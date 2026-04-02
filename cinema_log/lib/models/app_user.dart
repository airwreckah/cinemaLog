import 'package:firebase_auth/firebase_auth.dart';
import '../models/media.dart';

class AppUser {
  String? uid;
  String? email = '';
  String? fullName = '';
  String? age = '';
  List<List> mediaLists = [];
  List<Media> watchHistory = [];

  //blank user for start-up
  AppUser.anonymous();
  //actual constructor
  AppUser.creation(this.uid, this.email, this.fullName, this.age);

  bool watchHistoryNotEmpty() {
    return watchHistory.isNotEmpty;
  }
}
