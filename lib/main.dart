import 'package:firebase_core/firebase_core.dart';  //認証実装後、ユーザーごとにコレクションを分ける
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';  //By using [Provider], this value is cached, making it performant.
import 'package:myapp/colors.dart';
import 'package:myapp/models/event.dart';  //イベントモデル
import 'package:myapp/view/signup_page.dart';
import 'package:myapp/view/help_page.dart';  //遷移先1
import 'package:myapp/view/settings.dart';  //遷移先2
import 'package:myapp/view/event_detail.dart';  //詳細ページ

final selectedEventIdProvider = StateProvider<String>((ref) => '');  //リバポに宣言、We use [StateProvider] here as there is no fancy logic behind manipulating

void main() async {
  WidgetsFlutterBinding.ensureInitialized();  //フレームワーク使う時の接着剤みたいなの
  await Firebase.initializeApp(  //firebase初期化
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const ProviderScope(  //riverpod用
      child: MyApp()
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AD Calendar',
      theme: lightTheme,
      home: StreamBuilder<User?> (
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox();
          }
          else if (snapshot.hasData) {
            return const CalendarPage();
          }
          else {
            return SignUpPage();
          }
        }
      )
    );
  }
}

class CalendarPage extends HookConsumerWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focusedDayState = useState(DateTime.now());  //hooks使った
    final selectedDayState = useState(DateTime.now());
    final firebaseEvents = FirebaseFirestore.instance.collection('Events');  //collectionからインスタンスを持ってくる
    final events = useState({});  //初期化
    final showEventDetail = useState(false);
    int selectedIndex = 0;

    Future loadFirebaseData(DateTime focusedDay) async {  //DateTime型の引数focusedDayを受け取る
      Map<DateTime, List<Event>> events = {};  //Map型の変数eventsを宣言
      
      final snap = await firebaseEvents.withConverter(
        fromFirestore: (event, _) => Event.fromFirestore(event),  //firestoreからのデータをEvent型に変換
        toFirestore: (Event event, _) => event.toFirestore()  //firestoreへのデータをEvent型に変換
      ).get();

      for (var doc in snap.docs) {  //さっきsnapに格納したデータを日付ごとに整理
        final event = doc.data();
        final eventDay = event.startDateTime;
        final date = DateTime.utc(eventDay.year, eventDay.month, eventDay.day);
        // イベントを日付ごとに整理する。dateキーを持っていない場合、その日のイベントリストは空代入
        if (!events.containsKey(date)) {
          events[date] = [];
        }
        //eventsのdateキーにその日のeventデータを代入
        events[date]!.add(event);
      }
      return events;  //日付ごとのマップデータ(hook用)
    }

    Future getEvent() async {  //予定を読み込んでいる
      final Map<DateTime, List<Event>> eventData = await loadFirebaseData(DateTime.now()); // Firebaseを呼んでいる関数
      events.value = eventData;
      return events.value;
    }

    useEffect((){  //useEffectに渡された関数はレンダーの結果が画面に反映された後に動作
      getEvent();
      return null;
    },const []);

    List getEventForDay(DateTime day) {
      return events.value[day] ?? [];  //"?? []"は、もしevents[day]=day日の予定がnullであれば、代わりに空のリストを返すという意味。ボトムバー用
    }

    void onItemTapped(int index) {
      switch (index) {
        case 0:
          selectedIndex = 0;
        break;
        case 1:
          selectedIndex = 1;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HelpPage()),
          );
        break;
        case 2:
          selectedIndex = 2;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingPage()),
          );
        break;
      }
    }

    void showBottomMenu(BuildContext context, DateTime? selectedDay) {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 360,
            color: Theme.of(context).colorScheme.background,
            child: ListView(
              children: getEventForDay(selectedDay!).map((events) => ListTile(
                title: Text(events.title),
                onTap: () {
                  ref.watch(selectedEventIdProvider.notifier).state = events.id;  //update the value
                  Navigator.of(context).pop();
                  showEventDetail.value = true;
                },
              )).toList(),
            )
          );
        }
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false, // キーボードが出てきても画面が崩れないようにする
      appBar: AppBar(
        title: Text(
          'Home',
          style: TextStyle(
            color: Theme.of(context).colorScheme.background,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children : <Widget>[
          TableCalendar(
            rowHeight: 100.0,
            firstDay: DateTime.utc(2010, 1, 1),
            lastDay: DateTime.utc(2030, 1, 1),
            focusedDay: DateTime.now(),
            headerStyle: const HeaderStyle (  //週・月表示の変更はしない
              formatButtonVisible: false
            ),
            eventLoader: (day) {
              return getEventForDay(day);
            },
            selectedDayPredicate: (day) {  //以下、日付選択処理
              return isSameDay(selectedDayState.value, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              selectedDayState.value = selectedDay;
              focusedDayState.value = focusedDay;
              showBottomMenu(context, selectedDay);
            },
            calendarBuilders: CalendarBuilders (
              defaultBuilder: (context, date, _) {
                final weekday = date.weekday;
                Color textColor = weekday == DateTime.saturday ? Colors.blue : (weekday == DateTime.sunday ? Colors.red : Theme.of(context).colorScheme.primary);

                return Container(
                  margin: EdgeInsets.zero,
                  padding: const EdgeInsets.all(2.0),
                  alignment: Alignment.topLeft,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    '${date.day}',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16.0,
                    ),
                  ),
                );
              },
              holidayBuilder: (context, date, _) {
                return Container(
                  margin: EdgeInsets.zero,
                  padding: const EdgeInsets.all(2.0),
                  alignment: Alignment.topLeft,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    '${date.day}',
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 16.0,
                    ),
                  ),
                );
              },
              todayBuilder: (context, date, _) {
                return Container(
                  margin: EdgeInsets.zero,
                  padding: const EdgeInsets.all(2.0),
                  alignment: Alignment.topLeft,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.secondary,
                      width: 1.0,
                    ),
                  ),
                  child: Text(
                    '${date.day}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
              selectedBuilder: (context, date, _) {
                return Container(
                  margin: EdgeInsets.zero,
                  padding: const EdgeInsets.all(2.0),
                  alignment: Alignment.topLeft,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.tertiary,
                      width: 4.0,
                    ),
                  ),
                  child: Text(
                    '${date.day}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.tertiary,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
          if(showEventDetail.value) const EventDetailPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const<BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.help),
            label: 'Help',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: onItemTapped,
      ),
    );
  }
}
