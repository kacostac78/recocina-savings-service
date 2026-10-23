/// ENDPOINT del microservicio de ahorro.
///
/// Esta capa es la única que sabe de HTTP: recibe el Request, decodifica el
/// JSON, delega la validación a [SavingsValidator] y el cálculo a
/// `calcularAhorro` (servicio), y arma la Response. No contiene reglas de
/// negocio ni reglas de validación propias — solo coordina.
library savings_endpoint;

import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../services/savings_service.dart';
import '../validators/savings_validator.dart';

Response jsonResponse(Object data, {int status = 200}) {
  return Response(
    status,
    body: jsonEncode(data),
    headers: {'content-type': 'application/json'},
  );
}

class SavingsEndpoint {
  Router get router {
    final router = Router();

    router.get('/health', _health);
    router.post('/ahorro', _calcularAhorro);

    return router;
  }

  Response _health(Request req) {
    return jsonResponse({'status': 'ok', 'service': 'recocina-savings-service'});
  }

  Future<Response> _calcularAhorro(Request req) async {
    try {
      final body = await req.readAsString();
      final payload = jsonDecode(body) as Map<String, dynamic>;

      // 1) Validación
      final items = SavingsValidator.validarPayload(payload);

      // 2) Lógica de negocio (servicio)
      final resultado = calcularAhorro(items);

      // 3) Respuesta
      return jsonResponse(resultado.toJson());
    } on ValidationException catch (e) {
      return jsonResponse({'error': e.mensaje}, status: 400);
    } on FormatException {
      return jsonResponse({'error': 'El cuerpo de la solicitud no es un JSON válido'},
          status: 400);
    } catch (e) {
      return jsonResponse({'error': 'Error interno: $e'}, status: 500);
    }
  }
}
