--------------------------------------------------------
--  DDL for Package Body GMP_APS_DS_PULL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMP_APS_DS_PULL" AS
/* $Header: GMPPLDSB.pls 120.28.12010000.15 2010/01/29 09:08:21 vpedarla ship $ */

  /* Define Exceptions */
  invalid_string_value         EXCEPTION;
  invalid_gmp_uom_profile      EXCEPTION;

  l_debug                      VARCHAR2(1) := NVL(FND_PROFILE.VALUE('GMP_DEBUG_ENABLED'),'N'); -- BUG: 8420747

/* Record definition for the a line in a production order. */
  TYPE product_typ IS RECORD(
    batch_no                   VARCHAR2(32),
    plant_code                 VARCHAR2(4),
    batch_id                   PLS_INTEGER,
    x_batch_id                 PLS_INTEGER,  /* B1177070 added encoded key */
/* nsinghi INVCONV Start */
/* WIP Whse no longer used. */
/*    wip_whse_code    VARCHAR2(4), */
/* nsinghi INVCONV End */
    mtl_org_id                 PLS_INTEGER,
    routing_id                 PLS_INTEGER,
    start_date                 DATE,
    end_date                   DATE,
    actual_start_date          DATE,  -- Bug: 8624913
    trans_date                 DATE,
    batch_status               PLS_INTEGER,
    batch_type                 PLS_INTEGER,
/* nsinghi INVCONV Start */
/*  organization_id  PLS_INTEGER,
    whse_code        VARCHAR2(4),
    item_id         PLS_INTEGER,   */ /* Give a Unique Item Id Name */
/* nsinghi INVCONV End */
    line_id                    PLS_INTEGER,
    line_no                    PLS_INTEGER,   /* B2919303 */
    tline_no                   PLS_INTEGER,   /* B2953953 - CoProducts */
    line_type                  PLS_INTEGER,
    tline_type                 PLS_INTEGER,   /* B2953953 - CoProducts */
    qty                        NUMBER,
    uom_conv_factor            NUMBER,
    matl_item_id               PLS_INTEGER,      /* B1992371 for GME Changes */
    recipe_item_id             PLS_INTEGER,      /* B1992371 for GME Changes */
    poc_ind                    VARCHAR2(1), /* B1992371, B2239948 for GME Changes */
    firmed_ind                 PLS_INTEGER,      /* B2821248 - Firmed Ind is added */
    batchstep_no               PLS_INTEGER,      /* B2919303 StepNo */
--    matl_qty         NUMBER,
    requested_completion_date  DATE,
    schedule_priority	       PLS_INTEGER,
    from_op_seq_id 	       PLS_INTEGER,
    Minimum_Transfer_Qty       NUMBER,
    Minimum_Time_Offset	       NUMBER,
    Maximum_Time_Offset	       NUMBER,
    from_op_seq_num	       PLS_INTEGER
   );

  TYPE product_tbl IS TABLE OF product_typ INDEX by BINARY_INTEGER;
  prod_tab   product_tbl;

/* definition for the resource data of a production order */
  TYPE rsrc_rec IS RECORD(
    batch_id                 PLS_INTEGER,
    x_batch_id               PLS_INTEGER,  /* B1177070 added encoded key */
    batchstep_no             PLS_INTEGER,  /* B1224660 added batchstep to record */
    seq_dep_ind              PLS_INTEGER,
    prim_rsrc_ind_order      PLS_INTEGER,
    resources                VARCHAR2(16),
    instance_number          PLS_INTEGER,
    tran_seq_dep             PLS_INTEGER,
    plan_start_date          DATE,
/*    plant_code         VARCHAR2(4), nsinghi INVCONV  */
    organization_id          PLS_INTEGER, /* nsinghi INVCONV End */
    prim_rsrc_ind            PLS_INTEGER,
    resource_id              PLS_INTEGER,
    x_resource_id            PLS_INTEGER,  /* B1177070 added encoded key */
    activity                 VARCHAR2(16),	/* NAVIN: Remove this column. */
    operation_no             VARCHAR2(16),	/* NAVIN: Remove this column. */
    plan_rsrc_count          PLS_INTEGER,
    actual_rsrc_count        PLS_INTEGER,
    actual_start_date        DATE,
    plan_cmplt_date          DATE,
    actual_cmplt_date        DATE,
    step_status              PLS_INTEGER,
    resource_usage           NUMBER,
    resource_instance_usage  NUMBER,
    eqp_serial_number        VARCHAR2(30),   /* Bug 5639879 */
    scale_type               PLS_INTEGER,
    capacity_constraint      PLS_INTEGER ,
    plan_step_qty            NUMBER,
    min_xfer_qty             NUMBER,
    material_ind             PLS_INTEGER,
    schedule_flag            PLS_INTEGER,
--    offset_interval    NUMBER,
    act_start_date           DATE,
    utl_eff                  NUMBER,
    bs_activity_id           PLS_INTEGER,
--NAVIN: START new field (added for 11.1.1.3 of Process Execution APS Patchset J.1 TDD)
    group_sequence_id	     PLS_INTEGER,
    group_sequence_number    PLS_INTEGER,
    firm_type	             PLS_INTEGER,
    setup_id	             PLS_INTEGER,
    minimum_capacity         NUMBER,
    maximum_capacity         NUMBER,
    sequence_dependent_usage NUMBER,
    original_seq_num         NUMBER,
    org_step_status	     PLS_INTEGER,
    plan_charges	     PLS_INTEGER,
    plan_rsrc_usage	     NUMBER,
    actual_rsrc_usage	     NUMBER,
    batchstep_id             PLS_INTEGER,   /* Navin 6/23/2004 Added for resource charges*/
    mat_found                PLS_INTEGER,
    breakable_activity_flag  PLS_INTEGER,
    usage_uom                VARCHAR2(4), /*Sowmya - FDD changes - Alternate resources */
    step_qty_uom             VARCHAR2(3), /* Sowmya - FDD changes- Step Quantity UOM */
    equp_item_id             PLS_INTEGER ,  /* Sowmya- FDD changes - Resources Instances */
    gmd_rsrc_count           PLS_INTEGER,   /* Sowmya- FDD changes - Resources req and Alt */
    step_start_date          DATE, /* nsinghi- job_operations.reco_start_date */
    step_end_date            DATE, /* nsinghi- job_operations.reco_completion_date */
    efficiency               NUMBER /*B4320561 - sowsubra */
    );

  TYPE rsrc_dtl_tbl IS TABLE OF rsrc_rec INDEX by BINARY_INTEGER;
  rsrc_tab   rsrc_dtl_tbl;

/* Record and table definition for the MPS schedule details and the items and
   orgs that are associated by plant/whse eff. The schedule are used for MDS
   demand
*/
  TYPE sched_dtl_rec IS RECORD(
    schedule        	VARCHAR2(16),
    schedule_id     	PLS_INTEGER,
    order_ind       	PLS_INTEGER,
    stock_ind       	PLS_INTEGER,
    whse_code       	VARCHAR2(4),
    orgn_code       	VARCHAR2(4),
    organization_id 	PLS_INTEGER,
    inventory_item_id	PLS_INTEGER);

  TYPE sched_dtl_tbl IS TABLE OF sched_dtl_rec INDEX by BINARY_INTEGER;
  sched_dtl_tab     sched_dtl_tbl;

  /* Record and table definition for forecast detals */
  TYPE fcst_dtl_rec IS RECORD(
    inventory_item_id   PLS_INTEGER,
    organization_id     PLS_INTEGER,
    forecast_id         PLS_INTEGER,
    forecast            VARCHAR2(17),
    orgn_code           VARCHAR2(4),
    trans_date          DATE,
    trans_qty           NUMBER,
    consumed_qty        NUMBER,
    use_fcst_flag	NUMBER);

  TYPE fcst_dtl_tbl IS TABLE OF fcst_dtl_rec INDEX by BINARY_INTEGER;
  fcst_dtl_tab      fcst_dtl_tbl;

  /* Record and table definition for sales order detals */
  TYPE sales_dtl_rec IS RECORD(
    inventory_item_id   PLS_INTEGER,
    organization_id 	PLS_INTEGER,
    orgn_code           VARCHAR2(4),
    order_no            VARCHAR2(32),
    line_id             PLS_INTEGER,
    net_price           NUMBER,
    sched_shipdate      DATE,
    request_date        DATE,       /* B2971996 */
    trans_qty           NUMBER);

  TYPE sales_dtl_tbl IS TABLE OF sales_dtl_rec INDEX by BINARY_INTEGER;
  sales_dtl_tab     sales_dtl_tbl;

  /* Record and table definition for schedule forecast association */
  TYPE fcst_assoc_rec IS RECORD(
    schedule_id         PLS_INTEGER,
    forecast_id         PLS_INTEGER);

  TYPE fcst_assoc_tbl IS TABLE OF fcst_assoc_rec INDEX by BINARY_INTEGER;
  SCHD_FCST_DTL_TAB     fcst_assoc_tbl;

  /* Record and table definition for designators */
  TYPE desig_rec IS RECORD(
    designator      VARCHAR2(15),
    schedule        VARCHAR2(17),
    orgn_code       VARCHAR2(4),
    whse_code       VARCHAR2(4),
    organization_id PLS_INTEGER);

  TYPE desig_tbl IS TABLE OF desig_rec INDEX by BINARY_INTEGER;
  desig_tab         desig_tbl;

  TYPE stp_chg_typ is RECORD(
  wip_entity_id	     PLS_INTEGER,
  operation_seq_id   PLS_INTEGER,
  resource_id	     PLS_INTEGER,
  charge_num	     PLS_INTEGER,
  organization_id    PLS_INTEGER,
  operation_seq_no   PLS_INTEGER,
  resource_seq_num   PLS_INTEGER,
  charge_quantity    NUMBER	,
  charge_start_dt_time	DATE    ,
  charge_end_dt_time DATE
  );

  TYPE stp_chg_tab IS TABLE OF stp_chg_typ INDEX by BINARY_INTEGER;
  stp_chg_tbl stp_chg_tab;

/* NAVIN :- Alternate Resource */
/* NAVIN: Alternate Resource selection   */
TYPE gmp_alt_resource_typ IS RECORD
(
    prim_resource_id    PLS_INTEGER,
    alt_resource_id     PLS_INTEGER,
    runtime_factor      NUMBER,  /* B2353759,alternate runtime_factor */
    preference          PLS_INTEGER, /* B5688153 Prod spec alternates */
    inventory_item_id   PLS_INTEGER  /* B5688153 Prod spec alternates */
);
TYPE gmp_alt_resource_tbl IS TABLE OF gmp_alt_resource_typ INDEX by BINARY_INTEGER;
rtg_alt_rsrc_tab       gmp_alt_resource_tbl;

  /* Global Variable definitions  */
  null_value            VARCHAR2(2) := NULL;
  desig_count		PLS_INTEGER  := 0;
  gfcst_cnt		PLS_INTEGER  := 0;
  gso_cnt		PLS_INTEGER  := 0;
  gschd_fcst_cnt	PLS_INTEGER  := 0;
  g_instance_id		PLS_INTEGER  := 0 ;
  gitem_size		PLS_INTEGER  := 0;
  gfcst_size		PLS_INTEGER  := 0;
  gso_size		PLS_INTEGER  := 0;
  gschd_fcst_size	PLS_INTEGER  := 0;
  g_item_tbl_position	PLS_INTEGER  := 0;
  gcurrent_designator	VARCHAR2(10) := NULL;
  g_delimiter		VARCHAR2(4) ;
  gprod_size            PLS_INTEGER  := 0;
  grsrc_size            PLS_INTEGER  := 0;
  g_rsrc_cnt            INTEGER ;
  stp_chg_num           PLS_INTEGER  ;
  stp_chg_cursor        VARCHAR2(20000);
  statement_alt_resource  VARCHAR2(32000) := NULL; /* NAVIN :- added for alternate resource */
  alt_rsrc_size         PLS_INTEGER;  /* NAVIN :- : Number of rows in Alternate Resource */

  /* Sowmya - As per the latest FDD changes */
  shld_res_passed       BOOLEAN;
  converted_usage       NUMBER;
  l_res_inst_process    NUMBER;

/* ------------------- Requirement declaration ---------------------*/

TYPE number_idx_tbl IS TABLE OF number INDEX BY BINARY_INTEGER;
empty_num_tbl 	number_idx_tbl;
rr_organization_id  	number_idx_tbl;
s_organization_id  	number_idx_tbl;
d_organization_id  	number_idx_tbl;
f_organization_id  	number_idx_tbl;
i_organization_id  	number_idx_tbl;
arr_organization_id  	number_idx_tbl; /* alternate resource declaration */
rr_activity_group_id 	number_idx_tbl; /* B3995361 rpatangy */

rr_sr_instance_id  	number_idx_tbl;
s_sr_instance_id  	number_idx_tbl;
d_sr_instance_id  	number_idx_tbl;
f_sr_instance_id  	number_idx_tbl;
i_sr_instance_id  	number_idx_tbl;
stp_instance_id  	number_idx_tbl;
arr_sr_instance_id  	number_idx_tbl; /* alternate resource declaration */

rr_supply_id  		number_idx_tbl;

rr_resource_seq_num  	number_idx_tbl;

rr_resource_id  	number_idx_tbl;

TYPE date_idx_tbl IS TABLE OF date INDEX BY BINARY_INTEGER;
empty_date_tbl  	date_idx_tbl;
rr_start_date 		date_idx_tbl;
rr_end_date 		date_idx_tbl;

rr_opr_hours_required 	number_idx_tbl;
rr_usage_rate 		number_idx_tbl;
rr_assigned_units 	number_idx_tbl;

rr_department_id 	number_idx_tbl;
rr_wip_entity_id 	number_idx_tbl;
d_wip_entity_id 	number_idx_tbl;
f_wip_entity_id 	number_idx_tbl;

rr_operation_seq_num 	number_idx_tbl;
s_operation_seq_num 	number_idx_tbl;
d_operation_seq_num 	number_idx_tbl;

rr_firm_flag 		number_idx_tbl;
rr_minimum_transfer_quantity number_idx_tbl;
rr_parent_seq_num 	number_idx_tbl;
rr_schedule_flag 	number_idx_tbl;
rr_hours_expended 	number_idx_tbl;
rr_breakable_activity_flag number_idx_tbl ;
rr_unadjusted_resource_hrs number_idx_tbl ; /* B4320561 - sowsubra */
rr_touch_time 		number_idx_tbl; /* B4320561 - sowsubra */
rr_plan_step_qty        number_idx_tbl; /*Sowmya - As per latest FDD changes */

/* B5338598 rpatangy start */
TYPE batch_activity IS TABLE OF VARCHAR2(16)
INDEX BY BINARY_INTEGER;
empty_batch_activity	batch_activity ;
rr_activity_name	batch_activity ;
rr_operation_no         batch_activity ;
/* B5338598 rpatangy End */

TYPE res_step_qty_uom IS TABLE OF VARCHAR2(3)
INDEX BY BINARY_INTEGER;
empty_step_qty_uom	res_step_qty_uom ;
rr_step_qty_uom        res_step_qty_uom;  /*Sowmya - As per latest FDD changes */

rr_product_item_id      number_idx_tbl ; /* B4777532 - sowsubra */

rr_gmd_rsrc_cnt        number_idx_tbl; /*Sowmya - As per latest FDD changes */
rr_operation_sequence_id number_idx_tbl ; /* B5461922 rpatangy */
jo_wip_entity_id       number_idx_tbl;
jo_instance_id         number_idx_tbl;
jo_operation_seq_num   number_idx_tbl;
jo_operation_sequence_id number_idx_tbl;
jo_organization_id     number_idx_tbl;
jo_department_id       number_idx_tbl;
jo_minimum_transfer_quantity number_idx_tbl;

TYPE recommended_typ IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;
empty_jo_recommended	recommended_typ;
jo_recommended         recommended_typ;
jo_network_start_end   recommended_typ;

jo_reco_start_date     date_idx_tbl;
jo_reco_completion_date date_idx_tbl;

rr_index     NUMBER := 0 ;
arr_index    NUMBER := 0 ;
si_index     NUMBER := 0 ;
inst_indx    NUMBER := 0 ; /* NAVIN :- - For Resource Instance */
jo_index     NUMBER := 0; /* NAMIT :- For msc_st_job_operations */

/* ------------------- Supply declaration ---------------------*/

s_plan_id  		number_idx_tbl  ;

s_inventory_item_id 	number_idx_tbl ;
d_inventory_item_id 	number_idx_tbl ;
f_inventory_item_id 	number_idx_tbl ;

s_new_schedule_date 	date_idx_tbl;
s_old_schedule_date   	date_idx_tbl;
s_new_wip_start_date 	date_idx_tbl;
s_actual_start_date   date_idx_tbl; -- Bug: 8624913
s_old_wip_start_date 	date_idx_tbl;
s_lunit_completion_date date_idx_tbl;

s_disposition_id 	number_idx_tbl;

s_order_type 		number_idx_tbl;

TYPE order_number IS TABLE OF msc_st_supplies.order_number%TYPE
INDEX BY BINARY_INTEGER;
s_order_number order_number ;
empty_sorder_number  order_number ;

s_new_order_quantity 	number_idx_tbl;
s_old_order_quantity 	number_idx_tbl;
s_firm_planned_type 	number_idx_tbl;
s_process_seq_id        number_idx_tbl ;   -- Bug 8349005 Vpedarla

TYPE wip_entity_name IS TABLE OF msc_st_supplies.wip_entity_name%TYPE INDEX BY BINARY_INTEGER;
s_wip_entity_name wip_entity_name   ;
empty_swip_entity_name wip_entity_name   ;

TYPE lot_number IS TABLE OF msc_st_supplies.lot_number%TYPE INDEX BY BINARY_INTEGER;
s_lot_number lot_number ;

s_expiration_date 	date_idx_tbl;
s_firm_quantity 	number_idx_tbl;
s_firm_date 		date_idx_tbl;
s_by_product_using_assy_id number_idx_tbl ;
s_requested_completion_date  date_idx_tbl;
s_schedule_priority  	number_idx_tbl;

/*B5100481 - 16 for pending, 3 for wip*/
s_wip_status_code  	number_idx_tbl;

/* NAVIN: MTQ with Hardlinks */
stp_var_itm_instance_id number_idx_tbl;

stp_var_itm_from_op_seq_id number_idx_tbl;
stp_var_itm_wip_entity_id number_idx_tbl;
stp_var_itm_from_item_id number_idx_tbl;
stp_var_min_tran_qty 	number_idx_tbl;
stp_var_itm_min_tm_off 	number_idx_tbl;
stp_var_itm_max_tm_off 	number_idx_tbl;
stp_var_itm_from_op_seq_num number_idx_tbl;
stp_var_itm_organization_id  number_idx_tbl;

s_index      NUMBER := 0 ;

/* ---------------- Demands declaration ----------------------*/

d_assembly_item_id 	number_idx_tbl ;
f_assembly_item_id 	number_idx_tbl ;

d_demand_date 		date_idx_tbl;
f_demand_date 		date_idx_tbl;

d_requirement_quantity 	number_idx_tbl;
f_requirement_quantity 	number_idx_tbl;
d_demand_type 		number_idx_tbl;
f_demand_type 		number_idx_tbl;
d_origination_type 	number_idx_tbl;
f_origination_type 	number_idx_tbl;

TYPE demand_schedule IS TABLE OF msc_st_demands.demand_schedule_name%TYPE
INDEX BY BINARY_INTEGER;
empty_demand_schedule demand_schedule;
d_demand_schedule demand_schedule;
f_demand_schedule demand_schedule;

TYPE dorder_number IS TABLE OF msc_st_demands.order_number%TYPE INDEX BY BINARY_INTEGER;
empty_dorder_number dorder_number ;
d_order_number dorder_number ;
f_order_number dorder_number ;

TYPE dwip_entity_name IS TABLE OF msc_st_demands.wip_entity_name%TYPE INDEX BY BINARY_INTEGER;
empty_dwip_entity_name dwip_entity_name   ;
d_wip_entity_name dwip_entity_name   ;
f_wip_entity_name dwip_entity_name   ;

d_selling_price 	number_idx_tbl ;
f_selling_price 	number_idx_tbl ;

d_request_date 		date_idx_tbl;
f_request_date 		date_idx_tbl;

TYPE forecast_designator IS TABLE OF msc_st_demands.forecast_designator%TYPE
INDEX BY BINARY_INTEGER;
f_forecast_designator forecast_designator ;

f_sales_order_line_id 	number_idx_tbl;

/*B5100481 - 16 for pending, 3 for wip*/
d_wip_status_code  	number_idx_tbl;

d_index      NUMBER := 0 ;

/* ---------------- Designator declaration ----------------------*/
TYPE designator IS TABLE OF msc_st_designators.designator%TYPE INDEX BY BINARY_INTEGER;
i_designator designator ;

TYPE forecast_set IS TABLE OF msc_st_designators.forecast_set%TYPE INDEX BY BINARY_INTEGER;
i_forecast_set forecast_set;

TYPE description IS TABLE OF msc_st_designators.description%TYPE INDEX BY BINARY_INTEGER;
i_description description ;

i_disable_date 			date_idx_tbl;
i_consume_forecast 		number_idx_tbl;
i_backward_update_time_fence 	number_idx_tbl;
i_forward_update_time_fence 	number_idx_tbl;

i_index      NUMBER := 0 ;

stp_chg_department_id  		number_idx_tbl;
stp_chg_resource_id 		number_idx_tbl;
stp_chg_organization_id 	number_idx_tbl;
stp_chg_wip_entity_id 		number_idx_tbl;
stp_chg_operation_seq_id 	number_idx_tbl;
stp_chg_operation_seq_no 	number_idx_tbl;
stp_chg_resource_seq_num 	number_idx_tbl;
stp_chg_charge_num 		number_idx_tbl;
stp_chg_charge_quanitity 	number_idx_tbl;
stp_chg_charge_start_dt_time 	date_idx_tbl;
stp_chg_charge_end_dt_time 	date_idx_tbl;


--------------------------NAVIN: Sequence Dependencies--------------------------

rr_sequence_id 			number_idx_tbl;
rr_sequence_number 		number_idx_tbl;
rr_firm_type 			number_idx_tbl;
rr_setup_id  			number_idx_tbl;
/* NAVIN: new column for Operation Charges*/
rr_min_capacity  		number_idx_tbl;
rr_max_capacity  		number_idx_tbl;
rr_original_seq_num 		number_idx_tbl;
rr_sequence_dependent_usage   	number_idx_tbl;
rr_alternate_number 		number_idx_tbl;
rr_basis_type 			number_idx_tbl;

/* NAVIN :- Resource Instances start */
/*  Resource instance */

rec_inst_supply_id 		number_idx_tbl;
rec_inst_organization_id 	number_idx_tbl;
rec_inst_sr_instance_id 	number_idx_tbl;
rec_inst_rec_resource_seq_num 	number_idx_tbl;
rec_inst_resource_id 		number_idx_tbl;
rec_inst_instance_id 		number_idx_tbl;
rec_inst_start_date 		date_idx_tbl;
rec_inst_end_date 		date_idx_tbl;
rec_inst_rsrc_instance_hours 	number_idx_tbl;
rec_inst_operation_seq_num 	number_idx_tbl;
rec_inst_department_id 		number_idx_tbl;
rec_inst_wip_entity_id 		number_idx_tbl;

TYPE rec_serial_number IS TABLE OF msc_st_resource_instance_reqs.serial_number%TYPE
INDEX BY BINARY_INTEGER;
empty_inst_serial_number 	rec_serial_number ;
rec_inst_serial_number rec_serial_number;

rec_inst_parent_seq_num  	number_idx_tbl;
rec_inst_original_seq_num 	number_idx_tbl;
rec_inst_equp_item_id 		number_idx_tbl;  /* SOWMYA - As Per latest FDD changes - Resources Instances */

/* NAVIN :- Resource Instances end */

/*-------------------------- Alternate Resources -----------------------------*/

/* Sowmya - As Per the latest FDD changes :- Alternate resources declaration Start */
arr_wip_entity_id       number_idx_tbl;
arr_operation_seq_num   number_idx_tbl;
arr_res_seq_num         number_idx_tbl;
arr_resource_id         number_idx_tbl;
arr_alternate_num       number_idx_tbl;
arr_usage_rate          number_idx_tbl;
arr_assigned_units      number_idx_tbl;
arr_department_id       number_idx_tbl;
arr_activity_group_id   number_idx_tbl;
arr_basis_type          number_idx_tbl;
arr_setup_id            number_idx_tbl;
arr_schedule_seq_num    number_idx_tbl;
arr_maximum_assigned_units   number_idx_tbl;
TYPE alt_resource_varchar_typ IS TABLE OF VARCHAR2(4)
INDEX BY BINARY_INTEGER;
empty_arr_uom_code 	alt_resource_varchar_typ;
arr_uom_code            alt_resource_varchar_typ;

/* Sowmya - As Per latest FDD changes :- Alternate resources declaration Start */

/*-------------------------- Operation Charges-----------------------------*/

v_orgn_id		      NUMBER;
r             	              NUMBER;
p             	              NUMBER ;
chg_res_index 		      NUMBER; /* NAVIN :- Resource Charges */
resource_usage_flag           NUMBER;
resource_instance_usage_flag  NUMBER;
old_rsrc_batch_id             NUMBER;
old_rsrc_resources            VARCHAR2(16);
old_rsrc_original_seq_num     NUMBER;
old_instance_number           NUMBER;
old_rsrc_inst_batch_id        NUMBER;
old_rsrc_inst_resources       VARCHAR2(16);
old_rsrc_inst_original_seq_num NUMBER;


/***********************************************************************
*
*   NAME
*	bsearch_rsrc_chg
*
*   DESCRIPTION
*	This function will search through the resource charges PL/SQL table
*       using Binary Search.
*
*       IF  p_batch_id Found IN  stp_chg_tbl THEN
*         Return the last record location for p_batch_id in stp_chg_tbl.
*       ELSE if p_batch_id NOT Found IN the stp_chg_tbl THEN
*          Return -1
*       END IF;
*
*   HISTORY
*	Navin Sinha
************************************************************************/
FUNCTION bsearch_rsrc_chg ( p_batch_id IN NUMBER)
	 RETURN INTEGER IS

top     INTEGER ;
bottom  INTEGER ;
mid     INTEGER ;

ret_loc     INTEGER ;
BEGIN
     top    := 1;
     bottom := stp_chg_tbl.count;
     mid    := -1 ;
     ret_loc   := -1 ;

   WHILE  (top <= bottom )
    LOOP
     mid := top + ( ( bottom - top ) / 2 );

     IF p_batch_id < stp_chg_tbl(mid).wip_entity_id THEN
	bottom := mid -1 ;
     ELSIF p_batch_id > stp_chg_tbl(mid).wip_entity_id THEN
	top := mid + 1 ;
     ELSE
	ret_loc := mid ;
              EXIT;
     END IF ;
    END LOOP; /* (top <= bottom ) */

    -- Identify the location of the last record for the currently processed p_batch_id in stp_chg_tbl.
    IF ret_loc > 0 AND ret_loc <= stp_chg_tbl.count THEN
      LOOP
       IF ret_loc = stp_chg_tbl.count THEN
          -- Pointer is at last record of the array.
          Return ret_loc;
       END IF ;

       ret_loc :=  ret_loc + 1;
       IF p_batch_id <> stp_chg_tbl(ret_loc).wip_entity_id THEN
          -- Missmatch occurred hence return the previous location.
          Return (ret_loc - 1);
       END IF ;
      END LOOP;
    ELSE
       -- Not found
       Return -1 ;
    END IF ;

END bsearch_rsrc_chg ;

/* **********************************************************************
*   NAME
*	inst_stp_chg_tbl
*
*   DESCRIPTION
*       Inserts Data into step charge staging table.
*   HISTORY
*       B4761946, 20-DEC-2005 Rajesh Patangya Changed the while loop logic
************************************************************************/

PROCEDURE inst_stp_chg_tbl(pinstance_id IN NUMBER, p_batch_loc IN NUMBER)
IS

rsrc_chg_loc NUMBER;

BEGIN
  -- Locate the batch in Resource Charge PL/SQL table, i.e stp_chg_tbl
  -- rsrc_chg_loc will be -1 if NOT found OR it will point to last record
  -- location for x_batch_id in stp_chg_tbl.
  rsrc_chg_loc := bsearch_rsrc_chg(rsrc_tab(p_batch_loc).x_batch_id);

  -- IF resource charges found then process....
  IF rsrc_chg_loc > 0 THEN
     IF prod_tab(p).firmed_ind = 1 AND
         stp_chg_tbl(rsrc_chg_loc).charge_start_dt_time IS NULL AND
         stp_chg_tbl(rsrc_chg_loc).charge_end_dt_time IS NULL THEN
            -- APS decoded value as per
            -- DECODE(rsrc_tab(p_batch_loc).scale_type,0,2,1,1,2,3);
            rsrc_tab(p_batch_loc).scale_type := 1;
     ELSE
      -- Insert all the resource charge records untill the batch_id,
      -- batchstep_id and resource_id
      -- are same as currently processed resource record.
     /* B4761946, Rajesh Patangya Changed the while loop logic */
      LOOP
       IF (rsrc_tab(p_batch_loc).x_batch_id =
             stp_chg_tbl(rsrc_chg_loc).wip_entity_id) AND
          (rsrc_tab(p_batch_loc).batchstep_id =
             stp_chg_tbl(rsrc_chg_loc).operation_seq_id) AND
          (rsrc_tab(p_batch_loc).x_resource_id =
             stp_chg_tbl(rsrc_chg_loc).resource_id) THEN

        log_message(rsrc_tab(p_batch_loc).x_batch_id || ' -- ' ||
             stp_chg_tbl(rsrc_chg_loc).operation_seq_id || ' --'||
             stp_chg_tbl(rsrc_chg_loc).resource_id || ' --'|| rsrc_chg_loc || '--' ||
             stp_chg_tbl(rsrc_chg_loc).wip_entity_id );

	chg_res_index := chg_res_index + 1 ;
        stp_chg_resource_id(chg_res_index) := stp_chg_tbl(rsrc_chg_loc).resource_id ;
        stp_chg_organization_id(chg_res_index) := stp_chg_tbl(rsrc_chg_loc).organization_id ;
        stp_chg_department_id(chg_res_index) := ((v_orgn_id * 2) + 1) ;
        stp_chg_wip_entity_id(chg_res_index) := stp_chg_tbl(rsrc_chg_loc).wip_entity_id ;
        stp_chg_operation_seq_id(chg_res_index) := stp_chg_tbl(rsrc_chg_loc).operation_seq_id ;
        stp_chg_operation_seq_no(chg_res_index) := stp_chg_tbl(rsrc_chg_loc).operation_seq_no ;
        stp_chg_resource_seq_num(chg_res_index) := stp_chg_tbl(rsrc_chg_loc).resource_seq_num ;
        stp_chg_charge_num(chg_res_index) := stp_chg_tbl(rsrc_chg_loc).charge_num ;
        stp_chg_charge_quanitity(chg_res_index) := stp_chg_tbl(rsrc_chg_loc).charge_quantity ;
        stp_chg_charge_start_dt_time(chg_res_index) := stp_chg_tbl(rsrc_chg_loc).charge_start_dt_time ;
        stp_chg_charge_end_dt_time(chg_res_index) := stp_chg_tbl(rsrc_chg_loc).charge_end_dt_time ;
        stp_instance_id (chg_res_index) := pinstance_id ;
       END IF;

       rsrc_chg_loc := rsrc_chg_loc - 1 ;

       IF ((rsrc_chg_loc = 0) OR (rsrc_tab(p_batch_loc).x_batch_id <>
                stp_chg_tbl(rsrc_chg_loc).wip_entity_id)) THEN
                -- No more records to process in Step Charge PL/SQL table.
           EXIT;
       END IF;
      END LOOP;
     END IF;
  END IF;  /*  rsrc_chg_loc > 0 */
END inst_stp_chg_tbl;

/***********************************************************************
*
*   NAME
*	Enh_bsearch_alternate_rsrc
*
*
*       IF  pprim_resource_id Found IN  rtg_alt_rsrc_tab THEN
*         Return the first record location for pprim_resource_id in rtg_alt_rsrc_tab.
*       ELSE IF pprim_resource_id NOT Found IN  rtg_alt_rsrc_tab THEN
*          Return -1
*       END IF;
*
*   DESCRIPTION
*	This function will search throught the alternate resource PL/SQL table
*       using Binary Search. It is a modified Binary Search, as after finding a hit
*       it loops back to find the first row that gave the hit.
*   HISTORY
*	Navin Sinha
************************************************************************/

FUNCTION Enh_bsearch_alternate_rsrc ( pprim_resource_id   IN NUMBER)
		RETURN INTEGER IS

top     INTEGER ;
bottom  INTEGER ;
mid     INTEGER ;

ret_loc     INTEGER ;
BEGIN
     top    := 1;
     bottom := alt_rsrc_size ;
     mid    := -1 ;
     ret_loc   := -1 ;

   WHILE  (top <= bottom )
    LOOP
     mid := top + ( ( bottom - top ) / 2 );

     IF pprim_resource_id < rtg_alt_rsrc_tab(mid).prim_resource_id THEN
	bottom := mid -1 ;
     ELSIF pprim_resource_id > rtg_alt_rsrc_tab(mid).prim_resource_id THEN
	top := mid + 1 ;
     ELSE
	ret_loc := mid ;
              EXIT;
     END IF ;
    END LOOP; /* (top <= bottom ) */

    -- Bring back the pointer to the first location from where the Primary resource data starts.
    IF ret_loc >= 1 THEN
      LOOP
       IF ret_loc = 1 THEN
          -- Pointer is at first location of the array.
          Return ret_loc;
       END IF ;

       ret_loc :=  ret_loc - 1;
       IF pprim_resource_id <> rtg_alt_rsrc_tab(ret_loc).prim_resource_id THEN
          -- Missmatch occurred hence return the previous location.
          Return (ret_loc +1);
       END IF ;
      END LOOP;
    ELSE
      -- Not found
      Return -1 ;
    END IF ;  /* ret_loc >= 1 */

END Enh_bsearch_alternate_rsrc ;

/***********************************************************************
*
*   NAME
*     production_orders
*
*   DESCRIPTION
*     This procedure will take the production orders, batches and FPOs,
*     that have valid item/warehouse definitions as defined in the
*     the plant/whse eff and write them to the table msc_std_demands and \
*     msc_st_supplies. The products and byproducts will be written as
*     supplies and ingredients as demands
*   HISTORY
*     M Craig
*   04/03/2000 - Using mtl_organization_id instead of organization_id from
*              - sy_orgn_mst , Bug# 1252322
*   Sridhar 31-DEC-01 B2159482 - Added Alcoa Cursor Changes to the
*                                latest version of the package
*   Sridhar 15-JAN-02 B1992371   Modified the Cursor with GME Changes
*   Sridhar 27-FEB-2002 B2239948 Added correction for poc_ind comparisons
*   Sridhar 15-MAY-2002 B2363117 Added nvl Statement for If statements with
*                                Actual_cmplt_date and Start Date
*   Sridhar 10-JUL-2002 B2383692 Added code to take care of the last record
*   Sridhar 10-JUL-2002 B1522576 Added code to differentiate FPO Batches
*   Sridhar 19-MAR-2003 B2858929 Added Code to take resolve the Bug
*                                Resource Seq is incremented only if the
*                                activity is Changed
*   Sridhar 31-MAR-2003 B2882286 Ensuring the Order so that if the last batch
*                                resource requirements are written
*   Sridhar 30-APR-2003 B2919303 Added Operation Seq Number in msc_st_supplies
*                                and in msc_st_demands table
*   Sridhar 09-MAY-2003 B2919303 Added line_no and included in order by clause
*   Sridhar 12-MAY-2003 B2953953 Populated BY_PRODUCT_USING_ASSY_ID with
*                                product_line which is the assembly_item_id
*   Navin   21-APR-2003 B3577871 ST:OSFME2: collections failing in planning data pull.
*                                Added handling of NO_DATA_FOUND Exception.
*                                And return the return_status as TRUE.
************************************************************************/

PROCEDURE production_orders(
  pdblink        IN  VARCHAR2,
  pinstance_id   IN  NUMBER,
  prun_date      IN  DATE,
  pdelimiter     IN  VARCHAR2,
  return_status  IN OUT NOCOPY BOOLEAN)

IS

/* Defining the dynamic cursors to be used to retrieve data later. Production
   details, resource details, resource warehouse, and warehouse organization */

  TYPE gmp_cursor_typ IS REF CURSOR;
  c_prod_dtl           gmp_cursor_typ;
  rsrc_dtl             gmp_cursor_typ;
  rsrc_whse            gmp_cursor_typ;
  cur_alt_resource     gmp_cursor_typ; /* NAVIN :- Alternate Resource */
  cur_rs_intance       gmp_cursor_typ; /* NAVIN :- Resource Intance */
  c_chg_cursor         gmp_cursor_typ; /* NAVIN :- Resource Charges */
  rsrc_uoms_cur        gmp_cursor_typ; /* Sowmya - As per latest FDD Changes */
  uom_code_ref         gmp_cursor_typ; /* NAMIT - UOM Class */

  v_prod_cursor        VARCHAR2(32000) ;
  v_rsrc_cursor        VARCHAR2(32000) ;
  sql_stmt             VARCHAR2(32000) ;
  uom_code_cursor      VARCHAR2(32000);

  l_charges_remaining  NUMBER;
  res_whse             BOOLEAN ;
  res_whse_id          PLS_INTEGER ;
  supply_type          PLS_INTEGER ;
  old_batch_id         PLS_INTEGER;
  product_line         PLS_INTEGER ;
  opm_product_line     NUMBER ;
  prod_line_id         NUMBER ;
  prod_plant           VARCHAR2(4) ;
  order_no             VARCHAR2(37) ;
  v_inflate_wip        NUMBER ;
  found_mtl            NUMBER ;
  i                    PLS_INTEGER ;
  old_step_no          NUMBER ;
  prod_count           PLS_INTEGER ;
  resource_count       PLS_INTEGER ;
  stp_chg_count        PLS_INTEGER ;
  /* B1224660 added locals to develop resource sequence numbers */
  v_resource_usage     NUMBER ;
  v_res_seq            NUMBER ;
  v_schedule_flag      PLS_INTEGER ;
  v_parent_seq_num     NUMBER ;
  v_seq_dep_usage      NUMBER ; /* NAVIN :- Sequence Dependency */
  found_chrg_rsrc      NUMBER ; /* NAVIN :- Chargeable Resource */
  chrg_activity        NUMBER; /* NAVIN :- Chargeable Activity */
  v_rsrc_cnt           PLS_INTEGER ;
  v_start_date         DATE ;
  v_end_date           DATE ;
  old_activity         NUMBER ;
  v_alternate          NUMBER ; /* NAVIN :- added for alternate resource */
  alternate_rsrc_loc   NUMBER ; /* NAVIN :- added for alternate resource */
  alt_cnt              NUMBER ; /* NAVIN :- added for alternate resource */
  row_count            NUMBER ;
  start_loc            NUMBER ;
  l_gmp_um_code        VARCHAR2(25);
  l_gmp_uom_class      VARCHAR2(10); /* UOM Class */
  /*Sowmya - As per latest FDD changes - Start*/
  v_max_rsrcs          NUMBER; --for collecting the max resources
  /*Sowmya - As per latest FDD changes - End*/
  v_activity_group_id  PLS_INTEGER ;   /* B3995361 rpatangy */
  mk_alt_grp           NUMBER ;   /* B3995361 rpatangy */

  l_process_seq_id     PLS_INTEGER ; -- B8349005 Vpedarla

  uom_conv_cursor      VARCHAR2(32000); -- Bug: 8647592 Vpedarla
  c_uom_conv           gmp_cursor_typ ;  -- Bug: 8647592 Vpedarla
  v_new_res_usage      NUMBER;   -- Bug: 8647592 Vpedarla

BEGIN
  /* Initialize the values */
  v_activity_group_id  := 0;     /* B3995361 rpatangy */
  mk_alt_grp           := 0 ;    /* B3995361 rpatangy */
  v_prod_cursor        := NULL;
  v_rsrc_cursor        := NULL;

  res_whse             := FALSE;
  res_whse_id          := 0;
  supply_type          := 0;
  product_line         := 0;
  opm_product_line     := 0;
  prod_line_id         := 0;
  prod_plant           := NULL;
  order_no             := NULL;
  v_inflate_wip        := 0;
  found_mtl            := 0;
  i                    := 0;
  p                    := 0;
  r                    := 0;
  old_step_no          := 0;
  prod_count           := 1;
  resource_count       := 1;
  stp_chg_count        := 1;

  /* B1224660 added locals to develop resource sequence numbers */
  v_resource_usage     := 0;
  v_res_seq            := 0;
  v_schedule_flag      := 0;
  v_parent_seq_num     := 0;
  v_seq_dep_usage      := 0; /* NAVIN :- Sequence Dependency */
  found_chrg_rsrc      := 0; /* NAVIN :- Chargeable Resource */
  chrg_activity        := -1; /* NAVIN :- Chargeable Activity */
  chg_res_index        := 0; /* NAVIN :- Resource Charges */
  v_rsrc_cnt           := 0;
  v_start_date         := NULL;
  v_end_date           := NULL;
  old_activity         := 0;
  v_alternate          := 0; /* NAVIN :- added for alternate resource */
  alternate_rsrc_loc   := 0; /* NAVIN :- added for alternate resource */
  alt_cnt              := 0; /* NAVIN :- added for alternate resource */

  d_index              := 0 ;
  s_index              := 0 ;
  rr_index             := 0 ;
  arr_index            := 0 ;
  jo_index             := 0;
  gprod_size           := 0 ;
  grsrc_size           := 0;
  g_rsrc_cnt           := 1;
  si_index             := 1;
  inst_indx            := 0;
  row_count            := 1; /* NAVIN :- Maintains the row count. From set of repetitive rows, only one row is inserted. */
  start_loc            := 1;
  shld_res_passed      := FALSE;
  l_res_inst_process   := 0;
  converted_usage      := 0;
  v_max_rsrcs          := 0;

  l_process_seq_id     := 0; -- B8349005 Vpedarla

  IF return_status THEN
    v_cp_enabled := TRUE;
  ELSE
    v_cp_enabled := FALSE;
  END IF;

    /* populate the org_string */
     IF gmp_calendar_pkg.org_string(pinstance_id) THEN
        NULL ;
     ELSE
        RAISE invalid_string_value  ;
     END IF;

    /* Disable Formula Security Functionality */

  v_sql_stmt := 'BEGIN '
    || ' gmd_p_fs_context.set_additional_attr' || pdblink
    || ';END;'   ;
  EXECUTE IMMEDIATE v_sql_stmt ;

   BEGIN  -- B8349005 Vpedarla
   select NVL(max(process_seq_id),0) into l_process_seq_id  from msc_st_supplies
        where sr_instance_id = pinstance_id ;
    log_message('production_orders pinstance_id = ' || pinstance_id || ' AND l_process_seq_id = ' || l_process_seq_id );
   EXCEPTION
     WHEN no_data_found then
        l_process_seq_id := 0 ;
     WHEN others then
        l_process_seq_id := 0 ;
    END; -- B8349005 Vpedarla


  /* Get the profile value for inflating usage by the utilization and
     efficiency */
  IF NVL(fnd_profile.value('MSC_INFLATE_WIP') ,'N')= 'N' THEN
    v_inflate_wip := 0 ;
  ELSE
    v_inflate_wip := 1 ;
  END IF;

/* Not pick the "GMP:UOM for Hour" Profile and pick "BOM:UOM for Hour" profile. */
   /* bug:6710684 Vpedarla made changes to fetch the profile value from source server*/
      -- l_gmp_um_code   := fnd_profile.VALUE('BOM:HOUR_UOM_CODE'); /* OPM UOM */
         l_gmp_um_code   := GMP_BOM_ROUTING_PKG.get_profile_value('BOM:HOUR_UOM_CODE', pdblink );
/* bug: 6710684 end of changes */

  IF l_gmp_um_code IS NOT NULL THEN
/* Get the UOM code and UOM Class corresponding to "GMP: UOM for Hour" Profile */
     uom_code_cursor :=
                      ' select uom_class '
                      ||' from mtl_units_of_measure'||pdblink
                      ||' where uom_code = :gmp_um_code ';

     OPEN uom_code_ref FOR uom_code_cursor USING l_gmp_um_code;
     FETCH uom_code_ref INTO l_gmp_uom_class;
     CLOSE uom_code_ref;
  ELSE
     RAISE invalid_gmp_uom_profile  ;
  END IF;
  IF (l_gmp_uom_class IS NULL) THEN
     RAISE invalid_gmp_uom_profile  ;
  END IF;

  /* B2919303 - The following cursor has been modified to include
     batchstep_no for material txns which has release type as 3 ( auto by step )
     , if the rows are not release type as 3 then batchstep is taken as 0
  */
  /* B2953953 Added two temporary columns so that we can get the correct
     Order , Note that the Line_type is decoded so that Line_type - prod
     becomes 3 and is ordered first and product row is made into line_no 0
  */
  /* B2964633 - Added t.trans_date also in the Order by Clause to make sure
     Product comes in the first row, because product is always in the last
     step and therefore ordering by trans_date in the descending order */
  /* B3054460 - OPM/APS TO CATER FOR CHANGE TO TIME PHASED PLANNING
     OF MANUAL CONSUMPTION TYPE, - Considered release_type 1 also
  */

  v_prod_cursor := 'SELECT'
      || '   h.batch_no,'
      || '   gp.organization_code, '
      || '   h.batch_id,'
      || '   ((h.batch_id * 2) + 1), '
      || '   h.organization_id, '
      || '   h.routing_id,'
      || '   h.plan_start_date, '
      || '   h.plan_cmplt_date end_date,'
      || '   h.ACTUAL_START_DATE, '  -- bug: 8624913
      || '   d.material_requirement_date, '
      || '   h.batch_status,'
      || '   h.batch_type,'
      || '   d.material_detail_id,'
      || '   d.line_no  ,'     /* B2919303 */
      || ' DECODE(d.inventory_item_id ,v.inventory_item_id,0,d.line_no) t_line_no,' /* B2953953 */
      || '   d.line_type,'
      || ' DECODE(d.line_type,1,3,d.line_type) t_line_type,' /* B2953953 */
      || '   (nvl(d.wip_plan_qty,plan_qty) - d.actual_qty ), '
      || ' DECODE(d.original_qty,0,Inv_Convert.Inv_Um_Convert'||pdblink
      || '       (d.inventory_item_id, 0,d.organization_id, NULL,1, '
      ||' d.dtl_um, msi.primary_uom_code,NULL,NULL),'
      || ' (d.original_primary_qty /d.original_qty)), '
      || '   d.inventory_item_id matl_item_id, '
      || '   v.inventory_item_id recipe_item_id, '
      || '   h.poc_ind,   '
      || '   DECODE(h.firmed_ind,1,1,2), '
      || '   decode(d.release_type,0, -1, nvl(gbs.batchstep_no,-1)) batchstep_no,'
      || '   h.due_date,'
      || '   h.order_priority,'
      ||'   ((gbsi.batchstep_id*2)+1) from_op_seq_id, '     /* B5461922 */
      || '   DECODE(d.line_type,1,gbsi.minimum_transfer_qty, NULL) , '
      || '   DECODE(d.line_type,1,gbsi.minimum_delay, NULL) t_minimum_delay, '
      || '   DECODE(d.line_type,1,gbsi.maximum_delay, NULL) t_maximum_delay,'
      || '   gbs.batchstep_no'
      || ' FROM'
      || '   gme_batch_header'||pdblink||' h,'
      || '   gme_material_details'||pdblink||' d,'
      || '   gme_batch_step_items'||pdblink||' gbsi,'  /* 2919303 */
      || '   gme_batch_steps'||pdblink||' gbs,'       /* 2919303 */
      || '   gmd_recipe_validity_rules'||pdblink||' v,'
      || '   mtl_parameters'||pdblink||' gp, '  -- Added this table to get the plant code
      || '   mtl_system_items'||pdblink||' msi '
      || ' WHERE'
      || '     h.batch_id = d.batch_id'
      || '   AND h.recipe_validity_rule_id = v.recipe_validity_rule_id'
      || '   AND EXISTS (SELECT '
      || '                 1  '
      || '               FROM '
      || '                 gme_material_details'||pdblink||' gmd '
      || '               WHERE '
      || '                     gmd.batch_id = h.batch_id '
      || '                 AND gmd.inventory_item_id = v.inventory_item_id) '
      || '   AND h.organization_id = gp.organization_id '
      || '   AND gp.process_enabled_flag = '||''''||'Y'||'''' --invconv :- sowmya added
      || '   AND d.organization_id = msi.organization_id '
      || '   AND d.inventory_item_id = msi.inventory_item_id '
      || '   AND msi.process_execution_enabled_flag = '||''''||'Y'||''''
      || '   AND h.batch_type IN (0,10) '
      || '   AND d.material_detail_id = gbsi.material_detail_id (+)' /* 2919303 */
      || '   AND d.batch_id = gbsi.batch_id (+)  '      /* 2919303 */
      /* Bug 8614604  Vpedarla removed the whole check for product qty */
 /* B3625247 - Sowmya -
 * When a batch that is in WIP status in which the product is completed
 * manually, observed that the ingredient and the resouce requirements were not
 * collected on to the APS. Although in WIP the batch hasn't progressed.
 *         When a product is completed manually the transaction in ic_tran_pnd
 *         is updated where completed_ind = 1 and trans_qty = batch_output_qty.
 *         */
        /*So in this case a new transaction for the item completed manully is
 * inserted into ic_tran_pnd by GME. This new transaction for the product has
 * the completed_ind = 0 and trans_qty = 0. */
        /*To fetch this record added the condition in the whsere caluse and
 * ensured that this condition works on the product transactions alone. */
  -- B8342619 Rajesh Patangya
      ||' AND (  '
      || '    ( (nvl(d.wip_plan_qty,plan_qty) - nvl(d.actual_qty,0) ) > 0 ) '
      || '      OR '
      || '    (  d.inventory_item_id = v.inventory_item_id  ) '
      || '   ) '
  --    || '   AND (nvl(d.wip_plan_qty,plan_qty) - d.actual_qty ) > 0  ' /*B5100675*/
/*B5100675 - sowsubra - the demand for an ingredient in a batch, which has been consumed by a step
that has already completed should not be passed.And hence added a where clause to filter these rows*/
      || '   AND gbsi.batch_id = gbs.batch_id (+) '       /* 2919303 */
      || '   AND gbsi.batchstep_id  = gbs.batchstep_id (+)';   /* 2919303 */

      IF gmp_calendar_pkg.g_in_str_org  IS NOT NULL THEN
         v_prod_cursor := v_prod_cursor
         ||'    AND h.organization_id ' || gmp_calendar_pkg.g_in_str_org ;
      END IF;

      v_prod_cursor := v_prod_cursor
      || ' AND h.batch_status in (1, 2)'
      || ' ORDER BY h.batch_id ,t_line_type DESC ,t_line_no , d.material_requirement_date DESC ' ;

gmp_debug_message('v_prod_cursor - '|| v_prod_cursor);

    OPEN c_prod_dtl FOR v_prod_cursor;
    LOOP
      FETCH  c_prod_dtl INTO prod_tab(prod_count);
      EXIT WHEN  c_prod_dtl%NOTFOUND ;
      prod_count := prod_count + 1;
    END LOOP;
    CLOSE c_prod_dtl ;
    gprod_size := prod_count - 1;
    log_message('Batches size is = '|| to_char(gprod_size) );
    time_stamp ;

    v_rsrc_cursor := 'SELECT'
      || ' h.batch_id,'
      || ' ((r.batch_id * 2) + 1), '
      || ' r.batchstep_no,'
      || ' NVL(o.sequence_dependent_ind, -1),'	/* NAVIN: Moved this column up for order by clause and changed from NVL(o.sequence_dependent_ind,0) */
      || ' DECODE(gs.prim_rsrc_ind, 1,1,2,2,0,3),' /* This will ensure that ordering will always have primary first */
      || ' gs.resources,'
      || ' ((gri.instance_id * 2) + 1) , '  /* SOWMYA - As Per latest FDD */
      || ' NVL(t.sequence_dependent_ind,0), '
      || ' gs.plan_start_date,'
      || ' h.organization_id, '
      || ' gs.prim_rsrc_ind,'
      || ' c.resource_id,'
      || ' ((c.resource_id * 2) + 1),'
      || ' o.activity, '
      || ' go.oprn_no, '
      || ' gs.plan_rsrc_count,'
      || ' gs.actual_rsrc_count,'
      || ' gs.actual_start_date,'
      || ' gs.plan_cmplt_date,'
      || ' gs.actual_cmplt_date,'
      || ' r.step_status, '  /* B3995361 */
      || ' SUM(t.resource_usage) OVER (PARTITION BY t.doc_id, t.resources, t.line_id) resource_usage, '  -- summarized usage for the step resource
      || ' SUM(t.resource_usage) OVER (PARTITION BY t.doc_id, t.resources, t.line_id, t.instance_id) resource_instance_usage, ' -- summarized usage for the step resource instances
      || ' nvl(gri.eqp_serial_number,to_char(gri.instance_number)), '
      || ' DECODE(gs.scale_type,0,2,1,1,2,3), '
      || ' c.capacity_constraint , '
      || ' r.plan_step_qty, '
      || ' NVL(r.minimum_transfer_qty,-1), '
      || ' NVL(o.material_ind,0), '
      || ' 1 schedule_flag, '
      || ' o.plan_start_date, '
      || ' (DECODE(c.utilization,0,100,NVL(c.utilization,100))/100) * '
      || '   (DECODE(c.efficiency,0,100,NVL(c.efficiency,100))/100), '
      || ' o.batchstep_activity_id, '
      || ' gs.group_sequence_id,'
      || ' gs.group_sequence_number,'
      || ' nvl(gs.firm_type,0),'	/*Sowmya - If null then pass 0*/
      || ' gs.sequence_dependent_id  setup_id,'
  -- In the situation that value of calculate_charges at Step Resource has been
  -- set to 0 or NULL the values will need to be adjusted for min and max capacity
  -- at the resource level. min capacity will be set to 0 and the max capacity
  -- will be set to 99999999999999999
      || ' DECODE(NVL(gs.calculate_charges,0), 0, 0, gs.min_capacity) t_min_capacity,'
      || ' DECODE(NVL(gs.calculate_charges,0), 0, 99999999999999999, gs.max_capacity) t_max_capacity,'
      || ' gs.sequence_dependent_usage, '
      || ' gs.batchstep_resource_id,'
      /* NAVIN: for calculating WIP Charges */
      || ' r.step_status, '
      || ' r.plan_charges,'
      || ' gs.plan_rsrc_usage,'
  -- Bug: 6925112 Vpedarla modified the actual_rsrc_usage column inserted a NVl funtion
      || ' nvl(gs.actual_rsrc_usage,0) actual_rsrc_usage,'
      || ' ((r.batchstep_id*2)+1),'    /* Navin 6/23/2004 Added for resource charges*/
      || '  SUM(NVL(o.material_ind,0))  OVER (PARTITION BY '
      || '  o.batch_id, r.batchstep_id) mat_found, '
   -- OPM break_ind values 0 and NULL maps to value 2 of MSC breakable_activity_flag
   -- and 1 maps with 1.
      || ' DECODE(NVL(o.break_ind,0), 1, 1, 2) breakable_activity_flag , '
      || ' gs.usage_um ,'  --invconv :- sowmya changed this to usage um
      || ' r.step_qty_um ,' --invconv :- sowmya changed this to step_qty_um
      || ' gri.equipment_item_id ,' /* SOWMYA - As Per latest FDD changes */
      || ' gs.plan_rsrc_count gmd_rsrc_count,' /*passed on msc_st_resource_requirements*/
      || ' r.plan_start_date, ' /* populate msc_st_job_operations.reco_start_date */
      || ' r.plan_cmplt_date, ' /* populate msc_st_job_operations.reco_completion_date */
      || ' DECODE(nvl(c.efficiency,0),0,100) ' /*B4320561 - If null then resource is 100%efficient */
      || ' FROM'
      || ' mtl_units_of_measure'||pdblink||' uom, '
      || ' mtl_units_of_measure'||pdblink||' uom2, '
      || ' gme_batch_header'||pdblink||' h,'
      || ' gme_batch_steps'||pdblink||' r,'
      || ' gme_batch_step_activities'||pdblink||' o,'
      || ' gme_batch_step_resources'||pdblink||' gs,'
      || ' gme_resource_txns'||pdblink||' t , '
      || ' gmp_resource_instances'||pdblink||' gri, '
      || ' gmd_operations'||pdblink||' go, '
      || ' cr_rsrc_dtl'||pdblink||' c'
      || ' WHERE'
      || '     h.batch_id = r.batch_id '
      || ' AND r.batch_id = o.batch_id'
      || ' AND r.batchstep_id = o.batchstep_id'
      || ' AND o.batchstep_activity_id = gs.batchstep_activity_id'
      || ' AND o.batch_id = t.doc_id'
      || ' AND gs.batchstep_resource_id = t.line_id'
      || ' AND t.completed_ind = 0 '
      || ' AND NVL(t.sequence_dependent_ind,0) = 0 ' /* B4900503, Rajesh Patangya */
      || ' AND t.delete_mark = 0 '
      || ' AND t.instance_id = gri.instance_id (+) '
      || ' AND nvl(gri.inactive_ind,0) = 0 '
      || ' AND c.organization_id = h.organization_id '
      || ' AND c.resources = gs.resources'
      || ' AND c.delete_mark = 0 '
      || ' AND nvl(c.inactive_ind,0) = 0 '
/*B4313202 COLLECTING DATA FOR COMPLETED OPERATIONS:Included a chk for step status = 3*/
      || ' AND r.step_status in (1, 2, 3)'
      || ' AND c.Schedule_Ind <> 3 ' /* NAVIN:  gs.prim_rsrc_ind in (1,2) */
      || ' AND uom.uom_class = :gmp_uom_class '
      || ' AND uom.uom_code = gs.usage_um ' /* Sowmya - Alternate Resources */
      || ' AND uom2.uom_code = r.step_qty_um ' ;

      IF gmp_calendar_pkg.g_in_str_org  IS NOT NULL THEN
         v_rsrc_cursor := v_rsrc_cursor
       ||'    AND h.organization_id ' || gmp_calendar_pkg.g_in_str_org ;
      END IF;

      v_rsrc_cursor := v_rsrc_cursor
        || ' AND go.oprn_id = r.oprn_id '
        || ' AND go.delete_mark = 0 '
        || ' ORDER BY '
        ||'         1,2,3,4,5,6,7,8 DESC,9'; /* NAVIN: converted to position notation in Order By*/

gmp_debug_message('l_gmp_uom_class - '|| l_gmp_uom_class);
gmp_debug_message('v_rsrc_cursor - '|| v_rsrc_cursor);

      /* RAJESH PATANGYA open and fetch the all the batch details  */
      OPEN rsrc_dtl FOR v_rsrc_cursor USING l_gmp_uom_class;
      LOOP
            FETCH rsrc_dtl INTO rsrc_tab(resource_count);
            EXIT WHEN rsrc_dtl%NOTFOUND;
            resource_count := resource_count + 1;
      END LOOP;
      CLOSE rsrc_dtl ;
      grsrc_size := resource_count - 1;
      log_message('Batches Resource size is = '|| to_char(grsrc_size) );
      time_stamp ;

   -- NAVIN: START Operation Charges Data needs to be transferred to APS in to
   -- Msc_st_resource_charges
      stp_chg_cursor:=
        ' SELECT '
      ||' ((gbsc.batch_id*2)+1) x_batch_id,'
      ||' ((gbsc.batchstep_id*2)+1),'       /* B5461922 */
      || ' ((crd.resource_id * 2) + 1),'
      ||' gbsc.charge_number,'
      ||' h.organization_id, '
      ||' gbs.batchstep_no,'
      ||' gbsc.activity_sequence_number,'
      ||' gbsc.charge_quantity, '
      ||' gbsc.plan_start_date, '
      ||' gbsc.plan_cmplt_date'
      ||' FROM'
      ||' gme_batch_step_charges'||pdblink||' gbsc,'
      ||' cr_rsrc_dtl'||pdblink||' crd,'
      ||' gmd_recipe_validity_rules'||pdblink||' v,'
      ||' gme_batch_steps'||pdblink||' gbs,'
      ||' gme_batch_header'||pdblink||' h'
      ||' WHERE       '
      ||' h.batch_id = gbs.batch_id '
      ||' AND gbsc.batch_id = gbs.batch_id '
      ||' AND gbsc.batchstep_id = gbs.batchstep_id '
      ||' AND h.recipe_validity_rule_id = v.recipe_validity_rule_id'
      ||' AND EXISTS (SELECT '
      ||'               1  '
      ||'             FROM '
      ||'               gme_material_details'||pdblink||' gmd '
      ||'             WHERE '
      ||'                   gmd.batch_id = h.batch_id '
      ||'               AND gmd.inventory_item_id = v.inventory_item_id) '
      ||' AND crd.resources = gbsc.resources '
      ||' AND crd.organization_id = h.organization_id '
      ||' AND gbs.step_status in (1, 2) ';

      IF gmp_calendar_pkg.g_in_str_org  IS NOT NULL THEN
	   stp_chg_cursor := stp_chg_cursor
          ||'    AND h.organization_id ' || gmp_calendar_pkg.g_in_str_org ;
      END IF;

      stp_chg_cursor := stp_chg_cursor
            ||' ORDER BY 1, 2, 3, 4 ' ;

gmp_debug_message('stp_chg_cursor - '|| stp_chg_cursor);

      OPEN c_chg_cursor FOR stp_chg_cursor ;
      LOOP
            FETCH c_chg_cursor INTO stp_chg_tbl(stp_chg_count);
            EXIT WHEN c_chg_cursor%NOTFOUND;
            stp_chg_count := stp_chg_count + 1;
      END LOOP;
      CLOSE c_chg_cursor ;
      stp_chg_count := stp_chg_count - 1;
      log_message('Batch Step charge size is = '|| to_char(stp_chg_count) );
      time_stamp ;
      log_message(gmp_calendar_pkg.g_in_str_org);

     /* NAVIN :- alternate resource */
     /* NAVIN: In Procedure production_orders just before starting the looping for prod_dtl cursor
     try to get all the alternate Resources.*/

     /* Alternate Resource selection   */
     /* B5688153, Rajesh Patangya prod spec alt*/
        statement_alt_resource :=
                     ' SELECT pcrd.resource_id, acrd.resource_id, '
                   ||' cam.runtime_factor, '
/*prod spec alt*/  ||' nvl(cam.preference,-1), nvl(prod.inventory_item_id,-1)   '
                   ||' FROM  cr_rsrc_dtl'||pdblink||' acrd, '
                   ||'       cr_rsrc_dtl'||pdblink||' pcrd, '
                   ||'       cr_ares_mst'||pdblink||' cam, '
                   ||'       gmp_altresource_products'||pdblink||' prod'
                   ||' WHERE cam.alternate_resource = acrd.resources '
                   ||'   AND cam.primary_resource = pcrd.resources '
                   ||'   AND acrd.organization_id = pcrd.organization_id '
                   ||'   AND cam.primary_resource = prod.primary_resource(+) '
                   ||'   AND cam.alternate_resource = prod.alternate_resource(+) '
                   ||'   AND acrd.delete_mark = 0  '
                   ||' ORDER BY pcrd.resource_id, '
                   ||' DECODE(cam.preference,NULL,cam.runtime_factor,cam.preference),'
                   ||'   prod.inventory_item_id ' ;

gmp_debug_message('statement_alt_resource - '|| statement_alt_resource);

     -- Retrive the Details of all the Alternate Resources.
     alt_rsrc_size := 1;
     OPEN cur_alt_resource FOR statement_alt_resource ;
     LOOP
         FETCH cur_alt_resource INTO rtg_alt_rsrc_tab(alt_rsrc_size);
         EXIT WHEN cur_alt_resource%NOTFOUND;
         alt_rsrc_size := alt_rsrc_size + 1;
     END LOOP;
     CLOSE cur_alt_resource;
     alt_rsrc_size := alt_rsrc_size -1 ;
     log_message('alternate resource size is = '|| to_char(alt_rsrc_size) );

    old_batch_id := -1;
    p := 1 ;
    FOR p IN 1..gprod_size LOOP  /* Batch loop starts */

    /* Multiply plan_qty with UOM conv factor. Factor will be 1 when the
    plan_qty and primary UOM is same. */
gmp_debug_message('Production  material loop - '|| p);
gmp_debug_message('Batch Id - '|| prod_tab(p).batch_id );

    prod_tab(p).qty := prod_tab(p).qty * prod_tab(p).uom_conv_factor;
    prod_tab(p).Minimum_Transfer_Qty := prod_tab(p).Minimum_Transfer_Qty * prod_tab(p).uom_conv_factor;
    /*Sowmya - As per the latest FDD changes - Modified as per Matt's review commet.
    The minimum tranfer qty should be passed in the primary uom*/

    IF old_batch_id <> prod_tab(p).batch_id THEN

      old_batch_id := prod_tab(p).batch_id;
      product_line := -1;
      opm_product_line := -1;
      prod_line_id := -1;

      /* create a logical number by combining the plant and batch number */
      order_no := prod_tab(p).plant_code || pdelimiter ||
                  prod_tab(p).batch_no;

      IF prod_tab(p).batch_type = 10 THEN
        order_no := 'F/'||order_no ;
      END IF;
gmp_debug_message('order_no - '|| order_no);
/* nsinghi INVCONV Start */
/* Commented out the code for org specific collections as Org Check is now
directly done in each cursors. */

      v_orgn_id := prod_tab(p).mtl_org_id;
  /*
      IF prod_tab(p).plant_code = prod_plant THEN
         IF (res_whse) THEN
           v_orgn_id := res_whse_id;
         ELSE
           v_orgn_id := prod_tab(p).mtl_org_id;
         END IF;
      ELSE
        prod_plant := prod_tab(p).plant_code;
        v_sql_stmt :=
             'SELECT '
          || ' iwm.mtl_organization_id '
          || 'FROM '
          || '  sy_orgn_mst' ||pdblink|| ' sy, '
          || '  ic_whse_mst' ||pdblink|| ' iwm '
          || 'WHERE '
          || '  sy.orgn_code = :p1'
          || '  AND sy.resource_whse_code = iwm.whse_code';

        IF gmp_calendar_pkg.g_in_str_org  IS NOT NULL THEN
        v_sql_stmt := v_sql_stmt
          ||'   AND iwm.mtl_organization_id ' || gmp_calendar_pkg.g_in_str_org ;
        END IF;

        OPEN rsrc_whse FOR v_sql_stmt USING prod_tab(p).plant_code;
        FETCH rsrc_whse INTO res_whse_id;
          IF rsrc_whse%NOTFOUND THEN
            v_orgn_id := prod_tab(p).mtl_org_id;
            res_whse := FALSE;
          ELSE
            v_orgn_id := res_whse_id;
            res_whse := TRUE;
          END IF;
        CLOSE rsrc_whse;

      END IF;  */ /* for Plant code */
/* nsinghi INVCONV End */

    END IF;   /* Batch Changes */

    IF ( prod_tab(p).matl_item_id = prod_tab(p).recipe_item_id) AND (product_line = -1) THEN
/* nsinghi INVCONV Start */
/*      product_line := prod_tab(p).item_id;  *//* Product */
      product_line := prod_tab(p).matl_item_id;  /* Product */
      opm_product_line := prod_tab(p).recipe_item_id;  /* opm_Product */
/* nsinghi INVCONV End */

      prod_line_id := prod_tab(p).line_id;
      old_step_no := -1;
      i := 1;

/*Sowmya - Doubt - res_whse will be false when it enters this loop. Do we need to hav e res_whse??*/
      IF prod_tab(p).routing_id IS NOT NULL AND NVL(prod_tab(p).poc_ind, 'N') = 'Y' THEN -- AND
--         (res_whse) THEN
        -- log_message( ' Entry --  ' || g_rsrc_cnt );
        r := 1 ;
        resource_usage_flag := 0 ;
        resource_instance_usage_flag := 0 ;
        old_rsrc_batch_id :=  -999;
        old_rsrc_resources :=  -999;
        old_rsrc_original_seq_num := -999;
        old_instance_number :=  -999;
        old_rsrc_inst_batch_id := -999;
        old_rsrc_inst_resources := -999;
        old_rsrc_inst_original_seq_num := -999;

        FOR r IN g_rsrc_cnt..grsrc_size LOOP   /* Resource Cursor */
gmp_debug_message('Resource Loop  - '|| r);
           /* ------------- Navin: START Process Resource Requirements ------------- */
           IF old_rsrc_batch_id <> rsrc_tab(r).batch_id
              OR old_rsrc_resources <> rsrc_tab(r).resources
              OR old_rsrc_original_seq_num <> rsrc_tab(r).original_seq_num THEN
                -- Reset the flags.
                resource_usage_flag := 0 ;
           END IF;

           IF rsrc_tab(r).resource_usage > 0 AND resource_usage_flag = 0 THEN
             -- Process and insert the very first resource record
             resource_usage_flag := 1 ;
             -- Populate flags
             old_rsrc_batch_id := rsrc_tab(r).batch_id ;
             old_rsrc_resources := rsrc_tab(r).resources ;
             old_rsrc_original_seq_num := rsrc_tab(r).original_seq_num ;

            /*Sowmya - As per the latest FDD changes - process this resource only
            if the class type of this is same as the one defined in profile*/
            l_res_inst_process := 1;

             IF  prod_tab(p).batch_id > rsrc_tab(r).batch_id THEN --- MAIN IF
               NULL ;
             ELSIF  prod_tab(p).batch_id < rsrc_tab(r).batch_id THEN
               g_rsrc_cnt := r ;
               /* Initialize for the change of batch */
               v_resource_usage := 0;
               v_res_seq        := 0;
               v_schedule_flag  := 0;
               v_parent_seq_num := 0;
               v_rsrc_cnt       := 0;
               v_start_date     := NULL;
               v_end_date       := NULL;
               old_activity     := 0;
               V_ACTIVITY_GROUP_ID  := 0;  /* B3995361 rpatangy */
               v_seq_dep_usage  := 0;
               found_chrg_rsrc := 0;
               chrg_activity   := -1;

               EXIT;
             ELSIF  prod_tab(p).batch_id =  rsrc_tab(r).batch_id THEN
               IF old_step_no <> rsrc_tab(r).batchstep_no THEN /* Step change */
                 v_res_seq        := 0;
                 old_activity     := -1;
                 v_resource_usage := 0;
                 v_res_seq        := 0;
                 v_schedule_flag  := 0;
                 v_parent_seq_num := 0;
                 v_rsrc_cnt       := 0;
                 v_start_date     := NULL;
                 v_end_date       := NULL;
                 V_ACTIVITY_GROUP_ID  := 0;  /* B3995361 rpatangy */
                 v_seq_dep_usage  := 0;
                 found_chrg_rsrc := 0;
                 chrg_activity   := -1;
               /* nsinghi APSK - Insert Step related information in msc_st_job_operations
                  every time step changes. */

                 jo_index := jo_index + 1;
                 jo_wip_entity_id(jo_index) := rsrc_tab(r).x_batch_id;
                 jo_instance_id(jo_index) := pinstance_id;
                 jo_operation_seq_num(jo_index) := rsrc_tab(r).batchstep_no;
                 jo_recommended(jo_index) := 'Y';
                 jo_network_start_end(jo_index) := null_value;
                 jo_reco_start_date(jo_index) := rsrc_tab(r).step_start_date;
                 jo_reco_completion_date(jo_index) := rsrc_tab(r).step_end_date;
                 jo_operation_sequence_id(jo_index) := rsrc_tab(r).batchstep_id;
                 jo_organization_id(jo_index) := v_orgn_id;
                 jo_department_id(jo_index) := ((v_orgn_id*2) + 1);

		 /* Bug:6407939 -KBANDDYO  assignement changed from prod_tab to rsrc_tab  */
                 -- jo_minimum_transfer_quantity(jo_index) := prod_tab(p).minimum_transfer_qty;
                 jo_minimum_transfer_quantity(jo_index) := rsrc_tab(r).min_xfer_qty ;

               END IF;   /* Step change */

               IF rsrc_tab(r).seq_dep_ind <> -1 THEN /* NAVIN :- Process Rows only if
                                           Sequence Dependent is not -1 */

                 IF (old_activity <> rsrc_tab(r).bs_activity_id) OR (old_activity = -1) THEN
                   v_res_seq := v_res_seq + 1;
                   old_activity := rsrc_tab(r).bs_activity_id;

                   /* B3421856, If materail indicator activity then previous = 3, Next = 4 */
                   IF rsrc_tab(r).mat_found > 0 THEN

                     IF rsrc_tab(r).material_ind = 1 THEN
                         v_schedule_flag := 4;
                     ELSE
                       IF v_schedule_flag < 4 THEN
                          v_schedule_flag := 3 ;
                       END IF ;
                     END IF;   /* Material Indicator */
                   END IF;  /* Mat_found */
                 END IF;   /* old_activity */

                 IF (rsrc_tab(r).material_ind = 0) AND  (rsrc_tab(r).mat_found > 0) THEN
                   rsrc_tab(r).schedule_flag := v_schedule_flag;
                 END IF;

                 IF NVL(rsrc_tab(r).actual_cmplt_date,v_null_date) = v_null_date THEN
                   /* when the actual start is null the resource has not started
                      and the plan start will be used.  */

                   /* bug: 6713691 vpedarla - made changes to add the partial
                      resource transaction back to the resource usage
                      which will be cut-off during the ODS LOAD(APS) */
                   IF  rsrc_tab(r).actual_start_date is not null and
                       rsrc_tab(r).actual_cmplt_date is null THEN
                        rsrc_tab(r).resource_usage := rsrc_tab(r).resource_usage
                                                      + rsrc_tab(r).actual_rsrc_usage ;
                   END IF;

                  -- Bug: 8647592 Vpedarla
                    IF ( l_gmp_um_code <>  rsrc_tab(r).usage_uom  ) THEN
	            	    uom_conv_cursor := 'SELECT '
                        ||'  inv_convert.inv_um_convert'||pdblink
	                    ||'  (:pitem, '
		                ||'   NULL, '
		                ||'   :orgid, '
                        ||'    5  , '
	                    ||'   :pqty, '
	            	    ||'   :pfrom_um, '
	            	    ||'   :pto_um , '
	            	    ||'   NULL , '
	            	    ||'   NULL '
	            	    ||'   ) '
	            	    ||'   FROM dual';
                        v_new_res_usage := -1;
                        OPEN c_uom_conv FOR uom_conv_cursor USING
                           product_line,
                           v_orgn_id, --sowmya added.
                           rsrc_tab(r).resource_usage,
                           rsrc_tab(r).usage_uom ,
                           l_gmp_um_code;

                       FETCH c_uom_conv INTO v_new_res_usage;
                       CLOSE c_uom_conv;
                     IF v_new_res_usage > 0 THEN
                       rsrc_tab(r).resource_usage := v_new_res_usage ;
                     END IF;
                   END IF;
                  -- Bug: 8647592 end

                   IF rsrc_tab(r).tran_seq_dep = 1 THEN
                     v_parent_seq_num := v_res_seq;
                     v_resource_usage := rsrc_tab(r).resource_usage;
                     v_start_date := rsrc_tab(r).act_start_date;
                     v_end_date := rsrc_tab(r).plan_start_date;
                     /* NAVIN :- added Sequence Dependency */
                     v_seq_dep_usage := rsrc_tab(r).sequence_dependent_usage;
                   ELSE
                     v_seq_dep_usage  := 0;
                     v_parent_seq_num := TO_NUMBER(NULL);
                     v_start_date := rsrc_tab(r).plan_start_date;
                     v_end_date := rsrc_tab(r).plan_cmplt_date;
                     IF v_inflate_wip = 1 THEN
                       v_resource_usage := rsrc_tab(r).resource_usage / rsrc_tab(r).utl_eff;
                     ELSE
                       v_resource_usage := rsrc_tab(r).resource_usage;
                     END IF;
                   END IF;   /* tran_seq_ind */

                   /*Sowmya - As per the latest FDD changes - Start*/
                   /*For a Pending batch if the original resoucre count is less than the plan
                   resource count then pass pln resource count otherwise the original resource
                   count is passed*/
                   IF rsrc_tab(r).org_step_status = 1 THEN
        /* B4349002 Resource Count is same as Plan resource count */
                                v_max_rsrcs := rsrc_tab(r).gmd_rsrc_count;
                   ELSIF rsrc_tab(r).org_step_status = 2 THEN
                        IF rsrc_tab(r).actual_rsrc_count IS NULL THEN
                                v_max_rsrcs := rsrc_tab(r).plan_rsrc_count;
                        ELSE
                                v_max_rsrcs := rsrc_tab(r).actual_rsrc_count;
                        END IF;
                   END IF;
                   /*Sowmya - As per the latest FDD changes - End*/

                   /* If no actual resource exists then the resource has not
                      started and the planned value will be used */
                   IF rsrc_tab(r).actual_rsrc_count IS NULL THEN
                     v_rsrc_cnt := rsrc_tab(r).plan_rsrc_count;
                   ELSE
                     v_rsrc_cnt := rsrc_tab(r).actual_rsrc_count;
                   END IF;

                  /* write the current resource detail row asscoiating it with the
                    batch through the product line */

                  /* NAVIN :- If there are more than 1 activities in a step having
                   chargeable resources and scale_type = 3 and scheduled, then
                   change scale_type for all activities after the 1st is changed
                   to linear  */

                   IF rsrc_tab(r).mat_found = 0 OR rsrc_tab(r).material_ind = 1 THEN
                     IF rsrc_tab(r).scale_type = 3 -- APS decoded value as per DECODE(rsrc_tab(r).scale_type,0,2,1,1,2,3);
                     AND rsrc_tab(r).capacity_constraint = 1
                     AND found_chrg_rsrc = 0 THEN
                           found_chrg_rsrc := 1;
                           chrg_activity := rsrc_tab(r).bs_activity_id;
                           /* if the rtg_scale_type is 3 but another activity was found
                           with 2 then this row will be assigned scale_type = 1. */
                     ELSIF rsrc_tab(r).scale_type = 3
                     AND rsrc_tab(r).capacity_constraint = 1
                     AND found_chrg_rsrc = 1
                     AND chrg_activity <> rsrc_tab(r).bs_activity_id THEN
                           rsrc_tab(r).scale_type := 1;
                     END IF;
                   END IF;

                   IF rsrc_tab(r).scale_type = 3 AND found_chrg_rsrc = 1 THEN   -- APS decoded value as per DECODE(rsrc_tab(r).scale_type,0,2,1,1,2,3);
                   /* NAVIN: END Operation Charges Data needs to be transferred
                   to APS  in to Msc_st_resource_charges */
                      IF rsrc_tab(r).org_step_status = 2 THEN
                         l_charges_remaining := CEIL(((rsrc_tab(r).plan_rsrc_usage -
                             rsrc_tab(r).actual_rsrc_usage) * rsrc_tab(r).plan_charges) /
                             rsrc_tab(r).plan_rsrc_usage);
-- HW B4761811- Calculate the remaining charged
                      ELSE
                        l_charges_remaining := rsrc_tab(r).plan_charges ;

                      END IF;

                      IF rsrc_tab(r).org_step_status = 1 OR (l_charges_remaining > 0 AND rsrc_tab(r).org_step_status = 2) THEN
                      /* Batch step status is pending OR there are some remaining charges for a WIP batch */

                         inst_stp_chg_tbl(pinstance_id, r);
                      END IF;
                   END IF ;

                   /* B3995361 rpatangy start */
                   IF rsrc_tab(r).prim_rsrc_ind = 1 THEN
                    v_activity_group_id := rsrc_tab(r).x_resource_id ;
                   END IF;
                   /* B3995361 rpatangy end */

                   IF v_resource_usage > 0 THEN

                     /* Bulk Insert for insert_resource_requirements */
                       rr_index := rr_index + 1 ;
                       rr_organization_id(rr_index) := v_orgn_id ;
                       rr_sr_instance_id(rr_index) := pinstance_id ;
                       rr_supply_id(rr_index) :=  rsrc_tab(r).x_batch_id ; /* B1177070 encoded key */
                       rr_resource_seq_num(rr_index) := rsrc_tab(r).seq_dep_ind ;
                       rr_resource_id(rr_index) := rsrc_tab(r).x_resource_id ; /* B1177070 encoded key */
                       rr_start_date(rr_index) := v_start_date ;
                       rr_end_date(rr_index)  :=  v_end_date ;
                       rr_opr_hours_required(rr_index) :=  v_resource_usage  ;
                       /* Bug 4431718 populate usage_rate column */
		    IF rsrc_tab(r).scale_type = 1 THEN /*linearly scaled */
			IF rsrc_tab(r).plan_step_qty > 0 THEN
			rr_usage_rate(rr_index) :=
			v_resource_usage / rsrc_tab(r).plan_step_qty ;
			ELSE
			rr_usage_rate(rr_index) :=  v_resource_usage ;
			END IF ;
		    ELSIF rsrc_tab(r).scale_type = 2 THEN /*fix scaled*/
			rr_usage_rate(rr_index) := v_resource_usage ;
		    ELSIF rsrc_tab(r).scale_type = 3 THEN /* Charge Scaled */
			IF l_charges_remaining > 0 THEN
			rr_usage_rate(rr_index) :=
				v_resource_usage /l_charges_remaining ;
			ELSE
			rr_usage_rate(rr_index) := v_resource_usage ;
			END IF ;
		    END IF ;
                       rr_assigned_units(rr_index) := v_rsrc_cnt ;
                       rr_department_id(rr_index) := ((v_orgn_id * 2) + 1) ;  /* B1177070 encoded key */
                       rr_wip_entity_id(rr_index) :=  rsrc_tab(r).x_batch_id ; /* B1177070 encoded key */
                       /* B1224660 write the step number for oper seq num */
                       rr_operation_seq_num(rr_index)  :=   rsrc_tab(r).batchstep_no ;
                      /* B3995361 */
/* Bug 6739913 OPM BATCHES IN WIP STATE HAVE INCORRECT FIRM FLAG VALUE.
1. Discrete/OSFM models- when the operation is in running state, running_qty > 0
    and firm flag is 2. This looks good in PS as well.
2. OSFM models - when the operation is in WIP state, running_qty is NULL and
firm flag is 7. Looks like OPM collections are populating the value 7 in ODS.
If this is the case, PS can read the firm flag value of 7 and display the wip
operations as ACTIVE for opm models. Teva asked for such a requirement as
well for Version 1.
This is because you were directly interacting with HLS team. They see the firm_flag
as 7 as the MBP module will convert the 1 sent by discrete as 7 to them. So,
ideally OPM should be sending us 1 and MBP will convert this as 7 before
giving it to HLS.
*/
                       IF rsrc_tab(r).step_status = 2 THEN
                       /* vpedarla Bug: 6739913 made firm_type flag to be 1 when the
                          step status is WIP */
                          rr_firm_flag(rr_index) :=   1 ;
                      --  rr_firm_flag(rr_index) :=   7 ;
                       ELSE
                          rr_firm_flag(rr_index) :=    rsrc_tab(r).firm_type ;
                       END IF;
                       rr_minimum_transfer_quantity(rr_index) := 0 ;
                       rr_parent_seq_num(rr_index) := TO_NUMBER(NULL) ;
                       rr_schedule_flag(rr_index) := rsrc_tab(r).schedule_flag ;
                       /* NAVIN :- start */
                       rr_sequence_id(rr_index) := rsrc_tab(r).group_sequence_id ;
                       rr_sequence_number(rr_index) := rsrc_tab(r).group_sequence_number ;
                       rr_firm_type(rr_index) := rsrc_tab(r).firm_type ;
                       rr_setup_id(rr_index) := rsrc_tab(r).setup_id ;
                       rr_original_seq_num (rr_index) := rsrc_tab(r).original_seq_num;
                       rr_min_capacity(rr_index) := rsrc_tab(r).minimum_capacity;
                       rr_max_capacity(rr_index)  := rsrc_tab(r).maximum_capacity;
                       rr_alternate_number(rr_index) := 0 ;
                       rr_basis_type(rr_index) := rsrc_tab(r).scale_type;
                       rr_hours_expended(rr_index) := rsrc_tab(r).actual_rsrc_usage;
                       rr_breakable_activity_flag(rr_index) := rsrc_tab(r).breakable_activity_flag;
                       /*B4777532 - sowsubra - the product item id should be populated
                       used the product_line which is populated with the product id, everytime for
                       a new batch.*/
                       rr_product_item_id(rr_index) := product_line ;

                       /* Sowmya - As per the latest FDD changes - Start */
                       rr_plan_step_qty(rr_index) := rsrc_tab(r).plan_step_qty ;
                       rr_step_qty_uom(rr_index) := rsrc_tab(r).step_qty_uom ;
                       rr_gmd_rsrc_cnt(rr_index) := v_max_rsrcs;
                       /* Sowmya - As per the latest FDD changes - End */
                       /* B3995361 rpatangy */
                       rr_activity_group_id(rr_index) := v_activity_group_id ;
                       /* B5338598 rpatangy starts */
                    --   rr_activity_name(rr_index)  := rsrc_tab(r).activity ;
                    --   rr_operation_no(rr_index) :=  rsrc_tab(r).operation_no ;
                       /* B5338598 rpatangy Ends */
		       rr_operation_sequence_id(rr_index) := rsrc_tab(r).batchstep_id ; /* B5461922 rpatangy */

                       /*B4320561 - sowsubra - start*/
                       rr_unadjusted_resource_hrs(rr_index) := rsrc_tab(r).resource_usage ;
                       rr_touch_time(rr_index) := rr_unadjusted_resource_hrs(rr_index)/ rsrc_tab(r).efficiency ;
                       /*B4320561 - sowsubra - end*/

                       /* NAVIN :- START - Logic To Handle Alternate Resources */
                       /*
                           Now check if the above resource inserted is a Primary. If it is
                           Primary then find its Alternates if existing, and then insert its rows
                           into msc_st_operation_resources table. Also keep track of number of
                           times alternates are inserted.
                       */

                       IF rsrc_tab(r).prim_rsrc_ind = 1 THEN
                         ---------------------------------------------------------------------
                         -- Use Bsearch technique to identify if any Alternate exists for the primary.
                         -- Enh_bsearch_alternate_rsrc is a new procedure to locate the Alternate Resource
                         -- for a given Primary resource in the PL/SQl table.
                         ---------------------------------------------------------------------
                         alternate_rsrc_loc := Enh_bsearch_alternate_rsrc (rsrc_tab(r).resource_id);
                         v_alternate  := 0;

                         IF alternate_rsrc_loc > 0 THEN  /* Alternate resource location */
                         /*Sowmya - As per latest FDD changes - Included chks that determine
                         when the alternate resources will be passed */
                            IF prod_tab(p).firmed_ind <> 1 THEN /* Batch firm chk */
                            /*If batch not firmed then pass on the alternate resource data*/
                                IF rsrc_tab(r).org_step_status <> 2 THEN /* Batch Step not in WIP */
                                /*Pass on the alternate resource data when the batch step is not in
                                WIP status*/
                                IF ( rsrc_tab(r).firm_type <> 3 ) AND ( rsrc_tab(r).firm_type <> 5 )
                                 AND ( rsrc_tab(r).firm_type <> 6 ) AND ( rsrc_tab(r).firm_type <> 7 ) THEN
                                 /* Batch resources not firmed */
                                 /*0 - UnFrim ,         1 - Firm Start Date ,
                                   2 - Firm End Date ,  3 - Firm Resource  ,
                                   4 - Firm Start Date and End Date ,
                                   5 - Firm Start Date and Resource ,
                                   6 - Firm End Date and Resource ,
                                   7 - Firm All*/
                                        alt_cnt := 1 ;
                                        --  Loop through the Alternate resources for the Primary Resource
                                        /*Sowmya - As per the latest FDD changes - Start */
                                        FOR alt_cnt IN alternate_rsrc_loc..alt_rsrc_size
                                        LOOP
     /* B5688153, Rajesh Patangya prod spec alt*/
                                       IF ( rtg_alt_rsrc_tab(alt_cnt).prim_resource_id =
                                            rsrc_tab(r).resource_id
                                       AND (rtg_alt_rsrc_tab(alt_cnt).inventory_item_id = -1 OR
                                            rtg_alt_rsrc_tab(alt_cnt).inventory_item_id =
                                            opm_product_line )) THEN

   --   IF ( rtg_alt_rsrc_tab(alt_cnt).prim_resource_id = rsrc_tab(r).resource_id ) THEN
                                              v_alternate := v_alternate + 1;
                                              /* Bulk Insert for Alternate_resource_requirements */

                                              arr_index := arr_index + 1 ;
                                              arr_organization_id(arr_index) := v_orgn_id ;
                                              arr_sr_instance_id(arr_index) := pinstance_id;
                                              arr_res_seq_num(arr_index) := rsrc_tab(r).original_seq_num ;
                                              arr_assigned_units(arr_index) := v_rsrc_cnt ;
                                              arr_department_id(arr_index) :=
                                                                  ((v_orgn_id * 2) + 1) ;

                                              arr_wip_entity_id(arr_index) :=
                                                                  rsrc_tab(r).x_batch_id ;
                                              /* B1224660 write the step number for oper
                                                  seq num */
                                              arr_operation_seq_num(arr_index) :=
                                                             rsrc_tab(r).batchstep_no ;
                                              arr_setup_id(arr_index) :=
                                                             rsrc_tab(r).setup_id ;
                                              arr_schedule_seq_num(arr_index) :=
                                                             rsrc_tab(r).seq_dep_ind;
                                              arr_maximum_assigned_units(arr_index) :=
                                                             v_max_rsrcs;
                                              arr_activity_group_id(arr_index) :=
                                     ((rtg_alt_rsrc_tab(alt_cnt).alt_resource_id * 2) + 1);
                                              arr_basis_type(arr_index):=
                                                             rsrc_tab(r).scale_type;
                                              arr_resource_id(arr_index) :=
                                     ((rtg_alt_rsrc_tab(alt_cnt).alt_resource_id * 2) + 1) ;

                                     -- BUg: 8393507 Vpedarla  Modified the below code as mentioned below. Divide resource usage by step qty simillar to primary resource.
                                         --     arr_usage_rate(arr_index) := v_resource_usage * rtg_alt_rsrc_tab(alt_cnt).runtime_factor;
                                         arr_usage_rate(arr_index) := rr_usage_rate(rr_index) * rtg_alt_rsrc_tab(alt_cnt).runtime_factor;
                                              arr_alternate_num(arr_index) := v_alternate ;
                                              arr_uom_code(arr_index) :=
                                                             rsrc_tab(r).usage_uom;
                --                            arr_gmd_rsrc_cnt(rr_index) := v_max_rsrcs;
                                            ELSIF ( rtg_alt_rsrc_tab(alt_cnt).prim_resource_id > rsrc_tab(r).resource_id ) THEN
                                                EXIT ;
                                            END IF;  /* End if for alternate resource and orgn code match */
                                        END LOOP;  /* Alternate loop */
                                END IF; /* Batch resources not firmed */
                                END IF;/* Batch Step not in WIP */
                           ELSE
                              gmp_debug_message(' batch firmed - No alternate resources loaded ');
                           END IF; /* Batch firm chk */
                         END IF ; /* Alternate resource location */
                       END IF;  /* rsrc_tab(r).prim_rsrc_ind = 1 */

                       /* NAVIN:
                       Below logic is to create the resource group pattern with different
                       values of Alternate_Number. Variable v_alternate holds the count of
                       alternate resources that has been inserted for the Primary resource
                       of the group. Now insert all the resource records other than primary
                       with a value of Alternate_Number from 1 to v_alternate, to complete
                       the pattern of resource group.
                       NAVIN: */

                       IF rsrc_tab(r).prim_rsrc_ind <> 1 AND v_alternate > 0 THEN
                       /* B3995361 rpatangy  start */
                         mk_alt_grp := 0 ;
                         FOR alt_cnt IN alternate_rsrc_loc..alt_rsrc_size
                          LOOP
                          IF rtg_alt_rsrc_tab(alt_cnt).prim_resource_id =
                              ((v_activity_group_id - 1)/2) THEN
                           arr_index := arr_index + 1 ;
                           mk_alt_grp := mk_alt_grp + 1 ;
                           arr_organization_id(arr_index) := v_orgn_id ;
                           arr_sr_instance_id(arr_index) := pinstance_id ;
                           arr_res_seq_num(arr_index) := rsrc_tab(r).original_seq_num ;
                           arr_resource_id(arr_index) := rsrc_tab(r).x_resource_id ;
                           arr_assigned_units(arr_index) := v_rsrc_cnt ;
                           arr_department_id(arr_index) := ((v_orgn_id * 2) + 1) ;
                           arr_wip_entity_id(arr_index) :=  rsrc_tab(r).x_batch_id ;
                           arr_operation_seq_num(arr_index)  := rsrc_tab(r).batchstep_no ;
                           arr_setup_id(arr_index) := rsrc_tab(r).setup_id ;
                           arr_schedule_seq_num(arr_index) := rsrc_tab(r).seq_dep_ind;
                           arr_maximum_assigned_units(arr_index) := v_max_rsrcs;
                           arr_activity_group_id(arr_index) :=
                                   ((rtg_alt_rsrc_tab(alt_cnt).alt_resource_id * 2) + 1);
                           arr_basis_type(arr_index):= rsrc_tab(r).scale_type;
                           arr_usage_rate(arr_index) := rr_usage_rate(rr_index) ;
-- v_resource_usage ;
                           arr_alternate_num(arr_index) := mk_alt_grp ;
                           arr_uom_code(arr_index) := rsrc_tab(r).usage_uom;
                          ELSIF rtg_alt_rsrc_tab(alt_cnt).prim_resource_id >
                                ((v_activity_group_id - 1)/2) THEN
                             EXIT ;
                          END IF;  /* End if for alternate resource and orgn code match */
                         /* B3995361 rpatangy  End */
                         END LOOP;  /* mk_alt_grp loop */
                       END IF;  /* End if for Check in Primary Resource Indicator and  v_alternate > 0*/
                       /* NAVIN :- END - Logic To Handle Alternate Resources */

                       /* NAVIN :- Logic to Handle Additional row For Sequence Dependency Start */
                       IF v_seq_dep_usage > 0 THEN
                         rr_index := rr_index + 1 ;
                         rr_organization_id(rr_index) := v_orgn_id ;
                         rr_sr_instance_id(rr_index) := pinstance_id ;
                         rr_supply_id(rr_index) :=  rsrc_tab(r).x_batch_id ; /* B1177070 encoded key */
                         /* B1224660 new value to write resource seq num */
                         rr_resource_seq_num(rr_index) := rsrc_tab(r).seq_dep_ind ;
                         rr_resource_id(rr_index) := rsrc_tab(r).x_resource_id ; /* B1177070 encoded key */
                         rr_start_date(rr_index) := v_start_date ;
                         rr_end_date(rr_index)  :=  v_end_date ;
                         rr_opr_hours_required(rr_index) :=  rsrc_tab(r).sequence_dependent_usage;-- * converted_usage;
    /* B4637398, We will treat This extra usage row as fixed and provide
        the same reosurce usage in usage_rate column */
			 rr_usage_rate(rr_index) := v_resource_usage ;

                         /* Sowmya - As per the latest FDD changes - multiply the usage with the conveted factor */
                         rr_assigned_units(rr_index) := v_rsrc_cnt ;
                         rr_department_id(rr_index) := ((v_orgn_id * 2) + 1) ;  /* B1177070 encoded key */
                         rr_wip_entity_id(rr_index) :=  rsrc_tab(r).x_batch_id ; /* B1177070 encoded key */
                         /* B1224660 write the step number for oper seq num */
                         rr_operation_seq_num(rr_index)  :=   rsrc_tab(r).batchstep_no ;
			 rr_operation_sequence_id(rr_index) := rsrc_tab(r).batchstep_id ; /* B5461922 rpatangy */
                         rr_firm_flag(rr_index) :=    rsrc_tab(r).firm_type ;
                         rr_minimum_transfer_quantity(rr_index) := 0 ;
                         rr_parent_seq_num(rr_index) := rsrc_tab(r).original_seq_num;
                         rr_schedule_flag(rr_index) := rsrc_tab(r).schedule_flag ;
                         rr_sequence_id(rr_index) := rsrc_tab(r).group_sequence_id ;
                         rr_sequence_number(rr_index) := rsrc_tab(r).group_sequence_number ;
                         rr_firm_type(rr_index) := rsrc_tab(r).firm_type ;
                         rr_setup_id(rr_index) := rsrc_tab(r).setup_id ;
                         rr_original_seq_num (rr_index) := TO_NUMBER(NULL) ;
                         rr_min_capacity(rr_index) := rsrc_tab(r).minimum_capacity;
                         rr_max_capacity(rr_index)  := rsrc_tab(r).maximum_capacity;
                         rr_alternate_number(rr_index) := 0 ;
                         rr_basis_type(rr_index) := rsrc_tab(r).scale_type;           -- Added 7/14/2004
                         rr_hours_expended(rr_index) := rsrc_tab(r).actual_rsrc_usage;
                         rr_breakable_activity_flag(rr_index) := rsrc_tab(r).breakable_activity_flag;
                         /*B4777532 - sowsubra - the product item id should be populated
                         used the product_line which is populated with the product id, everytime for
                         a new batch.*/
                         rr_product_item_id(rr_index) := product_line ;

                         /* Sowmya - As per the latest FDD changes - Start */
                         rr_plan_step_qty(rr_index) := rsrc_tab(r).plan_step_qty ;
                         rr_step_qty_uom(rr_index) := rsrc_tab(r).step_qty_uom ;
                         rr_gmd_rsrc_cnt(rr_index) := v_max_rsrcs;
                         /* Sowmya - As per the latest FDD changes - End */

                         /* B3995361 rpatangy */
                       rr_activity_group_id(rr_index) := v_activity_group_id ;

                       /*B4320561 - sowsubra - start*/
                       rr_unadjusted_resource_hrs(rr_index) := rsrc_tab(r).resource_usage ;
                       rr_touch_time(rr_index) := rr_unadjusted_resource_hrs(rr_index)/ rsrc_tab(r).efficiency ;
                       /*B4320561 - sowsubra - end*/

                         gmp_debug_message('Resource '|| rr_resource_id(rr_index) ||' resource_count hours '||rr_opr_hours_required(rr_index));

                       END IF;
                   END IF;   /* resource usage */  -- v_resource_usage > 0
                 END IF;   /* actual completion date */ -- NVL(rsrc_tab(r).actual_cmplt_date,v_null_date) = v_null_date
               END IF; /* NAVIN :- End If condition for seq_dep_ind <> -1 */ -- rsrc_tab(r).seq_dep_ind <> -1

               old_step_no := rsrc_tab(r).batchstep_no;
             END IF ;   /* entry/Exit Logic */  --- MAIN IF

           END IF; /* rsrc_tab(r).resource_usage > 0 AND resource_usage_flag = 0 */

           /* ------------- Navin: END Process Resource Requirements ------------- */

           /* ------------- Navin: START Process Resource Instances Requirements ------------- */
           IF rsrc_tab(r).instance_number <> -1 THEN
             IF old_rsrc_inst_batch_id <> rsrc_tab(r).batch_id
                OR old_rsrc_inst_resources <> rsrc_tab(r).resources
                OR old_rsrc_inst_original_seq_num <> rsrc_tab(r).original_seq_num
                OR old_instance_number <> rsrc_tab(r).instance_number THEN
                  -- Reset the flags.
                  resource_instance_usage_flag := 0 ;
             END IF;

             IF rsrc_tab(r).resource_instance_usage > 0 AND resource_instance_usage_flag = 0  AND l_res_inst_process = 1 THEN
                  -- Process and insert the very first resource_instance_usage record
                  resource_instance_usage_flag := 1 ;

                  /* Sowmya - As per the latest FDD changes - Reinitialise the variable*/
                  l_res_inst_process := 0 ;

                  -- Populate flags
                  old_rsrc_inst_batch_id := rsrc_tab(r).batch_id ;
                  old_rsrc_inst_resources := rsrc_tab(r).resources ;
                  old_rsrc_inst_original_seq_num := rsrc_tab(r).original_seq_num ;
                  old_instance_number := rsrc_tab(r).instance_number;

                  -- Insert the very first resource_instance_usage record
                  inst_indx := inst_indx + 1 ;
                  rec_inst_supply_id(inst_indx) := rsrc_tab(r).x_batch_id ;
                  rec_inst_organization_id(inst_indx) := v_orgn_id ;
                  rec_inst_sr_instance_id(inst_indx) := pinstance_id ;
                  rec_inst_rec_resource_seq_num(inst_indx) := rsrc_tab(r).seq_dep_ind ;
                  rec_inst_resource_id(inst_indx) := rsrc_tab(r).x_resource_id ;
                  rec_inst_instance_id(inst_indx) := rsrc_tab(r).instance_number ;
                  rec_inst_start_date(inst_indx) := v_start_date ;
                  rec_inst_end_date(inst_indx)  :=  v_end_date ;
                  rec_inst_rsrc_instance_hours(inst_indx) := rsrc_tab(r).resource_instance_usage;-- * converted_usage;
                  /* Sowmya - As per the latest FDD changes - multiply the usage with the conveted factor */
                  rec_inst_operation_seq_num(inst_indx) := rsrc_tab(r).batchstep_no ;
                  rec_inst_department_id(inst_indx) := ((v_orgn_id * 2) + 1) ;
                  rec_inst_wip_entity_id(inst_indx) :=  rsrc_tab(r).x_batch_id ;
                  rec_inst_serial_number(inst_indx)  :=   rsrc_tab(r).eqp_serial_number ;
                  rec_inst_original_seq_num(inst_indx)  :=   rsrc_tab(r).original_seq_num ;
                  rec_inst_parent_seq_num(inst_indx) := TO_NUMBER(NULL) ;
                  rec_inst_equp_item_id(inst_indx) := rsrc_tab(r).equp_item_id;
                  /*Sowmya - As per the latest FDD changes - Resource Instances */

                  IF v_seq_dep_usage > 0 THEN
                    /* Bulk Insert for insert_resource_requirements */
                    inst_indx := inst_indx + 1 ;

                    rec_inst_supply_id(inst_indx) := rsrc_tab(r).x_batch_id ;
                    rec_inst_organization_id(inst_indx) := v_orgn_id ;
                    rec_inst_sr_instance_id(inst_indx) := pinstance_id ;
                    rec_inst_rec_resource_seq_num(inst_indx) := rsrc_tab(r).seq_dep_ind ;
                    rec_inst_resource_id(inst_indx) := rsrc_tab(r).x_resource_id ;
                    rec_inst_instance_id(inst_indx) := rsrc_tab(r).instance_number ;
                    rec_inst_start_date(inst_indx) := v_start_date ;
                    rec_inst_end_date(inst_indx)  :=  v_end_date ;
                    /* NAVIN: Divide the seq dep usage equally amongst the instances. */
                    rec_inst_rsrc_instance_hours(inst_indx) := rsrc_tab(r).sequence_dependent_usage;-- * converted_usage;
                    /* Sowmya - As per the latest FDD changes - multiply the usage with the conveted factor */
                    rec_inst_operation_seq_num(inst_indx) := rsrc_tab(r).batchstep_no ;
                    rec_inst_department_id(inst_indx) := ((v_orgn_id * 2) + 1) ;
                    rec_inst_wip_entity_id(inst_indx) :=  rsrc_tab(r).x_batch_id ;
                    rec_inst_serial_number(inst_indx)  :=   rsrc_tab(r).eqp_serial_number ;
                    rec_inst_original_seq_num(inst_indx)  :=  TO_NUMBER(NULL) ;
                    rec_inst_parent_seq_num(inst_indx) := rsrc_tab(r).original_seq_num;
                    rec_inst_equp_item_id(inst_indx) := rsrc_tab(r).equp_item_id;
                    /*Sowmya - As per the latest FDD changes - Resource Instances */

                  END IF; /* Sequence Dependency Row */
             END IF; /* rsrc_tab(r).resource_instance_usage > 0 AND resource_instance_usage_flag = 0 */
           END IF; /* rsrc_tab(r).instance_number <> -1 */
           /* ------------- Navin: END Process Resource Instances Requirements ------------- */

       END LOOP;   /* Resource Cursor */


      END IF;   /* Routing_id is not null */
   END IF;  /* item should be product */

        IF prod_tab(p).line_id = prod_line_id THEN
          supply_type := 3;    /* Product */
        ELSE
          supply_type := 14;   /* Co Product or a by-Product */
        END IF;

        /* ingredient get written to the demands. the quantity needs to be
           positive so we reverse it */
        IF prod_tab(p).line_type = -1 THEN
          IF prod_tab(p).batchstep_no = -1   /* 2919303 */
          THEN
              prod_tab(p).batchstep_no := TO_NUMBER(NULL);
          END IF;
    -- ----------------
    /*  B3267522, Rajesh Patangya Do not insert demands, if ingradient is same as product
        (single level circular reference) */

/* nsinghi INVCONV Start */
/*        IF prod_tab(p).item_id <> product_line THEN */
        IF prod_tab(p).matl_item_id <> product_line THEN
/* nsinghi INVCONV End */
           gmp_debug_message('Demand Item '|| prod_tab(p).matl_item_id ||' Qty '||prod_tab(p).qty);
             /* Demands Bulk inserts */
                d_index := d_index + 1 ;
                d_organization_id(d_index) := v_orgn_id ;

/* nsinghi INVCONV Start */
/*                d_inventory_item_id(d_index) :=  prod_tab(p).item_id ; */
                d_inventory_item_id(d_index) :=  prod_tab(p).matl_item_id ;
/* nsinghi INVCONV End */

                d_sr_instance_id(d_index) :=  pinstance_id ;
                d_assembly_item_id(d_index) := product_line ;
                d_demand_date(d_index) := prod_tab(p).trans_date ;
                /* Reverse sign to make positive */
                /*B4619070 - sowsura - With convergence ic_tran_pnd no longer exist and the ingredient
                demand quantity is picked from gme_material_details table. The ingredient qty as
                stored by GME is +ve. So we dont have to convert the qty into positive which
                was done pre-convergence.*/
--                d_requirement_quantity(d_index) := (prod_tab(p).qty * -1);
                d_requirement_quantity(d_index) := prod_tab(p).qty;
                d_demand_type(d_index) := 1 ;
                d_origination_type(d_index) := 3 ;
                 /* B1177070 encoded key */
                d_wip_entity_id(d_index) := prod_tab(p).x_batch_id ;
                d_demand_schedule(d_index) := null_value ;
                d_order_number(d_index)  := order_no ;
                d_wip_entity_name(d_index) := null_value ;
                d_operation_seq_num(d_index) := prod_tab(p).batchstep_no; /* B2919303 Batchstep */
                d_selling_price(d_index) := null_value ;

                /*B5100481 - sowsubra - WIP STATUS OF BATCHES NOT SHOWN*/
                IF prod_tab(p).batch_status = 1 THEN
                   d_wip_status_code(d_index) := 16 ; /* batch status -> pending */
                ELSE
                   d_wip_status_code(d_index) := 3 ; /* batch status -> WIP */
                END IF;

         END IF;    /* Circular reference   */
    -- ----------------

    /* If the line is a product or byproduct write to the supplies */
        ELSE
          IF prod_tab(p).batchstep_no = -1   /* 2919303 */
          THEN
              prod_tab(p).batchstep_no := TO_NUMBER(NULL);
          END IF;

           gmp_debug_message('Supply Item '|| prod_tab(p).matl_item_id ||' Qty '||prod_tab(p).qty);
           /* Supply Bulk Insert Assignments */
                s_index := s_index + 1 ;
/* nsinghi INVCONV Start */
/*                s_inventory_item_id(s_index) := prod_tab(p).item_id ; */
                s_inventory_item_id(s_index) := prod_tab(p).matl_item_id ;
/* nsinghi INVCONV End */
                s_organization_id(s_index)   := v_orgn_id ;
                s_sr_instance_id(s_index)    := pinstance_id;
                s_new_schedule_date(s_index) :=  prod_tab(p).trans_date ;
                s_old_schedule_date(s_index)       := prod_tab(p).trans_date ;

                -- Bug: 8624913
                IF prod_tab(p).actual_start_date IS NOT NULL THEN
                s_new_wip_start_date(s_index) := prod_tab(p).actual_start_date ;
		            s_actual_start_date(s_index) := prod_tab(p).actual_start_date ;
                ELSE
                s_new_wip_start_date(s_index) := prod_tab(p).start_date ;
		            s_actual_start_date(s_index)  := NULL ;
                END IF;

                s_old_wip_start_date(s_index) := prod_tab(p).start_date ;
                s_lunit_completion_date(s_index) := prod_tab(p).end_date ;
                /* B1177070 encoded key */
                s_disposition_id(s_index)    :=  prod_tab(p).x_batch_id ;

               /* B8349005 Vpedarla From ASCP planning perspective, we only need a
                   unique process_sequence_id in the msc_supplies (plan_id=-1, ODS data)
                   for WIP jobs. It is requirement from our new engine code, starting
                   from 11510 in other words for order_type 3,14.
               */
                s_process_seq_id(s_index) := l_process_seq_id + s_index ;

                /*B5100481 - sowsubra - WIP STATUS OF BATCHES NOT SHOWN*/
                IF prod_tab(p).batch_status = 1 THEN
                   s_wip_status_code(s_index) := 16 ; /* batch status -> pending */
                ELSE
                   s_wip_status_code(s_index) := 3 ; /* batch status -> WIP */
                END IF;

             IF supply_type IS NOT NULL THEN
                s_order_type(s_index)        := supply_type ;
             ELSE
                s_order_type(s_index)        := null_value ;
             END IF ;

             IF order_no IS NOT NULL THEN
                s_order_number(s_index)            := order_no ;
             ELSE
                s_order_number(s_index)        := null_value ;
             END IF ;

                -- Bug: 8614604 Vpedarla
                  IF prod_tab(p).qty < 0 THEN
                    prod_tab(p).qty := 0;
                  END IF;

                s_new_order_quantity(s_index) := prod_tab(p).qty ;
                s_old_order_quantity(s_index) := prod_tab(p).qty ;
                s_firm_planned_type(s_index)  := prod_tab(p).firmed_ind; /* 2821248 Firmed Indicator */
                s_firm_quantity(s_index)  := prod_tab(p).qty ; /* B2821248 Firmed Batches Qty  - */
                s_firm_date(s_index) := prod_tab(p).trans_date; /* B2821248 Firmed Batches Date - */

                s_requested_completion_date(s_index) := prod_tab(p).requested_completion_date; /* Navin : APS K Enh */
                s_schedule_priority(s_index) := prod_tab(p).schedule_priority; /* Navin : APS K Enh */

             IF order_no IS NOT NULL THEN
                s_wip_entity_name(s_index)        := order_no ;
             ELSE
                s_wip_entity_name(s_index)        := null_value ;
             END IF ;
                -- lot_number         := null_value ;
                -- expiration_date    := null_value ;
            s_operation_seq_num(s_index) := prod_tab(p).batchstep_no;  /* B2919303 Batchstep  */

            IF supply_type = 3 THEN
              s_by_product_using_assy_id(s_index) := to_number(NULL) ;
            ELSE
              s_by_product_using_assy_id(s_index) := product_line ;
            END IF;

            /* Section 11.1.1.2 MTQ with Hardlinks */
            IF (prod_tab(p).Minimum_Time_Offset IS NOT NULL) THEN
                  stp_var_itm_instance_id(si_index) := pinstance_id;
                  stp_var_itm_from_op_seq_id(si_index) := prod_tab(p).from_op_seq_id ;
                  stp_var_itm_wip_entity_id (si_index) := prod_tab(p).x_batch_id;
/* nsinghi INVCONV Start */
/*	          stp_var_itm_FROM_item_ID(si_index) := prod_tab(p).item_id; */
	          stp_var_itm_FROM_item_ID(si_index) := prod_tab(p).matl_item_id;
/* nsinghi INVCONV End */

	          stp_var_min_tran_qty(si_index) := prod_tab(p).Minimum_Transfer_Qty;
        	  stp_var_itm_min_tm_off(si_index) := prod_tab(p).Minimum_Time_Offset;
	          stp_var_itm_max_tm_off(si_index) := prod_tab(p).Maximum_Time_Offset;
                  stp_var_itm_from_op_seq_num(si_index) := prod_tab(p).from_op_seq_num;
                  stp_var_itm_organization_id(si_index)   := v_orgn_id ;
	          si_index := si_index+1;
            END IF;
    END IF;
  END LOOP;   /* all the details are retrieved so close the cursor */
  --close prod_dtl;
-- =====================================Inserts =======================
     i := 1 ;
     log_message(rr_organization_id.FIRST || ' *rr*' || rr_organization_id.LAST );
     IF rr_organization_id.FIRST > 0 THEN
     FORALL i IN rr_organization_id.FIRST..rr_organization_id.LAST
        INSERT INTO msc_st_resource_requirements (
		organization_id,
		sr_instance_id,
		supply_id,
		supply_type, /* kbanddyo B6407864 Need to populate supply_type field */
		resource_seq_num,
		resource_id,
		start_date,
		end_date,
		operation_hours_required,
                usage_rate, /* B4637398 Rajesh Patangya */
		assigned_units,
		department_id,
		wip_entity_id,
		operation_seq_num,
		deleted_flag,
		firm_flag,
		minimum_transfer_quantity,
		parent_seq_num,
		schedule_flag,
		basis_type,
		setup_id,
		group_sequence_id,
		group_sequence_number,
		minimum_capacity,
		maximum_capacity,
		orig_resource_seq_num,
		alternate_number,
                hours_expended,
                breakable_activity_flag,
                inventory_item_id,  /* B4777532 - product_item_id populated */
                step_quantity,    /* Sowmya - As per latest FDD changes*/
                step_quantity_uom , /* Sowmya - As per latest FDD changes*/
                maximum_assigned_units, /* Sowmya - As per latest FDD changes*/
                unadjusted_resource_hours, /*B4320561 - Same as in wip (without eff and util) */
                touch_time, /* B4320561 - Unadjusted res. hrs / efficiency.*/
                activity_group_id, /* B3995361 rpatangy */
          --      activity_name,  /* B5338598 rpatangy */
          --      operation_name,  /* B5338598 rpatangy */
		operation_sequence_id /* B5461922 rpatangy */
	     )
        VALUES (
		rr_organization_id(i),
		rr_sr_instance_id(i),
		rr_supply_id(i),
		 1,                    /* kbanddyo B6407864 supply_type = 1 for OPM batches*/
		rr_resource_seq_num(i),
		rr_resource_id(i),
		rr_start_date(i),
		rr_end_date(i),
		rr_opr_hours_required(i),
                nvl(rr_usage_rate(i),0), /* B4637398 Rajesh Patangya */
		rr_assigned_units(i),
		rr_department_id(i),
		rr_wip_entity_id(i),
		rr_operation_seq_num(i),
		2,
		rr_firm_flag(i),
		rr_minimum_transfer_quantity(i),
		rr_parent_seq_num(i),
		rr_schedule_flag(i),
		rr_basis_type(i),
		rr_setup_id(i),
		rr_sequence_id(i),     -- group_sequence_id
		rr_sequence_number(i), -- group_sequence_number
		rr_min_capacity(i),
		rr_max_capacity(i),
		rr_original_seq_num(i),
		rr_alternate_number(i),
                rr_hours_expended(i),
                rr_breakable_activity_flag(i),
                rr_product_item_id(i),   /* B4777532 - product_item_id populated */
                rr_plan_step_qty(i),  /* Sowmya - As per the latest FDD changes*/
                rr_step_qty_uom(i) , /* Sowmya - As per the latest FDD changes*/
                rr_gmd_rsrc_cnt(i),
                rr_unadjusted_resource_hrs(i), /*B4320561 - sowsubra*/
                rr_touch_time(i), /*B4320561 - sowsubra*/
                rr_activity_group_id(i),  /* B3995361 rpatangy */
            --    rr_activity_name(i),  /* B5338598 rpatangy */
            --    rr_operation_no(i),  /* B5338598 rpatangy */
		rr_operation_sequence_id(i) /* B5461922 rpatangy */
        )   ;

-- =============== memory release ====================
		rr_organization_id 	:= empty_num_tbl ;
		rr_sr_instance_id  	:= empty_num_tbl ;
		rr_supply_id		:= empty_num_tbl ;
		rr_resource_seq_num	:= empty_num_tbl ;
		rr_resource_id		:= empty_num_tbl ;
		rr_start_date		:= empty_date_tbl ;
		rr_end_date		:= empty_date_tbl ;
		rr_opr_hours_required 	:= empty_num_tbl ;
                rr_usage_rate		:= empty_num_tbl ;
		rr_assigned_units	:= empty_num_tbl ;
		rr_department_id	:= empty_num_tbl ;
		rr_wip_entity_id	:= empty_num_tbl ;
		rr_operation_seq_num	:= empty_num_tbl ;
		rr_firm_flag		:= empty_num_tbl ;
		rr_minimum_transfer_quantity	:= empty_num_tbl ;
		rr_parent_seq_num	:= empty_num_tbl ;
		rr_schedule_flag	:= empty_num_tbl ;
		rr_basis_type		:= empty_num_tbl ;
		rr_setup_id		:= empty_num_tbl ;
		rr_sequence_id		:= empty_num_tbl ;
		rr_sequence_number	:= empty_num_tbl ;
		rr_min_capacity		:= empty_num_tbl ;
		rr_max_capacity		:= empty_num_tbl ;
		rr_original_seq_num	:= empty_num_tbl ;
		rr_alternate_number	:= empty_num_tbl ;
                rr_hours_expended	:= empty_num_tbl ;
                rr_breakable_activity_flag	:= empty_num_tbl ;
                rr_product_item_id	:= empty_num_tbl ;
                rr_plan_step_qty	:= empty_num_tbl ;
                rr_step_qty_uom		:= empty_step_qty_uom ;
                rr_gmd_rsrc_cnt		:= empty_num_tbl ;
                rr_unadjusted_resource_hrs	:= empty_num_tbl ;
                rr_touch_time		:= empty_num_tbl ;
                rr_activity_group_id	:= empty_num_tbl ;
             --   rr_activity_name    	:= empty_batch_activity;
             --   rr_operation_no    	:= empty_batch_activity;
		rr_operation_sequence_id := empty_num_tbl ; /* B5461922 rpatangy */
-- =============== memory release ====================
     END IF;
/* ----------------------- Supply Insert --------------------- */
      i := 1 ;
      log_message(s_organization_id.FIRST || ' *s*' || s_organization_id.LAST );
      IF s_organization_id.FIRST > 0 THEN
      FORALL i IN s_organization_id.FIRST..s_organization_id.LAST
        INSERT INTO msc_st_supplies (
        plan_id,
        inventory_item_id,
        organization_id,
        sr_instance_id,
        new_schedule_date,
        old_schedule_date,
        new_wip_start_date,
        old_wip_start_date,
        last_unit_completion_date,
        disposition_id,
        order_type,
        order_number,
        new_order_quantity,
        old_order_quantity,
        firm_planned_type,
        firm_quantity,
        firm_date,
        wip_entity_name,
        lot_number,
        expiration_date,
        operation_seq_num,
        by_product_using_assy_id,
        deleted_flag,
        requested_completion_date,
        wip_status_code, /*B5100481*/
        schedule_priority,
        process_seq_id,  /* B8349005 */
	      actual_start_date          -- Bug: 8624913
        )
        VALUES (
        -1,
        s_inventory_item_id(i),
        s_organization_id(i),
        s_sr_instance_id(i),
        s_new_schedule_date(i),
        s_old_schedule_date(i),
        s_new_wip_start_date(i),
        s_old_wip_start_date(i),
        s_lunit_completion_date(i),
        s_disposition_id(i),
        s_order_type(i),
        s_order_number(i),
        s_new_order_quantity(i),
        s_old_order_quantity(i),
        s_firm_planned_type(i),  /* 2 */
        s_firm_quantity(i),
        s_firm_date(i),
        s_wip_entity_name(i),   /* Order Number */
        null_value,
        null_value,
        s_operation_seq_num(i),
        s_by_product_using_assy_id(i),
        2,                      /* Deleted Flag */
        s_requested_completion_date(i),
        s_wip_status_code(i), /*B5100481 - 16 for pending, 3 for wip */
        s_schedule_priority(i),
        s_process_seq_id(i),  /* B8349005 */
        s_actual_start_date(i)     -- Bug: 8624913
        ) ;

--====================== Memory release======================
        s_inventory_item_id	:=  empty_num_tbl ;
        s_organization_id	:= empty_num_tbl ;
        s_sr_instance_id	:= empty_num_tbl ;
        s_new_schedule_date	:= empty_date_tbl ;
        s_old_schedule_date	:= empty_date_tbl ;
        s_new_wip_start_date	:= empty_date_tbl ;
        s_old_wip_start_date	:= empty_date_tbl ;
        s_lunit_completion_date	:= empty_date_tbl ;
        s_disposition_id	:= empty_num_tbl ;
        s_order_type		:= empty_num_tbl ;
        s_order_number		:= empty_sorder_number ;
        s_new_order_quantity	:= empty_num_tbl ;
        s_old_order_quantity	:= empty_num_tbl ;
        s_firm_planned_type	:= empty_num_tbl ;
        s_firm_quantity		:= empty_num_tbl ;
        s_firm_date		:= empty_date_tbl ;
        s_wip_entity_name	:= empty_swip_entity_name ;
        s_operation_seq_num	:= empty_num_tbl ;
        s_by_product_using_assy_id	:= empty_num_tbl ;
        s_requested_completion_date	:= empty_date_tbl ;
        s_wip_status_code	:= empty_num_tbl ;
        s_schedule_priority	:= empty_num_tbl ;
        s_process_seq_id        := empty_num_tbl ; /* B8349005*/
        s_actual_start_date     := empty_date_tbl ;  -- Bug: 8624913

      END IF;
/* ----------------------- Demands Insert --------------------- */
      i := 1 ;
      log_message(d_organization_id.FIRST || '*' || d_index || '*' || d_organization_id.LAST );
      IF d_organization_id.FIRST > 0 THEN
      FORALL i IN d_organization_id.FIRST..d_organization_id.LAST
        INSERT INTO msc_st_demands (
        organization_id,
        inventory_item_id,
        sr_instance_id,
        using_assembly_item_id,
        using_assembly_demand_date,
        using_requirement_quantity,
        demand_type,
        origination_type,
        wip_entity_id,
        demand_schedule_name,
        order_number,
        wip_entity_name,
        selling_price,
        operation_seq_num,
        wip_status_code, /*B5100481*/
        deleted_flag )
        VALUES (
        d_organization_id(i),
        d_inventory_item_id(i),
        d_sr_instance_id(i),
        d_assembly_item_id(i),
        d_demand_date(i),
        d_requirement_quantity(i),
        d_demand_type(i),
        d_origination_type(i),
        d_wip_entity_id(i),
        d_demand_schedule(i),
        d_order_number(i),
        d_wip_entity_name(i),
        d_selling_price(i),
        d_operation_seq_num(i),
        d_wip_status_code(i), /*B5100481*/
        2 ) ;
--================== Memory Release ========================
        d_organization_id	:= empty_num_tbl ;
        d_inventory_item_id	:= empty_num_tbl ;
        d_sr_instance_id	:= empty_num_tbl ;
        d_assembly_item_id	:= empty_num_tbl ;
        d_demand_date		:= empty_date_tbl ;
        d_requirement_quantity	:= empty_num_tbl ;
        d_demand_type		:= empty_num_tbl ;
        d_origination_type	:= empty_num_tbl ;
        d_wip_entity_id		:= empty_num_tbl ;
        d_demand_schedule	:= empty_demand_schedule ;
        d_order_number		:= empty_dorder_number ;
        d_wip_entity_name	:= empty_dwip_entity_name ;
        d_selling_price		:= empty_num_tbl ;
        d_operation_seq_num	:= empty_num_tbl ;
        d_wip_status_code	:= empty_num_tbl ;
-- =============================================================
      END IF;

      s_index := 0 ;
      d_index := 0 ;
      rr_index := 0 ;

        /* NAVIN: ------------ START: Complex Route -- Collect Batch Step Dependencies in one insert-select ------------*/
        sql_stmt :=
         ' INSERT INTO msc_st_job_operation_networks '
                || ' ( '
                || '    from_op_seq_id, '
                || '    to_op_seq_id, '
                || '    wip_entity_id, '
                || '    dependency_type, '
                || '    transition_type, '
                || '    sr_instance_id, '
                || '    deleted_flag, '
                || '    minimum_time_offset, '
                || '    maximum_time_offset, '
                || '    transfer_pct, '
                || '    from_op_seq_num, '
                || '    to_op_seq_num, '
                || '    apply_to_charges, '
                || '    organization_id '
                || ' ) '
                || ' SELECT '
                ||'         ((gbsd.dep_step_id*2)+1), '     /* B5461922 */
		||'         ((gbsd.batchstep_id*2)+1),'     /* B5461922 */
                ||'          ((gbsd.batch_id * 2) + 1) x_batch_id, '
                ||'          decode(gbsd.dep_type,0,1,2) dependency_type, '
                ||'          1, '
                ||'          :1, '
                ||'          2, '
                ||'          gbsd.standard_delay, '
                ||'          gbsd.max_delay, '
                ||'          gbsd.transfer_percent, '
                ||'          gbs1.batchstep_no, '
                ||'          gbs2.batchstep_no, '
                ||'          DECODE(NVL(gbsd.chargeable_ind,0),1,1,2), '   /* convert a Null or 0 to a 2, a 1 remains a 1 */
/* nsinghi INVCONV Start */
/*                ||'          iwm.mtl_organization_id ' */
                ||'          h.organization_id '
/* nsinghi INVCONV End */

                ||'      FROM '
                ||'          gme_batch_step_dependencies'||pdblink||' gbsd, '
                ||'          gme_batch_header'||pdblink||' h,'
                ||'          gme_batch_steps'||pdblink||' gbs1, '
                ||'          gme_batch_steps'||pdblink||' gbs2 '
/* nsinghi INVCONV Start */
/*                ||'          ic_whse_mst'||pdblink||' iwm, '
                ||'          sy_orgn_mst'||pdblink||' som ' */
/* nsinghi INVCONV End */

                ||'      WHERE '
                ||'               h.batch_id = gbsd.batch_id '
                ||'          AND gbs1.batch_id = gbsd.batch_id '
                ||'          AND gbs1.batchstep_id = gbsd.dep_step_id '
                ||'          AND gbs2.batch_id = gbsd.batch_id '
                ||'          AND gbs2.batchstep_id = gbsd.batchstep_id '
                ||'          AND h.batch_status in (1, 2) ';

/* nsinghi INVCONV Start */
/*                ||'          AND h.plant_code = som.orgn_code '
                ||'          AND som.delete_mark = 0 '
                ||'          AND som.resource_whse_code = iwm.whse_code ' ; */
/* nsinghi INVCONV End */

	        IF gmp_calendar_pkg.g_in_str_org  IS NOT NULL THEN
	         sql_stmt := sql_stmt
/* nsinghi INVCONV Start */
/*	                   ||'   AND iwm.mtl_organization_id ' || gmp_calendar_pkg.g_in_str_org ; */
	                   ||'   AND h.organization_id ' || gmp_calendar_pkg.g_in_str_org ;
/* nsinghi INVCONV End */
	        END IF;

	         EXECUTE IMMEDIATE  sql_stmt USING pinstance_id;
        /* NAVIN: ------------ END: Complex Route -- Collect Batch Step Dependencies in one insert-select ------------*/

/* NAVIN: ----------------------- MTQ with Hardlinks --------------------- */
i := 1 ;
IF stp_var_itm_from_op_seq_id.FIRST > 0 THEN
FORALL i IN stp_var_itm_from_op_seq_id.FIRST..stp_var_itm_from_op_seq_id.LAST
 INSERT INTO msc_st_job_operation_networks(
	from_op_seq_id,
	wip_entity_id,
	dependency_type,
	transition_type,
	sr_instance_id,
	deleted_flag,
	from_item_id,
	organization_id,
	minimum_time_offset,
	maximum_time_offset,
	from_op_seq_num,
        minimum_transfer_qty
  )
 VALUES
  (
	stp_var_itm_from_op_seq_id(i),
	stp_var_itm_wip_entity_id(i),
	5,	-- dependency_type for mtq with hardlink
	1,	-- transition_type: primary
	stp_var_itm_instance_id(i),
	2,
	stp_var_itm_FROM_item_ID(i),
	stp_var_itm_organization_id(i),
	stp_var_itm_min_tm_off(i),
	stp_var_itm_max_tm_off(i),
	stp_var_itm_from_op_seq_num(i),
        stp_var_min_tran_qty(i)
  );
-- ================== Memory Release ===============================
	stp_var_itm_from_op_seq_id 	:=  empty_num_tbl ;
	stp_var_itm_wip_entity_id 	:=  empty_num_tbl ;
	stp_var_itm_instance_id 	:=  empty_num_tbl ;
	stp_var_itm_from_item_id 	:=  empty_num_tbl ;
	stp_var_itm_organization_id 	:=  empty_num_tbl ;
	stp_var_itm_min_tm_off 		:=  empty_num_tbl ;
	stp_var_itm_max_tm_off 		:=  empty_num_tbl ;
	stp_var_itm_from_op_seq_num 	:=  empty_num_tbl ;
        stp_var_min_tran_qty 		:=  empty_num_tbl ;
-- ================== Memory Release ===============================
END IF ;
/* ----------------------- MTQ with Hardlinks --------------------- */


/* ----------------------- Operation Charges --------------------- */
/* NAVIN: Operation Charges */
i := 1 ;
IF stp_chg_resource_id.FIRST > 0 THEN
 FORALL i IN stp_chg_resource_id.FIRST..stp_chg_resource_id.LAST
  INSERT INTO msc_st_resource_charges
  (
      sr_instance_id          ,
      resource_id             ,
      organization_id         ,
      department_id         ,
      wip_entity_id           ,
      operation_sequence_id   ,
      operation_seq_num       ,
      resource_seq_num        ,
      charge_number              ,
      charge_quantity         ,
      deleted_flag            ,
      charge_start_datetime   ,
      charge_end_datetime
  )

   VALUES

  (
      stp_instance_id(i)      ,
      stp_chg_resource_id(i)  ,
      stp_chg_organization_id(i),
      stp_chg_department_id(i),
      stp_chg_wip_entity_id(i),
      stp_chg_operation_seq_id(i),
      stp_chg_operation_seq_no(i),
      stp_chg_resource_seq_num(i),
      stp_chg_charge_num(i),
      stp_chg_charge_quanitity(i),
      2,
      stp_chg_charge_start_dt_time(i) ,
      stp_chg_charge_end_dt_time(i)
  );
--======================== Memory Release====================
      stp_instance_id			:= empty_num_tbl ;
      stp_chg_resource_id		:= empty_num_tbl ;
      stp_chg_organization_id		:= empty_num_tbl ;
      stp_chg_department_id		:= empty_num_tbl ;
      stp_chg_wip_entity_id		:= empty_num_tbl ;
      stp_chg_operation_seq_id		:= empty_num_tbl ;
      stp_chg_operation_seq_no		:= empty_num_tbl ;
      stp_chg_resource_seq_num		:= empty_num_tbl ;
      stp_chg_charge_num		:= empty_num_tbl ;
      stp_chg_charge_quanitity		:= empty_num_tbl ;
      stp_chg_charge_start_dt_time	:= empty_date_tbl ;
      stp_chg_charge_end_dt_time	:= empty_date_tbl ;
--======================== Memory Release====================
END IF ;
/* ----------------------- Operation Charges  --------------------- */

/* ----------------------- Resource Instances  --------------------- */

     i := 1 ;
     log_message(rec_inst_organization_id.FIRST || ' *rir*' || rec_inst_organization_id.LAST );
     IF rec_inst_organization_id.FIRST > 0 THEN
     FORALL i IN rec_inst_organization_id.FIRST..rec_inst_organization_id.LAST
       INSERT INTO msc_st_resource_instance_reqs (
        supply_id,
        organization_id,
        sr_instance_id,
        resource_seq_num,
        resource_id,
        res_instance_id,
        start_date,
        end_date,
        resource_instance_hours,
      /* NAVIN :- CHECK Should This be Included. It is
         mentioned in FDD, but not included in APS script file. */
--        schedule_flag,
        operation_seq_num,
        department_id,
        wip_entity_id,
        serial_number,
        deleted_flag,
        parent_seq_num, /* Sowmya -  as the column was changed from parent_seq_number to parent_seq_num */
        orig_resource_seq_num,
        equipment_item_id /*Sowmya - As per the latest FDD changes - End*/
       )
        VALUES (
        rec_inst_supply_id(i) ,
        rec_inst_organization_id(i) ,
        rec_inst_sr_instance_id(i) ,
        rec_inst_rec_resource_seq_num(i) ,
        rec_inst_resource_id(i) ,
        rec_inst_instance_id(i) ,
        rec_inst_start_date(i) ,
        rec_inst_end_date(i) ,
        rec_inst_rsrc_instance_hours(i) ,
--        1 , /* Schedule Flag 1 = Scheduled */
        rec_inst_operation_seq_num(i) ,
        rec_inst_department_id(i) ,
        rec_inst_wip_entity_id(i) ,
        rec_inst_serial_number(i) ,
        2 , /* Delete Flag */
        rec_inst_parent_seq_num(i) ,
        rec_inst_original_seq_num(i),
        rec_inst_equp_item_id(i) /*Sowmya - As per the latest FDD changes - End*/
        )   ;
--=================== Memory Release====================
        rec_inst_supply_id		:= empty_num_tbl ;
        rec_inst_organization_id	:= empty_num_tbl ;
        rec_inst_sr_instance_id		:= empty_num_tbl ;
        rec_inst_rec_resource_seq_num	:= empty_num_tbl ;
        rec_inst_resource_id		:= empty_num_tbl ;
        rec_inst_instance_id		:= empty_num_tbl ;
        rec_inst_start_date		:= empty_date_tbl ;
        rec_inst_end_date		:= empty_date_tbl ;
        rec_inst_rsrc_instance_hours	:= empty_num_tbl ;
        rec_inst_operation_seq_num	:= empty_num_tbl ;
        rec_inst_department_id		:= empty_num_tbl ;
        rec_inst_wip_entity_id		:= empty_num_tbl ;
        rec_inst_serial_number		:= empty_inst_serial_number ;
        rec_inst_parent_seq_num		:= empty_num_tbl ;
        rec_inst_original_seq_num	:= empty_num_tbl ;
        rec_inst_equp_item_id		:= empty_num_tbl ;
--=================== Memory Release====================
     END IF;
/* ----------------------- Resource Instances  --------------------- */

/* ----------------------- Alternate Resources --------------------- */
/*Sowmya - As per the latest FDD changes - Start*/
     i := 1 ;
     log_message(arr_organization_id.FIRST || ' *rir*' || arr_organization_id.LAST );
     IF arr_organization_id.FIRST > 0 THEN
     FORALL i IN arr_organization_id.FIRST..arr_organization_id.LAST

        INSERT INTO msc_st_job_op_resources
        (
         wip_entity_id,
         organization_id,
         sr_instance_id ,
         operation_seq_num ,
         resource_seq_num ,
         resource_id ,
         alternate_num ,
         reco_start_date ,
         reco_completion_date ,
         usage_rate_or_amount  ,
         assigned_units ,
         schedule_flag ,
         parent_seq_num ,
         recommended ,
         department_id ,
         uom_code ,
         activity_group_id ,
         basis_type ,
         firm_flag ,
         setup_id ,
         schedule_seq_num  ,
         group_sequence_id ,
         group_sequence_number ,
--         resource_batch_id ,
         maximum_assigned_units ,
         deleted_flag ,
         batch_number
        )
        VALUES
        (
        arr_wip_entity_id(i),
        arr_organization_id(i),
        arr_sr_instance_id(i),
        arr_operation_seq_num(i),
        arr_res_seq_num(i),
        arr_resource_id(i),
        arr_alternate_num(i),
        null_value,
        null_value,
        arr_usage_rate(i),
        arr_assigned_units(i),
        1,
        null_value,
        1,
        arr_department_id(i),
        arr_uom_code(i),
        arr_activity_group_id(i),
        arr_basis_type(i),
        null_value,
        arr_setup_id(i),
        arr_schedule_seq_num(i),
        null_value,
        null_value,
--        null_value,
        arr_maximum_assigned_units(i),
        2,
        null_value
        );
--================= Memory Release ==============
        arr_wip_entity_id	:= empty_num_tbl ;
        arr_organization_id	:= empty_num_tbl ;
        arr_sr_instance_id	:= empty_num_tbl ;
        arr_operation_seq_num	:= empty_num_tbl ;
        arr_res_seq_num		:= empty_num_tbl ;
        arr_resource_id		:= empty_num_tbl ;
        arr_alternate_num	:= empty_num_tbl ;
        arr_usage_rate		:= empty_num_tbl ;
        arr_assigned_units	:= empty_num_tbl ;
        arr_department_id	:= empty_num_tbl ;
        arr_uom_code		:= empty_arr_uom_code ;
        arr_activity_group_id	:= empty_num_tbl ;
        arr_basis_type		:= empty_num_tbl ;
        arr_setup_id		:= empty_num_tbl ;
        arr_schedule_seq_num	:= empty_num_tbl ;
        arr_maximum_assigned_units	:= empty_num_tbl ;
--====================Memory Release=============

     END IF;
/*Sowmya - As per the latest FDD changes - End*/
/* ----------------------- Alternate Resources --------------------- */

/* nsinghi : Populate Msc_Job_Operations Table. */
/* ----------------------- Job Operations --------------------- */
     i := 1 ;
     log_message(jo_wip_entity_id.FIRST || ' *jo*' || jo_wip_entity_id.LAST );
     IF jo_wip_entity_id.FIRST > 0 THEN
     FORALL i IN jo_wip_entity_id.FIRST..jo_wip_entity_id.LAST
        INSERT INTO msc_st_job_operations
        (
           wip_entity_id,
           sr_instance_id,
           operation_seq_num,
           recommended,
           network_start_end,
           reco_start_date,
           reco_completion_date,
           operation_sequence_id,
           organization_id,
           department_id,
           minimum_transfer_quantity,
           effectivity_date,
           deleted_flag
        )
        VALUES
        (
           jo_wip_entity_id(i),
           jo_instance_id(i),
           jo_operation_seq_num(i),
           jo_recommended(i),
           jo_network_start_end(i),
           jo_reco_start_date(i),
           jo_reco_completion_date(i),
           jo_operation_sequence_id(i),
           jo_organization_id(i),
           jo_department_id(i),
           jo_minimum_transfer_quantity(i),
           SYSDATE-100,
           2
        );
--================ Memory Release ========================
           jo_wip_entity_id		:= empty_num_tbl ;
           jo_instance_id		:= empty_num_tbl ;
           jo_operation_seq_num		:= empty_num_tbl ;
           jo_recommended		:= empty_jo_recommended ;
           jo_network_start_end		:= empty_jo_recommended ;
           jo_reco_start_date		:= empty_date_tbl ;
           jo_reco_completion_date	:= empty_date_tbl ;
           jo_operation_sequence_id	:= empty_num_tbl ;
           jo_organization_id		:= empty_num_tbl ;
           jo_department_id		:= empty_num_tbl ;
           jo_minimum_transfer_quantity	:= empty_num_tbl ;
--================= Memory Release =========================

     END IF;
/* ----------------------- Job Operations --------------------- */
	DBMS_SESSION.FREE_UNUSED_USER_MEMORY;

  return_status := TRUE;

  EXCEPTION
    WHEN invalid_string_value  THEN
        log_message('Organization string is Invalid ' );
        return_status := FALSE;

    WHEN invalid_gmp_uom_profile THEN
        log_message('Profile "GMP: UOM for Hour" is Invalid ' );
        return_status := FALSE;

    WHEN NO_DATA_FOUND THEN /* B3577871 */
      log_message(' NO_DATA_FOUND exception raised in Procedure: Gmp_aps_ds_pull.Production_orders ' );
      return_status := TRUE;

    WHEN OTHERS THEN
	return_status := FALSE;
	log_message('Failure occured during Production Orders extract' || sqlerrm);
	log_message(sqlerrm);

END production_orders;

/***********************************************************************
*
*   NAME
*	insert_supplies
*
*   DESCRIPTION
*	This procedure will take the parameter values and insert a row into
*	the table msc_st_supplies
*   HISTORY
*	M Craig
*  2/10/2000 - Populating Order number column with Wip Entity Name  ( porder_no )
*  2/24/2003 - populating Firmed batches Indicator, Qty and Date
************************************************************************/
PROCEDURE insert_supplies(
  pitem_id          PLS_INTEGER,
  porganization_id  PLS_INTEGER,
  pinstance_id      PLS_INTEGER,
  pdate             DATE,
  pstart_date       DATE,
  pend_date         DATE,
  pbatch_id         PLS_INTEGER,
  pqty              NUMBER,
  pfirmed_ind       NUMBER,
  pbatchstep_no     NUMBER,   /* Added pbatchstep_no - B2919303 */
  porder_no         VARCHAR2,
  plot_number       VARCHAR2,
  pexpire_date      DATE,
  psupply_type      NUMBER,
  pproduct_item_id  PLS_INTEGER)     /* B2953953 - CoProduct */

AS
  st_supplies  VARCHAR2(4000) ;
  vproduct_item_id NUMBER ;  /* B2953953 - CoProduct */
BEGIN

  st_supplies :=
    ' INSERT INTO msc_st_supplies ( '
  ||' plan_id, inventory_item_id, organization_id, sr_instance_id, '
  ||' new_schedule_date, old_schedule_date, new_wip_start_date, '
  ||' old_wip_start_date, last_unit_completion_date, disposition_id, '
  ||' order_type, order_number, new_order_quantity, old_order_quantity, '
  ||' firm_planned_type,firm_quantity,firm_date, wip_entity_name, '
  ||' lot_number, expiration_date,operation_seq_num, by_product_using_assy_id, '
  ||' deleted_flag ) '
  ||' VALUES '
  ||' (:p1, :p2, :p3, :p4, '
  ||'  :p5, :p6, :p7,      '
  ||'  :p8, :p9, :p10,     '
  ||'  :p11,:p12,:p13,:p14,'
  ||'  :p15,:p16,:p17,:p18,'
  ||'  :p19,:p20,:p21,'
  ||'  :p22,:p23 ) ' ;

  /* B2953953 The by_product_assy_id should not be written for Products ,
     but should be written for co-products and by-products */

  IF psupply_type = 3 THEN
     vproduct_item_id := to_number(NULL) ;
  ELSE
    vproduct_item_id := pproduct_item_id ;
  END IF;

    EXECUTE IMMEDIATE st_supplies USING
    -1,
    pitem_id,
    porganization_id,
    pinstance_id,
    pdate,
    pdate,
    pstart_date,
    pstart_date,
    pend_date,
    pbatch_id,
    psupply_type,
    porder_no,     /* Populating Order no column - bug#1152778 */
    pqty,
    pqty,
    /* 2, */
    pfirmed_ind,  /* B2821248 Firmed Batches Indicator - */
    pqty,         /* B2821248 Firmed Batches Qty  - */
    pdate,        /* B2821248 Firmed Batches Date - */
    porder_no,
    plot_number,
    pexpire_date,
    pbatchstep_no,  /* B2919303 */
    vproduct_item_id,  /* B2953953 - Co-Product      - */
    2 ;

  EXCEPTION
    WHEN OTHERS THEN
	log_message('Failure occured during the insert into msc_st_supplies');
	log_message(sqlerrm);
        RAISE;

END insert_supplies;

/***********************************************************************
*
*   NAME
*	 insert_resource_requirements
*
*   DESCRIPTION
*	This procedure wil insert a row into the table
*	msc_st_resource_requirements using the parameters passed in
*   HISTORY
* 	M Craig
* 	10/13/99 - Added deleted_flag in the insert statement
*       13-SEP-2002 - firm_flag = 1 for WIP steps B2266934
************************************************************************/
PROCEDURE insert_resource_requirements(
  porganization_id  IN PLS_INTEGER,
  pinstance_id      IN PLS_INTEGER,
  pseq_num          IN PLS_INTEGER,
  presource_id      IN PLS_INTEGER,
  pstart_date       IN DATE,
  pend_date         IN DATE,
  presource_usage   IN NUMBER,
  prsrc_cnt         IN NUMBER,
  pbatchstep_no     IN NUMBER,  /* B1224660 new parm to write step number */
  pbatch_id         IN PLS_INTEGER,
  pstep_status      IN NUMBER,
  pschedule_flag    IN NUMBER,
  pparent_seq_num   IN NUMBER,
  pmin_xfer_qty     IN NUMBER)

AS
  st_resource_requirements  VARCHAR2(2000) ;

BEGIN
  st_resource_requirements :=
       ' INSERT INTO msc_st_resource_requirements ( '
       ||' organization_id, sr_instance_id, supply_id, resource_seq_num,'
       ||' resource_id, start_date, end_date, operation_hours_required,'
       ||' assigned_units, department_id, wip_entity_id, operation_seq_num, '
       ||' deleted_flag, firm_flag, minimum_transfer_quantity, '
       ||' parent_seq_num, schedule_flag ) '
       ||' VALUES '
       ||' ( :p1, :p2, :p3, :p4, '
       ||'   :p5, :p6, :p7, :p8, '
       ||'   :p9, :p10,:p11,:p12, '
       ||'   :p13,:p14, :p15, '
       ||'   :p16, :p17 ) ';

  EXECUTE IMMEDIATE st_resource_requirements USING
    porganization_id,
    pinstance_id,
    pbatch_id,
    pseq_num,
    presource_id,
    pstart_date,
    pend_date,
    presource_usage,
    prsrc_cnt,
    ((porganization_id * 2) + 1),  /* B1177070 encoded key */
    pbatch_id,
    pbatchstep_no,  /* B1224660 write the step number for oper seq num */
    2,
    pstep_status,
    pmin_xfer_qty,
    pparent_seq_num,
    pschedule_flag ;

  EXCEPTION
    WHEN OTHERS THEN
	log_message('Failure occured during the insert into msc_st_resource_requirements');
	log_message(sqlerrm);
        RAISE;

END insert_resource_requirements;

/***********************************************************************
*
*   NAME
*	insert_demands
*
*   DESCRIPTION
*	This procedure will take the parameter values and insert a row into
*	the table msc_st_demands
*   HISTORY
*	M Craig
*	10/13/99 - Added deleted_flag in the insert statement
*     P Dong
*     09/14/01 - added api_mode and pschedule_id parameters
************************************************************************/
PROCEDURE insert_demands(
  pitem_id          PLS_INTEGER,
  porganization_id  PLS_INTEGER,
  pinstance_id      PLS_INTEGER,
  pbatch_id         PLS_INTEGER,
  pproduct_item_id  PLS_INTEGER,
  pdate             DATE,
  pqty              NUMBER,
  pbatchstep_no     NUMBER,   /* B2919303 - BatchStep */
  porder_no         VARCHAR2,
  pdesignator       VARCHAR2,
  pnet_price        NUMBER,  /* B1200400 added net price */
  porigination_type NUMBER,
  api_mode          BOOLEAN,
  pschedule_id      NUMBER )

AS

  statement_demands_api  VARCHAR2(3000) ;
  statement_demands      VARCHAR2(3000) ;
  t_order_number         VARCHAR2(70)   ;
  t_wip_entity_name      VARCHAR2(70)   ;

BEGIN
  t_order_number         := NULL ;
  t_wip_entity_name      := NULL ;

/* mfc 11-30-99 changed to write batch_id to wip_entity_id */

IF api_mode
THEN
  BEGIN
    statement_demands_api  :=
      ' INSERT INTO gmp_demands_api ( '
    ||'  organization_id, schedule_id, inventory_item_id, demand_date, '
    ||'  demand_quantity, origination_type, doc_id, selling_price ) '
    ||' VALUES '
    ||' ( :p1, :p2, :p3, :p4, '
    ||'   :p5, :p6, :p7, :p8 ) ';

    EXECUTE IMMEDIATE statement_demands_api USING
      porganization_id,
      pschedule_id,
      pitem_id,
      pdate,
      pqty,
      porigination_type,
      pbatch_id,
      pnet_price;

  EXCEPTION
    WHEN OTHERS THEN
	log_message('Failure occured during the insert into gmp_demands_api');
	log_message(sqlerrm);
      RAISE;
  END;
ELSE
  BEGIN

     SELECT DECODE(porigination_type,1,NULL,porder_no) ,
            DECODE(porigination_type,1,porder_no,NULL)
     INTO t_order_number, t_wip_entity_name
     FROM dual ;

    statement_demands  :=
      ' INSERT INTO msc_st_demands ( '
    ||' organization_id, inventory_item_id, sr_instance_id, '
    ||' using_assembly_item_id, using_assembly_demand_date, '
    ||' using_requirement_quantity, demand_type, origination_type, '
    ||' wip_entity_id, demand_schedule_name, order_number, '
    ||' wip_entity_name, selling_price,operation_seq_num,deleted_flag ) '
    ||' VALUES '
    ||' ( :p1, :p2, :p3,  '
    ||'   :p4, :p5,       '
    ||'   :p6, :p7, :p8 , '
    ||'   :p9, :p10,:p11, '
    ||'   :p12,:p13,:p14,:p15 )' ;

    EXECUTE IMMEDIATE statement_demands USING
      porganization_id,
      pitem_id,
      pinstance_id,
      pproduct_item_id,
      pdate,
      pqty,
      1,
      porigination_type,
      pbatch_id,
      pdesignator,
      t_order_number,
      t_wip_entity_name,
      pnet_price,    /* B1200400 added for net price */
      pbatchstep_no,  /* B2919303 */
      2 ;
  EXCEPTION
    WHEN OTHERS THEN
	log_message('Failure occured during the insert into msc_st_demands');
	log_message(sqlerrm);
      RAISE;
  END;

END IF;

END insert_demands;

/***********************************************************************
*
*   NAME
*	 onhand_inventory
*
*   DESCRIPTION
*	This procedure will insert records into the table msc_st_supplies
*	for the onhand balances in inventory. The insert is split into 3 parts
*	one for non-lot controlled, lot controlled, and lot and status
*	controlled item. Each inserted will need touse a distnct list from
*	the table gmp_item_aps. The table may contain multiple values for
*	the item/whse combination
*   HISTORY
* 	M Craig
*  M Craig B1332662 changed to call two new procs to collect onhand and
*          Inventory transfers
*   Navin   21-APR-2003 B3577871 ST:OSFME2: collections failing in planning data pull.
*                                Added handling of NO_DATA_FOUND Exception.
*                                And return the return_status as TRUE.
************************************************************************/
PROCEDURE onhand_inventory(
  pdblink        IN  VARCHAR2,
  pinstance_id   IN  PLS_INTEGER,
  prun_date      IN  DATE,
  pdelimiter     IN  VARCHAR2,
  return_status  IN OUT NOCOPY BOOLEAN)
AS

  local_ret_status1  BOOLEAN := TRUE;
  local_ret_status2  BOOLEAN := TRUE;
  onhand_balances_failure EXCEPTION ;
  inv_transfer_failure EXCEPTION ;

BEGIN

  IF return_status THEN
    v_cp_enabled := TRUE;
  ELSE
    v_cp_enabled := FALSE;
  END IF;

  extract_onhand_balances( pdblink, pinstance_id, prun_date, pdelimiter,
    local_ret_status1);

  IF local_ret_status1 = TRUE THEN
    return_status := TRUE;
  ELSE
    return_status := FALSE;
    RAISE  onhand_balances_failure ;
  END IF;

   /* B 2756431 Changed the call to new proceudre */

/* nsinghi INVCONV Start */
/* As in converged inventory we cannot pending inventory transfers, hence commenting
the call to this procedure. */

/*
  extract_inv_transfer_supplies(pdblink, pinstance_id, prun_date,
     pdelimiter, local_ret_status2);

  IF local_ret_status2 = TRUE  THEN
    return_status := TRUE ;
  ELSE
    return_status := FALSE;
    RAISE  inv_transfer_failure ;
  END IF;
*/
/* nsinghi INVCONV End */

  EXCEPTION
    WHEN onhand_balances_failure THEN
      log_message(' extract_onhand_balances_failure raised in Procedure: Gmp_aps_ds_pull.Onhand_inventory ' );
      return_status := FALSE;
    WHEN inv_transfer_failure THEN
      log_message(' extract_inv_transfer_supplies_failure raised in Procedure: Gmp_aps_ds_pull.Onhand_inventory ' );
      return_status := FALSE;
    WHEN NO_DATA_FOUND THEN /* B3577871 */
      log_message(' NO_DATA_FOUND exception raised in Procedure: Gmp_aps_ds_pull.Onhand_inventory ' );
      return_status := TRUE;

END onhand_inventory;  /* end onhand_inventory */

/***********************************************************************
*
*   NAME
*	extract_onhand_balances
*
*   DESCRIPTION
*	This procedure will insert records into the table msc_st_supplies
*	for the onhand balances in inventory. The insert is split into 3 parts
*	one for non-lot controlled, lot controlled, and lot and status
*	controlled item. Each inserted will need touse a distnct list from
*	the table gmp_item_aps. The table may contain multiple values for
*	the item/whse combination
*   HISTORY
* 	M Craig
* 	10/13/99 - Added deleted_flag in the insert statement
*	2/10/2000 - Populating sub inventory code with whse code - bug# 1172875
*  M Craig B1332662 created a new function to just collect onhand inventory
*  Sgidugu B2251375 - Changed Substr Function to substrb Function
************************************************************************/
PROCEDURE extract_onhand_balances(
  pdblink        IN  VARCHAR2,
  pinstance_id   IN  PLS_INTEGER,
  prun_date      IN  DATE,
  pdelimiter     IN  VARCHAR2,
  return_status  IN OUT NOCOPY BOOLEAN)
AS

BEGIN

/* nsinghi INVCONV Start */
/* Previously the logic to insert onhand information was split into the following 3 cursors:
1.      Insert onhand information for items non lot and non status control. View ic_summ_inv_onhand_v
        stores information of onhand and information retrieved from this view.
2.      Insert onhand information for items Lot controlled and non status controlled. ic_loct_inv contains
        onhand information of items in different lots
3.      Insert onhand information for items Lot controlled and status controlled. ic_loct_inv contains
        onhand information of items in different lots

 The three select statements are replaced by a single select statement. */

  v_sql_stmt := ' INSERT into msc_st_supplies ( '
    || ' plan_id, '
    || ' inventory_item_id, '
    || ' organization_id, '
    || ' sr_instance_id, '
    || ' new_schedule_date, '
    || ' new_dock_date, ' /* Confirm if this column is required */
    || ' order_type, '
    || ' lot_number, '
    || ' expiration_date, '
    || ' firm_planned_type, '
    || ' deleted_flag, '
    || ' subinventory_code,  '/* Added new column subinventory Code */
    || ' new_order_quantity) '
    || ' SELECT '
    || ' -1, '
    || ' mon.inventory_item_id, '
    || ' mon.organization_id, '
    || ' :pinstance_id, '
    || ' NVL(mln.hold_date, :prun_date), ' /* Confirm : should we have hold date here. */
    || ' :prun_date, '
    || ' 18, '                        /* onhand inventory value */
/* Discrete Lot and parent lot are now 80 chars long. Lot_number in msc_st_supplies is 30 chars long.
Hence there could be a problem as the lot number is the pkey in mtl_lot_numbers. */
    || ' substrb(DECODE(mln.parent_lot_number, NULL, '', mln.parent_lot_number||:pdelimiter) '
    || '    ||mln.lot_number, 1, 30), '
    || ' mln.expiration_date, '
    || ' 2, '
    || ' 2, '
    || ' mon.subinventory_code, '  /* Populating subinventory with whse code B1172875 */
    || ' INV_CONSIGNED_VALIDATIONS.GET_PLANNING_QUANTITY(2, 1, mon.organization_id, '
    || '        NULL, mon.inventory_item_id) '
    || ' FROM '
    || ' mtl_onhand_net'||pdblink||' mon, '
    || ' mtl_lot_numbers'||pdblink||' mln, '
    || ' mtl_parameters'||pdblink||' gp ' --invconv :- sowmya changed from gmd_parameters to mtl_parameters
    || ' WHERE '
    || ' mon.lot_number = mln.lot_number (+) '
    || ' AND mon.inventory_item_id = mln.inventory_item_id (+) '
    || ' AND mon.organization_id = mln.organization_id (+) '
    || ' AND mon.organization_id = gp.organization_id ';   --sowmya changed

  EXECUTE IMMEDIATE v_sql_stmt USING pinstance_id, prun_date, pdelimiter;


/* Commented out all the code after this */


  /* Query to select the production order details where the batch/fpo is pending
  the balances from ic_summ for the item/whse that are not lot controlled
  are inserted */
/*
  v_sql_stmt := 'INSERT into msc_st_supplies ('
    || ' plan_id,'
    || ' inventory_item_id,'
    || ' organization_id,'
    || ' sr_instance_id,'
    || ' new_schedule_date,'
    || ' order_type,'
    || ' firm_planned_type,'
    || ' deleted_flag,'
    || ' subinventory_code,'  *//* New change , added subinventory Code column */
/*    || ' new_order_quantity)'
    || ' SELECT '
    || ' -1,'
    || ' i.aps_item_id,'
    || ' i.organization_id,'
    || ' :pinstance_id, '
    || ' :prun_date, '
    || ' 18,'  */                      /* onhand inventory value */
/*    || ' 2,'
    || ' 2,'
    || ' s.whse_code,' *//* Populating subinventory with Whse code B1172875 */
/*    || ' s.onhand_qty'
    || ' FROM '
    || ' ic_summ_inv_onhand_v' ||pdblink|| ' s,'
    || ' (select distinct aps_item_id, item_id, whse_code, organization_id, '
    || '  lot_control from'
    || '  gmp_item_aps'||pdblink||') i'
    || ' WHERE '
    || ' s.item_id = i.item_id '
    || ' and s.whse_code = i.whse_code '
    || ' and i.lot_control = 0'
    || ' and s.onhand_qty <> 0';

  EXECUTE IMMEDIATE v_sql_stmt USING pinstance_id, prun_date;

*/
  /* Get onhand balances from the location inventory table for lot controlled
     items. The lot can not be status controlled, that will be in the next
     insert the lot number is the combo of lot and sublot
  */
  /*
  v_sql_stmt := 'INSERT into msc_st_supplies ('
    || ' plan_id,'
    || ' inventory_item_id,'
    || ' organization_id,'
    || ' sr_instance_id,'
    || ' new_schedule_date,'
    || ' order_type,'
    || ' lot_number,'
    || ' expiration_date,'
    || ' firm_planned_type,'
    || ' deleted_flag,'
    || ' subinventory_code,' *//* Added new column subinventory Code */
/*    || ' new_order_quantity)'
    || ' SELECT'
    || ' -1,'
    || ' i.aps_item_id,'
    || ' i.organization_id,'
    || ' :pinstance_id,'
    || ' :prun_date,'
    || ' 18,'                        *//* onhand inventory value */
/*    || ' substrb(l.lot_no||DECODE(l.sublot_no, NULL,NULL ,:pdelimiter || '
    || ' l.sublot_no),1,30),'
    || ' l.expire_date,'
    || ' 2,'
    || ' 2,'
    || ' s.whse_code,'  *//* Populating subinventory with whse code B1172875 */
/*    || ' s.loct_onhand'
    || ' FROM'
    || ' ic_loct_inv'||pdblink||' s,'
    || ' ic_lots_mst'||pdblink||' l,'
    || ' ic_item_mst'||pdblink||' m,'
    || ' (select distinct aps_item_id, item_id, whse_code, organization_id, '
    || 'lot_control from gmp_item_aps'||pdblink||') i'
    || ' WHERE'
    || '     s.item_id = i.item_id'
    || ' and s.item_id = m.item_id'
    || ' and s.whse_code = i.whse_code'
    || ' and i.lot_control = 1'
    || ' and m.status_ctl = 0'
    || ' and s.lot_id = l.lot_id'
    || ' and s.lot_id > 0'
    || ' and l.delete_mark = 0'
    || ' and s.loct_onhand <> 0';

  EXECUTE IMMEDIATE v_sql_stmt USING pinstance_id, prun_date, pdelimiter;
*/
  /* Get the onhand balances for items that are lot and status controlled. The
     balances come from the location inventory table but the status must be
     nettable on the lots.
     B3177516 Rajesh D. Patangya  05-Oct-2003
     PPLT Logical change:
	     If Hold release date is null then
	          new schedule date = prun_date;
	          new_dock_date=prun_date;
	          order type = 18;
	     Else
	          new schedule date = hold release date ;
	          new_dock_date=prun_date;
	          order type = 8
	     End if;
  */

  /* B2623374 -- Rajesh Patangya  PORT BUG FOR 2446925 (OM ATP CHECK TO
     RECOGNIZE THE ORDER PROCESSING FLAG) */
/*
  v_sql_stmt := 'INSERT into msc_st_supplies ('
    || ' plan_id,'
    || ' inventory_item_id,'
    || ' organization_id,'
    || ' sr_instance_id,'
    || ' new_schedule_date,'
    || ' new_dock_date,'
    || ' order_type,'
    || ' lot_number,'
    || ' expiration_date,'
    || ' firm_planned_type,'
    || ' deleted_flag,'
    || ' subinventory_code,'    */ /* added new column sub inventory code */
/*    || ' new_order_quantity,'
    || ' NON_NETTABLE_QTY)' *//* (OM ATP CHECK TO RECOGNIZE THE ORDER PROCESSING FLAG)*/
/*    || ' SELECT'
    || ' -1,'
    || ' i.aps_item_id,'
    || ' i.organization_id,'
    || ' :pinstance_id,'
    || ' DECODE(c.ic_hold_date,NULL,:prun_date,c.ic_hold_date),'
    || ' :prun_date,'
    || ' DECODE(c.ic_hold_date,NULL,18,8),'   *//* onhand inventory value */
/*    || ' substrb(l.lot_no||DECODE(l.sublot_no, NULL,NULL ,:pdelimiter || '
    || ' l.sublot_no),1,30),'
    || ' l.expire_date,'
    || ' 2,'
    || ' 2,'
    || ' s.whse_code,'  *//* Populating subinventory code with whse code B1172875 */
/*    || ' s.loct_onhand, '
    || ' decode(t.order_proc_ind,0,s.loct_onhand,0)'
    || ' FROM'
    || ' ic_loct_inv'||pdblink||' s,'
    || ' ic_lots_mst'||pdblink||' l,'
    || ' ic_item_mst'||pdblink||' m,'
    || ' (select distinct aps_item_id, item_id, whse_code, organization_id, '
    || ' lot_control from gmp_item_aps'||pdblink||') i,'
    || ' ic_lots_sts'||pdblink||' t,'
    || ' ic_lots_cpg'||pdblink||' c'
    || ' WHERE'
    || '     s.item_id = i.item_id'
    || ' and s.item_id = m.item_id'
    || ' and s.whse_code = i.whse_code'
    || ' and i.lot_control = 1'
    || ' and s.lot_id = l.lot_id'
    || ' and s.lot_id > 0'
    || ' and l.delete_mark = 0'
    || ' and m.status_ctl = 1'
    || ' and s.lot_status = t.lot_status'
    || ' and t.rejected_ind = 0'
    || ' and t.nettable_ind = 1'
    || ' and s.loct_onhand <> 0'
    || ' and c.item_id (+) = l.item_id'
    || ' and c.lot_id (+) = l.lot_id'
    || ' and c.ic_hold_date (+) > :run_date' ;

  EXECUTE IMMEDIATE v_sql_stmt USING pinstance_id, prun_date, prun_date, pdelimiter,
  prun_date;
*/
/* nsinghi INVCONV End */

  return_status := TRUE;

  EXCEPTION
    WHEN OTHERS THEN
	log_message('Failure occured during the Onhand Balances extract');
	log_message(sqlerrm);
        return_status := FALSE;

END extract_onhand_balances; /* end extract_onhand_balances */

/***********************************************************************
*
*   NAME
*	extract_inv_transfer_demands
*
*   DESCRIPTION
*	This procedure will insert records into the table msc_st_demands
*       According to APS team (Sam Tupe < prganesh Shah etc.
*        The inventory transfer demand is similar to Internal Sales Order
*        demand hence should be added to each of the demand schedule
*        The specifics are
*        demand_type = 6
*        origination_type = 6
*        disposition_id = same transfer_id This should match with the
*                        corresponding transaction_id of the supply created
*                        by the same transfer
*       demand_schedule_name =  OPM specific demand_schedule name - The
*              MDS names used in forecast/SO extraction
*   HISTORY
* 	25-Jan-2003 B2756431
*         Note : Old procedure extract_inv_transfers is now removed
*                and replaced with these two new procedures
************************************************************************/
PROCEDURE extract_inv_transfer_demands(
  pdblink        IN  VARCHAR2,
  pinstance_id   IN  PLS_INTEGER,
  prun_date      IN  DATE,
  pdelimiter     IN  VARCHAR2,
  pwhse_code     IN  VARCHAR2,
  pdesignator    IN  VARCHAR2,
  return_status  IN OUT NOCOPY BOOLEAN)
AS

  pdoc_type      VARCHAR2(4) ;

BEGIN
  pdoc_type      := 'XFER';

  return_status := TRUE ;

  v_sql_stmt := 'INSERT into msc_st_demands ('
    || '   organization_id,'
    || '   inventory_item_id,'
    || '   sr_instance_id,'
    || '   using_assembly_item_id,'
    || '   using_assembly_demand_date,'
    || '   using_requirement_quantity,'
    || '   demand_type,'
    || '   origination_type,'
    || '   order_number,'
    || '   demand_schedule_name,'
    || '   disposition_id,' /* B2756431 */
    || '   demand_source_type,' /* B2756431 */
    || '   original_system_reference,' /* B2756431  */
    || '   original_system_line_reference,' /* being added for B2756431 */
    || '   deleted_flag)'
    || ' SELECT '
    || '   i.organization_id,'
    || '   i.aps_item_id,'
    || '   :pinstance_id, '
    || '   i.aps_item_id,'
    || '   s.scheduled_release_date,'
    || '   s.release_quantity1,'
    || '   1,'  /* Discrete , other demands types are interpreted as continuous */
    || '   6,'   /* Orig_type should br 6 per Sam Tupe so change from 11 */
    || '   :pdoc_type || :pdelimiter || s.orgn_code ||'
    || '     :pdelimiter2 || s.transfer_no, '
    || '   :pdesignator,'
    || '   s.transfer_id,'
    || '   8,'             /* B2756431 Demand_source_type    */
    || '   s.transfer_id,' /* B2756431 original_system_reference */
    || '   s.transfer_id,' /* B2756431 original_system_line_reference */
    || '   2'
    || ' FROM '
    || '   ic_xfer_mst' ||pdblink|| ' s,'
    || '   (select distinct aps_item_id, item_id, whse_code, organization_id '
    || '     from gmp_item_aps'||pdblink||') i'
    || ' WHERE '
    || '   s.item_id = i.item_id '
    || '   and s.from_warehouse = i.whse_code '
    || '   and s.transfer_status IN (1) '
    || '   and s.from_warehouse = :pwhse_code '
    || '   and s.release_quantity1 <> 0';

  EXECUTE IMMEDIATE v_sql_stmt USING pinstance_id, pdoc_type, pdelimiter, pdelimiter , pdesignator, pwhse_code ;

  EXCEPTION
    WHEN OTHERS THEN
	log_message('Failure occured during the Inventory Transfer extract');
	log_message(sqlerrm);
        return_status := FALSE;

END extract_inv_transfer_demands;/* end extract_inv_transfer_dem */

/***********************************************************************
*
*   NAME
*	Extract_inventory_transfer_supplies
*
*   DESCRIPTION
*	This procedure will insert records into the table msc_st_supplies
*	and msc_st_demands for pending inventory transfers.
*   HISTORY
* 	25-Jan-2003 B1332662  Created New procedure to insert supplies
*         Per discussions with APS team the specifics are
*          Order_type = 2
*          Transaction_id = transafer_id of the transfer in OPM
************************************************************************/
PROCEDURE extract_inv_transfer_supplies(
  pdblink        IN  VARCHAR2,
  pinstance_id   IN  PLS_INTEGER,
  prun_date      IN  DATE,
  pdelimiter     IN  VARCHAR2,
  return_status  IN OUT NOCOPY BOOLEAN)
AS

  pdoc_type      VARCHAR2(4) ;

BEGIN
  pdoc_type      := 'XFER';

  return_status := TRUE ;

  v_sql_stmt := 'INSERT into msc_st_supplies ('
    || ' plan_id,'
    || ' inventory_item_id,'
    || ' organization_id,'
    || ' sr_instance_id,'
    || ' source_sr_instance_id,'
    || ' new_schedule_date,'
    || ' order_type,'
    || ' order_number,'
    || ' lot_number,'
    || ' firm_planned_type,'
    || ' deleted_flag,'
    || ' subinventory_code,'
    || ' transaction_id,'          /* being added for B2756431 */
    || ' disposition_id,'          /* being added for B2756431 */
    || ' po_line_id,'              /* being added for B2756431 */
    || ' source_organization_id,'   /* being added for B2756431 */
    || ' new_order_quantity)'
    || ' SELECT '
    || ' -1,'
    || ' i.aps_item_id,'
    || ' i.organization_id,'
    || ' :pinstance_id, '
    || ' :pinstance_id, '
    || ' s.scheduled_receive_date, '
    || ' 2,'                        /* po requisition value */
    || ' :pdoc_type || :pdelimiter || s.orgn_code ||'
    || '   :pdelimiter2 || s.transfer_no, '
    || ' DECODE(s.lot_id, 0, NULL, '
    || '   substrb(l.lot_no||DECODE(l.sublot_no, NULL,NULL ,:pdelimiter3 || '
    || '   l.sublot_no),1,30)),'
    || ' 2,'
    || ' 2,'
    || ' s.to_warehouse,'
    || ' s.transfer_id,' /* B2756431 transaction_id */
    || ' s.transfer_id,' /* B2756431 disposition_id */
    || ' s.transfer_id,' /* B2756431 po_line_id     */
    || ' w.mtl_organization_id,' /* B2756431 source_organization_id */
    || ' s.release_quantity1'
    || ' FROM '
    || ' ic_xfer_mst' ||pdblink|| ' s,'
    || ' ic_whse_mst' ||pdblink|| ' w,'
    || ' ic_lots_mst'||pdblink||' l,'
    || ' (select distinct aps_item_id, item_id, whse_code, organization_id '
    || '  from gmp_item_aps'||pdblink||') i'
    || ' WHERE '
    || ' s.item_id = i.item_id '
    || ' and s.to_warehouse = i.whse_code '
    || ' and s.from_warehouse = w.whse_code '
    || ' and s.transfer_status IN (1,2) '
    || ' and s.lot_id = l.lot_id'
    || ' and s.item_id = l.item_id'
    || ' and s.release_quantity1 <> 0';


  EXECUTE IMMEDIATE v_sql_stmt USING pinstance_id,pinstance_id, pdoc_type, pdelimiter,
    pdelimiter, pdelimiter;

  EXCEPTION
    WHEN OTHERS THEN
	log_message('Failure occured during the Inventory Transfer supplies ');
	log_message(sqlerrm);
        return_status := FALSE;

END extract_inv_transfer_supplies;/* end extract_inv_transfer_sup */


/***********************************************************************
*
*   NAME
*	 build_designator
*
*   DESCRIPTION
*       This procedure will create a new row in the pl/sql table if one does
*	for the current schedule/whse. The rows will be inserted into the
*	database in the procedure sales_forecast which calls this procedure.
*	A unique designator must be created for each schedule/whse otherwise a
*	number is added to make it unique. If the row exists already the value
*	is returned otherwise the table is added to and the new value is returned
*       in the out parameter
*   HISTORY
* 	M Craig
************************************************************************/
PROCEDURE build_designator(
  poccur       IN  NUMBER,
  pdelimiter   IN  VARCHAR2,
  pdesignator  OUT NOCOPY VARCHAR2)
AS

  temp_designator VARCHAR2(10);
  i               NUMBER;
  j               NUMBER;
  k               NUMBER;
  found           PLS_INTEGER;
  j_char          VARCHAR2(5);

BEGIN
  found := 0 ;
  /*  The default name generation is the first 5 chars of the schedule and the
      four chars of the warehouse
  */
  temp_designator := substrb(sched_dtl_tab(poccur).schedule,1,5) || pdelimiter
                     || sched_dtl_tab(poccur).whse_code;

  pdesignator := NULL;
  found := 0;

  /* if there are existing rows search them for the key values */
  IF desig_count > 0 THEN
  /* {
        loop through the existing designator rows */
    FOR i IN 1..desig_count LOOP
    /* {

      if a row has alreday been inserted for the schedule and warehouse
      use the value from that row and stop the loop
     */
      IF desig_tab(i).schedule = sched_dtl_tab(poccur).schedule and
         desig_tab(i).whse_code = sched_dtl_tab(poccur).whse_code THEN

        pdesignator := desig_tab(i).designator;
        found := 1;
        EXIT;

      END IF;

    /* } */
    END LOOP;

    /* when the schedule and warehouse are not represented we need to find
       a unique name for the designator
    */
    IF found = 0 THEN
    /* { */

      k := 5;
      j := 0;
      j_char := NULL;

      /* the loop will try the default value then change it if necessary and
        until we have exhasted all of the values of 0-99999 (5 chars of numbers)
      */
      LOOP
      /* { */
        temp_designator := j_char || SUBSTR(sched_dtl_tab(poccur).schedule,1,k) ||
                           pdelimiter || sched_dtl_tab(poccur).whse_code;
        /* this loop goes through the current list to see if there is a duplicate
           if found we stop and generate a new value then try again
        */
        FOR i IN 1..desig_count LOOP
        /* { */
          IF desig_tab(i).designator = temp_designator THEN
            EXIT;
          END IF;
          IF i =  desig_count THEN
            found := 1;
            pdesignator := temp_designator;
          END IF;
        /* } */
        END LOOP;

        /* if we found a value or reached the max we stop */
        IF found = 1 or j = 99999 THEN
          EXIT;
        END IF;

        /* to get a unique value we keep taking one char at a time from the
           the schedule leaving the warehouse intact.
        */
        j := j + 1;
        IF j < 10 THEN
          k := 4;
        ELSIF j < 100 THEN
          k := 3;
        ELSIF j < 1000 THEN
          k := 2;
        ELSIF j < 10000 THEN
          k := 1;
        ELSE
          k := 0;
        END IF;

        j_char := TO_CHAR(j);

      /* } */
      END LOOP;


      /* put a new row in for the value that was found */
      IF found = 1 and pdesignator = temp_designator THEN

        desig_count := desig_count + 1;
        desig_tab(desig_count).designator := temp_designator;
        desig_tab(desig_count).schedule := sched_dtl_tab(poccur).schedule;
        desig_tab(desig_count).orgn_code := sched_dtl_tab(poccur).orgn_code;
        desig_tab(desig_count).whse_code := sched_dtl_tab(poccur).whse_code;
        desig_tab(desig_count).organization_id :=
          sched_dtl_tab(poccur).organization_id;

      END IF;

    /* } */
    END IF;

  /* if no rows are in the table yet just put a new one in */
  ELSE

    desig_tab(1).designator := temp_designator;
    desig_tab(1).schedule := sched_dtl_tab(poccur).schedule;
    desig_tab(1).orgn_code := sched_dtl_tab(poccur).orgn_code;
    desig_tab(1).whse_code := sched_dtl_tab(poccur).whse_code;
    desig_tab(1).organization_id := sched_dtl_tab(poccur).organization_id;
    pdesignator := temp_designator;
    desig_count := 1;

  /* } */
  END IF;

END build_designator;

/***********************************************************************
*
*   NAME
*	 sales_forecast_api
*
*   DESCRIPTION
*     This procedure is a wrapper for the preexisting sales_forecast procedure.
*     This version is set up with the proper parameters to be called as from the
*     concurrent manager.  In addition, the main difference is the table into
*     which demands are inserted.  The standard procedure inserts into
*     msc_st_demands.
*     This new procedure inserts into gmp_demands_api. The difference between
*     the two tables is the addition of a schedule_id column in
*     gmp_demands_api.  Also, this version of sales_forecast begins by
*     truncating gmp_demands_api and leaves it populated after
*     it completes. By contrast, msc_st_demands (which is an APS staging table)
*     is immediately truncated after APS reads its data. This difference allows
*     gmp_demands_api to be a general purpose version of msc_st_demands.
*
*   HISTORY
* 	P. Dong
* 	09/14/01 - Created
*       12/21/01 - Replaced TRUNCATE with DELETE
************************************************************************/
PROCEDURE sales_forecast_api(
  errbuf         OUT NOCOPY VARCHAR2,
  retcode        OUT NOCOPY VARCHAR2,
  p_cp_enabled   IN BOOLEAN ,
  p_run_date     IN DATE )
AS
  lv_cp_enabled  BOOLEAN;
BEGIN

  lv_cp_enabled := p_cp_enabled;

  gmp_bom_routing_pkg.extract_items(
    at_apps_link => NULL,
    instance => NULL,
    run_date => p_run_date,
    return_status => lv_cp_enabled  );

  DELETE FROM gmp_demands_api;

  lv_cp_enabled := p_cp_enabled;

  sales_forecast(
    pdblink => NULL,
    pinstance_id => NULL,
    prun_date => p_run_date,
    pdelimiter => '/',
    return_status => lv_cp_enabled,
    api_mode => TRUE);

 errbuf := NULL;
 retcode := NULL;

 EXCEPTION
     WHEN OTHERS THEN
             errbuf := SUBSTRB(SQLERRM,1,100);
             retcode := SQLCODE;

END sales_forecast_api;

/***********************************************************************
*
*   NAME
*	 sales_forecast
*
*   DESCRIPTION
*       This procedure will retrieve all of the sales order lines and forecast
*	details for their respective schedules. The forecast will be consumed
*       and the all of the rows will be written to msc_st_demands. Each demand
*	is applied to an MDS aka designator.
*   HISTORY
* 	M Craig
* 	10/13/99 - Sridhar Added Designator Type column in the insert statement
* 	12/17/99 - Changes made to the insert statement for designators,
*                  changed desig_tab(1).schedule and desig_tab(1).whse_code to
*                  desig_tab(i).schedule and desig_tab(i).whse_code
* 	04/01/00 - Code Fix for Bug# 1137597.
* 	07/01/00 - Code Fix for Error in Designators Insert
*
*       02-MAY-2002 Re-engineered By : Abhay Satpute, Rajesh Patangya
*              Brief Logic of the new code
*                  Fetch the following data into PL/SQL tables
*                       a. Distinct schd/item/whse combinations
*                       b. Sales order details
*                       c. Forecast details
*                       d. Schedule forecast associations
*               For each item combination loop through and
*                  For each change of schedule change mark reuqired
*                  forecast rows as well note down the stock and ord ind.
*                  For each item insert sales orders, unconsumed forecast
*                  or the forecast , based on the indicators
*     P Dong
*     09/14/01 - Added api_mode to pass to insert_demands
*
*   Navin   21-APR-2003 B3577871 ST:OSFME2: collections failing in planning data pull.
*                                Added handling of NO_DATA_FOUND Exception.
*                                And return the return_status as TRUE.
****************************************************************************/

PROCEDURE sales_forecast( pdblink        IN  VARCHAR2,
			  pinstance_id   IN  PLS_INTEGER,
			  prun_date      IN  DATE,
			  pdelimiter     IN  VARCHAR2,
			  return_status  IN  OUT NOCOPY BOOLEAN,
			  api_mode       IN  BOOLEAN)

AS

    TYPE gmp_cursor_typ IS REF CURSOR;
    cur_gmp_schd_items     gmp_cursor_typ;
    cur_fcst_dtl           gmp_cursor_typ;
    cur_sales_dtl          gmp_cursor_typ;
    cur_schd_fcst          gmp_cursor_typ;

    so_ind		BOOLEAN ;
    fcst_ind		BOOLEAN ;
    log_mesg            VARCHAR2(100) ;
    i			NUMBER ;
    j			NUMBER ;
    old_schedule_id	NUMBER ;
    item_count		NUMBER ;
    fcst_count		NUMBER ;
    so_count		NUMBER ;
    schd_fcst_cnt	NUMBER ;
    local_ret_status    BOOLEAN ;

BEGIN
    g_delimiter         := '/';
    so_ind		:= FALSE ;
    fcst_ind		:= FALSE ;
    log_mesg            := NULL;
    i			:= 0;
    j			:= 0;
    old_schedule_id	:= 0 ;
    item_count		:= 1;
    fcst_count		:= 1;
    so_count		:= 1;
    schd_fcst_cnt	:= 1;

  gitem_size		:= 0;
  gfcst_size		:= 0;
  gso_size		:= 0;
  gschd_fcst_size	:= 0;

  gfcst_cnt		:= 0;
  gso_cnt		:= 0;
  gschd_fcst_cnt	:= 0;
  g_item_tbl_position	:= 0;
  local_ret_status      := return_status ;

  log_message('Start gmp_aps_ds_pull.sales forecast');
  time_stamp;

  IF return_status THEN
    v_cp_enabled := TRUE;
  ELSE
    v_cp_enabled := FALSE;
  END IF;
   g_delimiter		:= pdelimiter ;
   g_instance_id	:= pinstance_id ;

IF api_mode THEN
  /* If forecast and sales order select queries have joins with gmp_item_aps
     we need to select only schedules and warehouses here
     ORDERED By Schedule , Aps_Item, Organization_id(Warehouse) */

        /* Extract Schedule Details */
        v_item_sql_stmt := 'SELECT DISTINCT'
         || ' h.schedule,'
         || ' h.schedule_id,'
         || ' h.order_ind,'
         || ' h.stock_ind,'
         || ' a.whse_code,'
         || ' d.orgn_code,'
         || ' a.organization_id, '
         || ' a.aps_item_id inventory_item_id'
         || ' FROM'
         || '    ps_schd_hdr'||pdblink||' h,'
         || '    ps_schd_dtl'||pdblink||' d,'
         || '    gmp_item_aps'||pdblink||' a'
         || ' WHERE'
         || ' h.schedule_id = d.schedule_id'
         || ' and d.orgn_code = a.plant_code'
         || ' and h.active_ind = 1'
         || ' and a.replen_ind = 1'
         || ' and (h.order_ind = 1 or h.stock_ind = 1)'
         || ' and h.delete_mark = 0'
         || ' and a.item_id > 0 '
         || ' ORDER BY'
         || ' h.schedule_id ASC,'
         || ' a.aps_item_id, '
         || ' a.organization_id ' ;

   -- B2596464, Order changed for inv_item and organization_id
   -- B2973249, undershipped or overshipped sales orders have shipped_qty
   -- populated by OM and as per APS this lines can not be selected, as OM
   -- split original line and keep the open line without any shipped qty.
        /* Extract Sales Order */
        v_sales_sql_stmt := 'SELECT '
          || ' msi.inventory_item_id, '
          || ' msi.organization_id, '
          || ' h.orgn_code, '
          || ' h.order_no, '
          || ' d.line_id,  '
          || ' d.net_price, '
          || ' d.sched_shipdate, '
          || ' d.requested_shipdate, '      /* B2971996 */
          || ' (sum(t.trans_qty) * -1) trans_qty '
          || ' FROM '
          || ' mtl_system_items'||pdblink||' msi, '
          || ' ic_item_mst'||pdblink||' iim,'
          || ' ic_whse_mst'||pdblink||' wm, '
          || ' op_ordr_hdr'||pdblink||' h, '
          || ' op_ordr_dtl'||pdblink||' d, '
          || ' ic_tran_pnd'||pdblink||' t '
          || ' WHERE '
          || '     msi.organization_id = wm.mtl_organization_id '
          || ' AND msi.segment1 = iim.item_no '
          || ' and wm.delete_mark = 0 '
          || ' and h.order_id = d.order_id '
          || ' and h.order_status = 0 '
          || ' and h.delete_mark = 0 '
          || ' and h.order_id = t.doc_id '
          || ' and d.line_status >= 0 '
          || ' and d.line_status < 20 '
          || ' and h.from_whse = wm.whse_code '
          || ' and t.line_id = d.line_id '
          || ' and t.item_id = d.item_id  '
          || ' and iim.item_id = t.item_id  '
          || ' and iim.delete_mark = 0 '
          || ' AND iim.inactive_ind = 0 '
          || ' and t.trans_qty <> 0 '
          || ' and t.completed_ind = 0 '
          || ' and t.delete_mark = 0 '
          || ' and t.doc_type = :popso '
          || ' GROUP BY  '
          || ' msi.inventory_item_id, '
          || ' msi.organization_id, '
          || ' h.orgn_code, '
          || ' h.order_no, '
          || ' d.line_id,  '
          || ' d.net_price, '
          || ' d.sched_shipdate, '
          || ' d.requested_shipdate '    /* B2971996 */
          || ' UNION ALL '
          || ' SELECT '
          || ' items.inventory_item_id, '
          || ' items.organization_id, '
          || ' org.organization_code, '
          || ' TO_CHAR(hdr.order_number), '
          || ' TO_NUMBER(NULL), '
          || ' TO_NUMBER(NULL), '
          || ' mtl.requirement_date, '
          || ' dtl.request_date, '      /* B2971996 */
          || ' mtl.primary_uom_quantity '
          || ' FROM '
          || '     mtl_demand_omoe'||pdblink||' mtl, '
          || '     mtl_system_items'||pdblink||' items, '
          || '     oe_order_headers_all'||pdblink||' hdr, '
          || '     oe_order_lines_all'||pdblink||' dtl, '
          || '     mtl_parameters'||pdblink||' org '
          || ' WHERE '
          || '     items.organization_id   = mtl.organization_id  '
          || ' and items.inventory_item_id = mtl.inventory_item_id '
          || ' and NVL(mtl.completed_quantity,0) = 0 '
          || ' and mtl.open_flag = ' || '''Y'''
          || ' and mtl.available_to_mrp = 1 '
          || ' and mtl.parent_demand_id is NULL '
          || ' and mtl.demand_source_type IN (2,8) '
          || ' and mtl.demand_id = dtl.line_id '
          || ' and dtl.header_id = hdr.header_id '
        -- B2743626, Changed the join to take process sales order (OMSO)
          || ' and dtl.ship_from_org_id = org.organization_id  '
          || ' and org.process_enabled_flag = ' || '''Y'''
          || ' and NOT EXISTS  '
          || '     (SELECT 1 '
          || '        FROM so_lines_all'||pdblink||' sl,'
          || '          so_lines_all'||pdblink||' slp,'
          || '          mtl_demand_omoe'||pdblink||' dem'
          || '      WHERE '
          || '           slp.line_id(+) = nvl(sl.parent_line_id,sl.line_id) '
          || '        and to_number(dem.demand_source_line) = sl.line_id(+) '
          || '        and dem.demand_source_type in (2,8) '
          || '        and sl.end_item_unit_number IS NULL '
          || '        and slp.end_item_unit_number IS NULL '
          || '        and dem.demand_id = mtl.demand_id '
          || '        and items.effectivity_control = 2) '
          || ' ORDER BY 1,2,7 DESC ' ;

       /* Extract Forecast details */
        v_forecast_sql_stmt := 'SELECT '
          || ' msi.inventory_item_id, '
          || ' msi.organization_id, '
          || ' h.forecast_id, '
          || ' h.forecast, '
          || ' d.orgn_code, '
          || ' d.trans_date, '
          || ' (sum(d.trans_qty * -1) ) trans_qty, '
          || ' (sum(d.trans_qty * -1) ) consumed_qty ,'
          || ' 0 use_fcst_flag '
          || ' FROM '
          || ' mtl_system_items'||pdblink||' msi, '
          || ' ic_item_mst'||pdblink||' iim, '
          || ' ic_whse_mst'||pdblink||' wm, '
          || ' fc_fcst_hdr'||pdblink||' h, '
          || ' fc_fcst_dtl'||pdblink||' d '
          || ' WHERE '
          || '     msi.organization_id = wm.mtl_organization_id '
          || ' and msi.segment1 = iim.item_no '
          || ' and wm.delete_mark = 0 '
          || ' and h.forecast_id = d.forecast_id '
          || ' and d.forecast_id > 0  '
          || ' and d.item_id = iim.item_id '
          || ' and d.whse_code = wm.whse_code '
          || ' and d.orgn_code = wm.orgn_code '
          || ' and h.delete_mark = 0 '
          || ' and d.delete_mark = 0 '
          || ' and d.trans_qty <> 0 '
          || ' and d.trans_date >=  sysdate '
          || ' and EXISTS (SELECT 1 FROM '
          || '                      ps_schd_for'||pdblink||' sf, '
          || '                      ps_schd_hdr'||pdblink||' sh  '
          || '             WHERE sh.schedule_id = sf.schedule_id '
          || '               and sh.delete_mark = 0 '
          || '               and sh.active_ind = 1 '
          || '               and sf.forecast_id = h.forecast_id) '
          || ' GROUP BY '
          || ' msi.inventory_item_id, '
          || ' msi.organization_id, '
          || ' h.forecast, '
          || ' h.forecast_id, '
          || ' d.orgn_code, '
          || ' d.trans_date '
          || ' ORDER BY msi.inventory_item_id,msi.organization_id, '
          || ' d.trans_date DESC ' ;

       /* Extract Schedule Forecast Association SQL selection */
        v_association_sql_stmt := 'SELECT '
          || ' schedule_id, forecast_id '
          || ' from ps_schd_for'||pdblink
          || ' ORDER BY 1,2 ' ;

    /* Start Fetching the schedule, forecast, sales order and association
       data for above queries */

    OPEN cur_gmp_schd_items FOR v_item_sql_stmt;
    LOOP
      FETCH cur_gmp_schd_items INTO sched_dtl_tab(item_count);
      EXIT WHEN cur_gmp_schd_items%NOTFOUND;
      item_count := item_count + 1;
    END LOOP;
    CLOSE cur_gmp_schd_items;
    gitem_size := item_count -1 ;
    time_stamp ;
    log_message('Schedule Items size is = ' || to_char(gitem_size)) ;

    OPEN cur_fcst_dtl FOR v_forecast_sql_stmt;
    LOOP
      FETCH cur_fcst_dtl INTO fcst_dtl_tab(fcst_count);
      EXIT WHEN cur_fcst_dtl%NOTFOUND;
      fcst_count := fcst_count + 1;
    END LOOP;
    CLOSE cur_fcst_dtl ;
    gfcst_size := fcst_count  -1 ;
    time_stamp ;
    log_message('Fcst size is = '|| to_char(gfcst_size) );

    OPEN cur_sales_dtl FOR v_sales_sql_stmt USING v_doc_opso;
    LOOP
      FETCH cur_sales_dtl INTO sales_dtl_tab(so_count);
      EXIT WHEN cur_sales_dtl%NOTFOUND;
      so_count := so_count + 1;
    END LOOP;
    CLOSE cur_sales_dtl ;
    gso_size := so_count  -1 ;
    time_stamp ;
    log_message ('SO size is = '||to_char(gso_size));

    OPEN cur_schd_fcst FOR v_association_sql_stmt;
    LOOP
      FETCH cur_schd_fcst INTO SCHD_FCST_DTL_TAB(schd_fcst_cnt);
      EXIT WHEN cur_schd_fcst%NOTFOUND;
      schd_fcst_cnt := schd_fcst_cnt + 1;
    END LOOP;
    CLOSE cur_schd_fcst ;
    gschd_fcst_size := schd_fcst_cnt -1 ;
    time_stamp ;
    log_message('Schedule Forecast Assoc size is ='||to_char(gschd_fcst_size));

     gschd_fcst_cnt := 1;
     so_ind 	:= FALSE ;
     fcst_ind	:= FALSE ;

    FOR i IN 1..gitem_size LOOP
    g_item_tbl_position := i ;
    IF old_schedule_id <> sched_dtl_tab(i).schedule_id THEN
	-- Keep commiting the data to avoid Rollback segment growing problem
        COMMIT ;
	time_stamp ;
	  gfcst_cnt      := 1 ;
	  gso_cnt        := 1 ;
     	  so_ind 	:= FALSE ;
     	  fcst_ind	:= FALSE ;

	  IF sched_dtl_tab(i).order_ind = 1 THEN
		so_ind := TRUE ;
	  END IF;
	  IF sched_dtl_tab(i).stock_ind = 1 THEN
		fcst_ind := TRUE ;
	  END IF;

        /* If there is no forecast associated to current schedule
           then set FCST_IND = FALSE */
	IF sched_dtl_tab(i).stock_ind = 1 AND
          NOT (associate_forecasts(gschd_fcst_cnt,sched_dtl_tab(i).schedule_id))
        THEN
		fcst_ind := FALSE;
	/* Note that we are not Dis-associating the forecasts detail
	  rows when stock_ind is turned OFF. Make sure that the
	  forecast table is not used at all in such cases */
	END IF ;   /* Stock Indicator  */

       old_schedule_id := sched_dtl_tab(i).schedule_id ;
    END IF;  /* Schedule ID match */

      -- If both stock_ind and order_ind are 0 , we should simply continue to
      -- the next record , the easiest method may be <<goto>>

       IF (fcst_ind) THEN
          IF (so_ind) THEN
              consume_forecast(sched_dtl_tab(i).inventory_item_id,
                               sched_dtl_tab(i).organization_id,api_mode) ;
           ELSE
    	       write_forecast(gfcst_cnt,sched_dtl_tab(i).inventory_item_id,
                              sched_dtl_tab(i).organization_id,api_mode ) ;
	   END IF;
       ELSE
          IF (so_ind)  THEN
    		write_so(gso_cnt,sched_dtl_tab(i).inventory_item_id,
                          sched_dtl_tab(i).organization_id,api_mode ) ;
 	   END IF;
       END IF;

    END LOOP ;   /* Main Loop for Schedule, item, Warehouse */

    /* Bug 2756431 Moved the call to this function here per thisbug */
    /* the transfer demands and supplies need to be put under EACH of the
      demand schedules - Note that the supplies should NOT be replicated */
    FOR i IN 1..desig_tab.COUNT LOOP
      extract_inv_transfer_demands(pdblink, pinstance_id, prun_date,
      pdelimiter, desig_tab(i).whse_code,desig_tab(i).designator,
      local_ret_status);
    END LOOP ;

    return_status := local_ret_status ;

    Insert_Designator;

    log_message('End of gmp_aps_ds_pull.sales forecast') ;
    time_stamp ;
    return_status := TRUE;
ELSE
  extract_forecasts( pdblink       ,
                          pinstance_id   ,
                          prun_date      ,
                          pdelimiter    ,
                          return_status  );

END IF ; -- if NOT api_mode
  EXCEPTION
    WHEN NO_DATA_FOUND THEN /* B3577871 */
      log_message(' NO_DATA_FOUND exception raised in Procedure: Gmp_aps_ds_pull.Sales_forecast ' );
      return_status := TRUE;

    WHEN OTHERS THEN
	log_message('Failure occured during the Sales_Forecast extract');
	log_message(sqlerrm);
        return_status := FALSE;
END sales_forecast;

/************************************************************************
*   NAME
*	extract_forecasts
*
*   DESCRIPTION
*
*
*
*   HISTORY
*       Created By : Abhay Satpute
*		24-Oct-2003 Chnaged origincation_type to 29
************************************************************************/
PROCEDURE extract_forecasts ( pdblink        IN  VARCHAR2,
                          pinstance_id   IN  PLS_INTEGER,
                          prun_date      IN  DATE,
                          pdelimiter     IN  VARCHAR2,
                          return_status  IN  OUT NOCOPY BOOLEAN)
IS

TYPE gmp_cursor_typ IS REF CURSOR;
fcst_hdr   	gmp_cursor_typ;
cur_fcst_dtl   	gmp_cursor_typ;

TYPE fcst_hdr_rec IS RECORD (
fcst_id 		PLS_INTEGER,
orig_forecast 		VARCHAR2(16),
fcst_name 		VARCHAR2(10),
fcst_set  		VARCHAR2(10),
desgn_ind 		PLS_INTEGER,
consumption_ind		NUMBER,
backward_time_fence	NUMBER,
forward_time_fence	NUMBER
);
TYPE fcst_dtl_rec_typ IS RECORD
   (
    inventory_item_id   PLS_INTEGER,
    organization_id     PLS_INTEGER,
    forecast_id         PLS_INTEGER,
    line_id             PLS_INTEGER,
    forecast            VARCHAR2(16),
    forecast_set        VARCHAR2(10),
    trans_date          DATE,
    orgn_code           VARCHAR2(4),
    trans_qty           NUMBER,
    use_fcst_flag       NUMBER
  );
fcst_dtl_rec fcst_dtl_rec_typ ;

TYPE fcst_hdr_tab_typ IS TABLE OF fcst_hdr_rec
INDEX BY BINARY_INTEGER ;

fcst_hdr_tbl fcst_hdr_tab_typ ;

cnt             		PLS_INTEGER := 0 ;
l_cnt           		PLS_INTEGER := 1 ;
curr_cnt        		PLS_INTEGER := 0 ;
temp_name       		VARCHAR2(10) := NULL ;
i               		PLS_INTEGER := 1 ;
j               		PLS_INTEGER := 10 ;
k               		PLS_INTEGER := 0;
x 				PLS_INTEGER := 1;
duplicate_found 		BOOLEAN  := FALSE ;
prev_org_id  			PLS_INTEGER := 0 ;
prev_fcst_id	  		PLS_INTEGER := 0 ;
prev_fcst_set			VARCHAR2(10);
prev_fcst    			VARCHAR2(10);
write_fcst			BOOLEAN ;
write_fcst_set			BOOLEAN ;
fcst_locn			PLS_INTEGER ;

l_design_stmt   		VARCHAR2(2000) ;
l_fcst_stmt   			VARCHAR2(2000) ;
l_demands_stmt 			VARCHAR2(2000) ;
l_insert_set_stmt 		VARCHAR2(2000);

BEGIN

d_index  := 0 ;
i_index  := 0 ;
prev_fcst_set := '-1' ;
prev_fcst := '-1';

    /* populate the org_string */
    IF gmp_calendar_pkg.org_string(pinstance_id) THEN
        NULL ;
     ELSE
        RAISE invalid_string_value  ;
     END IF;

l_fcst_stmt := 'SELECT '
          || ' msi.inventory_item_id, '
          || ' msi.organization_id, '
          || ' h.forecast_id, '
          || ' d.line_id, '
          || ' h.forecast, '
          || ' h.forecast_set  FSET , '
          || ' d.trans_date, '
          || ' d.orgn_code, '
          || ' (d.trans_qty * -1)  trans_qty, '
          || ' 0 use_fcst_flag '
          || ' FROM '
          || ' mtl_system_items'||pdblink||' msi, '
          || ' ic_item_mst'||pdblink||' iim, '
          || ' ic_whse_mst'||pdblink||' wm, '
          || ' fc_fcst_hdr'||pdblink||' h, '
          || ' fc_fcst_dtl'||pdblink||' d '
          || ' WHERE '
          || '     msi.organization_id = wm.mtl_organization_id ' ;

        IF gmp_calendar_pkg.g_in_str_org  IS NOT NULL THEN
        l_fcst_stmt := l_fcst_stmt
          || ' and msi.organization_id ' || gmp_calendar_pkg.g_in_str_org ;
        END IF;

        l_fcst_stmt := l_fcst_stmt
          || ' and msi.segment1 = iim.item_no '
          || ' and wm.delete_mark = 0 '
          || ' and h.forecast_id = d.forecast_id '
          || ' and d.forecast_id > 0  '
          || ' and d.item_id = iim.item_id '
          || ' and d.whse_code = wm.whse_code '
          || ' and d.orgn_code = wm.orgn_code '
          || ' and h.forecast_set is NOT NULL '
          || ' and h.delete_mark = 0 '
          || ' and d.delete_mark = 0 '
          || ' and d.trans_qty <> 0 '
          || ' ORDER BY wm.mtl_organization_id ,FSET DESC,h.forecast_id ' ;

l_insert_set_stmt  :=
        ' INSERT INTO msc_st_designators ( '
      ||' designator,forecast_set, organization_id, sr_instance_id, '
      ||' description, mps_relief, inventory_atp_flag, '
      ||' designator_type,disable_date,consume_forecast, '
      ||' update_type,backward_update_time_fence,forward_update_time_fence, '
      ||' bucket_type,deleted_flag,refresh_id ) '
      ||' VALUES '
      ||' ( :p1, :p2, :p3,:p4, '
      ||'   :p5, :p6, :p7, '
      ||'   :p8, :p9, :p10, '
      ||'   :p11, :p12, :p13, '
      ||'   :p14,:p15,:p16 ) ';

l_demands_stmt  :=
      ' INSERT INTO msc_st_demands ( '
    ||' organization_id, inventory_item_id, sr_instance_id, '
    ||' using_assembly_item_id, using_assembly_demand_date, '
    ||' using_requirement_quantity,demand_class,bucket_type, '
    ||' demand_type, origination_type, wip_entity_id, '
    ||' demand_schedule_name,forecast_designator, order_number,'
    ||' wip_entity_name,sales_order_line_id, selling_price, deleted_flag ) '
    ||' VALUES '
    ||' ( :p1, :p2, :p3,  '
    ||'   :p4, :p5, :p6, '
    ||'   :p7, :p8, :p9, '
    ||'   :p10,:p11,:p12, '
    ||'   :p13,:p14,:p15, '
    ||'   :p16,:p17,:p18 )' ;

-- ===+++++++====++++ build designator++++=======++++=======
l_design_stmt := 'SELECT '||
' forecast_id, '||
' forecast, '||
' substr(forecast,1,10) DESGN, '||
' nvl(forecast_set ,substr(forecast,1,10)) FSET,  '||
' 1 DESGN_IND ,' ||
' consumption_ind, '||
' backward_time_fence, '||
' forward_time_fence '||
' FROM fc_fcst_hdr'||pdbLink ||
' WHERE delete_mark = 0 '||
' UNION ALL '||
-- Add forecast_sets to the list
' SELECT '||
' -1 , '||
' min(forecast), '||
' forecast_set DESGN , '||
' to_char(NULL) FSET,  '||
' 3 DESGN_IND, ' ||
' to_number(NULL), '||
' to_number(NULL), '||
' to_number(NULL) '||
' FROM fc_fcst_hdr'||pdblink ||
' WHERE delete_mark = 0 '||
' AND forecast_set is NOT NULL '||
' GROUP BY forecast_set '  ||
' ORDER BY FSET, 1 DESC , DESGN_IND ' ;
-- Add fabricated forecast-set to the list
/* Per discussions with Sam Tupe Forecast set name is NOT allowed to be changed
 Hence we should NOT collect the forecasts that do NOT have a forecast set */
/*
' UNION ALL '||
' SELECT '||
' -1, '||
' forecast, '||
' substr(forecast,1,10) DESGN_IND , '||
' to_char(NULL) FSET, '||
' 2 DESGN_IND,  '||
' to_number(NULL), '||
' to_number(NULL), '||
' to_number(NULL) '||
' FROM fc_fcst_hdr'||pdblink ||
' WHERE delete_mark = 0 '||
' AND forecast_set is NULL '||
--   With these changes some logic in designator generation has become redundant
*/

OPEN  fcst_hdr for l_design_stmt ;
LOOP
FETCH fcst_hdr INTO fcst_hdr_tbl(l_cnt);
EXIT WHEN fcst_hdr%NOTFOUND ;
l_cnt := l_cnt + 1 ;
END LOOP ;
CLOSE fcst_hdr ;
-- ===================== Logic ==============================
LOOP
EXIT  WHEN cnt + 1 > fcst_hdr_tbl.COUNT ;

IF duplicate_found THEN
 cnt := cnt ;
 duplicate_found := FALSE ;
ELSE
 IF temp_name is NOT NULL THEN
 IF (fcst_hdr_tbl(cnt).desgn_ind =  1
	AND fcst_hdr_tbl(cnt).fcst_name <> temp_name )THEN
--  	fcst_hdr_tbl(cnt).fcst_set := temp_name ;
   NULL ;
 ELSIF (fcst_hdr_tbl(cnt).desgn_ind =  3
	AND fcst_hdr_tbl(cnt).fcst_name <> temp_name )THEN
  -- This means we changed a set name
  -- Now change the name in all resords of fcst that used this as set
  FOR y in 1..fcst_hdr_tbl.COUNT
  LOOP
   IF (fcst_hdr_tbl(y).fcst_set = fcst_hdr_tbl(cnt).fcst_name
	AND fcst_hdr_tbl(y).desgn_ind =  1 ) THEN
	fcst_hdr_tbl(y).fcst_set := temp_name  ;
   END IF ;
  END LOOP;
 ELSIF (fcst_hdr_tbl(cnt).desgn_ind = 2
            AND fcst_hdr_tbl(cnt).fcst_name <> temp_name )THEN
  -- This means we changed a set name that was "generated"
  -- Now change the name in the resord of fcst that used itself as set
  FOR y in 1..fcst_hdr_tbl.COUNT
  LOOP
   IF (fcst_hdr_tbl(y).orig_forecast = fcst_hdr_tbl(cnt).orig_forecast
	AND fcst_hdr_tbl(y).desgn_ind  = 1 )THEN
        fcst_hdr_tbl(y).fcst_set := temp_name  ;
   END IF ;
  END LOOP;
 END IF ; -- desgn_ind check
 fcst_hdr_tbl(cnt).fcst_name := temp_name ;

 END IF ;

 cnt := cnt  + 1 ;
 j := 10 ;
 k := 0 ;
END IF ;

 IF j < 10 THEN
    temp_name := substr(fcst_hdr_tbl(cnt).fcst_name,1,j)||to_char(k) ;
 ELSE
    temp_name := fcst_hdr_tbl(cnt).fcst_name ;
 END IF ;

curr_cnt := cnt ;

i := 1 ;

LOOP
EXIT WHEN i > fcst_hdr_tbl.COUNT ;

IF i <> curr_cnt THEN
-- so that record is not compared to itself
 IF temp_name  = fcst_hdr_tbl(i).fcst_name THEN
   duplicate_found := TRUE ;
   k := k + 1 ;

  IF k < 10 THEN
     j := 9 ;
  ELSIF k < 100 THEN
     j := 8 ;
  ELSIF k < 1000 THEN
     j := 7 ;
  ELSIF k < 10000 THEN
     j := 6 ;
  ELSIF k < 100000 THEN
     j := 5 ;
  END IF ;

  EXIT ;

 END IF ;
END IF ; -- i <> curr_cnt

i := i + 1 ;
END LOOP ;


END LOOP ; -- Outer loop

/*
FOR x in 1..fcst_hdr_tbl.COUNT
LOOP
log_message(fcst_hdr_tbl(x).fcst_id||
		'='||fcst_hdr_tbl(x).orig_forecast ||
		'='||fcst_hdr_tbl(x).desgn_ind ||
		'='||fcst_hdr_tbl(x).fcst_name ||
		'='||fcst_hdr_tbl(x).fcst_set ) ;
END LOOP;
*/
-- ===+++++++====++++ build designator++++=======++++=======

    OPEN cur_fcst_dtl FOR l_fcst_stmt;
    LOOP
	write_fcst     := FALSE ;
	write_fcst_set := FALSE ;

	FETCH cur_fcst_dtl INTO fcst_dtl_rec;
	EXIT WHEN cur_fcst_dtl%NOTFOUND;
	IF fcst_dtl_rec.organization_id <> prev_org_id THEN
	  -- Write an entry for forecast
	  write_fcst     := TRUE ;
	  write_fcst_set := TRUE ;
	 prev_org_id := fcst_dtl_rec.organization_id ;
	END IF ;
	  -- also check if the set has changed ,if so write an entry for set
	IF fcst_dtl_rec.forecast_id <> prev_fcst_id THEN
	  write_fcst := TRUE ;
	  -- get designator, forecast_name
	  -- Temporarily putting a code - inefficient
	  FOR i in 1..fcst_hdr_tbl.COUNT
	  LOOP
	    IF fcst_dtl_rec.forecast_id = fcst_hdr_tbl(i).fcst_id THEN
		fcst_locn := i  ;
		EXIT ;
	    END IF ;
          END LOOP ;
	  IF fcst_hdr_tbl(fcst_locn).fcst_set <> prev_fcst_set THEN
	    -- insert set name for currrent org
	    write_fcst_set := TRUE ;
	  END IF ; -- end if for change of fcst_set
	END IF ; -- endif of fcst_is change

	prev_fcst	:= nvl(fcst_hdr_tbl(fcst_locn).fcst_name ,'-2');
	prev_fcst_id := fcst_dtl_rec.forecast_id ;

	IF write_fcst_set THEN

          i_index := i_index + 1 ;
          i_designator(i_index) :=  fcst_hdr_tbl(fcst_locn).fcst_set ;
          i_forecast_set(i_index) :=  to_char(NULL) ;
          i_organization_id(i_index) :=  fcst_dtl_rec.organization_id ;
          i_sr_instance_id(i_index) := pinstance_id ;
          i_description(i_index) :=  fcst_hdr_tbl(fcst_locn).fcst_set ;
          -- mps_relief(i_index) :=  0;  /* mps relief */
          -- inventory_atp_flag(i_index) := 0;  /* inventory atp flag */
          -- designator_type(i_index) := 6;  /* designator type */
          i_disable_date(i_index) := TO_DATE(NULL);  /* disable date */
          i_consume_forecast(i_index) := fcst_hdr_tbl(fcst_locn).consumption_ind ;
          -- update_type(i_index) := 6; /* Update type */
          i_backward_update_time_fence(i_index) :=  fcst_hdr_tbl(fcst_locn).backward_time_fence ;
          i_forward_update_time_fence(i_index) := fcst_hdr_tbl(fcst_locn).forward_time_fence ;
          -- bucket_type(i_index) := 1 ;  /* bucket type */ ;
          -- deleted_flag(i_index) := 2 ;
          -- refresh_id := 0 ; /* Refresh id */

	  prev_fcst_set := fcst_hdr_tbl(fcst_locn).fcst_set ;

	END IF ;

	IF write_fcst THEN

          i_index := i_index + 1 ;
          i_designator(i_index) := fcst_hdr_tbl(fcst_locn).fcst_name ;
          i_forecast_set(i_index) := fcst_hdr_tbl(fcst_locn).fcst_set ;
          i_organization_id(i_index) := fcst_dtl_rec.organization_id ;
          i_sr_instance_id(i_index) := pinstance_id ;
          i_description(i_index) :=  fcst_hdr_tbl(fcst_locn).fcst_name ;
          -- mps_relief(i_index) :=  0;  /* mps relief */
          -- inventory_atp_flag(i_index) := 0;  /* inventory atp flag */
          -- designator_type(i_index) := 6;  /* designator type,For forecast the value will be 6 */
          i_disable_date(i_index) := TO_DATE(NULL);  /* disable date */
          i_consume_forecast(i_index) := fcst_hdr_tbl(fcst_locn).consumption_ind ;
          -- update_type(i_index) := 6; /* Update Type,For Process value will be 6 */
          i_backward_update_time_fence(i_index) :=  fcst_hdr_tbl(fcst_locn).backward_time_fence ;
          i_forward_update_time_fence(i_index) := fcst_hdr_tbl(fcst_locn).forward_time_fence ;
          -- bucket_type(i_index) := 1 ;  /* bucket type */ ;
          -- deleted_flag(i_index) := 2 ;
          -- refresh_id := 0 ; /* Refresh id */

	END IF ;

	  -- and now write the forecast details entry also.
         /* Demands Bulk inserts */
         d_index := d_index + 1 ;
         f_organization_id(d_index) := fcst_dtl_rec.organization_id ;
         f_inventory_item_id(d_index) := fcst_dtl_rec.inventory_item_id ;
         f_sr_instance_id(d_index) :=  pinstance_id ;
         f_assembly_item_id(d_index) := fcst_dtl_rec.inventory_item_id ;
         f_demand_date(d_index) := fcst_dtl_rec.trans_date ;
         f_requirement_quantity(d_index) :=  fcst_dtl_rec.trans_qty ;
         -- demand_class := null_value ;           /* Demand Class  */
         -- bucket_type(d_index) := 1 ;             /* Bucket type */
         -- demand_type(d_index) := 1 ;             /* demand type */
         -- origination_type(d_index) := 29 ;       /* origination type */
         -- wip_entity_id(d_index) := null_value ;  /* wip_entity id */
         -- demand_schedule(d_index) := null_value ; /* demand Schedule name */
	 f_forecast_designator(d_index) :=
                fcst_hdr_tbl(fcst_locn).fcst_name ; /* forecast designator */
         f_order_number(d_index)  := fcst_hdr_tbl(fcst_locn).fcst_name;  /* Order Number */
         -- wip_entity_name(d_index) := null_value ; /* wip entity name */
         f_sales_order_line_id(d_index) := fcst_dtl_rec.line_id ; /* Sales Order line Id */
         -- selling_price(d_index) :=  null_value ;   /* Selling Price */
         -- deleted_flag :=  2 ;

     END LOOP ;
     CLOSE cur_fcst_dtl;

/* ----------------------- Demands Insert --------------------- */
      i := 1 ;
      log_message(f_organization_id.FIRST || ' *forecast*' || f_organization_id.LAST );
      IF f_organization_id.FIRST > 0 THEN
      FORALL i IN f_organization_id.FIRST..f_organization_id.LAST
        INSERT INTO msc_st_demands (
        organization_id,
        inventory_item_id,
        sr_instance_id,
        using_assembly_item_id,
        using_assembly_demand_date,
        using_requirement_quantity,
        demand_class,
        bucket_type,
        demand_type,
        origination_type,
        wip_entity_id,
        demand_schedule_name,
        forecast_designator,
        order_number,
        wip_entity_name,
        sales_order_line_id,
        selling_price,
        deleted_flag )
        VALUES (
        f_organization_id(i),
        f_inventory_item_id(i),
        f_sr_instance_id(i),
        f_assembly_item_id(i),
        f_demand_date(i),
        f_requirement_quantity(i),
        null_value,       /* demand_class  */
        1,                /* bucket_type  */
        1,                /* demand_type  */
        29,               /* origination_type */
        null_value,       /* wip_entity_id    */
        null_value,       /* demand_schedule_name */
        f_forecast_designator(i),
        f_order_number(i),
        null_value,                /* wip_entity_name */
        f_sales_order_line_id(i),
        null_value,                /* selling_price */
        2                          /* deleted_flag */
        ) ;
      END IF ;

/* ----------------------- Designator Insert --------------------- */
      i := 1 ;
      log_message(i_organization_id.FIRST || ' *Designator*' || i_organization_id.LAST );
      IF i_organization_id.FIRST > 0 THEN
      FORALL i IN i_organization_id.FIRST..i_organization_id.LAST
          INSERT INTO msc_st_designators (
          designator,
          forecast_set,
          organization_id,
          sr_instance_id,
          description,
          mps_relief,
          inventory_atp_flag,
          designator_type,
          disable_date,
          consume_forecast,
          update_type,
          backward_update_time_fence,
          forward_update_time_fence,
          bucket_type,
          deleted_flag,
          refresh_id
          )
          VALUES (
          i_designator(i)     ,
          i_forecast_set(i)   ,
          i_organization_id(i),
          i_sr_instance_id(i) ,
          i_description(i)    ,
          0,           /* mps relief */
          0,           /* inventory atp flag  */
          6,           /* designator type,For forecast the value will be 6 */
          i_disable_date(i)    ,
          i_consume_forecast(i),
          6,           /* Update Type,For Process value will be 6 */
          i_backward_update_time_fence(i),
          i_forward_update_time_fence(i) ,
          1,           /* bucket_type */
          2,           /* deleted_flag */
          0            /* refresh_id  */
          ) ;
      END IF ;

      return_status := TRUE ;

EXCEPTION
    WHEN invalid_string_value  THEN
        log_message('Organization string is Invalid ' );
        return_status := FALSE;

	WHEN OTHERS THEN
	log_message('Failure occured during the Forecast_extract');
	log_message(sqlerrm);
        return_status := FALSE;

END extract_forecasts ;


/************************************************************************
*   NAME
*	 Log_message
*
*   DESCRIPTION
*       Put the debug message in log file.
*   HISTORY
*       Created By : Rajesh Patangya
************************************************************************/
PROCEDURE LOG_MESSAGE(pBUFF  IN  VARCHAR2) IS
BEGIN
  IF v_cp_enabled THEN
     IF fnd_global.conc_request_id > 0  THEN
         FND_FILE.PUT_LINE( FND_FILE.LOG, pBUFF);
     ELSE
         null;
     END IF;
  ELSE
    null ;
  END IF;
  EXCEPTION
     WHEN OTHERS THEN
        RETURN;
END LOG_MESSAGE;

/* **************************************************************************
*   NAME
*	 associate_forecasts
*
*   DESCRIPTION
*         For each schedule forecast combination, mark the forecast table
*   HISTORY
*        Created By : Rajesh Patangya
************************************************************************/
FUNCTION associate_forecasts (	pschd_fcst_cnt	IN NUMBER,
      				pschd_id	IN PLS_INTEGER ) return BOOLEAN
IS
   found_fcst 	BOOLEAN := FALSE ;
   schd_cnt	NUMBER := 1 ;
   i       	NUMBER := 1 ;
   f1       	NUMBER := 1 ;
BEGIN
    -- Clean the earlier associations
    FOR f1 in 1..gfcst_size
    LOOP
       fcst_dtl_tab(f1).use_fcst_flag := 0 ;
    END LOOP;

    FOR schd_cnt in pschd_fcst_cnt..gschd_fcst_size
    LOOP
      IF pschd_id > schd_fcst_dtl_tab(schd_cnt).schedule_id THEN
        NULL ;
      ELSIF pschd_id = schd_fcst_dtl_tab(schd_cnt).schedule_id THEN
        FOR i in 1..gfcst_size
        LOOP
           IF fcst_dtl_tab(i).forecast_id =
              schd_fcst_dtl_tab(schd_cnt).forecast_id THEN
                  fcst_dtl_tab(i).use_fcst_flag := 1 ;
                  found_fcst := TRUE ;
           END IF;
        END LOOP;
      ELSE
         /*  pschd_id < schd_fcst_dtl_tab(schd_cnt).schedule_id THEN */
          gschd_fcst_cnt := schd_cnt ;
          EXIT ;
      END IF;
    END LOOP ;
    RETURN found_fcst ;

END associate_forecasts;

/* **************************************************************************
*   NAME
*	 check_forecast
*
*   DESCRIPTION
*    Inventory item, Warehouse combination check, hence reached to the
*    record for further processing
*   HISTORY
*        Created By : Rajesh Patangya
************************************************************************/
FUNCTION check_forecast(pfcst_counter		IN  NUMBER,
  			pinventory_item_id	IN  PLS_INTEGER,
  			porganization_id	IN  PLS_INTEGER) return BOOLEAN
IS
fcst_i        NUMBER := 1 ;
BEGIN
    /*  Loop through the forecast table for the matching inventory_item_id
        and organization_id (Process warehouse)  */

   FOR fcst_i in pfcst_counter..gfcst_size
   LOOP
     IF (fcst_dtl_tab(fcst_i).use_fcst_flag = 1) THEN

        IF fcst_dtl_tab(fcst_i).inventory_item_id > pinventory_item_id THEN
             return FALSE ;
        ELSIF fcst_dtl_tab(fcst_i).inventory_item_id = pinventory_item_id THEN
           IF fcst_dtl_tab(fcst_i).organization_id > porganization_id THEN
             return FALSE ;
           ELSIF fcst_dtl_tab(fcst_i).organization_id = porganization_id THEN
             return TRUE ;
           END IF;
        END IF;

     END IF;   /* Use Flag If   */
   END LOOP;
   -- If no rows were found after looping the whole table, return false
   return FALSE ;

END check_forecast ;

/* **************************************************************************
*   NAME
*	 check_so
*
*   DESCRIPTION
*    Inventory item, Warehouse combination check, hence reached to the
*    record for further processing
*   HISTORY
*        Created By : Rajesh Patangya
************************************************************************/
FUNCTION check_so( pso_counter		IN  NUMBER,
		   pinventory_item_id	IN  PLS_INTEGER,
		   porganization_id	IN  PLS_INTEGER) return BOOLEAN
IS

so_i     NUMBER := 0;
BEGIN
    /*  Loop through the Sales order table for the matching inventroy item_id
        and organization_id(whse)   */

   FOR so_i in pso_counter..gso_size
   LOOP
      IF sales_dtl_tab(so_i).inventory_item_id > pinventory_item_id THEN
           return FALSE ;
      ELSIF sales_dtl_tab(so_i).inventory_item_id = pinventory_item_id THEN
         IF sales_dtl_tab(so_i).organization_id > porganization_id THEN
           return FALSE ;
         ELSIF sales_dtl_tab(so_i).organization_id = porganization_id THEN
           return TRUE ;
         END IF;
      END IF;
   END LOOP ;
   -- If no rows were found after looping the whole table, return false
   return FALSE ;

END check_so ;

/* **************************************************************************
*   NAME
*	 consume_forecast
*
*   DESCRIPTION
*       This procedure will consume the forecast for the values that are
*	are loaded into the sales and forecast pl/sql tables. The occurences
*	are passed in as paramaters. The sales orders that fall on or after
*	a forecast for the same item/whse but before the next forecast for the
*	same will decrease the value of the forecast by the amount of the
* 	sales order line until it is zero.
*   HISTORY
*        Created By : Rajesh Patangya
*     P Dong
*     09/14/01 - Added api_mode to pass to insert_demands
************************************************************************/
PROCEDURE consume_forecast( pinventory_item_id	IN  PLS_INTEGER,
			    porganization_id	IN  PLS_INTEGER,
			    papi_mode	        IN  BOOLEAN )
AS
cfcst_cnt   PLS_INTEGER := 0 ;
cso_cnt     PLS_INTEGER := 0 ;
found_forecast BOOLEAN := FALSE ;
BEGIN
 FOR cfcst_cnt in gfcst_cnt..gfcst_size
 LOOP

  IF (fcst_dtl_tab(cfcst_cnt).use_fcst_flag = 1 )  THEN

   IF fcst_dtl_tab(cfcst_cnt).inventory_item_id = pinventory_item_id AND
        fcst_dtl_tab(cfcst_cnt).organization_id = porganization_id THEN
    found_forecast := TRUE ;     /* B2922488 */
    FOR cso_cnt in gso_cnt..gso_size
    LOOP
     IF fcst_dtl_tab(cfcst_cnt).inventory_item_id =
                     sales_dtl_tab(cso_cnt).inventory_item_id AND
        fcst_dtl_tab(cfcst_cnt).organization_id =
                      sales_dtl_tab(cso_cnt).organization_id THEN

        IF fcst_dtl_tab(cfcst_cnt).trans_date <=
              sales_dtl_tab(cso_cnt).sched_shipdate THEN

	    IF fcst_dtl_tab(cfcst_cnt).consumed_qty > 0 THEN
                 fcst_dtl_tab(cfcst_cnt).consumed_qty :=
                      fcst_dtl_tab(cfcst_cnt).consumed_qty -
                      sales_dtl_tab(cso_cnt).trans_qty ;
            END IF ; /* consumed_qty match */
                 write_this_so(cso_cnt,papi_mode) ;

        ELSE /* The fcst date is greater than so date, therefore write fcst */
            IF fcst_dtl_tab(cfcst_cnt).consumed_qty > 0 THEN
               write_this_fcst (cfcst_cnt,papi_mode);
            -- B2596464, Modified by Rajesh Patangya 26-SEP-2002
            -- Once forecast is written, make the quantity = 0,
            -- so that outside the loop it will not be written again.
               fcst_dtl_tab(cfcst_cnt).consumed_qty := 0 ;
            END IF ;
              EXIT ;
        END IF ; /* trans_date match */

     ELSIF (fcst_dtl_tab(cfcst_cnt).inventory_item_id <
            sales_dtl_tab(cso_cnt).inventory_item_id ) OR
        (   fcst_dtl_tab(cfcst_cnt).inventory_item_id =
            sales_dtl_tab(cso_cnt).inventory_item_id  AND
            fcst_dtl_tab(cfcst_cnt).organization_id <
            sales_dtl_tab(cso_cnt).organization_id
        )  THEN
            EXIT ;
     END IF ;
    END LOOP;  /* SO loop */
      -- After Looping through all SO , if the forecast remains
      -- unconsumed, write it to the table
         IF fcst_dtl_tab(cfcst_cnt).consumed_qty > 0 THEN
                   write_this_fcst (cfcst_cnt,papi_mode);
         END IF ;
    ELSIF
     (fcst_dtl_tab(cfcst_cnt).inventory_item_id > pinventory_item_id) OR
     (fcst_dtl_tab(cfcst_cnt).inventory_item_id = pinventory_item_id AND
     fcst_dtl_tab(cfcst_cnt).organization_id > porganization_id ) THEN
	gfcst_cnt := cfcst_cnt ;
        write_so(gso_cnt,pinventory_item_id,porganization_id,papi_mode);
        EXIT ;
    END IF ;
  END IF ; /* use_fcst_flag */
 END LOOP ;    /* FCST loop */

  IF NOT (found_forecast) THEN
        -- At last, if there is no forecast at all, then you have to write
        -- all the sales orders
        write_so(gso_cnt,pinventory_item_id,porganization_id,papi_mode);
  END IF;

 EXCEPTION
    WHEN OTHERS THEN
        log_message('Failure occured during write_forecast');
        log_message(sqlerrm);
      RAISE;
END consume_forecast ;

/* **************************************************************************
*   NAME
*	 write_forecast
*
*   DESCRIPTION
*     Loop through the forecast table for the matching inventory item_id
*     and organization_id(whse)
*     and insert into the destination table
*     exit when item_id changes after noting down the counter position
*   HISTORY
*        Created By : Rajesh Patangya
*     P Dong
*     09/14/01 - Added api_mode to pass to insert_demands
************************************************************************/
PROCEDURE write_forecast( pfcst_counter   	IN  NUMBER,
  			  pinventory_item_id	IN  PLS_INTEGER,
  			  porganization_id	IN  PLS_INTEGER,
		          papi_mode	        IN BOOLEAN)
AS
fcst_i   PLS_INTEGER := 0 ;

BEGIN
   -- A safety can be installed here
   IF gfcst_size >= pfcst_counter THEN


   FOR fcst_i in pfcst_counter..gfcst_size
   LOOP
     IF (fcst_dtl_tab(fcst_i).use_fcst_flag = 1 ) THEN

        IF fcst_dtl_tab(fcst_i).inventory_item_id > pinventory_item_id THEN
             gfcst_cnt := fcst_i ;
             EXIT ;
        ELSIF fcst_dtl_tab(fcst_i).inventory_item_id = pinventory_item_id THEN
           IF fcst_dtl_tab(fcst_i).organization_id > porganization_id THEN
             gfcst_cnt := fcst_i ;
             EXIT ;
           ELSIF fcst_dtl_tab(fcst_i).organization_id = porganization_id THEN
		IF fcst_dtl_tab(fcst_i).consumed_qty > 0 THEN
                  write_this_fcst(fcst_i,papi_mode) ;
		END IF ;
           END IF;
        END IF;

     END IF;   /* Use Flag If   */
   END LOOP;

   END IF;   /* Safety feature */

 EXCEPTION
    WHEN OTHERS THEN
        log_message('Failure occured during write_forecast');
        log_message(sqlerrm);
      RAISE;
END write_forecast ;

/* **************************************************************************
*   NAME
*	 write_so
*
*   DESCRIPTION
*     Loop through the Sales order table for the matching inventory item_id
*     and organization_id(whse)
*     and insert into the destination table
*     exit when item_id changes after noting down the counter position
*   HISTORY
*        Created By : Rajesh Patangya
*     P Dong
*     09/14/01 - Added api_mode to pass to insert_demands
************************************************************************/
PROCEDURE write_so( pso_counter		IN  NUMBER,
		    pinventory_item_id	IN  PLS_INTEGER,
		    porganization_id	IN  PLS_INTEGER,
		    papi_mode	        IN  BOOLEAN)
AS
so_i      PLS_INTEGER := 0 ;

BEGIN
   -- A safety can be installed here
   IF gso_size >= pso_counter THEN

   FOR so_i in pso_counter..gso_size
   LOOP
      IF sales_dtl_tab(so_i).inventory_item_id > pinventory_item_id THEN
           gso_cnt := so_i ;
           EXIT ;
      ELSIF sales_dtl_tab(so_i).inventory_item_id = pinventory_item_id THEN
         IF sales_dtl_tab(so_i).organization_id > porganization_id THEN
           gso_cnt := so_i ;
           EXIT ;
         ELSIF sales_dtl_tab(so_i).organization_id = porganization_id THEN
           write_this_so(so_i,papi_mode) ;
         END IF;
      END IF;
   END LOOP ;

   END IF;   /* Safety feature */

 EXCEPTION
    WHEN OTHERS THEN
        log_message('Failure occured during write_so');
        log_message(sqlerrm);
      RAISE;
END write_so ;

/* **************************************************************************
*   NAME
*	 write_this_so
*
*   DESCRIPTION
*    Call to build designator to get unique designator,
*    insert sales order into msc_st_demand
*   HISTORY
*        Created By : Rajesh Patangya
*     P Dong
*     09/14/01 - Added api_mode to pass to insert_demands
*     05/21/03 - B2971996 - Populating request_date in msc_st_demands table
************************************************************************/
PROCEDURE write_this_so(pcounter      IN NUMBER,
                        sapi_mode     IN BOOLEAN)
AS
  statement_demands_api  VARCHAR2(3000) := NULL ;
  statement_demands      VARCHAR2(3000) := NULL ;

BEGIN
    g_delimiter  := '/';
    build_designator(g_item_tbl_position, g_delimiter, gcurrent_designator);

IF sapi_mode
THEN
  BEGIN
    statement_demands_api  :=
      ' INSERT INTO gmp_demands_api ( '
    ||'  organization_id, schedule_id, inventory_item_id, demand_date, '
    ||'  demand_quantity, origination_type, doc_id, selling_price ) '
    ||' VALUES '
    ||' ( :p1, :p2, :p3, :p4, '
    ||'   :p5, :p6, :p7, :p8 ) ';

    EXECUTE IMMEDIATE statement_demands_api USING
        sales_dtl_tab(pcounter).organization_id,
        sched_dtl_tab(g_item_tbl_position).schedule_id,
        sales_dtl_tab(pcounter).inventory_item_id,
        sales_dtl_tab(pcounter).sched_shipdate,
        sales_dtl_tab(pcounter).trans_qty,
        6,				/* origination type */
        null_value,				/* wip_entity id */
        sales_dtl_tab(pcounter).net_price  ;

        /* Global vairable Updation to next record */
        /*  B2929759, Rajesh Patangya 28-APR-2003 */
         gso_cnt := pcounter + 1 ;

  EXCEPTION
    WHEN OTHERS THEN
        log_message('Failure occured during the insert into gmp_demands_api');
        log_message(sqlerrm);
      RAISE;
  END;
ELSE
  BEGIN

    statement_demands  :=
      ' INSERT INTO msc_st_demands ( '
    ||' organization_id, inventory_item_id, sr_instance_id, '
    ||' using_assembly_item_id, using_assembly_demand_date, '
    ||' using_requirement_quantity, demand_type, origination_type, '
    ||' wip_entity_id, demand_schedule_name, order_number, '
    ||' wip_entity_name, selling_price,request_date,deleted_flag ) '  /*B2971996*/
    ||' VALUES '
    ||' ( :p1, :p2, :p3,  '
    ||'   :p4, :p5,       '
    ||'   :p6, :p7, :p8 , '
    ||'   :p9, :p10,:p11, '
    ||'   :p12,:p13,:p14,:p15 )' ;

    EXECUTE IMMEDIATE statement_demands USING
	sales_dtl_tab(pcounter).organization_id,
	sales_dtl_tab(pcounter).inventory_item_id,
	g_instance_id,
	sales_dtl_tab(pcounter).inventory_item_id,
	sales_dtl_tab(pcounter).sched_shipdate,
	sales_dtl_tab(pcounter).trans_qty,
	1,				/* demand type */
        6,				/* origination type */
	null_value,			/* wip_entity id */
	gcurrent_designator,
	sales_dtl_tab(pcounter).orgn_code || g_delimiter ||
		sales_dtl_tab(pcounter).order_no,
	null_value,			/* wip entity name */
	sales_dtl_tab(pcounter).net_price,
        sales_dtl_tab(pcounter).request_date,   /* B2971996 */
        2 ;

        /* Global vairable Updation to next record */
        /*  B2929759, Rajesh Patangya 28-APR-2003 */
         gso_cnt := pcounter + 1 ;

 EXCEPTION
    WHEN OTHERS THEN
        log_message('Failure occured during write_this_so');
        log_message(sqlerrm);
      RAISE;
  END;

  END IF;
END write_this_so ;

/* **************************************************************************
*   NAME
*	 write_this_fcst
*
*   DESCRIPTION
*    Call to build designator to get unique designator,
*    insert forecast into msc_st_demand
*   HISTORY
*        Created By : Rajesh Patangya
*     P Dong
*     09/14/01 - Added api_mode to pass to insert_demands
************************************************************************/
PROCEDURE write_this_fcst(pcounter      IN NUMBER,
                          fapi_mode     IN BOOLEAN)
AS

  statement_demands_api   VARCHAR2(3000) := NULL ;
  statement_demands       VARCHAR2(3000) := NULL ;

BEGIN

    g_delimiter  := '/';
    build_designator(g_item_tbl_position, g_delimiter, gcurrent_designator);

IF fapi_mode
THEN
  BEGIN
    statement_demands_api  :=
      ' INSERT INTO gmp_demands_api ( '
    ||'  organization_id, schedule_id, inventory_item_id, demand_date, '
    ||'  demand_quantity, origination_type, doc_id, selling_price ) '
    ||' VALUES '
    ||' ( :p1, :p2, :p3, :p4, '
    ||'   :p5, :p6, :p7, :p8 ) ';

    EXECUTE IMMEDIATE statement_demands_api USING
        fcst_dtl_tab(pcounter).organization_id,
        sched_dtl_tab(g_item_tbl_position).schedule_id,
        fcst_dtl_tab(pcounter).inventory_item_id,
        fcst_dtl_tab(pcounter).trans_date,
        fcst_dtl_tab(pcounter).consumed_qty,
        7,				/* origination type */
        null_value,			/* wip_entity id */
        null_value ;

        /* Global vairable Updation to next record */
        /*  B2929759, Rajesh Patangya 28-APR-2003 */
           gfcst_cnt := pcounter + 1 ;

  EXCEPTION
    WHEN OTHERS THEN
        log_message('Failure occured during the insert into gmp_demands_api');
        log_message(sqlerrm);
      RAISE;
  END;
ELSE
  BEGIN
    statement_demands  :=
      ' INSERT INTO msc_st_demands ( '
    ||' organization_id, inventory_item_id, sr_instance_id, '
    ||' using_assembly_item_id, using_assembly_demand_date, '
    ||' using_requirement_quantity, demand_type, origination_type, '
    ||' wip_entity_id, demand_schedule_name, order_number, '
    ||' wip_entity_name, selling_price, deleted_flag ) '
    ||' VALUES '
    ||' ( :p1, :p2, :p3,  '
    ||'   :p4, :p5,       '
    ||'   :p6, :p7, :p8 , '
    ||'   :p9, :p10,:p11, '
    ||'   :p12,:p13,:p14 )' ;

    EXECUTE IMMEDIATE statement_demands USING
        fcst_dtl_tab(pcounter).organization_id,
        fcst_dtl_tab(pcounter).inventory_item_id,
        g_instance_id,
        fcst_dtl_tab(pcounter).inventory_item_id,
        fcst_dtl_tab(pcounter).trans_date,
        fcst_dtl_tab(pcounter).consumed_qty,
        1,				/* demand type */
        7,				/* origination type */
        null_value, 			/* wip_entity id */
        gcurrent_designator,
        fcst_dtl_tab(pcounter).forecast ,
        null_value,			/* wip entity name */
        null_value,
        2 ;

        /* Global vairable Updation to next record */
        /*  B2929759, Rajesh Patangya 28-APR-2003 */
           gfcst_cnt := pcounter + 1 ;

 EXCEPTION
    WHEN OTHERS THEN
        log_message('Failure occured during write_this_fcst');
        log_message(sqlerrm);
      RAISE;
  END;

END IF;
END write_this_fcst ;

/* **************************************************************************
*   NAME
*	 time_stamp
*
*   DESCRIPTION
*     Put the time stamp, whenever in prgroma required
*   HISTORY
*        Created By : Rajesh Patangya
************************************************************************/
PROCEDURE time_stamp IS

  cur_time VARCHAR2(25) := NULL ;
BEGIN
   SELECT to_char(sysdate,'DD-MON-RRRR HH24:MI:SS')
   INTO cur_time FROM sys.dual ;

   log_message(cur_time);
  EXCEPTION
    WHEN OTHERS THEN
        log_message('Failure occured in time_stamp');
        log_message(sqlerrm);
      RAISE;
END time_stamp ;

/* **************************************************************************
*   NAME
*        insert_designator
*
*   DESCRIPTION
*     Insert all the designator for schedule/item/warehouse combination
*   HISTORY
*        Created By : Rajesh Patangya
************************************************************************/
PROCEDURE insert_designator IS

i	PLS_INTEGER := 1 ;
  st_designators  VARCHAR2(3000) := NULL ;

BEGIN

    g_delimiter  := '/';
    st_designators  :=
        ' INSERT INTO msc_st_designators ( '
      ||' designator, organization_id, sr_instance_id, '
      ||' description, mps_relief, inventory_atp_flag, '
      ||' designator_type ) '
      ||' VALUES '
      ||' ( :p1, :p2, :p3, '
      ||'   :p4, :p5, :p6, '
      ||'   :p7 ) ';

      FOR i IN 1..desig_tab.COUNT LOOP

      EXECUTE IMMEDIATE st_designators USING
          desig_tab(i).designator,
          desig_tab(i).organization_id,
          g_instance_id,
          desig_tab(i).orgn_code || g_delimiter || desig_tab(i).schedule
                                 || g_delimiter || desig_tab(i).whse_code,
          2,
          2,
          1  ;

      END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
        log_message('Failure occured in insert_designator');
        log_message(sqlerrm);
      RAISE;
END insert_designator;

/***********************************************************************
*
*   NAME
*	process_resource_rows
*
*   DESCRIPTION
*	This procedure will process al of the resource rows for a step then
*       call the insert for resource requirements.
*   HISTORY
*	M Craig
************************************************************************/
PROCEDURE process_resource_rows(
  pfirst_row    IN  NUMBER,
  plast_row     IN  NUMBER,
  pfound_mtl    IN  NUMBER,
  porgn_id      IN  PLS_INTEGER,
  pinstance_id  IN  PLS_INTEGER,
  pinflate_wip  IN  NUMBER,
  pmin_xfer_qty IN  NUMBER)
IS

  v_resource_usage PLS_INTEGER := 0;
  v_res_seq        PLS_INTEGER := 0;
  v_schedule_flag  PLS_INTEGER := 0;
  v_parent_seq_num PLS_INTEGER := 0;
  v_rsrc_cnt       PLS_INTEGER := 0;
  v_start_date     DATE := NULL;
  v_end_date       DATE := NULL;
  old_activity     PLS_INTEGER := 0;
  j                PLS_INTEGER := 0;

BEGIN
  v_res_seq := 0;
  old_activity := -1;

 FOR j IN pfirst_row..plast_row
 LOOP
   /* if the actual completion date is null then the resource
      is pending or WIP and needs to be written. otherwise the
      resource is completed and does not need to be reported. */

   IF old_activity <> rsrc_tab(j).bs_activity_id OR
      old_activity = -1 THEN
     v_res_seq := v_res_seq + 1;
     old_activity := rsrc_tab(j).bs_activity_id;

    /* B3421856 , Schedule flag needs to be populated correctly */

     IF pfound_mtl = 1 THEN

        IF rsrc_tab(j).material_ind = 1 THEN
                v_schedule_flag := 4;
        ELSE
                IF v_schedule_flag < 4 THEN
                        v_schedule_flag := 3 ;
                END IF ;
        END IF ;

     END IF;  /* pfound_mtl */
   END IF;   /* old_activity */

   IF rsrc_tab(j).material_ind = 0 AND pfound_mtl = 1 THEN
     rsrc_tab(j).schedule_flag := v_schedule_flag;
   END IF;

   IF NVL(rsrc_tab(j).actual_cmplt_date,v_null_date) = v_null_date THEN

     /* when the actual start is null the resource has not started
        and the plan start will be used.  */
     IF rsrc_tab(j).tran_seq_dep = 1 THEN
       v_parent_seq_num := v_res_seq;
       v_resource_usage := rsrc_tab(j).resource_usage;
       v_start_date := rsrc_tab(j).act_start_date;
       v_end_date := rsrc_tab(j).plan_start_date;
     ELSE
       v_parent_seq_num := TO_NUMBER(NULL);
       v_start_date := rsrc_tab(j).plan_start_date;
       v_end_date := rsrc_tab(j).plan_cmplt_date;
       IF pinflate_wip = 1 THEN
         v_resource_usage := rsrc_tab(j).resource_usage / rsrc_tab(j).utl_eff;
       ELSE
         v_resource_usage := rsrc_tab(j).resource_usage;
       END IF;
     END IF;

     /* If no actual resource exists then the resource has not
        started and the planned value will be used */

     IF rsrc_tab(j).actual_rsrc_count IS NULL THEN
       v_rsrc_cnt := rsrc_tab(j).plan_rsrc_count;
     ELSE
       v_rsrc_cnt := rsrc_tab(j).actual_rsrc_count;
     END IF;

     /* write the current resource detail row asscoiating it with the
        batch through the product line */

     IF v_resource_usage > 0 THEN

        /* Bulk Insert for insert_resource_requirements */
          rr_index := rr_index + 1 ;
          rr_organization_id(rr_index) := porgn_id ;
          rr_sr_instance_id(rr_index) := pinstance_id ;
          rr_supply_id(rr_index) :=  rsrc_tab(j).x_batch_id ; /* B1177070 encoded key */
          /* B1224660 new value to write resource seq num */
          rr_resource_seq_num(rr_index) := v_res_seq ;
          rr_resource_id(rr_index) := rsrc_tab(j).x_resource_id ; /* B1177070 encoded key */
          rr_start_date(rr_index) := v_start_date ;
          rr_end_date(rr_index)  :=  v_end_date ;
          rr_opr_hours_required(rr_index) :=  v_resource_usage ;
          rr_assigned_units(rr_index) := v_rsrc_cnt ;
          rr_department_id(rr_index) := ((porgn_id * 2) + 1) ;  /* B1177070 encoded key */
          rr_wip_entity_id(rr_index) :=  rsrc_tab(j).x_batch_id ; /* B1177070 encoded key */
          /* B1224660 write the step number for oper seq num */
          rr_operation_seq_num(rr_index)  :=   rsrc_tab(j).batchstep_no ;
          rr_firm_flag(rr_index) :=    rsrc_tab(j).firm_type ;
          rr_minimum_transfer_quantity(rr_index) := pmin_xfer_qty ;
          rr_parent_seq_num(rr_index) := v_parent_seq_num ;
          rr_schedule_flag(rr_index) := rsrc_tab(j).schedule_flag ;
      END IF;
   END IF;
  END LOOP;

END process_resource_rows;

/*Sowmya - As Per latest FDD changes - Start*/
/***********************************************************************
*
*   NAME
*	production_reservations
*
*   DESCRIPTION
*	This procedure will fetch all salesorders against which production
*       batches are reserved.
*   HISTORY
*
************************************************************************/
/* INVCONV nsinghi Start */
/* ToDo: Need to make the changes */
/* INVCONV nsinghi End */
PROCEDURE production_reservations ( pdblink        IN  VARCHAR2,
                          pinstance_id   IN  PLS_INTEGER,
                          prun_date      IN  DATE,
                          pdelimiter     IN  VARCHAR2,
                          return_status  IN OUT NOCOPY BOOLEAN)
IS
        v_stmt_alt_rsrc VARCHAR2(4000);
BEGIN

v_stmt_alt_rsrc :=  'INSERT INTO MSC_ST_RESERVATIONS'
                ||'  (  '
                ||'        TRANSACTION_ID , '
                ||'        INVENTORY_ITEM_ID ,  '
                ||'        ORGANIZATION_ID, '
                ||'        SR_INSTANCE_ID ,  '
                ||'        REQUIREMENT_DATE , '
                ||'        PARENT_DEMAND_ID , '
                ||'        REVISION  , '
                ||'        DISPOSITION_ID , '
                ||'        RESERVED_QUANTITY , '
                ||'        DISPOSITION_TYPE ,  '
                ||'        SUBINVENTORY , '
                ||'        RESERVATION_TYPE , '
                ||'        DEMAND_CLASS , '
                ||'        AVAILABLE_TO_MRP , '
                ||'        RESERVATION_FLAG , '
                ||'        PROJECT_ID , '
                ||'        TASK_ID , '
                ||'        PLANNING_GROUP , '
                ||'        SUPPLY_SOURCE_HEADER_ID , '
                ||'        SUPPLY_SOURCE_TYPE_ID , '
                ||'        DELETED_FLAG '
                ||'  ) '
                ||'  SELECT '
                ||'        ((gbo.batch_res_id * 2) + 1), '
/*Sowmya - INVCONV -  Start*/
--                ||'        gia.aps_item_id , '
/*Sowmya - INVCONV -  Start*/
                ||'        gbo.organization_id, '
                ||'        :p1, '
                ||'        gbo.scheduled_ship_date, '
                ||'        gbo.so_line_id , '
                ||'        NULL , '
                ||'        gbo.order_id , '
                ||'        gbo.reserved_qty , '
                ||'        :p2 ,'
                ||'        NULL , '
                ||'        :p3 ,'
                ||'        ool.demand_class_code , '
                ||'        NULL  , '
                ||'        :p4 ,'
                ||'        ool.project_id, '
                ||'        ool.task_id, '
                ||'        ppp.planning_group, '
                ||'        ((gbo.batch_id * 2) + 1) , '
                ||'        :p5 ,'
                ||'        :p6 '
                ||'   FROM '
                ||'         gml_batch_so_reservations'||pdblink||' gbo, '
/*Sowmya - INVCONV -  start*/
/*                ||'        (SELECT  '
                ||'                DISTINCT item_id, aps_item_id, organization_id , whse_code '
                ||'         FROM gmp_item_aps'||pdblink||')  gia, '*/
                ||'         mtl_system_items'||pdblink||' msi, '
/*Sowmya - INVCONV -  End*/
                ||'        oe_order_lines_all'||pdblink||' ool, '
                ||'        pjm_project_parameters'||pdblink||' ppp  '
                ||'   WHERE '
/*Sowmya - INVCONV -  Start*/
--                ||'         gbo.item_id = gia.item_id '
/*doubt : gml_batch_so_reservations does not have inventory item id ?? - to include join
for gml table and msi table*/
/*Sowmya - INVCONV -  End*/
                ||'        AND gbo.organization_id = gia.organization_id '
                ||'        AND gbo.delete_mark = 0 '
                ||'        AND gbo.so_line_id = ool.line_id '
                ||'        AND ool.project_id = ppp.project_id (+) ';

                IF gmp_calendar_pkg.g_in_str_org  IS NOT NULL THEN
                        v_stmt_alt_rsrc := v_stmt_alt_rsrc
--                           ||'
/*Sowmya - INVCONV -  Start*/
/*                         ||'   AND EXISTS ( SELECT 1 FROM sy_orgn_mst'||pdblink||' som '
                         ||'   WHERE gia.whse_code = som.resource_whse_code )' ;
*/
                ||'     AND msi.organization_id '|| gmp_calendar_pkg.g_in_str_org;
/*Sowmya - INVCONV -  End*/
                END IF;

                EXECUTE IMMEDIATE v_stmt_alt_rsrc USING
                pinstance_id,2,1,2,5,2 ;    /*Sowmya - As per latest FDD changes -
                                             Changed the supply source id from 13 to 5 */
        EXCEPTION
                WHEN OTHERS THEN
	        log_message('Failure occured during the insert into msc_st_reservations');
	        log_message(sqlerrm);
              	return_status := FALSE;

END production_reservations;
/*Sowmya - As Per latest FDD changes - End*/

/***********************************************************************
*
*   NAME
*	update_last_setup_id
*
*   DESCRIPTION
*	This procedure is triggered by the concurrent program for
*       updating the last setup id.
*
*   HISTORY
*	Namit           14-09-2004      Procedure Created
************************************************************************/
/* INVCONV nsinghi Start */
/* ToDo: Need to make the changes */
/* INVCONV nsinghi End */

PROCEDURE update_last_setup_id (
   effbuf   OUT NOCOPY VARCHAR2,
   retcode      OUT NOCOPY NUMBER,
   f_orgn_code    IN  NUMBER,
   t_orgn_code    IN  NUMBER
)
IS
   TYPE ref_cursor_typ IS REF CURSOR;
   cur_lsetup_id ref_cursor_typ;
   resources VARCHAR2(30);
   v_last_setup_id      NUMBER;
   v_resource_id        NUMBER;
/*Sowmya - INVCONV -  Start*/
--   v_plant_code         VARCHAR2(10);
   v_org_id             NUMBER;
/*Sowmya - INVCONV -  End*/
   v_batch_id           NUMBER;
   v_instance_id        NUMBER;
   x_select             VARCHAR2(1000);
   old_resource_id      NUMBER;
   old_instance_id      NUMBER;
   lsetup_updated       BOOLEAN;
   l_user_id            NUMBER;

BEGIN


   x_select := NULL;
   old_resource_id := -1;
   old_instance_id := -1;
   lsetup_updated := TRUE;

    l_user_id :=  to_number(FND_PROFILE.VALUE('USER_ID'));

    X_select := ' SELECT '
    ||' gbsr.sequence_dependent_id, '
    ||' crd.resource_id, '
    ||' grt.instance_id, '
/*Sowmya - INVCONV -  Start*/
--    ||' crd.orgn_code, '
    ||' crd.organization_id, '
/*Sowmya - INVCONV -  End*/
    ||' gbsr.batch_id '
    ||' FROM    gme_batch_step_resources gbsr, '
    ||'    gme_resource_txns grt, '
/*Sowmya - INVCONV -  Start*/
/*doubt - which table should be used to fetch the current user id*/
--    ||'    sy_orgn_usr sou, '
/*Sowmya - INVCONV -  End*/
    ||'    cr_rsrc_dtl crd, '
    ||'    gme_batch_header gbh, '
    ||'    mtl_parameters mp '    /* sowmya added to pick the organization code in the
                                     concurrent pgm*/
    ||' WHERE   gbsr.batch_id = grt.doc_id '
    ||'    AND  gbh.batch_id = gbsr.batch_id '
/*Sowmya - INVCONV -  Start*/
/*    ||'    AND  gbh.plant_code = crd.orgn_code '
    ||'    AND  crd.orgn_code = sou.orgn_code '
    ||'    AND  sou.user_id = :user_id ' */
    ||'    AND  gbh.organization_id = crd.organization_id  '
    ||'    AND  mp.organization_id = crd.organization_id '
/* doubt - complete the join the for the user tables*/
/*Sowmya - INVCONV -  End*/
    ||'    AND  gbsr.batchstep_resource_id = grt.line_id '
    ||'    AND  grt.completed_ind = 1 '
    ||'    AND  crd.resources = gbsr.resources '
    ||'    AND  crd.resources = grt.resources '
    ||'    AND  crd.schedule_ind = 2 '
    ||'    AND   grt.instance_id IS NOT NULL '
    ||'    AND   crd.delete_mark = 0 ';
    IF f_orgn_code IS NOT NULL THEN
       x_select := x_select
/*Sowmya - INVCONV -  Start*/
--       ||'    AND     crd.orgn_code >= :frm_orgn ' ;
         ||'    AND     mp.organization_id >= :frm_orgn ' ;
    END IF;
    IF t_orgn_code IS NOT NULL THEN
       x_select := x_select
--       ||'    AND     crd.orgn_code <= :to_orgn ' ;
         ||'    AND     mp.organization_id <= :to_orgn ' ;
/*Sowmya - INVCONV -  End*/
    END IF;
    x_select := x_select
    ||'    ORDER BY grt.resources, grt.instance_id, '
    ||'       grt.end_date DESC, grt.poc_trans_id ' ;

   IF f_orgn_code IS NOT NULL AND t_orgn_code IS NOT NULL THEN
      OPEN cur_lsetup_id FOR x_select USING /*l_user_id,*/ f_orgn_code, t_orgn_code;
   ELSIF f_orgn_code IS NOT NULL AND t_orgn_code IS NULL THEN
      OPEN cur_lsetup_id FOR x_select USING /*l_user_id,*/ f_orgn_code;
   ELSIF f_orgn_code IS NULL AND t_orgn_code IS NOT NULL THEN
      OPEN cur_lsetup_id FOR x_select USING /*l_user_id,*/ t_orgn_code;
   ELSE
      OPEN cur_lsetup_id FOR x_select /*USING l_user_id*/;
   END IF;

   LOOP
      FETCH cur_lsetup_id INTO v_last_setup_id, v_resource_id, v_instance_id,
--        v_plant_code, v_batch_id;
/*Sowmya - INVCONV -  Start*/
            v_org_id, v_batch_id;
/*Sowmya - INVCONV -  End*/
      EXIT WHEN cur_lsetup_id%NOTFOUND;

      IF (old_resource_id <> v_resource_id OR old_instance_id <> v_instance_id) THEN
         old_resource_id := v_resource_id;
         old_instance_id := v_instance_id;
         lsetup_updated := FALSE;
      END IF;

      IF NOT (lsetup_updated) THEN
         lsetup_updated := TRUE;
--         IF v_last_setup_id IS NOT NULL
--         THEN
            UPDATE
               gmp_resource_instances gri
            SET gri.last_setup_id = v_last_setup_id

            WHERE
               gri.resource_id = v_resource_id
               AND gri.instance_id = v_instance_id;
--         END IF;
      END IF;
   END LOOP;
      CLOSE cur_lsetup_id ;
   COMMIT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        log_message(' NO_DATA_FOUND exception raised in Procedure: gmp_aps_ds_pull.update_last_setup_id ' );
      	RAISE;

    WHEN OTHERS THEN
        log_message('Error in Last Setup ID Program: '||SQLERRM);
        RAISE;

END update_last_setup_id;

/*
REM+=========================================================================+
REM| FUNCTION NAME                                                           |
REM|    gmp_debug_message                                                    |
REM| DESCRIPTION                                                             |
REM|    This procedure is created to enable more debug messages              |
REM| HISTORY                                                                 |
REM|    Vpedarla Bug: 8420747 created this procedure                         |
REM+=========================================================================+
*/
PROCEDURE gmp_debug_message(pBUFF  IN  VARCHAR2) IS
BEGIN
   IF (l_debug = 'Y') then
        LOG_MESSAGE(pBUFF);
   END IF;
END gmp_debug_message;

END gmp_aps_ds_pull;

/
