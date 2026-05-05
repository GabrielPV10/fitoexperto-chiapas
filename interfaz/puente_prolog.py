# ============================================================
#  FitoExperto-Chiapas
#  interfaz/puente_prolog.py  —  Puente Python ↔ SWI-Prolog
#
#  Encapsula toda la comunicación con PySWIP.
#  La GUI nunca importa pyswip directamente; solo usa esta clase.
# ============================================================

import os
import sys

# -- Ayuda a Windows encontrar la DLL de SWI-Prolog ----------
# Ajusta esta ruta si tu instalación está en otro directorio.
_SWI_DEFAULT = r"C:\Program Files\swipl"
if sys.platform == "win32" and os.path.isdir(_SWI_DEFAULT):
    os.environ.setdefault("SWI_HOME_DIR", _SWI_DEFAULT)

from pyswip import Prolog  # noqa: E402  (importación después del env)


class MotorFito:
    """
    Interfaz de alto nivel hacia el motor de inferencia Prolog.

    Uso básico:
        motor = MotorFito()
        motor.iniciar_consulta("cafe")
        motor.registrar_sintoma("polvo_amarillo_naranja_enves")
        motor.registrar_sintoma("manchas_amarillas_haz")
        motor.registrar_sintoma("defoliacion_progresiva")
        resultados = motor.diagnosticar()
        # [("roya", "alta_certeza")]
    """

    # Rutas relativas a la raíz del proyecto
    _KB_FILES = [
        "kb/kb_cafe.pl",
        "kb/kb_maiz.pl",
        "motor/inferencia.pl",
        "motor/explicacion.pl",
    ]

    def __init__(self, base_dir: str = None):
        """
        Parámetros
        ----------
        base_dir : str, opcional
            Ruta absoluta a la raíz del proyecto.
            Si se omite, se usa el directorio donde está este archivo.
        """
        self._base = base_dir or os.path.dirname(os.path.abspath(__file__))
        self._prolog = Prolog()
        self._cargar_base()

    # ----------------------------------------------------------
    #  CARGA DE ARCHIVOS
    # ----------------------------------------------------------
    def _cargar_base(self):
        for relpath in self._KB_FILES:
            ruta = os.path.join(self._base, relpath).replace("\\", "/")
            if not os.path.isfile(ruta):
                raise FileNotFoundError(
                    f"No se encontró el archivo de conocimiento: {ruta}\n"
                    f"Verifica que base_dir apunte a la raíz del proyecto."
                )
            self._prolog.consult(ruta)

    # ----------------------------------------------------------
    #  SESIÓN
    # ----------------------------------------------------------
    def iniciar_consulta(self, cultivo: str):
        """
        Inicia una nueva sesión de diagnóstico para 'cafe' o 'maiz'.
        Limpia toda la memoria de trabajo anterior.
        """
        list(self._prolog.query(f"iniciar_consulta({cultivo})"))

    def limpiar_sesion(self):
        """Limpia la memoria de trabajo sin iniciar nuevo cultivo."""
        list(self._prolog.query("limpiar_sesion"))

    # ----------------------------------------------------------
    #  REGISTRO DE SÍNTOMAS
    # ----------------------------------------------------------
    def registrar_sintoma(self, sintoma: str):
        """
        Registra un síntoma observado en la sesión actual.
        El síntoma debe ser un átomo Prolog en minúsculas y sin espacios,
        p.ej. 'polvo_amarillo_naranja_enves'.
        """
        list(self._prolog.query(f"registrar_sintoma({sintoma})"))

    def registrar_multiples(self, sintomas: list):
        """Registra una lista de síntomas de una sola vez."""
        for s in sintomas:
            self.registrar_sintoma(s)

    # ----------------------------------------------------------
    #  DIAGNÓSTICO
    # ----------------------------------------------------------
    def diagnosticar(self) -> list:
        """
        Retorna lista de tuplas (diagnostico, certeza) ordenada:
        alta_certeza primero.
        Ejemplo: [("roya", "alta_certeza"), ("mancha_hierro", "media_certeza")]
        """
        raw = list(self._prolog.query("diagnosticar(D, C)"))
        # Ordenar: alta_certeza antes que media_certeza
        orden = {"alta_certeza": 0, "media_certeza": 1}
        resultados = [(str(r["D"]), str(r["C"])) for r in raw]
        resultados.sort(key=lambda x: orden.get(x[1], 99))
        return resultados

    def primer_diagnostico(self):
        """
        Retorna solo el diagnóstico de mayor certeza como tupla,
        o None si no hay diagnóstico posible.
        """
        diags = self.diagnosticar()
        return diags[0] if diags else None

    def hay_diagnostico(self) -> bool:
        return bool(self.diagnosticar())

    # ----------------------------------------------------------
    #  TRATAMIENTO
    # ----------------------------------------------------------
    def obtener_tratamiento(self, diagnostico: str) -> list:
        """
        Retorna la lista de pasos de tratamiento para un diagnóstico.
        """
        raw = list(self._prolog.query(f"obtener_tratamiento({diagnostico}, L)"))
        if not raw:
            return []
        # L llega como lista de bytes en PySWIP; convertir a strings
        return [item.decode() if isinstance(item, bytes) else str(item)
                for item in raw[0]["L"]]

    # ----------------------------------------------------------
    #  SÍNTOMAS
    # ----------------------------------------------------------
    def sintomas_registrados(self) -> list:
        """Retorna los síntomas marcados en la sesión actual."""
        raw = list(self._prolog.query("sintomas_registrados(L)"))
        if not raw:
            return []
        return [str(s) for s in raw[0]["L"]]

    def sintomas_faltantes(self, diagnostico: str) -> list:
        """
        Retorna síntomas característicos del diagnóstico que aún
        no se han observado. Útil para sugerir al usuario qué revisar.
        """
        raw = list(self._prolog.query(f"sintomas_faltantes({diagnostico}, F)"))
        if not raw:
            return []
        return [str(s) for s in raw[0]["F"]]

    # ----------------------------------------------------------
    #  EXPLICACIÓN
    # ----------------------------------------------------------
    def explicacion_texto(self, diagnostico: str) -> str:
        """
        Retorna un string explicativo listo para mostrar en la GUI.
        """
        raw = list(self._prolog.query(f"explicacion_texto({diagnostico}, T)"))
        if not raw:
            return f"Sin explicación disponible para: {diagnostico}"
        texto = raw[0]["T"]
        return texto.decode() if isinstance(texto, bytes) else str(texto)

    def reglas_activadas(self) -> list:
        """Retorna las reglas Prolog que se dispararon en la sesión."""
        raw = list(self._prolog.query("reglas_activadas(L)"))
        if not raw:
            return []
        return [(str(r[0]), str(r[1])) for r in raw[0]["L"]]

    # ----------------------------------------------------------
    #  ALERTAS Y SEVERIDAD
    # ----------------------------------------------------------
    def alertas(self) -> list:
        return [str(r["A"]) for r in self._prolog.query("alerta(A)")]

    def severidad(self) -> str:
        raw = list(self._prolog.query("severidad(S)"))
        return str(raw[0]["S"]) if raw else "no_determinada"

    def recomendaciones(self) -> list:
        return [str(r["R"]) for r in self._prolog.query("recomendacion(R)")]