import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function json(status: number, body: Record<string, unknown>) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

function constantTimeEqual(a: string, b: string): boolean {
  const encoder = new TextEncoder();
  const left = encoder.encode(a);
  const right = encoder.encode(b);
  let diff = left.length ^ right.length;
  const length = Math.max(left.length, right.length);
  for (let i = 0; i < length; i++) diff |= (left[i] ?? 0) ^ (right[i] ?? 0);
  return diff === 0;
}

async function sha256(value: string): Promise<string> {
  const bytes = await crypto.subtle.digest("SHA-256", new TextEncoder().encode(value));
  return [...new Uint8Array(bytes)].map((b) => b.toString(16).padStart(2, "0")).join("");
}

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return json(405, { error: "Method not allowed" });

  const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
  const configuredPin = Deno.env.get("RECIPE_GUIDE_ADMIN_PIN") ?? "";
  const adminEmail = Deno.env.get("RECIPE_GUIDE_ADMIN_EMAIL") ?? "";
  if (!supabaseUrl || !anonKey || !serviceKey || !configuredPin || !adminEmail) {
    console.error("PIN login Edge Function is missing required secrets");
    return json(500, { error: "PIN login is not configured on the server." });
  }

  let pin = "";
  try {
    const body = await req.json();
    pin = typeof body.pin === "string" ? body.pin : "";
  } catch {
    return json(400, { error: "Invalid request." });
  }
  if (!/^\d{4,8}$/.test(pin)) return json(400, { error: "Enter a valid PIN." });

  const forwarded = req.headers.get("x-forwarded-for")?.split(",")[0]?.trim() ?? "unknown";
  const ipHash = await sha256(forwarded + (Deno.env.get("PIN_RATE_LIMIT_SALT") ?? serviceKey));
  const restHeaders = { apikey: serviceKey, Authorization: `Bearer ${serviceKey}` };
  const since = new Date(Date.now() - 15 * 60 * 1000).toISOString();
  const attemptsUrl = `${supabaseUrl}/rest/v1/recipe_guide_pin_attempts?ip_hash=eq.${ipHash}&attempted_at=gte.${encodeURIComponent(since)}&select=id`;

  try {
    const attemptsResponse = await fetch(attemptsUrl, { headers: restHeaders });
    if (!attemptsResponse.ok) throw new Error("Could not check PIN rate limit");
    const attempts = await attemptsResponse.json();
    if (Array.isArray(attempts) && attempts.length >= 8) {
      return json(429, { error: "Too many PIN attempts. Wait 15 minutes and try again." });
    }

    await fetch(`${supabaseUrl}/rest/v1/recipe_guide_pin_attempts`, {
      method: "POST",
      headers: { ...restHeaders, "Content-Type": "application/json", Prefer: "return=minimal" },
      body: JSON.stringify({ ip_hash: ipHash }),
    });

    if (!constantTimeEqual(pin, configuredPin)) {
      return json(401, { error: "Incorrect PIN." });
    }

    // Clear recent attempts for this client after successful verification.
    await fetch(`${supabaseUrl}/rest/v1/recipe_guide_pin_attempts?ip_hash=eq.${ipHash}`, {
      method: "DELETE",
      headers: restHeaders,
    });

    // Exchange the server-verified PIN for a real Supabase session belonging
    // to the configured, confirmed service account. The password is never sent
    // to or stored by the Flutter client.
    const linkResponse = await fetch(`${supabaseUrl}/auth/v1/admin/generate_link`, {
      method: "POST",
      headers: { ...restHeaders, "Content-Type": "application/json" },
      body: JSON.stringify({ type: "magiclink", email: adminEmail }),
    });
    const link = await linkResponse.json();
    if (!linkResponse.ok) {
      console.error("Could not create PIN login session", link);
      return json(502, { error: "Could not create a Store session. Contact the administrator." });
    }
    const tokenHash = link?.properties?.hashed_token ?? link?.hashed_token;
    if (typeof tokenHash !== "string" || tokenHash.length === 0) {
      console.error("Magic link response did not include hashed_token");
      return json(502, { error: "Could not create a Store session. Contact the administrator." });
    }

    const verifyResponse = await fetch(`${supabaseUrl}/auth/v1/verify`, {
      method: "POST",
      headers: { apikey: anonKey, "Content-Type": "application/json" },
      body: JSON.stringify({ type: "magiclink", token_hash: tokenHash }),
    });
    const session = await verifyResponse.json();
    if (!verifyResponse.ok || typeof session?.refresh_token !== "string") {
      console.error("Could not exchange PIN login for session", session);
      return json(502, { error: "PIN accepted but the Store session could not be established." });
    }

    return json(200, {
      access_token: session.access_token,
      refresh_token: session.refresh_token,
      token_type: session.token_type,
      expires_in: session.expires_in,
    });
  } catch (error) {
    console.error("PIN login request failed", error);
    return json(500, { error: "PIN verification service is temporarily unavailable." });
  }
});
