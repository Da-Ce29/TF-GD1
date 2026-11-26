CREATE DATABASE BD_VegaMarket;
GO

USE BD_VegaMarket;
GO

SELECT DB_NAME() AS BaseActual;
GO

CREATE TABLE dbo.SUCURSAL
(
    id_sucursal INT NOT NULL,
    distrito NVARCHAR(80) NOT NULL,
    direccion NVARCHAR(180) NOT NULL,

    CONSTRAINT PK_SUCURSAL
        PRIMARY KEY (id_sucursal)
);
GO

CREATE TABLE dbo.EMPLEADO
(
    dni_empleado CHAR(8) NOT NULL,
    nombre NVARCHAR(120) NOT NULL,
    turno VARCHAR(10) NOT NULL,
    id_sucursal INT NOT NULL,

    CONSTRAINT PK_EMPLEADO
        PRIMARY KEY (dni_empleado),

    CONSTRAINT UQ_EMPLEADO_DNI_SUCURSAL
        UNIQUE (dni_empleado, id_sucursal),

    CONSTRAINT FK_EMPLEADO_SUCURSAL
        FOREIGN KEY (id_sucursal)
        REFERENCES dbo.SUCURSAL (id_sucursal),

    CONSTRAINT CK_EMPLEADO_TURNO
        CHECK
        (
            turno IN
            (
                'MANANA',
                'TARDE',
                'NOCHE'
            )
        )
);
GO

CREATE TABLE dbo.PRODUCTO
(
    codigo_prod VARCHAR(20) NOT NULL,
    nombre NVARCHAR(120) NOT NULL,
    precio DECIMAL(10,2) NOT NULL,

    CONSTRAINT PK_PRODUCTO
        PRIMARY KEY (codigo_prod),

    CONSTRAINT CK_PRODUCTO_PRECIO
        CHECK (precio > 0)
);
GO

CREATE TABLE dbo.LOTE_INVENTARIO
(
    id_lote INT NOT NULL,
    codigo_prod VARCHAR(20) NOT NULL,
    id_sucursal INT NOT NULL,
    fecha_venc DATE NOT NULL,
    stock INT NOT NULL,

    CONSTRAINT PK_LOTE_INVENTARIO
        PRIMARY KEY (id_lote),

    CONSTRAINT FK_LOTE_PRODUCTO
        FOREIGN KEY (codigo_prod)
        REFERENCES dbo.PRODUCTO (codigo_prod),

    CONSTRAINT FK_LOTE_SUCURSAL
        FOREIGN KEY (id_sucursal)
        REFERENCES dbo.SUCURSAL (id_sucursal),

    CONSTRAINT CK_LOTE_STOCK
        CHECK (stock >= 0),

    CONSTRAINT UQ_LOTE_PRODUCTO_SUCURSAL_VENCIMIENTO
        UNIQUE
        (
            codigo_prod,
            id_sucursal,
            fecha_venc
        )
);
GO

CREATE TABLE dbo.TICKET
(
    num_ticket INT NOT NULL,
    dni_empleado CHAR(8) NOT NULL,
    id_sucursal INT NOT NULL,
    fecha DATE NOT NULL,
    hora TIME(0) NOT NULL,

    CONSTRAINT PK_TICKET
        PRIMARY KEY (num_ticket),

    CONSTRAINT FK_TICKET_EMPLEADO_SUCURSAL
        FOREIGN KEY
        (
            dni_empleado,
            id_sucursal
        )
        REFERENCES dbo.EMPLEADO
        (
            dni_empleado,
            id_sucursal
        )
);
GO

CREATE TABLE dbo.DETALLE_TICKET
(
    num_ticket INT NOT NULL,
    codigo_prod VARCHAR(20) NOT NULL,
    cantidad INT NOT NULL,
    precio_venta DECIMAL(10,2) NOT NULL,

    subtotal AS
    (
        CONVERT
        (
            DECIMAL(12,2),
            cantidad * precio_venta
        )
    ) PERSISTED,

    CONSTRAINT PK_DETALLE_TICKET
        PRIMARY KEY
        (
            num_ticket,
            codigo_prod
        ),

    CONSTRAINT FK_DETALLE_TICKET
        FOREIGN KEY (num_ticket)
        REFERENCES dbo.TICKET (num_ticket),

    CONSTRAINT FK_DETALLE_PRODUCTO
        FOREIGN KEY (codigo_prod)
        REFERENCES dbo.PRODUCTO (codigo_prod),

    CONSTRAINT CK_DETALLE_CANTIDAD
        CHECK (cantidad > 0),

    CONSTRAINT CK_DETALLE_PRECIO_VENTA
        CHECK (precio_venta > 0)
);
GO

INSERT INTO dbo.SUCURSAL
(
    id_sucursal,
    distrito,
    direccion
)
VALUES
(
    1,
    N'Ate',
    N'Av. Separadora Industrial 1250'
),
(
    2,
    N'San Juan de Lurigancho',
    N'Av. Próceres de la Independencia 1840'
),
(
    3,
    N'Comas',
    N'Av. Túpac Amaru 5400'
),
(
    4,
    N'Los Olivos',
    N'Av. Carlos Izaguirre 920'
),
(
    5,
    N'San Martín de Porres',
    N'Av. Perú 3050'
);
GO

INSERT INTO dbo.EMPLEADO
(
    dni_empleado,
    nombre,
    turno,
    id_sucursal
)
VALUES
(
    '45000001',
    N'Ana Torres Ramos',
    'MANANA',
    1
),
(
    '45000002',
    N'Luis Mendoza Ruiz',
    'TARDE',
    2
),
(
    '45000003',
    N'Carla Paredes Soto',
    'NOCHE',
    3
),
(
    '45000004',
    N'José Rojas Díaz',
    'MANANA',
    4
),
(
    '45000005',
    N'María Salazar León',
    'TARDE',
    5
);
GO

INSERT INTO dbo.PRODUCTO
(
    codigo_prod,
    nombre,
    precio
)
VALUES
(
    'P001',
    N'Arroz extra 1 kg',
    5.90
),
(
    'P002',
    N'Leche evaporada 400 g',
    4.50
),
(
    'P003',
    N'Aceite vegetal 1 L',
    10.90
),
(
    'P004',
    N'Gaseosa cola 1.5 L',
    7.50
),
(
    'P005',
    N'Galletas de vainilla',
    2.80
);
GO

INSERT INTO dbo.LOTE_INVENTARIO
(
    id_lote,
    codigo_prod,
    id_sucursal,
    fecha_venc,
    stock
)
VALUES
(
    1,
    'P001',
    1,
    '2027-05-15',
    80
),
(
    2,
    'P002',
    2,
    '2026-12-10',
    45
),
(
    3,
    'P003',
    3,
    '2027-08-20',
    35
),
(
    4,
    'P004',
    4,
    '2027-02-28',
    60
),
(
    5,
    'P005',
    5,
    '2027-01-15',
    100
);
GO

INSERT INTO dbo.TICKET
(
    num_ticket,
    dni_empleado,
    id_sucursal,
    fecha,
    hora
)
VALUES
(
    1001,
    '45000001',
    1,
    '2026-11-01',
    '08:15:00'
),
(
    1002,
    '45000002',
    2,
    '2026-11-02',
    '15:40:00'
),
(
    1003,
    '45000003',
    3,
    '2026-11-03',
    '21:10:00'
),
(
    1004,
    '45000004',
    4,
    '2026-11-04',
    '09:25:00'
),
(
    1005,
    '45000005',
    5,
    '2026-11-05',
    '17:20:00'
);
GO

INSERT INTO dbo.DETALLE_TICKET
(
    num_ticket,
    codigo_prod,
    cantidad,
    precio_venta
)
VALUES
(
    1001,
    'P001',
    2,
    5.90
),
(
    1002,
    'P002',
    3,
    4.50
),
(
    1003,
    'P003',
    1,
    10.90
),
(
    1004,
    'P004',
    2,
    7.50
),
(
    1005,
    'P005',
    4,
    2.80
);
GO

SELECT
    TABLE_SCHEMA AS Esquema,
    TABLE_NAME AS Tabla
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;
GO

SELECT *
FROM dbo.SUCURSAL;
GO

SELECT *
FROM dbo.EMPLEADO;
GO

SELECT *
FROM dbo.PRODUCTO;
GO

SELECT *
FROM dbo.LOTE_INVENTARIO;
GO

SELECT *
FROM dbo.TICKET;
GO

SELECT *
FROM dbo.DETALLE_TICKET;
GO

SELECT
    T.num_ticket,
    T.fecha,
    T.hora,

    S.id_sucursal,
    S.distrito AS sucursal,

    E.dni_empleado,
    E.nombre AS empleado,
    E.turno,

    P.codigo_prod,
    P.nombre AS producto,

    D.cantidad,
    D.precio_venta,
    D.subtotal

FROM dbo.TICKET AS T

INNER JOIN dbo.SUCURSAL AS S
    ON T.id_sucursal = S.id_sucursal

INNER JOIN dbo.EMPLEADO AS E
    ON T.dni_empleado = E.dni_empleado
   AND T.id_sucursal = E.id_sucursal

INNER JOIN dbo.DETALLE_TICKET AS D
    ON T.num_ticket = D.num_ticket

INNER JOIN dbo.PRODUCTO AS P
    ON D.codigo_prod = P.codigo_prod

ORDER BY T.num_ticket;
GO

SELECT
    T.num_ticket,
    T.fecha,
    S.distrito AS sucursal,
    E.nombre AS empleado,
    SUM(D.subtotal) AS total_ticket

FROM dbo.TICKET AS T

INNER JOIN dbo.SUCURSAL AS S
    ON T.id_sucursal = S.id_sucursal

INNER JOIN dbo.EMPLEADO AS E
    ON T.dni_empleado = E.dni_empleado
   AND T.id_sucursal = E.id_sucursal

INNER JOIN dbo.DETALLE_TICKET AS D
    ON T.num_ticket = D.num_ticket

GROUP BY
    T.num_ticket,
    T.fecha,
    S.distrito,
    E.nombre

ORDER BY T.num_ticket;
GO

SELECT
    S.id_sucursal,
    S.distrito,

    COUNT(DISTINCT T.num_ticket)
        AS cantidad_tickets,

    SUM(D.subtotal)
        AS venta_total

FROM dbo.SUCURSAL AS S

INNER JOIN dbo.TICKET AS T
    ON S.id_sucursal = T.id_sucursal

INNER JOIN dbo.DETALLE_TICKET AS D
    ON T.num_ticket = D.num_ticket

GROUP BY
    S.id_sucursal,
    S.distrito

ORDER BY venta_total DESC;
GO

SELECT
    L.id_lote,
    P.codigo_prod,
    P.nombre AS producto,

    S.id_sucursal,
    S.distrito AS sucursal,

    L.fecha_venc,
    L.stock

FROM dbo.LOTE_INVENTARIO AS L

INNER JOIN dbo.PRODUCTO AS P
    ON L.codigo_prod = P.codigo_prod

INNER JOIN dbo.SUCURSAL AS S
    ON L.id_sucursal = S.id_sucursal

ORDER BY
    L.fecha_venc,
    S.distrito,
    P.nombre;
GO

SELECT
    S.id_sucursal,
    S.distrito,

    P.codigo_prod,
    P.nombre AS producto,

    SUM(L.stock) AS stock_total

FROM dbo.LOTE_INVENTARIO AS L

INNER JOIN dbo.PRODUCTO AS P
    ON L.codigo_prod = P.codigo_prod

INNER JOIN dbo.SUCURSAL AS S
    ON L.id_sucursal = S.id_sucursal

GROUP BY
    S.id_sucursal,
    S.distrito,
    P.codigo_prod,
    P.nombre

ORDER BY
    S.id_sucursal,
    P.nombre;
GO

SELECT
    L.id_lote,
    P.codigo_prod,
    P.nombre AS producto,
    S.distrito AS sucursal,
    L.fecha_venc,
    L.stock

FROM dbo.LOTE_INVENTARIO AS L

INNER JOIN dbo.PRODUCTO AS P
    ON L.codigo_prod = P.codigo_prod

INNER JOIN dbo.SUCURSAL AS S
    ON L.id_sucursal = S.id_sucursal

WHERE L.fecha_venc
    BETWEEN '2026-11-22'
        AND DATEADD
            (
                DAY,
                60,
                '2026-11-22'
            )

ORDER BY L.fecha_venc;
GO

SELECT
    L.id_lote,
    P.nombre AS producto,
    S.distrito AS sucursal,
    L.stock,
    L.fecha_venc

FROM dbo.LOTE_INVENTARIO AS L

INNER JOIN dbo.PRODUCTO AS P
    ON L.codigo_prod = P.codigo_prod

INNER JOIN dbo.SUCURSAL AS S
    ON L.id_sucursal = S.id_sucursal

WHERE L.stock < 50

ORDER BY L.stock ASC;
GO

SELECT
    E.dni_empleado,
    E.nombre AS empleado,
    E.turno,

    S.distrito AS sucursal,

    COUNT(DISTINCT T.num_ticket)
        AS cantidad_tickets,

    SUM(D.subtotal)
        AS venta_total

FROM dbo.EMPLEADO AS E

INNER JOIN dbo.SUCURSAL AS S
    ON E.id_sucursal = S.id_sucursal

INNER JOIN dbo.TICKET AS T
    ON E.dni_empleado = T.dni_empleado
   AND E.id_sucursal = T.id_sucursal

INNER JOIN dbo.DETALLE_TICKET AS D
    ON T.num_ticket = D.num_ticket

GROUP BY
    E.dni_empleado,
    E.nombre,
    E.turno,
    S.distrito

ORDER BY venta_total DESC;
GO

BEGIN TRANSACTION;
GO

UPDATE dbo.PRODUCTO
SET precio = 11.50
WHERE codigo_prod = 'P003';
GO

UPDATE dbo.LOTE_INVENTARIO
SET stock = stock - 4
WHERE id_lote = 5;
GO

UPDATE dbo.EMPLEADO
SET turno = 'NOCHE'
WHERE dni_empleado = '45000002';
GO

DELETE FROM dbo.LOTE_INVENTARIO
WHERE id_lote = 2;
GO

DELETE FROM dbo.DETALLE_TICKET
WHERE num_ticket = 1001;
GO

DELETE FROM dbo.TICKET
WHERE num_ticket = 1001;
GO

SELECT * FROM dbo.PRODUCTO;
SELECT * FROM dbo.LOTE_INVENTARIO;
SELECT * FROM dbo.EMPLEADO;
SELECT * FROM dbo.TICKET;
GO

ROLLBACK TRANSACTION;
GO

DELETE FROM dbo.PRODUCTO
WHERE codigo_prod = 'P001';
GO

CREATE VIEW dbo.vw_detalle_ventas
AS
SELECT
    T.num_ticket,
    T.fecha,
    T.hora,
    S.distrito AS sucursal,
    E.nombre AS empleado,
    E.turno,
    P.nombre AS producto,
    D.cantidad,
    D.precio_venta,
    D.subtotal

FROM dbo.TICKET AS T

INNER JOIN dbo.SUCURSAL AS S
    ON T.id_sucursal = S.id_sucursal

INNER JOIN dbo.EMPLEADO AS E
    ON T.dni_empleado = E.dni_empleado
   AND T.id_sucursal = E.id_sucursal

INNER JOIN dbo.DETALLE_TICKET AS D
    ON T.num_ticket = D.num_ticket

INNER JOIN dbo.PRODUCTO AS P
    ON D.codigo_prod = P.codigo_prod;
GO

CREATE VIEW dbo.vw_total_por_ticket
AS
SELECT
    T.num_ticket,
    T.fecha,
    S.distrito AS sucursal,
    E.nombre AS empleado,
    SUM(D.subtotal) AS total_ticket

FROM dbo.TICKET AS T

INNER JOIN dbo.SUCURSAL AS S
    ON T.id_sucursal = S.id_sucursal

INNER JOIN dbo.EMPLEADO AS E
    ON T.dni_empleado = E.dni_empleado
   AND T.id_sucursal = E.id_sucursal

INNER JOIN dbo.DETALLE_TICKET AS D
    ON T.num_ticket = D.num_ticket

GROUP BY
    T.num_ticket,
    T.fecha,
    S.distrito,
    E.nombre;
GO

CREATE VIEW dbo.vw_venta_por_sucursal
AS
SELECT
    S.id_sucursal,
    S.distrito,
    COUNT(DISTINCT T.num_ticket) AS cantidad_tickets,
    SUM(D.subtotal) AS venta_total

FROM dbo.SUCURSAL AS S

INNER JOIN dbo.TICKET AS T
    ON S.id_sucursal = T.id_sucursal

INNER JOIN dbo.DETALLE_TICKET AS D
    ON T.num_ticket = D.num_ticket

GROUP BY
    S.id_sucursal,
    S.distrito;
GO

CREATE VIEW dbo.vw_ventas_por_empleado
AS
SELECT
    E.dni_empleado,
    E.nombre AS empleado,
    E.turno,
    S.distrito AS sucursal,
    COUNT(DISTINCT T.num_ticket) AS cantidad_tickets,
    SUM(D.subtotal) AS venta_total

FROM dbo.EMPLEADO AS E

INNER JOIN dbo.SUCURSAL AS S
    ON E.id_sucursal = S.id_sucursal

INNER JOIN dbo.TICKET AS T
    ON E.dni_empleado = T.dni_empleado
   AND E.id_sucursal = T.id_sucursal

INNER JOIN dbo.DETALLE_TICKET AS D
    ON T.num_ticket = D.num_ticket

GROUP BY
    E.dni_empleado,
    E.nombre,
    E.turno,
    S.distrito;
GO

CREATE VIEW dbo.vw_lotes_por_vencer
AS
SELECT
    L.id_lote,
    P.nombre AS producto,
    S.distrito AS sucursal,
    L.stock,
    L.fecha_venc

FROM dbo.LOTE_INVENTARIO AS L

INNER JOIN dbo.PRODUCTO AS P
    ON L.codigo_prod = P.codigo_prod

INNER JOIN dbo.SUCURSAL AS S
    ON L.id_sucursal = S.id_sucursal

WHERE L.fecha_venc
    BETWEEN CAST(GETDATE() AS DATE)
        AND DATEADD(DAY, 60, CAST(GETDATE() AS DATE));
GO

CREATE VIEW dbo.vw_stock_bajo
AS
SELECT
    L.id_lote,
    P.nombre AS producto,
    S.distrito AS sucursal,
    L.stock,
    L.fecha_venc

FROM dbo.LOTE_INVENTARIO AS L

INNER JOIN dbo.PRODUCTO AS P
    ON L.codigo_prod = P.codigo_prod

INNER JOIN dbo.SUCURSAL AS S
    ON L.id_sucursal = S.id_sucursal

WHERE L.stock < 50;
GO

SELECT * FROM dbo.vw_detalle_ventas ORDER BY num_ticket;
SELECT * FROM dbo.vw_total_por_ticket ORDER BY num_ticket;
SELECT * FROM dbo.vw_venta_por_sucursal ORDER BY venta_total DESC;
SELECT * FROM dbo.vw_ventas_por_empleado ORDER BY venta_total DESC;
SELECT * FROM dbo.vw_lotes_por_vencer ORDER BY fecha_venc;
SELECT * FROM dbo.vw_stock_bajo ORDER BY stock;
GO

CREATE PROCEDURE dbo.sp_registrar_venta
    @num_ticket INT,
    @dni_empleado CHAR(8),
    @id_sucursal INT,
    @codigo_prod VARCHAR(20),
    @cantidad INT
AS
BEGIN
    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.EMPLEADO
        WHERE dni_empleado = @dni_empleado
          AND id_sucursal = @id_sucursal
    )
        THROW 50001, 'El empleado no pertenece a la sucursal.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.PRODUCTO
        WHERE codigo_prod = @codigo_prod
    )
        THROW 50002, 'El producto no existe.', 1;

    IF
    (
        SELECT ISNULL(SUM(stock), 0)
        FROM dbo.LOTE_INVENTARIO
        WHERE codigo_prod = @codigo_prod
          AND id_sucursal = @id_sucursal
    ) < @cantidad
        THROW 50003, 'Stock insuficiente.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO dbo.TICKET
            (num_ticket, dni_empleado, id_sucursal, fecha, hora)
        VALUES
            (
                @num_ticket,
                @dni_empleado,
                @id_sucursal,
                CAST(GETDATE() AS DATE),
                CAST(GETDATE() AS TIME(0))
            );

        INSERT INTO dbo.DETALLE_TICKET
            (num_ticket, codigo_prod, cantidad, precio_venta)
        SELECT
            @num_ticket,
            codigo_prod,
            @cantidad,
            precio
        FROM dbo.PRODUCTO
        WHERE codigo_prod = @codigo_prod;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO

CREATE PROCEDURE dbo.sp_actualizar_precio
    @codigo_prod VARCHAR(20),
    @nuevo_precio DECIMAL(10,2)
AS
BEGIN
    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.PRODUCTO
        WHERE codigo_prod = @codigo_prod
    )
        THROW 50004, 'El producto no existe.', 1;

    IF @nuevo_precio <= 0
        THROW 50005, 'El precio debe ser mayor que cero.', 1;

    UPDATE dbo.PRODUCTO
    SET precio = @nuevo_precio
    WHERE codigo_prod = @codigo_prod;
END;
GO

CREATE PROCEDURE dbo.sp_reponer_stock
    @codigo_prod VARCHAR(20),
    @id_sucursal INT,
    @fecha_venc DATE,
    @cantidad INT
AS
BEGIN
    IF @cantidad <= 0
        THROW 50006, 'La cantidad debe ser mayor que cero.', 1;

    IF EXISTS
    (
        SELECT 1
        FROM dbo.LOTE_INVENTARIO
        WHERE codigo_prod = @codigo_prod
          AND id_sucursal = @id_sucursal
          AND fecha_venc = @fecha_venc
    )
    BEGIN
        UPDATE dbo.LOTE_INVENTARIO
        SET stock = stock + @cantidad
        WHERE codigo_prod = @codigo_prod
          AND id_sucursal = @id_sucursal
          AND fecha_venc = @fecha_venc;
    END
    ELSE
    BEGIN
        INSERT INTO dbo.LOTE_INVENTARIO
            (id_lote, codigo_prod, id_sucursal, fecha_venc, stock)
        SELECT
            ISNULL(MAX(id_lote), 0) + 1,
            @codigo_prod,
            @id_sucursal,
            @fecha_venc,
            @cantidad
        FROM dbo.LOTE_INVENTARIO;
    END
END;
GO

CREATE PROCEDURE dbo.sp_reporte_ventas_sucursal
    @id_sucursal INT,
    @fecha_inicio DATE,
    @fecha_fin DATE
AS
BEGIN
    SELECT
        T.num_ticket,
        T.fecha,
        SUM(D.subtotal) AS total_ticket

    FROM dbo.TICKET AS T

    INNER JOIN dbo.DETALLE_TICKET AS D
        ON T.num_ticket = D.num_ticket

    WHERE T.id_sucursal = @id_sucursal
      AND T.fecha BETWEEN @fecha_inicio AND @fecha_fin

    GROUP BY
        T.num_ticket,
        T.fecha;

    SELECT
        ISNULL(SUM(D.subtotal), 0) AS total_periodo

    FROM dbo.TICKET AS T

    INNER JOIN dbo.DETALLE_TICKET AS D
        ON T.num_ticket = D.num_ticket

    WHERE T.id_sucursal = @id_sucursal
      AND T.fecha BETWEEN @fecha_inicio AND @fecha_fin;
END;
GO

CREATE PROCEDURE dbo.sp_anular_ticket
    @num_ticket INT
AS
BEGIN
    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.TICKET
        WHERE num_ticket = @num_ticket
    )
        THROW 50007, 'El ticket no existe.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;

        DELETE FROM dbo.DETALLE_TICKET
        WHERE num_ticket = @num_ticket;

        DELETE FROM dbo.TICKET
        WHERE num_ticket = @num_ticket;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO

BEGIN TRANSACTION;

EXEC dbo.sp_actualizar_precio 'P003', 11.50;
EXEC dbo.sp_reponer_stock 'P001', 1, '2027-05-15', 20;
EXEC dbo.sp_reponer_stock 'P002', 1, '2027-03-01', 30;

SELECT * FROM dbo.PRODUCTO;
SELECT * FROM dbo.LOTE_INVENTARIO;

ROLLBACK TRANSACTION;
GO

EXEC dbo.sp_reporte_ventas_sucursal 1, '2026-11-01', '2026-11-30';
GO

CREATE FUNCTION dbo.fn_total_ticket
(
    @num_ticket INT
)
RETURNS DECIMAL(12,2)
AS
BEGIN
    DECLARE @total DECIMAL(12,2);

    SELECT @total = ISNULL(SUM(subtotal), 0)
    FROM dbo.DETALLE_TICKET
    WHERE num_ticket = @num_ticket;

    RETURN @total;
END;
GO

CREATE FUNCTION dbo.fn_stock_producto_sucursal
(
    @codigo_prod VARCHAR(20),
    @id_sucursal INT
)
RETURNS INT
AS
BEGIN
    DECLARE @stock INT;

    SELECT @stock = ISNULL(SUM(stock), 0)
    FROM dbo.LOTE_INVENTARIO
    WHERE codigo_prod = @codigo_prod
      AND id_sucursal = @id_sucursal;

    RETURN @stock;
END;
GO

CREATE FUNCTION dbo.fn_dias_para_vencer
(
    @id_lote INT
)
RETURNS INT
AS
BEGIN
    DECLARE @dias INT;

    SELECT @dias = DATEDIFF(DAY, CAST(GETDATE() AS DATE), fecha_venc)
    FROM dbo.LOTE_INVENTARIO
    WHERE id_lote = @id_lote;

    RETURN @dias;
END;
GO

CREATE FUNCTION dbo.fn_ventas_por_empleado
(
    @dni_empleado CHAR(8)
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        T.num_ticket,
        T.fecha,
        dbo.fn_total_ticket(T.num_ticket) AS total_ticket

    FROM dbo.TICKET AS T

    WHERE T.dni_empleado = @dni_empleado
);
GO

SELECT dbo.fn_total_ticket(1001) AS total_ticket_1001;
SELECT dbo.fn_stock_producto_sucursal('P001', 1) AS stock_P001_Ate;
SELECT dbo.fn_dias_para_vencer(2) AS dias_para_vencer_lote_2;
SELECT * FROM dbo.fn_ventas_por_empleado('45000003');

SELECT
    num_ticket,
    dbo.fn_total_ticket(num_ticket) AS total_ticket
FROM dbo.TICKET;
GO

CREATE TABLE dbo.AUDITORIA_PRECIO
(
    id_auditoria INT IDENTITY(1,1) NOT NULL,
    codigo_prod VARCHAR(20) NOT NULL,
    precio_anterior DECIMAL(10,2) NOT NULL,
    precio_nuevo DECIMAL(10,2) NOT NULL,
    fecha DATETIME NOT NULL,
    usuario NVARCHAR(128) NOT NULL,

    CONSTRAINT PK_AUDITORIA_PRECIO
        PRIMARY KEY (id_auditoria)
);
GO

ALTER TABLE dbo.AUDITORIA_PRECIO
    ADD CONSTRAINT FK_AUDITORIA_PRODUCTO
    FOREIGN KEY (codigo_prod)
    REFERENCES dbo.PRODUCTO(codigo_prod);
GO

CREATE TRIGGER dbo.trg_detalle_descuenta_stock
ON dbo.DETALLE_TICKET
AFTER INSERT
AS
BEGIN
    DECLARE @codigo_prod VARCHAR(20);
    DECLARE @cantidad INT;
    DECLARE @id_sucursal INT;
    DECLARE @id_lote INT;

    SELECT
        @codigo_prod = I.codigo_prod,
        @cantidad = I.cantidad,
        @id_sucursal = T.id_sucursal
    FROM inserted AS I
    INNER JOIN dbo.TICKET AS T
        ON I.num_ticket = T.num_ticket;

    SELECT TOP 1 @id_lote = id_lote
    FROM dbo.LOTE_INVENTARIO
    WHERE codigo_prod = @codigo_prod
      AND id_sucursal = @id_sucursal
      AND stock >= @cantidad
    ORDER BY fecha_venc;

    IF @id_lote IS NULL
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50010, 'Stock insuficiente: la venta fue cancelada.', 1;
    END

    UPDATE dbo.LOTE_INVENTARIO
    SET stock = stock - @cantidad
    WHERE id_lote = @id_lote;
END;
GO

CREATE TRIGGER dbo.trg_detalle_restituye_stock
ON dbo.DETALLE_TICKET
AFTER DELETE
AS
BEGIN
    UPDATE L
    SET L.stock = L.stock + D.cantidad

    FROM dbo.LOTE_INVENTARIO AS L

    INNER JOIN deleted AS D
        ON L.codigo_prod = D.codigo_prod

    INNER JOIN dbo.TICKET AS T
        ON D.num_ticket = T.num_ticket
       AND L.id_sucursal = T.id_sucursal

    WHERE L.id_lote =
    (
        SELECT TOP 1 L2.id_lote
        FROM dbo.LOTE_INVENTARIO AS L2
        WHERE L2.codigo_prod = L.codigo_prod
          AND L2.id_sucursal = L.id_sucursal
        ORDER BY L2.fecha_venc
    );
END;
GO

CREATE TRIGGER dbo.trg_producto_audita_precio
ON dbo.PRODUCTO
AFTER UPDATE
AS
BEGIN
    IF UPDATE(precio)
    BEGIN
        INSERT INTO dbo.AUDITORIA_PRECIO
            (codigo_prod, precio_anterior, precio_nuevo, fecha, usuario)
        SELECT
            D.codigo_prod,
            D.precio,
            I.precio,
            GETDATE(),
            SUSER_SNAME()
        FROM inserted AS I
        INNER JOIN deleted AS D
            ON I.codigo_prod = D.codigo_prod
        WHERE I.precio <> D.precio;
    END
END;
GO

CREATE TRIGGER dbo.trg_lote_valida_vencimiento
ON dbo.LOTE_INVENTARIO
AFTER INSERT, UPDATE
AS
BEGIN
    IF UPDATE(fecha_venc)
    BEGIN
        IF EXISTS
        (
            SELECT 1
            FROM inserted
            WHERE fecha_venc < CAST(GETDATE() AS DATE)
        )
        BEGIN
            ROLLBACK TRANSACTION;
            THROW 50011, 'No se puede registrar un lote ya vencido.', 1;
        END
    END
END;
GO

EXEC dbo.sp_registrar_venta 1006, '45000001', 1, 'P001', 3;
SELECT * FROM dbo.LOTE_INVENTARIO WHERE id_lote = 1;
SELECT * FROM dbo.vw_detalle_ventas WHERE num_ticket = 1006;
GO

EXEC dbo.sp_anular_ticket 1006;
SELECT * FROM dbo.LOTE_INVENTARIO WHERE id_lote = 1;
GO

BEGIN TRANSACTION;

UPDATE dbo.PRODUCTO
SET precio = 11.50
WHERE codigo_prod = 'P003';

SELECT * FROM dbo.AUDITORIA_PRECIO;

ROLLBACK TRANSACTION;
GO

EXEC dbo.sp_registrar_venta 1007, '45000001', 1, 'P001', 90;
GO
