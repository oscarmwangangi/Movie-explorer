import 'package:flutter/material.dart';
import 'package:movie_explorer/api/api_service.dart';
import 'package:movie_explorer/authentication/login.dart';
import 'package:movie_explorer/subscription/subscription_screen.dart';

/// A wrapper widget that checks the user's subscription status.
/// If the status is not 'active', it redirects the user to the
/// SubscriptionScreen.
class SubscriptionGate extends StatefulWidget {
  final Widget child;
  const SubscriptionGate({super.key, required this.child});

  @override
  State<SubscriptionGate> createState() => _SubscriptionGateState();
}

class _SubscriptionGateState extends State<SubscriptionGate> {
  bool _isLoading = true;
  bool _hasAccess = false;

  @override
  void initState() {
    super.initState();
    _checkSubscription();
  }

  Future<void> _checkSubscription() async {
    try {
      final subscription = await ApiService.getMySubscription();

      // The backend returns a JSON object. We check the 'status' field.
      // Expected statuses: 'active', 'pending', 'expired', 'cancelled'.
      final status = subscription['status'];

      if (status == 'active') {
        if (mounted) {
          setState(() {
            _hasAccess = true;
            _isLoading = false;
          });
        }
      } else {
        // Redirect to subscription screen if status is NOT active
        // (covers pending, expired, cancelled, or missing).
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            SubscriptionScreen.id,
            (route) => false,
          );
        }
      }
    } catch (e) {
      // If there's an error (like 401 Unauthorized or network issue),
      // we redirect to the login screen as a fallback.
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          LoginScreen.id,
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.red),
        ),
      );
    }

    return _hasAccess ? widget.child : const SizedBox.shrink();
  }
}
