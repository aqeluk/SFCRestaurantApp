import 'package:socket_io_example/main.dart';

Future<dynamic> fetchUKAddressDetails(String ukAddressId) async {
    try {
      var response =
          await supabase.from('UKAddress').select().eq('id', ukAddressId);
      return response;
    } catch (error) {
      return null;
    }
  }