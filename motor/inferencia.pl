% ============================================================
%  FitoExperto-Chiapas
%  motor/inferencia.pl  —  Motor de Inferencia
%
%  Encadenamiento hacia atrás nativo de SWI-Prolog.
%  Este módulo expone los predicados de alto nivel que
%  la interfaz Python consume vía PySWIP.
%
%  Orden de carga:
%    1. kb/kb_cafe.pl
%    2. kb/kb_maiz.pl
%    3. motor/inferencia.pl
%    4. motor/explicacion.pl
% ============================================================

:- module(inferencia, [
    iniciar_consulta/1,
    registrar_sintoma/1,
    diagnosticar/2,
    todos_diagnosticos/1,
    obtener_tratamiento/2,
    sintomas_registrados/1,
    severidad/1,
    alerta/1,
    recomendacion/1,
    sin_diagnostico/0,
    limpiar_sesion/0
]).

% ------------------------------------------------------------
%  MEMORIA DE TRABAJO
% ------------------------------------------------------------
:- dynamic sintoma_observado/1.
:- dynamic cultivo_consultado/1.
:- dynamic regla_aplicada/2.

% ------------------------------------------------------------
%  INICIALIZACIÓN Y LIMPIEZA
% ------------------------------------------------------------

iniciar_consulta(Cultivo) :-
    limpiar_sesion,
    assertz(cultivo_consultado(Cultivo)).

limpiar_sesion :-
    retractall(sintoma_observado(_)),
    retractall(regla_aplicada(_, _)),
    retractall(cultivo_consultado(_)).

% ------------------------------------------------------------
%  REGISTRO DE SÍNTOMAS
% ------------------------------------------------------------

registrar_sintoma(Sintoma) :-
    ( sintoma_observado(Sintoma)
    -> true
    ;  assertz(sintoma_observado(Sintoma))
    ).

registrar_regla(IdRegla, Certeza) :-
    ( regla_aplicada(IdRegla, Certeza)
    -> true
    ;  assertz(regla_aplicada(IdRegla, Certeza))
    ).

% ------------------------------------------------------------
%  CONSULTAS PRINCIPALES
%  Estas son las que Python llama desde PySWIP
% ------------------------------------------------------------

% diagnosticar(?Diagnostico, ?Certeza)
%   Unifica con cada diagnóstico posible dado los síntomas actuales.
%   Uso Python:
%     results = list(prolog.query("diagnosticar(D, C)"))
diagnosticar(Diagnostico, Certeza) :-
    diagnostico(Diagnostico, Certeza).

% todos_diagnosticos(-Lista)
%   Devuelve lista ordenada: alta_certeza primero, luego media.
%   Uso Python:
%     list(prolog.query("todos_diagnosticos(L)"))
todos_diagnosticos(Lista) :-
    findall(alta_certeza-D, diagnostico(D, alta_certeza), Alta),
    findall(media_certeza-D, diagnostico(D, media_certeza), Media),
    append(Alta, Media, Lista).

% obtener_tratamiento(+Diagnostico, -Lista)
%   Devuelve la lista de pasos de tratamiento.
obtener_tratamiento(Diagnostico, Lista) :-
    tratamiento(Diagnostico, Lista).

% sintomas_registrados(-Lista)
%   Devuelve los síntomas marcados en la sesión actual.
sintomas_registrados(Lista) :-
    findall(S, sintoma_observado(S), Lista).

% sin_diagnostico/0
%   Éxito si no existe ningún diagnóstico posible (síntomas insuficientes).
sin_diagnostico :-
    cultivo_consultado(_),
    \+ diagnostico(_, _).

% ------------------------------------------------------------
%  REGLAS AUXILIARES — Severidad
% ------------------------------------------------------------

% R32 — Severidad alta
severidad(alta) :-
    sintoma_observado(defoliacion_progresiva),
    diagnostico(_, alta_certeza).

severidad(alta) :-
    sintoma_observado(acame_prematuro).

% R33 — Severidad media
severidad(media) :-
    diagnostico(_, alta_certeza),
    \+ severidad(alta).

% R34 — Severidad baja
severidad(baja) :-
    \+ diagnostico(_, alta_certeza),
    diagnostico(_, media_certeza).

% ------------------------------------------------------------
%  REGLAS AUXILIARES — Alertas
% ------------------------------------------------------------

% R35 — Condiciones favorables para propagación rápida
alerta(propagacion_rapida) :-
    sintoma_observado(zona_alta_humedad),
    diagnostico(roya, _).

alerta(propagacion_rapida) :-
    sintoma_observado(zona_alta_humedad),
    diagnostico(mal_hilachas, _).

alerta(propagacion_rapida) :-
    sintoma_observado(zona_alta_humedad),
    diagnostico(ojo_de_gallo, _).

% R36 — Posible co-infección
alerta(posible_co_infeccion) :-
    diagnostico(E1, alta_certeza),
    diagnostico(E2, alta_certeza),
    E1 \= E2.

% ------------------------------------------------------------
%  REGLAS AUXILIARES — Recomendaciones
% ------------------------------------------------------------

% R37 — Solo certeza media: consultar agrónomo
recomendacion(consultar_agronomo) :-
    \+ diagnostico(_, alta_certeza),
    diagnostico(_, media_certeza).

% R38 — Severidad alta: acción urgente
recomendacion(accion_urgente_48hrs) :-
    severidad(alta).

% R39 — Roya vs mancha de hierro en café: riesgo de confusión
recomendacion(revisar_enves_con_lupa) :-
    cultivo_consultado(cafe),
    diagnostico(mancha_hierro, _),
    diagnostico(roya, _).