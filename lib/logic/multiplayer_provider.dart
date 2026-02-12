import 'package:firebase_database/firebase_database.dart';

class MultiplayerProvider {
  static final MultiplayerProvider _instance = MultiplayerProvider._internal();
  factory MultiplayerProvider() => _instance;
  MultiplayerProvider._internal();

  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  Future<void> createRoom(String code) async {
    await _dbRef.child('rooms').child(code).set({
      'status': 'waiting',
      'lastMove': '',
      'turn': 'white',
      'createdAt': ServerValue.timestamp,
    });
  }

  Future<bool> joinRoom(String code) async {
    final snapshot = await _dbRef.child('rooms').child(code).get();
    if (snapshot.exists) {
      await _dbRef.child('rooms').child(code).update({
        'status': 'playing',
      });
      return true;
    }
    return false;
  }

  Future<void> makeMove(
      String code,
      String move,
      String nextTurn,
      {bool gameOver = false, String winner = ''}
      ) async {
    await _dbRef.child('rooms').child(code).update({
      'lastMove': move,
      'turn': nextTurn,
      'gameOver': gameOver,
      'winner': winner,
    });
  }

  Stream<DatabaseEvent> getRoomStream(String code) {
    return _dbRef.child('rooms').child(code).onValue;
  }

  Future<String?> findWaitingRoom() async {
    final snapshot = await _dbRef
        .child('rooms')
        .orderByChild('status')
        .equalTo('waiting')
        .limitToFirst(1)
        .get();
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      return data.keys.first;
    }
    return null;
  }

  Future<Map<String, dynamic>> joinOnlineMatch() async {
    print("Searching for waiting room...");
    final waitingRoom = await findWaitingRoom();
    print("Waiting room found: $waitingRoom");
    if (waitingRoom != null) {
      print("Joining existing room");
      await _dbRef.child('rooms').child(waitingRoom).update({
        'status': 'playing',
      });
      return {
        'roomId': waitingRoom,
        'isCreator': false,
      };
    } else {
      print("Creating new room");
      final roomRef = _dbRef.child('rooms').push();
      await roomRef.set({
        'status': 'waiting',
        'lastMove': '',
        'turn': 'white',
        'createdAt': ServerValue.timestamp,
      });
      return {
        'roomId': roomRef.key!,
        'isCreator': true,
      };
    }
  }

  Future<void> removeRoom(String code) async {
    await _dbRef.child('rooms').child(code).remove();
  }
}
