import 'dart:convert';

import 'package:town_pass/bean/account.dart';
import 'package:town_pass/gen/assets.gen.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AccountService extends GetxService {
  Account? _account;

  Account? get account => _account;

  Future<AccountService> init() async {
    final accountResponse = AccountResponse.fromJson(
      jsonDecode(await rootBundle.loadString(Assets.mockData.account)),
    );
    _account = accountResponse.account;
    return this;
  }

  updateAccount(Account account) {
    _account = account;
  }
}

// import 'dart:convert';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:town_pass/bean/account.dart';
// import 'package:town_pass/gen/assets.gen.dart';
//
// class AccountService extends GetxService {
//   Account? _account;
//
//   Account? get account => _account;
//
//   Future<AccountService> init() async {
//     // dart-define からファイル名を取得（デフォルトは account.json）
//     const mockFile = String.fromEnvironment('ACCOUNT_FILE', defaultValue: 'account.json');
//
//     // パスを動的に組み立ててロード
//     final jsonString = await rootBundle.loadString('assets/mock/$mockFile');
//
//     final accountResponse = AccountResponse.fromJson(jsonDecode(jsonString));
//     _account = accountResponse.account;
//
//     return this;
//   }
//
//   void updateAccount(Account account) {
//     _account = account;
//   }
// }
