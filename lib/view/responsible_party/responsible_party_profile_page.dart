import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../sign_in_page.dart';

class ResponsiblePartyProfilePage extends StatefulWidget {
  const ResponsiblePartyProfilePage({super.key});

  @override
  State<ResponsiblePartyProfilePage> createState() =>
      _ResponsiblePartyProfilePageState();
}

class _ResponsiblePartyProfilePageState
    extends State<ResponsiblePartyProfilePage> {
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();

    // Redirect the user to the SignInPage after logging out
    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignInPage()),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFDCE4E9),
      appBar: PreferredSize(
        preferredSize:  Size.fromHeight(
          mediaQuery.size.height * 0.1,
        ),
        child: AppBar(
          leading: Padding(
            padding: EdgeInsets.fromLTRB(
              mediaQuery.size.width * 0.035,
              mediaQuery.size.height * 0.028,
              0,
              0,
              ),
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
                }, 
                icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Color(0xFF221540),),
                  ),
          ),
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          title: Padding(
            padding: EdgeInsets.fromLTRB(
              0, 
              mediaQuery.size.height * 0.035, 
              0, 
              0),
            child: Text(
              'Profile',
              style: TextStyle(
                fontFamily: 'Rubik Bold',
                fontSize: mediaQuery.size.height * 0.04,
                color: const Color(0xFF221540),
              ),),
          ),
        ),
      ),
      body: const Placeholder(),
      floatingActionButton: FloatingActionButton(
        onPressed: _logout,
        backgroundColor: const Color(0xFF221540),
        child: const Icon(Icons.logout),
      ),
    );
  }
}
