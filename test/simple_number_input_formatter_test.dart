import 'package:flutter_test/flutter_test.dart';
import 'package:simple_number_input_formatter/simple_number_input_formatter.dart';

void main() {
  test('adds one to input values', () {
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
}
