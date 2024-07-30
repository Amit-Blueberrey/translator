import 'package:get/get.dart';
import 'package:translator/core/navbar/navbar.dart';
import 'package:translator/features/login_signup/views/login.dart';
import 'package:translator/features/one_on_one_translation/one_on_one.dart';
import 'package:translator/features/translation/views/translation.dart';
import 'package:translator/routes/pages_name.dart';


class AppPages {
  static final List<GetPage> routes = [
    GetPage(name: PagesName.translator, page: () => translation_home()),
    GetPage(name: PagesName.login, page: () => login()),
    GetPage(name: PagesName.oneOnOne, page: () => OneOnOneCommunicationPage()),
    GetPage(name: PagesName.navbar, page: () => navBar()),
    // GetPage(name: '/page3', page: () => Page3()),
  ];
}

