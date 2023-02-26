import 'dart:async';

import 'package:teta_cms/src/data_stores/local/server_request_metadata_store.dart';
import 'package:teta_cms/src/database/collection_actions.dart';
import 'package:teta_cms/src/database/document_query.dart';
import 'package:teta_cms/src/models/stream_actions.dart';
import 'package:teta_cms/teta_cms.dart';

class TetaCollectionQuery {
  TetaCollectionQuery(
    this._serverRequestMetadata, {
    this.id,
    this.name,
  })  : _coll = TetaCollectionActions(_serverRequestMetadata),
        _realtime = TetaRealtime(_serverRequestMetadata);

  final String? id;
  final String? name;

  final TetaCollectionActions _coll;
  final TetaRealtime _realtime;

  ///This stores the token and project id headers.
  final ServerRequestMetadataStore _serverRequestMetadata;

  TetaDocumentQuery doc(final String id) {
    assert(
      name != null && this.id == null || name == null && this.id != null,
      'Only oe between name and id must be not null',
    );
    return TetaDocumentQuery(
      id,
      _serverRequestMetadata,
      collectionId: this.id,
      collectionName: name,
    );
  }

  Future<TetaResponse<Map<String, dynamic>?, TetaErrorResponse?>>
      delete() async {
    if (name == null && id == null) {
      return TetaResponse(
        data: null,
        error: TetaErrorResponse(
          message:
              'Call .select() choosing one between id and name before this.',
        ),
      );
    } else if (name != null) {
      return _coll.deleteCollectionByName(name!);
    } else {
      return _coll.deleteCollection(id!);
    }
  }

  Future<TetaResponse<List<dynamic>?, TetaErrorResponse?>> get({
    final List<Filter> filters = const [],
    final int page = 0,
    final int limit = 20,
    final bool showDrafts = false,
  }) async {
    if (name == null && id == null) {
      return TetaResponse(
        data: null,
        error: TetaErrorResponse(
          message:
              'Call .select() choosing one between id and name before this.',
        ),
      );
    } else if (name != null) {
      return _coll.getCollectionByName(name!);
    } else {
      return _coll.getCollection(id!);
    }
  }

  StreamController<List<dynamic>> stream({
    final StreamAction action = StreamAction.all,
    final List<Filter> filters = const [],
    final int page = 0,
    final int limit = 20,
    final bool showDrafts = false,
  }) {
    if (name == null && id == null) {
      throw Exception(
        'Call .select() choosing one between id and name before this.',
      );
    } else if (name != null) {
      return _realtime.streamCollectionByName(
        name!,
        action: action,
        filters: filters,
        page: page,
        limit: limit,
        showDrafts: showDrafts,
      );
    } else {
      return _realtime.streamCollection(
        id!,
        action: action,
        filters: filters,
        page: page,
        limit: limit,
        showDrafts: showDrafts,
      );
    }
  }

  Future<RealtimeHandler> on({
    final StreamAction action = StreamAction.all,
    final dynamic Function(SocketChangeEvent)? callback,
  }) {
    if (name == null && id == null) {
      throw Exception(
        'Call .select() choosing one between id and name before this.',
      );
    } else if (name != null) {
      return _realtime.on(
        action: action,
        collectionName: name,
        callback: callback,
      );
    } else {
      return _realtime.on(
        action: action,
        collectionId: id,
        callback: callback,
      );
    }
  }

  Future<int> count({
    final List<Filter> filters = const [],
    final int page = 0,
    final int limit = 20,
    final bool showDrafts = false,
  }) async {
    if (name == null && id == null) {
      Exception(
        'Call .select() choosing one between id and name before this.',
      );
      return 0;
    } else if (name != null) {
      return _coll.getCollectionCountByName(name!);
    } else {
      return _coll.getCollectionCount(id!);
    }
  }

  /// Updates the collection [collectionId] with [name] if prj_id is [prjId].
  ///
  /// Throws an exception on request error ( statusCode != 200 )
  ///
  /// Returns the updated collection as `Map<String,dynamic>`
  Future<TetaResponse<Map<String, dynamic>?, TetaErrorResponse?>> update(
    final String name,
    final Map<String, dynamic>? attributes,
  ) async {
    if (this.name == null && id == null) {
      return TetaResponse(
        data: null,
        error: TetaErrorResponse(
          message:
              'Call .select() choosing one between id and name before this.',
        ),
      );
    } else if (this.name != null) {
      return _coll.updateCollectionByName(this.name!, name, attributes);
    } else {
      return _coll.updateCollection(id!, name, attributes);
    }
  }

  /// Inserts the document [document] on [collectionName] if prj_id is [prjId].
  ///
  /// Throws an exception on request error ( statusCode != 200 )
  ///
  /// Returns `true` on success
  Future<TetaResponse<Map<String, dynamic>?, TetaErrorResponse?>> insert(
    final Map<String, dynamic> document,
  ) async {
    if (name == null && id == null) {
      return TetaResponse(
        data: null,
        error: TetaErrorResponse(
          message:
              'Call .select() choosing one between id and name before this.',
        ),
      );
    } else if (name != null) {
      return _coll.insertDocumentByCollName(name!, document);
    } else {
      return _coll.insertDocument(id!, document);
    }
  }
}