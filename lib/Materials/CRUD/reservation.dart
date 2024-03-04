import 'package:cloud_firestore/cloud_firestore.dart';

class Reservation {
  final String userName;
  final DateTime startDate;
  final DateTime endDate;
  final bool problems;
  final String materielId;
  final int surface;

  Reservation({
    required this.userName,
    required this.startDate,
    required this.endDate,
    required this.problems,
    required this.materielId,
    required this.surface,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      userName: json['userName'],
      startDate: (json['startDate'] as Timestamp).toDate(),
      endDate: (json['endDate'] as Timestamp).toDate(),
      problems: json['problems'],
      materielId: json['materielId'],
      surface: json['surface'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'problems': problems,
      'materielId': materielId,
      'surface': surface,
    };
  }
}
