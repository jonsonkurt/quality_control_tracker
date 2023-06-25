import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:quality_control_tracker/view/inspector/inspector_project_updates.dart';

class InspectorListPage extends StatefulWidget {
  final String projectIDQuery;

  const InspectorListPage({
    Key? key,
    required this.projectIDQuery,
  }) : super(key: key);

  @override
  State<InspectorListPage> createState() => _InspectorListPageState();
}

class _InspectorListPageState extends State<InspectorListPage> {
  String? inspectorID = FirebaseAuth.instance.currentUser?.uid;
  StreamSubscription<DatabaseEvent>? emptyPendingSubscription;
  var logger = Logger();
  bool isEmptyPending = true;
  String? searchQuery = "";

  void _handleSearch(String value) {
    setState(() {
      searchQuery = value;
    });
  }

  DatabaseReference ref =
      FirebaseDatabase.instance.ref().child('projectUpdates/');

  String convertJobTitle(String input) {
    switch (input.toLowerCase()) {
      case 'electrician':
        return 'Electrical';
      case 'plumber':
        return 'Plumbing';
      case 'painter':
        return 'Painting';
      case 'mason':
        return 'Masonry';
      case 'laborer':
        return 'Labor';
      case 'owner':
        return 'Ownership';
      case 'projectmanager':
        return 'Project Management';
      case 'welder':
        return 'Welding';
      case 'carpenter':
        return 'Carpentry';
      case 'landscaper':
        return 'Landscaping';
      case 'hvac':
        return 'HVAC';
      default:
        return 'Unknown';
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    emptyPendingSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    // Database reference and query for empty view
    DatabaseReference emptyPendingRef =
        FirebaseDatabase.instance.ref('projectUpdates');
    Query emptyPendingQuery = emptyPendingRef
        .orderByChild("inspectorProjectRemarks")
        .startAt("$inspectorID-${widget.projectIDQuery}-PENDING-")
        .endAt("$inspectorID-${widget.projectIDQuery}-PENDING-\uf8ff");

    emptyPendingSubscription = emptyPendingQuery.onValue.listen((event) {
      try {
        if (mounted) {
          setState(() {
            String check = event.snapshot.value.toString();
            if (check != "null") {
              isEmptyPending = false;
            }
          });
        }
      } catch (error, stackTrace) {
        logger.d('Error occurred: $error');
        logger.d('Stack trace: $stackTrace');
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFDCE4E9),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          mediaQuery.size.height * 0.1,
        ),
        child: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
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
                color: Color(0xFF221540),
              ),
            ),
          ),
          title: Padding(
            padding: EdgeInsets.fromLTRB(0, mediaQuery.size.height * 0.035,
                mediaQuery.size.width * 0.06, 0),
            child: Text(
              'For Inspection',
              style: TextStyle(
                fontFamily: 'Rubik Bold',
                fontSize: mediaQuery.size.height * 0.04,
                color: const Color(0xFF221540),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: SearchBox(onSearch: _handleSearch),
          ),
          Expanded(
            child: Container(
              height: 580,
              padding: const EdgeInsets.only(top: 10),
              child: Builder(
                builder: (BuildContext context) {
                  if (isEmptyPending) {
                    return const Center(child: Text("No Available Data"));
                  } else {
                    return FirebaseAnimatedList(
                      query: ref
                          .orderByChild("inspectorProjectRemarks")
                          .startAt(
                              "$inspectorID-${widget.projectIDQuery}-PENDING-")
                          .endAt(
                              "$inspectorID-${widget.projectIDQuery}-PENDING-\uf8ff"),
                      itemBuilder: (context, snapshot, animation, index) {
                        String projectUpdatesID =
                            snapshot.child("projectUpdatesID").value.toString();
                        String rpName =
                            snapshot.child("rpName").value.toString();
                        String rpRole =
                            snapshot.child("rpRole").value.toString();
                        String jobTitle = convertJobTitle(rpRole);

                        String rpSubmissionDateLengthString =
                            snapshot.child("rpSubmissionDate").value.toString();
                        int rpSubmissionDateLengthInt =
                            rpSubmissionDateLengthString.split(":").length - 1;
                        String rpSubmissionDate = snapshot
                            .child(
                                "rpSubmissionDate/rpSubmissionDate$rpSubmissionDateLengthInt")
                            .value
                            .toString();

                        String projectUpdatesTitle = snapshot
                            .child("projectUpdatesTitle")
                            .value
                            .toString();

                        String projectUpdatesPhotoURL = snapshot
                            .child("projectUpdatesPhotoURL")
                            .value
                            .toString();

                        DateTime dateTime =
                            DateFormat("MM-dd-yyyy").parse(rpSubmissionDate);
                        String formattedDate =
                            DateFormat("MMMM d, yyyy").format(dateTime);

                        if (searchQuery != null &&
                            searchQuery!.isNotEmpty &&
                            !projectUpdatesTitle
                                .toLowerCase()
                                .contains(searchQuery!.toLowerCase())) {
                          return Container();
                        }

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      InspectorProjectUpdatesPage(
                                        projectUpdatesID: projectUpdatesID,
                                      )),
                            );
                          },
                          child: Card(
                            child: Row(
                              children: [
                                Image.network(
                                  fit: BoxFit.cover,
                                  projectUpdatesPhotoURL,
                                  width: 100,
                                  height: 100,
                                ),
                                Column(
                                  children: [
                                    Text(
                                      jobTitle,
                                      style: const TextStyle(fontSize: 8),
                                    ),
                                    Text(projectUpdatesTitle),
                                    Text("Accomplished by: $rpName"),
                                    Text(formattedDate),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SearchBox extends StatefulWidget {
  final ValueChanged<String> onSearch;

  const SearchBox({required this.onSearch, Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SearchBoxState createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(
            top: MediaQuery.of(context).size.height / 50,
            left: MediaQuery.of(context).size.width / 20,
            right: MediaQuery.of(context).size.width / 20),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(
            color: Colors.black,
          ),
          decoration: const InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: 'Search',
            hintStyle: TextStyle(fontFamily: "GothamRnd", color: Colors.grey),
            prefixIcon: Icon(
              Icons.search,
              color: Color(0xFF274C77),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              borderSide: BorderSide(
                color: Color(0xFF274C77),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              borderSide: BorderSide(
                color: Color(0xFF274C77),
              ),
            ),
          ),
          onChanged: widget.onSearch,
        ),
      ),
    );
  }
}
