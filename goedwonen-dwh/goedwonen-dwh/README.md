# GoedWonen Zuid – OLAP schema & ADF pipeline

Onderdeel van de herkansing DIS: OLAP-schema en ADF-pipeline voor betere
rapportages over onderhoudsmeldingen in relatie tot weer.

## Inhoud

- `sql/00_create_staging_reference.sql` – `stg`-schema plus `stg.WEER`
  (dagelijkse weerdata voor de regio)
- `sql/01_create_olap_schema.sql` – DDL voor het sterretjesmodel (DimDatum,
  DimLocatie, DimObject, DimWerksoort, DimProject, DimMelding, DimWeer,
  FactWerk)
- `sql/02_load_procedures.sql` – stored procedures die de dimensies en
  FactWerk vullen vanuit staging (`stg.*`), truncate-and-load
- `adf/pipeline/` – pipeline-definities (JSON), zoals ADF ze wegschrijft
  wanneer je de Data Factory aan Git koppelt
  - `PL_Master_Load_DWH.json` – orkestreert de vier sub-pipelines
  - `PL_Load_Staging.json` – kopieert de OLTP-tabellen naar staging
  - `PL_Load_Weer.json` – haalt historische dagweerdata op voor Zuid-Limburg
  - `PL_Load_Dimensions.json` – vult alle dimensietabellen
  - `PL_Load_Fact.json` – vult FactWerk
- `adf/linkedService/LS_AzureSqlDWH.json` – placeholder linked service voor je database
- `adf/linkedService/LS_OpenMeteo_REST.json` – gratis Open-Meteo historical archive API (geen key)
- `adf/dataset/DS_Weer_REST.json` – REST-dataset voor de Open-Meteo-call

## Waar de weerdata vandaan komt

Alle objecten van GoedWonen Zuid liggen in Zuid-Limburg, dus is een
regionale differentiatie niet nodig. `DimWeer` is daarom gewoon 1 rij per
dag, gekoppeld aan `DimDatum` (geen `LocatieKey` meer). `PL_Load_Weer` roept
één keer de gratis Open-Meteo historical archive API aan
(`archive-api.open-meteo.com`, geen key nodig, historie vanaf 1940) met een
vast coördinatenpunt voor Heerlen (50.8882, 5.9795) als representatief punt
voor de regio, en de gewenste datumrange. Resultaat landt direct in
`stg.WEER`.

Wil je het toch preciezer per gemeente/postcode? Dan kun je later alsnog
teruggaan naar een per-locatie aanpak (PDOK Locatieserver voor geocoding +
`LocatieKey` op `DimWeer`) — voor nu is 1 regionaal punt verdedigbaar en
veel sneller te bouwen.

## Nog aan te vullen voor het werkt

1. `DimDatum` eenmalig vullen (script of los aanmaken, geen bron-tabel voor)
2. Linked service voor de OLTP-bron toevoegen, en datasets `DS_OLTP_*` /
   `DS_Staging_*` aanmaken en koppelen aan tabellen
3. Connectiegegevens invullen in `LS_AzureSqlDWH.json`
4. Open-Meteo geeft windsnelheid in km/h, niet Beaufort — reken dit om in
   `usp_Load_DimWeer` of al bij binnenkomst in staging
5. Check of `RegioLatitude`/`RegioLongitude` (Heerlen) precies genoeg is
   voor jouw complexen, of pas de coördinaten aan naar bv. het zwaartepunt
   van je woningbestand

## Naar je eigen repo pushen

```bash
git clone https://github.com/Caska07/<jouw-repo>.git
cp -r goedwonen-dwh/* <jouw-repo>/
cd <jouw-repo>
git add .
git commit -m "OLAP schema en ADF pipeline voor onderhoud/weer rapportage"
git push
```
