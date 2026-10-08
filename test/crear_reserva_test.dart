import 'package:flutter_test/flutter_test.dart';
import 'package:reservas_sala/domain/crear_reserva.dart';
import 'package:reservas_sala/domain/reserva.dart';

import 'support/reservas_en_memoria.dart';

DateTime hora(int h, [int m = 0]) => DateTime(2026, 10, 14, h, m);

void main() {
  late ReservasEnMemoria repositorio;
  late CrearReserva crearReserva;

  setUp(() {
    repositorio = ReservasEnMemoria();
    crearReserva = CrearReserva(repositorio);
  });

  test('acepta una reserva válida y la guarda', () async {
    final resultado = await crearReserva(SolicitudReserva(
      salaId: 'Sala A',
      usuarioId: 'u1',
      inicio: hora(9),
      fin: hora(10),
    ));

    expect(resultado.aceptada, isTrue);
    expect(repositorio.reservas, hasLength(1));
  });

  test('rechaza una reserva cuyo fin no es posterior al inicio', () async {
    final resultado = await crearReserva(SolicitudReserva(
      salaId: 'Sala A',
      usuarioId: 'u1',
      inicio: hora(10),
      fin: hora(9),
    ));

    expect(resultado.aceptada, isFalse);
    expect(resultado.mensaje, 'La hora de fin debe ser posterior a la de inicio');
    expect(repositorio.reservas, isEmpty);
  });

  test('rechaza una reserva que se solapa con la de otro usuario', () async {
    await repositorio.guardar(SolicitudReserva(
      salaId: 'Sala A',
      usuarioId: 'u2',
      inicio: hora(9),
      fin: hora(10),
    ));

    final resultado = await crearReserva(SolicitudReserva(
      salaId: 'Sala A',
      usuarioId: 'u1',
      inicio: hora(0),
      fin: hora(10),
    ));

    expect(resultado.aceptada, isFalse);
    expect(
      resultado.mensaje,
      'Error en la reserva: Sala ya reservada en ese intervalo de tiempo',
    );
    expect(repositorio.reservas, hasLength(1));
  });

  test('registra una sola reserva si el usuario envía dos veces la solicitud', () async {
    final solicitud = SolicitudReserva(
      salaId: 'Sala A',
      usuarioId: 'u1',
      inicio: hora(11),
      fin: hora(12),
    );

    final primera = await crearReserva(solicitud);
    await crearReserva(solicitud);

    expect(primera.aceptada, isTrue);
    expect(repositorio.reservas, hasLength(1));
    expect(repositorio.reservas.single.usuarioId, 'u1');
  });

  test('conserva la reserva existente si el usuario intenta repetirla', () async {
    final solicitud = SolicitudReserva(
      salaId: 'Sala A',
      usuarioId: 'u1',
      inicio: hora(13),
      fin: hora(14),
    );
    final existente = await repositorio.guardar(solicitud);

    await crearReserva(solicitud);

    expect(repositorio.reservas, hasLength(1));
    expect(repositorio.reservas.single.id, existente.id);
  });
}
