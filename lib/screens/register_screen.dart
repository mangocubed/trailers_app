import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../components/loading_dialog.dart';
import '../components/password_input_field.dart';
import '../components/snackbar_alert.dart';
import '../components/submit_button.dart';
import '../components/text_input_field.dart';
import '../constants.dart';
import '../graphql/mutations/create_user.graphql.dart';
import '../graphql/schema.graphql.dart';
import '../layouts.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formRegister = GlobalKey<FormState>();
  final _birhdateControlller = TextEditingController();
  final _countryControlller = TextEditingController();
  String _username = '';
  String _email = '';
  String _password = '';
  String _fullName = '';
  DateTime? _birthdate;
  Country? _country;
  String? _errorUsername;
  String? _errorEmail;
  String? _errorPassword;
  String? _errorFullName;
  String? _errorBirthdate;
  String? _errorCountry;

  _openBirthdatePicker() async {
    final pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(1910),
      lastDate: DateTime.now(),
      initialDate: _birthdate,
    );

    setState(() {
      _birthdate = pickedDate;
      _birhdateControlller.text = pickedDate.toString().split(' ').first;
    });
  }

  _openCountryPicker() {
    showCountryPicker(
      context: context,
      onSelect: (value) {
        setState(() {
          _country = value;
          _countryControlller.text = value.name;
        });
      },
    );
  }

  _attemptToRegister() async {
    final loadingDialog = LoadingDialog(context);

    setState(() {
      _errorUsername = null;
      _errorEmail = null;
      _errorPassword = null;
    });

    final textFailedToCreateUser = 'Failed to create user';

    if (_formRegister.currentState?.validate() == true) {
      _formRegister.currentState?.save();

      final graphQLClient = GraphQLProvider.of(context).value;

      final result = await graphQLClient.mutate$CreateUser(
        Options$Mutation$CreateUser(
          variables: Variables$Mutation$CreateUser(
            input: Input$UserInputObject(
              username: _username,
              email: _email,
              password: _password,
              fullName: _fullName,
              birthdate: _birthdate!,
              countryCode: _country!.countryCode,
            ),
          ),
        ),
      );

      if (result.hasException) {
        if (mounted) {
          SnackBarAlert.show(context, textFailedToCreateUser);
        }

        final inputErrors = result.exception?.graphqlErrors.first.extensions?['inputErrors'];

        setState(() {
          _errorUsername = inputErrors['username'];
          _errorEmail = inputErrors['email'];
          _errorPassword = inputErrors['password'];
          _errorFullName = inputErrors['fullName'];
          _errorBirthdate = inputErrors['birthdate'];
          _errorCountry = inputErrors['countryCode'];
        });
      } else if (mounted) {
        SnackBarAlert.show(context, 'User created successfully');
        context.goNamed(routeNameHome);
      }
    } else {
      SnackBarAlert.show(context, textFailedToCreateUser);
    }

    loadingDialog.close();
  }

  @override
  Widget build(BuildContext context) {
    return CenteredLayout(
      title: 'Register',
      child: Form(
        key: _formRegister,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            TextInputField(
              labelText: 'Username',
              errorText: _errorUsername,
              required: true,
              maxLines: 1,
              onSaved: (value) {
                _username = value ?? '';
              },
            ),
            TextInputField(
              labelText: 'Email',
              errorText: _errorEmail,
              keyboardType: TextInputType.emailAddress,
              required: true,
              onSaved: (value) {
                _email = value ?? '';
              },
            ),
            PasswordInputField(
              prefixIcon: const Icon(Icons.key_rounded),
              errorText: _errorPassword,
              required: true,
              onSaved: (value) {
                _password = value ?? '';
              },
            ),
            TextInputField(
              labelText: 'Full name',
              errorText: _errorFullName,
              required: true,
              onSaved: (value) {
                _fullName = value ?? '';
              },
            ),
            TextInputField(
              controller: _birhdateControlller,
              labelText: 'Birthdate',
              errorText: _errorBirthdate,
              required: true,
              readOnly: true,
              suffixIcon: const Icon(Icons.calendar_today),
              onTap: _openBirthdatePicker,
            ),
            TextInputField(
              controller: _countryControlller,
              labelText: 'Country',
              errorText: _errorCountry,
              required: true,
              readOnly: true,
              prefixIcon: _country != null
                  ? Padding(
                      padding: const EdgeInsets.only(top: 10, left: 14),
                      child: Text(_country!.flagEmoji, style: const TextStyle(fontSize: 20)),
                    )
                  : null,
              suffixIcon: const Icon(Icons.language_rounded),
              onTap: _openCountryPicker,
            ),
            SubmitButton(onPressed: _attemptToRegister),
          ],
        ),
      ),
    );
  }
}
