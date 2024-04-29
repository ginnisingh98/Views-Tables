--------------------------------------------------------
--  DDL for Package Body MRP_MANAGER_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_MANAGER_PK" AS
/* $Header: MRPPPMGB.pls 120.3.12000000.4 2007/10/25 19:33:29 schaudha ship $ */

  -- Global constant for package name
     g_om_installed             VARCHAR2(3)  := NULL;


-- ********************** mds_explode_in_process ******************************
PROCEDURE mds_explode_in_process (arg_in_process_id OUT NOCOPY NUMBER,
                                  arg_request_id    IN  NUMBER,
                                  arg_user_id       IN  NUMBER) IS
    var_batch_id NUMBER;
BEGIN
    SELECT mrp_form_query_s.nextval
    INTO   var_batch_id
    FROM   dual;

    var_watch_id := mrp_print_pk.start_watch(
                                'GEN-inserting',
                                arg_request_id,
                                arg_user_id,
                                'ENTITY',
                                'E_ITEMS',
                                'Y',
                                'TABLE',
                                'mrp_form_query(1:'||to_char(var_batch_id)||')',
                                'N');

    --
    -- Insert the following into MRP_FORM_QUERY:
    --     1. Items in MRP_RELIEF_INTERFACE
    --     2. Product family of items in (1)
    --     3. Components of config items in (1)
    --     4. Other items that are in the same product family as items in (1)
    --
    INSERT INTO mrp_form_query (
            query_id,
            number1,
            number2,
            number3,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by)
    SELECT  var_batch_id,
            upd.inventory_item_id,
            upd.organization_id,
            1,
            SYSDATE,
            -1,
            SYSDATE,
            -1
    FROM    mrp_relief_interface upd
    WHERE   upd.relief_type = 1
    AND     upd.request_id IS NOT NULL
    AND     upd.error_message IS NULL
    AND     upd.process_status = 3
    UNION
    SELECT  /*+ ordered use_nl(upd1, item) */
            var_batch_id,               /* product family */
            item.product_family_item_id,
            upd1.organization_id,
            1,
            SYSDATE,
            -1,
            SYSDATE,
            -1
    FROM    mrp_relief_interface        upd1,
            mtl_system_items            item
    WHERE   item.organization_id        = upd1.organization_id
    AND     item.inventory_item_id      = upd1.inventory_item_id
    AND     upd1.relief_type = 1
    AND     upd1.request_id IS NOT NULL
    AND     upd1.error_message IS NULL
    AND     upd1.process_status = 3
    UNION
    SELECT  /*+ ordered use_nl(upd2,bom_item, bom, comp, comp_item) */
            var_batch_id,
            comp.component_item_id,     /* config item's component */
            bom.organization_id,
            1,
            SYSDATE,
            -1,
            SYSDATE,
            -1
    FROM    mrp_relief_interface        upd2,
            mtl_system_items            bom_item,
            bom_bill_of_materials       bom,
            bom_inventory_components    comp,
            mtl_system_items            comp_item
    WHERE   NVL(comp_item.ato_forecast_control, ATO_NONE) <> ATO_NONE
    AND     comp_item.inventory_item_id = comp.component_item_id
    AND     comp_item.organization_id   = bom.organization_id
    AND     comp.bill_sequence_id       = bom.common_bill_sequence_id
    AND     bom.alternate_bom_designator IS NULL
    AND     bom.organization_id         = bom_item.organization_id
    AND     bom.assembly_item_id        = bom_item.inventory_item_id
    AND     bom_item.base_item_id IS NOT NULL
    AND     bom_item.organization_id    = upd2.organization_id
    AND     bom_item.inventory_item_id  = upd2.inventory_item_id
    AND     upd2.relief_type = 1
    AND     upd2.request_id IS NOT NULL
    AND     upd2.error_message IS NULL
    AND     upd2.process_status = 3
    UNION
    SELECT  /*+ ordered use_nl(upd3, item1, item2)
                    index (item2 mtl_system_items_b_n7) */
            var_batch_id,
            item2.inventory_item_id,    /* other items that belong to */
            item2.organization_id,      /* the same product family    */
            1,
            SYSDATE,
            -1,
            SYSDATE,
            -1
    FROM    mrp_relief_interface        upd3,
            mtl_system_items            item1,
            mtl_system_items            item2
    WHERE   item2.product_family_item_id = item1.product_family_item_id
    AND     item2.organization_id        = item1.organization_id
    AND     item2.inventory_item_id     <> item1.inventory_item_id
    AND     item1.organization_id        = upd3.organization_id
    AND     item1.inventory_item_id      = upd3.inventory_item_id
    AND     upd3.relief_type = 1
    AND     upd3.request_id IS NOT NULL
    AND     upd3.error_message IS NULL
    AND     upd3.process_status = 3;

    mrp_print_pk.stop_watch(arg_request_id,
                            var_watch_id,
                            SQL%ROWCOUNT);

    var_watch_id := mrp_print_pk.start_watch(
                            'GEN-inserting',
                            arg_request_id,
                            arg_user_id,
                            'ENTITY',
                            'E_ITEMS',
                            'Y',
                            'TABLE',
                            'mrp_form_query(2:'||to_char(var_batch_id)||')',
                            'N');

    --
    -- Insert the config items of those items inserted above
    --
    INSERT INTO mrp_form_query (
            query_id,
            number1,
            number2,
            number3,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by)
    SELECT  DISTINCT
            var_batch_id,
            bom.assembly_item_id,
            bom.organization_id,
            2,
            SYSDATE,
            -1,
            SYSDATE,
            -1
    FROM    mtl_system_items            bom_item,
            bom_bill_of_materials       bom,
            bom_inventory_components    comp,
            mtl_system_items            comp_item,
            mrp_form_query              query
    WHERE   bom_item.base_item_id IS NOT NULL
    AND     bom_item.organization_id    = bom.organization_id
    AND     bom_item.inventory_item_id  = bom.assembly_item_id
    AND     bom.alternate_bom_designator IS NULL
    AND     bom.organization_id         = comp_item.organization_id
    AND     bom.common_bill_sequence_id = comp.bill_sequence_id
    AND     comp.component_item_id      = comp_item.inventory_item_id
    AND     NVL(comp_item.ato_forecast_control, ATO_NONE) <> ATO_NONE
    AND     comp_item.organization_id   = query.number2
    AND     comp_item.inventory_item_id = query.number1
    AND     query.query_id = var_batch_id;

    mrp_print_pk.stop_watch(arg_request_id,
                            var_watch_id,
                            SQL%ROWCOUNT);

    arg_in_process_id := var_batch_id;
END mds_explode_in_process;


-- ********************** explode_in_process ********************************
PROCEDURE explode_in_process (arg_in_process_id OUT NOCOPY NUMBER,
                              arg_request_id    IN  NUMBER,
                              arg_user_id       IN  NUMBER) IS
    var_batch_id   NUMBER;
    var_batch_size NUMBER;
    var_expl       NUMBER;
BEGIN
    SELECT mrp_form_query_s.nextval
    INTO   var_batch_id
    FROM   dual;

    var_watch_id := mrp_print_pk.start_watch(
                                'GEN-inserting',
                                arg_request_id,
                                arg_user_id,
                                'ENTITY',
                                'E_ITEMS',
                                'Y',
                                'TABLE',
                                'mrp_form_query(1:'||to_char(var_batch_id)||')',
                                'N');

    var_expl := NVL(TO_NUMBER(FND_PROFILE.VALUE('MRP_FC_EXPLOSION')), SYS_YES);
    var_batch_size := NVL(TO_NUMBER(FND_PROFILE.VALUE(
                           'MRP_SCHED_MGR_BATCH_SIZE')), SYS_YES);

    --
    -- Insert the following into MRP_FORM_QUERY:
    --     1. Items in MRP_SALES_ORDER_UPDATES
    --     2. Product family of items in (1)
    --     3. Components of items in (1)
    --     4. Other items that are in the same product family as items in (1)
    --
    INSERT INTO mrp_form_query (
                query_id,
                number1,
                number2,
                number3,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by)
    SELECT      /*+ INDEX (upd MRP_SALES_ORDER_UPDATES_N4) */
                var_batch_id,
                upd.inventory_item_id,
                upd.organization_id,
                -1,
                SYSDATE,
                -1,
                SYSDATE,
                -1
    FROM        mrp_sales_order_updates upd
    WHERE       upd.process_status = 3
    UNION
    SELECT       /*+ INDEX (upd1 MRP_SALES_ORDER_UPDATES_N4)
                    ORDERED
                    USE_NL (upd1, item) */
                var_batch_id,		    /* product family */
                item.product_family_item_id,
                upd1.organization_id,
                1,
                SYSDATE,
                -1,
                SYSDATE,
                -1
    FROM        mrp_sales_order_updates upd1,
                mtl_system_items        item
    WHERE       item.organization_id    = upd1.organization_id
    AND         item.inventory_item_id  = upd1.inventory_item_id
    AND         upd1.request_id IS NOT NULL
    AND         upd1.error_message IS NULL
    AND         upd1.process_status = 3
    UNION
    SELECT      /*+ INDEX (upd2 MRP_SALES_ORDER_UPDATES_N4)
                    ORDERED
                    USE_NL (upd2, bom_item,bom,comp,comp_item) */
                var_batch_id,
                comp.component_item_id,     /* items's children */
                bom.organization_id,
                1,
                SYSDATE,
                -1,
                SYSDATE,
                -1
    FROM        mrp_sales_order_updates  upd2,
                mtl_system_items         bom_item,
                bom_bill_of_materials    bom,
                bom_inventory_components comp,
                mtl_system_items         comp_item
    WHERE       (((bom_item.bom_item_type  = ITEM_TYPE_MODEL
--
--  This is the logic we have added to skip explosion of
--  option classes if the profile is set to SYS_NO.
--
    OR             (bom_item.bom_item_type = ITEM_TYPE_OPTION_CLASS
    AND             var_expl = SYS_YES))
    AND           comp.optional = SYS_NO
    AND           comp_item.bom_item_type = ITEM_TYPE_STANDARD)
    OR           (bom_item.base_item_id IS NOT NULL))
    AND         NVL(comp_item.ato_forecast_control, ATO_NONE) <> ATO_NONE
    AND         comp_item.inventory_item_id     = comp.component_item_id
    AND         comp_item.organization_id   = bom.organization_id
    AND         comp.bill_sequence_id       = bom.common_bill_sequence_id
    AND         bom.alternate_bom_designator IS NULL
    AND         bom.organization_id         = bom_item.organization_id
    AND         bom.assembly_item_id        = bom_item.inventory_item_id
    AND         bom_item.pick_components_flag   = 'N'
    AND         bom_item.organization_id    = upd2.organization_id
    AND         bom_item.inventory_item_id  = upd2.inventory_item_id
    AND         upd2.request_id IS NOT NULL
    AND         upd2.error_message IS NULL
    AND         upd2.process_status = 3
    UNION
    SELECT      /*+ INDEX (upd3 MRP_SALES_ORDER_UPDATES_N4)
                    INDEX (item2 MTL_SYSTEM_ITEMS_B_N7)
                    ORDERED
                    USE_NL (upd3, item1,item2) */
                var_batch_id,
                item2.inventory_item_id,    /* other items that belong to */
                item2.organization_id,      /* the same product family    */
                1,
                SYSDATE,
                -1,
                SYSDATE,
                -1
    FROM        mrp_sales_order_updates  upd3,
                mtl_system_items         item1,
                mtl_system_items         item2
    WHERE       item2.product_family_item_id = item1.product_family_item_id
    AND         item2.organization_id        = item1.organization_id
    AND         item2.inventory_item_id     <> item1.inventory_item_id
    AND         item1.organization_id        = upd3.organization_id
    AND         item1.inventory_item_id      = upd3.inventory_item_id
    AND         upd3.request_id IS NOT NULL
    AND         upd3.error_message IS NULL
    AND         upd3.process_status = 3;

    mrp_print_pk.stop_watch(arg_request_id,
                            var_watch_id,
                            SQL%ROWCOUNT);

    var_watch_id := mrp_print_pk.start_watch(
                            'GEN-inserting',
                            arg_request_id,
                            arg_user_id,
                            'ENTITY',
                            'E_ITEMS',
                            'Y',
                            'TABLE',
                            'mrp_form_query(2:'||to_char(var_batch_id)||')',
                            'N');

    --
    -- Insert the following into MRP_FORM_QUERY:
    --     1. Model and Option classes of mandatory standard items
    --        which are inserted above
    --     2. Config items of those items inserted above
    --
    INSERT INTO mrp_form_query (
                query_id,
                number1,
                number2,
                number3,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by)
    SELECT      /*+ INDEX (query MRP_FORM_QUERY_N1)
                    ORDERED
                    USE_NL (query, comp_item, comp, bom, bom_item) */
                DISTINCT
                var_batch_id,
                bom.assembly_item_id,
                bom.organization_id,
                -1,
                SYSDATE,
                -1,
                SYSDATE,
                -1
    FROM        mrp_form_query              query,
                mtl_system_items            comp_item,
                bom_inventory_components    comp,
                bom_bill_of_materials       bom,
                mtl_system_items            bom_item
    WHERE       (((bom_item.bom_item_type  = ITEM_TYPE_MODEL
--
--  This is the logic we have added to skip explosion of
--  option classes if the profile is set to SYS_NO.
--
    OR             (bom_item.bom_item_type = ITEM_TYPE_OPTION_CLASS
    AND             var_expl = SYS_YES))
    AND           comp.optional = SYS_NO
    AND           comp_item.bom_item_type = ITEM_TYPE_STANDARD)
    OR           (bom_item.base_item_id IS NOT NULL))
    AND         bom_item.pick_components_flag   = 'N'
    AND         bom_item.organization_id    = bom.organization_id
    AND         bom_item.inventory_item_id  = bom.assembly_item_id
    AND         bom.alternate_bom_designator IS NULL
    AND         bom.organization_id         = comp_item.organization_id
    AND         bom.common_bill_sequence_id = comp.bill_sequence_id
    AND         comp.component_item_id      = comp_item.inventory_item_id
    AND         NVL(comp_item.ato_forecast_control, ATO_NONE) <> ATO_NONE
    AND         comp_item.organization_id   = query.number2
    AND         comp_item.inventory_item_id = query.number1
    AND         query.query_id = var_batch_id;

    mrp_print_pk.stop_watch(arg_request_id,
                            var_watch_id,
                            SQL%ROWCOUNT);

    var_watch_id := mrp_print_pk.start_watch(
                            'GEN-inserting',
                            arg_request_id,
                            arg_user_id,
                            'ENTITY',
                            'E_ITEMS',
                            'Y',
                            'TABLE',
                            'mrp_form_query(3:'||to_char(var_batch_id)||')',
                            'N');
    --
    -- Inserting the records to process
    --
    INSERT INTO mrp_form_query (
            query_id,
            number1,
            number2,
            number3,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by)
        SELECT /*+ index(upd2 mrp_sales_order_updates_n4) */
            var_batch_id,
            -1,
            inventory_item_id,
            -1,
            SYSDATE,
            -1,
            SYSDATE,
            -1
         FROM   mrp_sales_order_updates upd2
         WHERE  (upd2.new_schedule_date <>
                NVL(upd2.old_schedule_date,
                    upd2.new_schedule_date + 1)
            OR  upd2.new_schedule_quantity <>
                NVL(upd2.old_schedule_quantity,
                    upd2.new_schedule_quantity+1)
            OR  upd2.current_customer_id <>
                NVL(upd2.previous_customer_id,
                    upd2.current_customer_id + 1)
            OR  upd2.current_bill_id <>
                    NVL(upd2.previous_bill_id,
                        upd2.current_bill_id + 1)
            OR  upd2.current_ship_id <>
                    NVL(upd2.previous_ship_id,
                        upd2.current_ship_id + 1)
            OR  nvl(upd2.current_available_to_mrp,'N') <>
                NVL(upd2.previous_available_to_mrp,
                    'N')
           OR  nvl(upd2.current_demand_class,'734jkhJK24') <>
                NVL(upd2.previous_demand_class,
                    '734jkhJK24'))
        AND     upd2.process_status = 2
        AND     upd2.error_message IS NULL
        AND     upd2.request_id IS NULL
        AND     rownum <= var_batch_size
        AND     NOT EXISTS
                (SELECT 'x'
                 FROM   mrp_form_query
                 WHERE  query_id = var_batch_id
                 AND    number1  = upd2.inventory_item_id);

    mrp_print_pk.stop_watch(arg_request_id,
                            var_watch_id,
                            SQL%ROWCOUNT);



    arg_in_process_id := var_batch_id;
END explode_in_process;
-- ********************** compute_sales_order_changes *************************
PROCEDURE compute_sales_order_changes(arg_request_id IN NUMBER,
                                      arg_user_id IN NUMBER) IS

    var_break_loop                   INTEGER := SYS_NO;
    var_old_so_cutoff_days           NUMBER;
    var_first_time                   varchar2(5);
    pvalue                           boolean;
    new_org_rec_count                NUMBER;

    rows_updated                      NUMBER := 0;
    var_dem_rowid                     ROWID;
    var_dem_inventory_item_id         NUMBER;
    var_dem_demand_id                 NUMBER;
    var_dem_organization_id           NUMBER;
    var_dem_user_line_num             VARCHAR2(30);
    var_dem_requirement_date          DATE;
    var_dem_primary_uom_quantity      NUMBER;
    var_dem_customer_id               NUMBER;
    var_dem_ship_to_site_use_id       NUMBER;
    var_dem_bill_to_site_use_id       NUMBER;
    var_dem_available_to_mrp          VARCHAR2(1);
    var_dem_demand_class              VARCHAR2(30);
    var_dem_completed_quantity        NUMBER;
    var_dem_ordered_item              NUMBER;
    var_dem_source_header_id          NUMBER;
    var_upd_rowid                     ROWID;

    TYPE  line_id_table is TABLE of NUMBER
        INDEX BY BINARY_INTEGER;
    line_id_arr                       line_id_table;
    var_org_id                        NUMBER;
    var_cal_code                      VARCHAR2(30);
    prev_cal_code                     VARCHAR2(30);
    var_except_set_id                 NUMBER;
    prev_except_set_id                NUMBER;
    var_min_cal_date                  DATE;
    var_max_cal_date                  DATE;
    counter                           NUMBER := 0;
    counter1                          NUMBER := 0;
    var_demand_type		      NUMBER;
    var_ato_line_id		      NUMBER;
    var_dem_header_id  		      NUMBER;
    var_dem_demand_type		      NUMBER;
    records_in_process            NUMBER := 0;
    config_lines_counter          NUMBER;

    var_debug                     BOOLEAN := FALSE;
    insert_count                  NUMBER;
    update_count                  NUMBER;

    to_insert                     NUMBER;
    to_update                     NUMBER;

    var_line_id                   NUMBER;
    busy EXCEPTION;

    TYPE ato_model_config_rec IS RECORD
    (
           ato_line_id NUMBER,
           config_line_id NUMBER
    );

    TYPE ato_model_config_tbl IS TABLE OF ato_model_config_rec
    INDEX BY BINARY_INTEGER;

    ato_model_config_arr   ato_model_config_tbl;

    max_ato_model_config   NUMBER := 0;
    found_config_item      NUMBER;       -- Indicates if the configured item is
                                         -- present in the local array
                                         -- ato_model_config_arr.
    config_line_id         NUMBER;
    config_item_exists     NUMBER;
    line_ids_except_config NUMBER;

    PRAGMA EXCEPTION_INIT(busy, -54);

    CURSOR MTL_DEMAND_CUR_FIRST IS
        SELECT
                dem.inventory_item_id,
                dem.line_id,
                dem.SHIP_FROM_ORG_ID ,
                dem.line_number ,
		        decode(nvl(dem.mfg_lead_time,0),
				       0, dem.SCHEDULE_SHIP_DATE,
                        decode(dem.line_id,
                               dem.ato_line_id, dem.SCHEDULE_SHIP_DATE,
                               MRP_CALENDAR.DATE_OFFSET (dem.ship_from_org_id,
                                                         1,
                                                         dem.schedule_ship_date,
                                                         -1*(dem.mfg_lead_time)))),
                DECODE(dem.ORDERED_QUANTITY,
                           NULL, 0,
                           INV_DECIMALS_PUB.GET_PRIMARY_QUANTITY(
                                    dem.SHIP_FROM_ORG_ID,
                                    dem.INVENTORY_ITEM_ID,
                                    dem.ORDER_QUANTITY_UOM,
                                    dem.ORDERED_QUANTITY)),
                dem.SOLD_TO_ORG_ID,
                dem.SHIP_TO_ORG_ID,
                dem.INVOICE_TO_ORG_ID,
                NVL(visible_demand_flag,'N'),
                dem.demand_class_code,
                DECODE(dem.SHIPPED_QUANTITY,
                           NULL, 0,
                           INV_DECIMALS_PUB.GET_PRIMARY_QUANTITY(
                                    dem.SHIP_FROM_ORG_ID,
                                    dem.INVENTORY_ITEM_ID,
                                    dem.ORDER_QUANTITY_UOM,
                                    dem.SHIPPED_QUANTITY)),
                DECODE(DECODE(dem.ITEM_TYPE_CODE,
                                  'CLASS',2,
                                  'CONFIG',4,
                                  'MODEL',1,
                                  'OPTION' ,3,
                                  'STANDARD',6,
                                  -1),
                       1, dem.inventory_item_id, NULL),
                inv_salesorder.get_salesorder_for_oeheader(dem.HEADER_ID),
                DECODE(dem.ITEM_TYPE_CODE,
                           'CLASS',2,
                           'CONFIG',4,
                           'MODEL',1,
                           'OPTION' ,3,
                           'STANDARD',6,
                           -1),
                dem.ato_line_id,
                upd.rowid
        FROM
                oe_order_lines_all  dem,
                mrp_sales_order_updates upd,
                mtl_parameters  param
        WHERE   NVL(upd.process_status, -1) <> 3
        AND     upd.sales_order_id(+) = dem.line_id
        AND     param.calendar_code IS NOT NULL
        AND     param.calendar_exception_set_id IS NOT NULL
        AND     param.organization_id = decode(dem.cancelled_flag,
                                          'Y', upd.organization_id,
                                           dem.ship_from_org_id)
        AND     dem.SOLD_TO_ORG_ID IS NOT NULL
        AND     dem.SHIP_TO_ORG_ID IS NOT NULL
        AND     dem.INVOICE_TO_ORG_ID IS NOT NULL
        AND     ((dem.SCHEDULE_SHIP_DATE is NULL
--                   AND dem.cancelled_flag = 'Y'
                  )
                 OR (dem.SCHEDULE_SHIP_DATE IS NOT NULL
                     and dem.SCHEDULE_SHIP_DATE >=
                        (SYSDATE - var_old_so_cutoff_days)))
                                        -- BUG 2848262, Need to compare
                                        -- the value current_ cols in upd with
                                        -- the corresponding values in dem.
	    AND (NOT EXISTS
        (SELECT NULL
        FROM    mrp_sales_order_updates updates
        WHERE   updates.sales_order_id = dem.line_id
		 AND     (
				  decode(nvl(dem.mfg_lead_time,0),
						 0,updates.new_schedule_date,
                         decode(dem.line_id,
                                dem.ato_line_id, dem.SCHEDULE_SHIP_DATE,
                                mrp_calendar.date_offset(updates.organization_id,
                                                         1,
                                                         updates.new_schedule_date,
                                                         dem.mfg_lead_time)))
												  = dem.SCHEDULE_SHIP_DATE
                 OR
--                (dem.cancelled_flag = 'Y'
                  (NVL(dem.visible_demand_flag,'N') = 'N'
                   and updates.current_available_to_mrp = 'N'))
        AND     updates.new_schedule_quantity =
             DECODE(dem.ORDERED_QUANTITY,
                        NULL, 0,
                        INV_DECIMALS_PUB.GET_PRIMARY_QUANTITY(
                                         dem.SHIP_FROM_ORG_ID,
                                         dem.INVENTORY_ITEM_ID,
                                         dem.ORDER_QUANTITY_UOM,
                                         dem.ORDERED_QUANTITY))
        AND     updates.current_customer_id = dem.SOLD_TO_ORG_ID
        AND     updates.current_ship_id = dem.SHIP_TO_ORG_ID
        AND     updates.current_bill_id = dem.INVOICE_TO_ORG_ID
        AND     NVL(updates.current_demand_class, 'A') =
                        NVL(dem.demand_class_code, 'A')
        AND     updates.process_status <> 3))
    AND     (NOT EXISTS
    (SELECT NULL
     FROM Msc_FORM_QUERY query
        WHERE query.query_id = dem.line_id))
        AND     rownum <= UPDATE_BATCH_SIZE
                                                  -- BUG 2848262, Either record
        AND     (dem.visible_demand_flag = 'Y'    -- can be inserted
                 OR upd.rowid is NOT NULL)        -- OR can be updated
        AND     DECODE(dem.SOURCE_DOCUMENT_TYPE_ID, 10, 8,
                       DECODE(dem.LINE_CATEGORY_CODE, 'ORDER',2,12))
                IN  (MTL_SALES_ORDER, MTL_INT_SALES_ORDER);


    CURSOR MTL_DEMAND_CUR_NEXT IS
        SELECT /*+ ORDERED USE_NL(v, dem,upd,param) */
                dem.inventory_item_id,
                dem.line_id,
                dem.SHIP_FROM_ORG_ID ,
                dem.line_number ,
		        decode(nvl(dem.mfg_lead_time,0),
                       0, dem.SCHEDULE_SHIP_DATE,
                       decode(dem.line_id,
                              dem.ato_line_id, dem.SCHEDULE_SHIP_DATE,
                               MRP_CALENDAR.DATE_OFFSET (dem.ship_from_org_id,
                                                         1,
                                                         dem.schedule_ship_date,
                                                         -1*(dem.mfg_lead_time)))),
                DECODE(dem.ORDERED_QUANTITY,
                           NULL, 0,
                           INV_DECIMALS_PUB.GET_PRIMARY_QUANTITY(
                                    dem.SHIP_FROM_ORG_ID,
                                    dem.INVENTORY_ITEM_ID,
                                    dem.ORDER_QUANTITY_UOM,
                                    dem.ORDERED_QUANTITY)),
                dem.SOLD_TO_ORG_ID,
                dem.SHIP_TO_ORG_ID,
                dem.INVOICE_TO_ORG_ID,
                NVL(visible_demand_flag,'N'),
                dem.demand_class_code,
                DECODE(dem.SHIPPED_QUANTITY,
                           NULL, 0,
                           INV_DECIMALS_PUB.GET_PRIMARY_QUANTITY(
                                    dem.SHIP_FROM_ORG_ID,
                                    dem.INVENTORY_ITEM_ID,
                                    dem.ORDER_QUANTITY_UOM,
                                    dem.SHIPPED_QUANTITY)),
                DECODE(DECODE(dem.ITEM_TYPE_CODE,
                                  'CLASS',2,
                                  'CONFIG',4,
                                  'MODEL',1,
                                  'OPTION' ,3,
                                  'STANDARD',6,
                                  -1),
                       1, dem.inventory_item_id, NULL),
                inv_salesorder.get_salesorder_for_oeheader(dem.HEADER_ID),
                DECODE(dem.ITEM_TYPE_CODE,
                           'CLASS',2,
                           'CONFIG',4,
                           'MODEL',1,
                           'OPTION' ,3,
                           'STANDARD',6,
                           -1),
                dem.ato_line_id,
                upd.rowid
        FROM
                (SELECT DISTINCT line_id
                 FROM MRP_SO_LINES_TEMP
                 WHERE process_status = 3
                 AND   request_id = arg_request_id) V,
                oe_order_lines_all  dem,
                mrp_sales_order_updates upd,
                mtl_parameters  param
        WHERE   NVL(upd.process_status, -1) <> 3
        AND     upd.sales_order_id(+) = dem.line_id
        AND     param.calendar_code IS NOT NULL
        AND     param.calendar_exception_set_id IS NOT NULL
        AND     param.organization_id = decode(dem.cancelled_flag,
                                          'Y', upd.organization_id,
                                           dem.ship_from_org_id)
        AND     dem.SOLD_TO_ORG_ID IS NOT NULL
        AND     dem.SHIP_TO_ORG_ID IS NOT NULL
        AND     dem.INVOICE_TO_ORG_ID IS NOT NULL
    AND     (NOT EXISTS
    (SELECT NULL
     FROM Msc_FORM_QUERY query
     WHERE query.query_id = dem.line_id))
        AND     DECODE(dem.SOURCE_DOCUMENT_TYPE_ID, 10, 8,
                       DECODE(dem.LINE_CATEGORY_CODE, 'ORDER',2,12))
                IN  (MTL_SALES_ORDER, MTL_INT_SALES_ORDER)
        AND     dem.line_id = V.line_id
     ORDER BY dem.line_id;
                                     /* Bug 1997355
                                      * This Order By clause ensures that the
                                      * Configured line is retrieved after
                                      * the model/option class/option
                                      * records
                                      */


    CURSOR MTL_DEMAND_CUR1 IS
        SELECT  demand.rowid
        FROM    mtl_demand_omoe demand
        WHERE   ((EXISTS
                (SELECT NULL
                 FROM   mrp_sales_order_updates updates
                 WHERE  updates.sales_order_id = demand.demand_id
                 AND    updates.old_schedule_date = demand.requirement_date
                 AND    updates.old_schedule_quantity =
                            demand.primary_uom_quantity
                 AND    updates.previous_customer_id = demand.customer_id
                 AND    updates.previous_ship_id = demand.ship_to_site_use_id
                 AND    updates.previous_bill_id = demand.bill_to_site_use_id
                 AND    updates.previous_available_to_mrp =
                            DECODE(demand.available_to_mrp, SYS_YES, 'Y', 'N')
                 AND    NVL(updates.current_demand_class, 'A') =
                            NVL(demand.demand_class, 'A')
                 AND    updates.process_status <> 3))
         OR     demand.demand_source_type NOT IN
                (MTL_SALES_ORDER, MTL_INT_SALES_ORDER)
         OR     demand.parent_demand_id IS NOT NULL
         OR     demand.customer_id IS NULL
         OR     demand.ship_to_site_use_id IS NULL
         OR     demand.bill_to_site_use_id IS NULL
         OR     demand.available_to_mrp IS NULL)
        AND     demand.updated_flag = SYS_YES
        AND     rownum <= UPDATE_BATCH_SIZE
        FOR     UPDATE of demand.updated_flag NOWAIT;

    CURSOR calendar is
        SELECT  DISTINCT calendar_code,
                calendar_exception_set_id,
                param.organization_id
        from    mtl_parameters param,
                mrp_sales_order_updates mrp
        where   param.organization_id = mrp.organization_id
        and     mrp.process_status = 1
        order by calendar_code, calendar_exception_set_id;

    CURSOR cur_model_opt  is
       SELECT  line_id
       FROM    oe_order_lines_all
       WHERE     ato_line_id = var_ato_line_id
       AND     line_id <> var_dem_demand_id
       AND     item_type_code <> 'CONFIG'
       AND     header_id = var_dem_header_id;

                                     /* Bug 1997355.
                                      * Changing oe_order_lines to
                                      * oe_order_lines_ALL in the cursor
                                      * cur_header.
                                      */

                                     /* Bug 2504542.
                                      * There could be multiple config lines
                                      * for same ato_line_id.
                                      * This happens in case an ATO model is
                                      * below a PTO model and the total
                                      * quantity is not shipped at once.
                                      */

    CURSOR config_lines is
      SELECT line_id
      FROM oe_order_lines_all
      WHERE
          ato_line_id = var_ato_line_id
      AND item_type_code = 'CONFIG';

    CURSOR cur_header is
      SELECT header_id from oe_order_lines_all
      where line_id = var_dem_demand_id;

                                     /* Bug 2848262
                                      * Introduced a new cursor -
                                      * so_lines_temp.
                                      * This selects and locks records from the
                                      * table mrp_so_lines_temp that
                                      * can be processed at once.
                                      * With this cursor we can remove
                                      * the costly exclusive lock statement
                                      * on msou.
                                      */

    CURSOR so_lines_temp is
      SELECT mslt.line_id
      FROM   mrp_so_lines_temp mslt
      WHERE
             mslt.process_status = 2
             AND mslt.request_id is NULL
             AND rownum <= UPDATE_BATCH_SIZE
             AND NOT EXISTS
                 (SELECT 1
                  FROM mrp_sales_order_updates upd
                  WHERE
                       upd.sales_order_id = mslt.line_id
                       AND upd.process_status = 3)
             AND NOT EXISTS
                 (SELECT 1
                  FROM mrp_so_lines_temp mslt1
                  WHERE
                       mslt.line_id = mslt1.line_id
                       AND mslt1.process_status = 3)
             FOR UPDATE OF process_status NOWAIT;

BEGIN

  if ( g_om_installed IS NULL ) then
       g_om_installed := oe_install.get_active_product ;
  end if;
  var_old_so_cutoff_days := NVL(TO_NUMBER(
                 FND_PROFILE.VALUE('MRP_OLD_SO_CUTOFF_DAYS')), 99999);

  IF g_om_installed = 'OE' THEN

    LOOP
        rows_updated := 0;
/*
        var_watch_id := mrp_print_pk.start_watch('GEN-updated',
                                                    arg_request_id,
                                                    arg_user_id,
                                                    'ENTITY',
                                                    'mtl_demand(1)',
                                                    'N');

*/
        /*------------------------------------------------------+
        |                                                       |
        | Set updated flag to SYS_NO if none of the attributes  |
        | that affect sales order consumption have changed and  |
        | the sales order is already in MRP_SALES_ORDER_UPDATES |
        |                                                       |
        +------------------------------------------------------*/
        LOOP
            BEGIN
                OPEN mtl_demand_cur1;
                EXIT;
            EXCEPTION
                WHEN busy THEN
                    NULL;
                    dbms_lock.sleep(5);
            END;
        END LOOP;

        LOOP
            FETCH mtl_demand_cur1 INTO
                    var_dem_rowid;
            EXIT WHEN mtl_demand_cur1%NOTFOUND;

            UPDATE  mtl_demand demand
            SET     demand.updated_flag  = SYS_NO
            WHERE    rowid = var_dem_rowid;
            rows_updated := rows_updated + SQL%ROWCOUNT;

        END LOOP;

        CLOSE mtl_demand_cur1;
/*
        mrp_print_pk.stop_watch(arg_request_id,
                                var_watch_id,
                                rows_updated);
*/
        COMMIT;

        IF rows_updated < UPDATE_BATCH_SIZE THEN
            EXIT;
        END IF;

    END LOOP;

/* ------------------------------------------------------+
 | If Installed product is OE, then RETURN  !!!          |
 + ------------------------------------------------------*/
    return;

  END IF;

  -- Determine whether this is the first time the planning manager is run.

                                                              /*2285868*/

  var_first_time :=nvl(FND_PROFILE.VALUE('MRP_PLNG_MGR_FIRST_TIME'),'Y');

  var_debug := FND_PROFILE.VALUE('MRP_DEBUG') = 'Y';
/*
  mrp_print_pk.mrprint('First time : '|| var_first_time,
                       arg_request_id, arg_user_id);

*/

  LOOP

        rows_updated := 0;

        IF (var_first_time = 'N') Then

/*
            var_watch_id := mrp_print_pk.start_watch('GEN-updated',
                                        arg_request_id,
                                        arg_user_id,
                                        'ENTITY',
                                        'mrp_so_lines_temp',
                                        'N');

*/
                                 -- Update the interface table
                                 -- mrp_so_lines_temp.
                                 -- Keep looping until the records in mslt
                                 -- can be locked.

            LOOP
               BEGIN
                  OPEN so_lines_temp;
                  EXIT;
               EXCEPTION
                   WHEN busy THEN
                      NULL;
                      dbms_lock.sleep(5);
               END;
            END LOOP;



            FETCH so_lines_temp BULK COLLECT INTO
                  line_id_arr;


            IF (line_id_arr.COUNT > 0) THEN

               FORALL i in line_id_arr.FIRST..line_id_arr.LAST
                  UPDATE mrp_so_lines_temp
                  SET    process_status = 3,
                         request_id = arg_request_id,
                         last_update_login = arg_user_id,
                         last_update_date = sysdate
                  WHERE
                         line_id = line_id_arr(i)
                         and process_status = 2
                         and request_id IS NULL;

               rows_updated := rows_updated + SQL%ROWCOUNT;

            END IF;
            CLOSE so_lines_temp;

            line_id_arr.DELETE;
/*
            mrp_print_pk.stop_watch(arg_request_id,
                                    var_watch_id,
                                    rows_updated);
*/

            COMMIT;

            IF (rows_updated = 0) THEN

                 EXIT;               -- To take care of the last iteration
                                     -- in the case when NOT first time.
                                     -- Execute the code outside of the
                                     -- main loop.
            END IF;

            IF (rows_updated < UPDATE_BATCH_SIZE) THEN
               var_break_loop := SYS_YES;
            END IF;

        ELSE
                                    -- This is the first time the planning
                                    -- manager is running after creation of
                                    -- the profile option OR it has been
                                    -- reset to 'Yes'
           DELETE FROM mrp_so_lines_temp;

                                    -- BUG 2848262
                                    -- Lock the table msou only if
                                    -- the planning manager is being
                                    -- run for the first time.


/*
           var_watch_id := mrp_print_pk.start_watch('GEN-LOCK TABLE',
                                        arg_request_id,
                                        arg_user_id,
                                        'TABLE',
                                        'mrp_sales_order_updates',
                                        'N',
                                        'DATE',
                                        to_char(sysdate,'dd-mon hh24:mi:ss'),
                                        'Y');

*/

           LOCK TABLE mrp_sales_order_updates IN SHARE ROW EXCLUSIVE MODE;


/*
           mrp_print_pk.stop_watch(arg_request_id,
                                   var_watch_id,
                                   rows_updated);
*/

        END IF;


/*
        var_watch_id := mrp_print_pk.start_watch('GEN-SELECTING',
                                                 arg_request_id,
                                                 arg_user_id,
                                                 'ENTITY',
                                                 'mrp_sales_order_updates',
                                                 'N');
*/

        LOOP
            BEGIN
              IF (var_first_time = 'Y') THEN
                OPEN mtl_demand_cur_first;
              ELSE
                OPEN mtl_demand_cur_next;
              END IF;
              EXIT;
            EXCEPTION
                WHEN busy THEN
                    NULL;
                    dbms_lock.sleep(5);
            END;
        END LOOP;

        /*----------------------------------------------+
        |                                               |
        | Set to IN_PROCESS all rows that are for sales |
        | orders and if the rows are not in MRP_SALES   |
        | ORDER_UPDATES or are not IN_PROCESS           |
        |                                               |
        +----------------------------------------------*/
        counter := 0;
        counter1 := 0;

        insert_count := 0;
        update_count := 0;
        to_insert := 0;
        to_update := 0;

        LOOP

          IF (var_first_time = 'Y') THEN
            FETCH mtl_demand_cur_first INTO
            var_dem_inventory_item_id,
            var_dem_demand_id,
            var_dem_organization_id,
            var_dem_user_line_num,
            var_dem_requirement_date,
            var_dem_primary_uom_quantity,
            var_dem_customer_id,
            var_dem_ship_to_site_use_id,
            var_dem_bill_to_site_use_id,
            var_dem_available_to_mrp,
            var_dem_demand_class,
            var_dem_completed_quantity,
            var_dem_ordered_item,
            var_dem_source_header_id,
            var_dem_demand_type,
	        var_ato_line_id,
            var_upd_rowid;

            EXIT WHEN mtl_demand_cur_first%NOTFOUND;
          ELSE
            FETCH mtl_demand_cur_next INTO
            var_dem_inventory_item_id,
            var_dem_demand_id,
            var_dem_organization_id,
            var_dem_user_line_num,
            var_dem_requirement_date,
            var_dem_primary_uom_quantity,
            var_dem_customer_id,
            var_dem_ship_to_site_use_id,
            var_dem_bill_to_site_use_id,
            var_dem_available_to_mrp,
            var_dem_demand_class,
            var_dem_completed_quantity,
            var_dem_ordered_item,
            var_dem_source_header_id,
            var_dem_demand_type,
	        var_ato_line_id,
            var_upd_rowid;

            EXIT WHEN mtl_demand_cur_next%NOTFOUND;
          END IF;


                        /* Bug 1997355
                         * Need to check for the case when rescheduling a
                         * an ATO Model without delinking from the configured
                         * item that has been created already.
                         */

                        /* Bug 2504542.
                         * Need to do the following, only if the planning
                         * manager is NOT running for the first time.
                         */

          IF ((var_ato_line_id IS NOT NULL) AND
              (var_dem_demand_type <> 4) AND
              (var_first_time = 'N')) THEN

               found_config_item := SYS_NO;
               config_lines_counter := 0;

               FOR k IN 1..max_ato_model_config LOOP
                 IF (ato_model_config_arr(k).ato_line_id = var_ato_line_id) THEN
                     found_config_item := SYS_YES;
                     config_line_id := ato_model_config_arr(k).config_line_id;
                     config_lines_counter := k;
                     EXIT;
                 END IF;
               END LOOP;

               IF (found_config_item = SYS_NO) THEN
                         /* Need to check if the configured item is created.
                          */
                  OPEN config_lines;
                  LOOP

                    FETCH config_lines INTO config_line_id;
                    EXIT WHEN config_lines%NOTFOUND;

                    config_lines_counter := config_lines_counter + 1;
                    max_ato_model_config := max_ato_model_config +1;
                    ato_model_config_arr(max_ato_model_config).ato_line_id :=
                                    var_ato_line_id;
                    ato_model_config_arr(max_ato_model_config).config_line_id :=
                                    config_line_id;

                                 /* Config Item exists. Check if it is a part
                                  * of the request set.
                                  * We need to make sure that the config item
                                  * Line is processed.
                                  *
                                  * Because of the order in which we are
                                  * fetching records from the cursor
                                  * mtl_demand_cur_next, we execute this piece
                                  * of code only for the ATO model.
                                  */

                    BEGIN

                          SELECT /*+ INDEX (t mrp_so_lines_n2) */ 1
                          INTO config_item_exists
                          FROM mrp_so_lines_temp t
                          WHERE process_status = 3
                          AND line_id = config_line_id
                          AND request_id = arg_request_id
                          AND ROWNUM = 1;

                    EXCEPTION WHEN NO_DATA_FOUND THEN
                              config_item_exists := 0;
                    END;

                    IF (config_item_exists = 0) THEN

                         INSERT INTO mrp_so_lines_temp
                            (
                            LAST_UPDATED_BY ,
                            LAST_UPDATE_DATE,
                            CREATION_DATE,
                            CREATED_BY,
                            LAST_UPDATE_LOGIN,
                            line_id,
                            process_status
                            )
                         VALUES
                            (
                            arg_user_id,
                            SYSDATE,
                            SYSDATE,
                            arg_user_id,
                            arg_user_id,
                            config_line_id,
                            2             -- To Be Processed.
                            ) ;
                    END IF;

                  END LOOP;
                  CLOSE config_lines;

                                  /* If a configured line has not been created,
                                   * then we need to insert -1 as the
                                   * configured_line id in the array
                                   * ato_model_config_arr.
                                   */
                  IF (config_lines_counter = 0 ) THEN
                    config_line_id := -1;
                    max_ato_model_config := max_ato_model_config +1;
                    ato_model_config_arr(max_ato_model_config).ato_line_id :=
                                    var_ato_line_id;
                    ato_model_config_arr(max_ato_model_config).config_line_id :=
                                    config_line_id;

                  END IF;

                END IF;
                IF (config_line_id <> -1) THEN
                                  /* We should insert/update 0 for the
                                   * new_schedule_quantity in the table
                                   * mrp_sales_order_updates where the line
                                   * being processed is of model/option class
                                   * or for the option item
                                   */
                    var_dem_primary_uom_quantity := 0;

                END IF;


          END IF;

            IF var_upd_rowid IS NOT NULL THEN

/* 2463192 - Removed the check on completed_quantity since this does not
             affect forecast consumption. */

              to_update := to_update + 1;

              UPDATE mrp_sales_order_updates upd
              SET
                last_update_date    = SYSDATE,
                last_updated_by     = arg_user_id,
                last_update_login   = -1,
                process_status      = 1,
                inventory_item_id   = var_dem_inventory_item_id,
                sales_order_id      = var_dem_demand_id,
                organization_id     = nvl(var_dem_organization_id,
                                          organization_id),
                line_num        = var_dem_user_line_num,
                new_schedule_date   = nvl(var_dem_requirement_date,
                                          new_schedule_date),
                new_schedule_quantity   = var_dem_primary_uom_quantity,
                current_customer_id = var_dem_customer_id,
                current_ship_id     = var_dem_ship_to_site_use_id,
                current_bill_id     = var_dem_bill_to_site_use_id,
                current_available_to_mrp= var_dem_available_to_mrp,
                current_demand_class    = var_dem_demand_class,
                completed_quantity  = var_dem_completed_quantity,
                request_id      = NULL,
		error_message   = NULL
              WHERE  upd.rowid = var_upd_rowid
              AND   ((new_schedule_date <> var_dem_requirement_date)
              OR     (new_schedule_quantity <> var_dem_primary_uom_quantity)
              OR     (current_customer_id <> var_dem_customer_id)
              OR     (current_ship_id <> var_dem_ship_to_site_use_id)
              OR     (current_bill_id <> var_dem_bill_to_site_use_id)
              OR     (current_available_to_mrp <> var_dem_available_to_mrp)
              OR     (NVL(current_demand_class, '734jkhJK24') <>
                                  NVL(var_dem_demand_class, '734jkhJK24')))
              AND inventory_item_id   = var_dem_inventory_item_id
			  AND organization_id = Nvl(var_dem_organization_id,
										  organization_id);

	                    --
              -- update the old values so that this row is not picked up again by
	      -- the mtl_Demand_cur loop

              update_count := update_count + sql%rowcount;
              if (sql%rowcount = 0) then

				 -- Changes for the bug 2296197.
 				 -- Need to check if the Shipping Warehouse (organization_id)
				 -- for the sales order line has been changed.

				 IF (var_dem_organization_id IS NOT NULL) THEN
					-- Check if a record for the new organization_id
					-- exists in the table already.

					SELECT COUNT(*)
					  INTO new_org_rec_count
					  FROM mrp_sales_order_updates
					  WHERE
					  sales_order_id = var_dem_demand_id
					  AND inventory_item_id = var_dem_inventory_item_id
					  AND organization_id = var_dem_organization_id;

					IF (new_org_rec_count = 0) THEN
					   -- There is no record for the new org,
					   -- Need to insert a record for the new org.

					   IF var_dem_available_to_mrp = 'Y' THEN

						  INSERT INTO mrp_sales_order_updates
							(update_seq_num ,
							 last_update_date,
							 last_updated_by,
							 creation_date,
							 created_by,
							 last_update_login,
							 process_status,
							 inventory_item_id,
							 sales_order_id,
							 organization_id,
							 line_num,
							 new_schedule_date,
							 old_schedule_date,
							 new_schedule_quantity,
							 old_schedule_quantity,
							 current_customer_id,
							 previous_customer_id,
							 current_ship_id,
							 previous_ship_id,
							 current_bill_id,
							 previous_bill_id,
							 current_territory_id,
							 previous_territory_id,
							 current_available_to_mrp,
							 previous_available_to_mrp,
							 current_demand_class,
							 previous_demand_class,
							 ordered_item_id,
							 completed_quantity)
							VALUES
							(mrp_sales_order_updates_s.nextval,
							 SYSDATE,
							 arg_user_id,
							 SYSDATE,
							 arg_user_id,
							 -1,
							 1,
							 var_dem_inventory_item_id,
							 var_dem_demand_id,
							 var_dem_organization_id,
							 var_dem_user_line_num,
							 var_dem_requirement_date,
							 NULL,
							 var_dem_primary_uom_quantity,
							 NULL,
							 var_dem_customer_id,
							 NULL,
							 var_dem_ship_to_site_use_id,
							 NULL,
							 var_dem_bill_to_site_use_id,
							 NULL,
							 var_dem_source_header_id,
							 var_dem_source_header_id,
							 var_dem_available_to_mrp,
							 NULL,
							 var_dem_demand_class,
							 NULL,
							 var_dem_ordered_item,
							 var_dem_completed_quantity);

                             insert_count := insert_count + sql%rowcount;
					   END IF;

					END IF;

					-- Need to update the record for the existing
					-- Org(s) to 0.

					UPDATE mrp_sales_order_updates
					  SET
					  last_update_date    = SYSDATE,
					  last_updated_by     = arg_user_id,
					  last_update_login   = -1,
					  process_status      = 1,
					  new_schedule_quantity = 0,
					  request_id      = NULL,
					  error_message = NULL
					  WHERE
					  sales_order_id = var_dem_demand_id
					  AND ( inventory_item_id <> var_dem_inventory_item_id
					     OR organization_id <> var_dem_organization_id)
					  AND new_schedule_quantity <> 0;


                      update_count := update_count + sql%rowcount;
				 END IF;
				 --  Commented out the following update statement
				 --  for the bug 2296197

				 --update mrp_sales_order_updates
				 --  set old_schedule_date=new_schedule_date,
			     --  old_schedule_quantity=new_schedule_quantity,
				 --  previous_customer_id = current_customer_id,
				 --  previous_ship_id = current_ship_id,
				 --  previous_bill_id = current_bill_id
				 --  where rowid = var_upd_rowid;

			  end if;


            ELSIF var_dem_available_to_mrp = 'Y' THEN
              INSERT INTO mrp_sales_order_updates
               (update_seq_num ,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                process_status,
                inventory_item_id,
                sales_order_id,
                organization_id,
                line_num,
                new_schedule_date,
                old_schedule_date,
                new_schedule_quantity,
                old_schedule_quantity,
                current_customer_id,
                previous_customer_id,
                current_ship_id,
                previous_ship_id,
                current_bill_id,
                previous_bill_id,
                current_territory_id,
                previous_territory_id,
                current_available_to_mrp,
                previous_available_to_mrp,
                current_demand_class,
                previous_demand_class,
                ordered_item_id,
                completed_quantity)
             VALUES
                (mrp_sales_order_updates_s.nextval,
                SYSDATE,
                arg_user_id,
                SYSDATE,
                arg_user_id,
                -1,
                1,
                var_dem_inventory_item_id,
                var_dem_demand_id,
                var_dem_organization_id,
                var_dem_user_line_num,
                var_dem_requirement_date,
                NULL,
                var_dem_primary_uom_quantity,
                NULL,
                var_dem_customer_id,
                NULL,
                var_dem_ship_to_site_use_id,
                NULL,
                var_dem_bill_to_site_use_id,
                NULL,
                var_dem_source_header_id,
                var_dem_source_header_id,
                var_dem_available_to_mrp,
                NULL,
                var_dem_demand_class,
                NULL,
                var_dem_ordered_item,
                var_dem_completed_quantity);


                insert_count := insert_count + sql%rowcount;
            END IF;

	    /*
	     *  change the quantitites for model,options to 0 since
             *  config item is being created
	     */
            if(var_dem_demand_type = 4) then
                                  /* Scope for further optimization.
                                   * If the ATO model and Configured item are
                                   * in the same set of records being processed
                                   * then this update of mrp_sales_order_updates
                                   * is redundant as we have already inserted/
                                   * updated the new_schedule_quantity to 0
                                   */

              open cur_header;
              fetch cur_header into var_dem_header_id;
              close cur_header;

	      OPEN CUR_MODEL_OPT;

	      LOOP
	        FETCH cur_model_opt INTO line_ids_except_config;
	        EXIT WHEN CUR_MODEL_OPT%NOTFOUND;

/* 2463192 - update the record only if new_schedule_quantity <> 0 */

                UPDATE mrp_sales_order_updates upd
                SET
                 last_update_date    = SYSDATE,
                 last_updated_by     = arg_user_id,
                 last_update_login   = -1,
                 process_status      = 1,
                 new_schedule_quantity   = 0,
                 current_available_to_mrp = 'N',
                 request_id      = NULL,
                 error_message = NULL
                WHERE  upd.sales_order_id = line_ids_except_config
                and    upd.new_schedule_quantity <> 0;

                update_count := update_count + sql%rowcount;
	       END LOOP;

               CLOSE CUR_MODEL_OPT;

  	    end if;

         if ( g_om_installed IS NULL ) then
           g_om_installed := oe_install.get_active_product ;
         end if;

         IF g_om_installed = 'OE' THEN

            UPDATE  mtl_demand
            SET     updated_flag = SYS_NO
            WHERE   rowid = var_dem_rowid;

          END IF;
/* For Processing a batch of records at a time */
          IF (var_first_time = 'N') THEN
              counter1 := counter1 + 1;
              line_id_arr(counter1) := var_dem_demand_id;
          END IF;

        END LOOP;

        IF (var_first_time = 'Y') THEN
                counter := counter + mtl_demand_cur_first%ROWCOUNT;
                CLOSE mtl_demand_cur_first;

                IF counter < UPDATE_BATCH_SIZE THEN
                  var_break_loop := SYS_YES;
                END IF;
        ELSE
                CLOSE mtl_demand_cur_next;
        END IF;


        IF (var_first_time = 'N') THEN
                IF (var_break_loop = SYS_NO) THEN
                                   -- Update the temp table mrp_so_lines_temp
                                   -- set the line ids that have been processed
                                   -- already to process status 5.
                                   -- For the batch of rows processed.
                  FORALL i IN 1..counter1
                     UPDATE /*+ INDEX (t mrp_so_lines_n2) */ mrp_so_lines_temp t
                     SET process_status  = 5,
                         last_update_login = arg_user_id,
                         last_update_date = sysdate
                     WHERE
                           process_status = 3
                           AND request_id = arg_request_id
                           AND line_id = line_id_arr(i);
                END IF;
        END IF;


/*

        mrp_print_pk.stop_watch(arg_request_id,
                                var_watch_id,
                                counter);

        IF var_debug THEN

           mrp_print_pk.mrprint('Rows to update : '|| to_char(to_update),
                                 arg_request_id, arg_user_id);


           var_watch_id := mrp_print_pk.start_watch('GEN-INSERTED ROWS',
                                                    arg_request_id,
                                                    arg_user_id,
                                                    'NUMBER',
                                                    to_char(insert_count),
                                                    'N',
                                                    'TABLE',
                                                    'mrp_sales_order_updates',
                                                    'N');

           mrp_print_pk.stop_watch(arg_request_id,
                                   var_watch_id);

           var_watch_id := mrp_print_pk.start_watch('GEN-updated',
                                                    arg_request_id,
                                                    arg_user_id,
                                                    'ENTITY',
                                                    'mrp_sales_order_updates',
                                                    'N');

            mrp_print_pk.stop_watch(arg_request_id,
                                    var_watch_id,
                                    update_count);

        END IF;

*/
        /*------------------------------------------------------------+
        |  Update  sales order dates to the last valid workday for    |
        |  sales orders that lie outside the calendar date            |
        +------------------------------------------------------------*/
        OPEN calendar;
        prev_cal_code := 'aggd4885-23453';
        prev_except_set_id := '-23453';


        LOOP
            FETCH calendar into var_cal_code,
                                var_except_set_id,
                                var_org_id;

            EXIT WHEN calendar%NOTFOUND;

            IF prev_cal_code <> var_cal_code OR var_except_set_id <>
                    prev_except_set_id
            THEN


                SELECT  min(calendar_date), max(calendar_date)
                INTO    var_min_cal_date,
                        var_max_cal_date
                FROM    bom_calendar_dates
                WHERE   calendar_code = var_cal_code
                AND     exception_set_id = var_except_set_id;

                prev_cal_code := var_cal_code;
                prev_except_set_id := var_except_set_id;
            END IF;

/*
            IF var_debug THEN

               mrp_print_pk.mrprint('Processing Calendar: '|| var_cal_code,
                                    arg_request_id, arg_user_id);
               mrp_print_pk.mrprint('Min Date : '||
                                    to_char(var_min_cal_date,'DD-MON-RR'),
                                    arg_request_id, arg_user_id);
               mrp_print_pk.mrprint('Max Date : '||
                                    to_char(var_max_cal_date,'DD-MON-RR'),
                                    arg_request_id, arg_user_id);

            END IF;
*/
    	    insert into msc_form_query
		        (query_id   ,
                 last_update_date,
                 last_updated_by,
                 creation_date,
                 created_by,
                 last_update_login)
		    select sales_order_id ,
                       SYSDATE,
                       arg_user_id,
                       SYSDATE,
                       arg_user_id,
                       -1
                from mrp_sales_order_updates
                where organization_id = var_org_id
            and process_status = 1
            and (new_schedule_date < var_min_cal_date
                 or new_schedule_date > var_max_cal_date);

/*
            IF var_debug THEN

               insert_count := sql%rowcount;
               var_watch_id := mrp_print_pk.start_watch('GEN-INSERTED ROWS',
                                                     arg_request_id,
                                                     arg_user_id,
                                                     'NUMBER',
                                                     to_char(insert_count),
                                                     'N',
                                                     'TABLE',
                                                     'msc_form_query',
                                                     'N');

               mrp_print_pk.stop_watch(arg_request_id,
                                       var_watch_id);

            END IF;
*/
/*
            END LOOP;
*/
/*
        IF var_debug THEN


           mrp_print_pk.mrprint('Processed  '|| to_char(calendar%rowcount)
                                 ||' orgs',
                                 arg_request_id, arg_user_id);

        END IF;
*/

/*
       CLOSE calendar;

*/
/*
        IF var_debug THEN


            var_watch_id := mrp_print_pk.start_watch('GEN-updated',
                                                     arg_request_id,
                                                     arg_user_id,
                                                     'ENTITY',
                                                     'mrp_sales_order_updates',
                                                     'N');
        END IF;
*/
        UPDATE  mrp_sales_order_updates upd
            SET     old_schedule_date = GREATEST(var_min_cal_date,
                                LEAST(var_max_cal_date, old_schedule_date)),
                    new_schedule_date = GREATEST(var_min_cal_date,
                             LEAST(var_max_cal_date, new_schedule_date)),
                    process_status = 2
            WHERE   process_status = 1
            AND     organization_id = var_org_id ;

/*
        IF var_debug THEN


            mrp_print_pk.stop_watch(arg_request_id,
                                    var_watch_id,
                                    SQL%ROWCOUNT);

        END IF;
*/
        END LOOP;

           CLOSE calendar;

        COMMIT;

        IF var_break_loop = SYS_YES THEN
            EXIT;
        END IF;

    END LOOP;

  IF (var_first_time = 'N') Then
                                 -- Update the interface table
                                 -- mrp_so_lines_temp.
                                 -- For the last batch of rows.
    FORALL i IN 1..counter1
      UPDATE /*+ INDEX (t mrp_so_lines_n2) */ mrp_so_lines_temp t
      SET process_status  = 5,
          last_update_login = arg_user_id,
          last_update_date = sysdate
      WHERE
          process_status = 3
          AND request_id = arg_request_id
          AND line_id = line_id_arr(i);

                        /* Bug 1997355.
                         * Need to handle a case when a sales order line is
                         * deleted OR a configured item is delinked from it's
                         * model item.
                         * In this case, there will be some records in the table
                         * mrp_so_lines_temp, with the process_status as 3
                         * but their corresponding record is not found in the
                         * table oe_order_lines_all as they have been deleted.
                         */
      UPDATE mrp_sales_order_updates upd
      SET
          last_update_date    = SYSDATE,
          last_updated_by     = arg_user_id,
          last_update_login   = -1,
          process_status      = 2,
          new_schedule_quantity   = 0,
          current_available_to_mrp = 'N',  -- BUG 3445569
          request_id      = NULL,
          error_message = NULL
      WHERE
          sales_order_id IN
          (SELECT line_id
           FROM mrp_so_lines_temp
           WHERE
             process_status = 3
             AND request_id = arg_request_id) ;

                        /*  Now Update these lines in the table
                         * mrp_so_lines_temp to processed.
                         */

      UPDATE mrp_so_lines_temp
      SET process_status  = 5,
          last_update_login = arg_user_id,
          last_update_date = sysdate
      WHERE
          process_status = 3
          AND request_id = arg_request_id ;


  ELSE
                                 -- Set the profile option MRP Planning Manager
                                 -- First Time to No.
    pvalue := fnd_profile.save('MRP_PLNG_MGR_FIRST_TIME', 'N', 'SITE');
  END IF;
  COMMIT;

END compute_sales_order_changes;

-- ********************** update_sales_orders *************************
PROCEDURE update_sales_orders(arg_request_id IN NUMBER,
                             arg_user_id IN NUMBER) IS

    CURSOR lock_mtl_demand_cur IS
    SELECT demand.rowid,
           updates1.new_schedule_quantity,
           updates1.new_schedule_date
    FROM   mtl_demand demand,
           mrp_sales_order_updates updates1
    WHERE  updates1.sales_order_id = demand.demand_id
    AND    updates1.request_id = arg_request_id
    AND    updates1.process_status = 3
    AND    updates1.error_message IS NULL
    FOR UPDATE OF demand.mrp_date NOWAIT;

    var_rowid           ROWID;
    var_date            DATE;
    var_quantity        NUMBER;
    rows_updated        NUMBER := 0;

    busy                EXCEPTION;

    PRAGMA EXCEPTION_INIT(busy, -54);

BEGIN

  if ( g_om_installed IS NULL ) then
           g_om_installed := oe_install.get_active_product ;
  end if;

  IF g_om_installed = 'OE' THEN

    var_watch_id := mrp_print_pk.start_watch('GEN-updated',
                                             arg_request_id,
                                             arg_user_id,
                                             'ENTITY',
                                             'mtl_demand',
                                             'N');
    LOOP
        BEGIN
            OPEN lock_mtl_demand_cur;
            EXIT;
        EXCEPTION
            WHEN busy THEN
                NULL;
                dbms_lock.sleep(5);
        END;
    END LOOP;

    LOOP
        FETCH lock_mtl_demand_cur INTO
                var_rowid,
                var_quantity,
                var_date;
        EXIT WHEN lock_mtl_demand_cur%NOTFOUND;

        UPDATE  mtl_demand demand
        SET     demand.mrp_date = var_date,
                demand.mrp_quantity = var_quantity
        WHERE   rowid = var_rowid;

        rows_updated := rows_updated + SQL%ROWCOUNT;

    END LOOP;

    CLOSE lock_mtl_demand_cur;

    mrp_print_pk.stop_watch(arg_request_id,
                            var_watch_id,
                            rows_updated);

  END IF;

    var_watch_id := mrp_print_pk.start_watch('GEN-updated',
                                             arg_request_id,
                                             arg_user_id,
                                             'ENTITY',
                                             'mrp_sales_order_updates',
                                             'N');
    UPDATE mrp_sales_order_updates
    SET old_schedule_date         = new_schedule_date,
        old_schedule_quantity     = new_schedule_quantity,
        previous_customer_id      = current_customer_id,
        previous_ship_id          = current_ship_id,
        previous_bill_id          = current_bill_id,
        previous_demand_class     = current_demand_class,
        previous_territory_id     = current_territory_id,
        previous_available_to_mrp = current_available_to_mrp,
        process_status            = 5
    WHERE   request_id = arg_request_id
    AND     process_status = 3
    AND     error_message IS NULL;

    mrp_print_pk.stop_watch(arg_request_id,
                            var_watch_id,
                            SQL%ROWCOUNT);

END update_sales_orders;

-- ********************** create_forecast_items *************************
PROCEDURE create_forecast_items(
             arg_request_id IN NUMBER,
             arg_user_id    IN NUMBER,
             arg_desig      IN VARCHAR2) IS
BEGIN

    var_watch_id := mrp_print_pk.start_watch(
                                'GEN-inserting',
                                arg_request_id,
                                arg_user_id,
                                'ENTITY',
                                'E_ITEMS',
                                'Y',
                                'TABLE',
                                'mrp_forecast_items',
                                'N');

    INSERT INTO mrp_forecast_items
           (
            inventory_item_id,
            organization_id,
            forecast_designator,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login
            )
     SELECT  /*+ index (dates MRP_FORECAST_DATES_N1) */
     DISTINCT inventory_item_id,
              organization_id,
              forecast_designator,
              SYSDATE,
              1,
              SYSDATE,
              1,
              -1
     FROM     mrp_forecast_dates dates
     WHERE    NOT EXISTS
              (SELECT NULL
               FROM    mrp_forecast_items items
               WHERE   items.organization_id     = dates.organization_id
                 AND   items.forecast_designator = dates.forecast_designator
                 AND   items.inventory_item_id   = dates.inventory_item_id);

    mrp_print_pk.stop_watch(arg_request_id,
                            var_watch_id,
                            SQL%ROWCOUNT);

END create_forecast_items;

-- ********************** update_forecast_desc_flex *************************
PROCEDURE   update_forecast_desc_flex(arg_row_count   IN OUT NOCOPY  NUMBER) IS
BEGIN

    /*------------------------------------------------------+
    | Copy comments, desc flex, project, and line reference |
    | For line reference, copy only if for the same org     |
    +------------------------------------------------------*/

    UPDATE      mrp_forecast_dates dates1
    SET         (ddf_context, attribute_category,
                 attribute1, attribute2, attribute3,
                 attribute4, attribute5, attribute6,
                 attribute7, attribute8, attribute9,
                 attribute10, attribute11, attribute12,
                 attribute13, attribute14, attribute15,
                 comments, line_id, project_id, task_id)
              = (SELECT dates2.ddf_context, dates2.attribute_category,
                        dates2.attribute1, dates2.attribute2, dates2.attribute3,
                        dates2.attribute4, dates2.attribute5, dates2.attribute6,
                        dates2.attribute7, dates2.attribute8, dates2.attribute9,
                        dates2.attribute10, dates2.attribute11,
                        dates2.attribute12, dates2.attribute13,
                        dates2.attribute14, dates2.attribute15,
                        dates2.comments,
                        DECODE(dates2.organization_id,
                               dates1.organization_id, dates2.line_id, NULL),
                        DECODE(mtl.project_reference_enabled,
                               1, dates2.project_id,
                               NULL),
                        DECODE(mtl.project_reference_enabled,
                               1, DECODE(project_control_level,
                                         2, dates2.task_id,
                                         NULL),
                               NULL)
                 FROM   mtl_parameters        mtl,
                        mrp_forecast_dates    dates2
                 WHERE  dates2.transaction_id = dates1.old_transaction_id
                 AND    dates1.organization_id = mtl.organization_id)
    WHERE       dates1.old_transaction_id >= 0;

    arg_row_count := SQL%ROWCOUNT;

    UPDATE  mrp_forecast_dates
    SET     to_update           = null
    WHERE   old_transaction_id >= 0;

END update_forecast_desc_flex;

-- ********************** update_schedule_desc_flex *************************
PROCEDURE   update_schedule_desc_flex(arg_row_count   IN OUT NOCOPY  NUMBER,
                                      arg_schedule_count IN NUMBER,
                                      arg_forecast_count IN NUMBER,
                                      arg_so_count       IN NUMBER,
                                      arg_interorg_count IN NUMBER) IS
BEGIN


    /*--------------------------------------------------------------+
     | BUG # 2639914                                                |
     | Execute the Update statement based on the value of the new   |
     | input parameters.                                            |
     | Execute the update only if the corresponding counter > 0     |
     +-------------------------------------------------------------*/

    arg_row_count := 0;

  if (nvl(arg_forecast_count,1) > 0) then

    /*-----------------------------------------------------------------------+
    | Copy only comments, project, and line reference for fcst to sched load |
    | For line reference, copy only if for the same org                      |
    | Do not copy end_item_unit_number because it is not stored on forecast  |
    +-----------------------------------------------------------------------*/

    UPDATE      mrp_schedule_dates dates
    SET         (schedule_comments, line_id, project_id, task_id)
              = (SELECT fc_dates.comments,
                        DECODE(fc_dates.organization_id,
                               dates.organization_id, fc_dates.line_id, NULL),
                        DECODE(mtl.project_reference_enabled,
                               1, fc_dates.project_id,
                               NULL),
                        DECODE(mtl.project_reference_enabled,
                               1, DECODE(mtl.project_control_level,
                                         2, fc_dates.task_id,
                                         NULL),
                               NULL)
                 FROM   mtl_parameters         mtl,
                        mrp_forecast_dates     fc_dates
                 WHERE  fc_dates.transaction_id = dates.old_transaction_id
                 AND    dates.organization_id   = mtl.organization_id)
    WHERE       dates.old_transaction_id >= 0
    AND         (dates.schedule_origination_type = 2
    OR           (dates.schedule_origination_type = 8
    AND           dates.source_forecast_designator is not NULL));

    arg_row_count := arg_row_count + SQL%ROWCOUNT;

  end if;

  if (nvl(arg_so_count,1) > 0) then


    /*-------------------------------------------------------------+
    | copy only project reference for sales order to schedule load |
    | copy end_item_unit_number                                    |
    +-------------------------------------------------------------*/

    UPDATE      mrp_schedule_dates dates
    SET         (project_id, task_id, end_item_unit_number)
              = (SELECT DECODE(mtl.project_reference_enabled,
                               1, mrp_manager_pk.get_project_id(dates.reservation_id),
                               NULL),
                        DECODE(mtl.project_reference_enabled,
                               1, DECODE(mtl.project_control_level,
                                         2, mrp_manager_pk.get_task_id(dates.reservation_id),
                                         NULL),
                               NULL),
			mrp_manager_pk.get_unit_number(dates.reservation_id)
                 FROM   mtl_parameters             mtl
                 WHERE  dates.organization_id = mtl.organization_id)
    WHERE       dates.old_transaction_id >= 0
    AND         (dates.schedule_origination_type = 3
    OR           (dates.schedule_origination_type = 8
    AND           dates.source_sales_order_id is not NULL));

    arg_row_count := arg_row_count + SQL%ROWCOUNT;

  end if;


  if (nvl(arg_schedule_count,1) > 0) then


    /*-----------------------------------------------------------------------+
    | Copy comments, desc flex, project, line reference, and                 |
    | end_item_unit_number for sched to sched load                           |
    | Desc flex: only MDS -> MDS or MPS -> MPS                               |
    | Line reference: copy only if for the same org                          |
    +-----------------------------------------------------------------------*/

    UPDATE      mrp_schedule_dates dates1
    SET         (ddf_context, attribute_category,
                 attribute1, attribute2, attribute3,
                 attribute4, attribute5, attribute6,
                 attribute7, attribute8, attribute9,
                 attribute10, attribute11, attribute12,
                 attribute13, attribute14, attribute15,
                 schedule_comments, line_id, project_id, task_id,
                 end_item_unit_number)
              = (SELECT
                 DECODE(sched2.schedule_type,
                        sched1.schedule_type, dates2.ddf_context, NULL),
                 DECODE(sched2.schedule_type,
                        sched1.schedule_type, dates2.attribute_category, NULL),
                 DECODE(sched2.schedule_type,
                        sched1.schedule_type, dates2.attribute1, NULL),
                 DECODE(sched2.schedule_type,
                        sched1.schedule_type, dates2.attribute2, NULL),
                 DECODE(sched2.schedule_type,
                        sched1.schedule_type, dates2.attribute3, NULL),
                 DECODE(sched2.schedule_type,
                        sched1.schedule_type, dates2.attribute4, NULL),
                 DECODE(sched2.schedule_type,
                        sched1.schedule_type, dates2.attribute5, NULL),
                 DECODE(sched2.schedule_type,
                        sched1.schedule_type, dates2.attribute6, NULL),
                 DECODE(sched2.schedule_type,
                        sched1.schedule_type, dates2.attribute7, NULL),
                 DECODE(sched2.schedule_type,
                        sched1.schedule_type, dates2.attribute8, NULL),
                 DECODE(sched2.schedule_type,
                        sched1.schedule_type, dates2.attribute9, NULL),
                 DECODE(sched2.schedule_type,
                        sched1.schedule_type, dates2.attribute10, NULL),
                 DECODE(sched2.schedule_type,
                        sched1.schedule_type, dates2.attribute11, NULL),
                 DECODE(sched2.schedule_type,
                        sched1.schedule_type, dates2.attribute12, NULL),
                 DECODE(sched2.schedule_type,
                        sched1.schedule_type, dates2.attribute13, NULL),
                 DECODE(sched2.schedule_type,
                        sched1.schedule_type, dates2.attribute14, NULL),
                 DECODE(sched2.schedule_type,
                        sched1.schedule_type, dates2.attribute15, NULL),
                 dates2.schedule_comments,
                 DECODE(sched2.organization_id,
                        sched1.organization_id, dates2.line_id, NULL),
                 DECODE(mtl.project_reference_enabled,
                        1, dates2.project_id, NULL),
                 DECODE(mtl.project_reference_enabled,
                        1, DECODE(mtl.project_control_level,
                                  2, dates2.task_id, NULL),
                        NULL),
                 dates2.end_item_unit_number
                 FROM   mtl_parameters              mtl,
                        mrp_schedule_designators    sched1,
                        mrp_schedule_designators    sched2,
                        mrp_schedule_dates          dates2
                 WHERE  dates2.mps_transaction_id  = dates1.old_transaction_id
                 AND    dates2.schedule_level      = dates1.schedule_level
                 AND    sched1.organization_id     = dates1.organization_id
                 AND    sched1.schedule_designator = dates1.schedule_designator
                 AND    sched2.organization_id     = dates2.organization_id
                 AND    sched2.schedule_designator = dates2.schedule_designator
                 AND    mtl.organization_id        = dates1.organization_id)
    WHERE       dates1.old_transaction_id >= 0
    AND         (dates1.schedule_origination_type = 4
    OR           (dates1.schedule_origination_type = 8
    AND           dates1.source_schedule_designator is not NULL));

    arg_row_count := arg_row_count + SQL%ROWCOUNT;

  end if;

  if (nvl(arg_interorg_count,1) > 0) then


    /*------------------------------------------------------------------------+
    | Copy only project reference for interorg planned order to schedule load |
    | Do not copy line reference since they're always for different orgs      |
    | copy end_item_unit_number                                               |
    +------------------------------------------------------------------------*/

    UPDATE      mrp_schedule_dates dates
    SET         (project_id, task_id, end_item_unit_number)
              = (SELECT DECODE(mtl.project_reference_enabled,
                               1, recom.project_id,
                               NULL),
                        DECODE(mtl.project_reference_enabled,
                               1, DECODE(mtl.project_control_level,
                                         2, recom.task_id,
                                         NULL),
                               NULL),
                        NVL(recom.implement_end_item_unit_number,
				recom.end_item_unit_number)
                 FROM   mtl_parameters        mtl,
                        mrp_recommendations   recom
                 WHERE  recom.transaction_id = dates.old_transaction_id
                 AND    dates.organization_id = mtl.organization_id)
    WHERE       dates.old_transaction_id >= 0
    AND         dates.schedule_origination_type = 11;

    arg_row_count := arg_row_count + SQL%ROWCOUNT;

  end if;

    UPDATE  mrp_schedule_dates
    SET     to_update           = null
    WHERE   old_transaction_id >= 0;

EXCEPTION

  WHEN NO_DATA_FOUND THEN
    NULL;
END update_schedule_desc_flex;

-- *************** get_customer_name ************
-- Procedure returns customer name given customer id

FUNCTION get_customer_name(
                            p_customer_id   IN  NUMBER)
RETURN VARCHAR2 IS

  v_customer_name       VARCHAR2(50);

BEGIN

    SELECT part.party_name
    INTO   v_customer_name
    FROM   HZ_PARTIES part,
           HZ_CUST_ACCOUNTS cust
    WHERE  cust.cust_account_id = p_customer_id
    AND    part.party_id = cust.party_id ;

    RETURN v_customer_name;

END get_customer_name;

-- *************** get_ship_address ************
-- Procedure returns ship address given ship id

FUNCTION get_ship_address(
                           p_ship_id      IN NUMBER)
 RETURN VARCHAR2 IS

 v_ship_address         VARCHAR2(240);

BEGIN

    SELECT address1
    INTO   v_ship_address
    FROM   RA_CUSTOMER_SHIP_VIEW
    where  ship_id(+) = p_ship_id;

    RETURN v_ship_address;

END get_ship_address;

-- *************** get_bill_address ************
-- Procedure returns bill address given bill id

FUNCTION get_bill_address(
                           p_bill_id      IN NUMBER)
RETURN VARCHAR2 IS

  v_bill_address        VARCHAR2(240);

BEGIN

    SELECT address1
    INTO   v_bill_address
    FROM   RA_CUSTOMER_BILL_VIEW
    where  bill_id(+) = p_bill_id;

    RETURN v_bill_address;

END get_bill_address;

FUNCTION get_project_id(
	p_demand_id IN NUMBER)
RETURN NUMBER IS

  v_project_id 		NUMBER;

BEGIN

  SELECT project_id
  INTO v_project_id
  FROM oe_order_lines_all
  WHERE line_id = p_demand_id
  AND   visible_demand_flag = 'Y';

  RETURN v_project_id;

END get_project_id;

FUNCTION get_task_id(
	p_demand_id IN NUMBER)
RETURN NUMBER IS

  v_task_id 		NUMBER;

BEGIN

  SELECT task_id
  INTO v_task_id
  FROM oe_order_lines_all
  WHERE line_id = p_demand_id
  AND   visible_demand_flag = 'Y';

  RETURN v_task_id;

END get_task_id;

FUNCTION get_unit_number(
	p_demand_id IN NUMBER)
RETURN VARCHAR2 IS

  v_unit_number		VARCHAR2(30);

BEGIN

  if ( g_om_installed IS NULL ) then
           g_om_installed := oe_install.get_active_product ;
  end if;

/* 1835326 - SVAIDYAN : Uncomment for OM. We need to retrieve the unit
                        numbers for OM also.
*/

  IF g_om_installed = 'OE' THEN

    SELECT NVL(sl.end_item_unit_number, slp.end_item_unit_number)
    INTO v_unit_number
    FROM so_lines_all sl,
	so_lines_all slp,
	mtl_demand_omoe dem
    WHERE slp.line_id(+) = nvl(sl.parent_line_id,sl.line_id)
      AND to_number(dem.demand_source_line) = sl.line_id(+)
      AND dem.demand_source_type in (2,8)
      AND dem.demand_id = p_demand_id;

  ELSE

/* 1835326 - SCHAUDHA : Removed the join to mtl_demand_omoe as the
                        query fetched multiple rows for a sales
                        order line that is reserved against
                        multiple lots.
*/
    SELECT slp.end_item_unit_number
    INTO v_unit_number
    FROM oe_order_lines_all sl,
    oe_order_lines_all slp
    WHERE slp.line_id = nvl(sl.top_model_line_id,sl.line_id)
      AND sl.line_id = p_demand_id;

  END IF;

  RETURN v_unit_number;

END get_unit_number;

END; -- package

/
