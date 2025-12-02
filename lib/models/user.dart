class User {
  final int userId;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final int? churchId;
  final String? churchName;
  final DateTime? birthday;
  final DateTime? ordinationDate;
  final DateTime? feastDate;
  final String? motto;
  final bool isActive;

  User({
    required this.userId,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.churchId,
    this.churchName,
    this.birthday,
    this.ordinationDate,
    this.feastDate,
    this.motto,
    this.isActive = true,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'] is int
          ? json['user_id']
          : int.parse(json['user_id'].toString()),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      role: json['role'] ?? 'PARISHIONER',
      churchId: json['church_id'],
      churchName: json['church_name'],
      birthday: json['birthday'] != null
          ? DateTime.parse(json['birthday'])
          : null,
      ordinationDate: json['ordination_date'] != null
          ? DateTime.parse(json['ordination_date'])
          : null,
      feastDate: json['feast_date'] != null
          ? DateTime.parse(json['feast_date'])
          : null,
      motto: json['motto'],
      // Handle MySQL TINYINT(1) which returns 0 or 1 instead of true/false
      isActive: json['is_active'] == 1 || json['is_active'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'church_id': churchId,
      'church_name': churchName,
      'birthday': birthday?.toIso8601String(),
      'ordination_date': ordinationDate?.toIso8601String(),
      'feast_date': feastDate?.toIso8601String(),
      'motto': motto,
      'is_active': isActive,
    };
  }
}

class Church {
  final int churchId;
  final String name;
  final String? address;
  final String? phone;
  final String? bankAccount;
  final String? qrCodeUrl;
  final String? foraneName;
  final String? dioceseName;

  Church({
    required this.churchId,
    required this.name,
    this.address,
    this.phone,
    this.bankAccount,
    this.qrCodeUrl,
    this.foraneName,
    this.dioceseName,
  });

  factory Church.fromJson(Map<String, dynamic> json) {
    return Church(
      churchId: json['church_id'] is int
          ? json['church_id']
          : int.parse(json['church_id'].toString()),
      name: json['name'] ?? '',
      address: json['address'],
      phone: json['phone'],
      bankAccount: json['bank_account'],
      qrCodeUrl: json['qr_code_url'],
      foraneName: json['forane_name'],
      dioceseName: json['diocese_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'church_id': churchId,
      'name': name,
      'address': address,
      'phone': phone,
      'bank_account': bankAccount,
      'qr_code_url': qrCodeUrl,
      'forane_name': foraneName,
      'diocese_name': dioceseName,
    };
  }
}

class Service {
  final int serviceId;
  final String name;
  final String? description;
  final double amountRupees;
  final int churchId;
  final List<SplitConfig>? splits;

  Service({
    required this.serviceId,
    required this.name,
    this.description,
    required this.amountRupees,
    required this.churchId,
    this.splits,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      serviceId: json['service_id'] is int
          ? json['service_id']
          : int.parse(json['service_id'].toString()),
      name: json['name'] ?? '',
      description: json['description'],
      amountRupees: (json['amount_rupees'] ?? 0).toDouble(),
      churchId: json['church_id'] is int
          ? json['church_id']
          : int.parse(json['church_id'].toString()),
      splits: json['splits'] != null
          ? (json['splits'] as List)
                .map((s) => SplitConfig.fromJson(s))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'service_id': serviceId,
      'name': name,
      'description': description,
      'amount_rupees': amountRupees,
      'church_id': churchId,
      'splits': splits?.map((s) => s.toJson()).toList(),
    };
  }
}

class SplitConfig {
  final String beneficiaryType;
  final int percentage;

  SplitConfig({required this.beneficiaryType, required this.percentage});

  factory SplitConfig.fromJson(Map<String, dynamic> json) {
    return SplitConfig(
      beneficiaryType: json['beneficiary'] ?? json['beneficiary_type'] ?? '',
      percentage: json['percentage'] is int
          ? json['percentage']
          : int.parse(json['percentage'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {'beneficiary_type': beneficiaryType, 'percentage': percentage};
  }
}

class Booking {
  final int bookingId;
  final String parishioner;
  final String service;
  final String church;
  final String? priest;
  final double amountRupees;
  final String status;
  final DateTime createdAt;

  Booking({
    required this.bookingId,
    required this.parishioner,
    required this.service,
    required this.church,
    this.priest,
    required this.amountRupees,
    required this.status,
    required this.createdAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      bookingId: json['booking_id'] is int
          ? json['booking_id']
          : int.parse(json['booking_id'].toString()),
      parishioner: json['parishioner'] ?? '',
      service: json['service'] ?? '',
      church: json['church'] ?? '',
      priest: json['priest'],
      amountRupees: (json['amount_rupees'] ?? 0).toDouble(),
      status: json['status'] ?? 'PENDING',
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'booking_id': bookingId,
      'parishioner': parishioner,
      'service': service,
      'church': church,
      'priest': priest,
      'amount_rupees': amountRupees,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class Event {
  final int eventId;
  final String? title;
  final String? description;
  final DateTime startTime;
  final DateTime endTime;
  final String visibility;
  final bool isBusy;

  Event({
    required this.eventId,
    this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    required this.visibility,
    this.isBusy = false,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      eventId: json['event_id'] is int
          ? json['event_id']
          : int.parse(json['event_id'].toString()),
      title: json['title'],
      description: json['description'],
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      visibility: json['visibility'] ?? 'PUBLIC',
      isBusy: json['is_busy'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event_id': eventId,
      'title': title,
      'description': description,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'visibility': visibility,
      'is_busy': isBusy,
    };
  }
}

class Complaint {
  final int complaintId;
  final String complainant;
  final String title;
  final String body;
  final String status;
  final DateTime createdAt;

  Complaint({
    required this.complaintId,
    required this.complainant,
    required this.title,
    required this.body,
    required this.status,
    required this.createdAt,
  });

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      complaintId: json['complaint_id'] is int
          ? json['complaint_id']
          : int.parse(json['complaint_id'].toString()),
      complainant: json['complainant'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      status: json['status'] ?? 'OPEN',
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'complaint_id': complaintId,
      'complainant': complainant,
      'title': title,
      'body': body,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class Transaction {
  final int transactionId;
  final double amountRupees;
  final String method;
  final String status;
  final DateTime createdAt;
  final String? parishioner;
  final String? service;

  Transaction({
    required this.transactionId,
    required this.amountRupees,
    required this.method,
    required this.status,
    required this.createdAt,
    this.parishioner,
    this.service,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      transactionId: json['transaction_id'] is int
          ? json['transaction_id']
          : int.parse(json['transaction_id'].toString()),
      amountRupees: (json['amount_rupees'] ?? json['amount'] ?? 0).toDouble(),
      method: json['method'] ?? 'CASH',
      status: json['status'] ?? 'PENDING',
      createdAt: DateTime.parse(
        json['created_at'] ?? json['date'] ?? DateTime.now().toIso8601String(),
      ),
      parishioner: json['parishioner'],
      service: json['service'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_id': transactionId,
      'amount_rupees': amountRupees,
      'method': method,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'parishioner': parishioner,
      'service': service,
    };
  }
}

class Diocese {
  final int dioceseId;
  final String name;
  final String? code;

  Diocese({required this.dioceseId, required this.name, this.code});

  factory Diocese.fromJson(Map<String, dynamic> json) {
    return Diocese(
      dioceseId: json['diocese_id'] is int
          ? json['diocese_id']
          : int.parse(json['diocese_id'].toString()),
      name: json['name'] ?? '',
      code: json['code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'diocese_id': dioceseId, 'name': name, 'code': code};
  }
}

class Forane {
  final int foraneId;
  final int dioceseId;
  final String name;
  final String? dioceseName;

  Forane({
    required this.foraneId,
    required this.dioceseId,
    required this.name,
    this.dioceseName,
  });

  factory Forane.fromJson(Map<String, dynamic> json) {
    return Forane(
      foraneId: json['forane_id'] is int
          ? json['forane_id']
          : int.parse(json['forane_id'].toString()),
      dioceseId: json['diocese_id'] is int
          ? json['diocese_id']
          : int.parse(json['diocese_id'].toString()),
      name: json['name'] ?? '',
      dioceseName: json['diocese_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'forane_id': foraneId,
      'diocese_id': dioceseId,
      'name': name,
      'diocese_name': dioceseName,
    };
  }
}

class Notification {
  final int notificationId;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final String type;

  Notification({
    required this.notificationId,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
    this.type = 'general',
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      notificationId: json['notification_id'] is int
          ? json['notification_id']
          : int.parse(json['notification_id'].toString()),
      title: json['title'] ?? '',
      message: json['message'] ?? json['body'] ?? '',
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      isRead: json['is_read'] ?? json['read'] ?? false,
      type: json['type'] ?? 'general',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notification_id': notificationId,
      'title': title,
      'message': message,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
      'type': type,
    };
  }
}
