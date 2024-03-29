import 'package:socket_io_example/main.dart';

Future<dynamic> fetchUserDetails(String userEmail) async {
    try {
      var response =
          await supabase.from('User').select().eq('email', userEmail);
      return response;
    } catch (error) {
      return null;
    }
  }