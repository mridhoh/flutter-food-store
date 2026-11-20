import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_food_store_app/resource/model/product_model.dart';
import 'package:flutter_food_store_app/resource/remote/home_remote_resource.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_popular_state.dart';
part 'product_popular_cubit.freezed.dart';

class ProductPopularCubit extends Cubit<ProductPopularState> {
  final HomeRemoteResource homeRemoteResource;
  ProductPopularCubit(this.homeRemoteResource)
      : super(ProductPopularState.initial());

  Future<void> fetchProductPopular() async {
    emit(ProductPopularState.loading());
    final result = await homeRemoteResource.fetchProductsPopular();
    result.fold(
      (error) => emit(ProductPopularState.error(error)),
      (products) => emit(ProductPopularState.loadedProductPopular(products)),
    );
  }
}
