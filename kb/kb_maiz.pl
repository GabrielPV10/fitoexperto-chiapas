:- discontiguous enfermedad/2.
:- discontiguous sintoma_caracteristico/2.
:- discontiguous tratamiento/2.
:- discontiguous diagnostico/2.

:- dynamic sintoma_observado/1.
:- dynamic cultivo_consultado/1.
:- dynamic regla_aplicada/2.

enfermedad(carbon_comun,    maiz).
enfermedad(tizon_foliar,    maiz).
enfermedad(roya_maiz,       maiz).
enfermedad(mancha_gris,     maiz).
enfermedad(pudricion_tallo, maiz).
enfermedad(achaparramiento, maiz).

% ------------------------------------------------------------
%  HECHOS — Síntomas característicos por enfermedad
% ------------------------------------------------------------
sintoma_caracteristico(carbon_comun, agallas_grises_negras).
sintoma_caracteristico(carbon_comun, tejido_inflamado_deformado).
sintoma_caracteristico(carbon_comun, masa_polvosa_oscura_interior).

sintoma_caracteristico(tizon_foliar, lesiones_alargadas_grises).
sintoma_caracteristico(tizon_foliar, forma_cigarro_bordes_paralelos).
sintoma_caracteristico(tizon_foliar, hojas_inferiores_afectadas_primero).

sintoma_caracteristico(roya_maiz, pustulas_marron_rojizas).
sintoma_caracteristico(roya_maiz, distribucion_ambas_caras_hoja).
sintoma_caracteristico(roya_maiz, pustulas_rompen_epidermis).

sintoma_caracteristico(mancha_gris, lesiones_rectangulares_gris).
sintoma_caracteristico(mancha_gris, bordes_paralelos_nervaduras).
sintoma_caracteristico(mancha_gris, lesiones_coalescen_queman_hoja).

sintoma_caracteristico(pudricion_tallo, tallo_blando_al_apriete).
sintoma_caracteristico(pudricion_tallo, medula_rosada_o_blanca).
sintoma_caracteristico(pudricion_tallo, acame_prematuro).

sintoma_caracteristico(achaparramiento, planta_muy_pequena_achaparrada).
sintoma_caracteristico(achaparramiento, hojas_amarillas_verdor_palido).
sintoma_caracteristico(achaparramiento, proliferacion_mazorcas_pequenas).

% ------------------------------------------------------------
%  HECHOS — Tratamientos recomendados
% ------------------------------------------------------------
tratamiento(carbon_comun, [
    'No existe control quimico efectivo una vez presente',
    'Eliminar y enterrar plantas afectadas antes de que revienten las agallas',
    'Rotar cultivos: no sembrar maiz en el mismo sitio por 2 ciclos',
    'Usar hibridos o variedades con tolerancia al carbon',
    'Nota: las agallas son comestibles antes de madurar (huitlacoche)'
]).

tratamiento(tizon_foliar, [
    'Aplicar fungicidas: mancozeb, clorotalonil o triazoles',
    'Iniciar aplicaciones al detectar primeras lesiones',
    'Sembrar hibridos resistentes (HTF)',
    'Rotar cultivos con leguminosas o sorgo'
]).

tratamiento(roya_maiz, [
    'Aplicar fungicidas triazoles (propiconazol, tebuconazol)',
    'Aplicar preventivamente al inicio del espigamiento',
    'Sembrar variedades resistentes disponibles en INIFAP',
    'Monitorear desde etapa V6 en zonas de alta incidencia'
]).

tratamiento(mancha_gris, [
    'Aplicar fungicidas triazoles o estrobilurinas',
    'Reducir residuos de cosecha (labranza)',
    'Rotar cultivos al menos un ciclo',
    'Usar hibridos con resistencia parcial'
]).

tratamiento(pudricion_tallo, [
    'No hay control efectivo una vez que aparece en campo',
    'Cosechar anticipadamente antes del acame masivo',
    'Evitar estres hidrico y nutricional (K y Zn)',
    'Usar fungicidas en semilla: carboxin + captan',
    'Rotar cultivos con no-gramineas'
]).

tratamiento(achaparramiento, [
    'No hay cura: eliminar plantas infectadas inmediatamente',
    'Controlar vector (chicharrita Dalbulus maidis) con insecticidas',
    'Sembrar en fechas que eviten picos de chicharrita',
    'Usar variedades tolerantes al achaparramiento',
    'Limpiar malezas hospederas alrededor de la parcela'
]).

% ------------------------------------------------------------
%  REGLAS DE DIAGNÓSTICO — Maíz
% ------------------------------------------------------------

% R20 — Carbón común / Huitlacoche (alta certeza)
diagnostico(carbon_comun, alta_certeza) :-
    cultivo_consultado(maiz),
    sintoma_observado(agallas_grises_negras),
    sintoma_observado(tejido_inflamado_deformado),
    sintoma_observado(masa_polvosa_oscura_interior),
    assertz(regla_aplicada(r20_carbon_clasico, alta_certeza)).

% R21 — Carbón común en fase temprana (media certeza)
diagnostico(carbon_comun, media_certeza) :-
    cultivo_consultado(maiz),
    sintoma_observado(agallas_grises_negras),
    sintoma_observado(tejido_inflamado_deformado),
    \+ sintoma_observado(masa_polvosa_oscura_interior),
    \+ diagnostico(carbon_comun, alta_certeza),
    assertz(regla_aplicada(r21_carbon_temprano, media_certeza)).

% R22 — Tizón foliar norteño (alta certeza)
diagnostico(tizon_foliar, alta_certeza) :-
    cultivo_consultado(maiz),
    sintoma_observado(lesiones_alargadas_grises),
    sintoma_observado(forma_cigarro_bordes_paralelos),
    sintoma_observado(hojas_inferiores_afectadas_primero),
    assertz(regla_aplicada(r22_tizon_clasico, alta_certeza)).

% R23 — Tizón foliar probable (media certeza)
diagnostico(tizon_foliar, media_certeza) :-
    cultivo_consultado(maiz),
    sintoma_observado(lesiones_alargadas_grises),
    sintoma_observado(forma_cigarro_bordes_paralelos),
    \+ sintoma_observado(hojas_inferiores_afectadas_primero),
    \+ diagnostico(tizon_foliar, alta_certeza),
    assertz(regla_aplicada(r23_tizon_probable, media_certeza)).

% R24 — Roya común del maíz (alta certeza)
diagnostico(roya_maiz, alta_certeza) :-
    cultivo_consultado(maiz),
    sintoma_observado(pustulas_marron_rojizas),
    sintoma_observado(distribucion_ambas_caras_hoja),
    sintoma_observado(pustulas_rompen_epidermis),
    assertz(regla_aplicada(r24_roya_maiz_clasica, alta_certeza)).

% R25 — Roya del maíz probable (media certeza)
diagnostico(roya_maiz, media_certeza) :-
    cultivo_consultado(maiz),
    sintoma_observado(pustulas_marron_rojizas),
    sintoma_observado(distribucion_ambas_caras_hoja),
    \+ sintoma_observado(pustulas_rompen_epidermis),
    \+ diagnostico(roya_maiz, alta_certeza),
    assertz(regla_aplicada(r25_roya_maiz_probable, media_certeza)).

% R26 — Mancha gris (alta certeza)
diagnostico(mancha_gris, alta_certeza) :-
    cultivo_consultado(maiz),
    sintoma_observado(lesiones_rectangulares_gris),
    sintoma_observado(bordes_paralelos_nervaduras),
    sintoma_observado(lesiones_coalescen_queman_hoja),
    assertz(regla_aplicada(r26_mancha_gris_clasica, alta_certeza)).

% R27 — Mancha gris inicial (media certeza)
diagnostico(mancha_gris, media_certeza) :-
    cultivo_consultado(maiz),
    sintoma_observado(lesiones_rectangulares_gris),
    sintoma_observado(bordes_paralelos_nervaduras),
    \+ sintoma_observado(lesiones_coalescen_queman_hoja),
    \+ diagnostico(mancha_gris, alta_certeza),
    assertz(regla_aplicada(r27_mancha_gris_inicial, media_certeza)).

% R28 — Pudrición de tallo (alta certeza)
diagnostico(pudricion_tallo, alta_certeza) :-
    cultivo_consultado(maiz),
    sintoma_observado(tallo_blando_al_apriete),
    sintoma_observado(medula_rosada_o_blanca),
    sintoma_observado(acame_prematuro),
    assertz(regla_aplicada(r28_pudricion_clasica, alta_certeza)).

% R29 — Pudrición de tallo probable (media certeza)
diagnostico(pudricion_tallo, media_certeza) :-
    cultivo_consultado(maiz),
    sintoma_observado(tallo_blando_al_apriete),
    sintoma_observado(medula_rosada_o_blanca),
    \+ sintoma_observado(acame_prematuro),
    \+ diagnostico(pudricion_tallo, alta_certeza),
    assertz(regla_aplicada(r29_pudricion_probable, media_certeza)).

% R30 — Achaparramiento (alta certeza)
diagnostico(achaparramiento, alta_certeza) :-
    cultivo_consultado(maiz),
    sintoma_observado(planta_muy_pequena_achaparrada),
    sintoma_observado(hojas_amarillas_verdor_palido),
    sintoma_observado(proliferacion_mazorcas_pequenas),
    assertz(regla_aplicada(r30_achaparramiento, alta_certeza)).

% R31 — Achaparramiento probable (media certeza)
diagnostico(achaparramiento, media_certeza) :-
    cultivo_consultado(maiz),
    sintoma_observado(planta_muy_pequena_achaparrada),
    sintoma_observado(hojas_amarillas_verdor_palido),
    \+ sintoma_observado(proliferacion_mazorcas_pequenas),
    \+ diagnostico(achaparramiento, alta_certeza),
    assertz(regla_aplicada(r31_achaparramiento_probable, media_certeza)).