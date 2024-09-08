import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';




// Provider for ProfileNotifier
final profileProvider = StateNotifierProvider<ProfileNotifier, bool>(
      (ref) => ProfileNotifier(),
);



// StateNotifier to manage the isEditing state
class ProfileNotifier extends StateNotifier<bool> {
  ProfileNotifier() : super(false);

  // Toggle editing state
  void toggleEditing() {
    state = !state;
  }

  // Reset editing state to false
  void resetEditing() {
    state = false;
  }
}

