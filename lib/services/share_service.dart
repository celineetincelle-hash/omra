import 'package:share_plus/share_plus.dart';
import 'package:latlong2/latlong.dart';

class ShareService {
  static Future<void> shareLocation(LatLng position) async {
    final String url = 
        'https://www.openstreetmap.org/?mlat=${position.latitude}&mlon=${position.longitude}#map=15/${position.latitude}/${position.longitude}';
    final String message = 
        'Ma position actuelle: $url\n'
        'Latitude: ${position.latitude.toStringAsFixed(5)}\n'
        'Longitude: ${position.longitude.toStringAsFixed(5)}';

    await Share.share(message);
  }
}
