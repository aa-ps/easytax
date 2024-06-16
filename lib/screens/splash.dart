import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _redirect());
  }

  Future<void> _redirect() async {
    final user = Supabase.instance.client.auth.currentUser;
    String route = '/login';

    if (user != null) {
      try {
        await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single();
        route = '/main';
      } on PostgrestException catch (_) {
        route = '/demographic';
      }
    }

    if (mounted) {
      Navigator.of(context).pushReplacementNamed(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Image.asset('assets/images/ETBC.png')],
        ),
      ),
    );
  }
}
