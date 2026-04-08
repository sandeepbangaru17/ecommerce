String formatInr(num amount) {
  final isNegative = amount < 0;
  final absolute = amount.abs().toStringAsFixed(2).split('.');
  final whole = absolute[0];
  final decimal = absolute[1];
  final buffer = StringBuffer();

  if (whole.length > 3) {
    final prefix = whole.substring(0, whole.length - 3);
    final suffix = whole.substring(whole.length - 3);
    final groups = <String>[];
    for (var index = prefix.length; index > 0; index -= 2) {
      final start = (index - 2).clamp(0, prefix.length);
      groups.insert(0, prefix.substring(start, index));
    }
    buffer.write(groups.join(','));
    buffer.write(',');
    buffer.write(suffix);
  } else {
    buffer.write(whole);
  }

  final sign = isNegative ? '-' : '';
  if (decimal == '00') {
    return '$sign₹${buffer.toString()}';
  }
  return '$sign₹${buffer.toString()}.$decimal';
}

String shortOrderLabel(String orderId) {
  final value = orderId.length > 8 ? orderId.substring(0, 8) : orderId;
  return value.toUpperCase();
}
