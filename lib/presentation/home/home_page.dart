import 'package:flutter/material.dart';

import '../../domain/rooms/models/room_entity.dart';
import '../../domain/rooms/room_repository.dart';
import '../../injectable/injectable.dart';
import '../common/loading_scaffold.dart';
import 'room_participants_list.dart';
import 'room_selector_dialog.dart';

class HomePage extends StatefulWidget {
  final String userId;

  const HomePage({required this.userId, Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _roomRepository = getIt<RoomRepository>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<RoomEntity?>(
      future: _roomRepository.findRoomForUserId(widget.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return LoadingScaffold();
        }

        final room = snapshot.data;
        if (room == null) {
          WidgetsBinding.instance?.addPostFrameCallback((_) async {
            await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => RoomSelectorDialog(),
            );
            setState(() {});
          });
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(room?.name ?? 'mssPlanningPoker'),
          ),
          body: room != null
              ? RoomParticipantsList(roomId: room.id)
              : Container(),
        );
      },
    );
  }
}
