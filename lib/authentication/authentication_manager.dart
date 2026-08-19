import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthenticationManager {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> signUp(
      String name,
      String email,
      String password,
      ) async {
    try {
      final UserCredential result =
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = result.user;

      if (user == null) {
        return {
          'success': false,
          'message': 'Account could not be created.',
        };
      }

      debugPrint('AUTH SUCCESS: ${user.uid}');

      try {
        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        debugPrint('FIRESTORE SUCCESS');

        return {
          'success': true,
          'message': 'Account created successfully.',
          'user': user,
        };
      } on FirebaseException catch (e) {
        debugPrint(
          'FIRESTORE ERROR: ${e.code} - ${e.message}',
        );

        return {
          'success': false,
          'message': 'Firestore error: ${e.message}',
        };
      }
    } on FirebaseAuthException catch (e) {
      debugPrint(
        'AUTH ERROR: ${e.code} - ${e.message}',
      );

      String message;

      switch (e.code) {
        case 'email-already-in-use':
          message = 'This email is already registered.';
          break;

        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;

        case 'weak-password':
          message = 'Password is too weak.';
          break;

        case 'network-request-failed':
          message = 'Check your internet connection.';
          break;

        case 'operation-not-allowed':
          message = 'Email/Password authentication is not enabled.';
          break;

        default:
          message = e.message ?? 'Authentication failed.';
      }

      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      debugPrint('UNKNOWN ERROR: $e');

      return {
        'success': false,
        'message': 'Unexpected error: $e',
      };
    }
  }

  Future<User?> login(
      String email,
      String password,
      ) async {
    try {
      final UserCredential result =
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return result.user;
    } on FirebaseAuthException catch (e) {
      debugPrint(
        'Login Error: ${e.code} - ${e.message}',
      );
      return null;
    }
  }

  Future<User?> loginWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser =
      await GoogleSignIn.instance.authenticate();

      final GoogleSignInAuthentication googleAuth =
          googleUser.authentication;

      if (googleAuth.idToken == null) {
        debugPrint('Google Login Error: ID token is null');
        return null;
      }

      final OAuthCredential credential =
      GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final UserCredential result =
      await _auth.signInWithCredential(credential);

      final User? user = result.user;

      if (user == null) {
        return null;
      }

      final DocumentReference userDocument =
      _firestore.collection('users').doc(user.uid);

      final DocumentSnapshot snapshot =
      await userDocument.get();

      if (!snapshot.exists) {
        await userDocument.set({
          'name': user.displayName ?? '',
          'email': user.email,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      return user;
    } on FirebaseAuthException catch (e) {
      debugPrint(
        'Google Login Error: ${e.code} - ${e.message}',
      );
      return null;
    } catch (e) {
      debugPrint('Unknown Google Login Error: $e');
      return null;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();

    try {
      await GoogleSignIn.instance.signOut();
    } catch (e) {
      debugPrint('Google Logout Error: $e');
    }
  }
}