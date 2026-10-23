/// SERVICIO (lógica de negocio) del microservicio de ahorro.
///
/// Esta capa NO sabe nada de HTTP ni de JSON crudo — solo recibe objetos
/// [FoodItem] ya validados (ver lib/validators/savings_validator.dart) y
/// calcula cuánto se "ahorró" el usuario al cocinar en casa en vez de
/// comprar comida ya hecha. Separarla así permite probarla con pruebas
/// unitarias sin necesidad de levantar un servidor.
library savings_service;

class FoodItem {
  final String nombre;
  final double cantidad;
  final double precioUnitario; // precio estimado del ingrediente
  final double precioComidaEquivalente; // precio de comprar algo similar ya hecho

  FoodItem({
    required this.nombre,
    required this.cantidad,
    required this.precioUnitario,
    required this.precioComidaEquivalente,
  });
}

class SavingsResult {
  final double costoIngredientes;
  final double costoEquivalenteComprado;
  final double ahorroEstimado;
  final double porcentajeAhorro;

  SavingsResult({
    required this.costoIngredientes,
    required this.costoEquivalenteComprado,
    required this.ahorroEstimado,
    required this.porcentajeAhorro,
  });

  Map<String, dynamic> toJson() => {
        'costoIngredientes': costoIngredientes,
        'costoEquivalenteComprado': costoEquivalenteComprado,
        'ahorroEstimado': ahorroEstimado,
        'porcentajeAhorro': porcentajeAhorro,
      };
}

SavingsResult calcularAhorro(List<FoodItem> items) {
  final costoIngredientes = items.fold<double>(
    0,
    (sum, item) => sum + (item.cantidad * item.precioUnitario),
  );

  final costoEquivalente = items.fold<double>(
    0,
    (sum, item) => sum + item.precioComidaEquivalente,
  );

  final ahorro = costoEquivalente - costoIngredientes;
  final porcentaje =
      costoEquivalente == 0 ? 0.0 : (ahorro / costoEquivalente) * 100;

  return SavingsResult(
    costoIngredientes: costoIngredientes,
    costoEquivalenteComprado: costoEquivalente,
    ahorroEstimado: ahorro < 0 ? 0 : ahorro,
    porcentajeAhorro: porcentaje < 0 ? 0 : porcentaje,
  );
}
