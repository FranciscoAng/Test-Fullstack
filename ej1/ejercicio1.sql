CREATE SCHEMA IF NOT EXISTS ej1;

-- Existen otros campos como apellido, telefono, direccion, que se han omitido si no se relacionan a los criterios de evaluacion
CREATE TABLE ej1.clientes (
    cliente_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE
);


CREATE TABLE ej1.cuentas (
    cuenta_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    cliente_id BIGINT NOT NULL,
    monto_original NUMERIC(15, 2) NOT NULL,
    saldo_pendiente NUMERIC(15, 2) NOT NULL,
    fecha_vencimiento DATE NOT NULL,
    quebranto BOOL NOT NULL DEFAULT false,
    CONSTRAINT fk_cuentas_cliente FOREIGN KEY (cliente_id) 
        REFERENCES ej1.clientes(cliente_id) ON DELETE RESTRICT
);

CREATE TABLE ej1.transacciones (
    transaccion_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    cuenta_id BIGINT NOT NULL,
    monto NUMERIC(15, 2) NOT NULL CHECK (monto > 0),
    fecha_transaccion TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    concepto_pago VARCHAR(100),
    CONSTRAINT fk_transacciones_cuenta FOREIGN KEY (cuenta_id) 
        REFERENCES ej1.cuentas(cuenta_id) ON DELETE RESTRICT
);


------DATOS DE PRUEBA GENERADOS CON GEMINI----------
-- 1. Insertar 10 Clientes
INSERT INTO ej1.clientes (nombre, email) VALUES
('Carlos Mendoza', 'carlos.mendoza@email.com'),     -- Cliente TOP 1
('Ana María López', 'ana.lopez@email.com'),         -- Cliente TOP 2
('Roberto Gómez', 'roberto.gomez@email.com'),       -- Cliente TOP 3
('Laura Fernández', 'laura.fernandez@email.com'),   -- Cliente TOP 4
('Diego Ramírez', 'diego.ramirez@email.com'),       -- Cliente TOP 5
('Elena Torres', 'elena.torres@email.com'),         -- Bajo volumen
('Javier Ríos', 'javier.rios@email.com'),           -- Bajo volumen
('Patricia Castro', 'patricia.castro@email.com'),   -- Bajo volumen
('Gabriel Silva', 'gabriel.silva@email.com'),       -- Bajo volumen
('Sofia Morales', 'sofia.morales@email.com');       -- Bajo volumen

-- 2. Insertar 25 Cuentas
INSERT INTO ej1.cuentas (cliente_id, monto_original, saldo_pendiente, fecha_vencimiento) VALUES
(1, 10000.00, 2500.00, '2026-09-15'),  -- C1
(1, 15000.00, 8000.00, '2026-05-10'),  -- C2: VENCIDA CON SALDO (Vencida: May 2026)
(1, 5000.00,  0.00,    '2026-01-20'),  -- C3
(2, 20000.00, 12000.00, '2026-04-01'), -- C4: VENCIDA CON SALDO (Vencida: Apr 2026)
(2, 8000.00,  1500.00, '2026-10-30'),  -- C5
(3, 12000.00, 4000.00, '2026-03-15'),  -- C7: VENCIDA CON SALDO
(3, 6000.00,  0.00,    '2026-02-10'),  -- C8
(4, 9000.00,  3000.00, '2026-06-01'),  -- C10: VENCIDA CON SALDO
(4, 18000.00, 9000.00, '2026-11-15'),  -- C11
(5, 7000.00,  2000.00, '2026-07-20'),  -- C12: VENCIDA CON SALDO
(6, 5000.00,  1000.00, '2026-12-01'),  -- C14
(7, 4000.00,  1500.00, '2026-05-01'),  -- C16: VENCIDA CON SALDO
(7, 8500.00,  0.00,    '2026-03-01'),  -- C17
(8, 13000.00, 5000.00, '2026-08-01'),  -- C18: VENCIDA RECIENTE
(9, 15000.00, 7500.00, '2026-09-01'),  -- C20
(9, 3500.00,  0.00,    '2026-01-15'),  -- C21
(10, 22000.00, 10000.00, '2026-02-28'),-- C22: VENCIDA CON SALDO
(10, 9500.00, 2000.00, '2026-10-15'),  -- C24
(10, 1000.00, 0.00,    '2026-04-10');  -- C25

-- Cuentas en quebranto
INSERT INTO ej1.cuentas (cliente_id, monto_original, saldo_pendiente, fecha_vencimiento, quebranto) VALUES
(10, 5000.00, 5000.00, '2025-09-05', true),  -- C23: QUEBRANTO
(8, 6000.00,  6000.00, '2025-11-20', true),  -- C19: QUEBRANTO
(6, 11000.00, 11000.00, '2025-06-30', true), -- C15: QUEBRANTO
(5, 14000.00, 14000.00, '2025-10-10', true), -- C13: QUEBRANTO (Totalmente impagada)
(2, 3000.00,  3000.00, '2025-12-15', true),  -- C6: QUEBRANTO (Vencida 2025 con deuda total)
(3, 25000.00, 25000.00, '2025-08-20', true); -- C9: QUEBRANTO (Sin pagos desde 2025)


-- 3. Insertar 30 Transacciones
-- NOTA: Las fechas de los últimos 30 días están comprendidas en agosto 2026.
INSERT INTO ej1.transacciones (cuenta_id, monto, fecha_transaccion, concepto_pago) VALUES
-- Transacciones Clientes TOP (Cuentas 1 a 13) en últimos 30 días (Agosto 2026)
(1,  500.00, '2026-08-01 09:00:00+00', 'Pago ventanilla'),
(1,  500.00, '2026-08-01 09:02:00+00', 'Pago ventanilla'), -- DUPLICADA de la anterior (< 5 min)
(1,  1000.00,'2026-08-10 14:15:00+00', 'Abono app móvil'),
(2,  1500.00,'2026-08-03 10:30:00+00', 'Transferencia bancaria'),
(2,  1500.00,'2026-08-03 10:31:30+00', 'Transferencia bancaria'), -- DUPLICADA de la anterior (< 5 min)
(2,  2000.00,'2026-08-15 11:00:00+00', 'Abono cuota atrasada'),
(4,  3000.00,'2026-08-02 16:45:00+00', 'Pago parcial parcial'),
(4,  3000.00,'2026-08-02 16:48:10+00', 'Pago parcial parcial'), -- DUPLICADA de la anterior (< 5 min)
(5,  1000.00,'2026-08-05 08:20:00+00', 'Abono quincenal'),
(5,  1200.00,'2026-08-18 12:10:00+00', 'Abono quincenal'),
(7,  2000.00,'2026-08-04 15:00:00+00', 'Deposito en efectivo'),
(7,  2000.00,'2026-08-12 17:30:00+00', 'Pago por portal web'),
(7,  2000.00,'2026-08-12 17:33:45+00', 'Pago por portal web'), -- DUPLICADA de la anterior (< 5 min)
(10, 1500.00,'2026-08-06 13:00:00+00', 'Transferencia SPEI'),
(10, 1500.00,'2026-08-14 11:20:00+00', 'Transferencia SPEI'),
(11, 2500.00,'2026-08-08 09:30:00+00', 'Pago recurrente'),
(12, 1000.00,'2026-08-09 10:00:00+00', 'Abono a capital'),
(12, 1000.00,'2026-08-09 10:03:15+00', 'Abono a capital'), -- DUPLICADA de la anterior (< 5 min)
(12, 1000.00,'2026-08-16 16:00:00+00', 'Abono a capital'),

-- Transacciones Históricas o Fuera de los 30 días (Otras cuentas)
(14, 500.00, '2026-06-10 10:00:00+00', 'Pago mensual jun'),
(16, 750.00, '2026-05-15 11:30:00+00', 'Abono mayo'),
(17, 4250.00,'2026-03-01 09:15:00+00', 'Cancelación total'),
(18, 1500.00,'2026-07-01 14:00:00+00', 'Pago mensual jul'),
(20, 2500.00,'2026-06-20 15:45:00+00', 'Abono junio'),
(21, 1750.00,'2026-01-15 12:00:00+00', 'Pago cuota 1'),
(22, 3000.00,'2026-02-25 10:10:00+00', 'Pago parcial feb'),
(24, 1000.00,'2026-07-10 08:50:00+00', 'Abono julio'),
(24, 1000.00,'2026-08-19 13:00:00+00', 'Abono reciente'), -- Transacción única en ago
(25, 500.00, '2026-04-10 11:11:00+00', 'Pago liquidación 1'),
(25, 500.00, '2026-04-10 11:12:30+00', 'Pago liquidación 2');-- DUPLICADA histórica (< 5 min)


SELECT 
    cu.cuenta_id,
    c.nombre AS cliente,
    cu.monto_original,
    cu.saldo_pendiente,
    cu.fecha_vencimiento,
    CURRENT_DATE - cu.fecha_vencimiento AS dias_de_atraso
FROM ej1.cuentas cu
INNER JOIN ej1.clientes c ON cu.cliente_id = c.cliente_id
WHERE cu.saldo_pendiente > 0
  AND cu.fecha_vencimiento < CURRENT_DATE
  AND cu.quebranto = FALSE
ORDER BY cu.fecha_vencimiento ASC;

SELECT 
    c.cliente_id,
    c.nombre,
    COUNT(DISTINCT t.transaccion_id) AS total_transacciones,
    COALESCE(SUM(t.monto), 0) AS volumen_transaccionado
FROM ej1.clientes c
INNER JOIN ej1.cuentas cu 
    ON c.cliente_id = cu.cliente_id 
   AND cu.quebranto = FALSE
INNER JOIN ej1.transacciones t 
    ON cu.cuenta_id = t.cuenta_id
WHERE t.fecha_transaccion >= CURRENT_TIMESTAMP - INTERVAL '30 days'
GROUP BY c.cliente_id, c.nombre, c.email
ORDER BY volumen_transaccionado DESC
LIMIT 5;