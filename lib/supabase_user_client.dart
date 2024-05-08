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
          .update({'has_avatar': true})
          .eq('id', userId)
          // This is a hack to workaround the fact that the supabase API
          // is very difficult to mock. Without the `whenComplete`, it becomes
          // very difficult to test the `saveAvatarFile` method because `PostgrestFilterBuilder`
          // implements `Future` and we can't easily stub an `await` call.
          // Another option would be to avoid using `pkg:mocktail` and to
          // mock the networking layer with a local http server.
          // See https://github.com/supabase/supabase-flutter/blob/main/packages/supabase/test/mock_test.dart
          // Related issues:
          // * https://github.com/supabase/supabase-flutter/issues/36
          // * https://github.com/supabase/supabase-flutter/issues/864
          .whenComplete(() {});
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(
        SupabaseSaveAvatarFailure(error),
        stackTrace,
      );
    }
  }
}
