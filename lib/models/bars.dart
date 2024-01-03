import 'package:flutter/material.dart';
import '../screens/myprofile.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
          icon: const Icon(Icons.account_circle_rounded),
          onPressed: () {
            Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Profile()),
          );
          },
          iconSize: 45.0
        ),
      title: Text('City Report'),
      centerTitle: true,
      backgroundColor: Color.fromARGB(255, 227, 186, 220),
      actions: [
        IconButton(
           icon: Icon(Icons.email_outlined),
           onPressed: () {
            Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Profile()),
          );
          },
          iconSize: 45.0
       ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}