import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:polydiff/components/user_avatar.dart';
import 'package:polydiff/services/http_request_tool.dart';
import 'package:polydiff/services/image_from_server.dart';

class User {
  static String username = '';
  static late String id;
  static final StreamController<String> _usernameController =
      StreamController<String>.broadcast();
  static late String avatarFileName;
  static int dinarsAmount = 0;
  static late Container avatar;
  static late Container customAvatar;
  static late List<ConnectionHistoryEntry> connectionHistory;
  static late List<String> chatNameList;

  static late List<GameHistoryEntry> gameHistory;
  static late int totalPlayedGames;
  static late int totalWonGames;
  static late int avgFoundDifferencePerGame;
  static late int avgGameDuration;

  static bool specialErrorSoundUsed = false;
  static bool specialSuccessSoundUsed = false;

  static String get _username => username;
  static set _username(String value) {
    username = value;
    _usernameController.sink.add(username);
  }

  static Stream<String> get usernameStream => _usernameController.stream;

  static dispose() {
    _usernameController.close();
  }

  static loadData() async {
    await loadConnectionHistory();
    await loadGameHistory();
  }

  // This refreshed the users avatar from server information.
  static setAvatar(String avatarFileName) {
    User.avatarFileName = avatarFileName;
    User.avatar = AvatarImageFromServer.getAvatar(avatarFileName);
  }

  // transparent wether the user uses a custom avatar or a pre-defined.
  static Container getAvatar() {
    avatar = AvatarImageFromServer.getAvatar(avatarFileName);
    return avatar;
  }

  // To avoid lag when picture just has been taken, provide the local file wich was just taken. Otherwise, always load from server.
  static Container getCustomAvatar({File? file}) {
    if (file != null) {
      customAvatar = UserAvatar.customAvatar(Image.file(file));
    } else {
      customAvatar = AvatarImageFromServer.customAvatar('pictures/$username');
    }
    return customAvatar;
  }

  static loadConnectionHistory() async {
    var res = await HttpRequestTool.basicGet(
        'api/fs/players/$username/connection-history');
    connectionHistory = [];
    if (res.statusCode == 200) {
      for (var entry in jsonDecode(res.body)['connectionHistory']) {
        connectionHistory.add(ConnectionHistoryEntry(
          date: DateTime.parse(entry['date']),
          action: entry['action'],
        ));
      }
    }
  }

  static loadGameHistory() async {
    var res =
        await HttpRequestTool.basicGet('api/fs/players/$username/game-history');
    if (res.statusCode == 200) {
      gameHistory = [];
      var history = jsonDecode(res.body)['gameHistory'];
      for (var entry in history) {
        gameHistory.add(GameHistoryEntry(
          date: DateTime.parse(entry['date']),
          wonGame: entry['wonGame'],
        ));
      }
      totalPlayedGames = gameHistory.length;
      totalWonGames = gameHistory.where((game) => game.wonGame == true).length;

      res = await HttpRequestTool.basicGet('api/fs/players/$username/averages');
      if (res.statusCode == 200) {
        var avgDiff = jsonDecode(res.body)['averageDifferencePerGame'];
        var avgTime = jsonDecode(res.body)['averageTimePerGame'];
        avgFoundDifferencePerGame =
            avgDiff is double ? avgDiff.toInt() : avgDiff;
        avgGameDuration = avgTime is double ? avgTime.toInt() : avgTime;
      }
    }
  }
}

class ConnectionHistoryEntry {
  final DateTime date;
  final String action;
  ConnectionHistoryEntry({required this.date, required this.action});
}

class GameHistoryEntry {
  final DateTime date;
  final bool wonGame;
  GameHistoryEntry({required this.date, required this.wonGame});
}
