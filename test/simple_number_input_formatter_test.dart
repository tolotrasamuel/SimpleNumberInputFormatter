import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_number_input_formatter/simple_number_input_formatter.dart';

void main() {
  test('adds one to input values', () {
    expect(
      SimpleNumberInputFormatter(showTrailingZeroDecimal: false)
          .formatString(".", true),
      ".",
    );
    expect(
      SimpleNumberInputFormatter(showTrailingZeroDecimal: false)
          .formatString(".", false),
      "0",
    );
    expect(
      SimpleNumberInputFormatter(showTrailingZeroDecimal: true)
          .formatString(".", false),
      "0.00",
    );
    expect(
      SimpleNumberInputFormatter(showTrailingZeroDecimal: false)
          .formatString("55", true),
      "55",
    );
    expect(
      SimpleNumberInputFormatter(showTrailingZeroDecimal: false)
          .formatString("55.", true),
      "55.",
    );
    expect(
      SimpleNumberInputFormatter(showTrailingZeroDecimal: false)
          .formatString("55.", false),
      "55",
    );
    expect(
      SimpleNumberInputFormatter(showTrailingZeroDecimal: false)
          .applyMask(005481.123),
      "5 481.12",
    );
    expect(
      SimpleNumberInputFormatter(
              showTrailingZeroDecimal: false, decimalPlace: 1)
          .applyMask(005481.123),
      "5 481.1",
    );

    expect(
      SimpleNumberInputFormatter(showTrailingZeroDecimal: false)
          .applyMask(005481.1),
      "5 481.1",
    );

    final calculator = SimpleNumberInputFormatter();
    expect(calculator.applyMask(5481.487024305671), "5 481.48");
    expect(calculator.applyMask(005481.487024305671), "5 481.48");
    expect(
      SimpleNumberInputFormatter(showTrailingZeroDecimal: true)
          .applyMask(005481.00),
      "5 481.00",
    );
    expect(
      SimpleNumberInputFormatter(showTrailingZeroDecimal: false)
          .applyMask(005481.00),
      "5 481",
    );
    expect(
      SimpleNumberInputFormatter(showTrailingZeroDecimal: true)
          .applyMask(005481.1),
      "5 481.10",
    );
  });

  test("Format selection delete value", () {
    final oldValue = TextEditingValue(
      text: "2 999 999",
      selection: TextSelection.collapsed(
        offset: 1,
      ),
    );

    final newValue = TextEditingValue(
      text: "2. 999 999",
      selection: TextSelection.collapsed(
        offset: 2,
      ),
    );
    final result =
        SimpleNumberInputFormatter().formatEditUpdate(oldValue, newValue);
    expect(result.text, "2.99");
    expect(result.selection.baseOffset, 2);
  });

  test("Format selection first section", () {
    final oldValue = TextEditingValue(
      text: "123",
      selection: TextSelection.collapsed(
        offset: 3,
      ),
    );

    final newValue = TextEditingValue(
      text: "1234",
      selection: TextSelection.collapsed(
        offset: 4,
      ),
    );
    final result =
        SimpleNumberInputFormatter().formatEditUpdate(oldValue, newValue);
    expect(result.text, "1 234");
    expect(result.selection.baseOffset, 5);
  });

  test("Format selection second section", () {
    final oldValue = TextEditingValue(
      text: "123 456",
      selection: TextSelection.collapsed(
        offset: 7,
      ),
    );

    final newValue = TextEditingValue(
      text: "123 4567",
      selection: TextSelection.collapsed(
        offset: 8,
      ),
    );
    final result =
        SimpleNumberInputFormatter().formatEditUpdate(oldValue, newValue);
    expect(result.text, "1 234 567");
    expect(result.selection.baseOffset, 9);
  });
  test("Delete a separator should delete the Text triple Zero", () {
    final oldValue = TextEditingValue(
      text: "1 000",
      selection: TextSelection.collapsed(
        offset: 2,
      ),
    );

    final newValue = TextEditingValue(
      text: "1000",
      selection: TextSelection.collapsed(
        offset: 1,
      ),
    );
    final result =
        SimpleNumberInputFormatter().formatEditUpdate(oldValue, newValue);
    expect(result.text, "000");
    expect(result.selection.baseOffset, 0);
  });

  test("Delete a first char should leave cursor at zero", () {
    final oldValue = TextEditingValue(
      text: "1 000",
      selection: TextSelection.collapsed(
        offset: 1,
      ),
    );

    final newValue = TextEditingValue(
      text: "000",
      selection: TextSelection.collapsed(
        offset: 0,
      ),
    );
    final result =
        SimpleNumberInputFormatter().formatEditUpdate(oldValue, newValue);
    expect(result.text, "000");
    expect(result.selection.baseOffset, 0);
  });

  test("Delete a separator should delete the Text", () {
    final oldValue = TextEditingValue(
      text: "1 000 000",
      selection: TextSelection.collapsed(
        offset: 6,
      ),
    );

    final newValue = TextEditingValue(
      text: "1 000000",
      selection: TextSelection.collapsed(
        offset: 5,
      ),
    );
    final result =
        SimpleNumberInputFormatter().formatEditUpdate(oldValue, newValue);
    expect(result.text, "100 000");
    expect(result.selection.baseOffset, 4);
  });
}
