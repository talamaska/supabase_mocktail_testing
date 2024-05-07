import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

/// {@template supabase_user_exception}
/// A generic supabase user exception.
/// {@endtemplate}
abstract class SupabaseUserException implements Exception {
  /// {@macro supabase_user_exception}
  const SupabaseUserException(this.error);

  /// The error which was caught.
  final Object error;
}

/// {@template save_avatar_failure}
/// Thrown during saving an avatar if a failure occurs.
/// {@endtemplate}
class SupabaseSaveAvatarFailure extends SupabaseUserException {
  /// {@macro save_avatar_failure}
  const SupabaseSaveAvatarFailure(super.error);
}

/// {@template supabase_user_client}
/// A Very Good Project created by Very Good CLI.
/// {@endtemplate}
class SupabaseUserClient {
  /// {@macro supabase_user_client}
  const SupabaseUserClient({
    required SupabaseClient supabaseClient,
  }) : _supabaseClient = supabaseClient;

  /// supabase client
  final SupabaseClient _supabaseClient;

  /// current user id
  String get currentUserId {
    return _supabaseClient.auth.currentUser!.id;
  }

  /// Upload avatar to supabase storage
  Future<void> saveAvatarFile(File avatarFile) async {
    try {
      final userId = currentUserId;

      await _supabaseClient
          .from('users')
          .update({'has_avatar': true}).eq('id', userId);
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(
        SupabaseSaveAvatarFailure(error),
        stackTrace,
      );
    }
  }
}
