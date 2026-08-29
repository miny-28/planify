
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
final VoidCallback onToggleTheme;
final bool isDarkMode;

const ProfileScreen({
super.key,
required this.onToggleTheme,
required this.isDarkMode,
});

@override
State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
final FirebaseAuth _auth = FirebaseAuth.instance;

User? get currentUser => _auth.currentUser;

Future<void> _editProfile() async {
final user = currentUser;

if (user == null) {
return;
}

final nameController = TextEditingController(
text: user.displayName ?? '',
);

final emailController = TextEditingController(
text: user.email ?? '',
);

final formKey = GlobalKey<FormState>();

await showDialog(
context: context,
builder: (dialogContext) {
return AlertDialog(
title: const Text('Edit Profile'),

content: Form(
key: formKey,
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
TextFormField(
controller: nameController,
decoration: const InputDecoration(
labelText: 'Name',
prefixIcon: Icon(
Icons.person_outline,
),
),
validator: (value) {
if (value == null ||
value.trim().isEmpty) {
return 'Please enter your name';
}

return null;
},
),

const SizedBox(height: 16),

TextFormField(
controller: emailController,
keyboardType:
TextInputType.emailAddress,
decoration: const InputDecoration(
labelText: 'Email',
prefixIcon: Icon(
Icons.email_outlined,
),
),
validator: (value) {
if (value == null ||
value.trim().isEmpty) {
return 'Please enter your email';
}

if (!value.contains('@')) {
return 'Please enter a valid email';
}

return null;
},
),
],
),
),

actions: [
TextButton(
onPressed: () {
Navigator.pop(dialogContext);
},
child: const Text('Cancel'),
),

ElevatedButton(
onPressed: () async {
if (!formKey.currentState!.validate()) {
return;
}

final newName =
nameController.text.trim();

final newEmail =
emailController.text.trim();

try {

await user.updateDisplayName(newName);


if (newEmail != user.email) {
await user.verifyBeforeUpdateEmail(
newEmail,
);
}

await user.reload();

if (!mounted) {
return;
}

setState(() {});

Navigator.pop(dialogContext);

ScaffoldMessenger.of(context)
    .showSnackBar(
const SnackBar(
content: Text(
'Profile updated successfully',
),
),
);
} on FirebaseAuthException catch (e) {
if (!mounted) {
return;
}

Navigator.pop(dialogContext);

ScaffoldMessenger.of(context)
    .showSnackBar(
SnackBar(
content: Text(
e.message ??
'Failed to update profile',
),
),
);
}
},
child: const Text('Save'),
),
],
);
},
);

nameController.dispose();
emailController.dispose();
}


Future<void> _changePassword() async {
final passwordController =
TextEditingController();

final confirmPasswordController =
TextEditingController();

final formKey = GlobalKey<FormState>();

await showDialog(
context: context,
builder: (dialogContext) {
return AlertDialog(
title: const Text('Change Password'),

content: Form(
key: formKey,
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
TextFormField(
controller: passwordController,
obscureText: true,
decoration: const InputDecoration(
labelText: 'New Password',
prefixIcon: Icon(
Icons.lock_outline,
),
),
validator: (value) {
if (value == null ||
value.isEmpty) {
return 'Please enter a password';
}

if (value.length < 6) {
return 'Password must be at least 6 characters';
}

return null;
},
),

const SizedBox(height: 16),

TextFormField(
controller:
confirmPasswordController,
obscureText: true,
decoration: const InputDecoration(
labelText: 'Confirm Password',
prefixIcon: Icon(
Icons.lock_outline,
),
),
validator: (value) {
if (value == null ||
value.isEmpty) {
return 'Please confirm your password';
}

if (value !=
passwordController.text) {
return 'Passwords do not match';
}

return null;
},
),
],
),
),

actions: [
TextButton(
onPressed: () {
Navigator.pop(dialogContext);
},
child: const Text('Cancel'),
),

ElevatedButton(
onPressed: () async {
if (!formKey.currentState!.validate()) {
return;
}

final user = currentUser;

if (user == null) {
return;
}

try {
await user.updatePassword(
passwordController.text,
);

if (!mounted) {
return;
}

Navigator.pop(dialogContext);

ScaffoldMessenger.of(context)
    .showSnackBar(
const SnackBar(
content: Text(
'Password changed successfully',
),
),
);
} on FirebaseAuthException catch (e) {
if (!mounted) {
return;
}

Navigator.pop(dialogContext);

ScaffoldMessenger.of(context)
    .showSnackBar(
SnackBar(
content: Text(
e.message ??
'Failed to change password',
),
),
);
}
},
child: const Text('Save'),
),
],
);
},
);

passwordController.dispose();
confirmPasswordController.dispose();
}


Future<void> _logout() async {
final shouldLogout =
await showDialog<bool>(
context: context,
builder: (dialogContext) {
return AlertDialog(
title: const Text('Logout'),

content: const Text(
'Are you sure you want to logout?',
),

actions: [
TextButton(
onPressed: () {
Navigator.pop(
dialogContext,
false,
);
},
child: const Text('Cancel'),
),

ElevatedButton(
onPressed: () {
Navigator.pop(
dialogContext,
true,
);
},
child: const Text('Logout'),
),
],
);
},
);

if (shouldLogout != true) {
return;
}

try {
await _auth.signOut();

if (!mounted) {
return;
}


Navigator.pushAndRemoveUntil(
context,
MaterialPageRoute(
builder: (context) => LoginScreen(
onToggleTheme:
widget.onToggleTheme,
isDarkMode:
widget.isDarkMode,
),
),
(route) => false,
);
} on FirebaseAuthException catch (e) {
if (!mounted) {
return;
}

ScaffoldMessenger.of(context)
    .showSnackBar(
SnackBar(
content: Text(
e.message ?? 'Failed to logout',
),
),
);
}
}


@override
Widget build(BuildContext context) {
final theme = Theme.of(context);

final user = currentUser;

final String name =
user?.displayName?.isNotEmpty == true
? user!.displayName!
    : 'User';

final String email =
user?.email ?? 'No email available';

return Scaffold(
appBar: AppBar(
title: const Text(
'Profile',
style: TextStyle(
fontWeight: FontWeight.bold,
),
),
centerTitle: true,
),

body: SingleChildScrollView(
padding: const EdgeInsets.all(20),

child: Column(
children: [


CircleAvatar(
radius: 55,
backgroundColor:
theme.colorScheme.primary,

child: const Icon(
Icons.person,
size: 60,
color: Colors.white,
),
),

const SizedBox(height: 16),


Text(
name,
style: theme
    .textTheme
    .headlineSmall
    ?.copyWith(
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 6),



Text(
email,
style: theme
    .textTheme
    .bodyMedium
    ?.copyWith(
color: Colors.grey,
),
),

const SizedBox(height: 30),


_buildOption(
context,
icon: Icons.edit_outlined,
title: 'Edit Profile',
subtitle:
'Change your name and email',
onTap: _editProfile,
),


_buildOption(
context,
icon: Icons.lock_outline,
title: 'Change Password',
subtitle:
'Update your account password',
onTap: _changePassword,
),



Card(
margin:
const EdgeInsets.only(
bottom: 12,
),

child: ListTile(
leading: Icon(
widget.isDarkMode
? Icons.dark_mode
    : Icons.light_mode,
),

title: const Text(
'Theme',
style: TextStyle(
fontWeight:
FontWeight.w600,
),
),

subtitle: Text(
widget.isDarkMode
? 'Dark Mode'
    : 'Light Mode',
),

trailing: Switch(
value: widget.isDarkMode,
onChanged: (_) {
widget.onToggleTheme();
},
),

onTap:
widget.onToggleTheme,
),
),

const SizedBox(height: 10),


Card(
child: ListTile(
leading: const Icon(
Icons.logout,
color: Colors.red,
),

title: const Text(
'Logout',
style: TextStyle(
color: Colors.red,
fontWeight:
FontWeight.w600,
),
),

subtitle: const Text(
'Sign out from your account',
),

onTap: _logout,
),
),
],
),
),
);
}


Widget _buildOption(
BuildContext context, {
required IconData icon,
required String title,
required String subtitle,
required VoidCallback onTap,
}) {
return Card(
margin:
const EdgeInsets.only(
bottom: 12,
),

child: ListTile(
leading: Icon(icon),

title: Text(
title,
style: const TextStyle(
fontWeight:
FontWeight.w600,
),
),

subtitle: Text(subtitle),

trailing: const Icon(
Icons.arrow_forward_ios,
size: 18,
),

onTap: onTap,
),
);
}
}

