--------------------------------------------------------
--  DDL for Package FLM_SEQ_READER_WRITER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FLM_SEQ_READER_WRITER" AUTHID CURRENT_USER AS
/* $Header: FLMSQRWS.pls 120.1.12010000.2 2008/08/08 07:38:31 bgaddam ship $ */


--globals
g_user_id NUMBER;
g_login_id NUMBER;
g_job_prefix VARCHAR2(20) := null;

g_demand_type_SO NUMBER := 2;
g_demand_type_PO NUMBER := 100;

--global descriptive flex columns
g_attribute1 	VARCHAR2(150) := null;
g_attribute2 	VARCHAR2(150) := null;
g_attribute3 	VARCHAR2(150) := null;
g_attribute4 	VARCHAR2(150) := null;
g_attribute5 	VARCHAR2(150) := null;
g_attribute6 	VARCHAR2(150) := null;
g_attribute7 	VARCHAR2(150) := null;
g_attribute8 	VARCHAR2(150) := null;
g_attribute9 	VARCHAR2(150) := null;
g_attribute10 	VARCHAR2(150) := null;
g_attribute11 	VARCHAR2(150) := null;
g_attribute12 	VARCHAR2(150) := null;
g_attribute13 	VARCHAR2(150) := null;
g_attribute14 	VARCHAR2(150) := null;
g_attribute15 	VARCHAR2(150) := null;

g_days_index INTEGER;
g_components_index NUMBER;


TYPE number_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

TYPE schedule_rec_type IS RECORD
  (
   primary_item_id 		NUMBER,
   org_id 			NUMBER,
   wip_entity_id 		NUMBER,
   planned_quantity 		NUMBER,
   alt_rtg_designator 	        VARCHAR2(10),
   sch_start_date 		DATE,
   sch_completion_date 	        DATE,
   sch_group_id 		NUMBER,
   build_sequence 		NUMBER,
   line_id 			NUMBER,
   schedule_number              VARCHAR2(30),
   demand_type		        NUMBER,
   demand_id			NUMBER
   );
TYPE schedule_rec_tbl_type IS TABLE OF schedule_rec_type
  INDEX BY BINARY_INTEGER;


TYPE wip_flow_schedule_tbl IS TABLE OF wip_flow_schedules%rowtype
  INDEX BY BINARY_INTEGER;


TYPE cto_line_record_type IS RECORD
  (
   demand_source_line VARCHAR2(30),
   primary_item_id NUMBER,
   organization_id NUMBER
  );
TYPE cto_line_tbl_type IS TABLE OF cto_line_record_type INDEX BY BINARY_INTEGER;

TYPE comp_avail_record_type IS RECORD
  (
   inventory_item_id NUMBER,
   requirement_date NUMBER,
   qty NUMBER
   );
TYPE comp_avail_tbl_type IS TABLE OF comp_avail_record_type INDEX BY BINARY_INTEGER;

g_days number_tbl_type;
sch_rec_tbl schedule_rec_tbl_type;
g_cto_line_tbl cto_line_tbl_type;
g_components flm_supply_demand.number_tbl_type;
g_qtys flm_supply_demand.number_tbl_type;




/******************************************************************
 * To get a list of working days for a period (start, end)        *
 * The day will be in Julian format                               *
 ******************************************************************/
PROCEDURE Init_Working_Days(p_organization_id IN NUMBER,
                           p_start_date IN NUMBER,
                           p_end_date IN NUMBER,
                           x_err_code OUT NOCOPY NUMBER,
                           x_err_msg OUT NOCOPY VARCHAR
                           );


/******************************************************************
 * To get a list of working days for a period (start, end)        *
 * The day will be in Julian format                               *
 ******************************************************************/
PROCEDURE Get_Working_Days(p_batch_size IN NUMBER,
                           x_days OUT NOCOPY number_tbl_type,
                           x_found IN OUT NOCOPY NUMBER,
                           x_done_flag OUT NOCOPY INTEGER,
                           x_err_code OUT NOCOPY NUMBER,
                           x_err_msg OUT NOCOPY VARCHAR
                           );


/******************************************************************
 * To get available build sequence range for a period (start,end) *
 * The range (start_seq, end_seq) is an open interval (exclusive) *
 ******************************************************************/
PROCEDURE Get_BuildSeq_Range(p_line_id IN NUMBER,
                           p_organization_id IN NUMBER,
                           p_start_date IN NUMBER,
                           p_end_date IN NUMBER,
                           x_start_seq OUT NOCOPY NUMBER,
                           x_end_seq OUT NOCOPY NUMBER,
                           x_err_code OUT NOCOPY NUMBER,
                           x_err_msg OUT NOCOPY VARCHAR
                           );

/******************************************************************
 * To initialize globals used by db writer                        *
 ******************************************************************/
FUNCTION initialize_globals RETURN NUMBER;


/******************************************************************
 * To add a schedule in schedules table and return wip_id and     *
 * schedule number                                                *
 ******************************************************************/
PROCEDURE add_sch_rec(i_org_id NUMBER,
                      i_primary_item_id NUMBER,
                      i_line_id NUMBER,
                      i_sch_start_date DATE,
                      i_sch_completion_date DATE,
                      i_planned_quantity NUMBER,
                      i_alt_rtg_designator VARCHAR2,
                      i_build_sequence NUMBER,
                      i_schedule_group_id NUMBER,
                      i_demand_type NUMBER,
                      i_demand_id NUMBER,
                      x_wip_entity_id IN OUT NOCOPY NUMBER,
                      x_schedule_number IN OUT NOCOPY VARCHAR2,
                      o_return_code OUT NOCOPY NUMBER
                      );


/******************************************************************
 * To default the schedule columns and inserting the schedules    *
 ******************************************************************/
PROCEDURE create_schedules (o_return_code   OUT NOCOPY     NUMBER);


/******************************************************************
 * To default/derive the attribute which are not passed for this  *
 * schedule and copy the attributes which are passed              *
 ******************************************************************/
PROCEDURE default_attributes(sch_rec_tbl IN OUT NOCOPY schedule_rec_tbl_type,
                             l_sch_tbl_to_insert IN OUT NOCOPY wip_flow_schedule_tbl,
                             o_return_code OUT NOCOPY NUMBER);


/******************************************************************
 * Used to insert all the schedule in the table                   *
 ******************************************************************/
PROCEDURE insert_schedules (i_schedules_tbl IN wip_flow_schedule_tbl,
                            o_return_code OUT NOCOPY NUMBER);


/******************************************************************
 * gets the wip_entity_id and schedule_number from sequence       *
 ******************************************************************/
PROCEDURE get_wip_id_and_sch_num (o_wip_entity_id OUT NOCOPY NUMBER,
                                  o_schedule_number OUT NOCOPY VARCHAR2);


/******************************************************************
 * To get class code based on item and organization               *
 ******************************************************************/
FUNCTION get_class_code(i_org_id NUMBER, i_item_id NUMBER )RETURN VARCHAR;


/******************************************************************
 * To get all account id based on class code                      *
 ******************************************************************/
PROCEDURE get_account_ids (i_org_id NUMBER, i_class_code VARCHAR2,
                           i_material_act IN OUT NOCOPY NUMBER,
                           i_material_overhead_act IN OUT NOCOPY NUMBER,
                           i_resource_act IN OUT NOCOPY NUMBER,
                           i_outside_processing_act IN OUT NOCOPY NUMBER,
                           i_material_variance_act IN OUT NOCOPY NUMBER,
                           i_resource_variance_act IN OUT NOCOPY NUMBER,
                           i_outside_proc_variance_act IN OUT NOCOPY NUMBER,
                           i_std_cost_adjustment_act IN OUT NOCOPY NUMBER,
                           i_overhead_act IN OUT NOCOPY NUMBER,
                           i_overhead_variance_act IN OUT NOCOPY NUMBER);


/******************************************************************
 * To get bom revision and bom revision date                      *
 ******************************************************************/
PROCEDURE get_bom_rev_and_date (i_org_id NUMBER,
                                i_primary_item_id NUMBER,
                                i_sch_completion_date DATE,
                                o_bom_revision OUT NOCOPY VARCHAR,
                                o_bom_revision_date OUT NOCOPY DATE);


/******************************************************************
 * To get routing revision and routing revision date              *
 ******************************************************************/
PROCEDURE get_rtg_rev_and_date (i_org_id NUMBER,
                                i_primary_item_id NUMBER,
                                i_sch_completion_date DATE,
                                o_rtg_revision OUT NOCOPY VARCHAR,
                                o_rtg_revision_date OUT NOCOPY DATE);


/******************************************************************
 * To get alternate bom designator                                *
 ******************************************************************/
PROCEDURE get_alt_bom_designator(i_org_id NUMBER,
                                 i_primary_item_id NUMBER,
                                 i_alt_rtg_designator VARCHAR2,
                                 o_alt_bom_designator OUT NOCOPY VARCHAR2);


/******************************************************************
 * To get the completion subinventory and locator                 *
 ******************************************************************/
PROCEDURE get_completion_subinv_and_loc (i_org_id NUMBER,
                                         i_primary_item_id NUMBER,
                                         i_alt_rtg_designator VARCHAR2,
                                         o_completion_subinv OUT NOCOPY VARCHAR2,
                                         o_completion_locator_id OUT NOCOPY NUMBER);


/******************************************************************
 * gets the demand class based on demand type                     *
 ******************************************************************/
PROCEDURE get_demand_class(i_demand_type NUMBER,
                           i_demand_id NUMBER,
                           o_demand_class IN OUT NOCOPY VARCHAR2,
                           o_demand_header IN OUT NOCOPY NUMBER );

/******************************************************************
 * gets the project and task   added for Bug 6358519              *
 ******************************************************************/
PROCEDURE get_project_task(i_demand_type NUMBER,
                           i_demand_id NUMBER,
                           o_project_id IN OUT NOCOPY NUMBER,
                           o_task_id IN OUT NOCOPY NUMBER );


/******************************************************************
 * This procedure loops through schedules table, find out         *
 * unique item and alternate bom combinations, and call           *
 * explode for each unique combination                            *
 ******************************************************************/
PROCEDURE explode_all_items(i_schedules_tbl IN OUT NOCOPY
                            wip_flow_schedule_tbl,
                            o_return_code OUT NOCOPY NUMBER);


/******************************************************************
 * To explode the item bom                                        *
 ******************************************************************/
PROCEDURE explode_items (i_item_id    IN NUMBER,
                         i_org_id     IN NUMBER,
                         i_alt_bom    IN VARCHAR2,
                         x_error_msg  IN OUT NOCOPY VARCHAR2,
                         x_error_code IN OUT NOCOPY NUMBER);


/******************************************************************
 * To update the mrp_recommendations based on schedules inserted  *
 ******************************************************************/
PROCEDURE update_mrp_recommendations(i_schedules_tbl IN
                                     wip_flow_schedule_tbl,
                                     o_return_code IN OUT NOCOPY NUMBER);

/******************************************************************
 * To call the CTO API for each so line                           *
 ******************************************************************/
PROCEDURE call_cto_api(o_return_code IN OUT NOCOPY NUMBER);


/******************************************************************
 * call read_comp_avail to intialize global index and pl/sql table*
 ******************************************************************/
PROCEDURE Init_Component_Avail(p_seq_task_id IN NUMBER,
                           p_organization_id IN NUMBER,
                           p_from_date IN DATE,
                           p_to_date IN DATE,
                           x_err_code OUT NOCOPY NUMBER,
                           x_err_msg OUT NOCOPY VARCHAR
                           );


/******************************************************************
 * To get component availability of a sequencing task by batch    *
 ******************************************************************/
PROCEDURE Get_Component_Avail(
                           p_batch_size IN NUMBER,
                           x_ids OUT NOCOPY number_tbl_type,
                           x_qtys OUT NOCOPY number_tbl_type,
                           x_found IN OUT NOCOPY NUMBER,
                           x_done_flag OUT NOCOPY INTEGER,
                           x_err_code OUT NOCOPY NUMBER,
                           x_err_msg OUT NOCOPY VARCHAR
                           );

END flm_seq_reader_writer;

/
