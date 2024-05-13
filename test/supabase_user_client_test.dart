import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_mocktail_testing/supabase_user_client.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder {}

class MockUser extends Mock implements User {}

class FakeFile extends Fake implements File {}

void main() {
  late SupabaseClient supabaseClient;
  late GoTrueClient auth;
  late User user;
  late SupabaseUserClient userClient;

  setUp(() {
    supabaseClient = MockSupabaseClient();
    auth = MockGoTrueClient();
    user = MockUser();
    userClient = SupabaseUserClient(supabaseClient: supabaseClient);
  });

  group('saveAvatarFile', () {
    const table = 'users';
    const userId = 'test-user-id';

    late MockSupabaseQueryBuilder updateSupabaseQueryBuilder;
    late PostgrestFilterBuilder updatePostgrestFilterBuilder;
    late PostgrestFilterBuilder eqPostgrestFilterBuilder;

    setUp(() {
      updateSupabaseQueryBuilder = MockSupabaseQueryBuilder();
      updatePostgrestFilterBuilder = MockPostgrestFilterBuilder();
      eqPostgrestFilterBuilder = MockPostgrestFilterBuilder();

      when(
        () => supabaseClient.from(any()),
      ).thenAnswer((_) => updateSupabaseQueryBuilder);
      when(() => supabaseClient.auth).thenReturn(auth);
      when(() => auth.currentUser).thenReturn(user);
      when(() => user.id).thenReturn(userId);
      when(
        () => updateSupabaseQueryBuilder.update(any()),
      ).thenAnswer((_) => updatePostgrestFilterBuilder);
      when(
        () => updatePostgrestFilterBuilder.eq(any(), any()),
      ).thenAnswer((_) => eqPostgrestFilterBuilder);
      when(
        () => eqPostgrestFilterBuilder.whenComplete(any()),
      ).thenAnswer((_) async => null);
    });

    test('completes', () async {
      await userClient.saveAvatarFile(FakeFile());
      verifyInOrder([
        () => supabaseClient.from(table),
        () => updateSupabaseQueryBuilder.update({'has_avatar': true}),
        () => updatePostgrestFilterBuilder.eq('id', userId),
      ]);
    });
  });
}
