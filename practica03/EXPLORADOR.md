# Atlas de datos · 240687

Abrir `explorador-eer.html` directamente en un navegador. No requiere instalar
dependencias ni iniciar un servidor. Es un explorador documental local, escrito
para este proyecto; no fue generado con Archify, cuya integración no está
disponible en esta sesión. No modifica `modelo-eer.html` del compañero.

## Uso

- Buscar tablas o columnas y filtrar entidades, catálogos, detalles o bitácora.
- Seleccionar una tabla desde el panel lateral o su encabezado.
- Consultar resumen, claves únicas, auditoría documentada, relaciones y DDL.
- Navegar a otra tabla desde el panel de relaciones.
- Arrastrar encabezados para reorganizar tablas y el fondo para desplazarse.
- Usar la rueda o los botones para cambiar el zoom; Encuadrar ajusta el modelo.
- Restablecer recupera distribución y filtros iniciales. Las posiciones no se
  guardan entre sesiones.
- Exportar SVG descarga las tablas y relaciones visibles en su posición actual.
- Ctrl+K enfoca la búsqueda; Escape cierra el panel de detalles.

## Origen de información

Combina las cuatro tablas de `backups/respaldo10_14.sql` con las doce adicionales
de `scripts/create_ecommerce_tables.sql`. Para tablas existentes prevalece el
respaldo. Obtiene los nombres de triggers del respaldo y del script de auditoría,
y los nombres de vistas según las convenciones de los scripts del proyecto.

Los conteos son del respaldo, no del servidor actual. Las tablas de ampliación
muestran `s/d`: no se supone que estén vacías ni se confirma su instalación.
Solo dibuja claves foráneas declaradas; la jerarquía de categorías se explica
como pendiente porque su FK no aparece en el respaldo. No incluye filas de
usuarios, contraseñas, datos de pago ni credenciales de conexión.

Las flechas apuntan desde la tabla que contiene la FK hacia la referenciada;
no representan una notación completa de cardinalidad EER. Los catálogos de
estados conservan la interpretación provisional del diseño SQL.

## Regeneración

Desde la raíz del repositorio:

```powershell
python practica03/scripts/generate_eer_explorer.py
```

El generador usa `scripts/eer_explorer_template.html` y sobrescribe solamente
`explorador-eer.html`. El parser admite la sintaxis usada en los archivos actuales;
no es un parser general de MySQL. Para reflejar cambios en el servidor, actualizar
las fuentes y revisar el generador antes de regenerar.

Validación realizada: sintaxis JavaScript con Node, referencias DOM, 16 tablas,
137 columnas, 20 FK con columnas válidas y 45 triggers documentados. Pendiente
prueba visual e interacción en navegador y contraste con el servidor MySQL local.
