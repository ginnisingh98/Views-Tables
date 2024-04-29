--------------------------------------------------------
--  DDL for Package Body ICX_CAT_CNTNT_SCRTY_UPG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_CAT_CNTNT_SCRTY_UPG_PVT" AS
/* $Header: ICXVCSUB.pls 120.5.12000000.2 2007/01/29 22:50:52 huphan ship $*/

-- INFORMATION
--------------
--
-- The security assignment flag can be:
--   (1) ALL_USERS (when old store was secured by -2, all operating units)
--   (2) OU_SECURED (when old store was secured by some operating units)
--   (3) RESP_SECURED (in the case realms needs to be considered)
--
-- The content zone supplier flag can be:
--   (1) INCLUDE_ALL (for the base catalog)
--   (2) INCLUDE (some supplier restrictions)
--   (3) EXCLUDE_ALL (when only the w/o supplier checkbox is indicated)
--   (4) EXCLUDE (can't happen on upgrade as this was not allowed in 11.5.10)
--
-- The content zone category flag can be:
--   (1) INCLUDE_ALL (no realms)
--   (2) INCLUDE (for the case with realms)
--   (4) EXCLUDE (not used for upgrade, as not supported by realms in 11.5.10)
--
-- About Logging:  Since this is an upgrade script, by default, Exception
-- level logging will be enabled.  Hence, this script will mark out critical
-- data to the log with Exception Level even if there were no exceptional case
-- involved.


-- GLOBAL VARIABLES
-------------------

-- For logging purposes
g_pkg_name CONSTANT VARCHAR2(30) := 'ICX_CAT_CNTNT_SCRTY_UPG_PVT';

-- Stores the FND_PROFILE ID for ORG_ID (Operating Unit)
g_ou_profile_id NUMBER;

-- Stores the FND_PROFILE site-level value for ORG_ID (Operating Unit)
g_site_ou_profile_value NUMBER;

-- Stores the FND_PROFILE site-level value for POR_APPROVED_PRICING
g_site_approved_pricing VARCHAR2(1);

-- Map of old stores to new security assignment flag for content zones
g_store_security_flags ICX_MAP_VARCHAR20;

-- Map of local catalogs to their supplier attribute flag values
g_catalog_supplier_flags ICX_MAP_VARCHAR20;

-- Map of old store to new R12 store IDs
g_stores_map ICX_MAP_NUMBER;

-- Map of old exchange item source IDs to new content zone IDs;
-- required for upgraded downloaded punchouts from exchange
g_exchange_punchout_map ICX_MAP_NUMBER;

-- Map of item sources to responsibilties that can access them (realms)
g_item_sources_to_resp_map ICX_MAP_TBL_NUMBER;

-- Map of responsibilities to accessible categories (realms)
g_resp_to_categories_map ICX_MAP_TBL_NUMBER;

-- Indicates a pre-11.5.9 upgrade which requires special handling
g_is_pre_1159_upgrade BOOLEAN;

-- Determines if installation has any category realms
g_uses_category_realms BOOLEAN;

-- Determines if installation has any item source realms
g_uses_item_source_realms BOOLEAN;

-- List of all responsibilities with realms
g_resp_with_category_realms ICX_TBL_NUMBER;

-- List of all responsibilities without realms
g_resp_without_category_realms ICX_TBL_NUMBER;

-- List of all responsibilities with realms
g_resp_with_isrc_realms ICX_TBL_NUMBER;

-- List of all responsibilities without realms
g_resp_without_isrc_realms ICX_TBL_NUMBER;


-- TOP-LEVEL MIGRATE METHOD
---------------------------

-- The primary migrate method.  This is the starting point for the upgrade
-- script for content security.  The following outlines the high-level flow
-- of the method:
--
-- 1. Don't run the script if it's already been run.
-- 2. Add the default Smart Form link, as it's always required for seeding.
-- 3. In the new installation case, also add the link the Main Store.
-- 4. Handle the special-case with seeded data (both pre- and post-processing).
-- 5. Migrate stores by creating new R12 stores for all existing stores.
-- 6. Attempt to migrate local catalogs without category realms.
-- 7. Attempt to migrate item sources without item source realms.
-- 8. If realms needs to be considered for either local catalogs or
--    item sources, then migrate them with realms.
-- 9. Migrate non-catalog templates.
-- 10. Populate SQEs required for Catalog Search.
--
-- @return  High-level status to indicate success or failure.
--
PROCEDURE migrate
IS
  l_local_catalogs_migrated BOOLEAN;
  l_item_sources_migrated BOOLEAN;

  l_api_name CONSTANT VARCHAR2(30) := 'migrate';
  l_err_loc PLS_INTEGER;
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, 'Start');
  END IF;

  l_err_loc := 0;

  -- if this script has already run (should be re-runnable), then skip
  -- the rest of the script
  IF (is_already_run()) THEN
    RETURN;  -- no need to do further content security migration
  END IF;

  -- add the link between the default smart form and the Smart Form store
  add_smart_form_content_link();
  l_err_loc := 50;

  -- if this is a new installation, no actual migration from the old data
  -- model is needed;  instead, just add the link from the seeded "Main Store"
  -- to the seeded "All Local Content" as this is not handled by the .ldt
  IF (is_new_installation()) THEN

    add_main_store_content_link();
    l_err_loc := 50;

    RETURN;  -- no need to do further content security migration

  END IF;

  -- begin by initializing the packages' global variables
  initialize();
  l_err_loc := 100;

  -- start populating global data that is accessed often, but can be
  -- retrieved once from the database and saved to memory
  populate_global_data();
  l_err_loc := 200;

  -- special handing, migrate seed data
  seed_data_preprocessing();
  l_err_loc := 300;

  -- start by migrating the stores first;
  -- ALSO, this will populate the global map of old to new stores
  create_R12_stores();
  l_err_loc := 400;

  -- attempt to migrate all the local catalogs without the complications
  -- of realms;  if this cannot be done, defer to later
  l_local_catalogs_migrated := try_migrate_catalogs_no_realms();
  l_err_loc := 500;

  -- attempt to migrate all the item sources without the complications
  -- of realms;  if this cannot be done, defer to later
  l_item_sources_migrated := try_migrate_isrcs_no_realms();
  l_err_loc := 600;

  -- if either local catalogs or item sources have not been migrated (as
  -- they needed to consider realms), then migrate them now
  IF NOT (l_local_catalogs_migrated AND l_item_sources_migrated) THEN

    migrate_content_with_realms(l_local_catalogs_migrated,
                                l_item_sources_migrated);
    l_err_loc := 700;

  END IF;

  -- migrate the non-catalog templates
  migrate_templates();
  l_err_loc := 800;

  -- after finishing migration, handle any seed data processing post-upgrade
  seed_data_postprocessing();
  l_err_loc := 900;

  -- finally, populate corresponding SQEs for search
  ICX_CAT_SQE_PVT.sync_sqes_for_all_zones();
  l_err_loc := 1000;

  -- commit!
  commit;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name, 'End');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_CNTNT_SCRTY_UPG_PVT.migrate(' ||
     l_err_loc || '), ' || SQLERRM);

END migrate;


-- Determines if this script has already been run by checking to see if there
-- is any other content besides the seeded stores and content zones.
--
-- NOTE:  There is one small corner case where this method will return false
--        even if the migrate has been run.  This is when there are is ONLY
--        one local content (no other item sources) and no category realms
--        is used AND there is only one seeded store.  In this case, after
--        migration, only data that appears to be seeded will remain, seemly
--        like the migration has not been run.  However, the code will handle
--        this case in the regular code path by simply moving this one local
--        catalog and one store into R12 again.
--
FUNCTION is_already_run
RETURN BOOLEAN
IS
  exists_non_seeded_data NUMBER;
  l_err_loc PLS_INTEGER;
BEGIN

  l_err_loc := 0;

  BEGIN

    SELECT 1
    INTO exists_non_seeded_data
    FROM icx_cat_content_zones_b z, icx_cat_shop_stores_b s
    WHERE (z.zone_id NOT IN (1,2) OR s.store_id NOT IN (1,2))
      AND rownum = 1;
    l_err_loc := 100;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN

      -- just seeded data;  script has not been run
      exists_non_seeded_data := -1;
      l_err_loc := 200;

  END;

  -- log fact that script has already been run
  IF ((exists_non_seeded_data = 1) AND
      (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN

    FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
      ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, 'is_already_run'),
      'Detected that script already run.');

  END IF;

  RETURN (exists_non_seeded_data = 1);

EXCEPTION
  WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_CNTNT_SCRTY_UPG_PVT.is_already_run(' ||
     l_err_loc || '), ' || SQLERRM);

END is_already_run;


-- Determines if this is a new R12 installation (rather than an upgrade from
-- 11.5.10) by checking the existence of the 11.5.10's stores table.  There is
-- no direct migration from older versions, so 11.5.10 is a sufficient check.
--
FUNCTION is_new_installation
RETURN BOOLEAN
IS
  exists_catalogs_data NUMBER;
  l_icx_schema_name VARCHAR2(20);
  l_err_loc PLS_INTEGER;
BEGIN

  l_err_loc := 0;

  l_icx_schema_name := ICX_CAT_UTIL_PVT.getIcxSchemaName();
  l_err_loc := 100;

  BEGIN

    SELECT 1
    INTO exists_catalogs_data
    FROM all_objects
    WHERE owner = l_icx_schema_name
      AND object_name = 'ICX_POR_ITEM_SOURCES';
    l_err_loc := 200;

    SELECT 1
    INTO exists_catalogs_data
    FROM icx_por_item_sources
    WHERE rownum = 1;
    l_err_loc := 300;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN

      -- there's no item sources table or data
      exists_catalogs_data := -1;
      l_err_loc := 400;

  END;

  -- as far as content security upgrade is concerned, if there is no data
  -- (seeded or otherwise) in either catalogs table, then this is
  -- a "new installation," and nothing needs to be done
  IF ((exists_catalogs_data = -1) AND
      (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN

    FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
      ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, 'is_new_installation'),
      'Detected that this is a new R12 installation.');

  END IF;

  RETURN (exists_catalogs_data = -1);

EXCEPTION
  WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_CNTNT_SCRTY_UPG_PVT.is_new_installation(' ||
     l_err_loc || '), ' || SQLERRM);

END is_new_installation;


-- INITIALIZATION AND GLOBAL DATA
---------------------------------

-- Initializes the Global Variables.  This is required as they must be cleared
-- if the upgrade is re-run.
--
PROCEDURE initialize
IS
  l_api_name CONSTANT VARCHAR2(30) := 'initialize';
  l_err_loc PLS_INTEGER;
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, 'Start');
  END IF;

  l_err_loc := 0;

  -- defaults for numbers and strings
  g_ou_profile_id := -1;
  g_site_ou_profile_value := -1;
  g_site_approved_pricing := NULL;

  l_err_loc := 100;

  -- delete all elements from collections
  g_store_security_flags.DELETE;
  g_catalog_supplier_flags.DELETE;
  g_stores_map.DELETE;
  g_item_sources_to_resp_map.DELETE;
  g_resp_to_categories_map.DELETE;

  l_err_loc := 200;

  -- empty starting tables
  g_resp_with_category_realms := ICX_TBL_NUMBER();
  g_resp_without_category_realms := ICX_TBL_NUMBER();
  g_resp_with_isrc_realms := ICX_TBL_NUMBER();
  g_resp_without_isrc_realms := ICX_TBL_NUMBER();

  l_err_loc := 300;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name, 'End');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_CNTNT_SCRTY_UPG_PVT.initialize(' ||
     l_err_loc || '), ' || SQLERRM);

END initialize;


-- Populates any global data that is accessed frequently by querying the
-- database once, and starting this data for later.  Currently this includes:
--
-- 1. Map of old store IDs to the security assignment flag values that will
--    be stored on the new content zones.  See method for details.
--
-- 2. Map of old catalog IDs to the supplier attribute action flag values
--    that will be stored on the new content zones.  See method for details.
--
-- 3. List of all the item sources that require a map due to the parent_zone_id
--    concept when dealing with punchout catalogs downloaded from exchange.
--
-- 4. Populating the MO_OPERATING_UNIT profile ID and value for site
--
-- 5. Populating the POR_APPROVED_PRICING_ONLY profile value at SITE;
--    user level values cannot be migrated
--
PROCEDURE populate_global_data
IS
  l_api_name CONSTANT VARCHAR2(30) := 'populate_global_data';
  l_err_loc PLS_INTEGER;
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, 'Start');
  END IF;

  l_err_loc := 0;

  populate_store_security_flags();
  l_err_loc := 100;

  populate_catalog_supplr_flags();
  l_err_loc := 200;

  populate_operator_id_list();
  l_err_loc := 300;

  -- get the MO:Operating Unit profile ID and value at site level
  SELECT p.profile_option_id, v.profile_option_value
  INTO g_ou_profile_id, g_site_ou_profile_value
  FROM fnd_profile_options p, fnd_profile_option_values v
  WHERE p.profile_option_name = 'ORG_ID'
    AND p.profile_option_id = v.profile_option_id(+)
    AND p.application_id = v.application_id
    AND v.level_id(+) = 10001;
  l_err_loc := 400;

  -- get the POR:Approved Pricing Only profile value at site level
  SELECT nvl(v.profile_option_value, 'N')
  INTO g_site_approved_pricing
  FROM fnd_profile_options p, fnd_profile_option_values v
  WHERE p.application_id = 178
    AND p.profile_option_name = 'POR_APPROVED_PRICING_ONLY'
    AND p.profile_option_id = v.profile_option_id
    AND p.application_id = v.application_id
    AND v.level_id = 10001;
  l_err_loc := 500;

  IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
      ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
      'OU Profile ID='||g_ou_profile_id||', val(site)='||
        g_site_ou_profile_value||', Approved Pricing Profile val(site)='
        ||g_site_approved_pricing);
  END IF;
  l_err_loc := 600;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name, 'End');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_CNTNT_SCRTY_UPG_PVT.populate_global_data(' ||
     l_err_loc || '), ' || SQLERRM);

END populate_global_data;


-- SEED-DATA RELATED HELPERS
----------------------------

-- Adds the seeded "All Local Content" content zone to the seeded Main Store.
-- This is not handled by the .ldt which does just the data loading, so this
-- is done here for new installations.  For upgrades, this is handled via
-- the main content security upgrade code path.
--
PROCEDURE add_main_store_content_link
IS
  l_api_name CONSTANT VARCHAR2(30) := 'add_main_store_content_link';
  l_err_loc PLS_INTEGER;
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, 'Start');
  END IF;

  l_err_loc := 0;

  -- secure the seeded "All Local" content zone with the Main Store;
  -- this is not handled by the .ldt, so it's done here
  INSERT INTO icx_cat_store_contents
  (store_id, content_id, content_type, sequence, display_always_flag,
   created_by, creation_date, last_updated_by, last_update_date,
   last_update_login)
  SELECT 1, 1, 'CONTENT_ZONE', 1, NULL, fnd_global.user_id, sysdate,
         fnd_global.user_id, sysdate, fnd_global.login_id
  FROM dual;
  l_err_loc := 100;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name, 'End');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_CNTNT_SCRTY_UPG_PVT.add_main_store_content_link(' ||
     l_err_loc || '), ' || SQLERRM);

END add_main_store_content_link;


-- Adds the seeded default Smart Form to the seeded Non-Catalog Request tab.
-- This is not handled by the .ldt which does just the data loading, so this
-- is done here.
--
PROCEDURE add_smart_form_content_link
IS
  l_api_name CONSTANT VARCHAR2(30) := 'add_smart_form_content_link';
  l_err_loc PLS_INTEGER;
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, 'Start');
  END IF;

  l_err_loc := 0;

  INSERT INTO icx_cat_store_contents
  (store_id, content_id, content_type, sequence, display_always_flag,
   created_by, creation_date, last_updated_by, last_update_date,
   last_update_login)
  SELECT 2, 10000000, 'SMART_FORM', 1, 'N', fnd_global.user_id, sysdate,
         fnd_global.user_id, sysdate, fnd_global.login_id
  FROM dual;
  l_err_loc := 100;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name, 'End');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_CNTNT_SCRTY_UPG_PVT.add_smart_form_content_link(' ||
     l_err_loc || '), ' || SQLERRM);

END add_smart_form_content_link;


-- Migrates any values for seeded data in previous releases.  This handles
-- everything that can be done prior to processing the upgrade.  Additional
-- steps that can only occur after upgrade will be handled in postprocessing.
-- In preprocessing, steps will include:
--
-- 1. The Contractor Catalog -- copy translations over to the Contractor Zone.
--
-- 2. The Main Store (11.5.8 Migration) -- if there are no local catalogs
--    (which are seeded in 11.5.9 and 11.5.10 and cannot be deleted), then
--    this is a 11.5.8 migration to R12.
--
--    In this case, the upgrade is a bit complicated:
--    There is no Main Store, but the previous 11.5.9/11.5.10 upgrade script
--    will forcibly migrate any old 11.5.8 item sources and add the
--    relationship in icx_cat_store_catalogs to a "phantom" main store that
--    will not exist.  To properly complete this process, this script will
--    assume the new seeded R12 is the properly "migrated" store to which
--    the item sources will be moved over to content zones (as-is in the
--    rest of the script).
--
-- 3. The Main Store (11i) -- copy sequence and translations over to the seeded
--    R12 Main Store.  All catalogs and item sources will be migrated normally.
--    Delete the seeded store if the main store was previously deleted in 11i.
--
-- 4. The NonCatalog Store -- again, copy sequence and translations over to
--    the R12 Non-Catalog Store (subtab).  Templates will be migrated normally.
--
-- 5. No migration is needed for the default Smart Form, as it is identical
--    to the one seeded in 11i, except for the name change.  This name change
--    will not be reflected for customers upgrading as they will retain the
--    the old 11i name or whatever name they have used to rename it.
--
-- 6. "All Local Content" catalog in 11.5.10 will be migrated as any other
--    local catalog.  The only exception is that for the main store, this
--    catalog (if there exists a zone that has no supplier nor category
--    restrictions) will be promoted to it's seeded ID of 1.  In all cases
--    (except in new installations which has already been handled first), the
--    new R12 seeded content zone will be removed, as it is no longer relevant.
--
PROCEDURE seed_data_preprocessing
IS
  l_has_main_store NUMBER;
  l_api_name CONSTANT VARCHAR2(30) := 'seed_data_preprocessing';
  l_err_loc PLS_INTEGER;
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, 'Start');
  END IF;

  l_err_loc := 0;

  -- migrate translated values for contractor;  as nothing can be changed on
  -- the base table), the easiest way to do migrate is remove the seeded tl
  -- rows and replace them with the existing translated contractor rows.
  -- per .ldt file, contractor catalog was 10,000,001 in 11.5.10 and 2 in R12

  DELETE FROM icx_cat_content_zones_tl
  WHERE zone_id = 2
  AND EXISTS (SELECT 1
              FROM icx_por_item_sources_tl
              WHERE item_source_id = 10000001);
  l_err_loc := 100;

  INSERT INTO icx_cat_content_zones_tl
    (zone_id, language, source_lang, name, description,
     created_by, creation_date, last_updated_by, last_update_date,
     last_update_login)
  SELECT 2, language, source_lang, item_source_name, description,
         fnd_global.user_id, sysdate, fnd_global.user_id, sysdate,
         fnd_global.login_id
  FROM icx_por_item_sources_tl
  WHERE item_source_id = 10000001;
  l_err_loc := 200;

  -- check for the existence of local catalogs (meaning 11.5.9 and later)
  IF (exists_local_catalogs()) THEN

    g_is_pre_1159_upgrade := FALSE;

    -- migrate seeded main store (if exists) and non-catalog stores;
    -- if the main store does not exist, remove the newly seeded r12 one;
    IF (exists_old_seeded_main_store()) THEN

      -- per .ldt file, the main store ID was 0 in 11.5.10 and 1 in R12
      migrate_seeded_store(0, 1);
      l_err_loc := 300;

      -- add the relationship from old to new stores in the map so that any
      -- catalogs and item sources will be migrated properly
      g_stores_map(0) := 1;
      l_err_loc := 400;

    ELSE  -- main store does not exist in the 11.5.10 table

      -- the main store has been deleted in 11i, so delete the new seeded r12
      -- main store in this case (as it doesn't really make sense to add
      -- something the user didn't want before); the user can easily recreate
      -- a main store if desired.
      DELETE FROM icx_cat_shop_stores_b
      WHERE store_id = 1;
      l_err_loc := 600;

      DELETE FROM icx_cat_shop_stores_tl
      WHERE store_id = 1;
      l_err_loc := 700;

    END IF;

    -- functionally, for post 11.5.8 upgrade-scenarios, the seeded R12
    -- "All Local Content" zone should be removed;  it might be another
    -- appropriate zone is promoted later on (see postprocessing step)
    remove_R12_seeded_all_local();
    l_err_loc := 750;

  ELSE  -- this is now 11.5.8 or before migration, so the R12 main store
        -- assumes the position of the migrated main store

    g_is_pre_1159_upgrade := TRUE;

    -- add the relationship as if the old Main Store was migrated so that any
    -- 11.5.8 and prior item sources will be migrated properly
    g_stores_map(0) := 1;
    l_err_loc := 800;

    -- also store the security flag as 'ALL_USERS' by default for this case
    g_store_security_flags(0) := 'ALL_USERS';
    l_err_loc := 900;

    -- also, special-case handling of the "All Local Content"
    migrate_all_local_pre_1159();
    l_err_loc := 950;

  END IF;

  -- as the Non-Catalog store cannot be deleted in 11.5.10, no need to check
  -- if it exists like the Main Store;  just migrate it.
  -- per .ldt file, the NonCat Store ID was 10,000,000 in 11.5.10 and 2 in R12
  migrate_seeded_store(10000000, 2);
  l_err_loc := 1000;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name, 'End');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_CNTNT_SCRTY_UPG_PVT.seed_data_preprocessing(' ||
     l_err_loc || '), ' || SQLERRM);

END seed_data_preprocessing;


-- Determines if the old seeded main store still remains.
--
-- @return TRUE if so, FALSE if not
--
FUNCTION exists_old_seeded_main_store
RETURN BOOLEAN
IS
  l_has_main_store NUMBER;
  l_api_name CONSTANT VARCHAR2(30) := 'exists_old_seeded_main_store';
  l_err_loc PLS_INTEGER;
BEGIN

  l_err_loc := 0;

  BEGIN

    SELECT 1
    INTO l_has_main_store
    FROM icx_cat_stores_b
    WHERE store_id = 0;

    l_err_loc := 100;

  EXCEPTION
    WHEN no_data_found THEN
      l_has_main_store := -1;
      l_err_loc := 200;
  END;

  l_err_loc := 300;

    -- log status of the old seeded store pre-R12
  IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
      ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
      'The old seeded Main Store status (1=>EXISTS) = '||l_has_main_store);
  END IF;

  RETURN (l_has_main_store = 1);

EXCEPTION
  WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_CNTNT_SCRTY_UPG_PVT.exists_old_seeded_main_store('
     || l_err_loc || '), ' || SQLERRM);

END exists_old_seeded_main_store;


-- Migrates values for seeded stores from previous releases.  This includes
-- only the sequence number for the base table;  for the tl rows, first
-- all seeded rows are removed and updated with the existing old rows.
--
-- @param p_old_id The ID of the seeded store in 11.5.10.
-- @param p_new_id The ID of the seeded store in R12.
--
PROCEDURE migrate_seeded_store
(
  p_old_id NUMBER,
  p_new_id NUMBER
)
IS
  l_api_name CONSTANT VARCHAR2(30) := 'migrate_seeded_store';
  l_err_loc PLS_INTEGER;
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name,
      'p_old_id='||p_old_id||';p_new_id='||p_new_id);
  END IF;

  l_err_loc := 0;

  UPDATE icx_cat_shop_stores_b
  SET sequence =
    (SELECT sequence_number FROM icx_cat_stores_b
     WHERE store_id = p_old_id)
  WHERE store_id = p_new_id;
  l_err_loc := 100;

  DELETE FROM icx_cat_shop_stores_tl
  WHERE store_id = p_new_id
    AND EXISTS (SELECT 1 FROM icx_cat_stores_tl WHERE store_id = p_old_id);
  l_err_loc := 200;

  INSERT INTO icx_cat_shop_stores_tl
    (store_id, language, source_lang, name, description, long_description,
     image, created_by, creation_date, last_updated_by, last_update_date,
     last_update_login)
  SELECT p_new_id, language, source_lang, store_name,
         short_description, long_description, image_location,
         fnd_global.user_id, sysdate, fnd_global.user_id, sysdate,
         fnd_global.login_id
  FROM icx_cat_stores_tl
  WHERE store_id = p_old_id;
  l_err_loc := 300;

  -- add the relationship to the stores map
  g_stores_map(p_old_id) := p_new_id;
  l_err_loc := 400;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name, 'End');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_CNTNT_SCRTY_UPG_PVT.migrate_seeded_store(' ||
     l_err_loc || '), ' || SQLERRM);

END migrate_seeded_store;


-- Removes the "All Local Content" that was seeded in R12 because there were
-- "All Local Content" catalogs in 11.5.10 that were migrated to R12.
--
PROCEDURE remove_R12_seeded_all_local
IS
  l_api_name CONSTANT VARCHAR2(30) := 'remove_R12_seeded_all_local';
  l_err_loc PLS_INTEGER;
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, 'Start');
  END IF;

  l_err_loc := 0;

  -- remove the R12 seeded zone data
  DELETE FROM icx_cat_content_zones_b
  WHERE zone_id = 1;
  l_err_loc := 100;

  DELETE FROM icx_cat_content_zones_tl
  WHERE zone_id = 1;
  l_err_loc := 200;

  -- there are nothing seeded into icx_cat_secure_contents for the seeded
  -- content zone, so nothing to handle in that table

  -- remove all links to stores, if any
  DELETE FROM icx_cat_store_contents
  WHERE content_id = 1;
  l_err_loc := 300;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name, 'End');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_CNTNT_SCRTY_UPG_PVT.remove_R12_seeded_all_local('
     || l_err_loc || '), ' || SQLERRM);

END remove_R12_seeded_all_local;


-- For pre-11.5.9 upgrades, the "All Local Content" catalog must be handled
-- specially, as it is not seeded during R12.  The seeded R12 "All Local
-- Content" is kept, but must be duplicated with realms, if needed.
--
PROCEDURE migrate_all_local_pre_1159
IS
  l_api_name CONSTANT VARCHAR2(30) := 'migrate_all_local_pre_1159';
  l_err_loc PLS_INTEGER;
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, 'Start');
  END IF;

  l_err_loc := 0;

  -- determine all the responsibilities with category realms
  g_resp_with_category_realms := get_all_resps_with_realms('RT_CATEGORY_ID');
  l_err_loc := 100;

  -- in the case with no realms, the newly seeded R12 "All Local Content"
  -- can be used, and nothing is done here
  IF (g_resp_with_category_realms.COUNT = 0) THEN

    -- nothing needs to be migrated, but the link must be added to the
    -- new main store, as if this were a new installation
    add_main_store_content_link();
    l_err_loc := 150;

    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Pre-11.5.9 upgrade found no Category Realms being used.');
    END IF;

    l_err_loc := 200;

  ELSE  -- populate all responsibilties without realms as this will be
        -- needed to migrate local catalogs with realms consideration

    g_resp_without_category_realms :=
      get_all_resps_without_realms('RT_CATEGORY_ID');
    l_err_loc := 300;

    -- consider realms, and migrate the "All Local Content"
    migrate_catalog_with_realms(0, 0, g_resp_with_category_realms);
    l_err_loc := 400;

    -- after this, safely remove the "original" one as it as been migrated
    -- with realms properly
    remove_R12_seeded_all_local();
    l_err_loc := 500;

  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name, 'End');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_CNTNT_SCRTY_UPG_PVT.migrate_all_local_pre_1159('
     || l_err_loc || '), ' || SQLERRM);

END migrate_all_local_pre_1159;


-- Handles seed data processing that requires the upgrade to happen first.
-- Currently, this involves only one step -- promoting a migrated
-- "All Local Content" catalog to the seeded zone of ID 1 if it is
-- substantially "identical" to the R12 seeded one found in the Main Store.
-- "Identical" here means there are no catalog or supplier restrictions
-- for the migrated zone.
--
PROCEDURE seed_data_postprocessing
IS
  l_api_name CONSTANT VARCHAR2(30) := 'seed_data_postprocessing';
  l_err_loc PLS_INTEGER;
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, 'Start');
  END IF;

  l_err_loc := 0;

  -- promote an existing zone to the "All Local Content" seeded zone if
  -- the "All Local Content" catalog was migrated from 11.5.10;
  -- this method will do nothing in the case there is no suitable
  -- content zone to promote to the "seeded" one
  promote_all_local_to_seeded();
  l_err_loc := 100;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name, 'End');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_CNTNT_SCRTY_UPG_PVT.seed_data_postprocessing(' ||
     l_err_loc || '), ' || SQLERRM);

END seed_data_postprocessing;


-- Promotes the migrated "All Local Content" content zone from the main store
-- to "seeded" status by switching the IDs, if one exists that also has no
-- category restrictions (as in the "All Local Content" catalog).
-- If there is no qualifying content, then this method does a noop.
--
PROCEDURE promote_all_local_to_seeded
IS
  l_promoted_zone_id NUMBER;
  l_api_name CONSTANT VARCHAR2(30) := 'promote_all_local_to_seeded';
  l_err_loc PLS_INTEGER;
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, 'Start');
  END IF;

  l_err_loc := 0;

  -- promote the content zone to "seeded" only if it's in the main store
  -- and is not secured by any category (realms)
  BEGIN

    SELECT zone_id
    INTO l_promoted_zone_id
    FROM icx_cat_content_zones_b z, icx_cat_store_contents c
    WHERE z.supplier_attribute_action_flag = 'INCLUDE_ALL'
      AND z.category_attribute_action_flag = 'INCLUDE_ALL'
      AND z.zone_id = c.content_id
      AND c.store_id = 1;
    l_err_loc := 100;

    -- update the promoted zone to zone ID = 1 (seeded ID)
    UPDATE icx_cat_content_zones_b
    SET zone_id = 1
    WHERE zone_id = l_promoted_zone_id;
    l_err_loc := 200;

    UPDATE icx_cat_content_zones_tl
    SET zone_id = 1
    WHERE zone_id = l_promoted_zone_id;
    l_err_loc := 300;

    UPDATE icx_cat_secure_contents
    SET content_id = 1
    WHERE content_id = l_promoted_zone_id;
    l_err_loc := 400;

    -- update the store-contents association by deleting the old one, and
    -- replacing the new one with the new seeded ID of 1 (as there may
    -- be other valuable information saved in this relationship row that
    -- should be saved, for instance, sequence).
    UPDATE icx_cat_store_contents
    SET content_id = 1
    WHERE content_id = l_promoted_zone_id;
    l_err_loc := 500;

  EXCEPTION
    WHEN no_data_found THEN

    NULL; -- nothing needs to be done
    l_err_loc := 600;

    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Did not find an All Local Content to migrate to seeded status.');
    END IF;

  END;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name, 'End');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_CNTNT_SCRTY_UPG_PVT.promote_all_local_to_seeded('
     || l_err_loc || '), ' || SQLERRM);

END promote_all_local_to_seeded;


-- HIGH-LEVEL MIGRATE METHODS
-----------------------------

-- Attempts to migrate all local catalogs without category realms.  This
-- migration is sucessfully only in the case where there are no responsibilties
-- with category realms on the installation, or of course, when there are
-- no local catalogs to migrate in the first place.  In the former, all
-- local catalogs are migrated without category realms and TRUE is returned.
-- Otherwise, FALSE is returned if category realms must be considered.
--
-- @return  TRUE if local catalogs were sucessfully migrated, FALSE if realms
--          must be considered (so this is deferred until a later method).
--
FUNCTION try_migrate_catalogs_no_realms
RETURN BOOLEAN
IS
  l_local_catalogs_migrated BOOLEAN;
  l_api_name CONSTANT VARCHAR2(30) := 'try_migrate_catalogs_no_realms';
  l_err_loc PLS_INTEGER;
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, 'Start');
  END IF;

  l_err_loc := 0;
  l_local_catalogs_migrated := FALSE;

  IF (exists_local_catalogs()) THEN

    g_resp_with_category_realms := get_all_resps_with_realms('RT_CATEGORY_ID');
    l_err_loc := 100;

    -- proceed with the "no realms" migration if there are no responsibilities
    -- with category realms (that is, the count is 0)
    IF (g_resp_with_category_realms.COUNT = 0) THEN

      migrate_all_catalogs_no_realms();
      l_err_loc := 200;

      l_local_catalogs_migrated := TRUE;

    ELSE  -- populate all responsibilties without realms as this will be
          -- needed to migrate local catalogs with realms consideration

      g_resp_without_category_realms :=
        get_all_resps_without_realms('RT_CATEGORY_ID');
      l_err_loc := 300;

    END IF;

  ELSE -- no local catalogs to migrate

    l_local_catalogs_migrated := TRUE;
    l_err_loc := 400;

  END IF;

  l_err_loc := 500;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    IF (l_local_catalogs_migrated) THEN
      ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name,
        'Local Catalogs MIGRATED successfully.');
    ELSE
      ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name,
        'Local Catalogs have NOT been migrated.');
    END IF;
  END IF;

  RETURN l_local_catalogs_migrated;

EXCEPTION
  WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_CNTNT_SCRTY_UPG_PVT.try_migrate_catalogs_no_realms('
     || l_err_loc || '), ' || SQLERRM);

END try_migrate_catalogs_no_realms;


-- Attempts to migrate all item sources without item source realms.  This
-- migration is sucessfully only in the case where there are no responsibilties
-- with item source realms on the installation, or of course, when there are
-- no item sources to migrate in the first place.  In the former, all
-- item sources are migrated without item source realms and TRUE is returned.
-- Otherwise, FALSE is returned if item source realms must be considered.
--
-- @return  TRUE if item sources were sucessfully migrated, FALSE if realms
--          must be considered (so this is deferred until a later method).
--
FUNCTION try_migrate_isrcs_no_realms
RETURN BOOLEAN
IS
  l_item_sources_migrated BOOLEAN;
  l_api_name CONSTANT VARCHAR2(30) := 'try_migrate_isrcs_no_realms';
  l_err_loc PLS_INTEGER;
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, 'Start');
  END IF;

  l_err_loc := 0;
  l_item_sources_migrated := FALSE;

  IF (exists_item_sources()) THEN

    g_resp_with_isrc_realms :=
      get_all_resps_with_realms('ICX_POR_ITEM_SOURCE_ID');
    l_err_loc := 100;

    -- again, only if there are no responsibilities with item sources realms,
    -- then proceed with the migration without consideration to realms
    IF (g_resp_with_isrc_realms.COUNT = 0) THEN

      migrate_all_isrcs_no_realms();
      l_err_loc := 200;

      l_item_sources_migrated := TRUE;

    ELSE  -- the responsibilties without item source realms AND
          -- a mapping of item sources to which responsibilties can
          -- access them via their realms MUST BE POPULATED

      g_resp_without_isrc_realms :=
        get_all_resps_without_realms('ICX_POR_ITEM_SOURCE_ID');
      l_err_loc := 300;

      populate_isrcs_to_resp_map();
      l_err_loc := 400;

    END IF;

  ELSE -- no item sources to migrate

    l_item_sources_migrated := TRUE;
    l_err_loc := 500;

  END IF;

  l_err_loc := 600;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    IF (l_item_sources_migrated) THEN
      ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name,
        'Item Sources MIGRATED successfully.');
    ELSE
      ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name,
        'Item Sources have NOT been migrated.');
    END IF;
  END IF;

  RETURN l_item_sources_migrated;

EXCEPTION
  WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_CNTNT_SCRTY_UPG_PVT.try_migrate_isrcs_no_realms('
     || l_err_loc || '), ' || SQLERRM);

END try_migrate_isrcs_no_realms;


-- Migrates all local catalogs within the customer installation when
-- category realms do not need to be considered.  All catalogs, their
-- corresponding stores, and a new content zone sequence number are
-- selected and then passed to a migrate catalogs helper method.
--
PROCEDURE migrate_all_catalogs_no_realms
IS
  l_catalog_ids ICX_TBL_NUMBER;
  l_store_ids ICX_TBL_NUMBER;
  l_new_zone_ids ICX_TBL_NUMBER;

  l_api_name CONSTANT VARCHAR2(30) := 'migrate_all_catalogs_no_realms';
  l_err_loc PLS_INTEGER;
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, 'Start');
  END IF;

  l_err_loc := 0;

  SELECT sources.item_source_id, sc.store_id, ICX_CAT_CONTENT_ZONES_S.NEXTVAL
  BULK COLLECT INTO l_catalog_ids, l_store_ids, l_new_zone_ids
  FROM icx_por_item_sources sources, icx_cat_store_catalogs sc
  WHERE sources.type = 'LOCAL'
    AND sources.item_source_id = sc.item_source_id(+);
  l_err_loc := 100;

  migrate_catalogs_no_realms(l_catalog_ids, l_store_ids, l_new_zone_ids);
  l_err_loc := 200;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name, 'End');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_CNTNT_SCRTY_UPG_PVT.migrate_all_catalogs_no_realms('
     || l_err_loc || '), ' || SQLERRM);

END migrate_all_catalogs_no_realms;


-- Migrates all item sources within the customer installation when
-- item source realms do not need to be considered.  All item sources,
-- their corresponding stores, and a new content zone sequence number
-- are selected and then passed to a migrate item sources helper method.
-- The contractor item source is ignored, as it's a seeded element that's
-- handled separately.
--
PROCEDURE migrate_all_isrcs_no_realms
IS
  l_item_source_ids ICX_TBL_NUMBER;
  l_store_ids ICX_TBL_NUMBER;
  l_new_zone_ids ICX_TBL_NUMBER;

  l_api_name CONSTANT VARCHAR2(30) := 'migrate_all_isrcs_no_realms';
  l_err_loc PLS_INTEGER;
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, 'Start');
  END IF;

  l_err_loc := 0;

  SELECT sources.item_source_id, sc.store_id, ICX_CAT_CONTENT_ZONES_S.NEXTVAL
  BULK COLLECT INTO l_item_source_ids, l_store_ids, l_new_zone_ids
  FROM icx_por_item_sources sources, icx_cat_store_catalogs sc
  WHERE sources.type IN ('EXTERNAL', 'DISTSRCH', 'INFO')
    AND sources.item_source_id = sc.item_source_id(+);
  l_err_loc := 100;

  migrate_isrcs_no_realms(l_item_source_ids, l_store_ids, l_new_zone_ids);
  l_err_loc := 200;

  -- after all item sources have been migrated, update any downloaded
  -- punchouts from exchange (post-processing)
  update_exchange_punchouts();
  l_err_loc := 300;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name, 'End');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_CNTNT_SCRTY_UPG_PVT.migrate_all_isrcs_no_realms('
     || l_err_loc || '), ' || SQLERRM);

END migrate_all_isrcs_no_realms;


-- In the case where either category realms or item source realms (or both)
-- need to be considered for migration, this wrapper method is called to
-- oversee the migration.  This method will check for category realms
-- and item source realms when migrating local catalogs and item sources,
-- respectively.
--
-- This method is fairly complicated, but the process is broken down as follows:
--
-- (1) Determine all the content that needs to be migrated (this may include
--     local catalogs, item sources, or both -- depending on what had already
--     been migrated without regards to realms).
--
-- (2) This content list is returned ordered by the store (including the
--     possibility of NULL for content not included in a store).
--
-- (3) For each LOCAL content, determine if there are any responsibilties
--     with category realms that must be considered.  If there aren't any,
--     then this local catalog can be migrated as if there were no realms
--     to consider.  This is not done immediately, but keep track of in
--     a list that will migrated all at once (not unlike what is done if
--     there were no responsibilities with category realms in the entire
--     customer installation).
--
-- (4) If there are responsibilties with realms for this store (if this
--     store is assigned to -2 or is NULL, then all responsibilties with
--     category realms are considered in its place), then this local
--     catalog will be migrated considering realms.  This may be complicated
--     so this is done immediately.
--
-- (5) Correspondingly, for each ITEM SOURCE (Info, Punchout, or Transparent
--     Punchout) content, determine if there any responsibilities with
--     item source realms that can access the old store this content belonged
--     to.  If there are none, then, like local catalogs, a running list
--     is kept of item sources that can be migrated without considering
--     item source realms.  They are migrated all at once in the end.
--
-- (6) If there are responsibilties with item source realms for this store
--     (using the same formula as the local catalogs when the store is
--     assigned -2 or is NULL), then we will migrate this item source
--     considering realms immediately.
--
-- (7) Lastly, check our running lists of catalogs or item sources that
--     can be migrated without consideration of realms.  If any do exist,
--     migrate them in batch now.
--
PROCEDURE migrate_content_with_realms
(
  p_catalogs_migrated IN BOOLEAN,
  p_item_sources_migrated IN BOOLEAN
)
IS
  -- stores all the component content data parts which to migrate
  l_old_content_ids ICX_TBL_NUMBER;
  l_content_types ICX_TBL_VARCHAR15;
  l_old_store_ids ICX_TBL_NUMBER;
  l_new_zone_ids ICX_TBL_NUMBER;

  -- keeps track of the store the following list of responsilbities with and
  -- without realms are valid for;  will only query once per store to help
  -- performance (realms queries are quite large)
  l_isrc_realms_list_for_store NUMBER;
  l_resp_with_catr_realms ICX_TBL_NUMBER;
  l_resp_with_isrc_realms ICX_TBL_NUMBER;
  l_resp_without_isrc_realms ICX_TBL_NUMBER;

  -- keeps track of all the catalogs and item sources that can be migrated
  -- without realms consideration (they are all migrated in bulk)
  l_catalog_no_catr_realms_ids ICX_TBL_NUMBER;
  l_store_no_catr_realms_ids ICX_TBL_NUMBER;
  l_isrc_no_isrc_realms_ids ICX_TBL_NUMBER;
  l_store_no_isrc_realms_ids ICX_TBL_NUMBER;

  l_api_name CONSTANT VARCHAR2(30) := 'migrate_content_with_realms';
  l_err_loc PLS_INTEGER;

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, 'Start');
  END IF;

  l_err_loc := 0;

  -- depending on what's already been migrated, retrieves whatever
  -- left needs to be migrated while considering realms
  get_contents_to_migrate(p_catalogs_migrated, p_item_sources_migrated,
                          l_old_content_ids, l_content_types, l_old_store_ids);
  l_err_loc := 100;

  -- now, initialize the tables that keep track of any local catalogs or
  -- item sources that may still be migrated without regard to realms
  l_catalog_no_catr_realms_ids := ICX_TBL_NUMBER();
  l_store_no_catr_realms_ids := ICX_TBL_NUMBER();
  l_isrc_no_isrc_realms_ids := ICX_TBL_NUMBER();
  l_store_no_isrc_realms_ids := ICX_TBL_NUMBER();

  l_err_loc := 200;

  -- keep track of the current store (get_contents_to_migrate will return
  -- local catalogs/item sources to migrate ORDERED BY store);  this is used
  -- to minimize calls to the large queries to find responsibilties with
  -- or without item source realms that can access any given store;  NOTE,
  -- this doesn't help with category realms as there is only one local
  -- catalog per store anyways
  l_isrc_realms_list_for_store := -999;

  -- loop through all catalogs and/or item sources to migrate
  FOR i IN 1..l_old_content_ids.COUNT LOOP

    IF (l_content_types(i) = 'LOCAL') THEN

      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'Processing Local Catalog ... '||l_old_content_ids(i)||
          ' for Store '||l_old_store_ids(i)||' (is NULL if empty).');
      END IF;

      -- for local catalogs, determine if there any responsibilities with
      -- category realms that can access this store
      l_resp_with_catr_realms :=
        get_resps_with_realms_store('RT_CATEGORY_ID', l_old_store_ids(i));
      l_err_loc := 300;

      -- if there are none, then we can migrate this local catalog without
      -- consideration of category realms;  we simply keep a running list
      -- here and will migrate all of them at the end
      IF (l_resp_with_catr_realms.COUNT = 0) THEN

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Local Catalog can be migrated WITHOUT realms.');
        END IF;

        l_catalog_no_catr_realms_ids.extend;
        l_catalog_no_catr_realms_ids(l_catalog_no_catr_realms_ids.COUNT) :=
          l_old_content_ids(i);

        l_store_no_catr_realms_ids.extend;
        l_store_no_catr_realms_ids(l_store_no_catr_realms_ids.COUNT) :=
          l_old_store_ids(i);

        l_err_loc := 400;

      ELSE -- there are responsibilities with realms that can access this store

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Local Catalog MUST be migrated WITH realms.');
        END IF;

        -- migrate this individual local catalog with realms consideration
        migrate_catalog_with_realms(l_old_content_ids(i),
                                    l_old_store_ids(i),
                                    l_resp_with_catr_realms);
        l_err_loc := 500;

      END IF;  -- (l_resp_with_catr_realms.COUNT = 0)

    ELSE  -- for item sources (l_content_types(i) <> 'LOCAL')

      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'Processing Item Source ... '||l_old_content_ids(i)||
          ' for Store '||l_old_store_ids(i)||' (is NULL if empty).');
      END IF;

      -- check to see if the list of realms already queried is still
      -- valid for this store (that is, we haven't changed stores yet)
      IF ((l_old_store_ids(i) IS NULL AND l_isrc_realms_list_for_store IS NULL)
          OR (l_old_store_ids(i) = l_isrc_realms_list_for_store)) THEN

        -- it's ok to keep our cached lists;  this is done in the REVERSE
        -- way because the other condition requires three conditions:
        -- (1) old store is NULL and list store is NOT NULL
        -- (2) old store is NOT NULL and list store IS NULL
        -- (3) they don't match
        -- PL/SQL has screwed up ideas of equalities with NULL
        NULL;

        l_err_loc := 550;

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Processing Item Source ... same store, no need to re-query.');
        END IF;

      ELSE

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Processing Item Source ... a new store, MUST re-query.');
        END IF;

        l_err_loc := 600;

        -- query up the realms and without realms list (can be reused),
        -- also, set the tracking variable
        l_resp_with_isrc_realms :=
          get_resps_with_realms_store('ICX_POR_ITEM_SOURCE_ID',
                                      l_old_store_ids(i));
        l_err_loc := 700;

        l_resp_without_isrc_realms :=
          get_resps_without_realms_store('ICX_POR_ITEM_SOURCE_ID',
                                         l_old_store_ids(i));
        l_err_loc := 800;

        l_isrc_realms_list_for_store := l_old_store_ids(i);

       END IF;

       -- like local catalogs, check if realms needs to be considered;
       -- if so, tack them to a running list, otherwise, migrate this
       -- one item source with item source realms consideration
       IF (l_resp_with_isrc_realms.COUNT = 0) THEN

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Item Source can be migrated WITHOUT realms.');
        END IF;

         l_isrc_no_isrc_realms_ids.extend;
         l_isrc_no_isrc_realms_ids(l_isrc_no_isrc_realms_ids.COUNT) :=
           l_old_content_ids(i);

         l_store_no_isrc_realms_ids.extend;
         l_store_no_isrc_realms_ids(l_store_no_isrc_realms_ids.COUNT) :=
           l_old_store_ids(i);

         l_err_loc := 900;

       ELSE -- there are responsibilities with realms that can access this store

         IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
             ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
             'Item Source MUST be migrated WITH realms.');
         END IF;

         migrate_isrc_with_realms(l_old_content_ids(i), l_old_store_ids(i),
                                  l_resp_with_isrc_realms,
                                  l_resp_without_isrc_realms);

         l_err_loc := 1000;

       END IF; -- (l_resp_with_isrc_realms.COUNT = 0)

     END IF; -- check for content type

  END LOOP;

  -- at this point, migrate any local catalogs that are not affected
  -- by category realms, if any
  IF (l_catalog_no_catr_realms_ids.COUNT > 0) THEN

    l_new_zone_ids := get_new_zone_ids(l_catalog_no_catr_realms_ids.COUNT);

    migrate_catalogs_no_realms(l_catalog_no_catr_realms_ids,
                               l_store_no_catr_realms_ids,
                               l_new_zone_ids);
    l_err_loc := 1100;

  ELSE  -- skip and log

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Found no Local Catalogs that were migrate-able WITHOUT realms.');
    END IF;

  END IF;

  -- similarily, migrate any item sources that are not affected
  -- by item source realms, if any
  IF (l_isrc_no_isrc_realms_ids.COUNT > 0) THEN

    l_new_zone_ids := get_new_zone_ids(l_isrc_no_isrc_realms_ids.COUNT);

    migrate_isrcs_no_realms(l_isrc_no_isrc_realms_ids,
                            l_store_no_isrc_realms_ids,
                            l_new_zone_ids);
    l_err_loc := 1200;

  ELSE  -- skip and log

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Found no Item Sources that were migrate-able WITHOUT realms.');
    END IF;

  END IF;

  -- after all contents have been migrated, update any downloaded
  -- punchouts from exchange (post-processing)
  update_exchange_punchouts();
  l_err_loc := 1300;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name, 'End');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_CNTNT_SCRTY_UPG_PVT.migrate_content_with_realms('
     || l_err_loc || '), ' || SQLERRM);

END migrate_content_with_realms;


-- MIGRATE LOCAL CATALOGS AND ITEM SOURCES HELPERS
--------------------------------------------------

-- Migrates all given local catalogs when category realms do not need to
-- be considered for these content.  This happens when the responsibilities
-- that can access these catalogs themselves do not have category realms.
-- This method is also used in the general case where category realms is
-- not used on the customer installation.
--
-- @param p_catalog_ids The list of local catalogs to migrate.
-- @param p_old_store_ids The list of corresponding old stores that the
--                        local catalogs belonged to.
-- @param p_new_zone_ids The list of new content zone sequence numbers to
--                       be used when migrating these local catalogs.
--
PROCEDURE migrate_catalogs_no_realms
(
  p_catalog_ids IN ICX_TBL_NUMBER,
  p_old_store_ids IN ICX_TBL_NUMBER,
  p_new_zone_ids IN ICX_TBL_NUMBER
)
IS
  l_security_flags ICX_TBL_VARCHAR20;
  l_supplier_flags ICX_TBL_VARCHAR20;
  l_r12_store_ids ICX_TBL_NUMBER;

  l_api_name CONSTANT VARCHAR2(30) := 'migrate_catalogs_no_realms';
  l_err_loc PLS_INTEGER;
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, 'Start');
  END IF;

  l_err_loc := 0;

  -- create a corresponding list for each of the flags/ids needed
  l_security_flags := ICX_TBL_VARCHAR20();
  l_security_flags.extend(p_old_store_ids.COUNT);

  l_supplier_flags := ICX_TBL_VARCHAR20();
  l_supplier_flags.extend(p_old_store_ids.COUNT);

  l_r12_store_ids := ICX_TBL_NUMBER();
  l_r12_store_ids.extend(p_old_store_ids.COUNT);

  l_err_loc := 100;

  FOR i IN 1..p_old_store_ids.COUNT LOOP

    l_supplier_flags(i) := g_catalog_supplier_flags(p_catalog_ids(i));
    l_err_loc := 200;

    -- if the catalog does not belong to any store, keep NULL for the new store;
    -- also, security will default to ALL_USERS, as there are no restrictions
    -- on this non-existent store
    IF (p_old_store_ids(i) IS NULL) THEN

      l_r12_store_ids(i) := NULL;
      l_security_flags(i) := 'ALL_USERS';
      l_err_loc := 300;

    ELSE

      l_r12_store_ids(i) := g_stores_map(p_old_store_ids(i));
      l_security_flags(i) := g_store_security_flags(p_old_store_ids(i));
      l_err_loc := 400;

    END IF;

  END LOOP;

  -- once the list for new stores and security flags have been set, then
  -- create all the new zones, secure them by the corresponding store
  -- operating unit restrictions, and add the newly created zones to their
  -- corresponding stores
  create_local_zones(p_new_zone_ids, p_catalog_ids, l_security_flags,
                     l_supplier_flags, 'INCLUDE_ALL');
  l_err_loc := 500;

  secure_zones_by_store_orgs(p_new_zone_ids, p_old_store_ids, l_security_flags);
  l_err_loc := 600;

  add_zones_to_stores(p_new_zone_ids, l_r12_store_ids,
                      p_catalog_ids, p_old_store_ids);
  l_err_loc := 700;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name, 'End');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_CNTNT_SCRTY_UPG_PVT.migrate_catalogs_no_realms(' ||
     l_err_loc || '), ' || SQLERRM);

END migrate_catalogs_no_realms;


-- Migrates the one given local catalog with consideration to realms.
-- Unlike the no realms case, this method will handle only one catalog at
-- a time, to minimize complexity.  The process is broken down as follows:
--
-- (1) Eliminate any responsibililties with category realms that do not
--     actually have any realms values attached to them.
--
-- (2) If there are any responsibilities left, create a copy of the local
--     catalog for each.  Then add the category restrictions that are
--     particular to each responsibility.  Lastly, secure this content zone
--     by that particular responsibility.
--
-- (3) For all responsibilities WITHOUT category realms that can access
--     this store (if any), create another copy of the local content.
--     This copy will not be restricted by categories.  Secure this by
--     all such responsibilities without category realms.
--
-- @param p_catalog_id The local catalog to migrate.
-- @param p_old_store_id The corresponding old store of the local catalog.
-- @param p_resp_with_realms_ids The responsibilities with catalog realms
--                               that can access the old store.
--
PROCEDURE migrate_catalog_with_realms
(
  p_catalog_id IN NUMBER,
  p_old_store_id IN NUMBER,
  p_resp_with_realms_ids IN ICX_TBL_NUMBER
)
IS
  l_new_zone_ids ICX_TBL_NUMBER;
  l_resp_with_realm_values_ids ICX_TBL_NUMBER;
  l_resp_without_realms_ids ICX_TBL_NUMBER;

  l_api_name CONSTANT VARCHAR2(30) := 'migrate_catalog_with_realms';
  l_err_loc PLS_INTEGER;
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, 'Start');
  END IF;

  l_err_loc := 0;

  -- first filter out any responsibilities that do not have any category
  -- realm values;  no content zones will be created for them, as they
  -- cannot access any categories by definition of realms
  l_resp_with_realm_values_ids :=
    filter_out_no_category_resps(p_resp_with_realms_ids);
  l_err_loc := 100;

  -- if there any responsibilities left, migrate and secure by them
  IF (l_resp_with_realm_values_ids.COUNT > 0) THEN

    -- create one for each responsibility with category realm values
    l_new_zone_ids := get_new_zone_ids(l_resp_with_realm_values_ids.COUNT);
    l_err_loc := 200;

    -- for each, create a corresponding local zone;
    -- for pre 11.5.9 upgrade, the content zone must be created specially
    -- from the new seeded R12 "All Local Content" zone
    IF (g_is_pre_1159_upgrade) THEN

      create_local_all_content_zones(l_new_zone_ids, 'INCLUDE');
      l_err_loc := 300;

    ELSE

      create_local_zones(l_new_zone_ids, p_catalog_id, 'RESP_SECURED',
                         g_catalog_supplier_flags(p_catalog_id), 'INCLUDE');
      l_err_loc := 350;

    END IF;

    -- each responsibility will have a set of categories which they can
    -- access;  secure the local zone by these categories
    add_resp_categories_to_zone(l_new_zone_ids, l_resp_with_realm_values_ids);
    l_err_loc := 400;

    -- secure each zone to its corresponding responsibility
    secure_zones_by_resps(l_new_zone_ids, l_resp_with_realm_values_ids);
    l_err_loc := 500;

    -- only add the zones to the store if the original catalog was in a store
    IF (p_old_store_id IS NOT NULL) THEN

      add_zones_to_store(l_new_zone_ids, g_stores_map(p_old_store_id),
                         p_catalog_id, p_old_store_id);
      l_err_loc := 600;

    ELSE  -- skip and log

      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'Skipping adding zones migrated from Local Catalog '||p_catalog_id||
          ' to any R12 Stores because it did not belong to any Old Stores.');
      END IF;

    END IF;

  ELSE  -- skip and log

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Skipping creating category-restricted zones from Local Catalog '||
        p_catalog_id||' in Old Store '||p_old_store_id||
        ' as there are no resps with realm values that can access it.');
    END IF;

  END IF;

  -- now, handle all the responsibilties without category realms for this
  -- store;  they should, by default, be able to access this local catalog
  -- without any category restrictions
  l_resp_without_realms_ids :=
    get_resps_without_realms_store('RT_CATEGORY_ID', p_old_store_id);
  l_err_loc := 700;

  -- of course, create the zone only if these responsibilities exist
  IF (l_resp_without_realms_ids.COUNT > 0) THEN

    -- only one zone is needed for all these no realms responsibilities
    l_new_zone_ids := get_new_zone_ids(1);
    l_err_loc := 800;

    -- for pre 11.5.9 upgrade, the content zone must be created specially
    -- from the new seeded R12 "All Local Content" zone
    IF (g_is_pre_1159_upgrade) THEN

      -- create the local zone, but don't add any category restrictions
      create_local_all_content_zones(l_new_zone_ids, 'INCLUDE_ALL');
      l_err_loc := 900;

    ELSE

      -- create the local zone, but don't add any category restrictions
      create_local_zones(l_new_zone_ids, p_catalog_id, 'RESP_SECURED',
                         g_catalog_supplier_flags(p_catalog_id), 'INCLUDE_ALL');
      l_err_loc := 950;

    END IF;

    -- secure this zone by all these responsibilties without realms
    secure_zone_by_resps(l_new_zone_ids(1), l_resp_without_realms_ids);
    l_err_loc := 1000;

    -- again, add the zone to the store if the original catalog was in a store
    IF (p_old_store_id IS NOT NULL) THEN

      add_zones_to_store(l_new_zone_ids, g_stores_map(p_old_store_id),
                         p_catalog_id, p_old_store_id);
      l_err_loc := 1100;

    ELSE  -- skip and log

      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'Skipping adding zone migrated from Local Catalog '||p_catalog_id||
          ' to any R12 Stores because it did not belong to any Old Stores.');
      END IF;

    END IF;

  ELSE  -- skip and log

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Skipping creating category-unrestricted zone from Local Catalog '||
        p_catalog_id||' in Old Store '||p_old_store_id||
        ' as there are no resps without realms that can access it.');
    END IF;

  END IF;

  l_err_loc := 1200;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name, 'End');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_CNTNT_SCRTY_UPG_PVT.migrate_catalog_with_realms(' ||
     l_err_loc || '), ' || SQLERRM);

END migrate_catalog_with_realms;


-- Migrates all given item sources when item source realms do not need to
-- be considered for them.  This happens when the responsibilities
-- that can access these item sources themselves do not have realms.  This
-- method is also used in the general case where item source realms is not
-- used on the customer installation.
--
-- @param p_item_source_ids The list of item sources to migrate.
-- @param p_old_store_ids The list of corresponding old stores that the
--                        item sources belonged to.
-- @param p_new_zone_ids The list of new content zone sequence numbers to
--                       be used when migrating these item sources.
--
PROCEDURE migrate_isrcs_no_realms
(
  p_item_source_ids IN ICX_TBL_NUMBER,
  p_old_store_ids IN ICX_TBL_NUMBER,
  p_new_zone_ids IN ICX_TBL_NUMBER
)
IS
  l_security_flags ICX_TBL_VARCHAR20;
  l_r12_store_ids ICX_TBL_NUMBER;

  l_api_name CONSTANT VARCHAR2(30) := 'migrate_isrcs_no_realms';
  l_err_loc PLS_INTEGER;
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, 'Start');
  END IF;

  l_err_loc := 0;

  -- create a corresponding list for each of the flags/ids needed
  l_security_flags := ICX_TBL_VARCHAR20();
  l_security_flags.extend(p_old_store_ids.COUNT);

  l_r12_store_ids := ICX_TBL_NUMBER();
  l_r12_store_ids.extend(p_old_store_ids.COUNT);

  l_err_loc := 100;

  FOR i IN 1..p_old_store_ids.COUNT LOOP

    -- if the item source does not belong to any store, keep NULL for the
    -- new store; also, security will default to ALL_USERS, as there are no
    -- restrictionson this non-existent store
    IF (p_old_store_ids(i) IS NULL) THEN

      l_r12_store_ids(i) := NULL;
      l_security_flags(i) := 'ALL_USERS';

      l_err_loc := 200;

    ELSE

      l_r12_store_ids(i) := g_stores_map(p_old_store_ids(i));
      l_security_flags(i) := g_store_security_flags(p_old_store_ids(i));

      l_err_loc := 300;

    END IF;

  END LOOP;

  -- once the new store IDs and security flags have been set, create the
  -- actual item source zones
  create_item_source_zones(p_new_zone_ids, p_item_source_ids, l_security_flags);
  l_err_loc := 400;

  -- secure each by the corresponding operating unit restrictions of the old
  -- 11.5.10 store (or none, be that the case -- all handled in the method)
  secure_zones_by_store_orgs(p_new_zone_ids, p_old_store_ids, l_security_flags);
  l_err_loc := 500;

  -- add all the zones to the corresponding new R12 stores
  add_zones_to_stores(p_new_zone_ids, l_r12_store_ids,
                      p_item_source_ids, p_old_store_ids);
  l_err_loc := 600;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name, 'End');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_CNTNT_SCRTY_UPG_PVT.migrate_isrcs_no_realms(' ||
     l_err_loc || '), ' || SQLERRM);

END migrate_isrcs_no_realms;


-- Migrates one given item sources when item source realms when realms needs
-- to be considered.
--
-- Unlike the no realms case, this method will handle only one item source
-- at a time, to minimize complexity.  The process is broken down as follows:
--
-- (1) Determine which responsibilities have realm values that allow them
--     to access this given item source.
--
-- (2) If there are any responsibilities left, create a copy of the local
--     catalog for each.  Then add the category restrictions that are
--     particular to each responsibility.  Lastly, secure this content zone
--     by that particular responsibility.
--
-- (3) For all responsibilities WITHOUT category realms that can access
--     this store (if any), create another copy of the local content.
--     This copy will not be restricted by categories.  Secure this by
--     all such responsibilities without category realms.
--
-- @param p_item_source_ids The list of item sources to migrate.
-- @param p_old_store_ids The list of corresponding old stores that the
--                        item sources belonged to.
-- @param p_resp_with_realms_ids The list of responsibilities with item source
--                               realms that can access this store via the
--                               store's "org assignments."
-- @param p_resp_without_realms_ids List of responsibilities without item
--                                  source realms that can access this store.
--
PROCEDURE migrate_isrc_with_realms
(
  p_item_source_id IN NUMBER,
  p_old_store_id IN NUMBER,
  p_resp_with_realms_ids IN ICX_TBL_NUMBER,
  p_resp_without_realms_ids IN ICX_TBL_NUMBER
)
IS
  l_new_zone_ids ICX_TBL_NUMBER;
  l_resp_can_access_ids ICX_TBL_NUMBER;
  l_resps_to_secure_by ICX_TBL_NUMBER;

  l_api_name CONSTANT VARCHAR2(30) := 'migrate_isrc_with_realms';
  l_err_loc PLS_INTEGER;
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, 'Start');
  END IF;

  l_err_loc := 0;

  -- keep a running list of responsibilities that will be secured against
  -- this migrated "item source" content zone
  l_resps_to_secure_by := ICX_TBL_NUMBER();

  IF (g_item_sources_to_resp_map.EXISTS(p_item_source_id)) THEN

    -- retrieve list of responsibilities that can access this item source
    -- from their item source realm values
    l_resp_can_access_ids := g_item_sources_to_resp_map(p_item_source_id);
    l_err_loc := 100;

    FOR i in 1..l_resp_can_access_ids.COUNT LOOP

      FOR j in 1..p_resp_with_realms_ids.COUNT LOOP

        -- if this responsibility can access this store AND can access
        -- this item source via it's item source realms values, add to the list
        IF (l_resp_can_access_ids(i) = p_resp_with_realms_ids(j)) THEN

          l_resps_to_secure_by.extend;
          l_resps_to_secure_by(l_resps_to_secure_by.COUNT)
            := l_resp_can_access_ids(i);

          l_err_loc := 200;

        END IF;

      END LOOP;

    END LOOP;

    -- log out the responsibilties that can access this item source via realms
    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'For migrating Item Source '||p_item_source_id||
          ' with Realms for Store '||p_old_store_id||
          ', the following responsibilities can access it:');

      FOR i IN 1..l_resps_to_secure_by.COUNT LOOP
        FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'Responsibility #'||i||'.'||l_resps_to_secure_by(i));
      END LOOP;
    END IF;

  -- ELSE no responsibilties can access this item source via its realm
  -- values, so do nothing as l_resps_to_secure_by is already empty

  END IF;

  -- add both lists up: (1) the list just created of the resps that have
  -- item source realms and can access the item source via it's realm values
  -- AND (2) the list of resps without item source realms for this store(they
  -- automatically should be able to access this zone), and determine if there's
  -- any responsibilites to do the actually securing by (if none, do nothing)
  IF (l_resps_to_secure_by.COUNT + p_resp_without_realms_ids.COUNT > 0) THEN

    l_new_zone_ids := get_new_zone_ids(1);
    create_item_source_zones(l_new_zone_ids, p_item_source_id, 'RESP_SECURED');

    l_err_loc := 300;

    -- secure by the responsibility with realms that can access this item source
    IF (l_resps_to_secure_by.COUNT > 0) THEN

      secure_zone_by_resps(l_new_zone_ids(1), l_resps_to_secure_by);
      l_err_loc := 400;

    END IF;

    -- secure by the responsibility without realms, again, if any
    IF (p_resp_without_realms_ids.COUNT > 0) THEN

      secure_zone_by_resps(l_new_zone_ids(1), p_resp_without_realms_ids);
      l_err_loc := 500;

    END IF;

    -- add to the store only if the original item source was in a store
    IF (p_old_store_id IS NOT NULL) THEN

      add_zones_to_store(l_new_zone_ids, g_stores_map(p_old_store_id),
                         p_item_source_id, p_old_store_id);
      l_err_loc := 600;

    END IF;

  ELSE  -- no responsibilities total can access this item source, skip it

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Skipping Item Source '||p_item_source_id||' for Store '||
        p_old_store_id||' as no responsibilities can access it.');
    END IF;

  END IF;

  l_err_loc := 700;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name, 'End');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_CNTNT_SCRTY_UPG_PVT.migrate_isrc_with_realms(' ||
     l_err_loc || '), ' || SQLERRM);

END migrate_isrc_with_realms;


-- Migrates all info-templates over to Smart Forms for R12.  In actuality,
-- there is little data migration, as por_noncat_templates_all_b is still
-- being used.  So, only the relationship to the store is considered, where
-- the smart form must be added to the new R12 store if the smart form
-- via is org_id field is accessible via the old store's operating units
-- restrictions, if any.  The default template is skipped.
--
-- @param p_item_source_ids The list of item sources to migrate.
-- @param p_old_store_ids The list of corresponding old stores that the
--                        item sources belonged to.
-- @param p_new_zone_ids The list of new content zone sequence numbers to
--                       be used when migrating these item sources.
--
PROCEDURE migrate_templates
IS
  l_template_ids ICX_TBL_NUMBER;
  l_old_store_ids ICX_TBL_NUMBER;
  l_r12_store_ids ICX_TBL_NUMBER;

  l_api_name CONSTANT VARCHAR2(30) := 'migrate_templates';
  l_err_loc PLS_INTEGER;
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, 'Start');
  END IF;

  l_err_loc := 0;

  BEGIN

    SELECT templates.template_id, sc.store_id
    BULK COLLECT INTO l_template_ids, l_old_store_ids
    FROM icx_cat_store_catalogs sc, por_noncat_templates_all_b templates,
         icx_cat_store_org_assignments orgs
    WHERE templates.template_id = sc.item_source_id
      AND sc.store_id = orgs.store_id
      AND orgs.org_id IN (templates.org_id, -2)
      AND templates.template_id <> 10000000;

    l_err_loc := 100;

    l_r12_store_ids := ICX_TBL_NUMBER();
    l_r12_store_ids.extend(l_template_ids.COUNT);

    l_err_loc := 200;

    FOR i in 1..l_template_ids.COUNT LOOP

      -- get the corresponding R12 store ID;
      -- old store should be NEVER null as queried above
      l_r12_store_ids(i) := g_stores_map(l_old_store_ids(i));
      l_err_loc := 300;

    END LOOP;

    -- simply add these forms to their new corresponding R12 stores
    add_smart_forms_to_stores(l_template_ids, l_r12_store_ids, l_old_store_ids);
    l_err_loc := 400;

  EXCEPTION
    WHEN no_data_found THEN
      NULL; -- there are no smart forms
      l_err_loc := 500;

      IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'No Smart Forms found on the installation.');
      END IF;
  END;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name, 'End');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_CNTNT_SCRTY_UPG_PVT.migrate_templates(' ||
     l_err_loc || '), ' || SQLERRM);

END migrate_templates;


-- QUERYING OLD DATA HELPERS
----------------------------

-- Determines if there are any local catalogs in the installation.
--
-- @return TRUE if so, FALSE if not
--
FUNCTION exists_local_catalogs
RETURN BOOLEAN
IS
  l_exists_local_catalogs NUMBER;
  l_err_loc PLS_INTEGER;
BEGIN

  l_err_loc := 0;

  BEGIN

    SELECT 1
    INTO l_exists_local_catalogs
    FROM dual
    WHERE exists (SELECT item_source_id
                  FROM icx_por_item_sources
                  WHERE type = 'LOCAL');
    l_err_loc := 100;

  EXCEPTION
    WHEN no_data_found THEN
      l_exists_local_catalogs := -1;
      l_err_loc := 200;
  END;

  IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
      ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name,
                                             'exists_local_catalogs'),
      'Checking if any catalogs exist (1=>TRUE) = '||l_exists_local_catalogs);
  END IF;

  l_err_loc := 300;

  RETURN (l_exists_local_catalogs = 1);

EXCEPTION
  WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_CNTNT_SCRTY_UPG_PVT.exists_local_catalogs('
     || l_err_loc || '), ' || SQLERRM);

END exists_local_catalogs;


-- Determines if there are any item sources in the installation.
--
-- @return TRUE if so, FALSE if not
--
FUNCTION exists_item_sources
RETURN BOOLEAN
IS
  l_exists_item_sources NUMBER;
  l_err_loc PLS_INTEGER;
BEGIN

  l_err_loc := 0;

  BEGIN

    SELECT 1
    INTO l_exists_item_sources
    FROM dual
    WHERE exists (SELECT item_source_id
                  FROM icx_por_item_sources
                  WHERE type IN ('EXTERNAL', 'DISTSRCH', 'INFO'));
    l_err_loc := 100;

  EXCEPTION
    WHEN no_data_found THEN
      l_exists_item_sources := -1;
      l_err_loc := 200;
  END;

  IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
      ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, 'exists_item_sources'),
      'Checking if any item sources exist (1=>TRUE) = '||l_exists_item_sources);
  END IF;

  l_err_loc := 300;

  RETURN (l_exists_item_sources = 1);

EXCEPTION
  WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_CNTNT_SCRTY_UPG_PVT.exists_item_sources('
     || l_err_loc || '), ' || SQLERRM);

END exists_item_sources;


-- Creates a map of old store IDs to the security assignment flag values
-- that will be stored on the new content zones.  These values will be either
-- 'ALL_USERS' for stores secured by -2 (all OUs), or 'OU_SECURED' for
-- any stores secured by any number of OUs.  'RESP_SECURED' is not stored
-- here, as it will be taken of specially if realms need to be considered.
--
PROCEDURE populate_store_security_flags
IS
  l_store_ids ICX_TBL_NUMBER;
  l_security_flags ICX_TBL_VARCHAR20;

  l_api_name CONSTANT VARCHAR2(30) := 'populate_store_security_flags';
  l_err_loc PLS_INTEGER;
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, 'Start');
  END IF;

  l_err_loc := 0;

  SELECT distinct(stores.store_id),
         decode(orgs.org_id, -2, 'ALL_USERS', 'OU_SECURED')
  BULK COLLECT INTO l_store_ids, l_security_flags
  FROM icx_cat_stores_b stores, icx_cat_store_org_assignments orgs
  WHERE stores.store_id = orgs.store_id;

  l_err_loc := 100;

  FOR i IN 1..l_store_ids.COUNT LOOP

    g_store_security_flags(l_store_ids(i)) := l_security_flags(i);

    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'For Store '||l_store_ids(i)||
        ', security flag='||l_security_flags(i));
    END IF;

  END LOOP;

  l_err_loc := 200;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name, 'End');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_CNTNT_SCRTY_UPG_PVT.populate_store_security_flags('
     || l_err_loc || '), ' || SQLERRM);

END populate_store_security_flags;


-- Creates a map of old catalog IDs to the supplier attribute action flag
-- values that will be stored on the new content zones.  These values will
-- be either 'INCLUDE' if any supplier rows are found, or 'EXCLUDE_ALL' if
-- none are found for all other catalogs other than the local base.
-- This is because in 11i10, exclusion of specific suppliers was not allowed,
-- and the 'INCLUDE_ALL' case is only applicable to the seeded 'LOCAL_BASE'
-- catalog which is handled by the decode.
--
PROCEDURE populate_catalog_supplr_flags
IS
  l_sources_ids ICX_TBL_NUMBER;
  l_supplier_flags ICX_TBL_VARCHAR20;

  l_api_name CONSTANT VARCHAR2(30) := 'populate_catalog_supplr_flags';
  l_err_loc PLS_INTEGER;
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, 'Start');
  END IF;

  l_err_loc := 0;

  SELECT distinct sources.item_source_id,
         nvl2(details.supplier_id, 'INCLUDE',
              DECODE(sources.protocol_supported,
                     'LOCAL_BASE', 'INCLUDE_ALL', 'EXCLUDE_ALL'))
  BULK COLLECT INTO l_sources_ids, l_supplier_flags
  FROM icx_por_item_sources sources, icx_cat_item_src_details details
  WHERE sources.type = 'LOCAL'
    AND sources.item_source_id = details.item_source_id(+);

  l_err_loc := 100;

  FOR i IN 1..l_sources_ids.COUNT LOOP

    g_catalog_supplier_flags(l_sources_ids(i)) := l_supplier_flags(i);

    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'For Local Catalog '||l_sources_ids(i)||
        ', supplier flag='||l_supplier_flags(i));
    END IF;

  END LOOP;

  l_err_loc := 200;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name, 'End');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_CNTNT_SCRTY_UPG_PVT.populate_catalog_supplier_flags('
     || l_err_loc || '), ' || SQLERRM);

END populate_catalog_supplr_flags;


-- Creates a list of all the item sources that will require a old item source
-- ID (operator ID in the context of downloaded exchange punchout catalogs)
-- to new content zone ID mapping due the requirement that the
-- parent_zone_id must be properly mapped and populated in the punchout
-- details table (icx_cat_punchout_details).
--
PROCEDURE populate_operator_id_list
IS
  l_operator_ids ICX_TBL_NUMBER;

  l_api_name CONSTANT VARCHAR2(30) := 'populate_operator_id_list';
  l_err_loc PLS_INTEGER;
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, 'Start');
  END IF;

  l_err_loc := 0;

  BEGIN

    SELECT distinct operator_id
    BULK COLLECT INTO l_operator_ids
    FROM icx_por_item_sources
    WHERE operator_id IS NOT NULL;

    l_err_loc := 100;

    FOR i IN 1..l_operator_ids.COUNT LOOP
      g_exchange_punchout_map(l_operator_ids(i)) := -999;
    END LOOP;

    l_err_loc := 200;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN

      NULL; -- nothing needs to be done
      l_err_loc := 300;

      IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'No downloaded exchange punchout catalogs found to migrate.');
      END IF;

  END;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name, 'End');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_CNTNT_SCRTY_UPG_PVT.populate_parent_zone_id_list('
     || l_err_loc || '), ' || SQLERRM);

END populate_operator_id_list;


-- In the case where realms must be considered, this method retrieves the
-- list of contents (either local catalogs or item sources or both) depending
-- on what has already been sucessfully migrated without realms.  This
-- method should not be called if both have already been migrated, as
-- in that case, nothing more needs to be done, and this method does nothing.
-- In all cases, the contractor catalog is ignored, as it is taken care of
-- in migrate_seed_data().
--
-- @param p_catalogs_migrated True if local catalogs have been migrated
--                            (in this case, without realms consideration).
-- @param p_item_sources_migrated True if item sources have been migrated
--                            (in this case, without realms consideration).
--
-- @param OUT x_old_content_ids The list of the item source IDs to still migrate.
-- @param OUT x_content_types The corresponding types of the item sources.
-- @param OUT x_old_store_ids The list of corresponding stores, may be NULL;
--                            sources need not have been added to stores.
--
PROCEDURE get_contents_to_migrate
(
  p_catalogs_migrated IN BOOLEAN,
  p_item_sources_migrated IN BOOLEAN,
  x_old_content_ids OUT NOCOPY ICX_TBL_NUMBER,
  x_content_types OUT NOCOPY ICX_TBL_VARCHAR15,
  x_old_store_ids OUT NOCOPY ICX_TBL_NUMBER
)
IS
  l_api_name CONSTANT VARCHAR2(30) := 'get_contents_to_migrate';
  l_err_loc PLS_INTEGER;
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, 'Start');
  END IF;

  l_err_loc := 0;

  -- if neither has been migrated, select all contents to be migrated
  IF NOT (p_catalogs_migrated OR p_item_sources_migrated) THEN

    l_err_loc := 100;

    SELECT sources.item_source_id, sources.type, sc.store_id
    BULK COLLECT INTO x_old_content_ids, x_content_types, x_old_store_ids
    FROM icx_por_item_sources sources, icx_cat_store_catalogs sc
    WHERE sources.item_source_id = sc.item_source_id(+)
      AND sources.type <> 'CNTRCTR'
    ORDER BY sc.store_id;

    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Neither Local Catalogs nor Item Sources have been migrated.');
    END IF;

  -- else if item sources has not been migrated, select only them
  ELSIF NOT (p_item_sources_migrated) THEN

    l_err_loc := 200;

    SELECT sources.item_source_id, sources.type, sc.store_id
    BULK COLLECT INTO x_old_content_ids, x_content_types, x_old_store_ids
    FROM icx_por_item_sources sources, icx_cat_store_catalogs sc
    WHERE sources.item_source_id = sc.item_source_id(+)
      AND sources.type IN ('EXTERNAL', 'DISTSRCH', 'INFO')
    ORDER BY sc.store_id;

    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Only Local Catalogs have been migrated, retrieving Item Sources.');
    END IF;

  -- else if local catalogs has not been migrated, select only local catalogs
  ELSIF NOT (p_catalogs_migrated) THEN

    l_err_loc := 300;

    SELECT sources.item_source_id, sources.type, sc.store_id
    BULK COLLECT INTO x_old_content_ids, x_content_types, x_old_store_ids
    FROM icx_por_item_sources sources, icx_cat_store_catalogs sc
    WHERE sources.item_source_id = sc.item_source_id(+)
      AND sources.type = 'LOCAL'
    ORDER BY sc.store_id;

    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Only Item Sources have been migrated, retrieving Local Catalogs.');
    END IF;

  END IF;

  l_err_loc := 400;

  -- log out the contents to be migrated
  IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FOR i IN 1..x_old_content_ids.COUNT LOOP
      FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        i||'.old_content_id='||x_old_content_ids(i)||',type='
        ||x_content_types(i)||',store='||x_old_store_ids(i));
    END LOOP;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name, 'End');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_CNTNT_SCRTY_UPG_PVT.get_contents_to_migrate('
     || l_err_loc || '), ' || SQLERRM);

END get_contents_to_migrate;


-- R12 STORE HELPER METHODS
---------------------------

-- Creates a new R12 store from an existing pre-R12 old store,
-- essentially migrating the data over.  This method will NOT migrate
-- the seeded "Main Store" and "Non-Catalog" store, as they were
-- already handled in migrate_seed_data().
--
-- In addition, after this method call, the global map of old store IDs
-- to new R12 store IDs will be populated.
--
PROCEDURE create_R12_stores
IS
  l_old_store_ids ICX_TBL_NUMBER;
  l_r12_store_ids ICX_TBL_NUMBER;

  l_api_name CONSTANT VARCHAR2(30) := 'create_R12_stores';
  l_err_loc PLS_INTEGER;
  l_old_store_key NUMBER;
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, 'Start');
  END IF;

  l_err_loc := 0;

  -- select all the old stores (minus the seeded ones) and new store IDs
  SELECT store_id, ICX_CAT_SHOP_STORES_S.NEXTVAL
  BULK COLLECT INTO l_old_store_ids, l_r12_store_ids
  FROM icx_cat_stores_b
  WHERE store_id NOT IN (0, 10000000);

  l_err_loc := 100;

  -- store a mapping from the old store to the new R12 store IDs;
  -- will be needed when migrate the store catalogs and item sources
  FOR i IN 1..l_old_store_ids.COUNT LOOP
    g_stores_map(l_old_store_ids(i)) := l_r12_store_ids(i);
  END LOOP;

  l_err_loc := 200;

  -- migrate the base and TL table data
  FORALL i IN 1..l_old_store_ids.COUNT
    INSERT INTO icx_cat_shop_stores_b
      (store_id, sequence, local_content_first_flag, created_by, creation_date,
       last_updated_by, last_update_date, last_update_login)
    SELECT l_r12_store_ids(i), stores.sequence_number, 'Y', fnd_global.user_id,
           sysdate, fnd_global.user_id, sysdate, fnd_global.login_id
    FROM icx_cat_stores_b stores
    WHERE stores.store_id = l_old_store_ids(i);

  l_err_loc := 300;

  FORALL i IN 1..l_old_store_ids.COUNT
    INSERT INTO icx_cat_shop_stores_tl
      (store_id, language, source_lang, name, description, long_description,
       image, created_by, creation_date, last_updated_by, last_update_date,
       last_update_login)
    SELECT l_r12_store_ids(i), stores_tl.language, stores_tl.source_lang,
      stores_tl.store_name, stores_tl.short_description,
      stores_tl.long_description, stores_tl.image_location, fnd_global.user_id,
      sysdate, fnd_global.user_id, sysdate, fnd_global.login_id
    FROM icx_cat_stores_tl stores_tl
    WHERE stores_tl.store_id = l_old_store_ids(i);

  l_err_loc := 400;

  -- list the mapping of old stores to the new stores created
  IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

    l_old_store_key := g_stores_map.FIRST();

    WHILE (l_old_store_key IS NOT NULL) LOOP

      FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'New Store '||g_stores_map(l_old_store_key)||
        ' created from Old Store '||l_old_store_key);

      l_old_store_key := g_stores_map.NEXT(l_old_store_key);

    END LOOP;

  END IF;

  l_err_loc := 500;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name, 'End');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_CNTNT_SCRTY_UPG_PVT.create_R12_stores('
     || l_err_loc || '), ' || SQLERRM);

END create_R12_stores;


-- Adds the list of content zones to the given store.  This method is
-- primarily used in the case where category realms must be considered,
-- and one catalog must be split into multiple content zones based on
-- the responsibilities with category realms.
--
-- @param p_zone_ids List of Content Zone IDs to add to the R12 Store.
-- @param p_r12_store_id The R12 Store ID to which the zones are to be added.
-- @param p_old_store_id The 11.5.10 Store ID corresponding to the R12 store.
--
PROCEDURE add_zones_to_store
(
  p_zone_ids IN ICX_TBL_NUMBER,
  p_r12_store_id IN NUMBER,
  p_old_source_id IN NUMBER,
  p_old_store_id IN NUMBER
)
IS
  l_api_name CONSTANT VARCHAR2(30) := 'add_zones_to_store';
  l_err_loc PLS_INTEGER;
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, 'Start');
  END IF;

  l_err_loc := 0;

  FORALL i IN 1..p_zone_ids.COUNT
    INSERT INTO icx_cat_store_contents
    (store_id, content_id, content_type, sequence, display_always_flag,
     created_by, creation_date, last_updated_by, last_update_date,
     last_update_login)
    SELECT p_r12_store_id, p_zone_ids(i), 'CONTENT_ZONE',
           sc.sequence_number, sc.display_always_flag,
           fnd_global.user_id, sysdate, fnd_global.user_id, sysdate,
           fnd_global.login_id
    FROM icx_cat_store_catalogs sc
    WHERE p_old_store_id IS NOT NULL
      AND sc.store_id = p_old_store_id
      AND sc.item_source_id = p_old_source_id;

  l_err_loc := 100;

  -- list all the content zones added to the new stores
  IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FOR i IN 1..p_zone_ids.COUNT LOOP
      FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Adding Zone '||p_zone_ids(i)||' to R12 Store '||p_r12_store_id);
    END LOOP;
  END IF;

  -- list the old IDs if statement-level logging is enabled
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
      ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
      'Old Source='||p_old_source_id||', Old Store='||p_old_store_id);
  END IF;

  l_err_loc := 200;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name, 'End');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_CNTNT_SCRTY_UPG_PVT.add_zones_to_store('
     || l_err_loc || '), ' || SQLERRM);

END add_zones_to_store;


-- Adds the list of content zones to the corresponding list of stores (1:1).
-- That is, for each index, the zone at that index will be added to the store
-- add that index.  This is used to quickly add multiple zones to multiple
-- stores.  This is handled by a simple FORALL statement.
--
-- @param p_zone_ids List of Content Zone IDs to add to the stores.
-- @param p_r12_store_ids The R12 Stores IDs to which the zones are to be added.
-- @param p_old_store_ids The 11.5.10 Stores corresponding to the R12 Stores.
--
PROCEDURE add_zones_to_stores
(
  p_zone_ids IN ICX_TBL_NUMBER,
  p_r12_store_ids IN ICX_TBL_NUMBER,
  p_old_source_ids IN ICX_TBL_NUMBER,
  p_old_store_ids IN ICX_TBL_NUMBER
)
IS
  l_api_name CONSTANT VARCHAR2(30) := 'add_zones_to_stores';
  l_err_loc PLS_INTEGER;
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, 'Start');
  END IF;

  l_err_loc := 0;

  FORALL i IN 1..p_zone_ids.COUNT
    INSERT INTO icx_cat_store_contents
    (store_id, content_id, content_type, sequence, display_always_flag,
     created_by, creation_date, last_updated_by, last_update_date,
     last_update_login)
    SELECT p_r12_store_ids(i), p_zone_ids(i), 'CONTENT_ZONE',
           sc.sequence_number, sc.display_always_flag,
           fnd_global.user_id, sysdate, fnd_global.user_id, sysdate,
           fnd_global.login_id
    FROM icx_cat_store_catalogs sc
    WHERE p_old_store_ids(i) IS NOT NULL
      AND sc.store_id = p_old_store_ids(i)
      AND sc.item_source_id = p_old_source_ids(i);

  l_err_loc := 100;

  -- list all the content zones added to the new stores
  IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FOR i IN 1..p_zone_ids.COUNT LOOP
      FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Adding Zone '||p_zone_ids(i)||' to R12 Store '||p_r12_store_ids(i));
    END LOOP;
  END IF;

  -- list the old IDs if statement-level logging is enabled
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FOR i IN 1..p_old_source_ids.COUNT LOOP
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Old Source='||p_old_source_ids(i)||', Old Store='||p_old_store_ids(i));
    END LOOP;
  END IF;

  l_err_loc := 200;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name, 'End');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_CNTNT_SCRTY_UPG_PVT.add_zones_to_stores('
     || l_err_loc || '), ' || SQLERRM);

END add_zones_to_stores;


-- Adds the list of smart forms to the corresponding list of stores (1:1).
-- That is, for each index, the smart form at that index will be added to
-- the store add that index.  This is used to quickly add multiple
-- smart forms to multiple stores.  This is handled by a FORALL statement.
-- Unlike content zones, smart forms keep the same ID since they are not
-- being migrated (they say in por_noncat_templates_all_b), so no need for
-- a corresponding "old_template_id" as with the content zones.
--
-- @param p_zone_ids List of Smart Form IDs to add to the stores.
-- @param p_r12_store_ids The R12 Stores IDs to which the zones are to be added.
-- @param p_old_store_ids The corresponding 11.5.10 store IDs.
--
PROCEDURE add_smart_forms_to_stores
(
  p_smart_form_ids IN ICX_TBL_NUMBER,
  p_r12_store_ids IN ICX_TBL_NUMBER,
  p_old_store_ids IN ICX_TBL_NUMBER
)
IS
  l_api_name CONSTANT VARCHAR2(30) := 'add_smart_forms_to_stores';
  l_err_loc PLS_INTEGER;
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, 'Start');
  END IF;

  l_err_loc := 0;

  FORALL i IN 1..p_smart_form_ids.COUNT
    INSERT INTO icx_cat_store_contents
    (store_id, content_id, content_type, sequence, display_always_flag,
     created_by, creation_date, last_updated_by, last_update_date,
     last_update_login)
    SELECT p_r12_store_ids(i), p_smart_form_ids(i), 'SMART_FORM',
           DECODE(default_template_flag, 'Y', 1, NULL),
           sc.display_always_flag, fnd_global.user_id, sysdate,
           fnd_global.user_id, sysdate, fnd_global.login_id
    FROM icx_cat_store_catalogs sc
    WHERE sc.store_id = p_old_store_ids(i)
      AND sc.item_source_id = p_smart_form_ids(i);

  l_err_loc := 100;

  -- list all the smart forms migrated to the new stores
  IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FOR i IN 1..p_smart_form_ids.COUNT LOOP
      FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Moving Smart Form '||p_smart_form_ids(i)||' from Old Store '||
          p_old_store_ids(i)||' to R12 Store '||p_r12_store_ids(i));
    END LOOP;
  END IF;

  l_err_loc := 200;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name, 'End');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_CNTNT_SCRTY_UPG_PVT.add_smart_forms_to_store('
     || l_err_loc || '), ' || SQLERRM);

END add_smart_forms_to_stores;


-- CONTENT ZONE HELPERS
-----------------------

-- A simple helper method that retreives a list of new content zone IDs
-- based on the database sequence.
--
-- @param p_num_zone The number of zones to insert into the database, and
--                   hence the same number of new zone IDs to be returned.
--
FUNCTION get_new_zone_ids
(
  p_num_zones IN NUMBER
)
RETURN ICX_TBL_NUMBER
IS
  l_new_zone_ids ICX_TBL_NUMBER;
  l_api_name CONSTANT VARCHAR2(30) := 'get_new_zone_ids';
  l_err_loc PLS_INTEGER;
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name,
      'p_num_zones='||p_num_zones);
  END IF;

  l_err_loc := 0;

  l_new_zone_ids := ICX_TBL_NUMBER();
  l_new_zone_ids.extend(p_num_zones);

  FOR i IN 1..p_num_zones LOOP

    l_err_loc := 100;

    SELECT ICX_CAT_CONTENT_ZONES_S.NEXTVAL
    INTO l_new_zone_ids(i)
    FROM dual;

  END LOOP;

  l_err_loc := 200;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FOR i IN 1..l_new_zone_ids.COUNT LOOP
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'New Zone ID '||l_new_zone_ids(i)||' allocated.');
    END LOOP;
  END IF;

  l_err_loc := 300;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name, 'End');
  END IF;

  RETURN l_new_zone_ids;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_CNTNT_SCRTY_UPG_PVT.get_new_zone_ids('
     || l_err_loc || '), ' || SQLERRM);

END get_new_zone_ids;


-- Creates new content zones based on the given local catalog.  This method
-- is used primarily when migrating catalogs while considering category
-- realms as one local catalog must be duplicated into multiple content
-- zones that are secured by each of the different responsibilities with
-- category realms.
--
-- In addition to the IDs of the new zones to create and that of the old
-- local catalog which to migrate the data from, three more parameters are
-- needed: (1) the security flag of the store that this catalog belonged
-- to in 11.5.10, indicating whether to secure this zone by all_users,
-- operating unit, or responsibility, (2) the supplier flag indicating
-- whether this local catalog has any supplier restrictions, and
-- (3) category_flag indicating whether there are any category restrictions
-- (in the case with category realms).
--
-- This method will leverage the generic create_local_zones() method by
-- simply creating multiple "arrays" storing the duplicated values.
--
-- @param p_new_zone_ids The list of new content zone IDs to create.
-- @param p_catalog_id The old local catalog on which the new zones are based.
-- @param p_security_flag The security flag (used to determined by
--                         the store the old catalog was in (all users, etc).
-- @param p_supplier_flag The supplier flag indicating if the local
--                         catalog has supplier restrictions.
-- @param p_category_flag The category flag indicating any category
--                        restrictions due to category realms.
--
-- Please see top level note for details into the valid values of these flags.
--
PROCEDURE create_local_zones
(
  p_new_zone_ids IN ICX_TBL_NUMBER,
  p_catalog_id IN NUMBER,
  p_security_flag IN VARCHAR2,
  p_supplier_flag IN VARCHAR2,
  p_category_flag IN VARCHAR2
)
IS
  l_catalog_ids ICX_TBL_NUMBER;
  l_security_flags ICX_TBL_VARCHAR20;
  l_supplier_flags ICX_TBL_VARCHAR20;

  l_api_name CONSTANT VARCHAR2(30) := 'create_local_zones';
  l_err_loc PLS_INTEGER;
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, 'Start');
  END IF;

  l_err_loc := 0;

  l_security_flags := ICX_TBL_VARCHAR20();
  l_security_flags.extend(p_new_zone_ids.COUNT);

  l_supplier_flags := ICX_TBL_VARCHAR20();
  l_supplier_flags.extend(p_new_zone_ids.COUNT);

  l_catalog_ids := ICX_TBL_NUMBER();
  l_catalog_ids.extend(p_new_zone_ids.COUNT);

  FOR i IN 1..p_new_zone_ids.COUNT LOOP

    l_err_loc := 100;

    l_catalog_ids(i) := p_catalog_id;
    l_security_flags(i) := p_security_flag;
    l_supplier_flags(i) := p_supplier_flag;

  END LOOP;

  l_err_loc := 200;

  -- after populating all the arrays, leverage the generic method to insert
  -- the local zones into the database
  create_local_zones(p_new_zone_ids, l_catalog_ids,
                     l_security_flags, l_supplier_flags, p_category_flag);

  l_err_loc := 300;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name, 'End');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_CNTNT_SCRTY_UPG_PVT.create_local_zones('
     || l_err_loc || '), ' || SQLERRM);

END create_local_zones;


-- Creates new content zones corresponding to the list of local catalogs (1:1).
-- That is, for each index, the zone at that index will be created representing
-- the local catalog at that index.  This is used to quickly create multiple
-- zones for multiple local catalogs.  In addition to the IDs of the new
-- zones to create and those the old local catalogs which to migrate the
-- data from, three more parameters are needed: (1) list of security flags
-- indicating whether to secure this zone by all_users, operating unit, or
-- responsibility, (2) list of supplier flags indicating whether the local
-- catalog has any supplier restrictions, and (3) category_flag indicating
-- whether there are any category restrictions (in the case with
-- category realms).
--
-- @param p_new_zone_ids The list of new content zone IDs to create.
-- @param p_catalog_ids The list of old local catalogs to migrate over (1:1).
-- @param p_security_flags The list of security flags (used to determined by
--                         the store the old catalog was in (all users, etc).
-- @param p_supplier_flags The list of supplier flags indicating if the local
--                         catalog has supplier restrictions.
-- @param p_category_flag One flag for indicating any category restrictions
--                        which is used for all zones created in this method;
--                        currently, only one flag is required instead of a
--                        list due to the structure of the code (it is such
--                        that either category realms is considered or not).
--
-- Please see top level note for details into the valid values of these flags.
--
PROCEDURE create_local_zones
(
  p_new_zone_ids IN ICX_TBL_NUMBER,
  p_catalog_ids IN ICX_TBL_NUMBER,
  p_security_flags IN ICX_TBL_VARCHAR20,
  p_supplier_flags IN ICX_TBL_VARCHAR20,
  p_category_flag IN VARCHAR2
)
IS
  l_api_name CONSTANT VARCHAR2(30) := 'create_local_zones';
  l_err_loc PLS_INTEGER;
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, 'Start(Generic)');
  END IF;

  l_err_loc := 0;

  -- do a forall, migrating values into the base and tl tables
  FORALL i IN 1..p_catalog_ids.COUNT
    INSERT INTO icx_cat_content_zones_b
    (zone_id, type, url, security_assignment_flag,
     category_attribute_action_flag, supplier_attribute_action_flag,
     items_without_supplier_flag, items_without_shop_catg_flag,
     created_by, creation_date, last_updated_by,
     last_update_date, last_update_login)
    SELECT p_new_zone_ids(i), 'LOCAL', sources.url, p_security_flags(i),
           p_category_flag, p_supplier_flags(i),
           DECODE(g_site_approved_pricing, 'Y', 'N',
                  nvl(sources.include_internal_source_flag, 'Y')),
           'N', fnd_global.user_id, sysdate, fnd_global.user_id, sysdate,
           fnd_global.login_id
    FROM icx_por_item_sources sources
    WHERE sources.item_source_id = p_catalog_ids(i);

  l_err_loc := 100;

  FORALL i IN 1..p_catalog_ids.COUNT
    INSERT INTO icx_cat_content_zones_tl
    (zone_id, language, source_lang, name, description, keywords, image,
     created_by, creation_date, last_updated_by, last_update_date,
     last_update_login)
    SELECT p_new_zone_ids(i), sources_tl.language, sources_tl.source_lang,
           sources_tl.item_source_name, sources_tl.description,
           sources_tl.ctx_keywords, sources.image_url, fnd_global.user_id,
           sysdate, fnd_global.user_id, sysdate, fnd_global.login_id
    FROM icx_por_item_sources sources, icx_por_item_sources_tl sources_tl
    WHERE sources.item_source_id = p_catalog_ids(i)
      AND sources_tl.item_source_id = sources.item_source_id;

  l_err_loc := 200;

  -- migrate over supplier restrictions, if any
  FORALL i IN 1..p_catalog_ids.COUNT
    INSERT INTO icx_cat_zone_secure_attributes
    (zone_id, securing_attribute, supplier_id, created_by, creation_date,
     last_updated_by, last_update_date, last_update_login)
    SELECT p_new_zone_ids(i), 'SUPPLIER', supplier_id, fnd_global.user_id,
           sysdate, fnd_global.user_id, sysdate, fnd_global.login_id
    FROM icx_cat_item_src_details
    WHERE item_source_id = p_catalog_ids(i);

  l_err_loc := 300;

  -- log out all the new zones created
  IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FOR i IN 1..p_new_zone_ids.COUNT LOOP
      FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Zone '||p_new_zone_ids(i)||' created from Local Catalog '||
        p_catalog_ids(i)||' with security flag='||p_security_flags(i)||
        ', supplier flag='||p_supplier_flags(i)||
        ', category flag='||p_category_flag);
    END LOOP;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name, 'End(Generic)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_CNTNT_SCRTY_UPG_PVT.create_local_zones('
     || l_err_loc || '), ' || SQLERRM);

END create_local_zones;


-- Similar to "create_local_zones," this method will create new local content
-- zones.  However, this is done for the special case for pre-11.5.9 upgrades
-- where the "All Local Content" is not already seeded in icx_por_item_sources.
-- In this case, the local zones must be created from hard-coded values.
--
-- Note:  This method should be called ONLY when there are realms involved.
--        Values have been hard-coded accordingly.  In the non-realms case,
--        this method is not needed as the seeded R12 "All Local Content"
--        content zone is already sufficient, and needs no additional upgrade.
--
-- Please see the "create_local_zones" header for details into how this method
-- is similarily used.
--
-- @param p_new_zone_ids The list of new content zone IDs to create.
-- @param p_category_flag One flag for indicating any category restrictions
--                        which is used for all zones created in this method;
--                        currently, only one flag is required instead of a
--                        list due to the structure of the code (it is such
--                        that either category realms is considered or not).
--
-- Please see top level note for details into the valid values of these flags.
--
PROCEDURE create_local_all_content_zones
(
  p_new_zone_ids IN ICX_TBL_NUMBER,
  p_category_flag IN VARCHAR2
)
IS
  l_api_name CONSTANT VARCHAR2(30) := 'create_local_all_content_zones';
  l_err_loc PLS_INTEGER;
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, 'Start');
  END IF;

  l_err_loc := 0;

  -- do a forall, migrating values into the base and tl tables
  FORALL i IN 1..p_new_zone_ids.COUNT
    INSERT INTO icx_cat_content_zones_b
    (zone_id, type, url, security_assignment_flag,
     category_attribute_action_flag, supplier_attribute_action_flag,
     items_without_supplier_flag, items_without_shop_catg_flag,
     created_by, creation_date, last_updated_by,
     last_update_date, last_update_login)
    SELECT p_new_zone_ids(i), 'LOCAL', zones.url, 'RESP_SECURED',
           p_category_flag, 'INCLUDE_ALL',
           DECODE(g_site_approved_pricing, 'Y', 'N',
                  zones.items_without_supplier_flag),
           zones.items_without_shop_catg_flag, fnd_global.user_id,
           sysdate, fnd_global.user_id, sysdate, fnd_global.login_id
    FROM icx_cat_content_zones_b zones
    WHERE zones.zone_id = 1;

  l_err_loc := 100;

  FORALL i IN 1..p_new_zone_ids.COUNT
    INSERT INTO icx_cat_content_zones_tl
    (zone_id, language, source_lang, name, description, keywords, image,
     created_by, creation_date, last_updated_by, last_update_date,
     last_update_login)
    SELECT p_new_zone_ids(i), zones_tl.language, zones_tl.source_lang,
           zones_tl.name, zones_tl.description,
           zones_tl.keywords, zones_tl.image, fnd_global.user_id,
           sysdate, fnd_global.user_id, sysdate, fnd_global.login_id
    FROM icx_cat_content_zones_tl zones_tl
    WHERE zones_tl.zone_id = 1;

  l_err_loc := 200;

  -- log out all the new zones created
  IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FOR i IN 1..p_new_zone_ids.COUNT LOOP
      FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Special All-Local-Content Zone '||p_new_zone_ids(i)||' created.');
    END LOOP;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name, 'End');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_CNTNT_SCRTY_UPG_PVT.create_local_all_content_zones('
     || l_err_loc || '), ' || SQLERRM);

END create_local_all_content_zones;


-- Add category restrictions to the given content zones.  The category
-- restrictions added will be based on the category realm values of the
-- given responsibilities.  This is done on a 1:1 basis.  That is, for
-- each index, the zone at that index will be secured by the categories
-- based on the realms of the responsibility at that index.
--
-- @param p_new_zone_ids The list of new content zone IDs to which to
--                       add category restrictions.
-- @param p_resp_ids The list of responsibilities from which category realms
--                   restrictions will be based.
--
PROCEDURE add_resp_categories_to_zone
(
  p_new_zone_ids IN ICX_TBL_NUMBER,
  p_resp_ids IN ICX_TBL_NUMBER
)
IS
  l_current_zone_id NUMBER;
  l_category_ids ICX_TBL_NUMBER;

  l_zones_to_insert ICX_TBL_NUMBER;
  l_categories_to_insert ICX_TBL_NUMBER;

  l_api_name CONSTANT VARCHAR2(30) := 'add_resp_categories_to_zone';
  l_err_loc PLS_INTEGER;
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, 'Start');
  END IF;

  l_err_loc := 0;

  l_zones_to_insert := ICX_TBL_NUMBER();
  l_categories_to_insert := ICX_TBL_NUMBER();

  l_err_loc := 100;

  FOR i IN 1..p_new_zone_ids.COUNT LOOP

    -- for each responsibility with category realms, get all the categories
    -- that are accessible
    l_category_ids := get_catr_realm_values_cached(p_resp_ids(i));
    l_err_loc := 200;

    -- for each responsibility, a new content zone will be created
    l_current_zone_id := p_new_zone_ids(i);
    l_err_loc := 300;

    -- collect the responsibilty, zone, and categories into a running list
    FOR j IN 1..l_category_ids.COUNT LOOP

      l_zones_to_insert.extend;
      l_zones_to_insert(l_zones_to_insert.COUNT) := l_current_zone_id;

      l_categories_to_insert.extend;
      l_categories_to_insert(l_categories_to_insert.COUNT) := l_category_ids(j);

      l_err_loc := 400;

    END LOOP;

  END LOOP;

  -- then, for all the responsibility, zone, and categories tuples, add
  -- them all as rows in the secure attributes table
  FORALL i IN 1..l_zones_to_insert.COUNT
    INSERT INTO icx_cat_zone_secure_attributes
    (zone_id, securing_attribute, ip_category_id, created_by, creation_date,
    last_updated_by, last_update_date, last_update_login)
    SELECT l_zones_to_insert(i), 'CATEGORY', l_categories_to_insert(i),
           fnd_global.user_id, sysdate, fnd_global.user_id, sysdate,
           fnd_global.login_id
    FROM dual;

  -- for statement-level logging, print out values inserted
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FOR i IN 1..l_zones_to_insert.COUNT LOOP
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Zone '||l_zones_to_insert(i)||' secured by Category '||
        l_categories_to_insert(i));
    END LOOP;
  END IF;

  l_err_loc := 500;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name, 'End');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_CNTNT_SCRTY_UPG_PVT.add_resp_categories_to_zone('
     || l_err_loc || '), ' || SQLERRM);

END add_resp_categories_to_zone;


-- Creates new content zones based on the given item source.  This method
-- is used primarily when migrating item sources while considering item source
-- realms.  However, unlike catalogs, typically, only one zone is still
-- created for the item source even with realms.  However, this method still
-- accepts a list of new content zones, if that were the case.  In the
-- one zone case, this list would only have one element.
--
-- In addition to the IDs of the new zones to create and the item source
-- to migrate the data from, one more item is needed: (1) list of security
-- flags indicating whether to secure this zone by all_users, operating unit,
-- or responsibility.
--
-- This method will leverage the generic create_item_source_zones() method by
-- simply creating multiple "arrays" storing the duplicated values.
--
-- @param p_new_zone_ids The list of new content zone IDs to create.
-- @param p_item_source_id The item source on which the new zones are based.
-- @param p_security_flag The security flag (used to determined by
--                        the store the old item source was in (all users, etc).
--
-- Please see top level note for details into the valid values of these flags.
--
PROCEDURE create_item_source_zones
(
  p_new_zone_ids IN ICX_TBL_NUMBER,
  p_item_source_id IN NUMBER,
  p_security_flag IN VARCHAR2
)
IS
  l_item_source_ids ICX_TBL_NUMBER;
  l_security_flags ICX_TBL_VARCHAR20;
  l_api_name CONSTANT VARCHAR2(30) := 'create_item_source_zones';
  l_err_loc PLS_INTEGER;
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, 'Start');
  END IF;

  l_err_loc := 0;

  l_item_source_ids := ICX_TBL_NUMBER();
  l_item_source_ids.extend(p_new_zone_ids.COUNT);

  l_security_flags := ICX_TBL_VARCHAR20();
  l_security_flags.extend(p_new_zone_ids.COUNT);

  l_err_loc := 100;

  FOR i IN 1..p_new_zone_ids.COUNT LOOP

    l_item_source_ids(i) := p_item_source_id;
    l_security_flags(i) := p_security_flag;

  END LOOP;

  l_err_loc := 200;

  -- after populating all the arrays, leverage the generic method to insert
  -- the item source zones into the database
  create_item_source_zones(p_new_zone_ids, l_item_source_ids, l_security_flags);

  l_err_loc := 300;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name, 'End');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_CNTNT_SCRTY_UPG_PVT.create_item_source_zones('
     || l_err_loc || '), ' || SQLERRM);

END create_item_source_zones;


-- Creates new item source zones corresponding to the list of old item
-- sources (1:1).  That is, for each index, the zone at that index will be
-- created representing the item source at that index.  This is used to
-- quickly create multiple zones for multiple item sources.  In addition
-- to the IDs of the new zones to create and those the old item sources which
-- to migrate the data from, one more item is needed: (1) list of security
-- flags indicating whether to secure this zone by all_users, operating unit,
-- or responsibility.
--
-- @param p_new_zone_ids The list of new content zone IDs to create.
-- @param p_item_source_ids The list of old item sources to migrate over (1:1).
-- @param p_security_flags The list of security flags (used to determined by
--                         the store the item source was in (all users, etc).
--
-- Please see top level note for details into the valid values of these flags.
--
PROCEDURE create_item_source_zones
(
  p_new_zone_ids IN ICX_TBL_NUMBER,
  p_item_source_ids IN ICX_TBL_NUMBER,
  p_security_flags IN ICX_TBL_VARCHAR20
)
IS
  l_encrypted_password VARCHAR2(100);  -- length in icx_por_item_sources
  l_decrypted_password VARCHAR2(2048);  -- length in icx_call decrypt method
  l_api_name CONSTANT VARCHAR2(30) := 'create_item_source_zones';
  l_err_loc PLS_INTEGER;
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, 'Start(Generic)');
  END IF;

  l_err_loc := 0;

  -- using FORALL, migrate values into the base and tl tables
  FORALL i IN 1..p_new_zone_ids.COUNT
    INSERT INTO icx_cat_content_zones_b
    (zone_id, type, url, security_assignment_flag, created_by, creation_date,
     last_updated_by, last_update_date, last_update_login)
    SELECT p_new_zone_ids(i),
           DECODE(type, 'EXTERNAL', 'PUNCHOUT',
                        'DISTSRCH', 'TRANSPARENT_PUNCHOUT',
                        'INFO', 'INFORMATIONAL'),
           sources.url, p_security_flags(i),
           fnd_global.user_id, sysdate, fnd_global.user_id, sysdate,
           fnd_global.login_id
    FROM icx_por_item_sources sources
    WHERE sources.item_source_id = p_item_source_ids(i);

  l_err_loc := 100;

  FORALL i IN 1..p_new_zone_ids.COUNT
    INSERT INTO icx_cat_content_zones_tl
    (zone_id, language, source_lang, name, description, keywords, image,
     created_by, creation_date, last_updated_by, last_update_date,
     last_update_login)
    SELECT p_new_zone_ids(i), sources_tl.language, sources_tl.source_lang,
           sources_tl.item_source_name, sources_tl.description,
           sources_tl.ctx_keywords, sources.image_url,
           fnd_global.user_id, sysdate, fnd_global.user_id, sysdate,
           fnd_global.login_id
    FROM icx_por_item_sources sources, icx_por_item_sources_tl sources_tl
    WHERE sources.item_source_id = p_item_source_ids(i)
      AND sources_tl.item_source_id = sources.item_source_id;

  l_err_loc := 200;

  -- migrate values into punchout zone details for those type of item sources
  FORALL i IN 1..p_new_zone_ids.COUNT
    INSERT INTO icx_cat_punchout_zone_details
    (zone_id, protocol_supported, user_name, company_name, company_number,
     supplier_name, supplier_number, ecgateway_map_key1, vendor_id,
     vendor_site_id, encoding, party_site_id, parent_zone_id, authenticated_key,
     user_info_flag, lock_item_flag, retain_session_flag, operation_allowed,
     negotiated_flag, created_by, creation_date, last_updated_by,
     last_update_date, last_update_login)
    SELECT p_new_zone_ids(i),
           DECODE(protocol_supported, 'EXCHANGE', 'EXCHANGE',
                                      'XML_SUPP', 'XML_SUPPLIER',
                                      'CXML_SUPP', 'CXML_SUPPLIER',
                                      'DISTSRCH_SUPP', 'TRANSPARENT_SUPPLIER',
                                      'DISTSRCH_EXCH', 'TRANSPARENT_EXCHANGE',
                                      'VIA_EXCH', 'VIA_EXCHANGE'),
           user_name, company_name, company_number, supplier_name,
           supplier_number, key_1, vendor_id, vendor_site_id, encoding,
           party_site_id, operator_id, authenticated_key, user_info_flag,
           lock_item_flag, icx_session_servlet_flag, operation_allowed,
           negotiated_by_preparer_flag, fnd_global.user_id, sysdate,
           fnd_global.user_id, sysdate, fnd_global.login_id
    FROM icx_por_item_sources
    WHERE item_source_id = p_item_source_ids(i)
      AND type IN ('EXTERNAL', 'DISTSRCH');

  l_err_loc := 300;

  -- for distributed search, "supplemental" values may be migrated
  FORALL i IN 1..p_new_zone_ids.COUNT
    INSERT INTO icx_cat_zone_attributes
    (zone_id, attribute_name, attribute_value, created_by, creation_date,
     last_updated_by, last_update_date, last_update_login)
    SELECT p_new_zone_ids(i), d.name, d.value, fnd_global.user_id,
           sysdate, fnd_global.user_id, sysdate, fnd_global.login_id
    FROM icx_por_item_sources s, icx_cat_item_src_details d
    WHERE s.item_source_id = p_item_source_ids(i)
      AND s.type = 'DISTSRCH'
      AND s.item_source_id = d.item_source_id;

  l_err_loc := 400;

  -- then, specially migrate passwords into fnd_vault (used in R12);
  -- also, take care of populate mapping of exchange item sources for
  -- downloaded punchouts mapping
  FOR i IN 1..p_new_zone_ids.COUNT LOOP

    SELECT password
    INTO l_encrypted_password
    FROM icx_por_item_sources
    WHERE item_source_id = p_item_source_ids(i);

    -- skip the cases where the password is NULL
    IF (l_encrypted_password IS NOT NULL) THEN

      l_decrypted_password := icx_call.decrypt(l_encrypted_password);

      IF (l_decrypted_password IS NOT NULL) THEN

        FND_VAULT.PUT('ICX_CAT_CONTENT_ZONE_PSWD',
                      p_new_zone_ids(i), l_decrypted_password);

        l_err_loc := 500;

      END IF;

    END IF;

    -- only require the mapping for those exchange item sources that have
    -- corresponding downloaded punchouts (previously populated in the map)
    IF (g_exchange_punchout_map.EXISTS(p_item_source_ids(i))) THEN

      g_exchange_punchout_map(p_item_source_ids(i)) := p_new_zone_ids(i);
      l_err_loc := 600;

      IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'For exchange item source '||p_item_source_ids(i)||
          ', new content zone ID = '||p_new_zone_ids(i));
      END IF;

    END IF;

  END LOOP;

  -- log out all the new zones created
  IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FOR i IN 1..p_new_zone_ids.COUNT LOOP
      FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Zone '||p_new_zone_ids(i)||' created from Item Source '||
        p_item_source_ids(i)||' with security flag ='||p_security_flags(i));
    END LOOP;
  END IF;

  l_err_loc := 700;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name, 'End(Generic)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_CNTNT_SCRTY_UPG_PVT.create_item_source_zones('
     || l_err_loc || '), ' || SQLERRM);

END create_item_source_zones;


-- Currently, for downloaded punchout catalogs from Exchange, a link is
-- maintained via the "operator_id."  To properly upgrade these catalogs,
-- when creating the corresponding content zones, a mapping must be maintained
-- such that these old "opeartor_id"s are mapped to the new "parent_zone_ids"
-- (which reflect the new R12 content zone IDs) for R12.
--
-- This way of updating exchange punchouts after-the-fact may not be ideal.
-- However, since the order of content zone upgrade for item sources (nor
-- for that fact local catalogs) is not guaranteed, this avoids complicated
-- logic of (1) pre-storing the new IDs for exchange catalogs that have
-- corresponding downloaded punchouts or (2) having to enforce an order
-- of which item source catalogs are migrated so that exchange item sources
-- are created before all downloaded punchouts (which may prove difficult
-- in the existing context of migrating store security, realms, etc).
--
-- Hence, this method MUST be called in all code paths that require
-- upgrading of item source catalogs from pre-R12.
--
PROCEDURE update_exchange_punchouts
IS
  l_old_operator_ids ICX_TBL_NUMBER;
  l_new_parent_ids ICX_TBL_NUMBER;

  l_api_name CONSTANT VARCHAR2(30) := 'update_exchange_punchouts';
  l_err_loc PLS_INTEGER;
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, 'Start');
  END IF;

  l_err_loc := 0;

  -- retrieve all the operator_id values that must be updated
  SELECT distinct operator_id
  BULK COLLECT INTO l_old_operator_ids
  FROM icx_por_item_sources
  WHERE operator_id IS NOT NULL;
  l_err_loc := 100;

  -- create a list of the new zones IDs which will replace old operator IDs
  l_new_parent_ids := ICX_TBL_NUMBER();
  l_new_parent_ids.extend(l_old_operator_ids.COUNT);
  l_err_loc := 200;

  -- populate the list from mapping created when creating the content zones
  FOR i IN 1..l_old_operator_ids.COUNT LOOP

    IF ((g_exchange_punchout_map.EXISTS(l_old_operator_ids(i))) AND
        (g_exchange_punchout_map(l_old_operator_ids(i)) <> -999)) THEN

      l_new_parent_ids(i) := g_exchange_punchout_map(l_old_operator_ids(i));
      l_err_loc := 300;

    ELSE

      -- this shouldn't happen (bad data), so log out an exception and continue
      IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'Could not find a mapping for the old operator ID = '||
            l_old_operator_ids(i));
      END IF;
      l_err_loc := 400;

    END IF;

  END LOOP;

  -- now update all the downloaded punchout zones with the new zone IDs
  FORALL i IN 1..l_old_operator_ids.COUNT
    UPDATE icx_cat_punchout_zone_details
    SET parent_zone_id = l_new_parent_ids(i)
    WHERE parent_zone_id = l_old_operator_ids(i);
  l_err_loc := 200;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name, 'End');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_CNTNT_SCRTY_UPG_PVT.update_exchange_punchouts('
     || l_err_loc || '), ' || SQLERRM);

END update_exchange_punchouts;


-- SECURING CONTENT ZONE HELPER METHODS
---------------------------------------

-- Secures the given content zones with the same Operating Unit
-- restrictions as the old pre-R12 stores.  This is done, like many
-- methods in this package with 1:1 correspondence.  At each index,
-- the content zone at that index will be secured with the same
-- operating unit restrictions as the old store at that index.
--
-- @param p_zone_ids List of new content zones to be secured.
-- @param p_old_store_ids List of the corresponding stores to which to draw
--                        the OU restrictions from.  These restrictions will
--                        be transferred to the new content zone (as these
--                        restrictions have been moved from the store-level to
--                        the content zone level for R12.
-- @param p_security_flags Representing what type of security restrictions
--                         were on the old store.  Only "Operating Unit"-level
--                         security is required.  "All Users" security does
--                         not require adding any relationships (is skipped).
--
PROCEDURE secure_zones_by_store_orgs
(
  p_new_zone_ids IN ICX_TBL_NUMBER,
  p_old_store_ids IN ICX_TBL_NUMBER,
  p_security_flags IN ICX_TBL_VARCHAR20
)
IS
  l_api_name CONSTANT VARCHAR2(30) := 'secure_zones_by_store_orgs';
  l_err_loc PLS_INTEGER;
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, 'Start');
  END IF;

  l_err_loc := 0;

  -- secure the content zones with the orgs that were set on the old stores
  FORALL i IN 1..p_new_zone_ids.COUNT
    INSERT INTO icx_cat_secure_contents
    (content_id, org_id, secure_by, created_by, creation_date, last_updated_by,
     last_update_date, last_update_login)
    SELECT p_new_zone_ids(i), oa.org_id, 'OPERATING_UNIT', fnd_global.user_id,
           sysdate, fnd_global.user_id, sysdate, fnd_global.login_id
    FROM icx_cat_store_org_assignments oa
    WHERE p_old_store_ids(i) IS NOT NULL
      AND oa.store_id = p_old_store_ids(i)
      AND p_security_flags(i) = 'OU_SECURED';

  -- note how many pairs secured
  IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
      ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
      'Securing Zones by Operating Units, p_new_zone_ids.COUNT='
      ||p_new_zone_ids.COUNT);
  END IF;

  -- for statement-level logging, print out all tuples
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FOR i IN 1..p_new_zone_ids.COUNT LOOP
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Zone '||p_new_zone_ids(i)||' secured by OUs from Store '||
        p_old_store_ids(i)||' with security flag='||p_security_flags(i));
    END LOOP;
  END IF;

  l_err_loc := 100;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name, 'End');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_CNTNT_SCRTY_UPG_PVT.secure_zones_by_store_orgs('
     || l_err_loc || '), ' || SQLERRM);

END secure_zones_by_store_orgs;


-- Secures the given content zones by the given responsibilities.  At each
-- index, the content zone is secured by the given responsibility (1:1).
-- This method is used when securing multiple content zones to the
-- multiple responsibilities that have realms.
--
-- @param p_zone_ids List of new content zones to be secured.
-- @param p_resp_ids List of the corresponding responsibilities to secure by.
--
PROCEDURE secure_zones_by_resps
(
  p_new_zone_ids IN ICX_TBL_NUMBER,
  p_resp_ids IN ICX_TBL_NUMBER
)
IS
  l_api_name CONSTANT VARCHAR2(30) := 'secure_zones_by_resps';
  l_err_loc PLS_INTEGER;
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, 'Start');
  END IF;

  l_err_loc := 0;

  FORALL i IN 1..p_resp_ids.COUNT
    INSERT INTO icx_cat_secure_contents
    (content_id, responsibility_id, secure_by, created_by, creation_date,
     last_updated_by, last_update_date, last_update_login)
    SELECT p_new_zone_ids(i), p_resp_ids(i), 'RESPONSIBILITY',
           fnd_global.user_id, sysdate, fnd_global.user_id, sysdate,
           fnd_global.login_id
    FROM dual;

  -- note how many pairs secured
  IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
      ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
      'Securing Zones by Responsibilities, p_new_zone_ids.COUNT='
      ||p_new_zone_ids.COUNT);
  END IF;

  -- for statement-level logging, print out all pairs
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FOR i IN 1..p_new_zone_ids.COUNT LOOP
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Zone '||p_new_zone_ids(i)||' secured by resp '||p_resp_ids(i));
    END LOOP;
  END IF;

  l_err_loc := 100;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name, 'End');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_CNTNT_SCRTY_UPG_PVT.secure_zones_by_resps('
     || l_err_loc || '), ' || SQLERRM);

END secure_zones_by_resps;


-- Secures one given content zone by ALL the given responsibilities.
-- This method leverages the generic method by simply duplicating
-- the same new zone ID multiple times, and then calling that generic method.
--
-- @param p_zone_id The new content zone to be secured.
-- @param p_resp_ids List of the responsibilities to secure the zone by.
--
PROCEDURE secure_zone_by_resps
(
  p_new_zone_id IN NUMBER,
  p_resp_ids IN ICX_TBL_NUMBER
)
IS
  l_new_zone_ids ICX_TBL_NUMBER;
  l_api_name CONSTANT VARCHAR2(30) := 'secure_zone_by_resps';
  l_err_loc PLS_INTEGER;
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name,
      'p_new_zone_id='||p_new_zone_id||',p_resp_ids.COUNT='||p_resp_ids.COUNT);
  END IF;

  l_err_loc := 0;

  l_new_zone_ids := ICX_TBL_NUMBER();
  l_new_zone_ids.extend(p_resp_ids.COUNT);

  l_err_loc := 100;

  FOR i IN 1..p_resp_ids.COUNT LOOP
    l_new_zone_ids(i) := p_new_zone_id;
  END LOOP;

  l_err_loc := 200;

  -- after populating the zones lists, leverage the generic method
  secure_zones_by_resps(l_new_zone_ids, p_resp_ids);

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name, 'End');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_CNTNT_SCRTY_UPG_PVT.secure_zone_by_resps('
     || l_err_loc || '), ' || SQLERRM);

END secure_zone_by_resps;


-- RESPONSIBILITY AND REALMS HELPER METHODS
--------------------------------------------

-- Returns a map of item sources to the responsibilities that can access
-- them via Item Source Realms.
--
-- NOTE:  This requires that g_resp_with_isrc_realms global variable be
--        populated.  This is done via populate_resp_with_isrc_realms().
--
PROCEDURE populate_isrcs_to_resp_map
IS
  l_item_source_ids ICX_TBL_NUMBER;
  l_resp_list_ids ICX_TBL_NUMBER;

  l_api_name CONSTANT VARCHAR2(30) := 'populate_isrcs_to_resp_map';
  l_err_loc PLS_INTEGER;
  l_isrc_key NUMBER;
BEGIN

  l_err_loc := 0;

  -- first, initializing the mapping by clearing out all the elements;
  -- NOTE:  this initialization was moved to the initialize method

  FOR i in 1..g_resp_with_isrc_realms.COUNT LOOP

    l_item_source_ids := get_realm_values_for_resp(g_resp_with_isrc_realms(i),
                                                   'ICX_POR_ITEM_SOURCE_ID');

    l_err_loc := 100;

    FOR j in 1..l_item_source_ids.COUNT LOOP

      IF (g_item_sources_to_resp_map.EXISTS(l_item_source_ids(j))) THEN

        l_resp_list_ids := g_item_sources_to_resp_map(l_item_source_ids(j));
        l_err_loc := 200;

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Found existing list for Item Source '||l_item_source_ids(j));
        END IF;

      ELSE

        l_resp_list_ids := ICX_TBL_NUMBER();
        l_err_loc := 300;

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'A new list created for Item Source '||l_item_source_ids(j));
        END IF;

      END IF;

      l_resp_list_ids.extend;
      l_resp_list_ids(l_resp_list_ids.count) := g_resp_with_isrc_realms(i);
      g_item_sources_to_resp_map(l_item_source_ids(j)) := l_resp_list_ids;

      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'Appending resp '||g_resp_with_isrc_realms(i));
      END IF;

      l_err_loc := 400;

    END LOOP;

  END LOOP;

  -- note the final structure constructed
  IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

    l_isrc_key := g_item_sources_to_resp_map.FIRST();

    WHILE (l_isrc_key IS NOT NULL) LOOP

      l_resp_list_ids := g_item_sources_to_resp_map(l_isrc_key);

      FOR i IN 1..l_resp_list_ids.COUNT LOOP
        FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'Item Source '||l_isrc_key||' accessible via realms to resp '||
          l_resp_list_ids(i));
      END LOOP;

      l_isrc_key := g_item_sources_to_resp_map.NEXT(l_isrc_key);

    END LOOP;

  END IF;

  l_err_loc := 500;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_CNTNT_SCRTY_UPG_PVT.get_item_sources_to_resp_map('
     || l_err_loc || '), ' || SQLERRM);

END populate_isrcs_to_resp_map;


-- Returns a list of the securing attribute (realms) values for the
-- 'RT_CATEGORY_ID' securing attribute.  This method will catch globally
-- the categories that responsibilities can access, as this may be queried
-- many times during migration.
--
-- Values are stored globally in g_resp_to_categories_map.  If no values
-- are found there, then get_realm_values_for_resp() is used to query for them.
--
-- @param IN The responsibility whose realms values are desired.
--
-- @return The list of realms values for this responsibility and realm type.
--
FUNCTION get_catr_realm_values_cached
(
  p_resp_id IN NUMBER
)
RETURN ICX_TBL_NUMBER
IS
  l_realm_values ICX_TBL_NUMBER;
  l_api_name CONSTANT VARCHAR2(30) := 'get_catr_realm_values_cached';
  l_err_loc PLS_INTEGER;
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name,
      'p_resp_id='||p_resp_id);
  END IF;

  l_err_loc := 0;

  IF (g_resp_to_categories_map.EXISTS(p_resp_id)) THEN

    l_realm_values := g_resp_to_categories_map(p_resp_id);
    l_err_loc := 100;

    -- for statement-level logging, note that the values were cached
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Category realm values for resp '||p_resp_id||
          ' was already queried, returning cached values.');
    END IF;

  ELSE

    -- query up the values
    l_realm_values := get_realm_values_for_resp(p_resp_id, 'RT_CATEGORY_ID');
    l_err_loc := 200;

    -- store them for future reference
    g_resp_to_categories_map(p_resp_id) := l_realm_values;
    l_err_loc := 300;

  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name, 'End');
  END IF;

  RETURN l_realm_values;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_CNTNT_SCRTY_UPG_PVT.get_catr_realm_values_cached('
     || l_err_loc || '), ' || SQLERRM);

END get_catr_realm_values_cached;


-- Returns a list of the securing attribute (realms) values
-- based on the given realm type for the given responsibility.
--
-- @param IN The responsibility whose realms values are desired.
-- @param IN The realm type for which realms values are desired:
--           (1) RT_CATEGORY_ID
--           (2) ICX_POR_ITEM_SOURCE_ID
--
-- @return The list of realms values for this responsibility and realm type.
--
FUNCTION get_realm_values_for_resp
(
  p_resp_id IN NUMBER,
  p_realm_type IN VARCHAR2
)
RETURN ICX_TBL_NUMBER
IS
  l_realm_values ICX_TBL_NUMBER;
  l_api_name CONSTANT VARCHAR2(30) := 'get_realm_values_for_resp';
  l_err_loc PLS_INTEGER;
BEGIN

  l_err_loc := 0;

  SELECT akrsav.number_value as realm_value
  BULK COLLECT INTO l_realm_values
  FROM ak_resp_security_attr_values akrsav
  WHERE akrsav.responsibility_id = p_resp_id
    AND akrsav.attribute_application_id = 178
    AND akrsav.attribute_code = p_realm_type
    AND akrsav.number_value IS NOT NULL

  UNION ALL

  SELECT realmcomps.realm_component_value as realm_value
  FROM ak_resp_security_attr_values akrsav,
       icx_por_realms realms, icx_por_realm_components realmcomps
  WHERE akrsav.responsibility_id = p_resp_id
    AND akrsav.attribute_code = 'ICX_POR_REALM_ID'
    AND akrsav.attribute_application_id = 178
    AND akrsav.number_value = realms.realm_id
    AND realms.ak_attribute_code = p_realm_type
    AND realms.realm_id = realmcomps.realm_id
    AND realmcomps.realm_component_value IS NOT NULL;

  -- note how many realm values were found
  IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
      ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
      p_realm_type||' realm values for resp '||p_resp_id||', count = '||
      l_realm_values.COUNT);
  END IF;

  l_err_loc := 100;

  -- for statement-level logging, log all values
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FOR i IN 1..l_realm_values.COUNT LOOP
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        i||'.'||l_realm_values(i));
    END LOOP;
  END IF;

  RETURN l_realm_values;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_CNTNT_SCRTY_UPG_PVT.get_realm_values_for_resp('
     || l_err_loc || '), ' || SQLERRM);

END get_realm_values_for_resp;


-- From a given list of responsbilities with realms, this method creates a new
-- list that minus those responsibilities that do not have any CATEGORY realm
-- values.  This is useful when a responsibility has category realms enabled,
-- but no actual categories are tied to this responsibility.  In this case,
-- this responsibility can be skipped when migrating local content as
-- no local content zone should be created, as no categories are accessible.
--
-- @param IN The list of responsibilities with realms.
--
-- @return List of responsibilities with realms and have categories values.
--
FUNCTION filter_out_no_category_resps
(
  p_resp_with_realms_ids IN ICX_TBL_NUMBER
)
RETURN ICX_TBL_NUMBER
IS
  l_resp_with_realm_values_ids ICX_TBL_NUMBER;
  l_category_ids ICX_TBL_NUMBER;

  l_api_name CONSTANT VARCHAR2(30) := 'filter_out_no_category_resps';
  l_err_loc PLS_INTEGER;
BEGIN

  l_err_loc := 0;

  -- initialize as BULK COLLECT will always initialize variables, so keep this
  -- consistent so we can check COUNT rather than NULL to determine emptyness
  l_resp_with_realm_values_ids := ICX_TBL_NUMBER();

  FOR i IN 1..p_resp_with_realms_ids.COUNT LOOP

    l_category_ids :=
      get_catr_realm_values_cached(p_resp_with_realms_ids(i));

    l_err_loc := 100;

    IF (l_category_ids.COUNT > 0) THEN

      l_resp_with_realm_values_ids.extend;
      l_resp_with_realm_values_ids(l_resp_with_realm_values_ids.COUNT) :=
        p_resp_with_realms_ids(i);

      l_err_loc := 200;

    END IF;

  END LOOP;

  -- note how many responsibilities without realms were found
  IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
      ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
      'Resps after filtering out those without Category values, count = '||
      l_resp_with_realm_values_ids.COUNT);
  END IF;

  l_err_loc := 300;

  -- for statement-level logging, log all responsibilties
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FOR i IN 1..l_resp_with_realm_values_ids.COUNT LOOP
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        i||'.'||l_resp_with_realm_values_ids(i));
    END LOOP;
  END IF;

  RETURN l_resp_with_realm_values_ids;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_CNTNT_SCRTY_UPG_PVT.filter_out_no_category_resps('
     || l_err_loc || '), ' || SQLERRM);

END filter_out_no_category_resps;


-- LARGE RESPONSIBILITY WITH REALMS QUERIES
-------------------------------------------

-- Returns a list of all responsibilites with the given realm type
-- of realms.
--
-- @param IN The realm type to restrict the list of responsibilities.
-- @return The list of responsibilities with the given realm type.
--
FUNCTION get_all_resps_with_realms
(
  p_realm_type IN VARCHAR2
)
RETURN ICX_TBL_NUMBER
IS
  l_all_resp_with_realms_ids ICX_TBL_NUMBER;
  l_api_name CONSTANT VARCHAR2(30) := 'get_all_resps_with_realms';
  l_err_loc PLS_INTEGER;
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name,
      'p_realm_type='||p_realm_type);
  END IF;

  l_err_loc := 0;

  SELECT distinct resp.responsibility_id
  BULK COLLECT INTO l_all_resp_with_realms_ids
  FROM fnd_responsibility resp, ak_resp_security_attributes arsa
  WHERE resp.application_id IN (177, 178, 201, 396, 426)
    AND resp.responsibility_id = arsa.responsibility_id
    AND arsa.attribute_application_id = 178
    AND (arsa.attribute_code = p_realm_type
          or (arsa.attribute_code = 'ICX_POR_REALM_ID'
                and not exists (
                  select null
                  from ak_resp_security_attr_values akrsav
                  where akrsav.attribute_code = 'ICX_POR_REALM_ID'
                    and akrsav.responsibility_id = arsa.responsibility_id
                    and akrsav.attribute_application_id = 178))
          or (arsa.attribute_code = 'ICX_POR_REALM_ID'
                and exists (
                  select null
                  from ak_resp_security_attr_values akrsav,
                       icx_por_realms realms
                  where akrsav.number_value = realms.realm_id
                    and akrsav.attribute_code = 'ICX_POR_REALM_ID'
                    and realms.ak_attribute_code = p_realm_type
                    and akrsav.responsibility_id = arsa.responsibility_id
                    and akrsav.attribute_application_id = 178)));

  -- note how many responsibilities with realms were found
  IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
      ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
      'All Resps With '||p_realm_type||' Realms, count = '||
      l_all_resp_with_realms_ids.COUNT);
  END IF;

  -- for statement-level logging, log all responsibilties
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FOR i IN 1..l_all_resp_with_realms_ids.COUNT LOOP
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        i||'.'||l_all_resp_with_realms_ids(i));
    END LOOP;
  END IF;

  l_err_loc := 100;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name, 'End');
  END IF;

  RETURN l_all_resp_with_realms_ids;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_CNTNT_SCRTY_UPG_PVT.get_all_resps_with_realms('
     || l_err_loc || '), ' || SQLERRM);

END get_all_resps_with_realms;


-- Returns a list of all responsibilites without the given realm type
-- of realms.
--
-- @param IN The realm type to restrict the list of responsibilities.
-- @return The list of responsibilities without the given realm type.
--
FUNCTION get_all_resps_without_realms
(
  p_realm_type IN VARCHAR2
)
RETURN ICX_TBL_NUMBER
IS
  l_all_resp_without_realms_ids ICX_TBL_NUMBER;
  l_api_name CONSTANT VARCHAR2(30) := 'get_all_resps_without_realms';
  l_err_loc PLS_INTEGER;
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name,
      'p_realm_type='||p_realm_type);
  END IF;

  l_err_loc := 0;

  SELECT distinct resp.RESPONSIBILITY_ID
  BULK COLLECT INTO l_all_resp_without_realms_ids
  FROM FND_RESPONSIBILITY resp
  WHERE resp.application_id IN (177, 178, 201, 396, 426)
    AND NOT EXISTS
      (SELECT 1
       FROM ak_resp_security_attributes arsa
       WHERE arsa.responsibility_id = resp.RESPONSIBILITY_ID
       AND arsa.attribute_application_id = 178
       AND (arsa.attribute_code = p_realm_type
          or (arsa.attribute_code = 'ICX_POR_REALM_ID'
                and not exists (
                  select null
                  from ak_resp_security_attr_values akrsav
                  where akrsav.attribute_code = 'ICX_POR_REALM_ID'
                    and akrsav.responsibility_id = arsa.responsibility_id
                    and akrsav.attribute_application_id = 178))
          or (arsa.attribute_code = 'ICX_POR_REALM_ID'
                and exists (
                  select null
                  from ak_resp_security_attr_values akrsav,
                       icx_por_realms realms
                  where akrsav.number_value = realms.realm_id
                    and akrsav.attribute_code = 'ICX_POR_REALM_ID'
                    and realms.ak_attribute_code = p_realm_type
                    and akrsav.responsibility_id = arsa.responsibility_id
                    and akrsav.attribute_application_id = 178))));

  -- note how many responsibilities without realms were found
  IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
      ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
      'All Resps Without '||p_realm_type||' Realms, count = '||
      l_all_resp_without_realms_ids.COUNT);
  END IF;

  -- for statement-level logging, log all responsibilties
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FOR i IN 1..l_all_resp_without_realms_ids.COUNT LOOP
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        i||'.'||l_all_resp_without_realms_ids(i));
    END LOOP;
  END IF;

  l_err_loc := 100;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name, 'End');
  END IF;

  RETURN l_all_resp_without_realms_ids;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_CNTNT_SCRTY_UPG_PVT.get_all_resps_without_realms('
     || l_err_loc || '), ' || SQLERRM);

END get_all_resps_without_realms;


-- Returns a list of all responsibilites (that via their MO Operating Unit
-- profile that determines which Operating Unit they are tied to) with the
-- given realm type of realms that can access a given old pre-R12 store
-- (that is, through any operating unit restrictions).  If
-- old pre-R12 store is accessible by All Operating Units (-2), then
-- all responsibilities with realms (across all OUs) will be returned.
--
-- @param IN The realm type to restrict the list of responsibilities.
-- @param IN The old pre-R12 store that the responsibilities can access.
-- @return The list of responsibilities with the given realm type,
--         and via their Operating Unit profile, can access the
--         given store (which is secured by Operating Units).
--
FUNCTION get_resps_with_realms_store
(
  p_realm_type IN VARCHAR2,
  p_old_store_id IN NUMBER
)
RETURN ICX_TBL_NUMBER
IS
  l_resp_with_realms_ids ICX_TBL_NUMBER;
  l_api_name CONSTANT VARCHAR2(30) := 'get_resps_with_realms_store';
  l_err_loc PLS_INTEGER;
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name,
      'p_realm_type='||p_realm_type||',p_old_store_id='||p_old_store_id);
  END IF;

  l_err_loc := 0;

  IF ((p_old_store_id IS NULL) OR
      (g_store_security_flags(p_old_store_id) = 'ALL_USERS')) THEN

    IF (p_realm_type = 'RT_CATEGORY_ID') THEN

      l_resp_with_realms_ids := g_resp_with_category_realms; -- all orgs
      l_err_loc := 100;

    ELSE -- IF (p_realm_type = 'ICX_POR_ITEM_SOURCE_ID') THEN

      l_resp_with_realms_ids := g_resp_with_isrc_realms; -- all orgs
      l_err_loc := 200;

    END IF;

  ELSE

    l_err_loc := 300;

    -- get all the responsibilties with realms that can access this store
    SELECT distinct resp.responsibility_id
    BULK COLLECT INTO l_resp_with_realms_ids
    FROM fnd_responsibility resp,
         fnd_profile_option_values resp_profile,
         fnd_profile_option_values app_profile,
         icx_cat_store_org_assignments orgs,
         ak_resp_security_attributes arsa
    WHERE resp.application_id in (177, 178, 201, 396, 426)
      AND app_profile.profile_option_id(+) = g_ou_profile_id
      AND app_profile.level_id(+) = 10002
      AND app_profile.level_value(+) = resp.application_id
      AND resp_profile.profile_option_id(+) = g_ou_profile_id
      AND resp_profile.level_id(+) = 10003
      AND resp_profile.level_value(+) = resp.responsibility_id
      AND nvl(resp_profile.profile_option_value,
            nvl(app_profile.profile_option_value,
                g_site_ou_profile_value)) = orgs.org_id
      AND orgs.store_id = p_old_store_id
      AND arsa.responsibility_id = resp.RESPONSIBILITY_ID
      AND arsa.attribute_application_id = 178
      AND (arsa.attribute_code = p_realm_type
            or (arsa.attribute_code = 'ICX_POR_REALM_ID'
                  and not exists (
                    select null
                    from ak_resp_security_attr_values akrsav
                    where akrsav.attribute_code = 'ICX_POR_REALM_ID'
                      and akrsav.responsibility_id = arsa.responsibility_id
                      and akrsav.attribute_application_id = 178))
            or (arsa.attribute_code = 'ICX_POR_REALM_ID'
                  and exists (
                    select null
                    from ak_resp_security_attr_values akrsav,
                         icx_por_realms realms
                    where akrsav.number_value = realms.realm_id
                      and akrsav.attribute_code = 'ICX_POR_REALM_ID'
                      and realms.ak_attribute_code = p_realm_type
                      and akrsav.responsibility_id = arsa.responsibility_id
                      and akrsav.attribute_application_id = 178)));

    l_err_loc := 400;

    -- for statement-level logging, log all responsibilties
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FOR i IN 1..l_resp_with_realms_ids.COUNT LOOP
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          i||'.'||l_resp_with_realms_ids(i));
      END LOOP;
    END IF;

  END IF;  -- check if it should be all orgs

  -- note how many responsibilities without realms were found
  IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
      ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
      'Resps With '||p_realm_type||' Realms for Store '||p_old_store_id||
      ', count = '||l_resp_with_realms_ids.COUNT);
  END IF;

  l_err_loc := 500;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name, 'End');
  END IF;

  RETURN l_resp_with_realms_ids;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_CNTNT_SCRTY_UPG_PVT.get_resps_with_realms_store('
     || l_err_loc || '), ' || SQLERRM);

END get_resps_with_realms_store;


-- Returns a list of all responsibilites (that via their MO Operating Unit
-- profile that determines which Operating Unit they are tied to) without the
-- given realm type of realms that can access a given old pre-R12 store
-- (that is, through any operating unit restrictions).  If
-- old pre-R12 store is accessible by All Operating Units (-2), then
-- all responsibilities without realms (across all OUs) will be returned.
--
-- @param IN The realm type to restrict the list of responsibilities.
-- @param IN The old pre-R12 store that the responsibilities can access.
-- @return The list of responsibilities without the given realm type,
--         and via their Operating Unit profile, can access the
--         given store (which is secured by Operating Units).
--
FUNCTION get_resps_without_realms_store
(
  p_realm_type IN VARCHAR2,
  p_old_store_id IN NUMBER
)
RETURN ICX_TBL_NUMBER
IS
  l_resp_without_realms_ids ICX_TBL_NUMBER;
  l_api_name CONSTANT VARCHAR2(30) := 'get_resps_without_realms_store';
  l_err_loc PLS_INTEGER;
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name,
      'p_realm_type='||p_realm_type||',p_old_store_id='||p_old_store_id);
  END IF;

  l_err_loc := 0;

  IF ((p_old_store_id IS NULL) OR
      (g_store_security_flags(p_old_store_id) = 'ALL_USERS')) THEN

    IF (p_realm_type = 'RT_CATEGORY_ID') THEN

      l_resp_without_realms_ids := g_resp_without_category_realms; -- all orgs
      l_err_loc := 100;

    ELSE -- IF (p_realm_type = 'ICX_POR_ITEM_SOURCE_ID') THEN

      l_resp_without_realms_ids := g_resp_without_isrc_realms; -- all orgs
      l_err_loc := 200;

    END IF;

  ELSE

    l_err_loc := 300;

    -- get all the responsibilties without realms that can access this store
    SELECT distinct resp.responsibility_id
    BULK COLLECT INTO l_resp_without_realms_ids
    FROM fnd_responsibility resp,
         fnd_profile_option_values resp_profile,
         fnd_profile_option_values app_profile,
         icx_cat_store_org_assignments orgs
    WHERE resp.application_id in (177, 178, 201, 396, 426)
      AND app_profile.profile_option_id(+) = g_ou_profile_id
      AND app_profile.level_id(+) = 10002
      AND app_profile.level_value(+) = resp.application_id
      AND resp_profile.profile_option_id(+) = g_ou_profile_id
      AND resp_profile.level_id(+) = 10003
      AND resp_profile.level_value(+) = resp.responsibility_id
      AND nvl(resp_profile.profile_option_value,
            nvl(app_profile.profile_option_value,
                g_site_ou_profile_value)) = orgs.org_id
      AND orgs.store_id = p_old_store_id
      AND NOT EXISTS
         (SELECT 1
          FROM ak_resp_security_attributes arsa
          WHERE arsa.responsibility_id = resp.RESPONSIBILITY_ID
            AND arsa.attribute_application_id = 178
            AND (arsa.attribute_code = p_realm_type
                  or (arsa.attribute_code = 'ICX_POR_REALM_ID'
                        and not exists (
                          select null
                          from ak_resp_security_attr_values akrsav
                          where akrsav.attribute_code = 'ICX_POR_REALM_ID'
                            and akrsav.responsibility_id = arsa.responsibility_id
                            and akrsav.attribute_application_id = 178))
                  or (arsa.attribute_code = 'ICX_POR_REALM_ID'
                        and exists (
                          select null
                          from ak_resp_security_attr_values akrsav,
                               icx_por_realms realms
                          where akrsav.number_value = realms.realm_id
                            and akrsav.attribute_code = 'ICX_POR_REALM_ID'
                            and realms.ak_attribute_code = p_realm_type
                            and akrsav.responsibility_id = arsa.responsibility_id
                            and akrsav.attribute_application_id = 178))));

    l_err_loc := 400;

      -- for statement-level logging, log all responsibilties
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FOR i IN 1..l_resp_without_realms_ids.COUNT LOOP
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          i||'.'||l_resp_without_realms_ids(i));
      END LOOP;
    END IF;

  END IF;  -- check if it should be all orgs

  -- note how many responsibilities without realms were found
  IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
      ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
      'Resps Without '||p_realm_type||' Realms for Store '||p_old_store_id||
      ', count = '||l_resp_without_realms_ids.COUNT);
  END IF;

  l_err_loc := 500;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name, 'End');
  END IF;

  RETURN l_resp_without_realms_ids;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_CNTNT_SCRTY_UPG_PVT.get_resps_without_realms_store('
     || l_err_loc || '), ' || SQLERRM);

END get_resps_without_realms_store;

END ICX_CAT_CNTNT_SCRTY_UPG_PVT;


/
