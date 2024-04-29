--------------------------------------------------------
--  DDL for Package Body ICX_CAT_POPULATE_MI_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_CAT_POPULATE_MI_PVT" AS
/* $Header: ICXVPPMB.pls 120.8.12010000.14 2014/04/28 06:44:52 aacai ship $*/

--Will have the MI cursors
--for pre-upgrade, upgrade and online populate

--Both will call icx_cat_populate_item_pvt.populatePODocs

-- Constants
G_PKG_NAME                      CONSTANT VARCHAR2(30) :='ICX_CAT_POPULATE_MI_PVT';

g_upgrade_last_run_date         DATE;
g_online_mode                   VARCHAR2(15)    := null;
g_onlineUpdate_mode             VARCHAR2(15)    := 'OnlineUpdate';
g_bulkUpdate_mode               VARCHAR2(15)    := 'BulkUpdate';
g_catgItemUpdate_mode           VARCHAR2(15)    := 'CatgItemUpdate';
g_mtl_category_id               NUMBER;
g_inventory_item_id             NUMBER;
g_organization_id               NUMBER;
g_request_id                    NUMBER;
g_entity_type                   mtl_item_bulkload_recs.entity_type%TYPE;
g_start_rowid                   ROWID;
g_end_rowid                     ROWID;

PROCEDURE openOnlineItemCatgDeleteCursor
(       P_INVENTORY_ITEM_ID     IN      NUMBER  ,
        P_ORGANIZATION_ID       IN      NUMBER
)
IS
  l_api_name            CONSTANT VARCHAR2(30)   := 'openOnlineItemCatgDeleteCursor';
  l_err_loc     	PLS_INTEGER;
  l_masterItem_csr     	ICX_CAT_POPULATE_ITEM_PVT.g_item_csr_type;
BEGIN
  l_err_loc := 100;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Processing cursor:' || l_api_name ||
        ', g_NULL_NUMBER:' || ICX_CAT_UTIL_PVT.g_NULL_NUMBER ||
        ', g_category_set_id:' || ICX_CAT_UTIL_PVT.g_category_set_id ||
        ', P_INVENTORY_ITEM_ID:' || P_INVENTORY_ITEM_ID ||
        ', P_ORGANIZATION_ID:' || P_ORGANIZATION_ID  );
  END IF;

  l_err_loc := 150;
  --First close the cursor
  IF (l_masterItem_csr%ISOPEN) THEN
    l_err_loc := 200;
    CLOSE l_masterItem_csr;
  END IF;

  -- Have a different cursor instead of using the cursor for openOnlineItemChangeCursor
  -- because since the category assignment has deleted, in this case we need to do an
  -- outer join with mtl_item_categories and check if the po_category_id is null
  -- and the row is present in icx_cat_items_ctx_hdrs_tlpm then we need to remove these
  -- items from icx_cat_items_ctx_hdrs_tlp and icx_cat_items_ctx_dtls_tlp

  l_err_loc := 300;
  -- 17076597 changes added un_number and hazard_class
  OPEN l_masterItem_csr FOR
    SELECT /*+ LEADING(doc) */
           doc.*,
           nvl(ic1.rt_category_id, -2) ip_category_id,
           ic1.category_name ip_category_name,
           ctx.inventory_item_id ctx_inventory_item_id,
           ctx.source_type ctx_source_type,
           ctx.item_type ctx_item_type,
           ctx.purchasing_org_id ctx_purchasing_org_id,
           ctx.supplier_id ctx_supplier_id,
           ctx.supplier_site_id ctx_supplier_site_id,
           ctx.supplier_part_num ctx_supplier_part_num,
           ctx.supplier_part_auxid ctx_supplier_part_auxid,
           ctx.ip_category_id ctx_ip_category_id,
           ctx.po_category_id ctx_po_category_id,
           ctx.ip_category_name ctx_ip_category_name,
           -- 17076597 changes
           ctx.un_number ctx_un_number,
           ctx.un_number ctx_hazard_class,

           ROWIDTOCHAR(ctx.rowid) ctx_rowid
    FROM
         (
           SELECT /*+ ROWID(mi) NO_EXPAND use_nl(mitl,mic,catMap) */
                  mi.inventory_item_id inventory_item_id,
                  TO_NUMBER(ICX_CAT_UTIL_PVT.g_NULL_NUMBER) po_line_id,
                  TO_CHAR(ICX_CAT_UTIL_PVT.g_NULL_NUMBER) req_template_name,
                  TO_NUMBER(ICX_CAT_UTIL_PVT.g_NULL_NUMBER) req_template_line_num,
                  NVL(fsp.org_id, -2) org_id,
                  mitl.language,
                  'MASTER_ITEM' source_type,
                  NVL(fsp.org_id, -2) purchasing_org_id,
                  mic.category_id po_category_id,
                  catMap.category_key category_key,
                  mi.internal_order_enabled_flag,
                  mi.purchasing_enabled_flag,
                  mi.outside_operation_flag,
                  muom.unit_of_measure unit_meas_lookup_code,
                  DECODE(mi.purchasing_enabled_flag, 'Y', mi.list_price_per_unit, to_number(null)) unit_price,
                  mi.rfq_required_flag,
                  mitl.description,
                  mitl.long_description,
                  mparams.organization_id,
                  mparams.master_organization_id,
                  pun.un_number,
                  phc.hazard_class

           FROM mtl_system_items_b mi,
                mtl_parameters mparams,
                mtl_system_items_tl mitl,
                mtl_item_categories mic,
                mtl_units_of_measure muom,
                financials_system_params_all fsp,
                icx_por_category_data_sources catMap,
                po_un_numbers pun,
                po_hazard_classes phc

           WHERE mi.inventory_item_id = p_inventory_item_id
           AND mi.organization_id = mparams.organization_id
           AND (mparams.organization_id = p_organization_id
                OR mparams.master_organization_id = p_organization_id)
           AND mi.inventory_item_id = mitl.inventory_item_id
           AND mi.organization_id = mitl.organization_id
           AND mitl.language = mitl.source_lang
           AND mic.inventory_item_id (+) = mi.inventory_item_id
           AND mic.organization_id (+) = mi.organization_id
           AND mic.category_set_id (+) = ICX_CAT_UTIL_PVT.g_category_set_id
           AND muom.uom_code = mi.primary_uom_code
           AND NOT (mi.replenish_to_order_flag = 'Y'
                    AND mi.base_item_id IS NOT NULL
                    AND mi.auto_created_config_flag = 'Y')
           AND mi.organization_id = fsp.inventory_organization_id
           AND catMap.external_source_key (+) = TO_CHAR(mic.category_id)
           AND catMap.external_source (+) = 'Oracle'
           AND mi.UN_NUMBER_ID = pun.un_number_id(+)
           AND mi.HAZARD_CLASS_ID = phc.hazard_class_id(+)

         ) doc,
         icx_cat_categories_tl ic1,
         icx_cat_items_ctx_hdrs_tlp ctx
    WHERE ic1.key (+) = doc.category_key
    AND ic1.type (+) = 2
    AND ic1.language (+) = doc.language
    AND doc.inventory_item_id = ctx.inventory_item_id (+)
    AND doc.po_line_id = ctx.po_line_id (+)
    AND doc.req_template_name = ctx.req_template_name (+)
    AND doc.req_template_line_num = ctx.req_template_line_num (+)
    AND doc.org_id = ctx.org_id (+)
    AND doc.language = ctx.language (+)
    AND doc.source_type = ctx.source_type (+) ;

  l_err_loc := 500;
  populateMIs(l_masterItem_csr, ICX_CAT_UTIL_PVT.g_online_const);

  l_err_loc := 600;
  CLOSE l_masterItem_csr;

  l_err_loc := 700;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END openOnlineItemCatgDeleteCursor;

PROCEDURE openOnlineItemChangeCursor
(       P_INVENTORY_ITEM_ID     IN      NUMBER  ,
        P_ORGANIZATION_ID       IN      NUMBER
)
IS
  l_api_name            CONSTANT VARCHAR2(30)   := 'openOnlineItemChangeCursor';
  l_err_loc     	PLS_INTEGER;
  l_masterItem_csr     	ICX_CAT_POPULATE_ITEM_PVT.g_item_csr_type;
BEGIN
  l_err_loc := 100;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Processing cursor:' || l_api_name ||
        ', g_category_set_id:' || ICX_CAT_UTIL_PVT.g_category_set_id ||
        ', g_NULL_NUMBER:' || ICX_CAT_UTIL_PVT.g_NULL_NUMBER ||
        ', P_INVENTORY_ITEM_ID:' || P_INVENTORY_ITEM_ID ||
        ', P_ORGANIZATION_ID:' || P_ORGANIZATION_ID  );
  END IF;

  l_err_loc := 150;
  --First close the cursor
  IF (l_masterItem_csr%ISOPEN) THEN
    l_err_loc := 200;
    CLOSE l_masterItem_csr;
  END IF;

  -- Need to consider the following
  -- 1. populateItemChange with and without master org flag
  --    Will use one cursor by joining with mtl_parameters and adding the following where clause
  /*
             AND mi.organization_id = mparams.organization_id
             AND mi.inventory_item_id = p_inventory_item_id
             AND (mparams.organization_id = p_organization_id
                  OR mparams.master_organization_id = p_organization_id)
  */

  l_err_loc := 300;
  -- 17076597 changes added un_number and hazard_class
  OPEN l_masterItem_csr FOR
    SELECT /*+ LEADING(doc) */
           doc.*,
           nvl(ic1.rt_category_id, -2) ip_category_id,
           ic1.category_name ip_category_name,
           ctx.inventory_item_id ctx_inventory_item_id,
           ctx.source_type ctx_source_type,
           ctx.item_type ctx_item_type,
           ctx.purchasing_org_id ctx_purchasing_org_id,
           ctx.supplier_id ctx_supplier_id,
           ctx.supplier_site_id ctx_supplier_site_id,
           ctx.supplier_part_num ctx_supplier_part_num,
           ctx.supplier_part_auxid ctx_supplier_part_auxid,
           ctx.ip_category_id ctx_ip_category_id,
           ctx.po_category_id ctx_po_category_id,
           ctx.ip_category_name ctx_ip_category_name,
           ctx.un_number ctx_un_number,
           ctx.hazard_class ctx_hazard_class,

           ROWIDTOCHAR(ctx.rowid) ctx_rowid
    FROM
         (
           SELECT /*+ ROWID(mi) NO_EXPAND use_nl(mitl,mic,catMap) */
                  mi.inventory_item_id inventory_item_id,
                  TO_NUMBER(ICX_CAT_UTIL_PVT.g_NULL_NUMBER) po_line_id,
                  TO_CHAR(ICX_CAT_UTIL_PVT.g_NULL_NUMBER) req_template_name,
                  TO_NUMBER(ICX_CAT_UTIL_PVT.g_NULL_NUMBER) req_template_line_num,
                  NVL(fsp.org_id, -2) org_id,
                  mitl.language,
                  'MASTER_ITEM' source_type,
                  NVL(fsp.org_id, -2) purchasing_org_id,
                  mic.category_id po_category_id,
                  catMap.category_key category_key,
                  mi.internal_order_enabled_flag,
                  mi.purchasing_enabled_flag,
                  mi.outside_operation_flag,
                  muom.unit_of_measure unit_meas_lookup_code,
                  DECODE(mi.purchasing_enabled_flag, 'Y', mi.list_price_per_unit, to_number(null)) unit_price,
                  mi.rfq_required_flag,
                  mitl.description,
                  mitl.long_description,
                  mparams.organization_id,
                  mparams.master_organization_id,
		  pun.un_number,
		  phc.hazard_class

           FROM mtl_system_items_b mi,
                mtl_parameters mparams,
                mtl_system_items_tl mitl,
                mtl_item_categories mic,
                mtl_units_of_measure muom,
                financials_system_params_all fsp,
                icx_por_category_data_sources catMap,
                po_un_numbers pun,
                po_hazard_classes phc
           WHERE mi.inventory_item_id = p_inventory_item_id
           AND mi.organization_id = mparams.organization_id
           AND (mparams.organization_id = p_organization_id
                OR mparams.master_organization_id = p_organization_id)
           AND mi.inventory_item_id = mitl.inventory_item_id
           AND mi.organization_id = mitl.organization_id
           AND mitl.language = mitl.source_lang
           AND mic.inventory_item_id = mi.inventory_item_id
           AND mic.organization_id = mi.organization_id
           AND mic.category_set_id = ICX_CAT_UTIL_PVT.g_category_set_id
           AND muom.uom_code = mi.primary_uom_code
           AND NOT (mi.replenish_to_order_flag = 'Y'
                    AND mi.base_item_id IS NOT NULL
                    AND mi.auto_created_config_flag = 'Y')
           AND mi.organization_id = fsp.inventory_organization_id
           AND catMap.external_source_key (+) = TO_CHAR(mic.category_id)
           AND catMap.external_source (+) = 'Oracle'
           AND mi.UN_NUMBER_ID = pun.un_number_id(+)
           AND mi.HAZARD_CLASS_ID = phc.hazard_class_id(+)
         ) doc,
         icx_cat_categories_tl ic1,
         icx_cat_items_ctx_hdrs_tlp ctx
    WHERE ic1.key (+) = doc.category_key
    AND ic1.type (+) = 2
    AND ic1.language (+) = doc.language
    AND doc.inventory_item_id = ctx.inventory_item_id (+)
    AND doc.po_line_id = ctx.po_line_id (+)
    AND doc.req_template_name = ctx.req_template_name (+)
    AND doc.req_template_line_num = ctx.req_template_line_num (+)
    AND doc.org_id = ctx.org_id (+)
    AND doc.language = ctx.language (+)
    AND doc.source_type = ctx.source_type (+) ;

  l_err_loc := 500;
  populateMIs(l_masterItem_csr, ICX_CAT_UTIL_PVT.g_online_const);

  l_err_loc := 600;
  CLOSE l_masterItem_csr;

  l_err_loc := 700;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END openOnlineItemChangeCursor;

PROCEDURE openBulkItemChangeCursor
(       P_INVENTORY_ITEM_ID     IN      NUMBER          ,
        P_REQUEST_ID            IN      NUMBER          ,
        P_ENTITY_TYPE           IN      VARCHAR2
) IS
  l_api_name            CONSTANT VARCHAR2(30)   := 'openBulkItemChangeCursor';
  l_err_loc     	PLS_INTEGER;
  l_masterItem_csr     	ICX_CAT_POPULATE_ITEM_PVT.g_item_csr_type;
BEGIN
  l_err_loc := 100;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Processing cursor:' || l_api_name ||
        ', g_NULL_NUMBER:' || ICX_CAT_UTIL_PVT.g_NULL_NUMBER ||
        ', g_category_set_id:' || ICX_CAT_UTIL_PVT.g_category_set_id ||
        ', P_INVENTORY_ITEM_ID:' || P_INVENTORY_ITEM_ID ||
        ', P_REQUEST_ID:' || P_REQUEST_ID ||
        ', P_ENTITY_TYPE:' || P_ENTITY_TYPE  );
  END IF;

  l_err_loc := 150;
  --First close the cursor
  IF (l_masterItem_csr%ISOPEN) THEN
    l_err_loc := 200;
    CLOSE l_masterItem_csr;
  END IF;

  -- Need to consider the following
  -- 1. populateBulkItemChange when bulk updation done to item / category
  --    Join with MTL_ITEM_BULKLOAD_RECS to get the changed
  --    inventory_item_id and organization_id for the request_id passed in

  l_err_loc := 300;
  IF   (P_ENTITY_TYPE = 'ITEM') THEN
   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Inside if of  P_ENTITY_TYPE = ITEM');
   END IF;

   -- 17076597 changes added un_number and hazard_class
   OPEN l_masterItem_csr FOR
    SELECT /*+ LEADING(doc) */
           doc.*,
           nvl(ic1.rt_category_id, -2) ip_category_id,
           ic1.category_name ip_category_name,
           ctx.inventory_item_id ctx_inventory_item_id,
           ctx.source_type ctx_source_type,
           ctx.item_type ctx_item_type,
           ctx.purchasing_org_id ctx_purchasing_org_id,
           ctx.supplier_id ctx_supplier_id,
           ctx.supplier_site_id ctx_supplier_site_id,
           ctx.supplier_part_num ctx_supplier_part_num,
           ctx.supplier_part_auxid ctx_supplier_part_auxid,
           ctx.ip_category_id ctx_ip_category_id,
           ctx.po_category_id ctx_po_category_id,
           ctx.ip_category_name ctx_ip_category_name,
           ctx.un_number ctx_un_number,
           ctx.hazard_class ctx_hazard_class,

           ROWIDTOCHAR(ctx.rowid) ctx_rowid
    FROM
         (
           SELECT /*+ ROWID(mi) NO_EXPAND use_nl(mitl,mic,catMap) */
                  DISTINCT mi.inventory_item_id inventory_item_id,
                  TO_NUMBER(ICX_CAT_UTIL_PVT.g_NULL_NUMBER) po_line_id,
                  TO_CHAR(ICX_CAT_UTIL_PVT.g_NULL_NUMBER) req_template_name,
                  TO_NUMBER(ICX_CAT_UTIL_PVT.g_NULL_NUMBER) req_template_line_num,
                  NVL(fsp.org_id, -2) org_id,
                  mitl.language,
                  'MASTER_ITEM' source_type,
                  NVL(fsp.org_id, -2) purchasing_org_id,
                  mic.category_id po_category_id,
                  catMap.category_key category_key,
                  mi.internal_order_enabled_flag,
                  mi.purchasing_enabled_flag,
                  mi.outside_operation_flag,
                  muom.unit_of_measure unit_meas_lookup_code,
                  DECODE(mi.purchasing_enabled_flag, 'Y', mi.list_price_per_unit, to_number(null)) unit_price,
                  mi.rfq_required_flag,
                  mitl.description,
                  mitl.long_description,
                  mparams.organization_id,
                  mparams.master_organization_id,
                  pun.un_number,
                  phc.hazard_class

           FROM mtl_system_items_b mi,
                mtl_parameters mparams,
                mtl_item_bulkload_recs mbulk,
                mtl_system_items_tl mitl,
                mtl_item_categories mic,
                mtl_units_of_measure muom,
                financials_system_params_all fsp,
                icx_por_category_data_sources catMap,
                po_un_numbers pun,
                po_hazard_classes phc
           WHERE mbulk.request_id = p_request_id
           AND mbulk.entity_type = p_entity_type
           AND mbulk.inventory_item_id >= p_inventory_item_id
           AND mbulk.inventory_item_id = mi.inventory_item_id
           AND mparams.organization_id = mi.organization_id
           AND (mbulk.organization_id = mparams.organization_id OR mbulk.organization_id = mparams.master_organization_id)
           AND mi.inventory_item_id = mitl.inventory_item_id
           AND mi.organization_id = mitl.organization_id
           AND mitl.language = mitl.source_lang
           AND mic.inventory_item_id = mi.inventory_item_id
           AND mic.organization_id = mi.organization_id
           AND mic.category_set_id = ICX_CAT_UTIL_PVT.g_category_set_id
           AND muom.uom_code = mi.primary_uom_code
           AND NOT (mi.replenish_to_order_flag = 'Y'
                    AND mi.base_item_id IS NOT NULL
                    AND mi.auto_created_config_flag = 'Y')
           AND mi.organization_id = fsp.inventory_organization_id
           AND catMap.external_source_key (+) = TO_CHAR(mic.category_id)
           AND catMap.external_source (+) = 'Oracle'
	   AND mi.UN_NUMBER_ID = pun.un_number_id(+)
           AND mi.HAZARD_CLASS_ID = phc.hazard_class_id(+)
         ) doc,
         icx_cat_categories_tl ic1,
         icx_cat_items_ctx_hdrs_tlp ctx
    WHERE ic1.key (+) = doc.category_key
    AND ic1.type (+) = 2
    AND ic1.language (+) = doc.language
    AND doc.inventory_item_id = ctx.inventory_item_id (+)
    AND doc.po_line_id = ctx.po_line_id (+)
    AND doc.req_template_name = ctx.req_template_name (+)
    AND doc.req_template_line_num = ctx.req_template_line_num (+)
    AND doc.org_id = ctx.org_id (+)
    AND doc.language = ctx.language (+)
    AND doc.source_type = ctx.source_type (+)
    ORDER by doc.inventory_item_id;

/* Bug 6900901: During item import, when the category set are controlled at
*  master org level, mtl_item_bulkload_recs is only one record corresponding to
*  master org, even if items are imported for all orgs. so, the inventory org is derived
* from master_org using the following condition.
*  mbulk.category_set_id = msets.category_set_id
*  AND msets.control_level = 1    -- Controlled at Master org level
*  AND mbulk.organization_id = mparams.master_organization_id
*  AND mparams.organization_id = mi.organization_id
*  AND mi.organization_id = fsp.inventory_organization_id
*/
  ELSIF (P_ENTITY_TYPE = 'ITEM_CATEGORY') THEN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Inside else of  P_ENTITY_TYPE = ITEM_CATEGORY');
    END IF;

    -- 17076597 changes added un_number and hazard_class
   OPEN l_masterItem_csr FOR
    SELECT * FROM (
     SELECT /*+ LEADING(doc) */
           doc.*,
           nvl(ic1.rt_category_id, -2) ip_category_id,
           ic1.category_name ip_category_name,
           ctx.inventory_item_id ctx_inventory_item_id,
           ctx.source_type ctx_source_type,
           ctx.item_type ctx_item_type,
           ctx.purchasing_org_id ctx_purchasing_org_id,
           ctx.supplier_id ctx_supplier_id,
           ctx.supplier_site_id ctx_supplier_site_id,
           ctx.supplier_part_num ctx_supplier_part_num,
           ctx.supplier_part_auxid ctx_supplier_part_auxid,
           ctx.ip_category_id ctx_ip_category_id,
           ctx.po_category_id ctx_po_category_id,
           ctx.ip_category_name ctx_ip_category_name,
           ctx.un_number ctx_un_number,
           ctx.hazard_class ctx_hazard_class,
           ROWIDTOCHAR(ctx.rowid) ctx_rowid
    FROM
         (
           SELECT /*+ ROWID(mi) NO_EXPAND use_nl(mitl,mic,catMap) */
                  DISTINCT mi.inventory_item_id inventory_item_id,
                  TO_NUMBER(ICX_CAT_UTIL_PVT.g_NULL_NUMBER) po_line_id,
                  TO_CHAR(ICX_CAT_UTIL_PVT.g_NULL_NUMBER) req_template_name,
                  TO_NUMBER(ICX_CAT_UTIL_PVT.g_NULL_NUMBER) req_template_line_num,
                  NVL(fsp.org_id, -2) org_id,
                  mitl.language,
                  'MASTER_ITEM' source_type,
                  NVL(fsp.org_id, -2) purchasing_org_id,
                  mic.category_id po_category_id,
                  catMap.category_key category_key,
                  mi.internal_order_enabled_flag,
                  mi.purchasing_enabled_flag,
                  mi.outside_operation_flag,
                  muom.unit_of_measure unit_meas_lookup_code,
                  DECODE(mi.purchasing_enabled_flag, 'Y', mi.list_price_per_unit, to_number(null)) unit_price,
                  mi.rfq_required_flag,
                  mitl.description,
                  mitl.long_description,
                  mparams.organization_id,
                  mparams.master_organization_id,
                  pun.un_number,
                  phc.hazard_class
           FROM mtl_system_items_b mi,
                mtl_parameters mparams,
                mtl_item_bulkload_recs mbulk,
                mtl_system_items_tl mitl,
                mtl_item_categories mic,
                mtl_units_of_measure muom,
                mtl_category_sets msets,
                financials_system_params_all fsp,
                icx_por_category_data_sources catMap,
                po_un_numbers pun,
                po_hazard_classes phc
           WHERE mbulk.request_id = p_request_id
           AND mbulk.entity_type = p_entity_type
           AND mbulk.inventory_item_id >= p_inventory_item_id
           AND mbulk.inventory_item_id = mi.inventory_item_id
           AND mbulk.category_set_id = msets.category_set_id
           AND msets.control_level = 1    -- Controlled at Master org level
           AND mbulk.organization_id = mparams.master_organization_id
           AND mparams.organization_id = mi.organization_id
           AND mi.inventory_item_id = mitl.inventory_item_id
           AND mi.organization_id = mitl.organization_id
           AND mitl.language = mitl.source_lang
           AND mic.inventory_item_id = mi.inventory_item_id
           AND mic.organization_id = mi.organization_id
           AND mic.category_set_id = ICX_CAT_UTIL_PVT.g_category_set_id
           AND muom.uom_code = mi.primary_uom_code
           AND NOT (mi.replenish_to_order_flag = 'Y'
                    AND mi.base_item_id IS NOT NULL
                    AND mi.auto_created_config_flag = 'Y')
           AND mi.organization_id = fsp.inventory_organization_id
           AND catMap.external_source_key (+) = TO_CHAR(mic.category_id)
           AND catMap.external_source (+) = 'Oracle'
           AND mi.UN_NUMBER_ID = pun.un_number_id(+)
           AND mi.HAZARD_CLASS_ID = phc.hazard_class_id(+)
         ) doc,
         icx_cat_categories_tl ic1,
         icx_cat_items_ctx_hdrs_tlp ctx
    WHERE ic1.key (+) = doc.category_key
    AND ic1.type (+) = 2
    AND ic1.language (+) = doc.language
    AND doc.inventory_item_id = ctx.inventory_item_id (+)
    AND doc.po_line_id = ctx.po_line_id (+)
    AND doc.req_template_name = ctx.req_template_name (+)
    AND doc.req_template_line_num = ctx.req_template_line_num (+)
    AND doc.org_id = ctx.org_id (+)
    AND doc.language = ctx.language (+)
    AND doc.source_type = ctx.source_type (+)
    UNION ALL
    SELECT /*+ LEADING(doc) */
           doc.*,
           nvl(ic1.rt_category_id, -2) ip_category_id,
           ic1.category_name ip_category_name,
           ctx.inventory_item_id ctx_inventory_item_id,
           ctx.source_type ctx_source_type,
           ctx.item_type ctx_item_type,
           ctx.purchasing_org_id ctx_purchasing_org_id,
           ctx.supplier_id ctx_supplier_id,
           ctx.supplier_site_id ctx_supplier_site_id,
           ctx.supplier_part_num ctx_supplier_part_num,
           ctx.supplier_part_auxid ctx_supplier_part_auxid,
           ctx.ip_category_id ctx_ip_category_id,
           ctx.po_category_id ctx_po_category_id,
           ctx.ip_category_name ctx_ip_category_name,
           ctx.un_number ctx_un_number,
           ctx.hazard_class ctx_hazard_class,
           ROWIDTOCHAR(ctx.rowid) ctx_rowid
    FROM
         (
           SELECT /*+ ROWID(mi) NO_EXPAND use_nl(mitl,mic,catMap) */
                  DISTINCT mi.inventory_item_id inventory_item_id,
                  TO_NUMBER(ICX_CAT_UTIL_PVT.g_NULL_NUMBER) po_line_id,
                  TO_CHAR(ICX_CAT_UTIL_PVT.g_NULL_NUMBER) req_template_name,
                  TO_NUMBER(ICX_CAT_UTIL_PVT.g_NULL_NUMBER) req_template_line_num,
                  NVL(fsp.org_id, -2) org_id,
                  mitl.language,
                  'MASTER_ITEM' source_type,
                  NVL(fsp.org_id, -2) purchasing_org_id,
                  mic.category_id po_category_id,
                  catMap.category_key category_key,
                  mi.internal_order_enabled_flag,
                  mi.purchasing_enabled_flag,
                  mi.outside_operation_flag,
                  muom.unit_of_measure unit_meas_lookup_code,
                  DECODE(mi.purchasing_enabled_flag, 'Y', mi.list_price_per_unit, to_number(null)) unit_price,
                  mi.rfq_required_flag,
                  mitl.description,
                  mitl.long_description,
                  mparams.organization_id,
                  mparams.master_organization_id,
                  pun.un_number,
                  phc.hazard_class
           FROM mtl_system_items_b mi,
                mtl_parameters mparams,
                mtl_item_bulkload_recs mbulk,
                mtl_system_items_tl mitl,
                mtl_item_categories mic,
                mtl_units_of_measure muom,
                mtl_category_sets msets,
                financials_system_params_all fsp,
                icx_por_category_data_sources catMap,
                po_un_numbers pun,
                po_hazard_classes phc
           WHERE mbulk.request_id = p_request_id
           AND mbulk.entity_type = p_entity_type
           AND mbulk.inventory_item_id >= p_inventory_item_id
           AND mbulk.inventory_item_id = mi.inventory_item_id
           AND mbulk.category_set_id = msets.category_set_id
           AND msets.control_level =2 -- Controlled at item org level
           AND mbulk.organization_id = mi.organization_id
           AND mi.organization_id = mparams.organization_id
           AND mi.inventory_item_id = mitl.inventory_item_id
           AND mi.organization_id = mitl.organization_id
           AND mitl.language = mitl.source_lang
           AND mic.inventory_item_id = mi.inventory_item_id
           AND mic.organization_id = mi.organization_id
           AND mic.category_set_id = ICX_CAT_UTIL_PVT.g_category_set_id
           AND muom.uom_code = mi.primary_uom_code
           AND NOT (mi.replenish_to_order_flag = 'Y'
                    AND mi.base_item_id IS NOT NULL
                    AND mi.auto_created_config_flag = 'Y')
           AND mi.organization_id = fsp.inventory_organization_id
           AND catMap.external_source_key (+) = TO_CHAR(mic.category_id)
           AND catMap.external_source (+) = 'Oracle'
           AND mi.UN_NUMBER_ID = pun.un_number_id(+)
           AND mi.HAZARD_CLASS_ID = phc.hazard_class_id(+)
         ) doc,
         icx_cat_categories_tl ic1,
         icx_cat_items_ctx_hdrs_tlp ctx
    WHERE ic1.key (+) = doc.category_key
    AND ic1.type (+) = 2
    AND ic1.language (+) = doc.language
    AND doc.inventory_item_id = ctx.inventory_item_id (+)
    AND doc.po_line_id = ctx.po_line_id (+)
    AND doc.req_template_name = ctx.req_template_name (+)
    AND doc.req_template_line_num = ctx.req_template_line_num (+)
    AND doc.org_id = ctx.org_id (+)
    AND doc.language = ctx.language (+)
    AND doc.source_type = ctx.source_type (+)
    ) doc1 ORDER by doc1.inventory_item_id;
  END IF;
  l_err_loc := 500;
  populateMIs(l_masterItem_csr, ICX_CAT_UTIL_PVT.g_online_const);

  l_err_loc := 600;
  CLOSE l_masterItem_csr;

  l_err_loc := 700;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END openBulkItemChangeCursor;

PROCEDURE openCategoryItemsCursor
(       p_mtl_category_id       IN      NUMBER  ,
        p_inventory_item_id     IN      NUMBER
)
IS
  l_api_name            CONSTANT VARCHAR2(30)   := 'openCategoryItemsCursor';
  l_err_loc     	PLS_INTEGER;
  l_masterItem_csr     	ICX_CAT_POPULATE_ITEM_PVT.g_item_csr_type;
BEGIN
  l_err_loc := 100;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Processing cursor:' || l_api_name ||
        ', g_NULL_NUMBER:' || ICX_CAT_UTIL_PVT.g_NULL_NUMBER ||
        ', g_category_set_id:' || ICX_CAT_UTIL_PVT.g_category_set_id ||
        ', P_INVENTORY_ITEM_ID:' || P_INVENTORY_ITEM_ID ||
        ', p_mtl_category_id:' || p_mtl_category_id  );
  END IF;

  l_err_loc := 150;
  --First close the cursor
  IF (l_masterItem_csr%ISOPEN) THEN
    l_err_loc := 200;
    CLOSE l_masterItem_csr;
  END IF;

  l_err_loc := 300;
  -- 17076597 changes added un_number and hazard_class
  OPEN l_masterItem_csr FOR
    SELECT /*+ LEADING(doc) */
           doc.*,
           nvl(ic1.rt_category_id, -2) ip_category_id,
           ic1.category_name ip_category_name,
           ctx.inventory_item_id ctx_inventory_item_id,
           ctx.source_type ctx_source_type,
           ctx.item_type ctx_item_type,
           ctx.purchasing_org_id ctx_purchasing_org_id,
           ctx.supplier_id ctx_supplier_id,
           ctx.supplier_site_id ctx_supplier_site_id,
           ctx.supplier_part_num ctx_supplier_part_num,
           ctx.supplier_part_auxid ctx_supplier_part_auxid,
           ctx.ip_category_id ctx_ip_category_id,
           ctx.po_category_id ctx_po_category_id,
           ctx.ip_category_name ctx_ip_category_name,
           ctx.un_number ctx_un_number,
           ctx.hazard_class ctx_hazard_class,
           ROWIDTOCHAR(ctx.rowid) ctx_rowid
    FROM
         (
           SELECT /*+ ROWID(mi) NO_EXPAND use_nl(mitl,mic,catMap) */
                   mi.inventory_item_id inventory_item_id,
                  TO_NUMBER(ICX_CAT_UTIL_PVT.g_NULL_NUMBER) po_line_id,
                  TO_CHAR(ICX_CAT_UTIL_PVT.g_NULL_NUMBER) req_template_name,
                  TO_NUMBER(ICX_CAT_UTIL_PVT.g_NULL_NUMBER) req_template_line_num,
                  NVL(fsp.org_id, -2) org_id,
                  mitl.language,
                  'MASTER_ITEM' source_type,
                  NVL(fsp.org_id, -2) purchasing_org_id,
                  mic.category_id po_category_id,
                  catMap.category_key category_key,
                  mi.internal_order_enabled_flag,
                  mi.purchasing_enabled_flag,
                  mi.outside_operation_flag,
                  muom.unit_of_measure unit_meas_lookup_code,
                  DECODE(mi.purchasing_enabled_flag, 'Y', mi.list_price_per_unit, to_number(null)) unit_price,
                  mi.rfq_required_flag,
                  mitl.description,
                  mitl.long_description,
                  mparams.organization_id,
                  mparams.master_organization_id,
                  pun.un_number,
                  phc.hazard_class
           FROM mtl_system_items_b mi,
                mtl_parameters mparams,
                mtl_system_items_tl mitl,
                mtl_item_categories mic,
                mtl_units_of_measure muom,
                financials_system_params_all fsp,
                icx_por_category_data_sources catMap,
                po_un_numbers pun,
                po_hazard_classes phc
           WHERE mi.inventory_item_id = mitl.inventory_item_id
           AND mi.organization_id = mparams.organization_id
           AND mi.organization_id = mitl.organization_id
           AND mitl.language = mitl.source_lang
           AND mic.inventory_item_id = mi.inventory_item_id
           AND mic.organization_id = mi.organization_id
           AND mic.category_set_id = ICX_CAT_UTIL_PVT.g_category_set_id
           AND mic.category_id = p_mtl_category_id
           AND mi.inventory_item_id >= p_inventory_item_id
           AND muom.uom_code = mi.primary_uom_code
           AND NOT (mi.replenish_to_order_flag = 'Y'
                    AND mi.base_item_id IS NOT NULL
                    AND mi.auto_created_config_flag = 'Y')
           AND mi.organization_id = fsp.inventory_organization_id
           AND catMap.external_source_key (+) = TO_CHAR(mic.category_id)
           AND catMap.external_source (+) = 'Oracle'
           AND mi.UN_NUMBER_ID = pun.un_number_id(+)
           AND mi.HAZARD_CLASS_ID = phc.hazard_class_id(+)
         ) doc,
         icx_cat_categories_tl ic1,
         icx_cat_items_ctx_hdrs_tlp ctx
    WHERE ic1.key (+) = doc.category_key
    AND ic1.type (+) = 2
    AND ic1.language (+) = doc.language
    AND doc.inventory_item_id = ctx.inventory_item_id (+)
    AND doc.po_line_id = ctx.po_line_id (+)
    AND doc.req_template_name = ctx.req_template_name (+)
    AND doc.req_template_line_num = ctx.req_template_line_num (+)
    AND doc.org_id = ctx.org_id (+)
    AND doc.language = ctx.language (+)
    AND doc.source_type = ctx.source_type (+)
    ORDER by doc.inventory_item_id;

  l_err_loc := 500;
  populateMIs(l_masterItem_csr, ICX_CAT_UTIL_PVT.g_online_const);

  l_err_loc := 600;
  CLOSE l_masterItem_csr;

  l_err_loc := 700;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END openCategoryItemsCursor;

PROCEDURE openR12UpgradeMICursor
IS
  l_api_name            CONSTANT VARCHAR2(30)   := 'openR12UpgradeMICursor';
  l_err_loc     	PLS_INTEGER;
  l_masterItem_csr     	ICX_CAT_POPULATE_ITEM_PVT.g_item_csr_type;
BEGIN
  l_err_loc := 100;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Processing cursor:' || l_api_name ||
        ', g_upgrade_last_run_date:' || g_upgrade_last_run_date ||
        ', g_start_rowid:' || g_start_rowid ||
        ', g_end_rowid:' || g_end_rowid ||
        ', g_category_set_id:' || ICX_CAT_UTIL_PVT.g_category_set_id ||
        ', g_NULL_NUMBER:' || ICX_CAT_UTIL_PVT.g_NULL_NUMBER );
  END IF;

  l_err_loc := 150;
  --First close the cursor
  IF (l_masterItem_csr%ISOPEN) THEN
    l_err_loc := 200;
    CLOSE l_masterItem_csr;
  END IF;

  l_err_loc := 300;
  -- 17076597 changes added un_number and hazard_class
  IF (g_upgrade_last_run_date) IS NULL THEN
    l_err_loc := 400;
    OPEN l_masterItem_csr FOR
      SELECT /*+ LEADING(doc) use_nl(ic1,ctx) */
             doc.*,
             nvl(ic1.rt_category_id, -2) ip_category_id,
             ic1.category_name ip_category_name,
             ctx.inventory_item_id ctx_inventory_item_id,
             ctx.source_type ctx_source_type,
             ctx.item_type ctx_item_type,
             ctx.purchasing_org_id ctx_purchasing_org_id,
             ctx.supplier_id ctx_supplier_id,
             ctx.supplier_site_id ctx_supplier_site_id,
             ctx.supplier_part_num ctx_supplier_part_num,
             ctx.supplier_part_auxid ctx_supplier_part_auxid,
             ctx.ip_category_id ctx_ip_category_id,
             ctx.po_category_id ctx_po_category_id,
             ctx.ip_category_name ctx_ip_category_name,
             ctx.un_number ctx_un_number,
             ctx.hazard_class ctx_hazard_class,
             ROWIDTOCHAR(ctx.rowid) ctx_rowid
      FROM
           (
             SELECT /*+ ROWID(mi)  NO_EXPAND use_nl(mitl,mic,catMap) */
                    mi.inventory_item_id inventory_item_id,
                    TO_NUMBER(ICX_CAT_UTIL_PVT.g_NULL_NUMBER) po_line_id,
                    TO_CHAR(ICX_CAT_UTIL_PVT.g_NULL_NUMBER) req_template_name,
                    TO_NUMBER(ICX_CAT_UTIL_PVT.g_NULL_NUMBER) req_template_line_num,
                    NVL(fsp.org_id, -2) org_id,
                    mitl.language,
                    'MASTER_ITEM' source_type,
                    NVL(fsp.org_id, -2) purchasing_org_id,
                    mic.category_id po_category_id,
                    catMap.category_key category_key,
                    mi.internal_order_enabled_flag,
                    mi.purchasing_enabled_flag,
                    mi.outside_operation_flag,
                    muom.unit_of_measure unit_meas_lookup_code,
                    DECODE(mi.purchasing_enabled_flag, 'Y', mi.list_price_per_unit, to_number(null)) unit_price,
                    mi.rfq_required_flag,
                    mitl.description,
                    mitl.long_description,
                    mparams.organization_id,
                    mparams.master_organization_id,
                    pun.un_number,
                    phc.hazard_class
             FROM mtl_system_items_b mi,
                  mtl_parameters mparams,
                  mtl_system_items_tl mitl,
                  mtl_item_categories mic,
                  mtl_units_of_measure muom,
                  financials_system_params_all fsp,
                  icx_por_category_data_sources catMap,
                  po_un_numbers pun,
                  po_hazard_classes phc
             WHERE mi.inventory_item_id = mitl.inventory_item_id
             AND mi.organization_id = mparams.organization_id
             AND mi.organization_id = mitl.organization_id
             AND mitl.language = mitl.source_lang
             AND mic.inventory_item_id = mi.inventory_item_id
             AND mic.organization_id = mi.organization_id
             AND mic.category_set_id = ICX_CAT_UTIL_PVT.g_category_set_id
             AND muom.uom_code = mi.primary_uom_code
             AND NOT (mi.replenish_to_order_flag = 'Y'
                      AND mi.base_item_id IS NOT NULL
                      AND mi.auto_created_config_flag = 'Y')
             AND mi.organization_id = fsp.inventory_organization_id
             AND catMap.external_source_key (+) = TO_CHAR(mic.category_id)
             AND catMap.external_source (+) = 'Oracle'
             AND mi.UN_NUMBER_ID = pun.un_number_id(+)
             AND mi.HAZARD_CLASS_ID = phc.hazard_class_id(+)
             AND mi.rowid BETWEEN g_start_rowid and g_end_rowid
           ) doc,
           icx_cat_categories_tl ic1,
           icx_cat_items_ctx_hdrs_tlp ctx
      WHERE ic1.key (+) = doc.category_key
      AND ic1.type (+) = 2
      AND ic1.language (+) = doc.language
      AND doc.inventory_item_id = ctx.inventory_item_id (+)
      AND doc.po_line_id = ctx.po_line_id (+)
      AND doc.req_template_name = ctx.req_template_name (+)
      AND doc.req_template_line_num = ctx.req_template_line_num (+)
      AND doc.org_id = ctx.org_id (+)
      AND doc.language = ctx.language (+)
      AND doc.source_type = ctx.source_type (+);
  ELSE
    l_err_loc := 500;
    OPEN l_masterItem_csr FOR
      SELECT /*+ LEADING(doc) use_nl(ic1,ctx) */
             doc.*,
             nvl(ic1.rt_category_id, -2) ip_category_id,
             ic1.category_name ip_category_name,
             ctx.inventory_item_id ctx_inventory_item_id,
             ctx.source_type ctx_source_type,
             ctx.item_type ctx_item_type,
             ctx.purchasing_org_id ctx_purchasing_org_id,
             ctx.supplier_id ctx_supplier_id,
             ctx.supplier_site_id ctx_supplier_site_id,
             ctx.supplier_part_num ctx_supplier_part_num,
             ctx.supplier_part_auxid ctx_supplier_part_auxid,
             ctx.ip_category_id ctx_ip_category_id,
             ctx.po_category_id ctx_po_category_id,
             ctx.ip_category_name ctx_ip_category_name,
             ctx.un_number ctx_un_number,
             ctx.hazard_class ctx_hazard_class,
             ROWIDTOCHAR(ctx.rowid) ctx_rowid
      FROM
           (
             SELECT /*+ ROWID(mi) NO_EXPAND use_nl(mitl,mic,catMap) */
                    mi.inventory_item_id inventory_item_id,
                    TO_NUMBER(ICX_CAT_UTIL_PVT.g_NULL_NUMBER) po_line_id,
                    TO_CHAR(ICX_CAT_UTIL_PVT.g_NULL_NUMBER) req_template_name,
                    TO_NUMBER(ICX_CAT_UTIL_PVT.g_NULL_NUMBER) req_template_line_num,
                    NVL(fsp.org_id, -2) org_id,
                    mitl.language,
                    'MASTER_ITEM' source_type,
                    NVL(fsp.org_id, -2) purchasing_org_id,
                    mic.category_id po_category_id,
                    catMap.category_key category_key,
                    mi.internal_order_enabled_flag,
                    mi.purchasing_enabled_flag,
                    mi.outside_operation_flag,
                    muom.unit_of_measure unit_meas_lookup_code,
                    DECODE(mi.purchasing_enabled_flag, 'Y', mi.list_price_per_unit, to_number(null)) unit_price,
                    mi.rfq_required_flag,
                    mitl.description,
                    mitl.long_description,
                    mparams.organization_id,
                    mparams.master_organization_id,
                    pun.un_number,
                    phc.hazard_class
             FROM mtl_system_items_b mi,
                  mtl_parameters mparams,
                  mtl_system_items_tl mitl,
                  mtl_item_categories mic,
                  mtl_units_of_measure muom,
                  financials_system_params_all fsp,
                  icx_por_category_data_sources catMap,
                  po_un_numbers pun,
                  po_hazard_classes phc
             WHERE mi.inventory_item_id = mitl.inventory_item_id
             AND mi.organization_id = mparams.organization_id
             AND mi.organization_id = mitl.organization_id
             AND mitl.language = mitl.source_lang
             AND mic.inventory_item_id = mi.inventory_item_id
             AND mic.organization_id = mi.organization_id
             AND mic.category_set_id = ICX_CAT_UTIL_PVT.g_category_set_id
             AND muom.uom_code = mi.primary_uom_code
             AND NOT (mi.replenish_to_order_flag = 'Y'
                      AND mi.base_item_id IS NOT NULL
                      AND mi.auto_created_config_flag = 'Y')
             AND mi.organization_id = fsp.inventory_organization_id
             AND (mi.last_update_date > g_upgrade_last_run_date
                  OR mitl.last_update_date > g_upgrade_last_run_date
                  OR mic.last_update_date > g_upgrade_last_run_date)
             AND catMap.external_source_key (+) = TO_CHAR(mic.category_id)
             AND catMap.external_source (+) = 'Oracle'
             AND mi.UN_NUMBER_ID = pun.un_number_id(+)
             AND mi.HAZARD_CLASS_ID = phc.hazard_class_id(+)
             AND mi.rowid BETWEEN g_start_rowid and g_end_rowid
           ) doc,
           icx_cat_categories_tl ic1,
           icx_cat_items_ctx_hdrs_tlp ctx
      WHERE ic1.key (+) = doc.category_key
      AND ic1.type (+) = 2
      AND ic1.language (+) = doc.language
      AND doc.inventory_item_id = ctx.inventory_item_id (+)
      AND doc.po_line_id = ctx.po_line_id (+)
      AND doc.req_template_name = ctx.req_template_name (+)
      AND doc.req_template_line_num = ctx.req_template_line_num (+)
      AND doc.org_id = ctx.org_id (+)
      AND doc.language = ctx.language (+)
      AND doc.source_type = ctx.source_type (+);
  END IF;

  l_err_loc := 700;
  populateMIs(l_masterItem_csr, ICX_CAT_UTIL_PVT.g_upgrade_const);

  l_err_loc := 800;
  CLOSE l_masterItem_csr;

  l_err_loc := 900;

EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END openR12UpgradeMICursor;

-- p_masterItem_csr, ICX_CAT_UTIL_PVT.g_upgrade_const
PROCEDURE populateMIs
(       p_masterItem_csr        IN      ICX_CAT_POPULATE_ITEM_PVT.g_item_csr_type       ,
        p_current_mode          IN      VARCHAR2
)
IS

  l_api_name                            CONSTANT VARCHAR2(30)   := 'populateMIs';
  l_err_loc                             PLS_INTEGER;
  l_start_inv_item_id	                NUMBER;
  l_err_string                          VARCHAR2(4000);
  l_batch_count                         PLS_INTEGER;
  l_row_count                           PLS_INTEGER;
  l_count                               PLS_INTEGER;
  l_inv_item_status                     PLS_INTEGER;
  l_item_type                           VARCHAR2(8);
  l_current_ctx_item_rec                ICX_CAT_POPULATE_ITEM_PVT.g_ctx_item_rec_type;

  ----- Start of declaring columns selected in the cursor -----
  l_inv_item_id_tbl                     DBMS_SQL.NUMBER_TABLE;
  l_po_line_id_tbl                      DBMS_SQL.NUMBER_TABLE;
  l_req_template_name_tbl               DBMS_SQL.VARCHAR2_TABLE;
  l_req_template_line_num_tbl           DBMS_SQL.NUMBER_TABLE;
  l_org_id_tbl                          DBMS_SQL.NUMBER_TABLE;
  l_language_tbl                        DBMS_SQL.VARCHAR2_TABLE;
  l_source_type_tbl                     DBMS_SQL.VARCHAR2_TABLE;
  l_purchasing_org_id_tbl               DBMS_SQL.NUMBER_TABLE;
  l_po_category_id_tbl                  DBMS_SQL.NUMBER_TABLE;
  l_category_key_tbl                    DBMS_SQL.VARCHAR2_TABLE;
  l_intrnl_order_enbld_flag_tbl         DBMS_SQL.VARCHAR2_TABLE;
  l_purchasing_enabled_flag_tbl         DBMS_SQL.VARCHAR2_TABLE;
  l_outside_operation_flag_tbl          DBMS_SQL.VARCHAR2_TABLE;
  l_ip_category_id_tbl                  DBMS_SQL.NUMBER_TABLE;
  l_ip_category_name_tbl                DBMS_SQL.VARCHAR2_TABLE;
  l_unit_meas_lookup_code_tbl           DBMS_SQL.VARCHAR2_TABLE;
  l_unit_price_tbl                      DBMS_SQL.NUMBER_TABLE;
  l_rfq_required_flag_tbl               DBMS_SQL.VARCHAR2_TABLE;
  l_description_tbl                     DBMS_SQL.VARCHAR2_TABLE;
  --Bug6599217
  l_long_description_tbl                ICX_CAT_POPULATE_MI_PVT.VARCHAR4_TABLE;
  l_organization_id_tbl                 DBMS_SQL.NUMBER_TABLE;
  l_master_organization_id_tbl          DBMS_SQL.NUMBER_TABLE;
  l_ctx_inventory_item_id_tbl           DBMS_SQL.NUMBER_TABLE;
  l_ctx_source_type_tbl                 DBMS_SQL.VARCHAR2_TABLE;
  l_ctx_item_type_tbl                   DBMS_SQL.VARCHAR2_TABLE;
  l_ctx_purchasing_org_id_tbl           DBMS_SQL.NUMBER_TABLE;
  l_ctx_supplier_id_tbl                 DBMS_SQL.NUMBER_TABLE;
  l_ctx_supplier_site_id_tbl            DBMS_SQL.NUMBER_TABLE;
  l_ctx_supplier_part_num_tbl           DBMS_SQL.VARCHAR2_TABLE;
  l_ctx_supplier_part_auxid_tbl         DBMS_SQL.VARCHAR2_TABLE;
  l_ctx_ip_category_id_tbl              DBMS_SQL.NUMBER_TABLE;
  l_ctx_po_category_id_tbl              DBMS_SQL.NUMBER_TABLE;
  l_ctx_ip_category_name_tbl            DBMS_SQL.VARCHAR2_TABLE;
  l_ctx_rowid_tbl                       DBMS_SQL.UROWID_TABLE;

  -- 17076597 changes starts
  l_ctx_un_number_tbl                   DBMS_SQL.VARCHAR2_TABLE;
  l_un_number_tbl                       DBMS_SQL.VARCHAR2_TABLE;
  l_ctx_hazard_class_tbl                DBMS_SQL.VARCHAR2_TABLE;
  l_hazard_class_tbl                    DBMS_SQL.VARCHAR2_TABLE;

  -- 17076597 changes ends

  ------ End of declaring columns selected in the cursor ------

BEGIN
  l_err_loc := 100;
  l_batch_count := 0;
  l_row_count := 0;
  l_count := 0;
  LOOP
    l_err_loc := 200;
    l_inv_item_id_tbl.DELETE;
    l_po_line_id_tbl.DELETE;
    l_req_template_name_tbl.DELETE;
    l_req_template_line_num_tbl.DELETE;
    l_org_id_tbl.DELETE;
    l_language_tbl.DELETE;
    l_source_type_tbl.DELETE;
    l_purchasing_org_id_tbl.DELETE;
    l_po_category_id_tbl.DELETE;
    l_category_key_tbl.DELETE;
    l_intrnl_order_enbld_flag_tbl.DELETE;
    l_purchasing_enabled_flag_tbl.DELETE;
    l_outside_operation_flag_tbl.DELETE;
    l_ip_category_id_tbl.DELETE;
    l_ip_category_name_tbl.DELETE;
    l_unit_meas_lookup_code_tbl.DELETE;
    l_unit_price_tbl.DELETE;
    l_rfq_required_flag_tbl.DELETE;
    l_description_tbl.DELETE;
    l_long_description_tbl.DELETE;
    l_organization_id_tbl.DELETE;
    l_master_organization_id_tbl.DELETE;
    l_ctx_inventory_item_id_tbl.DELETE;
    l_ctx_source_type_tbl.DELETE;
    l_ctx_item_type_tbl.DELETE;
    l_ctx_purchasing_org_id_tbl.DELETE;
    l_ctx_supplier_id_tbl.DELETE;
    l_ctx_supplier_site_id_tbl.DELETE;
    l_ctx_supplier_part_num_tbl.DELETE;
    l_ctx_supplier_part_auxid_tbl.DELETE;
    l_ctx_ip_category_id_tbl.DELETE;
    l_ctx_po_category_id_tbl.DELETE;
    l_ctx_ip_category_name_tbl.DELETE;
    l_ctx_rowid_tbl.DELETE;

   -- 17076597 changes
    l_ctx_un_number_tbl.DELETE;
    l_un_number_tbl.DELETE;
    l_ctx_hazard_class_tbl.DELETE;
    l_hazard_class_tbl.DELETE;

    BEGIN
      l_err_loc := 300;
      FETCH p_masterItem_csr BULK COLLECT INTO
          l_inv_item_id_tbl,
          l_po_line_id_tbl,
          l_req_template_name_tbl,
          l_req_template_line_num_tbl,
          l_org_id_tbl,
          l_language_tbl,
          l_source_type_tbl,
          l_purchasing_org_id_tbl,
          l_po_category_id_tbl,
          l_category_key_tbl,
          l_intrnl_order_enbld_flag_tbl,
          l_purchasing_enabled_flag_tbl,
          l_outside_operation_flag_tbl,
          l_unit_meas_lookup_code_tbl,
          l_unit_price_tbl,
          l_rfq_required_flag_tbl,
          l_description_tbl,
          l_long_description_tbl,
          l_organization_id_tbl,
          l_master_organization_id_tbl,
          l_un_number_tbl,
          l_hazard_class_tbl,
          l_ip_category_id_tbl,
          l_ip_category_name_tbl,
          l_ctx_inventory_item_id_tbl,
          l_ctx_source_type_tbl,
          l_ctx_item_type_tbl,
          l_ctx_purchasing_org_id_tbl,
          l_ctx_supplier_id_tbl,
          l_ctx_supplier_site_id_tbl,
          l_ctx_supplier_part_num_tbl,
          l_ctx_supplier_part_auxid_tbl,
          l_ctx_ip_category_id_tbl,
          l_ctx_po_category_id_tbl,
          l_ctx_ip_category_name_tbl,
          l_ctx_un_number_tbl,
          l_ctx_hazard_class_tbl,
          l_ctx_rowid_tbl
      LIMIT ICX_CAT_UTIL_PVT.g_batch_size;
      l_err_loc := 400;
      EXIT WHEN l_inv_item_id_tbl.COUNT = 0;

      l_err_loc := 500;
      l_batch_count := l_batch_count + 1;

      l_err_loc := 600;
      l_count := l_inv_item_id_tbl.COUNT;
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Num. of rows returned from the cursor:' || l_count);
      END IF;

      --Save the last inventory_item_id processed, so that re-open of cursor will start from the saved id.
      l_start_inv_item_id := l_inv_item_id_tbl(l_count);

      l_row_count := l_row_count + l_count;

      FOR i in 1..l_inv_item_id_tbl.COUNT LOOP
        l_err_loc := 700;
        -- First get the status and item_type of the current inventory item line
        ICX_CAT_POPULATE_STATUS_PVT.getMasterItemStatusAndType
          (l_intrnl_order_enbld_flag_tbl(i), l_outside_operation_flag_tbl(i), l_unit_price_tbl(i),
           l_inv_item_status, l_item_type);
         IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                'l_inv_item_status: ' || l_inv_item_status ||
                'l_item_type :' || l_item_type);
          END IF;
         IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                'Values for Variables in populateMIs ' ||
                'l_inv_item_id: ' ||	l_inv_item_id_tbl(i) ||
                ',l_po_line_id: ' ||	l_po_line_id_tbl(i) ||
                ',l_req_template_name: ' ||	l_req_template_name_tbl(i) ||
                ',l_req_template_line_num: ' ||	l_req_template_line_num_tbl(i) ||
                ',l_org_id: ' ||	l_org_id_tbl(i) ||
                ',l_language: ' ||	l_language_tbl(i) ||
                ',l_source_type: ' ||	l_source_type_tbl(i) ||
                ',l_purchasing_org_id: ' ||	l_purchasing_org_id_tbl(i) ||
                ',l_po_category_id: ' ||	l_po_category_id_tbl(i) ||
                ',l_category_key: ' ||	l_category_key_tbl(i) ||
                ',l_intrnl_order_enbld_flag: ' ||	l_intrnl_order_enbld_flag_tbl(i) ||
                ',l_purchasing_enabled_flag: ' ||	l_purchasing_enabled_flag_tbl(i) ||
                ',l_outside_operation_flag: ' ||	l_outside_operation_flag_tbl(i) ||
                ',l_unit_meas_lookup_code: ' ||	l_unit_meas_lookup_code_tbl(i) ||
                ',l_unit_price: ' ||	l_unit_price_tbl(i) ||
                ',l_rfq_required_flag: ' ||	l_rfq_required_flag_tbl(i) ||
                ',l_description: ' ||	l_description_tbl(i) ||
                ',l_long_description: ' ||	l_long_description_tbl(i) ||
                ',l_organization_id: ' ||	l_organization_id_tbl(i) ||
                ',l_un_number: ' ||	l_un_number_tbl(i) ||
                ',l_hazard_class: ' ||	l_hazard_class_tbl(i) ||
                ',l_master_organization_id: ' ||	l_master_organization_id_tbl(i) ||
                ',l_ip_category_id: ' ||	l_ip_category_id_tbl(i) ||
                ',l_ip_category_name: ' ||	l_ip_category_name_tbl(i) ||
                ',l_ctx_inventory_item_id: ' ||	l_ctx_inventory_item_id_tbl(i) ||
                ',l_ctx_source_type: ' ||	l_ctx_source_type_tbl(i) ||
                ',l_ctx_item_type: ' ||	l_ctx_item_type_tbl(i) ||
                ',l_ctx_purchasing_org_id: ' ||	l_ctx_purchasing_org_id_tbl(i) ||
                ',l_ctx_supplier_id: ' ||	l_ctx_supplier_id_tbl(i) ||
                ',l_ctx_supplier_site_id: ' ||	l_ctx_supplier_site_id_tbl(i) ||
                ',l_ctx_supplier_part_num: ' ||	l_ctx_supplier_part_num_tbl(i) ||
                ',l_ctx_supplier_part_auxid: ' ||	l_ctx_supplier_part_auxid_tbl(i) ||
                ',l_ctx_ip_category_id: ' ||	l_ctx_ip_category_id_tbl(i) ||
                ',l_ctx_po_category_id: ' ||	l_ctx_po_category_id_tbl(i) ||
                ',l_ctx_un_number: ' ||	l_ctx_un_number_tbl(i) ||
                ',l_ctx_hazard_class: ' ||	l_ctx_hazard_class_tbl(i) ||
                ',l_ctx_ip_category_name: ' ||	l_ctx_ip_category_name_tbl(i));
          END IF;



        l_err_loc := 800;
        -- For category assignment delete
        IF (l_po_category_id_tbl(i) IS NULL) THEN
          l_err_loc := 900;
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                'null l_po_category_id:' || l_po_category_id_tbl(i) ||
                'for l_inv_item_id_tbl:' || l_inv_item_id_tbl(i) ||
                ', l_org_id_tbl:' || l_org_id_tbl(i));
          END IF;
          l_inv_item_status := ICX_CAT_POPULATE_STATUS_PVT.INVALID_ITEM_CATG_ASIGNMNT;
        END IF;

        l_err_loc := 1000;
        --BUG 6599217: commented to allow the updations on ctx tables via call processCurrentCtxItemRow(
        IF (--l_ctx_rowid_tbl(i) IS NOT NULL OR
            l_inv_item_status = ICX_CAT_POPULATE_STATUS_PVT.VALID_FOR_POPULATE)
        THEN
          l_err_loc := 1100;
          l_current_ctx_item_rec.inventory_item_id              := l_inv_item_id_tbl(i);
          l_current_ctx_item_rec.po_line_id                     := l_po_line_id_tbl(i);
          l_current_ctx_item_rec.req_template_name              := l_req_template_name_tbl(i);
          l_current_ctx_item_rec.req_template_line_num          := l_req_template_line_num_tbl(i);
          l_current_ctx_item_rec.org_id                         := l_org_id_tbl(i);
          l_current_ctx_item_rec.language                       := l_language_tbl(i);
          l_current_ctx_item_rec.source_type                    := l_source_type_tbl(i);
          l_current_ctx_item_rec.item_type                      := l_item_type;
          l_current_ctx_item_rec.purchasing_org_id              := l_purchasing_org_id_tbl(i);
          l_current_ctx_item_rec.owning_org_id                  := l_org_id_tbl(i);
          l_current_ctx_item_rec.supplier_id                    := TO_NUMBER(ICX_CAT_UTIL_PVT.g_NULL_NUMBER);
          l_current_ctx_item_rec.supplier_part_num              := '##NULL##';
          l_current_ctx_item_rec.supplier_part_auxid            := '##NULL##';
          l_current_ctx_item_rec.supplier_site_id               := TO_NUMBER(ICX_CAT_UTIL_PVT.g_NULL_NUMBER);
          l_current_ctx_item_rec.status                         := l_inv_item_status;
          -- Ignore category changes due to mapping if this was online item update
          -- Honor category changes due to mapping during upgrade, online item category change
          -- and online item create.
          IF (l_ctx_rowid_tbl(i) IS NOT NULL
              AND p_current_mode = ICX_CAT_UTIL_PVT.g_online_const
              AND NOT ICX_CAT_UTIL_PVT.g_ItemCatgChange_const)
          THEN
            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                  ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                  'Not changing the po category and ip category for' ||
                  ', l_inv_item_id_tbl:' || l_inv_item_id_tbl(i) ||
                  ', l_org_id_tbl:' || l_org_id_tbl(i) ||
                  ', l_ctx_rowid_tbl:' || l_ctx_rowid_tbl(i) ||
                  ', p_current_mode:' || p_current_mode );
            END IF;
            l_current_ctx_item_rec.po_category_id                 := l_ctx_po_category_id_tbl(i);
            l_current_ctx_item_rec.ip_category_id                 := l_ctx_ip_category_id_tbl(i);
            l_current_ctx_item_rec.ip_category_name               := l_ctx_ip_category_name_tbl(i);
          ELSE
            l_current_ctx_item_rec.po_category_id                 := l_po_category_id_tbl(i);
            l_current_ctx_item_rec.ip_category_id                 := l_ip_category_id_tbl(i);
            l_current_ctx_item_rec.ip_category_name               := l_ip_category_name_tbl(i);
          END IF;
          l_current_ctx_item_rec.req_template_po_line_id        := NULL;
          l_current_ctx_item_rec.item_revision                  := '-2';
          l_current_ctx_item_rec.po_header_id                   := NULL;
          l_current_ctx_item_rec.document_number                := NULL;
          l_current_ctx_item_rec.line_num                       := NULL;
          l_current_ctx_item_rec.allow_price_override_flag      := NULL;
          l_current_ctx_item_rec.not_to_exceed_price            := NULL;
          l_current_ctx_item_rec.line_type_id                   := NULL;
          l_current_ctx_item_rec.unit_meas_lookup_code          := l_unit_meas_lookup_code_tbl(i);
          l_current_ctx_item_rec.suggested_quantity             := NULL;
          l_current_ctx_item_rec.unit_price                     := l_unit_price_tbl(i);
          l_current_ctx_item_rec.amount                         := NULL;
          l_current_ctx_item_rec.currency_code                  := NULL;
          l_current_ctx_item_rec.rate_type                      := NULL;
          l_current_ctx_item_rec.rate_date                      := NULL;
          l_current_ctx_item_rec.rate                           := NULL;
          l_current_ctx_item_rec.buyer_id                       := NULL;
          l_current_ctx_item_rec.supplier_contact_id            := NULL;
          l_current_ctx_item_rec.rfq_required_flag              := l_rfq_required_flag_tbl(i);
          l_current_ctx_item_rec.negotiated_by_preparer_flag    := 'N';
          l_current_ctx_item_rec.description                    := l_description_tbl(i);
          l_current_ctx_item_rec.long_description               := l_long_description_tbl(i);
          l_current_ctx_item_rec.organization_id                := l_organization_id_tbl(i);
          l_current_ctx_item_rec.master_organization_id         := l_master_organization_id_tbl(i);
          l_current_ctx_item_rec.order_type_lookup_code         := 'QUANTITY';
          l_current_ctx_item_rec.supplier                       := NULL;
          l_current_ctx_item_rec.global_agreement_flag          := 'N';
          l_current_ctx_item_rec.merged_source_type             := 'MASTER_ITEM';
          l_current_ctx_item_rec.ctx_inventory_item_id          := l_ctx_inventory_item_id_tbl(i);
          l_current_ctx_item_rec.ctx_source_type                := l_ctx_source_type_tbl(i);
          l_current_ctx_item_rec.ctx_item_type                  := l_ctx_item_type_tbl(i);
          l_current_ctx_item_rec.ctx_purchasing_org_id          := l_ctx_purchasing_org_id_tbl(i);
          l_current_ctx_item_rec.ctx_supplier_id                := l_ctx_supplier_id_tbl(i);
          l_current_ctx_item_rec.ctx_supplier_site_id           := l_ctx_supplier_site_id_tbl(i);
          l_current_ctx_item_rec.ctx_supplier_part_num          := l_ctx_supplier_part_num_tbl(i);
          l_current_ctx_item_rec.ctx_supplier_part_auxid        := l_ctx_supplier_part_auxid_tbl(i);
          l_current_ctx_item_rec.ctx_ip_category_id             := l_ctx_ip_category_id_tbl(i);
          l_current_ctx_item_rec.ctx_po_category_id             := l_ctx_po_category_id_tbl(i);
          l_current_ctx_item_rec.ctx_rowid                      := l_ctx_rowid_tbl(i);
-- 17076597 changes
          l_current_ctx_item_rec.ctx_un_number                  := l_ctx_un_number_tbl(i);
          l_current_ctx_item_rec.un_number                      := l_un_number_tbl(i);
          l_current_ctx_item_rec.ctx_hazard_class               := l_ctx_hazard_class_tbl(i);
          l_current_ctx_item_rec.hazard_class                   := l_hazard_class_tbl(i);

          l_err_loc := 1200;
          ICX_CAT_POPULATE_ITEM_PVT.processCurrentCtxItemRow(l_current_ctx_item_rec, null, p_current_mode);

          l_err_loc := 1300;
          ICX_CAT_POPULATE_ITEM_PVT.populateItemCtxTables('INLOOP', ICX_CAT_UTIL_PVT.g_MasterItemCsr_const);
        ELSE
          IF (p_current_mode = ICX_CAT_UTIL_PVT.g_upgrade_const) THEN
            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                  ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                  'Row #:' || i ||
                  ', item:( ' || l_inv_item_id_tbl(i) ||
                  ', ' || l_org_id_tbl(i) || '), Not processed' ||
                  ', internal_order_enabled_flag:' || l_intrnl_order_enbld_flag_tbl(i) ||
                  ', purchasing_enabled_flag:' || l_purchasing_enabled_flag_tbl(i) ||
                  ', outside_operation_flag:' || l_outside_operation_flag_tbl(i) ||
                  ', list_price_per_unit:' || l_unit_price_tbl(i) ||
                  ', po_category_id:' || l_po_category_id_tbl(i) ||
                  ', status:' || l_inv_item_status);
            END IF;
          ELSE
            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                  ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                  'Row #:' || i ||
                  ', item:( ' || l_inv_item_id_tbl(i) ||
                  ', ' || l_organization_id_tbl(i) || '), Item is inactive and invalid for purchase, delete from iP tables' ||
                  ', internal_order_enabled_flag:' || l_intrnl_order_enbld_flag_tbl(i) ||
                  ', purchasing_enabled_flag:' || l_purchasing_enabled_flag_tbl(i) ||
                  ', outside_operation_flag:' || l_outside_operation_flag_tbl(i) ||
                  ', list_price_per_unit:' || l_unit_price_tbl(i) ||
                  ', po_category_id:' || l_po_category_id_tbl(i) ||
                  ', status:' || l_inv_item_status);
            END IF;
            populateItemDelete(l_inv_item_id_tbl(i), l_organization_id_tbl(i));   --Bug 7454766  delete item from iP tables.
          END IF;
        END IF;
      END LOOP;  --FOR LOOP of l_inv_item_id_tbl

      l_err_loc := 1400;
      EXIT WHEN l_inv_item_id_tbl.COUNT < ICX_CAT_UTIL_PVT.g_batch_size;
    EXCEPTION
      WHEN ICX_CAT_UTIL_PVT.g_snap_shot_too_old THEN
        l_err_string := 'ICX_CAT_POPULATE_MI_PVT.populateMIs' ||l_err_loc
	                ||', Total processeded batches:' ||l_batch_count
                        ||', Cursor will be reopened with inventory_item_id:' ||l_start_inv_item_id;
        IF (FND_API.To_Boolean(ICX_CAT_UTIL_PVT.g_COMMIT)) THEN
          ICX_CAT_UTIL_PVT.logAndCommitSnapShotTooOld(g_pkg_name, l_api_name, l_err_string);
          --Closing and reopen of cursor will be done by called procedures
          l_err_loc := 1500;
          IF (p_current_mode = ICX_CAT_UTIL_PVT.g_upgrade_const) THEN
            l_err_loc := 1600;
            openR12UpgradeMICursor;
          ELSE
            l_err_loc := 1700;
            IF (g_online_mode = g_bulkUpdate_mode) THEN
              l_err_loc := 1800;
              openBulkItemChangeCursor(l_start_inv_item_id, G_REQUEST_ID, G_ENTITY_TYPE);
            ELSIF (g_online_mode = g_catgItemUpdate_mode) THEN
              l_err_loc := 1800;
              openCategoryItemsCursor(g_mtl_category_id, l_start_inv_item_id);
            ELSE
              l_err_loc := 1900;
              -- Online case should not throw snapshot too old error.
              IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
                    ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                    'Online case throwing snap shot too old error');
              END IF;
            END IF;
          END IF;
        ELSE
          RAISE;
        END IF;
    END;
  END LOOP; --Cursor loop

  l_err_loc := 2000;
  ICX_CAT_POPULATE_ITEM_PVT.populateItemCtxTables('OUTLOOP', ICX_CAT_UTIL_PVT.g_MasterItemCsr_const);

  l_err_loc := 2100;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'populateMIs in mode:'|| p_current_mode ||' done; '||
        'Total num. of batches processed:' ||l_batch_count ||
        ', Total num. of rows processed:' ||l_row_count);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END populateMIs;

PROCEDURE upgradeR12MIs
(       p_upgrade_last_run_date IN      DATE    ,
        p_start_rowid           IN      ROWID   ,
        p_end_rowid             IN      ROWID
)
IS
  l_api_name            CONSTANT VARCHAR2(30)   := 'upgradeR12MIs';
  l_err_loc             PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  g_upgrade_last_run_date := p_upgrade_last_run_date;

  l_err_loc := 200;
  g_start_rowid := p_start_rowid;
  g_end_rowid := p_end_rowid;

  l_err_loc := 300;
  openR12UpgradeMICursor;

  l_err_loc := 400;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    ICX_CAT_UTIL_PVT.g_job_mi_complete_date := NULL;
    ICX_CAT_UTIL_PVT.g_job_complete_date := NULL;
    ICX_CAT_UTIL_PVT.g_job_current_status := ICX_CAT_UTIL_PVT.g_job_failed_status;
    RAISE;
END upgradeR12MIs;

PROCEDURE populateItemChange
(       P_INVENTORY_ITEM_ID             IN      NUMBER                                  ,
        P_ORGANIZATION_ID               IN      NUMBER                                  ,
        P_REQUEST_ID                    IN      NUMBER                                  ,
        P_ENTITY_TYPE                   IN      VARCHAR2
)
IS
  l_api_name    CONSTANT VARCHAR2(30)   := 'populateItemChange';
  l_err_loc     PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  g_inventory_item_id := P_INVENTORY_ITEM_ID;
  g_organization_id := P_ORGANIZATION_ID;
  g_request_id := P_REQUEST_ID;
  g_entity_type := P_ENTITY_TYPE;

  l_err_loc := 300;
  -- Set the batch_size for the online case
  ICX_CAT_UTIL_PVT.setBatchSize;

  l_err_loc := 400;
  ICX_CAT_UTIL_PVT.setWhoColumns(p_request_id);

  l_err_loc := 500;
  -- Initialize the purchasing category set info.
  -- If coming from populateItemCatgChange,
  -- this will already be set in ICX_CAT_POPULATE_MI_GRP.populateItemCategoryChange.
  IF (ICX_CAT_UTIL_PVT.g_category_set_id IS NULL) THEN
    l_err_loc := 600;
    ICX_CAT_UTIL_PVT.getPurchasingCategorySetInfo;
  ELSE
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'Purchasing category set info:' ||
          ', g_category_set_id:' || ICX_CAT_UTIL_PVT.g_category_set_id ||
          ', g_validate_flag:' || ICX_CAT_UTIL_PVT.g_validate_flag ||
          ', g_structure_id:' || ICX_CAT_UTIL_PVT.g_structure_id);
    END IF;
  END IF;

  l_err_loc := 700;
  IF (P_REQUEST_ID IS NULL) THEN
    g_online_mode := g_onlineUpdate_mode;
    l_err_loc := 800;
    openOnlineItemChangeCursor(P_INVENTORY_ITEM_ID, P_ORGANIZATION_ID);
  ELSE
    l_err_loc := 900;
    g_online_mode := g_bulkUpdate_mode;
    l_err_loc := 1000;
    openBulkItemChangeCursor(0, P_REQUEST_ID, P_ENTITY_TYPE);
  END IF;

  l_err_loc := 1100;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END populateItemChange;

PROCEDURE populateItemDelete
(       P_INVENTORY_ITEM_ID             IN      NUMBER                                  ,
        P_ORGANIZATION_ID               IN      NUMBER
)
IS
  CURSOR masterItemsToBeDeletedCsr(P_INVENTORY_ITEM_ID NUMBER,
                                   P_ORGANIZATION_ID NUMBER) IS
    SELECT ctx.inventory_item_id,
           ctx.org_id,
           ctx.language
    FROM icx_cat_items_ctx_hdrs_tlp ctx,
         financials_system_params_all fsp,
         mtl_parameters mparams
    WHERE ctx.inventory_item_id = P_INVENTORY_ITEM_ID
    AND   ctx.source_type = 'MASTER_ITEM'
    AND   (mparams.master_organization_id = P_ORGANIZATION_ID
           OR mparams.organization_id = P_ORGANIZATION_ID)
    AND   fsp.inventory_organization_id = mparams.organization_id
    AND   fsp.org_id = ctx.org_id;

  ----- Start of declaring columns selected in the cursor -----
  l_inv_item_id_tbl             DBMS_SQL.NUMBER_TABLE;
  l_org_id_tbl                  DBMS_SQL.NUMBER_TABLE;
  l_language_tbl                DBMS_SQL.VARCHAR2_TABLE;
  ------ End of declaring columns selected in the cursor ------

  l_api_name            	CONSTANT VARCHAR2(30)   := 'populateItemDelete';
  l_err_loc                     PLS_INTEGER;
  l_batch_count                 PLS_INTEGER;
  l_current_ctx_item_rec        ICX_CAT_POPULATE_ITEM_PVT.g_ctx_item_rec_type;
  l_err_string                  VARCHAR2(4000);

BEGIN
  l_err_loc := 100;
  l_batch_count := 0;

  l_err_loc := 200;
  -- Set the batch_size for the online case
  ICX_CAT_UTIL_PVT.setBatchSize;

  l_err_loc := 300;
  ICX_CAT_UTIL_PVT.setWhoColumns(null);

  l_err_loc := 400;
  OPEN masterItemsToBeDeletedCsr(P_INVENTORY_ITEM_ID, P_ORGANIZATION_ID);

  LOOP
    l_err_loc := 500;
    l_inv_item_id_tbl.DELETE;
    l_org_id_tbl.DELETE;
    l_language_tbl.DELETE;

    BEGIN
      l_err_loc := 600;
      FETCH masterItemsToBeDeletedCsr BULK COLLECT INTO
          l_inv_item_id_tbl, l_org_id_tbl, l_language_tbl
      LIMIT ICX_CAT_UTIL_PVT.g_batch_size;
      l_err_loc := 700;
      EXIT WHEN l_inv_item_id_tbl.COUNT = 0;

      l_err_loc := 800;
      l_batch_count := l_batch_count + 1;

      FOR i in 1..l_inv_item_id_tbl.COUNT LOOP
        l_err_loc := 900;
        l_current_ctx_item_rec.ctx_inventory_item_id          := l_inv_item_id_tbl(i);
        l_current_ctx_item_rec.po_line_id                     := TO_NUMBER(ICX_CAT_UTIL_PVT.g_NULL_NUMBER);
        l_current_ctx_item_rec.req_template_name              := TO_CHAR(ICX_CAT_UTIL_PVT.g_NULL_NUMBER);
        l_current_ctx_item_rec.req_template_line_num          := TO_NUMBER(ICX_CAT_UTIL_PVT.g_NULL_NUMBER);
        l_current_ctx_item_rec.org_id                         := l_org_id_tbl(i);
        l_current_ctx_item_rec.language                       := l_language_tbl(i);

        l_err_loc := 1000;
        ICX_CAT_POPULATE_ITEM_PVT.deleteItemCtxHdrsTLP(l_current_ctx_item_rec);

        l_err_loc := 1100;
        ICX_CAT_POPULATE_ITEM_PVT.deleteItemCtxDtlsTLP(l_current_ctx_item_rec);

        l_err_loc := 1200;
        ICX_CAT_POPULATE_ITEM_PVT.populateItemCtxTables('INLOOP', ICX_CAT_UTIL_PVT.g_MasterItemCsr_const);
      END LOOP;  --FOR LOOP of l_inv_item_id_tbl

      l_err_loc := 1300;
      EXIT WHEN l_inv_item_id_tbl.COUNT < ICX_CAT_UTIL_PVT.g_batch_size;
    EXCEPTION
      WHEN ICX_CAT_UTIL_PVT.g_snap_shot_too_old THEN
        l_err_string := 'ICX_CAT_POPULATE_MI_PVT.populateItemDelete' ||l_err_loc
                        ||', Total processeded batches:' ||l_batch_count
                        ||', Cursor will be reopened;';
        ICX_CAT_UTIL_PVT.logAndCommitSnapShotTooOld(g_pkg_name, l_api_name, l_err_string);
        l_err_loc := 1400;
        IF (masterItemsToBeDeletedCsr%ISOPEN) THEN
          l_err_loc := 1500;
          CLOSE masterItemsToBeDeletedCsr;
          l_err_loc := 1600;
          OPEN masterItemsToBeDeletedCsr(P_INVENTORY_ITEM_ID, P_ORGANIZATION_ID);
        END IF;
    END;
  END LOOP; --Cursor loop

  l_err_loc := 1700;
  ICX_CAT_POPULATE_ITEM_PVT.populateItemCtxTables('OUTLOOP', ICX_CAT_UTIL_PVT.g_MasterItemCsr_const);

  l_err_loc := 1800;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'populateItemDelete done; Total num. of batches processed:' || l_batch_count);
  END IF;

  l_err_loc := 1900;
  IF (masterItemsToBeDeletedCsr%ISOPEN) THEN
    l_err_loc := 2000;
    CLOSE masterItemsToBeDeletedCsr;
  END IF;

  l_err_loc := 2100;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END populateItemDelete;

PROCEDURE populateItemCatgChange
(       P_INVENTORY_ITEM_ID             IN      NUMBER                                  ,
        P_ORGANIZATION_ID               IN      NUMBER                                  ,
        P_CATEGORY_ID                   IN      NUMBER                                  ,
        P_REQUEST_ID                    IN      NUMBER                                  ,
        P_ENTITY_TYPE                   IN      VARCHAR2
)
IS
  l_api_name            CONSTANT VARCHAR2(30)   := 'populateItemCatgChange';
  l_err_loc             PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  -- Call populateItemChange because it internally checks for category change.
  populateItemChange(P_INVENTORY_ITEM_ID, P_ORGANIZATION_ID, P_REQUEST_ID, P_ENTITY_TYPE);
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END populateItemCatgChange;

PROCEDURE populateItemCatgDelete
(       P_INVENTORY_ITEM_ID             IN      NUMBER                                  ,
        P_ORGANIZATION_ID               IN      NUMBER
)
IS
  l_api_name            CONSTANT VARCHAR2(30)   := 'populateItemCatgDelete';
  l_err_loc             PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  g_inventory_item_id := P_INVENTORY_ITEM_ID;
  g_organization_id := P_ORGANIZATION_ID;
  g_online_mode := g_onlineUpdate_mode;

  l_err_loc := 200;
  -- Set the batch_size for the online case
  ICX_CAT_UTIL_PVT.setBatchSize;

  l_err_loc := 300;
  ICX_CAT_UTIL_PVT.setWhoColumns(null);

  l_err_loc := 400;
  openOnlineItemCatgDeleteCursor(P_INVENTORY_ITEM_ID, P_ORGANIZATION_ID);

  l_err_loc := 500;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END populateItemCatgDelete;

PROCEDURE populateCategoryItems
(       P_MTL_CATEGORY_ID_TBL           IN      DBMS_SQL.NUMBER_TABLE
)
IS
  l_api_name            CONSTANT VARCHAR2(30)   := 'populateCategoryItems';
  l_err_loc             PLS_INTEGER;
  l_start_date          DATE;
  l_end_date            DATE;
  l_log_string		VARCHAR2(2000);
BEGIN
  l_err_loc := 100;
  l_start_date := sysdate;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_string := 'Started at:' || TO_CHAR(l_start_date, 'DD-MON-YYYY HH24:MI:SS') ||
                    ', P_MTL_CATEGORY_ID_TBL.COUNT:' || P_MTL_CATEGORY_ID_TBL.COUNT;
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, l_log_string);
  END IF;

  g_online_mode := g_catgItemUpdate_mode;
  FOR i IN 1..P_MTL_CATEGORY_ID_TBL.COUNT LOOP
    g_mtl_category_id := P_MTL_CATEGORY_ID_TBL(i);
    l_err_loc := 200;
    openCategoryItemsCursor(P_MTL_CATEGORY_ID_TBL(i), 0);
  END LOOP;

  l_err_loc := 900;
  l_end_date := sysdate;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name,
       ' done in:' || ICX_CAT_UTIL_PVT.getTimeStats(l_start_date, l_end_date));
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END populateCategoryItems;

PROCEDURE buildCtxSqlForMIs
(       p_special_ctx_sql_tbl           IN OUT NOCOPY   ICX_CAT_BUILD_CTX_SQL_PVT.g_ctx_sql_tbl_type,
        p_regular_ctx_sql_tbl           IN OUT NOCOPY   ICX_CAT_BUILD_CTX_SQL_PVT.g_ctx_sql_tbl_type
)
IS
  l_api_name                    CONSTANT VARCHAR2(30)   := 'buildCtxSqlForMIs';
  l_err_loc                     PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  IF (NOT ICX_CAT_POPULATE_MI_PVT.g_metadataTblFormed) THEN
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'about to call buildmetadatinfo');
    END IF;

    l_err_loc := 200;
    ICX_CAT_BUILD_CTX_SQL_PVT.buildMetadataInfo
           (0, g_special_metadata_tbl, g_regular_nontl_metadata_tbl, g_regular_tl_metadata_tbl);
    l_err_loc := 300;
    ICX_CAT_POPULATE_MI_PVT.g_metadataTblFormed := TRUE;
  END IF;

  l_err_loc := 400;
  IF (NOT ICX_CAT_POPULATE_MI_PVT.g_CtxSqlForMIsFormed) THEN
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'about to call buildctxsql');
    END IF;
    l_err_loc := 500;
    ICX_CAT_BUILD_CTX_SQL_PVT.buildCtxSql
           (0, ICX_CAT_UTIL_PVT.g_MasterItemCsr_const, 'NOTROWID', g_special_metadata_tbl,
            g_regular_nontl_metadata_tbl, g_regular_tl_metadata_tbl,
            g_all_ctx_sql_tbl, g_special_ctx_sql_tbl, g_regular_ctx_sql_tbl);
    l_err_loc := 600;
    ICX_CAT_POPULATE_MI_PVT.g_CtxSqlForMIsFormed := TRUE;
  END IF;

  l_err_loc := 700;
  p_special_ctx_sql_tbl := g_special_ctx_sql_tbl;
  p_regular_ctx_sql_tbl := g_regular_ctx_sql_tbl;

  l_err_loc := 800;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END buildCtxSqlForMIs;

END ICX_CAT_POPULATE_MI_PVT;

/
