import 'package:flutter/material.dart';

import '../../domain/rooms/models/room_entity.dart';
import '../../domain/rooms/models/room_participant_entity.dart';
import '../../domain/rooms/participant_repository.dart';
import '../../domain/rooms/room_repository.dart';
import '../common/loading_scaffold.dart';
import 'room_participants_list.dart';
import 'room_selector_dialog.dart';

const List<String> _cards = ['?', '1', '2', '3', '5', '8', '13'];

class HomePage extends StatefulWidget {
  final String userId;

  const HomePage({required this.userId, Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<RoomEntity?>(
      future: roomRepository.findRoomForUserId(widget.userId),
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
            // TODO: Make this stateless after Riverpod
            setState(() {});
          });
          return Scaffold(body: Container());
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(room.name),
            leading: IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () => _onLeaveRoomPressed(room.id),
            ),
          ),
          body: Column(
            children: [
              Expanded(child: RoomParticipantsList(roomId: room.id)),
              SizedBox(
                height: 100,
                child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _cards
                          .map(
                            (e) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: PokerCardWidget(
                                value: e,
                                roomId: room.id,
                                userId: widget.userId,
                              ),
                            ),
                          )
                          .toList(),
                    )),
              )
            ],
          ),
        );
      },
    );
  }

  Future<void> _onLeaveRoomPressed(String roomId) async {
    await pcpRepository.leaveRoomWithId(roomId, participantId: widget.userId);
    setState(() {});
  }
}

class PokerCardWidget extends StatelessWidget {
  final String value;
  final String roomId;
  final String userId;

  const PokerCardWidget({
    required this.value,
    required this.roomId,
    required this.userId,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return SizedBox(
      height: 80,
      width: 56,
      child: StreamBuilder<RoomParticipantEntity?>(
        stream: pcpRepository.onParticipantChanged(userId, roomId: roomId),
        builder: (context, snapshot) {
          var backgroundColor = colorScheme.secondary;
          if (snapshot.data != null && snapshot.data!.selectedValue == value) {
            backgroundColor = colorScheme.error;
          }

          return TextButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith(
                (_) => backgroundColor,
              ),
            ),
            child: Text(
              value,
              style:
                  textTheme.subtitle1?.copyWith(color: colorScheme.onSecondary),
            ),
            onPressed: () {
              pcpRepository.setValue(
                value,
                roomId: roomId,
                participantId: userId,
              );
            },
          );
        },
      ),
    );
  }
}
