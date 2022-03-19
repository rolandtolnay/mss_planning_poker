import 'package:flutter/material.dart';
import 'package:mss_planning_poker/domain/auth/user_entity.dart';
import 'package:mss_planning_poker/domain/rooms/room_repository.dart';

import '../domain/auth/auth_repository.dart';
import '../injectable/injectable.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _authRepository = getIt<AuthRepository>();

  @override
  void initState() {
    super.initState();

    _authRepository.signInAnonymously();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: StreamBuilder<UserEntity?>(
          stream: _authRepository.onUserChanged,
          builder: (context, snapshot) {
            if (snapshot.hasError) return Text('Error occured');
            if (!snapshot.hasData) return CircularProgressIndicator();

            final user = snapshot.data!;
            return Column(
              children: [
                const Spacer(),
                Text('User id: ${user.id}'),
                const SizedBox(height: 16),
                if (user.displayName == null)
                  Text('User has no name.')
                else
                  Text('User display name: ${user.displayName}.'),
                const Spacer(),
                ElevatedButton(
                  onPressed: () async {
                    await getIt<RoomRepository>().createRoom(admin: user);
                  },
                  child: Text('Create room'),
                ),
                const Spacer(),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _authRepository.updateDisplayName('Roland');
        },
        tooltip: 'Set name',
        child: const Icon(Icons.person),
      ),
    );
  }
}
