import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quality_control_tracker/image_viewer.dart';
import 'package:quality_control_tracker/view/admin/admin_profile_page.dart';

import 'package:firebase_database/firebase_database.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  DatabaseReference ref = FirebaseDatabase.instance.ref().child('projects');
  late String projectID;
  String projectName = '';

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFDCE4E9),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          mediaQuery.size.height * 0.1,
        ),
        child: AppBar(
          toolbarHeight: 60,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          title: Padding(
            padding: EdgeInsets.fromLTRB(0, mediaQuery.size.height * 0.035,
                mediaQuery.size.width * 0.06, 0),
            child: Text(
              'Dashboard',
              style: TextStyle(
                fontFamily: 'Rubik Bold',
                fontSize: mediaQuery.size.height * 0.04,
                color: const Color(0xFF221540),
              ),
            ),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                0,
                mediaQuery.size.height * 0.017,
                mediaQuery.size.width * 0.035,
                0,
              ),
              child: IconButton(
                onPressed: () {
                  // ignore: use_build_context_synchronously
                  Navigator.push<void>(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AdminProfilePage()));
                },
                icon: Icon(
                  Icons.account_circle,
                  size: mediaQuery.size.height * 0.045,
                  color: const Color(0xFF221540),
                ),
              ),
            ),
          ],
        ),
      ),
      body: StreamBuilder(
          stream: ref.orderByChild("projectStatus").equalTo("ON-GOING").onValue,
          builder: (context, AsyncSnapshot snapshot) {
            dynamic values;
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasData) {
              DataSnapshot dataSnapshot = snapshot.data!.snapshot;

              if (dataSnapshot.value != null) {
                values = dataSnapshot.value;

                return ListView.builder(
                  itemCount: values.length,
                  itemBuilder: (context, index) {
                    String projectID = values.keys.elementAt(index);

                    String projectName = values[projectID]["projectName"];
                    String projectLocation =
                        values[projectID]["projectLocation"];
                    String projectImage = values[projectID]["projectImage"];

                    return Padding(
                      padding: EdgeInsets.fromLTRB(
                        mediaQuery.size.width * 0.01,
                        mediaQuery.size.height * 0.001,
                        mediaQuery.size.width * 0.01,
                        mediaQuery.size.height * 0.001,
                      ),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return DetailScreen(
                                        imageUrl: projectImage,
                                        projectID: projectID,
                                      );
                                    }));
                                  },

                                  // Image (kindly consult Jiiroo if you can't understand the code ty. ヾ(≧▽≦*)o)
                                  child: Hero(
                                    tag: projectID,
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: projectImage == "None"
                                            ? Image.asset(
                                                'assets/images/no-image.png',
                                                fit: BoxFit.cover,
                                                width: 100,
                                                height: 100,
                                              )
                                            : Image(
                                                width: 100,
                                                height: 100,
                                                fit: BoxFit.cover,
                                                image:
                                                    NetworkImage(projectImage),
                                                loadingBuilder: (context, child,
                                                    loadingProgress) {
                                                  if (loadingProgress == null) {
                                                    return child;
                                                  }
                                                  return const CircularProgressIndicator();
                                                },
                                                errorBuilder:
                                                    (context, object, stack) {
                                                  return const Icon(
                                                    Icons.error_outline,
                                                    color: Color.fromARGB(
                                                        255, 35, 35, 35),
                                                  );
                                                },
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Project $projectName',
                                      style: TextStyle(
                                        fontFamily: 'Rubik Bold',
                                        fontSize: mediaQuery.size.height * 0.02,
                                        color: const Color(0xff221540),
                                      ),
                                    ),
                                    SizedBox(
                                        height: mediaQuery.size.height * 0.002),
                                    Text(
                                      projectLocation,
                                      style: TextStyle(
                                        fontFamily: 'Karla Regular',
                                        fontSize:
                                            mediaQuery.size.height * 0.017,
                                        color: const Color(0xff221540),
                                      ),
                                    ),
                                    SizedBox(
                                        height: mediaQuery.size.height * 0.002),
                                    // Text(
                                    //   'Project Inspector: $projectInspector',
                                    //   style: TextStyle(
                                    //     fontFamily: 'Karla Regular',
                                    //     fontSize:
                                    //         mediaQuery.size.height * 0.017,
                                    //     color: const Color(0xff221540),
                                    //   ),
                                    // ),
                                    // SizedBox(
                                    //     height: mediaQuery.size.height * 0.002),
                                    Row(
                                      children: [
                                        Text(
                                          'Project ID: \n$projectID',
                                          style: TextStyle(
                                            fontFamily: 'Karla Regular',
                                            fontSize:
                                                mediaQuery.size.height * 0.017,
                                            color: const Color(0xff221540),
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            Clipboard.setData(
                                                ClipboardData(text: projectID));
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content: Text(
                                                      'Project ID copied to clipboard')),
                                            );
                                          },
                                          icon: Icon(
                                            Icons.copy,
                                            color: const Color(0xFF221540),
                                            size: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.02,
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        // You can access and display other properties from projectData here
                      ),
                    );
                  },
                );
              }
            }
            return const Text("");
          }),
    );
  }
}
