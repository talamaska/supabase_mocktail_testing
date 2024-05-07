// ignore_for_file: unused_local_variable

import 'dart:async';
import 'dart:io';

import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_mocktail_testing/supabase_user_client.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class MockPostgrestFilterBuilder<T> extends Mock
    implements PostgrestFilterBuilder<T> {}

class MockPostgrestTransformBuilder extends Mock
    implements PostgrestTransformBuilder<dynamic> {}

class MockPostgrestBuilder<T, S, R> extends Mock
    implements PostgrestBuilder<T, S, R> {}

class MockSupabaseStorage extends Mock implements SupabaseStorageClient {}

class MockSupabaseStorageReference extends Mock implements StorageFileApi {}

class MockGiftStorageClient extends Mock implements StorageFileApi {}

class FakeUser extends Fake implements User {
  @override
  String id = 'id';

  @override
  Map<String, dynamic> appMetadata = {};

  @override
  Map<String, dynamic>? userMetadata = {};

  @override
  String aud = 'aud';

  @override
  String createdAt = DateTime.now().toIso8601String();
}

class FakeGoTrue extends Fake implements GoTrueClient {
  @override
  final currentUser = User(
    id: 'id',
    appMetadata: {},
    userMetadata: {},
    aud: 'aud',
    createdAt: DateTime.now().toIso8601String(),
  );
}

class FakeSupabase extends Fake implements SupabaseClient {
  @override
  GoTrueClient get auth => FakeGoTrue();
}

class FakeUpdatePostgrestResponse<T> extends Fake
    implements PostgrestResponse<T> {}

class FakePostgrestFilterBuilder extends Fake
    implements PostgrestFilterBuilder<dynamic> {
  @override
  PostgrestFilterBuilder<dynamic> eq(String column, dynamic value) {
    // Simulate delay
    Future<void>.delayed(const Duration(seconds: 2));

    // Return this instance to allow method chaining
    return this;
  }
  // TODO(talamaska): figure out a way to mock then
  // @override
  // Future<U> then<U>(
  //   FutureOr<U> Function(dynamic value) onValue, {
  //   Function? onError,
  // }) async {
  //   return onValue();
  // }

  // Override other methods as needed...
}

void main() {
  const tableName = 'gifts';

  late SupabaseClient supabaseClient;
  late GoTrueClient goTrueClient;
  late PostgrestResponse<dynamic> postgrestResponse;
  late PostgrestResponse<dynamic> updatePostgrestResponse;
  late SupabaseUserClient userClient;
  late SupabaseStorageClient supabaseStorage;
  late SupabaseQueryBuilder supabaseQueryBuilder;
  late SupabaseQueryBuilder updateSupabaseQueryBuilder;
  // late PostgrestFilterBuilder selectPostgrestFilterBuilder;
  late PostgrestFilterBuilder<dynamic> updatePostgrestFilterBuilder;
  late PostgrestFilterBuilder<dynamic> eqPostgrestFilterBuilder;
  late PostgrestTransformBuilder<dynamic> postgrestTransformBuilder;
  late PostgrestFilterBuilder<dynamic> finalPostgrestFilterBuilder;
  late StorageFileApi supabaseStorageReference;
  late MockSupabaseStorageReference supaStorageRef;
  // late PostgrestBuilder<dynamic> upsertPostgrestBuilder;
  late User user;
  final mockFile = File('file.jpg');
  final faker = Faker();

  setUpAll(() {
    supabaseClient = MockSupabaseClient();
    goTrueClient = MockGoTrueClient();
    supabaseStorage = MockSupabaseStorage();
    supabaseQueryBuilder = MockSupabaseQueryBuilder();
    updateSupabaseQueryBuilder = MockSupabaseQueryBuilder();
    updatePostgrestFilterBuilder = MockPostgrestFilterBuilder();
    eqPostgrestFilterBuilder = FakePostgrestFilterBuilder();
    finalPostgrestFilterBuilder = MockPostgrestFilterBuilder();
    postgrestTransformBuilder = MockPostgrestTransformBuilder();
    user = FakeUser();
    updatePostgrestResponse = FakeUpdatePostgrestResponse();
    supabaseStorageReference = MockSupabaseStorageReference();

    when(() => supabaseClient.auth).thenReturn(goTrueClient);
    when(() => goTrueClient.currentUser).thenReturn(user);

    when(() => supabaseClient.storage).thenReturn(supabaseStorage);

    userClient = SupabaseUserClient(
      supabaseClient: supabaseClient,
    );
  });

  group('Supabase User Client', () {
    test('can be instantiated', () {
      expect(
        SupabaseUserClient(supabaseClient: supabaseClient),
        isNotNull,
      );
    });
  });

  group('saveAvatarFile', () {

    test('completes', () async {

      // TODO(talamaska): find a way to mock response from update
      when(() => supabaseClient.from('gifts'))
          .thenAnswer((invocation) => updateSupabaseQueryBuilder);

      when(
        () => updateSupabaseQueryBuilder.update({
          'has_image': true,
        }),
      ).thenAnswer((invocation) => updatePostgrestFilterBuilder);

      when(() => updatePostgrestFilterBuilder.eq('id', 'giftId'))
          .thenAnswer((invocation) => eqPostgrestFilterBuilder);

      // when(() => eqPostgrestFilterBuilder)
      //     .thenReturn(finalPostgrestFilterBuilder);

      await userClient.saveAvatarFile(mockFile);

      // Verify that update was called with the correct parameters
      verify(
        () => supabaseClient.from('gifts').update({
          'has_image': true,
        }).eq('id', 'giftId'),
      ).called(1);

      
    });
  });
}
