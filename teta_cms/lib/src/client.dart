import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:teta_cms/src/utils.dart';
import 'package:teta_cms/teta_cms.dart';

class TetaClient {
  TetaClient(
    this.token,
    this.prjId,
  );
  final String token;
  final int prjId;

  Map<String, String> get countHeader => {'cms-count-only': '1'};

  /// Creates a new collection with name [collectionName] and prj_id [prjId].
  ///
  /// Throws an exception on request error ( statusCode != 200 )
  ///
  /// Returns the created collection as `Map<String,dynamic`
  Future<Map<String, dynamic>> createCollection(
    final String collectionName,
  ) async {
    final uri = Uri.parse(
      '${U.baseUrl}cms/$prjId/$collectionName',
    );

    final res = await http.post(
      uri,
      headers: {'authorization': 'Bearer $token'},
    );

    TetaCMS.log('createCollection: ${res.body}');

    if (res.statusCode != 200) {
      throw Exception('createCollection returned status ${res.statusCode}');
    }

    final data = json.decode(res.body) as Map<String, dynamic>;

    return data;
  }

  /// Deletes the collection with id [collectionId] if prj_id is [prjId].
  ///
  /// Throws an exception on request error ( statusCode != 200 )
  ///
  /// Returns `true` on success
  Future<bool> deleteCollection(
    final String collectionId,
  ) async {
    final uri = Uri.parse(
      '${U.baseUrl}cms/$prjId/$collectionId',
    );

    final res = await http.delete(
      uri,
      headers: {
        'authorization': 'Bearer $token',
      },
    );

    TetaCMS.log('deleteCollection: ${res.body}');

    if (res.statusCode != 200) {
      throw Exception('deleteDocument returned status ${res.statusCode}');
    }

    return true;
  }

  /// Inserts the document [document] on [collectionId] if prj_id is [prjId].
  ///
  /// Throws an exception on request error ( statusCode != 200 )
  ///
  /// Returns `true` on success
  Future<bool> insertDocument(
    final String collectionId,
    final Map<String, dynamic> document,
  ) async {
    final uri = Uri.parse(
      '${U.baseUrl}cms/$prjId/$collectionId',
    );

    final res = await http.put(
      uri,
      headers: {
        'content-type': 'application/json',
        'authorization': 'Bearer $token',
      },
      body: json.encode(document),
    );

    TetaCMS.log('insertDocument: ${res.body}');

    if (res.statusCode != 200) {
      throw Exception('insertDocument returned status ${res.statusCode}');
    }

    return true;
  }

  /// Deletes the document with id [documentId] on [collectionId] if prj_id is [prjId].
  ///
  /// Throws an exception on request error ( statusCode != 200 )
  ///
  /// Returns `true` on success
  Future<bool> deleteDocument(
    final String collectionId,
    final String documentId,
  ) async {
    final uri = Uri.parse(
      '${U.baseUrl}cms/$prjId/$collectionId/$documentId',
    );

    final res = await http.delete(
      uri,
      headers: {
        'authorization': 'Bearer $token',
      },
    );

    TetaCMS.log('deleteDocument: ${res.body}');

    if (res.statusCode != 200) {
      throw Exception('deleteDocument returned status ${res.statusCode}');
    }

    return true;
  }

  /// Gets the collection with id [collectionId] if prj_id is [prjId].
  ///
  /// Throws an exception on request error ( statusCode != 200 )
  ///
  /// Returns the collection as `Map<String,dynamic>`
  Future<List<dynamic>> getCollection(
    final String collectionId, {
    final List<Filter> filters = const [],
    final int page = 0,
    final int limit = 20,
    final bool showDrafts = false,
  }) async {
    final finalFilters = [
      ...filters,
      if (!showDrafts) Filter('_vis', 'public'),
    ];
    final uri = Uri.parse('${U.baseUrl}cms/$prjId/$collectionId');

    final res = await http.get(
      uri,
      headers: {
        'authorization': 'Bearer $token',
        'cms-filters':
            json.encode(finalFilters.map((final e) => e.toJson()).toList()),
        'cms-pagination': json.encode(<String, dynamic>{
          'page': page,
          'pageElems': limit,
        }),
      },
    );

    TetaCMS.log('getCollection: ${res.body}');

    if (res.statusCode != 200) {
      throw Exception('getCollection returned status ${res.statusCode}');
    }

    final data = json.decode(res.body) as Map<String, dynamic>;

    final docs = data['docs'] as List<dynamic>;

    return docs;
  }

  /// Gets the collection with id [collectionId] if prj_id is [prjId].
  ///
  /// Throws an exception on request error ( statusCode != 200 )
  ///
  /// Returns the collection as `Map<String,dynamic>`
  Future<int> getCollectionCount(
    final String collectionId, {
    final List<Filter> filters = const [],
    final int page = 0,
    final int limit = 20,
    final bool showDrafts = false,
  }) async {
    final finalFilters = [
      ...filters,
      if (!showDrafts) Filter('_vis', 'public'),
    ];
    final uri = Uri.parse('${U.baseUrl}cms/$prjId/$collectionId');

    final res = await http.get(
      uri,
      headers: {
        'authorization': 'Bearer $token',
        'cms-filters':
            json.encode(finalFilters.map((final e) => e.toJson()).toList()),
        'cms-pagination': json.encode(<String, dynamic>{
          'page': page,
          'pageElems': limit,
        }),
        ...countHeader,
      },
    );

    if (res.statusCode != 200) {
      throw Exception('getCollection returned status ${res.statusCode}');
    }

    final data = json.decode(res.body) as Map<String, dynamic>;

    final count = data['count'] as int? ?? 0;

    return count;
  }

  /// Gets all collection where prj_id is [prjId].
  ///
  /// Throws an exception on request error ( statusCode != 200 )
  ///
  /// Returns the collections as `List<Map<String,dynamic>>` without `docs`
  Future<List<CollectionObject>> getCollections() async {
    final uri = Uri.parse('${U.baseUrl}cms/$prjId');

    final res = await http.get(
      uri,
      headers: {
        'authorization': 'Bearer $token',
      },
    );

    TetaCMS.log('getCollections: ${res.body}');

    if (res.statusCode != 200) {
      throw Exception('getCollections returned status ${res.statusCode}');
    }

    final data = json.decode(res.body) as List<dynamic>;

    TetaCMS.log('getCollections data: $data');

    final list = data
        .map(
          (final dynamic e) =>
              CollectionObject.fromJson(json: e as Map<String, dynamic>),
        )
        .toList();

    TetaCMS.log('getCollections list: $list');

    return list;
  }

  /// Updates the collection [collectionId] with [name] if prj_id is [prjId].
  ///
  /// Throws an exception on request error ( statusCode != 200 )
  ///
  /// Returns the updated collection as `Map<String,dynamic>`
  Future<bool> updateCollection(
    final String collectionId,
    final String name,
  ) async {
    final uri = Uri.parse(
      '${U.baseUrl}cms/$prjId/$collectionId',
    );

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

    TetaCMS.log(res.body);

    if (res.statusCode != 200) {
      throw Exception('updateCollection returned status ${res.statusCode}');
    }

    return true;
  }

  /// Updates the document with id [documentId] on [collectionId] with [content] if prj_id is [prjId].
  ///
  /// Throws an exception on request error ( statusCode != 200 )
  ///
  /// Returns `true` on success
  Future<bool> updateDocument(
    final String collectionId,
    final String documentId,
    final Map<String, dynamic> content,
  ) async {
    final uri = Uri.parse(
      '${U.baseUrl}cms/$prjId/$collectionId/$documentId',
    );

    final res = await http.put(
      uri,
      headers: {
        'content-type': 'application/json',
        'authorization': 'Bearer $token',
      },
      body: json.encode(content),
    );

    TetaCMS.log(res.body);

    if (res.statusCode != 200) {
      throw Exception('updateDocument returned status ${res.statusCode}');
    }

    return true;
  }

  Future customQuery(
    final String collectionId, {
    required final String query,
  }) async {
    final uri = Uri.parse('${U.baseUrl}cms/$prjId/$collectionId/raw');

    final res = await http.post(
      uri,
      headers: {
        'authorization': 'Bearer $token',
        'content-type': 'application/json',
      },
      body: query,
    );

    TetaCMS.log('getCollection: ${res.body}');

    if (res.statusCode != 200) {
      throw Exception('getCollection returned status ${res.statusCode}');
    }

    final data = json.decode(res.body) as Map<String, dynamic>;

    final docs = data['docs'] as List<dynamic>;

    return docs;
  }
}
