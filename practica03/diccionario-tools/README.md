# Extracción y verificación del diccionario

El sitio de `../diccionario-publico/` es estático y no se conecta a MySQL.
La fuente confirmada es `../backups/dicionario.sql`, un volcado MySQL 8.4.13.
No se ejecuta el SQL ni se insertan sus registros. La huella SHA-256 aparece
en `schema.json` y en la interfaz para identificar exactamente la entrada.

## Generar y probar

Con Node.js 20 o posterior, desde la raíz del repositorio:

```powershell
node practica03/diccionario-tools/generate.mjs
node --test practica03/diccionario-tools/test.mjs
node practica03/diccionario-tools/serve.mjs
```

Abre `http://127.0.0.1:4173/Practicas_BDN_240687/`. Las páginas consumen
`schema.json` mediante `fetch`; por ello la vista local requiere HTTP y no
funciona al abrir directamente `file://`. También se pueden especificar la
entrada y salida: `node practica03/diccionario-tools/generate.mjs RUTA_SQL RUTA_SCHEMA_JSON`.
El CSV y el anexo se escriben junto al JSON de salida.
Con el servidor activo, `node --test practica03/diccionario-tools/test-http.mjs`
comprueba los recursos y las rutas relativas bajo un prefijo equivalente al de
GitHub Pages.

## Extracción

`sql-parser.mjs` reconoce el delimitador del cliente, cadenas y comentarios
ejecutables `/*!...*/`, separa sentencias sin ejecutar el respaldo y construye
un único modelo que consumen las dos páginas. Se comprueban columnas de ambos
extremos de cada clave foránea y la correspondencia de sus componentes. El
generador falla si detecta construcciones no interpretadas o cargas cuyo conteo
no pueda determinarse con este método.

El conteo expresa **tuplas VALUES de INSERT de nivel superior** incluidas en el
respaldo. No cuenta INSERT dentro de rutinas o triggers y no afirma que una
restauración haya tenido éxito ni que la base activa conserve ese estado.
`INSERT IGNORE`, `INSERT ... SELECT`, `REPLACE`, `LOAD DATA`, cambios posteriores
de datos, modos `NO_BACKSLASH_ESCAPES`/`ANSI_QUOTES` o cambios estructurales
`ALTER TABLE` distintos de ENABLE/DISABLE KEYS requieren ampliar y verificar el
parser; no se asigna cero silenciosamente.

Las vistas temporales del volcado sirven solo para recuperar sus alias; se
conserva la vista final y no se infieren tipos ni nulabilidad del SELECT ficticio.
Las cardinalidades se deducen de NULL y claves declaradas, y los dominios de
negocio, escalas y explicaciones semánticas son interpretaciones. Cada índice
físico se cuenta una vez como PRIMARY, UNIQUE u otro; sus restricciones se
presentan separadamente y no se suman de nuevo.

El sitio no incluye las filas de las tablas ni las cuentas `DEFINER`. El anexo
contiene definiciones para lectura, sin cuentas DEFINER y sin INSERT del volcado;
no es un script de restauración. Antes de publicarlo se buscan posibles claves
o credenciales en definiciones. El respaldo original no es parte del directorio
público del sitio.

Las pruebas contrastan la extracción contra un segundo análisis orientado a las
líneas del volcado de este proyecto, incluidas columnas, índices, CHECK, FK,
objetos programables y tuplas de INSERT. Incluyen casos sintéticos con comillas,
comas, saltos de línea y delimitadores. Las páginas se verifican además en un
navegador con el prefijo de ruta de GitHub Pages.

Para repetir la batería automatizada de navegador, instala Playwright solo como
dependencia de desarrollo en tu entorno, inicia `serve.mjs` en otra terminal y
ejecuta `node --test practica03/diccionario-tools/test-browser.mjs`. Puedes usar
`DOCS_BASE_URL` para probar otra URL. Playwright y su navegador no se distribuyen
en el sitio publicado.
