
// ignore_for_file: use_build_context_synchronously

import 'dart:math';

import 'package:aquila_hundi/app/helper_widgets/appbar.dart';
import 'package:aquila_hundi/app/helper_widgets/bottom_navigation.dart';
import 'package:aquila_hundi/app/helper_widgets/config.dart';
import 'package:aquila_hundi/app/modules/Dashboard/dashboard_page.dart';
import 'package:aquila_hundi/store/app.state.dart';
import 'package:aquila_hundi/store/business/business.action.dart';
import 'package:aquila_hundi/store/dashboard/dashboard.action.dart';
import 'package:aquila_hundi/store/payments/payments.action.dart';
import 'package:aquila_hundi/store/payments/payments.reducer.dart';
import 'package:aquila_hundi/store/support/support.action.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:date_picker_plus/date_picker_plus.dart';
import 'package:intl/intl.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:image_picker/image_picker.dart';


class SupportPage extends StatefulWidget {
  const SupportPage({super.key});
  @override
  SupportPageState createState() => SupportPageState();
}

class SupportPageState extends State<SupportPage> {
 final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
 ScrollController scrollController = ScrollController();
  int screenIndex = 2;
  TextEditingController supportTitleController = TextEditingController();
  TextEditingController supportQueryController = TextEditingController();

 @override
 void initState() {
   super.initState();
  }

@override
void dispose() {
  scrollController.dispose();
  super.dispose();
}

 void openDrawer() {
    scaffoldKey.currentState!.openDrawer();
  }

  Future<void> onAddClickSupport() async{

    await Future.delayed(const Duration(milliseconds: 100));
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create Support Ticket'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: supportTitleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                ),
              ),
              TextField(
                controller: supportQueryController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Query',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (supportTitleController.text.isEmpty || supportQueryController.text.isEmpty) {
                  return;
                } else{
                Navigator.pop(context);
                StoreProvider.of<AppState>(context).dispatch(createSupport({
                  'Title': supportTitleController.text,
                  'Query': supportQueryController.text,
                }));
                loadingPopUp(context);
                }
                //StoreProvider.of<AppState>(context).dispatch(createSupportTicket(supportTitleController.text, supportQueryController.text));
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

    Future<void> loadingPopUp (BuildContext context) async {
    await Future.delayed(const Duration(milliseconds: 100));
    showDialog(
            context: context, 
            builder: (BuildContext context) {
              return StoreConnector<AppState, Store<AppState>>(
                converter: (store) => store,
                builder: (BuildContext context, store) {
                  final error = store.state.supportState.error;
                  final supportCreateLoading = store.state.supportState.supportCreateLoading;
                  final supportCreated = store.state.supportState.supportCreated;

        return 
        supportCreateLoading ?
        const AlertDialog(
          title: Text('Loading'),
          content: CircularProgressIndicator(),
        )  : supportCreated ?
        AlertDialog(
          title: const Text('Success'),
          content: const Text('Support Ticket Created Successfully'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                store.dispatch(SupportCreatedAction(supportCreated: false));
                store.dispatch(SupportCreateLoadingAction(supportCreateLoading: false));
                store.dispatch(SupportFailedAction(error: ''));
                supportTitleController.clear();
                supportQueryController.clear();
                store.dispatch(getSupportList());
                Navigator.of(context).pop();
              }, 
              child: const Text('OK')
            ),
          ],
        ) : error.isNotEmpty ?
        AlertDialog(
          title: const Text('Error'),
          content: Text(error),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                store.dispatch(SupportFailedAction(error: ''));
                Navigator.of(context).pop();
              }, 
              child: const Text('OK')
            ),
          ],
        )
        : const Center();
        
      }
    );
      }
    );
  } 
        








  @override
  Widget build(BuildContext context) {
     if (StoreProvider.of<AppState>(context).state.dashboardState.customerCurrentScreen == 'Buyer') {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor:  Color.fromARGB(255, 47, 14, 138),
      statusBarIconBrightness: Brightness.light,
    ));
    } else {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.orange,
        statusBarIconBrightness: Brightness.dark,
      ));
    }
    return StoreConnector<AppState, Store<AppState>>(
      converter: (store) => store,
      builder: (BuildContext context, store) {
        final customerCurrentScreen = store.state.dashboardState.customerCurrentScreen;
        final customerData = store.state.authState.customerData;
        final supportList = store.state.supportState.supportList;
        final supportListLoaded = store.state.supportState.supportListLoaded;
        final loading = store.state.supportState.loading;


        if (supportListLoaded == false && supportList.isEmpty) {
          store.dispatch(UpdateSupportListLoaded(supportListLoaded: true));
          store.dispatch(getSupportList());
        }

        return Scaffold(
          key: scaffoldKey,
          appBar: PreferredSize(
            preferredSize:  BoxConstraints.tightFor(height: AppConfig.size(context, 45)).smallest,
            child: WidgetHelper.getAppBar(context, 'Support', openDrawer, customerCurrentScreen == 'Seller' ? Colors.orange : Colors.deepPurple.shade900, onAddClickSupport),
          ),
      bottomNavigationBar: const BottomNavigation(),
    drawer: WidgetHelper.leftNavigationBar(context, screenIndex, customerData['ContactName'], customerData['Mobile'], customerCurrentScreen == 'Seller' ? Colors.orange : Colors.deepPurple.shade900),
    body: 
      loading ? const CircularProgressIndicator() :
      supportList.isEmpty ? const Center(child: Text('No support tickets found')) :
      SingleChildScrollView(
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              itemCount: supportList.length,
              itemBuilder: (BuildContext context, index) {
                final support = supportList[index];
                return ListTile(
                  title: Text(support['Support_Title'].toUpperCase()),
                  subtitle: Text(support['Support_key']),
                  trailing: Text(support['Support_Status'], style: TextStyle(color: support['Support_Status'] == 'Open' ? Colors.red : Colors.green, fontWeight: FontWeight.bold, fontSize: AppConfig.size(context, 16))),
                );
              },
            ),
          const Divider(),
          ],
        ),
      ),
        );
      },
    );
  }
}
