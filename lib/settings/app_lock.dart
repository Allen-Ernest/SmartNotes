import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLockingPage extends StatefulWidget {
  const AppLockingPage({super.key});

  @override
  State<AppLockingPage> createState() => _AppLockingPageState();
}

class _AppLockingPageState extends State<AppLockingPage> {
  bool isAppLocked = false;

  void _checkLockingStatus() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    bool? lockingStatus = preferences.getBool('lock_status');
    if (lockingStatus != null) {
      setState(() {
        isAppLocked = lockingStatus;
      });
    }
  }

  void setPIN() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setDialogState) {
            TextEditingController controller1 = TextEditingController();
            TextEditingController controller2 = TextEditingController();
            bool isPasswordVisible = false;
            void togglePINVisibility() {
              setDialogState(() {
                isPasswordVisible = !isPasswordVisible;
              });
            }

            var height = MediaQuery.of(context).size.height;

            return AlertDialog(
              title: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Set PIN'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller1,
                    obscureText: !isPasswordVisible,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        icon: const Icon(Icons.pin),
                        suffixIcon: IconButton(
                            onPressed: () {
                              togglePINVisibility();
                            },
                            icon: isPasswordVisible
                                ? const Icon(Icons.visibility_off)
                                : const Icon(Icons.visibility))),
                  ),
                  SizedBox(height: height * 0.03),
                  TextField(
                      controller: controller2,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          icon: Icon(Icons.check_circle),
                          border: OutlineInputBorder()))
                ],
              ),
              actions: [
                TextButton(onPressed: () {}, child: const Text('Set PIN')),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'))
              ],
            );
          });
        });
  }

  @override
  void initState() {
    _checkLockingStatus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App locking')),
      body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: isAppLocked
              ? Column(
                  children: <Widget>[
                    ListTile(
                      leading: const Icon(Icons.lock_open),
                      title: const Text('Disable App lock'),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: const Icon(Icons.change_circle),
                      title: const Text('Change locking mode'),
                      onTap: () {},
                    )
                  ],
                )
              : Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('Choose locking Mode'),
                      ],
                    ),
                    ListTile(
                      title: const Text('PIN'),
                      leading: const Icon(Icons.pin),
                      onTap: () {
                        setPIN();
                      },
                    ),
                    ListTile(
                      title: const Text('Password'),
                      leading: const Icon(Icons.password),
                      onTap: () {},
                    ),
                    ListTile(
                      title: const Text('Fingerprint'),
                      leading: const Icon(Icons.fingerprint),
                      onTap: () {},
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('OR'),
                      ],
                    ),
                    ListTile(
                      title: const Text('Use device unlock credential'),
                      leading: const Icon(Icons.phonelink_lock_rounded),
                      onTap: () {},
                    ),
                  ],
                )),
    );
  }
}
