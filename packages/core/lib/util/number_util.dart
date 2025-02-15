// Package imports:
import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';

// ignore: avoid_classes_with_only_static_members
class NumberUtil {
  static const int maxDecimalDigits = 6; // Max digits after decimal

  /// Convert raw to ban and return as BigDecimal
  ///
  /// @param raw 100000000000000000000000000000
  /// @return Decimal value 1.000000000000000000000000000000
  ///
  static Decimal getRawAsUsableDecimal(String raw) {
    final Decimal amount = Decimal.parse(raw.toString());
    return amount;
  }

  /// Return raw as a normal amount.
  ///
  /// @param raw 100000000000000000000000000000
  /// @returns 1
  ///
  static String getRawAsUsableString(String raw) {
    final NumberFormat nf = NumberFormat.currency(
        locale: 'en_US', decimalDigits: maxDecimalDigits, symbol: '');
    String asString = nf.format(
        double.tryParse(getRawAsUsableDecimal(raw).truncate().toString()));
    final List<String> split = asString.split('.');
    if (split.length > 1) {
      // Remove trailing 0s from this
      if (int.parse(split[1]) == 0) {
        asString = split[0];
      } else {
        String newStr = split[0] + '.';
        String digits = split[1];
        int endIndex = digits.length;
        for (int i = 1; i <= digits.length; i++) {
          if (int.parse(digits[digits.length - i]) == 0) {
            endIndex--;
          } else {
            break;
          }
        }
        digits = digits.substring(0, endIndex);
        newStr = split[0] + '.' + digits;
        asString = newStr;
      }
    }
    return asString;
  }

  /// Sanitize a number as something that can actually
  /// be parsed. Expects "." to be decimal separator
  /// @param amount $1,512
  /// @returns 1.512
  static String sanitizeNumber(String input,
      {int maxDecimalDigits = maxDecimalDigits}) {
    String sanitized = '';
    final List<String> splitStr = input.split('.');
    if (splitStr.length > 1) {
      if (splitStr[1].length > maxDecimalDigits) {
        splitStr[1] = splitStr[1].substring(0, maxDecimalDigits);
        input = splitStr[0] + '.' + splitStr[1];
      }
    }
    for (int i = 0; i < input.length; i++) {
      try {
        if (input[i] == '.') {
          sanitized = sanitized + input[i];
        } else {
          int.parse(input[i]);
          sanitized = sanitized + input[i];
        }
      } catch (e) {}
    }
    return sanitized;
  }
}
