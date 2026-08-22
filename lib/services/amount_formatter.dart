// lib/services/amount_formatter.dart

class AmountFormatter {
  /// Formate un montant en devise, ex: 185529.98 -> "185 529,98"
  static String format(double amount) {
    final String fixed = amount.toStringAsFixed(2);
    final parts = fixed.split('.');
    final String wholePart = parts[0];
    final String decimalPart = parts[1];

    final buffer = StringBuffer();
    for (int i = 0; i < wholePart.length; i++) {
      if (i != 0 && (wholePart.length - i) % 3 == 0) {
        buffer.write(' ');
      }
      buffer.write(wholePart[i]);
    }

    return '${buffer.toString()},$decimalPart';
  }
}