import 'package:flutter/cupertino.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:nfc_manager/nfc_manager.dart';

class NfcService extends GetxService {

  NfcAvailability availability = NfcAvailability.disabled;

  Future init() async{
    availability = await NfcManager.instance.checkAvailability();
    return this;
  }

  Future getNfcMessage() async{
    debugPrint("service called!");
    if (availability != NfcAvailability.enabled) {
      print('NFC may not be supported or may be temporarily disabled.');
      return;
    }



  }

}
