import 'package:intl/intl.dart';

class FormatHelper {
  static String money(double amount) {
    final f = NumberFormat('#,###', 'vi_VN');
    return '${f.format(amount).replaceAll(',', '.')}đ';
  }

  static String date(DateTime d) => DateFormat('dd/MM/yyyy').format(d);
}
