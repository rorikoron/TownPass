
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

class OpenUriService extends GetxService{

  Future init() async{
    return this;

  }

  Future openUri(String uri) async{
    if (await canLaunchUrlString(uri)) {
        await launchUrlString(uri, mode: LaunchMode.externalApplication);
    }
  }
}
