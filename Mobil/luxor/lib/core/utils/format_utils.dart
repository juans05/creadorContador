String formatCount(int n) {
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
  return '$n';
}

String? extractApiError(dynamic responseData) {
  if (responseData is Map) return responseData['message']?.toString();
  return null;
}
