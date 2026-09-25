// ignore_for_file: avoid_print

// import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bigger_brew_barista/app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    // ----------------------------------------------------------
    // INITIALIZE SHARED PREFERENCES FOR WIDGET TESTS
    // ----------------------------------------------------------
    //
    // RecipeRepository uses SharedPreferences for local
    // recipe overrides.
    //
    // Initialize the mock implementation before the app starts.
    //
    // ----------------------------------------------------------

    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
    'opens the Dark Chocolate recipe from the menu and loads its JSON data',
    (tester) async {
      print('');
      print('==============================================');
      print('RECIPE FLOW TEST');
      print('==============================================');

      // ----------------------------------------------------------
      // START APP
      // ----------------------------------------------------------

      await tester.pumpWidget(const BiggerBrewApp());

      // Allow the initial frame to render.
      await tester.pump();

      print('');
      print('INITIAL SCREEN');
      print('==============================================');

      // ----------------------------------------------------------
      // INITIAL SCREEN
      // ----------------------------------------------------------

      final milkTeaInitial = find.text('Milk Tea');

      print(
        'Milk Tea widgets: '
        '${milkTeaInitial.evaluate().length}',
      );

      expect(
        milkTeaInitial,
        findsAtLeastNWidgets(1),
        reason: 'Milk Tea menu category should be visible.',
      );

      // ----------------------------------------------------------
      // OPEN MILK TEA
      // ----------------------------------------------------------

      await tester.tap(milkTeaInitial.first);

      await tester.pumpAndSettle(const Duration(seconds: 2));

      print('');
      print('AFTER TAPPING MILK TEA');
      print('==============================================');

      final affordaMilktea = find.text('Afforda Milktea');

      final twelveDrinks = find.text('12 Drinks');

      final darkChocolateBefore = find.text('Dark Chocolate');

      print(
        'Afforda Milktea widgets: '
        '${affordaMilktea.evaluate().length}',
      );

      print(
        '12 Drinks widgets: '
        '${twelveDrinks.evaluate().length}',
      );

      print(
        'Dark Chocolate widgets: '
        '${darkChocolateBefore.evaluate().length}',
      );

      expect(
        affordaMilktea,
        findsAtLeastNWidgets(1),
        reason: 'Afforda Milktea group should be visible.',
      );

      // ----------------------------------------------------------
      // OPEN AFFORDA MILKTEA
      // ----------------------------------------------------------

      await tester.tap(affordaMilktea.first);

      await tester.pumpAndSettle(const Duration(seconds: 2));

      print('');
      print('AFTER OPENING AFFORDA MILKTEA');
      print('==============================================');

      final darkChocolate = find.text('Dark Chocolate');

      print(
        'Dark Chocolate widgets: '
        '${darkChocolate.evaluate().length}',
      );

      expect(
        darkChocolate,
        findsAtLeastNWidgets(1),
        reason: 'Dark Chocolate drink should be visible.',
      );

      // ----------------------------------------------------------
      // OPEN DARK CHOCOLATE RECIPE
      // ----------------------------------------------------------

      await tester.tap(darkChocolate.first);

      // Render the first frame after navigation.
      await tester.pump();

      print('');
      print('DARK CHOCOLATE RECIPE PAGE');
      print('==============================================');

      final loadingImmediately = find.text('Loading recipe...');

      print(
        'Loading widgets immediately after navigation: '
        '${loadingImmediately.evaluate().length}',
      );

      // ----------------------------------------------------------
      // WAIT FOR RECIPE LOAD
      // ----------------------------------------------------------
      //
      // Do not use pumpAndSettle for the recipe loading phase.
      //
      // FutureBuilder / asynchronous storage and asset loading can
      // cause pumpAndSettle to wait indefinitely.
      //
      // Instead, advance the test clock in controlled intervals.
      //
      // ----------------------------------------------------------

      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 250));

        final loadingCount = find.text('Loading recipe...').evaluate().length;

        final recipeCount = find.text('Recipe').evaluate().length;

        final darkChocolateCount = find
            .text('Dark Chocolate')
            .evaluate()
            .length;

        print(
          'WAIT ${(i + 1) * 250}ms '
          '| Loading: $loadingCount '
          '| Recipe: $recipeCount '
          '| Dark Chocolate: $darkChocolateCount',
        );

        // Stop once the recipe title appears.
        if (darkChocolateCount > 0) {
          break;
        }
      }

      // Give the widget tree one final frame.
      await tester.pump();

      print('');
      print('RECIPE LOAD RESULT');
      print('==============================================');

      // ----------------------------------------------------------
      // FIND RECIPE CONTENT
      // ----------------------------------------------------------

      final darkChocolateTitle = find.text('Dark Chocolate');

      final darkChocolatePowder = find.textContaining('Dark Chocolate Powder');

      final creamer = find.textContaining('Creamer');

      final fructose = find.textContaining('Fructose');

      final loadingRecipe = find.text('Loading recipe...');

      print(
        'Loading widgets: '
        '${loadingRecipe.evaluate().length}',
      );

      print(
        'Dark Chocolate title widgets: '
        '${darkChocolateTitle.evaluate().length}',
      );

      print(
        'Dark Chocolate Powder widgets: '
        '${darkChocolatePowder.evaluate().length}',
      );

      print(
        'Creamer widgets: '
        '${creamer.evaluate().length}',
      );

      print(
        'Fructose widgets: '
        '${fructose.evaluate().length}',
      );

      // ----------------------------------------------------------
      // RECIPE TITLE
      // ----------------------------------------------------------

      expect(
        darkChocolateTitle,
        findsAtLeastNWidgets(1),
        reason: 'Dark Chocolate recipe page should display its title.',
      );

      // ----------------------------------------------------------
      // INGREDIENTS
      // ----------------------------------------------------------
      //
      // "Dark Chocolate Powder" can appear more than once on
      // the recipe page.
      //
      // Therefore we intentionally use findsAtLeastNWidgets(1).
      //
      // ----------------------------------------------------------

      expect(
        darkChocolatePowder,
        findsAtLeastNWidgets(1),
        reason:
            'Dark Chocolate recipe should load and display '
            'Dark Chocolate Powder.',
      );

      expect(
        creamer,
        findsAtLeastNWidgets(1),
        reason: 'Dark Chocolate recipe should display Creamer.',
      );

      expect(
        fructose,
        findsAtLeastNWidgets(1),
        reason: 'Dark Chocolate recipe should display Fructose.',
      );

      // ----------------------------------------------------------
      // FINAL DIAGNOSTIC
      // ----------------------------------------------------------

      print('');
      print('==============================================');
      print('RECIPE FLOW TEST COMPLETE');
      print('==============================================');

      print(
        'Dark Chocolate title: '
        '${darkChocolateTitle.evaluate().length}',
      );

      print(
        'Dark Chocolate Powder: '
        '${darkChocolatePowder.evaluate().length}',
      );

      print(
        'Creamer: '
        '${creamer.evaluate().length}',
      );

      print(
        'Fructose: '
        '${fructose.evaluate().length}',
      );

      print('==============================================');
    },
  );
}
