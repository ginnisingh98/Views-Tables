--------------------------------------------------------
--  DDL for Package Body GMP_BOM_ROUTING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMP_BOM_ROUTING_PKG" AS
/* $Header: GMPBMRTB.pls 120.32.12010000.19 2009/09/30 07:36:04 vpedarla ship $ */

/*
REM+==========================================================================+
REM+                                                                          +
REM+                              ROADMAP                                     +
REM+ In R12.0 No OPM warehouse exists as part of convergence and hence        +
REM+ msc_st_sub_inventories will be populated by MSCCLAAB.pls package         +
REM+                                                                          +
REM+ The transfer of formula and routing data from OPM to APS is achieved in  +
REM+ two phases, by calling the 'extract_effectivities' procedure. The first  +
REM+ phase is to create and populate a set of PL/SQL tables and collections   +
REM+ with data from the OPM formulation tables. The second phase takes these  +
REM+ data and populates the APS tables. These two phases are carried out by   +
REM+ the 'retrieve effectivities' and 'export_effectivities' procedures. As   +
REM+ can be inferred from the procedures' names, the starting point is the    +
REM+ OPM effectivties.                                                        +
REM+                                                                          +
REM+ Because a formula (and for that matter a routing) can be used many times +
REM+ in several effectivities, the retrieval phase attempts to minimise the   +
REM+ memory requirements by only storing a formula (or routing) in the PL/SQL +
REM+ structures once, and setting up links to them. At the end of the first   +
REM+ phase the following structures will be in place:                         +
REM+                                                                          +
REM+ APS_EFFECTIVITIES: Containing organisational and warehouse data and a    +
REM+                    link to to the OPM effectivity. (Each OPM effectivity +
REM+                    can be exploded into several APS effectivties if the  +
REM+                    organisation or routing (or both) is/are null         +
REM+                                                                          +
REM+ OPM_EFFECTIVITIES: Containing effectivity data (dates, preferences etc)  +
REM+                    with links to: formula_headers, routing_headers (if a +
REM+                    routing was specified in this effectivity), formula/  +
REM+                    routing/materials (ditto). Also contains the index of +
REM+                    the effective item in the formula_details structure.  +
REM+                                                                          +
REM+ FORMULA_HEADERS:   Contains formula_no/version/description and links to  +
REM+                    the formula's details in the formula_details structure+
REM+                                                                          +
REM+ ROUTING_HEADERS:   Contains routing_no/version/description and links to  +
REM+                    the routing's details in the routing_details structure+
REM+                                                                          +
REM+                                                                          +
REM+ FORMULA_DETAILS:   Contains the formula's details.                       +
REM+                                                                          +
REM+ ROUTING_DETAILS:   Contains the routing's details.                       +
REM+                                                                          +
REM+ MATERIAL_ASSOCS:   Contains the routing/material associations.           +
REM+                                                                          +
REM+ Several other auxiliary structures are used as stepping stones to build  +
REM+ and populate the above structures, the names of each should assist in    +
REM+ determining their use. All structures are instantiated when the extract- +
REM+ ion process starts, and destroyed at completion.                         +
REM+                                                                          +
REM+ If the retrieval phase was successful, the export phase starts. This     +
REM+ works by traversing the above structures in a manner similar to the way  +
REM+ the retrieval phase gathered the data from the database: it starts with  +
REM+ the APS effectivities and follows the pointers to the other structures   +
REM+ to locate the data to be passed to APS. Several tables are written to.   +
REM+                                                                          +
REM+ Broadly, formulation data is written to the _BOM and _BOM_COMPONENTS     +
REM+ tables and APS effectivity data is writen to the _PROCESS_EFFECTIVITY    +
REM+ and GMP_FORM_EFF tables. The writing of routing data is somewhat more    +
REM+ complex. Basic routing header and detail data is written to the _ROUTINGS+
REM+ AND The _ROUTING_OPERATIONS tables. Each detail row (ie each step) then  +
REM+ has its detail (ie the individual activities) written to the _OPERATION_ +
REM+ RESOURCE_SEQS table. Each activity is given a sequence number within the +
REM+ step in which it occurs. Each activity's detail (ie each resource used   +
REM+ in the activity in the step (are you still with me?) is then written to  +
REM+ the _OPERATION_RESOURCES table. The final complication is that alternate +
REM+ resources are also written to the _OPERATION_RESOURCES table, one for    +
REM+ each alternative. Each row written has the original resource and a diff- +
REM+ erent alternative. If there are no alternatives, only one row is written +
REM+ and the alternative is not specified. Got all that?                      +
REM+                                                                          +
REM+ For further processing details, see the individual procedure headers.    +
REM+                                                                          +
REM+ All externally callable routines share the same interface:               +
REM+                                                                          +
REM+ LINK_NAME       IN    VARCHAR2                                           +
REM+ RETURN_STATUS   OUT   BOOLEAN                                            +
REM+                                                                          +
REM+ Each procedure returns a status of TRUE if everything worked OK or FALSE +
REM+ if there was a problem.                                                  +
REM+                                                                          +
REM+                                                                          +
REM+ P.J.Schofield OPM Development, 13th August 1999.                         +
REM+                                                                          +
REM+==========================================================================+

REM+==========================================================================+
REM| PACKAGE DATA BLOCK                                                       |
REM|                                                                          |
REM| Originally these were all defined with the %TYPE of the database column  |
REM| they represented, but as the APS server will not contain any OPM tables  |
REM| these have, sadly, to be replaced with scalar datatypes.                 |
REM+==========================================================================+

REM Create composite types
REM ======================

REM This type is used to create a holding area for data retreived by one of the
REM four cursors in the retrieve_effectivities procedure. Most of the values
REM are filled in by the cursors. The remainder are filled in by the procedures
REM which retrieve and validate formulae and routings.
*/

  TYPE ref_cursor_typ IS REF CURSOR;
  null_value                 VARCHAR2(2)     := NULL;
  routing_dtl_cursor         VARCHAR2(32767) := NULL;
  validation_statement       VARCHAR2(32767) := NULL;
  invalid_string_value       EXCEPTION;
  invalid_gmp_uom_profile    EXCEPTION;
  source_call_failure        EXCEPTION; /*  B8230710 */

TYPE gmp_buffer_typ IS RECORD
(
  fmeff_id            PLS_INTEGER,  /* OPM Effectivity ID         */
  aps_fmeff_id        PLS_INTEGER,  /* APS Effectivity ID - B2989806  */
  inventory_item_id   PLS_INTEGER,      /* OPM Effectivity Item ID    */
  formula_id          PLS_INTEGER,  /* Formula ID                 */
  organization_id     PLS_INTEGER,  /* ID for the Plant           */
  start_date          DATE,        /* Effectivity Start Date     */
  end_date            DATE,        /* Effectivity End Date       */
  inv_min_qty         NUMBER,      /* Effectivity Minimum Qty    */
  inv_max_qty         NUMBER,      /* Effectivity Maximum Qty    */
  preference          PLS_INTEGER,      /* Effectivity Preference     B3437281 */
  primary_uom_code    VARCHAR2(3), /* Primary UOM of the Item    */
  organization_code   VARCHAR2(3), /* Resource or Material Whse  */
  routing_id          PLS_INTEGER,  /* Routing ID. Could be NULL  */
  routing_no          VARCHAR2(32),/* Associated Routing No      */
  routing_vers        PLS_INTEGER,   /* Associated Routing Version */
  routing_desc        VARCHAR2(70),/* Associated Routing DEsc'n  */
  routing_uom         VARCHAR2(3), /* UOM from the Routing       */ -- akaruppa previously routing_um
  routing_qty         NUMBER,      /* Qty from the Routing       */
  prod_factor         NUMBER, /*B2870041 factor to convert prod to rout um */
  product_index       PLS_INTEGER, /*B2870041 index of the product line */
  recipe_id           PLS_INTEGER,  /* 1830940 New GMD Changes Recipe ID */
  recipe_no           VARCHAR2(32), /* B5584507 */
  recipe_version      PLS_INTEGER,    /* B5584507 */
  rtg_hdr_location    PLS_INTEGER,   /* index link to routing header */
  calculate_step_quantity NUMBER,
  category_id         PLS_INTEGER,
  setup_id            PLS_INTEGER,
  seq_dpnd_class      VARCHAR2(100)
);
effectivity           gmp_buffer_typ;

TYPE gmp_formula_header_typ IS RECORD
(
  formula_id          PLS_INTEGER,
  valid_flag          PLS_INTEGER,
  start_dtl_loc       PLS_INTEGER,
  end_dtl_loc         PLS_INTEGER,
  total_output        NUMBER, /* B2870041 total output for all prod/byp */
  total_uom           VARCHAR2(3) /*B2870041 um used to calculate qty */ -- akaruppa changed total_um to total_uom
);
TYPE gmp_formula_header_tbl IS TABLE OF gmp_formula_header_typ
INDEX BY BINARY_INTEGER;
formula_header_tab        gmp_formula_header_tbl;

TYPE gmp_formula_detail_typ IS RECORD
(
  formula_id          PLS_INTEGER,
  formula_no          VARCHAR2(32),
  formula_vers        PLS_INTEGER,
  formula_desc1       VARCHAR2(70),
  x_formulaline_id    PLS_INTEGER,
  line_type           PLS_INTEGER,
  inventory_item_id   PLS_INTEGER,
  formula_qty         NUMBER,
  scrap_factor        NUMBER,
  scale_type          PLS_INTEGER,
  contribute_yield_ind VARCHAR2(1),      /* B2657068 Rajesh Patangya */
  contribute_step_qty_ind PLS_INTEGER,      /* NAMIT_ASQC */
  phantom_type        PLS_INTEGER,
  primary_uom_code    VARCHAR2(3), -- akaruppa previously aps_um
  detail_uom          VARCHAR2(3), /*B2870041 formula um */ -- akaruppa previously orig_um
  bom_scale_type      PLS_INTEGER,
  primary_qty         NUMBER,
  scale_multiple      NUMBER,        /* B2657068 Rajesh Patangya */
  scale_rounding_variance PLS_INTEGER,    /* B2657068 Rajesh Patangya */
  rounding_direction  PLS_INTEGER,          /* B2657068 Rajesh Patangya */
  release_type        PLS_INTEGER,
  /*B5176291 - Item substitution changes - start*/
--  formula_line_id     NUMBER,
  original_item_flag  PLS_INTEGER,
  start_date          DATE,
  end_date            DATE,
  formula_line_id     PLS_INTEGER,
  preference          PLS_INTEGER
  /* Bug: 6087535 Vpedarla 23-07-07 FP :11.5.10 - 12.0.3 : ITEM SUBSTITUTION EFFECTIVITY IS NOT COLLECTED. */
--  lead_stdate         DATE,
--  lead_enddate        DATE,
--  lead_pref           NUMBER,
--  replace_uom         VARCHAR2(3),
--  actual_end_date     DATE,
--  actual_end_flag     NUMBER,
  /*B5176291 - Item substitution changes - end*/
--  release_type        NUMBER
);
TYPE gmp_formula_detail_tbl IS TABLE OF gmp_formula_detail_typ
INDEX BY BINARY_INTEGER;
formula_detail_tab   gmp_formula_detail_tbl ;

TYPE gmp_formula_detail_count_typ IS RECORD
(
  formula_id          PLS_INTEGER,
  formula_dtl_count   PLS_INTEGER
);
TYPE gmp_formula_detail_count_tbl IS TABLE OF gmp_formula_detail_count_typ
INDEX BY BINARY_INTEGER;
formula_dtl_count_rec     gmp_formula_detail_count_typ ;

TYPE gmp_formula_orgn_count_typ IS RECORD
(
  formula_id          PLS_INTEGER,
  organization_id     PLS_INTEGER,
  orgn_count          PLS_INTEGER,  /* Count of formula details */
  valid_flag          PLS_INTEGER
);
TYPE gmp_formula_orgn_count_tbl IS TABLE OF gmp_formula_orgn_count_typ
INDEX BY BINARY_INTEGER;
formula_orgn_count_tab  gmp_formula_orgn_count_tbl;

/*B5176291 - Item substitution changes - start*/
/* Bug: 6087535 Vpedarla 23-07-07 FP :11.5.10 - 12.0.3 : ITEM SUBSTITUTION EFFECTIVITY IS NOT COLLECTED. */
prev_detail_tab                    gmp_formula_detail_tbl ;
orig_detail_tab                     gmp_formula_detail_tbl ;
temp_detail_tab                    gmp_formula_detail_tbl ;
subst_tab                          gmp_formula_detail_tbl ;
/*B5176291 - Item substitution changes - end*/

TYPE gmp_routing_header_typ IS RECORD
(
  routing_id          PLS_INTEGER,
  organization_id     PLS_INTEGER,
  valid_flag          PLS_INTEGER,
  generic_start_loc   PLS_INTEGER,
  generic_end_loc     PLS_INTEGER,
  orgn_start_loc      PLS_INTEGER,
  orgn_end_loc        PLS_INTEGER,
  step_start_loc      PLS_INTEGER,
  step_end_loc        PLS_INTEGER,
  usage_start_loc     PLS_INTEGER,
  usage_end_loc       PLS_INTEGER,
  stpdep_start_loc    PLS_INTEGER,
  stpdep_end_loc      PLS_INTEGER
);
TYPE gmp_routing_header_tbl IS TABLE OF gmp_routing_header_typ
INDEX BY BINARY_INTEGER;
rtg_org_hdr_tab      gmp_routing_header_tbl;

TYPE gmp_routing_detail_typ IS RECORD
(
  routing_id          PLS_INTEGER,
  organization_id     PLS_INTEGER,
/* NAMIT_RD */
  routingstep_no      PLS_INTEGER,
  seq_dep_ind         PLS_INTEGER, /*B2870041 sequence dependent indicator */
  prim_rsrc_ind_order PLS_INTEGER,
  resources           VARCHAR2(16),
/* NAMIT_OC */
  prim_rsrc_ind       PLS_INTEGER,
  capacity_constraint PLS_INTEGER,
  min_capacity        NUMBER,
  max_capacity        NUMBER,
  schedule_ind        PLS_INTEGER,
  routingstep_id      PLS_INTEGER,
  x_routingstep_id    PLS_INTEGER,
  step_qty            NUMBER,
  minimum_transfer_qty NUMBER,
  oprn_desc           VARCHAR2(70),
  oprn_id             PLS_INTEGER,   /* SGIDUGU - Seq Dep changes */
  oprn_no             VARCHAR2(32),
  process_qty_uom     VARCHAR2(3), -- akaruppa previously process_qty_um
  activity            VARCHAR2(16),
  oprn_line_id        PLS_INTEGER,
  resource_count      PLS_INTEGER,
  resource_usage      NUMBER,
  resource_usage_uom  VARCHAR2(3), -- akaruppa previously usage_um
  scale_type          PLS_INTEGER,
  offset_interval     NUMBER,
  resource_id         PLS_INTEGER,
  x_resource_id       PLS_INTEGER,   /* B1177070 added encoded key */
  rtg_scale_type      PLS_INTEGER,
  activity_factor     NUMBER,       /* GMD New Additional Columns */
  process_qty         NUMBER,       /* GMD New Additional Columns */
  material_ind        PLS_INTEGER, /*B2870041 material indicator for next/prior*/
  schedule_flag       PLS_INTEGER,  /*B2870041 default value for APS*/
  mat_found           PLS_INTEGER,   /* Indicator is any activity is scheduled in operation. */
  include_rtg_row     PLS_INTEGER,    /* Do Not Plan Resource rows will have value 0 */
  break_ind           PLS_INTEGER,   /* Flag denoting whether activity is breakable or not. */
  o_min_capacity      NUMBER,  /* Overrides */
  o_max_capacity      NUMBER,  /* Overrides */
  o_resource_usage    NUMBER,  /* Overrides */
  o_activity_factor   NUMBER,  /* Overrides */
  o_process_qty       NUMBER,   /* Overrides */
  o_step_qty          NUMBER,   /* Overrides */
/* Rajesh Added */
  is_sds_rout         PLS_INTEGER,   /* B4918786 SDS */
  is_unique           PLS_INTEGER,   /* B4918786 SDS */
  is_nonunique        PLS_INTEGER,   /* B4918786 SDS */
  setup_id            PLS_INTEGER    /* B4918786 SDS */
);
TYPE gmp_routing_detail_tbl IS TABLE OF gmp_routing_detail_typ
INDEX BY BINARY_INTEGER;
rtg_org_dtl_tab    gmp_routing_detail_tbl;

/* B4918786 SDS */
TYPE gmp_sds_typ IS RECORD
(
  oprn_id             PLS_INTEGER,
  category_id         PLS_INTEGER,
  seq_dpnd_class      VARCHAR2(100),
  resources           VARCHAR2(16),
  resource_id         PLS_INTEGER,
  setup_id            PLS_INTEGER
);
TYPE gmp_sds_tbl IS TABLE OF gmp_sds_typ INDEX BY BINARY_INTEGER;
sds_tab    gmp_sds_tbl;
sds_tab_init gmp_sds_tbl;

TYPE gen_routing_detail_typ IS RECORD
(
  routing_id          PLS_INTEGER,
  routingstep_no      PLS_INTEGER,
/* NAMIT_RD */
  seq_dep_ind         PLS_INTEGER, /*B2870041 sequence dependent indicator */
  prim_rsrc_ind_order PLS_INTEGER,
  resources           VARCHAR2(16),
  routingstep_id      PLS_INTEGER,
  oprn_no             VARCHAR2(32),
  oprn_line_id        PLS_INTEGER,
  activity            VARCHAR2(16),
  prim_rsrc_ind       PLS_INTEGER,
  offset_interval     NUMBER,
  uom_code            VARCHAR2(3), /* NAMIT_RD */
  capacity_constraint NUMBER -- akaruppa added to check if resource is chargeable
);
TYPE gen_routing_detail_tbl IS TABLE OF gen_routing_detail_typ
INDEX BY BINARY_INTEGER;
rtg_gen_dtl_tab       gen_routing_detail_tbl;

TYPE gmp_alt_resource_typ IS RECORD
(
  prim_resource_id    PLS_INTEGER,
  alt_resource_id     PLS_INTEGER,
  min_capacity        NUMBER,  /* SGIDUGU - min capacity for alternate rsrc */
  max_capacity        NUMBER,  /* SGIDUGU - max capacity for alternate rsrc */
  runtime_factor      NUMBER,  /* B2353759,alternate runtime_factor */
  preference          PLS_INTEGER, /* B5688153 Prod spec alternates Rajesh Patangya */
  inventory_item_id   PLS_INTEGER  /* B5688153 Prod spec alternates Rajesh Patangya */
);
TYPE gmp_alt_resource_tbl IS TABLE OF gmp_alt_resource_typ
INDEX BY BINARY_INTEGER;
rtg_alt_rsrc_tab       gmp_alt_resource_tbl;

TYPE gmp_material_assoc_typ IS RECORD
(
  formula_id          PLS_INTEGER,
  recipe_id           PLS_INTEGER,
  line_type           PLS_INTEGER,
  line_no             PLS_INTEGER,
  x_formulaline_id    PLS_INTEGER,   /* B1177070 added encoded key */
  x_routingstep_id    PLS_INTEGER,  /* B1177070 added encoded key */
/* NAMIT_MTQ */
  inventory_item_id   PLS_INTEGER,
  routingstep_no      PLS_INTEGER,
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
  routing_id          PLS_INTEGER,
  x_dep_routingstep_id PLS_INTEGER,
  x_routingstep_id    PLS_INTEGER,
  dep_type            PLS_INTEGER,
  standard_delay      NUMBER,
  max_delay           NUMBER,
  transfer_pct        NUMBER,
  dep_routingstep_no  PLS_INTEGER,
  routingstep_no      PLS_INTEGER,
  chargeable_ind      PLS_INTEGER
);
 TYPE gmp_opr_stepdep_tab IS TABLE OF gmp_opr_stpdep_typ
 INDEX BY BINARY_INTEGER;
gmp_opr_stpdep_tbl gmp_opr_stepdep_tab;

/* GMD New Declaration of PL/SQL Tables for Activity and Resources Overrides */
TYPE recipe_orgn_override_typ IS RECORD
(
  routing_id          PLS_INTEGER,
  organization_id     PLS_INTEGER,
  routingstep_id      PLS_INTEGER,
  oprn_line_id        PLS_INTEGER,
  recipe_id           PLS_INTEGER,
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
  routing_id          PLS_INTEGER,
  routingstep_id      PLS_INTEGER,
  recipe_id           PLS_INTEGER,
  step_qty            NUMBER
);
TYPE recipe_override_tbl IS TABLE OF recipe_override_typ
INDEX BY BINARY_INTEGER;
recipe_override      recipe_override_tbl;

TYPE gmp_routing_step_offsets_typ IS RECORD
(
organization_id	PLS_INTEGER,
fmeff_id 	PLS_INTEGER,
formula_id	PLS_INTEGER,
routingstep_id	PLS_INTEGER,
start_offset	NUMBER,
end_offset	NUMBER,
formulaline_id	PLS_INTEGER
);
TYPE rtgstep_offsets_tbl IS TABLE OF gmp_routing_step_offsets_typ
INDEX BY BINARY_INTEGER ;
rstep_offsets	rtgstep_offsets_tbl;

--  Vpedarla 7391495
TYPE oper_leadtime_percent_typ IS RECORD
(
Organization_id NUMBER,
fmeff_id 	PLS_INTEGER,
formula_id	PLS_INTEGER,
routing_id  PLS_INTEGER,
routingstep_id	PLS_INTEGER,
start_offset	NUMBER,
end_offset	NUMBER
);
TYPE oper_leadtime_tbl IS TABLE OF oper_leadtime_percent_typ
INDEX BY BINARY_INTEGER ;
oper_leadtime_percent	oper_leadtime_tbl;
--  venu 7391495

/* SGIDUGU Seq Dep Table Definition */
TYPE gmp_sequence_typ IS RECORD
(
  oprn_id      PLS_INTEGER,
  category_id  PLS_INTEGER,
  seq_dep_id   PLS_INTEGER
);

seq_rec  gmp_sequence_typ;

TYPE gmp_setup_tbl  IS TABLE OF gmp_sequence_typ INDEX BY BINARY_INTEGER;
setupid_tab   gmp_setup_tbl ;

/* End of SGIDUGU Seq Dep Table Definition */


              /* Global Scalar values follow
                 =========================== */

l_debug                  VARCHAR2(1) := NVL(FND_PROFILE.VALUE('GMP_DEBUG_ENABLED'),'N'); -- BUG: 8420747


s		                 PLS_INTEGER := 1;
sd_index                  INTEGER := 0 ;  -- B4918786 (RDP) SDS
p_location                VARCHAR2(300) := NULL;

g_aps_eff_id              PLS_INTEGER := 0;  /* Global Aps Effectivity ID */
aps_fmeff_id              PLS_INTEGER := 0 ; /* Generated effectivity Id */
x_aps_fmeff_id            PLS_INTEGER := 0 ; /* encoded effectivity Id */

g_fm_dtl_start_loc        PLS_INTEGER := 0; /* Start detail location */
g_fm_dtl_end_loc          PLS_INTEGER := 0;  /* End detail location */
g_fm_hdr_loc              PLS_INTEGER := 1;  /* Starting for formula header */
g_formula_orgn_count_tab  PLS_INTEGER := 1;  /* Starting for formula orgn detail */
g_rstep_loc	 	  PLS_INTEGER := 1 ;  /* global rtg offset location */
g_curr_rstep_loc	  PLS_INTEGER  := -1 ; /* current r step offsetp locn */
g_prev_formula_id 	  PLS_INTEGER := -1 ;
g_prev_locn 		  PLS_INTEGER := 1;
g_dep_index               PLS_INTEGER := 1;

alt_rsrc_size             PLS_INTEGER;  /* Number of rows in formula_headers */
formula_headers_size      PLS_INTEGER;  /* Number of rows in formula_headers */
formula_details_size      PLS_INTEGER;  /* Number of rows in formula_details */
formula_orgn_size  	  PLS_INTEGER;  /* Number of detail rows for formula */
routing_headers_size      PLS_INTEGER;  /* Number of rows in routing_headers */
rtg_org_dtl_size      	  PLS_INTEGER;  /* Number of rows in routing_org_details */
rtg_gen_dtl_size          PLS_INTEGER;  /* Number of rows in generic routing_det */
material_assocs_size      PLS_INTEGER;  /* Number of rows in material_assocs */
/* NAMIT_CR */
setup_size                PLS_INTEGER;  /* Number of rows in Seq Dep Cursor */
/* SGIDUGU_seq_dep */
opr_stpdep_size           PLS_INTEGER := 1;  /* Number of rows in step dependency */

recipe_orgn_over_size     PLS_INTEGER;  /* No. of rows in recipe orgn override */
recipe_override_size      PLS_INTEGER;  /* Number of rows in recipe override */
rtg_offsets_size 	  PLS_INTEGER := 1;  /* Number of rows in rtg offsets tbl */
oper_leadtime_size        PLS_INTEGER := 1;  -- Vpedarla 7391495

current_date_time         DATE;	    /* For consistency writes */
instance_id               PLS_INTEGER;
delimiter   VARCHAR2(1);  /* Used when filling in comment columns on BOM and ROUTING Tables */
l_in_str_org              VARCHAR2(8000) := null ;   /* B3491625 */

at_apps_link              VARCHAR2(31); /* Database link to APPS server from Planning server  */
g_instance_id             PLS_INTEGER;       /* Instance Id from Planning server  */
v_cp_enabled              BOOLEAN := FALSE;
g_mat_assoc               PLS_INTEGER;  /* Glabal counter for materail assiciation */
g_gmp_uom_class           VARCHAR2(10); /* UOM Class */
g_setup_id                PLS_INTEGER; /* hold he last setup_id */

/* These variables store the MTQ related values that is last inserted. */
g_old_formula_id          PLS_INTEGER ; /* B3970993 */
g_old_recipe_id           PLS_INTEGER ; /* B3970993 */
g_old_rtg_id              PLS_INTEGER ; /* B3970993 */
g_old_rtgstep_id          PLS_INTEGER ; /* B3970993 */
g_old_aps_item_id         PLS_INTEGER ; /* B3970993 */
g_mtq_loc                 PLS_INTEGER ; /* B3970993 */
g_min_mtq                 NUMBER ; /* B3970993 */

/*B5176291 - Item substitution changes - start*/
loop_ctr                PLS_INTEGER;
k                       PLS_INTEGER;
g_formline_id           PLS_INTEGER;
l_counter               PLS_INTEGER;
ae_date                 DATE;
ae_flag                 BOOLEAN;
chg_stdate              BOOLEAN;
v_gmd_seq               VARCHAR2(4000) := NULL;
v_gmd_formula_lineid    INTEGER := 0;
gmd_formline_cnt        INTEGER := 0 ;
op_formline_cnt         INTEGER := 0 ;
get_sign                INTEGER;
/*B5176291 - Item substitution changes - end*/

/* bug:	6918852 Vpedarla created new global variabelt control precision in inventory uom conversion */
conv_precision          INTEGER := 9 ;

/* ---------------------------  Global declarations ------------------------ */
TYPE sr_instance_id IS TABLE OF msc_st_boms.sr_instance_id%TYPE INDEX BY BINARY_INTEGER;
bom_sr_instance_id  sr_instance_id;
bomc_sr_instance_id sr_instance_id;
pef_sr_instance_id sr_instance_id;
rtg_sr_instance_id sr_instance_id;
or_sr_instance_id sr_instance_id;
opr_sr_instance_id sr_instance_id;
rs_sr_instance_id sr_instance_id;
oc_sr_instance_id sr_instance_id;
/* NAMIT_MTQ */
itm_mtq_sr_instance_id sr_instance_id;
/* NAMIT_CR */
opr_stpdep_sr_instance_id sr_instance_id;

TYPE organization_id IS TABLE OF msc_st_boms.organization_id%TYPE INDEX BY BINARY_INTEGER;
bom_organization_id  organization_id;
bomc_organization_id organization_id;
pef_organization_id organization_id;
rtg_organization_id organization_id;
oc_organization_id organization_id;
gt_organization_id organization_id;
/* NAMIT_MTQ */
itm_mtq_organization_id       organization_id ;
opr_stpdep_organization_id    organization_id ;
opr_organization_id   organization_id ;
or_organization_id    organization_id ;
rs_organization_id    organization_id ;

TYPE bill_sequence_id IS TABLE OF msc_st_boms.bill_sequence_id%TYPE INDEX BY BINARY_INTEGER;
bom_bill_sequence_id bill_sequence_id;
bomc_bill_sequence_id bill_sequence_id;
pef_bill_sequence_id bill_sequence_id;
oc_bill_sequence_id bill_sequence_id;

TYPE last_update_date IS TABLE OF msc_st_boms.last_update_date%TYPE INDEX BY BINARY_INTEGER;
bom_last_update_date last_update_date ;
bomc_last_update_date last_update_date ;
pef_last_update_date last_update_date ;
rtg_last_update_date last_update_date ;
or_last_update_date last_update_date ;
opr_last_update_date last_update_date ;
opr_stpdep_last_update_date last_update_date ;  /* 7363807 */
itm_mtq_last_update_date last_update_date ;  /* 7363807 */
rs_last_update_date last_update_date ;
oc_last_update_date last_update_date ;

TYPE creation_date IS TABLE OF msc_st_boms.creation_date%TYPE INDEX BY BINARY_INTEGER;
bom_creation_date creation_date ;
bomc_creation_date creation_date ;
pef_creation_date creation_date ;
rtg_creation_date creation_date ;
or_creation_date creation_date ;
opr_creation_date creation_date ;
opr_stpdep_creation_date creation_date ;  /* 7363807 */
itm_mtq_creation_date  creation_date ;  /* 7363807 */
rs_creation_date creation_date ;
oc_creation_date creation_date ;

TYPE effectivity_date IS TABLE OF msc_st_process_effectivity.effectivity_date%TYPE
INDEX BY BINARY_INTEGER;
pef_effectivity_date effectivity_date   ;
bomc_effectivity_date effectivity_date   ;
opr_effectivity_date effectivity_date   ;

TYPE routing_sequence_id IS TABLE OF msc_st_routings.routing_sequence_id%TYPE
INDEX BY BINARY_INTEGER;
rtg_routing_sequence_id routing_sequence_id   ;
pef_routing_sequence_id routing_sequence_id   ;
or_routing_sequence_id routing_sequence_id   ;
opr_routing_sequence_id routing_sequence_id   ;
rs_routing_sequence_id routing_sequence_id   ;
oc_routing_sequence_id routing_sequence_id   ;
/* NAMIT_MTQ */
itm_mtq_routing_sequence_id routing_sequence_id   ;
/* NAMIT_CR */
opr_stpdep_routing_sequence_id routing_sequence_id   ;

TYPE uom_code IS TABLE OF msc_st_bom_components.uom_code%TYPE INDEX BY BINARY_INTEGER;
bomc_uom_code  uom_code  ;
rtg_uom_code   uom_code ;
or_uom_code    uom_code ;
opr_uom_code   uom_code ;

TYPE assembly_item_id IS TABLE OF msc_st_boms.assembly_item_id%TYPE
INDEX BY BINARY_INTEGER;
bom_assembly_item_id assembly_item_id ;
rtg_assembly_item_id assembly_item_id ;

TYPE component_sequence_id IS TABLE OF msc_st_bom_components.component_sequence_id%TYPE
INDEX BY BINARY_INTEGER;
bomc_component_sequence_id component_sequence_id;
oc_component_sequence_id component_sequence_id;

TYPE operation_sequence_id IS TABLE OF msc_st_operation_resources.operation_sequence_id%TYPE
INDEX BY BINARY_INTEGER;
or_operation_sequence_id  operation_sequence_id   ;
opr_operation_sequence_id operation_sequence_id   ;
rs_operation_sequence_id  operation_sequence_id   ;
oc_operation_sequence_id  operation_sequence_id   ;

-- Bug 7391495 Vpedarla
TYPE operation_leadtime_per IS TABLE OF msc_st_routing_operations.operation_lead_time_percent%TYPE
INDEX BY BINARY_INTEGER;
opr_lead_time_percent     operation_leadtime_per  ;

TYPE resource_seq_num IS TABLE OF msc_st_operation_resources.resource_seq_num%TYPE
INDEX BY BINARY_INTEGER;
or_resource_seq_num resource_seq_num   ;
rs_resource_seq_num resource_seq_num   ;
/* SGIDUGU - Seq Dep */
TYPE setup_id_typ IS TABLE OF gmp_sequence_types.seq_dep_id%TYPE INDEX BY BINARY_INTEGER;
or_setup_id     setup_id_typ   ;
gt_setup_id     setup_id_typ   ;
--
TYPE seq_dep_class_typ IS TABLE OF ic_item_mst.seq_dpnd_class%TYPE INDEX BY
BINARY_INTEGER;
gt_seq_dep_class     seq_dep_class_typ   ;
--
TYPE oprn_no_typ IS TABLE OF gmd_operations.oprn_no%TYPE INDEX BY
BINARY_INTEGER;
gt_oprn_no     oprn_no_typ ;

/* End of changes SGIDUGU - Seq Dep */

/* -------------------------------  BOM declarations --------------------------- */
TYPE alternate_bom_designator IS TABLE OF msc_st_boms.alternate_bom_designator%TYPE
INDEX BY BINARY_INTEGER;
bom_alternate_bom_designator alternate_bom_designator ;

TYPE specific_assembly_comment IS TABLE OF msc_st_boms.specific_assembly_comment%TYPE
INDEX BY BINARY_INTEGER;
bom_specific_assembly_comment specific_assembly_comment ;

TYPE scaling_type IS TABLE OF msc_st_boms.scaling_type%TYPE
INDEX BY BINARY_INTEGER;
bom_scaling_type scaling_type ;

TYPE assembly_quantity IS TABLE OF msc_st_boms.assembly_quantity%TYPE
INDEX BY BINARY_INTEGER;
bom_assembly_quantity assembly_quantity ;

TYPE uom IS TABLE OF msc_st_boms.uom%TYPE INDEX BY BINARY_INTEGER;
bom_uom uom ;

/* NAMIT_CR For Step Material Assoc */
TYPE seq_num IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
bom_op_seq_number seq_num;

/* NAMIT_OC For ingredients contribute_to_step_qty will
        store 1 for YES and 0 for NO */
TYPE contribute_to_step_qty_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
bomc_contribute_to_step_qty contribute_to_step_qty_type;

bom_index INTEGER := 0 ;   /* BOM Global counter */

/* ---------------------------  BOM Components declarations ------------------------ */
TYPE Inventory_item_id IS TABLE OF msc_st_bom_components.Inventory_item_id%TYPE
INDEX BY BINARY_INTEGER;
bomc_Inventory_item_id Inventory_item_id;

TYPE using_assembly_id IS TABLE OF msc_st_bom_components.using_assembly_id%TYPE
INDEX BY BINARY_INTEGER;
bomc_using_assembly_id using_assembly_id    ;

TYPE component_type IS TABLE OF msc_st_bom_components.component_type%TYPE
INDEX BY BINARY_INTEGER;
bomc_component_type component_type    ;

TYPE bc_scaling_type IS TABLE OF msc_st_bom_components.scaling_type%TYPE
INDEX BY BINARY_INTEGER;
bomc_scaling_type  bc_scaling_type;

TYPE usage_quantity IS TABLE OF msc_st_bom_components.usage_quantity%TYPE
INDEX BY BINARY_INTEGER;
bomc_usage_quantity usage_quantity ;

TYPE operation_offset_percent IS TABLE OF msc_st_bom_components.operation_offset_percent%TYPE
INDEX BY BINARY_INTEGER;
bomc_opr_offset_percent  operation_offset_percent ;

TYPE optional_component IS TABLE OF msc_st_bom_components.optional_component%TYPE
INDEX BY BINARY_INTEGER;
bomc_optional_component  optional_component ;

TYPE wip_supply_type IS TABLE OF msc_st_bom_components.wip_supply_type%TYPE
INDEX BY BINARY_INTEGER;
bomc_wip_supply_type wip_supply_type ;

TYPE scale_multiple IS TABLE OF msc_st_bom_components.scale_multiple%TYPE
INDEX BY BINARY_INTEGER;
bomc_scale_multiple  scale_multiple;

TYPE scale_rounding_variance IS TABLE OF msc_st_bom_components.scale_rounding_variance%TYPE
INDEX BY BINARY_INTEGER;
bomc_scale_rounding_variance scale_rounding_variance ;

TYPE rounding_direction IS TABLE OF msc_st_bom_components.rounding_direction%TYPE
INDEX BY BINARY_INTEGER;
bomc_rounding_direction  rounding_direction ;

/*B5176291 - Item substitution changes - start*/
TYPE b_disable_date IS TABLE OF msc_st_bom_components.disable_date%TYPE
INDEX BY BINARY_INTEGER;
bomc_disable_date  b_disable_date ;
/*B5176291 - Item substitution changes - end*/

bomc_index INTEGER := 0 ;   /* BOM component Global counter */

/* ---------------------------  Effectivity declarations ------------------------ */
TYPE process_sequence_id IS TABLE OF msc_st_process_effectivity.process_sequence_id%TYPE
INDEX BY BINARY_INTEGER;
pef_process_sequence_id process_sequence_id   ;

TYPE item_id IS TABLE OF msc_st_process_effectivity.item_id%TYPE INDEX BY BINARY_INTEGER;
pef_item_id item_id   ;

TYPE disable_date IS TABLE OF msc_st_process_effectivity.disable_date%TYPE
INDEX BY BINARY_INTEGER;
pef_disable_date disable_date   ;

TYPE minimum_quantity IS TABLE OF msc_st_process_effectivity.minimum_quantity%TYPE
INDEX BY BINARY_INTEGER;
pef_minimum_quantity minimum_quantity   ;

TYPE maximum_quantity IS TABLE OF msc_st_process_effectivity.maximum_quantity%TYPE
INDEX BY BINARY_INTEGER;
pef_maximum_quantity maximum_quantity   ;

TYPE preference IS TABLE OF msc_st_process_effectivity.preference%TYPE
INDEX BY BINARY_INTEGER;
pef_preference preference ;

 -- Bug: 8715318 Vpedarla uncommented the below line.
 TYPE recipe IS TABLE OF msc_st_process_effectivity.recipe%TYPE
 INDEX BY BINARY_INTEGER;
 pef_recipe recipe ;

pef_index INTEGER := 0 ;   /* Process Effectivity Global counter */

/* -------------------------------  Routng declarations  --------------------------- */
TYPE routing_comment IS TABLE OF msc_st_routings.routing_comment%TYPE
INDEX BY BINARY_INTEGER;
rtg_routing_comment routing_comment ;
empty_rtg_comment routing_comment ;

TYPE alt_routing_designator  IS TABLE OF msc_st_routings.alternate_routing_designator%TYPE
INDEX BY BINARY_INTEGER;
rtg_alt_routing_designator alt_routing_designator   ;

TYPE routing_quantity IS TABLE OF msc_st_routings.routing_quantity%TYPE
INDEX BY BINARY_INTEGER;
rtg_routing_quantity routing_quantity   ;

/* NAMIT_CR For Calculate Step Dependency Flag */
TYPE auto_step_qty_flag IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
rtg_auto_step_qty_flag auto_step_qty_flag  ;

rtg_index INTEGER := 0 ;   /* Routing Global counter */

/* -------------------------- Routng operations declarations  ------------------------ */
TYPE resource_id IS TABLE OF msc_st_operation_resources.resource_id%TYPE
INDEX BY BINARY_INTEGER;
or_resource_id resource_id   ;
gt_resource_id resource_id   ;

TYPE alternate_number IS TABLE OF msc_st_operation_resources.alternate_number%TYPE
INDEX BY BINARY_INTEGER;
or_alternate_number alternate_number   ;

TYPE principal_flag IS TABLE OF msc_st_operation_resources.principal_flag%TYPE
INDEX BY BINARY_INTEGER;
or_principal_flag principal_flag   ;

TYPE basis_type IS TABLE OF msc_st_operation_resources.basis_type%TYPE
INDEX BY BINARY_INTEGER;
or_basis_type basis_type   ;

TYPE resource_usage IS TABLE OF msc_st_operation_resources.resource_usage%TYPE
INDEX BY BINARY_INTEGER;
or_resource_usage resource_usage   ;

TYPE max_resource_units IS TABLE OF msc_st_operation_resources.max_resource_units%TYPE
INDEX BY BINARY_INTEGER;
or_max_resource_units max_resource_units   ;

TYPE resource_units IS TABLE OF msc_st_operation_resources.resource_units%TYPE
INDEX BY BINARY_INTEGER;
or_resource_units resource_units   ;

TYPE or_orig_rs_seq_num_typ IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
or_orig_rs_seq_num or_orig_rs_seq_num_typ ;
or_break_ind or_orig_rs_seq_num_typ;

or_index PLS_INTEGER := 0 ;   /* Operation Resource Global counter */

/* -------------------------- Operations declarations  ------------------------ */
TYPE operation_seq_num IS TABLE OF msc_st_routing_operations.operation_seq_num%TYPE
INDEX BY BINARY_INTEGER;
opr_operation_seq_num operation_seq_num   ;

TYPE operation_description IS TABLE OF msc_st_routing_operations.operation_description%TYPE
INDEX BY BINARY_INTEGER;
opr_operation_description operation_description   ;

TYPE mtransfer_quantity IS TABLE OF msc_st_routing_operations.minimum_transfer_quantity%TYPE
INDEX BY BINARY_INTEGER;
opr_mtransfer_quantity mtransfer_quantity   ;

TYPE department_id IS TABLE OF msc_st_routing_operations.department_id%TYPE
INDEX BY BINARY_INTEGER;
opr_department_id department_id ;
rs_department_id department_id ;

TYPE department_code IS TABLE OF msc_st_routing_operations.department_code%TYPE
INDEX BY BINARY_INTEGER;
opr_department_code department_code ;

TYPE activity_group_id IS TABLE OF msc_st_operation_resource_seqs.activity_group_id%TYPE
INDEX BY BINARY_INTEGER;
rs_activity_group_id activity_group_id ;

TYPE schedule_flag IS TABLE OF msc_st_operation_resource_seqs.activity_group_id%TYPE
INDEX BY BINARY_INTEGER;
rs_schedule_flag schedule_flag ;

/* NAMIT_MTQ */
TYPE operation_seq_id IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
itm_mtq_from_op_seq_id operation_seq_id ;
/* NAMIT_CR */
opr_stpdep_frm_seq_id operation_seq_id ;
opr_stpdep_to_seq_id operation_seq_id ;

/* NAMIT_CR */
TYPE dependency_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
opr_stpdep_dependency_type dependency_type ;

TYPE minimum_time_offset IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
itm_mtq_min_time_offset minimum_time_offset ;
itm_mtq_max_time_offset minimum_time_offset ;
/* NAMIT_CR */
opr_stpdep_min_time_offset minimum_time_offset ;
opr_stpdep_max_time_offset minimum_time_offset ;

/* NAMIT_CR */
TYPE transfer_pct IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
opr_stpdep_trans_pct transfer_pct ;

TYPE from_op_seq_num IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
itm_mtq_frm_op_seq_num from_op_seq_num ;
/* NAMIT_CR */
opr_stpdep_frm_op_seq_num from_op_seq_num ;
opr_stpdep_to_op_seq_num from_op_seq_num ;

/* NAMIT_CR */
TYPE apply_to_charges IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
opr_stpdep_app_to_chrg apply_to_charges ;

TYPE from_item_id IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
itm_mtq_from_item_id from_item_id ;

TYPE minimum_transfer_qty IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
itm_mtq_min_tran_qty minimum_transfer_qty ;

/* NAMIT_OC */
TYPE min_capacity IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
or_minimum_capacity min_capacity ;
or_maximum_capacity min_capacity ;

/* NAMIT_ASQC */
TYPE step_qty_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
opr_step_qty step_qty_type;

TYPE step_qty_uom_type IS TABLE OF VARCHAR2(3) INDEX BY BINARY_INTEGER;
opr_step_qty_uom step_qty_uom_type;

opr_index PLS_INTEGER := 0 ;   /* Operation Global counter */
rs_index  PLS_INTEGER := 0 ;   /* Operation Global counter */
oc_index  PLS_INTEGER := 0 ;   /* Operation component Global counter */
/* NAMIT_MTQ */
mtq_index PLS_INTEGER := 0 ;   /* MTQ Global counter */


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
  cur_oper_lead_time  ref_cursor_typ;  -- Vpedarla 7391495
  cur_rtg_offsets     ref_cursor_typ;
  cur_opr_stpdep      ref_cursor_typ;
  seq_dep_dtl         ref_cursor_typ;
  setup_id_dtl        ref_cursor_typ;
  uom_code_ref        ref_cursor_typ;
  source_call_ref     ref_cursor_typ ; /*B8230710*/

  retrieval_cursor        VARCHAR2(32767) ;
  effectivity_cursor      VARCHAR2(32767) ;
  formula_hdr_cursor      VARCHAR2(32767) ;
  formula_dtl_cursor      VARCHAR2(32767) ;
  routing_hdr_cursor      VARCHAR2(32767) ;
  mat_assoc_cursor        VARCHAR2(32767) ;
  recipe_orgn_statement   VARCHAR2(32767) ;
  recipe_statement        VARCHAR2(32767) ;
  uom_conv_cursor         VARCHAR2(32767) ; /*B2870041 hold sql for uom conv*/
  oper_lead_time_cur_stmt VARCHAR2(32767) ;  -- Vpedarla 7391495
  rtg_offset_cur_stmt     VARCHAR2(32767) ;
  statement_alt_resource  VARCHAR2(32767) ;
  opr_stpdep_cursor       VARCHAR2(32767) ;
  seq_dep_cursor          VARCHAR2(32767) ;
  setup_id_cursor         VARCHAR2(32767) ;
  uom_code_cursor         VARCHAR2(32767) ;

  valid                   BOOLEAN ;
  routing_valid           BOOLEAN ;

  old_fmeff_id            PLS_INTEGER ;
  old_organization_id     PLS_INTEGER ;
  old_formula_id          PLS_INTEGER ;
  mat_start_indx          PLS_INTEGER ;
  mat_end_indx            PLS_INTEGER ;
  eff_counter		  INTEGER ;
  s                       INTEGER ;
  j                       PLS_INTEGER ; /*B2870041 for loop index*/

  temp_total_qty          NUMBER ; /*B2870041 temp var to calculate total output*/
  v_matl_qty              NUMBER ; /*B2870041 cursor var to get uom conv qty */
  spl_cnt                 NUMBER ;
  end_index               PLS_INTEGER ; /*B2870041 for loop index*/
  old_route               PLS_INTEGER ; /*B2870041 for loop index*/
  old_orgn_id             PLS_INTEGER ; /*B2870041 for loop index*/
  old_step                PLS_INTEGER ; /*B2870041 for loop index*/
  ri                      PLS_INTEGER ; /*B2870041 for loop index*/
  found                   NUMBER ; /*B2870041 for loop index*/
  first_step_row          PLS_INTEGER ; /*B2870041 for loop index*/
  found_chrg_rsrc         PLS_INTEGER ;
  chrg_activity           VARCHAR2(16) ;
  l_gmp_um_code           VARCHAR2(25) ;
  v_dummy                 NUMBER ;   /* B8230710 hold the statistics */

  -- Bug:6087535 Vpedarla 23-07-07 added for item substituion
  loop_ctr                PLS_INTEGER;
  k                       PLS_INTEGER;
  orig_start_date         DATE;
  substcount              PLS_INTEGER;
  enddatenull             BOOLEAN:=FALSE;
  nullenddatefound        BOOLEAN := FALSE;
  l_eff_counter           NUMBER;            -- Vpedarla Bug: 8230710
  source_call             VARCHAR2(32767) ;  -- Vpedarla Bug: 8230710
  source_call_result      BOOLEAN;           -- Vpedarla Bug: 8230710

BEGIN
  retrieval_cursor        := NULL;
  effectivity_cursor      := NULL;
  formula_hdr_cursor      := NULL;
  formula_dtl_cursor      := NULL;
  routing_hdr_cursor      := NULL;
  mat_assoc_cursor        := NULL;
  recipe_orgn_statement   := NULL;
  recipe_statement        := NULL;
  uom_conv_cursor         := NULL; /*B2870041 hold sql for uom conv*/
  rtg_offset_cur_stmt     := NULL;
  statement_alt_resource  := NULL;
  opr_stpdep_cursor       := NULL;
  seq_dep_cursor          := NULL;
  setup_id_cursor         := NULL;
  uom_code_cursor         := NULL;
  oper_lead_time_cur_stmt := NULL ; -- Vpedarla 7391495
  valid                   := FALSE;
  routing_valid           := FALSE;
  old_fmeff_id            := 0 ;
  old_organization_id     := 0 ;
  old_formula_id          := 0 ;
  mat_start_indx          := 0 ;
  mat_end_indx            := 0 ;
  eff_counter		  := 0;
  s                       := 1 ;
  j                       := 0; /*B2870041 for loop index*/
  temp_total_qty          := 0; /*B2870041 temp var to calculate total output*/
  v_matl_qty              := 0; /*B2870041 cursor var to get uom conv qty */
  spl_cnt                 := 1 ;
  end_index               := 0; /*B2870041 for loop index*/
  old_route               := 0; /*B2870041 for loop index*/
  old_orgn_id             := 0; /*B2870041 for loop index*/
  old_step                := 0; /*B2870041 for loop index*/
  ri                      := 0; /*B2870041 for loop index*/
  found                   := 0; /*B2870041 for loop index*/
  first_step_row          := 0; /*B2870041 for loop index*/
  found_chrg_rsrc         := 0;
  chrg_activity           := NULL;
  l_gmp_um_code           := NULL;

  g_fm_dtl_start_loc      := 0; /* Start detail location */
  g_fm_dtl_end_loc        := 0; /* End detail location */
  g_fm_hdr_loc            := 1; /* Starting for formula header */
  g_formula_orgn_count_tab := 1; /* Starting for formula orgn detail */

  g_rstep_loc             := 1 ;
  g_curr_rstep_loc        := -1 ;
  g_prev_formula_id       := -1 ;
  g_prev_locn             := 1;

  enddatenull             := FALSE;
  nullenddatefound        := FALSE;
  v_dummy                 := 0; /* B8230710 */

    dbms_session.free_unused_user_memory;

     /* populate the org_string    */
     IF gmp_calendar_pkg.org_string(g_instance_id) THEN
        NULL ;
     ELSE
        RAISE invalid_string_value  ;
     END IF;

    l_in_str_org := gmp_calendar_pkg.g_in_str_org ;  /* B3491625 */


    LOG_MESSAGE('l_in_str_org'||'  '||l_in_str_org);
    time_stamp;

    /* Bug: 8230710 Call the remote procedure to populate gmp_form_eff with new
       effective validity rules. this will avoid insert over DB link for each effectivity */
    source_call := 'select gmp_utility.populate_eff'||at_apps_link||'('''||l_in_str_org||''')'||' into source_call_result from dual ';
    IF NOT source_call_result THEN
        RAISE source_call_failure;
    END IF;

    LOG_MESSAGE('after the Source call: populate_eff ');
    time_stamp;

    /* B2870041 changed cursor to retrieve the just the routing qty no uom
       conv, added uom conv of the product to the routing uom for a qty of 1
       to get the factor. The factor will be used later. added product index
       to allow access when we are writing out the routing */
    /* The query is being modified to incorporate changes for 1830940 */
    /* B2989806 Added inline tables and outer joins to select aps_fmeff_id */

/* NAMIT UOM Changes */

/* bug: 6710684 Vpedarla making changes to take the profile value from source server
           and also made changes to use procedure get_profile_value */
--       commented the below code line
--      l_gmp_um_code   := fnd_profile.VALUE('BOM:HOUR_UOM_CODE');
        l_gmp_um_code   := get_profile_value('BOM:HOUR_UOM_CODE', at_apps_link );
/* bug: 6710684 end of changes */

    IF l_gmp_um_code IS NOT NULL THEN
/* Get the UOM code and UOM Class corresponding to "BOM: UOM Hour" Profile */
/* akaruppa - sy_uoms_mst replaced with the mtl_units_of_measure */
       uom_code_cursor := ' select uom_class '
                      ||' from mtl_units_of_measure'||at_apps_link
                      ||' where uom_code = :gmp_um_code ';

       OPEN uom_code_ref FOR uom_code_cursor USING l_gmp_um_code;
       FETCH uom_code_ref INTO g_gmp_uom_class;
       CLOSE uom_code_ref;
    ELSE
         RAISE invalid_gmp_uom_profile  ;
    END IF;
    IF (g_gmp_uom_class IS NULL) THEN
         RAISE invalid_gmp_uom_profile  ;
    END IF;

    gmp_debug_message('gmp_uom_class - '|| g_gmp_uom_class);
        /* B3837959 MMK Issue, Database link added for form_eff */
     effectivity_cursor :=
 ' SELECT eff.recipe_validity_rule_id, '
        ||' nvl(gfe.aps_fmeff_id,-1),eff.inventory_item_id, '
        ||' eff.formula_id,eff.organization_id, '
        ||' eff.start_date, eff.end_date, eff.inv_min_qty, '
        ||' eff.inv_max_qty, eff.preference, eff.primary_uom_code, '
        ||' eff.wcode, eff.routing_id, '
        ||' eff.routing_no, eff.routing_vers, eff.routing_desc, '
        ||' eff.routing_uom, eff.routing_qty, '
        ||' eff.prd_fct  , eff.prd_ind, '
        ||' eff.recipe_id, eff.recipe_no, eff.recipe_version, eff.rhdr_loc, '
/* NAMIT_CR Get Calculate Step Dependency Checkbox*/
/* SGIDUGU - added Category id and Setup Id */
        ||' decode(eff.calculate_step_quantity,0,2,1) calculate_step_quantity, '
        ||' scat.category_id, NULL, '
        ||' scat.category_concat_segs '
        ||'FROM (  '
        ||' SELECT /*+ ORDERED USE_NL(gmd_recipe_validity_rules,fm_form_mst,mtl_system_items)*/  ffe.recipe_validity_rule_id, ffe.inventory_item_id, '
        ||' grb.formula_id, ffe.organization_id, '
	      ||' ffe.start_date, ffe.end_date, ffe.inv_min_qty, '
	      ||' ffe.inv_max_qty, ffe.preference, msi.primary_uom_code, '
        ||' mp.organization_code wcode , grb.routing_id, '
	      ||' frh.routing_no, frh.routing_vers, frh.routing_desc, '
        ||' frh.routing_uom, frh.routing_qty, ' /*B2870041*/
        ||' DECODE(frh.routing_uom,msi.primary_uom_code ,1, '
        ||'        inv_convert.inv_um_convert'||at_apps_link
        ||'                 ( ffe.inventory_item_id, '
        ||'                   NULL, '
        ||'                   ffe.organization_id, '
        /* bug: 6918852 Vpedarla 04-Apr-2008  used the global variable for precision*/
       /* ||'                   NULL, '  */
        ||                    conv_precision || ' , '
        ||'                   1, '
        ||'                   msi.primary_uom_code , '   /* primary */
        ||'                   frh.routing_uom , '   /* routing um */
        ||'                   NULL , '
        ||'                   NULL '
        ||'                 ) '
        ||'         ) prd_fct, -1 prd_ind, '
        ||' grb.recipe_id, grb.recipe_no, grb.recipe_version , '
	      ||' 0 rhdr_loc, '
       /* NAMIT_CR, SGIDUGU - Seq dep Id */
        ||' grb.calculate_step_quantity '
        ||' FROM  gmd_recipes_b'||at_apps_link||' grb,'
        ||'       gmd_recipe_validity_rules'||at_apps_link||' ffe,'
        ||'       fm_form_mst'||at_apps_link||' ffm,'
        ||'       fm_rout_hdr'||at_apps_link||' frh,'
      	||'       mtl_parameters'||at_apps_link||' mp,'
      	||'       mtl_system_items'||at_apps_link||' msi,'
       	||'       hr_organization_units'||at_apps_link||' hou,'
        ||'       gmd_status_b'||at_apps_link||' gs1,'
        ||'       gmd_status_b'||at_apps_link||' gs2,'
        ||'       gmd_status_b'||at_apps_link||' gs3,'
        ||'       gmd_status_b'||at_apps_link||' gs4 '
        ||' WHERE grb.delete_mark = 0 '
        ||'   AND grb.recipe_id = ffe.recipe_id '
        ||'   AND grb.recipe_status = gs1.status_code '
        ||'   AND gs1.status_type IN (' ||'''700'''|| ',' ||'''900'''|| ',' ||'''400'''|| ') '
        ||'   AND gs1.delete_mark = 0 '
        ||'   AND ffe.delete_mark = 0 '
        ||'   AND ffe.validity_rule_status = gs2.status_code '
        ||'   AND gs2.status_type IN (' ||'''700'''|| ',' ||'''900'''|| ',' ||'''400'''|| ') '
        ||'   AND gs2.delete_mark = 0 '
        ||'   AND frh.delete_mark = 0 '
        ||'   AND ffm.delete_mark = 0 '
        ||'   AND nvl(hou.date_to,SYSDATE) >= SYSDATE '
        ||'   AND hou.organization_id = mp.organization_id '
        ||'   AND frh.inactive_ind = 0 '
        ||'   AND ffm.inactive_ind = 0 '
        ||'   AND grb.routing_id IS NOT NULL '
        ||'   AND ffe.organization_id IS NOT NULL '
        ||'   AND ffe.recipe_use IN (0,1) '
        ||'   AND nvl(ffe.end_date,(SYSDATE + 1)) > SYSDATE '
        ||'   AND ffe.organization_id = mp.organization_id '
        ||'   AND grb.formula_id = ffm.formula_id '
        ||'   AND ffm.formula_status = gs3.status_code '
        ||'   AND gs3.status_type IN (' ||'''700'''|| ',' ||'''900'''|| ',' ||'''400'''|| ') '
        ||'   AND gs3.delete_mark = 0 '
        ||'   AND grb.routing_id =  frh.routing_id '
        ||'   AND frh.routing_status =  gs4.status_code '
        ||'   AND gs4.status_type IN (' ||'''700'''|| ',' ||'''900'''|| ',' ||'''400'''|| ') '
        ||'   AND gs4.delete_mark = 0 '
        ||'   AND msi.organization_id =  ffe.organization_id '
        ||'   AND msi.inventory_item_id =  ffe.inventory_item_id '
        ||'   AND msi.recipe_enabled_flag = ''Y'' '
        ||'   AND msi.process_execution_enabled_flag = ''Y'' '
        ||'   AND mp.process_enabled_flag = ''Y'' '
/*B5161655 - Changed the where clause to pick up even when the formula belongs to a differnt organization
from the validity rules */
        ||'   AND EXISTS ( SELECT /*+DRIVING_SITE(FM_MATL_DTL)*/ 1 '
        ||'          FROM  fm_matl_dtl'||at_apps_link||' '
        ||'          WHERE formula_id = grb.formula_id '
        ||'          AND line_type = 1 '
        ||'          AND inventory_item_id = msi.inventory_item_id '
        ||'          AND msi.organization_id = ffe.organization_id '
        ||'          AND inventory_item_id = ffe.inventory_item_id ) '
        ||' UNION ALL '
        ||' SELECT /*+ ORDERED USE_NL(gmd_recipe_validity_rules,fm_form_mst,mtl_system_items)*/ ffe.recipe_validity_rule_id, ffe.inventory_item_id, '
        ||' grb.formula_id, ffe.organization_id, '
        ||' ffe.start_date, ffe.end_date, ffe.inv_min_qty, '
        ||' ffe.inv_max_qty, ffe.preference, msi.primary_uom_code, '
        ||' mp.organization_code wcode , to_number(null) , '
        ||' NULL, to_number(null), NULL, '
        ||' NULL, to_number(null), to_number(null) prd_fct, -1 prd_ind, '
        ||' grb.recipe_id, grb.recipe_no, grb.recipe_version , '
        ||' 0 rhdr_loc, '
/* NAMIT_CR,SGIDUGU */
        ||' 0 calculate_step_quantity '
        ||' FROM  gmd_recipes_b'||at_apps_link||' grb,'
        ||'       gmd_recipe_validity_rules'||at_apps_link||' ffe,'
        ||'       fm_form_mst'||at_apps_link||' ffm, '
        ||'       mtl_parameters'||at_apps_link||' mp, '
	||'       mtl_system_items'||at_apps_link||' msi, '
	||'       hr_organization_units'||at_apps_link||' hou,'
	||'       gmd_status_b'||at_apps_link||' gs1,'
	||'       gmd_status_b'||at_apps_link||' gs2,'
	||'       gmd_status_b'||at_apps_link||' gs3 '
        ||' WHERE  grb.delete_mark = 0 '
        ||'   AND grb.recipe_id = ffe.recipe_id '
        ||'   AND grb.recipe_status = gs1.status_code '
        ||'   AND gs1.status_type IN (' ||'''700'''|| ',' ||'''900'''|| ',' ||'''400'''|| ') '
        ||'   AND gs1.delete_mark = 0 '
        ||'   AND ffe.delete_mark = 0 '
        ||'   AND ffe.validity_rule_status = gs2.status_code '
        ||'   AND gs2.status_type IN (' ||'''700'''|| ',' ||'''900'''|| ',' ||'''400'''|| ') '
        ||'   AND gs2.delete_mark = 0 '
        ||'   AND ffm.delete_mark = 0 '
        ||'   AND nvl(hou.date_to,SYSDATE) >= SYSDATE '
        ||'   AND hou.organization_id = mp.organization_id '
        ||'   AND ffm.inactive_ind = 0 '
        ||'   AND grb.routing_id IS NULL '
        ||'   AND ffe.organization_id IS NOT NULL '
        ||'   AND ffe.organization_id = mp.organization_id '
        ||'   AND ffe.recipe_use IN (0,1) '
        ||'   AND nvl(ffe.end_date,(SYSDATE + 1)) > SYSDATE '
        ||'   AND grb.formula_id = ffm.formula_id '
        ||'   AND ffm.formula_status = gs3.status_code '
        ||'   AND gs3.status_type IN (' ||'''700'''|| ',' ||'''900'''|| ',' ||'''400'''|| ') '
        ||'   AND gs3.delete_mark = 0 '
        ||'   AND msi.organization_id =  ffe.organization_id '
        ||'   AND msi.inventory_item_id =  ffe.inventory_item_id '
        ||'   AND msi.recipe_enabled_flag = ''Y'' '
        ||'   AND msi.process_execution_enabled_flag = ''Y'' '
        ||'   AND mp.process_enabled_flag = ''Y'' '
/*B5161655 - Changed the where clause to pick up even when the formula belongs to a differnt organization
from the validity rules */
        ||'   AND EXISTS ( SELECT /*+DRIVING_SITE(FM_MATL_DTL)*/ 1 '
        ||'          FROM  fm_matl_dtl'||at_apps_link||' '
        ||'          WHERE formula_id = grb.formula_id '
        ||'          AND line_type = 1 '
        ||'          AND inventory_item_id = msi.inventory_item_id '
        ||'          AND msi.organization_id = ffe.organization_id '
        ||'          AND inventory_item_id = ffe.inventory_item_id ) '
        ||' UNION ALL '
        ||' SELECT /*+ ORDERED USE_NL(gmd_recipe_validity_rules,fm_form_mst,mtl_system_items)*/ ffe.recipe_validity_rule_id, ffe.inventory_item_id, '
        ||' grb.formula_id, msi.organization_id, '
        ||' ffe.start_date, ffe.end_date, ffe.inv_min_qty, '
        ||' ffe.inv_max_qty, ffe.preference, msi.primary_uom_code, '
        ||' mp.organization_code wcode , grb.routing_id, '
        ||' frh.routing_no, frh.routing_vers, frh.routing_desc, '
        ||' frh.routing_uom, frh.routing_qty,' /*B2870041*/
        ||' DECODE(frh.routing_uom,msi.primary_uom_code ,1, '
        ||'        inv_convert.inv_um_convert'||at_apps_link
        ||'                 (ffe.inventory_item_id, '
        ||'                  NULL, '
        ||'                  msi.organization_id, '
      /* bug: 6918852 Vpedarla 04-Apr-2008  used the global variable for precision*/
       /* ||'                   NULL, '  */
        ||                    conv_precision || ' , '
        ||'                  1, '
        ||'                  msi.primary_uom_code , '   /* primary */
        ||'                  frh.routing_uom , '   /* routing um */
        ||'                  NULL , '
        ||'                  NULL '
        ||'                 ) '
        ||'         ) prd_fct, -1 prd_ind, '
        ||' grb.recipe_id, grb.recipe_no, grb.recipe_version ,'
	||' 0 rhdr_loc, '
/* NAMIT_CR,SGIDUGU */
        ||' grb.calculate_step_quantity '
	||' FROM  gmd_recipes_b'||at_apps_link||' grb,'
	||'       gmd_recipe_validity_rules'||at_apps_link||' ffe,'
	||'       fm_form_mst'||at_apps_link||' ffm,'
	||'       fm_rout_hdr'||at_apps_link||' frh,'
	||'       mtl_parameters'||at_apps_link||' mp,'
	||'       mtl_system_items'||at_apps_link||' msi,'
	||'       hr_organization_units'||at_apps_link||' hou,'
	||'       gmd_status_b'||at_apps_link||' gs1,'
	||'       gmd_status_b'||at_apps_link||' gs2,'
	||'       gmd_status_b'||at_apps_link||' gs3,'
	||'       gmd_status_b'||at_apps_link||' gs4 '
        ||' WHERE grb.delete_mark = 0 '
        ||'   AND grb.recipe_id = ffe.recipe_id '
        ||'   AND grb.recipe_status = gs1.status_code '
        ||'   AND gs1.status_type IN (' ||'''700'''|| ',' ||'''900'''|| ',' ||'''400'''|| ') '
        ||'   AND gs1.delete_mark = 0 '
        ||'   AND ffe.delete_mark = 0 '
        ||'   AND ffe.validity_rule_status = gs2.status_code '
        ||'   AND gs2.status_type IN (' ||'''700'''|| ',' ||'''900'''|| ',' ||'''400'''|| ') '
        ||'   AND gs2.delete_mark = 0 '
        ||'   AND frh.delete_mark = 0 '
        ||'   AND ffm.delete_mark = 0 '
        ||'   AND nvl(hou.date_to,SYSDATE) >= SYSDATE '
        ||'   AND hou.organization_id = mp.organization_id '
        ||'   AND frh.inactive_ind = 0 '
        ||'   AND ffm.inactive_ind = 0 '
        ||'   AND grb.routing_id IS NOT NULL '
        ||'   AND ffe.organization_id IS NULL '
        ||'   AND ffe.recipe_use IN (0,1) '
        ||'   AND nvl(ffe.end_date,(SYSDATE + 1)) > SYSDATE '
        ||'   AND grb.formula_id = ffm.formula_id '
        ||'   AND ffm.formula_status = gs3.status_code '
        ||'   AND gs3.status_type IN (' ||'''700'''|| ',' ||'''900'''|| ',' ||'''400'''|| ') '
        ||'   AND gs3.delete_mark = 0 '
        ||'   AND grb.routing_id =  frh.routing_id '
        ||'   AND frh.routing_status =  gs4.status_code '
        ||'   AND gs4.status_type IN (' ||'''700'''|| ',' ||'''900'''|| ',' ||'''400'''|| ') '
        ||'   AND gs4.delete_mark = 0 '
	||'   AND mp.organization_id = msi.organization_id '
        ||'   AND mp.process_enabled_flag = ''Y'' '
        ||'   AND msi.inventory_item_id =  ffe.inventory_item_id '
	||'   AND msi.recipe_enabled_flag = ''Y'' '
	||'   AND msi.process_execution_enabled_flag = ''Y'' '
/*B5161655 - Changed the where clause to pick up even when the formula belongs to a differnt organization
from the validity rules */
        ||'   AND EXISTS ( SELECT /*+DRIVING_SITE(FM_MATL_DTL)*/ 1 '
        ||'          FROM  fm_matl_dtl'||at_apps_link||' '
        ||'          WHERE formula_id = grb.formula_id '
        ||'          AND line_type = 1 '
        ||'          AND inventory_item_id = msi.inventory_item_id '
        ||'          AND msi.organization_id = nvl(ffe.organization_id,msi.organization_id) '
        ||'          AND inventory_item_id = ffe.inventory_item_id ) '
        ||' UNION ALL '
        ||' SELECT /*+ ORDERED USE_NL(gmd_recipe_validity_rules,fm_form_mst,mtl_system_items)*/ ffe.recipe_validity_rule_id, ffe.inventory_item_id, '
        ||' grb.formula_id, msi.organization_id, '
        ||' ffe.start_date, ffe.end_date, ffe.inv_min_qty, '
        ||' ffe.inv_max_qty, ffe.preference, msi.primary_uom_code, '
        ||' mp.organization_code wcode , to_number(null) , '
        ||' NULL, to_number(null), NULL, '
        ||' NULL, to_number(null), to_number(null) prd_fct, -1 prd_ind, ' /*B2870041*/
        ||' grb.recipe_id, grb.recipe_no, grb.recipe_version ,'
        ||' 0 rhdr_loc, '
/* NAMIT_CR,SGIDUGU */
        ||' 0 calculate_step_quantity '
        ||' FROM  gmd_recipes_b'||at_apps_link||' grb,'
        ||'       gmd_recipe_validity_rules'||at_apps_link||' ffe,'
        ||'       mtl_parameters'||at_apps_link||' mp, '
        ||'       fm_form_mst'||at_apps_link||' ffm, '
        ||'       mtl_system_items'||at_apps_link||' msi,'
        ||'       hr_organization_units'||at_apps_link||' hou,'
        ||'       gmd_status_b'||at_apps_link||' gs1,'
        ||'       gmd_status_b'||at_apps_link||' gs2,'
        ||'       gmd_status_b'||at_apps_link||' gs3 '
        ||' WHERE grb.delete_mark = 0 '
        ||'   AND grb.recipe_id = ffe.recipe_id '
        ||'   AND grb.recipe_status = gs1.status_code '
        ||'   AND gs1.status_type IN (' ||'''700'''|| ',' ||'''900'''|| ',' ||'''400'''|| ') '
        ||'   AND gs1.delete_mark = 0 '
        ||'   AND ffe.delete_mark = 0 '
        ||'   AND ffe.validity_rule_status = gs2.status_code '
        ||'   AND gs2.status_type IN (' ||'''700'''|| ',' ||'''900'''|| ',' ||'''400'''|| ') '
        ||'   AND gs2.delete_mark = 0 '
        ||'   AND ffm.delete_mark = 0 '
        ||'   AND nvl(hou.date_to,SYSDATE) >= SYSDATE '
        ||'   AND hou.organization_id = mp.organization_id '
        ||'   AND ffm.inactive_ind = 0 '
        ||'   AND grb.routing_id IS NULL '
        ||'   AND ffe.organization_id IS NULL '
        ||'   AND ffe.recipe_use IN (0,1) '
        ||'   AND nvl(ffe.end_date,(SYSDATE + 1)) > SYSDATE '
        ||'   AND grb.formula_id = ffm.formula_id '
        ||'   AND ffm.formula_status = gs3.status_code '
        ||'   AND gs3.status_type IN (' ||'''700'''|| ',' ||'''900'''|| ',' ||'''400'''|| ') '
        ||'   AND gs3.delete_mark = 0 '
        ||'   AND msi.organization_id = mp.organization_id '
        ||'   AND mp.process_enabled_flag = ''Y'' '  ;
     IF l_in_str_org  IS NOT NULL THEN
         effectivity_cursor := effectivity_cursor
        ||'   AND msi.organization_id ' || l_in_str_org ;
     END IF;

         effectivity_cursor := effectivity_cursor
	   ||'   AND msi.inventory_item_id = ffe.inventory_item_id '
	||'   AND msi.recipe_enabled_flag = ''Y'' '
	||'   AND msi.process_execution_enabled_flag = ''Y'' '
/*B5161655 - Changed the where clause to pick up even when the formula belongs to a differnt organization
from the validity rules */
        ||'   AND EXISTS ( SELECT /*+DRIVING_SITE(FM_MATL_DTL)*/ 1 '
        ||'          FROM  fm_matl_dtl'||at_apps_link||' '
        ||'          WHERE formula_id = grb.formula_id '
        ||'          AND line_type = 1 '
        ||'          AND inventory_item_id = msi.inventory_item_id '
        ||'          AND msi.organization_id = nvl(ffe.organization_id,msi.organization_id) '
        ||'          AND inventory_item_id = ffe.inventory_item_id )  ) eff,'
        ||'( SELECT /*+DRIVING_SITE(gmp_form_eff)*/ organization_id, fmeff_id, '
        ||'             max(aps_fmeff_id) aps_fmeff_id '
        ||'             FROM gmp_form_eff'||at_apps_link||' '
        ||'      WHERE organization_id is NOT NULL '
        ||'      GROUP BY organization_id, fmeff_id '
        ||'    ) gfe, '
         -- B4918786 (RDP) SDS Changes
        ||' (SELECT mic.category_concat_segs, '
        ||'         mic.category_id, '
        ||'         mic.organization_id,'
        ||'         mic.inventory_item_id '
        ||'    FROM mtl_item_categories_v'||at_apps_link|| ' mic, '
        ||'         mtl_default_category_sets_fk_v'||at_apps_link|| ' cat '
        ||'   WHERE mic.category_set_id = cat.category_set_id '
        ||'     AND cat.functional_area_id = 14 '
        ||' ) scat '
        ||'WHERE eff.organization_id = gfe.organization_id (+) '
        ||' AND (eff.organization_id IS NULL OR eff.organization_id ' || l_in_str_org ||')'
        ---#6358324 KBANDDYO Added for restricting the collections from collecting unwanted inv_organizations
        ||' AND eff.recipe_validity_rule_id = gfe.fmeff_id (+) '
        ||' AND eff.inventory_item_id = scat.inventory_item_id (+) '
        ||' AND eff.organization_id = scat.organization_id (+)'
	      ||' ORDER BY 4,5  ' ;

    gmp_debug_message('Started at '|| TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'));
    gmp_debug_message('effectivity_cursor -'||effectivity_cursor);

    formula_hdr_cursor :=
        ' SELECT unique ffm.formula_id, 0, 0, 0, -1, NULL '
        ||' FROM fm_form_mst'||at_apps_link||' ffm, '
        ||'      gmd_recipes_b'||at_apps_link||' grb, '
        ||'      gmd_recipe_validity_rules'||at_apps_link||' ffe, '
        ||'      hr_organization_units'||at_apps_link||' hou, '
        ||'      gmd_status_b'||at_apps_link||' gs '
        ||' WHERE grb.recipe_id = ffe.recipe_id '
        ||'   AND ffe.validity_rule_status = gs.status_code '
        ||'   AND ( ffe.organization_id is NULL or ffe.organization_id = hou.organization_id)'
   ----B#6358324 KBANDDYO Added for restricting the collections from collecting unwanted inv_organizations
   ----B#6489338 Added the next 1 conditions as below
        ||'   AND  hou.organization_id '|| l_in_str_org
        ||'   AND gs.status_type IN (' ||'''700'''|| ',' ||'''900'''|| ',' ||'''400'''|| ') '
        ||'   AND gs.delete_mark = 0 '
        ||'   AND nvl(ffe.end_date,(SYSDATE + 1)) > SYSDATE '
        ||'   AND ffm.formula_id = grb.formula_id '
        ||'   AND ffe.delete_mark = 0 '
        ||'   AND ffm.delete_mark = 0 '
        ||' ORDER BY formula_id  ' ;

    gmp_debug_message('formula_hdr_cursor -'||formula_hdr_cursor);
    OPEN cur_formula_hdr FOR formula_hdr_cursor;
    FETCH cur_formula_hdr BULK COLLECT INTO formula_header_tab;
    formula_headers_size := formula_header_tab.COUNT;

/* PennColor Bug: 8230710
    LOOP
      FETCH cur_formula_hdr INTO formula_header_tab(formula_headers_size);
      EXIT WHEN cur_formula_hdr%NOTFOUND;
      formula_headers_size := formula_headers_size + 1;
    END LOOP;
*/
    CLOSE cur_formula_hdr;
   -- formula_headers_size := formula_headers_size -1 ;
    time_stamp;
    log_message('Formula Header size is = ' || to_char(formula_headers_size)) ;

/*B2870041 added the original um from the line and the primary um of the item
but in the OPM uom format. We will use this later for conversions */
    /* B2657068 Rajesh Patangya */
    /* B2954076 Rajesh Patangya, cursor modified */

-- =========== Formula detail selection,item substitution processing start ========================
/* Logic for item substitution - The formula details along if any substitutes defined for the ingredients
are fetched from GMD view - gmd_material_effectivities_vw. The query also fetches the lead preference
(immediate next row prefernce), lead start date and lead end dates for each susbtitute defined for the
ingredient. A flag - original_item_flag to determine whether the item is an original item or substitue
item is used in processing each record. The logic primarliy does 4 functions -
                - Fill the leading spaces with the origial item whereever needed
                - Fill in the gaps with the original item where ever applicable
                - Change the validity start/end dates of the substitue items based on their preference
                - Fill in the gaps with the susbstute items whereever applicable
A flag "ae_flag" which corresponds to the actual end date flag is set to fill the gaps with the substitue
items whereever applicable. To understand this, lets take an simple example where ingredient say "A" in
a formula is replaced with
                    ----------------------------------------------------
                    ingredient |        validity period    | preference |
                               | Start date  |  Enddate    |            |
                    -----------------------------------------------------
                 - B          | 14/06/2006  |    -        |    2       |
                 - C          | 02/08/2006  | 15/10/2006  |    1       |
                   ------------------------------------------------------
In this case there will be 3 rows based on preference
                 - B from 14/06/2006 to 02/08/2006,
                 - C from 02/08/2006 to 15/10/2006, and
                 - B from 15/10/2006 to -            (then remaining period)
So the ae_flag is set for the substitute "B" to track that this substitute is to be replaced after
15/10/2006.
And then for each ingredient/substitute their effective date and disbale date are passed on to
msc_st_bom_components table with a component sequence id generated uniquely for the substitute items
alone*/


    /*B5176291 - initialise the tables - start*/
    prev_detail_tab(1) := NULL;
    orig_detail_tab(1) := NULL;
    ae_date := NULL;
    formula_details_size := 0;

    /*Fetch current value of formula_line id into a global value . Maintiain a
    global counter that is incremented everytime */

     v_gmd_seq := 'SELECT MAX(formulaline_id) FROM fm_matl_dtl'||at_apps_link ;
     EXECUTE IMMEDIATE v_gmd_seq INTO v_gmd_formula_lineid ;

    /*B5176291 - initialise the tables - end*/
    /*B547601 added order original_item_flag in partition stmt */
    /* bug: 6087535 Vpedarla 23-07-07 FP :11.5.10 - 12.0.3 : ITEM SUBSTITUTION EFFECTIVITY IS NOT COLLECTED.
    Changed the formula_dtl_cursor and later processing for better item substitution funtionality.
    */

    formula_dtl_cursor :=
         '  SELECT ffm.formula_id, '
       ||'  ffm.formula_no, '
       ||'  ffm.formula_vers, '
       ||'  ffm.formula_desc1, '
       ||'  ((fmd.formulaline_id * 2) + 1) x_formulaline_id, '
       ||'  fmd.line_type, '
       ||'  fmd.item_id inventory_item_id, '
       ||'  decode(fmd.original_item_flag,1,fmd.qty,(( fmd.sub_replace_qty / fmd.sub_original_qty) * fmd.line_item_qty)) formula_qty, '
       /*B5176291 - for substitute items fmd.qty will be null, in those case subsittute qty should be used*/
       ||'  fmd.scrap_factor , '
       ||'  fmd.scale_type, '
       ||'  fmd.contribute_yield_ind, '
                   ||'  decode(fmd.line_type, -1, decode(nvl(fmd.contribute_step_qty_ind, '''||'N'||''''||'),'    -- venu
                   ||    ''''||'Y'||''''||',1,2), 1) contribute_step_qty_ind,'                                    -- venu
       ||'  DECODE(fmd.phantom_type,0,null,6) phantom_type, '
       ||'  msi.primary_uom_code, '  -- venu
       ||'  fmd.item_um detail_uom, '  -- venu
  -- Bug: 7348022 Vpedarla changed below line of code
       ||'  DECODE(fmd.scale_type,2,4,fmd.scale_type) bom_scale_type, '
  --       ||'  DECODE(fmd.scale_type,0,0,1,2) bom_scale_type, '
       ||'  DECODE(fmd.item_um,msi.primary_uom_code,decode(fmd.original_item_flag,1,fmd.qty,((fmd.sub_replace_qty / fmd.sub_original_qty) * fmd.line_item_qty)), '
       ||'        inv_convert.inv_um_convert'||at_apps_link
       ||'                  ( fmd.item_id, '
       ||'                   NULL,msi.organization_id, '
      /* bug: 6918852 Vpedarla 04-Apr-2008  used the global variable for precision*/
       /* ||'                   NULL, '  */
        ||                    conv_precision || ' , '
       ||'                   decode(fmd.original_item_flag,1,fmd.qty,((fmd.sub_replace_qty / fmd.sub_original_qty) * fmd.line_item_qty)), '
       ||'                   fmd.item_um , '
       ||'                   msi.primary_uom_code , '
       ||'                   NULL ,NULL )) primary_qty, '
       ||'  DECODE(fmd.item_um,msi.primary_uom_code, decode(fmd.original_item_flag,1,fmd.scale_multiple,((fmd.sub_replace_qty / fmd.sub_original_qty) * fmd.line_item_qty)), '
       ||'        inv_convert.inv_um_convert'||at_apps_link
       ||'                  ( fmd.item_id, '
       ||'                   NULL,msi.organization_id, '
        ||                    conv_precision || ' , '
       ||'                   decode(fmd.original_item_flag,1,fmd.scale_multiple,((fmd.sub_replace_qty / fmd.sub_original_qty) * fmd.line_item_qty)), '
       ||'                   fmd.item_um , '
       ||'                   msi.primary_uom_code , '
       ||'                   NULL ,NULL )) scale_multiple, '
     /*  ||'  fmd.scale_multiple, '  */ /* Bug 8529867 Vpedarla */
       ||'  (fmd.scale_rounding_variance * 100) scale_rounding_variance, '   -- venu multipied it by 100
       ||'  decode(fmd.rounding_direction,1,2,2,1,fmd.rounding_direction) ,'
       ||'  fmd.release_type, '
       ||'  fmd.original_item_flag, '
       ||'  fmd.start_date, '
       ||'  fmd.end_date, '
       ||'  fmd.formulaline_id formula_line_id , '
       ||'  fmd.preference  '
--       ||'  null actual_end_date ,'
--       ||'  0 actual_end_flag '
       ||'  FROM  gmd_material_effectivities_vw'||at_apps_link||' fmd,'
       ||'        fm_form_mst'||at_apps_link||' ffm, '
       ||'        mtl_system_items'||at_apps_link||' msi '
       ||'  WHERE msi.inventory_item_id = fmd.item_id  '
       ||'  AND msi.organization_id = fmd.organization_id '
       ||'  AND ffm.formula_id = fmd.formula_id '
       ||'  AND ffm.formula_id IN ( select /*+ DRIVING_SITE(grb) DRIVING_SITE(ffe) DRIVING_SITE(gs) */ unique grb.formula_id '            -- #6358324 KBANDDYO Added Where clause for restricting the collections from collecting unwanted inv_organizations
       ||'                  FROM  gmd_recipes_b'||at_apps_link ||' grb,  '
       ||'                      gmd_recipe_validity_rules'||at_apps_link ||'  ffe, '
       ||'                      hr_organization_units'||at_apps_link ||'  hou, '
       ||'                      gmd_status_b'||at_apps_link ||' gs '
       ||'                  WHERE grb.recipe_id = ffe.recipe_id '
    ----B#6489338 Added the next 3 conditions as below and commented the above clause
       ||'                  AND ( ffe.organization_id is NULL or ffe.organization_id = hou.organization_id )'
       ||'                  AND  hou.organization_id '|| l_in_str_org
       ||'                  AND ffe.recipe_use in (0,1)'
       ||'                  AND ffe.validity_rule_status = gs.status_code    '
       ||'                  AND gs.status_type IN (' ||'''700'''|| ',' ||'''900'''|| ')'
       ||'                  AND gs.delete_mark = 0   '
       ||'                  AND nvl(ffe.end_date,(SYSDATE + 1)) > SYSDATE   '
       ||'                  AND ffe.delete_mark = 0 )'
       ||'  AND ffm.delete_mark = 0 '
       ----B#6489338 Added the next condition as below
       ||'  AND msi.organization_id '|| l_in_str_org
       ||'  AND nvl(fmd.qty,fmd.sub_replace_qty)  <> 0'
       ||'  AND ( fmd.qty <> 0 OR (( fmd.sub_replace_qty / fmd.sub_original_qty) * fmd.line_item_qty) <> 0) '
       ||'  ORDER BY ffm.formula_id ,fmd.line_type, fmd.formulaline_id, ' /* PennColor 13Feb fmd.line_no, vpedarla Bug: 7652265 */
       ||'  fmd.original_item_flag desc,fmd.start_date,fmd.preference ';

    gmp_debug_message('formula_dtl_cursor -'||formula_dtl_cursor);
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
	        enddatenull := FALSE; -- Bug: 6030499 Vpedarla forward port of 11.5.9 bug 6047372.
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
	        formula_detail_tab(formula_details_size).inventory_item_id := orig_detail_tab(1).inventory_item_id;
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
	               subst_tab(substcount).inventory_item_id := orig_detail_tab(1).inventory_item_id;
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


    time_stamp ;
    log_message('Formula detail size is = ' || to_char(formula_details_size)) ;
-- =========== Formula detail selection,item substitution processing end ========================

-- =========== rtg offset data selection start ========================
   rtg_offset_cur_stmt := ' SELECT '||
		' gro.organization_id, '||
		' gro.fmeff_id, '||
		' gro.formula_id, '||
		' gro.routingstep_id, '||
		' gro.start_offset, '||
		' gro.end_offset, '||
		' (rsm.formulaline_id *2 )+ 1'||
		' FROM '||
		'      gmd_recipe_step_materials'||at_apps_link||' rsm, '||
		'      gmp_routing_offsets'||at_apps_link||' gro '||
		' WHERE '||
		'       gro.recipe_id = rsm.recipe_id '||
		'   AND gro.routingstep_id = rsm.routingstep_id '||
		' ORDER BY gro.formula_id,gro.organization_id, rsm.formulaline_id ' ;

    gmp_debug_message('rtg_offset_cur_stmt -'||rtg_offset_cur_stmt);

    OPEN cur_rtg_offsets  FOR rtg_offset_cur_stmt ;
    FETCH cur_rtg_offsets BULK COLLECT INTO rstep_offsets;

    rtg_offsets_size := rstep_offsets.COUNT;

/* PennColor Bug: 8230710
    LOOP
      FETCH cur_rtg_offsets INTO rstep_offsets(rtg_offsets_size);
      EXIT WHEN cur_rtg_offsets%NOTFOUND;

      rtg_offsets_size := rtg_offsets_size + 1;
    END LOOP;
*/

    CLOSE cur_rtg_offsets;

 --   rtg_offsets_size := rtg_offsets_size -1 ;
    time_stamp ;
    log_message('Routing Offsets size is = ' || to_char(rtg_offsets_size)) ;

-- =========== rtg offset data selection end ========================

-- Vpedarla 7391495
-- =========== rtg operation lead time selection start ========================
   oper_lead_time_cur_stmt := ' SELECT '||
                ' gro.organization_id, '||
                ' gro.fmeff_id, '||
                ' gro.formula_id, '||
                ' gro.routing_id, '||
                ' gro.routingstep_id, '||
                ' gro.start_offset, '||
                ' gro.end_offset '||
                ' FROM gmp_routing_offsets'||at_apps_link||' gro '||
                ' ORDER BY gro.fmeff_id, gro.organization_id , gro.routingstep_id ' ;

    gmp_debug_message('oper_lead_time_cur_stmt -'||oper_lead_time_cur_stmt);
  oper_leadtime_size := 1;
    OPEN cur_oper_lead_time  FOR oper_lead_time_cur_stmt ;
    FETCH cur_oper_lead_time BULK COLLECT INTO oper_leadtime_percent;
    oper_leadtime_size := oper_leadtime_percent.COUNT;
/*  PennColor Bug: 8230710
    LOOP
      FETCH cur_oper_lead_time INTO oper_leadtime_percent(oper_leadtime_size);
      EXIT WHEN cur_oper_lead_time%NOTFOUND;
        oper_leadtime_size := oper_leadtime_size + 1;
    END LOOP;
*/
    CLOSE cur_oper_lead_time;

   -- oper_leadtime_size := oper_leadtime_size -1 ;
    time_stamp ;
    log_message('Routing operations Lead time size is = ' || to_char(oper_leadtime_size)) ;

-- =========== rtg operation lead time selection end ========================



    -- Validate formula for uom conversion, for planned items
    validate_formula ;

    routing_hdr_cursor :=
                     ' SELECT unique frh.routing_id, mp.organization_id, '
/* NAMIT_CR 2 more zeros added for Linking Step Dependency to Routing Header */
                   ||'        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 '
                   ||' FROM mtl_parameters'||at_apps_link||' mp, '
                   ||'      fm_rout_hdr'||at_apps_link||' frh, '
                   ||'      gmd_recipes_b'||at_apps_link||' grb, '
                   ||'      gmd_recipe_validity_rules'||at_apps_link||' ffe, '
		   ||'      hr_organization_units'||at_apps_link||' hou,'
                   ||'      gmd_status_b'||at_apps_link||' gs '
                   ||' WHERE grb.recipe_id = ffe.recipe_id '
                   ||'   AND ffe.validity_rule_status = gs.status_code '
                   ||'   AND gs.status_type IN (' ||'''700'''|| ',' ||'''900'''|| ',' ||'''400'''|| ') '
                   ||'   AND gs.delete_mark = 0 '
                   ||'   AND nvl(ffe.end_date,(SYSDATE + 1)) > SYSDATE '
                   ||'   AND frh.routing_id = grb.routing_id '
                   ||'   AND nvl(hou.date_to,SYSDATE) >= SYSDATE '
                   ||'   AND hou.organization_id = mp.organization_id '
                   ||'   AND nvl(ffe.organization_id, mp.organization_id) = mp.organization_id'
		   ||'   AND mp.process_enabled_flag = ''Y''' ;
            IF l_in_str_org  IS NOT NULL THEN
               routing_hdr_cursor := routing_hdr_cursor
	           ||' AND mp.organization_id ' || l_in_str_org ;
            END IF;

         routing_hdr_cursor := routing_hdr_cursor
                   ||'   AND ffe.delete_mark = 0 '
                   ||'   AND frh.delete_mark = 0 '
                   ||'   AND frh.inactive_ind = 0 '
                   ||' ORDER BY frh.routing_id, mp.organization_id ' ;

    gmp_debug_message('routing_hdr_cursor -'||routing_hdr_cursor);

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

    /*  Select All the Sequence Dependent Changeover for oprn_id <> -1 */
   setup_id_cursor :=
          ' SELECT oprn_id, '
              ||'  category_id,   '
              ||'  seq_dep_id   '
              ||'  FROM  gmp_sequence_types'||at_apps_link||' gst  '
              ||'  WHERE oprn_id <> -1  '
              ||'  ORDER BY oprn_id,category_id  ' ;

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
     log_message('Sequence Dependent Changeover size is = ' || to_char(setup_size)) ;

    routing_dtl_cursor :=
          ' SELECT frd.routing_id, '
              ||'  crd.organization_id, '
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
              ||'  fom.process_qty_uom,'  -- akaruppa previously sou2.uom_code
              ||'  goa.activity, '
              ||'  goa.oprn_line_id, '
              ||'  gor.resource_count, '
              ||'  gor.resource_usage, '
              ||'  gor.resource_usage_uom, '  -- akaruppa previously gor.usage_um
              ||'  gor.scale_type,'
              ||'  goa.offset_interval, '
              ||'  crd.resource_id, '
              ||'  ((crd.resource_id * 2) + 1) x_resource_id, '
              ||'  DECODE(gor.scale_type,0,2,1,1,2,3) , ' /* B2967464 */
              ||'  goa.activity_factor, '
              ||'  gor.process_qty, '
              ||'  NVL(goa.material_ind,0), '
              ||'  1 , '
              ||'  SUM(NVL(goa.material_ind,0))  OVER (PARTITION BY '
              ||'  frd.routing_id, crd.organization_id, frd.routingstep_no) mat_found,'
              ||'  1, ' /* flag for including rows */
              ||'  decode(goa.break_ind,NULL,2,0,2,1,1) brk_ind'
              ||' ,-1, -1, -1, -1, -1, -1, '
         -- B4918786 (RDP) SDS
              ||' (SUM(DECODE(NVL(goa.sequence_dependent_ind,0),1,1,0)) OVER '
              ||' (PARTITION BY '
              ||' frd.routing_id, crd.organization_id)) is_sds_rout,'
              ||' DECODE(NVL(goa.sequence_dependent_ind,0),1,DECODE(gor.prim_rsrc_ind,1,1,0),0) is_unique, '
              ||' DECODE(NVL(goa.sequence_dependent_ind,0),1,0,DECODE(gor.prim_rsrc_ind,1,1,0)) is_nonunique, '
              ||' NULL setup_id '
              ||' FROM  cr_rsrc_dtl'||at_apps_link||' crd, '
              ||'       fm_rout_dtl'||at_apps_link||' frd, '
              ||'       gmd_operations'||at_apps_link||' fom, '
              ||'       gmd_operation_activities'||at_apps_link||' goa, '
              ||'       gmd_operation_resources'||at_apps_link||' gor, '
	      ||'       hr_organization_units'||at_apps_link||' hou1, '
              ||'       mtl_units_of_measure'||at_apps_link||' mum, '
/*sowmya added - operation process qty should be verified with the uom master*/
              ||'       mtl_units_of_measure'||at_apps_link||' mum2 '
	   ----B#6489338 Added the next where condition as below
              ||' WHERE frd.routing_id in (  SELECT distinct routing_id '
              ||'            FROM  gmd_recipes'||at_apps_link ||' grb ,'
              ||'                  gmd_recipe_validity_rules'||at_apps_link ||' ffe ,'
              ||'                  hr_organization_units'||at_apps_link ||' hou ,'
              ||'                  gmd_status_b'||at_apps_link ||' gs '
              ||'            WHERE grb.recipe_id = ffe.recipe_id'
              ||'              AND ffe.validity_rule_status = gs.status_code '
              ||'              AND ffe.recipe_use in ( 0,1 )'
              ||'              AND gs.status_type IN (' ||'''700'''|| ',' ||'''900'''|| ')'
              ||'              AND gs.delete_mark = 0 '
              ||'              AND ( ffe.organization_id is NULL or ffe.organization_id = hou.organization_id )'
              ||'              AND hou.organization_id '|| l_in_str_org
              ||'              AND nvl(ffe.end_date,(SYSDATE + 1)) > SYSDATE  )'
	      ||'   AND frd.oprn_id = fom.oprn_id '
              ||'   AND fom.oprn_id = goa.oprn_id '
              ||'   AND goa.oprn_line_id = gor.oprn_line_id '
/* NAMIT_RD */
              ||'   AND crd.resources = gor.resources '
     ----B#6489338 Added the next 2 conditions as below
              ||'   AND hou1.organization_id '|| l_in_str_org
	      ||'   AND crd.organization_id = hou1.organization_id'
              ||'   AND mum.uom_code = gor.resource_usage_uom '
              ||'   AND mum2.uom_code = fom.process_qty_uom ' --sowmya added
              ||'   AND fom.delete_mark = 0 '
              ||'   AND goa.activity_factor > 0 '
              ||'   AND mum.uom_class = :gmp_uom_class '
/* NAMIT_RD */
              ||' ORDER BY  '
              ||'         1, 2, 3, 4, 5, 6 ';
/*
              ||' ORDER BY frd.routing_id,  '
              ||'          crd.orgn_code,  '
              ||'          frd.routingstep_no, '
              ||'          NVL(goa.sequence_dependent_ind,0) DESC, '
              ||'          goa.offset_interval,'
              ||'          goa.activity, '
              ||'          goa.oprn_line_id, '
              ||'          gor.prim_rsrc_ind, '
              ||'          gor.resources '; */

    gmp_debug_message('routing_dtl_cursor -'||routing_dtl_cursor);
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
         old_orgn_id <> rtg_org_dtl_tab(ri).organization_id OR
         old_step <> rtg_org_dtl_tab(ri).routingstep_no THEN

        found := 0;
        /* NAMIT_OC */
        found_chrg_rsrc := 0;
        chrg_activity   := NULL;
        first_step_row := ri;

        old_route := rtg_org_dtl_tab(ri).routing_id;
        old_orgn_id := rtg_org_dtl_tab(ri).organization_id;
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
              ||'  NVL(goa.sequence_dependent_ind,0), '
              ||'  DECODE(gor.prim_rsrc_ind, 1,1,2,2,0,3), ' /* This will ensure that ordering will
                                                                always have primary firsr*/
              ||'  gor.resources, '
              ||'  frd.routingstep_id, '
              ||'  fom.oprn_no, '
              ||'  goa.oprn_line_id, '
              ||'  goa.activity, '
              ||'  gor.prim_rsrc_ind, '
              ||'  goa.offset_interval, '
              ||'  gor.resource_usage_uom, ' -- akaruppa changed sou.uom_code to gor.resource_usage_uom
              ||'  decode(crm.capacity_constraint,1,1,2) ' -- akaruppa added to check if resource is chargeable, used for invalidating the routing if chargeable resource is not defined at the org level
              ||' FROM  fm_rout_dtl'||at_apps_link||' frd, '
              ||'       gmd_operations'||at_apps_link||' fom, '
              ||'       gmd_operation_activities'||at_apps_link||' goa, '
              ||'       gmd_operation_resources'||at_apps_link||' gor, '
              ||'       cr_rsrc_mst'||at_apps_link||' crm, '
              ||'       mtl_units_of_measure'||at_apps_link||' mum '
             ----B#6489338 Added the next where condition as below
              ||' WHERE frd.routing_id in (  SELECT distinct grb.routing_id '
              ||'            FROM  gmd_recipes'||at_apps_link ||' grb ,'
              ||'                  gmd_recipe_validity_rules'||at_apps_link ||' ffe ,'
              ||'                  hr_organization_units'||at_apps_link ||' hou ,'
              ||'                  gmd_status_b'||at_apps_link ||' gs '
              ||'            WHERE grb.recipe_id = ffe.recipe_id'
              ||'              AND ffe.validity_rule_status = gs.status_code '
              ||'              AND ffe.recipe_use in ( 0,1 )'
              ||'              AND gs.status_type IN (' ||'''700'''|| ',' ||'''900'''|| ')'
              ||'              AND gs.delete_mark = 0 '
              ||'              AND ( ffe.organization_id is NULL or ffe.organization_id = hou.organization_id )'
              ||'              AND hou.organization_id '|| l_in_str_org
              ||'              AND nvl(ffe.end_date,(SYSDATE + 1)) > SYSDATE  )'
              ||'   AND frd.oprn_id = fom.oprn_id '
              ||'   AND fom.oprn_id = goa.oprn_id '
              ||'   AND gor.resources = crm.resources '
              ||'   AND fom.delete_mark = 0'
              ||'   AND goa.oprn_line_id = gor.oprn_line_id '
              ||'   AND mum.uom_code = gor.resource_usage_uom '
              ||'   AND mum.uom_class = :gmp_uom_class '
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

    gmp_debug_message('validation_statement -'||validation_statement);
    OPEN cur_routing_dtl FOR validation_statement USING g_gmp_uom_class;
    FETCH cur_routing_dtl BULK COLLECT INTO rtg_gen_dtl_tab;
    rtg_gen_dtl_size := rtg_gen_dtl_tab.count;
/* PennColor Bug: 8230710
    LOOP
      FETCH cur_routing_dtl INTO rtg_gen_dtl_tab(rtg_gen_dtl_size);
      EXIT WHEN cur_routing_dtl%NOTFOUND;
      rtg_gen_dtl_size := rtg_gen_dtl_size + 1;
    END LOOP;
*/

    CLOSE cur_routing_dtl;
--    rtg_gen_dtl_size := rtg_gen_dtl_size -1 ;
    time_stamp ;
    log_message('Generic Routing size is = ' || to_char(rtg_gen_dtl_size)) ;

            recipe_orgn_statement := ' SELECT '
               ||'  grb.routing_id, gc.organization_id, '
               ||'  gc.routingstep_id, gc.oprn_line_id, gc.recipe_id, '
               ||'  gc.activity_factor, '
               ||'  gc.resources, gc.resource_usage, gc.process_qty, '
               ||'  gc.min_capacity, gc.max_capacity  '
               ||' FROM gmd_recipes'||at_apps_link||' grb, '
               ||'      gmd_status_b'||at_apps_link||' gs, ' /* B5114783*/
               ||' ( '
               ||' SELECT '
               ||'  gor.recipe_id, '
               ||'  gor.organization_id, '
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
               ||'   AND gor.organization_id = goa.organization_id '
               ||'   AND gor.oprn_line_id = goa.oprn_line_id '
               ||'   AND gor.routingstep_id = goa.routingstep_id '
               ||' UNION ALL '
               ||' SELECT goa.recipe_id, '
               ||'  goa.organization_id, '
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
               ||'         AND gor.organization_id = goa.organization_id '
               ||'         AND gor.oprn_line_id = goa.oprn_line_id '
               ||'         AND gor.routingstep_id = goa.routingstep_id ) '
               ||' UNION ALL '
               ||' SELECT gor.recipe_id, '
               ||'  gor.organization_id, '
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
               ||'         AND goa.organization_id = gor.organization_id '
               ||'         AND goa.oprn_line_id = gor.oprn_line_id '
               ||'         AND goa.routingstep_id = gor.routingstep_id ) '
               ||' ) gc '
               ||' WHERE grb.recipe_id = gc.recipe_id '
               ||'   AND grb.delete_mark = 0 '
            /* B5114783 start */
               ||'   AND grb.recipe_status =  gs.status_code '
               ||'   AND gs.status_type IN (' ||'''700''' || ',' || '''900''' || ',' || '''400'''|| ') '
               ||'   AND gs.delete_mark = 0 '
            /* B5114783 End */
              ||'     AND grb.recipe_id  in (  SELECT distinct  grb.recipe_id '
              ||'            FROM  gmd_recipes'||at_apps_link ||' grb ,'
              ||'                  gmd_recipe_validity_rules'||at_apps_link ||' ffe ,'
              ||'                  hr_organization_units'||at_apps_link ||' hou ,'
              ||'                  gmd_status_b'||at_apps_link ||' gs '
              ||'            WHERE grb.recipe_id = ffe.recipe_id'
              ||'              AND ffe.validity_rule_status = gs.status_code '
              ||'              AND ffe.recipe_use in ( 0,1 )'
              ||'              AND gs.status_type IN  (' ||'''700''' || ',' || '''900''' || ',' || '''400'''|| ') '
              ||'              AND gs.delete_mark = 0 '
              ||'              AND ( ffe.organization_id is NULL or ffe.organization_id = hou.organization_id )'
              ||'              AND hou.organization_id '|| l_in_str_org
              ||'              AND nvl(ffe.end_date,(SYSDATE + 1)) > SYSDATE  )'
               ||' ORDER BY 1,2,3,4,5 ' ;

    gmp_debug_message('recipe_orgn_statement -'||recipe_orgn_statement);
    OPEN c_recipe_orgn FOR recipe_orgn_statement;
/* PennColor Bug: 8230710
    LOOP
      FETCH c_recipe_orgn INTO rcp_orgn_override(recipe_orgn_over_size);
      EXIT WHEN c_recipe_orgn%NOTFOUND;
      recipe_orgn_over_size := recipe_orgn_over_size + 1;
    END LOOP;
  */
   FETCH c_recipe_orgn BULK COLLECT INTO rcp_orgn_override;
   recipe_orgn_over_size := rcp_orgn_override.COUNT;

    CLOSE c_recipe_orgn;

    --recipe_orgn_over_size := recipe_orgn_over_size -1 ;
    time_stamp ;
    log_message('recipe_orgn_over_size is= '|| to_char(recipe_orgn_over_size));

    recipe_statement :=
                 ' SELECT grb.routing_id, grs.routingstep_id, grs.recipe_id, '
               ||'        grs.step_qty '
               ||' FROM gmd_recipes'||at_apps_link||' grb, '
               ||'      gmd_status_b'||at_apps_link||' gs, ' /* B5114783*/
               ||'      gmd_recipe_routing_steps'||at_apps_link||' grs, '
               ||'      fm_rout_dtl'||at_apps_link||' frd '
               ||' WHERE grb.recipe_id = grs.recipe_id '
               ||'   AND grb.delete_mark = 0 '
            /* B5114783 start */
               ||'   AND grb.recipe_status =  gs.status_code '
               ||'   AND gs.status_type IN (' ||'''700''' || ',' || '''900''' || ',' || '''400'''|| ') '
               ||'   AND gs.delete_mark = 0 '
            /* B5114783 End */
             /* PennColor Bug: 8230710 */
                        ----B#6489338 Added the next where condition as below
              ||'     AND  grs.recipe_id  in (  SELECT distinct  grb.recipe_id '
              ||'            FROM  gmd_recipes'||at_apps_link ||' grb ,'
              ||'                  gmd_recipe_validity_rules'||at_apps_link ||' ffe ,'
              ||'                  hr_organization_units'||at_apps_link ||' hou ,'
              ||'                  gmd_status_b'||at_apps_link ||' gs '
              ||'            WHERE grb.recipe_id = ffe.recipe_id'
              ||'              AND ffe.validity_rule_status = gs.status_code '
              ||'              AND ffe.recipe_use in ( 0,1 )'
              ||'              AND gs.status_type IN  (' ||'''700''' || ',' || '''900''' || ',' || '''400'''|| ') '
              ||'              AND gs.delete_mark = 0 '
              ||'              AND ( ffe.organization_id is NULL or ffe.organization_id = hou.organization_id )'
              ||'              AND hou.organization_id '|| l_in_str_org
              ||'              AND nvl(ffe.end_date,(SYSDATE + 1)) > SYSDATE  )'
              ||'              AND grb.routing_id = frd.routing_id  '
              ||'              AND  grs.routingstep_id = frd.routingstep_id '
      -- Bug: 8354988 removed the below condition as routing step qty and recipe override though equal
      --  will not imply the same meaning. recipe overrides are the scaled values basing on formula total output and routing qty
           --   ||'       AND grs.step_qty <> frd.step_qty '
    --  Bug: 8354988  modified the order by clause from 1,2,3 to 1,3,2
               ||' ORDER BY 1,3,2 ' ;

    gmp_debug_message('recipe_statement -'||recipe_statement);
    OPEN c_recipe_override FOR recipe_statement ;
     FETCH c_recipe_override BULK COLLECT INTO recipe_override;
/* PennColor Bug: 8230710
    LOOP
      FETCH c_recipe_override INTO recipe_override(recipe_override_size);
      EXIT WHEN c_recipe_override%NOTFOUND;
      recipe_override_size := recipe_override_size + 1;
    END LOOP;
 */
    CLOSE c_recipe_override;
 --   recipe_override_size := recipe_override_size -1 ;
    recipe_override_size := recipe_override.COUNT;
    time_stamp ;
    log_message('recipe Override size is = '||to_char(recipe_override_size)) ;

     /* Alternate Resource selection   */
     /* B5688153, Rajesh Patangya prod spec alt*/
        statement_alt_resource :=
                     ' SELECT pcrd.resource_id, acrd.resource_id, '
                   ||' acrd.min_capacity, acrd.max_capacity, '
                   ||' cam.runtime_factor, '
/*prod spec alt*/  ||' nvl(cam.preference,-1), nvl(prod.inventory_item_id,-1)   '
                   ||' FROM  cr_rsrc_dtl'||at_apps_link||' acrd, '
                   ||'       cr_rsrc_dtl'||at_apps_link||' pcrd, '
                   ||'       cr_ares_mst'||at_apps_link||' cam, '
                   ||'       gmp_altresource_products'||at_apps_link||' prod'
                   ||' WHERE cam.alternate_resource = acrd.resources '
                   ||'   AND cam.primary_resource = pcrd.resources '
                   ||'   AND acrd.organization_id = pcrd.organization_id '
                   ||'   AND cam.primary_resource = prod.primary_resource(+) '
                   ||'   AND cam.alternate_resource = prod.alternate_resource(+) '
                   ||'   AND acrd.delete_mark = 0  '
                   ||'   AND pcrd.delete_mark = 0  '
                   ||' ORDER BY pcrd.resource_id, '
                   ||' DECODE(cam.preference,NULL,cam.runtime_factor,cam.preference),'
                   ||' prod.inventory_item_id ' ;

    gmp_debug_message('statement_alt_resource -'||statement_alt_resource);

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
    FETCH cur_opr_stpdep BULK COLLECT INTO gmp_opr_stpdep_tbl;
    opr_stpdep_size := gmp_opr_stpdep_tbl.COUNT;

/* PennColor Bug: 8230710
    LOOP
      FETCH cur_opr_stpdep INTO gmp_opr_stpdep_tbl(opr_stpdep_size);
      EXIT WHEN cur_opr_stpdep%NOTFOUND;
      opr_stpdep_size := opr_stpdep_size + 1;
    END LOOP;
*/

    CLOSE cur_opr_stpdep;
--    opr_stpdep_size := opr_stpdep_size -1 ;
    time_stamp ;
    log_message('Operation Step Dependency size is = ' || to_char(opr_stpdep_size)) ;

    /* ------------------------------------------------------- */
    /* PROCESSING STARTS AFTER SELECTION OF THE DATA IN MEMORY */
    /* ------------------------------------------------------- */

    -- Link the routing header and detail
    link_routing ;

    -- Link the routing header and detail overrides
    link_override_routing ;

/* Now spool the routing Header data for debugging */
  gmp_debug_message('Routing org details for debug purpose ');
  gmp_debug_message('RTG_ID Org Valid GStart GEnd OStart OEnd StStart StEND UsgSt UsgEnd StpDepSt StpDepEnd ');
  IF (l_debug = 'Y') THEN
  For spl_cnt in 1..rtg_org_hdr_tab.COUNT
  LOOP
     gmp_debug_message ( rtg_org_hdr_tab(spl_cnt).routing_id ||'*'||
     rtg_org_hdr_tab(spl_cnt).organization_id    ||'**'||
     rtg_org_hdr_tab(spl_cnt).valid_flag         ||'**'||
     rtg_org_hdr_tab(spl_cnt).generic_start_loc  ||'**'||
     rtg_org_hdr_tab(spl_cnt).generic_end_loc    ||'**'||
     rtg_org_hdr_tab(spl_cnt).orgn_start_loc     ||'**'||
     rtg_org_hdr_tab(spl_cnt).orgn_end_loc       ||'**'||
     rtg_org_hdr_tab(spl_cnt).step_start_loc     ||'**'||
     rtg_org_hdr_tab(spl_cnt).step_end_loc       ||'**'||
     rtg_org_hdr_tab(spl_cnt).usage_start_loc    ||'**'||
     rtg_org_hdr_tab(spl_cnt).usage_end_loc      ||'**'||
     rtg_org_hdr_tab(spl_cnt).stpdep_start_loc   ||'**'||
     rtg_org_hdr_tab(spl_cnt).stpdep_end_loc );
  END LOOP ;
  END IF;


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
              ||'   fmd.inventory_item_id, frd.routingstep_no, '
              || '   DECODE(fmd.detail_uom, msi.primary_uom_code, 1, ' -- akaruppa previously DECODE(fmd.item_um, gia.item_um,1,
              ||'        inv_convert.inv_um_convert'||at_apps_link  -- akaruppa previously GMICUOM.uom_conversion
              ||'                 (fmd.inventory_item_id, '
              ||'                  NULL, '
              ||'                  msi.organization_id, '
      /* bug: 6918852 Vpedarla 04-Apr-2008  used the global variable for precision*/
           /* ||'                   NULL, '  */
              ||                    conv_precision || ' , '
              ||'                  1, '
              ||'                  fmd.detail_uom , '
              ||'                  msi.primary_uom_code , '
              ||'                  NULL , '
              ||'                  NULL '
              ||'                 ) '
              ||'         ) uom_conv_factor, '
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
              ||'       mtl_system_items'||at_apps_link||' msi'
              ||' WHERE fmd.formulaline_id = frm.formulaline_id '
              ||'   AND msi.organization_id = fmd.organization_id '
              ||'   AND frm.recipe_id = r.recipe_id '  /* B3054460 */
              ||'   AND (fmd.release_type in (1,2,3) OR '  /* B3054460 */
              ||' NVL(r.calculate_step_quantity,0) = 1 ) '  /* xfer for ASQC */
/* NAMIT_MTQ */
              ||'   AND frd.routingstep_id = frm.routingstep_id '
              ||'   AND msi.inventory_item_id = fmd.inventory_item_id '
/* B3970993 nsinghi. Changed order by clause from 1,2,3,4,5 to 1,2,3,6,7 */
              ||' ORDER BY 1,2,3,4,6,7 ';
        /*      ||' ORDER BY 1,2,3,6,7 ';
 B7461010 change order by clause to consider the product formulaline come
  first, if multiple co-products are present Or same product is used multiple
times as coproducts */

    gmp_debug_message('mat_assoc_cursor -'||mat_assoc_cursor);
    OPEN cur_mat_assoc FOR mat_assoc_cursor ;
    FETCH cur_mat_assoc BULK COLLECT INTO mat_assoc_tab;
    material_assocs_size := mat_assoc_tab.COUNT;
/* PennColor Bug: 8230710
    LOOP
      FETCH cur_mat_assoc INTO mat_assoc_tab(material_assocs_size);
      EXIT WHEN cur_mat_assoc%NOTFOUND;
      material_assocs_size := material_assocs_size + 1;
    END LOOP;
*/
    CLOSE cur_mat_assoc;
--    material_assocs_size := material_assocs_size -1 ;
    time_stamp ;
    log_message('Material assoc size is = ' || to_char(material_assocs_size)) ;

 -- The cursor for effectivity opened and then the details processed
 l_eff_counter := 0;
 OPEN c_formula_effectivity FOR effectivity_cursor;

  LOOP
  FETCH c_formula_effectivity INTO effectivity;
  EXIT WHEN c_formula_effectivity%NOTFOUND;
  l_eff_counter := l_eff_counter + 1;
   IF ((effectivity.formula_id <> old_formula_id) OR
       (effectivity.organization_id <> old_organization_id) OR
       (effectivity.fmeff_id <> old_fmeff_id)
      )  THEN   /* Old values */

gmp_debug_message('processing fmeff_id -'|| effectivity.fmeff_id||' aps_fmeff_id -'||effectivity.aps_fmeff_id);
    valid := check_formula(effectivity.organization_id, effectivity.formula_id);

    IF not valid THEN
      log_message('check_formula returned Invalid for Organization_id '||
         effectivity.organization_id||' formula_id '||effectivity.formula_id) ;
    END IF;

   /* routing check for effectivity */
    IF (valid) AND effectivity.routing_id IS NOT NULL THEN
        /* Locate_org_routing through Bsearch */
        gmp_debug_message('calling find_routing_header');
         valid := find_routing_header (effectivity.routing_id,
                                       effectivity.organization_id);

       IF not valid THEN
        log_message('find_routing_header returned Invalid for Organization_id '||
           effectivity.organization_id||' routing_id '||effectivity.routing_id) ;
       END IF;

       IF (valid) AND effectivity.rtg_hdr_location > 0 AND
                      effectivity.routing_qty >= 0 THEN

           g_setup_id  := NULL; -- B4918786 (RDP) SDS
           sd_index    := 0 ;  -- B4918786 (RDP) SDS

         gmp_debug_message('calling validate_routing - '||effectivity.fmeff_id);
         IF (l_debug = 'Y') then
              time_stamp;
         END IF;

           validate_routing( effectivity.routing_id,
                             effectivity.organization_id,
                             effectivity.rtg_hdr_location,
                             routing_valid);

         IF (l_debug = 'Y') then
              time_stamp;
         END IF;

            IF (routing_valid) THEN /* Valid routing  */
                  valid := TRUE ;
             ELSE
                  valid := FALSE ;
                 LOG_MESSAGE('validate_routing returned Invalid for Organization_id '||
                   effectivity.organization_id||' routing_id '||effectivity.routing_id||
                   ' rtg_hdr_location '||effectivity.rtg_hdr_location||
                   'fmeff_id '||effectivity.fmeff_id) ;

             END IF;  /* Valid routing  */

       END IF ;   /* routing header location */

       /*B2870041 this logic will get the total output qty in the routing uom
          if the formula or route fails validation the effectivity is skipped*/
       IF (valid) THEN

         /* if the total output was already calculated for this formula in
            the routing um there is no need to do it again */
         IF formula_header_tab(g_fm_hdr_loc).total_uom <>
              effectivity.routing_uom  OR
            formula_header_tab(g_fm_hdr_loc).total_uom IS NULL THEN

           /* if the factor was not calculated then the uom conversion failed
              and if it failed the effectivity can not be used */
           IF effectivity.prod_factor <= 0 THEN
             valid := FALSE;
            gmp_debug_message(' Not valid because effectivity.prod_factor is '
                   ||effectivity.prod_factor);
           ELSE
             /* reset the total ouput accumulator and loop through all of the
                material details to find all products and byproducts */
             temp_total_qty := 0;

            gmp_debug_message('Before Formula Dtl Loop - '||effectivity.fmeff_id);
                 IF (l_debug = 'Y') then
                      time_stamp;
                 END IF;

             FOR j IN g_fm_dtl_start_loc..g_fm_dtl_end_loc
             LOOP

               /* if the line is either a product or byproduct then we need
                  to process it */
               IF formula_detail_tab(j).line_type > 0 THEN

                 /* if the item is the same as the item in the effectivity
                    we have the factor to get the item from base uom to the
                    route uom */
                 IF (formula_detail_tab(j).inventory_item_id = effectivity.inventory_item_id)
                 THEN
                   temp_total_qty := temp_total_qty +
                     (effectivity.prod_factor *
                      formula_detail_tab(j).primary_qty);
                 /* if the item is different but the item base uom is the
                    same as the route the primary_qty will be used */
                 ELSIF
                   formula_detail_tab(j).inventory_item_id <> effectivity.inventory_item_id AND
                   formula_detail_tab(j).primary_uom_code = effectivity.routing_uom
                 THEN
                   temp_total_qty := temp_total_qty +
                      formula_detail_tab(j).primary_qty;
                 /* if the item is different but the item base uom is the
                    same as the route the primary_qty will be used */
                 ELSIF
                   formula_detail_tab(j).inventory_item_id <> effectivity.inventory_item_id AND
                   formula_detail_tab(j).detail_uom = effectivity.routing_uom
                 THEN
                   temp_total_qty := temp_total_qty +
                      formula_detail_tab(j).formula_qty;
                 /* no uom can be matched or the item is not the same as the
                    product thus a uom conversion will need to be done. If the
                    qty is 0 there is no need to do the conversion */
                 ELSIF formula_detail_tab(j).formula_qty > 0 THEN
                   uom_conv_cursor :=
                       'SELECT '
		     ||'  inv_convert.inv_um_convert'||at_apps_link  -- akaruppa previously GMICUOM.uom_conversion
		     ||'  (:pitem, '
		     ||'   NULL, '
		     ||'   :orgid, '
	      /* bug: 6918852 Vpedarla 04-Apr-2008  used the global variable for precision*/
                  /* ||'   NULL, '  */
                     ||    conv_precision || ' , '
		     ||'   :pqty, '
		     ||'   :pfrom_um, '
		     ||'   :pto_um , '
		     ||'   NULL , '
		     ||'   NULL '
		     ||'   ) '
                     ||'   FROM dual';
                   v_matl_qty := -1;
                   OPEN c_uom_conv FOR uom_conv_cursor USING
                     formula_detail_tab(j).inventory_item_id,
                     effectivity.organization_id, --sowmya added.
                     formula_detail_tab(j).primary_qty,
                     formula_detail_tab(j).primary_uom_code,
                     effectivity.routing_uom;

                   FETCH c_uom_conv INTO v_matl_qty;
                   CLOSE c_uom_conv;

                   /* as long as the qty is >0 then the uom conversion was
                      successful. If negative then it failed so reject the
                      effectivity and stop the current loop */
                   IF v_matl_qty > 0 THEN
                     temp_total_qty := temp_total_qty + v_matl_qty;
                   ELSE
                     valid := FALSE;
                    gmp_debug_message(' Existing v_matl_qty = '||v_matl_qty);
                     EXIT;
                   END IF;
                 END IF;
               END IF;
             END LOOP;

             gmp_debug_message('After Formula Dtl Loop - '||effectivity.fmeff_id);
                 IF (l_debug = 'Y') then
                      time_stamp;
                 END IF;

             /* if there was no failure and the qty is >0 save the values in
                the formula header */
             IF (valid) AND temp_total_qty > 0 THEN
               formula_header_tab(g_fm_hdr_loc).total_output :=
                 temp_total_qty;
               formula_header_tab(g_fm_hdr_loc).total_uom :=
                 effectivity.routing_uom;
             ELSE
               log_message(' Not updating formula_header_tab temp_total_qty = '||temp_total_qty);
             END IF;
           END IF;
         END IF;
       END IF;


    END IF;   /* routing check for effectivity */

    IF valid THEN
      g_curr_rstep_loc := find_routing_offsets(effectivity.formula_id,
                               effectivity.organization_id);

      gmp_debug_message('Before Export Effectivities - '||effectivity.fmeff_id);
         IF (l_debug = 'Y') then
              time_stamp;
         END IF;
      export_effectivities (valid);
      gmp_debug_message('After Export Effectivities - '||effectivity.fmeff_id);
         IF (l_debug = 'Y') then
              time_stamp;
         END IF;
    END IF ;

   END IF ;   /* Old Values */

    old_formula_id      := effectivity.formula_id ;
    old_organization_id := effectivity.organization_id ;
    old_fmeff_id        := effectivity.fmeff_id ;
    valid               := FALSE ;
    routing_valid       := FALSE ;

    /*  Vpedarla   added B3837959 MMK Issue, Bulk insert after every 1000 effectivities */
    eff_counter         := eff_counter + 1 ;

    IF (mod(eff_counter,1000) = 0)  THEN /* Every 1000 effectivity */
      /* If all is OK, Bulk Insert the data into MSC tables */
       log_message('Before MSC Inserts' ) ;
       time_stamp ;
       msc_inserts(valid);
          IF NOT (valid) THEN
             log_message('Error encountered in MSC_INSERTS');
          END IF;
    END IF ; /* Every 1000 effectivity */

  END LOOP;
  CLOSE c_formula_effectivity;

   time_stamp ;
   log_message('Formula effectivity completed. Before MSC Inserts l_eff_counter = '||l_eff_counter ) ;
  /* If all is OK, Bulk Insert the data into MSC tables */
   msc_inserts(valid);
       IF valid THEN
          COMMIT;
        ELSE
           log_message('Invalid after MSC Inserts' ) ;
           NULL ;
       END IF;

   time_stamp ;
   log_message('After MSC Inserts ' ) ;

   IF NOT (valid) THEN
      log_message('Error encountered in MSC_INSERTS');
   ELSE
      write_setups_and_transitions(at_apps_link,valid) ;  /* Seq Dependencies */  /* bug: 6710684 Vpedarla */
      IF NOT (valid) THEN
         log_message('Error encountered in write_setups_and_transitions');
      ELSE
         COMMIT;
      END IF;
   END IF;

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
           IF oper_leadtime_percent.COUNT > 0 THEN
           oper_leadtime_percent.delete ;
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

  log_message('End of process' ) ;
  time_stamp ;
  return_status := TRUE;

  EXCEPTION
    /* PennColor Bug: 8230710 */
    WHEN source_call_failure THEN
        log_message('Source Call Failed ' );
        return_status := FALSE;
    WHEN invalid_string_value  THEN
        log_message('Organization string is Invalid ' );
        return_status := FALSE;
    WHEN invalid_gmp_uom_profile THEN
        log_message('Profile "BOM: UOM for Hour" is Invalid ' );
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
  i              PLS_INTEGER ;
  j              PLS_INTEGER ;
  k              PLS_INTEGER ;
  lgr_loc        PLS_INTEGER ;
  lgr_start_loc  PLS_INTEGER ;
  lgr_end_loc    PLS_INTEGER ;
  lorg_loc       PLS_INTEGER ;
  old_routing_id PLS_INTEGER ;
  gen_start_pos  PLS_INTEGER ;
  org_start_pos  PLS_INTEGER ;
  start_gen_pos_written PLS_INTEGER  ;
  start_org_pos_written PLS_INTEGER  ;

BEGIN
  i               := 1 ;
  j               := 1 ;
  k               := 1 ;
  lgr_loc         := 0 ;
  lgr_start_loc   := 0 ;
  lgr_end_loc     := 0 ;
  lorg_loc        := 0 ;
  old_routing_id  := 0 ;
  gen_start_pos   := 1 ;
  org_start_pos   := 1 ;
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
         rcp_orgn_override(k).organization_id  = rtg_org_hdr_tab(i).organization_id THEN

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
          (rcp_orgn_override(k).organization_id  > rtg_org_hdr_tab(i).organization_id)
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
FUNCTION find_routing_header ( prouting_id      IN PLS_INTEGER,
                               porganization_id IN PLS_INTEGER)
                               RETURN BOOLEAN IS

routing_header_loc   PLS_INTEGER ;
BEGIN
routing_header_loc   := 0 ;
      routing_header_loc := bsearch_routing (prouting_id,
                                             porganization_id);

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
  i              PLS_INTEGER ;
  j              PLS_INTEGER ;
  k              PLS_INTEGER ;
  lgr_loc        PLS_INTEGER ;
  lgr_start_loc  PLS_INTEGER ;
  lgr_end_loc    PLS_INTEGER ;
  lorg_loc       PLS_INTEGER ;
  old_routing_id PLS_INTEGER ;
  gen_start_pos  PLS_INTEGER ;
  org_start_pos  PLS_INTEGER ;
  start_gen_pos_written PLS_INTEGER  ;
  start_org_pos_written PLS_INTEGER  ;
/* NAMIT_CR To link step dependency to routing header */
  lstpdep_start_loc  PLS_INTEGER ;
  lstpdep_end_loc    PLS_INTEGER ;
  stpdep_start_pos  PLS_INTEGER ;
  start_stpdep_pos_written PLS_INTEGER  ;

BEGIN
  -- gmp_putline(' Start Link Rtg ','a');
  i              := 1 ;
  j              := 1 ;
  k              := 1 ;
  lgr_loc        := 0 ;
  lgr_start_loc  := 0 ;
  lgr_end_loc    := 0 ;
  lorg_loc       := 0 ;
  old_routing_id := 0 ;
  gen_start_pos  := 1 ;
  org_start_pos  := 1 ;
  start_gen_pos_written := 0 ;
  start_org_pos_written := 0 ;
  lstpdep_start_loc  := 0 ;
  lstpdep_end_loc    := 0 ;
  stpdep_start_pos   := 1 ;
  start_stpdep_pos_written := 0 ;


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

	 -- Vpedarla Bug: 8936327 Added the below condition
	ELSIF j = opr_stpdep_size THEN
                lstpdep_start_loc   := - 1;
                lstpdep_end_loc     := - 1;
        END IF ;

     END LOOP ;   /* Step Dependency loop */

/* NAMIT_CR Code To Link Step Dependency to Routing Header End */

   END IF ;   /* old rtg */

     --  For organization routing
     start_org_pos_written := 0 ;
     For k IN org_start_pos..rtg_org_dtl_size
     LOOP
      IF rtg_org_dtl_tab(k).routing_id = rtg_org_hdr_tab(i).routing_id AND
         rtg_org_dtl_tab(k).organization_id  = rtg_org_hdr_tab(i).organization_id THEN

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
          (rtg_org_dtl_tab(k).organization_id  > rtg_org_hdr_tab(i).organization_id)
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
REM|   2. ALL details are present in mtl_system_items with appropriate flags |
REM|                                                                         |
REM| HISTORY                                                                 |
REM| 07/14/2002   Rajesh Patangya - Reorgnized the complete code B2314052    |
REM+=========================================================================+
*/
PROCEDURE validate_routing (prouting_id     IN PLS_INTEGER ,
                           porganization_id IN PLS_INTEGER,
                           pheader_loc      IN PLS_INTEGER,
                           prout_valid      OUT NOCOPY BOOLEAN)
IS

  uom_statement           VARCHAR2(9000) ;
  old_routingstep_id      PLS_INTEGER ;
  old_oprn_no             VARCHAR2(32) ;
  old_activity            PLS_INTEGER  ;
  i                       INTEGER ;
  j                       INTEGER ;
  start_genric_count      PLS_INTEGER ;
  end_genric_count        PLS_INTEGER ;
  start_orgn_count        PLS_INTEGER ;
  end_orgn_count          PLS_INTEGER ;
  rtg_org_loc             PLS_INTEGER ;
  prim_rsrc_cnt           PLS_INTEGER ;
  p_uom_qty               NUMBER ;
  rtg_valid               BOOLEAN;
  found_match             BOOLEAN;
  k                       INTEGER;
  step_start_index        INTEGER;
  step_end_index          INTEGER;
  usage_start_index       INTEGER;
  usage_end_index         INTEGER;
  prev_routingstep_id     NUMBER;   -- B4918786 (RDP) SDS
  l_setup_id              NUMBER;   -- B4918786 (RDP) SDS
  rtg_recipe_valid        BOOLEAN ;  -- Bug: 8409692 vpedarla

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
  p_uom_qty               := -1 ;
  found_match             := TRUE ;
  prev_routingstep_id     := NULL ; -- B4918786 (RDP) SDS
  l_setup_id              := NULL;  -- B4918786 (RDP) SDS

  prim_rsrc_cnt      := 0 ;
  rtg_org_loc        := pheader_loc;
  start_genric_count := rtg_org_hdr_tab(rtg_org_loc).generic_start_loc;
  end_genric_count   := rtg_org_hdr_tab(rtg_org_loc).generic_end_loc;
  start_orgn_count   := rtg_org_hdr_tab(rtg_org_loc).orgn_start_loc;
  end_orgn_count     := rtg_org_hdr_tab(rtg_org_loc).orgn_end_loc;
  sds_tab  := sds_tab_init ;

-- Overrides Rajesh {
   rtg_valid                 := TRUE ;
   k                         := 1;
   rtg_recipe_valid          := TRUE ;  -- Bug: 8409692 vpedarla



   step_start_index :=
      rtg_org_hdr_tab(effectivity.rtg_hdr_location).step_start_loc ;
   step_end_index :=
      rtg_org_hdr_tab(effectivity.rtg_hdr_location).step_end_loc ;
   usage_start_index :=
      rtg_org_hdr_tab(effectivity.rtg_hdr_location).usage_start_loc ;
   usage_end_index :=
      rtg_org_hdr_tab(effectivity.rtg_hdr_location).usage_end_loc ;

-- Changes for Overrides Rajesh }

   gmp_debug_message('start_genric_count='||start_genric_count||
               ' end_genric_count='||end_genric_count||
               ' start_orgn_count='||start_orgn_count||
               ' end_orgn_count='||end_orgn_count||
               ' step_start_index='||step_start_index||
               ' step_end_index='||step_end_index||
               ' usage_start_index='||usage_start_index||
               ' usage_end_index='||usage_end_index
               );

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
             (start_orgn_count <= end_orgn_count) THEN
       prev_routingstep_id := NULL ;
       FOR j IN start_orgn_count..end_orgn_count
       LOOP
        /* {{ */
         IF (rtg_org_dtl_tab(j).organization_id = porganization_id)  AND
            (rtg_org_dtl_tab(j).routing_id = prouting_id) THEN

         /* ------------ B4918786 (RDP) STARTS ----------------------*/

         IF (rtg_org_dtl_tab(j).routingstep_id <> nvl(prev_routingstep_id,-1)) THEN

           IF (rtg_org_dtl_tab(j).is_unique = 1) AND (effectivity.category_id > 0) THEN

               l_setup_id := bsearch_setupid(rtg_org_dtl_tab(j).oprn_id,
                                 effectivity.category_id);

               IF l_setup_id > 0 THEN
                  rtg_org_dtl_tab(j).setup_id := l_setup_id ;
               ELSE
                 /* The actual SDS changeover data is not established */
                 rtg_org_dtl_tab(j).setup_id := NULL ;
               END IF;

               gmp_debug_message(' Effectivity ' || effectivity.fmeff_id ||
                           ' rouiting ' || rtg_org_dtl_tab(j).routing_id ||
                           ' rouitingstep ' || rtg_org_dtl_tab(j).routingstep_id ||
                           ' Category ' || effectivity.category_id ||
                           ' Setup Id = ' || l_setup_id);

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
         /* ------------ B4918786 (RDP) ENDS -----------------------*/

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
            ELSIF (effectivity.recipe_id < recipe_override(k).recipe_id) THEN
     --     ELSE     Bug: 8409692 Vpedarla modified else to elseif
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
                     (rtg_org_dtl_tab(j).organization_id =
                      rcp_orgn_override(k).organization_id) AND
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

    IF l_debug = 'Y' THEN
     gmp_debug_message ('ROU_ID '||
     rtg_org_dtl_tab(j).routing_id ||'*'||' REC_ID '||
     effectivity.recipe_id ||'*'||' PR_IND '||
     rtg_org_dtl_tab(j).prim_rsrc_ind      ||'*'||' RS_ID '||
     rtg_org_dtl_tab(j).routingstep_id         ||' RES '||
     rtg_org_dtl_tab(j).resources     ||'* '||
     rtg_org_dtl_tab(j).resource_usage      ||' *'||
     rtg_org_dtl_tab(j).o_resource_usage      ||' AF '||
     rtg_org_dtl_tab(j).activity_factor      ||' *'||
     rtg_org_dtl_tab(j).o_activity_factor      ||' SQ '||
     rtg_org_dtl_tab(j).step_qty      ||' *'||
     rtg_org_dtl_tab(j).o_step_qty     ||' PQ '||
     rtg_org_dtl_tab(j).process_qty      ||' *'||
     rtg_org_dtl_tab(j).o_process_qty      ||' MNC '||
     rtg_org_dtl_tab(j).min_capacity   ||' *'||
     rtg_org_dtl_tab(j).o_min_capacity   ||' MXC '||
     rtg_org_dtl_tab(j).max_capacity   ||' *'||
     rtg_org_dtl_tab(j).o_max_capacity);
     END IF;

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
                     --   rtg_valid := FALSE ;    /* bug: 8409692 Vpedarla */
                          rtg_recipe_valid  := FALSE ;
                        log_message('Recipe ' || effectivity.recipe_id ||' '||
                               rtg_org_dtl_tab(j).resources|| ' has override usage 0');
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
                     --   rtg_valid := FALSE ;    /* bug: 8409692 Vpedarla */
                          rtg_recipe_valid  := FALSE ;
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
                     --   rtg_valid := FALSE ;    /* bug: 8409692 Vpedarla */
                          rtg_recipe_valid  := FALSE ;
                        log_message('Recipe ' || effectivity.recipe_id ||
                         ' has ZERO override step qty');
                        EXIT ;
                     END IF ;
            END IF;  /* For primary resource chack */



      /* ------------ Override Calculation Code start ----------------------*/

                IF ((rtg_org_dtl_tab(j).prim_rsrc_ind = 1
		     OR rtg_org_dtl_tab(j).capacity_constraint = 1) -- akaruppa added to check that chargeable resources are not defined as 'Do Not Plan'
                    AND (rtg_org_dtl_tab(j).schedule_ind = 3)) THEN

                    rtg_valid := FALSE;
        	    rtg_org_hdr_tab(rtg_org_loc).valid_flag := -1 ;
                    log_message('Primary Resource or Chargeable Resource '||rtg_org_dtl_tab(j).resources||
                        ' is defined as Do Not Plan '); -- akaruppa added "Chargeable Resource"
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
	      -- akaruppa make rtg invalid if a secondary resource which is chargeable is not defined at org level
              IF ((rtg_gen_dtl_tab(i).prim_rsrc_ind <> 0)
	          OR ((rtg_gen_dtl_tab(i).prim_rsrc_ind = 0)
		      AND (rtg_gen_dtl_tab(i).capacity_constraint = 1))) THEN
                 rtg_valid := FALSE ;
                log_message('Missing Plant Resource '||rtg_gen_dtl_tab(i).resources);
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

         IF ( rtg_valid = FALSE or rtg_recipe_valid = FALSE ) THEN
       --  IF  rtg_valid = FALSE  THEN   /* bug: 8409692 Vpedarla */
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

--    Bug: 8409692 Vpedarla modified the below code
--     prout_valid := rtg_valid ;
   IF rtg_recipe_valid THEN
        prout_valid := rtg_valid ;
   ELSE
        prout_valid := rtg_recipe_valid ;
   END IF ;

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
PROCEDURE invalidate_rtg_all_org (p_routing_id IN PLS_INTEGER) IS

  i INTEGER ;
BEGIN
  i := 1;
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
REM|   1. ALL details can be converted to primary UOM                        |
REM|   2. ALL details are present in mtl_system_items with appropriate flags |
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
start_pos_written  PLS_INTEGER ;
detail_found       PLS_INTEGER ;
uom_success        BOOLEAN ;

BEGIN
   --  gmp_putline(' Begin validate_formula ','a');
i                  := 1 ;
j                  := 1 ;
current_dtl_cnt    := 1 ;
start_pos_written  := 0 ;
detail_found       := 0 ;
uom_success        := FALSE ;

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

  /* 	   log_message(
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

    cur_formula_orgn_count          ref_cursor_typ;
    c_formula_dtl_count             ref_cursor_typ;
    formula_orgn_count_cursor       VARCHAR2(32767) ;
    formula_dtl_count_cursor        VARCHAR2(32767) ;
    fm_dtl_orgn_cnt                 INTEGER ;
    i                               INTEGER ;

BEGIN
      --  gmp_putline(' start of validate_formula_for_org ','a');

    formula_orgn_count_cursor       := NULL ;
    formula_dtl_count_cursor        := NULL ;
    fm_dtl_orgn_cnt                 := 1 ;
    i                               := 1 ;

   formula_orgn_count_cursor :=
                     ' SELECT fmd.formula_id, '
                   ||'       msi.organization_id, count(*), 0 '
                   ||' FROM  fm_matl_dtl'||at_apps_link||' fmd, '
                   ||'       fm_form_mst'||at_apps_link||' ffm, '
                   ||'       mtl_system_items'||at_apps_link||' msi, '
                   ||'       mtl_parameters'||at_apps_link||' mp '
                   ||' WHERE ffm.formula_id = fmd.formula_id '
                   ||'   AND ffm.delete_mark = 0 '
                   ||'   AND fmd.qty <> 0 '  /* 2362810 Voltek Fix */
                   ||'   AND fmd.inventory_item_id = msi.inventory_item_id '
		   ||'   AND msi.recipe_enabled_flag = ''Y'' '
                   ||'   AND msi.organization_id = mp.organization_id '
		   ||'   AND mp.process_enabled_flag = ''Y'' ';

	IF l_in_str_org  IS NOT NULL THEN
            formula_orgn_count_cursor := formula_orgn_count_cursor
		   ||' AND mp.organization_id ' || l_in_str_org ;
        END IF;

         formula_orgn_count_cursor := formula_orgn_count_cursor
                   ||'   AND ( '
                   ||'       ( fmd.line_type = -1 ) '
                   ||'     OR '
                   ||'       ( fmd.line_type IN (1,2) AND '
                   ||'         msi.process_execution_enabled_flag = ''Y'' ) '
                   ||'       ) '  -- akaruppa added to verify that the products are process execution enabled
                   ||' GROUP BY fmd.formula_id, '
                   ||'          msi.organization_id, 0 '
                   ||' ORDER BY fmd.formula_id, '
                   ||'          msi.organization_id ' ;

       -- Get counts for the formulae
       formula_dtl_count_cursor :=
                     ' SELECT fmd.formula_id, count(*) '
                   ||' FROM  fm_matl_dtl'||at_apps_link||' fmd, '
                   ||'       fm_form_mst'||at_apps_link||' ffm '
                   ||' WHERE ffm.formula_id = fmd.formula_id '
                   ||'   AND ffm.delete_mark = 0 '
                   ||'   AND fmd.qty <> 0 '   /* 2362810 Voltek Fix */
                   ||' GROUP BY fmd.formula_id '
		   ||' ORDER BY fmd.formula_id ' ; /* 4722080 Added Order by */

    OPEN cur_formula_orgn_count FOR formula_orgn_count_cursor;
    FETCH cur_formula_orgn_count BULK COLLECT INTO formula_orgn_count_tab;
    formula_orgn_size := formula_orgn_count_tab.count;
/* PennColor Bug: 8230710
    LOOP
    FETCH cur_formula_orgn_count INTO formula_orgn_count_tab(formula_orgn_size);
    EXIT WHEN cur_formula_orgn_count%NOTFOUND;

    formula_orgn_size := formula_orgn_size + 1 ;
    END LOOP;
    */

    CLOSE cur_formula_orgn_count;
    --formula_orgn_size := formula_orgn_size -1 ;
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
                 gmp_debug_message(' formula org check failed for formula '||formula_dtl_count_rec.formula_id);
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
-- akaruppa removed pplant_code IN parameter
FUNCTION check_formula ( porganization_id IN PLS_INTEGER,
                         pformula_id IN PLS_INTEGER) return BOOLEAN IS

i                 INTEGER ;
p_organization_id PLS_INTEGER ;
p_formula_id      PLS_INTEGER ;

BEGIN

i                 := 1 ;
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
        gmp_debug_message('start -'||g_fm_dtl_start_loc||' end -'||g_fm_dtl_end_loc);
	        IF check_formula_for_organization (p_organization_id ,
                                                   p_formula_id) THEN -- akaruppa removed p_plant_code
		  g_fm_hdr_loc := i ;
                  return TRUE ;

                ELSE
		  g_fm_hdr_loc := i ;
		  gmp_debug_message(' check_formula_for_organization failed');
                  return FALSE ;

                END IF;
            ELSE
		  g_fm_hdr_loc := i ;
		  gmp_debug_message(' check_formula valid_flag failed');
                  return FALSE ;
	    END IF ;  /* Header validation */
	ELSIF formula_header_tab(i).formula_id > pformula_id THEN
		g_fm_hdr_loc := i ;
		gmp_debug_message(' check_formula failed');
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
                         porganization_id IN PLS_INTEGER,
                         pformula_id IN PLS_INTEGER) return BOOLEAN IS
i            INTEGER;
BEGIN
i            := 1 ;

FOR i IN g_formula_orgn_count_tab..formula_orgn_count_tab.COUNT
LOOP
  IF formula_orgn_count_tab(i).formula_id = pformula_id THEN

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
FUNCTION bsearch_routing (p_routing_id      IN PLS_INTEGER ,
			  p_organization_id IN PLS_INTEGER)
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
	 p_organization_id < rtg_org_hdr_tab(mid).organization_id ) THEN
	bottom := mid -1 ;
     ELSIF
	p_routing_id > rtg_org_hdr_tab(mid).routing_id OR
        (p_routing_id = rtg_org_hdr_tab(mid).routing_id AND
         p_organization_id > rtg_org_hdr_tab(mid).organization_id ) THEN
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
FUNCTION bsearch_setupid (p_oprn_id       IN PLS_INTEGER ,
                          p_category_id   IN PLS_INTEGER
                         ) RETURN INTEGER IS
top     INTEGER ;
bottom  INTEGER ;
mid     INTEGER ;

BEGIN
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
  p_x_aps_fmeff_id   IN PLS_INTEGER,
  p_aps_fmeff_id     IN PLS_INTEGER,
  return_status      OUT NOCOPY BOOLEAN
)
IS
  statement_form_eff  VARCHAR2(9000);
  loop_index          INTEGER;
  routing_id          PLS_INTEGER;
  temp_recipe         VARCHAR2(240);

BEGIN
  statement_form_eff  := NULL ;
  temp_recipe         := NULL ;

/* B2989806  Added IF condition below */
IF effectivity.aps_fmeff_id = -1 THEN

    statement_form_eff :=
	          'INSERT INTO gmp_form_eff'||at_apps_link
		   ||' ( '
		   ||'  aps_fmeff_id,organization_id,fmeff_id, '
                   ||'  formula_id, routing_id, '
		   ||'  creation_date, created_by, last_update_date, '
                   ||'  last_updated_by '
		   ||' ) '
		   ||' VALUES '
		   ||' ( :p1,:p2,:p3,:p4,:p5,:p6,:p7,:p8,:p9)';

             /* This aps_fmeff_id the next sequence ID, but not multiplied by
                2 and added by 1 */
    EXECUTE IMMEDIATE statement_form_eff USING
		   p_aps_fmeff_id,
		   effectivity.organization_id, -- akaruppa added
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

           -- Bug: 8715318 Vpedarla uncommented the below line
	   /* B5584507 */
	   temp_recipe :=
	   effectivity.recipe_no || delimiter || to_char(effectivity.recipe_version) ;

           pef_process_sequence_id(pef_index) :=   p_x_aps_fmeff_id ;
           pef_item_id(pef_index) :=  effectivity.inventory_item_id ;
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
           pef_sr_instance_id(pef_index) :=  instance_id ;

           -- Bug: 8715318 Vpedarla uncommented the below line
	   pef_recipe(pef_index)         :=  temp_recipe ;  /* B5584507 */
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
  p_x_aps_fmeff_id   IN PLS_INTEGER,
  return_status      OUT NOCOPY BOOLEAN
)
IS
  temp_assembly_comment   VARCHAR2(240) ;
  primary_bom_written     PLS_INTEGER ;
  p_primary_qty           NUMBER ;
  loop_index              PLS_INTEGER;
  l_scale_type            INTEGER;
  l_offset_loc            NUMBER ;
  l_offset                NUMBER ;
  l_line_type             INTEGER;
  rtgstpno_loc            NUMBER;
  temp_alt_bom_desig      VARCHAR2(40) ;  /* B5584507 */

BEGIN

  temp_assembly_comment   := NULL ;
  primary_bom_written     := 0 ;
  p_primary_qty           := 0 ;
  l_offset_loc            := 0 ;
  l_offset                := 0 ;
  l_line_type             := 0 ;
  rtgstpno_loc            := -1;
  temp_alt_bom_desig      := NULL ;  /* B5584507 */

  -- ABHAY write the code to get the offset percentages here.
  -- The code will loop through the formula_detail_tab  from
  -- g_fm_dtl_start_loc to g_fm_dtl_end_loc and update the field offset
  FOR loop_index IN g_fm_dtl_start_loc..g_fm_dtl_end_loc
  LOOP

     /* Do write a row for the primary produc */

   IF (effectivity.inventory_item_id = formula_detail_tab(loop_index).inventory_item_id) AND
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

        /* Bug: 8608111 Vpedarla Uncommented below code */
         /* B5584507 */
	 temp_alt_bom_desig := substr( formula_detail_tab(loop_index).formula_no, 1,
                       10- length(delimiter||to_char(formula_detail_tab(loop_index).formula_vers)))
  	-- formula_detail_tab(loop_index).formula_no
        ||delimiter||  to_char(formula_detail_tab(loop_index).formula_vers) ;

         /* BOM Bulk Insert assignments */

         bom_index := bom_index + 1 ;
         bom_bill_sequence_id(bom_index) := p_x_aps_fmeff_id ;
         bom_sr_instance_id(bom_index)   := instance_id ;
         bom_organization_id(bom_index)  := effectivity.organization_id ;
         bom_assembly_item_id(bom_index) := effectivity.inventory_item_id ;
         -- bom_assembly_type(bom_index)    := 1 ;

         /* Bug: 8608111 Vpedarla commented below code to pass temp_alt_bom_desig*/
	  bom_alternate_bom_designator(bom_index)  := p_x_aps_fmeff_id ;
         -- bom_alternate_bom_designator(bom_index)  := temp_alt_bom_desig ;

         -- bom_alternate_bom_designator(bom_index)  := temp_alt_bom_desig ;
         bom_specific_assembly_comment(bom_index) :=  temp_assembly_comment ;

       /* Bug: 7385050 Vpedarla added the below condition to send the scale_type 2 for proportional and 0 for fixed  */
        IF formula_detail_tab(loop_index).scale_type = 0 THEN
                l_scale_type := 0 ;
        ELSIF formula_detail_tab(loop_index).scale_type = 1 THEN
                l_scale_type := 2 ;
        ELSE
                 /* scale type of other than 0,1,2 is not supported */
                 l_scale_type := formula_detail_tab(loop_index).scale_type ;
        END IF ;
        bom_scaling_type(bom_index)    := l_scale_type ;
      --   bom_scaling_type(bom_index)    :=
       --                      formula_detail_tab(loop_index).bom_scale_type ;
       /* Bug: 7385050 Vpedarla */

         bom_assembly_quantity(bom_index)  :=
                            formula_detail_tab(loop_index).primary_qty ;
         bom_uom(bom_index)  := formula_detail_tab(loop_index).primary_uom_code ;
/* NAMIT_CR For Step Material Assoc */
/* Used enhanced binary search to get the location for routing
    step number of product. */

            rtgstpno_loc :=
               enh_bsearch_stpno (effectivity.formula_id, effectivity.recipe_id,
                  effectivity.inventory_item_id); -- akaruppa changed effectivity.item_id to effectivity.inventory_item_id

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
				effectivity.organization_id, -- akaruppa previously effectivity.plant_code
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

/* VPEDARLA BUG: 7348022 */
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

/*  VPEDARLA Bug: 7348022 */

         bomc_index := bomc_index + 1 ;
         bomc_component_sequence_id(bomc_index) := formula_detail_tab(loop_index).x_formulaline_id ;
         bomc_sr_instance_id(bomc_index)   := instance_id ;
         bomc_organization_id(bomc_index)  := effectivity.organization_id ;
         bomc_Inventory_item_id(bomc_index) := formula_detail_tab(loop_index).inventory_item_id ;
         bomc_using_assembly_id(bomc_index) := effectivity.inventory_item_id ;
         bomc_bill_sequence_id(bomc_index) := p_x_aps_fmeff_id ;
         bomc_component_type(bomc_index) := 10 ;  /* for co-proudcts */
         bomc_scaling_type(bomc_index) := l_scale_type; /* Scailing type for APS */
           -- bomc_change_notice(i)  == null
           -- bomc_revision(i),  == null
         bomc_uom_code(bomc_index) := formula_detail_tab(loop_index).primary_uom_code ;
         bomc_usage_quantity(bomc_index) :=  (-1 * formula_detail_tab(loop_index).primary_qty) ;
        -- Bug: 8624603 Vpedarla
        bomc_effectivity_date(bomc_index) := trunc(effectivity.start_date) ;
      --   bomc_effectivity_date(bomc_index) := current_date_time ;
         /* NAMIT_OC For ingredients contribute_to_step_qty will
         store 1 for YES and 0 for NO */
         bomc_disable_date(bomc_index) := null_value;
         /*B5176291 - item substitution changes - disabale date should eb initalised to null */
         bomc_contribute_to_step_qty(bomc_index) := formula_detail_tab(loop_index).contribute_step_qty_ind;
           -- bomc_disable_date := null_value,
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
				effectivity.organization_id, -- akaruppa previously effectivity.plant_code
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

    IF (effectivity.inventory_item_id = formula_detail_tab(loop_index).inventory_item_id) AND
      (formula_detail_tab(loop_index).line_type = -1)  THEN
      NULL ;
    ELSE
        IF (trunc(nvl(formula_detail_tab(loop_index).end_date,current_date_time + 1)) >  trunc(current_date_time)) THEN /* Currently active rows should only be passed*/
                 /* BOM Component Bulk Insert assignments */
                 bomc_index := bomc_index + 1 ;

                /*B5176291 - item subtitution changes - start*/
                /*For sustitutes the formula line id will be null. component sequence id in
                msc_st_bom_components is a primary key. So the max value from gmd formula line sequence
                is fetched and global counter value is added to it.Then odd value is passed on to APS. */
                 IF formula_detail_tab(loop_index).x_formulaline_id IS NOT NULL THEN
                        bomc_component_sequence_id(bomc_index) := formula_detail_tab(loop_index).x_formulaline_id ;
                 ELSE
                        gmd_formline_cnt := gmd_formline_cnt + 1;
                        bomc_component_sequence_id(bomc_index) := (( v_gmd_formula_lineid + gmd_formline_cnt ) * 2) + 1;
                 END IF;
                /*B5176291 - item subtitution changes - end*/

                 bomc_sr_instance_id(bomc_index)   := instance_id ;
                 bomc_organization_id(bomc_index)  := effectivity.organization_id ;
                 bomc_Inventory_item_id(bomc_index) := formula_detail_tab(loop_index).inventory_item_id ;
                 -- RDP B2445746, replace component aps_item_id to product aps_item_id
                 bomc_using_assembly_id(bomc_index) := effectivity.inventory_item_id ;
                 bomc_bill_sequence_id(bomc_index) := p_x_aps_fmeff_id ;
                 bomc_component_type(bomc_index) := l_line_type ;
                 bomc_scaling_type(bomc_index) := l_scale_type; /* Scailing type for APS */
                   -- bomc_change_notice(i)  == null
                   -- bomc_revision(i),  == null
                 bomc_uom_code(bomc_index) := formula_detail_tab(loop_index).primary_uom_code ;
                 bomc_usage_quantity(bomc_index) :=  p_primary_qty ;

                /*B5176291 - Item substitution - start*/
                IF ( formula_detail_tab(loop_index).end_date IS NULL
                AND formula_detail_tab(loop_index).start_date IS NULL ) THEN
                       -- Bug: 8624603 Vpedarla
                       bomc_effectivity_date(bomc_index) := trunc(effectivity.start_date) ;
                      --  bomc_effectivity_date(bomc_index) := trunc(current_date_time) ;
                        bomc_disable_date(bomc_index) := null_value;
                ELSE
                        IF formula_detail_tab(loop_index).start_date IS NULL THEN
                           -- Bug: 8624603 Vpedarla
                            bomc_effectivity_date(bomc_index) := trunc(effectivity.start_date) ;
                             --   bomc_effectivity_date(bomc_index) := trunc(current_date_time);
                        ELSE
                        /*B5176291 - Truncate the time from the date part and then pass on
                        this to APS. Round up the day when the time is not equal to 00:00 and pass
                        on ( date + 1 ) */

                        -- Vpedarla Bug:6087535 commented below line
                           bomc_effectivity_date(bomc_index) := trunc(formula_detail_tab(loop_index).start_date);
                        /*
                                IF (loop_index > 1) AND (bomc_index > 1 ) AND (
                                 ( formula_detail_tab(loop_index).formula_id =
                                           formula_detail_tab(loop_index - 1).formula_id ) AND
                                 ( formula_detail_tab(loop_index).formula_line_id =
                                           formula_detail_tab(loop_index - 1).formula_line_id ) AND
                                 (( bomc_disable_date(bomc_index - 1) >
                                         trunc(formula_detail_tab(loop_index).start_date) )
                                   OR
                                   (
                                   ((sign(formula_detail_tab(loop_index - 1).end_date -
                                        trunc(formula_detail_tab(loop_index - 1).end_date)) = 1 ) AND
                                   (current_date_time > formula_detail_tab(loop_index - 1).end_date))
                                   )
                                 )) THEN
                                           bomc_effectivity_date(bomc_index) :=
                                                 trunc(formula_detail_tab(loop_index).start_date) + 1;
                                                 log_message('--- 3 truncating the start date +1 '|| to_char(formula_detail_tab(loop_index).start_date, 'dd-mon-yy hh24:mi:ss'));
                                ELSE
                                           bomc_effectivity_date(bomc_index) :=
                                                  trunc(formula_detail_tab(loop_index).start_date);
                                                  log_message('--- 4 truncating the start date  '|| to_char(formula_detail_tab(loop_index).start_date, 'dd-mon-yy hh24:mi:ss'));
                                END IF;

                         */
                        END IF;

                        -- Rajesh Patangya 5058669, If Null then do not use it
                        IF formula_detail_tab(loop_index).end_date IS NOT NULL THEN
                        -- vpedarla  Bug:6087535 commented below lines
                            bomc_disable_date(bomc_index) := trunc(formula_detail_tab(loop_index).end_date);
                         /*        get_sign := sign(formula_detail_tab(loop_index).end_date
                                      - trunc(formula_detail_tab(loop_index).end_date));
                                IF ( get_sign = 1 ) THEN
                                        bomc_disable_date(bomc_index) := trunc(formula_detail_tab(loop_index).end_date) + 1;
                                        log_message('--- 3 truncating the end date +1 '|| to_char(formula_detail_tab(loop_index).end_date, 'dd-mon-yy hh24:mi:ss'));
                                ELSE
                                        bomc_disable_date(bomc_index) := trunc(formula_detail_tab(loop_index).end_date);
                                        log_message('--- 3 truncating the start date  '|| to_char(formula_detail_tab(loop_index).end_date, 'dd-mon-yy hh24:mi:ss'));
                                END IF; */
                        ELSE
                                bomc_disable_date(bomc_index) := null_value;
                        END IF;
                END IF;
                /*B5176291 - Item substitution - end*/

                 /* NAMIT_OC For ingredients contribute_to_step_qty will
                 store 1 for YES and 0 for NO */
                 bomc_contribute_to_step_qty(bomc_index) := formula_detail_tab(loop_index).contribute_step_qty_ind;
                   -- bomc_disable_date := null_value,
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
        END IF; /* Currently active rows should only be passed*/
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
  p_x_aps_fmeff_id   IN PLS_INTEGER,
  return_status      OUT NOCOPY BOOLEAN
)
IS
  p_routing_details  VARCHAR2(128);
  temp_alt_rtg_desig VARCHAR2(40);   /* B5584507 */
  v_routing_qty      NUMBER;
BEGIN
  p_routing_details  := NULL;
  temp_alt_rtg_desig := NULL;  /* B5584507 */
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



        /* Bug: 8608111 Vpedarla Uncommented below code */
         /* B5584507 */
	 temp_alt_rtg_desig := substr( effectivity.routing_no, 1,
                       10- length(delimiter||to_char(to_char(effectivity.routing_vers))))
        ||delimiter|| to_char(effectivity.routing_vers) ;


            rtg_routing_sequence_id(rtg_index) := p_x_aps_fmeff_id ;
            rtg_sr_instance_id(rtg_index) := instance_id ;
              -- rtg_routing_type(rtg_index) := 1 ;
            rtg_routing_comment(rtg_index) := p_routing_details ;

	    -- Bug: 8608111 Vpedarla commented the below code to pass temp_alt_rtg_desig
            rtg_alt_routing_designator(rtg_index) := p_x_aps_fmeff_id ; /* B2098058 */
           --  rtg_alt_routing_designator(rtg_index) := temp_alt_rtg_desig;

	    -- p_x_aps_fmeff_id ; /* B2098058 */
              -- project_id :=  null_value ;
              -- task_id :=  null_value ;
              -- line_id :=  null_value ;
            /*B2870041*/
            rtg_uom_code(rtg_index) := formula_detail_tab(effectivity.product_index).primary_uom_code ;
              -- cfm_routing_flag := null_value ;
              -- ctp_flag := null_value ;
            /*B2870041*/
            rtg_routing_quantity(rtg_index) := v_routing_qty ;
            rtg_assembly_item_id(rtg_index) := effectivity.inventory_item_id ;
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
  p_x_aps_fmeff_id   IN PLS_INTEGER,
  return_status      OUT NOCOPY BOOLEAN
)
IS

  start_index          INTEGER;
  end_index            INTEGER;
  loop_index           INTEGER;
  k                    INTEGER;
  alt_cnt              INTEGER;
  previous_id          PLS_INTEGER;
  previous_activity    PLS_INTEGER ;
  seq_no               INTEGER;
  statement_no         INTEGER;
  v_counter            INTEGER;
  alternates_inserted  VARCHAR2(1);
  v_alternate          PLS_INTEGER;
  t_scale_type         PLS_INTEGER;

  f_step_qty           NUMBER ;
  f_resource_usage     NUMBER ;
  f_activity_factor    NUMBER ;
  f_process_qty        NUMBER ;
/* NAMIT_OC */
  f_min_capacity       NUMBER ;
  f_max_capacity       NUMBER ;

  calculated_resource_usage NUMBER ;

  prod_scale_factor    NUMBER ; /*B2870041 contains factor to scale usage */
  l_prod_scale_factor  NUMBER ;
  temp_min_xfer_qty    NUMBER ; /*B2870041*/

/* For SDS Enhancement */
   l_seq_dep_class     VARCHAR2(8);
   orig_rs_seq_num     NUMBER ;
   u_setup_id          PLS_INTEGER ;

   oprn_leadtime_start  INTEGER ;  -- Vpedarla 7391495
   oprn_leadtime_end    INTEGER ;  -- Vpedarla 7391495
   lead_loop            INTEGER ;  -- Vpedarla 7391495

BEGIN

  k                     := 0;
  alt_cnt               := 0;
  previous_id           := 0;
  previous_activity     := -1;
  seq_no                := 1;
  statement_no          := 0;
  v_counter             := 0;
  alternates_inserted   := 'N';
  v_alternate           := 0;
  t_scale_type          := -1;

  f_step_qty            := 0;
  f_resource_usage      := 0;
  f_activity_factor     := 0;
  f_process_qty         := 0;
/* NAMIT_OC */
  f_min_capacity        := 0;
  f_max_capacity        := 999999;

  calculated_resource_usage := 0;

  prod_scale_factor     := 1; /*B2870041 contains factor to scale usage */
  l_prod_scale_factor   := 1;
  temp_min_xfer_qty     := 0; /*B2870041*/

  orig_rs_seq_num      := 0;
  u_setup_id           := NULL ;

-- Vpedarla 7391495
   oprn_leadtime_start := 0;
   oprn_leadtime_end   := 0;
   lead_loop           := 0;

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

    /*B4359481 - sowsubra - CHG: MTQ VALUES ARE NOT COLLECTED - Uncommented this part of code */
    /*This piece of code was commented as part of APS, as the step dependency was sent as part of
    APS K enhancement.*/

     IF  rtg_org_dtl_tab(loop_index).step_qty = 0 THEN
       temp_min_xfer_qty := 0 ;
     ELSE
   -- B6873825 Rajesh Patangya
  --   temp_min_xfer_qty :=  rtg_org_dtl_tab(loop_index).minimum_transfer_qty ;
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

-- Vpedarla Bug: 7391495
   search_operation_leadtime(effectivity.fmeff_id ,effectivity.organization_id ,
               oprn_leadtime_start, oprn_leadtime_end );

  IF ( oprn_leadtime_start > 0 ) THEN
      statement_no := 11 ;
   FOR i IN oprn_leadtime_start..oprn_leadtime_end
   LOOP
         statement_no := 12;
     IF (oper_leadtime_percent(i).routingstep_id = rtg_org_dtl_tab(loop_index).routingstep_id ) THEN
           lead_loop  := i ;
           EXIT ;
     END IF;
     IF (oper_leadtime_percent(i).routingstep_id > rtg_org_dtl_tab(loop_index).routingstep_id) THEN
           EXIT ;
     END IF;
   END LOOP ;
  END IF;
-- Vpedarla Bug: 7391495

    statement_no := 15 ;

  statement_no := 20 ;
    -- Routing Step Bulk insert assignments
       opr_index := opr_index + 1 ;
       opr_operation_sequence_id(opr_index) :=
                                      rtg_org_dtl_tab(loop_index).x_routingstep_id ;
       opr_routing_sequence_id(opr_index) := p_x_aps_fmeff_id ;
       opr_operation_seq_num(opr_index) := rtg_org_dtl_tab(loop_index).routingstep_no ;
       opr_sr_instance_id(opr_index) := instance_id ;
       opr_operation_description(opr_index) := rtg_org_dtl_tab(loop_index).oprn_desc ;
       opr_effectivity_date(opr_index) := current_date_time ;

        -- Vpedarla 7391495
       IF (lead_loop > 0) THEN
        opr_lead_time_percent(opr_index) := oper_leadtime_percent(lead_loop).start_offset ;
       ELSE
        opr_lead_time_percent(opr_index) := NULL;
       END IF;

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

     -- Bug: 8354988 Vpedarla added if condition to check for recipe step qty overrides
      IF (rtg_org_dtl_tab(loop_index).o_step_qty  > 0) THEN
         opr_step_qty(opr_index) := prod_scale_factor * rtg_org_dtl_tab(loop_index).o_step_qty / l_prod_scale_factor  ;
      ELSE
         opr_step_qty(opr_index) := prod_scale_factor * rtg_org_dtl_tab(loop_index).step_qty;
      END IF;
   --    opr_step_qty(opr_index) := prod_scale_factor * rtg_org_dtl_tab(loop_index).step_qty;

       opr_step_qty_uom(opr_index) := rtg_org_dtl_tab(loop_index).process_qty_uom;
         -- yield := null_value ; /*  B2365684 rtg_org_dtl_tab(loop_index).step_qty, */

       opr_department_id(opr_index) := (effectivity.organization_id * 2) + 1 ;
       opr_organization_id(opr_index) := effectivity.organization_id  ;
       opr_department_code(opr_index) := effectivity.organization_code ;
         --  operation_lead_time_percent,cumulative_yield, := null ;
         -- reverse_cumulative_yield,net_planning_percent, := null;
         -- setup_duration,tear_down_duration, := null ;
       /*B2870041*/
       opr_uom_code(opr_index) := formula_detail_tab(effectivity.product_index).primary_uom_code ;
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
       rs_sr_instance_id(rs_index)   := instance_id ;
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
--      or_resource_seq_num(or_index) := seq_no ;
      /* B3596028 */
      or_resource_seq_num(or_index) := rtg_org_dtl_tab(loop_index).seq_dep_ind ;
      or_resource_id(or_index) := rtg_org_dtl_tab(loop_index).x_resource_id ;
      or_alternate_number(or_index) := 0 ;
      or_basis_type(or_index) := t_scale_type ;
      or_resource_usage(or_index) := ( calculated_resource_usage
                   * rtg_org_dtl_tab(loop_index).resource_count ) ;
      or_max_resource_units(or_index) := rtg_org_dtl_tab(loop_index).resource_count ;
      or_resource_units(or_index) := rtg_org_dtl_tab(loop_index).resource_count ;
      or_uom_code(or_index) := rtg_org_dtl_tab(loop_index).resource_usage_uom ;
      or_sr_instance_id(or_index) := instance_id ;
      or_routing_sequence_id(or_index) := p_x_aps_fmeff_id ;
      or_organization_id(or_index) := effectivity.organization_id ;
      or_minimum_capacity(or_index) := nvl(f_min_capacity,0) ;
      or_maximum_capacity(or_index) := nvl(f_max_capacity,9999999) ;
      or_last_update_date(or_index) := current_date_time ;
      or_creation_date(or_index) := current_date_time ;
      or_orig_rs_seq_num(or_index) := orig_rs_seq_num;
      or_break_ind(or_index) := rtg_org_dtl_tab(loop_index).break_ind;

      /* For Primary Rsrc Principal flag = 1, for Aux and Sec Rsrcs Principal Flag = 2*/
      IF (rtg_org_dtl_tab(loop_index).prim_rsrc_ind = 1) THEN

         or_principal_flag(or_index) := rtg_org_dtl_tab(loop_index).prim_rsrc_ind ;
      ELSE
         or_principal_flag(or_index) := 2 ;

      END IF;  /* End of primary Resource Check */

     /* ------------ B4918786 (RDP) STARTS ------------------*/
     statement_no := 110 ;
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

    /*
     log_message(
     ' WEff ' || effectivity.fmeff_id
     ||' Rt '|| rtg_org_dtl_tab(loop_index).routing_id
     ||' Op '|| rtg_org_dtl_tab(loop_index).routingstep_no
     ||' SdInd '|| rtg_org_dtl_tab(loop_index).seq_dep_ind
     ||' ' || rtg_org_dtl_tab(loop_index).resources
     ||' Setup ' ||  rtg_org_dtl_tab(loop_index).setup_id
     ||' U ' || rtg_org_dtl_tab(loop_index).is_unique
     ||' SDX ' || sd_index
     ||' NU ' || rtg_org_dtl_tab(loop_index).is_nonunique
     ||' NuSet ' || u_setup_id
     ||' OS ' || or_setup_id(or_index) );
    */
     /* ------------ B4918786 (RDP) ENDS ----------------- */

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
        alt_cnt := 1 ;
        FOR alt_cnt IN 1..alt_rsrc_size
        LOOP

      /* B5688153 Prod spec alternates Rajesh Patangya */
            IF ( rtg_alt_rsrc_tab(alt_cnt).prim_resource_id =
                      rtg_org_dtl_tab(loop_index).resource_id
             AND (rtg_alt_rsrc_tab(alt_cnt).inventory_item_id = -1 OR
                  rtg_alt_rsrc_tab(alt_cnt).inventory_item_id = effectivity.inventory_item_id)) THEN

             orig_rs_seq_num := orig_rs_seq_num + 1;
            /* B2353759, alternate runtime_factor considered */
               v_alternate := v_alternate + 1;

            /* Bulk insert assignments for operation_resources, Alternate resources */
		/* OR insert # 2 */
             or_index := or_index + 1 ;
             or_operation_sequence_id(or_index) :=
                        rtg_org_dtl_tab(loop_index).x_routingstep_id ;
--             or_resource_seqor_operation_sequence_id_num(or_index) := seq_no ;
             /* B3596028 */
             or_resource_seq_num(or_index) := rtg_org_dtl_tab(loop_index).seq_dep_ind ;
             or_resource_id(or_index) :=
                  ((rtg_alt_rsrc_tab(alt_cnt).alt_resource_id * 2) + 1) ;
             or_alternate_number(or_index) := v_alternate ;
             or_principal_flag(or_index) := 1;  /* Taking Principal flag as 1 for Alternates */
             or_basis_type(or_index) := t_scale_type ;
             or_resource_usage(or_index) := ( calculated_resource_usage
                          * rtg_org_dtl_tab(loop_index).resource_count
                          * rtg_alt_rsrc_tab(alt_cnt).runtime_factor ) ;
             or_max_resource_units(or_index) := rtg_org_dtl_tab(loop_index).resource_count ;
             /* B2761278 */
             or_resource_units(or_index) := rtg_org_dtl_tab(loop_index).resource_count ;
             or_uom_code(or_index) := rtg_org_dtl_tab(loop_index).resource_usage_uom ;
               -- or_deleted_flag(or_index) := 2 ;
             or_sr_instance_id(or_index) := instance_id ;
             or_routing_sequence_id(or_index) := p_x_aps_fmeff_id ;
             or_organization_id(or_index) := effectivity.organization_id ;
             /* SGIDUGU added min capacity and max capacity inserts */
             or_minimum_capacity(or_index) :=
                       nvl(rtg_alt_rsrc_tab(alt_cnt).min_capacity,0) ;
             or_maximum_capacity(or_index) :=
                       nvl(rtg_alt_rsrc_tab(alt_cnt).max_capacity,999999) ;

             or_orig_rs_seq_num(or_index) := orig_rs_seq_num;
             or_break_ind(or_index) := rtg_org_dtl_tab(loop_index).break_ind;

             /* ------------ B4918786 (RDP) STARTS ------------------*/
               statement_no := 125 ;
               IF  rtg_org_dtl_tab(loop_index).setup_id IS NOT NULL THEN
                 or_setup_id(or_index) := rtg_org_dtl_tab(loop_index).setup_id ;
               ELSE
                 or_setup_id(or_index) := null_value ;
               END IF;
               /*
     log_message(
     ' -- A sds? ' ||
     rtg_org_dtl_tab(loop_index).is_sds_rout    ||' OS ' ||
     or_setup_id(or_index) ||' RTg '||
     rtg_org_dtl_tab(loop_index).routing_id ||' Opr '||
     rtg_org_dtl_tab(loop_index).routingstep_no ||' S_IND '||
     rtg_org_dtl_tab(loop_index).seq_dep_ind || ' RS  ' ||
     rtg_org_dtl_tab(loop_index).setup_id ||
     ' Prev ' || p_setup_id  ||
     ' GS ' || g_setup_id ) ;
               */

     /* ------------ B4918786 (RDP) ENDS ----------------- */

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
             or_uom_code(or_index) := rtg_org_dtl_tab(loop_index).resource_usage_uom ;
               -- or_deleted_flag(or_index) := 2 ;
             or_sr_instance_id(or_index) := instance_id ;
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
     log_message(
     ' Effect ' || effectivity.fmeff_id || ' is_sds_rout ' ||
     rtg_org_dtl_tab(loop_index).is_sds_rout    ||' Setup ' ||
     rtg_org_dtl_tab(loop_index).setup_id    ||' RTg '||
     rtg_org_dtl_tab(loop_index).routing_id ||' Oprn '||
     rtg_org_dtl_tab(loop_index).routingstep_no ||' SDS_IND '||
     rtg_org_dtl_tab(loop_index).seq_dep_ind );

     log_message(
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
  p_x_aps_fmeff_id   IN  PLS_INTEGER,
  precipe_id         IN  PLS_INTEGER,
  return_status      OUT NOCOPY BOOLEAN
)
IS

  i              INTEGER ;
  record_written BOOLEAN ;  /* B3562488 */
  already_done   INTEGER ;  /* 3562488  */
  stmt_no        NUMBER ;
  found_product  BOOLEAN ;
  write_row      BOOLEAN ;

BEGIN
  i              := 1;
  record_written := FALSE ;    /* B3562488 */
  already_done   := 0 ;        /* 3562488  */
  stmt_no        := 0;
  found_product  := FALSE;
  write_row      := TRUE;

  -- write routing/material associations to msc_operation_components
         gmp_debug_message('Enter --- > ' || g_mat_assoc
          || ' Effec ' || effectivity.formula_id
          || ' Material ' || mat_assoc_tab(g_mat_assoc).formula_id || ' Recipe ' || precipe_id ) ;

stmt_no := 0;
   FOR i in g_mat_assoc..material_assocs_size
   LOOP

     IF  effectivity.formula_id > mat_assoc_tab(i).formula_id THEN
       gmp_debug_message(i || ' --- ' ||
          effectivity.formula_id || ' > ' || mat_assoc_tab(i).formula_id ) ;
          NULL ;   /* Keep on looping */

     ELSIF effectivity.formula_id < mat_assoc_tab(i).formula_id THEN
            /* B3562488 */
            IF record_written = TRUE THEN
               g_mat_assoc := already_done ;
            END IF ;

           gmp_debug_message('Exit ' || g_mat_assoc || ' ***'
             || effectivity.formula_id || ' < ' || mat_assoc_tab(i).formula_id ) ;

           EXIT;
     ELSIF effectivity.formula_id = mat_assoc_tab(i).formula_id THEN
            /* B3562488 */
        IF record_written = FALSE THEN
           already_done := i ;
           record_written := TRUE ;
--         log_message('Written ' || already_done);
        END IF ;

stmt_no := 10;
        IF mat_assoc_tab(i).recipe_id = precipe_id THEN

           /*  Do Not write material association
                      for the product line */

           IF mat_assoc_tab(i).inventory_item_id = effectivity.inventory_item_id THEN
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

              /*B5176291 - Item substitution changes - start*/
              IF mat_assoc_tab(i).x_formulaline_id IS NOT NULL THEN
                 oc_component_sequence_id(oc_index) := mat_assoc_tab(i).x_formulaline_id ;
              ELSE
                 op_formline_cnt := op_formline_cnt + 1;
                 oc_component_sequence_id(oc_index) := (( v_gmd_formula_lineid + op_formline_cnt ) * 2) + 1;
              END IF;
              /*B5176291 - Item substitution changes - end*/

              oc_sr_instance_id(oc_index) := instance_id ;
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
                 g_old_aps_item_id <> mat_assoc_tab(i).inventory_item_id
              THEN
                 g_old_recipe_id := mat_assoc_tab(i).recipe_id;
                 g_old_formula_id := mat_assoc_tab(i).formula_id;
                 g_old_rtg_id := p_x_aps_fmeff_id;
                 g_old_rtgstep_id := mat_assoc_tab(i).x_routingstep_id;
                 g_old_aps_item_id := mat_assoc_tab(i).inventory_item_id;
                 g_mtq_loc := mtq_index;
                 g_min_mtq := mat_assoc_tab(i).min_trans_qty;

                 itm_mtq_from_op_seq_id(mtq_index) :=  mat_assoc_tab(i).x_routingstep_id;
                 itm_mtq_routing_sequence_id(mtq_index) := p_x_aps_fmeff_id ;
                 itm_mtq_sr_instance_id(mtq_index) := instance_id ;
                 itm_mtq_from_item_id(mtq_index) := mat_assoc_tab(i).inventory_item_id ;
                 itm_mtq_organization_id(mtq_index) := effectivity.organization_id ;
                 itm_mtq_min_tran_qty(mtq_index) := mat_assoc_tab(i).min_trans_qty * mat_assoc_tab(i).uom_conv_factor;
                 itm_mtq_min_time_offset(mtq_index) := mat_assoc_tab(i).min_delay;
                 itm_mtq_max_time_offset(mtq_index) := mat_assoc_tab(i).max_delay;
                 itm_mtq_frm_op_seq_num(mtq_index) := mat_assoc_tab(i).routingstep_no;
                 itm_mtq_last_update_date(mtq_index) := current_date_time;
                 itm_mtq_creation_date(mtq_index) := current_date_time;
              END IF;

     /* If an item is yielded in the same step multiple times and if MTQ value is associated
      to that item multiple times, then write row that has min MTQ. */

              IF g_old_recipe_id = mat_assoc_tab(i).recipe_id AND
                 g_old_formula_id = mat_assoc_tab(i).formula_id AND
                 g_old_rtg_id = p_x_aps_fmeff_id AND
                 g_old_rtgstep_id = mat_assoc_tab(i).x_routingstep_id AND
                 g_old_aps_item_id = mat_assoc_tab(i).inventory_item_id AND
                 g_mtq_loc <> mtq_index
              THEN
                 log_message('Item : '||mat_assoc_tab(i).inventory_item_id||' in recipe : '||mat_assoc_tab(i).recipe_id
                 ||' is associated multiple times in step '||mat_assoc_tab(i).routingstep_no
                 ||' with MTQ/Min/Max Delay defined. Row with Minimum/Null MTQ will be considered. ');
                 IF mat_assoc_tab(i).min_trans_qty < g_min_mtq THEN
                    itm_mtq_from_op_seq_id(g_mtq_loc) :=  mat_assoc_tab(i).x_routingstep_id;
                    itm_mtq_routing_sequence_id(g_mtq_loc) := p_x_aps_fmeff_id ;
                    itm_mtq_sr_instance_id(g_mtq_loc) := instance_id ;
                    itm_mtq_from_item_id(g_mtq_loc) := mat_assoc_tab(i).inventory_item_id ;
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

  retrieval_cursor        VARCHAR2(4096) ;
BEGIN
g_aps_eff_id              := 0; /* Global Aps Effectivity ID */
aps_fmeff_id              := 0 ;/* Generated effectivity Id */
x_aps_fmeff_id            := 0 ;/* encoded effectivity Id */
retrieval_cursor          := NULL ;


log_message ('extract effectivities started '|| l_debug );

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
                log_message(' NO_DATA_FOUND exception raised in Procedure: Gmp_bom_routing_pkg.Extract_effectivities ' );
                return_status := TRUE;
	WHEN OTHERS THEN
		log_message('Untrapped effectivity extraction error');
		log_message(sqlerrm);
        return_status := FALSE;

END extract_effectivities;

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
  formula_details_size      := 1;
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

  instance_id := instance;

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
FUNCTION find_routing_offsets (p_formula_id    	IN PLS_INTEGER,
                               p_organization_id	IN PLS_INTEGER) -- akaruppa previously p_plant_code(VARCHAR2)
                               RETURN NUMBER IS

i 	    PLS_INTEGER ;
retvar 	    PLS_INTEGER ;

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
    IF rstep_offsets(i).organization_id = p_organization_id THEN
      retvar := i ;
      g_rstep_loc := i ;
      EXIT ;
    ELSIF rstep_offsets(i).organization_id > p_organization_id THEN
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
FUNCTION get_offsets( p_formula_id		IN PLS_INTEGER,
			p_organization_id	IN PLS_INTEGER, -- akaruppa previously p_plant_code(VARCHAR2)
			p_formulaline_id	IN PLS_INTEGER )
			RETURN NUMBER IS

i 	    PLS_INTEGER ;
retvar 	    PLS_INTEGER ;

BEGIN
i 	    := 1 ;
retvar 	    := -1 ;

FOR i in g_rstep_loc..rtg_offsets_size
LOOP
  IF rstep_offsets(i).formula_id = p_formula_id THEN
    IF rstep_offsets(i).organization_id = p_organization_id THEN
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
    ELSIF rstep_offsets(i).organization_id > p_organization_id THEN
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
REM|    Report_Error                                                         |
REM|                                                                         |
REM| TYPE                                                                    |
REM|    Private                                                              |
REM|                                                                         |
REM| USAGE                                                                   |
REM|                                                                         |
REM|                                                                         |
REM| DESCRIPTION                                                             |
REM|    This is a general error reporting procedure which logs errors for    |
REM|    the effectivity extraction.                                          |
REM|                                                                         |
REM| INPUT PARAMETERS                                                        |
REM|    i_error_id    number    -  The error id for the failure              |
REM|    i_error_code  varchar2  -  The error code for the message            |
REM|    i_param_1     varchar2  -  Error parameter 1                         |
REM|    i_param_2     varchar2  -  Error parameter 2                         |
REM|    i_param_3     varchar2  -  Error parameter 3                         |
REM|    i_param_4     varchar2  -  Error parameter 4                         |
REM|                                                                         |
REM| OUTPUT PARAMETERS                                                       |
REM|    None                                                                 |
REM|                                                                         |
REM| INPUT/OUTPUT PARAMETERS                                                 |
REM|    None                                                                 |
REM|                                                                         |
REM| HISTORY                                                                 |
REM|    Created 9th July 1999 by P.J.Schofield (OPM Development Oracle UK)   |
REM|                                                                         |
REM+=========================================================================+
*/
PROCEDURE Report_Error
(
  i_error_id       IN VARCHAR2,
  i_error_code     IN VARCHAR2,
  i_param_1        IN VARCHAR2,
  i_param_2        IN VARCHAR2,
  i_param_3        IN VARCHAR2,
  i_param_4        IN VARCHAR2
)
IS
BEGIN
  /* This is temporary, AOL standards for error reporting will be needed */
  RAISE_APPLICATION_ERROR ( i_error_id, i_error_code );
END Report_Error;

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
             UTL_FILE.fopen ( p_location, 'GMPBMRTB.log', v_mode );
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
REM|    log_message                                                          |
REM|                                                                         |
REM| TYPE                                                                    |
REM|    Private                                                              |
REM| USAGE                                                                   |
REM|                                                                         |
REM| DESCRIPTION                                                             |
REM|    This is a general error reporting procedure which logs errors to a   |
REM|    file or to the screen (for debug)                                    |
REM|                                                                         |
REM| PARAMETERS                                                              |
REM|    string    IN VARCHAR2                                                |
REM|                                                                         |
REM| HISTORY                                                                 |
REM|  07/14/2002   Rajesh Patangya - Reorgnized the complete code B2314052   |
REM+=========================================================================+
*/

PROCEDURE LOG_MESSAGE(pBUFF  IN  VARCHAR2) IS
BEGIN
  IF v_cp_enabled THEN
     IF fnd_global.conc_request_id > 0  THEN
         FND_FILE.PUT_LINE( FND_FILE.LOG, pBUFF);
     ELSE
         null;
     END IF;
   ELSE
         null;
   END IF;

  EXCEPTION
     WHEN OTHERS THEN
        RETURN;
END LOG_MESSAGE;

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

   SELECT to_char(sysdate,'MM/DD/YYYY HH24:MI:SS')
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

stmt_no   NUMBER ;
i         integer ;
v_dummy   NUMBER; /* Penncolor -- Vpedarla Bug: 8230710 */

BEGIN
stmt_no   := 0 ;
i         := 1;
v_dummy   := 0; /* Penncolor -- Vpedarla Bug: 8230710 */

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
	     -- Bug: 8715318 Vpedarla uncommented the below line
             -- recipe,      /* B5584507 */
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
	     -- Bug: 8715318 Vpedarla uncommented the below line
             -- pef_recipe(i),                    /* B5584507 */
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
       /* NAMIT_ASQC */
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
       bomc_disable_date(i), /* B5176291 - Item substitution changes */
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
       opr_lead_time_percent(i),  -- Bug: 7391495 Vpedarla
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
       from_op_seq_num,
       planning_pct    -- Bug: 6407973 KBANDDYO Added the column to send default value of 100
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
        itm_mtq_last_update_date(i),
        0,
        itm_mtq_creation_date(i),
        0,
        itm_mtq_frm_op_seq_num(i),
	100           -- Bug:  6407973 KBANDDYO added the column to send default value of 100
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
-- Bug:  6407973 KBANDDYO inserting into column planning_pct along with transfer_pct
       planning_pct,
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
	opr_stpdep_trans_pct(i),   -- Bug: 6407973 KBANDDYO
        opr_stpdep_last_update_date(i), /* 7363807 */
        0,
        opr_stpdep_creation_date(i), /* 7363807 */
        0,
        opr_stpdep_frm_op_seq_num(i),
        opr_stpdep_to_op_seq_num(i),
        opr_stpdep_app_to_chrg(i),
        opr_stpdep_organization_id(i)
       );

      END IF;

       -- Vpedarla Bug: 8230710

       SELECT st.VALUE INTO v_dummy from V$MYSTAT st, V$STATNAME sn
       WHERE st.STATISTIC# = sn.STATISTIC#
       AND sn.NAME in ('session pga memory max');
       log_message('MSC_INSERTS-Before Freeing up. Session pga memory max = ' || to_char(v_dummy) );

       SELECT st.VALUE INTO v_dummy from V$MYSTAT st, V$STATNAME sn
       where st.STATISTIC# = sn.STATISTIC#
       and sn.NAME in ('session pga memory');
       log_message('MSC_INSERTS-Before Freeing up. Session pga memory = ' || TO_CHAR(v_dummy) );

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
              opr_lead_time_percent.delete ;

              rtg_routing_sequence_id.delete ;
              pef_routing_sequence_id.delete ;
              or_routing_sequence_id.delete ;
              opr_routing_sequence_id.delete ;
              rs_routing_sequence_id.delete ;
              oc_routing_sequence_id.delete ;

	     -- Bug: 8715318 Vpedarla
              pef_recipe.delete ;

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

            /* -- Pef Variable Initialization -- */
              pef_process_sequence_id.delete ;
              pef_item_id.delete ;
              pef_disable_date.delete ;
              pef_minimum_quantity.delete ;
              pef_maximum_quantity.delete ;
              pef_preference.delete ;
              pef_index := 0 ;

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

              -- bug: 6851919 Vpedarla
              mtq_index := 0;
              g_dep_index := 1 ;
              opr_stpdep_frm_seq_id.delete;
              opr_stpdep_to_seq_id.delete;
              opr_stpdep_routing_sequence_id.delete;
              opr_stpdep_dependency_type.delete;
              opr_stpdep_app_to_chrg.delete;
              opr_stpdep_sr_instance_id.delete;
              opr_stpdep_organization_id.delete;
              opr_stpdep_frm_op_seq_num.delete;
              opr_stpdep_to_op_seq_num.delete;
              opr_stpdep_trans_pct.delete;
              opr_stpdep_min_time_offset.delete;
              opr_stpdep_max_time_offset.delete;

              itm_mtq_frm_op_seq_num.delete;
              itm_mtq_max_time_offset.delete;
              itm_mtq_min_tran_qty.delete;
              itm_mtq_organization_id.delete;
              itm_mtq_from_item_id.delete;
              itm_mtq_sr_instance_id.delete;
              itm_mtq_routing_sequence_id.delete;
              itm_mtq_from_op_seq_id.delete;

        dbms_session.free_unused_user_memory;

      -- Vpedarla Bug: 8230710
      SELECT st.VALUE INTO v_dummy from V$MYSTAT st, V$STATNAME sn
      WHERE st.STATISTIC# = sn.STATISTIC#
        AND sn.NAME in ('session pga memory max');
      log_message('MSC_INSERTS-After Freeing up2. Session pga memory max = ' || to_char(v_dummy) );

      SELECT st.VALUE INTO v_dummy from V$MYSTAT st, V$STATNAME sn
      where st.STATISTIC# = sn.STATISTIC#
        and sn.NAME in ('session pga memory');
      log_message('MSC_INSERTS-After Freeing up2. Session pga memory = ' || TO_CHAR(v_dummy) );

        return_status := TRUE ;
EXCEPTION
   WHEN OTHERS THEN
    log_message('Error in MSC Inserts : '||stmt_no || ':' || sqlerrm);
    return_status := FALSE;

END msc_inserts ;

/*
REM+=========================================================================+
REM| PROCEDURE NAME                                                          |
REM|    write_setups_and_transitions                                         |
REM|                                                                         |
REM| DESCRIPTION                                                             |
REM|    This procedure inserts rows into msc_st_resource_setups and          |
REM|    msc_st_setup_transitions                                             |
REM|                                                                         |
REM| HISTORY                                                                 |
REM|  02/03/2006 B4918786 Rajesh Patangya Rewrite for SDS Enhancement        |
REM|   MSC_RESOURCE_SETUPS unique key is ON                                  |
REM|   Instance_id,resource_id,organization_id and setup_id                  |
REM|   02-20-2007 B5741664 Added a join with mtl_parameters to filter        |
REM|    rows for process organization - similar to 11.5.10 code              |
REM|   08-01-2008 B6710684 Vpedarla Added one more in parameter              |
REM+=========================================================================+
*/
PROCEDURE write_setups_and_transitions
(
  at_apps_link   IN VARCHAR2,
  return_status  OUT NOCOPY BOOLEAN
)  IS

   l_profile            VARCHAR2(4);
   stmt_no              NUMBER;
   Zero_tran            VARCHAR2(32767);
   fact_tran            VARCHAR2(32767);
   rsrc_setup           VARCHAR2(32767);
BEGIN

   Zero_tran   := NULL ;
   fact_tran   := NULL ;
   rsrc_setup  := NULL ;

LOG_MESSAGE('write_setups_and_transitions started ' );
time_stamp;
/* bug: 6710684 Vpedarla making changes to take the profile value from source server
           and also made changes to use procedure get_profile_value */
--       commented the below code line
--      l_profile       := FND_PROFILE.VALUE('BOM:HOUR_UOM_CODE');
        l_profile       := get_profile_value('BOM:HOUR_UOM_CODE' , at_apps_link);

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
     ||'    ((a.resource_id * 2) + 1),'
     ||'    a.organization_id, '
     ||'    a.seq_dep_id, '
     ||'    b.seq_dep_id, '
     ||'    0 setup_time, '
     ||'    0 penalty_factor, '
     ||'    :profile, '
     ||'    :instance1 , '
     ||'    2 '
     ||' FROM ( '
     ||' SELECT '
     ||' rd.organization_id, '
     ||' s.category_id, '
     ||' s.seq_dep_id, '
     ||' o.oprn_id, '
     ||' rd.resource_id, '
     ||' count(o.oprn_id) OVER (PARTITION BY rd.organization_id,s.category_id,rd.resource_id) CNT '
     ||' FROM '
     ||'     cr_rsrc_dtl'||at_apps_link||' rd, '
     ||'     gmp_sequence_types'||at_apps_link||' s, '
     ||'     gmd_operation_resources'||at_apps_link||' r, '
     ||'     gmd_operation_activities'||at_apps_link||' a, '
     ||'     gmd_operations'||at_apps_link||' o '
     ||' WHERE o.oprn_id = a.oprn_id '
     ||' AND a.oprn_line_id = r.oprn_line_id '
     ||' AND a.sequence_dependent_ind = 1 '
     ||' AND r.prim_rsrc_ind = 1 '
     ||' AND r.resources = rd.resources '
     ||' AND o.oprn_id = s.oprn_id ' ;

     IF l_in_str_org  IS NOT NULL THEN
        Zero_tran := Zero_tran
        ||'   AND rd.organization_id ' || l_in_str_org  ;
     END IF;

     Zero_tran := Zero_tran
     ||' UNION ALL '
     ||' SELECT '
     ||' rd.organization_id, '
     ||' s.category_id, '
     ||' s.seq_dep_id, '
     ||' o.oprn_id, '
     ||' rd.alt_resource_id, '
     ||' count(o.oprn_id) OVER (PARTITION BY rd.organization_id,s.category_id,rd.alt_resource_id) CNT '
     ||' FROM '
     ||'     gmp_sequence_types'||at_apps_link||' s, '
     ||'     gmd_operation_resources'||at_apps_link||' r, '
     ||'     gmd_operation_activities'||at_apps_link||' a, '
     ||'     gmd_operations'||at_apps_link||' o, '
     ||' (SELECT pcrd.resource_id prim_resource_id, '
     ||'         pcrd.resources prim_resources,  '
     ||'         acrd.resource_id alt_resource_id,  '
     ||'         acrd.resources alt_resources, '
     ||'         acrd.organization_id  '
     ||'                     FROM  cr_rsrc_dtl'||at_apps_link||' acrd,  '
     ||'                           cr_rsrc_dtl'||at_apps_link||' pcrd,  '
     ||'                           cr_ares_mst'||at_apps_link||' cam  '
     ||'                     WHERE cam.alternate_resource = acrd.resources  '
     ||'                       AND cam.primary_resource = pcrd.resources  '
     ||'                       AND acrd.organization_id = pcrd.organization_id  ' ;

     IF l_in_str_org  IS NOT NULL THEN
        Zero_tran := Zero_tran
        ||'   AND acrd.organization_id ' || l_in_str_org  ;
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
     ||' rd.organization_id, '
     ||' s.category_id, '
     ||' s.seq_dep_id, '
     ||' o.oprn_id, '
     ||' rd.resource_id, '
     ||' count(o.oprn_id) OVER (PARTITION BY rd.organization_id,s.category_id,rd.resource_id) CNT '
     ||' FROM '
     ||'     cr_rsrc_dtl'||at_apps_link||' rd, '
     ||'     gmp_sequence_types'||at_apps_link||' s, '
     ||'     gmd_operation_resources'||at_apps_link||' r, '
     ||'     gmd_operation_activities'||at_apps_link||' a, '
     ||'     gmd_operations'||at_apps_link||' o '
     ||' WHERE o.oprn_id = a.oprn_id '
     ||' AND a.oprn_line_id = r.oprn_line_id '
     ||' AND a.sequence_dependent_ind = 1 '
     ||' AND r.prim_rsrc_ind = 1 '
     ||' AND r.resources = rd.resources '
     ||' AND o.oprn_id = s.oprn_id ' ;

     IF l_in_str_org  IS NOT NULL THEN
      Zero_tran := Zero_tran
      ||'   AND rd.organization_id ' || l_in_str_org  ;
     END IF;

     Zero_tran := Zero_tran
     ||' UNION ALL '
     ||' SELECT '
     ||' rd.organization_id, '
     ||' s.category_id, '
     ||' s.seq_dep_id, '
     ||' o.oprn_id, '
     ||' rd.alt_resource_id, '
     ||' count(o.oprn_id) OVER (PARTITION BY rd.organization_id,s.category_id,rd.alt_resource_id) CNT '
     ||' FROM '
     ||'     gmp_sequence_types'||at_apps_link||' s, '
     ||'     gmd_operation_resources'||at_apps_link||' r, '
     ||'     gmd_operation_activities'||at_apps_link||' a, '
     ||'     gmd_operations'||at_apps_link||' o, '
     ||' (SELECT pcrd.resource_id prim_resource_id, '
     ||'         pcrd.resources prim_resources,  '
     ||'         acrd.resource_id alt_resource_id,  '
     ||'         acrd.resources alt_resources, '
     ||'         acrd.organization_id  '
     ||'                     FROM  cr_rsrc_dtl'||at_apps_link||' acrd,  '
     ||'                           cr_rsrc_dtl'||at_apps_link||' pcrd,  '
     ||'                           cr_ares_mst'||at_apps_link||' cam  '
     ||'                     WHERE cam.alternate_resource = acrd.resources  '
     ||'                       AND cam.primary_resource = pcrd.resources  '
     ||'                       AND acrd.organization_id = pcrd.organization_id  ' ;

     IF l_in_str_org  IS NOT NULL THEN
        Zero_tran := Zero_tran
        ||'   AND acrd.organization_id ' || l_in_str_org  ;
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
     ||' WHERE a.organization_id = b.organization_id '
     ||'   AND a.category_id = b.category_id '
     ||'   AND a.resource_id = b.resource_id '
     ||'   AND a.cnt = b.cnt '
     ||'   AND a.seq_dep_id <> b.seq_dep_id '
     ||'   AND a.cnt > 1 ' ;

  -- Bug: 8293879 Vpedarla
  -- As per information from APS, Plan would be generating the un finished SDS matrix with
  --  zero setup time and zero transiton penality. So, OPM need not specifically insert the records.
  --  EXECUTE IMMEDIATE Zero_tran USING l_profile, instance_id ;

     -- Fact Transitions (Alternate Resources are considered)
     stmt_no := 920 ;

     -- Vpedarla bug: 8293879 Modified the cursor below
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
     ||'       SETUP_ID , deleted_flag, sr_instance_id, UOM_CODE '
     ||'   from MSC_ST_OPERATION_RESOURCES '
     ||'      WHERE sr_instance_id = :instance1 '
     ||'   and setup_id is not null  ) b, '
     ||'     (select unique RESOURCE_ID, ORGANIZATION_ID,'
     ||'       SETUP_ID , deleted_flag, sr_instance_id, UOM_CODE '
     ||'   from MSC_ST_OPERATION_RESOURCES '
     ||'      WHERE sr_instance_id = :instance1 '
     ||'   and setup_id is not null  ) c '
     ||' WHERE  b.setup_id = a.from_seq_dep_id  '
     ||'        and c.setup_id = a.to_seq_dep_id  '
     ||'        AND b.RESOURCE_ID = c.RESOURCE_ID ';
 /*    ||' AND NOT EXISTS ( select 1 from msc_st_setup_transition '
     ||'    WHERE organization_id = b.organization_id '
     ||'      AND resource_id = b.resource_id '
     ||'      AND from_setup_id =  a.FROM_SEQ_DEP_ID '
     ||'      AND to_setup_id =  a.TO_SEQ_DEP_ID '
     ||'      AND sr_instance_id = b.sr_instance_id ) ' ; */

     IF l_in_str_org  IS NOT NULL THEN
        Fact_tran := Fact_tran
        ||'   AND b.organization_id ' || l_in_str_org  ;
     END IF;

     EXECUTE IMMEDIATE Fact_tran USING instance_id , instance_id ;

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
	-- B5741664 Added a join with mtl_parameters to filter rows for process
	-- organization - similar to 11.5.10 code
    IF l_in_str_org  IS NOT NULL THEN
      rsrc_setup := rsrc_setup
      ||'     AND mst.organization_id ' || l_in_str_org  ;
    END IF;

LOG_MESSAGE(' Resource setups started ' );
time_stamp;

-- Bug: 8578876 Vpedarla
--        EXECUTE IMMEDIATE rsrc_setup USING instance_id ;

   rsrc_setup := ' INSERT INTO msc_st_resource_setups ( '
    ||'   resource_id,      '
    ||'   organization_id,  '
    ||'   sr_instance_id,   '
    ||'   setup_id,         '
    ||'   setup_code,       '
    ||'   setup_description,'
    ||'   deleted_flag   ) '
    ||'   SELECT /*+DRIVING_SITE(mtl) DRIVING_SITE(gmp) DRIVING_SITE(gao) DRIVING_SITE(gmd) DRIVING_SITE(crd) */ unique  '
    ||'   ((crd.resource_id*2) + 1) resource_id , '
    ||'   crd.ORGANIZATION_ID , '
    ||'   :instance1 , '
    ||'   gmp.SEQ_DEP_ID , '
    ||'   mtl.CONCATENATED_SEGMENTS, '
    ||'   mtl.CONCATENATED_SEGMENTS, '
    ||'   2 '
    ||' FROM gmp_sequence_types'||at_apps_link||' gmp, '
    ||'     MTL_CATEGORIES_B_KFV'||at_apps_link||' mtl, '
    ||'     gmd_operation_activities'||at_apps_link||' gao, '
    ||'     gmd_operation_resources'||at_apps_link||' gmd, '
    ||'     cr_rsrc_dtl'||at_apps_link||' crd '
    ||'  WHERE gmp.oprn_id = gao.oprn_id  '
    ||'  AND gmp.oprn_id <> -1 '
    ||'  AND gao.OPRN_LINE_ID = gmd.OPRN_LINE_ID '
    ||'  AND gao.sequence_dependent_ind = 1 '
    ||'  AND gmd.prim_rsrc_ind = 1 '
    ||'  AND mtl.category_id = gmp.category_id  '
    ||'  AND crd.RESOURCES   = gmd.RESOURCES ' ;

    IF l_in_str_org  IS NOT NULL THEN
      rsrc_setup := rsrc_setup
      ||'  AND crd.ORGANIZATION_ID ' || l_in_str_org  ;
    END IF;

     EXECUTE IMMEDIATE rsrc_setup USING instance_id ;

     return_status := TRUE ;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL ;
      return_status := TRUE ;
    WHEN OTHERS THEN
      log_message('Write setups and Transitions Failed: '||sqlerrm||'-'||stmt_no);
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
  p_x_aps_fmeff_id   IN PLS_INTEGER
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

  IF ((stpdep_start_index > 0) AND (stpdep_end_index > 0) AND
      (stpdep_end_index >= stpdep_start_index)) THEN
   FOR stpdp_cnt IN stpdep_start_index..stpdep_end_index
   LOOP
    opr_stpdep_frm_seq_id(dep_index) := gmp_opr_stpdep_tbl(stpdp_cnt).x_dep_routingstep_id;
    opr_stpdep_to_seq_id(dep_index) := gmp_opr_stpdep_tbl(stpdp_cnt).x_routingstep_id;
    opr_stpdep_routing_sequence_id(dep_index) := p_x_aps_fmeff_id ;
    opr_stpdep_dependency_type(dep_index) := gmp_opr_stpdep_tbl(stpdp_cnt).dep_type;
    opr_stpdep_sr_instance_id(dep_index) := instance_id ;
    opr_stpdep_min_time_offset(dep_index) := gmp_opr_stpdep_tbl(stpdp_cnt).standard_delay;
    opr_stpdep_max_time_offset(dep_index) := gmp_opr_stpdep_tbl(stpdp_cnt).max_delay;
    opr_stpdep_trans_pct(dep_index) := gmp_opr_stpdep_tbl(stpdp_cnt).transfer_pct;
    opr_stpdep_frm_op_seq_num(dep_index) := gmp_opr_stpdep_tbl(stpdp_cnt).dep_routingstep_no;
    opr_stpdep_to_op_seq_num(dep_index) := gmp_opr_stpdep_tbl(stpdp_cnt).routingstep_no;
    opr_stpdep_app_to_chrg(dep_index) := gmp_opr_stpdep_tbl(stpdp_cnt).chargeable_ind;
    opr_stpdep_organization_id(dep_index) := effectivity.organization_id;
    opr_stpdep_creation_date(dep_index) := current_date_time ;
    opr_stpdep_last_update_date(dep_index) := current_date_time ;
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

FUNCTION enh_bsearch_stpno ( l_formula_id   IN PLS_INTEGER,
                             l_recipe_id    IN PLS_INTEGER,
                             l_item_id      IN PLS_INTEGER)
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
    mat_assoc_tab(ret_loc).inventory_item_id = l_item_id THEN
        RETURN ret_loc;
    ELSE
        ret_loc := ret_loc + 1;
    END IF;
    END LOOP;

    RETURN -1;

EXCEPTION WHEN OTHERS THEN
   log_message(' Error in gmp_bom_routing_pkg.enh_bsearch_stpno: '||SQLERRM);
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
PROCEDURE bsearch_unique (p_resource_id   IN PLS_INTEGER ,
                          p_category_id   IN PLS_INTEGER ,
                          p_setup_id      OUT NOCOPY PLS_INTEGER
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

/* ========================================================================= */
PROCEDURE extract_items
(
  at_apps_link  IN VARCHAR2,
  instance      IN INTEGER,
  run_date      IN DATE,
  return_status IN OUT NOCOPY BOOLEAN
)
IS
  c_item_cursor           ref_cursor_typ;

  retrieval_cursor        VARCHAR2(4096);
  insert_statement        VARCHAR2(4096);

  TYPE gmp_item_aps_typ  IS RECORD (
    item_no               VARCHAR2(32),
    item_id               PLS_INTEGER,
    category_id           NUMBER,   /* SGIDUGU */
    seq_dep_id            NUMBER,   /* SGIDUGU */
    seq_dpnd_class        VARCHAR2(8),   /* SGIDUGU */
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
    last_update_login     PLS_INTEGER ) ;

  gmp_item_aps_rec        gmp_item_aps_typ;

  i                       NUMBER ;

BEGIN
  i                       := 0;

  IF return_status THEN
    v_cp_enabled := TRUE;
  ELSE
    v_cp_enabled := FALSE;
  END IF;

   /* populate the org_string   */

     IF gmp_calendar_pkg.org_string(instance) THEN
        NULL ;
     ELSE
        RAISE invalid_string_value  ;
     END IF;

    l_in_str_org := gmp_calendar_pkg.g_in_str_org ; /* 3491625 */

  retrieval_cursor := 'DELETE FROM gmp_item_aps'||at_apps_link;
  EXECUTE IMMEDIATE retrieval_cursor;

  COMMIT;

/*   New Changes - Using mtl_organization_id from ic_whse_mst , instead of
 *        organization_id from sy_orgn_mst , Bug# 1252322
 *        */

  /* SGIDUGU - code added for Seq Dep */
  retrieval_cursor :=
                'SELECT iim.item_no, iim.item_id,nvl(iim.seq_category_id,-1), '
                ||'  t.seq_dep_id, '
                ||'  iim.seq_dpnd_class , '
                ||'  iim.item_um, mum.uom_code,iim.lot_ctl, iim.item_desc1, '
                ||'  msi.inventory_item_id, '
                ||'  iwm.mtl_organization_id, '
                ||'  pwe.whse_code, decode(sum(pwe.replen_ind), 0, 0, 1), '
                ||'  decode(sum(pwe.consum_ind), 0, 0, 1), '
                ||'  pwe.plant_code, iim.creation_date, iim.created_by, '
                ||'  iim.last_update_date,iim.last_updated_by, NULL '
                ||'  FROM  ic_item_mst'||at_apps_link||' iim,'
                ||'        sy_uoms_mst'||at_apps_link||' sou,'   /* B1540127 */
                ||'        ps_whse_eff'||at_apps_link||' pwe,'
                ||'        ic_whse_mst'||at_apps_link||' iwm,'
                ||'        mtl_system_items'||at_apps_link||' msi,'
                ||'        mtl_units_of_measure'||at_apps_link||' mum, '
                ||'        sy_orgn_mst'||at_apps_link||' som, '
                ||'        (SELECT category_id,seq_dep_id  '      /* SGIDUGU */
                ||'         FROM gmp_sequence_types'||at_apps_link   /* SGIDUGU
*/
                ||'         WHERE oprn_id = -1 '       /* SGIDUGU */
                ||'        ) t '
                ||'  WHERE iim.delete_mark = 0 '
                ||'    AND som.delete_mark = 0 '
                ||'    AND iim.inactive_ind = 0 '
                ||'    AND iim.item_no = msi.segment1 '
                ||'    AND iwm.mtl_organization_id = msi.organization_id '
                ||'    AND pwe.plant_code = som.orgn_code '
                ||'    AND pwe.whse_code = iwm.whse_code '
                ||'    AND sou.unit_of_measure = mum.unit_of_measure '
                ||'    AND sou.delete_mark = 0 ' ;
              IF l_in_str_org  IS NOT NULL THEN
                retrieval_cursor := retrieval_cursor
                ||'    AND iwm.mtl_organization_id ' || l_in_str_org ;
             END IF;
                retrieval_cursor := retrieval_cursor
                ||'    AND iim.item_um = sou.um_code '
                ||'    AND iim.experimental_ind = 0 '
                ||'    AND iim.seq_category_id = t.category_id (+) ' /* SGIDUGU
*/
                ||'    AND ( '
                ||'          pwe.whse_item_id IS NULL OR '
                ||'          pwe.whse_item_id = iim.whse_item_id OR '
                ||'          ( '
                ||'            pwe.whse_item_id = iim.item_id AND '
                ||'            iim.item_id <> iim.whse_item_id '
                ||'          ) '
                ||'        ) '
                ||' GROUP BY '
                ||'   iim.item_id, iim.item_no,iim.seq_category_id,t.seq_dep_id, '
                ||'   iim.seq_dpnd_class, '
                ||'   iim.item_desc1, iim.item_um, '
                ||'   iim.lot_ctl, pwe.whse_code, '
                ||'   pwe.plant_code, mum.uom_code, msi.inventory_item_id, '
                ||'   iwm.mtl_organization_id, '
                ||'   iim.creation_date, iim.created_by, iim.last_update_date, '
                ||'   iim.last_updated_by ' ;

  OPEN c_item_cursor FOR retrieval_cursor;

  /* SGIDUGU - added inserts for Category Id and Seq Dep Id */
  insert_statement :=
                'INSERT INTO gmp_item_aps'||at_apps_link||' '
                ||' ( '
                ||'  item_no, item_id,category_id,seq_dep_id,seq_dpnd_class, '
                ||'  item_um, uom_code, '
                ||'  lot_control, item_desc1, '
                ||'  aps_item_id, organization_id, whse_code, replen_ind,'
                ||'  consum_ind,  plant_code, creation_date, created_by, '
                ||'  last_update_date, last_updated_by, last_update_login '
                ||' ) '
                ||'  VALUES '
                ||' (:p1,:p2,:p3,:p4,:p5,:p6, '
                ||'  :p7,:p8,:p9,:p10,'
                ||'  :p11,:p12,:p13,:p14, '
                ||'  :p15,:p16,:p17,:p18,:p19,:p20)';

  FETCH c_item_cursor
  INTO  gmp_item_aps_rec;

  WHILE c_item_cursor%FOUND
  LOOP
    EXECUTE IMMEDIATE insert_statement USING
                 gmp_item_aps_rec.item_no,
                 gmp_item_aps_rec.item_id,
                 gmp_item_aps_rec.category_id,  /* SGIDUGU */
                 gmp_item_aps_rec.seq_dep_id,  /* SGIDUGU */
                 gmp_item_aps_rec.seq_dpnd_class,  /* SGIDUGU */
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
                 0;

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

  return_status := TRUE;

  EXCEPTION
    WHEN invalid_string_value  THEN
      log_message('Organization string is Invalid ' );
      return_status := FALSE;
    WHEN NO_DATA_FOUND THEN /* B3577871 */
      log_message(' NO_DATA_FOUND exception raised in Procedure: Gmp_bom_routing_pkg.Extract_Items ' );
      return_status := TRUE;
    WHEN OTHERS THEN
      log_message('Item extraction failed with error '||sqlerrm);
      return_status := FALSE;

END Extract_Items;

/*
REM+=========================================================================+
REM| FUNCTION NAME                                                           |
REM|    get_profile_value                                                    |
REM| DESCRIPTION                                                             |
REM|    This procedure is created to get the profile value from the source or|
REM|     destination server basing on the dblink                             |
REM| HISTORY                                                                 |
REM|    Vpedarla B6710684 created this procedure                             |
REM+=========================================================================+
*/
FUNCTION get_profile_value(
  profile_name            IN VARCHAR2,
  pdblink                 IN VARCHAR2) return VARCHAR2 IS
  uom_code_dblink         VARCHAR2(32767) ; /* bug: 6710684 Vpedarla */
  uom_code_ref            ref_cursor_typ ;
  l_gmp_um_code           VARCHAR2(32767);
BEGIN
LOG_MESSAGE(' GMP_BOM_ROUTING_PKG.get_profile_value called for profile '||profile_name||' with dblink '||pdblink);

uom_code_dblink := 'select fnd_profile.VALUE'||pdblink||'('''||profile_name||''')'||' from dual ';

     OPEN uom_code_ref for uom_code_dblink ;
         FETCH uom_code_ref INTO l_gmp_um_code;
     CLOSE uom_code_ref;
     RETURN l_gmp_um_code ;
END get_profile_value;

/*
REM+=========================================================================+
REM| FUNCTION NAME                                                           |
REM|    search_operation_leadtime                                           |
REM| DESCRIPTION                                                             |
REM|                                                                         |
REM| HISTORY                                                                 |
REM| 04/12/2008 Vpedarla  Created new procedure for bug 7391495              |
REM+=========================================================================+
*/
PROCEDURE search_operation_leadtime (p_fmeff_id IN PLS_INTEGER ,
			  p_organization_id IN NUMBER,
              top OUT NOCOPY INTEGER,
              bottom OUT NOCOPY INTEGER) IS
i INTEGER ;
BEGIN
     top    := -1;
     bottom := -1 ;

   i := 1  ;
   FOR i IN 1..oper_leadtime_size
   LOOP

     IF (top = -1 AND oper_leadtime_percent(i).fmeff_id = p_fmeff_id
          AND  oper_leadtime_percent(i).organization_id = p_organization_id )   THEN
           top := i;
     END IF;
     IF (top <> -1 AND oper_leadtime_percent(i).fmeff_id = p_fmeff_id
          AND  oper_leadtime_percent(i).organization_id = p_organization_id )   THEN
            bottom := i;
     END IF;
     IF oper_leadtime_percent(i).fmeff_id > p_fmeff_id THEN
           EXIT ;
     END IF;
   END LOOP ;
   IF ( top = -1 ) THEN
    bottom := -1;
   END IF;

END search_operation_leadtime ;

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

END GMP_BOM_ROUTING_PKG;

/
