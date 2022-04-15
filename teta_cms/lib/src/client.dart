import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:teta_cms/teta_cms.dart';

class TetaClient {
  TetaClient(this.token);
  final String token;

  /// Creates a new collection with name [collectionName] and prj_id [projectId].
  ///
  /// Throws an exception on request error ( statusCode != 200 )
  ///
  /// Returns the created collection as `Map<String,dynamic`
  Future<Map<String, dynamic>> createCollection(
    final int projectId,
    final String collectionName,
  ) async {
    final uri =
        Uri.parse('https://public.teta.so:9840/cms/$projectId/$collectionName');

    final res = await http.post(
      uri,
      headers: {'authorization': 'Bearer $token'},
    );

    if (res.statusCode != 200) {
      throw Exception('createCollection returned status ${res.statusCode}');
    }

    final data = json.encode(res.body) as Map<String, dynamic>;

    return data;
  }

  /// Deletes the collection with id [collectionId] if prj_id is [projectId].
  ///
  /// Throws an exception on request error ( statusCode != 200 )
  ///
  /// Returns `true` on success
  Future<bool> deleteCollection(
    final int projectId,
    final String collectionId,
  ) async {
    final uri =
        Uri.parse('https://public.teta.so:9840/cms/$projectId/$collectionId');

    final res = await http.delete(
      uri,
      headers: {
        'authorization': 'Bearer $token',
      },
    );

    if (res.statusCode != 200) {
      throw Exception('deleteDocument returned status ${res.statusCode}');
    }

    return true;
  }

  /// Inserts the document [document] on [collectionId] if prj_id is [projectId].
  ///
  /// Throws an exception on request error ( statusCode != 200 )
  ///
  /// Returns `true` on success
  Future<bool> insertDocument(
    final int projectId,
    final String collectionId,
    final Map<String, dynamic> document,
  ) async {
    final uri =
        Uri.parse('https://public.teta.so:9840/cms/$projectId/$collectionId');

    final res = await http.put(
      uri,
      headers: {
        'content-type': 'application/json',
        'authorization': 'Bearer $token',
      },
      body: json.encode(document),
    );

    if (res.statusCode != 200) {
      throw Exception('insertDocument returned status ${res.statusCode}');
    }

    return true;
  }

  /// Deletes the document with id [documentId] on [collectionId] if prj_id is [projectId].
  ///
  /// Throws an exception on request error ( statusCode != 200 )
  ///
  /// Returns `true` on success
  Future<bool> deleteDocument(
    final int projectId,
    final String collectionId,
    final String documentId,
  ) async {
    final uri = Uri.parse(
      'https://public.teta.so:9840/cms/$projectId/$collectionId/$documentId',
    );

    final res = await http.delete(
      uri,
      headers: {
        'authorization': 'Bearer $token',
      },
    );

    if (res.statusCode != 200) {
      throw Exception('deleteDocument returned status ${res.statusCode}');
    }

    return true;
  }

  /// Gets the collection with id [collectionId] if prj_id is [projectId].
  ///
  /// Throws an exception on request error ( statusCode != 200 )
  ///
  /// Returns the collection as `Map<String,dynamic>`
  Future<List<dynamic>> getCollection(
    final int projectId,
    final String collectionId,
  ) async {
    final uri =
        Uri.parse('https://public.teta.so:9840/cms/$projectId/$collectionId');

    final res = await http.get(
      uri,
      headers: {'authorization': 'Bearer $token'},
    );

    if (res.statusCode != 200) {
      throw Exception('getCollection returned status ${res.statusCode}');
    }

    final data = json.encode(res.body) as Map<String, dynamic>;

    final docs = data['docs'] as List<dynamic>;

    return docs;
  }

  /// Gets all collection where prj_id is [projectId].
  ///
  /// Throws an exception on request error ( statusCode != 200 )
  ///
  /// Returns the collections as `List<Map<String,dynamic>>` without `docs`
  Future<List<CollectionObject>> getCollections(
    final int projectId,
  ) async {
    final uri = Uri.parse('https://public.teta.so:9840/cms/$projectId');

    final res = await http.get(
      uri,
      headers: {'authorization': 'Bearer $token'},
    );

    if (res.statusCode != 200) {
      throw Exception('getCollections returned status ${res.statusCode}');
    }

    final data = json.encode(res.body) as List<dynamic>;

    return data
        .map(
          (final dynamic e) =>
              CollectionObject.fromJson(json: e as Map<String, dynamic>),
        )
        .toList();
  }

  /// Updates the collection [collectionId] with [name] if prj_id is [projectId].
  ///
  /// Throws an exception on request error ( statusCode != 200 )
  ///
  /// Returns the updated collection as `Map<String,dynamic>`
  Future<bool> updateCollection(
    final int projectId,
    final String collectionId,
    final String name,
  ) async {
    final uri =
        Uri.parse('https://public.teta.so:9840/cms/$projectId/$collectionId');

    final res = await http.patch(
      uri,
      headers: {
        'content-type': 'application/json',
        'authorization': 'Bearer $token',
      },
      body: json.encode(<String, dynamic>{
        'name': name,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('updateCollection returned status ${res.statusCode}');
    }

    return true;
  }

  /// Updates the document with id [documentId] on [collectionId] with [content] if prj_id is [projectId].
  ///
  /// Throws an exception on request error ( statusCode != 200 )
  ///
  /// Returns `true` on success
  Future<bool> updateDocument(
    final int projectId,
    final String collectionId,
    final String documentId,
    final Map<String, dynamic> content,
  ) async {
    final uri = Uri.parse(
      'https://public.teta.so:9840/cms/$projectId/$collectionId/$documentId',
    );

    final res = await http.put(
      uri,
      headers: {
        'content-type': 'application/json',
        'authorization': 'Bearer $token',
      },
      body: json.encode(content),
    );

    if (res.statusCode != 200) {
      throw Exception('updateDocument returned status ${res.statusCode}');
    }

    return true;
  }
}