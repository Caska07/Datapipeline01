-- =====================================================================
-- Staging-tabel voor weerdata. Alle objecten van GoedWonen Zuid liggen in
-- Zuid-Limburg, dus geen locatie-koppeling nodig: 1 rij per dag, opgehaald
-- voor een vast punt (Heerlen) als representatief voor de regio.
-- =====================================================================

CREATE SCHEMA stg
GO

CREATE TABLE [stg].[WEER]
(
    DATUM               DATE NOT NULL,
    GEM_TEMPERATUUR_C   DECIMAL(5,1),
    MIN_TEMPERATUUR_C   DECIMAL(5,1),
    MAX_TEMPERATUUR_C   DECIMAL(5,1),
    NEERSLAG_MM         DECIMAL(6,1),
    WINDKRACHT_BFT      INT,
    MAX_WINDSTOOT_KMH   DECIMAL(5,1),
    WEERTYPE            VARCHAR(50)
)
GO
