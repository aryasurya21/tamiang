import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tamiang/providers/auth_provider.dart';
import 'package:tamiang/providers/mooncakes_provider.dart';
import 'package:tamiang/providers/orders_provider.dart';
import 'package:tamiang/screens/auth_screen.dart';
import 'package:tamiang/screens/order_form_screen.dart';
import 'package:tamiang/screens/cake_form_screen.dart';
import 'package:tamiang/screens/user_order_screen.dart';
import 'package:tamiang/screens/loading_screen.dart';
import 'package:tamiang/screens/user_cake_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => AuthProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, MoonCakesProvider>(
          update: (context, auth, previous) => MoonCakesProvider(
            auth.token,
            auth.userID,
            previous.mooncakes == null ? [] : previous.mooncakes,
          ),
          create: (context) => MoonCakesProvider(null, null, []),
        ),
        ChangeNotifierProxyProvider<AuthProvider, OrdersProvider>(
          update: (context, value, previous) => OrdersProvider(
            null,
            null,
            previous.orderedCakes == null ? [] : previous.orderedCakes,
          ),
          create: (context) => OrdersProvider(null, null, []),
        )
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) => MaterialApp(
          title: "Tamiang",
          theme: ThemeData(
            primarySwatch: Colors.red,
            accentColor: Colors.white,
            fontFamily: "Lato",
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: authProvider.isAuth
              ? UserOrderScreen()
              : FutureBuilder(
                  future: authProvider.tryAutoLogin(),
                  builder: (context, authData) =>
                      authData.connectionState == ConnectionState.waiting
                          ? LoadingScreen()
                          : AuthScreen(),
                ),
          routes: {
            UserCakeScreen.routeName: (ctx) => UserCakeScreen(),
            CakeFormScreen.routeName: (ctx) => CakeFormScreen(),
            OrderFormScreen.routeName: (ctx) => OrderFormScreen()
          },
        ),
      ),
    );
  }
}
