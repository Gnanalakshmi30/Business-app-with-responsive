import 'package:aquila_hundi/app/helper_widgets/config.dart';
import 'package:aquila_hundi/app/helper_widgets/style.dart';
import 'package:aquila_hundi/app/modules/InviteHistory/invite_history_page.dart';
import 'package:aquila_hundi/app/modules/InviteListPage/invitelist_page.dart';
import 'package:aquila_hundi/app/modules/Invoice/invoice_page.dart';
import 'package:aquila_hundi/app/modules/Login/deviceotp_page.dart';
import 'package:aquila_hundi/app/modules/Login/login_page.dart';
import 'package:aquila_hundi/app/modules/MyBusiness/mybusiness_page.dart';
import 'package:aquila_hundi/app/modules/Notifications/notifications_page.dart';
import 'package:aquila_hundi/app/modules/Payments/payments_page.dart';
import 'package:aquila_hundi/app/modules/Profile/my_profile.dart';
import 'package:aquila_hundi/app/modules/Support/support_page.dart';
import 'package:aquila_hundi/app/modules/UserManagement/usermanage_page.dart';
import 'package:aquila_hundi/store/app.state.dart';
import 'package:aquila_hundi/store/auth/auth.action.dart';
import 'package:aquila_hundi/store/business/business.action.dart';
import 'package:aquila_hundi/store/commonValues/commonvalues.action.dart';
import 'package:aquila_hundi/store/dashboard/dashboard.action.dart';
import 'package:flutter/material.dart';
import 'package:aquila_hundi/app/helper_widgets/navigation_drawer.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

class WidgetHelper {
  static Widget getAppBar(BuildContext context, String title,
      Function() onMenuClick, Color backgroundColor, Function onAddClick,
      {int notificationCount = 0}) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: AppConfig.size(context, 20),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.menu,
            color: Colors.white,
          ),
          onPressed: () {
            print('menu clicked');
            onMenuClick();
          },
        ),
        actions: [
          title == 'Dashboard'
              ? WidgetHelper.getNotificationIcon(context, notificationCount)
              : title == 'My Business'
                  ? WidgetHelper.addBusinessIcon(context, () {
                      // show add business modal form
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return WidgetHelper.addBusinessModalForm(
                              context, 'Add Business');
                        },
                      );
                    })
                  : (title == 'Buyer\'s List' || title == 'Seller\'s List')
                      ? WidgetHelper.inviteBuyerIcon(context, () {
                          // show invite buyer modal form
                          onAddClick();
                        })
                      : title == 'Seller\'s List'
                          ? IconButton(
                              onPressed: onAddClick(),
                              icon: const Icon(Icons.add_circle_outline,
                                  color: Colors.white))
                          : title == 'Invite History'
                              ? WidgetHelper.inviteBuyerIcon(context, () {
                                  // show invite buyer modal form
                                  onAddClick();
                                })
                              : (title == 'Invoices' ||
                                      title == 'Users' ||
                                      title == 'Support')
                                  ? WidgetHelper.createInvoiceIcon(context, () {
                                      // show invite buyer modal form
                                      onAddClick();
                                    })
                                  : (title == "My profile")
                                      ? WidgetHelper.profileMenu(context)
                                      : const SizedBox(),
        ],
      ),
    );
  }

  static getNotificationIcon(BuildContext context, int badgeCount) {
    // return icon with badge
    return IconButton(
      icon: Stack(
        children: [
          const Icon(
            Icons.notifications,
            color: Colors.white,
          ),
          if (badgeCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(6),
                ),
                constraints: const BoxConstraints(
                  minWidth: 12,
                  minHeight: 12,
                ),
                child: Text(
                  '$badgeCount',
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
      onPressed: () {
        // navigate to notification page
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const NotificationsPage()));
      },
    );
  }

  static addBusinessIcon(BuildContext context, Function() onAddBusinessClick) {
    return IconButton(
      icon: const Icon(
        Icons.add_circle_outline,
        color: Colors.white,
      ),
      onPressed: () {
        onAddBusinessClick();
      },
    );
  }

  static inviteBuyerIcon(BuildContext context, Function() onInviteBuyerClick) {
    return IconButton(
      icon: const Icon(
        Icons.add_circle_outline,
        color: Colors.white,
      ),
      onPressed: () {
        onInviteBuyerClick();
      },
    );
  }

  static createInvoiceIcon(
      BuildContext context, Function() onCreateInvoiceClick) {
    return IconButton(
      icon: const Icon(
        Icons.add_circle_outline,
        color: Colors.white,
      ),
      onPressed: () {
        onCreateInvoiceClick();
      },
    );
  }

  //added by gnanalakshmi
  static profileMenu(context) {
    final customerType = StoreProvider.of<AppState>(context)
        .state
        .dashboardState
        .customerCurrentScreen;
    return PopupMenuButton(
        iconColor: Colors.white,
        itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () {
                  StoreProvider.of<AppState>(context)
                      .dispatch(UpdateDeviceOTP(""));
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OTPScreen(),
                      ),
                      (route) => false);
                },
                value: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Reset pin",
                    ),
                    Icon(
                      Icons.key,
                      color: customerType == 'Seller'
                          ? Colors.orange
                          : Colors.deepPurple.shade900,
                    )
                  ],
                ),
              ),
              PopupMenuItem(
                onTap: () {
                  deregisterConfirmation(context, customerType);
                },
                value: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Deregister device",
                    ),
                    Icon(
                      Icons.phonelink_erase,
                      color: customerType == 'Seller'
                          ? Colors.orange
                          : Colors.deepPurple.shade900,
                    )
                  ],
                ),
              ),
            ]);
  }

  static deregisterConfirmation(context, customerType) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            actionsAlignment: MainAxisAlignment.end,
            title: Text(
              "Deregister device confirmation",
              style: TextStyle(
                  color: Colors.black, fontSize: AppConfig.size(context, 20)),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                      child: Text(
                    "Are you sure, want to deregister device?",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: AppConfig.size(context, 15)),
                  )),
                ],
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () {
                  final customerData = StoreProvider.of<AppState>(context)
                      .state
                      .authState
                      .customerData;
                  String mobileNum = customerData['Mobile'] ?? "";
                  deregisterDevice(context, mobileNum);
                },
                child: Container(
                    padding: EdgeInsets.only(
                        left: AppConfig.size(context, 15),
                        right: AppConfig.size(context, 15),
                        bottom: AppConfig.size(context, 10),
                        top: AppConfig.size(context, 10)),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: customerType == 'Seller'
                          ? Colors.orange
                          : Colors.deepPurple.shade900,
                    ),
                    child: const Text(
                      'Ok',
                      style: TextStyle(color: Colors.white),
                    )),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                    padding: EdgeInsets.only(
                        left: AppConfig.size(context, 15),
                        right: AppConfig.size(context, 15),
                        bottom: AppConfig.size(context, 10),
                        top: AppConfig.size(context, 10)),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: customerType == 'Seller'
                          ? Colors.orange
                          : Colors.deepPurple.shade900,
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white),
                    )),
              ),
            ],
          );
        });
  }

  static deregisterDevice(context, mobileNumber) {
    // logout
    StoreProvider.of<AppState>(context).dispatch(logout(mobileNumber));
    // navigate to login screen
    Future.delayed(Duration.zero, () {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginPage(),
          ),
          (route) => false);
    });
  }
  //added by gnanalakshmi

  static Widget sideMenu(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text('Drawer Header'),
          ),
          ListTile(
            title: const Text('Item 1'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Item 2'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  static Widget leftNavigationBar(BuildContext context, screenIndex,
      contactName, contactNumber, Color backgroundColor) {
    final customerSelectedScreen = StoreProvider.of<AppState>(context)
        .state
        .dashboardState
        .customerCurrentScreen;
    final mobileNumber = StoreProvider.of<AppState>(context)
        .state
        .authState
        .customerData['Mobile'];
    final customerData = StoreProvider.of<AppState>(context)
        .state
        .authState
        .customerData;

    void handleLogout() {
      // logout
      StoreProvider.of<AppState>(context).dispatch(logout(mobileNumber));
      // navigate to login screen
      Future.delayed(Duration.zero, () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginPage(),
          ),
        );
      });
    }

    void handleLogoutConfirm(int index) {
      if (index == destinations.length) {
        // logout
        // show logout dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Logout'),
              content: const Text('Are you sure you want to logout?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    // logout
                    // clear all data
                    handleLogout();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Logout'),
                ),
              ],
            );
          },
        );
      }

      // navigate to login screen

      if (index == 0) {
        // set bottomnavigatorindex to 0
        StoreProvider.of<AppState>(context)
            .dispatch(UpdateSelectedBottomNavIndexAction(0));
        // show add business modal form
        Future.delayed(Duration.zero, () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MyBusinessPage(),
            ),
          );
        });
      }

      if (index == 1) {
        StoreProvider.of<AppState>(context)
            .dispatch(UpdateSelectedBottomNavIndexAction(1));
        // show add business modal form
        Future.delayed(Duration.zero, () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const InviteHistoryPage(),
            ),
          );
        });
      }

      if (index == 2) {
        StoreProvider.of<AppState>(context)
            .dispatch(UpdateSelectedBottomNavIndexAction(1));
        // show add business modal form
        Future.delayed(Duration.zero, () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const InviteListPage(),
            ),
          );
        });
      }

      if (index == 3) {
        StoreProvider.of<AppState>(context)
            .dispatch(UpdateSelectedBottomNavIndexAction(3));
        // show add business modal form
        Future.delayed(Duration.zero, () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const InvoicePage(),
            ),
          );
        });
      }

      if (index == 4) {
        StoreProvider.of<AppState>(context)
            .dispatch(UpdateSelectedBottomNavIndexAction(4));
        // show add business modal form
        Future.delayed(Duration.zero, () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PaymentsPage(),
            ),
          );
        });
      }

      if (index == 5) {
        StoreProvider.of<AppState>(context)
            .dispatch(UpdateSelectedBottomNavIndexAction(2));
        // show add business modal form
        Future.delayed(Duration.zero, () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MyProfilePage(),
            ),
          );
        });
      }

      if (index == 6) {
        StoreProvider.of<AppState>(context)
            .dispatch(UpdateSelectedBottomNavIndexAction(2));
        // show add business modal form
        Future.delayed(Duration.zero, () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const UserManagePage(),
            ),
          );
        });
      }

      if (index == 7) {
        StoreProvider.of<AppState>(context)
            .dispatch(UpdateSelectedBottomNavIndexAction(2));
        // show add business modal form
        Future.delayed(Duration.zero, () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SupportPage(),
            ),
          );
        });
      }
    }

    return NavigationDrawer(
      onDestinationSelected: handleLogoutConfirm,
      selectedIndex: screenIndex,
      children: <Widget>[
        // add avatar and background color
        // add image with rounded corners
        Container(
          padding: const EdgeInsets.fromLTRB(28, 16, 28, 10),
          color: backgroundColor,
          child: Column(
            children: [
               CircleAvatar(
                radius: 40,
                backgroundImage: // if image available
                    customerData['File_Name'].isNotEmpty && customerData['File_Name'] != null 
                        ? NetworkImage('${AppConfig.rootUrl}/APP_API/Customer_Image/${customerData['File_Name']}') as ImageProvider<Object>
                        : const AssetImage('assets/images/profile-empty.png') as ImageProvider<Object>,
              ),
              // show name
              Text(
                contactName ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // show phone number in a rounded rectangular white box
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  contactNumber ?? '',
                  style: TextStyle(
                    color: backgroundColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        const Padding(
          padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
        ),

        ...destinations.map(
          (MenuItems destination) {
            customerSelectedScreen == 'Buyer' && destination.label == 'Buyers'
                ? destination = destinations2[2]
                : destination = destination;
            return NavigationDrawerDestination(
              label: Text(destination.label),
              icon: destination.icon,
              selectedIcon: destination.selectedIcon,
            );
          },
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(28, 16, 28, 10),
          child: Divider(),
        ),
        // add logout button at the bottom
        const NavigationDrawerDestination(
          label: Text('Logout'),
          icon: Icon(Icons.logout),
          selectedIcon: Icon(Icons.logout),
        ),
      ],
      // logout button at the bottom
    );
  }

  static Widget addBusinessModalForm(BuildContext context, String title) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    Map<String, dynamic> industryList1 =
        StoreProvider.of<AppState>(context).state.businessState.industryList;
    String? selectedIndustry;
    // store industry list as array from industryList['Response']
    List<dynamic> industryList = industryList1['Response'];

    TextEditingController businessNameController = TextEditingController();
    TextEditingController branchNameController = TextEditingController();
    TextEditingController businessCreditLimitController =
        TextEditingController();
    final customerCurrentScreen = StoreProvider.of<AppState>(context)
        .state
        .dashboardState
        .customerCurrentScreen;

    void saveForm() {
      // save form
      StoreProvider.of<AppState>(context).dispatch(addBusiness(
        businessNameController.text,
        branchNameController.text,
        selectedIndustry ?? '',
        businessCreditLimitController.text != ''
            ? double.parse(businessCreditLimitController.text)
            : 0.0,
      ));
    }

    return AlertDialog(
      title: Text(title),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(labelText: 'Business Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter business name';
                  }
                  return null;
                },
                controller: businessNameController,
              ),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Branch Name (Optional)'),
                controller: branchNameController,
              ),
              DropdownButtonFormField(
                key: UniqueKey(),
                value: selectedIndustry,
                decoration: const InputDecoration(
                  labelText: 'Choose Industry',
                ),
                icon: const Icon(Icons.keyboard_arrow_down),
                style: TextStyle(color: Colors.grey[800]),
                items: industryList.map((value) {
                  return DropdownMenuItem(
                    value: value['_id'],
                    child: Text(value['Industry_Name']),
                  );
                }).toList(),
                validator: (value) =>
                    value == null ? 'Please select an industry' : null,
                onChanged: (newValue) => {
                  selectedIndustry = newValue.toString(),
                },
              ),
              if (customerCurrentScreen == 'Seller')
                TextFormField(
                  decoration:
                      const InputDecoration(labelText: 'Business Credit Limit'),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        double.parse(value) == 0.0) {
                      return 'Please enter credit limit';
                    }
                    return null;
                  },
                  controller: businessCreditLimitController,
                ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            print('print save');
            // validate form
            if (formKey.currentState!.validate()) {
              formKey.currentState!.save();
              // save form
              saveForm();
              Navigator.of(context).pop();
            }
            //Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  static Widget editBusinessModalForm(
      BuildContext context,
      String businessId,
      String businessName,
      String branchName,
      double businessCreditLimit,
      Map<String, dynamic> industryId) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    Map<String, dynamic> industryList1 =
        StoreProvider.of<AppState>(context).state.businessState.industryList;
    String? selectedIndustry;
    // store industry list as array from industryList['Response']
    List<dynamic> industryList = industryList1['Response'];

    // String businessId = '';
    // String businessName = '';
    // String branchName = '';
    // String businessCreditLimit = '';

    TextEditingController businessNameController = TextEditingController();
    TextEditingController branchNameController = TextEditingController();
    TextEditingController businessCreditLimitController =
        TextEditingController();
    final customerCurrentScreen = StoreProvider.of<AppState>(context)
        .state
        .dashboardState
        .customerCurrentScreen;

    if (businessId != '') {
      businessNameController.text = businessName;
      branchNameController.text = branchName;
      businessCreditLimitController.text = businessCreditLimit.toString();
      selectedIndustry = industryId['_id'];
    }

    print('businessId: $businessId');
    print('businessName: $businessName');

    void saveForm() {
      // save form
      StoreProvider.of<AppState>(context).dispatch(updateBusiness(
        businessId,
        businessNameController.text,
        branchNameController.text,
        selectedIndustry ?? '',
        double.parse(businessCreditLimitController.text),
      ));
    }

    return AlertDialog(
      title: const Text('Edit Business'),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(labelText: 'Business Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter business name';
                  }
                  return null;
                },
                controller: businessNameController,
              ),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Branch Name (Optional)'),
                controller: branchNameController,
              ),
              DropdownButtonFormField(
                key: UniqueKey(),
                value: selectedIndustry,
                decoration: const InputDecoration(
                  labelText: 'Choose Industry',
                ),
                icon: const Icon(Icons.keyboard_arrow_down),
                style: TextStyle(color: Colors.grey[800]),
                items: industryList.map((value) {
                  return DropdownMenuItem(
                    value: value['_id'],
                    child: Text(value['Industry_Name']),
                  );
                }).toList(),
                validator: (value) =>
                    value == null ? 'Please select an industry' : null,
                onChanged: (newValue) => {
                  selectedIndustry = newValue.toString(),
                },
              ),
              if (customerCurrentScreen == 'Seller')
                TextFormField(
                  decoration:
                      const InputDecoration(labelText: 'Business Credit Limit'),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        double.parse(value) == 0.0) {
                      return 'Please enter credit limit';
                    }
                    return null;
                  },
                  controller: businessCreditLimitController,
                ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            print('print save');
            // validate form
            if (formKey.currentState!.validate()) {
              formKey.currentState!.save();
              // save form
              saveForm();
              Navigator.of(context).pop();
            }
            //Navigator.of(context).pop();
          },
          child: const Text('Update'),
        ),
      ],
    );
  }
}

class MenuItems {
  const MenuItems(this.label, this.icon, this.selectedIcon);

  final String label;
  final Widget icon;
  final Widget selectedIcon;
}

const List<MenuItems> destinations = <MenuItems>[
  MenuItems('My Business', Icon(Icons.business_center_outlined),
      Icon(Icons.business_center)),
  MenuItems(
      'Invite List', Icon(Icons.groups_2_outlined), Icon(Icons.groups_sharp)),
  MenuItems(
      'Buyers', Icon(Icons.shopping_cart_outlined), Icon(Icons.shopping_cart)),
  MenuItems('Invoices', Icon(Icons.document_scanner_outlined),
      Icon(Icons.document_scanner)),
  MenuItems('Payments', Icon(Icons.payment_outlined), Icon(Icons.payment)),
  MenuItems('My Profile', Icon(Icons.person_outline), Icon(Icons.person)),
  MenuItems('User Management', Icon(Icons.people_outline), Icon(Icons.people)),
  MenuItems(
      'Support', Icon(Icons.support_agent_outlined), Icon(Icons.support_agent)),
];

const List<MenuItems> destinations2 = <MenuItems>[
  MenuItems('My Business', Icon(Icons.business_center_outlined),
      Icon(Icons.business_center)),
  MenuItems(
      'Invite List', Icon(Icons.groups_2_outlined), Icon(Icons.groups_sharp)),
  MenuItems('Sellers', Icon(Icons.store_outlined), Icon(Icons.store)),
  MenuItems('Invoices', Icon(Icons.document_scanner_outlined),
      Icon(Icons.document_scanner)),
  MenuItems('Payments', Icon(Icons.payment_outlined), Icon(Icons.payment)),
  MenuItems('My Profile', Icon(Icons.person_outline), Icon(Icons.person)),
  MenuItems('User Management', Icon(Icons.people_outline), Icon(Icons.people)),
  MenuItems(
      'Support', Icon(Icons.support_agent_outlined), Icon(Icons.support_agent)),
];
