:- discontiguous enfermedad/2.
:- discontiguous sintoma_caracteristico/2.
:- discontiguous tratamiento/2.
:- discontiguous diagnostico/2.

:- dynamic sintoma_observado/1.
:- dynamic cultivo_consultado/1.
:- dynamic regla_aplicada/2.

% ------------------------------------------------------------
%  HECHOS — Enfermedades registradas para café
% ------------------------------------------------------------
enfermedad(roya,          cafe).
enfermedad(ojo_de_gallo,  cafe).
enfermedad(antracnosis,   cafe).
enfermedad(mancha_hierro, cafe).
enfermedad(mal_hilachas,  cafe).
enfermedad(llaga_macana,  cafe).
enfermedad(broca_cafe,    cafe).

% ------------------------------------------------------------
%  HECHOS — Síntomas característicos por enfermedad
% ------------------------------------------------------------
sintoma_caracteristico(roya, polvo_amarillo_naranja_enves).
sintoma_caracteristico(roya, manchas_amarillas_haz).
sintoma_caracteristico(roya, defoliacion_progresiva).

sintoma_caracteristico(ojo_de_gallo, manchas_circulares_centro_blanco).
sintoma_caracteristico(ojo_de_gallo, perforaciones_hojas).
sintoma_caracteristico(ojo_de_gallo, zona_alta_humedad).

sintoma_caracteristico(antracnosis, manchas_oscuras_frutos).
sintoma_caracteristico(antracnosis, frutos_momificados).
sintoma_caracteristico(antracnosis, necrosis_ramas).

sintoma_caracteristico(mancha_hierro, manchas_circulares_marron).
sintoma_caracteristico(mancha_hierro, halo_amarillo).
sintoma_caracteristico(mancha_hierro, deficit_nutricional_aparente).

sintoma_caracteristico(mal_hilachas, filamentos_blancos_ramas).
sintoma_caracteristico(mal_hilachas, hojas_pegadas_secas).
sintoma_caracteristico(mal_hilachas, zona_alta_humedad).

sintoma_caracteristico(llaga_macana, marchitez_repentina).
sintoma_caracteristico(llaga_macana, corteza_oscurecida).
sintoma_caracteristico(llaga_macana, rajaduras_tronco).

sintoma_caracteristico(broca_cafe, perforaciones_frutos).
sintoma_caracteristico(broca_cafe, polvo_marron_frutos).

% ------------------------------------------------------------
%  HECHOS — Tratamientos recomendados
% ------------------------------------------------------------
tratamiento(roya, [
    'Aplicar fungicida cuprico (oxicloruro de cobre 50% al 0.3%)',
    'Podar y quemar hojas afectadas',
    'Reducir sombra al 35-50% para mejorar ventilacion',
    'Considerar variedades resistentes: Costa Rica 95, Oro Azteca'
]).

tratamiento(ojo_de_gallo, [
    'Aplicar fungicida a base de cobre o mancozeb',
    'Reducir humedad relativa con podas de sombra',
    'Eliminar hojas afectadas del suelo',
    'Evitar riegos nocturnos'
]).

tratamiento(antracnosis, [
    'Retirar y destruir frutos y ramas afectadas',
    'Aplicar fungicidas: tiofanato metil o carbendazim',
    'Mejorar drenaje del suelo',
    'No transportar material vegetal de zonas infectadas'
]).

tratamiento(mancha_hierro, [
    'Corregir deficiencias de potasio y zinc',
    'Aplicar fungicidas preventivos en epoca lluviosa',
    'Mantener pH del suelo entre 5.5 y 6.5',
    'Aplicar abonos organicos para mejorar nutricion'
]).

tratamiento(mal_hilachas, [
    'Podar y quemar ramas con filamentos',
    'Aplicar pasta bordelesa en cortes de poda',
    'Mejorar circulacion de aire en el cafetal',
    'Aplicar fungicidas sistemicos en casos severos'
]).

tratamiento(llaga_macana, [
    'Eliminar y quemar plantas gravemente afectadas',
    'Desinfectar herramientas con cloro al 10%',
    'Aplicar pasta cicatrizante con fungicida en heridas',
    'No resembrar en el mismo hoyo por al menos 2 ciclos'
]).

tratamiento(broca_cafe, [
    'Aplicar hongo entomopatogeno Beauveria bassiana',
    'Realizar re-re (recoleccion de frutos caidos)',
    'Instalar trampas con etanol-metanol al 1:1',
    'Cosechar oportunamente sin dejar frutos rezagados'
]).

% ------------------------------------------------------------
%  REGLAS DE DIAGNÓSTICO — Café
% ------------------------------------------------------------

% R1 — Roya clásica (alta certeza: los 3 síntomas presentes)
diagnostico(roya, alta_certeza) :-
    cultivo_consultado(cafe),
    sintoma_observado(polvo_amarillo_naranja_enves),
    sintoma_observado(manchas_amarillas_haz),
    sintoma_observado(defoliacion_progresiva),
    assertz(regla_aplicada(r1_roya_clasica, alta_certeza)).

% R2 — Roya temprana (media certeza: solo 2 síntomas)
diagnostico(roya, media_certeza) :-
    cultivo_consultado(cafe),
    sintoma_observado(polvo_amarillo_naranja_enves),
    sintoma_observado(manchas_amarillas_haz),
    \+ sintoma_observado(defoliacion_progresiva),
    \+ diagnostico(roya, alta_certeza),
    assertz(regla_aplicada(r2_roya_temprana, media_certeza)).

% R3 — Ojo de gallo (alta certeza)
diagnostico(ojo_de_gallo, alta_certeza) :-
    cultivo_consultado(cafe),
    sintoma_observado(manchas_circulares_centro_blanco),
    sintoma_observado(perforaciones_hojas),
    sintoma_observado(zona_alta_humedad),
    assertz(regla_aplicada(r3_ojo_de_gallo, alta_certeza)).

% R4 — Ojo de gallo sin dato de humedad (media certeza)
diagnostico(ojo_de_gallo, media_certeza) :-
    cultivo_consultado(cafe),
    sintoma_observado(manchas_circulares_centro_blanco),
    sintoma_observado(perforaciones_hojas),
    \+ sintoma_observado(zona_alta_humedad),
    \+ diagnostico(ojo_de_gallo, alta_certeza),
    assertz(regla_aplicada(r4_ojo_de_gallo_probable, media_certeza)).

% R5 — Antracnosis (alta certeza)
diagnostico(antracnosis, alta_certeza) :-
    cultivo_consultado(cafe),
    sintoma_observado(manchas_oscuras_frutos),
    sintoma_observado(frutos_momificados),
    sintoma_observado(necrosis_ramas),
    assertz(regla_aplicada(r5_antracnosis, alta_certeza)).

% R6 — Antracnosis inicial (media certeza)
diagnostico(antracnosis, media_certeza) :-
    cultivo_consultado(cafe),
    sintoma_observado(manchas_oscuras_frutos),
    sintoma_observado(frutos_momificados),
    \+ sintoma_observado(necrosis_ramas),
    \+ diagnostico(antracnosis, alta_certeza),
    assertz(regla_aplicada(r6_antracnosis_inicial, media_certeza)).

% R7 — Mancha de hierro / Cercospora (alta certeza)
diagnostico(mancha_hierro, alta_certeza) :-
    cultivo_consultado(cafe),
    sintoma_observado(manchas_circulares_marron),
    sintoma_observado(halo_amarillo),
    sintoma_observado(deficit_nutricional_aparente),
    assertz(regla_aplicada(r7_cercospora, alta_certeza)).

% R8 — Mancha de hierro probable (media certeza)
diagnostico(mancha_hierro, media_certeza) :-
    cultivo_consultado(cafe),
    sintoma_observado(manchas_circulares_marron),
    sintoma_observado(halo_amarillo),
    \+ sintoma_observado(deficit_nutricional_aparente),
    \+ diagnostico(mancha_hierro, alta_certeza),
    assertz(regla_aplicada(r8_cercospora_probable, media_certeza)).

% R9 — Mal de hilachas (alta certeza)
diagnostico(mal_hilachas, alta_certeza) :-
    cultivo_consultado(cafe),
    sintoma_observado(filamentos_blancos_ramas),
    sintoma_observado(hojas_pegadas_secas),
    sintoma_observado(zona_alta_humedad),
    assertz(regla_aplicada(r9_hilachas, alta_certeza)).

% R10 — Mal de hilachas sin dato de humedad (media certeza)
diagnostico(mal_hilachas, media_certeza) :-
    cultivo_consultado(cafe),
    sintoma_observado(filamentos_blancos_ramas),
    sintoma_observado(hojas_pegadas_secas),
    \+ sintoma_observado(zona_alta_humedad),
    \+ diagnostico(mal_hilachas, alta_certeza),
    assertz(regla_aplicada(r10_hilachas_probable, media_certeza)).

% R11 — Llaga macana (alta certeza)
diagnostico(llaga_macana, alta_certeza) :-
    cultivo_consultado(cafe),
    sintoma_observado(marchitez_repentina),
    sintoma_observado(corteza_oscurecida),
    sintoma_observado(rajaduras_tronco),
    assertz(regla_aplicada(r11_llaga_macana, alta_certeza)).

% R12 — Llaga macana probable (media certeza)
diagnostico(llaga_macana, media_certeza) :-
    cultivo_consultado(cafe),
    sintoma_observado(marchitez_repentina),
    sintoma_observado(corteza_oscurecida),
    \+ sintoma_observado(rajaduras_tronco),
    \+ diagnostico(llaga_macana, alta_certeza),
    assertz(regla_aplicada(r12_llaga_macana_probable, media_certeza)).

% R13 — Broca del café (alta certeza)
diagnostico(broca_cafe, alta_certeza) :-
    cultivo_consultado(cafe),
    sintoma_observado(perforaciones_frutos),
    sintoma_observado(polvo_marron_frutos),
    assertz(regla_aplicada(r13_broca, alta_certeza)).

% R14 — Broca probable (media certeza: solo perforaciones)
diagnostico(broca_cafe, media_certeza) :-
    cultivo_consultado(cafe),
    sintoma_observado(perforaciones_frutos),
    \+ sintoma_observado(polvo_marron_frutos),
    \+ diagnostico(broca_cafe, alta_certeza),
    assertz(regla_aplicada(r14_broca_probable, media_certeza)).