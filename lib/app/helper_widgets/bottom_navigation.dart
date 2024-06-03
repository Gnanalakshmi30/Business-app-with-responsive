import 'package:aquila_hundi/app/helper_widgets/config.dart';
import 'package:aquila_hundi/app/helper_widgets/style.dart';
import 'package:aquila_hundi/app/modules/Dashboard/dashboard_page.dart';
import 'package:aquila_hundi/app/modules/InviteListPage/invitelist_page.dart';
import 'package:aquila_hundi/app/modules/Invoice/invoice_page.dart';
import 'package:aquila_hundi/app/modules/MyBusiness/myBusiness_page.dart';
import 'package:aquila_hundi/app/modules/Payments/payments_page.dart';
import 'package:aquila_hundi/store/app.state.dart';
import 'package:aquila_hundi/store/commonValues/commonvalues.action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';


class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  BottomNavigationState createState() => BottomNavigationState();
}

class BottomNavigationState extends State<BottomNavigation> {


  @override
  Widget build(BuildContext context) {


    return StoreConnector<AppState, Store<AppState>>(
      converter: (store) => store,
      builder: (context, store) {

     int invoiceBadgeCount = 0;
     int paymentBadgeCount = 0;

    final dashBoardData = store.state.dashboardState.dashboardData;
    final String customerCurrentScreen = store.state.dashboardState.customerCurrentScreen;
    final int selectedBottomNavIndex = store.state.commonValuesState.selectedBottomNavIndex;


    if (dashBoardData.isNotEmpty) {
      invoiceBadgeCount = dashBoardData['InvoiceCount'] ?? 0;
      paymentBadgeCount = dashBoardData['PaymentCount'] ?? 0;
    }

    void onItemTapped(int index) {
    if (index == 0) {
            print('businesslist');

      // navigate to my business
      Future.delayed(Duration.zero, () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MyBusinessPage(),
          ),
        );
      });
    }  
    else if (index == 1) {
      print('buyerlist');
      // navigate to buyer/seller
      Future.delayed(Duration.zero, () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const InviteListPage(),
          ),
        );
      });
    }
    else if (index == 2) {
      // navigate to dashboard
      Future.delayed(Duration.zero, () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DashBaordPage(),
          ),
        );
      });
    }
    else if (index == 3) {
      // navigate to invoice
      Future.delayed(Duration.zero, () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const InvoicePage(),
          ),
        );
      });
    }
    else if (index == 4) {
      // navigate to payment
      Future.delayed(Duration.zero, () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PaymentsPage(),
          ),
        );
      });
    }
    store.dispatch(UpdateSelectedBottomNavIndexAction(index));
    }



    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(
            Icons.business_center,
            size: AppConfig.isPortrait(context)
                ? AppConfig.size(context, 30)
                : AppConfig.size(context, 40),
            ),
          label: 'My Business',
        ),
         BottomNavigationBarItem(
          icon: 
          Icon(
            customerCurrentScreen == 'Seller'
                ? Icons.shopping_cart
                : Icons.store,
            size: AppConfig.isPortrait(context)
                ? AppConfig.size(context, 30)
                : AppConfig.size(context, 40),
          ),
          label: customerCurrentScreen == 'Seller' ? 'Buyer' : 'Seller',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.space_dashboard),
          label: 'Dashboard',
        ),
        if (invoiceBadgeCount > 0)
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.document_scanner),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: Text(
                      '$invoiceBadgeCount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: AppConfig.isPortrait(context)
                            ? AppConfig.size(context, 10)
                            : AppConfig.size(context, 12),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            label: 'Invoice',
          )
        else
          const BottomNavigationBarItem(
            icon: Icon(Icons.document_scanner),
            label: 'Invoice',
          ),
  
        if (paymentBadgeCount > 0)
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.payment),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: Text(
                      '$paymentBadgeCount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: AppConfig.isPortrait(context)
                            ? AppConfig.size(context, 10)
                            : AppConfig.size(context, 12),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            label: 'Payment',
          )
        else
          const BottomNavigationBarItem(
            icon: Icon(Icons.payment),
            label: 'Payment',
          ),
 
      ],
      currentIndex: selectedBottomNavIndex,
      selectedItemColor: customerCurrentScreen == 'Seller'
          ? Colors.amber[800]
          : Colors.blue[800],
      onTap: onItemTapped,
      backgroundColor: customerCurrentScreen == 'Seller'
          ? Colors.amber[50]
          : Colors.blue[50],
      selectedFontSize: AppConfig.size(context, 12),
      unselectedFontSize: AppConfig.size(context, 10),
      selectedLabelStyle: const TextStyle(
      fontWeight: FontWeight.bold,

      ),
    );
      }
    );
  }


}



