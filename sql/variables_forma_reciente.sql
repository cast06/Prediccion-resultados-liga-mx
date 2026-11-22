-- =====================================================================
-- Variables de forma reciente por equipo (Liga MX)
-- ---------------------------------------------------------------------
-- Entrada: tabla `partidos` con una fila por partido:
--   id_partido, fecha (YYYY-MM-DD), temporada, local, visitante,
--   goles_local, goles_visitante, resultado (H / D / A)
--
-- Salida: una fila por partido con el promedio de puntos, goles a favor
-- y goles en contra de cada equipo en sus 5 partidos ANTERIORES.
--
-- La ventana "ROWS BETWEEN 5 PRECEDING AND 1 PRECEDING" excluye el
-- partido actual, así el modelo solo usa información que ya se conocía
-- antes del silbatazo inicial (sin fuga de información).
-- =====================================================================

WITH vista_equipo AS (
    -- Cada partido aparece dos veces: desde el punto de vista del local
    -- y desde el punto de vista del visitante.
    SELECT
        id_partido,
        fecha,
        local            AS equipo,
        1                AS es_local,
        goles_local      AS goles_favor,
        goles_visitante  AS goles_contra,
        CASE resultado WHEN 'H' THEN 3 WHEN 'D' THEN 1 ELSE 0 END AS puntos
    FROM partidos

    UNION ALL

    SELECT
        id_partido,
        fecha,
        visitante        AS equipo,
        0                AS es_local,
        goles_visitante  AS goles_favor,
        goles_local      AS goles_contra,
        CASE resultado WHEN 'A' THEN 3 WHEN 'D' THEN 1 ELSE 0 END AS puntos
    FROM partidos
),

forma AS (
    SELECT
        id_partido,
        equipo,
        es_local,
        COUNT(*)          OVER ult5 AS partidos_previos,
        AVG(puntos)       OVER ult5 AS pts_ult5,
        AVG(goles_favor)  OVER ult5 AS gf_ult5,
        AVG(goles_contra) OVER ult5 AS gc_ult5,
        -- Forma jugando en la misma condición (solo de local o solo de visitante)
        AVG(puntos) OVER (
            PARTITION BY equipo, es_local
            ORDER BY fecha, id_partido
            ROWS BETWEEN 5 PRECEDING AND 1 PRECEDING
        ) AS pts_ult5_condicion
    FROM vista_equipo
    WINDOW ult5 AS (
        PARTITION BY equipo
        ORDER BY fecha, id_partido
        ROWS BETWEEN 5 PRECEDING AND 1 PRECEDING
    )
)

SELECT
    p.*,
    l.partidos_previos   AS local_partidos_previos,
    l.pts_ult5           AS local_pts_ult5,
    l.gf_ult5            AS local_gf_ult5,
    l.gc_ult5            AS local_gc_ult5,
    l.pts_ult5_condicion AS local_pts_ult5_en_casa,
    v.partidos_previos   AS visita_partidos_previos,
    v.pts_ult5           AS visita_pts_ult5,
    v.gf_ult5            AS visita_gf_ult5,
    v.gc_ult5            AS visita_gc_ult5,
    v.pts_ult5_condicion AS visita_pts_ult5_fuera
FROM partidos AS p
JOIN forma AS l ON l.id_partido = p.id_partido AND l.es_local = 1
JOIN forma AS v ON v.id_partido = p.id_partido AND v.es_local = 0
ORDER BY p.fecha, p.id_partido;
