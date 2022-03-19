import 'package:flutter/material.dart';
import 'package:mss_planning_poker/domain/rooms/models/room_entity.dart';

import '../../domain/rooms/room_repository.dart';
import '../../injectable/injectable.dart';

class RoomParticipantsList extends StatelessWidget {
  final String roomId;

  final _roomRepository = getIt<RoomRepository>();

  RoomParticipantsList({required this.roomId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<RoomEntity?>(
      stream: _roomRepository.onRoomUpdated(id: roomId),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text('Error occured'));
        if (!snapshot.hasData) return CircularProgressIndicator();

        final room = snapshot.data!;
        return ListView.builder(
          itemCount: room.participants.length,
          itemBuilder: (_, index) {
            final user = room.participants[index];
            return ListTile(title: Text(user.displayName));
          },
        );
      },
    );
  }
}
