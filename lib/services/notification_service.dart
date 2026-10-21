abstract interface class NotificationService {
  Future<void> scheduleHungerReminder(Duration delay);
  Future<void> cancelHungerReminder();
}
