# Archivo de datos de db_test {#archivo}

El respaldo describe 26 tablas, 28 vistas, 39 triggers y 3 procedimientos. Su contenido es una fotografía del esquema, no una consulta al servidor actual.

- Las claves y restricciones proceden de las definiciones SQL del respaldo.
- Los nombres y clasificaciones de significado son interpretaciones cuando no hay comentario explícito.
- Los tipos de las columnas de vistas necesitan comprobarse en un servidor MySQL.

@answer scope="Respaldo 10/28 · definiciones, sin registros"
@meta locale=es

## ¿Cómo se relaciona la compra? {#compra}

@erd id=compra-modelo title="Relaciones declaradas de compra"
| entity usuario | tb_users |
| entity carrito | tb_carts |
| entity pedido | tb_buyer_orders |
| entity pago | tb_payments |
| usuario.ID | int | pk |
| carrito.ID | int unsigned | pk |
| carrito.user_ID | int | fk | usuario.ID |
| pedido.ID | int unsigned | pk |
| pedido.buyer_user_ID | int | fk | usuario.ID |
| pago.ID | int unsigned | pk |
| pago.order_ID | int unsigned | fk | pedido.ID |
| carrito > usuario | many:one | pertenece a |
| pedido > usuario | many:one | compra |
| pago > pedido | many:one | paga |

## ¿Qué significa que un campo se omita? {#insercion}

Un campo que admite `NULL` acepta la ausencia explícita de valor. Omitirlo significa no mencionarlo al insertar. Un valor automático o predeterminado puede permitir omitir un campo que no admite `NULL`.

## ¿Dónde están los detalles? {#detalle}

El diccionario interactivo acompaña esta vista con cada columna y sus restricciones. El anexo contiene las definiciones, sin registros ni cuentas DEFINER.
