:- discontiguous regla_auxiliar/1.
:- discontiguous diagnostico/2.

% ------------------------------------------------------------
%  1. INICIALIZACIÓN DE SESIÓN
% ------------------------------------------------------------

% Limpia toda la memoria de trabajo e inicia una nueva consulta
iniciar_consulta(Cultivo) :-
    retractall(sintoma_observado(_)),
    retractall(regla_aplicada(_, _)),
    retractall(cultivo_consultado(_)),
    assertz(cultivo_consultado(Cultivo)),
    format('=== Nueva consulta iniciada para cultivo: ~w ===~n', [Cultivo]).

% ------------------------------------------------------------
%  2. PREDICADOS DE REGISTRO
% ------------------------------------------------------------

% Registra un síntoma observado durante la consulta
registrar_sintoma(Sintoma) :-
    ( sintoma_observado(Sintoma)
    -> true                          % ya estaba, no duplicar
    ;  assertz(sintoma_observado(Sintoma))
    ).

% Registra qué regla se activó (para la explicación)
% Se llama desde dentro de cada regla de diagnóstico
registrar_regla(IdRegla, Certeza) :-
    ( regla_aplicada(IdRegla, Certeza)
    -> true
    ;  assertz(regla_aplicada(IdRegla, Certeza))
    ).

% ------------------------------------------------------------
%  3. REGLAS AUXILIARES (R32–R40)
% ------------------------------------------------------------

% R32 — Severidad alta (más del 50% de la planta visible afectada)
severidad(alta) :-
    sintoma_observado(defoliacion_progresiva),
    diagnostico(_, alta_certeza).

severidad(alta) :-
    sintoma_observado(acame_prematuro).

% R33 — Severidad media
severidad(media) :-
    diagnostico(_, alta_certeza),
    \+ severidad(alta).

% R34 — Severidad baja (solo diagnóstico con certeza media)
severidad(baja) :-
    \+ diagnostico(_, alta_certeza),
    diagnostico(_, media_certeza).

% R35 — Alerta: condiciones favorables para propagación rápida
alerta(propagacion_rapida) :-
    sintoma_observado(zona_alta_humedad),
    diagnostico(roya, _).

alerta(propagacion_rapida) :-
    sintoma_observado(zona_alta_humedad),
    diagnostico(mal_hilachas, _).

alerta(propagacion_rapida) :-
    sintoma_observado(zona_alta_humedad),
    diagnostico(ojo_de_gallo, _).

% R36 — Recomendación: consultar agrónomo cuando certeza es solo media
recomendacion(consultar_agronomo) :-
    \+ diagnostico(_, alta_certeza),
    diagnostico(_, media_certeza).

% R37 — Recomendación: acción urgente si severidad alta
recomendacion(accion_urgente_48hrs) :-
    severidad(alta).

% R38 — Riesgo de confusión entre roya de café y mancha de hierro
recomendacion(revisar_envés_con_lupa) :-
    cultivo_consultado(cafe),
    diagnostico(mancha_hierro, _),
    diagnostico(roya, _).

% R39 — Co-infección posible (dos o más diagnósticos de alta certeza)
alerta(posible_co_infeccion) :-
    diagnostico(E1, alta_certeza),
    diagnostico(E2, alta_certeza),
    E1 \= E2.

% R40 — Sin diagnóstico posible (síntomas insuficientes)
sin_diagnostico :-
    cultivo_consultado(_),
    \+ diagnostico(_, _).

% ------------------------------------------------------------
%  4. PREDICADO PRINCIPAL DE DIAGNÓSTICO
% ------------------------------------------------------------

% Devuelve todos los diagnósticos posibles con su certeza
% Uso desde Python: list(prolog.query("diagnosticar(D, C)"))
diagnosticar(Diagnostico, Certeza) :-
    diagnostico(Diagnostico, Certeza).

% Devuelve el tratamiento para un diagnóstico
obtener_tratamiento(Diagnostico, Tratamiento) :-
    tratamiento(Diagnostico, Tratamiento).

% Devuelve todos los síntomas registrados en esta sesión
sintomas_registrados(Lista) :-
    findall(S, sintoma_observado(S), Lista).

% Devuelve todos los diagnósticos ordenados (alta certeza primero)
todos_diagnosticos(Lista) :-
    findall(alta_certeza-D, diagnostico(D, alta_certeza), Alta),
    findall(media_certeza-D, diagnostico(D, media_certeza), Media),
    append(Alta, Media, Lista).

% ------------------------------------------------------------
%  5. MÓDULO DE EXPLICACIÓN
% ------------------------------------------------------------

% por_que(+Diagnostico)
%   Imprime en consola la cadena de razonamiento completa
%   para un diagnóstico específico.
%   Uso: ?- por_que(roya).
por_que(Diagnostico) :-
    ( diagnostico(Diagnostico, Certeza)
    ->
        nl,
        format('=== EXPLICACIÓN DEL DIAGNÓSTICO ===~n'),
        format('Diagnóstico: ~w~n', [Diagnostico]),
        format('Nivel de certeza: ~w~n', [Certeza]),
        nl,
        format('Síntomas observados que llevaron a esta conclusión:~n'),
        forall(
            sintoma_caracteristico(Diagnostico, S),
            ( sintoma_observado(S)
            -> format('  [v] ~w~n', [S])
            ;  format('  [ ] ~w  (no observado)~n', [S])
            )
        ),
        nl,
        format('Reglas activadas:~n'),
        forall(
            regla_aplicada(R, C),
            format('  -> ~w  (certeza: ~w)~n', [R, C])
        ),
        nl,
        format('Tratamiento recomendado:~n'),
        ( tratamiento(Diagnostico, Lista)
        -> forall(
               member(T, Lista),
               format('  * ~w~n', [T])
           )
        ;  format('  (no registrado)~n')
        )
    ;
        format('No se encontró diagnóstico para: ~w~n', [Diagnostico]),
        format('Verifica que los síntomas estén registrados correctamente.~n')
    ).

% como_llego/0
%   Muestra un resumen completo de la sesión actual:
%   síntomas registrados, todos los diagnósticos y alertas.
%   Uso: ?- como_llego.
como_llego :-
    nl,
    format('========================================~n'),
    format('   RESUMEN DE LA CONSULTA ACTUAL        ~n'),
    format('========================================~n'),

    ( cultivo_consultado(C)
    -> format('Cultivo consultado: ~w~n', [C])
    ;  format('Cultivo: (no definido)~n')
    ),

    nl,
    format('Síntomas registrados:~n'),
    ( findall(S, sintoma_observado(S), Sintomas), Sintomas \= []
    -> forall(member(S, Sintomas), format('  - ~w~n', [S]))
    ;  format('  (ninguno registrado)~n')
    ),

    nl,
    format('Diagnósticos encontrados:~n'),
    ( todos_diagnosticos(Lista), Lista \= []
    -> forall(
           member(Cert-Diag, Lista),
           format('  [~w] ~w~n', [Cert, Diag])
       )
    ;  format('  (ninguno — síntomas insuficientes)~n')
    ),

    nl,
    format('Alertas activas:~n'),
    ( findall(A, alerta(A), Alertas), Alertas \= []
    -> forall(member(A, Alertas), format('  !! ~w~n', [A]))
    ;  format('  (ninguna)~n')
    ),

    nl,
    format('Severidad estimada: '),
    ( severidad(Sev)
    -> format('~w~n', [Sev])
    ;  format('(no determinada)~n')
    ),

    nl,
    format('Recomendaciones adicionales:~n'),
    ( findall(R, recomendacion(R), Recs), Recs \= []
    -> forall(member(R, Recs), format('  >> ~w~n', [R]))
    ;  format('  (ninguna adicional)~n')
    ),

    format('========================================~n').

% ------------------------------------------------------------
%  6. PRUEBA RÁPIDA (descomentar para probar en consola)
% ------------------------------------------------------------
%
% :- iniciar_consulta(cafe),
%    registrar_sintoma(polvo_amarillo_naranja_enves),
%    registrar_sintoma(manchas_amarillas_haz),
%    registrar_sintoma(defoliacion_progresiva),
%    registrar_sintoma(zona_alta_humedad),
%    como_llego,
%    por_que(roya).