/// VALIDADOR del microservicio de ahorro.
///
/// Esta capa se encarga de revisar que el JSON que llega por HTTP tenga la
/// forma correcta y datos coherentes (números no negativos, campos
/// obligatorios presentes, etc.) ANTES de convertirlo en objetos de dominio
/// y pasárselo al servicio. Así el servicio nunca tiene que preocuparse por
/// datos corruptos o incompletos.
library savings_validator;

import '../services/savings_service.dart';

/// Se lanza cuando la solicitud no cumple las reglas de validación.
/// El endpoint la captura y responde 400 con el mensaje.
class ValidationException implements Exception {
  final String mensaje;
  ValidationException(this.mensaje);

  @override
  String toString() => mensaje;
}

class SavingsValidator {
  /// Valida el payload crudo recibido en POST /ahorro y, si todo está
  /// correcto, devuelve la lista de [FoodItem] lista para el servicio.
  /// Si algo está mal, lanza [ValidationException].
  static List<FoodItem> validarPayload(Map<String, dynamic> payload) {
    if (!payload.containsKey('items')) {
      throw ValidationException('El campo "items" es obligatorio');
    }

    final rawItems = payload['items'];
    if (rawItems is! List) {
      throw ValidationException('"items" debe ser una lista');
    }

    if (rawItems.isEmpty) {
      throw ValidationException('La lista de items no puede estar vacía');
    }

    final items = <FoodItem>[];
    for (var i = 0; i < rawItems.length; i++) {
      final raw = rawItems[i];
      if (raw is! Map) {
        throw ValidationException('El item en la posición $i no es un objeto válido');
      }
      items.add(_validarItem(Map<String, dynamic>.from(raw), i));
    }

    return items;
  }

  static FoodItem _validarItem(Map<String, dynamic> item, int indice) {
    _requerirCampo(item, 'nombre', indice);
    _requerirCampo(item, 'cantidad', indice);
    _requerirCampo(item, 'precioUnitario', indice);
    _requerirCampo(item, 'precioComidaEquivalente', indice);

    final nombre = item['nombre'];
    if (nombre is! String || nombre.trim().isEmpty) {
      throw ValidationException(
          'El item $indice: "nombre" debe ser un texto no vacío');
    }

    final cantidad = _comoNumeroPositivo(item['cantidad'], 'cantidad', indice);
    final precioUnitario =
        _comoNumeroPositivo(item['precioUnitario'], 'precioUnitario', indice);
    final precioComidaEquivalente = _comoNumeroPositivo(
        item['precioComidaEquivalente'], 'precioComidaEquivalente', indice);

    return FoodItem(
      nombre: nombre,
      cantidad: cantidad,
      precioUnitario: precioUnitario,
      precioComidaEquivalente: precioComidaEquivalente,
    );
  }

  static void _requerirCampo(Map<String, dynamic> item, String campo, int indice) {
    if (!item.containsKey(campo) || item[campo] == null) {
      throw ValidationException('El item $indice: falta el campo "$campo"');
    }
  }

  static double _comoNumeroPositivo(dynamic valor, String campo, int indice) {
    if (valor is! num) {
      throw ValidationException('El item $indice: "$campo" debe ser numérico');
    }
    if (valor < 0) {
      throw ValidationException('El item $indice: "$campo" no puede ser negativo');
    }
    return valor.toDouble();
  }
}
