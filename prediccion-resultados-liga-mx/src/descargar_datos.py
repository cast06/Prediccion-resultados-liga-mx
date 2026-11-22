"""Descarga el histórico de partidos de la Liga MX desde football-data.co.uk.

Uso:
    python src/descargar_datos.py
"""

from pathlib import Path
from urllib.request import urlretrieve

URL_DATOS = "https://www.football-data.co.uk/new/MEX.csv"
RUTA_SALIDA = Path(__file__).resolve().parents[1] / "data" / "raw" / "MEX.csv"


def main() -> None:
    RUTA_SALIDA.parent.mkdir(parents=True, exist_ok=True)
    print(f"Descargando {URL_DATOS} ...")
    urlretrieve(URL_DATOS, RUTA_SALIDA)
    print(f"Archivo guardado en {RUTA_SALIDA}")


if __name__ == "__main__":
    main()
