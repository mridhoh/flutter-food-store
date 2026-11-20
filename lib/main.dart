import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_food_store_app/app_router.dart';
import 'package:dio/dio.dart';
import 'package:flutter_food_store_app/bloc/auth/auth_bloc.dart';
import 'package:flutter_food_store_app/bloc/cart/cart_bloc.dart';
import 'package:flutter_food_store_app/bloc/category/category_cubit.dart';
import 'package:flutter_food_store_app/bloc/order/order_cubit.dart';
import 'package:flutter_food_store_app/bloc/product/product_cubit.dart';
import 'package:flutter_food_store_app/bloc/product_popular/product_popular_cubit.dart';
import 'package:flutter_food_store_app/bloc/profile/profile_bloc.dart';
import 'package:flutter_food_store_app/bloc/slider/slider_cubit.dart';
import 'package:flutter_food_store_app/core/constants/app.config.dart';
import 'package:flutter_food_store_app/core/utils/auth_interceptor.dart';
import 'package:flutter_food_store_app/resource/remote/auth_remote_resource.dart';
import 'package:flutter_food_store_app/resource/remote/cart_remote_resource.dart';
import 'package:flutter_food_store_app/resource/remote/checkout_remote_resource.dart';
import 'package:flutter_food_store_app/resource/remote/home_remote_resource.dart';
import 'package:flutter_food_store_app/resource/remote/order_remote_resource.dart';
import 'package:flutter_food_store_app/resource/remote/profile_remote_resource.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final dio = Dio(BaseOptions(baseUrl: AppConfig.apiPath));

  final homeRemoteResource = HomeRemoteResource(dio);
  final profileRemoteResource = ProfileRemoteResource(dio);
  final authRemoteResource = AuthRemoteResource(dio);
  final orderRemoteResource = OrderRemoteResource(dio);
  final cartRemoteResource = CartRemoteResource(dio);
  final checkoutRemoteResource = CheckoutRemoteResource(dio);
  final authBloc = AuthBloc(authRemoteResource)
    ..add(AuthEvent.checkLoginStatus());

  final appRouter = AppRouter(
    authBloc: authBloc,
    orderRemoteResource: orderRemoteResource,
    homeRemoteResource: homeRemoteResource,
    checkoutRemoteResource: checkoutRemoteResource,
  );

  dio.interceptors.add(AuthInterceptor(authBloc));
  runApp(
    MyApp(
      appRouter: appRouter,
      authBloc: authBloc,
      profileRemoteResource: profileRemoteResource,
      orderRemoteResource: orderRemoteResource,
      homeRemoteResource: homeRemoteResource,
      cartRemoteResource: cartRemoteResource,
    ),
  );
}

class MyApp extends StatelessWidget {
  final AppRouter appRouter;
  final AuthBloc authBloc;
  final ProfileRemoteResource profileRemoteResource;
  final OrderRemoteResource orderRemoteResource;
  final HomeRemoteResource homeRemoteResource;
  final CartRemoteResource cartRemoteResource;

  const MyApp({
    super.key,
    required this.appRouter,
    required this.authBloc,
    required this.profileRemoteResource,
    required this.orderRemoteResource,
    required this.homeRemoteResource,
    required this.cartRemoteResource,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: authBloc),
        BlocProvider(create: (context) => ProfileBloc(profileRemoteResource)),
        BlocProvider(create: (context) => OrderCubit(orderRemoteResource)),
        BlocProvider(
          create: (context) => SliderCubit(homeRemoteResource)..fetchSlider(),
        ),
        BlocProvider(
          create: (context) =>
              CategoryCubit(homeRemoteResource)..fetchCategory(),
        ),
        BlocProvider(
          create: (_) => ProductCubit(homeRemoteResource)..fetchProduct(),
        ),
        BlocProvider(
          create: (_) =>
              ProductPopularCubit(homeRemoteResource)..fetchProductPopular(),
        ),
        BlocProvider(create: (context) => CartBloc(cartRemoteResource)),
      ],
      child: MaterialApp.router(
        title: 'Food Store',
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.grey.shade100,
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.orange),
          useMaterial3: true,
        ),
        routerConfig: appRouter.router,
      ),
    );
  }
}
