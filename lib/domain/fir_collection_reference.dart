import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_odm/cloud_firestore_odm.dart';
import 'package:injectable/injectable.dart';

import 'rooms/models/room_model.dart';
import 'rooms/models/room_participant_model.dart';

part 'fir_collection_reference.g.dart';

@Collection<RoomModel>('rooms')
@Collection<RoomParticipantModel>('rooms/*/participants')
final _roomsRef = RoomModelCollectionReference();

RoomParticipantModelCollectionReference _participantsRef(String roomId) =>
    _roomsRef.doc(roomId).participants;

@Injectable()
class FirCollectionReference {
  RoomModelCollectionReference get rooms => _roomsRef;

  RoomParticipantModelCollectionReference participants(String roomId) =>
      _participantsRef(roomId);
}
