--------------------------------------------------------
--  DDL for Package Body WMS_WAVE_PLANNING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_WAVE_PLANNING_PVT" as
  /* $Header: WMSWVPVB.pls 120.12.12010000.20 2009/11/11 09:26:14 ajunnikr noship $ */

 l_seq_val NUMBER;

 TYPE troLineRecTyp IS RECORD (
      delivery_detail_id    NUMBER,
      inventory_item_id     NUMBER,
      from_sub       VARCHAR2(10),
      from_locator             NUMBER,
      lot_number               VARCHAR2(32),
      revision                 VARCHAR2(3),
      source_header_id     NUMBER,
      requested_quantity     NUMBER,
      source_line_id     NUMBER,
      requested_quantity_uom   VARCHAR2(3),
      SRC_REQUESTED_QUANTITY  NUMBER,
      SRC_REQUESTED_QUANTITY_UOM VARCHAR2(3),
      requested_quantity2     NUMBER,
      requested_quantity_uom2 VARCHAR2(3),
      ship_set_id       NUMBER,
      ship_model_complete_flag VARCHAR2(1),
      top_model_line_id     NUMBER,
      date_scheduled      DATE,
      project_id    NUMBER,
      task_id NUMBER,
      unit_number   NUMBER,
      preferred_grade     VARCHAR2(150),
      secondary_quantity     NUMBER,
      top_model_quantity    NUMBER
);


TYPE troLineRecTabTyp IS TABLE OF troLineRecTyp INDEX BY BINARY_INTEGER;
g_troline_table troLineRecTabTyp;

TYPE mtrlTblTyp  is table of mtl_txn_request_lines%rowtype index by binary_integer;
g_mtrl_tbl  mtrlTblTyp;

  TYPE psrTyp IS RECORD(
    attribute      NUMBER,
    attribute_name VARCHAR2(30),
    priority       NUMBER,
    sort_order     VARCHAR2(4));

  l_source_code_tb             char_tab;
  l_source_header_id_tb        num_tab;
  l_source_line_id_tb          num_tab;
  l_source_header_number_tb    char1_tab;
  l_source_line_number_tb      char1_tab;
  l_source_header_type_id_tb   num_tab;
  l_source_document_type_id_tb num_tab;
  l_delivery_Detail_id_tb      num_tab;
  l_organization_id_tb         num_tab;
  l_item_id_tb                 num_tab;
  l_delivery_id_tb             num_tab;
  l_requested_quantity_tb      num_tab;
  l_requested_quantity_uom_tb  uom_tab;
  l_requested_quantity2_tb     num_tab;
  l_requested_quantity_uom2_tb uom_tab;
  l_demand_header_id_tb        num_tab;
  l_net_weight_tb              num_tab;
  l_volume_tb                  num_tab;
  l_net_value                  num_tab;

  TYPE psrTabTyp IS TABLE OF psrTyp INDEX BY BINARY_INTEGER;
  --
  g_newline             CONSTANT VARCHAR2(10)  := fnd_global.newline;
  -- PACKAGE CONSTANTS
  --

  -- Indicate what attributes are used in Pick Sequence Rules
  C_INVOICE_VALUE     CONSTANT BINARY_INTEGER := 1;
  C_ORDER_NUMBER      CONSTANT BINARY_INTEGER := 2;
  C_SCHEDULE_DATE     CONSTANT BINARY_INTEGER := 3;
  C_TRIP_STOP_DATE    CONSTANT BINARY_INTEGER := 4;
  C_SHIPMENT_PRIORITY CONSTANT BINARY_INTEGER := 5;

  -- Indicate status of functions
  -- SUCCESS CONSTANT BINARY_INTEGER := 6;
  --  DONE    CONSTANT BINARY_INTEGER := 7;
  --  FAILURE CONSTANT BINARY_INTEGER := 8;

  --
  -- PACKAGE VARIABLES
  --
  --g_initialized         BOOLEAN := FALSE;
  g_ordered_psr psrTabTyp;
  --  g_use_order_ps        VARCHAR2(1) := 'Y';
  g_total_pick_criteria NUMBER;
  g_primary_psr         VARCHAR2(30);
  g_request_data varchar2(30);

  -- Track local PL/SQL table information
  g_del_current_line NUMBER := 1;
  g_rel_current_line NUMBER := 1;
  first_line         relRecTyp;
  MAX_LINES          NUMBER := 52;
  -- Return status of procedures
  g_return_status VARCHAR2(1);
  ajith           varchar2(4000);
  -- ajith1          varchar2(4000);
  -- ajith2          varchar2(4000);
  -- Column variables for DBMS_SQL package for mapping to values
  -- selected from cursors
  v_source_code              varchar2(30);
  v_header_id                NUMBER;
  v_line_id                  NUMBER;
  v_header_number            varchar2(150);
  v_line_number              varchar2(150);
  v_header_type_name         varchar2(240);
  v_header_type_id           NUMBER;
  v_document_type_id         NUMBER;
  v_delivery_detail_id       NUMBER;
  v_released_status          varchar2(1);
  v_org_id                   NUMBER;
  v_inventory_item_id        NUMBER;
  v_requested_quantity       NUMBER;
  v_requested_quantity_uom   varchar2(3);
  v_move_order_line_id       NUMBER;
  v_ship_model_complete_flag varchar2(1);
  v_top_model_id             NUMBER;
  v_ship_from_location_id    NUMBER;
  v_ship_to_location_id      NUMBER;
  v_ship_method_code         varchar2(30);
  v_shipment_priority_code   varchar2(30);
  v_ship_set_id              NUMBER;
  v_date_scheduled           date;
  v_planned_departure_date   date;
  v_delivery_id              NUMBER;
  v_customer_id              NUMBER;
  v_carrier_id               NUMBER;
  v_preferred_grade          NUMBER;
  v_requested_quantity2      NUMBER;
  v_requested_quantity_uom2  varchar2(3);
  v_project_id               NUMBER;
  v_task_id                  NUMBER;
  v_subinventory             varchar2(30);
  v_weight_uom_code          varchar2(5);
  v_net_weight               NUMBER;
  v_volume_uom_code          varchar2(5);
  v_volume                   NUMBER;
  v_cursorID                 INTEGER;
  v_ignore                   INTEGER;
--g_enforce_ship_set_and_smc VARCHAR2(1);
  -- new_wave_type WSH_PICKING_BATCHES_PUB.Batch_Info_Rec;

  l_is_unreleased           BOOLEAN;
  l_is_pending              BOOLEAN;
  l_is_queued               BOOLEAN;
  l_is_dispatched           BOOLEAN;
  l_is_active               BOOLEAN;
  l_is_loaded               BOOLEAN;
  l_is_completed            BOOLEAN;
  l_include_inbound         BOOLEAN;
  l_include_outbound        BOOLEAN;
  l_include_crossdock       BOOLEAN;
  l_include_manufacturing   BOOLEAN;
  l_include_warehousing     BOOLEAN;
  l_include_sales_orders    BOOLEAN;
  l_include_internal_orders BOOLEAN;
  l_include_replenishment   BOOLEAN;
  l_include_mo_transfer     BOOLEAN;
  l_include_mo_issue        BOOLEAN;
  l_include_lpn_putaway     BOOLEAN;
  l_include_staging_move    BOOLEAN;
  l_include_cycle_count     BOOLEAN;
  l_is_pending_plan         BOOLEAN;
  l_is_inprogress_plan      BOOLEAN;
  l_is_completed_plan       BOOLEAN;
  l_is_cancelled_plan       BOOLEAN;
  l_is_aborted_plan         BOOLEAN;
  l_query_independent_tasks BOOLEAN;
  l_query_planned_tasks     BOOLEAN;

  l_organization_id            NUMBER;
  l_subinventory               VARCHAR2(240);
  l_locator_id                 NUMBER;
  l_to_subinventory            VARCHAR2(240);
  l_to_locator_id              NUMBER;
  l_inventory_item_id          NUMBER;
  l_category_set_id            NUMBER;
  l_item_category_id           NUMBER;
  l_employee_id                NUMBER;
  l_equipment_type_id          NUMBER;
  l_equipment                  VARCHAR2(240);
  l_user_task_type_id          NUMBER;
  l_from_task_quantity         NUMBER;
  l_to_task_quantity           NUMBER;
  l_from_task_priority         NUMBER;
  l_to_task_priority           NUMBER;
  l_from_creation_date         DATE;
  l_to_creation_date           DATE;
  l_from_purchase_order        VARCHAR2(240);
  l_from_po_header_id          NUMBER;
  l_to_purchase_order          VARCHAR2(240);
  l_to_po_header_id            NUMBER;
  l_from_rma                   VARCHAR2(240);
  l_from_rma_header_id         NUMBER;
  l_to_rma                     VARCHAR2(240);
  l_to_rma_header_id           NUMBER;
  l_from_requisition           VARCHAR2(240);
  l_from_requisition_header_id NUMBER;
  l_to_requisition             VARCHAR2(240);
  l_to_requisition_header_id   NUMBER;
  l_from_shipment              VARCHAR2(240);
  l_to_shipment                VARCHAR2(240);
  l_from_sales_order_id        NUMBER;
  l_to_sales_order_id          NUMBER;
  l_from_pick_slip             NUMBER;
  l_to_pick_slip               NUMBER;
  l_customer_id                NUMBER;
  l_customer_category          VARCHAR2(240);
  l_delivery_id                NUMBER;
  l_carrier_id                 NUMBER;
  l_ship_method_code           VARCHAR2(240);
  l_trip_id                    NUMBER;
  l_shipment_priority          VARCHAR2(240);
  l_from_shipment_date         DATE;
  l_to_shipment_date           DATE;
  l_ship_to_state              VARCHAR2(240);
  l_ship_to_country            VARCHAR2(240);
  l_ship_to_postal_code        VARCHAR2(240);
  l_from_lines_in_sales_order  NUMBER;
  l_to_lines_in_sales_order    NUMBER;
  l_manufacturing_type         VARCHAR2(240);
  l_from_job                   VARCHAR2(240);
  l_to_job                     VARCHAR2(240);
  l_assembly_id                NUMBER;
  l_from_start_date            DATE;
  l_to_start_date              DATE;
  l_from_line                  VARCHAR2(240);
  l_to_line                    VARCHAR2(240);
  l_department_id              NUMBER;
  l_from_replenishment_mo      VARCHAR2(240);
  l_to_replenishment_mo        VARCHAR2(240);
  l_from_transfer_issue_mo     VARCHAR2(240);
  l_to_transfer_issue_mo       VARCHAR2(240);
  l_cycle_count_name           VARCHAR2(240);
  l_op_plan_activity_id        NUMBER;
  l_op_plan_type_id            NUMBER;
  l_op_plan_id                 NUMBER;

  -- l_action_description   VARCHAR2(1000);
  l_tasks_total          NUMBER;
  l_action_type          VARCHAR2(10);
  l_status               VARCHAR2(60);
  l_status_code          NUMBER;
  l_priority_type        VARCHAR2(10);
  l_priority             NUMBER;
  l_clear_priority       VARCHAR2(100);
  l_assign_type          VARCHAR2(100);
  l_employee             VARCHAR2(100);
  l_user_task_type       VARCHAR2(100);
  l_effective_start_date DATE;
  l_effective_end_date   DATE;
  l_person_resource_id   NUMBER;
  l_person_resource_code VARCHAR2(100);
  l_override_emp_check   BOOLEAN;
  l_temp_query           BOOLEAN;
  l_temp_action          BOOLEAN;
  l_wave_header_id       number;
  g_update_wdd      VARCHAR2(1) := 'N';

  PROCEDURE print_debug(p_err_msg VARCHAR2, p_debug number) IS

  BEGIN

    IF p_debug = 1 THEN
      inv_mobile_helper_functions.tracelog(p_err_msg => p_err_msg,
                                           p_module  => 'WMS_WAVE_PLANNING_PVT',
                                           p_level   => 4);
    END IF;

  END print_debug;

  PROCEDURE print_form_messages(p_err_msg VARCHAR2) is

    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  begin

    print_debug(' ' || p_err_msg, l_Debug);

  end print_form_messages;
  /*

  This procedure is used to set the global variables from Forms and Concurrent Program
  */
  procedure set_global_variable(order_type_id          in number,
                                order_header_id        in number,
                                backorders_flag        in varchar2,
                                include_planned_lines  in varchar2,
                                customer_id            in number,
                                inventory_item_id      in number,
                                shipment_priority_code in varchar2,
                                ship_method_code       in varchar2,
                                ship_to_loc_id         in number,
                                project_id             in number,
                                task_id                in number,
                                delivery_id            in number,
                                trip_id                in number,
                                trip_stop_id           in number,
                                pick_seq_rule_id       in number,
                                pick_grouping_rule_id  number,
                                scheduled_days         in number,
                                scheduled_hrs          in number,
                                dock_days              in number,
                                dock_hours             in number,
                                customer_class_id      in VARCHAR2,
                                carrier_id             in number,
                                category_Set_id        in number,
                                add_lines              in varchar2 default 'N') IS
    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  begin

    g_add_lines := add_lines;

    if order_type_id is null then
      g_order_type_id := 0;
    else
      g_order_type_id := order_type_id;
    end if;
    if order_header_id is null then
      g_order_header_id := 0;
    else
      g_order_header_id := order_header_id;
    end if;
    --g_backorders_flag := backorders_flag;
    g_backorders_flag := 'I';

    g_include_planned_lines := include_planned_lines;

    if customer_id is null then
      g_customer_id := 0;
    else
      g_customer_id := customer_id;
    end if;

    if customer_class_id is null then
      g_customer_class_id := null;
    else
      --  g_customer_class_id := '''' || customer_class_id || '''';
      g_customer_class_id := customer_class_id;
    end if;

    -- g_existing_rsvs_only_flag := reservations_flag;
    if inventory_item_id is null then
      g_inventory_item_id := 0;
    else
      g_inventory_item_id := inventory_item_id;
    end if;
    if shipment_priority_code is not null then
      g_shipment_priority := shipment_priority_code;
    end if;
    if ship_method_code is not null then
      -- g_ship_method_code := '''' || ship_method_code || '''';
      g_ship_method_code := ship_method_code;
      print_debug('g_ship_method_code' || g_ship_method_code, l_debug);
    end if;
    /*
    if ship_set_number is null then
      g_ship_set_number := 0;
    else
      g_ship_set_number := ship_set_number;
    end if;
    */
    g_ship_to_loc_id := SHIP_TO_LOC_ID;
    if project_id is null then
      g_project_id := 0;
    else
      g_project_id := project_id;
    end if;
    if task_id is null then
      g_task_id := 0;
    else
      g_task_id := task_id;
    end if;
    --g_doc_set_id := document_Set_id;

    if delivery_id is null then
      g_DELIVERY_ID := 0;
    else
      g_DELIVERY_ID := delivery_id;
    end if;

    if trip_id is null then
      g_trip_id := 0;
    else
      g_trip_id := trip_id;
    end if;
    if trip_stop_id is null then
      g_trip_Stop_id := 0;
    else
      g_trip_stop_id := trip_stop_id;
    end if;

    if category_Set_id is null then

      g_item_category_id := 0;

    else
      g_item_category_id := category_Set_id;

    end if;
    if scheduled_days is null and scheduled_hrs is null then
      g_from_sched_ship_date := NULL; --????????????????

    else
      --   if nvl(scheduled_days, 0) <= -1 or (nvl(scheduled_hrs, 0) / 24) <= -1 then
      if nvl(scheduled_days, 0) < 0 or (nvl(scheduled_hrs, 0) / 24) < 0 then

        g_from_sched_ship_date := sysdate + nvl(scheduled_days, 0) +
                                  nvl(scheduled_hrs, 0) / 24; --????????????????
        g_to_sched_ship_date   := sysdate;

      else

        g_from_sched_ship_date := sysdate; --????????????????
        g_to_sched_ship_date   := sysdate + nvl(scheduled_days, 0) +
                                  nvl(scheduled_hrs, 0) / 24;
      end if;
    end if;

    if dock_days is null and dock_hours is null then
      g_from_dock_appoint_date := NULL; --????????????????

    else

      --   if nvl(dock_hours, 0) <= -1 or (nvl(dock_days, 0) / 24) <= -1 then
      if nvl(dock_hours, 0) < 0 or (nvl(dock_days, 0) / 24) < 0 then
        g_from_dock_appoint_date := sysdate + nvl(dock_days, 0) +
                                    nvl(dock_hours, 0) / 24; --????????????????
        g_to_dock_appoint_date   := sysdate;
      else

        g_from_dock_appoint_date := sysdate; --????????????????
        g_to_dock_appoint_date   := sysdate + nvl(dock_days, 0) +
                                    nvl(dock_hours, 0) / 24;
      end if;
    end if;

    --g_from_sched_ship_date   := NULL; --????????????????
    -- g_from_dock_appoint_date := NULL;
    g_pick_seq_rule_id      := pick_seq_rule_id;
    g_pick_grouping_rule_id := pick_grouping_rule_id;

    if carrier_id is null then
      g_carrier_id := 0;
    else
      g_carrier_id := carrier_id;
    end if;

    print_debug('In Set Global Variables', l_Debug);

    print_debug('Order Type Id ' || g_order_type_id, l_debug);
    --print_debug('g_ship_set_number ' || g_ship_set_number, l_debug);
    print_debug('g_task_id ' || g_task_id, l_debug);
    print_debug('(g_project_id ' || g_project_id, l_debug);
    print_debug('g_trip_id ' || g_trip_id, l_debug);
    print_debug('Delivery id ' || g_DELIVERY_ID, l_debug);
    print_debug('Customer Class Id ' || g_customer_class_id, l_debug);
    print_debug('Inventory Item Id ' || g_inventory_item_id, l_debug);
    print_debug('scheduled_days ' || scheduled_days, l_debug);
    print_debug('scheduled_hrs ' || scheduled_hrs, l_debug);
    print_debug('g_from_sched_ship_date ' || g_from_sched_ship_date,
                l_debug);

    print_debug('g_to_sched_ship_date ' || g_to_sched_ship_date, l_debug);
    print_debug('g_from_dock_appoint_date ' || g_from_dock_appoint_date,
                l_debug);
    print_debug('g_to_dock_appoint_date ' || g_to_dock_appoint_date,
                l_debug);

    print_debug('Pick Sequence Rule Id ' || g_pick_seq_rule_id || ' : ' ||
                g_pick_grouping_rule_id,
                l_debug);
    print_debug('g_include_planned_lines ' || g_include_planned_lines,
                l_debug);

  EXCEPTION
    when others THEN
      print_debug('Error : ' || SQLCODE || ' : ' || SQLERRM, l_debug);
  END set_global_variable;

  PROCEDURE submit_WP_conc_request(p_wave_header_id in number,
                                   p_org_id         in number,
                                   x_request_id     OUT NOCOPY number) IS

    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  begin

    --Calling the Concurrent Program that does the following
    --Calls the Dynamic SQL
    -- Creates the batch record
    --Inserts into Lines Table
    -- Calls the Pick Release process
    --Should clear out All Global Variable ???????????????
    x_request_id := FND_REQUEST.SUBMIT_REQUEST(application => 'WMS',
                                               program     => 'WMS_WAVE_PLANNING',
                                               description => 'Wave Planning Initiate process', -- Need to change to Upper Cae?????
                                               start_time  => NULL,
                                               argument1   => NULL,
                                               argument2   => p_wave_header_id,
                                               argument3   => p_org_id);

    commit;
  exception
    WHEN OTHERS THEN
      print_debug('Error in submit Wave Planning Concurrent Request: ' ||
                  SQLCODE || ' : ' || SQLERRM,
                  l_debug);
  end submit_WP_conc_request;

  FUNCTION Outstanding_Order_Value(p_header_id IN BINARY_INTEGER,
                                   p_line_id   IN BINARY_INTEGER)
    RETURN BINARY_INTEGER IS

    l_order_value BINARY_INTEGER;

  BEGIN

    --
    SELECT SUM(NVL(L.ORDERED_QUANTITY, 0) * NVL(L.UNIT_SELLING_PRICE, 0))
      INTO l_order_value
      FROM OE_ORDER_HEADERS_ALL H, OE_ORDER_LINES_ALL L
     WHERE H.HEADER_ID = p_header_id
       and l.line_id = p_line_id
       AND L.HEADER_ID = H.HEADER_ID;

    --
    RETURN l_order_value;

  EXCEPTION
    WHEN OTHERS THEN
      --
      RETURN 0;

    --

  END Outstanding_Order_Value;

  procedure delete_wave_header(p_wave_header_id in number)

   is

  begin

    delete from wms_wp_wave_headers_vl
     where wave_header_id = p_wave_header_id;

    commit;

  end delete_wave_header;

  PROCEDURE launch_concurrent_CP(errbuf               OUT NOCOPY VARCHAR2,
                                 retcode              OUT NOCOPY NUMBER,
                                 p_wave_template_name in varchar2,
                                 p_wave_header_id     in number,
                                 p_org_id             in number) is

    x_msg_count              number;
    x_return_status          VARCHAR2(100);
    x_msg_data               VARCHAR2(500);
    p_BATCH_ID               NUMBER;
    P_REQUEST_ID             NUMBER;
    l_debug                  NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'),
                                           0);
    p_order_type_id          number;
    p_order_header_id        number;
    p_backorders_flag        varchar2(1);
    p_include_planned_lines  varchar2(1);
    p_customer_id            number;
    p_inventory_item_id      number;
    p_shipment_priority_code varchar2(100);
    p_ship_method_code       varchar2(100);
    p_ship_to_loc_id         number;
    p_project_id             number;
    p_task_id                number;
    p_delivery_id            number;
    p_category_id            number;
    p_trip_id                number;
    p_trip_stop_id           number;
    p_pick_seq_rule_id       number;
    p_pick_grouping_rule_id  number;
    p_scheduled_days         number;
    p_scheduled_hrs          number;
    p_dock_days              number;
    p_dock_hours             number;
    p_customer_class_id      varchar2(100);
    p_planning_criteria_id   number;
    p_carrier_id             NUMBER;
    parent_request_id        number;
    l_plan_req_status        boolean;
    l_dummy                  boolean;
    l_completion_status      VARCHAR2(100);
    l_phase                  VARCHAR2(100);
    l_status                 VARCHAR2(100);
    l_dev_phase              VARCHAR2(100);
    l_dev_status             VARCHAR2(100);
    l_message                VARCHAR2(500);
    l_mode                   VARCHAR2(4) := null;
    l_request_data           VARCHAR2(100);
    p_plan_wave              varchar2(1);
    p_release_wave           varchar2(1);
    v_wave_header_id         NUMBER;
    plan_request_id          NUMBER;

    wave_creation_exception exception;
    wave_line_exception exception;

  begin

    savepoint create_wave_lines_sp;

    v_wave_header_id := p_wave_header_id;

    l_mode         := NULL;
    l_request_data := FND_CONC_GLOBAL.Request_Data;
    if l_request_data is NULL then

      if p_wave_template_name is not null then
        --If Concurrent program is Scheduled and template name is given
        --Create Wave records for Wave Headers and Advanced Criteria table
        wms_wave_planning_pvt.insert_wave_record(v_WAVE_HEADER_ID);
        --insert into Advanced Criteria

        if x_return_status <> 'S' then
          raise wave_Creation_exception;
        end if;

      END IF;

      select order_type_id,
             from_order_header_id,
             backorders_flag,
             include_planned_lines,
             customer_id,
             inventory_item_id,
             ship_priority,
             ship_method_code,
             SHIP_TO_LOCATION_ID,
             project_id,
             task_id,
             delivery_id,
             trip_id,
             trip_stop_id,
             pick_seq_rule_id,
             pick_grouping_rule_id,
             scheduled_days,
             scheduled_hrs,
             dock_appointment_days,
             dock_appointment_hours,
             customer_class_id,
             planning_criteria_id,
             initiate_wave_planning,
             RELEASE_IMMEDIATELY,
             carrier_id,
             category_id
        into p_order_type_id,
             p_order_header_id,
             p_backorders_flag,
             p_include_planned_lines,
             p_customer_id,
             p_inventory_item_id,
             p_shipment_priority_code,
             p_ship_method_code,
             p_ship_to_loc_id,
             p_project_id,
             p_task_id,
             p_delivery_id,
             p_trip_id,
             p_trip_stop_id,
             p_pick_seq_rule_id,
             p_pick_grouping_rule_id,
             p_scheduled_days,
             p_scheduled_hrs,
             p_dock_days,
             p_dock_hours,
             p_customer_class_id,
             p_planning_criteria_id,
             p_plan_wave,
             p_release_wave,
             p_carrier_id,
             p_category_id
        from wms_wp_wave_headers_vl
       where wave_header_id = v_wave_header_id;

      set_global_variable(p_order_type_id,
                          p_order_header_id,
                          p_backorders_flag,
                          nvl(p_include_planned_lines, 'Y'),
                          p_customer_id,
                          p_inventory_item_id,
                          p_shipment_priority_code,
                          p_ship_method_code,
                          p_ship_to_loc_id,
                          p_project_id,
                          p_task_id,
                          p_delivery_id,
                          p_trip_id,
                          p_trip_stop_id,
                          p_pick_seq_rule_id,
                          p_pick_grouping_rule_id,
                          p_scheduled_days,
                          p_scheduled_hrs,
                          p_dock_days,
                          p_dock_hours,
                          p_customer_class_id,
                          p_carrier_id,
                          p_category_id);

      update wms_wp_wave_headers_vl
         set request_id = fnd_global.conc_request_id
       where wave_header_id = v_wave_header_id;

      --Call the Dynamic SQL
      get_dynamic_sql(v_wave_header_id, p_org_id, x_return_status);

      print_debug('l_request_data:' || l_request_data, l_debug);

      if x_return_status = 'S' then

        if p_plan_wave = 'Y' then

          print_debug('Calling Plan Wave Concurrent program:', l_debug);
          parent_request_id := fnd_global.conc_request_id;

          FND_CONC_GLOBAL.Set_Req_Globals(Conc_Status  => 'PAUSED',
                                          Request_Data => 'Child');

          p_request_id := FND_REQUEST.SUBMIT_REQUEST(application => 'WMS',
                                                     program     => 'PLAN_WAVE_CP',
                                                     description => 'Wave Planning Plan Wave',
                                                     start_time  => NULL,
                                                     sub_request => TRUE,
                                                     argument1   => v_wave_header_id,
                                                     argument2   => p_planning_criteria_id);
          print_debug('Calling Plan Wave Concurrent program with Request id:' ||
                      p_request_id,
                      l_debug);

          plan_request_id := p_request_id;

          l_dummy := FND_CONCURRENT.GET_REQUEST_STATUS(p_request_id,
                                                       '',
                                                       '',
                                                       l_phase,
                                                       l_status,
                                                       l_dev_phase,
                                                       l_dev_status,
                                                       l_message);

          IF l_dev_status = 'WARNING' THEN
            l_completion_status := 'WARNING';
          ELSIF l_dev_status <> 'NORMAL' THEN
            l_completion_status := 'ERROR';
          else
            l_completion_status := 'NORMAL';

            if p_release_wave <> 'Y' then

              l_dummy := FND_CONCURRENT.SET_COMPLETION_STATUS(l_completion_status,
                                                              '');
            END IF;

          end if;
        end if;

        if p_release_wave = 'Y' THEN
          /*
               if p_plan_wave = 'Y' then

              --Waiting for Plan Wave concurrent program to get complete if plan Wave Option is checked
          l_dummy := FND_CONCURRENT.WAIT_FOR_REQUEST
          (request_id=>plan_request_id,
          phase=>l_phase,
          status=>l_status,
          dev_phase=>l_dev_phase,
          dev_status=>l_dev_status,
          message=>l_message);
          END IF;
          */
          FND_CONC_GLOBAL.Set_Req_Globals(Conc_Status  => 'PAUSED',
                                          Request_Data => 'Child');

          p_request_id := FND_REQUEST.SUBMIT_REQUEST(application => 'WMS',
                                                     program     => 'RELEASE_BATCH_CP',
                                                     description => 'Wave Planning Release Wave',
                                                     start_time  => NULL,
                                                     sub_request => TRUE,
                                                     argument1   => V_wave_header_id);

          l_dummy := FND_CONCURRENT.GET_REQUEST_STATUS(p_request_id,
                                                       '',
                                                       '',
                                                       l_phase,
                                                       l_status,
                                                       l_dev_phase,
                                                       l_dev_status,
                                                       l_message);

          print_debug('Calling Release Wave Concurrent program with Request id:' ||
                      p_request_id,
                      l_debug);

          IF l_dev_status = 'WARNING' THEN
            l_completion_status := 'WARNING';
          ELSIF l_dev_status <> 'NORMAL' THEN
            l_completion_status := 'ERROR';
          else
            l_completion_status := 'NORMAL';

          END IF;

          l_dummy := FND_CONCURRENT.SET_COMPLETION_STATUS(l_completion_status,
                                                          '');

        end if;

      else
        raise wave_line_exception;

      end if;
    end if;

    commit;

  exception
    WHEN wave_creation_exception then

      rollback to create_wave_lines_sp;
      RAISE fnd_api.g_exc_unexpected_error;

    WHEN wave_line_exception then

      rollback to create_wave_lines_sp;

      delete_wave_header(v_wave_header_id);
      RAISE fnd_api.g_exc_unexpected_error;

    --  l_completion_status := 'ERROR';

    /*  l_dummy := FND_CONCURRENT.SET_COMPLETION_STATUS(l_completion_status,
    '');*/

    WHEN OTHERS THEN
      print_debug('Error in Launch Concurrent CP: ' || SQLCODE || ' : ' ||
                  SQLERRM,
                  l_debug);
      --  l_completion_status := 'ERROR';
      /*  l_dummy             := FND_CONCURRENT.SET_COMPLETION_STATUS(l_completion_status,

      '');*/

      RAISE fnd_api.g_exc_unexpected_error;
  end launch_concurrent_CP;

  PROCEDURE Plan_Wave_CP(errbuf                 OUT NOCOPY VARCHAR2,
                         retcode                OUT NOCOPY NUMBER,
                         p_wave_header_id       in number,
                         p_planning_criteria_id in number)

   is
    l_debug         NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    x_return_status VARCHAR2(10);
  begin

   g_request_data := FND_CONC_GLOBAL.Request_Data;
   print_Debug('request data  '|| g_request_data, l_debug);

if  g_request_data is null then
    savepoint plan_wave_concurrent_sp;

    print_Debug('In Plan Wave Cp', l_debug);

    print_Debug('Calling Plan Wave API', l_debug);
    plan_wave(p_wave_header_id, p_planning_criteria_id, x_return_Status);

    if x_return_Status <> 'S' then

      RAISE fnd_api.g_exc_unexpected_error;

    end if;

end if;

  exception

    when others THEN

      print_debug('Error in Plan Wave CP: ' || SQLCODE || ' : ' || SQLERRM,
                  l_debug);
      rollback to plan_wave_concurrent_sp;
      RAISE fnd_api.g_exc_unexpected_error;
  end plan_wave_cp;

  procedure insert_wave_record(p_wave_header_id in OUT NOCOPY number) is
    l_debug          NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    l_wave_header_id number;
  begin

    select WMS_WP_WAVE_HEADERS_S.NEXTVAL into l_wave_header_id from dual;

  INSERT INTO wms_wp_wave_headers_vl
      (wave_header_id,
       WAVE_NAME,
       WAVE_DESCRIPTION,
       start_time,  -- start time changes
       WAVE_SOURCE,
       WAVE_STATUS,
       TYPE_ID,
       BATCH_ID,
       SHIP_TO_LOCATION_ID,
       CUSTOMER_CLASS_ID,
       pull_replenishment_flag,
       INITIATE_WAVE_PLANNING,
       RELEASE_IMMEDIATELY,
       TABLE_NAME,
       ADVANCED_CRITERIA,
       CREATED_BY,
       CREATION_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATE_DATE,
       LAST_UPDATE_LOGIN,
       ORGANIZATION_ID,
       PICK_SEQ_RULE_ID,
       PICK_GROUPING_RULE_ID,
       TRIP_ID,
       TRIP_STOP_ID,
       SHIP_METHOD_CODE,
       SHIPMENT_PRIORITY_CODE,
       CARRIER_ID,
       DELIVERY_ID,
       FROM_ORDER_HEADER_ID,
       ORDER_TYPE_ID,
       CUSTOMER_ID,
       TASK_ID,
       PROJECT_ID,
       CATEGORY_SET_ID,
       CATEGORY_ID,
       INVENTORY_ITEM_ID,
       BACKORDERS_FLAG,
       INCLUDE_PLANNED_LINES,
       TASK_PLANNING_FLAG,
       APPEND_DELIVERIES,
       AUTO_CREATE_DELIVERY,
       AUTO_CREATE_DELIVERY_CRITERIA,
       TASK_PRIORITY,
       DEFAULT_STAGE_SUBINVENTORY,
       DEFAULT_STAGE_LOCATOR_ID,
       DEFAULT_ALLOCATION_METHOD,
       WAVE_FIRMED_FLAG,
       WAVE_COMPLETION_TIME,
       ORDER_NAME,
       CUSTOMER,
       ORDER_TYPE,
       CUSTOMER_CLASS,
       SHIP_METHOD,
       CARRIER,
       SHIP_PRIORITY,
       DELIVERY,
       TRIP,
       TRIP_STOP,
       ITEM,
       ITEM_CATEGORY,
       PROJECT_NAME,
       TASK_NAME,
       SCHEDULED_DAYS,
       SCHEDULED_HRS,
       DOCK_APPOINTMENT_DAYS,
       DOCK_APPOINTMENT_HOURS,
       PICK_SLIP_GROUP,
       RELEASE_SEQ_RULE,
       STAGING_SUBINVENTORY,
       STAGING_LOCATOR,
       CROSS_DOCK_CRITERIA,
       PLANNING_CRITERIA,
       PLANNING_CRITERIA_ID,
       pick_subinventory)
      SELECT l_wave_header_id,
             WAVE_NAME || '-' || l_wave_header_id,
             WAVE_DESCRIPTION,
             start_time, -- start time changes
             WAVE_SOURCE,
             WAVE_STATUS, --Need to Confirm??????
             'W',
             BATCH_ID,
             SHIP_TO_LOCATION_ID,
             CUSTOMER_CLASS_ID,
             pull_replenishment_flag,
             INITIATE_WAVE_PLANNING,
             RELEASE_IMMEDIATELY,
             TABLE_NAME,
             ADVANCED_CRITERIA,
             CREATED_BY,
             CREATION_DATE,
             fnd_global.user_id,
             sysdate,
             fnd_global.login_id,
             ORGANIZATION_ID,
             PICK_SEQ_RULE_ID,
             PICK_GROUPING_RULE_ID,
             TRIP_ID,
             TRIP_STOP_ID,
             SHIP_METHOD_CODE,
             SHIPMENT_PRIORITY_CODE,
             CARRIER_ID,
             DELIVERY_ID,
             FROM_ORDER_HEADER_ID,
             ORDER_TYPE_ID,
             CUSTOMER_ID,
             TASK_ID,
             PROJECT_ID,
             CATEGORY_SET_ID,
             CATEGORY_ID,
             INVENTORY_ITEM_ID,
             BACKORDERS_FLAG,
             INCLUDE_PLANNED_LINES,
             TASK_PLANNING_FLAG,
             APPEND_DELIVERIES,
             AUTO_CREATE_DELIVERY,
             AUTO_CREATE_DELIVERY_CRITERIA,
             TASK_PRIORITY,
             DEFAULT_STAGE_SUBINVENTORY,
             DEFAULT_STAGE_LOCATOR_ID,
             DEFAULT_ALLOCATION_METHOD,
             WAVE_FIRMED_FLAG,
             WAVE_COMPLETION_TIME,
             ORDER_NAME,
             CUSTOMER,
             ORDER_TYPE,
             CUSTOMER_CLASS,
             SHIP_METHOD,
             CARRIER,
             SHIP_PRIORITY,
             DELIVERY,
             TRIP,
             TRIP_STOP,
             ITEM,
             ITEM_CATEGORY,
             PROJECT_NAME,
             TASK_NAME,
             SCHEDULED_DAYS,
             SCHEDULED_HRS,
             DOCK_APPOINTMENT_DAYS,
             DOCK_APPOINTMENT_HOURS,
             PICK_SLIP_GROUP,
             RELEASE_SEQ_RULE,
             STAGING_SUBINVENTORY,
             STAGING_LOCATOR,
             CROSS_DOCK_CRITERIA,
             PLANNING_CRITERIA,
             PLANNING_CRITERIA_ID,
             pick_subinventory
        FROM wms_wp_wave_headers_vl
       WHERE wave_header_id = p_wave_header_id;

    INSERT INTO wms_wp_Advanced_Criteria
      (RULE_ID,
       RULE_WAVE_HEADER_ID,
       SEQUENCE_NUMBER,
       LAST_UPDATED_BY,
       LAST_UPDATE_DATE,
       CREATED_BY,
       CREATION_DATE,
       LAST_UPDATE_LOGIN,
       LOGICAL_OPERATOR_CODE,
       LOGICAL_OPERATOR_MEANING,
       BRACKET_OPEN,
       OBJECT_ID,
       OBJECT_NAME,
       OBJECT_DESCRIPTION,
       PARAMETER_ID,
       PARAMETER_NAME,
       PARAMETER_DESCRIPTION,
       OPERATOR_CODE,
       OPERATOR_MEANING,
       OPERATOR_DESCRIPTION,
       OPERAND_VALUE,
       OPERAND_CHAR,
       BRACKET_CLOSE)
      SELECT wms_wp_advanced_criteria_s.NEXTVAL,
             l_wave_header_id,
             SEQUENCE_NUMBER,
             fnd_global.user_id,
             sysdate,
             CREATED_BY,
             CREATION_DATE,
             fnd_global.login_id,
             LOGICAL_OPERATOR_CODE,
             LOGICAL_OPERATOR_MEANING,
             BRACKET_OPEN,
             OBJECT_ID,
             OBJECT_NAME,
             OBJECT_DESCRIPTION,
             PARAMETER_ID,
             PARAMETER_NAME,
             PARAMETER_DESCRIPTION,
             OPERATOR_CODE,
             OPERATOR_MEANING,
             OPERATOR_DESCRIPTION,
             OPERAND_VALUE,
             OPERAND_CHAR,
             BRACKET_CLOSE
        FROM wms_wp_Advanced_Criteria
       WHERE rule_wave_header_id = p_wave_header_id;

    select WMS_WP_WAVE_HEADERS_S.CURRVAL into p_wave_header_id from dual;

  exception
    when others then
      select WMS_WP_WAVE_HEADERS_S.CURRVAL into p_wave_header_id from dual;
      print_debug('Error in Insert Wave Record: ' || SQLCODE || ' : ' ||
                  SQLERRM,
                  l_debug);
  end insert_wave_record;

  PROCEDURE Call_Plan_Wave_CP(p_wave_header_id       in number,
                              p_planning_criteria_id in number,
                              p_request_id           OUT NOCOPY number)

   is
    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  begin

    print_Debug('In Call Plan Wave', l_debug);
    p_request_id := FND_REQUEST.SUBMIT_REQUEST(application => 'WMS',
                                               program     => 'PLAN_WAVE_CP',
                                               description => 'Wave Planning Plan Wave',
                                               start_time  => NULL,
                                               argument1   => p_wave_header_id,
                                               argument2   => p_planning_criteria_id);
  exception
    when others then
      print_debug('Error in Call Plan Wave Cp: ' || SQLCODE || ' : ' ||
                  SQLERRM,
                  l_debug);
  end call_Plan_Wave_CP;

   procedure labor_resource_planning(x_labor_time_tbl labor_time_tbl,
                                    tbl_type         number,
                                    plan_type        varchar2,
                                    plan_id          number,
                                    wave_id          number,
                                    ORGANIZATION_ID number) is
    l_planning_criteria_id NUMBER := plan_id;
    l_wave_header_id       NUMBER := wave_id;
    l_organization_id      NUMBER;
    cap_det                NUMBER;

    ----------  SET UP DETAILS --------------------
    TYPE labor_setup_record IS RECORD(
      resource_name            VARCHAR2(100),
      resource_type            NUMBER,
      source                   VARCHAR2(100),
      destination              VARCHAR2(100),
      unit_of_measure          VARCHAR2(10),
      item_category_id         NUMBER,
      operation_plan_id        NUMBER,
      transaction_time         NUMBER,
      travel_time              NUMBER,
      outbound_processing_time NUMBER);

    TYPE labor_setup_tbl IS TABLE OF labor_setup_record INDEX BY BINARY_INTEGER;

    x_labor_setup_tbl  labor_setup_tbl; -- Gonna contain entire set up
    x_labor_suited_tbl labor_setup_tbl; -- Gonna contain only suited resource detail for the current task

    --x_tasks_tbl labor_time_tbl; -- Gonna contain details of the planned tasks
    ----------  TASK DETAILS ----------------------

    ----- cursor to get the details of all the resources from wms_wp_labor_planning table ----

    /*  cursor get the details of resource. First fetch persons (resouce type = 2) last fetch machines (resource type = 1)*/

    CURSOR c_get_labor_details(p_plan_id NUMBER) IS
      SELECT wlp.resource_type resource_name,
             wlp.source_subinventory,
             wlp.destination_subinventory,
             wlp.pick_uom pick_uom,
             wlp.transaction_time,
             wlp.travel_time,
             wlp.processing_overhead_duration,
             wlp.category_id,
             Decode(plan_type, 'A', -1, 'R', wlp.operation_plan_id) operation_plan_id,
             br.resource_type resource_type
        FROM wms_wp_labor_planning       wlp,
             bom_department_resources    bdr,
             bom_Resources               br,
             wms_wp_planning_Criteria_vl wpl
       WHERE wlp.planning_criteria_id = p_plan_id
         AND wpl.planning_criteria_id = p_plan_id
         AND br.resource_code = wlp.resource_type
         AND br.resource_id = bdr.resource_id
         AND bdr.department_id = wpl.department_id
       ORDER BY br.resource_type DESC;

    --- cursor to get the distinct resources ----

    CURSOR c_get_distinct_resource(p_plan_id NUMBER) IS
      SELECT DISTINCT resource_type
        FROM wms_wp_labor_planning
       WHERE planning_criteria_id = p_plan_id;

    position                 NUMBER := 0;
    current_load             NUMBER := 0;
    resource_type            NUMBER := 0;
    number_of_tasks          NUMBER := 0;
    total_capacity           NUMBER := 0;
    l_std_oprn_id            VARCHAR2(1) := 'N';
    l_item_cat_id            VARCHAR2(1) := 'N';
    suit_copy                NUMBER := 0;
    l_available_capacity     NUMBER := 0;
    l_qty_able_to_do         NUMBER := 0;
    l_total_quantity_to_do   NUMBER;
    l_total_machine_quantity NUMBER;
    l_suit_count             NUMBER;
    l_planned_load_task      NUMBER;
    l_planned_temp_load      NUMBER;
    l_complete_task          NUMBER; -- This will be added to planned tasks. It will become zero after assigned to 1st resource, if
    -- the work load is shared among 2 or more resources.
    l_debug            NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'),
                                     0);
    l_complete_machine number;
    l_resource_okay    VARCHAR2(1);
    l_dept_id          number;
    l_utilization      number;
    l_efficiency       number;

  BEGIN
      print_debug('In ORGANIZATION_ID API '||ORGANIZATION_ID, l_debug);

    /*
    1.Take a task from x_labor_time_tbl
    2.From x_labor_setup_tbl copy the records into x_labor_suited_tbl which can do the work
    3.If no resource is person then task can't be assigned to any one
    4.If person is there assign the load to him.
    5.If no enough capacity then try for another resource from x_labor_suited_tbl
    6.If no resource found then overload the current person.
    7.After assigning the work to person, see if machine is available to do and assign same load to it.
    */
    /* tbl_type = '1' ==> inventory movements table
    tbl_type = '2' ==> crossdock movements table
    plan_type = 'A' ==> availability check planning
    plan_type = 'R' ==> rules based planning*/

    l_organization_id := ORGANIZATION_ID;
    begin
      print_debug('In labor_resource_planning API', l_debug);
      select department_id
        into l_dept_id
        from wms_wp_planning_criteria_vl
       where planning_criteria_id = l_planning_criteria_id;
    exception
      when no_data_found then
        l_dept_id := -1;
    end;

    /* labor planning api is going to call this procedure twice;
    when it calls for inventory movements only we need to update resource capacity table.
    After doing labor resource planning for inventory movements, labor planning api will call this again for xdock movements;
    then resource capacity should have old values which are obtained after labor resource planning for inventory movements
    This is bcoz labor resource planning should be done for inventory + xdock movements*/

    -- populating x_resource_capacity_tbl --
    if tbl_type = 1 then
      position := 0;
      FOR l_cap_det IN c_get_distinct_resource(l_planning_criteria_id) LOOP
        x_resource_capacity_tbl(position).resource_name := l_cap_det.resource_type;
        wms_wave_planning_pvt.get_current_work_load(l_cap_det.resource_type,
                                                    l_planning_criteria_id,
                                                    l_wave_header_id,
                                                    current_load,
                                                    resource_type,
                                                    number_of_tasks,
                                                    total_capacity);

        x_resource_capacity_tbl(position).current_load := current_load;
        x_resource_capacity_tbl(position).resource_type := resource_type;
        x_resource_capacity_tbl(position).actual_tasks := number_of_tasks;
        x_resource_capacity_tbl(position).total_capacity := total_capacity;
        x_resource_capacity_tbl(position).available_capacity := total_capacity -
                                                                current_load;

        position := position + 1;
      END LOOP;
    end if;

    -- populating x_labor_setup_tbl --
    position := 0;
    FOR l_setup IN c_get_labor_details(l_planning_criteria_id) LOOP
      --x_labor_setup_tbl --
      x_labor_setup_tbl(position).resource_name := l_setup.resource_name;
      x_labor_setup_tbl(position).source := l_setup.source_subinventory;
      x_labor_setup_tbl(position).destination := l_setup.destination_subinventory;
      x_labor_setup_tbl(position).unit_of_measure := l_setup.pick_uom;
      x_labor_setup_tbl(position).item_category_id := l_setup.category_id;
      x_labor_setup_tbl(position).operation_plan_id := l_setup.operation_plan_id;
      print_debug('operation plan id assignment = ' ||
                  x_labor_setup_tbl(position).item_category_id,
                  l_debug);
      x_labor_setup_tbl(position).transaction_time := l_setup.transaction_time;
      x_labor_setup_tbl(position).travel_time := l_setup.travel_time;
      x_labor_setup_tbl(position).outbound_processing_time := l_setup.processing_overhead_duration;
      x_labor_setup_tbl(position).resource_type := l_setup.resource_type;

      position := position + 1;
    END LOOP;

    -- load calculation starts --
    if x_labor_time_tbl.count > 0 then
      FOR task IN x_labor_time_tbl.first .. x_labor_time_tbl.last LOOP
        -- loop for every task
        print_debug('task is from ' || x_labor_time_tbl(TASK)
                    .picking_subinventory || ' to' ||
                    x_labor_time_tbl(TASK)
                    .destination_subinventory || ' and quantity moved is ' ||
                    x_labor_time_tbl(TASK).demand_qty_picking_uom,
                    l_debug);
        print_debug('From  : ' || x_labor_time_tbl(TASK)
                    .picking_subinventory,
                    l_debug);
        print_debug('To  : ' || x_labor_time_tbl(TASK)
                    .destination_subinventory,
                    l_debug);
        print_debug('UOM  : ' || x_labor_time_tbl(TASK).picking_uom,
                    l_debug);
        print_debug('qty  : ' || x_labor_time_tbl(TASK)
                    .demand_qty_picking_uom,
                    l_debug);
        print_debug('item_id  : ' || x_labor_time_tbl(TASK)
                    .INVENTORY_ITEM_ID,
                    l_debug);
        print_debug('oprn_id  : ' || x_labor_time_tbl(TASK)
                    .operation_plan_id,
                    l_debug);
        print_debug('std_oprn_id  : ' || x_labor_time_tbl(TASK)
                    .standard_operation_id,
                    l_debug);

        suit_copy          := 0; -- variable to copy into suited table.
        l_complete_task    := 1;
        l_complete_machine := 1;
        FOR setup IN x_labor_setup_tbl.first .. x_labor_setup_tbl.last LOOP
          -- loop the set up table and get the eligible resources to complete the task
          l_std_oprn_id := 'N';
          l_item_cat_id := 'N';
          IF x_labor_setup_tbl(setup).source = x_labor_time_tbl(TASK)
          .picking_subinventory AND x_labor_setup_tbl(setup)
          .destination = x_labor_time_tbl(TASK)
          .destination_subinventory AND x_labor_setup_tbl(setup)
          .unit_of_measure = x_labor_time_tbl(TASK)
          .picking_uom AND
             ((x_labor_setup_tbl(setup)
              .operation_plan_id = x_labor_time_tbl(TASK).operation_plan_id) or
              (x_labor_setup_tbl(setup)
              .source = 'Not Applicable' and x_labor_time_tbl(TASK)
              .operation_plan_id = -1) or
              (plan_type = 'R' and x_labor_setup_tbl(setup).operation_plan_id is null)) THEN
             print_debug('resource1',l_debug);
            IF ((x_labor_time_tbl(task)
               .standard_operation_id = -1 and plan_type = 'A') or
               (x_labor_setup_tbl(setup)
               .source = 'Not Applicable' and x_labor_time_tbl(TASK)
               .standard_operation_id = -1)) THEN
              l_std_oprn_id := 'Y';
              print_debug('resource2',l_debug);
            ELSE
              begin
                SELECT 'Y'
                  INTO l_std_oprn_id
                  FROM dual
                 WHERE x_labor_time_tbl(task)
                .standard_operation_id IN
                       (SELECT standard_operation_id
                          FROM bom_std_op_resources_v
                         WHERE resource_code = x_labor_setup_tbl(setup)
                        .resource_name);
                 print_debug('resource3',l_debug);
              exception
                when no_data_found THEN
                  l_std_oprn_id := 'N';
              end;
            END IF;

            IF l_std_oprn_id = 'Y' THEN
              -- This resource is capable of doing the particular task
              -- assign value Y to l_item_cat_id, if the setup matches.
              BEGIN
              print_debug('resource4',l_debug);

                SELECT 'Y'
                  INTO l_item_cat_id
                  FROM dual
                 WHERE x_labor_setup_tbl(setup)
                .item_category_id is null
                    or (x_labor_setup_tbl(setup)
                        .item_category_id IN
                        (SELECT category_id
                           FROM mtl_category_set_valid_cats_v a
                          WHERE a.category_id IN
                                (SELECT DISTINCT b.category_id
                                   FROM mtl_item_categories b
                                  WHERE a.category_id = b.category_id
                                    and b.inventory_item_id =
                                        x_labor_time_tbl(TASK)
                                 .inventory_item_id
                                    AND b.organization_id = l_organization_id)));

              exception
                when no_data_found THEN
                  l_item_cat_id := 'N';
              end;

              IF l_item_cat_id = 'Y' THEN
              print_debug('resource5',l_debug);
                x_labor_suited_tbl(suit_copy).resource_name := x_labor_setup_tbl(setup)
                                                              .resource_name;
                x_labor_suited_tbl(suit_copy).source := x_labor_setup_tbl(setup)
                                                       .source;
                x_labor_suited_tbl(suit_copy).destination := x_labor_setup_tbl(setup)
                                                            .destination;
                x_labor_suited_tbl(suit_copy).unit_of_measure := x_labor_setup_tbl(setup)
                                                                .unit_of_measure;
                x_labor_suited_tbl(suit_copy).item_category_id := x_labor_setup_tbl(setup)
                                                                 .item_category_id;
                x_labor_suited_tbl(suit_copy).operation_plan_id := x_labor_setup_tbl(setup)
                                                                  .operation_plan_id;
                x_labor_suited_tbl(suit_copy).transaction_time := x_labor_setup_tbl(setup)
                                                                 .transaction_time;
                x_labor_suited_tbl(suit_copy).travel_time := x_labor_setup_tbl(setup)
                                                            .travel_time;
                x_labor_suited_tbl(suit_copy).outbound_processing_time := x_labor_setup_tbl(setup)
                                                                         .outbound_processing_time;
                x_labor_suited_tbl(suit_copy).resource_type := x_labor_setup_tbl(setup)
                                                              .resource_type;
                suit_copy := suit_copy + 1;
              END IF;
            END IF;
          END IF;
        END LOOP;

        l_total_quantity_to_do   := x_labor_time_tbl(TASK)
                                   .demand_qty_picking_uom;
        l_total_machine_quantity := l_total_quantity_to_do;
        l_suit_count             := x_labor_suited_tbl.Count - 1;
        l_planned_load_task      := 0;
        print_debug('************************ x_labor_suited_tbl.Count ***************************',
                    l_debug);
        print_debug('x_labor_suited_tbl.Count ' ||
                    x_labor_suited_tbl.Count,
                    l_debug);
        IF x_labor_suited_tbl.Count > 0 THEN
          FOR suit IN x_labor_suited_tbl.first .. x_labor_suited_tbl.last LOOP
            print_debug('current resource is ' || x_labor_suited_tbl(suit)
                        .resource_name,
                        l_debug);
            print_debug('current resource type is ' ||
                        x_labor_suited_tbl(suit).resource_type,
                        l_debug);
            print_debug('======================================================',
                        l_debug);
            IF l_total_quantity_to_do > 0 THEN
              IF x_labor_suited_tbl(suit).resource_type = 2 THEN
                -- ==> person resource
                -- Find the position in x_resource_capacity_tbl.

                FOR l_cap_det IN x_resource_capacity_tbl.first .. x_resource_capacity_tbl.last LOOP
                  IF x_resource_capacity_tbl(l_cap_det)
                  .resource_name = x_labor_suited_tbl(suit).resource_name THEN
                    cap_det := l_cap_det;
                    EXIT;
                  END IF;
                END LOOP;
                print_debug(' quanity = ' || l_total_quantity_to_do,
                            l_debug);
                print_debug(' available_capacity = ' ||
                            x_resource_capacity_tbl(cap_det)
                            .available_capacity,
                            l_debug);
                print_debug(' travel_time = ' || x_labor_suited_tbl(suit)
                            .travel_time,
                            l_debug);
                print_debug(' outbound_processing_time = ' ||
                            x_labor_suited_tbl(suit)
                            .outbound_processing_time,
                            l_debug);
                print_debug(' transaction_time = ' ||
                            x_labor_suited_tbl(suit).transaction_time,
                            l_debug);

                select nvl(utilization, 100) / 100,
                       nvl(efficiency, 100) / 100
                  into l_utilization, l_efficiency
                  from bom_department_resources_v bdrv
                 where department_id = l_dept_id
                   and resource_code = x_resource_capacity_tbl(cap_det)
                .resource_name;

                l_available_capacity := (x_resource_capacity_tbl(cap_det)
                                        .available_capacity * l_efficiency *
                                         l_utilization) -
                                        (x_labor_suited_tbl(suit)
                                        .travel_time +
                                         x_labor_suited_tbl(suit)
                                        .outbound_processing_time);
                l_qty_able_to_do     := Floor(l_available_capacity /
                                              x_labor_suited_tbl(suit)
                                              .transaction_time);
                print_debug(' l_qty_able_to_do = ' || l_qty_able_to_do,
                            l_debug);

                IF l_qty_able_to_do >= l_total_quantity_to_do THEN
                  -- Here the resource is able to do the task completely so no problem.
                  print_debug('Resource can do completely', l_debug);
                  x_resource_capacity_tbl(cap_det).planned_tasks := x_resource_capacity_tbl(cap_det)
                                                                   .planned_tasks +
                                                                    l_complete_task;
                  l_complete_task := 0;
                  l_planned_temp_load := round((l_total_quantity_to_do *
                                         x_labor_suited_tbl(suit)
                                         .transaction_time +
                                          x_labor_suited_tbl(suit)
                                         .travel_time + Nvl(x_labor_suited_tbl(suit)
                                                            .outbound_processing_time,
                                                            0)) /
                                         (l_efficiency * l_utilization));
                  x_resource_capacity_tbl(cap_det).planned_load := x_resource_capacity_tbl(cap_det)
                                                                  .planned_load +
                                                                   l_planned_temp_load;
                  l_total_quantity_to_do := 0;
                  l_planned_load_task := l_planned_load_task +
                                         l_planned_temp_load;
                  x_resource_capacity_tbl(cap_det).available_capacity := x_resource_capacity_tbl(cap_det)
                                                                        .available_capacity -
                                                                         l_planned_temp_load;
                  print_debug(' l_planned_temp_load = ' ||
                              l_planned_temp_load,
                              l_debug);

                  print_debug('resource = '||x_resource_capacity_tbl(cap_det).resource_name,l_debug);
                  print_debug('available = '||x_resource_capacity_tbl(cap_det).available_capacity,l_debug);
                  print_debug('planned = '||x_resource_capacity_tbl(cap_det).planned_load,l_debug);
                ELSIF l_qty_able_to_do < l_total_quantity_to_do THEN
                  -- Here the resource can do only part of the task.
                  print_debug('Resource can do partially', l_debug);
                  l_resource_okay := 'N';
                  IF suit < l_suit_count THEN
                    IF x_labor_suited_tbl(suit + 1).resource_type = 2 THEN
                      l_resource_okay := 'Y';
                      print_debug('l_resource_okay = ' || l_resource_okay,
                                  l_debug);
                    ELSE
                      l_resource_okay := 'N';
                      print_debug('l_resource_okay = ' || l_resource_okay,
                                  l_debug);
                    END IF;
                  END IF;

                  IF l_resource_okay = 'Y' THEN
                    IF x_resource_capacity_tbl(cap_det)
                    .available_capacity > 0 THEN
                      x_resource_capacity_tbl(cap_det).planned_tasks := x_resource_capacity_tbl(cap_det)
                                                                       .planned_tasks +
                                                                        l_complete_task;
                      l_complete_task := 0;
                      IF l_qty_able_to_do > 0 THEN
                        l_planned_temp_load := round((l_qty_able_to_do *
                                               x_labor_suited_tbl(suit)
                                               .transaction_time +
                                                x_labor_suited_tbl(suit)
                                               .travel_time +
                                                Nvl(x_labor_suited_tbl(suit)
                                                    .outbound_processing_time,
                                                    0)) / (l_efficiency *
                                               l_utilization));
                        x_resource_capacity_tbl(cap_det).planned_load := x_resource_capacity_tbl(cap_det)
                                                                        .planned_load +
                                                                         l_planned_temp_load;
                        l_total_quantity_to_do := l_total_quantity_to_do -
                                                  l_qty_able_to_do;
                        l_planned_load_task := l_planned_load_task +
                                               l_planned_temp_load;
                        x_resource_capacity_tbl(cap_det).available_capacity := x_resource_capacity_tbl(cap_det)
                                                                              .available_capacity -
                                                                              l_planned_temp_load;
                        print_debug(' l_planned_temp_load = ' ||
                                    l_planned_temp_load,
                                    l_debug);
                  print_debug('resource = '||x_resource_capacity_tbl(cap_det).resource_name,l_debug);
                  print_debug('available = '||x_resource_capacity_tbl(cap_det).available_capacity,l_debug);
                  print_debug('planned = '||x_resource_capacity_tbl(cap_det).planned_load,l_debug);

                      ELSE
                        print_debug('Resource cannot handle even 1 qty',
                                    l_debug);
                      END IF;
                    END IF;
                  ELSE
                    -- There is no other person resource who can do this task. So assign the load to this guy only.
                    print_debug('Resource should do every thing', l_debug);
                    x_resource_capacity_tbl(cap_det).planned_tasks := x_resource_capacity_tbl(cap_det)
                                                                     .planned_tasks +
                                                                      l_complete_task;
                    l_complete_task := 0;
                    l_planned_temp_load := round((l_total_quantity_to_do *
                                           x_labor_suited_tbl(suit)
                                           .transaction_time +
                                            x_labor_suited_tbl(suit)
                                           .travel_time +
                                            Nvl(x_labor_suited_tbl(suit)
                                                .outbound_processing_time,
                                                0)) /
                                           (l_efficiency * l_utilization));
                    x_resource_capacity_tbl(cap_det).planned_load := x_resource_capacity_tbl(cap_det)
                                                                    .planned_load +
                                                                     l_planned_temp_load;
                    l_total_quantity_to_do := 0;
                    l_planned_load_task := l_planned_load_task +
                                           l_planned_temp_load;
                    x_resource_capacity_tbl(cap_det).available_capacity := x_resource_capacity_tbl(cap_det)
                                                                          .available_capacity -
                                                                           l_planned_temp_load;
                    print_debug(' l_planned_temp_load = ' ||
                                l_planned_temp_load,
                                l_debug);
                  print_debug('resource = '||x_resource_capacity_tbl(cap_det).resource_name,l_debug);
                  print_debug('available = '||x_resource_capacity_tbl(cap_det).available_capacity,l_debug);
                  print_debug('planned = '||x_resource_capacity_tbl(cap_det).planned_load,l_debug);

                  END IF;

                END IF;
              END IF;
            END IF;

            IF l_total_quantity_to_do = 0 AND l_planned_load_task > 0 THEN
              cap_det := -1;
              print_debug('in machine calculation', l_debug);
              -- now assign the total load to the machinery.
              IF x_labor_suited_tbl(suit).resource_type = 1 THEN
                print_debug('machine is ' || x_labor_suited_tbl(suit)
                            .resource_name,
                            l_debug);
                FOR l_cap_det IN x_resource_capacity_tbl.first .. x_resource_capacity_tbl.last LOOP
                  IF x_resource_capacity_tbl(l_cap_det)
                  .resource_name = x_labor_suited_tbl(suit).resource_name THEN
                    cap_det := l_cap_det;
                    EXIT;
                  END IF;
                END LOOP;

                IF x_resource_capacity_tbl(cap_det)
                .available_capacity > l_planned_load_task THEN
                  x_resource_capacity_tbl(cap_det).planned_load := x_resource_capacity_tbl(cap_det)
                                                                  .planned_load +
                                                                   l_planned_load_task;
                  x_resource_capacity_tbl(cap_det).planned_tasks := x_resource_capacity_tbl(cap_det)
                                                                   .planned_tasks +
                                                                    l_complete_machine;
                  x_resource_capacity_tbl(cap_det).available_capacity := x_resource_capacity_tbl(cap_det)
                                                                        .available_capacity -
                                                                         l_planned_load_task;
                  l_planned_load_task := 0;
                  l_complete_machine := 0;
                ELSIF x_resource_capacity_tbl(cap_det)
                .available_capacity < l_planned_load_task THEN
                  IF l_suit_count > suit THEN
                    print_debug('more machine available', l_debug);
                    IF x_resource_capacity_tbl(cap_det)
                    .available_capacity > 0 THEN
                      x_resource_capacity_tbl(cap_det).planned_load := x_resource_capacity_tbl(cap_det)
                                                                      .planned_load +
                                                                       x_resource_capacity_tbl(cap_det)
                                                                      .available_capacity;
                      l_planned_load_task := l_planned_load_task -
                                             x_resource_capacity_tbl(cap_det)
                                            .available_capacity;
                      x_resource_capacity_tbl(cap_det).available_capacity := 0;
                      x_resource_capacity_tbl(cap_det).planned_tasks := x_resource_capacity_tbl(cap_det)
                                                                       .planned_tasks +
                                                                        l_complete_machine;
                      l_complete_machine := 0;
                    END IF;
                  ELSE
                    print_debug('final machine', l_debug);
                    print_debug('x_resource_capacity_tbl(cap_det).resource_name = ' ||
                                x_resource_capacity_tbl(cap_det)
                                .resource_name,
                                l_debug);
                    x_resource_capacity_tbl(cap_det).planned_load := x_resource_capacity_tbl(cap_det)
                                                                    .planned_load +
                                                                     l_planned_load_task;
                    x_resource_capacity_tbl(cap_det).available_capacity := x_resource_capacity_tbl(cap_det)
                                                                          .available_capacity -
                                                                           l_planned_load_task;
                    print_debug('x_resource_capacity_tbl(cap_det).planned_load = ' ||
                                x_resource_capacity_tbl(cap_det)
                                .planned_load,
                                l_debug);
                    l_planned_load_task := 0;
                    x_resource_capacity_tbl(cap_det).planned_tasks := x_resource_capacity_tbl(cap_det)
                                                                     .planned_tasks +
                                                                      l_complete_machine;
                    l_complete_machine := 0;
                  END IF;
                END IF;
              END IF;
            END IF;

          END LOOP;

        END IF;

      END LOOP;
    end if;

    for m2 in x_resource_capacity_tbl.FIRST .. x_resource_capacity_tbl.LAST LOOP

      print_debug('************************ Resource Details after planning, ***************************',
                  l_debug);
      print_debug('x_resource_capacity_tbl(m2).resource_name ' ||
                  x_resource_capacity_tbl(m2).resource_name,
                  l_debug);
      print_debug('x_resource_capacity_tbl(m2).resource_type ' ||
                  x_resource_capacity_tbl(m2).resource_type,
                  l_debug);
      print_debug('x_resource_capacity_tbl(m2).total_capacity ' ||
                  x_resource_capacity_tbl(m2).total_capacity,
                  l_debug);
      print_debug('x_resource_capacity_tbl(m2).available_capacity ' ||
                  x_resource_capacity_tbl(m2).available_capacity,
                  l_debug);
      print_debug('x_resource_capacity_tbl(m2).planned_load ' ||
                  x_resource_capacity_tbl(m2).planned_load,
                  l_debug);
      print_debug('x_resource_capacity_tbl(m2).current_load ' ||
                  x_resource_capacity_tbl(m2).current_load,
                  l_debug);
      print_debug('x_resource_capacity_tbl(m2).planned_tasks ' ||
                  x_resource_capacity_tbl(m2).planned_tasks,
                  l_debug);
      print_debug('x_resource_capacity_tbl(m2).actual_tasks ' ||
                  x_resource_capacity_tbl(m2).actual_tasks,
                  l_debug);

    end loop;

  end;




  procedure rules_labor_planning(p_planning_criteria_id in number,
                               p_wave_header_id       in number,
                               p_move_order_hdr_id    in number,
                               p_org_id number,
                               x_return_status        out nocopy varchar2)

 is

  --  p_move_order_header_id number := 3013761;

  l_labor_setup_mode varchar2(1);
  l_tbl_count number;
  l_tbl_start number;

  cursor c_parent_mmtts_zone is
    SELECT DISTINCT mmtt1.transaction_temp_id,
                    mmtt1.standard_operation_id,
                    mmtt1.parent_line_id,
                    mmtt1.transaction_quantity,
                    wz1.zone_name from_zone,
                    Decode(mmtt1.transfer_to_location,
                           NULL,
                           NULL,
                           wz2.zone_name) to_zone,
                    mmtt1.transaction_uom,
                    mmtt1.operation_plan_id,
                    mmtt1.inventory_item_id
      FROM mtl_material_transactions_temp mmtt1,
           mtl_material_transactions_temp mmtt2,
           wms_zone_locators              wzl1,
           wms_zone_locators              wzl2,
           wms_zones_vl                   wz1,
           wms_zones_vl                   wz2
     WHERE mmtt2.move_order_header_id = p_move_order_hdr_id
       and mmtt1.locator_id = wzl1.inventory_location_id
       and (mmtt1.transfer_to_location = wzl2.inventory_location_id OR
           mmtt1.transfer_to_location IS NULL)
       and mmtt1.organization_id = wzl1.organization_id
       and mmtt1.organization_id = wzl2.organization_id
       and wz1.zone_id = wzl1.zone_id
       and wz2.zone_id = wzl2.zone_id
       and wz1.zone_type = 'L'
       and wz2.zone_type = 'L'
       AND (mmtt1.transaction_temp_id = mmtt2.transaction_temp_id OR
           mmtt1.transaction_temp_id = mmtt2.parent_line_id)
       AND (mmtt2.parent_line_id IS NULL OR
           mmtt1.transaction_temp_id = mmtt1.parent_line_id);

  p_parent_line_id        number;
  p_standard_operation_id number;
  p_transaction_qty       number;

  cursor c_child_mmtts_zone IS
    select distinct transaction_temp_id,
                    wz1.zone_name from_zone,
                    wz2.zone_name to_zone,
                    transaction_uom,
                    operation_plan_id,
                    inventory_item_id,
                    dropping_order,
                    transaction_quantity
      from mtl_material_transactions_temp mmtt,
           MTL_SECONDARY_INVENTORIES      MSI,
           wms_zone_locators              wzl1,
           wms_zone_locators              wzl2,
           wms_zones_vl                   wz1,
           wms_zones_vl                   wz2
     where move_order_header_id = p_move_order_hdr_id
          --AND mmtt.transfer_subinventory =msi.SECONDARY_INVENTORY_NAME
       AND mmtt.organization_id = msi.organization_id
       and mmtt.locator_id = wzl1.inventory_location_id
       and mmtt.transfer_to_location = wzl2.inventory_location_id
       and mmtt.organization_id = wzl1.organization_id
       and mmtt.organization_id = wzl2.organization_id
       and wz1.zone_id = wzl1.zone_id
       and wz2.zone_id = wzl2.zone_id
       and wz1.zone_type = 'L'
       and wz2.zone_type = 'L'
       and wzl2.subinventory_code = msi.SECONDARY_INVENTORY_NAME
       and parent_line_id = p_parent_line_id
     order by dropping_order;

  cursor c_parent_mmtts is
    SELECT DISTINCT mmtt1.transaction_temp_id,
                    mmtt1.standard_operation_id,
                    mmtt1.parent_line_id,
                    mmtt1.transaction_quantity,
                    mmtt1.subinventory_code,
                    mmtt1.transfer_subinventory,
                    mmtt1.transaction_uom,
                    mmtt1.operation_plan_id,
                    mmtt1.inventory_item_id
      FROM mtl_material_transactions_temp mmtt1,
           mtl_material_transactions_temp mmtt2
     WHERE mmtt2.move_order_header_id = p_move_order_hdr_id
       AND (mmtt1.transaction_temp_id = mmtt2.transaction_temp_id OR
           mmtt1.transaction_temp_id = mmtt2.parent_line_id)
       AND (mmtt2.parent_line_id IS NULL OR
           mmtt1.transaction_temp_id = mmtt1.parent_line_id);

  cursor c_child_mmtts IS
    select distinct transaction_temp_id,
                    subinventory_code,
                    transfer_subinventory,
                    transaction_uom,
                    operation_plan_id,
                    inventory_item_id,
                    dropping_order,
                    transaction_quantity
      from mtl_material_transactions_temp mmtt,
           MTL_SECONDARY_INVENTORIES      MSI
     where move_order_header_id = p_move_order_hdr_id
       AND mmtt.transfer_subinventory = msi.SECONDARY_INVENTORY_NAME
       AND mmtt.organization_id = msi.organization_id
       and parent_line_id = p_parent_line_id
     order by dropping_order;

  n1         number := 0;
  prev_index number;
  j          number := 0;
  --i number := 1;
  l_dest_subinventory varchar2(30);
  l_allocation_method varchar2(1);

  x_labor_time_tbl           labor_time_tbl;
  c_labor_time_tbl           labor_time_tbl;
  l_debug                    NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'),
                                           0);
  v_destination_subinventory VARCHAR2(30);
  v_zone_name varchar2(100);
begin

  select labor_setup_mode, allocation_method, destination_subinventory
    into l_labor_setup_mode,
         l_allocation_method,
         v_destination_subinventory
    from wms_wp_planning_criteria_vl
   where PLANNING_CRITERIA_ID = p_planning_criteria_id;

if v_destination_subinventory is null THEN

 SELECT staging_subinventory
    INTO   v_destination_subinventory
    FROM wms_wp_wave_headers_vl
   WHERE wave_header_id = p_wave_header_id;

 end if;

  if l_allocation_method in ('N','I','X') and p_move_order_hdr_id <> -1then

   if l_labor_setup_mode = 'S' then

    for l_parent in c_parent_mmtts loop

      p_parent_line_id        := l_parent.parent_line_id;
      p_standard_operation_id := l_parent.standard_operation_id;
      p_transaction_qty       := l_parent.transaction_quantity;

      if p_parent_line_id is not null then

        j := 0;
        for l_child in c_child_mmtts loop

          if j > 0 then
            -- From the second time onwards

            if l_dest_subinventory = l_child.transfer_subinventory then

              x_labor_time_tbl(prev_index).picking_subinventory := l_child.subinventory_code;
              x_labor_time_tbl(prev_index).destination_SUBINVENTORY := l_child.transfer_subinventory;
              x_labor_time_tbl(prev_index).demand_qty_picking_uom := x_labor_time_tbl(prev_index)
                                                                    .demand_qty_picking_uom +
                                                                     l_child.transaction_quantity;

              prev_index := n1;

            else

              n1 := n1 + 1;

              x_labor_time_tbl(n1).picking_subinventory := l_dest_subinventory;
              x_labor_time_tbl(n1).destination_SUBINVENTORY := l_child.transfer_subinventory;
              x_labor_time_tbl(n1).picking_uom := l_child.transaction_uom;
              x_labor_time_tbl(n1).demand_qty_picking_uom := l_child.transaction_quantity;
              x_labor_time_tbl(n1).operation_plan_id := l_child.operation_plan_id;
              x_labor_time_tbl(n1).inventory_item_id := l_child.inventory_item_id;
              x_labor_time_tbl(n1).standard_operation_id := p_standard_operation_id;

              prev_index := n1;

            end if;

          else

            n1 := n1 + 1;

            x_labor_time_tbl(n1).picking_subinventory := l_child.subinventory_code;
            x_labor_time_tbl(n1).destination_SUBINVENTORY := l_child.transfer_subinventory;
            x_labor_time_tbl(n1).picking_uom := l_child.transaction_uom;
            x_labor_time_tbl(n1).demand_qty_picking_uom := l_child.transaction_quantity;
            x_labor_time_tbl(n1).operation_plan_id := l_child.operation_plan_id;
            x_labor_time_tbl(n1).inventory_item_id := l_child.inventory_item_id;
            x_labor_time_tbl(n1).standard_operation_id := p_standard_operation_id;

            prev_index := n1;
            --p_transaction_qty := p_transaction_qty - l_child.transaction_quantity;

          end if;

          l_dest_subinventory := l_child.transfer_subinventory;

          j := j + 1;

        end loop;

      else

        n1 := n1 + 1;

        x_labor_time_tbl(n1).picking_subinventory := l_parent.subinventory_code;
        x_labor_time_tbl(n1).destination_SUBINVENTORY := l_parent.transfer_subinventory;
        x_labor_time_tbl(n1).picking_uom := l_parent.transaction_uom;
        x_labor_time_tbl(n1).demand_qty_picking_uom := l_parent.transaction_quantity;
        x_labor_time_tbl(n1).operation_plan_id := l_parent.operation_plan_id;
        x_labor_time_tbl(n1).inventory_item_id := l_parent.inventory_item_id;
        x_labor_time_tbl(n1).standard_operation_id := p_standard_operation_id;

        prev_index := n1;

      end if;

    end loop;

  else

    for l_parent in c_parent_mmtts_zone loop

      p_parent_line_id        := l_parent.parent_line_id;
      p_standard_operation_id := l_parent.standard_operation_id;
      p_transaction_qty       := l_parent.transaction_quantity;

      if p_parent_line_id is not null then

        j := 0;
        for l_child in c_child_mmtts_zone loop

          if j > 0 then
            -- From the second time onwards

            if l_dest_subinventory = l_child.to_zone then

              x_labor_time_tbl(prev_index).picking_subinventory := l_child.from_zone;
              x_labor_time_tbl(prev_index).destination_SUBINVENTORY := l_child.to_zone;
              x_labor_time_tbl(prev_index).demand_qty_picking_uom := x_labor_time_tbl(prev_index)
                                                                    .demand_qty_picking_uom +
                                                                     l_child.transaction_quantity;

              prev_index := n1;

            else

              n1 := n1 + 1;

              x_labor_time_tbl(n1).picking_subinventory := l_dest_subinventory;
              x_labor_time_tbl(n1).destination_SUBINVENTORY := l_child.to_zone;
              x_labor_time_tbl(n1).picking_uom := l_child.transaction_uom;
              x_labor_time_tbl(n1).demand_qty_picking_uom := l_child.transaction_quantity;
              x_labor_time_tbl(n1).operation_plan_id := l_child.operation_plan_id;
              x_labor_time_tbl(n1).inventory_item_id := l_child.inventory_item_id;
              x_labor_time_tbl(n1).standard_operation_id := p_standard_operation_id;

              prev_index := n1;

            end if;

          else

            n1 := n1 + 1;

            x_labor_time_tbl(n1).picking_subinventory := l_child.from_zone;
            x_labor_time_tbl(n1).destination_SUBINVENTORY := l_child.to_zone;
            x_labor_time_tbl(n1).picking_uom := l_child.transaction_uom;
            x_labor_time_tbl(n1).demand_qty_picking_uom := l_child.transaction_quantity;
            x_labor_time_tbl(n1).operation_plan_id := l_child.operation_plan_id;
            x_labor_time_tbl(n1).inventory_item_id := l_child.inventory_item_id;
            x_labor_time_tbl(n1).standard_operation_id := p_standard_operation_id;

            prev_index := n1;
            --p_transaction_qty := p_transaction_qty - l_child.transaction_quantity;

          end if;

          l_dest_subinventory := l_child.to_zone;

          j := j + 1;

        end loop;

      else

        n1 := n1 + 1;

        x_labor_time_tbl(n1).picking_subinventory := l_parent.from_zone;
        x_labor_time_tbl(n1).destination_SUBINVENTORY := l_parent.to_zone;
        x_labor_time_tbl(n1).picking_uom := l_parent.transaction_uom;
        x_labor_time_tbl(n1).demand_qty_picking_uom := l_parent.transaction_quantity;
        x_labor_time_tbl(n1).operation_plan_id := l_parent.operation_plan_id;
        x_labor_time_tbl(n1).inventory_item_id := l_parent.inventory_item_id;
        x_labor_time_tbl(n1).standard_operation_id := p_standard_operation_id;

        prev_index := n1;

      end if;

    end loop;

  end if;

  if x_labor_time_tbl.count > 0 then

    for i IN x_labor_time_tbl.FIRST .. x_labor_time_tbl.LAST loop

      print_debug('x_labor_time_tbl(i).source ' || x_labor_time_tbl(i)
                  .picking_subinventory,
                  l_debug);
      print_debug('x_labor_time_tbl(i).destination ' ||
                  x_labor_time_tbl(i).destination_SUBINVENTORY,
                  l_debug);
      print_debug('x_labor_time_tbl(i).unit_of_measure ' ||
                  x_labor_time_tbl(i).picking_uom,
                  l_debug);
      print_debug('x_labor_time_tbl(i).demand_qty_picking_uom ' ||
                  x_labor_time_tbl(i).demand_qty_picking_uom,
                  l_debug);
      print_debug('x_labor_time_tbl(i).operation_plan_id ' ||
                  x_labor_time_tbl(i).operation_plan_id,
                  l_debug);
      print_debug('x_labor_time_tbl(i).inventory_item_id ' ||
                  x_labor_time_tbl(i).inventory_item_id,
                  l_debug);
      print_debug('x_labor_time_tbl(i).standard_operation_id ' ||
                  x_labor_time_tbl(i).standard_operation_id,
                  l_debug);

    end loop;

  end if;

  labor_resource_planning(x_labor_time_tbl,
                          1,
                          'R',
                          p_planning_criteria_id,
                          p_wave_header_id,
                          p_org_id);

end if;

if l_allocation_method in('C', 'N', 'X') and p_move_order_hdr_id = -1 then

print_debug('Getting the crossdock movements --- >  ', l_debug);

print_debug('Bulk Labor Planning Enabled ', l_debug);

 if l_labor_setup_mode = 'S' then

SELECT 'Not Applicable',v_destination_subinventory,
 Min(requested_quantity_uom),
 Sum(crossdock_quantity),
  -1, inventory_item_id,
  -1 bulk collect into
  c_labor_time_tbl
  FROM wms_wp_wave_lines
  WHERE wave_header_id = p_wave_header_id
  GROUP BY inventory_item_id
   ORDER BY inventory_item_id;

else  --Zone


	SELECT distinct zone_name into v_zone_name from wms_zones_vl wz, wms_zone_locators wzl WHERE
	wz.zone_id=wzl.zone_id
	and wz.zone_type ='L'
	and wzl.subinventory_code=v_destination_subinventory;


	SELECT 'Not Applicable', v_zone_name,
 Min(requested_quantity_uom),
 Sum(crossdock_quantity),
  -1, inventory_item_id,
  -1 bulk collect into
  c_labor_time_tbl
  FROM wms_wp_wave_lines
  WHERE wave_header_id = p_wave_header_id
  GROUP BY inventory_item_id
   ORDER BY inventory_item_id;


end if;

if l_allocation_method = 'C' then labor_resource_planning(c_labor_time_tbl,
                                                          1,
                                                          'R',
                                                          p_planning_criteria_id,
                                                          p_wave_header_id,
                                                          p_org_id);

elsif l_allocation_method in('N', 'X') then

labor_resource_planning(c_labor_time_tbl,
                        2,
                        'R',
                        p_planning_criteria_id,
                        p_wave_header_id,
                        p_org_id);

end if;

end if;


 DELETE FROM wms_wp_labor_Statistics
   WHERE wave_header_id = p_wave_header_id;

l_tbl_count := x_resource_capacity_tbl.count;

  if x_resource_capacity_tbl.count > 0 then
   --forall i in 0 .. l_tbl_count     -- dbchange1
   for i in x_resource_capacity_tbl.first .. x_resource_capacity_tbl.last loop
      insert into wms_wp_labor_statistics
        (wave_header_id,
         resource_name,
         planned_wave_load,
         total_capacity,
         actual_workload,
         available_capacity,
         NUMBER_OF_ACTUAL_TASKS,
         NUMBER_OF_PLANNED_TASKS)
      values
        (p_wave_header_id,
         x_resource_capacity_tbl(i).resource_name,
         x_resource_capacity_tbl(i).planned_load,
         x_resource_capacity_tbl(i).total_Capacity,
         x_resource_capacity_tbl(i).current_load,
         x_resource_capacity_tbl(i).available_capacity,
         x_resource_capacity_tbl(i).actual_tasks,
         x_resource_capacity_tbl(i).planned_tasks);
         end loop;
  end if;

  -- x_labor_stats_tbl.delete;
 -- x_labor_time_tbl.delete;
 -- c_labor_time_tbl.delete;
--  x_resource_capacity_tbl.delete;
  -- x_labor_dtl_tbl.delete;
  -- x_machine_dtl_tbl.delete;
  --  x_labor_stats_tbl_tmp.delete;

  commit;
  x_return_status := 'S';

  exception
  when others then

      print_debug('Rules Labor Planning : ' || SQLCODE || ' : ' ||
                  SQLERRM,
                  l_debug);
   x_return_status := 'E';
end rules_labor_planning;


  procedure call_planned_crossdock(p_wave_header_id       in number,
                                   p_planning_criteria_id in number)

   is
    l_api_version_number NUMBER := 1.0;
    l_commit             VARCHAR2(1) := FND_API.G_FALSE;

    -- X-dock, declare package level global variables
    g_allocation_method  WSH_PICKING_BATCHES.ALLOCATION_METHOD%TYPE;
    g_xdock_delivery_ids WSH_UTIL_CORE.Id_Tab_Type; -- used for X-dock only
    g_xdock_detail_ids   WSH_PICK_LIST.DelDetTabTyp; -- used for X-dock only

    --xdock wsh_pr_criteria.relRecTabTyp;

    xdock           WSH_PR_CRITERIA.relRecTabTyp;
    m3              number := 0;
    l_return_status VARCHAR2(1);
    l_msg_data      VARCHAR2(120);
    l_msg_count     NUMBER;
  l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    cursor c_crossdock_demand_lines is
      select wwl.source_header_number,
             wwl.source_line_id,
             wdd.customer_id,
             wdd.source_header_id,
             wwl.delivery_detail_id,
             wwl.organization_id,
             wwl.inventory_item_id,
             (wwl.requested_quantity - nvl(wwr.allocated_quantity, 0)) requested_quantity,
             wwl.requested_quantity_uom,
             inv_salesorder.get_salesorder_for_oeheader(wdd.source_header_id) demand_source_header_id
        from wms_wp_wave_headers_vl       wwh,
             wms_wp_wave_lines            wwl,
             wms_wp_planning_criteria_vl  wwp,
             wsh_delivery_details         wdd,
             wms_wp_rules_simulation wwr
       where wwh.wave_header_id = p_wave_header_id
         and wwp.planning_criteria_id = p_planning_criteria_id
         and wwh.planning_criteria_id = wwp.planning_criteria_id
         and wwh.wave_header_id = wwl.wave_header_id
         and wwr.delivery_detail_id = wwl.delivery_detail_id
         and wwr.wave_header_id=wwl.wave_header_id
         and wwl.delivery_detail_id = wdd.delivery_Detail_id
       and wdd.released_status in ('R','B'); --- For Hot Order Changes
         --- For Hot Order Changes;;

  begin

    g_planning_criteria_id := p_planning_criteria_id;

    for l_crossdock in c_crossdock_demand_lines loop

if  l_crossdock.requested_quantity >0 then
 xdock(m3).requested_quantity := l_crossdock.requested_quantity;
print_debug('In Crossdock Requested Quantity is '||l_crossdock.requested_quantity,l_debug);

      xdock(m3).source_line_id := l_crossdock.source_line_id;
      xdock(m3).source_header_id := l_crossdock.source_header_id;
      xdock(m3).organization_id := l_crossdock.organization_id;
      xdock(m3).inventory_item_id := l_crossdock.inventory_item_id;
      xdock(m3).delivery_detail_id := l_crossdock.delivery_detail_id;


      xdock(m3).demand_source_header_id := l_crossdock.demand_source_header_id;
      xdock(m3).source_header_number := l_crossdock.source_header_number;
      -- xdock(m3).line_number :=l_crossdock.line_number;
      xdock(m3).customer_id := l_crossdock.customer_id;
      xdock(m3).requested_quantity_uom := l_crossdock.requested_quantity_uom;
      m3 := m3 + 1;
    end if;
    end loop;


    WMS_Xdock_Pegging_Pub.Planned_Cross_Dock(p_api_version         => l_api_version_number,
                                             p_init_msg_list       => fnd_api.g_false,
                                             p_commit              => l_commit,
                                             p_batch_id            => null,
                                             p_wsh_release_table   => xdock,
                                             p_trolin_delivery_ids => g_xdock_delivery_ids,
                                             p_del_detail_id       => g_xdock_detail_ids,
                                             x_return_status       => l_return_status,
                                             x_msg_count           => l_msg_count,
                                             x_msg_data            => l_msg_data,
                                             p_simulation_mode     => 'Y');

  end call_planned_crossdock;


  PROCEDURE initialize(p_wave_id NUMBER, p_organization_id NUMBER, x_return_status out nocopy varchar2) IS


    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

    CURSOR fetch_wdd(p_wave_id number) is
      select wdd.delivery_detail_id,
             wdd.inventory_item_id,
             subinventory,
             locator_id,
             lot_number,
             revision,
             wdd.source_header_id,
             --wdd.requested_quantity,
             wwr.requested_quantity - Nvl(wwr.crossdocked_quantity, 0),
             wdd.source_line_id,
             wdd.REQUESTED_QUANTITY_UOM,
             SRC_REQUESTED_QUANTITY,
             SRC_REQUESTED_QUANTITY_UOM,
             --wdd.requested_quantity2,
             wwr.requested_quantity2 - Nvl(wwr.crossdocked_quantity2, 0),
             wdd.requested_quantity_uom2,
             ship_set_id,
             SHIP_MODEL_COMPLETE_FLAG,
             top_model_line_id,
             date_scheduled,
             project_id,
             task_id,
             unit_NUMBER,
             preferred_grade,
             NULL,
             NULL
        FROM wsh_delivery_details         wdd,
             wms_wp_wave_lines            wwl,
             wms_wp_rules_simulation wwr
       WHERE wdd.released_status in ('R', 'B')
         AND wwr.delivery_detail_id = wdd.delivery_detail_id
         and wwr.wave_header_id=wwl.wave_header_id
         and wdd.delivery_detail_id = wwl.delivery_detail_id
         and wwl.wave_header_id = p_wave_id
         and wwr.wave_header_id=p_wave_id
       ORDER BY wave_line_id;

  BEGIN
    print_debug('In Initialize p_wave_id: '||p_wave_id||' '||'p_organization_id: '||p_organization_id, l_debug);




    SELECT enforce_ship_set_and_smc,
           default_stage_subinventory,
           default_stage_locator_id
      INTO g_enforce_ship_set_and_smc,
           g_default_stage_subinventory,
           g_default_stage_locator_id
      FROM WSH_SHIPPING_PARAMETERS
     WHERE ORGANIZATION_ID = p_organization_id;


    --g_from_subinventory := nvl(Pick from subinventory given in Planning criteria, g_pick_subinventory);
    g_from_subinventory := nvl(g_from_subinventory_plan, g_pick_subinventory);
    --g_from_locator := NULL since in wave planning currently no provision for default pick from locator
    g_from_locator    := NULL;
    g_to_subinventory := g_staging_subinventory;
  --  print_debug('initialize 2',l_debug);
  --g_to_locator  := staging locator given at wave header



    OPEN fetch_wdd(p_wave_id);
    fetch fetch_wdd bulk collect
      into g_troline_table;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

   EXCEPTION
    WHEN No_Data_Found THEN
      print_debug('No Data Found Exception in initialize',l_debug);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      print_debug('OTHER Exception in initialize',l_debug);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END initialize;



   PROCEDURE create_move_order(p_organization_id           number,
                              p_wave_id NUMBER,
                              x_mo_header_id   OUT NOCOPY NUMBER,
                              x_request_number OUT NOCOPY NUMBER,
                              x_return_status out nocopy varchar2) IS

    l_standalone_mode          VARCHAR2(1) := nvl(fnd_profile.VALUE('WMS_DEPLOYMENT_MODE'), 'I');
    l_line_id                  NUMBER;
    l_result                   number;
    l_requested_quantity       number;
    l_result2                  number;
    l_requested_quantity2      number;
    l_demand_source_header_id  NUMBER;
    l_primary_uom_code         varchar2(3);
    l_ship_set_id              NUMBER;
    l_top_model_line_id        NUMBER;
    l_ship_model_complete_flag VARCHAR2(1);
    l_last_top_model_line_id   NUMBER;
    l_last_model_quantity      NUMBER;
    l_last_ship_set_id         NUMBER;
    l_ordered_quantity         NUMBER;
    l_order_quantity_uom       VARCHAR2(1);
    l_request_number number;
    l_mo_header_id   number;
    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
   -- l_count number := 0;
   l_tbl_count number;
   l_tbl_first number;
   l_tbl_last number;
   l_mtrl_count NUMBER := 0;
   l_wdd_count NUMBER := 0;

   CURSOR fetch_wdd(p_wave_id NUMBER) IS
   select wdd.delivery_detail_id,
             'DELIVERY_DETAIL'
          FROM wsh_delivery_details         wdd,
             wms_wp_wave_lines            wwl,
             wms_wp_rules_simulation wwr
       WHERE wdd.released_status in ('R', 'B')
         AND wwr.delivery_detail_id = wdd.delivery_detail_id
         and wwr.wave_header_id=wwl.wave_header_id
         and wdd.delivery_detail_id = wwl.delivery_detail_id
         and wwl.wave_header_id = p_wave_id
         and wwr.wave_header_id=p_wave_id
       ORDER BY wave_line_id;


   l_attr_tab            wsh_delivery_autocreate.grp_attr_tab_type;
   l_action_rec          wsh_delivery_autocreate.action_rec_type;
   l_target_rec          wsh_delivery_autocreate.grp_attr_rec_type;
   l_group_info          wsh_delivery_autocreate.grp_attr_tab_type;
   l_matched_entities    wsh_util_core.id_tab_type;
   l_out_rec             wsh_delivery_autocreate.out_rec_type;

   TYPE group_match_seq_rec_type IS RECORD(
      delivery_detail_id NUMBER,
      match_group_id     NUMBER,
      delivery_group_id  NUMBER);

    TYPE group_match_seq_tab_type IS TABLE OF group_match_seq_rec_type INDEX BY BINARY_INTEGER;
   l_group_match_seq_tbl group_match_seq_tab_type;

   TYPE num_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   l_carton_grouping_tbl  num_tbl_type;

   l_match_found    BOOLEAN;
   l_return_status varchar2(10);
  BEGIN
    print_debug('In Create Move Order', l_debug);
    SAVEPOINT create_move_order;
    --x_return_status := fnd_api.g_ret_sts_success;

    SELECT MTL_TXN_REQUEST_HEADERS_S.NEXTVAL
      into l_request_number
      FROM SYS.DUAL;

    l_mo_header_id := INV_TRANSFER_ORDER_PVT.get_next_header_id;

    INSERT INTO mtl_txn_request_headers
      (HEADER_ID,
       REQUEST_NUMBER,
       TRANSACTION_TYPE_ID,
       MOVE_ORDER_TYPE,
       ORGANIZATION_ID,
       DESCRIPTION,
       DATE_REQUIRED,
       FROM_SUBINVENTORY_CODE,
       TO_SUBINVENTORY_CODE,
       TO_ACCOUNT_ID,
       HEADER_STATUS,
       STATUS_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATE_LOGIN,
       LAST_UPDATE_DATE,
       CREATED_BY,
       CREATION_DATE,
       REQUEST_ID,
       PROGRAM_APPLICATION_ID,
       PROGRAM_ID,
       PROGRAM_UPDATE_DATE,
       GROUPING_RULE_ID,
       ATTRIBUTE1,
       ATTRIBUTE2,
       ATTRIBUTE3,
       ATTRIBUTE4,
       ATTRIBUTE5,
       ATTRIBUTE6,
       ATTRIBUTE7,
       ATTRIBUTE8,
       ATTRIBUTE9,
       ATTRIBUTE10,
       ATTRIBUTE11,
       ATTRIBUTE12,
       ATTRIBUTE13,
       ATTRIBUTE14,
       ATTRIBUTE15,
       ATTRIBUTE_CATEGORY,
       SHIP_TO_LOCATION_ID,
       FREIGHT_CODE,
       SHIPMENT_METHOD,
       AUTO_RECEIPT_FLAG,
       REFERENCE_ID,
       REFERENCE_DETAIL_ID,
       ASSIGNMENT_ID)
    VALUES
      (l_mo_header_id,
       l_request_number,
       NULL,
       INV_GLOBALS.G_MOVE_ORDER_PICK_WAVE,
       p_organization_id,
       NULL,
       sysdate,
       NULL,
       NULL,
       NULL,
       INV_Globals.G_TO_STATUS_PREAPPROVED,
       NULL,
       FND_GLOBAL.USER_ID,
       FND_GLOBAL.CONC_LOGIN_ID,
       SYSDATE,
       FND_GLOBAL.USER_ID,
       SYSDATE,
       NULL,
       NULL,
       NULL,
       NULL,
       g_PICK_GROUPING_RULE_ID,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL);

    print_debug('Created Move Order: header_id '||l_mo_header_id||' request_number '||l_request_number, l_debug);


    FOR i IN g_troline_table.first .. g_troline_table.last LOOP
        l_attr_tab(i).entity_id := g_troline_table(i).delivery_detail_id;
        l_attr_tab(i).entity_type := 'DELIVERY_DETAIL';
    END LOOP;

    l_action_rec.action               := 'MATCH_GROUPS';
    l_action_rec.group_by_header_flag := 'N';

    print_debug('Calling Find Matching Groups ', l_debug);

    wsh_Delivery_autocreate.Find_Matching_Groups(p_attr_tab         => l_attr_tab,
                                                     p_action_rec       => l_action_rec,
                                                     p_target_rec       => l_target_rec,
                                                     p_group_tab        => l_group_info,
                                                     x_matched_entities => l_matched_entities,
                                                     x_out_rec          => l_out_rec,
                                                     x_return_status    => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
          print_debug('Error status from Find_Matching_Groups: ' || l_return_status, l_debug);
          RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    for i in 1 .. l_attr_tab.count loop

          l_match_found := FALSE;

          IF l_group_match_seq_tbl.count > 0 THEN
            --{
            FOR k in l_group_match_seq_tbl.FIRST .. l_group_match_seq_tbl.LAST LOOP
              --{
              IF l_attr_tab(i).group_id = l_group_match_seq_tbl(k).match_group_id THEN
                --{
                l_group_match_seq_tbl(i).delivery_group_id := l_group_match_seq_tbl(k).delivery_group_id;
                l_match_found := TRUE;
                EXIT;
                --}
              End IF;
              --}
            END LOOP;
            --}
          END IF;

          IF NOT l_match_found THEN

            l_group_match_seq_tbl(i).match_group_id := l_attr_tab(i).group_id;
            select WSH_DELIVERY_GROUP_S.nextval
              into l_group_match_seq_tbl(i).delivery_group_id
              from dual;

          End IF;

          print_debug('CARTON GROUPING ID : ' || l_group_match_seq_tbl(i).delivery_group_id, l_debug);

          l_carton_grouping_tbl(i) := l_group_match_seq_tbl(i).delivery_group_id;

        end loop;


   for i in g_troline_table.FIRST .. g_troline_table.LAST loop

    	SELECT MTL_TXN_REQUEST_LINES_S.NEXTVAL INTO l_seq_val FROM dual;     -- Changed
      l_line_id := l_seq_val;

      g_mtrl_tbl(i).LINE_ID := l_line_id;
      g_mtrl_tbl(i).HEADER_ID := l_mo_header_id;

      g_mtrl_tbl(i).LINE_NUMBER := i;
      g_mtrl_tbl(i).ORGANIZATION_ID := p_organization_id;
      g_mtrl_tbl(i).INVENTORY_ITEM_ID := g_troline_table(i).inventory_item_id;
      g_mtrl_tbl(i).REVISION := g_troline_table(i).revision;


      -- calculate g_mtrl_tbl.from_subinventory_code,from_locator_id
      IF ((g_troline_table(i).from_sub is NOT NULL) AND
         (g_from_subinventory IS NULL)) THEN
        g_mtrl_tbl(i).from_subinventory_code := g_troline_table(i).from_sub;
        -- Standalone project Changes : Begin
        IF (l_standalone_mode = 'D') THEN
          g_mtrl_tbl(i).from_locator_id := g_troline_table(i).from_locator;
        END IF;
      ELSE
        g_mtrl_tbl(i).from_subinventory_code := g_from_subinventory;
        -- Standalone project Changes
        -- wdd's loc id should be considered when released with pick from sub and no pick from loc
        IF (l_standalone_mode = 'D' AND g_from_locator IS NULL) THEN
          IF (g_mtrl_tbl(i).from_subinventory_code = g_from_subinventory) THEN
            g_mtrl_tbl(i).from_locator_id := g_troline_table(i)
                                            .from_locator;
          ELSE
            g_mtrl_tbl(i).from_locator_id := NULL;
          END IF;
        ELSE
          g_mtrl_tbl(i).from_locator_id := g_from_locator;
        END IF;
      END IF;



      -- calculate g_mtrl_tbl.revision,lot_number
      -- Standalone project Changes
      IF (l_standalone_mode = 'D') THEN
        g_mtrl_tbl(i).revision := g_troline_table(i).revision;
        g_mtrl_tbl(i).lot_number := g_troline_table(i).lot_number;
      END IF;

      g_mtrl_tbl(i).to_subinventory_code := g_to_subinventory;
      g_mtrl_tbl(i).to_locator_id := g_to_locator;

      g_mtrl_tbl(i).TO_ACCOUNT_ID := null;
      g_mtrl_tbl(i).SERIAL_NUMBER_START := null;
      g_mtrl_tbl(i).SERIAL_NUMBER_END := null;
      g_mtrl_tbl(i).UOM_CODE := g_troline_table(i).requested_quantity_uom;

      -- calculate g_mtrl_tbl(i).quantity
      l_result              := g_troline_table(i).requested_quantity;
      l_requested_quantity  := g_troline_table(i).requested_quantity;
      l_result2             := g_troline_table(i).requested_quantity2;
      l_requested_quantity2 := nvl(g_troline_table(i).requested_quantity2,
                                   0);


      l_demand_source_header_id := INV_SALESORDER.GET_SALESORDER_FOR_OEHEADER(g_troline_table(i).source_header_id);

      IF (g_from_subinventory is not null) THEN


        WSH_PICK_LIST.Calculate_Reservations(p_demand_source_header_id => l_demand_source_header_id,
                                             p_demand_source_line_id   => g_troline_table(i)
                                                                         .source_line_id,
                                             p_requested_quantity      => g_troline_table(i)
                                                                         .requested_quantity,
                                             -- Bug 4775539
                                             p_requested_quantity_uom     => g_troline_table(i)
                                                                            .requested_quantity_uom,
                                             p_src_requested_quantity_uom => g_troline_table(i)
                                                                            .src_requested_quantity_uom,
                                             p_src_requested_quantity     => g_troline_table(i)
                                                                            .src_requested_quantity,
                                             p_inv_item_id                => g_troline_table(i)
                                                                            .inventory_item_id,
                                             --  p_requested_quantity2        => g_troline_table(i).requested_quantity2,
                                             x_result  => l_result,
                                             x_result2 => l_result2);


      END IF;

      g_troline_table(i).requested_quantity := l_result;
      g_troline_table(i).SECONDARY_QUANTITY := to_number(nvl(l_result2, 0));
      g_mtrl_tbl(i).quantity := round(g_troline_table(i).requested_quantity,
                                      5);

      g_mtrl_tbl(i).QUANTITY_DELIVERED := NULL;
      g_mtrl_tbl(i).QUANTITY_DETAILED := null;
      g_mtrl_tbl(i).DATE_REQUIRED := g_troline_table(i).date_scheduled;
      g_mtrl_tbl(i).REASON_ID := null;
      g_mtrl_tbl(i).REFERENCE := null;
      g_mtrl_tbl(i).REFERENCE_TYPE_CODE := null;
      g_mtrl_tbl(i).REFERENCE_ID := null;
      g_mtrl_tbl(i).PROJECT_ID := g_troline_table(i).project_id;
      g_mtrl_tbl(i).TASK_ID := g_troline_table(i).task_id;
      g_mtrl_tbl(i).TRANSACTION_HEADER_ID := null;
      g_mtrl_tbl(i).LINE_STATUS := INV_Globals.G_TO_STATUS_PREAPPROVED;
      g_mtrl_tbl(i).STATUS_DATE := SYSDATE;
      g_mtrl_tbl(i).LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      g_mtrl_tbl(i).LAST_UPDATE_LOGIN := FND_GLOBAL.CONC_LOGIN_ID;
      g_mtrl_tbl(i).LAST_UPDATE_DATE := SYSDATE;
      g_mtrl_tbl(i).CREATED_BY := FND_GLOBAL.USER_ID;
      g_mtrl_tbl(i).CREATION_DATE := SYSDATE;
      g_mtrl_tbl(i).REQUEST_ID := null;
      g_mtrl_tbl(i).PROGRAM_APPLICATION_ID := null;
      g_mtrl_tbl(i).PROGRAM_ID := null;
      g_mtrl_tbl(i).PROGRAM_UPDATE_DATE := null;
      g_mtrl_tbl(i).ATTRIBUTE1 := null;
      g_mtrl_tbl(i).ATTRIBUTE2 := null;
      g_mtrl_tbl(i).ATTRIBUTE3 := null;
      g_mtrl_tbl(i).ATTRIBUTE4 := null;
      g_mtrl_tbl(i).ATTRIBUTE5 := null;
      g_mtrl_tbl(i).ATTRIBUTE6 := null;
      g_mtrl_tbl(i).ATTRIBUTE7 := null;
      g_mtrl_tbl(i).ATTRIBUTE8 := null;
      g_mtrl_tbl(i).ATTRIBUTE9 := null;
      g_mtrl_tbl(i).ATTRIBUTE10 := null;
      g_mtrl_tbl(i).ATTRIBUTE11 := null;
      g_mtrl_tbl(i).ATTRIBUTE12 := null;
      g_mtrl_tbl(i).ATTRIBUTE13 := null;
      g_mtrl_tbl(i).ATTRIBUTE14 := null;
      g_mtrl_tbl(i).ATTRIBUTE15 := null;
      g_mtrl_tbl(i).ATTRIBUTE_CATEGORY := null;

      g_mtrl_tbl(i).TXN_SOURCE_ID := l_demand_source_header_id;
      g_mtrl_tbl(i).TXN_SOURCE_LINE_ID := g_troline_table(i).source_line_id;
      g_mtrl_tbl(i).TXN_SOURCE_LINE_DETAIL_ID := g_troline_table(i).delivery_detail_id;

      g_mtrl_tbl(i).TRANSACTION_TYPE_ID := INV_GLOBALS.G_TYPE_TRANSFER_ORDER_STGXFR;
      g_mtrl_tbl(i).TRANSACTION_SOURCE_TYPE_ID := 2;

      -- calculate g_mtrl_tbl(i).PRIMARY_QUANTITY
      SELECT primary_uom_code
        INTO l_primary_uom_code
        FROM mtl_system_items
       WHERE organization_id = g_mtrl_tbl(i)
      .organization_id
         AND inventory_item_id = g_mtrl_tbl(i).inventory_item_id;

      IF l_primary_uom_code = g_mtrl_tbl(i).uom_code THEN
        g_mtrl_tbl(i).primary_quantity := g_mtrl_tbl(i).quantity;
      ELSE
        g_mtrl_tbl(i).primary_quantity := inv_convert.inv_um_convert(item_id       => g_mtrl_tbl(i)
                                                                                     .inventory_item_id,
                                                                     PRECISION     => NULL,
                                                                     from_quantity => g_mtrl_tbl(i)
                                                                                     .quantity,
                                                                     from_unit     => g_mtrl_tbl(i)
                                                                                     .uom_code,
                                                                     to_unit       => l_primary_uom_code,
                                                                     from_name     => NULL,
                                                                     to_name       => NULL);
      END IF;


    --	   SELECT WSH_DELIVERY_GROUP_S.NEXTVAL INTO l_seq_val FROM dual;     -- Changed


      g_mtrl_tbl(i).TO_ORGANIZATION_ID := null;
      g_mtrl_tbl(i).PUT_AWAY_STRATEGY_ID := null;
      g_mtrl_tbl(i).PICK_STRATEGY_ID := null;
      g_mtrl_tbl(i).SHIP_TO_LOCATION_ID := null;
      g_mtrl_tbl(i).UNIT_NUMBER := g_troline_table(i).unit_number;
      g_mtrl_tbl(i).REFERENCE_DETAIL_ID := null;
      g_mtrl_tbl(i).ASSIGNMENT_ID := null;
      g_mtrl_tbl(i).FROM_COST_GROUP_ID := null;
      g_mtrl_tbl(i).TO_COST_GROUP_ID := null;
      g_mtrl_tbl(i).LPN_ID := null;
      g_mtrl_tbl(i).TO_LPN_ID := null;
      g_mtrl_tbl(i).PICK_SLIP_NUMBER := null;
      g_mtrl_tbl(i).PICK_SLIP_DATE := null;
      g_mtrl_tbl(i).FROM_SUBINVENTORY_ID := null;
      g_mtrl_tbl(i).TO_SUBINVENTORY_ID := null;
      g_mtrl_tbl(i).INSPECTION_STATUS := null;
      g_mtrl_tbl(i).PICK_METHODOLOGY_ID := null;
      g_mtrl_tbl(i).CONTAINER_ITEM_ID := null;
      --g_mtrl_tbl(i).CARTON_GROUPING_ID := l_seq_val;
      g_mtrl_tbl(i).CARTON_GROUPING_ID := l_carton_grouping_tbl(i);
      g_mtrl_tbl(i).BACKORDER_DELIVERY_DETAIL_ID := null;
      g_mtrl_tbl(i).WMS_PROCESS_FLAG := null;
      g_mtrl_tbl(i).SHIP_SET_ID := g_troline_table(i).ship_set_id;

      -- calculate g_mtrl_tbl(i).SHIP_MODEL_ID and g_mtrl_tbl(i).MODEL_QUANTITY
      l_ship_set_id              := g_troline_table(i).ship_set_id;
      l_ship_model_complete_flag := g_troline_table(i).SHIP_MODEL_COMPLETE_FLAG;
      l_top_model_line_id        := g_troline_table(i).top_model_line_id;

      IF (g_enforce_ship_set_and_smc = 'Y') THEN
        IF (l_ship_set_id IS NOT NULL) THEN
          -- Ignore SMC if SS is Specified
          l_ship_model_complete_flag := NULL;
          l_top_model_line_id        := NULL;
        ELSE
          IF (NVL(l_ship_model_complete_flag, 'N') = 'N') THEN
            -- Ignore top_model_line_id if SMC is not set to Y
            l_top_model_line_id := NULL;
          END IF;
        END IF;

        IF (((l_last_ship_set_id IS NOT NULL) AND
           (l_last_ship_set_id <> NVL(l_ship_set_id, -99))) OR
           ((l_last_top_model_line_id IS NOT NULL) AND
           (l_last_top_model_line_id <> NVL(l_top_model_line_id, -99)))) THEN
          l_last_top_model_line_id := NULL;
          l_last_model_quantity    := NULL;
        END IF;
      ELSE
        l_ship_set_id              := NULL;
        l_top_model_line_id        := NULL;
        l_ship_model_complete_flag := 'N';
      END IF; -- g_enforce_ship_set_and_smc

      IF ((l_last_ship_set_id IS NULL) AND
         (l_last_top_model_line_id IS NULL)) THEN
        l_last_model_quantity := NULL;
      END IF;

      IF ((g_troline_table(i).ship_set_id is NULL) AND
         (l_top_model_line_id is NOT NULL)) THEN
        g_troline_table(i).top_model_line_id := l_top_model_line_id;
        IF (l_top_model_line_id <> NVL(l_last_top_model_line_id, -99)) THEN
          SELECT ORDERED_QUANTITY, ORDER_QUANTITY_UOM
            into l_ordered_quantity, l_order_quantity_uom
            FROM OE_ORDER_LINES_ALL
           WHERE LINE_ID = l_top_model_line_id;

          g_troline_table(i).top_model_quantity := l_ordered_quantity;
          l_last_model_quantity := l_ordered_quantity;
        ELSE
          g_troline_table(i).top_model_quantity := l_last_model_quantity;
        END IF;
      ELSE
        g_troline_table(i).top_model_line_id := NULL;
        g_troline_table(i).top_model_quantity := NULL;
      END IF;

      IF (g_enforce_ship_set_and_smc = 'Y') THEN
        l_last_ship_set_id       := l_ship_set_id;
        l_last_top_model_line_id := l_top_model_line_id;
      END IF;

      g_mtrl_tbl(i).ship_model_id := g_troline_table(i).top_model_line_id;
      g_mtrl_tbl(i).model_quantity := g_troline_table(i).top_model_quantity;

      g_mtrl_tbl(i).CROSSDOCK_TYPE := null;
      g_mtrl_tbl(i).REQUIRED_QUANTITY := null;
      g_mtrl_tbl(i).GRADE_CODE := g_troline_table(i).preferred_grade;
      g_mtrl_tbl(i).SECONDARY_QUANTITY := g_troline_table(i).SECONDARY_QUANTITY;
      g_mtrl_tbl(i).SECONDARY_QUANTITY_DELIVERED := null;
      g_mtrl_tbl(i).SECONDARY_QUANTITY_DETAILED := null;
      g_mtrl_tbl(i).SECONDARY_REQUIRED_QUANTITY := null;
      g_mtrl_tbl(i).SECONDARY_UOM_CODE := g_troline_table(i).requested_quantity_uom2;
      g_mtrl_tbl(i).WIP_ENTITY_ID := null;
      g_mtrl_tbl(i).REPETITIVE_SCHEDULE_ID := null;
      g_mtrl_tbl(i).OPERATION_SEQ_NUM := null;
      g_mtrl_tbl(i).WIP_SUPPLY_TYPE := null;
    end loop;

   print_debug('CREATE MO LINE END OF LOOP', l_debug);
   print_debug('g_mtrl_tbl.first: '||g_mtrl_tbl.first||' g_mtrl_tbl.last: '||g_mtrl_tbl.last||' g_mtrl_tbl.count: '||g_mtrl_tbl.count,l_debug);

    -- for each WDD in the current wave insert record in MTRL with following values:
    Forall i in g_mtrl_tbl.first .. g_mtrl_tbl.last
      insert into mtl_txn_request_lines values g_mtrl_tbl (i);

l_mtrl_count := SQL%ROWCOUNT;
      print_debug( l_mtrl_count||' move order lines inserted INTO MTRL', l_debug);



--l_tbl_first := g_mtrl_tbl.first;
--l_tbl_last := g_mtrl_tbl.last;

 --  FORALL i in l_tbl_first .. l_tbl_last
 --dbchange2
 FOR i in g_mtrl_tbl.first .. g_mtrl_tbl.last LOOP

      UPDATE wsh_delivery_details
      SET move_order_line_id = g_mtrl_tbl(i).line_id
      WHERE delivery_detail_id = g_mtrl_tbl(i).TXN_SOURCE_LINE_DETAIL_ID
      AND move_order_line_id IS NULL;

      l_wdd_count := l_wdd_count +SQL%ROWCOUNT;
end loop;

--l_wdd_count := SQL%ROWCOUNT;

    print_debug( l_wdd_count||' WDDs updated with move_order_line_Id', l_debug);

 print_debug( 'g_mtrl_tbl.Count is '||g_mtrl_tbl.Count, l_debug);

    IF l_wdd_count <> g_mtrl_tbl.Count THEN
      print_debug('Could not update all WDD lines', l_debug);
      RAISE fnd_api.g_exc_unexpected_error;
    ELSE
      g_update_wdd  := 'Y';
    END IF;

   x_mo_header_id   := l_mo_header_id;
   x_request_number := l_request_number;

   COMMIT;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   print_debug('Exiting Create Move Order', l_debug);

  EXCEPTION
    WHEN OTHERS THEN
      print_debug('Error in create_move_order',l_debug);
      ROLLBACK TO create_move_order;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END create_move_order;




PROCEDURE process_reservations
(p_wave_id  IN number,
 p_action   IN VARCHAR2,
 x_return_status OUT NOCOPY varchar2
) IS

cursor c_reservations (p_wave_id NUMBER) IS
SELECT *
FROM mtl_reservations
WHERE demand_source_line_id IN (SELECT DISTINCT source_line_id
                                FROM WMS_WP_WAVE_LINES
                                WHERE wave_header_id = p_wave_id);

TYPE rsTblTyp  is table of mtl_reservations%rowtype index by binary_integer;
l_rs_tbl  rsTblTyp;

l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);


BEGIN

  IF p_action = 'S' THEN
      OPEN c_reservations(p_wave_id);
      FETCH c_reservations BULK COLLECT INTO l_rs_tbl;

      print_Debug('Total no of reservation records for all line in current wave '||l_rs_tbl.Count,l_debug);
      IF l_rs_tbl.Count >0 THEN
        FORALL i IN l_rs_tbl.first..l_rs_tbl.last
          INSERT INTO wms_wp_reservations_gtmp
          VALUES l_rs_tbl(i);
      ELSE
        print_Debug('No reservation records exists for any line in current wave ',l_debug);
      END IF;
      CLOSE c_reservations;
  ELSIF p_action = 'R' THEN
      DELETE FROM mtl_reservations
      WHERE demand_source_line_id IN (SELECT DISTINCT source_line_id
                                FROM WMS_WP_WAVE_LINES
                                WHERE wave_header_id = p_wave_id);

      INSERT into mtl_reservations(reservation_id ,
  requirement_date,
  organization_id,
  inventory_item_id,
  demand_source_type_id,
  demand_source_name,
  demand_source_header_id,
  demand_source_line_id,
  demand_source_delivery,
  primary_uom_code,
  primary_uom_id,
  reservation_uom_code ,
  reservation_uom_id,
  reservation_quantity,
  primary_reservation_quantity,
  autodetail_group_id,
  external_source_code,
  external_source_line_id,
  supply_source_type_id,
  supply_source_header_id,
  supply_source_line_id,
  supply_source_line_detail,
  supply_source_name ,
  revision,
  subinventory_code,
  subinventory_id,
  locator_id,
  lot_number ,
  lot_number_id ,
  serial_number,
  serial_number_id  ,
  partial_quantities_allowed ,
  auto_detailed ,
  pick_slip_number ,
  lpn_id ,
  last_update_date,
  last_updated_by,
  creation_date ,
  created_by,
  last_update_login ,
  request_id ,
  program_application_id,
  program_id ,
  program_update_date,
  attribute_category,
  attribute1  ,
  attribute2  ,
  attribute3  ,
  attribute4  ,
  attribute5  ,
  attribute6  ,
  attribute7  ,
  attribute8  ,
  attribute9  ,
  attribute10 ,
  attribute11 ,
  attribute12 ,
  attribute13 ,
  attribute14 ,
  attribute15 ,
  ship_ready_flag,
  n_column1,
  detailed_quantity,
  cost_group_id ,
  container_lpn_id ,
  staged_flag ,
  secondary_detailed_quantity ,
  secondary_reservation_quantity,
  secondary_uom_code,
  secondary_uom_id,
  crossdock_flag,
  crossdock_criteria_id,
  demand_source_line_detail,
  serial_reservation_quantity,
  supply_receipt_date,
  demand_ship_date ,
  exception_code,
  orig_supply_source_type_id,
  orig_supply_source_header_id,
  orig_supply_source_line_id,
  orig_supply_source_line_detail ,
  orig_demand_source_type_id,
  orig_demand_source_header_id,
  orig_demand_source_line_id,
  orig_demand_source_line_detail,
  project_id,
  task_id )
      SELECT *
 FROM wms_wp_reservations_gtmp;

  END IF;

  COMMIT;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
WHEN OTHERS THEN
  print_debug('Error in process_reservation. Action is '||p_action, l_debug);
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END process_reservations;



PROCEDURE spawn_workers
    (p_organization_id    number,
     p_wave_id            number,
     p_mo_header_id       number,
     p_mode               VARCHAR2,
     p_num_workers        number,
     x_return_status  OUT NOCOPY VARCHAR2
    ) IS
   -- l_api_name     VARCHAR2(30) := 'spawn_workers';
    l_msg_count    NUMBER;
    l_msg_data     VARCHAR2(2000);

    l_sub_request  BOOLEAN      := TRUE;
    l_request_id   NUMBER;
    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

    l_phase      VARCHAR2(100);
    l_status     VARCHAR2(100);
    l_dev_phase  VARCHAR2(100);
    l_dev_status VARCHAR2(100);
    l_message    VARCHAR2(500);
     l_mode                   VARCHAR2(4) := null;
    l_request_data           VARCHAR2(100);

  --  l_result     boolean;


    l_dummy             boolean;
    l_completion_status VARCHAR2(100);

  --     l_mode                   VARCHAR2(4) := null;
  --     l_request_data           VARCHAR2(100);
  --     parent_request_id number;


  BEGIN

    l_mode         := NULL;
    l_request_data := FND_CONC_GLOBAL.Request_Data;
    if l_request_data is NULL then


    PRINT_DEBUG('In spawn_workers ',l_debug);
    x_return_status := fnd_api.g_ret_sts_success;

 --   l_sub_request := TRUE;
 --   print_debug ('Sub request is TRUE.', l_debug);

    FOR i IN 1..p_num_workers LOOP -- {
                  print_debug ('Submitting worker #: ' || i, l_debug);

       l_request_id :=
          FND_REQUEST.Submit_Request( application => 'WMS'
                                    , program     => 'WMSWPRBS'
                                  --  , description => ''
                                  --  , start_time  => ''
                                --    , sub_request => l_sub_request
                                    , argument1   => p_organization_id
                                    , argument2   => p_wave_id
                                    , argument3   => p_mo_header_id
                                    , argument4   => p_mode
                                    , argument5   => i     -- Worker ID
                                    );

 COMMIT;
        IF l_request_id = 0 THEN
                 print_debug( 'Request submission failed for worker ' || i, l_debug);
                 RAISE fnd_api.g_exc_unexpected_error;
        ELSE
                 print_debug( 'Request ' || l_request_id ||' submitted successfully' , l_debug);
        END IF;
    END LOOP; --}




  --  IF l_sub_request THEN

          print_debug ('Setting Parent Request to pause' , l_debug);

       FND_CONC_GLOBAL.Set_Req_Globals( Conc_Status  => 'PAUSED'
                                      , Request_Data => p_organization_id   ||':'||
                                                        p_wave_id ||':'||
                                                        p_mo_header_id ||':'||
                                                        p_mode);
  --  END IF;
end if;

  EXCEPTION
    WHEN OTHERS THEN
      print_debug ('Other error: ' || SQLERRM, l_debug);
      x_return_status := fnd_api.g_ret_sts_unexp_error;

END spawn_workers;

PROCEDURE fetch_next_wpr_rec
      (  p_organization_id    IN number
       , p_wave_id            IN number
       , p_mo_header_id       IN NUMBER
       , p_mode               IN VARCHAR2
       , x_inventory_item_id  OUT NOCOPY number
       , x_return_status      OUT NOCOPY VARCHAR2
       ) IS

 --   l_api_name       VARCHAR2(30) := 'fetch_next_wpr_rec';
    l_msg_count      NUMBER;
    l_msg_data       VARCHAR2(2000);

    l_inventory_item_id  number;
    l_return_status  VARCHAR2(1);
    l_row_id         ROWID;
    done             BOOLEAN := FALSE;
    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

    record_locked_exc      EXCEPTION;
    PRAGMA EXCEPTION_INIT  (record_locked_exc, -54);

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    SAVEPOINT fetch_wpr_sp;

    print_debug( 'Entered fetch_next_wpr_rec with parameters: '                       || g_newline ||
                    'p_organization_id => '            || TO_CHAR(p_organization_id)  || g_newline ||
                    'p_wave_id => '                    || TO_CHAR(p_wave_id)          || g_newline ||
                    'p_mo_header_id => '               || TO_CHAR(p_mo_header_id)     || g_newline ||
                    'p_mode => '                       || TO_CHAR(p_mode)
                    ,l_debug);

  IF p_mode = 'RBP-SS' THEN
    begin
          UPDATE wms_pr_workers
          SET processed_flag = 'Y'
          WHERE organization_id  = p_organization_id
          AND batch_id          = p_wave_id
          AND mo_header_id     = p_mo_header_id
          AND processed_flag = 'N'
          AND worker_mode   = 'RBP'
          AND transaction_batch_id IS NULL;

          IF SQL%ROWCOUNT = 0 THEN
           print_debug ('No more records', l_debug);
           x_return_status := 'N';
           RETURN;
          END IF;

          l_inventory_item_id := NULL;
          COMMIT;

    END;
  ELSIF p_mode = 'RBP' THEN
    LOOP --{
       EXIT WHEN done;
       BEGIN
           SELECT rowid INTO l_row_id
           FROM wms_pr_workers
           WHERE organization_id  = p_organization_id
             AND batch_id          = p_wave_id
             AND mo_header_id     = p_mo_header_id
             AND processed_flag = 'N'
             AND worker_mode   = 'RBP'
             AND transaction_batch_id IS NOT NULL
             AND rownum < 2
             FOR UPDATE NOWAIT;



          done := TRUE;

          UPDATE wms_pr_workers
             SET processed_flag = 'Y'
           WHERE rowid = l_row_id
          RETURNING transaction_batch_id  -- inventory_item_id
               INTO l_inventory_item_id;

          COMMIT;


         print_debug
             ( 'Successfully locked a WPR row: ' || g_newline ||
             ' l_inventory_item_id: '            || TO_CHAR(l_inventory_item_id)
             , l_debug
             );

       EXCEPTION
          WHEN record_locked_exc THEN
             print_debug ('Record locked', l_debug);
             done := FALSE;
          WHEN NO_DATA_FOUND THEN
             print_debug ('No more records', l_debug);
             x_return_status := 'N';
             done := TRUE;
          WHEN OTHERS THEN
             print_debug ('Other error: ' || SQLERRM, l_debug);
             done := TRUE;
             RAISE fnd_api.g_exc_unexpected_error;
       END;

    END LOOP; --}
  ELSE
    print_debug ('Invalid Mode ', l_debug);
    RAISE fnd_api.g_exc_unexpected_error;

  END IF;

    IF x_return_status = fnd_api.g_ret_sts_success THEN
       x_inventory_item_id := l_inventory_item_id;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO fetch_wpr_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      print_debug ('Other error: ' || SQLERRM, l_debug);

END fetch_next_wpr_rec;


PROCEDURE allocation (errbuf              OUT   NOCOPY   VARCHAR2,
                      retcode             OUT   NOCOPY   NUMBER,
                      p_organization_id IN NUMBER,
                      p_wave_id        IN NUMBER,
                      p_mo_header_id    IN NUMBER,
                      p_mode            IN VARCHAR2,
                      p_worker_id       IN NUMBER DEFAULT NULL
                     ) IS

l_print_mode VARCHAR2(1); --used for print pick slip which is not required
l_grouping_rule_id NUMBER; -- get its value from shipping parameter however it is used for print pick slip which is not required
l_detail_rec_count NUMBER;
l_mo_line_tbl        inv_move_order_pub.Trolin_Tbl_Type;
l_mo_line            INV_Move_Order_PUB.TROLIN_REC_TYPE;

l_return_status          VARCHAR2(3);
l_msg_count          number;
l_msg_data           varchar2(1000);
l_conc_ret_status    BOOLEAN;
l_error_message      VARCHAR2(2000);

l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);


v_inventory_item_id   NUMBER;

l_line_index NUMBER;
l_start_index     NUMBER;
l_cur_txn_source_line_id NUMBER;
l_quantity                  NUMBER;
l_quantity_delivered NUMBER;
l_cur_ship_set_id NUMBER := NULL;
l_cur_ship_model_id      NUMBER := NULL;
l_cur_txn_source_qty     NUMBER;
l_lower_tolerance NUMBER;
l_transaction_quantity  NUMBER;
l_model_reloop           BOOLEAN := FALSE;
l_set_index       NUMBER;
l_cur_txn_source_req_qty NUMBER;
l_txn_source_line_uom    VARCHAR2(3);
l_new_model_quantity     NUMBER;
l_set_txn_source_line_id NUMBER := NULL;
l_set_new_req_qty        NUMBER;
l_set_txn_source_req_qty NUMBER;
l_new_line_quantity      NUMBER;
l_return_value        BOOLEAN := TRUE;
l_primary_uom VARCHAR2(3);
l_reservable_type          NUMBER;


CURSOR c1 IS
SELECT
attribute1, attribute10, attribute11, attribute12, attribute13,
attribute14, attribute15, attribute2, attribute3, attribute4,
attribute5, attribute6, attribute7, attribute8, attribute9,
attribute_category, created_by, creation_date, date_required, from_locator_id,
from_subinventory_code, from_subinventory_id, header_id, inventory_item_id, last_updated_by,
last_update_date, last_update_login, line_id, line_number, line_status,
lot_number, organization_id, program_application_id, program_id, program_update_date,
project_id, quantity, quantity_delivered, quantity_detailed, reason_id,
reference, reference_id, reference_type_code, request_id, revision,
serial_number_end, serial_number_start, status_date, task_id, to_account_id,
to_locator_id, to_subinventory_code, to_subinventory_id, transaction_header_id, transaction_type_id,
txn_source_id, txn_source_line_id, txn_source_line_detail_id, transaction_source_type_id, primary_quantity,
to_organization_id, pick_strategy_id, put_away_strategy_id, uom_code, unit_number,
ship_to_location_id, from_cost_group_id, to_cost_group_id, lpn_id, to_lpn_id,
pick_methodology_id, container_item_id, carton_grouping_id, FND_API.G_MISS_CHAR, FND_API.G_MISS_CHAR,
FND_API.G_MISS_CHAR, inspection_status, wms_process_flag, pick_slip_number, pick_slip_date,
ship_set_id, ship_model_id, model_quantity, required_quantity, secondary_quantity,
secondary_uom_code, secondary_quantity_detailed, secondary_quantity_delivered, grade_code, secondary_required_quantity
FROM mtl_txn_request_lines mtrl, wms_wp_rules_simulation wwr
WHERE mtrl.TXN_SOURCE_LINE_DETAIL_ID = wwr.delivery_detail_id
AND p_mode = 'RBP'
and wwr.wave_header_id=p_wave_id
AND mtrl.inventory_item_id = v_inventory_item_id

UNION
SELECT
mtrl.attribute1, mtrl.attribute10, mtrl.attribute11, mtrl.attribute12, mtrl.attribute13,
mtrl.attribute14, mtrl.attribute15, mtrl.attribute2, mtrl.attribute3, mtrl.attribute4,
mtrl.attribute5, mtrl.attribute6, mtrl.attribute7, mtrl.attribute8, mtrl.attribute9,
mtrl.attribute_category, mtrl.created_by, mtrl.creation_date, mtrl.date_required, mtrl.from_locator_id,
mtrl.from_subinventory_code, mtrl.from_subinventory_id, mtrl.header_id, mtrl.inventory_item_id, mtrl.last_updated_by,
mtrl.last_update_date, mtrl.last_update_login, mtrl.line_id, mtrl.line_number, mtrl.line_status,
mtrl.lot_number, mtrl.organization_id, mtrl.program_application_id, mtrl.program_id, mtrl.program_update_date,
mtrl.project_id, mtrl.quantity, mtrl.quantity_delivered, mtrl.quantity_detailed, mtrl.reason_id,
mtrl.reference, mtrl.reference_id, mtrl.reference_type_code, mtrl.request_id, mtrl.revision,
mtrl.serial_number_end, mtrl.serial_number_start, mtrl.status_date, mtrl.task_id, mtrl.to_account_id,
mtrl.to_locator_id, mtrl.to_subinventory_code, mtrl.to_subinventory_id, mtrl.transaction_header_id, mtrl.transaction_type_id,
mtrl.txn_source_id, mtrl.txn_source_line_id, mtrl.txn_source_line_detail_id, mtrl.transaction_source_type_id, mtrl.primary_quantity,
mtrl.to_organization_id, mtrl.pick_strategy_id, mtrl.put_away_strategy_id, mtrl.uom_code, mtrl.unit_number,
mtrl.ship_to_location_id, mtrl.from_cost_group_id, mtrl.to_cost_group_id, mtrl.lpn_id, mtrl.to_lpn_id,
mtrl.pick_methodology_id, mtrl.container_item_id, mtrl.carton_grouping_id, FND_API.G_MISS_CHAR, FND_API.G_MISS_CHAR,
FND_API.G_MISS_CHAR, mtrl.inspection_status, mtrl.wms_process_flag, mtrl.pick_slip_number, mtrl.pick_slip_date,
mtrl.ship_set_id, mtrl.ship_model_id, mtrl.model_quantity, mtrl.required_quantity, mtrl.secondary_quantity,
mtrl.secondary_uom_code, mtrl.secondary_quantity_detailed, mtrl.secondary_quantity_delivered, mtrl.grade_code, mtrl.secondary_required_quantity
FROM mtl_txn_request_lines mtrl, wms_wp_rules_simulation wwr, wsh_delivery_details wdd
WHERE mtrl.TXN_SOURCE_LINE_DETAIL_ID = wwr.delivery_detail_id
AND wwr.delivery_detail_id = wdd.delivery_detail_id
AND p_mode = 'RBP-SS'
and wwr.wave_header_id=p_wave_id
AND (wdd.SHIP_SET_ID IS NOT NULL OR Nvl(wdd.SHIP_MODEL_COMPLETE_FLAG, 'N') = 'Y')
ORDER BY line_id
;



BEGIN

print_debug('Enter Allocation ',l_debug);
retcode := 0;


       print_debug( 'Entered Allocation with parameters: '                           || g_newline ||
                    'p_organization_id => '        || TO_CHAR(p_organization_id)     || g_newline ||
                    'p_wave_id => '                || TO_CHAR(p_wave_id)             || g_newline ||
                    'p_mo_header_id => '           || TO_CHAR(p_mo_header_id)        || g_newline ||
                    'p_mode => '                   || TO_CHAR(p_mode)                || g_newline ||
                    'p_worker_id => '              || TO_CHAR(p_worker_id)
                    ,l_debug);

--x_return_status := fnd_api.g_ret_sts_success;

   LOOP --{
       l_return_status := fnd_api.g_ret_sts_success;
       fetch_next_wpr_rec
       ( p_organization_id    => p_organization_id
       , p_wave_id            => p_wave_id
       , p_mo_header_id       => p_mo_header_id
       , p_mode               => p_mode
       , x_inventory_item_id  => v_inventory_item_id
       , x_return_status      => l_return_status
       );

       print_debug('Return status after fetch_next_wpr_rec '||l_return_status, l_debug);
       IF l_return_status = 'N' THEN
          print_debug ( 'No more records in WPR', l_debug );
          EXIT;
       ELSIF l_return_status <> fnd_api.g_ret_sts_success THEN
          print_debug('Error status from fetch_next_wpr_rec: ' || l_return_status, l_debug);
          RAISE fnd_api.g_exc_unexpected_error;
       END IF;

       OPEN c1;
       FETCH c1 BULK COLLECT INTO l_mo_line_tbl;
       print_debug('l_mo_line_tbl.count '||l_mo_line_tbl.Count, l_debug);

       l_line_index      := l_mo_line_tbl.FIRST;
       --FOR i IN l_mo_line_tbl.first..l_mo_line_tbl.last LOOP
       LOOP
        l_mo_line := l_mo_line_tbl(l_line_index);
        IF p_mode = 'RBP-SS' THEN
          IF l_mo_line.ship_set_id IS NOT NULL AND
                    (l_cur_ship_set_id IS NULL OR l_cur_ship_set_id <> l_mo_line.ship_set_id) THEN
            SAVEPOINT SHIPSET;
	          l_cur_ship_set_id := l_mo_line.ship_set_id;
            l_start_index     := l_line_index;
            --l_start_process   := l_processed_row_count;
	          print_debug('Start Shipset :' || l_cur_ship_set_id, l_debug);
	        ELSIF l_cur_ship_set_id IS NOT NULL AND l_mo_line.ship_set_id IS NULL THEN
            print_debug('End of Shipset :' || l_cur_ship_set_id, l_debug);
	          l_cur_ship_set_id := NULL;
          END IF;

          IF l_mo_line.ship_model_id IS NOT NULL AND
	                  (l_cur_ship_model_id IS NULL OR l_cur_ship_model_id <> l_mo_line.ship_model_id) THEN
            SAVEPOINT SHIPMODEL;
	          l_cur_ship_model_id := l_mo_line.ship_model_id;
            l_start_index     := l_line_index;
            --l_start_process   := l_processed_row_count;
	          print_debug('Start Ship Model :' || l_cur_ship_model_id, l_debug);
          ELSIF l_cur_ship_model_id IS NOT NULL AND l_mo_line.ship_model_id IS NULL THEN
            print_debug('End of Ship Model :' || l_cur_ship_model_id, l_debug);
            l_cur_ship_model_id := NULL;
          END IF;

          IF l_cur_txn_source_line_id IS NULL OR l_mo_line.txn_source_line_id <> l_cur_txn_source_line_id THEN
            l_cur_txn_source_line_id := l_mo_line.txn_source_line_id;
            l_cur_txn_source_qty     := 0;
            --l_cur_txn_source_qty2 := 0;
            print_debug('Set Current Txn Src Line:' || l_cur_txn_source_line_id, l_debug);
          END IF;
        END IF;

       BEGIN
         print_debug('Calling process_line for Move Order line id '||l_mo_line.line_id, l_debug);

         IF l_mo_line.quantity > 0 THEN
            SAVEPOINT allocation;

            l_return_value := INV_CACHE.set_item_rec(l_mo_line.organization_id, l_mo_line.inventory_item_id);
            IF NOT l_return_value THEN
              print_debug('Error setting item cache', 'Inv_Pick_Release_PVT.Process_Line');
              raise fnd_api.g_exc_unexpected_error;
            End If;
            l_reservable_type:= INV_CACHE.item_rec.reservable_type;

            IF l_reservable_type = 2 THEN
              print_debug('In wave simulation mode. Update the allocation table with complete quantity fulfilled', l_debug);
              UPDATE wms_wp_rules_simulation
              SET ALLOCATED_QUANTITY = l_mo_line.quantity,
              ALLOCATED_QUANTITY2 = l_mo_line.secondary_quantity
              WHERE DELIVERY_DETAIL_ID = l_mo_line.txn_source_line_detail_id
             and  wave_header_id=p_wave_id;

            ELSE
              INV_Pick_Release_PVT.Process_Line(
	                p_api_version	      => 1.0
	              , p_init_msg_list	    => fnd_api.g_false
	              , p_commit		        => fnd_api.g_false
	              , x_return_status     => l_return_status
   	            , x_msg_count         => l_msg_count
   	            , x_msg_data          => l_msg_data
   	            , p_mo_line_rec       => l_mo_line
	              , p_grouping_rule_id	=> g_PICK_GROUPING_RULE_ID -- set in initialize
	           -- , p_allow_partial_pick => l_allow_partial_pick   -- default value or TRUE if not passed
	              , p_print_mode        => l_print_mode            -- pass null value since for simulation mode it is not required
	              , x_detail_rec_count	=> l_detail_rec_count
                , p_plan_tasks        => TRUE
                , p_wave_simulation_mode  => 'Y'
                );
              print_debug('Allocation: return status after INV_Pick_Release_PVT.Process_Line for line_id '||l_mo_line.line_id||': '||l_return_status, l_debug);
              /*IF l_return_status <> fnd_api.g_ret_sts_success THEN
                  ROLLBACK;
              END IF;
              */
            END IF;
          ELSE
            print_debug('Requested quantity is zero', l_debug);
          END IF;

       EXCEPTION
       WHEN others THEN
          print_debug('Error in allocation for line_id '||l_mo_line.line_id, l_debug);

          ROLLBACK TO allocation;
       END;

       IF p_mode = 'RBP' then
        COMMIT;
       END IF;

       IF p_MODE ='RBP-SS' THEN
          l_quantity              := l_mo_line.quantity;
          l_quantity_delivered    := l_mo_line.quantity_delivered;
          l_lower_tolerance       := inv_pick_release_pvt.g_min_tolerance;
          l_transaction_quantity  := nvl(l_mo_line.quantity_detailed, 0) - nvl(l_mo_line.quantity_delivered, 0);

          IF (l_transaction_quantity < (l_quantity - NVL(l_quantity_delivered,0) - l_lower_tolerance)) THEN
               IF l_cur_ship_set_id IS NOT NULL THEN
                    ROLLBACK to SHIPSET;
                    l_set_index   := l_start_index;
                    --l_set_process := l_start_process;
                    --loop through all move order lines for this ship set
                    LOOP
                      l_mo_line := l_mo_line_tbl(l_set_index);
                      update mtl_txn_request_lines
                      set quantity                = 0,
                      quantity_detailed           = 0,
                      secondary_quantity          = decode(secondary_quantity, fnd_api.g_miss_num, NULL, 0),
                      secondary_quantity_detailed = decode(secondary_quantity_detailed, fnd_api.g_miss_num, NULL, 0),
                      line_status                 = 5,
                      status_date                 = sysdate
                      where line_id = l_mo_line.line_id;

                      EXIT WHEN l_mo_line_tbl.LAST = l_set_index;
                      l_set_index := l_mo_line_tbl.NEXT(l_set_index);
                      if nvl(l_mo_line_tbl(l_set_index).ship_set_id, -1) <> l_cur_ship_set_id then
                          l_set_index := l_mo_line_tbl.PRIOR(l_set_index);
                          EXIT;
                      end if;

                      --If next line is for same ship set, update output table
                      --l_set_process := l_set_process + 1;
                    END loop;

                    l_line_index          := l_set_index;
                    l_cur_ship_set_id     := NULL;
                    --l_processed_row_count := l_set_process;
                    l_detail_rec_count    := 0;
                    print_debug('Finished processing all lines in shipset', l_debug);

               ELSIF l_cur_ship_model_id IS NOT NULL THEN
                    ROLLBACK to SHIPMODEL;
                    l_set_index   := l_start_index;
                    --l_set_process := l_start_process;
                    print_debug('OE Line: ' || l_cur_txn_source_line_id, l_debug);

                    BEGIN
                      SELECT ordered_quantity, order_quantity_uom
                      INTO l_cur_txn_source_req_qty, l_txn_source_line_uom
                      FROM OE_ORDER_LINES_ALL
                      WHERE line_id = l_cur_txn_source_line_id;
                    EXCEPTION
                      WHEN NO_DATA_FOUND then
                          print_debug('No Order Line Quantity found', l_debug);
                          ROLLBACK;
                          RAISE fnd_api.g_exc_unexpected_error;
                    END;

                    BEGIN
                       SELECT primary_uom_code
                       INTO l_primary_uom
                       FROM mtl_system_items
                       WHERE organization_id = l_mo_line.organization_id
                       AND inventory_item_id = l_mo_line.inventory_item_id;
                    EXCEPTION
                       WHEN no_data_found THEN
                          ROLLBACK;
                          print_debug('No Item Info found', l_debug);
                          RAISE fnd_api.g_exc_unexpected_error;
                    END;

                    IF l_txn_source_line_uom <> l_primary_uom THEN
                          l_cur_txn_source_req_qty := inv_convert.inv_um_convert(l_mo_line.inventory_item_id,
                                                                     NULL,
                                                                     l_cur_txn_source_req_qty,
                                                                     l_txn_source_line_uom,
                                                                     l_primary_uom,
                                                                     NULL,
                                                                     NULL);
                    END IF;

                    l_new_model_quantity := floor(l_cur_txn_source_qty * l_mo_line.model_quantity
                                                  / l_cur_txn_source_req_qty);
                    print_debug('New model qty ' || l_new_model_quantity, l_debug);

                    LOOP
                      l_mo_line := l_mo_line_tbl(l_set_index);
                      print_debug('SHIPMODEL-Current mo line:' || l_mo_line.line_id, l_debug);

                      IF l_set_txn_source_line_Id IS NULL OR
                                    l_set_txn_source_line_id <> l_mo_line.txn_source_line_id THEN
                          l_set_txn_source_line_id := l_mo_line.txn_source_line_id;
                          print_debug('OE Line: ' || l_set_txn_source_line_id, l_debug);

                          IF l_set_txn_source_line_id = l_cur_txn_source_line_id Then
                              l_set_txn_source_req_qty := l_cur_txn_source_req_qty;
                          ELSE
                              BEGIN
                                SELECT ordered_quantity, order_quantity_uom
                                INTO l_set_txn_source_req_qty, l_txn_source_line_uom
                                FROM OE_ORDER_LINES_ALL
                                WHERE line_id = l_set_txn_source_line_id;
                              EXCEPTION
                                WHEN NO_DATA_FOUND then
                                  print_debug('No Order Line Quantity found', l_debug);
                                  ROLLBACK;
                                  RAISE fnd_api.g_exc_unexpected_error;
                              END;

                              if l_txn_source_line_uom <> l_primary_uom then
                                  l_cur_txn_source_req_qty := inv_convert.inv_um_convert(l_mo_line.inventory_item_id,
                                                                           NULL,
                                                                           l_cur_txn_source_req_qty,
                                                                           l_txn_source_line_uom,
                                                                           l_primary_uom,
                                                                           NULL,
                                                                           NULL);
                              end if;
                          END IF;

                          l_set_new_req_qty := l_set_txn_source_req_qty * l_new_model_quantity
                                                / l_mo_line.model_quantity;

                          print_debug('New req qty: ' || l_set_new_req_qty, l_debug);
                      END IF;

                      -- set new move order line quantity
                      IF l_set_new_req_qty >= l_mo_line.quantity THEN
                          l_new_line_quantity := l_mo_line.quantity;
                      ELSE
                          l_new_line_quantity := l_set_new_req_qty;
                          print_debug('New line qty: ' || l_new_line_quantity, l_debug);
                          l_return_value := INV_CACHE.set_wdd_rec(l_mo_line.line_id);
                          If NOT l_return_value Then
                              print_debug('Error setting cache for delivery line',l_debug);
                              RAISE fnd_api.g_exc_unexpected_error;
                          End If;
                      END IF;

                      l_set_new_req_qty := l_set_new_req_qty - l_new_line_quantity;

                      -- Update mo line with new quantity and model quantity;
                      --If mo line quantity is 0, close the move order line
                      IF l_new_line_quantity = 0 THEN
                          update mtl_txn_request_lines
                          set quantity          = 0,
                          quantity_detailed = 0,
                          line_status       = 5,
                          status_date       = sysdate,
                          model_quantity    = l_new_model_quantity
                          where line_id = l_mo_line.line_id;

                          l_mo_line_tbl(l_set_index).quantity_detailed := 0;
                          l_mo_line_tbl(l_set_index).line_status := 5;
                      ELSE
                          update mtl_txn_request_lines
                          set quantity          = l_new_line_quantity,
                          quantity_detailed = NULL,
                          model_quantity    = l_new_model_quantity
                          where line_id = l_mo_line.line_id;

                          l_mo_line_tbl(l_set_index).quantity_detailed := NULL;
                      END IF;

                      l_mo_line_tbl(l_set_index).quantity := l_new_line_quantity;

                      EXIT WHEN l_mo_line_tbl.LAST = l_set_index;
                      l_set_index := l_mo_line_tbl.NEXT(l_set_index);
                      if nvl(l_mo_line_tbl(l_set_index).ship_model_id, -99) <> l_cur_ship_model_id then
                          l_set_index := l_mo_line_tbl.PRIOR(l_set_index);
                          EXIT;
                      end if;

                    END LOOP;

                    l_cur_ship_model_id := NULL;
                    l_cur_txn_source_qty := 0;
                    --l_cur_txn_source_qty2    := 0;
                    l_cur_txn_source_line_id := NULL;

                    IF l_new_model_quantity = 0 THEN
                          l_line_index          := l_set_index;
                          --l_processed_row_count := l_set_process;
                          l_detail_rec_count    := 0;

                          print_debug('Backordered all lines with this Ship Model Id', l_debug);

                    ELSE

                          l_line_index          := l_start_index;
                          --l_processed_row_count := l_start_process;
                          l_model_reloop        := TRUE;
                    END IF;

               END IF;
          END if;
       END IF;

       EXIT WHEN l_line_index = l_mo_line_tbl.last AND(l_model_reloop <> TRUE);
       IF (l_model_reloop <> TRUE) THEN
            l_line_index := l_mo_line_tbl.NEXT(l_line_index);
       ELSE
            --Don't increment the line index and turn off the reloop variable
            l_model_reloop := FALSE;
       END IF;

       END LOOP;
       CLOSE c1;
   END loop;

   COMMIT;

EXCEPTION
  WHEN OTHERS THEN
      l_error_message := SQLERRM;
      print_debug ('Error in allocation '||l_error_message, l_debug);
      l_conc_ret_status := fnd_concurrent.set_completion_status('ERROR', l_error_message);
      retcode := 2;
      errbuf  := l_error_message;

END allocation;
PROCEDURE init_allocation(p_organization_id  number,
                           p_wave_id      number,
                           p_mo_header_id number,
                           x_return_status  out nocopy varchar2
                           )IS
 l_num_workers   NUMBER;
 l_tot_worker_records NUMBER := 0;
 l_tot_smc_records NUMBER;
 l_tbl_count number;
 --l_select_clause  VARCHAR2(1000);
 --l_from_clause   VARCHAR2(1000);
 --l_where_clause   VARCHAR2(1000);
 --l_groupby_clause VARCHAR2(1000);
 --l_final_query varchar2(1000);

 CURSOR c1 IS
     SELECT WWL.ORGANIZATION_ID, WWL.INVENTORY_ITEM_ID, COUNT(*)
     FROM wms_wp_wave_lines wwl
     WHERE organization_id = p_organization_id
     and wave_header_id = p_wave_id
     GROUP BY WWL.ORGANIZATION_ID, WWL.INVENTORY_ITEM_ID;

 CURSOR c2 IS
     SELECT Wdd.ORGANIZATION_ID, DECODE(Wdd.SHIP_SET_ID,NULL,DECODE(Wdd.SHIP_MODEL_COMPLETE_FLAG,'Y',NULL,Wdd.INVENTORY_ITEM_ID),NULL), COUNT(*)
     FROM wms_wp_rules_simulation wwl, wsh_delivery_details wdd
     WHERE wdd.organization_id = p_organization_id
     AND wwl.delivery_detail_id = wdd.delivery_detail_id
     and wwl.wave_header_id=p_wave_id
     GROUP BY Wdd.ORGANIZATION_ID, DECODE(Wdd.SHIP_SET_ID,NULL,DECODE(Wdd.SHIP_MODEL_COMPLETE_FLAG,'Y',NULL,Wdd.INVENTORY_ITEM_ID),NULL);

 --TYPE l_ref_cur IS REF CURSOR;
 --c1 l_ref_cur;
/* TYPE cRec IS RECORD (organization_id NUMBER,
                          item NUMBER,
                          total_count number
                          ); */

-- TYPE cTblTyp IS TABLE OF cRec INDEX BY BINARY_INTEGER;
 --l_cTbl cTblTyp;

 TYPE cTblorg IS TABLE OF number INDEX BY BINARY_INTEGER;
 	 TYPE cTblitem IS TABLE OF number INDEX BY BINARY_INTEGER;
 	 	 TYPE cTblcount IS TABLE OF number INDEX BY BINARY_INTEGER;

 	 	 l_cTblorg cTblorg;
 	 	 	l_cTblitem cTblitem;
 	 	 	l_cTblcount cTblcount;

 l_msg_data  VARCHAR2(1000);
 l_retcode NUMBER;

 l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
 begin
  print_debug('In init_allocation',l_debug);
  x_return_status := FND_API.G_RET_STS_SUCCESS;


   IF g_enforce_ship_set_and_smc = 'N' THEN
      OPEN c1;
      FETCH c1 BULK COLLECT INTO l_cTblorg,l_cTblitem,l_cTblcount;
   ELSE
      OPEN c2;
      FETCH c2 BULK COLLECT INTO l_cTblorg,l_cTblitem,l_cTblcount;
   END IF;

--l_tbl_count := l_cTbl.count;

 --
  --FORall i IN l_cTbl.first..l_cTbl.last dbchange3
 FORALL i IN l_cTblorg.first..l_cTblorg.last
   INSERT INTO wms_pr_workers
           (batch_id,
            worker_mode,
            processed_flag,
            organization_id,
            mo_header_id,
            transaction_batch_id,
            detailed_count
           )
   VALUES (p_wave_id,
           'RBP',
           'N',
           l_cTblorg(i),
           p_mo_header_id,
           l_cTblitem(i),
           l_cTblcount(i)
          );

         -- l_tot_worker_records := l_tot_worker_records + SQL%ROWCOUNT;


    l_tot_worker_records := SQL%ROWCOUNT;
    print_debug(l_tot_worker_records ||' no of rows inserted into wms_pr_workers', l_debug);

  SELECT Count(*) INTO l_tot_smc_records
  FROM wms_pr_workers
  WHERE organization_id=p_organization_id
  AND batch_id=p_wave_id
  and mo_header_id=p_mo_header_id
  AND worker_mode='RBP'
  AND processed_flag='N'
  AND transaction_batch_id IS NULL;

  IF l_tot_smc_records > 1 THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RETURN;
  ELSIF l_tot_smc_records = 1 THEN
  --SS/SMC batch, lock record and call allocation directly in parent thread

           allocation(errbuf            => l_msg_data,
                      retcode           => l_retcode,
                      p_organization_id => p_organization_id,
                      p_wave_id         => p_wave_id,
                      p_mo_header_id    => p_mo_header_id,
                      p_mode            => 'RBP-SS'
                     );

           print_debug('return status after init_allocation '|| l_retcode, l_debug);
           IF l_retcode <> 0 THEN
              RAISE fnd_api.g_exc_unexpected_error;
           END IF;

  END IF;

    l_tot_worker_records := l_tot_worker_records - l_tot_smc_records;

    l_num_workers := NVL(fnd_profile.value('WSH_PR_NUM_WORKERS'),3);
    IF l_num_workers < 2 THEN
      l_num_workers := 3;
    END IF;

    l_num_workers := LEAST(l_tot_worker_records, l_num_workers);

    spawn_workers(p_organization_id => p_organization_id,
                  p_wave_id         => p_wave_id,
                  p_mo_header_id    => p_mo_header_id,
                  p_mode            => 'RBP',
                  p_num_workers     => l_num_workers,
                  x_return_status   => x_return_status);

    print_debug('return status after spawn_workers '||x_return_status, l_debug);
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

  --  COMMIT;
 EXCEPTION
  WHEN OTHERS THEN
    print_debug ('Error in init_allocation '||SQLERRM, l_debug);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

 END init_allocation;



PROCEDURE post_allocation_processing
            (P_ORGANIZATION_ID      NUMBER,
             p_move_order_Number    NUMBER,
             x_request_id       out nocopy NUMBER,
             x_return_status    OUT NOCOPY varchar2) IS
--PROCEDURE post_allocation_processing(P_ORGANIZATION_ID IN NUMBER, p_move_order_Number NUMBER) IS
    l_phase      VARCHAR2(100);
    l_status     VARCHAR2(100);
    l_dev_phase  VARCHAR2(100);
    l_dev_status VARCHAR2(100);
    l_message    VARCHAR2(500);
    l_batch_id   varchar2(30);
    l_result     boolean;

    l_request_id        NUMBER;
    l_dummy             boolean;
    l_completion_status VARCHAR2(100);

       l_mode                   VARCHAR2(4) := null;
       l_request_data           VARCHAR2(100);
       parent_request_id number;
       l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);


  BEGIN

   x_return_status := fnd_api.g_ret_sts_success;

    l_request_id := FND_REQUEST.SUBMIT_REQUEST(application => 'WMS',
                                               program     => 'WMSPALOC',
                                               description => 'WMS post-allocation processing',
                                               start_time  => NULL,
                                            --   sub_request => TRUE,
                                               argument1   => p_move_order_Number,
                                               argument2   => P_ORGANIZATION_ID,
                                               argument3   => 1,
                                               argument4   => 2,
                                               argument5   => 1,
                                               argument6   => 1,
                                               argument7   => 2,
                                               argument8   => 2,
                                               argument9   => 1,
                                               argument10  => 2,
                                               argument11  => 'Y');

                    -- argument3 operation_plan     1
                    -- argument5 consolidate tasks  1
                    -- argument6 assign task type   1
                    -- argument9 plan tasks         1

     x_request_id := l_request_id;

                     commit;


     l_dummy := FND_CONCURRENT.WAIT_FOR_REQUEST(request_id => l_request_id,
                interval => 5,
  --              max_wait => 120,
                phase => l_phase,
                status => l_status,
                dev_phase => l_dev_phase,
                dev_status => l_dev_status,
                message => l_message);




    l_dummy := FND_CONCURRENT.GET_REQUEST_STATUS(l_request_id,
                                                 '',
                                                 '',
                                                 l_phase,
                                                 l_status,
                                                 l_dev_phase,
                                                 l_dev_status,
                                                 l_message);

    print_debug('Rule Based simulation: Waiting for Post Allocation request '||l_request_id, l_debug);
    print_debug('l_phase '||l_phase||' l_status '||l_status||' l_dev_phase '||l_dev_phase||' l_dev_status '||l_dev_status,l_debug);

    IF l_dev_status = 'WARNING' THEN
      l_completion_status := 'WARNING';
      x_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;
    ELSIF l_dev_status <> 'NORMAL' THEN
      l_completion_status := 'ERROR';
      x_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;
    else
      l_completion_status := 'NORMAL';
      l_dummy             := FND_CONCURRENT.SET_COMPLETION_STATUS(l_completion_status, '');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      print_debug('Error in post_allocation_processing', l_debug);
      x_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;
  END post_allocation_processing;


  PROCEDURE fulfillment_labor_planning(p_planning_criteria_id in number,
                                     p_wave_header_id       in number,
                                     p_move_order_hrd_id    in number,
                                     P_ORGANIZATION_ID      in number,
                                     x_return_status        out nocopy varchar2) IS

  CURSOR c1 IS
    select mtrl.TXN_SOURCE_LINE_DETAIL_ID delivery_detail_id,
           sum(transaction_quantity) l_quantity,
           sum(secondary_transaction_quantity) l_quantity2
      from wms_wp_rules_simulation   wwr,
           mtl_material_transactions_temp mmtt,
           mtl_txn_request_lines          mtrl
     where wwr.delivery_detail_id = mtrl.TXN_SOURCE_LINE_DETAIL_ID
     and wwr.wave_header_id=p_wave_header_id
       AND mtrl.line_Id = mmtt.move_order_line_id
       and (mmtt.parent_line_id IS NULL OR
           mmtt.transaction_temp_id <> mmtt.parent_line_id)
     group by mtrl.TXN_SOURCE_LINE_DETAIL_ID;

  TYPE wp_rules_rec IS RECORD(
    delivery_detail_id number,
    allocated_qty      number,
    allocated_qty2     number);

  TYPE wp_rules_tbl IS TABLE OF wp_rules_rec INDEX BY BINARY_INTEGER;

  x_wp_rules_tbl wp_rules_tbl;

  l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

  l_enable_labor_planning varchar2(1);
  v_labor_count           number;

BEGIN

  print_debug('In fulfillment_labor_planning ', l_debug);
  x_return_status := fnd_api.g_ret_sts_success;

  open c1;

  fetch c1 bulk collect
    into x_wp_rules_tbl;
  print_debug('x_wp_rules_tbl.count: ' || x_wp_rules_tbl.count, l_debug);

  CLOSE c1;

  /*  FOR i IN x_wp_rules_tbl.first..x_wp_rules_tbl.last LOOP
    print_debug('i is '||i,l_debug);
      print_debug('delivery_detail_id '||x_wp_rules_tbl(i).delivery_detail_id||'  l_quantity '||x_wp_rules_tbl(i).allocated_qty, l_debug);
    END LOOP;
  */

 -- forall i in indices of x_wp_rules_tbl
 if x_wp_rules_tbl.count >0 then


 for i in x_wp_rules_tbl.FIRST .. x_wp_rules_tbl.LAST LOOP

 	begin
    update wms_wp_rules_simulation
       set allocated_quantity  = x_wp_rules_tbl(i).allocated_qty,
           allocated_quantity2 = x_wp_rules_tbl(i).allocated_qty2
     where delivery_detail_id = x_wp_rules_tbl(i).delivery_detail_id
     and wave_header_id=p_wave_header_id;

     EXCEPTION
     	when others then
     		null;
     	end;
   end loop;

end if;


  print_debug('In fulfillment_labor_planning 4', l_debug);

  ----call labor planning api-----

  select enable_labor_planning
    into l_enable_labor_planning
    from wms_wp_planning_Criteria_vl
   where planning_criteria_id = p_planning_criteria_id;

  print_debug('Checking if Labor Planning Set up or Department Setup  is done ',
              l_debug);
  select count(1)
    into v_labor_count
    from wms_wp_labor_planning
   where planning_Criteria_id = p_planning_Criteria_id;

  if v_labor_count > 0 and l_enable_labor_planning = 'Y' then

    savepoint labor_planning_sp;

    print_debug('Call Labor Planning API', l_debug);
    rules_labor_planning(p_planning_criteria_id,
                         p_wave_header_id,
                         p_move_order_hrd_id,
                         P_ORGANIZATION_ID,
                         x_return_status);

    if x_return_status <> 'S' then

      rollback to labor_planning_sp;
    else
      commit;
    end if;

  else

    print_debug('Setup is not available for Labor Planning. Please check the Labor Planning  setup',
                l_debug);
    delete from wms_wp_labor_statistics
     where wave_header_id = p_wave_header_id;
    commit;
  end if;



EXCEPTION
  WHEN No_Data_Found THEN
    print_debug('No Data Found Exception in fulfillment_labor_planning',
                l_debug);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  WHEN OTHERS THEN
    print_debug('Other Exception in fulfillment_labor_planning', l_debug);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END fulfillment_labor_planning;




PROCEDURE clean_up(p_organization_id NUMBER, p_wave_id NUMBER, p_mo_header_id NUMBER, x_return_status OUT NOCOPY varchar2) IS


 /* TYPE delMMTTRec IS RECORD
        (transaction_temp_id  NUMBER,
         transaction_header_id  NUMBER,
         ITEM_LOT_CONTROL_CODE  NUMBER,
         ITEM_SERIAL_CONTROL_CODE number
        );

  TYPE delMMTTTab IS TABLE OF delMMTTRec INDEX BY BINARY_INTEGER;
  l_del_mmtt delMMTTTab; */

TYPE delMMTTtempid IS TABLE OF number INDEX BY BINARY_INTEGER;
TYPE delMMTThdrid IS TABLE OF number INDEX BY BINARY_INTEGER;
	TYPE delMMTTlotctrl IS TABLE OF number INDEX BY BINARY_INTEGER;
		TYPE delMMTTserialctrl IS TABLE OF number INDEX BY BINARY_INTEGER;


l_delMMTTtempid delMMTTtempid;
l_delMMTThdrid delMMTThdrid;
l_delMMTTlotctrl delMMTTlotctrl;
l_delMMTTserialctrl delMMTTserialctrl;

  CURSOR c_del_mmtt IS
  SELECT DISTINCT mmtt1.transaction_temp_id, mmtt1.transaction_header_id, mmtt1.ITEM_LOT_CONTROL_CODE, mmtt1.ITEM_SERIAL_CONTROL_CODE
  FROM mtl_material_transactions_temp mmtt1, mtl_material_transactions_temp mmtt2
  WHERE mmtt2.move_order_header_id=p_mo_header_id
    AND (mmtt1.transaction_temp_id=mmtt2.transaction_temp_id OR mmtt1.transaction_temp_id=mmtt2.parent_line_id);


  l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  l_tbl_count number;
  l_row_count NUMBER := 0;


  BEGIN
  x_return_status := fnd_api.g_ret_sts_success;


   BEGIN
    IF g_update_wdd = 'Y' THEN
      UPDATE wsh_delivery_details
      SET move_order_line_id=NULL
      WHERE delivery_detail_id IN (SELECT delivery_Detail_id
                                   FROM wms_wp_rules_simulation where wave_header_id=p_wave_id);

      print_debug(SQL%ROWCOUNT || ' Rows updated from WDD ',l_debug);
      g_update_wdd := 'N';
      COMMIT;
    END IF;
    EXCEPTION
      WHEN OTHERS THEN
        print_debug('Could not update WDD', l_debug);
    END;


   DELETE FROM wms_pr_workers
   WHERE batch_id = p_wave_id
   AND worker_mode = 'RBP'
   AND organization_id = p_organization_id
   AND mo_header_id = p_mo_header_id;

   print_debug(SQL%ROWCOUNT || ' Rows deleted from wms_pr_workers ',l_debug);


   DELETE FROM wms_wp_reservations_gtmp;


 open c_del_mmtt;
 FETCH c_del_mmtt BULK COLLECT INTO l_delMMTTtempid,l_delMMTThdrid,l_delMMTTlotctrl,l_delMMTTserialctrl;

 print_debug(' Number of rows in l_del_mmtt cursor is '||l_delMMTTtempid.count,l_debug);

l_tbl_count := l_delMMTTtempid.Count;
 IF l_delMMTTtempid.Count >0 THEN
 FORALL i IN l_delMMTTtempid.FIRST ..l_delMMTTtempid.LAST
 --FOR i IN 1 ..l_tbl_count LOOP dbchange4
    UPDATE mtl_serial_numbers
    SET group_mark_id = NULL, line_mark_id = NULL, lot_line_mark_id = NULL
    WHERE l_delMMTTserialctrl(i) IN (2, 5)
      AND ((l_delMMTTlotctrl(i) <> 2 AND (group_mark_id = l_delMMTTtempid(i) OR group_mark_id = l_delMMTThdrid(i)))
            OR (l_delMMTTlotctrl(i) = 2
                AND (group_mark_id  IN (SELECT serial_transaction_temp_id
                                       FROM mtl_transaction_lots_temp
                                       WHERE transaction_temp_id = l_delMMTTtempid(i))
                     OR group_mark_id = l_delMMTThdrid(i))));


    print_debug(SQL%ROWCOUNT || ' Rows updated from MSN ',l_debug);


                  --dbchange5

 --FORALL i IN 1 ..l_tbl_count

FORALL i IN l_delMMTTtempid.FIRST ..l_delMMTTtempid.LAST
    DELETE FROM mtl_serial_numbers_temp
    WHERE  l_delMMTTserialctrl(i) IN (2, 5)
      AND  ((l_delMMTTlotctrl(i) <> 2
                AND  transaction_temp_id = l_delMMTTtempid(i))
            OR (l_delMMTTlotctrl(i) = 2
                AND transaction_temp_id IN (SELECT SERIAL_TRANSACTION_TEMP_ID
                                            FROM mtl_transaction_lots_temp
                                            WHERE transaction_temp_id = l_delMMTTtempid(i))));

  print_debug(SQL%ROWCOUNT|| ' Rows deleted from MSNT ',l_debug);


   --FORALL i IN 1 ..l_tbl_count   dbchange6

FORALL i IN l_delMMTTtempid.FIRST ..l_delMMTTtempid.LAST
    DELETE FROM mtl_transaction_lots_temp
    WHERE  l_delMMTTlotctrl(i) = 2
      AND  transaction_temp_id = l_delMMTTtempid(i);

  print_debug(SQL%ROWCOUNT || ' Rows deleted from MTLT ',l_debug);

 --FORALL i IN 1 ..l_tbl_count  dbchange7

FORALL i IN l_delMMTTtempid.FIRST ..l_delMMTTtempid.LAST
    DELETE FROM mtl_material_transactions_temp
    WHERE transaction_temp_id = l_delMMTTtempid(i);



  print_debug(SQL%ROWCOUNT || ' Rows deleted from MMTT ',l_debug);

 END IF;

  DELETE FROM mtl_txn_request_Lines WHERE header_id=p_mo_header_id;

  print_debug(SQL%ROWCOUNT || ' Rows deleted from MTRL ', l_debug);

  DELETE FROM mtl_txn_request_headers WHERE header_id=p_mo_header_id;

  print_debug(SQL%ROWCOUNT || ' Rows deleted from MTRH ', l_debug);

  process_reservations(p_wave_id =>  p_wave_id
                  , p_action      =>  'R'
                  , x_return_status  => x_return_status
                  );


--delete from wms_wp_rules_simulation;
  COMMIT;

 EXCEPTION
  WHEN OTHERS THEN
    print_debug('Error in clean_up', l_debug);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

 END clean_up;


  PROCEDURE rule_based_simulation(p_planning_criteria_id in number,
                                p_wave_id              in number,
                                p_organization_id      IN number) IS

  l_mo_header_id      number;
  l_debug             NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  l_phase             VARCHAR2(100);
  l_status            VARCHAR2(100);
  l_dev_phase         VARCHAR2(100);
  l_dev_status        VARCHAR2(100);
  l_message           VARCHAR2(500);
  l_result            boolean;
  l_request_number    number;
  l_request_id        number;
  l_request_data      varchar2(30);
  l_completion_status varchar2(30);
  l_dummy             BOOLEAN;
  l_return_status     VARCHAR2(3);
  l_num_workers       NUMBER;

  cleanup_not_require_exception  EXCEPTION;

BEGIN
  print_debug('In Rule Based simulation ', l_debug);
  l_return_status := FND_API.G_RET_STS_SUCCESS;

  initialize(p_wave_id, p_organization_id, l_return_status);
  print_debug('return status after initialize ' ||
              l_return_status,
              l_debug);
  IF l_return_status <> fnd_api.g_ret_sts_success THEN
    RAISE cleanup_not_require_exception;
  END IF;

  print_debug('Rule Based simulation: calling create_move_order', l_debug);
    create_move_order(p_organization_id, p_wave_id, l_mo_header_id, l_request_number, l_return_status);
  print_debug('return status after create_move_order ' ||
              l_return_status,
              l_debug);
  IF l_return_status <> fnd_api.g_ret_sts_success THEN
    RAISE cleanup_not_require_exception;
  END IF;


  process_reservations(p_wave_id       => p_wave_id,
                       p_action        => 'S',
                       x_return_status => l_return_status);
  print_debug('return status after process_reservations ' ||
              l_return_status,
              l_debug);
  IF l_return_status <> fnd_api.g_ret_sts_success THEN
    RAISE fnd_api.g_exc_unexpected_error;
  END IF;


  init_allocation(p_organization_id,
                  p_wave_id,
                  l_mo_header_id,
                  l_return_status);

    print_debug('return status after init_allocation '|| l_return_status, l_debug);
    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;


  print_debug('Rule Based simulation: calling post_allocation_processing',
              l_debug);

  post_allocation_processing(P_ORGANIZATION_ID,
                             l_request_number,
                             l_request_id,
                             l_return_status);
  --post_allocation_processing(P_ORGANIZATION_ID, l_request_number);
  print_debug('Rule Based simulation: return status after post_allocation_processing ' ||
              l_return_status,
              l_debug);
  IF l_return_status <> fnd_api.g_ret_sts_success THEN
    RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  BEGIN
    print_debug('Update WDD', l_debug);
    UPDATE wsh_delivery_details
    SET move_order_line_id=NULL
    WHERE delivery_detail_id IN (SELECT delivery_Detail_id
                                 FROM wms_wp_rules_simulation where wave_header_id=p_wave_id);

    g_update_wdd := 'N';
  EXCEPTION
    WHEN OTHERS THEN
      print_debug('Could not update WDD. need to update it again during clean_up', l_debug);
  END;

  print_debug('Rule Based simulation: calling fulfillment_labor_planning',
              l_debug);
  fulfillment_labor_planning(p_planning_criteria_id,
                             p_wave_id,
                             l_mo_header_id,
                             p_organization_id,
                             l_return_status);
  print_debug('Rule Based simulation: return status after fulfillment_labor_planning ' ||
              l_return_status,
              l_debug);
  IF l_return_status <> fnd_api.g_ret_sts_success THEN
    RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  print_debug('Rule Based simulation: calling clean up', l_debug);
  clean_up(p_organization_id, p_wave_id, l_mo_header_id, l_return_status);
  print_debug('Rule Based simulation: return status after clean_up ' ||
              l_return_status,
              l_debug);
  IF l_return_status <> fnd_api.g_ret_sts_success THEN
    RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  print_debug('Rule Based simulation: exiting', l_debug);

  EXCEPTION
    WHEN cleanup_not_require_exception THEN
      print_debug('Error in rule_based_simulation, No need to call clean_up', l_debug);
      RAISE fnd_api.g_exc_unexpected_error;

    WHEN OTHERS THEN
      print_debug('Error in rule_based_simulation. Need to call clean_up', l_debug);
      clean_up(p_organization_id, p_wave_id, l_mo_header_id, l_return_status);
      RAISE fnd_api.g_exc_unexpected_error;
  END rule_based_simulation;



 procedure Plan_Wave(p_wave_header_id       in number,
                    p_planning_criteria_id in number,
                    x_return_status        OUT NOCOPY varchar2) is

  l_dummy             boolean;
  l_completion_status VARCHAR2(100);

  cursor c_item is
    SELECT DISTINCT inventory_item_id, organization_id
      FROM wms_wp_wave_lines
     WHERE wave_header_id = p_wave_header_id
       and nvl(remove_from_wave_flag, 'N') <> 'Y';

  L_ORG_ID  NUMBER;
  L_ITEM_ID NUMBER;
  l_tbl_count number;

  cursor c_plan_lines is
    select wwl.source_header_number,
           wwl.delivery_detail_id,
           wwl.organization_id,
           wwl.inventory_item_id,
           wwl.requested_quantity,
           wwl.requested_quantity_uom,
           wwh.planning_criteria_id,
           wdd.ship_set_id,
           wwl.source_line_id,
           wdd.top_model_line_id,
           --  wdd.source_header_id,
           inv_salesorder.get_salesorder_for_oeheader(wdd.source_header_id) demand_source_header_id,
           --   wdd.source_header_type_id,
           decode(wdd.source_document_type_id, 10, 8, 2) demand_source_type_id,
           wwl.wave_line_id
      from wms_wp_wave_headers_vl      wwh,
           wms_wp_wave_lines           wwl,
           wms_wp_planning_criteria_vl wwp,
           wsh_delivery_details        wdd
     where wwh.wave_header_id = p_wave_header_id
       and wwl.organization_id = l_org_id
       and wwl.inventory_item_id = l_item_id
       and wwp.planning_criteria_id = p_planning_criteria_id
       and wwh.planning_criteria_id = wwp.planning_criteria_id
       and wwh.wave_header_id = wwl.wave_header_id
       and wwl.delivery_detail_id = wdd.delivery_Detail_id
       and wdd.released_status in ('R','B') --- For Hot Order Changes
       and nvl(remove_from_wave_flag, 'N') <> 'Y';
  /*
  cursor c_req_qty_for_item
  select sum(requested_quantity),inventory_item_id,organization_id
  from wms_wp_wave_lines where wave_header_id = p_wave_header_id
  group by inventory_item_id; */

  TYPE SUFFICIENT_QTY_LINES IS RECORD(
    source_header_number    varchar2(30),
    DELIVERY_DETAIL_ID      NUMBER,
    ORGANIZATION_ID         NUMBER,
    INVENTORY_ITEM_ID       NUMBER,
    REQUESTED_QUANTITY      NUMBER,
    requested_quantity_uom  VARCHAR2(3),
    SOURCE_LINE_ID          NUMBER,
    ship_set_id             number,
    demand_source_header_id number,
    demand_source_type_id   number,
    model_id                number);

  TYPE INSUFFICIENT_QTY_LINES IS RECORD(
    source_header_number    varchar2(30),
    DELIVERY_DETAIL_ID      NUMBER,
    ORGANIZATION_ID         NUMBER,
    INVENTORY_ITEM_ID       NUMBER,
    REQUESTED_QUANTITY      NUMBER,
    requested_quantity_uom  VARCHAR2(3),
    SOURCE_LINE_ID          NUMBER,
    ship_set_id             number,
    demand_source_header_id number,
    demand_source_type_id   number,
    model_id                number);

 /* TYPE DELIVERY_DETAIL_REC IS RECORD(
    DELIVERY_DETAIL_ID NUMBER);*/

 /* TYPE insufficient_order_number_rec IS RECORD(
    order_number NUMBER);*/

  m1            number;
  v_labor_count number;
  v_shipset_no  number;
  v_model_no    number;

  TYPE DELIVERY_DETAIL_TBL IS TABLE OF number INDEX BY BINARY_INTEGER;
  TYPE SUFFICIENT_QTY_LINES_TBL IS TABLE OF SUFFICIENT_QTY_LINES INDEX BY BINARY_INTEGER;
  TYPE INSUFFICIENT_QTY_LINES_TBL IS TABLE OF SUFFICIENT_QTY_LINES INDEX BY BINARY_INTEGER;
  TYPE insufficient_order_number IS TABLE OF number INDEX BY BINARY_INTEGER;

  l_insufficient_DD_TBL       DELIVERY_DETAIL_TBL; -- For storing insufficient delivery detail ids
  l_insufficient_order_number insufficient_order_number;

  cursor c_shipset is
    SELECT WDD.DELIVERY_DETAIL_ID
      FROM WMS_WP_WAVE_LINES WWL, WSH_DELIVERY_DETAILS WDD
     WHERE WWL.DELIVERY_DETAIL_ID = WDD.DELIVERY_DETAIL_ID
       AND WWL.WAVE_HEADER_ID = p_wave_header_id
       AND WDD.SHIP_SET_ID = v_shipset_no
        and wdd.released_status in ('R','B') --- For Hot Order Changes
       and v_shipset_no is not null;

  cursor c_model is
    SELECT WDD.DELIVERY_DETAIL_ID
      FROM WMS_WP_WAVE_LINES WWL, WSH_DELIVERY_DETAILS WDD
     WHERE WWL.DELIVERY_DETAIL_ID = WDD.DELIVERY_DETAIL_ID
       AND WWL.WAVE_HEADER_ID = p_wave_header_id
       AND WDD.top_model_line_id = v_model_no
        and wdd.released_status in ('R','B') --- For Hot Order Changes
       and v_model_no is not null;

  cursor c_credit_check is
    SELECT wwl.wave_line_id, wwl.source_line_id, wwl.source_header_id
      FROM WMS_WP_WAVE_LINES WWL
     WHERE WWL.WAVE_HEADER_ID = p_wave_header_id
   --   and wdd.released_status in ('R','B') --- For Hot Order Changes
       and nvl(wwl.remove_from_wave_flag, 'N') <> 'Y';

  L_DEMAND_QTY       NUMBER;
  l_is_revision_ctrl BOOLEAN := FALSE;
  l_is_lot_ctrl      BOOLEAN := FALSE;
  l_is_serial_ctrl   BOOLEAN := FALSE;
  l_qoh              NUMBER;
  l_rqoh             NUMBER;
  l_qr               NUMBER;
  l_qs               NUMBER;
  l_atr              NUMBER;
  l_att              NUMBER;

  l_return_status          VARCHAR2(3) := fnd_api.g_ret_sts_success;
  j                        number := 0;
  k                        number := 0;
  v_backorder_flag         varchar2(1);
  v_reject_line_flag       varchar2(1);
  v_reject_shipset_flag    varchar2(1);
  v_reject_model_flag      varchar2(1);
  v_reject_order_flag      varchar2(1);
  v_reserve_flag           varchar2(1);
  v_create_delivery_flag   varchar2(1);
  v_credit_check_hold_flag varchar2(1);

  p_delivery_detail_id         number;
  l_TabOfDelDets               WSH_UTIL_CORE.ID_TAB_TYPE;
  l_del_rows                   WSH_UTIL_CORE.ID_TAB_TYPE;
  X_INSUFFICIENT_QTY_LINES_TBL INSUFFICIENT_QTY_LINES_TBL;
  X_SUFFICIENT_QTY_LINES_TBL   SUFFICIENT_QTY_LINES_TBL;
  X_DELIVERY_DETAIL_TBL        DELIVERY_DETAIL_TBL;

  /*TYPE CONSOL_LINES_REC IS RECORD(
    wave_header_id    NUMBER,
    wave_line_id      number,
    planned_fill_rate number); */



  TYPE CONSOL_LINES_wave_hdr_id IS TABLE OF number INDEX BY BINARY_INTEGER;
  	TYPE CONSOL_LINES_wave_line_id IS TABLE OF number INDEX BY BINARY_INTEGER;
  		TYPE CONSOL_LINES_fill_rate IS TABLE OF number INDEX BY BINARY_INTEGER;

  X_CONSOL_LINES_wave_hdr_id   CONSOL_LINES_wave_hdr_id;
  X_CONSOL_LINES_wave_line_id CONSOL_LINES_wave_line_id;
  X_CONSOL_LINES_fill_rate CONSOL_LINES_fill_rate;

  m                    NUMBER := 0;
  l_debug              NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'),
                                     0);
  l_msg_count          number;
  l_msg_data           varchar2(1000);
  v_Delivery_Detail_id NUMBER;
  v_sqlerrm            NUMBER;
  v_sqlmsg             VARCHAR2(1000);

  l_pick_subinventory varchar2(100);
  l_reserved_qty      number;
  l_effective_atr     number;

  --For credit check hold
  l_hold_result VARCHAR2(10);
 /* TYPE credit_check_rec IS RECORD(
    wave_line_id NUMBER); */
  TYPE credit_check_tbl IS TABLE OF number INDEX BY BINARY_INTEGER;
  l_credit_check_tbl credit_check_tbl;
  l_hold_index       number;

  --For backorder part
  l_out_rows            WSH_UTIL_CORE.ID_TAB_TYPE;
  g_backorder_deliv_tab WSH_UTIL_CORE.ID_TAB_TYPE;
  g_backorder_qty_tab   WSH_UTIL_CORE.ID_TAB_TYPE;
  g_dummy_table         WSH_UTIL_CORE.ID_TAB_TYPE;
  n1                    number := 1;

  --For Reservations
  l_rsv_temp_rec                inv_reservation_global.mtl_reservation_rec_type;
  l_rsv_temp_rec_2              inv_reservation_global.mtl_reservation_rec_type;
  l_src_sub                     VARCHAR2(10);
  l_order_count                 NUMBER;
  l_demand_header_id            NUMBER;
  L_demand_line_id              NUMBER;
  L_demand_line_detail_id       NUMBER;
  L_demand_quantity             NUMBER;
  L_demand_quantity_in_repl_uom NUMBER;
  L_demand_uom_code             VARCHAR2(3);
  L_demand_type_id              NUMBER;
  L_sequence_id                 NUMBER;
  l_expected_ship_date          date;
  l_repl_level                  NUMBER;
  l_repl_type                   NUMBER;
  l_repl_UOM_code               VARCHAR2(3);
  l_Repl_Lot_Size               NUMBER;
  l_rsv_tbl_tmp                 inv_reservation_global.mtl_reservation_tbl_type;
  l_rsv_rec                     inv_reservation_global.mtl_reservation_rec_type;
  l_serial_number               inv_reservation_global.serial_number_tbl_type;
  l_to_serial_number            inv_reservation_global.serial_number_tbl_type;
  l_quantity_reserved           NUMBER;
  l_quantity_reserved2          NUMBER;
  l_rsv_id                      NUMBER;
  l_error_code                  NUMBER;
  l_mtl_reservation_count       NUMBER;
  n                             number := 1;
  l_other_wdd_qty               number := 0;
  l_temp_value                  number;
  l_enable_labor_planning       varchar2(1);
  l_planning_method             varchar2(1);
  l_crossdock_criteria          varchar2(100);
  l_crossdock_criteria_id       number;
  l_allocation_method           varchar2(100);
  l_crossdock_qty               number := 0;
  l_allocated_qty               number := 0;
  l_organization_id             number;
  l_table_start number;

  -- For Storing Values in Global Temp Table -- Rules SImulation
  cursor c_populate_temp IS
    select delivery_Detail_id
      from wms_wp_wave_lines
     where wave_header_id = p_wave_header_id;

  TYPE wp_crossdock_rec IS RECORD(
    delivery_detail_id number,
    crossdock_qty      number);

  TYPE wp_crossdock_tbl IS TABLE OF wp_crossdock_rec INDEX BY BINARY_INTEGER;

  x_wp_crossdock_tbl wp_crossdock_tbl;

  l_start_time  DATE; -- start time changes
  l_target_date DATE; -- start time changes
  --  l_organization_id NUMBER; -- start time changes
  start_date_exception EXCEPTION; -- start time changes
l_wave_status varchar2(30);
l_total_qty number;
l_pull_replenishment varchar2(1);

begin

  -- start time changes start
  print_debug('CHECKING IF START TIME IS BETWEEN SYSDATE OR NOT', l_debug);




  SELECT start_time, organization_id,pick_seq_rule_id,
  pick_grouping_rule_id,pick_subinventory,staging_subinventory,
  DEFAULT_STAGE_LOCATOR_ID,wave_status,pull_replenishment_flag
    INTO l_start_time, l_organization_id,
    g_pick_seq_rule_id,
           g_pick_grouping_rule_id,
           g_pick_subinventory,
           g_staging_subinventory,
           g_to_locator,
           l_wave_status,
           l_pull_replenishment
    FROM wms_wp_wave_headers_vl
   WHERE wave_header_id = p_wave_header_id;

print_debug('Ajith after', l_debug);
    print_Debug('start time = ' ||
              To_Char(l_start_time, 'DD:MON:YYYY HH24:MI:SS'),
              l_debug);

  select enable_labor_planning
    into l_enable_labor_planning
    from wms_wp_planning_Criteria_vl
   where planning_criteria_id = p_planning_criteria_id;

   print_debug('Validating the Start time ', l_debug);

      print_debug('Labor Enabled Flag is  '||l_enable_labor_planning, l_debug);


   if l_enable_labor_planning = 'Y' then


  SELECT MAX(nvl(wdab.end_time,
                 (nvl(wts.planned_departure_date,
                      nvl(wnd.latest_pickup_date, wdd.date_scheduled)))))
    into l_target_date
    FROM wms_wp_wave_lines        wwl,
         wsh_delivery_details     wdd,
         wsh_delivery_assignments wda,
         wsh_new_deliveries       wnd,
         wsh_delivery_legs        wdl,
         wsh_trip_stops           wts,
         wms_dock_appointments_b  wdab
   WHERE wwl.organization_id = l_organization_id
     AND wwl.wave_header_id = p_wave_header_id
     AND wwl.delivery_detail_id = wdd.delivery_detail_id
     AND wdd.delivery_detail_id = wda.delivery_detail_id
      --and wdd.released_status in ('R','B') --- For Hot Order Changes
     AND wda.delivery_id = wnd.delivery_id(+)
     AND wnd.delivery_id = wdl.delivery_id(+)
     AND wdl.pick_up_stop_id = wts.stop_id(+)
     AND wts.stop_id = wdab.trip_stop(+);

  print_Debug('l_target_date = ' ||
              To_Char(l_target_date, 'DD:MON:YYYY HH24:MI:SS'),
              l_debug);
  print_Debug('SYSDATE = ' || to_char(SYSDATE, 'DD:MON:YYYY HH24:MI:SS'),
              l_debug);

     IF l_target_date < l_start_time THEN
     RAISE start_date_exception;
     END IF;
end if;
  -- start time changes end

  -- Bulk Populate the Global Temp Table



  insert into wms_wp_rules_simulation
    (wave_header_id,delivery_Detail_id, requested_quantity, requested_quantity2)
    select wwl.wave_header_id,wwl.delivery_Detail_id, wwl.requested_quantity, wwl.requested_quantity2
      from wms_wp_wave_lines wwl, wsh_delivery_details wdd
     where wave_header_id = p_wave_header_id
     and wdd.released_status in ('R','B') --- For Hot Order Changes;
     and wdd.delivery_Detail_id = wwl.delivery_Detail_id
     and nvl(remove_from_wave_flag,'N')<>'Y';

  update wms_wp_wave_lines
     set crossdock_quantity = 0
   where wave_header_id = p_wave_header_id;
  --select
  -- Checking if Pick Subinventory is mentioned in Planning Criteria

  print_debug('In Plan Wave API', l_debug);

  select Backorder_flag,
         Reject_order_line_flag,
         Reject_all_lines_shipset_flag,
         Reject_all_lines_model_flag,
         Reject_Order_flag,
         Reserve_stock_flag,
         auto_create_deliveries_flag,
         credit_check_hold_flag,
         picking_subinventory,
         enable_labor_planning,
         planning_method,
         crossdock_criteria,
         crossdock_criteria_id,
         allocation_method
    into v_backorder_flag,
         v_reject_line_flag,
         v_reject_shipset_flag,
         v_reject_model_flag,
         v_reject_order_flag,
         v_reserve_flag,
         v_create_delivery_flag,
         v_credit_check_hold_flag,
         l_pick_subinventory,
         l_enable_labor_planning,
         l_planning_method,
         l_crossdock_criteria,
         l_crossdock_criteria_id,
         l_allocation_method
    from wms_wp_planning_criteria_vl
   where planning_criteria_id = p_planning_criteria_id;

  print_debug('pick_subinventory in Plan Wave CP is:' ||
              l_pick_subinventory,
              l_debug);

g_from_subinventory_plan := l_pick_subinventory;

  -- Plan Wave plans what needs to be done for the wave lines if there is sufficient stock and if sufficient stock is not available.
  -- Get the consolidated demand for the item.
  -- Get the ATR for the item(org level)
  -- Get the wave lines that has available quantity and get the lines that has insufficient quantity
  -- Based on the parameters passed, we will be planning what needs to be done

  --Find out the total demand quantity for an item.
  ---   OPEN c_req_qty_for_item;
  --    FETCH c_req_qty_for_item BULK COLLECT INTO  CONSOL_ITEM_TBL, ORG_ID_TBL,CONSOL_ITEM_REQ_QTY_TBL;
  --    CLOSE c_req_qty_for_item;

  -- Find the total lines for the wave_header_id
  /*
  OPEN c_plan_lines;
  FETCH c_plan_lines BULK COLLECT INTO CONSOL_LINES_TBL;
  CLOSE c_plan_lines;   */

  print_debug('Before c_item_rec loop ', l_debug);

  print_debug('Checking whether it is availability to check planning or Rule Based Planning ',
              l_debug);

  if l_planning_method = 'R' then

    print_debug('Rule Based Planning ', l_debug);

    if l_allocation_method = 'C' then

      call_planned_crossdock(p_wave_header_id, p_planning_criteria_id);

    elsif l_allocation_method = 'I' THEN
      print_debug('xxx calling Rule Based simulation ', l_debug);

      rule_based_simulation(p_planning_criteria_id,
                            p_wave_header_id,
                            l_organization_id);

    elsif l_allocation_method = 'N' then

      rule_based_simulation(p_planning_criteria_id,
                            p_wave_header_id,
                            l_organization_id);

      call_planned_crossdock(p_wave_header_id, p_planning_criteria_id);

    elsif l_allocation_method = 'X' then

      call_planned_crossdock(p_wave_header_id, p_planning_criteria_id);

      rule_based_simulation(p_planning_criteria_id,
                            p_wave_header_id,
                            l_organization_id);

    end if;

  else

    print_debug('Availabiltity Based Planning ', l_debug);

    if l_allocation_method in ('C', 'X') then

      -- Call Crossdocking

      call_planned_crossdock(p_wave_header_id, p_planning_criteria_id);

  elsif l_allocation_method = 'N' then

  	print_debug('Prioritize Inventory --> Checking how much can come from inventory', l_debug);


  	 FOR c_item_rec IN c_item LOOP

    l_item_id := c_item_rec.inventory_item_id;
    l_org_id  := c_item_rec.organization_id;
    print_debug('l_item_id :' || l_item_id, l_debug);
    print_debug('l_org_id :' || l_org_id, l_debug);

          print_debug('Planning Method is Availability to Check and Allocation Method is not Crossdock Only --> Getting ATR ',
                  l_debug);

      --Find out the total atr for the item
      IF inv_cache.set_item_rec(L_ORG_ID, L_item_id) THEN

     /*   IF inv_cache.item_rec.revision_qty_control_code = 2 THEN
          l_is_revision_ctrl := TRUE;
        ELSE
          l_is_revision_ctrl := FALSE;
        END IF;

        IF inv_cache.item_rec.lot_control_code = 2 THEN
          l_is_lot_ctrl := TRUE;
        ELSE
          l_is_lot_ctrl := FALSE;
        END IF; */

        IF inv_cache.item_rec.serial_number_control_code NOT IN (1, 6) THEN
          l_is_serial_ctrl := FALSE;
        ELSE
          l_is_serial_ctrl := TRUE;
        END IF;

      ELSE

        print_debug('Error: Item detail not found', l_debug);
        RAISE no_data_found;
      END IF;

      inv_quantity_tree_pub.query_quantities(p_api_version_number      => 1.0,
                                             p_init_msg_lst            => fnd_api.g_false,
                                             x_return_status           => l_return_status,
                                             x_msg_count               => l_msg_count,
                                             x_msg_data                => l_msg_data,
                                             p_organization_id         => l_org_id,
                                             p_inventory_item_id       => l_item_id,
                                             p_tree_mode               => inv_quantity_tree_pub.g_transaction_mode,
                                             p_is_revision_control     => l_is_revision_ctrl,
                                             p_is_lot_control          => l_is_lot_ctrl,
                                             p_is_serial_control       => l_is_serial_ctrl,
                                             p_demand_source_type_id   => -9999 --should not be null
                                            ,
                                             p_demand_source_header_id => -9999 --should not be null
                                            ,
                                             p_demand_source_line_id   => -9999,
                                             p_revision                => NULL,
                                             p_lot_number              => NULL,
                                             p_subinventory_code       => l_pick_subinventory,
                                             p_locator_id              => NULL,
                                             x_qoh                     => l_qoh,
                                             x_rqoh                    => l_rqoh,
                                             x_qr                      => l_qr,
                                             x_qs                      => l_qs,
                                             x_att                     => l_att,
                                             x_atr                     => l_atr);

      print_debug('x_qoh :' || l_qoh, l_debug);
      print_debug('x_rqoh :' || l_rqoh, l_debug);
      print_debug('x_qr :' || l_qr, l_debug);
      print_debug('x_qs :' || l_qs, l_debug);
      print_debug('x_att :' || l_att, l_debug);
      print_debug('x_atr :' || l_atr, l_debug);




  	FOR c_rec IN c_plan_lines LOOP

      EXIT WHEN c_plan_lines%NOTFOUND;

    --   begin

          -- Since Qty Tree would have also subttracted qty for current demand
          -- lines under consideration for which there is existing
          -- reservation as well, I need to add them back
          -- to see real picture of the atr for demand line under consideration

          ------------------

          SELECT nvl(sum(reservation_quantity), 0)
            INTO l_reserved_qty
            FROM mtl_Reservations
           WHERE demand_source_line_id = c_rec.SOURCE_LINE_ID
             and organization_id = L_ORG_ID
             and inventory_item_id = L_ITEM_ID
             and (subinventory_code = l_pick_subinventory or
                 l_pick_subinventory is null);

          SELECT Nvl(SUM(wdd.requested_quantity), 0)
            INTO l_other_wdd_qty
            FROM wsh_delivery_details wdd
           WHERE wdd.organization_id = l_org_id
             AND wdd.inventory_item_id = l_item_id
             and wdd.delivery_Detail_id not in
                 (select delivery_detail_id
                    from wms_wp_wave_lines
                   where wave_header_id = p_wave_header_id
                        --  and nvl(remove_from_wave_flag, 'N') <> 'Y'   --- Removed by Ajith in Phase III as  planning it second time is giving an issue
                     and source_line_id = wdd.source_line_id);

          print_debug('Reserved Qty for other dds that do not belong to the wave in source line id  :' ||
                      c_rec.SOURCE_LINE_ID || ' is ' || l_other_wdd_qty,
                      l_debug);

          IF (l_reserved_qty - l_other_wdd_qty) >= 0 THEN
            l_temp_value := (l_reserved_qty - l_other_wdd_qty);
          ELSE
            l_temp_value := 0;
          END IF;

          l_reserved_qty := l_temp_value;

          print_debug('Reserved Qty for source line id  :' ||
                      c_rec.SOURCE_LINE_ID || ' is ' || l_reserved_qty,
                      l_debug);

                                print_debug('l_atr is   :' ||l_atr,
                      l_debug);

                         if (l_atr + l_reserved_qty) >= c_rec.requested_quantity then

                update wms_wp_rules_simulation
                   set allocated_quantity =  c_rec.requested_quantity
                 where delivery_detail_id = c_rec.delivery_Detail_id
                 and wave_header_id=p_wave_header_id;
                print_debug('Prioritize Inventory --> Quantity picked from Inventory is  '||c_rec.requested_quantity,
                            l_debug);


                l_atr := l_atr - c_rec.REQUESTED_QUANTITY;

              elsif (l_atr + l_reserved_qty) < c_rec.requested_quantity then



                  update wms_wp_rules_simulation
                     set allocated_quantity =
                                                (l_atr + l_reserved_qty)
                   where delivery_detail_id = c_rec.delivery_Detail_id
                    and wave_header_id=p_wave_header_id;

   print_debug('Prioritize Inventory --> Quantity picked from Inventory is  '||
                                                (l_atr + l_reserved_qty),
                            l_debug);


                l_atr :=0;


              end if;





      if l_atr < 0 then

        l_atr := 0;

      end if;

    end loop;

  end loop;

         print_debug('Prioritize Inventory -->Calling Crossdocking', l_debug);
    call_planned_crossdock(p_wave_header_id, p_planning_criteria_id);
    end if;


  end if;

  print_debug('Entering the Item Loop ', l_debug);

  FOR c_item_rec IN c_item LOOP

    l_item_id := c_item_rec.inventory_item_id;
    l_org_id  := c_item_rec.organization_id;
    print_debug('l_item_id :' || l_item_id, l_debug);
    print_debug('l_org_id :' || l_org_id, l_debug);

    -- Get the Allocation Method and check if it is crossdock only then the following code can be skipped..

    if (l_planning_method = 'A' and l_allocation_method <> 'C') then

      print_debug('Planning Method is Availability to Check and Allocation Method is not Crossdock Only --> Getting ATR ',
                  l_debug);

      --Find out the total atr for the item
      IF inv_cache.set_item_rec(L_ORG_ID, L_item_id) THEN

      /*  IF inv_cache.item_rec.revision_qty_control_code = 2 THEN
          l_is_revision_ctrl := TRUE;
        ELSE
          l_is_revision_ctrl := FALSE;
        END IF;

        IF inv_cache.item_rec.lot_control_code = 2 THEN
          l_is_lot_ctrl := TRUE;
        ELSE
          l_is_lot_ctrl := FALSE;
        END IF;*/

        IF inv_cache.item_rec.serial_number_control_code NOT IN (1, 6) THEN
          l_is_serial_ctrl := FALSE;
        ELSE
          l_is_serial_ctrl := TRUE;
        END IF;

      ELSE

        print_debug('Error: Item detail not found', l_debug);
        RAISE no_data_found;
      END IF;

      inv_quantity_tree_pub.query_quantities(p_api_version_number      => 1.0,
                                             p_init_msg_lst            => fnd_api.g_false,
                                             x_return_status           => l_return_status,
                                             x_msg_count               => l_msg_count,
                                             x_msg_data                => l_msg_data,
                                             p_organization_id         => l_org_id,
                                             p_inventory_item_id       => l_item_id,
                                             p_tree_mode               => inv_quantity_tree_pub.g_transaction_mode,
                                             p_is_revision_control     => l_is_revision_ctrl,
                                             p_is_lot_control          => l_is_lot_ctrl,
                                             p_is_serial_control       => l_is_serial_ctrl,
                                             p_demand_source_type_id   => -9999 --should not be null
                                            ,
                                             p_demand_source_header_id => -9999 --should not be null
                                            ,
                                             p_demand_source_line_id   => -9999,
                                             p_revision                => NULL,
                                             p_lot_number              => NULL,
                                             p_subinventory_code       => l_pick_subinventory,
                                             p_locator_id              => NULL,
                                             x_qoh                     => l_qoh,
                                             x_rqoh                    => l_rqoh,
                                             x_qr                      => l_qr,
                                             x_qs                      => l_qs,
                                             x_att                     => l_att,
                                             x_atr                     => l_atr);

      print_debug('x_qoh :' || l_qoh, l_debug);
      print_debug('x_rqoh :' || l_rqoh, l_debug);
      print_debug('x_qr :' || l_qr, l_debug);
      print_debug('x_qs :' || l_qs, l_debug);
      print_debug('x_att :' || l_att, l_debug);
      print_debug('x_atr :' || l_atr, l_debug);


          -- Ajith Replenishment Simulation for availability check

      -- Get the Sourcing subinventory for the pick subinventory

      -- Need to check if entire atr can be fulfilled from this subinventory or should it be replenished.

      if l_pick_subinventory is not null and l_pull_replenishment = 'Y' and get_source_subinventory(l_item_id,l_pick_subinventory) is not null THEN


      	   print_debug('Checking if Replenishment is needed in Availability check', l_debug);

      select sum(requested_quantity) into l_total_qty  from wms_wp_wave_lines where wave_header_id = p_wave_header_id
      and inventory_item_id = l_item_id and organization_id=l_org_id;

     print_debug('total demand quantity for the item is ' || l_total_qty, l_debug);

      if l_total_qty < l_atr THEN

      	 print_debug('No Replenishment is needed', l_debug);

    ELSE

    	l_atr := l_atr + get_att_for_subinventory(get_source_subinventory(l_item_id,l_pick_subinventory),
                                    l_item_id,
                                    l_org_id);


    	 print_debug('New ATT for the item is ' || l_atr, l_debug);

    end if;




    end if;


    ELSE

      l_atr := 0;

    end if; --- For Crossdock only

    FOR c_rec IN c_plan_lines LOOP

      EXIT WHEN c_plan_lines%NOTFOUND;

      if (l_planning_method = 'A' and l_allocation_method <> 'C') then

        print_debug('Planning Method is Availability to Check and Allocation Method is not Crossdock Only  --> Getting Reserved Qty ',
                    l_debug);

        begin

          -- Since Qty Tree would have also subttracted qty for current demand
          -- lines under consideration for which there is existing
          -- reservation as well, I need to add them back
          -- to see real picture of the atr for demand line under consideration

          ------------------

          SELECT nvl(sum(reservation_quantity), 0)
            INTO l_reserved_qty
            FROM mtl_Reservations
           WHERE demand_source_line_id = c_rec.SOURCE_LINE_ID
             and organization_id = L_ORG_ID
             and inventory_item_id = L_ITEM_ID
             and (subinventory_code = l_pick_subinventory or
                 l_pick_subinventory is null);

          SELECT Nvl(SUM(wdd.requested_quantity), 0)
            INTO l_other_wdd_qty
            FROM wsh_delivery_details wdd
           WHERE wdd.organization_id = l_org_id
             AND wdd.inventory_item_id = l_item_id
             and wdd.delivery_Detail_id not in
                 (select delivery_detail_id
                    from wms_wp_wave_lines
                   where wave_header_id = p_wave_header_id
                        --  and nvl(remove_from_wave_flag, 'N') <> 'Y'   --- Removed by Ajith in Phase III as  planning it second time is giving an issue
                     and source_line_id = wdd.source_line_id);

          print_debug('Reserved Qty for other dds that do not belong to the wave in source line id  :' ||
                      c_rec.SOURCE_LINE_ID || ' is ' || l_other_wdd_qty,
                      l_debug);

          IF (l_reserved_qty - l_other_wdd_qty) >= 0 THEN
            l_temp_value := (l_reserved_qty - l_other_wdd_qty);
          ELSE
            l_temp_value := 0;
          END IF;

          l_reserved_qty := l_temp_value;

          print_debug('Reserved Qty for source line id  :' ||
                      c_rec.SOURCE_LINE_ID || ' is ' || l_reserved_qty,
                      l_debug);

          l_crossdock_qty := 0; ---In Case of Inventory only
          if l_allocation_method <> 'I' then
            select crossdocked_quantity
              into l_crossdock_qty
              from wms_wp_rules_simulation
             where delivery_Detail_id = c_rec.delivery_Detail_id
              and wave_header_id=p_wave_header_id;

            print_debug('Crossdocked Quantity for delivery_Detail_id   :' ||
                        c_rec.delivery_Detail_id || ' is ' ||
                        l_crossdock_qty,
                        l_debug);

            if l_allocation_method = 'N' then

              print_debug('Prioritize Inventory', l_debug);

              if (l_atr + l_reserved_qty) >= c_rec.requested_quantity then

                update wms_wp_rules_simulation
                   set crossdocked_quantity = 0
                 where delivery_detail_id = c_rec.delivery_Detail_id
                  and wave_header_id=p_wave_header_id;
                print_debug('Prioritize Inventory --> Quantity picked from Crossdocking is 0 ',
                            l_debug);

                l_crossdock_qty := 0;
              else

                if l_crossdock_qty > 0 then

                  update wms_wp_rules_simulation
                     set crossdocked_quantity = c_rec.requested_quantity -
                                                (l_atr + l_reserved_qty)
                   where delivery_detail_id = c_rec.delivery_Detail_id
                    and wave_header_id=p_wave_header_id;

                  print_debug('Prioritize Inventory --> Quantity picked from Crossdocking is  ' ||
                              to_number(c_rec.requested_quantity -
                                        (l_atr + l_reserved_qty)),
                              l_debug);
                  l_crossdock_qty := c_rec.requested_quantity -
                                     (l_atr + l_reserved_qty);
                end if;
              end if;

            end if;
          end if;
        exception

          when no_data_found then
            l_reserved_qty  := 0;
            l_crossdock_qty := 0;
        end;

        l_atr := l_atr + l_reserved_qty + l_crossdock_qty;

        print_debug('Effective ATR is  :' || l_atr, l_debug);

      Elsif (l_allocation_method = 'C') THEN
        -- For Crossdock only in Rule Based or Normal Planning

        print_debug('Allocation Method is Crossdock Only  --> Getting Crossdock Qty ',
                    l_debug);

        select crossdocked_quantity
          into l_crossdock_qty
          from wms_wp_rules_simulation
         where delivery_Detail_id = c_rec.delivery_Detail_id
          and wave_header_id=p_wave_header_id;

        print_debug('Crossdocked Quantity for delivery_Detail_id   :' ||
                    c_rec.delivery_Detail_id || ' is ' || l_crossdock_qty,
                    l_debug);

        l_atr := l_crossdock_qty;

      elsif (l_planning_method = 'R' and l_allocation_method <> 'C') then

        print_debug('Planning Method is Rule based Planning and Allocation Method is not Crossdock Only  --> Getting Allocated Qty and Crossdocked Qty ',
                    l_debug);

        select crossdocked_quantity, allocated_quantity
          into l_crossdock_qty, l_allocated_qty
          from wms_wp_rules_simulation
         where delivery_Detail_id = c_rec.delivery_Detail_id
          and wave_header_id=p_wave_header_id;

        print_debug('Crossdocked Quantity for delivery_Detail_id   :' ||
                    c_rec.delivery_Detail_id || ' is ' || l_crossdock_qty,
                    l_debug);
        print_debug('Allocated Quantity for delivery_Detail_id   :' ||
                    c_rec.delivery_Detail_id || ' is ' || l_allocated_qty,
                    l_debug);

        l_atr := l_crossdock_qty + l_allocated_qty;

      end if; -- Crossdock only

      print_debug('Effective Final ATR   is :' || l_atr, l_debug);

      if l_atr >= c_rec.REQUESTED_QUANTITY then

        PRINT_DEBUG('Effective ATR is greater than the Requested Quantity',
                    l_debug);

        X_CONSOL_LINES_wave_hdr_id(m) := p_wave_header_id;
       X_CONSOL_LINES_wave_line_id(m) := c_rec.wave_line_id;
        X_CONSOL_LINES_fill_rate(m) := 100;

        X_SUFFICIENT_QTY_LINES_TBL(j).DELIVERY_DETAIL_ID := c_rec
                                                           .DELIVERY_DETAIL_ID;
        X_SUFFICIENT_QTY_LINES_TBL(j).SOURCE_LINE_ID := c_rec
                                                       .SOURCE_LINE_ID;
        X_SUFFICIENT_QTY_LINES_TBL(j).source_header_number := c_rec
                                                             .source_header_number;
        X_SUFFICIENT_QTY_LINES_TBL(j).ORGANIZATION_ID := c_rec
                                                        .ORGANIZATION_ID;
        X_SUFFICIENT_QTY_LINES_TBL(j).INVENTORY_ITEM_ID := c_rec
                                                          .INVENTORY_ITEM_ID;
        X_SUFFICIENT_QTY_LINES_TBL(j).REQUESTED_QUANTITY := c_rec
                                                           .REQUESTED_QUANTITY;
        X_SUFFICIENT_QTY_LINES_TBL(j).ship_set_id := c_rec.ship_set_id;
        X_SUFFICIENT_QTY_LINES_TBL(j).model_id := c_rec.top_model_line_id;
        X_SUFFICIENT_QTY_LINES_TBL(j).requested_quantity_uom := c_rec
                                                               .requested_quantity_uom;
        X_SUFFICIENT_QTY_LINES_TBL(j).demand_source_header_id := c_rec
                                                                .demand_source_header_id;
        X_SUFFICIENT_QTY_LINES_TBL(j).demand_source_type_id := c_rec
                                                              .demand_source_type_id;

        -- For Autocreate delivery
        if v_create_delivery_flag = 'Y' then
          l_TabOfDelDets(j + 1) := X_SUFFICIENT_QTY_LINES_TBL(j)
                                  .DELIVERY_DETAIL_ID;
        end if;
        if v_reserve_flag = 'Y' then
          -- If atr is greater than the req qty plan for lines with Sufficient stock
          -- *********Planning Action for Lines with Sufficient Stock *********

          --Reserve Stock for Order Line
          --Create High Level Reservation

          begin

            -- Create Org Level reservation for every demand line, if it does not exist

            -- Check if an Org level reservation exists for corresponding order line
            -- Clear out old values
            l_rsv_temp_rec := l_rsv_temp_rec_2;

            -- Assign all new values
            l_rsv_temp_rec.organization_id   := X_SUFFICIENT_QTY_LINES_TBL(j)
                                               .ORGANIZATION_ID;
            l_rsv_temp_rec.inventory_item_id := X_SUFFICIENT_QTY_LINES_TBL(j)
                                               .INVENTORY_item_id;

            l_rsv_temp_rec.DEMAND_SOURCE_TYPE_ID := X_SUFFICIENT_QTY_LINES_TBL(j)
                                                   .demand_source_type_id;

            l_rsv_temp_rec.DEMAND_SOURCE_HEADER_ID := X_SUFFICIENT_QTY_LINES_TBL(j)
                                                     .demand_source_header_id;
            l_rsv_temp_rec.DEMAND_SOURCE_LINE_ID   := X_SUFFICIENT_QTY_LINES_TBL(j)
                                                     .source_line_id;

            l_return_status := fnd_api.g_ret_sts_success;
            inv_reservation_pub.query_reservation(p_api_version_number        => 1.0,
                                                  x_return_status             => l_return_status,
                                                  x_msg_count                 => l_msg_count,
                                                  x_msg_data                  => l_msg_data,
                                                  p_query_input               => l_rsv_temp_rec,
                                                  x_mtl_reservation_tbl       => l_rsv_tbl_tmp,
                                                  x_mtl_reservation_tbl_count => l_mtl_reservation_count,
                                                  x_error_code                => l_error_code);

            IF l_RETURN_status = fnd_api.g_ret_sts_success THEN

              PRINT_DEBUG('Number of reservations found: ' ||
                          l_mtl_reservation_count,
                          l_debug);

              --
              IF l_mtl_reservation_count = 0 then
                -- Create high-level reservation

                PRINT_DEBUG('Creating reservation>>>', l_debug);

                -- Set the values for the reservation record to be created

                l_rsv_rec.reservation_id          := NULL;
                l_rsv_rec.requirement_date        := sysdate; --l_demand_expected_time;
                l_rsv_rec.organization_id         := X_SUFFICIENT_QTY_LINES_TBL(j)
                                                    .ORGANIZATION_ID;
                l_rsv_rec.inventory_item_id       := X_SUFFICIENT_QTY_LINES_TBL(j)
                                                    .inventory_item_id;
                l_rsv_rec.demand_source_name      := NULL;
                l_rsv_rec.demand_source_type_id   := X_SUFFICIENT_QTY_LINES_TBL(j)
                                                    .demand_source_type_id;
                l_rsv_rec.demand_source_header_id := X_SUFFICIENT_QTY_LINES_TBL(j)
                                                    .demand_source_header_id;
                -- here l_demand_so_header_id is inv_salesorder.get_salesorder_for_oeheader(wdd.source_header_id)
                l_rsv_rec.demand_source_line_id        := X_SUFFICIENT_QTY_LINES_TBL(j)
                                                         .source_line_id;
                l_rsv_rec.orig_demand_source_type_id   := X_SUFFICIENT_QTY_LINES_TBL(j)
                                                         .demand_source_type_id;
                l_rsv_rec.orig_demand_source_header_id := X_SUFFICIENT_QTY_LINES_TBL(j)
                                                         .demand_source_header_id;
                l_rsv_rec.orig_demand_source_line_id   := X_SUFFICIENT_QTY_LINES_TBL(j)
                                                         .source_line_id;

                -- For now supply is only from Inventory supply_source_type_id = 13
                l_rsv_rec.demand_source_line_detail      := NULL;
                l_rsv_rec.orig_demand_source_line_detail := NULL;

                l_rsv_rec.demand_source_delivery         := NULL;
                l_rsv_rec.primary_uom_code               := X_SUFFICIENT_QTY_LINES_TBL(j)
                                                           .requested_quantity_uom;
                l_rsv_rec.primary_uom_id                 := NULL;
                l_rsv_rec.secondary_uom_code             := null;
                l_rsv_rec.secondary_uom_id               := NULL;
                l_rsv_rec.reservation_uom_code           := X_SUFFICIENT_QTY_LINES_TBL(j)
                                                           .requested_quantity_uom; --l_supply_uom_code;
                l_rsv_rec.reservation_uom_id             := NULL;
                l_rsv_rec.reservation_quantity           := X_SUFFICIENT_QTY_LINES_TBL(j)
                                                           .requested_quantity; --Should
                l_rsv_rec.primary_reservation_quantity   := X_SUFFICIENT_QTY_LINES_TBL(j)
                                                           .requested_quantity;
                l_rsv_rec.secondary_reservation_quantity := null;
                l_rsv_rec.detailed_quantity              := NULL;
                l_rsv_rec.secondary_detailed_quantity    := NULL;
                l_rsv_rec.autodetail_group_id            := NULL;
                l_rsv_rec.external_source_code           := 'OE'; -- Mark the external source --Ajith???????????????
                l_rsv_rec.external_source_line_id        := NULL;
                l_rsv_rec.supply_source_type_id          := 13;
                l_rsv_rec.orig_supply_source_type_id     := 13;
                l_rsv_rec.supply_source_name             := NULL;

                l_rsv_rec.supply_source_header_id        := NULL;
                l_rsv_rec.supply_source_line_id          := NULL;
                l_rsv_rec.supply_source_line_detail      := NULL;
                l_rsv_rec.orig_supply_source_header_id   := NULL;
                l_rsv_rec.orig_supply_source_line_id     := NULL;
                l_rsv_rec.orig_supply_source_line_detail := NULL;

                l_rsv_rec.revision := NULL;
                --  l_rsv_rec.subinventory_code  := l_subinventory_code;
                l_rsv_rec.subinventory_code  := NULL;
                l_rsv_rec.subinventory_id    := NULL;
                l_rsv_rec.locator_id         := NULL;
                l_rsv_rec.lot_number         := NULL;
                l_rsv_rec.lot_number_id      := NULL;
                l_rsv_rec.pick_slip_number   := NULL;
                l_rsv_rec.lpn_id             := NULL;
                l_rsv_rec.attribute_category := NULL;
                l_rsv_rec.attribute1         := NULL;
                l_rsv_rec.attribute2         := NULL;
                l_rsv_rec.attribute3         := NULL;
                l_rsv_rec.attribute4         := NULL;
                l_rsv_rec.attribute5         := NULL;
                l_rsv_rec.attribute6         := NULL;
                l_rsv_rec.attribute7         := NULL;
                l_rsv_rec.attribute8         := NULL;
                l_rsv_rec.attribute9         := NULL;
                l_rsv_rec.attribute10        := NULL;
                l_rsv_rec.attribute11        := NULL;
                l_rsv_rec.attribute12        := NULL;
                l_rsv_rec.attribute13        := NULL;
                l_rsv_rec.attribute14        := NULL;
                l_rsv_rec.attribute15        := NULL;
                l_rsv_rec.ship_ready_flag    := NULL;
                l_rsv_rec.staged_flag        := NULL;

                l_rsv_rec.crossdock_flag        := NULL;
                l_rsv_rec.crossdock_criteria_id := NULL;

                l_rsv_rec.serial_reservation_quantity := NULL;
                --   l_rsv_rec.supply_receipt_date         := l_supply_expected_time; --????????Ajith
                --   l_rsv_rec.demand_ship_date            := l_demand_expected_time; --?????????Ajith
                l_rsv_rec.supply_receipt_date := sysdate;
                l_rsv_rec.demand_ship_date    := sysdate;
                l_rsv_rec.project_id          := NULL;
                l_rsv_rec.task_id             := NULL;
                l_rsv_rec.serial_number       := NULL;

                print_debug('Call the create_reservation API to create the replenishemnt reservation',
                            l_debug);

                INV_RESERVATION_PVT.create_reservation(p_api_version_number          => 1.0,
                                                       p_init_msg_lst                => fnd_api.g_false,
                                                       x_return_status               => l_return_status,
                                                       x_msg_count                   => l_msg_count,
                                                       x_msg_data                    => l_msg_data,
                                                       p_rsv_rec                     => l_rsv_rec,
                                                       p_serial_number               => l_serial_number,
                                                       x_serial_number               => l_to_serial_number,
                                                       p_partial_reservation_flag    => fnd_api.g_false,
                                                       p_force_reservation_flag      => fnd_api.g_false,
                                                       p_validation_flag             => fnd_api.g_true,
                                                       x_quantity_reserved           => l_quantity_reserved,
                                                       x_secondary_quantity_reserved => l_quantity_reserved2,
                                                       x_reservation_id              => l_rsv_id);

              END IF;

              IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

                print_debug('Error returned from INV create_reservation API: ' ||
                            l_return_status,
                            l_debug);

                -- Raise an exception.  The caller will do the rollback, cleanups,
                RAISE FND_API.G_EXC_ERROR;

              END IF;

            ELSE

              PRINT_DEBUG('Error: ' || l_msg_data, l_debug);

            END IF;

          EXCEPTION
            WHEN OTHERS THEN
              l_return_status := fnd_api.g_ret_sts_error;
              fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                        p_data  => l_msg_data);

              print_debug('Exiting Create_RSV - Execution error: ' ||
                          TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS') || ' ' ||
                          l_msg_data,
                          l_debug);

          end;
        end if;

        j := j + 1;

      else

        PRINT_DEBUG('Effective ATR is less than the Requested Quantity',
                    l_debug);

        X_CONSOL_LINES_wave_hdr_id(m) := p_wave_header_id;
       X_CONSOL_LINES_wave_line_id(m) := c_rec.wave_line_id;

        IF L_ATR > 0 THEN
          X_CONSOL_LINES_fill_rate(m) := round((l_atr * 100) /
                                                           c_rec.REQUESTED_QUANTITY);

          --    l_atr := l_atr - c_rec.REQUESTED_QUANTITY;

        ELSE
          X_CONSOL_LINES_fill_rate(m) := 0;

          -- l_atr := l_atr - c_rec.REQUESTED_QUANTITY;
        end if;

        X_INSUFFICIENT_QTY_LINES_TBL(k).DELIVERY_DETAIL_ID := c_rec
                                                             .DELIVERY_DETAIL_ID;
        X_INSUFFICIENT_QTY_LINES_TBL(k).SOURCE_LINE_ID := c_rec
                                                         .SOURCE_LINE_ID;
        X_INSUFFICIENT_QTY_LINES_TBL(k).source_header_number := c_rec
                                                               .source_header_number;
        X_INSUFFICIENT_QTY_LINES_TBL(k).ORGANIZATION_ID := c_rec
                                                          .ORGANIZATION_ID;
        X_INSUFFICIENT_QTY_LINES_TBL(k).INVENTORY_ITEM_ID := c_rec
                                                            .INVENTORY_ITEM_ID;
        X_INSUFFICIENT_QTY_LINES_TBL(k).REQUESTED_QUANTITY := c_rec
                                                             .REQUESTED_QUANTITY;
        X_INSUFFICIENT_QTY_LINES_TBL(k).requested_quantity_uom := c_rec
                                                                 .requested_quantity_uom;
        X_INSUFFICIENT_QTY_LINES_TBL(k).ship_set_id := c_rec.ship_set_id;
        X_INSUFFICIENT_QTY_LINES_TBL(k).model_id := c_rec.top_model_line_id;

        if v_backorder_flag = 'Y' then
          --Backorder Line

          print_debug('In Backorder Line. Populating the G_backorder_qty_tab and G_backorder_deliv_tab',
                      l_debug);

          G_backorder_qty_tab(k + 1) := X_INSUFFICIENT_QTY_LINES_TBL(k)
                                       .REQUESTED_QUANTITY;
          G_backorder_deliv_tab(k + 1) := X_INSUFFICIENT_QTY_LINES_TBL(k)
                                         .DELIVERY_DETAIL_ID;
          g_dummy_table(k + 1) := null;
          print_debug('Delivery Detail Id ' || ' = ' ||
                      G_backorder_deliv_tab(k + 1),
                      l_debug);
          print_debug('Back Order Qty  ' || ' = ' ||
                      G_backorder_qty_tab(k + 1),
                      l_debug);

        end if;

        if v_reject_order_flag = 'Y' then

          l_insufficient_order_number(k) := X_INSUFFICIENT_QTY_LINES_TBL(k)
                                                        .source_header_number;

        end if;

        --  Storing all the insufficient delivery detail ids in l_insufficient_DD_TBL

        l_insufficient_DD_TBL(k) := X_INSUFFICIENT_QTY_LINES_TBL(k)
                                                      .DELIVERY_DETAIL_ID;

        k := k + 1;

      end if;

      --  end if;
      m := m + 1;

      if l_allocation_method <> 'X' and l_planning_method = 'A' then

        l_atr := l_atr - c_rec.REQUESTED_QUANTITY;

      end if;
      if l_atr < 0 then

        l_atr := 0;

      end if;

    end loop;

  end loop;

  --Planning Action for Credit Check Hold

  if v_credit_check_hold_flag = 'Y' then

    begin
      print_debug('In Credit Check Hold In Plan Wave API', l_debug);
      l_hold_index := 0;


      for l_credit_check in c_credit_check loop

        print_debug('Calling OE_Holds_pub.check_holds from plan_wave API',
                    l_debug);

        OE_HOLDS_PUB.Check_Holds(p_api_version   => 1.0,
                                 p_header_id     => l_credit_check.source_header_id,
                                 p_line_id       => l_credit_check.source_line_id,
                                 p_hold_id       => 1,
                                 p_entity_code   => 'O',
                                 p_entity_id     => NULL,
                                 x_result_out    => l_hold_result,
                                 x_msg_count     => l_msg_count,
                                 x_msg_data      => l_msg_data,
                                 x_return_status => l_return_status);

        if l_return_status = 'S' and l_hold_result = FND_API.G_TRUE then
          print_debug('Credit Check is on hold for Wave Line Id ' ||
                      l_credit_check.wave_line_id || ' in Wave header id ' ||
                      p_wave_header_id,
                      l_debug);
          -- put wave line id in credit_check pl/sql table
          l_credit_check_tbl(l_hold_index) := l_credit_check.wave_line_id;
          l_hold_index := l_hold_index + 1;

        end if;

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;

      end loop;

--    l_tbl_count := l_credit_check_tbl.LAST;
  --  l_table_start := l_credit_check_tbl.FIRST;

     forall c1 in l_credit_check_tbl.FIRST ..l_credit_check_tbl.LAST
 -- for c1 in l_table_start ..l_tbl_count loop dbchange8
        update wms_wp_wave_lines
           set remove_from_wave_flag = 'Y',
               message               = 'Line removed from wave due to credit check hold'
         where wave_line_id = l_credit_check_tbl(c1)
           and wave_header_id = p_wave_header_id
           and nvl(remove_from_wave_flag, 'N') <> 'Y';


      l_credit_check_tbl.delete;
    exception

      when others then
        print_debug('Exception in Credit Check Hold In Plan Wave API',
                    l_debug);
        l_return_status := 'E';
        l_credit_check_tbl.delete;
    end;
    x_return_status := l_return_status;
  end if;

  -- ******* Planning Action for Lines with Insufficient Stock*********
  if X_INSUFFICIENT_QTY_LINES_TBL.count > 0 then

    if v_backorder_flag = 'Y' then
      --Backorder Line

      BEGIN

        print_debug('Calling Shipping API to backorder all  demand lines when sufficient qty is not available',
                    l_debug);

        WSH_SHIP_CONFIRM_ACTIONS2.backorder(p_detail_ids     => G_backorder_deliv_tab,
                                            p_bo_qtys        => G_backorder_qty_tab,
                                            p_req_qtys       => G_backorder_qty_tab,
                                            p_bo_qtys2       => G_dummy_table,
                                            p_overpick_qtys  => G_dummy_table,
                                            p_overpick_qtys2 => G_dummy_table,
                                            p_bo_mode        => 'UNRESERVE',
                                            p_bo_source      => 'PICK',
                                            x_out_rows       => l_out_rows,
                                            x_return_status  => l_return_status);

        print_debug('After call to Backorder API Return Status :' ||
                    l_return_status,
                    l_debug);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_unexpected_error;

        END IF;

        --Delete all entries in the pl/sql table
        G_backorder_deliv_tab.DELETE;
        G_backorder_qty_tab.DELETE;
        G_dummy_table.DELETE;

        x_return_status := l_return_status;
      EXCEPTION
        WHEN OTHERS THEN

          print_debug('Error in Backorder_wdd_for_repl: ' || sqlcode || ',' ||
                      sqlerrm,
                      l_debug);

          --Delete all entries in the pl/sql table
          G_backorder_deliv_tab.DELETE;
          G_backorder_qty_tab.DELETE;
          G_dummy_table.DELETE;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      END;

    end if;

    -- Reject Order Line from the Wave

    if v_reject_line_flag = 'Y' then

      print_debug('In Reject Line', l_debug);

      -- We will be doing bulk update  at the end for this

    end if;

    for i in X_INSUFFICIENT_QTY_LINES_TBL.FIRST .. X_INSUFFICIENT_QTY_LINES_TBL.LAST LOOP

      if v_reject_shipset_flag = 'Y' then
        -- Reject All Lines in Ship Set from Wave

        v_shipset_no := X_INSUFFICIENT_QTY_LINES_TBL(i).SHIP_SET_ID;
        print_debug('Plan Wave Ship Set with Ship Set Number  ' ||
                    v_shipset_no,
                    l_debug);

        OPEN c_shipset;
        FETCH c_shipset BULK COLLECT
          INTO X_DELIVERY_DETAIL_TBL;
        CLOSE c_shipset;

        -- Find all the lines that has the same Ship Set No

          -- l_tbl_count := X_DELIVERY_DETAIL_TBL.count;



        if X_DELIVERY_DETAIL_TBL.count > 0 then
          --forall l in l_table_start .. l_tbl_count   dbchange9
          forall l in X_DELIVERY_DETAIL_TBL.FIRST .. X_DELIVERY_DETAIL_TBL.LAST
            update wms_wp_wave_lines
               set remove_from_wave_flag = 'Y',
                   message               = 'Line removed from wave due to insufficient quantity'
             where delivery_Detail_id = X_DELIVERY_DETAIL_TBL(l)
               and wave_header_id = p_wave_header_id;


          X_DELIVERY_DETAIL_TBL.delete;
        end if;
      end if;

      if v_reject_model_flag = 'Y' then
        -- Reject all lines for the Model from Wave

        --Get the Model number for the lines from WDD based on delivery_detail_id
        --Assuming model to be top_model_line_id --????NEED to confirm with Satish

        v_model_no := X_INSUFFICIENT_QTY_LINES_TBL(i).model_id;
        print_debug('In Reject Model : Model No  ' || v_model_no, l_debug);

        OPEN c_model;
        FETCH c_model BULK COLLECT
          INTO X_DELIVERY_DETAIL_TBL;
        CLOSE c_model;



        if X_DELIVERY_DETAIL_TBL.count > 0 then
          -- Find all the lines that has the same Model No
      -- forall l in l_table_start .. l_tbl_count    dbchange10
         forall l in X_DELIVERY_DETAIL_TBL.FIRST .. X_DELIVERY_DETAIL_TBL.LAST
            update wms_wp_wave_lines
               set remove_from_wave_flag = 'Y',
                   message               = 'Line removed from wave due to insufficient quantity'
             where delivery_Detail_id = X_DELIVERY_DETAIL_TBL(l)
               and wave_header_id = p_wave_header_id;

          X_DELIVERY_DETAIL_TBL.delete;
        end if;
      end if;
    end loop;

    if v_reject_order_flag = 'Y' then
      print_debug('In Reject Order', l_debug);

      -- Reject Entire Order from Wave
     -- forall i3 in l_table_start .. l_tbl_count dbchange11
     forall i3 in l_insufficient_order_number.FIRST .. l_insufficient_order_number.LAST
        update wms_wp_wave_lines
           set remove_from_wave_flag = 'Y',
               message               = 'Line removed from wave due to insufficient quantity'
         where source_header_number = l_insufficient_order_number(i3)
           and wave_header_id = p_wave_header_id
           and nvl(remove_from_wave_flag, 'N') <> 'Y';

      l_insufficient_order_number.delete;
    end if;

    if v_reject_line_flag = 'Y' or v_backorder_flag = 'Y' then

    -- l_tbl_count := l_insufficient_DD_TBL.count;



     --forall i2 in l_table_start .. l_tbl_count dbchange12
    forall i2 in l_insufficient_DD_TBL.FIRST .. l_insufficient_DD_TBL.LAST
        update wms_wp_wave_lines
           set remove_from_wave_flag = 'Y',
               message               = 'Line removed from wave due to insufficient quantity'
         where delivery_Detail_id = l_insufficient_DD_TBL(i2)
           and wave_header_id = p_wave_header_id
           and nvl(remove_from_wave_flag, 'N') <> 'Y';

      l_insufficient_DD_TBL.delete;

    end if;
  END IF;

  if X_SUFFICIENT_QTY_LINES_TBL.count > 0 then

    --Auto create Deliveries for the delivery ids.

    if v_create_delivery_flag = 'Y' then

      begin

        WSH_DELIVERY_DETAILS_PUB.Autocreate_Deliveries(
                                                       -- Standard parameters
                                                       p_api_version_number => 1.0,
                                                       p_init_msg_list      => FND_API.G_FALSE,
                                                       p_commit             => FND_API.G_FALSE,
                                                       x_return_status      => l_return_status,
                                                       x_msg_count          => l_msg_count,
                                                       x_msg_data           => l_msg_data,
                                                       p_line_rows          => l_TabOfDelDets,
                                                       x_del_rows           => l_del_rows);

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

          print_debug('Error returned from Auto Create Deliveries API: ' ||
                      l_return_status,
                      l_debug);

          -- Raise an exception.  The caller will do the rollback, cleanups,
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      exception
        when others then

          print_debug('Error returned from Auto Create Deliveries API: ' ||
                      l_return_status,
                      l_debug);

      end;

    end if;
  end if;

  --Calculate the Planned Fill Rate for the Wave
  /*  WMS_WAVE_PLANNING_PVT.get_line_fill_rate(x_return_status,
                                           p_wave_header_id);
  print_debug('Status after Call to Get the Fill Rate' ||
              x_return_status,
              l_debug); */

  if l_allocation_method in ('C', 'N', 'X') then

    -- Update the crossdock qty in Lines Table

    select delivery_detail_id, crossdocked_quantity bulk collect
      into x_wp_crossdock_tbl
      from wms_wp_rules_simulation
       where wave_header_id=p_wave_header_id;

   -- forall i in indices of x_wp_crossdock_tbl
   if x_wp_crossdock_tbl.count > 0 then
      for i in  x_wp_crossdock_tbl.FIRST .. x_wp_crossdock_tbl.LAST loop
      update wms_wp_wave_lines
         set crossdock_quantity = x_wp_crossdock_tbl(i).crossdock_qty
       where delivery_detail_id = x_wp_crossdock_tbl(i)
      .delivery_detail_id
         and wave_header_id = p_wave_header_id;
  end loop;
end if;
  end if;




  if X_CONSOL_LINES_wave_hdr_id.count > 0 then
   -- forall m2 in l_table_start .. l_tbl_count dbchange13
      forall m2 in X_CONSOL_LINES_wave_hdr_id.FIRST .. X_CONSOL_LINES_wave_hdr_id.LAST
      update wms_wp_wave_lines
         set planned_fill_rate = X_CONSOL_LINES_fill_rate(m2)
       where wave_line_id = X_CONSOL_LINES_wave_line_id(m2);

  end if;

if l_wave_status <> 'Released' then
  print_debug('Before Calling API to Update Wave Status: ', l_debug);
  update_wave_header_status(x_return_status, p_wave_header_id, 'Planned');
end if;
  -- Need to check whether the set up is done else we wont invoke Labor Planning

  print_debug('Return Status after Plan Wave is ' || x_return_status,
              l_debug);

  commit;

  print_debug('Checking if Labor Planning Set up or Department Setup  is done ',
              l_debug);
  select count(1)
    into v_labor_count
    from wms_wp_labor_planning
   where planning_Criteria_id = p_planning_Criteria_id;

  if v_labor_count > 0 and l_enable_labor_planning = 'Y' then

   savepoint labor_planning_sp;

    if l_planning_method = 'A' then

      print_debug('Setup is available for Labor Planning. Calling Availability Check Labor Planning API ',
                  l_debug);

      WMS_WAVE_PLANNING_PVT.labor_planning(p_wave_header_id,
                                           p_planning_criteria_id,
                                           x_return_status);

    elsif l_planning_method = 'R' and
          l_allocation_method in ('C', 'N', 'X') then
      print_debug('Setup is available for Labor Planning. Calling Rule Based  Labor Planning API ',
                  l_debug);

      rules_labor_planning(p_planning_criteria_id,
                           p_wave_header_id,
                           -1,
                           l_organization_id,
                           x_return_status);

  end if;

    if x_return_status <> 'S' then

      rollback to labor_planning_sp;
    else
      commit;
    end if;


  else

    print_debug('Setup is not available for Labor Planning. Please check the Labor Planning  setup',
                l_debug);
    delete from wms_wp_labor_statistics
     where wave_header_id = p_wave_header_id;
    commit;
  end if;

  print_debug('Return Status after Plan Wave is ' || x_return_status,
              l_debug);

 delete from wms_wp_rules_simulation where wave_header_id=p_wave_header_id;
 commit;

exception

  WHEN start_date_exception THEN
    print_debug('START DATE PROBLEM. SO DID NOT PLAN', l_debug);

  when others THEN
    print_debug('Error in Plan Wave API: ' || SQLCODE || ' : ' || SQLERRM,
                l_debug);
                 delete from wms_wp_rules_simulation where wave_header_id=p_wave_header_id;
                 commit;
    x_return_status := FND_API.G_RET_STS_ERROR;

end Plan_Wave;


  -- start time changes
 -- copy entire get_available_capacity

/*function get_resource_capacity(p_wave_start_time  number,
                               p_wave_end_time    number,
                               p_shift_start_time number,
                               p_shift_end_time   number,
                               p_date_diff        number) return number is
  l_debug              NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'),
                                     0);
  wst                  number := p_wave_start_time;
  wet                  number := p_wave_end_time;
  sst                  number := p_shift_start_time;
  shet                 number := p_shift_end_time;
  l_date_diff          number := p_date_diff;
  l_available_capacity number := 0;
  l_start_day_time NUMBER := 0;
  l_end_day_time NUMBER := 0;
begin

  print_debug('In get_resource_capacity function',l_debug);
  if (l_date_diff) >= 1 then
    -- utilization on the first day
    -- NO NEED TO CHECK AGAIN. THIS PART IS OKAY.
    if wst > sst THEN
      IF shet > wst THEN
        l_start_day_time := shet - wst;
        print_debug('l_start_day_time(1) := ' || l_start_day_time, l_debug);
      ELSE
        l_start_day_time := 0;
        print_debug('l_start_day_time(1) := ' || l_start_day_time, l_debug);
      END IF;
    elsif wst <= sst then
      l_start_day_time := shet - sst;
      print_debug('l_start_day_time(2) := ' || l_start_day_time, l_debug);
    end if;
    -- utilization on the last day
    -- NO NEED TO CHECK AGAIN. THIS PART IS OKAY.
    if wet >= shet then
      l_end_day_time := shet - sst;
      print_debug('l_end_day_time(1) := ' || l_end_day_time, l_debug);
    elsif wet < shet THEN
      IF wet > sst THEN
        l_end_day_time := wet - sst;
        print_debug('l_end_day_time(2) := ' || l_end_day_time, l_debug);
      ELSE
        l_end_day_time := 0;
        print_debug('l_end_day_time(2) := ' || l_end_day_time, l_debug);
      END IF;
    end if;

    l_available_capacity := l_available_capacity + l_end_day_time +
                            l_start_day_time +
                            ((l_date_diff) - 1) * (shet - sst);
    print_debug('l_daily_capacity := ' ||
                ((l_date_diff) - 1) * (shet - sst),
                l_debug);
    print_debug('l_available_capacity := ' || l_available_capacity,
                l_debug);

  elsif (l_date_diff) = 0 THEN
    IF (wst BETWEEN sst AND shet) OR (wet BETWEEN sst AND shet) or
       (wst < sst and wet > shet) then
      IF wst > sst THEN
        IF wet >= shet THEN
          l_available_capacity := (shet - wst);
          print_debug('l_available_capacity1 := ' || l_available_capacity,
                      l_debug);
        ELSIF wet < shet THEN
          l_available_capacity := (wet - wst);
          print_debug('l_available_capacity2 := ' || l_available_capacity,
                      l_debug);
        END IF;
      ELSIF wst <= sst THEN
        IF wet >= shet THEN
          l_available_capacity := (shet - sst);
          print_debug('l_available_capacity3 := ' || l_available_capacity,
                      l_debug);
        ELSIF wet < shet THEN
          l_available_capacity := (wet - sst);
          print_debug('l_available_capacity4 := ' || l_available_capacity,
                      l_debug);
        END IF;
      END IF;
    END IF;
  end if;
  print_debug('End of get_resource_capacity function',l_debug);
  return l_available_capacity;

exception
  when others then
    print_debug('Error in get_resource_capacity function', l_debug);
    return - 1;
end;
*/
 function get_resource_capacity(p_wave_start_time  number,
                               p_wave_end_time    number,
                               p_shift_start_time number,
                               p_shift_end_time   number,
                               p_date_diff        number) return number is
  l_debug              NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'),
                                     0);
  wst                  number := p_wave_start_time;
  wet                  number := p_wave_end_time;
  sst                  number := p_shift_start_time;
  shet                 number := p_shift_end_time;
  l_date_diff          number := p_date_diff;
  l_available_capacity number := 0;
  l_start_day_time NUMBER := 0;
  l_end_day_time NUMBER := 0;
begin

  print_debug('In get_resource_capacity function',l_debug);
  if (l_date_diff) >= 1 then
    -- utilization on the first day
    -- NO NEED TO CHECK AGAIN. THIS PART IS OKAY.
    if shet > sst then
    if wst > sst THEN
      IF shet > wst THEN
        l_start_day_time := shet - wst;
        print_debug('l_start_day_time(1) := ' || l_start_day_time, l_debug);
      ELSE
        l_start_day_time := 0;
        print_debug('l_start_day_time(1) := ' || l_start_day_time, l_debug);
      END IF;
    elsif wst <= sst then
      l_start_day_time := shet - sst;
      print_debug('l_start_day_time(2) := ' || l_start_day_time, l_debug);
    end if;
    -- utilization on the last day
    -- NO NEED TO CHECK AGAIN. THIS PART IS OKAY.
    if wet >= shet then
      l_end_day_time := shet - sst;
      print_debug('l_end_day_time(1) := ' || l_end_day_time, l_debug);
    elsif wet < shet THEN
      IF wet > sst THEN
        l_end_day_time := wet - sst;
        print_debug('l_end_day_time(2) := ' || l_end_day_time, l_debug);
      ELSE
        l_end_day_time := 0;
        print_debug('l_end_day_time(2) := ' || l_end_day_time, l_debug);
      END IF;
    end if;

    l_available_capacity := l_available_capacity + l_end_day_time +
                            l_start_day_time +
                            ((l_date_diff) - 1) * (shet - sst);

    elsif shet < sst then
    -- start day calculation
      if wst > sst then
         l_start_day_time := 1440 - wst;
      elsif wst < sst then
         l_start_day_time := 1440 - sst;
      end if;

    -- end day calculation
      if wet > shet then
        l_end_day_time := shet;
      elsif wet < shet then
	l_end_day_time := wet;
      end if;

    l_available_capacity := l_available_capacity + l_end_day_time +
                            l_start_day_time +
                            ((l_date_diff) - 1) * ((1440 - sst) + shet);
    end if;
    print_debug('l_daily_capacity := ' ||
                ((l_date_diff) - 1) * (shet - sst),
                l_debug);
    print_debug('l_available_capacity := ' || l_available_capacity,
                l_debug);

  elsif (l_date_diff) = 0 THEN
    IF (wst BETWEEN sst AND shet) OR (wet BETWEEN sst AND shet) or
       (wst < sst and wet > shet) then
      IF wst > sst THEN
        IF wet >= shet THEN
          l_available_capacity := (shet - wst);
          print_debug('l_available_capacity1 := ' || l_available_capacity,
                      l_debug);
        ELSIF wet < shet THEN
          l_available_capacity := (wet - wst);
          print_debug('l_available_capacity2 := ' || l_available_capacity,
                      l_debug);
        END IF;
      ELSIF wst <= sst THEN
        IF wet >= shet THEN
          l_available_capacity := (shet - sst);
          print_debug('l_available_capacity3 := ' || l_available_capacity,
                      l_debug);
        ELSIF wet < shet THEN
          l_available_capacity := (wet - sst);
          print_debug('l_available_capacity4 := ' || l_available_capacity,
                      l_debug);
        END IF;
      END IF;
    END IF;
  end if;
  print_debug('End of get_resource_capacity function',l_debug);
  return l_available_capacity;

exception
  when others then
    print_debug('Error in get_resource_capacity function', l_debug);
    return - 1;
end;

function get_available_capacity(p_resource_id     number,
                                p_dept_id         number,
                                p_start_date      date, -- start time changes
                                p_target_date     date,
                                p_24hrs           number,
                                p_org_id          number,
                                l_unit_of_measure in varchar2)
  return NUMBER is

  l_instance_count     number := 0;
  l_available_capacity number := 0;
  l_day_diff           NUMBER;
  l_temp_capacity      number := 0;
  l_debug              NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'),
                                     0);

  wst              number := round((p_start_date - trunc(p_start_date)) * 24 * 60);
  wet              number := round((p_target_date - trunc(p_target_date)) * 24 * 60);
  shet             number := 0;
  sst              number := 0;
  l_date_diff      number := 0;
  l_start_day_time number := 0;
  l_end_day_time   number := 0;
  resource_capacity_exception exception;
  l_conv_rate NUMBER;

  cursor c_shift is
    SELECT distinct round(bst.to_time / 60) end_time,
                    round(bst.from_time / 60) start_time,
                    nvl(brs.CAPACITY_UNITS, 0) cap_units,
                    brs.shift_num shift_num
      from bom_resource_shifts brs,
           mtl_parameters      mp,
           bom_shift_dates     bsd,
           bom_shift_times     bst
     where brs.department_id = p_dept_id
       and brs.resource_id = p_resource_id
       and mp.organization_id = p_org_id
       and mp.calendar_code = bsd.calendar_code
       and mp.calendar_exception_set_id = bsd.exception_set_id
       and brs.shift_num = bsd.shift_num
       --and bsd.shift_date BETWEEN Trunc(SYSDATE) AND Trunc(SYSDATE + 1)
       and bsd.seq_num is not null
       and bst.shift_num = bsd.shift_num
       and bst.calendar_code = bsd.calendar_code
     order BY brs.shift_num;

  type shift_details_record is record(
    end_time   number,
    start_time number,
    cap_units  number,
    shift_num  number);
  TYPE shift_tbl IS TABLE OF shift_details_record INDEX BY BINARY_INTEGER;
  l_shift_tbl shift_tbl;

BEGIN
  print_debug('p_start_date := ' ||
              To_Char(p_start_date, 'DD-MON-RRRR HH24:MI:SS'),
              l_debug);
  print_debug('p_target_date := ' ||
              To_Char(p_target_date, 'DD-MON-RRRR HH24:MI:SS'),
              l_debug);

  print_debug('wst := ' || wst, l_debug);
  print_debug('wet := ' || wet, l_debug);

  l_date_diff := trunc(p_target_date) - trunc(p_start_date);

  print_debug('l_date_diff := ' || l_date_diff, l_debug);

  if (p_24hrs = 1) then
    print_debug('P_24HRS = 1 ===> available 24 hrs', l_debug);
    select count(*)
      into l_instance_count
      from BOM_DEPT_RES_INSTANCES
     WHERE resource_id = p_resource_id
       and department_id = p_dept_id;

    l_temp_capacity := wms_wave_planning_pvt.get_resource_capacity(wst,
                                                                   wet,
                                                                   0,
                                                                   1440,
                                                                   l_date_diff);

    if l_temp_capacity = -1 then
      raise resource_capacity_exception;
    end if;

    l_available_capacity := l_instance_count * l_temp_capacity; -- in minutes

  elsif (p_24hrs = 2) then
    print_debug('P_24HRS = 2 ===> available in shifts', l_debug);
    l_available_capacity := 0;

    open c_shift;
    fetch c_shift BULK collect
      into l_shift_tbl;

    for i in l_shift_tbl.first .. l_shift_tbl.last loop

      shet := l_shift_tbl(i).end_time;
      sst  := l_shift_tbl(i).start_time;
      print_debug('shet := ' || shet,l_debug);
      print_debug('sst := ' || sst,l_debug);

      l_temp_capacity := wms_wave_planning_pvt.get_resource_capacity(wst,
                                                                     wet,
                                                                     sst,
                                                                     shet,
                                                                     l_date_diff);
      if l_temp_capacity = -1 then
        raise resource_capacity_exception;
      end if;

      l_available_capacity := l_available_capacity +
                              (l_temp_capacity * l_shift_tbl(i).cap_units);

    end loop;

  end if;
  print_debug('l_available_capacity before conversion := ' || l_available_capacity, l_debug);
  l_conv_rate := round(wms_wave_planning_pvt.get_conversion_rate(null,

                                                                 'MIN',

                                                                 l_unit_of_measure));

print_debug('Conversion rat ='||l_conv_rate,l_debug);

  l_available_capacity := l_conv_rate *  l_available_capacity;
  print_debug('l_available_capacity after conversion := ' || l_available_capacity, l_debug);

  print_debug('End of get_available_capacity function',l_debug);

  return l_available_capacity;

EXCEPTION
  WHEN resource_capacity_exception THEN
    print_debug('Error from get_resource_capacity function',l_debug);
    return - 1;
  WHEN OTHERS THEN
    print_debug('Unknown Error in get_available_capacity function',l_debug);
    return - 1;

end get_available_capacity;



   procedure get_current_work_load(p_resource             in varchar2,
                                p_planning_criteria_id in number,
                                p_wave_header_id       in number,
                                x_current_workload     out nocopy number,
                                x_resource_type        out nocopy NUMBER,
                                x_number_of_tasks      OUT nocopy NUMBER,
                                x_total_capacity       out nocopy NUMBER) IS
  -- start time changes

  cursor c_resource_details is
    select source_subinventory,
           destination_subinventory,
           pick_uom,
           transaction_time,
           travel_time,
           processing_overhead_duration
      from wms_wp_labor_planning
     where planning_criteria_id = p_planning_criteria_id
       and resource_type = p_resource;

  l_unit_of_measure      varchar2(10);
  l_uom                  varchar2(10);
  l_capacity_units       number := 0;
  l_current_workload     number := 0;
  l_transaction_quantity number := 0;
  l_resource_type        number := 0; -- 1 => machine  2 => person
  l_load                 number := 0;
  l_utilization          number;
  l_efficiency           number;
  l_number_of_tasks      NUMBER := 0;
  l_tasks                NUMBER := 0;
  l_resource_id          number := 0;
  l_dept_id              number := 0;
  l_target_date          date;
  l_org_id               number;
  l_24hrs                number;
  l_debug                NUMBER := nvl(fnd_profile.VALUE('INV_DEBUG_TRACE'),
                                       0);
  l_total_capacity       NUMBER;
  l_LABOR_SETUP_MODE     varchar2(1); -- ssk
  l_start_date           DATE; -- start time changes
  st_exception EXCEPTION; -- start time changes

begin
-- ssk
select LABOR_SETUP_MODE into l_LABOR_SETUP_MODE from wms_wp_planning_criteria_vl
where PLANNING_CRITERIA_ID = p_planning_criteria_id;
-- ssk
  select department_id
    into l_dept_id
    from wms_wp_planning_criteria_vl
   where planning_criteria_id = p_planning_criteria_id;
  print_debug('In get_current_work_load procedure', l_debug);
  select (nvl(utilization, 100) / 100),
         (nvl(efficiency, 100) / 100),
         capacity_units,
         unit_of_measure,
         resource_id,
         ORGANIZATION_ID,
         AVAILABLE_24_HOURS_FLAG
    into l_utilization,
         l_efficiency,
         l_capacity_units,
         l_unit_of_measure,
         l_resource_id,
         l_org_id,
         l_24hrs
    from bom_department_resources_v
   where department_id = l_dept_id
     and resource_code = p_resource;

  l_current_workload := 0;

  for l_resource_details in c_resource_details loop
  if l_labor_setup_mode = 'S' then
    begin
      select sum(mmtt.transaction_quantity), Count(*), br.resource_type
        into l_transaction_quantity, l_number_of_tasks, l_resource_type
        from bom_resources                  br,
             mtl_material_transactions_temp mmtt,
             wms_dispatched_tasks           wdt
       where mmtt.subinventory_code =
             l_resource_details.source_subinventory
         and mmtt.transfer_subinventory =
             l_resource_details.destination_subinventory
         and mmtt.transaction_uom = l_resource_details.pick_uom
         and mmtt.transaction_temp_id = wdt.transaction_temp_id(+)
         and wdt.person_resource_id = br.resource_id(+)
         and br.resource_code = p_resource
       group by br.resource_type;
    exception
      when no_data_found then
        l_transaction_quantity := 0;
        SELECT resource_type
          INTO l_resource_type
          FROM bom_resources
         WHERE resource_code = p_resource
           AND resource_id IN
               (SELECT DISTINCT resource_id
                  FROM BOM_DEPARTMENT_RESOURCES
                 WHERE department_id IN
                       (SELECT DISTINCT department_id
                          FROM wms_wp_planning_criteria_vl
                         WHERE planning_criteria_id = p_planning_criteria_id));
    end;
    elsif l_labor_setup_mode = 'Z' then
    begin
      select sum(mmtt.transaction_quantity), Count(*), br.resource_type
        into l_transaction_quantity, l_number_of_tasks, l_resource_type
        from bom_resources                  br,
             mtl_material_transactions_temp mmtt,
             wms_dispatched_tasks           wdt,
	     wms_zone_locators              wzl1,
           wms_zone_locators              wzl2,
           wms_zones_vl                   wz1,
           wms_zones_vl                   wz2
       where wz1.zone_name =
             l_resource_details.source_subinventory
         and wz2.zone_name =
             l_resource_details.destination_subinventory
	and mmtt.locator_id = wzl1.inventory_location_id
       and mmtt.transfer_to_location = wzl2.inventory_location_id
       and mmtt.organization_id = wzl1.organization_id
       and mmtt.organization_id = wzl2.organization_id
       and wz1.zone_id = wzl1.zone_id
       and wz2.zone_id = wzl2.zone_id
       and wz1.zone_type = 'L'
       and wz2.zone_type = 'L'
         and mmtt.transaction_uom = l_resource_details.pick_uom
         and mmtt.transaction_temp_id = wdt.transaction_temp_id(+)
         and wdt.person_resource_id = br.resource_id(+)
         and br.resource_code = p_resource
       group by br.resource_type;
    exception
      when no_data_found then
        l_transaction_quantity := 0;
        SELECT resource_type
          INTO l_resource_type
          FROM bom_resources
         WHERE resource_code = p_resource
           AND resource_id IN
               (SELECT DISTINCT resource_id
                  FROM BOM_DEPARTMENT_RESOURCES
                 WHERE department_id IN
                       (SELECT DISTINCT department_id
                          FROM wms_wp_planning_criteria_vl
                         WHERE planning_criteria_id = p_planning_criteria_id));
                         END;
    end if;
    l_tasks := l_tasks + l_number_of_tasks;
    print_debug('current load = ' || l_current_workload, l_debug);
    print_debug('l_transaction_quantity = ' || l_transaction_quantity,
                l_debug);
    IF (l_transaction_quantity > 0) then
      l_load             := (l_transaction_quantity *
                            nvl(l_resource_details.transaction_time,0)) +
                            nvl(l_resource_details.travel_time,0) + nvl(l_resource_details.processing_overhead_duration,0);
      l_current_workload := l_current_workload + l_load;
      print_debug('current load = ' || l_current_workload, l_debug);
    END IF;
  end loop;

  select time_uom
    into l_uom
    from wms_wp_planning_criteria_vl
   where planning_Criteria_id = p_planning_criteria_id;

  x_current_workload := round((l_current_workload) /
                              (l_utilization * l_efficiency));
  x_resource_type    := l_resource_type;
  x_number_of_tasks  := l_tasks;

  SELECT MAX(nvl(wdab.end_time,
                 (nvl(wts.planned_departure_date,
                      nvl(wnd.latest_pickup_date, wdd.date_scheduled)))))
    into l_target_date
    FROM wms_wp_wave_lines        wwl,
         wsh_delivery_details     wdd,
         wsh_delivery_assignments wda,
         wsh_new_deliveries       wnd,
         wsh_delivery_legs        wdl,
         wsh_trip_stops           wts,
         wms_dock_appointments_b  wdab
   WHERE wwl.organization_id = l_org_id
     AND wwl.wave_header_id = p_wave_header_id
     AND wwl.delivery_detail_id = wdd.delivery_detail_id
     AND wdd.delivery_detail_id = wda.delivery_detail_id
     AND wda.delivery_id = wnd.delivery_id(+)
     AND wnd.delivery_id = wdl.delivery_id(+)
     AND wdl.pick_up_stop_id = wts.stop_id(+)
     AND wts.stop_id = wdab.trip_stop(+);

  -- start time changes start
  SELECT start_time
    INTO l_start_date
    FROM wms_wp_wave_headers_vl
   WHERE wave_header_id = p_wave_header_id;
  print_debug('start_time = ' || l_start_date, l_debug);

  -- start time changes end

  l_total_capacity := get_available_capacity(l_resource_id,
                                             l_dept_id,
                                             l_start_date, -- start time changes
                                             l_target_date,
                                             l_24hrs,
                                             l_org_id,
                                             l_unit_of_measure);

  x_total_capacity := round(round(l_total_capacity *

                                  wms_wave_planning_pvt.get_conversion_rate(null,

                                                                            l_unit_of_measure,

                                                                            l_uom)));

  print_debug('resource is ' || p_resource, l_debug);
  print_debug('current_workload = ' || x_current_workload, l_debug);
  print_debug('resource_type = ' || x_resource_type, l_debug);
  print_debug('no of tasks = ' || x_number_of_tasks, l_debug);
  print_debug('x_total_capacity = ' || x_total_capacity, l_debug);

EXCEPTION
  when others then
    print_debug('Error in get_current_workload function' || ':' || SQLCODE || ':' ||
                SQLERRM,
                l_debug);
end get_current_work_load;


  /*FUNCTION get_next_resource(j                          NUMBER,
                             p_source_subinventory      VARCHAR2,
                             p_destination_subinventory VARCHAR2,
                             p_uom                      VARCHAR2,
                             p_resource_type            NUMBER) RETURN NUMBER IS
    i               number := j + 1;
    l_found         NUMBER := 0;
    l_next_resource NUMBER := -1;
    l_debug         NUMBER := nvl(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    if p_resource_type = 2 then
      while i < x_labor_dtl_tbl.count loop
        if x_labor_dtl_tbl(i).source_subinventory = p_source_subinventory AND
           x_labor_dtl_tbl(i)
        .destination_subinventory = p_destination_subinventory AND
           x_labor_dtl_tbl(i).pick_uom = p_uom AND x_labor_dtl_tbl(i)
        .resource_type = p_resource_type then
          l_found         := 1;
          l_next_resource := i;
          exit;
        ELSE
          i := i + 1;
        end if;
      end loop;

    elsif p_resource_type = 1 then
      while i < x_machine_dtl_tbl.count loop
        if x_machine_dtl_tbl(i).source_subinventory = p_source_subinventory AND
           x_machine_dtl_tbl(i)
        .destination_subinventory = p_destination_subinventory AND
           x_machine_dtl_tbl(i).pick_uom = p_uom AND x_machine_dtl_tbl(i)
        .resource_type = p_resource_type then
          l_found         := 1;
          l_next_resource := i;
          exit;
        ELSE
          i := i + 1;
        end if;
      end loop;
    end if;

    if l_found = 1 then
      return l_next_resource;
    ELSE
      return - 1;
    end if;

  EXCEPTION
    WHEN OTHERS THEN
      print_debug('Error in get_next_resource function ' || ':' || SQLCODE || ':' ||
                  SQLERRM,
                  l_debug);
  END;

  procedure sync_machine_person_time(p_planned_load             number,
                                     p_planned_tasks            number,
                                     p_source_subinventory      varchar2,
                                     p_destination_subinventory varchar2,
                                     p_uom                      varchar2) is

    l_debug              NUMBER := nvl(fnd_profile.VALUE('INV_DEBUG_TRACE'),
                                       0);
    l_planned_load       number := p_planned_load;
    l_planned_tasks      number := p_planned_tasks;
    l_resource_type      number := 1; -- hard coded. should not be changed
    l_completed          number := 0;
    l_temp_planned_tasks number := 0;
    j                    number := 0;
    j_temp               number := 0;
    i                    number := 0;

  begin
    print_debug('In sync_machine_person_time api', l_debug);
    print_debug('planned load passed to this api is ' || p_planned_load,
                l_debug);
    print_debug('planned tasks passed to this api are ' || p_planned_tasks,
                l_debug);
    print_debug('number of machines available are ' ||
                x_machine_dtl_tbl.count,
                l_debug);

    if x_machine_dtl_tbl.count > 0 then
      -- only if machines are available enter the below loops.
      while i < x_machine_dtl_tbl.count and l_completed <> 1 loop
        -- i should be incremented manually
        if x_machine_dtl_tbl(i).source_subinventory = p_source_subinventory and
           x_machine_dtl_tbl(i)
        .destination_subinventory = p_destination_subinventory and
           x_machine_dtl_tbl(i).pick_uom = p_uom then

          print_debug('The machine is ' || x_machine_dtl_tbl(i)
                      .resource_name,
                      l_debug);
          j := 0;

          while j < x_labor_stats_tbl.count loop
            -- j should be incremented manually
            if x_machine_dtl_tbl(i).resource_name = x_labor_stats_tbl(j)
            .resource_name then

              if x_labor_stats_tbl(j)
              .available_capacity > 0 and x_labor_stats_tbl(j)
              .available_capacity >= l_planned_load then
                print_debug('This machine resource can take the entire load',
                            l_debug);
                print_debug('available capacity for the resource is ' ||
                            x_labor_stats_tbl(j).available_capacity,
                            l_debug);
                x_labor_stats_tbl(j).planned_wave_load := x_labor_stats_tbl(j)
                                                         .planned_wave_load +
                                                          l_planned_load;
                x_labor_stats_tbl(j).number_of_planned_tasks := x_labor_stats_tbl(j)
                                                               .number_of_planned_tasks + 1;
                x_labor_stats_tbl(j).available_capacity := x_labor_stats_tbl(j)
                                                          .available_capacity -
                                                           l_planned_load;
                print_debug('available capacity after load assignmentfor the resource is ' ||
                            x_labor_stats_tbl(j).available_capacity,
                            l_debug);
                print_debug('Planned tasks for the resource is ' ||
                            x_labor_stats_tbl(j).number_of_planned_tasks,
                            l_debug);

                l_completed := 1;
                j           := x_labor_stats_tbl.count + 5;
                exit;

              elsif x_labor_stats_tbl(j)
              .available_capacity > 0 and x_labor_stats_tbl(j)
              .available_capacity < l_planned_load then
                print_debug('This machine resource can take the partial load',
                            l_debug);
                i := get_next_resource(i,
                                       p_source_subinventory,
                                       p_destination_subinventory,
                                       p_uom,
                                       l_resource_type);

                if i = -1 then
                  print_debug('available capacity for the resource is ' ||
                              x_labor_stats_tbl(j).available_capacity,
                              l_debug);
                  x_labor_stats_tbl(j).planned_wave_load := x_labor_stats_tbl(j)
                                                           .planned_wave_load +
                                                            l_planned_load;
                  x_labor_stats_tbl(j).number_of_planned_tasks := x_labor_stats_tbl(j)
                                                                 .number_of_planned_tasks + 1;
                  x_labor_stats_tbl(j).available_capacity := x_labor_stats_tbl(j)
                                                            .available_capacity -
                                                             l_planned_load;
                  print_debug('available capacity after load assignmentfor the resource is ' ||
                              x_labor_stats_tbl(j).available_capacity,
                              l_debug);
                  print_debug('Planned tasks for the resource is ' ||
                              x_labor_stats_tbl(j).number_of_planned_tasks,
                              l_debug);

                  l_completed := 1;
                  j           := x_labor_stats_tbl.count + 5;
                  i           := x_machine_dtl_tbl.count + 5;
                  exit;
                else
                  print_debug('available capacity for the resource is ' ||
                              x_labor_stats_tbl(j).available_capacity,
                              l_debug);
                  x_labor_stats_tbl(j).planned_wave_load := x_labor_stats_tbl(j)
                                                           .planned_wave_load +
                                                            x_labor_stats_tbl(j)
                                                           .available_capacity;
                  x_labor_stats_tbl(j).number_of_planned_tasks := x_labor_stats_tbl(j)
                                                                 .number_of_planned_tasks + 1;
                  l_planned_load := l_planned_load - x_labor_stats_tbl(j)
                                   .available_capacity;
                  x_labor_stats_tbl(j).available_capacity := 0;
                  print_debug('available capacity after load assignmentfor the resource is ' ||
                              x_labor_stats_tbl(j).available_capacity,
                              l_debug);
                  print_debug('Planned tasks for the resource is ' ||
                              x_labor_stats_tbl(j).number_of_planned_tasks,
                              l_debug);

                  j := x_labor_stats_tbl.count + 5;
                end if;
              elsif x_labor_stats_tbl(j).available_capacity <= 0 then
                print_debug('This machine resource can take the partial load',
                            l_debug);
                i := get_next_resource(i,
                                       p_source_subinventory,
                                       p_destination_subinventory,
                                       p_uom,
                                       l_resource_type);

                if i = -1 then
                  print_debug('available capacity for the resource is ' ||
                              x_labor_stats_tbl(j).available_capacity,
                              l_debug);
                  x_labor_stats_tbl(j).planned_wave_load := x_labor_stats_tbl(j)
                                                           .planned_wave_load +
                                                            l_planned_load;
                  x_labor_stats_tbl(j).number_of_planned_tasks := x_labor_stats_tbl(j)
                                                                 .number_of_planned_tasks + 1;
                  x_labor_stats_tbl(j).available_capacity := x_labor_stats_tbl(j)
                                                            .available_capacity -
                                                             l_planned_load;
                  print_debug('available capacity after load assignmentfor the resource is ' ||
                              x_labor_stats_tbl(j).available_capacity,
                              l_debug);
                  print_debug('Planned tasks for the resource is ' ||
                              x_labor_stats_tbl(j).number_of_planned_tasks,
                              l_debug);

                  l_completed := 1;
                  j           := x_labor_stats_tbl.count + 5;
                  i           := x_machine_dtl_tbl.count + 5;
                  exit;
                else
                  j := x_labor_stats_tbl.count + 5;
                end if;
              end if;

            else
              j := j + 1;
            end if;
          end loop;
        else
          i := i + 1;
        end if;
      end loop;

    end if;

  exception
    when others then
      print_debug('error in sync_machine_person_time api ' || ':' ||
                  SQLCODE || ':' || SQLERRM,
                  l_debug);
  end;
*/


  /*
  API to Calculate Labor Planning and Resource Allocation.


  */
 procedure labor_planning(p_wave_header_id       in number,
                         p_planning_criteria_id in number,
                         x_return_status        OUT NOCOPY varchar2) is

  v_replenishment_required   varchar2(1) := 'N';
  v_picking_subinventory     varchar2(4000);
  v_destination_subinventory varchar2(4000);
  L_ORG_ID                   NUMBER;
  L_ITEM_ID                  NUMBER;
  tbl_index                  number := 0;
  l_att                      number;
  l_bulk_planning            varchar2(1);
  n                          number := 0;
  v_department_id            number;
  v_time_uom                 VARCHAR2(10);
  l_allocation_method        varchar2(20);

  --  commented below code as it being declared in specification

  /*  TYPE labor_statistics_Record IS RECORD(
    resource_name           varchar2(100),
    total_time_per_Resource NUMBER DEFAULT 0,
    planned_wave_load       NUMBER DEFAULT 0,
    total_Capacity          NUMBER DEFAULT 0,
    current_workload number default 0, --
    number_of_tasks  NUMBER DEFAULT 0,  --
    resource_type number, --
    available_capacity NUMBER DEFAULT 0); --

  TYPE labor_stats_tbl IS TABLE OF labor_statistics_Record INDEX BY BINARY_INTEGER;

  x_labor_stats_tbl labor_stats_tbl;   */

  cursor c_labor_lines is
    select DISTINCT wwl.organization_id,
                    wwl.inventory_item_id,
                    wwh.pull_replenishment_flag pull_replenishment_flag,
                    wwl.wave_line_id,
                    (wwl.requested_quantity - wwl.crossdock_quantity) requested_quantity
      from wms_wp_wave_headers_vl wwh, wms_wp_wave_lines wwl,wsh_delivery_details wdd
     where wwh.wave_header_id = p_wave_header_id
       and wwh.wave_header_id = wwl.wave_header_id
       AND Nvl(wwl.remove_from_Wave_flag, 'N') <> 'Y'
       AND wwl.inventory_item_id = l_item_id
       and wwl.organization_id = l_org_id
          and wwl.delivery_detail_id=wdd.delivery_detail_id
     and wdd.released_status in ('R','B') --- For Hot Order Changes
     ORDER BY inventory_item_id, wave_line_id;

  cursor c_item is
    SELECT DISTINCT wwl.inventory_item_id, wwl.organization_id
      FROM wms_wp_wave_lines wwl,wsh_delivery_Details wdd
     WHERE wave_header_id = p_wave_header_id
     and wwl.delivery_detail_id=wdd.delivery_detail_id
     and wdd.released_status in ('R','B') --- For Hot Order Changes
       AND Nvl(remove_from_Wave_flag, 'N') <> 'Y';

  cursor c_subinventories is
    select DISTINCT MSI.SECONDARY_INVENTORY_NAME,
                    moqd.SUBINVENTORY_CODE,
                    wms_wave_planning_pvt.get_source_subinventory(MSIB.INVENTORY_ITEM_id,
                                                                  MSI.SECONDARY_INVENTORY_NAME) source_subinventory,
                    MSI.PICK_UOM_CODE,
                    wms_wave_planning_pvt.get_conversion_rate(MSIB.INVENTORY_ITEM_id,
                                                              MSI.PICK_UOM_CODE,
                                                              MSIB.PRIMARY_UOM_CODE) AS CONVERSION_RATE,
                    MSI.PICKING_ORDER
      from MTL_SECONDARY_INVENTORIES    MSI,
           MTL_SYSTEM_ITEMS_B           MSIB,
           mtl_onhand_quantities_Detail moqd
     WHERE MSIB.organization_id = l_org_id
       and MSIB.INVENTORY_ITEM_ID = l_item_id
       AND MSI.PICK_UOM_CODE IS NOT NULL
       AND (MSI.SECONDARY_INVENTORY_NAME = v_picking_subinventory or
           v_picking_subinventory is null)
       AND wms_wave_planning_pvt.get_conversion_rate(MSIB.INVENTORY_ITEM_id,
                                                     MSI.PICK_UOM_CODE,
                                                     MSIB.PRIMARY_UOM_CODE) > 0
       AND moqd.INVENTORY_ITEM_id = MSIB.INVENTORY_ITEM_id
       AND moqd.ORGANIZATION_ID = MSIB.ORGANIZATION_ID
       AND moqd.SUBINVENTORY_CODE = msi.SECONDARY_INVENTORY_NAME
       AND moqd.ORGANIZATION_ID = msi.ORGANIZATION_ID
     ORDER BY CONVERSION_RATE DESC, MSI.PICKING_ORDER;

  cursor c_labor_time is
    SELECT source_subinventory,
           destination_subinventory,
           pick_uom,
           transaction_time,
           travel_time,
           resource_type
      FROM wms_wp_labor_planning
     WHERE planning_criteria_id = p_planning_criteria_id
     group by source_subinventory,
              destination_subinventory,
              pick_uom,
              transaction_time,
              travel_time,
              resource_type; -- group by added by

  cursor c_labor_resource is
    SELECT distinct resource_type
      FROM wms_wp_labor_planning
     WHERE planning_criteria_id = p_planning_criteria_id;

  /*  cursor c_labor_resource is
  SELECT distinct wwlp.resource_type
    FROM wms_wp_labor_planning wwlp,BOM_DEPARTMENT_RESOURCES_V bdr,wms_wp_planning_criteria_vl wwp
   WHERE wwlp.planning_criteria_id =  p_planning_criteria_id
   AND wwp.planning_criteria_id=wwlp.planning_criteria_id
   and wwp.department_id=v_department_id
   and wwp.department_id=bdr.department_id
   and wwlp.resource_type=bdr.resource_code
   AND (bdr.AVAILABLE_24_HOURS_FLAG=2
   OR (SELECT Count(1) FROM BOM_DEPT_RES_INSTANCES WHERE resource_id= bdr.resource_id AND department_id=bdr.department_id) > 0);*/

  TYPE ITEM_TBL IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

  x_item_tbl ITEM_TBL;

  L_DEMAND_QTY NUMBER;

  l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

  l_return_status VARCHAR2(3) := fnd_api.g_ret_sts_success;

  v_total_labor_time number := 0;

  travel_time_idx number;
  n2              number := 0;
  /*  CURSOR c_dept is
  SELECT RESOURCE_code,
         (nvl(utilization, 100) / 100) utilization,
         (nvl(efficiency, 100) / 100) efficiency,
         unit_of_measure,
         capacity_units
    FROM BOM_DEPARTMENT_RESOURCES_V
   WHERE department_id = v_department_id; */

  --  declare variables
  x_current_load            number := 0;
  x_resource_type           number := 0;
  x_number_of_tasks         NUMBER := 0;
  x_total_capacity          NUMBER := 0;
  l_dd_qty                  NUMBER := 0;
  l_person_found            NUMBER := 0;
  l_avail_capacity          NUMBER := 0;
  l_utilization             NUMBER := 0;
  l_efficiency              NUMBER := 0;
  l_number_of_capable_units NUMBER := 0;
  l_accept_load             NUMBER := 0;
  j                         NUMBER := 0;
  l_completed               NUMBER := 0;
  j_temp                    NUMBER := 0;
  l_resource_type           NUMBER := 2; -- Never ever change this declaration. Problematic
  lab_dtl                   NUMBER := 0;
  l_planned_load            NUMBER := 0;
  k                         NUMBER := 0;
  --  declared variables
  l_other_wdd_qty    number := 0;
  l_temp_value       number;
  l_reserved_qty     number;
  l_crossdock_qty    number;
  l_current_position NUMBER := 0;
  l_tbl_count number;
begin

  print_debug('Labor Planning API entered -------> ', l_debug);

  select wwp.picking_subinventory,
         wwp.destination_subinventory,
         bulk_labor_planning_flag,
         department_id,
         time_uom,
         allocation_method
    into v_picking_subinventory,
         v_destination_subinventory,
         l_bulk_planning,
         v_department_id,
         v_time_uom,
         l_allocation_method
    from wms_wp_planning_criteria_vl wwp
   where planning_Criteria_id = p_planning_criteria_id;

  print_debug('The Picking Subinventory specified is ' ||
              v_picking_subinventory,
              l_debug);
  print_debug('The Destination Subinventory is ' ||
              v_destination_subinventory,
              l_debug);

  -- Getting the distinct resource in the Labor Planning table and populating it into the pl/sql record

  /*  for l_resource in c_labor_resource loop

    x_labor_stats_tbl(n2).resource_name := l_resource.resource_type;
    --  addition starts
    wms_wave_planning_pvt.get_current_work_load(l_resource.resource_type,
                                                p_planning_criteria_id,
                                                p_wave_header_id,
                                                x_current_load,
                                                x_resource_type,
                                                x_number_of_tasks,
                                                x_total_capacity);
    x_labor_stats_tbl(n2).current_workload := x_current_load;
    x_labor_stats_tbl(n2).resource_type := x_resource_type;
    x_labor_stats_tbl(n2).number_of_tasks := x_number_of_tasks;
    x_labor_stats_tbl(n2).total_capacity := x_total_capacity;
    x_labor_stats_tbl(n2).available_capacity := x_total_capacity -
                                                x_current_load;

    print_debug('x_labor_stats_tbl(n2).resource_name = ' ||
                x_labor_stats_tbl(n2).resource_name,
                l_debug);
    print_debug('x_labor_stats_tbl(n2).current_workload = ' ||
                x_labor_stats_tbl(n2).current_workload,
                l_debug);
    print_debug('x_labor_stats_tbl(n2).resource_type = ' ||
                x_labor_stats_tbl(n2).resource_type,
                l_debug);
    print_debug('x_labor_stats_tbl(n2).number_of_tasks = ' ||
                x_labor_stats_tbl(n2).number_of_tasks,
                l_debug);
    print_debug('x_labor_stats_tbl(n2).total_capacity = ' ||
                x_labor_stats_tbl(n2).total_capacity,
                l_debug);
    print_debug('x_labor_stats_tbl(n2).available_capacity = ' ||
                x_labor_stats_tbl(n2).available_capacity,
                l_debug);

    --  addition stops

    n2 := n2 + 1;

  end loop; */

  if l_allocation_method <> 'C' then

    for c_item_rec in c_item loop

      l_item_id    := c_item_rec.inventory_item_id;
      l_org_id     := c_item_rec.organization_id;
      L_DEMAND_QTY := 0;

      print_debug('The Item processed is ' || l_item_id, l_debug);

      l_att := get_att_for_subinventory(null, l_item_id, l_org_id);
      print_debug('l_att for item ' || l_item_id ||
                  '- In labor Planning API is' || l_att,
                  l_debug);
      begin

        -- Since Qty Tree would have also subttracted qty for current demand
        -- lines under consideration for which there is existing
        -- reservation as well, I need to add them back
        -- to see real picture of the atr for demand line under consideration

        ------------------

        SELECT nvl(sum(reservation_quantity), 0)
          INTO l_reserved_qty
          FROM mtl_Reservations
         WHERE demand_source_line_id in
               (select source_line_id
                  from wms_wp_wave_lines
                 where wave_header_id = p_wave_header_id
                   and nvl(remove_from_wave_flag, 'N') <> 'Y')
           and organization_id = L_ORG_ID
           and inventory_item_id = L_ITEM_ID
           and (subinventory_code = v_picking_subinventory or
               v_picking_subinventory is null);

        SELECT Nvl(SUM(wdd.requested_quantity), 0)
          INTO l_other_wdd_qty
          FROM wsh_delivery_details wdd
         WHERE wdd.organization_id = l_org_id
           AND wdd.inventory_item_id = l_item_id
           and wdd.delivery_Detail_id not in
               (select delivery_detail_id
                  from wms_wp_wave_lines
                 where wave_header_id = p_wave_header_id
                   and nvl(remove_from_wave_flag, 'N') <> 'Y');

        print_debug('Reserved Qty for other dds that do not belong to the wave   :' ||
                    ' is ' || l_other_wdd_qty,
                    l_debug);

        IF (l_reserved_qty - l_other_wdd_qty) >= 0 THEN
          l_temp_value := (l_reserved_qty - l_other_wdd_qty);
        ELSE
          l_temp_value := 0;
        END IF;

        l_reserved_qty := l_temp_value;

        l_att := l_att + l_reserved_qty;

        print_debug('Reserved Qty is ' || l_reserved_qty, l_debug);

      exception

        when no_data_found then
          l_reserved_qty := 0;
      end;

      if nvl(l_bulk_planning, 'N') = 'Y' then

        print_debug('Bulk Labor Planning Enabled ', l_debug);

        select sum(wwl.requested_quantity), sum(crossdock_quantity)
          into l_demand_qty, l_crossdock_qty
          from wms_wp_wave_lines wwl,wsh_delivery_details wdd
         where wave_header_id = p_wave_header_id
           and nvl(remove_from_wave_flag, 'N') <> 'Y'
              and wwl.delivery_detail_id=wdd.delivery_detail_id
     and wdd.released_status in ('R','B') --- For Hot Order Changes
           and wwl.inventory_item_id = l_item_id;

        print_debug('The  Crossdock quantity in Labor Planning API is ' ||
                    l_crossdock_qty,
                    l_debug);

        if l_allocation_method in ('N', 'X') then

          l_demand_qty := l_demand_qty - l_crossdock_qty;

        end if;

        select pull_replenishment_flag
          into v_replenishment_required
          from wms_wp_wave_headers_vl
         where wave_header_id = p_wave_header_id;

        if l_att >= L_DEMAND_QTY then

          print_debug('ATT greater than demand qty - In labor Planning API',
                      l_debug);

        else

          print_debug('ATT less than demand qty - In labor Planning API',
                      l_debug);

          l_demand_qty := l_att;

          print_debug('The new demand quantity is ' || l_demand_qty,
                      l_debug);

        end if;
        print_debug('The  demand quantity in Labor Planning API is ' ||
                    l_demand_qty,
                    l_debug);
        -- Store all the values in cursor c_subinventories to the labor pl/sql record

        for l_rec in c_subinventories loop

          x_labor_plan_tbl(n).picking_subinventory := l_rec.SECONDARY_INVENTORY_NAME;
          x_labor_plan_tbl(n).source_subinventory := l_rec.source_subINVENTORY;
          x_labor_plan_tbl(n).picking_uom := l_rec.PICK_UOM_CODE;
          x_labor_plan_tbl(n).conversion_rate := l_rec.CONVERSION_RATE;
          x_labor_plan_tbl(n).att := get_att_for_subinventory(p_sub     => l_rec.SECONDARY_INVENTORY_NAME,
                                                              p_item_id => l_item_id,
                                                              p_org_id  => l_org_id);

          print_debug('The Picking Subinventory is ' ||
                      x_labor_plan_tbl(n).picking_subinventory,
                      l_debug);
          print_debug('The Source Subinventory is ' || x_labor_plan_tbl(n)
                      .source_subinventory,
                      l_debug);
          print_debug('The Picking UOM  is ' || x_labor_plan_tbl(n)
                      .picking_uom,
                      l_debug);
          print_debug('The att for Subinventory  ' || x_labor_plan_tbl(n)
                      .picking_subinventory || ' is ' ||
                      x_labor_plan_tbl(n).att,
                      l_debug);
          n := n + 1;

        end loop;
        -- Represent the total demand quantity as integral multiple of the qty conversion to primary UOM.
        -- Update the labor_record pl/sql table for normal and Replenishment Cases
        -- v_destination_subinventory := 'STA';
        update_bulk_labor_record(x_labor_plan_tbl           => x_labor_plan_tbl,
                                 v_replenishment_required   => v_replenishment_required,
                                 v_destination_subinventory => v_destination_subinventory,
                                 p_demand_qty               => l_demand_qty,
                                 x_return_status            => l_return_status);

        x_labor_plan_tbl.delete;
        --Reinitializing n to 0 again;
        n := 0;

      else
        -- Get the Subinventory information where item is available
        print_debug('Bulk Labor Planning Not Enabled ', l_debug);
        print_debug('Doing Labor planning for All Wdds one by one ',
                    l_debug);

        tbl_index := 0;
        for l_rec in c_subinventories loop

          x_labor_plan_tbl(tbl_index).picking_subinventory := l_rec.SECONDARY_INVENTORY_NAME;
          x_labor_plan_tbl(tbl_index).source_subinventory := l_rec.source_subINVENTORY;
          x_labor_plan_tbl(tbl_index).picking_uom := l_rec.PICK_UOM_CODE;
          x_labor_plan_tbl(tbl_index).conversion_rate := l_rec.CONVERSION_RATE;
          x_labor_plan_tbl(tbl_index).att := get_att_for_subinventory(p_sub     => l_rec.SECONDARY_INVENTORY_NAME,
                                                                      p_item_id => l_item_id,
                                                                      p_org_id  => l_org_id);

          -- Ideal Pick Scenario Record
          ideal_labor_plan_tbl(tbl_index).picking_subinventory := l_rec.SECONDARY_INVENTORY_NAME;
          ideal_labor_plan_tbl(tbl_index).source_subinventory := l_rec.source_subINVENTORY;
          ideal_labor_plan_tbl(tbl_index).picking_uom := l_rec.PICK_UOM_CODE;
          ideal_labor_plan_tbl(tbl_index).conversion_rate := l_rec.CONVERSION_RATE;

          print_debug('The Picking Subinventory is ' ||
                      x_labor_plan_tbl(tbl_index).picking_subinventory,
                      l_debug);
          print_debug('The Source Subinventory is ' ||
                      x_labor_plan_tbl(tbl_index).source_subinventory,
                      l_debug);
          print_debug('The Picking UOM  is ' ||
                      x_labor_plan_tbl(tbl_index).picking_uom,
                      l_debug);
          print_debug('The att for Subinventory  ' ||
                      x_labor_plan_tbl(tbl_index)
                      .picking_subinventory || ' is ' ||
                      x_labor_plan_tbl(tbl_index).att,
                      l_debug);
          tbl_index := tbl_index + 1;

        end loop;

        FOR c_rec IN c_labor_lines LOOP

          print_debug('The Requested Quantity for wave line id ' ||
                      c_rec.wave_line_id || 'is ' ||
                      c_rec.requested_quantity,
                      l_debug);
          v_replenishment_required := c_Rec.pull_replenishment_flag;

          L_DEMAND_QTY := L_DEMAND_QTY + c_rec.requested_quantity;

          if L_DEMAND_QTY > l_att then

            print_debug('This line cannot be processed as the total demand qty exceeds the org level ATT',
                        l_debug);
            exit;

          else

            print_debug('Process wave line id and represent it as integral multiple of the conversion rates of subinventories where item is available',
                        l_debug);

            --  Get the ideal pick scenario based on the requested qty and representing it as integral multiple.

            get_ideal_pick_scenario(p_requested_qty => c_rec.requested_quantity,
                                    x_return_status => l_return_status);

          end if;

        END LOOP; -- End loop for all items in that loop;

        --We have two tables one with ideal record and one has the subinventory list with ATT

        -- Need to synchronize ideal pl/sql table based on ATT.

        synchronize_labor_plan_tables(x_return_status            => l_return_status,
                                      p_replenishment_required   => v_replenishment_required,
                                      v_Destination_subinventory => v_Destination_subinventory);

        -- Here we need to enter the Picking to Staging Subinventory and Picking UOM  in the Time Tbl for that item.

        ideal_labor_plan_tbl.delete;
        x_labor_plan_tbl.delete;

      end if; -- End if for Bulk Labor Planning

      print_debug('Current Position is ' || l_current_position, l_debug);

      if x_labor_time_tbl.count > 0 then

        for m4 in l_current_position .. x_labor_time_tbl.LAST loop

          x_labor_time_tbl(m4).inventory_item_id := l_item_id;
          x_labor_time_tbl(m4).standard_operation_id := -1;
          x_labor_time_tbl(m4).operation_plan_id := -1;

        end loop;

      end if;

      l_current_position := x_labor_time_tbl.count - 1;

    end loop; -- End loop for Item

    labor_resource_planning(x_labor_time_tbl,
                            1,
                            'A',
                            p_planning_criteria_id,
                            p_wave_header_id,
                            l_org_id);

  end if;

  if l_allocation_method in ('C', 'X', 'N') then

    print_debug('Getting the crossdock movements --- >  ', l_debug);

    if nvl(l_bulk_planning, 'N') = 'Y' then

      print_debug('Bulk Labor Planning Enabled ', l_debug);

      SELECT 'Not Applicable',
             v_destination_subinventory,
             Min(wwl.requested_quantity_uom),
             Sum(crossdock_quantity),
             -1,
             wwl.inventory_item_id,
             -1 bulk collect
        into c_labor_time_tbl
        FROM wms_wp_wave_lines wwl,wsh_delivery_details wdd
       WHERE wave_header_id = p_wave_header_id
          and wwl.delivery_detail_id=wdd.delivery_detail_id
     and wdd.released_status in ('R','B') --- For Hot Order Changes
       GROUP BY wwl.inventory_item_id
       ORDER BY wwl.inventory_item_id;

    else

      SELECT 'Not Applicable',
             v_destination_subinventory,
             wwl.requested_quantity_uom,
             crossdock_quantity,
             -1,
             wwl.inventory_item_id,
             -1 bulk collect
        into c_labor_time_tbl
        FROM wms_wp_wave_lines wwl,wsh_delivery_details wdd
       WHERE wave_header_id = p_wave_header_id
          and wwl.delivery_detail_id=wdd.delivery_detail_id
     and wdd.released_status in ('R','B') --- For Hot Order Changes
       ORDER BY inventory_item_id;

    end if;

    if l_allocation_method = 'C' then

    	 SELECT organization_id INTO l_org_id FROM wms_Wp_Wave_headers_vl WHERE wave_header_id=p_wave_header_id;

      labor_resource_planning(c_labor_time_tbl,
                              1,
                              'A',
                              p_planning_criteria_id,
                              p_wave_header_id,
                              l_org_id);

    elsif l_allocation_method in ('N', 'X') then

      labor_resource_planning(c_labor_time_tbl,
                              2,
                              'A',
                              p_planning_criteria_id,
                              p_wave_header_id,
                              l_org_id);

    end if;

  end if;

  --  end if;

  print_debug('Labor Movement Required from following  pick subinv to dest subinv ',
              l_debug);

  print_debug('Time Uom is  ' || v_time_uom, l_debug);

  /*

      --  code addition starts
      -- initialize the x_labor_dtl_tbl with all resource details including resource_type
      lab_dtl := 0;
      for l_labor_time in c_labor_time loop
        x_labor_dtl_tbl(lab_dtl).resource_name := l_labor_time.resource_type;
        x_labor_dtl_tbl(lab_dtl).source_subinventory := l_labor_time.source_subinventory;
        x_labor_dtl_tbl(lab_dtl).destination_subinventory := l_labor_time.destination_subinventory;
        x_labor_dtl_tbl(lab_dtl).pick_uom := l_labor_time.pick_uom;
        x_labor_dtl_tbl(lab_dtl).transaction_time := l_labor_time.transaction_time;
        x_labor_dtl_tbl(lab_dtl).travel_time := l_labor_time.travel_time;
        --above details directly available through the cursor. but resource type is stored only in x_labor_stats_tbl
        for j in x_labor_stats_tbl.first .. x_labor_stats_tbl.last loop
          if x_labor_stats_tbl(j).resource_name = x_labor_dtl_tbl(lab_dtl)
          .resource_name then
            x_labor_dtl_tbl(lab_dtl).resource_type := x_labor_stats_tbl(j)
                                                     .resource_type;
          end if;
        end loop;
        lab_dtl := lab_dtl + 1;
      end loop;
      print_debug('just before populating machine details', l_debug);

      --initialize x_machine_dtl_tbl with all the machine details
      lab_dtl := 0;
      for i in x_labor_dtl_tbl.first .. x_labor_dtl_tbl.last loop
        if x_labor_dtl_tbl(i).resource_type = 1 then
          -- if machine only then details should be populated
          x_machine_dtl_tbl(lab_dtl).resource_name := x_labor_dtl_tbl(i)
                                                     .resource_name;
          x_machine_dtl_tbl(lab_dtl).source_subinventory := x_labor_dtl_tbl(i)
                                                           .source_subinventory;
          x_machine_dtl_tbl(lab_dtl).destination_subinventory := x_labor_dtl_tbl(i)
                                                                .destination_subinventory;
          x_machine_dtl_tbl(lab_dtl).pick_uom := x_labor_dtl_tbl(i).pick_uom;
          x_machine_dtl_tbl(lab_dtl).resource_type := x_labor_dtl_tbl(i)
                                                     .resource_type;
          lab_dtl := lab_dtl + 1;
        else
          print_debug('resource ' || x_labor_dtl_tbl(i)
                      .resource_name || ' is person',
                      l_debug);
        end if;
      end loop;

      print_debug('just after  populating machine details', l_debug);

      if x_labor_time_tbl.count > 0 then
        -- only if there is a movement, we need to calculate the load distribution.
        for i in x_labor_time_tbl.first .. x_labor_time_tbl.last loop
          -- run the loop for each of the movement.
          print_debug('Current movement is from ', l_debug);
          print_debug(x_labor_time_tbl(i).picking_subinventory || ' to ',
                      l_debug);
          print_debug(x_labor_time_tbl(i).destination_subinventory, l_debug);
          print_debug('The uom is ' || x_labor_time_tbl(i).picking_uom,
                      l_debug);
          print_debug('Quantity to be moved is ' || x_labor_time_tbl(i)
                      .demand_qty_picking_uom,
                      l_debug);

          l_completed     := 0;
          l_resource_type := 2;
          l_person_found  := 0;
          -- <<start_machine_test>> --if only m/c and no person is available for movement, it should not be considered.

          j        := 0;
          l_dd_qty := x_labor_time_tbl(i).demand_qty_picking_uom;
          while j < x_labor_dtl_tbl.count loop
            -- needs manual increment for this loop
            if l_completed = 1 then
              exit; --entire qyt for this movement has been handled. So exit  x_labor_dtl_tbl loop
            end if;
            if x_labor_time_tbl(i).picking_subinventory = x_labor_dtl_tbl(j)
            .source_subinventory and x_labor_time_tbl(i)
            .destination_subinventory = x_labor_dtl_tbl(j)
            .destination_subinventory and x_labor_time_tbl(i)
            .picking_uom = x_labor_dtl_tbl(j)
            .pick_uom and x_labor_dtl_tbl(j)
            .resource_type = l_resource_type then

              l_person_found := 1;
              k              := 0;

              while k < x_labor_stats_tbl.count loop
                -- needs manual increment for this loop
                if x_labor_stats_tbl(k).resource_name = x_labor_dtl_tbl(j)
                .resource_name then
                  -- k  value should be incremented in this if.
                  print_debug('The resource is ' || x_labor_stats_tbl(k)
                              .resource_name,
                              l_debug);

                  select nvl(utilization, 100) / 100,
                         nvl(efficiency, 100) / 100
                    into l_utilization, l_efficiency
                    from bom_department_resources_v
                   where department_id in
                         (select department_id
                            from wms_wp_planning_criteria_vl
                           where planning_criteria_id = p_planning_criteria_id)
                     and resource_code = x_labor_stats_tbl(k)
                  .resource_name;

                  l_avail_capacity          := x_labor_stats_tbl(k)
                                              .available_capacity;
                  l_number_of_capable_units := floor((round(l_avail_capacity *
                                                            l_utilization *
                                                            l_efficiency) -
                                                     x_labor_dtl_tbl(j)
                                                     .travel_time) /
                                                     x_labor_dtl_tbl(j)
                                                     .transaction_time);

                  print_debug('Quantity which this resource can handle is ' ||
                              l_number_of_capable_units,
                              l_debug);

                  if l_avail_capacity > 0 and
                     l_dd_qty <= l_number_of_capable_units then
                    print_debug('Resource can handle entire quantity in this movement',
                                l_debug);
                    l_accept_load  := l_dd_qty;
                    l_dd_qty       := l_dd_qty - l_accept_load;
                    l_planned_load := round((l_accept_load *
                                            x_labor_dtl_tbl(j)
                                            .transaction_time +
                                             x_labor_dtl_tbl(j).travel_time) /
                                            (l_utilization * l_efficiency));

                    print_debug('Planned load on this resource due to this movement is ' ||
                                l_planned_load,
                                l_debug);
                    x_labor_stats_tbl(k).planned_wave_load := x_labor_stats_tbl(k)
                                                             .planned_wave_load +
                                                              l_planned_load;
                    print_debug('Total planned load on this resource with this load included is ' ||
                                x_labor_stats_tbl(k).planned_wave_load,
                                l_debug);

                    x_labor_stats_tbl(k).number_of_planned_tasks := x_labor_stats_tbl(k)
                                                                   .number_of_planned_tasks + 1;
                    print_debug('Total planned tasks for this resource after including tasks for this movement ' ||
                                x_labor_stats_tbl(k).number_of_planned_tasks,
                                l_debug);

                    x_labor_stats_tbl(k).available_capacity := x_labor_stats_tbl(k)
                                                              .available_capacity -
                                                               l_planned_load;
                    print_debug('Available capacity for the resource after subtracting the current  planned load is ' ||
                                x_labor_stats_tbl(k).available_capacity,
                                l_debug);

                    if l_resource_type = 2 then
                      -- Only if the current resource is person, we need to add the load to machine.
                      sync_machine_person_time(l_planned_load,
                                               1,
                                               x_labor_dtl_tbl(j)
                                               .source_subinventory,
                                               x_labor_dtl_tbl(j)
                                               .destination_subinventory,
                                               x_labor_dtl_tbl(j).pick_uom);
                    end if;

                    -- entire qty for this movement has been handled. Now need to exit these loops.
                    l_completed := 1; -- will tell the x_labor_dtl_tbl loop to exit
                    k           := x_labor_stats_tbl.count; -- will not allow to come into this loop again.
                    exit; -- this will exit from x_labor_stats_tbl loop

                  elsif l_avail_capacity > 0 and
                        l_dd_qty > l_number_of_capable_units then
                    print_debug('Resource can handle partial quantity in this movement',
                                l_debug);
                    -- find if this resource is the final resource. if so no question. Assign entire load to this guy
                    -- if this resource is not the final resource, assign him the load that he can do and later assign it to next guy who can do it.

                    j_temp := get_next_resource(j,
                                                x_labor_time_tbl(i)
                                                .picking_subinventory,
                                                x_labor_time_tbl(i)
                                                .destination_subinventory,
                                                x_labor_time_tbl(i)
                                                .picking_uom,
                                                l_resource_type);
                    -- if j_temp is -1 no resource is available, else there is some other resource who can handle the load

                    if j_temp = -1 then
                      l_accept_load := l_dd_qty;
                      l_dd_qty      := 0;
                    else
                      if l_number_of_capable_units > 0 then
                        l_accept_load := l_number_of_capable_units;
                        l_dd_qty      := l_dd_qty - l_accept_load;
                      else
                        l_accept_load := 0;
                      end if;
                    end if;

                    if j_temp = -1 or
                       (j_temp <> -1 and l_number_of_capable_units > 0) then
                      l_planned_load := round((l_accept_load *
                                              x_labor_dtl_tbl(j)
                                              .transaction_time +
                                               x_labor_dtl_tbl(j).travel_time) /
                                              (l_utilization * l_efficiency));

                      print_debug('Planned load on this resource due to this movement is ' ||
                                  l_planned_load,
                                  l_debug);
                      x_labor_stats_tbl(k).planned_wave_load := x_labor_stats_tbl(k)
                                                               .planned_wave_load +
                                                                l_planned_load;
                      print_debug('Total planned load on this resource with this load included is ' ||
                                  x_labor_stats_tbl(k).planned_wave_load,
                                  l_debug);

                      x_labor_stats_tbl(k).number_of_planned_tasks := x_labor_stats_tbl(k)
                                                                     .number_of_planned_tasks + 1;
                      print_debug('Total planned tasks for this resource after including tasks for this movement ' ||
                                  x_labor_stats_tbl(k)
                                  .number_of_planned_tasks,
                                  l_debug);

                      x_labor_stats_tbl(k).available_capacity := x_labor_stats_tbl(k)
                                                                .available_capacity -
                                                                 l_planned_load;
                      print_debug('Available capacity for the resource after subtracting the current  planned load is ' ||
                                  x_labor_stats_tbl(k).available_capacity,
                                  l_debug);

                      if l_resource_type = 2 then
                        -- Only if the current resource is person, we need to add the load to machine.
                        sync_machine_person_time(l_planned_load,
                                                 1,
                                                 x_labor_dtl_tbl(j)
                                                 .source_subinventory,
                                                 x_labor_dtl_tbl(j)
                                                 .destination_subinventory,
                                                 x_labor_dtl_tbl(j).pick_uom);
                      end if;
                    end if;

                    if j_temp = -1 then
                      -- here all the qty is handled by this guy. take care to exit the loop
                      l_completed := 1; -- will tell the x_labor_dtl_tbl loop to exit
                      k           := x_labor_stats_tbl.count; -- will not allow to come into this loop again.
                      exit; -- this will exit from x_labor_stats_tbl loop
                    else
                      -- last step is to assign the value of j to j_temp
                      k := x_labor_stats_tbl.count; -- should start from begining, inorder to get the next resource details
                      j := j_temp;
                    end if;

                  elsif l_avail_capacity <= 0 then
                    print_debug('Resource cannot handle any quantity in this movement',
                                l_debug);
                    j_temp := get_next_resource(j,
                                                x_labor_time_tbl(i)
                                                .picking_subinventory,
                                                x_labor_time_tbl(i)
                                                .destination_subinventory,
                                                x_labor_time_tbl(i)
                                                .picking_uom,
                                                l_resource_type);

                    if j_temp = -1 then
                      l_accept_load  := l_dd_qty;
                      l_dd_qty       := 0;
                      l_planned_load := round((l_accept_load *
                                              x_labor_dtl_tbl(j)
                                              .transaction_time +
                                               x_labor_dtl_tbl(j).travel_time) /
                                              (l_utilization * l_efficiency));

                      print_debug('Planned load on this resource due to this movement is ' ||
                                  l_planned_load,
                                  l_debug);
                      x_labor_stats_tbl(k).planned_wave_load := x_labor_stats_tbl(k)
                                                               .planned_wave_load +
                                                                l_planned_load;
                      print_debug('Total planned load on this resource with this load included is ' ||
                                  x_labor_stats_tbl(k).planned_wave_load,
                                  l_debug);

                      x_labor_stats_tbl(k).number_of_planned_tasks := x_labor_stats_tbl(k)
                                                                     .number_of_planned_tasks + 1;
                      print_debug('Total planned tasks for this resource after including tasks for this movement ' ||
                                  x_labor_stats_tbl(k)
                                  .number_of_planned_tasks,
                                  l_debug);

                      x_labor_stats_tbl(k).available_capacity := x_labor_stats_tbl(k)
                                                                .available_capacity -
                                                                 l_planned_load;
                      print_debug('Available capacity for the resource after subtracting the current  planned load is ' ||
                                  x_labor_stats_tbl(k).available_capacity,
                                  l_debug);

                      if l_resource_type = 2 then
                        -- Only if the current resource is person, we need to add the load to machine.
                        sync_machine_person_time(l_planned_load,
                                                 1,
                                                 x_labor_dtl_tbl(j)
                                                 .source_subinventory,
                                                 x_labor_dtl_tbl(j)
                                                 .destination_subinventory,
                                                 x_labor_dtl_tbl(j).pick_uom);
                      end if;
                      -- here all the qty is handled by this guy. take care to exit the loop
                      l_completed := 1; -- will tell the x_labor_dtl_tbl loop to exit
                      k           := x_labor_stats_tbl.count; -- will not allow to come into this loop again.
                      exit; -- this will exit from x_labor_stats_tbl loop
                    else
                      k := x_labor_stats_tbl.count; -- should start from beginning, inorder to get next resource details
                      j := j_temp;
                    end if;
                  end if;
                else
                  k := k + 1;
                end if;
              end loop;

            else
              j := j + 1;
            end if;
          end loop;
          if l_person_found <> 1 then
            --and l_resource_type = 2 then
            print_debug('No person is available to handle the current movement',
                        l_debug);
            --l_resource_type := 1;
            --goto start_machine_test;
            /*elsif l_person_found <> 1 and l_resource_type = 1 then
            print_debug('No machine found to do the work too',l_debug);
          end if;
        end loop;
      end if;

      --  code addition stops
      print_debug('before duplicate table entries', l_debug);
      lab_dtl := 0;
      for i in x_labor_stats_tbl.first .. x_labor_stats_tbl.last loop
        print_debug('in duplicate table entries', l_debug);
        if x_labor_stats_tbl(i).planned_wave_load <> 0 then
          print_debug('in duplicate table entries if', l_debug);
          print_debug('value of i' || i, l_debug);
          print_debug('value of lab_dtl' || lab_dtl, l_debug);
          x_labor_stats_tbl_tmp(lab_dtl).resource_name := x_labor_stats_tbl(i)
                                                         .resource_name;
          x_labor_stats_tbl_tmp(lab_dtl).planned_wave_load := x_labor_stats_tbl(i)
                                                             .planned_wave_load;
          x_labor_stats_tbl_tmp(lab_dtl).total_Capacity := x_labor_stats_tbl(i)
                                                          .total_Capacity;
          x_labor_stats_tbl_tmp(lab_dtl).current_workload := x_labor_stats_tbl(i)
                                                            .current_workload;
          x_labor_stats_tbl_tmp(lab_dtl).available_capacity := x_labor_stats_tbl(i)
                                                              .available_capacity;
          x_labor_stats_tbl_tmp(lab_dtl).number_of_tasks := x_labor_stats_tbl(i)
                                                           .number_of_tasks;
          x_labor_stats_tbl_tmp(lab_dtl).number_of_planned_tasks := x_labor_stats_tbl(i)
                                                                   .number_of_planned_tasks;
          lab_dtl := lab_dtl + 1;
        end if;
      end loop;
      print_debug('after duplicate table entries', l_debug);
  */
  DELETE FROM wms_wp_labor_Statistics
   WHERE wave_header_id = p_wave_header_id;

l_tbl_count := x_resource_capacity_tbl.count;

  if x_resource_capacity_tbl.count > 0 then
     --forall i in x_resource_capacity_tbl.first .. x_resource_capacity_tbl.last
     for i in x_resource_capacity_tbl.first .. x_resource_capacity_tbl.last LOOP --dbchange14

      insert into wms_wp_labor_statistics
        (wave_header_id,
         resource_name,
         planned_wave_load,
         total_capacity,
         actual_workload,
         available_capacity,
         NUMBER_OF_ACTUAL_TASKS,
         NUMBER_OF_PLANNED_TASKS)
      values
        (p_wave_header_id,
         x_resource_capacity_tbl(i).resource_name,
         x_resource_capacity_tbl(i).planned_load,
         x_resource_capacity_tbl(i).total_Capacity,
         x_resource_capacity_tbl(i).current_load,
         x_resource_capacity_tbl(i).available_capacity,
         x_resource_capacity_tbl(i).actual_tasks,
         x_resource_capacity_tbl(i).planned_tasks);
       end loop;
  end if;

  -- x_labor_stats_tbl.delete;
  x_labor_time_tbl.delete;
  c_labor_time_tbl.delete;
  x_resource_capacity_tbl.delete;
  -- x_labor_dtl_tbl.delete;
  -- x_machine_dtl_tbl.delete;
  --  x_labor_stats_tbl_tmp.delete;

  commit;
  x_return_status := 'S';
exception
  when others then
    print_debug('Error in Labor Planning API: ' || SQLCODE || ' : ' ||
                SQLERRM,
                l_debug);
    x_return_status := 'E';
end labor_planning;

  procedure get_ideal_pick_scenario(p_requested_qty in number,
                                    x_return_status OUT NOCOPY varchar2)

   is

    l_requested_qty number := p_requested_qty;
    l_debug         NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    divider         number;
  begin

    print_debug('Entered ideal pick scenario: '||ideal_labor_plan_tbl.count, l_debug);


if ideal_labor_plan_tbl.count >0 then

    FOR i IN ideal_labor_plan_tbl.FIRST .. ideal_labor_plan_tbl.LAST LOOP


    print_debug('Inside for loop ', l_debug);

      divider := Floor(l_requested_qty / ideal_labor_plan_tbl(i)
                       .conversion_rate);

    print_debug('After divider ', l_debug);


      ideal_labor_plan_tbl(i).demand_qty_picking_uom := ideal_labor_plan_tbl(i)
                                                       .demand_qty_picking_uom +
                                                        divider;

      print_debug('Picking Subinventory is  ' || ideal_labor_plan_tbl(i)
                  .picking_subinventory,
                  l_debug);

      print_debug('Conversion rate is ' || ideal_labor_plan_tbl(i)
                  .conversion_rate,
                  l_debug);

      print_debug('Demand qty in Picking UOM is ' ||
                  ideal_labor_plan_tbl(i).demand_qty_picking_uom,
                  l_debug);

      print_debug(' Picking UOM is ' || ideal_labor_plan_tbl(i)
                  .picking_uom,
                  l_debug);

      l_requested_qty := l_requested_qty -
                         divider * ideal_labor_plan_tbl(i).conversion_rate;

    END LOOP;

  end if;

  exception
    when others then
      print_debug('Error in get ideal pick scenario: ' || SQLCODE || ' : ' ||
                  SQLERRM,
                  l_debug);

  end get_ideal_pick_Scenario;

  procedure synchronize_labor_plan_tables(x_return_status            OUT NOCOPY varchar2,
                                          p_replenishment_Required   in varchar2,
                                          v_Destination_subinventory in varchar2) is

    m             number;
    l             number;
    sum_qty       NUMBER := 0;
    sum_att       NUMBER := 0;
    repl_quantity NUMBER := 0;
    qty_moved     NUMBER := 0;
    jump_Count    NUMBER := 0;
    m2            NUMBER;
    m1            NUMBER;

    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  begin

    print_debug('Entered synchronize labor plan tables', l_debug);

    m := ideal_labor_plan_tbl.count - 1;
    print_debug('m is ' || m, l_debug);
    l := x_labor_plan_tbl.count - 1;

    print_debug('x labor count  is ' || l, l_debug);

    WHILE (m >= 0) loop

      -- First find out the sum of the conversion rate and subinventory

      print_debug('Current conversion rate is ' || ideal_labor_plan_tbl(m)
                  .conversion_rate,
                  l_debug);

      -- Find the sum of qty in this conversion rate  and sum of att as well

      m1        := m - 1;
      sum_qty   := ideal_labor_plan_tbl(m)
                  .demand_qty_picking_uom * ideal_labor_plan_tbl(m)
                  .conversion_rate;
      sum_att   := x_labor_plan_tbl(m).att;
      qty_moved := 0;

      WHILE (m1 > 0) loop

        EXIT WHEN ideal_labor_plan_tbl(m1) .conversion_rate > ideal_labor_plan_tbl(m) .conversion_rate;

        sum_qty := sum_qty + ideal_labor_plan_tbl(m1)
                  .demand_qty_picking_uom * ideal_labor_plan_tbl(m1)
                  .conversion_rate;
        sum_att := sum_att + x_labor_plan_tbl(m1).att;

        m1 := m1 - 1;
      END LOOP;

      -- Dbms_Output.put_line('m1 is '||m1+1);

      print_debug('Sum qty is ' || sum_qty, l_debug);

      print_debug('Sum att is ' || sum_att, l_debug);

      IF sum_att >= sum_qty then

        -- We need to move for subinventories  of conversion rate 1

        jump_Count := 0;
        WHILE (m1 < m) LOOP
          IF (ideal_labor_plan_tbl(m1 + 1)
             .demand_qty_picking_uom * ideal_labor_plan_tbl(m1 + 1)
             .conversion_rate) <= x_labor_plan_tbl(m1 + 1)
          .att AND ideal_labor_plan_tbl(m1 + 1)
          .demand_qty_picking_uom <> 0 THEN

            qty_moved := qty_moved +
                         (ideal_labor_plan_tbl(m1 + 1)
                         .demand_qty_picking_uom *
                          ideal_labor_plan_tbl(m1 + 1).conversion_rate);

            x_labor_time_tbl(n1).demand_qty_picking_uom := ideal_labor_plan_tbl(m1 + 1)
                                                          .demand_qty_picking_uom;
            x_labor_time_tbl(n1).picking_uom := ideal_labor_plan_tbl(m1 + 1)
                                               .picking_uom;
            x_labor_time_tbl(n1).picking_subinventory := ideal_labor_plan_tbl(m1 + 1)
                                                        .picking_subinventory;
            x_labor_time_tbl(n1).destination_subinventory := v_destination_subinventory;

            print_debug('Entered if part where demand qty in picking uom > 0 and  it is less than att',
                        l_debug);
            print_debug('n1 is ' || n1, l_debug);
            n1 := n1 + 1;

          ELSIF ideal_labor_plan_tbl(m1 + 1)
          .demand_qty_picking_uom <> 0 AND
                (ideal_labor_plan_tbl(m1 + 1)
                 .demand_qty_picking_uom * ideal_labor_plan_tbl(m1 + 1)
                 .conversion_rate) > x_labor_plan_tbl(m1 + 1).att then

            x_labor_time_tbl(n1).demand_qty_picking_uom := floor(x_labor_plan_tbl(m1 + 1)
                                                                 .att /
                                                                 ideal_labor_plan_tbl(m1 + 1)
                                                                 .conversion_rate);
            x_labor_time_tbl(n1).picking_uom := ideal_labor_plan_tbl(m1 + 1)
                                               .picking_uom;
            x_labor_time_tbl(n1).picking_subinventory := ideal_labor_plan_tbl(m1 + 1)
                                                        .picking_subinventory;
            x_labor_time_tbl(n1).destination_subinventory := v_destination_subinventory;
            print_debug('Entered if part where demand qty in picking uom <> 0 and  it is greater than att',
                        l_debug);
            print_debug('n1 is ' || n1, l_debug);
            n1 := n1 + 1;

            qty_moved := qty_moved + x_labor_plan_tbl(m1 + 1).att;

          ELSE
            print_debug('Entered if part where demand qty in picking uom  =  0',
                        l_debug);
            print_debug('sum_qty is ' || sum_qty, l_debug);
            print_debug('qty_moved is ' || qty_moved, l_debug);

            IF x_labor_plan_tbl(m1 + 1)
            .att >= (sum_qty - qty_moved) AND (sum_qty - qty_moved) > 0 THEN

              x_labor_time_tbl(n1).demand_qty_picking_uom := floor((sum_qty -
                                                                   qty_moved) /
                                                                   ideal_labor_plan_tbl(m1 + 1)
                                                                   .conversion_rate);
              print_debug('Qty to be moved in demand qty picking uom is  ' ||
                          x_labor_time_tbl(n1).demand_qty_picking_uom,
                          l_debug);

              x_labor_time_tbl(n1).picking_uom := ideal_labor_plan_tbl(m1 + 1)
                                                 .picking_uom;
              x_labor_time_tbl(n1).picking_subinventory := ideal_labor_plan_tbl(m1 + 1)
                                                          .picking_subinventory;
              print_debug('Picking Sub inventory is  ' ||
                          x_labor_time_tbl(n1).picking_subinventory,
                          l_debug);
              print_debug('Picking uom is  ' || x_labor_time_tbl(n1)
                          .picking_uom,
                          l_debug);
              x_labor_time_tbl(n1).destination_subinventory := v_destination_subinventory;
              print_debug('n1 is ' || n1, l_debug);
              print_debug('Entered if part where demand qty in picking uom  =  0 and  it is less than att',
                          l_debug);
              n1 := n1 + 1;

              qty_moved := qty_moved + (sum_qty - qty_moved);

            ELSIF x_labor_plan_tbl(m1 + 1).att < (sum_qty - qty_moved) then

              qty_moved := qty_moved + x_labor_plan_tbl(m1 + 1).att;

              x_labor_time_tbl(n1).demand_qty_picking_uom := floor(x_labor_plan_tbl(m1 + 1)
                                                                   .att /
                                                                   ideal_labor_plan_tbl(m1 + 1)
                                                                   .conversion_rate);
              x_labor_time_tbl(n1).picking_uom := ideal_labor_plan_tbl(m1 + 1)
                                                 .picking_uom;
              x_labor_time_tbl(n1).picking_subinventory := ideal_labor_plan_tbl(m1 + 1)
                                                          .picking_subinventory;
              x_labor_time_tbl(n1).destination_subinventory := v_destination_subinventory;
              print_debug('n1 in else2 is ' || n1, l_debug);
              n1 := n1 + 1;

            END IF;
          END IF;

          jump_Count := jump_Count + 1;
          m1         := m1 + 1;

        END LOOP;

        print_debug('jump_Count is ' || jump_Count, l_debug);

      ELSE

        --Quantity is less

        -- Need to check if replenishment s required

        IF p_replenishment_Required = 'Y' THEN

          print_debug('Replenishment Required ', l_debug);
          m2 := m1 + 1;
          -- Here we need to check how much needs to be moved

          repl_quantity := ceil((sum_qty - sum_att) /
                                x_labor_plan_tbl(m2 - 1).conversion_rate);
          print_debug('Replenishment qty is ' || repl_quantity, l_debug);
          -- Need to check if the source subinventory is m1+1 and att is available

          IF x_labor_plan_tbl(m2 - 1)
          .att >= repl_quantity and x_labor_plan_tbl(m2 - 1)
          .picking_subinventory = x_labor_plan_tbl(m2)
          .source_subinventory then

            x_labor_plan_tbl(m2 - 1).att := x_labor_plan_tbl(m2 - 1)
                                           .att - (repl_quantity *
                                                   x_labor_plan_tbl(m2 - 1)
                                                   .conversion_rate);
            x_labor_plan_tbl(m2).att := x_labor_plan_tbl(m2)
                                       .att + (repl_quantity *
                                               x_labor_plan_tbl(m2 - 1)
                                               .conversion_rate);

            print_Debug('New ATT for  ' || x_labor_plan_tbl(m2 - 1)
                        .picking_subinventory || ' is ' ||
                        x_labor_plan_tbl(m2 - 1).att,
                        l_debug);
            print_Debug('New ATT for ' || x_labor_plan_tbl(m2)
                        .picking_subinventory || ' is ' ||
                        x_labor_plan_tbl(m2).att,
                        l_debug);

            x_labor_time_tbl(n1).demand_qty_picking_uom := repl_quantity;
            x_labor_time_tbl(n1).picking_uom := ideal_labor_plan_tbl(m2 - 1)
                                               .picking_uom;
            x_labor_time_tbl(n1).picking_subinventory := x_labor_plan_tbl(m2)
                                                        .source_subinventory;
            x_labor_time_tbl(n1).destination_subinventory := ideal_labor_plan_tbl(m2)
                                                            .picking_subinventory;

            n1 := n1 + 1;

            jump_Count := 0;
            WHILE (m1 < m) loop
              IF x_labor_plan_tbl(m1 + 1).att <= (ideal_labor_plan_tbl(m1 + 1)
                         .demand_qty_picking_uom *
                         ideal_labor_plan_tbl(m1 + 1)
                         .conversion_rate) THEN

                qty_moved := qty_moved + x_labor_plan_tbl(m1 + 1).att;

                x_labor_time_tbl(n1).demand_qty_picking_uom := (x_labor_plan_tbl(m1 + 1)
                                                               .att /
                                                                x_labor_plan_tbl(m1 + 1)
                                                               .conversion_rate);
                x_labor_time_tbl(n1).picking_uom := ideal_labor_plan_tbl(m1 + 1)
                                                   .picking_uom;
                x_labor_time_tbl(n1).picking_subinventory := ideal_labor_plan_tbl(m1 + 1)
                                                            .picking_subinventory;
                x_labor_time_tbl(n1).destination_subinventory := v_destination_subinventory;

                print_debug('n1 is ' || n1, l_debug);
                n1 := n1 + 1;
              ELSE

                IF qty_moved < sum_qty THEN
                  IF (sum_qty - qty_moved) <= x_labor_plan_tbl(m1 + 1).att then

                    x_labor_time_tbl(n1).demand_qty_picking_uom := To_Number((sum_qty -
                                                                             qty_moved) /
                                                                             x_labor_plan_tbl(m1 + 1)
                                                                             .conversion_rate);
                    x_labor_time_tbl(n1).picking_uom := ideal_labor_plan_tbl(m1 + 1)
                                                       .picking_uom;
                    x_labor_time_tbl(n1).picking_subinventory := ideal_labor_plan_tbl(m1 + 1)
                                                                .picking_subinventory;
                    x_labor_time_tbl(n1).destination_subinventory := v_destination_subinventory;

                    qty_moved := qty_moved + To_Number(sum_qty - qty_moved);

                    print_debug('n1 is ' || n1, l_debug);
                    n1 := n1 + 1;

                  ELSE
                    x_labor_time_tbl(n1).demand_qty_picking_uom := x_labor_plan_tbl(m1 + 1)
                                                                  .att /
                                                                   x_labor_plan_tbl(m1 + 1)
                                                                  .conversion_rate;
                    x_labor_time_tbl(n1).picking_uom := ideal_labor_plan_tbl(m1 + 1)
                                                       .picking_uom;
                    x_labor_time_tbl(n1).picking_subinventory := ideal_labor_plan_tbl(m1 + 1)
                                                                .picking_subinventory;
                    x_labor_time_tbl(n1).destination_subinventory := v_destination_subinventory;

                    print_debug('n1 is ' || n1, l_debug);
                    n1 := n1 + 1;

                    qty_moved := qty_moved + x_labor_plan_tbl(m1 + 1).att;

                  END IF;

                END IF;
              END IF;

              jump_Count := jump_Count + 1;
              m1         := m1 + 1;

            END LOOP;

          else

            -- Source subinventory is not the defined or not correct or ATT is not available in Source Subinventory

            print_debug('Source subinventory is not defined or ATT is not available in Source subinventory',
                        l_debug);

            jump_Count := 0;
            WHILE (m1 < m) loop
              jump_Count := jump_Count + 1;
              m1         := m1 + 1;

              x_labor_time_tbl(n1).demand_qty_picking_uom := floor(x_labor_plan_tbl(m1)
                                                                   .att /
                                                                   x_labor_plan_tbl(m1)
                                                                   .conversion_rate);
              x_labor_time_tbl(n1).picking_uom := ideal_labor_plan_tbl(m1)
                                                 .picking_uom;
              x_labor_time_tbl(n1).picking_subinventory := ideal_labor_plan_tbl(m1)
                                                          .picking_subinventory;
              x_labor_time_tbl(n1).destination_subinventory := v_destination_subinventory;

              print_debug('n1 is ' || n1, l_debug);
              n1 := n1 + 1;

            END LOOP;

          END IF;

        ELSE

          -- Replenishment not required
          -- If replenishment is not required we just move whatever is available

          print_debug('Qty not available ', l_debug);
          jump_Count := 0;
          WHILE (m1 < m) loop
            jump_Count := jump_Count + 1;
            m1         := m1 + 1;

            x_labor_time_tbl(n1).demand_qty_picking_uom := floor(x_labor_plan_tbl(m1)
                                                                 .att /
                                                                 x_labor_plan_tbl(m1)
                                                                 .conversion_rate);
            x_labor_time_tbl(n1).picking_uom := ideal_labor_plan_tbl(m1)
                                               .picking_uom;
            x_labor_time_tbl(n1).picking_subinventory := ideal_labor_plan_tbl(m1)
                                                        .picking_subinventory;
            x_labor_time_tbl(n1).destination_subinventory := v_destination_subinventory;

            print_debug('n1 is ' || n1, l_debug);
            n1 := n1 + 1;

          END LOOP;

        END IF;

      END IF;
      m := m - jump_Count;
    END LOOP;

  exception
    when others then
      print_debug('Error in get synchronize labor plan tables: ' ||
                  SQLCODE || ' : ' || SQLERRM,
                  l_debug);

  end synchronize_labor_plan_tables;

  FUNCTION get_conversion_rate(p_item_id       IN NUMBER,
                               p_from_uom_code IN VARCHAR2,
                               p_to_uom_code   IN VARCHAR2) RETURN NUMBER IS
    l_conversion_rate NUMBER;
    l_debug           NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

  BEGIN
    IF (p_from_uom_code = p_to_uom_code) THEN
      -- No conversion necessary
      l_conversion_rate := 1;
    else

      inv_convert.inv_um_conversion(from_unit => p_from_uom_code,
                                    to_unit   => p_to_uom_code,
                                    item_id   => p_item_id,
                                    uom_rate  => l_conversion_rate);

    end if;
    RETURN l_conversion_rate;

  EXCEPTION
    WHEN OTHERS THEN
      IF l_debug = 1 THEN
        print_debug('Exception in get_conversion_rate: ' || sqlcode || ', ' ||
                    sqlerrm,
                    l_debug);
      END IF;
      -- If an exception occurs, return a negative value.
      -- The calling program should interpret this as an exception in retrieving
      -- the UOM conversion rate.
      RETURN - 999;
  END get_conversion_rate;

  FUNCTION get_att_for_subinventory(p_sub     IN VARCHAR2,
                                    p_item_id IN NUMBER,
                                    p_org_id  IN NUMBER) RETURN NUMBER IS

    l_is_revision_ctrl BOOLEAN := FALSE;
    l_is_lot_ctrl      BOOLEAN := FALSE;
    l_is_serial_ctrl   BOOLEAN := FALSE;
    l_qoh              NUMBER;
    l_rqoh             NUMBER;
    l_qr               NUMBER;
    l_qs               NUMBER;
    l_atr              NUMBER;
    l_att              NUMBER;
    l_msg_count        number;
    l_return_status    VARCHAR2(3) := fnd_api.g_ret_sts_success;
    l_msg_data         varchar2(100);
    l_debug            NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'),
                                     0);
  begin

    --Find out the total atr for the item
    IF inv_cache.set_item_rec(p_ORG_ID, p_item_id) THEN

     /* IF inv_cache.item_rec.revision_qty_control_code = 2 THEN
        l_is_revision_ctrl := TRUE;
      ELSE
        l_is_revision_ctrl := FALSE;
      END IF;

      IF inv_cache.item_rec.lot_control_code = 2 THEN
        l_is_lot_ctrl := TRUE;
      ELSE
        l_is_lot_ctrl := FALSE;
      END IF; */

      IF inv_cache.item_rec.serial_number_control_code NOT IN (1, 6) THEN
        l_is_serial_ctrl := FALSE;
      ELSE
        l_is_serial_ctrl := TRUE;
      END IF;

    ELSE
      RAISE no_data_found;
    END IF;
    print_debug('In Get ATT for subinventory API', l_debug);

    inv_quantity_tree_pub.query_quantities(p_api_version_number      => 1.0,
                                           p_init_msg_lst            => fnd_api.g_false,
                                           x_return_status           => l_return_status,
                                           x_msg_count               => l_msg_count,
                                           x_msg_data                => l_msg_data,
                                           p_organization_id         => p_org_id,
                                           p_inventory_item_id       => p_item_id,
                                           p_tree_mode               => inv_quantity_tree_pub.g_transaction_mode,
                                           p_is_revision_control     => l_is_revision_ctrl,
                                           p_is_lot_control          => l_is_lot_ctrl,
                                           p_is_serial_control       => l_is_serial_ctrl,
                                           p_demand_source_type_id   => -9999 --should not be null
                                          ,
                                           p_demand_source_header_id => -9999 --should not be null
                                          ,
                                           p_demand_source_line_id   => -9999,
                                           p_revision                => NULL,
                                           p_lot_number              => NULL,
                                           p_subinventory_code       => p_sub,
                                           p_locator_id              => NULL,
                                           x_qoh                     => l_qoh,
                                           x_rqoh                    => l_rqoh,
                                           x_qr                      => l_qr,
                                           x_qs                      => l_qs,
                                           x_att                     => l_att,
                                           x_atr                     => l_atr);

    print_debug('ATR for Item ' || p_item_id || 'in subinventory ' ||
                p_sub || ' is :' || l_atr,
                l_debug);
    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      l_atr := 0;
    END IF;

    RETURN l_atr;
  END get_att_for_subinventory;

  procedure update_bulk_labor_record(x_labor_plan_tbl           in OUT NOCOPY labor_plan_tbl,
                                     v_replenishment_required   in varchar2,
                                     v_destination_subinventory in varchar2,
                                     p_demand_qty               in OUT NOCOPY number,
                                     x_return_status            OUT NOCOPY varchar2)

   is

    i                       NUMBER := 0;
    divider                 INTEGER;
    REMinder                INTEGER;
    j                       number := 0;
    v_att                   NUMBER;
    n                       number := 0;
    sum_qty                 NUMBER := 0;
    current_conversion_rate NUMBER;
    next_conversion_rate    NUMBER;
    low_picking_order       NUMBER;

    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN

    print_debug('Entered Bulk Labor Record API ', l_debug);

    v_att := x_labor_plan_tbl(0).att;

    print_debug(' v_att is ' || v_att, l_debug);

    WHILE (p_demand_qty >= x_labor_plan_tbl(x_labor_plan_tbl.Count - 1)
          .conversion_rate AND j <= x_labor_plan_tbl.Count - 1) loop

      IF (p_demand_qty >= v_att) AND
         (v_att >= x_labor_plan_tbl(j).conversion_rate) THEN

        divider := Floor(v_att / x_labor_plan_tbl(j).conversion_rate);
        print_debug('Qty in picking uom is ' || divider, l_debug);

        x_labor_plan_tbl(j).demand_qty_picking_uom := divider;
        x_labor_plan_tbl(j).demand_quantity := v_att;
        -- x_labor_plan_tbl(j).demand_quantity := v_att;
        -- p_demand_qty := p_demand_qty - v_att;
        p_demand_qty := p_demand_qty -
                        (divider * x_labor_plan_tbl(j).conversion_rate);

        print_debug('Demand Qty is ' || v_att, l_debug);
        print_debug('Conversion rate is ' || x_labor_plan_tbl(j)
                    .conversion_rate,
                    l_debug);
        print_debug('The Picking Subinventory is ' || x_labor_plan_tbl(j)
                    .picking_subinventory,
                    l_debug);
        print_debug('The Source Subinventory is ' || x_labor_plan_tbl(j)
                    .source_subinventory,
                    l_debug);
        v_att := 0;

      ELSIF (v_att >= x_labor_plan_tbl(j).conversion_rate) then
        IF Mod(v_att, x_labor_plan_tbl(j).conversion_rate) = 0 then
          v_att := v_att - x_labor_plan_tbl(j).conversion_rate;
        ELSE
          v_att := v_att - Mod(v_att, x_labor_plan_tbl(j).conversion_rate);
        END IF;
      ELSE
        -- For Replenishment cases
        -- Dbms_Output.put_line('v_final is '||x_labor_plan_tbl(j+1).att);
        --  Dbms_Output.put_line('qty is '||qty);
        if v_replenishment_required = 'Y' then

          print_debug('Replenishment is Enabled', l_debug);
          IF j < x_labor_plan_tbl.Count - 1 then

            current_conversion_rate := x_labor_plan_tbl(j).conversion_rate;

            print_debug('Current conversion_rate is' ||
                        current_conversion_rate,
                        l_debug);

            FOR k IN j + 1 .. x_labor_plan_tbl.Count - 1 loop

              next_conversion_rate := x_labor_plan_tbl(k).conversion_rate;
              print_debug('next_conversion_rate is' ||
                          next_conversion_rate,
                          l_debug);
              low_picking_order := k;
              EXIT WHEN x_labor_plan_tbl(k) .conversion_rate < x_labor_plan_tbl(j) .conversion_rate;

            END LOOP;

            sum_qty := 0;

            FOR i IN j + 1 .. x_labor_plan_tbl.Count - 1 loop

              IF x_labor_plan_tbl(i).conversion_rate = next_conversion_rate then

                sum_qty := sum_qty + x_labor_plan_tbl(i).att;

                -- Find the subinventory first picking order in this group
                -- It shd be value of i which is j+1

              end IF;

            END LOOP;

            print_debug('sum_qty is' || sum_qty, l_debug);
            print_debug('low_picking_order is' || low_picking_order,
                        l_debug);

            IF p_demand_qty > sum_qty THEN

              IF (x_labor_plan_tbl(j)
                 .att - (x_labor_plan_tbl(j)
                  .demand_qty_picking_uom * x_labor_plan_tbl(j)
                  .conversion_rate)) >= x_labor_plan_tbl(j)
              .conversion_rate and x_labor_plan_tbl(low_picking_order)
              .source_subinventory = x_labor_plan_tbl(j)
              .picking_subinventory then

                x_labor_plan_tbl(low_picking_order).att := x_labor_plan_tbl(low_picking_order)
                                                          .att +
                                                           x_labor_plan_tbl(j)
                                                          .conversion_rate;
                x_labor_plan_tbl(j).att := x_labor_plan_tbl(j)
                                          .att - x_labor_plan_tbl(j)
                                          .conversion_rate;

                x_labor_time_tbl(n1).demand_qty_picking_uom := 1; -- As maximum of 1 plt or 1 cs will be transferred
                x_labor_time_tbl(n1).picking_uom := x_labor_plan_tbl(j)
                                                   .picking_uom;
                x_labor_time_tbl(n1).picking_subinventory := x_labor_plan_tbl(j)
                                                            .picking_subinventory;
                x_labor_time_tbl(n1).destination_subinventory := x_labor_plan_tbl(low_picking_order)
                                                                .picking_subinventory;

                print_debug('New ATT for Subinventory ' ||
                            x_labor_plan_tbl(low_picking_order)
                            .picking_subinventory || ' is ' ||
                            x_labor_plan_tbl(low_picking_order).att,
                            l_debug);

                print_debug('New ATT for Source Subinventory ' ||
                            x_labor_plan_tbl(j)
                            .picking_subinventory || ' is ' ||
                            x_labor_plan_tbl(j).att,
                            l_debug);

                n1 := n1 + 1;
                -- Dbms_Output.put_line('att j+1 is '||x_labor_plan_tbl(j+1).att);
                --Dbms_Output.put_line('qty1 is '||x_labor_plan_tbl(j+1).conversion_rate);
                -- Dbms_Output.put_line('j is '||j);

              END IF;
            END IF;
          end if;
        end if;
        j := j + 1;
        IF j <= x_labor_plan_tbl.Count - 1 then

          v_att := x_labor_plan_tbl(j).att;
          print_debug('Demand Qty is ' || v_att, l_debug);
        END IF;
      END IF;

    END LOOP;

    FOR i IN x_labor_plan_tbl.FIRST .. x_labor_plan_tbl.LAST LOOP
      /*
        print_debug('total integral value is ' || x_labor_plan_tbl(i)
                    .demand_qty_picking_uom,
                    l_debug);
        print_debug('Demand qty is ' || x_labor_plan_tbl(i).demand_quantity,
                    l_debug);
        print_debug('att is ' || x_labor_plan_tbl(i).att, l_debug);
      */
      if x_labor_plan_tbl(i).demand_qty_picking_uom <> 0 then
        x_labor_time_tbl(n1).demand_qty_picking_uom := x_labor_plan_tbl(i)
                                                      .demand_qty_picking_uom;
        x_labor_time_tbl(n1).picking_uom := x_labor_plan_tbl(i).picking_uom;
        x_labor_time_tbl(n1).picking_subinventory := x_labor_plan_tbl(i)
                                                    .picking_subinventory;
        x_labor_time_tbl(n1).destination_subinventory := v_destination_subinventory;
        print_debug('n1 is ' || n1, l_debug);
        n1 := n1 + 1;
      end if;
    END LOOP;
  exception
    when others then
      print_debug('Error in Update Labor record: ' || SQLCODE || ' : ' ||
                  SQLERRM,
                  l_debug);

  end update_bulk_labor_record;

  function get_source_subinventory(p_item_id      in number,
                                   p_subinventory in varchar2)
    return varchar2 is
    v_source_subinventory varchar2(100);

  begin

    select source_subinventory
      into v_source_subinventory
      from MTL_ITEM_SUB_INVENTORIES
     where inventory_item_id = p_item_id
       and SECONDARY_INVENTORY = p_subinventory;

    return v_source_subinventory;

  exception
    when no_data_found then
      return null;

  end get_source_subinventory;

  PROCEDURE Release_Batch_CP(errbuf           OUT NOCOPY VARCHAR2,
                             retcode          OUT NOCOPY NUMBER,
                             p_wave_header_id in number)

   is

    x_msg_count     number;
    x_return_status VARCHAR2(100);
    x_msg_data      VARCHAR2(500);
    p_BATCH_ID      NUMBER;
    P_REQUEST_ID    NUMBER;
    l_debug         NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    l_phase         VARCHAR2(100);
    l_status        VARCHAR2(100);
    l_dev_phase     VARCHAR2(100);
    l_dev_status    VARCHAR2(100);
    l_message       VARCHAR2(500);
    l_result        boolean;
  begin

    print_debug('Entered Release Batch CP - Call Create Batch Record',
                l_debug);

    create_batch_record(x_return_status, p_wave_header_id);

    print_debug('Status after Call to create batch record' ||
                x_return_status,
                l_debug);

    if x_return_status = 'S' then

      savepoint release_lines_concurrent_sp;

      UPDATE wms_wp_wave_lines
         SET message               = 'This line has been Firmed in Wave ' ||
                                     p_wave_header_id,
             remove_from_Wave_flag = 'Y'
       WHERE delivery_detail_id IN
             (SELECT delivery_detail_id
                FROM wms_wp_wave_lines
               WHERE wave_header_id = p_wave_header_id
                 and nvl(remove_from_wave_flag, 'N') <> 'Y')
         and wave_header_id <> p_wave_header_id;

      update wms_wp_wave_headers_vl
         set wave_firmed_flag = 'Y'
       where wave_header_id = p_wave_header_id;

      --  commit;

      WSH_PICKING_BATCHES_GRP.release_wms_wave(p_release_mode        => 'CONCURRENT',
                                               p_pick_wave_header_id => p_wave_header_id,
                                               x_request_id          => p_request_id,
                                               X_RETURN_STATUS       => X_RETURN_STATUS,
                                               X_MSG_COUNT           => X_MSG_COUNT,
                                               X_MSG_DATA            => X_MSG_DATA,
                                               P_BATCH_REC           => new_wave_type, --???????g_wave_release_attribute_Rec
                                               X_BATCH_ID            => p_BATCH_ID);

      /* update wms_wp_wave_headers_vl
        set request_id = p_request_id
      where wave_header_id = p_wave_header_id;*/

      --Making our concurrent program wait till the pick release concurrent program is complete
      l_result := FND_CONCURRENT.WAIT_FOR_REQUEST(request_id => p_request_id,
                                                  phase      => l_phase,
                                                  status     => l_status,
                                                  dev_phase  => l_dev_phase,
                                                  dev_status => l_dev_status,
                                                  message    => l_message);

      l_result := FND_CONCURRENT.SET_COMPLETION_STATUS(status  => l_status,
                                                       message => '');

      -- Need to firm the wave as releasing it will firm the wave
      /*if X_RETURN_STATUS = 'S' then

        UPDATE wms_wp_wave_lines
           SET message               = 'This line has been Firmed in Wave ' ||
                                       p_wave_header_id,
               remove_from_Wave_flag = 'Y'
         WHERE delivery_detail_id IN
               (SELECT delivery_detail_id
                  FROM wms_wp_wave_lines
                 WHERE wave_header_id = p_wave_header_id
                   and nvl(remove_from_wave_flag, 'N') <> 'Y')
           and wave_header_id <> p_wave_header_id;

        update wms_wp_wave_headers_vl
           set wave_firmed_flag = 'Y'
         where wave_header_id = p_wave_header_id;

      end if; */

      if x_return_status = 'S' then
        -- To take the Warning Status
        print_debug('Updating Wave Header Status after Calling Release Wave Concurrently',
                    l_debug);
        update_wave_header_status(x_return_status,
                                  p_wave_header_id,
                                  'Released');
        get_actual_fill_rate(x_return_status, p_wave_header_id);

        print_debug('Status after Call to Get the Actual Fill Rate' ||
                    x_return_status,
                    l_debug);

        commit;

elsif x_return_status = 'W'  then
	  print_debug('Updating Wave Header Status after Calling Release Wave Concurrently',
                    l_debug);
        update_wave_header_status(x_return_status,
                                  p_wave_header_id,
                                  'Released(Warning)');
        get_actual_fill_rate(x_return_status, p_wave_header_id);

        print_debug('Status after Call to Get the Actual Fill Rate' ||
                    x_return_status,
                    l_debug);

        commit;

      else

        rollback to release_lines_concurrent_sp;
      end if;

    end if;

  end Release_Batch_CP;

  /*function get_packed_status(p_task_id in number) return boolean

     is
      l_packed_result number := 1;
      l_debug         NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    begin

      print_debug('In Get Packed Status task id is ' || p_task_id, l_debug);


      select Decode(wlpn.lpn_context,
                    11,
                    Decode(mil.inventory_location_type, 4, 0, 5, 0,1),
                    1)
        into l_packed_result
        from mtl_material_transactions   mmt,
             wms_license_plate_numbers wlpn,
             mtl_item_locations_kfv    mil
       where mmt.transfer_lpn_id = wlpn.lpn_id
       and mmt.transaction_id=p_task_id
         and mmt.transfer_locator_id = mil.INVENTORY_LOCATION_ID
         and mmt.transfer_organization_id = mil.ORGANIZATION_ID;


      select Decode(mil.inventory_location_type, 4, 0, 5, 0, 1)
        into l_packed_result
        from wsh_delivery_details      wdd,
             mtl_material_transactions mmt,
             mtl_item_locations_kfv    mil
       where mmt.transaction_id = p_task_id
         and mmt.transaction_id = wdd.transaction_id
         and wdd.locator_id = mil.INVENTORY_LOCATION_ID;

      if l_packed_result = 0 then
        return true;
        print_debug('In Get Packed Status task id is ' || p_task_id ||
                    ' is packed',
                    l_debug);
      else
        return false;
        print_debug('In Get Packed Status task id is ' || p_task_id ||
                    ' is not  packed',
                    l_debug);
      end if;

    exception
      when others then
        print_debug('Error in Get Packed Status: ' || SQLCODE || ' : ' ||
                    SQLERRM,
                    l_debug);
        return false;

    end get_packed_status;
  */
  function check_min_equip_Capacity(l_mmtt_tbl in number_table_type)
    return boolean is

    g_newline CONSTANT VARCHAR2(10) := fnd_global.newline;
    l_debug            NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),
                                     0);
    g_bulk_fetch_limit NUMBER := 1000;

    g_hash_base  NUMBER := 1;
    g_hash_size  NUMBER := POWER(2, 25);
    sum_capacity number := 0;
    sum_qty      number := 0;

    l_item_vol             NUMBER; --item unit volume
    l_item_v_uom           VARCHAR2(3); --item unit volume UOM
    l_equip_v_uom          VARCHAR2(3); -- equipment volume UOM
    l_equip_vol            NUMBER; --equipment volume capacity
    l_eqp_capacity         NUMBER;
    l_minimum_fill_percent number;
    l_eq_it_v_uom_ratio    NUMBER := 1; --conversion ratio between equipment volume capacity and item unit volume UOM
    l_txn_pri_uom_ratio    NUMBER; --conversion rate between transaction uom and item primary UOM
    l_txn_uom_code         VARCHAR2(3); --transaction uom_code
    l_item_id              NUMBER;
    l_init_qty             NUMBER;
    l_item_prim_uom_code   VARCHAR2(3); --primary uom_code
    l_min_cap              NUMBER; --minimum equipment capacity for a task
    l_min_cap_temp         NUMBER;
    l_new_qty              NUMBER;
    p_task_id              number;
    l_organization_id      number;

    CURSOR c_eqp_capacity(p_task_id NUMBER) IS
      SELECT distinct res_equip.inventory_item_id
        FROM mtl_material_transactions_temp mmtt,
             bom_resource_equipments        res_equip,
             bom_resources                  res,
             bom_std_op_resources           tt_x_res
       WHERE mmtt.transaction_temp_id = p_task_id
         AND mmtt.standard_operation_id = tt_x_res.standard_operation_id
         AND tt_x_res.resource_id = res.resource_id
         AND res.resource_type = 1
         AND res_equip.resource_id = tt_x_res.resource_id;

  begin

    for i in l_mmtt_tbl.FIRST .. l_mmtt_tbl.LAST loop

      SELECT mmtt.transaction_uom,
             mmtt.inventory_item_id,
             mmtt.transaction_quantity,
             item.primary_uom_code,
             item.organization_id
        INTO l_txn_uom_code,
             l_item_id,
             l_init_qty,
             l_item_prim_uom_code,
             l_organization_id
        FROM mtl_material_transactions_temp mmtt,
             mtl_item_locations             mil,
             mtl_secondary_inventories      msi,
             mtl_system_items               item
       WHERE mmtt.transaction_temp_id = l_mmtt_tbl(i)
         AND mmtt.locator_id = mil.inventory_location_id(+)
         AND mmtt.organization_id = mil.organization_id(+)
         AND mmtt.subinventory_code = msi.secondary_inventory_name
         AND mmtt.organization_id = msi.organization_id
         AND mmtt.inventory_item_id = item.inventory_item_id
         AND mmtt.organization_id = item.organization_id;

      l_min_cap := -9999;

      sum_qty := sum_qty + l_init_qty;

      IF (l_txn_uom_code IS NULL OR l_item_id IS NULL OR l_init_qty IS NULL OR
         l_item_prim_uom_code IS NULL) THEN

        print_debug('Necessary UOM information is missing for task: ' ||
                    l_mmtt_tbl(i),
                    l_Debug);
        RETURN TRUE;
      END IF;

      IF l_txn_uom_code = l_item_prim_uom_code THEN
        -- {
        l_txn_pri_uom_ratio := 1;
      ELSE

        --Compute conversion ratio between transaction UOM and item primary UOM
        inv_convert.inv_um_conversion(from_unit => l_txn_uom_code,
                                      to_unit   => l_item_prim_uom_code,
                                      item_id   => l_item_id,
                                      uom_rate  => l_txn_pri_uom_ratio);
      END IF; -- }

      IF (l_txn_pri_uom_ratio = -99999) THEN
        -- { uom conversion failure
        print_debug('txn/item uom ratio calculation failed for task: ' ||
                    l_mmtt_tbl(i),
                    l_debug);
        RETURN TRUE;
      END IF; -- }

      print_debug('UOM conversion data:' ||
                  TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),
                  l_debug);
      print_debug('l_txn_pri_uom_ratio => ' || l_txn_pri_uom_ratio,
                  l_debug);

      IF (inv_cache.set_item_rec(l_organization_id, l_item_id)) THEN
        -- {
        l_item_v_uom := inv_cache.item_rec.volume_uom_code;
        l_item_vol   := inv_cache.item_rec.unit_volume;
      END IF;

      IF l_item_v_uom IS NOT NULL THEN
        -- {
        OPEN c_eqp_capacity(l_mmtt_tbl(i));
        LOOP
          -- {  --Equipment loop
          FETCH c_eqp_capacity
            INTO l_eqp_capacity;
          EXIT WHEN c_eqp_capacity%NOTFOUND;

          IF (inv_cache.set_item_rec(l_organization_id, l_eqp_capacity)) THEN
            -- {
            l_equip_v_uom          := inv_cache.item_rec.volume_uom_code;
            l_equip_vol            := inv_cache.item_rec.internal_volume;
            l_minimum_fill_percent := inv_cache.item_rec.minimum_fill_percent;
          END IF; -- }

          IF (l_equip_vol IS NOT NULL AND l_item_vol IS NOT NULL) THEN
            -- {
            l_eq_it_v_uom_ratio := -9999;
            l_min_cap_temp      := -9999;
          END IF; -- }

          IF (l_item_v_uom IS NOT NULL AND l_equip_v_uom IS NOT NULL) THEN
            -- {
            IF l_equip_v_uom = l_item_v_uom THEN
              -- {
              l_eq_it_v_uom_ratio := 1;
            ELSE
              inv_convert.inv_um_conversion(from_unit => l_equip_v_uom,
                                            to_unit   => l_item_v_uom,
                                            item_id   => 0,
                                            uom_rate  => l_eq_it_v_uom_ratio);
            END IF; -- }
          END IF; -- }

          print_debug('l_equip_vol = ' || l_equip_vol, l_debug);
          print_debug('l_item_vol = ' || l_item_vol, l_debug);
          print_debug('l_eq_it_v_uom_ratio = ' || l_eq_it_v_uom_ratio,
                      l_debug);

          IF l_eq_it_v_uom_ratio <> -9999 THEN
            l_min_cap_temp := TRUNC((l_equip_vol * l_eq_it_v_uom_ratio *
                                    (l_minimum_fill_percent / 100)) /
                                    l_item_vol);
            IF (l_min_cap_temp = 0) THEN
              -- {
              l_min_cap_temp := (l_equip_vol * l_eq_it_v_uom_ratio) /
                                l_item_vol;
            end if;
          ELSE
            print_debug('Both eqp/item volume and eqp/item weight uom ratio calculation failed' ||
                        TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),
                        l_debug);

          END IF; -- }

          print_debug('l_min_cap_temp = ' || l_min_cap_temp, l_debug);
          print_debug('l_min_cap = ' || l_min_cap, l_debug);

          IF ((l_min_cap_temp <> -9999 AND l_min_cap_temp < l_min_cap) OR
             l_min_cap = -9999) THEN
            -- {
            l_min_cap := l_min_cap_temp;

            --       END IF ;  -- }
          ELSE
            print_debug('Eqp/it vol is not defined: ' ||
                        TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),
                        l_debug);
            RETURN TRUE;
          END IF; -- }

        END LOOP; -- }   End of Equipment loop

        CLOSE c_eqp_capacity;

      end if;

      --sum_capacity := l_min_cap + sum_capacity;
      sum_capacity := l_min_cap;

      IF (l_min_cap = -9999) THEN
        -- {
        print_debug('invalid capacity for all equipment' ||
                    TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),
                    l_Debug);
        RETURN TRUE;
      END IF; -- }

    end loop;

    print_debug('Sum of Capacity for all tasks in user task type is  ' ||
                sum_capacity,
                l_Debug);
    print_debug('Sum of transaction qty  for all tasks in user task type is  ' ||
                sum_qty,
                l_Debug);

    if sum_qty >= sum_capacity then

      return true;

    else

      return false;

    end if;

  exception

    when others then
      print_debug('Error in Get Minimum Equipment Capacity : ' || SQLCODE ||
                  ' : ' || SQLERRM,
                  l_debug);
      return false;
  end check_min_equip_Capacity;

  function get_tasks_exist(p_consol_locator_id in number,
                           p_delivery_id       in number)

   return boolean

   IS

    l_mmtt_count number;
    l_debug      NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'), 0);
  begin

    SELECT count(distinct mmtt.transaction_temp_id)
      into l_mmtt_count
      FROM mtl_material_transactions_temp mmtt,
           wsh_Delivery_details           wdd,
           WSH_NEW_DELIVERIES             WND,
           WSH_DELIVERY_ASSIGNMENTS       WDA
     WHERE wdd.source_line_id = mmtt.trx_source_line_id
       AND WND.DELIVERY_ID(+) = WDA.DELIVERY_ID
       AND WDA.DELIVERY_DETAIL_ID = WDD.DELIVERY_DETAIL_ID
       and mmtt.transfer_to_location = p_consol_locator_id
       and mmtt.wms_task_status <> 8
       and wnd.delivery_id <> p_delivery_id
       and wnd.delivery_id is not null;

    print_debug('Count of Tasks that are already  been worked upon in the Consolidation Locator' ||
                l_mmtt_count,
                l_Debug);

    if l_mmtt_count > 0 then

      return false;

    else

      return true;

    end if;

  exception

    when others then

      return false;

  end get_tasks_exist;

  function get_tasks_exist(p_consol_locator_id in number)

   return boolean

   IS
    l_mmtt_count number;
    l_debug      NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'), 0);
  begin

    SELECT count(distinct mmtt.transaction_temp_id)
      into l_mmtt_count
      FROM mtl_material_transactions_temp mmtt,
           wsh_Delivery_details           wdd,
           WSH_NEW_DELIVERIES             WND,
           WSH_DELIVERY_ASSIGNMENTS       WDA
     WHERE wdd.source_line_id = mmtt.trx_source_line_id
       AND WND.DELIVERY_ID(+) = WDA.DELIVERY_ID
       AND WDA.DELIVERY_DETAIL_ID = WDD.DELIVERY_DETAIL_ID
       and mmtt.wms_task_status <> 8
       and mmtt.transfer_to_location = p_consol_locator_id
       and wnd.delivery_id is not null;

    print_debug('Count of Tasks that are already  been worked upon in the Consolidation Locator' ||
                l_mmtt_count,
                l_Debug);

    if l_mmtt_count > 0 then

      return false;

    else

      return true;

    end if;

  exception

    when others then

      return false;

  end get_tasks_exist;

  PROCEDURE Task_Release_CP(errbuf            OUT NOCOPY VARCHAR2,
                            retcode           OUT NOCOPY NUMBER,
                            p_organization_id in number,
                            p_query_name      in varchar2,
                            p_task_release_id in number) is

    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

    CURSOR c_saved_queries(p_query_name VARCHAR2) IS
      select field_name,
             --ltrim(rtrim(field_value)) field_value,
             field_value,
             organization_id,
             query_type
        from wms_saved_queries
       where query_name = p_query_name
         and (query_type = 'TASK_PLANNING' or
             query_type = 'TEMP_TASK_PLANNING')
         FOR UPDATE NOWAIT;

    cursor c_wave_temp is
      select transaction_temp_id,
             status,
             status_id,
             task_type,
             task_type_id,
             source_header
        from wms_waveplan_tasks_temp;

    cursor c_mmtt is
      select distinct transaction_temp_id from wms_waveplan_tasks_temp;

    rec_saved_queries c_saved_queries%rowtype;

    l_field_name_table      wms_wave_planning_pvt.field_name_table_type;
    l_field_value_table     wms_wave_planning_pvt.field_value_table_type;
    l_organization_id_table wms_wave_planning_pvt.organization_id_table_type;
    l_query_type_table      wms_wave_planning_pvt.query_type_table_type;

    l_return_status VARCHAR2(1);
    l_msg_data      VARCHAR2(120);
    l_msg_count     NUMBER;
    l_save_count    NUMBER;
    l_return_msg    VARCHAR2(120);
    l_record_count  NUMBER;

    l_query_name     varchar2(100);
    l_return_message VARCHAR2(4000);
    -- l_count          number := 0;
    -- Replenishment Complete declaration section
    p_carton_grouping_id number;
    l_mmtt_table         number_table_type;
    l_mmtt_table2        number_table_type;
    l_final_mmtt_table   number_table_type;
    no_of_tasks          number := 0;
    --   no_of_rc_tasks       number := 0;
    --p_batch_id           number;

    CURSOR c_carton_grouping_id IS
      SELECT DISTINCT carton_grouping_id
        FROM wms_waveplan_tasks_temp wwtt,
             mtl_txn_request_lines   mtrl,
             wsh_Delivery_details    wdd
       WHERE wwtt.move_order_line_id = mtrl.line_id
         and wdd.source_line_id = wwtt.transaction_source_line_id
         and wwtt.transaction_temp_id in
             (select transaction_temp_id
                from wms_wp_tp_mmtt
               where indicator_flag = 'C')
         and wwtt.status_id = 8; --- Ajith????????????
    --  order by wdd.shipment_priority_code;

    CURSOR c_rc_wdds is
      SELECT distinct wdd.delivery_detail_id
        FROM mtl_material_transactions_temp mmtt,
             mtl_txn_request_lines          mtrl,
             wsh_Delivery_details           wdd
       WHERE mmtt.move_order_line_id = mtrl.line_id
         AND wdd.source_line_id = mmtt.trx_source_line_id
         AND Nvl(wdd.REPLENISHMENT_STATUS, 'C') = 'C'
         AND mtrl.carton_grouping_id = p_carton_grouping_id;

    CURSOR c_rr_wdds is
      SELECT distinct wdd.delivery_detail_id
        FROM wsh_Delivery_details wdd
       where wdd.REPLENISHMENT_STATUS = 'R'
         and (wdd.batch_id in
             (SELECT batch_id
                 FROM wsh_Delivery_details           wdd,
                      mtl_txn_request_lines          mtrl,
                      mtl_material_transactions_temp mmtt
                where mmtt.move_order_line_id = mtrl.line_id
                  AND wdd.source_line_id = mmtt.trx_source_line_id
                  AND mtrl.carton_grouping_id = p_carton_grouping_id) or
             wdd.batch_id in
             (select distinct SELECTED_BATCH_ID
                 from WSH_PICKING_BATCHES            wpb,
                      mtl_txn_request_lines          mtrl,
                      wsh_delivery_details           wdd2,
                      mtl_material_transactions_temp mmtt
                where mmtt.move_order_line_id = mtrl.line_id
                  AND wdd2.source_line_id = mmtt.trx_source_line_id
                  AND wpb.batch_id = wdd2.batch_id
                  AND mtrl.carton_grouping_id = p_carton_grouping_id));

    CURSOR c_rc_tasks is
      SELECT wwtt.transaction_temp_id
        FROM wms_waveplan_tasks_temp wwtt, mtl_txn_request_lines mtrl
       WHERE wwtt.move_order_line_id = mtrl.line_id
         and wwtt.transaction_temp_id in
             (select transaction_temp_id
                from wms_wp_tp_mmtt
               where indicator_flag = 'C')
         AND mtrl.carton_grouping_id = p_carton_grouping_id;

    -- Minimum Equipment Capacity

    CURSOR c_task_type is
      SELECT DISTINCT wwtt.user_task_type
        FROM wms_waveplan_tasks_temp wwtt;
    /*
    p_user_task_type varchar2(4);

             CURSOR c_tasktype_mmtt(p_user_task_type) is
          SELECT wwtt.transaction_temp_id transaction_temp_id
            FROM wms_waveplan_tasks_temp  wwtt
            WHERE user_task_type=p_user_task_type;

    */
    -- Reverse Trip Stop

    l_Stop_id number;
    l_trip_id number;
    j         number;

    CURSOR c_get_trip is
      SELECT distinct wts.trip_id trip_id
        FROM wms_waveplan_tasks_temp  wwtt,
             wsh_Delivery_details     wdd,
             WSH_NEW_DELIVERIES       WND,
             WSH_DELIVERY_ASSIGNMENTS WDA,
             WSH_TRIP_STOPS           WTS,
             WSH_DELIVERY_LEGS        WLG
       WHERE WND.DELIVERY_ID(+) = WDA.DELIVERY_ID
         AND wdd.source_line_id = wwtt.transaction_source_line_id
         AND WDA.DELIVERY_DETAIL_ID = WDD.DELIVERY_DETAIL_ID
         AND WTS.STOP_ID(+) = WLG.DROP_OFF_STOP_ID
         AND WLG.DELIVERY_ID(+) = WND.DELIVERY_ID
         and wwtt.transaction_temp_id in
             (select transaction_temp_id
                from wms_wp_tp_mmtt
               where indicator_flag = 'F') --- Ajith????????????
         and wwtt.status_id = 8
         and wts.trip_id is not null; --  Get All Trips for tasks  in UnReleased Status

    CURSOR c_get_trip_Stop is
      SELECT distinct wts.stop_id stop_id, wts.STOP_SEQUENCE_NUMBER
        FROM mtl_material_transactions_temp mmtt,
             wsh_Delivery_details           wdd,
             WSH_NEW_DELIVERIES             WND,
             WSH_DELIVERY_ASSIGNMENTS       WDA,
             WSH_TRIP_STOPS                 WTS,
             WSH_DELIVERY_LEGS              WLG
       WHERE WND.DELIVERY_ID(+) = WDA.DELIVERY_ID
         and wts.trip_id = l_trip_id
         AND wdd.source_line_id = mmtt.trx_source_line_id
         AND WDA.DELIVERY_DETAIL_ID = WDD.DELIVERY_DETAIL_ID
         AND WTS.STOP_ID(+) = WLG.DROP_OFF_STOP_ID
         AND WLG.DELIVERY_ID(+) = WND.DELIVERY_ID
       ORDER BY wts.STOP_SEQUENCE_NUMBER desc;

    CURSOR c_get_mmtt is
      SELECT distinct mmtt.transaction_temp_id transaction_temp_id
        FROM mtl_material_transactions_temp mmtt,
             wsh_Delivery_details           wdd,
             WSH_NEW_DELIVERIES             WND,
             WSH_DELIVERY_ASSIGNMENTS       WDA,
             WSH_TRIP_STOPS                 WTS,
             WSH_DELIVERY_LEGS              WLG
       WHERE wts.stop_id = l_stop_id
         AND wdd.source_line_id = mmtt.trx_source_line_id
         AND WND.DELIVERY_ID(+) = WDA.DELIVERY_ID
         AND WDA.DELIVERY_DETAIL_ID = WDD.DELIVERY_DETAIL_ID
         AND WTS.STOP_ID(+) = WLG.DROP_OFF_STOP_ID
         AND WLG.DELIVERY_ID(+) = WND.DELIVERY_ID
      /*   and wwtt.transaction_temp_id in
                         (select transaction_temp_id
                            from wms_wp_tp_mmtt
                           where indicator_flag = 'F') --- Ajith???????????? */
      --    AND wwtt.status_id <> 6
      --  ORDER BY wts.STOP_SEQUENCE_NUMBER desc
      union
      SELECT distinct mmt.transaction_id transaction_temp_id
        FROM mtl_material_transactions mmt,
             wsh_Delivery_details      wdd,
             WSH_NEW_DELIVERIES        WND,
             WSH_DELIVERY_ASSIGNMENTS  WDA,
             WSH_TRIP_STOPS            WTS,
             WSH_DELIVERY_LEGS         WLG
       WHERE wts.stop_id = l_stop_id
         AND wdd.source_line_id = mmt.trx_source_line_id
         AND WND.DELIVERY_ID(+) = WDA.DELIVERY_ID
         AND WDA.DELIVERY_DETAIL_ID = WDD.DELIVERY_DETAIL_ID
         AND WTS.STOP_ID(+) = WLG.DROP_OFF_STOP_ID
         AND WLG.DELIVERY_ID(+) = WND.DELIVERY_ID
      /*   and wwtt.transaction_temp_id in
                         (select transaction_temp_id
                            from wms_wp_tp_mmtt
                           where indicator_flag = 'F') --- Ajith???????????? */
      --    AND wwtt.status_id <> 6
      --   ORDER BY wts.STOP_SEQUENCE_NUMBER desc
      ;

    -- Consolidation Locator

    CURSOR c_consol_locator IS
      select distinct wwtt.to_locator_id, wwtt.to_locator
        from wms_waveplan_tasks_temp wwtt, mtl_item_locations_kfv mil
       where wwtt.to_locator_id = mil.inventory_location_id
         and wwtt.to_organization_id = mil.organization_id
         and mil.inventory_location_type in (4, 5)
         and wwtt.transaction_temp_id in
             (select transaction_temp_id
                from wms_wp_tp_mmtt
               where indicator_flag = 'T') --- Ajith????????????
         and wwtt.status_id = 8; -- We get only the Un Released Lines Delivery.

    p_consol_locator_id number;

    p_delivery_id number;

    cursor c_delivery is
      select distinct wnd.delivery_id
        from wsh_delivery_details     wdd,
             wsh_new_deliveries       wnd,
             wsh_delivery_details     wdd2,
             wsh_delivery_assignments wda
       where wdd2.
       lpn_id in (select distinct lpn_id
                          from mtl_onhand_quantities_detail moqd
                         where locator_id = p_consol_locator_id)
         and WND.DELIVERY_ID(+) = WDA.DELIVERY_ID
         AND WDA.DELIVERY_DETAIL_ID = WDD.DELIVERY_DETAIL_ID
         AND wda.parent_delivery_detail_id = wdd2.delivery_detail_id(+);

    -- Get all WDDS that are in Released to Warehouse and Staged status
    cursor c_wdd_delivery is
      select wdd.delivery_detail_id
        from wsh_delivery_details     wdd,
             wsh_delivery_assignments wda,
             wsh_new_deliveries       wnd
       where wnd.delivery_id = p_delivery_id
         and WND.DELIVERY_ID(+) = WDA.DELIVERY_ID
         AND WDA.DELIVERY_DETAIL_ID = WDD.DELIVERY_DETAIL_ID
         and wdd.released_status in ('Y', 'S');

    cursor c_wdd_Staged is
      select wdd.delivery_detail_id
        from wsh_delivery_details     wdd,
             wsh_delivery_assignments wda,
             wsh_new_deliveries       wnd
       where wnd.delivery_id = p_delivery_id
         and WND.DELIVERY_ID(+) = WDA.DELIVERY_ID
         AND WDA.DELIVERY_DETAIL_ID = WDD.DELIVERY_DETAIL_ID
         and wdd.released_status in ('Y');

    l_wdd_count number;

    l_wdd_staged_count number;

    CURSOR c_delivery_mmtt IS
      SELECT DISTINCT WND.DELIVERY_ID delivery_id
        FROM wms_waveplan_tasks_temp  wwtt,
             wsh_Delivery_details     wdd,
             WSH_NEW_DELIVERIES       WND,
             WSH_DELIVERY_ASSIGNMENTS WDA
       WHERE wdd.source_line_id = wwtt.transaction_source_line_id
         and wwtt.transaction_temp_id in
             (select transaction_temp_id
                from wms_wp_tp_mmtt
               where indicator_flag = 'T') --- Ajith????????????
         AND WND.DELIVERY_ID(+) = WDA.DELIVERY_ID
         AND WDA.DELIVERY_DETAIL_ID = WDD.DELIVERY_DETAIL_ID
         and wwtt.status_id = 8 -- We get only the Un Released Lines Delivery.
         and wwtt.to_locator_id = p_consol_locator_id
       order by WND.DELIVERY_ID;

    p_delivery_mmtt_id number;

    -- We get all the tasks for the delivery.
    CURSOR c_get_mmtt_delivery(p_delivery_mmtt_id in number) is
      SELECT distinct wwtt.transaction_temp_id transaction_temp_id
        FROM wms_waveplan_tasks_temp  wwtt,
             wsh_Delivery_details     wdd,
             WSH_NEW_DELIVERIES       WND,
             WSH_DELIVERY_ASSIGNMENTS WDA
       WHERE WND.DELIVERY_ID = p_delivery_mmtt_id
         and wdd.source_line_id = wwtt.transaction_source_line_id
         and wwtt.transaction_temp_id in
             (select transaction_temp_id
                from wms_wp_tp_mmtt
               where indicator_flag = 'T')
         AND WND.DELIVERY_ID(+) = WDA.DELIVERY_ID
         AND WDA.DELIVERY_DETAIL_ID = WDD.DELIVERY_DETAIL_ID;

    l_unreleased_count number := 0;

    l_delivery_count number;
    -- l_packed_count           number;
    l_completed_task_count  number;
    l_total_completed_count number := 0;
    v_task_count            number := 0;
    v_final_completed_flag  varchar2(1) := 'Y';
    --  v_completed_flag         varchar2(1);
    l_wdd_table              number_table_type;
    l_wdd_table1             number_table_type;
    l_wdd_table2             number_table_type;
    l_wdd_table3             number_table_type;
    l_replenishment_complete VARCHAR2(1);
    l_fill_capacity          VARCHAR2(1);
    l_reverse_trip_Stop      VARCHAR2(1);
    l_consol_locator         VARCHAR2(1);
    l_custom_flag            VARCHAR2(1);
    l_trip_tolerance         number;
    l_dummy_delivery         number;
    --  no_of_tasks_delivery     number := 0;
    l_replen_tolerance       number;
    l_cons_locator_tolerance number;
    l_custom_plan_tolerance  number;
    l_release_delivery       varchar2(1) := 'N';
    l_table_count            number;
    --no_of_packed_tasks       number := 0;
    -- process_next_delivery    varchar2(1) := 'Y';
    -- l_first_time             varchar2(1) := 'Y';
    --   k2                       number := 0;
    l_sum_qty number := 0;

    --Catronization
    l_cartonization_required VARCHAR2(1);
    --  l_move_order_line_id     varchar2(4000);
    l_mmtt_char varchar2(4000);

    --  cartonization_profile        VARCHAR2(1)   := 'Y';
    v_cart_value             NUMBER;
    l_cartonize_sales_orders VARCHAR2(1) := NULL;

    cursor c_carton_lines is
      select wdd.delivery_Detail_id, mmtt.move_order_line_id
      -- into p_line_rows(l1), p_move_order_line_tbl(l1)
        from wsh_delivery_details wdd, mtl_material_transactions_temp mmtt
       where wdd.Source_line_id = mmtt.trx_source_line_id
         AND Nvl(wdd.REPLENISHMENT_STATUS, 'C') = 'C'
         and to_char(mmtt.transaction_temp_id) in
             (SELECT TRIM(SUBSTR(txt,
                                 INSTR(txt, ',', 1, level) + 1,
                                 INSTR(txt, ',', 1, level + 1) -
                                 INSTR(txt, ',', 1, level) - 1)) AS token
                FROM (SELECT ',' || l_mmtt_char || ',' AS txt FROM dual)
              CONNECT BY level <=
                         LENGTH(txt) - LENGTH(REPLACE(txt, ',', '')) - 1);

    /*    cursor c_move_order_header is
    select distinct HEADER_ID
      from mtl_txn_request_lines
     where to_char(line_id) in
           (SELECT TRIM(SUBSTR(txt,
                               INSTR(txt, ',', 1, level) + 1,
                               INSTR(txt, ',', 1, level + 1) -
                               INSTR(txt, ',', 1, level) - 1)) AS token
              FROM (SELECT ',' || l_move_order_line_id || ',' AS txt
                      FROM dual)
            CONNECT BY level <=
                       LENGTH(txt) - LENGTH(REPLACE(txt, ',', '')) - 1);*/

    l_attr_tab            wsh_delivery_autocreate.grp_attr_tab_type;
    l_action_rec          wsh_delivery_autocreate.action_rec_type;
    l_target_rec          wsh_delivery_autocreate.grp_attr_rec_type;
    l_group_info          wsh_delivery_autocreate.grp_attr_tab_type;
    l_matched_entities    wsh_util_core.id_tab_type;
    l_out_rec             wsh_delivery_autocreate.out_rec_type;
    p_line_rows           wsh_util_core.id_tab_type;
    p_carton_grouping_tbl inv_move_order_pub.num_tbl_type;
    p_move_order_line_tbl inv_move_order_pub.num_tbl_type;
    l_match_found         boolean;
    x_return_status       varchar2(1);

    -- For Creating Move Order Header

    l_trohdr_rec       INV_Move_Order_PUB.Trohdr_Rec_Type;
    l_trohdr_val_rec   INV_Move_Order_PUB.Trohdr_Val_Rec_Type;
    l_x_trohdr_rec     INV_Move_Order_PUB.Trohdr_Rec_Type;
    l_x_trohdr_val_rec INV_Move_Order_PUB.Trohdr_Val_Rec_Type;
    l_commit           VARCHAR2(1) := FND_API.G_TRUE;

    TYPE group_match_seq_rec_type IS RECORD(
      delivery_detail_id NUMBER,
      match_group_id     NUMBER,
      delivery_group_id  NUMBER);

    TYPE group_match_seq_tab_type IS TABLE OF group_match_seq_rec_type INDEX BY BINARY_INTEGER;

    l_group_match_seq_tbl group_match_seq_tab_type;

    --  p_move_order_hdr_tbl num_tab;

    l_repl_tasks number := 0;

    l_replcom_tasks number := 0;
    l_temp          number;
    line_count      number := 1;
  begin

    l_record_count            := 0;
    l_is_unreleased           := FALSE;
    l_is_pending              := FALSE;
    l_is_queued               := FALSE;
    l_is_dispatched           := FALSE;
    l_is_active               := FALSE;
    l_is_loaded               := FALSE;
    l_is_completed            := FALSE;
    l_include_inbound         := FALSE;
    l_include_outbound        := FALSE;
    l_include_crossdock       := FALSE;
    l_include_manufacturing   := FALSE;
    l_include_warehousing     := FALSE;
    l_include_sales_orders    := FALSE;
    l_include_internal_orders := FALSE;
    l_include_replenishment   := FALSE;
    l_include_mo_transfer     := FALSE;
    l_include_mo_issue        := FALSE;
    l_include_lpn_putaway     := FALSE;
    l_include_staging_move    := FALSE;
    l_include_cycle_count     := FALSE;
    l_is_pending_plan         := FALSE;
    l_is_inprogress_plan      := FALSE;
    l_is_completed_plan       := FALSE;
    l_is_cancelled_plan       := FALSE;
    l_is_aborted_plan         := FALSE;
    l_query_independent_tasks := FALSE;
    l_query_planned_tasks     := FALSE;

    OPEN c_saved_queries(p_query_name);

    FETCH c_saved_queries BULK COLLECT
      INTO l_field_name_table, l_field_value_table, l_organization_id_table, l_query_type_table;

    -- If no records founds for the given query name
    -- then close the cursor and return informing invalid query name.

    print_DEBUG('c_saved_queries%ROWCOUNT = ' || c_saved_queries%ROWCOUNT,
                l_debug);

    IF c_saved_queries%ROWCOUNT = 0 THEN
      CLOSE c_saved_queries;
      print_DEBUG('No data found for query name = ' || p_query_name,
                  l_debug);
      --x_rowcount      := 0;
      --  x_return_status := fnd_api.g_ret_sts_success;
      --  x_return_message:= 'No data found for query name = ' || p_query_name ;

      RETURN;
    END IF;

    CLOSE c_saved_queries;

    print_DEBUG('field_name_table.count ' || l_field_name_table.count,
                l_debug);

    print_DEBUG('Bulk collect from c_saved_queries successful and closed c_saved_queries cursor',
                l_debug);

    print_DEBUG('Calling SET_QUERY_TASKS_PARAMETERS', l_Debug);

    SET_QUERY_TASKS_PARAMETERS(p_field_name_table      => l_field_name_table,
                               p_field_value_table     => l_field_value_table,
                               p_organization_id_table => l_organization_id_table,
                               p_query_type_table      => l_query_type_table,
                               x_return_status         => l_return_status,
                               x_return_message        => l_return_message);

    print_DEBUG('SET_QUERY_TASKS_PARAMETERS return status = ' ||
                l_return_status,
                l_debug);
    print_DEBUG('SET_QUERY_TASKS_PARAMETERS return message = ' ||
                l_return_message,
                l_debug);

    IF l_return_status = fnd_api.g_ret_sts_error OR
       l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      print_DEBUG(' Error in SET_QUERY_TASKS_PARAMETERS ', l_debug);
      return;
    END IF;

    select replen_completed_flag,
           nvl(replen_tolerance, 0),
           min_equip_capacity_flag,
           rev_trip_stop_flag,
           nvl(trip_stop_tolerance, 0),
           cons_locator_flag,
           nvl(cons_locator_tolerance, 0),
           custom_task_plan_flag,
           nvl(custom_plan_tolerance, 0)
      into l_replenishment_complete,
           l_replen_tolerance,
           l_fill_capacity,
           l_reverse_trip_Stop,
           l_trip_tolerance,
           l_consol_locator,
           l_cons_locator_tolerance,
           l_custom_flag,
           l_custom_plan_tolerance
      from wms_task_Release_vl
     where criteria_id = p_task_release_id;

    if l_reverse_trip_Stop = 'Y' or l_consol_locator = 'Y' or
       l_replenishment_complete = 'Y' THEN

      -- We will be querying only for UnReleased Tasks

      l_is_queued             := FALSE;
      l_is_dispatched         := FALSE;
      l_is_active             := FALSE;
      l_is_loaded             := FALSE;
      l_is_completed          := FALSE;
      l_is_pending            := FALSE;
      l_include_inbound       := FALSE;
      l_include_crossdock     := FALSE;
      l_include_manufacturing := FALSE;
      l_include_warehousing   := FALSE;

    else
      --    l_is_queued             := TRUE;
      --  l_is_dispatched         := TRUE;
      --  l_is_active             := TRUE;
      --  l_is_loaded             := TRUE;
      --  l_is_completed          := FALSE;
      l_include_inbound       := FALSE;
      l_include_crossdock     := FALSE;
      l_include_manufacturing := FALSE;
      l_include_warehousing   := FALSE;

    end if;

    --get the values related to cartonization from org parameters
    BEGIN
      SELECT NVL(cartonization_flag, -1), NVL(cartonize_sales_orders, 'Y')
        INTO v_cart_value, l_cartonize_sales_orders
        FROM mtl_parameters
       WHERE organization_id = p_organization_id;
    EXCEPTION
      WHEN OTHERS THEN
        v_cart_value := NULL;
    END;

    if v_cart_value = 4 AND l_cartonize_sales_orders = 'Y' THEN
      --Always Cartonize for Task Release process
      l_cartonization_required := 'Y';
    elsif v_cart_value = 5 AND l_cartonize_sales_orders = 'Y' THEN
      --Cartonize for Task Release at subinventory level
      l_cartonization_required := 'Y';
    else

      l_cartonization_required := 'N';

    end if;

    delete from wms_waveplan_tasks_temp;

    wms_waveplan_tasks_pvt.query_tasks(p_add                        => NULL,
                                       p_organization_id            => l_organization_id,
                                       p_subinventory_code          => l_subinventory,
                                       p_locator_id                 => l_locator_id,
                                       p_to_subinventory_code       => l_to_subinventory,
                                       p_to_locator_id              => l_to_locator_id,
                                       p_inventory_item_id          => l_inventory_item_id,
                                       p_category_set_id            => l_category_set_id,
                                       p_item_category_id           => l_item_category_id,
                                       p_person_id                  => l_employee_id,
                                       p_person_resource_id         => l_person_resource_id,
                                       p_equipment_type_id          => l_equipment_type_id,
                                       p_machine_instance           => l_equipment,
                                       p_user_task_type_id          => l_user_task_type_id,
                                       p_from_task_quantity         => l_from_task_quantity,
                                       p_to_task_quantity           => l_to_task_quantity,
                                       p_from_task_priority         => l_from_task_priority,
                                       p_to_task_priority           => l_to_task_priority,
                                       p_from_creation_date         => l_from_creation_date,
                                       p_to_creation_date           => l_to_creation_date,
                                       p_is_unreleased              => l_is_unreleased,
                                       p_is_pending                 => l_is_pending,
                                       p_is_queued                  => l_is_queued,
                                       p_is_dispatched              => l_is_dispatched,
                                       p_is_active                  => l_is_active,
                                       p_is_loaded                  => l_is_loaded,
                                       p_is_completed               => l_is_completed,
                                       p_include_inbound            => l_include_inbound,
                                       p_include_outbound           => l_include_outbound,
                                       p_include_crossdock          => l_include_crossdock,
                                       p_include_manufacturing      => l_include_manufacturing,
                                       p_include_warehousing        => l_include_warehousing,
                                       p_from_purchase_order        => l_from_purchase_order,
                                       p_from_po_header_id          => l_from_po_header_id,
                                       p_to_purchase_order          => l_to_purchase_order,
                                       p_to_po_header_id            => l_to_po_header_id,
                                       p_from_rma                   => l_from_rma,
                                       p_from_rma_header_id         => l_from_rma_header_id,
                                       p_to_rma                     => l_to_rma,
                                       p_to_rma_header_id           => l_to_rma_header_id,
                                       p_from_requisition           => l_from_requisition,
                                       p_from_requisition_header_id => l_from_requisition_header_id,
                                       p_to_requisition             => l_to_requisition,
                                       p_to_requisition_header_id   => l_to_requisition_header_id,
                                       p_from_shipment_number       => l_from_shipment,
                                       p_to_shipment_number         => l_to_shipment,
                                       p_from_sales_order_id        => l_from_sales_order_id,
                                       p_to_sales_order_id          => l_to_sales_order_id,
                                       p_from_pick_slip_number      => l_from_pick_slip,
                                       p_to_pick_slip_number        => l_to_pick_slip,
                                       p_customer_id                => l_customer_id,
                                       p_customer_category          => l_customer_category,
                                       p_delivery_id                => l_delivery_id,
                                       p_carrier_id                 => l_carrier_id,
                                       p_ship_method                => l_ship_method_code,
                                       p_trip_id                    => l_trip_id,
                                       p_shipment_priority          => l_shipment_priority,
                                       p_from_shipment_date         => l_from_shipment_date,
                                       p_to_shipment_date           => l_to_shipment_date,
                                       p_ship_to_state              => l_ship_to_state,
                                       p_ship_to_country            => l_ship_to_country,
                                       p_ship_to_postal_code        => l_ship_to_postal_code,
                                       p_from_number_of_order_lines => l_from_lines_in_sales_order,
                                       p_to_number_of_order_lines   => l_to_lines_in_sales_order,
                                       p_manufacturing_type         => l_manufacturing_type,
                                       p_from_job                   => l_from_job,
                                       p_to_job                     => l_to_job,
                                       p_assembly_id                => l_assembly_id,
                                       p_from_start_date            => l_from_start_date,
                                       p_to_start_date              => l_to_start_date,
                                       p_from_line                  => l_from_line,
                                       p_to_line                    => l_to_line,
                                       p_department_id              => l_department_id,
                                       p_include_sales_orders       => l_include_sales_orders,
                                       p_include_internal_orders    => l_include_internal_orders,
                                       p_include_replenishment      => l_include_replenishment,
                                       p_from_replenishment_mo      => l_from_replenishment_mo,
                                       p_to_replenishment_mo        => l_to_replenishment_mo,
                                       p_include_mo_transfer        => l_include_mo_transfer,
                                       p_include_mo_issue           => l_include_mo_issue,
                                       p_from_transfer_issue_mo     => l_from_transfer_issue_mo,
                                       p_to_transfer_issue_mo       => l_to_transfer_issue_mo,
                                       p_include_lpn_putaway        => l_include_lpn_putaway,
                                       p_include_staging_move       => l_include_staging_move,
                                       p_include_cycle_count        => l_include_cycle_count,
                                       p_cycle_count_name           => l_cycle_count_name,
                                       x_return_status              => l_return_status,
                                       x_msg_data                   => l_msg_data,
                                       x_msg_count                  => l_msg_count,
                                       x_record_count               => l_record_count,
                                       p_query_independent_tasks    => l_query_independent_tasks,
                                       p_query_planned_tasks        => l_query_planned_tasks,
                                       p_is_pending_plan            => l_is_pending_plan,
                                       p_is_inprogress_plan         => l_is_inprogress_plan,
                                       p_is_completed_plan          => l_is_completed_plan,
                                       p_is_cancelled_plan          => l_is_cancelled_plan,
                                       p_is_aborted_plan            => l_is_aborted_plan,
                                       p_activity_id                => l_op_plan_activity_id,
                                       p_plan_type_id               => l_op_plan_type_id,
                                       p_op_plan_id                 => l_op_plan_id,
                                       p_wave_header_id             => l_wave_header_id);

    print_DEBUG('WMS_WAVEPLAN_TASKS_PVT.QUERY_TASKS x_return_status => ' ||
                l_return_status,
                l_debug);
    print_DEBUG('WMS_WAVEPLAN_TASKS_PVT.QUERY_TASKS x_msg_data => ' ||
                l_msg_data,
                l_debug);
    print_DEBUG('WMS_WAVEPLAN_TASKS_PVT.QUERY_TASKS x_msg_count => ' ||
                l_msg_count,
                l_debug);
    print_DEBUG('WMS_WAVEPLAN_TASKS_PVT.QUERY_TASKS x_record_count => ' ||
                l_record_count,
                l_debug);

    IF l_return_status = fnd_api.g_ret_sts_error THEN
      print_DEBUG(' Error in WMS_WAVEPLAN_TASKS_PVT.QUERY_TASKS ', l_debug);
      --return;
      RAISE fnd_api.g_exc_error;
    END IF;

    open c_mmtt;

    fetch c_mmtt bulk collect
      into l_final_mmtt_table;

    close c_mmtt;

    print_DEBUG(' Total Number of Tasks is  ' || l_final_mmtt_table.count,
                l_debug);

    forall m in l_final_mmtt_table.FIRST .. l_final_mmtt_table.LAST
      insert into wms_wp_tp_mmtt values (l_final_mmtt_table(m), 'N');

    /*
      for l_rec in c_wave_temp loop

        print_debug('Transaction Temp Id is' || l_rec.transaction_temp_id,
                    l_debug);
        print_debug('Status is' || l_rec.status, l_debug);
        print_debug('Task Type is' || l_rec.task_type, l_debug);
        print_debug('Order Number is' || l_rec.source_header, l_debug);

      end loop;
    */
    IF l_custom_flag = 'Y' THEN
      print_debug('Custom condition is enabled. Calling wms_wp_custom_apis_pub.task_release_cust ',
                  l_debug);
      wms_wp_custom_apis_pub.task_release_cust(p_organization_id       => p_organization_id,
                                               p_custom_plan_tolerance => l_custom_plan_tolerance,
                                               --  p_cartonization_required      => p_cartonization,
                                               p_final_mmtt_table => l_mmtt_table, -- Need to make it an in/ out parameter.Ajith?????
                                               x_return_status    => l_return_status,
                                               x_msg_count        => l_msg_count,
                                               x_msg_data         => l_msg_data);

      IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        print_debug('Error returned from task_release_cust in Task_Release_CP ',
                    l_debug);
        RAISE FND_API.G_EXC_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        print_debug('Unexpected errror from task_release_cust in Task_Release_CP ',
                    l_debug);
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      x_return_status := l_return_status;

    end if;

    --ELSE

    if l_fill_capacity = 'Y' then

      print_debug('Checking Minimum Equipment Fill Capacity', l_debug);

      begin

        -- Looping through the different User Task Types
        for l_user_task_type in c_task_type loop

          print_debug('Looping through User Task Type ' ||
                      l_user_task_type.user_task_type,
                      l_debug);

          -- Need to find out all the tasks for that User task type

          select transaction_temp_id bulk collect
            into l_mmtt_table
            from wms_waveplan_tasks_temp
           where user_Task_type = l_user_task_type.user_task_type;

          print_debug('Calling Minimum Equipment Capacity API to get the minimum equipment
                Capacity ',
                      l_debug);

          select sum(transaction_quantity)
            into l_sum_qty
            from wms_waveplan_tasks_temp
           where user_Task_type = l_user_task_type.user_task_type;

          print_debug('Sum of Transaction Qty for User task type ' ||
                      l_user_task_type.user_task_type || ' is  ' ||
                      l_sum_qty,
                      l_debug);

          if check_min_equip_Capacity(l_mmtt_table) then

            print_debug(' All Tasks in User Task type ' ||
                        l_user_task_type.user_task_type ||
                        ' has fulfilled the minimum equipment
                Capacity ',
                        l_debug);

            forall i in l_mmtt_table.FIRST .. l_mmtt_table.LAST
              update wms_wp_tp_mmtt
                 set indicator_flag = 'F'
               where transaction_temp_id = l_mmtt_table(i);
            --   and indicator_flag <> 'Y';

            --  l_mmtt_table1.DELETE;

          else
            print_debug(' All Tasks in User Task type ' ||
                        l_user_task_type.user_task_type ||
                        ' has not fulfilled the minimum equipment
                Capacity ',
                        l_debug);
            l_mmtt_table.DELETE;
          end if;

        end loop;

      exception
        WHEN OTHERS THEN
          print_debug('Error in Task Planning Minimum Fill Capacity: ' ||
                      SQLCODE || ' : ' || SQLERRM,
                      l_debug);

          RAISE fnd_api.g_exc_error;
      end;

    end if;

    if l_reverse_trip_Stop = 'Y' then

      if l_fill_capacity = 'Y' then

        /*  forall i in l_mmtt_table.FIRST .. l_mmtt_table.LAST
        update wms_wp_tp_mmtt
           set indicator_flag = 'Y'
         where transaction_temp_id = l_mmtt_table(i); */
        l_mmtt_table.DELETE;
      else

        forall i in l_final_mmtt_table.FIRST .. l_final_mmtt_table.LAST
          update wms_wp_tp_mmtt
             set indicator_flag = 'F'
           where transaction_temp_id = l_final_mmtt_table(i);

      end if;

      print_debug('Checking Reverse Trip Stop Tasks', l_debug);

      begin
        j := 0;

        for l_trip in c_get_trip loop
          l_trip_id := l_trip.trip_id;
          print_debug(' Trip Id is ' || l_trip_id, l_debug);

          v_final_completed_flag := 'Y';

          for l_stop in c_get_trip_Stop loop

            l_Stop_id               := l_stop.stop_id;
            v_task_count            := 0;
            l_total_completed_count := 0;

            print_debug(' Trip Stop Id is ' || l_stop_id, l_debug);

            for l_task in c_get_mmtt loop
              if v_final_completed_flag = 'Y' then
                -- Need to check if the task is completed

                v_task_count := v_task_count + 1;

                select count(1)
                  into l_completed_task_count
                  from mtl_material_transactions
                 where transaction_id = l_task.transaction_temp_id;

                if l_completed_task_count = 1 then
                  print_debug(' transaction id ' ||
                              l_task.transaction_temp_id ||
                              ' is completed',
                              l_debug);

                  l_total_completed_count := l_total_completed_count + 1;
                  -- So need to check if all the tasks are completed or not
                else
                  print_debug(' transaction temp id not completed is ' ||
                              l_task.transaction_temp_id,
                              l_debug);
                  -- Need to find out whether the Tasks belong to the Query
                  begin
                    select 1
                      into l_unreleased_count
                      from wms_wp_tp_mmtt
                     where indicator_flag = 'F'
                       and transaction_temp_id = l_task.transaction_temp_id;

                  exception
                    when others then
                      print_debug(' transaction temp id not available in Control Board Query is  ' ||
                                  l_task.transaction_temp_id,
                                  l_debug);

                      l_unreleased_count := 0;
                  end;

                  if l_unreleased_count = 1 then
                    print_debug(' transaction temp id  in Control Board Query is ' ||
                                l_task.transaction_temp_id,
                                l_debug);
                    l_mmtt_table(j) := l_task.transaction_temp_id;
                    j := j + 1;

                  end if;
                end if;

              end if;
            end loop;

            -- FInal Completion Status

            print_debug(' l_total_completed_count is ' ||
                        l_total_completed_count,
                        l_debug);

            print_debug(' v_task_count is ' || v_task_count, l_debug);

            if v_task_count > 0 then
              if l_total_completed_count >=
                 ((100 - l_trip_tolerance) / 100) * v_task_count then
                print_debug(' All Tasks for the trip stop are Completed ',
                            l_debug);
                v_final_completed_flag := 'Y';
              else
                print_debug(' All Tasks for the trip stop are not Completed So not releasing the tasks for the next trip stop ',
                            l_debug);
                v_final_completed_flag := 'N';
              end if;
            end if;
          end loop;
        end loop;

        forall i in l_mmtt_table.FIRST .. l_mmtt_table.LAST
          update wms_wp_tp_mmtt
             set indicator_flag = 'T'
           where transaction_temp_id = l_mmtt_table(i);
        --  and indicator_flag <> 'Y';
        --  l_mmtt_table1.DELETE;

      exception
        WHEN OTHERS THEN
          print_debug('Error in Task Release Reverse Trip Stop: ' ||
                      SQLCODE || ' : ' || SQLERRM,
                      l_debug);
          RAISE fnd_api.g_exc_error;
      end;

    end if;

    -- Checking Consolidation Locator group by delivery
    -- We release tasks only when the tasks pertaining to the prior delivery is packed.
    if l_consol_locator = 'Y' then

      begin

        if (l_fill_capacity = 'Y' and l_reverse_trip_Stop = 'Y') or
           l_reverse_trip_Stop = 'Y' then

          l_mmtt_table.delete;

        elsif (l_fill_capacity = 'Y' and l_reverse_trip_Stop <> 'Y') then

          forall i in l_mmtt_table.FIRST .. l_mmtt_table.LAST
            update wms_wp_tp_mmtt
               set indicator_flag = 'T'
             where transaction_temp_id = l_mmtt_table(i);

        else

          forall i in l_final_mmtt_table.FIRST .. l_final_mmtt_table.LAST
            update wms_wp_tp_mmtt
               set indicator_flag = 'T'
             where transaction_temp_id = l_final_mmtt_table(i);

        end if;

        print_debug('Checking Consolidation Locator Tasks', l_debug);

        for l_consol_locator in c_consol_locator loop

          p_consol_locator_id := l_consol_locator.to_locator_id;

          print_debug(' Consolidation Locator   is ' ||
                      l_consol_locator.to_locator,
                      l_debug);

          open c_delivery;
          loop
            fetch c_delivery
              into l_dummy_delivery;
            exit;
          end loop;

          l_delivery_count := c_delivery%ROWCOUNT;

          close c_delivery;

          if l_delivery_count = 0 then

            -- Then we need to release all the tasks for the first delivery.

            if get_tasks_exist(p_consol_locator_id) then
              l_release_delivery := 'Y';
            end if;

          else

            for l_delivery in c_delivery loop

              p_delivery_id := l_delivery.delivery_id;

              print_debug(' Processing Delivery  in Consolidation Locator ' ||
                          p_delivery_id,
                          l_debug);

              open c_wdd_delivery;

              fetch c_wdd_delivery bulk collect
                into l_wdd_table2;

              close c_wdd_delivery;

              ---- Getting all WDDS in Replenishment requested Status

              open c_wdd_staged;

              fetch c_wdd_staged bulk collect
                into l_wdd_table3;

              close c_wdd_staged;

              l_wdd_count := l_wdd_table2.count; ---> set1

              l_wdd_staged_count := l_wdd_table3.count; ---> set2

              print_debug(' Count of Total Wdds in the delivery is  ' ||
                          l_wdd_count,
                          l_debug);

              print_debug(' Count of Total Staged  WDDs  in the  delivery is  ' ||
                          l_wdd_staged_count,
                          l_debug);

              print_debug('Consolidation Locator Tolerance is ' ||
                          l_cons_locator_tolerance,
                          l_debug);

              if l_wdd_count > 0 then
                if ((l_wdd_staged_count * 100) / (l_wdd_count)) >=
                   (100 - l_cons_locator_tolerance) then

                  print_debug(100 - l_cons_locator_tolerance ||
                              ' % of wdds in the delivery are Staged ',
                              l_debug);

                  if get_tasks_exist(p_consol_locator_id, p_delivery_id) then
                    l_release_delivery := 'Y';
                    exit; --Exiting the loop as no need to process the next delivery.
                  end if;
                  --   l_release_delivery := 'Y'; -- Releasing next delivery

                else

                  print_debug(100 - l_cons_locator_tolerance ||
                              ' % of wdds in the delivery are not Staged . So not processing the next delivery',
                              l_debug);

                  l_release_delivery := 'N';

                end if;
              end if;

              l_wdd_count        := 0;
              l_wdd_staged_count := 0;

            end loop;

          end if;

          if l_release_delivery = 'Y' then

            print_debug('Releasing tasks for the First Delivery ', l_debug);

            for l_delivery1 in c_delivery_mmtt loop

              p_delivery_mmtt_id := l_delivery1.delivery_id;

              print_debug(' delivery id whose tasks are  to be released is ' ||
                          p_delivery_mmtt_id,
                          l_debug);

              open c_get_mmtt_delivery(p_delivery_mmtt_id);

              fetch c_get_mmtt_delivery bulk collect
                into l_mmtt_table2;

              close c_get_mmtt_delivery;

              forall i in l_mmtt_table2.FIRST .. l_mmtt_table2.LAST
                update wms_wp_tp_mmtt
                   set indicator_flag = 'C'
                 where transaction_temp_id = l_mmtt_table2(i);

              --    l_mmtt_table.delete;

              exit; -- This should run only for one delivery

            end loop;

            l_table_count := l_mmtt_table.COUNT;

            print_debug(' l_table_count is ' || l_table_count, l_debug);

            for i in l_mmtt_table2.FIRST .. l_mmtt_table2.LAST loop

              l_mmtt_table(i + l_table_count) := l_mmtt_table2(i);

            end loop;

            l_mmtt_table2.delete;

          end if;

        end loop;

      exception
        WHEN OTHERS THEN
          print_debug('Error in Task Release Consolidation Locator : ' ||
                      SQLCODE || ' : ' || SQLERRM,
                      l_debug);
          RAISE fnd_api.g_exc_error;
      end;

    end if;

    IF l_custom_flag = 'Y' THEN

      print_DEBUG('Before pre cartonization starts after customization.',
                  l_debug);
    else
      print_DEBUG('Updating the l_mmtt_table from the global temp table.',
                  l_debug);

      if (l_fill_capacity = 'Y' or l_reverse_trip_Stop = 'Y' or
         l_consol_locator = 'Y') then

        forall i in l_mmtt_table.FIRST .. l_mmtt_table.LAST
          update wms_wp_tp_mmtt
             set indicator_flag = 'C'
           where transaction_temp_id = l_mmtt_table(i);

      else

        forall i in l_final_mmtt_table.FIRST .. l_final_mmtt_table.LAST
          update wms_wp_tp_mmtt
             set indicator_flag = 'C'
           where transaction_temp_id = l_final_mmtt_table(i);

        select transaction_temp_id bulk collect
          into l_mmtt_table
          from wms_wp_tp_mmtt
         where indicator_flag = 'C';

      end if;

      --   l_mmtt_table.delete;

    end if;

    if l_cartonization_required = 'Y' or l_replenishment_complete = 'Y' then

      --<<Pre cartonize code here >>

      print_DEBUG('Pre Cartonization code starts here .', l_debug);

      if l_mmtt_table.count > 0 then

        for l1 in l_mmtt_table.FIRST .. l_mmtt_table.LAST loop
          print_DEBUG('Transaction Temp id is .' || l_mmtt_table(l1),
                      l_debug);
          -- Ajith Make this a cursor and do bulk collect

          l_mmtt_char := l_mmtt_char || to_char(l_mmtt_table(l1)) || ',';

        end loop;

        l_mmtt_char := l_mmtt_char || '0';

        print_DEBUG('Transaction Temp id is .' || l_mmtt_char, l_debug);
        open c_carton_lines;

        fetch c_carton_lines bulk collect
          into p_line_rows, p_move_order_line_tbl;

        close c_carton_lines;

        print_DEBUG('Before Update mtrl carton grouping id to null .',
                    l_debug);

        forall l2 in 1 .. p_move_order_line_tbl.count
          update mtl_txn_request_lines
             set carton_grouping_id = null
           where line_id = p_move_order_line_tbl(l2);

        print_DEBUG('After Update mtrl .', l_debug);
        FOR i IN 1 .. p_line_rows.count LOOP
          print_debug('**** PROCESSING DELIVERY DETAIL ID ' ||
                      P_LINE_ROWS(I) || ' ****',
                      l_debug);
          l_attr_tab(i).entity_id := p_line_rows(i);
          l_attr_tab(i).entity_type := 'DELIVERY_DETAIL';
        END LOOP;

        l_action_rec.action               := 'MATCH_GROUPS';
        l_action_rec.group_by_header_flag := 'N'; -- Need to confirm with Satish????????

        --    l_action_rec.check_single_grp := 'Y';

        print_debug('Calling Find Matching Groups ', l_debug);
        /*
        wsh_Delivery_autocreate.Find_Matching_Groups(p_attr_tab IN OUT NOCOPY grp_attr_tab_type,
                         p_action_rec IN action_rec_type,
                         p_target_rec IN grp_attr_rec_type,
                         p_group_tab IN OUT NOCOPY grp_attr_tab_type,
                         x_matched_entities OUT NOCOPY wsh_util_core.id_tab_type,
                         x_out_rec out NOCOPY out_rec_type,
                         x_return_status out NOCOPY varchar2); */
        -- l_group_info.organization_id := p_organization_id;
        wsh_Delivery_autocreate.Find_Matching_Groups(p_attr_tab         => l_attr_tab,
                                                     p_action_rec       => l_action_rec,
                                                     p_target_rec       => l_target_rec,
                                                     p_group_tab        => l_group_info,
                                                     x_matched_entities => l_matched_entities,
                                                     x_out_rec          => l_out_rec,
                                                     x_return_status    => x_return_status);

        print_debug('Return status from  Find Matching Groups ' ||
                    x_return_status,
                    l_debug);

        /*  l_group_match_seq_tbl.delete;

          --{
          for i in 1 .. l_attr_tab.count loop

            l_match_found := FALSE;
            --  print_debug('l_match_found '||l_match_found,l_debug);

            IF l_group_match_seq_tbl.count > 0 THEN
              --{
              FOR k in l_group_match_seq_tbl.FIRST .. l_group_match_seq_tbl.LAST LOOP
                --{

                print_debug(' l_attr_tab(i).group_id ' || l_attr_tab(i)
                            .group_id,
                            l_debug);

                IF l_attr_tab(i).group_id = l_group_match_seq_tbl(k)
                .match_group_id THEN
                  --{
                  l_group_match_seq_tbl(i).delivery_group_id := l_group_match_seq_tbl(k)
                                                               .delivery_group_id;
                  print_debug('  l_group_match_seq_tbl(i).delivery_group_id  ' ||
                              l_group_match_seq_tbl(i).delivery_group_id,
                              l_debug);

                  l_match_found := TRUE;
                  EXIT;
                  --}
                End IF;
                --}
              END LOOP;
              --}
            END IF;

            IF NOT l_match_found THEN
              --{

              l_group_match_seq_tbl(i).match_group_id := l_attr_tab(i)
                                                        .group_id;

              print_debug(' 123 l_attr_tab(i).group_id ' || l_attr_tab(i)
                          .group_id,
                          l_debug);
              print_debug('123 l_group_match_seq_tbl(k)
              .match_group_id ' ||
                          l_group_match_seq_tbl(i).match_group_id,
                          l_debug);

              select WSH_DELIVERY_GROUP_S.nextval
                into l_group_match_seq_tbl(i) .delivery_group_id
                from dual;
              --}
            End IF;

            --   l_group_match_seq_tbl(i) .delivery_group_id := l_temp;
            print_debug('CARTON GROUPING ID : ' || l_group_match_seq_tbl(i)
                        .delivery_group_id,
                        l_debug);

            p_carton_grouping_tbl(i) := l_group_match_seq_tbl(i)
                                       .delivery_group_id;
            --}

          end loop;
        */

        for i in 1 .. l_attr_tab.count loop

          l_match_found := FALSE;

          IF l_group_match_seq_tbl.count > 0 THEN
            --{
            FOR k in l_group_match_seq_tbl.FIRST .. l_group_match_seq_tbl.LAST LOOP
              --{
              IF l_attr_tab(i).group_id = l_group_match_seq_tbl(k)
              .match_group_id THEN
                --{
                l_group_match_seq_tbl(i).delivery_group_id := l_group_match_seq_tbl(k)
                                                             .delivery_group_id;
                l_match_found := TRUE;
                EXIT;
                --}
              End IF;
              --}
            END LOOP;
            --}
          END IF;

          IF NOT l_match_found THEN
            --{
            l_group_match_seq_tbl(i).match_group_id := l_attr_tab(i)
                                                      .group_id;
            select WSH_DELIVERY_GROUP_S.nextval
              into l_group_match_seq_tbl(i) .delivery_group_id
              from dual;
            --}
          End IF;

          print_debug('CARTON GROUPING ID : ' || l_group_match_seq_tbl(i)
                      .delivery_group_id,
                      l_debug);

          p_carton_grouping_tbl(i) := l_group_match_seq_tbl(i)
                                     .delivery_group_id;

        end loop;

        print_debug('Calling the  inv_move_order_pub.stamp_cart_id  : ',
                    l_debug);

        inv_move_order_pub.stamp_cart_id(p_validation_level    => 1,
                                         p_carton_grouping_tbl => p_carton_grouping_tbl,
                                         p_move_order_line_tbl => p_move_order_line_tbl);

        print_debug(' After calling  inv_move_order_pub.stamp_cart_id -- > Now we Release the Tasks   ',
                    l_debug);

        print_debug('Pre cartonization code ends here ---->   ', l_debug);

        -- end if;

        if l_replenishment_complete = 'Y' then

          print_debug('Inside Replenishment Completed Check ---->   ',
                      l_debug);

          -- Process the lines
          begin
            print_debug('Checking Replenishment Complete Tasks', l_debug);

            l_mmtt_table.delete;
            for l_carton in c_carton_grouping_id loop

              p_carton_grouping_id := l_carton.carton_grouping_id;

              --  p_batch_id := l_carton.batch_id;

              print_debug(' carton_grouping_id is ' ||
                          p_carton_grouping_id,
                          l_debug);

              ---- Getting all WDDS in Replenishment Completed or Released to Warehouse Status

              open c_rc_wdds;

              fetch c_rc_wdds bulk collect
                into l_wdd_table;

              close c_rc_wdds;

              ---- Getting all WDDS in Replenishment requested Status

              open c_rr_wdds;

              fetch c_rr_wdds bulk collect
                into l_wdd_table1;

              close c_rr_wdds;

              no_of_tasks := l_wdd_table.count; ---> set1

              l_repl_tasks := l_wdd_table1.count; ---> set2

              print_debug(' Count of Replenishment Completed Wdds is  ' ||
                          no_of_tasks,
                          l_debug);

              print_debug(' Count of Replenishment Requested WDDs is  ' ||
                          l_repl_tasks,
                          l_debug);

              if no_of_tasks > 0 then
                if ((no_of_tasks * 100) / (no_of_tasks + l_repl_tasks)) >=
                   (100 - l_replen_tolerance) then

                  print_debug(100 - l_replen_tolerance ||
                              ' % of wdds are Replenishment Completed or Released to Warehouse ',
                              l_debug);

                  open c_rc_tasks;

                  fetch c_rc_tasks bulk collect
                    into l_mmtt_table;

                  close c_rc_tasks;

                  forall i in l_mmtt_table.FIRST .. l_mmtt_table.LAST
                    update wms_wp_tp_mmtt
                       set indicator_flag = 'L'
                     where transaction_temp_id = l_mmtt_table(i);

                  l_mmtt_table.delete;

                  print_debug(' Releasing the Tasks for the Carton Grouping id ' ||
                              p_carton_grouping_id,
                              l_debug);

                else
                  print_debug(' Not Releasing the Tasks for the Carton Grouping id ' ||
                              p_carton_grouping_id || ' as ' ||
                              to_char(100 - l_replen_tolerance) ||
                              ' % of wdds are not Replenishment Completed or Released to Warehouse ',
                              l_debug);

                end if;
              end if;
              no_of_tasks  := 0;
              l_repl_tasks := 0;
            end loop;

            select transaction_temp_id bulk collect
              into l_mmtt_table
              from wms_wp_tp_mmtt
             where indicator_flag = 'L';

          exception
            WHEN OTHERS THEN
              print_debug('Error in Task Planning Replenishment Complete part: ' ||
                          SQLCODE || ' : ' || SQLERRM,
                          l_debug);
              RAISE fnd_api.g_exc_error;

          end;

        end if;

        if l_cartonization_required = 'Y' then

          if p_move_order_line_tbl.count > 0 then

            print_debug('Inside Call to Cartonize ---->   ', l_debug);

            print_debug('Assigning Values to Header Record ---->   ',
                        l_debug);

            l_trohdr_rec.created_by          := fnd_global.user_id;
            l_trohdr_rec.creation_date       := sysdate;
            l_trohdr_rec.header_status       := INV_Globals.g_to_status_preapproved;
            l_trohdr_rec.last_updated_by     := fnd_global.user_id;
            l_trohdr_rec.last_update_date    := sysdate;
            l_trohdr_rec.last_update_login   := fnd_global.user_id;
            l_trohdr_rec.organization_id     := p_organization_id; -- assigned inside the loop
            l_trohdr_rec.status_date         := sysdate;
            l_trohdr_rec.move_order_type     := INV_GLOBALS.G_MOVE_ORDER_PICK_WAVE;
            l_trohdr_rec.transaction_type_id := INV_GLOBALS.G_TYPE_TRANSFER_ORDER_STGXFR;
            l_trohdr_rec.operation           := INV_GLOBALS.G_OPR_CREATE;
            l_trohdr_rec.db_flag             := FND_API.G_TRUE;

            print_debug('CALLING INV_Move_Order_PUB.Create_Move_Order_Header',
                        l_debug);

            INV_Move_Order_PUB.Create_Move_Order_Header(p_api_version_number => 1.0,
                                                        p_init_msg_list      => FND_API.G_FALSE,
                                                        p_return_values      => FND_API.G_TRUE,
                                                        p_commit             => l_commit,
                                                        x_return_status      => x_return_status,
                                                        x_msg_count          => l_msg_count,
                                                        x_msg_data           => l_msg_data,
                                                        p_trohdr_rec         => l_trohdr_rec,
                                                        p_trohdr_val_rec     => l_trohdr_val_rec,
                                                        x_trohdr_rec         => l_x_trohdr_rec,
                                                        x_trohdr_val_rec     => l_x_trohdr_val_rec,
                                                        p_validation_flag    => inv_move_order_pub.g_validation_yes);

            IF l_return_status = FND_API.G_RET_STS_ERROR THEN

              print_debug('Creating MO Header failed with unexpected error returning message: ' ||
                          l_msg_data,
                          l_debug);

              RAISE fnd_api.g_exc_unexpected_error;
              -- If cant create a common MOH, do no repl stuff
            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

              print_debug('Creating MO Header failed with expected error returning message: ' ||
                          l_msg_data,
                          l_debug);
              --    RAISE fnd_api.g_exc_error;
              -- If cant create a common MOH, do not cartonize
            ELSE

              print_debug('Creating MO Header returned success with MO Header Id: ' ||
                          l_x_trohdr_rec.header_id,
                          l_debug);

            END IF;

            print_debug('Before Stamping the move order Header Ids for Move order Lines: ',
                        l_debug);

            -- Calling API to create Move Order Header API

            -- Stamping Move Order Header Id for all the Lines

            for i2 in p_move_order_line_tbl.FIRST .. p_move_order_line_tbl.LAST loop

              update mtl_txn_request_lines
                 set header_id   = l_x_trohdr_rec.header_id,
                     line_number = line_count
               where line_id = p_move_order_line_tbl(i2);
              line_count := line_count + 1;
            end loop;

            forall i3 in p_move_order_line_tbl.FIRST .. p_move_order_line_tbl.LAST
              update mtl_material_transactions_temp
                 set move_order_header_id = l_x_trohdr_rec.header_id
               where move_order_line_id = p_move_order_line_tbl(i3);

            /*
               loop
                print_debug(' Move Order Line Id is   ' ||
                            p_move_order_line_tbl(i2),
                            l_debug);

                l_move_order_line_id := l_move_order_line_id ||
                                        to_char(p_move_order_line_tbl(i2)) || ',';
              end loop;

              l_move_order_line_id := l_move_order_line_id || '0'; -- Just to make sure no extra comma is present in the query

              print_debug(' Move Order Line Id char  is   ' ||
                          l_move_order_line_id,
                          l_debug);

              open c_move_order_header;

              fetch c_move_order_header bulk collect
                into p_move_order_hdr_tbl;

              close c_move_order_header;
            */
          end if;

          /*
          select HEADER_ID
            into p_move_order_hdr_tbl(i2)
            from mtl_txn_request_lines
           where line_id = p_move_order_line_tbl(i2); */

          -- end loop;

          /* if p_move_order_hdr_tbl.count > 0 then
          for i3 in p_move_order_hdr_tbl.FIRST .. p_move_order_hdr_tbl.LAST loop

            print_debug(' Move Order header  Id is   ' ||
                        p_move_order_hdr_tbl(i3),
                        l_debug);

            print_debug(' Calling Cartonize API to cartonize the move order headers  ',
                        l_debug);
                        */

          wms_postalloc_pvt.cartonize(p_org_id               => p_organization_id,
                                      p_move_order_header_id => l_x_trohdr_rec.header_id,
                                      p_caller               => 'TRP',
                                      x_return_status        => x_return_status);

          print_DEBUG('Return Status from Cartonize API => ' ||
                      x_return_status,
                      l_debug);
          --   end loop;

        end if;

      end if;

    end if;
    --END IF;

    if l_mmtt_table.count > 0 then
      for l1 in l_mmtt_table.FIRST .. l_mmtt_table.LAST loop

        print_DEBUG(' Transaction temp ids selected for Releasing .' ||
                    l_mmtt_table(l1),
                    l_debug);

      end loop;

    end if;

    forall i IN l_mmtt_table.FIRST .. l_mmtt_table.LAST
      UPDATE mtl_material_transactions_temp
         SET wms_task_status = 1
       WHERE transaction_temp_id = l_mmtt_table(i)
         and wms_task_status = 8;

    commit;

    -- Clearing the tables.
    l_field_name_table.delete;
    l_field_value_table.delete;
    l_query_type_table.delete;
    l_mmtt_table.delete;

    print_DEBUG('Cleared pl/sql tables l_query_type_table, l_field_name_table and l_field_value_table.',
                l_debug);

  exception
    WHEN OTHERS THEN
      print_debug('Error in Task Release CP: ' || SQLCODE || ' : ' ||
                  SQLERRM,
                  l_debug);

      RAISE fnd_api.g_exc_unexpected_error;
  end Task_Release_CP;

  PROCEDURE SET_QUERY_TASKS_PARAMETERS(p_field_name_table      IN wms_wave_planning_pvt.field_name_table_type,
                                       p_field_value_table     IN wms_wave_planning_pvt.field_value_table_type,
                                       p_organization_id_table IN wms_wave_planning_pvt.organization_id_table_type,
                                       p_query_type_table      IN wms_wave_planning_pvt.query_type_table_type,
                                       x_return_status         OUT NOCOPY VARCHAR2,
                                       x_return_message        OUT NOCOPY VARCHAR2) IS
    i       number;
    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    print_DEBUG('Inside SET_QUERY_TASKS_PARAMETERS', l_debug);

    print_DEBUG('p_field_name_table.count ' || p_field_name_table.count,
                l_debug);

    IF p_field_name_table.count <> 0 THEN
      FOR i in p_field_name_table.first .. p_field_name_table.last LOOP
        IF (p_field_name_table(i) = 'FIND_TASKS.UNRELEASED' AND
           p_field_value_table(i) = 'Y') THEN
          l_is_unreleased := TRUE;
        END IF;

        IF (p_field_name_table(i) = 'FIND_TASKS.PENDING' AND
           p_field_value_table(i) = 'Y') THEN
          l_is_pending := TRUE;
        END IF;

        IF (p_field_name_table(i) = 'FIND_TASKS.QUEUED' AND
           p_field_value_table(i) = 'Y') THEN
          l_is_queued := TRUE;
        END IF;

        IF (p_field_name_table(i) = 'FIND_TASKS.DISPATCHED' AND
           p_field_value_table(i) = 'Y') THEN
          l_is_dispatched := TRUE;
        END IF;

        IF (p_field_name_table(i) = 'FIND_TASKS.ACTIVE' AND
           p_field_value_table(i) = 'Y') THEN
          l_is_active := TRUE;
        END IF;

        IF (p_field_name_table(i) = 'FIND_TASKS.LOADED' AND
           p_field_value_table(i) = 'Y') THEN
          l_is_loaded := TRUE;
        END IF;

        IF (p_field_name_table(i) = 'FIND_TASKS.COMPLETED' AND
           p_field_value_table(i) = 'Y') THEN
          l_is_completed := TRUE;
        END IF;

        IF (p_field_name_table(i) = 'FIND_TASKS.INBOUND' AND
           p_field_value_table(i) = 'Y') THEN
          l_include_inbound := TRUE;
        END IF;

        IF (p_field_name_table(i) = 'FIND_TASKS.OUTBOUND' AND
           p_field_value_table(i) = 'Y') THEN
          l_include_outbound := TRUE;
        END IF;

        IF (p_field_name_table(i) = 'FIND_TASKS.CROSSDOCK' AND
           p_field_value_table(i) = 'Y') THEN
          l_include_crossdock := TRUE;
        END IF;

        IF (p_field_name_table(i) = 'FIND_TASKS.MANUFACTURING' AND
           p_field_value_table(i) = 'Y') THEN
          l_include_manufacturing := TRUE;
        END IF;

        IF (p_field_name_table(i) = 'FIND_TASKS.WAREHOUSING' AND
           p_field_value_table(i) = 'Y') THEN
          l_include_warehousing := TRUE;
        END IF;

        IF (p_field_name_table(i) = 'FIND_TASKS.ORDER_TYPE' AND
           p_field_value_table(i) = 'S') THEN
          l_include_sales_orders := TRUE;
        ELSIF (p_field_name_table(i) = 'FIND_TASKS.ORDER_TYPE' AND
              p_field_value_table(i) = 'I') THEN
          l_include_internal_orders := TRUE;
        ELSIF (p_field_name_table(i) = 'FIND_TASKS.ORDER_TYPE' AND
              p_field_value_table(i) = 'B') THEN
          l_include_sales_orders    := TRUE;
          l_include_internal_orders := TRUE;
        END IF;

        IF (p_field_name_table(i) = 'FIND_TASKS.REPLENISHMENT_TASKS' AND
           p_field_value_table(i) = 'Y') THEN
          l_include_replenishment := TRUE;
        END IF;

        IF (p_field_name_table(i) = 'FIND_TASKS.MO_TRANSFER_TASKS' AND
           p_field_value_table(i) = 'Y') THEN
          l_include_mo_transfer := TRUE;
        END IF;

        IF (p_field_name_table(i) = 'FIND_TASKS.MO_ISSUE_TASKS' AND
           p_field_value_table(i) = 'Y') THEN
          l_include_mo_issue := TRUE;
        END IF;

        IF (p_field_name_table(i) = 'FIND_TASKS.LPN_PUTAWAY_TASKS' AND
           p_field_value_table(i) = 'Y') THEN
          l_include_lpn_putaway := TRUE;
        END IF;

        IF (p_field_name_table(i) = 'FIND_TASKS.STAGING_MOVE' AND
           p_field_value_table(i) = 'Y') THEN
          l_include_staging_move := TRUE;
        END IF;

        IF (p_field_name_table(i) = 'FIND_TASKS.CYCLE_COUNT_TASKS' AND
           p_field_value_table(i) = 'Y') THEN
          l_include_cycle_count := TRUE;
        END IF;

        IF (p_field_name_table(i) = 'FIND_TASKS.PLAN_PENDING' AND
           p_field_value_table(i) = 'Y') THEN
          l_is_pending_plan := TRUE;
        END IF;

        IF (p_field_name_table(i) = 'FIND_TASKS.PLAN_IN_PROGRESS' AND
           p_field_value_table(i) = 'Y') THEN
          l_is_inprogress_plan := TRUE;
        END IF;

        IF (p_field_name_table(i) = 'FIND_TASKS.PLAN_COMPLETED' AND
           p_field_value_table(i) = 'Y') THEN
          l_is_completed_plan := TRUE;
        END IF;

        IF (p_field_name_table(i) = 'FIND_TASKS.PLAN_CANCELLED' AND
           p_field_value_table(i) = 'Y') THEN
          l_is_cancelled_plan := TRUE;
        END IF;

        IF (p_field_name_table(i) = 'FIND_TASKS.PLAN_ABORTED' AND
           p_field_value_table(i) = 'Y') THEN
          l_is_aborted_plan := TRUE;
        END IF;

        IF (p_field_name_table(i) = 'FIND_TASKS.PLANNED_TASKS' AND
           p_field_value_table(i) = 'Y') THEN
          l_query_planned_tasks := TRUE;
        END IF;

        IF (p_field_name_table(i) = 'FIND_TASKS.INDEPENDENT_TASKS' AND
           p_field_value_table(i) = 'Y') THEN
          l_query_independent_tasks := TRUE;
        END IF;

        IF p_field_name_table(i) = 'FIND_TASKS.SUBINVENTORY' THEN
          l_subinventory := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'FIND_TASKS.LOCATOR_ID' THEN
          l_locator_id := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'FIND_TASKS.TO_SUBINVENTORY' THEN
          l_to_subinventory := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'FIND_TASKS.TO_LOCATOR_ID' THEN
          l_to_locator_id := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'FIND_TASKS.INVENTORY_ITEM_ID' THEN
          l_inventory_item_id := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'FIND_TASKS.CATEGORY_SET_ID' THEN
          l_category_set_id := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'FIND_TASKS.ITEM_CATEGORY_ID' THEN
          l_item_category_id := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'FIND_TASKS.EMPLOYEE_ID' THEN
          l_employee_id := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'FIND_TASKS.PERSON_RESOURCE_ID' THEN
          l_person_resource_id := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'FIND_TASKS.EQUIPMENT_TYPE_ID' THEN
          l_equipment_type_id := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'FIND_TASKS.EQUIPMENT' THEN
          l_equipment := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'FIND_TASKS.USER_TASK_TYPE_ID' THEN
          l_user_task_type_id := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'FIND_TASKS.FROM_TASK_QUANTITY' THEN
          l_from_task_quantity := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'FIND_TASKS.TO_TASK_QUANTITY' THEN
          l_to_task_quantity := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'FIND_TASKS.FROM_TASK_PRIORITY' THEN
          l_from_task_priority := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'FIND_TASKS.TO_TASK_PRIORITY' THEN
          l_to_task_priority := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'FIND_TASKS.FROM_CREATION_DATE' THEN
          l_from_creation_date := FND_DATE.CHARDT_TO_DATE(p_field_value_table(i));
        ELSIF p_field_name_table(i) = 'FIND_TASKS.TO_CREATION_DATE' THEN
          l_to_creation_date := FND_DATE.CHARDT_TO_DATE(p_field_value_table(i));
        ELSIF p_field_name_table(i) = 'FIND_TASKS.FROM_PURCHASE_ORDER' THEN
          l_from_purchase_order := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'FIND_TASKS.FROM_PO_HEADER_ID' THEN
          l_from_po_header_id := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'FIND_TASKS.TO_PURCHASE_ORDER' THEN
          l_to_purchase_order := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'FIND_TASKS.TO_PO_HEADER_ID' THEN
          l_to_po_header_id := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'FIND_TASKS.FROM_RMA' THEN
          l_from_rma := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'FIND_TASKS.FROM_RMA_HEADER_ID' THEN
          l_from_rma_header_id := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'FIND_TASKS.TO_RMA' THEN
          l_to_rma := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'FIND_TASKS.TO_RMA_HEADER_ID' THEN
          l_to_rma_header_id := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'FIND_TASKS.FROM_REQUISITION' THEN
          l_from_requisition := p_field_value_table(i);
        ELSIF p_field_name_table(i) =
              'FIND_TASKS.FROM_REQUISITION_HEADER_ID' THEN
          l_from_requisition_header_id := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'FIND_TASKS.TO_REQUISITION' THEN
          l_to_requisition := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'FIND_TASKS.TO_REQUISITION_HEADER_ID' THEN
          l_to_requisition_header_id := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'FIND_TASKS.FROM_SHIPMENT' THEN
          l_from_shipment := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'FIND_TASKS.TO_SHIPMENT' THEN
          l_to_shipment := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'FIND_TASKS.FROM_SALES_ORDER_ID' THEN
          l_from_sales_order_id := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'FIND_TASKS.TO_SALES_ORDER_ID' THEN
          l_to_sales_order_id := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'FIND_TASKS.FROM_PICK_SLIP' THEN
          l_from_pick_slip := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'FIND_TASKS.TO_PICK_SLIP' THEN
          l_to_pick_slip := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'FIND_TASKS.CUSTOMER_ID' THEN
          l_customer_id := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'FIND_TASKS.CUSTOMER_CATEGORY' THEN
          l_customer_category := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'FIND_TASKS.DELIVERY_ID' THEN
          l_delivery_id := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'FIND_TASKS.CARRIER_ID' THEN
          l_carrier_id := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'FIND_TASKS.SHIP_METHOD_CODE' THEN
          l_ship_method_code := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'FIND_TASKS.TRIP_ID' THEN
          l_trip_id := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'FIND_TASKS.SHIPMENT_PRIORITY' THEN
          l_shipment_priority := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'FIND_TASKS.FROM_SHIPMENT_DATE' THEN
          l_from_shipment_date := FND_DATE.CHARDT_TO_DATE(p_field_value_table(i));
        ELSIF p_field_name_table(i) = 'FIND_TASKS.TO_SHIPMENT_DATE' THEN
          l_to_shipment_date := FND_DATE.CHARDT_TO_DATE(p_field_value_table(i));
        ELSIF p_field_name_table(i) = 'FIND_TASKS.SHIP_TO_STATE' THEN
          l_ship_to_state := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'FIND_TASKS.SHIP_TO_COUNTRY' THEN
          l_ship_to_country := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'FIND_TASKS.SHIP_TO_POSTAL_CODE' THEN
          l_ship_to_postal_code := p_field_value_table(i);
        ELSIF p_field_name_table(i) =
              'FIND_TASKS.FROM_LINES_IN_SALES_ORDER' THEN
          l_from_lines_in_sales_order := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'FIND_TASKS.TO_LINES_IN_SALES_ORDER' THEN
          l_to_lines_in_sales_order := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'FIND_TASKS.MANUFACTURING_TYPE' THEN
          l_manufacturing_type := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'FIND_TASKS.FROM_JOB' THEN
          l_from_job := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'FIND_TASKS.TO_JOB' THEN
          l_to_job := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'FIND_TASKS.ASSEMBLY_ID' THEN
          l_assembly_id := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'FIND_TASKS.FROM_START_DATE' THEN
          l_from_start_date := FND_DATE.CHARDT_TO_DATE(p_field_value_table(i));
        ELSIF p_field_name_table(i) = 'FIND_TASKS.TO_START_DATE' THEN
          l_to_start_date := FND_DATE.CHARDT_TO_DATE(p_field_value_table(i));
        ELSIF p_field_name_table(i) = 'FIND_TASKS.FROM_LINE' THEN
          l_from_line := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'FIND_TASKS.TO_LINE' THEN
          l_to_line := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'FIND_TASKS.DEPARTMENT_ID' THEN
          l_department_id := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'FIND_TASKS.FROM_REPLENISHMENT_MO' THEN
          l_from_replenishment_mo := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'FIND_TASKS.TO_REPLENISHMENT_MO' THEN
          l_to_replenishment_mo := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'FIND_TASKS.FROM_TRANSFER_ISSUE_MO' THEN
          l_from_transfer_issue_mo := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'FIND_TASKS.TO_TRANSFER_ISSUE_MO' THEN
          l_to_transfer_issue_mo := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'FIND_TASKS.CYCLE_COUNT_NAME' THEN
          l_cycle_count_name := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'FIND_TASKS.OP_PLAN_ACTIVITY_ID' THEN
          l_op_plan_activity_id := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'FIND_TASKS.OP_PLAN_TYPE_ID' THEN
          l_op_plan_type_id := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'FIND_TASKS.OP_PLAN_ID' THEN
          l_op_plan_id := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'FIND_TASKS.WAVE_HEADER_ID' THEN
          l_wave_header_id := p_field_value_table(i);
          print_debug('l wave header id is: ' || l_wave_header_id, l_debug);
        END IF;

      END LOOP;
    END IF;

    i                 := 1;
    l_organization_id := p_organization_id_table(i);

    IF p_query_type_table(i) = 'TEMP_TASK_PLANNING' THEN
      l_temp_query := TRUE;
    ELSE
      l_temp_query := FALSE;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --DEBUG( 'Exiting SET_QUERY_TASKS_PARAMETERS');

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;
      x_return_message := 'Unexpected error has occured in WMS_TASK_ACTION_PVT.SET_QUERY_TASKS_PARAMETERS. ' ||
                          'Oracle error message is ' || SQLERRM;
      --DEBUG( 'Unexpected error has occured. Oracle error message is '
    --  || SQLERRM, 'WMS_TASK_ACTION_PVT.SET_QUERY_TASKS_PARAMETERS - other error');

  END SET_QUERY_TASKS_PARAMETERS;

  function get_net_value(p_wave_header_id in number) return varchar2 is

    cursor c_net_value is
      SELECT Sum(net_value) net_value,
             wwl.source_header_number,
             max(ooh.TRANSACTIONAL_CURR_CODE) TRANSACTIONAL_CURR_CODE,
             max(ooh.conversion_rate) conversion_rate,
             max(ooh.conversion_type_code) conversion_type_code,
             max(ooh.conversion_rate_Date) conversion_rate_Date,
             max(org_id) org_id
        FROM wms_wp_Wave_lines wwl, oe_order_headers_all ooh
       WHERE wwl.wave_header_id = p_wave_header_id
         AND wwl.source_header_number = ooh.order_number
         AND Nvl(remove_From_Wave_flag, 'N') <> 'Y'
       GROUP BY source_header_number;

    l_total_value number := 0;

    l_currency_code varchar2(10);

    l_set_of_books_id number;

    G_SOB_CURRENCY varchar2(10);
    l_debug        NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

  begin

    for l_value in c_net_value loop

      SELECT SET_OF_BOOKS_ID
        INTO l_set_of_books_id
        FROM ORG_ORGANIZATION_DEFINITIONS
       WHERE ORGANIZATION_ID = l_value.org_id;

      SELECT Currency_Code
        INTO G_SOB_CURRENCY
        FROM OE_GL_SETS_OF_BOOKS_V
       WHERE SET_OF_BOOKS_ID = l_set_of_books_id;

      l_total_value := l_total_value +
                       gl_currency_api.convert_amount(x_from_currency   => l_value.TRANSACTIONAL_CURR_CODE,
                                                      x_to_currency     => G_SOB_CURRENCY,
                                                      x_conversion_date => l_value.conversion_rate_Date,
                                                      x_conversion_type => l_value.conversion_rate,
                                                      x_amount          => l_value.net_value);

    end loop;

    return l_total_value || ' ' || G_SOB_CURRENCY;

  exception
    when others then

      print_debug('Error in Get Net Value API : ' || SQLCODE || ' : ' ||
                  SQLERRM,
                  l_debug);

      return null;

  end get_net_value;

  PROCEDURE SET_ACTION_TASKS_PARAMETERS(p_field_name_table  IN wms_wave_planning_pvt.field_name_table_type,
                                        p_field_value_table IN wms_wave_planning_pvt.field_value_table_type,
                                        p_query_type_table  IN wms_wave_planning_pvt.query_type_table_type,
                                        x_return_status     OUT NOCOPY VARCHAR2,
                                        x_return_message    OUT NOCOPY VARCHAR2) IS
    i       number;
    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    print_DEBUG('Inside SET_ACTION_TASKS_PARAMETERS', l_debug);

    IF p_field_name_table.count <> 0 THEN
      FOR i IN p_field_name_table.first .. p_field_name_table.last LOOP
        IF p_field_name_table(i) = 'MANAGE_TASKS.ACTION_TYPE' THEN
          l_action_type := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'MANAGE_TASKS.STATUS' THEN
          l_status := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'MANAGE_TASKS.STATUS_CODE' THEN
          l_status_code := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'MANAGE_TASKS.PRIORITY_TYPE' THEN
          l_priority_type := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'MANAGE_TASKS.PRIORITY' THEN
          l_priority := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'MANAGE_TASKS.CLEAR_PRIORITY' THEN
          l_clear_priority := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'MANAGE_TASKS.ASSIGN_TYPE' THEN
          l_assign_type := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'MANAGE_TASKS.EMPLOYEE' THEN
          l_employee := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'MANAGE_TASKS.EMPLOYEE_ID' THEN
          l_employee_id := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'MANAGE_TASKS.USER_TASK_TYPE' THEN
          l_user_task_type := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'MANAGE_TASKS.USER_TASK_TYPE_ID' THEN
          l_user_task_type_id := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'MANAGE_TASKS.EFFECTIVE_START_DATE' THEN
          l_effective_start_date := FND_DATE.CHARDT_TO_DATE(p_field_value_table(i));
        ELSIF p_field_name_table(i) = 'MANAGE_TASKS.EFFECTIVE_END_DATE' THEN
          l_effective_end_date := FND_DATE.CHARDT_TO_DATE(p_field_value_table(i));
        ELSIF p_field_name_table(i) = 'MANAGE_TASKS.PERSON_RESOURCE_ID' THEN
          l_person_resource_id := p_field_value_table(i);
        ELSIF p_field_name_table(i) = 'MANAGE_TASKS.PERSON_RESOURCE_CODE' THEN
          l_person_resource_code := p_field_value_table(i);
        END IF;

        IF ((p_field_name_table(i) = 'MANAGE_TASKS.OVERRIDE_EMP_CHECK') and
           (p_field_value_table(i) = 'Y')) THEN
          l_override_emp_check := TRUE;
        END IF;

      END LOOP;
    END IF;
    i := 1;
    IF p_query_type_table(i) = 'TEMP_TASK_ACTION' THEN
      l_temp_action := TRUE;
    ELSE
      l_temp_action := FALSE;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    print_DEBUG('Exiting SET_ACTION_TASKS_PARAMETERS', l_debug);

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;
      x_return_message := 'Unexpected error has occured in WMS_TASK_ACTION_PVT.SET_ACTION_TASKS_PARAMETERS. ' ||
                          'Oracle error message is ' || SQLERRM;
      print_DEBUG('Unexpected error has occured. Oracle error message is ' ||
                  SQLERRM ||
                  ' in WMS_TASK_ACTION_PVT.SET_ACTION_TASKS_PARAMETERS - other error',
                  l_debug);
  END SET_ACTION_TASKS_PARAMETERS;

   PROCEDURE insert_wave_header(x_return_status   OUT nocopy VARCHAR2,
                               p_wave_header_rec in wms_wp_wave_headers_vl%ROWTYPE) is
    l_debug     NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    p_WAVE_NAME VARCHAR2(4000);
  begin

    -- delete from  wms_wp_wave_headers_vl where wave_header_id = p_wave_header_id ;
    --check if the wave header already exists.
    -- For appending wave name with wave header id

    savepoint wave_header_creation;

    if p_wave_header_rec.WAVE_NAME is null then

      p_WAVE_NAME := p_wave_header_rec.WAVE_NAME || ' ' ||
                     p_wave_header_rec.WAVE_HEADER_ID;
    else

      p_WAVE_NAME := p_wave_header_rec.WAVE_NAME || '-' ||
                     p_wave_header_rec.WAVE_HEADER_ID;

    end if;
    print_debug('Concurrent Request Id' || fnd_global.conc_request_id,
                l_debug);
    insert into wms_wp_wave_headers_vl
      (WAVE_HEADER_ID,
       WAVE_NAME,
       WAVE_DESCRIPTION,
       start_time,   -- start time changes
       WAVE_SOURCE,
       WAVE_STATUS,
       TYPE_ID,
       BATCH_ID,
       SHIP_TO_LOCATION_ID,
       CUSTOMER_CLASS_ID,
       pull_replenishment_flag,
       INITIATE_WAVE_PLANNING,
       RELEASE_IMMEDIATELY,
       TABLE_NAME,
       ADVANCED_CRITERIA,
       CREATED_BY,
       CREATION_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATE_DATE,
       LAST_UPDATE_LOGIN,
       ORGANIZATION_ID,
       PICK_SEQ_RULE_ID,
       PICK_GROUPING_RULE_ID,
       TRIP_ID,
       TRIP_STOP_ID,
       SHIP_METHOD_CODE,
       SHIPMENT_PRIORITY_CODE,
       CARRIER_ID,
       DELIVERY_ID,
       FROM_ORDER_HEADER_ID,
       ORDER_TYPE_ID,
       CUSTOMER_ID,
       TASK_ID,
       PROJECT_ID,
       CATEGORY_SET_ID,
       CATEGORY_ID,
       INVENTORY_ITEM_ID,
       BACKORDERS_FLAG,
       INCLUDE_PLANNED_LINES,
       TASK_PLANNING_FLAG,
       APPEND_DELIVERIES,
       AUTO_CREATE_DELIVERY,
       AUTO_CREATE_DELIVERY_CRITERIA,
       TASK_PRIORITY,
       DEFAULT_STAGE_SUBINVENTORY,
       DEFAULT_STAGE_LOCATOR_ID,
       DEFAULT_ALLOCATION_METHOD,
       ORDER_NAME,
       CUSTOMER,
       ORDER_TYPE,
       CUSTOMER_CLASS,
       SHIP_METHOD,
       CARRIER,
       SHIP_PRIORITY,
       DELIVERY,
       TRIP,
       TRIP_STOP,
       ITEM,
       ITEM_CATEGORY,
       PROJECT_NAME,
       TASK_NAME,
       SCHEDULED_DAYS,
       SCHEDULED_HRS,
       DOCK_APPOINTMENT_DAYS,
       DOCK_APPOINTMENT_HOURS,
       PICK_SLIP_GROUP,
       RELEASE_SEQ_RULE,
       STAGING_SUBINVENTORY,
       STAGING_LOCATOR,
       CROSS_DOCK_CRITERIA,
       PICK_SUBINVENTORY,
       PLANNING_CRITERIA,
       PLANNING_CRITERIA_ID,
       REQUEST_ID,
       WAVE_FIRMED_FLAG)
    values
      (p_wave_header_rec.WAVE_HEADER_ID,
       p_WAVE_NAME,
       p_wave_header_rec.WAVE_DESCRIPTION,
       p_wave_header_rec.start_time, -- start time changes
       p_wave_header_rec.WAVE_SOURCE,
       p_wave_header_rec.WAVE_STATUS,
       p_wave_header_rec.TYPE_ID,
       p_wave_header_rec.BATCH_ID,
       p_wave_header_rec.SHIP_TO_LOCATION_ID,
       p_wave_header_rec.CUSTOMER_CLASS_ID,
       p_wave_header_rec.pull_replenishment_flag,
       p_wave_header_rec.INITIATE_WAVE_PLANNING,
       p_wave_header_rec.RELEASE_IMMEDIATELY,
       p_wave_header_rec.TABLE_NAME,
       p_wave_header_rec.ADVANCED_CRITERIA,
       p_wave_header_rec.CREATED_BY,
       p_wave_header_rec.CREATION_DATE,
       p_wave_header_rec.LAST_UPDATED_BY,
       p_wave_header_rec.LAST_UPDATE_DATE,
       p_wave_header_rec.LAST_UPDATE_LOGIN,
       p_wave_header_rec.ORGANIZATION_ID,
       p_wave_header_rec.PICK_SEQ_RULE_ID,
       p_wave_header_rec.PICK_GROUPING_RULE_ID,
       p_wave_header_rec.TRIP_ID,
       p_wave_header_rec.TRIP_STOP_ID,
       p_wave_header_rec.SHIP_METHOD_CODE,
       p_wave_header_rec.SHIPMENT_PRIORITY_CODE,
       p_wave_header_rec.CARRIER_ID,
       p_wave_header_rec.DELIVERY_ID,
       p_wave_header_rec.FROM_ORDER_HEADER_ID,
       p_wave_header_rec.ORDER_TYPE_ID,
       p_wave_header_rec.CUSTOMER_ID,
       p_wave_header_rec.TASK_ID,
       p_wave_header_rec.PROJECT_ID,
       p_wave_header_rec.CATEGORY_SET_ID,
       p_wave_header_rec.CATEGORY_ID,
       p_wave_header_rec.INVENTORY_ITEM_ID,
       p_wave_header_rec.BACKORDERS_FLAG,
       p_wave_header_rec.INCLUDE_PLANNED_LINES,
       p_wave_header_rec.TASK_PLANNING_FLAG,
       p_wave_header_rec.APPEND_DELIVERIES,
       p_wave_header_rec.AUTO_CREATE_DELIVERY,
       p_wave_header_rec.AUTO_CREATE_DELIVERY_CRITERIA,
       p_wave_header_rec.TASK_PRIORITY,
       p_wave_header_rec.DEFAULT_STAGE_SUBINVENTORY,
       p_wave_header_rec.DEFAULT_STAGE_LOCATOR_ID,
       p_wave_header_rec.DEFAULT_ALLOCATION_METHOD,
       p_wave_header_rec.ORDER_NAME,
       p_wave_header_rec.CUSTOMER,
       p_wave_header_rec.ORDER_TYPE,
       p_wave_header_rec.CUSTOMER_CLASS,
       p_wave_header_rec.SHIP_METHOD,
       p_wave_header_rec.CARRIER,
       p_wave_header_rec.SHIP_PRIORITY,
       p_wave_header_rec.DELIVERY,
       p_wave_header_rec.TRIP,
       p_wave_header_rec.TRIP_STOP,
       p_wave_header_rec.ITEM,
       p_wave_header_rec.ITEM_CATEGORY,
       p_wave_header_rec.PROJECT_NAME,
       p_wave_header_rec.TASK_NAME,
       p_wave_header_rec.SCHEDULED_DAYS,
       p_wave_header_rec.SCHEDULED_HRS,
       p_wave_header_rec.DOCK_APPOINTMENT_DAYS,
       p_wave_header_rec.DOCK_APPOINTMENT_HOURS,
       p_wave_header_rec.PICK_SLIP_GROUP,
       p_wave_header_rec.RELEASE_SEQ_RULE,
       p_wave_header_rec.STAGING_SUBINVENTORY,
       p_wave_header_rec.STAGING_LOCATOR,
       p_wave_header_rec.CROSS_DOCK_CRITERIA,
       p_wave_header_rec.PICK_SUBINVENTORY,
       p_wave_header_rec.PLANNING_CRITERIA,
       p_wave_header_rec.PLANNING_CRITERIA_ID,
       fnd_global.conc_request_id,
       p_wave_header_rec.WAVE_FIRMED_FLAG);

    x_return_status := 'S';
    COMMIT;

  EXCEPTION
    when others then
      x_return_status := 'E';
      print_debug('Error in insert wave header API : ' || SQLCODE || ' : ' ||
                  SQLERRM,
                  l_debug);
  END insert_wave_header;

  PROCEDURE RELEASE_ONLINE(X_RETURN_STATUS  OUT NOCOPY VARCHAR2,
                           P_WAVE_HEADER_ID IN NUMBER) IS
    x_msg_count  varchar2(100);
    x_msg_data   varchar2(100);
    p_batch_id   number;
    P_REQUEST_ID NUMBER;
    l_debug      NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN

    create_batch_record(x_return_status, p_wave_header_id);

    if x_return_status = 'S' then

      WSH_PICKING_BATCHES_GRP.release_wms_wave(p_release_mode        => 'ONLINE',
                                               p_pick_wave_header_id => p_wave_header_id,
                                               x_request_id          => p_request_id,
                                               X_RETURN_STATUS       => X_RETURN_STATUS,
                                               X_MSG_COUNT           => X_MSG_COUNT,
                                               X_MSG_DATA            => X_MSG_DATA,
                                               P_BATCH_REC           => new_wave_type,
                                               X_BATCH_ID            => p_BATCH_ID);

      if x_return_status = 'S' then
        print_debug('Updating Wave Header Status after Calling Release Wave from Workbench',
                    l_debug);
        update_wave_header_status(x_return_status,
                                  p_wave_header_id,
                                  'Released');
        get_actual_fill_rate(x_return_status, p_wave_header_id);

        print_debug('Status after Call to Get the Actual Fill Rate' ||
                    x_return_status,
                    l_debug);
        commit;

      elsif  x_return_status = 'W' then

      	print_debug('Updating Wave Header Status after Calling Release Wave from Workbench',
                    l_debug);
        update_wave_header_status(x_return_status,
                                  p_wave_header_id,
                                  'Released(Warning)');
        get_actual_fill_rate(x_return_status, p_wave_header_id);

        print_debug('Status after Call to Get the Actual Fill Rate' ||
                    x_return_status,
                    l_debug);
        commit;
      end if;

    end if;
  EXCEPTION

    WHEN OTHERS THEN

      print_debug('Error in Release Online API : ' || SQLCODE || ' : ' ||
                  SQLERRM,
                  l_debug);

  END RELEASE_ONLINE;

  procedure create_batch_record(x_return_status  OUT nocopy varchar2,
                                p_wave_header_id in number)

   is

    p_FROM_ORDER_HEADER_ID       number;
    p_BACKORDERS_FLAG            varchar2(1);
    p_DOCUMENT_SET_ID            number;
    p_EXISTING_RSVS_ONLY_FLAG    varchar2(1);
    p_SHIPMENT_PRIORITY_CODE     varchar2(100);
    p_SHIP_METHOD_CODE           varchar2(100);
    p_CUSTOMER_ID                number;
    p_SHIP_SET_NUMBER            number;
    p_INVENTORY_ITEM_ID          number;
    p_ORDER_TYPE_ID              number;
    p_SHIP_TO_LOCATION_ID        number;
    p_TRIP_ID                    number;
    p_DELIVERY_ID                number;
    p_INCLUDE_PLANNED_LINES      varchar2(1);
    p_PICK_GROUPING_RULE_ID      number;
    p_PICK_SEQ_RULE_ID           number;
    p_AUTO_CREATE_DELIVERY       varchar2(1);
    p_TRIP_STOP_ID               number;
    p_DEFAULT_STAGE_SUBINVENTORY varchar2(100);
    p_DEFAULT_STAGE_LOCATOR_ID   number;
    p_PROJECT_ID                 number;
    p_TASK_ID                    number;
    p_ORGANIZATION_ID            number;
    p_TASK_PLANNING_FLAG         varchar2(1);
    p_CATEGORY_SET_ID            number;
    p_CATEGORY_ID                number;
    p_ac_DELIVERY_CRITERIA       varchar2(100);
    p_TASK_PRIORITY              number;
    p_DEFAULT_ALLOCATION_METHOD  varchar2(100);
    p_REPLENISHMENT_ONLY         varchar2(1);
    p_INITIATE_WAVE_PLANNING     varchar2(1);
    p_RELEASE_IMMEDIATELY        varchar2(1);
    p_pick_subinventory          varchar2(400);
    p_crossdock_criteria_name    varchar2(400);
    l_debug                      NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'),
                                               0);
  begin

    select FROM_ORDER_HEADER_ID,
           BACKORDERS_FLAG,
           SHIP_PRIORITY,
           SHIP_METHOD_CODE,
           CUSTOMER_ID,
           INVENTORY_ITEM_ID,
           ORDER_TYPE_ID,
           SHIP_TO_LOCATION_ID,
           TRIP_ID,
           DELIVERY_ID,
           INCLUDE_PLANNED_LINES,
           PICK_GROUPING_RULE_ID,
           PICK_SEQ_RULE_ID,
           AUTO_CREATE_DELIVERY,
           TRIP_STOP_ID,
           staging_subinventory,
           DEFAULT_STAGE_LOCATOR_ID,
           PROJECT_ID,
           TASK_ID,
           ORGANIZATION_ID,
           TASK_PLANNING_FLAG,
           CATEGORY_SET_ID,
           CATEGORY_ID,
           AUTO_CREATE_DELIVERY_CRITERIA,
           TASK_PRIORITY,
           DEFAULT_ALLOCATION_METHOD,
           pull_replenishment_flag,
           INITIATE_WAVE_PLANNING,
           RELEASE_IMMEDIATELY,
           pick_subinventory,
           cross_dock_criteria
      into p_FROM_ORDER_HEADER_ID,
           p_BACKORDERS_FLAG,
           p_SHIPMENT_PRIORITY_CODE,
           p_SHIP_METHOD_CODE,
           p_CUSTOMER_ID,
           p_INVENTORY_ITEM_ID,
           p_ORDER_TYPE_ID,
           p_SHIP_TO_LOCATION_ID,
           p_TRIP_ID,
           p_DELIVERY_ID,
           p_INCLUDE_PLANNED_LINES,
           p_PICK_GROUPING_RULE_ID,
           p_PICK_SEQ_RULE_ID,
           p_AUTO_CREATE_DELIVERY,
           p_TRIP_STOP_ID,
           p_DEFAULT_STAGE_SUBINVENTORY,
           p_DEFAULT_STAGE_LOCATOR_ID,
           p_PROJECT_ID,
           p_TASK_ID,
           p_ORGANIZATION_ID,
           p_TASK_PLANNING_FLAG,
           p_CATEGORY_SET_ID,
           p_CATEGORY_ID,
           p_ac_DELIVERY_CRITERIA,
           p_TASK_PRIORITY,
           p_DEFAULT_ALLOCATION_METHOD,
           p_REPLENISHMENT_ONLY,
           p_INITIATE_WAVE_PLANNING,
           p_RELEASE_IMMEDIATELY,
           p_pick_subinventory,
           p_crossdock_criteria_name
      from wms_wp_wave_headers_vl
     where wave_header_id = p_wave_header_id;

    /* Leave out parameters other than in Wave Options tab
    if p_FROM_ORDER_HEADER_ID is not null then
      new_wave_type.Order_Header_Id := p_FROM_ORDER_HEADER_ID;
    end if;

      if p_SHIPMENT_PRIORITY_CODE is not null then
      new_wave_type.Shipment_Priority_Code := p_SHIPMENT_PRIORITY_CODE;
    end if;
    if p_SHIP_METHOD_CODE is not null then
      new_wave_type.Ship_Method_Code := p_SHIP_METHOD_CODE;
    end if;
    if p_CUSTOMER_ID is not null then
      new_wave_type.Customer_Id := p_CUSTOMER_ID;
    end if;

    if p_INVENTORY_ITEM_ID is not null then
      new_wave_type.Inventory_Item_Id := p_INVENTORY_ITEM_ID;
    end if;
    if p_ORDER_TYPE_ID is not null then
      new_wave_type.Order_Type_Id := p_ORDER_TYPE_ID;
    end if;


    if p_TRIP_ID is not null then
      new_wave_type.Trip_Id := p_TRIP_ID;
    end if;
    if p_DELIVERY_ID is not null then
      new_wave_type.Delivery_Id := p_DELIVERY_ID;
    end if;

      if p_CATEGORY_SET_ID is not null then
      new_wave_type.Category_Set_ID := p_CATEGORY_SET_ID;
    end if;
    if p_CATEGORY_ID is not null then
      new_wave_type.Category_ID := p_CATEGORY_ID;
    end if;
         if p_TRIP_STOP_ID is not null then
      new_wave_type.Trip_Stop_Id := p_TRIP_STOP_ID;
    end if;
      if p_PROJECT_ID is not null then
      new_wave_type.Project_Id := p_PROJECT_ID;
    end if;
    */

    if p_crossdock_criteria_name is not null then
      new_wave_type.crossdock_criteria_name := p_crossdock_criteria_name;
    end if;

    if p_INCLUDE_PLANNED_LINES is not null then
      --Include Newly Added Columns
      new_wave_type.Include_Planned_Lines := p_INCLUDE_PLANNED_LINES;
    end if;
    if p_BACKORDERS_FLAG is not null then
      new_wave_type.Backorders_Only_Flag := p_BACKORDERS_FLAG;
    end if;
    if p_PICK_GROUPING_RULE_ID is not null then
      new_wave_type.Pick_Grouping_Rule_Id := p_PICK_GROUPING_RULE_ID;
    end if;
    if p_PICK_SEQ_RULE_ID is not null then
      new_wave_type.Pick_Sequence_Rule_Id := p_PICK_SEQ_RULE_ID;
    end if;
    if p_AUTO_CREATE_DELIVERY is not null then
      new_wave_type.Autocreate_Delivery_Flag := p_AUTO_CREATE_DELIVERY;
    end if;
    if p_SHIP_TO_LOCATION_ID is not null then
      --Need to modify the code for From and To Requested Date and From and To Scheduled Ship Date
      new_wave_type.Ship_To_Location_Id := p_SHIP_TO_LOCATION_ID;
    end if;
    if p_DEFAULT_STAGE_SUBINVENTORY is not null then
      new_wave_type. Default_Stage_Subinventory := p_DEFAULT_STAGE_SUBINVENTORY;
    end if;
    if p_DEFAULT_STAGE_LOCATOR_ID is not null then
      new_wave_type.Default_Stage_Locator_Id := p_DEFAULT_STAGE_LOCATOR_ID;
    end if;
    if p_SHIP_SET_NUMBER is not null then
      new_wave_type.Ship_Set_Number := p_SHIP_SET_NUMBER;
    end if;
    if p_ORGANIZATION_ID is not null then
      new_wave_type.Organization_Id := p_ORGANIZATION_ID;
    end if;
    if p_TASK_PLANNING_FLAG is not null then
      new_wave_type.Task_Planning_Flag := p_TASK_PLANNING_FLAG;
    end if;
    if p_DOCUMENT_SET_ID is not null then
      new_wave_type.document_set_id := p_DOCUMENT_SET_ID;
    end if;
    if p_REPLENISHMENT_ONLY is not null then
      new_wave_type.dynamic_replenishment_flag := p_REPLENISHMENT_ONLY;
    end if;

    if p_pick_subinventory is not null then
      new_wave_type.PICK_FROM_SUBINVENTORY := p_pick_subinventory;
    end if;

    if p_ac_DELIVERY_CRITERIA is not null then
      new_wave_type.ac_Delivery_Criteria := p_ac_DELIVERY_CRITERIA;
    end if;
    if p_TASK_PRIORITY is not null then
      new_wave_type.task_priority := p_TASK_PRIORITY;
    end if;
    if p_DEFAULT_ALLOCATION_METHOD is not null then
      new_wave_type.allocation_method := p_DEFAULT_ALLOCATION_METHOD;
    end if;
    --Few columns in the PL/SQL record does not contain corresponding match in the headers table.
    --Will add Attributes in the end. As of now not adding that
    x_return_status := 'S';
    print_debug('Exited Create Batch Record API ', l_debug);
  exception

    when others then
      x_return_status := 'E';
      print_debug('Error in create batch record API : ' || SQLCODE ||
                  ' : ' || SQLERRM,
                  l_debug);
  end create_batch_record;

  --
  -- Name
  --   PROCEDURE Init_Rules
  --
  -- Purpose
  --   Retrieves sequencing information based on sequence rule
  --   Retrieves group by based on grouping rule
  --
  -- Input Parameter
  --   p_pick_seq_rule_id       - pick sequence rule
  --   p_pick_grouping_rule_id  - pick grouping rule
  --
  -- Output Parameters
  --   x_api_status      - Success, Error, Unexpected Error
  --
  PROCEDURE Init_Rules(p_pick_seq_rule_id      IN NUMBER,
                       p_pick_grouping_rule_id IN NUMBER,
                       x_api_status            OUT NOCOPY VARCHAR2) IS
    -- cursor to fetch pick sequence rule info
    CURSOR pick_seq_rule(v_psr_id IN NUMBER) IS
      SELECT NAME,
             NVL(ORDER_ID_PRIORITY, -1),
             DECODE(ORDER_ID_SORT, 'A', 'ASC', 'D', 'DESC', ''),
             NVL(INVOICE_VALUE_PRIORITY, -1),
             DECODE(INVOICE_VALUE_SORT, 'A', 'ASC', 'D', 'DESC', ''),
             NVL(SCHEDULE_DATE_PRIORITY, -1),
             DECODE(SCHEDULE_DATE_SORT, 'A', 'ASC', 'D', 'DESC', ''),
             NVL(SHIPMENT_PRI_PRIORITY, -1),
             DECODE(SHIPMENT_PRI_SORT, 'A', 'ASC', 'D', 'DESC', ''),
             NVL(TRIP_STOP_DATE_PRIORITY, -1),
             DECODE(TRIP_STOP_DATE_SORT, 'A', 'ASC', 'D', 'DESC', '')
        FROM WSH_PICK_SEQUENCE_RULES
       WHERE PICK_SEQUENCE_RULE_ID = v_psr_id
         AND SYSDATE BETWEEN TRUNC(NVL(START_DATE_ACTIVE, SYSDATE)) AND
             NVL(END_DATE_ACTIVE, TRUNC(SYSDATE) + 1);

    -- cursor to determine if pick slip rule contains order number
    CURSOR order_ps_group(v_pgr_id IN NUMBER) IS
      SELECT NVL(ORDER_NUMBER_FLAG, 'N')
        FROM WSH_PICK_GROUPING_RULES
       WHERE PICK_GROUPING_RULE_ID = v_pgr_id
         AND SYSDATE BETWEEN TRUNC(NVL(START_DATE_ACTIVE, SYSDATE)) AND
             NVL(END_DATE_ACTIVE, TRUNC(SYSDATE) + 1);

    l_pick_seq_rule_name      VARCHAR2(30);
    l_invoice_value_priority  NUMBER;
    l_order_number_priority   NUMBER;
    l_schedule_date_priority  NUMBER;
    l_trip_stop_date_priority NUMBER;
    l_shipment_pri_priority   NUMBER;
    l_invoice_value_sort      VARCHAR2(4);
    l_order_number_sort       VARCHAR2(4);
    l_schedule_date_sort      VARCHAR2(4);
    l_trip_stop_date_sort     VARCHAR2(4);
    l_shipment_pri_sort       VARCHAR2(4);
    i                         NUMBER;
    j                         NUMBER;
    l_temp_psr                psrTyp;
    l_cs                      NUMBER;
    l_debug                   NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'),
                                            0);

  BEGIN
    print_debug('Fetching pick sequence rule information for the batch',
                l_debug);
    -- fetch pick sequence rule parameters
    OPEN pick_seq_rule(p_pick_seq_rule_id);
    FETCH pick_seq_rule
      INTO l_pick_seq_rule_name, l_order_number_priority,
       l_order_number_sort, l_invoice_value_priority,
        l_invoice_value_sort, l_schedule_date_priority,
         l_schedule_date_sort, l_shipment_pri_priority,
         l_shipment_pri_sort, l_trip_stop_date_priority,
          l_trip_stop_date_sort;

    -- handle pick sequence rule does not exist
    IF pick_seq_rule%NOTFOUND THEN
      print_debug('Pick sequence rule ID ' || to_char(g_pick_seq_rule_id) ||
                  ' does not exist.',
                  l_debug);
      x_api_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RETURN;
    END IF;
    IF pick_seq_rule%ISOPEN THEN
      CLOSE pick_seq_rule;
    END IF;

    -- initialize the pick sequence rule parameters
    i := 1;
    IF (l_invoice_value_priority <> -1) THEN
      g_ordered_psr(i).attribute := C_INVOICE_VALUE;
      g_ordered_psr(i).attribute_name := 'INVOICE_VALUE';
      -- initialize the invoice_value_flag to be used as part
      -- of building the select statement
      /*??   g_invoice_value_flag := 'Y'; */
      g_ordered_psr(i).priority := l_invoice_value_priority;
      g_ordered_psr(i).sort_order := l_invoice_value_sort;
      i := i + 1;
    END IF;
    IF (l_order_number_priority <> -1) THEN
      g_ordered_psr(i).attribute := C_ORDER_NUMBER;
      g_ordered_psr(i).attribute_name := 'ORDER_NUMBER';
      g_ordered_psr(i).priority := l_order_number_priority;
      g_ordered_psr(i).sort_order := l_order_number_sort;
      i := i + 1;
    END IF;
    IF (l_schedule_date_priority <> -1) THEN
      g_ordered_psr(i).attribute := C_SCHEDULE_DATE;
      g_ordered_psr(i).attribute_name := 'SCHEDULE_DATE';
      g_ordered_psr(i).priority := l_schedule_date_priority;
      g_ordered_psr(i).sort_order := l_schedule_date_sort;
      i := i + 1;
    END IF;
    IF (l_trip_stop_date_priority <> -1) THEN
      g_ordered_psr(i).attribute := C_TRIP_STOP_DATE;
      g_ordered_psr(i).attribute_name := 'TRIP_STOP_DATE';
      g_ordered_psr(i).priority := l_trip_stop_date_priority;
      g_ordered_psr(i).sort_order := l_trip_stop_date_sort;
      i := i + 1;
    END IF;
    IF (l_shipment_pri_priority <> -1) THEN
      g_ordered_psr(i).attribute := C_SHIPMENT_PRIORITY;
      g_ordered_psr(i).attribute_name := 'SHIPMENT_PRIORITY';
      g_ordered_psr(i).priority := l_shipment_pri_priority;
      g_ordered_psr(i).sort_order := l_shipment_pri_sort;
      i := i + 1;
    END IF;
    g_total_pick_criteria := i - 1;

    -- sort the table for pick sequence rule according to priority
    FOR i IN 1 .. g_total_pick_criteria LOOP
      FOR j IN i + 1 .. g_total_pick_criteria LOOP
        IF (g_ordered_psr(j).priority < g_ordered_psr(i).priority) THEN
          l_temp_psr := g_ordered_psr(j);
          g_ordered_psr(j) := g_ordered_psr(i);
          g_ordered_psr(i) := l_temp_psr;
        END IF;
      END LOOP;
    END LOOP;

    -- determine the most significant pick sequence rule attribute
    g_primary_psr := g_ordered_psr(1).attribute_name;
    print_debug('Primary pick rule is ' || g_primary_psr, l_debug);

    -- print pick sequence rule information for debugging purposes
    FOR i IN 1 .. g_total_pick_criteria LOOP
      print_debug('attribute = ' || g_ordered_psr(i)
                  .attribute_name || ' ' || 'priority = ' ||
                  to_char(g_ordered_psr(i).priority) || ' ' || 'sort = ' ||
                  g_ordered_psr(i).sort_order,
                  l_debug);
    END LOOP;
    --Need to remove this part
    /*
      print_debug('Determining if order number is in grouping rule...',
                  l_debug);
      OPEN order_ps_group(p_pick_grouping_rule_id);
      FETCH order_ps_group
        INTO g_use_order_ps;
      IF order_ps_group%NOTFOUND THEN
        g_use_order_ps := 'N';
      END IF;
      IF order_ps_group%ISOPEN THEN
        CLOSE order_ps_group;
      END IF;
    */
    x_api_status := fnd_api.g_ret_sts_success;

  EXCEPTION
    -- handle other errors
    WHEN OTHERS THEN
      IF pick_seq_rule%ISOPEN THEN
        CLOSE pick_seq_rule;
      END IF;
      IF order_ps_group%ISOPEN THEN
        CLOSE order_ps_group;
      END IF;
      print_debug('Unexpected error in Init_Rules', l_debug);
      x_api_status := FND_API.G_RET_STS_ERROR;
  END Init_Rules;

  procedure launch_online(x_return_status     OUT nocopy VARCHAR2,
                          p_wave_header_id    IN NUMBER,
                          v_orgid             in number,
                          p_release_immediate in varchar2,
                          p_plan_wave         in varchar2,
                          p_request_id        OUT NOCOPY number,
                          p_add_lines         in varchar2 default 'N') IS

    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    --x_return_status varchar2(20);
    x_msg_count            varchar2(100);
    x_msg_data             varchar2(100);
    p_batch_id             number;
    p_planning_criteria_id number;
    wave_line_exception exception;
  begin
    print_debug('In Launch Online', l_debug);

    savepoint create_wave_lines_online_sp;
    --Get Dynamic SQL and insert into Lines Table
    get_dynamic_sql(p_wave_header_id, v_orgid, x_return_status);

    print_debug('Status after call to get Dynamic SQL ' || x_return_status,
                l_debug);

    if x_return_status = 'S' then

      if p_plan_wave = 'Y' then

        select planning_criteria_id
          into p_planning_criteria_id
          from wms_wp_wave_headers_vl
         where wave_header_id = p_wave_header_id;

        print_debug('In Launch Online Plan Wave with Planning Criteria Id ' ||
                    p_planning_criteria_id,
                    l_debug);
        WMS_WAVE_PLANNING_PVT.Plan_Wave(p_wave_header_id,
                                        p_planning_criteria_id,
                                        x_return_status);
      end if;

    else

      if p_Add_lines = 'Y' then
        rollback to create_wave_lines_online_sp;
        RAISE fnd_api.g_exc_unexpected_error;
      else
        raise wave_line_exception;
      end if;
    end if;
    if x_return_status = 'S' then
      print_debug('In Launch Online Release Immediately ' ||
                  p_release_immediate,
                  l_debug);
      if p_release_immediate = 'Y' then
        create_batch_record(x_return_status, p_wave_header_id);

        if x_return_status = 'S' then

          -- Need to firm the wave as releasing it will firm the wave
          savepoint release_wave_lines_sp;

          UPDATE wms_wp_wave_lines
             SET message               = 'This line has been Firmed in Wave ' ||
                                         p_wave_header_id,
                 remove_from_Wave_flag = 'Y'
           WHERE delivery_detail_id IN
                 (SELECT delivery_detail_id
                    FROM wms_wp_wave_lines
                   WHERE wave_header_id = p_wave_header_id
                     and nvl(remove_from_wave_flag, 'N') <> 'Y')
             and wave_header_id <> p_wave_header_id;

          update wms_wp_wave_headers_vl
             set wave_firmed_flag = 'Y'
           where wave_header_id = p_wave_header_id;

          print_debug('In Launch Online Before Calling Release Wave',
                      l_debug);

          WSH_PICKING_BATCHES_GRP.release_wms_wave(p_release_mode        => 'ONLINE',
                                                   p_pick_wave_header_id => p_wave_header_id,
                                                   x_request_id          => p_request_id,
                                                   X_RETURN_STATUS       => X_RETURN_STATUS,
                                                   X_MSG_COUNT           => X_MSG_COUNT,
                                                   X_MSG_DATA            => X_MSG_DATA,
                                                   P_BATCH_REC           => new_wave_type,
                                                   X_BATCH_ID            => p_BATCH_ID);
        end if;
        if x_return_status = 'S' then
          print_debug('Updating Wave Header Status after Calling Release Wave',
                      l_debug);
          update_wave_header_status(x_return_status,
                                    p_wave_header_id,
                                    'Released');
          --Update the Actual Fill Rate
          get_actual_fill_rate(x_return_status, p_wave_header_id);

          print_debug('Status after Call to Get the Actual Fill Rate' ||
                      x_return_status,
                      l_debug);

      elsif  x_return_status = 'W' then
 print_debug('Updating Wave Header Status after Calling Release Wave',
                      l_debug);
          update_wave_header_status(x_return_status,
                                    p_wave_header_id,
                                    'Released(Warning)');
          --Update the Actual Fill Rate
          get_actual_fill_rate(x_return_status, p_wave_header_id);

          print_debug('Status after Call to Get the Actual Fill Rate' ||
                      x_return_status,
                      l_debug);


else
          rollback to release_wave_lines_sp;
          RAISE fnd_api.g_exc_unexpected_error;
        end if;
      end if;

    end if;

    commit;

  EXCEPTION
    WHEN wave_line_exception then

      rollback to create_wave_lines_online_sp;

      delete_wave_header(p_wave_header_id);
      RAISE fnd_api.g_exc_unexpected_error;

    WHEN OTHERS THEN
      print_debug('Error in Launch Online : ' || SQLCODE || ' : ' ||
                  SQLERRM,
                  l_debug);
  end launch_online;

  procedure get_dynamic_sql(p_wave_header_id in number,
                            org_id           in number,
                            x_return_status  OUT NOCOPY varchar2) is
    l_debug           NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    l_organization_id number := org_id;
    l_return_status   varchar2(30);
    l_done_flag       varchar2(10);
    v_advanced_sql    varchar2(4000);
    v_wave_sql        varchar2(4000);

    l_to_sub_tmp            VARCHAR2(10);
    l_to_loc_tmp            NUMBER;
    l_pick_seq_rule_id      NUMBER;
    l_pick_grouping_rule_id NUMBER;
    l_ps_mode               VARCHAR2(1);
    l_use_header_flag       VARCHAR2(1);
    l_firmed_flag           varchar2(1);
    l_count                 number;

    l_api_is_implemented     BOOLEAN;
    l_custom_line_tbl        line_tbl_typ;
    l_custom_line_action_tbl action_tbl_typ;
    l_replenishment_status   VARCHAR2(1);
    l_released_status        VARCHAR2(1);
    l_msg_count              varchar2(100);
    l_msg_data               varchar2(100);
    l_tbl_count number;

    CURSOR get_default_params(v_org_id IN NUMBER) IS
      SELECT NVL(PRINT_PICK_SLIP_MODE, 'E'),
             NVL(AUTOCREATE_DEL_ORDERS_FLAG, 'Y'),
             DEFAULT_STAGE_SUBINVENTORY,
             DEFAULT_STAGE_LOCATOR_ID,
             PICK_SEQUENCE_RULE_ID,
             PICK_GROUPING_RULE_ID
        FROM WSH_SHIPPING_PARAMETERS
       WHERE ORGANIZATION_ID = org_id;

    cursor c_get_wave_parameters is
      SELECT restrictions.PARAMETER_ID,
             restrictions.OPERATOR_MEANING,
             restrictions.OPERAND_VALUE
        FROM WMS_WP_ADVANCED_CRITERIA restrictions,
             wms_wp_wave_headers_vl   headers
       WHERE restrictions.RULE_WAVE_HEADER_ID = headers.wave_header_id
         and restrictions.RULE_WAVE_HEADER_ID = P_WAVE_HEADER_ID
         AND PARAMETER_ID IN (6002, 6003, 6004, 6005, 6006);

    cursor c_get_wave_line_count is
      SELECT restrictions.PARAMETER_ID,
             restrictions.OPERATOR_MEANING,
             restrictions.OPERAND_VALUE
        FROM WMS_WP_ADVANCED_CRITERIA restrictions,
             wms_wp_wave_headers_vl   headers
       WHERE restrictions.RULE_WAVE_HEADER_ID = headers.wave_header_id
         and restrictions.RULE_WAVE_HEADER_ID = P_WAVE_HEADER_ID
         AND PARAMETER_ID = 6001;

  begin

    print_debug('Entered Get Dynamic SQL ' || l_return_status, l_debug);

    select advanced_criteria, nvl(wave_firmed_flag, 'N')
      into v_advanced_sql, l_firmed_flag
      from wms_wp_wave_headers_vl
     where wave_header_id = p_wave_header_id;

    OPEN get_default_params(org_id);
    FETCH get_default_params
      INTO l_ps_mode, l_use_header_flag, l_to_sub_tmp, l_to_loc_tmp, l_pick_seq_rule_id, l_pick_grouping_rule_id;

    IF (l_pick_grouping_rule_id IS NOT NULL AND g_pick_seq_rule_id IS NULL) THEN
      -- This case shd not happen....as release sequence rule is mandatory field in UI
      WMS_WAVE_PLANNING_PVT.Init_Rules(l_pick_seq_rule_id,
                                       l_pick_grouping_rule_id,
                                       l_return_status);

    else

      WMS_WAVE_PLANNING_PVT.Init_Rules(g_pick_seq_rule_id,
                                       g_pick_grouping_rule_id,
                                       l_return_status);

    end if;

    WMS_WAVE_PLANNING_PVT.Init_Cursor(l_organization_id,
                                      v_advanced_sql,
                                      P_WAVE_HEADER_ID,
                                      l_return_status);

    print_debug('init cursor status ' || l_return_status, l_debug);

    IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      print_debug('Error occurred in Init_Cursor', l_debug);
      x_return_status := 'E';
      --  RETURN;
    elsif l_return_status = FND_API.G_RET_STS_SUCCESS then
      print_Debug('before get Lines ' || l_return_status, l_Debug);

      WMS_WAVE_PLANNING_PVT.Get_Lines(l_done_flag, l_return_status);

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        print_debug('Error occurred in Get Lines', l_debug);
        -- RETURN;
        x_return_status := 'E';
      else

        FORALL i IN 1 .. release_table.Count
          insert into wms_wp_wave_lines
            (WAVE_HEADER_ID,
             WAVE_LINE_ID,
             WAVE_LINE_SOURCE,
             WAVE_LINE_STATUS,
             CREATED_BY,
             CREATION_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATE_LOGIN,
             SOURCE_CODE,
             SOURCE_HEADER_ID,
             SOURCE_LINE_ID,
             SOURCE_HEADER_NUMBER,
             SOURCE_LINE_NUMBER,
             SOURCE_HEADER_TYPE_ID,
             SOURCE_DOCUMENT_TYPE_ID,
             DELIVERY_DETAIL_ID,
             delivery_id,
             ORGANIZATION_ID,
             INVENTORY_ITEM_ID,
             REQUESTED_QUANTITY,
             REQUESTED_QUANTITY_UOM,
             REQUESTED_QUANTITY2,
             REQUESTED_QUANTITY_UOM2,
             DEMAND_SOURCE_HEADER_ID,
             NET_WEIGHT,
             VOLUME,
             NET_VALUE,
             REMOVE_FROM_WAVE_FLAG,
             ATTRIBUTE_CATEGORY,
             ATTRIBUTE1,
             ATTRIBUTE2,
             ATTRIBUTE3,
             ATTRIBUTE4,
             ATTRIBUTE5,
             ATTRIBUTE6,
             ATTRIBUTE7,
             ATTRIBUTE8,
             ATTRIBUTE9,
             ATTRIBUTE10,
             ATTRIBUTE11,
             ATTRIBUTE12,
             ATTRIBUTE13,
             ATTRIBUTE14,
             ATTRIBUTE15)
          values
            (p_wave_header_id,
             WMS_WP_WAVE_LINES_S.NEXTVAL,
             'OE',
             'Created',
             fnd_global.user_id,
             sysdate,
             fnd_global.user_id,
             sysdate,
             fnd_global.login_id,
             l_source_code_tb(i),
             l_source_header_id_tb(i),
             l_source_line_id_tb(i),
             l_source_header_number_tb(i),
             l_source_line_number_tb(i),
             l_source_header_type_id_tb(i),
             l_source_document_type_id_tb(i),
             l_delivery_Detail_id_tb(i),
             l_delivery_id_tb(i),
             l_organization_id_tb(i),
             l_item_id_tb(i),
             l_requested_quantity_tb(i),
             l_requested_quantity_uom_tb(i),
             l_requested_quantity2_tb(i),
             l_requested_quantity_uom2_tb(i),
             inv_salesorder.get_salesorder_for_oeheader(l_source_header_id_tb(i)), --???????? Demand Source Header Id
             l_net_weight_tb(i),
             l_volume_tb(i),
             OUTSTANDING_ORDER_VALUE(l_source_header_id_tb(i),
                                     l_source_line_id_tb(i)), -- net value ????
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             null);

        --   commit;

        -- Honor the Wave Aggregate parameters

        for c_rec in c_get_wave_parameters loop

          exit when c_get_wave_parameters%NOTFOUND;

          if c_rec.operator_meaning in ('>', '>=', '=') then

            print_debug('Entered Wave Parameter with >, >= ,= operators  ',
                        l_debug);
            print_debug('If Criteria is not satified Wave Lines wont be created. ',
                        l_debug);

            if c_rec.parameter_id in (6002) then

              -- Total Weight

              select sum(net_weight)
                into l_count
                from wms_wp_wave_lines
               where wave_header_id = p_wave_header_id;

              print_debug('Entered Wave Parameter with >, >= ,= operators  --- >  Total Weight ',
                          l_debug);

              print_debug(' Total Weight  in Lines in the Wave is ' ||
                          l_count,
                          l_debug);

              print_debug(' Total Weight given in the Criteria is  ' ||
                          C_REC.OPERAND_VALUE,
                          l_debug);

              if c_rec.operator_meaning = '=' then

                if l_count = C_REC.OPERAND_VALUE then

                  print_debug('Criteria is satisfied. So not deleting any lines ',
                              l_debug);
                else
                  delete from wms_wp_wave_lines
                   where wave_header_id = p_wave_header_id;

                end if;
              elsif c_rec.operator_meaning = '>=' then

                if l_count >= C_REC.OPERAND_VALUE then
                  print_debug('Criteria is satisfied. So not deleting any lines ',
                              l_debug);
                else
                  delete from wms_wp_wave_lines
                   where wave_header_id = p_wave_header_id;

                end if;
              elsif c_rec.operator_meaning = '>' then

                if l_count > C_REC.OPERAND_VALUE then
                  print_debug('Criteria is satisfied. So not deleting any lines ',
                              l_debug);
                else
                  delete from wms_wp_wave_lines
                   where wave_header_id = p_wave_header_id;

                end if;

              end if;

            elsif c_rec.parameter_id in (6003) then

              -- Total Volume
              select sum(volume)
                into l_count
                from wms_wp_wave_lines
               where wave_header_id = p_wave_header_id;

              print_debug('Entered Wave Parameter with >, >= ,= operators  --- >  Total Volume ',
                          l_debug);

              print_debug(' Total Volume in Lines in the Wave is ' ||
                          l_count,
                          l_debug);

              print_debug(' Total Volume given in the Criteria is  ' ||
                          C_REC.OPERAND_VALUE,
                          l_debug);

              if c_rec.operator_meaning = '=' then

                if l_count = C_REC.OPERAND_VALUE then
                  print_debug('Criteria is satisfied. So not deleting any lines ',
                              l_debug);
                else
                  delete from wms_wp_wave_lines
                   where wave_header_id = p_wave_header_id;

                end if;
              elsif c_rec.operator_meaning = '>=' then

                if l_count >= C_REC.OPERAND_VALUE then
                  print_debug('Criteria is satisfied. So not deleting any lines ',
                              l_debug);
                else
                  delete from wms_wp_wave_lines
                   where wave_header_id = p_wave_header_id;

                end if;
              elsif c_rec.operator_meaning = '>' then

                if l_count > C_REC.OPERAND_VALUE then
                  print_debug('Criteria is satisfied. So not deleting any lines ',
                              l_debug);
                else
                  delete from wms_wp_wave_lines
                   where wave_header_id = p_wave_header_id;

                end if;

              end if;

            elsif c_rec.parameter_id in (6004) then

              -- Total Value
              select sum(net_value)
                into l_count
                from wms_wp_wave_lines
               where wave_header_id = p_wave_header_id;

              print_debug('Entered Wave Parameter with >, >= ,= operators  --- >  Total Value ',
                          l_debug);

              print_debug(' Total Value  in Lines in the Wave is ' ||
                          l_count,
                          l_debug);

              print_debug(' Total Value given in the Criteria is  ' ||
                          C_REC.OPERAND_VALUE,
                          l_debug);

              if c_rec.operator_meaning = '=' then

                if l_count = C_REC.OPERAND_VALUE then
                  print_debug('Criteria is satisfied. So not deleting any lines ',
                              l_debug);
                else
                  delete from wms_wp_wave_lines
                   where wave_header_id = p_wave_header_id;

                end if;
              elsif c_rec.operator_meaning = '>=' then

                if l_count >= C_REC.OPERAND_VALUE then
                  print_debug('Criteria is satisfied. So not deleting any lines ',
                              l_debug);
                else
                  delete from wms_wp_wave_lines
                   where wave_header_id = p_wave_header_id;

                end if;
              elsif c_rec.operator_meaning = '>' then

                if l_count > C_REC.OPERAND_VALUE then
                  print_debug('Criteria is satisfied. So not deleting any lines ',
                              l_debug);
                else
                  delete from wms_wp_wave_lines
                   where wave_header_id = p_wave_header_id;

                end if;

              end if;

            elsif c_rec.parameter_id in (6005) then
              --Delivery Count
              select count(distinct delivery_id)
                into l_count
                from wms_wp_wave_lines
               where wave_header_id = p_wave_header_id;

              print_debug('Entered Wave Parameter with >, >= ,= operators  --- > Delivery count ',
                          l_debug);

              print_debug(' Delivery count  in Lines in the Wave is ' ||
                          l_count,
                          l_debug);

              print_debug(' Delivery count  given in the Criteria is  ' ||
                          C_REC.OPERAND_VALUE,
                          l_debug);

              if c_rec.operator_meaning = '=' then

                if l_count = C_REC.OPERAND_VALUE then
                  print_debug('Criteria is satisfied. So not deleting any lines ',
                              l_debug);
                else
                  delete from wms_wp_wave_lines
                   where wave_header_id = p_wave_header_id;

                end if;
              elsif c_rec.operator_meaning = '>=' then

                if l_count >= C_REC.OPERAND_VALUE then
                  print_debug('Criteria is satisfied. So not deleting any lines ',
                              l_debug);
                else
                  delete from wms_wp_wave_lines
                   where wave_header_id = p_wave_header_id;

                end if;
              elsif c_rec.operator_meaning = '>' then

                if l_count > C_REC.OPERAND_VALUE then
                  print_debug('Criteria is satisfied. So not deleting any lines ',
                              l_debug);
                else
                  delete from wms_wp_wave_lines
                   where wave_header_id = p_wave_header_id;

                end if;

              end if;
            elsif c_rec.parameter_id in (6006) then
              -- Item Count
              select count(distinct inventory_item_id)
                into l_count
                from wms_wp_wave_lines
               where wave_header_id = p_wave_header_id;

              print_debug('Entered Wave Parameter with >, >= ,= operators  --- > Item count ',
                          l_debug);

              print_debug(' Item count  in Lines in the Wave is ' ||
                          l_count,
                          l_debug);

              print_debug(' Item count  given in the Criteria is  ' ||
                          C_REC.OPERAND_VALUE,
                          l_debug);

              if c_rec.operator_meaning = '=' then

                if l_count = C_REC.OPERAND_VALUE then
                  print_debug('Criteria is satisfied. So not deleting any lines ',
                              l_debug);
                else
                  delete from wms_wp_wave_lines
                   where wave_header_id = p_wave_header_id;

                end if;
              elsif c_rec.operator_meaning = '>=' then

                if l_count >= C_REC.OPERAND_VALUE then
                  print_debug('Criteria is satisfied. So not deleting any lines ',
                              l_debug);
                else
                  delete from wms_wp_wave_lines
                   where wave_header_id = p_wave_header_id;

                end if;
              elsif c_rec.operator_meaning = '>' then

                if l_count > C_REC.OPERAND_VALUE then
                  print_debug('Criteria is satisfied. So not deleting any lines ',
                              l_debug);
                else
                  delete from wms_wp_wave_lines
                   where wave_header_id = p_wave_header_id;

                end if;

              end if;

            end if;

            --       end if;

          else
            -- This is for criteria that is '<', '<=' where u need to delete the extra lines
            if c_rec.parameter_id in (6002, 6003, 6004) then

              if C_REC.OPERATOR_MEANING = '<' then

                C_REC.OPERATOR_MEANING := '>=';

              elsif C_REC.OPERATOR_MEANING = '<=' then

                C_REC.OPERATOR_MEANING := '>';

              end if;
            end if;

            if c_rec.parameter_id = 6002 then

              -- Total Weight

              EXECUTE IMMEDIATE 'delete from wms_wp_wave_lines where wave_line_id in
         (select wave_line_id from
             (select x.wave_line_id, x.Cum_total_weight
              from
                (
                   select wl.wave_line_id , SUM(wl.net_weight) OVER(ORDER BY wave_line_id) Cum_total_weight from wms_wp_wave_lines wl
                    where wave_header_id = :wave_header_id
                ) x
                 where Cum_total_weight ' ||
                                C_REC.OPERATOR_MEANING ||
                                C_REC.OPERAND_VALUE || '))'
                using p_wave_header_id;

              print_debug('No of Lines deleted based on condition Total Weight is  ' ||
                          SQL%ROWCOUNT,
                          l_debug);

            elsif c_rec.parameter_id = 6003 then

              -- Total Volume
              EXECUTE IMMEDIATE 'delete from wms_wp_wave_lines where wave_line_id in
         (select wave_line_id from
             (select x.wave_line_id, x.Cum_total_volume
              from
                (
                   select wl.wave_line_id , SUM(wl.volume) OVER(ORDER BY wave_line_id) Cum_total_volume from wms_wp_wave_lines wl
                    where wave_header_id = :wave_header_id
                ) x
                 where Cum_total_volume ' ||
                                C_REC.OPERATOR_MEANING ||
                                C_REC.OPERAND_VALUE || '))'
                using p_wave_header_id;

              print_debug('No of Lines deleted based on condition Total Volume is  ' ||
                          SQL%ROWCOUNT,
                          l_debug);

            elsif c_rec.parameter_id = 6004 then

              -- Total Value

              EXECUTE IMMEDIATE 'delete from wms_wp_wave_lines where wave_line_id in
         (select wave_line_id from
             (select x.wave_line_id, x.Cum_value
              from
                (
                   select wl.wave_line_id , SUM(wl.net_value) OVER(ORDER BY wave_line_id) Cum_value from wms_wp_wave_lines wl
                    where wave_header_id = :wave_header_id
                ) x
                 where Cum_value' ||
                                C_REC.OPERATOR_MEANING ||
                                C_REC.OPERAND_VALUE || '))'
                using p_wave_header_id;

              print_debug('No of Lines deleted based on condition Total Value is  ' ||
                          SQL%ROWCOUNT,
                          l_debug);

            elsif c_rec.parameter_id = 6005 then

              --Delivery Count
              EXECUTE IMMEDIATE 'delete from wms_wp_wave_lines where delivery_id not in
(
select delivery_id from
(
select  min(wwwl.WAVE_LINE_ID)  min_line_id, wnd.delivery_id
from WMS_WP_WAVE_LINES wwwl, wsh_delivery_details wdd,
WSH_NEW_DELIVERIES wnd,  WSH_DELIVERY_ASSIGNMENTS WDA
where wave_header_id = :p_wave_header_id
and  wnd.DELIVERY_ID(+) = WDA.DELIVERY_ID
AND   WDA.DELIVERY_DETAIL_ID = WDD.DELIVERY_DETAIL_ID
AND wwwl.delivery_Detail_id = WDD.DELIVERY_DETAIL_ID
AND wnd.delivery_id IS NOT null
                               group by wnd.delivery_id
                              order by min_line_id)' ||
                                ' where rownum ' || C_REC.OPERATOR_MEANING ||
                                C_REC.OPERAND_VALUE || ')' ||
                                ' and wave_header_id = :wave_header_id and delivery_id is not null '
                using p_wave_header_id, p_wave_header_id;

              print_debug('No of Lines deleted based on condition Delivery Count is  ' ||
                          SQL%ROWCOUNT,
                          l_debug);

            elsif c_rec.parameter_id = 6006 then

              --Item Count
              EXECUTE IMMEDIATE 'delete from wms_wp_wave_lines where inventory_item_id not in
(
select inventory_item_id from
(
select  min(wwwl.WAVE_LINE_ID)  min_line_id, inventory_item_id
from WMS_WP_WAVE_LINES wwwl
where wave_header_id = :wave_header_id
                               group by inventory_item_id
                              order by min_line_id) ' ||
                                ' where rownum ' || C_REC.OPERATOR_MEANING ||
                                C_REC.OPERAND_VALUE || ')' ||
                                ' and wave_header_id = :wave_header_id'
                using p_wave_header_id, p_wave_header_id;

              print_debug('No of Lines deleted based on condition Item Count is  ' ||
                          SQL%ROWCOUNT,
                          l_debug);

            end if;
          end if;

        end loop;

        for c_rec1 in c_get_wave_line_count loop
          exit when c_get_wave_line_count%NOTFOUND;
          if c_rec1.operator_meaning in ('>', '>=', '=') then

            -- Line Count
            select count(1)
              into l_count
              from wms_wp_wave_lines
             where wave_header_id = p_wave_header_id;

            print_debug('Entered Wave Parameter with >, >= ,= operators  --- > Line count ',
                        l_debug);

            print_debug(' Line count  in Lines in the Wave is ' || l_count,
                        l_debug);

            print_debug(' Line count  given in the Criteria is  ' ||
                        C_REC1.OPERAND_VALUE,
                        l_debug);

            if c_rec1.operator_meaning = '=' then

              if l_count = C_REC1.OPERAND_VALUE then
                print_debug('Criteria is satisfied. So not deleting any lines ',
                            l_debug);
              else
                delete from wms_wp_wave_lines
                 where wave_header_id = p_wave_header_id;

              end if;
            elsif c_rec1.operator_meaning = '>=' then

              if l_count >= C_REC1.OPERAND_VALUE then
                print_debug('Criteria is satisfied. So not deleting any lines ',
                            l_debug);
              else
                delete from wms_wp_wave_lines
                 where wave_header_id = p_wave_header_id;

              end if;
            elsif c_rec1.operator_meaning = '>' then

              if l_count > C_REC1.OPERAND_VALUE then
                print_debug('Criteria is satisfied. So not deleting any lines ',
                            l_debug);
              else
                delete from wms_wp_wave_lines
                 where wave_header_id = p_wave_header_id;

              end if;

            end if;
          else

            -- Line Count
            /*
            v_wave_sql := 'delete from wms_wp_wave_lines where rownum ' ||
                          C_REC1.OPERATOR_MEANING || C_REC1.OPERAND_VALUE ||
                          ' and wave_header_id = ' || p_wave_header_id;
            */
            EXECUTE IMMEDIATE 'delete from wms_wp_wave_lines where wave_line_id not in
          (
          select wave_line_id from wms_wp_wave_lines where wave_header_id = :wave_header_id and rownum' ||
                              C_REC1.OPERATOR_MEANING ||
                              C_REC1.OPERAND_VALUE || ' )' ||
                              ' and wave_header_id = :wave_header_id'
              using p_wave_header_id, p_wave_header_id;

            print_debug('No of Lines deleted based on condition Line Count is  ' ||
                        SQL%ROWCOUNT,
                        l_debug);
          end if;
        end loop;
        -- Make the delivery_id column as null for all the lines
        update wms_wp_wave_lines
           set delivery_id = null
         where wave_header_id = p_wave_header_id;
        print_debug('Firmed Flag is ' || l_firmed_flag, l_debug);

        if l_firmed_flag = 'Y' then
          UPDATE wms_wp_wave_lines
             SET message               = 'This line has been Firmed in Wave ' ||
                                         p_wave_header_id,
                 remove_from_Wave_flag = 'Y'
           WHERE delivery_detail_id IN
                 (SELECT delivery_detail_id
                    FROM wms_wp_wave_lines
                   WHERE wave_header_id = p_wave_header_id
                     and nvl(remove_from_wave_flag, 'N') <> 'Y')
             and wave_header_id <> p_wave_header_id;
        end if;

      end if;
      wms_wp_custom_apis_pub.create_wave_lines_cust(p_wave_header_id         => p_wave_header_id,
                                                    x_api_is_implemented     => l_api_is_implemented,
                                                    x_custom_line_tbl        => l_custom_line_tbl,
                                                    x_custom_line_action_tbl => l_custom_line_action_tbl,
                                                    x_return_status          => l_return_status,
                                                    x_msg_count              => l_msg_count,
                                                    x_msg_data               => l_msg_data);

      IF l_api_is_implemented AND
         l_return_status = fnd_api.g_ret_sts_success THEN
        print_debug('Custom API Implemented for create wave lines ',
                    l_debug);
                    l_tbl_count := l_custom_line_tbl.count;

       -- FORall i IN 0 .. l_tbl_count dbchange15
       FOR i IN l_custom_line_tbl.FIRST .. l_custom_line_tbl.LAST LOOP
          DELETE FROM wms_wp_wave_lines
           WHERE DELIVERY_DETAIL_ID = l_custom_line_tbl(i)
          .DELIVERY_DETAIL_ID
             AND l_custom_line_action_tbl(i) = 'REMOVE'
             AND wave_header_id = p_wave_header_id;
           end loop;

        print_debug('Deleted ' || SQL%ROWCOUNT ||
                    ' lines from wms_wp_wave_lines using custom API returned lines',
                    l_debug);

        FOR i IN l_custom_line_action_tbl.first .. l_custom_line_action_tbl.last loop
          IF l_custom_line_action_tbl(i) = 'ADD' THEN
            SELECT released_status, Nvl(replenishment_status, 'C')
              INTO l_released_status, l_replenishment_status
              FROM wsh_delivery_details
             WHERE delivery_detail_id = l_custom_line_tbl(i)
            .delivery_detail_id;

            IF (l_released_status = 'R' OR l_released_status = 'B') and
               l_replenishment_status = 'C' THEN
              DECLARE
                a number;
              begin
                SELECT (1)
                  INTO a
                  FROM dual
                 WHERE l_custom_line_tbl(i)
                .delivery_detail_id IN
                       (SELECT distinct wwl.delivery_detail_id
                          FROM WMS_WP_WAVE_LINES      wwl,
                               wms_wp_wave_headers_vl wwh
                         WHERE wwl.wave_header_id = 367
                            OR (wwl.wave_header_id = wwh.wave_header_id and
                               nvl(wwh.wave_firmed_flag, 'N') = 'Y' and
                               wwh.wave_status <> 'Cancelled' and
                               nvl(wwl.remove_from_wave_flag, 'N') <> 'Y'));

                print_debug('Not inserting detail line ' ||
                            l_custom_line_tbl(i)
                            .delivery_detail_id ||
                            ' returned by custom API as line already added to the current wave or it is firmed in other wave ',
                            l_debug);

                l_custom_line_tbl.delete(i);
                l_custom_line_action_tbl.delete(i);
              EXCEPTION
                WHEN No_Data_Found THEN
                  print_debug('Detail line ' || l_custom_line_tbl(i)
                              .delivery_detail_id ||
                              ' from custom API will be inserted into lines table',
                              l_debug);
              END;
            ELSE
              print_debug('Not inserting detail line ' ||
                          l_custom_line_tbl(i)
                          .delivery_detail_id ||
                          ' returned by custom API as replenishment is not completed yet',
                          l_debug);
              l_custom_line_tbl.delete(i);
              l_custom_line_action_tbl.delete(i);
            END IF;
          ELSE
            -- l_custom_line_action_tbl(i)='REMOVE' or some other value
            l_custom_line_tbl.delete(i);
            l_custom_line_action_tbl.delete(i);
          END IF;
        END LOOP;

        FORALL i IN l_custom_line_tbl.first .. l_custom_line_tbl.last
          INSERT INTO wms_wp_wave_lines VALUES l_custom_line_tbl (i);

        print_debug('Inserted ' || SQL%ROWCOUNT ||
                    ' detail lines returned by custom API into wms_wp_wave_lines ',
                    l_debug);

      END IF; -- custom API implemented

    end if;

    x_return_status := l_return_status;

  EXCEPTION
    WHEN OTHERS THEN
      print_debug('Unexpected error occurred in Get Dynamic SQL', l_debug);
      print_debug('Error : ' || SQLCODE || ' : ' || SQLERRM, l_debug);
      x_return_status := 'E';
  end get_dynamic_sql;

  PROCEDURE Init_Cursor(p_organization_id IN NUMBER,
                        v_advanced_sql    in varchar2,
                        V_WAVE_HEADER_ID  in NUMBER,
                        x_api_status      OUT NOCOPY VARCHAR2) IS
    l_debug              NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'),
                                       0);
    l_cs                 NUMBER;
    l_strlen             NUMBER;
    i                    NUMBER;
    g_advanced_sql       varchar2(4000);
    G_WHERE_SQL          VARCHAR2(32000);
    V_CURSOR_FLAG        VARCHAR2(1);
    ajith                varchar2(400);
    v_single_line_flag   varchar2(1) := 'N';
    v_delivery_flag      varchar2(1) := 'N';
    v_quantity_flag      varchar2(1) := 'N';
    v_ordercount_flag    varchar2(1) := 'N';
    v_item_flag          varchar2(1) := 'N';
    v_customerclass_flag varchar2(1) := 'N';

    -- Phase II Changes
    v_carrier_order_flag varchar2(1) := 'N';
    v_order_line_flag    varchar2(1) := 'N';
    v_trip_flag          varchar2(1) := 'N';
    v_cat_flag           varchar2(1) := 'N';

    CURSOR C_ADVANCED_CONDITION IS
      SELECT PARAMETER_ID
        FROM WMS_WP_ADVANCED_CRITERIA
       WHERE RULE_WAVE_HEADER_ID = V_WAVE_HEADER_ID
         AND PARAMETER_ID IN
             (1006, 2001, 2002, 3002, 5001, 5002, 5003, 5004, 5005, 5006, 3001, 1011, 1004, 2006, 2004, 2005, 4002);
  BEGIN
    --
    -- Make sure the first_line record has header_id set to -1
    -- This is used to determine whether the Get_Lines
    -- is called for the first time or not. The first_line is set
    -- as a dummy line

    print_debug('Entered Init Cursor ', l_debug);
    first_line.source_header_id := -1;
    g_del_current_line          := 1;
    g_advanced_sql              := v_advanced_sql;
    V_CURSOR_FLAG               := 'Y';

  SELECT  enforce_ship_set_and_smc
  INTO  g_enforce_ship_set_and_smc
    FROM   WSH_SHIPPING_PARAMETERS WSP
    WHERE    WSP.ORGANIZATION_ID = p_organization_id;



    G_WHERE_SQL := 'WHERE ';
    -- Selection for unreleased lines
    g_Unreleased_SQL := 'SELECT distinct WDD.SOURCE_CODE,' ||
                        '       WDD.SOURCE_HEADER_ID,' ||
                        '       WDD.SOURCE_LINE_ID,' ||
                        '       WDD.SOURCE_HEADER_NUMBER,' ||
                        '       WDD.SOURCE_LINE_NUMBER,' ||
                        '       WDD.SOURCE_HEADER_TYPE_NAME,' ||
                        '       WDD.SOURCE_HEADER_TYPE_ID,' ||
                        '       WDD.SOURCE_DOCUMENT_TYPE_ID,' ||
                        '       WDD.DELIVERY_DETAIL_ID,' ||
                        '       WDD.RELEASED_STATUS,' ||
                        '       WDD.ORGANIZATION_ID,' ||
                        '       WDD.INVENTORY_ITEM_ID,' ||
                        '       WDD.REQUESTED_QUANTITY,' ||
                        '       WDD.REQUESTED_QUANTITY_UOM,' ||
                        '       WDD.MOVE_ORDER_LINE_ID,' ||
                        '       WDD.SHIP_MODEL_COMPLETE_FLAG,' ||
                        '       WDD.TOP_MODEL_LINE_ID,' ||
                        '       WDD.SHIP_FROM_LOCATION_ID,' ||
                        '       WDD.SHIP_TO_LOCATION_ID,' ||
                        '       WDD.SHIP_METHOD_CODE,' ||
                        '       WDD.SHIPMENT_PRIORITY_CODE,' ||
                        '       WDD.SHIP_SET_ID,' ||
                        '       WDD.DATE_SCHEDULED,' ||
                        '       WTS.PLANNED_DEPARTURE_DATE,' ||
                        '       WDA.DELIVERY_ID,' ||
                        '       WDD.CUSTOMER_ID,' ||
                        '       WDD.CARRIER_ID,' ||
                        '       WDD.PREFERRED_GRADE,' ||
                        '       WDD.SRC_REQUESTED_QUANTITY2,' ||
                        '       WDD.SRC_REQUESTED_QUANTITY_UOM2,' ||
                        '       WDD.PROJECT_ID,' || '       WDD.TASK_ID,' ||
                        '       WDD.SUBINVENTORY,' ||
                        '       WDD.WEIGHT_UOM_CODE,' ||
                        '       WDD.NET_WEIGHT,' || --????? Is it Net Weight or Gross Weight
                        '       WDD.VOLUME_UOM_CODE,' ||
                        '       WDD.VOLUME '; -- Ajith Changed Need to Check
    g_Unreleased_SQL := g_Unreleased_SQL ||
                        ' FROM  WSH_DELIVERY_DETAILS WDD,' ||
                        '       WSH_NEW_DELIVERIES WDE,' ||
                        '       WSH_DELIVERY_ASSIGNMENTS WDA,' ||
                        '       WSH_DELIVERY_LEGS WLG,' ||
                        '       WSH_TRIP_STOPS WTS, ' ||
                        '       WMS_DOCK_APPOINTMENTS_B WDO ';

    FOR CUR_REC IN C_ADVANCED_CONDITION LOOP

      IF CUR_REC.PARAMETER_ID = 2002 THEN
        if v_quantity_flag = 'N' then
          g_Unreleased_SQL := g_Unreleased_SQL ||
                              ',(SELECT SUM(WDD1.SRC_REQUESTED_QUANTITY) QUANTITY, WDD1.SOURCE_LINE_ID FROM WSH_DELIVERY_DETAILS WDD1
                           GROUP BY WDD1.SOURCE_LINE_ID) SALES_ORDER_LINE ';

          g_WHERE_SQL := g_WHERE_SQL ||
                         ' WDD.SOURCE_LINE_ID=SALES_ORDER_LINE.SOURCE_LINE_ID  AND ';

        end if;
        v_quantity_flag := 'Y';
        --   g_WHERE_SQL := g_WHERE_SQL || ' '||g_advanced_sql;

      ELSIF CUR_REC.PARAMETER_ID = 3002 THEN
        if v_ordercount_flag = 'N' then
          g_Unreleased_SQL := g_Unreleased_SQL ||
                              ',(SELECT COUNT(distinct SOURCE_HEADER_NUMBER) ORDER_COUNT , WDE.DELIVERY_ID DELIVERY_ID FROM WSH_DELIVERY_DETAILS WDD ,WSH_NEW_DELIVERIES WDE, WSH_DELIVERY_ASSIGNMENTS WDA
                                                WHERE  WDE.DELIVERY_ID = WDA.DELIVERY_ID AND   WDA.DELIVERY_DETAIL_ID = WDD.DELIVERY_DETAIL_ID
                                                 GROUP BY WDE.DELIVERY_ID) DELIVERY ';
          g_WHERE_SQL      := g_WHERE_SQL ||
                              ' WDE.DELIVERY_ID=DELIVERY.DELIVERY_ID  AND ';
          -- g_WHERE_SQL := g_WHERE_SQL || ' '||g_advanced_sql;
        end if;
        v_ordercount_flag := 'Y';
        /*
        ELSIF CUR_REC.PARAMETER_ID = 1005 THEN
          --SINGLE LINE ORDER
          g_WHERE_SQL        := g_WHERE_SQL || g_ADVANCED_SQL ||
                                ' select 1  FROM wsh_delivery_details wdd1 where wdd1.source_header_number = wdd.source_header_number GROUP BY SOURCE_HEADER_NUMBER HAVING Count(SOURCE_HEADER_NUMBER)=1)';
          v_single_line_flag := 'Y';
        */
      elsif cur_rec.parameter_id IN (5001, 5002, 5003, 5004, 2001, 5005) then
        --ITEM
        if v_item_flag = 'N' then
          g_Unreleased_SQL := g_Unreleased_SQL ||
                              ',MTL_SYSTEM_ITEMS_B MSIB ';
          g_WHERE_SQL      := g_WHERE_SQL ||
                              ' WDD.INVENTORY_ITEM_ID=MSIB.INVENTORY_ITEM_ID  AND ';
        end if;
        v_item_flag := 'Y';
        -- g_WHERE_SQL := g_WHERE_SQL || ' '||g_advanced_sql;
      elsif cur_rec.parameter_id IN (4002) then
        --TRIP Carrier
        if v_trip_flag = 'N' then
          g_Unreleased_SQL := g_Unreleased_SQL || ',WSH_TRIPS WT ';
          g_WHERE_SQL      := g_WHERE_SQL ||
                              ' WTS.TRIP_ID=WT.TRIP_ID  AND ';
        end if;
        v_trip_flag := 'Y';

      elsif cur_rec.parameter_id IN (5006) then
        --Item Category
        if v_cat_flag = 'N' then
          g_Unreleased_SQL := g_Unreleased_SQL ||
                              ',MTL_ITEM_CATEGORIES MIC ';
          g_WHERE_SQL      := g_WHERE_SQL ||
                              ' MIC.INVENTORY_ITEM_ID=WDD.INVENTORY_ITEM_ID  AND ';
        end if;
        v_cat_flag := 'Y';

      elsif cur_rec.parameter_id IN (1011, 1004) then
        -- Ship Method, Carrier, Scheduled Ship Date
        if v_carrier_order_flag = 'N' then
          g_Unreleased_SQL := g_Unreleased_SQL ||
                              ',oe_order_headers_all OOHA ';
          g_WHERE_SQL      := g_WHERE_SQL ||
                              ' WDD.source_header_id=OOHA.header_id  AND ';
        end if;
        v_carrier_order_flag := 'Y';
        -- g_WHERE_SQL := g_WHERE_SQL || ' '||g_advanced_sql;

      elsif cur_rec.parameter_id IN (2004, 2005, 2006) then
        -- Ship Method, Carrier, Scheduled Ship Date
        if v_order_line_flag = 'N' then
          g_Unreleased_SQL := g_Unreleased_SQL ||
                              ',oe_order_lines_all OOLA ';
          g_WHERE_SQL      := g_WHERE_SQL ||
                              ' WDD.source_header_id=OOLA.header_id  AND WDD.SOURCE_LINE_ID=OOLA.LINE_ID and ';
        end if;
        v_order_line_flag := 'Y';
        -- g_WHERE_SQL := g_WHERE_SQL || ' '||g_advanced_sql;

      ELSIF CUR_REC.PARAMETER_ID = 1006 THEN
        --CUSTOMER CATEGORY
        if v_customerclass_flag = 'N' then
          g_Unreleased_SQL := g_Unreleased_SQL ||
                              ',(select  cust_Acct.customer_class_code customer_class_code,
          cust_acct.cust_account_id cust_account_id from
 hz_parties PARTY
, hz_cust_accounts CUST_ACCT
where party.party_id = cust_acct.party_id
and cust_acct.status = ''A'') CUSTOMER_CLASS  ';

          g_WHERE_SQL := g_WHERE_SQL ||
                         ' CUSTOMER_CLASS.cust_account_id = WDD.CUSTOMER_ID AND ';
        end if;
        v_customerclass_flag := 'Y';
      elsif CUR_REC.PARAMETER_ID = 3001 then

        --Putting g_Delivery_id as -1 if delivery id is chosen in advanced criteria tab

        g_DELIVERY_ID := -1;

      end if;

      IF C_ADVANCED_CONDITION%ROWCOUNT > 0 THEN

        V_CURSOR_FLAG := 'N';
      END IF;

    END LOOP;
    if v_single_line_flag <> 'Y' then
      IF V_CURSOR_FLAG = 'Y' THEN
        g_WHERE_SQL := g_WHERE_SQL || G_ADVANCED_SQL;

      else

        g_WHERE_SQL := g_WHERE_SQL || ' ' || g_advanced_sql;
      END IF;
    end if;

    if g_advanced_sql is null then
      g_WHERE_SQL := g_WHERE_SQL || ' 1=1 ';
    end if;
    g_Unreleased_SQL := g_Unreleased_SQL || G_WHERE_SQL ||
                        ' AND   WDD.RELEASED_STATUS IN (''R'',''B'',''X'') ' ||
                        ' AND   nvl(WDD.replenishment_status,''C'') = ''C''' ||
                        ' AND   WDD.DATE_SCHEDULED IS NOT NULL' ||
                        ' AND   WTS.STOP_ID(+) = WLG.PICK_UP_STOP_ID ' ||
                        ' AND   WLG.DELIVERY_ID(+) = WDE.DELIVERY_ID ' ||
                        ' AND   WDE.DELIVERY_ID(+) = WDA.DELIVERY_ID ' ||
                        ' AND   WDA.DELIVERY_DETAIL_ID = WDD.DELIVERY_DETAIL_ID' ||
                        ' AND   WTS.STOP_ID = WDO.TRIP_STOP(+) ' || --Added for Dock Assignments
                        ' AND   NVL(WDD.REQUESTED_QUANTITY,0) > 0' ||
                        ' AND   WDD.SOURCE_CODE = ''OE''' ||
                        ' AND  WDD.DELIVERY_DETAIL_ID NOT IN' ||
                        '(SELECT distinct wwl.delivery_detail_id  FROM WMS_WP_WAVE_LINES wwl ,wms_wp_wave_headers_vl wwh
                         where wwl.wave_header_id=wwh.wave_header_id and (nvl(wwh.wave_firmed_flag,''N'') = ''Y''  and wwh.wave_status <> ''Cancelled''  and nvl(wwl.remove_from_wave_flag,''N'') <>''Y''))';
    -- WHERE WAVE_HEADER_ID = :X_WAVE_HEADER_ID)';

    -- The above condition is added to check if the lines are present in Wave Lines table
    -- Following conditions use bind variables
    -- The columns which have indexes are included in the SQL statement
    -- conditionally.  This is done so that the index will be used

    if nvl(g_Add_lines, 'N') = 'Y' then
      g_Unreleased_SQL := g_Unreleased_SQL ||
                          ' AND  WDD.DELIVERY_DETAIL_ID NOT IN' ||
                          '(select distinct delivery_detail_id from wms_wp_Wave_lines where wave_header_id=:X_wave_header_id)';

    end if;

    g_cond_SQL := '';

    IF (g_customer_class_id is not null) THEN
      g_cond_SQL := g_Cond_SQL || ' AND WDD.CUSTOMER_ID IN  (select cust_acct.cust_account_id
from hz_parties PARTY
, hz_cust_accounts CUST_ACCT
where party.party_id = cust_acct.party_id
and cust_acct.status = ''A''' ||
                    ' AND cust_Acct.customer_class_code = :X_CUSTOMER_CLASS_ID) ' || '';
      print_debug('g_cond_sql  after customer class code :' || g_cond_sql,
                  l_debug);
    END IF;

    -- For Item Category
    IF (g_item_category_id <> 0) THEN
      g_cond_SQL := g_Cond_SQL || ' and wdd.inventory_item_id in (select distinct inventory_item_id
from mtl_item_categories mic
where mic.category_id =:X_category_id) ' || '';
    END IF;

    -- Ajith Changed this part
    IF (g_order_header_id <> 0) THEN
      g_Cond_SQL := g_Cond_SQL ||
                    ' AND WDD.SOURCE_HEADER_ID = :X_header_id ' || '';
      /*
          ELSIF (g_order_header_id <> 0 AND g_order_line_id <> 0) THEN
      g_Cond_SQL := g_Cond_SQL ||
      ' AND WDD.SOURCE_HEADER_ID + 0 = :X_header_id' || '';*/
    END IF;
    /*  IF (g_order_line_id <> 0) THEN
        g_Cond_SQL := g_Cond_SQL ||
    ' AND WDD.SOURCE_LINE_ID = :X_order_line_id' || '';
    END IF;*/
    IF (g_customer_id <> 0) THEN
      g_Cond_SQL := g_Cond_SQL || ' AND WDD.CUSTOMER_ID = :X_customer_id' || '';
    END IF;
    IF (g_carrier_id is not null) THEN
      g_Cond_SQL := g_Cond_SQL ||
                    ' AND (WDD.CARRIER_ID = :X_carrier_id OR :X_carrier_id = 0)' || '';
    END IF;
    IF (g_ship_from_loc_id <> -1) THEN
      g_Cond_SQL := g_Cond_SQL ||
                    ' AND WDD.SHIP_FROM_LOCATION_ID = :X_ship_from_loc_id' || '';
    END IF;
    IF (g_ship_to_loc_id <> 0) THEN
      g_Cond_SQL := g_Cond_SQL ||
                    ' AND WDD.SHIP_TO_LOCATION_ID = :X_ship_to_loc_id' || '';
    END IF;
    g_Cond_SQL := g_Cond_SQL ||
                  ' AND (WDD.SOURCE_HEADER_TYPE_ID = :X_order_type_id OR :X_order_type_id = 0) ' || '' ||
                 --    ' AND (WDD.SHIP_SET_ID = :X_ship_set_id OR :X_ship_set_id = 0) ' || '' ||
                  ' AND (WDD.TASK_ID = :X_task_id OR :X_task_id = 0) ' || '' ||
                  ' AND (WDD.PROJECT_ID = :X_project_id OR :X_project_id = 0) ' || '' ||
                  ' AND (WDD.ORGANIZATION_ID = :X_org_id' || '' ||
                  '      OR  :X_org_id IS NULL) ' || '' ||
                  ' AND (WDD.SHIP_METHOD_CODE =  :X_ship_method_code ' || '' ||
                  '      OR  :X_ship_method_code IS NULL) ' || '' ||
                  ' AND (WDD.SHIPMENT_PRIORITY_CODE = :X_shipment_priority ' || '' ||
                  '     OR :X_shipment_priority IS NULL) ' || '' ||
                  ' AND (WDD.DATE_REQUESTED >=' ||
                  '         :X_from_request_date OR :X_from_request_date IS NULL) ' || '' ||
                  ' AND (WDD.DATE_REQUESTED <=' ||
                  '   :X_to_request_date OR :X_to_request_date IS NULL) ' || '' ||
                  ' AND (WDD.DATE_SCHEDULED >= :X_from_sched_ship_date OR :X_from_sched_ship_date IS NULL) ' || '' ||
                  ' AND (WDD.DATE_SCHEDULED <=' ||
                  '   :X_to_sched_ship_date OR :X_to_sched_ship_date IS NULL) ' || '' ||
                  ' AND (WDD.INVENTORY_ITEM_ID  = :X_inventory_item_id ' ||
                  '   OR :X_inventory_item_id = 0) ' || '' ||
                  ' AND (NVL(WDE.DELIVERY_ID, -99) = -99 ' ||
                  '   OR :X_include_planned_lines <> ''N'' ' ||
                  '   OR (:X_trip_id <> 0 and :X_include_planned_lines <> ''N'') OR (:X_delivery_id <> 0 and :X_include_planned_lines <> ''N'') OR (WDE.DELIVERY_ID IS NOT NULL and :X_include_planned_lines <> ''N''))';
    /*
                      if g_delivery_id <> -1 then
              g_Cond_SQL := g_Cond_SQL || ' AND (NVL(WDE.DELIVERY_ID, -99) = -99 ' ||
                      '   OR :X_include_planned_lines <> ''N'' ' ||
                      '         OR :X_trip_id <> 0 OR :X_delivery_id <> 0)';
                      elsif g_delivery_id = -1then
                       g_Cond_SQL := g_Cond_SQL || ' AND (NVL(WDE.DELIVERY_ID, -99) = -99 ' ||
                      '   OR :X_include_planned_lines <> ''N'' ' ||
                      '         OR :X_trip_id <> 0 OR :X_delivery_id = -1)';
                      end if;

    */
    -- Handling trips and deliveries
    IF (g_delivery_id <> 0) and (g_delivery_id <> -1) THEN
      g_Cond_SQL := g_Cond_SQL || ' AND WDE.DELIVERY_ID = :X_delivery_id' || '';
    END IF;
    IF (g_trip_id <> 0) THEN
      g_Cond_SQL := g_Cond_SQL || ' AND WTS.TRIP_ID = :X_trip_id ' || '' ||
                    ' AND ( WTS.STOP_ID = :X_trip_stop_id' ||
                    '       OR  :X_trip_stop_id = 0) ' || '';

    end if;

    if (g_from_dock_appoint_date is not null) then
      g_Cond_SQL := g_Cond_SQL ||
                    ' AND (WDO.START_TIME >= sysdate or :X_from_dock_appoint_date IS NULL )' ||
                    ' AND (WDO.END_TIME <= :X_to_dock_appoint_date OR :X_to_dock_appoint_date IS NULL)';
    end if;

    -- Determine the order by clause
    g_orderby_SQL := 'ORDER BY ';

 FOR i IN 1 .. g_total_pick_criteria LOOP
      IF (g_ordered_psr(i).attribute = C_INVOICE_VALUE) THEN

        g_orderby_SQL := g_orderby_SQL ||
                         ' WSH_PICK_CUSTOM.OUTSTANDING_ORDER_VALUE(WDD.SOURCE_HEADER_ID) ' ||
                         g_ordered_psr(i)
                        .sort_order || ' , SOURCE_HEADER_ID ASC ,';

      ELSIF (g_ordered_psr(i).attribute = C_ORDER_NUMBER) THEN
        g_orderby_SQL := g_orderby_SQL || ' SOURCE_HEADER_ID ' ||
                         g_ordered_psr(i).sort_order || ', ';
      ELSIF (g_ordered_psr(i).attribute = C_SCHEDULE_DATE) THEN
        g_orderby_SQL := g_orderby_SQL || ' DATE_SCHEDULED ' ||
                         g_ordered_psr(i).sort_order || ', ';
      ELSIF (g_ordered_psr(i).attribute = C_TRIP_STOP_DATE) THEN
        g_orderby_SQL := g_orderby_SQL || 'PLANNED_DEPARTURE_DATE ' ||
                         g_ordered_psr(i).sort_order || ', ';
      ELSIF (g_ordered_psr(i).attribute = C_SHIPMENT_PRIORITY) THEN
        g_orderby_SQL := g_orderby_SQL || 'SHIPMENT_PRIORITY_CODE ' ||
                         g_ordered_psr(i).sort_order || ', ';
      END IF;
    END LOOP;

if g_enforce_ship_set_and_smc = 'Y' then

		           g_orderby_SQL := g_orderby_SQL || ' NVL(WDD.SHIP_SET_ID,999999999), ';

	        -- Consider SMC only if SS is not specified
	   g_orderby_SQL := g_orderby_SQL || ' DECODE(NVL(WDD.SHIP_SET_ID,-999999999), -999999999, WDD.SHIP_MODEL_COMPLETE_FLAG,NULL) DESC, ';

	        -- This is necessary to push the non-transactable lines ahead in SS/SMC
		g_orderby_SQL := g_orderby_SQL ||' RELEASED_STATUS DESC, ';

	        -- Consider SMC only if SS is not specified
		g_orderby_SQL := g_orderby_SQL || ' DECODE(NVL(WDD.SHIP_SET_ID,-999999999), -999999999,WDD.TOP_MODEL_LINE_ID,NULL), ';
			g_orderby_SQL := g_orderby_SQL || ' WDD.INVENTORY_ITEM_ID, ';


end if;

    g_orderby_SQL := g_orderby_SQL || ' WDD.SOURCE_LINE_ID, ' ||
                     ' SHIP_FROM_LOCATION_ID, ' || ' SHIP_METHOD_CODE';
    -- Parse cursor
    v_CursorID := DBMS_SQL.Open_Cursor;
    print_debug('Parse cursor', l_debug);

    print_debug('Printing Dynamic SQL', l_debug);
    print_debug('g_unreleased_sql :' || g_unreleased_sql, l_debug);

    print_debug('g_where_sql :' || g_where_sql, l_debug);
    print_debug('g_cond_sql  :' || g_cond_sql, l_debug);
    print_debug('g_orderby_sql  :' || g_orderby_sql, l_debug);

    DBMS_SQL.Parse(v_CursorID,
                   '( ' || g_Unreleased_SQL || g_Cond_SQL || ' ) ' ||
                   g_orderby_SQL,
                   DBMS_SQL.v7);

    print_debug('Column definition for cursor', l_debug);
    DBMS_SQL.Define_Column(v_CursorID, 1, v_source_code, 30);
    DBMS_SQL.Define_Column(v_CursorID, 2, v_header_id);
    DBMS_SQL.Define_Column(v_CursorID, 3, v_line_id);
    DBMS_SQL.Define_Column(v_CursorID, 4, v_header_number, 150);
    DBMS_SQL.Define_Column(v_CursorID, 5, v_line_number, 150);
    DBMS_SQL.Define_Column(v_CursorID, 6, v_header_type_name, 240);
    DBMS_SQL.Define_Column(v_CursorID, 7, v_header_type_id);
    DBMS_SQL.Define_Column(v_CursorID, 8, v_document_type_id);
    DBMS_SQL.Define_Column(v_CursorID, 9, v_delivery_detail_id);
    DBMS_SQL.Define_Column(v_CursorID, 10, v_released_status, 1);
    DBMS_SQL.Define_Column(v_CursorID, 11, v_org_id);
    DBMS_SQL.Define_Column(v_CursorID, 12, v_inventory_item_id);
    DBMS_SQL.Define_Column(v_CursorID, 13, v_requested_quantity);
    DBMS_SQL.Define_Column(v_CursorID, 14, v_requested_quantity_uom, 3);
    DBMS_SQL.Define_Column(v_CursorID, 15, v_move_order_line_id);
    DBMS_SQL.Define_Column(v_CursorID, 16, v_ship_model_complete_flag, 1);
    DBMS_SQL.Define_Column(v_CursorID, 17, v_top_model_id);
    DBMS_SQL.Define_Column(v_CursorID, 18, v_ship_from_location_id);
    DBMS_SQL.Define_Column(v_CursorID, 19, v_ship_to_location_id);
    DBMS_SQL.Define_Column(v_CursorID, 20, v_ship_method_code, 30);
    DBMS_SQL.Define_Column(v_CursorID, 21, v_shipment_priority_code, 30);
    DBMS_SQL.Define_Column(v_CursorID, 22, v_ship_set_id);
    DBMS_SQL.Define_Column(v_CursorID, 23, v_date_scheduled);
    DBMS_SQL.Define_Column(v_CursorID, 24, v_planned_departure_date);
    DBMS_SQL.Define_Column(v_CursorID, 25, v_delivery_id);
    DBMS_SQL.Define_Column(v_CursorID, 26, v_customer_id);
    DBMS_SQL.Define_Column(v_CursorID, 27, v_carrier_id);
    DBMS_SQL.Define_Column(v_CursorID, 28, v_preferred_grade);
    DBMS_SQL.Define_Column(v_CursorID, 29, v_requested_quantity2);
    DBMS_SQL.Define_Column(v_CursorID, 30, v_requested_quantity_uom2, 3);
    DBMS_SQL.Define_Column(v_CursorID, 31, v_project_id);
    DBMS_SQL.Define_Column(v_CursorID, 32, v_task_id);
    DBMS_SQL.Define_Column(v_CursorID, 33, v_subinventory, 30);
    DBMS_SQL.Define_Column(v_CursorID, 34, v_weight_uom_code, 5);
    DBMS_SQL.Define_Column(v_CursorID, 35, v_net_weight);
    DBMS_SQL.Define_Column(v_CursorID, 36, v_volume_uom_code, 5);
    DBMS_SQL.Define_Column(v_CursorID, 37, v_volume);
    --  Bind release criteria values

    print_debug('Bind cursor', L_debug);

    /* IF (g_del_line_id <> 0 AND g_del_lines_list IS NULL) THEN
        -- DBMS_SQL.BIND_VARIABLE(v_CursorID,':X_del_detail_id',g_del_line_id);
    END IF;*/
    IF (g_customer_class_id is not null) THEN
      DBMS_SQL.BIND_VARIABLE(v_CursorID,
                             ':X_CUSTOMER_CLASS_ID',
                             g_customer_class_id);
    END IF;

    IF (g_order_header_id <> 0) THEN
      DBMS_SQL.BIND_VARIABLE(v_CursorID, ':X_header_id', g_order_header_id);
    END IF;
    /*   IF (g_order_line_id <> 0) THEN
    DBMS_SQL.BIND_VARIABLE(v_CursorID,':X_order_line_id',g_order_line_id);
      END IF;*/
    IF (g_customer_id <> 0) THEN
      DBMS_SQL.BIND_VARIABLE(v_CursorID, ':X_customer_id', g_customer_id);
    END IF;
    IF (g_item_category_id <> 0) THEN
      DBMS_SQL.BIND_VARIABLE(v_CursorID,
                             ':X_category_id',
                             g_item_category_id);
    END IF;
    IF (g_ship_from_loc_id <> -1) THEN
      DBMS_SQL.BIND_VARIABLE(v_CursorID,
                             ':X_ship_from_loc_id',
                             g_ship_from_loc_id);
    END IF;
    IF (g_ship_to_loc_id <> 0) THEN
      DBMS_SQL.BIND_VARIABLE(v_CursorID,
                             ':X_ship_to_loc_id',
                             g_ship_to_loc_id);
    END IF;
    --  DBMS_SQL.BIND_VARIABLE(v_CursorID,':X_backorders_flag',g_backorders_flag);
    DBMS_SQL.BIND_VARIABLE(v_CursorID, ':X_order_type_id', g_order_type_id);
    --   DBMS_SQL.BIND_VARIABLE(v_CursorID, ':X_ship_set_id', g_ship_set_number);
    DBMS_SQL.BIND_VARIABLE(v_CursorID, ':X_task_id', g_task_id);
    DBMS_SQL.BIND_VARIABLE(v_CursorID, ':X_project_id', g_project_id);
    DBMS_SQL.BIND_VARIABLE(v_CursorID, ':X_org_id', p_organization_id);
    DBMS_SQL.BIND_VARIABLE(v_CursorID,
                           ':X_ship_method_code',
                           g_ship_method_code);
    DBMS_SQL.BIND_VARIABLE(v_CursorID,
                           ':X_shipment_priority',
                           g_shipment_priority);
    DBMS_SQL.BIND_VARIABLE(v_CursorID,
                           ':X_from_request_date',
                           g_from_request_date);
    DBMS_SQL.BIND_VARIABLE(v_CursorID,
                           ':X_to_request_date',
                           g_to_request_date);
    DBMS_SQL.BIND_VARIABLE(v_CursorID,
                           ':X_from_sched_ship_date',
                           g_from_sched_ship_date);
    DBMS_SQL.BIND_VARIABLE(v_CursorID,
                           ':X_to_sched_ship_date',
                           g_to_sched_ship_date);
    DBMS_SQL.BIND_VARIABLE(v_CursorID,
                           ':X_inventory_item_id',
                           g_inventory_item_id);
    DBMS_SQL.BIND_VARIABLE(v_CursorID, ':X_trip_id', g_trip_id);
    DBMS_SQL.BIND_VARIABLE(v_CursorID, ':X_delivery_id', g_delivery_id);
    DBMS_SQL.BIND_VARIABLE(v_CursorID,
                           ':X_include_planned_lines',
                           g_include_planned_lines);
    IF (g_trip_id <> 0) THEN
      DBMS_SQL.BIND_VARIABLE(v_CursorID, ':X_trip_stop_id', g_trip_stop_id);
    end if;

    if (g_from_dock_appoint_date is not null) then
      DBMS_SQL.BIND_VARIABLE(v_CursorID,
                             ':X_to_dock_appoint_date',
                             g_to_dock_appoint_date);
      DBMS_SQL.BIND_VARIABLE(v_CursorID,
                             ':X_from_dock_appoint_date',
                             g_from_dock_appoint_date);
    END IF;

    if nvl(g_add_lines, 'N') = 'Y' then
      DBMS_SQL.BIND_VARIABLE(v_CursorID,
                             ':X_WAVE_HEADER_ID',
                             V_WAVE_HEADER_ID);
    end if;
    DBMS_SQL.BIND_VARIABLE(v_CursorID, ':X_CARRIER_ID', g_CARRIER_ID);
    -- Execute the cursor
    print_debug('Executing cursor', l_debug);
    v_ignore := DBMS_SQL.Execute(v_CursorID);

    x_api_status := fnd_api.g_ret_sts_success;
  EXCEPTION
    WHEN OTHERS THEN
      print_debug('Error : ' || SQLCODE || ' : ' || SQLERRM, l_debug);
      x_api_status := FND_API.G_RET_STS_ERROR;
  END Init_Cursor;

  --
  -- Name
  --   PROCEDURE Get_Lines
  --
  -- Purpose
  --   This routine returns information about the lines that
  --   are eligible for release. It fetches rows from the cursor
  --   for unreleased and backordered lines, and inserts the each
  --   row in the release_table based on the release sequence rule.
  --   It controls the number of lines to be fetched. The default
  --   value is set at 50. It also indicates whether there are any
  --   more lines to be retrieved.
  --
  -- Output Parameters
  --    x_done_flag   - whether all lines have been fetched
  --    x_api_status  - FND_API.G_RET_STS_SUCCESS or
  --                    FND_API.G_RET_STS_ERROR or
  --                    FND_API.G_RET_STS_ERROR
  --
  PROCEDURE Get_Lines(x_done_flag  OUT NOCOPY VARCHAR2,
                      x_api_status OUT NOCOPY VARCHAR2) IS
    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    print_debug('In Get_Lines', l_debug);
    -- handle uninitialized package errors here
    /*
    IF g_initialized = FALSE THEN
      print_debug('The package must be initialized before use',l_debug);
      x_api_status := FND_API.G_RET_STS_ERROR;
      RETURN;
      END IF;
      */
    g_rel_current_line := 1;
    -- Clear the table
    --Ajith Need to modify this.
    IF release_table.count <> 0 THEN
      release_table.delete;
      l_source_code_tb.delete;
      l_source_header_id_tb.delete;
      l_source_line_id_tb.delete;
      l_source_header_number_tb.delete;
      l_source_line_number_tb.delete;
      l_source_header_type_id_tb.delete;
      l_source_document_type_id_tb.delete;
      l_delivery_Detail_id_tb.delete;
      l_organization_id_tb.delete;
      l_item_id_tb.delete;
      l_requested_quantity_tb.delete;
      l_requested_quantity_uom_tb.delete;
      l_requested_quantity2_tb.delete;
      l_requested_quantity_uom2_tb.delete;
      l_demand_header_id_tb.delete;
      l_net_weight_tb.delete;
      l_volume_tb.delete;
      l_net_value.delete;

    END IF;
    -- Set flag to indicate that fetching is not completed for
    -- an organization
    x_done_flag := FND_API.G_FALSE;
    -- If called after the first time, place the last row fetched in previous
    -- call as the first row, since it was not returned in the previous call
    IF first_line.source_header_id <> -1 THEN
      release_table(g_rel_current_line) := first_line;
      g_rel_current_line := g_rel_current_line + 1;
    END IF;
    print_debug('Fetching Customer specified lines', l_debug);
    MAX_LINES := 1000;
    print_debug('MAX_LINES is ' || to_char(MAX_LINES), l_debug);
    -- Loop and fetch up to MAX_LINES
    LOOP
      IF g_rel_current_line < MAX_LINES THEN
        IF DBMS_SQL.Fetch_Rows(v_cursorID) = 0 THEN
          print_debug('Fetched all lines for organization', l_debug);
          x_done_flag := FND_API.G_TRUE;
          DBMS_SQL.Close_Cursor(v_cursorID);
          -- Reinitialize the first line marker since we have
          -- fetched all rows
          first_line.source_header_id := -1;
          print_debug('After Fetching all ROWs ', l_debug);

          EXIT;
        ELSE
          print_debug('--------------------', l_debug);
          print_debug('Current line is ' || to_char(g_rel_current_line),
                      l_debug);
          -- Save fetched record into release table
          Insert_RL_Row(g_return_status);

          IF (g_return_status = FND_API.G_RET_STS_ERROR) OR
             (g_return_status = FND_API.G_RET_STS_ERROR) THEN
            print_debug('Error occurred in Insert_RL_Row', l_debug);
            x_api_status := g_return_status;
            RETURN;
          END IF;
          print_debug('Row Description:', l_debug);
          print_debug('order_header_id = ' ||
                      release_table(g_rel_current_line)
                      .source_header_id || ' order_line_id = ' ||
                      release_table(g_rel_current_line)
                      .source_line_id || ' delivery_detail_id = ' ||
                      release_table(g_rel_current_line).delivery_detail_id,
                      l_debug);
          g_rel_current_line := g_rel_current_line + 1;
        END IF;
      ELSE
        first_line := release_table(g_rel_current_line - 1);
        release_table.delete(g_rel_current_line - 1);
        g_rel_current_line := g_rel_current_line - 1;
        x_done_flag        := FND_API.G_FALSE;
        EXIT;
      END IF;
    END LOOP;
    x_api_status := fnd_api.g_ret_sts_success;
  EXCEPTION
    WHEN OTHERS THEN

      print_debug('Unexpected error occurred in Get_Lines', l_debug);
      print_debug('Error : ' || SQLCODE || ' : ' || SQLERRM, l_debug);

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg('WSH_PR_CRITERIA', 'Get_Lines');
      END IF;
      IF DBMS_SQL.Is_Open(v_cursorID) THEN
        DBMS_SQL.Close_Cursor(v_cursorID);
      END IF;
      x_done_flag  := FND_API.G_RET_STS_ERROR;
      x_api_status := FND_API.G_RET_STS_ERROR;
  END Get_Lines;

  PROCEDURE Insert_RL_Row(x_api_status OUT NOCOPY VARCHAR2) IS
    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    print_debug('Map output columns', l_debug);
    DBMS_SQL.Column_Value(v_CursorID, 1, v_source_code);
    DBMS_SQL.Column_Value(v_CursorID, 2, v_header_id);
    DBMS_SQL.Column_Value(v_CursorID, 3, v_line_id);
    DBMS_SQL.Column_Value(v_CursorID, 4, v_header_number);
    DBMS_SQL.Column_Value(v_CursorID, 5, v_line_number);
    DBMS_SQL.Column_Value(v_CursorID, 6, v_header_type_name);
    DBMS_SQL.Column_Value(v_CursorID, 7, v_header_type_id);
    DBMS_SQL.Column_Value(v_CursorID, 8, v_document_type_id);
    DBMS_SQL.Column_Value(v_CursorID, 9, v_delivery_detail_id);
    DBMS_SQL.Column_Value(v_CursorID, 10, v_released_status);
    DBMS_SQL.Column_Value(v_CursorID, 11, v_org_id);
    DBMS_SQL.Column_Value(v_CursorID, 12, v_inventory_item_id);
    DBMS_SQL.Column_Value(v_CursorID, 13, v_requested_quantity);
    DBMS_SQL.Column_Value(v_CursorID, 14, v_requested_quantity_uom);
    DBMS_SQL.Column_Value(v_CursorID, 15, v_move_order_line_id);
    DBMS_SQL.Column_Value(v_CursorID, 16, v_ship_model_complete_flag);
    DBMS_SQL.Column_Value(v_CursorID, 17, v_top_model_id);
    DBMS_SQL.Column_Value(v_CursorID, 18, v_ship_from_location_id);
    DBMS_SQL.Column_Value(v_CursorID, 19, v_ship_to_location_id);
    DBMS_SQL.Column_Value(v_CursorID, 20, v_ship_method_code);
    DBMS_SQL.Column_Value(v_CursorID, 21, v_shipment_priority_code);
    DBMS_SQL.Column_Value(v_CursorID, 22, v_ship_set_id);
    DBMS_SQL.Column_Value(v_CursorID, 23, v_date_scheduled);
    DBMS_SQL.Column_Value(v_CursorID, 24, v_planned_departure_date);
    DBMS_SQL.Column_Value(v_CursorID, 25, v_delivery_id);
    DBMS_SQL.Column_Value(v_CursorID, 26, v_customer_id);
    DBMS_SQL.Column_Value(v_CursorID, 27, v_carrier_id);
    DBMS_SQL.Column_Value(v_CursorID, 28, v_preferred_grade);
    DBMS_SQL.Column_Value(v_CursorID, 29, v_requested_quantity2);
    DBMS_SQL.Column_Value(v_CursorID, 30, v_requested_quantity_uom2);
    DBMS_SQL.Column_Value(v_CursorID, 31, v_project_id);
    DBMS_SQL.Column_Value(v_CursorID, 32, v_task_id);
    DBMS_SQL.Column_Value(v_CursorID, 33, v_subinventory);
    DBMS_SQL.Column_Value(v_CursorID, 34, v_weight_uom_code);
    DBMS_SQL.Column_Value(v_CursorID, 35, v_net_weight);
    DBMS_SQL.Column_Value(v_CursorID, 36, v_volume_uom_code);

    DBMS_SQL.Column_Value(v_CursorID, 37, v_volume);
    print_debug('Insert into table', l_debug);
    release_table(g_rel_current_line).source_line_id := v_line_id;
    release_table(g_rel_current_line).source_header_id := v_header_id;
    release_table(g_rel_current_line).organization_id := v_org_id;
    release_table(g_rel_current_line).inventory_item_id := v_inventory_item_id;
    release_table(g_rel_current_line).move_order_line_id := v_move_order_line_id;
    release_table(g_rel_current_line).source_code := v_source_code;
    release_table(g_rel_current_line).SOURCE_HEADER_NUMBER := v_HEADER_NUMBER;
    release_table(g_rel_current_line).SOURCE_LINE_NUMBER := v_LINE_NUMBER;
    release_table(g_rel_current_line).SOURCE_HEADER_TYPE_NAME := v_HEADER_TYPE_NAME;
    release_table(g_rel_current_line).SOURCE_HEADER_TYPE_ID := v_HEADER_TYPE_ID;
    release_table(g_rel_current_line).SOURCE_DOCUMENT_TYPE_ID := v_DOCUMENT_TYPE_ID;
    release_table(g_rel_current_line).delivery_detail_id := v_delivery_detail_id;
    release_table(g_rel_current_line).requested_quantity := v_requested_quantity;
    release_table(g_rel_current_line).requested_quantity_uom := v_requested_quantity_uom;
    release_table(g_rel_current_line).SHIP_MODEL_COMPLETE_FLAG := v_SHIP_MODEL_COMPLETE_FLAG;
    release_table(g_rel_current_line).top_model_line_id := v_top_model_id;
    release_table(g_rel_current_line).ship_from_location_id := v_ship_from_location_id;
    release_table(g_rel_current_line).ship_to_location_id := v_ship_to_location_id;
    release_table(g_rel_current_line).ship_method_code := v_ship_method_code;
    release_table(g_rel_current_line).shipment_priority_code := v_shipment_priority_code;
    release_table(g_rel_current_line).ship_set_id := v_ship_set_id;
    release_table(g_rel_current_line).date_scheduled := v_date_scheduled;
    release_table(g_rel_current_line).planned_departure_date := v_planned_departure_date;
    release_table(g_rel_current_line).delivery_id := v_delivery_id;
    release_table(g_rel_current_line).customer_id := v_customer_id;
    release_table(g_rel_current_line).carrier_id := v_carrier_id;
    release_table(g_rel_current_line).preferred_grade := v_preferred_grade;
    release_table(g_rel_current_line).requested_quantity := v_requested_quantity;
    release_table(g_rel_current_line).requested_quantity_uom := v_requested_quantity_uom;
    release_table(g_rel_current_line).project_id := v_project_id;
    release_table(g_rel_current_line).task_id := v_task_id;
    release_table(g_rel_current_line).FROM_SUBINVENTORY_CODE := v_subinventory;
    release_table(g_rel_current_line).net_weight_uom_code := v_weight_uom_code;
    release_table(g_rel_current_line).net_weight := v_net_weight;
    release_table(g_rel_current_line).volume_uom_code := v_volume_uom_code;
    release_table(g_rel_current_line).volume := v_volume;

    -- For Bulk Processing

    l_source_code_tb(g_rel_current_line) := v_source_code;

    l_source_header_id_tb(g_rel_current_line) := v_header_id;
    l_source_line_id_tb(g_rel_current_line) := v_line_id;
    l_source_header_number_tb(g_rel_current_line) := v_HEADER_NUMBER;
    l_source_line_number_tb(g_rel_current_line) := v_LINE_NUMBER;
    l_source_header_type_id_tb(g_rel_current_line) := v_HEADER_TYPE_ID;
    l_source_document_type_id_tb(g_rel_current_line) := v_DOCUMENT_TYPE_ID;
    l_delivery_Detail_id_tb(g_rel_current_line) := v_delivery_detail_id;
    l_delivery_id_tb(g_rel_current_line) := v_delivery_id;
    l_organization_id_tb(g_rel_current_line) := v_org_id;
    l_item_id_tb(g_rel_current_line) := v_inventory_item_id;
    l_requested_quantity_tb(g_rel_current_line) := v_requested_quantity;
    l_requested_quantity_uom_tb(g_rel_current_line) := v_requested_quantity_uom;
    l_requested_quantity2_tb(g_rel_current_line) := v_requested_quantity2;
    l_requested_quantity_uom2_tb(g_rel_current_line) := v_requested_quantity_uom2;
    -- l_demand_header_id_tb(g_rel_current_line);
    l_net_weight_tb(g_rel_current_line) := v_net_weight;
    l_volume_tb(g_rel_current_line) := v_volume;
    --  l_net_value(g_rel_current_line);

    x_api_status := fnd_api.g_ret_sts_success;
  EXCEPTION
    WHEN OTHERS THEN
      print_debug('Unexpected error in Insert_RL_Row', l_debug);
      print_debug('Error : ' || SQLCODE || ' : ' || SQLERRM, l_debug);
      x_api_status := FND_API.G_RET_STS_ERROR;
  END Insert_RL_Row;

  --Procedure to Calculate the Planned Fill Rate
  procedure get_line_fill_rate(x_return_status  OUT NOCOPY varchar2,
                               p_wave_header_id in number) is
    cursor c_lines(p_item_id in number, p_org_id in number) is
      select wwl.wave_header_id,
             wwl.wave_line_id,
             wwl.source_header_number,
             wwl.source_line_id,
             wwl.delivery_detail_id,
             wwl.organization_id,
             wwl.inventory_item_id,
             wwl.requested_quantity
        from wms_wp_wave_lines wwl
       where wwl.wave_header_id = p_wave_header_id
         and wwl.inventory_item_id = p_item_id
         and wwl.organization_id = p_org_id
         and nvl(wwl.remove_from_wave_flag, 'N') = 'N'
       ORDER BY wave_header_id, inventory_item_id, wave_line_id;

    cursor c_item is
      SELECT DISTINCT inventory_item_id, organization_id
        FROM wms_wp_wave_lines
       WHERE wave_header_id = p_wave_header_id;

    TYPE CONSOL_LINES_REC IS RECORD(
      wave_header_id    NUMBER,
      wave_line_id      number,
      planned_fill_rate number);

    TYPE CONSOL_LINES_TBL IS TABLE OF CONSOL_LINES_REC INDEX BY BINARY_INTEGER;
    L_ORG_ID           NUMBER;
    L_ITEM_ID          NUMBER;
    L_DEMAND_QTY       NUMBER;
    l_is_revision_ctrl BOOLEAN := FALSE;
    l_is_lot_ctrl      BOOLEAN := FALSE;
    l_is_serial_ctrl   BOOLEAN := FALSE;
    l_qoh              NUMBER;
    l_rqoh             NUMBER;
    l_qr               NUMBER;
    l_qs               NUMBER;
    l_atr              NUMBER;
    l_att              NUMBER;
    l_reserved_qty     number;

    X_CONSOL_LINES_TBL  CONSOL_LINES_TBL;
    l_debug             NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'),
                                      0);
    m                   NUMBER := 0;
    l_msg_count         number;
    l_msg_data          varchar2(100);
    l_pick_subinventory varchar2(100);
    l_other_wdd_qty     number := 0;
    l_temp_value        number;

  begin

    -- Checking if Pick Subinventory is mentioned in Planning Criteria
    begin
      select picking_subinventory
        into l_pick_subinventory
        from wms_wp_planning_criteria_vl wwp, wms_wp_wave_headers_vl wwh
       where wave_header_id = p_wave_header_id
         and wwh.planning_Criteria_id = wwp.planning_Criteria_id;
      print_debug('pick_subinventory :' || l_pick_subinventory, l_debug);
    exception
      when no_data_found then
        null;
    end;

    --Consolidating every item and org combination and then traversing through all the lines in the wave

    for c_item_rec in c_item loop
      l_item_id := c_item_rec.inventory_item_id;
      l_org_id  := c_item_rec.organization_id;
      print_debug('l_item_id :' || l_item_id, l_debug);
      print_debug('l_org_id :' || l_org_id, l_debug);

      --Find out the total atr for the item
      IF inv_cache.set_item_rec(L_ORG_ID, L_item_id) THEN

     /*   IF inv_cache.item_rec.revision_qty_control_code = 2 THEN
          l_is_revision_ctrl := TRUE;
        ELSE
          l_is_revision_ctrl := FALSE;
        END IF;

        IF inv_cache.item_rec.lot_control_code = 2 THEN
          l_is_lot_ctrl := TRUE;
        ELSE
          l_is_lot_ctrl := FALSE;
        END IF; */

        IF inv_cache.item_rec.serial_number_control_code NOT IN (1, 6) THEN
          l_is_serial_ctrl := FALSE;
        ELSE
          l_is_serial_ctrl := TRUE;
        END IF;

      ELSE

        print_debug('Error: Item detail not found', l_debug);

        RAISE no_data_found;
      END IF;

      inv_quantity_tree_pub.query_quantities(p_api_version_number      => 1.0,
                                             p_init_msg_lst            => fnd_api.g_false,
                                             x_return_status           => x_return_status,
                                             x_msg_count               => l_msg_count,
                                             x_msg_data                => l_msg_data,
                                             p_organization_id         => l_org_id,
                                             p_inventory_item_id       => l_item_id,
                                             p_tree_mode               => inv_quantity_tree_pub.g_transaction_mode,
                                             p_is_revision_control     => l_is_revision_ctrl,
                                             p_is_lot_control          => l_is_lot_ctrl,
                                             p_is_serial_control       => l_is_serial_ctrl,
                                             p_demand_source_type_id   => -9999 --should not be null
                                            ,
                                             p_demand_source_header_id => -9999 --should not be null
                                            ,
                                             p_demand_source_line_id   => -9999,
                                             p_revision                => NULL,
                                             p_lot_number              => NULL,
                                             p_subinventory_code       => l_pick_subinventory,
                                             p_locator_id              => NULL,
                                             x_qoh                     => l_qoh,
                                             x_rqoh                    => l_rqoh,
                                             x_qr                      => l_qr,
                                             x_qs                      => l_qs,
                                             x_att                     => l_att,
                                             x_atr                     => l_atr);

      print_debug('x_qoh :' || l_qoh, l_debug);
      print_debug('x_rqoh :' || l_rqoh, l_debug);
      print_debug('x_qr :' || l_qr, l_debug);
      print_debug('x_qs :' || l_qs, l_debug);
      print_debug('x_att :' || l_att, l_debug);
      print_debug('x_atr :' || l_atr, l_debug);

      FOR c_rec IN c_lines(l_item_id, l_org_id) LOOP

        EXIT WHEN c_lines%NOTFOUND;
        begin

          -- Since Qty Tree would have also subttracted qty for current demand
          -- lines under consideration for which there is existing
          -- reservation as well, I need to add them back
          -- to see real picture of the atr for demand line under consideration

          ------------------

          SELECT nvl(sum(reservation_quantity), 0)
            INTO l_reserved_qty
            FROM mtl_Reservations
           WHERE demand_source_line_id = c_rec.SOURCE_LINE_ID
             and organization_id = L_ORG_ID
             and inventory_item_id = L_ITEM_ID
             and (subinventory_code = l_pick_subinventory or
                 l_pick_subinventory is null);

          SELECT Nvl(SUM(wdd.requested_quantity), 0)
            INTO l_other_wdd_qty
            FROM wsh_delivery_details wdd
           WHERE wdd.organization_id = l_org_id
             AND wdd.inventory_item_id = l_item_id
             and wdd.delivery_Detail_id not in
                 (select delivery_detail_id
                    from wms_wp_wave_lines
                   where wave_header_id = p_wave_header_id
                     and nvl(remove_from_wave_flag, 'N') <> 'Y'
                     and source_line_id = wdd.source_line_id);

          print_debug('Reserved Qty for other dds that do not belong to the wave in source line id  :' ||
                      c_rec.SOURCE_LINE_ID || ' is ' || l_other_wdd_qty,
                      l_debug);

          IF (l_reserved_qty - l_other_wdd_qty) >= 0 THEN
            l_temp_value := (l_reserved_qty - l_other_wdd_qty);
          ELSE
            l_temp_value := 0;
          END IF;

          l_reserved_qty := l_temp_value;

          print_debug('Reserved Qty for source line id  :' ||
                      c_rec.SOURCE_LINE_ID || ' is ' || l_reserved_qty,
                      l_debug);

        exception

          when no_data_found then
            l_reserved_qty := 0;
        end;

        l_atr := l_atr + l_reserved_qty;

        print_debug('Effective ATR is  :' || l_atr, l_debug);

        if l_atr >= c_rec.REQUESTED_QUANTITY then
          X_CONSOL_LINES_TBL(m).wave_header_id := p_wave_header_id;
          X_CONSOL_LINES_TBL(m).wave_line_id := c_rec.wave_line_id;
          X_CONSOL_LINES_TBL(m).planned_fill_rate := 100;

          l_atr := l_atr - c_rec.REQUESTED_QUANTITY;
        else

          X_CONSOL_LINES_TBL(m).wave_header_id := p_wave_header_id;
          X_CONSOL_LINES_TBL(m).wave_line_id := c_rec.wave_line_id;

          IF L_ATR > 0 THEN
            X_CONSOL_LINES_TBL(m).planned_fill_rate := round((l_atr * 100) /
                                                             c_rec.REQUESTED_QUANTITY);

            l_atr := l_atr - c_rec.REQUESTED_QUANTITY;

          ELSE
            X_CONSOL_LINES_TBL(m).planned_fill_rate := 0;

            -- l_atr := l_atr - c_rec.REQUESTED_QUANTITY;
          end if;
        end if;
        /*
        if c_rec.wave_line_id = p_wave_line_id then
          fill_rate_percent := X_CONSOL_LINES_TBL(m).planned_fill_rate;
        end if;
        */
        --Updating the Lines Table with planned_fill_rate and actual _fill_rate
        print_debug('Wave Line Id:' || X_CONSOL_LINES_TBL(m).wave_line_id,
                    l_debug);

        print_debug('Planned Fill Rate:' || X_CONSOL_LINES_TBL(m)
                    .planned_fill_rate,
                    l_debug);

        update wms_wp_wave_lines
           set planned_fill_rate = X_CONSOL_LINES_TBL(m).planned_fill_rate
         where wave_line_id = X_CONSOL_LINES_TBL(m).wave_line_id;

        m := m + 1;
      END LOOP;

    end loop;
    x_return_status := fnd_api.g_ret_sts_success;
    -- commit;
  exception

    when others then
      print_debug('Error in Planned Fill Rate: ' || SQLCODE || ' : ' ||
                  SQLERRM,
                  l_debug);
      x_return_status := FND_API.G_RET_STS_ERROR;

  end get_line_fill_rate;

  procedure get_actual_fill_rate(x_return_status  OUT NOCOPY varchar2,
                                 p_wave_header_id in number)

   is
    v_actual_fill_rate number;
    l_progress         number;
    cursor c_actual_fill_rate is
      SELECT wwl.wave_line_id,
             min(wwl.requested_quantity) requested_qty,
             min(wdd.released_status) released_status,
             Decode(min(wdd.released_status),
                    'B',
                    0,
                    sum((get_conversion_rate(wdd.inventory_item_id,
                                             mmtt.transaction_uom,
                                             wdd.requested_quantity_uom) *
                        Nvl(MMTT.TRANSACTION_QUANTITY, 0)))) allocated_qty
        FROM mtl_material_transactions_temp mmtt,
             WSH_DELIVERY_DETAILS           WDD,
             WMS_WP_WAVE_LINES              WWL
       where WDD.source_line_id = MMTT.trx_source_line_id(+)
         AND WWL.DELIVERY_DETAIL_ID = WDD.DELIVERY_DETAIL_ID
         AND wwl.wave_header_id = p_wave_header_id
         and nvl(wwl.remove_from_wave_flag, 'N') = 'N'
       group by wwl.wave_line_id
       ORDER BY wave_line_id;

    -- cursor c_check_mmtt is
    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  begin
    x_return_status := fnd_api.g_ret_sts_success;
    for c_Rec in c_actual_fill_rate loop
      exit when c_actual_fill_rate%NOTFOUND;

      -- Checking if the Line is in Crossdocked Status. In that case we mark the Release Fill Rate for that Line as 100%
      print_debug('Checking if the Line is in Crossdocked Status. In that case we mark the Release Fill Rate for that Line as 100%',
                  l_debug);

      select line_progress_id
        into l_progress
        from wms_wp_wwb_lines_v wwlv, wms_Wp_Wave_lines wwl
       where wwl.wave_line_id = c_rec.wave_line_id
         and wwl.delivery_detail_id = wwlv.delivery_Detail_id
         and wwlv.wave_header_id = p_wave_header_id;

      if l_progress = 3 then

        print_debug(' Line is in Crossdocked Status. In that case we mark the Release Fill Rate for that Line as 100%',
                    l_debug);
        v_actual_fill_rate := 100;

      else

        print_debug('Entered Actual Fill Rate with Allocated Qty ' ||
                    c_rec.allocated_qty,
                    l_debug);
        print_debug('Entered Actual Fill Rate with released status ' ||
                    c_rec.released_status,
                    l_debug);
        v_actual_fill_rate := round((c_rec.allocated_qty * 100) /
                                    c_rec.requested_qty);

      end if;

      print_debug('Actual Fill Rate:' || v_actual_fill_rate, l_debug);

      update wms_wp_wave_lines
         set release_fill_rate = v_actual_fill_rate
       where wave_line_id = c_rec.wave_line_id;
    end loop;
    x_return_status := fnd_api.g_ret_sts_success;
    --   commit;
  exception
    when others then
      print_debug('Error in Actual Fill Rate: ' || SQLCODE || ' : ' ||
                  SQLERRM,
                  l_debug);
      x_return_status := FND_API.G_RET_STS_ERROR;

  end get_actual_fill_rate;

  function get_order_weight(p_source_header_id in number,
                            p_orgid            in number) return number

   is

    cursor c_uom is
      select nvl(net_weight, 0) net_weight, weight_uom_code
        from wsh_delivery_details
       where source_header_id = p_source_header_id;

    v_weight_uom varchar2(20);
    total_weight number := 0;
    l_debug      NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  begin

    SELECT uom_code
      into v_weight_uom
      FROM mtl_units_of_measure_vl
     WHERE uom_class = (SELECT weight_uom_class
                          FROM wsh_shipping_parameters
                         WHERE organization_id = p_orgid)
       AND base_uom_flag = 'Y';

    for l_uom in c_uom loop

      total_weight := total_weight + wms_wave_planning_pvt.get_conversion_rate(null,
                                                                               l_uom.weight_uom_code,
                                                                               v_weight_uom) *
                      l_uom.net_weight;

    end loop;
    --  print_debug('Total Weight for Order id :'||p_source_header_id ||' is '|| total_weight, l_debug);

    return total_weight;

  exception

    when others then
      print_debug('Error in get_order_weight : ' || SQLCODE || ' : ' ||
                  SQLERRM,
                  l_debug);
      return 0;

  end get_order_weight;

  function get_order_volume(p_source_header_id in number,
                            p_orgid            in number) return number

   is

    cursor c_uom is
      select nvl(volume, 0) volume, volume_uom_code
        from wsh_delivery_details
       where source_header_id = p_source_header_id;

    v_volume_uom varchar2(20);
    total_volume number := 0;
    l_debug      NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  begin

    SELECT uom_code
      into v_volume_uom
      FROM mtl_units_of_measure_vl
     WHERE uom_class = (SELECT volume_uom_class
                          FROM wsh_shipping_parameters
                         WHERE organization_id = p_orgid)
       AND base_uom_flag = 'Y';

    for l_uom in c_uom loop

      total_volume := total_volume + wms_wave_planning_pvt.get_conversion_rate(null,
                                                                               l_uom.volume_uom_code,
                                                                               v_volume_uom) *
                      l_uom.volume;

    end loop;
    --  print_debug('Total Volume for Order id :'||p_source_header_id ||' is '|| total_volume, l_debug);

    return total_volume;

  exception

    when others then
      print_debug('Error in get_order_volume : ' || SQLCODE || ' : ' ||
                  SQLERRM,
                  l_debug);
      return 0;

  end get_order_volume;

  procedure get_net_weight_volume(p_wave_header_id in number,
                                  p_orgid          in number,
                                  x_weight         OUT NOCOPY varchar2,
                                  x_volume         OUT NOCOPY varchar2)

   is

    cursor c_uom is
      select nvl(net_weight, 0) net_weight,
             weight_uom_code,
             nvl(volume, 0) volume,
             volume_uom_code
        from wsh_delivery_details
       where delivery_detail_id in
             (select delivery_Detail_id
                from wms_wp_wave_lines
               where wave_header_id = p_wave_header_id
                 and nvl(remove_from_wave_flag, 'N') <> 'Y');

    v_weight_uom varchar2(20);
    v_volume_uom varchar2(20);

    total_weight number := 0;
    total_volume number := 0;
    l_debug      NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  begin

    SELECT uom_code
      into v_weight_uom
      FROM mtl_units_of_measure_vl
     WHERE uom_class = (SELECT weight_uom_class
                          FROM wsh_shipping_parameters
                         WHERE organization_id = p_orgid)
       AND base_uom_flag = 'Y';

    SELECT uom_code
      into v_volume_uom
      FROM mtl_units_of_measure_vl
     WHERE uom_class = (SELECT volume_uom_class
                          FROM wsh_shipping_parameters
                         WHERE organization_id = p_orgid)
       AND base_uom_flag = 'Y';

    for l_uom in c_uom loop

      -- dbms_output.put_line( l_uom.weight_uom_code);
      total_weight := total_weight + wms_wave_planning_pvt.get_conversion_rate(null,
                                                                               l_uom.weight_uom_code,
                                                                               v_weight_uom) *
                      l_uom.net_weight;

      total_volume := total_volume + wms_wave_planning_pvt.get_conversion_rate(null,
                                                                               l_uom.volume_uom_code,
                                                                               v_volume_uom) *
                      l_uom.volume;

    end loop;

    --dbms_output.put_line(v_weight_uom);
    --dbms_output.put_line(v_volume_uom);
    --dbms_output.put_line(total_weight);
    --dbms_output.put_line(total_volume);

    print_debug('Total Weight is : ' || total_weight, l_debug);

    if nvl(total_weight, 0) > 0 then

      x_weight := total_weight || ' ' || v_weight_uom;
    else
      x_weight := '';
    end if;
    print_debug('Total Volume  is : ' || total_weight, l_debug);

    if nvl(total_volume, 0) > 0 then

      x_volume := round(total_volume, 2) || ' ' || v_volume_uom;
    else

      x_volume := '';
    end if;

  exception

    when others then
      print_debug('Error in get net weight volume : ' || SQLCODE || ' : ' ||
                  SQLERRM,
                  l_debug);

  end get_net_weight_volume;

  procedure update_wave_header_status(x_return_status  OUT NOCOPY varchar2,
                                      p_wave_header_id in number,
                                      Status           in varchar2)

   is
    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  begin
    print_debug('Update Wave Header Status: ' || Status, l_debug);
    update wms_wp_wave_headers_vl
       set wave_status = Status
     where wave_header_id = p_wave_header_id;

    x_return_status := 'S';
  exception

    when OTHERS then
      print_debug('Error in Update Wave Header Status: ' || SQLCODE ||
                  ' : ' || SQLERRM,
                  l_debug);
      x_return_status := FND_API.G_RET_STS_ERROR;
  end update_wave_header_status;

  PROCEDURE update_task(p_transaction_temp_id   IN WMS_WAVE_PLANNING_PVT.transaction_temp_table_type,
                        p_task_type_id          IN WMS_WAVE_PLANNING_PVT.task_type_id_table_type,
                        p_employee              IN VARCHAR2,
                        p_employee_id           IN NUMBER,
                        p_user_task_type        IN VARCHAR2,
                        p_user_task_type_id     IN NUMBER,
                        p_effective_start_date  IN DATE,
                        p_effective_end_date    IN DATE,
                        p_person_resource_id    IN NUMBER,
                        p_person_resource_code  IN VARCHAR2,
                        p_force_employee_change IN BOOLEAN,
                        p_to_status             IN VARCHAR2,
                        p_to_status_id          IN NUMBER,
                        p_priority_type         IN varchar2 DEFAULT 'S', --mitgupta
                        p_priority              IN NUMBER,
                        p_clear_priority        IN VARCHAR2,
                        x_result                OUT NOCOPY WMS_WAVE_PLANNING_PVT.result_table_type,
                        x_message               OUT NOCOPY WMS_WAVE_PLANNING_PVT.message_table_type,
                        x_task_id               OUT NOCOPY WMS_WAVE_PLANNING_PVT.task_id_table_type,
                        x_return_status         OUT NOCOPY VARCHAR2,
                        x_return_msg            OUT NOCOPY VARCHAR2,
                        x_msg_count             OUT NOCOPY NUMBER) IS
    l_task_id NUMBER;
    l_index   NUMBER;
    l_debug   NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

    TYPE status_table_type IS TABLE OF Varchar2(100);

    l_transaction_temp_ids      WMS_WAVE_PLANNING_PVT.transaction_temp_table_type;
    l_task_type_ids             WMS_WAVE_PLANNING_PVT.task_type_id_table_type;
    l_statuses                  status_table_type;
    l_transaction_temp_ids_temp WMS_WAVE_PLANNING_PVT.transaction_temp_table_type;
    l_device_id                 NUMBER;
    l_messages                  WMS_WAVE_PLANNING_PVT.message_table_type;
    l_message                   WMS_WP_TASKS_GTMP.error%TYPE;
    g_cannot_update_putaway          WMS_WP_TASKS_GTMP.error%TYPE;
    g_task_updated                   WMS_WP_TASKS_GTMP.error%TYPE;

  BEGIN
    print_debug('XXXX Update Wave Header Status: ', l_debug);

--g_cannot_update_putaway := NULL;

     IF g_cannot_update_putaway IS NULL
      THEN
         fnd_message.set_name ('WMS', 'WMS_CANNOT_UPDATE_PUTAWAY_TASK');
         g_cannot_update_putaway := fnd_message.get;

         fnd_message.set_name ('WMS', 'WMS_TASK_UPDATED');
         g_task_updated := fnd_message.get;

      END IF;

      FORALL i IN p_transaction_temp_id.FIRST .. p_transaction_temp_id.LAST
         UPDATE wms_wp_tasks_gtmp
            SET RESULT = 'X'
          WHERE transaction_temp_id = p_transaction_temp_id (i)
            AND task_type_id = p_task_type_id (i);

      -- Validations

      -- 1  Pick
      -- 2  Putaway
      -- 3  Cycle Count
      -- 4  Replenish
      -- 5  Move Order Transfer
      -- 6  Move Order Issue
      -- 7  Staging Move

      -- Cannot update putaway tasks or staging moves
      UPDATE wms_wp_tasks_gtmp
         SET RESULT = 'E',
             error =
                DECODE (task_type_id,
                        2, g_cannot_update_putaway
                       )
       WHERE RESULT = 'X' AND task_type_id IN (2);

    g_task_updated := fnd_message.get;
    -- Validations

    -- 1  Pick
    -- 2  Putaway
    -- 3  Cycle Count
    -- 4  Replenish
    -- 5  Move Order Transfer
    -- 6  Move Order Issue
    -- 7  Staging Move
 /*   FORALL i IN p_transaction_temp_id.FIRST .. p_transaction_temp_id.LAST
      UPDATE wms_wp_tasks_gtmp
         SET RESULT = 'X'
       WHERE transaction_temp_id = p_transaction_temp_id(i)
         AND task_type_id = p_task_type_id(i);*/

    -- Invalid status changes
    IF p_to_status_id IS NOT NULL THEN
      SELECT transaction_temp_id, task_type_id, status BULK COLLECT
        INTO l_transaction_temp_ids, l_task_type_ids, l_statuses
        FROM wms_wp_tasks_gtmp
       WHERE RESULT = 'X'
         AND NOT ((status_id = 8 AND p_to_status_id IN (1, 2)) -- Unreleased to pending or queued
              OR (status_id = 1 AND p_to_status_id IN (2, 8)) -- Pending to queued or unreleased
              OR (status_id = 2 AND p_to_status_id IN (1, 8)) -- Queued to pending or unreleased
              OR (status_id = 9 AND p_to_status_id IN (1, 8)) -- R12:Active to Pending or unreleased
              OR (status_id = 3 AND p_to_status_id IN (1, 8)) -- R12:Dispatched to Pending or unreleased
              OR (status_id = p_to_status_id)); -- No Status Change
      IF l_transaction_temp_ids.COUNT > 0 THEN
        FOR i IN l_transaction_temp_ids.FIRST .. l_transaction_temp_ids.LAST LOOP
          fnd_message.set_name('WMS', 'WMS_CANNOT_UPDATE_STATUS');
          fnd_message.set_token('FROM_STATUS', l_statuses(i));
          fnd_message.set_token('TO_STATUS', p_to_status);
          l_messages(i) := fnd_message.get;
        END LOOP;

        FORALL i IN l_transaction_temp_ids.FIRST .. l_transaction_temp_ids.LAST
          UPDATE wms_wp_tasks_gtmp
             SET RESULT = 'E', error = l_messages(i)
           WHERE transaction_temp_id = l_transaction_temp_ids(i)
             AND task_type_id = l_task_type_ids(i);
      END IF;

      IF p_to_status_id IN (1, 8) THEN
        SELECT wwtt.transaction_temp_id, wwtt.task_type_id, wwtt.status BULK COLLECT
          INTO l_transaction_temp_ids, l_task_type_ids, l_statuses
          FROM wms_wp_tasks_gtmp              wwtt,
               mtl_material_transactions_temp mmtt,
               WMS_DISPATCHED_TASKS           wdt
         WHERE wwtt.transaction_temp_id = wdt.transaction_temp_id
           AND wwtt.transaction_temp_id = mmtt.transaction_temp_id
           AND wwtt.RESULT = 'X'
           AND wwtt.status_id = 3
           AND EXISTS
         (SELECT 1
                  FROM WMS_DISPATCHED_TASKS wdt2
                 WHERE wdt2.person_id = wwtt.person_id
                   AND wdt2.status = 9
                   AND wdt2.task_method IS NOT NULL
                   AND wdt2.transaction_temp_id IN
                       (SELECT transaction_temp_id
                          FROM mtl_material_transactions_temp mmtt1
                         WHERE DECODE(wdt.TASK_METHOD,
                                      'CARTON',
                                      mmtt1.cartonization_id,
                                      'PICK_SLIP',
                                      mmtt1.pick_slip_number,
                                      'DISCRETE',
                                      mmtt1.pick_slip_number,
                                      mmtt1.transaction_source_id) =
                               DECODE(wdt.TASK_METHOD,
                                      'CARTON',
                                      mmtt.cartonization_id,
                                      'PICK_SLIP',
                                      mmtt.pick_slip_number,
                                      'DISCRETE',
                                      mmtt.pick_slip_number,
                                      mmtt.transaction_source_id)));

        IF l_transaction_temp_ids.COUNT > 0 THEN
          FOR i IN l_transaction_temp_ids.FIRST .. l_transaction_temp_ids.LAST LOOP
            fnd_message.set_name('WMS', 'WMS_GROUP_TASKS_CANNOT_UPDATE');
            l_messages(i) := fnd_message.get;
          END LOOP;

          FORALL i IN l_transaction_temp_ids.FIRST .. l_transaction_temp_ids.LAST
            UPDATE wms_wp_tasks_gtmp
               SET RESULT = 'E',
                   error  = 'This group of tasks is currently being worked, cannot change status'
             WHERE transaction_temp_id = l_transaction_temp_ids(i)
               AND task_type_id = l_task_type_ids(i);
        END IF;

        -- if the original task status is Active, check if the user whom the task is assigned is
        -- logged on to the system
        -- if the original task status is Active, check if the user whom the task is assigned is
        -- logged on to the system
        SELECT transaction_temp_id, task_type_id, status BULK COLLECT
          INTO l_transaction_temp_ids, l_task_type_ids, l_statuses
          FROM wms_wp_tasks_gtmp wwtt
         WHERE RESULT = 'X'
           AND status_id = 9
           AND EXISTS
         (SELECT 1
                  FROM MTL_MOBILE_LOGIN_HIST MMLH, WMS_DISPATCHED_TASKS WDT
                 WHERE WDT.TRANSACTION_TEMP_ID = WWTT.TRANSACTION_TEMP_ID
                   AND MMLH.USER_ID = WDT.LAST_UPDATED_BY
                   AND MMLH.LOGOFF_DATE IS NULL
                   AND MMLH.EVENT_MESSAGE IS NULL);

        IF l_transaction_temp_ids.COUNT > 0 THEN
          FORALL i IN l_transaction_temp_ids.FIRST .. l_transaction_temp_ids.LAST
            UPDATE wms_wp_tasks_gtmp
               SET RESULT = 'E',
                   error  = 'This task is currently being worked, cannot change status'
             WHERE transaction_temp_id = l_transaction_temp_ids(i)
               AND task_type_id = l_task_type_ids(i);
        END IF;

      END IF;

    END IF;

    -- Employee eligibility validation
    IF p_employee_id IS NOT NULL AND NOT p_force_employee_change THEN
      fnd_message.set_name('WMS', 'WMS_CANNOT_UPDATE_EMPLOYEE');
      fnd_message.set_token('EMPLOYEE', p_employee);
      l_message := fnd_message.get;

      UPDATE wms_wp_tasks_gtmp wwtt
         SET RESULT = 'E', error = l_message
       WHERE RESULT = 'X'
         AND NOT EXISTS
       (SELECT 1
                FROM bom_std_op_resources bsor, bom_resource_employees bre
               WHERE wwtt.user_task_type_id = bsor.standard_operation_id
                 AND bsor.resource_id = bre.resource_id
                 AND bre.person_id = p_employee_id);

      SELECT transaction_temp_id BULK COLLECT
        INTO l_transaction_temp_ids_temp
        FROM wms_wp_tasks_gtmp
       WHERE RESULT = 'X';

      --j Develop
      IF (l_transaction_temp_ids_temp.COUNT > 0) THEN
        FOR i IN l_transaction_temp_ids_temp.FIRST .. l_transaction_temp_ids_temp.LAST LOOP
          IF (getforcesignonflagvalue(l_transaction_temp_ids_temp(i),
                                      l_device_id) = 'Y') THEN
            fnd_message.set_name('WMS', 'WMS_CANNOT_UPDATE_EMPLOYEE');
            fnd_message.set_token('EMPLOYEE', p_employee);
            l_message := fnd_message.get;
            if l_debug = 1 then
              print_DEBUG('l_device_id : ' || l_device_id, l_debug);
              print_DEBUG(' p_employee_id : ' || p_employee_id, l_debug);
            end if;

            UPDATE wms_wp_tasks_gtmp wwtt
               SET RESULT = 'E', error = l_message
             WHERE transaction_temp_id = l_transaction_temp_ids_temp(i)
               AND NOT EXISTS
             (SELECT 1
                      FROM wms_device_assignment_temp
                     WHERE device_id = l_device_id
                       AND employee_id = p_employee_id);
          END IF;
        END LOOP;
      END IF;
      -- End  of J Develop
    END IF;

    UPDATE wms_wp_tasks_gtmp wwtt
       SET person_resource_id = (SELECT bre.resource_id
                                   FROM bom_std_op_resources   bsor,
                                        bom_resource_employees bre
                                  WHERE wwtt.user_task_type_id =
                                        bsor.standard_operation_id
                                    AND bsor.resource_id = bre.resource_id
                                    AND bre.person_id = wwtt.person_id
                                    AND ROWNUM < 2)
     WHERE RESULT = 'X';

    IF p_user_task_type_id IS NOT NULL THEN
      -- R12: Can update User Task Type if task is dispatched, active  IF
      -- Dispatched or Active tasks are in the process of getting updated to pending or Unreleased
      IF p_to_status_id IS NOT NULL THEN
        UPDATE wms_wp_tasks_gtmp wwtt
           SET RESULT = 'E', error = l_message
         WHERE RESULT = 'X'
           AND (status_id NOT IN (1, 2, 3, 8, 9) AND
               p_to_status_id IN (1, 8))
        RETURNING transaction_temp_id, task_type_id, status BULK COLLECT INTO l_transaction_temp_ids, l_task_type_ids, l_statuses;
      ELSE
        -- R12: Cannot update User Task Type if task is dispatched, active or loaded IF
        -- Dispatched or Active tasks are NOT in the process of getting updated to pending or Unreleased
        UPDATE wms_wp_tasks_gtmp wwtt
           SET RESULT = 'E', error = l_message
         WHERE RESULT = 'X'
           AND status_id NOT IN (1, 8)
        RETURNING transaction_temp_id, task_type_id, status BULK COLLECT INTO l_transaction_temp_ids, l_task_type_ids, l_statuses;
      END IF;

      IF l_transaction_temp_ids.COUNT > 0 THEN
        FOR i IN l_transaction_temp_ids.FIRST .. l_transaction_temp_ids.LAST LOOP
          fnd_message.set_name('WMS', 'WMS_CANNOT_UPDATE_USER_TASK_TYPE');
          fnd_message.set_token('STATUS', l_statuses(i));
          l_messages(i) := fnd_message.get;
        END LOOP;

        FORALL i IN l_transaction_temp_ids.FIRST .. l_transaction_temp_ids.LAST
          UPDATE wms_wp_tasks_gtmp
             SET RESULT = 'E', error = l_messages(i)
           WHERE transaction_temp_id = l_transaction_temp_ids(i)
             AND task_type_id = l_task_type_ids(i);
      END IF;
    END IF;
    -- Ajith Needs to check the following code ??????????
    --mitgupta add p_priority_type
    IF (p_priority_type IS NOT NULL AND p_priority IS NOT NULL) OR
       p_clear_priority = 'Y' THEN
      -- R12: Can update priority if task is dispatched, active  IF
      -- Dispatched or Active tasks are in the process of getting updated to pending or Unreleased
      IF p_to_status_id IS NOT NULL THEN
        UPDATE wms_wp_tasks_gtmp wwtt
           SET RESULT = 'E', error = l_message
         WHERE RESULT = 'X'
           AND (status_id NOT IN (1, 2, 3, 8, 9) AND
               p_to_status_id IN (1, 8))
        RETURNING transaction_temp_id, task_type_id, status BULK COLLECT INTO l_transaction_temp_ids, l_task_type_ids, l_statuses;
      ELSE
        -- R12: Cannot update priority if task is dispatched, active or loaded IF
        -- Dispatched or Active tasks are NOT in the process of getting updated to pending or Unreleased
        UPDATE wms_wp_tasks_gtmp wwtt
           SET RESULT = 'E', error = l_message
         WHERE RESULT = 'X'
           AND status_id NOT IN (1, 2, 8)
        RETURNING transaction_temp_id, task_type_id, status BULK COLLECT INTO l_transaction_temp_ids, l_task_type_ids, l_statuses;
      END IF;

      IF l_transaction_temp_ids.COUNT > 0 THEN
        FOR i IN l_transaction_temp_ids.FIRST .. l_transaction_temp_ids.LAST LOOP
          fnd_message.set_name('WMS', 'WMS_CANNOT_UPDATE_PRIORITY');
          fnd_message.set_token('STATUS', l_statuses(i));
          l_messages(i) := fnd_message.get;
        END LOOP;

        FORALL i IN l_transaction_temp_ids.FIRST .. l_transaction_temp_ids.LAST
          UPDATE wms_wp_tasks_gtmp
             SET RESULT = 'E', error = l_messages(i)
           WHERE transaction_temp_id = l_transaction_temp_ids(i)
             AND task_type_id = l_task_type_ids(i);
      END IF;
    END IF;

    -- If changing status to Queued
    IF p_to_status_id = 2 THEN
      UPDATE wms_wp_tasks_gtmp
         SET task_id   = NVL(task_id, wms_dispatched_tasks_s.NEXTVAL),
             status    = p_to_status,
             status_id = p_to_status_id,
             priority  = DECODE(p_clear_priority,
                                'Y',
                                NULL,
                                DECODE(p_priority_type,
                                       'I',
                                       NVL(priority, 0) + p_priority, -- R12: Increment priority
                                       'D',
                                       DECODE(SIGN(NVL(priority, 0) -
                                                   p_priority), -- R12: Decrement priority
                                              -1,
                                              0,
                                              +1,
                                              NVL(priority, 0) - p_priority,
                                              0,
                                              0),
                                       'S',
                                       NVL(p_priority, priority), -- R12: Set       priority
                                       priority)),

             person               = p_employee,
             person_id            = p_employee_id,
             effective_start_date = p_effective_start_date,
             effective_end_date   = p_effective_end_date,
             person_resource_code = p_person_resource_code,
             person_resource_id   = p_person_resource_id,
             RESULT               = 'S',
             error                = g_task_updated,
             is_modified          = 'Y'
       WHERE RESULT = 'X';
    ELSE

      if l_debug = 1 then
        print_DEBUG('Else Part  ______________________: ', l_debug);
      end if;
      UPDATE wms_wp_tasks_gtmp
         SET task_id           = DECODE(p_to_status_id,
                                        1,
                                        NULL,
                                        8,
                                        NULL,
                                        task_id),
             status            = NVL(p_to_status, status),
             status_id         = NVL(p_to_status_id, status_id),
             user_task_type    = NVL(p_user_task_type, user_task_type),
             user_task_type_id = NVL(p_user_task_type_id, user_task_type_id),

             priority = DECODE(p_clear_priority,
                               'Y',
                               NULL,
                               DECODE(p_priority_type,
                                      'I',
                                      NVL(priority, 0) + p_priority, -- R12: Increment priority
                                      'D',
                                      DECODE(SIGN(NVL(priority, 0) -
                                                  p_priority), -- R12: Decrement priority
                                             -1,
                                             0,
                                             +1,
                                             NVL(priority, 0) - p_priority,
                                             0,
                                             0),
                                      'S',
                                      NVL(p_priority, priority), -- R12: Set Constant priority value
                                      priority)),

             person               = DECODE(p_to_status_id,
                                           1,
                                           NULL,
                                           8,
                                           NULL,
                                           person),
             person_id            = DECODE(p_to_status_id,
                                           1,
                                           NULL,
                                           8,
                                           NULL,
                                           person_id),
             effective_start_date = DECODE(p_to_status_id,
                                           1,
                                           NULL,
                                           8,
                                           NULL,
                                           effective_start_date),
             effective_end_date   = DECODE(p_to_status_id,
                                           1,
                                           NULL,
                                           8,
                                           NULL,
                                           effective_end_date),
             person_resource_code = DECODE(p_to_status_id,
                                           1,
                                           NULL,
                                           8,
                                           NULL,
                                           person_resource_code),
             person_resource_id   = DECODE(p_person_resource_id,
                                           1,
                                           NULL,
                                           8,
                                           NULL,
                                           person_resource_id),
             RESULT               = 'S',
             error                = g_task_updated,
             is_modified          = 'Y'
       WHERE RESULT = 'X';

      if l_debug = 1 then
        print_DEBUG('Else Part : ________________2', l_debug);
      end if;
    END IF;

    FORALL i IN p_transaction_temp_id.FIRST .. p_transaction_temp_id.LAST
      UPDATE wms_wp_tasks_gtmp
         SET RESULT = RESULT
       WHERE transaction_temp_id = p_transaction_temp_id(i)
         AND task_type_id = p_task_type_id(i)
      RETURNING task_id, RESULT, error BULK COLLECT INTO x_task_id, x_result, x_message;
    x_return_status := 'S';
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := 'U';
      x_return_msg    := SQLERRM;
      print_DEBUG('Sql Error: ' || SQLERRM, l_debug);
  END update_task;

  PROCEDURE save_tasks(p_commit        BOOLEAN,
                       p_user_id       NUMBER,
                       p_login_id      NUMBER,
                       x_save_count    OUT NOCOPY NUMBER,
                       x_return_status OUT NOCOPY VARCHAR2,
                       x_msg_data      OUT NOCOPY VARCHAR2,
                       x_msg_count     OUT NOCOPY NUMBER) IS
    TYPE transaction_temp_id_table_type IS TABLE OF mtl_material_transactions_temp.transaction_temp_id%TYPE INDEX BY BINARY_INTEGER;

    TYPE wms_task_status_table_type IS TABLE OF mtl_material_transactions_temp.wms_task_status%TYPE INDEX BY BINARY_INTEGER;

    TYPE task_priority_table_type IS TABLE OF mtl_material_transactions_temp.task_priority%TYPE INDEX BY BINARY_INTEGER;

    TYPE person_id_table_type IS TABLE OF wms_dispatched_tasks.person_id%TYPE INDEX BY BINARY_INTEGER;

    TYPE person_resource_id_table_type IS TABLE OF wms_dispatched_tasks.person_resource_id%TYPE /* Bug 5630187 */
    INDEX BY BINARY_INTEGER;

    TYPE effective_start_date IS TABLE OF wms_dispatched_tasks.effective_start_date%TYPE INDEX BY BINARY_INTEGER;

    TYPE effective_end_date IS TABLE OF wms_dispatched_tasks.effective_end_date%TYPE INDEX BY BINARY_INTEGER;

    TYPE task_type_id IS TABLE OF wms_waveplan_tasks_temp.task_type_id%TYPE INDEX BY BINARY_INTEGER;

    TYPE user_task_type_id IS TABLE OF wms_waveplan_tasks_temp.user_task_type_id%TYPE -- R12: Update User Task Type Id
    INDEX BY BINARY_INTEGER;

    l_transaction_temp_id_table  transaction_temp_id_table_type;
    l_wms_task_status_table      wms_task_status_table_type;
    l_task_priority_table        task_priority_table_type;
    l_person_id_table            person_id_table_type;
    l_person_resource_id_table   person_resource_id_table_type;
    l_effective_start_date_table effective_start_date;
    l_effective_end_date_table   effective_end_date;
    l_task_type_id               task_type_id;
    l_user_task_type_id          user_task_type_id;
    l_error_message              VARCHAR2(120);
    l_update_date                DATE;
    l_non_cycle_count_number     NUMBER := 0;
    l_cycle_count_number         NUMBER := 0;
    l_children_task_count        NUMBER := 0;
    l_debug                      NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'),
                                               0);

    CURSOR cur_wwtt IS
      SELECT transaction_temp_id,
             task_type_id,
             mmtt_last_updated_by,
             mmtt_last_update_date,
             wdt_last_updated_by,
             wdt_last_update_date,
             person_id,
             person_id_original,
             person_resource_id,
             effective_start_date,
             effective_end_date,
             status_id,
             status_id_original,
             priority,
             priority_original,
             user_task_type_id,
             num_of_child_tasks
        FROM wms_wp_tasks_gtmp wwtt
       WHERE wwtt.is_modified = 'Y';

    --Patchset J: Bulk picking
    --Get the transaction_temp_id of the children tasks
    CURSOR bulk_children_tasks_cur(trx_temp_id NUMBER) IS
      SELECT transaction_temp_id
        FROM mtl_material_transactions_temp
       WHERE parent_line_id = trx_temp_id
         AND transaction_temp_id <> trx_temp_id
         FOR UPDATE nowait;
    --end bulk picking

    i NUMBER;
    record_locked EXCEPTION;
    PRAGMA EXCEPTION_INIT(record_locked, -54);

  BEGIN
    x_return_status := 'S';
    x_save_count    := 0;
    SAVEPOINT save_tasks;

    i := 1;

    FOR rec_wwtt IN cur_wwtt LOOP
      BEGIN

        print_DEBUG('TRANSACTION_TEMP_ID: ' ||
                    rec_wwtt.transaction_temp_id,
                    l_debug);

        print_DEBUG('STATUS_ID: ' || rec_wwtt.status_id, l_debug);
        print_DEBUG('PERSON_ID: ' || rec_wwtt.person_id, l_debug);
        print_DEBUG('PRIORITY: ' || rec_wwtt.priority, l_debug);

        IF rec_wwtt.task_type_id IN (2, 8) AND rec_wwtt.status_id = 12 THEN
          if l_debug = 1 then
            print_DEBUG('Cancelled Plan', l_debug);
          end if;

          x_save_count := x_save_count + 1;
          if l_debug = 1 then
            print_DEBUG('no of records saved are' || x_save_count, l_debug);
          end if;

          IF g_plan_cancelled IS NULL THEN
            fnd_message.set_name('WMS', 'WMS_PLAN_CANCELLED');
            g_plan_cancelled := fnd_message.get;
          END IF;

          UPDATE wms_wp_tasks_gtmp
             SET is_modified = 'N', RESULT = 'S', error = g_plan_cancelled
           WHERE transaction_temp_id = rec_wwtt.transaction_temp_id;

        END IF;

        if l_debug = 1 then
          print_DEBUG('In the wwtt for loop', l_debug);
        end if;

        IF rec_wwtt.task_type_id <> 3 THEN
          SELECT mmtt.transaction_temp_id
            INTO l_transaction_temp_id_table(i)
            FROM mtl_material_transactions_temp mmtt,
                 wms_dispatched_tasks           wdt
           WHERE mmtt.transaction_temp_id = rec_wwtt.transaction_temp_id
             AND mmtt.transaction_temp_id = wdt.transaction_temp_id(+)
             AND mmtt.wms_task_type = wdt.task_type(+)
             AND DECODE(wdt.status,
                        NULL,
                        NVL(mmtt.wms_task_status, 1),
                        wdt.status) = NVL(rec_wwtt.status_id_original, -1)
             AND NVL(mmtt.task_priority, -1) =
                 NVL(rec_wwtt.priority_original, -1)
             AND NVL(wdt.person_id, -1) =
                 NVL(rec_wwtt.person_id_original, -1)
             AND mmtt.last_updated_by = rec_wwtt.mmtt_last_updated_by
             AND mmtt.last_update_date = rec_wwtt.mmtt_last_update_date
             AND NVL(wdt.last_updated_by, -1) =
                 NVL(rec_wwtt.wdt_last_updated_by, -1)
             AND (wdt.last_update_date = rec_wwtt.wdt_last_update_date OR
                 (wdt.last_update_date IS NULL AND
                 rec_wwtt.wdt_last_update_date IS NULL))
             FOR UPDATE NOWAIT;

          l_non_cycle_count_number := l_non_cycle_count_number + 1;

        END IF;

        l_wms_task_status_table(i) := rec_wwtt.status_id;
        l_task_priority_table(i) := rec_wwtt.priority;
        l_person_id_table(i) := rec_wwtt.person_id;
        l_person_resource_id_table(i) := rec_wwtt.person_resource_id;
        l_effective_start_date_table(i) := sysdate;
        l_effective_end_date_table(i) := sysdate;
        l_task_type_id(i) := rec_wwtt.task_type_id;
        l_user_task_type_id(i) := rec_wwtt.user_task_type_id;
        i := i + 1;

        --If updating a bulk tasks, update the children tasks also.
        --Condition to check if it's a bulk task is with the
        --num_of_child_task column.
        --Bulk task should always have children tasks
        IF rec_wwtt.num_of_child_tasks IS NOT NULL AND
           rec_wwtt.num_of_child_tasks > 0 THEN
          FOR bulk_children IN bulk_children_tasks_cur(l_transaction_temp_id_table(i - 1)) LOOP
            l_transaction_temp_id_table(i) := bulk_children.transaction_temp_id;

            l_wms_task_status_table(i) := rec_wwtt.status_id;
            l_task_priority_table(i) := rec_wwtt.priority;
            l_person_id_table(i) := rec_wwtt.person_id;
            l_person_resource_id_table(i) := rec_wwtt.person_resource_id;
            l_effective_start_date_table(i) := sysdate; -- rec_wwtt.effective_start_date; --bug#6409956
            l_effective_end_date_table(i) := sysdate; --rec_wwtt.effective_end_date; --bug#6409956
            l_task_type_id(i) := rec_wwtt.task_type_id;
            l_user_task_type_id(i) := rec_wwtt.user_task_type_id; -- R12: Update User Task Type Id
            i := i + 1;
            l_children_task_count := l_children_task_count + 1;
          END LOOP;
        END IF;
        --/bulk picking
      EXCEPTION
        WHEN record_locked THEN
          NULL;
        WHEN NO_DATA_FOUND THEN
          NULL;
      END;
    END LOOP;

    x_save_count := x_save_count + l_transaction_temp_id_table.COUNT -
                    l_children_task_count;

    if l_debug = 1 then
      print_DEBUG('Save Count is ' || x_save_count, l_debug);
    end if;

    -- IF l_transaction_temp_id_table.COUNT > 0 THEN
    IF x_save_count > 0 THEN
      if l_debug = 1 then
        print_DEBUG('Save Count is ' || x_save_count, l_debug);
      end if;

      IF l_non_cycle_count_number > 0 THEN
        FORALL i IN l_transaction_temp_id_table.FIRST .. l_transaction_temp_id_table.LAST
          UPDATE mtl_material_transactions_temp
             SET wms_task_status       = DECODE(l_wms_task_status_table(i),
                                                8,
                                                8,
                                                1,
                                                1,
                                                NULL),
                 task_priority         = l_task_priority_table(i),
                 last_update_date      = SYSDATE,
                 last_updated_by       = p_user_id,
                 last_update_login     = p_login_id,
                 standard_operation_id = l_user_task_type_id(i)
           WHERE transaction_temp_id = l_transaction_temp_id_table(i) -- R12: Update User Task Type Id
             AND l_task_type_id(i) <> 3;
        if l_debug = 1 then
          print_DEBUG('No of records updated are-777 ' || SQL%ROWCOUNT,
                      l_debug);
        end if;
      END IF;

      -- Delete WDT line for tasks that were queued but now are pending or unreleased
      DELETE wms_dispatched_tasks wdt
       WHERE wdt.status IN (2, 3, 9) -- R12: Delete the Active or Dispatched tasks which were updated to pending/Unreleased
         AND wdt.transaction_temp_id IN
             (SELECT transaction_temp_id
                FROM wms_wp_tasks_gtmp wwtt
               WHERE wwtt.status_id IN (1, 8)
                 AND wwtt.is_modified = 'Y');
      if l_debug = 1 then
        print_DEBUG('No of records deleted are-555 ' || SQL%ROWCOUNT,
                    l_debug);
      end if;

      l_update_date := SYSDATE;
      if l_debug = 1 then
        print_DEBUG('inserting into WDT ' || x_save_count, l_debug);
      end if;

      -- Insert into WDT tasks that have become queued from pending or unreleased
      INSERT INTO wms_dispatched_tasks
        (task_id,
         transaction_temp_id,
         organization_id,
         user_task_type,
         person_id,
         effective_start_date,
         effective_end_date,
         person_resource_id,
         machine_resource_id,
         status,
         dispatched_time,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by,
         last_update_login,
         task_type,
         priority,
         move_order_line_id,
         operation_plan_id,
         transfer_lpn_id)
        (SELECT wwtt.task_id,
                wwtt.transaction_temp_id,
                wwtt.organization_id,
                NVL(wwtt.user_task_type_id, 0),
                wwtt.person_id,
                sysdate,
                sysdate,
                wwtt.person_resource_id,
                NULL,
                2, -- Queued
                NULL,
                l_update_date,
                p_user_id,
                l_update_date,
                p_user_id,
                p_login_id,
                wwtt.task_type_id,
                wwtt.priority,
                wwtt.move_order_line_id,
                wwtt.operation_plan_id,
                wwtt.to_lpn_id
           FROM wms_wp_tasks_gtmp wwtt
          WHERE wwtt.status_id = 2
            AND wwtt.status_id_original IN (1, 8)
            AND wwtt.is_modified = 'Y'
            AND NOT EXISTS
          (SELECT 1
                   FROM wms_dispatched_tasks wdt
                  WHERE wdt.transaction_temp_id = wwtt.transaction_temp_id));
      if l_debug = 1 then
        print_DEBUG('No of records inserted are-444 ' || SQL%ROWCOUNT,
                    l_debug);
      end if;
      --  forall i IN l_transaction_temp_id_table.first..l_transaction_temp_id_table.last
      FORALL i IN 1 .. l_transaction_temp_id_table.COUNT
        UPDATE wms_dispatched_tasks
           SET person_id            = l_person_id_table(i),
               person_resource_id   = l_person_resource_id_table(i),
               effective_start_date = l_effective_start_date_table(i),
               effective_end_date   = l_effective_end_date_table(i),
               priority             = l_task_priority_table(i),
               last_update_date     = l_update_date,
               last_updated_by      = p_user_id,
               last_update_login    = p_login_id
         WHERE transaction_temp_id = l_transaction_temp_id_table(i);
      if l_debug = 1 then
        print_DEBUG('No of records updated are-333 ' || SQL%ROWCOUNT,
                    l_debug);
        print_DEBUG('Commiting ', l_debug);
      end if;

      IF g_task_saved IS NULL THEN
        fnd_message.set_name('WMS', 'WMS_TASK_SAVED');
        g_task_saved := fnd_message.get;
      END IF;

      --  forall i IN l_transaction_temp_id_table.first..l_transaction_temp_id_table.last
      FORALL i IN 1 .. l_transaction_temp_id_table.COUNT
        UPDATE wms_wp_tasks_gtmp
           SET RESULT                = 'S',
               error                 = g_task_saved,
               is_modified           = 'N',
               person_id_original    = l_person_id_table(i),
               status_id_original    = l_wms_task_status_table(i),
               priority_original     = l_task_priority_table(i),
               mmtt_last_updated_by  = p_user_id,
               mmtt_last_update_date = l_update_date,
               wdt_last_updated_by   = DECODE(l_wms_task_status_table(i),
                                              1,
                                              NULL,
                                              8,
                                              NULL,
                                              p_user_id),
               wdt_last_update_date  = TO_DATE(DECODE(l_wms_task_status_table(i),
                                                      1,
                                                      NULL,
                                                      8,
                                                      NULL,
                                                      TO_CHAR(l_update_date,
                                                              'DD-MON-YY HH24:MI:SS')),
                                               'DD-MON-YY HH24:MI:SS')
         WHERE transaction_temp_id = l_transaction_temp_id_table(i);
      if l_debug = 1 then
        print_DEBUG('No of records updated are-222 ' || SQL%ROWCOUNT,
                    l_debug);
      end if;
    END IF;

    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    l_error_message := fnd_message.get;

    UPDATE wms_wp_tasks_gtmp
       SET RESULT = 'E', error = l_error_message
     WHERE is_modified = 'Y';

    if l_debug = 1 then
      print_DEBUG('No of records updated are-111 ' || SQL%ROWCOUNT,
                  l_debug);
    end if;

    /* Bug 5507934 */
    IF p_commit THEN
      if l_debug = 1 then
        print_DEBUG('Commiting the record', l_debug);
      end if;
      COMMIT;
    END IF;
    /* End of 5507934 */
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO save_tasks;
      x_return_status := 'U';
      x_msg_data      := SQLERRM;
      print_DEBUG('SQL error: ' || SQLERRM, l_debug);
  END save_tasks;

  FUNCTION getforcesignonflagvalue(p_transaction_temp_id IN mtl_material_transactions_temp.transaction_temp_id%TYPE,
                                   p_device_id           OUT NOCOPY NUMBER)
    RETURN VARCHAR2 IS
    l_force_sign_on wms_devices_b.force_sign_on_flag%TYPE;
  BEGIN
    SELECT wms_task_dispatch_device.get_eligible_device(mmtt.organization_id,
                                                        mmtt.subinventory_code,
                                                        mmtt.locator_id)
      INTO p_device_id
      FROM mtl_material_transactions_temp mmtt
     WHERE mmtt.transaction_temp_id = p_transaction_temp_id;

    SELECT force_sign_on_flag
      INTO l_force_sign_on
      FROM wms_devices_b
     WHERE device_id = p_device_id;

    RETURN l_force_sign_on;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 'N';
  END getforcesignonflagvalue;

  PROCEDURE set_num_of_child_tasks IS
    l_debug    NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    l_progress NUMBER;

    TYPE num_of_child_tasks_type IS TABLE OF wms_wp_tasks_gtmp.num_of_child_tasks%TYPE;
    l_num_of_child_tasks_tbl num_of_child_tasks_type;
    l_parent_temp_ids_tbl    wms_wave_planning_pvt.transaction_temp_table_type;
  BEGIN
    IF l_debug = 1 THEN
      print_DEBUG('set_num_of_child_tasks entered ' ||
                  TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),
                  l_debug);
    END IF;

    l_progress := 10;

    --MMTT used to get children task.
    --wwtt used to get the parent task.
    SELECT COUNT(1), wwtt.transaction_temp_id BULK COLLECT
      INTO l_num_of_child_tasks_tbl, l_parent_temp_ids_tbl
      FROM wms_wp_tasks_gtmp wwtt, mtl_material_transactions_temp mmtt
     WHERE wwtt.transaction_temp_id = mmtt.parent_line_id
       AND wwtt.transaction_temp_id <> mmtt.transaction_temp_id
     GROUP BY wwtt.transaction_temp_id;

    l_progress := 20;

    IF l_num_of_child_tasks_tbl.COUNT > 0 THEN
      l_progress := 30;
      FORALL i IN l_num_of_child_tasks_tbl.FIRST .. l_num_of_child_tasks_tbl.LAST
        UPDATE wms_wp_tasks_gtmp wwtt
           SET wwtt.num_of_child_tasks = l_num_of_child_tasks_tbl(i)
         WHERE wwtt.transaction_temp_id = l_parent_temp_ids_tbl(i);
      l_progress := 40;
    END IF;

    l_progress := 50;

    IF l_debug = 1 THEN
      print_DEBUG('set_num_of_child_tasks exited ' ||
                  TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),
                  l_debug);
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      --no parent bulk task
      IF l_debug = 1 THEN
        print_DEBUG('set_num_of_child_tasks no_data_found after l_progress ' ||
                    l_progress,
                    l_debug);

        IF l_progress = 10 THEN
          print_DEBUG('set_num_of_child_tasks exited normally with no parent ' ||
                      'task found ' ||
                      TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),
                      l_debug);
        END IF;
      END IF;
    WHEN OTHERS THEN
      IF l_debug = 1 THEN
        print_DEBUG('set_num_of_child_tasks OTHERS exception after l_progress ' ||
                    l_progress,
                    l_debug);
      END IF;
  END set_num_of_child_tasks;

  --Get Completion Status
  --This Procedure is being called by Wave Planning Track Completion Status Concurrent Program.
  --E -  Replenishment Requested
  --F -- Replenishment Completed
  /*We are mark Completed ...after all WDDs are staged
  then we mark Wave Closed...after all WDDs are shipped  (We are introducing one more status Wave Status = 'Closed')
  */

  PROCEDURE Update_Completion_Status_CP(errbuf  OUT NOCOPY VARCHAR2,
                                        retcode OUT NOCOPY NUMBER)

   is
    --Cursor to find whether the wave lines in Released Status are staged.

    cursor c_waves is
      select wwh.wave_header_id
        from wms_wp_wave_headers_vl wwh,
             (select wave_header_id, count(1) count_lines
                from wms_wp_wwb_lines_v
               where nvl(remove_from_wave_flag, 'N') = 'N'
               group by wave_header_id) wwlv,
             (select count(1) count_completed_lines, wave_header_id
                from wms_wp_wwb_lines_v
               where line_progress_id >= 8
                 and nvl(remove_from_wave_flag, 'N') = 'N'
               group by wave_header_id) wwlv1
       where wwh.wave_header_id = wwlv.wave_header_id
         and wwh.wave_status = 'Released'
         and wwlv.count_lines = wwlv1.count_completed_lines
         and wwlv.wave_header_id = wwlv1.wave_header_id;
    /*
    select wwh.wave_header_id
      from wms_wp_wave_lines    wwl,
           wms_wp_wave_headers_vl  wwh,
           wsh_delivery_details wdd
     where wwh.wave_header_id = wwl.wave_header_id
       and WWL.DELIVERY_DETAIL_ID = WDD.DELIVERY_DETAIL_ID
       and wwh.wave_status = 'Released'
       and wdd.released_status NOT in ('E', 'S', 'F')
     group by wwh.wave_header_id; */

    x_return_status varchar2(10);
    l_debug         NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

  begin

    savepoint check_completed_status_sp;

    -- Updating the Wave Status if all the lines in that Wave are Completed.

    for l_waves in c_waves loop

      print_debug('Completion Status for Wave : ' ||
                  l_waves.wave_header_id,
                  l_debug);

      update wms_wp_wave_headers_vl
         set wave_status = 'Completed', wave_Completion_time = sysdate -- should we change the column name to Wave Completion Date
       where wave_header_id = l_waves.wave_header_id;

      update wms_wp_wave_lines
         set pick_fill_rate = 100
       where wave_header_id = l_waves.wave_header_id;

      -- Need to check whether the wave can be closed or not
      print_debug('Making Pick Fill Rate For the Wave : ' ||
                  l_waves.wave_header_id || ' as 100',
                  l_debug);
      --  commit;

    end loop;

    -- Call to Calculate Pick Fill Rate for Released but not completed Lines

    wms_wave_planning_pvt.get_pick_fill_rate(x_return_status);

    if x_return_Status = 'S' then
      print_debug('Checking whether the wave can be closed. Call Check_wave_closed_status API : ',
                  l_debug);

      wms_wave_planning_pvt.Check_wave_closed_status(x_return_status);
    else

      RAISE fnd_api.g_exc_error;

    end if;

    if x_return_Status <> 'S' then

      RAISE fnd_api.g_exc_error;

    end if;

    commit;

  exception

    when others then

      print_debug('Error in update completion status : ' || SQLCODE ||
                  ' : ' || SQLERRM,
                  l_debug);

      rollback to check_completed_status_sp;

      RAISE fnd_api.g_exc_unexpected_error;
  end Update_Completion_Status_CP;

  procedure Check_wave_closed_status(x_return_status OUT NOCOPY varchar2)

   is
    -- Cursor change to the base table and compare wave line count with lines in wdd status shipped in a wave.  Ajith?????
    cursor c_completed_waves is
      select wwh.wave_header_id
        from wms_wp_wave_headers_vl wwh,
             (select wave_header_id, count(1) count_lines
                from wms_wp_wwb_lines_v
               where nvl(remove_from_wave_flag, 'N') = 'N'
               group by wave_header_id) wwlv,
             (select count(1) count_completed_lines, wave_header_id
                from wms_wp_wwb_lines_v
               where line_progress_id = 11
                 and nvl(remove_from_wave_flag, 'N') = 'N'
               group by wave_header_id) wwlv1
       where wwh.wave_header_id = wwlv.wave_header_id
         and wwh.wave_status in ('Completed', 'Released') -- Adding released status if direct ship is done lines will be in shipped directly
         and wwlv.count_lines = wwlv1.count_completed_lines
         and wwlv.wave_header_id = wwlv1.wave_header_id;

    l_debug           NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    l_wave_header_tbl num_tab;
    i                 number := 0;
  begin
    -- Here do Bulk Update Ajith?????

    for l_waves in c_completed_waves loop

      print_debug('Closed Status for Wave : ' || l_waves.wave_header_id,
                  l_debug);

      l_wave_header_tbl(i) := l_waves.wave_header_id;
      i := i + 1;

    end loop;

    --  commit;
    if l_wave_header_tbl.count > 0 then
      forall k in l_wave_header_tbl.FIRST .. l_wave_header_tbl.LAST
        update wms_wp_wave_headers_vl
           set wave_status = 'Closed' -- should we change the column name to Wave Completion Date
         where wave_header_id = l_wave_header_tbl(k);

    end if;

    x_return_status := 'S';

  exception

    when others then

      x_return_status := 'E';

      print_debug('Error in check wave closed status : ' || SQLCODE ||
                  ' : ' || SQLERRM,
                  l_debug);

  end Check_wave_closed_status;

  --Get_pick_fill_rate

  procedure get_pick_fill_rate(x_return_status OUT NOCOPY varchar2)

   is
    -- Pick Fill Rate for Backordered / Replenishment Requested Status is 0.
    -- We calculate the Pick Fill Rate for Released lines by (sum(completed transaction qty) / requested qty ) *100.

    -- Transaction Qty should be converted to primary uom

    cursor c_waves is
      select wwh.wave_header_id,
             wdd.delivery_detail_id,
             Decode(wdd.released_status,
                    'Y',
                    (((get_conversion_rate(wdd.inventory_item_id,
                                           wwtv.transaction_uom,
                                           wdd.requested_quantity_uom) *
                    wwtv.transaction_quantity) / wwl.requested_quantity) * 100),
                    'B',
                    0,
                    'E',
                    0) pick_fill_rate,
             wwl.requested_quantity,
             wwtv.transaction_quantity
        from wms_wp_wave_lines      wwl,
             wms_wp_wave_headers_vl wwh,
             wsh_delivery_details   wdd,
             wms_wp_wwb_tasks_v     wwtv
       where wwh.wave_header_id = wwl.wave_header_id
         and WWL.DELIVERY_DETAIL_ID = WDD.DELIVERY_DETAIL_ID
         AND WDD.source_line_id = wwtv.transaction_source_line_id(+)
         and (wwh.wave_status = 'Released' and
             wwh.wave_status <> 'Completed')
         and nvl(wwl.remove_from_wave_flag, 'N') = 'N'
         and wdd.released_status in ('B', 'E', 'Y');

    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

  begin

    for l_waves in c_waves loop
      print_debug('Pick Fill Rate for Wave : ' || l_waves.wave_header_id,
                  l_debug);
      print_debug('Pick Fill Rate for Delivery Detail Id : ' ||
                  l_waves.delivery_detail_id || 'is ' ||
                  l_waves.pick_fill_rate,
                  l_debug);
      update wms_wp_wave_lines
         set pick_fill_rate = l_waves.pick_fill_rate
       where delivery_Detail_id = l_waves.delivery_detail_id
         and wave_header_id = l_waves.wave_header_id;
      --   commit;

    end loop;

    x_return_status := 'S';
  EXCEPTION
    WHEN OTHERS THEN
      print_debug('Error : ' || SQLCODE || ' : ' || SQLERRM, l_debug);
      x_return_status := FND_API.G_RET_STS_ERROR;

  end get_pick_fill_rate;

  function get_loaded_status(p_Delivery_Detail_id in number) return number

   is
    v_loaded number := 0;
    v_total  number := 0;
    v_status number := 0;
    l_debug  NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

  begin

    SELECT Sum(Decode(mmtt.wms_task_status, 4, 1, 0)) loaded,
           Count(1) total_tasked
      into v_loaded, v_total
      FROM wsh_delivery_details wdd, mtl_material_transactions_temp mmtt
     WHERE wdd.delivery_detail_id = p_Delivery_Detail_id
       AND wdd.source_line_id = mmtt.trx_source_line_id;

    if v_loaded < v_total and v_loaded >= 1 then

      v_status := 1; -- Partially Loaded

    elsif v_loaded = v_total then
      v_status := 2; -- Loaded

    end if;

    return v_status;

  exception

    when others then

      print_debug('Error in get Loaded Status ' || SQLCODE || SQLERRM,
                  l_Debug);

      return - 1;

  end get_loaded_status;

  PROCEDURE catch_wave_exceptions_cp(errbuf                         OUT nocopy VARCHAR2,
                                     retcode                        OUT nocopy NUMBER,
                                     p_exception_name               IN VARCHAR2,
                                     p_organization_id              IN NUMBER,
                                     p_wave                         IN NUMBER,
                                     p_exception_entity             IN VARCHAR2,
                                     p_progress_stage               IN VARCHAR2,
                                     p_completion_threshold         IN NUMBER,
                                     p_high_sev_exception_threshold IN NUMBER,
                                     p_low_sev_exception_threshold  IN NUMBER,
                                     p_take_corrective_measures     IN VARCHAR2,
                                     p_release_back_ordered_lines   IN VARCHAR2,
                                     p_action_name                  IN VARCHAR2) IS

    l_total_lines            NUMBER;
    l_perfect_lines          NUMBER;
    l_progress_stage         NUMBER;
    l_temp_previous_order_id NUMBER DEFAULT NULL;
    l_temp_previous_line_id  NUMBER DEFAULT NULL;
    l_exception_id           NUMBER := -1;
    l_previous_order_id      NUMBER;
    l_previous_line_id       NUMBER;
    l_debug                  NUMBER := nvl(fnd_profile.VALUE('INV_DEBUG_TRACE'),
                                           0);

    l_api_is_implemented BOOLEAN;
    l_return_status      varchar2(30);
    l_msg_count          varchar2(100);
    l_msg_data           varchar2(100);

    -- cursor c_get_waves fetches wave if wave id is given else all the waves in released status.
    -- cursor also fetches the date scheduled for that particular wave.
    CURSOR c_get_waves IS
      SELECT DISTINCT wwl.wave_header_id,
                      MIN(nvl(wdab.end_time,
                              (nvl(wts.planned_arrival_date,
                                   nvl(wnd.earliest_pickup_date,
                                       wdd.date_scheduled))))) date_scheduled
        FROM wms_wp_wave_lines wwl,
             wsh_delivery_details wdd,
             (SELECT wave_header_id wave_id
                FROM wms_wp_wave_headers_vl
               WHERE ((wave_header_id = p_wave) AND
                     LOWER(wave_status) in ('released', 'completed'))
                  OR (p_wave IS NULL AND
                     LOWER(wave_status) in ('released', 'completed'))) wwh,
             wsh_delivery_assignments wda,
             wsh_delivery_legs wdl,
             wsh_new_deliveries wnd,
             wsh_trip_stops wts,
             wms_dock_appointments_b wdab
       WHERE wwl.wave_header_id = wwh.wave_id
         AND wwl.delivery_detail_id = wdd.delivery_detail_id
         AND wdd.delivery_detail_id = wda.delivery_detail_id
         AND wda.delivery_id = wnd.delivery_id(+)
         AND wnd.delivery_id = wdl.delivery_id(+)
         AND wdl.pick_up_stop_id = wts.stop_id(+)
         AND wts.stop_id = wdab.trip_stop(+)
         AND wdd.organization_id = p_organization_id
       GROUP BY wwl.wave_header_id;

    -- cursor def for getting trips and corresponding date scheduled of a particular wave.
    CURSOR c_get_trips(p_wave_id NUMBER) IS
      SELECT DISTINCT wts.trip_id,
                      nvl(wdab.end_time, wts.planned_arrival_date) date_scheduled
        FROM wms_wp_wave_lines        wwl,
             wsh_delivery_details     wdd,
             wsh_delivery_assignments wda,
             wsh_delivery_legs        wdl,
             wsh_new_deliveries       wnd,
             wsh_trip_stops           wts,
             wms_dock_appointments_b  wdab
       WHERE wwl.wave_header_id = p_wave_id
         AND wwl.delivery_detail_id = wdd.delivery_detail_id
         AND wdd.delivery_detail_id = wda.delivery_detail_id
         AND wda.delivery_id = wnd.delivery_id(+)
         AND wnd.delivery_id = wdl.delivery_id(+)
         AND wdl.pick_up_stop_id = wts.stop_id(+)
         AND wts.trip_id IS NOT NULL
         AND wts.stop_id = wdab.trip_stop(+)
         AND wdd.organization_id = p_organization_id;

    -- cursor def for getting deliveries and corresponding date scheduled of a particular wave.
    CURSOR c_get_deliveries(p_wave_id NUMBER) IS
      SELECT DISTINCT wts.trip_id,
                      wda.delivery_id,
                      nvl(wdab.end_time,
                          (nvl(wts.planned_arrival_date,
                               wnd.earliest_pickup_date))) date_scheduled
        FROM wms_wp_wave_lines        wwl,
             wsh_delivery_details     wdd,
             wsh_delivery_assignments wda,
             wsh_delivery_legs        wdl,
             wsh_new_deliveries       wnd,
             wsh_trip_stops           wts,
             wms_dock_appointments_b  wdab
       WHERE wwl.wave_header_id = p_wave_id
         AND wwl.delivery_detail_id = wdd.delivery_detail_id
         AND wdd.delivery_detail_id = wda.delivery_detail_id
         AND wda.delivery_id IS NOT NULL
         AND wda.delivery_id = wnd.delivery_id(+)
         AND wnd.delivery_id = wdl.delivery_id(+)
         AND wdl.pick_up_stop_id = wts.stop_id(+)
         AND wts.stop_id = wdab.trip_stop(+)
         AND wdd.organization_id = p_organization_id;

    -- cursor def for getting orders and corresponding date scheduled that belong to particular wave.
    CURSOR c_get_so(p_wave_id NUMBER) IS
      SELECT DISTINCT wts.trip_id,
                      wda.delivery_id,
                      shi.source_header_id,
                      shi.date_scheduled,
                      wdd.source_header_number
        FROM (SELECT wdd.source_header_id,
                     MIN(nvl(wdab.end_time,
                             (nvl(wts.planned_arrival_date,
                                  nvl(wnd.earliest_pickup_date,
                                      wdd.date_scheduled))))) date_scheduled
                FROM wms_wp_wave_lines        wwl,
                     wsh_delivery_details     wdd,
                     wsh_delivery_assignments wda,
                     wsh_delivery_legs        wdl,
                     wsh_new_deliveries       wnd,
                     wsh_trip_stops           wts,
                     wms_dock_appointments_b  wdab
               WHERE wwl.wave_header_id = p_wave_id
                 AND wwl.delivery_detail_id = wdd.delivery_detail_id
                 AND wdd.delivery_detail_id = wda.delivery_detail_id
                 AND wda.delivery_id = wnd.delivery_id(+)
                 AND wnd.delivery_id = wdl.delivery_id(+)
                 AND wdl.pick_up_stop_id = wts.stop_id(+)
                 AND wts.stop_id = wdab.trip_stop(+)
                 AND wdd.organization_id = p_organization_id
               GROUP BY wdd.source_header_id) shi,
             wsh_delivery_details wdd,
             wsh_delivery_assignments wda,
             wsh_delivery_legs wdl,
             wsh_new_deliveries wnd,
             wsh_trip_stops wts
       WHERE wdd.source_header_id = shi.source_header_id
         AND wdd.delivery_detail_id = wda.delivery_detail_id
         AND wda.delivery_id = wnd.delivery_id(+)
         AND wnd.delivery_id = wdl.delivery_id(+)
         AND wdl.pick_up_stop_id = wts.stop_id(+)
       ORDER BY shi.source_header_id;
    -- Don't remove this order by.. Usefull for check_so procedure

    -- cursor def for getting all the lines and corresponding date scheduled in a particular wave.
    CURSOR c_get_lines(p_wave_id NUMBER) IS
      SELECT DISTINCT wts.trip_id,
                      wda.delivery_id,
                      shi.source_line_id,
                      shi.date_scheduled,
                      wdd.source_header_number
        FROM (SELECT wdd.source_line_id,
                     MIN(nvl(wdab.end_time,
                             (nvl(wts.planned_arrival_date,
                                  nvl(wnd.earliest_pickup_date,
                                      wdd.date_scheduled))))) date_scheduled
                FROM wms_wp_wave_lines        wwl,
                     wsh_delivery_details     wdd,
                     wsh_delivery_assignments wda,
                     wsh_delivery_legs        wdl,
                     wsh_new_deliveries       wnd,
                     wsh_trip_stops           wts,
                     wms_dock_appointments_b  wdab
               WHERE wwl.wave_header_id = p_wave_id
                 AND wwl.delivery_detail_id = wdd.delivery_detail_id
                 AND wdd.delivery_detail_id = wda.delivery_detail_id
                 AND wda.delivery_id = wnd.delivery_id(+)
                 AND wnd.delivery_id = wdl.delivery_id(+)
                 AND wdl.pick_up_stop_id = wts.stop_id(+)
                 AND wts.stop_id = wdab.trip_stop(+)
                 AND wdd.organization_id = p_organization_id
               GROUP BY wdd.source_line_id) shi,
             wms_wp_wave_lines wwl,
             wsh_delivery_details wdd,
             wsh_delivery_assignments wda,
             wsh_delivery_legs wdl,
             wsh_new_deliveries wnd,
             wsh_trip_stops wts
       WHERE wdd.source_line_id = shi.source_line_id
         AND wdd.delivery_detail_id = wwl.delivery_detail_id
         AND wdd.delivery_detail_id = wda.delivery_detail_id
         AND wda.delivery_id = wnd.delivery_id(+)
         AND wnd.delivery_id = wdl.delivery_id(+)
         AND wdl.pick_up_stop_id = wts.stop_id(+)
       order by shi.source_line_id;
    /* SELECT DISTINCT wts.trip_id,
                   wda.delivery_id,
                   wdd.delivery_detail_id, -- using delivery detail id instead of source line id.
                   wdd.source_header_number,
                   nvl(wdab.end_time,
                       (nvl(wts.planned_arrival_date,
                            nvl(wnd.earliest_pickup_date,
                                wdd.date_scheduled)))) date_scheduled
     FROM wms_wp_wave_lines        wwl,
          wsh_delivery_details     wdd,
          wsh_delivery_assignments wda,
          wsh_delivery_legs        wdl,
          wsh_new_deliveries       wnd,
          wsh_trip_stops           wts,
          wms_dock_appointments_b  wdab
    WHERE wwl.wave_header_id = p_wave_id
      AND wwl.delivery_detail_id = wdd.delivery_detail_id
      AND wdd.delivery_detail_id = wda.delivery_detail_id
      AND wda.delivery_id = wnd.delivery_id(+)
      AND wnd.delivery_id = wdl.delivery_id(+)
      AND wdl.pick_up_stop_id = wts.stop_id(+)
      AND wts.stop_id = wdab.trip_stop(+)
      AND wdd.organization_id = p_organization_id
      and nvl(wwl.remove_from_Wave_flag, 'N') <> 'Y';*/

    l_progress  NUMBER;
    l_exception VARCHAR2(1) := 'N';

  BEGIN
    wms_wp_custom_apis_pub.Get_wave_exceptions_cust(x_api_is_implemented           => l_api_is_implemented,
                                                    p_exception_name               => p_exception_name,
                                                    p_organization_id              => p_organization_id,
                                                    p_wave                         => p_wave,
                                                    p_exception_entity             => p_exception_entity,
                                                    p_progress_stage               => p_progress_stage,
                                                    p_completion_threshold         => p_completion_threshold,
                                                    p_high_sev_exception_threshold => p_high_sev_exception_threshold,
                                                    p_low_sev_exception_threshold  => p_low_sev_exception_threshold,
                                                    p_take_corrective_measures     => p_take_corrective_measures,
                                                    p_release_back_ordered_lines   => p_release_back_ordered_lines,
                                                    p_action_name                  => p_action_name,
                                                    x_return_status                => l_return_status,
                                                    x_msg_count                    => l_msg_count,
                                                    x_msg_data                     => l_msg_data);

    IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      print_debug('Error returned from Get_wave_exceptions_cust in api catch_wave_exceptions_cp ',
                  l_debug);
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      print_debug('Unexpected errror from Get_wave_exceptions_cust api in catch_wave_exceptions_cp ',
                  l_debug);
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF l_api_is_implemented THEN
      print_debug('Custom API Implemented for create exceptions ', l_debug);
      /*print_debug('take_corrective_measure is ' || p_take_corrective_measures, l_debug);
      IF (p_take_corrective_measures = 'Yes') THEN
              -- call api to take corrective measures
              take_corrective_measures(l_exception_id,
                                       p_wave_id,
                                       p_entity,
                                       p_entity_value,
                                       p_release_back_ordered_lines,
                                       p_action_name,
                                       p_organization_id);

      END IF;
      */
    else

      IF (p_progress_stage = 'Ready to Release') THEN
        l_progress_stage := 1;
      ELSIF (p_progress_stage = 'Backordered') THEN
        l_progress_stage := 2;
      ELSIF (p_progress_stage = 'Crossdock Planned') THEN
        l_progress_stage := 3;
      ELSIF (p_progress_stage = 'Replenishment Planned') THEN
        l_progress_stage := 4;
      ELSIF (p_progress_stage = 'Tasked') THEN
        l_progress_stage := 5;
      ELSIF (p_progress_stage = 'Picked') THEN
        l_progress_stage := 7; -- skipping 6 here, as it is used for partially loaded in wms_wp_wwb_lines_v
      ELSIF (p_progress_stage = 'Packed') THEN
        l_progress_stage := 9;
      ELSIF (p_progress_stage = 'Staged') THEN
        l_progress_stage := 8;
      ELSIF (p_progress_stage = 'Loaded to Dock') THEN
        l_progress_stage := 10;
      END IF;

      print_debug('Entity is ' || p_exception_entity, l_debug);
      print_debug('p_progress Stage is ' || p_progress_stage, l_debug);
      print_debug('l_Progress Stage is ' || l_progress_stage, l_debug);

      FOR l_get_waves IN c_get_waves LOOP

        IF (p_exception_entity = 'Wave') THEN
          print_debug('Entity: Wave; Wave id: ' ||
                      l_get_waves.wave_header_id,
                      l_debug);
          print_debug('Entity: Wave; Date_Scheduled: ' ||
                      l_get_waves.date_scheduled,
                      l_debug);

          l_exception := 'N';

          BEGIN

            -- used to find if any record exists in the wms_wave_exceptions table for this wave.
            -- if it exists fetches the corresponding exception_id else fetches -1.
            l_exception_id := -1;
            SELECT exception_id
              INTO l_exception_id
              FROM wms_wp_wave_exceptions_vl
             WHERE wave_header_id = l_get_waves.wave_header_id
               AND exception_entity = p_exception_entity
               AND exception_stage = p_progress_stage
               AND LOWER(status) <> 'closed';

          EXCEPTION
            WHEN no_data_found THEN
              l_exception_id := -1;
          END;

          print_debug('l_exception_id :=' || l_exception_id, l_debug);

          BEGIN

            SELECT Count(*),
                   Sum(CASE
                         WHEN line_progress_id >= l_progress_stage THEN
                          1
                         ELSE
                          0
                       END)
              INTO l_total_lines, l_perfect_lines
              FROM wms_wp_wwb_lines_v
             WHERE wave_header_id = l_get_waves.wave_header_id
               AND organization_id = p_organization_id
               and nvl(remove_from_Wave_flag, 'N') <> 'Y';

          EXCEPTION

            when others then
              l_exception := 'Y';

          END;

          if (l_exception = 'N') then

            actionable_exceptions(l_perfect_lines,
                                  l_total_lines,
                                  p_completion_threshold,
                                  p_low_sev_exception_threshold,
                                  p_high_sev_exception_threshold,
                                  l_get_waves.date_scheduled,
                                  l_exception_id,
                                  p_exception_name,
                                  l_get_waves.wave_header_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  l_previous_order_id,
                                  NULL,
                                  l_previous_line_id,
                                  p_exception_entity,
                                  l_get_waves.wave_header_id,
                                  p_progress_stage,
                                  p_take_corrective_measures,
                                  p_release_back_ordered_lines,
                                  p_action_name,
                                  p_organization_id);

          end if;

        ELSIF (p_exception_entity = 'Trip') THEN

          FOR l_get_trips IN c_get_trips(l_get_waves.wave_header_id) LOOP
            print_debug('wave_header_id ' || l_get_waves.wave_header_id,
                        l_debug);
            print_debug('trip_id ' || l_get_trips.trip_id, l_debug);
            print_debug('date_scheduled ' || l_get_trips.date_scheduled,
                        l_debug);

            l_exception := 'N';

            BEGIN

              -- used to find if any record exists in the wms_wave_exceptions table for this trip.
              -- if it exists fetches the corresponding exception_id else fetches -1.
              l_exception_id := -1;
              SELECT exception_id
                INTO l_exception_id
                FROM wms_wp_wave_exceptions_vl
               WHERE wave_header_id = l_get_waves.wave_header_id
                 AND exception_entity = p_exception_entity
                 AND exception_stage = p_progress_stage
                 AND trip_id = l_get_trips.trip_id
                 AND LOWER(status) <> 'closed';

            EXCEPTION
              WHEN no_data_found THEN
                l_exception_id := -1;
            END;

            print_debug('l_exception_id :=' || l_exception_id, l_debug);

            BEGIN

              SELECT Count(*),
                     Sum(CASE
                           WHEN line_progress_id >= l_progress_stage THEN
                            1
                           ELSE
                            0
                         END)
                INTO l_total_lines, l_perfect_lines
                FROM wms_wp_wwb_lines_v
               WHERE wave_header_id = l_get_waves.wave_header_id
                 AND TRIP = l_get_trips.trip_id
                 AND organization_id = p_organization_id
                 and nvl(remove_from_Wave_flag, 'N') <> 'Y';

            EXCEPTION

              when others then
                l_exception := 'Y';

            END;

            if (l_exception = 'N') then
              actionable_exceptions(l_perfect_lines,
                                    l_total_lines,
                                    p_completion_threshold,
                                    p_low_sev_exception_threshold,
                                    p_high_sev_exception_threshold,
                                    l_get_trips.date_scheduled,
                                    l_exception_id,
                                    p_exception_name,
                                    l_get_waves.wave_header_id,
                                    l_get_trips.trip_id,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    l_previous_order_id,
                                    NULL,
                                    l_previous_line_id,
                                    p_exception_entity,
                                    l_get_trips.trip_id,
                                    p_progress_stage,
                                    p_take_corrective_measures,
                                    p_release_back_ordered_lines,
                                    p_action_name,
                                    p_organization_id);

            end if;
          END LOOP;

        ELSIF (p_exception_entity = 'Delivery') THEN
          FOR l_get_deliveries IN c_get_deliveries(l_get_waves.wave_header_id) LOOP
            print_debug('wave_header_id ' || l_get_waves.wave_header_id,
                        l_debug);
            print_debug('trip_id ' || l_get_deliveries.trip_id, l_debug);
            print_debug('delivery_id ' || l_get_deliveries.delivery_id,
                        l_debug);
            print_debug('date_scheduled ' ||
                        l_get_deliveries.date_scheduled,
                        l_debug);

            l_exception := 'N';

            BEGIN

              -- used to find if any record exists in the wms_wave_exceptions table for this delivery.
              -- if it exists fetches the corresponding exception_id else fetches -1.
              l_exception_id := -1;
              SELECT exception_id
                INTO l_exception_id
                FROM wms_wp_wave_exceptions_vl
               WHERE wave_header_id = l_get_waves.wave_header_id
                 AND exception_entity = p_exception_entity
                 AND exception_stage = p_progress_stage
                 AND delivery_id = l_get_deliveries.delivery_id
                 AND LOWER(status) <> 'closed';

            EXCEPTION
              WHEN no_data_found THEN
                l_exception_id := -1;
            END;

            print_debug('l_exception_id :=' || l_exception_id, l_debug);

            BEGIN

              SELECT Count(*),
                     Sum(CASE
                           WHEN line_progress_id >= l_progress_stage THEN
                            1
                           ELSE
                            0
                         END)
                INTO l_total_lines, l_perfect_lines
                FROM wms_wp_wwb_lines_v
               WHERE wave_header_id = l_get_waves.wave_header_id
                 AND delivery_id = l_get_deliveries.delivery_id
                 AND organization_id = p_organization_id
                 and nvl(remove_from_Wave_flag, 'N') <> 'Y';

            EXCEPTION

              when others then
                l_exception := 'Y';

            END;

            if (l_exception = 'N') then

              actionable_exceptions(l_perfect_lines,
                                    l_total_lines,
                                    p_completion_threshold,
                                    p_low_sev_exception_threshold,
                                    p_high_sev_exception_threshold,
                                    l_get_deliveries.date_scheduled,
                                    l_exception_id,
                                    p_exception_name,
                                    l_get_waves.wave_header_id,
                                    l_get_deliveries.trip_id,
                                    l_get_deliveries.delivery_id,
                                    NULL,
                                    NULL,
                                    NULL,
                                    l_previous_order_id,
                                    NULL,
                                    l_previous_line_id,
                                    p_exception_entity,
                                    l_get_deliveries.delivery_id,
                                    p_progress_stage,
                                    p_take_corrective_measures,
                                    p_release_back_ordered_lines,
                                    p_action_name,
                                    p_organization_id);

            end if;
          END LOOP;

        ELSIF (p_exception_entity = 'Order') THEN
          FOR l_get_so IN c_get_so(l_get_waves.wave_header_id) LOOP
            print_debug('wave_header_id ' || l_get_waves.wave_header_id,
                        l_debug);
            print_debug('trip_id ' || l_get_so.trip_id, l_debug);
            print_debug('delivery_id ' || l_get_so.delivery_id, l_debug);
            print_debug('Order number ' || l_get_so.source_header_number,
                        l_debug);
            print_debug('date_scheduled ' || l_get_so.date_scheduled,
                        l_debug);

            l_exception := 'N';

            BEGIN

              -- used to find if any record exists in the wms_wave_exceptions table for this Order.
              -- if it exists fetches the corresponding exception_id else fetches -1.
              l_exception_id := -1;
              SELECT exception_id
                INTO l_exception_id
                FROM wms_wp_wave_exceptions_vl
               WHERE wave_header_id = l_get_waves.wave_header_id
                 AND exception_entity = p_exception_entity
                 AND exception_stage = p_progress_stage
                 AND order_number = l_get_so.source_header_number
                 AND LOWER(status) <> 'closed';

            EXCEPTION
              WHEN no_data_found THEN
                l_exception_id := -1;
            END;

            print_debug('l_exception_id :=' || l_exception_id, l_debug);

            BEGIN

              SELECT Count(*),
                     Sum(CASE
                           WHEN line_progress_id >= l_progress_stage THEN
                            1
                           ELSE
                            0
                         END)
                INTO l_total_lines, l_perfect_lines
                FROM wms_wp_wwb_lines_v
               WHERE wave_header_id = l_get_waves.wave_header_id
                 AND source_header_id = l_get_so.source_header_id
                 AND organization_id = p_organization_id
                 and nvl(remove_from_Wave_flag, 'N') <> 'Y';

            EXCEPTION

              when others then

                l_exception := 'Y';

            END;

            if (l_exception = 'N') then

              l_previous_order_id := l_temp_previous_order_id;

              actionable_exceptions(l_perfect_lines,
                                    l_total_lines,
                                    p_completion_threshold,
                                    p_low_sev_exception_threshold,
                                    p_high_sev_exception_threshold,
                                    l_get_so.date_scheduled,
                                    l_exception_id,
                                    p_exception_name,
                                    l_get_waves.wave_header_id,
                                    l_get_so.trip_id,
                                    l_get_so.delivery_id,
                                    l_get_so.source_header_number,
                                    NULL,
                                    l_get_so.source_header_id,
                                    l_previous_order_id,
                                    NULL,
                                    l_previous_line_id,
                                    p_exception_entity,
                                    l_get_so.source_header_number,
                                    p_progress_stage,
                                    p_take_corrective_measures,
                                    p_release_back_ordered_lines,
                                    p_action_name,
                                    p_organization_id);

              l_temp_previous_order_id := l_previous_order_id;

            end if;
          END LOOP;

        ELSIF (p_exception_entity = 'Order Line') THEN
          FOR l_get_lines IN c_get_lines(l_get_waves.wave_header_id) LOOP
            print_debug('wave_header_id ' || l_get_waves.wave_header_id,
                        l_debug);
            print_debug('trip_id ' || l_get_lines.trip_id, l_debug);
            print_debug('delivery_id ' || l_get_lines.delivery_id, l_debug);
            print_debug('order number ' ||
                        l_get_lines.source_header_number,
                        l_debug);
            print_debug('line id ' || l_get_lines.source_line_id, l_debug);
            print_debug('date_scheduled ' || l_get_lines.date_scheduled,
                        l_debug);

            l_exception := 'N';

            BEGIN

              -- used to find if any record exists in the wms_wave_exceptions table for this trip.
              -- if it exists fetches the corresponding exception_id else fetches -1.
              l_exception_id := -1;
              SELECT exception_id
                INTO l_exception_id
                FROM wms_wp_wave_exceptions_vl
               WHERE wave_header_id = l_get_waves.wave_header_id
                 AND exception_entity = p_exception_entity
                 AND exception_stage = p_progress_stage
                 AND ORDER_LINE_ID = l_get_lines.source_line_id
                 AND LOWER(status) <> 'closed';

            EXCEPTION
              WHEN no_data_found THEN
                l_exception_id := -1;
            END;

            print_debug('l_exception_id :=' || l_exception_id, l_debug);

            BEGIN

              SELECT Count(*),
                     Sum(CASE
                           WHEN line_progress_id >= l_progress_stage THEN
                            1
                           ELSE
                            0
                         END)
                INTO l_total_lines, l_perfect_lines
                FROM wms_wp_wwb_lines_v
               WHERE wave_header_id = l_get_waves.wave_header_id
                 AND source_line_id = l_get_lines.source_line_id
                 AND organization_id = p_organization_id
                 and nvl(remove_from_Wave_flag, 'N') <> 'Y';

            EXCEPTION

              when others then
                l_exception := 'Y';

            END;

            if (l_exception = 'N') then
              actionable_exceptions(l_perfect_lines,
                                    l_total_lines,
                                    p_completion_threshold,
                                    p_low_sev_exception_threshold,
                                    p_high_sev_exception_threshold,
                                    l_get_lines.date_scheduled,
                                    l_exception_id,
                                    p_exception_name,
                                    l_get_waves.wave_header_id,
                                    l_get_lines.trip_id,
                                    l_get_lines.delivery_id,
                                    l_get_lines.source_header_number,
                                    l_get_lines.source_line_id,
                                    NULL,
                                    l_previous_order_id,
                                    l_get_lines.source_line_id,
                                    l_previous_line_id,
                                    p_exception_entity,
                                    l_get_lines.source_line_id,
                                    p_progress_stage,
                                    p_take_corrective_measures,
                                    p_release_back_ordered_lines,
                                    p_action_name,
                                    p_organization_id);

            end if;
          END LOOP;
        END IF;

      END LOOP;
    end if;

  EXCEPTION
    WHEN others THEN
      print_debug('Unknown exception in Exceptions CP ' || SQLCODE || ':' ||
                  sqlerrm,
                  l_debug);
      RAISE fnd_api.g_exc_unexpected_error;
  END catch_wave_exceptions_cp;

  PROCEDURE insert_purge_exceptions(p_exception_name       VARCHAR2,
                                    p_exception_entity     VARCHAR2,
                                    p_exception_level      VARCHAR2,
                                    p_completion_threshold NUMBER,
                                    p_progress_stage       VARCHAR2,
                                    p_exception_threshold  NUMBER,
                                    p_wave_id              NUMBER,
                                    p_trip_id              NUMBER,
                                    p_delivery_id          NUMBER,
                                    p_order_number         NUMBER,
                                    p_order_line_id        NUMBER,
                                    x_return_status        OUT NOCOPY VARCHAR2) IS

    l_currval  NUMBER;
    l_msg      VARCHAR2(1000);
    l_addl_msg VARCHAR2(1000);
    l_debug    NUMBER := nvl(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    l_null     NUMBER := null;

  BEGIN

    -- Procedure inserts a record into the exceptions table
    print_debug('In insert_purge_exceptions procedure', l_debug);

    l_msg      := p_exception_level || ' exception for ' ||
                  p_exception_entity;
    l_addl_msg := '(' || p_completion_threshold || ' % lines are not ' ||
                  p_progress_stage || ' within ';
    l_addl_msg := l_addl_msg || p_exception_threshold ||
                  ' hours of shipment )';
    l_msg      := l_msg || l_addl_msg;

    print_debug('message for exception is : ' || l_msg, l_debug);

     SELECT wms_WP_WAVE_exceptions_s.NEXTVAL INTO l_seq_val FROM dual;     -- Changed

    WMS_WP_WAVE_EXCEPTIONS_PKG.INSERT_ROW(
                                          -- X_ROWID => l_null, --
                                          X_EXCEPTION_ID          => l_seq_val,
                                          X_EXCEPTION_ENTITY      => p_exception_entity,
                                          X_EXCEPTION_STAGE       => p_progress_stage,
                                          X_EXCEPTION_LEVEL       => p_exception_level,
                                          X_EXCEPTION_MSG         => l_msg,
                                          X_WAVE_HEADER_ID        => p_wave_id,
                                          X_TRIP_ID               => p_trip_id,
                                          X_DELIVERY_ID           => p_delivery_id,
                                          X_ORDER_NUMBER          => p_order_number,
                                          X_ORDER_LINE_ID         => p_order_line_id,
                                          X_STATUS                => 'Active',
                                          X_READY_TO_RELEASE      => null,
                                          X_BACKORDERED           => null,
                                          X_CROSSDOCK_PLANNED     => null,
                                          X_REPLENISHMENT_PLANNED => null,
                                          X_TASKED                => null,
                                          X_PICKED                => null,
                                          X_PACKED                => null,
                                          X_STAGED                => null,
                                          X_LOADED_TO_DOCK        => null,
                                          X_SHIPPED               => null,
                                          X_CONCURRENT_REQUEST_ID => fnd_global.conc_request_id,
                                          X_PROGRAM_ID            => fnd_global.conc_program_id, --
                                          X_EXCEPTION_NAME        => p_exception_name,
                                          X_CREATION_DATE         => sysdate,
                                          X_CREATED_BY            => fnd_global.user_id,
                                          X_LAST_UPDATE_DATE      => sysdate,
                                          X_LAST_UPDATED_BY       => fnd_global.user_id,
                                          X_LAST_UPDATE_LOGIN     => fnd_global.conc_login_id);

    /*  INSERT INTO wms_wp_wave_exceptions_vl
      (exception_id,
       exception_name,
       exception_entity,
       exception_stage,
       exception_level,
       exception_msg,
       wave_header_id,
       trip_id,
       delivery_id,
       order_number,
       order_line_id,
       status,
       concurrent_request_id,
       program_id,
       created_by,
       creation_date,
       last_update_date,
       last_updated_by,
       last_update_login)
    VALUES
      (wms_WP_WAVE_exceptions_s.nextval,
       p_exception_name,
       p_exception_entity,
       p_progress_stage,
       p_exception_level,
       l_msg,
       p_wave_id,
       p_trip_id,
       p_delivery_id,
       p_order_number,
       p_order_line_id,
       'Active',
       fnd_global.conc_request_id,
       fnd_global.conc_program_id,
       fnd_global.user_id,
       sysdate,
       sysdate,
       fnd_global.user_id,
       fnd_global.conc_login_id);*/

    print_debug('exception id for current exception :=' ||
                l_seq_val,    -- Changed
                l_debug);

    -- DELETE NEED NOT BE USED, AS CARE IS TAKEN IN ACTIONABLE PROCEDURE.

    /*
    DELETE FROM wms_wave_exceptions
     WHERE wave_header_id = p_wave_id
       AND ((p_exception_entity = 'Wave' AND
           (wave_header_id = p_wave_id AND trip_id IS NULL AND
           delivery_id IS NULL AND order_number IS NULL AND
           order_line_id IS NULL)) OR
           (p_exception_entity = 'Trip' AND trip_id = p_trip_id AND
           delivery_id IS NULL AND order_number IS NULL AND
           order_line_id IS NULL) OR
           (p_exception_entity = 'Delivery' AND
           delivery_id = p_delivery_id AND order_number IS NULL AND
           order_line_id IS NULL) OR
           (p_exception_entity = 'Order' AND order_number = p_order_number AND
           order_line_id IS NULL) OR (p_exception_entity = 'Order Line' AND
           order_line_id = p_order_line_id))
       AND concurrent_request_id != fnd_global.conc_request_id
       AND exception_id != (l_currval);

    COMMIT; */

  EXCEPTION
    WHEN others THEN
      print_debug('Exception in insert_purge_exceptions' || SQLCODE || ':' ||
                  sqlerrm,
                  l_debug);
      x_return_status := fnd_api.g_ret_sts_error;
  END insert_purge_exceptions;

  PROCEDURE check_so(p_current_order    NUMBER,
                     p_current_delivery NUMBER,
                     p_current_trip     NUMBER,
                     p_organization_id  NUMBER) IS

    l_date              DATE := sysdate;
    l_previous_delivery NUMBER DEFAULT NULL;
    l_previous_trip     NUMBER DEFAULT NULL;
    l_exception_id      NUMBER DEFAULT NULL;
    l_debug             NUMBER := nvl(fnd_profile.VALUE('INV_DEBUG_TRACE'),
                                      0);

    -- My information purpose

    /*In this procedure, we need not take care of purging the exceptions that were logged in
    previously for the same entity as this procedure is called only if the
    previous order in this current concurrent request is same as that of the current one
    and it would have taken care of purging the exceptions.*/

  BEGIN

    -- This procedure is used to avoid multiple entries into wms_wave_exception table for a single order
    -- If the Order has lines which are attached to different trips and deliveries then for each different
    -- combination of that order, delivery and trip, there is a chance of an entry. This procedure eliminates it.

    print_debug('In check_so procedure', l_debug);
    SELECT exception_id, delivery_id, trip_id
      INTO l_exception_id, l_previous_delivery, l_previous_trip
      FROM wms_wp_wave_exceptions_vl
     WHERE concurrent_request_id = fnd_global.conc_request_id
       AND order_number = p_current_order;

    print_debug('exception_id fetched =' || l_exception_id, l_debug);

    -- If deliveries and trips ares same no issues.
    IF (nvl(l_previous_delivery, -999) = nvl(p_current_delivery, -999) AND
       nvl(l_previous_trip, -999) = nvl(p_current_trip, -999)) THEN
      print_debug('Nothing to update or insert : Entity = Order', l_debug);
    ELSE
      -- If deliveries are same, obviously trip is same. So that condition is ruled out.
      -- If trips are same, deliveries may not be equal. If that is the case, null out only delivery as trip is same.
      -- if both trips and deliveries are different null out both delivery and trip.

      IF (nvl(l_previous_trip, -999) = nvl(p_current_trip, -999) AND
         nvl(l_previous_delivery, -999) <> nvl(p_current_delivery, -999)) THEN

        update wms_wp_wave_exceptions_b
           set delivery_id       = null,
               last_update_login = fnd_global.conc_login_id,
               last_updated_by   = fnd_global.user_id,
               last_update_date  = l_date
         where exception_id = l_exception_id;

        update WMS_WP_WAVE_EXCEPTIONS_TL
           set LAST_UPDATE_DATE  = l_date,
               LAST_UPDATED_BY   = fnd_global.user_id,
               LAST_UPDATE_LOGIN = fnd_global.conc_login_id,
               SOURCE_LANG       = userenv('LANG')
         where EXCEPTION_ID = l_exception_id
           and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

        /*        UPDATE wms_wp_wave_exceptions
          SET delivery_id = NULL
        WHERE exception_id = l_exception_id;*/

      ELSIF (nvl(l_previous_trip, -999) <> nvl(p_current_trip, -999) AND
            nvl(l_previous_delivery, -999) <>
            nvl(p_current_delivery, -999)) THEN

        update wms_wp_wave_exceptions_b
           set trip_id           = null,
               delivery_id       = null,
               last_update_login = fnd_global.conc_login_id,
               last_updated_by   = fnd_global.user_id,
               last_update_date  = l_date
         where exception_id = l_exception_id;

        update WMS_WP_WAVE_EXCEPTIONS_TL
           set LAST_UPDATE_DATE  = l_date,
               LAST_UPDATED_BY   = fnd_global.user_id,
               LAST_UPDATE_LOGIN = fnd_global.conc_login_id,
               SOURCE_LANG       = userenv('LANG')
         where EXCEPTION_ID = l_exception_id
           and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
        /*
        UPDATE wms_wp_wave_exceptions
           SET trip_id = NULL, delivery_id = NULL
         WHERE exception_id = l_exception_id;*/

      END IF;

    END IF;

  EXCEPTION
    -- My information purpose.

    /* Ideally no_data_found and too_many_rows exceptions should not raise.
    no_data_found: Atleast exception_id should be fetched in select query
    too_many_rows: For that particular concurrent request,if the order number
    comes for the second time we are calling this procedure and this will retain only
    one record for that.*/
    WHEN no_data_found THEN
      print_debug('No data was fetched from check_so procedure query',
                  l_debug);
    WHEN too_many_rows THEN
      print_debug('too many rows fetched from check_so procedure query',
                  l_debug);
    WHEN others THEN
      print_debug('Unknown exception raised in check_so procedure',
                  l_debug);
  END check_so;

  -- below procedure is similar to check_so but here it takes care of lines.

  PROCEDURE check_line(p_current_line     NUMBER,
                       p_current_delivery NUMBER,
                       p_current_trip     NUMBER,
                       p_organization_id  NUMBER) IS

    l_date              DATE := sysdate;
    l_previous_delivery NUMBER DEFAULT NULL;
    l_previous_trip     NUMBER DEFAULT NULL;
    l_exception_id      NUMBER DEFAULT NULL;
    l_debug             NUMBER := nvl(fnd_profile.VALUE('INV_DEBUG_TRACE'),
                                      0);

  BEGIN

    print_debug('In check_line procedure', l_debug);
    SELECT exception_id, delivery_id, trip_id
      INTO l_exception_id, l_previous_delivery, l_previous_trip
      FROM wms_wp_wave_exceptions_vl
     WHERE concurrent_request_id = fnd_global.conc_request_id
       AND ORDER_LINE_ID = p_current_line;

    print_debug('exception_id fetched =' || l_exception_id, l_debug);

    IF (nvl(l_previous_delivery, -999) = nvl(p_current_delivery, -999) AND
       nvl(l_previous_trip, -999) = nvl(p_current_trip, -999)) THEN
      print_debug('Nothing to update or insert : Entity = Line', l_debug);
    ELSE
      IF (nvl(l_previous_trip, -999) = nvl(p_current_trip, -999) AND
         nvl(l_previous_delivery, -999) <> nvl(p_current_delivery, -999)) THEN

        update wms_wp_wave_exceptions_b
           set delivery_id       = null,
               last_update_login = fnd_global.conc_login_id,
               last_updated_by   = fnd_global.user_id,
               last_update_date  = l_date
         where exception_id = l_exception_id;

        update WMS_WP_WAVE_EXCEPTIONS_TL
           set LAST_UPDATE_DATE  = l_date,
               LAST_UPDATED_BY   = fnd_global.user_id,
               LAST_UPDATE_LOGIN = fnd_global.conc_login_id,
               SOURCE_LANG       = userenv('LANG')
         where EXCEPTION_ID = l_exception_id
           and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

      ELSIF (nvl(l_previous_trip, -999) <> nvl(p_current_trip, -999) AND
            nvl(l_previous_delivery, -999) <>
            nvl(p_current_delivery, -999)) THEN

        update wms_wp_wave_exceptions_b
           set trip_id           = null,
               delivery_id       = null,
               last_update_login = fnd_global.conc_login_id,
               last_updated_by   = fnd_global.user_id,
               last_update_date  = l_date
         where exception_id = l_exception_id;

        update WMS_WP_WAVE_EXCEPTIONS_TL
           set LAST_UPDATE_DATE  = l_date,
               LAST_UPDATED_BY   = fnd_global.user_id,
               LAST_UPDATE_LOGIN = fnd_global.conc_login_id,
               SOURCE_LANG       = userenv('LANG')
         where EXCEPTION_ID = l_exception_id
           and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

      END IF;
    END IF;
  EXCEPTION
    WHEN no_data_found THEN
      print_debug('No data was fetched from check_line procedure query',
                  l_debug);
    WHEN too_many_rows THEN
      print_debug('too many rows fetched from check_line procedure query',
                  l_debug);
    WHEN others THEN
      print_debug('Unknown exception raised in check_line procedure',
                  l_debug);
  END check_line;

  PROCEDURE actionable_exceptions(p_perfect_lines                NUMBER,
                                  p_total_lines                  NUMBER,
                                  p_completion_threshold         NUMBER,
                                  p_low_sev_exception_threshold  NUMBER,
                                  p_high_sev_exception_threshold NUMBER,
                                  p_date_scheduled               DATE,
                                  p_exception_id                 NUMBER,
                                  p_exception_name               VARCHAR2,
                                  p_wave_id                      NUMBER,
                                  p_trip_id                      NUMBER,
                                  p_delivery_id                  NUMBER,
                                  p_order_number                 NUMBER,
                                  p_order_line_id                NUMBER,
                                  p_current_order_id             NUMBER,
                                  p_previous_order_id            IN OUT NOCOPY NUMBER,
                                  p_current_line_id              NUMBER,
                                  p_previous_line_id             IN OUT NOCOPY NUMBER,
                                  p_entity                       VARCHAR2,
                                  p_entity_value                 NUMBER,
                                  p_progress_stage               VARCHAR2,
                                  p_take_corrective_measures     VARCHAR2,
                                  p_release_back_ordered_lines   VARCHAR2,
                                  p_action_name                  VARCHAR2,
                                  p_organization_id              NUMBER) IS

    l_level                VARCHAR2(25) DEFAULT NULL;
    l_diff_min             NUMBER;
    l_readytorelease       VARCHAR2(25);
    l_backordered          VARCHAR2(25);
    l_crossdocked          VARCHAR2(25);
    l_replenishment        VARCHAR2(25);
    l_tasked               VARCHAR2(25);
    l_picked               VARCHAR2(25);
    l_packed               VARCHAR2(25);
    l_staged               VARCHAR2(25);
    l_loadedtodock         VARCHAR2(25);
    l_shipped              VARCHAR2(25);
    x_return_status        VARCHAR2(10) := 'S';
    l_completion_threshold NUMBER;
    l_update_exception_id  NUMBER;
    l_msg                  VARCHAR2(400);
    l_addl_msg             VARCHAR2(100);

    l_low_min  NUMBER := p_low_sev_exception_threshold * 60;
    l_high_min NUMBER := p_high_sev_exception_threshold * 60;
    l_debug    NUMBER := nvl(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

  BEGIN

    print_debug('In actionable_exceptions procedure', l_debug);
    l_diff_min := (p_date_scheduled - sysdate) * 24 * 60;
    l_level    := NULL;

    print_debug('take_corrective_measure is=' ||
                p_take_corrective_measures,
                l_debug);

    IF ((p_perfect_lines / p_total_lines) * 100 < p_completion_threshold) THEN

      print_debug('Actual % lines in this particular stage is less than user given completion threshold',
                  l_debug);

      print_debug('actual percentage := ' ||
                  (p_perfect_lines / p_total_lines),
                  l_debug);

      IF (l_diff_min <= l_low_min AND l_diff_min > l_high_min) THEN
        l_level := 'Low';
        -- raise low severity exception
      ELSIF (l_diff_min <= l_high_min) THEN
        l_level := 'High';
      END IF;

    END IF;

    print_debug('exception_level is =' || l_level, l_debug);

    IF (p_exception_id <> -1) THEN

      print_debug('p_exception_id <> -1 :=' || p_exception_id, l_debug);

      IF (l_level = 'Low' OR l_level = 'High') THEN

        print_debug('p_current_order_id = ' || p_current_order_id, l_debug);
        print_debug('p_previous_order_id = ' || p_previous_order_id,
                    l_debug);

        IF (p_entity = 'Order' AND
           nvl(p_current_order_id, -99) = nvl(p_previous_order_id, -999)) THEN
          -- If it is for the first time with entity order, p_previous_order_id will be null
          print_debug('call being made to check_so', l_debug);
          check_so(p_order_number,
                   p_delivery_id,
                   p_trip_id,
                   p_organization_id);

          -- we need not take any other action as the required action was taken for this particular order
          -- in previous run itself.
        ELSIF (p_entity = 'Order Line' AND
              nvl(p_current_line_id, -99) = nvl(p_previous_line_id, -999)) THEN
          -- if it is for the first time with entiry order line, p_previous_line_id will be null
          print_debug('call being made to check_line', l_debug);
          check_line(p_order_line_id,
                     p_delivery_id,
                     p_trip_id,
                     p_organization_id);

          -- we need not take any other action as the required action was taken for this particular order line id
          -- in previous run itself.
        ELSE

          IF (l_level = 'Low') THEN
            l_completion_threshold := p_low_sev_exception_threshold;
          ELSIF (l_level = 'High') THEN
            l_completion_threshold := p_high_sev_exception_threshold;
          END IF;

          l_msg      := l_level || ' exception for ' || p_entity;
          l_addl_msg := '(' || p_completion_threshold ||
                        ' % lines are not ' || p_progress_stage ||
                        ' within ';
          l_addl_msg := l_addl_msg || l_completion_threshold ||
                        ' hours of shipment )';
          l_msg      := l_msg || l_addl_msg;

          SELECT to_char(ROUND((nvl(SUM(decode(line_progress_id, 1, 1, 0)),
                                    0) /
                               decode(COUNT(1), 0, -1, COUNT(-1))) * 100,
                               2)) || '%',
                 to_char(ROUND((nvl(SUM(decode(line_progress_id, 2, 1, 0)),
                                    0) /
                               decode(COUNT(1), 0, -1, COUNT(-1))) * 100,
                               2)) || '%',
                 to_char(ROUND((nvl(SUM(decode(line_progress_id, 3, 1, 0)),
                                    0) /
                               decode(COUNT(1), 0, -1, COUNT(-1))) * 100,
                               2)) || '%',
                 to_char(ROUND((nvl(SUM(decode(line_progress_id, 4, 1, 0)),
                                    0) /
                               decode(COUNT(1), 0, -1, COUNT(-1))) * 100,
                               2)) || '%',
                 to_char(ROUND((nvl(SUM(decode(line_progress_id, 5, 1, 0)),
                                    0) /
                               decode(COUNT(1), 0, -1, COUNT(-1))) * 100,
                               2)) || '%',
                 to_char(ROUND((nvl(SUM(decode(line_progress_id, 7, 1, 0)),
                                    0) /
                               decode(COUNT(1), 0, -1, COUNT(-1))) * 100,
                               2)) || '%',
                 to_char(ROUND((nvl(SUM(decode(line_progress_id, 8, 1, 0)),
                                    0) /
                               decode(COUNT(1), 0, -1, COUNT(-1))) * 100,
                               2)) || '%',
                 to_char(ROUND((nvl(SUM(decode(line_progress_id, 9, 1, 0)),
                                    0) /
                               decode(COUNT(1), 0, -1, COUNT(-1))) * 100,
                               2)) || '%',
                 to_char(ROUND((nvl(SUM(decode(line_progress_id, 10, 1, 0)),
                                    0) /
                               decode(COUNT(1), 0, -1, COUNT(-1))) * 100,
                               2)) || '%',
                 to_char(ROUND((nvl(SUM(decode(line_progress_id, 11, 1, 0)),
                                    0) /
                               decode(COUNT(1), 0, -1, COUNT(-1))) * 100,
                               2)) || '%'
            INTO l_readytorelease,
                 l_backordered,
                 l_crossdocked,
                 l_replenishment,
                 l_tasked,
                 l_picked,
                 l_staged,
                 l_packed,
                 l_loadedtodock,
                 l_shipped
            FROM wms_wp_wwb_lines_v
           WHERE wave_header_id = p_wave_id
             AND ((p_entity = 'Wave' AND wave_header_id = p_wave_id) OR
                 (p_entity = 'Trip' AND trip = p_entity_value) OR
                 (p_entity = 'Delivery' AND delivery_id = p_entity_value) OR
                 (p_entity = 'Order' AND order_number = p_entity_value) OR
                 (p_entity = 'Order Line' AND
                 source_line_id = p_entity_value));

          UPDATE wms_wp_wave_exceptions_b
             SET exception_level       = l_level,
                 exception_msg         = l_msg,
                 ready_to_release      = l_readytorelease,
                 backordered           = l_backordered,
                 crossdock_planned     = l_crossdocked,
                 replenishment_planned = l_replenishment,
                 tasked                = l_tasked,
                 picked                = l_picked,
                 packed                = l_packed,
                 staged                = l_staged,
                 loaded_to_dock        = l_loadedtodock,
                 shipped               = l_shipped,
                 concurrent_request_id = fnd_global.conc_request_id,
                 program_id            = fnd_global.conc_program_id,
                 last_updated_by       = fnd_global.user_id,
                 last_update_login     = fnd_global.conc_login_id,
                 last_update_date      = SYSDATE

           WHERE exception_id = p_exception_id;

          update WMS_WP_WAVE_EXCEPTIONS_TL
             set LAST_UPDATE_DATE  = SYSDATE,
                 LAST_UPDATED_BY   = fnd_global.user_id,
                 LAST_UPDATE_LOGIN = fnd_global.conc_login_id,
                 SOURCE_LANG       = userenv('LANG')
           where EXCEPTION_ID = p_exception_id
             and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

          IF (p_take_corrective_measures = 'Yes') THEN
            -- call api to take corrective measures
            take_corrective_measures(p_exception_id,
                                     p_wave_id,
                                     p_entity,
                                     p_entity_value,
                                     p_release_back_ordered_lines,
                                     p_action_name,
                                     p_organization_id);

          END IF;

          /*   elsif (p_take_corrective_measures = 'No') then
          -- If the record has status "action taken" we should not change it
          -- If the record is active, we need not change it
          -- So no action to be taken in this in this "elsif" part.*/
        END IF;

      ELSIF (l_level IS NULL) THEN

        -- confirm the below if condition.
        -- It may be like, first time when the order is encountered and exception rouse
        -- but some corrective measures were taken and as result exception is no more there
        -- by the time the order is encountered the second time.
        -- That time it should be closed. ?????????
        IF (p_entity = 'Order' AND
           nvl(p_current_order_id, -99) = nvl(p_previous_order_id, -999)) THEN

          print_debug('required action is already taken for the same order
      the last time when this order was evaluated',
                      l_debug);

        ELSIF (p_entity = 'Order Line' AND
              nvl(p_current_line_id, -99) = nvl(p_previous_line_id, -999)) THEN
          print_debug('required action is already taken for the same order line id
      the last time when this order line id was evaluated',
                      l_debug);

        ELSE

          UPDATE wms_wp_wave_exceptions_b
             SET status            = 'Closed',
                 last_update_date  = sysdate,
                 last_updated_by   = fnd_global.user_id,
                 last_update_login = fnd_global.login_id
           WHERE exception_id = p_exception_id;

          update WMS_WP_WAVE_EXCEPTIONS_TL
             set LAST_UPDATE_DATE  = SYSDATE,
                 LAST_UPDATED_BY   = fnd_global.user_id,
                 LAST_UPDATE_LOGIN = fnd_global.conc_login_id,
                 SOURCE_LANG       = userenv('LANG')
           where EXCEPTION_ID = p_exception_id
             and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

        END IF;

      END IF;

      IF p_entity = 'Order' THEN
        p_previous_order_id := p_current_order_id;
      END IF;

      if p_entity = 'Order Line' then
        p_previous_line_id := p_current_line_id;
      end if;

    ELSIF (p_exception_id = -1 AND l_level IS NOT NULL) THEN

      print_debug('in p_exception_id = -1', l_debug);

      IF (l_level = 'Low') THEN
        l_completion_threshold := p_low_sev_exception_threshold;
      ELSIF (l_level = 'High') THEN
        l_completion_threshold := p_high_sev_exception_threshold;
      END IF;

      insert_purge_exceptions(p_exception_name,
                              p_entity,
                              l_level,
                              p_completion_threshold,
                              p_progress_stage,
                              l_completion_threshold,
                              p_wave_id,
                              p_trip_id,
                              p_delivery_id,
                              p_order_number,
                              p_order_line_id,
                              x_return_status);

      IF (x_return_status <> 'S') THEN
        print_debug('Error returned from insert_purge_exceptions ',
                    l_debug);
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF (p_entity = 'Order') THEN
        p_previous_order_id := p_current_order_id;
      END IF;

      if p_entity = ('Order Line') THEN
        p_previous_line_id := p_current_line_id;
      end if;

      SELECT to_char(ROUND((nvl(SUM(decode(line_progress_id, 1, 1, 0)), 0) /
                           decode(COUNT(1), 0, -1, COUNT(-1))) * 100,
                           2)) || '%',
             to_char(ROUND((nvl(SUM(decode(line_progress_id, 2, 1, 0)), 0) /
                           decode(COUNT(1), 0, -1, COUNT(-1))) * 100,
                           2)) || '%',
             to_char(ROUND((nvl(SUM(decode(line_progress_id, 3, 1, 0)), 0) /
                           decode(COUNT(1), 0, -1, COUNT(-1))) * 100,
                           2)) || '%',
             to_char(ROUND((nvl(SUM(decode(line_progress_id, 4, 1, 0)), 0) /
                           decode(COUNT(1), 0, -1, COUNT(-1))) * 100,
                           2)) || '%',
             to_char(ROUND((nvl(SUM(decode(line_progress_id, 5, 1, 0)), 0) /
                           decode(COUNT(1), 0, -1, COUNT(-1))) * 100,
                           2)) || '%',
             to_char(ROUND((nvl(SUM(decode(line_progress_id, 7, 1, 0)), 0) /
                           decode(COUNT(1), 0, -1, COUNT(-1))) * 100,
                           2)) || '%',
             to_char(ROUND((nvl(SUM(decode(line_progress_id, 8, 1, 0)), 0) /
                           decode(COUNT(1), 0, -1, COUNT(-1))) * 100,
                           2)) || '%',
             to_char(ROUND((nvl(SUM(decode(line_progress_id, 9, 1, 0)), 0) /
                           decode(COUNT(1), 0, -1, COUNT(-1))) * 100,
                           2)) || '%',
             to_char(ROUND((nvl(SUM(decode(line_progress_id, 10, 1, 0)), 0) /
                           decode(COUNT(1), 0, -1, COUNT(-1))) * 100,
                           2)) || '%',
             to_char(ROUND((nvl(SUM(decode(line_progress_id, 11, 1, 0)), 0) /
                           decode(COUNT(1), 0, -1, COUNT(-1))) * 100,
                           2)) || '%'
        INTO l_readytorelease,
             l_backordered,
             l_crossdocked,
             l_replenishment,
             l_tasked,
             l_picked,
             l_staged,
             l_packed,
             l_loadedtodock,
             l_shipped
        FROM wms_wp_wwb_lines_v
       WHERE wave_header_id = p_wave_id
         AND ((p_entity = 'Wave' AND wave_header_id = p_wave_id) OR
             (p_entity = 'Trip' AND trip = p_entity_value) OR
             (p_entity = 'Delivery' AND delivery_id = p_entity_value) OR
             (p_entity = 'Order' AND order_number = p_entity_value) OR
             (p_entity = 'Order Line' AND source_line_id = p_entity_value));

            SELECT wms_WP_WAVE_exceptions_s.currval INTO l_seq_val FROM dual;      -- Changed
      l_update_exception_id := l_seq_val;              -- Changed

      UPDATE wms_wp_wave_exceptions_b
         SET ready_to_release      = l_readytorelease,
             backordered           = l_backordered,
             crossdock_planned     = l_crossdocked,
             replenishment_planned = l_replenishment,
             tasked                = l_tasked,
             picked                = l_picked,
             packed                = l_packed,
             staged                = l_staged,
             loaded_to_dock        = l_loadedtodock,
             shipped               = l_shipped,
             concurrent_request_id = fnd_global.conc_request_id,
             program_id            = fnd_global.conc_program_id,
             last_update_date      = sysdate,
             last_updated_by       = fnd_global.user_id,
             last_update_login     = fnd_global.conc_login_id
       WHERE exception_id = l_update_exception_id;

      update WMS_WP_WAVE_EXCEPTIONS_TL
         set LAST_UPDATE_DATE  = SYSDATE,
             LAST_UPDATED_BY   = fnd_global.user_id,
             LAST_UPDATE_LOGIN = fnd_global.conc_login_id,
             SOURCE_LANG       = userenv('LANG')
       where EXCEPTION_ID = l_update_exception_id
         and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

      IF (p_take_corrective_measures = 'Yes') THEN
        -- call api to take corrective measures
        SELECT wms_WP_WAVE_exceptions_s.CURRVAL INTO l_seq_val FROM dual;  -- Changed
        take_corrective_measures(l_seq_val,                                          -- Changed
                                 p_wave_id,
                                 p_entity,
                                 p_entity_value,
                                 p_release_back_ordered_lines,
                                 p_action_name,
                                 p_organization_id);

        /*   elsif (p_take_corrective_measures = 'No') then
        -- If the record has status "action taken" we should not change it
        -- If the record is active, we need not change it
        -- So no action to be taken in this in this "elsif" part.*/
      END IF;

    END IF;

  END actionable_exceptions;

  PROCEDURE apply_saved_action( --p_action_name  IN    VARCHAR2,
                               p_wave_id       NUMBER,
                               p_entity        varchar2,
                               p_entity_value  NUMBER,
                               p_action_name   VARCHAR2,
                               x_return_status OUT nocopy VARCHAR2) IS

    l_transaction_temp_id_table WMS_WAVE_PLANNING_PVT.transaction_temp_table_type;
    l_task_type_id_table        WMS_WAVE_PLANNING_PVT.task_type_id_table_type;
    row_in                      NUMBER := 0;
    l_select_query              VARCHAR2(4000);
    l_from_query                VARCHAR2(4000);
    l_where_query               VARCHAR2(4000);
    l_final_query               VARCHAR2(4000) := NULL;
    type cur_typ IS ref CURSOR;
    c               cur_typ;
    l_task_id_table wms_wave_planning_pvt.task_id_table_type;
    --x_return_status VARCHAR2(1);

    l_debug          NUMBER := nvl(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    l_updated_record NUMBER := 0;

    l_msg_data      VARCHAR2(120);
    l_msg_count     NUMBER;
    l_save_count    NUMBER;
    l_return_status VARCHAR2(120);
    l_result_table  wms_wave_planning_pvt.result_table_type;
    l_message_table wms_wave_planning_pvt.message_table_type;

    CURSOR c_saved_actions(p_action_name varchar2) IS
      select field_name, field_value, query_type
        from wms_saved_queries
       where query_name = p_action_name
         and (query_type = 'TASK_ACTION' or query_type = 'TEMP_TASK_ACTION')
         FOR UPDATE NOWAIT;

    CURSOR c_query_type(p_action_name varchar2) IS
      select distinct query_type
        from wms_saved_queries
       where query_name = p_action_name;

    rec_saved_actions c_saved_actions%rowtype;

    l_field_name_table      wms_wave_planning_pvt.field_name_table_type;
    l_field_value_table     wms_wave_planning_pvt.field_value_table_type;
    l_organization_id_table wms_wave_planning_pvt.organization_id_table_type;
    l_query_type_table      wms_wave_planning_pvt.query_type_table_type;

  BEGIN

    -- Clearing the tables.
    l_field_name_table.delete;
    l_field_value_table.delete;
    l_query_type_table.delete;

    print_DEBUG('Cleared pl/sql tables l_query_type_table, l_field_name_table and l_field_value_table.',
                l_debug);

    print_DEBUG('Opening c_saved_actions cursor', l_debug);

    OPEN c_saved_actions(p_action_name);
    FETCH c_saved_actions BULK COLLECT
      INTO l_field_name_table, l_field_value_table, l_query_type_table;

    -- If no records founds for the given query name
    -- then close the cursor and return informing invalid query name.

    print_DEBUG('c_saved_actions%ROWCOUNT = ' || c_saved_actions%ROWCOUNT,
                l_debug);

    --x_rowcount := c_saved_actions%ROWCOUNT;

    IF c_saved_actions%ROWCOUNT = 0 THEN
      CLOSE c_saved_actions;

      print_DEBUG('No data found for action name. ' || p_action_name,
                  l_debug);
      --x_rowcount  := 0;
      x_return_status := fnd_api.g_ret_sts_success;
      --x_return_message:= 'No data found for action name. ' || p_action_name;

      FOR rec_query_type IN c_query_type(p_action_name) LOOP
        IF rec_query_type.query_type = 'TEMP_TASK_ACTION' THEN
          l_temp_action := TRUE;
        ELSE
          l_temp_action := FALSE;
        END IF;
      END LOOP;

      RETURN;
    END IF;

    CLOSE c_saved_actions;

    print_DEBUG('Bulk collect successful and closed c_saved_actions cursor',
                l_debug);

    print_DEBUG('Calling SET_ACTION_TASKS_PARAMETERS', l_debug);

    SET_ACTION_TASKS_PARAMETERS(p_field_name_table  => l_field_name_table,
                                p_field_value_table => l_field_value_table,
                                p_query_type_table  => l_query_type_table,
                                x_return_status     => l_return_status,
                                x_return_message    => l_msg_data);

    print_DEBUG('SET_ACTION_TASKS_PARAMETERS return status = ' ||
                l_return_status,
                l_debug);
    print_DEBUG('SET_ACTION_TASKS_PARAMETERS return message = ' ||
                l_msg_data,
                l_debug);

    -- If set_action_tasks_parameters returns error then log message and return.
    IF l_return_status = fnd_api.g_ret_sts_error OR
       l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      print_DEBUG(' Error in SET_ACTION_TASKS_PARAMETERS ', l_debug);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      return;
    END IF;

    -------------------------------------------------------------------------------------------------------------

    l_select_query := 'select mmtt.TRANSACTION_TEMP_ID, mmtt.wms_task_type';
    l_from_query   := ' from wms_wp_wave_lines wwl,wsh_delivery_details wdd,
                                   mtl_material_transactions_temp mmtt';
    l_where_query  := ' where wwl.wave_header_id = :wave_id
                                  and wdd.delivery_detail_id = wwl.delivery_detail_id
                                  and wdd.source_line_id  = mmtt.trx_source_line_id';
    --     Change the status from unreleased to pending for  those mmtts  that belong to wdds
    --     that belong to this particular entity value and mmtts are in 'Unreleased status

    IF (p_entity = 'Wave') THEN
      print_debug('Nothing to Do here' || l_final_query, l_debug);
    ELSIF (p_entity = 'Trip') THEN
      l_from_query  := l_from_query ||
                       ' ,wsh_delivery_assignments wda, wsh_new_deliveries wnd,
                                        wsh_delivery_legs wdl, wsh_trip_stops wts';
      l_where_query := l_where_query ||
                       ' and wdd.delivery_detail_id = wda.delivery_detail_id
                                          and wda.delivery_id = wnd.delivery_id
            and wnd.delivery_id = wdl.delivery_id
            and wdl.pick_up_stop_id = wts.stop_id
            and wts.trip_id = :entity_value ';
    ELSIF (p_entity = 'Delivery') THEN
      l_from_query  := l_from_query || ' , wsh_delivery_assignments wda';
      l_where_query := l_where_query ||
                       ' and wdd.delivery_detail_id = wda.delivery_detail_id
                                           and wda.delivery_id = :entity_value ';
    ELSIF (p_entity = 'Order') THEN
      l_where_query := l_where_query ||
                       ' and wdd.source_header_id = :entity_value';

      print_debug('take measures, pending tasks, task priority of order',
                  l_debug);
    ELSIF (p_entity = 'Order Line') THEN
      l_where_query := l_where_query ||
                       ' and wdd.source_line_id = :entity_value ';
    END IF;

    l_final_query := l_select_query || l_from_query || l_where_query;
    print_debug('final query:  ' || l_final_query, l_debug);

    l_transaction_temp_id_table.DELETE;
    l_task_type_id_table.DELETE;

    IF (p_entity = 'Wave') THEN

      OPEN c FOR l_final_query
        USING p_wave_id;
      LOOP
        FETCH c
          INTO l_transaction_temp_id_table(row_in), l_task_type_id_table(row_in);
        row_in := row_in + 1;
        EXIT WHEN c % NOTFOUND;
      END LOOP;

      CLOSE c;
      row_in := 0;
    ELSE

      OPEN c FOR l_final_query
        USING p_wave_id, p_entity_value;
      LOOP
        FETCH c
          INTO l_transaction_temp_id_table(row_in), l_task_type_id_table(row_in);
        row_in := row_in + 1;
        EXIT WHEN c % NOTFOUND;
      END LOOP;

      CLOSE c;
      row_in := 0;
    END IF;

    print_debug('XXX 1', l_debug);

    IF (l_transaction_temp_id_table.count = 0 or
       l_task_type_id_table.count = 0) THEN
      RETURN;
    END IF;

    --populate wms_wp_tasks_gtmp using view wms_wp_wwb_tasks_v and transaction_temp_id in l_transaction_temp_id
    FORALL ttemp_id IN l_transaction_temp_id_table.FIRST .. l_transaction_temp_id_table.LAST
      insert into wms_wp_tasks_gtmp
        select task_id,
               to_lpn,
               to_lpn_id,
               transaction_temp_id,
               transaction_type_id,
               transaction_action_id,
               transaction_source_type_id,
               transaction_source_id,
               transaction_source_line_id,
               organization_id,
               organization_code,
               to_organization_id,
               to_organization_code,
               to_subinventory,
               to_locator_id,
               to_locator,
               user_task_type_id,
               user_task_type,
               person_id,
               person_id_original,
               person,
               effective_start_date,
               effective_end_date,
               person_resource_id,
               person_resource_code,
               status_id,
               status_id_original,
               status,
               mmtt_last_update_date,
               mmtt_last_updated_by,
               wdt_last_update_date,
               wdt_last_updated_by,
               priority,
               priority_original,
               task_type_id,
               task_type,
               is_modified,
               plan_task,
               result,
               error,
               source_header,
               line_number,
               item,
               item_description,
               revision,
               subinventory,
               locator,
               secondary_quantity,
               secondary_uom,
               operation_plan_id,
               operation_plan,
               operation_sequence,
               operation_plan_instance,
               ship_method,
               shipment_date,
               shipment_priority,
               department,
               child_tasks,
               num_of_child_tasks,
               allocated_lpn,
               cartonized_lpn,
               container_item,
               content_lpn,
               dispatched_time,
               equipment,
               from_lpn,
               parent_line_id,
               move_order_line_id,
               pick_slip_number,
               picked_lpn,
               transaction_uom,
               transaction_quantity
          from wms_wp_wwb_tasks_v
         where wave_header_id = p_wave_id
           AND transaction_temp_id = l_transaction_temp_id_table(ttemp_id);

    /* Bug 5485730 - The employee details should be null if the status is being updated
    to Pending or Unreleased */
    IF l_action_type = 'U' then

      IF l_status_code IN (1, 8) THEN
        l_employee             := NULL;
        l_employee_id          := NULL;
        l_user_task_type       := NULL;
        l_user_task_type_id    := NULL;
        l_effective_start_date := NULL;
        l_effective_end_date   := NULL;
        l_person_resource_id   := NULL;
        l_person_resource_code := NULL;
      END IF;
      /* End of Bug 5485730 */
      --call update task
      print_DEBUG('Calling wms_wave_planning_pvt.UPDATE_TASK', l_debug);
      print_DEBUG('Following are the input parameters', l_debug);
      print_DEBUG('p_employee    => ' || l_employee, l_debug);
      print_DEBUG('p_employee_id    => ' || l_employee_id, l_debug);
      print_DEBUG('p_user_task_type  => ' || l_user_task_type, l_debug);
      print_DEBUG('p_user_task_type_id  => ' || l_user_task_type_id,
                  l_debug);
      print_DEBUG('p_effective_start_date  => ' || l_effective_start_date,
                  l_debug);
      print_DEBUG('p_effective_end_date  => ' || l_effective_end_date,
                  l_debug);
      print_DEBUG('p_person_resource_id  => ' || l_person_resource_id,
                  l_debug);
      print_DEBUG('p_person_resource_code  => ' || l_person_resource_code,
                  l_debug);
      --print_DEBUG( 'p_person_resource_code  => ' || l_override_emp_check, l_debug);
      print_DEBUG('p_to_status    => ' || l_status, l_debug);
      print_DEBUG('p_to_status_id    => ' || l_status_code, l_debug);
      print_DEBUG('p_update_priority_type  => ' || l_priority_type,
                  l_debug);
      print_DEBUG('p_update_priority  => ' || l_priority, l_debug);
      print_DEBUG('p_clear_priority  => ' || l_clear_priority, l_debug);

      IF l_override_emp_check = TRUE THEN
        print_DEBUG('p_force_employee_change  => TRUE', l_debug);
      ELSE
        print_DEBUG('p_force_employee_change  => FALSE', l_debug);
      END IF;

      update_task(p_transaction_temp_id   => l_transaction_temp_id_table,
                  p_task_type_id          => l_task_type_id_table,
                  p_employee              => l_employee,
                  p_employee_id           => l_employee_id,
                  p_user_task_type        => l_user_task_type,
                  p_user_task_type_id     => l_user_task_type_id,
                  p_effective_start_date  => l_effective_start_date,
                  p_effective_end_date    => l_effective_end_date,
                  p_person_resource_id    => l_person_resource_id,
                  p_person_resource_code  => l_person_resource_code,
                  p_force_employee_change => l_override_emp_check,
                  p_to_status             => l_status,
                  p_to_status_id          => l_status_code,
                  p_priority_type         => l_priority_type,
                  p_priority              => l_priority,
                  p_clear_priority        => l_clear_priority,
                  x_result                => l_result_table,
                  x_message               => l_message_table,
                  x_task_id               => l_task_id_table,
                  x_return_status         => l_return_status,
                  x_return_msg            => l_msg_data,
                  x_msg_count             => l_msg_count);

      print_DEBUG('update_task l_return_status ' || l_return_status,
                  l_debug);

      IF l_return_status = fnd_api.g_ret_sts_error OR
         l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        print_DEBUG('Error in update_task ', l_debug);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        return;
      END IF;

      print_DEBUG('Records Updated by update_task ' ||
                  l_result_table.count,
                  l_debug);
      l_updated_record := l_result_table.Count;

    ELSIF l_action_type = 'C' THEN
      print_DEBUG('Cancel Task is not applicable ', l_debug);
      l_updated_record := 0;
    ELSE
      print_DEBUG('Invalid Action ', l_debug);
      l_updated_record := 0;
    END IF;

    IF l_updated_record > 0 then
      print_DEBUG('Calling wms_waveplan_tasks_pvt.save_tasks ', l_debug);
      print_DEBUG('Input Parameters passed', l_debug);
      print_DEBUG('p_commit  => TRUE', l_debug);
      print_DEBUG('p_user_id  => ' || fnd_global.user_id, l_debug);
      print_DEBUG('p_login_id  => ' || fnd_global.login_id, l_debug);

      save_tasks(p_commit        => TRUE,
                 p_user_id       => fnd_global.user_id,
                 p_login_id      => fnd_global.login_id,
                 x_save_count    => l_save_count,
                 x_return_status => l_return_status,
                 x_msg_data      => l_msg_data,
                 x_msg_count     => l_msg_count);

      print_DEBUG('SAVE_TASKS return Status = ' || l_return_status,
                  l_debug);
      print_DEBUG('SAVE_TASKS l_save_count = ' || l_save_count, l_debug);
      print_DEBUG('SAVE_TASKS l_msg_data = ' || l_msg_data, l_debug);
      print_DEBUG('SAVE_TASKS l_msg_count = ' || l_msg_count, l_debug);

      IF l_return_status = fnd_api.g_ret_sts_error OR
         l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        print_DEBUG('Error in save_task ', l_debug);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        return;
      END IF;
    END IF;

    l_transaction_temp_id_table.DELETE;
    l_task_type_id_table.DELETE;

    print_debug('Exiting apply_saved_action ', l_debug);

  EXCEPTION
    WHEN others THEN
      print_debug('exception in apply_saved_action ', l_debug);
  END apply_saved_action;

  PROCEDURE take_corrective_measures(p_exception_id               NUMBER,
                                     p_wave_id                    NUMBER,
                                     p_entity                     VARCHAR2,
                                     p_entity_value               NUMBER,
                                     p_release_back_ordered_lines VARCHAR2,
                                     p_action_name                VARCHAR2,
                                     p_organization_id            NUMBER) IS

    type wdd_table IS TABLE OF NUMBER INDEX BY binary_integer;
    l_wdd_table    wdd_table;
    row_in         NUMBER := 0;
    l_select_query VARCHAR2(4000);
    l_from_query   VARCHAR2(4000);
    l_where_query  VARCHAR2(4000);
    l_where_rpt    VARCHAR2(4000);
    l_where_cptp   VARCHAR2(4000);
    type cur_typ IS ref CURSOR;
    c               cur_typ;
    l_final_query   VARCHAR2(4000) := NULL;
    l_debug         NUMBER := nvl(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    x_msg_count     VARCHAR2(100);
    x_msg_data      VARCHAR2(100);
    p_batch_id      NUMBER;
    p_request_id    NUMBER;
    x_return_status VARCHAR2(1);
    l_phase         VARCHAR2(100);
    l_status        VARCHAR2(100);
    l_dev_phase     VARCHAR2(100);
    l_dev_status    VARCHAR2(100);
    l_message       VARCHAR2(500);
    l_result        boolean;

    l_entity_value number;
    --p_action_name VARCHAR2(100) := 'p';

  BEGIN

    print_debug('in take_corrective_measures API', l_debug);

    if (p_entity = 'Order') then
      begin
        select distinct (source_header_id)
          into l_entity_value
          from wsh_delivery_details
         where source_header_number = p_entity_value
           and organization_id = p_organization_id;

      exception
        when no_data_found then
          print_debug('no data found exception in take corrective measures',
                      l_debug);
        when others then
          print_debug('other exception in take corrective measures',
                      l_debug);
      end;
    else

      l_entity_value := p_entity_value;
    end if;

    IF (p_release_back_ordered_lines = 'Yes') THEN
      l_select_query := 'select wwl.delivery_detail_id';
      l_from_query   := ' from wms_wp_wave_lines wwl,wsh_delivery_details wdd';
      l_where_query  := ' where wwl.wave_header_id = :wave_id
                                  and wdd.delivery_detail_id = wwl.delivery_detail_id
                                  and wdd.released_status = ''B''
                                  and wdd.replenishment_status is null';
      --not in (''R'',''C'')';
      -- Select only backordered wdds (EXCLUDE 'RR" and 'RC' status ) for this particular entity value

      IF (p_entity = 'Wave') THEN
        print_debug('No more changes in any string', l_debug);
      ELSIF (p_entity = 'Trip') THEN
        l_from_query  := l_from_query ||
                         ' , wsh_delivery_assignments wda, wsh_new_deliveries wnd,
                      wsh_delivery_legs wdl,wsh_trip_stops wts';
        l_where_query := l_where_query ||
                         ' and wda.delivery_detail_id = wdd.delivery_detail_id
                       and wda.delivery_id = wnd.delivery_id(+)
                       and wnd.delivery_id = wdl.delivery_id(+)
                       and wdl.pick_up_stop_id = wts.stop_id(+)
                       and wts.trip_id = :entity_value';
      ELSIF (p_entity = 'Delivery') THEN
        l_from_query  := l_from_query || ' ,wsh_delivery_assignments wda';
        l_where_query := l_where_query ||
                         ' and wda.delivery_detail_id = wdd.delivery_detail_id
                       and wda.delivery_id = :entity_value';
      ELSIF (p_entity = 'Order') THEN
        l_where_query := l_where_query ||
                         ' and wwl.source_header_id = :entity_value';
      ELSIF (p_entity = 'Order Line') THEN
        l_where_query := l_where_query ||
                         ' and wwl.source_line_id = :entity_value';
      END IF;

      l_final_query := l_select_query || l_from_query || l_where_query;

      print_debug('Query for ' || p_entity || ':' || l_final_query,
                  l_debug);
      print_debug('The Wave Header Id is ' || p_wave_id, l_debug);

      IF (p_entity = 'Wave') THEN

        OPEN c FOR l_final_query
          USING p_wave_id;
        LOOP
          FETCH c
            INTO l_wdd_table(row_in);
          row_in := row_in + 1;
          EXIT WHEN c % NOTFOUND;
        END LOOP;

        CLOSE c;
        row_in := 0;
      ELSE

        OPEN c FOR l_final_query
          USING p_wave_id, l_entity_value;
        LOOP
          FETCH c
            INTO l_wdd_table(row_in);
          row_in := row_in + 1;
          EXIT WHEN c % NOTFOUND;
        END LOOP;

        CLOSE c;
        row_in := 0;
      END IF;

      print_debug('Setting the Re Release flag to Y ', l_debug);

      forall i IN l_wdd_table.FIRST .. l_wdd_table.LAST

        UPDATE wms_wp_wave_lines
           SET re_release_flag = 'Y'
         WHERE delivery_detail_id = l_wdd_table(i);
      COMMIT;

      -- Call backorder API with the pls table as input.
      wms_wave_planning_pvt.create_batch_record(x_return_status, p_wave_id);

      IF x_return_status = 'S' THEN

        wsh_picking_batches_grp.release_wms_wave(p_release_mode        => 'CONCURRENT',
                                                 p_pick_wave_header_id => p_wave_id,
                                                 x_request_id          => p_request_id, -- wat rqst id
                                                 x_return_status       => x_return_status,
                                                 x_msg_count           => x_msg_count,
                                                 x_msg_data            => x_msg_data,
                                                 p_batch_rec           => new_wave_type, -- wat wave type
                                                 x_batch_id            => p_batch_id);
        -- wat batch id

        l_result := fnd_concurrent.wait_for_request(request_id => p_request_id,
                                                    phase      => l_phase,
                                                    status     => l_status,
                                                    dev_phase  => l_dev_phase,
                                                    dev_status => l_dev_status,
                                                    message    => l_message);

        l_result := fnd_concurrent.set_completion_status(status  => l_status,
                                                         message => '');

        IF x_return_status = 'S' THEN

          get_actual_fill_rate(x_return_status, p_wave_id);

          print_debug('Status after Call to Get the Actual Fill Rate' ||
                      x_return_status,
                      l_debug);

        END IF;

      END IF;

      -- After calling the api, we need to delete the records in the plsql table
      -- NEED TO UNCOMMENT THE ABOVE PART, WHEN INCLUDED IN AJITH'S MAIN API
      l_wdd_table.DELETE;
    END IF;

    /*-------------task update start here---------------------
    --create table of mmtt.transaction_temp_id as it is doen currently and then apply action
      IF (p_release_planned_tasks = 'Yes' OR
         p_change_pending_task_priority = 'Yes') THEN

        print_debug('in release pending tasks and change pending task priority',
                    l_debug);
        l_select_query := 'select mmtt.TRANSACTION_TEMP_ID';
        l_from_query   := ' from wms_wp_wave_lines wwl,wsh_delivery_details wdd,
                                       mtl_material_transactions_temp mmtt';
        l_where_query  := ' where wwl.wave_header_id = :wave_id
                                    and wdd.delivery_detail_id = wwl.delivery_detail_id
                                    and wdd.source_line_id  = mmtt.trx_source_line_id';
        --     Change the status from unreleased to pending for  those mmtts  that belong to wdds
        --     that belong to this particular entity value and mmtts are in 'Unreleased status

        IF (p_entity = 'Wave') THEN
          print_debug('Nothing to Do here' || l_final_query, l_debug);
        ELSIF (p_entity = 'Trip') THEN
          l_from_query  := l_from_query ||
                           ' ,wsh_delivery_assignments wda, wsh_new_deliveries wnd,
                                          wsh_delivery_legs wdl, wsh_trip_stops wts';
          l_where_query := l_where_query ||
                           ' and wdd.delivery_detail_id = wda.delivery_detail_id
                                            and wda.delivery_id = wnd.delivery_id
              and wnd.delivery_id = wdl.delivery_id
              and wdl.pick_up_stop_id = wts.stop_id
              and wts.trip_id = :entity_value ';
        ELSIF (p_entity = 'Delivery') THEN
          l_from_query  := l_from_query || ' , wsh_delivery_assignments wda';
          l_where_query := l_where_query ||
                           ' and wdd.delivery_detail_id = wda.delivery_detail_id
                                             and wda.delivery_id = :entity_value ';
        ELSIF (p_entity = 'Order') THEN
          l_where_query := l_where_query ||
                           ' and wdd.source_header_id = :entity_value';

          print_debug('take measures, pending tasks, task priority of order',
                      l_debug);
        ELSIF (p_entity = 'Order Line') THEN
          l_where_query := l_where_query ||
                           ' and wdd.delivery_detail_id = :entity_value ';
        END IF;

      END IF;

      IF (p_release_planned_tasks = 'Yes') THEN
        l_where_rpt   := l_where_query || ' and mmtt.wms_task_status = 8';
        l_final_query := l_select_query || l_from_query || l_where_rpt;
        print_debug('final query' || l_final_query, l_debug);

        IF (p_entity = 'Wave') THEN

          OPEN c FOR l_final_query
            USING p_wave_id;
          LOOP
            FETCH c
              INTO l_wdd_table(row_in);
            row_in := row_in + 1;
            EXIT WHEN c % NOTFOUND;
          END LOOP;

          CLOSE c;
          row_in := 0;
        ELSE

          OPEN c FOR l_final_query
            USING p_wave_id, l_entity_value;
          LOOP
            FETCH c
              INTO l_wdd_table(row_in);
            row_in := row_in + 1;
            EXIT WHEN c % NOTFOUND;
          END LOOP;

          CLOSE c;
          row_in := 0;
        END IF;

        forall i IN l_wdd_table.FIRST .. l_wdd_table.LAST

          UPDATE mtl_material_transactions_temp
             SET wms_task_status = 1
           WHERE transaction_temp_id = l_wdd_table(i);
        l_wdd_table.DELETE;
      END IF;

      print_debug('befor pending task priority', l_debug);

      IF (p_change_pending_task_priority = 'Yes') THEN
        l_where_cptp  := l_where_query || ' and mmtt.wms_task_status in (1)';
        l_final_query := l_select_query || l_from_query || l_where_cptp;

        print_debug('final query' || l_final_query, l_debug);

        print_debug('before ref cursor opening', l_debug);

        IF (p_entity = 'Wave') THEN

          OPEN c FOR l_final_query
            USING p_wave_id;
          LOOP
            FETCH c
              INTO l_wdd_table(row_in);
            row_in := row_in + 1;
            EXIT WHEN c % NOTFOUND;
          END LOOP;

          CLOSE c;
          row_in := 0;
        ELSE

          OPEN c FOR l_final_query
            USING p_wave_id, l_entity_value;
          LOOP
            FETCH c
              INTO l_wdd_table(row_in);
            row_in := row_in + 1;
            EXIT WHEN c % NOTFOUND;
          END LOOP;

          CLOSE c;
          row_in := 0;
        END IF;

        print_debug('after ref cursor close', l_debug);
        print_debug('befor bulk update', l_debug);

        forall i IN l_wdd_table.FIRST .. l_wdd_table.LAST

          UPDATE mtl_material_transactions_temp
             SET task_priority = (nvl(task_priority, 0) + p_change_priority_to)
           WHERE transaction_temp_id = l_wdd_table(i);
        l_wdd_table.DELETE;

        print_debug('after bulk update', l_debug);
    END IF;
      print_debug('p_change_priority_to' || p_change_priority_to, l_debug);
    -------------task update end here---------------------*/

    IF p_action_name IS NOT NULL THEN

      apply_saved_action(p_wave_id       => p_wave_id,
                         p_entity        => p_entity,
                         p_entity_value  => p_entity_value,
                         p_action_name   => p_action_name,
                         x_return_status => x_return_status);

      IF x_return_status = fnd_api.g_ret_sts_error OR
         x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        print_DEBUG('Error in apply_saved_action ', l_debug);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        return;
      END IF;

    END IF;

    IF (p_release_back_ordered_lines = 'Yes' OR p_action_name IS NOT NULL) THEN

      UPDATE wms_wp_wave_exceptions_b
         SET status = 'Action Taken'
       WHERE exception_id = p_exception_id;

      update WMS_WP_WAVE_EXCEPTIONS_TL
         set LAST_UPDATE_DATE  = SYSDATE,
             LAST_UPDATED_BY   = fnd_global.user_id,
             LAST_UPDATE_LOGIN = fnd_global.conc_login_id,
             SOURCE_LANG       = userenv('LANG')
       where EXCEPTION_ID = p_exception_id
         and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

    END IF;

    print_debug('p_exception_id = ' || p_exception_id, l_debug);

    print_debug('after update of exceptions table', l_debug);

    -- Temporaryily added

  END;

      -- cancel task changes start

PROCEDURE cancel_mmtt(p_txn_temp_id NUMBER, x_result OUT nocopy VARCHAR2) IS

    x_return_status   VARCHAR2(100);
    x_msg_data        VARCHAR2(100);
    x_msg_count       NUMBER;
    l_txn_temp_id     NUMBER;
    l_mol_id          NUMBER;
    l_moh_id          NUMBER;
    l_res_id          NUMBER;
    l_txn_qty         NUMBER;
    l_prim_qty        NUMBER;
    l_sec_qty         NUMBER;
    l_org_id          NUMBER;
    l_from_sub        VARCHAR2(10);
    l_from_loc        NUMBER;
    l_no_mmtt         NUMBER;
    l_mo_type         NUMBER;
    l_sec_uom         VARCHAR2(3);
    l_qty             NUMBER;
    l_qty_del         NUMBER;
    l_qty_det         NUMBER;
    l_sec_mol_qty     NUMBER;
    l_sec_qty_del     NUMBER;
    l_sec_qty_det     NUMBER;
    l_qty_backorder   NUMBER;

    l_shipping_attr wsh_interface.changedattributetabtype;

  BEGIN

    l_txn_temp_id := p_txn_temp_id;

      SELECT mtrl.move_order_line_id,
             mtrl.move_order_header_id,
             mtrl.reservation_id,
             mtrl.transaction_quantity,
             mtrl.primary_quantity,
             mtrl.secondary_transaction_quantity,
             mtrl.organization_id,
             mtrh.move_order_type
        INTO l_mol_id,
             l_moh_id,
             l_res_id,
             l_txn_qty,
             l_prim_qty,
             l_sec_qty,
             l_org_id,
	     l_mo_type
        FROM mtl_material_transactions_temp mtrl,
         mtl_txn_request_headers mtrh
       WHERE mtrl.transaction_temp_id = l_txn_temp_id
        AND mtrh.header_id = mtrl.move_order_header_id;

      -- move order type :   2:Replenishment    3:Pick Wave    6:Crossdocking

      IF l_mo_type = 6 THEN
        -- cross dock task

        BEGIN

          wms_cross_dock_pvt.cancel_crossdock_task(p_transaction_temp_id => l_txn_temp_id,
                                                   x_return_status       => x_return_status,
                                                   x_msg_data            => x_msg_data,
                                                   x_msg_count           => x_msg_count);

          IF x_return_status = 'S' THEN
            x_result := 'S';
          ELSE
	    x_result := 'E';
          END IF;

        EXCEPTION
	 WHEN OTHERS THEN
	 x_result := 'E';

        END;
      ELSIF l_mo_type = 3 THEN
        -- pick release task
       BEGIN
        SELECT COUNT(*)
          INTO l_no_mmtt
          FROM mtl_material_transactions_temp
         WHERE move_order_line_id = l_mol_id;


        SELECT delivery_detail_id,
               oe_header_id,
               oe_line_id,
               released_status
          INTO l_shipping_attr(1).delivery_detail_id,
               l_shipping_attr(1).source_header_id,
               l_shipping_attr(1).source_line_id,
               l_shipping_attr(1).released_status
          FROM wsh_inv_delivery_details_v
         WHERE move_order_line_id = l_mol_id
           AND move_order_line_id IS NOT NULL
           AND released_status = 'S';

        SELECT from_subinventory_code,
               from_locator_id,
               secondary_uom_code,
               quantity,
               quantity_delivered,
               quantity_detailed,
               secondary_quantity,
               secondary_quantity_delivered,
               secondary_quantity_detailed
          INTO l_from_sub,
               l_from_loc,
               l_sec_uom,
               l_qty,
               l_qty_del,
               l_qty_det,
               l_sec_mol_qty,
               l_sec_qty_del,
               l_sec_qty_det
          FROM mtl_txn_request_lines
         WHERE line_id = l_mol_id;


        /* The below call deletes mtlt, msnt and mmtt. Takes care of everything*/

        inv_mo_backorder_pvt.delete_details(x_return_status        => x_return_status,
                                            x_msg_data             => x_msg_data,
                                            x_msg_count            => x_msg_count,
                                            p_transaction_temp_id  => l_txn_temp_id,
                                            p_move_order_line_id   => l_mol_id,
                                            p_reservation_id       => l_res_id,
                                            p_transaction_quantity => l_txn_qty,
                                            p_primary_trx_qty      => l_prim_qty,
                                            p_secondary_trx_qty    => l_sec_qty);

        IF l_no_mmtt = 1 THEN
          -- only 1 mmtt is there so close the mol

          IF l_sec_uom IS NULL THEN

            UPDATE mtl_txn_request_lines
               SET line_status       = 5,
                   quantity_detailed = (quantity_detailed - l_txn_qty),
                   quantity          = (quantity - l_txn_qty)
             WHERE line_id = l_mol_id;
          ELSE

            UPDATE mtl_txn_request_lines
               SET line_status                 = 5,
                   quantity_detailed           = (quantity_detailed -
                                                 l_txn_qty),
                   secondary_quantity_detailed = (secondary_quantity_detailed -
                                                 l_sec_qty),
                   quantity                    = (quantity - l_txn_qty),
                   secondary_quantity          = (secondary_quantity -
                                                 l_sec_qty),
                   status_date                 = sysdate
             WHERE line_id = l_mol_id;
          END IF;

        ELSE
          -- more than 1 mmtt is there so should not close mol

          IF l_sec_uom IS NULL THEN

            UPDATE mtl_txn_request_lines
               SET quantity_detailed = (quantity_detailed - l_txn_qty),
                   quantity          = (quantity - l_txn_qty)
             WHERE line_id = l_mol_id;
          ELSE

            UPDATE mtl_txn_request_lines
               SET quantity_detailed           = (quantity_detailed -
                                                 l_txn_qty),
                   secondary_quantity_detailed = (secondary_quantity_detailed -
                                                 l_sec_qty),
                   quantity                    = (quantity - l_txn_qty),
                   secondary_quantity          = (secondary_quantity -
                                                 l_sec_qty),
                   status_date                 = sysdate
             WHERE line_id = l_mol_id;
          END IF;

        END IF;

        -- To deal with case of over picking

        /* Conditions checked here are:
              If more qty is already picked then obviously current transaction quantiy
        will be more than qty to backorder which is calculated*/ -- Check with Satish or Ajith

        l_qty_backorder := l_qty - l_qty_del;

        IF l_txn_qty > l_qty_backorder THEN
          l_txn_qty := l_qty_backorder;
          l_sec_qty := l_sec_qty - l_sec_qty_del;
        END IF;

        l_shipping_attr(1).ship_from_org_id := l_org_id;
        l_shipping_attr(1).action_flag := 'B';
        l_shipping_attr(1).cycle_count_quantity := l_txn_qty;
        l_shipping_attr(1).cycle_count_quantity2 := l_sec_qty;
        l_shipping_attr(1).subinventory := l_from_sub;
        l_shipping_attr(1).locator_id := l_from_loc;

        /* The below call splits the wdd or backorders the line accordingly*/

        wsh_interface.update_shipping_attributes(p_source_code        => 'INV',
                                                 p_changed_attributes => l_shipping_attr,
                                                 x_return_status      => x_return_status);

        IF x_return_status = 'S' THEN
          x_result := 'S';
        ELSE
	  x_result := 'E';
        END IF;

	EXCEPTION
	WHEN OTHERS THEN
	x_result := 'E';

	END;


      ELSIF l_mo_type = 2 THEN
        -- replenishment task
        -- Replenishment task is not eligible for cancelling
        -- print a message that the task is ineligible for cancellation
        -- pass the value of txn temp id to the calling procedure
	     x_result := 'R';
      END IF;

  EXCEPTION

  WHEN OTHERS THEN
  -- print some debug message and return fail
  x_result := 'E';

  END cancel_mmtt;


  -- cancel task changes end

end WMS_WAVE_PLANNING_PVT;


/
