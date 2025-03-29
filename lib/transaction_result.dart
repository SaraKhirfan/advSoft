class TransactionResult {
  final bool success;
  final bool showAlert;
  final String? alertMessage;
  final String categoryName;

  TransactionResult({
    required this.success,
    this.showAlert = false,
    this.alertMessage,
    this.categoryName = '',
  });
}