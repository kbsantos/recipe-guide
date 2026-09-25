import '../models/category_type.dart';
import '../models/menu_category.dart';
import '../models/menu_group.dart';
import '../models/menu_item.dart';

class MenuRepository {
  MenuRepository._();

  static final List<MenuCategory> categories = [
    // ==========================================================
    // MILK TEA
    // ==========================================================
    MenuCategory(
      type: CategoryType.milkTea,
      title: 'Milk Tea',
      subtitle: 'Afforda + Signature',
      groups: [
        // ------------------------------------------------------
        // Afforda Milktea
        // ------------------------------------------------------
        MenuGroup(
          id: 'afforda_milktea',
          title: 'Afforda Milktea',
          items: const [
            MenuItem(
              id: 'classic_milktea',
              title: 'Classic Milktea',
              recipePath: 'afforda_milktea/classic_milktea',
            ),
            MenuItem(
              id: 'dark_chocolate',
              title: 'Dark Chocolate',
              recipePath: 'afforda_milktea/dark_chocolate',
            ),
            MenuItem(
              id: 'chocolate',
              title: 'Chocolate',
              recipePath: 'afforda_milktea/chocolate',
            ),
            MenuItem(
              id: 'okinawa',
              title: 'Okinawa',
              recipePath: 'afforda_milktea/okinawa',
            ),
            MenuItem(
              id: 'cheesecake',
              title: 'Cheesecake',
              recipePath: 'afforda_milktea/cheesecake',
            ),
            MenuItem(
              id: 'cookies_cream',
              title: 'Cookies & Cream',
              recipePath: 'afforda_milktea/cookies_cream',
            ),
            MenuItem(
              id: 'salted_caramel',
              title: 'Salted Caramel',
              recipePath: 'afforda_milktea/salted_caramel',
            ),
            MenuItem(
              id: 'wintermelon',
              title: 'Wintermelon',
              recipePath: 'afforda_milktea/wintermelon',
            ),
            MenuItem(
              id: 'javachip',
              title: 'Javachip',
              recipePath: 'afforda_milktea/javachip',
            ),
            MenuItem(
              id: 'taro',
              title: 'Taro',
              recipePath: 'afforda_milktea/taro',
            ),
            MenuItem(
              id: 'strawberry',
              title: 'Strawberry',
              recipePath: 'afforda_milktea/strawberry',
            ),
            MenuItem(
              id: 'matcha',
              title: 'Matcha',
              recipePath: 'afforda_milktea/matcha',
            ),
          ],
        ),

        // ------------------------------------------------------
        // Signature Milktea
        // ------------------------------------------------------
        MenuGroup(
          id: 'signature_milktea',
          title: 'Signature Milktea',
          items: const [
            MenuItem(
              id: 'biscoff_milktea',
              title: 'Biscoff Milktea',
              recipePath: 'signature_milktea/biscoff_milktea',
            ),
            MenuItem(
              id: 'choco_butternut_donut',
              title: 'Choco Butternut Donut',
              recipePath: 'signature_milktea/choco_butternut_donut',
            ),
            MenuItem(
              id: 'matcha_green_tea_boba',
              title: 'Matcha Green Tea Boba',
              recipePath: 'signature_milktea/matcha_green_tea_boba',
            ),
            MenuItem(
              id: 'brown_sugar_boba',
              title: 'Brown Sugar Boba',
              recipePath: 'signature_milktea/brown_sugar_boba',
            ),
            MenuItem(
              id: 'milo_boba',
              title: 'Milo Boba',
              recipePath: 'signature_milktea/milo_boba',
            ),
            MenuItem(
              id: 'choco_oreo_boba',
              title: 'Choco Oreo Boba',
              recipePath: 'signature_milktea/choco_oreo_boba',
            ),
          ],
        ),
      ],
    ),

    // ==========================================================
    // COFFEE
    // ==========================================================
    MenuCategory(
      type: CategoryType.coffee,
      title: 'Coffee',
      subtitle: 'Hot • Iced • Signature',
      groups: [
        // ------------------------------------------------------
        // Hot Coffee
        // ------------------------------------------------------
        MenuGroup(
          id: 'hot_coffee',
          title: 'Hot Coffee',
          items: const [
            MenuItem(
              id: 'hot_black_coffee',
              title: 'Hot Black Coffee',
              recipePath: 'hot_coffee/hot_black_coffee',
            ),
            MenuItem(
              id: 'hot_latte',
              title: 'Hot Latte',
              recipePath: 'hot_coffee/hot_latte',
            ),
            MenuItem(
              id: 'hot_vanilla_latte',
              title: 'Hot Vanilla Latte',
              recipePath: 'hot_coffee/hot_vanilla_latte',
            ),
            MenuItem(
              id: 'hot_hazelnut_latte',
              title: 'Hot Hazelnut Latte',
              recipePath: 'hot_coffee/hot_hazelnut_latte',
            ),
            MenuItem(
              id: 'hot_caramel_macchiato',
              title: 'Hot Caramel Macchiato',
              recipePath: 'hot_coffee/hot_caramel_macchiato',
            ),
            MenuItem(
              id: 'hot_spanish_latte',
              title: 'Hot Spanish Latte',
              recipePath: 'hot_coffee/hot_spanish_latte',
            ),
            MenuItem(
              id: 'hot_matcha',
              title: 'Hot Matcha',
              recipePath: 'hot_coffee/hot_matcha',
            ),
            MenuItem(
              id: 'hot_chocolate',
              title: 'Chocolate',
              recipePath: 'hot_coffee/chocolate',
            ),
          ],
        ),

        // ------------------------------------------------------
        // Afforda Coffee
        // ------------------------------------------------------
        MenuGroup(
          id: 'afforda_coffee',
          title: 'Afforda Coffee',
          items: const [
            MenuItem(
              id: 'iced_americano',
              title: 'Iced Americano',
              recipePath: 'afforda_coffee/iced_americano',
            ),
            MenuItem(
              id: 'iced_coffee_latte',
              title: 'Iced Coffee Latte',
              recipePath: 'afforda_coffee/iced_coffee_latte',
            ),
            MenuItem(
              id: 'iced_spanish_latte',
              title: 'Iced Spanish Latte',
              recipePath: 'afforda_coffee/iced_spanish_latte',
            ),
            MenuItem(
              id: 'iced_salted_caramel_latte',
              title: 'Iced Salted Caramel Latte',
              recipePath: 'afforda_coffee/iced_salted_caramel_latte',
            ),
            MenuItem(
              id: 'iced_cheesecake_coffee',
              title: 'Iced Cheesecake Coffee',
              recipePath: 'afforda_coffee/iced_cheesecake_coffee',
            ),
            MenuItem(
              id: 'iced_matcha_latte',
              title: 'Iced Matcha Latte',
              recipePath: 'afforda_coffee/iced_matcha_latte',
            ),
            MenuItem(
              id: 'iced_dark_chocolate_latte',
              title: 'Iced Dark Chocolate Latte',
              recipePath: 'afforda_coffee/iced_dark_chocolate_latte',
            ),
          ],
        ),

        // ------------------------------------------------------
        // Signature Coffee
        // ------------------------------------------------------
        MenuGroup(
          id: 'signature_coffee',
          title: 'Signature Coffee',
          items: const [
            MenuItem(
              id: 'iced_peach_americano',
              title: 'Iced Peach Americano',
              recipePath: 'signature_coffee/iced_peach_americano',
            ),
            MenuItem(
              id: 'iced_matcha_cream_puff',
              title: 'Iced Matcha Cream Puff',
              recipePath: 'signature_coffee/iced_matcha_cream_puff',
            ),
            MenuItem(
              id: 'iced_butter_caramel',
              title: 'Iced Butter Caramel',
              recipePath: 'signature_coffee/iced_butter_caramel',
            ),
            MenuItem(
              id: 'iced_hazelnut_mocha',
              title: 'Iced Hazelnut Mocha',
              recipePath: 'signature_coffee/iced_hazelnut_mocha',
            ),
            MenuItem(
              id: 'iced_brown_sugar_latte',
              title: 'Iced Brown Sugar Latte',
              recipePath: 'signature_coffee/iced_brown_sugar_latte',
            ),
            MenuItem(
              id: 'iced_caramel_macchiato',
              title: 'Iced Caramel Macchiato',
              recipePath: 'signature_coffee/iced_caramel_macchiato',
            ),
            MenuItem(
              id: 'iced_french_vanilla',
              title: 'Iced French Vanilla',
              recipePath: 'signature_coffee/iced_french_vanilla',
            ),
          ],
        ),
      ],
    ),

    // ==========================================================
    // MATCHA
    // ==========================================================
    MenuCategory(
      type: CategoryType.matcha,
      title: 'Matcha',
      subtitle: 'Matcha Series',
      groups: [
        MenuGroup(
          id: 'matcha_series',
          title: 'Matcha Series',
          items: const [
            MenuItem(
              id: 'matcha_oreo_frappe',
              title: 'Matcha Oreo Frappe',
              recipePath: 'matcha_series/matcha_oreo_frappe',
            ),
            MenuItem(
              id: 'matcha_pure_frappe',
              title: 'Matcha Pure Frappe',
              recipePath: 'matcha_series/matcha_pure_frappe',
            ),
            MenuItem(
              id: 'matcha_pistachio',
              title: 'Matcha Pistachio',
              recipePath: 'matcha_series/matcha_pistachio',
            ),
            MenuItem(
              id: 'matcha_greentea',
              title: 'Matcha Greentea',
              recipePath: 'matcha_series/matcha_greentea',
            ),
            MenuItem(
              id: 'matcha_strawberry',
              title: 'Matcha Strawberry',
              recipePath: 'matcha_series/matcha_strawberry',
            ),
          ],
        ),
      ],
    ),

    // ==========================================================
    // FRAPPE
    // ==========================================================
    MenuCategory(
      type: CategoryType.frappe,
      title: 'Frappe',
      subtitle: 'Blended Drinks',
      groups: [
        MenuGroup(
          id: 'frappe_selections',
          title: 'Frappe Selections',
          items: const [
            MenuItem(
              id: 'javachip_frappe',
              title: 'Javachip Frappe',
              recipePath: 'frappe/javachip_frappe',
            ),
            MenuItem(
              id: 'dark_mocha_frappe',
              title: 'Dark Mocha Frappe',
              recipePath: 'frappe/dark_mocha_frappe',
            ),
            MenuItem(
              id: 'caramel_coffee_frappe',
              title: 'Caramel Coffee Frappe',
              recipePath: 'frappe/caramel_coffee_frappe',
            ),
            MenuItem(
              id: 'strawberry_frappe',
              title: 'Strawberry Frappe',
              recipePath: 'frappe/strawberry_frappe',
            ),
            MenuItem(
              id: 'cookies_cream_frappe',
              title: 'Cookies & Cream Frappe',
              recipePath: 'frappe/cookies_cream_frappe',
            ),
            MenuItem(
              id: 'matcha_frappe',
              title: 'Matcha Frappe',
              recipePath: 'frappe/matcha_frappe',
            ),
            MenuItem(
              id: 'cookie_crumble',
              title: 'Cookie Crumble',
              recipePath: 'frappe/cookie_crumble',
            ),
            MenuItem(
              id: 'coffee_jelly',
              title: 'Coffee Jelly',
              recipePath: 'frappe/coffee_jelly',
            ),
          ],
        ),
      ],
    ),

    // ==========================================================
    // FRUIT TEA
    // ==========================================================
    MenuCategory(
      type: CategoryType.fruitTea,
      title: 'Fruit Tea',
      subtitle: 'Fruitea Series',
      groups: [
        MenuGroup(
          id: 'fruitea',
          title: 'Fruitea',
          items: const [
            MenuItem(
              id: 'lychee_fruitea',
              title: 'Lychee Fruitea',
              recipePath: 'fruitea/lychee_fruitea',
            ),
            MenuItem(
              id: 'strawberry_fruitea',
              title: 'Strawberry Fruitea',
              recipePath: 'fruitea/strawberry_fruitea',
            ),
            MenuItem(
              id: 'green_apple_fruitea',
              title: 'Green Apple Fruitea',
              recipePath: 'fruitea/green_apple_fruitea',
            ),
            MenuItem(
              id: 'blueberry_fruitea',
              title: 'Blueberry Fruitea',
              recipePath: 'fruitea/blueberry_fruitea',
            ),
          ],
        ),
      ],
    ),

    // ==========================================================
    // FRUITY SODA
    // ==========================================================
    MenuCategory(
      type: CategoryType.fruitySoda,
      title: 'Fruity Soda',
      subtitle: 'Sparkling Drinks',
      groups: [
        MenuGroup(
          id: 'fruity_soda',
          title: 'Fruity Soda',
          items: const [
            MenuItem(
              id: 'lychee_soda',
              title: 'Lychee Soda',
              recipePath: 'fruity_soda/lychee_soda',
            ),
            MenuItem(
              id: 'strawberry_soda',
              title: 'Strawberry Soda',
              recipePath: 'fruity_soda/strawberry_soda',
            ),
            MenuItem(
              id: 'green_apple_soda',
              title: 'Green Apple Soda',
              recipePath: 'fruity_soda/green_apple_soda',
            ),
            MenuItem(
              id: 'blueberry_soda',
              title: 'Blueberry Soda',
              recipePath: 'fruity_soda/blueberry_soda',
            ),
          ],
        ),
      ],
    ),

    // ==========================================================
    // SLUSHIES
    // ==========================================================
    MenuCategory(
      type: CategoryType.slushies,
      title: 'Slushies',
      subtitle: 'Ice Blended',
      groups: [
        MenuGroup(
          id: 'slushies',
          title: 'Slushies',
          items: const [
            MenuItem(
              id: 'green_apple_slushies',
              title: 'Green Apple Slushies',
              recipePath: 'slushies/green_apple_slushies',
            ),
            MenuItem(
              id: 'strawberry_slushies',
              title: 'Strawberry Slushies',
              recipePath: 'slushies/strawberry_slushies',
            ),
            MenuItem(
              id: 'blueberry_slushies',
              title: 'Blueberry Slushies',
              recipePath: 'slushies/blueberry_slushies',
            ),
            MenuItem(
              id: 'lychee_slushies',
              title: 'Lychee Slushies',
              recipePath: 'slushies/lychee_slushies',
            ),
          ],
        ),
      ],
    ),
  ];
}
