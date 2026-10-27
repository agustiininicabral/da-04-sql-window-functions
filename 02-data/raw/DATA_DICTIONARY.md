# Data Dictionary

## sales.csv — 3.500 registros
- `order_id` (text): identificador único del pedido.
- `customer_id` (text): identificador del cliente.
- `order_date` (date): fecha de compra.
- `category` (category): categoría del producto.
- `channel` (category): canal de venta.
- `country` (category): país.
- `city` (text): ciudad.
- `quantity` (int): unidades vendidas.
- `unit_price` (decimal): precio unitario.
- `discount_rate` (decimal): descuento aplicado, entre 0 y 0,20.
- `net_revenue` (decimal): ingresos netos.
- `cost` (decimal): costo estimado.
- `payment_method` (category): método de pago.
- `device` (category): dispositivo.

## products.csv — 500 productos
- `product_id` (text): identificador único del producto.
- `product_name` (text): nombre del producto.
- `category` (category): categoría del catálogo.
- `brand` (category): marca ficticia.
- `active` (Yes/No): estado del producto.

## Limitaciones de análisis

El archivo de ventas no contiene `product_id`; las funciones de ventana se calculan sobre pedidos, clientes, fechas, categorías y canales. Los datos son sintéticos.
