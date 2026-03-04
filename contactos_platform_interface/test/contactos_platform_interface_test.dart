/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 26 November 2025
 */

import 'package:flutter_test/flutter_test.dart';

import 'src/contactos_platform_interface_test.dart'
    as contactos_platform_interface_test;
import 'src/method_channel_contactos_test.dart'
    as method_channel_contactos_test;
import 'src/types_test.dart' as types_test;

void main() => group('Unit_tests -', () {
      contactos_platform_interface_test.main();
      method_channel_contactos_test.main();
      types_test.main();
    });
