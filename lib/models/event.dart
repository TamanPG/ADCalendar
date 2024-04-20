import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String title;
  final bool createdBy;
  final bool allDay;
  final DateTime date;
  final DateTime startDateTime;
  final DateTime finishDateTime;
  final String? memo;
  final String id;
  final String userId;  //ハッシュ値をコレクション名とする
  Event({
    required this.title,
    required this.createdBy,
    required this.allDay,
    required this.date,
    required this.startDateTime,
    required this.finishDateTime,
    this.memo,
    required this.id,
    required this.userId,
  });

  factory Event.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot,
      [SnapshotOptions? options]) {
    final data = snapshot.data()!;
    return Event(
      title: data['title'],
      createdBy: data['createdBy'],
      allDay: data['allDay'],
      date: data['data'].toDate(),
      startDateTime: data['startDateTime'].toDate(),
      finishDateTime: data['finishDateTime'].toDate(),
      memo: data['memo'],
      id: snapshot.id,  //docのスナップショットをsnapshotと定義=これでdocのidを取得可能
      userId: data['userId'],
    );
  }

  Map<String, Object?> toFirestore() {
    return {
      "title": title,
      "createdBy": createdBy,
      "allDay": allDay,
      "date": date,
      "startDateTime": Timestamp.fromDate(startDateTime),
      "finishDateTime": Timestamp.fromDate(finishDateTime),
      "memo": memo,
      "userId": userId,
    };
  }
}