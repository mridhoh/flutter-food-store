import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_food_store_app/resource/model/location_model.dart';
import 'package:flutter_food_store_app/resource/remote/checkout_remote_resource.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'location_state.dart';
part 'location_cubit.freezed.dart';

class LocationCubit extends Cubit<LocationState> {
  final CheckoutRemoteResource checkoutRemoteResource;
  LocationCubit(this.checkoutRemoteResource) : super(LocationState.initial());

  void getLocation(String search) async {
    emit(LocationState.loading());
    final result = await checkoutRemoteResource.getLocation(search);
    result.fold(
      (message) => emit(LocationState.error(message)),
      (location) => emit(LocationState.loaded(location)),
    );
  }

  void clearLocation() {
    emit(LocationState.initial());
  }
}
