--------------------------------------------------------
--  DDL for Package Body ZX_TCM_GEO_JUR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_TCM_GEO_JUR_PKG" AS
/* $Header: zxcjurb.pls 120.42.12010000.7 2010/01/08 12:51:19 tsen ship $ */

  -- Logging Infra
  G_CURRENT_RUNTIME_LEVEL      NUMBER;
  G_LEVEL_UNEXPECTED           CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
  G_LEVEL_ERROR                CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
  G_LEVEL_EXCEPTION            CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_EVENT                CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
  G_LEVEL_PROCEDURE            CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_STATEMENT            CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
  G_MODULE_NAME                CONSTANT VARCHAR2(30) := 'ZX.PLSQL.ZX_TCM_GEO_JUR_PKG';

  TYPE geography_id_type is TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  l_jurisdiction_rec_tmp_tbl   tax_jurisdiction_rec_tbl_type;

  g_geography_use_info_tbl     zx_global_Structures_pkg.geography_use_info_tbl_type;
  -- this table is used in jurisdictions API to get geography types and uses for a given tax
  -- and this structure is value for the whole session.

  g_geo_name_references_tbl     zx_global_structures_pkg.geo_name_references_tbl_type;
  -- this table is used in get_zone API to get geo name reference for a given location_id
  -- and this structure is value for the whole session.

  PROCEDURE  get_location_info(p_location_id     IN NUMBER,
                               p_location_table_name IN VARCHAR2 default NULL,
                               x_location_info_rec OUT NOCOPY zx_global_Structures_pkg.loc_info_rec_type,
                               x_return_status     OUT NOCOPY VARCHAR2);

  PROCEDURE get_pos_loc_or_site(p_party_type    IN VARCHAR2,
                                x_loc_tbl       OUT NOCOPY VARCHAR2,
                                x_loc_site      OUT NOCOPY VARCHAR2,
                                x_return_status OUT NOCOPY VARCHAR2) IS
    -- Logging Infra
    l_procedure_name CONSTANT VARCHAR2(30) := 'get_pos_loc_or_site';
    l_log_msg   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
    l_party_type_tbl_idx binary_integer;
    l_idx                BINARY_INTEGER;

    CURSOR c_get_party_type_info
    IS
    SELECT
        PARTY_TYPE_CODE,
        upper(PARTY_SOURCE_TABLE) PARTY_SOURCE_TABLE,
        upper(PARTY_SOURCE_COLUMN)PARTY_SOURCE_COLUMN,
        APPLICABLE_TO_EVNT_CLS_FLAG,
        PARTY_SITE_TYPE,
        upper(LOCATION_SOURCE_TABLE) LOCATION_SOURCE_TABLE,
        upper(LOCATION_SOURCE_COLUMN) LOCATION_SOURCE_COLUMN
     FROM
        ZX_PARTY_TYPES;

  BEGIN
    -- Logging Infra: Setting up runtime level
    G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    -- Logging Infra: Procedure level
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := l_procedure_name||'(+)';
      l_log_msg := l_log_msg ||' B: SEL zx_party_types: in: p_party_type='||p_party_type;
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
    END IF;

     -- Initialize API return status to success.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_party_type_tbl_idx :=  dbms_utility.get_hash_value(p_party_type, 1, 8192);

    IF (ZX_GLOBAL_STRUCTURES_PKG.ZX_PARTY_TYPES_CACHE.exists(l_party_type_tbl_idx)) THEN
        x_loc_tbl := ZX_GLOBAL_STRUCTURES_PKG.ZX_PARTY_TYPES_CACHE(l_party_type_tbl_idx).LOCATION_SOURCE_TABLE;

        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            l_log_msg := 'Found the party type information in cache for:'||p_party_type;
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
        END IF;


    ELSE
        FOR c_party_type_rec IN c_get_party_type_info
        LOOP

           l_idx := dbms_utility.get_hash_value(c_party_type_rec.party_type_code, 1, 8192);

           ZX_GLOBAL_STRUCTURES_PKG.ZX_PARTY_TYPES_CACHE(l_idx).PARTY_TYPE_CODE
                   := c_party_type_rec.PARTY_TYPE_CODE;
           ZX_GLOBAL_STRUCTURES_PKG.ZX_PARTY_TYPES_CACHE(l_idx).PARTY_SOURCE_TABLE
                   := c_party_type_rec.PARTY_SOURCE_TABLE;
           ZX_GLOBAL_STRUCTURES_PKG.ZX_PARTY_TYPES_CACHE(l_idx).PARTY_SOURCE_COLUMN
                   := c_party_type_rec.PARTY_SOURCE_COLUMN;
           ZX_GLOBAL_STRUCTURES_PKG.ZX_PARTY_TYPES_CACHE(l_idx).APPLICABLE_TO_EVNT_CLS_FLAG
                   := c_party_type_rec.APPLICABLE_TO_EVNT_CLS_FLAG;
           ZX_GLOBAL_STRUCTURES_PKG.ZX_PARTY_TYPES_CACHE(l_idx).PARTY_SITE_TYPE
                   := c_party_type_rec.PARTY_SITE_TYPE;
           ZX_GLOBAL_STRUCTURES_PKG.ZX_PARTY_TYPES_CACHE(l_idx).LOCATION_SOURCE_TABLE
                   := c_party_type_rec.LOCATION_SOURCE_TABLE;
           ZX_GLOBAL_STRUCTURES_PKG.ZX_PARTY_TYPES_CACHE(l_idx).LOCATION_SOURCE_COLUMN
                   := c_party_type_rec.LOCATION_SOURCE_COLUMN;
        END LOOP;
        x_loc_tbl := ZX_GLOBAL_STRUCTURES_PKG.ZX_PARTY_TYPES_CACHE(l_party_type_tbl_idx).LOCATION_SOURCE_TABLE;

    END IF;


    /* 3471450 -- SITE_ID changed to PARTY_SITE_ID */
    IF x_loc_tbl = 'HZ_LOCATIONS' THEN
       x_loc_site := 'LOCATION_ID';
    ELSIF x_loc_tbl =  'HR_LOCATIONS_ALL' THEN
       x_loc_site := 'LOCATION_ID';
    ELSIF x_loc_tbl = 'PO_VENDOR_SITES_ALL' THEN
       x_loc_site := 'PARTY_SITE_ID';
    END IF;

    -- Logging Infra: Statement level: "R" means "R"eturned value to a caller
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'R: SEL zx_party_types: out: x_loc_tbl='||x_loc_tbl||', x_loc_site='||x_loc_site;
      l_log_msg := l_log_msg ||' '||l_procedure_name||'(-)';
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
    END IF;

  EXCEPTION WHEN OTHERS THEN
     -- Party type information could not be retrived.
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      --FND_MESSAGE.SET_NAME('ZX', 'ZX_TCM_NO_PARTY_TYPE_INFO');

      -- Logging Infra: Statement level
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, 'E: EXC: OTHERS: '||SQLCODE||': '||SQLERRM);
        FND_LOG.STRING(G_LEVEL_STATEMENT,
                       G_MODULE_NAME || l_procedure_name,
                       'E: EXC: OTHERS: p_party_type='||p_party_type ||
                       ' Party type information could not be retrived.');
      END IF;

  END get_pos_loc_or_site;

  PROCEDURE check_location_exists(p_location_id IN NUMBER,
                                  x_location_table_name IN OUT NOCOPY VARCHAR2) IS
  l_hr_location_exists VARCHAR2(5);
  l_hz_location_exists VARCHAR2(5);
  l_procedure_name CONSTANT VARCHAR2(30) := 'check_location_exists';
  BEGIN
    IF x_location_table_name = 'HR_LOCATIONS_ALL' THEN
       BEGIN
         SELECT 'TRUE'
         INTO  l_hr_location_exists
         FROM  hr_locations_all
         WHERE location_id = p_location_id;

       EXCEPTION WHEN NO_DATA_FOUND THEN
         l_hr_location_exists := 'FALSE';
       END;
       IF l_hr_location_exists = 'FALSE' THEN
         BEGIN
           SELECT 'TRUE'
           INTO  l_hz_location_exists
           FROM  hz_locations
           WHERE location_id = p_location_id;

         EXCEPTION WHEN NO_DATA_FOUND THEN
           l_hz_location_exists := 'FALSE';
         END;
         IF l_hz_location_exists = 'TRUE' THEN
           x_location_table_name := 'HZ_LOCATIONS';
         ELSE
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, 'B: Invalid Location_id');
           END IF;
         END IF;
       END IF;
     ELSIF x_location_table_name = 'HZ_LOCATIONS' THEN
       BEGIN
         SELECT 'TRUE'
         INTO  l_hz_location_exists
         FROM  hz_locations
         WHERE location_id = p_location_id;

       EXCEPTION WHEN NO_DATA_FOUND THEN
         l_hz_location_exists := 'FALSE';
       END;
       IF l_hz_location_exists = 'FALSE' THEN
         BEGIN
           SELECT 'TRUE'
           INTO  l_hr_location_exists
           FROM  hr_locations_all
           WHERE location_id = p_location_id;

         EXCEPTION WHEN NO_DATA_FOUND THEN
           l_hr_location_exists := 'FALSE';
         END;
         IF l_hr_location_exists = 'TRUE' THEN
           x_location_table_name := 'HR_LOCATIONS_ALL';
         ELSE
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, 'B: Invalid Location_id');
           END IF;
         END IF;
       END IF;
     END IF;

 END;

 PROCEDURE  get_location_info( p_location_id     IN NUMBER,
                               p_location_table_name IN VARCHAR2 default NULL,
                               x_location_info_rec OUT NOCOPY zx_global_Structures_pkg.loc_info_rec_type,
                               x_return_status     OUT NOCOPY VARCHAR2)
 IS
   l_loc_country_code  hz_locations.country%type;
   l_procedure_name CONSTANT VARCHAR2(30) := 'get_location_info';
   l_log_msg        VARCHAR2(2000);
 BEGIN

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := l_procedure_name||'(+)';
      FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME || l_procedure_name || '.begin', l_log_msg);
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF ZX_GLOBAL_STRUCTURES_PKG.Loc_info_tbl.exists(to_char(p_location_id)) then

       x_location_info_rec := zx_global_Structures_pkg.loc_info_tbl(to_char(p_location_id));

       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name,
                 'Found the location info in cache for location id: '||p_location_id||' for table '||
                 x_location_info_rec.location_table_name);
       END IF;

    ELSE
        IF p_location_table_name = 'HR_LOCATIONS_ALL' THEN
           BEGIN
             SELECT country
             INTO  l_loc_country_code
             FROM  hr_locations_all
             WHERE location_id = p_location_id;

             x_location_info_rec.country_code := l_loc_country_code;
             x_location_info_rec.location_table_name := 'HR_LOCATIONS_ALL';
             x_location_info_rec.location_id := p_location_id;

             zx_global_Structures_pkg.loc_info_tbl(to_char(p_location_id)) := x_location_info_rec;

           EXCEPTION WHEN NO_DATA_FOUND THEN

             BEGIN
               SELECT country
               INTO  l_loc_country_code
               FROM  hz_locations
               WHERE location_id = p_location_id;

               x_location_info_rec.country_code := l_loc_country_code;
               x_location_info_rec.location_table_name := 'HZ_LOCATIONS';
               x_location_info_rec. location_id := p_location_id;

               zx_global_Structures_pkg.loc_info_tbl(to_char(p_location_id)) := x_location_info_rec;


             EXCEPTION WHEN NO_DATA_FOUND THEN
               IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                  l_log_msg := 'B: Invalid Location_id';
                  l_log_msg := l_log_msg ||' E: SEL country_code: no_data_found: p_location_id='||p_location_id;
                  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
               END IF;

               x_return_status := FND_API.G_RET_STS_ERROR;
               FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_NO_LOC_REC');
               FND_MESSAGE.SET_TOKEN('LOC_ID', p_location_id);
               FND_MESSAGE.SET_TOKEN('TABLE_NAME', p_location_table_name);
               RAISE FND_API.G_EXC_ERROR;
             END;
           END;

        ELSIF p_location_table_name = 'HZ_LOCATIONS' THEN
           BEGIN
             SELECT country
             INTO  l_loc_country_code
             FROM  hz_locations
             WHERE location_id = p_location_id;

             x_location_info_rec.country_code := l_loc_country_code;
             x_location_info_rec.location_table_name := 'HZ_LOCATIONS';
             x_location_info_rec. location_id := p_location_id;

             zx_global_Structures_pkg.loc_info_tbl(to_char(p_location_id)) := x_location_info_rec;

           EXCEPTION WHEN NO_DATA_FOUND THEN

             BEGIN
               SELECT country
               INTO  l_loc_country_code
               FROM  hr_locations_all
               WHERE location_id = p_location_id;

               x_location_info_rec.country_code := l_loc_country_code;
               x_location_info_rec.location_table_name := 'HR_LOCATIONS_ALL';
               x_location_info_rec. location_id := p_location_id;

               zx_global_Structures_pkg.loc_info_tbl(to_char(p_location_id)) := x_location_info_rec;


             EXCEPTION WHEN NO_DATA_FOUND THEN
               IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, 'B: Invalid Location_id');
               END IF;

               -- Logging Infra: "E" means "E"rror
               IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                  l_log_msg := 'E: SEL country_code: no_data_found: p_location_id='||p_location_id;
                  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
               END IF;

               x_return_status := FND_API.G_RET_STS_ERROR;
               FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_NO_LOC_REC');
               FND_MESSAGE.SET_TOKEN('LOC_ID', p_location_id);
               FND_MESSAGE.SET_TOKEN('TABLE_NAME', p_location_table_name);
               RAISE FND_API.G_EXC_ERROR;
             END;
           END;
        END IF;
    END IF; -- Loc_info_tbl.exists

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := l_procedure_name||'(-)';
      FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME || l_procedure_name || '.end', l_log_msg);
   END IF;

 END get_location_info;

  PROCEDURE get_location_table_name(p_location_type       IN         VARCHAR2,
                                    x_location_table_name OUT NOCOPY VARCHAR2) IS
    l_loc_site VARCHAR2(30);
    x_return_status  VARCHAR2(1);
    -- Logging Infra
    l_procedure_name CONSTANT VARCHAR2(30) := 'get_location_table_name';
    l_log_msg FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

  BEGIN
    -- Logging Infra: Statement level
    -- No need to initialize g_current_runtime_level as it is done at the caller (get_zone or get_master_geo)
    -- Logging Infra: Statement level: "B" means "B"reak point
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := l_procedure_name||'(+)';
      l_log_msg := l_log_msg || 'B: p_location_type= '||p_location_type;
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name || '.begin', l_log_msg);
    END IF;

    -- Logging Infra: Intentionally, not implementing log infra around get_pos_loc_or_site procedure
    -- as it internally logs its messages.
    IF p_location_type = 'SHIP_FROM' THEN
      get_pos_loc_or_site(
                       zx_valid_init_params_pkg.source_rec.ship_from_party_type,                       x_location_table_name,
                       l_loc_site,
                       x_return_status);

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    ELSIF p_location_type = 'SHIP_TO' THEN
      get_pos_loc_or_site(
                       zx_valid_init_params_pkg.source_rec.ship_to_party_type,
                       x_location_table_name,
                       l_loc_site,
                       x_return_status);

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    ELSIF p_location_type = 'BILL_FROM' THEN
      get_pos_loc_or_site(
                       zx_valid_init_params_pkg.source_rec.bill_from_party_type,                       x_location_table_name,
                       l_loc_site,
                       x_return_status);
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    ELSIF p_location_type = 'BILL_TO' THEN
      get_pos_loc_or_site(
                       zx_valid_init_params_pkg.source_rec.bill_to_party_type,
                       x_location_table_name,
                       l_loc_site,
                       x_return_status);
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    ELSIF p_location_type = 'POA' THEN
      get_pos_loc_or_site(
                       zx_valid_init_params_pkg.source_rec.poa_party_type,
                       x_location_table_name,
                       l_loc_site,
                       x_return_status);
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    ELSIF p_location_type = 'POO' THEN
      get_pos_loc_or_site(
                       zx_valid_init_params_pkg.source_rec.poo_party_type,
                       x_location_table_name,
                       l_loc_site,
                       x_return_status);
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    ELSIF p_location_type = 'TRADING_HQ' THEN
      get_pos_loc_or_site(
                       zx_valid_init_params_pkg.source_rec.trad_hq_party_type,
                       x_location_table_name,
                       l_loc_site,
                       x_return_status);
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    ELSIF p_location_type = 'OWN_HQ' THEN
      get_pos_loc_or_site(
                       zx_valid_init_params_pkg.source_rec.own_hq_party_type,                          x_location_table_name,
                       l_loc_site,
                       x_return_status);
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    ELSIF p_location_type = 'TITLE_TRANS' THEN
      get_pos_loc_or_site(
                       zx_valid_init_params_pkg.source_rec.ttl_trns_party_type,
                       x_location_table_name,
                       l_loc_site,
                       x_return_status);
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    ELSIF p_location_type = 'PAYING' THEN
      get_pos_loc_or_site(
                       zx_valid_init_params_pkg.source_rec.paying_party_type,
                       x_location_table_name,
                       l_loc_site,
                       x_return_status);
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    ELSIF p_location_type = 'POC' THEN
      /*get_pos_loc_or_site(
                       zx_valid_init_params_pkg.source_rec.ship_from_party_type,                       x_location_table_name,
                       l_loc_site,
                       x_return_status);
    */
      null;

    ELSIF p_location_type = 'POI' THEN
      get_pos_loc_or_site(
                       zx_valid_init_params_pkg.source_rec.poi_party_type,
                       x_location_table_name,
                       l_loc_site,
                       x_return_status);
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    ELSIF p_location_type = 'POD' THEN
      get_pos_loc_or_site(
                       zx_valid_init_params_pkg.source_rec.pod_party_type,
                       x_location_table_name,
                       l_loc_site,
                       x_return_status);
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    ELSIF p_location_type = 'INTERNAL_ORG' THEN
      x_location_table_name := 'HR_LOCATIONS_ALL';

    END IF;

    -- Logging Infra: Statement level:"R" means "R"eturned value to a caller
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'R: x_location_table_name='||x_location_table_name;
      l_log_msg :=  l_log_msg || l_procedure_name||'(-)';
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
    END IF;

  EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
       x_return_status :=FND_API.G_RET_STS_ERROR;

  END get_location_table_name;


  PROCEDURE get_jurisdiction(p_tax              IN VARCHAR2,
                             p_tax_regime_code  IN VARCHAR2,
                             p_geography_id     IN NUMBER,
                             p_date             IN DATE,
                             p_inner_city_jurisdiction_flag IN VARCHAR2) IS
    i BINARY_INTEGER;
     -- Logging Infra
    l_procedure_name CONSTANT VARCHAR2(30) := 'get_jurisdiction';
    l_log_msg FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
    -----x_jurisdiction_rec_tmp_tbl tax_jurisdiction_rec_tbl_type;
    CURSOR get_jur_info_c
    ( c_tax                           VARCHAR2,
      c_tax_regime_code               VARCHAR2,
      c_geography_id                  NUMBER,
      c_date                          DATE,
      c_inner_city_jurisdiction_flag  VARCHAR2
    )
    IS
    SELECT tax_jurisdiction_id,
           tax_jurisdiction_code,
           tax_regime_code,
           tax,
           precedence_level
       FROM   zx_jurisdictions_b
       WHERE  effective_from <= c_date
       AND    (effective_to >= c_date or effective_to is null)
       AND    tax = c_tax
       AND    tax_regime_code = c_tax_regime_code
       AND    zone_geography_id = c_geography_id
       AND    (((inner_city_jurisdiction_flag = c_inner_city_jurisdiction_flag) OR
                (inner_city_jurisdiction_flag IS NULL AND
                 c_inner_city_jurisdiction_flag IS NULL))  OR
              (inner_city_jurisdiction_flag is null and
               c_inner_city_jurisdiction_flag is not null) OR
              (inner_city_jurisdiction_flag is not null and c_inner_city_jurisdiction_flag is null));



  BEGIN

    -- Logging Infra: Setting up runtime level
    G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    -- Logging Infra: Procedure level
    -- Logging Infra: Statement level: "B" means "B"reak point
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := l_procedure_name||'(+)';
      l_log_msg := l_log_msg ||' B: SEL zx_jurisdictions: in: p_tax='||p_tax||', p_date='||p_date||', p_tax_regime_code='||p_tax_regime_code||', p_geography_id='||p_geography_id;
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name || '.begin', l_log_msg);
    END IF;

      IF l_jurisdiction_rec_tmp_tbl.count = 0 THEN
        i := 1;
      ELSE
        i := l_jurisdiction_rec_tmp_tbl.last + 1;
      END IF;


      OPEN get_jur_info_c
      ( p_tax,
        p_tax_regime_code,
        p_geography_id,
        p_date,
        p_inner_city_jurisdiction_flag
      );

      FETCH get_jur_info_c INTO
           l_jurisdiction_rec_tmp_tbl(i).tax_jurisdiction_id,
           l_jurisdiction_rec_tmp_tbl(i).tax_jurisdiction_code,
           l_jurisdiction_rec_tmp_tbl(i).tax_regime_code,
           l_jurisdiction_rec_tmp_tbl(i).tax,
           l_jurisdiction_rec_tmp_tbl(i).precedence_level;
      CLOSE get_jur_info_c;


       -- Logging Infra: Statement level: "R" means "R"eturned value to a caller
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          l_log_msg := 'R: SEL zx_jurisdictions: out: tax_jurisdiction_id='||l_jurisdiction_rec_tmp_tbl(i).tax_jurisdiction_id||
                     ', tax_jurisdiction_code='||l_jurisdiction_rec_tmp_tbl(i).tax_jurisdiction_code;

          l_log_msg := l_log_msg ||' '||l_procedure_name||'(-)';
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;

  EXCEPTION WHEN NO_DATA_FOUND THEN
    NULL;
    -- Logging Infra: Procedure level
----    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
----       l_log_msg := 'S: EXC: NO_DATA_FOUND: tax_jurisdiction_id='||g_jurisdiction_rec_tbl.tax_jurisdiction_id(i)||
----                     ', tax_jurisdiction_code='||g_jurisdiction_rec_tbl.tax_jurisdiction_code(i);
----        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
----    END IF;

  END get_jurisdiction;

  PROCEDURE get_zone
   ( p_location_id       IN         NUMBER,
     p_location_type     IN         VARCHAR2,
     p_zone_type         IN         VARCHAR2,
     p_trx_date          IN         DATE,
     x_zone_tbl          OUT NOCOPY HZ_GEO_GET_PUB.zone_tbl_type,
     x_return_status     OUT NOCOPY VARCHAR2) IS



     CURSOR C_GEOGRAPHY_TYPES (c_geography_type in VARCHAR2) IS
      SELECT geography_type,
             geography_use,
             limited_by_geography_id
           FROM hz_geography_types_b
           WHERE geography_type = c_geography_type;


    x_location_table_name  VARCHAR2(30);
    -- Bug 4551957
    l_count_geo  NUMBER;
    l_loc_country_code VARCHAR2(30);
    l_zone_type_country_code VARCHAR2(30);

    -- Logging Infra
    l_procedure_name  CONSTANT VARCHAR2(30) := 'get_zone';
    l_log_msg FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

    -- The following 3 variables are added to make the external api (HZ_GEO_GET_PUB.get_zone)
    -- calling place to compile. Needs to be removed later...
    l_init_msg_list VARCHAR2(30);
    x_msg_count     NUMBER;
    x_msg_data      VARCHAR2(2000);
    l_location_info_rec ZX_GLOBAL_STRUCTURES_PKG.loc_info_rec_type;

    l_geography_type_index BINARY_INTEGER;
    l_geography_type  hz_geography_types_b.geography_type%TYPE;
    l_geography_use   hz_geography_types_b.geography_use%TYPE;
    l_limited_by_geography_id hz_geography_types_b.limited_by_geography_id%TYPE;

    --bug8251315
    l_tbl_index      BINARY_INTEGER;
    l_zone_indx      VARCHAR2(4000);
    p_zone_tbl       HZ_GEO_GET_PUB.zone_tbl_type;
    l                NUMBER;
  BEGIN
    -- Logging Infra: Setting up runtime level
    G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    -- Logging Infra: Procedure level
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := l_procedure_name||'(+)';
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name || '.begin', l_log_msg);
    END IF;

 -- Initialize API return status to success.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

 -- Derive location table name based on location_type
    IF ZX_GLOBAL_STRUCTURES_PKG.Loc_info_tbl.exists(to_char(p_location_id)) then

            l_loc_country_code := ZX_GLOBAL_STRUCTURES_PKG.Loc_info_tbl(to_char(p_location_id)).country_code;
            x_location_table_name := ZX_GLOBAL_STRUCTURES_PKG.Loc_info_tbl(to_char(p_location_id)).location_table_name;
    ELSE

            get_location_table_name(p_location_type,
                                   x_location_table_name);

            -- Logging Infra: Statement level: "B" means "B"reak point
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               l_log_msg :=  'B: hz_geo_get_pub.get_zone: in: '||'p_location_table_name='||x_location_table_name||
                             ',  p_location_id='||p_location_id||', p_zone_type=' ||p_zone_type||', p_date='||p_trx_date;
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
           END IF;

           get_location_info(p_location_id, x_location_table_name, l_location_info_rec, x_return_status);
           x_location_table_name := ZX_GLOBAL_STRUCTURES_PKG.Loc_info_tbl(to_char(p_location_id)).location_table_name;

           l_loc_country_code := l_location_info_rec.country_code;

    END IF;

    l_geography_type_index := dbms_utility.get_hash_value(p_zone_type, 1, 8192);

    --bug8251315
    IF ZX_GLOBAL_STRUCTURES_PKG.g_geography_type_info_tbl.exists(l_geography_type_index)
       AND ZX_GLOBAL_STRUCTURES_PKG.g_geography_type_info_tbl(l_geography_type_index).zone_type = p_zone_type THEN
        l_limited_by_geography_id :=
             ZX_GLOBAL_STRUCTURES_PKG.g_geography_type_info_tbl(l_geography_type_index).limited_by_geography_id;

    ELSE

           open C_GEOGRAPHY_TYPES(p_zone_type);
           fetch C_GEOGRAPHY_TYPES into
                 l_geography_type,
                 l_geography_use,
                 l_limited_by_geography_id;
           close C_GEOGRAPHY_TYPES;

           ZX_GLOBAL_STRUCTURES_PKG.g_geography_type_info_tbl(l_geography_type_index).geography_type := l_geography_type;
           ZX_GLOBAL_STRUCTURES_PKG.g_geography_type_info_tbl(l_geography_type_index).geography_use := l_geography_use;
           ZX_GLOBAL_STRUCTURES_PKG.g_geography_type_info_tbl(l_geography_type_index).limited_by_geography_id := l_limited_by_geography_id;
           --bug8251315
           ZX_GLOBAL_STRUCTURES_PKG.g_geography_type_info_tbl(l_geography_type_index).zone_type := p_zone_type;

    END IF;

    IF l_limited_by_geography_id IS NOT NULL THEN
      SELECT country_code
      INTO l_zone_type_country_code
      FROM hz_geographies
      WHERE geography_id = l_limited_by_geography_id;
    END IF;

    IF l_limited_by_geography_id IS NULL OR
       l_loc_country_code = l_zone_type_country_code THEN

       IF l_limited_by_geography_id IS NOT NULL THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           l_log_msg := 'R: Location country and Zone Type country are matching';
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
         END IF;

         -- check if geo name reference information is there in cache
         l_tbl_index := dbms_utility.get_hash_value(
                   TO_CHAR(p_location_id),
                   1,
                   8192);

         --bug8351315
         IF g_geo_name_references_tbl.EXISTS(l_tbl_index) AND
            g_geo_name_references_tbl(l_tbl_index).location_id = p_location_id then
           -- The geo name reference information is there in cache.
           -- No need to read from tables
           IF (g_level_statement >= g_current_runtime_level ) THEN
               FND_LOG.STRING(g_level_statement,
                       G_MODULE_NAME || l_procedure_name,
                       'Found geo name reference information in cache ');
           END IF;
           l_count_geo := g_geo_name_references_tbl(l_tbl_index).ref_count;

         ELSE
           IF (g_level_statement >= g_current_runtime_level ) THEN
               FND_LOG.STRING(g_level_statement,
                       G_MODULE_NAME || l_procedure_name,
                       'Not found geo name reference information in cache, read from table');
           END IF;
           -- Bug 4551957
           BEGIN
             SELECT 1 into l_count_geo
             FROM  hz_geo_name_references
             WHERE location_id = p_location_id
             AND   rownum = 1;
          EXCEPTION WHEN NO_DATA_FOUND THEN
            l_count_geo  := 0;
          END;
           g_geo_name_references_tbl(l_tbl_index).ref_count := l_count_geo;
           --bug8251315
           g_geo_name_references_tbl(l_tbl_index).location_id := p_location_id;

         END IF;

         IF l_count_geo = 0 THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
           FND_MESSAGE.SET_NAME('ZX', 'ZX_GEO_NO_GEO_NAME_REF');
           FND_MESSAGE.SET_TOKEN('LOCATION_TYPE', p_location_type);
           RAISE FND_API.G_EXC_ERROR;
         END IF;
       END IF;

       -- Once table name is got, call TCA's get_zone API

       --bug8251315
       l_zone_indx := to_char(p_location_id) || '|' ||
                      p_location_type || '|' ||
                      p_zone_type || '|' ||
                      p_trx_date || '|' ||
                      to_char(1);
       IF ZX_GLOBAL_STRUCTURES_PKG.g_hz_zone_tbl.EXISTS(l_zone_indx) AND
          ZX_GLOBAL_STRUCTURES_PKG.g_hz_zone_tbl(l_zone_indx).location_id = p_location_id AND
          ZX_GLOBAL_STRUCTURES_PKG.g_hz_zone_tbl(l_zone_indx).location_type = p_location_type AND
          ZX_GLOBAL_STRUCTURES_PKG.g_hz_zone_tbl(l_zone_indx).zone_type = p_zone_type AND
          ZX_GLOBAL_STRUCTURES_PKG.g_hz_zone_tbl(l_zone_indx).indx_value = l_zone_indx AND
          ZX_GLOBAL_STRUCTURES_PKG.g_hz_zone_tbl(l_zone_indx).value = 1 THEN

        IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
                  G_MODULE_NAME || l_procedure_name,
                  'Zone Information found in cache.');
        END IF;

        l := 1;
        LOOP
          l_zone_indx := to_char(p_location_id) || '|' ||
                         p_location_type || '|' ||
                         p_zone_type || '|' ||
                         p_trx_date || '|' ||
                         to_char(l);
          IF NOT ZX_GLOBAL_STRUCTURES_PKG.g_hz_zone_tbl.EXISTS(l_zone_indx) THEN
            EXIT;
          END IF;
          p_zone_tbl(l).zone_id := ZX_GLOBAL_STRUCTURES_PKG.g_hz_zone_tbl(l_zone_indx).zone_id;
          p_zone_tbl(l).zone_name := ZX_GLOBAL_STRUCTURES_PKG.g_hz_zone_tbl(l_zone_indx).zone_name;
          p_zone_tbl(l).zone_code := ZX_GLOBAL_STRUCTURES_PKG.g_hz_zone_tbl(l_zone_indx).zone_code;
          p_zone_tbl(l).zone_type := ZX_GLOBAL_STRUCTURES_PKG.g_hz_zone_tbl(l_zone_indx).zone_type;
          l := l + 1;
        END LOOP;
        x_zone_tbl := p_zone_tbl;
      ELSE

        IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_geography_info',
                   'Not Found Zone info in cache... call HZ_GEO_GET_PUB.get_zone');
        END IF;
        HZ_GEO_GET_PUB.get_zone(
                     x_location_table_name,
                     p_location_id,
                     p_zone_type,
                     p_trx_date,
                     l_init_msg_list,
                     x_zone_tbl,
                     x_return_status,
                     x_msg_count,
                     x_msg_data);

       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          ZX_API_PUB.G_EXTERNAL_API_CALL := 'Y';
          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            IF x_msg_count = 1
            THEN
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_procedure_name,x_msg_data);
            ELSIF x_msg_count > 1
            THEN
              FOR i in 1..x_msg_count LOOP
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_procedure_name,
                              FND_MSG_PUB.GET(p_msg_index => i, p_encoded => FND_API.G_FALSE));
              END LOOP;
            END IF;
          END IF;
       END IF;
       FOR rec IN 1 .. x_zone_tbl.count LOOP
        l_zone_indx := to_char(p_location_id) || '|' ||
                         p_location_type || '|' ||
                         p_zone_type || '|' ||
                         p_trx_date || '|' ||
                         to_char(rec);
        IF ZX_GLOBAL_STRUCTURES_PKG.g_hz_zone_tbl.EXISTS(l_zone_indx) THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          IF (g_level_unexpected >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TCM_GEO_JUR_PKG.get_zone',
                     'Caching issue can cause incorrect tax calculation.');
          END IF;
          RETURN;
        END IF;
        ZX_GLOBAL_STRUCTURES_PKG.g_hz_zone_tbl(l_zone_indx).zone_id := x_zone_tbl(rec).zone_id;
        ZX_GLOBAL_STRUCTURES_PKG.g_hz_zone_tbl(l_zone_indx).zone_name := x_zone_tbl(rec).zone_name;
        ZX_GLOBAL_STRUCTURES_PKG.g_hz_zone_tbl(l_zone_indx).zone_code := x_zone_tbl(rec).zone_code;
        ZX_GLOBAL_STRUCTURES_PKG.g_hz_zone_tbl(l_zone_indx).zone_type := x_zone_tbl(rec).zone_type;
        ZX_GLOBAL_STRUCTURES_PKG.g_hz_zone_tbl(l_zone_indx).location_id := p_location_id;
        ZX_GLOBAL_STRUCTURES_PKG.g_hz_zone_tbl(l_zone_indx).location_type := p_location_type;
        ZX_GLOBAL_STRUCTURES_PKG.g_hz_zone_tbl(l_zone_indx).trx_date := p_trx_date;
        ZX_GLOBAL_STRUCTURES_PKG.g_hz_zone_tbl(l_zone_indx).indx_value := l_zone_indx;
        ZX_GLOBAL_STRUCTURES_PKG.g_hz_zone_tbl(l_zone_indx).value := rec;
      END LOOP;

    END IF;
     -- Logging Infra: Statement level: "R" means "R"eturned value to a caller
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         IF x_zone_tbl.count > 0 THEN
           FOR i in x_zone_tbl.first..x_zone_tbl.last LOOP
             l_log_msg := 'R: hz_geo_get_pub.get_zone: out: x_zone_id='||x_zone_tbl(i).zone_id||', x_zone_code='||x_zone_tbl(i).zone_code||
                      ', x_zone_name='||x_zone_tbl(i).zone_name||', x_return_status='||x_return_status;
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
           END LOOP;
         END IF;
       END IF;
     ELSE
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         l_log_msg := 'R: Location country and Zone Type country are not matching';
         l_log_msg := l_log_msg ||' '|| l_procedure_name||'(-)';
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
       END IF;

     END IF;

   EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;

       -- Logging Infra: Statement level: "E" means "E"rror
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       IF x_zone_tbl.count > 0 THEN
         FOR i in x_zone_tbl.first..x_zone_tbl.last LOOP
           l_log_msg := 'E: EXC: FND_API.G_EXC_ERROR: x_zone_id='||x_zone_tbl(i).zone_id||', x_zone_code='||x_zone_tbl(i).zone_code||
                      ', x_zone_name='||x_zone_tbl(i).zone_name||', x_return_status='||x_return_status;
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
         END LOOP;
       END IF;
     END IF;

     WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MESSAGE.Set_Name ('ZX','ZX_GENERIC_MESSAGE');
       FND_MESSAGE.Set_Token('GENERIC_TEXT', SQLERRM);

       IF C_GEOGRAPHY_TYPES%ISOPEN THEN
           close C_GEOGRAPHY_TYPES;
       END IF;

       -- Logging Infra: Statement level: "E" means "E"rror
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       IF x_zone_tbl.count > 0 THEN
         FOR i in x_zone_tbl.first..x_zone_tbl.last LOOP
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, 'E: EXC: OTHERS: '||SQLCODE||': '|| SQLERRM);
           l_log_msg := 'E: EXC: OTHERS: x_zone_id='||x_zone_tbl(i).zone_id||', x_zone_code='||x_zone_tbl(i).zone_code||
                      ', x_zone_name='||x_zone_tbl(i).zone_name||', x_return_status='||x_return_status;
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
         END LOOP;
       END IF;
     END IF;

  END get_zone;



  PROCEDURE get_tax_jurisdictions
   ( p_location_id           IN         NUMBER,
     p_location_type         IN         VARCHAR2,
     p_tax                   IN         VARCHAR2,
     p_tax_regime_code       IN         VARCHAR2,
     p_trx_date              IN         DATE,
     x_tax_jurisdiction_rec  OUT NOCOPY tax_jurisdiction_rec_type,
     x_jurisdictions_found OUT NOCOPY VARCHAR2,
     x_return_status         OUT NOCOPY VARCHAR2) IS

    x_geography_id NUMBER;
    x_geography_code VARCHAR2(30);
    x_geography_name VARCHAR2(360);
    TYPE geography_type_use_type is TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
    --TYPE geography_id_type is TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    TYPE geography_code_type is TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
    TYPE geography_name_type is TABLE OF VARCHAR2(360) INDEX BY BINARY_INTEGER;
    TYPE geography_type_num_type is TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    l_geography_id NUMBER;
    l_geography_code VARCHAR2(30);
    l_geography_name VARCHAR2(360);
    l_tmp_count NUMBER;
    l_tax_id NUMBER;
    l_error_buffer         VARCHAR2(200);


    l_geography_type geography_type_use_type;
    l_geography_use  geography_type_use_type;
    l_geography_type_num geography_type_num_type;
    l_inner_city_jurisdiction_flag VARCHAR2(30);
    l_zone_tbl HZ_GEO_GET_PUB.zone_tbl_type;
    l_country_or_group_code VARCHAR2(30);
    l_regime_country_code VARCHAR2(30);
    l_loc_country_code VARCHAR2(30);
    l_country_regime_flag VARCHAR2(1);
    l_same_regime_loc_country VARCHAR2(1);
    x_location_table_name VARCHAR2(30);
    -- Logging Infra
    l_procedure_name CONSTANT VARCHAR2(30) := 'get_tax_jurisdictions';
    l_log_msg FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
    l_tax_rec        ZX_TDS_UTILITIES_PKG.zx_tax_info_cache_rec;
    l_tax_regime_rec zx_global_structures_pkg.tax_regime_rec_type;

    l_tbl_index      BINARY_INTEGER;
    i                NUMBER;
    l_location_info_rec ZX_GLOBAL_STRUCTURES_PKG.loc_info_rec_type;

  BEGIN

    -- Logging Infra: Setting up runtime message level
    G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    -- Logging Infra: Procedure level
     -- Logging Infra: Statement level: "B" means "B"reak point
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := l_procedure_name||'(+)';
      l_log_msg := l_log_msg ||' B: SEL hz_geography_types: in: p_tax='||p_tax||', p_tax_regime_code='||p_tax_regime_code;
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name || '.begin', l_log_msg);
    END IF;


 -- Initialize API return status to success.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_jurisdiction_rec_tmp_tbl.delete;
    x_jurisdictions_found := 'N';

       ZX_TDS_UTILITIES_PKG.get_regime_cache_info(
                         p_tax_regime_code,
                         p_trx_date,
                         l_tax_regime_rec,
                         x_return_status,
                         l_error_buffer);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
            IF (g_level_exception >= g_current_runtime_level ) THEN

               l_log_msg := 'Incorrect return_status after calling ' ||
                      'ZX_TDS_UTILITIES_PKG.get_regime_cache_info
                      RETURN_STATUS = ' || x_return_status||' Error Buffer = '||l_error_buffer||
                      ', '||l_procedure_name||' (-)';

              FND_LOG.STRING(g_level_exception,
                            G_MODULE_NAME || l_procedure_name||'.END',
                            l_log_msg);
            END IF;
            RETURN;
        END IF;

        --SELECT country_or_group_code, country_code
        --INTO l_country_or_group_code, l_regime_country_code
        --FROM zx_regimes_b
        --WHERE tax_regime_code = p_tax_regime_code;

        l_country_or_group_code := l_tax_regime_rec.country_or_group_code;
        l_regime_country_code := l_tax_regime_rec.country_code;

        /*IF (g_level_statement >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_statement,
                      G_MODULE_NAME || l_procedure_name,
                      'Country_or_group_code = ' ||l_country_or_group_code||
                      'Country_code = '||l_regime_country_code);
         END If;
        */

        IF l_country_or_group_code <> 'COUNTRY' THEN
          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            l_log_msg := 'R: Tax Regime is created for a tax zone';
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
          END IF;
          l_country_regime_flag := 'N';
        ELSE
          l_country_regime_flag := 'Y';
          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            l_log_msg := 'R: Tax Regime is created for a country';
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
          END IF;
          get_location_table_name(p_location_type,
                            x_location_table_name);

          get_location_info(p_location_id, x_location_table_name, l_location_info_rec, x_return_status);

          l_loc_country_code := l_location_info_rec.country_code;
          /* nipatel location caching
          check_location_exists(p_location_id, x_location_table_name);
          IF x_location_table_name = 'HZ_LOCATIONS' THEN
            SELECT country
            INTO l_loc_country_code
            FROM hz_locations
            WHERE location_id = p_location_id;
          ELSIF x_location_table_name = 'HR_LOCATIONS_ALL' THEN
            SELECT country
            INTO l_loc_country_code
            FROM hr_locations_all
            WHERE location_id = p_location_id;
          END IF;
         */

          IF l_regime_country_code = l_loc_country_code THEN
            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              l_log_msg := 'R: Country of Tax Regime is same as the country of the location';
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
            END IF;
            l_same_regime_loc_country := 'Y';
          ELSE
            null;
            l_same_regime_loc_country := 'N';
            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              l_log_msg := 'R: Country of Tax Regime is not the same as the country of the location';
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
            END IF;
          END IF;
        END IF;
  IF l_country_regime_flag = 'N' or l_same_regime_loc_country = 'Y' THEN

    BEGIN
      l_tbl_index := dbms_utility.get_hash_value(
                p_tax_regime_code||p_tax||'1',
                1,
                8192);

      IF g_geography_use_info_tbl.EXISTS(l_tbl_index) then
      -- The Gography usage information is there in cache. No need to read from tables


          IF (g_level_statement >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_statement,
                      G_MODULE_NAME || l_procedure_name,
                      'Found Geography usage information in cache ');
          END IF;

      ELSE

          -- Local variables; no need to initialize
          -- l_geography_type.delete;
          -- l_geography_use.delete;
          -- l_geography_type_num.delete;

          -- get tax_id
          ZX_TDS_UTILITIES_PKG.get_tax_cache_info(
                            p_tax_regime_code,
                            p_tax,
                            p_trx_date,
                            l_tax_rec,
                            x_return_status,
                            l_error_buffer);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
            IF (g_level_exception >= g_current_runtime_level ) THEN

               l_log_msg := 'Incorrect return_status after calling ' ||
                      'ZX_TDS_UTILITIES_PKG.get_regime_cache_info
                      RETURN_STATUS = ' || x_return_status||' Error Buffer = '||l_error_buffer||
                      ', '||l_procedure_name||' (-)';

              FND_LOG.STRING(g_level_exception,
                            G_MODULE_NAME || l_procedure_name||'.END',
                            l_log_msg);
            END IF;

            RETURN;
          END IF;

          l_tax_id := l_tax_rec.tax_id;

          IF (l_tax_rec.zone_geography_type IS NOT NULL OR
             l_tax_rec.override_geography_type IS NOT NULL) THEN

            SELECT geography_type, geography_use, geography_type_num
            BULK COLLECT INTO l_geography_type, l_geography_use, l_geography_type_num
            FROM
            (SELECT gt.geography_type geography_type, gt.geography_use geography_use, 1 geography_type_num
            FROM  hz_geography_types_b gt
            WHERE l_tax_rec.zone_geography_type = gt.geography_type
            UNION
            SELECT gt.geography_type geography_type, gt.geography_use geography_use, 2 geography_type_num
            FROM  hz_geography_types_b gt
            WHERE l_tax_rec.override_geography_type = gt.geography_type
            UNION
            SELECT rt.object_type geography_type,
                   gt.geography_use geography_use,
                   2+rownum geography_type_num
            FROM hz_relationship_types rt,
                 hz_geography_types_b gt
            WHERE l_tax_rec.override_geography_type = rt.subject_type
            AND  rt.object_type = gt.geography_type)
            ORDER BY 3 desc;

            For i in nvl(l_geography_type.FIRST,0)..nvl(l_geography_type.LAST,-1) LOOP

               l_tbl_index := dbms_utility.get_hash_value(
                  p_tax_regime_code||p_tax||to_char(i),
                  1,
                  8192);
               g_geography_use_info_tbl(l_tbl_index).tax_id              := l_tax_id;
               g_geography_use_info_tbl(l_tbl_index).GEOGRAPHY_TYPE_NUM  := i;
               g_geography_use_info_tbl(l_tbl_index).GEOGRAPHY_TYPE      := l_geography_type(i);
               g_geography_use_info_tbl(l_tbl_index).GEOGRAPHY_USE       := l_geography_use(i);

            END LOOP;

          END IF;

     END IF;

    EXCEPTION WHEN NO_DATA_FOUND THEN
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                l_log_msg := 'B: SEL hz_geography_type: Not Found for Tax';
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
            END IF;
    END;

    -- populate the l_inner_city_jurisdiction_flag value
    IF NVL(FND_PROFILE.value('ZX_USE_LOC_INSIDE_CITY_LIMITS'), 'N') = 'Y'
       AND p_tax = 'CITY' THEN
      IF x_location_table_name = 'HZ_LOCATIONS' THEN
        BEGIN
          SELECT DECODE(NVL(sales_tax_inside_city_limits, '0'), '0', 'N', 'Y')
          INTO l_inner_city_jurisdiction_flag
          FROM hz_locations
          WHERE location_id = p_location_id;
        EXCEPTION
          WHEN OTHERS THEN
            BEGIN
              SELECT NVL(loc_information14, 'N')
              INTO l_inner_city_jurisdiction_flag
              FROM hr_locations_all
              WHERE location_id = p_location_id;
            EXCEPTION
              WHEN OTHERS THEN
                l_inner_city_jurisdiction_flag := NULL;
            END;
        END;
      ELSIF x_location_table_name = 'HR_LOCATIONS_ALL' THEN
        BEGIN
          SELECT NVL(loc_information14, 'N')
          INTO l_inner_city_jurisdiction_flag
          FROM hr_locations_all
          WHERE location_id = p_location_id;
        EXCEPTION
          WHEN OTHERS THEN
            BEGIN
              SELECT DECODE(NVL(sales_tax_inside_city_limits, '0'), '0', 'N', 'Y')
              INTO l_inner_city_jurisdiction_flag
              FROM hz_locations
              WHERE location_id = p_location_id;
            EXCEPTION
              WHEN OTHERS THEN
                l_inner_city_jurisdiction_flag := NULL;
            END;
        END;
      END IF;
    ELSE
      l_inner_city_jurisdiction_flag := NULL;
    END IF;
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'B: SEL l_inner_city_jurisdiction_flag: ' || Nvl(l_inner_city_jurisdiction_flag,'X') ||
                   ' from Location: ' || p_location_id || ' Tax: ' || p_tax;
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
    END IF;

  --  IF l_geography_type.count > 0 THEN
      i := 1; -- counter for geography_type_num

      WHILE TRUE LOOP

           l_tbl_index := dbms_utility.get_hash_value(
                     p_tax_regime_code||p_tax||to_char(i),
                     1,
                     8192);

           IF  NOT g_geography_use_info_tbl.EXISTS(l_tbl_index) then

              EXIT;  -- exit the loop

           ELSE
               -- Logging Infra: Statement level: "B" means "B"reak point
              IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                  l_log_msg := 'B: SEL hz_geography_type: out: p_location_id='||p_location_id||',
                                p_location_type='||p_location_type||
                                ', l_geography_type='||g_geography_use_info_tbl(l_tbl_index).geography_type||
                                ', l_geography_use='||g_geography_use_info_tbl(l_tbl_index).geography_use;
                  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
              END IF;
              IF g_geography_use_info_tbl(l_tbl_index).geography_use = 'TAX' THEN
                  get_zone(p_location_id,
                           p_location_type,
                           g_geography_use_info_tbl(l_tbl_index).geography_type,
                           p_trx_date,
                           l_zone_tbl,
                           -----l_geography_id(i),
                           x_return_status);
                  -- Logging Infra: Statement level: "B" means "B"reak point
-----                  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
-----                      l_log_msg := 'B: geography info: geography_id='||l_geography_id(i)||', geography_name='||l_geography_name(i)||
-----                                   ', x_return_status='||x_return_status;
-----                      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
-----                  END IF;
                  IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
                    IF l_zone_tbl.count > 0 THEN
                      FOR j in l_zone_tbl.first..l_zone_tbl.last LOOP
                        l_geography_id := l_zone_tbl(j).zone_id;
                        get_jurisdiction(p_tax,
                                         p_tax_regime_code,
                                         l_geography_id ,
                                         p_trx_date,
                                         l_inner_city_jurisdiction_flag);
                      END LOOP;
                    END IF;
                  END IF;
              ELSIF g_geography_use_info_tbl(l_tbl_index).geography_use = 'MASTER_REF' THEN
                  get_master_geography(
                           p_location_id,
                           p_location_type,
                           g_geography_use_info_tbl(l_tbl_index).geography_type,
                           l_geography_id,
                           l_geography_code,
                           l_geography_name,
                           x_return_status);
                  -- Logging Infra: Statement level: "B" means "B"reak point
                  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                      l_log_msg := 'B: geography info: geography_id='||l_geography_id||', geography_name='||l_geography_name||
                                   ', x_return_status='||x_return_status;
                      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
                  END IF;
                  IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
                    IF l_geography_id IS NOT NULL THEN
                      get_jurisdiction(p_tax,
                                       p_tax_regime_code,
                                       l_geography_id ,
                                       p_trx_date,
                                       l_inner_city_jurisdiction_flag);
                    END IF;
                  END IF;

              END IF; -- _geography_use
          END IF; -- g_geography_use_info_tbl.EXISTS
          i := i + 1; -- counter for geography_type_num
     END LOOP;

    -- END IF;  -- l_geography_type.count > 0
  END IF;


    IF l_jurisdiction_rec_tmp_tbl.count = 1 THEN
      x_tax_jurisdiction_rec.tax_jurisdiction_id := l_jurisdiction_rec_tmp_tbl(1).tax_jurisdiction_id;
      x_tax_jurisdiction_rec.tax_jurisdiction_code := l_jurisdiction_rec_tmp_tbl(1).tax_jurisdiction_code;
      x_tax_jurisdiction_rec.tax_regime_code := l_jurisdiction_rec_tmp_tbl(1).tax_regime_code;
      x_tax_jurisdiction_rec.tax       := l_jurisdiction_rec_tmp_tbl(1).tax;
      x_tax_jurisdiction_rec.precedence_level := l_jurisdiction_rec_tmp_tbl(1).precedence_level;
      x_jurisdictions_found := 'Y';
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        l_log_msg := 'R: Single jurisdiction has been found';
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;
    ELSIF l_jurisdiction_rec_tmp_tbl.count > 1 THEN
      FOR n in l_jurisdiction_rec_tmp_tbl.first..l_jurisdiction_rec_tmp_tbl.last LOOP
        INSERT INTO zx_jurisdictions_gt
         (TAX_JURISDICTION_ID,
          TAX_JURISDICTION_CODE,
          TAX_REGIME_CODE,
          TAX,
          PRECEDENCE_LEVEL)
        SELECT
          l_jurisdiction_rec_tmp_tbl(n).tax_jurisdiction_id,
          l_jurisdiction_rec_tmp_tbl(n).tax_jurisdiction_code,
          l_jurisdiction_rec_tmp_tbl(n).tax_regime_code,
          l_jurisdiction_rec_tmp_tbl(n).tax,
          l_jurisdiction_rec_tmp_tbl(n).precedence_level
        FROM dual
        WHERE NOT EXISTS (SELECT '1'
                          FROM zx_jurisdictions_gt
                         WHERE tax_jurisdiction_code = l_jurisdiction_rec_tmp_tbl(n).tax_jurisdiction_code
                           AND tax_regime_code       = l_jurisdiction_rec_tmp_tbl(n).tax_regime_code
                           AND tax                   = l_jurisdiction_rec_tmp_tbl(n).tax
                         );

      END LOOP;
        x_jurisdictions_found := 'Y';

    -- Logging Infra: Statement level:  "R" means "R"eturned value to a caller
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        l_log_msg := 'R: Inserted into zx_jurisdictions_gt table)' ;
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;
    ELSIF l_jurisdiction_rec_tmp_tbl.count = 0 THEN
      x_jurisdictions_found := 'N';
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        l_log_msg := 'R: No jurisdiction has been found';
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;
    END IF;


    -- Logging Infra: Statement level:  "R" means "R"eturned value to a caller
----    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
----      l_log_msg := 'R: tax_jurisdiction_id='||g_jurisdiction_rec_tbl(i).tax_jurisdiction_id||
----                   ', tax_jurisdiction_code='||g_jurisdiction_rec_tbl(i).tax_jurisdiction_code;
----      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
----    END IF;
    -- Logging Infra: Procedure level
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
     l_log_msg :=  l_procedure_name||'(-)';
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name || '.end', l_log_msg);
    END IF;
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

       -- Logging Infra: Statement level
----      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
----        l_log_msg := 'E: EXC: FND_API.G_EXEC_ERROR: tax_jurisdiction_id='||g_jurisdiction_rec_tbl.tax_jurisdiction_id(i)||
----                     ', tax_jurisdiction_code='||g_jurisdiction_rec_tbl.tax_jurisdiction_code(i);
----        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
----      END IF;


   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.Set_Name ('ZX','ZX_GENERIC_MESSAGE');
     FND_MESSAGE.Set_Token('GENERIC_TEXT', SQLERRM);

     -- Logging Infra: Statement level
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, 'E: EXC: OTHERS: '||SQLCODE||': '||SQLERRM);
----       l_log_msg :=  'E: EXC: OTHERS: tax_jurisdiction_id='||g_jurisdiction_rec_tbl.tax_jurisdiction_id(i)||
----                     ', tax_jurisdiction_code='||g_jurisdiction_rec_tbl.tax_jurisdiction_code(i);
----       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
    END IF;

  END get_tax_jurisdictions;

  PROCEDURE get_master_geography
    (p_location_id         IN         VARCHAR2,
     p_location_type       IN         VARCHAR2,
     p_geography_type      IN         VARCHAR2,
     x_geography_id        OUT NOCOPY NUMBER,
     x_geography_code      OUT NOCOPY VARCHAR2,
     x_geography_name      OUT NOCOPY VARCHAR2,
     x_return_status       OUT NOCOPY VARCHAR2) IS

    l_count NUMBER;
    x_location_table_name  VARCHAR2(30);
    l_country_code VARCHAR2(30);
    -- Logging Infra
    l_procedure_name   CONSTANT VARCHAR2(30) := 'get_master_geography';
    l_log_msg     FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

    l_location_info_rec ZX_GLOBAL_STRUCTURES_PKG.loc_info_rec_type;
    l_geography_use     hz_geographies.geography_use%type;
    l_tbl_index   binary_integer;
    l_tbl_country_index binary_integer;

  BEGIN
    -- Logging Infra: Setting up runtime level
    G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    -- Logging Infra: Procedure level
    -- Logging Infra: Statement level: "B" means "B"reak point
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := l_procedure_name||'(+)';
      l_log_msg := l_log_msg||' B: SEL hz_geography_types: in: p_geography_type='||p_geography_type;
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name || '.begin', l_log_msg);
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    /* nipatel commented out this validation because the call to get_master_geography is
       being made from within this package itself and there we are already fetching the
       goegoraphy type from hz_geography_types_b and the call is made only when geograpy_use
       is 'MASTER_REF'

       -- Validate geography type
       SELECT count(*)
       INTO   l_count
       FROM   hz_geography_types_b
       WHERE  geography_type = p_geography_type
       AND    geography_use = 'MASTER_REF';

       -- ---------------------
       IF l_count = 0 THEN
         -- Logging Infra: Statement level: "E" means "E"rror
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           l_log_msg := 'E: SEL hz_geography_types: no_data_found: '||'p_geography_type='||p_geography_type;
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
         END IF;

         --x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_TYPE_INVALID');
         RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- ---------------------
    */
     get_location_table_name(p_location_type,
                            x_location_table_name);
     get_location_info(p_location_id, x_location_table_name, l_location_info_rec,x_return_status);
     x_location_table_name := ZX_GLOBAL_STRUCTURES_PKG.Loc_info_tbl(to_char(p_location_id)).location_table_name;


     -- Logging Infra: Statement level: "B" means "B"reak point
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        l_log_msg := 'B: SEL hz_geo_name_ref: in: p_location_id='||p_location_id||', p_geography_type='||p_geography_type||
                     ', x_location_table_name='||x_location_table_name;
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
    END IF;

    -- Find geography id from gnr table
    -- ---------------------------------

    l_tbl_index := dbms_utility.get_hash_value(
                     to_char(p_location_id)||p_geography_type,
                     1,
                     8192);

    IF zx_global_structures_pkg.Loc_geography_info_tbl.exists(l_tbl_index) AND
           (zx_global_structures_pkg.Loc_geography_info_tbl(l_tbl_index).location_id = p_location_id AND
          zx_global_structures_pkg.Loc_geography_info_tbl(l_tbl_index).geography_type = p_geography_type) THEN

        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
             l_log_msg := 'Found the geography id and geography name info in cache';
             FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, l_log_msg);
        END IF;

        x_geography_id := zx_global_structures_pkg.Loc_geography_info_tbl(l_tbl_index).geography_id;
        x_geography_code :=  zx_global_structures_pkg.Loc_geography_info_tbl(l_tbl_index).geography_code;
        x_geography_name :=  zx_global_structures_pkg.Loc_geography_info_tbl(l_tbl_index).geography_name;

     ELSE

        BEGIN
          SELECT gnr.geography_id, geo.geography_code, geo.geography_name, geo.geography_use
          INTO   x_geography_id, x_geography_code, x_geography_name, l_geography_use
          FROM   hz_geo_name_references gnr, hz_geographies geo
          WHERE  gnr.location_table_name = x_location_table_name
          AND    gnr.location_id = p_location_id
          AND    gnr.geography_type = p_geography_type
          AND    geo.geography_id = gnr.geography_id;

          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            l_log_msg := 'B: SEL hz_geo_name_ref: out: x_geography_id='||x_geography_id;
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
          END IF;

          zx_global_structures_pkg.Loc_geography_info_tbl(l_tbl_index).location_id    := p_location_id;
          zx_global_structures_pkg.Loc_geography_info_tbl(l_tbl_index).geography_type := p_geography_type;
          zx_global_structures_pkg.Loc_geography_info_tbl(l_tbl_index).geography_id   := x_geography_id;
          zx_global_structures_pkg.Loc_geography_info_tbl(l_tbl_index).geography_code := x_geography_code;
          zx_global_structures_pkg.Loc_geography_info_tbl(l_tbl_index).geography_name := x_geography_name;
          zx_global_structures_pkg.Loc_geography_info_tbl(l_tbl_index).geography_use  := l_geography_use;


        EXCEPTION WHEN NO_DATA_FOUND THEN

          -- Logging Infra: Statement level: "S" means "S"uccess. Geography code can be NULL.
          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            l_log_msg := 'S: SEL hz_geo_name_ref: no_data_found: '||'x_location_table_name='||x_location_table_name||' B: x_geography_id='||x_geography_id||', p_geography_type='||p_geography_type||
                         ', p_location_id='||p_location_id||', p_geography_type='||p_geography_type;
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
          END IF;
        END;

    END IF;

    IF x_geography_id IS NULL THEN
      IF p_geography_type = 'COUNTRY' THEN
        -- access location tables to get the country.

         l_country_code := l_location_info_rec.country_code;

        -- Logging Infra: "B" means "B"reak point
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          l_log_msg := 'B: SEL hz_geographies: in: l_country_code='||l_country_code;
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
        END IF;

        BEGIN
          SELECT geography_id, geography_code, geography_name
          INTO x_geography_id, x_geography_code, x_geography_name
          FROM hz_geographies
          WHERE geography_code = l_country_code
          AND  geography_type = 'COUNTRY';

        EXCEPTION WHEN NO_DATA_FOUND THEN

          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            l_log_msg := 'E: SEL hz_geographies: no_data_found: '||'l_country_code='
                        ||l_country_code||' for location '||p_location_id
                        ||' and table '||x_location_table_name;
            FND_LOG.STRING(G_LEVEL_STATEMENT,
                           G_MODULE_NAME || l_procedure_name,
                           l_log_msg);
          END IF;

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          --FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_INVALID_COUNTRY');
          --FND_MESSAGE.SET_TOKEN('LOC_ID', p_location_id);
          --FND_MESSAGE.SET_TOKEN('TABLE_NAME', x_location_table_name);
          --RAISE FND_API.G_EXC_ERROR;
          RETURN;
        END;
      ELSE


        /* 3471450 -- Logging Infra: return_status changed to success status */
        -- Logging Infra: Statement level: "S" means "S"uccess. Geography code can be NULL.
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          l_log_msg := 'S: hz_geo_no_geo_name_ref: p_geography_type='||p_geography_type;
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
        END IF;

        x_return_status := FND_API.G_RET_STS_SUCCESS;

      END IF; -- p_geography_type = 'COUNTRY'
    END IF; --x_geography_id IS NULL

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'R: x_geography_id='||x_geography_id||', x_gegraphy_code='||x_geography_code||
                   ', x_geography_name='||x_geography_name;
      l_log_msg := l_log_msg || '- '||l_procedure_name||'(-)';
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         l_log_msg := 'E: EXC: FND_API.G_EXC_ERROR: x_geography_id='||
                    x_geography_id||', x_gegraphy_code='||x_geography_code||',
                    x_geography_name='||x_geography_name;
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME ||l_procedure_name,l_log_msg);
      END IF;

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MESSAGE.Set_Name ('ZX','ZX_GENERIC_MESSAGE');
      FND_MESSAGE.Set_Token('GENERIC_TEXT', SQLERRM);

      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name,
                    'E: EXC: OTHERS: '|| SQLCODE||': '||SQLERRM);
       l_log_msg := 'E: EXC: OTHERS: x_geography_id='||x_geography_id||',
                     x_gegraphy_code='||x_geography_code||
                    ', x_geography_name='||x_geography_name;
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME ||l_procedure_name,l_log_msg);
      END IF;
  END;

PROCEDURE RETRIEVE_GEO_VALUE( p_event_class_mapping_id IN  ZX_LINES_DET_FACTORS.event_class_mapping_id%type,
                              p_trx_id                 IN  ZX_LINES_DET_FACTORS.trx_id%type,
                              p_trx_line_id            IN  ZX_LINES_DET_FACTORS.trx_line_id%type,
                              p_trx_level_type         IN  ZX_LINES_DET_FACTORS.trx_level_type%type,
                              p_location_type          IN  VARCHAR2,
                              p_location_id            IN  ZX_LINES_DET_FACTORS.ship_to_location_id%type,
                              p_geography_type         IN  VARCHAR2,
                              x_geography_value        OUT NOCOPY VARCHAR2,
                              x_geography_id         OUT NOCOPY NUMBER,
                              x_geo_val_found          OUT NOCOPY BOOLEAN) IS

   hash_string                     varchar2(1000);
   TABLE_SIZE              BINARY_INTEGER := 65636;
   TABLEIDX                        binary_integer;
   loc_info_idx                    binary_integer;
   HASH_VALUE binary_integer;

   BEGIN

      hash_string := to_char(p_event_class_mapping_id)||'|'||
                     to_char(p_trx_id)||'|'||
                     to_char(p_trx_line_id)||'|'||
                     p_trx_level_type||'|'||
                     p_location_type||'|'||
                     to_char(p_location_id)||'|'||
                     p_geography_type;

       TABLEIDX := dbms_utility.get_hash_value(hash_string,1,TABLE_SIZE);

       IF (ZX_GLOBAL_STRUCTURES_PKG.location_hash_tbl.EXISTS(TABLEIDX)) THEN
         loc_info_idx := ZX_GLOBAL_STRUCTURES_PKG.location_hash_tbl(TABLEIDX);
         x_geography_value := ZX_GLOBAL_STRUCTURES_PKG.location_info_tbl.geography_value(loc_info_idx);
         x_geography_id:= ZX_GLOBAL_STRUCTURES_PKG.location_info_tbl.geography_id(loc_info_idx);
         x_geo_val_found := TRUE;
       ELSE
         x_geo_val_found := FALSE;
       END IF;

end RETRIEVE_GEO_VALUE;

 PROCEDURE populate_loc_geography_info
    (EVENT_CLASS_MAPPING_ID IN NUMBER,
     TRX_ID                 IN NUMBER,
     TRX_LINE_ID            IN NUMBER,
     TRX_LEVEL_TYPE         IN VARCHAR2,
     LOCATION_TYPE_TBL      IN ZX_TCM_GEO_JUR_PKG.LOCATION_TYPE_TBL_TYPE,
     LOCATION_ID_TBL        IN ZX_TCM_GEO_JUR_PKG.LOCATION_ID_TBL_TYPE,
     x_return_status        OUT NOCOPY VARCHAR2
) IS
n NUMBER;
k BINARY_INTEGER;
x_loc_tbl VARCHAR2(30);
l_error_flag VARCHAR2(1) := 'N';
geography_found VARCHAR2(6) := 'FALSE';
idx1 VARCHAR2(200);
hash_string VARCHAR2(1000);
TABLEIDX    binary_integer;
TABLE_SIZE  BINARY_INTEGER := 65636;
TYPE GEO_ID_TBL_TYPE IS TABLE OF NUMBER index by BINARY_INTEGER;
l_geography_id GEO_ID_TBL_TYPE;

TYPE GEO_TYPE_TBL_TYPE IS TABLE OF VARCHAR2(30) index by BINARY_INTEGER;
l_geography_type GEO_TYPE_TBL_TYPE;

TYPE GEO_NAME_TBL_TYPE IS TABLE OF VARCHAR2(360) index by BINARY_INTEGER;
l_geography_name GEO_NAME_TBL_TYPE;
    -- Logging Infra
    l_procedure_name CONSTANT VARCHAR2(30) := 'populate_loc_geography_info';
    l_log_msg FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
BEGIN
 -- Logging Infra: Setting up runtime level
 G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := l_procedure_name||'(+)';
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name || '.begin', l_log_msg);
    END IF;

 -- Initialize API return status to success.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

IF location_type_tbl.count > 0 THEN

  FOR i IN location_type_tbl.first..location_type_tbl.last LOOP
    ZX_TCM_GEO_JUR_PKG.get_location_table_name(location_type_tbl(i), x_loc_tbl);

    check_location_exists(location_id_tbl(i), x_loc_tbl);

    -- Logging Infra: Statement level: "B" means "B"reak point
    -- IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    --   l_log_msg := 'B: get_location_table_name: out: x_loc_tbl='||x_loc_tbl;
    --   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
    -- END IF;

    n := 1;
    idx1 := to_char(event_class_mapping_id)||location_type_tbl(i)||location_id_tbl(i) ||x_loc_tbl|| to_char(n);
    k := ZX_GLOBAL_STRUCTURES_PKG.LOCATION_INFO_TBL.event_class_mapping_id.last;
    IF k IS NOT NULL THEN
      k := k + 1;
    ELSE
      k := 1;
    END IF;
    LOOP

    IF g_geography_id_tbl.exists(idx1) THEN
      geography_found := 'TRUE';
    -- Logging Infra: Statement level: "B" means "B"reak point
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           l_log_msg := 'B: Geography found ';
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;
      ZX_GLOBAL_STRUCTURES_PKG.LOCATION_INFO_TBL.event_class_mapping_id(k) :=
                event_class_mapping_id;
      ZX_GLOBAL_STRUCTURES_PKG.LOCATION_INFO_TBL.trx_id(k) :=  trx_id;
      ZX_GLOBAL_STRUCTURES_PKG.LOCATION_INFO_TBL.trx_line_id(k) := trx_line_id;
      ZX_GLOBAL_STRUCTURES_PKG.LOCATION_INFO_TBL.trx_level_type(k) := trx_level_type;
      ZX_GLOBAL_STRUCTURES_PKG.LOCATION_INFO_TBL.location_type(k) := location_type_tbl(i);
      ZX_GLOBAL_STRUCTURES_PKG.LOCATION_INFO_TBL.location_table_name(k) := x_loc_tbl;
      ZX_GLOBAL_STRUCTURES_PKG.LOCATION_INFO_TBL.location_id (k) := location_id_tbl(i);
      ZX_GLOBAL_STRUCTURES_PKG.LOCATION_INFO_TBL.geography_id(k) := g_geography_id_tbl(idx1);

      ZX_GLOBAL_STRUCTURES_PKG.LOCATION_INFO_TBL.geography_type(k) := g_geography_type_tbl(idx1);
      ZX_GLOBAL_STRUCTURES_PKG.LOCATION_INFO_TBL.geography_value(k) := g_geography_name_tbl(idx1);


      hash_string := to_char(event_class_mapping_id)||'|'||
                     to_char(trx_id)||'|'||
                     to_char(trx_line_id)||'|'||
                     trx_level_type||'|'||
                     location_type_tbl(i)||'|'||
                     to_char(location_id_tbl(i))||'|'||
                     g_geography_type_tbl(idx1);

       TABLEIDX := dbms_utility.get_hash_value(hash_string,1,TABLE_SIZE);

       ZX_GLOBAL_STRUCTURES_PKG.location_hash_tbl(TABLEIDX) := k;


    -- Logging Infra: Statement level: "B" means "B"reak point
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           l_log_msg := 'B: Geography found ='||event_class_mapping_id||trx_id||trx_line_id||
                         trx_level_type||x_loc_tbl||location_id_tbl(i)||g_geography_id_tbl(idx1)
                         ||g_geography_type_tbl(idx1)||g_geography_name_tbl(idx1);
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;
      n := n + 1;
      k := k + 1;
      idx1 := to_char(event_class_mapping_id)||location_type_tbl(i)||location_id_tbl(i) ||x_loc_tbl|| to_char(n);
    ELSE
      -- Logging Infra: Statement level: "B" means "B"reak point
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           l_log_msg := 'B: Geography NOT existing in cache ';
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;
      EXIT;
    END IF;
    END LOOP;
    IF geography_found <> 'TRUE' THEN
      -- Logging Infra: Statement level: "B" means "B"reak point
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         l_log_msg := 'B: Fetching geography info from gnr. The Location id is'||to_char(location_id_tbl(i));
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;
     BEGIN
       l_error_flag := 'N';
      SELECT gnr.geography_id, gnr.geography_type, g.geography_name
      BULK COLLECT INTO  l_geography_id, l_geography_type, l_geography_name
      FROM hz_geo_name_references gnr, hz_geographies g
      WHERE location_table_name = x_loc_tbl
      AND  location_id = location_id_tbl(i)
      AND  gnr.geography_id = g.geography_id
      ORDER BY gnr.geography_id;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           l_log_msg := 'B: After GNR fetch ';
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;
     EXCEPTION
      WHEN OTHERS THEN
        -- Logging Infra: Statement level
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, 'E: EXC: OTHERS: '
                               || SQLCODE||': '||SQLERRM);

           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
        END IF;
        l_error_flag := 'Y';
     END;
     IF l_error_flag <> 'Y' then
        n := 1;
        idx1 := to_char(event_class_mapping_id)||location_type_tbl(i)||location_id_tbl(i) ||x_loc_tbl|| to_char(n);
  IF l_geography_id.count > 0 THEN
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                l_log_msg := 'B: Entering assignment loop after GNR fetch';
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
           END IF;


           FOR m IN l_geography_id.first..l_geography_id.last LOOP
       -----for each geography element found above add row in location_info_tbl, g_geography_id_tbl;
          g_geography_id_tbl(idx1) :=  l_geography_id(m);

          g_geography_type_tbl(idx1) :=  l_geography_type(m);

          g_geography_name_tbl(idx1) :=  l_geography_name(m);

          ZX_GLOBAL_STRUCTURES_PKG.LOCATION_INFO_TBL.event_class_mapping_id(k) := event_class_mapping_id;

          ZX_GLOBAL_STRUCTURES_PKG.LOCATION_INFO_TBL.trx_id(k) :=  trx_id;

          ZX_GLOBAL_STRUCTURES_PKG.LOCATION_INFO_TBL.trx_line_id(k) := trx_line_id;

          ZX_GLOBAL_STRUCTURES_PKG.LOCATION_INFO_TBL.trx_level_type(k) := trx_level_type;

          ZX_GLOBAL_STRUCTURES_PKG.LOCATION_INFO_TBL.location_type(k) := location_type_tbl(i);

          ZX_GLOBAL_STRUCTURES_PKG.LOCATION_INFO_TBL.location_table_name(k) := x_loc_tbl;

          ZX_GLOBAL_STRUCTURES_PKG.LOCATION_INFO_TBL.location_id (k) := location_id_tbl(i);

          ZX_GLOBAL_STRUCTURES_PKG.LOCATION_INFO_TBL.geography_id(k) := g_geography_id_tbl(idx1);

          ZX_GLOBAL_STRUCTURES_PKG.LOCATION_INFO_TBL.geography_type(k) := g_geography_type_tbl(idx1);

          ZX_GLOBAL_STRUCTURES_PKG.LOCATION_INFO_TBL.geography_value(k) := g_geography_name_tbl(idx1);

                IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               l_log_msg := 'B: g_geography_id_tbl(idx1): l_geography_id(m)'||
                                     g_geography_id_tbl(idx1)|| l_geography_id(m);
                        l_log_msg := l_log_msg ||' B: g_geography_type_tbl(idx1): l_geography_type(m)'
                                     ||g_geography_type_tbl(idx1)|| l_geography_type(m);
                        l_log_msg := l_log_msg ||' B: g_geography_name_tbl(idx1): l_geography_name(m)'
                                     ||g_geography_name_tbl(idx1)|| l_geography_name(m);
                        l_log_msg := l_log_msg ||' B: LOCATION_INFO_TBL.event_class_mapping_id(k)'
                                     || ZX_GLOBAL_STRUCTURES_PKG.LOCATION_INFO_TBL.event_class_mapping_id(k);
                        l_log_msg := l_log_msg ||' B: LOCATION_INFO_TBL.trx_id(k)'
                                     ||ZX_GLOBAL_STRUCTURES_PKG.LOCATION_INFO_TBL.trx_id(k);
                        l_log_msg := l_log_msg ||' B: LOCATION_INFO_TBL.trx_line_id(k)'
                                     ||ZX_GLOBAL_STRUCTURES_PKG.LOCATION_INFO_TBL.trx_line_id(k);
                        l_log_msg := l_log_msg ||' B: LOCATION_INFO_TBL.trx_level_type(k)'
                                     ||ZX_GLOBAL_STRUCTURES_PKG.LOCATION_INFO_TBL.trx_level_type(k);
                        l_log_msg := l_log_msg ||' B: LOCATION_INFO_TBL.location_type(k)'
                                     ||ZX_GLOBAL_STRUCTURES_PKG.LOCATION_INFO_TBL.location_type(k);
                        l_log_msg := l_log_msg ||' B: LOCATION_INFO_TBL.location_table_name(k)'
                                  ||ZX_GLOBAL_STRUCTURES_PKG.LOCATION_INFO_TBL.location_table_name(k);
                        l_log_msg := l_log_msg ||' B: LOCATION_INFO_TBL.location_id(k)'
                                  ||ZX_GLOBAL_STRUCTURES_PKG.LOCATION_INFO_TBL.location_id(k);
                        l_log_msg := l_log_msg ||' B: LOCATION_INFO_TBL.geography_id(k)'
                                   ||ZX_GLOBAL_STRUCTURES_PKG.LOCATION_INFO_TBL.geography_id(k);
                        l_log_msg := l_log_msg ||' B: LOCATION_INFO_TBL.geography_type(k)'
                               ||ZX_GLOBAL_STRUCTURES_PKG.LOCATION_INFO_TBL.geography_type(k);
                        l_log_msg := l_log_msg || 'B: LOCATION_INFO_TBL.geography_value(k)'
                                   ||ZX_GLOBAL_STRUCTURES_PKG.LOCATION_INFO_TBL.geography_value(k);
                        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
                END IF;

      hash_string := to_char(event_class_mapping_id)||'|'||
                     to_char(trx_id)||'|'||
                     to_char(trx_line_id)||'|'||
                     trx_level_type||'|'||
                     location_type_tbl(i)||'|'||
                     to_char(location_id_tbl(i))||'|'||
                     g_geography_type_tbl(idx1);

       TABLEIDX := dbms_utility.get_hash_value(hash_string,1,TABLE_SIZE);

       ZX_GLOBAL_STRUCTURES_PKG.location_hash_tbl(TABLEIDX) := k;

                -- Logging Infra: Statement level: "B" means "B"reak point
                IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                   l_log_msg := 'B: Geography details populated'|| g_geography_id_tbl(idx1)
                         ||g_geography_type_tbl(idx1)||g_geography_name_tbl(idx1);
                   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
                END IF;

          n := n + 1;
          k := k + 1;
          idx1 := to_char(event_class_mapping_id)||location_type_tbl(i)||location_id_tbl(i) ||x_loc_tbl|| to_char(n);

           END LOOP;
  END IF;
     END IF;
     END IF;
    END LOOP;
 END IF;
END;

END;

/
