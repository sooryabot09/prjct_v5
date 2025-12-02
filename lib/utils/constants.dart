class AppConstants {
  static const String appName = 'Church Management System';
  static const String appVersion = '1.0.0';
  
  // Date formats
  static const String dateFormat = 'dd MMM yyyy';
  static const String dateTimeFormat = 'dd MMM yyyy, hh:mm a';
  static const String timeFormat = 'hh:mm a';
  
  // Pagination
  static const int pageSize = 20;
  
  // Validation
  static const int minPasswordLength = 6;
  static const int minDescriptionLength = 10;
  static const int maxFileSize = 5 * 1024 * 1024; // 5MB
  
  // User Roles
  static const String roleParishioner = 'PARISHIONER';
  static const String rolePriest = 'PRIEST';
  static const String roleChurchAdmin = 'CHURCH_ADMIN';
  static const String roleDioceseAdmin = 'DIOCESE_ADMIN';
  static const String roleSuperAdmin = 'SUPER_ADMIN';
  
  // Booking Status
  static const String statusPending = 'PENDING';
  static const String statusPaid = 'PAID';
  static const String statusCancelled = 'CANCELLED';
  static const String statusCompleted = 'COMPLETED';
  
  // Payment Methods
  static const String paymentRazorpay = 'RAZORPAY';
  static const String paymentCash = 'CASH';
  static const String paymentGPay = 'GPAY';
  
  // Transaction Status
  static const String transactionPending = 'PENDING';
  static const String transactionCompleted = 'COMPLETED';
  static const String transactionFailed = 'FAILED';
  static const String transactionPendingReview = 'PENDING_REVIEW';
  
  // Complaint Status
  static const String complaintOpen = 'OPEN';
  static const String complaintInProgress = 'IN_PROGRESS';
  static const String complaintResolved = 'RESOLVED';
  static const String complaintClosed = 'CLOSED';
  
  // Event Visibility
  static const String visibilityPublic = 'PUBLIC';
  static const String visibilityPrivate = 'PRIVATE';
}