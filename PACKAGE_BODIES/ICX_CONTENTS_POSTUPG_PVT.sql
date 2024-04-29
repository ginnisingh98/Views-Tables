--------------------------------------------------------
--  DDL for Package Body ICX_CONTENTS_POSTUPG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_CONTENTS_POSTUPG_PVT" AS
/* $Header: ICXVCPUB.pls 120.1 2008/02/07 09:35:06 krsethur noship $*/

-- GLOBAL VARIABLES
-------------------

-- For logging purposes
g_pkg_name CONSTANT VARCHAR2(30) := 'ICX_CONTENTS_POSTUPG_PVT';

g_categories_per_zone PLS_INTEGER := 150;


-- TOP-LEVEL AUTO_SPLIT METHOD
---------------------------

-- This is the entry method.  This identifies the list of content zones
-- whose sqe sequence is not built due to the column size restriction and
-- splits them into multiple content zones. The following outlines the
-- high-level flow of the method:
--
-- 1. Get local content zones with sqe_sequence not populated due to size
--    restriction
-- 2. For each of the zones, find the category count. Group them into
--    multiple zones with 150 categories each.
-- 3. Create icx_cat_content_zones_b, icx_cat_content_zones_tl for each of
--    these new zones.
-- 4. Duplicate the supplier restrictions from the original zones to the new
--    zones.
-- 5. Create Category restrictions to these new zones.
-- 6. Duplicate the icx_cat_secure_contents to the new zones.
-- 7. Add these zone to all stores with which the original zone was attached.
-- 8. After all the new zones are created, delete the original zones from
--    all the relevant tables.
-- 9. Populate SQEs required for Catalog Search.
--
-- @return  High-level status to indicate success or failure.
--
PROCEDURE auto_split
IS

  l_original_zone_ids ICX_TBL_NUMBER := ICX_TBL_NUMBER();
  l_new_zone_ids ICX_TBL_NUMBER := ICX_TBL_NUMBER();
  l_zone_categories ICX_MAP_TBL_NUMBER;

  l_api_name CONSTANT VARCHAR2(30) := 'auto_split';
  l_err_loc PLS_INTEGER;

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, 'Start');
  END IF;

  l_err_loc := 0;

  SELECT  zone_id
  BULK COLLECT INTO l_original_zone_ids
  FROM icx_cat_content_zones_b
  WHERE type='LOCAL'
    AND category_attribute_action_flag='INCLUDE'
    AND sqe_sequence IS NULL;


  l_err_loc := 100;

  -- If no zones to split, then just return.
  IF(l_original_zone_ids.count = 0) THEN
    return;
  END IF;

  -- Loop through the zones and split
  FOR i IN 1..l_original_zone_ids.Count
  LOOP

    l_new_zone_ids.DELETE;
    l_zone_categories.DELETE;

    l_err_loc := 200;

    get_new_zones_and_categorylist(l_original_zone_ids(i),
      l_new_zone_ids,
      l_zone_categories);

    l_err_loc := 300;

    create_content_zones(l_original_zone_ids(i),
      l_new_zone_ids);

    l_err_loc := 400;

    create_category_restrictions(l_original_zone_ids(i),
      l_new_zone_ids,
      l_zone_categories );

    l_err_loc := 500;

    create_secure_contents(l_original_zone_ids(i),
      l_new_zone_ids);

    l_err_loc := 600;

    add_new_zones_to_stores(l_original_zone_ids(i),
      l_new_zone_ids);

    l_err_loc := 700;

    delete_old_zone(l_original_zone_ids(i));

    l_err_loc := 800;

  END LOOP;

  l_err_loc := 900;

  -- finally, populate corresponding SQEs for search
  ICX_CAT_SQE_PVT.sync_sqes_for_all_zones();
  l_err_loc := 1000;

  commit;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name, 'End');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ' || g_pkg_name || '.' || l_api_name || '(' ||
     l_err_loc || '), ' || SQLERRM);

END auto_split;



PROCEDURE  get_new_zones_and_categorylist(p_original_zone_id IN NUMBER,
  p_new_zone_ids OUT NOCOPY ICX_TBL_NUMBER,
  p_zone_categories OUT NOCOPY ICX_MAP_TBL_NUMBER) IS

  l_category_list ICX_TBL_NUMBER := ICX_TBL_NUMBER();
  l_zone_categories ICX_TBL_NUMBER := ICX_TBL_NUMBER();
  l_no_of_zones_reqd PLS_INTEGER;
  l_api_name CONSTANT VARCHAR2(30) := 'get_new_zones_and_categorylist';
  l_err_loc PLS_INTEGER;
  l_zone_counter PLS_INTEGER := 0;

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, 'Start');
  END IF;

  l_err_loc := 0;

  SELECT ip_category_id
  BULK COLLECT INTO l_category_list
  FROM icx_cat_zone_secure_attributes
  WHERE ZONE_ID=p_original_zone_id
  AND SECURING_ATTRIBUTE= 'CATEGORY';

  l_err_loc := 100;

  l_no_of_zones_reqd := ceil(l_category_list.COUNT / g_categories_per_zone);

  p_new_zone_ids := ICX_CAT_CNTNT_SCRTY_UPG_PVT.get_new_zone_ids(l_no_of_zones_reqd);

  l_err_loc := 200;

  FOR i in 1..l_category_list.COUNT
  LOOP

    l_zone_categories.EXTEND;
    l_zone_categories(l_zone_categories.COUNT) := l_category_list(i);

    IF( (mod(i,g_categories_per_zone) = 0) OR i = l_category_list.COUNT ) THEN
      l_err_loc := 300;
      l_zone_counter := l_zone_counter +1;
      p_zone_categories(p_new_zone_ids(l_zone_counter)) := l_zone_categories;
      l_zone_categories.DELETE;

    END IF;


  END LOOP;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name, 'End');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ' || g_pkg_name || '.' || l_api_name || '(' ||
     l_err_loc || '), ' || SQLERRM);

END get_new_zones_and_categorylist;


PROCEDURE create_content_zones(p_old_zone_id IN NUMBER,
  p_new_zone_ids IN ICX_TBL_NUMBER) IS

  l_api_name CONSTANT VARCHAR2(30) := 'create_content_zones_b';
  l_err_loc PLS_INTEGER;
  l_index_tab ICX_IDX_TBL_NUMBER;

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, 'Start');
  END IF;

  l_err_loc := 0;

  FORALL i IN 1..p_new_zone_ids.COUNT
    INSERT INTO icx_cat_content_zones_b
    (zone_id, type, url, security_assignment_flag,
     category_attribute_action_flag, supplier_attribute_action_flag,
     items_without_supplier_flag, items_without_shop_catg_flag,
     created_by, creation_date, last_updated_by,
     last_update_date, last_update_login)
    SELECT p_new_zone_ids(i), zones.type, zones.url, zones.security_assignment_flag,
           zones.category_attribute_action_flag, zones.supplier_attribute_action_flag,
           zones.items_without_supplier_flag, zones.items_without_shop_catg_flag,
           zones.created_by, zones.creation_date, zones.last_updated_by,
           zones.last_update_date, zones.last_update_login
    FROM icx_cat_content_zones_b zones
    WHERE zones.zone_id = p_old_zone_id;

  l_err_loc := 100;

  FOR i in 1..p_new_zone_ids.COUNT
  LOOP
    l_index_tab(i) := i;
  END LOOP;

  l_err_loc := 200;

  FORALL i IN 1..p_new_zone_ids.COUNT
      INSERT INTO icx_cat_content_zones_tl
      (zone_id, language, source_lang, name, description, keywords, image,
       created_by, creation_date, last_updated_by, last_update_date,
       last_update_login)
      SELECT p_new_zone_ids(i), zones_tl.language, zones_tl.source_lang, zones_tl.name || ' : ' || l_index_tab(i),
       zones_tl.description, zones_tl.keywords, zones_tl.image,
       zones_tl.created_by, zones_tl.creation_date, zones_tl.last_updated_by, zones_tl.last_update_date,
       zones_tl.last_update_login
      FROM icx_cat_content_zones_tl zones_tl
      WHERE zones_tl.zone_id = p_old_zone_id;


  l_err_loc := 300;

  -- migrate over supplier restrictions, if any
    FORALL i IN 1..p_new_zone_ids.COUNT
      INSERT INTO icx_cat_zone_secure_attributes
      (zone_id, securing_attribute, supplier_id, created_by, creation_date,
       last_updated_by, last_update_date, last_update_login)
      SELECT p_new_zone_ids(i), zone_attr.securing_attribute, zone_attr.supplier_id,
        zone_attr.created_by, zone_attr.creation_date,
        zone_attr.last_updated_by, zone_attr.last_update_date, zone_attr.last_update_login
      FROM icx_cat_zone_secure_attributes zone_attr
      WHERE zone_attr.zone_id = p_old_zone_id
      AND  zone_attr.securing_attribute = 'SUPPLIER';

  l_err_loc := 400;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name, 'End');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ' || g_pkg_name || '.' || l_api_name || '(' ||
     l_err_loc || '), ' || SQLERRM);

END create_content_zones;


PROCEDURE create_category_restrictions(p_old_zone_id IN NUMBER,
      p_new_zone_ids IN ICX_TBL_NUMBER ,
      p_zone_categories IN ICX_MAP_TBL_NUMBER ) IS

  l_api_name CONSTANT VARCHAR2(30) := 'create_category_restrictions';
  l_err_loc PLS_INTEGER;

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, 'Start');
  END IF;

  l_err_loc := 0;

  FOR i in 1..p_new_zone_ids.COUNT
  LOOP
    l_err_loc := 100;
    FORALL j in 1..p_zone_categories(p_new_zone_ids(i)).COUNT
      INSERT INTO icx_cat_zone_secure_attributes
      (zone_id, securing_attribute, ip_category_id, created_by, creation_date,
       last_updated_by, last_update_date, last_update_login)
      SELECT p_new_zone_ids(i), 'CATEGORY', p_zone_categories(p_new_zone_ids(i))(j),
        fnd_global.user_id, sysdate, fnd_global.user_id, sysdate,
        fnd_global.login_id
      FROM dual;

  END LOOP;

  l_err_loc := 100;


  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name, 'End');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ' || g_pkg_name || '.' || l_api_name || '(' ||
     l_err_loc || '), ' || SQLERRM);

END create_category_restrictions;


PROCEDURE create_secure_contents(p_old_zone_id IN NUMBER,
      p_new_zone_ids IN ICX_TBL_NUMBER) IS

  l_api_name CONSTANT VARCHAR2(30) := 'create_secure_contents';
  l_err_loc PLS_INTEGER;

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, 'Start');
  END IF;

  l_err_loc := 0;

  FORALL i IN 1..p_new_zone_ids.COUNT
    INSERT INTO icx_cat_secure_contents
    (content_id, org_id, responsibility_id, secure_by, created_by, creation_date,
     last_updated_by, last_update_date, last_update_login)
    SELECT p_new_zone_ids(i), contents.org_id, contents.responsibility_id,
      contents.secure_by, contents.created_by, contents.creation_date,
      contents.last_updated_by, contents.last_update_date, contents.last_update_login
    FROM icx_cat_secure_contents contents
    WHERE contents.content_id = p_old_zone_id;

  l_err_loc := 100;


  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name, 'End');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ' || g_pkg_name || '.' || l_api_name || '(' ||
     l_err_loc || '), ' || SQLERRM);

END create_secure_contents;

PROCEDURE add_new_zones_to_stores(p_old_zone_id IN NUMBER,
      p_new_zone_ids IN ICX_TBL_NUMBER) IS

  l_api_name CONSTANT VARCHAR2(30) := 'add_new_zones_to_stores';
  l_err_loc PLS_INTEGER;

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, 'Start');
  END IF;

  l_err_loc := 0;

  FORALL i IN 1..p_new_zone_ids.COUNT
    INSERT INTO icx_cat_store_contents
    (store_id, content_id, content_type, sequence, display_always_flag,
     created_by, creation_date, last_updated_by, last_update_date,
     last_update_login)
    SELECT sc.store_id, p_new_zone_ids(i), sc.content_type, sc.sequence,
     sc.display_always_flag, sc.created_by, sc.creation_date,
     sc.last_updated_by, sc.last_update_date, sc.last_update_login
    FROM icx_cat_store_contents sc
    WHERE sc.content_id = p_old_zone_id;

  l_err_loc := 100;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name, 'End');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ' || g_pkg_name || '.' || l_api_name || '(' ||
     l_err_loc || '), ' || SQLERRM);

END add_new_zones_to_stores;


PROCEDURE delete_old_zone(p_old_zone_id IN NUMBER) IS

  l_api_name CONSTANT VARCHAR2(30) := 'delete_old_zone';
  l_err_loc PLS_INTEGER;

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, 'Start');
  END IF;

  l_err_loc := 0;

  -- delete from icx_cat_store_contents
  DELETE icx_cat_store_contents
  WHERE content_id = p_old_zone_id;

  l_err_loc := 100;

  -- delete from icx_cat_secure_contents
  DELETE icx_cat_secure_contents
  WHERE content_id = p_old_zone_id;

  l_err_loc := 200;

  -- delete from icx_cat_zone_secure_attributes
  DELETE icx_cat_zone_secure_attributes
  WHERE zone_id=p_old_zone_id;

  l_err_loc := 300;

  -- delete from icx_cat_content_zones_tl
  DELETE icx_cat_content_zones_tl
  WHERE zone_id=p_old_zone_id;

  l_err_loc := 400;

  -- delete from icx_cat_content_zones_b
  DELETE icx_cat_content_zones_b
  WHERE zone_id=p_old_zone_id;

  l_err_loc := 500;


  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name, 'End');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ' || g_pkg_name || '.' || l_api_name || '(' ||
     l_err_loc || '), ' || SQLERRM);

END delete_old_zone;


END ICX_CONTENTS_POSTUPG_PVT;

/
