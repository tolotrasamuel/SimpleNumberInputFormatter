library simple_number_input_formatter;

import 'package:flutter/services.dart';

String get logTrace =>
    '[EVENT] ' +
    StackTrace.current.toString().split("\n").toList()[1].split("      ").last;

class SimpleNumberInputFormatter extends TextInputFormatter {
  SimpleNumberInputFormatter({
    this.decimalPlace = 2,
    this.separator = " ",
    this.decimalSeparator = ".",
    this.showTrailingZeroDecimal = false,
  });

  final int decimalPlace;
  final String separator;
  final String decimalSeparator;
  final bool showTrailingZeroDecimal;

  ///
  /// Parse the masked String value back to double
  /// For example if sep = " " and decSep = ","
  /// - "5 900,56" becomes 5900.56
  /// - "5 900.56" becomes null
  /// - "5,900.56" becomes null
  /// - "asdf560.345" becomes null
  double? parse(String currentValue) {
    String numStr = currentValue
        .replaceAll(separator, '')
        .replaceAll(decimalSeparator, '.');
    return double.tryParse(numStr);
  }

  @Deprecated("Use [formatDouble] instead")

  ///  Take double for formatting
  String? applyMask(double number) {
    return NumberFormatter(this, false).formatDouble(number);
  }

  ///  Take double for formatting
  String? formatDouble(double number) {
    return NumberFormatter(this, false).formatDouble(number);
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    print('$logTrace formatEditUpdate');

    if (newValue.text.length == 0) {
      return newValue.copyWith(text: '');
    } else if (oldValue == newValue) {
      print('$logTrace new value equal old value');
      return oldValue;
    } else if (newValue.text.compareTo(oldValue.text) == 0) {
      return newValue;
    }
    final newValueText = _getNewValueText(oldValue, newValue);

    final newString = NumberFormatter(this, true).formatString(newValueText);
    if (newString == null) {
      return oldValue;
    }

    final commasAfterChange = separator.allMatches(newString).length;
    final commasBeforeChange = separator.allMatches(oldValue.text).length;
    final twoPartsFromNew = newValue.text.split(decimalSeparator);
    int commasAfterDecimalSeparatorInNew = 0;
    if (twoPartsFromNew.length == 2) {
      commasAfterDecimalSeparatorInNew =
          separator.allMatches(twoPartsFromNew[1]).length;
    }
    int offset = newValue.selection.end +
        commasAfterChange -
        commasBeforeChange +
        commasAfterDecimalSeparatorInNew;

    // handling edge case 0. from . only input
    if (newString == "0$decimalSeparator") {
      offset = newString.length;
    }
    if (newString == oldValue.text) {
      offset = oldValue.selection.baseOffset;
    }
    if (newValue.selection.end == 0) {
      offset = 0;
    }
    print("$logTrace offset $offset $newString");
    return TextEditingValue(
      text: newString,
      selection: TextSelection.collapsed(
        offset: offset,
      ),
    );
  }

  String? formatString(String s, [bool editMode = false]) {
    final newString = NumberFormatter(this, editMode).formatString(s);
    return newString;
  }

  String _getNewValueText(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (oldValue.text.length < newValue.text.length) return newValue.text;
    if (oldValue.selection.end == 0) return newValue.text;
    final previousCharOld = oldValue.text[oldValue.selection.end - 1];
    if (previousCharOld != separator) return newValue.text;
    return replaceCharAt(newValue.text, newValue.selection.end - 1, "");
  }

  String replaceCharAt(String oldString, int index, String newChar) {
    return oldString.substring(0, index) +
        newChar +
        oldString.substring(index + 1);
  }
}

class NumberFormatter {
  final SimpleNumberInputFormatter simpleNumberInputFormatter;
  final bool editMode;

  String get separator => simpleNumberInputFormatter.separator;

  String get decimalSeparator => simpleNumberInputFormatter.decimalSeparator;

  bool get showTrailingZeroDecimal =>
      simpleNumberInputFormatter.showTrailingZeroDecimal;

  int get decimalPlace => simpleNumberInputFormatter.decimalPlace;

  NumberFormatter(this.simpleNumberInputFormatter, this.editMode);

  static List<String> nums = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"];

  /// When this returns null, it means that nothing has changed
  String? formatString(String newValueText) {
    if (separator == decimalSeparator) {
      print("separator cannot be same decimalSeparator");
      return null;
    }
    if (!_isValidInput(newValueText)) return null;

    List<String> twoParts =
        newValueText.replaceAll(separator, '').split(decimalSeparator);
    return _applyMask(twoParts);
  }

  String _getInterger(String input) {
    List<String> integerChars = input.split('');

    // Removing leading zeros
    // This code works however, when user changes form 2,000 to 1,000
    // by deleting the 2, the 000 will be removed
    // because they are considered as leading zeros and it will be 10
    if (integerChars.length > 1) {
//        integerChars = _removeLeadingZeros(_integerChars);
    }

    if (integerChars.length == 0 && !editMode) {
      integerChars = ["0"];
    }
    print("$logTrace allChars $input integerCharss $integerChars");
    String newString = '';
    print("$logTrace $integerChars");
    for (int i = integerChars.length - 1; i >= 0; i--) {
      if ((integerChars.length - 1 - i) % 3 == 0 &&
          i < integerChars.length - 1 &&
          integerChars.length > 3) newString = separator + newString;
      newString = integerChars[i] + newString;
    }

    return newString;
  }

  List<String> _fillOrRemoveTrailingZero(List<String> decimalChars, int place) {
    List<String> result = [];
    for (int i = 0; i < place; i++) {
      if (i < decimalChars.length) {
        result.add(decimalChars[i]);
        continue;
      }
      if (!showTrailingZeroDecimal) continue;
      result.add("0");
      continue;
    }
    return result;
  }

  String _getDecimal(String s) {
    List<String> decimalChars = [];
    decimalChars = s.split('');
    decimalChars = _fillOrRemoveTrailingZero(decimalChars, decimalPlace);
    if (decimalChars.isEmpty) return "";
    return decimalSeparator + decimalChars.join("");
  }

  /// Take String partially formatted with
  /// decimal and thousand separator
  /// strictly equal to the library setup,
  /// this will output undefined behaviour
  String? _applyMask(List<String> twoParts) {
    if (twoParts.length > 2) {
      return null;
    }

    final _integer = _getInterger(twoParts[0]);
    final _decimal = _getDecimal(twoParts.length == 2 ? twoParts[1] : "");
    if (_decimal.isEmpty && editMode && twoParts.length == 2) {
      return _integer + decimalSeparator;
    }
    return _integer + _decimal;
  }

  bool _isValidInput(String stringTypedByUser) {
    if (decimalSeparator.allMatches(stringTypedByUser).length > 1) return false;
    final allowed = [separator, decimalSeparator, ...nums];
    for (final s in stringTypedByUser.split("")) {
      if (!allowed.contains(s)) return false;
    }
    return true;
  }

  List<String> _removeLeadingZeros(List<String> _integerChars) {
    for (int i = 0; i < _integerChars.length; i++) {
      String num = _integerChars[i];
      if (num != "0") {
        return _integerChars.sublist(i);
      } else {}
    }
    return [];
  }

  String? formatDouble(double number) {
    final newValueText = number.toString();
    List<String> twoParts = newValueText.split('.');
    if (twoParts.length > 1 && twoParts[1] == "0") {
      twoParts = [twoParts[0]];
    }
    return _applyMask(twoParts);
  }
}
