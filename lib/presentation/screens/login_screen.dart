
import 'package:flutter/material.dart';
import '../../authentication/authentication_manager.dart';
import 'signup_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
final VoidCallback onToggleTheme;
final bool isDarkMode;

const LoginScreen({
super.key,
required this.onToggleTheme,
required this.isDarkMode,
});

@override
State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
final AuthenticationManager _authManager = AuthenticationManager();

final TextEditingController _emailController = TextEditingController();
final TextEditingController _passwordController = TextEditingController();

bool _isLoading = false;
bool _isGoogleLoading = false;

Future<void> _login() async {
final email = _emailController.text.trim();
final password = _passwordController.text.trim();

if (email.isEmpty || password.isEmpty) {
_showMessage('Please enter your email and password');
return;
}

setState(() {
_isLoading = true;
});

final user = await _authManager.login(email, password);

if (!mounted) return;

setState(() {
_isLoading = false;
});

if (user != null) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => HomeScreen(
        onToggleTheme: widget.onToggleTheme,
        isDarkMode: widget.isDarkMode,
      ),
    ),
  );
} else {
  _showMessage(
    'Login failed. Please check your email and password.',
  );
}
}

Future<void> _loginWithGoogle() async {
setState(() {
_isGoogleLoading = true;
});

final user = await _authManager.loginWithGoogle();

if (!mounted) return;

setState(() {
_isGoogleLoading = false;
});

if (user != null) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => HomeScreen(
        onToggleTheme: widget.onToggleTheme,
        isDarkMode: widget.isDarkMode,
      ),
    ),
  );
} else {
  _showMessage('Google sign-in was cancelled or failed');
}
}

void _showMessage(String message) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(message),
),
);
}

InputDecoration _inputDecoration(String label) {
return InputDecoration(
labelText: label,
labelStyle: TextStyle(
color: widget.isDarkMode ? Colors.grey : Colors.grey.shade700,
),
);
}

@override
void dispose() {
_emailController.dispose();
_passwordController.dispose();
super.dispose();
}

@override
Widget build(BuildContext context) {
final textColor = widget.isDarkMode ? Colors.white : Colors.black;
final secondaryColor =
widget.isDarkMode ? Colors.grey : Colors.grey.shade700;

return Scaffold(
backgroundColor: Theme.of(context).scaffoldBackgroundColor,
body: SafeArea(
child: Stack(
children: [
Positioned(
top: 10,
right: 10,
child: IconButton(
onPressed: widget.onToggleTheme,
icon: Icon(
widget.isDarkMode
? Icons.light_mode
    : Icons.dark_mode,
color: textColor,
),
tooltip: widget.isDarkMode
? 'Light Mode'
    : 'Dark Mode',
),
),

Center(
child: SingleChildScrollView(
padding: const EdgeInsets.symmetric(
horizontal: 24,
vertical: 30,
),
child: ConstrainedBox(
constraints: const BoxConstraints(
maxWidth: 420,
),
child: Column(
children: [
const SizedBox(height: 30),

Text(
'Welcome Back',
style: TextStyle(
color: textColor,
fontSize: 32,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 10),

Text(
'Sign in to your Planify account',
style: TextStyle(
color: secondaryColor,
fontSize: 16,
),
),

const SizedBox(height: 35),

TextField(
controller: _emailController,
keyboardType: TextInputType.emailAddress,
style: TextStyle(color: textColor),
decoration: _inputDecoration('Email'),
),

const SizedBox(height: 16),

TextField(
controller: _passwordController,
obscureText: true,
style: TextStyle(color: textColor),
decoration: _inputDecoration('Password'),
),

const SizedBox(height: 25),

SizedBox(
width: double.infinity,
height: 52,
child: ElevatedButton(
onPressed: _isLoading ? null : _login,
style: ElevatedButton.styleFrom(
backgroundColor: textColor,
foregroundColor:
widget.isDarkMode
? Colors.black
    : Colors.white,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(12),
),
),
child: _isLoading
? SizedBox(
width: 22,
height: 22,
child: CircularProgressIndicator(
strokeWidth: 2,
color: widget.isDarkMode
? Colors.black
    : Colors.white,
),
)
    : const Text(
'Sign In',
style: TextStyle(
fontSize: 16,
fontWeight: FontWeight.bold,
),
),
),
),

const SizedBox(height: 22),

Row(
children: [
Expanded(
child: Divider(
color: secondaryColor,
),
),
Padding(
padding: const EdgeInsets.symmetric(
horizontal: 12,
),
child: Text(
'OR',
style: TextStyle(
color: secondaryColor,
),
),
),
Expanded(
child: Divider(
color: secondaryColor,
),
),
],
),

const SizedBox(height: 22),

SizedBox(
width: double.infinity,
height: 52,
child: OutlinedButton(
onPressed: _isGoogleLoading
? null
    : _loginWithGoogle,
style: OutlinedButton.styleFrom(
foregroundColor: textColor,
side: BorderSide(
color: secondaryColor,
),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(12),
),
),
child: _isGoogleLoading
? const SizedBox(
width: 22,
height: 22,
child: CircularProgressIndicator(
strokeWidth: 2,
),
)
    : Row(
mainAxisAlignment:
MainAxisAlignment.center,
children: [
Container(
width: 24,
height: 24,
alignment: Alignment.center,
decoration: BoxDecoration(
color: Colors.white,
borderRadius:
BorderRadius.circular(4),
),
child: const Text(
'G',
style: TextStyle(
color: Colors.black,
fontWeight: FontWeight.bold,
),
),
),
const SizedBox(width: 10),
const Text(
'Continue with Google',
style: TextStyle(
fontSize: 15,
fontWeight: FontWeight.w500,
),
),
],
),
),
),

const SizedBox(height: 25),

Row(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Text(
"Don't have an account? ",
style: TextStyle(
color: secondaryColor,
),
),
TextButton(
onPressed: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) => SignUpScreen(
onToggleTheme:
widget.onToggleTheme,
isDarkMode:
widget.isDarkMode,
),
),
);
},
child: Text(
'Create Account',
style: TextStyle(
color: textColor,
fontWeight: FontWeight.bold,
),
),
),
],
),
],
),
),
),
),
],
),
),
);
}
}
