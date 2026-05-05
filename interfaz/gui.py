# ============================================================
#  FitoExperto-Chiapas
#  interfaz/gui.py  —  Interfaz Gráfica (Tkinter)
#
#  Pantallas:
#    1. Bienvenida
#    2. Selección de cultivo
#    3. Cuestionario de síntomas
#    4. Resultado + explicación
# ============================================================

import tkinter as tk
from tkinter import ttk, messagebox, scrolledtext
import os
import sys

# Importar el puente; si pyswip no está instalado, avisamos claramente
try:
    from puente_prolog import MotorFito
    PROLOG_OK = True
except Exception as e:
    PROLOG_OK = False
    PROLOG_ERROR = str(e)

# ── Paleta de colores ────────────────────────────────────────
C = {
    "bg":        "#F5F0E8",   # crema cálido
    "panel":     "#FFFFFF",
    "verde":     "#2D6A4F",   # verde selva oscuro
    "verde_c":   "#52B788",   # verde claro
    "cafe":      "#6B3A2A",   # café oscuro
    "amarillo":  "#E9C46A",   # amarillo maíz
    "rojo":      "#C1121F",   # alerta
    "texto":     "#1A1A2E",
    "subtexto":  "#555577",
    "borde":     "#D0C9BB",
    "sombra":    "#C8BFB0",
}

FONT_TITULO  = ("Georgia", 22, "bold")
FONT_SUBTIT  = ("Georgia", 13)
FONT_NORMAL  = ("Segoe UI", 10)
FONT_BOLD    = ("Segoe UI", 10, "bold")
FONT_SMALL   = ("Segoe UI", 9)
FONT_GRANDE  = ("Georgia", 16, "bold")

# ── Síntomas por cultivo ─────────────────────────────────────
SINTOMAS = {
    "cafe": [
        ("polvo_amarillo_naranja_enves",    "Polvo amarillo/naranja en el envés de las hojas"),
        ("manchas_amarillas_haz",           "Manchas amarillas en el haz de las hojas"),
        ("defoliacion_progresiva",          "Caída progresiva de hojas"),
        ("manchas_circulares_centro_blanco","Manchas circulares con centro blanco en hojas"),
        ("perforaciones_hojas",             "Perforaciones / agujeros en hojas"),
        ("manchas_oscuras_frutos",          "Manchas oscuras en los frutos"),
        ("frutos_momificados",              "Frutos momificados o arrugados"),
        ("necrosis_ramas",                  "Necrosis (muerte) en puntas de ramas"),
        ("manchas_circulares_marron",       "Manchas circulares de color marrón en hojas"),
        ("halo_amarillo",                   "Halo amarillo alrededor de las manchas"),
        ("deficit_nutricional_aparente",    "Planta con aspecto desnutrido o pálida"),
        ("filamentos_blancos_ramas",        "Filamentos o hilos blancos sobre ramas"),
        ("hojas_pegadas_secas",             "Hojas pegadas y secas sin caer"),
        ("marchitez_repentina",             "Marchitez repentina de la planta"),
        ("corteza_oscurecida",              "Corteza del tronco oscurecida o negra"),
        ("rajaduras_tronco",                "Rajaduras en el tronco"),
        ("perforaciones_frutos",            "Pequeñas perforaciones circulares en frutos"),
        ("polvo_marron_frutos",             "Polvo o aserrín marrón alrededor de perforaciones"),
        ("zona_alta_humedad",               "La planta está en zona de alta humedad"),
    ],
    "maiz": [
        ("agallas_grises_negras",               "Agallas (bolsas) grises o negras en planta"),
        ("tejido_inflamado_deformado",          "Tejido inflamado o deformado"),
        ("masa_polvosa_oscura_interior",        "Interior de agallas con masa polvosa oscura"),
        ("lesiones_alargadas_grises",           "Lesiones alargadas de color gris en hojas"),
        ("forma_cigarro_bordes_paralelos",      "Lesiones con forma de cigarro y bordes paralelos"),
        ("hojas_inferiores_afectadas_primero",  "Las hojas de abajo se afectan primero"),
        ("pustulas_marron_rojizas",             "Pústulas (granos) marrón rojizas en hojas"),
        ("distribucion_ambas_caras_hoja",       "Pústulas en ambas caras de la hoja"),
        ("pustulas_rompen_epidermis",           "Pústulas que rompen la piel de la hoja"),
        ("lesiones_rectangulares_gris",         "Lesiones rectangulares de color gris"),
        ("bordes_paralelos_nervaduras",         "Lesiones con bordes paralelos a las nervaduras"),
        ("lesiones_coalescen_queman_hoja",      "Las lesiones se unen y queman la hoja"),
        ("tallo_blando_al_apriete",             "Tallo se siente blando al apretarlo"),
        ("medula_rosada_o_blanca",              "Interior del tallo color rosado o blanco"),
        ("acame_prematuro",                     "Plantas tumbadas antes de la cosecha"),
        ("planta_muy_pequena_achaparrada",      "Planta muy pequeña y achaparrada"),
        ("hojas_amarillas_verdor_palido",       "Hojas amarillas o con verdor muy pálido"),
        ("proliferacion_mazorcas_pequenas",     "Muchas mazorcas pequeñas y sin grano"),
    ],
}

NOMBRES_ENFERMEDAD = {
    "roya":             "Roya del cafeto",
    "ojo_de_gallo":     "Ojo de gallo",
    "antracnosis":      "Antracnosis (CBD)",
    "mancha_hierro":    "Mancha de hierro / Cercospora",
    "mal_hilachas":     "Mal de hilachas",
    "llaga_macana":     "Llaga macana",
    "broca_cafe":       "Broca del café",
    "carbon_comun":     "Carbón común (Huitlacoche)",
    "tizon_foliar":     "Tizón foliar norteño",
    "roya_maiz":        "Roya común del maíz",
    "mancha_gris":      "Mancha gris",
    "pudricion_tallo":  "Pudrición del tallo",
    "achaparramiento":  "Achaparramiento",
}

CERTEZA_LABEL = {
    "alta_certeza":  "Alta certeza ✓",
    "media_certeza": "Certeza media — se recomienda verificar",
}

COLOR_CERTEZA = {
    "alta_certeza":  C["verde"],
    "media_certeza": C["amarillo"],
}


# ─────────────────────────────────────────────────────────────
#  VENTANA PRINCIPAL
# ─────────────────────────────────────────────────────────────
class AppFito(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("FitoExperto-Chiapas")
        self.geometry("820x620")
        self.minsize(700, 520)
        self.configure(bg=C["bg"])
        self.resizable(True, True)

        # Motor Prolog
        self.motor = None
        if PROLOG_OK:
            try:
                self.motor = MotorFito(
                    base_dir=os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
                )
            except Exception as e:
                messagebox.showerror(
                    "Error al cargar Prolog",
                    f"No se pudo inicializar el motor de inferencia.\n\n{e}\n\n"
                    "Verifica que SWI-Prolog esté instalado y en el PATH."
                )
        else:
            messagebox.showerror(
                "PySWIP no encontrado",
                f"No se pudo importar pyswip.\n\n{PROLOG_ERROR}\n\n"
                "Ejecuta:  pip install pyswip"
            )

        # Estado de la sesión
        self.cultivo_sel = tk.StringVar(value="cafe")
        self.vars_sintomas = {}      # {atom: BooleanVar}
        self.ultimo_diagnostico = [] # [(diag, certeza), ...]

        # Contenedor de frames
        self._container = tk.Frame(self, bg=C["bg"])
        self._container.pack(fill="both", expand=True)

        self._frames = {}
        for F in (PantallaBienvenida, PantallaCultivo,
                  PantallaSintomas, PantallaResultado):
            frame = F(self._container, self)
            self._frames[F.__name__] = frame
            frame.place(relx=0, rely=0, relwidth=1, relheight=1)

        self.mostrar("PantallaBienvenida")

    def mostrar(self, nombre: str):
        frame = self._frames[nombre]
        if hasattr(frame, "al_mostrar"):
            frame.al_mostrar()
        frame.lift()


# ─────────────────────────────────────────────────────────────
#  PANTALLA 1 — BIENVENIDA
# ─────────────────────────────────────────────────────────────
class PantallaBienvenida(tk.Frame):
    def __init__(self, parent, app: AppFito):
        super().__init__(parent, bg=C["bg"])
        self.app = app
        self._build()

    def _build(self):
        # Franja decorativa superior
        banda = tk.Frame(self, bg=C["verde"], height=8)
        banda.pack(fill="x")

        centro = tk.Frame(self, bg=C["bg"])
        centro.pack(expand=True)

        tk.Label(centro, text="🌿", font=("Segoe UI Emoji", 48),
                 bg=C["bg"]).pack(pady=(30, 0))

        tk.Label(centro, text="FitoExperto-Chiapas",
                 font=FONT_TITULO, bg=C["bg"], fg=C["verde"]).pack()

        tk.Label(centro,
                 text="Sistema Experto para Diagnóstico de Fitopatologías\n"
                      "en Cultivos de Café y Maíz",
                 font=FONT_SUBTIT, bg=C["bg"], fg=C["subtexto"],
                 justify="center").pack(pady=(6, 30))

        # Tarjetas de info
        tarjetas = tk.Frame(centro, bg=C["bg"])
        tarjetas.pack(pady=10)
        for icono, texto in [
            ("☕", "Café\n7 enfermedades"),
            ("🌽", "Maíz\n6 enfermedades"),
            ("🧠", "35 reglas\nde inferencia"),
        ]:
            t = tk.Frame(tarjetas, bg=C["panel"],
                         highlightbackground=C["borde"], highlightthickness=1)
            t.pack(side="left", padx=10, ipadx=16, ipady=12)
            tk.Label(t, text=icono, font=("Segoe UI Emoji", 24),
                     bg=C["panel"]).pack()
            tk.Label(t, text=texto, font=FONT_SMALL, bg=C["panel"],
                     fg=C["subtexto"], justify="center").pack()

        btn = tk.Button(
            centro, text="Iniciar diagnóstico →",
            font=FONT_BOLD, bg=C["verde"], fg="white",
            relief="flat", padx=28, pady=10, cursor="hand2",
            activebackground=C["verde_c"], activeforeground="white",
            command=lambda: self.app.mostrar("PantallaCultivo")
        )
        btn.pack(pady=30)

        tk.Label(self,
                 text="Tecnológico de Chiapas  •  Inteligencia Artificial",
                 font=FONT_SMALL, bg=C["bg"], fg=C["borde"]).pack(side="bottom", pady=8)


# ─────────────────────────────────────────────────────────────
#  PANTALLA 2 — SELECCIÓN DE CULTIVO
# ─────────────────────────────────────────────────────────────
class PantallaCultivo(tk.Frame):
    def __init__(self, parent, app: AppFito):
        super().__init__(parent, bg=C["bg"])
        self.app = app
        self._build()

    def _build(self):
        tk.Frame(self, bg=C["verde"], height=8).pack(fill="x")

        tk.Label(self, text="¿Qué cultivo deseas diagnosticar?",
                 font=FONT_GRANDE, bg=C["bg"], fg=C["texto"]).pack(pady=(30, 8))
        tk.Label(self,
                 text="Selecciona el cultivo afectado para cargar los síntomas correspondientes.",
                 font=FONT_NORMAL, bg=C["bg"], fg=C["subtexto"]).pack()

        tarjetas = tk.Frame(self, bg=C["bg"])
        tarjetas.pack(expand=True)

        self._btn_cafe  = None
        self._btn_maiz  = None

        for cultivo, icono, nombre, desc, color in [
            ("cafe",  "☕", "Café",  "Coffea arabica\n7 enfermedades / 14 reglas", C["cafe"]),
            ("maiz",  "🌽", "Maíz",  "Zea mays\n6 enfermedades / 12 reglas",      C["verde"]),
        ]:
            f = tk.Frame(tarjetas, bg=C["panel"],
                         highlightbackground=C["borde"], highlightthickness=2,
                         cursor="hand2")
            f.pack(side="left", padx=20, ipadx=30, ipady=24)
            tk.Label(f, text=icono, font=("Segoe UI Emoji", 52), bg=C["panel"]).pack()
            tk.Label(f, text=nombre, font=("Georgia", 16, "bold"),
                     bg=C["panel"], fg=color).pack()
            tk.Label(f, text=desc, font=FONT_SMALL,
                     bg=C["panel"], fg=C["subtexto"], justify="center").pack(pady=4)

            c = cultivo  # captura en closure
            f.bind("<Button-1>", lambda e, cv=c: self._seleccionar(cv))
            for child in f.winfo_children():
                child.bind("<Button-1>", lambda e, cv=c: self._seleccionar(cv))

        # Botones nav
        nav = tk.Frame(self, bg=C["bg"])
        nav.pack(side="bottom", pady=20)
        tk.Button(nav, text="← Volver", font=FONT_NORMAL,
                  bg=C["bg"], fg=C["subtexto"], relief="flat", cursor="hand2",
                  command=lambda: self.app.mostrar("PantallaBienvenida")).pack(side="left", padx=10)

    def _seleccionar(self, cultivo: str):
        self.app.cultivo_sel.set(cultivo)
        self.app.mostrar("PantallaSintomas")


# ─────────────────────────────────────────────────────────────
#  PANTALLA 3 — CUESTIONARIO DE SÍNTOMAS
# ─────────────────────────────────────────────────────────────
class PantallaSintomas(tk.Frame):
    def __init__(self, parent, app: AppFito):
        super().__init__(parent, bg=C["bg"])
        self.app = app
        self._checks_frame = None
        self._build_estructura()

    def _build_estructura(self):
        tk.Frame(self, bg=C["verde"], height=8).pack(fill="x")

        # Cabecera
        cab = tk.Frame(self, bg=C["bg"])
        cab.pack(fill="x", padx=24, pady=(14, 0))

        self._lbl_titulo = tk.Label(cab, text="",
                                    font=FONT_GRANDE, bg=C["bg"], fg=C["texto"])
        self._lbl_titulo.pack(side="left")

        tk.Label(cab, text="Marca todos los síntomas que observas en la planta:",
                 font=FONT_NORMAL, bg=C["bg"], fg=C["subtexto"]).pack(side="left", padx=16)

        # Área scrollable
        contenedor = tk.Frame(self, bg=C["bg"])
        contenedor.pack(fill="both", expand=True, padx=24, pady=8)

        canvas = tk.Canvas(contenedor, bg=C["bg"], highlightthickness=0)
        scroll = ttk.Scrollbar(contenedor, orient="vertical", command=canvas.yview)
        canvas.configure(yscrollcommand=scroll.set)

        scroll.pack(side="right", fill="y")
        canvas.pack(side="left", fill="both", expand=True)

        self._checks_frame = tk.Frame(canvas, bg=C["bg"])
        self._win_id = canvas.create_window((0, 0), window=self._checks_frame, anchor="nw")

        self._checks_frame.bind("<Configure>",
            lambda e: canvas.configure(scrollregion=canvas.bbox("all")))
        canvas.bind("<Configure>",
            lambda e: canvas.itemconfig(self._win_id, width=e.width))
        canvas.bind_all("<MouseWheel>",
            lambda e: canvas.yview_scroll(int(-1*(e.delta/120)), "units"))

        # Barra inferior
        barra = tk.Frame(self, bg=C["sombra"], height=1)
        barra.pack(fill="x")

        pie = tk.Frame(self, bg=C["bg"])
        pie.pack(fill="x", padx=24, pady=10)

        tk.Button(pie, text="← Cambiar cultivo", font=FONT_NORMAL,
                  bg=C["bg"], fg=C["subtexto"], relief="flat", cursor="hand2",
                  command=lambda: self.app.mostrar("PantallaCultivo")).pack(side="left")

        tk.Button(pie, text="Limpiar selección", font=FONT_NORMAL,
                  bg=C["bg"], fg=C["subtexto"], relief="flat", cursor="hand2",
                  command=self._limpiar).pack(side="left", padx=12)

        tk.Button(pie, text="Diagnosticar  →", font=FONT_BOLD,
                  bg=C["verde"], fg="white", relief="flat",
                  padx=20, pady=8, cursor="hand2",
                  activebackground=C["verde_c"], activeforeground="white",
                  command=self._diagnosticar).pack(side="right")

    def al_mostrar(self):
        """Reconstruye los checkboxes según el cultivo seleccionado."""
        cultivo = self.app.cultivo_sel.get()
        icono = "☕" if cultivo == "cafe" else "🌽"
        nombre = "Café" if cultivo == "cafe" else "Maíz"
        self._lbl_titulo.config(text=f"{icono} {nombre}  —")

        # Limpiar checkboxes anteriores
        for w in self._checks_frame.winfo_children():
            w.destroy()
        self.app.vars_sintomas.clear()

        sintomas = SINTOMAS.get(cultivo, [])
        for i, (atom, etiqueta) in enumerate(sintomas):
            var = tk.BooleanVar(value=False)
            self.app.vars_sintomas[atom] = var

            fila = tk.Frame(self._checks_frame, bg=C["bg"])
            fila.pack(fill="x", padx=8, pady=2)

            cb = tk.Checkbutton(
                fila, text=etiqueta, variable=var,
                font=FONT_NORMAL, bg=C["bg"], fg=C["texto"],
                activebackground=C["bg"], selectcolor=C["panel"],
                anchor="w", cursor="hand2"
            )
            cb.pack(side="left", fill="x")

    def _limpiar(self):
        for var in self.app.vars_sintomas.values():
            var.set(False)

    def _diagnosticar(self):
        seleccionados = [atom for atom, var in self.app.vars_sintomas.items()
                         if var.get()]

        if not seleccionados:
            messagebox.showwarning(
                "Sin síntomas",
                "Por favor marca al menos un síntoma antes de diagnosticar."
            )
            return

        if self.app.motor is None:
            # Modo demo sin Prolog
            self.app.ultimo_diagnostico = [("roya", "alta_certeza")]
            self.app.mostrar("PantallaResultado")
            return

        cultivo = self.app.cultivo_sel.get()
        try:
            self.app.motor.iniciar_consulta(cultivo)
            self.app.motor.registrar_multiples(seleccionados)
            self.app.ultimo_diagnostico = self.app.motor.diagnosticar()
        except Exception as e:
            messagebox.showerror("Error en el motor", str(e))
            return

        self.app.mostrar("PantallaResultado")


# ─────────────────────────────────────────────────────────────
#  PANTALLA 4 — RESULTADO
# ─────────────────────────────────────────────────────────────
class PantallaResultado(tk.Frame):
    def __init__(self, parent, app: AppFito):
        super().__init__(parent, bg=C["bg"])
        self.app = app
        self._build_estructura()

    def _build_estructura(self):
        tk.Frame(self, bg=C["verde"], height=8).pack(fill="x")

        tk.Label(self, text="Resultado del diagnóstico",
                 font=FONT_GRANDE, bg=C["bg"], fg=C["texto"]).pack(pady=(16, 4))

        # Panel principal (diagnóstico + tratamiento)
        self._panel = tk.Frame(self, bg=C["bg"])
        self._panel.pack(fill="both", expand=True, padx=24, pady=4)

        # Columna izquierda: diagnóstico
        self._col_diag = tk.Frame(self._panel, bg=C["bg"])
        self._col_diag.pack(side="left", fill="both", expand=True, padx=(0, 8))

        # Columna derecha: tratamiento
        self._col_trat = tk.Frame(self._panel, bg=C["bg"])
        self._col_trat.pack(side="right", fill="both", expand=True, padx=(8, 0))

        # Pie: botón explicación y nueva consulta
        pie = tk.Frame(self, bg=C["bg"])
        pie.pack(fill="x", padx=24, pady=12)

        tk.Button(pie, text="¿Por qué este diagnóstico?",
                  font=FONT_NORMAL, bg=C["amarillo"], fg=C["texto"],
                  relief="flat", padx=14, pady=7, cursor="hand2",
                  command=self._mostrar_explicacion).pack(side="left")

        tk.Button(pie, text="Nueva consulta", font=FONT_BOLD,
                  bg=C["verde"], fg="white", relief="flat",
                  padx=20, pady=7, cursor="hand2",
                  activebackground=C["verde_c"], activeforeground="white",
                  command=lambda: self.app.mostrar("PantallaCultivo")).pack(side="right")

    def al_mostrar(self):
        # Limpiar columnas
        for col in (self._col_diag, self._col_trat):
            for w in col.winfo_children():
                w.destroy()

        diags = self.app.ultimo_diagnostico

        # ── Columna izquierda: diagnósticos ──────────────────
        tk.Label(self._col_diag, text="Enfermedades detectadas",
                 font=FONT_BOLD, bg=C["bg"], fg=C["subtexto"]).pack(anchor="w")

        if not diags:
            tk.Label(self._col_diag,
                     text="No se encontró un diagnóstico con los síntomas indicados.\n"
                          "Intenta marcar más síntomas o consulta a un agrónomo.",
                     font=FONT_NORMAL, bg=C["bg"], fg=C["rojo"],
                     wraplength=300, justify="left").pack(anchor="w", pady=8)
        else:
            for diag, certeza in diags:
                tarj = tk.Frame(self._col_diag, bg=C["panel"],
                                highlightbackground=COLOR_CERTEZA.get(certeza, C["borde"]),
                                highlightthickness=2)
                tarj.pack(fill="x", pady=4, ipady=8, ipadx=10)

                nombre = NOMBRES_ENFERMEDAD.get(diag, diag.replace("_", " ").title())
                label_cert = CERTEZA_LABEL.get(certeza, certeza)

                tk.Label(tarj, text=nombre, font=FONT_BOLD,
                         bg=C["panel"], fg=C["texto"]).pack(anchor="w")
                tk.Label(tarj, text=label_cert, font=FONT_SMALL,
                         bg=C["panel"],
                         fg=COLOR_CERTEZA.get(certeza, C["subtexto"])).pack(anchor="w")

        # Alertas
        if self.app.motor:
            alertas = self.app.motor.alertas()
            if alertas:
                tk.Label(self._col_diag, text="⚠ Alertas",
                         font=FONT_BOLD, bg=C["bg"], fg=C["rojo"]).pack(anchor="w", pady=(10, 0))
                for a in alertas:
                    tk.Label(self._col_diag,
                             text=f"• {a.replace('_', ' ')}",
                             font=FONT_SMALL, bg=C["bg"], fg=C["rojo"]).pack(anchor="w")

        # ── Columna derecha: tratamiento ──────────────────────
        tk.Label(self._col_trat, text="Tratamiento recomendado",
                 font=FONT_BOLD, bg=C["bg"], fg=C["subtexto"]).pack(anchor="w")

        if diags:
            diag_principal = diags[0][0]
            nombre = NOMBRES_ENFERMEDAD.get(diag_principal,
                                            diag_principal.replace("_", " ").title())
            tk.Label(self._col_trat, text=f"Para: {nombre}",
                     font=FONT_SMALL, bg=C["bg"], fg=C["subtexto"]).pack(anchor="w", pady=(0, 4))

            pasos = []
            if self.app.motor:
                pasos = self.app.motor.obtener_tratamiento(diag_principal)

            if pasos:
                for i, paso in enumerate(pasos, 1):
                    fila = tk.Frame(self._col_trat, bg=C["panel"],
                                    highlightbackground=C["borde"], highlightthickness=1)
                    fila.pack(fill="x", pady=2, ipadx=8, ipady=6)
                    tk.Label(fila, text=f"{i}.", font=FONT_BOLD,
                             bg=C["panel"], fg=C["verde"]).pack(side="left", padx=(4, 6))
                    tk.Label(fila, text=paso, font=FONT_SMALL,
                             bg=C["panel"], fg=C["texto"],
                             wraplength=280, justify="left").pack(side="left")
            else:
                tk.Label(self._col_trat,
                         text="(tratamiento no disponible)",
                         font=FONT_SMALL, bg=C["bg"],
                         fg=C["subtexto"]).pack(anchor="w")

    def _mostrar_explicacion(self):
        diags = self.app.ultimo_diagnostico
        if not diags:
            messagebox.showinfo("Explicación", "No hay diagnóstico que explicar.")
            return

        diag_principal = diags[0][0]

        ventana = tk.Toplevel(self)
        ventana.title(f"Explicación — {NOMBRES_ENFERMEDAD.get(diag_principal, diag_principal)}")
        ventana.geometry("560x440")
        ventana.configure(bg=C["bg"])

        tk.Label(ventana, text="¿Cómo llegó el sistema a este diagnóstico?",
                 font=FONT_BOLD, bg=C["bg"], fg=C["texto"]).pack(pady=(12, 4), padx=16)

        area = scrolledtext.ScrolledText(ventana, wrap="word",
                                         font=FONT_SMALL, bg=C["panel"],
                                         fg=C["texto"], padx=10, pady=10,
                                         relief="flat")
        area.pack(fill="both", expand=True, padx=16, pady=8)

        if self.app.motor:
            texto = self.app.motor.explicacion_texto(diag_principal)
            area.insert("end", texto)
        else:
            area.insert("end",
                f"Diagnóstico: {diag_principal}\n\n"
                "(Motor Prolog no disponible — modo demostración)")

        area.configure(state="disabled")

        tk.Button(ventana, text="Cerrar", font=FONT_NORMAL,
                  bg=C["verde"], fg="white", relief="flat",
                  padx=16, pady=6, cursor="hand2",
                  command=ventana.destroy).pack(pady=(0, 12))


# ─────────────────────────────────────────────────────────────
#  ENTRY POINT
# ─────────────────────────────────────────────────────────────
if __name__ == "__main__":
    app = AppFito()
    app.mainloop()