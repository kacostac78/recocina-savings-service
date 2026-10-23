import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_cors_headers/shelf_cors_headers.dart';

import '../lib/endpoints/savings_endpoint.dart';

void main() async {
  final endpoint = SavingsEndpoint();

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders())
      .addHandler(endpoint.router.call);

  final port = int.parse(Platform.environment['PORT'] ?? '8081');
  final server = await io.serve(handler, InternetAddress.anyIPv4, port);
  print('recocina-savings-service escuchando en el puerto ${server.port}');
}
