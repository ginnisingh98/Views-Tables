--------------------------------------------------------
--  DDL for Package WMS_PLAN_TASKS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_PLAN_TASKS_PVT" AUTHID CURRENT_USER AS
/* $Header: WMSPTKPS.pls 120.4.12010000.1 2008/07/28 18:36:10 appldev ship $*/

    g_is_add                                   BOOLEAN DEFAULT FALSE;
    g_organization_id                          NUMBER DEFAULT NULL;
    g_subinventory_code                        VARCHAR2(10) DEFAULT NULL;
    g_locator_id                               NUMBER DEFAULT NULL;
    g_to_subinventory_code                     VARCHAR2(10) DEFAULT NULL;
    g_to_locator_id                            NUMBER DEFAULT NULL;
    g_inventory_item_id                        NUMBER DEFAULT NULL;
    g_category_set_id                          NUMBER DEFAULT NULL;
    g_item_category_id                         NUMBER DEFAULT NULL;
    g_person_id                                NUMBER DEFAULT NULL;
    g_person_resource_id                       NUMBER DEFAULT NULL;
    g_equipment_type_id                        NUMBER DEFAULT NULL;
    g_machine_resource_id                      NUMBER DEFAULT NULL;
    g_machine_instance                         VARCHAR2(30) DEFAULT NULL;
    g_user_task_type_id                        NUMBER DEFAULT NULL;
    g_from_task_quantity                       NUMBER DEFAULT NULL;
    g_to_task_quantity                         NUMBER DEFAULT NULL;
    g_from_task_priority                       NUMBER DEFAULT NULL;
    g_to_task_priority                         NUMBER DEFAULT NULL;
    g_from_creation_date                       DATE DEFAULT NULL;
    g_to_creation_date                         DATE DEFAULT NULL;
    g_is_unreleased_task                       BOOLEAN DEFAULT FALSE;
    g_is_pending_task                          BOOLEAN DEFAULT FALSE;
    g_is_queued_task                           BOOLEAN DEFAULT FALSE;
    g_is_dispatched_task                       BOOLEAN DEFAULT FALSE;
    g_is_active_task                           BOOLEAN DEFAULT FALSE;
    g_is_loaded_task                           BOOLEAN DEFAULT FALSE;
    g_is_completed_task                        BOOLEAN DEFAULT FALSE;
    g_include_inbound                          BOOLEAN DEFAULT FALSE;
    g_include_outbound                         BOOLEAN DEFAULT FALSE;
    g_include_crossdock                        BOOLEAN DEFAULT FALSE;
    g_include_manufacturing                    BOOLEAN DEFAULT FALSE;
    g_include_warehousing                      BOOLEAN DEFAULT FALSE;
    g_from_po_header_id                        NUMBER DEFAULT NULL;
    g_to_po_header_id                          NUMBER DEFAULT NULL;
    g_from_purchase_order                      VARCHAR2(30) DEFAULT NULL;
    g_to_purchase_order                        VARCHAR2(30) DEFAULT NULL;
    g_from_rma_header_id                       NUMBER DEFAULT NULL;
    g_to_rma_header_id                         NUMBER DEFAULT NULL;
    g_from_rma                                 VARCHAR2(30) DEFAULT NULL;
    g_to_rma                                   VARCHAR2(30) DEFAULT NULL;
    g_from_requisition_header_id               NUMBER DEFAULT NULL;
    g_to_requisition_header_id                 NUMBER DEFAULT NULL;
    g_from_requisition                         VARCHAR2(30) DEFAULT NULL;
    g_to_requisition                           VARCHAR2(30) DEFAULT NULL;
    g_from_shipment_number                     VARCHAR2(30) DEFAULT NULL;
    g_to_shipment_number                       VARCHAR2(30) DEFAULT NULL;
    g_include_sales_orders                     BOOLEAN DEFAULT TRUE;
    g_include_internal_orders                  BOOLEAN DEFAULT TRUE;
    g_from_sales_order_id                      NUMBER DEFAULT NULL;
    g_to_sales_order_id                        NUMBER DEFAULT NULL;
    g_from_pick_slip_number                    NUMBER DEFAULT NULL;
    g_to_pick_slip_number                      NUMBER DEFAULT NULL;
    g_customer_id                              NUMBER DEFAULT NULL;
    g_customer_category                        VARCHAR2(30) DEFAULT NULL;
    g_delivery_id                              NUMBER DEFAULT NULL;
    g_carrier_id                               NUMBER DEFAULT NULL;
    g_ship_method                              VARCHAR2(30) DEFAULT NULL;
    g_shipment_priority                        VARCHAR2(30) DEFAULT NULL;
    g_trip_id                                  NUMBER DEFAULT NULL;
    g_from_shipment_date                       DATE DEFAULT NULL;
    g_to_shipment_date                         DATE DEFAULT NULL;
    g_ship_to_state                            VARCHAR2(30) DEFAULT NULL;
    g_ship_to_country                          VARCHAR2(30) DEFAULT NULL;
    g_ship_to_postal_code                      VARCHAR2(30) DEFAULT NULL;
    g_from_number_of_order_lines               NUMBER DEFAULT NULL;
    g_to_number_of_order_lines                 NUMBER DEFAULT NULL;
    g_manufacturing_type                       VARCHAR2(30) DEFAULT NULL;
    g_from_job                                 VARCHAR2(240) DEFAULT NULL;
    g_to_job                                   VARCHAR2(240) DEFAULT NULL;
    g_assembly_id                              NUMBER DEFAULT NULL;
    g_from_start_date                          DATE DEFAULT NULL;
    g_to_start_date                            DATE DEFAULT NULL;
    g_from_line                                VARCHAR2(30) DEFAULT NULL;
    g_to_line                                  VARCHAR2(30) DEFAULT NULL;
    g_department_id                            NUMBER DEFAULT NULL;
    g_include_replenishment                    BOOLEAN DEFAULT TRUE;
    g_from_replenishment_mo                    VARCHAR2(30) DEFAULT NULL;
    g_to_replenishment_mo                      VARCHAR2(30) DEFAULT NULL;
    g_include_mo_transfer                      BOOLEAN DEFAULT TRUE;
    g_include_mo_issue                         BOOLEAN DEFAULT TRUE;
    g_from_transfer_issue_mo                   VARCHAR2(30) DEFAULT NULL;
    g_to_transfer_issue_mo                     VARCHAR2(30) DEFAULT NULL;
    g_include_lpn_putaway                      BOOLEAN DEFAULT TRUE;
    g_include_staging_move                     BOOLEAN DEFAULT FALSE;
    g_include_cycle_count                      BOOLEAN DEFAULT TRUE;
    g_cycle_count_name                         VARCHAR2(30) DEFAULT NULL;

    g_is_pending_plan                          BOOLEAN DEFAULT FALSE;
    g_is_inprogress_plan                       BOOLEAN DEFAULT FALSE;
    g_is_completed_plan                        BOOLEAN DEFAULT FALSE;
    g_is_cancelled_plan                        BOOLEAN DEFAULT FALSE;
    g_is_aborted_plan                          BOOLEAN DEFAULT FALSE;
    g_activity_id                              NUMBER DEFAULT NULL;
    g_plan_type_id                             NUMBER DEFAULT NULL;
    g_op_plan_id                               NUMBER DEFAULT NULL;
    g_inbound_specific_query                   BOOLEAN DEFAULT FALSE;
    g_outbound_specific_query                  BOOLEAN DEFAULT FALSE;

    g_query_independent_tasks                  BOOLEAN DEFAULT TRUE;
    g_query_planned_tasks                      BOOLEAN DEFAULT TRUE;
  /*Bug 3627575:Added variable to change the where clause in get_generic_where*/
    g_from_inbound                             BOOLEAN DEFAULT FALSE;

    g_plans_tasks_record_count                 NUMBER;
    g_task_types             wms_waveplan_tasks_pvt.lookup_meaning_table;
    g_task_types_orig        wms_waveplan_tasks_pvt.lookup_meaning_table;
    g_status_codes           wms_waveplan_tasks_pvt.lookup_meaning_table;
    g_status_codes_orig      wms_waveplan_tasks_pvt.lookup_meaning_table;
    g_plan_task_types        wms_waveplan_tasks_pvt.lookup_meaning_table;
    g_plan_task_types_orig   wms_waveplan_tasks_pvt.lookup_meaning_table;
    g_plan_status_codes      wms_waveplan_tasks_pvt.lookup_meaning_table;
    g_plan_status_codes_orig wms_waveplan_tasks_pvt.lookup_meaning_table;

    g_allocated_lpn_visible        jtf_custom_grid_cols.visible_flag%TYPE;
    g_assembly_visible             jtf_custom_grid_cols.visible_flag%TYPE;
    g_carrier_visible              jtf_custom_grid_cols.visible_flag%TYPE;
    g_cartonization_lpn_visible    jtf_custom_grid_cols.visible_flag%TYPE;
    g_container_item_visible       jtf_custom_grid_cols.visible_flag%TYPE;
    g_content_lpn_visible          jtf_custom_grid_cols.visible_flag%TYPE;
    g_customer_visible             jtf_custom_grid_cols.visible_flag%TYPE;
    g_delivery_visible             jtf_custom_grid_cols.visible_flag%TYPE;
    g_department_visible           jtf_custom_grid_cols.visible_flag%TYPE;
    g_line_visible                 jtf_custom_grid_cols.visible_flag%TYPE;
    g_line_number_visible          jtf_custom_grid_cols.visible_flag%TYPE;
    g_machine_resource_visible     jtf_custom_grid_cols.visible_flag%TYPE;
    g_person_visible               jtf_custom_grid_cols.visible_flag%TYPE;
    g_person_resource_visible      jtf_custom_grid_cols.visible_flag%TYPE;
    g_ship_method_visible          jtf_custom_grid_cols.visible_flag%TYPE;
    g_ship_to_country_visible      jtf_custom_grid_cols.visible_flag%TYPE;
    g_ship_to_postal_code_visible  jtf_custom_grid_cols.visible_flag%TYPE;
    g_ship_to_state_visible        jtf_custom_grid_cols.visible_flag%TYPE;
    g_source_header_visible        jtf_custom_grid_cols.visible_flag%TYPE;
    g_status_visible               jtf_custom_grid_cols.visible_flag%TYPE;
    g_task_type_visible            jtf_custom_grid_cols.visible_flag%TYPE;
    g_to_locator_visible           jtf_custom_grid_cols.visible_flag%TYPE;
    g_to_lpn_visible               jtf_custom_grid_cols.visible_flag%TYPE;
    g_from_lpn_visible             jtf_custom_grid_cols.visible_flag%TYPE;
    g_to_organization_code_visible jtf_custom_grid_cols.visible_flag%TYPE;
    g_transaction_action_visible   jtf_custom_grid_cols.visible_flag%TYPE;
    g_txn_source_type_visible      jtf_custom_grid_cols.visible_flag%TYPE;
    g_operation_plan_visible       jtf_custom_grid_cols.visible_flag%TYPE;
    g_user_task_type_visible       jtf_custom_grid_cols.visible_flag%TYPE;
    g_num_of_child_tasks_visible   jtf_custom_grid_cols.visible_flag%TYPE;
    g_op_plan_instance_id_visible  jtf_custom_grid_cols.visible_flag%TYPE;
    g_operation_sequence_visible   jtf_custom_grid_cols.visible_flag%TYPE;

    -- Bug #3754781 +1 line.
    g_inbound_cycle                BOOLEAN DEFAULT FALSE;

    TYPE planned_record IS RECORD(
                                  is_pending BOOLEAN := FALSE,
                                  is_loaded BOOLEAN := FALSE,
                                  is_completed BOOLEAN := FALSE
                                 );

    g_planned_tasks_rec planned_record;

    SUBTYPE long_sql IS VARCHAR2(32767);
    SUBTYPE short_sql IS VARCHAR2(3000);

    /* Procedure to write the log messages */
    PROCEDURE DEBUG(
                    p_message VARCHAR2,
                    p_module VARCHAR2 DEFAULT 'Plans_tasks'
                   );

    /* wrapper procedure to fetch the inbound tasks */
    PROCEDURE query_inbound_plan_tasks(x_return_status OUT NOCOPY VARCHAR2, p_summary_mode NUMBER DEFAULT 0);

    /* Procedure to fetch the plans specific query */
    PROCEDURE get_plans(x_plans_query_str OUT NOCOPY VARCHAR2);

    /* Procedure to fetch the tasks specific query */
    PROCEDURE get_tasks(x_tasks_query_str OUT NOCOPY VARCHAR2, p_summary_mode NUMBER DEFAULT 0);

    /* Common Procedure to get the insert stmt */
    PROCEDURE get_col_list(x_col_list_str OUT NOCOPY VARCHAR2);

    /* Procedure to fetch completed task records from mmt and wdth
     * This is more relevant for the Pre-patchset J records and non-inbound
     * cases */
    PROCEDURE get_completed_records(
                                    x_wdth_select_str OUT NOCOPY VARCHAR2,
                                    x_wdth_from_str   OUT NOCOPY VARCHAR2,
                                    x_wdth_where_str  OUT NOCOPY VARCHAR2
                                   );

    PROCEDURE get_wdth_plan_records(
                                    x_wdth_select_str OUT NOCOPY VARCHAR2,
                                    x_wdth_from_str   OUT NOCOPY VARCHAR2,
                                    x_wdth_where_str  OUT NOCOPY VARCHAR2
                                   );

    PROCEDURE get_inbound_specific_query(
                               x_inbound_select_str OUT NOCOPY VARCHAR2,
                               x_inbound_from_str   OUT NOCOPY VARCHAR2,
                               x_inbound_where_str  OUT NOCOPY VARCHAR2,
                               p_is_completed_rec   IN  NUMBER
                                        );

   /* This is used to add-in the outbound query criteria while
      querying crossdock tasks */
   PROCEDURE get_outbound_specific_query(
                       x_outbound_from_str   OUT NOCOPY VARCHAR2
                      ,x_outbound_where_str  OUT NOCOPY VARCHAR2
                      );


    /**
     * Procedure that sets the global variables. This takes in all the
     * fields on the form as input parameters.
     * Each of the input parameter is a record representing each of the
     * tabs on form
     **/
    PROCEDURE set_globals(
    p_organization_id            NUMBER   DEFAULT NULL
  , p_subinventory_code          VARCHAR2 DEFAULT NULL
  , p_locator_id                 NUMBER   DEFAULT NULL
  , p_to_subinventory_code       VARCHAR2 DEFAULT NULL
  , p_to_locator_id              NUMBER   DEFAULT NULL
  , p_inventory_item_id          NUMBER   DEFAULT NULL
  , p_category_set_id            NUMBER   DEFAULT NULL
  , p_item_category_id           NUMBER   DEFAULT NULL
  , p_person_id                  NUMBER   DEFAULT NULL
  , p_person_resource_id         NUMBER   DEFAULT NULL
  , p_equipment_type_id          NUMBER   DEFAULT NULL
  , p_machine_resource_id        NUMBER   DEFAULT NULL
  , p_machine_instance           VARCHAR2 DEFAULT NULL
  , p_user_task_type_id          NUMBER   DEFAULT NULL
  , p_from_task_quantity         NUMBER   DEFAULT NULL
  , p_to_task_quantity           NUMBER   DEFAULT NULL
  , p_from_task_priority         NUMBER   DEFAULT NULL
  , p_to_task_priority           NUMBER   DEFAULT NULL
  , p_from_creation_date         DATE     DEFAULT NULL
  , p_to_creation_date           DATE     DEFAULT NULL
  , p_is_unreleased_task         BOOLEAN  DEFAULT FALSE
  , p_is_pending_task            BOOLEAN  DEFAULT FALSE
  , p_is_queued_task             BOOLEAN  DEFAULT FALSE
  , p_is_dispatched_task         BOOLEAN  DEFAULT FALSE
  , p_is_active_task             BOOLEAN  DEFAULT FALSE
  , p_is_loaded_task             BOOLEAN  DEFAULT FALSE
  , p_is_completed_task          BOOLEAN  DEFAULT FALSE
  , p_include_inbound            BOOLEAN  DEFAULT FALSE
  , p_include_outbound           BOOLEAN  DEFAULT FALSE
  , p_include_crossdock          BOOLEAN  DEFAULT FALSE
  , p_include_manufacturing      BOOLEAN  DEFAULT FALSE
  , p_include_warehousing        BOOLEAN  DEFAULT FALSE
  , p_from_po_header_id          NUMBER   DEFAULT NULL
  , p_to_po_header_id            NUMBER   DEFAULT NULL
  , p_from_purchase_order        VARCHAR2 DEFAULT NULL
  , p_to_purchase_order          VARCHAR2 DEFAULT NULL
  , p_from_rma_header_id         NUMBER   DEFAULT NULL
  , p_to_rma_header_id           NUMBER   DEFAULT NULL
  , p_from_rma                   VARCHAR2 DEFAULT NULL
  , p_to_rma                     VARCHAR2 DEFAULT NULL
  , p_from_requisition_header_id NUMBER   DEFAULT NULL
  , p_to_requisition_header_id   NUMBER   DEFAULT NULL
  , p_from_requisition           VARCHAR2 DEFAULT NULL
  , p_to_requisition             VARCHAR2 DEFAULT NULL
  , p_from_shipment_number       VARCHAR2 DEFAULT NULL
  , p_to_shipment_number         VARCHAR2 DEFAULT NULL
  , p_include_sales_orders       BOOLEAN  DEFAULT TRUE
  , p_include_internal_orders    BOOLEAN  DEFAULT TRUE
  , p_from_sales_order_id        NUMBER   DEFAULT NULL
  , p_to_sales_order_id          NUMBER   DEFAULT NULL
  , p_from_pick_slip_number      NUMBER   DEFAULT NULL
  , p_to_pick_slip_number        NUMBER   DEFAULT NULL
  , p_customer_id                NUMBER   DEFAULT NULL
  , p_customer_category          VARCHAR2 DEFAULT NULL
  , p_delivery_id                NUMBER   DEFAULT NULL
  , p_carrier_id                 NUMBER   DEFAULT NULL
  , p_ship_method                VARCHAR2 DEFAULT NULL
  , p_shipment_priority          VARCHAR2 DEFAULT NULL
  , p_trip_id                    NUMBER   DEFAULT NULL
  , p_from_shipment_date         DATE     DEFAULT NULL
  , p_to_shipment_date           DATE     DEFAULT NULL
  , p_ship_to_state              VARCHAR2 DEFAULT NULL
  , p_ship_to_country            VARCHAR2 DEFAULT NULL
  , p_ship_to_postal_code        VARCHAR2 DEFAULT NULL
  , p_from_number_of_order_lines NUMBER   DEFAULT NULL
  , p_to_number_of_order_lines   NUMBER   DEFAULT NULL
  , p_manufacturing_type         VARCHAR2 DEFAULT NULL
  , p_from_job                   VARCHAR2 DEFAULT NULL
  , p_to_job                     VARCHAR2 DEFAULT NULL
  , p_assembly_id                NUMBER   DEFAULT NULL
  , p_from_start_date            DATE     DEFAULT NULL
  , p_to_start_date              DATE     DEFAULT NULL
  , p_from_line                  VARCHAR2 DEFAULT NULL
  , p_to_line                    VARCHAR2 DEFAULT NULL
  , p_department_id              NUMBER   DEFAULT NULL
  , p_include_replenishment      BOOLEAN  DEFAULT TRUE
  , p_from_replenishment_mo      VARCHAR2 DEFAULT NULL
  , p_to_replenishment_mo        VARCHAR2 DEFAULT NULL
  , p_include_mo_transfer        BOOLEAN  DEFAULT TRUE
  , p_include_mo_issue           BOOLEAN  DEFAULT TRUE
  , p_from_transfer_issue_mo     VARCHAR2 DEFAULT NULL
  , p_to_transfer_issue_mo       VARCHAR2 DEFAULT NULL
  , p_include_lpn_putaway        BOOLEAN  DEFAULT TRUE
  , p_include_staging_move       BOOLEAN  DEFAULT FALSE
  , p_include_cycle_count        BOOLEAN  DEFAULT TRUE
  , p_cycle_count_name           VARCHAR2 DEFAULT NULL
  , p_query_independent_tasks    BOOLEAN  DEFAULT TRUE
  , p_query_planned_tasks        BOOLEAN  DEFAULT TRUE
  , p_is_pending_plan            BOOLEAN  DEFAULT FALSE
  , p_is_inprogress_plan         BOOLEAN  DEFAULT FALSE
  , p_is_completed_plan          BOOLEAN  DEFAULT FALSE
  , p_is_cancelled_plan          BOOLEAN  DEFAULT FALSE
  , p_is_aborted_plan            BOOLEAN  DEFAULT FALSE
  , p_activity_id                NUMBER   DEFAULT NULL
  , p_plan_type_id               NUMBER   DEFAULT NULL
  , p_op_plan_id                 NUMBER   DEFAULT NULL) ;


 PROCEDURE clear_globals;

END wms_plan_tasks_pvt;

/
