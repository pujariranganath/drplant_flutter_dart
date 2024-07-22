import 'package:dr_plant/history_screen.dart';
import 'package:dr_plant/home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'search_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dr.Plant',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          systemOverlayStyle:
              SystemUiOverlayStyle(statusBarColor: Colors.white),
          elevation: 0,
        ),
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      home: const MainPage(title: 'Dr.Plant'),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.title});

  final String title;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final CupertinoTabController _tabController =
      CupertinoTabController(initialIndex: 1);
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      controller: _tabController,
      tabBar: CupertinoTabBar(
        backgroundColor: Colors.white,
        activeColor: Colors.black,
        inactiveColor: Colors.black.withOpacity(0.5),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
        ],
        onTap: (index) {
          if (index == _tabController.index) {
            _navigatorKeys[index]
                .currentState
                ?.popUntil((route) => route.isFirst);
          }
        },
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(
          navigatorKey: _navigatorKeys[index],
          builder: (context) {
            switch (index) {
              case 0:
                return CupertinoPageScaffold(
                  navigationBar: CupertinoNavigationBar(
                    middle: Image.asset('assets/images/Dr.Plant_Title.png',
                        height: 30),
                    backgroundColor: Colors.white,
                    border: const Border(
                        bottom: BorderSide(color: Colors.transparent)),
                  ),
                  child: const SearchScreen(),
                );
              case 1:
                return CupertinoPageScaffold(
                  navigationBar: CupertinoNavigationBar(
                    middle: Image.asset('assets/images/Dr.Plant_Title.png',
                        height: 30),
                    backgroundColor: Colors.white,
                    border: const Border(
                        bottom: BorderSide(color: Colors.transparent)),
                  ),
                  child: const HomeScreen(),
                );
              case 2:
                return CupertinoPageScaffold(
                  navigationBar: CupertinoNavigationBar(
                    middle: Image.asset('assets/images/Dr.Plant_Title.png',
                        height: 30),
                    backgroundColor: Colors.white,
                    border: const Border(
                        bottom: BorderSide(color: Colors.transparent)),
                  ),
                  child: const HistoryScreen(),
                );
              default:
                return const CupertinoTabView();
            }
          },
        );
      },
    );
  }
}
