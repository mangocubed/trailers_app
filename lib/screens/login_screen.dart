import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../components/loading_dialog.dart';
import '../components/password_input_field.dart';
import '../components/snackbar_alert.dart';
import '../components/submit_button.dart';
import '../components/text_input_field.dart';
import '../constants.dart';
import '../layouts.dart';
import '../session.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formLogin = GlobalKey<FormState>();
  String _usernameOrEmail = '';
  String _password = '';

  _attemptToLogin() async {
    final loadingDialog = LoadingDialog(context);

    final textFailedToAuthenticateUser = 'Failed to authenticate user';

    if (_formLogin.currentState?.validate() == true) {
      _formLogin.currentState?.save();

      final isSuccessful = await Session.create(context, _usernameOrEmail, _password);

      if (mounted) {
        if (isSuccessful) {
          SnackBarAlert.show(context, 'User authenticated successfully');
          context.goNamed(routeNameHome);
        } else {
          SnackBarAlert.show(context, textFailedToAuthenticateUser);
        }
      }
    } else {
      SnackBarAlert.show(context, textFailedToAuthenticateUser);
    }

    loadingDialog.close();
  }

  @override
  Widget build(BuildContext context) {
    return CenteredLayout(
      title: 'Login',
      child: Form(
        key: _formLogin,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            TextInputField(
              labelText: 'Username or email',
              required: true,
              maxLines: 1,
              onSaved: (value) {
                _usernameOrEmail = value ?? '';
              },
            ),
            PasswordInputField(
              prefixIcon: const Icon(Icons.key_rounded),
              required: true,
              onSaved: (value) {
                _password = value ?? '';
              },
            ),
            SubmitButton(onPressed: _attemptToLogin),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.goNamed(routeNameRegister),
                icon: const Icon(Icons.person_add_rounded),
                label: Text('I don\'t have an account'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
