import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:first_project/foundation/color.dart';
import 'package:first_project/widgets/call_to_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../Models/members.dart';
import '../Models/workers.dart';
import '../Provider/attendance_provider.dart';
import '../Provider/auth_provider.dart';
import '../screens/all_tabs.dart';
import '../screens/members_tab.dart';
import '../screens/workers_tab.dart';
import '../widgets/member_form_widget.dart';
import '../widgets/worker_form_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<AttendanceProvider>(context, listen: false).fetchData();
    print('object');
  }

  @override
  Widget build(BuildContext context) {
    final color = MyColor();
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: StreamBuilder<User?>(stream: FirebaseAuth.instance.authStateChanges(), builder: (context,snapshot){
            if (snapshot.connectionState == ConnectionState.waiting){
              return CircularProgressIndicator();
            } if (!snapshot.hasData || snapshot.data == null) {
              return Text("No user logged in");
            }
            final authProvider = Provider.of<AuthsProvider>(context);
            final user = authProvider.user;
            return Text('${user?.displayName ?? 'User'} attendance' );
          }),
          bottom: TabBar(
            indicatorColor: color.mainColor,
            labelColor: color.mainColor,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorWeight: 5,
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Workers'),
              Tab(text: 'Members'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AllTab(),
            WorkersTab(),
            MembersTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          foregroundColor: Colors.white,
          backgroundColor: color.mainColor,
          onPressed: () => _showAddDialog(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final color = MyColor();
    showModalBottomSheet(
      context: context,
      builder: (_) => SizedBox(
        height: 200,
        child: Column(
          children: [
            ListTile(
              title: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    'Add Workers',
                    style: TextStyle(
                        color: color.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                ),
              ),
              onTap: () {
                showAddWorkerForm(context);
              },
            ),
            ListTile(
              title: Center(
                child: Text(
                  'Add Members',
                  style: TextStyle(
                      color: color.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              ),
              onTap: () {
                showAddMemberForm(context);

              },
            ),
          ],
        ),
      ),
    );
  }
}
