import 'reserva.dart';
import 'reservas_repository.dart';

class CrearReserva {
  CrearReserva(this.repositorio);

  final ReservasRepository repositorio;

  Future<ResultadoReserva> call(SolicitudReserva solicitud) async {
    if (!solicitud.fin.isAfter(solicitud.inicio)) {
      return ResultadoReserva.rechazada(
        'La hora de fin debe ser posterior a la de inicio',
      );
    }

    final reservas = await repositorio.reservasDeSala(solicitud.salaId);

    for (final existente in reservas) {
      final mismaReserva = existente.usuarioId == solicitud.usuarioId &&
          existente.inicio.isAtSameMomentAs(solicitud.inicio) &&
          existente.fin.isAtSameMomentAs(solicitud.fin);

      if (mismaReserva) {
        return ResultadoReserva.aceptada(existente);
      }
    }

    for (final existente in reservas) {
      final seSolapan = solicitud.inicio.isBefore(existente.fin) &&
          existente.inicio.isBefore(solicitud.fin);

      if (seSolapan) {
        return ResultadoReserva.rechazada(
          'Error en la reserva: Sala ya reservada en ese intervalo de tiempo',
        );
      }
    }

    final reserva = await repositorio.guardar(solicitud);
    return ResultadoReserva.aceptada(reserva);
  }
}
