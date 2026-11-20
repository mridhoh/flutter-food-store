part of 'product_popular_cubit.dart';

@freezed
class ProductPopularState with _$ProductPopularState {
  const factory ProductPopularState.initial() = _Initial;
  const factory ProductPopularState.loading() = _Loading;
  const factory ProductPopularState.loadedProductPopular(
      List<ProductModel> products) = _LoadedProductPopular;
  const factory ProductPopularState.error(String message) = _Error;
}
