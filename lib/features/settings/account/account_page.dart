import 'dart:convert';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:hiddify/core/model/environment.dart';
import 'package:hiddify/features/common/nested_app_bar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsAccountPage extends StatelessWidget {
  const SettingsAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Environment.hasSupabaseConfig) {
      return const Scaffold(
        body: CustomScrollView(
          slivers: [
            NestedAppBar(
              title: Text("Account"),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: _ErrorState(
                "Supabase is not configured. Missing SUPABASE_URL / SUPABASE_ANON_KEY.",
              ),
            ),
          ],
        ),
      );
    }

    SupabaseClient client;
    try {
      client = Supabase.instance.client;
    } catch (_) {
      return const Scaffold(
        body: CustomScrollView(
          slivers: [
            NestedAppBar(
              title: Text("Account"),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: _ErrorState(
                "Supabase client is not initialized.",
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: StreamBuilder<AuthState>(
        stream: client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          final session = snapshot.data?.session ?? client.auth.currentSession;
          return CustomScrollView(
            slivers: [
              const NestedAppBar(
                title: Text("Account"),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: session == null
                      ? _AuthCard(client: client)
                      : _AccountStatusCard(
                          client: client,
                          session: session,
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AuthCard extends StatefulWidget {
  const _AuthCard({
    required this.client,
  });

  final SupabaseClient client;

  @override
  State<_AuthCard> createState() => _AuthCardState();
}

class _AuthCardState extends State<_AuthCard> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  bool _loading = false;
  String? _error;
  String? _info;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() {
      _loading = true;
      _error = null;
      _info = null;
    });
    try {
      await widget.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _signUp() async {
    setState(() {
      _loading = true;
      _error = null;
      _info = null;
    });
    try {
      await widget.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      setState(() {
        _info = "Sign-up completed. If email confirmation is enabled, verify your email before signing in.";
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Sign in to view account status",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.username],
              decoration: const InputDecoration(
                labelText: "Email",
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              autofillHints: const [AutofillHints.password],
              decoration: const InputDecoration(
                labelText: "Password",
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: _loading ? null : _signIn,
                  icon: const Icon(FluentIcons.person_key_20_regular),
                  label: const Text("Sign In"),
                ),
                OutlinedButton.icon(
                  onPressed: _loading ? null : _signUp,
                  icon: const Icon(FluentIcons.person_add_20_regular),
                  label: const Text("Sign Up"),
                ),
              ],
            ),
            if (_loading) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(),
            ],
            if (_info != null) ...[
              const SizedBox(height: 12),
              Text(
                _info!,
                style: const TextStyle(color: Colors.blueGrey),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AccountStatusCard extends StatefulWidget {
  const _AccountStatusCard({
    required this.client,
    required this.session,
  });

  final SupabaseClient client;
  final Session session;

  @override
  State<_AccountStatusCard> createState() => _AccountStatusCardState();
}

class _AccountStatusCardState extends State<_AccountStatusCard> {
  late Future<_AccountStatus> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetchStatus();
  }

  @override
  void didUpdateWidget(covariant _AccountStatusCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.session.user.id != widget.session.user.id) {
      _future = _fetchStatus();
    }
  }

  Future<_AccountStatus> _fetchStatus() async {
    final response = await widget.client.functions.invoke("account-status");

    dynamic payload = response.data;
    if (payload is String) {
      payload = jsonDecode(payload);
    }
    if (payload is! Map) {
      throw const FormatException(
        "account-status returned an invalid payload shape.",
      );
    }

    final data = payload.map(
      (key, value) => MapEntry(key.toString(), value),
    );

    int readInt(String key) {
      final value = data[key];
      if (value is int) return value;
      if (value is num && value == value.toInt()) return value.toInt();
      throw FormatException("account-status missing/invalid '$key'");
    }

    double readDouble(String key) {
      final value = data[key];
      if (value is num) return value.toDouble();
      throw FormatException("account-status missing/invalid '$key'");
    }

    return _AccountStatus(
      daysRemaining: readInt("days_remaining"),
      gbUsed: readDouble("gb_used"),
      connectedMinutes: readInt("connected_minutes"),
    );
  }

  Future<void> _signOut() async {
    await widget.client.auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Signed in as ${widget.session.user.email ?? widget.session.user.id}",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            FutureBuilder<_AccountStatus>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: LinearProgressIndicator(),
                  );
                }
                if (snapshot.hasError) {
                  return _ErrorState(
                    snapshot.error.toString(),
                    action: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _future = _fetchStatus();
                        });
                      },
                      icon: const Icon(FluentIcons.arrow_sync_20_regular),
                      label: const Text("Retry"),
                    ),
                  );
                }
                final status = snapshot.data!;
                final hours = status.connectedMinutes ~/ 60;
                final minutes = status.connectedMinutes % 60;
                return Column(
                  children: [
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: const Text("Subscription Status"),
                      subtitle: Text("${status.daysRemaining} days remaining"),
                    ),
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: const Text("GB Used"),
                      subtitle: Text(status.gbUsed.toStringAsFixed(2)),
                    ),
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: const Text("Connected Time"),
                      subtitle: Text("${hours}h ${minutes}m"),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _signOut,
              icon: const Icon(FluentIcons.sign_out_20_regular),
              label: const Text("Log out"),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountStatus {
  const _AccountStatus({
    required this.daysRemaining,
    required this.gbUsed,
    required this.connectedMinutes,
  });

  final int daysRemaining;
  final double gbUsed;
  final int connectedMinutes;
}

class _ErrorState extends StatelessWidget {
  const _ErrorState(
    this.message, {
    this.action,
  });

  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(FluentIcons.error_circle_24_regular),
            const SizedBox(height: 8),
            SelectableText(
              message,
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: 8),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
