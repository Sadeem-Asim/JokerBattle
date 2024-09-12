import 'package:flutter/material.dart';

// import '/models/models.dart';
import '../screens/screens.dart';
// import "package:joker_battle/screens/Game/game_screen.dart";

class AppRouter {
  static Route onGenerateRoute(RouteSettings settings) {
    // print('This is route: ${settings.name}');
    switch (settings.name) {
      // case '/':
      //   return HomeScreen.route();
      //The method 'route' isn't
      case HomeScreen.routeName:
        return HomeScreen.route();
      case InfoScreen.routeName: //The getter 'routeName' isn't
        return InfoScreen.route(); //The method 'route' isn't
      case GameScreen.routeName: //The getter 'routeName' isn't
        return GameScreen.route();
      case SelectCardsScreen.routeName: //The getter 'routeName' isn't
        return SelectCardsScreen.route();  
      // case ProductScreen.routeName: //The getter 'routeName' isn't
      //   return ProductScreen.route(product: settings.arguments as Product);
      // case CatalogScreen.routeName: //The getter 'routeName' isn't
      //   return CatalogScreen.route(category: settings.arguments as Category);
      // case WishListScreen.routeName: //The getter 'routeName' isn't
      //   return WishListScreen.route();
      default:
        return _errorRoute(); //The method '_errorRoute' isn't
    }
  }

  static Route _errorRoute() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: '/error'),
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
      ), // Scaffold
    ); // MaterialPageRoute
  }
}
