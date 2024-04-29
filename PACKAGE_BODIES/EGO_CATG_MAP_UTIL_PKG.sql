--------------------------------------------------------
--  DDL for Package Body EGO_CATG_MAP_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_CATG_MAP_UTIL_PKG" AS
/* $Header: EGOUCMB.pls 120.4.12010000.2 2009/02/19 22:46:39 akbharga ship $ */

-- Given a ACC Id, to provide the ACC Id, ACC name
PROCEDURE Get_Alt_Catalog_Ctgr_Mapping
(
    P_GPC_ID  IN NUMBER,
    X_ACC_CATEGORY_ID OUT NOCOPY NUMBER,
    X_ACC_CATALOG_ID OUT NOCOPY NUMBER
)
IS

  --l_category_mapping_id NUMBER;
  l_category_id    mtl_categories_kfv.CATEGORY_ID%TYPE;
/*Bug 7184385, changed cursors to c_get_acc_category_id to get correct mapped target category and category_set id */

/*
 CURSOR c_get_category_mapping_id(cp_category_id NUMBER)
  IS
   SELECT
         catg_map_id, target_catg_id
   FROM EGO_CATG_MAP_DTLS
   WHERE source_catg_id = cp_category_id
   AND ROWNUM = 1;


  CURSOR c_get_catalog_id(cp_catg_map_id NUMBER)
  IS
   SELECT
         target_catg_set_id
   FROM EGO_CATG_MAP_HDRS_B
   WHERE catg_map_id = cp_catg_map_id;*/




CURSOR c_get_acc_category_id(cp_category_id NUMBER)
  IS
   SELECT
         target_catg_id,target_catg_set_id
   FROM EGO_CATG_MAP_DTLS det, EGO_CATG_MAP_HDRS_B hdr
   WHERE det.catg_map_id = hdr.catg_map_id
   AND source_catg_id = cp_category_id
   AND ENABLED_FLAG = 'Y'
   AND ROWNUM = 1;

BEGIN




   /*OPEN c_get_category_mapping_id(cp_category_id => p_gpc_id);
   FETCH c_get_category_mapping_id INTO l_category_mapping_id, x_acc_category_id;
   CLOSE c_get_category_mapping_id;

   OPEN c_get_catalog_id(cp_catg_map_id => l_category_mapping_id);
   FETCH c_get_catalog_id INTO x_acc_catalog_id;
   CLOSE c_get_catalog_id;*/

/*Bug 7184385, changed select to get correct category_id passed a gpc_id */
select mck.category_id into l_category_id
from mtl_categories_kfv mck,
mtl_category_sets mcs,
mtl_default_category_sets_fk_v mdcs
where mdcs.functional_area_id = 21
and mdcs.category_set_id = mcs.category_set_id
and mcs.structure_id = mck.structure_id
and mck.segment2 = to_char(p_gpc_id);




   OPEN c_get_acc_category_id(cp_category_id => l_category_id);
   FETCH c_get_acc_category_id INTO x_acc_category_id, x_acc_catalog_id;
   CLOSE c_get_acc_category_id;


EXCEPTION
  WHEN NO_DATA_FOUND THEN
     x_acc_category_id := NULL;
     x_acc_catalog_id := NULL;

END Get_Alt_Catalog_Ctgr_Mapping;


PROCEDURE Get_Item_Catalog_Ctgr_Mapping
(
   P_GPC_ID  IN VARCHAR2,
   X_ICC_CATEGORY_ID OUT NOCOPY NUMBER
)
IS

  l_category_id    mtl_categories_kfv.CATEGORY_ID%TYPE;

  CURSOR c_get_icc_category_id(cp_category_id NUMBER)
  IS
   SELECT
         target_catg_id
   FROM EGO_CATG_MAP_DTLS det, EGO_CATG_MAP_HDRS_B hdr
   WHERE det.catg_map_id = hdr.catg_map_id
   AND source_catg_id = cp_category_id
   AND target_catg_set_id = -1
   AND ENABLED_FLAG = 'Y'
   AND ROWNUM = 1;

BEGIN

   SELECT CATEGORY_ID
   INTO l_category_id
   FROM mtl_categories_kfv
   WHERE SEGMENT2 = P_GPC_ID
   AND ROWNUM = 1;

   OPEN c_get_icc_category_id(cp_category_id => l_category_id);
   FETCH c_get_icc_category_id INTO x_icc_category_id;
   CLOSE c_get_icc_category_id;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
     x_icc_category_id := NULL;

END Get_Item_Catalog_Ctgr_Mapping;

END EGO_CATG_MAP_UTIL_PKG;

/
