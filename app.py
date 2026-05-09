# ============================================================
#  FitoExperto-Chiapas
#  app.py  —  Punto de entrada principal
#
#  Ejecutar desde la raíz del proyecto:
#    python app.py
# ============================================================

import sys
import os

# Agrega la carpeta 'interfaz' al path para que los imports funcionen
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "interfaz"))

from interfaz.gui import AppFito

if __name__ == "__main__":
    app = AppFito()
    app.mainloop()