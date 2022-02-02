import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/pages/foodchart.dart';
import 'package:myapp/pages/house.dart';

class SignInUsingPhone extends StatefulWidget {
  final bool loading = false;
  final List<int> otp = [];
  SignInUsingPhone({Key? key}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInUsingPhone> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String currentView = 'phone';
  final myController = TextEditingController();
  String verId = '';
  @override
  Widget build(BuildContext context) {
    return currentView == 'phone'
        ? showPhoneNumberSignInPage()
        : showVerificationCodePage();
  }

  Widget showPhoneNumberSignInPage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Home'),
      ),
      body: Center(
        child: currentView == 'phone'
            ? Form(
                key: formKey,
                child: Column(
                  children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: TextFormField(
                          controller: myController,
                          decoration:
                              const InputDecoration(hintText: '91231XXXXX'),
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Phone number cannot be empty';
                            }
                            // if (value.length < 10 || value.length > 10) {
                            //   return 'Phone numbers must be 10 characters';
                            // }
                            return null;
                          },
                        )),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: ElevatedButton(
                          onPressed: () async {
                            FirebaseAuth auth = FirebaseAuth.instance;
                            String phoneNumber = myController.text;
                            if (formKey.currentState!.validate()) {
                              await auth.verifyPhoneNumber(
                                  phoneNumber: '+91' + phoneNumber,
                                  verificationCompleted:
                                      handleVerificationCompleted,
                                  verificationFailed: handleVerificationFailed,
                                  codeSent: handleCodeSent,
                                  codeAutoRetrievalTimeout: handleCodeTimeout);
                            }
                          },
                          child: const Text('Sign in')),
                    )
                  ],
                ))
            : showVerificationCodePage(),
      ),
    );
  }

  handleCodeTimeout(String timeout) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.orange[700],
        content: const Text.rich(
          TextSpan(text: 'Timed out'),
          textAlign: TextAlign.center,
        ),
        duration: const Duration(seconds: 1)));
  }

  handleCodeSent(String verificationId, int? forceResendingToken) {
    myController.text = '';
    setState(() {
      verId = verificationId;
    });
    setState(() {
      currentView = 'otp';
    });
  }

  handleVerificationFailed(FirebaseAuthException exception) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red[700],
        content: const Text.rich(
          TextSpan(text: 'Verification failed'),
          textAlign: TextAlign.center,
        ),
        duration: const Duration(seconds: 1)));
  }

  handleVerificationCompleted(PhoneAuthCredential credential) async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      await auth.signInWithCredential(credential);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.green[700],
          content: const Text.rich(
            TextSpan(text: 'Success'),
            textAlign: TextAlign.center,
          ),
          duration: const Duration(seconds: 1)));
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => House(),
          ));
    } catch (error) {
      rethrow;
    }
  }

  Widget showVerificationCodePage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OTP'),
      ),
      body: Center(
          child: Center(
              child: Column(children: [
        RichText(
            text: const TextSpan(children: <TextSpan>[
          TextSpan(
              text: 'Verification code',
              style: TextStyle(fontSize: 30, color: Colors.black)),
          TextSpan(
              text: 'Please enter the OTP sent to your phone',
              style: TextStyle(fontSize: 15))
        ])),
        Column(
          children: <Widget>[
            TextField(
              controller: myController,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
            )
          ],
        ),
        ElevatedButton(
            onPressed: () async {
              try {
                FirebaseAuth auth = FirebaseAuth.instance;
                PhoneAuthCredential credential = PhoneAuthProvider.credential(
                    verificationId: verId, smsCode: myController.text);
                await auth.signInWithCredential(credential);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    backgroundColor: Colors.green[700],
                    content: const Text.rich(
                      TextSpan(text: 'Success'),
                      textAlign: TextAlign.center,
                    ),
                    duration: const Duration(seconds: 1)));
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => House(),
                    ));
              } catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    backgroundColor: Colors.red[700],
                    content: const Text.rich(
                      TextSpan(text: 'Auth error'),
                      textAlign: TextAlign.center,
                    ),
                    duration: const Duration(seconds: 1)));
              }
            },
            child: const Text('Verify'))
      ]))),
    );
  }
}
