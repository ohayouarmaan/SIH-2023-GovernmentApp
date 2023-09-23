import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:textfield_tags/textfield_tags.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

Future<Position> determinePosition() async {
	bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
	if(!serviceEnabled) {
		// Service is disabled, throw error and show error screen.
		return Future.error("Location services are disabled");
	}

	LocationPermission permission = await Geolocator.checkPermission();
	if(permission == LocationPermission.denied) {
		permission = await Geolocator.requestPermission();
		if(permission == LocationPermission.denied) {
			// Location permissions are denied, throw error or show permission_handler prompt again.
			return Future.error("Provide location permission");
		}
	} else if (permission == LocationPermission.deniedForever) {
		// location permissions are permanently denied, show prompt to the user to change it in the settings.
		return Future.error("Location permissions are permanently denied, change it in the application settings");
	}

	return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'SIH Government App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

Widget generateContacts(BuildContext context) {
  return SizedBox(
    width: MediaQuery.of(context).size.width * 0.6,
    child: const TextField(
      decoration:
          InputDecoration(border: OutlineInputBorder(), hintText: "Wow"),
    ),
  );
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 1;
  List<String> contacts = [];
  List<String> tags = [];
  Set tags_set = new Set();
  Position? pos;

  Future<void> _getCurrentPosition() async {
    await determinePosition().then((Position _pos) => {
      setState(() => pos = _pos)
    });
  }

  @override
  void initState() {
    super.initState();
    _getCurrentPosition();
  }

  void addTag(String newTag) {
    setState(() {
      tags_set.add(newTag);
    });
  }

  void removeTag(String tagToRemove) {
    setState(() {
      tags_set.remove(tagToRemove);
    });
  }

  void increment_contact(
      String contact, TextEditingController contactController) {
    setState(() {
      contacts.add(contact);
    });
    contactController.value = TextEditingValue(
      text: "",
    );
    print(contactController.text);
  }

  void increment_tags(String tag, TextEditingController tagController) {
    setState(() {
      tags.add(tag);
    });
    tagController.value = TextEditingValue(
      text: "",
    );
    print(tagController.text);
  }

  TextEditingController contactController = TextEditingController();
  TextEditingController tagsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: const Text(
                "Name",
                textAlign: TextAlign.start,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: const TextField(
                decoration: InputDecoration(
                    border: OutlineInputBorder(), hintText: "Wow"),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: const Text(
                "Contact Numbers:",
                textAlign: TextAlign.start,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Row(
                children: [
                  Column(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: TextField(
                          controller: contactController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(), hintText: "Wow"),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  FloatingActionButton(
                    onPressed: () => {
                      increment_contact(
                          contactController.text, contactController)
                    },
                    child: Icon(Icons.add),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: const Text(
                "Address",
                textAlign: TextAlign.start,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: const TextField(
                decoration: InputDecoration(
                    border: OutlineInputBorder(), hintText: "Wow"),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: const Text(
                "Tags:",
                textAlign: TextAlign.start,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Row(
                children: [
                  Column(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: TextFieldTags(
                          textSeparators: [
                            " ", //seperate with space
                          ],
                          initialTags: [
                            //inital tags
                          ],
                          onTag: (tag) {
                            addTag(tag);
                            //this will give tag when entered new single tag
                          },
                          onDelete: (tag) {
                            removeTag(tag);
                            //this will give single tag on delete
                          },
                          validator: (tag) {
                            //add validation for tags
                            if (tag.length < 3) {
                              return "Enter tag up to 3 characters.";
                            }
                            return null;
                          },
                          tagsStyler: TagsStyler(
                              //styling tag style
                              tagTextStyle:
                                  TextStyle(fontWeight: FontWeight.normal),
                              tagDecoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.circular(0.0),
                              ),
                              tagCancelIcon: Icon(Icons.cancel,
                                  size: 18.0, color: Colors.blue[900]),
                              tagPadding: EdgeInsets.all(6.0)),
                          textFieldStyler: TextFieldStyler(
                              //styling tag text field
                              textFieldBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.blue, width: 2))),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
