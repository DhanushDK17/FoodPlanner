import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:myapp/pages/house.dart';
import 'siginusingphone.dart';

import 'foodchart.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List daysOfTheWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  FirebaseAuth auth = FirebaseAuth.instance;
  DateTime? _selectedDay;
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      print(user);
      if (user == null) {
        pushToSignInUsingPhone();
      } else {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => House(),
            ));
      }
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loading'),
      ),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;
    final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Widget buildHomePageWithSignIn() {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
              onPressed: () {
                User? result = FirebaseAuth.instance.currentUser;
                if (result != null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      backgroundColor: Colors.green[700],
                      content: const Text.rich(
                        TextSpan(text: 'Welcome'),
                        textAlign: TextAlign.center,
                      ),
                      duration: const Duration(seconds: 1)));
                } else {
                  signInWithGoogle().then((value) {}).catchError((error) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(error.message),
                        duration: const Duration(seconds: 1)));
                  });
                }
              },
              child: const Text('Sign in with Google')),
          ElevatedButton(
              onPressed: () => pushToSignInUsingPhone(),
              child: const Text('Sign in using phone number'))
        ],
      )),
    );
  }

  void pushToSignInUsingPhone() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => SignInUsingPhone()));
  }

  Widget buildSignInPage() {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
          child: Column(
        children: <Widget>[],
      )),
    );
  }
}
