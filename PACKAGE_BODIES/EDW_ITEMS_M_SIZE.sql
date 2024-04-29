--------------------------------------------------------
--  DDL for Package Body EDW_ITEMS_M_SIZE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_ITEMS_M_SIZE" AS
/* $Header: ENIITMSB.pls 115.3 2004/01/30 21:51:47 sbag noship $*/

PROCEDURE cnt_rows(p_from_date DATE,
                   p_to_date DATE,
                   p_num_rows OUT NOCOPY NUMBER) IS

CURSOR c_cnt_rows IS
   select sum(cnt)
   from (
        select count(*) cnt
        from
        mtl_system_items m
        where  m.last_update_date between
        p_from_date and p_to_date ) ;


BEGIN

  OPEN c_cnt_rows;
       FETCH c_cnt_rows INTO p_num_rows;
  CLOSE c_cnt_rows;

EXCEPTION
  WHEN OTHERS THEN
	IF c_cnt_rows%ISOPEN THEN
		CLOSE c_cnt_rows;
	END IF;

END CNT_ROWS;

PROCEDURE est_row_len(p_from_date DATE,
                      p_to_date DATE,
                      p_avg_row_len OUT NOCOPY NUMBER) IS

 x_date                 number := 7;
 x_total                number := 0;
 x_constant             number := 6;

  -- EDW_ITEM_ITEMORG_LCV

  CURSOR c_1 IS
        SELECT
        avg(nvl(vsize(mti.inventory_item_id ||'-'||mti.organization_id ||'-'||inst.instance_code), 0)) +
        avg(nvl(vsize(inst.instance_code), 0)) +
        avg(nvl(vsize(mti.inventory_item_id ||'-'||edw_items_pkg.get_master_parent(mti.organization_id) ||'-'||inst.instance_code), 0)) +
        avg(nvl(vsize('NA_EDW'), 0)) +
        avg(nvl(vsize('NA_EDW'), 0)) +
        avg(nvl(vsize(substr(mti.concatenated_segments ||'('||mtp.organization_code||')',1,240)), 0)) +
        avg(nvl(vsize(substr(mti.concatenated_segments ||'('||mtp.organization_code||')',1,80)), 0)) +
        avg(nvl(vsize(decode(mti.buyer_id, NULL, 'NA_EDW', to_char(mti.buyer_id)||'?')), 0)) +
        avg(nvl(vsize(decode(mti.planner_code, NULL, 'NA_EDW', mti.planner_code||'?')), 0)) +
        avg(nvl(vsize(substr(mti.concatenated_segments ||'('||mtp.organization_code||')',1,240)), 0)) +
        avg(nvl(vsize(mti.description), 0)) +
        avg(nvl(vsize(mti.inventory_item_id), 0)) +
        avg(nvl(vsize(mti.organization_id), 0)) +
        avg(nvl(vsize(mti.planning_make_buy_code), 0)) +
        avg(nvl(vsize(mti.list_price_per_unit), 0)) +
        avg(nvl(vsize(mti.market_price), 0)) +
        avg(nvl(vsize(mti.taxable_flag), 0)) +
        avg(nvl(vsize(mti.stock_enabled_flag), 0)) +
        avg(nvl(vsize(mti.internal_order_enabled_flag), 0)) +
        avg(nvl(vsize(mti.inventory_planning_code), 0)) +
        avg(nvl(vsize(mti.lot_control_code), 0)) +
        avg(nvl(vsize(mti.outside_operation_flag), 0)) +
        avg(nvl(vsize(mti.price_tolerance_percent), 0)) +
        avg(nvl(vsize(mti.purchasing_enabled_flag), 0)) +
        avg(nvl(vsize(mti.shelf_life_code), 0)) +
        avg(nvl(vsize(mti.shelf_life_days), 0)) +
        avg(nvl(vsize(mti.tax_code), 0)) +
        avg(nvl(vsize(mti.revision_qty_control_code), 0)) +
        avg(nvl(vsize(mti.inspection_required_flag), 0)) +
        avg(nvl(vsize(mti.receipt_required_flag), 0)) +
        avg(nvl(vsize(mti.location_control_code), 0)) +
        avg(nvl(vsize(mti.effectivity_control), 0)) +
        avg(nvl(vsize(mti.serial_number_control_code), 0)) +
        avg(nvl(vsize(mti.mrp_planning_code), 0)) +
        avg(nvl(vsize(mti.must_use_approved_vendor_flag), 0)) +
        avg(nvl(vsize(mti.allow_substitute_receipts_flag), 0)) +
        avg(nvl(vsize(mti.allow_unordered_receipts_flag), 0)) +
        avg(nvl(vsize(mti.allow_express_delivery_flag), 0)) +
        avg(nvl(vsize(mti.hazard_class_id), 0)) +
        avg(nvl(vsize(mti.un_number_id), 0)) +
        avg(nvl(vsize(mti.rfq_required_flag), 0)) +
        avg(nvl(vsize(mti.creation_date), 0)) +
        avg(nvl(vsize(mti.last_update_date), 0)) +
        avg(nvl(vsize(NULL), 0)) +
        avg(nvl(vsize(mti.segment1), 0)) +
        45
        from mtl_system_items_b_kfv mti,
        mtl_parameters mtp,
        mtl_parameters mtm,
        edw_local_instance inst
        WHERE
        mti.product_family_item_id is NULL
        and mti.organization_id=mtp.organization_id
        and mtp.master_organization_id=mtm.organization_id
        and mti.last_update_date between
        p_from_date and p_to_date;

  -- EDW_ITEM_ITEMREV_LCV

  CURSOR c_2 IS
        SELECT
        avg(nvl(vsize(mtr.revision||'-'|| mtr.inventory_item_id ||'-'|| mtr.organization_id ||'-'|| inst.instance_code), 0))  +
        avg(nvl(vsize(inst.instance_code), 0)) +
	avg(nvl(vsize(mtr.inventory_item_id||'-'||mtr.organization_id||'-'||inst.instance_code), 0)) +
        avg(nvl(vsize(substr(mtr.revision || '(' || mti.concatenated_segments || ',' ||mp.organization_code || ')',1,240)), 0)) +
        avg(nvl(vsize(substr(mtr.revision || '(' || mti.concatenated_segments || ',' || mp.organization_code || ')',1,80)), 0)) +
        avg(nvl(vsize(substr(mtr.revision || '(' || mti.concatenated_segments || ',' || mp.organization_code || ')',1,240)), 0)) +
        avg(nvl(vsize(mtr.effectivity_date), 0)) +
        avg(nvl(vsize(mtr.creation_date), 0)) +
        avg(nvl(vsize(mtr.last_update_date), 0)) +
        avg(nvl(vsize(NULL), 0)) +
        10
        FROM
        mtl_system_items_kfv mti,
        mtl_item_revisions mtr,
        mtl_parameters mp,
        edw_local_instance inst
        WHERE
        mti.inventory_item_id = mtr.inventory_item_id
        and mti.organization_id = mtr.organization_id
        and mtr.organization_id = mp.organization_id
        and mtr.last_update_date between
        p_from_date and p_to_date;


  -- EDW_ITEM_ITEM_LCV

  CURSOR c_3 IS
        SELECT
        avg(nvl(vsize(mti.inventory_item_id||'-'||mti.organization_id||'-'||inst.instance_code), 0)) +
        avg(nvl(vsize(inst.instance_code), 0)) +
        avg(nvl(vsize('NA_EDW'), 0)) +
        avg(nvl(vsize('NA_EDW'), 0)) +
        avg(nvl(vsize('NA_EDW'), 0)) +
        avg(nvl(vsize('NA_EDW'), 0)) +
        avg(nvl(vsize(substr(mti.CONCATENATED_SEGMENTS||'('||mtp.organization_code||')',1,240)), 0)) +
        avg(nvl(vsize(substr(mti.CONCATENATED_SEGMENTS||'('||mtp.organization_code||')',1,80)), 0)) +
        avg(nvl(vsize(substr(mti.CONCATENATED_SEGMENTS||'('||mtp.organization_code||')',1,240)), 0)) +
        avg(nvl(vsize(mti.description), 0)) +
        avg(nvl(vsize(mti.ORGANIZATION_ID), 0)) +
        avg(nvl(vsize(mti.inventory_item_id), 0)) +
        avg(nvl(vsize(mti.last_update_date), 0)) +
        avg(nvl(vsize(mti.creation_date), 0)) +
        avg(nvl(vsize(NULL), 0)) +
        15
        from mtl_system_items_kfv mti,
        mtl_parameters mtp,
        edw_local_instance inst
        WHERE mtp.organization_id = mtp.master_organization_id
        and mti.organization_id = mtp.organization_id
        and mti.last_update_date between
        p_from_date and p_to_date;


  -- EDW_ITEM_ONETIME_ITEMORG_LCV

  CURSOR c_4 IS
        SELECT DISTINCT
        avg(nvl(vsize(l.ITEM_DESCRIPTION || '-' || cat.category_id || '-' || l.org_id || '-' || inst.instance_code || '-ONETIME'), 0)) +
        avg(nvl(vsize(inst.instance_code), 0)) +
        avg(nvl(vsize(l.ITEM_DESCRIPTION || '-' || cat.category_id || '-' || l.org_id || '-' || inst.instance_code || '-ONETIME'), 0)) +
        avg(nvl(vsize('NA_EDW'), 0)) +
        avg(nvl(vsize(cat.category_id||'-'||inst.instance_code), 0)) +
        avg(nvl(vsize(substr(l.ITEM_DESCRIPTION || '('|| cat.CONCATENATED_SEGMENTS || ',' || l.org_id|| ')',1,240)), 0)) +
        avg(nvl(vsize(substr(l.ITEM_DESCRIPTION || '(' || cat.CONCATENATED_SEGMENTS || ',' || l.org_id|| ')',1,80)), 0)) +
        avg(nvl(vsize('NA_EDW'), 0)) +
        avg(nvl(vsize('NA_EDW'), 0)) +
        avg(nvl(vsize('Y'), 0)) +
        avg(nvl(vsize(NULL), 0)) +
        avg(nvl(vsize(l.item_description), 0)) +
        avg(nvl(vsize(l.org_id), 0)) +
        avg(nvl(vsize(NULL), 0)) +
        avg(nvl(vsize(null), 0)) +
        avg(nvl(vsize(null), 0)) +
        avg(nvl(vsize(null), 0)) +
        avg(nvl(vsize(null), 0)) +
        avg(nvl(vsize(null), 0)) +
        avg(nvl(vsize(null), 0)) +
        avg(nvl(vsize(null), 0)) +
        avg(nvl(vsize(null), 0)) +
        avg(nvl(vsize(NULL), 0)) +
        avg(nvl(vsize(null), 0)) +
        avg(nvl(vsize(null), 0)) +
        avg(nvl(vsize(null), 0)) +
        avg(nvl(vsize(null), 0)) +
        avg(nvl(vsize(null), 0)) +
        avg(nvl(vsize(null), 0)) +
        avg(nvl(vsize(null), 0)) +
        avg(nvl(vsize(null), 0)) +
        avg(nvl(vsize(null), 0)) +
        avg(nvl(vsize(null), 0)) +
        avg(nvl(vsize(null), 0)) +
        avg(nvl(vsize(null), 0)) +
        avg(nvl(vsize(null), 0)) +
        avg(nvl(vsize(null), 0)) +
        avg(nvl(vsize(null), 0)) +
        avg(nvl(vsize(null), 0)) +
        avg(nvl(vsize(min(l.creation_date)), 0)) +
        avg(nvl(vsize(max(l.last_update_date)), 0)) +
        avg(nvl(vsize(NULL), 0)) +
        avg(nvl(vsize(NULL), 0)) +
        avg(nvl(vsize(NULL), 0)) +
        avg(nvl(vsize(NULL), 0)) +
        avg(nvl(vsize(NULL), 0)) +
        avg(nvl(vsize(NULL), 0)) +
        47
        From
        mtl_categories_kfv cat,
        po_lines_all l,
        edw_local_instance inst
        WHERE cat.category_id = l.category_id
        and l.item_id is null
        and l.last_update_date between
        p_from_date and p_to_date
        Group by
        l.ITEM_DESCRIPTION,
        l.org_id,
        cat.category_id,
        cat.CONCATENATED_SEGMENTS,
        inst.instance_code ;

  -- EDW_ITEM_ONETIME_ITEM_LCV

  CURSOR c_5 IS
        SELECT distinct
        avg(nvl(vsize(l.ITEM_DESCRIPTION || '-' || cat.category_id || '-' || l.org_id|| '-' || inst.instance_code ||'-ONETIME'), 0)) +
        avg(nvl(vsize(inst.instance_code), 0)) +
        avg(nvl(vsize(cat.category_id || '-' || inst.instance_code), 0)) +
        avg(nvl(vsize('NA_EDW'), 0)) +
        avg(nvl(vsize(substr(l.ITEM_DESCRIPTION || '(' || cat.CONCATENATED_SEGMENTS|| ')',1,240)), 0)) +
        avg(nvl(vsize(substr(l.ITEM_DESCRIPTION || '(' || cat.CONCATENATED_SEGMENTS|| ')',1,80)), 0)) +
        avg(nvl(vsize('Y'), 0)) +
        avg(nvl(vsize(l.item_description), 0)) +
        avg(nvl(vsize(NVL(l.item_description,'NA_EDW')), 0)) +
        avg(nvl(vsize(min(l.creation_date)), 0)) +
        avg(nvl(vsize(max(l.last_update_date)), 0)) +
        avg(nvl(vsize(NULL), 0)) +
        avg(nvl(vsize(NULL), 0)) +
        avg(nvl(vsize(NULL), 0)) +
        avg(nvl(vsize(NULL), 0)) +
        avg(nvl(vsize(NULL), 0)) +
        avg(nvl(vsize(NULL), 0)) +
        17
        From edw_local_instance inst,
        mtl_categories_kfv cat,
        po_lines_all l
        WHERE cat.category_id = l.category_id
        and l.item_id is null
        and l.last_update_date between
        p_from_date and p_to_date
        Group by l.ITEM_DESCRIPTION,
        l.org_id,
        cat.category_id,
        cat.concatenated_segments,
        inst.instance_code;

  -- EDW_ITEM_ITEMORGPF_LCV

  CURSOR c_6 IS
        SELECT
        avg(nvl(vsize(mti.inventory_item_id||'-'||mtp.organization_id||'-'||inst.instance_code), 0)) +
        avg(nvl(vsize(NULL), 0)) +
        avg(nvl(vsize(mti.inventory_item_id||'-'||edw_items_pkg.get_master_parent(mtp.organization_id) ||'-'||inst.instance_code), 0)) +
        avg(nvl(vsize(mic.category_id ||'-'||inst.instance_code), 0)) +
        avg(nvl(vsize('NA_EDW'), 0)) +
        avg(nvl(vsize(substr(mti.concatenated_segments||'('||mtp.organization_code||')',1,240)), 0)) +
        avg(nvl(vsize(substr(mti.concatenated_segments||'('||mtp.organization_code||')',1,80)), 0)) +
        avg(nvl(vsize(decode(mti.buyer_id, NULL,'NA_EDW',to_char(mti.buyer_id)||'?')), 0)) +
        avg(nvl(vsize(decode(mti.planner_code, NULL, 'NA_EDW', mti.planner_code||'?')), 0)) +
        avg(nvl(vsize(substr(mti.concatenated_segments||'('||mtp.organization_code||')',1,240)), 0)) +
        avg(nvl(vsize(mti.description), 0)) +
        avg(nvl(vsize(mti.inventory_item_id), 0)) +
        avg(nvl(vsize(mti.organization_id), 0)) +
        avg(nvl(vsize(mti.planning_make_buy_code), 0)) +
        avg(nvl(vsize(mti.list_price_per_unit), 0)) +
        avg(nvl(vsize(mti.market_price), 0)) +
        avg(nvl(vsize(mti.taxable_flag), 0)) +
        avg(nvl(vsize(mti.stock_enabled_flag), 0)) +
        avg(nvl(vsize(mti.internal_order_enabled_flag), 0)) +
        avg(nvl(vsize(mti.inventory_planning_code), 0)) +
        avg(nvl(vsize(mti.lot_control_code), 0)) +
        avg(nvl(vsize(mti.outside_operation_flag), 0)) +
        avg(nvl(vsize(mti.price_tolerance_percent), 0)) +
        avg(nvl(vsize(mti.purchasing_enabled_flag), 0)) +
        avg(nvl(vsize(mti.shelf_life_code), 0)) +
        avg(nvl(vsize(mti.shelf_life_days), 0)) +
        avg(nvl(vsize(mti.tax_code), 0)) +
        avg(nvl(vsize(mti.revision_qty_control_code), 0)) +
        avg(nvl(vsize(mti.inspection_required_flag), 0)) +
        avg(nvl(vsize(mti.receipt_required_flag), 0)) +
        avg(nvl(vsize(mti.location_control_code), 0)) +
        avg(nvl(vsize(mti.effectivity_control), 0)) +
        avg(nvl(vsize(mti.serial_number_control_code), 0)) +
        avg(nvl(vsize(mti.mrp_planning_code), 0)) +
        avg(nvl(vsize(mti.must_use_approved_vendor_flag), 0)) +
        avg(nvl(vsize(mti.allow_substitute_receipts_flag), 0)) +
        avg(nvl(vsize(mti.allow_unordered_receipts_flag), 0)) +
        avg(nvl(vsize(mti.allow_express_delivery_flag), 0)) +
        avg(nvl(vsize(mti.hazard_class_id), 0)) +
        avg(nvl(vsize(mti.un_number_id), 0)) +
        avg(nvl(vsize(mti.rfq_required_flag), 0)) +
        avg(nvl(vsize(mti.creation_date), 0)) +
        avg(nvl(vsize(mti.last_update_date), 0)) +
        avg(nvl(vsize(NULL), 0)) +
        avg(nvl(vsize(mti.segment1), 0)) +
        45
        FROM
        mtl_system_items_kfv mti,
        mtl_item_categories mic,
        mtl_category_sets sets,
        mtl_parameters mtp,
        mtl_parameters mtm,
        edw_local_instance inst
        WHERE
        mti.product_family_item_id is not null
        and mti.organization_id = mtp.organization_id
        and mic.inventory_item_id = mti.product_family_item_id
        and mic.organization_id = mti.organization_id
        and mic.category_set_id = sets.category_set_id
        and sets.category_set_name = 'Product Family'
        and mtp.master_organization_id = mtm.organization_id
        and mti.last_update_date between
        p_from_date and p_to_date;

  -- EDW_ITEM_ITEM_CAT_LCV

  CURSOR c_7 IS
        SELECT
        avg(nvl(vsize(mtc.category_id||'-'||inst.instance_code), 0)) +
        avg(nvl(vsize(inst.instance_code), 0)) +
        avg(nvl(vsize('ALL'), 0)) +
        avg(nvl(vsize(substr(mtc.concatenated_segments,1,240)), 0)) +
        avg(nvl(vsize(substr(mtc.concatenated_segments,1,80)), 0)) +
        avg(nvl(vsize(mtc.description), 0)) +
        avg(nvl(vsize(mts.category_set_name), 0)) +
        avg(nvl(vsize(mtc.category_id), 0)) +
        avg(nvl(vsize(mtc.creation_date), 0)) +
        avg(nvl(vsize(greatest(mtc.last_update_date, mts.last_update_date)), 0)) +
        avg(nvl(vsize(NULL), 0)) +
        11
        from
        mtl_categories_kfv mtc,
        mtl_category_sets mts,
        edw_local_instance inst
        WHERE mtc.structure_id = mts.structure_id
        and mts.control_level = 1
        and mtc.last_update_date between
        p_from_date and p_to_date;


  -- EDW_ITEM_ITEM_ORG_CAT_LCV

  CURSOR c_8 IS
        SELECT
        avg(nvl(vsize(mtc.category_id ||'-'||inst.instance_code), 0)) +
        avg(nvl(vsize(inst.instance_code), 0)) +
        avg(nvl(vsize('ALL'), 0)) +
        avg(nvl(vsize(substr(mtc.concatenated_segments,1,240)), 0)) +
        avg(nvl(vsize(substr(mtc.concatenated_segments,1,80)), 0)) +
        avg(nvl(vsize(mtc.description), 0)) +
        avg(nvl(vsize(mts.category_set_name), 0)) +
        avg(nvl(vsize(mtc.category_id), 0)) +
        avg(nvl(vsize(mtc.creation_date), 0)) +
        avg(nvl(vsize(greatest(mtc.last_update_date, mts.last_update_date)), 0)) +
        avg(nvl(vsize(NULL), 0)) +
        11
        from mtl_categories_kfv mtc,
        mtl_category_sets mts,
        edw_local_instance inst
        WHERE mtc.structure_id = mts.structure_id
        and mtc.last_update_date between
        p_from_date and p_to_date;



  -- EDW_ITEM_PRDFAM_LCV

  CURSOR c_9 IS
        SELECT
        avg(nvl(vsize(cats.category_id ||'-'||inst.instance_code), 0)) +
        avg(nvl(vsize(inst.instance_code), 0)) +
        avg(nvl(vsize('ALL'), 0)) +
        avg(nvl(vsize(substr(CATS.CONCATENATED_SEGMENTS,1,240)), 0)) +
        avg(nvl(vsize(substr(CATS.CONCATENATED_SEGMENTS,1,80)), 0)) +
        avg(nvl(vsize(substr(cats.concatenated_segments,1,240)), 0)) +
        avg(nvl(vsize(cats.description), 0)) +
        avg(nvl(vsize(cats.creation_date), 0)) +
        avg(nvl(vsize(cats.last_update_date), 0)) +
        avg(nvl(vsize(NULL), 0)) +
        avg(nvl(vsize(NULL), 0)) +
        avg(nvl(vsize(NULL), 0)) +
        avg(nvl(vsize(NULL), 0)) +
        avg(nvl(vsize(NULL), 0)) +
        avg(nvl(vsize(NULL), 0)) +
        15
        FROM
        mtl_categories_kfv cats,
        mtl_category_sets sets,
        edw_local_instance inst
        WHERE
        cats.structure_id = sets.structure_id
        and sets.category_set_name = 'Product Family'
        and cats.last_update_date between
        p_from_date and p_to_date;


  -- EDW_ITEM_PROD_CATG_LCV

  CURSOR c_10 IS
        SELECT
        avg(nvl(vsize(CD.INTEREST_CODE_ID || '-' || INST.INSTANCE_CODE || '-PRIM_CODE'), 0)) +
        avg(nvl(vsize(INTYP.INTEREST_TYPE_ID || '-' || INST.INSTANCE_CODE || '-INTR_TYPE'), 0)) +
        avg(nvl(vsize(CD.CODE ||'(' || INTYP.INTEREST_TYPE || ')'), 0)) +
        avg(nvl(vsize(CD.CODE), 0)) +
        avg(nvl(vsize(CD.DESCRIPTION), 0)) +
        avg(nvl(vsize(CD.INTEREST_CODE_ID), 0)) +
        avg(nvl(vsize(CD.MASTER_ENABLED_FLAG), 0)) +
        avg(nvl(vsize(INST.INSTANCE_CODE), 0)) +
        avg(nvl(vsize(CD.CREATION_DATE), 0)) +
        avg(nvl(vsize(GREATEST(CD.LAST_UPDATE_DATE, INTYP.LAST_UPDATE_DATE)), 0)) +
        avg(nvl(vsize(NULL), 0)) +
        avg(nvl(vsize(NULL), 0)) +
        avg(nvl(vsize(NULL), 0)) +
        avg(nvl(vsize(NULL), 0)) +
        avg(nvl(vsize(NULL), 0)) +
        avg(nvl(vsize(TO_DATE(NULL)), 0)) +
        16
        FROM
        AS_INTEREST_CODES_V CD ,
        AS_INTEREST_TYPES_V INTYP ,
        EDW_LOCAL_INSTANCE INST
        WHERE
        CD.INTEREST_TYPE_ID = INTYP.INTEREST_TYPE_ID
        AND CD.PARENT_INTEREST_CODE_ID IS NULL
        AND INTYP.EXPECTED_PURCHASE_FLAG = 'Y'
        AND ( ( CD.LAST_UPDATE_DATE > TO_DATE('1000/01/01', 'YYYY/MM/DD') )
        OR (INTYP.LAST_UPDATE_DATE > TO_DATE('1000/01/01', 'YYYY/MM/DD') ) )
        and cd.last_update_date between
        p_from_date and p_to_date;


  -- EDW_ITEM_PROD_GRP_LCV

  CURSOR c_11 IS
        SELECT
        avg(nvl(vsize(SCD.INTEREST_CODE_ID || '-' || INST.INSTANCE_CODE || '-SECN_CODE'), 0)) +
        avg(nvl(vsize(PCD.INTEREST_CODE_ID || '-' || INST.INSTANCE_CODE || '-PRIM_CODE'), 0)) +
        avg(nvl(vsize(SCD.CODE ||'(' || PCD.CODE || ')' || '(' || INTYP.INTEREST_TYPE || ')'), 0)) +
        avg(nvl(vsize(SCD.CODE), 0)) +
        avg(nvl(vsize(SCD.DESCRIPTION), 0)) +
        avg(nvl(vsize(SCD.INTEREST_CODE_ID), 0)) +
        avg(nvl(vsize(SCD.MASTER_ENABLED_FLAG), 0)) +
        avg(nvl(vsize(INST.INSTANCE_CODE), 0)) +
        avg(nvl(vsize(SCD.CREATION_DATE), 0)) +
        avg(nvl(vsize(GREATEST(SCD.LAST_UPDATE_DATE, PCD.LAST_UPDATE_DATE, INTYP.LAST_UPDATE_DATE)), 0)) +
        avg(nvl(vsize(NULL), 0)) +
        avg(nvl(vsize(NULL), 0)) +
        avg(nvl(vsize(NULL), 0)) +
        avg(nvl(vsize(NULL), 0)) +
        avg(nvl(vsize(NULL), 0)) +
        avg(nvl(vsize(TO_DATE(NULL)), 0)) +
        16
        FROM
        AS_INTEREST_CODES_V SCD ,
        AS_INTEREST_CODES_V PCD ,
        AS_INTEREST_TYPES_V INTYP ,
        EDW_LOCAL_INSTANCE INST
        WHERE
        SCD.PARENT_INTEREST_CODE_ID = PCD.INTEREST_CODE_ID
        AND PCD.PARENT_INTEREST_CODE_ID IS NULL
        AND SCD.INTEREST_TYPE_ID = PCD.INTEREST_TYPE_ID
        AND PCD.INTEREST_TYPE_ID = INTYP.INTEREST_TYPE_ID
        AND INTYP.EXPECTED_PURCHASE_FLAG = 'Y'
        AND ( ( SCD.LAST_UPDATE_DATE > TO_DATE('1000/01/01', 'YYYY/MM/DD') )
        OR ( PCD.LAST_UPDATE_DATE > TO_DATE('1000/01/01', 'YYYY/MM/DD') )
        OR (INTYP.LAST_UPDATE_DATE > TO_DATE('1000/01/01', 'YYYY/MM/DD') ) )
        and scd.last_update_date between
        p_from_date and p_to_date;


  -- EDW_ITEM_PROD_LINE_LCV

  CURSOR c_12 IS
        SELECT
        avg(nvl(vsize(INTYP.INTEREST_TYPE_ID || '-' || INST.INSTANCE_CODE || '-INTR_TYPE'), 0)) +
        avg(nvl(vsize('ALL'), 0)) +
        avg(nvl(vsize(INTYP.INTEREST_TYPE), 0)) +
        avg(nvl(vsize(INTYP.INTEREST_TYPE), 0)) +
        avg(nvl(vsize(INTYP.DESCRIPTION), 0)) +
        avg(nvl(vsize(INTYP.INTEREST_TYPE_ID), 0)) +
        avg(nvl(vsize(INTYP.MASTER_ENABLED_FLAG), 0)) +
        avg(nvl(vsize(INST.INSTANCE_CODE), 0)) +
        avg(nvl(vsize(INTYP.CREATION_DATE), 0)) +
        avg(nvl(vsize(INTYP.LAST_UPDATE_DATE), 0)) +
        avg(nvl(vsize(NULL), 0)) +
        avg(nvl(vsize(NULL), 0)) +
        avg(nvl(vsize(NULL), 0)) +
        avg(nvl(vsize(NULL), 0)) +
        avg(nvl(vsize(NULL), 0)) +
        avg(nvl(vsize(TO_DATE(NULL)), 0)) +
        16
        FROM
        AS_INTEREST_TYPES_V INTYP ,
        EDW_LOCAL_INSTANCE INST
        WHERE
        INTYP.EXPECTED_PURCHASE_FLAG = 'Y'
        and intyp.last_update_date between
        p_from_date and p_to_date;


		l_current NUMBER := 0;
		l_total NUMBER := 0;

  BEGIN

	OPEN c_1;
	FETCH c_1 INTO l_current;
	l_total := l_total + l_current;
	CLOSE c_1;

 	OPEN c_2;
	FETCH c_2 INTO l_current;
	l_total := l_total + l_current;
	CLOSE c_2;

	OPEN c_3;
	FETCH c_3 INTO l_current;
	l_total := l_total + l_current;
	CLOSE c_3;

	OPEN c_4;
	FETCH c_4 INTO l_current;
	l_total := l_total + l_current;
	CLOSE c_4;

	OPEN c_5;
	FETCH c_5 INTO l_current;
	l_total := l_total + l_current;
	CLOSE c_5;

	OPEN c_6;
	FETCH c_6 INTO l_current;
	l_total := l_total + l_current;
	CLOSE c_6;

	OPEN c_7;
	FETCH c_7 INTO l_current;
	l_total := l_total + 22*l_current;
	CLOSE c_7;

	OPEN c_8;
	FETCH c_8 INTO l_current;
	l_total := l_total + 6*l_current;
	CLOSE c_8;

	OPEN c_9;
	FETCH c_9 INTO l_current;
	l_total := l_total + l_current;
	CLOSE c_9;

	OPEN c_10;
	FETCH c_10 INTO l_current;
	l_total := l_total + l_current;
	CLOSE c_10;

	OPEN c_11;
	FETCH c_11 INTO l_current;
	l_total := l_total + l_current;
	CLOSE c_11;

	OPEN c_12;
	FETCH c_12 INTO l_current;
	l_total := l_total + l_current;
	CLOSE c_12;

	p_avg_row_len := ceil(l_total) + 3*31;

EXCEPTION
  WHEN OTHERS THEN
	IF c_1%ISOPEN THEN
		CLOSE c_1;
	END IF;

	IF c_2%ISOPEN THEN
	   CLOSE c_2;
	END IF;

	IF c_3%ISOPEN THEN
	   CLOSE c_3;
	END IF;

	IF c_4%ISOPEN THEN
	   CLOSE c_4;
	END IF;

    IF c_5%ISOPEN THEN
       CLOSE c_5;
	END IF;

 	IF c_6%ISOPEN THEN
	   CLOSE c_6;
	END IF;

	IF c_7%ISOPEN THEN
	   CLOSE c_7;
	END IF;

	IF c_8%ISOPEN THEN
	   CLOSE c_8;
	END IF;

	IF c_9%ISOPEN THEN
	   CLOSE c_9;
	END IF;

	IF c_10%ISOPEN THEN
	   CLOSE c_10;
	END IF;

	IF c_11%ISOPEN THEN
	   CLOSE c_11;
	END IF;

	IF c_12%ISOPEN THEN
	   CLOSE c_12;
	END IF;


  END EST_ROW_LEN;

END EDW_ITEMS_M_SIZE;

/
