import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:myapp/main.dart';

class EventDetailPage extends HookConsumerWidget {
  const EventDetailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focusNode = FocusNode();
    final selectedEventId = ref.watch(selectedEventIdProvider);
    final selectedDoc = FirebaseFirestore.instance.collection("Events").doc(selectedEventId);
    final eventTitle = useState("");
    final eventAllDay = useState(bool);
    final eventCB = useState(bool);
    final eventSDT = useState(DateTime);
    final eventFDT = useState(DateTime);
    final eventMemo = useState("");

    selectedDoc.get().then(
      (DocumentSnapshot doc) {
        final detailMap = doc.data as Map<String, dynamic>;
        eventTitle.value = detailMap['title'];
        eventAllDay.value = detailMap['allDay'];
        eventCB.value = detailMap['createdBy'];
        eventSDT.value = detailMap['startDateTime'];
        eventFDT.value = detailMap['finishDateTime'];
        eventMemo.value = detailMap['memo'];
      },
    );
  
    return Focus(
      focusNode: focusNode,
      child: GestureDetector(
        onTap: focusNode.requestFocus,
        child: Card(
          margin: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          color: Theme.of(context).colorScheme.background,
          shadowColor: Theme.of(context).colorScheme.primary,
          elevation: 8,  //影の幅
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: <Widget> [
              TextField(
                decoration: InputDecoration(
                  labelText: "タイトル",
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.surface)
                  )
                ),
                controller: TextEditingController(text: eventTitle.value)
              ),
            ]
          ),
        )
      )
    );
  }
}