# Data Dictionary

## sales.csv — 3.500 registros

Una fila representa un pedido. El período cubierto es enero de 2024 a diciembre de 2025.

- `order_id` (text): identificador único del pedido.
- `customer_id` (text): identificador del cliente.
- `order_date` (date): fecha de compra en formato ISO.
- `category` (category): categoría del producto.
- `channel` (category): canal atribuido a la venta.
- `country` (category): país.
- `city` (text): ciudad.
- `quantity` (int): unidades vendidas.
- `unit_price` (decimal): precio unitario.
- `discount_rate` (decimal): descuento aplicado entre 0 y 0,20.
- `net_revenue` (decimal): ingresos netos, calculados como cantidad × precio × (1 − descuento).
- `cost` (decimal): costo estimado.
- `payment_method` (category): método de pago.
- `device` (category): dispositivo.

## products.csv — 500 productos

- `product_id` (text): identificador único del producto.
- `product_name` (text): nombre del producto.
- `category` (category): categoría del catálogo.
- `brand` (category): marca ficticia.
- `active` (Yes/No): estado de actividad.

## Relaciones y limitaciones

- `order_id` identifica cada pedido en ventas.
- `sales.csv` no contiene `product_id`; no se puede relacionar una venta con un producto individual.
- Las métricas monetarias son ficticias y no están asociadas a una moneda real.
- Los clientes activos en cohortes se definen por la existencia de al menos un pedido en el mes calendario.
