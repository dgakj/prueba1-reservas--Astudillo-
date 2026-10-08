## Escenarios que elegí y por qué

Elegí el primer escenario porque dos usuarios pueden solicitar la misma sala en horarios que coinciden: la especificación describe una reserva previa de la sala A y otra solicitud que se solapa con ella (specs/001-reservas-sala/spec.md:24 y specs/001-reservas-sala/spec.md:25 muestran ambas solicitudes). La prueba registra primero la reserva de otro usuario y exige que la nueva se rechace sin crear una segunda (test/crear_reserva_test.dart:44, test/crear_reserva_test.dart:58 y test/crear_reserva_test.dart:63 muestran la preparación y las aserciones).

Elegí los otros dos escenarios porque un estudiante puede enviar dos veces la misma solicitud o repetirla después de que ya se registró (specs/001-reservas-sala/spec.md:27 y specs/001-reservas-sala/spec.md:30 distinguen esas situaciones). Buscan que exista una sola reserva y que se conserve la original (test/crear_reserva_test.dart:78, test/crear_reserva_test.dart:93 y test/crear_reserva_test.dart:94 comprueban la cantidad y el identificador).

## Riesgo más grave del repositorio

El riesgo más grave es una credencial incrustada en la aplicación: el JWT de lib/data/supabase_config.dart:4 contiene el rol service_role y lib/main.dart:11 muestra que se entrega al cliente de Supabase al iniciar. Si esa clave está activa, distribuirla con la app expone una credencial privilegiada fuera del servidor (lib/data/supabase_config.dart:4 muestra que está escrita directamente en el código del cliente).

## ¿La regla protege la app real?

Todavía no: el caso de uso consulta las reservas y rechaza intervalos solapados (lib/domain/crear_reserva.dart:16, lib/domain/crear_reserva.dart:29 y lib/domain/crear_reserva.dart:33 muestran la consulta y el rechazo). Sin embargo, el botón llama a _reservar (lib/presentation/reserva_page.dart:103) y ese método inserta directamente en Supabase (lib/presentation/reserva_page.dart:58 y lib/presentation/reserva_page.dart:60), aunque la página recibe el caso de uso (lib/presentation/reserva_page.dart:7). La tabla solo declara la comprobación de que el fin sea posterior al inicio (supabase/migracion.sql:11 muestra esa restricción), por lo que no impide solapamientos ni duplicados en la base (supabase/migracion.sql:4 y supabase/migracion.sql:12 delimitan la definición de la tabla). Además, la consulta y el guardado ocurren por separado (lib/domain/crear_reserva.dart:16 y lib/domain/crear_reserva.dart:39 muestran ambas operaciones), así que solicitudes simultáneas requieren una protección atómica en la base.
