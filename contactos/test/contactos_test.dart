/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 26 November 2025
 */

import 'package:flutter_test/flutter_test.dart';

import 'src//contactos_legacy_test.dart' as contactos_legacy_test;
import 'src/contactos_test.dart' as contactos_test;

void main() => group('ContactosPlugin -', () {
      contactos_legacy_test.main();
      contactos_test.main();
    });
