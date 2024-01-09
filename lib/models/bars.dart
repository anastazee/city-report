import 'package:flutter/material.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import '../screens/myprofile.dart';
import 'package:vibration/vibration.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
          icon: const Icon(Icons.account_circle_rounded),
          onPressed: () {
            Navigator.push(
            context,
            SwipeablePageRoute(builder: (context) => Profile()),
          );
          },
          iconSize: 35.0
        ),
      title: Text('City Report'),
      centerTitle: true,
      backgroundColor: Color.fromARGB(255, 232, 222, 255),
      actions: [
        IconButton(
           icon: Icon(Icons.email_outlined),
           onPressed: () {
            Navigator.push(
            context,
            SwipeablePageRoute(builder: (context) => Profile()),
          );
          },
          iconSize: 35.0
       ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}


class AppNavigationBar extends StatelessWidget {
  final int selectedIndex;

  AppNavigationBar({
    required this.selectedIndex
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60.0,
      color: Color.fromARGB(255, 232, 222, 255),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(context, 0, Icons.radio_button_checked, 'Near Me'),
          _buildNavItem(context, 1, Icons.add, 'New Incident'),
          _buildNavItem(context, 2, Icons.folder_outlined, 'My Posts'),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        //Vibration.vibrate();
        // Handle navigation based on the selected index
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/map');
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/new_incident');
            break;
          case 2:
            Navigator.pushReplacementNamed(context, '/my_posts');
            break;
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container( 
            width: 60.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0), // Adjust the border radius as needed
              shape: BoxShape.rectangle,
              color: selectedIndex == index ? Color.fromARGB(255, 194, 185, 213) : Colors.transparent,
            ),
            child: Icon(
              icon,
              color: Color(0xFF21005D),
              size: 30.0,
            )
          ),
          SizedBox(height: 4.0),
          Text(
            label,
            style: TextStyle(
              color: Color(0xFF21005D),
              fontSize: 12.0,
            ),
          ),
        ],
      ),
    );
  }
}
