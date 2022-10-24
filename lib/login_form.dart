import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:quiz_app/route_generator.dart';

logInConfirm(BuildContext context,Map values) async {
  HttpOverrides.global = MyHttpOverrides();
  var url = Uri.https("www.cs.utep.edu",
      "/cheon/cs4381/homework/quiz/login.php", {
        "user": values['username'],
        "pin": values['password']
      });
  var response = await http.get(url);
  var decode = jsonDecode(response.body);
  bool connected = decode['response'];
  if (!connected) {
    var reason = decode['reason'];
    await showDialog(context: context, builder: (context) => AlertDialog(
      title: const Text('Error'),
      content: Text(reason) ,
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(),
        child: const Text('Try Again'),)
      ],
    ),);
  }else{
    Navigator.of(context).pushNamed('/homeScreen',arguments: LoginArguments(values['username'], values['password']));
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final GlobalKey<FormFieldState<String>> _usernameFormFieldKey = GlobalKey();
  final GlobalKey<FormFieldState<String>> _passwordFormFieldKey = GlobalKey();

  _notEmpty(String value) => value.isNotEmpty;

  get values => ({
    'username': _usernameFormFieldKey.currentState?.value,
    'password': _passwordFormFieldKey.currentState?.value
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: ListView(
        children: <Widget>[
          Container(alignment: Alignment.center, padding : const EdgeInsets.all(25),color: Colors.purple,),
          Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(25),
              color: Colors.black,
              child: const Text(' CS 4381\nQuiz App',
                style: TextStyle(
                    color: Colors.purple,
                    fontWeight: FontWeight.w500,
                    fontSize: 35),
              )
          ),
          Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(5),
              child: const Text(
                'Login to start',
                style: TextStyle(fontSize: 20, color: Colors.purple),
              )),
          TextFormField(
            key: _usernameFormFieldKey,
            style: const TextStyle(color: Colors.purple),

            decoration: const InputDecoration(
              labelText: 'Username',
              filled: true,
              fillColor: Colors.white,
            ),
            validator: (value) =>
            _notEmpty(value!) ? null : 'Username is required',
          ),
          TextFormField(
            key: _passwordFormFieldKey,
            obscureText: true,
            style: const TextStyle(color: Colors.purple),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Pin',
              filled: true,
              fillColor: Colors.white,
            ),
            validator: (value) =>
            _notEmpty(value!) ? null : 'Password is required',
          ),
          Builder(builder: (context) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                ElevatedButton(
                  // ElevatedButton
                    child: const Text('Log In'),
                    onPressed: () async { logInConfirm(context, values); }
                ),
                TextButton(
                  // TextButton
                  child: const Text('Reset'),
                  onPressed: () => Form.of(context)!.reset(),
                )
              ],
            );
          }),
        ],
      ),
    );
  }
}

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}
