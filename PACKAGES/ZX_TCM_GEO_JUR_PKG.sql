--------------------------------------------------------
--  DDL for Package ZX_TCM_GEO_JUR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_TCM_GEO_JUR_PKG" AUTHID CURRENT_USER AS
/* $Header: zxcjurs.pls 120.13.12010000.2 2009/09/29 09:32:25 msakalab ship $ */


  TYPE tax_jurisdiction_rec_type IS RECORD
   ( tax_jurisdiction_id          NUMBER,
     tax_jurisdiction_code        VARCHAR2(30),
    ----- effective_from               DATE,
    ----- effective_to                 DATE,
     tax_regime_code              VARCHAR2(30),
    ----- coll_tax_authority_id        NUMBER,
    ----- rep_tax_authority_id         NUMBER,
     tax                          VARCHAR2(30),
    ----- zone_geography_id            NUMBER,
    ----- inner_city_jurisdiction_flag VARCHAR2(1),
     precedence_level             NUMBER
    ----- default_jurisdiction_flg     VARCHAR2(1),
    ----- default_flg_effective_from   DATE,
    ----- default_flg_effective_to     DATE
   );

  TYPE tax_jurisdiction_rec_tbl_type IS TABLE of tax_jurisdiction_rec_type INDEX BY BINARY_INTEGER;

  -- bug fix 4090639
 ----- g_jurisdiction_rec_tbl  tax_jurisdiction_rec_tbl_type;

  PROCEDURE get_zone
   ( p_location_id       IN         NUMBER,
     p_location_type     IN         VARCHAR2,
     p_zone_type         IN         VARCHAR2,
     p_trx_date          IN         DATE,
     x_zone_tbl          OUT NOCOPY HZ_GEO_GET_PUB.zone_tbl_type,
     x_return_status     OUT NOCOPY VARCHAR2);

  PROCEDURE get_pos_loc_or_site
   ( p_party_type        IN         VARCHAR2,
     x_loc_tbl           OUT NOCOPY VARCHAR2,
     x_loc_site          OUT NOCOPY VARCHAR2,
     x_return_status     OUT NOCOPY VARCHAR2);


  PROCEDURE get_tax_jurisdictions
   ( p_location_id       IN         NUMBER,
     p_location_type     IN         VARCHAR2,
     p_tax               IN         VARCHAR2,
     p_tax_regime_code   IN         VARCHAR2,
     p_trx_date          IN         DATE,
     x_tax_jurisdiction_rec OUT NOCOPY tax_jurisdiction_rec_type,
     x_jurisdictions_found OUT NOCOPY VARCHAR2,
     x_return_status     OUT NOCOPY VARCHAR2);

  PROCEDURE get_master_geography
    (p_location_id         IN         VARCHAR2,
     p_location_type       IN         VARCHAR2,
     p_geography_type      IN         VARCHAR2,
     x_geography_id        OUT NOCOPY NUMBER,
     x_geography_code      OUT NOCOPY VARCHAR2,
     x_geography_name      OUT NOCOPY VARCHAR2,
     x_return_status       OUT NOCOPY VARCHAR2);

 TYPE LOCATION_TYPE_TBL_TYPE IS TABLE OF VARCHAR2(30) index by binary_integer;
 TYPE LOCATION_ID_TBL_TYPE IS TABLE OF NUMBER index by binary_integer;


/*Added by Usha for bug 4458010 */
PROCEDURE RETRIEVE_GEO_VALUE
	( p_event_class_mapping_id IN  ZX_LINES_DET_FACTORS.event_class_mapping_id%type,
          p_trx_id                 IN  ZX_LINES_DET_FACTORS.trx_id%type,
          p_trx_line_id            IN  ZX_LINES_DET_FACTORS.trx_line_id%type,
          p_trx_level_type         IN  ZX_LINES_DET_FACTORS.trx_level_type%type,
          p_location_type          IN  VARCHAR2,
          p_location_id            IN  ZX_LINES_DET_FACTORS.ship_to_location_id%type,
          p_geography_type         IN  VARCHAR2,
          x_geography_value        OUT NOCOPY VARCHAR2,
          x_geography_id 	   OUT NOCOPY NUMBER,
          x_geo_val_found          OUT NOCOPY BOOLEAN);

  PROCEDURE populate_loc_geography_info
    (EVENT_CLASS_MAPPING_ID IN NUMBER,
     TRX_ID                 IN NUMBER,
     TRX_LINE_ID            IN NUMBER,
     TRX_LEVEL_TYPE         IN VARCHAR2,
     LOCATION_TYPE_TBL      IN ZX_TCM_GEO_JUR_PKG.LOCATION_TYPE_TBL_TYPE,
     LOCATION_ID_TBL        IN ZX_TCM_GEO_JUR_PKG.LOCATION_ID_TBL_TYPE,
     x_return_status        OUT NOCOPY VARCHAR2);

 TYPE GEOGRAPHY_ID_TBL_TYPE IS TABLE OF NUMBER index by VARCHAR2(200);
 g_geography_id_tbl GEOGRAPHY_ID_TBL_TYPE;

 TYPE GEOGRAPHY_TYPE_TBL_TYPE IS TABLE OF VARCHAR2(30) index by VARCHAR2(200);
 g_geography_type_tbl GEOGRAPHY_TYPE_TBL_TYPE;

 TYPE GEOGRAPHY_NAME_TBL_TYPE IS TABLE OF VARCHAR2(360) index by VARCHAR2(200);
 g_geography_name_tbl GEOGRAPHY_NAME_TBL_TYPE;
END;

/
