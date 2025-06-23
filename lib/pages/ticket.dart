class Ticket {
  final String type;
  final String line;
  late DateTime expiresAt;
  bool isExpired = false;

  Ticket({
    required this.type,
    required this.line,
    required int remainingSeconds,
  }) {
    expiresAt = DateTime.now().add(Duration(seconds: remainingSeconds));
  }

  int get remainingSeconds {
    final diff = expiresAt.difference(DateTime.now()).inSeconds;
    return diff > 0 ? diff : 0;
  }

  void checkIfExpired() {
    if (!isExpired && DateTime.now().isAfter(expiresAt)) {
      isExpired = true;
    }
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'line': line,
    'expiresAt': expiresAt.toIso8601String(),
    'isExpired': isExpired,
  };

  static Ticket fromJson(Map<String, dynamic> json) {
    final ticket = Ticket(
      type: json['type'] ?? 'Unknown',
      line: json['line'] ?? 'Unknown',
      remainingSeconds: 0,
    );

    if (json['expiresAt'] != null && json['expiresAt'] is String) {
      ticket.expiresAt = DateTime.parse(json['expiresAt']);
    } else {
      ticket.expiresAt = DateTime.now();
    }

    ticket.isExpired = json['isExpired'] ?? false;
    ticket.checkIfExpired();
    return ticket;
  }
}
