extension DateTimeExtensions on DateTime {
  bool isToday() {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool isFuture() {
    final now = DateTime.now();
    return isAfter(now);
  }
}
