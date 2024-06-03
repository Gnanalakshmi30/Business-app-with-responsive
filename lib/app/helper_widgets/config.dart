import 'package:flutter/material.dart';

class AppConfig {
  static const appName = "aquila_hundi";

  static const apiUrl = "";

  // static const rootUrl = "http://192.168.1.3:3002";
  static const rootUrl = "http://172.16.35.116:3002";

  static const defaultImage = "";
  static const privacyUrl = "";
  static const termOfUseUrl = "";

  static const fontName = '';

  static String fcmToken = "";
  static String apnToken = "";
  static dynamic profile;
  static bool loginWithToken = true;

  static double size(BuildContext context, double s) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    if (height / width > 896 / 414) {
      return MediaQuery.of(context).size.width / 414 * s;
    } else {
      return MediaQuery.of(context).size.height / 896 * s;
    }
  }

  static double landSize(BuildContext context, double s) {
    // var width = MediaQuery.of(context).size.width;
    // var height = MediaQuery.of(context).size.height;
    return MediaQuery.of(context).size.width / 896 * s;
    // if (height / width > 896 / 414) {
    //   return MediaQuery.of(context).size.width / 414 * s;
    // } else {
    //   return MediaQuery.of(context).size.height / 896 * s;
    // }
  }

  static bool isPortrait(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var webWidth = MediaQuery.of(context).size.width;
    if (height > width && webWidth < 600) {
      return true;
    } else {
      return false;
    }
  }

  static bool isTablet(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    if (height > width) {
      if (width > 600) {
        return true;
      } else {
        return false;
      }
    } else {
      if (height > 600) {
        return true;
      } else {
        return false;
      }
    }
  }

  static bool isWeb(BuildContext context) {
    return MediaQuery.of(context).size.width > 600;
  }

  static double fullWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }
}

class AppFunc {
  static bool validateMobile(String phone) {
    String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    RegExp regExp = RegExp(pattern);
    if (phone.isEmpty) {
      return false;
    } else if (!regExp.hasMatch(phone)) {
      return false;
    }
    return true; //correct format
  }

  static bool validateEmail(String email) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = RegExp(pattern);
    if (email.isEmpty) {
      return false;
    } else if (!regExp.hasMatch(email)) {
      return false;
    }
    return true; //correct format
  }

  static String formatPhoneNumber(String str) {
    String cleaned = str.replaceAll(RegExp(r'\D'), '');
    RegExp exp = RegExp(r'^(1|)?(\d{3})(\d{3})(\d{4})$');
    Iterable<RegExpMatch> matches = exp.allMatches(cleaned);
    if (matches.isNotEmpty) {
      RegExpMatch match = matches.first;
      String intlCode = match.group(1) != null ? "+1 " : "";
      return "$intlCode(${match.group(2)}) ${match.group(3)}-${match.group(4)}";
    }
    return str;
  }

  static String getTimeAgo(String oldTimeStr) {
    final oldTime = DateTime.parse(oldTimeStr).millisecondsSinceEpoch;
    final time = DateTime.now().millisecondsSinceEpoch;
    final different = (time - oldTime) / 1000;
    final month = (different / (3600 * 24 * 30)).floor();
    final days = ((different / (3600 * 24)) % 30).floor();
    final hours = ((different / 3600) % 24).floor();
    final mins = ((different / 60) % 60).floor();

    if (month == 1) return '1 month ago';
    if (month > 1) return '$month months ago';
    if (days == 1) return '1 day ago';
    if (days > 1) return '$days days ago';
    if (hours == 1) return '1 hour ago';
    if (hours > 1) return '$hours hours ago';
    if (mins == 1) return '1 min ago';
    if (mins > 1) return '$mins mins ago';
    return 'less than 1 min ago';
  }

  static String printDouble(dynamic n) {
    var s = double.parse('$n');
    if (s.truncateToDouble() == s) {
      return s.toStringAsFixed(0);
    } else {
      s = double.parse(s.toStringAsFixed(s.truncateToDouble() == s ? 0 : 2));
    }
    return "$s";
  }

  static bool isNumeric(String str) {
    final numericRegex = RegExp(r'^\d+$');
    return numericRegex.hasMatch(str);
  }
}

class AvailableFonts {
  static const primaryFont = "Quicksand";
}

class AppColors {
  // static const main = Color.fromRGBO(71, 37, 131, 1);
  static const main = Color.fromARGB(255, 242, 242, 244);
  static const highlight = Color.fromRGBO(17, 6, 137, 1);
  static const dark = Color.fromRGBO(17, 6, 137, 1);

  static const Color primaryColor = Color.fromARGB(255, 239, 238, 241);

  static const Color secondaryColor = Color.fromRGBO(17, 6, 137, 1);
}

class AppImages {
  static const emptyState = {
    'assetImage': AssetImage('assets/images/empty.png'),
    'assetPath': 'assets/images/empty.png',
  };
  static const intro1 = AssetImage('assets/images/img_intro1.png');
  static const intro2 = AssetImage('assets/images/img_intro2.png');
  static const intro3 = AssetImage('assets/images/img_intro3.png');
  static const intro4 = AssetImage('assets/images/img_intro4.png');
  static const intro5 = AssetImage('assets/images/img_intro5.png');

  static const homePage = AssetImage('assets/images/home_page.png');
  static const appLogo = AssetImage('assets/images/logo.png');
  static const appLogoBanner = AssetImage('assets/images/logo_banner.png');
}

///App level custom dialog
class AppDialog {
  /// show dialog: params : [context], [title], [message], optional [ok]
  static Future<void> show(BuildContext context, String title, String message,
      {String ok = "OK"}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
