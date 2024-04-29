--------------------------------------------------------
--  DDL for Package Body MSC_CL_GMP_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_CL_GMP_UTILITY" as --body
 /* $Header: MSCCLGMB.pls 120.0.12010000.3 2008/08/18 07:06:26 sbyerram ship $ */


          /*======== GLOBAL OPM Data Collection Declaration =========*/

TYPE  ref_cursor_typ is REF CURSOR;

invalid_string_value      EXCEPTION;
invalid_gmp_uom_profile   EXCEPTION;
stmt_no                   NUMBER := 0;
s		          INTEGER := 1;
p_location                VARCHAR2(300) := NULL;
g_aps_eff_id              NUMBER     := 0;  /* Global Aps Effectivity ID */
aps_fmeff_id              NUMBER     := 0 ; /* Generated effectivity Id */
x_aps_fmeff_id            NUMBER     := 0 ; /* encoded effectivity Id */
g_fm_dtl_start_loc        INTEGER := 0; /* Start detail location */
g_fm_dtl_end_loc          INTEGER := 0;  /* End detail location */
g_fm_hdr_loc              INTEGER := 1;  /* Starting for formula header */
g_formula_orgn_count_tab  INTEGER := 1;  /* Starting for formula orgn detail */
g_rstep_loc	 	  INTEGER := 1 ;  /* global rtg offset location */
g_curr_rstep_loc	  NUMBER  := -1 ; /* current r step offsetp locn */
g_prev_formula_id 	  NUMBER := -1 ;
g_prev_locn 		  NUMBER := 1;
g_dep_index               NUMBER := 1;
alt_rsrc_size             INTEGER;  /* Number of Alternate resources for BOM */
formula_headers_size      INTEGER;  /* Number of rows in formula_headers */
formula_details_size      INTEGER;  /* Number of rows in formula_details */
formula_orgn_size  	  INTEGER;  /* Number of detail rows for formula */
routing_headers_size      INTEGER;  /* Number of rows in routing_headers */
rtg_org_dtl_size      	  INTEGER;  /* Number of rows in routing_org_details */
rtg_gen_dtl_size          INTEGER;  /* Number of rows in generic routing_det */
material_assocs_size      INTEGER;  /* Number of rows in material_assocs */
setup_size                INTEGER;  /* Number of rows in Seq Dep Cursor */
opr_stpdep_size           INTEGER := 1;  /* Number of rows in step dependency */
recipe_orgn_over_size     INTEGER;  /* No. of rows in recipe orgn override */
recipe_override_size      INTEGER;  /* Number of rows in recipe override */
rtg_offsets_size 	  INTEGER := 1;  /* Number of rows in rtg offsets tbl */
current_date_time         DATE;	    /* For consistency writes */
b_instance_id             INTEGER;
delimiter                 VARCHAR2(1);  /* Used when filling in comment columns on BOM and ROUTING Tables */
l_in_str_org              VARCHAR2(32767) := null ;   /* B3491625 */
at_apps_link              VARCHAR2(31); /* Database link to APPS server from Planning server  */
g_instance_id             NUMBER;       /* Instance Id from Planning server  */
g_mat_assoc               INTEGER;  /* Glabal counter for materail assiciation */
g_gmp_uom_class           VARCHAR2(10); /* UOM Class */
g_setup_id                NUMBER; /* hold he last setup_id */
sd_index                  INTEGER := 0 ;
/* These variables store the MTQ related values that is last inserted. */
g_old_formula_id          NUMBER ; /* B3970993 */
g_old_recipe_id           NUMBER ; /* B3970993 */
g_old_rtg_id              NUMBER ; /* B3970993 */
g_old_rtgstep_id          NUMBER ; /* B3970993 */
g_old_aps_item_id         NUMBER ; /* B3970993 */
g_mtq_loc                 NUMBER ; /* B3970993 */
g_min_mtq                 NUMBER ; /* B3970993 */
/* Bug:5872693 Vpedarla 12-Feb-2007 */
k                         NUMBER;
orig_start_date           DATE;
substcount                NUMBER;
enddatenull               BOOLEAN:=FALSE;
/* Bug:5872693 Vpedarla end 12-Feb-2007 */
v_gmd_seq 		  varchar2(100);
v_gmd_formula_lineid 	  INTEGER := 0;
gmd_formline_cnt  	  INTEGER := 0 ;
op_formline_cnt 	  INTEGER := 0 ;
desig_count		  NUMBER  := 0;
gfcst_cnt		  NUMBER  := 0;
gso_cnt		          NUMBER  := 0;
gschd_fcst_cnt	          NUMBER  := 0;
gitem_size		  NUMBER  := 0;
gfcst_size		  NUMBER  := 0;
gso_size		  NUMBER  := 0;
gschd_fcst_size	          NUMBER  := 0;
g_item_tbl_position	  NUMBER  := 0;
gcurrent_designator	  VARCHAR2(10) := NULL;
g_delimiter               VARCHAR2(4) := '/' ;
gprod_size                NUMBER  := 0;
grsrc_size                NUMBER  := 0;
gonhand_balance_size      NUMBER  := 0; -- akaruppa B4287033
g_rsrc_cnt                INTEGER ;
stp_chg_num               NUMBER  ;
stp_chg_cursor            VARCHAR2(32700);
statement_alt_resource    VARCHAR2(32700):= NULL;
alt_prod_size             INTEGER;  /* NAVIN :- : Number of rows in Alternate Resource */
/* Sowmya - As per the latest FDD changes */
l_res_inst_process        NUMBER;
/*-------------------------- Operation Charges-----------------------------*/
v_orgn_id                      NUMBER;
r                              NUMBER;
p                              NUMBER ;
chg_res_index                  NUMBER; /* NAVIN :- Resource Charges */
resource_usage_flag            NUMBER;
resource_instance_usage_flag   NUMBER;
old_rsrc_batch_id              NUMBER;
old_rsrc_resources             VARCHAR2(16);
old_rsrc_original_seq_num      NUMBER;
old_instance_number            NUMBER;
old_rsrc_inst_batch_id         NUMBER;
old_rsrc_inst_resources        VARCHAR2(16);
old_rsrc_inst_original_seq_num NUMBER;
V_FROM_RSRC                    VARCHAR2(16) ;
V_TO_RSRC                      VARCHAR2(16) ;

TYPE gmp_buffer_typ IS RECORD
(
  fmeff_id            NUMBER,  /* OPM Effectivity ID         */
  aps_fmeff_id        NUMBER,  /* APS Effectivity ID - B2989806  */
  item_id             NUMBER,  /* OPM Effectivity Item ID    */
  formula_id          NUMBER,  /* Formula ID                 */
  plant_code          VARCHAR2(4), /* Effectivity Orgn code      */
  organization_id     NUMBER    ,  /* ID for the Plant           */
  start_date          DATE,        /* Effectivity Start Date     */
  end_date            DATE,        /* Effectivity End Date       */
  inv_min_qty         NUMBER,      /* Effectivity Minimum Qty    */
  inv_max_qty         NUMBER,      /* Effectivity Maximum Qty    */
  preference          NUMBER,      /* Effectivity Preference     B3437281 */
  primary_um          VARCHAR2(4), /* Primary UOM of the Item    */
  whse_code           VARCHAR2(4), /* Resource or Material Whse  */
  routing_id          NUMBER    ,  /* Routing ID. Could be NULL  */
  routing_no          VARCHAR2(32),/* Associated Routing No      */
  routing_vers        NUMBER   ,   /* Associated Routing Version */
  routing_desc        VARCHAR2(70),/* Associated Routing DEsc'n  */
  routing_um          VARCHAR2(4), /* UOM from the Routing       */
  routing_qty         NUMBER,      /* Qty from the Routing       */
  prod_factor         NUMBER, /*B2870041 factor to convert prod to rout um */
  product_index       NUMBER, /*B2870041 index of the product line */
  aps_item_id         NUMBER    ,  /* OPM Effective Aps Item ID    */
  recipe_id           NUMBER  ,  /* 1830940 New GMD Changes Recipe ID */
  rtg_hdr_location    NUMBER    ,   /* index link to routing header */
/* NAMIT_CR */
  calculate_step_quantity NUMBER ,
  category_id         NUMBER,  /* SGIDUGU */
  setup_id            NUMBER,   /* SGIDUGU */
  seq_dpnd_class      VARCHAR2(8)   /* SGIDUGU */
);
effectivity           gmp_buffer_typ;
-- primary_bom_formulaline_id  NUMBER     ; -- Bug # 4879588

TYPE gmp_formula_header_typ IS RECORD
(
  formula_id          NUMBER    ,
  valid_flag          NUMBER   ,
  start_dtl_loc       NUMBER    ,
  end_dtl_loc         NUMBER    ,
  total_output        NUMBER, /* B2870041 total output for all prod/byp */
  total_um            VARCHAR2(4) /*B2870041 um used to calculate qty */
);
TYPE gmp_formula_header_tbl IS TABLE OF gmp_formula_header_typ
INDEX BY BINARY_INTEGER;
formula_header_tab        gmp_formula_header_tbl;

TYPE gmp_formula_detail_typ IS RECORD
(
  formula_id          NUMBER,
  formula_no          VARCHAR2(32),
  formula_vers        NUMBER, --PK
  formula_desc1       VARCHAR2(100),
  x_formulaline_id    NUMBER,
  line_type           NUMBER,
  opm_item_id         NUMBER, --PK
  formula_qty         NUMBER,
  scrap_factor        NUMBER,
  scale_type          NUMBER,
  contribute_yield_ind VARCHAR2(1),      /* B2657068 Rajesh Patangya */
  contribute_step_qty_ind NUMBER,      /* NAMIT_ASQC */
  phantom_type        NUMBER,
  aps_um              VARCHAR2(3),
  orig_um             VARCHAR2(4), /*B2870041 formula um */
  primary_um          VARCHAR2(4), /* B2870041 item primary um */
  bom_scale_type      NUMBER,
  primary_qty         NUMBER,
  aps_item_id         NUMBER, --PK
  scale_multiple      NUMBER, --PK       /* B2657068 Rajesh Patangya */
  scale_rounding_variance NUMBER, --PK    /* B2657068 Rajesh Patangya */
  rounding_direction  NUMBER,          /* B2657068 Rajesh Patangya */
  release_type        NUMBER,       /* B3278466 LTC change */
  /*sowmya - Item substitution - start*/
  original_item_id    NUMBER, --PK
  start_date          DATE,
  end_date            DATE,
  /*sowmya - Item substitution - end*/
  /* venu */
  formula_line_id     NUMBER, --PK
  preference          NUMBER, --PK
  lead_stdate         DATE,
  lead_enddate        DATE,
  lead_pref           NUMBER,
  actual_end_date     DATE,
  actual_end_flag     NUMBER,
  original_item_flag  NUMBER,
  formulaline_id      NUMBER --PK
  /* venu */
);

TYPE gmp_formula_detail_tbl IS TABLE OF gmp_formula_detail_typ
INDEX by BINARY_INTEGER;
formula_detail_tab   gmp_formula_detail_tbl ;

/* Bug:5872693 Vpedarla start 12-Feb-2007 */
prev_detail_tab                   gmp_formula_detail_tbl ;
orig_detail_tab                   gmp_formula_detail_tbl ;
temp_detail_tab                   gmp_formula_detail_tbl ;
subst_tab                         gmp_formula_detail_tbl ;
/* Bug:5872693 Vpedarla end 12-Feb-2007 */

TYPE gmp_formula_detail_count_typ IS RECORD
(
  formula_id          NUMBER    ,
  formula_dtl_count   NUMBER
);
TYPE gmp_formula_detail_count_tbl IS TABLE OF gmp_formula_detail_count_typ
INDEX BY BINARY_INTEGER;
formula_dtl_count_rec     gmp_formula_detail_count_typ ;

TYPE gmp_formula_orgn_count_typ IS RECORD
(
  formula_id          NUMBER    ,
  plant_code          VARCHAR2(4),
  organization_id     NUMBER    ,
  orgn_count          NUMBER    ,  /* Count of formula details */
  valid_flag          NUMBER
);
TYPE gmp_formula_orgn_count_tbl IS TABLE OF gmp_formula_orgn_count_typ
INDEX BY BINARY_INTEGER;
formula_orgn_count_tab  gmp_formula_orgn_count_tbl;

TYPE gmp_routing_header_typ IS RECORD
(
  routing_id          NUMBER    ,
  plant_code          VARCHAR2(4),
  valid_flag          NUMBER   ,
  generic_start_loc   NUMBER    ,
  generic_end_loc     NUMBER    ,
  orgn_start_loc      NUMBER    ,
  orgn_end_loc        NUMBER    ,
  step_start_loc      NUMBER    ,
  step_end_loc        NUMBER    ,
  usage_start_loc     NUMBER    ,
  usage_end_loc       NUMBER    ,
  stpdep_start_loc    NUMBER    ,
  stpdep_end_loc      NUMBER
);
TYPE gmp_routing_header_tbl IS TABLE OF gmp_routing_header_typ
INDEX BY BINARY_INTEGER;
rtg_org_hdr_tab      gmp_routing_header_tbl;

TYPE gmp_routing_detail_typ IS RECORD
(
  routing_id          NUMBER    ,
  orgn_code           VARCHAR2(4),
  routingstep_no      NUMBER   ,
  seq_dep_ind         NUMBER, /*B2870041 sequence dependent indicator */
  prim_rsrc_ind_order NUMBER   ,
  resources           VARCHAR2(16),
  prim_rsrc_ind       NUMBER   ,
  capacity_constraint NUMBER   ,
  min_capacity        NUMBER,
  max_capacity        NUMBER,
  schedule_ind        NUMBER,

  routingstep_id      NUMBER    ,
  x_routingstep_id    NUMBER    ,
--  routingstep_no      NUMBER   ,
  step_qty            NUMBER,
  minimum_transfer_qty NUMBER,
  oprn_desc           VARCHAR2(70),
  oprn_id             NUMBER  ,   /* SGIDUGU - Seq Dep changes */
  oprn_no             VARCHAR2(32),
  process_qty_um      VARCHAR2(4),
  activity            VARCHAR2(16),
  oprn_line_id        NUMBER    ,
--  resources           VARCHAR2(16),
  resource_count      NUMBER   ,
  resource_usage      NUMBER,
  usage_um            VARCHAR2(4),
  scale_type          NUMBER   ,
--  prim_rsrc_ind       NUMBER   ,
  offset_interval     NUMBER,
  resource_id         NUMBER    ,
  x_resource_id       NUMBER    ,   /* B1177070 added encoded key */
  rtg_scale_type      NUMBER   ,
  aps_usage_um        VARCHAR2(3),
  activity_factor     NUMBER,       /* GMD New Additional Columns */
  process_qty         NUMBER,       /* GMD New Additional Columns */
--  seq_dep_ind         NUMBER, /*B2870041 sequence dependent indicator */
  material_ind        NUMBER, /*B2870041 material indicator for next/prior*/
  schedule_flag       NUMBER, /*B2870041 default value for APS*/
  mat_found           NUMBER, /* Indicator is any activity is scheduled in operation. */
  include_rtg_row     NUMBER, /* Do Not Plan Resource rows will have value 0 */
  break_ind           NUMBER, /* Flag denoting whether activity is breakable or not. */
  o_min_capacity      NUMBER,  /* Overrides */
  o_max_capacity      NUMBER,  /* Overrides */
  o_resource_usage    NUMBER,  /* Overrides */
  o_activity_factor   NUMBER,  /* Overrides */
  o_process_qty       NUMBER,  /* Overrides */
  o_step_qty          NUMBER,  /* Overrides */
  is_sds_rout         NUMBER,   /* B4918786 SDS */
  is_unique           NUMBER,   /* B4918786 SDS */
  is_nonunique        NUMBER,   /* B4918786 SDS */
  setup_id            NUMBER    /* B4918786 SDS */
);
TYPE gmp_routing_detail_tbl IS TABLE OF gmp_routing_detail_typ
INDEX BY BINARY_INTEGER;
rtg_org_dtl_tab    gmp_routing_detail_tbl;

TYPE gen_routing_detail_typ IS RECORD
(
  routing_id          NUMBER    ,
  routingstep_no      NUMBER   ,
  seq_dep_ind         NUMBER, /*B2870041 sequence dependent indicator */
  prim_rsrc_ind_order NUMBER   ,
  resources           VARCHAR2(16),
  routingstep_id      NUMBER    ,
  oprn_no             VARCHAR2(32),
  oprn_line_id        NUMBER    ,
  activity            VARCHAR2(16),
  prim_rsrc_ind       NUMBER   ,
--  resources           VARCHAR2(16),
--  prim_rsrc_ind       NUMBER   ,
--  seq_dep_ind         NUMBER, /*B2870041 sequence dependent indicator */
  offset_interval     NUMBER,
  uom_code            VARCHAR2(3) /* NAMIT_RD */
);
TYPE gen_routing_detail_tbl IS TABLE OF gen_routing_detail_typ
INDEX BY BINARY_INTEGER;
rtg_gen_dtl_tab       gen_routing_detail_tbl;

/* B4918786 SDS */
TYPE gmp_sds_typ IS RECORD
(
  oprn_id             NUMBER,
  category_id         NUMBER,
  seq_dpnd_class      VARCHAR2(100),
  resources           VARCHAR2(16),
  resource_id         NUMBER,
  setup_id            NUMBER
);
TYPE gmp_sds_tbl IS TABLE OF gmp_sds_typ INDEX BY BINARY_INTEGER;
sds_tab    gmp_sds_tbl;
sds_tab_init gmp_sds_tbl;

TYPE gmp_alt_resource_typ IS RECORD
(
  prim_resource_id    NUMBER    ,
  alt_resource_id     NUMBER    ,
  min_capacity        NUMBER,  /* SGIDUGU - min capacity for alternate rsrc */
  max_capacity        NUMBER,  /* SGIDUGU - max capacity for alternate rsrc */
  runtime_factor      NUMBER,  /* B2353759,alternate runtime_factor */
  preference	      NUMBER, /* Prod spec alternates */
  item_id 	      NUMBER  /* Prod spec alternates */
);
TYPE gmp_alt_resource_tbl IS TABLE OF gmp_alt_resource_typ
INDEX BY BINARY_INTEGER;
rtg_alt_rsrc_tab       gmp_alt_resource_tbl;

TYPE gmp_material_assoc_typ IS RECORD
(
  formula_id          NUMBER    ,
  recipe_id           NUMBER    ,
  line_type           NUMBER   ,
  line_no             NUMBER   ,
  x_formulaline_id    NUMBER    ,   /* B1177070 added encoded key */
  x_routingstep_id    NUMBER    ,  /* B1177070 added encoded key */
/* NAMIT_MTQ */
  item_id             NUMBER  ,
  routingstep_no      NUMBER   ,
  aps_item_id         NUMBER,
  uom_conv_factor     NUMBER,
  min_trans_qty       NUMBER,
  min_delay           NUMBER,
  max_delay           NUMBER
);
TYPE gmp_material_assoc_tbl IS TABLE OF gmp_material_assoc_typ
INDEX BY BINARY_INTEGER;
mat_assoc_tab    gmp_material_assoc_tbl;

/* NAMIT_CR Define Step Dependency Record Type */

TYPE gmp_opr_stpdep_typ IS RECORD
(
  routing_id          NUMBER  ,
  x_dep_routingstep_id NUMBER    ,
  x_routingstep_id    NUMBER    ,
  dep_type            NUMBER   ,
  standard_delay      NUMBER,
  max_delay           NUMBER,
  transfer_pct        NUMBER,
  dep_routingstep_no  NUMBER   ,
  routingstep_no      NUMBER   ,
  chargeable_ind      NUMBER
);
 TYPE gmp_opr_stepdep_tab IS TABLE OF gmp_opr_stpdep_typ
 INDEX BY BINARY_INTEGER;
gmp_opr_stpdep_tbl gmp_opr_stepdep_tab;

/* GMD New Declaration of PL/SQL Tables for Activity and Resources Overrides */
TYPE recipe_orgn_override_typ IS RECORD
(
  routing_id          NUMBER    ,
  orgn_code           VARCHAR2(4),
  routingstep_id      NUMBER    ,
  oprn_line_id        NUMBER    ,
  recipe_id           NUMBER    ,
  activity_factor     NUMBER,
  resources           VARCHAR2(16),
  resource_usage      NUMBER,
  process_qty         NUMBER,
/* NAMIT_OC */
  min_capacity        NUMBER,
  max_capacity        NUMBER
);
TYPE recipe_orgn_override_tbl IS TABLE OF recipe_orgn_override_typ
INDEX BY BINARY_INTEGER;
rcp_orgn_override    recipe_orgn_override_tbl;

TYPE recipe_override_typ IS RECORD
(
  routing_id          NUMBER    ,
  routingstep_id      NUMBER    ,
  recipe_id           NUMBER    ,
  step_qty            NUMBER
);
TYPE recipe_override_tbl IS TABLE OF recipe_override_typ
INDEX BY BINARY_INTEGER;
recipe_override      recipe_override_tbl;
-- Routing steps offsets
TYPE gmp_routing_step_offsets_typ IS RECORD
(
plant_code 	VARCHAR2(4),
fmeff_id 	NUMBER,
formula_id	NUMBER,
routingstep_id	NUMBER,
start_offset	NUMBER,
end_offset	NUMBER,
formulaline_id	NUMBER
);
TYPE rtgstep_offsets_tbl IS TABLE OF gmp_routing_step_offsets_typ
INDEX BY BINARY_INTEGER ;
rstep_offsets	rtgstep_offsets_tbl;
--
/* SGIDUGU Seq Dep Table Definition */
TYPE gmp_sequence_typ IS RECORD
(
  oprn_id      NUMBER,
  category_id  NUMBER,
  seq_dep_id   NUMBER
);

seq_rec  gmp_sequence_typ;

TYPE gmp_setup_tbl  IS TABLE OF gmp_sequence_typ INDEX BY BINARY_INTEGER;
setupid_tab   gmp_setup_tbl ;

/* End of SGIDUGU Seq Dep Table Definition */

/* === OPM PLD Declaraion =====*/

/* Record definition for the a line in a production order. */
  TYPE product_typ IS RECORD(
    batch_no                    VARCHAR2(32),
    plant_code                  VARCHAR2(4),
    batch_id                    NUMBER,
    x_batch_id                  NUMBER,  /* B1177070 added encoded key */
    wip_whse_code               VARCHAR2(4),
    mtl_org_id                  NUMBER,
    routing_id                  NUMBER,
    start_date                  DATE,
    end_date                    DATE,
    trans_date                  DATE,
    batch_status                NUMBER,
    batch_type                  NUMBER,
    organization_id             NUMBER,
    whse_code                   VARCHAR2(4),
    item_id                     NUMBER,   /* Give a Unique Item Id Name */
    line_id                     NUMBER,
    line_no                     NUMBER,   /* B2919303 */
    tline_no                    NUMBER,   /* B2953953 - CoProducts */
    line_type                   NUMBER,
    tline_type                  NUMBER,   /* B2953953 - CoProducts */
    qty                         NUMBER,
    matl_item_id                NUMBER,   /* B1992371 for GME Changes */
    recipe_item_id              NUMBER,   /* B1992371 for GME Changes */
    poc_ind                     VARCHAR2(1),   /* B1992371, B2239948 for GME Changes */
    firmed_ind                  NUMBER,      /* B2821248 - Firmed Ind is added */
    batchstep_no                NUMBER,     /* B2919303 StepNo */
    matl_qty                    NUMBER,
    uom_conv_factor             NUMBER,
    requested_completion_date   DATE,
    schedule_priority		NUMBER,
    from_op_seq_id 		NUMBER,
    Minimum_Transfer_Qty	NUMBER,
    Minimum_Time_Offset	        NUMBER,
    Maximum_Time_Offset	        NUMBER,
    from_op_seq_num		NUMBER
   );
  TYPE product_tbl IS TABLE OF product_typ INDEX by BINARY_INTEGER;
  prod_tab   product_tbl;

/* definition for the resource data of a production order */
  TYPE rsrc_rec IS RECORD(
    batch_id                  NUMBER,
    x_batch_id                NUMBER,  /* B1177070 added encoded key */
    batchstep_no              NUMBER,  /* B1224660 added batchstep to record */
    seq_dep_ind               NUMBER,
    prim_rsrc_ind_order       NUMBER,
    resources                 VARCHAR2(16),
    instance_number           NUMBER,
    tran_seq_dep              NUMBER,
    plan_start_date           DATE,
    plant_code                VARCHAR2(4),
--    activity                VARCHAR2(16),	/* NAVIN: Remove this column. */
    prim_rsrc_ind             NUMBER,
    resource_id               NUMBER,
    x_resource_id             NUMBER,  /* B1177070 added encoded key */
    plan_rsrc_count           NUMBER,
    actual_rsrc_count         NUMBER,
    actual_start_date         DATE,
    plan_cmplt_date           DATE,
    actual_cmplt_date         DATE,
    step_status               NUMBER,
    resource_usage            NUMBER,
    resource_instance_usage   NUMBER,
    eqp_serial_number         VARCHAR2(30),   -- Bug 5713355
    scale_type                NUMBER,
    capacity_constraint       NUMBER ,
    plan_step_qty             NUMBER,
    min_xfer_qty              NUMBER,
    material_ind              NUMBER,
    schedule_flag             NUMBER,
--    offset_interval         NUMBER,
    act_start_date            DATE,
    utl_eff                   NUMBER,
    bs_activity_id            NUMBER,
    --NAVIN: START new field (added for 11.1.1.3 of Process Execution APS Patchset J.1 TDD)
    group_sequence_id	      NUMBER,
    group_sequence_number     NUMBER,
    firm_type	              NUMBER,
    setup_id	              NUMBER,
    minimum_capacity          NUMBER,
    maximum_capacity          NUMBER,
    sequence_dependent_usage  NUMBER,
    original_seq_num          NUMBER,
    org_step_status	      NUMBER,
    plan_charges	      NUMBER,
    plan_rsrc_usage	      NUMBER,
    actual_rsrc_usage	      NUMBER,
    batchstep_id              NUMBER,   /* Navin 6/23/2004 Added for resource charges*/
    mat_found                 NUMBER,
    breakable_activity_flag   NUMBER,
    usage_uom                 VARCHAR2(4), /*Sowmya - As Per the latest FDD changes */
    step_qty_uom              VARCHAR2(3),
    equp_item_id              NUMBER ,
    gmd_rsrc_count            NUMBER,
    step_start_date           DATE, /* msc_st_job_operations.reco_start_date */
    step_end_date             DATE,  /* msc_st_job_operations.reco_completion_date */
    efficiency                NUMBER /*B4320561 - sowsubra */
    );
  TYPE rsrc_dtl_tbl IS TABLE OF rsrc_rec INDEX by BINARY_INTEGER;
  rsrc_tab   rsrc_dtl_tbl;

/* Record and table definition for the MPS schedule details and the items and
   orgs that are associated by plant/whse eff. The schedule are used for MDS
   demand
*/
  TYPE sched_dtl_rec IS RECORD(
    schedule        	VARCHAR2(16),
    schedule_id     	NUMBER,
    order_ind       	NUMBER,
    stock_ind       	NUMBER,
    whse_code       	VARCHAR2(4),
    orgn_code       	VARCHAR2(4),
    organization_id 	NUMBER,
    inventory_item_id	NUMBER);

  TYPE sched_dtl_tbl IS TABLE OF sched_dtl_rec INDEX by BINARY_INTEGER;
  sched_dtl_tab     sched_dtl_tbl;

  /* Record and table definition for forecast detals */
  TYPE fcst_dtl_rec IS RECORD(
    inventory_item_id   NUMBER,
    organization_id     NUMBER,
    forecast_id         NUMBER,
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
    inventory_item_id   NUMBER,
    organization_id 	NUMBER,
    orgn_code           VARCHAR2(4),
    order_no            VARCHAR2(32),
    line_id             NUMBER,
    net_price           NUMBER,
    sched_shipdate      DATE,
    request_date        DATE,       /* B2971996 */
    trans_qty           NUMBER);

  TYPE sales_dtl_tbl IS TABLE OF sales_dtl_rec INDEX by BINARY_INTEGER;
  sales_dtl_tab     sales_dtl_tbl;

  /* Record and table definition for schedule forecast association */
  TYPE fcst_assoc_rec IS RECORD(
    schedule_id         NUMBER,
    forecast_id         NUMBER);

  TYPE fcst_assoc_tbl IS TABLE OF fcst_assoc_rec INDEX by BINARY_INTEGER;
  SCHD_FCST_DTL_TAB     fcst_assoc_tbl;

  /* Record and table definition for designators */
  TYPE desig_rec IS RECORD(
    designator      VARCHAR2(15),
    schedule        VARCHAR2(17),
    orgn_code       VARCHAR2(4),
    whse_code       VARCHAR2(4),
    organization_id NUMBER);

  TYPE desig_tbl IS TABLE OF desig_rec INDEX by BINARY_INTEGER;
  desig_tab         desig_tbl;

TYPE stp_chg_typ is RECORD(
  wip_entity_id	        NUMBER  ,
  operation_seq_id      NUMBER	,
  resource_id	        NUMBER	,
  charge_num	        NUMBER  ,
  organization_id       NUMBER  ,
  operation_seq_no      NUMBER	,
  resource_seq_num      NUMBER  ,
  charge_quantity       NUMBER	,
  charge_start_dt_time	DATE    ,
  charge_end_dt_time    DATE
  );

TYPE stp_chg_tab IS TABLE OF stp_chg_typ INDEX by BINARY_INTEGER;
stp_chg_tbl stp_chg_tab;

/* NAVIN :- Alternate Resource */
/* NAVIN: Alternate Resource selection   */
TYPE prod_alt_resource_typ IS RECORD
(
    prim_resource_id    NUMBER,
    alt_resource_id     NUMBER,
    runtime_factor      NUMBER,  /* B2353759,alternate runtime_factor */
    preference          NUMBER, /* B5688153 Prod spec alternates */
    item_id             NUMBER  /* B5688153 Prod spec alternates */
);
TYPE prod_alt_resource_tbl IS TABLE OF prod_alt_resource_typ INDEX by BINARY_INTEGER;
prod_alt_rsrc_tab       prod_alt_resource_tbl;

/* ---------------------------  Global declarations ------------------------ */
TYPE number_idx_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE date_idx_tbl IS TABLE OF DATE INDEX BY BINARY_INTEGER;
TYPE uom_code_tbl IS TABLE OF VARCHAR2(3) INDEX BY BINARY_INTEGER;
empty_number_table      number_idx_tbl;
empty_date_table       	date_idx_tbl ;
empty_uom_code_tbl	uom_code_tbl ;

bom_sr_instance_id  	number_idx_tbl;
bomc_sr_instance_id 	number_idx_tbl;
pef_sr_instance_id 	number_idx_tbl;
rtg_sr_instance_id 	number_idx_tbl;
or_sr_instance_id 	number_idx_tbl;
opr_sr_instance_id 	number_idx_tbl;
rs_sr_instance_id 	number_idx_tbl;
oc_sr_instance_id 	number_idx_tbl;
itm_mtq_sr_instance_id 	number_idx_tbl; /* NAMIT_MTQ */
opr_stpdep_sr_instance_id  number_idx_tbl; /* NAMIT_CR */

bom_organization_id  	   number_idx_tbl;
bomc_organization_id 	   number_idx_tbl;
pef_organization_id 	   number_idx_tbl;
rtg_organization_id 	   number_idx_tbl;
oc_organization_id 	   number_idx_tbl;
gt_organization_id 	   number_idx_tbl;
itm_mtq_organization_id    number_idx_tbl ; /* NAMIT_MTQ */
opr_stpdep_organization_id number_idx_tbl ;
opr_organization_id   	   number_idx_tbl ;
or_organization_id    	   number_idx_tbl ;
rs_organization_id    	   number_idx_tbl ;

bom_bill_sequence_id 	number_idx_tbl;
bomc_bill_sequence_id 	number_idx_tbl;
pef_bill_sequence_id 	number_idx_tbl;
oc_bill_sequence_id 	number_idx_tbl;

bom_last_update_date 	date_idx_tbl ;
bomc_last_update_date 	date_idx_tbl ;
pef_last_update_date 	date_idx_tbl ;
rtg_last_update_date 	date_idx_tbl ;
or_last_update_date 	date_idx_tbl ;
opr_last_update_date 	date_idx_tbl ;
rs_last_update_date 	date_idx_tbl ;
oc_last_update_date 	date_idx_tbl ;

bom_creation_date 	date_idx_tbl ;
bomc_creation_date 	date_idx_tbl ;
pef_creation_date 	date_idx_tbl ;
rtg_creation_date 	date_idx_tbl ;
or_creation_date 	date_idx_tbl ;
opr_creation_date 	date_idx_tbl ;
rs_creation_date 	date_idx_tbl ;
oc_creation_date 	date_idx_tbl ;

pef_effectivity_date 	date_idx_tbl   ;
bomc_effectivity_date 	date_idx_tbl   ;
opr_effectivity_date 	date_idx_tbl   ;
bomc_disable_date 	date_idx_tbl   ;

rtg_routing_sequence_id 	number_idx_tbl   ;
pef_routing_sequence_id 	number_idx_tbl   ;
or_routing_sequence_id 		number_idx_tbl   ;
opr_routing_sequence_id 	number_idx_tbl   ;
rs_routing_sequence_id 		number_idx_tbl   ;
oc_routing_sequence_id 		number_idx_tbl   ;
/* NAMIT_MTQ */
itm_mtq_routing_sequence_id 	number_idx_tbl   ;
/* NAMIT_CR */
opr_stpdep_routing_sequence_id 	number_idx_tbl   ;

bomc_uom_code  uom_code_tbl  ;
rtg_uom_code   uom_code_tbl ;
or_uom_code    uom_code_tbl ;
opr_uom_code   uom_code_tbl ;

bom_assembly_item_id 	number_idx_tbl ;
rtg_assembly_item_id 	number_idx_tbl ;

bomc_component_sequence_id 	number_idx_tbl;
oc_component_sequence_id 	number_idx_tbl;

or_operation_sequence_id  	number_idx_tbl   ;
opr_operation_sequence_id 	number_idx_tbl   ;
rs_operation_sequence_id 	number_idx_tbl   ;
oc_operation_sequence_id 	number_idx_tbl   ;

or_resource_seq_num 		number_idx_tbl   ;
rs_resource_seq_num 		number_idx_tbl   ;
/* SGIDUGU - Seq Dep */
or_setup_id     		number_idx_tbl   ;
gt_setup_id     		number_idx_tbl   ;
--
TYPE seq_dep_class_typ IS TABLE OF ic_item_mst.seq_dpnd_class%TYPE INDEX BY
BINARY_INTEGER;
gt_seq_dep_class     seq_dep_class_typ   ;
empty_seq_dep_class	seq_dep_class_typ ;
--
TYPE oprn_no_typ IS TABLE OF gmd_operations.oprn_no%TYPE INDEX BY
BINARY_INTEGER;
gt_oprn_no     oprn_no_typ ;
empty_oprn_no     oprn_no_typ ;

/* End of changes SGIDUGU - Seq Dep */

/* -------------------------------  BOM declarations --------------------------- */
TYPE alternate_bom_designator IS TABLE OF msc_st_boms.alternate_bom_designator%TYPE
INDEX BY BINARY_INTEGER;
bom_alternate_bom_designator alternate_bom_designator ;
empty_alternate_bom_designator alternate_bom_designator ;

TYPE specific_assembly_comment IS TABLE OF msc_st_boms.specific_assembly_comment%TYPE
INDEX BY BINARY_INTEGER;
bom_specific_assembly_comment specific_assembly_comment ;
empty_bom_assembly_comment specific_assembly_comment ;

bom_scaling_type 	number_idx_tbl ;
bom_assembly_quantity 	number_idx_tbl ;

TYPE uom IS TABLE OF msc_st_boms.uom%TYPE INDEX BY BINARY_INTEGER;
bom_uom 	uom ;
empty_bom_uom 	uom ;

/* NAMIT_CR For Step Material Assoc */
bom_op_seq_number 	number_idx_tbl;

/* NAMIT_OC For ingredients contribute_to_step_qty will
        store 1 for YES and 0 for NO */
bomc_contribute_to_step_qty 	number_idx_tbl;

bom_index INTEGER := 0 ;   /* BOM Global counter */

/* ---------------------------  BOM Components declarations ------------------------ */
bomc_Inventory_item_id 		number_idx_tbl;
bomc_using_assembly_id 		number_idx_tbl    ;
bomc_component_type 		number_idx_tbl    ;
bomc_scaling_type  		number_idx_tbl;
bomc_usage_quantity 		number_idx_tbl;
bomc_opr_offset_percent  	number_idx_tbl ;
bomc_optional_component  	number_idx_tbl ;
bomc_wip_supply_type 		number_idx_tbl ;
bomc_scale_multiple  		number_idx_tbl;
bomc_scale_rounding_variance 	number_idx_tbl ;
bomc_rounding_direction  	number_idx_tbl ;

bomc_index INTEGER := 0 ;   /* BOM component Global counter */

/* ---------------------------  Effectivity declarations ------------------------ */
pef_process_sequence_id 	number_idx_tbl   ;
pef_item_id             	number_idx_tbl ;
pef_disable_date 		date_idx_tbl   ;
pef_minimum_quantity 		number_idx_tbl   ;
pef_maximum_quantity 		number_idx_tbl   ;
pef_preference 			number_idx_tbl ;

pef_index INTEGER := 0 ;   /* Process Effectivity Global counter */

/* -------------------------------  Routng declarations  --------------------------- */
TYPE routing_comment IS TABLE OF msc_st_routings.routing_comment%TYPE
INDEX BY BINARY_INTEGER;
rtg_routing_comment routing_comment ;
empty_rtg_comment routing_comment ;


TYPE alt_routing_designator  IS TABLE OF msc_st_routings.alternate_routing_designator%TYPE
INDEX BY BINARY_INTEGER;
rtg_alt_routing_designator alt_routing_designator   ;
empty_rtg_designator alt_routing_designator   ;

TYPE routing_quantity IS TABLE OF msc_st_routings.routing_quantity%TYPE
INDEX BY BINARY_INTEGER;
rtg_routing_quantity 		number_idx_tbl   ;

/* NAMIT_CR For Calculate Step Dependency Flag */
rtg_auto_step_qty_flag 		number_idx_tbl  ;

rtg_index INTEGER := 0 ;   /* Routing Global counter */

/* -------------------------- Routng operations declarations  ------------------------ */
or_resource_id 		number_idx_tbl   ;
gt_resource_id 		number_idx_tbl   ;

or_alternate_number 		number_idx_tbl   ;
or_principal_flag 		number_idx_tbl   ;
or_basis_type 			number_idx_tbl   ;
or_resource_usage 		number_idx_tbl   ;
or_max_resource_units 		number_idx_tbl   ;
or_resource_units 		number_idx_tbl   ;
or_orig_rs_seq_num 		number_idx_tbl ;
or_break_ind 			number_idx_tbl;

or_index INTEGER := 0 ;   /* Operation Resource Global counter */
gt_index INTEGER := 0 ;   /* Operation Resource Global counter */

/* -------------------------- Operations declarations  ------------------------ */
opr_operation_seq_num 		number_idx_tbl   ;
opr_mtransfer_quantity 		number_idx_tbl   ;
opr_department_id 		number_idx_tbl ;
rs_department_id 		number_idx_tbl ;
rs_schedule_flag 	        number_idx_tbl ;
/* NAMIT_MTQ */
itm_mtq_from_op_seq_id 	        number_idx_tbl ;
/* NAMIT_CR */
opr_stpdep_frm_seq_id 	        number_idx_tbl ;
opr_stpdep_to_seq_id 	        number_idx_tbl ;
opr_stpdep_dependency_type      number_idx_tbl ;
/* NAMIT_CR */
itm_mtq_min_time_offset 	number_idx_tbl ;
itm_mtq_max_time_offset 	number_idx_tbl ;
rs_activity_group_id 		number_idx_tbl ;
opr_stpdep_min_time_offset 	number_idx_tbl ;
opr_stpdep_max_time_offset 	number_idx_tbl ;
opr_stpdep_trans_pct 		number_idx_tbl ;
itm_mtq_frm_op_seq_num 		number_idx_tbl ;
opr_stpdep_frm_op_seq_num 	number_idx_tbl ;
opr_stpdep_to_op_seq_num 	number_idx_tbl ;
opr_stpdep_app_to_chrg 		number_idx_tbl ;
itm_mtq_from_item_id 		number_idx_tbl ;
itm_mtq_min_tran_qty 		number_idx_tbl ;
or_minimum_capacity 		number_idx_tbl ;
or_maximum_capacity 		number_idx_tbl ;
opr_step_qty 			number_idx_tbl;

opr_step_qty_uom 		uom_code_tbl;

TYPE operation_description IS TABLE OF msc_st_routing_operations.operation_description%TYPE
INDEX BY BINARY_INTEGER;
opr_operation_description    operation_description   ;
empty_opr_description        operation_description   ;
TYPE department_code IS TABLE OF msc_st_routing_operations.department_code%TYPE
INDEX BY BINARY_INTEGER;
opr_department_code          department_code ;
empty_opr_department_code    department_code ;

opr_index INTEGER := 0 ;   /* Operation Global counter */
rs_index  INTEGER := 0 ;   /* Operation Global counter */
oc_index  INTEGER := 0 ;   /* Operation component Global counter */
/* NAMIT_MTQ */
mtq_index INTEGER := 0 ;   /* MTQ Global counter */

/* ------------------- Requirement declaration ---------------------*/

/* akaruppa B5007729 */
empty_num_table      number_idx_tbl;
rr_organization_id   number_idx_tbl;
s_organization_id    number_idx_tbl;
d_organization_id    number_idx_tbl;
f_organization_id    number_idx_tbl;
i_organization_id    number_idx_tbl;
o_organization_id    number_idx_tbl; -- akaruppa B4287033
arr_organization_id  number_idx_tbl; /* alternate resource declaration */
rr_activity_group_id number_idx_tbl; /* B3995361 rpatangy */

rr_sr_instance_id   number_idx_tbl;
s_sr_instance_id    number_idx_tbl;
d_sr_instance_id    number_idx_tbl;
f_sr_instance_id    number_idx_tbl;
i_sr_instance_id    number_idx_tbl;
o_sr_instance_id    number_idx_tbl; -- akaruppa B4287033
stp_instance_id     number_idx_tbl;
arr_sr_instance_id  number_idx_tbl; /* alternate resource declaration */

rr_supply_id         number_idx_tbl;
rr_resource_seq_num  number_idx_tbl;
rr_resource_id       number_idx_tbl;

rr_opr_hours_required number_idx_tbl ;
rr_usage_rate         number_idx_tbl ;
rr_assigned_units     number_idx_tbl ;
rr_department_id      number_idx_tbl ;

rr_wip_entity_id      number_idx_tbl ;
d_wip_entity_id       number_idx_tbl ;
f_wip_entity_id       number_idx_tbl ;

rr_operation_seq_num  number_idx_tbl;
s_operation_seq_num   number_idx_tbl;
d_operation_seq_num   number_idx_tbl;

rr_firm_flag                 number_idx_tbl ;
rr_minimum_transfer_quantity number_idx_tbl ;
rr_parent_seq_num            number_idx_tbl ;
rr_schedule_flag             number_idx_tbl ;
/* akaruppa B5007729 End*/

empty_dat_table  date_idx_tbl;
rr_start_date    date_idx_tbl;
rr_end_date      date_idx_tbl;

rr_hours_expended          number_idx_tbl ;
rr_breakable_activity_flag number_idx_tbl ;
rr_unadjusted_resource_hrs number_idx_tbl ; /* B4320561 - sowsubra */
rr_touch_time              number_idx_tbl; /* B4320561 - sowsubra */
rr_plan_step_qty           number_idx_tbl; /*Sowmya - As per latest FDD changes */

TYPE res_step_qty_uom IS TABLE OF VARCHAR2(3)
INDEX BY BINARY_INTEGER;
rre_step_qty_uom           res_step_qty_uom;
rr_step_qty_uom            res_step_qty_uom;  /*Sowmya - As per latest FDD changes */

rr_gmd_rsrc_cnt              number_idx_tbl; /*Sowmya - As per latest FDD changes */
rr_operation_sequence_id     number_idx_tbl ; /* B5461922 rpatangy */
jo_wip_entity_id             number_idx_tbl;
jo_instance_id               number_idx_tbl;
jo_operation_seq_num         number_idx_tbl;
jo_operation_sequence_id     number_idx_tbl;
jo_organization_id           number_idx_tbl;
jo_department_id             number_idx_tbl;
jo_minimum_transfer_quantity number_idx_tbl;

TYPE recommended_typ IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;
jo_recommended         recommended_typ;
jo_network_start_end   recommended_typ;
joe_recommended        recommended_typ;
joe_network_start_end  recommended_typ;

jo_reco_start_date      date_idx_tbl ;
jo_reco_completion_date date_idx_tbl ;

rr_index      NUMBER := 0 ;
arr_index     NUMBER := 0 ;
si_index      NUMBER := 0 ;
inst_indx     NUMBER := 0 ; /* NAVIN :- - For Resource Instance */
jo_index      NUMBER := 0; /* NAMIT :- For msc_st_job_operations */

/* ------------------- Supply declaration ---------------------*/

/* akaruppa B5007729 */
s_plan_id               number_idx_tbl  ;
o_plan_id               number_idx_tbl  ; -- akaruppa B4287033
s_inventory_item_id     number_idx_tbl ;
d_inventory_item_id     number_idx_tbl ;
f_inventory_item_id     number_idx_tbl ;
o_inventory_item_id     number_idx_tbl ; -- akaruppa B4287033
rr_inventory_item_id    number_idx_tbl ; -- HW B4902328

s_new_schedule_date     date_idx_tbl ;
o_new_schedule_date     date_idx_tbl ; -- akaruppa B4287033
s_old_schedule_date     date_idx_tbl ;
s_new_wip_start_date    date_idx_tbl ;
s_old_wip_start_date    date_idx_tbl ;
s_lunit_completion_date date_idx_tbl ;
s_disposition_id        number_idx_tbl ;
s_order_type            number_idx_tbl ;
o_order_type            number_idx_tbl ; -- akaruppa B4287033
/* akaruppa B5007729 End*/

TYPE order_number IS TABLE OF msc_st_supplies.order_number%TYPE INDEX BY BINARY_INTEGER;
s_order_number  order_number ;
se_order_number order_number ;/* akaruppa B5007729 */

/* akaruppa B5007729 */
s_new_order_quantity number_idx_tbl ;
o_new_order_quantity number_idx_tbl ; -- akaruppa B4287033
s_old_order_quantity number_idx_tbl ;
s_firm_planned_type  number_idx_tbl ;
o_firm_planned_type  number_idx_tbl ; -- akaruppa B4287033
/* akaruppa B5007729 End*/

TYPE wip_entity_name IS TABLE OF msc_st_supplies.wip_entity_name%TYPE INDEX BY BINARY_INTEGER;
s_wip_entity_name  wip_entity_name   ;
se_wip_entity_name wip_entity_name ;/* akaruppa B5007729 */

TYPE lot_number IS TABLE OF msc_st_supplies.lot_number%TYPE INDEX BY BINARY_INTEGER;
s_lot_number lot_number ;
o_lot_number lot_number ; -- akaruppa B4287033
e_lot_number lot_number ; /* akaruppa B5007729 */

/* akaruppa B5007729 */
s_expiration_date          date_idx_tbl ;
o_expiration_date          date_idx_tbl ; -- akaruppa B4287033
s_firm_quantity            number_idx_tbl ;
s_firm_date                date_idx_tbl ;
s_by_product_using_assy_id number_idx_tbl ;
/* akaruppa B5007729 End*/

s_requested_completion_date     date_idx_tbl ;

TYPE stp_schedule_priority IS TABLE OF msc_st_supplies.schedule_priority%TYPE
INDEX BY BINARY_INTEGER;
s_schedule_priority  stp_schedule_priority;

/*B5100481 - 16 for pending, 3 for wip*/
s_wip_status_code            number_idx_tbl;

/* NAVIN: MTQ with Hardlinks */
stp_var_itm_instance_id      number_idx_tbl;
stp_var_itm_from_op_seq_id   number_idx_tbl;
stp_var_itm_wip_entity_id    number_idx_tbl;
stp_var_itm_from_item_id     number_idx_tbl;
stp_var_min_tran_qty         number_idx_tbl;
stp_var_itm_min_tm_off       number_idx_tbl;
stp_var_itm_max_tm_off       number_idx_tbl;
stp_var_itm_from_op_seq_num  number_idx_tbl;
stp_var_itm_organization_id  number_idx_tbl;

s_index      NUMBER := 0 ;

/* ---------------- Demands declaration ----------------------*/

/* akaruppa B5007729 */
d_assembly_item_id number_idx_tbl ;
f_assembly_item_id number_idx_tbl ;

d_demand_date date_idx_tbl ;
f_demand_date date_idx_tbl ;

d_requirement_quantity number_idx_tbl;
f_requirement_quantity number_idx_tbl;

d_demand_type number_idx_tbl ;
f_demand_type number_idx_tbl ;

d_origination_type number_idx_tbl ;
f_origination_type number_idx_tbl ;
/* akaruppa B5007729 End*/

TYPE demand_schedule IS TABLE OF msc_st_demands.demand_schedule_name%TYPE
INDEX BY BINARY_INTEGER;
d_demand_schedule demand_schedule;
f_demand_schedule demand_schedule;
e_demand_schedule demand_schedule;/* akaruppa B5007729 */

TYPE dorder_number IS TABLE OF msc_st_demands.order_number%TYPE INDEX BY BINARY_INTEGER;
d_order_number dorder_number ;
f_order_number dorder_number ;
e_order_number dorder_number ;/* akaruppa B5007729 */

TYPE dwip_entity_name IS TABLE OF msc_st_demands.wip_entity_name%TYPE INDEX BY BINARY_INTEGER;
d_wip_entity_name     dwip_entity_name   ;
f_wip_entity_name     dwip_entity_name   ;
e_wip_entity_name     dwip_entity_name   ;/* akaruppa B5007729 */

/* akaruppa B5007729 */
d_selling_price    number_idx_tbl;
f_selling_price    number_idx_tbl;

d_request_date     date_idx_tbl ;
f_request_date     date_idx_tbl ;

TYPE forecast_designator IS TABLE OF msc_st_demands.forecast_designator%TYPE
INDEX BY BINARY_INTEGER;
f_forecast_designator  forecast_designator ;
e_forecast_designator  forecast_designator ;/* akaruppa B5007729 */

f_sales_order_line_id  number_idx_tbl; /* akaruppa B5007729 */

/*B5100481 - 16 for pending, 3 for wip*/
d_wip_status_code      number_idx_tbl;

d_index      NUMBER := 0 ;

/* ---------------- Designator declaration ----------------------*/
TYPE designator IS TABLE OF msc_st_designators.designator%TYPE INDEX BY BINARY_INTEGER;
i_designator designator ;
e_designator designator ;/* akaruppa B5007729 */

TYPE forecast_set IS TABLE OF msc_st_designators.forecast_set%TYPE INDEX BY BINARY_INTEGER;
i_forecast_set forecast_set;
e_forecast_set forecast_set;/* akaruppa B5007729 */

TYPE description IS TABLE OF msc_st_designators.description%TYPE INDEX BY BINARY_INTEGER;
i_description description ;
e_description description ;/* akaruppa B5007729 */

i_disable_date               date_idx_tbl ;/* akaruppa B5007729 */
i_consume_forecast           number_idx_tbl;/* akaruppa B5007729 */
i_backward_update_time_fence number_idx_tbl;/* akaruppa B5007729 */
i_forward_update_time_fence  number_idx_tbl;/* akaruppa B5007729 */

i_index      NUMBER := 0 ;

/* akaruppa B4287033  OnHand Declarations */
o_new_dock_date   date_idx_tbl ;/* akaruppa B5007729 */

o_deleted_flag    number_idx_tbl;/* akaruppa B5007729 */

TYPE subinventory_code IS TABLE OF msc_st_supplies.subinventory_code%TYPE
INDEX BY BINARY_INTEGER;
o_subinventory_code subinventory_code   ;
e_subinventory_code subinventory_code   ;/* akaruppa B5007729 */

o_non_nettable_qty number_idx_tbl;/* akaruppa B5007729 */

-- Rajesh Patangya 02-MAY-2006 Starts

stp_chg_department_id      number_idx_tbl ;
stp_chg_resource_id        number_idx_tbl ;
stp_chg_organization_id    number_idx_tbl ;
stp_chg_wip_entity_id      number_idx_tbl ;
stp_chg_operation_seq_id   number_idx_tbl ;
stp_chg_operation_seq_no   number_idx_tbl ;
stp_chg_resource_seq_num   number_idx_tbl ;
stp_chg_charge_num         number_idx_tbl ;
stp_chg_charge_quanitity   number_idx_tbl ;

-- Rajesh Patangya 02-MAY-2006 Ends

TYPE stp_charge_start_dt_time IS TABLE OF msc_st_resource_charges.charge_start_datetime%TYPE
INDEX BY BINARY_INTEGER;
stpe_chg_charge_start_dt_time stp_charge_start_dt_time ;
stp_chg_charge_start_dt_time  stp_charge_start_dt_time ;

TYPE stp_charge_end_dt_time IS TABLE OF msc_st_resource_charges.charge_end_datetime%TYPE
INDEX BY BINARY_INTEGER;
stpe_chg_charge_end_dt_time stp_charge_end_dt_time ;
stp_chg_charge_end_dt_time  stp_charge_end_dt_time ;

--------------------------NAVIN: Sequence Dependencies--------------------------

-- Rajesh Patangya 02-MAY-2006 Starts

rr_sequence_id           number_idx_tbl ;
rr_sequence_number       number_idx_tbl ;
rr_setup_id              number_idx_tbl ;

TYPE rsrc_firm_type IS TABLE OF msc_st_resource_requirements.firm_flag %TYPE
INDEX BY BINARY_INTEGER;
rr_firm_type rsrc_firm_type;

/* NAVIN: new column for Operation Charges*/
rr_min_capacity               number_idx_tbl;
rr_max_capacity               number_idx_tbl;
rr_original_seq_num           number_idx_tbl;
rr_sequence_dependent_usage   number_idx_tbl;
rr_alternate_number           number_idx_tbl;
rr_basis_type                 number_idx_tbl;

/* NAVIN :- Resource Instances start */

rec_inst_supply_id            number_idx_tbl;
rec_inst_organization_id      number_idx_tbl;
rec_inst_sr_instance_id       number_idx_tbl;
rec_inst_rec_resource_seq_num number_idx_tbl;
rec_inst_resource_id          number_idx_tbl;
rec_inst_instance_id          number_idx_tbl;
rec_inst_start_date           date_idx_tbl ;
rec_inst_end_date             date_idx_tbl ;
rec_inst_rsrc_instance_hours  number_idx_tbl;
rec_inst_operation_seq_num    number_idx_tbl;
rec_inst_department_id        number_idx_tbl;
rec_inst_wip_entity_id        number_idx_tbl;

-- Begin Bug 5713355
TYPE rec_serial_number IS TABLE OF msc_st_resource_instance_reqs.serial_number%TYPE
INDEX BY BINARY_INTEGER;
empty_inst_serial_number      rec_serial_number ;
rec_inst_serial_number        rec_serial_number;
-- End Bug 5713355
rec_inst_parent_seq_num       number_idx_tbl;
rec_inst_original_seq_num     number_idx_tbl;
rec_inst_equp_item_id         number_idx_tbl;

/* NAVIN :- Resource Instances end */

/*-------------------------- Alternate Resources -----------------------------*/

/* Sowmya - As Per the latest FDD changes :- Alternate resources declaration Start */

TYPE alt_resource_varchar_typ IS TABLE OF VARCHAR2(4)
INDEX BY BINARY_INTEGER;
arre_uom_code              alt_resource_varchar_typ;
arr_uom_code               alt_resource_varchar_typ;

arr_wip_entity_id          number_idx_tbl;
arr_operation_seq_num      number_idx_tbl;
arr_res_seq_num            number_idx_tbl;
arr_resource_id            number_idx_tbl;
arr_alternate_num          number_idx_tbl;
arr_usage_rate             number_idx_tbl;
arr_assigned_units         number_idx_tbl;
arr_department_id          number_idx_tbl;
arr_activity_group_id      number_idx_tbl;
arr_basis_type             number_idx_tbl;
arr_setup_id               number_idx_tbl;
arr_schedule_seq_num       number_idx_tbl;
arr_maximum_assigned_units number_idx_tbl;

/* Sowmya - As Per latest FDD changes :- Alternate resources declaration Ends */

/*===== Calendar Declaration ===========*/

TYPE cal_shift_typ is RECORD
( cal_date    DATE,
  shift_num   NUMBER,
  from_time   NUMBER,
  to_time     NUMBER
);
calendar_record  cal_shift_typ;
TYPE cal_tab is table of cal_shift_typ index by BINARY_INTEGER;
new_rec  cal_tab;

TYPE cal_detail_typ is RECORD
(calendar_id        NUMBER,
 calendar_no        VARCHAR2(16),
 calendar_desc      VARCHAR2(40),
 orgn_code          VARCHAR2(4),
 resource_whse_code VARCHAR2(4),
 organization_id    NUMBER,
 posted             NUMBER
);
cursor_rec  cal_detail_typ;
TYPE tab_cal_typ is table of cal_detail_typ INDEX BY BINARY_INTEGER;
plsqltbl_rec  tab_cal_typ;

resource_count    number_idx_tbl;
resource_id       number_idx_tbl;
instance_id       number_idx_tbl;
x_resource_id     number_idx_tbl;
x_instance_id     number_idx_tbl;
instance_number   number_idx_tbl;
shift_num         number_idx_tbl;
equipment_item_id number_idx_tbl;

f_date           date_idx_tbl;
t_date           date_idx_tbl;

TYPE serial_number IS TABLE OF msc_st_net_res_inst_avail.serial_number%TYPE
INDEX BY BINARY_INTEGER;
emp_serial_number  serial_number;
msc_serial_number  serial_number;

/*
REM+=========================================================================+
REM| PROCEDURE NAME                                                          |
REM|    retrieve_effectivities                                               |
REM|                                                                         |
REM| TYPE                                                                    |
REM|    Private                                                              |
REM|                                                                         |
REM| DESCRIPTION                                                             |
REM|    The majority of the logic in this procedure is contained in the four |
REM|    cursors. There is one for each type of effectivity as follows:       |
REM|      case 1: Effectivity has an organisation and a routing              |
REM|      case 2: Effectivity has an organisation but no routing             |
REM|      case 3: Effectivity has no organisation but has a routing          |
REM|      case 4: Effectivity has no organisation and no routing             |
REM|    Depending on each case above, the retrieval logic differs slightly   |
REM|    as does the source of some the values which come back. To make it    |
REM|    simpler to understand (and maintain) each case was dealt             |
REM|    with on its own. By putting as much logic as possible in the SQL it  |
REM|    was hoped to optimise the database accesses and make the code itself |
REM|    simpler.                                                             |
REM|                                                                         |
REM| INPUT PARAMETERS                                                        |
REM|    none                                                                 |
REM|                                                                         |
REM| OUTPUT PARAMETERS                                                       |
REM|    return_status  TRUE=> OK                                             |
REM|                                                                         |
REM| INPUT/OUTPUT PARAMETERS                                                 |
REM|    None                                                                 |
REM|                                                                         |
REM| HISTORY                                                                 |
REM|    Created 12th July 1999 by P.J.Schofield (OPM Development Oracle UK)  |
REM|    04/03/2000 - Using organization_id from gmp_item_aps , instead of    |
REM|                 organization_id from sy_orgn_mst, Bug# 1252322          |
REM| 07/14/2002   Rajesh Patangya - Reorgnized the complete code B2314052    |
REM| 01/14/2003   Sridhar Gidugu  - Using gia.uom_code instead of gia.item_um|
REM|                                Bug# 2739627                             |
REM| 06/02/2003   Sridhar Gidugu  - B2989806 - Forward port fix for          |
REM|                                Bug#2916619 - Rewrote Effectivity Cursor |
REM+=========================================================================+
*/
PROCEDURE retrieve_effectivities
(
  return_status  OUT NOCOPY BOOLEAN
)
IS
  c_formula_effectivity   ref_cursor_typ;
  cur_routing_hdr     ref_cursor_typ;
  cur_routing_dtl     ref_cursor_typ;
  cur_formula_dtl     ref_cursor_typ;
  cur_formula_hdr     ref_cursor_typ;
  cur_mat_assoc       ref_cursor_typ;
  cur_alt_resource    ref_cursor_typ;
  c_recipe_override   ref_cursor_typ;
  c_recipe_orgn       ref_cursor_typ;
  c_uom_conv          ref_cursor_typ; /*B2870041 uom conversion cursor*/
  cur_rtg_offsets     ref_cursor_typ;
  cur_opr_stpdep      ref_cursor_typ;
  seq_dep_dtl         ref_cursor_typ;
  setup_id_dtl        ref_cursor_typ;
  uom_code_ref        ref_cursor_typ;
  um_code_ref         ref_cursor_typ;
  v_gmd_cursor 	      ref_cursor_typ;

  routing_dtl_cursor      VARCHAR2(32700) ;
  validation_statement    VARCHAR2(32700) ;
  retrieval_cursor        VARCHAR2(32700) ;
  effectivity_cursor      VARCHAR2(32700) ;
  formula_hdr_cursor      VARCHAR2(32700) ;
  formula_dtl_cursor      VARCHAR2(32700) ;
  routing_hdr_cursor      VARCHAR2(32700) ;
  mat_assoc_cursor        VARCHAR2(32700) ;
  recipe_orgn_statement   VARCHAR2(32700) ;
  recipe_statement        VARCHAR2(32700) ;
  uom_conv_cursor         VARCHAR2(32700) ; /*B2870041 hold sql for uom conv*/
  rtg_offset_cur_stmt     VARCHAR2(32700) ;
  opr_stpdep_cursor       VARCHAR2(32700) ;
  seq_dep_cursor          VARCHAR2(32700) ;
  setup_id_cursor         VARCHAR2(32700) ;
  uom_code_cursor         VARCHAR2(4000);
  um_code_cursor          VARCHAR2(4000);

  valid                   BOOLEAN ;
  routing_valid           BOOLEAN ;
  old_fmeff_id            NUMBER ;
  old_organization_id     NUMBER ;
  old_formula_id          NUMBER ;
  mat_start_indx          NUMBER ;
  mat_end_indx            NUMBER ;
  eff_counter		  INTEGER ;
  old_plant_code          VARCHAR2(4) ;
  s                       INTEGER ;
  temp_total_qty          NUMBER ; /*B2870041 temp var to calculate total output*/
  v_matl_qty              NUMBER ; /*B2870041 cursor var to get uom conv qty */
  spl_cnt                 NUMBER ;
  j                       NUMBER ; /*B2870041 for loop index*/
  end_index               NUMBER ; /*B2870041 for loop index*/
  old_route               NUMBER ; /*B2870041 for loop index*/
  old_orgn                VARCHAR2(4); /*B2870041 for loop index*/
  old_step                NUMBER ; /*B2870041 for loop index*/
  ri                      NUMBER ; /*B2870041 for loop index*/
  found                   NUMBER ; /*B2870041 for loop index*/
/* NAMIT_OC */
  found_chrg_rsrc         NUMBER ;
  chrg_activity           VARCHAR2(16) ;
  first_step_row          NUMBER ; /*B2870041 for loop index*/
  l_gmp_um_code           VARCHAR2(25) ;
  v_dummy                 NUMBER ;
  nullenddatefound        BOOLEAN;  /* bug: 5872693 Vpedarla 12-Feb-2007 */

BEGIN
g_fm_dtl_start_loc        := 0; /* Start detail location */
g_fm_dtl_end_loc          := 0; /* End detail location */
g_fm_hdr_loc              := 1; /* Starting for formula header */
g_formula_orgn_count_tab  := 1; /* Starting for formula orgn detail */

g_rstep_loc               := 1 ;
g_curr_rstep_loc	  := -1 ;
g_prev_formula_id         := -1 ;
g_prev_locn               := 1;

  routing_dtl_cursor      := NULL;
  validation_statement    := NULL;
  retrieval_cursor        := NULL;
  effectivity_cursor      := NULL;
  formula_hdr_cursor      := NULL;
  formula_dtl_cursor      := NULL;
  routing_hdr_cursor      := NULL;
  mat_assoc_cursor        := NULL;
  recipe_orgn_statement   := NULL;
  recipe_statement        := NULL;
  uom_conv_cursor         := NULL;
  rtg_offset_cur_stmt     := NULL;
  opr_stpdep_cursor       := NULL ;
  seq_dep_cursor          := NULL ;
  setup_id_cursor         := NULL ;
  old_plant_code          := NULL ;
  old_orgn                := NULL;
  chrg_activity           := NULL ;
  l_gmp_um_code           := NULL ;
  uom_code_cursor         := NULL ;
  um_code_cursor          := NULL ;

  valid                   := FALSE;
  routing_valid           := FALSE ;
  nullenddatefound        := FALSE;  /* bug: 5872693 Vpedarla 12-Feb-2007 */

  old_fmeff_id            := 0  ;
  old_organization_id     := 0  ;
  old_formula_id          := 0  ;
  mat_start_indx          := 0  ;
  mat_end_indx            := 0  ;
  eff_counter		  := 0 ;
  temp_total_qty          := 0  ;
  v_matl_qty              := 0  ;
  spl_cnt                 := 0 ;
  j                       := 0 ;
  end_index               := 0 ;
  old_route               := 0 ;
  old_step                := 0 ;
  ri                      := 0 ;
  found                   := 0 ;
  found_chrg_rsrc         := 0 ;
  first_step_row          := 0 ;
  v_dummy                 := 0 ;
  s                       := 1 ;

dbms_session.free_unused_user_memory;/* akaruppa B5007729 */

/* populate the org_string    */
     IF MSC_CL_GMP_UTILITY.org_string(g_instance_id) THEN
        NULL ;
     ELSE
        log_message(MSC_CL_GMP_UTILITY.g_in_str_org);
        RAISE invalid_string_value  ;
     END IF;

--       l_in_str_org := 'IN (1381,1382,1383,1383,5172)' ;
    l_in_str_org := MSC_CL_GMP_UTILITY.g_in_str_org ;  /* B3491625 */

/*B2870041 changed cursor to retrieve the just the routing qty no uom conv,
added uom conv of the product to the routing uom for a qty of 1 to get the
factor. The factor will be used later. added product index to allow access
when we are writing out the routing */
    /* The query is being modified to incorporate changes for 1830940 */
/* B2989806 Added inline tables and outer joins to select aps_fmeff_id */

/* NAMIT UOM Change, This should come from source */
    um_code_cursor   := ' select fnd_profile.VALUE' ||at_apps_link
                      ||' (''SY$UOM_HOURS'') from dual ' ; /* OPM UOM */

       OPEN um_code_ref FOR um_code_cursor ;
       FETCH um_code_ref INTO l_gmp_um_code;
       CLOSE um_code_ref;

    IF l_gmp_um_code IS NOT NULL THEN
/* Get the UOM code and UOM Class corresponding to "GMP: UOM for Hour" Profile */
       uom_code_cursor :=
                      ' select um_type '
                      ||' from sy_uoms_mst'||at_apps_link
                      ||' where um_code = :gmp_um_code ';
/* mattt the comparison is done against um_code not unit_of_measure */
-- ||' where unit_of_measure = :gmp_um_code ';

       OPEN uom_code_ref FOR uom_code_cursor USING l_gmp_um_code;
       FETCH uom_code_ref INTO g_gmp_uom_class;
       CLOSE uom_code_ref;
    ELSE
         RAISE invalid_gmp_uom_profile  ;
    END IF;
    IF (g_gmp_uom_class IS NULL) THEN
         RAISE invalid_gmp_uom_profile  ;
    END IF;

    effectivity_cursor :=
                   ' SELECT eff.recipe_validity_rule_id, '
                   ||' nvl(gfe.aps_fmeff_id,-1),eff.item_id, '
                   ||' eff.formula_id,eff.lorgn_code, eff.organization_id, '
                   ||' eff.start_date, eff.end_date, eff.inv_min_qty, '
                   ||' eff.inv_max_qty, eff.preference, eff.uom_code, '
                   ||' eff.wcode, eff.routing_id, '
                   ||' eff.routing_no, eff.routing_vers, eff.routing_desc, '
                   ||' eff.item_um, eff.routing_qty, '
                   ||' eff.prd_fct  , eff.prd_ind, '
                   ||' eff.aps_item_id, eff.recipe_id, eff.rhdr_loc, '
                   ||' decode(eff.calculate_step_quantity,0,2,1) calculate_step_quantity, '
                   ||' eff.category_id,NULL , '
                   ||' eff.seq_dpnd_class '
                   ||' FROM (  '
                   ||' SELECT ffe.recipe_validity_rule_id, ffe.item_id, '
                   ||' grb.formula_id, ffe.orgn_code lorgn_code, gia.organization_id, '
		   ||' ffe.start_date, ffe.end_date, ffe.inv_min_qty, '
		   ||' ffe.inv_max_qty, ffe.preference, gia.uom_code, '
                   ||' som.resource_whse_code wcode , grb.routing_id, '
		   ||' frh.routing_no, frh.routing_vers, frh.routing_desc, '
                   ||' frh.item_um, frh.routing_qty, ' /*B2870041*/
                   ||' DECODE(frh.item_um,gia.item_um ,1, '
                   ||'        GMICUOM.uom_conversion'||at_apps_link
                   ||'                 (ffe.item_id, '
                   ||'                 0, '
                   ||'                 1, '
                   ||'                 gia.item_um , '   /* primary */
                   ||'                 frh.item_um , '   /* routing um */
                   ||'                 0 '
                   ||'                 ) '
                   ||'         ) prd_fct, -1 prd_ind, '
                   ||' gia.aps_item_id, grb.recipe_id, 0 rhdr_loc, '
                   ||' grb.calculate_step_quantity,'
		   || ' gia.category_id,NULL, '
                   ||' gia.seq_dpnd_class '
		   ||' FROM  gmd_recipes_b'||at_apps_link||' grb,'
		   ||'       gmd_recipe_validity_rules'||at_apps_link||' ffe,'
		   ||'       fm_form_mst'||at_apps_link||' ffm,'
		   ||'       fm_rout_hdr'||at_apps_link||' frh,'
		   ||'       sy_orgn_mst'||at_apps_link||' som,'
		   ||'       gmp_item_aps'||at_apps_link||' gia,'
		   ||'       gmd_status_b'||at_apps_link||' gs1,'
		   ||'       gmd_status_b'||at_apps_link||' gs2,'
		   ||'       gmd_status_b'||at_apps_link||' gs3,'
		   ||'       gmd_status_b'||at_apps_link||' gs4 '
                   ||' WHERE grb.delete_mark = 0 '
                   ||'   AND grb.recipe_id = ffe.recipe_id '
                   ||'   AND grb.recipe_status = gs1.status_code '
                   ||'   AND gs1.status_type IN (' ||'''700'''|| ',' ||''' 900'''|| ') '
                   ||'   AND gs1.delete_mark = 0 '
                   ||'   AND ffe.delete_mark = 0 '
                   ||'   AND ffe.validity_rule_status = gs2.status_code '
                   ||'   AND gs2.status_type IN (' ||'''700'''|| ',' ||''' 900'''|| ') '
                   ||'   AND gs2.delete_mark = 0 '
                   ||'   AND frh.delete_mark = 0 '
                   ||'   AND ffm.delete_mark = 0 '
                   ||'   AND som.delete_mark = 0 '
                   ||'   AND frh.inactive_ind = 0 '
                   ||'   AND ffm.inactive_ind = 0 '
                   ||'   AND grb.routing_id IS NOT NULL '
                   ||'   AND ffe.orgn_code IS NOT NULL '
                   ||'   AND ffe.recipe_use IN (0,1) '
                   ||'   AND nvl(ffe.end_date,(SYSDATE + 1)) > SYSDATE '
                   ||'   AND ffe.orgn_code = som.orgn_code '
                   ||'   AND grb.formula_id = ffm.formula_id '
                   ||'   AND ffm.formula_status = gs3.status_code '
                   ||'   AND gs3.status_type IN (' ||'''700'''|| ',' ||''' 900'''|| ') '
                   ||'   AND gs3.delete_mark = 0 '
                   ||'   AND grb.routing_id =  frh.routing_id '
                   ||'   AND frh.routing_status =  gs4.status_code '
                   ||'   AND gs4.status_type IN (' ||'''700'''|| ',' ||''' 900'''|| ') '
                   ||'   AND gs4.delete_mark = 0 '
                   ||'   AND gia.plant_code =  ffe.orgn_code '
                   ||'   AND gia.item_id =  ffe.item_id '
                   ||'   AND gia.whse_code = som.resource_whse_code '
                   ||'   AND gia.replen_ind = 1 '
                   ||'   AND EXISTS ( SELECT 1 '
                   ||'          FROM  fm_matl_dtl'||at_apps_link||' '
                   ||'          WHERE formula_id = grb.formula_id '
                   ||'            AND line_type = 1 '
                   ||'            AND item_id = ffe.item_id ) '
                   ||' UNION ALL '
                   ||' SELECT ffe.recipe_validity_rule_id, ffe.item_id, '
                   ||' grb.formula_id, ffe.orgn_code lorgn_code, gia.organization_id, '
                   ||' ffe.start_date, ffe.end_date, ffe.inv_min_qty, '
                   ||' ffe.inv_max_qty, ffe.preference, gia.uom_code, '
                   ||' gia.whse_code wcode , to_number(null) , '
		   ||' NULL, to_number(null), NULL, '
                   ||' NULL, to_number(null), to_number(null) prd_fct, -1 prd_ind, '
                   ||' gia.aps_item_id, grb.recipe_id, 0 rhdr_loc, '
/* NAMIT_CR,SGIDUGU */
                   ||' 0 calculate_step_quantity, '
                   ||' gia.category_id,NULL, '
                   ||' gia.seq_dpnd_class '
		   ||' FROM  gmd_recipes_b'||at_apps_link||' grb,'
		   ||'       gmd_recipe_validity_rules'||at_apps_link||' ffe,'
		   ||'       fm_form_mst'||at_apps_link||' ffm, '
		   ||'       sy_orgn_mst'||at_apps_link||' som, '
		   ||'       gmp_item_aps'||at_apps_link||' gia, '
		   ||'       gmd_status_b'||at_apps_link||' gs1,'
		   ||'       gmd_status_b'||at_apps_link||' gs2,'
		   ||'       gmd_status_b'||at_apps_link||' gs3 '
                   ||' WHERE  grb.delete_mark = 0 '
                   ||'   AND grb.recipe_id = ffe.recipe_id '
                   ||'   AND grb.recipe_status = gs1.status_code '
                   ||'   AND gs1.status_type IN (' ||'''700'''|| ',' ||''' 900'''|| ') '
                   ||'   AND gs1.delete_mark = 0 '
                   ||'   AND ffe.delete_mark = 0 '
                   ||'   AND ffe.validity_rule_status = gs2.status_code '
                   ||'   AND gs2.status_type IN (' ||'''700'''|| ',' ||''' 900'''|| ') '
                   ||'   AND gs2.delete_mark = 0 '
                   ||'   AND ffm.delete_mark = 0 '
                   ||'   AND som.delete_mark = 0 '
                   ||'   AND ffm.inactive_ind = 0 '
                   ||'   AND grb.routing_id IS NULL '
                   ||'   AND ffe.orgn_code IS NOT NULL '
                   ||'   AND ffe.orgn_code = som.orgn_code '
                   ||'   AND ffe.recipe_use IN (0,1) '
                   ||'   AND nvl(ffe.end_date,(SYSDATE + 1)) > SYSDATE '
                   ||'   AND grb.formula_id = ffm.formula_id '
                   ||'   AND ffm.formula_status = gs3.status_code '
                   ||'   AND gs3.status_type IN (' ||'''700'''|| ',' ||''' 900'''|| ') '
                   ||'   AND gs3.delete_mark = 0 '
                   ||'   AND gia.plant_code =  ffe.orgn_code '
                   ||'   AND gia.item_id =  ffe.item_id '
                   ||'   AND gia.whse_code = som.resource_whse_code '
                   ||'   AND gia.replen_ind = 1 '
                   ||'   AND EXISTS ( SELECT 1 '
                   ||'          FROM  fm_matl_dtl'||at_apps_link||' '
                   ||'          WHERE formula_id = grb.formula_id '
                   ||'            AND line_type = 1 '
                   ||'            AND item_id = ffe.item_id ) '
                   ||' UNION ALL '
                   ||' SELECT ffe.recipe_validity_rule_id, ffe.item_id, '
                   ||' grb.formula_id, gia.plant_code lorgn_code, gia.organization_id, '
                   ||' ffe.start_date, ffe.end_date, ffe.inv_min_qty, '
                   ||' ffe.inv_max_qty, ffe.preference, gia.uom_code, '
                   ||' som.resource_whse_code wcode , grb.routing_id, '
                   ||' frh.routing_no, frh.routing_vers, frh.routing_desc, '
                   ||' frh.item_um, frh.routing_qty,' /*B2870041*/
                   ||' DECODE(frh.item_um,gia.item_um, 1, '
                   ||'        GMICUOM.uom_conversion'||at_apps_link
                   ||'                 (ffe.item_id, '
                   ||'                 0, '
                   ||'                 1, '
                   ||'                 gia.item_um , '   /* primary */
                   ||'                 frh.item_um , '   /* routing um */
                   ||'                 0 '
                   ||'                 ) '
                   ||'         ) prd_fct, -1 prd_ind, '
                   ||' gia.aps_item_id, grb.recipe_id, 0 rhdr_loc, '
/* NAMIT_CR,SGIDUGU */
                   ||' grb.calculate_step_quantity, '
                   ||' gia.category_id,NULL, '
                   ||' gia.seq_dpnd_class '
		   ||' FROM  gmd_recipes_b'||at_apps_link||' grb,'
		   ||'       gmd_recipe_validity_rules'||at_apps_link||' ffe,'
		   ||'       fm_form_mst'||at_apps_link||' ffm,'
		   ||'       fm_rout_hdr'||at_apps_link||' frh,'
		   ||'       sy_orgn_mst'||at_apps_link||' som,'
		   ||'       gmp_item_aps'||at_apps_link||' gia,'
		   ||'       gmd_status_b'||at_apps_link||' gs1,'
		   ||'       gmd_status_b'||at_apps_link||' gs2,'
		   ||'       gmd_status_b'||at_apps_link||' gs3,'
		   ||'       gmd_status_b'||at_apps_link||' gs4 '
                   ||' WHERE grb.delete_mark = 0 '
                   ||'   AND grb.recipe_id = ffe.recipe_id '
                   ||'   AND grb.recipe_status = gs1.status_code '
                   ||'   AND gs1.status_type IN (' ||'''700'''|| ',' ||''' 900'''|| ') '
                   ||'   AND gs1.delete_mark = 0 '
                   ||'   AND ffe.delete_mark = 0 '
                   ||'   AND ffe.validity_rule_status = gs2.status_code '
                   ||'   AND gs2.status_type IN (' ||'''700'''|| ',' ||''' 900'''|| ') '
                   ||'   AND gs2.delete_mark = 0 '
                   ||'   AND frh.delete_mark = 0 '
                   ||'   AND ffm.delete_mark = 0 '
                   ||'   AND som.delete_mark = 0 '
                   ||'   AND frh.inactive_ind = 0 '
                   ||'   AND ffm.inactive_ind = 0 '
                   ||'   AND grb.routing_id IS NOT NULL '
                   ||'   AND ffe.orgn_code IS NULL '
                   ||'   AND ffe.recipe_use IN (0,1) '
                   ||'   AND nvl(ffe.end_date,(SYSDATE + 1)) > SYSDATE '
                   ||'   AND grb.formula_id = ffm.formula_id '
                   ||'   AND ffm.formula_status = gs3.status_code '
                   ||'   AND gs3.status_type IN (' ||'''700'''|| ',' ||''' 900'''|| ') '
                   ||'   AND gs3.delete_mark = 0 '
                   ||'   AND grb.routing_id =  frh.routing_id '
                   ||'   AND frh.routing_status =  gs4.status_code '
                   ||'   AND gs4.status_type IN (700,900) '
                   ||'   AND gs4.delete_mark = 0 '
                   ||'   AND gia.plant_code =  som.orgn_code '
                   ||'   AND gia.item_id =  ffe.item_id '
                   ||'   AND gia.whse_code = som.resource_whse_code '
                   ||'   AND gia.replen_ind = 1 '
                   ||'   AND EXISTS ( SELECT 1 '
                   ||'          FROM  fm_matl_dtl'||at_apps_link||' '
                   ||'          WHERE formula_id = grb.formula_id '
                   ||'            AND line_type = 1 '
                   ||'            AND item_id = ffe.item_id ) '
                   ||' UNION ALL '
                   ||' SELECT ffe.recipe_validity_rule_id, ffe.item_id, '
                   ||' grb.formula_id, gia.plant_code lorgn_code, gia.organization_id, '
                   ||' ffe.start_date, ffe.end_date, ffe.inv_min_qty, '
                   ||' ffe.inv_max_qty, ffe.preference, gia.uom_code, '
                   ||' gia.whse_code wcode , to_number(null) , '
                   ||' NULL, to_number(null), NULL, '
                   ||' NULL, to_number(null), to_number(null) prd_fct, -1 prd_ind, ' /*B2870041*/
                   ||' gia.aps_item_id, grb.recipe_id, 0 rhdr_loc, '
/* NAMIT_CR,SGIDUGU */
                   ||' 0 calculate_step_quantity, '
                   ||' gia.category_id,NULL, '
                   ||' gia.seq_dpnd_class '
		   ||' FROM  gmd_recipes_b'||at_apps_link||' grb,'
		   ||'       gmd_recipe_validity_rules'||at_apps_link||' ffe,'
                   ||'       sy_orgn_mst'||at_apps_link||' som, '
                   ||'       fm_form_mst'||at_apps_link||' ffm, '
                   ||'       gmp_item_aps'||at_apps_link||' gia,'
		   ||'       gmd_status_b'||at_apps_link||' gs1,'
		   ||'       gmd_status_b'||at_apps_link||' gs2,'
		   ||'       gmd_status_b'||at_apps_link||' gs3 '
                   ||' WHERE grb.delete_mark = 0 '
                   ||'   AND grb.recipe_id = ffe.recipe_id '
                   ||'   AND grb.recipe_status = gs1.status_code '
                   ||'   AND gs1.status_type IN (' ||'''700'''|| ',' ||''' 900'''|| ') '
                   ||'   AND gs1.delete_mark = 0 '
                   ||'   AND ffe.delete_mark = 0 '
                   ||'   AND ffe.validity_rule_status = gs2.status_code '
                   ||'   AND gs2.status_type IN (' ||'''700'''|| ',' ||''' 900'''|| ') '
                   ||'   AND gs2.delete_mark = 0 '
                   ||'   AND ffm.delete_mark = 0 '
                   ||'   AND som.delete_mark = 0 '
                   ||'   AND ffm.inactive_ind = 0 '
                   ||'   AND grb.routing_id IS NULL '
                   ||'   AND ffe.orgn_code IS NULL '
                   ||'   AND ffe.recipe_use IN (0,1) '
                   ||'   AND nvl(ffe.end_date,(SYSDATE + 1)) > SYSDATE '
                   ||'   AND grb.formula_id = ffm.formula_id '
                   ||'   AND ffm.formula_status = gs3.status_code '
                   ||'   AND gs3.status_type IN (' ||'''700'''|| ',' ||''' 900'''|| ') '
                   ||'   AND gs3.delete_mark = 0 '
		   ||'   AND gia.plant_code = som.orgn_code '  ;
         IF l_in_str_org  IS NOT NULL THEN
         effectivity_cursor := effectivity_cursor
                   ||'   AND gia.organization_id ' || l_in_str_org
                   ||'   AND gia.whse_code = som.resource_whse_code ' ;
        END IF;
         /* B3837959 MMK Issue, Database link added for form_eff */
         effectivity_cursor := effectivity_cursor
		   ||'   AND gia.item_id = ffe.item_id '
                   ||'   AND gia.replen_ind = 1 '
                   ||'   AND EXISTS ( SELECT 1 '
                   ||'          FROM  fm_matl_dtl'||at_apps_link||' '
                   ||'          WHERE formula_id = grb.formula_id '
                   ||'            AND line_type = 1 '
                   ||'            AND item_id = ffe.item_id )  ) eff,'
                   ||'( SELECT plant_code, whse_code, fmeff_id, '
                   ||'             max(aps_fmeff_id) aps_fmeff_id '
                   ||'             FROM gmp_form_eff'||at_apps_link||' '
                   ||'      GROUP BY plant_code, whse_code, fmeff_id '
                   ||'    ) gfe '
                   ||'WHERE eff.lorgn_code = gfe.plant_code (+) '
                   ||' AND eff.wcode = gfe.whse_code (+) '
                   ||' AND eff.recipe_validity_rule_id = gfe.fmeff_id (+) '
		   ||' ORDER BY 4,5,6  ' ;

    formula_hdr_cursor :=
                     ' SELECT unique ffm.formula_id, 0, 0, 0, -1, NULL '
                   ||' FROM fm_form_mst'||at_apps_link||' ffm, '
                   ||'      gmd_recipes_b'||at_apps_link||' grb, '
                   ||'      gmd_recipe_validity_rules'||at_apps_link||' ffe, '
                   ||'      gmd_status_b'||at_apps_link||' gs '
                   ||' WHERE grb.recipe_id = ffe.recipe_id '
                   ||'   AND ffe.validity_rule_status = gs.status_code '
                   ||'   AND gs.status_type IN (' ||'''700'''|| ',' ||''' 900'''|| ') '
                   ||'   AND gs.delete_mark = 0 '
                   ||'   AND nvl(ffe.end_date,(SYSDATE + 1)) > SYSDATE '
                   ||'   AND ffm.formula_id = grb.formula_id '
                   ||'   AND ffe.delete_mark = 0 '
                   ||'   AND ffm.delete_mark = 0 '
                   ||' ORDER BY formula_id  ' ;

    -- gmp_putline('Started at '|| TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'),'a');
    OPEN cur_formula_hdr FOR formula_hdr_cursor;
    LOOP
      FETCH cur_formula_hdr INTO formula_header_tab(formula_headers_size);
      EXIT WHEN cur_formula_hdr%NOTFOUND;
      formula_headers_size := formula_headers_size + 1;
    END LOOP;
    CLOSE cur_formula_hdr;
    formula_headers_size := formula_headers_size -1 ;
    time_stamp;
    log_message('Formula Header size is = ' || to_char(formula_headers_size)) ;

     v_gmd_seq := 'SELECT MAX(formulaline_id) FROM fm_matl_dtl'||at_apps_link;

     OPEN v_gmd_cursor FOR v_gmd_seq;
     FETCH v_gmd_cursor INTO v_gmd_formula_lineid;
     CLOSE v_gmd_cursor;

/* Bug: 5872693 Vpedarla 12-Feb-2007 Start */
    prev_detail_tab(1) := NULL;
    orig_detail_tab(1) := NULL;
    formula_details_size := 0;
/* Bug: 5872693 Vpedarla 12-Feb-2007 end */

/* Bug: 5872693 Vpedarla 12-Mar-2007 Start */

   formula_dtl_cursor :=
         '  SELECT ffm.formula_id, '
       ||'  ffm.formula_no, '
       ||'  ffm.formula_vers, '
       ||'  ffm.formula_desc1, '
       ||'  ((fmd.formulaline_id * 2) + 1) x_formulaline_id, '
       ||'  fmd.line_type, '
       ||'  fmd.item_id, '
       ||'  decode(fmd.original_item_flag,1,fmd.qty,(( fmd.sub_replace_qty / fmd.sub_original_qty) * fmd.line_item_qty)) qty, '
       /*B5176291 - for substitute items fmd.qty will be null, in those case subsittute qty should be used*/
       ||'  fmd.scrap_factor, '
       ||'  fmd.scale_type, '
       ||'  fmd.contribute_yield_ind, '
       ||'  decode(fmd.line_type, -1, decode(nvl(fmd.contribute_step_qty_ind, '''||'N'||''''||'),'
       ||    ''''||'Y'||''''||',1,2), 1) contribute_step_qty_ind,'
       ||'  DECODE(fmd.phantom_type,0,null,6) phantom_type, '
       ||'  gia.uom_code, ' --akaruppa changed gia.uom_code to msi.primary_uom_code
       ||'  fmd.item_um ,  ' /*B2870041*/ --akaruppa changed fmd.item_um to fmd.detail_uom and gia.item_um to msi.primary_uom_code
       ||'  gia.uom_code, '
       ||'  DECODE(fmd.scale_type,0,0,1,2) scale_type, '
       ||'  DECODE(fmd.item_um,gia.uom_code,decode(fmd.original_item_flag,1,fmd.qty,((fmd.sub_replace_qty / fmd.sub_original_qty) * fmd.line_item_qty)), '
       ||'        GMICUOM.uom_conversion'||at_apps_link
       ||'                  ( fmd.item_id, '
       ||'                   0, '
       ||'                   decode(fmd.original_item_flag,1,fmd.qty,((fmd.sub_replace_qty / fmd.sub_original_qty) * fmd.line_item_qty)), '
       ||'                   fmd.item_um , '
       ||'                   gia.item_um , '
       ||'                   0)) primary_qty, '
       ||'  gia.aps_item_id, '
       ||'  fmd.scale_multiple, '
       ||'  (fmd.scale_rounding_variance * 100) scale_rounding_variance, '
/* B3703430 - sowsubra - rounding variance multiplied by 100 */
       ||'  decode(fmd.rounding_direction,1,2,2,1,fmd.rounding_direction) ,'
       ||'  fmd.release_type, '
       ||'  fmd.line_item_id, '
       ||'  fmd.start_date, '
       ||'  fmd.end_date, '
       ||'  fmd.formulaline_id formula_line_id , '
       ||'  fmd.preference preference, '
       ||'  to_date(NULL) lead_stdate ,'
       ||'  to_date(NULL) lead_enddate ,'
       ||'  to_number(NULL) lead_pref ,'
       ||'  null actual_end_date ,'
       ||'  0 actual_end_flag ,'
       ||'  fmd.original_item_flag original_item_flag  , '
       ||'  fmd.formulaline_id formula_line_id '
       ||'  FROM  gmd_material_effectivities_vw'||at_apps_link||' fmd,'
       ||'        fm_form_mst'||at_apps_link||' ffm, '
       ||'        (SELECT  a.item_id, a.aps_item_id, a.item_um, a.uom_code '
       ||'            FROM (SELECT item_id, aps_item_id, item_um, uom_code, '
       ||'           ROW_NUMBER() OVER ( PARTITION BY item_id ORDER BY item_id,aps_item_id ) AS first_row '
       ||'           FROM gmp_item_aps'||at_apps_link ||' ) a where a.first_row = 1 ) gia '
       ||'  WHERE gia.item_id = fmd.item_id '
       ||'  AND ffm.formula_id = fmd.formula_id '
       ||'  AND ffm.delete_mark = 0 '
       ||'  AND ( fmd.qty <> 0 OR (( fmd.sub_replace_qty / fmd.sub_original_qty) * fmd.line_item_qty) <> 0) '
       ||'  ORDER BY ffm.formula_id ,fmd.line_type, fmd.formulaline_id, '
       ||'  fmd.original_item_flag desc,fmd.start_date,fmd.preference ';

	OPEN cur_formula_dtl FOR formula_dtl_cursor;
	-- { L1
	LOOP
	FETCH cur_formula_dtl INTO temp_detail_tab(1);
	-- Bug 5955251 Vpedarla 29-Mar-2007  COLLECTION ISSUE CREATES DUMMY CO-PRODUCT CREATION IN ODS
	EXIT WHEN cur_formula_dtl%NOTFOUND;
	--end of bug 5955251
	   -- { 1
	   IF  (temp_detail_tab(1).original_item_flag = 1 ) THEN         /* If original item */
	     -- { 2
	     IF substcount <> 0 THEN              --processing the previous original item's substituion records
	        FOR i in 1..substcount
	        -- { L2
	        loop
	           -- { 3
	           IF (subst_tab(i).start_date <= NVL(subst_tab(i).end_date,subst_tab(i).start_date)) THEN
	              FOR j in 1..substcount
	              -- { L3
	              LOOP
	                  -- { 4
	                  IF ((I <> J) and
	                      (subst_tab(j).start_date <= NVL(subst_tab(j).end_date,subst_tab(j).start_date))) THEN
	                        -- { 5
	                        IF (subst_tab(i).preference < subst_tab(j).preference) THEN
	                             -- { 6
	                             IF ((subst_tab(j).start_date >= subst_tab(i).start_date) and
	                                  (subst_tab(i).end_date IS NULL)) THEN
		       		                subst_tab(j).end_date := (subst_tab(j).start_date - 1/1440) ;

	                             ELSIF ((subst_tab(j).start_date < subst_tab(i).start_date) and
	                                      (subst_tab(i).end_date IS NULL) AND
		                                ((subst_tab(j).end_date >= subst_tab(i).start_date) OR
		                                (subst_tab(j).end_date IS NULL))) THEN
	       		                     subst_tab(j).end_date := (subst_tab(i).start_date - 1/1440) ;

	                             ELSIF ((subst_tab(j).start_date < subst_tab(i).end_date) and
	                                    (subst_tab(j).end_date <= subst_tab(i).end_date) and
	                                    (subst_tab(i).start_date <= subst_tab(j).start_date)) THEN
	                                subst_tab(j).end_date := (subst_tab(j).start_date - 1/1440) ;

	                             ELSIF (subst_tab(j).start_date > subst_tab(i).start_date)  and
	                                  (subst_tab(j).start_date < subst_tab(i).end_date)  and
	                                   (subst_tab(j).end_date > subst_tab(i).end_date) THEN
		                         	  log_message('entered into condition--4');
	                                subst_tab(j).start_date := subst_tab(i).end_date + 1/1440 ;

	                             ELSIF (subst_tab(i).start_date > subst_tab(j).start_date)  and
	                                    (subst_tab(i).start_date < subst_tab(j).end_date)  and
	                                    (subst_tab(i).end_date > subst_tab(j).end_date)  THEN
	                        		 subst_tab(j).end_date := subst_tab(i).start_date - 1/1440 ;
                                --Swapna Bug#5975883 below eslif condition was added
	                             ELSIF(subst_tab(i).start_date <= subst_tab(j).start_date) and
                                      (subst_tab(i).end_date is NOT NULL) and (subst_tab(j).start_date < subst_tab(i).end_date) and
	                	                 (subst_tab(j).end_date is NULL) THEN
	                                 subst_tab(j).start_date := subst_tab(i).end_date + 1/1440;
	                             ELSIF(subst_tab(i).start_date > subst_tab(j).start_date)  and
	                	                 (subst_tab(j).end_date is NULL)
	                	                 and (subst_tab(i).end_date is NOT NULL) THEN
	                                 subst_tab(j).end_date := subst_tab(i).start_date - 1/1440;
	                                 substcount := substcount + 1;	--Swapna Bug#5975883
	                                 subst_tab(substcount) := subst_tab(j);
	                           		 subst_tab(substcount).start_date := subst_tab(i).end_date +1/1440 ;
	                                 subst_tab(substcount).end_date := NULL;

	                             ELSIF (subst_tab(i).start_date > subst_tab(j).start_date) and
		                               (subst_tab(i).end_date < subst_tab(j).end_date) THEN
	                                 substcount := substcount + 1;
	                                 subst_tab(substcount) := subst_tab(j);
	                                 subst_tab(substcount).start_date := subst_tab(i).end_date +1/1440 ;
	                                 subst_tab(substcount).end_date := subst_tab(j).end_date;
	                                 subst_tab(j).end_date := subst_tab(i).start_date - 1/1440 ;

	                            END IF;
	                            -- } 6
	                        END IF;
	                        -- } 5
	                   END IF;
	                   -- } 4
	                END LOOP;
	                -- } L3
	            END IF;
	            -- } 3
	        END LOOP;
	        -- } L2
	      /* insert processed substitutes now */
	        FOR k in 1..substcount
	        LOOP
	           formula_details_size := formula_details_size + 1 ;
	           formula_detail_tab(formula_details_size) := subst_tab(k) ;
	           formula_detail_tab(formula_details_size).x_formulaline_id := NULL;
	        END LOOP;
	        /*insert trailing records if there is no substitue which has a null end date*/
	        FOR k in 1..substcount
	        LOOP
	        If subst_tab(k).end_date is null then
	           enddatenull := TRUE;
	        ELSIF subst_tab(k).end_date > NVL(orig_detail_tab(1).start_date,sysdate) THEN
	           orig_detail_tab(1).start_date:= subst_tab(k).end_date + 1/1440 ;
	        END IF;
	     END LOOP;
	     IF NOT(enddatenull) THEN
	        formula_details_size := formula_details_size + 1 ;
	        formula_detail_tab(formula_details_size) := orig_detail_tab(1) ;
	        formula_detail_tab(formula_details_size).original_item_id := orig_detail_tab(1).opm_item_id;
	        formula_detail_tab(formula_details_size).x_formulaline_id := NULL;
	        formula_detail_tab(formula_details_size).end_date:=NULL;
	     END IF;
	  END IF; /* end of substitute record processing */
	  -- } 2 substcount <> 0
	     orig_detail_tab(1) := temp_detail_tab(1) ;
		 prev_detail_tab(1) := temp_detail_tab(1) ;
	        /* This is to insert original item */
	     IF  nvl(temp_detail_tab(1).end_date,(SYSDATE +1)) > sysdate THEN
	        formula_details_size := formula_details_size + 1 ;
		    formula_detail_tab(formula_details_size) := temp_detail_tab (1) ;
		    formula_detail_tab(formula_details_size).end_date := temp_detail_tab(1).end_date - 1/1440 ;
	      END IF ;
	        substcount := 0;
	        orig_start_date:=orig_detail_tab(1).end_date;
	   -- } IF of 1
	   ELSE /* ELSE of original item - not an original item */
	   -- { ELSE of 1
	       IF substcount > 0 THEN /* from the second record onwards */
	       /* comparing with prevoious record to check if there is any gap so that we insert
	          the original item record in the gap. */
	          IF ( temp_detail_tab(1).start_date > orig_start_date ) and NOT(nullenddatefound) THEN
	         /* store the previous record' end date */
	               substcount := substcount + 1 ;
	               subst_tab(substcount) := orig_detail_tab(1) ;
	               subst_tab(substcount).original_item_id := orig_detail_tab(1).opm_item_id;
	               subst_tab(substcount).x_formulaline_id := NULL;
	               subst_tab(substcount).start_date := orig_start_date;
	               subst_tab(substcount).end_date := temp_detail_tab (1).start_date - 1/1440;
	               subst_tab(substcount).preference:=99999;
	           END IF;
	       END IF;
	       substcount := substcount + 1 ;
	       subst_tab(substcount) := temp_detail_tab (1) ;
	       IF (temp_detail_tab (1).end_date IS NULL) AND NOT (nullenddatefound)  THEN
	          nullenddatefound := TRUE;
	       ELSIF (temp_detail_tab(1).end_date > orig_start_date ) AND NOT (nullenddatefound) THEN
	          orig_start_date := temp_detail_tab(1).end_date +1/1440;
	       END IF;

	   END IF;
	   -- }  1
	EXIT WHEN cur_formula_dtl%NOTFOUND;
	END LOOP;
	-- } L1
CLOSE cur_formula_dtl;

/* Bug: 5872693 Vpedarla 12-Mar-2007 END */

    time_stamp ;
    log_message('Formula detail size is = ' || to_char(formula_details_size)) ;

-- =========== rtg offset data selection start ========================
   rtg_offset_cur_stmt := ' SELECT '||
		' gro.plant_code, '||
		' gro.fmeff_id, '||
		' gro.formula_id, '||
		' gro.routingstep_id, '||
		' gro.start_offset, '||
		' gro.end_offset, '||
		' (rsm.formulaline_id *2 )+ 1'||
		' from '||
		' gmd_recipe_step_materials'||at_apps_link||' rsm, '||
		' gmp_routing_offsets'||at_apps_link||' gro '||
		' WHERE '||
		' gro.recipe_id = rsm.recipe_id '||
		' AND gro.routingstep_id = rsm.routingstep_id '||
		' ORDER BY gro.formula_id,gro.plant_code, rsm.formulaline_id ' ;

    OPEN cur_rtg_offsets  FOR rtg_offset_cur_stmt ;
    LOOP
      FETCH cur_rtg_offsets INTO rstep_offsets(rtg_offsets_size);

      EXIT WHEN cur_rtg_offsets%NOTFOUND;
      rtg_offsets_size := rtg_offsets_size + 1;
    END LOOP;
    CLOSE cur_rtg_offsets;

    rtg_offsets_size := rtg_offsets_size -1 ;
    time_stamp ;
    log_message('Routing Offsets size is = ' || to_char(rtg_offsets_size)) ;

-- =========== rtg offset data selection end ========================

    -- Validate formula for uom conversion, for planned items
    validate_formula ;

    routing_hdr_cursor :=
                     ' SELECT unique frh.routing_id, som.orgn_code, '
/* NAMIT_CR 2 more zeros added for Linking Step Dependency to Routing Header */
                   ||'        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 '
                   ||' FROM sy_orgn_mst'||at_apps_link||' som, '
                   ||'      fm_rout_hdr'||at_apps_link||' frh, '
                   ||'      gmd_recipes_b'||at_apps_link||' grb, '
                   ||'      gmd_recipe_validity_rules'||at_apps_link||' ffe, '
                   ||'      gmd_status_b'||at_apps_link||' gs '
                   ||' WHERE grb.recipe_id = ffe.recipe_id '
                   ||'   AND ffe.validity_rule_status = gs.status_code '
                   ||'   AND gs.status_type IN (' ||'''700'''|| ',' ||''' 900'''|| ') '
                   ||'   AND gs.delete_mark = 0 '
                   ||'   AND nvl(ffe.end_date,(SYSDATE + 1)) > SYSDATE '
                   ||'   AND frh.routing_id = grb.routing_id '
                   ||'   AND som.delete_mark = 0 '
                   ||'   AND som.resource_whse_code is NOT NULL '
                   ||'   AND nvl(ffe.orgn_code, som.orgn_code) = som.orgn_code' ;
            IF l_in_str_org  IS NOT NULL THEN
               routing_hdr_cursor := routing_hdr_cursor
                   ||'   AND EXISTS ( SELECT 1 FROM gmp_item_aps'||at_apps_link||' gia '
                   ||'   WHERE gia.whse_code = som.resource_whse_code )' ;
            END IF;

         routing_hdr_cursor := routing_hdr_cursor
                   ||'   AND ffe.delete_mark = 0 '
                   ||'   AND frh.delete_mark = 0 '
                   ||'   AND frh.inactive_ind = 0 '
                   ||' ORDER BY frh.routing_id, som.orgn_code ' ;

    OPEN cur_routing_hdr FOR routing_hdr_cursor;
    LOOP
      FETCH cur_routing_hdr INTO rtg_org_hdr_tab(routing_headers_size);
      EXIT WHEN cur_routing_hdr%NOTFOUND;
      routing_headers_size := routing_headers_size + 1;
    END LOOP;
    CLOSE cur_routing_hdr;
    routing_headers_size := routing_headers_size -1 ;
    time_stamp ;
    log_message('Routing Header size is = ' || to_char(routing_headers_size)) ;
    /* 2582849 minimum_transfer_qty selected */

    /*  Select Seq Dep rows SGIDUGU
       Construct PL/Sql table used in bsearch
      Select Setup id rows for oprn_id <> -1 SGIDUGU */
   setup_id_cursor :=
          ' SELECT oprn_id, '
              ||'  category_id,   '
              ||'  seq_dep_id   '
              ||'  FROM  gmp_sequence_types'||at_apps_link||' gst  '
              ||'  WHERE oprn_id <> -1  '
              ||'  ORDER BY oprn_id,category_id  ' ;
--
     setup_size := 1;
     OPEN setup_id_dtl FOR setup_id_cursor;
     LOOP
        FETCH setup_id_dtl INTO setupid_tab(setup_size);
        EXIT WHEN setup_id_dtl%NOTFOUND;
        setup_size := setup_size + 1;
     END LOOP;
     CLOSE setup_id_dtl;
     setup_size := setup_size - 1;
     time_stamp ;
     log_message('Setup id size is = ' || to_char(setup_size)) ;
--
    /*  End of Select Seq Dep rows SGIDUGU */
--
    routing_dtl_cursor :=
          ' SELECT frd.routing_id, '
              ||'  crd.orgn_code, '
              ||'  frd.routingstep_no,  '
              ||'  NVL(goa.sequence_dependent_ind,0), '
              /* This will ensure that ordering will always have primary first */
              ||'  DECODE(gor.prim_rsrc_ind, 1,1,2,2,0,3), '
              ||'  gor.resources, '
              ||'  gor.prim_rsrc_ind, '
              ||'  decode(crd.capacity_constraint,1,1,2), '
              ||'  crd.min_capacity, '
              ||'  crd.max_capacity, '
              ||'  crd.schedule_ind, '
              ||'  frd.routingstep_id, '
              ||'  ((frd.routingstep_id * 2) + 1) x_routingstep_id,  '
              ||'  frd.step_qty, '
              ||'  NVL(frd.minimum_transfer_qty,0) minimum_transfer_qty, '
              ||'  fom.oprn_desc,  '
              ||'  fom.oprn_id,  '     /* SGIDUGU Seq Dep */
              ||'  fom.oprn_no,  '
              ||'  sou2.uom_code,'
              ||'  goa.activity, '
              ||'  goa.oprn_line_id, '
              ||'  gor.resource_count, '
              ||'  gor.resource_usage, '
              ||'  gor.usage_um, '
              ||'  gor.scale_type,'
              ||'  goa.offset_interval, '
              ||'  crd.resource_id, '
              ||'  ((crd.resource_id * 2) + 1) x_resource_id, '
--              ||'  -- DECODE(gor.scale_type,0,2,1,1,2,1) , ' /* B2967464 */
              ||'  DECODE(gor.scale_type,0,2,1,1,2,3) , ' /* B2967464 */
              ||'  sou.uom_code, '
              ||'  goa.activity_factor, '
              ||'  gor.process_qty, '
--              ||'  NVL(goa.sequence_dependent_ind,0), '
              ||'  NVL(goa.material_ind,0), '
              ||'  1 , '
              || '  SUM(NVL(goa.material_ind,0))  OVER (PARTITION BY '
              || '  frd.routing_id, crd.orgn_code, frd.routingstep_no) mat_found, '
              || '  1, ' /* flag for including rows */
              || '  decode(goa.break_ind,NULL,2,0,2,1,1) brk_ind'
              || ' ,-1, -1, -1, -1, -1, -1, '
              ||' (SUM(DECODE(NVL(goa.sequence_dependent_ind,0),1,1,0)) OVER '
              ||' (PARTITION BY '
              ||' frd.routing_id, crd.orgn_code)) is_sds_rout,'
              ||' DECODE(NVL(goa.sequence_dependent_ind,0),1,DECODE(gor.prim_rsrc_ind,1,1,0),0) is_unique, '
              ||' DECODE(NVL(goa.sequence_dependent_ind,0),1,0,DECODE(gor.prim_rsrc_ind,1,1,0)) is_nonunique, '
              ||' NULL setup_id '
              ||' FROM  sy_uoms_mst'||at_apps_link||' sou, '
              ||'       sy_uoms_mst'||at_apps_link||' sou2, '
              ||'       cr_rsrc_dtl'||at_apps_link||' crd, '
              ||'       fm_rout_dtl'||at_apps_link||' frd, '
              ||'       gmd_operations'||at_apps_link||' fom, '
              ||'       gmd_operation_activities'||at_apps_link||' goa, '
              ||'       gmd_operation_resources'||at_apps_link||' gor '
              ||' WHERE frd.oprn_id = fom.oprn_id '
              ||'   AND fom.oprn_id = goa.oprn_id '
              ||'   AND goa.oprn_line_id = gor.oprn_line_id '
              ||'   AND crd.resources = gor.resources '
              ||'   AND sou.um_code = gor.usage_um '
              ||'   AND sou2.um_code = fom.process_qty_um '
              ||'   AND sou.delete_mark = 0 '
              ||'   AND fom.delete_mark = 0 '
              ||'   AND goa.activity_factor > 0 '
              ||'   AND sou.um_type = :gmp_uom_class '
              ||' ORDER BY  '
              ||'         1, 2, 3, 4, 5, 6 ';

    OPEN cur_routing_dtl FOR routing_dtl_cursor USING g_gmp_uom_class;
    LOOP
      FETCH cur_routing_dtl INTO rtg_org_dtl_tab(rtg_org_dtl_size);
      EXIT WHEN cur_routing_dtl%NOTFOUND;
      /*B2870041 The activities have to be properly marked for the schedule
         flag. This only needs to be done once for the route. The index is
         copied for ease of use. */

      ri := rtg_org_dtl_size;

      /* since the select includes orgn_code we need to track when the route
         org or step changes. If any of them change this means the step has
         changed. when there is a new step the process needs to reset. The
         new values are saved and the first row of the step is saved to be
         used to loop later. found will be used to indicate that an activity
         has the material ind set to 1 */

      IF old_route <> rtg_org_dtl_tab(ri).routing_id OR
         old_orgn <> rtg_org_dtl_tab(ri).orgn_code OR
         old_step <> rtg_org_dtl_tab(ri).routingstep_no THEN

        found := 0;
        /* NAMIT_OC */
        found_chrg_rsrc := 0;
        chrg_activity   := NULL;
        first_step_row := ri;

        old_route := rtg_org_dtl_tab(ri).routing_id;
        old_orgn := rtg_org_dtl_tab(ri).orgn_code;
        old_step := rtg_org_dtl_tab(ri).routingstep_no;

      END IF;
      /* if we found an activity with the material ind = 1 and one has not
         found yet we need to go back and set all the activities before this
         one in the step as PRIOR. the rows are looped though using the first
         step row index to the row before this current row. All rows with
         the material ind = 1 will have the schedule flag set to 1 as part
         of the query by default. If no activity has a material ind = 1
         all of the activities will be considered as schedule_flag=1
         by default in the query */

      IF rtg_org_dtl_tab(ri).material_ind = 1 AND found = 0 THEN
        found := 1;
        IF first_step_row < ri THEN
          end_index := ri -1;
          FOR j IN first_step_row..end_index
          LOOP
            rtg_org_dtl_tab(j).schedule_flag := 3;
          END LOOP;
        END IF;

      /* if the material ind is 0 but another activity was found with 1
         then this row will be considered as NEXT. */
      ELSIF rtg_org_dtl_tab(ri).material_ind = 0 AND found = 1 THEN
        rtg_org_dtl_tab(ri).schedule_flag := 4;
      END IF;

        /* NAMIT_OC */

        /* If an operation has been found to have more than one activity with chargeable resources the first
        activity will be used and all other activities will have the scale type changed to be linear. If any
        activity found with chargeable resource, other activities in the operation having resource with
        scale_type "By Charge", will be changed to scale_type "Proportional" */

      IF rtg_org_dtl_tab(ri).mat_found = 0 OR rtg_org_dtl_tab(ri).material_ind = 1
      THEN

        IF rtg_org_dtl_tab(ri).rtg_scale_type = 3
        AND rtg_org_dtl_tab(ri).capacity_constraint = 1
        AND found_chrg_rsrc = 0 THEN
          found_chrg_rsrc := 1;
          chrg_activity := rtg_org_dtl_tab(ri).activity;
        /* if the rtg_scale_type is 3 but another activity was found with 3
           then this row will be assigned scale_type = 1. */
        ELSIF rtg_org_dtl_tab(ri).rtg_scale_type = 3
        AND rtg_org_dtl_tab(ri).capacity_constraint = 1
        AND found_chrg_rsrc = 1
        AND chrg_activity <> rtg_org_dtl_tab(ri).activity THEN
          rtg_org_dtl_tab(ri).rtg_scale_type := 1;
          rtg_org_dtl_tab(ri).scale_type := 1;
        END IF;
      END IF;

      rtg_org_dtl_size := rtg_org_dtl_size + 1;

    END LOOP;
    CLOSE cur_routing_dtl;
    rtg_org_dtl_size := rtg_org_dtl_size -1 ;
    time_stamp ;
    log_message('Routing Org detail size is = ' || to_char(rtg_org_dtl_size)) ;

     /* New GMD Changes - B1830940 */
    validation_statement := 'SELECT '
              ||'  frd.routing_id, '
              ||'  frd.routingstep_no, '
/* NAMIT_RD */
              ||'  NVL(goa.sequence_dependent_ind,0), '
              ||'  DECODE(gor.prim_rsrc_ind, 1,1,2,2,0,3), ' /* This will ensure that ordering will
                                                                always have primary firsr*/
              ||'  gor.resources, '
              ||'  frd.routingstep_id, '
              ||'  fom.oprn_no, '
              ||'  goa.oprn_line_id, '
              ||'  goa.activity, '
              ||'  gor.prim_rsrc_ind, '
--              ||'  gor.resources, '
--              ||'  decode(gor.prim_rsrc_ind,1,1,2) prim_rsrc_ind, '
--              ||'  NVL(goa.sequence_dependent_ind,0), '
              ||'  goa.offset_interval, '
/* NAMIT_RD */
              ||'  sou.uom_code '
              ||' FROM  fm_rout_dtl'||at_apps_link||' frd, '
              ||'       gmd_operations'||at_apps_link||' fom, '
              ||'       gmd_operation_activities'||at_apps_link||' goa, '
              ||'       gmd_operation_resources'||at_apps_link||' gor, '
/* NAMIT_RD */
              ||'       sy_uoms_mst'||at_apps_link||' sou '
              ||' WHERE frd.oprn_id = fom.oprn_id '
              ||'   AND fom.oprn_id = goa.oprn_id '
/* NAMIT_RD */
--              ||'   AND gor.prim_rsrc_ind in (1,2) '
              ||'   AND fom.delete_mark = 0'
              ||'   AND goa.oprn_line_id = gor.oprn_line_id '
/* NAMIT_RD */
              ||'   AND sou.um_code = gor.usage_um '
              ||'   AND sou.delete_mark = 0 '
              ||'   AND sou.um_type = :gmp_uom_class '
/* NAMIT_RD */
              ||' ORDER BY 1, 2, 3, 4, 5 ' ;
/*              ||' ORDER BY frd.routing_id, '
              ||'          frd.routingstep_no, '
              ||'          fom.oprn_no, '
              ||'          NVL(goa.sequence_dependent_ind,0) DESC, '
              ||'          goa.offset_interval,'
              ||'          goa.activity,'
              ||'          goa.oprn_line_id,'
              ||'          decode(gor.prim_rsrc_ind,1,1,2), '
              ||'          gor.resources ' ;*/

    OPEN cur_routing_dtl FOR validation_statement USING g_gmp_uom_class;
    LOOP
      FETCH cur_routing_dtl INTO rtg_gen_dtl_tab(rtg_gen_dtl_size);
      EXIT WHEN cur_routing_dtl%NOTFOUND;
      rtg_gen_dtl_size := rtg_gen_dtl_size + 1;
    END LOOP;
    CLOSE cur_routing_dtl;
    rtg_gen_dtl_size := rtg_gen_dtl_size -1 ;
    time_stamp ;
    log_message('Generic Routing size is = ' || to_char(rtg_gen_dtl_size)) ;

    recipe_orgn_statement := ' SELECT '
               ||'  grb.routing_id, gc.orgn_code, '
               ||'  gc.routingstep_id, gc.oprn_line_id, gc.recipe_id, '
               ||'  gc.activity_factor, '
               ||'  gc.resources, gc.resource_usage, gc.process_qty, '
               ||'  gc.min_capacity, gc.max_capacity  '
               ||' FROM gmd_recipes'||at_apps_link||' grb, '
               ||'      gmd_status_b'||at_apps_link||' gs, ' /* B5114783*/
               ||' ( '
               ||' SELECT '
               ||'  gor.recipe_id, '
               ||'  gor.orgn_code, '
               ||'  gor.oprn_line_id, '
               ||'  gor.routingstep_id, '
               ||'  goa.activity_factor, '
               ||'  gor.resources, '
               ||'  gor.resource_usage , '
               ||'  gor.process_qty,  '
               ||'  gor.min_capacity, '
               ||'  gor.max_capacity  '
               ||' FROM  gmd_recipe_orgn_activities'||at_apps_link||' goa, '
               ||'       gmd_recipe_orgn_resources'||at_apps_link||' gor '
               ||' WHERE gor.recipe_id = goa.recipe_id '
               ||'   AND gor.orgn_code = goa.orgn_code '
               ||'   AND gor.oprn_line_id = goa.oprn_line_id '
               ||'   AND gor.routingstep_id = goa.routingstep_id '
               ||' UNION ALL '
               ||' SELECT goa.recipe_id, '
               ||'  goa.orgn_code, '
               ||'  goa.oprn_line_id, '
               ||'  goa.routingstep_id, '
               ||'  goa.activity_factor,  '
               ||'  NULL resources,  '
               ||'  -1 resource_usage, '
               ||'  -1 process_qty, '
               ||'  -1 min_capacity, '
               ||'  -1 max_capacity '

               ||' FROM  gmd_recipe_orgn_activities'||at_apps_link||' goa '
               ||' WHERE NOT EXISTS( SELECT 1 '
               ||'       FROM gmd_recipe_orgn_resources'||at_apps_link||' gor '
               ||'       WHERE gor.recipe_id = goa.recipe_id '
               ||'         AND gor.orgn_code = goa.orgn_code '
               ||'         AND gor.oprn_line_id = goa.oprn_line_id '
               ||'         AND gor.routingstep_id = goa.routingstep_id ) '
               ||' UNION ALL '
               ||' SELECT gor.recipe_id, '
               ||'  gor.orgn_code, '
               ||'  gor.oprn_line_id, '
               ||'  gor.routingstep_id, '
               ||'  -1 activity_factor, '
               ||'  gor.resources, '
               ||'  gor.resource_usage , '
               ||'  gor.process_qty,  '
               ||'  gor.min_capacity, '
               ||'  gor.max_capacity '
               ||' FROM  gmd_recipe_orgn_resources'||at_apps_link||' gor  '
               ||' WHERE NOT EXISTS( SELECT 1 '
               ||'       FROM gmd_recipe_orgn_activities'||at_apps_link||' goa'
               ||'       WHERE goa.recipe_id = gor.recipe_id '
               ||'         AND goa.orgn_code = gor.orgn_code '
               ||'         AND goa.oprn_line_id = gor.oprn_line_id '
               ||'         AND goa.routingstep_id = gor.routingstep_id ) '
               ||' ) gc '
               ||' WHERE grb.recipe_id = gc.recipe_id '
               ||'   AND grb.delete_mark = 0 '
            /* B5114783 start */
               ||'   AND grb.recipe_status =  gs.status_code '
               ||'   AND gs.status_type IN (' ||'''700'''|| ',' ||''' 900'''|| ') '
               ||'   AND gs.delete_mark = 0 '
            /* B5114783 End */
               ||' ORDER BY 1,2,3,4,5 ' ;

    OPEN c_recipe_orgn FOR recipe_orgn_statement;
    LOOP
      FETCH c_recipe_orgn INTO rcp_orgn_override(recipe_orgn_over_size);
      EXIT WHEN c_recipe_orgn%NOTFOUND;
      recipe_orgn_over_size := recipe_orgn_over_size + 1;
    END LOOP;
    CLOSE c_recipe_orgn;
    recipe_orgn_over_size := recipe_orgn_over_size -1 ;
    time_stamp ;
    log_message('recipe_orgn_over_size is= '|| to_char(recipe_orgn_over_size));

   recipe_statement :=
              ' SELECT grb.routing_id, grs.routingstep_id, grs.recipe_id, '
             ||'        grs.step_qty '
             ||' FROM gmd_recipes'||at_apps_link||' grb, '
             ||'      gmd_status_b'||at_apps_link||' gs, ' /* B5114783*/
             ||'      gmd_recipe_routing_steps'||at_apps_link||' grs '
             ||' WHERE grb.recipe_id = grs.recipe_id '
             ||'   AND grb.delete_mark = 0 '
          /* B5114783 start */
             ||'   AND grb.recipe_status =  gs.status_code '
             ||'   AND gs.status_type IN (' ||'''700'''|| ',' ||''' 900'''|| ') '
             ||'   AND gs.delete_mark = 0 '
          /* B5114783 End */
             ||' ORDER BY 1,2,3 ' ;

    OPEN c_recipe_override FOR recipe_statement ;
    LOOP
      FETCH c_recipe_override INTO recipe_override(recipe_override_size);
      EXIT WHEN c_recipe_override%NOTFOUND;
      recipe_override_size := recipe_override_size + 1;
    END LOOP;
    CLOSE c_recipe_override;
    recipe_override_size := recipe_override_size -1 ;
    time_stamp ;
    log_message('recipe Override size is = '||to_char(recipe_override_size)) ;

     /* Alternate Resource selection   */
     /* B5688153, Rajesh Patangya prod spec alt*/
        statement_alt_resource :=
                     ' SELECT pcrd.resource_id, acrd.resource_id, '
                   ||' acrd.min_capacity, acrd.max_capacity, '
                   ||' cam.runtime_factor, '
/*prod spec alt*/  ||' nvl(cam.preference,-1), nvl(prod.item_id,-1)   '
                   ||' FROM  cr_rsrc_dtl'||at_apps_link||' acrd, '
                   ||'       cr_rsrc_dtl'||at_apps_link||' pcrd, '
                   ||'       cr_ares_mst'||at_apps_link||' cam, '
		   ||'       gmp_altresource_products'||at_apps_link||' prod'
                   ||' WHERE cam.alternate_resource = acrd.resources '
                   ||'   AND cam.primary_resource = pcrd.resources '
                   ||'   AND acrd.orgn_code = pcrd.orgn_code '
                   ||'   AND cam.primary_resource = prod.primary_resource(+) '
                   ||'   AND cam.alternate_resource = prod.alternate_resource(+)  '
                   ||'   AND acrd.delete_mark = 0  '
                   ||' ORDER BY pcrd.resource_id, '
                   ||'   DECODE(cam.preference,NULL,cam.runtime_factor,cam.preference),'
                   ||'   prod.item_id ' ;

    alt_rsrc_size := 1;
    OPEN cur_alt_resource FOR statement_alt_resource ;
    LOOP
      FETCH cur_alt_resource INTO rtg_alt_rsrc_tab(alt_rsrc_size);
      EXIT WHEN cur_alt_resource%NOTFOUND;
      alt_rsrc_size := alt_rsrc_size + 1;
    END LOOP;
    CLOSE cur_alt_resource;
    alt_rsrc_size := alt_rsrc_size -1 ;
    time_stamp ;
    log_message('Alternate Routing size is = ' || to_char(alt_rsrc_size)) ;

/* NAMIT_CR Get Step Dependency data */

   opr_stpdep_cursor := '    SELECT frdp.routing_id, '
              ||'          ((frd2.routingstep_id * 2) + 1) x_dep_routingstep_id, '
              ||'          ((frd1.routingstep_id * 2) + 1) x_routingstep_id, '
              ||'          decode(frdp.dep_type,0,1,2) dependency_type, '
              ||'          frdp.standard_delay, '
              ||'          frdp.max_delay, '
              ||'          frdp.transfer_pct, '
              ||'          frdp.dep_routingstep_no, '
              ||'          frdp.routingstep_no, '
              ||'          decode(nvl(frdp.chargeable_ind, 0),0,2,1,1) '
              ||'      FROM '
              ||'          fm_rout_dtl'||at_apps_link||' frd1, '
              ||'          fm_rout_dtl'||at_apps_link||' frd2, '
              ||'          fm_rout_dep'||at_apps_link||' frdp '
              ||'      WHERE '
              ||'          frd1.routing_id = frdp.routing_id '
              ||'          AND frd1.routingstep_no = frdp.routingstep_no '
              ||'          AND frd2.routing_id = frdp.routing_id '
              ||'          AND frd2.routingstep_no = frdp.dep_routingstep_no '
              ||'      ORDER BY 1,3,2 ' ;

    OPEN cur_opr_stpdep FOR opr_stpdep_cursor ;
    LOOP
      FETCH cur_opr_stpdep INTO gmp_opr_stpdep_tbl(opr_stpdep_size);
      EXIT WHEN cur_opr_stpdep%NOTFOUND;
      opr_stpdep_size := opr_stpdep_size + 1;
    END LOOP;
    CLOSE cur_opr_stpdep;
    opr_stpdep_size := opr_stpdep_size -1 ;
    time_stamp ;
    log_message('Operation Step Dependency size is = ' || to_char(opr_stpdep_size)) ;

    /* ------------------------------------------------------- */
    /* PROCESSING STARTS AFTER SELECTION OF THE DATA IN MEMORY */
    /* ------------------------------------------------------- */

    -- Link the routing header and detail
    link_routing ;
/* Now spool the routing Header data for debugging */
/*
  log_message ('Routing is ');
  log_message ('RTG_ID Plnt Valid GStart GEnd OStart OEnd StStart StEND UsgSt
  UsgEnd StpDepSt StpDepEnd  ');
  For spl_cnt in 1..rtg_org_hdr_tab.COUNT
  LOOP
     log_message ( rtg_org_hdr_tab(spl_cnt).routing_id ||'*'||
     rtg_org_hdr_tab(spl_cnt).plant_code         ||'*'||
     rtg_org_hdr_tab(spl_cnt).valid_flag         ||'*'||
     rtg_org_hdr_tab(spl_cnt).generic_start_loc  ||'*'||
     rtg_org_hdr_tab(spl_cnt).generic_end_loc    ||'*'||
     rtg_org_hdr_tab(spl_cnt).orgn_start_loc     ||'*'||
     rtg_org_hdr_tab(spl_cnt).orgn_end_loc       ||'*'||
     rtg_org_hdr_tab(spl_cnt).step_start_loc     ||'*'||
     rtg_org_hdr_tab(spl_cnt).step_end_loc       ||'*'||
     rtg_org_hdr_tab(spl_cnt).usage_start_loc    ||'*'||
     rtg_org_hdr_tab(spl_cnt).usage_end_loc      ||'*'||
     rtg_org_hdr_tab(spl_cnt).stpdep_start_loc   ||'*'||
     rtg_org_hdr_tab(spl_cnt).stpdep_end_loc );
  END LOOP ;
  */

    -- Link the routing header and detail overrides
    link_override_routing ;

    /*  New GMD Changes B1830940 */
    /*  B2800311, APS SHOULD SEE INGREDIENTS RELEASED AS AUTO-BY-STEP */
    /* B3054460 OPM/APS TO CATER FOR CHANGE TO TIME PHASED PLANNING OF
       MANUAL CONSUMPTION TYPE
    */

    mat_assoc_cursor  :=
                ' SELECT  fmd.formula_id, frm.recipe_id, '
              ||'  DECODE(fmd.line_type, 1,1,2,2,-1,3), fmd.line_no, '
              ||'  ((frm.formulaline_id * 2) + 1) x_formulaline_id, '
              ||'  ((frm.routingstep_id * 2) + 1) x_routingstep_id, '
/* NAMIT_MTQ */
              ||'   fmd.item_id, frd.routingstep_no, '
              ||'   gia.aps_item_id, '
              || '   DECODE(fmd.item_um, gia.item_um, 1, '
              || '     GMICUOM.uom_conversion'||at_apps_link
              || '       (fmd.item_id, 0, 1, fmd.item_um, gia.item_um, 0)) uom_conv_factor, '
              /*Sowmya - As per Latest FDD changes - Changes as per Matt's review comments-
              Fetch the conversion factor for a unit item, needed for converting the MTQ.
              MTQ value to be passed as promary UOM.*/
              ||'   decode(fmd.line_type, 1, frm.minimum_transfer_qty, null) minimum_transfer_qty, '
              ||'   decode(fmd.line_type, 1, frm.minimum_delay, null) minimum_delay, '
              ||'   decode(fmd.line_type, 1, frm.maximum_delay, null) maximum_delay '
             ||' FROM gmd_recipes'||at_apps_link||' r ,' /* added for asqc flg*/
	      ||' gmd_recipe_step_materials'||at_apps_link||' frm, '
              ||'       fm_matl_dtl'||at_apps_link||' fmd, '
/* NAMIT_MTQ */
              ||'       fm_rout_dtl'||at_apps_link||' frd,  '
              ||'      ( SELECT item_id, aps_item_id, item_um, uom_code '
              ||'        FROM (SELECT item_id, aps_item_id, item_um, uom_code,'
              ||'  		ROW_NUMBER() OVER ( PARTITION BY item_id '
              ||'      		ORDER BY item_id,aps_item_id ) AS first_row '
              ||'              	FROM gmp_item_aps '||at_apps_link
              ||'       	) '
              ||'        WHERE first_row = 1 '
              ||'       ) gia ' /*Sowmya - Added*/
              ||' WHERE fmd.formulaline_id = frm.formulaline_id '
              ||'   AND frm.recipe_id = r.recipe_id '  /* B3054460 */
              ||'   AND (fmd.release_type in (1,2,3) OR '  /* B3054460 */
              ||' NVL(r.calculate_step_quantity,0) = 1 ) '  /* xfer for ASQC */
/* NAMIT_MTQ */
              ||'   AND frd.routingstep_id = frm.routingstep_id '
              ||'   AND gia.item_id = fmd.item_id '
/* B3970993 nsinghi. Changed order by clause from 1,2,3,4,5 to 1,2,3,6,7 */
              ||' ORDER BY 1,2,3,6,7 ';

    OPEN cur_mat_assoc FOR mat_assoc_cursor ;
    LOOP
      FETCH cur_mat_assoc INTO mat_assoc_tab(material_assocs_size);
      EXIT WHEN cur_mat_assoc%NOTFOUND;
      material_assocs_size := material_assocs_size + 1;
    END LOOP;
    CLOSE cur_mat_assoc;
    material_assocs_size := material_assocs_size -1 ;
    time_stamp ;
    log_message('Material assoc size is = ' || to_char(material_assocs_size)) ;

 -- The cursor for effectivity opened and then the details processed
 OPEN c_formula_effectivity FOR effectivity_cursor;

  LOOP
  FETCH c_formula_effectivity INTO effectivity;
  EXIT WHEN c_formula_effectivity%NOTFOUND;
   IF ((effectivity.formula_id <> old_formula_id) OR
       (effectivity.plant_code <> old_plant_code) OR
       (effectivity.organization_id <> old_organization_id) OR
       (effectivity.fmeff_id <> old_fmeff_id)
      )  THEN   /* Old values */

    valid := check_formula(effectivity.plant_code,
                  effectivity.organization_id, effectivity.formula_id);
    /* routing check for effectivity */
    IF (valid) AND effectivity.routing_id IS NOT NULL THEN
        /* Locate_org_routing through Bsearch */
         valid := find_routing_header (effectivity.routing_id,
                                       effectivity.plant_code);

       IF (valid) AND effectivity.rtg_hdr_location > 0 AND
                      effectivity.routing_qty >= 0 THEN

           g_setup_id  := NULL;
           sd_index    := 0 ;
           validate_routing( effectivity.routing_id,
                             effectivity.plant_code,
                             effectivity.rtg_hdr_location,
                             routing_valid);

            IF (routing_valid) THEN /* Valid routing  */
                  valid := TRUE ;
             ELSE
                    valid := FALSE ;
             END IF;  /* Valid routing  */

       END IF ;   /* routing header location */

       /*B2870041 this logic will get the total output qty in the routing uom
          if the formula or route fails validation the effectivity is skipped*/
       IF (valid) THEN

         /* if the total output was already calculated for this formula in
            the routing um there is no need to do it again */
         IF formula_header_tab(g_fm_hdr_loc).total_um <>
              effectivity.routing_um  OR
            formula_header_tab(g_fm_hdr_loc).total_um IS NULL THEN

           /* if the factor was not calculated then the uom conversion failed
              and if it failed the effectivity can not be used */
           IF effectivity.prod_factor <= 0 THEN
             valid := FALSE;
           ELSE
             /* reset the total ouput accumulator and loop through all of the
                material details to find all products and byproducts */
             temp_total_qty := 0;

             FOR j IN g_fm_dtl_start_loc..g_fm_dtl_end_loc
             LOOP

               /* if the line is either a product or byproduct then we need
                  to process it */
               IF formula_detail_tab(j).line_type > 0 THEN

                 /* if the item is the same as the item in the effectivity
                    we have the factor to get the item from base uom to the
                    route uom */
                 IF (formula_detail_tab(j).opm_item_id = effectivity.item_id)
                 THEN
                   temp_total_qty := temp_total_qty +
                     (effectivity.prod_factor *
                      formula_detail_tab(j).primary_qty);
                 /* if the item is different but the item base uom is the
                    same as the route the primary_qty will be used */
                 ELSIF
                   formula_detail_tab(j).opm_item_id <> effectivity.item_id AND
                   formula_detail_tab(j).primary_um = effectivity.routing_um
                 THEN
                   temp_total_qty := temp_total_qty +
                      formula_detail_tab(j).primary_qty;
                 /* if the item is different but the item base uom is the
                    same as the route the primary_qty will be used */
                 ELSIF
                   formula_detail_tab(j).opm_item_id <> effectivity.item_id AND
                   formula_detail_tab(j).orig_um = effectivity.routing_um
                 THEN
                   temp_total_qty := temp_total_qty +
                      formula_detail_tab(j).formula_qty;
                 /* no uom can be matched or the item is not the same as the
                    product thus a uom conversion will need to be done. If the
                    qty is 0 there is no need to do the conversion */
                 ELSIF formula_detail_tab(j).formula_qty > 0 THEN
                   uom_conv_cursor :=
                       'SELECT '
                     ||'  GMICUOM.uom_conversion'||at_apps_link
                     ||'  (:pitem, 0, :pqty, :pfrom_um, :pto_um, 0) '
                     ||'FROM dual';
                   v_matl_qty := -1;
                   OPEN c_uom_conv FOR uom_conv_cursor USING
                     formula_detail_tab(j).opm_item_id,
                     formula_detail_tab(j).primary_qty,
                     formula_detail_tab(j).primary_um,
                     effectivity.routing_um;

                   FETCH c_uom_conv INTO v_matl_qty;
                   CLOSE c_uom_conv;

                   /* as long as the qty is >0 then the uom conversion was
                      successful. If negative then it failed so reject the
                      effectivity and stop the current loop */
                   IF v_matl_qty > 0 THEN
                     temp_total_qty := temp_total_qty + v_matl_qty;
                   ELSE
                     valid := FALSE;
                     EXIT;
                   END IF;
                 END IF;
               END IF;
             END LOOP;
             /* if there was no failure and the qty is >0 save the values in
                the formula header */
             IF (valid) AND temp_total_qty > 0 THEN
               formula_header_tab(g_fm_hdr_loc).total_output :=
                 temp_total_qty;
               formula_header_tab(g_fm_hdr_loc).total_um :=
                 effectivity.routing_um;
             END IF;
           END IF;
         END IF;
       END IF;


    END IF;   /* routing check for effectivity */

    IF valid THEN

      g_curr_rstep_loc := find_routing_offsets(effectivity.formula_id,
                               effectivity.plant_code);

      export_effectivities (valid);

    END IF ;

   END IF ;   /* Old Values */

    old_formula_id      := effectivity.formula_id ;
    old_organization_id := effectivity.organization_id ;
    old_fmeff_id        := effectivity.fmeff_id ;
    old_plant_code      := effectivity.plant_code ;
    valid               := FALSE ;
    routing_valid       := FALSE ;

  END LOOP;
  CLOSE c_formula_effectivity;

  log_message('Before MSC Inserts' ) ;
  time_stamp ;
  /* If all is OK, Bulk Insert the data into MSC tables */
   msc_inserts(valid);
       IF valid THEN
          COMMIT;
	ELSE
	NULL ;
       END IF;
   write_setups_and_transitions(valid) ;  /* SGIDUGU - Seq Dependencies */

       IF valid THEN
          COMMIT;
	ELSE
	NULL ;
       END IF;

  log_message('End of process' ) ;
  time_stamp ;
  -- gmp_putline('End at '|| TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'),'a');
/* akaruppa B5007729 Start*/
         /* Free memory used by PL/SQL tables used by program  */
           IF formula_header_tab.COUNT > 0 THEN
           formula_header_tab.delete ;
           END IF;
           IF formula_header_tab.COUNT > 0 THEN
           formula_header_tab.delete ;
           END IF;
           IF formula_detail_tab.COUNT > 0 THEN
           formula_detail_tab.delete ;
           END IF;
           IF formula_orgn_count_tab.COUNT > 0 THEN
           formula_orgn_count_tab.delete ;
           END IF;
           IF rtg_org_hdr_tab.COUNT > 0 THEN
           rtg_org_hdr_tab.delete ;
           END IF;
           IF rtg_org_dtl_tab.COUNT > 0 THEN
           rtg_org_dtl_tab.delete ;
           END IF;
           IF rtg_gen_dtl_tab.COUNT > 0 THEN
           rtg_gen_dtl_tab.delete ;
           END IF;
           IF rtg_alt_rsrc_tab.COUNT > 0 THEN
           rtg_alt_rsrc_tab.delete ;
           END IF;
           IF mat_assoc_tab.COUNT > 0 THEN
           mat_assoc_tab.delete;
           END IF;
           IF rcp_orgn_override.COUNT > 0 THEN
           rcp_orgn_override.delete ;
           END IF;
           IF recipe_override.COUNT > 0 THEN
           recipe_override.delete ;
           END IF;
           IF rstep_offsets.COUNT > 0 THEN
           rstep_offsets.delete ;
           END IF;

          dbms_session.free_unused_user_memory;

          SELECT st.VALUE INTO v_dummy from V$MYSTAT st, V$STATNAME sn
          WHERE st.STATISTIC# = sn.STATISTIC#
          AND sn.NAME in ('session pga memory max');
          log_message('Session pga memory max = ' || to_char(v_dummy) );

          SELECT st.VALUE INTO v_dummy from V$MYSTAT st, V$STATNAME sn
          where st.STATISTIC# = sn.STATISTIC#
          and sn.NAME in ('session pga memory');
          log_message('Session pga memory = ' || TO_CHAR(v_dummy) );

	  /* akaruppa B5007729 End*/

  return_status := TRUE;

  EXCEPTION
    WHEN invalid_string_value  THEN
        log_message('Organization string is Invalid ' );
        return_status := FALSE;
    WHEN invalid_gmp_uom_profile THEN
        log_message('Profile "GMP: UOM for Hour" is Invalid ' );
        return_status := FALSE;
    WHEN OTHERS THEN
	log_message('Error retrieving effectivities: '||sqlerrm);
	return_status := FALSE;

END retrieve_effectivities;

/*
REM+=========================================================================+
REM| PROCEDURE NAME                                                          |
REM|    link_override_routing                                                |
REM| DESCRIPTION                                                             |
REM|    Link the override based on routing and organization code             |
REM|                                                                         |
REM| HISTORY                                                                 |
REM| 08/23/2002   Created Rajesh Patangya                                    |
REM|                                                                         |
REM+=========================================================================+
*/
PROCEDURE link_override_routing IS
  i              NUMBER ;
  j              NUMBER ;
  k              NUMBER ;
  lgr_loc        NUMBER ;
  lgr_start_loc  NUMBER ;
  lgr_end_loc    NUMBER ;
  lorg_loc       NUMBER ;
  old_routing_id NUMBER ;
  gen_start_pos  NUMBER ;
  org_start_pos  NUMBER ;
  start_gen_pos_written NUMBER  ;
  start_org_pos_written NUMBER  ;

BEGIN
  i              := 1 ;
  j              := 1 ;
  k              := 1 ;
  lgr_loc        := 0 ;
  lgr_start_loc  := 0 ;
  lgr_end_loc    := 0 ;
  lorg_loc       := 0 ;
  old_routing_id := 0 ;
  gen_start_pos  := 1  ;
  org_start_pos  := 1  ;
  start_gen_pos_written := 0 ;
  start_org_pos_written := 0 ;


  -- gmp_putline(' Begin Link Override Rtg ','a');
  FOR i IN 1..routing_headers_size
  LOOP
   IF rtg_org_hdr_tab(i).routing_id = old_routing_id THEN /* old rtg */

        rtg_org_hdr_tab(i).step_start_loc := lgr_start_loc ;
        rtg_org_hdr_tab(i).step_end_loc   := lgr_end_loc ;
   ELSE
        start_gen_pos_written := 0 ;
        FOR j IN gen_start_pos..recipe_override_size
        LOOP
        IF recipe_override(j).routing_id = rtg_org_hdr_tab(i).routing_id THEN
            IF start_gen_pos_written = 0 THEN
                lgr_start_loc := j ;  /* Used for other org in org header */
                rtg_org_hdr_tab(i).step_start_loc := j ;
                start_gen_pos_written := 1 ;
            END IF ;
            IF j = recipe_override_size THEN
                rtg_org_hdr_tab(i).step_end_loc := j ;
                lgr_end_loc     := j ;
            END IF ;

        ELSIF recipe_override(j).routing_id > rtg_org_hdr_tab(i).routing_id
        THEN

            IF start_gen_pos_written <> 1 THEN
                rtg_org_hdr_tab(i).step_start_loc := -1 ;
                rtg_org_hdr_tab(i).step_end_loc   := -1 ;
                lgr_start_loc   := - 1;
                lgr_end_loc     := - 1;
            ELSE
                lgr_end_loc   := j - 1;
                rtg_org_hdr_tab(i).step_end_loc := lgr_end_loc ;
            END IF ;
            gen_start_pos := j ;
            EXIT ;

        /* ELSE - no need to write, continue looping. */
        END IF ;
     END LOOP ;   /* Generic loop */
   END IF ;   /* old rtg */

     --  For organization recipe
     start_org_pos_written := 0 ;
     FOR k IN org_start_pos..recipe_orgn_over_size
     LOOP
      IF rcp_orgn_override(k).routing_id = rtg_org_hdr_tab(i).routing_id AND
         rcp_orgn_override(k).orgn_code  = rtg_org_hdr_tab(i).plant_code THEN

          IF start_org_pos_written = 0 THEN
              rtg_org_hdr_tab(i).usage_start_loc := k ;
              start_org_pos_written := 1 ;
          END IF ;
          IF k = recipe_orgn_over_size THEN
              rtg_org_hdr_tab(i).usage_end_loc := k ;
          END IF ;

      ELSIF (rcp_orgn_override(k).routing_id>rtg_org_hdr_tab(i).routing_id) OR
          (
          (rcp_orgn_override(k).routing_id = rtg_org_hdr_tab(i).routing_id) AND
          (rcp_orgn_override(k).orgn_code  > rtg_org_hdr_tab(i).plant_code)
          )  THEN

            IF start_org_pos_written <> 1 THEN
              rtg_org_hdr_tab(i).usage_start_loc := -1 ;
              rtg_org_hdr_tab(i).usage_end_loc :=  -1 ;
            ELSE
              rtg_org_hdr_tab(i).usage_end_loc := k - 1 ;
            END IF ;
            org_start_pos := k ;
            EXIT ;

      /* ELSE - no need to write, continue looping. */
      END IF ;
     END LOOP ;   /* recipe organization loop */

     old_routing_id := rtg_org_hdr_tab(i).routing_id ;
  END LOOP ;  /* routing header loop */

  -- gmp_putline(' End Link Override Rtg ','a');
END link_override_routing;

/*
REM+=========================================================================+
REM| FUNCTION NAME                                                           |
REM|    find_routing_header                                                  |
REM| DESCRIPTION                                                             |
REM|                                                                         |
REM| HISTORY                                                                 |
REM| 07/14/2002   Rajesh Patangya - Reorgnized the complete code B2314052    |
REM+=========================================================================+
*/
FUNCTION find_routing_header ( prouting_id   IN NUMBER,
                               pplant_code   IN VARCHAR2)
                               RETURN BOOLEAN IS

routing_header_loc   NUMBER     ;
BEGIN
routing_header_loc   := 0 ;
      routing_header_loc := bsearch_routing (prouting_id,
                                             pplant_code);

       IF routing_header_loc > 0 THEN  /* routing header location */

          IF (rtg_org_hdr_tab(routing_header_loc).valid_flag < 0) OR
             (rtg_org_hdr_tab(routing_header_loc).generic_start_loc < 0) OR
             (rtg_org_hdr_tab(routing_header_loc).orgn_start_loc < 0)  THEN

                effectivity.rtg_hdr_location :=  -1 ;
                return FALSE ;
           ELSE
                effectivity.rtg_hdr_location := routing_header_loc ;
                return TRUE ;
          END IF ;
       ELSE
                log_message('Bsearch returned negative for Routing Plant ');
                effectivity.rtg_hdr_location :=  -1 ;
                return FALSE ;
       END IF ; /* routing header location */

END find_routing_header;

/*
REM+=========================================================================+
REM| PROCEDURE NAME                                                          |
REM|    link_routing                                                         |
REM| DESCRIPTION                                                             |
REM|                                                                         |
REM| HISTORY                                                                 |
REM| 07/14/2002   Rajesh Patangya - Reorgnized the complete code B2314052    |
REM+=========================================================================+
*/
PROCEDURE link_routing IS
  i              NUMBER ;
  j              NUMBER ;
  k              NUMBER ;
  lgr_loc        NUMBER ;
  lgr_start_loc  NUMBER ;
  lgr_end_loc    NUMBER ;
  lorg_loc       NUMBER ;
  old_routing_id NUMBER ;
  gen_start_pos  NUMBER ;
  org_start_pos  NUMBER ;
  start_gen_pos_written NUMBER  ;
  start_org_pos_written NUMBER  ;
/* NAMIT_CR To link step dependency to routing header */
  lstpdep_start_loc  NUMBER ;
  lstpdep_end_loc    NUMBER ;
  stpdep_start_pos  NUMBER ;
  start_stpdep_pos_written NUMBER  ;

BEGIN
  i              := 1 ;
  j              := 1 ;
  k              := 1 ;
  lgr_loc        := 0 ;
  lgr_start_loc  := 0 ;
  lgr_end_loc    := 0 ;
  lorg_loc       := 0 ;
  old_routing_id := 0 ;
  gen_start_pos  := 1  ;
  org_start_pos  := 1  ;
  start_gen_pos_written := 0 ;
  start_org_pos_written := 0 ;
  lstpdep_start_loc  := 0 ;
  lstpdep_end_loc    := 0 ;
  stpdep_start_pos  := 1  ;
  start_stpdep_pos_written := 0 ;


  -- gmp_putline(' Start Link Rtg ','a');
  FOR i IN 1..routing_headers_size
  LOOP
   IF rtg_org_hdr_tab(i).routing_id = old_routing_id THEN /* old rtg */

        rtg_org_hdr_tab(i).generic_start_loc := lgr_start_loc ;
        rtg_org_hdr_tab(i).generic_end_loc   := lgr_end_loc ;
/* NAMIT_CR Link the Step Dependency to the routing header */
        rtg_org_hdr_tab(i).stpdep_start_loc := lstpdep_start_loc ;
        rtg_org_hdr_tab(i).stpdep_end_loc   := lstpdep_end_loc ;

   ELSE
        start_gen_pos_written := 0 ;
        FOR j IN gen_start_pos..rtg_gen_dtl_size
        LOOP
        IF rtg_gen_dtl_tab(j).routing_id = rtg_org_hdr_tab(i).routing_id THEN
            IF start_gen_pos_written = 0 THEN
                lgr_start_loc := j ;  /* Used for other org in org header */
                rtg_org_hdr_tab(i).generic_start_loc := j ;
                start_gen_pos_written := 1 ;
            END IF ;
            IF j = rtg_gen_dtl_size THEN
                rtg_org_hdr_tab(i).generic_end_loc := j ;
                lgr_end_loc     := j ;
            END IF ;

        ELSIF rtg_gen_dtl_tab(j).routing_id > rtg_org_hdr_tab(i).routing_id
        THEN

            IF start_gen_pos_written <> 1 THEN
                rtg_org_hdr_tab(i).generic_start_loc := -1 ;
                rtg_org_hdr_tab(i).generic_end_loc   := -1 ;
                lgr_start_loc   := - 1;
                lgr_end_loc     := - 1;
            ELSE
                lgr_end_loc   := j - 1;
                rtg_org_hdr_tab(i).generic_end_loc := lgr_end_loc ;
            END IF ;
            gen_start_pos := j ;
            EXIT ;

        /* ELSE - no need to write, continue looping. */
        END IF ;
     END LOOP ;   /* Generic loop */
/* NAMIT_CR Code To Link Step Dependency to Routing Header Start */

     start_stpdep_pos_written := 0 ;
     FOR j IN stpdep_start_pos..opr_stpdep_size
     LOOP
        IF gmp_opr_stpdep_tbl(j).routing_id = rtg_org_hdr_tab(i).routing_id THEN
            IF start_stpdep_pos_written = 0 THEN
                lstpdep_start_loc := j ;  /* Used for other routes in route header */
                rtg_org_hdr_tab(i).stpdep_start_loc := j ;
                start_stpdep_pos_written := 1 ;
            END IF ;
            IF j = opr_stpdep_size THEN
                rtg_org_hdr_tab(i).stpdep_end_loc := j ;
                lstpdep_end_loc     := j ;
            END IF ;

        ELSIF gmp_opr_stpdep_tbl(j).routing_id > rtg_org_hdr_tab(i).routing_id
        THEN

            IF start_stpdep_pos_written <> 1 THEN
                rtg_org_hdr_tab(i).stpdep_start_loc := -1 ;
                rtg_org_hdr_tab(i).stpdep_end_loc   := -1 ;
                lstpdep_start_loc   := - 1;
                lstpdep_end_loc     := - 1;
            ELSE
                lstpdep_end_loc   := j - 1;
                rtg_org_hdr_tab(i).stpdep_end_loc := lstpdep_end_loc ;
            END IF ;
            stpdep_start_pos := j ;
            EXIT ;

        /* ELSE - no need to write, continue looping. */
        END IF ;
     END LOOP ;   /* Step Dependency loop */

/* NAMIT_CR Code To Link Step Dependency to Routing Header End */

   END IF ;   /* old rtg */

     --  For organization routing
     start_org_pos_written := 0 ;
     For k IN org_start_pos..rtg_org_dtl_size
     LOOP
      IF rtg_org_dtl_tab(k).routing_id = rtg_org_hdr_tab(i).routing_id AND
         rtg_org_dtl_tab(k).orgn_code  = rtg_org_hdr_tab(i).plant_code THEN

          IF start_org_pos_written = 0 THEN
              rtg_org_hdr_tab(i).orgn_start_loc := k ;
              start_org_pos_written := 1 ;
          END IF ;
          IF k = rtg_org_dtl_size THEN
              rtg_org_hdr_tab(i).orgn_end_loc := k ;
          END IF ;

      ELSIF (rtg_org_dtl_tab(k).routing_id > rtg_org_hdr_tab(i).routing_id) OR
          (
          (rtg_org_dtl_tab(k).routing_id = rtg_org_hdr_tab(i).routing_id) AND
          (rtg_org_dtl_tab(k).orgn_code  > rtg_org_hdr_tab(i).plant_code)
          )  THEN

            IF start_org_pos_written <> 1 THEN
              rtg_org_hdr_tab(i).orgn_start_loc := -1 ;
              rtg_org_hdr_tab(i).orgn_end_loc :=  -1 ;
            ELSE
              rtg_org_hdr_tab(i).orgn_end_loc := k - 1 ;
            END IF ;
            org_start_pos := k ;
            EXIT ;

      /* ELSE - no need to write, continue looping. */
      END IF ;
     END LOOP ;   /* Organization loop */

     old_routing_id := rtg_org_hdr_tab(i).routing_id ;

  END LOOP ;  /* routing header loop */

  -- gmp_putline(' End Link Rtg ','a');
END link_routing;

/*
REM+=========================================================================+
REM| PROCEDURE NAME                                                          |
REM|    validate_routing                                                     |
REM| DESCRIPTION                                                             |
REM|   1. ALL Items in effectivity needs to be convertible to Routing UOM    |
REM|   2. ALL details are present in gmp_item_aps with appropriate flags     |
REM|                                                                         |
REM| HISTORY                                                                 |
REM| 07/14/2002   Rajesh Patangya - Reorgnized the complete code B2314052    |
REM+=========================================================================+
*/
PROCEDURE validate_routing (prouting_id IN NUMBER ,
                           porgn_code   IN VARCHAR2,
                           pheader_loc  IN NUMBER,
                           prout_valid  OUT NOCOPY BOOLEAN)
IS

  uom_statement           VARCHAR2(2000) ;
  old_routingstep_id      NUMBER   ;
  old_oprn_no             VARCHAR2(32)  ;
  old_activity            NUMBER ;
  i                       INTEGER ;
  j                       INTEGER ;
  start_genric_count      NUMBER ;
  end_genric_count        NUMBER ;
  start_orgn_count        NUMBER ;
  end_orgn_count          NUMBER ;
  rtg_org_loc             NUMBER ;
  prim_rsrc_cnt           NUMBER ;
  p_uom_qty               NUMBER ;
  rtg_valid               BOOLEAN ;
  found_match             BOOLEAN ;

--
  k                       INTEGER;
  step_start_index        INTEGER;
  step_end_index          INTEGER;
  usage_start_index       INTEGER;
  usage_end_index         INTEGER;
  prev_routingstep_id     NUMBER;
  l_setup_id              NUMBER;

BEGIN
  uom_statement           := NULL ;
  old_routingstep_id      := 0 ;
  old_oprn_no             := ' ' ;
  old_activity            := -1 ;
  i                       := 1 ;
  j                       := 1 ;
  start_genric_count      := 0 ;
  end_genric_count        := 0 ;
  start_orgn_count        := 0 ;
  end_orgn_count          := 0 ;
  rtg_org_loc             := 0 ;
  prim_rsrc_cnt           := 0 ;
  p_uom_qty               := -1 ;
  rtg_valid               := TRUE ;
  found_match             := TRUE ;
  prim_rsrc_cnt      := 0 ;
  found_match        := TRUE ;
  prev_routingstep_id     := NULL ;
  l_setup_id              := NULL;

   rtg_org_loc        := pheader_loc;
   start_genric_count := rtg_org_hdr_tab(rtg_org_loc).generic_start_loc;
   end_genric_count   := rtg_org_hdr_tab(rtg_org_loc).generic_end_loc;
   start_orgn_count   := rtg_org_hdr_tab(rtg_org_loc).orgn_start_loc;
   end_orgn_count     := rtg_org_hdr_tab(rtg_org_loc).orgn_end_loc;

-- Overrides Rajesh {
   rtg_valid                 := TRUE ;
   k                         := 1;

   step_start_index :=
      rtg_org_hdr_tab(effectivity.rtg_hdr_location).step_start_loc ;
   step_end_index :=
      rtg_org_hdr_tab(effectivity.rtg_hdr_location).step_end_loc ;
   usage_start_index :=
      rtg_org_hdr_tab(effectivity.rtg_hdr_location).usage_start_loc ;
   usage_end_index :=
      rtg_org_hdr_tab(effectivity.rtg_hdr_location).usage_end_loc ;

-- Changes for Overrides Rajesh }

   /* Generic routing check */
   IF (start_genric_count > 0) AND (end_genric_count > 0 ) THEN
   FOR i IN start_genric_count..end_genric_count
   LOOP
     /* { */
      IF (rtg_gen_dtl_tab(i).routing_id = prouting_id) THEN

         /* If operation, activity, step change then */
         IF (i = start_genric_count) OR
            (rtg_gen_dtl_tab(i).routingstep_id <> old_routingstep_id) OR
            (rtg_gen_dtl_tab(i).oprn_no <> old_oprn_no) OR
            (rtg_gen_dtl_tab(i).oprn_line_id <>  old_activity)  THEN
              prim_rsrc_cnt := 0 ;
          END IF ;

          IF rtg_gen_dtl_tab(i).prim_rsrc_ind = 1 THEN
             prim_rsrc_cnt := prim_rsrc_cnt + 1 ;
          END IF ;

          /* If no primary/ multiple primary resource exit and invalidate
             the rtg_header for all the organization */
          IF prim_rsrc_cnt <> 1 THEN
              --  Routing INVALID We should not do any further processing
              prim_rsrc_cnt := 0 ;
              invalidate_rtg_all_org(prouting_id) ;
              rtg_valid := FALSE;
              EXIT ;
          END IF ;

          old_routingstep_id := rtg_gen_dtl_tab(i).routingstep_id ;
          old_oprn_no        := rtg_gen_dtl_tab(i).oprn_no ;
          old_activity       := rtg_gen_dtl_tab(i).oprn_line_id ;

       /* organization check */
       IF (start_orgn_count > 0) AND (end_orgn_count > 0 ) AND
             (start_orgn_count <= end_orgn_count)
       THEN
       FOR j IN start_orgn_count..end_orgn_count
       LOOP
        /* {{ */
         IF (rtg_org_dtl_tab(j).orgn_code = porgn_code)  AND
            (rtg_org_dtl_tab(j).routing_id = prouting_id) THEN

-- ------------------
         IF (rtg_org_dtl_tab(j).routingstep_id <> nvl(prev_routingstep_id,-1)) THEN

           IF (rtg_org_dtl_tab(j).is_unique = 1) AND (effectivity.category_id > 0)
	   THEN
               l_setup_id := bsearch_setupid(rtg_org_dtl_tab(j).oprn_id,
                                 effectivity.category_id);
               IF l_setup_id > 0 THEN
                  rtg_org_dtl_tab(j).setup_id := l_setup_id ;
               ELSE
                 /* The actual SDS changeover data is not established */
                 rtg_org_dtl_tab(j).setup_id := NULL ;
               END IF;
           END IF;
           prev_routingstep_id := rtg_org_dtl_tab(j).routingstep_id ;
         END IF;
         IF (rtg_org_dtl_tab(j).is_unique = 1) AND (effectivity.category_id > 0) THEN
            sd_index := sd_index + 1 ;
            sds_tab(sd_index).oprn_id        := rtg_org_dtl_tab(j).oprn_id ;
            sds_tab(sd_index).category_id    := effectivity.category_id    ;
            sds_tab(sd_index).seq_dpnd_class := effectivity.seq_dpnd_class ;
            sds_tab(sd_index).resources      := rtg_org_dtl_tab(j).resources ;
            sds_tab(sd_index).resource_id    := rtg_org_dtl_tab(j).resource_id ;
            sds_tab(sd_index).setup_id       := rtg_org_dtl_tab(j).setup_id ;
         END IF;
-- ------------------
          /* -------- Get step qty override (RDP) ------------------*/

            rtg_org_dtl_tab(j).o_resource_usage  := -1 ;
            rtg_org_dtl_tab(j).o_activity_factor := -1 ;
            rtg_org_dtl_tab(j).o_step_qty        := -1 ;
            rtg_org_dtl_tab(j).o_process_qty     := -1 ;
            rtg_org_dtl_tab(j).o_max_capacity    := -1 ;
            rtg_org_dtl_tab(j).o_min_capacity    := -1 ;

            IF (step_start_index > 0) AND (step_end_index > 0) THEN
            k := 1 ;
            FOR k IN step_start_index..step_end_index
            LOOP
             IF (effectivity.recipe_id =
                   recipe_override(k).recipe_id) THEN

             IF (rtg_org_dtl_tab(j).routing_id =
                   recipe_override(k).routing_id) AND
                (rtg_org_dtl_tab(j).routingstep_id =
                   recipe_override(k).routingstep_id) THEN

                 rtg_org_dtl_tab(j).o_step_qty :=
                    recipe_override(k).step_qty ;
                 EXIT ;
             END IF ;
            ELSE
                 rtg_org_dtl_tab(j).o_step_qty := -1 ;
                 EXIT ;
            END IF; /* Get step qty override */

            END LOOP ;   /* Step Qty Override */
            END IF; /* Get step qty override */
           /* -------- step qty override Ends (RDP) ------------------*/

            IF (rtg_gen_dtl_tab(i).routingstep_id =
                               rtg_org_dtl_tab(j).routingstep_id) AND
               (rtg_gen_dtl_tab(i).oprn_line_id =
                               rtg_org_dtl_tab(j).oprn_line_id) AND
               (rtg_gen_dtl_tab(i).resources =
                                rtg_org_dtl_tab(j).resources) THEN

      /* ------------ Override Calculation Code start ----------------------*/

            IF ((usage_start_index > 0) AND (usage_end_index > 0)) THEN
            k := 1 ;
              FOR k IN usage_start_index..usage_end_index
              LOOP
               /* { */
               IF (rtg_org_dtl_tab(j).routing_id =
                      rcp_orgn_override(k).routing_id) AND
                     (rtg_org_dtl_tab(j).orgn_code =
                      rcp_orgn_override(k).orgn_code) AND
                     (rtg_org_dtl_tab(j).routingstep_id =
                      rcp_orgn_override(k).routingstep_id) AND
                     (rtg_org_dtl_tab(j).oprn_line_id =
                      rcp_orgn_override(k).oprn_line_id) AND
                     (effectivity.recipe_id =
                      rcp_orgn_override(k).recipe_id) THEN

                   -- Activity factor override
                     rtg_org_dtl_tab(j).o_activity_factor :=
                               rcp_orgn_override(k).activity_factor;
                   -- Resource Overrides
                 /* { */
                 IF (rtg_org_dtl_tab(j).resources =
                         rcp_orgn_override(k).resources) THEN

                     rtg_org_dtl_tab(j).o_resource_usage :=
                            rcp_orgn_override(k).resource_usage;
                   -- Process Qty override
                     rtg_org_dtl_tab(j).o_process_qty :=
                             rcp_orgn_override(k).process_qty ;
                   -- Min / Max Capacity Overrides
                     rtg_org_dtl_tab(j).o_min_capacity :=
                             rcp_orgn_override(k).min_capacity ;
                     rtg_org_dtl_tab(j).o_max_capacity :=
                             rcp_orgn_override(k).max_capacity ;
                 END IF ; /* } Resource Overrides */

               END IF ;  /* }check for routing/step/oprn/recipe */

              END LOOP;  /* Override Loop Ends here */
            END IF; /* } check for Override presence */

            IF (rtg_org_dtl_tab(j).prim_rsrc_ind = 1) THEN

                     IF (rtg_org_dtl_tab(j).o_resource_usage = -1 ) THEN

                       IF (rtg_org_dtl_tab(j).resource_usage = 0) THEN
                        rtg_valid := FALSE ;
        		rtg_org_hdr_tab(rtg_org_loc).valid_flag := -1 ;
                        log_message('Recipe ' || effectivity.recipe_id ||' '||
                               rtg_org_dtl_tab(j).resources|| ' has usage 0');
                        EXIT ;
                       END IF;
                     ELSIF (rtg_org_dtl_tab(j).o_resource_usage = 0) THEN
                        rtg_valid := FALSE ;
                        log_message('Recipe ' || effectivity.recipe_id ||' '||
                               rtg_org_dtl_tab(j).resources|| ' has usage 0');
                        EXIT ;
                     END IF ;

                     IF (rtg_org_dtl_tab(j).o_activity_factor = -1 ) THEN
                       IF (rtg_org_dtl_tab(j).activity_factor = 0) THEN
                        rtg_valid := FALSE ;
        		rtg_org_hdr_tab(rtg_org_loc).valid_flag := -1 ;
                        log_message('Recipe ' || effectivity.recipe_id ||
                         ' has ZERO activity factor');
                        EXIT;
                       END IF;
                     ELSIF (rtg_org_dtl_tab(j).o_activity_factor = 0) THEN
                        rtg_valid := FALSE ;
                        log_message('Recipe ' || effectivity.recipe_id ||
                         ' has ZERO Override activity factor');
                        EXIT ;
                     END IF ;

                     IF (rtg_org_dtl_tab(j).o_step_qty = -1 ) THEN
                       IF (rtg_org_dtl_tab(j).step_qty = 0) THEN
                        rtg_valid := FALSE ;
        		rtg_org_hdr_tab(rtg_org_loc).valid_flag := -1 ;
                        log_message('Recipe ' || effectivity.recipe_id ||
                         ' has ZERO step qty');
                        EXIT ;
                       END IF;
                     ELSIF (rtg_org_dtl_tab(j).o_step_qty = 0) THEN
                        rtg_valid := FALSE ;
                        log_message('Recipe ' || effectivity.recipe_id ||
                         ' has ZERO override step qty');
                        EXIT ;
                     END IF ;
            END IF;  /* For primary resource chack */
/*
    IF rtg_org_dtl_tab(j).routing_id = 58 THEN
     log_message (
     rtg_org_dtl_tab(j).routing_id ||'*'||
     effectivity.recipe_id ||'*'||
     rtg_org_dtl_tab(j).prim_rsrc_ind      ||'*'||
     rtg_org_dtl_tab(j).routingstep_id         ||' Us '||
     rtg_org_dtl_tab(j).resources     ||'* '||
     rtg_org_dtl_tab(j).resource_usage      ||' *'||
     rtg_org_dtl_tab(j).o_resource_usage      ||' AF '||
     rtg_org_dtl_tab(j).activity_factor      ||' *'||
     rtg_org_dtl_tab(j).o_activity_factor      ||' SQ '||
     rtg_org_dtl_tab(j).step_qty      ||' *'||
     rtg_org_dtl_tab(j).o_step_qty     ||' PQ '||
     rtg_org_dtl_tab(j).process_qty      ||' *'||
     rtg_org_dtl_tab(j).o_process_qty      ||' M '||
     rtg_org_dtl_tab(j).min_capacity   ||' *'||
     rtg_org_dtl_tab(j).o_min_capacity   ||' X '||
     rtg_org_dtl_tab(j).max_capacity   ||' *'||
     rtg_org_dtl_tab(j).o_max_capacity);
     END IF;
*/
      /* ------------ Override Calculation Code start ----------------------*/

                IF (rtg_org_dtl_tab(j).prim_rsrc_ind = 1
                    AND rtg_org_dtl_tab(j).schedule_ind = 3) THEN

                    rtg_valid := FALSE;
        	    rtg_org_hdr_tab(rtg_org_loc).valid_flag := -1 ;
                    log_message('Primary Resource '||rtg_org_dtl_tab(j).resources||
                        ' is defined as Do Not Plan ');
                    EXIT;
                ELSIF (rtg_org_dtl_tab(j).prim_rsrc_ind <> 1
                    AND rtg_org_dtl_tab(j).schedule_ind = 3) THEN

                    start_orgn_count := j + 1 ;
                    rtg_org_dtl_tab(j).include_rtg_row := 0;
                    EXIT;
                ELSE
                    rtg_valid := TRUE ;
        	    rtg_org_hdr_tab(rtg_org_loc).valid_flag := 1 ;
                    start_orgn_count := j + 1 ;
                    EXIT ;
                END IF;

            ELSE
              -- Make the rtg invalid ONLY if the Primary or Auxilary
              -- resources for any activity is missing
              IF rtg_gen_dtl_tab(i).prim_rsrc_ind <> 0 THEN
                 rtg_valid := FALSE ;
                log_message('Missing Plant Resource '||rtg_org_dtl_tab(j).resources);
      -- gmp_putline('Missing resource ' || rtg_org_dtl_tab(j).resources,'a');
              END IF ;
              EXIT;
            END IF ;

         END IF;
         /* }} */
       END LOOP;   /* Orgnization  Loop */
       ELSE
          -- If there are no organization details , the rtg is invalid
          rtg_valid := FALSE ;
       END IF;  /* organization check */

         IF rtg_valid = FALSE THEN
            EXIT ;
         END IF ;
     END IF;
     /* } */
   END LOOP ;  /* Generic Loop */
   ELSE
        -- If no generic routing details present, make routing invalid
        rtg_valid := FALSE ;
        invalidate_rtg_all_org(prouting_id) ;
   END IF;  /* Generic routing check */

   IF rtg_valid THEN
        rtg_org_hdr_tab(rtg_org_loc).valid_flag := 1 ;
   ELSE
        rtg_org_hdr_tab(rtg_org_loc).valid_flag := -1 ;
   END IF ;

     prout_valid := rtg_valid ;

END validate_routing ;

/*
REM+=========================================================================+
REM| PROCEDURE NAME                                                          |
REM|    invalidate_rtg_all_org                                               |
REM| DESCRIPTION                                                             |
REM|                                                                         |
REM| HISTORY                                                                 |
REM| 07/14/2002   Rajesh Patangya - Reorgnized the complete code B2314052    |
REM+=========================================================================+
*/
PROCEDURE invalidate_rtg_all_org (p_routing_id IN NUMBER) IS

  i INTEGER ;
BEGIN
  i := 1  ;
   FOR i IN 1..routing_headers_size
   LOOP
     IF rtg_org_hdr_tab(i).routing_id = p_routing_id THEN
           rtg_org_hdr_tab(i).valid_flag := -1 ;
     ELSIF rtg_org_hdr_tab(i).routing_id > p_routing_id THEN
           EXIT ;
     /* ELSE
           NULL ;  */
     END IF;
   END LOOP ;
END invalidate_rtg_all_org;

/*
REM+=========================================================================+
REM| PROCEDURE NAME                                                          |
REM|    validate_formula                                                     |
REM| DESCRIPTION                                                             |
REM|                                                                         |
REM|   Note that we are going to structure the formula retrieval query       |
REM|   so that only the formulae used in Effectivities are fetched           |
REM|   so trying to validate all at once does not cause any extra work       |
REM|  Summary : Two validations need to be performed                         |
REM|    1. ALL details can be converted to primary UOM                       |
REM|    2. ALL details are present in gmp_item_aps with appropriate flags    |
REM|                                                                         |
REM| It is now determined that the check for gmp_item_aps and flags therein  |
REM| should NOT be done here , so would be made immediately before inserting |
REM| rows. The same may also be achieved by joining to gmp_item_aps table    |
REM| while getting formula details                                           |
REM|                                                                         |
REM| HISTORY                                                                 |
REM| 07/14/2002   Rajesh Patangya - Reorgnized the complete code B2314052    |
REM+=========================================================================+
*/
PROCEDURE validate_formula IS

i                  INTEGER ;
j                  INTEGER ;
current_dtl_cnt    INTEGER ;
start_pos_written  NUMBER ;
detail_found       NUMBER ;
uom_success        BOOLEAN ;

BEGIN
i                  := 1 ;
j                  := 1 ;
current_dtl_cnt    := 1 ;
start_pos_written  := 0 ;
detail_found       := 0 ;
uom_success        := FALSE ;
   --  gmp_putline(' Begin validate_formula ','a');
   FOR i IN 1..formula_headers_size
   LOOP
     uom_success       := TRUE ;
     start_pos_written := 0 ;
     detail_found      := 0 ;

     FOR j IN current_dtl_cnt..formula_details_size
     LOOP
       IF formula_detail_tab(j).formula_id = formula_header_tab(i).formula_id
       THEN
           detail_found  := 1 ;
           IF formula_detail_tab(j).primary_qty < 0  THEN
		uom_success := FALSE ;
           ELSE
		uom_success := TRUE ;
           END IF;

           --  store the starting detail position
           IF start_pos_written = 0 THEN
              formula_header_tab(i).start_dtl_loc := j ;
              start_pos_written := 1 ;
           END IF;

           --  store the ending detail position, if it is the last row
           IF j = formula_details_size THEN
              formula_header_tab(i).end_dtl_loc := j ;
           END IF ;

       ELSIF formula_detail_tab(j).formula_id >
                          formula_header_tab(i).formula_id THEN

           --  store the ending detail position
           IF start_pos_written <> 1 THEN
              formula_header_tab(i).start_dtl_loc := -1 ;
              formula_header_tab(i).end_dtl_loc := -1 ;
           ELSE
              formula_header_tab(i).end_dtl_loc := j - 1 ;
           END IF ;
           current_dtl_cnt := j ;
           EXIT ;

       /* ELSE - no need to write else as it simply has to continue looping. */
       END IF ;

     END LOOP ;   /* formula_details_size  */

     IF (detail_found = 1) THEN
         IF (uom_success) THEN
           formula_header_tab(i).valid_flag := 1 ;
         ELSE
           formula_header_tab(i).valid_flag := -1 ;
           formula_header_tab(i).start_dtl_loc := -1 ;
           formula_header_tab(i).end_dtl_loc := -1 ;
   	   log_message(
                  'UOM Conversion falied for formula ' ||
   		  to_char(formula_header_tab(i).formula_id)
                  );
          END IF ;
     ELSE
           formula_header_tab(i).valid_flag := -1 ;
           formula_header_tab(i).start_dtl_loc := -1 ;
           formula_header_tab(i).end_dtl_loc := -1 ;
	/* B4625724
   	   log_message(
                  'Formula detail not found for formula ' ||
   		  to_char(formula_header_tab(i).formula_id)
                  );
	*/
     END IF ;

   END LOOP ;   /* Formula header loop */

   /* Now validate the formula for all the organizations */
   validate_formula_for_orgn ;

   --  gmp_putline(' End validate_formula ','a');
END validate_formula ;

/*
REM+=========================================================================+
REM| PROCEDURE NAME                                                          |
REM|    validate_formula_for_orgn                                            |
REM| DESCRIPTION                                                             |
REM|    This procedure contains SQL query, but getting executed only once.   |
REM| HISTORY                                                                 |
REM| 07/14/2002   Rajesh Patangya - Reorgnized the complete code B2314052    |
REM| 08/27/2002   Rajesh Patangya - Voltek Customer Fix B2362810             |
REM+=========================================================================+
*/
PROCEDURE validate_formula_for_orgn IS

    formula_orgn_count_cursor       VARCHAR2(32700) ;
    formula_dtl_count_cursor        VARCHAR2(32700) ;
    cur_formula_orgn_count          ref_cursor_typ;
    c_formula_dtl_count             ref_cursor_typ;
    fm_dtl_orgn_cnt                 INTEGER ;
    i                               INTEGER ;

BEGIN
    formula_orgn_count_cursor       := NULL ;
    formula_dtl_count_cursor        := NULL ;
    fm_dtl_orgn_cnt                 := 1 ;
    i                               := 1 ;
      --  gmp_putline(' start of validate_formula_for_org ','a');

   formula_orgn_count_cursor :=
                     ' SELECT fmd.formula_id, gia.plant_code, '
                   ||'       gia.organization_id, count(*), 0 '
                   ||' FROM  fm_matl_dtl'||at_apps_link||' fmd, '
                   ||'       fm_form_mst'||at_apps_link||' ffm, '
                   ||'       gmp_item_aps'||at_apps_link||' gia, '
                   ||'       sy_orgn_mst'||at_apps_link||' som '
                   ||' WHERE ffm.formula_id = fmd.formula_id '
                   ||'   AND ffm.delete_mark = 0 '
                   ||'   AND fmd.qty <> 0 '  /* 2362810 Voltek Fix */
                   ||'   AND fmd.item_id = gia.item_id '
                   ||'   AND gia.plant_code = som.orgn_code ' ;
         IF l_in_str_org  IS NOT NULL THEN
            formula_orgn_count_cursor := formula_orgn_count_cursor
                   ||'   AND gia.whse_code = som.resource_whse_code ' ;
        END IF;

         formula_orgn_count_cursor := formula_orgn_count_cursor
                   ||'   AND ( '
                   ||'       ( fmd.line_type = -1 AND '
                   ||'         gia.consum_ind = 1 ) '
                   ||'     OR '
                   ||'       ( fmd.line_type IN (1,2) AND '
                   ||'         gia.replen_ind = 1 ) '
                   ||'       ) '
                   ||' GROUP BY fmd.formula_id, gia.plant_code, '
                   ||'          gia.organization_id, 0 '
                   ||' ORDER BY fmd.formula_id, gia.plant_code, '
                   ||'          gia.organization_id ' ;

       -- Get counts for the formulae
       formula_dtl_count_cursor :=
                     ' SELECT fmd.formula_id, count(*) '
                   ||' FROM  fm_matl_dtl'||at_apps_link||' fmd, '
                   ||'       fm_form_mst'||at_apps_link||' ffm '
                   ||' WHERE ffm.formula_id = fmd.formula_id '
                   ||'   AND ffm.delete_mark = 0 '
                   ||'   AND fmd.qty <> 0 '   /* 2362810 Voltek Fix */
                   ||' GROUP BY fmd.formula_id '
                   ||' ORDER BY fmd.formula_id ' ;

    OPEN cur_formula_orgn_count FOR formula_orgn_count_cursor;
    LOOP
    FETCH cur_formula_orgn_count INTO formula_orgn_count_tab(formula_orgn_size);
    EXIT WHEN cur_formula_orgn_count%NOTFOUND;

    formula_orgn_size := formula_orgn_size + 1 ;
    END LOOP;
    CLOSE cur_formula_orgn_count;
    formula_orgn_size := formula_orgn_size -1 ;
    time_stamp ;
    log_message('Formula Orgn size is = ' || to_char(formula_orgn_size)) ;

    OPEN c_formula_dtl_count FOR formula_dtl_count_cursor ;
    FETCH c_formula_dtl_count INTO formula_dtl_count_rec ;
     WHILE c_formula_dtl_count%FOUND
     LOOP

       FOR i IN fm_dtl_orgn_cnt..formula_orgn_size
       LOOP
        IF formula_dtl_count_rec.formula_id =
                      formula_orgn_count_tab(i).formula_id THEN

             IF formula_dtl_count_rec.formula_dtl_count =
                      formula_orgn_count_tab(i).orgn_count THEN
                 formula_orgn_count_tab(i).valid_flag := 1 ;
             ELSE
                 formula_orgn_count_tab(i).valid_flag := -1 ;
             END IF ;

        ELSIF formula_dtl_count_rec.formula_id <
                 formula_orgn_count_tab(i).formula_id THEN
                 fm_dtl_orgn_cnt := i ;
              EXIT ;

        /*  ELSE NULL ;  */
        END IF ;
       END LOOP ;

     /* Get the next record */
     FETCH c_formula_dtl_count INTO formula_dtl_count_rec ;
     END LOOP ;
     CLOSE c_formula_dtl_count ;
     --   gmp_putline(' End of validate_formula_for_org ','a');

END validate_formula_for_orgn;

/*
REM+=========================================================================+
REM| FUNCTION NAME                                                           |
REM|    check_formula                                                        |
REM| DESCRIPTION                                                             |
REM|                                                                         |
REM| HISTORY                                                                 |
REM| 07/14/2002   Rajesh Patangya - Reorgnized the complete code B2314052    |
REM+=========================================================================+
*/
FUNCTION check_formula ( pplant_code IN VARCHAR2,
                         porganization_id IN NUMBER,
                         pformula_id IN NUMBER) return BOOLEAN IS

i                 INTEGER ;
p_plant_code      VARCHAR2(4) ;
p_organization_id NUMBER ;
p_formula_id      NUMBER ;

BEGIN
p_plant_code      := pplant_code;
p_organization_id := porganization_id;
p_formula_id      := pformula_id;

FOR i in g_fm_hdr_loc..formula_headers_size
LOOP
	IF  formula_header_tab(i).formula_id = pformula_id THEN
	    IF formula_header_tab(i).valid_flag = 1 THEN
		-- Note down formula_header location to be used
		-- while writing the bom
		g_fm_dtl_start_loc := formula_header_tab(i).start_dtl_loc ;
		g_fm_dtl_end_loc := formula_header_tab(i).end_dtl_loc ;
	        IF check_formula_for_organization (p_plant_code ,
                                                   p_organization_id ,
                                                   p_formula_id) THEN
		  g_fm_hdr_loc := i ;
                  return TRUE ;
                ELSE
		  g_fm_hdr_loc := i ;
                  return FALSE ;
                END IF;
            ELSE
		  g_fm_hdr_loc := i ;
		  /* Bug 4625724-Relocated message here so we do not list
			invalid formulas indep of organization*/
		  log_message('Formula detail not found for formula id = ' ||
                 to_char(formula_header_tab(i).formula_id)||' in organization id = '||
              		to_char(p_organization_id));
                  return FALSE ;
	    END IF ;  /* Header validation */
	ELSIF formula_header_tab(i).formula_id > pformula_id THEN
		g_fm_hdr_loc := i ;
		return FALSE ;
        /* ELSE
             NULL ;   */
	END IF ;
END LOOP ;
		return FALSE ;
END check_formula ;

/*
REM+=========================================================================+
REM| FUNCTION NAME                                                           |
REM|    check_formula_for_organization                                       |
REM| DESCRIPTION                                                             |
REM|                                                                         |
REM| HISTORY                                                                 |
REM| 07/14/2002   Rajesh Patangya - Reorgnized the complete code B2314052    |
REM+=========================================================================+
*/
FUNCTION check_formula_for_organization (
                         pplant_code IN VARCHAR2,
                         porganization_id IN NUMBER,
                         pformula_id IN NUMBER) return BOOLEAN IS
i            INTEGER ;
BEGIN
i            := 1  ;
FOR i IN g_formula_orgn_count_tab..formula_orgn_count_tab.COUNT
LOOP
  IF formula_orgn_count_tab(i).formula_id = pformula_id THEN

    IF formula_orgn_count_tab(i).plant_code = pplant_code THEN
        IF formula_orgn_count_tab(i).organization_id = porganization_id THEN
          IF formula_orgn_count_tab(i).valid_flag = 1 THEN
             g_formula_orgn_count_tab := i ;
             return TRUE ;
          ELSE
             g_formula_orgn_count_tab := i ;
             return FALSE ;
          END IF;
        ELSIF formula_orgn_count_tab(i).organization_id > porganization_id THEN
             g_formula_orgn_count_tab := i ;
             return FALSE ;
           /* ELSE
                 NULL ;  */
        END IF;  /* Organizatin ID */
    ELSIF formula_orgn_count_tab(i).plant_code >  pplant_code THEN
             g_formula_orgn_count_tab := i ;
             return FALSE ;
    /* ELSE
        NULL ;  */
    END IF ;   /* For Plant code  */
  ELSIF formula_orgn_count_tab(i).formula_id > pformula_id THEN
           g_formula_orgn_count_tab := i ;
           return FALSE ;
  /* ELSE
    NULL ;  */
  END IF;
END LOOP ;
   return FALSE ;
END check_formula_for_organization ;

/*
REM+=========================================================================+
REM| FUNCTION NAME                                                           |
REM|    bsearch_routing                                                      |
REM| DESCRIPTION                                                             |
REM|                                                                         |
REM| HISTORY                                                                 |
REM| 07/14/2002   Rajesh Patangya - Reorgnized the complete code B2314052    |
REM+=========================================================================+
*/
FUNCTION bsearch_routing (p_routing_id IN NUMBER ,
			  p_plant_code IN VARCHAR2)
			RETURN INTEGER IS

top     INTEGER ;
bottom  INTEGER ;
mid     INTEGER ;

BEGIN
     top    := 1;
     bottom := routing_headers_size ;
     mid    := -1 ;
   WHILE  (top <= bottom )
    LOOP
     mid := top + ( ( bottom - top ) / 2 );

     IF p_routing_id < rtg_org_hdr_tab(mid).routing_id OR
  	(p_routing_id = rtg_org_hdr_tab(mid).routing_id AND
	 p_plant_code < rtg_org_hdr_tab(mid).plant_code ) THEN
	bottom := mid -1 ;
     ELSIF
	p_routing_id > rtg_org_hdr_tab(mid).routing_id OR
        (p_routing_id = rtg_org_hdr_tab(mid).routing_id AND
         p_plant_code > rtg_org_hdr_tab(mid).plant_code ) THEN
	top := mid + 1 ;
     ELSE
	-- We can do the checking for the validity etc here
	-- OR just return the location to calling function and
	-- let the calling function do rest of the work
	RETURN mid ;
     END IF ;
    END LOOP;
    -- Not found
    Return -1 ;
END bsearch_routing ;
/*
REM+=========================================================================+
REM| FUNCTION NAME                                                           |
REM|    bsearch_setupid  SGIDUGU                                             |
REM| DESCRIPTION                                                             |
REM|                                                                         |
REM| HISTORY                                                                 |
REM+=========================================================================+
*/
FUNCTION bsearch_setupid (p_oprn_id       IN NUMBER ,
                          p_category_id   IN NUMBER
                         ) RETURN INTEGER IS
--
top     INTEGER ;
bottom  INTEGER ;
mid     INTEGER ;

BEGIN
--
     top    := 1;
     bottom := setup_size ;
     mid    := -1 ;
--
   WHILE  (top <= bottom )
    LOOP
     mid := top + ( ( bottom - top ) / 2 );

     IF p_oprn_id < setupid_tab(mid).oprn_id OR
  	(p_oprn_id = setupid_tab(mid).oprn_id AND
	 p_category_id < setupid_tab(mid).category_id ) THEN
	bottom := mid -1 ;
     ELSIF
	p_oprn_id > setupid_tab(mid).oprn_id OR
        (p_oprn_id = setupid_tab(mid).oprn_id AND
         p_category_id > setupid_tab(mid).category_id ) THEN
	top := mid + 1 ;
     ELSE
--	RETURN mid ;
	RETURN setupid_tab(mid).seq_dep_id ;
     END IF ;
    END LOOP;
    -- Not found
    Return -1 ;
END bsearch_setupid ;
/*
REM+=========================================================================+
REM| PROCEDURE NAME                                                          |
REM|    write_process_effectivities                                          |
REM|                                                                         |
REM| TYPE                                                                    |
REM|    Private                                                              |
REM|                                                                         |
REM| USAGE                                                                   |
REM|    This procedure creates the effectivty rows in gmp_form_eff and       |
REM|    msc_process_effectivities                                            |
REM|                                                                         |
REM| DESCRIPTION                                                             |
REM|                                                                         |
REM|                                                                         |
REM| INPUT PARAMETERS                                                        |
REM|    None                                                                 |
REM|                                                                         |
REM| OUTPUT PARAMETERS                                                       |
REM|    return_status    TRUE => OK                                          |
REM|                                                                         |
REM| INPUT/OUTPUT PARAMETERS                                                 |
REM|    None                                                                 |
REM|                                                                         |
REM| HISTORY                                                                 |
REM|  07/14/2002   Rajesh Patangya - Reorgnized the complete code B2314052   |
REM|  06/02/2003   Sridhar Gidugu  Checked aps_fmeff_id before               |
REM|                               inserts - B2989806                        |
REM+=========================================================================+
*/
PROCEDURE write_process_effectivity
(
  p_x_aps_fmeff_id   IN NUMBER,
  p_aps_fmeff_id     IN NUMBER,
  return_status      OUT NOCOPY BOOLEAN
)
IS
  statement_form_eff     VARCHAR2(32700) ;
  loop_index       INTEGER;
  routing_id       NUMBER ;

BEGIN
  statement_form_eff     := NULL ;

/* B2989806  Added IF condition below */
IF effectivity.aps_fmeff_id = -1 THEN
    statement_form_eff :=
	          'INSERT INTO gmp_form_eff'||at_apps_link
		   ||' ( '
		   ||'  aps_fmeff_id,whse_code,plant_code,fmeff_id, '
                   ||'  formula_id, routing_id, '
		   ||'  creation_date, created_by, last_update_date, '
                   ||'  last_updated_by '
		   ||' ) '
		   ||' VALUES '
		   ||' ( :p1,:p2,:p3,:p4,:p5,:p6,:p7,:p8,:p9,:p10)';

             /* This aps_fmeff_id the next sequence ID, but not multiplied by
                2 and added by 1 */
    EXECUTE IMMEDIATE statement_form_eff USING
		   p_aps_fmeff_id,
		   effectivity.whse_code,
		   effectivity.plant_code,
		   effectivity.fmeff_id,
		   effectivity.formula_id,
		   effectivity.routing_id,
		   current_date_time,
		   0,
		   current_date_time,
		   0;
END IF ; /* New effectivity row to be created */

        /* Process Effectivity Bulk Insert assignment */

           pef_index := pef_index + 1 ;
           pef_process_sequence_id(pef_index) :=   p_x_aps_fmeff_id ;
           pef_item_id(pef_index) :=  effectivity.aps_item_id ;   /* aps_item_id */
           pef_organization_id(pef_index) :=  effectivity.organization_id ;
           pef_effectivity_date(pef_index) :=  effectivity.start_date ;

           IF effectivity.end_date IS NOT NULL THEN
                pef_disable_date(pef_index) :=  effectivity.end_date ;
           ELSE
                pef_disable_date(pef_index) := null_value ;
           END IF;

           pef_minimum_quantity(pef_index) :=  effectivity.inv_min_qty ;
           pef_maximum_quantity(pef_index) :=  effectivity.inv_max_qty ;
           pef_preference(pef_index)       :=  effectivity.preference ;
           pef_routing_sequence_id(pef_index) :=  p_x_aps_fmeff_id ;
           pef_bill_sequence_id(pef_index)    :=  p_x_aps_fmeff_id ;
           pef_sr_instance_id(pef_index) :=  b_instance_id ;
           -- pef_deleted_flag(pef_index)     := 2;
           pef_last_update_date(pef_index) := current_date_time ;
           -- bom_last_updated_by(pef_index)  := 0 ;
           pef_creation_date(pef_index)    := current_date_time ;
           -- pef_created_by(pef_index)       := 0;

  return_status := TRUE;

  EXCEPTION
    WHEN OTHERS THEN
       log_message('Write Process Effectivity Raised Exception: '||sqlerrm);
       log_message(to_char(effectivity.fmeff_id));
       return_status := FALSE;
END write_process_effectivity;

/*
REM+=========================================================================+
REM| PROCEDURE NAME                                                          |
REM|    write_bom_components                                                 |
REM|                                                                         |
REM| TYPE                                                                    |
REM|    Private                                                              |
REM|                                                                         |
REM| USAGE                                                                   |
REM|    This procedure creates the bill of material components in msc_boms   |
REM|                                                                         |
REM| DESCRIPTION                                                             |
REM|                                                                         |
REM|                                                                         |
REM| INPUT PARAMETERS                                                        |
REM|    None                                                                 |
REM|                                                                         |
REM| OUTPUT PARAMETERS                                                       |
REM|    return_status    TRUE => OK                                          |
REM|                                                                         |
REM| INPUT/OUTPUT PARAMETERS                                                 |
REM|    None                                                                 |
REM|                                                                         |
REM| HISTORY                                                                 |
REM|  07/14/2002   Rajesh Patangya - Reorgnized the complete code B2314052   |
REM|  08/27/2002 - B2098058 Alternate_bomdesignator is being passed          |
REM|               as the eff_id because 1. Alt_rtg_desgn is now required    |
REM|               per explanation in the bug 2.alt_rtg_desgn should be same |
REM|               alt_bom_desgn for the bom in the same eff 3.OPM has       |
REM|               has no way to determine primary bom/rtg from alternate    |
REM|                                                                         |
REM+=========================================================================+
*/
PROCEDURE write_bom_components
(
  p_x_aps_fmeff_id   IN NUMBER,
  return_status      OUT NOCOPY BOOLEAN
)
IS
  temp_assembly_comment   VARCHAR2(240) ;
  primary_bom_written     NUMBER ;
  p_primary_qty           NUMBER ;
  loop_index              INTEGER;
  l_scale_type            INTEGER;
  l_offset_loc            NUMBER ;
  l_offset           	  NUMBER ;
  l_line_type 		  INTEGER;
  rtgstpno_loc            NUMBER;
BEGIN
  temp_assembly_comment   := NULL ;
  p_primary_qty           := 0 ;
  l_offset_loc            := 0 ;
  l_offset           	  := 0 ;
  l_line_type 		  := 0 ;


  rtgstpno_loc := -1;
  primary_bom_written := 0 ;

  -- ABHAY write the code to get the offset percentages here.
  -- The code will loop through the formula_detail_tab  from
  -- g_fm_dtl_start_loc to g_fm_dtl_end_loc and update the field offset
  FOR loop_index IN g_fm_dtl_start_loc..g_fm_dtl_end_loc
  LOOP

     /* Do write a row for the primary produc */

   IF (effectivity.item_id = formula_detail_tab(loop_index).opm_item_id) AND
      (formula_detail_tab(loop_index).line_type = 1)  THEN
      IF primary_bom_written = 0 THEN
         /* WRITE_BOM : Do write a row for the primary product   */
        BEGIN
        /*B2870041 save the index of the product it will be used when writing
           the route and its details */
        effectivity.product_index := loop_index;

        temp_assembly_comment :=
	 formula_detail_tab(loop_index).formula_no ||delimiter||
	 to_char(formula_detail_tab(loop_index).formula_vers) ||delimiter||
	 formula_detail_tab(loop_index).formula_desc1 ;

         /* BOM Bulk Insert assignments */

         bom_index := bom_index + 1 ;
         bom_bill_sequence_id(bom_index) := p_x_aps_fmeff_id ;
         bom_sr_instance_id(bom_index)   := b_instance_id ;
         bom_organization_id(bom_index)  := effectivity.organization_id ;
         bom_assembly_item_id(bom_index) := effectivity.aps_item_id ;
         -- bom_assembly_type(bom_index)    := 1 ;
         bom_alternate_bom_designator(bom_index)  := p_x_aps_fmeff_id ;
         bom_specific_assembly_comment(bom_index) :=  temp_assembly_comment ;
         bom_scaling_type(bom_index)    :=
                             formula_detail_tab(loop_index).bom_scale_type ;
         bom_assembly_quantity(bom_index)  :=
                            formula_detail_tab(loop_index).primary_qty ;
         bom_uom(bom_index)  := formula_detail_tab(loop_index).aps_um ;
/* NAMIT_CR For Step Material Assoc */
/* Used enhanced binary search to get the location for routing
    step number of product. */

            rtgstpno_loc :=
               enh_bsearch_stpno (effectivity.formula_id, effectivity.recipe_id,
                  effectivity.item_id);

--

            IF(rtgstpno_loc > 0) THEN
               bom_op_seq_number(bom_index) := mat_assoc_tab(rtgstpno_loc).routingstep_no;
            ELSE
                bom_op_seq_number(bom_index) := null_value ;
            END IF;

--         bom_op_seq_number(bom_index) := formula_detail_tab(loop_index).routingstep_no;

         -- bom_deleted_flag(bom_index)     := 2;
         bom_last_update_date(bom_index) := current_date_time ;
         -- bom_last_updated_by(bom_index)  := 0 ;
         bom_creation_date(bom_index)    := current_date_time ;
         -- bom_created_by(bom_index)       := 0;

         EXCEPTION
              WHEN OTHERS THEN
              log_message('Error writing to msc_st_boms: '||sqlerrm);
              /* B3837959 MMK Issue, set return status to false */
              return_status := FALSE;
         END;
          primary_bom_written := 1 ;
--          primary_bom_formulaline_id := formula_detail_tab(loop_index).x_formulaline_id; -- Bug # 4879588
      -- 01/17/2003 Rajesh Patangya B2740767
      ELSE      /* Primary BOM written */
           /* Primary product written and now co-prod is same as prod
              note that the co-products always contribute to yield and
              scale type can only be fixed or linear per restrictions in GMD
           */
	-- Now get the offset percentage
	-- -------------------------------
	IF g_curr_rstep_loc > 0  AND
	(formula_detail_tab(loop_index).release_type between  1 AND 3)
	THEN
	 l_offset_loc := get_offsets( effectivity.formula_id,
				effectivity.plant_code,
		formula_detail_tab(loop_index).x_formulaline_id ) ;
	 IF l_offset_loc < 0 THEN
          IF formula_detail_tab(loop_index).line_type < 0 THEN
                l_offset := 0 ;
          ELSE
                l_offset := 100 ;
          END IF ;
	 ELSE
          IF formula_detail_tab(loop_index).line_type < 0 THEN
                l_offset := rstep_offsets(l_offset_loc).start_offset ;
          ELSE
                l_offset := rstep_offsets(l_offset_loc).end_offset ;
          END IF ;

	 END IF ;
	ELSE
	  IF formula_detail_tab(loop_index).line_type < 0 THEN
		l_offset := 0 ;
	  ELSE
		l_offset := 100 ;
	  END IF ;
	END IF ;
	-- -------------------------------

         BEGIN   /* co-product */
         /* BOM Component Bulk Insert assignments */
         bomc_index := bomc_index + 1 ;
         bomc_component_sequence_id(bomc_index) := formula_detail_tab(loop_index).x_formulaline_id ;
         bomc_sr_instance_id(bomc_index)   := b_instance_id ;
         bomc_organization_id(bomc_index)  := effectivity.organization_id ;
         bomc_Inventory_item_id(bomc_index) := formula_detail_tab(loop_index).aps_item_id ;
         bomc_using_assembly_id(bomc_index) := effectivity.aps_item_id ;
         bomc_bill_sequence_id(bomc_index) := p_x_aps_fmeff_id ;
         bomc_component_type(bomc_index) := 10 ;  /* for co-proudcts */
         bomc_scaling_type(bomc_index) := l_scale_type; /* Scailing type for APS */
           -- bomc_change_notice(i)  == null
           -- bomc_revision(i),  == null
         bomc_uom_code(bomc_index) := formula_detail_tab(loop_index).aps_um ;
         bomc_usage_quantity(bomc_index) :=  (-1 * formula_detail_tab(loop_index).primary_qty) ;
         bomc_effectivity_date(bomc_index) := current_date_time ;
         bomc_contribute_to_step_qty(bomc_index) := formula_detail_tab(loop_index).contribute_step_qty_ind;
         bomc_disable_date(bomc_index) := null_value ;
           -- bomc_from_unit_number := null_value,
           -- bomc_to_unit_number := null_value,
           -- bomc_use_up_code := null_value,
           -- bomc_suggested_effectivity_date := null_value,
           -- bomc_driving_item_id := null_value,
         IF l_offset IS NOT NULL THEN
           bomc_opr_offset_percent(bomc_index) := l_offset; /* offset percentage */
         ELSE
           bomc_opr_offset_percent(bomc_index) := null_value ;
         END IF;

         bomc_optional_component(bomc_index) := 2 ;
           -- bomc_old_effectivity_date := null_value,
         bomc_wip_supply_type(bomc_index) := formula_detail_tab(loop_index).phantom_type ;
           -- bomc_planning_factor := null_value,
           -- bomc_atp_flag := 1,
           -- bomc_component_yield_factor := 1,
           -- deleted_flag := 2,
         bomc_last_update_date(bomc_index) := current_date_time ;
           -- bomc_last_updated_by(bomc_index)  := 0 ;
         bomc_creation_date(bomc_index)    := current_date_time ;
           -- bomc_created_by(bomc_index)       := 0;
         IF  formula_detail_tab(loop_index).scale_multiple IS NOT NULL THEN
           bomc_scale_multiple(bomc_index) := formula_detail_tab(loop_index).scale_multiple ;
         ELSE
           bomc_scale_multiple(bomc_index) := null_value;
         END IF;
         IF formula_detail_tab(loop_index).scale_rounding_variance IS NOT NULL THEN
           bomc_scale_rounding_variance(bomc_index) :=
                     formula_detail_tab(loop_index).scale_rounding_variance ;
         ELSE
           bomc_scale_rounding_variance(bomc_index) := null_value;
         END IF;
         IF formula_detail_tab(loop_index).rounding_direction IS NOT NULL THEN
           bomc_rounding_direction(bomc_index) :=
                         formula_detail_tab(loop_index).rounding_direction ;
         ELSE
           bomc_rounding_direction(bomc_index) := null_value ;
         END IF;

         EXCEPTION
              WHEN OTHERS THEN
              log_message('Error co-products to msc_st_bom_comp: '||sqlerrm);
              /* B3837959 MMK Issue, set return status to false */
              return_status := FALSE;
         END ;   /* co-product */

      END IF ;  /* Primary BOM written */

   ELSE

     /* Do write all formula detail lines except primary product */
       IF formula_detail_tab(loop_index).line_type = -1 THEN
           p_primary_qty := formula_detail_tab(loop_index).primary_qty;
           /* B2559881, scrap_factor introduced */
           p_primary_qty := p_primary_qty *
            (1 + nvl(formula_detail_tab(loop_index).scrap_factor,0));
       ELSE
           p_primary_qty := (-1) * formula_detail_tab(loop_index).primary_qty;
           /* B2559881, scrap_factor introduced */
           p_primary_qty := p_primary_qty *
            (1 + nvl(formula_detail_tab(loop_index).scrap_factor,0));
       END IF;

       /* B3452524, If co-prodcut or by product is not same as product then
          component type should be 10 */

	IF formula_detail_tab(loop_index).line_type = 1 THEN
	  l_line_type := 10 ;
	ELSE
	  l_line_type := formula_detail_tab(loop_index).line_type ;
	END IF ;


    /* B2657068 Scailing type decision Rajesh Patangya */
    /*  Scale type in material detail 0-Fixed, 1-proportional 2-Integer */

    IF formula_detail_tab(loop_index).contribute_yield_ind = 'Y' THEN
       IF formula_detail_tab(loop_index).scale_type = 0 THEN
          l_scale_type := 0 ;
       ELSIF formula_detail_tab(loop_index).scale_type = 1 THEN
          l_scale_type := 1 ;
       ELSIF  formula_detail_tab(loop_index).scale_type = 2 THEN
          l_scale_type := 4 ;
       ELSE
         /* scale type of other than 0,1,2 is not supported */
         l_scale_type := formula_detail_tab(loop_index).scale_type ;
       END IF ;
    ELSE
       IF formula_detail_tab(loop_index).scale_type = 0 THEN
          l_scale_type := 2 ;
       ELSIF formula_detail_tab(loop_index).scale_type = 1 THEN
          l_scale_type := 3 ;
       ELSIF  formula_detail_tab(loop_index).scale_type = 2 THEN
          l_scale_type := 5 ;
       ELSE
         /* scale type of other than 0,1,2 is not supported */
         l_scale_type := formula_detail_tab(loop_index).scale_type ;
       END IF ;
    END IF ;           /* IF contribute_yield_ind */
	-- Now get the offsets
	-- -------------------------------
	IF g_curr_rstep_loc > 0  AND
	(formula_detail_tab(loop_index).release_type between 1 AND 3)
	THEN
	 l_offset_loc := get_offsets( effectivity.formula_id,
				effectivity.plant_code,
		formula_detail_tab(loop_index).x_formulaline_id ) ;
	 IF l_offset_loc < 0 THEN
          IF formula_detail_tab(loop_index).line_type < 0 THEN
                l_offset := 0 ;
          ELSE
                l_offset := 100 ;
          END IF ;
	 ELSE
          IF formula_detail_tab(loop_index).line_type < 0 THEN
                l_offset := rstep_offsets(l_offset_loc).start_offset ;
          ELSE
                l_offset := rstep_offsets(l_offset_loc).end_offset ;
          END IF ;

	 END IF ;
	ELSE
	  IF formula_detail_tab(loop_index).line_type < 0 THEN
		l_offset := 0 ;
	  ELSE
		l_offset := 100 ;
	  END IF ;
	END IF ;
	-- -----------------------------------

   /* B3267522, Rajesh Patangya Do not insert ingredients, if ingredient is same
      as product (single level circular reference) */

    IF (effectivity.aps_item_id = formula_detail_tab(loop_index).aps_item_id) AND
      (formula_detail_tab(loop_index).line_type = -1)  THEN
      NULL ;
    ELSE
         /* BOM Component Bulk Insert assignments */
         bomc_index := bomc_index + 1 ;

         /*Sowmya - Item substitution - start*/
         IF formula_detail_tab(loop_index).x_formulaline_id IS NOT NULL THEN
                bomc_component_sequence_id(bomc_index) := formula_detail_tab(loop_index).x_formulaline_id ;
         ELSE
                gmd_formline_cnt := gmd_formline_cnt + 1;
                bomc_component_sequence_id(bomc_index) := (( v_gmd_formula_lineid + gmd_formline_cnt ) * 2) + 1;
                /*For sustitutes the formula line id will be null. component sequence id in
                msc_st_bom_components is a primary key. So the max value from gmd formula line sequence
                is fetched and global counter value is added to it.Then odd value is passed on to APS. */
         END IF;
         /*Sowmya - Item substitution - End*/

         bomc_sr_instance_id(bomc_index)   := b_instance_id ;
         bomc_organization_id(bomc_index)  := effectivity.organization_id ;
         bomc_Inventory_item_id(bomc_index) := formula_detail_tab(loop_index).aps_item_id ;
         -- RDP B2445746, replace component aps_item_id to product aps_item_id
         bomc_using_assembly_id(bomc_index) := effectivity.aps_item_id ;
         bomc_bill_sequence_id(bomc_index) := p_x_aps_fmeff_id ;
         bomc_component_type(bomc_index) := l_line_type ;
         bomc_scaling_type(bomc_index) := l_scale_type; /* Scailing type for APS */
         bomc_uom_code(bomc_index) := formula_detail_tab(loop_index).aps_um ;
         bomc_usage_quantity(bomc_index) :=  p_primary_qty ;
         bomc_contribute_to_step_qty(bomc_index) := formula_detail_tab(loop_index).contribute_step_qty_ind;
	-- Rounding off the start date  /* Bug: 5872693 Vpedarla Starts */
	 IF formula_detail_tab(loop_index).start_date IS NULL  THEN
           bomc_effectivity_date(bomc_index) := trunc(current_date_time) ;
	 ELSE
	  bomc_effectivity_date(bomc_index) := trunc(formula_detail_tab(loop_index).start_date) ;
	 END IF ;
	 -- Rounding off the end date
	 IF formula_detail_tab(loop_index).end_date IS NULL  THEN
           bomc_disable_date(bomc_index) := null_value ;
	 ELSE
	  bomc_disable_date(bomc_index) := trunc(formula_detail_tab(loop_index).end_date) ;
	 END IF ;
          /* Bug: 5872693 Vpedarla Ends */
           -- bomc_from_unit_number := null_value,
           -- bomc_to_unit_number := null_value,
           -- bomc_use_up_code := null_value,
           -- bomc_suggested_effectivity_date := null_value,
           -- bomc_driving_item_id := null_value,
         IF l_offset IS NOT NULL THEN
           bomc_opr_offset_percent(bomc_index) := l_offset; /* offset percentage */
         ELSE
           bomc_opr_offset_percent(bomc_index) := null_value ;
         END IF;

         bomc_optional_component(bomc_index) := 2 ;
           -- bomc_old_effectivity_date := null_value,
         bomc_wip_supply_type(bomc_index) := formula_detail_tab(loop_index).phantom_type ;
         bomc_last_update_date(bomc_index) := current_date_time ;
         bomc_creation_date(bomc_index)    := current_date_time ;
         /* B2657068 Rajesh Patangya */
         IF  formula_detail_tab(loop_index).scale_multiple IS NOT NULL THEN
           bomc_scale_multiple(bomc_index) := formula_detail_tab(loop_index).scale_multiple ;
         ELSE
           bomc_scale_multiple(bomc_index) := null_value;
         END IF;
         IF formula_detail_tab(loop_index).scale_rounding_variance IS NOT NULL THEN
           bomc_scale_rounding_variance(bomc_index) :=
                     formula_detail_tab(loop_index).scale_rounding_variance ;
         ELSE
           bomc_scale_rounding_variance(bomc_index) := null_value;
         END IF;
         IF formula_detail_tab(loop_index).rounding_direction IS NOT NULL THEN
           bomc_rounding_direction(bomc_index) := formula_detail_tab(loop_index).rounding_direction ;
         ELSE
           bomc_rounding_direction(bomc_index) := null_value ;
         END IF;

    END IF;   /* Circular reference */

   END IF;

  END LOOP;
  return_status := TRUE;

  EXCEPTION
    WHEN OTHERS THEN
	log_message('Error writing to msc_st_bom_components: '||sqlerrm);
	return_status := FALSE;
END write_bom_components;

/*
REM+=========================================================================+
REM| PROCEDURE NAME                                                          |
REM|    write_routing                                                        |
REM|                                                                         |
REM| TYPE                                                                    |
REM|    Private                                                              |
REM|                                                                         |
REM| USAGE                                                                   |
REM|    This procedure creates a routing in msc_routings                     |
REM|                                                                         |
REM| DESCRIPTION                                                             |
REM|                                                                         |
REM|                                                                         |
REM| INPUT PARAMETERS                                                        |
REM|    table_index      index into aps_effectivities structure for current  |
REM|                     effectivity.                                        |
REM|                                                                         |
REM| OUTPUT PARAMETERS                                                       |
REM|    return_status    TRUE => OK                                          |
REM|                                                                         |
REM| INPUT/OUTPUT PARAMETERS                                                 |
REM|    None                                                                 |
REM|                                                                         |
REM| HISTORY                                                                 |
REM|  07/14/2002   Rajesh Patangya - Reorgnized the complete code B2314052   |
REM|  08/27/2002   B2098058 Alternate_routing_designator is being passed     |
REM|               as the eff_id because 1. Alt_rtg_desgn is now required    |
REM|               per explanation in the bug 2.alt_rtg_desgn should be same |
REM|               alt_bom_desgn for the bom in the same eff 3.OPM has       |
REM|               has no way to determine primary bom/rtg from alternate    |
REM|                                                                         |
REM+=========================================================================+
*/
PROCEDURE write_routing
(
  p_x_aps_fmeff_id   IN NUMBER,
  return_status      OUT NOCOPY BOOLEAN
)
IS
  p_routing_details  VARCHAR2(128) ;
  v_routing_qty      NUMBER ;
BEGIN
  p_routing_details  := NULL;
  v_routing_qty      := 0;
  IF effectivity.rtg_hdr_location > 0 AND effectivity.product_index > 0 THEN

    p_routing_details := effectivity.routing_no ||delimiter||
                         to_char(effectivity.routing_vers) ||delimiter||
                         effectivity.routing_desc ;

    /*B2870041 The routing qty needs to be represented as the product of the
       effectivity so APS can scale the route correctly. If the product has
       fixed scaling then the route will need to use the full product qty
       as the route will not get scaled according to total output in APS.
       Otherwise the quantity will be the product qty scaled to match
       the total output if represented as the routing qty*/
    IF formula_detail_tab(effectivity.product_index).scale_type = 0 THEN
      v_routing_qty :=
        formula_detail_tab(effectivity.product_index).primary_qty;
    ELSE
      v_routing_qty := (effectivity.routing_qty /
        formula_header_tab(g_fm_hdr_loc).total_output) *
        formula_detail_tab(effectivity.product_index).primary_qty;
    END IF;

    /* B2870041 report the uom as the primary uom of the product in the discrete
      form. The quantity is the scaled version of the product to match the
      routing qty as explained previously */

          /* Routing Bulk insert assignments */
            rtg_index := rtg_index + 1 ;
            rtg_routing_sequence_id(rtg_index) := p_x_aps_fmeff_id ;
            rtg_sr_instance_id(rtg_index) := b_instance_id ;
              -- rtg_routing_type(rtg_index) := 1 ;
            rtg_routing_comment(rtg_index) := p_routing_details ;
            rtg_alt_routing_designator(rtg_index) := p_x_aps_fmeff_id ; /* B2098058 */
              -- project_id :=  null_value ;
              -- task_id :=  null_value ;
              -- line_id :=  null_value ;
            /*B2870041*/
            rtg_uom_code(rtg_index) := formula_detail_tab(effectivity.product_index).aps_um ;
              -- cfm_routing_flag := null_value ;
              -- ctp_flag := null_value ;
            /*B2870041*/
            rtg_routing_quantity(rtg_index) := v_routing_qty ;
            rtg_assembly_item_id(rtg_index) := effectivity.aps_item_id ;
            rtg_organization_id(rtg_index) := effectivity.organization_id ;
/* NAMIT_CR Calculate Step Quantities */
            rtg_auto_step_qty_flag(rtg_index) := effectivity.calculate_step_quantity ;

              -- deleted_flag  = 2 ;
            rtg_last_update_date(rtg_index) := current_date_time ;
            rtg_creation_date(rtg_index) := current_date_time ;

    return_status := TRUE;
  ELSE
    return_status := FALSE;
  END IF ;

/* NAMIT_CR Write Step Dependency Data. */
  write_step_dependency(p_x_aps_fmeff_id);

  EXCEPTION
    WHEN OTHERS THEN
	log_message('Error writing to msc_st_routings: '||sqlerrm);
	return_status := FALSE;
END write_routing;

/*
REM+=========================================================================+
REM| PROCEDURE NAME                                                          |
REM|    write_routing_operations                                             |
REM|                                                                         |
REM| TYPE                                                                    |
REM|    Private                                                              |
REM|                                                                         |
REM| DESCRIPTION                                                             |
REM|    This procedure writes operation/resource/activity details to the MSC |
REM|    tables and also caters for alternate resources.                      |
REM|                                                                         |
REM| INPUT PARAMETERS                                                        |
REM|    table_index: index of APS effectivity in aps_effectivities           |
REM|                                                                         |
REM| OUTPUT PARAMETERS                                                       |
REM|    return_status  TRUE=> OK                                             |
REM|                                                                         |
REM| INPUT/OUTPUT PARAMETERS                                                 |
REM|    None                                                                 |
REM|                                                                         |
REM| HISTORY                                                                 |
REM|  07/14/2002   Rajesh Patangya - Reorgnized the complete code B2314052   |
REM|  12/12/2002   Abhay Satpute   - Resource Load Changes Bug# 2710139      |
REM|  01/22/2003   Rajesh Patangya - Resource Unit = resource_count B2761278 |
REM|  05/23/2003   Sridhar Gidugu  - Populating Activity Group Id using      |
REM|                                 Resource Id bug#2975261                 |
REM+=========================================================================+
*/
PROCEDURE write_routing_operations
(
  p_x_aps_fmeff_id   IN NUMBER,
  return_status      OUT NOCOPY BOOLEAN
)
IS

  start_index          INTEGER;
  end_index            INTEGER;
  loop_index           INTEGER;
  k                    INTEGER ;
  alt_cnt              INTEGER ;
  previous_id          NUMBER     ;
  previous_activity    NUMBER ;
  seq_no               INTEGER ;
  statement_no         INTEGER ;
  v_counter            INTEGER ;
  alternates_inserted  VARCHAR2(1);
  v_alternate          NUMBER ;
  t_scale_type         NUMBER ;

  f_step_qty             NUMBER ;
  f_resource_usage       NUMBER ;
  f_activity_factor      NUMBER ;
  f_process_qty          NUMBER ;
  f_min_capacity         NUMBER ;
  f_max_capacity         NUMBER ;

  calculated_resource_usage NUMBER ;

  prod_scale_factor      NUMBER ; /*B2870041 contains factor to scale usage */
  l_prod_scale_factor    NUMBER ;
  temp_min_xfer_qty      NUMBER ; /*B2870041*/

   l_seq_dep_class     VARCHAR2(8);
   orig_rs_seq_num     NUMBER ;
   u_setup_id          NUMBER ;

   oprn_found 		BOOLEAN ;
BEGIN
  k                    := 0;
  alt_cnt              := 0;
  previous_id          := 0;
  previous_activity    := -1;
  seq_no               := 1;
  statement_no         := 0;
  v_counter            := 0;
  alternates_inserted   := 'N';
  v_alternate          := 0;
  t_scale_type         := -1;
  f_step_qty             := 0;
  f_resource_usage       := 0;
  f_activity_factor      := 0;
  f_process_qty          := 0;
  f_min_capacity         := 0;
  f_max_capacity         := 999999;
  calculated_resource_usage := 0;
  prod_scale_factor      := 1;
  l_prod_scale_factor    := 1;
  temp_min_xfer_qty      := 0;
   orig_rs_seq_num      := 0;
   oprn_found 		:= FALSE ;


  statement_no := 0 ;

  start_index := rtg_org_hdr_tab(effectivity.rtg_hdr_location).orgn_start_loc ;
  end_index :=  rtg_org_hdr_tab(effectivity.rtg_hdr_location).orgn_end_loc ;

--
  /*B2870041 If the product has fixed scaling the route will need to be scaled
     to match the total output not the product. If the product is linear
     then the route can be scaled in APS. The routing qty in the route header
     was modified to match the original routing qty. The product qty
      was scaled to match that value, thus the factor will always be 1 */

  statement_no := 10 ;
  /* B3145206, No matter what scale type it is, factor needs to be calculated */
    l_prod_scale_factor := formula_header_tab(g_fm_hdr_loc).total_output/
        effectivity.routing_qty;
  IF formula_detail_tab(effectivity.product_index).scale_type = 0 THEN
 	prod_scale_factor := l_prod_scale_factor ;
  ELSE
    	prod_scale_factor := 1;
  END IF;

  IF (start_index > 0) AND (end_index > 0) THEN

  FOR loop_index IN start_index..end_index
  LOOP
  /* Write only non Do Not Plan rows and rows in which usage UOM
  and GMP UOM for Hours profile have Time as base UOM class. */
  IF (rtg_org_dtl_tab(loop_index).include_rtg_row = 1) THEN
    t_scale_type  := rtg_org_dtl_tab(loop_index).rtg_scale_type ;

    -- Routing Step insertion
    IF rtg_org_dtl_tab(loop_index).routingstep_id <> previous_id THEN

-- Note that this code differs from R12 code -
     IF  rtg_org_dtl_tab(loop_index).step_qty = 0 THEN
       temp_min_xfer_qty := 0 ;
     ELSE
    -- in R12 the code
    -- temp_min_xfer_qty :=  rtg_org_dtl_tab(loop_index).minimum_transfer_qty ;
     temp_min_xfer_qty := (effectivity.routing_qty *
       formula_detail_tab(effectivity.product_index).primary_qty *
       rtg_org_dtl_tab(loop_index).minimum_transfer_qty) /
       (formula_header_tab(g_fm_hdr_loc).total_output *
        rtg_org_dtl_tab(loop_index).step_qty);
     END IF;

     /*B2870041 the mtq quantity needs to be represented as a value based on the
        product not the step qty. Since a formula can have multiple products
        in different effectivities the calculation will use the relationhip
        of the mtq based on the step qty as applied to the product */


  statement_no := 20 ;
    -- Routing Step Bulk insert assignments
       opr_index := opr_index + 1 ;
       opr_operation_sequence_id(opr_index) :=
                                      rtg_org_dtl_tab(loop_index).x_routingstep_id ;
       opr_routing_sequence_id(opr_index) := p_x_aps_fmeff_id ;
       opr_operation_seq_num(opr_index) := rtg_org_dtl_tab(loop_index).routingstep_no ;
       opr_sr_instance_id(opr_index) := b_instance_id ;
       opr_operation_description(opr_index) := rtg_org_dtl_tab(loop_index).oprn_desc ;
       opr_effectivity_date(opr_index) := current_date_time ;
         -- disable_date,from_unit_number, to_unit_number, := null ;
         -- option_dependent_flag := 1,
         -- operation_type := null_value ;
       opr_mtransfer_quantity(opr_index) := temp_min_xfer_qty;   /*B2870041*/

       /* NAMIT_ASQC
       l_prod_scale_factor is Scale factor based on fm total output qty and rtg qty.
       (l_prod_scale_factor = formula_header_tab.total_output/effectivity.routing_qty)
       Also added the Step Qty UOM. Discrete UOM is obtained from Sy_UOM_Mst */
--       opr_step_qty(opr_index) := l_prod_scale_factor * rtg_org_dtl_tab(loop_index).step_qty;

      /* Step Qty calculated In correctly */
       opr_step_qty(opr_index) := prod_scale_factor * rtg_org_dtl_tab(loop_index).step_qty;

       opr_step_qty_uom(opr_index) := rtg_org_dtl_tab(loop_index).process_qty_um;
         -- yield := null_value ; /*  B2365684 rtg_org_dtl_tab(loop_index).step_qty, */

       opr_department_id(opr_index) := (effectivity.organization_id * 2) + 1 ;
       opr_organization_id(opr_index) := effectivity.organization_id  ;
       opr_department_code(opr_index) := effectivity.whse_code ;
         --  operation_lead_time_percent,cumulative_yield, := null ;
         -- reverse_cumulative_yield,net_planning_percent, := null;
         -- setup_duration,tear_down_duration, := null ;
       /*B2870041*/
       opr_uom_code(opr_index) := formula_detail_tab(effectivity.product_index).aps_um ;
         -- standard_operation_code := null_value,
       opr_last_update_date(opr_index) := current_date_time ;
       opr_creation_date(opr_index) := current_date_time ;

     previous_id := rtg_org_dtl_tab(loop_index).routingstep_id;
     previous_activity := -1;
     seq_no := 0;
    END IF;   /* routing Step Insertion */

    --  Activity Insertion
  statement_no := 30 ;
    IF rtg_org_dtl_tab(loop_index).oprn_line_id <> previous_activity THEN

       seq_no := seq_no + 1;

     /*B2870041 modified the population of schedule_flag. The value of this will
        come from the plsql table and not hardcoded to 1. The value was set
        in the proceesing for the routing details */

     /* B2975261 - Populating activity group id using resource id */

     /* Operation resource seqs Bulk Insert assignments */
       rs_index := rs_index + 1 ;
       rs_operation_sequence_id(rs_index) := rtg_org_dtl_tab(loop_index).x_routingstep_id ;
--       rs_resource_seq_num(rs_index) := seq_no ;
       /* B3596028 */
       rs_resource_seq_num(rs_index) := rtg_org_dtl_tab(loop_index).seq_dep_ind ;
       rs_sr_instance_id(rs_index)   := b_instance_id ;
       rs_department_id(rs_index)    := (effectivity.organization_id * 2) + 1 ;
         -- rs_resource_offset_percent := null_value ;
       /*B2870041 */
       rs_schedule_flag(rs_index)    := rtg_org_dtl_tab(loop_index).schedule_flag ;
       rs_routing_sequence_id(rs_index) := p_x_aps_fmeff_id ;
       rs_organization_id(rs_index)    := effectivity.organization_id ;
         -- deleted_flag := 2 ;
       rs_last_update_date(rs_index) := current_date_time ;
       rs_creation_date(rs_index) := current_date_time ;
       rs_activity_group_id(rs_index) := rtg_org_dtl_tab(loop_index).x_resource_id ;

      previous_activity := rtg_org_dtl_tab(loop_index).oprn_line_id;

    END IF;  /* End if for Activity Change */

    /*
    New Changes for Alternate Resources Begin : Bug# 1319610
    The following code depends on the ordering of prim_rsrc_ind, right
    now the Secondary Resources are Not considered, and the
    Primary_rsrc_indicator will have
              1 for Primary Resource
              2 for a Auxilary Resource.
              0 for a Secondary Resource.
              The Logic in brief goes like this :
              The Resources are inserted as usual and then a check is made
              to find if the resource is a Primary resource and if it has
              any alternates,
              the Alternate Resources are inserted. Then the groups secondaries
              are inserted.
     Insert the Resources : Bug# 1319610
     mfc 12-01-99 changed scale type to 0>2 1>1
     */

      f_step_qty  := 0;
      f_activity_factor    := 0 ;
      f_process_qty        := 0 ;
      f_resource_usage     := 0 ;
/* NAMIT_OC */
      f_min_capacity       := 0 ;
      f_max_capacity       := 999999;

      -- Get process_qty,activity_factor override
      statement_no := 80 ;
      IF (rtg_org_dtl_tab(loop_index).o_step_qty  > 0) THEN
     /* B3145206, Note that the overriden qty is with respect to the total o/p
        and not with respect to just the product, let's have an example
        rtg_qty = 40 , step_qty = 40 , but when used
        in a formula having prod = 40 and by-prod = 40 , the recipe step_qty
        field will show 80 , if the user overrides it to be 40, then this new
        overriden qty 40 is wrt to total o/p of 80  */

         f_step_qty := rtg_org_dtl_tab(loop_index).o_step_qty / l_prod_scale_factor  ;
      ELSE
         f_step_qty := rtg_org_dtl_tab(loop_index).step_qty ;
      END IF;

      IF rtg_org_dtl_tab(loop_index).o_resource_usage > 0 THEN
         f_resource_usage := rtg_org_dtl_tab(loop_index).o_resource_usage ;
      ELSE
         f_resource_usage := rtg_org_dtl_tab(loop_index).resource_usage ;
      END IF ;

      IF (rtg_org_dtl_tab(loop_index).o_activity_factor > 0) THEN
         f_activity_factor := rtg_org_dtl_tab(loop_index).o_activity_factor;
      ELSE
         f_activity_factor := rtg_org_dtl_tab(loop_index).activity_factor;
      END IF ;

      IF (rtg_org_dtl_tab(loop_index).o_process_qty > 0) THEN
         f_process_qty := rtg_org_dtl_tab(loop_index).o_process_qty;
      ELSE
         f_process_qty := rtg_org_dtl_tab(loop_index).process_qty;
      END IF ;

/* NAMIT_OC */

      IF (rtg_org_dtl_tab(loop_index).o_min_capacity > 0) THEN
         f_min_capacity := rtg_org_dtl_tab(loop_index).o_min_capacity ;
      ELSE
         f_min_capacity := rtg_org_dtl_tab(loop_index).min_capacity ;
      END IF ;

      IF (rtg_org_dtl_tab(loop_index).o_max_capacity > 0) THEN
         f_max_capacity := rtg_org_dtl_tab(loop_index).o_max_capacity ;
      ELSE
         f_max_capacity := rtg_org_dtl_tab(loop_index).max_capacity ;
      END IF ;

         --  SPECIAL !!! process_qty ZERO than take final step_qty */
         IF f_process_qty = 0 THEN
            f_process_qty := f_step_qty;
         END IF ;

  statement_no := 90 ;

  /* NAMIT_OC If the resource is scaled as fixed or By Charge, the resource
  usage will be treated as if it were fixed. If the scale type of the resource
  is "By Charge" then  the usage defined is that of the charge and will not need
  to be scaled in any way, except of course by the number of charges. */

      IF ((rtg_org_dtl_tab(loop_index).scale_type = 0) OR
          (rtg_org_dtl_tab(loop_index).scale_type = 2)) THEN
         -- fixed scaling
         calculated_resource_usage := ((f_resource_usage * f_activity_factor));
      ELSE
         /*B2870041 the scale factor was added to ensure the usages match
            what is represented by the product in the routing qty */

         calculated_resource_usage := ((f_step_qty / f_process_qty) *
           (f_resource_usage * f_activity_factor) * prod_scale_factor ) ;
      END IF; /* fixed scaling */

  statement_no := 100 ;
     /* Bulk insert assignments for operation_resources */
	/* OR insert # 1 */
      orig_rs_seq_num := orig_rs_seq_num + 1;
      or_index := or_index + 1 ;

      or_operation_sequence_id(or_index) :=
                       rtg_org_dtl_tab(loop_index).x_routingstep_id ;
--      or_resource_seq_num(or_index) := seq_no ; /* B3596028 */
      or_resource_seq_num(or_index) := rtg_org_dtl_tab(loop_index).seq_dep_ind ;
      or_resource_id(or_index) := rtg_org_dtl_tab(loop_index).x_resource_id ;
      or_alternate_number(or_index) := 0 ;
      /* For Primary Rsrc Principal flag = 1, for Aux and Sec Rsrcs Principal Flag = 2*/
      IF (rtg_org_dtl_tab(loop_index).prim_rsrc_ind = 1) THEN
         or_principal_flag(or_index) := rtg_org_dtl_tab(loop_index).prim_rsrc_ind ;
      ELSE
         or_principal_flag(or_index) := 2 ;
      END IF;
      or_basis_type(or_index) := t_scale_type ;
      or_resource_usage(or_index) := ( calculated_resource_usage
                   * rtg_org_dtl_tab(loop_index).resource_count ) ;
      or_max_resource_units(or_index) := rtg_org_dtl_tab(loop_index).resource_count ;
      or_resource_units(or_index) := rtg_org_dtl_tab(loop_index).resource_count ;
      or_uom_code(or_index) := rtg_org_dtl_tab(loop_index).aps_usage_um ;
      or_sr_instance_id(or_index) := b_instance_id ;
      or_routing_sequence_id(or_index) := p_x_aps_fmeff_id ;
      or_organization_id(or_index) := effectivity.organization_id ;
      or_minimum_capacity(or_index) := nvl(f_min_capacity,0) ;
      or_maximum_capacity(or_index) := nvl(f_max_capacity,9999999) ;
      or_last_update_date(or_index) := current_date_time ;
      or_creation_date(or_index) := current_date_time ;
      or_orig_rs_seq_num(or_index) := orig_rs_seq_num;
      or_break_ind(or_index) := rtg_org_dtl_tab(loop_index).break_ind;
--
   statement_no := 110 ;
-- ---------------------------------------------
     u_setup_id   := NULL ;
     or_setup_id(or_index) := null_value ;
     IF (rtg_org_dtl_tab(loop_index).is_sds_rout >= 1) THEN
       IF (rtg_org_dtl_tab(loop_index).is_unique = 1) THEN
           or_setup_id(or_index) := rtg_org_dtl_tab(loop_index).setup_id ;
       ELSE
          IF (rtg_org_dtl_tab(loop_index).is_nonunique = 1) THEN
           -- If the resource is not unique then it should get the setup_id of
           -- unique resource present anywhere in a route
             bsearch_unique(rtg_org_dtl_tab(loop_index).resource_id,
                            effectivity.category_id,
                            u_setup_id);
            or_setup_id(or_index) := u_setup_id ;
            rtg_org_dtl_tab(loop_index).setup_id := u_setup_id;
          ELSE
            -- It is niether unique nor nonunique
            or_setup_id(or_index)  := null_value;
            rtg_org_dtl_tab(loop_index).setup_id := null_value;
          END IF;

       END IF; /* is_unique */

     END IF; /* Is sds route */

     IF rtg_org_dtl_tab(loop_index).prim_rsrc_ind = 1 THEN
       -- This assignment will ensure that , alternate will use this setup
       rtg_org_dtl_tab(loop_index).setup_id := or_setup_id(or_index) ;
     END IF;

-- ---------------------------------------------
       /*
        Now the check if the above resource inserted is a Primary. If it is
        Primary then find its Alternates if existing, and then insert its rows
        into msc_st_operation_resources table. Also keep track of number of
        times alternates are inserted. 1319610
       */

  statement_no := 120 ;
        IF rtg_org_dtl_tab(loop_index).prim_rsrc_ind = 1 THEN

          --  Reset the Counters and the Flags
           v_counter := 0;
           alternates_inserted := 'N';
           v_alternate  := 0;
           k  := 0;

        --  Open the Alternate resource Cursor, for the above Primary Resource
 	/* we shall have to put a new BSEARCH function if this looping become
		a performance problem */
        alt_cnt := 1 ;
        FOR alt_cnt IN 1..alt_rsrc_size
        LOOP
-- 	    Prod Spec alternates
--	    IF ( rtg_alt_rsrc_tab(alt_cnt).prim_resource_id =
--                      rtg_org_dtl_tab(loop_index).resource_id ) THEN
	    IF ( rtg_alt_rsrc_tab(alt_cnt).prim_resource_id =
                      rtg_org_dtl_tab(loop_index).resource_id
		AND (rtg_alt_rsrc_tab(alt_cnt).item_id = -1 OR
		     rtg_alt_rsrc_tab(alt_cnt).item_id = effectivity.item_id)) THEN
             orig_rs_seq_num := orig_rs_seq_num + 1;
            /* B2353759, alternate runtime_factor considered */
               v_alternate := v_alternate + 1;

            /* Bulk insert assignments for operation_resources, Alternate resources */
		/* OR insert # 2 */
             or_index := or_index + 1 ;
             or_operation_sequence_id(or_index) :=
                        rtg_org_dtl_tab(loop_index).x_routingstep_id ;
--             or_resource_seq_num(or_index) := seq_no ;
             /* B3596028 */
             or_resource_seq_num(or_index) := rtg_org_dtl_tab(loop_index).seq_dep_ind ;
             or_resource_id(or_index) :=
                  ((rtg_alt_rsrc_tab(alt_cnt).alt_resource_id * 2) + 1) ;

--	Prod spec alternates
      /* B5688153 Rajesh Patangya
      We are removing the preference logic for primary resource and will continue
      to use the old logic of numbering the primary resources in sequence as per the
      order by clause used by alternate resource cursor.
      */
             or_alternate_number(or_index) := v_alternate ;

             or_principal_flag(or_index) := 1;  /* Taking Principal flag as 1 for Alternates */
             or_basis_type(or_index) := t_scale_type ;
             or_resource_usage(or_index) := ( calculated_resource_usage
                          * rtg_org_dtl_tab(loop_index).resource_count
                          * rtg_alt_rsrc_tab(alt_cnt).runtime_factor ) ;
             or_max_resource_units(or_index) := rtg_org_dtl_tab(loop_index).resource_count ;
             /* B2761278 */
             or_resource_units(or_index) := rtg_org_dtl_tab(loop_index).resource_count ;
             or_uom_code(or_index) := rtg_org_dtl_tab(loop_index).aps_usage_um ;
               -- or_deleted_flag(or_index) := 2 ;
             or_sr_instance_id(or_index) := b_instance_id ;
             or_routing_sequence_id(or_index) := p_x_aps_fmeff_id ;
             or_organization_id(or_index) := effectivity.organization_id ;
             /* SGIDUGU added min capacity and max capacity inserts */
             or_minimum_capacity(or_index) :=
                       nvl(rtg_alt_rsrc_tab(alt_cnt).min_capacity,0) ;
             or_maximum_capacity(or_index) :=
                       nvl(rtg_alt_rsrc_tab(alt_cnt).max_capacity,999999) ;

             or_orig_rs_seq_num(or_index) := orig_rs_seq_num;
             or_break_ind(or_index) := rtg_org_dtl_tab(loop_index).break_ind;
-- ----------------------------------------------------
               statement_no := 125 ;
               IF  rtg_org_dtl_tab(loop_index).setup_id IS NOT NULL THEN
                 or_setup_id(or_index) := rtg_org_dtl_tab(loop_index).setup_id ;
               ELSE
                 or_setup_id(or_index) := null_value ;
               END IF;

-- ----------------------------------------------------
             or_last_update_date(or_index) := current_date_time ;
               -- or_last_updated_by(or_index) := 0 ;
             or_creation_date(or_index) := current_date_time ;
               -- or_created_by(or_index) := 0 ;

               /* Increment counter to check the number of times the
                  alternates are inserted */

               alternates_inserted := 'Y'; /* Inserted alternates */

	    ELSIF ( rtg_alt_rsrc_tab(alt_cnt).prim_resource_id >
                      rtg_org_dtl_tab(loop_index).resource_id ) THEN
               EXIT ;
            ELSE
               NULL ;
            END IF;  /* End if for alternate resource and orgn code match */
	END LOOP;  /* Alternate loop */

        END IF;  /* End if for Check in Primary Resource Indicator */

      /*
      Now check if the resource is a Auxilary resource and if the
      alternates are inserted, if both the conditions are satisfied,
      then loop thru the number of times the alternate resources are inserted
      and insert the Auxilary resources.
      This will take care of the combinations that has to come with the
      alternate resources. 1319610
      08/10/00 - Bug# 1388757 Changed != to <> as per the Standards
      */

  statement_no := 130 ;
     IF ( rtg_org_dtl_tab(loop_index).prim_rsrc_ind <> 1) AND
        (alternates_inserted = 'Y')
     THEN
         for k in 1 ..v_alternate
         LOOP

            /* Bulk insert assignments operation_resources, Alternate resources */
		/* OR insert # 3 */
             or_index := or_index + 1 ;

             or_operation_sequence_id(or_index) := rtg_org_dtl_tab(loop_index).x_routingstep_id ;
--             or_resource_seq_num(or_index) := seq_no ;
            /* B3596028 */
             or_resource_seq_num(or_index) := rtg_org_dtl_tab(loop_index).seq_dep_ind ;
             or_resource_id(or_index) := rtg_org_dtl_tab(loop_index).x_resource_id ;
             or_alternate_number(or_index) := k ;
            /* K will determine the no. of times altenates are used */
             or_principal_flag(or_index) := 2 ;
            /* Principal flag as 2 for Secondary Resources */
             or_basis_type(or_index) := t_scale_type ;
             or_resource_usage(or_index) := ( calculated_resource_usage
                    * rtg_org_dtl_tab(loop_index).resource_count ) ;

             or_max_resource_units(or_index) := rtg_org_dtl_tab(loop_index).resource_count ;
             /* B2761278 */
             or_resource_units(or_index) := rtg_org_dtl_tab(loop_index).resource_count ;
             or_uom_code(or_index) := rtg_org_dtl_tab(loop_index).aps_usage_um ;
               -- or_deleted_flag(or_index) := 2 ;
             or_sr_instance_id(or_index) := b_instance_id ;
             or_routing_sequence_id(or_index) := p_x_aps_fmeff_id ;
             or_organization_id(or_index) := effectivity.organization_id ;
             /* SGIDUGU - Added min capacity and max capacity inserts */
             or_minimum_capacity(or_index) := nvl(f_min_capacity,0) ;
             or_maximum_capacity(or_index) := nvl(f_max_capacity,9999999) ;
             or_break_ind(or_index) := rtg_org_dtl_tab(loop_index).break_ind;
             or_setup_id(or_index) := null_value ;
             or_last_update_date(or_index) := current_date_time ;
               -- or_last_updated_by(or_index) := 0 ;
             or_creation_date(or_index) := current_date_time ;
               -- or_created_by(or_index) := 0 ;
             or_orig_rs_seq_num(or_index) := orig_rs_seq_num;

         END LOOP; /* End loop of the v_counter */
     END IF;  /* End if condition for the secondary resource flag */

  END IF; /* End if condition for include rtg row check */
         -- To nullify the override effect for next recipe to use
         rtg_org_dtl_tab(loop_index).o_step_qty := -1 ;
         rtg_org_dtl_tab(loop_index).o_process_qty := -1 ;
         rtg_org_dtl_tab(loop_index).o_activity_factor := -1 ;
         rtg_org_dtl_tab(loop_index).o_resource_usage := -1 ;
         rtg_org_dtl_tab(loop_index).o_max_capacity   := -1 ;
         rtg_org_dtl_tab(loop_index).o_min_capacity   := -1 ;
/*
     log_message (
     rtg_org_hdr_tab(effectivity.rtg_hdr_location).valid_flag || ' ***' ||
     rtg_org_dtl_tab(loop_index).routing_id ||'*'||
     effectivity.recipe_id ||'*'||
     rtg_org_dtl_tab(loop_index).routingstep_id         ||' Us '||
     rtg_org_dtl_tab(loop_index).resource_usage      ||' *'||
     rtg_org_dtl_tab(loop_index).o_resource_usage      ||' AF '||
     rtg_org_dtl_tab(loop_index).activity_factor      ||' *'||
     rtg_org_dtl_tab(loop_index).o_activity_factor      ||' SQ '||
     rtg_org_dtl_tab(loop_index).step_qty      ||' *'||
     rtg_org_dtl_tab(loop_index).o_step_qty     ||' PQ '||
     rtg_org_dtl_tab(loop_index).process_qty      ||' *'||
     rtg_org_dtl_tab(loop_index).o_process_qty      ||' M '||
     rtg_org_dtl_tab(loop_index).min_capacity   ||' *'||
     rtg_org_dtl_tab(loop_index).o_min_capacity   ||' X '||
     rtg_org_dtl_tab(loop_index).max_capacity   ||' *'||
     rtg_org_dtl_tab(loop_index).o_max_capacity);
*/
  END LOOP;  /* End loop of the Main */
  END IF ;  /* Positive counter value check */

  statement_no := 140 ;
  return_status := TRUE;

  EXCEPTION
  WHEN OTHERS THEN
	log_message('Write routing operations failed at statement '
                     ||to_char(statement_no)||': '||sqlerrm);
	return_status := FALSE;

END write_routing_operations;

/*
REM+=========================================================================+
REM| PROCEDURE NAME                                                          |
REM|    write_operation_componenets                                          |
REM|                                                                         |
REM| TYPE                                                                    |
REM|    Private                                                              |
REM|                                                                         |
REM| DESCRIPTION                                                             |
REM|     Writes routing/material associations to the MSC tables              |
REM|                                                                         |
REM| INPUT PARAMETERS                                                        |
REM|    table_index: index of APS effectivity in aps_effectivities           |
REM|                                                                         |
REM| OUTPUT PARAMETERS                                                       |
REM|    return_status  TRUE=> OK                                             |
REM|                                                                         |
REM| INPUT/OUTPUT PARAMETERS                                                 |
REM|    None                                                                 |
REM|                                                                         |
REM| HISTORY                                                                 |
REM|  07/14/2002   Rajesh Patangya - Reorgnized the complete code B2314052   |
REM+=========================================================================+
*/
PROCEDURE write_operation_components
(
  p_x_aps_fmeff_id   IN  NUMBER,
  precipe_id         IN  NUMBER,
  return_status      OUT NOCOPY BOOLEAN
)
IS

  st_mst_operation_components VARCHAR2(4000) ;
  i    INTEGER ;
  record_written BOOLEAN ;    /* B3562488 */
  already_done INTEGER ;          /* 3562488  */
  found_product                 BOOLEAN ;
  write_row                     BOOLEAN ;

BEGIN
  st_mst_operation_components := NULL ;
  i    				:= 1;
  record_written 		:= FALSE ;
  already_done 		:= 0 ;
  stmt_no 		:= 0;

   found_product        := FALSE;
   write_row            := TRUE;

  -- write routing/material associations to msc_operation_components
--         log_message('Enter --- > ' || g_mat_assoc
--          || ' Effec ' || effectivity.formula_id
--          || ' Material ' || mat_assoc_tab(g_mat_assoc).formula_id || ' Recipe ' || precipe_id ) ;

stmt_no := 0;
   FOR i in g_mat_assoc..material_assocs_size
   LOOP

     IF  effectivity.formula_id > mat_assoc_tab(i).formula_id THEN
--         log_message(i || ' --- ' ||
--          effectivity.formula_id || ' > ' || mat_assoc_tab(i).formula_id ) ;
          NULL ;   /* Keep on looping */

     ELSIF effectivity.formula_id < mat_assoc_tab(i).formula_id THEN
            /* B3562488 */
            IF record_written = TRUE THEN
               g_mat_assoc := already_done ;
            END IF ;

--           log_message('Exit ' || g_mat_assoc || ' ***'
--             || effectivity.formula_id || ' < ' || mat_assoc_tab(i).formula_id ) ;

           EXIT;
     ELSIF effectivity.formula_id = mat_assoc_tab(i).formula_id THEN
            /* B3562488 */
        IF record_written = FALSE THEN
           already_done := i ;
           record_written := TRUE ;
--         log_message('Written ' || already_done);
        END IF ;

stmt_no := 10;
        IF mat_assoc_tab(i).recipe_id = precipe_id  THEN
--       AND primary_bom_formulaline_id <> mat_assoc_tab(i).x_formulaline_id  THEN
-- /* Bug # 4879588*/
-- Backed this out as the new code already has a check for product_id

           /*  Do Not write material association
                      for the product line */

           IF mat_assoc_tab(i).item_id = effectivity.item_id THEN
	      IF NOT (found_product )THEN
	         found_product := TRUE ;
		 write_row := FALSE ;
	      ELSE
                 write_row := TRUE ;
              END IF ;
           ELSE
              write_row := TRUE ;
           END IF ;

           /*  operation components bulk insert */
           IF (write_row ) THEN
              oc_index := oc_index + 1 ;
              oc_operation_sequence_id(oc_index) := mat_assoc_tab(i).x_routingstep_id ;
              oc_component_sequence_id(oc_index) := mat_assoc_tab(i).x_formulaline_id  ;
              oc_sr_instance_id(oc_index) := b_instance_id ;
              oc_bill_sequence_id(oc_index) := p_x_aps_fmeff_id  ;
              oc_routing_sequence_id(oc_index) := p_x_aps_fmeff_id ;
              oc_organization_id(oc_index) := effectivity.organization_id ;
              -- deleted_flag := 2,
              oc_last_update_date(oc_index) := current_date_time ;
              oc_creation_date(oc_index) := current_date_time ;
           END IF;

stmt_no := 20;
/* NAMIT_MTQ */
           IF ((mat_assoc_tab(i).min_trans_qty IS NOT NULL) OR
                   (mat_assoc_tab(i).min_delay IS NOT NULL)) THEN

              IF (mat_assoc_tab(i).min_trans_qty IS NULL) THEN
                 mat_assoc_tab(i).min_trans_qty := 0;
              END IF;

              mtq_index := mtq_index + 1;

   /* nsinghi B3970993 Start */
   /* If either the org, recipe, formula, rtg, step or item changes; re-initialize
   the globals. Write this MTQ row, and let the g_min_mtq be the mtq qty from this
   row. Also store the index of mtq row in global variable.
   The first MTQ row for a item belonging to a step is always written. If the same
   item is defined in the same step, then the row having minimum MTQ will be written. */

   /*
   1) If the MTQ is defined as null in one row, but min and/or max delay
   is defined for that row. Another row for the same item in same step, if MTQ is
   not null, but min and/or max delay are null, then which row to transfer. The code
   will transfer the row that has null MTQ.
   2) If MTQ is defined for same item multiple times in same step, and if all the
   MTQ values are equal, then the first row where MTQ is found will be sent. */

              IF g_old_recipe_id <> mat_assoc_tab(i).recipe_id OR
                 g_old_formula_id <> mat_assoc_tab(i).formula_id OR
                 g_old_rtg_id <> p_x_aps_fmeff_id OR
                 g_old_rtgstep_id <> mat_assoc_tab(i).x_routingstep_id OR
                 g_old_aps_item_id <> mat_assoc_tab(i).aps_item_id
              THEN
                 g_old_recipe_id := mat_assoc_tab(i).recipe_id;
                 g_old_formula_id := mat_assoc_tab(i).formula_id;
                 g_old_rtg_id := p_x_aps_fmeff_id;
                 g_old_rtgstep_id := mat_assoc_tab(i).x_routingstep_id;
                 g_old_aps_item_id := mat_assoc_tab(i).aps_item_id;
                 g_mtq_loc := mtq_index;
                 g_min_mtq := mat_assoc_tab(i).min_trans_qty;

                 itm_mtq_from_op_seq_id(mtq_index) :=  mat_assoc_tab(i).x_routingstep_id;
                 itm_mtq_routing_sequence_id(mtq_index) := p_x_aps_fmeff_id ;
                 itm_mtq_sr_instance_id(mtq_index) := b_instance_id ;
                 itm_mtq_from_item_id(mtq_index) := mat_assoc_tab(i).aps_item_id ;
                 itm_mtq_organization_id(mtq_index) := effectivity.organization_id ;
                 itm_mtq_min_tran_qty(mtq_index) := mat_assoc_tab(i).min_trans_qty * mat_assoc_tab(i).uom_conv_factor;
                 itm_mtq_min_time_offset(mtq_index) := mat_assoc_tab(i).min_delay;
                 itm_mtq_max_time_offset(mtq_index) := mat_assoc_tab(i).max_delay;
                 itm_mtq_frm_op_seq_num(mtq_index) := mat_assoc_tab(i).routingstep_no;
              END IF;

     /* If an item is yielded in the same step multiple times and if MTQ value is associated
      to that item multiple times, then write row that has min MTQ. */

              IF g_old_recipe_id = mat_assoc_tab(i).recipe_id AND
                 g_old_formula_id = mat_assoc_tab(i).formula_id AND
                 g_old_rtg_id = p_x_aps_fmeff_id AND
                 g_old_rtgstep_id = mat_assoc_tab(i).x_routingstep_id AND
                 g_old_aps_item_id = mat_assoc_tab(i).aps_item_id AND
                 g_mtq_loc <> mtq_index
              THEN
                 log_message('Item : '||mat_assoc_tab(i).item_id||' in recipe : '||mat_assoc_tab(i).recipe_id
                 ||' is associated multiple times in step '||mat_assoc_tab(i).routingstep_no
                 ||' with MTQ/Min/Max Delay defined. Row with Minimum/Null MTQ will be considered. ');
                 IF mat_assoc_tab(i).min_trans_qty < g_min_mtq THEN
                    itm_mtq_from_op_seq_id(g_mtq_loc) :=  mat_assoc_tab(i).x_routingstep_id;
                    itm_mtq_routing_sequence_id(g_mtq_loc) := p_x_aps_fmeff_id ;
                    itm_mtq_sr_instance_id(g_mtq_loc) := b_instance_id ;
                    itm_mtq_from_item_id(g_mtq_loc) := mat_assoc_tab(i).aps_item_id ;
                    itm_mtq_organization_id(g_mtq_loc) := effectivity.organization_id ;
                    itm_mtq_min_tran_qty(g_mtq_loc) := mat_assoc_tab(i).min_trans_qty * mat_assoc_tab(i).uom_conv_factor;
                    itm_mtq_min_time_offset(g_mtq_loc) := mat_assoc_tab(i).min_delay;
                    itm_mtq_max_time_offset(g_mtq_loc) := mat_assoc_tab(i).max_delay;
                    itm_mtq_frm_op_seq_num(g_mtq_loc) := mat_assoc_tab(i).routingstep_no;
                 END IF;
                 mtq_index := mtq_index - 1;
              END IF;
        /* nsinghi B3970993 End */

           END IF;
stmt_no := 30;

--       log_message(i || ' - RCP - ' || p_x_aps_fmeff_id || ' ** ' || mat_assoc_tab(i).recipe_id ) ;

        END IF ;   /* Recipe check */

     END IF ;   /* formula check */
   END LOOP ;

  return_status := TRUE;

  EXCEPTION
  WHEN OTHERS THEN
	log_message('Error writing operation components: '||sqlerrm);
	return_status := FALSE;
END write_operation_components;

/*
REM+=========================================================================+
REM| PROCEDURE NAME                                                          |
REM|    export_effectivities                                                 |
REM|                                                                         |
REM| TYPE                                                                    |
REM|    Private                                                              |
REM|                                                                         |
REM| DESCRIPTION                                                             |
REM|    This procedure is called after all of the effectivities have been    |
REM|    validated and extracted. It exports the data gathered to APS using   |
REM|    the defined table mappings.                                          |
REM|                                                                         |
REM| INPUT PARAMETERS                                                        |
REM|    None                                                                 |
REM|                                                                         |
REM| OUTPUT PARAMETERS                                                       |
REM|    return_status    TRUE => OK                                          |
REM|                                                                         |
REM| INPUT/OUTPUT PARAMETERS                                                 |
REM|    None                                                                 |
REM|                                                                         |
REM| HISTORY                                                                 |
REM|  07/14/2002   Rajesh Patangya - Reorgnized the complete code B2314052   |
REM|  06/02/2003   Sridhar Gidugu  - Added code to check aps fm eff          |
REM|                                 B2989806                                |
REM+=========================================================================+
*/
PROCEDURE export_effectivities
(
  return_status            OUT NOCOPY BOOLEAN
)
IS
  p_status       BOOLEAN;
  b_status       BOOLEAN;
  r_status       BOOLEAN;
  ro_status      BOOLEAN;
  oc_status      BOOLEAN;

BEGIN

        /* Finally generate the effectivity_id */

        /* B2989806
           If aps_fmeff_id from gmp_form_eff was null,
           then create a new one.  Otherwise, use original.
        */

        /*
          g_aps_eff_id := g_aps_eff_id + 1 ;
          aps_fmeff_id := g_aps_eff_id ;
          x_aps_fmeff_id := (aps_fmeff_id * 2 ) + 1 ;
          B2989806
        */

        IF effectivity.aps_fmeff_id = -1 THEN
         g_aps_eff_id := g_aps_eff_id + 1 ;
         aps_fmeff_id := g_aps_eff_id ;
        ELSE
         aps_fmeff_id := effectivity.aps_fmeff_id ;
        END IF ;

        x_aps_fmeff_id := (aps_fmeff_id * 2 ) + 1 ;


    /* B3837959 MMK Issue, Handling of return status */
    write_process_effectivity(x_aps_fmeff_id, aps_fmeff_id, p_status);
    return_status := p_status ;

    IF return_status = TRUE THEN
      write_bom_components(x_aps_fmeff_id, b_status);
      return_status := b_status ;

      IF (effectivity.routing_id IS NOT NULL) AND (b_status = TRUE) THEN
        write_routing(x_aps_fmeff_id, r_status);
        return_status := r_status ;

        IF return_status = TRUE THEN
          write_routing_operations(x_aps_fmeff_id,ro_status);
          return_status := ro_status ;

          IF return_status = TRUE THEN
             write_operation_components(x_aps_fmeff_id,
                                        effectivity.recipe_id,
                                        oc_status);
             return_status := oc_status ;
             IF return_status = FALSE THEN
               log_message('write_operation_components Returned FALSE');
             END IF;
          ELSE
            log_message('write_routing_operations Returned FALSE');
            return_status := FALSE;
          END IF;
        ELSE
          log_message('write_routing Returned FALSE');
          return_status := FALSE;
        END IF;
      ELSE
          IF return_status = FALSE THEN
            log_message('write_bom_components Returned FALSE');
          END IF;
      END IF;
    ELSE
      log_message('write_process_effectivity Returned FALSE');
      return_status := FALSE;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
       log_message('Export Effectivities Raised Exception: '||sqlerrm);
       log_message(to_char(effectivity.fmeff_id));
       return_status := FALSE;
END export_effectivities;

/*
REM+=========================================================================+
REM+                                                                         +
REM+                         PUBLIC PROCEDURES                               +
REM+                                                                         +
REM+=========================================================================+

REM+=========================================================================+
REM| PROCEDURE NAME                                                          |
REM|    extract_effectivities                                                |
REM|                                                                         |
REM| TYPE                                                                    |
REM|    Public                                                               |
REM|                                                                         |
REM| USAGE                                                                   |
REM|    This is the 'main' procedure for extracting effectivities and then   |
REM|    exploding the ones which are valid for export to APS                 |
REM|                                                                         |
REM| DESCRIPTION                                                             |
REM|                                                                         |
REM|                                                                         |
REM| INPUT PARAMETERS                                                        |
REM|    None                                                                 |
REM|                                                                         |
REM| OUTPUT PARAMETERS                                                       |
REM|    return_status                                                        |
REM|                                                                         |
REM| INPUT/OUTPUT PARAMETERS                                                 |
REM|    None                                                                 |
REM|                                                                         |
REM| HISTORY                                                                 |
REM|  07/14/2002   Rajesh Patangya - Reorgnized the complete code B2314052   |
REM| 04/21/2004   - Navin Sinha - B3577871 -ST:OSFME2: collections failing   |
REM|                               in planning data pull.                    |
REM|                               Added handling of NO_DATA_FOUND Exception.|
REM|                               And return the return_status as TRUE.     |
REM+=========================================================================+
*/
PROCEDURE extract_effectivities
(
  at_apps_link     IN VARCHAR2,
  delimiter_char   IN VARCHAR2,
  instance         IN INTEGER,
  run_date         IN DATE,
  return_status    IN OUT NOCOPY BOOLEAN
)
IS
  valid            BOOLEAN;
  setup_failure    EXCEPTION;
  extract_failure  EXCEPTION;
  export_failure   EXCEPTION;

  retrieval_cursor        VARCHAR2(32700) ;
BEGIN
g_aps_eff_id              := 0; /* Global Aps Effectivity ID */
aps_fmeff_id              := 0 ;/* Generated effectivity Id */
x_aps_fmeff_id            := 0 ;/* encoded effectivity Id */
retrieval_cursor          := NULL ;

  IF return_status THEN
    v_cp_enabled := TRUE;
  ELSE
    v_cp_enabled := FALSE;
  END IF;

  /* B2104059 GMP-APS ENHANCEMENT FOR GMD FORMULA SECURITY FUNCTIONALITY  */
  /* Disable the security  */

    retrieval_cursor := ' begin gmd_p_fs_context.set_additional_attr'
                        || at_apps_link || ';end;'   ;
    EXECUTE IMMEDIATE retrieval_cursor ;

  /* Before we do anything we need to create/setup/size a few things */

  g_instance_id := instance ;

  setup(at_apps_link, delimiter_char, instance, run_date, valid);

  IF NOT valid THEN
    RAISE setup_failure;
  END IF;

  /* If all is OK, extract the effectivities to PL/SQL tables */
  retrieve_effectivities(valid);

  IF NOT valid THEN
    RAISE extract_failure;
  END IF;

  return_status := TRUE;

  EXCEPTION
	WHEN setup_failure THEN
	    /* Initial setup failed */
		log_message('Effectivity extract setup failure');
		return_status := FALSE;

	WHEN extract_failure THEN
	    /* Effectivity extraction failed */
		log_message('Effectivity extraction failed');
		return_status := FALSE;

	WHEN export_failure THEN
	    /* Effectivity export failed */
		log_message('Effectivity export failed');
		return_status := FALSE;

        WHEN NO_DATA_FOUND THEN  /* B3577871 */
                log_message(' NO_DATA_FOUND exception raised in Procedure: MSC_CL_GMP_UTILITY.Extract_effectivities ' );
                return_status := TRUE;
	WHEN OTHERS THEN
		log_message('Untrapped effectivity extraction error');
		log_message(sqlerrm);
        return_status := FALSE;

END extract_effectivities;

/*
REM+=========================================================================+
REM| PROCEDURE NAME                                                          |
REM|    Extract_Items                                                        |
REM|                                                                         |
REM| TYPE                                                                    |
REM|    Public                                                               |
REM|                                                                         |
REM| USAGE                                                                   |
REM|                                                                         |
REM|                                                                         |
REM| DESCRIPTION                                                             |
REM|    This procedure refreshes the gmp_items_aps table with all items for  |
REM|    which planning is required. An item is deemed to fall within the     |
REM|    scope of planning if it occurs in the plant/warehouse effectivity    |
REM|    (ps_whse_eff). If a row in ps_whse_eff has a blank item_id this      |
REM|    indicates all items, and this means that we must generate rows in    |
REM|    gmp_item_aps for all items using the plant/warehouse combination     |
REM|    just read.                                                           |
REM|                                                                         |
REM|                                                                         |
REM| INPUT PARAMETERS                                                        |
REM|    opm_link   VARCHAR2 database link to opm_instance                    |
REM|    aps_link   VARCHAR2 database link to aps_instance                    |
REM|                                                                         |
REM|    Either or both of these parameters may be NULL or they may both be   |
REM|    be set up, depending on requirements and which server(s) are         |
REM|    present.                                                             |
REM|                                                                         |
REM| OUTPUT PARAMETERS                                                       |
REM|    return_status    BOOLEAN: TRUE=> OK                                  |
REM|                                                                         |
REM| INPUT/OUTPUT PARAMETERS                                                 |
REM|    None                                                                 |
REM|                                                                         |
REM| HISTORY                                                                 |
REM|    Created 8th July 1999 by P.J.Schofield (OPM Development Oracle UK)   |
REM|                                                                         |
REM|    15th July 1999 P.J.Schofield                                         |
REM|    Include inventory_item_id from mtl_system_items and uom_code from    |
REM|    mtl_units_of_measure                                                 |
REM|    04/03/2000 - Using mtl_organization_id from ic_item_mst instead of   |
REM|               - organization_id from sy_orgn_mst table. Bug# 1252322    |
REM|    12/14/00   - B1540127 By Rajesh Patangya                             |
REM|                 join change for unit_of_measure field in sy_uoms_mst    |
REM| 04/21/2004   - Navin Sinha - B3577871 -ST:OSFME2: collections failing   |
REM|                               in planning data pull.                    |
REM|                               Added handling of NO_DATA_FOUND Exception.|
REM|                               And return the return_status as TRUE.     |
REM|                                                                         |
REM+=========================================================================+
*/
PROCEDURE extract_items
(
  at_apps_link  IN VARCHAR2,
  instance      IN INTEGER,
  run_date      IN DATE,
  return_status IN OUT NOCOPY BOOLEAN
)
IS
  c_item_cursor           ref_cursor_typ;

  retrieval_cursor        VARCHAR2(32700);
  insert_statement        VARCHAR2(32700);

  TYPE gmp_item_aps_typ  IS RECORD (
    item_no               VARCHAR2(32),
    item_id               PLS_INTEGER,
    category_id           NUMBER,        /* SGIDUGU  Bug 5882984 */
    seq_dpnd_class        VARCHAR2(8),   /* SGIDUGU  Bug 5882984 */
    item_um               VARCHAR2(4),
    uom_code              VARCHAR2(3),
    lot_control           PLS_INTEGER,
    item_desc1            VARCHAR2(70),
    aps_item_id           PLS_INTEGER,
    organization_id       PLS_INTEGER,
    whse_code             VARCHAR2(4),
    replen_ind            PLS_INTEGER,
    consum_ind            PLS_INTEGER,
    plant_code            VARCHAR2(4),
    creation_date         DATE,
    created_by            PLS_INTEGER,
    last_update_date      DATE,
    last_updated_by       PLS_INTEGER,
    last_update_login     PLS_INTEGER,
    experimental_ind      PLS_INTEGER);   /* Bug # 5238790 */

  gmp_item_aps_rec        gmp_item_aps_typ;

  i                       INTEGER ;
  v_dummy                 NUMBER ;

BEGIN
  i                       := 0;
  v_dummy                 := 0;

  IF return_status THEN
    v_cp_enabled := TRUE;
  ELSE
    v_cp_enabled := FALSE;
  END IF;

   /* populate the org_string */
     IF MSC_CL_GMP_UTILITY.org_string(instance) THEN
        NULL ;
     ELSE
        RAISE invalid_string_value  ;
     END IF;

     l_in_str_org := MSC_CL_GMP_UTILITY.g_in_str_org ;    /* 3491625 */

  retrieval_cursor := 'DELETE FROM gmp_item_aps'||at_apps_link;
  EXECUTE IMMEDIATE retrieval_cursor;

  COMMIT;

/*   New Changes - Using mtl_organization_id from ic_whse_mst , instead of organization_id
                   from sy_orgn_mst , Bug# 1252322
*/

  /* SGIDUGU - code added for Seq Dep Bug 5882984 */
  retrieval_cursor :=
                'SELECT iim.item_no, iim.item_id,nvl(iim.seq_category_id,-1), '
                ||'  iim.seq_dpnd_class , '
                ||'  iim.item_um, mum.uom_code,iim.lot_ctl, iim.item_desc1, '
                ||'  msi.inventory_item_id, '
                ||'  iwm.mtl_organization_id, '
		||'  pwe.whse_code, decode(sum(pwe.replen_ind), 0, 0, 1), '
                ||'  decode(sum(pwe.consum_ind), 0, 0, 1), '
		||'  pwe.plant_code, iim.creation_date, iim.created_by, '
                ||'  iim.last_update_date,iim.last_updated_by, NULL '
                 /* Bug # 5238790 */
                ||'  ,NVL(iim.experimental_ind,0) '
                ||'  FROM  ic_item_mst'||at_apps_link||' iim,'
		||'        sy_uoms_mst'||at_apps_link||' sou,'   /* B1540127 */
		||'        ps_whse_eff'||at_apps_link||' pwe,'
		||'        ic_whse_mst'||at_apps_link||' iwm,'
		||'        mtl_system_items'||at_apps_link||' msi,'
		||'        mtl_units_of_measure'||at_apps_link||' mum, '
                ||'        sy_orgn_mst'||at_apps_link||' som '
		||'  WHERE iim.delete_mark = 0 '
		||'    AND som.delete_mark = 0 '
		||'    AND iim.inactive_ind = 0 '
		||'    AND iim.item_no = msi.segment1 '
		||'    AND iwm.mtl_organization_id = msi.organization_id '
                ||'    AND pwe.plant_code = som.orgn_code '
		||'    AND pwe.whse_code = iwm.whse_code '
		||'    AND sou.unit_of_measure = mum.unit_of_measure '
                ||'    AND sou.delete_mark = 0 ' ;
             IF l_in_str_org  IS NOT NULL THEN     /* B3491625 */
                retrieval_cursor := retrieval_cursor
                ||'    AND iwm.mtl_organization_id ' || l_in_str_org ;
             END IF;
                retrieval_cursor := retrieval_cursor
		||'    AND iim.item_um = sou.um_code '
		/*||'    AND iim.experimental_ind = 0 '*//* Bug # 5238790 */
		||'    AND ( '
		||'          pwe.whse_item_id IS NULL OR '
		||'          pwe.whse_item_id = iim.whse_item_id OR '
		||'          ( '
		||'            pwe.whse_item_id = iim.item_id AND '
		||'            iim.item_id <> iim.whse_item_id '
		||'          ) '
                ||'        ) '
		||' GROUP BY '
		||'   iim.item_id, iim.item_no,iim.seq_category_id, '
                ||'   iim.seq_dpnd_class, '
                ||'   iim.item_desc1, iim.item_um, '
                ||'   iim.lot_ctl, pwe.whse_code, '
		||'   pwe.plant_code, mum.uom_code, msi.inventory_item_id, '
                ||'   iwm.mtl_organization_id, '
		||'   iim.creation_date, iim.created_by, iim.last_update_date, '
                ||'   iim.last_updated_by '
                ||'  ,iim.experimental_ind ' ;/* Bug # 5238790 */

  OPEN c_item_cursor FOR retrieval_cursor;

  /* SGIDUGU - added inserts for Category Id and Seq Dep Id Bug 5882984 */
  insert_statement :=
                'INSERT INTO gmp_item_aps'||at_apps_link||' '
		||' ( '
		||'  item_no, item_id,category_id,seq_dpnd_class, '
                ||'  item_um, uom_code, '
                ||'  lot_control, item_desc1, '
	        ||'  aps_item_id, organization_id, whse_code, replen_ind,'
		||'  consum_ind,  plant_code, creation_date, created_by, '
		||'  last_update_date, last_updated_by, last_update_login '
                ||'  ,experimental_ind '  /* Bug # 5238790 */
		||' ) '
		||'  VALUES '
		||' (:p1,:p2,:p3,:p4, '
                ||'  :p5,:p6, '
                ||'  :p7,:p8,:p9,:p10,'
                ||'  :p11,:p12,:p13,:p14, '
                ||'  :p15,:p16,:p17,:p18,:p19,:p20 )'; /* Bug # 5238790 */

  FETCH c_item_cursor
  INTO  gmp_item_aps_rec;

  WHILE c_item_cursor%FOUND
  LOOP
    EXECUTE IMMEDIATE insert_statement USING
                 gmp_item_aps_rec.item_no,
		 gmp_item_aps_rec.item_id,
		 gmp_item_aps_rec.category_id,     /* SGIDUGU Bug 5882984 */
		 gmp_item_aps_rec.seq_dpnd_class,  /* SGIDUGU Bug 5882984 */
		 gmp_item_aps_rec.item_um,
		 gmp_item_aps_rec.uom_code,
		 gmp_item_aps_rec.lot_control,
		 gmp_item_aps_rec.item_desc1,
		 gmp_item_aps_rec.aps_item_id,
		 gmp_item_aps_rec.organization_id,
		 gmp_item_aps_rec.whse_code,
	         gmp_item_aps_rec.replen_ind,
		 gmp_item_aps_rec.consum_ind,
		 gmp_item_aps_rec.plant_code,
		 run_date,
		 gmp_item_aps_rec.created_by,
	         run_date,
		 gmp_item_aps_rec.last_updated_by,
		 0
                 ,gmp_item_aps_rec.experimental_ind ;   /* Bug # 5238790 */

    i := i + 1;

    IF i = 500 then
      COMMIT;
      i := 0;
    END IF;


    FETCH c_item_cursor
    INTO gmp_item_aps_rec;

  END LOOP;

  COMMIT;

  CLOSE c_item_cursor;

          SELECT st.VALUE INTO v_dummy from V$MYSTAT st, V$STATNAME sn
          where st.STATISTIC# = sn.STATISTIC#
          and sn.NAME in ('session pga memory');
          log_message('After Item Cursor Session pga memory = ' || TO_CHAR(v_dummy) );

  return_status := TRUE;

  EXCEPTION
    WHEN invalid_string_value  THEN
      log_message('Organization string is Invalid ' );
      return_status := FALSE;
    WHEN NO_DATA_FOUND THEN /* B3577871 */
      log_message(' NO_DATA_FOUND exception raised in Procedure: MSC_CL_GMP_UTILITY.Extract_Items ' );
      return_status := TRUE;
    WHEN OTHERS THEN
      log_message('Item extraction failed with error '||sqlerrm);
      return_status := FALSE;

END Extract_Items;

/*
REM+=========================================================================+
REM| PROCEDURE NAME                                                          |
REM|    extract_sub_inventory                                                |
REM|                                                                         |
REM| TYPE                                                                    |
REM|    Public                                                               |
REM|                                                                         |
REM| USAGE                                                                   |
REM|                                                                         |
REM|                                                                         |
REM| DESCRIPTION                                                             |
REM|    This procedure creates sub-inventories for each eligible OPM         |
REM|    warehouse and writes them to the msc_sub_inventories table.          |
REM|                                                                         |
REM| INPUT PARAMETERS                                                        |
REM|    opm_link   VARCHAR2 database link to opm_instance                    |
REM|    aps_link   VARCHAR2 database link to aps_instance                    |
REM|                                                                         |
REM|    Either or both of these parameters may be NULL or they may both be   |
REM|    be set up, depending on requirements and which server(s) are         |
REM|    present.                                                             |
REM|                                                                         |
REM| OUTPUT PARAMETERS                                                       |
REM|    return_status    BOOLEAN: TRUE=> OK                                  |
REM|                                                                         |
REM| INPUT/OUTPUT PARAMETERS                                                 |
REM|    None                                                                 |
REM|                                                                         |
REM| HISTORY                                                                 |
REM|    Created 12th August 1999 by P.J.Schofield (OPM Development UK)       |
REM|    10/13/99 - Added deleted_flag in the insert statement                |
REM| 04/21/2004  - Navin Sinha - B3577871 -ST:OSFME2: collections failing    |
REM|                               in planning data pull.                    |
REM|                               Return return_status as TRUE in case      |
REM|                               no_warehouses Exception is raised.        |
REM|                                                                         |
REM+=========================================================================+
*/
PROCEDURE extract_sub_inventory
(
  at_apps_link  IN VARCHAR2,
  instance      IN INTEGER,
  run_date      IN DATE,
  return_status IN OUT NOCOPY BOOLEAN
)
IS
  c_whse_cursor           ref_cursor_typ;

  retrieval_cursor        VARCHAR2(32700);

  whse_code           VARCHAR2(4);
  organization_id     NUMBER;
  valid               BOOLEAN;

  no_warehouses       EXCEPTION;
  setup_failure       EXCEPTION;
BEGIN

  IF return_status THEN
    v_cp_enabled := TRUE;
  ELSE
    v_cp_enabled := FALSE;
  END IF;

   /* populate the org_string */
     IF MSC_CL_GMP_UTILITY.org_string(instance) THEN
        NULL ;
     ELSE
        RAISE invalid_string_value  ;
     END IF;

     l_in_str_org := MSC_CL_GMP_UTILITY.g_in_str_org ;    /* B3491625 */

  /* New Changes - Using mtl_organization_id from ic_whse_mst , instead of
     organization_id from sy_orgn_mst , Bug# 1252322 */

  retrieval_cursor :=
                     ' SELECT iwm.whse_code, iwm.mtl_organization_id '
		   ||' FROM  ic_whse_mst'||at_apps_link||' iwm '
	           ||' WHERE iwm.delete_mark = 0 AND '
		   ||'       iwm.mtl_organization_id IS NOT NULL ';

        IF l_in_str_org  IS NOT NULL THEN     /* B3491625 */
           retrieval_cursor := retrieval_cursor
                ||'    AND iwm.mtl_organization_id ' || l_in_str_org ;
        END IF;

  OPEN c_whse_cursor FOR retrieval_cursor;

  FETCH c_whse_cursor
  INTO  whse_code, organization_id;

  IF c_whse_cursor%NOTFOUND
  THEN
    raise no_warehouses;
  END IF;

  WHILE c_whse_cursor%FOUND
  LOOP
     INSERT INTO msc_st_sub_inventories
	 (
	   sub_inventory_code,
	   organization_id,
	   netting_type,
	   sr_instance_id,
           deleted_flag,
	   creation_date,
	   created_by,
	   last_update_date,
	   last_updated_by
	 )
	 VALUES
	 (
	   whse_code,
	   organization_id,
	   1,
	   instance,
           2,
	   run_date,
	   0,
	   run_date,
	   0
	 );

     COMMIT;

     FETCH c_whse_cursor
	 INTO  whse_code, organization_id;

  END LOOP;
  CLOSE c_whse_cursor;

  return_status := TRUE;

  EXCEPTION
    WHEN invalid_string_value  THEN
        log_message('Organization string is Invalid ' );
        return_status := FALSE;

    WHEN no_warehouses
	THEN
	  log_message('No warehouses found to export');
	  return_status := TRUE;   /* B3577871 */

    WHEN setup_failure
	THEN
	  log_message('Sub-inventory export setup failure');
	  return_status := FALSE;

    WHEN OTHERS
	THEN
	  log_message('Sub-Inventory Export failed:');
	  log_message(sqlerrm);
	  return_status := FALSE;
END extract_sub_inventory;

/*
REM+=========================================================================+
REM| PROCEDURE NAME                                                          |
REM|    setup                                                                |
REM|                                                                         |
REM| TYPE                                                                    |
REM|    Private                                                              |
REM|                                                                         |
REM| USAGE                                                                   |
REM|    This procedure sets up and initilialises various program structures  |
REM|    for the extraction of effectivities                                  |
REM|                                                                         |
REM| DESCRIPTION                                                             |
REM|                                                                         |
REM|                                                                         |
REM| INPUT PARAMETERS                                                        |
REM|    apps_link_name VARCHAR2 - database link to APPS database instance    |
REM|    delimtiter_char VARCHAR2 - used to links strings together            |
REM|    instance       INTEGER - the GMP instance ID                         |
REM|    run_date       DATE    - the run date                                |
REM|                                                                         |
REM| OUTPUT PARAMETERS                                                       |
REM|    return_status: TRUE => OK                                            |
REM|                                                                         |
REM| INPUT/OUTPUT PARAMETERS                                                 |
REM|    None                                                                 |
REM|                                                                         |
REM| HISTORY                                                                 |
REM|  07/14/2002   Rajesh Patangya - Reorgnized the complete code B2314052   |
REM+=========================================================================+
*/
PROCEDURE setup
(
  apps_link_name IN VARCHAR2,
  delimiter_char IN VARCHAR2,
  instance       IN INTEGER,
  run_date       IN DATE,
  return_status  OUT NOCOPY BOOLEAN
)
IS
  stat           VARCHAR2(1024);
  statement_no   INTEGER;

BEGIN
  /* Construct link names */

  IF apps_link_name IS NOT NULL
  THEN
    at_apps_link := apps_link_name;
  ELSE
    at_apps_link := ' ';
  END IF;

  /* select maximum aps_effectivity ID */

  stat := ' SELECT max(APS_FMEFF_ID) from gmp_form_eff'||at_apps_link ;
  EXECUTE IMMEDIATE stat INTO g_aps_eff_id ;

  IF NVL(g_aps_eff_id,0) = 0 THEN
     g_aps_eff_id := 1 ;
  END IF ;

  /* Everything starts with index # of 1 */

  alt_rsrc_size             := 1;
  formula_headers_size      := 1;
  formula_details_size	    := 1;
  formula_orgn_size         := 1;
  routing_headers_size      := 1;
  rtg_org_dtl_size          := 1;
  rtg_gen_dtl_size          := 1;
  material_assocs_size      := 1;
  recipe_orgn_over_size     := 1;
  recipe_override_size      := 1;
  g_mat_assoc      	    := 1;
  opr_stpdep_size           := 1;
  g_dep_index               := 1;

/* These variables store the MTQ related values that is last inserted. */
  g_old_formula_id          := -1; /* B3970993 */
  g_old_recipe_id           := -1; /* B3970993 */
  g_old_rtg_id              := -1; /* B3970993 */
  g_old_rtgstep_id          := -1; /* B3970993 */
  g_old_aps_item_id         := -1; /* B3970993 */
  g_mtq_loc                 := -1; /* B3970993 */
  g_min_mtq                 := -1; /* B3970993 */

  current_date_time := run_date;

  b_instance_id := instance;

  delimiter := delimiter_char;

  /* Initialize the counter values for bulk inserts */
   bom_index   := 0 ;
   bomc_index  := 0 ;
   or_index    := 0 ;
   rtg_index   := 0 ;
   opr_index   := 0 ;
   rs_index    := 0 ;
   oc_index    := 0 ;
   mtq_index   := 0 ;

  return_status := TRUE;

   /* Get the directory specified in the 'utl_file_dir' in init.ora file */
   BEGIN
       SELECT substrb(translate(ltrim(value),',',' '), 1,
                     instr(translate(ltrim(value),',',' '),' ') - 1)
        INTO p_location
        FROM v$parameter
       WHERE name = 'utl_file_dir';
  EXCEPTION
    WHEN OTHERS THEN
	return_status := FALSE;
	log_message('directory select failed ');
	log_message(sqlerrm);
    END ;

    IF p_location IS NOT NULL THEN
      -- gmp_putline ( 'file opened ' || p_location  || ' at '
      --    || TO_CHAR ( SYSDATE, 'DD-MON-YYYY HH24:MI:SS' ), 'w' );
      -- gmp_putline ('  ' , 'a' );
      null ;
    END IF ;

  EXCEPTION
    WHEN OTHERS THEN
	return_status := FALSE;
	log_message('Setup failed at statement ');
	log_message(sqlerrm);

END setup;
/*
REM+=========================================================================+
REM| FUNCTION NAME                                                           |
REM|    find_routing_offsets                                                  |
REM| DESCRIPTION                                                             |
REM|                                                                         |
REM| HISTORY                                                                 |
REM+=========================================================================+
*/
FUNCTION find_routing_offsets (p_formula_id    	IN NUMBER,
                               p_plant_code 	IN VARCHAR2)
                               RETURN NUMBER IS

i 	    NUMBER ;
retvar 	    NUMBER ;

BEGIN
i 	    := 1 ;
retvar 	    := -1 ;

IF p_formula_id = g_prev_formula_id THEN
 retvar := g_prev_locn ;
 IF g_prev_locn > 0 THEN
   g_rstep_loc := g_prev_locn ;
 END IF ;
ELSE
g_prev_formula_id := p_formula_id ;
FOR i in g_rstep_loc..rtg_offsets_size
LOOP
  IF rstep_offsets(i).formula_id = p_formula_id THEN
    IF rstep_offsets(i).plant_code = p_plant_code THEN
      retvar := i ;
      g_rstep_loc := i ;
      EXIT ;
    ELSIF rstep_offsets(i).plant_code > p_plant_code THEN
      g_rstep_loc := i ;
      retvar := -1 ;
      EXIT ;
    ELSE  /* continue looping */
      NULL ;
    END IF ;
  ELSIF rstep_offsets(i).formula_id < p_formula_id THEN
    NULL ;  /* Continue looping */
  ELSE -- rstep_offsets(i).formula_id > p_formula_id THEN
   retvar := -1 ;
   g_rstep_loc := i ;
   EXIT ;
  END IF;
END LOOP ;

END IF ; /* different formula_id */
 g_prev_locn := retvar ;
 return retvar ;
END find_routing_offsets;

/*
REM+=========================================================================+
REM| FUNCTION NAME                                                           |
REM|    get_offsets                                                          |
REM| DESCRIPTION                                                             |
REM|                                                                         |
REM| HISTORY                                                                 |
REM+=========================================================================+
*/
FUNCTION get_offsets( p_formula_id		IN NUMBER,
			p_plant_code 		IN VARCHAR2,
			p_formulaline_id	IN NUMBER )
			RETURN NUMBER IS

i 	    NUMBER ;
retvar 	    NUMBER ;

BEGIN
i 	    := 1 ;
retvar 	    := -1 ;

FOR i in g_rstep_loc..rtg_offsets_size
LOOP
  IF rstep_offsets(i).formula_id = p_formula_id THEN
    IF rstep_offsets(i).plant_code = p_plant_code THEN
      IF rstep_offsets(i).formulaline_id = p_formulaline_id THEN
	retvar := i ;
	g_rstep_loc := i+1 ;
	EXIT ;
      ELSIF
	rstep_offsets(i).formulaline_id > p_formulaline_id THEN
	retvar := -1 ;
	g_rstep_loc := i ;
	EXIT ;
      ELSE
	NULL ; /* continue looping */
      END IF ;
    ELSIF rstep_offsets(i).plant_code > p_plant_code THEN
      g_rstep_loc := i ;
      retvar := -1 ;
      EXIT ;
    ELSE  /* continue looping */
      NULL ;
    END IF ;
  ELSIF rstep_offsets(i).formula_id < p_formula_id THEN
    NULL ;  /* Continue looping */
  ELSE -- rstep_offsets(i).formula_id > p_formula_id THEN
   retvar := -1 ;
   g_rstep_loc := i ;
   EXIT ;
  END IF;
END LOOP ;
 return retvar ;
END get_offsets;

/*
REM+=========================================================================+
REM| PROCEDURE NAME                                                          |
REM|    gmp_putline                                                          |
REM| HISTORY                                                                 |
REM|    Created by Rajesh Patangya (OPM Development Oracle US)               |
REM+=========================================================================+
*/
   /* Define a function that open the log file, makes entry into the log file
      and close the log file */
   PROCEDURE gmp_putline (
       v_text                    IN       VARCHAR2,
       v_mode                    IN       VARCHAR2 )
   IS
      LOG   UTL_FILE.file_type;
  BEGIN

    IF p_location IS NOT NULL THEN
      LOG    :=
             UTL_FILE.fopen ( p_location, 'GMPBM11B.log', v_mode );
      UTL_FILE.put_line ( LOG, v_text );
      UTL_FILE.fflush ( LOG );
      UTL_FILE.fclose ( LOG );
    ELSE
      NULL ;
    END IF;
END gmp_putline;

/*
REM+=========================================================================+
REM| PROCEDURE NAME                                                          |
REM|    time_stamp                                                           |
REM| DESCRIPTION                                                             |
REM|                                                                         |
REM| HISTORY                                                                 |
REM| 07/14/2002   Rajesh Patangya - Reorgnized the complete code B2314052    |
REM+=========================================================================+
*/
PROCEDURE time_stamp IS

  cur_time VARCHAR2(25) ;
BEGIN
  cur_time := NULL ;

   SELECT to_char(sysdate,'DD-MON-RRRR HH24:MI:SS')
   INTO cur_time FROM sys.dual ;

   log_message(cur_time);
  EXCEPTION
    WHEN OTHERS THEN
        log_message('Failure occured in time_stamp');
        log_message(sqlerrm);
      RAISE;
END time_stamp ;

/*
REM+=========================================================================+
REM| PROCEDURE NAME                                                          |
REM|    msc_inserts                                                          |
REM| DESCRIPTION                                                             |
REM|    All the Bulk insert to MSC tables for OPM data                       |
REM|                                                                         |
REM| HISTORY                                                                 |
REM| 03/12/2004   Created Rajesh Patangya                                    |
REM|                                                                         |
REM+=========================================================================+
*/
PROCEDURE msc_inserts
(
  return_status  OUT NOCOPY BOOLEAN
)
IS

i         integer ;

BEGIN
stmt_no   := 0 ;
i         := 1;

/* --------------------------- Process Effectivity Insert ------------------------- */

     stmt_no := 901 ;
     i := 1 ;
     IF pef_organization_id.FIRST > 0 THEN
     FORALL i IN pef_organization_id.FIRST..pef_organization_id.LAST
      INSERT INTO msc_st_process_effectivity (
             process_sequence_id,
             item_id,
             organization_id,
             effectivity_date,
             disable_date,
             minimum_quantity,
             maximum_quantity,
             preference,
             routing_sequence_id,
             bill_sequence_id,
             sr_instance_id,
             item_process_cost, line_id,
             total_product_cycle_time, primary_line_flag, production_line_rate,
             deleted_flag,
             last_update_date,
             last_updated_by,
             creation_date,
             created_by )
             VALUES
             (
             pef_process_sequence_id(i) ,
             pef_item_id(i) ,
             pef_organization_id(i) ,
             pef_effectivity_date(i) ,
             pef_disable_date(i) ,
             pef_minimum_quantity(i) ,
             pef_maximum_quantity(i) ,
             pef_preference(i) ,
             pef_routing_sequence_id(i) ,
             pef_bill_sequence_id(i) ,
             pef_sr_instance_id(i) ,
             null_value, null_value,
             null_value, null_value, null_value,
             2     ,                           /* Deleted Flag */
             pef_last_update_date(i) ,
             0  ,                              /* Last Updated By */
             pef_creation_date(i)    ,
             0                                /* Created By */
             ) ;
     END IF;
/* -------------------------------  BOM Insert --------------------------- */
     stmt_no := 902 ;
     i := 1 ;              /* B3837959 MMK Issue */
     IF bom_organization_id.FIRST > 0 THEN
     FORALL i IN bom_organization_id.FIRST..bom_organization_id.LAST
       INSERT INTO msc_st_boms (
	 bill_sequence_id,
         sr_instance_id,
         organization_id,
	 assembly_item_id,
         assembly_type,
         alternate_bom_designator,
	 specific_assembly_comment,
         scaling_type,
         assembly_quantity,
	 uom,
/* NAMIT_CR */
         operation_seq_num,
         deleted_flag,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by )
	 VALUES
         (
         bom_bill_sequence_id(i),
         bom_sr_instance_id(i)  ,
         bom_organization_id(i) ,
         bom_assembly_item_id(i),
         1   ,                             /* Assembly Type  */
         bom_alternate_bom_designator(i),
         bom_specific_assembly_comment(i),
         bom_scaling_type(i)     ,
         bom_assembly_quantity(i),
         bom_uom(i)              ,
/* NAMIT_CR */
         bom_op_seq_number(i)    ,
	 2     ,                           /* Deleted Flag */
         bom_last_update_date(i) ,
         0  ,                              /* Last Updated By */
         bom_creation_date(i)    ,
         0                                 /* Created By */
         ) ;
      END IF;


/* --------------------------- BOM Components Insert Stars ------------------------- */

     stmt_no := 903 ;
     i := 1 ;
     IF bomc_organization_id.FIRST > 0 THEN
     FORALL i IN bomc_organization_id.FIRST..bomc_organization_id.LAST
        INSERT INTO msc_st_bom_components
       (
       component_sequence_id,
       sr_instance_id,
       organization_id,
       Inventory_item_id,
       using_assembly_id,
       bill_sequence_id,
       component_type,
       scaling_type,
       change_notice,
       revision,
       uom_code,
       usage_quantity,
       effectivity_date,
       contribute_to_step_qty,
       disable_date,
       from_unit_number,
       to_unit_number,
       use_up_code,
       suggested_effectivity_date,
       driving_item_id,
       operation_offset_percent,
       optional_component,
       old_effectivity_date,
       wip_supply_type,
       planning_factor,
       atp_flag,
       component_yield_factor,
       deleted_flag,
       last_update_date,
       last_updated_by,
       creation_date,
       created_by,
       scale_multiple,
       scale_rounding_variance,
       rounding_direction
       )
       VALUES
       (
       bomc_component_sequence_id(i),
       bomc_sr_instance_id(i),
       bomc_organization_id(i),
       bomc_Inventory_item_id(i),
       bomc_using_assembly_id(i),
       bomc_bill_sequence_id(i),
       bomc_component_type(i),
       bomc_scaling_type(i),
       null_value,
       null_value,
       bomc_uom_code(i),
       bomc_usage_quantity(i),
       bomc_effectivity_date(i),
        /* NAMIT_ASQC */
       bomc_contribute_to_step_qty(i),
       bomc_disable_date(i),
       null_value,
       null_value,
       null_value,
       null_value,
       null_value,
       bomc_opr_offset_percent(i),
       bomc_optional_component(i),
       null_value,
       bomc_wip_supply_type(i),
       null_value,
       1,                                /* atp flag */
       1,                                /* component_yield_factor */
       2     ,                           /* Deleted Flag */
       bomc_last_update_date(i) ,
       0  ,                              /* Last Updated By */
       bomc_creation_date(i)    ,
       0 ,                               /* Created By */
       bomc_scale_multiple(i),
       bomc_scale_rounding_variance(i),
       bomc_rounding_direction(i)
       );
      END IF;

/* --------------------------- Routing Insert Stars ------------------------- */
     stmt_no := 904 ;
     i := 1 ;
     IF rtg_organization_id.FIRST > 0 THEN
     FORALL i IN rtg_organization_id.FIRST..rtg_organization_id.LAST
          INSERT INTO msc_st_routings (
           routing_sequence_id,
           sr_instance_id,
           routing_type,
           routing_comment,
           alternate_routing_designator,
           project_id,
           task_id,
           line_id,
           uom_code,
           cfm_routing_flag,
           ctp_flag,
           routing_quantity,
           assembly_item_id,
           organization_id,
           auto_step_qty_flag,
           deleted_flag,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by )
           VALUES (
           rtg_routing_sequence_id(i),
           rtg_sr_instance_id(i),
           1 ,                                    /* routing_type */
           rtg_routing_comment(i),
           rtg_alt_routing_designator(i),
           null_value,
           null_value,
           null_value,
           rtg_uom_code(i),
           null_value,
           null_value,
           rtg_routing_quantity(i),
           rtg_assembly_item_id(i),
           rtg_organization_id(i),
           rtg_auto_step_qty_flag(i),
           2,                                   /* Deleted Flag */
           rtg_last_update_date(i),             /* Last Update Date */
           0,
           rtg_creation_date(i),                /* Creation Date */
           0 ) ;
      END IF;

/* ----------------------- Operation Resource  Insert --------------------- */
     stmt_no := 905 ;
     i := 1 ;

  /*
     for i in or_operation_sequence_id.FIRST..or_operation_sequence_id.LAST
     loop
        log_message('========');
        log_message('Op seq id '||or_operation_sequence_id(i)) ;
        log_message('Res Seq Num '||or_resource_seq_num(i)) ;
        log_message('Resource id '||or_resource_id(i)) ;
        log_message(' Alternate Num ' ||or_alternate_number(i));
        log_message( 'principal flag '||or_principal_flag(i));
        log_message( 'Basis type '||or_basis_type(i));
        log_message( 'resource usage '||or_resource_usage(i));
        log_message( 'Max rsrc units '||or_max_resource_units(i)) ;
        log_message(' rsrc units '||or_resource_units(i)) ;
        log_message(' uom code '||or_uom_code(i)) ;
        log_message('Min capacity '||or_minimum_capacity(i)) ;
        log_message('Max capacity '||or_maximum_capacity(i)) ;
        log_message('Setup Id '||or_setup_id(i)) ;
        log_message('========');
     end loop;
    */

--
     IF or_operation_sequence_id.FIRST > 0 THEN
     FORALL i IN or_operation_sequence_id.FIRST..or_operation_sequence_id.LAST
        INSERT INTO msc_st_operation_resources (
        operation_sequence_id,
        resource_seq_num,
        resource_id,
        alternate_number,
        principal_flag,
        basis_type,
        resource_usage,
        max_resource_units,
        resource_units,
        uom_code,
        deleted_flag,
        sr_instance_id,
        routing_sequence_id,
        organization_id,
        minimum_capacity,
        maximum_capacity,
        setup_id,
        orig_resource_seq_num,
        breakable_activity_flag,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by )
        VALUES (
        or_operation_sequence_id(i) ,
        or_resource_seq_num(i) ,
        or_resource_id(i) ,
        or_alternate_number(i) ,
        or_principal_flag(i) ,
        or_basis_type(i) ,
        or_resource_usage(i) ,
        or_max_resource_units(i) ,
        or_resource_units(i) ,
        or_uom_code(i) ,
        2,
        or_sr_instance_id(i) ,
        or_routing_sequence_id(i) ,
        or_organization_id(i),
        or_minimum_capacity(i),
        or_maximum_capacity(i),
        or_setup_id(i),
        or_orig_rs_seq_num(i),
        or_break_ind(i),
        or_last_update_date(i) ,
        0,
        or_creation_date(i) ,
        0 );
      END IF;
/* ----------------------- Operations Insert --------------------- */
     stmt_no := 906 ;
     i := 1 ;
     IF opr_operation_sequence_id.FIRST > 0 THEN
     FORALL i IN opr_operation_sequence_id.FIRST..opr_operation_sequence_id.LAST
       INSERT INTO msc_st_routing_operations (
       operation_sequence_id,
       routing_sequence_id,
       operation_seq_num,
       sr_instance_id,
       operation_description,
       effectivity_date,
       disable_date,
       from_unit_number,
       to_unit_number,
       option_dependent_flag,
       operation_type,
       minimum_transfer_quantity,
       yield,
/* NAMIT_ASQC */
       step_quantity,
       step_quantity_uom,
       department_id,
       department_code,
       operation_lead_time_percent,
       cumulative_yield,
       reverse_cumulative_yield,
       net_planning_percent,
       setup_duration,
       tear_down_duration,
       uom_code,
       organization_id,
       standard_operation_code,
       deleted_flag,
       last_update_date,
       last_updated_by,
       creation_date,
       created_by )
       VALUES
       (
       opr_operation_sequence_id(i),
       opr_routing_sequence_id(i),
       opr_operation_seq_num(i),
       opr_sr_instance_id(i),
       opr_operation_description(i),
       opr_effectivity_date(i),
       null_value,
       null_value,
       null_value,
       1,
       null_value,
       opr_mtransfer_quantity(i),    /*B2870041*/
       null_value, /*  B2365684 rtg_org_dtl_tab(loop_index).step_qty, */
/* NAMIT_ASQC */
       opr_step_qty(i),
       opr_step_qty_uom(i),
       opr_department_id(i),
       opr_department_code(i),
       null_value,
       null_value,
       null_value,
       null_value,
       null_value,
       null_value,
       opr_uom_code(i),
       opr_organization_id(i),
       null_value ,
       2,                    /* Deleted Flag */
       opr_last_update_date(i),
       0,
       opr_creation_date(i),
       0 ) ;
      END IF;

/* ----------------------- Operation Sequence Insert --------------------- */
     stmt_no := 907 ;
     i := 1 ;
     IF rs_operation_sequence_id.FIRST > 0 THEN
     FORALL i IN rs_operation_sequence_id.FIRST..rs_operation_sequence_id.LAST
       INSERT INTO msc_st_operation_resource_seqs (
       operation_sequence_id,
       resource_seq_num,
       sr_instance_id,
       department_id,
       resource_offset_percent,
       schedule_flag,
       routing_sequence_id,
       organization_id,
       deleted_flag,
       last_update_date,
       last_updated_by,
       creation_date,
       created_by,
       activity_group_id )
       VALUES (
       rs_operation_sequence_id(i),
       rs_resource_seq_num(i),
       rs_sr_instance_id(i),
       rs_department_id(i),
       null_value,
       rs_schedule_flag(i),
       rs_routing_sequence_id(i),
       rs_organization_id(i),
       2,                         /* deleted flag */
       rs_last_update_date(i),
       0,
       rs_creation_date(i),
       0 ,
       rs_activity_group_id(i)
       ) ;
      END IF;

/* ----------------------- Operation Component Insert --------------------- */
     stmt_no := 908 ;
     i := 1 ;
  /*
     for i in oc_operation_sequence_id.FIRST..oc_operation_sequence_id.LAST
     loop
        log_message('========');
        log_message('Op seq id '||oc_operation_sequence_id(i)) ;
        log_message('Comp seq id '||oc_component_sequence_id(i)) ;
        log_message('Instance '||oc_sr_instance_id(i)) ;
        log_message('Bill Seq '||oc_bill_sequence_id(i)) ;
        log_message('Routing Seq '||oc_routing_sequence_id(i)) ;
        log_message('Org Id '||oc_organization_id(i)) ;
     end loop;
  */
     IF oc_operation_sequence_id.FIRST > 0 THEN
     FORALL i IN oc_operation_sequence_id.FIRST..oc_operation_sequence_id.LAST
      INSERT INTO msc_st_operation_components (
      operation_sequence_id, component_sequence_id, sr_instance_id,
      bill_sequence_id, routing_sequence_id, organization_id,
      deleted_flag, last_update_date, last_updated_by,
      creation_date, created_by )
      VALUES (
      oc_operation_sequence_id(i),
      oc_component_sequence_id(i),
      oc_sr_instance_id(i),
      oc_bill_sequence_id(i),
      oc_routing_sequence_id(i),
      oc_organization_id(i),
      2,
      oc_last_update_date(i),
      0,
      oc_creation_date(i),
      0   ) ;

      END IF;

/* ----------------------- MTQ Insert --------------------- */
/*  NAMIT_MTQ */

     stmt_no := 909 ;
     i := 1 ;
     IF itm_mtq_from_op_seq_id.FIRST > 0 THEN
     FORALL i IN itm_mtq_from_op_seq_id.FIRST..itm_mtq_from_op_seq_id.LAST
       INSERT INTO msc_st_operation_networks(
       from_op_seq_id,
       routing_sequence_id,
       dependency_type,
       transition_type,
       plan_id,
       sr_instance_id,
       deleted_flag,
       from_item_id,
       organization_id,
       minimum_transfer_qty,
       minimum_time_offset,
       maximum_time_offset,
       last_update_date,
       last_updated_by,
       creation_date,
       created_by,
       from_op_seq_num
       ) VALUES
       (
        itm_mtq_from_op_seq_id(i),
        itm_mtq_routing_sequence_id(i),
        5, /* MTQ with Hardlink */
        1, /* Primary */
        -1,
        itm_mtq_sr_instance_id(i),
        2,
        itm_mtq_from_item_id(i),
        itm_mtq_organization_id(i),
        itm_mtq_min_tran_qty(i),
        itm_mtq_min_time_offset(i),
        itm_mtq_max_time_offset(i),
        opr_last_update_date(i),
        0,
        opr_creation_date(i),
        0,
        itm_mtq_frm_op_seq_num(i)
       );

      END IF;

/* ----------------------- Step Dependency Insert --------------------- */
/* NAMIT_CR */

     stmt_no := 910 ;
     i := 1 ;
     IF opr_stpdep_frm_seq_id.FIRST > 0 THEN
     FORALL i IN opr_stpdep_frm_seq_id.FIRST..opr_stpdep_frm_seq_id.LAST
       INSERT INTO msc_st_operation_networks(
       from_op_seq_id,
       to_op_seq_id,
       routing_sequence_id,
       dependency_type,
       transition_type,
       plan_id,
       sr_instance_id,
       deleted_flag,
       minimum_time_offset,
       maximum_time_offset,
       transfer_pct,
       last_update_date,
       last_updated_by,
       creation_date,
       created_by,
       from_op_seq_num,
       to_op_seq_num,
       apply_to_charges,
       organization_id
       ) VALUES
       (
        opr_stpdep_frm_seq_id(i),
        opr_stpdep_to_seq_id(i),
        opr_stpdep_routing_sequence_id(i),
        opr_stpdep_dependency_type(i),
        1, /* Transition Type, 1 = Primary*/
        -1, /* Plan Id */
        opr_stpdep_sr_instance_id(i),
        2, /* Deleted Flag */
        opr_stpdep_min_time_offset(i),
        opr_stpdep_max_time_offset(i),
        opr_stpdep_trans_pct(i),
        opr_last_update_date(i),
        0,
        opr_creation_date(i),
        0,
        opr_stpdep_frm_op_seq_num(i),
        opr_stpdep_to_op_seq_num(i),
        opr_stpdep_app_to_chrg(i),
        opr_stpdep_organization_id(i)
       );

      END IF;
              bom_organization_id.delete  ;
              bomc_organization_id.delete ;
              pef_organization_id.delete ;
              rtg_organization_id.delete ;
              oc_organization_id.delete ;
              opr_organization_id.delete   ;
              or_organization_id.delete ;
              rs_organization_id.delete ;

              bom_bill_sequence_id.delete ;
              bomc_bill_sequence_id.delete ;
              pef_bill_sequence_id.delete ;
              oc_bill_sequence_id.delete ;

              bom_last_update_date.delete ;
              bomc_last_update_date.delete ;
              pef_last_update_date.delete ;
              rtg_last_update_date.delete ;
              or_last_update_date.delete ;
              opr_last_update_date.delete ;
              rs_last_update_date.delete ;
              oc_last_update_date.delete ;

              bom_creation_date.delete ;
              bomc_creation_date.delete ;
              pef_creation_date.delete ;
              rtg_creation_date.delete ;
              or_creation_date.delete ;
              opr_creation_date.delete ;
              rs_creation_date.delete ;
              oc_creation_date.delete ;

              pef_effectivity_date.delete ;
              bomc_effectivity_date.delete ;
              opr_effectivity_date.delete ;

              rtg_routing_sequence_id.delete ;
              pef_routing_sequence_id.delete ;
              or_routing_sequence_id.delete ;
              opr_routing_sequence_id.delete ;
              rs_routing_sequence_id.delete ;
              oc_routing_sequence_id.delete ;

              bomc_uom_code.delete;
              rtg_uom_code.delete;
              or_uom_code.delete ;
              opr_uom_code.delete;

              bom_assembly_item_id.delete ;
              rtg_assembly_item_id.delete ;

              bomc_component_sequence_id.delete ;
              oc_component_sequence_id.delete ;

              or_operation_sequence_id.delete  ;
              opr_operation_sequence_id.delete ;
              rs_operation_sequence_id.delete ;
              oc_operation_sequence_id.delete ;

              or_resource_seq_num.delete ;
              rs_resource_seq_num.delete ;

            /* -- BOM Variable Initialization -- */
              bom_alternate_bom_designator.delete ;
              bom_specific_assembly_comment.delete ;
              bom_scaling_type.delete ;
              bom_assembly_quantity.delete ;
              bom_uom.delete ;
              bom_index := 0 ;

            /* -- BOMC Variable Initialization -- */
              bomc_Inventory_item_id.delete ;
              bomc_using_assembly_id.delete ;
              bomc_component_type.delete ;
              bomc_scaling_type.delete ;
              bomc_usage_quantity.delete ;
              bomc_opr_offset_percent.delete  ;
              bomc_optional_component.delete  ;
              bomc_wip_supply_type.delete ;
              bomc_scale_multiple.delete  ;
              bomc_scale_rounding_variance.delete ;
              bomc_rounding_direction.delete  ;
              bomc_index := 0 ;

            /* -- Pef Variable Initialization -- */
              pef_process_sequence_id.delete ;
              pef_item_id.delete ;
              pef_disable_date.delete ;
              pef_minimum_quantity.delete ;
              pef_maximum_quantity.delete ;
              pef_preference.delete ;
              pef_index := 0 ;

            /* -- Rtg Variable Initialization -- */
              rtg_routing_comment.delete ;
              rtg_alt_routing_designator.delete ;
              rtg_routing_quantity.delete ;
              rtg_index := 0 ;

            /* -- Or Variable Initialization -- */
              or_resource_id.delete ;
              or_alternate_number.delete ;
              or_principal_flag.delete ;
              or_basis_type.delete ;
              or_resource_usage.delete ;
              or_max_resource_units.delete ;
              or_resource_units.delete ;
              or_index := 0 ;

            /* -- Opr Variable Initialization -- */
              opr_operation_seq_num.delete ;
              opr_operation_description.delete ;
              opr_mtransfer_quantity.delete ;
              opr_department_id.delete ;
              rs_department_id.delete ;
              opr_department_code.delete ;
              rs_activity_group_id.delete ;
              rs_schedule_flag.delete ;
              opr_index := 0 ;
              rs_index := 0 ;
              oc_index := 0 ;

              dbms_session.free_unused_user_memory;/* akaruppa B5007729 */


        return_status := TRUE ;
  EXCEPTION
    WHEN OTHERS THEN
        log_message('Error in MSC Inserts : '||stmt_no || ':' || sqlerrm);
        return_status := FALSE;

END msc_inserts ;
--
/*
REM+=========================================================================+
REM| PROCEDURE NAME                                                          |
REM|    write_setups_and_transitions                                         |
REM|                                                                         |
REM| TYPE                                                                    |
REM|    Private                                                              |
REM|                                                                         |
REM| USAGE                                                                   |
REM|    This procedure inserts rows into msc_st_resource_setups and          |
REM|    msc_st_setup_transitions                                             |
REM|                                                                         |
REM| DESCRIPTION                                                             |
REM|                                                                         |
REM|                                                                         |
REM| INPUT PARAMETERS                                                        |
REM|    None                                                                 |
REM|                                                                         |
REM| OUTPUT PARAMETERS                                                       |
REM|    None                                                                 |
REM|                                                                         |
REM| INPUT/OUTPUT PARAMETERS                                                 |
REM|    None                                                                 |
REM|                                                                         |
REM| HISTORY                                                                 |
REM|  06/02/2004   Sridhar Gidugu  created                                   |
REM|  0519/06 Rewrite for SDS                                                |
REM|   MSC_RESOURCE_SETUPS unique key is ON                                  |
REM|   Instance_id,resource_id,organization_id and setup_id                  |
REM+=========================================================================+
*/
PROCEDURE write_setups_and_transitions
(
  return_status  OUT NOCOPY BOOLEAN
)  IS
   l_profile            VARCHAR2(4);
   Zero_tran            VARCHAR2(25000);
   fact_tran            VARCHAR2(25000);
   rsrc_setup           VARCHAR2(25000);
   um_code_cursor       VARCHAR2(1000);
   um_code_ref          ref_cursor_typ;
BEGIN
   stmt_no     := 0 ;
   Zero_tran   := NULL ;
   fact_tran   := NULL ;
   rsrc_setup  := NULL ;
   um_code_cursor   := ' select fnd_profile.VALUE' ||at_apps_link
                      ||' (''BOM:HOUR_UOM_CODE'') from dual ' ;

       OPEN um_code_ref FOR um_code_cursor ;
       FETCH um_code_ref INTO l_profile;
       CLOSE um_code_ref;

     -- ZERO Transitions  (Alternate Resources are considered)
     stmt_no := 910 ;
     Zero_tran := ' INSERT INTO msc_st_setup_transitions ( '
     ||'    resource_id,          '
     ||'    organization_id,     '
     ||'    from_setup_id,        '
     ||'    to_setup_id,         '
     ||'    transition_time,      '
     ||'    transition_penalty,   '
     ||'    transition_uom,       '
     ||'    sr_instance_id,     '
     ||'    deleted_flag )   '
     ||' SELECT  '
     ||'    ((a.resource_id * 2 ) +1 ), '
     ||'    a.mtl_organization_id, '
     ||'    a.seq_dep_id, '
     ||'    b.seq_dep_id, '
     ||'    0 setup_time, '
     ||'    0 penalty_factor, '
     ||'    :profile, '
     ||'    :instance1 , '
     ||'    2 '
     ||' FROM ( '
     ||' SELECT '
     ||' iwm.mtl_organization_id, '
     ||' s.category_id, '
     ||' s.seq_dep_id, '
     ||' o.oprn_id, '
     ||' rd.resource_id, '
     ||' count(o.oprn_id) OVER (PARTITION BY rd.orgn_code,s.category_id,rd.resource_id) CNT '
     ||' FROM '
     ||'     ic_whse_mst'||at_apps_link||' iwm, '
     ||'     sy_orgn_mst'||at_apps_link||' sy, '
     ||'     cr_rsrc_dtl'||at_apps_link||' rd, '
     ||'     gmp_sequence_types'||at_apps_link||' s, '
     ||'     gmd_operation_resources'||at_apps_link||' r, '
     ||'     gmd_operation_activities'||at_apps_link||' a, '
     ||'     gmd_operations'||at_apps_link||' o '
     ||' WHERE o.oprn_id = a.oprn_id '
     ||' AND a.oprn_line_id = r.oprn_line_id '
     ||' AND rd.orgn_code = sy.orgn_code '
     ||' AND sy.resource_whse_code = iwm.whse_code '
     ||' AND a.sequence_dependent_ind = 1 '
     ||' AND r.prim_rsrc_ind = 1 '
     ||' AND r.resources = rd.resources '
     ||' AND o.oprn_id = s.oprn_id ' ;
--     ||' AND iwm.mtl_organization_id in (1381,1382,1383,11159) '
     IF l_in_str_org  IS NOT NULL THEN
      Zero_tran := Zero_tran
      ||'   AND iwm.mtl_organization_id ' || l_in_str_org  ;
     END IF;
     Zero_tran := Zero_tran
     ||' UNION ALL '
     ||' SELECT '
     ||' rd.mtl_organization_id, '
     ||' s.category_id, '
     ||' s.seq_dep_id, '
     ||' o.oprn_id, '
     ||' rd.alt_resource_id, '
     ||' count(o.oprn_id) OVER (PARTITION BY rd.mtl_organization_id,s.category_id,rd.alt_resource_id) CNT '
     ||' FROM '
     ||'     gmp_sequence_types'||at_apps_link||' s, '
     ||'     gmd_operation_resources'||at_apps_link||' r, '
     ||'     gmd_operation_activities'||at_apps_link||' a, '
     ||'     gmd_operations'||at_apps_link||' o, '
     ||' (SELECT pcrd.resource_id prim_resource_id, '
     ||'         pcrd.resources prim_resources,  '
     ||'         acrd.resource_id alt_resource_id,  '
     ||'         acrd.resources alt_resources, '
     ||'         iwm.mtl_organization_id  '
     ||'                     FROM  ic_whse_mst'||at_apps_link||' iwm,  '
     ||'                           sy_orgn_mst'||at_apps_link||' sy,  '
     ||'                           cr_rsrc_dtl'||at_apps_link||' acrd,  '
     ||'                           cr_rsrc_dtl'||at_apps_link||' pcrd,  '
     ||'                           cr_ares_mst'||at_apps_link||' cam  '
     ||'                     WHERE cam.alternate_resource = acrd.resources  '
     ||'                       AND cam.primary_resource = pcrd.resources  '
     ||'                       AND acrd.orgn_code = pcrd.orgn_code  '
     ||'                       AND acrd.orgn_code = sy.orgn_code'
     ||'                       AND sy.resource_whse_code = iwm.whse_code  ' ;
--     ||'                       AND iwm.mtl_organization_id in (1381,1382,1383,11159) '
     IF l_in_str_org  IS NOT NULL THEN
        Zero_tran := Zero_tran
        ||'   AND iwm.mtl_organization_id ' || l_in_str_org  ;
     END IF;
     Zero_tran := Zero_tran
     ||'                       AND acrd.delete_mark = 0   '
     ||'                     ORDER BY pcrd.resource_id ) rd '
     ||' WHERE o.oprn_id = a.oprn_id '
     ||' AND a.oprn_line_id = r.oprn_line_id '
     ||' AND a.sequence_dependent_ind = 1 '
     ||' AND r.prim_rsrc_ind = 1 '
     ||' AND o.oprn_id = s.oprn_id '
     ||' AND r.resources = rd.prim_resources '
     ||' ) a, '
     ||' ( '
     ||' SELECT '
     ||' iwm.mtl_organization_id, '
     ||' s.category_id, '
     ||' s.seq_dep_id, '
     ||' o.oprn_id, '
     ||' rd.resource_id, '
     ||' count(o.oprn_id) OVER (PARTITION BY rd.orgn_code,s.category_id,rd.resource_id) CNT '
     ||' FROM '
     ||'     ic_whse_mst'||at_apps_link||' iwm, '
     ||'     sy_orgn_mst'||at_apps_link||' sy, '
     ||'     cr_rsrc_dtl'||at_apps_link||' rd, '
     ||'     gmp_sequence_types'||at_apps_link||' s, '
     ||'     gmd_operation_resources'||at_apps_link||' r, '
     ||'     gmd_operation_activities'||at_apps_link||' a, '
     ||'     gmd_operations'||at_apps_link||' o '
     ||' WHERE o.oprn_id = a.oprn_id '
     ||' AND a.oprn_line_id = r.oprn_line_id '
     ||' AND rd.orgn_code = sy.orgn_code '
     ||' AND sy.resource_whse_code = iwm.whse_code '
     ||' AND a.sequence_dependent_ind = 1 '
     ||' AND r.prim_rsrc_ind = 1 '
     ||' AND r.resources = rd.resources '
     ||' AND o.oprn_id = s.oprn_id ' ;
--     ||' AND iwm.mtl_organization_id in (1381,1382,1383,11159) '
     IF l_in_str_org  IS NOT NULL THEN
        Zero_tran := Zero_tran
        ||'   AND iwm.mtl_organization_id ' || l_in_str_org  ;
     END IF;
     Zero_tran := Zero_tran
     ||' UNION ALL '
     ||' SELECT '
     ||' rd.mtl_organization_id, '
     ||' s.category_id, '
     ||' s.seq_dep_id, '
     ||' o.oprn_id, '
     ||' rd.alt_resource_id, '
     ||' count(o.oprn_id) OVER (PARTITION BY rd.mtl_organization_id,s.category_id,rd.alt_resource_id) CNT '
     ||' FROM '
     ||'     gmp_sequence_types'||at_apps_link||' s, '
     ||'     gmd_operation_resources'||at_apps_link||' r, '
     ||'     gmd_operation_activities'||at_apps_link||' a, '
     ||'     gmd_operations'||at_apps_link||' o, '
     ||' (SELECT pcrd.resource_id prim_resource_id, '
     ||'         pcrd.resources prim_resources,  '
     ||'         acrd.resource_id alt_resource_id,  '
     ||'         acrd.resources alt_resources, '
     ||'         iwm.mtl_organization_id  '
     ||'                     FROM  ic_whse_mst'||at_apps_link||' iwm,  '
     ||'                           sy_orgn_mst'||at_apps_link||' sy,  '
     ||'                           cr_rsrc_dtl'||at_apps_link||' acrd,  '
     ||'                           cr_rsrc_dtl'||at_apps_link||' pcrd,  '
     ||'                           cr_ares_mst'||at_apps_link||' cam  '
     ||'                     WHERE cam.alternate_resource = acrd.resources  '
     ||'                       AND cam.primary_resource = pcrd.resources  '
     ||'                       AND acrd.orgn_code = sy.orgn_code  '
     ||'                       AND sy.resource_whse_code = iwm.whse_code  '
     ||'                       AND acrd.orgn_code = pcrd.orgn_code  ' ;
--     ||'                       AND iwm.mtl_organization_id in (1381,1382,1383,11159) '
     IF l_in_str_org  IS NOT NULL THEN
        Zero_tran := Zero_tran
        ||'   AND iwm.mtl_organization_id ' || l_in_str_org  ;
     END IF;

     Zero_tran := Zero_tran
     ||'                       AND acrd.delete_mark = 0   '
     ||'                     ORDER BY pcrd.resource_id ) rd '
     ||' WHERE o.oprn_id = a.oprn_id '
     ||' AND a.oprn_line_id = r.oprn_line_id '
     ||' AND a.sequence_dependent_ind = 1 '
     ||' AND r.prim_rsrc_ind = 1 '
     ||' AND o.oprn_id = s.oprn_id '
     ||' AND r.resources = rd.prim_resources '
     ||' ORDER BY 1,2,4,3 '
     ||' ) b '
     ||' WHERE a.mtl_organization_id = b.mtl_organization_id '
     ||'   AND a.category_id = b.category_id '
     ||'   AND a.resource_id = b.resource_id '
     ||'   AND a.cnt = b.cnt '
     ||'   AND a.seq_dep_id <> b.seq_dep_id '
     ||'   AND a.cnt > 1 ' ;

     IF l_in_str_org  IS NOT NULL THEN
        Zero_tran := Zero_tran
        ||' AND  a.mtl_organization_id ' || l_in_str_org  ;
     END IF;

     EXECUTE IMMEDIATE Zero_tran USING l_profile, b_instance_id ;
    -- Fact Transitions (Alternate Resources are considered)
     stmt_no := 920 ;
     Fact_tran := ' INSERT INTO msc_st_setup_transitions ( '
     ||'   resource_id, '
     ||'   organization_id, '
     ||'   from_setup_id, '
     ||'   to_setup_id, '
     ||'   transition_time, '
     ||'   transition_penalty, '
     ||'   transition_uom, '
     ||'   sr_instance_id, '
     ||'   deleted_flag ) '
     ||' SELECT unique  '
     ||'   b.resource_id, '
     ||'   b.organization_id, '
     ||'   a.from_seq_dep_id, '
     ||'   a.to_seq_dep_id, '
     ||'   a.setup_time, '
     ||'   a.penalty_factor, '
     ||'   b.uom_code, '
     ||'   b.sr_instance_id, '
     ||'   b.deleted_flag '
     ||' FROM gmp_sequence_dependencies'||at_apps_link||' a, '
     ||'     (select unique RESOURCE_ID, ORGANIZATION_ID,'
     ||'       setup_id , deleted_flag, sr_instance_id, uom_code '
     ||'   from msc_st_operation_resources '
     ||'      WHERE sr_instance_id = :instance1 '
     ||'   and setup_id is not null  ) b '
     ||' WHERE ( b.setup_id = a.from_seq_dep_id OR '
     ||'         b.setup_id = a.to_seq_dep_id ) '  ;
     IF l_in_str_org  IS NOT NULL THEN
        Fact_tran := Fact_tran
        ||'   AND b.organization_id ' || l_in_str_org  ;
     END IF;

     EXECUTE IMMEDIATE Fact_tran USING b_instance_id ;

   -- Resource Setups (Alternate Resources are considered)
   stmt_no := 930 ;
   rsrc_setup := ' INSERT INTO msc_st_resource_setups ( '
    ||'   resource_id,      '
    ||'   organization_id,  '
    ||'   sr_instance_id,   '
    ||'   setup_id,         '
    ||'   setup_code,       '
    ||'   setup_description,'
    ||'   deleted_flag   ) '
    ||'SELECT unique  '
    ||'   mst.resource_id, '
    ||'   mst.organization_id, '
    ||'   mst.sr_instance_id, '
    ||'   gst.SEQ_DEP_ID , '
    ||'   mc.CONCATENATED_SEGMENTS, '
    ||'   mc.CONCATENATED_SEGMENTS, '
    ||'   2 '
    ||' FROM gmp_sequence_types'||at_apps_link||' gst, '
    ||'     MTL_CATEGORIES_B_KFV'||at_apps_link||' mc, '
    ||'    ( SELECT unique mt.organization_id, mt.resource_id, '
    ||'      mt.transition_uom,mt.sr_instance_id, '
    ||'      mt.deleted_flag , mt.from_setup_id, mt.to_setup_id '
    ||'      FROM mtl_parameters'||at_apps_link|| ' mp, '
    ||'       msc_st_setup_transitions mt  '
    ||'      WHERE mp.organization_id = mt.organization_id AND '
    ||'       mp.process_enabled_flag = '|| ''''||'Y'||'''' ||' )  mst '
    ||' WHERE gst.oprn_id <> -1 '
    ||'  AND mc.category_id = gst.category_id  '
    ||'  AND mst.sr_instance_id = :instance1 '
    ||'  AND (gst.seq_dep_id = mst.from_setup_id OR '
    ||'       gst.seq_dep_id = mst.to_setup_id )  ' ;

    IF l_in_str_org  IS NOT NULL THEN
      rsrc_setup := rsrc_setup
      ||'     AND mst.organization_id ' || l_in_str_org  ;
    END IF;

       EXECUTE IMMEDIATE rsrc_setup USING b_instance_id ;

        return_status := TRUE ;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL ;
      return_status := TRUE ;
    WHEN OTHERS THEN
       log_message('Write setups and Transitions Exception: '||sqlerrm||'-'||stmt_no);
        return_status := FALSE ;

END write_setups_and_transitions ;

/*
REM+=========================================================================+
REM| PROCEDURE NAME                                                          |
REM|    write_step_dependency                                                |
REM|                                                                         |
REM| TYPE                                                                    |
REM|    Private                                                              |
REM|                                                                         |
REM| USAGE                                                                   |
REM|    This procedure inserts rows for step dependency                      |
REM|                                                                         |
REM| DESCRIPTION                                                             |
REM|                                                                         |
REM|                                                                         |
REM| INPUT PARAMETERS                                                        |
REM|    None                                                                 |
REM|                                                                         |
REM| OUTPUT PARAMETERS                                                       |
REM|    None                                                                 |
REM|                                                                         |
REM| INPUT/OUTPUT PARAMETERS                                                 |
REM|    None                                                                 |
REM|                                                                         |
REM| HISTORY                                                                 |
REM|  06/16/2004   Namit Singhi created                                      |
REM+=========================================================================+
*/

PROCEDURE write_step_dependency (
  p_x_aps_fmeff_id   IN NUMBER
)
IS

  stpdep_start_index   INTEGER;
  stpdep_end_index     INTEGER;
  dep_index            NUMBER ;

BEGIN

   dep_index := g_dep_index ;

/* Get index for Routing Step Dependency */
  stpdep_start_index :=
      rtg_org_hdr_tab(effectivity.rtg_hdr_location).stpdep_start_loc ;
  stpdep_end_index :=
      rtg_org_hdr_tab(effectivity.rtg_hdr_location).stpdep_end_loc ;

  IF ((stpdep_start_index > 0) AND (stpdep_end_index > 0) AND (stpdep_end_index >= stpdep_start_index)) THEN
      FOR stpdp_cnt IN stpdep_start_index..stpdep_end_index
      LOOP
          opr_stpdep_frm_seq_id(dep_index) :=  gmp_opr_stpdep_tbl(stpdp_cnt).x_dep_routingstep_id;
          opr_stpdep_to_seq_id(dep_index) :=  gmp_opr_stpdep_tbl(stpdp_cnt).x_routingstep_id;
          opr_stpdep_routing_sequence_id(dep_index) := p_x_aps_fmeff_id ;
          opr_stpdep_dependency_type(dep_index) := gmp_opr_stpdep_tbl(stpdp_cnt).dep_type;
          opr_stpdep_sr_instance_id(dep_index) := b_instance_id ;
          opr_stpdep_min_time_offset(dep_index) := gmp_opr_stpdep_tbl(stpdp_cnt).standard_delay;
          opr_stpdep_max_time_offset(dep_index) := gmp_opr_stpdep_tbl(stpdp_cnt).max_delay;
          opr_stpdep_trans_pct(dep_index) := gmp_opr_stpdep_tbl(stpdp_cnt).transfer_pct;
          opr_stpdep_frm_op_seq_num(dep_index) := gmp_opr_stpdep_tbl(stpdp_cnt).dep_routingstep_no;
          opr_stpdep_to_op_seq_num(dep_index) := gmp_opr_stpdep_tbl(stpdp_cnt).routingstep_no;
          opr_stpdep_app_to_chrg(dep_index) := gmp_opr_stpdep_tbl(stpdp_cnt).chargeable_ind;
          opr_stpdep_organization_id(dep_index) := effectivity.organization_id;
          dep_index := dep_index + 1;
      END LOOP;  /* Step Dependency loop */
  END IF;
    g_dep_index := dep_index ;

END write_step_dependency ;

/*
REM+=========================================================================+
REM| FUNCTION NAME                                                           |
REM|    enh_bsearch_stpno                                                    |
REM|                                                                         |
REM| TYPE                                                                    |
REM|    Private                                                              |
REM|                                                                         |
REM| USAGE                                                                   |
REM|    This function returns the location in mat_assoc_tab                  |
REM|    for given recipe, formula and formulaline_id                         |
REM|                                                                         |
REM| DESCRIPTION                                                             |
REM|                                                                         |
REM|                                                                         |
REM| INPUT PARAMETERS                                                        |
REM|    l_formula_id   IN NUMBER                                             |
REM|    l_recipe_id IN NUMBER                                                |
REM|    l_item_id IN NUMBER                                                  |
REM|                                                                         |
REM| OUTPUT PARAMETERS                                                       |
REM|    INTEGER - Location in mat_assoc_tab                                  |
REM|                                                                         |
REM| INPUT/OUTPUT PARAMETERS                                                 |
REM|    None                                                                 |
REM|                                                                         |
REM| HISTORY                                                                 |
REM|  06/16/2004   Namit Singhi created                                      |
REM+=========================================================================+
*/

FUNCTION enh_bsearch_stpno ( l_formula_id   IN NUMBER,
                             l_recipe_id    IN NUMBER,
                             l_item_id      IN NUMBER)
		RETURN INTEGER IS

top     INTEGER ;
bottom  INTEGER ;
mid     INTEGER ;
loop_direction NUMBER;
ret_loc     INTEGER ;
formula_start INTEGER ;

BEGIN
     top    := 1;
     bottom := material_assocs_size ;
     mid    := -1 ;
     ret_loc   := -1 ;
     loop_direction := 0;
     formula_start := -1;

   WHILE  (top <= bottom )
    LOOP
     mid := top + ( ( bottom - top ) / 2 );
--
     IF l_formula_id < mat_assoc_tab(mid).formula_id THEN
	bottom := mid - 1 ;
     ELSIF l_formula_id > mat_assoc_tab(mid).formula_id THEN
	top := mid + 1 ;
     ELSE
	ret_loc := mid ;
        EXIT;
     END IF ;
    END LOOP;

    IF ret_loc > 0 THEN
        IF ret_loc = 1 THEN
            formula_start := 1 ;
        ELSE  /* ret_loc > 1*/
        LOOP
            ret_loc := ret_loc - 1;
            IF ret_loc = 1 THEN
                formula_start := 1 ;
                EXIT;
            ELSIF mat_assoc_tab(ret_loc).formula_id <> l_formula_id THEN
                formula_start := ret_loc + 1;
                EXIT;
            END IF;
        END LOOP;
        END IF;
    ELSE
        RETURN -1 ;
    END IF;

    ret_loc := formula_start;

    WHILE(ret_loc <= material_assocs_size) LOOP
    IF(mat_assoc_tab(ret_loc).formula_id > l_formula_id) THEN
        RETURN -1;
    ELSIF mat_assoc_tab(ret_loc).recipe_id = l_recipe_id AND
    mat_assoc_tab(ret_loc).item_id = l_item_id THEN
        RETURN ret_loc;
    ELSE
        ret_loc := ret_loc + 1;
    END IF;
    END LOOP;

    RETURN -1;

EXCEPTION WHEN OTHERS THEN
   log_message(' Error in MSC_CL_GMP_UTILITY.enh_bsearch_stpno: '||SQLERRM);
   RETURN -1;
END enh_bsearch_stpno ;

/*
REM+=========================================================================+
REM| PROCEDURE NAME                                                          |
REM|    bsearch_unique                                                       |
REM|                                                                         |
REM| DESCRIPTION                                                             |
REM|    This procedure finds the unique setup id for the combination passed  |
REM|                                                                         |
REM| HISTORY                                                                 |
REM|  02/10/2006 B4918786 Rajesh Patangya Rewrite for SDS Enhancement        |
REM|                                                                         |
REM+=========================================================================+
*/
PROCEDURE bsearch_unique (p_resource_id   IN NUMBER ,
                          p_category_id   IN NUMBER ,
                          p_setup_id      OUT NOCOPY NUMBER
                         ) IS
i  INTEGER;
BEGIN
  i := 1 ;
   FOR i IN 1..SD_INDEX LOOP
     IF  (sds_tab(i).resource_id = p_resource_id) AND
         (sds_tab(i).category_id = p_category_id) THEN
             p_setup_id := sds_tab(i).setup_id ;
             EXIT ;
     ELSE
             p_setup_id := NULL ;
     END IF ;
   END LOOP;
EXCEPTION
   WHEN OTHERS THEN
   log_message('Error in bsearch_unique ' || sqlerrm);
   p_setup_id := NULL ;
END bsearch_unique ;

-- for future use
FUNCTION GMP_BOM_UTILITY1_R10
            (
                          p_dblink      IN VARCHAR2,
                          p_delimiter   IN VARCHAR2,
                          p_instance    IN INTEGER,
                          p_run_date    IN DATE,
                          p_num1        IN NUMBER,
                          p_num2        IN NUMBER,
                          p_num3        IN NUMBER,
                          p_num4        IN NUMBER,
                          p_varchar1    IN VARCHAR2,
                          p_varchar2    IN VARCHAR2,
                          p_varchar3    IN VARCHAR2,
                          p_varchar4    IN VARCHAR2
            ) RETURN INTEGER IS
BEGIN
    return 0;
END GMP_BOM_UTILITY1_R10;

FUNCTION GMP_BOM_UTILITY2_R10
            (
                          p_dblink      IN VARCHAR2,
                          p_delimiter   IN VARCHAR2,
                          p_instance    IN INTEGER,
                          p_run_date    IN DATE,
                          p_num1        IN NUMBER,
                          p_num2        IN NUMBER,
                          p_num3        IN NUMBER,
                          p_num4        IN NUMBER,
                          p_varchar1    IN VARCHAR2,
                          p_varchar2    IN VARCHAR2,
                          p_varchar3    IN VARCHAR2,
                          p_varchar4    IN VARCHAR2
            ) RETURN INTEGER IS
BEGIN
    return 0;
END GMP_BOM_UTILITY2_R10;

PROCEDURE GMP_BOM_PROC1_R10
            (
                          p_dblink      IN VARCHAR2,
                          p_delimiter   IN VARCHAR2,
                          p_instance    IN INTEGER,
                          p_run_date    IN DATE,
                          p_num1        IN NUMBER,
                          p_num2        IN NUMBER,
                          p_num3        IN NUMBER,
                          p_num4        IN NUMBER,
                          p_varchar1    IN VARCHAR2,
                          p_varchar2    IN VARCHAR2,
                          p_varchar3    IN VARCHAR2,
                          p_varchar4    IN VARCHAR2,
                          return_status  OUT NOCOPY BOOLEAN
            ) IS
BEGIN
    return_status := TRUE;
END GMP_BOM_PROC1_R10;

PROCEDURE GMP_BOM_PROC2_R10
            (
                          p_dblink      IN VARCHAR2,
                          p_delimiter   IN VARCHAR2,
                          p_instance    IN INTEGER,
                          p_run_date    IN DATE,
                          p_num1        IN NUMBER,
                          p_num2        IN NUMBER,
                          p_num3        IN NUMBER,
                          p_num4        IN NUMBER,
                          p_varchar1    IN VARCHAR2,
                          p_varchar2    IN VARCHAR2,
                          p_varchar3    IN VARCHAR2,
                          p_varchar4    IN VARCHAR2,
                          return_status  OUT NOCOPY BOOLEAN
              ) IS
BEGIN
    return_status := TRUE;
END GMP_BOM_PROC2_R10;

/*======================OPM BOM Package End ===================================*/

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

top         INTEGER ;
bottom      INTEGER ;
mid         INTEGER ;
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
  /*
      log_message(rsrc_tab(p_batch_loc).x_batch_id || ' -- ' ||
                  rsrc_tab(p_batch_loc).batchstep_id || ' -- ' ||
                  rsrc_tab(p_batch_loc).x_resource_id || ' -- ' ||
             rsrc_chg_loc || ' -- ' ||
             stp_chg_tbl(rsrc_chg_loc).wip_entity_id   || ' -- ' ||
      ((stp_chg_tbl(rsrc_chg_loc).operation_seq_id -1)/2) || ' --'||
             stp_chg_tbl(rsrc_chg_loc).resource_id );
*/
       IF (rsrc_tab(p_batch_loc).x_batch_id =
             stp_chg_tbl(rsrc_chg_loc).wip_entity_id) AND
          (rsrc_tab(p_batch_loc).batchstep_id =
             ((stp_chg_tbl(rsrc_chg_loc).operation_seq_id -1)/2)) AND
          (rsrc_tab(p_batch_loc).x_resource_id =
             stp_chg_tbl(rsrc_chg_loc).resource_id) THEN

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
*       IF  pprim_resource_id Found IN  prod_alt_rsrc_tab THEN
*         Return the first record location for pprim_resource_id in prod_alt_rsrc_tab.
*       ELSE IF pprim_resource_id NOT Found IN  prod_alt_rsrc_tab THEN
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
     bottom := alt_prod_size ;
     mid    := -1 ;
     ret_loc   := -1 ;

   WHILE  (top <= bottom )
    LOOP
     mid := top + ( ( bottom - top ) / 2 );

     IF pprim_resource_id < prod_alt_rsrc_tab(mid).prim_resource_id THEN
	bottom := mid -1 ;
     ELSIF pprim_resource_id > prod_alt_rsrc_tab(mid).prim_resource_id THEN
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
       IF pprim_resource_id <> prod_alt_rsrc_tab(ret_loc).prim_resource_id THEN
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
*   Sulipta 25-JAN-2006 B4612203 Populating supply_type as 1 in
*                                MSC_ST_RESOURCE_REQUIREMENTS table
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
  cur_alt_rsrc         gmp_cursor_typ; /* NAVIN :- Alternate Resource */
  cur_rs_intance       gmp_cursor_typ; /* NAVIN :- Resource Intance */
  c_chg_cursor         gmp_cursor_typ; /* NAVIN :- Resource Charges */
  rsrc_uoms_cur        gmp_cursor_typ; /* Sowmya - As per latest FDD Changes */
  uom_code_ref         gmp_cursor_typ; /* NAMIT - UOM Class */
  um_code_ref          gmp_cursor_typ; /* NAMIT - UOM Class */
  ic_code_ref          gmp_cursor_typ;
  bs_code_ref          gmp_cursor_typ;

  v_prod_cursor        VARCHAR2(32000) ;
  v_rsrc_cursor        VARCHAR2(32000) ;
  sql_stmt	       VARCHAR2(32000) ;
  uom_code_cursor      VARCHAR2(32000);
  um_code_cursor       VARCHAR2(32000);

  l_charges_remaining  NUMBER;
  res_whse             BOOLEAN ;
  res_whse_id          NUMBER ;
  supply_type          NUMBER ;
  old_batch_id         NUMBER;
  product_line         NUMBER ;
  opm_product_line     NUMBER ;
  prod_line_id         NUMBER ;
  prod_plant           VARCHAR2(4) ;
  order_no             VARCHAR2(37) ;
  v_inflate_wip        NUMBER ;
  found_mtl            NUMBER ;
  i                    NUMBER ;
  old_step_no          NUMBER ;
  prod_count           NUMBER ;
  resource_count       NUMBER ;
  stp_chg_count        NUMBER ;
  /* B1224660 added locals to develop resource sequence numbers */
  v_resource_usage     NUMBER ;
  v_res_seq            NUMBER ;
  v_schedule_flag      NUMBER ;
  v_parent_seq_num     NUMBER ;
  v_seq_dep_usage      NUMBER ; /* NAVIN :- Sequence Dependency */
  found_chrg_rsrc      NUMBER ; /* NAVIN :- Chargeable Resource */
  chrg_activity        NUMBER ; /* NAVIN :- Chargeable Activity */
  v_rsrc_cnt           NUMBER ;
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
  v_max_rsrcs          NUMBER; --for collecting the max resources
  v_activity_group_id  NUMBER ;   /* B3995361 rpatangy */
  mk_alt_grp           NUMBER ;   /* B3995361 rpatangy */

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
  l_res_inst_process   := 0;
  v_max_rsrcs          := 0;

  IF return_status THEN
    v_cp_enabled := TRUE;
  ELSE
    v_cp_enabled := FALSE;
  END IF;

    /* populate the org_string */
   IF MSC_CL_GMP_UTILITY.org_string(pinstance_id) THEN
        NULL ;
     ELSE
        RAISE invalid_string_value  ;
     END IF;

    /* Disable Formula Security Functionality */

  v_sql_stmt := 'BEGIN '
    || ' gmd_p_fs_context.set_additional_attr' || pdblink
    || ';END;'   ;
  EXECUTE IMMEDIATE v_sql_stmt ;


  /* Get the profile value for inflating usage by the utilization and
     efficiency */
  IF NVL(fnd_profile.value('MSC_INFLATE_WIP') ,'N')= 'N' THEN
    v_inflate_wip := 0 ;
  ELSE
    v_inflate_wip := 1 ;
  END IF;

/* NAMIT UOM Change, This should come from source */
    um_code_cursor   := ' select fnd_profile.VALUE' ||pdblink
                      ||' (''SY$UOM_HOURS'') from dual ' ; /* OPM UOM */

       OPEN um_code_ref FOR um_code_cursor ;
       FETCH um_code_ref INTO l_gmp_um_code;
       CLOSE um_code_ref;

  IF l_gmp_um_code IS NOT NULL THEN
/* Get the UOM code and UOM Class corresponding to "GMP: UOM for Hour" Profile */
     uom_code_cursor :=
                      ' select um_type '
                      ||' from sy_uoms_mst'||pdblink
                      ||' where um_code = :gmp_um_code ';

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

  /* Bug 4774975 -- FRUTAROM INDUSTRIES LTD, org string check should be
     removed so that all the supplies and demand belongs to other warehouse
     should be sent to APS in resource warehouse */

  v_prod_cursor := 'SELECT'
      || '   h.batch_no,'
      || '   h.plant_code,'
      || '   h.batch_id,'
      || '   ((h.batch_id * 2) + 1), '
      || '   h.wip_whse_code,'
      || '   iwm.mtl_organization_id, '
      || '   h.routing_id,'
      || '   h.plan_start_date, '
      || '   h.plan_cmplt_date end_date,'
      || '   DECODE(d.line_type,-1,MIN(t.trans_date),MAX(t.trans_date)),'
      || '   h.batch_status,'
      || '   h.batch_type,'
      || '   i.organization_id,'
      || '   t.whse_code,'
      || '   i.aps_item_id,'
      || '   d.material_detail_id,'
      || '   d.line_no  ,'     /* B2919303 */
      || ' DECODE(d.item_id ,v.item_id,0,d.line_no) t_line_no,' /* B2953953 */
      || '   d.line_type,'
      || ' DECODE(d.line_type,1,3,d.line_type) t_line_type,' /* B2953953 */
      || '   SUM(t.trans_qty),'
      || '   d.item_id  matl_item_id,'
      || '   v.item_id  recipe_item_id, '
      || '   h.poc_ind,   '
      || '   DECODE(h.firmed_ind,1,1,2), '
      || '   decode(d.release_type,0, -1, nvl(gbs.batchstep_no,-1)) batchstep_no,'
      || '   d.plan_qty, '
      || '   DECODE(d.item_um, i.item_um, 1, '
      || '     GMICUOM.uom_conversion'||pdblink
      || '       (d.item_id, 0, 1, d.item_um, i.item_um, 0)), ' /* NAVIN: Get UOM
                                        conversion factor for unit qty */
      || '   h.due_date,'
      || '   h.order_priority,'
      ||'   ((gbsi.batchstep_id*2)+1) from_op_seq_id, '     /* B5461922 */
      || '   DECODE(d.line_type,1,gbsi.minimum_transfer_qty, NULL) t_minimum_transfer_qty,'
      || '   DECODE(d.line_type,1,gbsi.minimum_delay, NULL) t_minimum_delay, '
      || '   DECODE(d.line_type,1,gbsi.maximum_delay, NULL) t_maximum_delay,'
      || '   gbs.batchstep_no'
      || ' FROM'
      || '   gme_batch_header'||pdblink||' h,'
      || '   gme_material_details'||pdblink||' d,'
      || '   gme_batch_step_items'||pdblink||' gbsi,'  /* 2919303 */
      || '   gme_batch_steps'||pdblink||' gbs,'       /* 2919303 */
      || '   gmd_recipe_validity_rules'||pdblink||' v,'
      || '   ic_whse_mst'||pdblink||' iwm,'
      || '   ic_tran_pnd'||pdblink||' t,'
      || '   gmp_item_aps'||pdblink||' i'
      || ' WHERE'
      || '     h.batch_id = d.batch_id'
      || '   AND h.recipe_validity_rule_id = v.recipe_validity_rule_id'
      || '   AND EXISTS (SELECT '
      || '                 1  '
      || '               FROM '
      || '                 gme_material_details'||pdblink||' gmd '
      || '               WHERE '
      || '                     gmd.batch_id = h.batch_id '
      || '                 AND gmd.item_id = v.item_id) '
      || '   AND h.wip_whse_code = iwm.whse_code'
      || '   AND h.batch_id = t.doc_id'
      || '   AND ((h.batch_type = 0 and t.doc_type = :p1) OR'
      || '        (h.batch_type = 10 and t.doc_type = :p2))'
      || '   AND d.material_detail_id = gbsi.material_detail_id (+)' /* 2919303 */
      || '   AND d.batch_id = gbsi.batch_id (+)  '      /* 2919303 */
      || '   AND gbsi.batch_id = gbs.batch_id (+) '       /* 2919303 */
      || '   AND gbsi.batchstep_id  = gbs.batchstep_id (+)'    /* 2919303 */
      || '   AND d.material_detail_id = t.line_id'
      || '   AND t.item_id = i.item_id'
      || '   AND t.whse_code = i.whse_code'
      || '   AND t.orgn_code = i.plant_code'
      || '   AND h.batch_status in (1, 2)'
      || '   AND t.completed_ind = 0'
      || '   AND t.delete_mark = 0'
  -- B3721336 Rajesh Patangya If product is 100% Yeiled, But steps are pending
  --  || '   AND t.trans_qty <> 0'
      || ' GROUP BY'
      || '   h.batch_no,'
      || '   h.plant_code,'
      || '   h.batch_id,'
      || '   h.wip_whse_code,'
      || '   iwm.mtl_organization_id, '
      || '   h.routing_id,'
      || '   h.plan_start_date,'
      || '   h.plan_cmplt_date,'
      || '   v.item_id,'
      || '   h.poc_ind,'
      || '   h.firmed_ind,'
      || '   decode(d.release_type, 0, -1, nvl(gbs.batchstep_no,-1)),' /*2919303*/
      || '   d.item_id,'
      || '   h.batch_status,'
      || '   h.batch_type,'
      || '   i.organization_id,'
      || '   t.whse_code,'
      || '   i.aps_item_id,'
      || '   d.material_detail_id,'
      || '   d.line_no,'
      || '   d.line_type,'
      /* NAVIN:  Added following columns in group by as these are newly added in the select clouse.*/
      || '   d.plan_qty, '
      || '   DECODE(d.item_um, i.item_um, 1, GMICUOM.uom_conversion' || pdblink
      || '       (d.item_id, 0, 1, d.item_um, i.item_um, 0)), '
      || '   h.due_date,'
      || '   h.order_priority,'
      || '   gbsi.batchstep_id,'
      || '   DECODE(d.line_type,1,gbsi.minimum_transfer_qty, NULL) ,'
      || '   DECODE(d.line_type,1,gbsi.minimum_delay, NULL), '
      || '   DECODE(d.line_type,1,gbsi.maximum_delay, NULL),'
      || '   gbs.batchstep_no'
      || ' ORDER BY h.batch_id ,t_line_type DESC ,t_line_no , '
      || '   DECODE(d.line_type,-1,MIN(t.trans_date),MAX(t.trans_date)) DESC ';

    OPEN c_prod_dtl FOR v_prod_cursor USING v_doc_prod, v_doc_fpo;
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
      || ' ((gri.instance_id * 2) + 1) , '  /* SOWMYA - Resources Instances */
      || ' NVL(t.sequence_dependent_ind,0), '
      || ' gs.plan_start_date,'
      || ' h.plant_code,'
      -- || ' o.activity,'			/* NAVIN: Remove this column. */
      || ' gs.prim_rsrc_ind,'
      || ' c.resource_id,'
      || ' ((c.resource_id * 2) + 1),'
      || ' gs.plan_rsrc_count,'
      || ' gs.actual_rsrc_count,'
      || ' gs.actual_start_date,'
      || ' gs.plan_cmplt_date,'
      || ' gs.actual_cmplt_date,'
--      || ' DECODE(r.step_status,2,1,NULL), '
      || ' r.step_status, '  /* B3995361 */
      || ' SUM(t.resource_usage) OVER (PARTITION BY t.doc_id, t.resources, t.line_id) resource_usage, '  -- summarized usage for the step resource
      || ' SUM(t.resource_usage) OVER (PARTITION BY t.doc_id, t.resources, t.line_id, t.instance_id) resource_instance_usage, ' -- summarized usage for the step resource instances
      || ' nvl(gri.eqp_serial_number,to_char(gri.instance_number)), '  /* SOWMYA - As Per latest FDD changes - Resources Instances */
      || ' DECODE(gs.scale_type,0,2,1,1,2,3), '
      || ' c.capacity_constraint , '
      || ' r.plan_step_qty, '
      || ' NVL(r.minimum_transfer_qty,-1), '
      || ' NVL(o.material_ind,0), '
      || ' 1 schedule_flag, '
       --  || ' o.offset_interval, '	/* NAVIN: Remove this column. */
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
      || ' gs.actual_rsrc_usage,'
      || ' r.batchstep_id,'    /* Navin 6/23/2004 Added for resource charges*/
      || '  SUM(NVL(o.material_ind,0))  OVER (PARTITION BY '
      || '  o.batch_id, r.batchstep_id) mat_found, '
   -- OPM break_ind values 0 and NULL maps to value 2 of MSC breakable_activity_flag
   -- and 1 maps with 1.
      || ' DECODE(NVL(o.break_ind,0), 1, 1, 2) breakable_activity_flag , '
      || ' uom.uom_code ,'
      || ' uom2.uom_code ,'
      || ' gri.equipment_item_id ,' /* SOWMYA - As Per latest FDD changes */
      || ' gs.plan_rsrc_count gmd_rsrc_count,' /*passed on msc_st_resource_requirements*/
      || ' r.plan_start_date, ' /* populate msc_st_job_operations.reco_start_date */
      || ' r.plan_cmplt_date, ' /* populate msc_st_job_operations.reco_completion_date */
      || ' NVL(c.efficiency,100) ' /*B4320561 - If null then resource is 100%efficient */
      || ' FROM'
      || ' mtl_units_of_measure'||pdblink||' uom, '
      || ' mtl_units_of_measure'||pdblink||' uom2, '
      || ' gme_batch_header'||pdblink||' h,'
      || ' gme_batch_steps'||pdblink||' r,'
      || ' gme_batch_step_activities'||pdblink||' o,'
      || ' gme_batch_step_resources'||pdblink||' gs,'
      || ' gme_resource_txns'||pdblink||' t , '
      || ' gmp_resource_instances'||pdblink||' gri, '
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
      || ' AND c.orgn_code = h.plant_code '
      || ' AND c.resources = gs.resources'
/*B4313202 COLLECTING DATA FOR COMPLETED OPERATIONS:Included a chk for step status = 3*/
      || ' AND r.step_status in (1, 2, 3)'
      || ' AND c.Schedule_Ind <> 3 ' /* NAVIN:  gs.prim_rsrc_ind in (1,2) */
      || ' AND uom.uom_class = :gmp_uom_class '
      || ' AND uom.unit_of_measure = gs.usage_uom '
      || ' AND uom2.unit_of_measure = r.step_qty_uom '
      || ' AND c.delete_mark = 0 '
      || ' AND nvl(c.inactive_ind,0) = 0 ' ;

      IF MSC_CL_GMP_UTILITY.g_in_str_org  IS NOT NULL THEN
         v_rsrc_cursor := v_rsrc_cursor
           ||' AND EXISTS ( SELECT 1 FROM sy_orgn_mst'||pdblink||' som '
           ||' WHERE h.wip_whse_code = som.resource_whse_code )' ;
      END IF;

      v_rsrc_cursor := v_rsrc_cursor
        || ' ORDER BY '
        ||'         1,2,3,4,5,6,7,8 DESC,9';	/* NAVIN: converted to position notation in Order By*/

--      || ' ORDER BY '
--      || '   h.batch_id,'
--      || '   ((r.batch_id * 2) + 1), '
--      || '   r.batchstep_no, '
--      || '   NVL(o.sequence_dependent_ind,0) DESC,'
--      || '   o.offset_interval, '
--      || '   o.activity,  '
--      || '   o.batchstep_activity_id, '
--      || '   gs.prim_rsrc_ind,'
--      || '   gs.resources,'
--      || '   NVL(t.sequence_dependent_ind,0) DESC, '
--      || '   gs.plan_start_date';

      /* RAJESH PATANGYA open and fetch all the batch details  */
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

      -- Get all the Operation Charges for the batch step
      -- NAVIN: START Operation Charges Data needs to be transferred to APS in to Msc_st_resource_charges
      stp_chg_cursor:=
        ' SELECT '
      ||' ((gbsc.batch_id*2)+1) x_batch_id,'
      ||' ((gbsc.batchstep_id*2)+1),'       /* B5461922 */
      || ' ((crd.resource_id * 2) + 1),'
      ||' gbsc.charge_number,'
      ||' iwm.mtl_organization_id,'
      ||' gbs.batchstep_no,'
      ||' gbsc.activity_sequence_number,'
      ||' gbsc.charge_quantity, '
      ||' gbsc.plan_start_date, '
      ||' gbsc.plan_cmplt_date'
      ||' FROM'
      ||' gme_batch_step_charges'||pdblink||' gbsc,'
      ||' cr_rsrc_dtl'||pdblink||' crd,'
      ||' ic_whse_mst'||pdblink||' iwm,'
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
      ||'               AND gmd.item_id = v.item_id) '
      ||' AND crd.resources = gbsc.resources '
      ||' AND h.wip_whse_code = iwm.whse_code'
      ||' AND gbs.step_status in (1, 2) ';

      IF MSC_CL_GMP_UTILITY.g_in_str_org  IS NOT NULL THEN
	   stp_chg_cursor := stp_chg_cursor
          ||'   AND EXISTS ( SELECT 1 FROM sy_orgn_mst'||pdblink||' som '
          ||'   WHERE  h.wip_whse_code = som.resource_whse_code )' ;
      END IF;

      stp_chg_cursor := stp_chg_cursor
            ||' ORDER BY 1, 2, 3, 4 ' ;

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

      -- NAVIN: END Operation Charges Data needs to be transferred to APS in to Msc_st_resource_charges

     /* NAVIN :- alternate resource */
     /* NAVIN: In Procedure production_orders just before starting the looping for prod_dtl cursor
     try to get all the alternate Resources.*/

     /* Alternate Resource selection   */
     /* B5688153, Rajesh Patangya prod spec alt*/
     /* B5879844  Uday Phadtare replaced at_apps_link with pdblink for prod */
        statement_alt_resource :=
                     ' SELECT pcrd.resource_id, acrd.resource_id, '
                   ||' cam.runtime_factor, '
/*prod spec alt*/  ||' nvl(cam.preference,-1), nvl(prod.item_id,-1)   '
                   ||' FROM  cr_rsrc_dtl'||pdblink||' acrd, '
                   ||'       cr_rsrc_dtl'||pdblink||' pcrd, '
                   ||'       cr_ares_mst'||pdblink||' cam, '
                   ||'       gmp_altresource_products'||pdblink||' prod'
                   ||' WHERE cam.alternate_resource = acrd.resources '
                   ||'   AND cam.primary_resource = pcrd.resources '
                   ||'   AND acrd.orgn_code = pcrd.orgn_code '
                   ||'   AND cam.primary_resource = prod.primary_resource(+) '
                   ||'   AND cam.alternate_resource = prod.alternate_resource(+) '
                   ||'   AND acrd.delete_mark = 0  '
                   ||' ORDER BY pcrd.resource_id, '
                   ||' DECODE(cam.preference,NULL,cam.runtime_factor,cam.preference),'
                   ||'   prod.item_id ' ;

     -- Retrive the Details of all the Alternate Resources.
     alt_prod_size := 1;
     OPEN cur_alt_rsrc FOR statement_alt_resource ;
     LOOP
         FETCH cur_alt_rsrc INTO prod_alt_rsrc_tab(alt_prod_size);
         EXIT WHEN cur_alt_rsrc%NOTFOUND;
         alt_prod_size := alt_prod_size + 1;
     END LOOP;
     CLOSE cur_alt_rsrc;
     alt_prod_size := alt_prod_size -1 ;
     log_message('Production alternate resource size is = '|| to_char(alt_prod_size) );

    old_batch_id := -1;
    p := 1 ;
    FOR p IN 1..gprod_size LOOP  /* Batch loop starts */

    /* Multiply plan_qty with UOM conv factor. Factor will be 1 when the
    plan_qty and primary UOM is same. */

    prod_tab(p).matl_qty := prod_tab(p).matl_qty * prod_tab(p).uom_conv_factor;
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

      IF prod_tab(p).plant_code = prod_plant THEN
         IF (res_whse) THEN
           v_orgn_id := res_whse_id;
         ELSE
           v_orgn_id := prod_tab(p).mtl_org_id;
         END IF;
      ELSE
        prod_plant := prod_tab(p).plant_code;

     /* Bug 4774975 --  Rajesh Patangya starts */
        v_sql_stmt :=
             'SELECT '
          || ' iwm.mtl_organization_id '
          || 'FROM '
          || '  sy_orgn_mst' ||pdblink|| ' sy, '
          || '  ic_whse_mst' ||pdblink|| ' iwm '
          || 'WHERE '
          || '  sy.orgn_code = :p1'
          || '  AND sy.resource_whse_code = iwm.whse_code';

     /* Bug 4774975 --  Rajesh Patangya End */

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

      END IF;  /* for Plant code */
    END IF;   /* Batch Changes */

    IF ( prod_tab(p).matl_item_id = prod_tab(p).recipe_item_id) AND (product_line = -1) THEN

      product_line := prod_tab(p).item_id;  /* APS Item Identifier for Product */
      opm_product_line := prod_tab(p).recipe_item_id;  /* OPM Item Identifier for Product */
      prod_line_id := prod_tab(p).line_id;
      old_step_no := -1;
      i := 1;

      IF prod_tab(p).routing_id IS NOT NULL AND NVL(prod_tab(p).poc_ind, 'N') = 'Y'  AND
         (res_whse) THEN

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
               /* NAVIN :- */
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
                 /* NAVIN :- */
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
                 jo_minimum_transfer_quantity(jo_index) := prod_tab(p).minimum_transfer_qty;

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

                   IF rsrc_tab(r).scale_type = 3 AND found_chrg_rsrc = 1 THEN
-- APS decoded value as per DECODE(rsrc_tab(r).scale_type,0,2,1,1,2,3);
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
                       rr_opr_hours_required(rr_index) :=  v_resource_usage ;
       /* Bug 4431718 populate usage_rate column starts */
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
       /* Bug 4431718 populate usage_rate column Ends */

                       rr_assigned_units(rr_index) := v_rsrc_cnt ;
                       rr_department_id(rr_index) := ((v_orgn_id * 2) + 1) ;  /* B1177070 encoded key */
                       rr_wip_entity_id(rr_index) :=  rsrc_tab(r).x_batch_id ; /* B1177070 encoded key */
                       /* B1224660 write the step number for oper seq num */
                       rr_operation_seq_num(rr_index)  :=   rsrc_tab(r).batchstep_no ;
                      /* B3995361 */
                       IF rsrc_tab(r).step_status = 2 THEN
                          rr_firm_flag(rr_index) :=   7 ;
                       ELSE
                          rr_firm_flag(rr_index) :=    rsrc_tab(r).firm_type ;
                       END IF;
--                       rr_firm_flag(rr_index) :=    rsrc_tab(r).firm_type ;
                       rr_minimum_transfer_quantity(rr_index) := 0 ;
                       rr_parent_seq_num(rr_index) := TO_NUMBER(NULL) ;
                       rr_schedule_flag(rr_index) := rsrc_tab(r).schedule_flag ;
                   -- HW B4902328 - Added inventory_item_id
                       rr_inventory_item_id(rr_index) := product_line;
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
                       /* Sowmya - As per the latest FDD changes - Start */
                       rr_plan_step_qty(rr_index) := rsrc_tab(r).plan_step_qty ;
                       rr_step_qty_uom(rr_index) := rsrc_tab(r).step_qty_uom ;
                       rr_gmd_rsrc_cnt(rr_index) := v_max_rsrcs;
                       /* Sowmya - As per the latest FDD changes - End */

                       /* B3995361 rpatangy */
                       rr_activity_group_id(rr_index) := v_activity_group_id ;
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
                                /*Pass on the alternate resource data when the batch step is not in WIP status*/
                                IF ( rsrc_tab(r).firm_type <> 3 ) AND ( rsrc_tab(r).firm_type <> 5 ) AND ( rsrc_tab(r).firm_type <> 6 ) AND ( rsrc_tab(r).firm_type <> 7 ) THEN
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
                                   FOR alt_cnt IN alternate_rsrc_loc..alt_prod_size
                                   LOOP
     /* B5688153, Rajesh Patangya prod spec alt*/
                                       IF ( prod_alt_rsrc_tab(alt_cnt).prim_resource_id =
                                            rsrc_tab(r).resource_id
                                       AND (prod_alt_rsrc_tab(alt_cnt).item_id = -1 OR
                                            prod_alt_rsrc_tab(alt_cnt).item_id = opm_product_line )) THEN
                           --          IF ( prod_alt_rsrc_tab(alt_cnt).prim_resource_id = rsrc_tab(r).resource_id ) THEN
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
                                         /* B1224660 write the step number for oper seq num */
                                         arr_operation_seq_num(arr_index) :=
                                                        rsrc_tab(r).batchstep_no ;
                                         arr_setup_id(arr_index) :=
                                                        rsrc_tab(r).setup_id ;
                                         arr_schedule_seq_num(arr_index) :=
                                                        rsrc_tab(r).seq_dep_ind;
                                         arr_maximum_assigned_units(arr_index) :=
                                                        v_max_rsrcs;
                                         arr_activity_group_id(arr_index) :=
                                ((prod_alt_rsrc_tab(alt_cnt).alt_resource_id * 2) + 1);
                                         arr_basis_type(arr_index):=
                                                        rsrc_tab(r).scale_type;
                                         arr_resource_id(arr_index) :=
                                ((prod_alt_rsrc_tab(alt_cnt).alt_resource_id * 2) + 1) ;
                                         arr_usage_rate(arr_index) := v_resource_usage
                                            * prod_alt_rsrc_tab(alt_cnt).runtime_factor;
                                         arr_alternate_num(arr_index) := v_alternate ;
                                         arr_uom_code(arr_index) :=
                                                        rsrc_tab(r).usage_uom;
                --                       arr_gmd_rsrc_cnt(rr_index) := v_max_rsrcs;
                                       ELSIF ( prod_alt_rsrc_tab(alt_cnt).prim_resource_id > rsrc_tab(r).resource_id ) THEN
                                           EXIT ;
                                       END IF;  /* End if for alternate resource and orgn code match */
                                   END LOOP;  /* Alternate loop */
                                END IF; /* Batch resources not firmed */
                                END IF;/* Batch Step not in WIP */
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
                         FOR alt_cnt IN alternate_rsrc_loc..alt_prod_size
                          LOOP
                          IF prod_alt_rsrc_tab(alt_cnt).prim_resource_id =
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
                                   ((prod_alt_rsrc_tab(alt_cnt).alt_resource_id * 2) + 1);
                           arr_basis_type(arr_index):= rsrc_tab(r).scale_type;
                           arr_usage_rate(arr_index) := v_resource_usage ;
                           arr_alternate_num(arr_index) := mk_alt_grp ;
                           arr_uom_code(arr_index) := rsrc_tab(r).usage_uom;
                          ELSIF prod_alt_rsrc_tab(alt_cnt).prim_resource_id >
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
                         rr_opr_hours_required(rr_index) :=  rsrc_tab(r).sequence_dependent_usage; -- * converted_usage;
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
                   -- HW B4902328 - Added inventory_item_id
                         rr_inventory_item_id(rr_index) := product_line;
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

        IF prod_tab(p).item_id <> product_line THEN

             /* Demands Bulk inserts */
                d_index := d_index + 1 ;
                d_organization_id(d_index) := v_orgn_id ;
                d_inventory_item_id(d_index) :=  prod_tab(p).item_id ;
                d_sr_instance_id(d_index) :=  pinstance_id ;
                d_assembly_item_id(d_index) := product_line ;
                d_demand_date(d_index) := prod_tab(p).trans_date ;
                /* Reverse sign to make positive */
                d_requirement_quantity(d_index) := (prod_tab(p).qty * -1);
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

           /* Supply Bulk Insert Assignments */
                s_index := s_index + 1 ;
                s_inventory_item_id(s_index) := prod_tab(p).item_id ;
                s_organization_id(s_index)   := v_orgn_id ;
                s_sr_instance_id(s_index)    := pinstance_id;
                s_new_schedule_date(s_index) :=  prod_tab(p).trans_date ;
                s_old_schedule_date(s_index)       := prod_tab(p).trans_date ;
                s_new_wip_start_date(s_index) := prod_tab(p).start_date ;
                s_old_wip_start_date(s_index) := prod_tab(p).start_date ;
                s_lunit_completion_date(s_index) := prod_tab(p).end_date ;
                /* B1177070 encoded key */
                s_disposition_id(s_index)    :=  prod_tab(p).x_batch_id ;

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
	          stp_var_itm_FROM_item_ID(si_index) := prod_tab(p).item_id;
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

     i := 1 ;
     log_message(rr_organization_id.FIRST || ' *rr*' || rr_organization_id.LAST );
     IF rr_organization_id.FIRST > 0 THEN
     FORALL i IN rr_organization_id.FIRST..rr_organization_id.LAST
        INSERT INTO msc_st_resource_requirements (
		organization_id,
		sr_instance_id,
		supply_id,
                supply_type, /* sultripa B4612203 Need to populate supply_type field */
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
            -- HW B4902328 - Added inventory_item_id
                inventory_item_id,
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
                step_quantity,    /* Sowmya - As per latest FDD changes*/
                step_quantity_uom , /* Sowmya - As per latest FDD changes*/
                maximum_assigned_units, /* Sowmya - As per latest FDD changes*/
                unadjusted_resource_hours, /*B4320561 - Same as in wip (without eff and util) */
                touch_time, /* B4320561 - Unadjusted res. hrs / efficiency.*/
                activity_group_id, /* B3995361 rpatangy */
                operation_sequence_id /* B5461922 rpatangy */
	)
        VALUES (
		rr_organization_id(i),
		rr_sr_instance_id(i),
		rr_supply_id(i),
                1, /* sultripa B4612203 supply_type = 1 for OPM batches*/
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
            -- HW B4902328 - Added inventory_item_id
                rr_inventory_item_id(i),
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
                rr_plan_step_qty(i),  /* Sowmya - As per the latest FDD changes*/
                rr_step_qty_uom(i) , /* Sowmya - As per the latest FDD changes*/
                rr_gmd_rsrc_cnt(i),
                rr_unadjusted_resource_hrs(i), /*B4320561 - sowsubra*/
                rr_touch_time(i), /*B4320561 - sowsubra*/
                rr_activity_group_id(i),  /* B3995361 rpatangy */
                rr_operation_sequence_id(i) /* B5461922 rpatangy */
        )   ;

     END IF;

/* akaruppa B5007729 */
        rr_organization_id   := empty_num_table ;
        rr_inventory_item_id := empty_num_table ;
        rr_sr_instance_id    := empty_num_table ;
        rr_supply_id         := empty_num_table ;
        rr_resource_seq_num  := empty_num_table ;
        rr_resource_id       := empty_num_table ;
        rr_start_date        := empty_dat_table ;
        rr_end_date          := empty_dat_table ;
        rr_opr_hours_required := empty_num_table ;
        rr_usage_rate        := empty_num_table ;
        rr_assigned_units    := empty_num_table ;
        rr_department_id     := empty_num_table ;
        rr_wip_entity_id     := empty_num_table ;
        rr_operation_seq_num := empty_num_table ;
        rr_firm_flag         := empty_num_table ;
        rr_minimum_transfer_quantity   := empty_num_table ;
        rr_parent_seq_num    := empty_num_table ;
        rr_schedule_flag     := empty_num_table ;
        rr_basis_type        := empty_num_table ;
        rr_setup_id          := empty_num_table ;
        rr_sequence_id       := empty_num_table ;
        rr_sequence_number   := empty_num_table ;
        rr_min_capacity      := empty_num_table ;
        rr_max_capacity      := empty_num_table ;
        rr_original_seq_num  := empty_num_table ;
        rr_alternate_number  := empty_num_table ;
        rr_hours_expended    := empty_num_table ;
        rr_breakable_activity_flag := empty_num_table ;
        rr_plan_step_qty     := empty_num_table ;
        rr_step_qty_uom      := rr_step_qty_uom ;
        rr_gmd_rsrc_cnt      := empty_num_table ;
        rr_unadjusted_resource_hrs  := empty_num_table;
        rr_touch_time           := empty_num_table  ;
        rr_activity_group_id    := empty_num_table ;
        rr_operation_sequence_id := empty_num_table ; /* B5461922 rpatangy */
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
        schedule_priority
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
        s_schedule_priority(i)
        ) ;
      END IF;

        s_inventory_item_id  := empty_num_table ;
        s_organization_id    := empty_num_table ;
        s_sr_instance_id     := empty_num_table ;
        s_new_schedule_date  := empty_dat_table ;
        s_old_schedule_date  := empty_dat_table ;
        s_new_wip_start_date := empty_dat_table ;
        s_old_wip_start_date := empty_dat_table ;
        s_lunit_completion_date  := empty_dat_table ;
        s_disposition_id      := empty_num_table ;
        s_order_type          := empty_num_table ;
        s_order_number        := se_order_number ;
        s_new_order_quantity  := empty_num_table ;
        s_old_order_quantity  := empty_num_table ;
        s_firm_planned_type   := empty_num_table ;
        s_firm_quantity       := empty_num_table ;
        s_firm_date           := empty_dat_table ;
        s_wip_entity_name     := se_wip_entity_name ;
        s_operation_seq_num   := empty_num_table ;
        s_by_product_using_assy_id  := empty_num_table ;
        s_lot_number          := e_lot_number;
        s_wip_status_code     := empty_num_table;
        s_requested_completion_date := empty_dat_table ;

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
      END IF;

/* akaruppa B5007729 starts*/
        d_organization_id    := empty_num_table ;
        d_inventory_item_id  := empty_num_table ;
        d_sr_instance_id     := empty_num_table ;
        d_assembly_item_id   := empty_num_table ;
        d_demand_date        := empty_dat_table ;
        d_requirement_quantity  := empty_num_table ;
        d_demand_type      := empty_num_table ;
        d_origination_type := empty_num_table ;
        d_wip_entity_id    := empty_num_table ;
        d_demand_schedule  := e_demand_schedule ;
        d_order_number     := e_order_number ;
        d_wip_entity_name  := e_wip_entity_name ;
        d_selling_price    := empty_num_table ;
        d_wip_status_code  := empty_num_table;
        d_operation_seq_num := empty_num_table ;
/* akaruppa B5007729 End*/


      s_index := 0 ;
      d_index := 0 ;
      rr_index := 0 ;

/* NAVIN: -- START: Complex Route -- Collect Batch Step Dependencies in one insert-select --*/
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
                || '    organization_id, '
                || '    recommended '
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
                ||'          iwm.mtl_organization_id, '
                ||           '''Y'''
                ||'      FROM '
                ||'          gme_batch_step_dependencies'||pdblink||' gbsd, '
                ||'          gme_batch_header'||pdblink||' h,'
                ||'          gme_batch_steps'||pdblink||' gbs1, '
                ||'          gme_batch_steps'||pdblink||' gbs2, '
                ||'          ic_whse_mst'||pdblink||' iwm, '
                ||'          sy_orgn_mst'||pdblink||' som '
                ||'      WHERE '
                ||'               h.batch_id = gbsd.batch_id '
                ||'          AND gbs1.batch_id = gbsd.batch_id '
                ||'          AND gbs1.batchstep_id = gbsd.dep_step_id '
                ||'          AND gbs2.batch_id = gbsd.batch_id '
                ||'          AND gbs2.batchstep_id = gbsd.batchstep_id '
                ||'          AND h.batch_status in (1, 2) '
                ||'          AND h.plant_code = som.orgn_code '
                ||'          AND som.delete_mark = 0 '
                ||'          AND som.resource_whse_code = iwm.whse_code ' ;


	        IF MSC_CL_GMP_UTILITY.g_in_str_org  IS NOT NULL THEN
	         sql_stmt := sql_stmt
	                   ||'   AND iwm.mtl_organization_id ' || MSC_CL_GMP_UTILITY.g_in_str_org ;
	        END IF;

	         EXECUTE IMMEDIATE  sql_stmt USING pinstance_id;
        /* NAVIN: ------------ END: Complex Route -- Collect Batch Step Dependencies in one insert-select ------------*/

/* NAVIN: ----------------------- MTQ with Hardlinks --------------------- */
i := 1;
log_message(stp_var_itm_from_op_seq_id.FIRST || ' *OPERNETTWORK*' ||
stp_var_itm_from_op_seq_id.LAST );
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
        minimum_transfer_qty,
        recommended
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
        stp_var_min_tran_qty(i),
        'Y'
  );

END IF ;

        stp_var_itm_from_op_seq_id  := empty_num_table ;
        stp_var_itm_wip_entity_id   := empty_num_table ;
        stp_var_itm_instance_id     := empty_num_table ;
        stp_var_itm_FROM_item_ID    := empty_num_table ;
        stp_var_itm_organization_id := empty_num_table ;
        stp_var_itm_min_tm_off      := empty_num_table ;
        stp_var_itm_max_tm_off      := empty_num_table ;
        stp_var_itm_from_op_seq_num := empty_num_table ;
        stp_var_min_tran_qty        := empty_num_table ;
/* ----------------------- MTQ with Hardlinks --------------------- */


/* ----------------------- Operation Charges --------------------- */
/* NAVIN: Operation Charges */
i := 1 ;
log_message(stp_chg_organization_id.FIRST || ' *STEPCHARGE*' ||
stp_chg_organization_id.LAST );
IF stp_chg_organization_id.FIRST > 0 THEN
 FORALL i IN stp_chg_organization_id.FIRST..stp_chg_organization_id.LAST
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
END IF ;

        stp_instance_id           := empty_num_table ;
        stp_chg_resource_id       := empty_num_table ;
        stp_chg_organization_id   := empty_num_table ;
        stp_chg_department_id     := empty_num_table ;
        stp_chg_wip_entity_id     := empty_num_table ;
        stp_chg_operation_seq_id  := empty_num_table ;
        stp_chg_operation_seq_no  := empty_num_table ;
        stp_chg_resource_seq_num  := empty_num_table ;
        stp_chg_charge_num        := empty_num_table ;
        stp_chg_charge_quanitity  := empty_num_table ;
        stp_chg_charge_start_dt_time := stpe_chg_charge_start_dt_time ;
        stp_chg_charge_end_dt_time   := stpe_chg_charge_end_dt_time ;

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
     END IF;

        rec_inst_supply_id             := empty_num_table ;
        rec_inst_organization_id       := empty_num_table ;
        rec_inst_sr_instance_id        := empty_num_table ;
        rec_inst_rec_resource_seq_num  := empty_num_table ;
        rec_inst_resource_id           := empty_num_table ;
        rec_inst_instance_id           := empty_num_table ;
        rec_inst_start_date            := empty_dat_table ;
        rec_inst_end_date              := empty_dat_table ;
        rec_inst_rsrc_instance_hours   := empty_num_table ;
        rec_inst_operation_seq_num     := empty_num_table ;
        rec_inst_department_id         := empty_num_table ;
        rec_inst_wip_entity_id         := empty_num_table ;
        rec_inst_serial_number         := empty_inst_serial_number ;   -- Bug 5713355
        rec_inst_parent_seq_num        := empty_num_table ;
        rec_inst_original_seq_num      := empty_num_table ;
        rec_inst_equp_item_id          := empty_num_table ;

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

     END IF;

        arr_wip_entity_id              := empty_num_table ;
        arr_organization_id            := empty_num_table ;
        arr_sr_instance_id             := empty_num_table ;
        arr_operation_seq_num          := empty_num_table ;
        arr_res_seq_num                := empty_num_table ;
        arr_resource_id                := empty_num_table ;
        arr_alternate_num              := empty_num_table ;
        arr_usage_rate                 := empty_num_table ;
        arr_assigned_units             := empty_num_table ;
        arr_department_id              := empty_num_table ;
        arr_uom_code                   := arre_uom_code   ;
        arr_activity_group_id          := empty_num_table ;
        arr_basis_type                 := empty_num_table ;
        arr_setup_id                   := empty_num_table ;
        arr_schedule_seq_num           := empty_num_table ;
        arr_maximum_assigned_units     := empty_num_table ;

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
           (SYSDATE-100),
           2
        );

     END IF;

        jo_wip_entity_id         := empty_num_table ;
        jo_instance_id           := empty_num_table ;
        jo_operation_seq_num     := empty_num_table ;
        jo_recommended           := joe_recommended ;
        jo_network_start_end     := joe_network_start_end;
        jo_reco_start_date       := empty_dat_table ;
        jo_reco_completion_date  := empty_dat_table ;
        jo_operation_sequence_id := empty_num_table ;
        jo_organization_id       := empty_num_table ;
        jo_department_id         := empty_num_table ;
        jo_minimum_transfer_quantity := empty_num_table ;

      dbms_session.free_unused_user_memory;/* akaruppa B5007729 */

/* ----------------------- Job Operations --------------------- */

  return_status := TRUE;

  EXCEPTION
    WHEN invalid_string_value  THEN
        log_message('Organization string is Invalid ' );
        return_status := FALSE;

    WHEN invalid_gmp_uom_profile THEN
        log_message('Profile "GMP: UOM for Hour" is Invalid ' );
        return_status := FALSE;

    WHEN NO_DATA_FOUND THEN /* B3577871 */
      log_message(' NO_DATA_FOUND exception raised in Procedure: MSC_CL_GMP_UTILITY.Production_orders ' );
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
  pitem_id          NUMBER,
  porganization_id  NUMBER,
  pinstance_id      NUMBER,
  pdate             DATE,
  pstart_date       DATE,
  pend_date         DATE,
  pbatch_id         NUMBER,
  pqty              NUMBER,
  pfirmed_ind       NUMBER,
  pbatchstep_no     NUMBER,   /* Added pbatchstep_no - B2919303 */
  porder_no         VARCHAR2,
  plot_number       VARCHAR2,
  pexpire_date      DATE,
  psupply_type      NUMBER,
  pproduct_item_id  NUMBER)     /* B2953953 - CoProduct */

AS
  st_supplies  VARCHAR2(32000) ;
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
  porganization_id  IN NUMBER,
  pinstance_id      IN NUMBER,
  pseq_num          IN NUMBER,
  presource_id      IN NUMBER,
  pstart_date       IN DATE,
  pend_date         IN DATE,
  presource_usage   IN NUMBER,
  prsrc_cnt         IN NUMBER,
  pbatchstep_no     IN NUMBER,  /* B1224660 new parm to write step number */
  pbatch_id         IN NUMBER,
  pstep_status      IN NUMBER,
  pschedule_flag    IN NUMBER,
  pparent_seq_num   IN NUMBER,
  pmin_xfer_qty     IN NUMBER)

AS
  st_resource_requirements  VARCHAR2(32000) ;

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
  pitem_id          NUMBER,
  porganization_id  NUMBER,
  pinstance_id      NUMBER,
  pbatch_id         NUMBER,
  pproduct_item_id  NUMBER,
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

  statement_demands_api  VARCHAR2(32000) ;
  statement_demands      VARCHAR2(32000) ;
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
  pinstance_id   IN  NUMBER,
  prun_date      IN  DATE,
  pdelimiter     IN  VARCHAR2,
  return_status  IN OUT NOCOPY BOOLEAN)
AS

  local_ret_status1       BOOLEAN ;
  local_ret_status2       BOOLEAN ;
  onhand_balances_failure EXCEPTION ;
  inv_transfer_failure    EXCEPTION ;

BEGIN
  local_ret_status1  := TRUE;
  local_ret_status2  := TRUE;

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
  extract_inv_transfer_supplies(pdblink, pinstance_id, prun_date,
     pdelimiter, local_ret_status2);

  IF local_ret_status2 = TRUE  THEN
    return_status := TRUE ;
  ELSE
    return_status := FALSE;
    RAISE  inv_transfer_failure ;
  END IF;

  EXCEPTION
    WHEN onhand_balances_failure THEN
      log_message(' extract_onhand_balances_failure raised in Procedure: MSC_CL_GMP_UTILITY.Onhand_inventory ' );
      return_status := FALSE;
    WHEN inv_transfer_failure THEN
      log_message(' extract_inv_transfer_supplies_failure raised in Procedure: MSC_CL_GMP_UTILITY.Onhand_inventory ' );
      return_status := FALSE;
    WHEN NO_DATA_FOUND THEN /* B3577871 */
      log_message(' NO_DATA_FOUND exception raised in Procedure: MSC_CL_GMP_UTILITY.Onhand_inventory ' );
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
*  Sgidugu  B2251375 - Changed Substr Function to substrb Function
*  AKARUPPA B4287033 - Changed direct insert selects to BULK INSERT as direct insert
*		       select over dblink causes performance issues.
*  AKARUPPA B4278082 - Changed query to select status controlled items to
*		       fetch items with status control as No Inventory (status_ctl = 2)
************************************************************************/
PROCEDURE extract_onhand_balances(
  pdblink        IN  VARCHAR2,
  pinstance_id   IN  NUMBER,
  prun_date      IN  DATE,
  pdelimiter     IN  VARCHAR2,
  return_status  IN OUT NOCOPY BOOLEAN)
AS

/* akaruppa B4287033 07-APR-2005 Adding new variable definitions for doing BULK INSERT in place of direct INSERT SELECT */
  TYPE onhand_balance_nolot_typ IS RECORD(
	  plan_id		NUMBER,
	  inventory_item_id	NUMBER,
	  organization_id	NUMBER,
	  sr_instance_id	NUMBER,
	  new_schedule_date	DATE,
	  order_type		NUMBER,
	  firm_planned_type	NUMBER,
	  deleted_flag		NUMBER,
	  subinventory_code	VARCHAR2(10),
	  new_order_quantity	NUMBER );

  TYPE onhand_balance_nolot_tbl IS TABLE OF onhand_balance_nolot_typ INDEX by BINARY_INTEGER;
  onhand_balance_nolot_tab   onhand_balance_nolot_tbl;

  TYPE onhand_balance_lot_typ IS RECORD(
	  plan_id		NUMBER,
	  inventory_item_id	NUMBER,
	  organization_id	NUMBER,
	  sr_instance_id	NUMBER,
	  new_schedule_date	DATE,
	  order_type		NUMBER,
	  lot_number		VARCHAR2(30),
	  expiration_date	DATE,
	  firm_planned_type	NUMBER,
	  deleted_flag		NUMBER,
	  subinventory_code	VARCHAR2(10),
	  new_order_quantity	NUMBER );

  TYPE onhand_balance_lot_tbl IS TABLE OF onhand_balance_lot_typ INDEX by BINARY_INTEGER;
  onhand_balance_lot_tab   onhand_balance_lot_tbl;

  TYPE onhand_balance_status_typ IS RECORD(
	  plan_id		NUMBER,
	  inventory_item_id	NUMBER,
	  organization_id	NUMBER,
	  sr_instance_id	NUMBER,
	  new_schedule_date	DATE,
	  new_dock_date		DATE,
	  order_type		NUMBER,
	  lot_number		VARCHAR2(30),
	  expiration_date	DATE,
	  firm_planned_type	NUMBER,
	  deleted_flag		NUMBER,
	  subinventory_code	VARCHAR2(10),
	  new_order_quantity	NUMBER,
	  non_nettable_qty 	NUMBER );

  TYPE onhand_balance_status_tbl IS TABLE OF onhand_balance_status_typ INDEX by BINARY_INTEGER;
  onhand_balance_status_tab   onhand_balance_status_tbl;

  TYPE gmp_cursor_typ IS REF CURSOR;
  c_onhand_balance_nolot  gmp_cursor_typ;
  c_onhand_balance_lot	  gmp_cursor_typ;
  c_onhand_balance_status gmp_cursor_typ;
  ex_code_ref             gmp_cursor_typ;
  mx_code_ref             gmp_cursor_typ;

  v_onhand_cursor   VARCHAR2(32000) ;
  onhand_count      NUMBER;
  insert_count      NUMBER;

  /* End of definitions for B4287033 */

 l_profile NUMBER ; /* Bug # 5238790 */
 sy_max_date DATE ; /* B5501754 Rajesh Patangya */
 ex_code_cursor       VARCHAR2(32000);
 mx_code_cursor       VARCHAR2(32000);

BEGIN

   log_message('Entering Extract_OnHand_Balances. ');
   time_stamp ;

   /* Bug # 5238790 */
   l_profile := 0 ;
   ex_code_cursor   := ' select NVL(fnd_profile.VALUE' ||pdblink
                      ||' (''GMP_COLLECT_EXPR_ONHAND''),0) from dual ' ;

       OPEN ex_code_ref FOR ex_code_cursor ;
       FETCH ex_code_ref INTO l_profile;
       CLOSE ex_code_ref;

   /* B5501754 */
   mx_code_cursor   := ' select to_date(fnd_profile.VALUE' ||pdblink
                      ||' (''SY$MAX_DATE''),''YYYY/MM/DD'') from dual ' ;

       OPEN mx_code_ref FOR mx_code_cursor ;
       FETCH mx_code_ref INTO sy_max_date;
       CLOSE mx_code_ref;

  onhand_count     := 1;
  v_onhand_cursor  := NULL;
  insert_count     := 1;

  /* Query to select the production order details where the batch/fpo is pending
  the balances from ic_summ for the item/whse that are not lot controlled
  are inserted */
  v_onhand_cursor :=   ' SELECT '
	 || ' -1,'
	 || ' i.aps_item_id,'
	 || ' i.organization_id,'
	 || ' :pinstance_id, '
	 || ' :prun_date, '
	 || ' 18,'                        /* onhand inventory value */
	 || ' 2,'
	 || ' 2,'
	 || ' s.whse_code,' /* Populate subinventory with Whse code B1172875 */
	 || ' s.onhand_qty'
	 || ' FROM '
	 || ' ic_summ_inv_onhand_v' ||pdblink|| ' s,'
	 || ' (select distinct aps_item_id,item_id,whse_code,organization_id, '
	 || '  lot_control,experimental_ind from gmp_item_aps'||pdblink||') i'
	 || ' WHERE '
	 || ' s.item_id = i.item_id '
	 || ' and s.whse_code = i.whse_code '
	 || ' and i.lot_control = 0'
	 || ' and s.onhand_qty <> 0';

        /* Bug # 5238790 */
        IF l_profile = 0 THEN
           v_onhand_cursor := v_onhand_cursor
         || ' and i.experimental_ind = 0 ' ;
        END IF;

    OPEN c_onhand_balance_nolot FOR v_onhand_cursor USING pinstance_id, prun_date;
    LOOP
      FETCH  c_onhand_balance_nolot INTO onhand_balance_nolot_tab(onhand_count);
      EXIT WHEN  c_onhand_balance_nolot%NOTFOUND ;
      onhand_count := onhand_count + 1;
    END LOOP;
    CLOSE c_onhand_balance_nolot ;
    gonhand_balance_size := onhand_count - 1;

   log_message('No lot on hand fetches : '|| to_char(gonhand_balance_size) );
   time_stamp ;

   IF onhand_count > 1 THEN
   FOR i in onhand_balance_nolot_tab.FIRST..onhand_balance_nolot_tab.LAST
   LOOP
    o_plan_id(insert_count)            :=  onhand_balance_nolot_tab(i).plan_id;
    o_inventory_item_id(insert_count)  :=  onhand_balance_nolot_tab(i).inventory_item_id;
    o_organization_id(insert_count)    :=  onhand_balance_nolot_tab(i).organization_id;
    o_sr_instance_id(insert_count)     :=  onhand_balance_nolot_tab(i).sr_instance_id;
    o_new_schedule_date(insert_count)  :=  onhand_balance_nolot_tab(i).new_schedule_date;
    o_new_dock_date(insert_count)      :=  NULL;
    o_order_type(insert_count)         :=  onhand_balance_nolot_tab(i).order_type;
    o_lot_number(insert_count)	       :=  NULL;
    o_expiration_date(insert_count)    :=  NULL;
    o_firm_planned_type(insert_count)  :=  onhand_balance_nolot_tab(i).firm_planned_type;
    o_deleted_flag(insert_count)       :=  onhand_balance_nolot_tab(i).deleted_flag;
    o_subinventory_code(insert_count)  :=  onhand_balance_nolot_tab(i).subinventory_code;
    o_new_order_quantity(insert_count) :=  onhand_balance_nolot_tab(i).new_order_quantity;
    o_non_nettable_qty(insert_count)   :=  NULL;
    insert_count := insert_count + 1;
   END LOOP;
   END IF;

    onhand_count := 1;

    v_onhand_cursor := NULL;

  /* Get onhand balances from the location inventory table for lot controlled
     items. The lot can not be status controlled, that will be in the next
     insert the lot number is the combo of lot and sublot
  */
  v_onhand_cursor :=   ' SELECT'
	    || ' -1,'
	    || ' i.aps_item_id,'
	    || ' i.organization_id,'
	    || ' :pinstance_id,'
	    || ' :prun_date,'
	    || ' 18,'                        /* onhand inventory value */
	    || ' substrb(l.lot_no||DECODE(l.sublot_no, NULL,NULL ,:pdelimiter || '
	    || ' l.sublot_no),1,30),'
	    || ' l.expire_date,'
	    || ' 2,'
	    || ' 2,'
	    || ' s.whse_code,' /* Populate subinventory with whse code B1172875 */
	    || ' s.loct_onhand'
	    || ' FROM'
	    || ' ic_loct_inv'||pdblink||' s,'
	    || ' ic_lots_mst'||pdblink||' l,'
	    || ' ic_item_mst_b'||pdblink||' m,'
	    || ' (select distinct aps_item_id,item_id,whse_code,organization_id, '
	    || ' lot_control,experimental_ind from gmp_item_aps'||pdblink||') i'
	    || ' WHERE'
	    || '     s.item_id = i.item_id'
	    || ' and s.item_id = m.item_id'
	    || ' and s.whse_code = i.whse_code'
	    || ' and i.lot_control = 1'
	    || ' and m.status_ctl = 0'
	    || ' and s.lot_id = l.lot_id'
	    || ' and s.item_id = l.item_id'
	    || ' and s.lot_id > 0'
	    || ' and l.delete_mark = 0'
	    || ' and s.loct_onhand <> 0';
    /* Bug # 5238790 */
    IF l_profile = 0 THEN
       v_onhand_cursor := v_onhand_cursor
    || ' and i.experimental_ind = 0 ' ;
    END IF;


    OPEN c_onhand_balance_lot FOR v_onhand_cursor USING pinstance_id, prun_date, pdelimiter;
    LOOP
      FETCH  c_onhand_balance_lot INTO onhand_balance_lot_tab(onhand_count);
      EXIT WHEN  c_onhand_balance_lot%NOTFOUND ;
      onhand_count := onhand_count + 1;
    END LOOP;
    CLOSE c_onhand_balance_lot ;
    gonhand_balance_size := gonhand_balance_size + onhand_count - 1;

   log_message('Lot on hand fetches : '|| to_char(gonhand_balance_size) );
   time_stamp ;

   IF onhand_count > 1 THEN
   FOR i in onhand_balance_lot_tab.FIRST..onhand_balance_lot_tab.LAST
   LOOP
     o_plan_id(insert_count)            :=  onhand_balance_lot_tab(i).plan_id;
     o_inventory_item_id(insert_count)  :=  onhand_balance_lot_tab(i).inventory_item_id;
     o_organization_id(insert_count)	:=  onhand_balance_lot_tab(i).organization_id;
     o_sr_instance_id(insert_count)	:=  onhand_balance_lot_tab(i).sr_instance_id;
     o_new_schedule_date(insert_count)  :=  onhand_balance_lot_tab(i).new_schedule_date;
     o_new_dock_date(insert_count)	:=  NULL;
     o_order_type(insert_count)  	:=  onhand_balance_lot_tab(i).order_type;
     o_lot_number(insert_count)	        :=  onhand_balance_lot_tab(i).lot_number;

     /* B5501754 */
     IF (onhand_balance_lot_tab(i).expiration_date >= sy_max_date) THEN
     o_expiration_date(insert_count)    :=  NULL;
     ELSE
     o_expiration_date(insert_count)    := onhand_balance_lot_tab(i).expiration_date;
     END IF;

     o_firm_planned_type(insert_count)  :=  onhand_balance_lot_tab(i).firm_planned_type;
     o_deleted_flag(insert_count)	:=  onhand_balance_lot_tab(i).deleted_flag;
     o_subinventory_code(insert_count)  :=  onhand_balance_lot_tab(i).subinventory_code;
     o_new_order_quantity(insert_count) :=  onhand_balance_lot_tab(i).new_order_quantity;
     o_non_nettable_qty(insert_count)   :=  NULL;
     insert_count := insert_count + 1;
   END LOOP;
   END IF;

    onhand_count := 1;

    v_onhand_cursor := NULL;

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

  v_onhand_cursor :=  ' SELECT'
	  || ' -1,'
	  || ' i.aps_item_id,'
	  || ' i.organization_id,'
	  || ' :pinstance_id,'
	  || ' DECODE(c.ic_hold_date,NULL,:prun_date,c.ic_hold_date),'
	  || ' :prun_date,'
	  || ' DECODE(c.ic_hold_date,NULL,18,8),'   /* onhand inventory value */
	  || ' substrb(l.lot_no||DECODE(l.sublot_no, NULL,NULL ,:pdelimiter || '
	  || ' l.sublot_no),1,30),'
	  || ' l.expire_date,'
	  || ' 2,'
	  || ' 2,'
	  || ' s.whse_code,'  /* Populating subinventory code with whse code B1172875 */
	  || ' s.loct_onhand, '
	  || ' decode(t.order_proc_ind,0,s.loct_onhand,0)'
	  || ' FROM'
	  || ' ic_loct_inv'||pdblink||' s,'
	  || ' ic_lots_mst'||pdblink||' l,'
	  || ' ic_item_mst_b'||pdblink||' m,'
	  || ' (select distinct aps_item_id, item_id, whse_code, organization_id, '
	  || ' lot_control,experimental_ind from gmp_item_aps'||pdblink||') i,'
	  || ' ic_lots_sts'||pdblink||' t,'
	  || ' ic_lots_cpg'||pdblink||' c'
	  || ' WHERE'
	  || '     s.item_id = i.item_id'
	  || ' and s.item_id = m.item_id'
	  || ' and s.whse_code = i.whse_code'
	  || ' and i.lot_control = 1'
	  || ' and s.lot_id = l.lot_id'
	  || ' and s.item_id = l.item_id'
	  || ' and s.lot_id > 0'
	  || ' and l.delete_mark = 0'
	  || ' and m.status_ctl IN (1,2)' -- akaruppa B4278082 19-APR-2005 Added status_ctl = 2 also as Items with Status Control with No Inventory were not getting collected
	  || ' and s.lot_status = t.lot_status'
	  || ' and t.rejected_ind = 0'
	  || ' and t.nettable_ind = 1'
	  || ' and s.loct_onhand <> 0'
	  || ' and c.item_id (+) = l.item_id'
	  || ' and c.lot_id (+) = l.lot_id'
	  || ' and c.ic_hold_date (+) > :run_date' ;
    /* Bug # 5238790 */
    IF l_profile = 0 THEN
       v_onhand_cursor := v_onhand_cursor
    || ' and i.experimental_ind = 0 ' ;
    END IF;

    OPEN c_onhand_balance_status FOR v_onhand_cursor USING pinstance_id, prun_date, prun_date, pdelimiter, prun_date;
    LOOP
      FETCH  c_onhand_balance_status INTO onhand_balance_status_tab(onhand_count);
      EXIT WHEN  c_onhand_balance_status%NOTFOUND ;
      onhand_count := onhand_count + 1;
    END LOOP;
    CLOSE c_onhand_balance_status ;
    gonhand_balance_size := gonhand_balance_size + onhand_count - 1;

   log_message('Lot and status on hand fetches : '|| to_char(gonhand_balance_size) );
   time_stamp ;

    IF onhand_count > 1 THEN
    FOR i in onhand_balance_status_tab.FIRST..onhand_balance_status_tab.LAST
    LOOP
     o_plan_id(insert_count)           := onhand_balance_status_tab(i).plan_id;
     o_inventory_item_id(insert_count) := onhand_balance_status_tab(i).inventory_item_id;
     o_organization_id(insert_count)   := onhand_balance_status_tab(i).organization_id;
     o_sr_instance_id(insert_count)    := onhand_balance_status_tab(i).sr_instance_id;
     o_new_schedule_date(insert_count) := onhand_balance_status_tab(i).new_schedule_date;
     o_new_dock_date(insert_count)     := onhand_balance_status_tab(i).new_dock_date;
     o_order_type(insert_count)        := onhand_balance_status_tab(i).order_type;
     o_lot_number(insert_count)        := onhand_balance_status_tab(i).lot_number;
     /* B5501754 */
     IF (onhand_balance_status_tab(i).expiration_date >= sy_max_date) THEN
     o_expiration_date(insert_count)    :=  NULL;
     ELSE
     o_expiration_date(insert_count)   := onhand_balance_status_tab(i).expiration_date;
     END IF;
     o_firm_planned_type(insert_count) := onhand_balance_status_tab(i).firm_planned_type;
     o_deleted_flag(insert_count)      := onhand_balance_status_tab(i).deleted_flag;
     o_subinventory_code(insert_count) := onhand_balance_status_tab(i).subinventory_code;
  o_new_order_quantity(insert_count) := onhand_balance_status_tab(i).new_order_quantity;
     o_non_nettable_qty(insert_count)  := onhand_balance_status_tab(i).non_nettable_qty;
     insert_count := insert_count + 1;
    END LOOP;
    END IF;

    insert_count := insert_count - 1;

    FORALL i IN 1..insert_count
    INSERT INTO msc_st_supplies
                (plan_id,
		inventory_item_id,
		organization_id,
		sr_instance_id,
		new_schedule_date,
		new_dock_date,
		order_type,
		lot_number,
		expiration_date,
		firm_planned_type,
		deleted_flag,
		subinventory_code,
		new_order_quantity,
		non_nettable_qty
		)
         VALUES(o_plan_id(i),
		o_inventory_item_id(i),
		o_organization_id(i),
		o_sr_instance_id(i),
		o_new_schedule_date(i),
		o_new_dock_date(i),
		o_order_type(i),
		o_lot_number(i),
		o_expiration_date(i),
		o_firm_planned_type(i),
		o_deleted_flag(i),
		o_subinventory_code(i),
		o_new_order_quantity(i),
		o_non_nettable_qty(i)
		);

   log_message('On Hand Balances size is = '|| to_char(gonhand_balance_size) );
   time_stamp ;

/* akaruppa B5007729 */
	o_organization_id  := empty_num_table ;
	o_sr_instance_id   := empty_num_table ;
	o_plan_id          := empty_num_table ;
	o_inventory_item_id := empty_num_table ;
	o_new_schedule_date := empty_dat_table ;
        o_order_type        := empty_num_table ;
	o_new_order_quantity := empty_num_table ;
	o_firm_planned_type  := empty_num_table ;
	o_lot_number         := e_lot_number;
	o_expiration_date    := empty_dat_table ;
	o_new_dock_date      := empty_dat_table ;
	o_deleted_flag       := empty_num_table ;
	o_subinventory_code  := e_subinventory_code;
        o_non_nettable_qty   := empty_num_table ;

        dbms_session.free_unused_user_memory;

/* akaruppa B5007729 End*/

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
  pinstance_id   IN  NUMBER,
  prun_date      IN  DATE,
  pdelimiter     IN  VARCHAR2,
  pwhse_code     IN  VARCHAR2,
  pdesignator    IN  VARCHAR2,
  return_status  IN OUT NOCOPY BOOLEAN)
AS

  pdoc_type      VARCHAR2(4) ;
  l_profile      NUMBER      ; /* Bug # 5238790 */
  TYPE onh_cursor_typ IS REF CURSOR;
  ex_code_ref          onh_cursor_typ;
  ex_code_cursor       VARCHAR2(32000);

BEGIN
   log_message('Entering extract_inv_transfer_demands. ');
   time_stamp ;
  pdoc_type      := 'XFER';
  /* Bug # 5238790 */
   l_profile := 0 ;
   ex_code_cursor   := ' select NVL(fnd_profile.VALUE' ||pdblink
                      ||' (''GMP_COLLECT_EXPR_ONHAND''),0) from dual ' ;

       OPEN ex_code_ref FOR ex_code_cursor ;
       FETCH ex_code_ref INTO l_profile;
       CLOSE ex_code_ref;

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
    || '    ,experimental_ind from gmp_item_aps'||pdblink||') i'
    || ' WHERE '
    || '   s.item_id = i.item_id '
    || '   and s.from_warehouse = i.whse_code '
    || '   and s.transfer_status IN (1) '
    || '   and s.from_warehouse = :pwhse_code '
    || '   and s.release_quantity1 <> 0';
    /* Bug # 5238790 */
    IF l_profile = 0 THEN
       v_sql_stmt := v_sql_stmt
    || ' and i.experimental_ind = 0 ' ;
    END IF;

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
  pinstance_id   IN  NUMBER,
  prun_date      IN  DATE,
  pdelimiter     IN  VARCHAR2,
  return_status  IN OUT NOCOPY BOOLEAN)
AS

  pdoc_type      VARCHAR2(4) ;
  l_profile      NUMBER      ;/* Bug # 5238790 */
  TYPE onh_cursor_typ IS REF CURSOR;
  ex_code_ref          onh_cursor_typ;
  ex_code_cursor       VARCHAR2(32000);

BEGIN
   log_message('Entering extract_inv_transfer_supplies. ');
   time_stamp ;
  pdoc_type      := 'XFER';

   /* Bug # 5238790 */
   l_profile := 0 ;
   ex_code_cursor   := ' select NVL(fnd_profile.VALUE' ||pdblink
                      ||' (''GMP_COLLECT_EXPR_ONHAND''),0) from dual ' ;

       OPEN ex_code_ref FOR ex_code_cursor ;
       FETCH ex_code_ref INTO l_profile;
       CLOSE ex_code_ref;

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
    || '  ,experimental_ind from gmp_item_aps'||pdblink||') i'
    || ' WHERE '
    || ' s.item_id = i.item_id '
    || ' and s.to_warehouse = i.whse_code '
    || ' and s.from_warehouse = w.whse_code '
    || ' and s.transfer_status IN (1,2) '
    || ' and s.lot_id = l.lot_id'
    || ' and s.item_id = l.item_id'
    || ' and s.release_quantity1 <> 0';
   /* Bug # 5238790 */
    IF l_profile = 0 THEN
       v_sql_stmt := v_sql_stmt
    || ' and i.experimental_ind = 0 ' ;
    END IF;

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
  found           NUMBER ;
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

  MSC_CL_GMP_UTILITY.extract_items(
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
			  pinstance_id   IN  NUMBER,
			  prun_date      IN  DATE,
			  pdelimiter     IN  VARCHAR2,
			  return_status  IN  OUT NOCOPY BOOLEAN,
			  api_mode       IN  BOOLEAN)

AS

    TYPE gmp_cursor_typ IS REF CURSOR;
    cur_gmp_schd_items  gmp_cursor_typ;
    cur_fcst_dtl        gmp_cursor_typ;
    cur_sales_dtl       gmp_cursor_typ;
    cur_schd_fcst       gmp_cursor_typ;
    ex_code_ref         gmp_cursor_typ;

    so_ind		BOOLEAN ;
    fcst_ind		BOOLEAN ;
    log_mesg            VARCHAR2(1000) ;
    i			NUMBER ;
    j			NUMBER ;
    old_schedule_id	NUMBER ;
    item_count		NUMBER ;
    fcst_count		NUMBER ;
    so_count		NUMBER ;
    schd_fcst_cnt	NUMBER ;
    local_ret_status    BOOLEAN;
    l_profile           NUMBER ; /* Bug # 5238790 */
    ex_code_cursor      VARCHAR2(32000);

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

  log_message('Start MSC_CL_GMP_UTILITY.sales forecast');
  time_stamp;

  IF return_status THEN
    v_cp_enabled := TRUE;
  ELSE
    v_cp_enabled := FALSE;
  END IF;
   g_delimiter		:= pdelimiter ;
   g_instance_id	:= pinstance_id ;

   /* Bug # 5238790 */
   l_profile := 0 ;
   ex_code_cursor   := ' select NVL(fnd_profile.VALUE' ||pdblink
                      ||' (''GMP_COLLECT_EXPR_ONHAND''),0) from dual ' ;

       OPEN ex_code_ref FOR ex_code_cursor ;
       FETCH ex_code_ref INTO l_profile;
       CLOSE ex_code_ref;

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
         || ' and a.item_id > 0 ' ;
         /* Bug # 5238790 */
         IF l_profile = 0 THEN
        v_item_sql_stmt := v_item_sql_stmt
         || ' and a.experimental_ind = 0 ' ;
         END IF;

        v_item_sql_stmt := v_item_sql_stmt
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
          || '     msi.organization_id = wm.mtl_organization_id ' ;
          /* Bug # 5238790 */
         IF l_profile = 0 THEN
                  v_forecast_sql_stmt := v_forecast_sql_stmt
         || ' and iim.experimental_ind = 0 ' ;
         END IF;

          v_forecast_sql_stmt := v_forecast_sql_stmt
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

    log_message('End of MSC_CL_GMP_UTILITY.sales forecast') ;
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
      log_message(' NO_DATA_FOUND exception raised in Procedure: MSC_CL_GMP_UTILITY.Sales_forecast ' );
      return_status := TRUE;

    WHEN OTHERS THEN
	log_message('Failure occured during the Sales_Forecast extract');
	log_message(sqlerrm);
        return_status := FALSE;
END sales_forecast;

/************************************************************************
*   NAME
*	sales_order_allocation
*
*   DESCRIPTION
*  This procedure will have a new procedure to collect the additional data
*  element for ASCP. OPM does not have sales order reservation
*  functionality. Hence OM Reservation does not impact ic_tran_pnd. Only
*  Allocation, which can be be done just after Order creation or after
*  order is booked but before Shipping will create a  record in ic_tran_pnd
*  table. Sales order Reservation Quantity is summation of allocated -
*  quantity + remaining Quantity. We can Reserve/Allocate more than On hand
*   committed quantity. These sales order item allocation record will be
*  send to ASCP.
*   For non-controlled items, no allocation/reservations are allowed
*   and hence this enhancement will not send any information.
*   The following enhancement will also support org specific
*   collection for reservation entity. The net change
*   functionality will not be supported by process code collection.
*
*   HISTORY
*       Created By : B5501754 Rajesh Patangya
************************************************************************/
PROCEDURE sales_order_allocation (
                          pdblink        IN  VARCHAR2,
                          pinstance_id   IN  NUMBER,
                          pentity        IN  NUMBER,
                          return_status  IN  OUT NOCOPY BOOLEAN)
IS


   TYPE pld_cursor_typ IS REF CURSOR;
   ic_code_ref          pld_cursor_typ;
   bs_code_ref          pld_cursor_typ;

   ic_code_cursor       VARCHAR2(32000);
   bs_code_cursor       VARCHAR2(32000);
   l_profile            VARCHAR2(40) ;
   b_profile            VARCHAR2(70) ;
   pdoc_type            VARCHAR2(4) ;
   v_instance_id        NUMBER;
   v_entity             NUMBER;
   v_sql_stmt           VARCHAR2(32000);
BEGIN
   v_instance_id := pinstance_id ;
   v_entity := pentity ;
   return_status := TRUE ;
   pdoc_type     := 'OMSO' ;
   l_profile := NULL ;

   /* This profile value holds the Defualt Location */
    ic_code_cursor   := ' select fnd_profile.VALUE' ||pdblink
                      ||' (''IC$DEFAULT_LOCT'') from dual ' ;

       OPEN ic_code_ref FOR ic_code_cursor ;
       FETCH ic_code_ref INTO l_profile;
       CLOSE ic_code_ref;

    bs_code_cursor   := ' select fnd_profile.VALUE' ||pdblink
                      ||' (''BIS_PRIMARY_RATE_TYPE'') from dual ' ;

       OPEN bs_code_ref FOR bs_code_cursor ;
       FETCH bs_code_ref INTO b_profile;
       CLOSE bs_code_ref;

    /* populate the org_string */
     IF MSC_CL_GMP_UTILITY.org_string(pinstance_id) THEN
        NULL ;
     ELSE
        RAISE invalid_string_value  ;
     END IF;

    IF v_entity = 1 THEN
/* to consider ATP,
1. Sales order Record should be inserted in msc_sales_order table, this record is directly coming from APS data collection, we have to modify ceratin columns (or insert an record in mtl_demand table).
2. Reservation record should be inserted in msc_sales_order table
*/

    v_sql_stmt := 'INSERT INTO MSC_ST_SALES_ORDERS ( '
   ||'    INVENTORY_ITEM_ID,'
   ||'    SOURCE_INVENTORY_ITEM_ID,'
   ||'    ORGANIZATION_ID,'
   ||'    PRIMARY_UOM_QUANTITY,'
   ||'    RESERVATION_TYPE, '
   ||'    RESERVATION_QUANTITY,'
   ||'    DEMAND_SOURCE_TYPE, '
   ||'    DEMAND_SOURCE_HEADER_ID,   '
   ||'    COMPLETED_QUANTITY,'
   ||'    SUBINVENTORY,'
   ||'    DEMAND_CLASS, '
   ||'    REQUIREMENT_DATE,'
   ||'    DEMAND_SOURCE_LINE, '
   ||'    SOURCE_DEMAND_SOURCE_LINE, '
   ||'    DEMAND_SOURCE_DELIVERY,'
   ||'    DEMAND_SOURCE_NAME,'
   ||'    PARENT_DEMAND_ID,'
   ||'    DEMAND_ID,'
   ||'    SOURCE_DEMAND_ID,'
   ||'    SALES_ORDER_NUMBER,'
   ||'    FORECAST_VISIBLE, '
   ||'    DEMAND_VISIBLE,'
   ||'    SALESREP_CONTACT,'
   ||'    SALESREP_ID,'
   ||'    CUSTOMER_ID,'
   ||'    SHIP_TO_SITE_USE_ID,'
   ||'    BILL_TO_SITE_USE_ID, '
   ||'    REQUEST_DATE, '
   ||'    PROJECT_ID, '
   ||'    TASK_ID, '
   ||'    PLANNING_GROUP,'
   ||'    SELLING_PRICE, '
   ||'    END_ITEM_UNIT_NUMBER, '
   ||'    ORDERED_ITEM_ID, '
   ||'    ORIGINAL_ITEM_ID,'
   ||'    LINK_TO_LINE_ID ,'
   ||'    CUST_PO_NUMBER, '
   ||'    CUSTOMER_LINE_NUMBER,'
   ||'    MFG_LEAD_TIME, '
   ||'    ORG_FIRM_FLAG,'
   ||'    SHIP_SET_ID, '
   ||'    ARRIVAL_SET_ID,'
   ||'    SHIP_SET_NAME, '
   ||'    ARRIVAL_SET_NAME,'
   ||'    ATP_REFRESH_NUMBER, '
   ||'    DELETED_FLAG, '
   ||'    ORIGINAL_SYSTEM_LINE_REFERENCE, '
   ||'    ORIGINAL_SYSTEM_REFERENCE, '
   ||'    CTO_FLAG, '
   ||'    AVAILABLE_TO_MRP,'
   ||'    DEMAND_PRIORITY,'
   ||'    PROMISE_DATE, '
   ||'    REFRESH_ID,'
   ||'    SR_INSTANCE_ID, '
   ||'    SCHEDULE_ARRIVAL_DATE, '
   ||'    LATEST_ACCEPTABLE_DATE,'
   ||'    SHIPPING_METHOD_CODE, '
   ||'    ATO_LINE_ID,'
   ||'    ORDER_DATE_TYPE_CODE,'
   ||'    INTRANSIT_LEAD_TIME '
   ||'   )  '
   ||'    SELECT '
   ||'    OOL.INVENTORY_ITEM_ID, '
   ||'    OOL.INVENTORY_ITEM_ID SOURCE_INVENTORY_ITEM_ID, '
   ||'    OOL.ORGANIZATION_ID, '
   ||'    (t.trans_qty * -1) PRIMARY_UOM_QUANTITY, '
   ||'    2 RESERVATION_TYPE, '
   ||'    TO_NUMBER(NULL) RESERVATION_QUANTITY, '
   ||'    decode(ool.SOURCE_DOCUMENT_TYPE_ID,10,8,2) DEMAND_SOURCE_TYPE, '
   ||'    so.SALES_ORDER_ID    DEMAND_SOURCE_HEADER_ID, '
   ||'    0 COMPLETED_QUANTITY, '
   ||'    TO_CHAR(NULL) SUBINVENTORY, '
   ||'    OOL.DEMAND_CLASS, '
   ||'    OOL.SCHEDULE_SHIP_DATE REQUIREMENT_DATE, '
   ||'    TO_CHAR(OOL.LINE_ID) DEMAND_SOURCE_LINE, '
   ||'    TO_CHAR(OOL.LINE_ID) SOURCE_DEMAND_SOURCE_LINE, '
   ||'    TO_CHAR(NULL) DEMAND_SOURCE_DELIVERY, '
   ||'    TO_CHAR(NULL) DEMAND_SOURCE_NAME, '
   ||'    TO_NUMBER(NULL) PARENT_DEMAND_ID, '
   ||'    MTL_DEMAND_S.nextval DEMAND_ID, '
   ||'    MTL_DEMAND_S.currval SOURCE_DEMAND_ID, '
   ||'    so.Concatenated_Segments, '
   ||'    ''Y'' , '
   ||'    ''Y'' , '
   ||'    TO_CHAR(NULL) Salesrep_Contact, '
   ||'    ool.salesrep_id, '
   ||'    ool.CUSTOMER_ID, '
   ||'    ool.SHIP_TO_SITE_ID, '
   ||'    ool.BILL_TO_SITE_ID, '
   ||'    ool.REQUEST_DATE, '
   ||'    ool.project_id, '
   ||'    ool.task_id, '
   ||'    TO_CHAR(NULL) PLANNING_GROUP, '
   ||'    ool.LIST_PRICE * decode(   GL_CURRENCY_API.get_rate_sql( '
   ||'				 h.transactional_curr_code, '
   ||'				 gsb.currency_code, '
   ||'				 h.booked_date, '
   ||'				 nvl(h.conversion_type_code, :b_prof1 )), '
   ||'				 -2,1,-1,1, '
   ||'				 GL_CURRENCY_API.get_rate_sql( '
   ||'				 h.transactional_curr_code, '
   ||'				 gsb.currency_code, '
   ||'				 h.booked_date, '
   ||'				 nvl(h.conversion_type_code, :b_prof2 )) '
   ||'				 ) LIST_PRICE, '
   ||'    ool.end_item_unit_number, '
   ||'    DECODE(DECODE(ool.ITEM_TYPE_CODE, '
   ||'          ''CLASS'',2, '
   ||'          ''CONFIG'',4, '
   ||'          ''MODEL'',1, '
   ||'          ''OPTION'' ,3, '
   ||'          ''STANDARD'',6, -1), 1, ool.inventory_item_id, NULL) ORDERED_ITEM_ID, '
   ||'    decode(ool.ORIGINAL_INVENTORY_ITEM_ID,-1,to_number(null), '
   ||'		  decode(ool.ITEM_RELATIONSHIP_TYPE,-1,to_number(null), '
   ||'						    2, ool.ORIGINAL_INVENTORY_ITEM_ID,  '
   ||'						    null,ool.ORIGINAL_INVENTORY_ITEM_ID,  '
   ||'						    to_number(null)) '
   ||'						    ) ORIGINAL_ITEM_ID, '
   ||'    TO_NUMBER(NULL) LINK_TO_LINE_ID, '
   ||'    nvl(ool.CUST_PO_NUMBER,''-1'') CUST_PO_NUMBER, '
   ||'    nvl(ool.CUSTOMER_LINE_NUMBER,''-1'') CUSTOMER_LINE_NUMBER, '
   ||'    ool.mfg_lead_time, '
   ||'    decode(ool.firm_demand_flag,NULL,to_number(null),''Y'',1,2) FIRM_DEMAND_FLAG, '
   ||'    ool.SHIP_SET_ID, '
   ||'    ool.ARRIVAL_SET_ID, '
   ||'    mrp_cl_function.get_ship_set_name(ool.SHIP_SET_ID) SHIP_SET_NAME, '
   ||'    mrp_cl_function.get_arrival_set_name(ool.ARRIVAL_SET_ID) ARRIVAL_SET_NAME, '
   ||'    TO_NUMBER(NULL) ATP_REFRESH_NUMBER, '
   ||'    2 DELETED_FLAG, '
   ||'    ool.original_system_reference, '
   ||'    ool.original_system_line_reference, '
   ||'    2 CTO_FLAG, '
   ||'    TO_NUMBER(NULL) available_to_mrp, '
   ||'    ool.DEMAND_PRIORITY, '
   ||'    ool.PROMISE_DATE, '
   ||'    TO_NUMBER(NULL) refresh_id, '
   ||'    :instance_id, '
   ||'    ool.SCHEDULE_ARRIVAL_DATE, '
   ||'    ool.LATEST_ACCEPTABLE_DATE, '
   ||'    ool.SHIPPING_METHOD_CODE, '
   ||'    ool.ATO_LINE_ID, '
   ||'    decode(h.ORDER_DATE_TYPE_CODE,''ARRIVAL'',2,1) ORDER_DATE_TYPE_CODE, '
   ||'    OOL.DELIVERY_LEAD_TIME  '
   ||'    FROM  '
   ||'        MRP_SN_SYS_ITEMS msik, '
   ||'        MTL_SALES_ORDERS_KFV so, '
   ||'        OE_ORDER_HEADERS_ALL h,       '
   ||'        GL_SETS_OF_BOOKS gsb, '
   ||'        AR_SYSTEM_PARAMETERS_ALL aspa   , '
   ||'        IC_TRAN_PND  t , '
   ||'        GMP_ITEM_APS i , '
   ||'        MRP_SN_ODR_LINES ool '
   ||'    WHERE  '
   ||'      t.item_id = i.item_id  '
   ||'      AND t.doc_type = :p_doc_type '
   ||'      AND ool.line_id = t.line_id '
   ||'      AND ( t.lot_id <> 0 OR t.location <> :p_prof ) '
   ||'      AND t.whse_code = i.whse_code  '
   ||'      AND t.orgn_code = i.plant_code  '
   ||'      AND t.completed_ind = 0  '
   ||'      AND t.trans_qty <> 0  '
   ||'      AND t.delete_mark = 0 '
   ||'      AND msik.inventory_item_id = i.aps_item_id '
   ||'      AND msik.organization_id = i.organization_id '
   ||'      AND so.Sales_Order_ID = t.doc_id  '
   ||'      AND ool.header_id = h.header_id(+) '
   ||'      AND h.org_id = aspa.org_id(+) '
   ||'      AND aspa.set_of_books_id = gsb.set_of_books_id(+) '
   ||'      AND h.org_id is not null ' ;

     IF MSC_CL_GMP_UTILITY.g_in_str_org  IS NOT NULL THEN
     v_sql_stmt := v_sql_stmt
     || '  AND i.organization_id ' || MSC_CL_GMP_UTILITY.g_in_str_org ;
     END IF;

    EXECUTE IMMEDIATE v_sql_stmt USING
      b_profile, b_profile, v_instance_id, pdoc_type, l_profile  ;

    v_sql_stmt := 'INSERT INTO MSC_ST_SALES_ORDERS ( '
   ||'    INVENTORY_ITEM_ID,'
   ||'    SOURCE_INVENTORY_ITEM_ID,'
   ||'    ORGANIZATION_ID,'
   ||'    PRIMARY_UOM_QUANTITY,'
   ||'    RESERVATION_TYPE, '
   ||'    RESERVATION_QUANTITY,'
   ||'    DEMAND_SOURCE_TYPE, '
   ||'    DEMAND_SOURCE_HEADER_ID,   '
   ||'    COMPLETED_QUANTITY,'
   ||'    SUBINVENTORY,'
   ||'    DEMAND_CLASS, '
   ||'    REQUIREMENT_DATE,'
   ||'    DEMAND_SOURCE_LINE, '
   ||'    SOURCE_DEMAND_SOURCE_LINE, '
   ||'    DEMAND_SOURCE_DELIVERY,'
   ||'    DEMAND_SOURCE_NAME,'
   ||'    PARENT_DEMAND_ID,'
   ||'    DEMAND_ID,'
   ||'    SOURCE_DEMAND_ID,'
   ||'    SALES_ORDER_NUMBER,'
   ||'    FORECAST_VISIBLE, '
   ||'    DEMAND_VISIBLE,'
   ||'    SALESREP_CONTACT,'
   ||'    SALESREP_ID,'
   ||'    CUSTOMER_ID,'
   ||'    SHIP_TO_SITE_USE_ID,'
   ||'    BILL_TO_SITE_USE_ID, '
   ||'    REQUEST_DATE, '
   ||'    PROJECT_ID, '
   ||'    TASK_ID, '
   ||'    PLANNING_GROUP,'
   ||'    SELLING_PRICE, '
   ||'    END_ITEM_UNIT_NUMBER, '
   ||'    ORDERED_ITEM_ID, '
   ||'    ORIGINAL_ITEM_ID,'
   ||'    LINK_TO_LINE_ID ,'
   ||'    CUST_PO_NUMBER, '
   ||'    CUSTOMER_LINE_NUMBER,'
   ||'    MFG_LEAD_TIME, '
   ||'    ORG_FIRM_FLAG,'
   ||'    SHIP_SET_ID, '
   ||'    ARRIVAL_SET_ID,'
   ||'    SHIP_SET_NAME, '
   ||'    ARRIVAL_SET_NAME,'
   ||'    ATP_REFRESH_NUMBER, '
   ||'    DELETED_FLAG, '
   ||'    ORIGINAL_SYSTEM_LINE_REFERENCE, '
   ||'    ORIGINAL_SYSTEM_REFERENCE, '
   ||'    CTO_FLAG, '
   ||'    AVAILABLE_TO_MRP,'
   ||'    DEMAND_PRIORITY,'
   ||'    PROMISE_DATE, '
   ||'    REFRESH_ID,'
   ||'    SR_INSTANCE_ID, '
   ||'    SCHEDULE_ARRIVAL_DATE, '
   ||'    LATEST_ACCEPTABLE_DATE,'
   ||'    SHIPPING_METHOD_CODE, '
   ||'    ATO_LINE_ID,'
   ||'    ORDER_DATE_TYPE_CODE,'
   ||'    INTRANSIT_LEAD_TIME '
   ||'   )  '
   ||'    SELECT '
   ||'    OOL.INVENTORY_ITEM_ID, '
   ||'    OOL.INVENTORY_ITEM_ID SOURCE_INVENTORY_ITEM_ID, '
   ||'    OOL.ORGANIZATION_ID, '
   ||'    (t.trans_qty * -1 ) PRIMARY_UOM_QUANTITY, '
   ||'    2 RESERVATION_TYPE, '
   ||'    TO_NUMBER(NULL) RESERVATION_QUANTITY, '
   ||'    decode(ool.SOURCE_DOCUMENT_TYPE_ID,10,8,2) DEMAND_SOURCE_TYPE, '
   ||'    so.SALES_ORDER_ID    DEMAND_SOURCE_HEADER_ID, '
   ||'    0 COMPLETED_QUANTITY, '
   ||'    TO_CHAR(NULL) SUBINVENTORY, '
   ||'    OOL.DEMAND_CLASS, '
   ||'    OOL.SCHEDULE_SHIP_DATE REQUIREMENT_DATE, '
   ||'    TO_CHAR(OOL.LINE_ID) DEMAND_SOURCE_LINE, '
   ||'    TO_CHAR(OOL.LINE_ID) SOURCE_DEMAND_SOURCE_LINE, '
   ||'    TO_CHAR(NULL) DEMAND_SOURCE_DELIVERY, '
   ||'    TO_CHAR(NULL) DEMAND_SOURCE_NAME, '
   ||'    TO_NUMBER(NULL) PARENT_DEMAND_ID, '
   ||'    MTL_DEMAND_S.nextval DEMAND_ID, '
   ||'    MTL_DEMAND_S.currval SOURCE_DEMAND_ID, '
   ||'    so.Concatenated_Segments, '
   ||'    ''Y'' , '
   ||'    ''Y'' , '
   ||'    TO_CHAR(NULL) Salesrep_Contact, '
   ||'    ool.salesrep_id, '
   ||'    ool.CUSTOMER_ID, '
   ||'    ool.SHIP_TO_SITE_ID, '
   ||'    ool.BILL_TO_SITE_ID, '
   ||'    ool.REQUEST_DATE, '
   ||'    ool.project_id, '
   ||'    ool.task_id, '
   ||'    TO_CHAR(NULL) PLANNING_GROUP, '
   ||'    ool.LIST_PRICE * decode(   GL_CURRENCY_API.get_rate_sql( '
   ||'				 h.transactional_curr_code, '
   ||'				 gsb.currency_code, '
   ||'				 h.booked_date, '
   ||'				 nvl(h.conversion_type_code, :b_prof1 )), '
   ||'				 -2,1,-1,1, '
   ||'				 GL_CURRENCY_API.get_rate_sql( '
   ||'				 h.transactional_curr_code, '
   ||'				 gsb.currency_code, '
   ||'				 h.booked_date, '
   ||'				 nvl(h.conversion_type_code, :b_prof2 )) '
   ||'				 ) LIST_PRICE, '
   ||'    ool.end_item_unit_number, '
   ||'    DECODE(DECODE(ool.ITEM_TYPE_CODE, '
   ||'          ''CLASS'',2, '
   ||'          ''CONFIG'',4, '
   ||'          ''MODEL'',1, '
   ||'          ''OPTION'' ,3, '
   ||'          ''STANDARD'',6, -1), 1, ool.inventory_item_id, NULL) ORDERED_ITEM_ID, '
   ||'    decode(ool.ORIGINAL_INVENTORY_ITEM_ID,-1,to_number(null), '
   ||'		  decode(ool.ITEM_RELATIONSHIP_TYPE,-1,to_number(null), '
   ||'						    2, ool.ORIGINAL_INVENTORY_ITEM_ID,  '
   ||'						    null,ool.ORIGINAL_INVENTORY_ITEM_ID,  '
   ||'						    to_number(null)) '
   ||'						    ) ORIGINAL_ITEM_ID, '
   ||'    TO_NUMBER(NULL) LINK_TO_LINE_ID, '
   ||'    nvl(ool.CUST_PO_NUMBER,''-1'') CUST_PO_NUMBER, '
   ||'    nvl(ool.CUSTOMER_LINE_NUMBER,''-1'') CUSTOMER_LINE_NUMBER, '
   ||'    ool.mfg_lead_time, '
   ||'    decode(ool.firm_demand_flag,NULL,to_number(null),''Y'',1,2) FIRM_DEMAND_FLAG, '
   ||'    ool.SHIP_SET_ID, '
   ||'    ool.ARRIVAL_SET_ID, '
   ||'    mrp_cl_function.get_ship_set_name(ool.SHIP_SET_ID) SHIP_SET_NAME, '
   ||'    mrp_cl_function.get_arrival_set_name(ool.ARRIVAL_SET_ID) ARRIVAL_SET_NAME, '
   ||'    TO_NUMBER(NULL) ATP_REFRESH_NUMBER, '
   ||'    2 DELETED_FLAG, '
   ||'    ool.original_system_reference, '
   ||'    ool.original_system_line_reference, '
   ||'    2 CTO_FLAG, '
   ||'    TO_NUMBER(NULL) available_to_mrp, '
   ||'    ool.DEMAND_PRIORITY, '
   ||'    ool.PROMISE_DATE, '
   ||'    TO_NUMBER(NULL) refresh_id, '
   ||'    :instance_id, '
   ||'    ool.SCHEDULE_ARRIVAL_DATE, '
   ||'    ool.LATEST_ACCEPTABLE_DATE, '
   ||'    ool.SHIPPING_METHOD_CODE, '
   ||'    ool.ATO_LINE_ID, '
   ||'    decode(h.ORDER_DATE_TYPE_CODE,''ARRIVAL'',2,1) ORDER_DATE_TYPE_CODE, '
   ||'    OOL.DELIVERY_LEAD_TIME  '
   ||'    FROM  '
   ||'        MRP_SN_SYS_ITEMS msik, '
   ||'        MTL_SALES_ORDERS_KFV so, '
   ||'        OE_ORDER_HEADERS_ALL h,       '
   ||'        GL_SETS_OF_BOOKS gsb, '
   ||'        AR_SYSTEM_PARAMETERS_ALL aspa   , '
   ||'        IC_TRAN_PND  t , '
   ||'        GMP_ITEM_APS i , '
   ||'        MRP_SN_ODR_LINES ool '
   ||'    WHERE  '
   ||'      t.item_id = i.item_id  '
   ||'      AND t.doc_type = :p_doc_type '
   ||'      AND ool.line_id = t.line_id '
   ||'      AND ( t.lot_id <> 0 OR t.location <> :p_prof ) '
   ||'      AND t.whse_code = i.whse_code  '
   ||'      AND t.orgn_code = i.plant_code  '
   ||'      AND t.completed_ind = 0  '
   ||'      AND t.trans_qty <> 0  '
   ||'      AND t.delete_mark = 0 '
   ||'      AND msik.inventory_item_id = i.aps_item_id '
   ||'      AND msik.organization_id = i.organization_id '
   ||'      AND so.Sales_Order_ID = t.doc_id  '
   ||'      AND ool.header_id = h.header_id(+) '
   ||'      AND  nvl(h.org_id,-99) = nvl(aspa.org_id,-99) '
   ||'      AND aspa.set_of_books_id = gsb.set_of_books_id(+) '
   ||'      AND h.org_id is null  ' ;

     IF MSC_CL_GMP_UTILITY.g_in_str_org  IS NOT NULL THEN
     v_sql_stmt := v_sql_stmt
     || '  AND i.organization_id ' || MSC_CL_GMP_UTILITY.g_in_str_org ;
     END IF;

    EXECUTE IMMEDIATE v_sql_stmt USING
      b_profile, b_profile, v_instance_id, pdoc_type, l_profile  ;

    END IF ;

    IF v_entity = 2 THEN
   log_message(MSC_CL_GMP_UTILITY.g_in_str_org);

   /* For Engine Reseration record inserted */
   v_sql_stmt := 'INSERT into msc_st_reservations ('
    || ' inventory_item_id,'
    || ' organization_id,'
    || ' sr_instance_id,'
    || ' transaction_id,'
    || ' parent_demand_id,'
    || ' disposition_id ,'
    || ' requirement_date,'
    || ' reserved_quantity,'
    || ' disposition_type,'
    || ' subinventory,'
    || ' reservation_type,'
    || ' demand_class,'
    || ' available_to_mrp,'
    || ' reservation_flag,'
    || ' planning_group,'
    || ' deleted_flag'
    || ' )'
    || ' SELECT '
    || '    i.aps_item_id, '
    || '    ool.organization_id, '
    || '    :p_instance_id , '
    || '    ((t.doc_id * 2 ) + 1), '  /* MTL_SALES_ORDERS.SALES_ORDER_ID */
    || '    ool.line_id, '
    || '    INV_SALESORDER.GET_SALESORDER_FOR_OEHEADER(ool.HEADER_ID), '
    || '    t.trans_date , '
    || '    (t.trans_qty * -1 ), '
    || '    2, '    /* DISPOSITION_TYPE */
    || '    NULL, ' /* SUBINVENTORY */
    || '    1,  '   /* RESERVATION_TYPE 1 is for Discrete ?? */
    || '    ool.demand_class, ' /* DEMAND_CLASS CODE */
    || '    NULL, ' /* AVAILABLE_TO_MRP */
    || '    2,  '   /* RESERVATION_FLAG */
    || '    NULL, ' /* PLANNING_GROUP */
    || '    2  '
    || ' FROM '
    || '   ic_tran_pnd' ||pdblink|| ' t,'
    || '   gmp_item_aps'||pdblink|| ' i,'
    || '   MRP_SN_ODR_LINES'||pdblink|| ' ool'
    || ' WHERE '
    || '     t.doc_type = :p_doctype '
    || ' AND t.item_id = i.item_id '
    || ' AND ool.line_id = t.line_id'
    || ' AND ( t.lot_id <> 0 OR '
    || '   t.location <> :loc_profile ) '
    || ' AND t.whse_code = i.whse_code '
    || ' AND t.orgn_code = i.plant_code '
    || ' AND t.completed_ind = 0 '
    || ' and ool.open_flag = ' || '''Y'''
    || ' AND t.trans_qty <> 0 '
    || ' AND t.delete_mark = 0 ' ;

     IF MSC_CL_GMP_UTILITY.g_in_str_org  IS NOT NULL THEN
     v_sql_stmt := v_sql_stmt
     || ' and i.organization_id ' || MSC_CL_GMP_UTILITY.g_in_str_org ;
     END IF;

    EXECUTE IMMEDIATE v_sql_stmt USING v_instance_id, pdoc_type, l_profile ;

    END IF; /* pentity */

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      log_message(' NO DATA FOUND exception in: MSC_CL_GMP_UTILITY.sales_order_allocation');
      return_status := TRUE;
    WHEN invalid_string_value  THEN
        log_message('Organization string is Invalid ' );
        return_status := FALSE;
    WHEN OTHERS THEN
      log_message('Failure occured during the sales_order_allocation extract');
      log_message(sqlerrm);
      return_status := FALSE;
END sales_order_allocation;

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
                          pinstance_id   IN  NUMBER,
                          prun_date      IN  DATE,
                          pdelimiter     IN  VARCHAR2,
                          return_status  IN  OUT NOCOPY BOOLEAN)
IS

TYPE gmp_cursor_typ IS REF CURSOR;
fcst_hdr   	gmp_cursor_typ;
cur_fcst_dtl   	gmp_cursor_typ;

l_design_stmt   	VARCHAR2(32000) ;
l_fcst_stmt             VARCHAR2(32700) ; /* Bug # 5086464 */
l_demands_stmt 		VARCHAR2(32000) ;
l_insert_set_stmt 	VARCHAR2(32000);

TYPE fcst_hdr_rec IS RECORD (
fcst_id 		NUMBER,
orig_forecast 		VARCHAR2(16),
fcst_name 		VARCHAR2(10),
fcst_set  		VARCHAR2(10),
desgn_ind 		NUMBER,
consumption_ind		NUMBER,
backward_time_fence	NUMBER,
forward_time_fence	NUMBER
);
TYPE fcst_dtl_rec_typ IS RECORD
   (
    inventory_item_id   NUMBER,
    organization_id     NUMBER,
    forecast_id         NUMBER,
    line_id             NUMBER,
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

cnt             	NUMBER ;
l_cnt           	NUMBER ;
curr_cnt        	NUMBER ;
temp_name       	VARCHAR2(10) ;
i               	NUMBER ;
j               	NUMBER ;
k               	NUMBER ;
x 			NUMBER ;
duplicate_found 	BOOLEAN ;
prev_org_id  		NUMBER ;
prev_fcst_id	  	NUMBER ;
prev_fcst_set		VARCHAR2(10);
prev_fcst    		VARCHAR2(10);
write_fcst		BOOLEAN ;
write_fcst_set		BOOLEAN ;
fcst_locn		NUMBER ;

BEGIN
cnt             	:= 0 ;
l_cnt           	:= 1 ;
curr_cnt        	:= 0 ;
temp_name       	:= NULL ;
i               	:= 1 ;
j               	:= 10 ;
k               	:= 0;
x 			:= 1;
duplicate_found 	:= FALSE ;
prev_org_id  		:= 0 ;
prev_fcst_id	  	:= 0 ;
d_index                 := 0 ;
i_index                 := 0 ;
prev_fcst_set           := '-1' ;
prev_fcst               := '-1';

    /* populate the org_string */
     IF MSC_CL_GMP_UTILITY.org_string(pinstance_id) THEN
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

        IF MSC_CL_GMP_UTILITY.g_in_str_org  IS NOT NULL THEN
        l_fcst_stmt := l_fcst_stmt
          || ' and msi.organization_id ' || MSC_CL_GMP_UTILITY.g_in_str_org ;
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
      				pschd_id	IN NUMBER ) return BOOLEAN
IS
   found_fcst 	BOOLEAN ;
   schd_cnt	NUMBER ;
   i       	NUMBER ;
   f1       	NUMBER ;
BEGIN
   found_fcst 	:= FALSE ;
   schd_cnt	:= 1 ;
   i       	:= 1 ;
   f1       	:= 1 ;

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
  			pinventory_item_id	IN  NUMBER,
  			porganization_id	IN  NUMBER) return BOOLEAN
IS
fcst_i        NUMBER ;
BEGIN
fcst_i        := 1 ;
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
		   pinventory_item_id	IN  NUMBER,
		   porganization_id	IN  NUMBER) return BOOLEAN
IS

so_i     NUMBER ;
BEGIN
so_i     := 0;
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
PROCEDURE consume_forecast( pinventory_item_id	IN  NUMBER,
			    porganization_id	IN  NUMBER,
			    papi_mode	        IN  BOOLEAN )
AS
cfcst_cnt      NUMBER ;
cso_cnt        NUMBER ;
found_forecast BOOLEAN ;

BEGIN

cfcst_cnt      := 0 ;
cso_cnt        := 0 ;
found_forecast := FALSE ;

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
  			  pinventory_item_id	IN  NUMBER,
  			  porganization_id	IN  NUMBER,
		          papi_mode	        IN BOOLEAN)
AS
fcst_i   NUMBER ;

BEGIN
fcst_i   := 0 ;
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
		    pinventory_item_id	IN  NUMBER,
		    porganization_id	IN  NUMBER,
		    papi_mode	        IN  BOOLEAN)
AS
so_i      NUMBER ;

BEGIN
so_i      := 0 ;
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
  statement_demands_api  VARCHAR2(32000) ;
  statement_demands      VARCHAR2(32000) ;

BEGIN
  statement_demands_api  := NULL ;
  statement_demands      := NULL ;
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

  statement_demands_api   VARCHAR2(32000) ;
  statement_demands       VARCHAR2(32000) ;

BEGIN
  statement_demands_api  := NULL ;
  statement_demands      := NULL ;
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
*        insert_designator
*
*   DESCRIPTION
*     Insert all the designator for schedule/item/warehouse combination
*   HISTORY
*        Created By : Rajesh Patangya
************************************************************************/
PROCEDURE insert_designator IS

i	       NUMBER ;
st_designators VARCHAR2(32000) ;

BEGIN

  i	         := 1 ;
  st_designators := NULL ;
  g_delimiter    := '/';
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
  porgn_id      IN  NUMBER,
  pinstance_id  IN  NUMBER,
  pinflate_wip  IN  NUMBER,
  pmin_xfer_qty IN  NUMBER)
IS

  v_resource_usage NUMBER ;
  v_res_seq        NUMBER ;
  v_schedule_flag  NUMBER ;
  v_parent_seq_num NUMBER ;
  v_rsrc_cnt       NUMBER ;
  v_start_date     DATE ;
  v_end_date       DATE ;
  old_activity     NUMBER ;
  j                NUMBER ;

BEGIN
  v_resource_usage := 0;
  v_res_seq        := 0;
  v_schedule_flag  := 0;
  v_parent_seq_num := 0;
  v_rsrc_cnt       := 0;
  v_start_date     := NULL;
  v_end_date       := NULL;
  old_activity     := -1;
  j                := 0;

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

PROCEDURE production_reservations ( pdblink        IN  VARCHAR2,
                          pinstance_id   IN  NUMBER,
                          prun_date      IN  DATE,
                          pdelimiter     IN  VARCHAR2,
                          return_status  IN OUT NOCOPY BOOLEAN)
IS
        v_stmt_alt_rsrc VARCHAR2(32000);
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
                ||'        gia.aps_item_id , '
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
                ||'        (SELECT  '
                ||'                DISTINCT item_id, aps_item_id, organization_id , whse_code '
                ||'         FROM gmp_item_aps'||pdblink||')  gia, '
                ||'        oe_order_lines_all'||pdblink||' ool, '
                ||'        pjm_project_parameters'||pdblink||' ppp  '
                ||'   WHERE '
                ||'         gbo.item_id = gia.item_id '
                ||'        AND gbo.organization_id = gia.organization_id '
                ||'        AND gbo.delete_mark = 0 '
                ||'        AND gbo.so_line_id = ool.line_id '
                ||'        AND ool.project_id = ppp.project_id (+) ';

                IF MSC_CL_GMP_UTILITY.g_in_str_org  IS NOT NULL THEN
                        v_stmt_alt_rsrc := v_stmt_alt_rsrc
                         ||'   AND EXISTS ( SELECT 1 FROM sy_orgn_mst'||pdblink||' som '
                         ||'   WHERE gia.whse_code = som.resource_whse_code )' ;
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

PROCEDURE update_last_setup_id (
   effbuf   OUT NOCOPY VARCHAR2,
   retcode      OUT NOCOPY NUMBER,
   f_orgn_code    IN  VARCHAR2,
   t_orgn_code    IN  VARCHAR2
)
IS
   cur_lsetup_id        ref_cursor_typ;
   resources            VARCHAR2(30);
   v_last_setup_id      NUMBER;
   v_resource_id        NUMBER;
   v_plant_code         VARCHAR2(10);
   v_batch_id           NUMBER;
   v_instance_id        NUMBER;
   x_select             VARCHAR2(32000);
   old_resource_id      NUMBER;
   old_instance_id      NUMBER;
   lsetup_updated       BOOLEAN;
   l_user_id            NUMBER;

BEGIN

   x_select        := NULL;
   old_resource_id := -1;
   old_instance_id := -1;
   lsetup_updated  := TRUE;

    l_user_id :=  to_number(FND_PROFILE.VALUE('USER_ID'));

    X_select := ' SELECT '
    ||' gbsr.sequence_dependent_id, '
    ||' crd.resource_id, '
    ||' grt.instance_id, '
    ||' crd.orgn_code, '
    ||' gbsr.batch_id '
    ||' FROM    gme_batch_step_resources gbsr, '
    ||'    gme_resource_txns grt, '
    ||'    sy_orgn_usr sou, '
    ||'    cr_rsrc_dtl crd, '
    ||'    gme_batch_header gbh '
    ||' WHERE   gbsr.batch_id = grt.doc_id '
    ||'    AND  gbh.batch_id = gbsr.batch_id '
    ||'    AND  gbh.plant_code = crd.orgn_code '
    ||'    AND  crd.orgn_code = sou.orgn_code '
    ||'    AND  sou.user_id = :user_id '
    ||'    AND  gbsr.batchstep_resource_id = grt.line_id '
    ||'    AND  grt.completed_ind = 1 '
    ||'    AND  crd.resources = gbsr.resources '
    ||'    AND  crd.resources = grt.resources '
    ||'    AND  crd.schedule_ind = 2 '
    ||'    AND   grt.instance_id IS NOT NULL '
    ||'    AND     crd.delete_mark = 0 ';

    IF f_orgn_code IS NOT NULL THEN
       x_select := x_select
       ||'    AND     crd.orgn_code >= :frm_orgn ' ;
    END IF;
    IF t_orgn_code IS NOT NULL THEN
       x_select := x_select
       ||'    AND     crd.orgn_code <= :to_orgn ' ;
    END IF;

    x_select := x_select
    ||'    ORDER BY grt.resources, grt.instance_id, '
    ||'       grt.end_date DESC, grt.poc_trans_id ' ;

   IF f_orgn_code IS NOT NULL AND t_orgn_code IS NOT NULL THEN
      OPEN cur_lsetup_id FOR x_select USING l_user_id, f_orgn_code, t_orgn_code;
   ELSIF f_orgn_code IS NOT NULL AND t_orgn_code IS NULL THEN
      OPEN cur_lsetup_id FOR x_select USING l_user_id, f_orgn_code;
   ELSIF f_orgn_code IS NULL AND t_orgn_code IS NOT NULL THEN
      OPEN cur_lsetup_id FOR x_select USING l_user_id, t_orgn_code;
   ELSE
      OPEN cur_lsetup_id FOR x_select USING l_user_id;
   END IF;

   LOOP
      FETCH cur_lsetup_id INTO v_last_setup_id, v_resource_id, v_instance_id,
        v_plant_code, v_batch_id;
      EXIT WHEN cur_lsetup_id%NOTFOUND;

      IF (old_resource_id <> v_resource_id OR old_instance_id <> v_instance_id) THEN
         old_resource_id := v_resource_id;
         old_instance_id := v_instance_id;
         lsetup_updated := FALSE;
      END IF;

      IF NOT (lsetup_updated) THEN
         lsetup_updated := TRUE;
            UPDATE gmp_resource_instances gri
            SET gri.last_setup_id = v_last_setup_id
            WHERE gri.resource_id = v_resource_id
              AND gri.instance_id = v_instance_id;
      END IF;
   END LOOP;
      CLOSE cur_lsetup_id ;
   COMMIT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        log_message(' NO_DATA_FOUND exception raised in Procedure: MSC_CL_GMP_UTILITY.update_last_setup_id ' );
      	RAISE;

    WHEN OTHERS THEN
        log_message('Error in Last Setup ID Program: '||SQLERRM);
        RAISE;

END update_last_setup_id;

FUNCTION GMP_APSDS_UTILITY1_R10
            (
                          p_dblink      IN VARCHAR2,
                          p_delimiter   IN VARCHAR2,
                          p_instance    IN INTEGER,
                          p_run_date    IN DATE,
                          p_num1        IN NUMBER,
                          p_num2        IN NUMBER,
                          p_num3        IN NUMBER,
                          p_num4        IN NUMBER,
                          p_varchar1    IN VARCHAR2,
                          p_varchar2    IN VARCHAR2,
                          p_varchar3    IN VARCHAR2,
                          p_varchar4    IN VARCHAR2
            ) RETURN INTEGER IS
BEGIN
    return 0;
END GMP_APSDS_UTILITY1_R10;

PROCEDURE GMP_APSDS_PROC1_R10
            (
                          p_dblink      IN VARCHAR2,
                          p_delimiter   IN VARCHAR2,
                          p_instance    IN INTEGER,
                          p_run_date    IN DATE,
                          p_num1        IN NUMBER,
                          p_num2        IN NUMBER,
                          p_num3        IN NUMBER,
                          p_num4        IN NUMBER,
                          p_varchar1    IN VARCHAR2,
                          p_varchar2    IN VARCHAR2,
                          p_varchar3    IN VARCHAR2,
                          p_varchar4    IN VARCHAR2,
                          return_status  OUT NOCOPY BOOLEAN
            ) IS
BEGIN
    return_status := TRUE;
END GMP_APSDS_PROC1_R10;

-- --------------------OPM Production Order Package End ------------

/*
REM+==========================================================================+
REM| PROCEDURE NAME                                                           |
REM|    rsrc_extract                                                          |
REM|                                                                          |
REM| Type                                                                     |
REM|    public                                                                |
REM|                                                                          |
REM| DESCRIPTION                                                              |
REM|    The following procedure rows into msc_st_department_resources         |
REM|                                                                          |
REM| Input Parameters                                                         |
REM|    p_instance_id - Instance Id                                           |
REM|    p_db_link - Database Link                                             |
REM|    return_status - Status return variable                                |
REM|                                                                          |
REM| Output Parameters                                                        |
REM|    None                                                                  |
REM|                                                                          |
REM|                                                                          |
REM| HISTORY                                                                  |
REM|    Created 5th Aug 1999 by Sridhar Gidugu (OPM Development Oracle US)    |
REM|    8/17/99 - Changed to Dynamic SQL , added db_link                      |
REM|    10/13/99 - Added deleted_flag in the insert statement                 |
REM|    11/23/99 - Changed value of aggregate_resource_flag from 1 to 2       |
REM|    01/12/00 - Added owning_department_id column in the Insert statement  |
REM|             - Bug# 1140113                                               |
REM|    4/03/00 - using mtl_organization_id from ic_whse_mst instead of       |
REM|            - organization_id from sy_orgn_mst - Bug# 1252322             |
REM|    4/18/00 - Fixed Bug# 1273557 - Department count is Zero               |
REM|            - Changes made to the insert statement, changed               |
REM|            - s.organization_id to w.mtl_organization_id                  |
REM|    12/26/01 - Adding Code changes for Resource Utilization and Resource  |
REM|               Efficiency - B2163006                                      |
REM|    12/20/02 - Sridhar Gidugu  B2714583, Populated 3 new columns for      |
REM|                               msc_st_department_resources                |
REM|                               1.Resource_excess_type,                    |
REM|                               2.Resource_shortage_type                   |
REM|                               3.User_time_fence                          |
REM|    01/09/03 - Sridhar Gidugu  Used mrp_planning_exception_sets           |
REM|                               instead of mrp_planning_exception_sets_v   |
REM|                               also added extra join with Organization_id |
REM|    01/22/03 - Sridhar Gidugu  Insert statement for Resource Groups       |
REM|    05/11/03 - Rajesh Patangya Used to_number(NULL) in palce of NULL      |
REM|    05/20/03 - Sridhar Gidugu  B2971120 Populating new columns            |
REM|                               Over_utilized_percent and                  |
REM|                               under_utilized_percent in dept_rsc table   |
REM|  04/21/2004   - Navin Sinha - B3577871 -ST:OSFME2: collections failing   |
REM|                                in planning data pull.                    |
REM|                                Added handling of NO_DATA_FOUND Exception.|
REM|                                And return the return_status as TRUE.     |
REM|  12/30/04 - Arvind Karuppasamy - B4081551, Modified query in rsrc_extract|
REM|                                  to select the resource description from |
REM|                                  cr_rsrc_mst.			      |
REM|  02/17/05 - Teresa Wong - B4179616 Increased length of variables holding |
REM|                                   dynamic sql stmts with string of org   |
REM|                                   codes.                                 |
REM+==========================================================================+
*/

PROCEDURE rsrc_extract(p_instance_id IN NUMBER,
                       p_db_link     IN VARCHAR2,
                       return_status OUT NOCOPY BOOLEAN) is

ins_dept_res     varchar2(32000);
ins_res_group    varchar2(32000);
ins_res_instance varchar2(32000);
dep_ref_cursor   ref_cursor_typ;
BEGIN
stmt_no          := 0 ;

/*  New changes made for msc_st_department_resources - using mtl_organization_id
    from ic_whse_mst instead of organization_id from sy_orgn_mst
    table  - Bug # 1252322
    Commented the Where clause resource_whse_code is NOT NULL as whse code in
    ic_whse_mst is never NULL - 04/03/2000
*/

    IF return_status THEN
       v_cp_enabled := TRUE;
    ELSE
       v_cp_enabled := FALSE;
    END IF;

    /* populate the org_string */
     IF MSC_CL_GMP_UTILITY.org_string(p_instance_id) THEN
        NULL ;
     ELSE
        RAISE invalid_string_value  ;
     END IF;

        /* note that we introduced substr(resources) as the
          final msc table has the column at 10 char only. If and when the MSC
          column width increases we shall remove substr */

    /* AKARUPPA 12/30/2004 B4081551 - Modified query to select resource description from cr_rsrc_mst */

    stmt_no := 10 ;
    ins_dept_res := ' INSERT INTO msc_st_department_resources '
               || ' ( organization_id,  '
               || ' sr_instance_id, '
               || ' resource_id, '
               || ' department_id, '
               || ' resource_code, '
               || ' resource_description,  '
               || ' department_code, '
               || ' owning_department_id, '
               || ' line_flag, '
               || ' aggregated_resource_flag, '
               || ' capacity_units, '
               || ' available_24_hours_flag, '
               || ' resource_cost,  '
               || ' ctp_flag,     '
               || ' deleted_flag,  '
               || ' resource_excess_type,  '
               || ' resource_shortage_type,  '
               || ' user_time_fence,  '
               || ' over_utilized_percent,  '    /* B2971120 */
               || ' under_utilized_percent,  '   /* B2971120 */
               || ' efficiency,  '
               || ' utilization,  '
               || ' planning_exception_set,  '
               || ' resource_group_name,  '
               || ' bottleneck_flag,  '
               || ' chargeable_flag, '
               || ' capacity_tolerance, '
               || ' batchable_flag, '
               || ' batching_window, '
               || ' min_capacity, '
               || ' max_capacity, '
               || ' unit_of_measure, '
               || ' idle_time_tolerance, '
               || ' sds_scheduling_window, '
               || ' batching_penalty, '
               || ' schedule_to_instance, '
 /*B4487118 - HLINK GC:(RV): MULTIPLE ROWS ARE DISPALYED FOR A RESOURCE IN THE RV*/
               || ' resource_type '
               || ') '
               || '  SELECT w.mtl_organization_id , '
               || '  :instance_id, '
               || '  ((r.resource_id * 2) + 1),'         /* B1177070 encoded */
               || '  ((w.mtl_organization_id * 2) + 1),' /* B1177070 encoded */
               || '  substrb(r.resources,1,10), '
               || '  rsm.resource_desc, '                /* B4081551 */
               || '  w.whse_code   , '
               || '  ((w.mtl_organization_id * 2) + 1)  , ' /* B1177070 */
               || '  2, '            /* Line Flag */
               || '  2, '      /* Yes = 1 and No = 2 resource Flag */
               || '  r.assigned_qty, '
               || '  2, '      /* Avail 24 hrs flag */
               || '  r.nominal_cost, '
               || '  1,'     /* for ATP to check Resources (RDP)*/
               || '  2, '
               || '  mrp.resource_excess_type, '      /*  B2714583 */
               || '  mrp.resource_shortage_type, '    /* B2714583 */
               || '  mrp.user_time_fence, '           /* B2714583 */
               || '  mrp.over_utilized_percent, '     /* B2971120 */
               || '  mrp.under_utilized_percent, '    /* B2971120 */
               || '  r.efficiency, '                  /* B2163006 */
               || '  r.utilization, '                 /* B2163006 */
               || '  r.planning_exception_set, '      /* B2714583 */
               || '  r.group_resource, '
               || '  NULL, '
               || '  decode(r.capacity_constraint,1,1,2), '
               || '  r.capacity_tolerance, '
               || '  2, ' /* batchable_flag */
               || '  NULL, '
               || '  r.min_capacity, '
               || '  r.max_capacity, '
               || '  sou.uom_code, '
               || '  idle_time_tolerence, '
               || '  sds_window, '
               || '  NULL, '
            /* If the Resource is scheduled to Instance, then value is Yes else No */
               || '  decode(r.schedule_ind,2,1,2), '
   /*B4487118 - HLINK GC:(RV): MULTIPLE ROWS ARE DISPALYED FOR A RESOURCE IN THE RV*/
               || '  1 '
               || '  FROM   cr_rsrc_dtl'||p_db_link||' r, '
	       || '         cr_rsrc_mst'||p_db_link||' rsm, ' /* B4081551 */
               || '         mrp_planning_exception_sets'||p_db_link||' mrp, '
               || '         sy_orgn_mst'||p_db_link||' p, '
               || '         ic_whse_mst'||p_db_link||' w, '
               ||'          sy_uoms_mst'||p_db_link||' sou '
               || '  WHERE  r.orgn_code = p.orgn_code '
               || '  AND    r.planning_exception_set = mrp.exception_set_name '
               || '  AND    w.mtl_organization_id = mrp.organization_id '
	       || '  AND    r.resources = rsm.resources ' /* B4081551 */
               || '  AND    p.resource_whse_code = w.whse_code ' ;

        IF MSC_CL_GMP_UTILITY.g_in_str_org  IS NOT NULL THEN
         ins_dept_res := ins_dept_res
                   ||'   AND w.mtl_organization_id ' || MSC_CL_GMP_UTILITY.g_in_str_org ;
        END IF;

         ins_dept_res := ins_dept_res
               || '  AND    r.delete_mark = 0 '
               || '  AND    rsm.delete_mark = 0 ' /* B4081551 */
               || '  AND    p.delete_mark = 0 '
               || '  AND    w.delete_mark = 0 '
               ||'   AND sou.delete_mark = 0 '
               ||'   AND sou.um_code = r.capacity_uom '
               || '  UNION ALL '
               || '  SELECT w.mtl_organization_id , '
               || '  :instance_id1, '
               || '  ((r.resource_id * 2) + 1),'         /* B1177070 encoded */
               || '  ((w.mtl_organization_id * 2) + 1),' /* B1177070 encoded */
               || '  substrb(r.resources,1,10), '
               || '  rsm.resource_desc, '                /* B4081551 */
               || '  w.whse_code   , '
               || '  ((w.mtl_organization_id * 2) + 1)  , ' /* B1177070 */
               || '  2, '            /* Line Flag */
               || '  2, '      /* Yes = 1 and No = 2 resource Flag */
               || '  r.assigned_qty, '
               || '  2, '      /* Avail 24 hrs flag */
               || '  r.nominal_cost, '
               || '  1,'     /* for ATP to check Resources (RDP)*/
               || '  2, '
               || '  to_number(NULL), '      /*  B2714583 */
               || '  to_number(NULL), '      /*  B2714583 */
               || '  to_number(NULL), '      /*  B2714583 */
               || '  to_number(NULL), '      /*  B2971120 */
               || '  to_number(NULL), '      /*  B2971120 */
               || '  r.efficiency, '         /* B2163006 */
               || '  r.utilization, '        /* B2163006 */
               || '  r.planning_exception_set, ' /* B2714583 */
               || '  r.group_resource, '
               || '  NULL, '
               || '  decode(r.capacity_constraint,1,1,2), '
               || '  r.capacity_tolerance, '
               || '  2, ' /* batchable_flag */
               || '  NULL, '
               || '  r.min_capacity, '
               || '  r.max_capacity, '
               || '  sou.uom_code, '
               || '  idle_time_tolerence, '
               || '  sds_window, '
               || '  NULL, '
            /* If the Resource is scheduled to Instance, then value is Yes else No */
               || '  decode(r.schedule_ind,2,1,2), '
   /*B4487118 - HLINK GC:(RV): MULTIPLE ROWS ARE DISPALYED FOR A RESOURCE IN THE RV*/
               || '  1 '
               || '  FROM   cr_rsrc_dtl'||p_db_link||' r, '
	       || '         cr_rsrc_mst'||p_db_link||' rsm, ' /* B4081551 */
               || '         sy_orgn_mst'||p_db_link||' p, '
               || '         ic_whse_mst'||p_db_link||' w, '
               ||'          sy_uoms_mst'||p_db_link||' sou '
               || '  WHERE  r.orgn_code = p.orgn_code '
               || '  AND    r.planning_exception_set IS NULL '
               || '  AND    p.resource_whse_code = w.whse_code '
	       || '  AND    r.resources = rsm.resources ' /* B4081551 */
               || '  AND    r.delete_mark = 0 '
               || '  AND    rsm.delete_mark = 0 ' /* B4081551 */
               || '  AND    p.delete_mark = 0 '
               || '  AND    w.delete_mark = 0 '
               ||'   AND sou.delete_mark = 0 '
               ||'   AND sou.um_code = r.capacity_uom ';

        IF MSC_CL_GMP_UTILITY.g_in_str_org  IS NOT NULL THEN
         ins_dept_res := ins_dept_res
               ||'   AND w.mtl_organization_id ' || MSC_CL_GMP_UTILITY.g_in_str_org ;
        END IF;

         EXECUTE IMMEDIATE  ins_dept_res USING p_instance_id, p_instance_id;

    /* Insert into MSC_ST_RESOURCE_GROUPS for Bottleneck Resources
       Sending only those resources that are used in Planning for APS
    */
    stmt_no := 20 ;
    ins_res_group := ' INSERT INTO msc_st_resource_groups '
               || ' ( group_code,  '
               || '   meaning, '
               || '   description,  '
               || '   from_date,  '
               || '   to_date,  '
               || '   enabled_flag,  '
               || '   sr_instance_id '
               || ' ) '
               || '  SELECT distinct '
               || '   crd.group_resource , '
               || '   crm.resource_desc,'
               || '   crm.resource_desc,'
               || '   sysdate,'
               || '   NULL,'
               || '   1,'
               || '   :instance_id '
               || '  FROM  sy_orgn_mst'||p_db_link||' sy, '
               || '        cr_rsrc_dtl'||p_db_link||' crd, '
               || '        cr_rsrc_mst'||p_db_link||' crm '
               || '  WHERE sy.orgn_code = crd.orgn_code  '
               || '    AND sy.resource_whse_code is NOT NULL '
               || '    AND crd.resources = crm.resources '
               || '    AND crd.group_resource = crm.resources '
               || '    AND crd.delete_mark = 0 ';

        IF MSC_CL_GMP_UTILITY.g_in_str_org  IS NOT NULL THEN
         ins_res_group := ins_res_group
               || '    AND EXISTS ( SELECT 1 FROM gmp_item_aps'||p_db_link||' gia '
               || '    WHERE gia.whse_code = sy.resource_whse_code )' ;
        END IF;

         EXECUTE IMMEDIATE  ins_res_group USING p_instance_id;

        /* Now extract the resource instances too -
        The instance extraction was put under resource avaialbility
        extraction but to keep it in synch with Discrete collection, it is being
        moved here. */

     stmt_no := 30 ;
     ins_res_instance := ' INSERT INTO msc_st_dept_res_instances '
         ||' ( sr_instance_id, '
         ||'   res_instance_id, '
         ||'   resource_id, '
         ||'   department_id, '
         ||'   organization_id, '
         ||'   serial_number, '
         ||'   equipment_item_id, '
         ||'   last_known_setup, '
         ||'   effective_start_date, '
         ||'   effective_end_date, '
         ||'   deleted_flag '
         ||' ) '
         ||' SELECT :instance_id, '
         ||'   ((gri.instance_id * 2) + 1), '
         ||'   ((gri.resource_id * 2) + 1) x_resource_id,  '
         ||'   ((iwm.mtl_organization_id * 2) + 1) department_id,'  /* encoded */
         ||'   iwm.mtl_organization_id ,  '
         ||'   NVL(gri.eqp_serial_number, to_char(gri.instance_number)),  '
         ||'   gri.equipment_item_id,  '
         ||'   gri.last_setup_id, '  -- Conc Prog routine will populate this
         ||'   gri.eff_start_date,  '
         ||'   gri.eff_end_date, '
         ||'   2 '
         ||' FROM  '
         ||'   gmp_resource_instances'||p_db_link||' gri,  '
         ||'   cr_rsrc_dtl'||p_db_link||' crd, '
         ||'   sy_orgn_mst'||p_db_link||' som,'
         ||'   ic_whse_mst'||p_db_link||' iwm '
         ||' WHERE  '
         ||'       gri.resource_id = crd.resource_id '
         ||'   AND crd.schedule_ind = 2 '
         ||'   AND crd.orgn_code = som.orgn_code '
         ||'   AND gri.inactive_ind = 0  '
         ||'   AND crd.delete_mark = 0 '
         ||'   AND som.delete_mark = 0'
         ||'   AND iwm.delete_mark = 0'
         ||'   AND som.resource_whse_code = iwm.whse_code' ;

     IF MSC_CL_GMP_UTILITY.g_in_str_org  IS NOT NULL THEN
        ins_res_instance := ins_res_instance
         ||'   AND EXISTS ( SELECT 1 FROM gmp_item_aps'||p_db_link||' gia '
         ||'   WHERE gia.whse_code = som.resource_whse_code )' ;
     END IF;

     EXECUTE IMMEDIATE  ins_res_instance USING p_instance_id;

    return_status := TRUE;

EXCEPTION

    WHEN invalid_string_value  THEN
        log_message('APS string is Invalid, check for Error condition' );
        return_status := FALSE;
    WHEN NO_DATA_FOUND THEN /* B3577871 */
        log_message(' NO_DATA_FOUND exception raised in Procedure: MSC_CL_GMP_UTILITY.Rsrc_extract ' );
        return_status := TRUE;
    WHEN  OTHERS THEN
        log_message('Error in department/Res Group Insert: '||p_instance_id);
        log_message('stmt_no: ' || stmt_no || '--' || sqlerrm);
        return_status := FALSE;

END rsrc_extract;

/*
REM+==========================================================================+
REM| PROCEDURE NAME                                                           |
REM|    net_rsrc                                                              |
REM|                                                                          |
REM| Type                                                                     |
REM|    public                                                                |
REM|                                                                          |
REM| DESCRIPTION                                                              |
REM|    The following procedure inserts rows into                             |
REM|    msc_st_net_rsrc_avail table                                           |
REM|                                                                          |
REM| Input Parameters                                                         |
REM|    p_instance_id - Instance Id                                           |
REM|    p_org_id - Organization id                                            |
REM|    p_simulation_set - Simulation Set                                     |
REM|    p_shift_no - Shift number                                             |
REM|    p_cal_date - Calendar date                                            |
REM|    p_from_time - shift starting time                                     |
REM|    p_to_time - Shift Ending time                                         |
REM|                                                                          |
REM| Output Parameters                                                        |
REM|    None                                                                  |
REM|                                                                          |
REM|                                                                          |
REM| HISTORY                                                                  |
REM|    Created 5th Aug 1999 by Sridhar Gidugu (OPM Development Oracle US)    |
REM|    10/13/99 - Added deleted_flag in the insert statement                 |
REM|    01/24/01 - Bug Fix - 1612090, Added new name to the unavailable view  |
REM|                                                                          |
REM|                                                                          |
REM+==========================================================================+
*/

PROCEDURE net_rsrc(p_instance_id    IN NUMBER,
                   p_org_id         IN NUMBER,
                   p_simulation_set IN VARCHAR2,
                   p_resource_id    IN NUMBER,
                   p_assigned_qty   IN NUMBER,
                   p_shift_num      IN NUMBER,
                   p_calendar_date  IN DATE,
                   p_from_time      IN NUMBER,
                   p_to_time        IN NUMBER ) IS
BEGIN
stmt_no          := 31;
    /*  Call Unavail_rsrc_proc */
      INSERT INTO msc_st_net_resource_avail
                            ( organization_id,
                            sr_instance_id,
                            resource_id,
                            department_id,
                            simulation_set,
                            shift_num,
                            shift_date,
                            from_time,
                            to_time,
                            capacity_units,
                            deleted_flag
                            )
                      values
                            ( p_org_id,
                            p_instance_id,
                            ((p_resource_id * 2) + 1), /* B1177070 */
                            ((p_org_id * 2) + 1),  /* B1177070 encoded key */
                            p_simulation_set,
                            p_shift_num,
                            p_calendar_date,
                            p_from_time,
                            p_to_time,
                            p_assigned_qty,
                            2
                            );
EXCEPTION
    WHEN OTHERS THEN
      log_message('Failure:net_rsrc Occured ' || stmt_no);

END net_rsrc;

/*
REM+==========================================================================+
REM| PROCEDURE NAME                                                           |
REM|    update_trading_partners                                               |
REM|                                                                          |
REM| Type                                                                     |
REM|    public                                                                |
REM|                                                                          |
REM| DESCRIPTION                                                              |
REM|                                                                          |
REM|    This procedure updates the following table :                          |
REM|                                                                          |
REM|                      1. msc_st_trading_partners                          |
REM|                                                                          |
REM| Input Parameters                                                         |
REM|    p_org_id - Organization_id                                            |
REM|    p_cal_code - Calendar_code                                            |
REM|                                                                          |
REM| Output Parameters                                                        |
REM|    None                                                                  |
REM|                                                                          |
REM|                                                                          |
REM| HISTORY                                                                  |
REM|    Created 5th Aug 1999 by Sridhar Gidugu (OPM Development Oracle US)    |
REM|    8/30/99 - Removed the existing Trading Partner Procedure and changed  |
REM|              to a single Update Procedure.                               |
REM|    10/1/99 - Changed Updating Trading Partners,                          |
REM|            - Updated Organization_typw with a value 2 and changed        |
REM|            - partner_type = 3                                            |
REM|                                                                          |
REM|                                                                          |
REM+==========================================================================+
*/
PROCEDURE update_trading_partners(p_org_id      IN NUMBER,
                                  p_cal_code    IN VARCHAR2,
                                  return_status OUT NOCOPY BOOLEAN) IS
BEGIN

    IF return_status THEN
       v_cp_enabled := TRUE;
    ELSE
       v_cp_enabled := FALSE;
    END IF;

      stmt_no  := 32;
    -- The Following Update statement the Trading Parters table with the
    -- Calendar Code for the Organization that uses the Calendar.
      UPDATE MSC_ST_TRADING_PARTNERS
      SET calendar_code = p_cal_code,
          organization_type = 2
      WHERE sr_tp_id = p_org_id
      AND partner_type = 3;


      return_status := TRUE;
EXCEPTION
    WHEN OTHERS THEN
      log_message('Failure:Trading Partners Update Occured ' || stmt_no);
      return_status := FALSE;

END update_trading_partners; /* End of Updating Trading partners */

/*
REM+==========================================================================+
REM| PROCEDURE NAME                                                           |
REM|    get_cal_no                                                            |
REM|                                                                          |
REM| Type                                                                     |
REM|    public                                                                |
REM|                                                                          |
REM| DESCRIPTION                                                              |
REM|    The following Procedure checks for the value of calendar no and       |
REM|    assigns a new value if the lenght exceeds 10 characters               |
REM|                                                                          |
REM| Input Parameters                                                         |
REM|    p_cal_id - Calendar Id                                                |
REM|    p_cal_no - Calendar No                                                |
REM|                                                                          |
REM| Output Parameters                                                        |
REM|    p_out_cal                                                             |
REM|    p_already_prefixed                                                    |
REM|                                                                          |
REM|                                                                          |
REM| HISTORY                                                                  |
REM|    Created 24th Sep 1999 by Sridhar Gidugu (OPM Development Oracle US)   |
REM|    05/03/2000 - Changed 14characters check to 10 Characters to include   |
REM|                 Instance code as prefix to Calendar code which has       |
REM|                 already has 4 Characters - Bug#1288143                   |
REM|    07/07/2000 - Modified get_cal_no Function to a Procedure, comparisons |
REM|                 with Calendar Code which has Instance Code Prefixes are  |
REM|                 taken  care - Bug# 1337084                               |
REM|                                                                          |
REM|                                                                          |
REM+==========================================================================+
*/

PROCEDURE get_cal_no( p_cal_id           IN  NUMBER,
                      p_cal_no           IN  VARCHAR2,
                      p_icode            IN  VARCHAR2,
                      p_out_cal          OUT NOCOPY VARCHAR2,
                      p_already_prefixed OUT NOCOPY VARCHAR2 ) IS

  temp_cal_no          VARCHAR2(10) ;
  prefixed_temp_cal_no VARCHAR2(14) ;
  out_cal_no           VARCHAR2(14) ;
  i                    NUMBER;
  k                    NUMBER;
  j                    NUMBER;
  j_char               VARCHAR2(10) ;
  found                NUMBER ;
  already_prefixed     VARCHAR2(3) ;

BEGIN

  temp_cal_no          := NULL;
  prefixed_temp_cal_no := NULL ;
  out_cal_no           := NULL;
  i                    := 0 ;
  k                    := 0 ;
  j                    := 0 ;
  j_char               := NULL;
  found                := 0;
  stmt_no              := 0;
  already_prefixed     := 'NO';

/* If calendar no is less than 10 , return  */

  IF length(p_cal_no) < 10 or plsqltbl_rec.COUNT < 1 THEN
     out_cal_no := substrb(p_cal_no,1,10);
  ELSE

  /* The default name generation is the first 10 chars of the calendar no */

     temp_cal_no := substrb(p_cal_no,1,10);

 /* 07/07/2000 - Adding Instance code as a Prefix to the Calendar Code. */

     prefixed_temp_cal_no := p_icode||':'||temp_cal_no;

     out_cal_no := NULL;

  stmt_no   := 10;
  FOR i IN 1..plsqltbl_rec.COUNT
  LOOP
    /*  if a row has already been inserted for the calendar id
        use the value from that row and stop the loop  */

      IF plsqltbl_rec(i).calendar_id = p_cal_id
      THEN

     /* Commented the following statement and used substrb to pick first
        10 characters as it causes a buffer too small problem - Bug#1288143 */

          out_cal_no := substrb(plsqltbl_rec(i).calendar_no,1,14);

     /*
       07/07/2000 - Added a check flag to indicate the Instance is already prefixed
             and this check is being used at the time when the PLSQL table is
             constructed, where in it will not assign an Instance Prefix if the
             calendar_code is already prefixed - Bug# 1337084.
     */

          already_prefixed := 'YES';
          found := 1;
          EXIT;
      END IF;

  END LOOP; /* End loop for check in the PL/SQL tbl */

  IF found = 0 THEN
      k := 10;
      j := 0;
      j_char := NULL;

      /*
       the loop will try the default value then change it if necessary and
       until we have exhasted all of the values of 0-99999999999999 (10 chars of numbers)
      */
      stmt_no   := 20;
      LOOP
        /* { */
        temp_cal_no := j_char || substrb(p_cal_no,1,k);
      /*
         this loop goes through the current list to see if there is a duplicate
         if found we stop and generate a new value then try again
      */

        FOR i IN 1..plsqltbl_rec.COUNT LOOP
        /*  { */

/*  07/07/00 - Comparing the Calendar number with Prefixed Calendar Code - Bug#1337084 */

          IF plsqltbl_rec(i).calendar_no = p_icode||':'||temp_cal_no THEN
            EXIT;
          END IF;
          IF i =  plsqltbl_rec.COUNT THEN
            found := 1;
            out_cal_no := temp_cal_no;
          END IF;
        /* }  */
        END LOOP ;

        /*  if we found a value or reached the max we stop */
        IF found = 1 or j = 9999999999 THEN
          EXIT;
        END IF;

        /*  to get a unique value we keep taking one char at a time from the
         the calendar_no.
        */
        j := j + 1;
        j_char := TO_CHAR(j);
        k := 10 - length(j_char);

      /* } */
      END LOOP;
  END IF;

  END IF ;

        p_out_cal := out_cal_no;
        p_already_prefixed := already_prefixed ;
EXCEPTION
    WHEN OTHERS THEN
      log_message('Failure:get_cal_no Occured ' || stmt_no);
      p_out_cal := NULL ;
      p_already_prefixed := already_prefixed ;

END get_cal_no; /* End of the Procedure GET_CAL_NO */
/*
REM+==========================================================================+
REM| PROCEDURE NAME                                                           |
REM|    retrieve_calendar_detail                                              |
REM|                                                                          |
REM| Type                                                                     |
REM|    public                                                                |
REM|                                                                          |
REM| DESCRIPTION                                                              |
REM|                                                                          |
REM|                                                                          |
REM| Input Parameters                                                         |
REM|    p_orgn_code - Orgn Code                                               |
REM|    p_org_id - Organization id                                            |
REM|    p_cal_id - calendar_id                                                |
REM|    p_instance_id - Instance Id                                           |
REM|    p_delimiter - Delimiter                                               |
REM|    p_db_link - Data Base Link                                            |
REM|                                                                          |
REM| Output Parameters                                                        |
REM|    return_status                                                         |
REM|                                                                          |
REM|                                                                          |
REM| HISTORY                                                                  |
REM|    Created 5th Aug 1999 by Sridhar Gidugu (OPM Development Oracle US)    |
REM|    9/20/99 - created the Retrieve calendar Procedure                     |
REM|    10/13/99 - Added deleted_flag in the insert statement                 |
REM|    10/18/99 - Changed value of Exception set Id from 1 to -1             |
REM|    12/09/99 - Added Code to include all Calendar Days                    |
REM|    12/17/99 - Fixed Code for Bug# 1117565                                |
REM|    02/01/00 - next seq and prior seqs are made same as seq number in     |
REM|             - msc_calendar_dates insert, bug#1175906                     |
REM|             - similarly for next date and prior date are same as calendar|
REM|             - dates                                                      |
REM|    03/01/00 - Added Code to not to include rows which have               |
REM|               shift_duration as zero seconds - Bug#1221285               |
REM|    03/20/03 - Added Inserts to msc_st_shift_times table - 2213101        |
REM|    03/20/03 - Added Inserts to msc_st_shift_dates table - 2213101        |
REM|                                                                          |
REM|                                                                          |
REM+==========================================================================+
*/
PROCEDURE retrieve_calendar_detail( p_cal_id      IN NUMBER,
                                    p_calendar_no IN VARCHAR2,
                                    p_cal_desc    IN VARCHAR2,
                                    p_run_date    IN DATE,
                                    p_db_link     IN VARCHAR2,
                                    p_instance_id IN NUMBER,
                                    p_usage       IN VARCHAR2,
                                    return_status OUT NOCOPY BOOLEAN) IS
cal_cur             ref_cursor_typ;
cal_count           NUMBER;
cal_start_date      DATE;
cal_end_date        DATE;
sql_stmt2           VARCHAR2(32700);
sql_stmt3           VARCHAR2(32700);
v_cal_date          DATE;
v_shift_num         NUMBER;
v_from_time         NUMBER;
v_to_time           NUMBER;
old_occur           NUMBER;
prior_occur         NUMBER;
old_cal_date        DATE;
seq_num             NUMBER;
prior_seq_num       NUMBER;
next_seq_num        NUMBER;
shift_seq_num       NUMBER;
shift_prior_seq_num NUMBER;
shift_next_seq_num  NUMBER;
shift_next_date     DATE;
shift_prior_date    DATE;
shift_old_date      DATE;
v_prior_date        DATE;
v_old_cal_date      DATE;
v_seq_num           NUMBER;
v_next_seq_num      NUMBER;
v_prior_seq_num     NUMBER;
i                   INTEGER;
j                   INTEGER;
x                   INTEGER;
old_weekly          NUMBER ;
prior_weekly        NUMBER ;
old_period          NUMBER ;
prior_period        NUMBER ;
period_char         VARCHAR2(8);
week_end            DATE;
weekly_seq          NUMBER ;
period_seq          NUMBER ;
week_num            NUMBER ;
/* 05-JAN-2002 Rajesh Patangya  */
wps_index           INTEGER ;
/* 12/13/02 - Rajesh Patangya B2710601, Added database link  */
ins_stmt            VARCHAR2(32700) ;
ins_stmt1           VARCHAR2(32700) ;
shft_time           VARCHAR2(32700) ;
temp_from_date      DATE ;
temp_to_date        DATE ;
temp_to_time        NUMBER ;
temp_shift_num      NUMBER ;

BEGIN

  cal_count         := 0;
  prior_occur       := 1;
  old_cal_date      :=  to_date('01/01/1959','DD/MM/YYYY');
  seq_num           := 0;
  prior_seq_num     := 1;
  shift_seq_num     := 0;
  shift_prior_seq_num := 1;
  shift_old_date    := to_date('01/01/1959','DD/MM/YYYY');

  i                 := 0;
  j                 := 0;
  x                 := 0;
  old_weekly        := 0;
  prior_weekly      := 0;
  old_period        := 0;
  prior_period      := 0;
  period_char       := NULL;
  weekly_seq        := 0;
  period_seq        := 0;
  week_num          := 0;
  wps_index         := 0;
  ins_stmt          := NULL;
  ins_stmt1         := NULL;
  shft_time         := NULL;
  temp_from_date    := NULL;
  temp_to_date      := NULL;
  temp_to_time      := 0 ;
  temp_shift_num    := 0 ;
  stmt_no           := 0;

       /* Insert for Net Resource starts here, The following select statement
          gets the period that are availble for a given calendar, From time
          and To Time are taken in seconds here.
       */

    IF return_status THEN
       v_cp_enabled := TRUE;
    ELSE
       v_cp_enabled := FALSE;
    END IF;

--
       stmt_no := 10;
       sql_stmt3 := ' SELECT msd.calendar_date calendar_date,  '
                    || '      dd.shift_no  shift_no,                 '
                    || '      dd.shift_start  from_time,             '
                    || '      dd.shift_start + dd.shift_duration  to_time  '
                    || ' FROM   mr_shcl_dtl'||p_db_link||'  msd, '
                    || '        mr_shdy_hdr'||p_db_link||'  dh,  '
                    || '        mr_shdy_dtl'||p_db_link||'  dd   '
                    || ' WHERE msd.calendar_id = :curr_cal_id   '
                    || ' and   dh.shopday_no = msd.shopday_no   '
                    || ' AND dd.shopday_no = dh.shopday_no      '
                    || ' AND msd.delete_mark = 0                '
                    || ' AND dh.delete_mark  = 0                '
                    || ' AND dd.delete_mark  = 0                '
                    || ' AND dd.shift_duration  > 0             '
                    || ' ORDER BY  calendar_date,               '
                    || '           from_time,                   '
                    || '           to_time  ';

    /* The cursor is opened and the values are stored in a PL/SQL table
      for further processing If Pl/SQL Tbl new_rec  has any residual rows,
      we Need to clean before populating the New Table - 12/17/99 */

       IF new_rec.COUNT > 0 THEN
          new_rec.delete;
       END IF;

      /*      OPEN cal_cur FOR sql_stmt3 USING p_cal_id,trunc(p_run_date); */

       OPEN cal_cur FOR sql_stmt3 USING p_cal_id;

     stmt_no := 20;
     i := 0;
     LOOP
       FETCH cal_cur
       INTO  calendar_record;
       EXIT WHEN cal_cur%NOTFOUND;

       stmt_no := 30;

       /*  Check for the First record  */
       IF i = 0 THEN
         stmt_no := 40;

         /*  Check if the first row to time is spilling over  */

         IF calendar_record.to_time > no_of_secs THEN
           i := i + 1;
           new_rec(i).cal_date := calendar_record.cal_date ;
           new_rec(i).shift_num := calendar_record.shift_num ;
           new_rec(i).from_time := calendar_record.from_time;
           new_rec(i).to_time := no_of_secs ;

 /*           Add more record for the spilled over shift  */
           i := i +1 ;

           new_rec(i).cal_date := calendar_record.cal_date + 1 ;
           new_rec(i).shift_num := calendar_record.shift_num ;
           new_rec(i).from_time := 0 ;
           new_rec(i).to_time := calendar_record.to_time - no_of_secs ;
         ELSE
             /*  Else Store the values in the PL/sql table          */

           i := i + 1;
           new_rec(i).cal_date := calendar_record.cal_date ;
           new_rec(i).shift_num := calendar_record.shift_num ;
           new_rec(i).from_time := calendar_record.from_time;
           new_rec(i).to_time := calendar_record.to_time;

         END IF;

       /*   If not the first record, then check if the Calendar date
            is greater than the Previous cal date in the PL/sql table */
     ELSE
       IF calendar_record.cal_date >  new_rec(i).cal_date  THEN

          /*  Check if the Date, to_time is spilling over */
         IF calendar_record.to_time > no_of_secs THEN
           i := i + 1;
           new_rec(i).cal_date := calendar_record.cal_date;
           new_rec(i).from_time := calendar_record.from_time;
           new_rec(i).shift_num := calendar_record.shift_num;
           new_rec(i).to_time := no_of_secs;

       /*          Add more record for the spilled over shift  */
             i := i + 1;
             new_rec(i).cal_date := calendar_record.cal_date + 1;
             new_rec(i).shift_num := calendar_record.shift_num;
             new_rec(i).from_time := 0;
             new_rec(i).to_time := calendar_record.to_time - no_of_secs ;
         ELSE
             /*   Else Store the values in the PL/sql table          */

             i := i + 1 ;
             new_rec(i).cal_date := calendar_record.cal_date ;
             new_rec(i).shift_num := calendar_record.shift_num ;
             new_rec(i).from_time := calendar_record.from_time;
             new_rec(i).to_time := calendar_record.to_time;

         END IF;

       /*  If not the first record, then check if the Calendar date
           is equal to the Previous cal date in the PL/sql table */

     ELSIF calendar_record.cal_date =  new_rec(i).cal_date THEN

        /*  Checking if the Cursor from_time is greater than Previous record to_time */

          IF calendar_record.from_time >  new_rec(i).to_time  THEN
             /*  Check if the Date, to_time is spilling over */
             IF calendar_record.to_time > no_of_secs THEN
               i := i + 1;
               new_rec(i).cal_date := calendar_record.cal_date;
               new_rec(i).from_time := calendar_record.from_time;
               new_rec(i).shift_num := calendar_record.shift_num;
               new_rec(i).to_time := no_of_secs;

           /*  Add more record for the spilled over shift  */
                 i := i + 1;
                 new_rec(i).cal_date := calendar_record.cal_date + 1 ;
                 new_rec(i).from_time := 0 ;
                 new_rec(i).shift_num := calendar_record.shift_num;
                 new_rec(i).to_time := calendar_record.to_time - no_of_secs ;
             ELSE
                i := i + 1;
                new_rec(i).cal_date := calendar_record.cal_date ;
                new_rec(i).shift_num := calendar_record.shift_num ;
                new_rec(i).from_time := calendar_record.from_time;
                new_rec(i).to_time := calendar_record.to_time;
            END IF ;
         ELSE      /* Merge time !!!
                      Shifts Merge is the start time of the shift is Less than
                      the Previous record to_time
               Checking if the record that is Merged is spilling Over to next day */
             IF calendar_record.to_time > no_of_secs THEN
                new_rec(i).to_time := no_of_secs ;
               /* Add more record for the spilled over shift  */
                 i := i + 1;
                 new_rec(i).cal_date := calendar_record.cal_date + 1;
                 new_rec(i).from_time := 0 ;
                 new_rec(i).shift_num := calendar_record.shift_num;
                 new_rec(i).to_time := calendar_record.to_time - no_of_secs ;
              ELSE
                IF  calendar_record.to_time > new_rec(i).to_time THEN
                  new_rec(i).to_time := calendar_record.to_time ;
                END IF ;
              END IF  ;
          END IF ; /* End OF Merge time  */

       /*  checking if the Calendar date is less than the Previous cal date
           in the PL/sql table This check is useful when two shifts in a day
           are crossing Midnight Then in that case we need to compare the start
           time with the Previously completed shift end time and the dates too. */

        ELSIF calendar_record.cal_date <  new_rec(i).cal_date THEN
            IF calendar_record.to_time > no_of_secs THEN
              IF calendar_record.to_time - no_of_secs > new_rec(i).to_time THEN
                 new_rec(i).to_time := calendar_record.to_time - no_of_secs ;
              END IF;
            END IF ;

        END IF ; /* End if for date check */
     END IF; /* End if for i = 0 */

     END LOOP;

     /*  cal count gives the Number of rows after the Calendar is exploded */
     cal_count := new_rec.COUNT ;
     /*  Calendar Start date and End dates are Calculated here  */
     cal_start_date := new_rec(1).cal_date;
     cal_end_date := new_rec(cal_count).cal_date;

     CLOSE cal_cur;

   /* 05-JAN-2002 Rajesh Patangya  */
   /* Start writing the exploded Calendar dates into temp table */
   wps_index         := 1 ;

   /* 12/13/02 - Rajesh Patangya B2710601, Added database link  */
     ins_stmt := 'INSERT INTO gmp_calendar_detail_gtmp'||p_db_link
                          ||' ( '
                          ||'   calendar_id, '
                          ||'   shift_num, '
                          ||'   shift_date, '
                          ||'   from_time, '
                          ||'   to_time, '
                          ||'   from_date, '
                          ||'   to_date '
                          ||' ) '
                          ||' VALUES '
                          ||' ( :p1,:p2,:p3,:p4,:p5,:p6,:p7)';


     ins_stmt1 := 'INSERT INTO temp_cal'||p_db_link
                          ||' ( '
                          ||'   calendar_id, '
                          ||'   shift_num, '
                          ||'   shift_date, '
                          ||'   from_time, '
                          ||'   to_time, '
                          ||'   from_date, '
                          ||'   to_date '
                          ||' ) '
                          ||' VALUES '
                          ||' ( :p1,:p2,:p3,:p4,:p5,:p6,:p7)';
--
   FOR wps_index IN 1..new_rec.COUNT
   LOOP

     temp_from_date := (new_rec(wps_index).cal_date +
                         (new_rec(wps_index).from_time/86400)) ;

     IF new_rec(wps_index).to_time = 86400 THEN
     temp_to_time   := new_rec(wps_index).to_time - 1 ;
     temp_shift_num := new_rec(wps_index).shift_num  + 99999 ;
     ELSE
     temp_to_time   := new_rec(wps_index).to_time  ;
     temp_shift_num := new_rec(wps_index).shift_num;
     END IF ;

     temp_to_date   := (new_rec(wps_index).cal_date + (temp_to_time /86400)) ;

     EXECUTE IMMEDIATE ins_stmt USING
                                p_cal_id,
                                temp_shift_num,
                                new_rec(wps_index).cal_date,
                                new_rec(wps_index).from_time,
                                temp_to_time,
                                temp_from_date,
                                temp_to_date
                               ;
  /*
     EXECUTE IMMEDIATE ins_stmt1 USING
                                p_cal_id,
                                temp_shift_num,
                                new_rec(wps_index).cal_date,
                                new_rec(wps_index).from_time,
                                temp_to_time,
                                temp_from_date,
                                temp_to_date
                               ;
  */
    END LOOP;
--       log_message(to_char(sysdate,'MM/DD/YYYY HH24:MI:SS'));

   IF p_usage = 'APS' THEN
       /* Insert for msc_st_shift_times Starts Here - 2213101 */
       stmt_no := 41;
       shft_time := '  INSERT INTO msc_st_shift_times '
                    || ' (shift_num,                      '
                    || '  calendar_code,                  '
                    || '  from_time,                      '
                    || '  to_time,                        '
                    || '  deleted_flag,                   '
                    || '  sr_instance_id                  '
                    || ' )                                '
                    || ' SELECT distinct shift_num ,   '
                    || '  :calendar_no,                      '
                    || '  from_time,         '
                    || '  to_time,  '
                    || '  2  ,                    '
                    || '  :instance_id                      '
                    || ' FROM  gmp_calendar_detail_gtmp'||p_db_link||'  gtmp '
                    || ' WHERE calendar_id = :curr_cal_id   '
                    || ' ORDER BY shift_num,from_time, to_time ' ;

       EXECUTE IMMEDIATE shft_time USING p_calendar_no,
                                         p_instance_id,
                                         p_cal_id;

       /* Insert for msc_st_shift_times Ends Here - 2213101 */
--
     /* Start writing the Calendar dates */

     old_occur := 1;
     old_cal_date := new_rec(1).cal_date;

     old_weekly := 1;
     prior_weekly := 1;
     old_period := 1;
     prior_period := 1;

     period_char := TO_CHAR(new_rec(old_period).cal_date,'MON-YYYY');
     weekly_seq := 0;
     period_seq := 0;

     SELECT to_char(new_rec(old_weekly).cal_date,'D') INTO week_num FROM dual;
     week_num := (week_num - 7) * -1;
     week_end := new_rec(old_weekly).cal_date + week_num;

     /*
      The PL/sql table thus Populated after exploding the Calendar is useful in
      Populating MSC_ST_CALENDAR_DATES here
     */
     stmt_no := 50;
     FOR j IN 1 ..cal_count
     LOOP
       IF new_rec(j).cal_date <> old_cal_date THEN
          seq_num := seq_num + 1;
          prior_seq_num := seq_num - 1;
          IF prior_seq_num < 1 THEN
             prior_seq_num := 1;
          END IF;
          next_seq_num := seq_num + 1;
         /* Code change to include all the Calendar Days in the
            Staging Calendar Table
         */

        /* After allowing the first row insert, check from the second row on
           if there are any gaps in the dates
        */
          IF seq_num >= 1 THEN
          /* using information from the Prior set values of sequences and dates */

             v_next_seq_num := next_seq_num;
             v_prior_seq_num := seq_num;
             v_old_cal_date := old_cal_date;
             v_prior_date := old_cal_date;

         /* Start of Code change to include all the Calendar Days in the
            Staging Calendar Table
         */

             stmt_no := 51;
             WHILE ( v_old_cal_date + 1 < new_rec(j).cal_date)
             LOOP
                  INSERT INTO msc_st_calendar_dates
                                  (calendar_date,
                                   calendar_code,
                                   exception_set_id,
                                   seq_num,
                                   next_seq_num,
                                   prior_seq_num,
                                   next_date,
                                   prior_date,
                                   calendar_start_date,
                                   calendar_end_date,
                                   description,
                                   sr_instance_id,
                                   deleted_flag
                                  )
                            values(v_old_cal_date + 1,
                                   p_calendar_no,
                                   -1,
                                   NULL,
                                   v_next_seq_num,
                                   v_prior_seq_num,
                                   new_rec(j).cal_date,
                                   v_prior_date,
                                   cal_start_date,
                                   cal_end_date,
                                   p_cal_desc,
                                   p_instance_id,
                                   2
                                   );
                 /* The Calendar Date needs to be incremented to check for
                    further gaps in the dates
                 */
                 v_old_cal_date := v_old_cal_date + 1;
             END LOOP;
          END IF;

         /* End of Code change to include all the Calendar Days in the
            Staging Calendar Table
         */

        /* New changes made to the calendar sequences, Bug#1175906
           nextseq, prior_seq are made same as seq number for working
           days, and similarly for next date and prior_dates are same as
           calendar_dates - 02/01/2000
        */

          stmt_no := 52;
          INSERT INTO msc_st_calendar_dates
                 (calendar_date,
                  calendar_code,
                  exception_set_id,
                  seq_num,
                  next_seq_num,
                  prior_seq_num,
                  next_date,
                  prior_date,
                  calendar_start_date,
                  calendar_end_date,
                  description,
                  sr_instance_id,
                  deleted_flag
                 )
           VALUES(new_rec(old_occur).cal_date,
                  p_calendar_no,
                  -1,
                  seq_num,
                  seq_num,
                  seq_num,
                  new_rec(old_occur).cal_date,
                  new_rec(old_occur).cal_date,
                  cal_start_date,
                  cal_end_date,
                  p_cal_desc,
                  p_instance_id,
                  2
                 );

             /*  write weekly bucket */
             stmt_no := 53;
             IF new_rec(j).cal_date > week_end THEN
               weekly_seq := weekly_seq + 1;
               INSERT INTO msc_st_cal_week_start_dates
                 ( CALENDAR_CODE         ,
                   EXCEPTION_SET_ID       ,
                   WEEK_START_DATE        ,
                   NEXT_DATE              ,
                   PRIOR_DATE             ,
                   SEQ_NUM                ,
                   DELETED_FLAG           ,
                   SR_INSTANCE_ID)
               VALUES
                 ( p_calendar_no ,
                   -1,
                   new_rec(old_weekly).cal_date,
                   new_rec(j).cal_date,
                   new_rec(prior_weekly).cal_date,
                   weekly_seq,
                   2,
                   p_INSTANCE_ID) ;

               week_num := 0;
               SELECT TO_CHAR(new_rec(j).cal_date,'D') INTO week_num FROM dual;
               week_num := (week_num - 7) * -1;
               prior_weekly := old_weekly;
               old_weekly := j;
               week_end := new_rec(old_weekly).cal_date + week_num;

               /*  write period bucket */
               IF period_char <> TO_CHAR(new_rec(j).cal_date,'MON-YYYY') THEN
                 period_seq := period_seq + 1;

                 stmt_no := 54;
                 INSERT INTO msc_st_period_start_dates
                 ( CALENDAR_CODE         ,
                   EXCEPTION_SET_ID       ,
                   PERIOD_START_DATE      ,
                   PERIOD_SEQUENCE_NUM    ,
                   PERIOD_NAME            ,
                   NEXT_DATE              ,
                   PRIOR_DATE             ,
                   DELETED_FLAG           ,
                   SR_INSTANCE_ID)
                 VALUES
                 ( p_calendar_no ,
                   -1,
                   new_rec(old_period).cal_date,
                   period_seq,
                   TO_CHAR(new_rec(old_period).cal_date, 'MON'),
                   new_rec(j).cal_date,
                   new_rec(prior_period).cal_date,
                   2,
                   p_INSTANCE_ID);

                 prior_period := old_period;
                 old_period := j;
                 period_char := TO_CHAR(new_rec(old_period).cal_date,'MON-YYYY');
               END IF;
             END IF;

             old_cal_date := new_rec(j).cal_date;
             prior_occur := old_occur;
             old_occur := j;
             prior_seq_num := seq_num;
       END IF;
     END LOOP;

     /* Insert for the last record */

     stmt_no := 60;
     INSERT INTO msc_st_calendar_dates
       ( calendar_date,
         calendar_code,
         exception_set_id,
         seq_num,
         next_seq_num,
         prior_seq_num,
         next_date,
         prior_date,
         calendar_start_date,
         calendar_end_date,
         description,
         sr_instance_id
         )
      VALUES
       ( new_rec(old_occur).cal_date,
         p_calendar_no,
         -1,
         seq_num + 1,
         seq_num + 1,
         seq_num + 1,
         new_rec(old_occur).cal_date,
         new_rec(old_occur).cal_date,
         cal_start_date,
         cal_end_date,
         p_cal_desc,
         p_instance_id
       );

     weekly_seq := weekly_seq + 1;

     stmt_no := 61;
     INSERT INTO msc_st_cal_week_start_dates
       ( CALENDAR_CODE         ,
         EXCEPTION_SET_ID       ,
         WEEK_START_DATE        ,
         NEXT_DATE              ,
         PRIOR_DATE             ,
         SEQ_NUM                ,
         DELETED_FLAG           ,
         SR_INSTANCE_ID)
     VALUES
       ( p_calendar_no ,
         -1,
         new_rec(old_weekly).cal_date,
         new_rec(old_weekly).cal_date,
         new_rec(prior_weekly).cal_date,
         weekly_seq,
         2,
         p_INSTANCE_ID) ;


     period_seq := period_seq + 1;

     stmt_no := 63;
     INSERT INTO msc_st_period_start_dates
     ( CALENDAR_CODE         ,
       EXCEPTION_SET_ID       ,
       PERIOD_START_DATE      ,
       PERIOD_SEQUENCE_NUM    ,
       PERIOD_NAME            ,
       NEXT_DATE              ,
       PRIOR_DATE             ,
       DELETED_FLAG           ,
       SR_INSTANCE_ID
     )
     VALUES
     (p_calendar_no ,
      -1,
      new_rec(old_period).cal_date,
      period_seq,
      TO_CHAR(new_rec(old_period).cal_date, 'MON'),
      new_rec(old_period).cal_date,
      new_rec(prior_period).cal_date,
      2,
      p_INSTANCE_ID);

      /* B2213101 - Code added for Insert into msc_st_shift_dates */
     stmt_no := 70;
     shift_prior_date := new_rec(1).cal_date;

     FOR h IN 1 ..new_rec.COUNT
     LOOP

         shift_seq_num := shift_seq_num + 1;

         shift_prior_seq_num := shift_seq_num - 1;
         IF shift_prior_seq_num < 1 THEN
             shift_prior_seq_num := 1;
         END IF;

         shift_next_seq_num := shift_seq_num + 1;
         IF shift_next_seq_num > new_rec.COUNT THEN
            shift_next_seq_num := shift_next_seq_num - 1;
         END IF;

         IF new_rec(1).shift_num = new_rec(h).shift_num THEN
            IF shift_seq_num = 1 THEN
               shift_prior_date := new_rec(h).cal_date;
               shift_next_date  := shift_prior_date + 1;
            ELSE
               shift_prior_date := new_rec(h-1).cal_date;
               shift_next_date  := new_rec(h).cal_date + 1;
            END IF;
         END IF;


         INSERT INTO msc_st_shift_dates
           ( calendar_code,
             exception_set_id,
             shift_num,
             shift_date,
             seq_num,
             next_seq_num,
             prior_seq_num,
             next_date,
             prior_date,
             deleted_flag,
             sr_instance_id
           )
         VALUES
           ( p_calendar_no,
             -1,
             new_rec(h).shift_num,
             new_rec(h).cal_date,
             shift_seq_num,
             shift_next_seq_num,
             shift_prior_seq_num,
             shift_next_date,
             shift_prior_date,
             2,
             p_instance_id
           );

     END LOOP;

      /* B2213101 - End of changes for  Insert into msc_st_shift_dates */

  END IF ; /*  End if for usage */

  return_status := TRUE;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
    log_message('Calendar has no days set in the Calendar Detail : '||p_calendar_no);
    log_message('stmt_no = ' || stmt_no || '--' || sqlerrm);
    return_status := FALSE;

   WHEN OTHERS THEN
    log_message('Error in retrieve Calendar Detail : ' || sqlerrm);
    return_status := FALSE;

END retrieve_calendar_detail;

/*
REM+==========================================================================+
REM| PROCEDURE NAME                                                           |
REM|    net_rsrc_insert                                                       |
REM|                                                                          |
REM| Type                                                                     |
REM|    public                                                                |
REM|                                                                          |
REM| DESCRIPTION                                                              |
REM|                                                                          |
REM|                                                                          |
REM| Input Parameters                                                         |
REM|    p_org_id - Organization id                                            |
REM|    p_orgn_code - Orgn Code                                               |
REM|    p_calendar_id - calendar_id                                           |
REM|    p_instance_id - Instance Id                                           |
REM|    p_usage - Used foir APS or WPS                                        |
REM|    p_db_link - Data Base Link                                            |
REM|                                                                          |
REM| Output Parameters                                                        |
REM|    return_status                                                         |
REM|                                                                          |
REM| HISTORY                                                                  |
REM|    Created on 4th Jan 2002 By Rajesh Patangya                            |
REM|    7th Mar 2003 -- Performance issue fix and B2671540 00:00 shift fix    |
REM| B3161696 - 26-SEP-2003 TARGETTED RESOURCE AVAILABILITY PLACEHOLDER BUG   |
REM| B4309093 - 20-APR-2005 Modified code to TO ADD TIME OR A SHIFT TO A      |
REM|                        PLANT RESOURCE                                    |
REM+==========================================================================+
*/
PROCEDURE net_rsrc_insert(p_org_id         IN NUMBER,
                          p_orgn_code      IN VARCHAR2,
                          p_simulation_set IN VARCHAR2,
                          p_db_link        IN VARCHAR2,
                          p_instance_id    IN NUMBER,
                          p_run_date       IN DATE ,
                          p_calendar_id    IN NUMBER,
                          p_usage          IN VARCHAR2,
                          return_status    OUT NOCOPY BOOLEAN) IS

ri_shift_interval	ref_cursor_typ;

gsql_stmt		varchar2(10000) ;
sql_stmt1		varchar2(32000) ;
sql_shifts 		varchar2(32000) ;
i         		INTEGER ;
j         		INTEGER ;
g_calendar_id 		NUMBER  ;

BEGIN
         /* 8i Database does not support BULK COLLECT - B3881832 */
         stmt_no	 := 0;
         i     		 := 1;
         j     		 := 1;
         resource_count  := empty_num_table;
         resource_id     := empty_num_table;
         instance_id     := empty_num_table;
         instance_number := empty_num_table;
         shift_num       := empty_num_table;
         f_date          := empty_dat_table;
         t_date          := empty_dat_table;

         /* 8i Database does not support BULK COLLECT - B3881832 */
         dbms_session.free_unused_user_memory;

         stmt_no := 72;
         -- Rajesh Patangya B4692705, When the calendar is not assigned to
         -- resource then organization calendar should be considered
	 g_calendar_id 	:= 0 ;
         gsql_stmt :=  '  SELECT mfg_calendar_id '
                    || '  FROM  sy_orgn_mst'||p_db_link
                    || '  WHERE orgn_code = :orgn_code1 ';

         EXECUTE IMMEDIATE gsql_stmt INTO g_calendar_id USING p_orgn_code ;

         IF g_calendar_id = 0 THEN
            log_message('Warning : '||p_orgn_code||
                    ' does not have manufacturing calendar, continuing ...') ;
         END IF;

    /* Interval Cursor gives the all the point of inflections  */

       stmt_no := 73;
       -- HW B4309093 Check for calendar id in cr_rsrc_dtl
       sql_stmt1 :=  ' SELECT /*+ ALL_ROWS */ '
                  || ' 	decode(rt.interval_date,rt.lead_idate,rt.assigned_qty,decode(rt.rsum,0,rt.assigned_qty,rt.assigned_qty-rt.rsum)) resource_count  '
                  || ' 	,rt.resource_id '
                  || ' 	,0 instance_id '
                  || ' 	,0 instance_number '
                  || ' 	,rt.shift_num '
                  || ' 	,rt.interval_date	from_date  '
                  || ' 	,rt.lead_idate		to_date '
                  || ' FROM '
                  || ' ( '
                  || ' SELECT '
                  || ' 	t.resource_id '
                  || ' 	,t.shift_num  '
                  || ' 	,t.interval_date '
                  || ' 	,t.assigned_qty  '
                  || ' 	,nvl(sum(u.resource_units),0) rsum  '
                  || ' 	,max(t.lead_idate) lead_idate '
                  || ' FROM '
                  || ' ( '
                  || ' SELECT unique resource_id,instance_number,from_date, '
                  || ' to_date to_date1,resource_units '
                  || ' FROM ( '
                  || ' SELECT un.resource_id, '
                  || '        gri.instance_number, '
                  || '        un.from_date,  '
                  || '        un.to_date,    '
                  || '        1 resource_units'
                  || ' FROM   cr_rsrc_dtl '||p_db_link||'  crd, '
                  || '        gmp_rsrc_unavail_dtl_v '||p_db_link||' un, '
                  || '        gmp_resource_instances '||p_db_link||' gri '
                  || ' WHERE  crd.resource_id = un.resource_id  '
                  || ' AND    crd.resource_id = gri.resource_id  '
                  || ' AND    un.instance_id  = gri.instance_id  '
                  || ' AND    crd.orgn_code = :orgn_code ' ;

    IF (p_usage = 'BASED') THEN   /* Usage APS */
    sql_stmt1 := sql_stmt1
                  || ' AND    crd.calendar_id = :l_cal_id ' ;
    ELSE
    sql_stmt1 := sql_stmt1
                  || ' AND    nvl(crd.calendar_id,:g_default_cal_id)=:l_cal_id';
    END IF ;

    sql_stmt1 := sql_stmt1
                  || ' AND    crd.schedule_ind = 2 '
                  || ' AND    crd.delete_mark = 0 ' ;

    IF (v_from_rsrc IS NOT NULL AND v_to_rsrc IS NOT NULL) THEN
    sql_stmt1 := sql_stmt1 || '  AND crd.resources BETWEEN :frsrc and :trsrc ' ;
    END IF ;

-- HW B4309093 Check for calendar id in cr_rsrc_dtl
    sql_stmt1 := sql_stmt1
                  || ' AND    nvl(un.instance_id,0) <> 0  '
                  || ' UNION ALL '
                  || ' SELECT un.resource_id, '
                  || '        gri.instance_number, '
                  || '        un.from_date,  '
                  || '        un.to_date,    '
                  || '        1 resource_units'
                  || ' FROM   cr_rsrc_dtl '||p_db_link||'  crd, '
                  || '        gmp_rsrc_unavail_dtl_v '||p_db_link||' un, '
                  || '        gmp_resource_instances '||p_db_link||' gri '
                  || ' WHERE  crd.resource_id = un.resource_id  '
                  || ' AND    crd.resource_id = gri.resource_id  '
                  || ' AND    crd.orgn_code = :orgn_code1 ' ;

    IF (p_usage = 'BASED') THEN   /* Usage APS */
    sql_stmt1 := sql_stmt1
                  || ' AND    crd.calendar_id = :l_cal_id1 ' ;
    ELSE
    sql_stmt1 := sql_stmt1
                  || ' AND    nvl(crd.calendar_id ,:g_default_cal_id1)= :l_cal_id1 ';
    END IF ;
    sql_stmt1 := sql_stmt1
                  || ' AND    crd.delete_mark = 0 '
                  || ' AND    crd.schedule_ind = 2 '
                  || ' AND    nvl(un.instance_id,0) = 0  ' ;

    IF (v_from_rsrc IS NOT NULL AND v_to_rsrc IS NOT NULL) THEN
    sql_stmt1 := sql_stmt1 || '  AND crd.resources BETWEEN :frsrc and :trsrc ' ;
    END IF ;

-- HW B4309093 Check for calendar id in cr_rsrc_dtl
    sql_stmt1 := sql_stmt1
                  || ' AND    gri.instance_number in '
                  || '      ( select tgri.instance_number '
                  || '      FROM gmp_resource_instances '||p_db_link||' tgri '
                  || '      WHERE tgri.resource_id = crd.resource_id '
                  || '      AND rownum <= un.resource_units '
                  || '      ) '
                  || ' UNION ALL  '
                  || ' SELECT un.resource_id, '
                  || '        0 instance_number,  '
                  || '        un.from_date,  '
                  || '        un.to_date,    '
                  || '        un.resource_units '
                  || ' FROM   cr_rsrc_dtl '||p_db_link||'  crd, '
                  || '        gmp_rsrc_unavail_dtl_v ' ||p_db_link||'  un'
                  || ' WHERE  crd.resource_id = un.resource_id  '
                  || ' AND    crd.orgn_code = :orgn_code2 ' ;

    IF (p_usage = 'BASED') THEN   /* Usage APS */
    sql_stmt1 := sql_stmt1
                  || ' AND    crd.calendar_id = :l_cal_id2 ' ;
    ELSE
    sql_stmt1 := sql_stmt1
                  || ' AND    nvl(crd.calendar_id ,:g_default_cal_id2)= :l_cal_id2 ' ;
    END IF;
    sql_stmt1 := sql_stmt1
                  || ' AND    crd.delete_mark = 0 ' ;

    IF (v_from_rsrc IS NOT NULL AND v_to_rsrc IS NOT NULL) THEN
    sql_stmt1 := sql_stmt1 || '  AND crd.resources BETWEEN :frsrc and :trsrc ' ;
    END IF ;

-- HW B4309093 Check for calendar id in cr_rsrc_dtl
    sql_stmt1 := sql_stmt1
                  || ' AND NOT EXISTS '
                  || ' (SELECT 1 '
                  || '  FROM gmp_resource_instances  ' ||p_db_link||' gri '
                  || '  WHERE gri.resource_id = un.resource_id ) '
                  || ' ) '
                  || ' ) u, '
                  || ' 	( '
                  || ' 	SELECT resource_id,shift_num,interval_date, '
                  || '          assigned_qty,lead_idate '
                  || ' 	FROM '
                  || ' 		( '
                  || ' 	        SELECT resource_id,shift_num,interval_date, '
                  || '                 assigned_qty '
                  || ' 			,lead(resource_id,1) over(order by '
                  || '  resource_id,interval_date,shift_num) as lead_rid '
                  || ' 			,lead(interval_date,1) over(order by '
                  || '  resource_id,interval_date,shift_num) as lead_idate '
                  || ' 			,lead(shift_num,1) over(order by '
                  || '  resource_id,interval_date,shift_num) as lead_snum '
                  || ' 		FROM '
                  || ' 			( '
                  || ' SELECT unique cmd.resource_id, '
                  || ' 0 , '
                  || ' exp.shift_num, '
                  || ' 0 , '
                  || ' cmd.interval_date, '
                  || ' cmd.assigned_qty '
                  || ' FROM ( '
                  || ' SELECT un.resource_id resource_id, '
                  || '        gri.instance_number instance_number,'
                  || '        0 shift_num,'
                  || '        0 resource_count,'
                  || '        un.from_date interval_date, '
                  || '        crd.assigned_qty assigned_qty '
                  || ' FROM   cr_rsrc_dtl '||p_db_link||'  crd, '
                  || '        gmp_rsrc_unavail_dtl_v '||p_db_link||' un, '
                  || '        gmp_resource_instances '||p_db_link||' gri '
                  || ' WHERE  crd.resource_id = un.resource_id  '
                  || ' AND    crd.resource_id = gri.resource_id  '
                  || ' AND    un.instance_id  = gri.instance_id  '
                  || ' AND    crd.orgn_code = :orgn_code1 ' ;

    IF (p_usage = 'BASED') THEN   /* Usage APS */
    sql_stmt1 := sql_stmt1
                  || ' AND    crd.calendar_id = :l_cal_id2 ' ;
    ELSE
    sql_stmt1 := sql_stmt1
                  || ' AND    nvl(crd.calendar_id ,:g_default_cal_id4)= :l_cal_id4 ' ;
    END IF;

    sql_stmt1 := sql_stmt1
                  || ' AND    crd.schedule_ind = 2 '
                  || ' AND    crd.delete_mark = 0 '
                  || ' AND    nvl(un.instance_id,0) <> 0  ' ;

    IF (v_from_rsrc IS NOT NULL AND v_to_rsrc IS NOT NULL) THEN
    sql_stmt1 := sql_stmt1 || '  AND crd.resources BETWEEN :frsrc and :trsrc ' ;
    END IF ;

-- HW B4309093 Check for calendar id in cr_rsrc_dtl
    sql_stmt1 := sql_stmt1
                  || ' UNION ALL '
                  || ' SELECT un.resource_id resource_id, '
                  || '        gri.instance_number instance_number,'
                  || '        0 shift_num,'
                  || '        0 resource_count,'
                  || '        un.to_date interval_date, '
                  || '        crd.assigned_qty assigned_qty '
                  || ' FROM   cr_rsrc_dtl '||p_db_link||'  crd, '
                  || '        gmp_rsrc_unavail_dtl_v '||p_db_link||' un, '
                  || '        gmp_resource_instances '||p_db_link||' gri '
                  || ' WHERE  crd.resource_id = un.resource_id  '
                  || ' AND    crd.resource_id = gri.resource_id  '
                  || ' AND    un.instance_id  = gri.instance_id  '
                  || ' AND    crd.orgn_code = :orgn_code2 ' ;

    IF (p_usage = 'BASED') THEN   /* Usage APS */
    sql_stmt1 := sql_stmt1
                  || ' AND    crd.calendar_id = :l_cal_id2 ' ;
    ELSE
    sql_stmt1 := sql_stmt1
                  || ' AND    nvl(crd.calendar_id ,:g_default_cal_id5)= :l_cal_id5 ' ;
    END IF;

    sql_stmt1 := sql_stmt1
                  || ' AND    crd.schedule_ind = 2 '
                  || ' AND    crd.delete_mark = 0 '
                  || ' AND    nvl(un.instance_id,0) <> 0  ' ;

    IF (v_from_rsrc IS NOT NULL AND v_to_rsrc IS NOT NULL) THEN
    sql_stmt1 := sql_stmt1 || '  AND crd.resources BETWEEN :frsrc and :trsrc ' ;
    END IF ;

-- HW B4309093 Check for calendar id in cr_rsrc_dtl
    sql_stmt1 := sql_stmt1
                  || ' UNION ALL '
                  || ' SELECT un.resource_id resource_id, '
                  || '        gri.instance_number instance_number,'
                  || '        0 shift_num,'
                  || '        0 resource_count,'
                  || '        un.from_date interval_date, '
                  || '        crd.assigned_qty assigned_qty '
                  || ' FROM   cr_rsrc_dtl '||p_db_link||'  crd, '
                  || '        gmp_rsrc_unavail_dtl_v '||p_db_link||' un, '
                  || '        gmp_resource_instances '||p_db_link||' gri '
                  || ' WHERE  crd.resource_id = un.resource_id  '
                  || ' AND    crd.resource_id = gri.resource_id  '
                  || ' AND    crd.orgn_code = :orgn_code3 ' ;

    IF (p_usage = 'BASED') THEN   /* Usage APS */
    sql_stmt1 := sql_stmt1
                  || ' AND    crd.calendar_id = :l_cal_id2 ' ;
    ELSE
    sql_stmt1 := sql_stmt1
                  || ' AND    nvl(crd.calendar_id ,:g_default_cal_id6)= :l_cal_id6 ' ;
    END IF;

    sql_stmt1 := sql_stmt1
                  || ' AND    crd.schedule_ind = 2 '
                  || ' AND    crd.delete_mark = 0 '
                  || ' AND    nvl(un.instance_id,0) = 0  ' ;

    IF (v_from_rsrc IS NOT NULL AND v_to_rsrc IS NOT NULL) THEN
    sql_stmt1 := sql_stmt1 || '  AND crd.resources BETWEEN :frsrc and :trsrc ' ;
    END IF ;

-- HW B4309093 Check for calendar id in cr_rsrc_dtl
    sql_stmt1 := sql_stmt1
                  || ' AND    gri.instance_number in '
                  || '      ( select tgri.instance_number '
                  || '      FROM gmp_resource_instances '||p_db_link||' tgri '
                  || '      WHERE tgri.resource_id = crd.resource_id '
                  || '      AND rownum <= un.resource_units '
                  || '      ) '
                  || ' UNION ALL '
                  || ' SELECT un.resource_id resource_id, '
                  || '        gri.instance_number instance_number,'
                  || '        0 shift_num,'
                  || '        0 resource_count,'
                  || '        un.to_date interval_date, '
                  || '        crd.assigned_qty assigned_qty '
                  || ' FROM   cr_rsrc_dtl '||p_db_link||'  crd, '
                  || '        gmp_rsrc_unavail_dtl_v '||p_db_link||' un, '
                  || '        gmp_resource_instances '||p_db_link||' gri '
                  || ' WHERE  crd.resource_id = un.resource_id  '
                  || ' AND    crd.resource_id = gri.resource_id  '
                  || ' AND    crd.orgn_code = :orgn_code4 ' ;

    IF (p_usage = 'BASED') THEN   /* Usage APS */
    sql_stmt1 := sql_stmt1
                  || ' AND    crd.calendar_id = :l_cal_id2 ' ;
    ELSE
    sql_stmt1 := sql_stmt1
                  || ' AND    nvl(crd.calendar_id ,:g_default_cal_id7)= :l_cal_id7 ';
    END IF ;

    sql_stmt1 := sql_stmt1
                  || ' AND    crd.delete_mark = 0 '
                  || ' AND    crd.schedule_ind = 2 '
                  || ' AND    nvl(un.instance_id,0) = 0  ' ;

    IF (v_from_rsrc IS NOT NULL AND v_to_rsrc IS NOT NULL) THEN
    sql_stmt1 := sql_stmt1 || '  AND crd.resources BETWEEN :frsrc and :trsrc ' ;
    END IF ;

    sql_stmt1 := sql_stmt1
                  || ' AND    gri.instance_number in '
                  || '      ( select tgri.instance_number '
                  || '      FROM gmp_resource_instances '||p_db_link||' tgri '
                  || '      WHERE tgri.resource_id = crd.resource_id '
                  || '      AND rownum <= un.resource_units '
                  || '      ) '
                  || ' UNION ALL '
                  || ' SELECT un.resource_id, '
                  || '        0 instance_number,  '
                  || '        0 shift_num,'
                  || '        0 resource_count,'
                  || '        un.from_date interval_date, '
                  || '        crd.assigned_qty assigned_qty '
                  || ' FROM   cr_rsrc_dtl '||p_db_link||'  crd, '
                  || '        gmp_rsrc_unavail_dtl_v '||p_db_link||' un '
                  || ' WHERE  crd.resource_id = un.resource_id  '
                  || ' AND    crd.orgn_code = :orgn_code44 ' ;

    IF (p_usage = 'BASED') THEN   /* Usage APS */
    sql_stmt1 := sql_stmt1
                  || ' AND    crd.calendar_id = :l_cal_id2 ' ;
    ELSE
    sql_stmt1 := sql_stmt1
                  || ' AND    nvl(crd.calendar_id ,:g_default_cal_id8)= :l_cal_id8 ' ;
    END IF;

    sql_stmt1 := sql_stmt1
                  || ' AND    crd.delete_mark = 0 ' ;

    IF (v_from_rsrc IS NOT NULL AND v_to_rsrc IS NOT NULL) THEN
    sql_stmt1 := sql_stmt1 || '  AND crd.resources BETWEEN :frsrc and :trsrc ' ;
    END IF ;

-- HW B4309093 Check for calendar id in cr_rsrc_dtl
    sql_stmt1 := sql_stmt1
                  || ' AND NOT EXISTS '
                  || '       (SELECT 1 '
                  || '        FROM gmp_resource_instances '||p_db_link||' gri '
                  || '        WHERE gri.resource_id = un.resource_id ) '
                  || ' UNION ALL '
                  || ' SELECT un.resource_id, '
                  || '        0 instance_number,  '
                  || '        0 shift_num,'
                  || '        0 resource_count,'
                  || '        un.to_date interval_date, '
                  || '        crd.assigned_qty assigned_qty '
                  || ' FROM   cr_rsrc_dtl '||p_db_link||'  crd, '
                  || '        gmp_rsrc_unavail_dtl_v '||p_db_link||' un '
                  || ' WHERE  crd.resource_id = un.resource_id  '
                  || ' AND    crd.orgn_code = :orgn_code444 ' ;

    IF (p_usage = 'BASED') THEN   /* Usage APS */
    sql_stmt1 := sql_stmt1
                  || ' AND    crd.calendar_id = :l_cal_id2 ' ;
    ELSE
    sql_stmt1 := sql_stmt1
                  || ' AND    nvl(crd.calendar_id ,:g_default_cal_id9)= :l_cal_id9 ' ;
    END IF;

    sql_stmt1 := sql_stmt1
                  || ' AND    crd.delete_mark = 0 ' ;

    IF (v_from_rsrc IS NOT NULL AND v_to_rsrc IS NOT NULL) THEN
    sql_stmt1 := sql_stmt1 || '  AND crd.resources BETWEEN :frsrc and :trsrc ' ;
    END IF ;

    sql_stmt1 := sql_stmt1
                  || ' AND NOT EXISTS '
                  || '       (SELECT 1 '
                  || '        FROM gmp_resource_instances '||p_db_link||' gri '
                  || '        WHERE gri.resource_id = un.resource_id ) '
                  || '    )   cmd,  '
                  || '        gmp_calendar_detail_gtmp ' ||p_db_link||' exp  '
                  || '      WHERE  exp.calendar_id = :curr_cal1 '
                  || '        AND  cmd.interval_date  BETWEEN '
                  || '             exp.from_date AND exp.to_date '
                  || ' UNION ALL '
                  || ' SELECT crd.resource_id , '
                  || '        0 , '
                  || '        exp.shift_num,  '
                  || '        0 , '
                  || '        exp.from_date interval_date, '
                  || '        crd.assigned_qty assigned_qty '
                  || ' FROM   cr_rsrc_dtl '||p_db_link||'  crd, '
                  || '        gmp_calendar_detail_gtmp ' ||p_db_link||' exp  '
                  || ' WHERE  crd.orgn_code = :orgn_code5 ' ;

    IF (p_usage = 'BASED') THEN   /* Usage APS */
    sql_stmt1 := sql_stmt1
                  || ' AND    crd.calendar_id = :l_cal_id2 ' ;
    ELSE
    sql_stmt1 := sql_stmt1
                  || ' AND    nvl(crd.calendar_id ,:g_default_cal_id10)= :l_cal_id10 ' ;
    END IF;

    sql_stmt1 := sql_stmt1
                  || ' AND    crd.delete_mark = 0 ' ;

    IF (v_from_rsrc IS NOT NULL AND v_to_rsrc IS NOT NULL) THEN
    sql_stmt1 := sql_stmt1 || '  AND crd.resources BETWEEN :frsrc and :trsrc ' ;
    END IF ;

-- HW B4309093 Check for calendar id in cr_rsrc_dtl
    sql_stmt1 := sql_stmt1
                  || ' AND    exp.calendar_id = :curr_cal2 '
                  || ' UNION ALL '
                  || ' SELECT crd.resource_id , '
                  || '        0 , '
                  || '        exp.shift_num,  '
                  || '        0 , '
                  || '        exp.to_date interval_date, '
                  || '        crd.assigned_qty assigned_qty '
                  || ' FROM   cr_rsrc_dtl '||p_db_link||'  crd, '
                  || '        gmp_calendar_detail_gtmp ' ||p_db_link||' exp  '
                  || ' WHERE  crd.orgn_code = :orgn_code6 ' ;

    IF (p_usage = 'BASED') THEN   /* Usage APS */
    sql_stmt1 := sql_stmt1
                  || ' AND    crd.calendar_id = :l_cal_id2 ' ;
    ELSE
    sql_stmt1 := sql_stmt1
                  || ' AND    nvl(crd.calendar_id ,:g_default_cal_id11)= :l_cal_id11 ' ;
    END IF;

    sql_stmt1 := sql_stmt1
                  || ' AND    crd.delete_mark = 0 ' ;

    IF (v_from_rsrc IS NOT NULL AND v_to_rsrc IS NOT NULL) THEN
    sql_stmt1 := sql_stmt1 || '  AND crd.resources BETWEEN :frsrc and :trsrc ' ;
    END IF ;

    sql_stmt1 := sql_stmt1
                  || ' AND    exp.calendar_id = :curr_cal3 '
                  || ' 			) '
                  || ' 		) '
                  || ' 	WHERE '
                  || ' 		resource_id = lead_rid '
                  || ' 	    AND trunc(interval_date) = trunc(lead_idate) '
                  || ' 	    AND interval_date < lead_idate '
                  || ' 	    AND shift_num = lead_snum  '
                  || ' 	) t '
                  || ' WHERE '
                  || ' 	    t.interval_date >= u.from_date(+) '
                  || '  AND t.lead_idate <= u.to_date1 (+) '
                  || ' 	AND t.resource_id = u.resource_id(+) '
                  || ' GROUP BY '
                  || ' 	 t.resource_id '
                  || ' 	,t.shift_num '
                  || ' 	,t.interval_date '
                  || ' 	,t.assigned_qty '
                  || ' ) rt '
                  || ' WHERE '
                  || ' 	(rt.interval_date = rt.lead_idate OR rt.rsum=0) '
                  || ' 	OR '
                  || ' 	(    rt.interval_date <> rt.lead_idate '
                  || '   AND rt.rsum <> 0 '
                  || '   AND rt.assigned_qty>rsum) '
                  || ' ORDER BY 2,6,5 ';


    IF (v_from_rsrc IS NOT NULL AND v_to_rsrc IS NOT NULL) THEN
-- HW B4309093 Pass correct parameters
    OPEN ri_shift_interval FOR sql_stmt1 USING
           p_orgn_code,p_calendar_id,p_calendar_id, V_FROM_RSRC, V_TO_RSRC ,
           p_orgn_code,p_calendar_id,p_calendar_id, V_FROM_RSRC, V_TO_RSRC ,
           p_orgn_code,p_calendar_id,p_calendar_id, V_FROM_RSRC, V_TO_RSRC ,
           p_orgn_code,p_calendar_id,p_calendar_id, V_FROM_RSRC, V_TO_RSRC ,
           p_orgn_code,p_calendar_id,p_calendar_id, V_FROM_RSRC, V_TO_RSRC ,
           p_orgn_code,p_calendar_id,p_calendar_id, V_FROM_RSRC, V_TO_RSRC ,
           p_orgn_code,p_calendar_id,p_calendar_id, V_FROM_RSRC, V_TO_RSRC ,
           p_orgn_code,p_calendar_id,p_calendar_id, V_FROM_RSRC, V_TO_RSRC ,
           p_orgn_code,p_calendar_id,p_calendar_id, V_FROM_RSRC, V_TO_RSRC ,
           p_calendar_id ,
           p_orgn_code,p_calendar_id,p_calendar_id, V_FROM_RSRC, V_TO_RSRC ,
           p_calendar_id ,
           p_orgn_code,p_calendar_id,p_calendar_id, V_FROM_RSRC, V_TO_RSRC ,
           p_calendar_id  ;

    ELSE

-- HW B4309093 Pass correct parameters
      IF (p_usage = 'BASED') THEN   /* Usage APS */
       OPEN ri_shift_interval FOR sql_stmt1 USING
                p_orgn_code,p_calendar_id,
		p_orgn_code,p_calendar_id,
		p_orgn_code,p_calendar_id,
                p_orgn_code,p_calendar_id,
		p_orgn_code,p_calendar_id,
                p_orgn_code,p_calendar_id,
		p_orgn_code,p_calendar_id,
                p_orgn_code,p_calendar_id,
		p_orgn_code,p_calendar_id, p_calendar_id,
                p_orgn_code,p_calendar_id, p_calendar_id,
                p_orgn_code,p_calendar_id, p_calendar_id ;

      ELSE
       OPEN ri_shift_interval FOR sql_stmt1 USING
                p_orgn_code,g_calendar_id,p_calendar_id,
		p_orgn_code,g_calendar_id,p_calendar_id,
		p_orgn_code,g_calendar_id,p_calendar_id,
                p_orgn_code,g_calendar_id,p_calendar_id,
		p_orgn_code,g_calendar_id,p_calendar_id,
                p_orgn_code,g_calendar_id,p_calendar_id,
		p_orgn_code,g_calendar_id,p_calendar_id,
                p_orgn_code,g_calendar_id,p_calendar_id,
		p_orgn_code,g_calendar_id,p_calendar_id,
                p_calendar_id,
                p_orgn_code, g_calendar_id,p_calendar_id,
		p_calendar_id,
                p_orgn_code, g_calendar_id,p_calendar_id,
		p_calendar_id ;
      END IF ;
    END IF;

    /* B3347284, Performance Issue */
    j := 1 ;
    LOOP
       FETCH ri_shift_interval INTO resource_count(j), resource_id(j),
         instance_id(j), instance_number(j), shift_num(j),
         f_date(j), t_date(j);
       EXIT WHEN ri_shift_interval%NOTFOUND;

    BEGIN
    stmt_no := 74;
    i := 1 ;
    IF (resource_id.FIRST > 0) AND (j = 75000) THEN  /* Only if any resource */

       IF ((p_usage = 'APS') OR (p_usage = 'BASED')) THEN /* Usage APS/BASED */

        FORALL i IN resource_id.FIRST..resource_id.LAST
          INSERT INTO msc_st_net_resource_avail
            ( organization_id,
              sr_instance_id,
              resource_id,
              department_id,
              simulation_set,
              shift_num,
              shift_date,
              from_time,
              to_time,
              capacity_units,
              deleted_flag
              )
           VALUES
            ( p_org_id,
              p_instance_id,
              ((resource_id(i) * 2) + 1), /* B1177070 */
              ((p_org_id * 2) + 1),  /* B1177070 encoded key */
              p_simulation_set,
              shift_num(i),
              trunc(f_date(i)),
              ((f_date(i) - trunc(f_date(i))) * 86400 ),
              ((t_date(i) - trunc(t_date(i))) * 86400 ),
              resource_count(i),
              2
              );

       ELSIF (p_usage = 'WPS') THEN   /* Usage WPS     */

        FORALL i IN resource_id.FIRST..resource_id.LAST
         INSERT INTO gmp_resource_avail
         (
          instance_id, plant_code, resource_id,
          calendar_id, resource_instance_id, shift_num,
          shift_date, from_time, to_time,
          resource_units, creation_date, created_by,
          last_update_date, last_updated_by, last_update_login
         )  VALUES
         (
            p_instance_id,
            p_orgn_code,
            resource_id(i),
            p_calendar_id,
            instance_id(i),
            shift_num(i),
            trunc(f_date(i)),
            ((f_date(i) - trunc(f_date(i))) * 86400 ),
            ((t_date(i) - trunc(t_date(i))) * 86400 ),
            resource_count(i),
            sysdate,
            FND_GLOBAL.USER_ID,
            sysdate,
            FND_GLOBAL.USER_ID,
            FND_GLOBAL.USER_ID
          )           ;

       END IF;   /* APS or WPS */

         resource_count  := empty_num_table;
         resource_id     := empty_num_table;
         instance_id     := empty_num_table;
         instance_number := empty_num_table;
         shift_num       := empty_num_table;
         f_date          := empty_dat_table;
         t_date          := empty_dat_table;
         j:= 0 ;
         /* 8i Database does not support BULK COLLECT - B3881832 */
         dbms_session.free_unused_user_memory;
         COMMIT ;

    END IF;   /* Only if any resource */
    END;

    j := j + 1 ;
    END LOOP ;
    CLOSE ri_shift_interval;

    BEGIN
    stmt_no := 75;
    i := 1 ;
    IF (resource_id.FIRST > 0) THEN  /* Only if any resource */

       IF ((p_usage = 'APS') OR (p_usage = 'BASED')) THEN /* Usage APS/BASED */

        FORALL i IN resource_id.FIRST..resource_id.LAST
          INSERT INTO msc_st_net_resource_avail
            ( organization_id,
              sr_instance_id,
              resource_id,
              department_id,
              simulation_set,
              shift_num,
              shift_date,
              from_time,
              to_time,
              capacity_units,
              deleted_flag
              )
           VALUES
            ( p_org_id,
              p_instance_id,
              ((resource_id(i) * 2) + 1), /* B1177070 */
              ((p_org_id * 2) + 1),  /* B1177070 encoded key */
              p_simulation_set,
              shift_num(i),
              trunc(f_date(i)),
              ((f_date(i) - trunc(f_date(i))) * 86400 ),
              ((t_date(i) - trunc(t_date(i))) * 86400 ),
              resource_count(i),
              2
              );

       ELSIF (p_usage = 'WPS') THEN   /* Usage WPS     */

        FORALL i IN resource_id.FIRST..resource_id.LAST
         INSERT INTO gmp_resource_avail
         (
          instance_id, plant_code, resource_id,
          calendar_id, resource_instance_id, shift_num,
          shift_date, from_time, to_time,
          resource_units, creation_date, created_by,
          last_update_date, last_updated_by, last_update_login
         )  VALUES
         (
            p_instance_id,
            p_orgn_code,
            resource_id(i),
            p_calendar_id,
            instance_id(i),
            shift_num(i),
            trunc(f_date(i)),
            ((f_date(i) - trunc(f_date(i))) * 86400 ),
            ((t_date(i) - trunc(t_date(i))) * 86400 ),
            resource_count(i),
            sysdate,
            FND_GLOBAL.USER_ID,
            sysdate,
            FND_GLOBAL.USER_ID,
            FND_GLOBAL.USER_ID
          )           ;

       END IF;   /* APS or WPS */

         resource_count  := empty_num_table;
         resource_id     := empty_num_table;
         instance_id     := empty_num_table;
         instance_number := empty_num_table;
         shift_num       := empty_num_table;
         f_date          := empty_dat_table;
         t_date          := empty_dat_table;
         /* 8i Database does not support BULK COLLECT - B3881832 */
         dbms_session.free_unused_user_memory;

    END IF;   /* Only if any resource */
    END ;

    /* Insert for msc_st_resource_shifts Starts here - 2213101 */
       stmt_no := 80;
       sql_shifts := ' INSERT INTO msc_st_resource_shifts '
            || '  ( department_id,                  '
            || '  shift_num,                      '
            || '  resource_id,                    '
            || '  deleted_flag,                   '
            || '  sr_instance_id,                 '
            || '  capacity_units                  '
            || '  )                                 '
            || ' SELECT unique '
            || '  ((ic.mtl_organization_id*2)+1) organization_id, '
            || '  gtmp.shift_num,            '
            || '  ((crd.resource_id*2)+1),  '
            || '  2,                        '
            || '  :instance_id,             '
            || '  crd.assigned_qty          '
            || ' FROM gmp_calendar_detail_gtmp'||p_db_link||'  gtmp, '
            || '      sy_orgn_mst'||p_db_link||'  som,   '
            || '      ic_whse_mst'||p_db_link||'  ic,   '
            || '      cr_rsrc_dtl'||p_db_link||'  crd   '
            || ' WHERE gtmp.calendar_id = :curr_cal_id   '
            || ' AND NVL(crd.calendar_id,som.mfg_calendar_id)=gtmp.calendar_id '
            || ' AND som.orgn_code = crd.orgn_code   '
            || ' AND som.resource_whse_code IS NOT NULL  '
            || ' AND crd.delete_mark  = 0                ' ;

     IF ((p_usage = 'APS') OR (p_usage = 'BASED')) THEN /* Usage APS/BASED */
     EXECUTE IMMEDIATE sql_shifts USING p_instance_id,p_calendar_id;
     END IF;

    /* End of Inserts to msc_st_resource_shifts - 2213101  */

  return_status := TRUE;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    log_message('NO DATA FOUND : MSC_CL_GMP_UTILITY.net_rsrc_insert' || stmt_no);
    return_status := TRUE;
  WHEN OTHERS THEN
    log_message('Error in Net Resource Insert: '||stmt_no);
    log_message(sqlerrm);
    return_status := FALSE;

END net_rsrc_insert;

/*
REM+==========================================================================+
REM| PROCEDURE NAME                                                           |
REM|    insert_simulation_sets                                                |
REM|                                                                          |
REM| Type                                                                     |
REM|    public                                                                |
REM|                                                                          |
REM| DESCRIPTION                                                              |
REM|                                                                          |
REM|                                                                          |
REM| Input Parameters                                                         |
REM|    p_org_id - Organization id                                            |
REM|    p_rsrc_whse_code - Resource Whse Code                                 |
REM|    p_instance_id - Instance Id                                           |
REM|    p_delimiter - Delimiter                                               |
REM|                                                                          |
REM| Output Parameters                                                        |
REM|    return_status                                                         |
REM|                                                                          |
REM|                                                                          |
REM| HISTORY                                                                  |
REM|    Created 23th Sep 1999 by Sridhar Gidugu (OPM Development Oracle US)   |
REM|    10/01/1999 - Chaged passing of Parameters to insert_simulation_sets   |
REM|               - Added p_simulation_sets as a parameter and removed       |
REM|               - p_rsrc_whse_code parameter                               |
REM|    10/13/1999 - Added deleted_flag in the insert statement               |
REM|                                                                          |
REM|                                                                          |
REM+==========================================================================+
*/
PROCEDURE insert_simulation_sets(p_org_id         IN NUMBER,
                                 p_instance_id    IN NUMBER,
                                 p_simulation_set IN VARCHAR2,
                                 return_status    OUT NOCOPY BOOLEAN) IS
BEGIN

    IF return_status THEN
       v_cp_enabled := TRUE;
    ELSE
       v_cp_enabled := FALSE;
    END IF;

          INSERT INTO msc_st_simulation_sets
                                        (organization_id,
                                         sr_instance_id,
                                         simulation_set,
                                         description,
                                         use_in_wip_flag,
                                         deleted_flag
                                         )
                             values     (p_org_id,
                                         p_instance_id,
                                         p_simulation_set,
                                         p_simulation_set,
                                         2,
                                         2
                                        ); /* Simulation Set Insert ends here */

     return_status := TRUE;

EXCEPTION
   WHEN  OTHERS THEN
      log_message('Error in insert simulation: ');
      log_message(sqlerrm);
      return_status := FALSE;

END insert_simulation_sets;

/*
REM+==========================================================================+
REM| PROCEDURE NAME                                                           |
REM|    populate_rsrc_cal                                                     |
REM|                                                                          |
REM| Type                                                                     |
REM|    public                                                                |
REM|                                                                          |
REM| DESCRIPTION                                                              |
REM|                                                                          |
REM|                                                                          |
REM| Input Parameters                                                         |
REM|    p_orgn_code - Orgn Code                                               |
REM|    p_org_id - Organization id                                            |
REM|    p_cal_id - calendar_id                                                |
REM|    p_instance_id - Instance Id                                           |
REM|    p_delimiter - Delimiter                                               |
REM|    p_db_link - Data Base Link                                            |
REM|    p_nra_enabled - flag to build net resource available                  |
REM|                                                                          |
REM| Output Parameters                                                        |
REM|    return_status                                                         |
REM|                                                                          |
REM|                                                                          |
REM| HISTORY                                                                  |
REM|    Created 5th Aug 1999 by Sridhar Gidugu (OPM Development Oracle US)    |
REM|    9/1/99 - Main Proc calls the populate_cal_dates                       |
REM|             Update trading Partners and net_rsrc_insert procedure.       |
REM|                                                                          |
REM|    9/7/99 - Changed the Main Procedure, removed UNION ALL for main cursor|
REM|    9/28/99 - Changed the main query ordering by Organization Id and      |
REM|            - changed logic for populating plsqltbl                       |
REM|    4/03/00 - using mtl_organization_id from ic_whse_mst instead of       |
REM|            - organization_id from sy_orgn_mst - Bug# 1252322             |
REM|    5/03/00 - Add instance code as a prefix to the calendar code          |
REM|            - Bug # 1288143                                               |
REM|    7/07/00 - Anchor Date Problem Fixed in the Calendar Code              |
REM|            - Bug # 1337084.                                              |
REM|    7/12/00 - Removed the Debugging Statement shcl.calendar_id in         |
REM|            - (121,126) - bug#1353845                                     |
REM|    10/18/01 - B2041247 - Modified the cursor to consider Calendars       |
REM|            associated with the OPM Plants                                |
REM|                                                                          |
REM|    7th Mar 2003 -- Performance issue fix and B2671540 00:00 shift fix    |
REM|  04/21/2004   - Navin Sinha - B3577871 -ST:OSFME2: collections failing   |
REM|                                in planning data pull.                    |
REM|                                Added handling of NO_DATA_FOUND Exception.|
REM|                                And return the return_status as TRUE.     |
REM|                                                                          |
REM|   07-May-2004 - Sowmya - B3599089 - ST: ORG SPECIFIC COMPLETE COLLETION  |
REM|                          FOR OPM ORGS TAKING MORE TIME.                  |
REM|                          As the varaibale l_org_specific was not getting |
REM|                          refreshed,the resource availability             |
REM|                          was getting collected irrespective of whether or|
REM|                          not the org is enabled. To overcome this, added |
REM|                          if clause containing the l_cur%NOTFOUND.So when |
REM|                          the no values are returned the l_org_specific= 0|
REM|                                                                          |
REM+==========================================================================+
REM
*/

PROCEDURE populate_rsrc_cal(p_run_date    IN DATE,
                            p_instance_id IN NUMBER,
                            p_delimiter   IN VARCHAR2,
                            p_db_link     IN VARCHAR2,
                            p_nra_enabled IN NUMBER,
                            return_status OUT NOCOPY BOOLEAN) IS

/* Local Array Defintions */
TYPE interval_typ_a is RECORD
(
  organization_id 	NUMBER,
  simulation_set  	VARCHAR2(10),
  resource_id     	NUMBER,
  shift_date      	DATE,
  shift_num       	NUMBER,
  capacity_units  	NUMBER,
  from_time       	NUMBER,
  to_time         	NUMBER
);

TYPE interval_tab_a is table of interval_typ_a index by BINARY_INTEGER;
interval_record_aps     interval_typ_a;

TYPE interval_typ_b is RECORD
(
  organization_id 	NUMBER,
  Department_id 	NUMBER,
  resource_id     	NUMBER,
  res_instance_id     	NUMBER,
  equipment_item_id    	NUMBER,
  serial_number  	VARCHAR2(30),
  shift_date      	DATE,
  shift_num       	NUMBER,
  from_time       	NUMBER,
  to_time         	NUMBER
);

TYPE interval_tab_b is table of interval_typ_b index by BINARY_INTEGER;
inst_record_aps     interval_typ_b;

union_cal_ref      ref_cursor_typ;
l_cur              ref_cursor_typ;
ri_assembly	   ref_cursor_typ;
r_inst_assembly	   ref_cursor_typ;
sql_allcal         VARCHAR2(32000);
inst_stmt          VARCHAR2(32000);
inst_resavl  	   VARCHAR2(32000);
Upd_Process_Org    VARCHAR2(32000);
sqlstmt  	   VARCHAR2(32000);
upd_res_avl  	   VARCHAR2(32000);
l_stmt             VARCHAR2(32700);/* Bug # 5086464 */
ins_res_avl        VARCHAR2(32700);
n                  INTEGER;
i                  INTEGER;
j                  INTEGER;
k                  INTEGER;
x                  INTEGER;
y                  INTEGER;
v_icode            VARCHAR2(4);
fetch_cal          NUMBER;
found              NUMBER;
old_org_id         NUMBER;
v_out_cal_no       VARCHAR2(16);
v_already_prefixed VARCHAR2(3);
instance_prefix    VARCHAR2(4);
simulation_set     VARCHAR2(10);
l_opm_org          VARCHAR2(2000);
f_resource_id      NUMBER;
l_org_specific     NUMBER;

BEGIN

n              := 0;
i              := 0;
j              := 0;
k              := 0;
x              := 0;
y              := 0;
v_icode        := '';
fetch_cal      := 0;
found          := 0;
old_org_id     := 0 ;
v_out_cal_no   := '';
v_already_prefixed := '';
instance_prefix    := '';
simulation_set     := NULL;

inst_resavl  	:= NULL;
sqlstmt  	:= NULL;
f_resource_id   := 0;
l_opm_org       := NULL;
l_org_specific  := 0;
l_stmt          := NULL;

     /* Following statements are added to include the instance Code as
        a Prefix to the Calendar Code, this done to maintain the uniqueness
        of a calendar code across instances, prior to this change the
        calendar code was not prefixed with Instance code and this caused
        unique constraint problems - Bug# 1288143
     */

    IF return_status THEN
       v_cp_enabled := TRUE;
    ELSE
       v_cp_enabled := FALSE;
    END IF;

    /* Retrieving the Instance code from MSC_APPS_INSTANCES - Bug#1288143 */
     stmt_no := 05;
     inst_stmt :=  ' SELECT instance_code '
                || ' FROM msc_apps_instances WHERE instance_id = :instance_id ';

     EXECUTE IMMEDIATE inst_stmt INTO v_icode USING p_instance_id ;

     /* Cursor statement to retrieve the calendar_id and the plant that the
        calendar is asociated with and the Organization_id that uses the
        calendar, here the ordering is done by Organization_id,
        resource_whse_code and calendar_id, in that way the primary row
        is always retrieved first and the rest can be skipped
     */
     /* New changes made for main Calendar Cursor - using mtl_organization_id
        from ic_whse_mst instead of organization_id from sy_orgn_mst table
        - Bug# 1252322 */
     /* B2041247 - The following Calendar Cursor has been modified to reflect
        the design changes planned for WPS Process integration. Now The
        calendars that are associated with the OPM plant are considered */

     stmt_no := 10;
     sql_allcal :=  ' SELECT sy.mfg_calendar_id, '
                 || ' shcl.calendar_no, '
                 || ' shcl.calendar_desc, '
                 || ' sy.orgn_code,    '
                 || ' decode(whse.whse_code,sy.resource_whse_code, '
                 || '        sy.resource_whse_code,NULL) resource_whse_code, '
                 || ' ic.mtl_organization_id  organization_id,  '
                 || ' 0  '
                 || ' FROM ps_schd_hdr'||p_db_link||' h, '
                 || '      ps_schd_dtl'||p_db_link||' d, '
                 || '      mr_shcl_hdr'||p_db_link||' shcl, '
                 || '      (select distinct plant_code,whse_code '
                 || '       from ps_whse_eff'||p_db_link|| ') whse, '
                 || '      sy_orgn_mst'||p_db_link||' sy, '
                 || '      ic_whse_mst'||p_db_link||' ic  '
                 || ' WHERE  d.schedule_id = h.schedule_id '
                 || ' AND    d.orgn_code = sy.orgn_code '
                 || ' AND    shcl.calendar_id = sy.mfg_calendar_id ' /* B2041247 */
                 || ' AND    whse.plant_code = sy.orgn_code '
                 || ' AND    whse.whse_code = ic.whse_code '
                 || ' AND    h.active_ind = 1 '
                 || ' AND    shcl.active_ind = 1 '
                 || ' AND    h.delete_mark = 0 '
                 || ' AND    shcl.delete_mark = 0 '
                 || ' ORDER BY organization_id, '
                 || '          resource_whse_code, '
                 || '          mfg_calendar_id ';

     /* The following cursor fetch statement retrieves rows from the Main
        cursor and inserts rows into plsqltbl when the organization_id changes */
     stmt_no := 20;
     i := 0;
     OPEN  union_cal_ref FOR sql_allcal;
     LOOP
          FETCH union_cal_ref INTO cursor_rec;
          EXIT WHEN union_cal_ref%NOTFOUND;
          IF cursor_rec.organization_id <> old_org_id THEN
              i := i + 1;
     /* Prefixing the Instance Code to the calendar code - Bug#1288143 */
     /* Bug# 1337084 - Changed get_cal_no Function to a Procedure - 07/06/00 */

              stmt_no := 22;
              get_cal_no(cursor_rec.calendar_id,
                         cursor_rec.calendar_no,
                         v_icode,
                         v_out_cal_no,
                         v_already_prefixed);

     /* 07/07/2000 - Added a check flag to indicate the Instance is already prefixed
        and this check is being used at the time when the PLSQL table is
        constructed, where in it will not assign an Instance Prefix if the
        calendar_code is already prefixed. - Bug# 1337084. */

              stmt_no := 23;
              IF v_already_prefixed = 'YES' THEN
                   plsqltbl_rec(i).calendar_no := v_out_cal_no ;
              ELSE
                   plsqltbl_rec(i).calendar_no := v_icode||':'||v_out_cal_no ;
              END IF ;

              plsqltbl_rec(i).calendar_id := cursor_rec.calendar_id;
              plsqltbl_rec(i).calendar_desc := cursor_rec.calendar_desc;
              plsqltbl_rec(i).orgn_code := cursor_rec.orgn_code;
              plsqltbl_rec(i).resource_whse_code :=
                              cursor_rec.resource_whse_code;
              plsqltbl_rec(i).organization_id := cursor_rec.organization_id;
              plsqltbl_rec(i).posted := cursor_rec.posted;
          END IF;

          old_org_id := cursor_rec.organization_id;
          v_already_prefixed := 'NO';
          v_out_cal_no := '';
     END LOOP; /* End loop for Main Cursor */
     CLOSE union_cal_ref;

     /* INSERT A LOOP TO SPIT OUT ALL THE ROWS IN PL/SQL TABLE HERE  */

   stmt_no := 30;
   WHILE y = 0 LOOP

     FOR k in 1 .. plsqltbl_rec.COUNT
     LOOP

     /* Checking if there are any rows in PL/SQL that were processed */
     IF plsqltbl_rec(k).posted = 0 THEN
        found := 1;

         IF fetch_cal = 0 THEN
	    fetch_cal := plsqltbl_rec(k).calendar_id;

           /* Calling the retrieve Calendar Procedure,which explodes the calendar
              for a given Calendar Id */

           stmt_no := 40;
           retrieve_calendar_detail(plsqltbl_rec(k).calendar_id,
                                    plsqltbl_rec(k).calendar_no,
                                    plsqltbl_rec(k).calendar_desc,
                                    p_run_date,
                                    p_db_link,
                                    p_instance_id,
                                    V_APS,
                                    return_status
                                   );
         END IF;

       IF plsqltbl_rec(k).calendar_id = fetch_cal THEN

           /* Calling the Update Trading Partner Procedure,which updates the
              MSC_ST_TRADING_PARTNERS with the Calendar Code for a given Organization
              Id
           */
           stmt_no := 50;
           update_trading_partners(plsqltbl_rec(k).organization_id,
                                   plsqltbl_rec(k).calendar_no,
                                   return_status
                                   );

         IF plsqltbl_rec(k).resource_whse_code IS NOT NULL  THEN

          /* Check if the org string have the organization */
           BEGIN
            stmt_no := 51;
            IF MSC_CL_GMP_UTILITY.org_string(p_instance_id) THEN
               NULL ;
            ELSE
               RAISE invalid_string_value  ;
            END IF;

            l_opm_org := plsqltbl_rec(k).organization_id ;

            IF MSC_CL_GMP_UTILITY.g_in_str_org IS NOT NULL THEN
             l_stmt := 'SELECT 1 FROM dual WHERE '||
                        l_opm_org||MSC_CL_GMP_UTILITY.g_in_str_org ;
                OPEN l_cur for l_stmt ;
                FETCH l_cur INTO l_org_specific ;
                IF l_cur%NOTFOUND THEN
                        l_org_specific := 0;
                END IF;
                /*B3599089 - sowsubra - When the organization is not in the list ,
                the resource  availability was getting collected
                irrespective of whether or not the org is enabled . So
                added this to reset the value of l_org_specific. */
                CLOSE l_cur ;
            END IF;

           EXCEPTION
              WHEN NO_DATA_FOUND THEN
                l_org_specific := 0 ;
                NULL ;
              WHEN OTHERS THEN
                log_message('Error in org string decision:  '||stmt_no);
                log_message(sqlerrm);
                l_org_specific := 0 ;
                return_status := FALSE;
           END;

             IF l_org_specific = 1 THEN

               /* B3452373, Simulation set should be null, as OPM stops sending this
                  information to APS and hence related code is commented */
                 simulation_set := NULL ;

               IF p_nra_enabled = V_YES THEN
                 /* Populating Net Resource Insert Table */
                 stmt_no := 65;
                 net_rsrc_insert(plsqltbl_rec(k).organization_id,
                                 plsqltbl_rec(k).orgn_code,
                                 simulation_set,
                                 p_db_link,
                                 p_instance_id,
                                 p_run_date,
                                 plsqltbl_rec(k).calendar_id,
                                 V_APS,
                                 return_status
                                 );
        /* Populate Net Resource Instance rows  PS Integration */
           net_rsrc_avail_calculate(plsqltbl_rec(k).organization_id,
                                    plsqltbl_rec(k).orgn_code,
                                    plsqltbl_rec(k).calendar_id,
                                    p_instance_id,
                                    p_db_link,
                                    V_APS,
                                    return_status)  ;
               END IF;
             END IF;  /* org_specific */

         END IF;  /* rsrc whse code not null */

         /* Marking that particular as being Posted, after making all the calls
            to the Procedure */
         plsqltbl_rec(k).posted := 1;

       END IF;  /* cal_id = fetch_cal */

     END IF;  /* postd = 0 */
     END LOOP;  /* End loop for PL/SQL table */

     IF found = 1 THEN
       fetch_cal := 0;
       found := 0;
     ELSE
       y := 1;
     END IF;
   END LOOP;  /* End Loop for While */

     /* B5001619 Rajesh All the process orgs should have organization_type=2 */
      BEGIN
       stmt_no := 67 ;
       Upd_Process_Org := 'UPDATE MSC_ST_TRADING_PARTNERS '
       ||' SET organization_type = 2 '
       ||' WHERE sr_tp_id in (SELECT organization_id '
       ||'                    FROM  mtl_parameters'||p_db_link
       ||'                    WHERE process_enabled_flag = '||''''||'Y'||'''' || ')'
       ||' AND partner_type = 3' ;

       EXECUTE IMMEDIATE  Upd_Process_Org;
       log_message('Trading Partner Update is Done' );

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
           NULL ;
        WHEN OTHERS THEN
          log_message('Error in UPDATE TRADING_PARTNERS  '||stmt_no);
          log_message(SQLERRM);
          return_status := FALSE;
      END ;

   /* Addition of shifts/Datetime in resource calendar functionlality */
    IF p_nra_enabled = V_YES THEN
        log_message('Enter rsrcal_based_availability ');
        rsrcal_based_availability(p_run_date ,
                                  p_instance_id ,
                                  p_db_link ,
                                  return_status) ;
        log_message('Return From rsrcal_based_availability ');
    END IF;

   /* 7th Mar 2003 -- Performance issue fix and B2671540 00:00 shift fix */
   /* This logic introduced for Net resource availablility to
       write consolidated rows once final available rows are in place */
    stmt_no := 75;

   ins_res_avl :=  ' SELECT '
   || '        net.organization_id, '
   || '        net.simulation_set, '
   || '        net.resource_id , '
   || '        net.shift_date  , '
   || '        net.shift_num   , '
   || '        net.capacity_units , '
   || '        min(net.from_time) from_time, '
   || '        max(net.lead_tt) to_time '
   || ' FROM  ( '
   || '        SELECT organization_id , '
   || '               simulation_set, '
   || '               resource_id, '
   || '               shift_date  , '
   || '               shift_num , '
   || '               capacity_units , '
   || '               from_time , '
   || '               to_time , '
   || '  lead(organization_id,1) '
   || '  over(order by organization_id,simulation_set, '
   || '  resource_id,shift_date, shift_num,from_time,to_time,capacity_units) '
   || '  as lead_iid, '
   || '  lead(simulation_set,1) '
   || '  over(order by organization_id,simulation_set,'
   || '  resource_id,shift_date, shift_num,from_time,to_time,capacity_units) '
   || '  as lead_ss, '
   || '  lead(resource_id,1) '
   || '  over(order by organization_id,simulation_set,'
   || '  resource_id,shift_date, shift_num,from_time,to_time,capacity_units) '
   || '  as lead_rid, '
   || '  lead(shift_date,1) '
   || '  over(order by organization_id,simulation_set,'
   || '  resource_id,shift_date, shift_num,from_time,to_time,capacity_units) '
   || '  as lead_sdt, '
   || '  lead(shift_num,1) '
   || '  over(order by organization_id,simulation_set,'
   || '  resource_id,shift_date, shift_num,from_time,to_time,capacity_units) '
   || '  as lead_sn, '
   || '  lead(from_time,1) '
   || '  over(order by organization_id,simulation_set,'
   || '  resource_id,shift_date, shift_num,from_time,to_time,capacity_units) '
   || '  as lead_ft, '
   || '  lead(to_time,1) '
   || '  over(order by organization_id,simulation_set,'
   || '  resource_id,shift_date, shift_num,from_time,to_time,capacity_units) '
   || '  as lead_tt, '
   || '  lead(capacity_units,1) '
   || '  over(order by organization_id,simulation_set,'
   || '  resource_id,shift_date, shift_num,from_time,to_time,capacity_units) '
   || '  as lead_rc '
   || '          FROM msc_st_net_resource_avail '
   || '          WHERE sr_instance_id = :inst_id '
   || '              ) net '
   || '      WHERE net.resource_id     = net.lead_rid '
   || '        AND net.organization_id = net.lead_iid '
   || '        AND net.simulation_set  = net.lead_ss '
   || '        AND net.shift_num       = net.lead_sn '
   || '        AND net.shift_date      = net.lead_sdt '
   || '        AND net.to_time         = net.lead_ft '
   || '        AND net.capacity_units  = net.lead_rc '
   || ' GROUP BY '
   || '        net.organization_id , '
   || '        net.simulation_set , '
   || '        net.resource_id , '
   || '        net.shift_date , '
   || '        net.shift_num , '
   || '        net.capacity_units ' ;

    stmt_no := 76;
    OPEN ri_assembly FOR ins_res_avl  USING p_instance_id ;
    LOOP
       FETCH ri_assembly INTO  interval_record_aps;
       EXIT WHEN ri_assembly%NOTFOUND;

     sqlstmt := ' DELETE FROM msc_st_net_resource_avail '
             || ' WHERE organization_id  = :org_id '
             || '   AND simulation_set = :sim_set '
             || '   AND sr_instance_id = :inst_id '
             || '   AND resource_id = :prid '
             || '   AND shift_date = :psdt '
             || '   AND shift_num  = :psn  '
             || '   AND capacity_units = :prc '
             || '   AND from_time  >= :pft '
             || '   AND to_time  <= :ptt '  ;

    stmt_no := 77;
       EXECUTE immediate sqlstmt USING
       interval_record_aps.organization_id ,
       interval_record_aps.simulation_set ,
       p_instance_id ,
       interval_record_aps.resource_id,
       interval_record_aps.shift_date,
       interval_record_aps.shift_num,
       interval_record_aps.capacity_units,
       interval_record_aps.from_time,
       interval_record_aps.to_time  ;

       f_resource_id :=  (interval_record_aps.resource_id - 1 )/ 2 ;

    stmt_no := 78;
         net_rsrc(
            p_instance_id,
            interval_record_aps.organization_id,
            interval_record_aps.simulation_set,
            f_resource_id,
            interval_record_aps.capacity_units,
            interval_record_aps.shift_num,
            trunc(interval_record_aps.shift_date),
            interval_record_aps.from_time ,
            interval_record_aps.to_time
                  );

	f_resource_id  := 0 ;
       COMMIT ;
    END LOOP;
    CLOSE ri_assembly;

    stmt_no := 79;
    upd_res_avl := null ;
    upd_res_avl := 'UPDATE msc_st_net_resource_avail '
            ||' SET to_time   = 86400 '
            ||' WHERE to_time = 86399 '
            ||'   AND shift_num >= 99999 ' ;

       EXECUTE immediate upd_res_avl;

    stmt_no := 80;
    upd_res_avl := null ;
    upd_res_avl := 'UPDATE msc_st_net_resource_avail '
            ||' SET shift_num = (shift_num - 99999) '
            ||' WHERE shift_num >= 99999 ' ;

       EXECUTE immediate upd_res_avl;
       COMMIT ;

   /* Final rows for msc_st_net_res_inst_avail */
   stmt_no := 81;
   inst_resavl :=  null;

   inst_resavl := ' SELECT '
   || '        net.organization_id, '
   || '        net.Department_id, '
   || '        net.resource_id , '
   || '        net.res_instance_id , '
   || '        net.equipment_item_id , '
   || '        net.serial_number, '
   || '        net.shift_date  , '
   || '        net.shift_num   , '
   || '        min(net.from_time) from_time, '
   || '        max(net.lead_tt) to_time '
   || ' FROM  ( '
   || '        SELECT organization_id , '
   || '               Department_id, '
   || '               resource_id, '
   || '               res_instance_id, '
   || '               equipment_item_id, '
   || '               serial_number, '
   || '               shift_date  , '
   || '               shift_num , '
   || '               from_time , '
   || '               to_time , '
   || '  lead(organization_id,1) '
   || '  over(order by organization_id,Department_id,resource_id,res_instance_id, '
   || '  equipment_item_id,serial_number, shift_date,shift_num,from_time,to_time) '
   || '  as lead_iid, '
   || '  lead(Department_id,1) '
   || '  over(order by organization_id,Department_id,resource_id,res_instance_id, '
   || '  equipment_item_id,serial_number, shift_date,shift_num,from_time,to_time) '
   || '  as lead_did, '
   || '  lead(resource_id,1) '
   || '  over(order by organization_id,Department_id,resource_id,res_instance_id, '
   || '  equipment_item_id,serial_number, shift_date,shift_num,from_time,to_time) '
   || '  as lead_rid, '
   || '  lead(res_instance_id,1) '
   || '  over(order by organization_id,Department_id,resource_id,res_instance_id, '
   || '  equipment_item_id,serial_number, shift_date,shift_num,from_time,to_time) '
   || '  as lead_r_inst_id, '
   || '  lead(equipment_item_id,1) '
   || '  over(order by organization_id,Department_id,resource_id,res_instance_id, '
   || '  equipment_item_id,serial_number, shift_date,shift_num,from_time,to_time) '
   || '  as lead_eid, '
   || '  lead(serial_number,1) '
   || '  over(order by organization_id,Department_id,resource_id,res_instance_id, '
   || '  equipment_item_id,serial_number, shift_date,shift_num,from_time,to_time) '
   || '  as lead_sr_no, '
   || '  lead(shift_date,1) '
   || '  over(order by organization_id,Department_id,resource_id,res_instance_id, '
   || '  equipment_item_id,serial_number, shift_date,shift_num,from_time,to_time) '
   || '  as lead_sdt, '
   || '  lead(shift_num,1) '
   || '  over(order by organization_id,Department_id,resource_id,res_instance_id, '
   || '  equipment_item_id,serial_number, shift_date,shift_num,from_time,to_time) '
   || '  as lead_sn, '
   || '  lead(from_time,1) '
   || '  over(order by organization_id,Department_id,resource_id,res_instance_id, '
   || '  equipment_item_id,serial_number, shift_date,shift_num,from_time,to_time) '
   || '  as lead_ft, '
   || '  lead(to_time,1) '
   || '  over(order by organization_id,Department_id,resource_id,res_instance_id, '
   || '  equipment_item_id,serial_number, shift_date,shift_num,from_time,to_time) '
   || '  as lead_tt '
   || '          FROM msc_st_net_res_inst_avail '
   || '          WHERE sr_instance_id = :inst_id '
   || '              ) net '
   || '      WHERE '
   || '            net.organization_id   = net.lead_iid '
   || '        AND net.Department_id     = net.lead_did '
   || '        AND net.resource_id       = net.lead_rid '
   || '        AND net.res_instance_id   = net.lead_r_inst_id '
   || '        AND net.equipment_item_id = net.lead_eid '
   || '        AND net.serial_number     = net.lead_sr_no '
   || '        AND net.shift_date        = net.lead_sdt '
   || '        AND net.shift_num         = net.lead_sn '
   || '        AND net.to_time           = net.lead_ft '
   || ' GROUP BY '
   || '        net.organization_id, '
   || '        net.Department_id, '
   || '        net.resource_id , '
   || '        net.res_instance_id , '
   || '        net.equipment_item_id , '
   || '        net.serial_number, '
   || '        net.shift_date  , '
   || '        net.shift_num   ' ;

    stmt_no := 82;
    OPEN r_inst_assembly FOR inst_resavl  USING p_instance_id ;
    LOOP
       FETCH r_inst_assembly INTO  inst_record_aps;
       EXIT WHEN r_inst_assembly%NOTFOUND;

     sqlstmt := ' DELETE FROM msc_st_net_res_inst_avail '
             || ' WHERE organization_id  = :org_id '
             || '   AND Department_id  = :dept_id '
             || '   AND sr_instance_id = :inst_id '
             || '   AND resource_id = :prid '
             || '   AND res_instance_id = :pr_inst_id '
             || '   AND equipment_item_id = :pe_id '
             || '   AND serial_number = :ps_no '
             || '   AND shift_date = :psdt '
             || '   AND shift_num  = :psn  '
             || '   AND from_time  >= :pft '
             || '   AND to_time  <= :ptt '  ;

    stmt_no := 83;
       EXECUTE immediate sqlstmt USING
       inst_record_aps.organization_id ,
       inst_record_aps.Department_id ,
       p_instance_id ,
       inst_record_aps.resource_id,
       inst_record_aps.res_instance_id,
       inst_record_aps.equipment_item_id,
       inst_record_aps.serial_number ,
       inst_record_aps.shift_date,
       inst_record_aps.shift_num,
       inst_record_aps.from_time,
       inst_record_aps.to_time  ;

    stmt_no := 84;

        INSERT INTO msc_st_net_res_inst_avail
          ( Organization_Id,
            Department_id,
            sr_instance_id,
            Resource_Id,
            res_instance_id,
            serial_number,
            equipment_item_id,
            Shift_Num,
            Shift_Date,
            From_Time,
            To_Time
         )  VALUES
         (  inst_record_aps.organization_id ,
            inst_record_aps.Department_id ,
            p_instance_id  ,
            inst_record_aps.resource_id,
            inst_record_aps.res_instance_id,
            inst_record_aps.equipment_item_id,
            inst_record_aps.serial_number ,
            inst_record_aps.shift_num,
            inst_record_aps.shift_date,
            inst_record_aps.from_time,
            inst_record_aps.to_time
         )  ;

       COMMIT ;
    END LOOP;
    CLOSE r_inst_assembly;

    stmt_no := 85;
    sqlstmt := null ;
    sqlstmt := 'UPDATE msc_st_net_res_inst_avail '
            ||' SET to_time   = 86400 '
            ||' WHERE to_time = 86399 '
            ||'   AND shift_num >= 99999 ' ;

       EXECUTE immediate sqlstmt;
    sqlstmt := null ;
    stmt_no := 86;
    sqlstmt := 'UPDATE msc_st_net_res_inst_avail '
            ||' SET shift_num = (shift_num - 99999) '
            ||' WHERE shift_num >= 99999 ' ;

       EXECUTE immediate sqlstmt;
       COMMIT ;

   return_status := TRUE;

EXCEPTION
    WHEN invalid_string_value  THEN
      log_message('APS string is Invalid, check for Error condition' );
      return_status := FALSE;
    WHEN NO_DATA_FOUND THEN /* B3577871 */
      log_message(' NO_DATA_FOUND exception : MSC_CL_GMP_UTILITY.Populate_rsrc_cal ' );
      return_status := TRUE;
    WHEN OTHERS THEN
      log_message('Error in Populate Rsrc cal construct: '||stmt_no);
      log_message('Error : '||v_icode);
      log_message(SQLERRM);
      return_status := FALSE;

END populate_rsrc_cal;  /* End of Main Procedure */

/*
REM+==========================================================================+
REM| PROCEDURE NAME                                                           |
REM|    rsrcal_based_availability                                             |
REM|                                                                          |
REM| Type                                                                     |
REM|    private                                                               |
REM|                                                                          |
REM| DESCRIPTION                                                              |
REM|    This Procedure will calcaulate net resource availability              |
REM|    for all the resources having their own calendars different            |
REM|    from plant's manufacturing calendar                                   |
REM| Input Parameters                                                         |
REM|    p_run_date    - Running Date                                          |
REM|    p_instance_id - Instance Id                                           |
REM|    p_db_link - Data Base Link                                            |
REM|                                                                          |
REM| Output Parameters                                                        |
REM|    return_status                                                         |
REM|                                                                          |
REM| HISTORY                                                                  |
REM|    06/07/2005  by Rajesh Patangya (OPM Development Oracle US)            |
REM+==========================================================================+
REM
*/
PROCEDURE rsrcal_based_availability(p_run_date    IN DATE,
                                    p_instance_id IN NUMBER,
                                    p_db_link     IN VARCHAR2,
                                    return_status OUT NOCOPY BOOLEAN) IS

  /*  Declare  Cursor Types */
  cur_get_cal      ref_cursor_typ;

  TYPE cal_org_typ is RECORD
  ( calendar_id      number,
    calendar_no      varchar2(16),
    calendar_desc    varchar2(40),
    orgn_code        varchar2(4),
    organization_id  number
  );
  calorg_record  cal_org_typ;

  sql_get_cal      VARCHAR2(32700);/* Bug # 5086464 */
  old_calendar_id  NUMBER ;

BEGIN
  stmt_no          := 0 ;
  old_calendar_id  := -1;

         stmt_no := 610;
         /* populate the org_string */
         IF MSC_CL_GMP_UTILITY.org_string(p_instance_id) THEN
            NULL ;
         ELSE
            RAISE invalid_string_value  ;
         END IF;

         sql_get_cal :=  ' SELECT distinct crd.calendar_id,  '
            ||' shcl.calendar_no, shcl.calendar_desc, '
            ||' sy.orgn_code, iwm.mtl_organization_id '
            ||' FROM mr_shcl_hdr'||p_db_link||' shcl, '
            ||'      sy_orgn_mst'||p_db_link||' sy,  '
            ||'      cr_rsrc_dtl'||p_db_link||' crd,  '
            ||'      ic_whse_mst'||p_db_link||' iwm  '
            ||' WHERE sy.orgn_code = crd.orgn_code '
	    ||'   AND sy.mfg_calendar_id <> crd.calendar_id '
            ||'   AND crd.calendar_id IS NOT NULL '
            ||'   AND crd.calendar_id = shcl.calendar_id '
            ||'   AND iwm.whse_code = sy.resource_whse_code ' ;

        IF MSC_CL_GMP_UTILITY.g_in_str_org  IS NOT NULL THEN
         sql_get_cal := sql_get_cal
            ||'   AND iwm.mtl_organization_id '||MSC_CL_GMP_UTILITY.g_in_str_org;
        END IF;

         sql_get_cal := sql_get_cal
            ||'   AND shcl.delete_mark = 0 '
            ||'   AND crd.delete_mark = 0 '
            ||' ORDER BY crd.calendar_id  ' ;

     OPEN cur_get_cal FOR sql_get_cal ;
     LOOP
     FETCH cur_get_cal INTO calorg_record ;
     EXIT WHEN cur_get_cal%NOTFOUND ;

      log_message('BASED: ' || calorg_record.calendar_id );
      IF calorg_record.calendar_id <> old_calendar_id THEN
         stmt_no := 611 ;
         COMMIT;  -- To Empty the _GTMP Table

      log_message('BASED 1 ' );
         retrieve_calendar_detail(calorg_record.calendar_id,
                                  calorg_record.calendar_no,
                                  calorg_record.calendar_desc,
                                  p_run_date,
                                  p_db_link,
                                  p_instance_id,
                                  V_WPS,
                                  return_status
                                  );
      END IF ;

      log_message('BASED 2 ' );
         stmt_no := 622;
         /* Populating Net Resource Insert Table */
         net_rsrc_insert(calorg_record.organization_id,
                         calorg_record.orgn_code,
                         NULL,    -- simulation_set,
                         p_db_link,
                         p_instance_id,
                         p_run_date,
                         calorg_record.calendar_id,
                         V_BASED,
                         return_status
                         );

      log_message('BASED 3 ' );
        /* Populate Net Resource Instance rows  PS Integration */
           net_rsrc_avail_calculate(calorg_record.organization_id,
                                    calorg_record.orgn_code,
                                    calorg_record.calendar_id,
                                    p_instance_id,
                                    p_db_link,
                                    V_BASED,
                                    return_status)  ;
      log_message('BASED 4 ' );
    COMMIT ;

      old_calendar_id := calorg_record.calendar_id ;

     END LOOP ;
     CLOSE cur_get_cal ;
     return_status := TRUE;

EXCEPTION
    WHEN invalid_string_value  THEN
      log_message('APS string is Invalid, check for Error condition' );
      return_status := FALSE;
    WHEN NO_DATA_FOUND THEN
      log_message('NO DATA FOUND exception: MSC_CL_GMP_UTILITY.rsrcal_based_availability');
      return_status := TRUE;
    WHEN OTHERS THEN
      log_message('Error in MSC_CL_GMP_UTILITY.rsrcal_based_availability '||p_instance_id);
      log_message(sqlerrm);
      return_status := FALSE;

END rsrcal_based_availability;

/*
REM+==========================================================================+
REM| PROCEDURE NAME                                                           |
REM|    insert_gmp_resource_avail                                             |
REM|                                                                          |
REM| Type                                                                     |
REM|    public                                                                |
REM|                                                                          |
REM| DESCRIPTION                                                              |
REM|                                                                          |
REM| Input Parameters                                                         |
REM|    p_orgn_code - Orgn Code                                               |
REM|                                                                          |
REM| Output Parameters                                                        |
REM|    errbuf and retcode                                                    |
REM|                                                                          |
REM| HISTORY                                                                  |
REM|    Created on 4th Jan 2002 By Rajesh Patangya                            |
REM| B3161696 - 26-SEP-2003 TARGETTED RESOURCE AVAILABILITY PLACEHOLDER BUG   |
REM| B4309093 - 20-APR-2005 Modified code to TO ADD TIME OR A SHIFT TO A      |
REM|                        PLANT RESOURCE                                    |
REM+==========================================================================+
*/
PROCEDURE insert_gmp_resource_avail( errbuf        OUT NOCOPY VARCHAR2,
                                     retcode       OUT NOCOPY NUMBER  ,
                                     p_orgn_code   IN VARCHAR2 ,
                                     p_from_rsrc   IN VARCHAR2 ,
                                     p_to_rsrc     IN VARCHAR2 ,
                                     p_calendar_id IN NUMBER   ) IS

  cal_detail_ref    ref_cursor_typ;
  cur_get_def_cal   ref_cursor_typ;
  cur_get_cal       ref_cursor_typ;
  l_calendar_no     varchar2(16) ;
  l_calendar_desc   varchar2(40) ;
  l_calendar_id     NUMBER  ;
  i                 integer ;
  l_message         varchar2(1000) ;
  ret_status        boolean ;
  sql_stmt1	    VARCHAR2(32000) ;
  sql_stmt2	    VARCHAR2(32000) ;
  delete_stmt	    VARCHAR2(32000) ;
  sql_get_cal	    VARCHAR2(32000) ;
  sql_get_def_cal   VARCHAR2(32000) ;

BEGIN
  i                 := 1 ;
  stmt_no	    := 0 ;
  l_message         := NULL ;
  sql_stmt1         := NULL;
  sql_stmt2         := NULL;
  sql_get_cal       := NULL;
  delete_stmt       := NULL;
  l_calendar_id     := 0 ;

  V_FROM_RSRC := p_from_rsrc;
  V_TO_RSRC   := p_to_rsrc ;
  l_calendar_id := p_calendar_id ;


--HW B4309093 Case I - Calendar is blank
IF p_calendar_id is NULL THEN

-- This also covers if From and To resources are blank
    sql_get_cal :=  ' SELECT '
         ||'  DISTINCT NVL(r.calendar_id,sy.mfg_calendar_id), '
         ||' shcl.calendar_no, shcl.calendar_desc '
         ||' FROM mr_shcl_hdr shcl, '
         ||'      sy_orgn_mst sy, '
         ||'      cr_rsrc_dtl r   '
         ||' WHERE sy.orgn_code = r.orgn_code '
	 ||'   AND NVL(r.calendar_id,sy.mfg_calendar_id)=shcl.calendar_id '
	 ||'   AND r.orgn_code = :lorgn_code '
         ||'   AND shcl.delete_mark = 0 ' ;

-- Case A - From Resource is entered and To Resource is blank

   IF (v_from_rsrc IS NOT NULL AND v_to_rsrc IS NULL) THEN
     sql_get_cal := sql_get_cal  || ' AND r.resources >= :frsrc ' ;
     OPEN cur_get_cal FOR sql_get_cal USING p_orgn_code , p_from_rsrc;

-- Case B - From and TO resources are entered

   ELSE
     IF (v_from_rsrc IS NOT NULL AND v_to_rsrc IS NOT NULL) THEN
       sql_get_cal := sql_get_cal  || ' AND resources BETWEEN :frsrc and :trsrc ';
       OPEN cur_get_cal FOR sql_get_cal USING p_orgn_code , p_from_rsrc, p_to_rsrc ;

-- Case C - From and TO resources are blank
-- Statement is already constrcut at top
     ELSIF ( v_from_rsrc IS NULL AND v_to_rsrc IS NULL) THEN
      OPEN cur_get_cal FOR sql_get_cal USING p_orgn_code ;
     END IF ;

   END IF;

-- Case II Calendar is entered
ELSE
-- Case A- Both from and To resources are entered
      sql_get_cal := 'Select calendar_id, '
		||' calendar_no,calendar_desc '
		||' FROM mr_shcl_hdr '
		||' WHERE calendar_id = :cal_id ' ;
      OPEN cur_get_cal FOR sql_get_cal USING p_calendar_id ;
END IF ;

-- HW B4309093 Loop through the calendars
LOOP
FETCH cur_get_cal INTO l_calendar_id, l_calendar_no, l_calendar_desc ;
EXIT WHEN cur_get_cal%NOTFOUND ;

     stmt_no := 1 ;
     delete_stmt := 'DELETE FROM gmp_resource_avail '||
                    ' WHERE calendar_id = :cal_id '  ||
                    '   AND plant_code  = :Plant_code1 ';

    IF (v_from_rsrc IS NOT NULL AND v_to_rsrc IS NOT NULL) THEN
      delete_stmt := delete_stmt ||' AND resource_id in (select resource_id '
                            ||' FROM cr_rsrc_dtl '
                            ||' WHERE orgn_code = :Plant_code2 '
                            ||' AND resources BETWEEN :frsrc and :trsrc ) ';
     EXECUTE IMMEDIATE delete_stmt USING l_calendar_id, p_orgn_code,
                   p_orgn_code, v_from_rsrc, v_to_rsrc;
    ELSIF (v_from_rsrc IS NOT NULL AND v_to_rsrc IS NULL) THEN
      delete_stmt := delete_stmt ||' AND resource_id in (select resource_id '
                            ||' FROM cr_rsrc_dtl '
                            ||' WHERE orgn_code = :Plant_code2 '
                            ||' AND resources > :frsrc ) ';
     EXECUTE IMMEDIATE delete_stmt USING l_calendar_id, p_orgn_code,
                   p_orgn_code, v_from_rsrc;

    ELSIF (v_from_rsrc IS NULL AND v_to_rsrc IS NULL) THEN
     EXECUTE IMMEDIATE delete_stmt USING l_calendar_id, p_orgn_code ;

    END IF ;

    COMMIT;

    retrieve_calendar_detail(l_calendar_id,
                             l_calendar_no,
                             l_calendar_desc,
                             null,
                             null,
                             null,
                             V_WPS,
                             ret_status)  ;

    /* Summary rows for WPS */
    net_rsrc_insert(null,
                    p_orgn_code,
                    null,
                    null,
                    0,
                    sysdate,
                    l_calendar_id,
                    V_WPS,
                    ret_status)  ;
    COMMIT ;

    /* Instance number rows for WPS */
    net_rsrc_avail_calculate(null,
                             p_orgn_code,
                             l_calendar_id,
                             null,   /* MSC INSTANCE */
                             null,   /* DB LINK */
                             V_WPS,
                             ret_status)  ;
    COMMIT ;

END LOOP ;
CLOSE cur_get_cal ; -- HW B4309093

    retcode := 0 ;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
       l_message := 'Manufacturing Calendar is not assigned to '|| p_orgn_code ;
       log_message(l_message);
       retcode := 1 ;
   WHEN OTHERS THEN
       log_message(sqlerrm);
       retcode := 1 ;

END insert_gmp_resource_avail;

/*
REM+==========================================================================+
REM| PROCEDURE NAME                                                           |
REM|    net_rsrc_avail_calculate                                              |
REM|                                                                          |
REM| Type                                                                     |
REM|    public                                                                |
REM|                                                                          |
REM| DESCRIPTION                                                              |
REM|                                                                          |
REM| Input Parameters                                                         |
REM|    p_nstance_id - Instance_id                                            |
REM|    p_orgn_code - Orgn Code                                               |
REM|    p_instance_id - Instance Id                                           |
REM|    p_db_link - Data Base Link                                            |
REM|                                                                          |
REM| Output Parameters                                                        |
REM|    return_status                                                         |
REM|                                                                          |
REM| HISTORY                                                                  |
REM|    Created on 4th Jan 2002 By Rajesh Patangya                            |
REM|    7th Mar 2003 -- Performance issue fix and B2671540 00:00 shift fix    |
REM| B3161696 - 26-SEP-2003 TARGETTED RESOURCE AVAILABILITY PLACEHOLDER BUG   |
REM| B4309093 - 20-APR-2005 Modified code to TO ADD TIME OR A SHIFT TO A      |
REM|                        PLANT RESOURCE                                    |
REM+==========================================================================+
*/

PROCEDURE net_rsrc_avail_calculate(
                          p_org_id       IN NUMBER,
                          p_orgn_code    IN VARCHAR2,
                          p_calendar_id  IN NUMBER,
                          p_instance_id  IN NUMBER,
                          p_db_link      IN VARCHAR2,
                          p_usage        IN VARCHAR2,   /* OPM-PS */
                          return_status  OUT NOCOPY BOOLEAN) IS

/* For GMP_RESOURCE_AVAIL array definition */
TYPE interval_typ is RECORD
(
  resource_id           NUMBER,
  resource_instance_id  NUMBER,
  shift_date            DATE,
  shift_num             NUMBER,
  resource_units        NUMBER,
  from_time             NUMBER,
  to_time               NUMBER
);

TYPE interval_tab is table of interval_typ index by BINARY_INTEGER;

interval_record		interval_typ;
interval_rec		interval_tab;

ri_assembly	        ref_cursor_typ;
ri_shift_interval	ref_cursor_typ;

sqlstmt		        VARCHAR2(32000) ;
sqlupt 		        VARCHAR2(32000) ;
sql_stmt1		VARCHAR2(32000) ;
sql_stmt2		VARCHAR2(32000) ;

k         		INTEGER ;
i         		INTEGER ;
j         		INTEGER ;
g_calendar_id           NUMBER  ;
x_dept_id               NUMBER  ;

BEGIN

         /* 8i Database does not support BULK COLLECT - B3881832 */
         sqlstmt	 := NULL;
         sqlupt 	 := NULL;
         sql_stmt1	 := NULL;
         sql_stmt2	 := NULL;
         stmt_no	 := 0 ;
         x_dept_id       := 0 ;
         k         	 := 1;
         i         	 := 1;
         j         	 := 1;
         resource_count  := empty_num_table;
         resource_id     := empty_num_table;
         instance_id     := empty_num_table;
         instance_number := empty_num_table;
         shift_num       := empty_num_table;
         f_date          := empty_dat_table;
         t_date          := empty_dat_table;
         /* 8i Database does not support BULK COLLECT - B3881832 */
         dbms_session.free_unused_user_memory;

         stmt_no := 60;
         -- Rajesh Patangya B4692705, When the calendar is not assigned to
         -- resource then organization calendar should be considered
	 g_calendar_id 	:= 0 ;
         sql_stmt1 :=  '  SELECT mfg_calendar_id '
                    || '  FROM sy_orgn_mst'||p_db_link
                    || '  WHERE orgn_code = :orgn_code1 ';

         EXECUTE IMMEDIATE sql_stmt1 INTO g_calendar_id USING p_orgn_code ;

         IF g_calendar_id = 0 THEN
            log_message('Warning : '||p_orgn_code||
                    ' does not have manufacturing calendar, continuing ...') ;
         END IF;

    /* Interval Cursor gives the all the point of inflections  */

    stmt_no := 63;
    /*  03/26/02 Rajesh Patangya B2282409, Filter extra resource information */
    -- HW B4309093 Check for calendar id in cr_rsrc_dtl
       sql_stmt1 :=  ' SELECT /*+ ALL_ROWS */ '
                  || '  decode(rt.interval_date,rt.lead_idate,rt.assigned_qty,'
                  || '  (rt.assigned_qty-nvl(rt.rsum,0))) resource_count '
                  || '  ,rt.resource_id '
                  || '  ,rt.instance_id '
                  || '  ,rt.shift_num '
                  || '  ,rt.interval_date '
                  || '  ,rt.lead_idate    '
               -- for OPM-PS
                  || '  ,NVL(gri.eqp_serial_number, to_char(gri.instance_number)) '
                  || '  ,gri.equipment_item_id '
                  || '  ,((rt.resource_id * 2) + 1) '
                  || '  ,((rt.instance_id * 2) + 1) '
                  || ' FROM '
                  || ' ( '
                  || ' SELECT '
                  || '  t.resource_id '
                  || '  ,t.instance_id '
                  || '  ,t.shift_num  '
                  || '  ,t.interval_date '
                  || '  ,t.assigned_qty  '
                  || '  ,nvl(u.resource_units,0) rsum  '
                  || '  ,max(t.lead_idate) lead_idate '
                  || ' FROM ( '
                  || ' SELECT unique resource_id,instance_id,from_date, '
                  || ' to_date to_date1,resource_units '
                  || ' FROM ( '
                  || ' SELECT un.resource_id, '
                  || '        gri.instance_id, '
                  || '        un.from_date,  '
                  || '        un.to_date,    '
                  || '        1 resource_units'
                  || ' FROM   cr_rsrc_dtl '||p_db_link||'  crd, '
                  || '        gmp_rsrc_unavail_dtl_v '||p_db_link||' un, '
                  || '        gmp_resource_instances '||p_db_link||' gri '
                  || ' WHERE  crd.resource_id = un.resource_id  '
                  || ' AND    crd.resource_id = gri.resource_id  '
                  || ' AND    un.instance_id  = gri.instance_id  '
                  || ' AND    crd.orgn_code = :orgn_code1 ' ;

    IF (p_usage = 'BASED') THEN   /* Usage APS */
    sql_stmt1 := sql_stmt1
                  || ' AND    crd.calendar_id = :l_cal_id1 ' ;
    ELSE
    sql_stmt1 := sql_stmt1
                  || ' AND    nvl(crd.calendar_id,:g_default_cal_id1)=:l_cal_id1 ';
    END IF ;

    sql_stmt1 := sql_stmt1
                  || ' AND    crd.schedule_ind = 2 '
                  || ' AND    crd.delete_mark = 0 '
                  || ' AND    nvl(un.instance_id,0) <> 0  ' ;

    IF (v_from_rsrc IS NOT NULL AND v_to_rsrc IS NOT NULL) THEN
    sql_stmt1 := sql_stmt1 || '  AND crd.resources BETWEEN :frsrc1 and :trsrc2 ' ;
    END IF ;

-- HW B4309093 Check for calendar id in cr_rsrc_dtl
    sql_stmt1 := sql_stmt1
                  || ' UNION ALL '
                  || ' SELECT un.resource_id, '
                  || '        gri.instance_id, '
                  || '        un.from_date,  '
                  || '        un.to_date,    '
                  || '        1 resource_units'
                  || ' FROM   cr_rsrc_dtl '||p_db_link||'  crd, '
                  || '        gmp_rsrc_unavail_dtl_v '||p_db_link||' un, '
                  || '        gmp_resource_instances '||p_db_link||' gri '
                  || ' WHERE  crd.resource_id = un.resource_id  '
                  || ' AND    crd.resource_id = gri.resource_id  '
                  || ' AND    crd.orgn_code = :orgn_code2 ' ;

    IF (p_usage = 'BASED') THEN   /* Usage APS */
    sql_stmt1 := sql_stmt1
                  || ' AND    crd.calendar_id = :l_cal_id2 ' ;
    ELSE
    sql_stmt1 := sql_stmt1
                  || ' AND    nvl(crd.calendar_id ,:g_default_cal_id2)= :l_cal_id2 ' ;
    END IF;

    sql_stmt1 := sql_stmt1
                  || ' AND    crd.delete_mark = 0 '
                  || ' AND    crd.schedule_ind = 2 '
                  || ' AND    nvl(un.instance_id,0) = 0  ' ;

    IF (v_from_rsrc IS NOT NULL AND v_to_rsrc IS NOT NULL) THEN
    sql_stmt1 := sql_stmt1 || '  AND crd.resources BETWEEN :frsrc2 and :trsrc2 ' ;
    END IF ;
-- HW B4309093 Check for calendar id in cr_rsrc_dtl
    sql_stmt1 := sql_stmt1
                  || ' AND    gri.instance_number in '
                  || '      ( select tgri.instance_number '
                  || '      FROM gmp_resource_instances '||p_db_link||' tgri '
                  || '      WHERE tgri.resource_id = crd.resource_id '
                  || '      AND rownum <= un.resource_units '
                  || '      ) '
                  || '   ) '
                  || ' ) u, '
                  || ' 	( '
                  || '  SELECT	resource_id,instance_id, shift_num, '
                  || '          interval_date,assigned_qty,lead_idate '
                  || ' 	FROM '
                  || ' 		( '
                  || ' 		SELECT '
                  || ' 			resource_id,instance_id,shift_num, '
                  || '                  interval_date,1 assigned_qty, '
                  || ' 			lead(resource_id,1) over(order by '
    || ' resource_id,instance_id,interval_date,shift_num) as lead_rid, '
                  || ' 			lead(instance_id,1) over(order by '
    || ' resource_id,instance_id,interval_date,shift_num) as lead_iid, '
                  || ' 			lead(interval_date,1) over(order by '
    || ' resource_id,instance_id,interval_date,shift_num) as lead_idate, '
                  || ' 			lead(shift_num,1) over(order by '
    || ' resource_id,instance_id,interval_date,shift_num) as lead_snum '
                  || ' 		FROM '
                  || ' 			( '
                  || ' SELECT unique cmd.resource_id, '
                  || ' cmd.instance_id, '
                  || ' exp.shift_num, '
                  || ' 1 , '
                  || ' cmd.interval_date '
                  || ' FROM ( '
                  || ' SELECT un.resource_id resource_id, '
                  || '        gri.instance_id instance_id,'
                  || '        0 shift_num,'
                  || '        1 resource_count,'
                  || '        un.from_date interval_date '
                  || ' FROM   cr_rsrc_dtl '||p_db_link||'  crd, '
                  || '        gmp_rsrc_unavail_dtl_v '||p_db_link||' un, '
                  || '        gmp_resource_instances '||p_db_link||' gri '
                  || ' WHERE  crd.resource_id = un.resource_id  '
                  || ' AND    crd.resource_id = gri.resource_id  '
                  || ' AND    un.instance_id  = gri.instance_id  '
                  || ' AND    crd.orgn_code = :orgn_code3 ' ;

    IF (p_usage = 'BASED') THEN   /* Usage APS */
    sql_stmt1 := sql_stmt1
                  || ' AND    crd.calendar_id = :l_cal_id3 ' ;
    ELSE
    sql_stmt1 := sql_stmt1
                  || ' AND    nvl(crd.calendar_id ,:g_default_cal_id3)= :l_cal_id3 ' ;
    END IF;

    sql_stmt1 := sql_stmt1
                  || ' AND    crd.schedule_ind = 2 '
                  || ' AND    crd.delete_mark = 0 '
                  || ' AND    nvl(un.instance_id,0) <> 0  ' ;

    IF (v_from_rsrc IS NOT NULL AND v_to_rsrc IS NOT NULL) THEN
    sql_stmt1 := sql_stmt1 || '  AND crd.resources BETWEEN :frsrc3 and :trsrc3 ' ;
    END IF ;

-- HW B4309093 Check for calendar id in cr_rsrc_dtl
    sql_stmt1 := sql_stmt1
                  || ' UNION ALL '
                  || ' SELECT un.resource_id resource_id, '
                  || '        gri.instance_id instance_id,'
                  || '        0 shift_num,'
                  || '        1 resource_count,'
                  || '        un.to_date interval_date '
                  || ' FROM   cr_rsrc_dtl '||p_db_link||'  crd, '
                  || '        gmp_rsrc_unavail_dtl_v '||p_db_link||' un, '
                  || '        gmp_resource_instances '||p_db_link||' gri '
                  || ' WHERE  crd.resource_id = un.resource_id  '
                  || ' AND    crd.resource_id = gri.resource_id  '
                  || ' AND    un.instance_id  = gri.instance_id  '
                  || ' AND    crd.orgn_code = :orgn_code4 ' ;
    IF (p_usage = 'BASED') THEN   /* Usage APS */
    sql_stmt1 := sql_stmt1
                  || ' AND    crd.calendar_id = :l_cal_id4 ' ;
    ELSE
    sql_stmt1 := sql_stmt1
                  || ' AND    nvl(crd.calendar_id ,:g_default_cal_id4)= :l_cal_id4 ' ;
    END IF;

    sql_stmt1 := sql_stmt1
                  || ' AND    crd.schedule_ind = 2 '
                  || ' AND    crd.delete_mark = 0 '
                  || ' AND    nvl(un.instance_id,0) <> 0  ' ;

    IF (v_from_rsrc IS NOT NULL AND v_to_rsrc IS NOT NULL) THEN
    sql_stmt1 := sql_stmt1 || '  AND crd.resources BETWEEN :frsrc4 and :trsrc4 ' ;
    END IF ;

-- HW B4309093 Check for calendar id in cr_rsrc_dtl
    sql_stmt1 := sql_stmt1
                  || ' UNION ALL '
                  || ' SELECT un.resource_id resource_id, '
                  || '        gri.instance_id instance_id,'
                  || '        0 shift_num,'
                  || '        1 resource_count,'
                  || '        un.from_date interval_date '
                  || ' FROM   cr_rsrc_dtl '||p_db_link||'  crd, '
                  || '        gmp_rsrc_unavail_dtl_v '||p_db_link||' un, '
                  || '        gmp_resource_instances '||p_db_link||' gri '
                  || ' WHERE  crd.resource_id = un.resource_id  '
                  || ' AND    crd.resource_id = gri.resource_id  '
                  || ' AND    crd.orgn_code = :orgn_code5 ' ;
    IF (p_usage = 'BASED') THEN   /* Usage APS */
    sql_stmt1 := sql_stmt1
                  || ' AND    crd.calendar_id = :l_cal_id5 ' ;
    ELSE
    sql_stmt1 := sql_stmt1
                  || ' AND    nvl(crd.calendar_id ,:g_default_cal_id5)= :l_cal_id5 ' ;
    END IF;

    sql_stmt1 := sql_stmt1
                  || ' AND    crd.schedule_ind = 2 '
                  || ' AND    crd.delete_mark = 0 '
                  || ' AND    nvl(un.instance_id,0) = 0  ' ;

    IF (v_from_rsrc IS NOT NULL AND v_to_rsrc IS NOT NULL) THEN
    sql_stmt1 := sql_stmt1 || '  AND crd.resources BETWEEN :frsrc5 and :trsrc5 ' ;
    END IF ;

-- HW B4309093 Check for calendar id in cr_rsrc_dtl
    sql_stmt1 := sql_stmt1
                  || ' AND    gri.instance_number in '
                  || '      ( select tgri.instance_number '
                  || '      FROM gmp_resource_instances '||p_db_link||' tgri '
                  || '      WHERE tgri.resource_id = crd.resource_id '
                  || '      AND rownum <= un.resource_units '
                  || '      ) '
                  || ' UNION ALL '
                  || ' SELECT un.resource_id resource_id, '
                  || '        gri.instance_id instance_id,'
                  || '        0 shift_num,'
                  || '        1 resource_count,'
                  || '        un.to_date interval_date '
                  || ' FROM   cr_rsrc_dtl '||p_db_link||'  crd, '
                  || '        gmp_rsrc_unavail_dtl_v '||p_db_link||' un, '
                  || '        gmp_resource_instances '||p_db_link||' gri '
                  || ' WHERE  crd.resource_id = un.resource_id  '
                  || ' AND    crd.resource_id = gri.resource_id  '
                  || ' AND    crd.orgn_code = :orgn_code6 ' ;

    IF (p_usage = 'BASED') THEN   /* Usage APS */
    sql_stmt1 := sql_stmt1
                  || ' AND    crd.calendar_id = :l_cal_id6 ' ;
    ELSE
    sql_stmt1 := sql_stmt1
                  || ' AND    nvl(crd.calendar_id ,:g_default_cal_id6)= :l_cal_id6 ' ;
    END IF;

    sql_stmt1 := sql_stmt1
                  || ' AND    crd.delete_mark = 0 '
                  || ' AND    crd.schedule_ind = 2 '
                  || ' AND    nvl(un.instance_id,0) = 0  ' ;

    IF (v_from_rsrc IS NOT NULL AND v_to_rsrc IS NOT NULL) THEN
    sql_stmt1 := sql_stmt1 || '  AND crd.resources BETWEEN :frsrc6 and :trsrc6 ' ;
    END IF ;

-- HW B4309093 Check for calendar id in cr_rsrc_dtl
    sql_stmt1 := sql_stmt1
                  || ' AND    gri.instance_number in '
                  || '      ( select tgri.instance_number '
                  || '      FROM gmp_resource_instances '||p_db_link||' tgri '
                  || '      WHERE tgri.resource_id = crd.resource_id '
                  || '      AND rownum <= un.resource_units '
                  || '      ) '
                  || '    )   cmd,  '
                  || '        gmp_calendar_detail_gtmp ' ||p_db_link||' exp  '
                  || '      WHERE  exp.calendar_id = :curr_cal1 '
                  || '        AND  cmd.interval_date  BETWEEN '
                  || '             exp.from_date AND exp.to_date '
                  || ' UNION ALL '
                  || ' SELECT crd.resource_id , '
                  || '        gri.instance_id, '
                  || '        exp.shift_num,  '
                  || '        1 , '
                  || '        (exp.shift_date + '
                  || '               (exp.from_time/86400)) interval_date '
                  || ' FROM   cr_rsrc_dtl '||p_db_link||'  crd, '
                  || '        gmp_calendar_detail_gtmp ' ||p_db_link||' exp, '
                  || '        gmp_resource_instances '||p_db_link||' gri '
                  || ' WHERE  crd.orgn_code = :orgn_code7 ' ;

    IF (p_usage = 'BASED') THEN   /* Usage APS */
    sql_stmt1 := sql_stmt1
                  || ' AND    crd.calendar_id = :l_cal_id7 ' ;
    ELSE
    sql_stmt1 := sql_stmt1
                  || ' AND    nvl(crd.calendar_id ,:g_default_cal_id7)= :l_cal_id7 ' ;
    END IF;

    sql_stmt1 := sql_stmt1
                  || ' AND    exp.calendar_id = :curr_cal2 '
                  || ' AND    crd.resource_id = gri.resource_id  '
                  || ' AND    crd.delete_mark = 0 '
                  || ' AND    crd.schedule_ind = 2 ' ;

    IF (v_from_rsrc IS NOT NULL AND v_to_rsrc IS NOT NULL) THEN
    sql_stmt1 := sql_stmt1 || '  AND crd.resources BETWEEN :frsrc7 and :trsrc7 ' ;
    END IF ;

-- HW B4309093 Check for calendar id in cr_rsrc_dtl
    sql_stmt1 := sql_stmt1
                  || ' UNION ALL '
                  || ' SELECT crd.resource_id , '
                  || '        gri.instance_id, '
                  || '        exp.shift_num,  '
                  || '        1 , '
                  || '        (exp.shift_date + '
                  || '               (exp.to_time/86400)) interval_date '
                  || ' FROM   cr_rsrc_dtl '||p_db_link||'  crd, '
                  || '        gmp_calendar_detail_gtmp ' ||p_db_link||' exp, '
                  || '        gmp_resource_instances '||p_db_link||' gri '
                  || ' WHERE  crd.orgn_code = :orgn_code8 ' ;

    IF (p_usage = 'BASED') THEN   /* Usage APS */
    sql_stmt1 := sql_stmt1
                  || ' AND    crd.calendar_id = :l_cal_id8 ' ;
    ELSE
    sql_stmt1 := sql_stmt1
                  || ' AND    nvl(crd.calendar_id ,:g_default_cal_id8)= :l_cal_id8 ' ;
    END IF;

    sql_stmt1 := sql_stmt1
                  || ' AND    exp.calendar_id = :curr_cal3 '
                  || ' AND    crd.resource_id = gri.resource_id  '
                  || ' AND    crd.delete_mark = 0 ' ;

    IF (v_from_rsrc IS NOT NULL AND v_to_rsrc IS NOT NULL) THEN
    sql_stmt1 := sql_stmt1 || '  AND crd.resources BETWEEN :frsrc8 and :trsrc8 ' ;
    END IF ;

    sql_stmt1 := sql_stmt1
                  || ' AND    crd.schedule_ind = 2 '
                  || '                  ) '
                  || '          ) '
                  || '    WHERE resource_id = lead_rid '
                  || '      AND instance_id = lead_iid '
                  || '      AND trunc(interval_date) = trunc(lead_idate) '
                  || '      AND interval_date < lead_idate '
                  || '      AND shift_num = lead_snum  '
                  || '  ) t '
                  || ' WHERE '
                  || '      t.interval_date >= u.from_date(+) '
                  || '  AND t.lead_idate <= u.to_date1 (+) '
                  || '  AND t.resource_id = u.resource_id(+) '
                  || '  AND t.instance_id = u.instance_id(+) '
                  || ' GROUP BY '
                  || '   t.resource_id '
                  || '  ,t.instance_id '
                  || '  ,t.shift_num '
                  || '  ,t.interval_date '
                  || '  ,u.resource_units '
                  || '  ,t.assigned_qty '
                  || ' ) rt, '
                  || '   gmp_resource_instances '||p_db_link||' gri '
                  || ' WHERE '
                  || '  decode(rt.interval_date,rt.lead_idate,rt.assigned_qty,'
                  || '        (rt.assigned_qty - nvl(rt.rsum,0))) > 0 '
                  || '  AND rt.resource_id = gri.resource_id '
                  || '  AND rt.instance_id = gri.instance_id '
                  || ' ORDER BY rt.resource_id ,rt.instance_id, '
                  || '  rt.interval_date,rt.shift_num ' ;

    IF (v_from_rsrc IS NOT NULL AND v_to_rsrc IS NOT NULL) THEN

-- HW B4309093 Pass correct parameters
    OPEN ri_shift_interval FOR sql_stmt1 USING
      p_orgn_code,p_calendar_id, p_calendar_id,V_FROM_RSRC, V_TO_RSRC,
      p_orgn_code, p_calendar_id,p_calendar_id,V_FROM_RSRC, V_TO_RSRC,
      p_orgn_code, p_calendar_id,p_calendar_id,V_FROM_RSRC, V_TO_RSRC,
      p_orgn_code, p_calendar_id,p_calendar_id,V_FROM_RSRC, V_TO_RSRC,
      p_orgn_code, p_calendar_id,p_calendar_id,V_FROM_RSRC, V_TO_RSRC,
      p_orgn_code, p_calendar_id,p_calendar_id,V_FROM_RSRC, V_TO_RSRC,
      p_calendar_id,
      p_orgn_code, p_calendar_id,p_calendar_id,p_calendar_id, V_FROM_RSRC, V_TO_RSRC,
      p_orgn_code, p_calendar_id,p_calendar_id,p_calendar_id, V_FROM_RSRC, V_TO_RSRC ;

    ELSE
-- HW B4309093 Pass correct parameters
      IF (p_usage = 'BASED') THEN   /* Usage APS */
        OPEN ri_shift_interval FOR sql_stmt1 USING
	    p_orgn_code,p_calendar_id,
    	    p_orgn_code,p_calendar_id,
	    p_orgn_code,p_calendar_id,
	    p_orgn_code,p_calendar_id,
	    p_orgn_code,p_calendar_id,
            p_orgn_code,p_calendar_id, p_calendar_id,
            p_orgn_code,p_calendar_id,p_calendar_id,
            p_orgn_code,p_calendar_id, p_calendar_id ;

       ELSE
        OPEN ri_shift_interval FOR sql_stmt1 USING
	    p_orgn_code,g_calendar_id,p_calendar_id,
    	    p_orgn_code,g_calendar_id,p_calendar_id,
	    p_orgn_code,g_calendar_id,p_calendar_id,
	    p_orgn_code,g_calendar_id,p_calendar_id,
	    p_orgn_code,g_calendar_id,p_calendar_id,
            p_orgn_code,g_calendar_id,p_calendar_id, p_calendar_id,
            p_orgn_code,g_calendar_id, p_calendar_id,p_calendar_id,
            p_orgn_code,g_calendar_id,p_calendar_id, p_calendar_id ;


      END IF;
    END IF;

    /* B3347284, Performance Issue */
    stmt_no := 644;
    j := 1 ;
    LOOP
       FETCH ri_shift_interval INTO resource_count(j), resource_id(j),
             instance_id(j), shift_num(j), f_date(j), t_date(j), msc_serial_number(j),
             equipment_item_id(j), x_resource_id(j), x_instance_id(j);

       EXIT WHEN ri_shift_interval%NOTFOUND;

    stmt_no := 665;
    i := 1 ;
    x_dept_id := ((p_org_id * 2) + 1) ;
    IF (resource_id.FIRST > 0) AND (j = 75000) THEN  /* Only if any resource */

       IF ((p_usage = 'APS') OR (p_usage = 'BASED')) THEN /* Usage APS/BASED */

        FORALL i IN resource_id.FIRST..resource_id.LAST

        INSERT INTO msc_st_net_res_inst_avail
          ( Organization_Id,
            Department_id,
            sr_instance_id ,
            Resource_Id,
            res_instance_id,
            serial_number,
            equipment_item_id,
            Shift_Num,
            Shift_Date,
            From_Time,
            To_Time
         )  VALUES
         (
            p_org_id,
            x_dept_id,
            p_instance_id ,
            x_resource_id(i),
            x_instance_id(i),
            msc_serial_number(i),
            equipment_item_id(i),
            shift_num(i),
            trunc(f_date(i)),
            ((f_date(i) - trunc(f_date(i))) * 86400 ),
            ((t_date(i) - trunc(t_date(i))) * 86400 )
          )                     ;

       ELSIF (p_usage = 'WPS') THEN   /* Usage WPS     */

        FORALL i IN resource_id.FIRST..resource_id.LAST
        INSERT INTO gmp_resource_avail
         (
          instance_id, plant_code, resource_id,
          calendar_id, resource_instance_id, shift_num,
          shift_date, from_time, to_time,
          resource_units, creation_date, created_by,
          last_update_date, last_updated_by, last_update_login
         )  VALUES
         (
            p_instance_id,
            p_orgn_code,
            resource_id(i),
            p_calendar_id,
            instance_id(i),
            shift_num(i),
            trunc(f_date(i)),
            ((f_date(i) - trunc(f_date(i))) * 86400 ),
            ((t_date(i) - trunc(t_date(i))) * 86400 ),
            resource_count(i),
            sysdate,
            FND_GLOBAL.USER_ID,
            sysdate,
            FND_GLOBAL.USER_ID,
            FND_GLOBAL.USER_ID
          )                     ;

       END IF;   /* APS or WPS */

         resource_count     := empty_num_table;
         resource_id        := empty_num_table;
         x_resource_id      := empty_num_table;
         instance_id        := empty_num_table;
         x_instance_id      := empty_num_table;
         shift_num          := empty_num_table;
         msc_serial_number  := emp_serial_number;
         equipment_item_id  := empty_num_table;
         f_date             := empty_dat_table;
         t_date             := empty_dat_table;
         j := 0 ;
         /* 8i Database does not support BULK COLLECT - B3881832 */
         dbms_session.free_unused_user_memory;

   END IF;   /* Only if any resource */

   j := j + 1 ;
   END LOOP ;
   CLOSE ri_shift_interval;

    stmt_no := 666;
    i := 1 ;
    x_dept_id := ((p_org_id * 2) + 1) ;
    IF (resource_id.FIRST > 0) THEN  /* Only if any resource */

       IF ((p_usage = 'APS') OR (p_usage = 'BASED')) THEN /* Usage APS/BASED */

        FORALL i IN resource_id.FIRST..resource_id.LAST
        INSERT INTO msc_st_net_res_inst_avail
          ( Organization_Id,
            Department_id,
            sr_instance_id ,
            Resource_Id,
            res_instance_id,
            serial_number,
            equipment_item_id,
            Shift_Num,
            Shift_Date,
            From_Time,
            To_Time
         )  VALUES
         (
            p_org_id,
            x_dept_id,
            p_instance_id ,
            x_resource_id(i),
            x_instance_id(i),
            msc_serial_number(i),
            equipment_item_id(i),
            shift_num(i),
            trunc(f_date(i)),
            ((f_date(i) - trunc(f_date(i))) * 86400 ),
            ((t_date(i) - trunc(t_date(i))) * 86400 )
          )                     ;

       ELSIF (p_usage = 'WPS') THEN   /* Usage WPS     */

        FORALL i IN resource_id.FIRST..resource_id.LAST
        INSERT INTO gmp_resource_avail
         (
          instance_id, plant_code, resource_id,
          calendar_id, resource_instance_id, shift_num,
          shift_date, from_time, to_time,
          resource_units, creation_date, created_by,
          last_update_date, last_updated_by, last_update_login
         )  VALUES
         (
            p_instance_id,
            p_orgn_code,
            resource_id(i),
            p_calendar_id,
            instance_id(i),
            shift_num(i),
            trunc(f_date(i)),
            ((f_date(i) - trunc(f_date(i))) * 86400 ),
            ((t_date(i) - trunc(t_date(i))) * 86400 ),
            resource_count(i),
            sysdate,
            FND_GLOBAL.USER_ID,
            sysdate,
            FND_GLOBAL.USER_ID,
            FND_GLOBAL.USER_ID
          )                     ;

       END IF;   /* APS or WPS */

         resource_count     := empty_num_table;
         resource_id        := empty_num_table;
         x_resource_id      := empty_num_table;
         instance_id        := empty_num_table;
         x_instance_id      := empty_num_table;
         shift_num          := empty_num_table;
         msc_serial_number  := emp_serial_number;
         equipment_item_id  := empty_num_table;
         f_date             := empty_dat_table;
         t_date             := empty_dat_table;
         /* 8i Database does not support BULK COLLECT - B3881832 */
         dbms_session.free_unused_user_memory;
         COMMIT ;

   END IF;   /* Only if any resource */

   /* This logic introduced for Net resource availablility to
       write consolidated rows once final available rows are in place */
   stmt_no := 666;
   sql_stmt2 := NULL;

   sql_stmt2 :=  ' SELECT  /*+ ALL_ROWS */ '
   || '        net.resource_id , '
   || '        net.resource_instance_id, '
   || '        net.shift_date  , '
   || '        net.shift_num   , '
   || '        net.resource_units , '
   || '        min(net.from_time) from_time, '
   || '        max(net.lead_tt) to_time '
   || ' FROM  ( '
   || '        SELECT resource_id , '
   || '               resource_instance_id, '
   || '               shift_date  , '
   || '               shift_num , '
   || '               from_time , '
   || '               to_time , '
   || '               resource_units , '
   || '  lead(resource_id,1) over(order by resource_id,resource_instance_id, '
   || '  shift_date, shift_num,from_time,to_time,resource_units) as lead_rid, '
   || '  lead(resource_instance_id,1) over(order by resource_id, '
   || '  resource_instance_id, '
   || '  shift_date, shift_num,from_time,to_time,resource_units) as lead_iid, '
   || '  lead(shift_date,1) over(order by resource_id,resource_instance_id, '
   || '  shift_date, shift_num,from_time,to_time,resource_units) as lead_sdt, '
   || '  lead(shift_num,1) over(order by resource_id,resource_instance_id, '
   || '  shift_date, shift_num,from_time,to_time,resource_units) as lead_sn, '
   || '  lead(from_time,1) over(order by resource_id,resource_instance_id, '
   || '  shift_date, shift_num,from_time,to_time,resource_units) as lead_ft, '
   || '  lead(to_time,1) over(order by resource_id,resource_instance_id, '
   || '  shift_date, shift_num,from_time,to_time,resource_units) as lead_tt, '
   || '  lead(resource_units,1) over(order by resource_id, '
   || '  resource_instance_id, '
   || '  shift_date, shift_num,from_time,to_time,resource_units) as lead_rc '
   || '          FROM gmp_resource_avail'
   || '          WHERE plant_code = :orgn_code1 '
   || '            AND calendar_id = :cal_id ' ;

   IF (v_from_rsrc IS NOT NULL AND v_to_rsrc IS NOT NULL) THEN

   sql_stmt2 := sql_stmt2 ||' AND resource_id in (select resource_id '
                          ||' from cr_rsrc_dtl '||p_db_link
                          ||' WHERE orgn_code = :orgn_code2 '
                          ||' AND resources BETWEEN :frsrc and :trsrc )' ;
   END IF ;

   sql_stmt2 := sql_stmt2 || '              ) net '
   || '      WHERE net.resource_id          = net.lead_rid '
   || '        AND net.resource_instance_id = net.lead_iid '
   || '        AND net.shift_num      = net.lead_sn '
   || '        AND net.shift_date     = net.lead_sdt '
   || '        AND net.to_time        = net.lead_ft '
   || '        AND net.resource_units = net.lead_rc '
   || ' GROUP BY '
   || '        net.resource_id , '
   || '        net.resource_instance_id , '
   || '        net.shift_date , '
   || '        net.shift_num , '
   || '        net.resource_units ' ;

    stmt_no := 66;

    IF (v_from_rsrc IS NOT NULL AND v_to_rsrc IS NOT NULL) THEN
     OPEN ri_assembly FOR sql_stmt2 USING p_orgn_code, p_calendar_id,
          p_orgn_code, v_from_rsrc, v_to_rsrc ;
    ELSE
     OPEN ri_assembly FOR sql_stmt2 USING p_orgn_code, p_calendar_id ;
    END IF;

    LOOP
       FETCH ri_assembly INTO  interval_record;
       EXIT WHEN ri_assembly%NOTFOUND;

     sqlstmt := 'DELETE FROM gmp_resource_avail'
             || ' WHERE plant_code  = :Plant_code1 '
             || '   AND calendar_id = :cal_id '
             || '   AND resource_id = :prid '
             || '   AND resource_instance_id = :piid '
             || '   AND shift_date = :psdt '
             || '   AND shift_num  = :psn  '
             || '   AND from_time  >= :pft '
             || '   AND to_time  <= :ptt '
             || '   AND resource_units = :prc ' ;

   stmt_no := 67;
       EXECUTE immediate sqlstmt USING
       p_orgn_code , p_calendar_id ,
       interval_record.resource_id,
       interval_record.resource_instance_id,
       trunc(interval_record.shift_date),
       interval_record.shift_num,
       interval_record.from_time, interval_record.to_time,
       interval_record.resource_units  ;

   stmt_no := 68;
         net_rsrc_avail_insert(
            p_instance_id,
            p_orgn_code,
            interval_record.resource_instance_id,
            p_calendar_id,
            interval_record.resource_id,
            interval_record.resource_units,
            interval_record.shift_num,
            interval_record.shift_date,
            interval_record.from_time,
            interval_record.to_time
                  );

       COMMIT ;
    END LOOP;
    CLOSE ri_assembly;

   stmt_no := 69;
     sqlupt := 'UPDATE gmp_resource_avail'
            ||' SET to_time   = 86400 '
            ||' WHERE to_time = 86399 '
            ||'   AND shift_num >= 99999 ' ;

       EXECUTE immediate sqlupt ;
     sqlupt := null ;
     sqlupt := 'UPDATE gmp_resource_avail'
            ||' SET shift_num = (shift_num - 99999) '
            ||' WHERE shift_num >= 99999 ' ;

       EXECUTE immediate sqlupt ;
       COMMIT ;

    return_status := TRUE ;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
   log_message('NO DATA FOUND exception: MSC_CL_GMP_UTILITY.net_rsrc_avail_calculate');
   return_status := TRUE;
  WHEN  OTHERS THEN
   log_message('Error in Net Resource Instance Insert: '||stmt_no);
   log_message(sqlerrm);
   return_status := FALSE ;

end net_rsrc_avail_calculate;

/*
REM+==========================================================================+
REM| PROCEDURE NAME                                                           |
REM|    net_rsrc_avail_insert                                                 |
REM|                                                                          |
REM| Type                                                                     |
REM|    public                                                                |
REM|                                                                          |
REM| DESCRIPTION                                                              |
REM|    The following procedure inserts rows into gmp_resource_avail          |
REM|                                                                          |
REM| Input Parameters                                                         |
REM|    p_instance_id - Instance Id                                           |
REM|    p_orgn_code - Plant Code                                              |
REM|    p_resource_instance_id - Resource Instance Id                         |
REM|    p_Calendar_id - Calendar id                                           |
REM|    p_resource_id - Resource Id                                           |
REM|    p_assigned_qty -  Resource units                                      |
REM|    p_shift_num - Shift number                                            |
REM|    p_calendar_date - Calendar date                                       |
REM|    p_from_time - shift starting time                                     |
REM|    p_to_time - Shift Ending time                                         |
REM|                                                                          |
REM| Output Parameters                                                        |
REM|    None                                                                  |
REM|                                                                          |
REM| HISTORY                                                                  |
REM|    Created on 4th Jan 2002 By Rajesh Patangya                            |
REM|                                                                          |
REM+==========================================================================+
*/

PROCEDURE net_rsrc_avail_insert(p_instance_id          IN NUMBER,
                                p_orgn_code            IN VARCHAR2,
                                p_resource_instance_id IN NUMBER,
                                p_calendar_id          IN NUMBER,
                                p_resource_id          IN NUMBER,
                                p_assigned_qty         IN NUMBER,
                                p_shift_num            IN NUMBER,
                                p_calendar_date        IN DATE,
                                p_from_time            IN NUMBER,
                                p_to_time              IN NUMBER ) IS

BEGIN
   IF nvl(p_from_time,0) = 0  AND nvl(p_to_time,0) = 0 THEN
     NULL ;
   ELSE
     INSERT INTO gmp_resource_avail (
     instance_id, plant_code, resource_id,
     calendar_id, resource_instance_id, shift_num,
     shift_date, from_time, to_time,
     resource_units, creation_date, created_by,
     last_update_date, last_updated_by, last_update_login )
     VALUES (
             p_instance_id,
             p_orgn_code,
             p_resource_id,
             p_calendar_id,
             p_resource_instance_id,
             p_shift_num,
             p_calendar_date,
             p_from_time,
             p_to_time,
             p_assigned_qty,
             sysdate,
             FND_GLOBAL.USER_ID,
             sysdate,
             FND_GLOBAL.USER_ID,
             FND_GLOBAL.USER_ID ) ;
    END IF;
EXCEPTION
  WHEN  OTHERS THEN
     log_message('Error in Net Resource Avail Insert ' || sqlerrm);

END net_rsrc_avail_insert;

/*
REM+=========================================================================+
REM| FUNCTION NAME                                                           |
REM|    ORG_STRING                                                           |
REM| DESCRIPTION                                                             |
REM|    To find out the organization string                                  |
REM| HISTORY                                                                 |
REM| 12/21/2005   Rajesh Patangya                                            |
REM+=========================================================================+
*/
FUNCTION ORG_STRING(instance_id IN NUMBER) return BOOLEAN IS

 sql_stmt         varchar2(32000);
 c_str            ref_cursor_typ ;
 l_aps_compatible number ;
 org_str          varchar2(32767) ;
 in_position      number ;

BEGIN
 sql_stmt           := NULL ;
 l_aps_compatible   := 0 ;
 org_str            := NULL ;
 in_position        := -10 ;

    SELECT MSC_CL_GMP_UTILITY.is_aps_compatible
    INTO l_aps_compatible  FROM DUAL ;

    IF l_aps_compatible = 1 THEN

       /*sql_stmt := 'SELECT MSC_CL_PULL.get_org_str(' || instance_id || ') FROM dual ' ;
       OPEN c_str FOR sql_stmt ;
       FETCH c_str INTO org_str ;
       log_message(' String From APS : ' || org_str);
       CLOSE c_str ;*/

       org_str := MSC_CL_PULL.get_org_str(instance_id); /* Bug # 5086464 Commented the code above and added this line */

--  org_str := 'IN (1381,1382)' ;
         in_position := instr(org_str,'IN');

         /* B3450303, For all org or specific org, APS will provide valid org string
            We have to find the IN part in the string, otherwise have to raise
            Exception message for error condition */

         IF in_position > 0 THEN
         	MSC_CL_GMP_UTILITY.g_in_str_org  := org_str ;
        	return TRUE  ;
         ELSE
         	MSC_CL_GMP_UTILITY.g_in_str_org := NULL ;
        	return FALSE ;
         END IF;


    ELSE
     /* For older patchset This value should be TRUE */
        MSC_CL_GMP_UTILITY.g_in_str_org := NULL ;
        return TRUE  ;
    END IF;

   EXCEPTION
     WHEN OTHERS THEN
       log_message('Error in org_string ' || sqlerrm);
       MSC_CL_GMP_UTILITY.g_in_str_org := NULL ;
       return FALSE ;
END ORG_STRING;

FUNCTION GMP_CAL_UTILITY1_R10
            (
                          p_dblink      IN VARCHAR2,
                          p_delimiter   IN VARCHAR2,
                          p_instance    IN INTEGER,
                          p_run_date    IN DATE,
                          p_num1        IN NUMBER,
                          p_num2        IN NUMBER,
                          p_num3        IN NUMBER,
                          p_num4        IN NUMBER,
                          p_varchar1    IN VARCHAR2,
                          p_varchar2    IN VARCHAR2,
                          p_varchar3    IN VARCHAR2,
                          p_varchar4    IN VARCHAR2
            ) RETURN INTEGER IS
BEGIN
    return 0;
END GMP_CAL_UTILITY1_R10;

PROCEDURE GMP_CAL_PROC1_R10
            (
                          p_dblink      IN VARCHAR2,
                          p_delimiter   IN VARCHAR2,
                          p_instance    IN INTEGER,
                          p_run_date    IN DATE,
                          p_num1        IN NUMBER,
                          p_num2        IN NUMBER,
                          p_num3        IN NUMBER,
                          p_num4        IN NUMBER,
                          p_varchar1    IN VARCHAR2,
                          p_varchar2    IN VARCHAR2,
                          p_varchar3    IN VARCHAR2,
                          p_varchar4    IN VARCHAR2,
                          return_status  OUT NOCOPY BOOLEAN
            ) IS
BEGIN
    return_status := TRUE;
END GMP_CAL_PROC1_R10;

-- --------------------OPM Calendar Package End --------------


 FUNCTION is_aps_compatible RETURN NUMBER IS
 BEGIN
  RETURN 1 ;
 END is_aps_compatible ;

 END MSC_CL_GMP_UTILITY;

/
