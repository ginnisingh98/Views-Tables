--------------------------------------------------------
--  DDL for Package Body ZX_MERGE_LOC_CHECK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_MERGE_LOC_CHECK_PKG" AS
/* $Header: zxcmergegnrchkb.pls 120.3.12010000.2 2008/10/20 18:19:08 tsen ship $ */

  G_CURRENT_RUNTIME_LEVEL      NUMBER;
  G_LEVEL_UNEXPECTED           CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
  G_LEVEL_ERROR                CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
  G_LEVEL_EXCEPTION            CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_EVENT                CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
  G_LEVEL_PROCEDURE            CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_STATEMENT            CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
  G_MODULE_NAME                CONSTANT VARCHAR2(30) := 'ZX.ZX_MERGE_LOC_CHECK_PKG';
  l_log_msg   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
  l_procedure_name CONSTANT VARCHAR2(30) := 'CHECK_GNR';

PROCEDURE CHECK_GNR(p_from_location_id IN  NUMBER,
                    p_to_location_id   IN  NUMBER,
                    p_init_msg_list    IN  VARCHAR2,
                    x_merge_yn         OUT NOCOPY VARCHAR2,
                    x_return_status    OUT NOCOPY VARCHAR2,
                    x_msg_count        OUT NOCOPY NUMBER,
                    x_msg_data         OUT NOCOPY VARCHAR2) AS
TYPE number_tbl_type IS TABLE OF NUMBER;
TYPE varchar2_tbl_type IS TABLE OF VARCHAR2(30);
l_from_geography_id_tbl number_tbl_type;
l_from_geography_type_tbl varchar2_tbl_type;
l_to_geography_id_tbl number_tbl_type;
l_to_geography_type_tbl varchar2_tbl_type;
l_from_country_code VARCHAR2(30);
l_to_country_code VARCHAR2(30);
l_from_tax_usage_exists VARCHAR2(6);
l_to_tax_usage_exists VARCHAR2(6);
l_from_geography_id_count NUMBER;
l_to_geography_id_count NUMBER;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_merge_yn := 'N';
  BEGIN
    SELECT 'TRUE'
    INTO l_from_tax_usage_exists
    FROM hz_geo_struct_map map, hz_locations loc, hz_address_usages usage
    WHERE map.country_code = loc.country
    AND  map.loc_tbl_name = 'HZ_LOCATIONS'
    AND  nvl(map.address_style,'1') = nvl(loc.address_style,'1')
    AND  map.map_id = usage.map_id
    AND  usage.usage_code = 'TAX'
    AND  loc.location_id = p_from_location_id;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    l_from_tax_usage_exists := 'FALSE';
  END;

  BEGIN
    SELECT 'TRUE'
    INTO l_to_tax_usage_exists
    FROM hz_geo_struct_map map, hz_locations loc, hz_address_usages usage
    WHERE map.country_code = loc.country
    AND  map.loc_tbl_name = 'HZ_LOCATIONS'
    AND  nvl(map.address_style,'1') = nvl(loc.address_style,'1')
    AND  map.map_id = usage.map_id
    AND  usage.usage_code = 'TAX'
    AND  loc.location_id = p_to_location_id;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    l_to_tax_usage_exists := 'FALSE';
  END;

  IF l_from_tax_usage_exists = 'TRUE' and l_to_tax_usage_exists = 'TRUE' THEN
    SELECT gnr.geography_id, gnr.geography_type
    BULK COLLECT INTO l_from_geography_id_tbl, l_from_geography_type_tbl
    FROM hz_geo_name_references gnr,
         hz_geo_name_reference_log log,
         hz_geo_struct_map map,
         hz_locations loc,
         hz_address_usages usage,
         hz_address_usage_dtls dtl
    WHERE gnr.location_id = p_from_location_id
    AND   gnr.location_id = log.location_id
    AND   log.map_status = 'S'
    AND   log.usage_code = 'TAX'
    AND   loc.location_id = gnr.location_id
    AND   map.country_code = loc.country
    AND   map.loc_tbl_name = 'HZ_LOCATIONS'
    AND   nvl(map.address_style,'1') = nvl(loc.address_style,'1')
    AND   map.map_id = usage.map_id
    AND   usage.usage_code = 'TAX'
    AND   dtl.usage_id = usage.usage_id
    AND   dtl.geography_type = gnr.geography_type
    ORDER BY gnr.geography_id;

    SELECT gnr.geography_id, gnr.geography_type
    BULK COLLECT INTO l_to_geography_id_tbl, l_to_geography_type_tbl
    FROM hz_geo_name_references gnr,
         hz_geo_name_reference_log log,
         hz_geo_struct_map map,
         hz_locations loc,
         hz_address_usages usage,
         hz_address_usage_dtls dtl
    WHERE gnr.location_id = p_to_location_id
    AND  gnr.location_id = log.location_id
    AND  log.map_status = 'S'
    AND log.usage_code = 'TAX'
    AND   loc.location_id = gnr.location_id
    AND   map.country_code = loc.country
    AND   map.loc_tbl_name = 'HZ_LOCATIONS'
    AND   nvl(map.address_style,'1') = nvl(loc.address_style,'1')
    AND   map.map_id = usage.map_id
    AND   usage.usage_code = 'TAX'
    AND   dtl.usage_id = usage.usage_id
    AND   dtl.geography_type = gnr.geography_type
    ORDER BY gnr.geography_id;

    l_from_geography_id_count := l_from_geography_id_tbl.count;
    l_to_geography_id_count := l_to_geography_id_tbl.count;


    IF l_from_geography_id_count = 0 OR l_to_geography_id_count = 0 THEN
      x_merge_yn := 'N';
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        l_log_msg := 'B: Tax Usage exists for from and to locations but no GNR has been created';
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;
      return;
    END IF;
    IF l_from_geography_id_count <> l_to_geography_id_count THEN
      x_merge_yn := 'N';
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        l_log_msg := 'B: Tax Usage exists for from and to locations but GNR rows are different';
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;
    ELSE
      FOR i IN l_from_geography_id_tbl.first..l_from_geography_id_tbl.last LOOP
        IF l_from_geography_id_tbl(i) = l_to_geography_id_tbl(i) THEN
          x_merge_yn := 'Y';
        ELSE
          x_merge_yn := 'N';
          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            l_log_msg := 'B: Tax Usage exists for from and to locations and GNR rows are not identical';
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
          END IF;
          EXIT;
        END IF ;
      END LOOP;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         l_log_msg := 'B: After Loop Tax Usage for from and to locations and GNR rows are identical';
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;

    END IF;

  ELSIF l_from_tax_usage_exists = 'FALSE' and l_to_tax_usage_exists = 'FALSE' THEN
    SELECT country
    INTO l_from_country_code
    FROM hz_locations loc
    WHERE loc.location_id = p_from_location_id;

    SELECT country
    INTO l_to_country_code
    FROM hz_locations loc
    WHERE loc.location_id = p_to_location_id;

    IF l_from_country_code <> l_to_country_code THEN
      x_merge_yn := 'N';
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        l_log_msg := 'B: Tax Usage does not exist for from and to locations and country codes are different';
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;
    ELSE
      x_merge_yn := 'Y';
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        l_log_msg := 'B: Tax Usage does not exist for from and to locations and country codes are identical';
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;
    END IF;

  ELSIF l_from_tax_usage_exists = 'TRUE' and l_to_tax_usage_exists = 'FALSE' THEN
    x_merge_yn := 'N';
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'B: Tax Usage exists for from location but not for to location';
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
    END IF;

  ELSIF l_from_tax_usage_exists = 'FALSE' and l_to_tax_usage_exists = 'TRUE' THEN
    x_merge_yn := 'N';
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'B: Tax Usage does not exist for from location but exists for to location';
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
    END IF;
  END IF;
EXCEPTION WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.Set_Name ('ZX','ZX_GENERIC_MESSAGE');
     FND_MESSAGE.Set_Token('GENERIC_TEXT', SQLERRM);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count        => x_msg_count,
                                p_data        => x_msg_data);

     -- Logging Infra: Statement level
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, 'E: EXC: OTHERS: '||SQLCODE||': '||SQLERRM);
     END IF;


END;

END;

/
