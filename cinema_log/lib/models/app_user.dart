import 'package:firebase_auth/firebase_auth.dart';
import '../models/media.dart';


class AppUser{
  User? uid = null;
  String? email = '';
  String? fullName = '';
  String? age = '';
  List<List> mediaLists = [];
  List<Media> watchHistory = [];

  AppUser.anonymous();
  AppUser.creation(this.uid, this.email, this.fullName,  this.age);
  
  bool watchHistoryNotEmpty(){
    return watchHistory.isNotEmpty;
  }

  
}
