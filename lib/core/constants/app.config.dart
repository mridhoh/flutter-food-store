class AppConfig {
  static const String baseUrl = 'http://10.123.208.83';
  static const String apiPath = '$baseUrl/api/';
  static const String storagePath = '$baseUrl/storage/';
  static const String storageImage = storagePath;
  static const String storageAvatar = '${storagePath}avatars/';
  static const String urlPayment =
      'https://app.sandbox.midtrans.com/snap/v2/vtweb/';
}
