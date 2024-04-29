--------------------------------------------------------
--  DDL for Package Body CZ_OM_ATP_CALLBACK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_OM_ATP_CALLBACK" AS
/* $Header: czatpcbb.pls 120.3 2007/05/29 19:59:02 qmao ship $ */

/*
12/05/2002  bug 2614660 fix: all lines related with vendor_name are removed
    using (IN OUT) in extend_atp_record and append_mandatory_comps

01/23/2003  bug 2737013 fix
    1. For consistency, dynamically call MSC_SATP_FUNC.extend_atp to extend atp_rec
       instead of managing it locally in extend_atp_record
    2. Remove counter=1 block and counter-checking code in the main procedure,
       call_atp, i.e., treat counter=1 in the same way as counter>1
    3. Need to check if ATP is configured on a remote DB across a dblink. If profile
       option 'MRP_ATP_DATABASE_LINK' is set, get atp_session_id from remote DB.
       Otherwise, obtain it from local DB
    4. Retrieve any possible error message even when ATP call's return status is success

08/2003 APS patch set J support

05/20/2004 change in get atp session id by calling the new api: MSC_ATP_GLOBAL.get_atp_session_id
   (This requires ATP's new patch 3604429 which contains the ATP team's change for
    APS patch set J in the old patch 3052937)
*/

  EXPLODE_TYPE_INCLUDED   CONSTANT VARCHAR2(10):= 'INCLUDED';
  BOM_BILL_NOT_EXISTS     CONSTANT NUMBER := 9998;
  APS_VERSION_PATCHSET_J  CONSTANT NUMBER := 10;
  aps_version  NUMBER;

  extend_atp_rec_exc  EXCEPTION;

  TYPE num_tbl_type IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
  TYPE uom_tbl_type IS TABLE OF bom_explosions.PRIMARY_UOM_CODE%TYPE INDEX BY PLS_INTEGER;

--------------------------------------------------------------------------------
  -- based on oe_order_sch_util (not a public procedure)
  -- having code here gives us more control anyway, some fields were added
  -- Used only when MSC_SATP_FUNC.extend_atp does not exist
  PROCEDURE extend_atp_record_local(p_count  IN  NUMBER)
  IS
    l_count NUMBER;
  BEGIN
    l_count := p_count;
    g_atp_rec.Inventory_Item_Id.extend(l_count);
    g_atp_rec.Source_Organization_Id.extend(l_count);
    g_atp_rec.organization_id.extend(l_count);
    g_atp_rec.Identifier.extend(l_count);
    g_atp_rec.Calling_Module.extend(l_count);
    g_atp_rec.Customer_Id.extend(l_count);
    g_atp_rec.Customer_Site_Id.extend(l_count);
    g_atp_rec.Destination_Time_Zone.extend(l_count);
    g_atp_rec.Quantity_Ordered.extend(l_count);
    g_atp_rec.Quantity_UOM.extend(l_count);
    g_atp_rec.Requested_Ship_Date.extend(l_count);
    g_atp_rec.Requested_Arrival_Date.extend(l_count);
    g_atp_rec.Earliest_Acceptable_Date.extend(l_count);
    g_atp_rec.Latest_Acceptable_Date.extend(l_count);
    g_atp_rec.Delivery_Lead_Time.extend(l_count);
    g_atp_rec.Atp_Lead_Time.extend(l_count);
    g_atp_rec.Freight_Carrier.extend(l_count);
    g_atp_rec.Ship_Method.extend(l_count);
    g_atp_rec.Demand_Class.extend(l_count);
    g_atp_rec.Ship_Set_Name.extend(l_count);
    g_atp_rec.Arrival_Set_Name.extend(l_count);
    g_atp_rec.Override_Flag.extend(l_count);
    g_atp_rec.Action.extend(l_count);
    g_atp_rec.ship_date.extend(l_count);
    g_atp_rec.Available_Quantity.extend(l_count);
    g_atp_rec.Requested_Date_Quantity.extend(l_count);
    g_atp_rec.Group_Ship_Date.extend(l_count);
    g_atp_rec.Group_Arrival_Date.extend(l_count);
    g_atp_rec.Vendor_Id.extend(l_count);
    g_atp_rec.Vendor_Site_Id.extend(l_count);
    g_atp_rec.Insert_Flag.extend(l_count);
    g_atp_rec.Error_Code.extend(l_count);
    g_atp_rec.Message.extend(l_count);

    -- OE doesn't provide these, might as well try them out
    g_atp_rec.row_id.extend(l_count);
    g_atp_rec.instance_id.extend(l_count);
    g_atp_rec.inventory_item_name.extend(l_count);
    g_atp_rec.source_organization_code.extend(l_count);
    g_atp_rec.demand_source_header_id.extend(l_count);
    g_atp_rec.demand_source_delivery.extend(l_count);
    g_atp_rec.demand_source_type.extend(l_count);
    g_atp_rec.scenario_id.extend(l_count);
    -- g_atp_rec.vendor_name.extend(l_count); -- bug 2614660 fix
    g_atp_rec.vendor_site_name.extend(l_count);
    g_atp_rec.oe_flag.extend(l_count);
    g_atp_rec.end_pegging_id.extend(l_count);

  END extend_atp_record_local;

--------------------------------------------------------------------------------
  -- pre-115.18: extend atp rec locally
  --
  -- 115.18 or later: call MSC_SATP_FUNC.extend_atp dynamically. If the MSC proc
  --                  does not exist, extend atp rec locally
  --
  -- aps patch set j: call msc new api msc_global_atp.extend_atp
  --
  PROCEDURE extend_atp_record(p_count IN NUMBER) IS

  BEGIN
    g_count := p_count;

    IF (aps_version < APS_VERSION_PATCHSET_J) THEN
      EXECUTE IMMEDIATE
         'BEGIN MSC_SATP_FUNC.extend_atp ' ||
         '       (p_atp_tab =>cz_om_atp_callback.g_atp_rec ' ||
         '       ,x_return_status => cz_om_atp_callback.g_return_status ' ||
         '       ,p_index => cz_om_atp_callback.g_count); ' ||
         ' END;';
    ELSE
      MSC_ATP_GLOBAL.extend_atp(g_atp_rec, g_return_status, p_count);
    END IF;

    IF (g_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE extend_atp_rec_exc;
    END IF;

  EXCEPTION
    WHEN extend_atp_rec_exc THEN
      RAISE;

    WHEN OTHERS THEN
      IF (aps_version < APS_VERSION_PATCHSET_J) THEN
        extend_atp_record_local(p_count);
      ELSE
        RAISE;
      END IF;

  END extend_atp_record;

--------------------------------------------------------------------------------
  -- Appends mandatory components returned from cto_config_item_pk
  -- to the original ATP record generated from cz_atp_requests
  PROCEDURE append_mandatory_comps(p_mc_atp_rec IN MRP_ATP_PUB.atp_rec_typ) IS
    l_atp_rec_length NUMBER;
    l_atp_rec_index NUMBER;
    l_num_mandatory_comps NUMBER;
    i NUMBER;

  BEGIN
    -- number of items in ATP record
    l_atp_rec_length := g_atp_rec.quantity_ordered.COUNT;
    -- number of mandatory components to add
    l_num_mandatory_comps := p_mc_atp_rec.quantity_ordered.COUNT;

    extend_atp_record(l_num_mandatory_comps);

    FOR i in 1..l_num_mandatory_comps LOOP
      l_atp_rec_index := i + l_atp_rec_length;

      g_atp_rec.calling_module(l_atp_rec_index) := p_mc_atp_rec.calling_module(i);
      g_atp_rec.identifier(l_atp_rec_index) := p_mc_atp_rec.identifier(i);
      g_atp_rec.ship_set_name(l_atp_rec_index) := p_mc_atp_rec.ship_set_name(i);
      g_atp_rec.action(l_atp_rec_index) := p_mc_atp_rec.action(i);
      g_atp_rec.organization_id(l_atp_rec_index) := p_mc_atp_rec.organization_id(i);
      g_atp_rec.source_organization_id(l_atp_rec_index) :=
        p_mc_atp_rec.source_organization_id(i);
      g_atp_rec.customer_id(l_atp_rec_index) := p_mc_atp_rec.customer_id(i);
      g_atp_rec.customer_site_id(l_atp_rec_index) := p_mc_atp_rec.customer_site_id(i);
      g_atp_rec.requested_ship_date(l_atp_rec_index) :=
        p_mc_atp_rec.requested_ship_date(i);
      g_atp_rec.inventory_item_id(l_atp_rec_index) :=
        p_mc_atp_rec.inventory_item_id(i);
      g_atp_rec.quantity_uom(l_atp_rec_index) := p_mc_atp_rec.quantity_uom(i);
      g_atp_rec.quantity_ordered(l_atp_rec_index) := p_mc_atp_rec.quantity_ordered(i);
      g_atp_rec.destination_time_zone(l_atp_rec_index) :=
        p_mc_atp_rec.destination_time_zone(i);
      g_atp_rec.requested_arrival_date(l_atp_rec_index) :=
        p_mc_atp_rec.requested_arrival_date(i);
      g_atp_rec.earliest_acceptable_date(l_atp_rec_index) :=
        p_mc_atp_rec.earliest_acceptable_date(i);
      g_atp_rec.latest_acceptable_date(l_atp_rec_index) :=
        p_mc_atp_rec.latest_acceptable_date(i);
      g_atp_rec.delivery_lead_time(l_atp_rec_index) :=
        p_mc_atp_rec.delivery_lead_time(i);
      g_atp_rec.atp_lead_time(l_atp_rec_index) :=
        p_mc_atp_rec.atp_lead_time(i);
      g_atp_rec.freight_carrier(l_atp_rec_index) :=
        p_mc_atp_rec.freight_carrier(i);
      g_atp_rec.ship_method(l_atp_rec_index) := p_mc_atp_rec.ship_method(i);
      g_atp_rec.demand_class(l_atp_rec_index) := p_mc_atp_rec.demand_class(i);
      g_atp_rec.arrival_set_name(l_atp_rec_index) :=
        p_mc_atp_rec.arrival_set_name(i);
      g_atp_rec.override_flag(l_atp_rec_index) :=
        p_mc_atp_rec.override_flag(i);
      g_atp_rec.ship_date(l_atp_rec_index) := p_mc_atp_rec.ship_date(i);
      g_atp_rec.group_ship_date(l_atp_rec_index) :=
        p_mc_atp_rec.group_ship_date(i);
      g_atp_rec.available_quantity(l_atp_rec_index) :=
        p_mc_atp_rec.available_quantity(i);
      g_atp_rec.requested_date_quantity(l_atp_rec_index) :=
        p_mc_atp_rec.requested_date_quantity(i);
      g_atp_rec.group_arrival_date(l_atp_rec_index) :=
        p_mc_atp_rec.group_arrival_date(i);
      g_atp_rec.vendor_id(l_atp_rec_index) := p_mc_atp_rec.vendor_id(i);
      g_atp_rec.vendor_site_id(l_atp_rec_index) :=
        p_mc_atp_rec.vendor_site_id(i);
      g_atp_rec.insert_flag(l_atp_rec_index) := p_mc_atp_rec.insert_flag(i);
      g_atp_rec.error_code(l_atp_rec_index) := p_mc_atp_rec.error_code(i);
      g_atp_rec.message(l_atp_rec_index) := p_mc_atp_rec.message(i);
      g_atp_rec.row_id(l_atp_rec_index) := p_mc_atp_rec.row_id(i);
      g_atp_rec.instance_id(l_atp_rec_index) := p_mc_atp_rec.instance_id(i);
      g_atp_rec.inventory_item_name(l_atp_rec_index) :=
        p_mc_atp_rec.inventory_item_name(i);
      g_atp_rec.source_organization_code(l_atp_rec_index) :=
        p_mc_atp_rec.source_organization_code(i);
      g_atp_rec.demand_source_header_id(l_atp_rec_index) :=
        p_mc_atp_rec.demand_source_header_id(i);
      g_atp_rec.demand_source_delivery(l_atp_rec_index) :=
        p_mc_atp_rec.demand_source_delivery(i);
      g_atp_rec.demand_source_type(l_atp_rec_index) :=
        p_mc_atp_rec.demand_source_type(i);
      g_atp_rec.scenario_id(l_atp_rec_index) := p_mc_atp_rec.scenario_id(i);
      -- g_atp_rec.vendor_name(l_atp_rec_index) := p_mc_atp_rec.vendor_name(i); -- bug 2614660 fix
      g_atp_rec.vendor_site_name(l_atp_rec_index) :=
        p_mc_atp_rec.vendor_site_name(i);
      g_atp_rec.oe_flag(l_atp_rec_index) := p_mc_atp_rec.oe_flag(i);
      g_atp_rec.end_pegging_id(l_atp_rec_index) := p_mc_atp_rec.end_pegging_id(i);
    END LOOP;

  END append_mandatory_comps;

--------------------------------------------------------------------------------
-- bug 5723470: cto only returns ATO's MCs, so we need to get PTO's MCs on our own
-- g_atp_rec contains the recs from cz runtime as well as ATO MCs (if any) from cto
-- p_count number of atp records from cz runtime
PROCEDURE get_pto_mandatory_components(p_top_item_id     IN NUMBER
                                      ,p_organization_id IN NUMBER
                                      ,p_count           IN NUMBER
                                      ,x_itm_tbl    OUT NOCOPY num_tbl_type
                                      ,x_qty_tbl    OUT NOCOPY num_tbl_type
                                      ,x_uom_tbl    OUT NOCOPY uom_tbl_type
                                      ,x_ret_status OUT NOCOPY NUMBER
                                      ,x_msg_data   OUT NOCOPY VARCHAR2
                                      )
IS
  l_pto_flag   mtl_system_items_b.pick_components_flag%TYPE;
  l_grp_id     NUMBER;
  l_err_code   NUMBER;
  l_err_msg    VARCHAR2(2000);

  l_itm_tbl  num_tbl_type;
  l_qty_tbl  num_tbl_type;
  l_uom_tbl  uom_tbl_type;
  l_count    INTEGER;

BEGIN
  x_ret_status := 0;

  SELECT UPPER(pick_components_flag) INTO l_pto_flag
  FROM mtl_system_items_b
  WHERE inventory_item_id = p_top_item_id AND organization_id = p_organization_id;

  IF l_pto_flag <> 'Y' THEN
    RETURN;
  END IF;

  l_count := 0;
  FOR i IN g_atp_rec.inventory_item_id.FIRST .. p_count LOOP
    IF g_atp_rec.inventory_item_id(i) <> p_top_item_id THEN
      SELECT UPPER(pick_components_flag) INTO l_pto_flag
      FROM mtl_system_items_b
      WHERE inventory_item_id = g_atp_rec.inventory_item_id(i)
      AND organization_id = p_organization_id;
    END IF;

    -- l_err_code := 0;
    IF l_pto_flag = 'Y' THEN
      bompnord.bmxporder_explode_for_order(
           org_id             => p_organization_id,
           copy_flag          => 2,
           expl_type          => EXPLODE_TYPE_INCLUDED,
           order_by           => 2,
           grp_id             => l_grp_id,
           session_id         => 0,
           levels_to_explode  => 60,
           item_id            => g_atp_rec.inventory_item_id(i),
           rev_date           => to_char(SYSDATE,'YYYY/MM/DD HH24:MI'),
           user_id            => 0,
           commit_flag        => 'N',
           err_msg            => l_err_msg,
           error_code         => l_err_code);

      IF l_err_code = 0 THEN
        l_itm_tbl.DELETE;
        l_qty_tbl.DELETE;
        l_uom_tbl.DELETE;
        -- Note bom explosion with included mode only contains mc std items
        -- otherwise we would need to check bom_item_type = 4
        SELECT component_item_id, extended_quantity, primary_uom_code
        BULK COLLECT INTO l_itm_tbl, l_qty_tbl, l_uom_tbl
        FROM bom_explosions
        WHERE explosion_type = EXPLODE_TYPE_INCLUDED
        AND plan_level > 0
        AND extended_quantity > 0
        AND TOP_BILL_SEQUENCE_ID =
            (SELECT bill_sequence_id
             FROM bom_bill_of_materials
             WHERE assembly_item_id = g_atp_rec.inventory_item_id(i)
             AND organization_id = p_organization_id
             AND ALTERNATE_BOM_DESIGNATOR IS NULL)
        AND EFFECTIVITY_DATE <= SYSDATE AND DISABLE_DATE > SYSDATE; -- AND check_atp = 1?

        IF l_itm_tbl.COUNT > 0 THEN
          FOR j IN l_itm_tbl.FIRST .. l_itm_tbl.LAST LOOP
            l_count := l_count + 1;
            x_itm_tbl(l_count) := l_itm_tbl(j);
            x_qty_tbl(l_count) := l_qty_tbl(j) * g_atp_rec.quantity_ordered(i);
            x_uom_tbl(l_count) := l_uom_tbl(j);
          END LOOP;
        END IF;

      ELSIF l_err_code <> BOM_BILL_NOT_EXISTS THEN
        x_ret_status := l_err_code;
        x_msg_data := 'Bom exploding error with item ' || to_char(g_atp_rec.inventory_item_id(i))
                   || substr(l_err_msg, 1, 1950);
        RETURN;
      END IF;
    END IF;
  END LOOP;
END get_pto_mandatory_components;

PROCEDURE set_null_fields(p_counter IN NUMBER)
IS
BEGIN
  -- providing these either because they are output params or because
  -- oe_order_sch_util provides them
  g_atp_rec.destination_time_zone(p_counter) := null;
  g_atp_rec.requested_arrival_date(p_counter) := null;
  g_atp_rec.earliest_acceptable_date(p_counter) := null;
  g_atp_rec.latest_acceptable_date(p_counter) := null;
  g_atp_rec.delivery_lead_time(p_counter) := null;
  g_atp_rec.atp_lead_time(p_counter) := null;
  g_atp_rec.freight_carrier(p_counter) := null;
  g_atp_rec.ship_method(p_counter) := null;
  g_atp_rec.demand_class(p_counter) := null;
  g_atp_rec.arrival_set_name(p_counter) := null;
  g_atp_rec.override_flag(p_counter) := null;
  g_atp_rec.ship_date(p_counter) := null;
  g_atp_rec.group_ship_date(p_counter) := null;
  g_atp_rec.available_quantity(p_counter) := null;
  g_atp_rec.requested_date_quantity(p_counter) := null;
  g_atp_rec.group_arrival_date(p_counter) := null;
  g_atp_rec.vendor_id(p_counter) := null;
  g_atp_rec.vendor_site_id(p_counter) := null;
  g_atp_rec.insert_flag(p_counter) := null;
  g_atp_rec.error_code(p_counter) := null;
  g_atp_rec.message(p_counter) := null;

  -- the OE procedure doesn't provide these, but I might as well try
  g_atp_rec.row_id(p_counter) := null;
  g_atp_rec.instance_id(p_counter) := null;
  g_atp_rec.inventory_item_name(p_counter) := null;
  g_atp_rec.source_organization_code(p_counter) := null;
  g_atp_rec.demand_source_header_id(p_counter) := null;
  g_atp_rec.demand_source_delivery(p_counter) := null;
  g_atp_rec.demand_source_type(p_counter) := null;
  g_atp_rec.scenario_id(p_counter) := null;
  -- g_atp_rec.vendor_name(p_counter) := null; -- bug 2614660 fix
  g_atp_rec.vendor_site_name(p_counter) := null;
  g_atp_rec.oe_flag(p_counter) := null;
  g_atp_rec.end_pegging_id(p_counter) := null;
END set_null_fields;

--------------------------------------------------------------------------------
  -- Main procedure, calls MRP ATP procedure
  --
  -- REQUIRED params - p_config_session_key, p_requested_date
  -- and one of the following:
  --   1. p_warehouse_id
  --   2. p_ship_to_org_id
  --   3. p_customer_id and p_customer_site_id
  -- NOTES: For 11.5.1, p_warehouse_id is REQUIRED
  --        If p_requested_date is NULL, SYSDATE will be used
  PROCEDURE call_atp (p_config_session_key IN VARCHAR2,
                      p_warehouse_id IN NUMBER,
                      p_ship_to_org_id IN NUMBER,
                      p_customer_id IN NUMBER,
                      p_customer_site_id IN NUMBER,
                      p_requested_date IN DATE,
                      p_ship_to_group_date OUT NOCOPY DATE) IS
    PRAGMA AUTONOMOUS_TRANSACTION;

    CURSOR atp_requests IS
      SELECT atp_request_id, seq_no, ps_node_id, item_key, item_key_type,
             quantity, uom_code, config_item_id, parent_config_item_id,
             ato_config_item_id, component_sequence_id
      FROM cz_atp_requests
      WHERE configurator_session_key = p_config_session_key
      ORDER BY seq_no;

    -- future: add need_by_date, days_late
    CURSOR update_atp_requests IS
      SELECT * FROM cz_atp_requests WHERE configurator_session_key
             = p_config_session_key ORDER BY seq_no FOR UPDATE OF
             ship_to_date, msg_data;

    l_counter NUMBER;
    l_requested_date DATE;
    l_ship_date      DATE;
    l_atp_row_count NUMBER;
    l_atp_row atp_requests%ROWTYPE;
    l_atp_update_row update_atp_requests%ROWTYPE;
    l_atp_rec  MRP_ATP_PUB.atp_rec_typ;
    l_ship_set_name VARCHAR2(30);
    l_top_model_line_id NUMBER;
    l_validation_org  NUMBER;
    l_pto_model_flag  mtl_system_items.pick_components_flag%TYPE;

    -- variables used for mandatory component addition
    l_mc_result NUMBER;
    l_mc_atp_rec MRP_ATP_PUB.atp_rec_typ;
    l_mc_error VARCHAR2(2000);
    l_mc_message_name VARCHAR2(100);
    l_mc_tbl_name VARCHAR2(100);
    l_mc_exception EXCEPTION;

    l_pto_mc_exception EXCEPTION;
    l_itm_tbl  num_tbl_type;
    l_qty_tbl  num_tbl_type;
    l_uom_tbl  uom_tbl_type;
    l_err_code NUMBER;

    -- inventory item ID of model
    l_model_inv_item_id NUMBER;

    l_action NUMBER;
    l_cz_appl_id NUMBER;
    l_atp_session_id NUMBER;
    l_atp_supply_demand MRP_ATP_PUB.atp_supply_demand_typ;
    l_atp_period MRP_ATP_PUB.atp_period_typ;
    l_atp_details MRP_ATP_PUB.atp_details_typ;
    l_return_status VARCHAR2(10);
    l_msg_data VARCHAR2(2000);
    l_msg_count NUMBER;
    l_error_msg_count NUMBER;

    l_warehouse_id_exc    EXCEPTION;
    l_call_atp_exc        EXCEPTION;
    l_validation_org_exc  EXCEPTION;
    l_atp_session_id_exc  EXCEPTION;

    l_ndebug  NUMBER;

    empty_atp_rec         MRP_ATP_PUB.ATP_Rec_Typ;
  BEGIN
    l_ndebug := 0;
    cz_utils.log_report('cz_om_atp_callback', 'call_atp', l_ndebug,
        'CZ session ' || p_config_session_key || ': starting cz_om_atp_callback.call_atp',
         fnd_log.LEVEL_PROCEDURE);

    aps_version := MSC_ATP_GLOBAL.get_aps_version;
    l_ndebug := 1;
    cz_utils.log_report('cz_om_atp_callback', 'call_atp', l_ndebug,
        'aps_version ' || aps_version, fnd_log.LEVEL_PROCEDURE);

    g_atp_rec := empty_atp_rec;

    -- 11.5.1 limitation, warehouse_id is REQUIRED
    IF p_warehouse_id IS NULL AND aps_version < APS_VERSION_PATCHSET_J THEN
      raise l_warehouse_id_exc;
    END IF;

    IF p_requested_date IS NULL THEN
      l_requested_date := sysdate;
    ELSE
      l_requested_date := p_requested_date;
    END IF;

    -- determine array size
    SELECT count(*) INTO l_atp_row_count FROM cz_atp_requests
    WHERE configurator_session_key = p_config_session_key;

    extend_atp_record(l_atp_row_count);
    l_ndebug := 2;

    l_counter := 1;
    -- 100 is value for OE_ORDER_SCH_UTIL.OESCH_ACT_ATP_CHECK
    -- don't know why the number isn't stored in a constant
    -- 100 - ATP Inquiry (see ATP white paper)
    l_action := 100;
    l_cz_appl_id := 708;
    l_ship_set_name := 'A';
    FOR l_atp_row IN atp_requests LOOP
      IF (aps_version >= APS_VERSION_PATCHSET_J) THEN
        IF (l_counter = 1) THEN
          l_top_model_line_id := l_atp_row.config_item_id;
          l_validation_org := cz_utils.conv_num(oe_sys_parameters.value('MASTER_ORGANIZATION_ID'));
          IF (l_validation_org IS NULL) THEN
            RAISE l_validation_org_exc;
          END IF;
        END IF;
        g_atp_rec.ato_model_line_id(l_counter) := l_atp_row.ato_config_item_id;
        g_atp_rec.parent_line_id(l_counter) := l_atp_row.parent_config_item_id;
        g_atp_rec.top_model_line_id(l_counter) := l_top_model_line_id;
        -- Let MRP/MSC explode std MCs for PTO components? 1 or null - No, 2 - Yes
        -- Note MRP/MSC always explodes ATO's std MCs
        g_atp_rec.included_item_flag(l_counter) := 2;
        g_atp_rec.validation_org(l_counter) := l_validation_org;
        g_atp_rec.component_sequence_id(l_counter) := l_atp_row.component_sequence_id;
        g_atp_rec.component_code(l_counter) :=
             substr(l_atp_row.item_key, 1, instr(l_atp_row.item_key, ':')-1);
      END IF;

      g_atp_rec.calling_module(l_counter) := l_cz_appl_id;
      g_atp_rec.identifier(l_counter) := l_atp_row.config_item_id; -- line_id
      g_atp_rec.ship_set_name(l_counter) := l_ship_set_name;
      g_atp_rec.action(l_counter) := l_action;
      g_atp_rec.organization_id(l_counter) := p_ship_to_org_id;
      g_atp_rec.source_organization_id(l_counter) := p_warehouse_id;
      g_atp_rec.customer_id(l_counter) := p_customer_id;
      g_atp_rec.customer_site_id(l_counter) := p_customer_site_id;
      g_atp_rec.requested_ship_date(l_counter) := l_requested_date;
      g_atp_rec.inventory_item_id(l_counter) :=
      cz_atp_callback_util.inv_item_id_from_item_key(l_atp_row.item_key);
      g_atp_rec.quantity_uom(l_counter) := l_atp_row.uom_code;
      g_atp_rec.quantity_ordered(l_counter) := l_atp_row.quantity;
      set_null_fields(l_counter);
      l_counter := l_counter + 1;
    END LOOP;

    l_ndebug := 3;

    IF (aps_version < APS_VERSION_PATCHSET_J) THEN
      -- add mandatory components to g_atp_rec
      cz_utils.log_report('cz_om_atp_callback', 'call_atp', l_ndebug,
          'Before calling get_mandatory_comps.', fnd_log.LEVEL_PROCEDURE);
      l_model_inv_item_id := g_atp_rec.inventory_item_id(1);
      l_mc_result :=
        cto_config_item_pk.get_mandatory_components(g_atp_rec,
          p_warehouse_id, l_model_inv_item_id, l_mc_atp_rec,
          l_mc_error, l_mc_message_name, l_mc_tbl_name);

      l_ndebug := 4;
      cz_utils.log_report('cz_om_atp_callback', 'call_atp', l_ndebug,
          'After calling get_mandatory_comps.', fnd_log.LEVEL_PROCEDURE);

      IF l_mc_result = 0 THEN
        raise l_mc_exception;
      END IF;

      append_mandatory_comps(l_mc_atp_rec);

      get_pto_mandatory_components(l_model_inv_item_id
                                  ,cz_atp_callback_util.validation_org_for_cfg_model(p_config_session_key)
                                  ,l_atp_row_count
                                  ,l_itm_tbl
                                  ,l_qty_tbl
                                  ,l_uom_tbl
                                  ,l_err_code
                                  ,l_msg_data);
      IF l_err_code <> 0 THEN
        RAISE l_pto_mc_exception;
      END IF;

      IF l_itm_tbl.COUNT > 0 THEN
        extend_atp_record(l_itm_tbl.COUNT);
        l_counter := l_atp_row_count + l_mc_atp_rec.inventory_item_id.COUNT + 1;
        FOR i IN l_itm_tbl.FIRST .. l_itm_tbl.LAST LOOP
          g_atp_rec.calling_module(l_counter) := l_cz_appl_id;
          g_atp_rec.identifier(l_counter) := i;
          g_atp_rec.ship_set_name(l_counter) := l_ship_set_name;
          g_atp_rec.action(l_counter) := l_action;
          g_atp_rec.organization_id(l_counter) := p_ship_to_org_id;
          g_atp_rec.source_organization_id(l_counter) := p_warehouse_id;
          g_atp_rec.customer_id(l_counter) := p_customer_id;
          g_atp_rec.customer_site_id(l_counter) := p_customer_site_id;
          g_atp_rec.requested_ship_date(l_counter) := l_requested_date;
          g_atp_rec.inventory_item_id(l_counter) := l_itm_tbl(i);
          g_atp_rec.quantity_uom(l_counter) := l_uom_tbl(i);
          g_atp_rec.quantity_ordered(l_counter) := l_qty_tbl(i);
          set_null_fields(l_counter);
          l_counter := l_counter + 1;
        END LOOP;
      END IF;
    END IF;
    l_ndebug := 5;

    -- calculate ATP
    MSC_ATP_GLOBAL.get_atp_session_id(l_atp_session_id, l_return_status);
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      raise l_atp_session_id_exc;
    END IF;

    l_ndebug := 6;
    cz_utils.log_report('cz_om_atp_callback', 'call_atp', l_ndebug,
        'CZ session ' || p_config_session_key || ': calling mrp_atp_pub.call_atp with ATP session ID '
        || l_atp_session_id, fnd_log.LEVEL_PROCEDURE);
    l_atp_rec := g_atp_rec;
    MRP_ATP_PUB.call_atp(l_atp_session_id, l_atp_rec,
                         g_atp_rec, l_atp_supply_demand,
                         l_atp_period, l_atp_details,
                         l_return_status, l_msg_data,
                         l_msg_count);
    l_ndebug := 7;
    cz_utils.log_report('cz_om_atp_callback', 'call_atp', l_ndebug,
        'CZ session ' || p_config_session_key || ': mrp_atp_pub.call_atp - Ret.Status : '
        || l_return_status, fnd_log.LEVEL_PROCEDURE);
    cz_utils.log_report('cz_om_atp_callback', 'call_atp', l_ndebug,
        'CZ session ' || p_config_session_key || ': mrp_atp_pub.call_atp - Msg.Data : '
        || l_msg_data, fnd_log.LEVEL_PROCEDURE);
    cz_utils.log_report('cz_om_atp_callback', 'call_atp', l_ndebug,
        'CZ session ' || p_config_session_key || ': mrp_atp_pub.call_atp - Msg.Count : '
        || l_msg_count, fnd_log.LEVEL_PROCEDURE);

    -- For expected errors, ATP populates the error_code for each record in atp_rec_typ.
    -- The error_code is defined by the lookup_type 'MTL_DEMAND_INTERFACE_ERRORS' in the
    -- table mfg_lookups.
    -- Display error messages in ATP notification window by selecting 'meaning' for the given error_codes
    -- bug 2737013 fix: retrieve any possible error message even when the return status is success
    IF l_return_status = FND_API.G_RET_STS_ERROR OR l_return_status = FND_API.G_RET_STS_SUCCESS THEN
      l_error_msg_count := g_atp_rec.error_code.COUNT;
      cz_utils.log_report('cz_om_atp_callback', 'call_atp', l_ndebug,
        'Known Error ... Count : ' || l_error_msg_count, fnd_log.LEVEL_STATEMENT);

      -- Note: In aps patchset j, the returned g_atp_rec.message from MRP is uninitialized
      -- (see bug 3358937). So here we use l_atp_rec.message for storing err msg instead.
      -- here we are assuming g_atp_rec.error_code always initialized
      FOR i in 1..l_error_msg_count LOOP
        cz_utils.log_report('cz_om_atp_callback', 'call_atp', l_ndebug,
          'Get err message ' || i  || ' Err Code :' || g_atp_rec.error_code(i),
           fnd_log.LEVEL_STATEMENT);
        if g_atp_rec.error_code(i) is null  or g_atp_rec.error_code(i) = -99
                   OR g_atp_rec.error_code(i) = 61 -- filter out "atp not applicable" message
                   OR g_atp_rec.error_code(i) = 0 then
          l_atp_rec.message(i) := NULL;
	else
          SELECT meaning INTO l_atp_rec.message(i)
          FROM mfg_lookups
          WHERE lookup_type = 'MTL_DEMAND_INTERFACE_ERRORS'
            AND lookup_code = g_atp_rec.error_code(i);
	end if;
        cz_utils.log_report('cz_om_atp_callback', 'call_atp', l_ndebug,
                            'Lookup Err. Message : ' || l_atp_rec.message(i),
                            fnd_log.LEVEL_STATEMENT);
      END LOOP;

    -- will display error message using x_msg_data returned from MRP_ATP_PUB.CALL_ATP
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      cz_utils.log_report('cz_om_atp_callback', 'call_atp', l_ndebug,
        'UnExpected Error from ...', fnd_log.LEVEL_STATEMENT);
      RAISE l_call_atp_exc;
    END IF;

    -- run through results, populate cz_atp_requests
    -- NOTE: this may need to change, depending on what happens
    --       with mandatory comps

    l_ndebug := 8;
    l_counter := 1;
    FOR l_atp_update_row IN update_atp_requests LOOP
      -- no date should be displayed if error code is -99
      if (g_atp_rec.error_code(l_counter) = -99) then
        l_ship_date := null;
      else
        l_ship_date := g_atp_rec.ship_date(l_counter);
      end if;

      cz_utils.log_report('cz_om_atp_callback', 'call_atp', l_ndebug,
        p_config_session_key || ': updating ATP requests rec, l_ship_date: ' ||
           to_char(l_ship_date, 'MM-DD-YYYY HH24:MI:SS'),
        fnd_log.LEVEL_STATEMENT);

      cz_utils.log_report('cz_om_atp_callback', 'call_atp', l_ndebug,
        'Updating ATP requests rec, message: ' || l_atp_rec.message(l_counter),
        fnd_log.LEVEL_STATEMENT);

      -- if atp returns need_by_date and days_late in g_atp_rec
      -- we will update the fields here

      UPDATE cz_atp_requests SET msg_data = l_atp_rec.message(l_counter),
                                 ship_to_date = l_ship_date
      WHERE CURRENT OF update_atp_requests;

      l_counter := l_counter + 1;
    END LOOP;
    COMMIT;

    l_ndebug := 9;
    -- return group ship date
    -- the following logic will be changed because there are some special cases
    p_ship_to_group_date := g_atp_rec.group_ship_date(1);
    IF (aps_version >= APS_VERSION_PATCHSET_J) THEN
      SELECT pick_components_flag INTO l_pto_model_flag
      FROM mtl_system_items
      WHERE inventory_item_id = g_atp_rec.inventory_item_id(1)
      AND organization_id = l_validation_org;

      cz_utils.log_report('cz_om_atp_callback', 'call_atp', l_ndebug,
        'Top model is a pto? ' || l_pto_model_flag, fnd_log.LEVEL_STATEMENT);

      IF (upper(l_pto_model_flag) <> 'Y') THEN
        p_ship_to_group_date := g_atp_rec.ship_date(1);
      END IF;

      -- if atp provides an api for retrieving need_by_date and days_late,
      -- we will need to put those outputs into cz_atp_requests

    END IF;

    l_ndebug := 10;
    cz_utils.log_report('cz_om_atp_callback', 'call_atp', l_ndebug,
      'CZ session ' || p_config_session_key || ': returning group ship date: '
      || To_char(p_ship_to_group_date), fnd_log.LEVEL_PROCEDURE);
    g_atp_rec := empty_atp_rec;

  EXCEPTION
    WHEN extend_atp_rec_exc THEN
      g_atp_rec := empty_atp_rec;
      cz_utils.log_report('cz_om_atp_callback', 'call_atp', l_ndebug,
         'Unexpected error in cz_om_atp_callback returned from MSC_SATP_FUNC.extend_atp',
          fnd_log.LEVEL_ERROR);
      UPDATE cz_atp_requests SET msg_data = 'Error in executing MSC_SATP_FUNC.extend_atp'
      WHERE configurator_session_key = p_config_session_key
      AND seq_no = 1;
      COMMIT;

    WHEN l_validation_org_exc THEN
       g_atp_rec := empty_atp_rec;
       cz_utils.log_report('cz_om_atp_callback', 'call_atp', l_ndebug,
          'Unexpected error in cz_om_atp_callback: NULL organization id returned from ' ||
                 'oe_sys_parameters.value(MASTER_ORGANIZATION_ID)', fnd_log.LEVEL_ERROR);
       UPDATE cz_atp_requests SET msg_data = 'Error in executing oe_sys_parameters.value for ' ||
                                             'MASTER_ORGANIZATION_ID: Null value returned'
       WHERE configurator_session_key = p_config_session_key
       AND seq_no = 1;
      COMMIT;

    WHEN l_mc_exception THEN
      g_atp_rec := empty_atp_rec;
      cz_utils.log_report('cz_om_atp_callback', 'call_atp', l_ndebug,
         'Error in mandatory comp expl proc: '|| l_mc_error,
          fnd_log.LEVEL_ERROR);
      UPDATE cz_atp_requests SET msg_data =
        'Mandatory comp expl error: ' || l_mc_error
      WHERE configurator_session_key = p_config_session_key
        AND seq_no = 1;
      COMMIT;
    WHEN l_warehouse_id_exc THEN
      cz_utils.log_report('cz_om_atp_callback', 'call_atp', l_ndebug,
         'No warehouse supplied to ATP call.', fnd_log.LEVEL_ERROR);
      UPDATE cz_atp_requests SET msg_data = CZ_UTILS.GET_TEXT('CZ_ATP_NO_WAREHOUSE')
      WHERE configurator_session_key = p_config_session_key
        AND seq_no = 1;
      COMMIT;

    WHEN l_atp_session_id_exc THEN
     l_msg_data := 'Fail in getting an atp session id from MSC_ATP_GLOBAL';
     cz_utils.log_report('cz_om_atp_callback', 'call_atp', l_ndebug,
                         l_msg_data, fnd_log.LEVEL_ERROR);
      UPDATE cz_atp_requests SET msg_data = l_msg_data
      WHERE configurator_session_key = p_config_session_key
        AND seq_no = 1;
      COMMIT;

    WHEN l_call_atp_exc THEN
      g_atp_rec := empty_atp_rec;
      cz_utils.log_report('cz_om_atp_callback', 'call_atp', l_ndebug,
         'Unexpected error in cz_om_atp_callback returned from mrp_atp_pub: ' || l_msg_data,
          fnd_log.LEVEL_ERROR);

      UPDATE cz_atp_requests SET msg_data =
          'Unexpected error in cz_om_atp_callback returned from mrp_atp_pub: ' || l_msg_data
      WHERE configurator_session_key = p_config_session_key
        AND seq_no = 1;
      COMMIT;
    WHEN OTHERS THEN
      g_atp_rec := empty_atp_rec;
      l_msg_data := 'Unexpected error in cz_om_atp_callback statement ' || l_ndebug || ': '
                   || substr(SQLERRM, 1, 1500);
      cz_utils.log_report('cz_om_atp_callback', 'call_atp', l_ndebug, l_msg_data,
          fnd_log.LEVEL_UNEXPECTED);
      UPDATE cz_atp_requests SET msg_data = l_msg_data
      WHERE configurator_session_key = p_config_session_key
        AND seq_no = 1;
      COMMIT;
  END call_atp;

END cz_om_atp_callback;

/
