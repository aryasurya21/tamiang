import 'package:flutter/material.dart';
import 'package:tamiang/widgets/background.dart';
import 'package:tamiang/widgets/text_field_container.dart';
import 'package:tamiang/constants/constant.dart';
import 'package:tamiang/helpers/http_exception.dart';
import 'package:tamiang/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatefulWidget {
  AuthScreen({Key key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final FocusNode _passwordFocusNode = FocusNode();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Map<String, String> _credentials = {"email": "", "password": ""};
  IconData _peekIcon;
  bool isHiddenPassword;
  bool isLoading;

  @override
  void initState() {
    super.initState();
    this._peekIcon = Icons.visibility;
    this.isHiddenPassword = true;
    this.isLoading = false;
  }

  Future<void> _submit() async {
    if (!this._formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    setState(() {
      this.isLoading = true;
    });
    try {
      await Provider.of<AuthProvider>(context).login(
        this._credentials["email"].trim(),
        this._credentials["password"].trim(),
      );
    } on HTTPException catch (err) {
      var errMessage = "Gagal login: ${err.message}";
      if (errMessage.toString().contains("INVALID_EMAIL")) {
        errMessage = "Format email yang dimasukkan salah";
      } else if (errMessage.toString().contains("EMAIL_NOT_FOUND")) {
        errMessage = "Email yang dimasukkan tidak terdaftar";
      } else if (errMessage.toString().contains("INVALID_PASSWORD")) {
        errMessage = "Password yang dimasukkan tidak benar";
      }
      this._showErrSnackBar(errMessage);
    } catch (err) {
      const errMessage = "Tidak bisa login, terjadi error pada database.";
      this._showErrSnackBar(errMessage);
    }
    setState(() {
      this.isLoading = false;
    });
  }

  void _showErrSnackBar(String message) {
    this._scaffoldKey.currentState.showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
  }

  void _togglePassword() {
    setState(() {
      this._peekIcon = this._peekIcon == Icons.visibility
          ? Icons.visibility_off
          : Icons.visibility;
      this.isHiddenPassword = !this.isHiddenPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: this._scaffoldKey,
      body: Background(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                "assets/images/auth.png",
                height: MediaQuery.of(context).size.height * 0.2,
              ),
              Form(
                key: this._formKey,
                child: Column(
                  children: <Widget>[
                    TextFieldContainer(
                      child: TextFormField(
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Email tidak boleh kosong";
                          } else if (!value.contains("@")) {
                            return "Email harus mengandung 1 `@`";
                          }
                          return null;
                        },
                        onSaved: (newValue) {
                          this._credentials["email"] = newValue;
                        },
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(this._passwordFocusNode);
                        },
                        decoration: InputDecoration(
                          errorStyle: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                          icon: Icon(
                            Icons.person,
                            color: Constants.primaryColor,
                          ),
                          hintText: "Email",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    TextFieldContainer(
                      child: TextFormField(
                        focusNode: this._passwordFocusNode,
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Password tidak boleh kosong";
                          }
                          return null;
                        },
                        obscureText: this.isHiddenPassword,
                        onSaved: (newValue) {
                          this._credentials["password"] = newValue;
                        },
                        decoration: InputDecoration(
                          errorStyle: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                          icon: Icon(
                            Icons.lock,
                            color: Constants.primaryColor,
                          ),
                          hintText: "Password",
                          border: InputBorder.none,
                          suffixIcon: InkWell(
                            onTap: this._togglePassword,
                            child: Icon(
                              this._peekIcon,
                              color: Constants.primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(29),
                        child: FlatButton(
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 40),
                          color: Constants.primaryColor,
                          onPressed: this._submit,
                          child: this.isLoading
                              ? Container(
                                  width: 25,
                                  height: 25,
                                  child: CircularProgressIndicator())
                              : Text(
                                  "LOGIN",
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
