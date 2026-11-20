import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter_food_store_app/resource/model/checkout_model.dart';
import 'package:flutter_food_store_app/resource/model/location_model.dart';
import 'package:flutter_food_store_app/resource/model/shipping_cost_model.dart';

class CheckoutRemoteResource {
  final Dio _dio;

  CheckoutRemoteResource(this._dio);

  Future<Either<String, List<LocationModel>>> getLocation(String search) async {
    try {
      final response = await _dio.get(
        'public/search-destination?search=$search',
      );
      final data = _extractList(response.data);
      if (data == null) {
        return Left(
          _extractMessage(response.data, 'Format data lokasi tidak valid'),
        );
      }
      final result = data.map((e) => LocationModel.fromMap(e)).toList();
      return Right(result);
    } on DioException catch (e) {
      return Left(e.toString());
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, List<ShippingCostModel>>> getShippingCost(
    int cityId,
    int weight,
    String courierName,
  ) async {
    try {
      final response = await _dio.post(
        'public/check-ongkir',
        data: {'destination': cityId, 'weight': weight, 'courier': courierName},
      );
      final data = _extractList(response.data);
      if (data == null) {
        return Left(
          _extractMessage(response.data, 'Format data ongkir tidak valid'),
        );
      }
      final result = data.map((e) => ShippingCostModel.fromMap(e)).toList();
      return Right(result);
    } on DioException catch (e) {
      return Left(e.toString());
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, String>> checkOut(CheckoutModel checkout) async {
    try {
      final response = await _dio.post(
        'public/checkout',
        data: {
          'province_name': checkout.provinceName,
          'city_name': checkout.cityName,
          'district_name': checkout.districtName,
          'subdistrict_name': checkout.subdistrictName,
          'zip_code': checkout.zipCode,
          'full_address': checkout.fullAddress,
          'weight': checkout.weight,
          'shipping_courier': checkout.shippingCourier,
          'shipping_service': checkout.shippingService,
          'shipping_cost': checkout.shippingCost,
          'total': checkout.total,
        },
      );
      return Right(response.data['data']['snap_token']);
    } on DioException catch (e) {
      return Left(e.toString());
    } catch (e) {
      return Left(e.toString());
    }
  }

  /// Mengambil list dari respons API.
  /// Mendukung dua bentuk: list langsung `[...]`
  /// atau dibungkus `{"data": [...]}`. Selain itu mengembalikan null.
  List<dynamic>? _extractList(dynamic body) {
    if (body is List) return body;
    if (body is Map<String, dynamic> && body['data'] is List) {
      return body['data'] as List<dynamic>;
    }
    return null;
  }

  /// Mengambil pesan dari respons API (`message`), atau memakai [fallback].
  String _extractMessage(dynamic body, String fallback) {
    if (body is Map<String, dynamic> && body['message'] != null) {
      return body['message'].toString();
    }
    return fallback;
  }
}
