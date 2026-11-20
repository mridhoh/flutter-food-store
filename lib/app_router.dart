import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_food_store_app/bloc/auth/auth_bloc.dart';
import 'package:flutter_food_store_app/bloc/cart/cart_bloc.dart';
import 'package:flutter_food_store_app/bloc/category/category_cubit.dart';
import 'package:flutter_food_store_app/bloc/checkout/checkout_cubit.dart';
import 'package:flutter_food_store_app/bloc/location/location_cubit.dart';
import 'package:flutter_food_store_app/bloc/order/order_cubit.dart';
import 'package:flutter_food_store_app/bloc/product/product_cubit.dart';
import 'package:flutter_food_store_app/bloc/profile/profile_bloc.dart';
import 'package:flutter_food_store_app/bloc/review_product/review_product_cubit.dart';
import 'package:flutter_food_store_app/bloc/shipping_cost/shipping_cost_cubit.dart';
import 'package:flutter_food_store_app/page/auth/login_page.dart';
import 'package:flutter_food_store_app/page/auth/register_page.dart';
import 'package:flutter_food_store_app/page/checkout/checkout_page.dart';
import 'package:flutter_food_store_app/page/dashboard/cart_page.dart';
import 'package:flutter_food_store_app/page/dashboard/dashboard_page.dart';
import 'package:flutter_food_store_app/page/dashboard/home_page.dart';
import 'package:flutter_food_store_app/page/dashboard/order_page.dart';
import 'package:flutter_food_store_app/page/dashboard/profile_page.dart';
import 'package:flutter_food_store_app/page/midtrans/midtrans_payment_page.dart';
import 'package:flutter_food_store_app/page/order/order_detail_page.dart';
import 'package:flutter_food_store_app/page/product/all_product_page.dart';
import 'package:flutter_food_store_app/page/product/detail_product_page.dart';
import 'package:flutter_food_store_app/page/product/product_by_category_page.dart';
import 'package:flutter_food_store_app/page/search/search_page.dart';
import 'package:flutter_food_store_app/resource/model/category_model.dart';
import 'package:flutter_food_store_app/resource/remote/checkout_remote_resource.dart';
import 'package:flutter_food_store_app/resource/remote/home_remote_resource.dart';
import 'package:flutter_food_store_app/resource/remote/order_remote_resource.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  final AuthBloc authBloc;
  final OrderRemoteResource orderRemoteResource;
  final HomeRemoteResource homeRemoteResource;
  final CheckoutRemoteResource checkoutRemoteResource;
  AppRouter({
    required this.authBloc,
    required this.orderRemoteResource,
    required this.homeRemoteResource,
    required this.checkoutRemoteResource,
  });

  late final GoRouter router = GoRouter(
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    initialLocation: '/dashboard/home',
    redirect: (context, state) {
      final authState = authBloc.state;
      final isLoggedIn = authState is Authenticated;

      final protectedRoutes = [
        '/dashboard/order',
        '/dashboard/profile',
        '/dashboard/cart',
        '/order',
        '/checkout',
      ];

      final isProtected = protectedRoutes.any(
        (route) => state.matchedLocation.startsWith(route),
      );

      if (!isLoggedIn && isProtected) return '/login';

      if (isLoggedIn && state.matchedLocation == '/login') {
        return '/login';
      }

      return null;
    },
    routes: [
      ShellRoute(
        builder: (_, _, child) => DashboardPage(child: child),
        routes: [
          GoRoute(
            path: '/dashboard/home',
            builder: (_, _) {
              return HomePage();
            },
          ),
          GoRoute(
            path: '/dashboard/order',
            builder: (context, state) {
              context.read<OrderCubit>().fetchOrders(isRefresh: true);
              return OrderPage();
            },
          ),
          GoRoute(
            path: '/dashboard/cart',
            builder: (context, state) {
              context.read<CartBloc>().add(CartEvent.fetchCart());
              return CartPage();
            },
          ),
          GoRoute(
            path: '/dashboard/profile',
            builder: (context, state) {
              context.read<ProfileBloc>().add(ProfileEvent.loadProfile());
              return ProfilePage();
            },
          ),
        ],
      ),
      GoRoute(path: '/login', builder: (_, _) => const LoginPage()),
      GoRoute(path: '/register', builder: (_, _) => RegisterPage()),
      GoRoute(
        path: '/orderDetail/:snapToken',
        builder: (context, state) {
          final snapToken = state.pathParameters['snapToken'] ?? '';
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) =>
                    OrderCubit(orderRemoteResource)..detailOrder(snapToken),
              ),
              BlocProvider(
                create: (context) => ReviewProductCubit(orderRemoteResource),
              ),
            ],
            child: OrderDetailPage(),
          );
        },
      ),
      GoRoute(
        path: '/midtransPayment/:snapToken',
        builder: (context, state) {
          return MidtransPaymentPage(
            snapToken: state.pathParameters['snapToken'] ?? '',
          );
        },
      ),
      GoRoute(
        path: '/allProducts',
        builder: (context, state) => BlocProvider(
          create: (context) =>
              ProductCubit(homeRemoteResource)..fetchProduct(isRefresh: true),
          child: AllProductPage(),
        ),
      ),
      GoRoute(
        path: '/detailProduct/:slug',
        builder: (context, state) {
          return BlocProvider(
            create: (context) =>
                ProductCubit(homeRemoteResource)
                  ..detailProduct(state.pathParameters['slug'] ?? ''),
            child: DetailProductPage(),
          );
        },
      ),
      GoRoute(
        path: '/productByCategory',
        builder: (context, state) {
          final category = state.extra as CategoryModel;
          return BlocProvider(
            create: (context) =>
                CategoryCubit(homeRemoteResource)
                  ..fetchCategoryBySlug(category.slug ?? ''),
            child: ProductByCategoryPage(categoryName: category.name ?? ''),
          );
        },
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) {
          final String totalPrice =
              state.uri.queryParameters['totalPrice'] ?? '0';
          final String totalWeight =
              state.uri.queryParameters['totalWeight'] ?? '0';
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => ShippingCostCubit(checkoutRemoteResource),
              ),
              BlocProvider(
                create: (context) => CheckoutCubit(checkoutRemoteResource),
              ),
              BlocProvider(
                create: (context) => LocationCubit(checkoutRemoteResource),
              ),
            ],
            child: CheckoutPage(
              totalPrice: int.parse(totalPrice),
              totalWeight: int.parse(totalWeight),
            ),
          );
        },
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) {
          final String query = state.uri.queryParameters['query'] ?? '';
          return BlocProvider(
            create: (context) =>
                ProductCubit(homeRemoteResource)..fetchProduct(query: query),
            child: SearchPage(),
          );
        },
      ),
    ],
  );
}

/// Helper untuk konversi Bloc stream ke Listenable
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream stream) {
    stream.listen((_) {
      notifyListeners();
    });
  }
}
