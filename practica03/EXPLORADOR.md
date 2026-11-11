# EER / Schema Atlas · DB_TEST

Abrir `modelo-eer.html` directamente en un navegador. El visor contiene sus datos,
estilos y JavaScript; funciona sin servidor, conexión a MySQL ni dependencias
externas. Este es el archivo que se debe abrir o compartir.

## Uso

- Buscar tablas, columnas o tipos; Ctrl+K / Cmd+K enfoca la búsqueda.
- Filtrar todas las tablas, las que tienen datos o las vacías. Las métricas
  superiores muestran los totales correspondientes a las tablas visibles.
- Cambiar entre distribución jerárquica LR y orgánica/grid.
- Mostrar u ocultar tipos y colapsar o expandir las tarjetas.
- Seleccionar tablas, columnas o conectores para consultar restricciones y
  relaciones; Escape cierra los detalles.
- Arrastrar los encabezados para mover tablas y el fondo para desplazar el lienzo.
- Usar la rueda, los controles de zoom y el minimapa para navegar. El botón
  Ajustar al lienzo o la tecla F encuadra todas las tablas visibles.
- Resaltar columnas mediante la leyenda PK, FK, UQ, NN y AI.
- Exportar las tablas y relaciones visibles como SVG o PNG.

Las posiciones y filtros no se guardan entre sesiones.

## Origen de información

El visor actual se generó a partir de `backups/respaldo10_20.sql`: 16 tablas,
137 columnas, 10,130 registros y 20 restricciones de llave foránea. Tres FK son
compuestas, por lo que se representan 23 pares de columnas.

Los conteos provienen de las sentencias INSERT del respaldo; no son consultas
al servidor actual. Solo se incorporan metadatos y conteos, no los valores de
las filas. Las relaciones corresponden a las FK declaradas en el SQL y sus
cardinalidades reflejan restricciones del esquema. UQ puede indicar pertenencia
a un índice compuesto; consultar el detalle para ver sus columnas.

## Archivos y regeneración

- `modelo-eer.html`: visor final autocontenido.
- `modelo-eer.template.html`: plantilla editable de diseño y comportamiento.
- `generar_modelo_eer.py`: extrae el esquema y los conteos e incorpora los datos
  en la plantilla.

Desde la raíz del repositorio:

```powershell
python practica03/generar_modelo_eer.py
```

El generador sobrescribe `modelo-eer.html` y escribe el modelo complementario
de Archify en `.archify/erd-db-test/candidate.json`. Prefiere explícitamente
`respaldo10_20.sql`; solo si falta selecciona el archivo `.sql` de `backups/`
con fecha de modificación más reciente. Para usar un respaldo posterior mientras
exista el del 20/10, actualizar la variable `preferred` antes de regenerar.
El parser está adaptado a la sintaxis del respaldo del proyecto.

El visor fue comprobado en Edge mediante 20 verificaciones, incluyendo búsqueda,
filtros, navegación, arrastre, FK compuestas y generación de SVG/PNG. Se revisaron
capturas de escritorio. No se conectó a MySQL para contrastar el estado actual.
