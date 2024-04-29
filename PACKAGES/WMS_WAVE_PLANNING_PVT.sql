--------------------------------------------------------
--  DDL for Package WMS_WAVE_PLANNING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_WAVE_PLANNING_PVT" 
/* $Header: WMSWVPVS.pls 120.7.12010000.6 2009/11/10 18:05:37 ajunnikr noship $ */
 AUTHID CURRENT_USER as
  -- PACKAGE TYPES
  --
    TYPE line_tbl_typ IS TABLE OF wms_wp_wave_lines%ROWTYPE INDEX BY BINARY_INTEGER;
  TYPE action_tbl_typ IS TABLE OF varchar2(6) INDEX BY BINARY_INTEGER;

  TYPE relRecTyp IS RECORD(
    SOURCE_CODE                 VARCHAR2(30),
    SOURCE_HEADER_ID            NUMBER,
    SOURCE_LINE_ID              NUMBER,
    SOURCE_HEADER_NUMBER        VARCHAR2(150),
    SOURCE_LINE_NUMBER          VARCHAR2(150),
    SOURCE_HEADER_TYPE_NAME     VARCHAR2(240),
    SOURCE_HEADER_TYPE_ID       NUMBER,
    SOURCE_DOCUMENT_TYPE_ID     NUMBER,
    DELIVERY_DETAIL_ID          NUMBER,
    RELEASED_STATUS             VARCHAR2(1),
    ORGANIZATION_ID             NUMBER,
    INVENTORY_ITEM_ID           NUMBER,
    REQUESTED_QUANTITY          NUMBER,
    REQUESTED_QUANTITY_UOM      VARCHAR2(3),
    PRIMARY_QUANTITY            NUMBER,
    PRIMARY_UOM_CODE            VARCHAR2(3),
    MOVE_ORDER_LINE_ID          NUMBER,
    SHIP_MODEL_COMPLETE_FLAG    VARCHAR2(1),
    TOP_MODEL_LINE_ID           NUMBER,
    SHIP_FROM_LOCATION_ID       NUMBER,
    SHIP_TO_LOCATION_ID         NUMBER,
    SHIP_METHOD_CODE            VARCHAR2(30),
    SHIPMENT_PRIORITY_CODE      VARCHAR2(30),
    SHIP_SET_ID                 NUMBER,
    DATE_SCHEDULED              DATE,
    PLANNED_DEPARTURE_DATE      DATE,
    DELIVERY_ID                 NUMBER,
    CUSTOMER_ID                 NUMBER,
    CARRIER_ID                  NUMBER,
    PREFERRED_GRADE             VARCHAR2(150),
    REQUESTED_QUANTITY2         NUMBER,
    REQUESTED_QUANTITY_UOM2     VARCHAR2(3),
    PROJECT_ID                  NUMBER,
    TASK_ID                     NUMBER,
    FROM_SUBINVENTORY_CODE      VARCHAR2(10),
    TO_SUBINVENTORY_CODE        VARCHAR2(10),
    END_ITEM_UNIT_NUMBER        VARCHAR2(30),
    RESERVABLE_TYPE             NUMBER,
    DEMAND_SOURCE_HEADER_ID     NUMBER,
    OUTSTANDING_ORDER_VALUE     NUMBER,
    COUNT_ORDER_LINES           NUMBER,
    NET_WEIGHT_UOM_CODE         VARCHAR2(3),
    NET_WEIGHT                  NUMBER,
    NET_WEIGHT_MAX_OL_UOM_CODE  NUMBER,
    VOLUME_UOM_CODE             VARCHAR2(3),
    VOLUME                      NUMBER,
    VOLUME_MAX_OL_CUBE_UOM_CODE NUMBER,
    NET_VALUE                   NUMBER,
    DELIVER_SNAPSHOT_DATE       DATE);

  TYPE labor_plan_Record IS RECORD(
    picking_subinventory   varchar2(4000),
    SOURCE_SUBINVENTORY    varchar2(4000),
    picking_uom            varchar2(4000),
    conversion_rate        number,
    att                    number,
    demand_qty_picking_uom number default 0,
    demand_quantity        number);

  TYPE labor_time_Record IS RECORD(
    picking_subinventory     varchar2(4000),
    destination_SUBINVENTORY varchar2(4000),
    picking_uom              varchar2(4000),
    demand_qty_picking_uom   number default 0,
    operation_plan_id number,
    inventory_item_id number,
    standard_operation_id number);

  n1 number := 0;

  TYPE labor_plan_tbl IS TABLE OF labor_plan_Record INDEX BY BINARY_INTEGER;

  TYPE labor_time_tbl IS TABLE OF labor_time_record INDEX BY BINARY_INTEGER;

  x_labor_plan_tbl labor_plan_tbl;

  ideal_labor_plan_tbl labor_plan_tbl;

  x_labor_time_tbl labor_time_tbl;

  c_labor_time_tbl labor_time_tbl;


----------  RESOURCE CAPACITY DETAILS ---------
TYPE resource_capacity_record IS RECORD(
resource_name VARCHAR2(100),
resource_type NUMBER,
total_capacity NUMBER default 0,
available_capacity NUMBER default 0,
planned_load NUMBER default 0,
current_load NUMBER default 0,
planned_tasks NUMBER default 0,
actual_tasks NUMBER default 0
);

TYPE resource_capacity_tbl IS TABLE OF resource_capacity_record INDEX BY BINARY_INTEGER;
x_resource_capacity_tbl resource_capacity_tbl;
----------  RESOURCE CAPACITY DETAILS ---------

-- labor planning

/*TYPE labor_details_record IS RECORD(
      resource_name VARCHAR2(100),
      source_subinventory VARCHAR2(100),
      destination_subinventory VARCHAR2(100),
      pick_uom VARCHAR2(25),
      transaction_time number,
      travel_time number,
      resource_type number);

      type machine_details_record is record(
      	resource_name varchar2(100),
      	source_subinventory varchar2(100),
      	destination_subinventory varchar2(100),
      	pick_uom varchar2(25),
      	resource_type number
      	);

    TYPE labor_dtl_tbl IS TABLE OF labor_details_record INDEX BY BINARY_INTEGER;
    	type machine_dtl_tbl is table of machine_details_record index by binary_integer;

    x_labor_dtl_tbl labor_dtl_tbl;
    x_machine_dtl_tbl machine_dtl_tbl;

    TYPE labor_statistics_Record IS RECORD(
      resource_name           varchar2(100),
      total_time_per_Resource NUMBER DEFAULT 0,
      planned_wave_load       NUMBER DEFAULT 0,
      total_Capacity          NUMBER DEFAULT 0,
      current_workload number default 0, -- sudheer
      number_of_tasks  NUMBER DEFAULT 0,  -- sudheer
      resource_type number, -- sudheer
      available_capacity NUMBER DEFAULT 0, -- sudheer
      number_of_planned_tasks NUMBER DEFAULT 0); -- sudheer

    TYPE labor_stats_tbl IS TABLE OF labor_statistics_Record INDEX BY BINARY_INTEGER;

    x_labor_stats_tbl labor_stats_tbl;
    x_labor_stats_tbl_tmp labor_stats_tbl;
    */
-- Labor Planning

      tbl_index number := 0;

  TYPE num_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE uom_tab IS TABLE OF VARCHAR2(3) INDEX BY BINARY_INTEGER;
  TYPE date_tab IS TABLE OF DATE INDEX BY BINARY_INTEGER;
  TYPE char_tab IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
  TYPE char1_tab IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;
  TYPE number_table_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE relRecTabTyp IS TABLE OF relRecTyp INDEX BY BINARY_INTEGER;

  TYPE query_type_table_type IS TABLE OF wms_saved_queries.query_type%TYPE INDEX BY BINARY_INTEGER;
  TYPE field_name_table_type IS TABLE OF wms_saved_queries.field_name%TYPE INDEX BY BINARY_INTEGER;
  TYPE field_value_table_type IS TABLE OF wms_saved_queries.field_value%TYPE INDEX BY BINARY_INTEGER;
  TYPE organization_id_table_type IS TABLE OF wms_saved_queries.organization_id%TYPE INDEX BY BINARY_INTEGER;

  -- PUBLIC VARIABLES
  --
  release_table                relRecTabTyp;
  g_application_id             NUMBER;
  g_program_id                 NUMBER;
  g_request_id                 NUMBER;
  g_user_id                    NUMBER;
  g_login_id                   NUMBER;
  g_batch_name                 VARCHAR2(30);
  g_to_request_date            DATE;
  g_from_sched_ship_date       DATE;
  g_to_sched_ship_date         DATE;
  g_append_flag                VARCHAR2(1);
  g_ship_set_smc_flag          VARCHAR2(1);
  g_use_delivery_ps            VARCHAR2(1) := 'N';
  g_allocation_method          VARCHAR2(1);
  g_crossdock_criteria_id      NUMBER;
  g_actual_departure_date      DATE;
  g_credit_check_option        VARCHAR2(1) := NULL;
  g_sql_stmt                   VARCHAR2(32767);
  g_honor_pick_from            VARCHAR2(1) := 'Y';
  g_dynamic_replenishment_flag VARCHAR2(1);
  g_initialized                BOOLEAN := FALSE;
  -- g_ordered_psr                   psrTabTyp;
  --   g_use_order_ps                  VARCHAR2(1) := 'Y';
  --   g_total_pick_criteria           NUMBER;
  g_order_type_id           NUMBER;
  g_order_line_id           NUMBER;
  g_order_header_id         NUMBER;
  g_backorders_flag         VARCHAR2(1);
  g_include_planned_lines   VARCHAR2(1);
  g_del_line_id             NUMBER;
  g_del_lines_list          VARCHAR2(100);
  g_customer_id             NUMBER;
  g_from_request_date       DATE;
  g_existing_rsvs_only_flag VARCHAR2(1);
  g_inventory_item_id       NUMBER;
  g_shipment_priority       VARCHAR2(30);
  g_ship_method_code        VARCHAR2(30);
  g_ship_set_number         NUMBER;
  g_ship_to_loc_id          NUMBER;
  g_ship_from_loc_id        NUMBER;
  g_project_id              NUMBER;
  g_task_id                 NUMBER;
  g_doc_set_id              NUMBER;
  g_Unreleased_SQL          VARCHAR(32000) := NULL;
  g_Backordered_SQL         VARCHAR(4000) := NULL;
  g_Cond_SQL                VARCHAR(4000) := NULL;
  g_orderby_SQL             VARCHAR2(500) := NULL;
  g_from_subinventory       VARCHAR2(10);
  g_from_locator            VARCHAR2(10);
  g_DELIVERY_ID             NUMBER;
  g_trip_id                 number;
  g_trip_stop_id            number;
  g_pick_seq_rule_id        number;
  g_pick_grouping_rule_id   number;
  g_to_dock_appoint_date    date;
  g_from_dock_appoint_date  date;
  g_customer_class_id       varchar2(100);
  g_carrier_id              NUMBER;
  g_item_category_id        NUMBER;
  g_add_lines               varchar2(1);
  new_wave_type             WSH_PICKING_BATCHES_PUB.Batch_Info_Rec;

  --Variables and Tables for manage tasks

  TYPE transaction_temp_table_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE task_type_id_table_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE task_id_table_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE result_table_type IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;
  TYPE message_table_type IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
  g_task_updated   wms_wp_tasks_gtmp.error%TYPE;
  g_plan_cancelled wms_wp_tasks_gtmp.error%TYPE;
  g_task_saved     wms_wp_tasks_gtmp.error%TYPE;
  TYPE lookup_meaning_table IS TABLE OF mfg_lookups.meaning%TYPE INDEX BY BINARY_INTEGER;
  TYPE row_ids_table_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE lookup_meaning_table_type IS TABLE OF mfg_lookups.meaning%TYPE INDEX BY BINARY_INTEGER;

  g_task_types             lookup_meaning_table;
  g_task_types_orig        lookup_meaning_table;
  g_status_codes           lookup_meaning_table;
  g_status_codes_orig      lookup_meaning_table;
  g_plan_task_types        lookup_meaning_table;
  g_plan_task_types_orig   lookup_meaning_table;
  g_plan_status_codes      lookup_meaning_table;
  g_plan_status_codes_orig lookup_meaning_table;

  g_task_type_pick      CONSTANT NUMBER := 1;
  g_task_type_replenish CONSTANT NUMBER := 4;
  g_planning_criteria_id number;


 -- Rule based Planning


g_from_subinventory_plan varchar2(30);
g_staging_subinventory_plan VARCHAR2(30);
g_pick_subinventory VARCHAR2(30);
g_default_stage_subinventory VARCHAR2(30);
g_default_stage_locator_id NUMBER;
g_enforce_ship_set_and_smc VARCHAR2(1);
g_to_subinventory varchar(30);
g_to_locator NUMBER;
 g_staging_subinventory VARCHAR2(30);
g_mo_header_id number;
g_request_number number;



  PROCEDURE launch_concurrent_CP(errbuf               OUT NOCOPY VARCHAR2,
                                 retcode              OUT NOCOPY NUMBER,
                                 p_wave_template_name in varchar2,
                                 p_wave_header_id     in number,
                                 p_org_id             in number);

  PROCEDURE submit_WP_conc_request(p_wave_header_id in number,
                                   p_org_id         in number,
                                   x_request_id     OUT NOCOPY number);

  procedure insert_wave_record(p_wave_header_id in OUT NOCOPY number);

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
                                add_lines              in varchar2 default 'N');

  -- Insert Wave Header requires jus the PL/SQL record wave_header_rec as IN parameter

  procedure insert_wave_header(x_return_status   OUT nocopy VARCHAR2,
                               p_wave_header_rec in wms_wp_wave_headers_vl%ROWTYPE);

  procedure launch_online(x_return_status     OUT nocopy VARCHAR2,
                          p_wave_header_id    IN NUMBER,
                          v_orgid             in number,
                          p_release_immediate in varchar2,
                          p_plan_wave         in varchar2,
                          p_request_id        OUT NOCOPY number,
                          p_add_lines         in varchar2 default 'N');

  procedure create_batch_record(x_return_status  OUT nocopy varchar2,
                                p_wave_header_id in number);

  PROCEDURE Plan_Wave_CP(errbuf                 OUT NOCOPY VARCHAR2,
                         retcode                OUT NOCOPY NUMBER,
                         p_wave_header_id       in number,
                         p_planning_criteria_id in number);

  PROCEDURE Call_Plan_Wave_CP(p_wave_header_id       in number,
                              p_planning_criteria_id in number,
                              p_request_id           OUT NOCOPY number);

  PROCEDURE Release_Batch_CP(errbuf           OUT NOCOPY VARCHAR2,
                             retcode          OUT NOCOPY NUMBER,
                             p_wave_header_id in number);

  procedure get_dynamic_sql(p_wave_header_id in number,
                            org_id           in number,
                            x_return_status  OUT NOCOPY varchar2);

  Procedure Init_Cursor(p_organization_id IN NUMBER,
                        v_advanced_sql    in varchar2,
                        v_WAVE_HEADER_ID  in NUMBER,
                        x_api_status      OUT NOCOPY VARCHAR2);

  PROCEDURE Get_Lines(x_done_flag  OUT NOCOPY VARCHAR2,
                      x_api_status OUT NOCOPY VARCHAR2);

  PROCEDURE Insert_RL_Row(x_api_status OUT NOCOPY VARCHAR2);
  procedure Plan_Wave(p_wave_header_id       in number,
                      p_planning_criteria_id in number,
                      x_return_status        OUT NOCOPY varchar2);
  PROCEDURE RELEASE_ONLINE(X_RETURN_STATUS  OUT NOCOPY VARCHAR2,
                           P_WAVE_HEADER_ID IN NUMBER);

  procedure get_line_fill_rate(x_return_status  OUT NOCOPY varchar2,
                               p_wave_header_id in number);

  procedure get_actual_fill_rate(x_return_status  OUT NOCOPY varchar2,
                                 p_wave_header_id in number);

  procedure update_wave_header_status(x_return_status  OUT NOCOPY varchar2,
                                      p_wave_header_id in number,
                                      Status           in varchar2);

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
                        x_msg_count             OUT NOCOPY NUMBER);

  PROCEDURE save_tasks(p_commit        BOOLEAN,
                       p_user_id       NUMBER,
                       p_login_id      NUMBER,
                       x_save_count    OUT NOCOPY NUMBER,
                       x_return_status OUT NOCOPY VARCHAR2,
                       x_msg_data      OUT NOCOPY VARCHAR2,
                       x_msg_count     OUT NOCOPY NUMBER);
  -- Sudheer
  FUNCTION getforcesignonflagvalue(p_transaction_temp_id IN mtl_material_transactions_temp.transaction_temp_id%TYPE,
                                   p_device_id           OUT NOCOPY NUMBER)
    RETURN VARCHAR2;
  PROCEDURE set_num_of_child_tasks;

  PROCEDURE Update_Completion_Status_CP(errbuf  OUT NOCOPY VARCHAR2,
                                        retcode OUT NOCOPY NUMBER);
  procedure get_pick_fill_rate(x_return_status OUT NOCOPY varchar2);

  procedure labor_planning(p_wave_header_id       in number,
                           p_planning_criteria_id in number,
                           x_return_status        OUT NOCOPY varchar2);

  FUNCTION get_conversion_rate(p_item_id       IN NUMBER,
                               p_from_uom_code IN VARCHAR2,
                               p_to_uom_code   IN VARCHAR2) RETURN NUMBER;

  FUNCTION get_att_for_subinventory(p_sub     IN VARCHAR2,
                                    p_item_id IN NUMBER,
                                    p_org_id  IN NUMBER) RETURN NUMBER;

  procedure get_ideal_pick_scenario(p_requested_qty in number,
                                    x_return_status OUT NOCOPY varchar2);

  function get_source_subinventory(p_item_id      in number,
                                   p_subinventory in varchar2)
    return varchar2;

  procedure synchronize_labor_plan_tables(x_return_status            OUT NOCOPY varchar2,
                                          p_replenishment_Required   in varchar2,
                                          v_Destination_subinventory in varchar2);

  procedure update_bulk_labor_record(x_labor_plan_tbl           in OUT NOCOPY labor_plan_tbl,
                                     v_replenishment_required   in varchar2,
                                     v_destination_subinventory in varchar2,
                                     p_demand_qty               in OUT NOCOPY number,
                                     x_return_status            OUT NOCOPY varchar2);

  procedure Check_wave_closed_status(x_return_status OUT NOCOPY varchar2);

  function get_loaded_status(p_Delivery_Detail_id in number) return number;

  function get_order_weight(p_source_header_id in number,
                            p_orgid            in number) return number;

  function get_order_volume(p_source_header_id in number,
                            p_orgid            in number) return number;

  procedure get_net_weight_volume(p_wave_header_id in number,
                                  p_orgid          in number,
                                  x_weight         OUT NOCOPY varchar2,
                                  x_volume         OUT NOCOPY varchar2);
  -- Name
  --   FUNCTION Outstanding_Order_Value
  --
  -- Purpose
  --   This functions calculates the value of the order, which
  --   is used in the order by clause for releasing lines.
  --
  -- Arguments
  --   p_header_id ,p_line_id
  --
  -- Return Values
  --   - value of order
  --   - 0 if failure
  --
  -- Notes

  FUNCTION Outstanding_Order_Value(p_header_id IN BINARY_INTEGER,
                                   p_line_id   IN BINARY_INTEGER)
    RETURN BINARY_INTEGER;

  PROCEDURE print_debug(p_err_msg VARCHAR2, p_debug NUMBER);

  PROCEDURE print_form_messages(p_err_msg VARCHAR2);

  PROCEDURE SET_QUERY_TASKS_PARAMETERS(p_field_name_table      IN wms_wave_planning_pvt.field_name_table_type,
                                       p_field_value_table     IN wms_wave_planning_pvt.field_value_table_type,
                                       p_organization_id_table IN wms_wave_planning_pvt.organization_id_table_type,
                                       p_query_type_table      IN wms_wave_planning_pvt.query_type_table_type,
                                       x_return_status         OUT NOCOPY VARCHAR2,
                                       x_return_message        OUT NOCOPY VARCHAR2);

  PROCEDURE SET_ACTION_TASKS_PARAMETERS(p_field_name_table  IN wms_wave_planning_pvt.field_name_table_type,
                                        p_field_value_table IN wms_wave_planning_pvt.field_value_table_type,
                                        p_query_type_table  IN wms_wave_planning_pvt.query_type_table_type,
                                        x_return_status     OUT NOCOPY VARCHAR2,
                                        x_return_message    OUT NOCOPY VARCHAR2);

  PROCEDURE Task_Release_CP(errbuf             OUT NOCOPY VARCHAR2,
                            retcode            OUT NOCOPY NUMBER,
                            p_organization_id  in number,
                            p_query_name       in varchar2,
                            p_task_release_id in number);

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
                                     p_action_name                  IN VARCHAR2);

  PROCEDURE insert_purge_exceptions(p_exception_name       IN VARCHAR2,
                                    p_exception_entity     IN VARCHAR2,
                                    p_exception_level      IN VARCHAR2,
                                    p_completion_threshold IN NUMBER,
                                    p_progress_stage       IN VARCHAR2,
                                    p_exception_threshold  IN NUMBER,
                                    p_wave_id              IN NUMBER,
                                    p_trip_id              IN NUMBER,
                                    p_delivery_id          IN NUMBER,
                                    p_order_number         IN NUMBER,
                                    p_order_line_id        IN NUMBER,
                                    x_return_status        OUT NOCOPY VARCHAR2);

  PROCEDURE check_so(p_current_order    IN NUMBER,
                     p_current_delivery IN NUMBER,
                     p_current_trip     IN NUMBER,
                     p_organization_id  IN NUMBER);


PROCEDURE check_line(p_current_line in NUMBER,
                     p_current_delivery in NUMBER,
                     p_current_trip in NUMBER,
                     p_organization_id in NUMBER);


  PROCEDURE take_corrective_measures(p_exception_id               IN NUMBER,
                                     p_wave_id                    IN NUMBER,
                                     p_entity                     IN VARCHAR2,
                                     p_entity_value               IN NUMBER,
                                     p_release_back_ordered_lines IN VARCHAR2,
                                     p_action_name                IN VARCHAR2,
                                     p_organization_id            IN NUMBER);

  PROCEDURE actionable_exceptions(p_perfect_lines                IN NUMBER,
                                  p_total_lines                  IN NUMBER,
                                  p_completion_threshold         IN NUMBER,
                                  p_low_sev_exception_threshold  IN NUMBER,
                                  p_high_sev_exception_threshold IN NUMBER,
                                  p_date_scheduled               IN DATE,
                                  p_exception_id                 IN NUMBER,
                                  p_exception_name               IN VARCHAR2,
                                  p_wave_id                      IN NUMBER,
                                  p_trip_id                      IN NUMBER,
                                  p_delivery_id                  IN NUMBER,
                                  p_order_number                 IN NUMBER,
                                  p_order_line_id                IN NUMBER,
                                  p_current_order_id             IN NUMBER,
                                  p_previous_order_id            IN OUT NOCOPY NUMBER,
                                  p_current_line_id       IN  NUMBER,
                                  p_previous_line_id  IN OUT NOCOPY NUMBER,
                                  p_entity                       IN VARCHAR2,
                                  p_entity_value                 IN NUMBER,
                                  p_progress_stage               IN VARCHAR2,
                                  p_take_corrective_measures     IN VARCHAR2,
                                  p_release_back_ordered_lines   IN VARCHAR2,
                                  p_action_name                  IN VARCHAR2,
                                  p_organization_id              IN NUMBER);

 -- function get_packed_status(p_task_id in number) return boolean;

  function check_min_equip_Capacity(l_mmtt_tbl in number_table_type)
    return boolean;

  function get_net_value(p_wave_header_id in number) return varchar2;

  PROCEDURE cancel_mmtt(p_txn_temp_id NUMBER, x_result OUT nocopy VARCHAR2);

  PROCEDURE allocation (errbuf              OUT   NOCOPY   VARCHAR2,
                      retcode             OUT   NOCOPY   NUMBER,
                      p_organization_id IN NUMBER,
                      p_wave_id        IN NUMBER,
                      p_mo_header_id    IN NUMBER,
                      p_mode            IN VARCHAR2,
                      p_worker_id       IN NUMBER DEFAULT null
                     );


   procedure get_current_work_load(p_resource             in varchar2,
                                  p_planning_criteria_id in number,
                                  p_wave_header_id       in number,
                                  x_current_workload     out nocopy number,
                                  x_resource_type        out nocopy NUMBER,
                                  x_number_of_tasks      OUT nocopy NUMBER,
                                  x_total_capacity       out nocopy NUMBER );



END WMS_WAVE_PLANNING_PVT;


/
