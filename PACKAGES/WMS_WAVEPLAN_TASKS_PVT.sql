--------------------------------------------------------
--  DDL for Package WMS_WAVEPLAN_TASKS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_WAVEPLAN_TASKS_PVT" AUTHID CURRENT_USER AS
/* $Header: WMSVTKPS.pls 120.8.12010000.2 2009/03/25 09:11:17 mitgupta ship $ */

TYPE transaction_temp_table_type IS TABLE OF wms_waveplan_tasks_temp.transaction_temp_id%TYPE INDEX BY BINARY_INTEGER;
TYPE task_type_id_table_type     IS TABLE OF wms_waveplan_tasks_temp.task_type_id%TYPE INDEX BY BINARY_INTEGER;
TYPE result_table_type           IS TABLE OF wms_waveplan_tasks_temp.result%TYPE INDEX BY BINARY_INTEGER;
TYPE message_table_type          IS TABLE OF wms_waveplan_tasks_temp.error%TYPE INDEX BY BINARY_INTEGER;
TYPE task_id_table_type          IS TABLE OF wms_waveplan_tasks_temp.task_id%TYPE INDEX BY BINARY_INTEGER;
TYPE time_per_task_table_type    IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE time_uom_table_type         IS TABLE OF bom_resources.unit_of_measure%TYPE INDEX BY BINARY_INTEGER;

TYPE lookup_meaning_table IS TABLE OF mfg_lookups.meaning%TYPE INDEX BY BINARY_INTEGER;
TYPE row_ids_table_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE lookup_meaning_table_type IS TABLE OF mfg_lookups.meaning%TYPE INDEX BY BINARY_INTEGER;


g_task_types                   lookup_meaning_table;
g_task_types_orig              lookup_meaning_table;
g_status_codes                 lookup_meaning_table;
g_status_codes_orig            lookup_meaning_table;
g_plan_task_types              lookup_meaning_table;
g_plan_task_types_orig         lookup_meaning_table;
g_plan_status_codes            lookup_meaning_table;
g_plan_status_codes_orig       lookup_meaning_table;

g_task_type_pick	CONSTANT NUMBER := 1;
g_task_type_putaway	CONSTANT NUMBER := 2;
g_task_type_cycle_count CONSTANT NUMBER := 3;
g_task_type_replenish	CONSTANT NUMBER := 4;
g_task_type_mo_transfer CONSTANT NUMBER := 5;
g_task_type_mo_issue	CONSTANT NUMBER := 6;
g_task_type_staging_move	CONSTANT NUMBER := 7;
g_task_type_inspection		CONSTANT NUMBER := 8;



--Procedures for labor estimations
PROCEDURE mark_rows(p_transaction_temp_id IN  wms_waveplan_tasks_pvt.transaction_temp_table_type,
	       p_task_type_id        IN  wms_waveplan_tasks_pvt.task_type_id_table_type,
	       x_return_status       OUT nocopy varchar2);

PROCEDURE unmark_rows;

PROCEDURE query_tasks
 (p_add                         BOOLEAN  DEFAULT FALSE,
  p_organization_id             NUMBER   DEFAULT NULL,
  p_subinventory_code           VARCHAR2 DEFAULT NULL,
  p_locator_id                  NUMBER   DEFAULT NULL,
  p_to_subinventory_code        VARCHAR2 DEFAULT NULL,
  p_to_locator_id               NUMBER   DEFAULT NULL,
  p_inventory_item_id           NUMBER   DEFAULT NULL,
  p_category_set_id             NUMBER   DEFAULT NULL,
  p_item_category_id            NUMBER   DEFAULT NULL,
  p_person_id                   NUMBER   DEFAULT NULL,
  p_person_resource_id          NUMBER   DEFAULT NULL,
  p_equipment_type_id           NUMBER   DEFAULT NULL,
  p_machine_resource_id         NUMBER   DEFAULT NULL,
  p_machine_instance            VARCHAR2 DEFAULT NULL,
  p_user_task_type_id           NUMBER   DEFAULT NULL,
  p_from_task_quantity          NUMBER   DEFAULT NULL,
  p_to_task_quantity            NUMBER   DEFAULT NULL,
  p_from_task_priority          NUMBER   DEFAULT NULL,
  p_to_task_priority            NUMBER   DEFAULT NULL,
  p_from_creation_date          DATE     DEFAULT NULL,
  p_to_creation_date            DATE     DEFAULT NULL,
  p_is_unreleased               BOOLEAN  DEFAULT FALSE,
  p_is_pending                  BOOLEAN  DEFAULT FALSE,
  p_is_queued                   BOOLEAN  DEFAULT FALSE,
  p_is_dispatched               BOOLEAN  DEFAULT FALSE,
  p_is_active                   BOOLEAN  DEFAULT FALSE,
  p_is_loaded                   BOOLEAN  DEFAULT FALSE,
  p_is_completed                BOOLEAN  DEFAULT FALSE,
  p_include_inbound             BOOLEAN  DEFAULT FALSE,
  p_include_outbound            BOOLEAN  DEFAULT FALSE,
  p_include_crossdock           BOOLEAN  DEFAULT FALSE,
  p_include_manufacturing       BOOLEAN  DEFAULT FALSE,
  p_include_warehousing         BOOLEAN  DEFAULT FALSE,
  p_from_po_header_id           NUMBER   DEFAULT NULL,
  p_to_po_header_id             NUMBER   DEFAULT NULL,
  p_from_purchase_order         VARCHAR2 DEFAULT NULL,
  p_to_purchase_order           VARCHAR2 DEFAULT NULL,
  p_from_rma_header_id          NUMBER   DEFAULT NULL,
  p_to_rma_header_id            NUMBER   DEFAULT NULL,
  p_from_rma                    VARCHAR2 DEFAULT NULL,
  p_to_rma                      VARCHAR2 DEFAULT NULL,
  p_from_requisition_header_id  NUMBER   DEFAULT NULL,
  p_to_requisition_header_id    NUMBER   DEFAULT NULL,
  p_from_requisition            VARCHAR2 DEFAULT NULL,
  p_to_requisition              VARCHAR2 DEFAULT NULL,
  p_from_shipment_number        VARCHAR2 DEFAULT NULL,
  p_to_shipment_number          VARCHAR2 DEFAULT NULL,
  p_include_sales_orders        BOOLEAN  DEFAULT TRUE,
  p_include_internal_orders     BOOLEAN  DEFAULT TRUE,
  p_from_sales_order_id         NUMBER   DEFAULT NULL,
  p_to_sales_order_id           NUMBER   DEFAULT NULL,
  p_from_pick_slip_number       NUMBER   DEFAULT NULL,
  p_to_pick_slip_number         NUMBER   DEFAULT NULL,
  p_customer_id                 NUMBER   DEFAULT NULL,
  p_customer_category           VARCHAR2 DEFAULT NULL,
  p_delivery_id                 NUMBER   DEFAULT NULL,
  p_carrier_id                  NUMBER   DEFAULT NULL,
  p_ship_method                 VARCHAR2 DEFAULT NULL,
  p_shipment_priority           VARCHAR2 DEFAULT NULL,
  p_trip_id                     NUMBER   DEFAULT NULL,
  p_from_shipment_date          DATE     DEFAULT NULL,
  p_to_shipment_date            DATE     DEFAULT NULL,
  p_ship_to_state               VARCHAR2 DEFAULT NULL,
  p_ship_to_country             VARCHAR2 DEFAULT NULL,
  p_ship_to_postal_code         VARCHAR2 DEFAULT NULL,
  p_from_number_of_order_lines  NUMBER   DEFAULT NULL,
  p_to_number_of_order_lines    NUMBER   DEFAULT NULL,
  p_manufacturing_type          VARCHAR2 DEFAULT NULL,
  p_from_job                    VARCHAR2 DEFAULT NULL,
  p_to_job                      VARCHAR2 DEFAULT NULL,
  p_assembly_id                 NUMBER   DEFAULT NULL,
  p_from_start_date             DATE     DEFAULT NULL,
  p_to_start_date               DATE     DEFAULT NULL,
  p_from_line                   VARCHAR2 DEFAULT NULL,
  p_to_line                     VARCHAR2 DEFAULT NULL,
  p_department_id               NUMBER   DEFAULT NULL,
  p_include_replenishment       BOOLEAN  DEFAULT TRUE,
  p_from_replenishment_mo       VARCHAR2 DEFAULT NULL,
  p_to_replenishment_mo         VARCHAR2 DEFAULT NULL,
  p_include_mo_transfer         BOOLEAN  DEFAULT TRUE,
  p_include_mo_issue            BOOLEAN  DEFAULT TRUE,
  p_from_transfer_issue_mo      VARCHAR2 DEFAULT NULL,
  p_to_transfer_issue_mo        VARCHAR2 DEFAULT NULL,
  p_include_lpn_putaway         BOOLEAN  DEFAULT TRUE,
  p_include_staging_move        BOOLEAN  DEFAULT FALSE,
  p_include_cycle_count         BOOLEAN  DEFAULT TRUE,
  p_cycle_count_name            VARCHAR2 DEFAULT NULL,
  x_record_count            OUT NOCOPY NUMBER,
  x_return_status           OUT NOCOPY VARCHAR2,
  x_msg_data                OUT NOCOPY VARCHAR2,
  x_msg_count               OUT NOCOPY NUMBER,
  p_query_independent_tasks  BOOLEAN DEFAULT TRUE,
  p_query_planned_tasks      BOOLEAN DEFAULT TRUE,
  p_is_pending_plan             BOOLEAN DEFAULT FALSE,
  p_is_inprogress_plan             BOOLEAN DEFAULT FALSE,
  p_is_completed_plan             BOOLEAN DEFAULT FALSE,
  p_is_cancelled_plan             BOOLEAN DEFAULT FALSE,
  p_is_aborted_plan             BOOLEAN DEFAULT FALSE,
  p_activity_id                 NUMBER  DEFAULT NULL,
  p_plan_type_id                 NUMBER  DEFAULT NULL,
  p_op_plan_id                 NUMBER  DEFAULT NULL,
   -- R12 : Additional Query Criteria
   p_item_type_code                            VARCHAR2 DEFAULT NULL,
   p_age_uom_code                              VARCHAR2 DEFAULT NULL,
   p_age_min                                   NUMBER DEFAULT NULL,
   p_age_max                                   NUMBER DEFAULT NULL,
   p_order_type_id                             NUMBER DEFAULT NULL,
   p_time_till_shipment_uom_code               VARCHAR2 DEFAULT NULL,
   p_time_till_shipment                        NUMBER DEFAULT NULL,
   p_time_till_appt_uom_code                   VARCHAR2 DEFAULT NULL,
   p_time_till_appt                            NUMBER DEFAULT NULL,
   p_summary_mode				NUMBER DEFAULT 0
   -- R12 : Additional Query Criteria
   , p_wave_header_id                            NUMBER DEFAULT NULL
  );

PROCEDURE update_task (
      p_transaction_temp_id     IN              wms_waveplan_tasks_pvt.transaction_temp_table_type,
      p_task_type_id            IN              wms_waveplan_tasks_pvt.task_type_id_table_type,
      p_employee                IN              VARCHAR2,
      p_employee_id             IN              NUMBER,
      p_user_task_type          IN              VARCHAR2,
      p_user_task_type_id       IN              NUMBER,
      p_effective_start_date    IN              DATE,
      p_effective_end_date      IN              DATE,
      p_person_resource_id      IN              NUMBER,
      p_person_resource_code    IN              VARCHAR2,
      p_force_employee_change   IN              BOOLEAN,
      p_to_status               IN              VARCHAR2,
      p_to_status_id            IN              NUMBER,
      p_update_priority_type    IN              VARCHAR2,
      p_update_priority         IN              NUMBER,
      p_clear_priority          IN              VARCHAR2,
      x_result                  OUT NOCOPY      wms_waveplan_tasks_pvt.result_table_type,
      x_message                 OUT NOCOPY      wms_waveplan_tasks_pvt.message_table_type,
      x_task_id                 OUT NOCOPY      wms_waveplan_tasks_pvt.task_id_table_type,
      x_return_status           OUT NOCOPY      VARCHAR2,
      x_return_msg              OUT NOCOPY      VARCHAR2,
      x_msg_count               OUT NOCOPY      NUMBER);

PROCEDURE remove_tasks (p_transaction_temp_id   IN  wms_waveplan_tasks_pvt.transaction_temp_table_type,
			x_record_count          OUT NOCOPY NUMBER,
			x_return_status         OUT nocopy VARCHAR2,
			x_msg_data              OUT nocopy varchar2);

PROCEDURE save_tasks(
		     p_task_action               VARCHAR2,
		     p_commit                    BOOLEAN,
		     p_user_id                   NUMBER,
		     p_login_id                  NUMBER,
		     x_save_count     OUT nocopy NUMBER,
		     x_return_status  OUT nocopy VARCHAR2,
		     x_msg_data       OUT nocopy VARCHAR2,
		     x_msg_count      OUT nocopy NUMBER);

-- Record Type for the task status distribution data for the performance chart
TYPE cb_chart_status_rec_type is RECORD
  (status		VARCHAR2(400) 	:= NULL,
   task_count           NUMBER          := NULL );

-- Record Type for the Task Summary information
TYPE wms_task_summary_rec_type IS RECORD
  ( wms_task_type	NUMBER,
    task_count		NUMBER   := 0);

-- Table Type for the task summary information
TYPE wms_task_summary_tbl_type IS TABLE OF wms_task_summary_rec_type
	INDEX BY BINARY_INTEGER;

g_wms_task_summary_tbl	wms_task_summary_tbl_type;

-- Table type definition for an array of cb_chart_status_rec_type records.
TYPE cb_chart_status_tbl_type is TABLE OF cb_chart_status_rec_type
  INDEX BY BINARY_INTEGER;


-- Procedure definition to get task status distribution
PROCEDURE get_status_dist(x_status_chart_data	OUT nocopy cb_chart_status_tbl_type,
			  x_status_data_count	OUT nocopy NUMBER,
			  x_return_status	OUT nocopy VARCHAR2,
			  x_msg_count	       	OUT nocopy NUMBER,
			  x_msg_data            OUT nocopy VARCHAR2,
			  p_task_type_id        IN         NUMBER DEFAULT NULL);


-- Record Type for the task type distribution data for the performance chart
TYPE cb_chart_type_rec_type is RECORD
  (type		VARCHAR2(100) 	:= NULL,
   task_count	NUMBER  	:= NULL);

-- Table type definition for an array of cb_chart_type_rec_type records.
TYPE cb_chart_type_tbl_type is TABLE OF cb_chart_type_rec_type
  INDEX BY BINARY_INTEGER;

-- Procedure definition to get task type distribution
PROCEDURE get_type_dist(x_type_chart_data    OUT nocopy	 cb_chart_type_tbl_type,
			x_type_data_count    OUT nocopy  NUMBER,
			x_return_status	     OUT nocopy	 VARCHAR2,
			x_msg_count	     OUT nocopy	 NUMBER,
			x_msg_data     	     OUT nocopy	 VARCHAR2,
			p_task_type_id       IN          NUMBER DEFAULT NULL);

PROCEDURE calculate_summary(p_calculate_time    IN  BOOLEAN  DEFAULT FALSE,
			    p_time_per_task     IN  wms_waveplan_tasks_pvt.time_per_task_table_type,
			    p_time_per_task_uom IN  wms_waveplan_tasks_pvt.time_uom_table_type,
			    p_time_uom_code     IN  VARCHAR2 DEFAULT NULL,
			    p_time_uom          IN  VARCHAR2 DEFAULT NULL,
			    p_calculate_volume  IN  BOOLEAN  DEFAULT FALSE,
			    p_volume_uom_code   IN  VARCHAR2 DEFAULT NULL,
			    p_volume_uom        IN  VARCHAR2 DEFAULT NULL,
			    p_calculate_weight  IN  BOOLEAN  DEFAULT FALSE,
			    p_weight_uom_code   IN  VARCHAR2 DEFAULT NULL,
			    p_weight_uom        IN  VARCHAR2 DEFAULT NULL,
			    x_total_tasks       OUT nocopy NUMBER,
			    x_total_time        OUT nocopy NUMBER,
			    x_total_weight      OUT nocopy NUMBER,
			    x_total_volume      OUT nocopy NUMBER,
			    x_return_status     OUT nocopy VARCHAR2,
			    x_msg_data          OUT nocopy VARCHAR2,
			    x_msg_count         OUT nocopy NUMBER);

FUNCTION get_generic_select
 (p_is_unreleased               BOOLEAN DEFAULT FALSE,
  p_is_pending                  BOOLEAN DEFAULT FALSE,
  p_is_queued                   BOOLEAN DEFAULT FALSE,
  p_is_dispatched               BOOLEAN DEFAULT FALSE,
  p_is_active                   BOOLEAN DEFAULT FALSE,
  p_is_loaded                   BOOLEAN DEFAULT FALSE,
  p_is_completed                BOOLEAN DEFAULT FALSE,
  p_populate_merged_tasks       BOOLEAN DEFAULT FALSE)
  RETURN VARCHAR2;

FUNCTION get_generic_from
 (p_is_queued                   BOOLEAN DEFAULT FALSE,
  p_is_dispatched               BOOLEAN DEFAULT FALSE,
  p_is_active                   BOOLEAN DEFAULT FALSE,
  p_is_loaded                   BOOLEAN DEFAULT FALSE,
  p_is_completed                BOOLEAN DEFAULT FALSE,
  p_item_category_id            NUMBER  DEFAULT NULL,
  p_category_set_id             NUMBER  DEFAULT NULL,
  p_populate_merged_tasks       BOOLEAN DEFAULT FALSE)
  RETURN VARCHAR2;

FUNCTION get_generic_where
 (p_add                         BOOLEAN  DEFAULT FALSE,
  p_organization_id             NUMBER   DEFAULT NULL,
  p_subinventory_code           VARCHAR2 DEFAULT NULL,
  p_locator_id                  NUMBER   DEFAULT NULL,
  p_to_subinventory_code        VARCHAR2 DEFAULT NULL,
  p_to_locator_id               NUMBER   DEFAULT NULL,
  p_inventory_item_id           NUMBER   DEFAULT NULL,
  p_category_set_id             NUMBER   DEFAULT NULL,
  p_item_category_id            NUMBER   DEFAULT NULL,
  p_person_id                   NUMBER   DEFAULT NULL,
  p_person_resource_id          NUMBER   DEFAULT NULL,
  p_equipment_type_id           NUMBER   DEFAULT NULL,
  p_machine_resource_id         NUMBER   DEFAULT NULL,
  p_machine_instance            VARCHAR2 DEFAULT NULL,
  p_user_task_type_id           NUMBER   DEFAULT NULL,
  p_from_task_quantity          NUMBER   DEFAULT NULL,
  p_to_task_quantity            NUMBER   DEFAULT NULL,
  p_from_task_priority          NUMBER   DEFAULT NULL,
  p_to_task_priority            NUMBER   DEFAULT NULL,
  p_from_creation_date          DATE     DEFAULT NULL,
  p_to_creation_date            DATE     DEFAULT NULL,
  p_include_cycle_count         BOOLEAN  DEFAULT FALSE,
  p_is_unreleased               BOOLEAN  DEFAULT FALSE,
  p_is_pending                  BOOLEAN  DEFAULT FALSE,
  p_is_queued                   BOOLEAN  DEFAULT FALSE,
  p_is_dispatched               BOOLEAN  DEFAULT FALSE,
  p_is_active                   BOOLEAN  DEFAULT FALSE,
  p_is_loaded                   BOOLEAN  DEFAULT FALSE,
  p_is_completed                BOOLEAN  DEFAULT FALSE,
  p_populate_merged_tasks       BOOLEAN  DEFAULT FALSE,
  p_outbound_tasks_cycle        BOOLEAN  DEFAULT FALSE,      -- bug #4661615
   -- R12 : Additional Query Criteria
   p_item_type_code                            VARCHAR2 DEFAULT NULL,
   p_age_uom_code                              VARCHAR2 DEFAULT NULL,
   p_age_min                                   NUMBER DEFAULT NULL,
   p_age_max                                   NUMBER DEFAULT NULL
   -- R12 : Additional Query Criteria
  )
  RETURN VARCHAR2;

PROCEDURE cancel_plans(x_return_status    OUT nocopy VARCHAR2,
                       x_ret_code          OUT nocopy wms_waveplan_tasks_pvt.message_table_type,
             p_transaction_temp_table wms_waveplan_tasks_pvt.transaction_temp_table_type);

   PROCEDURE cancel_task (
      p_transaction_temp_id     IN              wms_waveplan_tasks_pvt.transaction_temp_table_type,
      p_task_type_id            IN              wms_waveplan_tasks_pvt.task_type_id_table_type,
      p_is_crossdock            IN              BOOLEAN DEFAULT FALSE, /* Bug 5623122 */
      x_result                  OUT NOCOPY      wms_waveplan_tasks_pvt.result_table_type,
      x_message                 OUT NOCOPY      wms_waveplan_tasks_pvt.message_table_type,
      x_task_id                 OUT NOCOPY      wms_waveplan_tasks_pvt.task_id_table_type,
      x_return_status           OUT NOCOPY      VARCHAR2,
      x_return_msg              OUT NOCOPY      VARCHAR2,
      x_msg_count               OUT NOCOPY      NUMBER
   );



FUNCTION get_final_query RETURN VARCHAR2;

PROCEDURE set_status_codes;

PROCEDURE set_task_type;

--Change
PROCEDURE set_plan_task_types;

  PROCEDURE set_plan_status_codes;
PROCEDURE find_visible_columns;

FUNCTION get_task_summary RETURN wms_task_summary_tbl_type;

PROCEDURE set_task_summary(p_wms_task_summary_tbl wms_task_summary_tbl_type);

END wms_waveplan_tasks_pvt;

/
