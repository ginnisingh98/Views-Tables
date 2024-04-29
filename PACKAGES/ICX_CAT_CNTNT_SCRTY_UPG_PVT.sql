--------------------------------------------------------
--  DDL for Package ICX_CAT_CNTNT_SCRTY_UPG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_CAT_CNTNT_SCRTY_UPG_PVT" AUTHID CURRENT_USER AS
/* $Header: ICXVCSUS.pls 120.1 2006/08/30 08:11:24 huphan noship $*/

-- creating types on associative arrays gives incomplete types, so just
-- defining the types within this package

TYPE ICX_MAP_NUMBER IS TABLE OF NUMBER
  INDEX BY BINARY_INTEGER;

TYPE ICX_MAP_VARCHAR20 IS TABLE OF VARCHAR2(20)
  INDEX BY BINARY_INTEGER;

TYPE ICX_MAP_TBL_NUMBER IS TABLE OF ICX_TBL_NUMBER
  INDEX BY BINARY_INTEGER;


-- TOP-LEVEL MIGRATE METHOD AND HELPERS
---------------------------------------

PROCEDURE migrate;

FUNCTION is_already_run
RETURN BOOLEAN;

FUNCTION is_new_installation
RETURN BOOLEAN;


-- INITIALIZATION AND GLOBAL DATA
---------------------------------

PROCEDURE initialize;

PROCEDURE populate_global_data;


-- SEED-DATA RELATED HELPERS
----------------------------

-- NEW INSTALLATIONS

PROCEDURE add_main_store_content_link;

-- PRE-PROCESSING

PROCEDURE seed_data_preprocessing;

PROCEDURE add_smart_form_content_link;

FUNCTION exists_old_seeded_main_store
RETURN BOOLEAN;

PROCEDURE migrate_seeded_store
(
  p_old_id NUMBER,
  p_new_id NUMBER
);

PROCEDURE remove_R12_seeded_all_local;

PROCEDURE migrate_all_local_pre_1159;

-- POST-PROCESSING

PROCEDURE seed_data_postprocessing;

PROCEDURE promote_all_local_to_seeded;


-- HIGH-LEVEL MIGRATE METHODS
-----------------------------

FUNCTION try_migrate_catalogs_no_realms
RETURN BOOLEAN;

FUNCTION try_migrate_isrcs_no_realms
RETURN BOOLEAN;

PROCEDURE migrate_all_catalogs_no_realms;

PROCEDURE migrate_all_isrcs_no_realms;

PROCEDURE migrate_content_with_realms
(
  p_catalogs_migrated IN BOOLEAN,
  p_item_sources_migrated IN BOOLEAN
);

PROCEDURE migrate_templates;


-- MIGRATE LOCAL CATALOGS AND ITEM SOURCES HELPERS
--------------------------------------------------

PROCEDURE migrate_catalogs_no_realms
(
  p_catalog_ids IN ICX_TBL_NUMBER,
  p_old_store_ids IN ICX_TBL_NUMBER,
  p_new_zone_ids IN ICX_TBL_NUMBER
);

PROCEDURE migrate_catalog_with_realms
(
  p_catalog_id IN NUMBER,
  p_old_store_id IN NUMBER,
  p_resp_with_realms_ids IN ICX_TBL_NUMBER
);

PROCEDURE migrate_isrcs_no_realms
(
  p_item_source_ids IN ICX_TBL_NUMBER,
  p_old_store_ids IN ICX_TBL_NUMBER,
  p_new_zone_ids IN ICX_TBL_NUMBER
);

PROCEDURE migrate_isrc_with_realms
(
  p_item_source_id IN NUMBER,
  p_old_store_id IN NUMBER,
  p_resp_with_realms_ids IN ICX_TBL_NUMBER,
  p_resp_without_realms_ids IN ICX_TBL_NUMBER
);


-- QUERYING OLD DATA HELPERS
----------------------------

FUNCTION exists_local_catalogs
RETURN BOOLEAN;

FUNCTION exists_item_sources
RETURN BOOLEAN;

PROCEDURE get_contents_to_migrate
(
  p_catalogs_migrated IN BOOLEAN,
  p_item_sources_migrated IN BOOLEAN,
  x_old_content_ids OUT NOCOPY ICX_TBL_NUMBER,
  x_content_types OUT NOCOPY ICX_TBL_VARCHAR15,
  x_old_store_ids OUT NOCOPY ICX_TBL_NUMBER
);

PROCEDURE populate_store_security_flags;

PROCEDURE populate_catalog_supplr_flags;

PROCEDURE populate_operator_id_list;


-- R12 STORE HELPERS
--------------------

PROCEDURE create_R12_stores;

PROCEDURE add_zones_to_store
(
  p_zone_ids IN ICX_TBL_NUMBER,
  p_r12_store_id IN NUMBER,
  p_old_source_id IN NUMBER,
  p_old_store_id IN NUMBER
);

PROCEDURE add_zones_to_stores
(
  p_zone_ids IN ICX_TBL_NUMBER,
  p_r12_store_ids IN ICX_TBL_NUMBER,
  p_old_source_ids IN ICX_TBL_NUMBER,
  p_old_store_ids IN ICX_TBL_NUMBER
);

PROCEDURE add_smart_forms_to_stores
(
  p_smart_form_ids IN ICX_TBL_NUMBER,
  p_r12_store_ids IN ICX_TBL_NUMBER,
  p_old_store_ids IN ICX_TBL_NUMBER
);


-- CONTENT ZONE HELPERS
-----------------------

FUNCTION get_new_zone_ids
(
  p_num_zones IN NUMBER
)
RETURN ICX_TBL_NUMBER;

PROCEDURE create_local_zones
(
  p_new_zone_ids IN ICX_TBL_NUMBER,
  p_catalog_id IN NUMBER,
  p_security_flag IN VARCHAR2,
  p_supplier_flag IN VARCHAR2,
  p_category_flag IN VARCHAR2
);

PROCEDURE create_local_zones
(
  p_new_zone_ids IN ICX_TBL_NUMBER,
  p_catalog_ids IN ICX_TBL_NUMBER,
  p_security_flags IN ICX_TBL_VARCHAR20,
  p_supplier_flags IN ICX_TBL_VARCHAR20,
  p_category_flag IN VARCHAR2
);

PROCEDURE create_local_all_content_zones
(
  p_new_zone_ids IN ICX_TBL_NUMBER,
  p_category_flag IN VARCHAR2
);

PROCEDURE add_resp_categories_to_zone
(
  p_new_zone_ids IN ICX_TBL_NUMBER,
  p_resp_ids IN ICX_TBL_NUMBER
);

PROCEDURE create_item_source_zones
(
  p_new_zone_ids IN ICX_TBL_NUMBER,
  p_item_source_id IN NUMBER,
  p_security_flag IN VARCHAR2
);

PROCEDURE create_item_source_zones
(
  p_new_zone_ids IN ICX_TBL_NUMBER,
  p_item_source_ids IN ICX_TBL_NUMBER,
  p_security_flags IN ICX_TBL_VARCHAR20
);

PROCEDURE update_exchange_punchouts;


-- CONTENT ZONE SECURITY HELPERS
--------------------------------

PROCEDURE secure_zones_by_store_orgs
(
  p_new_zone_ids IN ICX_TBL_NUMBER,
  p_old_store_ids IN ICX_TBL_NUMBER,
  p_security_flags IN ICX_TBL_VARCHAR20
);

PROCEDURE secure_zones_by_resps
(
  p_new_zone_ids IN ICX_TBL_NUMBER,
  p_resp_ids IN ICX_TBL_NUMBER
);

PROCEDURE secure_zone_by_resps
(
  p_new_zone_id IN NUMBER,
  p_resp_ids IN ICX_TBL_NUMBER
);


-- RESPONSIBILITY AND REALMS HELPER METHODS
-------------------------------------------

PROCEDURE populate_isrcs_to_resp_map;

FUNCTION get_catr_realm_values_cached
(
  p_resp_id IN NUMBER
)
RETURN ICX_TBL_NUMBER;

FUNCTION filter_out_no_category_resps
(
  p_resp_with_realms_ids IN ICX_TBL_NUMBER
)
RETURN ICX_TBL_NUMBER;

FUNCTION get_realm_values_for_resp
(
  p_resp_id IN NUMBER,
  p_realm_type IN VARCHAR2
)
RETURN ICX_TBL_NUMBER;


-- LARGE RESPONSIBILITY WITH REALMS QUERIES
-------------------------------------------

FUNCTION get_all_resps_with_realms
(
  p_realm_type IN VARCHAR2
)
RETURN ICX_TBL_NUMBER;

FUNCTION get_all_resps_without_realms
(
  p_realm_type IN VARCHAR2
)
RETURN ICX_TBL_NUMBER;

FUNCTION get_resps_with_realms_store
(
  p_realm_type IN VARCHAR2,
  p_old_store_id IN NUMBER
)
RETURN ICX_TBL_NUMBER;

FUNCTION get_resps_without_realms_store
(
  p_realm_type IN VARCHAR2,
  p_old_store_id IN NUMBER
)
RETURN ICX_TBL_NUMBER;

END ICX_CAT_CNTNT_SCRTY_UPG_PVT;


 

/
