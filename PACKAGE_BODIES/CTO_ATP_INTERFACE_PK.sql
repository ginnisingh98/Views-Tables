--------------------------------------------------------
--  DDL for Package Body CTO_ATP_INTERFACE_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CTO_ATP_INTERFACE_PK" AS
/* $Header: CTOATPIB.pls 115.70 2003/10/10 22:29:08 ksarkar ship $ */

 G_PKG_NAME CONSTANT VARCHAR2(30) := 'CTO_ATP_INTERFACE_PK';
/*
** Steps for evaluate_om_shipset
** -----------------------------
**
** 1) Get ship set
** 2) get additional info from OEOL, MSYI, BIC
** 3) return ship set if no models or config items( atp may be doing this )
** 4) eliminate mandatory components and stand alone standard items
** 5) arrange data for sparse array traversal
** 6) populate level
** 7) populate parent ato
** 8) unscramble array
** 9) order information by top model line id, level
** 10) check whether ship set involves sourcing and identify sources
** 11) return if no sourcing found [Eliminate pure pto ?]
** 12) filter/prepare structure for calling BOM API
** 13) call BOM API
** 14) prepare ship set for atp
** 15) send the shipset and BOM to ATP.
**
*/

/*
** This record holds data for each line_id for evaluating shipset
*/
TYPE CTO_SHIPSET_TYPE IS RECORD (
ship_set_name        varchar2(200) ,
header_id            number ,
line_id              number,
top_model_line_id    number,
ato_line_id          number ,
link_to_line_id      number ,
inventory_item_id    oe_order_lines.inventory_item_id%type ,
item_type_code       oe_order_lines.item_type_code%type ,
wip_supply_type      bom_inventory_components.wip_supply_type%type ,
bom_item_type           mtl_system_items.bom_item_type%type ,
replenish_to_order_flag mtl_system_items.replenish_to_order_flag%type ,
pick_components_flag    mtl_system_items.pick_components_flag%type ,
base_item_id            mtl_system_items.base_item_id%type ,
build_in_wip_flag       mtl_system_items.build_in_wip_flag%type  ,
buy_model            varchar2(1) , /* added for procure config 'B', 'Y' , 'N' */
/* value 'B' has been introduced to flag the top buy model. value 'Y' has been ointroduced to flag all the buy model components excluding the top buy model. The attribute_05 = 'N' will be set for visible demand */

configuration_exists varchar2(1), /* 'Y' , 'N' to indicate configuration exists, this data will be used to decide what to populate in visible demand flag */
plan_level           number(3) ,
parent_ato_line_id   number(9) ,
sourcing_org         number ,
ordered_quantity     number ,
bom_exists           boolean ,
mandatory_component  boolean ,
sourced_components    boolean ,
top_model_ato        boolean ,
location             number ,
error_code           number ,
error_message        varchar2(200) ,
unique_id            number(9) ,
auto_generated       boolean,  /* changes for navneet */
process_demand	     boolean,
atp_flag	     varchar2(1),	-- 2462661
atp_components_flag  varchar2(1),	-- 2462661
stored_atp_flag	     varchar2(1)	-- 2462661
,mlmo_flag	     varchar2(1)	-- 2723674
);

/*
** This record holds processed information for atp requests from configurator
*/
TYPE CZ_REQUESTS_TYPE IS RECORD (
ship_set_name                varchar2(200) ,
configurator_session_key     cz_atp_requests.configurator_session_key%type ,
seq_no                       cz_atp_requests.seq_no%type ,
Item_key                     cz_atp_requests.item_key%type ,
quantity                     cz_atp_requests.quantity%type ,
UOM_CODE                     cz_atp_requests.UOM_CODE%type ,
inv_org_id                   cz_atp_requests.inv_org_id%type ,
ship_To_date                 cz_atp_requests.ship_to_date%type  ,
inventory_item_id            mtl_system_items.inventory_item_id%type ,
self_code                    cz_atp_requests.item_key%type ,
parent_code                  cz_atp_requests.item_key%type ,
top_model_code               cz_atp_requests.item_key%type ,
config_item_id               cz_atp_requests.config_item_id%type , /* Added for MI */
parent_config_item_id        cz_atp_requests.parent_config_item_id%type , /* Added for MI */
line_id                      number ,
link_to_line_id              number ,
ato_line_id                  number ,
item_type_code               oe_order_lines.item_type_code%type ,
wip_supply_type              bom_inventory_components.wip_supply_type%type ,
bom_item_type                mtl_system_items.bom_item_type%type ,
replenish_to_order_flag      mtl_system_items.replenish_to_order_flag%type ,
pick_components_flag         mtl_system_items.pick_components_flag%type ,
base_item_id                 mtl_system_items.base_item_id%type ,
build_in_wip_flag            mtl_system_items.build_in_wip_flag%type  ,
top_model_ato                boolean ,
top_model_line_id            number ,
assigned                     boolean ,
location                     number ,
parent_location              number,
atp_flag		     varchar2(1),	--2462661
atp_components_flag	     varchar2(1)	--2462661
) ;

/*
** This record holds status ( sourcing, success, start location ) for each shipset
*/
TYPE SHIPSET_SUCCESS_REC_TYPE IS RECORD (
ship_set_name         varchar2(200) ,
success_status          boolean  ,
model_sourced         boolean ,
start_location        number ,
cto_start_location         number ,
reduced_start_location         number  ,
auto_generated           boolean,
process_demand	boolean
) ;

/* 2723674  -- record to hold SLSO lines for flushing demand */
TYPE SLSO_CTO_SHIPSET_TYPE IS RECORD (
ship_set_name        varchar2(200) ,
ato_line_id          number
);
slso_index	number  := 0;
rows_deleted	number ;
/* 2723674 end new record type creation */

/*
** This record holds autogenerated shipset names and whether to process demand for them or not
*/
TYPE AUTO_SHIPSET_REC_TYPE IS RECORD (
set_name varchar2(200) ,
process_demand	boolean
);

ginstance_id     number;

NULL_MRP_ASSIGNMENT_SET EXCEPTION ;
INVALID_MRP_ASSIGNMENT_SET EXCEPTION ;

TYPE CTO_SHIPSET_TBL_TYPE is table of CTO_SHIPSET_TYPE INDEX BY BINARY_INTEGER ;
TYPE CZ_REQUESTS_TBL_TYPE is table of CZ_REQUESTS_TYPE INDEX BY BINARY_INTEGER ;
TYPE SHIPSET_SUCCESS_TBL_TYPE is table of SHIPSET_SUCCESS_REC_TYPE INDEX BY BINARY_INTEGER ;

TYPE AUTO_SHIPSET_TBL_TYPE is table of AUTO_SHIPSET_REC_TYPE INDEX BY BINARY_INTEGER ;

/* 2723674 new table type creation */
TYPE SLSO_SHIPSET_TBL_TYPE is table of SLSO_CTO_SHIPSET_TYPE INDEX BY BINARY_INTEGER ;
/* 2723674 end new table type creation */

g_requests_tab        CZ_REQUESTS_TBL_TYPE ;
g_shipset_status_tbl  SHIPSET_SUCCESS_TBL_TYPE ;

/* common table to store information to be dumped into bom_cto_order_demand */
g_final_cto_shipset     CTO_SHIPSET_TBL_TYPE ; /* package global array */
g_cto_shipset     CTO_SHIPSET_TBL_TYPE ; /* package global array */
g_cto_sparse_shipset     CTO_SHIPSET_TBL_TYPE ; /* package global sparse array */
local_cto_shipset     CTO_SHIPSET_TBL_TYPE ; /* package global variable */
g_shipset      MRP_ATP_PUB.ATP_REC_TYP  ;
g_final_shipset      MRP_ATP_PUB.ATP_REC_TYP  ;

g_auto_generated_shipset  AUTO_SHIPSET_TBL_TYPE ;

g_expected_error_code   number ;
g_stmt_num Number ;
gUserId        number ;
gLoginId        number ;
gMrpAssignmentSet        number ;
gMrpAssignmentSetName        varchar2(80) ;

slso_shipset	SLSO_SHIPSET_TBL_TYPE ; /* 2723674 */


/*********************************
 API for data initialization
*********************************/

PROCEDURE initialize_session_globals;

PG_DEBUG Number := NVL(FND_PROFILE.value('ONT_DEBUG_LEVEL'), 0);

PROCEDURE initialize_assignment_set( x_return_status out varchar2)  ;

/*********************************
 API for Business logic Processing
**********************************/

PROCEDURE evaluate_shipset(
  p_shipset            in out NOCOPY MRP_ATP_PUB.ATP_REC_TYP
, p_auto_generated     in    boolean
, p_process_demand     in    boolean
, p_atp_bom_rec        out  NOCOPY MRP_ATP_PUB.ATP_BOM_REC_TYP
, p_model_sourced      out  boolean
, x_return_status      out varchar2
);

PROCEDURE populate_cz_shipset(
  p_shipset                in out NOCOPY MRP_ATP_PUB.ATP_REC_TYP
, p_orig_shipsEt_tracker   in out NOCOPY CTO_SHIPSET_TBL_TYPE
, p_shipset_contains_model in out boolean
, x_return_status             out varchar2
);

PROCEDURE populate_om_shipset(
  p_shipset                in out NOCOPY MRP_ATP_PUB.ATP_REC_TYP
, p_orig_shipset_tracker   in out NOCOPY CTO_SHIPSET_TBL_TYPE
, p_shipset_contains_model in out boolean
, x_return_status             out varchar2
);

PROCEDURE process_sourcing_chain(
  p_top_location     number
, p_location         number
, p_org              number
, p_isPhantom        boolean
, p_isProcured       boolean
, p_basis_qty        number
, x_return_status             out varchar2
);

PROCEDURE query_sourcing_org(
  p_inventory_item_id    NUMBER
, p_organization_id      NUMBER
, p_sourcing_rule_exists out varchar2
, p_source_type          out NUMBER
, p_sourcing_org         out NUMBER
, p_transit_lead_time    out NUMBER
, x_return_status        out varchar2
);


/************************************************************
 Convenience API for data relationship query and manipulation
*************************************************************/

PROCEDURE propagate_ato_line_id(
  p_location         number
)  ;

PROCEDURE populate_plan_level(
  p_t_bcol  in out NOCOPY CTO_SHIPSET_TBL_TYPE
);

PROCEDURE populate_parent_ato(
  p_t_bcol  in out NOCOPY CTO_SHIPSET_TBL_TYPE
, p_bcol_line_id in      oe_order_lines.line_id%type
);

/*********************************************************************
 API for saving state of shipset and reconstructing it on demand
***********************************************************************/

PROCEDURE save_shipset(
  p_shipset in MRP_ATP_PUB.ATP_REC_TYP
, x_return_status out     varchar2
);

PROCEDURE resurrect_shipset(
  p_shipset in out NOCOPY MRP_ATP_PUB.ATP_REC_TYP
, p_success_flag  in     boolean
, x_return_status out     varchar2
, x_msg_count     out     number
, x_msg_data      out     varchar2
) ;

PROCEDURE populate_configuration_status ;

PROCEDURE populate_visible_demand(
  p_shipset    in out NOCOPY MRP_ATP_PUB.ATP_REC_TYP
, p_success_flag in boolean
, x_return_status out     varchar2
, x_msg_count     out     number
, x_msg_data      out     varchar2
);

PROCEDURE reconstruct_shipset(
  p_shipset    in out NOCOPY MRP_ATP_PUB.ATP_REC_TYP
, p_success_flag_tbl in MRP_ATP_PUB.SHIPSET_STATUS_REC_TYPE
, x_return_status out     varchar2
, x_msg_count     out     number
, x_msg_data      out     varchar2
);

/*****************************
 API for registering errors
******************************/

PROCEDURE register_error(
  p_ship_set_name in varchar2
, p_line_id       in number
, p_error_code    in number
, p_action        in number
, p_status        in boolean
, x_return_status out varchar2
);

PROCEDURE populate_error(
  p_shipset   in out NOCOPY MRP_ATP_PUB.ATP_REC_TYP
, x_return_status out varchar2
);

/*************************************************************
 API for summarizing/manipulating information at Shipset Level
**************************************************************/

PROCEDURE isAutoGeneratedShipset(
  p_ship_set_name in varchar2,
  x_auto_gen out boolean,
  x_process_demand out boolean
);

FUNCTION get_shipset_success_index(
  p_ship_set_name in varchar2
)
return number ;

PROCEDURE default_ship_set_name( p_shipset in out NOCOPY MRP_ATP_PUB.ATP_REC_TYP ) ;


/***********************************************************
Convenience API for Displaying Information to aid debugging
************************************************************/

PROCEDURE show_contents( p_shipset_tracker IN CTO_SHIPSET_TBL_TYPE ) ;

PROCEDURE print_shipset( p_shipset IN MRP_ATP_PUB.ATP_REC_TYP ) ;

PROCEDURE print_shipset_capacity( p_shipset IN MRP_ATP_PUB.ATP_REC_TYP ) ;

FUNCTION get_shipset_status(
                            p_shipset_tbl  IN MRP_ATP_PUB.SHIPSET_STATUS_REC_TYPE,
                            p_shipset_name IN varchar2
                            ) RETURN VARCHAR2;

FUNCTION get_shipset_source_flag(
                                  p_shipset_name IN varchar2
                                  ) RETURN BOOLEAN;


/**************************************************
 Convenience API for record Cloning/Deletion
**************************************************/

PROCEDURE remove_elements_from_bom_rec(
 p_bom_rec  in out NOCOPY MRP_ATP_PUB.ATP_BOM_REC_TYP
);

PROCEDURE remove_elements_from_atp_rec(
 p_atp_rec  in out NOCOPY MRP_ATP_PUB.ATP_REC_TYP
);

PROCEDURE Assign_Atp_Bom_Rec (
	p_src_atp_bom	IN OUT NOCOPY MRP_ATP_PUB.atp_bom_rec_typ,
        p_src_location  in     number ,
        p_des_atp_bom   IN OUT NOCOPY MRP_ATP_PUB.atp_bom_rec_typ ,
	x_return_status  out varchar2 ,
        x_msg_data       out varchar2 ,
        x_msg_count      out number ) ;


/**************************************
** Doubts Resolved during Development *
***************************************
** 1) Can phantom model have a sourcing rule: Yes,
** ignore the sourcing rule for the phantom and any items below it.
** Use the sourcing org of the non phantom parent for phantom model and its descendants
** 2) Chain Sourcing rules to get the final sourcing org.
** 3) Provide WIP supply type in BOM structure to ATP for ATP check.
** 4) Treat Multi-level and Multi-Org models in the same way.
*/


/*
** Issues Resolved
*****************
** Need to provide expected error for null shipset name
** Need to provide expected error for invalid validation org
**
*/


/*
** This procedure is the entry procedure to perform pre-atp related operations.
** This procedure accepts one or more shipsets and provides the bom's for all components of an ATO model
** in a sourced shipset. A shipset is considered to be sourced if it contains a sourced model.
** Processing Steps
** 1) separate shipset from group of shipsets ( on change of shipset name )
** 2) evaluate one shipset at a time
** 3) if error found abort any further processing, cleanup may be required
** 4) if no error add enhanced shipset, supplementary BOM array to their respective collection.
** 5) store the status of the shipset ( sourced, etc. ) in shipset_status structure
** 6) return appropriate result to caller
*/
PROCEDURE get_atp_bom(
  p_shipset          in out   NOCOPY MRP_ATP_PUB.ATP_REC_TYP
, p_atp_bom_rec         out   NOCOPY MRP_ATP_PUB.ATP_BOM_REC_TYP
, x_return_status       out          varchar2
, x_msg_count           out          number
, x_msg_data            out          varchar2
)
is
l_stmt_num Number ;
l_return_status varchar2(1) ;
v_shipset          MRP_ATP_PUB.ATP_REC_TYP  ;
v_reduced_shipset          MRP_ATP_PUB.ATP_REC_TYP  ;
v_null_atp_rec		MRP_ATP_PUB.ATP_REC_TYP  ;
v_atp_bom_rec      MRP_ATP_PUB.ATP_BOM_REC_TYP ;
v_ship_set_name    varchar2(200) ;
v_prev_ship_set_name varchar2(200) ;
v_cto_shipset_count  number ;
v_bomrec_count  number ;
v_model_sourced  boolean ;
v_shipset_line_processed number ;
v_start_location      number ;
 l_file_val varchar2(60) ;
v_auto_gen boolean;
v_process_demand boolean;

BEGIN

   l_stmt_num := 10 ;

   x_return_status := FND_API.G_RET_STS_SUCCESS ;

   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('***get_atp_bom: ' ||  ' Entered get_atp_bom' , 1);
   	oe_debug_pub.add('get_atp_bom: ' ||  ' identifier ' || p_shipset.identifier.count || ' inventory ' ||  p_shipset.inventory_item_id.count || ' ship_set_name ' ||  p_shipset.ship_set_name.count, 3);

	l_stmt_num := 40 ;
	print_shipset_capacity( p_shipset ) ;
   	print_shipset( p_shipset ) ;
   END IF;

   l_stmt_num := 80 ;

   /* initialize session specific variables */
   initialize_session_globals ;

   gUserId := nvl(fnd_global.user_id, -1);
   gLoginId := nvl(fnd_global.login_id, -1);

   /* get assignment set and check its validity */
   initialize_assignment_set( x_return_status ) ;

   IF( x_return_status = FND_API.G_RET_STS_ERROR ) THEN
       FOR l_error_loc IN
           p_shipset.ship_set_name.first..p_shipset.ship_set_name.last
       LOOP
           p_shipset.error_code(l_error_loc) := 65 ;
       END LOOP ;
       RAISE FND_API.G_EXC_ERROR ;
   ELSIF( x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
   END IF ;

   l_stmt_num := 90 ;

   FOR v_init IN p_shipset.ship_set_name.first..p_shipset.ship_set_name.last
   LOOP
      IF ( p_shipset.ship_set_name(v_init ) is null
		AND p_shipset.arrival_set_name(v_init ) is null) THEN

	  IF PG_DEBUG <> 0 THEN
	  	oe_debug_pub.add('get_atp_bom: ' ||  'Both ship set and arrival set are null', 2);
	  END IF;

          p_shipset.ship_set_name(v_init) := p_shipset.identifier(v_init) ;

          g_auto_generated_shipset(g_auto_generated_shipset.count + 1 ).set_name := to_char( p_shipset.identifier(v_init)) ;
	  g_auto_generated_shipset(g_auto_generated_shipset.count ).process_demand := FALSE;

      ELSIF ( p_shipset.ship_set_name(v_init ) is null
		AND p_shipset.arrival_set_name(v_init ) is not null) THEN

	  IF PG_DEBUG <> 0 THEN
	  	oe_debug_pub.add('get_atp_bom: ' ||  'Arrival set is not null', 2);
	  END IF;

          p_shipset.ship_set_name(v_init) := p_shipset.arrival_set_name(v_init) ;

          g_auto_generated_shipset(g_auto_generated_shipset.count + 1 ).set_name := p_shipset.arrival_set_name(v_init);
	  g_auto_generated_shipset(g_auto_generated_shipset.count ).process_demand := TRUE;

      END IF ;

   END LOOP ;

   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('get_atp_bom: ' ||  'Printing p_shipset after populating set name' , 2 );
	print_shipset( p_shipset ) ;
   END IF;

   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('get_atp_bom: ' ||  'Going to print g_auto_generated_shipset ' || g_auto_generated_shipset.count , 2 );
   END IF;

   FOR auto_gen_count IN 1..g_auto_generated_shipset.count
   LOOP
      	IF PG_DEBUG <> 0 THEN
      		oe_debug_pub.add('get_atp_bom: ' ||  'Shipset name::'||g_auto_generated_shipset(auto_gen_count).set_name, 2);
      	END IF;
	IF g_auto_generated_shipset(auto_gen_count).process_demand THEN
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('get_atp_bom: ' ||  'Process Demand flag::TRUE', 2);
		END IF;
	ELSE
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('get_atp_bom: ' ||  'Process Demand flag::FALSE', 2);
		END IF;
	END IF;
   END LOOP ;


   l_stmt_num := 100 ;
   v_prev_ship_set_name := p_shipset.ship_set_name( nvl( p_shipset.ship_set_name.first, p_shipset.identifier.first)  ) ;
   v_ship_set_name := p_shipset.ship_set_name( nvl( p_shipset.ship_set_name.first, p_shipset.identifier.first)  ) ;

   v_shipset_line_processed := 0;
   v_start_location:= 1;

   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('get_atp_bom: ' ||  'Iterate through each shipset element and evaluate shipset on change of shipset name ' , 1);
   END IF;

   l_stmt_num := 120 ;

   FOR i IN p_shipset.ship_set_name.first..p_shipset.ship_set_name.last
   LOOP
      v_prev_ship_set_name := v_ship_set_name ;
      v_ship_set_name := nvl( p_shipset.ship_set_name(i), p_shipset.identifier(i)) ;

      l_stmt_num := 140 ;

      IF( v_ship_set_name = v_prev_ship_set_name ) THEN

         /*
         ** copy p_shipset into v_shipset and evaluate one shipset at a time
         */
         l_stmt_num := 160 ;

         MRP_ATP_PVT.assign_atp_input_rec(
            p_shipset,
            i,
            v_shipset,
            l_return_status );

         v_shipset_line_processed := v_shipset_line_processed + 1;

      ELSE

         IF PG_DEBUG <> 0 THEN
         	oe_debug_pub.add('get_atp_bom: ' ||  'Shipset name ' || v_ship_set_name , 1 );
         	oe_debug_pub.add('get_atp_bom: ' ||  'Previous shipset name ' || v_prev_ship_set_name , 1 );
         END IF;

         /*
         ** call evaluate shipset for accumulated components
         */

         IF PG_DEBUG <> 0 THEN
         	oe_debug_pub.add('get_atp_bom: ' || 'Going to evaluate shipset ' ,1);
         END IF;

         l_stmt_num := 180 ;

         /* add name of shipset to shipset table  */

         IF( v_shipset.ship_set_name.first is not null ) THEN
            g_shipset_status_tbl(g_shipset_status_tbl.count + 1 ).ship_set_name := v_shipset.ship_set_name( v_shipset.ship_set_name.first );

            isAutoGeneratedShipset(
		v_shipset.ship_set_name( v_shipset.ship_set_name.first),
		v_auto_gen,
		v_process_demand);

	    IF PG_DEBUG <> 0 THEN
	    	oe_debug_pub.add('get_atp_bom: ' || 'isAutoGeneratedShipset returned following values for shipset::'||v_shipset.ship_set_name( v_shipset.ship_set_name.first), 3);
	    END IF;
	    IF v_auto_gen THEN
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('get_atp_bom: ' || 'v_auto_gen::TRUE', 3);
		END IF;
	    ELSE
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('get_atp_bom: ' || 'v_auto_gen::FALSE', 3);
		END IF;
	    END IF;
	    IF v_process_demand THEN
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('get_atp_bom: ' || 'v_process_demand::TRUE', 3);
		END IF;
	    ELSE
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('get_atp_bom: ' || 'v_process_demand::FALSE', 3);
		END IF;
	    END IF;

	    g_shipset_status_tbl(g_shipset_status_tbl.count).auto_generated := v_auto_gen;
	    g_shipset_status_tbl(g_shipset_status_tbl.count).process_demand := v_process_demand;

         END IF ;

         l_stmt_num := 200 ;

         evaluate_shipset(
            v_shipset
         , g_shipset_status_tbl(g_shipset_status_tbl.count).auto_generated
	 , g_shipset_status_tbl(g_shipset_status_tbl.count).process_demand
         , v_atp_bom_rec
         , v_model_sourced
         , l_return_status
         ) ;

         IF PG_DEBUG <> 0 THEN
         	oe_debug_pub.add('get_atp_bom: ' || 'Evaluate shipset returned ' || l_return_status  ,1);
         END IF;


         /*
         ** perform all cleanup operations in case of an expected error
         ** no cleanup is required for unexpected error
         */
         IF( l_return_status = FND_API.G_RET_STS_ERROR ) THEN

            l_stmt_num := 205 ;

            /*
            ** copy enhanced shipset returned by evaluate_shipset in to v_reduced_shipset
            */
            for k in v_shipset.ship_set_name.first..v_shipset.ship_set_name.last
            LOOP
               MRP_ATP_PVT.assign_atp_input_rec(
                 v_shipset,
                 k,
                 v_reduced_shipset,
                 l_return_status );
            END LOOP ;

            l_stmt_num := 210 ;

            --remove_elements_from_atp_rec( p_shipset ) ;
	    p_shipset := v_null_atp_rec;

            l_stmt_num := 215 ;

            /*
            ** add contents of v_reduced_shipset for current shipset
            ** to accumulated collection of enhanced shipsets
            */
            for k in v_shipset.ship_set_name.first..v_shipset.ship_set_name.last
            LOOP
             MRP_ATP_PVT.assign_atp_input_rec(
                 v_reduced_shipset,
                 k,
                 p_shipset,
                 l_return_status );
            END LOOP ;

            RAISE FND_API.G_EXC_ERROR ;

         ELSIF( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN

              RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
         /*
         ** END of cleanup operation for expected error
         */
         END IF ;

         l_stmt_num := 217 ;
         /*
         ** store information for model sourcing and start location in shipset status table
         */
         IF( v_shipset.ship_set_name.first is not null ) THEN
           IF( v_model_sourced ) THEN
             g_shipset_status_tbl(g_shipset_status_tbl.count ).model_sourced := TRUE ;
             g_shipset_status_tbl(g_shipset_status_tbl.count ).start_location := v_start_location ;
           ELSE
             g_shipset_status_tbl(g_shipset_status_tbl.count ).model_sourced := FALSE ;
             g_shipset_status_tbl(g_shipset_status_tbl.count ).start_location := v_start_location ;
           END IF ;
         END IF ;

         l_stmt_num := 220 ;

         IF( v_atp_bom_rec.assembly_identifier.count > 0 )
         THEN
             /*
             ** accumulate bom provided
             */
             l_stmt_num := 240 ;

             FOR j IN v_atp_bom_rec.assembly_identifier.first..v_atp_bom_rec.assembly_identifier.last
             LOOP

                l_stmt_num := 260 ;

                IF( v_atp_bom_rec.assembly_identifier.exists(j) ) THEN

                     l_stmt_num := 280 ;
                     assign_atp_bom_rec(
                                     v_atp_bom_rec
                                   , j
                                   , p_atp_bom_rec
                                   , x_return_status
                                   , x_msg_count
                                   , x_msg_data ) ;
                END IF ;
             END LOOP ;
          END IF ;

          /*
          ** copy transformed v_shipset into v_reduced_shipset
          */
          l_stmt_num := 300 ;

          FOR k IN v_shipset.ship_set_name.first..v_shipset.ship_set_name.last
          LOOP

              l_stmt_num := 320 ;

              MRP_ATP_PVT.assign_atp_input_rec(
                   v_shipset,
                   k,
                   v_reduced_shipset,
                   l_return_status );

          END LOOP ;

          /*
          ** remove bom records to initialize it
          */
          l_stmt_num := 340 ;

          remove_elements_from_bom_rec( v_atp_bom_rec ) ;

          /*
          ** remove v_shipset records to intialize it
          */
          l_stmt_num := 360 ;

          --remove_elements_from_atp_rec( v_shipset ) ;
	  v_shipset := v_null_atp_rec;

          /*
          ** copy current element encountered on change of shipset from p_shipset into v_shipset
          */
          l_stmt_num := 380 ;

          MRP_ATP_PVT.assign_atp_input_rec(
            p_shipset,
            i,
            v_shipset,
            l_return_status );

          v_shipset_line_processed := v_shipset_line_processed + 1;
          v_start_location := v_shipset_line_processed ;

       END IF ;

       l_stmt_num := 400 ;

       g_cto_shipset.delete ;
       g_cto_sparse_shipset.delete ;

   END LOOP ;


   /*
   ** repeat all the above iterations for the last shipset
   ** if there is only one shipset to be processed this
   ** is where all the processing takes place
   */
   l_stmt_num := 420 ;

   IF( v_shipset.ship_set_name.first is not null ) THEN

       g_shipset_status_tbl(g_shipset_status_tbl.count + 1 ).ship_set_name :=
           v_shipset.ship_set_name( v_shipset.ship_set_name.first ) ;

	isAutoGeneratedShipset(
		v_shipset.ship_set_name( v_shipset.ship_set_name.first),
		v_auto_gen,
		v_process_demand);

	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('get_atp_bom: ' || 'isAutoGeneratedShipset returned following values for shipset::'||v_shipset.ship_set_name( v_shipset.ship_set_name.first), 3);
	END IF;

	IF v_auto_gen THEN
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('get_atp_bom: ' || 'v_auto_gen::TRUE', 3);
		END IF;
	ELSE
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('get_atp_bom: ' || 'v_auto_gen::FALSE', 3);
		END IF;
	END IF;
	IF v_process_demand THEN
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('get_atp_bom: ' || 'v_process_demand::TRUE', 3);
		END IF;
	ELSE
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('get_atp_bom: ' || 'v_process_demand::FALSE', 3);
		END IF;
	END IF;

	g_shipset_status_tbl(g_shipset_status_tbl.count).auto_generated := v_auto_gen;
	g_shipset_status_tbl(g_shipset_status_tbl.count).process_demand := v_process_demand;

   END IF;

   l_stmt_num := 440 ;

   evaluate_shipset(
            v_shipset
          , g_shipset_status_tbl(g_shipset_status_tbl.count).auto_generated
	  , g_shipset_status_tbl(g_shipset_status_tbl.count).process_demand
          , v_atp_bom_rec
          , v_model_sourced
          , l_return_status
          ) ;

   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('get_atp_bom: ' || 'Evaluate shipset returned ' || l_return_status  ,1);
   END IF;

   IF( l_return_status = FND_API.G_RET_STS_ERROR ) THEN

            l_stmt_num := 445 ;

            FOR k IN v_shipset.ship_set_name.first..v_shipset.ship_set_name.last
            LOOP
               MRP_ATP_PVT.assign_atp_input_rec(
                 v_shipset,
                 k,
                 v_reduced_shipset,
                 l_return_status );
            END LOOP ;

            l_stmt_num := 450 ;

            --remove_elements_from_atp_rec( p_shipset ) ;
	    p_shipset := v_null_atp_rec;

            l_stmt_num := 455 ;

            FOR k IN v_reduced_shipset.ship_set_name.first..v_reduced_shipset.ship_set_name.last
            LOOP
             MRP_ATP_PVT.assign_atp_input_rec(
                 v_reduced_shipset,
                 k,
                 p_shipset,
                 l_return_status );
            END LOOP ;

            IF PG_DEBUG <> 0 THEN
		print_shipset( p_shipset ) ;
             	oe_debug_pub.add('get_atp_bom: ' ||  ' going to raise expected error ' , 1 );
            END IF;

            RAISE FND_API.G_EXC_ERROR ;

   ELSIF( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
   END IF ;

   l_stmt_num := 460 ;

   /* add sourcing status of shipset to sourced shipsets */
   IF( v_shipset.ship_set_name.first is not null ) THEN

     IF( v_model_sourced ) THEN
       g_shipset_status_tbl(g_shipset_status_tbl.count ).model_sourced := TRUE ;
       g_shipset_status_tbl(g_shipset_status_tbl.count ).start_location := v_start_location ;
      ELSE
       g_shipset_status_tbl(g_shipset_status_tbl.count ).model_sourced := FALSE ;
       g_shipset_status_tbl(g_shipset_status_tbl.count ).start_location := v_start_location ;
      END IF ;
   END IF ;

   l_stmt_num := 480 ;

   IF( v_atp_bom_rec.assembly_identifier.count > 0 ) THEN
   /*
   ** copy atp_bom_rec into p_atp_bom_rec
   */
   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('get_atp_bom: ' ||  ' Copy atp_bom_rec into p_atp_bom_rec ' || v_atp_bom_rec.assembly_identIFier.count , 2);
   END IF;

   l_stmt_num := 500 ;

   FOR j IN v_atp_bom_rec.assembly_identifier.first..v_atp_bom_rec.assembly_identifier.last
   LOOP
      IF( v_atp_bom_rec.assembly_identifier.exists(j) ) THEN

          l_stmt_num := 520 ;
          assign_atp_bom_rec(
                         v_atp_bom_rec
                       , j
                       , p_atp_bom_rec
                       , x_return_status
                       , x_msg_count
                       , x_msg_data ) ;
      END IF ;
   END LOOP ;

   END IF ;

   /*
   ** copy transformed v_shipset into v_reduced_shipset
   */
   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('get_atp_bom: ' ||  'Copy transformed v_shipset into v_reduced_shipset ' , 2 );
   END IF;

   l_stmt_num := 540 ;

   FOR k IN v_shipset.ship_set_name.first..v_shipset.ship_set_name.last
   LOOP
             MRP_ATP_PVT.assign_atp_input_rec(
                 v_shipset,
                 k,
                 v_reduced_shipset,
                 l_return_status );
   END LOOP ;

   l_stmt_num := 560 ;

   /* remove elements from p_shipset to initialize it */
   /* For each new element added to the rec by ATP, we need
      to modify this API. Instead, we are nullifying the atp rec */
   --remove_elements_from_atp_rec( p_shipset ) ;
   p_shipset := v_null_atp_rec;

   /*
   ** Assign shipset to Send reduced shipset back to calling module
   */

   l_stmt_num := 580 ;

   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('get_atp_bom: ' ||  'v_reduced_shipset count ' || v_reduced_shipset.ship_set_name.count , 1 );
   END IF;

   FOR k IN v_reduced_shipset.ship_set_name.first..v_reduced_shipset.ship_set_name.last
   LOOP
             MRP_ATP_PVT.assign_atp_input_rec(
                 v_reduced_shipset,
                 k,
                 p_shipset,
                 l_return_status );
   END LOOP ;

  --
  -- The auto-generated shipset names should be transparent to ATP. Hence,
  -- we null them out before sending the reduced shipset to ATP. We will
  -- re-generate them in the post-ATP call (bug 2598745)
  --
  IF PG_DEBUG <> 0 THEN
  	oe_debug_pub.add('get_atp_bom: ' ||  'Going to null out auto-generated shipset names in pre-ATP call ' ,2 );
  END IF;

  FOR v_auto_shipset IN p_shipset.ship_set_name.first..p_shipset.ship_set_name.last
  LOOP

      isAutoGeneratedShipset(
	p_shipset.ship_set_name(v_auto_shipset),
	v_auto_gen,
	v_process_demand);

      IF v_auto_gen THEN
	  IF PG_DEBUG <> 0 THEN
	  	oe_debug_pub.add('get_atp_bom: ' ||  'Nulled out shipset name '||p_shipset.ship_set_name(v_auto_shipset) ,3 );
	  END IF;
          p_shipset.ship_set_name(v_auto_shipset) := null ;
      END IF ;

  END LOOP ;	-- bug 2598745


   /*
   ** remove bom records to intialize it
   */
   l_stmt_num := 600 ;
   remove_elements_from_bom_rec( v_atp_bom_rec ) ;

   /*
   ** remove v_shipset records to intialize it
   */
   l_stmt_num := 620 ;
   --remove_elements_from_atp_rec( v_shipset ) ;
   v_shipset := v_null_atp_rec;

   /*
   ** copy cto_shipset into final_cto_shipset for 2nd phase
   */
   l_stmt_num := 640 ;

   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('get_atp_bom: ' ||  'Printing g_final_cto_shipset ' , 2 );
	l_stmt_num := 660 ;
	show_contents(g_final_cto_shipset) ;
   END IF;

   g_cto_shipset.delete ;
   g_cto_sparse_shipset.delete ;

   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('get_atp_bom: ' ||  ' Printing shipset before finishing get_atp_bom ' , 2 );
	l_stmt_num := 680 ;
	print_shipset( p_shipset ) ;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS ;

   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('get_atp_bom: ' ||  ' Done get atp bom' , 1 );
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('get_atp_bom: ' || 'GET_ATP_BOM_PUB::exp error::'||to_char(l_stmt_num)||'::'||sqlerrm,1);
		oe_debug_pub.add('get_atp_bom: ' ||  ' Printing shipset to show exp error ' , 2 );
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;

        print_shipset( p_shipset ) ;

        FND_MSG_PUB.Count_And_Get(
          p_count => x_msg_count
        , p_data  => x_msg_data
        );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('get_atp_bom: ' || 'GET_ATP_BOM_PUB::unexp error::'||to_char(l_stmt_num)||'::'||sqlerrm,1);
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
          p_count => x_msg_count
        , p_data  => x_msg_data
        );

   WHEN OTHERS THEN
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('get_atp_bom: ' || 'GET_ATP_BOM_PUB::others::'||to_char(l_stmt_num)||'::'||sqlerrm,1);
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
           FND_MSG_PUB.Add_Exc_Msg(
             G_PKG_NAME
           , 'GET_ATP_BOM_PUB'
           );
        END IF;
        FND_MSG_PUB.Count_And_Get(
          p_count => x_msg_count
        , p_data  => x_msg_data
        );

END get_atp_bom ;



/*
** This procedure evaluates the shipset for determining model source.
** This evaluation is done with the help of preprocessing procedures
** depending on the origin of the call( CZ or OM )
** This procedure returns a reduced shipset if the shipset is sourced.
** Processing Steps
** 1) evaluate source of call ( CZ or OM ) and type of action ( enquiry, schedule, reschedule, cancel, delete )
** 2) Retrieve relevant information required for processing according to the request
** 3) Return if no models found in the shipset
** 4) Filter out mandatory components(permanent) and standard/ATO items( temporary ) for model processing.
** 5) Populate plan level
** 6) Populate Parent ATO
** 7) Unscramble the data and reorder it
** 8) Evaluate sourcing for the entire shipset
** 9) If model not sourced check step 10 else check step 11
** 10) if model not multilevel return without any further processing
** 11) Populate Sparse shipset for BOM creation
** 12) Create BOM for as model is Multi-level/Multi-Org
** 13) Reinstate WIP information for phantom models and option classes to non phantom in BOM structure as they
**     have been exploded in the Pre-ATP process. ATP should not be exploding these models and option classes again.
** 14) Identify components under ATO models to be eliminated from p_shipset as they are part of sourced shipset
** 15) Start eliminating components under ATO models from p_shipset
** 16) Send Enhanced shipset back to caller
*************
** Caution **
** A shipset may be SMC( Ship Model Complete ) or NonSMC. In the case of NonSMC the PTO model
** may not be passed with the ATO models under it. The code needs to handle both scenarios from a
** Top Down Model processing perspective.
*/
PROCEDURE evaluate_shipset(
  p_shipset            in out NOCOPY  MRP_ATP_PUB.ATP_REC_TYP
, p_auto_generated     in   boolean
, p_process_demand     in   boolean
, p_atp_bom_rec        out  NOCOPY MRP_ATP_PUB.ATP_BOM_REC_TYP
, p_model_sourced      out  boolean
, x_return_status      out varchar2
)
is
v_orig_shipset_tracker     CTO_SHIPSET_TBL_TYPE;
v_raw_shipset_tracker     CTO_SHIPSET_TBL_TYPE ;
v_dummy_shipset_tracker     CTO_SHIPSET_TBL_TYPE ;
v_temp_tracker     CTO_SHIPSET_TYPE ;
v_basis_qty          number ;
v_phantom            boolean ;
v_procured           boolean := FALSE;
v_shipset_contains_models  boolean ;
v_curr_line_id        number ;
v_top_model_line_id        number ;
l_validation_org      number ;
l_return_status       varchar2(1) ;
v_call_from           varchar2(10 ) ;
v_action_code              varchar2(20) ; /* values 'RESCHED' , 'CANCEL' */
v_action              number ;
l_msg_data            varchar2(2000) ;
l_msg_count           number ;
x_msg_data            varchar2(2000) ;
x_msg_count           number ;
l_stmt_num            number ;
v_cto_shipset_flag   FLAG_TBL_TYPE;
v_shipset            MRP_ATP_PUB.ATP_REC_TYP ;
v_shipset_index      number ;
TYPE TABNUM is TABLE of NUMBER index by binary_integer ;
l_pal_array          TABNUM ;
l_pal_count          number ;
l_pal_found          boolean ;
v_lcs_size           number ;
v_top_model_exists   boolean;
v_multilevel_shipset boolean := FALSE ; /* BUG#1874380 */

/* start 2723674 - Variable declaration */
v_mlmo_ato_line_id      number;
d_line_id		number; 	-- debug
d_parent_ato_line_id 	number;		-- debug
d_bom_item_type		number;		-- debug
d_wip_supply_type 	number;		-- debug
d_ato_line_id		number;		-- debug
dj_line_id		number; 	-- debug
dj_ato_line_id		number;		-- debug
dj_mlmo_flag		varchar2(1);	-- debug
dd_mlmo_flag		varchar2(1);	-- debug
/* end 2723674 - Variable declaration */

BEGIN


   l_stmt_num := 10 ;

   p_model_sourced := FALSE ;
   x_return_status := FND_API.G_RET_STS_SUCCESS ;
   local_cto_shipset.delete ;

   /*
   ** evaluate call from OM or CZ
   */
   l_stmt_num := 40 ;

   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('evaluate_shipset: ' ||  'Calling module is:: '|| to_char( p_shipset.calling_module.first ) , 2 );
   	oe_debug_pub.add('evaluate_shipset: ' ||  'Shipset count is::' || to_char( p_shipset.calling_module.count ) , 4 );
	print_shipset(p_shipset) ;
   END IF;


   IF( p_shipset.calling_module( p_shipset.calling_module.first) = 660 ) THEN
       v_call_from := 'OM' ;
   ELSIF( p_shipset.calling_module( p_shipset.calling_module.first) = 708 ) THEN
       v_call_from := 'CZ' ;
   END IF ;

   /*
   ** evaluate action
   */
   l_stmt_num := 60 ;
   IF( p_shipset.Action(p_shipset.Action.first) = 100 ) THEN
       v_action_code  := 'ATP' ;
       v_action := 100 ;
   ELSIF( p_shipset.Action(p_shipset.Action.first) = 110 ) THEN
       v_action_code := 'SCHED' ;
       v_action := 110 ;
   ELSIF( p_shipset.Action(p_shipset.Action.first) = 120 ) THEN
       v_action_code := 'RESCHED' ;
       v_action := 120 ;
   END IF;

   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('evaluate_shipset: ' || 'Action is:: ' || v_action_code , 2 );
   END IF;

   /*
   ** populate om or cz shipset
   */
    l_stmt_num := 80 ;
   IF( v_call_from = 'OM'  )
   THEN
       IF PG_DEBUG <> 0 THEN
       	oe_debug_pub.add ('evaluate_shipset: ' ||  'Calling populate_om_shipset ' , 2 );
       END IF;

       l_stmt_num := 100  ;
       populate_om_shipset(
          p_shipset
        , v_orig_shipset_tracker
        , v_shipset_contains_models
        , x_return_status
        );

        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('evaluate_shipset: ' ||  'Returned from populate om shipset::'||x_return_status, 4);
        END IF;

        l_stmt_num := 120 ;

        IF( x_return_status = FND_API.G_RET_STS_ERROR ) THEN
            RAISE FND_API.G_EXC_ERROR ;
        ELSIF( x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        END IF ;

   ELSIF ( v_call_from = 'CZ' ) THEN
       IF PG_DEBUG <> 0 THEN
       	oe_debug_pub.add ('evaluate_shipset: ' ||  'Calling populate_cz_shipset ' , 2 );
       END IF;

       l_stmt_num := 160 ;
       populate_cz_shipset(
         p_shipset
       , v_orig_shipset_tracker
       , v_shipset_contains_models
       , x_return_status
       );

        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('evaluate_shipset: ' ||  'Returned from populate cz shipset:: '||x_return_status, 4);
        END IF;
       l_stmt_num := 180 ;

       IF( x_return_status = FND_API.G_RET_STS_ERROR ) THEN
            RAISE FND_API.G_EXC_ERROR ;
        ELSIF( x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        END IF ;

   END IF ;

   l_stmt_num := 190 ;

   IF( v_orig_shipset_tracker.count > 0 ) THEN
      FOR i IN v_orig_shipset_tracker.first..v_orig_shipset_tracker.last
      LOOP
         IF( v_orig_shipset_tracker.exists(i) ) THEN
             v_orig_shipset_tracker(i).auto_generated := p_auto_generated ;
	     v_orig_shipset_tracker(i).process_demand := p_process_demand ;
         END IF ;
      END LOOP ;
   END IF ;

   show_contents( v_orig_shipset_tracker ) ;

   l_stmt_num := 200 ;

   /*
   ** return IF no models or config items in ship set
   */
   IF( v_shipset_contains_models = FALSE )
   THEN
       /*
       ** before reducing shipset populate the error codes encountered
       */

       IF PG_DEBUG <> 0 THEN
       	oe_debug_pub.add('evaluate_shipset: ' ||  'No models in shipset, going to populate error ' , 2  );
       END IF;

       l_stmt_num := 220 ;

       populate_error( p_shipset , l_return_status ) ;

       /*
       ** copy the shipset to global shipset
       */
       IF PG_DEBUG <> 0 THEN
       	oe_debug_pub.add('evaluate_shipset: ' ||  'Going to save shipset into global shipset ' , 2  );
       END IF;

       l_stmt_num := 240 ;
       save_shipset( p_shipset , x_return_status ) ;
       return ;
   END IF ;

   /*
   ** copy original shipset tracker excluding mandatory and stand alone standard items
   ** into v_raw_shipset_tracker.
   ** position tracker contents by lineid location for sparse index traversal
   */
   l_stmt_num := 260 ;

   FOR j IN v_orig_shipset_tracker.first..v_orig_shipset_tracker.last
   LOOP
      IF PG_DEBUG <> 0 THEN
      	oe_debug_pub.add ('evaluate_shipset: ' ||  v_orig_shipset_tracker(j).line_id || ' IT ' ||
                            v_orig_shipset_tracker(j).bom_item_type || ' ID ' ||
                            v_orig_shipset_tracker(j).base_item_id || ' WF  ' ||
                            v_orig_shipset_tracker(j).build_in_wip_flag || ' RF ' ||
                            v_orig_shipset_tracker(j).replenish_to_order_flag , 5 );
      END IF;

      l_stmt_num := 280 ;

      /*
      ** filter out mandatory components and ato items
      */
      IF( NOT (    ( v_orig_shipset_tracker(j).mandatory_component AND
                     v_orig_shipset_tracker(j).mandatory_component is not null
                   )
                OR ( v_orig_shipset_tracker(j).bom_item_type = '4' AND
                     v_orig_shipset_tracker(j).base_item_id is not null AND
                     v_orig_shipset_tracker(j).build_in_wip_flag = 'Y' AND
                     v_orig_shipset_tracker(j).replenish_to_order_flag = 'Y'
                   )
                OR ( v_orig_shipset_tracker(j).bom_item_type = '4' AND
                     v_orig_shipset_tracker(j).top_model_line_id is null
                   )
              )
         )
      THEN
          l_stmt_num := 300 ;

          v_raw_shipset_tracker(v_orig_shipset_tracker(j).line_id) := v_orig_shipset_tracker(j) ;

      END IF;
   END LOOP ;


   /*
   ** populate_plan_level for the ship set
   */
   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add ('evaluate_shipset: ' ||  'Going to call populate plan level, shipset count is ' ||v_raw_shipset_tracker.count , 2 );
   END IF;
   l_stmt_num := 320 ;

   populate_plan_level(
     v_raw_shipset_tracker
   ) ;

   l_stmt_num := 340 ;

   show_contents(
     v_raw_shipset_tracker
   ) ;

   /*
   ** populate_parent_ato for the ship set
   */
   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('evaluate_shipset: ' ||  'Going to call populate parent ato ', 2  );
   END IF;

   l_stmt_num := 360 ;

   populate_parent_ato(
     v_raw_shipset_tracker
   , null ) ;
   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('evaluate_shipset: ' ||  'Populated parent ato ' , 4  );
   END IF;

   l_stmt_num := 380 ;

   show_contents(
     v_raw_shipset_tracker
   ) ;

   /*
   ** unscramble the data and reorder it
   */
   l_stmt_num := 400 ;

   FOR i IN v_raw_shipset_tracker.first..v_raw_shipset_tracker.last
   LOOP
      IF( v_raw_shipset_tracker.exists(i) )
      THEN
          v_lcs_size := local_cto_shipset.count + 1 ;
          local_cto_shipset(v_lcs_size ) := v_raw_shipset_tracker(i) ;

          /*
          ** A Multilevel Model will have atleast one element where
          ** ato_line_id <> parent_ato_line_id. The nvl function is used to take
          ** care of null values for pto items.
          */
          IF( nvl( local_cto_shipset(v_lcs_size).ato_line_id , local_cto_shipset(v_lcs_size).line_id ) <>
              nvl( local_cto_shipset(v_lcs_size).parent_ato_line_id , local_cto_shipset(v_lcs_size).line_id ))
          THEN
              v_multilevel_shipset := TRUE ; /* BUG#1874380 */
          END IF ;

      END IF ;
   END LOOP ;

   IF( v_multilevel_shipset ) THEN  /* BUG#1874380 */
       IF PG_DEBUG <> 0 THEN
       	oe_debug_pub.add('evaluate_shipset: ' ||  '*** Shipset Has atleast one Multilevel Model ' , 1 );
       END IF;
   ELSE
       IF PG_DEBUG <> 0 THEN
       	oe_debug_pub.add('evaluate_shipset: ' ||  '*** Shipset does not have Multilevel Model ' , 1 );
       END IF;
   END IF ;


   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add ('evaluate_shipset: ' ||  ' **  Bubble Sort logic for aligning ship set' , 4  );
   END IF;

   /*
   **  Bubble Sort logic for aligning ship set ( replace this with quick sort later!! )
   **  sort by Top model line id , level
   */
   l_stmt_num := 440 ;

   FOR i IN 1..local_cto_shipset.count
   LOOP
      FOR j IN i +1 ..local_cto_shipset.count
      LOOP
         IF(  ( local_cto_shipset(i).top_model_line_id >
                local_cto_shipset(j).top_model_line_id )
           OR ( ( local_cto_shipset(i).top_model_line_id =
                  local_cto_shipset(j).top_model_line_id ) AND
                ( local_cto_shipset(i).plan_level >
                  local_cto_shipset(j).plan_level )
              )
           OR ( ( local_cto_shipset(i).top_model_line_id =
                  local_cto_shipset(j).top_model_line_id ) AND
                ( local_cto_shipset(i).plan_level >
                  local_cto_shipset(j).plan_level ) AND
                ( local_cto_shipset(i).line_id >
                  local_cto_shipset(j).line_id )
              )
            )
         THEN
              v_temp_tracker := local_cto_shipset(i) ;
              local_cto_shipset(i) := local_cto_shipset(j) ;
              local_cto_shipset(j) := v_temp_tracker ;
         END IF ;
      END LOOP ;
   END LOOP ;


   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add ('evaluate_shipset: ' ||  'Going to process sourcing, shipset count is ' || local_cto_shipset.count , 2 );
   END IF;
   /*
   ** Check for each top model line whether multi-org and identify sources
   ** Also calculate model quantity per
   */
   l_stmt_num := 480 ;

   v_top_model_exists := FALSE ;

   FOR i IN 1..local_cto_shipset.count
   LOOP
      v_top_model_line_id := local_cto_shipset(i).top_model_line_id ;
      IF( v_top_model_line_id = local_cto_shipset(i).line_id ) THEN
          v_top_model_exists := TRUE ;
      END IF ;
   END LOOP ;

   l_stmt_num := 490 ;
   FOR i IN 1..local_cto_shipset.count
   LOOP
     /*
     ** In the case of non SMC PTO models, the top model may not be passed with the components
     ** We need to check whether the top model is passed. If not, the ato model should be
     ** processed for sourcing individually.
     */
     IF(
         ( local_cto_shipset(i).top_model_line_id  = local_cto_shipset(i).line_id AND
           v_top_model_exists = TRUE ) OR
         ( local_cto_shipset(i).ato_line_id = local_cto_shipset(i).line_id AND
           v_top_model_exists = FALSE )
       )
     THEN
         IF( local_cto_shipset(i).wip_supply_type = '6' )
         THEN
             v_phantom := TRUE ;
         ELSE
             v_phantom := FALSE ;
         END IF ;

         v_basis_qty := local_cto_shipset(i).ordered_quantity ;

         l_stmt_num := 500 ;
         IF( v_basis_qty <> 0 ) THEN
         	local_cto_shipset(i).ordered_quantity :=
                   local_cto_shipset(i).ordered_quantity / v_basis_qty ;
         ELSE
         	local_cto_shipset(i).ordered_quantity := 0 ;
         END IF ;

         IF PG_DEBUG <> 0 THEN
         	oe_debug_pub.add('evaluate_shipset: ' ||  'Going to call process_sourcing_chain ' , 2 );
         END IF;

         l_stmt_num := 520 ;
         process_sourcing_chain(
           i
         , i
         , local_cto_shipset(i).sourcing_org
         , v_phantom
         , v_procured
         , v_basis_qty
         , x_return_status
         ) ;

         l_stmt_num := 540 ;

         IF( x_return_status = FND_API.G_RET_STS_ERROR ) THEN
              l_stmt_num := 545 ;
              IF( local_cto_shipset.count > 0 ) THEN
              	l_stmt_num := 550 ;
              	FOR l_lcs_count IN local_cto_shipset.first..local_cto_shipset.last
              	LOOP
                  g_cto_shipset(g_cto_shipset.count + 1 ) := local_cto_shipset(l_lcs_count) ;
                  g_final_cto_shipset(g_final_cto_shipset.count + 1 ) := local_cto_shipset(l_lcs_count) ;
              	END LOOP ;
              END IF ;

              l_stmt_num := 555 ;
              IF PG_DEBUG <> 0 THEN
              	oe_debug_pub.add('evaluate_shipset: ' ||  'Going to call register error with error code::' || to_char( g_expected_error_code ) , 1 );
              END IF;

              register_error ( local_cto_shipset(i).ship_set_name ,
                               local_cto_shipset(i).line_id,
                               g_expected_error_code,
                               v_action,
                               false,
                               x_return_status);

              l_stmt_num := 557 ;
              populate_error( p_shipset , x_return_status ) ;
              RAISE FND_API.G_EXC_ERROR ;
         ELSIF( x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
         END IF ;

         IF( local_cto_shipset(i).sourced_components )
         THEN
             p_model_sourced := TRUE ;
         END IF ;

     END IF ;

  END LOOP ;

   l_stmt_num := 560 ;
   IF( p_model_sourced ) THEN
     IF PG_DEBUG <> 0 THEN
     	oe_debug_pub.add('evaluate_shipset: ' ||  '***Model is sourced in this shipset ' , 1 );
     END IF;
   ELSE
     IF PG_DEBUG <> 0 THEN
     	oe_debug_pub.add('evaluate_shipset: ' ||  '***Model is not sourced in this shipset ' , 1 );
     END IF;
   END IF ;

   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('evaluate_shipset: ' ||  'Done sourcing, status is::' || x_return_status , 2 );
   	oe_debug_pub.add('evaluate_shipset: ' ||  'Done sourcing, shipset count is:: ' || local_cto_shipset.count  , 1 );
   END IF;

   l_stmt_num := 580 ;
   show_contents(
    local_cto_shipset
   ) ;

   -- 2723674 start fix
  l_stmt_num := 598;

   for i in local_cto_shipset.first..local_cto_shipset.last
   loop
      if( local_cto_shipset.exists(i) )
      then
      oe_debug_pub.add( ' Shipset exist i' , 1 ) ;	-- debug
           if((		( local_cto_shipset(i).line_id  <> nvl( local_cto_shipset(i).parent_ato_line_id , local_cto_shipset(i).line_id ))
            	AND	( local_cto_shipset(i).bom_item_type = 1)
            	AND	( nvl(local_cto_shipset(i).wip_supply_type, 1) <> 6)
             )
            	OR  	( local_cto_shipset(i).sourced_components =TRUE
            		AND	( local_cto_shipset(i).bom_item_type = 1)
            		AND	( nvl(local_cto_shipset(i).wip_supply_type, 1) <> 6)
            	)
            )
           then 	/* get ato_line_id */
           	d_line_id 		:= local_cto_shipset(i).line_id; -- debug
           	d_parent_ato_line_id 	:= local_cto_shipset(i).parent_ato_line_id;	-- debug
           	d_bom_item_type		:= local_cto_shipset(i).bom_item_type;		-- debug
           	d_wip_supply_type 	:= local_cto_shipset(i).wip_supply_type;	-- debug
           	-- d_sourced_components 	:= to_char(local_cto_shipset(i).sourced_components);	-- debug
           	d_ato_line_id		:= local_cto_shipset(i).ato_line_id;		-- debug
           	oe_debug_pub.add( ' Lid '||d_line_id||' p_ato_lid '||d_parent_ato_line_id, 1 ) ;			  -- debug
           	oe_debug_pub.add( ' IT '||d_bom_item_type||' WS '||d_wip_supply_type,1);				  -- debug


           	v_mlmo_ato_line_id :=local_cto_shipset(i).ato_line_id;

           	oe_debug_pub.add( ' atoLid '||d_ato_line_id||' mlmo_ato_lid '||v_mlmo_ato_line_id, 1 ) ;		  -- debug

           	for j in local_cto_shipset.first..local_cto_shipset.last
           	loop
           	if( local_cto_shipset.exists(j) )
           	then

           	oe_debug_pub.add( ' Shipset exist j' , 1 ) ;								  -- debug

           		if ( local_cto_shipset(j).ato_line_id = v_mlmo_ato_line_id )
           		then

           			dj_ato_line_id		:= local_cto_shipset(j).ato_line_id;				   -- debug
           			dj_line_id		:= local_cto_shipset(j).line_id;				   -- debug
           			oe_debug_pub.add( ' line id '||dj_line_id||' atoLid '||dj_ato_line_id||' mlmo_ato_lid '||v_mlmo_ato_line_id, 1 ) ;  -- debug

           			local_cto_shipset(j).mlmo_flag := 'Y';

           			dj_mlmo_flag		:= local_cto_shipset(j).mlmo_flag;				   -- debug
           			oe_debug_pub.add( ' mlmo_flag after settin to Y '||dj_mlmo_flag, 1 ) ;   		   -- debug

           		end if;
           	end if;
           	end loop;
           end if;
        end if ;
   end loop ;
 -- 2723674 end fix

  /*
  ** filter, prepare structure for calling BOM API
  ** remove pto and its pto components from pto-ato models
  */
   l_stmt_num := 600 ;

   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('evaluate_shipset: ' ||  ' ** Filter, prepare structure for calling BOM API ', 2 );
   	oe_debug_pub.add('evaluate_shipset: ' ||  ' ** Remove pto and its pto components from pto-ato models ' , 2 );
   	oe_debug_pub.add('evaluate_shipset: ' ||  ' ** Before filtering components ' || local_cto_shipset.count , 2 );
   END IF;

   l_stmt_num := 602 ;

   IF( local_cto_shipset.count > 0 ) THEN
   FOR i IN 1..local_cto_shipset.last
   LOOP
     IF( local_cto_shipset.exists(i) )
     THEN
        IF( local_cto_shipset(i).top_model_line_id  = local_cto_shipset(i).line_id )
        THEN
           IF PG_DEBUG <> 0 THEN
           	oe_debug_pub.add('evaluate_shipset: ' ||  'Filtering PTO, i is '|| i  , 5 );
           END IF;
           /* remove single source ATO , PTO */
           IF( local_Cto_shipset(i).sourced_components = FALSE )
           THEN
               IF PG_DEBUG <> 0 THEN
               	oe_debug_pub.add('evaluate_shipset: ' ||  'Filtering PTO, no sourced components ' , 2 );
               END IF;
               v_top_model_line_id := local_cto_shipset(i).line_id ;

               l_stmt_num := 640 ;
               IF( local_cto_shipset.count > 0 ) THEN
               FOR j IN 1..local_cto_shipset.last
                   /* Changed i to 1 to account for copied orders which may
                   ** not have all the order lines in the right order
                   */
               LOOP
                 IF( local_cto_shipset.exists(j) ) THEN
                 IF( local_cto_shipset(j).top_model_line_id = v_top_model_line_id )
                 THEN
                     IF PG_DEBUG <> 0 THEN
                     	oe_debug_pub.add('evaluate_shipset: ' ||  'Filtering PTO, j is '|| j  , 5 );
                     END IF;
                     /* remove only pto and its components before ato */
                     IF( local_cto_shipset(j).ato_line_id is null OR
                        ( local_cto_shipset(j).ato_line_id = local_cto_shipset(j).line_id AND
                           local_cto_shipset(j).item_type_code in (  'OPTION' , 'INCLUDED' )
                        ) /* special processing for ato items under PTO Models per BUG#1874380 */
                        ) THEN
                          IF PG_DEBUG <> 0 THEN
                          	oe_debug_pub.add('evaluate_shipset: ' ||  'Filtering PTO, deleted comp for line_id:: ' || local_cto_shipset(j).line_id, 2 );
                          END IF;
                          local_cto_shipset.delete(j) ;
                     END IF ;

                 END IF ;
                 END IF ;
               END LOOP ;
               END IF;

           ELSIF( local_cto_shipset(i).sourced_components = TRUE ) THEN
              IF PG_DEBUG <> 0 THEN
              	oe_debug_pub.add('evaluate_shipset: ' ||  'Filtering PTO, sourced components ' , 2 );
              END IF;

              /* remove PTO and PTO components from sourced PTO */
              v_top_model_line_id := local_cto_shipset(i).line_id ;

              l_stmt_num := 680 ;
              IF( local_cto_shipset.count > 0 ) THEN
              FOR j IN 1..local_cto_shipset.last
                   /* Changed i to 1 to account for copied orders which may
                   ** not have all the order lines in the right order
                   */
              LOOP
                 IF( local_cto_shipset.exists(j) ) THEN
                 IF( local_cto_shipset(j).top_model_line_id = v_top_model_line_id )
                 THEN
                     IF PG_DEBUG <> 0 THEN
                     	oe_debug_pub.add('evaluate_shipset: ' ||  'Filtering PTO, j is '|| j  , 5 );
                     END IF;
                     /* remove only pto and its components before ato */
                     IF( local_cto_shipset(j).ato_line_id is null OR
                        ( local_cto_shipset(j).ato_line_id = local_cto_shipset(j).line_id AND
                           local_cto_shipset(j).item_type_code in (  'OPTION' , 'INCLUDED' )
                        ) /* special processing for ato items under PTO Models per BUG#1874380 */
                      )
                     THEN
                         IF PG_DEBUG <> 0 THEN
                         	oe_debug_pub.add('evaluate_shipset: ' ||  'Filtering PTO, deleted comp for line_id::' || local_cto_shipset(j).line_id  , 2 );
                         END IF;
                         local_cto_shipset.delete(j) ;
                     /* set the top level ato to sourced components of top level model */
                     ELSIF( local_cto_shipset(j).ato_line_id = local_cto_shipset(j).line_id ) THEN
                         local_cto_shipset(j).sourced_components := TRUE ;
                     END IF ;

                 END IF ;
                 END IF ;
              END LOOP ;
              END IF;

           ELSE
              IF PG_DEBUG <> 0 THEN
              	oe_debug_pub.add('evaluate_shipset: ' ||  'Filtering PTO, null sourced components ', 2  );
              END IF;
           END IF ;

        ELSIF( local_cto_shipset(i).top_model_line_id is null AND
               local_cto_shipset(i).bom_item_type = 4 )
        THEN
              /* remove standard items and ato items */

              IF PG_DEBUG <> 0 THEN
              	oe_debug_pub.add('evaluate_shipset: ' ||  'Filtering PTO, removing standard item for line_id::' || local_cto_shipset(i).line_id , 2 );
              END IF;

              local_cto_shipset.delete(i) ;

        END IF ;

     END IF ;
   END LOOP ;
   END IF ;


   /* Fixed BUG 2405011
      New change made to get rid of pto options in a complex shipset.
      Initially this was in the original loop and added pto components into the
      final set before they were deleted from the original set.
      New strategy requires the collection in g_cto_shipset to be delayed
      till complete complex shipset processing is done.
   */
   l_stmt_num := 700 ;
   IF( local_cto_shipset.count > 0 ) THEN
   FOR i IN 1..local_cto_shipset.last
   LOOP
        IF( local_cto_shipset.exists(i))
        THEN
            l_stmt_num := 720 ;

              /* populate shipset for reference */
              IF PG_DEBUG <> 0 THEN
              	oe_debug_pub.add('evaluate_shipset: ' || 'g_cto_shipset count ='||to_char(g_cto_shipset.count),2);
              END IF;
              g_cto_shipset(g_cto_shipset.count + 1 ) := local_cto_shipset(i) ;

              IF PG_DEBUG <> 0 THEN
              	oe_debug_pub.add('evaluate_shipset: ' || 'Before creating sparse_shipset',4);
              	oe_debug_pub.add('evaluate_shipset: ' || 'Ading line Id '
                               ||to_char(local_cto_shipset(i).line_id) || ' to sparse shipset' ,2);
              END IF;
              /* sparse array creation */
              g_cto_sparse_shipset(local_cto_shipset(i).line_id) := local_cto_shipset(i) ;

             l_stmt_num := 740 ;
             /* populate final shipset for reference */
             g_final_cto_shipset(g_final_cto_shipset.count + 1) := local_cto_shipset(i) ;

             IF( g_cto_shipset.count = 1 ) THEN

                 IF PG_DEBUG <> 0 THEN
                 	oe_debug_pub.add('evaluate_shipset: ' ||  'Populating g_cto_shipset for shipset name ' || g_cto_shipset(1).ship_set_name , 2 );
                 END IF;

                 l_stmt_num := 760 ;
                 v_shipset_index := get_shipset_success_index( g_cto_shipset(1).ship_set_name ) ;
                 g_shipset_status_tbl(v_shipset_index).cto_start_location := g_final_cto_shipset.count ;

             END IF ;
             /* this is needed for error processing */
	  -- 2723674 SLSO fix for storing SLSO in new structure
	    if (nvl(local_cto_shipset(i).mlmo_flag, 'N') = 'N') then
	 	-- populate slso_shipset from local_cto_shipset
	 	slso_shipset(local_cto_shipset(i).ato_line_id).ship_set_name	:= local_cto_shipset(i).ship_set_name;
	 	slso_shipset(local_cto_shipset(i).ato_line_id).ato_line_id	:= local_cto_shipset(i).ato_line_id;

	 	oe_debug_pub.add( ' SLSO shipset name ' || slso_shipset(local_cto_shipset(i).ato_line_id).ship_set_name , 1 ) ;
	 	oe_debug_pub.add( ' SLSO ato line id ' || slso_shipset(local_cto_shipset(i).ato_line_id).ato_line_id , 1 ) ;
	     end if;
	 -- 2723674 end fix
        END IF;
   END LOOP ;
   END IF; /* local cto shipset count > 0 */

   /*
   ** return if no models are sourced
   ** this call is delayed as we need to store cto_shipset information for non sourced models as well
   ** Modifications: Consider multilevel single org ato models also as enhanced atp processing items
   ** provide bom for their processing.
   ** A true multi level model will have more than one unique parent ato's.
   */
   l_stmt_num := 780 ;

   IF( p_model_sourced = FALSE AND  v_multilevel_shipset = FALSE  )
   THEN
       /*
       ** before reducing shipset populate the error codes encountered
       */

       IF PG_DEBUG <> 0 THEN
       	oe_debug_pub.add('evaluate_shipset: ' ||  'Returning as none of the models are sourced ' , 2  );
       END IF;

       l_stmt_num := 800 ;
       populate_error( p_shipset , l_return_status ) ;

       /*
       ** copy the shipset to global variable
       */
       l_stmt_num := 820 ;
       save_shipset( p_shipset , x_return_status ) ;
       local_cto_shipset.delete ;
       return ;
   END IF ;

   IF( p_model_sourced = FALSE )
   THEN
       /* added this statement as multilevel single org should work as multiorg*/
       p_model_sourced := TRUE ;
       IF PG_DEBUG <> 0 THEN
       	oe_debug_pub.add('evaluate_shipset: ' ||  ' Model is multilevel single org, it should behave as multiorg ' , 2 );
       END IF;
   END IF ;

   /*
   ** CALL BOM API
   ** make the structure contiguous before calling
   */
   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add ('evaluate_shipset: ' ||  ' Before Create ATP BOM ' , 1 );
   END IF;
   l_stmt_num := 840 ;

   show_contents( g_cto_shipset ) ;

   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add ('evaluate_shipset: ' ||  ' Display shipset contents before Create ATP BOM ' , 2 );
	show_contents( g_cto_sparse_shipset ) ;
   END IF;

   l_stmt_num := 860 ;
   Create_Atp_Bom (
      p_atp_bom_rec
    , l_return_status
    , l_msg_data
    , l_msg_count
   );

   l_stmt_num := 880 ;
   IF( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
       populate_error( p_shipset , l_return_status ) ;
       RAISE FND_API.G_EXC_ERROR ;
   ELSIF( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
   END IF ;

   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('evaluate_shipset: ' ||  ' Create ATP BOM information ' , 4 );
   END IF;

   l_stmt_num := 900 ;
   FOR k IN p_atp_bom_rec.assembly_identifier.first..p_atp_bom_rec.assembly_identifier.last
   LOOP
      IF( p_atp_bom_rec.assembly_identifier.exists(k) ) THEN

         IF PG_DEBUG <> 0 THEN
         	oe_debug_pub.add('evaluate_shipset: ' ||  ' Aident ' || p_atp_bom_rec.assembly_identifier(k) ||
                                ' Aitem ' || p_atp_bom_rec.assembly_item_id(k) ||
                                ' Cident ' || p_atp_bom_rec.component_identifier(k) ||
                                ' Citem ' || p_atp_bom_rec.component_item_id(k) ||
                                ' quant ' || p_atp_bom_rec.quantity(k) ||
                                ' FLT ' || p_atp_bom_rec.fixed_lt(k) ||
                                ' VLT ' || p_atp_bom_rec.variable_lt(k) ||
				' PPLT ' || p_atp_bom_rec.pre_process_lt(k) ||
				' ORG ' || p_atp_bom_rec.source_organization_id(k) ||
                                ' WIP ' || p_atp_bom_rec.wip_supply_type(k) , 4 );
         END IF;

        l_stmt_num := 920 ;
        FOR l IN g_final_cto_shipset.first..g_final_cto_shipset.last
        LOOP
           IF( g_final_cto_shipset(l).line_id = p_atp_bom_rec.component_identifier(k) )
           THEN
               IF( g_final_cto_shipset(l).inventory_item_id = p_atp_bom_rec.component_item_id(k))
               THEN
                  IF( p_atp_bom_rec.wip_supply_type(k) = 6 )
                  THEN
                     IF(  g_final_cto_shipset(l).bom_item_type in ( 1 , 2 ) )
                     THEN
                        l_stmt_num := 940 ;
                        g_final_cto_shipset(l).wip_supply_type := -1 ;
                        p_atp_bom_rec.wip_supply_type(k) := -1 ;
                        IF PG_DEBUG <> 0 THEN
                        	oe_debug_pub.add('evaluate_shipset: ' ||  ' Changed wip to -1 for ' ||
                                   g_final_cto_shipset(l).line_id || ' iid ' ||
                                   g_final_cto_shipset(l).inventory_item_id  ||
                                   ' as it matched ' || p_atp_bom_rec.component_identifier(k) ||
                                   ' item ' || p_atp_bom_rec.component_item_id(k) , 5  );
                        END IF;

                     ELSE
                        l_stmt_num := 960 ;
                        g_final_cto_shipset(l).wip_supply_type := 6 ;
                        IF PG_DEBUG <> 0 THEN
                        	oe_debug_pub.add('evaluate_shipset: ' ||  ' Changed wip to 6 for ' || g_final_cto_shipset(l).line_id || ' iid ' || g_final_cto_shipset(l).inventory_item_id , 5 );
                        END IF;
                     END IF ;
                  END IF ;
               END IF ;
          END IF ;
        END LOOP ;
      END IF ;
   END LOOP ;

   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add ('evaluate_shipset: ' ||  ' **Prepare ship set for ATP ' || g_cto_sparse_shipset.count ,2 );
   END IF;
   /*
   ** prepare ship set for ATP
   ** Identify and flag components in ship set that need to be inactivated
   ** as their models are sourced or if they are SLSO (bug 2723674)
   */
   l_stmt_num := 980 ;
   FOR i IN 1..p_shipset.identifier.count
   LOOP
      IF( g_cto_sparse_shipset.exists(p_shipset.identifier(i)) )
      THEN
        IF (g_cto_sparse_shipset(p_shipset.identifier(i)).mlmo_flag = 'Y') THEN	-- bug 2723674
           v_curr_line_id := g_cto_sparse_shipset(p_shipset.identifier(i)).line_id ;

           IF( g_cto_sparse_shipset(v_curr_line_id).inventory_item_id = p_shipset.inventory_item_id(i) ) THEN
             IF( NOT ( g_cto_sparse_shipset(v_curr_line_id).ato_line_id = v_curr_line_id ))
             THEN
                 v_cto_shipset_flag(i) := FALSE ;
             ELSE
                 v_cto_shipset_flag(i) := TRUE ;
             END IF ;
           ELSE
                 v_cto_shipset_flag(i) := FALSE ;
           END IF ;
        ELSE
	   v_cto_shipset_flag(i) := TRUE ;
	END IF;  -- bug 2723674
      ELSE
             v_cto_shipset_flag(i) := TRUE ;

      END IF ;
   END LOOP ;

   /*
   ** before reducing shipset populate the error codes encountered
   */
   l_stmt_num := 1000 ;
   populate_error( p_shipset , l_return_status ) ;

   /*
   ** copy the shipset to global variable
   */
   l_stmt_num := 1020 ;
   save_shipset( p_shipset , x_return_status ) ;

   /*
   ** prepare reduced shipset
   */
   l_stmt_num := 1040 ;
   FOR i IN v_cto_shipset_flag.first..v_cto_shipset_flag.last
   LOOP
      IF( v_cto_shipset_flag(i) ) THEN
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add ('evaluate_shipset: ' ||  'Line id ' || p_shipset.identifier(i) || ' is part of reduced shipset ', 2  );
        END IF;
                l_stmt_num := 1060 ;
                MRP_ATP_PVT.assign_atp_input_rec(p_shipset,
                                                 i,
                                                 v_shipset,
                                                 x_return_status );
                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add('evaluate_shipset: ' || 'MRP API returns with '|| x_return_status , 5 );
                END IF;
      ELSE
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('evaluate_shipset: ' ||  'Line id ' || p_shipset.identifier(i) || ' is removed from reduced shipset ', 2  );
        END IF;
      END IF ;
   END LOOP ;

   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('evaluate_shipset: ' ||  '***Contents of reduced shipset are '  ,1 );
   END IF;

   l_stmt_num := 1080 ;
   FOR i IN v_shipset.identifier.first..v_shipset.identifier.last
   LOOP
      IF( v_shipset.identifier.exists(i) ) THEN
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('evaluate_shipset: ' ||  '++++Line id:: ' || v_shipset.identifier(i) , 1  );
        END IF;
      END IF ;
   END LOOP ;

   /*
   ** send reduced shipset
   */
   p_shipset := v_shipset ;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('evaluate_shipset: ' || ':exp error::'||to_char(l_stmt_num)||'::'||sqlerrm,1);
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
          p_count => x_msg_count
        , p_data  => x_msg_data
        );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('evaluate_shipset: ' || ':unexp error::'||to_char(l_stmt_num)||'::'||sqlerrm,1);
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
          p_count => x_msg_count
        , p_data  => x_msg_data
        );
   WHEN OTHERS THEN
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('evaluate_shipset: ' || ':others::'||to_char(l_stmt_num)||'::'||sqlerrm,1);
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
           FND_MSG_PUB.Add_Exc_Msg(
             G_PKG_NAME
           , 'EVALUATE_SHIPSET'
           );
        END IF;
END evaluate_shipset ;


/*
** This procedure does the preprocessing and data collection for calls
** originating from CZ.
** CZ store information in CZ_ATP_REQUESTS table. The format of this information does
** not match with data structure required for evaluate shipset function. Hence this data
** needs to be transformed from CZ_REQUEST_TYPE data structure to CTO_SHIPSET_TYPE data structure.
** Model/Component relationships ( link_to_line_id, ato_line_id) need to be established before
** transformation.
*/
PROCEDURE populate_cz_shipset(
  p_shipset                in out NOCOPY MRP_ATP_PUB.ATP_REC_TYP
, p_orig_shipset_tracker   in out NOCOPY CTO_SHIPSET_TBL_TYPE
, p_shipset_contains_model in out boolean
, x_return_status             out varchar2
)
is
v_orig_shipset_tracker     CTO_SHIPSET_TBL_TYPE ;
v_raw_shipset_tracker     CTO_SHIPSET_TBL_TYPE ;
v_dummy_shipset_tracker     CTO_SHIPSET_TBL_TYPE ;
v_temp_tracker     CTO_SHIPSET_TYPE ;
v_basis_qty          number ;
v_phantom            boolean ;
v_shipset_contains_models  boolean ;
local_cto_shipset     CTO_SHIPSET_TBL_TYPE ; /* package global variable */
v_curr_line_id        number ;
v_top_model_line_id        number ;
c_organization_id     number ;
v_requests_tab        CZ_REQUESTS_TBL_TYPE ;
v_index                     number(10) := 0 ;
v_component_code      cz_atp_requests.item_key%type ;
v_top_model_code      cz_atp_requests.item_key%type ;
v_match_component_code      cz_atp_requests.item_key%type ;
v_code_loc            number(10) ;
v_parent_found        boolean ;
v_parent_loc          number(10) ;
	 cursor c1 (c_session_key cz_atp_requests.configurator_session_key%type )
	   is
     select Item_key, quantity, UOM_CODE, ship_To_date
		 from cz_atp_requests where configurator_session_key = c_session_key ;
x_msg_count number ;
x_msg_data  varchar2(2000) ;
l_stmt_num  number ;
v_bill_sequence_id   bom_bill_of_materials.bill_sequence_id%type  ;
v_component_code_tbl  CZ_ATP_CALLBACK_UTIL.char30_arr ;
l_validation_org     number ;
v_config_item_id     number ;
v_top_config_item_id number ;

BEGIN

        l_stmt_num := 1 ;
        p_shipset_contains_model := FALSE ;
        g_requests_tab.delete ;

        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('populate_cz_shipset: ' ||  'Entered populate cz shipset ' , 1 );
        END IF;

        l_stmt_num := 4 ;
        FOR v_location IN p_shipset.ship_set_name.first..p_shipset.ship_set_name.last
        LOOP
           IF( p_shipset.identifier(v_location) is not null ) THEN
               v_index := v_index + 1 ;

            l_stmt_num := 6 ;
            select
                 atp_request_id  /* line to be commented if noncz */
                 ,                 /* line to be commented if noncz */
                 configurator_session_key
                 , seq_no
                 , item_key
                 , quantity
                 , uom_code
                 , ship_to_date
                 , cz_atp_callback_util.inv_item_id_from_item_key( item_key )
                  /* line to be commented if noncz */
                 , config_item_id    /*BUG#2250621 Multiple Instantiation Code Change */
                 , parent_config_item_id /*BUG#2250621 Multiple Instantiation Code Change */
            into
                   g_requests_tab(v_index).line_id    /* line to be commented if noncz */
                 ,                                      /* line to be commented if noncz */
                 g_requests_tab(v_index).configurator_session_key
                 , g_requests_tab(v_index).seq_no
                 , g_requests_tab(v_index).item_key
	         , g_requests_tab(v_index).quantity
	         , g_requests_tab(v_index).UOM_CODE
	         , g_requests_tab(v_index).ship_To_date
	         , g_requests_tab(v_index).inventory_item_id
                 /* line to be commented if noncz */
	         , g_requests_tab(v_index).config_item_id /*BUG#2250621 Multiple Instantiation Code Change */
                 , g_requests_tab(v_index).parent_config_item_id   /*BUG#2250621 Multiple Instantiation Code Change */
            from cz_atp_requests
            where atp_request_id = p_shipset.identifier(v_location) ;
            /* line to be commented if noncz */

            l_stmt_num := 10 ;
            g_requests_tab(v_index).inv_org_id := p_shipset.source_organization_id(v_location ) ;

            IF PG_DEBUG <> 0 THEN
            	oe_debug_pub.add('populate_cz_shipset: ' ||  'Ship from org is ' || g_requests_tab(v_index).inv_org_id , 2 );
            END IF;

            g_requests_tab(v_index).location := v_location ;
            g_requests_tab(v_index).ship_set_name := p_shipset.ship_set_name(v_location ) ;
            g_requests_tab(v_index).assigned := FALSE ;

 	    v_component_code := cz_atp_callback_util.component_code_from_item_key(
                                  g_requests_tab(v_index).item_key
                                 ) ;
	    v_component_code_tbl := cz_atp_callback_util.component_code_tokens(
                                  v_component_code
                                ) ;
            v_top_model_code := v_component_code_tbl( v_component_code_tbl.first ) ;
            v_top_config_item_id := cz_atp_callback_util.root_bom_config_item_id( g_requests_tab(v_index).configurator_session_key) ; /*BUG#2250621 Multiple Instantiation Code Change */

            l_stmt_num := 14 ;
          END IF ; /* check whether identifier is null */
	END LOOP ;

        l_stmt_num := 20 ;
        FOR j IN 1..g_requests_tab.count
        LOOP

        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('populate_cz_shipset: ' ||  'Line_id  ' || g_requests_tab(j).line_id
                         || ' inventory id ' || g_requests_tab(j).inventory_item_id
                         || ' self ' || g_requests_tab(j).config_item_id
                         || ' parent ' || g_requests_tab(j).parent_config_item_id , 5 );
        END IF;

        END LOOP ;

        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('populate_cz_shipset: ' ||  'Fetched cz information ' ,  3 );
         END IF;

           l_validation_org := cz_atp_callback_util.validation_org_for_cfg_model( g_requests_tab(g_requests_tab.first).configurator_session_key ) ;

         IF PG_DEBUG <> 0 THEN
         	oe_debug_pub.add('populate_cz_shipset: ' ||  'Validation org is ' || l_validation_org , 3 );
         END IF;

         l_stmt_num := 24 ;
         IF( l_validation_org is null ) THEN
             FOR l_error_loc IN
                 p_shipset.ship_set_name.first..p_shipset.ship_set_name.last
             LOOP
                p_shipset.error_code(l_error_loc) := 69 ;
                /* error code for Invalid Validation Org seeded in MFG_LOOKUPS
                ** for TYPE 'MTL_DEMAND_INTERFACE_ERRORS'
                */
             END LOOP ;

             RAISE FND_API.G_EXC_ERROR ;
         END IF ;

         --- We re storing the l_validation_org value in pkg variable,which will be used
         --- in BOM creation module to get the calendar code for validation org.

        CTO_ATP_INTERFACE_PK.G_OE_VALIDATION_ORG := l_validation_org;

         /*    BUG#2250621 Multiple Instantiation Code Change */
	 /*
	 ** populate link_to_line_id for each of the components
         ** Strategy: Find all children that could belong to a possible parent
         **           for each possible parent node(outer LOOP)
         **               for each possible child (inner LOOP)
         **                 if child of current parent
         **                    make it point to the current parent
         **
	 */

         l_stmt_num := 28 ;
         FOR j IN 1..g_requests_tab.count
	 LOOP
               /*      BUG#2250621 Multiple Instantiation Code Change */

               IF( g_requests_tab(j).config_item_id <> v_top_config_item_id ) THEN
                  v_config_item_id := g_requests_tab(j).config_item_id ;
               ELSE
                  v_config_item_id := g_requests_tab(j).config_item_id ;
                  v_top_model_line_id := g_requests_tab(j).line_id ;
               END IF ;

               l_stmt_num := 30 ;
	       FOR k IN 1..g_requests_tab.count
	       LOOP
                  IF( k <> j  ) THEN
                      IF( v_config_item_id = g_requests_tab(k).parent_config_item_id )
                      THEN
			  v_parent_loc := j ;
			  g_requests_tab(k).link_to_line_id := g_requests_tab(v_parent_loc).line_id ;
                          g_requests_tab(k).parent_location := g_requests_tab(v_parent_loc).location ;
                      END IF ;
                  END IF ;
	       END LOOP ;
	 END LOOP ;

         IF PG_DEBUG <> 0 THEN
         	oe_debug_pub.add('populate_cz_shipset: ' ||  'Done populating link_to_line_id ' , 4 );
         END IF;

         l_stmt_num := 34 ;
         FOR j IN 1..g_requests_tab.count
         LOOP
            g_requests_tab(j).top_model_line_id := v_top_model_line_id ;
            IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('populate_cz_shipset: ' ||  'Line_id  ' || g_requests_tab(j).line_id
                         || ' inventory id ' || g_requests_tab(j).inventory_item_id
                         || ' self ' || g_requests_tab(j).config_item_id
                         || ' parent ' || g_requests_tab(j).parent_config_item_id
                         || ' link ' || g_requests_tab(j).link_to_line_id
                         || ' top ' || g_requests_tab(j).top_model_line_id
, 4 );
            END IF;
         END LOOP ;

         IF PG_DEBUG <> 0 THEN
         	oe_debug_pub.add('populate_cz_shipset: ' ||  'Done populating top_model_line_id ' , 4 );
         END IF;

         l_stmt_num := 38 ;
         FOR j IN  1..g_requests_tab.count
	 LOOP
           IF PG_DEBUG <> 0 THEN
           	oe_debug_pub.add('populate_cz_shipset: ' ||  'Going to query msyi with iid ' || g_requests_tab(j).inventory_item_id || ' org ' || l_validation_org  , 5 );
           END IF;

            l_stmt_num := 40 ;
	    select MSYI.bom_item_type
               , MSYI.replenish_to_order_flag
               , MSYI.pick_components_flag
               , MSYI.base_item_id
               , MSYI.build_in_wip_flag
	       , MSYI.atp_flag			--2462661
	       , MSYI.atp_components_flag	--2462661
            into
	         g_requests_tab(j).bom_item_type
               , g_requests_tab(j).replenish_to_order_flag
	       , g_requests_tab(j).pick_components_flag
	       , g_requests_tab(j).base_item_id
	       , g_requests_tab(j).build_in_wip_flag
	       , g_requests_tab(j).atp_flag
	       , g_requests_tab(j).atp_components_flag
            from Mtl_system_items MSYI
	    where MSYI.inventory_item_id = g_requests_tab(j).inventory_item_id
	      and MSYI.organization_id  = l_validation_org ;
           /*
           ** find bill sequence id for parent item
           */

           IF PG_DEBUG <> 0 THEN
           	oe_debug_pub.add('populate_cz_shipset: ' ||  'Done msyi ' ,5  );

          	oe_debug_pub.add('populate_cz_shipset: ' ||  'Going to find bill_sequence_id with assemblyid ' || g_requests_tab(nvl( g_requests_tab(j).parent_location , j ) ).inventory_item_id || ' and  org ' || l_validation_org , 5  );
          END IF;

           BEGIN

           l_stmt_num := 42 ;
           select common_bill_sequence_id
             into v_bill_sequence_id
           from bom_bill_of_materials
           where assembly_item_id = g_requests_tab( nvl( g_requests_tab(j).parent_location, j ) ).inventory_item_id
             AND organization_id = l_validation_org ;

           EXCEPTION
           WHEN no_data_found THEN
                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add('populate_cz_shipset: ' ||  'No data found for bill sequence id ' , 2 );
                END IF;
                v_bill_sequence_id := null ;
           WHEN others THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
           END ;

           l_stmt_num := 44 ;
           IF( g_requests_tab(j).bom_item_type = '1' ) THEN
               /*
               ** find wip supply type using parent bill sequence id and self inventory item id and
               ** item validation org
               */
              IF PG_DEBUG <> 0 THEN
              	oe_debug_pub.add('populate_cz_shipset: ' ||  'Going for wipsupplytype with billsequenceid ' || v_bill_sequence_id  || ' componentid ' || g_requests_tab(j).inventory_item_id  , 5 );
              END IF;

              BEGIN
                l_stmt_num := 48 ;
                select wip_supply_type
                 into g_requests_tab(j).wip_supply_type
                 from bom_inventory_components
                where bill_sequence_id = v_bill_sequence_id
                 AND component_item_id = g_requests_tab(j).inventory_item_id
                 AND rownum < 1 ;

              EXCEPTION
              WHEN no_data_found THEN
                   IF PG_DEBUG <> 0 THEN
                   	oe_debug_pub.add('populate_cz_shipset: ' ||  'No data for wip supply ',2 );
                   END IF;

              WHEN others THEN
                   IF PG_DEBUG <> 0 THEN
                   	oe_debug_pub.add('populate_cz_shipset: ' ||  ' other error raise ' || SQLCODE ,2 );
                   	oe_debug_pub.add('populate_cz_shipset: ' ||  ' other error raise ' || SQLERRM ,2 );
                   END IF;
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
              END ;

           END IF ;
	 END LOOP ;

         IF PG_DEBUG <> 0 THEN
         	oe_debug_pub.add('populate_cz_shipset: ' ||  'Done fetching msyi and bic information '  , 2 );
         END IF;

	 /*
	 ** propagate ato line id to all descendents
	 */
	 IF PG_DEBUG <> 0 THEN
	 	oe_debug_pub.add('populate_cz_shipset: ' || ' ** propagate ato line id to all descendents ' ,2  );
	 END IF;

         l_stmt_num := 52 ;
         FOR j IN 1..g_requests_tab.count
         LOOP
           IF PG_DEBUG <> 0 THEN
           	oe_debug_pub.add('populate_cz_shipset: ' ||  ' loc ' || j || ' -> ' || g_requests_tab(j).line_id || ' alid '
			|| g_requests_tab(j).ato_line_id || ' link ' || g_requests_tab(j).link_to_line_id || ' top ' || g_Requests_Tab(j).top_model_line_id  , 5 );
           END IF;
         END LOOP ;

	 IF PG_DEBUG <> 0 THEN
	 	oe_debug_pub.add('populate_cz_shipset: ' || ' ** calling propagate ato line id to all descendents ' ,2  );
	 END IF;
         propagate_ato_line_id( g_requests_tab.first ) ;

	 IF PG_DEBUG <> 0 THEN
	 	oe_debug_pub.add('populate_cz_shipset: ' || ' ** copying information to shipset tracker ' ,2  );
	 END IF;

   l_stmt_num := 56 ;
   FOR j IN 1..g_requests_tab.count
   LOOP
      v_index := p_orig_shipset_tracker.count + 1 ;

      IF( g_requests_tab.exists(j)) THEN

      p_orig_shipset_tracker(v_index ).header_id := null ;
      /* cz call does not have header id */
      p_orig_shipset_tracker(v_index ).line_id           := g_requests_tab(j).line_id ;
      p_orig_shipset_tracker(v_index).top_model_line_id := g_requests_tab(j).top_model_line_id ;
      p_orig_shipset_tracker(v_index).ato_line_id       := g_requests_tab(j).ato_line_id ;
      p_orig_shipset_tracker(v_index).link_to_line_id   := g_requests_tab(j).link_to_line_id ;
      p_orig_shipset_tracker(v_index).inventory_item_id := g_requests_tab(j).inventory_item_id ;
      p_orig_shipset_tracker(v_index).item_type_code    := g_requests_tab(j).item_type_code ;
      p_orig_shipset_tracker(v_index).ordered_quantity  := g_requests_tab(j).quantity ;
      p_orig_shipset_tracker(v_index).wip_supply_type   := g_requests_tab(j).wip_supply_type ;
      p_orig_shipset_tracker(v_index).bom_item_type     := g_requests_tab(j).bom_item_type ;
      p_orig_shipset_tracker(v_index).replenish_to_order_flag := g_requests_tab(j).replenish_to_order_flag ;
      p_orig_shipset_tracker(v_index).pick_components_flag := g_requests_tab(j).pick_components_flag ;
      p_orig_shipset_tracker(v_index).base_item_id         := g_requests_tab(j).base_item_id ;
      p_orig_shipset_tracker(v_index).build_in_wip_flag    := g_requests_tab(j).build_in_wip_flag ;
      p_orig_shipset_tracker(v_index).sourcing_org         := g_requests_tab(j).inv_org_id ;
      p_orig_shipset_tracker(v_index).ordered_quantity     := g_requests_tab(j).quantity ;
      p_orig_shipset_tracker(v_index).top_model_ato        := g_requests_tab(j).top_model_ato ;
      p_orig_shipset_tracker(v_index).location             := g_requests_tab(j).location ;
      p_orig_shipset_tracker(v_index).ship_set_name := g_requests_tab(j).ship_set_name ;
      p_orig_shipset_tracker(v_index).sourced_components := FALSE ;
      p_orig_shipset_tracker(v_index).atp_flag             := g_requests_tab(j).atp_flag;
      p_orig_shipset_tracker(v_index).atp_components_flag  := g_requests_tab(j).atp_components_flag;
      /* Added for procure to order */
      p_orig_shipset_tracker(v_index).buy_model := 'N' ;

      p_orig_shipset_tracker(v_index).mlmo_flag := 'N';		-- 2723674 : Initializing MLMO flag

      /*
      **  mandatory components may cause a problem to calculate plan level and parent ato
      */
      l_stmt_num := 60 ;
      IF( p_orig_shipset_tracker(v_index).inventory_item_id <> p_shipset.inventory_item_id(j) ) THEN
          p_orig_shipset_tracker(v_index).mandatory_component := TRUE  ;
      END IF ;

      /*
      **  check whether any models exist
      */
      IF( p_orig_shipset_tracker(v_index).bom_item_type = '1' ) THEN
          p_shipset_contains_model := TRUE  ;
      END IF ;

      /*
      **  calculate stored_atp_flag for ATP (bug 2462661)
      **  Note: making a change to p_shipset here, which needs to be
      **  sent back to ATP in the reduced shipset structure
      */
      l_stmt_num := 62 ;
      IF( p_orig_shipset_tracker(v_index).atp_flag <> 'N' OR p_orig_shipset_tracker(v_index).atp_components_flag <> 'N') THEN
	  p_shipset.attribute_06(p_orig_shipset_tracker(v_index).location ) := 'Y';
      ELSE
	  p_shipset.attribute_06(p_orig_shipset_tracker(v_index).location ) := 'N';
      END IF ;

     END IF ;
   END LOOP ;

   l_stmt_num := 64 ;
   show_contents( p_orig_shipset_tracker ) ;

   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('populate_cz_shipset: ' ||  'Done populate cz shipset ' ,1 );
   END IF;


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('populate_cz_shipset: ' || 'POPULATE_CZ_SHIPSET::exp error::'||to_char(l_stmt_num)||'::'||sqlerrm,1);
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
          p_count => x_msg_count
        , p_data  => x_msg_data
        );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('populate_cz_shipset: ' || 'POPULATE_CZ_SHIPSET::unexp error::'||to_char(l_stmt_num)||'::'||sqlerrm,1);
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
          p_count => x_msg_count
        , p_data  => x_msg_data
        );
   WHEN OTHERS THEN
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('populate_cz_shipset: ' || 'POPULATE_CZ_SHIPSET::others::'||to_char(l_stmt_num)||'::'||sqlerrm,1);
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
           FND_MSG_PUB.Add_Exc_Msg(
             G_PKG_NAME
           , 'POPULATE_CZ_SHIPSET'
           );
        END IF;
END populate_cz_shipset ;


/*
** This procedure does the preprocessing and data collection for calls
** originating from OM.
*/
PROCEDURE populate_om_shipset(
  p_shipset                in out NOCOPY MRP_ATP_PUB.ATP_REC_TYP
, p_orig_shipset_tracker   in out NOCOPY CTO_SHIPSET_TBL_TYPE
, p_shipset_contains_model in out boolean
, x_return_status             out varchar2
)
is
l_stmt_num        number ;
x_msg_count       number ;
x_msg_data        varchar2(2000) ;
l_validation_org  number ;
BEGIN

   l_stmt_num := 1 ;
   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('populate_om_shipset: ' ||  ' In populate om shipset ' , 1  );
   END IF;
   x_return_status := FND_API.G_RET_STS_SUCCESS ;
   p_shipset_contains_model := FALSE ;

   /*
   ** Find Validation Organization
   */
   l_stmt_num := 4 ;
   BEGIN
      select nvl(master_organization_id,-99)	--bugfix 2646849: master_organization_id can be 0
      into   l_validation_org
      from   oe_order_lines_all oel,
             oe_system_parameters_all ospa
      where  oel.line_id = p_shipset.identifier(1)
        and  nvl(oel.org_id,-1) = nvl(ospa.org_id,-1) --bug 1531691
        and  oel.inventory_item_id = p_shipset.inventory_item_id(1) ;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
           l_validation_org := -99 ;	--bugfix 2646849: changed from null to -99

      WHEN OTHERS THEN
           x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;
           raise FND_API.G_EXC_UNEXPECTED_ERROR;
   END ;

   l_stmt_num := 6 ;
   IF( l_validation_org = -99 ) THEN 	--bugfix 2646849: changed from null to -99
         FOR l_error_loc IN
             p_shipset.ship_set_name.first..p_shipset.ship_set_name.last
         LOOP
             p_shipset.error_code(l_error_loc) := 69 ;
             /* error code for Invalid Validation Org seeded in MFG_LOOKUPS
             ** for TYPE 'MTL_DEMAND_INTERFACE_ERRORS'
             */
         END LOOP ;
         RAISE FND_API.G_EXC_ERROR ;

   END IF ;

         --- We re storing the l_validation_org value in pkg variable,which will be used
         --- in BOM creation module to get the calendar code for validation org.
        CTO_ATP_INTERFACE_PK.G_OE_VALIDATION_ORG := l_validation_org;

   /*
   ** process shipset
   */
   l_stmt_num := 8 ;

   FOR j IN p_shipset.identifier.first..p_shipset.identifier.last
   LOOP
      BEGIN
           select OEOL.header_id
                , OEOL.line_id
                , OEOL.top_model_line_id
                , OEOL.ato_line_id
                , OEOL.link_to_line_id
                , OEOL.inventory_item_id
                , OEOL.item_type_code
                , OEOL.ordered_quantity
                , OEOL.ship_from_org_id
                , decode( OEOL.line_id, OEOL.ato_line_id , null ,
                  BIC.wip_supply_type )
                , MSYI.bom_item_type
                , MSYI.replenish_to_order_flag
                , MSYI.pick_components_flag
                , MSYI.base_item_id
                , MSYI.build_in_wip_flag
		, MSYI.atp_flag			--2462661
		, MSYI.atp_components_flag	--2462661
		, 'N'				-- 2723674 : Initializing MLMO flag
           INTO
                  p_orig_shipset_tracker(j).header_id
                , p_orig_shipset_tracker(j).line_id
                , p_orig_shipset_tracker(j).top_model_line_id
                , p_orig_shipset_tracker(j).ato_line_id
                , p_orig_shipset_tracker(j).link_to_line_id
                , p_orig_shipset_tracker(j).inventory_item_id
                , p_orig_shipset_tracker(j).item_type_code
                , p_orig_shipset_tracker(j).ordered_quantity
                , p_orig_shipset_tracker(j).sourcing_org
                , p_orig_shipset_tracker(j).wip_supply_type
                , p_orig_shipset_tracker(j).bom_item_type
                , p_orig_shipset_tracker(j).replenish_to_order_flag
                , p_orig_shipset_tracker(j).pick_components_flag
                , p_orig_shipset_tracker(j).base_item_id
                , p_orig_shipset_tracker(j).build_in_wip_flag
		, p_orig_shipset_tracker(j).atp_flag
		, p_orig_shipset_tracker(j).atp_components_flag
		, p_orig_shipset_tracker(j).mlmo_flag			-- 2723674 : Initializing MLMO flag
           from oe_order_lines_all OEOL , bom_inventory_components BIC , mtl_system_items MSYI
           where line_id = p_shipset.identifier(j)
             and OEOL.component_sequence_id = BIC.component_sequence_id(+)
             and MSYI.inventory_item_id = p_shipset.inventory_item_id(j)
             and MSYI.organization_id = l_validation_org
           order by line_id ;

           p_orig_shipset_tracker(j).location := j ;  /* note location in original shipset */
           p_orig_shipset_tracker(j).sourced_components := FALSE ;
           p_orig_shipset_tracker(j).ship_set_name := p_shipset.ship_set_name(j) ;
           p_orig_shipset_tracker(j).ordered_quantity := p_shipset.quantity_ordered(j) ;
           p_orig_shipset_tracker(j).sourcing_org := p_shipset.source_organization_id(j) ;
          /* Added for procure to order */
           p_orig_shipset_tracker(j).buy_model := 'N' ;

      EXCEPTION
      WHEN others THEN
           IF PG_DEBUG <> 0 THEN
           	oe_debug_pub.add('populate_om_shipset: ' ||  'Error ' || SQLCODE , 1 );
           	oe_debug_pub.add('populate_om_shipset: ' ||  'Error ' || SQLERRM , 1 );
           	oe_debug_pub.add('populate_om_shipset: ' ||  ' query ' || p_shipset.identifier(j)  || ' ' ||
                 p_shipset.demand_source_header_id(j) || ' ' || l_validation_org , 2 );
           END IF;
      END ;

      /*
      **  mandatory components may cause a problem to calculate plan level and parent ato
      */
      l_stmt_num := 10 ;
      IF( p_orig_shipset_tracker(j).inventory_item_id <> p_shipset.inventory_item_id(j) )
      THEN
          p_orig_shipset_tracker(j).mandatory_component := TRUE  ;
      END IF ;

      /*
      **  check whether any models exist
      */
      l_stmt_num := 12 ;
      IF( p_orig_shipset_tracker(j).bom_item_type = '1' )
      THEN
          p_shipset_contains_model := TRUE  ;
      END IF ;

      /*
      **  calculate stored_atp_flag for ATP processing (bug 2462661)
      **  Note: making a change to p_shipset here, which needs to be
      **  sent back to ATP in the reduced shipset structure
      */
      l_stmt_num := 13 ;
      IF ( p_orig_shipset_tracker(j).atp_flag <> 'N' OR p_orig_shipset_tracker(j).atp_components_flag <> 'N')
      THEN
	  p_shipset.attribute_06(j) := 'Y';
      ELSE
	  p_shipset.attribute_06(j) := 'N';
      END IF ;
   END LOOP ;

   l_stmt_num := 14 ;
   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('populate_om_shipset: ' ||  'Displaying contents after populate_om_shipset '  , 3 );
	show_contents( p_orig_shipset_tracker ) ;
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('populate_om_shipset: ' || 'POPULATE_OM_SHIPSET::exp error::'||to_char(l_stmt_num)||'::'||sqlerrm,1);
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
          p_count => x_msg_count
        , p_data  => x_msg_data
        );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('populate_om_shipset: ' || 'POPULATE_OM_SHIPSET::unexp error::'||to_char(l_stmt_num)||'::'||sqlerrm,1);
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
          p_count => x_msg_count
        , p_data  => x_msg_data
        );
   WHEN OTHERS THEN
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('populate_om_shipset: ' || 'POPULATE_OM_SHIPSET::others::'||to_char(l_stmt_num)||'::'||sqlerrm,1);
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
           FND_MSG_PUB.Add_Exc_Msg(
             G_PKG_NAME
           , 'POPULATE_OM_SHIPSET'
           );
        END IF;
END populate_om_shipset ;


/*
** This procedure propagates any sourcing across the heirarchy and
** calculates model per quantity
*/
PROCEDURE process_sourcing_chain(
  p_top_location     number
, p_location         number
, p_org              number
, p_isPhantom        boolean
, p_isProcured       boolean
, p_basis_qty        number
, x_return_status             out varchar2
)
is
v_new_org number ;
v_model_line_id  number ;
v_phantom   boolean ;
v_basis_qty    number ;
p_new_basis_qty    number ;
v_transit_lead_time number ;
v_sourcing_rule_exists varchar2(1) ;
x_msg_data    varchar2(2000) ;
x_msg_count   number ;
l_stmt_num    number ;
v_source_type number;
v_procured    boolean := FALSE;
l_make_buy_code   Number;
x_exp_error_code  Number ;
BEGIN

   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('process_sourcing_chain: ' ||  'Entered process sourcing chain ' , 1 );
   END IF;

   l_stmt_num := 1 ;
   v_new_org := p_org ;
   v_model_line_id := local_cto_shipset(p_location).line_id ;
   x_return_status := FND_API.G_RET_STS_SUCCESS ;

   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('process_sourcing_chain: ' ||  ' p_top_location is '|| to_char(p_top_location) , 5 );
   	oe_debug_pub.add('process_sourcing_chain: ' ||  ' p_location is '|| to_char(p_location) , 5 );
   END IF;

   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('process_sourcing_chain: ' ||  ' processing sourcing chain ' || p_location || ' bom it ' || local_cto_shipset(p_location).bom_item_type || ' line id ' || local_cto_shipset(p_location).line_id , 5 );
   END IF;

   l_stmt_num := 10 ;
   IF( NOT p_isPhantom AND NOT p_isProcured )
   THEN
       /*
       ** Evaluate sourcing rules only for Models
       */
       IF( local_cto_shipset(p_location).bom_item_type = '1'  AND
           local_cto_shipset(p_location).ato_line_id is not null /* Sushant added this check to not process PTO Models 05-28-02*/
         )
       THEN
           IF( gMrpAssignmentSet is not null )
           THEN

               l_stmt_num := 20 ;
               CTO_UTILITY_PK.get_model_sourcing_org(
                                         local_cto_shipset(p_location).inventory_item_id
                                       , local_cto_shipset(p_location).sourcing_org
                                       , v_sourcing_rule_exists
                                       , v_new_org
                                       , v_source_type
                                       , v_transit_lead_time
                                       , x_return_status
                                       , x_exp_error_code
                                       , local_cto_shipset(p_location).line_id
                                       , local_cto_shipset(p_location).ship_set_name
                                       ) ;

               IF PG_DEBUG <> 0 THEN
               	oe_debug_pub.add('process_sourcing_chain: ' ||  ' after get model source status ' || x_return_status , 4 );
               END IF;

               -- The expected error code from get_model_sourcing_org
               -- needs to be copied into g_expected_error_code for further processing

               g_expected_error_code := x_exp_error_code;

               l_stmt_num := 30 ;
               IF x_return_status = FND_API.G_RET_STS_ERROR
               THEN
                   RAISE FND_API.G_EXC_ERROR;
               ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
               THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
           ELSE  /* assignment set is null */
              IF PG_DEBUG <> 0 THEN
              	oe_debug_pub.add('process_sourcing_chain: ' ||  '***$$$ Going to check Planning type attribute as assignment set is null ' , 3 );
              END IF;

                --- When there is no sourcing rule defined we need to look at the
                --- Planning_make_buy_code to determine the source_type
                --- If the planning_make_buy_code is 1(Make) we can return as it is
                --- If the planning_make_buy_code is 2(Buy) we need to set the p_source_type to 3 and return
                --- so that the calling application will knwo this as buy model

                SELECT planning_make_buy_code
                INTO   l_make_buy_code
                FROM   MTL_SYSTEM_ITEMS
                WHERE  inventory_item_id = local_cto_shipset(p_location).inventory_item_id
                AND    organization_id   = p_org;

                IF l_make_buy_code = 2 THEN
                  v_source_type := 3;
                END IF;

           END IF ;

       END IF ;

       l_stmt_num := 40 ;
       IF( v_source_type = '3' ) THEN
           local_cto_shipset(p_location).buy_model := 'B' ;
           local_cto_shipset(p_location).sourcing_org := v_new_org ;
           local_cto_shipset(p_top_location).sourced_components := TRUE ;
	   local_cto_shipset(p_location).sourced_components := TRUE ;  --bug2803895
       ELSE
           local_cto_shipset(p_location).buy_model := 'N' ;
           IF( FND_API.to_boolean( v_sourcing_rule_exists ) )
           THEN
              local_cto_shipset(p_location).sourcing_org := v_new_org ;
              local_cto_shipset(p_top_location).sourced_components := TRUE ;
	      local_cto_shipset(p_location).sourced_components := TRUE ;  --bug2803895
           END IF ;
       END IF ;

   ELSE
       /* Phantom properties have higher priority than procurement properties */
       IF( p_isPhantom ) THEN
           local_cto_shipset(p_location).wip_supply_type := '6' ;
           local_cto_shipset(p_location).buy_model := 'N' ;
       ELSIF( p_isProcured ) THEN
           local_cto_shipset(p_location).buy_model := 'Y' ;
       END IF ;
   END IF;

   l_stmt_num := 50 ;
   /*
   ** for each model child of top level model
   */
   FOR j IN 1..local_cto_shipset.count
   LOOP
           IF( v_model_line_id = local_cto_shipset(j).link_to_line_id )
           THEN
               l_stmt_num := 60 ;
               IF( local_cto_shipset(p_location).buy_model in('B','Y') ) THEN
                   v_procured := TRUE ;
               ELSE
                   v_procured := FALSE ;
                  IF( local_cto_shipset(j).wip_supply_type = '6')
                  THEN
                     v_phantom := TRUE ;
                  ELSE
                      v_phantom := FALSE ;
                  END IF ;
               END IF ;

               v_basis_qty := local_cto_shipset(j).ordered_quantity ;

               l_stmt_num := 70 ;
               IF( p_basis_qty <> 0 ) THEN
                  p_new_basis_qty := local_cto_shipset(j).ordered_quantity ; /* BUG#2424590*/
                  local_cto_shipset(j).ordered_quantity := local_cto_shipset(j).ordered_quantity / p_basis_qty ;
               ELSE
                  local_cto_shipset(j).ordered_quantity := 0 ;
               END IF ;

               /* all components should refer to parents new org */
               local_cto_shipset(j).sourcing_org := local_cto_shipset(p_location).sourcing_org ;

               l_stmt_num := 80 ;
               process_sourcing_chain(
                 p_top_location
               , j
               , v_new_org
               , v_phantom
               , v_procured
               , p_new_basis_qty  /* the basis qty should be w.r.t. top model qty BUG#2424590 basis qty should be w.r.t immediate parent , bom per qty concept */
               , x_return_status
               ) ;

               l_stmt_num := 90 ;
               IF x_return_status = FND_API.G_RET_STS_ERROR
               THEN
                   RAISE FND_API.G_EXC_ERROR;
               ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
               THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
      END IF ;
   END LOOP ;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('process_sourcing_chain: ' || 'PROCESS_SOURCING_CHAIN::exp error::'||to_char(l_stmt_num)||'::'||sqlerrm,1);
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
          p_count => x_msg_count
        , p_data  => x_msg_data
        );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('process_sourcing_chain: ' || 'PROCESS_SOURCING_CHAIN::unexp error::'||to_char(l_stmt_num)||'::'||sqlerrm,1);
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
          p_count => x_msg_count
        , p_data  => x_msg_data
        );
   WHEN OTHERS THEN
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('process_sourcing_chain: ' || 'PROCESS_SOURCING_CHAIN::others::'||to_char(l_stmt_num)||'::'||sqlerrm,1);
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
           FND_MSG_PUB.Add_Exc_Msg(
             G_PKG_NAME
           , 'PROCESS_SOURCING_CHAIN'
           );
        END IF;
END process_sourcing_chain ;



/*
** This procedure checks whether a model has been sourced.
** It also checks for circular sourcing and flags an error if it detects one.
** This procedure keeps on chaining sourcing rules till no more sourcing rules exist.
*/
PROCEDURE get_model_sourcing_org(
  p_inventory_item_id    NUMBER
, p_organization_id      NUMBER
, p_sourcing_rule_exists out varchar2
, p_sourcing_org         out NUMBER
, p_source_type          out NUMBER
, p_transit_lead_time    out NUMBER
, x_return_status        out varchar2
, p_line_id              in NUMBER
, p_ship_set_name        in varchar2
)
IS
v_sourcing_organization_id  number ;
v_assignment_type   number ;
CTO_MRP_ASSIGNMENT_SET  EXCEPTION;
x_msg_data     varchar2(2000) ;
x_msg_count    number ;
l_stmt_num     number ;
l_error_code   number ;
v_organization_id number ;
v_transit_lead_time number ;
TYPE TABNUM is TABLE of NUMBER index by binary_integer ;
v_orgs_tbl         TABNUM ;
v_circular_sourcing boolean ;
v_location          number := 0 ;
v_sourcing_rule_exists varchar2(1) ;
v_source_type       number;

BEGIN
        l_stmt_num :=  1;

        p_sourcing_rule_exists := FND_API.G_FALSE ;
        p_transit_lead_time := 0 ;
        x_return_status := FND_API.G_RET_STS_SUCCESS ;
        v_organization_id := p_organization_id ;
        v_transit_lead_time := 0 ;
        v_circular_sourcing := FALSE ;
        v_orgs_tbl.delete ; /* reinitialize table to check circular sourcing */

        l_stmt_num := 10 ;
        <<OUTER>>
        WHILE( TRUE )
        LOOP

           l_stmt_num := 20 ;
           /*
           ** check whether the current org exists in the orgs array
           */
           FOR i IN 1..v_orgs_tbl.count
           LOOP
              IF( v_orgs_tbl(i) = v_organization_id )
              THEN
                 v_circular_sourcing := TRUE ;
                 v_location := i ;
                 exit OUTER ;
              END IF ;
           END LOOP ;

           v_orgs_tbl(v_orgs_tbl.count + 1 ) := v_organization_id ;
           l_stmt_num := 30 ;
           query_sourcing_org(
                p_inventory_item_id
              , v_organization_id
              , v_sourcing_rule_exists
              , v_source_type
              , v_sourcing_organization_id
              , v_transit_lead_time
              , x_return_status
           ) ;

           l_stmt_num := 40 ;
           IF x_return_status = FND_API.G_RET_STS_ERROR
           THEN
                   RAISE FND_API.G_EXC_ERROR;
           ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
           THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;

           p_source_type := v_source_type ;
           IF( v_source_type = '3' ) THEN
               exit ;
           ELSE
               IF( FND_API.to_boolean( v_sourcing_rule_exists )  ) THEN
                   p_sourcing_rule_exists := 'T' ;
               ELSE
                 exit ; /* always exit when no more sourcing rules to cascade */
               END IF ;
           END IF ;

           l_stmt_num := 50 ;
           /* set the query organization id to current sourcing organization to
           ** cascade sourcing rules.
           ** e.g.  M1 <- D1 , D1 <- M2  =>  M1 <- M2
           */
           v_organization_id := v_sourcing_organization_id ;
           p_transit_lead_time := p_transit_lead_time + v_transit_lead_time ;

        END LOOP OUTER ;

        l_stmt_num := 60 ;
        IF( v_circular_sourcing )
        THEN
           g_expected_error_code := 66 ;
           IF PG_DEBUG <> 0 THEN
           	oe_debug_pub.add('get_model_sourcing_org: ' ||  '***Circular sourcing error ' , 1 );
           END IF;
           RAISE FND_API.G_EXC_ERROR;
        END IF ;

        p_sourcing_org := v_organization_id ;
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('get_model_sourcing_org: ' || 'Sourcing org is ' || p_sourcing_org || ' lead time ' || to_char( p_transit_lead_time ) , 2 );
        END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('get_model_sourcing_org: ' || 'GET_MODEL_SOURCING_ORG::exp error::'||to_char(l_stmt_num)||'::'||sqlerrm,1);
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;

        FND_MSG_PUB.Count_And_Get(
          p_count => x_msg_count
        , p_data  => x_msg_data
        );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('get_model_sourcing_org: ' || 'GET_MODEL_SOURCING_ORG::unexp error::'||to_char(l_stmt_num)||'::'||sqlerrm,1);
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MSG_PUB.Count_And_Get(
          p_count => x_msg_count
        , p_data  => x_msg_data
        );

   WHEN OTHERS THEN
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('get_model_sourcing_org: ' || 'GET_MODEL_SOURCING_ORG::others::'||to_char(l_stmt_num)||'::'||sqlerrm,1);
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
           FND_MSG_PUB.Add_Exc_Msg(
             G_PKG_NAME
           , 'GET_MODEL_SOURCING_ORG'
           );
        END IF;

END get_model_sourcing_org ;


/*
** This procedure checks for existence of any sourcing rules for a given Item.
** An Item will be considered sourced if the sourcing rule type is 'TRANSFER FROM'.
** This procedure flags an error if multiple sourcing rules exist for an Item.
** A no data found for sourcing rule query or a 'MAKE AT' sourcing rule is considered as END of sourcing chain.
*/
PROCEDURE query_sourcing_org(
  p_inventory_item_id    NUMBER
, p_organization_id      NUMBER
, p_sourcing_rule_exists out varchar2
, p_source_type          out NUMBER
, p_sourcing_org         out NUMBER
, p_transit_lead_time    out NUMBER
, x_return_status        out varchar2
)
is
v_sourcing_rule_id number ;
l_stmt_num         number ;
v_source_type      varchar2(1) ;
v_sourcing_rule_count number;

l_make_buy_code     number;
BEGIN
     /*
     ** This routine should consider no data found or one make at sourcing rule
     ** as no sourcing rule exist.
     */
           l_stmt_num := 1 ;
           p_sourcing_rule_exists := FND_API.G_FALSE ;
           x_return_status := FND_API.G_RET_STS_SUCCESS ;
           p_transit_lead_time := 0 ;

           /*
           ** Fix for Bug 1610583
           ** Source Type values in MRP_SOURCES_V
           ** 1 = Transfer From, 2 = Make At, 3 = Buy From.
           */
           -- If the sourcing is defined in the org level the source_type
           -- will be null. Still we need to see that sourcing rule. So the condition
           -- Source_type <> 3 is replaced with nvl(source_type,1). When the source_type is
           -- Null it will be defaulted to 1(Transfer from).
           /* Please note the changes done for procuring config project */
           -- Since the buy sourcing needs to be supported the where condition for msv.source_type is removed
           -- from the following query.

           l_stmt_num := 10 ;
           BEGIN
              select distinct
                source_organization_id,
                sourcing_rule_id,
                nvl(source_type,1) ,
                nvl( avg_transit_lead_time , 0 )
              into
                p_sourcing_org
              , v_sourcing_rule_id
              , v_source_type
              , p_transit_lead_time
              from mrp_sources_v msv
              where msv.assignment_set_id = gMrpAssignmentSet
                and msv.inventory_item_id = p_inventory_item_id
                and msv.organization_id = p_organization_id
                and nvl(effective_date,sysdate) <= nvl(disable_date, sysdate)
                and nvl(disable_date, sysdate+1) > sysdate;

              /*
              ** item is multi-org if sourcing rule is transfer from.
              */
              l_stmt_num := 20 ;
              p_source_type := v_source_type ;

              IF( v_source_type = 1 ) THEN
                  p_sourcing_rule_exists := FND_API.G_TRUE ;
              ELSIF v_source_type = 3 THEN
                  IF PG_DEBUG <> 0 THEN
                  	oe_debug_pub.add('query_sourcing_org: ' || 'Buy Sourcing rule exists...',4);
                  END IF;
              END IF ;

              IF PG_DEBUG <> 0 THEN
              	oe_debug_pub.add('query_sourcing_org: ' ||  '****$$$$ IID ' || p_inventory_item_id || ' in org ' ||
                      p_organization_id || ' is sourced from org ' || p_sourcing_org ||
                      ' type ' || v_source_type || ' $$$$****' , 5 );
              END IF;

           EXCEPTION
              WHEN NO_DATA_FOUND THEN
                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add('query_sourcing_org: ' ||  ' came into no data when finding source ' || to_char(l_stmt_num ) , 1  );
                END IF;
                /* removed no sourcing flag as cascading of sourcing rules will
                ** be continued till no more sourcing rules can be cascaded
                ** add check for buy attribute for model
                */
                --- When there is no sourcing rule defined we need to look at the
                --- Planning_make_buy_code to determine the source_type
                --- If the planning_make_buy_code is 1(Make) we can return as it is
                --- If the planning_make_buy_code is 2(Buy) we need to set the p_source_type to 3 and return
                --- so that the calling application will knwo this as buy model

                SELECT planning_make_buy_code
                INTO   l_make_buy_code
                FROM   MTL_SYSTEM_ITEMS
                WHERE  inventory_item_id = p_inventory_item_id
                AND    organization_id   = p_organization_id;

                IF l_make_buy_code = 2 THEN
                  p_source_type := 3;
                END IF;

              WHEN TOO_MANY_ROWS THEN
                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add('query_sourcing_org: ' ||  ' came into too_many when finding source ' || to_char(l_stmt_num)  , 1  );
                END IF;
              select count(*)
              into v_sourcing_rule_count
              from mrp_sources_v msv
              where msv.assignment_set_id = gMrpAssignmentSet
                and msv.inventory_item_id = p_inventory_item_id
                and msv.organization_id = p_organization_id
                and nvl(msv.source_type,1) <> 3
                and nvl(effective_date,sysdate) <= nvl(disable_date, sysdate)
                and nvl(disable_date, sysdate+1) > sysdate;

                IF( v_sourcing_rule_count > 0 ) THEN
                    x_return_status                := FND_API.G_RET_STS_ERROR;
                    g_expected_error_code := 66;
                ELSE
                    p_source_type := 3 ;
                END IF ;

              WHEN OTHERS THEN
                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add('query_sourcing_org: ' ||  'QUERY_SOURCING_ORG::others:: ' ||
                                   to_char(l_stmt_num) || '::' ||
                                  ' came into others when finding source ' , 1  );
                	oe_debug_pub.add('query_sourcing_org: ' ||  ' SQLCODE ' || SQLCODE , 1 );
                	oe_debug_pub.add('query_sourcing_org: ' ||  ' SQLERRM ' || SQLERRM  , 1 );
                	oe_debug_pub.add('query_sourcing_org: ' ||  ' came into others when finding source ' , 1  );
                END IF;

                x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;
           END ;
END query_sourcing_org ;



/*
** This procedure finds the level of the components in its heirarchy.
** The levels are numbered for ATO models and their components.
** However PTO models and PTO components are marked as level 0.
*/
PROCEDURE populate_plan_level(
  p_t_bcol  in out NOCOPY CTO_SHIPSET_TBL_TYPE
)
 is
 TYPE TABNUM is TABLE of NUMBER index by binary_integer ;
 v_raw_line_id TABNUM ;
 v_src_point   number ;
 j             number ;
 v_step        VARCHAR2(10) ;
 BEGIN
    /*
    ** Strategy: Resolve plan_level for each line item by setting it to 1 + plan_level of parent.
    ** use the link_to_line_id column to get to the parent. if parents plan_level is not yet
    ** resolved, go to its immediate ancestor recursively till you find a line item with
    ** plan_level set( Top level plan level is always set to zero ). When coming out of recursion
    ** set the plan_level of any ancestors that havent been resolved yet.
    ** Implementation: As Pl/Sql does not support Stack built-in-datatype, an equivalent behavior
    ** can be achieved by storing items in a table( PUSH implementation) and retrieving them from
    ** the end of the table ( POP implmentation [LIFO] )
    */
        v_step := 'Step B1' ;
    FOR i IN p_t_bcol.first..p_t_bcol.last
    LOOP
       IF( p_t_bcol.exists(i)  ) THEN
          v_src_point := i ;
          /*
          ** resolve plan level for item only if not yet resolved
          */
          WHILE( p_t_bcol(v_src_point).plan_level is null )
          LOOP
             IF PG_DEBUG <> 0 THEN
             	oe_debug_pub.add('populate_plan_level: ' ||  ' v_src_point ' || v_src_point , 5 );
             END IF;

             v_raw_line_id(v_raw_line_id.count + 1 ) := v_src_point  ;

             /* store each unresolved item in its heirarchy */
             IF( p_t_bcol(v_src_point).link_to_line_id is not null AND
                 p_t_bcol(v_src_point).ato_line_id is not null ) THEN
                 /* stop right at top ato line id in the case of pto-ato hybrid */
                 IF( p_t_bcol(v_src_point).line_id =
                     p_t_bcol(v_src_point).ato_line_id )
                 THEN
                    p_t_bcol(v_src_point).plan_level := 0 ;
                    exit ;
                 ELSE
                    v_src_point := p_t_bcol(v_src_point).link_to_line_id ;
                 END IF ;

             ELSE
                 /* assign level = 0 for single ato or single pto */
                 p_t_bcol(v_src_point).plan_level := 0 ;
                 exit ;
             END IF;
          END LOOP ;

        v_step := 'Step B2' ;
          j := v_raw_line_id.count ; /* total number of items to be resolved */
          WHILE( j >= 1 )
          LOOP
             p_t_bcol(v_raw_line_id(j)).plan_level := p_t_bcol(v_src_point).plan_level + 1;
             v_src_point := v_raw_line_id(j) ;
             j := j -1 ;
          END LOOP ;

          v_raw_line_id.delete ; /* remove all elements as they have been resolved */

       END IF ;
    END LOOP ;

 EXCEPTION
 WHEN others THEN
   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('populate_plan_level: ' ||  ' error ' || SQLCODE , 1 );

   	oe_debug_pub.add('populate_plan_level: ' ||  ' error ' || SQLERRM , 1 );
   END IF;
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
 END populate_plan_level ;



/*
** This procedure populates the parent_ato_line_id for a component in a given model heirarchy.
** This information is populated only for components under an ATO model.
*/
PROCEDURE populate_parent_ato(
  p_t_bcol  in out NOCOPY CTO_SHIPSET_TBL_TYPE
, p_bcol_line_id in      oe_order_lines.line_id%type
)
 is
 TYPE TABNUM is TABLE of NUMBER index by binary_integer ;
 v_raw_line_id TABNUM ;
 v_src_point   number ;
 v_prev_src_point   number ;
 j             number ;
 v_step        VARCHAR2(10) ;
 BEGIN
    /*
    ** Strategy: Resolve parent_ato for each line item by setting it to 1 + plan_level of parent.
    ** use the link_to_line_id column to get to the parent. if parents plan_level is not yet
    ** resolved, go to its immediate ancestor recursively till you find a line item with
    ** plan_level set( Top level plan level is always set to zero ). When coming out of recursion
    ** set the plan_level of any ancestors that havent been resolved yet.
    ** Implementation: As Pl/Sql does not support Stack built-in-datatype, an equivalent behavior
    ** can be achieved by storing items in a table( PUSH implementation) and retrieving them from
    ** the END of the table ( POP implmentation [LIFO] )
    */

    v_step := 'Step C1' ;
    FOR i IN p_t_bcol.first..p_t_bcol.last
    LOOP
       IF( p_t_bcol.exists(i)  ) THEN
          v_src_point := i ;

       IF( p_t_bcol(v_src_point).ato_line_id is not null ) THEN
          /* please note, here it stores the index which is the same as line_id due to sparse array*/
          IF PG_DEBUG <> 0 THEN
          	oe_debug_pub.add('populate_parent_ato: ' ||  ' processing ' || to_char( v_src_point ) , 4 );
          END IF;
          /*
          ** resolve parent ato line id for item.
          */

        v_step := 'Step C2' ;
          WHILE( p_t_bcol.exists(v_src_point) )
          LOOP
             v_raw_line_id(v_raw_line_id.count + 1 ) := v_src_point  ;
             IF( p_t_bcol(v_src_point).line_id =
                 p_t_bcol(v_src_point).ato_line_id )
             THEN
                exit ;
             END IF ;

             /* store each unresolved item in its heirarchy */
             v_prev_src_point := v_src_point ;
             v_src_point := p_t_bcol(v_src_point).link_to_line_id ;

             IF PG_DEBUG <> 0 THEN
             	oe_debug_pub.add('populate_parent_ato: ' ||  'prev point ' || to_char( v_prev_src_point ) || ' bcol ' || to_char( p_bcol_line_id ) , 5 );
             END IF;

             IF( v_src_point is null  ) THEN
                v_src_point := v_prev_src_point ;
                exit ;
             END IF ;

             IF(  p_t_bcol(v_src_point).ato_line_id is null  or v_prev_src_point = p_bcol_line_id ) THEN
                v_src_point := v_prev_src_point ;
                 /* break IF pto is on top of top level ato or
                    the current lineid is top level phantom ato
                 v_src_point := null ;
                 */
                 exit ;
             END IF ;

             IF( p_t_bcol(v_src_point).bom_item_type = '1' AND
                 p_t_bcol(v_src_point).ato_line_id is not null AND
                 nvl( p_t_bcol(v_src_point).wip_supply_type , 0 ) <> '6' ) THEN
                   exit ;
                  /* break if non phantom ato parent found */
             END IF ;
          END LOOP ;

          j := v_raw_line_id.count ; /* total number of items to be resolved */

        v_step := 'Step C3' ;
          WHILE( j >= 1 )
          LOOP
             p_t_bcol(v_raw_line_id(j)).parent_ato_line_id := v_src_point ;
             j := j -1 ;
          END LOOP ;

          /* remove all elements as they have been resolved */
          v_raw_line_id.delete ;

        END IF ; /* check whether ato_line_id is not null */

       END IF ;
    END LOOP ;
 END populate_parent_ato ;



/*
** This procedure propagates the ato_line_id for a component in a given model heirarchy
** for calls originating from CZ.
*/
PROCEDURE propagate_ato_line_id(
  p_location         number
)
is
v_model_line_id  number ;
BEGIN
   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('propagate_ato_line_id: ' ||  'Entered propagate_ato_line_id p_location ' || p_location , 2 );
   END IF;

   IF( p_location is null ) THEN
       return ;
   END IF ;

   v_model_line_id := g_requests_tab(p_location).line_id ;
   /*
   ** for each model child of top level model
   */
   FOR j IN g_requests_tab.first..g_requests_tab.last
   LOOP
      IF( g_requests_tab.exists(j)) THEN
      IF( v_model_line_id = g_requests_tab(j).link_to_line_id ) THEN
          IF( g_requests_tab(p_location).ato_line_id is not null ) THEN
				  g_requests_tab(j).ato_line_id := g_requests_tab(p_location).ato_line_id ;
          ELSE
                   /*
                   ** check whether this item is an ATO MODEL!!
                   */
                   IF( g_requests_tab(j).bom_item_type = '1' AND
		       g_requests_tab(j).replenish_to_order_flag = 'Y'
		      ) THEN
		      g_requests_tab(j).ato_line_id := g_requests_tab(j).line_id ;
                   END IF ;
          END IF;

      ELSIF( g_requests_tab(j).link_to_line_id is null ) THEN
                   IF( g_requests_tab(j).bom_item_type = '1' AND
		       g_requests_tab(j).replenish_to_order_flag = 'Y'
		      ) THEN
		      g_requests_tab(j).ato_line_id := g_requests_tab(j).line_id ;
                   END IF ;
      END IF ;
     END IF ;
   END LOOP ;

   propagate_ato_line_id( g_requests_tab.next(p_location ) ) ;

END propagate_ato_line_id ;



/*
** This procedure is called in the post-atp phase for reconstructing the original shipset
** from the reduced shipset.
** A set of reduced shipset is passed with a supporting structure to indicate the atp success/failure status.
** This procedure reconstructs all the shipsets by consulting the saved shipset structure.
*/
PROCEDURE reconstruct_shipset(
  p_shipset    in out NOCOPY MRP_ATP_PUB.ATP_REC_TYP
, p_success_flag_tbl in   MRP_ATP_PUB.SHIPSET_STATUS_REC_TYPE
, x_return_status out     varchar2
, x_msg_count     out     number
, x_msg_data      out     varchar2
)
is
v_reduced_shipset    MRP_ATP_PUB.ATP_REC_TYP  ;
v_reduced_shipset_init    MRP_ATP_PUB.ATP_REC_TYP  ;
v_shipset_init    MRP_ATP_PUB.ATP_REC_TYP  ;
v_null_atp_rec    MRP_ATP_PUB.ATP_REC_TYP  ;
v_shipset_loc   number ;
v_char         varchar2(1) := FND_API.G_TRUE ;
v_success_status boolean ;
l_stmt_num     number ;
k              number:=0;
v_auto_gen boolean;
v_process_demand boolean;

BEGIN

  l_stmt_num := 1 ;

  IF PG_DEBUG <> 0 THEN
  	oe_debug_pub.add('reconstruct_shipset: ' ||  'Before reconstruct shipset ' , 1 );
	print_shipset( p_shipset ) ;
  	oe_debug_pub.add('reconstruct_shipset: ' ||  'Done printing before reconstruct shipset ' , 4 );
  	oe_debug_pub.add('reconstruct_shipset: ' ||  'Printing p_success_flag_tbl sent by ATP', 4);
  END IF;

  /* removed stmt FOR j IN g_shipset_status_tbl.first..g_shipset_status_tbl.last */

  FOR j IN p_success_flag_tbl.ship_set_name.first..p_success_flag_tbl.ship_set_name.last
   LOOP
	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('reconstruct_shipset: ' || 'Contents of shipset status table::', 3);
		oe_debug_pub.add('reconstruct_shipset: ' ||  p_success_flag_tbl.ship_set_name(j), 3);
		oe_debug_pub.add('reconstruct_shipset: ' ||  p_success_flag_tbl.status(j), 3);
	END IF;
   END LOOP;
  IF PG_DEBUG <> 0 THEN
  	oe_debug_pub.add('reconstruct_shipset: ' ||  'Done printing p_success_flag_tbl sent by ATP', 3);
  END IF;



  FOR j IN g_shipset_status_tbl.first..g_shipset_status_tbl.last
   LOOP
	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('reconstruct_shipset: ' || 'Contents of g_shipset_status table::', 3);
		oe_debug_pub.add('reconstruct_shipset: ' ||  g_shipset_status_tbl(j).ship_set_name, 3);
	END IF;
   END LOOP;
  IF PG_DEBUG <> 0 THEN
  	oe_debug_pub.add('reconstruct_shipset: ' ||  'Done printing g_shipset_status_tbl sent by ATP', 3);
  END IF;





  l_stmt_num := 10 ;
  IF( p_shipset.group_ship_date.count = 1 AND p_shipset.group_ship_date(1) is null )
  THEN
     p_shipset.group_ship_date(1) := p_shipset.ship_date(1) ;
  END IF ;

   l_stmt_num := 20 ;
   FOR j IN g_shipset_status_tbl.first..g_shipset_status_tbl.last
   LOOP
       IF PG_DEBUG <> 0 THEN
       	oe_debug_pub.add('reconstruct_shipset: ' ||  'Processing shipset ' || g_shipset_status_tbl(j).ship_set_name , 2 );
       END IF;

       l_stmt_num := 30 ;
       FOR m IN p_success_flag_tbl.ship_set_name.first..p_success_flag_tbl.ship_set_name.last
       LOOP
          l_stmt_num := 40 ;
          IF( p_success_flag_tbl.ship_set_name(m) = g_shipset_status_tbl(j).ship_set_name ) THEN
              l_stmt_num := 50 ;
	      IF( FND_API.to_boolean(p_success_flag_tbl.status(m)))
              THEN
              g_shipset_status_tbl(j).success_status := TRUE ;
              ELSE
              g_shipset_status_tbl(j).success_status := FALSE ;
              END IF ;
              exit ;
          END IF ;
       END LOOP ;

       l_stmt_num := 60 ;
       v_reduced_shipset := v_reduced_shipset_init ;
       FOR i IN p_shipset.ship_set_name.first..p_shipset.ship_set_name.last
       LOOP
          l_stmt_num := 70 ;
          if( p_shipset.ship_set_name(i) is null ) then
              p_shipset.ship_set_name(i) := p_shipset.identifier(i) ;

             oe_debug_pub.add( ' initialized' || p_shipset.identifier(i), 5 ) ;
          end if ;

          oe_debug_pub.add( 'reconstruct_shipset: comparing ' || p_shipset.ship_set_name(i) || ' -> '
                           || g_shipset_status_tbl(j).ship_set_name , 5 ) ;
          IF( p_shipset.ship_set_name(i) = g_shipset_status_tbl(j).ship_set_name ) THEN
              MRP_ATP_PVT.assign_atp_input_rec(
                   p_shipset,
                   i,
                   v_reduced_shipset,
                   x_return_status );

             oe_debug_pub.add( ' copied ' || x_return_status , 5 ) ;
          END IF ;
       END LOOP ;

       l_stmt_num := 80 ;

       g_shipset := v_shipset_init ;
       IF PG_DEBUG <> 0 THEN
       	oe_debug_pub.add('reconstruct_shipset: ' ||  'Copying final shipset, sount is:: ' || g_final_shipset.ship_set_name.count ,5 );
       	oe_debug_pub.add('reconstruct_shipset: ' ||  'v_reduced_shipset count is:: ' || v_reduced_shipset.ship_set_name.count ,5 );
       END IF;

       FOR i IN g_final_shipset.ship_set_name.first..g_final_shipset.ship_set_name.last
       LOOP
          l_stmt_num := 90 ;
          IF( g_final_shipset.ship_set_name(i) = g_shipset_status_tbl(j).ship_set_name ) THEN
              MRP_ATP_PVT.assign_atp_input_rec(
                  g_final_shipset,
                  i,
                  g_shipset,
                  x_return_status );
          END IF ;
       END LOOP ;

       g_cto_shipset.delete ;
       g_cto_sparse_shipset.delete ;

       l_stmt_num := 100 ;
       FOR i IN g_final_cto_shipset.first..g_final_cto_shipset.last
       LOOP

          l_stmt_num := 110 ;
          IF( g_final_cto_shipset(i).ship_set_name = g_shipset_status_tbl(j).ship_set_name ) THEN
              g_cto_shipset(g_cto_shipset.count ) := g_final_cto_shipset(i) ;
              g_cto_sparse_shipset(g_final_cto_shipset(i).line_id ) := g_final_cto_shipset(i) ;
           IF PG_DEBUG <> 0 THEN
           	oe_debug_pub.add('reconstruct_shipset: ' ||  'Added line_id' || g_final_cto_shipset(i).line_id || ' to g_cto_shipset and g_final_cto_shipset',  1 );
           END IF;
          END IF ;
       END LOOP ;

       IF PG_DEBUG <> 0 THEN
       	oe_debug_pub.add('reconstruct_shipset: ' ||  ' CALLING RESURRECT shipset '  , 1 );
       END IF;

       l_stmt_num := 120 ;
       resurrect_shipset(
          v_reduced_shipset
        , g_shipset_status_tbl(j).success_status
        , x_return_status
        , x_msg_count
        , x_msg_data
      ) ;

       /* Added this call to populate configuration status
          to decide how to populate visible demand flag
       */
          populate_configuration_status ;

          populate_visible_demand(
          v_reduced_shipset
        , g_shipset_status_tbl(j).success_status
        , x_return_status
        , x_msg_count
        , x_msg_data
         ) ;

     /*
     ** copy the enhanced shipset data back to final shipset
     */
       l_stmt_num := 130 ;
       IF PG_DEBUG <> 0 THEN
       	oe_debug_pub.add('reconstruct_shipset: ' || 'Redecued shipset name count = '||v_reduced_shipset.ship_set_name.count,2);
       END IF;

       FOR i IN v_reduced_shipset.ship_set_name.first..v_reduced_shipset.ship_set_name.last
       LOOP
          l_stmt_num := 140 ;
          IF  g_shipset_status_tbl(j).ship_set_name = v_reduced_shipset.ship_set_name(i)  THEN
          k := k+1;
          v_shipset_loc := k + g_shipset_status_tbl(j).start_location - 1;

          IF PG_DEBUG <> 0 THEN
          	oe_debug_pub.add('reconstruct_shipset: ' ||  'start =' || g_shipset_status_tbl(j).start_location || ' loc =' || v_shipset_loc || ' k = ' || k  , 5 );
          END IF;

          g_final_shipset.Available_Quantity(v_shipset_loc) := v_reduced_shipset.available_quantity(k) ;
          g_final_shipset.Requested_Date_Quantity(v_shipset_loc) := v_reduced_shipset.requested_date_quantity(k) ;
          g_final_shipset.Group_Ship_Date(v_shipset_loc) := v_reduced_shipset.group_ship_date(k) ;
          g_final_shipset.Ship_Date(v_shipset_loc) := v_reduced_shipset.ship_date(k) ;
          g_final_shipset.Group_Arrival_Date(v_shipset_loc) := v_reduced_shipset.group_arrival_date(k) ;
          g_final_shipset.error_code(v_shipset_loc) := v_reduced_shipset.error_code(k) ;
          /* BUG#2158449 added as per navneet on 03-27-2002 */
          g_final_shipset.Arrival_Date(v_shipset_loc) :=v_reduced_shipset.arrival_date(k)  ;
          g_final_shipset.delivery_lead_time(v_shipset_loc) := v_reduced_shipset.delivery_lead_time(k) ;
          g_final_shipset.source_organization_id (v_shipset_loc) :=v_reduced_shipset.source_organization_id(k)  ;
          g_final_shipset.ship_method(v_shipset_loc) :=v_reduced_shipset.ship_method(k) ;
          g_final_shipset.END_pegging_id(v_shipset_loc) :=v_reduced_shipset.END_pegging_id(k)  ;
          g_final_shipset.attribute_05(v_shipset_loc) := v_reduced_shipset.attribute_05(k);
	  END IF;
       END LOOP ;

       k := 0;

   END LOOP ;

   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('reconstruct_shipset: ' ||  'Done reconstruct shipset ' ,1 );
   END IF;

  print_shipset( g_final_shipset ) ;


  /* overwrite values from null shipset to original shipset location */
  for v_no_name in p_shipset.ship_set_name.first..p_shipset.ship_set_name.last
  LOOP
      IF( p_shipset.ship_set_name(v_no_name) is null ) THEN

      FOR v_index IN g_final_shipset.ship_set_name.first..g_final_shipset.ship_set_name.last
      LOOP

         IF( p_shipset.identifier(v_no_name) = g_final_shipset.identifier(v_index) AND
             p_shipset.inventory_item_id(v_no_name) =
             g_final_shipset.inventory_item_id(v_index)
           ) THEN

             g_final_shipset.Available_Quantity(v_index) := p_shipset.available_quantity(v_no_name) ;
             g_final_shipset.Requested_Date_Quantity(v_index) := p_shipset.requested_date_quantity(v_no_name) ;
             g_final_shipset.Group_Ship_Date(v_index) := p_shipset.group_ship_date(v_no_name) ;
             g_final_shipset.Ship_Date(v_index) := p_shipset.ship_date(v_no_name) ;
             g_final_shipset.Group_Arrival_Date(v_index) := p_shipset.group_arrival_date(v_no_name) ;
             g_final_shipset.error_code(v_index) := p_shipset.error_code(v_no_name) ;
             g_final_shipset.attribute_05(v_index) := p_shipset.attribute_05(v_no_name);

         END IF ;

     END LOOP ;

     END IF ;

  END LOOP ;


   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('reconstruct_shipset: ' ||  'Going to null out shipset names ' ,3 );
   END IF;
  /* null out the auto generated shipset names */

  FOR v_auto_shipset IN g_final_shipset.ship_set_name.first..g_final_shipset.ship_set_name.last
  LOOP

      isAutoGeneratedShipset(
	g_final_shipset.ship_set_name(v_auto_shipset),
	v_auto_gen,
	v_process_demand);

      IF v_auto_gen THEN
          g_final_shipset.ship_set_name(v_auto_shipset) := null ;
      END IF ;

      IF( g_final_shipset.error_code.exists(v_auto_shipset)) THEN
          IF( g_final_shipset.error_code(v_auto_shipset) is null ) THEN
              g_final_shipset.error_code(v_auto_shipset) := 0 ;
          END IF ;
      END IF ;

  END LOOP ;

   p_shipset := g_final_shipset ;

   l_stmt_num := 150 ;
   --remove_elements_from_atp_rec( v_reduced_shipset ) ;
   v_reduced_shipset := v_null_atp_rec;

   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('reconstruct_shipset: ' ||  ' Done null shipset copy ' ,4 );
   END IF;

   print_shipset( p_shipset ) ;

EXCEPTION
 WHEN others THEN
   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('reconstruct_shipset: ' ||  ' error encountered in reconstruct_shipset at line ' || to_char(l_stmt_num ) , 1 );
   	oe_debug_pub.add('reconstruct_shipset: ' ||  ' error ' || SQLCODE , 1 );
   	oe_debug_pub.add('reconstruct_shipset: ' ||  ' error ' || SQLERRM , 1 );
   END IF;
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

END reconstruct_shipset ;



/*
** This procedure accepts a reduced shipset and resurrects it with the saved shipset information.
** This procedure also propagates information returned by ATP for each model to its child components
** depending on the status of the ATP result for the shipset.
*/
/* BUGFIX 2406559 for this procedure at multiple places
*/
PROCEDURE resurrect_shipset(
  p_shipset    in out NOCOPY MRP_ATP_PUB.ATP_REC_TYP
, p_success_flag in boolean
, x_return_status out     varchar2
, x_msg_count     out     number
, x_msg_data      out     varchar2
)
is
v_new_available_quantity number ;
v_new_requested_date_quantity number ;
v_new_group_ship_date DATE ;
v_new_ship_date DATE ;
v_new_group_arrival_date  DATE ;
v_shipset_loc        number ;
v_curr_line_id        number ;
l_stmt_num           number ;
v_new_arrival_date     DATE ;
v_new_delivery_lead_time  number ;
v_new_source_organization_id  number ;
v_new_ship_method  VARCHAR2(40) ;
v_new_end_pegging_id  number ;
v_action       number ;

BEGIN

  l_stmt_num := 1 ;
  IF PG_DEBUG <> 0 THEN
  	oe_debug_pub.add('resurrect_shipset: ' ||  ' printing reduced shipset before resurrection ' , 2 );
  	print_shipset( p_shipset ) ;
  END IF;
  v_action := p_shipset.action(p_shipset.action.first) ;

  IF( p_success_flag ) THEN
   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('resurrect_shipset: ' ||  ' p_success_flag is true ' , 2 );
   END IF;
  ELSE
   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('resurrect_shipset: ' ||  ' p_success_flag is false ' , 2 );
   END IF;
  END IF ;


  l_stmt_num := 20 ;
   /* for each element in reduced shipset */
   FOR i IN 1..p_shipset.identifier.count
   LOOP
      /*
      ** check whether top ato model exists
      */
      l_stmt_num := 30 ;

      IF( g_cto_sparse_shipset.exists(p_shipset.identifier(i)) )
      THEN

        v_curr_line_id := g_cto_sparse_shipset(p_shipset.identifier(i)).line_id ;

       	IF( get_shipset_source_flag( g_cto_sparse_shipset(v_curr_line_id).ship_set_name )  = TRUE ) THEN

               l_stmt_num := 40 ;
               v_new_available_quantity := p_shipset.Available_Quantity(i) ;
               v_new_requested_date_quantity := p_shipset.Requested_Date_Quantity(i) ;
               v_new_group_ship_date := p_shipset.Group_Ship_Date(i) ;
               v_new_ship_date := p_shipset.Ship_Date(i) ;
               v_new_group_arrival_date := p_shipset.Group_Arrival_Date(i) ;
               /* BUG#2158449 added as per navneet on 03-27-2002 */
               v_new_arrival_date := p_shipset.Arrival_Date(i) ;
               v_new_delivery_lead_time := p_shipset.delivery_lead_time(i) ;
               v_new_source_organization_id := p_shipset.source_organization_id(i) ;
               v_new_ship_method := p_shipset.ship_method(i) ;
               v_new_end_pegging_id := p_shipset.end_pegging_id(i) ;

               /*
               ** register_error
               */
               l_stmt_num := 50 ;
               IF( p_shipset.error_code.exists(i) ) THEN
                  IF( p_shipset.error_code(i) is not null) THEN
			IF( get_shipset_source_flag( g_cto_sparse_shipset(v_curr_line_id).ship_set_name )  = TRUE ) THEN
               			register_error( p_shipset.ship_set_name.first ,
                      			p_shipset.identifier(i) , p_shipset.error_code(i) ,
                      			v_action,
                      			p_success_flag,
                      			x_return_status ) ;
        		END IF ;
                   END IF;
           	END IF;

            	l_stmt_num := 60 ;
           	/*
           	** propagate information for all the lower level components of ato model
           	*/
           	FOR j IN g_cto_shipset.first..g_cto_shipset.last
           	LOOP

              		l_stmt_num := 70 ;
              		IF( g_cto_shipset(j).ato_line_id  = v_curr_line_id ) THEN
                  		v_shipset_loc := g_cto_shipset(j).location ;

                  		l_stmt_num := 80 ;
                  		/* check whether top level parent or its component */
                  		IF( g_cto_shipset(j).line_id <> v_curr_line_id ) THEN

                      		    l_stmt_num := 90 ;
                      		    IF( p_success_flag  ) THEN

                          		l_stmt_num := 100 ;
                          		g_shipset.Available_Quantity(v_shipset_loc) := v_new_available_quantity ;
                          		g_shipset.Requested_Date_Quantity(v_shipset_loc) := v_new_requested_date_quantity ;
                          		g_shipset.Group_Ship_Date(v_shipset_loc) := v_new_group_ship_date ;
                          		g_shipset.Ship_Date(v_shipset_loc) := v_new_ship_date ;
                          		g_shipset.Group_Arrival_Date(v_shipset_loc) := v_new_group_arrival_date ;
                          		/* BUG#2158449 added as per navneet on 03-27-2002 */
                          		g_shipset.Arrival_Date(v_shipset_loc) :=v_new_arrival_date;
                          		g_shipset.delivery_lead_time(v_shipset_loc) := v_new_delivery_lead_time ;
                          		g_shipset.source_organization_id (v_shipset_loc) :=v_new_source_organization_id  ;
                          		g_shipset.ship_method(v_shipset_loc) :=v_new_ship_method  ;
                          		g_shipset.end_pegging_id(v_shipset_loc) :=v_new_end_pegging_id ;

                      		     ELSE

                          		l_stmt_num := 110 ;
                          		g_shipset.Available_Quantity(v_shipset_loc) := null ;
                          		g_shipset.Requested_Date_Quantity(v_shipset_loc) := null ;
                          		g_shipset.Group_Ship_Date(v_shipset_loc) := null ;
                          		g_shipset.Ship_Date(v_shipset_loc) := null ;
                          		g_shipset.Group_Arrival_Date(v_shipset_loc) := null ;
                      		     END IF ;
                  		ELSE

                      		     l_stmt_num := 120 ;
                      		     /* do not nullify the information in the parent record */
                       		     g_shipset.Available_Quantity(v_shipset_loc) := v_new_available_quantity ;
                      		     g_shipset.Requested_Date_Quantity(v_shipset_loc) := v_new_requested_date_quantity ;
                      		     g_shipset.Group_Ship_Date(v_shipset_loc) := v_new_group_ship_date ;
                      		     g_shipset.Ship_Date(v_shipset_loc) := v_new_ship_date ;
                      		     g_shipset.Group_Arrival_Date(v_shipset_loc) := v_new_group_arrival_date ;
                        	     /* BUG#2158449 added as per navneet on 03-27-2002 */
                      		     g_shipset.Arrival_Date(v_shipset_loc) :=v_new_arrival_date  ;
                      		     g_shipset.delivery_lead_time(v_shipset_loc) := v_new_delivery_lead_time ;
                      		     g_shipset.source_organization_id (v_shipset_loc) :=v_new_source_organization_id  ;
                      		     g_shipset.ship_method(v_shipset_loc) :=v_new_ship_method  ;
                      		     g_shipset.end_pegging_id(v_shipset_loc) :=v_new_end_pegging_id;

                  		END IF ;

              		END IF ;
           	END LOOP ;
       	ELSE

           /* this code will be executed for non sourced shipsets  */
           /* Changes to support product substitution */

          l_stmt_num := 130 ;
          FOR j IN g_shipset.identifier.first..g_shipset.identifier.last
          LOOP

             l_stmt_num := 140 ;
             IF( g_shipset.identifier(j) = p_shipset.identifier(i) ) THEN

                      l_stmt_num := 150 ;
                      g_shipset.Available_Quantity(j) := p_shipset.available_quantity(i) ;
                      g_shipset.Requested_Date_Quantity(j) :=  p_shipset.requested_date_quantity(i) ;

                      g_shipset.Group_Ship_Date(j) := p_shipset.group_ship_date(i);
                      g_shipset.Ship_Date(j) := p_shipset.ship_date(i);
                      g_shipset.Group_Arrival_Date(j) := p_shipset.group_arrival_date(i) ;
                      g_shipset.error_code(j) := p_shipset.error_code(i) ;

                      l_stmt_num := 155 ;
                      g_shipset.Arrival_Date(j) := p_shipset.arrival_date(i)  ;
                      g_shipset.delivery_lead_time(j) := p_shipset.delivery_lead_time(i) ;
                      g_shipset.source_organization_id (j) := p_shipset.source_organization_id(i)  ;
                      g_shipset.ship_method(j) := p_shipset.ship_method(i)  ;
                      g_shipset.end_pegging_id(j) := p_shipset.end_pegging_id(i)  ;
                      /* BUG#2250630 product substitution code changes */
                      g_shipset.request_item_id (j) := p_shipset.request_item_id(i) ;
                      g_shipset.inventory_item_id(j) := p_shipset.inventory_item_id(i) ;
                      /* BUG#2250630 product substitution code changes */
              end IF ;
          END LOOP ;

       END IF ; /* if g_cto_sparse_shipset is a sourced shipset */

       ELSE
            /* shipset line does not exist */
           /* this code will be executed for standard items part of shipset */
           /* Changes to support product substitution */

            IF PG_DEBUG <> 0 THEN
            	oe_debug_pub.add('resurrect_shipset: ' ||  '  shipset line does not exist ' || p_shipset.identifier(i) , 5);
            END IF;

          l_stmt_num := 130 ;
          FOR j IN g_shipset.identifier.first..g_shipset.identifier.last
          LOOP

             l_stmt_num := 140 ;
             IF( g_shipset.identifier(j) = p_shipset.identifier(i) ) THEN

                      l_stmt_num := 150 ;
                      g_shipset.Available_Quantity(j) := p_shipset.available_quantity(i) ;
                      g_shipset.Requested_Date_Quantity(j) :=  p_shipset.requested_date_quantity(i) ;
                      g_shipset.Group_Ship_Date(j) := p_shipset.group_ship_date(i);
                      g_shipset.Ship_Date(j) := p_shipset.ship_date(i);
                      g_shipset.Group_Arrival_Date(j) := p_shipset.group_arrival_date(i) ;
                      g_shipset.error_code(j) := p_shipset.error_code(i) ;
                      g_shipset.Arrival_Date(j) := p_shipset.arrival_date(i)  ;
                      g_shipset.delivery_lead_time(j) := p_shipset.delivery_lead_time(i) ;
                      g_shipset.source_organization_id (j) := p_shipset.source_organization_id(i)  ;
                      g_shipset.ship_method(j) := p_shipset.ship_method(i)  ;
                      g_shipset.END_pegging_id(j) := p_shipset.end_pegging_id(i)  ;

                      /* BUG#2250630 product substitution code changes */
                      g_shipset.request_item_id (j) := p_shipset.request_item_id(i) ;
                      g_shipset.inventory_item_id(j) := p_shipset.inventory_item_id(i) ;
              END IF ;
          END LOOP ;

       END IF ; /* if element exists in g_cto_sparse_shipset */

   END LOOP ;

   l_stmt_num := 160 ;
   p_shipset := g_shipset ;
   populate_error( p_shipset , x_return_status ) ;

   l_stmt_num := 170 ;

   IF PG_DEBUG <> 0 THEN
  	oe_debug_pub.add('resurrect_shipset: ' ||  'After resurrect shipset ' , 1 );
   END IF;

   l_stmt_num := 180 ;
   print_shipset( p_shipset ) ;

EXCEPTION
 WHEN others THEN
   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('resurrect_shipset: ' ||  ' error encountered in resurrect_shipset at line ' || to_char(l_stmt_num ) , 1 );
   	oe_debug_pub.add('resurrect_shipset: ' ||  ' error ' || SQLCODE , 1 );
   	oe_debug_pub.add('resurrect_shipset: ' ||  ' error ' || SQLERRM , 1 );
   END IF;
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
END resurrect_shipset;



PROCEDURE populate_configuration_status
is
type top_model_tab_type  is table of number index by binary_integer ;
t_top_model_tab top_model_tab_type ;

/* populate top model line id location with 0 for no config and 1 for config created */
v_config_exists boolean ;
l_stmt_num   number ;
BEGIN

 IF PG_DEBUG <> 0 THEN
 	oe_debug_pub.add('populate_configuration_status: ' || 'Populating Configuration Status ..',4);
 END IF;
 l_stmt_num :=  1 ;

 IF( g_cto_shipset.count > 0 ) THEN
 FOR i IN g_cto_shipset.first..g_cto_shipset.last
 LOOP

    l_stmt_num :=  5 ;
    IF g_cto_shipset(i).ato_line_id is not null THEN
    IF( g_cto_shipset.exists(i) ) THEN

       l_stmt_num :=  10 ;
       IF ( t_top_model_tab.exists(g_cto_shipset(i).ato_line_id) ) THEN

            l_stmt_num :=  20 ;
            IF( t_top_model_tab(g_cto_shipset(i).ato_line_id) = 0 ) THEN
                g_cto_shipset(i).configuration_exists := 'N' ;
            ELSE
                g_cto_shipset(i).configuration_exists := 'Y' ;
            END IF ;
       ELSE
            l_stmt_num :=  30 ;
            v_config_exists := CTO_WORKFLOW.config_line_exists(g_cto_shipset(i).ato_line_id) ;

            l_stmt_num :=  40 ;
            IF( v_config_exists ) THEN
                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add('populate_configuration_status: ' || 'Config item exists for this ato line id :: '||to_char(g_cto_shipset(i).ato_line_id),4);
                END IF;
                g_cto_shipset(i).configuration_exists := 'Y' ;
                t_top_model_tab(g_cto_shipset(i).ato_line_id) := 1 ;
            ELSE
                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add('populate_configuration_status: ' || 'Config item DOES NOT exist for this ato line id :: '||to_char(g_cto_shipset(i).ato_line_id),4);
                END IF;
                g_cto_shipset(i).configuration_exists := 'N' ;
                t_top_model_tab(g_cto_shipset(i).ato_line_id) := 0 ;
            END IF ;
       END IF ;
    END IF ;
   END IF;
 END LOOP ;

 END IF ;

EXCEPTION
 WHEN others THEN
   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('populate_configuration_status: ' ||  ' error encountered in populate_configuration_status at line ' || to_char(l_stmt_num ) , 1 );
   	oe_debug_pub.add('populate_configuration_status: ' ||  ' error ' || SQLCODE , 1 );
   	oe_debug_pub.add('populate_configuration_status: ' ||  ' error ' || SQLERRM , 1 );
   END IF;
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
END populate_configuration_status ;



PROCEDURE populate_visible_demand(
  p_shipset    in out NOCOPY MRP_ATP_PUB.ATP_REC_TYP
, p_success_flag in boolean
, x_return_status out     varchar2
, x_msg_count     out     number
, x_msg_data      out     varchar2
)
is
l_stmt_num   number ;

BEGIN

 IF PG_DEBUG <> 0 THEN
 	oe_debug_pub.add('populate_visible_demand: ' || 'Populating Visible demand Flag value..',4);
 END IF;
 l_stmt_num :=  1 ;

 IF( g_cto_shipset.count > 0 ) THEN

 FOR i IN g_cto_shipset.first..g_cto_shipset.last
 LOOP

 l_stmt_num :=  5 ;
 IF (g_cto_shipset.exists(i)) THEN

    l_stmt_num :=  10 ;
    IF( g_cto_shipset(i).configuration_exists = 'N' ) THEN

        l_stmt_num :=  20 ;
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('populate_visible_demand: ' || 'Location ='||to_char(g_cto_shipset(i).location),5);
        END IF;

        IF ( g_cto_shipset(i).buy_model = 'Y' ) THEN

            l_stmt_num :=  30 ;
            p_shipset.attribute_05(g_cto_shipset(i).location) := 'N' ;
            IF PG_DEBUG <> 0 THEN
            	oe_debug_pub.add('populate_visible_demand: ' || 'Visible demand flag set to Y for line_id = '||to_char(g_cto_shipset(i).line_id),4);
            END IF;

        ELSE
            l_stmt_num :=  40 ;
            p_shipset.attribute_05(g_cto_shipset(i).location) := 'Y' ;
        END IF ;

    ELSE
        /* populate visible demand flag = 'N' if configuration exists */

        l_stmt_num :=  50 ;
        p_shipset.attribute_05(g_cto_shipset(i).location) := 'N' ;
    END IF ;

 END IF;

 END LOOP ;

 END IF ;

 l_stmt_num :=  70 ;

EXCEPTION
 WHEN others THEN
   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('populate_visible_demand: ' ||  ' error encountered in Populate_visible_demand at line ' || to_char(l_stmt_num ) , 1 );
   	oe_debug_pub.add('populate_visible_demand: ' ||  ' error ' || SQLCODE , 1 );
   	oe_debug_pub.add('populate_visible_demand: ' ||  ' error ' || SQLERRM , 1 );
   END IF;
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
END populate_visible_demand;



PROCEDURE remove_elements_from_atp_rec(
 p_atp_rec in out NOCOPY MRP_ATP_PUB.ATP_REC_TYP
)
is
BEGIN
    p_atp_rec.Row_Id.delete ;
    p_atp_rec.Instance_Id.delete ;
    p_atp_rec.Inventory_Item_Id.delete ;
    p_atp_rec.Inventory_Item_Name.delete ;
    p_atp_rec.Source_Organization_Id.delete ;
    p_atp_rec.Source_Organization_Code.delete ;
    p_atp_rec.Organization_Id.delete ;
    p_atp_rec.Identifier.delete ;
    p_atp_rec.Demand_Source_Header_Id.delete ;
    p_atp_rec.Demand_Source_Delivery.delete ;
    p_atp_rec.Demand_Source_Type.delete ;
    p_atp_rec.Scenario_Id.delete ;
    p_atp_rec.Calling_Module.delete ;
    p_atp_rec.Customer_Id.delete ;
    p_atp_rec.Customer_Site_Id.delete ;
    p_atp_rec.Destination_Time_Zone.delete ;
    p_atp_rec.Quantity_Ordered.delete ;
    p_atp_rec.Quantity_UOM.delete ;
    p_atp_rec.Requested_Ship_Date.delete ;
    p_atp_rec.Requested_Arrival_Date.delete ;
    p_atp_rec.Earliest_Acceptable_Date.delete ;
    p_atp_rec.Latest_Acceptable_Date.delete ;
    p_atp_rec.Delivery_Lead_Time.delete ;
    p_atp_rec.Freight_Carrier.delete ;
    p_atp_rec.Ship_Method.delete ;
    p_atp_rec.Demand_Class.delete ;
    p_atp_rec.Ship_Set_Name.delete ;
    p_atp_rec.Arrival_Set_Name.delete ;
    p_atp_rec.Override_Flag.delete ;
    p_atp_rec.Action.delete ;
    p_atp_rec.Ship_Date.delete ;
    p_atp_rec.Available_Quantity.delete ;
    p_atp_rec.Requested_Date_Quantity.delete ;
    p_atp_rec.Group_Ship_Date.delete ;
    p_atp_rec.Group_Arrival_Date.delete ;
    p_atp_rec.Vendor_Id.delete ;
    p_atp_rec.Vendor_Name.delete ;
    p_atp_rec.Vendor_Site_Id.delete ;
    p_atp_rec.Vendor_Site_Name.delete ;
    p_atp_rec.Insert_Flag.delete ;
    p_atp_rec.OE_Flag.delete ;
    p_atp_rec.Atp_Lead_Time.delete ;
    p_atp_rec.Error_Code.delete ;
    p_atp_rec.Message.delete ;
    p_atp_rec.End_Pegging_Id.delete ;
    p_atp_rec.Order_Number.delete ;
    p_atp_rec.Old_Source_Organization_Id.delete ;
    p_atp_rec.Old_Demand_Class.delete ;
END remove_elements_from_atp_rec ;



PROCEDURE remove_elements_from_bom_rec(
 p_bom_rec in out NOCOPY MRP_ATP_PUB.ATP_BOM_REC_TYP
)
is
BEGIN
    p_bom_rec.assembly_identifier.delete ;
    p_bom_rec.assembly_item_id.delete ;
    p_bom_rec.component_identifier.delete ;
    p_bom_rec.component_item_id.delete ;
    p_bom_rec.quantity.delete ;
    p_bom_rec.fixed_lt.delete ;
    p_bom_rec.variable_lt.delete ;
    p_bom_rec.pre_process_lt.delete ;
END remove_elements_from_bom_rec ;



PROCEDURE isAutoGeneratedShipset(
  p_ship_set_name in varchar2,
  x_auto_gen out boolean,
  x_process_demand out boolean
)
is
BEGIN

  x_auto_gen := FALSE;
  x_process_demand := FALSE;

  IF( g_auto_generated_shipset.count > 0 ) THEN
  FOR i IN g_auto_generated_shipset.first..g_auto_generated_shipset.last
  LOOP

    IF(p_ship_set_name = g_auto_generated_shipset(i).set_name ) THEN
  	IF PG_DEBUG <> 0 THEN
  		oe_debug_pub.add('isAutoGeneratedShipset: ' ||  'Shipset '||p_ship_set_name|| 'is an auto-generated shipset  '  ,3 );
  	END IF;
	x_auto_gen := TRUE;
	x_process_demand := g_auto_generated_shipset(i).process_demand;
	exit;
    END IF ;

  END LOOP ;

  IF PG_DEBUG <> 0 THEN
  	oe_debug_pub.add('isAutoGeneratedShipset: ' ||  'Shipset '||p_ship_set_name|| 'is NOT an auto-generated shipset  '  ,3 );
  END IF;
  END IF ;

END isAutoGeneratedShipset;



FUNCTION get_shipset_success_index(
  p_ship_set_name in varchar2
)
return number
is
BEGIN

   FOR i IN g_shipset_status_tbl.first..g_shipset_status_tbl.last
   LOOP
      IF( p_ship_set_name = g_shipset_status_tbl(i).ship_set_name ) THEN
          return i ;
      END IF ;
   END LOOP ;

   return 0 ;
END get_shipset_success_index ;


/*
** This procedure registers errors in the g_cto_shipset structure for any components towards their Top level ATO models
** An error code of -99 is used to indicate OM not to display the lower level components
** of an Multi-level, Multi-org ATO model.
   --  Action_code 100 means Enquiry
   --  Action_code 110 means Scheduling
   --  Action_code 120 means Rescheduling
*/
PROCEDURE register_error(
  p_ship_set_name       in varchar2
, p_line_id       in number
, p_error_code    in number
, p_action        in number
, p_status        in boolean
, x_return_status out varchar2
)
is
v_start_loc  number ;
v_ato_line_id number ;
v_pto_line_id number ;
v_atp_group_error_code number := -99 ;
v_sched_group_error_code number := 19 ;
v_mask_error_code number := -100 ;
v_error_code_registered boolean ;
BEGIN

  IF( g_cto_shipset.count > 0 ) THEN
   FOR i IN g_cto_shipset.first..g_cto_shipset.last
   LOOP

      IF( g_cto_shipset(i).line_id = p_line_id ) THEN

          IF PG_DEBUG <> 0 THEN
          	oe_debug_pub.add('register_error: ' ||  ' line id ' || p_line_id || ' found in g_cto_shipset ' , 5 );
          END IF;

          v_ato_line_id := g_cto_shipset(i).ato_line_id ;
          v_pto_line_id := g_cto_shipset(i).top_model_line_id ;

          /*
          ** register error for ato line id
          */
          FOR j IN g_cto_shipset.first..g_cto_shipset.last
          LOOP
             IF( g_cto_shipset(j).line_id = v_ato_line_id ) THEN
                 g_cto_shipset(j).error_code := p_error_code ;

                 IF PG_DEBUG <> 0 THEN
                 	oe_debug_pub.add('register_error: ' ||  'Registered ato error ' || to_char( p_error_code )|| 'for line_id' || g_cto_shipset(j).line_id  , 2 );
                 END IF;
             ELSIF( g_cto_shipset(j).ato_line_id = v_ato_line_id ) THEN

                    /* Changes made for scheduling errors due to bug 2428252 */

                    IF( nvl(p_action , 100) <> 100 and p_status = false ) THEN
                       g_cto_shipset(j).error_code :=  v_sched_group_error_code  ;

                       IF PG_DEBUG <> 0 THEN
                       	oe_debug_pub.add('register_error: ' ||  'Registered group error ' || v_sched_group_error_code , 2 );
                       END IF;
                    ELSE
                       g_cto_shipset(j).error_code :=  v_atp_group_error_code  ;

                       IF PG_DEBUG <> 0 THEN
                       	oe_debug_pub.add('register_error: ' ||  'Registered group error ' || v_atp_group_error_code , 2 );
                       END IF;

                    END IF;
             END IF;
          END LOOP ;

          v_error_code_registered := true ;
          exit ;

      END IF ;

   END LOOP ;
   ELSE

     IF PG_DEBUG <> 0 THEN
     	oe_debug_pub.add('register_error: ' ||  'Register_error did not record anything ' , 2 );
     END IF;
   END IF ;

END register_error ;


/*
** This procedure actually populates the errors registered in the g_cto_shipset structure to the actual shipset.
*/
PROCEDURE populate_error(
  p_shipset   in out NOCOPY MRP_ATP_PUB.ATP_REC_TYP
, x_return_status out varchar2
)
is
v_start_loc  number ;
v_ato_line_id number ;
BEGIN

   IF( g_cto_shipset.count > 0 ) THEN
   FOR i IN g_cto_shipset.first..g_cto_shipset.last
   LOOP

      IF( g_cto_shipset(i).error_code is not null ) THEN

          IF PG_DEBUG <> 0 THEN
          	oe_debug_pub.add('populate_error: ' ||  'Populating error code ' || g_cto_shipset(i).error_code || ' at '  || i || ' for line id ' || g_cto_shipset(i).line_id || ' at location '  || g_cto_shipset(i).location , 2 );
          END IF;

          p_shipset.error_code(g_cto_shipset(i).location) := g_cto_shipset(i).error_code ;
      END IF;

   END LOOP ;
   ELSE
    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add('populate_error: ' ||  'No errors to populate as g_cto_shipset count is ' || g_cto_shipset.count, 1 );
    END IF;

   END IF ;


END populate_error;


PROCEDURE save_shipset(
  p_shipset in MRP_ATP_PUB.ATP_REC_TYP
, x_return_status out     varchar2
)
is
BEGIN
   FOR i IN p_shipset.identifier.first..p_shipset.identifier.last
   LOOP
      IF( p_shipset.identifier.exists(i) ) THEN
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('save_shipset: ' ||  ' +++++ident ' || p_shipset.identifier(i) || ' is part of reduced shipset ' , 2 );
        END IF;
        MRP_ATP_PVT.assign_atp_input_rec(p_shipset,
                                         i,
                                         g_final_shipset,
                                         x_return_status );
       END IF;
   END LOOP ;
END save_shipset ;


PROCEDURE show_contents( p_shipset_tracker CTO_SHIPSET_TBL_TYPE )
is
BEGIN

   IF( p_shipset_tracker.count > 0 ) THEN
   oe_debug_pub.add('show_contents: ' ||'Show contents of shipset:', 2);
   FOR i IN p_shipset_tracker.first..p_shipset_tracker.last
   LOOP
      IF( p_shipset_tracker.exists(i) ) THEN
      IF PG_DEBUG <> 0 THEN
      	oe_debug_pub.add('**i:'||to_char(i), 2);
	oe_debug_pub.add('+++header_id:: ' || p_shipset_tracker(i).header_id, 2);
        oe_debug_pub.add('+++line_id::  ' || p_shipset_tracker(i).line_id , 2);
        oe_debug_pub.add('+++plan_level::  ' || p_shipset_tracker(i).plan_level, 2);
        oe_debug_pub.add('+++ato_line_id::  ' || p_shipset_tracker(i).ato_line_id, 2);
        oe_debug_pub.add('+++parent_ato_line_id::  ' || p_shipset_tracker(i).parent_ato_line_id , 2);
        oe_debug_pub.add('+++top_model_line_id::  ' || p_shipset_tracker(i).top_model_line_id , 2);
        oe_debug_pub.add('+++link_to_line_id::  ' || p_shipset_tracker(i).link_to_line_id  , 2);
        oe_debug_pub.add('+++srcorg::  ' || p_shipset_tracker(i).sourcing_org , 2);
        oe_debug_pub.add('+++wip_supply_type::  ' || p_shipset_tracker(i).wip_supply_type , 2);
        oe_debug_pub.add('+++ordered_qty::  ' || p_shipset_tracker(i).ordered_quantity  , 2);
        oe_debug_pub.add('+++ss_name::  ' || p_shipset_tracker(i).ship_set_name  , 2);
        oe_debug_pub.add('+++Buy Flag:: '||p_shipset_tracker(i).buy_model  , 2);
        oe_debug_pub.add('+++location::  '||p_shipset_tracker(i).location , 2);
        oe_debug_pub.add('+++atp_flag::  '||p_shipset_tracker(i).atp_flag , 2);
        oe_debug_pub.add('+++atp_components_flag::  '||p_shipset_tracker(i).atp_components_flag , 2);
        oe_debug_pub.add('+++stored_atp_flag::  '||p_shipset_tracker(i).stored_atp_flag , 2);
      END IF;
      IF( p_shipset_tracker(i).auto_generated ) THEN
                    IF PG_DEBUG <> 0 THEN
                    	oe_debug_pub.add('+++auto_generated::TRUE' , 1 );
                    END IF;
                ELSE
                    IF PG_DEBUG <> 0 THEN
                    	oe_debug_pub.add('+++auto_generated::FALSE' , 1 );
                    END IF;
                END IF ;
		IF( p_shipset_tracker(i).process_demand ) THEN
                    IF PG_DEBUG <> 0 THEN
                    	oe_debug_pub.add('+++process_demand::TRUE' , 1 );
                    END IF;
                ELSE
                    IF PG_DEBUG <> 0 THEN
                    	oe_debug_pub.add('+++process_demand::FALSE' , 1 );
                    END IF;
                END IF ;
		IF( p_shipset_tracker(i).sourced_components ) THEN
                    IF PG_DEBUG <> 0 THEN
                    	oe_debug_pub.add('+++sourced_components::TRUE' , 1 );
                    END IF;
                ELSE
                    IF PG_DEBUG <> 0 THEN
                    	oe_debug_pub.add('+++sourced_components::FALSE' , 1 );
                    END IF;
                END IF ;
      END IF ;
   END LOOP ;
   ELSE
    	IF PG_DEBUG <> 0 THEN
    		oe_debug_pub.add ('show_contents: ' ||  ' shipset tracker contents ' || p_shipset_tracker.count , 2 );
    	END IF;
   END IF ;

   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('show_contents: ' ||  ' Show contents of g_shipset_status_tbl ', 2 );
   END IF;
   IF( g_shipset_status_tbl.count > 0 ) THEN
   for i in g_shipset_status_tbl.first..g_shipset_status_tbl.last
   LOOP
      IF PG_DEBUG <> 0 THEN
      	oe_debug_pub.add('+++i:: '||to_char(i) ||  'ss_name ' || g_shipset_status_tbl(i).ship_set_name , 2 );
      END IF;
   END LOOP ;
   END IF ;

END show_contents;


PROCEDURE default_ship_set_name( p_shipset in out NOCOPY MRP_ATP_PUB.ATP_REC_TYP )
is
BEGIN
    IF( p_shipset.identIFier.count > 0 ) THEN
     FOR i IN p_shipset.identifier.first..p_shipset.identifier.last
     LOOP
          IF( p_shipset.ship_set_name(i) is null ) THEN
              p_shipset.ship_set_name(i) := 'CTODEFAULT' ;
          END IF ;
     END LOOP ;
    ELSE
   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('default_ship_set_name: ' ||  ' identIFier column of shipset is of count ' || p_shipset.identifier.count , 4);
   END IF;

  END IF ;

END default_ship_set_name ;


PROCEDURE print_shipset(
   p_shipset IN MRP_ATP_PUB.ATP_REC_TYP
 )
 is
 BEGIN

    IF PG_DEBUG <> 0 THEN
       	oe_debug_pub.add('***print_shipset: ' ||  'Going to print shipset:: ' , 2);

    END IF;

    IF( p_shipset.ship_set_name.count > 0 )
    THEN

       FOR j IN p_shipset.ship_set_name.first..p_shipset.ship_set_name.last
       LOOP

          IF( p_shipset.ship_set_name.exists(j) ) THEN
              IF PG_DEBUG <> 0 THEN
              	oe_debug_pub.add('**Shipset Name ' || p_shipset.ship_set_name(j), 2 );
              END IF;
          END IF ;

          IF( p_shipset.inventory_item_id.exists(j) ) THEN
              IF PG_DEBUG <> 0 THEN
              	oe_debug_pub.add('+++Inventory_Item_Id:: ' || p_shipset.inventory_item_id(j) , 2 );
                oe_debug_pub.add('+++Source_Organization_Id:: ' || p_shipset.source_organization_id(j) , 2 );
                oe_debug_pub.add('+++Identifier:: ' || p_shipset.identifier(j), 2 );
              END IF;
              IF( p_shipset.error_code.count > 0 ) THEN
                  IF( p_shipset.error_code.exists(j) ) THEN
                      IF PG_DEBUG <> 0 THEN
                      	oe_debug_pub.add('+++Error Code:: ' || p_shipset.error_code(j) , 2 );
                      END IF;
                  END IF ;
              END IF ;
              IF( p_shipset.group_ship_date.count > 0 ) THEN
                  IF( p_shipset.group_ship_date.exists(j) ) THEN
                      IF PG_DEBUG <> 0 THEN
                      	oe_debug_pub.add('+++Group Ship Date:: ' || p_shipset.group_ship_date(j)  , 2 );
                      END IF;
                  END IF ;
              END IF ;
              IF( p_shipset.ship_date.count > 0 ) THEN
                  IF( p_shipset.ship_date.exists(j) ) THEN
                      IF PG_DEBUG <> 0 THEN
                      	oe_debug_pub.add('+++Ship Date:: ' || p_shipset.ship_date(j)  , 2 );
                      END IF;
                  END IF ;
              END IF ;
              IF( p_shipset.group_arrival_date.count > 0 ) THEN
                  IF( p_shipset.group_arrival_date.exists(j) ) THEN
                      IF PG_DEBUG <> 0 THEN
                      	oe_debug_pub.add('+++Group Arrival Date:: ' || p_shipset.group_arrival_date(j)  , 2 );
                      END IF;
                  END IF ;
              END IF ;
              IF( p_shipset.attribute_05.count > 0 ) THEN
                  IF( p_shipset.attribute_05.exists(j) ) THEN
                      IF PG_DEBUG <> 0 THEN
                      	oe_debug_pub.add('+++Attribute_05:: ' || p_shipset.attribute_05(j)  , 2 );
                      END IF;
                  END IF ;
              END IF ;
	      IF( p_shipset.attribute_06.count > 0 ) THEN
                  IF( p_shipset.attribute_06.exists(j) ) THEN
                      IF PG_DEBUG <> 0 THEN
                      	oe_debug_pub.add('+++Attribute_06:: ' || p_shipset.attribute_06(j)  , 2 );
                      END IF;
                  END IF ;
              END IF ;
              IF( p_shipset.ato_delete_flag.count > 0 ) then
                  if( p_shipset.ato_delete_flag.exists(j) ) then
			IF PG_DEBUG <> 0 THEN
                      	  oe_debug_pub.add( '+++Ato delete flag:: ' || p_shipset.ato_delete_flag(j)  , 2 ) ;
			END IF;
                  END IF;
              END IF;
              IF( p_shipset.action.count > 0 ) then
                  if( p_shipset.action.exists(j) ) then
			IF PG_DEBUG <> 0 THEN
                      	  oe_debug_pub.add( '+++Action:: ' || p_shipset.action(j)  , 2 ) ;
			END IF;
                  END IF;
              END IF;
          END IF ;
      END LOOP ;

   ELSE
       IF PG_DEBUG <> 0 THEN
       	oe_debug_pub.add('print_shipset: ' ||  'Ship set name table of shipset record is ' || p_shipset.ship_set_name.count , 2 );
       END IF;
   END IF ;

   IF PG_DEBUG <> 0 THEN
       	oe_debug_pub.add('***print_shipset: ' ||  'Done printing shipset ' , 2 );
   END IF;

END print_shipset ;


PROCEDURE print_shipset_capacity( p_shipset IN MRP_ATP_PUB.ATP_REC_TYP )
is
BEGIN

    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add('***print_shipset_capacity: ' ||  'Going to print shipset capacity ' , 5 );
    END IF;

    IF( p_shipset.ship_set_name.count > 0 ) THEN
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('print_shipset_capacity: ' || ' record count   ...'||to_char(p_shipset.ship_set_name.count),5);

               	oe_debug_pub.add('print_shipset_capacity: ' ||  ' Row_Id ' || p_shipset.row_id.count  ||
                      ' Instance_Id ' || p_shipset.instance_id.count ||
                      ' Inventory_Item_Id ' || p_shipset.inventory_item_id.count ||
                      ' Inventory_Item_Name ' || p_shipset.inventory_item_name.count ||
                      ' Source_Organization_Id ' || p_shipset.source_organization_id.count ||
                      ' Source_Organization_Code ' || p_shipset.source_organization_code.count , 5);

                	oe_debug_pub.add('print_shipset_capacity: ' ||  ' Organization_Id ' || p_shipset.organization_id.count ||
                      ' Identifier ' || p_shipset.identifier.count ||
                      ' Demand_Source_Header_Id ' || p_shipset.demand_source_header_id.count ||
                      ' Demand_Source_Delivery ' || p_shipset.demand_source_delivery.count  ||
                      ' Demand_Source_Type ' || p_shipset.demand_source_type.count ||
                      ' Scenario_Id ' || p_shipset.scenario_id.count , 5 );

               	oe_debug_pub.add('print_shipset_capacity: ' ||   ' Calling_Module ' || p_shipset.calling_module.count ||
                      ' Customer_Id ' || p_shipset.customer_id.count ||
                      ' Customer_Site_Id ' || p_shipset.customer_site_id.count ||
                      ' Destination_Time_Zone ' || p_shipset.destination_time_zone.count ||
                      ' Quantity_Ordered ' || p_shipset.quantity_ordered.count ||
                      ' Quantity_UOM ' || p_shipset.quantity_uom.count , 5 );

               	oe_debug_pub.add('print_shipset_capacity: ' ||   ' Requested_Ship_Date ' || p_shipset.requested_ship_date.count ||
                      ' Requested_Arrival_Date ' || p_shipset.requested_arrival_date.count ||
                      ' Earliest_Acceptable_Date ' || p_shipset.earliest_acceptable_date.count ||
                      ' Latest_Acceptable_Date ' || p_shipset.latest_acceptable_date.count ||
                      ' Delivery_Lead_Time ' || p_shipset.delivery_lead_time.count ||
                      ' Freight_Carrier ' || p_shipset.freight_carrier.count  , 5 );

               	oe_debug_pub.add('print_shipset_capacity: ' ||   ' Ship_Method ' || p_shipset.ship_method.count ||
                      ' Demand_Class ' || p_shipset.demand_class.count ||
                      ' Ship_Set_Name ' || p_shipset.ship_set_name.count ||
                      ' Arrival_Set_Name ' || p_shipset.arrival_set_name.count ||
                      ' Override_Flag ' || p_shipset.override_flag.count ||
                      ' Action ' || p_shipset.action.count  , 5 );

               	oe_debug_pub.add('print_shipset_capacity: ' ||   ' Ship_Date ' || p_shipset.ship_date.count ||
                      ' Available_Quantity ' || p_shipset.available_quantity.count ||
                      ' Requested_Date_Quantity ' || p_shipset.requested_date_quantity.count ||
                      ' Group_Ship_Date ' || p_shipset.group_ship_date.count ||
                      ' Group_Arrival_Date ' || p_shipset.group_arrival_date.count ||
                      ' Vendor_Id ' || p_shipset.vendor_id.count  , 5 );

               	oe_debug_pub.add('print_shipset_capacity: ' ||   ' Vendor_Name ' || p_shipset.vendor_name.count ||
                      ' Vendor_Site_Id ' || p_shipset.vendor_site_id.count ||
                      ' Vendor_Site_Name ' || p_shipset.vendor_site_name.count ||
                      ' Insert_Flag ' || p_shipset.insert_flag.count ||
                      ' OE_Flag ' || p_shipset.oe_flag.count ||
                      ' Atp_Lead_Time ' || p_shipset.atp_lead_time.count  , 5 );
               	oe_debug_pub.add('print_shipset_capacity: ' ||   ' Error_Code ' || p_shipset.error_code.count ||
                      ' Message ' || p_shipset.message.count ||
                      ' End_Pegging_Id ' || p_shipset.end_pegging_id.count ||
                      ' Order_Number ' || p_shipset.order_number.count ||
                      ' Old_Source_Organization_Id ' || p_shipset.old_source_organization_id.count ||
		      ' ATO DELETE FLAG ' || p_shipset.ato_delete_flag.count ||
                      ' Old_Demand_Class ' || p_shipset.old_demand_class.count  , 5  );
               END IF;

     ELSE
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('print_shipset_capacity: ' ||  ' ship set name table of shipset record is ' || p_shipset.ship_set_name.count  , 5 );
        END IF;
     END IF ;

     IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add('***print_shipset_capacity: ' ||  ' done printing shipset capacity ' , 5 );
     END IF;

END print_shipset_capacity ;




/*-------------------------------------------------------------------
  Name        : Create_ATP_BOM
  Description : This procedure creates a temporary BOM structure for all
		ATO models in an ATP request ship-set
  Requires    : Global memory structure G_CTO_SPARSE_SHIPSET
  Returns     :
-----------------------------------------------------------------------*/
PROCEDURE Create_Atp_Bom (
	p_atp_bom	in out	NOCOPY MRP_ATP_PUB.atp_bom_rec_typ,
        x_Return_Status	out    	varchar2 ,
        x_Msg_Data    	out    	varchar2 ,
        x_Msg_Count   	out    	number )
IS

	l_index		NUMBER;
	l_parent_id	NUMBER;
	l_link_id	NUMBER;
	l_fixed_lt	NUMBER;
	l_variable_lt	NUMBER;
	l_preproc_lt	NUMBER;
	l_eff_date	DATE;
	l_disable_date	DATE;
	l_atp_flag	VARCHAR2(1);
	l_atp_comps_flag	VARCHAR2(1);
	l_buy_flag	VARCHAR2(1);
	i		NUMBER := 0;
	lStmtNum	NUMBER;

        l_bom_item_type mtl_system_items.bom_item_type%type ;

BEGIN
	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('create_atp_bom: ' || 'Begin BOM creation', 2);

		oe_debug_pub.add('create_atp_bom: ' || 'G_Cto_Sparse_Shipset.COUNT :: '||to_char(G_Cto_Sparse_Shipset.COUNT), 2);
	END IF;
	lStmtNum := 10;
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('create_atp_bom: ' || 'Getting eff and dis date for optional comps', 4);
	END IF;
	lStmtNum := 20;
	--
	-- Optional comps are made effective from today to calendar_end_date
	--

        -- Modified by Renga Kannan on 10/30/02
        -- The blind query on bom_calendar is modified with proper join
        -- The global variable used here G_OE_VALIDATION_ORG is set in the
        -- populate_om_shipset and populate_cz_shipset part of code
        -- We will get the calender dates based on the calendar code parameter
        -- set in the Oe validation org.

	select min(calendar_date), max(calendar_date)
	into l_eff_date, l_disable_date
	from bom_calendar_dates cal,
             mtl_parameters mp
        where mp.organization_id = CTO_ATP_INTERFACE_PK.G_OE_VALIDATION_ORG
        and   mp.calendar_code   = cal.calendar_code
        and   mp.calendar_exception_set_id = cal.exception_set_id;


	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('create_atp_bom: ' || 'l_eff_date :: '||to_char(l_eff_date), 4);

		oe_debug_pub.add('create_atp_bom: ' || 'l_disable_date :: '||to_char(l_disable_date), 4);
	END IF;

	IF G_Cto_Sparse_Shipset.COUNT > 0 THEN
		--
		-- LOOP through all items in g_cto_sparse_shipset
		-- Populate each item and its parent
		--
		l_index := G_Cto_Sparse_Shipset.FIRST;
		LOOP
		--
		-- Insert all items into BOM structure except top level ATO models
		--
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('create_atp_bom: ' || 'Processing line_id '||to_char(l_index), 2);
		END IF;
		lStmtNum := 30;
		IF (g_cto_sparse_shipset.EXISTS(l_index)) THEN
		 IF (g_cto_sparse_shipset(l_index).mlmo_flag = 'Y') THEN	--2723674
		  l_parent_id := g_cto_sparse_shipset(l_index).Parent_Ato_Line_Id;
		  l_link_id := g_cto_sparse_shipset(l_index).Link_To_Line_Id;
		  l_buy_flag := g_cto_sparse_shipset(l_index).Buy_Model;
		  IF PG_DEBUG <> 0 THEN
		  	oe_debug_pub.add('**create_atp_bom: ' || 'l_parent_id is '||to_char(l_parent_id), 4);

		  	oe_debug_pub.add('**create_atp_bom: ' || 'l_link_id is '||to_char(l_link_id), 4);

		  	oe_debug_pub.add('**create_atp_bom: ' || 'l_buy_flag is '||l_buy_flag, 4);
		  END IF;

		  /* 'Make' components and top 'Buy' model */
		  IF ((g_cto_sparse_shipset(l_index).Ato_Line_Id <> g_cto_sparse_shipset(l_index).Line_Id) AND (nvl(l_buy_flag, 'N') <> 'Y')) THEN

			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('**create_atp_bom: ' || 'Not top ato model and not buy item, so insert into BOM', 2);
			END IF;
			i := p_atp_bom.assembly_identifier.count+1;
			lStmtNum := 40;
			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('**create_atp_bom: ' || 'Insert record # '||to_char(i), 2);
			END IF;
			Extend_Atp_Bom(p_atp_bom,
					x_Return_Status,
					x_Msg_Count,
					x_Msg_Data);
			IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
				IF PG_DEBUG <> 0 THEN
					oe_debug_pub.add('**create_atp_bom: ' || 'Unexp error in Extend_ATP_BOM::'||sqlerrm,1);
				END IF;
				raise FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('**create_atp_bom: ' || 'After extend_atp', 5);
			END IF;

			lStmtNum := 50;
			/*Populate this item's information*/
			p_atp_bom.Component_Item_Id(i) := g_cto_sparse_shipset(l_index).Inventory_Item_Id;
			p_atp_bom.Component_Identifier(i) := g_cto_sparse_shipset(l_index).Line_Id;
			p_atp_bom.Quantity(i) := g_cto_sparse_shipset(l_index).Ordered_Quantity;
			p_atp_bom.SMC_Flag(i) := 'N';

                        /* Sushant made changes for bug 2396739 */
			p_atp_bom.source_organization_id(i) := g_cto_sparse_shipset(l_parent_id).sourcing_org;

			lStmtNum := 60;
			/*Populate parent model's information*/
			p_atp_bom.Assembly_Item_Id(i) := g_cto_sparse_shipset(l_parent_id).Inventory_Item_Id;
			p_atp_bom.Assembly_Identifier(i) := g_cto_sparse_shipset(l_parent_id).Line_Id;

			lStmtNum := 70;
			/*Populate the parent model's lead time on the item.
			We will pass fixed, variable and pre-processing lead
			times in the BOM and ATP will do the calculations*/
			select nvl(fixed_lead_time, 0), nvl(variable_lead_time, 0), nvl(preprocessing_lead_time, 0)
			into l_fixed_lt, l_variable_lt, l_preproc_lt
			from mtl_system_items
			where inventory_item_id = g_cto_sparse_shipset(l_parent_id).Inventory_Item_Id
			and organization_id = g_cto_sparse_shipset(l_parent_id).Sourcing_Org;
			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('**create_atp_bom: ' || 'After getting LT', 5);
			END IF;
			p_atp_bom.Fixed_LT(i) := l_fixed_lt;
			p_atp_bom.Variable_LT(i) := l_variable_lt;
			p_atp_bom.Pre_Process_LT(i) := l_preproc_lt;

			lStmtNum := 75;
			/*Populate atp_flag for each component and send to ATP (bug 2462661)*/
			select atp_flag, atp_components_flag, bom_item_type
			into l_atp_flag, l_atp_comps_flag, l_bom_item_type
			from mtl_system_items
			where inventory_item_id = g_cto_sparse_shipset(l_index).Inventory_Item_Id
			and organization_id = g_cto_sparse_shipset(l_index).Sourcing_Org;
			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('**create_atp_bom: ' || 'After getting atp flags', 5);
			END IF;
                        /* Sushant added this on 01-14-2003 for atp issues of option classes */

			IF (l_atp_flag <> 'N' OR l_atp_comps_flag <> 'N' ) THEN
				p_atp_bom.atp_flag(i) := 'Y';
			ELSE
				p_atp_bom.atp_flag(i) := 'N';
			END IF;

			lStmtNum := 80;
			/*Populate this item's effectivity and disable dates
			These dates will be used by ATP engine to check the
			effectivity of the item. For optional components, we
			pass the calendar_start_date and calendar_end_date
			(always effective within planning horizon)*/

			p_atp_bom.Effective_Date(i) := l_eff_date;
			p_atp_bom.Disable_Date(i) := l_disable_date;

			/*Populate the ATP flag on the BOM for this item
			 Here, the same item can be included more than once
			 on the BOM (with a different op. seq.). Since there
			 is no way of selecting the correct component, we
			 are joining with rownum = 1*/

			lStmtNum := 85;
			select bic.check_atp
                             , bic.wip_supply_type
			into p_atp_bom.atp_check(i)
                           , p_atp_bom.wip_supply_type(i)
			from bom_bill_of_materials bbom,
				bom_inventory_components bic
			where bbom.assembly_item_id = g_cto_sparse_shipset(l_link_id).Inventory_Item_Id
			and bbom.organization_id = g_cto_sparse_shipset(l_link_id).Sourcing_Org
			and bbom.alternate_bom_designator is NULL
			and bbom.common_bill_sequence_id = bic.bill_sequence_id
			and bic.component_item_id = g_cto_sparse_shipset(l_index).Inventory_Item_Id
			and rownum = 1;

		  /* Top ato model is buy model, create dummy BOM */
		  ELSIF ((g_cto_sparse_shipset(l_index).Ato_Line_Id = g_cto_sparse_shipset(l_index).Line_Id) AND (nvl(l_buy_flag, 'N') = 'B')) THEN

			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('**create_atp_bom: ' || 'Top ato model is buy model, so insert dummy row in BOM', 2);
			END IF;
			i := p_atp_bom.assembly_identifier.count+1;
			lStmtNum := 86;
			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('**create_atp_bom: ' || 'Insert record# '||to_char(i), 2);
			END IF;
			Extend_Atp_Bom(p_atp_bom,
					x_Return_Status,
					x_Msg_Count,
					x_Msg_Data);
			IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
				IF PG_DEBUG <> 0 THEN
					oe_debug_pub.add('**create_atp_bom: ' || 'Unexp error in Extend_ATP_BOM::'||sqlerrm,1);
				END IF;
				raise FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('**create_atp_bom: ' || 'After extend_atp', 5);
			END IF;

			lStmtNum := 87;
			/*Populate dummy information. ATP will not use this
			information. It will only use it to identify that
			there is atleast one row in the BOM. Populating
			component information for the top buy model, not
			populating parent or any other information*/

                        p_atp_bom.Assembly_Identifier(i) := g_cto_sparse_shipset(l_index).Line_Id;
                        p_atp_bom.Assembly_Item_Id(i)    := g_cto_sparse_shipset(l_index).Inventory_Item_Id;
			p_atp_bom.Component_Item_Id(i) := g_cto_sparse_shipset(l_index).Inventory_Item_Id;
			p_atp_bom.Component_Identifier(i) := g_cto_sparse_shipset(l_index).Line_Id;
			p_atp_bom.Quantity(i) := g_cto_sparse_shipset(l_index).Ordered_Quantity;
		  END IF; /* Top level ato model*/

  		  lStmtNum := 90;
		  /*If this item is a 'Make' model or OC, get
		  its sourcing information and populate
		  mandatory components from that org*/
		  IF ((g_cto_sparse_shipset(l_index).Bom_Item_Type IN (1,2)) AND (nvl(l_buy_flag, 'N') = 'N')) THEN
			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('**create_atp_bom: ' || 'Item is Make model or OC, get mand comps', 2);
			END IF;
			lStmtNum := 100;
			Populate_Mandatory_Components(p_atp_bom,
					l_index,
					x_Return_Status,
					x_Msg_Count,
					x_Msg_Data);
			IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
				IF PG_DEBUG <> 0 THEN
					oe_debug_pub.add('**create_atp_bom: ' || 'Unexp error in Populate_Mandatory_Components::'||sqlerrm,1);
				END IF;
				raise FND_API.G_EXC_UNEXPECTED_ERROR;
			ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
				IF PG_DEBUG <> 0 THEN
					oe_debug_pub.add('**create_atp_bom: ' || 'Exp error in Populate_Mandatory_Components::'||sqlerrm,1);
				END IF;
				raise FND_API.G_EXC_ERROR;
			END IF;
			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('**create_atp_bom: ' || 'After Populate_Mandatory_Components', 5);
			END IF;
	 	  END IF; /* 'Make' model or OC */
		 END IF;	--2723674
		  EXIT WHEN l_index = G_Cto_Sparse_Shipset.LAST;
		  lStmtNum := 110;
		END IF;
		l_index := G_Cto_Sparse_Shipset.NEXT(l_index);
		END LOOP; /* loop for all items in ship-set */
		--
		-- writing BOM to debug file
		--
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('create_atp_bom: ' || 'BOM STRUCTURE::', 2);
		END IF;
		FOR i IN p_atp_bom.assembly_identifier.first..p_atp_bom.assembly_identifier.last
		LOOP
		lStmtNum := 120;
			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('create_atp_bom: ' || to_char(p_atp_bom.Assembly_Identifier(i))||'  '||
					to_char(p_atp_bom.Assembly_Item_Id(i))||'  '||
					to_char(p_atp_bom.Component_Identifier(i))||'  '||
					to_char(p_atp_bom.Component_Item_Id(i))||'  '||
					to_char(p_atp_bom.Quantity(i))||'  '||
					to_char(p_atp_bom.Fixed_LT(i))||'  '||
					to_char(p_atp_bom.Variable_LT(i))||'  '||
					to_char(p_atp_bom.Pre_Process_LT(i))||'  '||
					to_char(p_atp_bom.Effective_Date(i))||'  '||
					to_char(p_atp_bom.Disable_Date(i))||'  '||
					to_char(p_atp_bom.atp_check(i)) ||'  '||
					to_char(p_atp_bom.source_organization_id(i)) ||'  '||
					p_atp_bom.SMC_Flag(i), 2);
			END IF;
		END LOOP; /* writing debug msg */

	END IF; /* G_Cto_Sparse_Shipset.COUNT > 0 */

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('create_atp_bom: ' || 'Create_Atp_Bom::exp error::'||to_char(lStmtNum)||'::'||sqlerrm,1);
		END IF;
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get
        		(p_count => x_msg_count
        		,p_data  => x_msg_data
        		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('create_atp_bom: ' || 'Create_Atp_Bom::unexp error::'||to_char(lStmtNum)||'::'||sqlerrm,1);
		END IF;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
        		(p_count => x_msg_count
        		,p_data  => x_msg_data
        		);
	WHEN OTHERS THEN
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('create_atp_bom: ' || 'Create_Atp_Bom::others::'||to_char(lStmtNum)||'::'||sqlerrm,1);
		END IF;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            		FND_MSG_PUB.Add_Exc_Msg
            			(G_PKG_NAME
            			,'Create_Atp_Bom'
            			);
        	END IF;
        	FND_MSG_PUB.Count_And_Get
        		(p_count => x_msg_count
        		,p_data  => x_msg_data
        		);

END Create_Atp_Bom;



PROCEDURE Extend_Atp_Bom (
	p_atp_bom	IN OUT NOCOPY MRP_ATP_PUB.atp_bom_rec_typ,
	x_return_status  out varchar2,
        x_msg_data       out varchar2,
        x_msg_count      out number)
IS

BEGIN

    --
    -- Current number of elements in BOM is 12
    -- This procedure needs to be updated each time a new element is
    -- added to the BOM
    --
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    p_atp_bom.Assembly_Identifier.EXTEND;
    p_atp_bom.Assembly_Item_Id.EXTEND;
    p_atp_bom.Component_Identifier.EXTEND;
    p_atp_bom.Component_Item_Id.EXTEND;
    p_atp_bom.Quantity.EXTEND;
    p_atp_bom.Fixed_LT.EXTEND;
    p_atp_bom.Variable_LT.Extend;
    p_atp_bom.Pre_Process_LT.Extend;
    p_atp_bom.Effective_Date.Extend;
    p_atp_bom.Disable_Date.Extend;
    p_atp_bom.atp_check.Extend;
    p_atp_bom.wip_supply_type.Extend;
    p_atp_bom.SMC_Flag.Extend;
    p_atp_bom.source_organization_id.Extend;
    p_atp_bom.atp_flag.Extend;

EXCEPTION
	WHEN OTHERS THEN
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('Extend_Atp_Bom: ' || 'Extend_Atp_Bom::others::'||sqlerrm,1);
		END IF;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            		FND_MSG_PUB.Add_Exc_Msg
            			(G_PKG_NAME
            			,'Extend_Atp_Bom'
            			);
        	END IF;
        	FND_MSG_PUB.Count_And_Get
        		(p_count => x_msg_count
        		,p_data  => x_msg_data
        		);
END Extend_Atp_Bom;



PROCEDURE Assign_Atp_Bom_Rec (
	p_src_atp_bom	IN OUT NOCOPY MRP_ATP_PUB.atp_bom_rec_typ,
        p_src_location  in     number ,
        p_des_atp_bom   IN OUT MRP_ATP_PUB.atp_bom_rec_typ ,
	x_return_status  out varchar2 ,
        x_msg_data       out varchar2 ,
        x_msg_count      out number )
is
v_des_location  number ;
BEGIN

    --
    -- Current number of elements in BOM is 12
    -- This procedure needs to be updated each time a new element is
    -- added to the BOM
    --
    extend_atp_bom( p_des_atp_bom , x_return_status, x_msg_data, x_msg_count ) ;
    v_des_location := p_des_atp_bom.assembly_identifier.count ;
    p_des_atp_bom.assembly_identifier(v_des_location) := p_src_atp_bom.Assembly_Identifier(p_src_location ) ;
    p_des_atp_bom.assembly_item_id(v_des_location) := p_src_atp_bom.Assembly_Item_Id(p_src_location ) ;
    p_des_atp_bom.component_identifier(v_des_location) := p_src_atp_bom.Component_Identifier(p_src_location ) ;
    p_des_atp_bom.component_item_id(v_des_location) := p_src_atp_bom.Component_Item_Id(p_src_location) ;
    p_des_atp_bom.quantity(v_des_location) := p_src_atp_bom.Quantity(p_src_location) ;
    p_des_atp_bom.fixed_lt(v_des_location) := p_src_atp_bom.Fixed_LT(p_src_location) ;
    p_des_atp_bom.variable_lt(v_des_location) := p_src_atp_bom.Variable_LT(p_src_location) ;
    p_des_atp_bom.pre_process_lt(v_des_location) := p_src_atp_bom.Pre_Process_LT(p_src_location) ;
    p_des_atp_bom.effective_date(v_des_location) := p_src_atp_bom.Effective_Date(p_src_location) ;
    p_des_atp_bom.disable_date(v_des_location) := p_src_atp_bom.Disable_Date(p_src_location) ;
    p_des_atp_bom.wip_supply_type(v_des_location) := p_src_atp_bom.wip_supply_type(p_src_location) ;
    p_des_atp_bom.atp_check(v_des_location) := p_src_atp_bom.atp_check(p_src_location) ;
    p_des_atp_bom.smc_flag(v_des_location) := p_src_atp_bom.smc_flag(p_src_location) ;
    p_des_atp_bom.source_organization_id(v_des_location) := p_src_atp_bom.source_organization_id(p_src_location) ;
    p_des_atp_bom.atp_flag(v_des_location) := p_src_atp_bom.atp_flag(p_src_location) ;

END assign_atp_bom_rec ;



PROCEDURE Populate_Mandatory_Components(p_atp_bom 	IN OUT NOCOPY MRP_ATP_PUB.atp_bom_rec_typ,
					p_index		IN NUMBER,
					x_Return_Status OUT VARCHAR2,
					x_Msg_Count	OUT NUMBER,
					x_Msg_Data	OUT VARCHAR2)
IS

CURSOR c_mand_comps IS
select bic.component_item_id component_item_id,
bic.component_quantity component_quantity,
bic.effectivity_date eff_date,
bic.disable_date disable_date,
bic.check_atp check_atp,
bic.wip_supply_type
from bom_bill_of_materials bbom,
	bom_inventory_components bic
where bbom.assembly_item_id = g_cto_sparse_shipset(p_index).Inventory_Item_Id
and bbom.organization_id = g_cto_sparse_shipset(p_index).Sourcing_Org
and bbom.alternate_bom_designator is NULL
and bbom.common_bill_sequence_id = bic.bill_sequence_id
and bic.optional = 2
and nvl(bic.disable_date, sysdate) >= sysdate
and bic.implementation_date is not null
and bic.bom_item_type = 4;

i		NUMBER := 0;
j		NUMBER := 0;
l_fixed_lt	NUMBER;
l_variable_lt	NUMBER;
l_preproc_lt	NUMBER;
l_atp_flag	VARCHAR2(1);
l_atp_comps_flag	VARCHAR2(1);
lStmtNum	NUMBER;
l_disable_date	DATE;
l_model_item_id NUMBER;
l_model_src_org NUMBER;
l_model_line_id	NUMBER;		--model's line id
l_new_model_line_id NUMBER;
l_wip_supply_type NUMBER;
l_parent_line_id NUMBER;	--parent ATO line id
l_link_line_id 	NUMBER;		--immediate parent line id
l_error_code	NUMBER;
--x_return_status VARCHAR2(1);
x_bill_id	NUMBER;

BEGIN
	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('Populate_Mandatory_Components: ' || 'Begin Populate_Mandatory_Components', 2);
	END IF;
	lStmtNum := 110;
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	l_model_item_id := g_cto_sparse_shipset(p_index).Inventory_Item_Id;
	l_model_src_org := g_cto_sparse_shipset(p_index).Sourcing_Org;
	l_model_line_id := g_cto_sparse_shipset(p_index).Line_Id;

	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('**Populate_Mandatory_Components: ' || 'Model item::'||to_char(l_model_item_id), 2);
		oe_debug_pub.add('**Populate_Mandatory_Components: ' || 'Model src org::'||to_char(l_model_src_org), 2);
		oe_debug_pub.add('**Populate_Mandatory_Components: ' || 'Model line_id::'||to_char(l_model_line_id), 2);
	END IF;

	/* In case of an option class or phantom model, assembly
	information for SMC's should be that of the next non-phantom
	parent model */
	IF (g_cto_sparse_shipset(l_model_line_id).Ato_Line_Id <> g_cto_sparse_shipset(l_model_line_id).Line_Id) THEN
		/* not top level ATO model */
		lStmtNum := 111;
		l_parent_line_id := g_cto_sparse_shipset(l_model_line_id).Parent_Ato_Line_id;
		l_link_line_id := g_cto_sparse_shipset(l_model_line_id).Link_To_Line_id;
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('**Populate_Mandatory_Components: ' || 'Parent line_id::'||to_char(l_parent_line_id), 4);
			oe_debug_pub.add('**Populate_Mandatory_Components: ' || 'Link_to_line_id::'||to_char(l_link_line_id), 4);
		END IF;

		lStmtNum := 112;
		select bic.wip_supply_type
		into l_wip_supply_type
		from bom_bill_of_materials bbom,
			bom_inventory_components bic
		where bbom.assembly_item_id = g_cto_sparse_shipset(l_link_line_id).Inventory_Item_Id
		and bbom.organization_id = g_cto_sparse_shipset(l_link_line_id).Sourcing_Org
		and bbom.alternate_bom_designator is NULL
		and bbom.common_bill_sequence_id = bic.bill_sequence_id
		and bic.component_item_id = g_cto_sparse_shipset(l_model_line_id).Inventory_Item_Id
		and rownum = 1;

		IF nvl(l_wip_supply_type, -1) = 6 THEN
			-- phantom model or option class
			lStmtNum := 113;
			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('**Populate_Mandatory_Components: ' || 'Phantom model or option class', 2);
			END IF;
			l_new_model_line_id := l_parent_line_id;
		ELSE
			lStmtNum := 114;
			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('**Populate_Mandatory_Components: ' || 'Non-Phantom model', 2);
			END IF;
			l_new_model_line_id := l_model_line_id;
		END IF;
	ELSE  /* top level ATO model */
		lStmtNum := 115;
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('**Populate_Mandatory_Components: ' || 'Top level ATO model', 2);
		END IF;
		l_new_model_line_id := l_model_line_id;
	END IF;

	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('**Populate_Mandatory_Components: ' || 'Model line_id::'||to_char(l_model_line_id), 2);
		oe_debug_pub.add('**Populate_Mandatory_Components: ' || 'New Model line_id::'||to_char(l_new_model_line_id), 2);
	END IF;

	lStmtNum := 116;
	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('Populate_Mandatory_Components: ' || 'Getting eff and dis date for optional comps', 4);
	END IF;

        -- Modified by Renga Kannan on 10/30/02
        -- The blind query on bom_calendar is modified with proper join
        -- The global variable used here G_OE_VALIDATION_ORG is set in the
        -- populate_om_shipset and populate_cz_shipset part of code
        -- We will get the calender dates based on the calendar code parameter
        -- set in the Oe validation org.

	select max(calendar_date)
	into l_disable_date
	from bom_calendar_dates cal,
             mtl_parameters mp
        where mp.organization_id = CTO_ATP_INTERFACE_PK.G_OE_VALIDATION_ORG
        and   mp.calendar_code   = cal.calendar_code
        and   mp.calendar_exception_set_id = cal.exception_set_id;

	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('Populate_Mandatory_Components: ' || 'l_disable_date :: '||to_char(l_disable_date), 4);
	END IF;

	FOR nxtrec IN c_mand_comps
	LOOP
		lStmtNum := 120;
		i := p_atp_bom.assembly_identifier.count+1;
		j := j + 1;
		Extend_Atp_Bom(p_atp_bom,
				x_Return_Status,
				x_Msg_Count,
				x_Msg_Data);

		IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('Populate_Mandatory_Components: ' || 'Unexp error in Extend_ATP_BOM::'||sqlerrm,1);
			END IF;
			raise FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('Populate_Mandatory_Components: ' || 'After extend_atp', 5);
		END IF;

		/*Populate this item's information*/
		lStmtNum := 130;
		p_atp_bom.Component_Item_Id(i) := nxtrec.component_item_id;
		--
		-- SMC's do not have line_id information.
		-- However, ATP engine needs to distinguish between the
		-- same SMC's existing more than once at different
		-- levels in the model BOM
		-- Hence, populating the immediate parent's line id
		-- (model's line_id) as the component identifier
		-- (Discussed with navneet)
		--
		p_atp_bom.Component_Identifier(i) := l_model_line_id;
		p_atp_bom.Assembly_Item_Id(i) := g_cto_sparse_shipset(l_new_model_line_id).Inventory_Item_Id;
		p_atp_bom.Assembly_Identifier(i) := l_new_model_line_id;
		p_atp_bom.Quantity(i) := nxtrec.component_quantity;
		p_atp_bom.Effective_date(i) := nxtrec.eff_date;
		p_atp_bom.Disable_date(i) := nvl(nxtrec.disable_date, l_disable_date);
		p_atp_bom.atp_check(i) := nxtrec.Check_ATP;
		p_atp_bom.wip_supply_type(i) := nxtrec.wip_supply_type ;
		p_atp_bom.SMC_Flag(i) := 'Y';
		p_atp_bom.source_organization_id(i) := g_cto_sparse_shipset(p_index).sourcing_org ;

		lStmtNum := 140;
		--
		-- Lead time required for all items (bug 2560915)
		--
		select nvl(fixed_lead_time, 0), nvl(variable_lead_time, 0), nvl(preprocessing_lead_time, 0)
		into l_fixed_lt, l_variable_lt, l_preproc_lt
		from mtl_system_items
		where inventory_item_id = g_cto_sparse_shipset(l_new_model_line_id).Inventory_Item_Id
		and organization_id = g_cto_sparse_shipset(l_new_model_line_id).Sourcing_Org;

		lStmtNum := 150;
		p_atp_bom.Fixed_LT(i) := l_fixed_lt;
		p_atp_bom.Variable_LT(i) := l_variable_lt;
		p_atp_bom.Pre_Process_LT(i) := l_preproc_lt;

		--
		-- Populate atp_flag for each component (bug 2462661)
		--
		lStmtNum := 160;
		select atp_flag, atp_components_flag
		into l_atp_flag, l_atp_comps_flag
		from mtl_system_items
		where inventory_item_id = nxtrec.component_item_id
		and organization_id = g_cto_sparse_shipset(l_new_model_line_id).Sourcing_Org;

		lStmtNum := 170;
		IF (l_atp_flag <> 'N' OR l_atp_comps_flag <> 'N') THEN
			p_atp_bom.atp_flag(i) := 'Y';
		ELSE
			p_atp_bom.atp_flag(i) := 'N';
		END IF;

	END LOOP;
	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('Populate_Mandatory_Components: ' || 'added '||to_char(j)||' mand comps for item '||to_char(l_model_item_id)||' in org '||to_char(l_model_src_org), 2);
	END IF;

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('Populate_Mandatory_Components: ' || 'Populate_Mandatory_Components::exp error::'||to_char(lStmtNum)||'::'||sqlerrm,1);
		END IF;
		x_return_status := FND_API.G_RET_STS_ERROR;

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('Populate_Mandatory_Components: ' || 'Populate_Mandatory_Components::unexp error::'||to_char(lStmtNum)||'::'||sqlerrm,1);
		END IF;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
        		(p_count => x_msg_count
        		,p_data  => x_msg_data
        		);
	WHEN OTHERS THEN
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('Populate_Mandatory_Components: ' || 'Populate_Mandatory_Components::others::'||to_char(lStmtNum)||'::'||sqlerrm,1);
		END IF;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            		FND_MSG_PUB.Add_Exc_Msg
            			(G_PKG_NAME
            			,'Populate_Mandatory_Components'
            			);
        	END IF;
        	FND_MSG_PUB.Count_And_Get
        		(p_count => x_msg_count
        		,p_data  => x_msg_data
        		);

END Populate_Mandatory_Components;




--   The structure of BOM_CTO_ORDER_TABLE
--   Table Name : Bom_Cto_order_lines_all
--   Bcod_line_id                 ====> Unique sequence no (Primary Key)
--   Oe_line_id                   ====> line_id from OE_order_lines_all table
--   Ato_line_id                  ====> Top ato model line_id (Mainly used to flush the
--                                         data with respect to a model)
--   Inventory_item_id            ====> Inventory_item_id of the model/option class/
--                                      option item
--   Organization_id              ====> In case of model/option class/option item rows
--                                      it will be having manufacturing org id
--                                      In case of config item/ Ato item it will be having
--                                      ship_from_org_id
--   Required_date                ====> Demand date
--   Required_qty                 ====> Demand Quantity
--   Order_quantity_uom           ====> Uom of the item
--   Parent_Demand_type           ====> If it is '1' THEN this row belongs to ATO MODEL
--                                      if it is '2' THEN this row belongs to ATO ITEM
--                                      (Mainly used in the flusing the data for all
--                                       ATO item lines before cplanning collection )
--   Header_id                    ====> Oe_order_headers_all header_id
--   Forecast_visible             ====> If 'Y' it will be exploded by Forecast
--                                      If 'N' it will be ignored by the Forecast exp
--   Demand_visible               ====> If 'Y' this row is visible for planning.
--                                      If 'N' this row will not be visible for planning.


FUNCTION is_config_line_exists(p_ato_line_id  IN Number
                                ) RETURN VARCHAR2;

PROCEDURE Create_demand_line(
                             p_session_id        IN Number,
                             p_line_id           IN Number,
                             p_ato_line_id       IN Number,
                             p_inventory_item_id IN oe_order_lines_all.inventory_item_id%type,
                             p_org_id            IN Number,
                             p_forecast_flag     IN Varchar2,
                             p_demand_flag       IN Varchar2,
                             p_config_line       IN varchar2
                            );


/*------------------------------------------------------------------------------
            Created by   : Renga Kannan
            Created Date : 26-sep-2000
            Purpose      : This procedure is being called from ATP when it
                           scheduling succeeds.The input for this procedure
                           is session_id for the pegging tree,reduced ship set
                           and the shared structure stored by the procedure
                           GET_ATP_BOM_PUB.
                           This procedure will get the required_qty and
                           required_date from ATP pegging tree table
                           MRP_ATP_DETAILS_TEMP and insert the entier row
                           into the table BOM_CTO_ORDER_DEMAND.
           Input         :
              p_ship_set   - This is the IN OUT Parameter. When it is called
                             from ATP it will have the Reduced Ship set in it.
                             And the end of this procedure it will be having
                             the full ship set(Transformed).
              p_success_flag - This will have 'Y' or 'N' based on the scheduling                               Succeeds or fails.
              p_session_id - session_id is used to identify the set of records
                             in the peggin tree
           Process       : The records in the table BOM_CTO_ORDER_DEMAND is
                           populated
           Output        :
              xreturn_status - Return FND_API.G_RET_STS_SUCCESS if the procedure
                               is executed successfully
                               Return FND_API.G_RET_STS_ERROR if the procedure
                               is completed with expected error
                               Return FND_API.G_RET_STS_UNEXP_ERROR if the
                               procedure is completed with unexpected error

The Logic for CREATE_CTO_MODEL_DEMAND is as follows:
1. Scan through the records in the Shared shipset
2. For each record in the shared shipset find out the shipset name
3. If the shipset is not sourced and the action is rescheduling
   THEN delete the information for this top model from BCOD table.

------------------------------------------------------------------------------*/

/*****************************************************************************************
09-JAN-2001
1. When the shipset is having a ATO model for which the configuration item
   is alerady created THEN the only action possible is rescheduling.
2. In this case delete the existing demand from bcod for this line_id.
3. And insert the new demands for all the model,option class and option item
   including config item with the proper visible_forecast_flag and visible_demand_flag

*******************************************************************************************/

PROCEDURE CREATE_CTO_MODEL_DEMAND(
          p_shipset        IN OUT NOCOPY MRP_ATP_PUB.ATP_REC_TYP,
          p_session_id     IN  number,
          p_shipset_status IN  MRP_ATP_PUB.SHIPSET_STATUS_REC_TYPE,
          xreturn_status   OUT varchar2,
          xMsgCount        OUT number,
          xMsgData         OUT varchar2) is
        i                    number; -- Loop counter
        lStmtNum             number;
        l_prev_shipset       varchar2(200) := null;
        l_shipset_status     varchar2(1);
        l_shipset_sourced    boolean;
        l_vis_forecast_flag  varchar2(1);
        l_vis_demand_flag    varchar2(1);
        l_config_exists      varchar2(1);
        ATP_NO_RECORD_ERROR  EXCEPTION;
        l_line_id            number;

	 -- new variables for 3189261
        l_par_line_id           number;
        l_par_inventory_item_id number;
        l_par_bom_item_type     number;
        l_required_date         date;
        l_required_qty          number;
        l_order_qty             number;
        l_order_quantity_uom    varchar2(3);
        l_record_count          number;
        l_header_id             oe_order_lines_all.header_id%type;
        x_lead_time             number;
        l_fixed_lead_time       number;
        l_variable_lead_time    number;
        l_stmt_num              number;
        -- end new variables for 3189261

BEGIN

   lStmtNum  := 10;
   SAVEPOINT  create_cto_model_demand_begin;

   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('create_cto_model_demand: ' || 'Begin CREATE_CTO_MODEL_DEMAND module ....',1);
   	oe_debug_pub.add('create_cto_model_demand: ' || 'Session id passed by ATP = '||to_char(p_session_id),1);
   END IF;

   -- Get the user id and Login id by calling the FND api
   guserid  := nvl(FND_GLOBAL.user_id,-1);
   gloginid := nvl(FND_GLOBAL.login_id,-1);

   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('create_cto_model_demand: ' || 'Record count in the ATP Shipset = '||to_char(p_shipset.action.count),2);
   END IF;

   IF p_shipset.action.count = 0 THEN
     IF PG_DEBUG <> 0 THEN
     	oe_debug_pub.add('create_cto_model_demand: ' || 'There are no records to process in ATP Shipset ',2);
     END IF;
     raise FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

/*
   The following part of the code is added for the Scheduling bug in OM.
   When the model option class or option item is deleted OM will indicate this
   With ATO_DELETE_FLAG in shipset. In this case CTO will simply delete the demand for that
   line_id in bcod and return the shipset back to ATP. ATP introduced a new flag ATO_DELETE_FLAG
   in shipset for this. For this delete case ATP will not call out pre ATP procedure.

   The following are the decision points in this design.

   1. When the option class or Option item is getting deleted, OM will pas only that
      perticular line to ATP with the appropirate flag. So at any time the no of records in the
      shipset will be 1.

   2. The action code in this case will be 120.
*/
    IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('ato delete flag check',2);
   	oe_debug_pub.add('ato delete flag count '|| p_shipset.ato_delete_flag.count,2);
   	oe_debug_pub.add('ato delete flag first '|| p_shipset.ato_delete_flag.first ,2);
    END IF;

    IF ( ( p_shipset.ato_delete_flag.count > 0 ) AND
     	( nvl (p_shipset.ato_delete_flag(p_shipset.ato_delete_flag.first),'N')
       	= 'Y' ))
    THEN

    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add('create_cto_model_demand: ' || 'One of the ATO line is deleted...',5);
    	oe_debug_pub.add('create_cto_model_demand: ' || 'No of records in shipset ='||to_char(p_shipset.action.count),5);
    	oe_debug_pub.add('create_cto_model_demand: ' || 'Action code   = '||to_char(p_shipset.action(p_shipset.action.first)),5);
    	oe_debug_pub.add('create_cto_model_demand: ' || 'Line id = '||to_char(p_shipset.identifier(p_shipset.identifier.first)),5);
    END IF;

    --- Delete the row from Bom_cto_order_demand for the line_id
    l_line_id := p_shipset.identifier(p_shipset.identifier.first);
    DELETE
    FROM  BOM_CTO_ORDER_DEMAND
    WHERE  OE_LINE_ID = l_line_id;

    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add('create_cto_model_demand: ' || 'No of records deleted..'||sql%rowcount,2);
    END IF;

    xreturn_status := FND_API.G_RET_STS_SUCCESS;

    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add('create_cto_model_demand: ' || 'Returning the control to ATP..',2);
    END IF;

    return;
  END IF;

  IF PG_DEBUG <> 0 THEN
	oe_debug_pub.add('ato delete flag check done',2);
  END IF;

   --  Action_code 100 means Enquiry
   --  Action_code 110 means Scheduling
   --  Actino_code 120 means Rescheduling

   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('create_cto_model_demand: ' || '....Scheduling Action code...'|| to_char( p_shipset.action(p_shipset.action.first)), 2);
   END IF;

   -- If the scheduling is succeded and the action is not enquiry THEN
   -- create the demand in BCOD table....
   IF p_shipset.action(p_shipset.action.first) <> 100 THEN

    -- 2723674  Flushing any existing demand for SLSO
      if slso_Shipset.COUNT > 0
      then
       	slso_index := slso_Shipset.FIRST;
       	oe_debug_pub.add('FIRST slso_index is '||to_char(slso_index), 2);
        loop
      	     lStmtNum := 30;
             if (slso_shipset.EXISTS(slso_index))
             then

                oe_debug_pub.add('ato line id is '||to_char(slso_shipset(slso_index).ato_line_id), 2);

             	delete from bom_cto_order_demand
      		where ato_line_id = slso_shipset(slso_index).ato_line_id;
      		rows_deleted	:= sql%rowcount;

      		oe_debug_pub.add('Deleted '||to_char(rows_deleted)||' rows. ', 2);

      	     slso_index := slso_Shipset.NEXT(slso_index);
      	     oe_debug_pub.add('NEXT slso_index is '||to_char(slso_index), 2);
      	     EXIT WHEN slso_index IS NULL;
      	     end if;
      	end loop;
       end if;
      -- end 2723674

      -- Loop through the shared  Shipset. For each record in the shared
      -- shipset get the required quantity and required date from the ATP
      -- pegging tree table MRP_ATP_DETAILS_TEMP

      IF PG_DEBUG <> 0 THEN
      	oe_debug_pub.add('create_cto_model_demand: ' || 'Total no of records in the shared stuct...'|| to_char(g_final_cto_shipset.count), 2);
      END IF;

      lStmtNum  := 15;

      -- 2723674

      IF g_final_cto_shipset.count > 0 THEN

      -- Commented following lines as a part of 2723674 fix

      -- IF g_final_cto_shipset.count = 0 THEN
      --    IF PG_DEBUG <> 0 THEN
      --   	oe_debug_pub.add('create_cto_model_demand: ' || '.. CREATE_CTO_MODEL_DEMAND module raising exp error::' ||'There are no records to process in the shared'||' Structure.....',1);
      --    END IF;
      --   raise FND_API.G_EXC_UNEXPECTED_ERROR;
      -- END IF;

      --
      -- We need to auto-generate shipset names once again in the structure
      -- returned by ATP. We use this auto-generated shipset name to
      -- reconstruct the shipset (bug 2598745)
      -- The auto-generated shipset names are already stored in the global
      -- structure g_auto_generated_shipset and need not be stored again.
      --
      lStmtNum := 17;
      FOR v_init IN p_shipset.ship_set_name.first..p_shipset.ship_set_name.last
      LOOP
      	IF ( p_shipset.ship_set_name(v_init ) is null
		AND p_shipset.arrival_set_name(v_init ) is null) THEN

	  	IF PG_DEBUG <> 0 THEN
	  		oe_debug_pub.add('create_cto_model_demand: ' ||  'Both ship set and arrival set are null', 3);
	  	END IF;
          	p_shipset.ship_set_name(v_init) := p_shipset.identifier(v_init) ;

      	ELSIF ( p_shipset.ship_set_name(v_init ) is null
		AND p_shipset.arrival_set_name(v_init ) is not null) THEN

	  	IF PG_DEBUG <> 0 THEN
	  		oe_debug_pub.add('create_cto_model_demand: ' ||  'Arrival set is not null', 3);
	  	END IF;
          	p_shipset.ship_set_name(v_init) := p_shipset.arrival_set_name(v_init) ;

      	END IF ;
      END LOOP ;	-- bug 2598745

      lStmtNum := 20;
      IF PG_DEBUG <> 0 THEN
      	oe_debug_pub.add('create_cto_model_demand: ' || '..Begin looping the shared structure...',2);
      END IF;

      i := g_final_cto_shipset.first;

      IF PG_DEBUG <> 0 THEN
      	oe_debug_pub.add('create_cto_model_demand: ' || 'Creating Demand in BCOD table...',2);
      END IF;

      FOR i IN g_final_cto_shipset.first..g_final_cto_shipset.last
      LOOP
       IF g_final_cto_shipset(i).mlmo_flag = 'Y' THEN 	--2723674
         -- Check if the shipset is succeeded in the scheduling action
         lStmtNum := 30;
         -- Whenever shipset is changing get the source and status information
         -- of the shipset
        IF not(g_final_cto_shipset(i).auto_generated AND not(g_final_cto_shipset(i).process_demand)) THEN
         IF nvl(l_prev_shipset,'-99') <> g_final_cto_shipset(i).ship_set_name THEN
            l_shipset_status := get_shipset_status(p_shipset_status,
                                                g_final_cto_shipset(i).ship_set_name);
            l_shipset_sourced := get_shipset_source_flag
                                         (g_final_cto_shipset(i).ship_set_name);
            l_prev_shipset := g_final_cto_shipset(i).ship_set_name;

            IF PG_DEBUG <> 0 THEN
            	oe_debug_pub.add('create_cto_model_demand: ' || 'shipset name ===> '||g_final_cto_shipset(i).ship_set_name,2);
            	oe_debug_pub.add('create_cto_model_demand: ' || 'shipset status ====>'||l_shipset_status,2);
            END IF;

            -- The following assignment is required cuz if the action for this shipset is
            -- scheduling THEN it will not go to the is_config_line_exists part at all
            l_vis_forecast_flag := 'Y';
            l_vis_demand_flag   := 'Y';
         END IF;

         lStmtNum  := 35;
	 IF  (FND_API.to_boolean(l_shipset_status))  THEN
            -- Deleted the information from BCOD table if the line is the
            -- Top model ATO line,
            -- Delete the line only if the action is rescheduling

            IF g_final_cto_shipset(i).ato_line_id = g_final_cto_shipset(i).line_id AND
               p_shipset.action(p_shipset.action.first) = 120 THEN

               -- If the config line does not exists set both forecast_visible
               -- and demand visible flag to Y
               -- If config line exists THEN set demand_visible to N and
               -- Forecast visible to Y. Also insert a line for the config item
               -- in bcod.

               lStmtNum := 38;
               l_config_exists :=  is_config_line_exists(g_final_cto_shipset(i).ato_line_id);

               IF PG_DEBUG <> 0 THEN
               	oe_debug_pub.add('create_cto_model_demand: ' || 'Config line exists for this ato_line_id '|| g_final_cto_shipset(i).ato_line_id||' Is '||l_config_exists,2);
               END IF;

               lStmtNum := 40;
               IF PG_DEBUG <> 0 THEN
               	oe_debug_pub.add('create_cto_model_demand: ' || ' Deleting the Bcod information for the '|| ' Ato line_id...'||to_char(g_final_cto_shipset(i).ato_line_id), 2);
               END IF;

               DELETE FROM BOM_CTO_ORDER_DEMAND
               WHERE  ato_line_id = g_final_cto_shipset(i).ato_line_id;

               lStmtNum  := 43;
               IF l_config_exists = 'Y' THEN
                   l_vis_forecast_flag := 'Y';
                   l_vis_demand_flag   := 'N';
                   -- Insert the Config line demand in BCOD if the qty is non zero
                   -- And the shipset is sourced/multi org
                  -- Added one more condition to filter buy model components
                  -- If buy_model is set to 'Y' in g_cto_shipset we should
                  -- not store the demand. This change is done for
                  -- Procuring configurations

                   IF PG_DEBUG <> 0 THEN
                   	oe_debug_pub.add('create_cto_model_demand: ' || 'Buy model flag ='||nvl(g_final_cto_shipset(i).buy_model,'N'),2);
                   END IF;

                   IF (g_final_cto_shipset(i).ordered_quantity <> 0 AND
                      l_shipset_sourced  AND
                      nvl(g_final_cto_shipset(i).wip_supply_type,-1) <> 6) AND
                      nvl(g_final_cto_shipset(i).buy_model,'N') <> 'Y'     THEN

                      IF PG_DEBUG <> 0 THEN
                      	oe_debug_pub.add('create_cto_model_demand: ' || 'Inserting a row in bcod for config line...',1);
                      END IF;

                      Create_demand_line(p_session_id        => p_session_id,
                                         p_line_id           => g_final_cto_shipset(i).line_id,
                                         p_ato_line_id       => g_final_cto_shipset(i).ato_line_id,
                                         p_inventory_item_id => g_final_cto_shipset(i).inventory_item_id,
                                         p_org_id            => g_final_cto_shipset(i).sourcing_org,
                                         p_forecast_flag     => 'N',
                                         p_demand_flag       => 'Y',
                                         p_config_line       => 'Y');

                      IF PG_DEBUG <> 0 THEN
                      	oe_debug_pub.add('create_cto_model_demand: ' || 'Config line demand is inserted successfully..',1);
                      END IF;

                   END IF;
               ELSE
                   l_vis_forecast_flag := 'Y';
                   l_vis_demand_flag   := 'Y';
              END IF;
            END IF;

            -- Check whether the shipset is sourced one or not
            -- If it is sourced THEN create the demand in bcod table
            -- Otherwise proceed with the next record
            -- Added to not create the bcod data for cancelation
            IF PG_DEBUG <> 0 THEN
            	oe_debug_pub.add('create_cto_model_demand: ' || 'Ordered quantity...'||to_char(g_final_cto_shipset(i).ordered_quantity),2);
            END IF;

            --            Another fix is done for the Phantom item case. In the case of option item being phantom
            --            we need not store the demand, since neither planning or forecast is going to look into this
            --            entry. Apart from that we won't be getting any information for the phantom option item from
            --            the begging tree. So we skipp getting information and storing it in bcod for phantom option items
            --            This is as part of the bug fix #: 1531399

            IF PG_DEBUG <> 0 THEN
            	oe_debug_pub.add('create_cto_model_demand: ' || 'WIP_SUPPLY_TYPE = '||to_char(g_final_cto_shipset(i).wip_supply_type) ,2);
            END IF;

            IF PG_DEBUG <> 0 THEN
            	oe_debug_pub.add('create_cto_model_demand: ' || 'Buy model flag ='||nvl(g_final_cto_shipset(i).buy_model,'N'),2);
            END IF;

            IF     g_final_cto_shipset(i).ordered_quantity <> 0
               AND l_shipset_sourced
               -- 3189261 AND nvl(g_final_cto_shipset(i).wip_supply_type,-1) <> 6
               AND nvl(g_final_cto_shipset(i).buy_model,'N')      <> 'Y'  THEN

                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add('create_cto_model_demand: ' || ' Shipset is sourced....', 2);
                END IF;

               lStmtNum := 50;
               -- Get the information from ATP Pegging tree
               -- And insert the information to BCOD table
               IF PG_DEBUG <> 0 THEN
               	oe_debug_pub.add('create_cto_model_demand: ' || to_char(g_final_cto_shipset(i).line_id)||':'||
                                to_char(g_final_cto_shipset(i).inventory_item_id )||':'||
                                to_char(g_final_cto_shipset(i).sourcing_org)||':'||to_char(p_session_id),2);
               END IF;

               -- In the following call p_config_line is set to 'N' cuz this loop will
               -- Insert demands for Model,Option class and option item and not config lines.
	       -- 3189261 : Add IF here
               IF nvl(g_final_cto_shipset(i).wip_supply_type,-1) <> 6 then
                 Create_demand_line(p_session_id        => p_session_id,
                                  p_line_id           => g_final_cto_shipset(i).line_id,
                                  p_ato_line_id       => g_final_cto_shipset(i).ato_line_id,
                                  p_inventory_item_id => g_final_cto_shipset(i).inventory_item_id,
                                  p_org_id            => g_final_cto_shipset(i).sourcing_org,
                                  p_forecast_flag     => l_vis_forecast_flag,
                                  p_demand_flag       => l_vis_demand_flag,
                                  p_config_line       => 'N');
	       ELSE
                -- 3189261 Derive the demand.
                -- select parent details


                begin

                 lStmtNum := 51;

                 IF PG_DEBUG <> 0 THEN
                     oe_debug_pub.add('CREATE_CTO_MODEL_DEMAND: ' ||  ' line_id ' || g_final_cto_shipset(i).link_to_line_id , 1);
                 END IF;


                 select oel.line_id,
                        oel.inventory_item_id,
                        msi.bom_item_type
                 into   l_par_line_id,
                        l_par_inventory_item_id,
                        l_par_bom_item_type
                 from   oe_order_lines_all oel,
                        mtl_system_items msi
                 where  oel.line_id = g_final_cto_shipset(i).link_to_line_id
                 and    oel.inventory_item_id = msi.inventory_item_id
                 and    oel.ship_from_org_id = msi.organization_id;


                 IF PG_DEBUG <> 0 THEN
                         oe_debug_pub.add('CREATE_CTO_MODEL_DEMAND: ' ||  ' line_id ' ||l_par_line_id ||
                                ' inventory_item_id ' || l_par_inventory_item_id ||
                                ' bom_item_type  ' || l_par_bom_item_type , 1);
                 END IF;

                -- select uom of phantom item

                 lStmtNum := 52;

		 IF PG_DEBUG <> 0 THEN
                    oe_debug_pub.add('CREATE_CTO_MODEL_DEMAND: ' ||  ' line_id ' || g_final_cto_shipset(i).line_id , 1);
                 END IF;

                 select order_quantity_uom,ordered_quantity
                 into   l_order_quantity_uom,l_order_qty
                 from   oe_order_lines_all
                 where  line_id = g_final_cto_shipset(i).line_id;

                 IF PG_DEBUG <> 0 THEN
                    oe_debug_pub.add('CREATE_CTO_MODEL_DEMAND: ' ||  ' order_quantity_uom ' || l_order_quantity_uom , 1);
                 END IF;

                 -- for bom_item_type = 2 ( Option Class ) and 1 ( Model)
                 -- get date from pegging tree

                 lStmtNum := 53;

                 IF PG_DEBUG <> 0 THEN
                         oe_debug_pub.add('CREATE_CTO_MODEL_DEMAND: ' ||  ' session_id ' ||p_session_id ||
                                ' component_identifier ' || g_final_cto_shipset(i).link_to_line_id ||
                                ' inventory_item_id ' || l_par_inventory_item_id ||
                                ' organization_id  ' || g_final_cto_shipset(i).sourcing_org , 1);
                 END IF;

                 select MAX(atp.supply_demand_date),          -- required_date
                        SUM(atp.supply_demand_quantity),      -- required_qty
                        MAX(oel.order_quantity_uom),          -- ordered_quantity_uom
                        MAX(oel.header_id),                   -- Header_id
                        COUNT(*)                              -- To get the no of rows selected
                                                             -- The above count(*) is added by renga on 12/22/00 to error out
                                                             -- in the case of zero rows.
                 into   l_required_date,
                        l_required_qty,
                        l_order_quantity_uom,
                        l_header_id,
                        l_record_count
		 from   MRP_ATP_DETAILS_TEMP ATP,
                        OE_ORDER_LINES_ALL OEL
                 where  ATP.session_id             = p_session_id
                 and    ATP.component_identifier   = g_final_cto_shipset(i).link_to_line_id
                 and    ATP.inventory_item_id      = l_par_inventory_item_id
                 and    ATP.organization_id        = g_final_cto_shipset(i).sourcing_org
                 and    ATP.supply_demand_type     = 1 -- Demand
                 and    OEL.line_id                = ATP.component_identifier;

                 IF PG_DEBUG <> 0 THEN
                         oe_debug_pub.add('CREATE_CTO_MODEL_DEMAND: ' ||  ' required_date ' ||l_required_date ||
                                ' required_qty ' || l_required_qty ||
                                ' order_quantity_uom ' || l_order_quantity_uom ||
                                ' header_id ' || l_header_id , 1);
                 END IF;

                -- additional massage of required date for Model
                -- by offsetting it with lead time
                if l_par_bom_item_type = 1 then

                        lStmtNum := 54;

                        select nvl(fixed_lead_time,0),
                               nvl(variable_lead_time,0)
                        into   l_fixed_lead_time,
                               l_variable_lead_time
                        from   mtl_system_items
                        where  inventory_item_id = l_par_inventory_item_id
                        and    organization_id   = g_final_cto_shipset(i).sourcing_org;

                        x_lead_time := l_fixed_lead_time  +
                                       l_variable_lead_time * l_required_qty;

                        IF PG_DEBUG <> 0 THEN
                         oe_debug_pub.add('CREATE_CTO_MODEL_DEMAND: ' ||  ' Fixed LT ' ||l_fixed_lead_time ||
                                ' Variable LT ' || l_variable_lead_time ||
                                ' required_qty ' || l_required_qty ||
                                ' lead_time ' || x_lead_time , 1);
                         END IF;

                --  Calculate the offset date with CalENDer

		 lStmtNum := 55;

                    IF PG_DEBUG <> 0 THEN
                     oe_debug_pub.add('CREATE_CTO_MODEL_DEMAND: ' ||  ' Sourcing_org ' || g_final_cto_shipset(i).sourcing_org ||
                                ' required_date ' || l_required_date ||
                                ' lead_time ' || x_lead_time , 1);
                    END IF;


                    l_required_date := MSC_SATP_FUNC.src_date_offset (
                                        g_final_cto_shipset(i).sourcing_org,
                                        l_required_date,
                                        x_lead_time);
                End if;

                -- insert phantom item demand into bcod

                lStmtNum := 56;

                IF PG_DEBUG <> 0 THEN
                 oe_debug_pub.add('CREATE_CTO_MODEL_DEMAND: ' ||  ' oe_line_id ' || g_final_cto_shipset(i).line_id ||
                                ' ato_line_id ' || g_final_cto_shipset(i).ato_line_id ||
                                ' inventory_item_id ' || g_final_cto_shipset(i).inventory_item_id ||
                                ' organization_id ' || g_final_cto_shipset(i).sourcing_org ||
                                ' required_date ' || l_required_date ||
                                ' required_qty ' || l_order_qty ||
                                ' order_quantity_uom ' || l_order_quantity_uom ||
                                ' header_id ' || g_final_cto_shipset(i).header_id ||
                                ' forecast_visible ' || l_vis_forecast_flag ||
                                ' demand_visible ' || l_vis_demand_flag , 1);
                END IF;

		INSERT INTO BOM_CTO_ORDER_DEMAND (
                      bcod_line_id,
                      oe_line_id,
                      ato_line_id,
                      inventory_item_id,
                      organization_id,
                      required_date,
                      required_qty,
                      order_quantity_uom,
                      parent_demand_type,
                      header_id,
                      forecast_visible,
                      demand_visible,
                      created_by,
                      last_updated_by,
                      last_updated_date,
                      last_update_login,
                      program_application_id,
                      program_update_date)
               VALUES(
                      BOM_CTO_ORDER_DEMAND_S1.nextval,           -- bcod_line_id
                      g_final_cto_shipset(i).line_id,            -- oe_line_id
                      g_final_cto_shipset(i).ato_line_id,        -- ato_line_id
                      g_final_cto_shipset(i).inventory_item_id,  -- Inventory_item_id
                      g_final_cto_shipset(i).sourcing_org,       -- organization_id
                      l_required_date,                           -- required_date
                      l_order_qty,                               -- required_qty
                      l_order_quantity_uom,                      -- ordered_quantity_uom
                      1,                                         -- parent_demand_type
                      g_final_cto_shipset(i).header_id,          -- header_id
                      l_vis_forecast_flag,                       -- forecast_visible
                      l_vis_demand_flag,                         -- demand_visible
                      guserid,                                   -- Created_by
                      guserid,                                   -- Last_updated_by
                      sysdate,                                   -- last_updated_date
                      gloginid,                                  -- Last update_login
                      null,                                      -- program_application_id
                      sysdate);                                  -- program_update_date
		EXCEPTION
                when no_data_found then
                        IF PG_DEBUG <> 0 THEN
                          oe_debug_pub.add( ' CREATE_CTO_MODEL_DEMAND: no_data_found in stmt # '||to_char(l_stmt_num) );
                        END IF;

                when others then
                        IF PG_DEBUG <> 0 THEN
                          oe_debug_pub.add('CREATE_CTO_MODEL_DEMAND: unexp error in stmt # '||to_char(l_stmt_num)||' :: '|| sqlerrm);
                        END IF;
                END;

            END IF;     -- end bugfix 3189261

          END IF ;
         END IF;
      END IF;
      END IF; 	-- 2723674
      END LOOP;
   END IF; -- 		2723674		g_final count > 0
   END IF; -- 		2723674		action code <> 100

   -- Call the procedure to reconstruct the Full ship set
   -- From Reduced ship set
   lStmtNum  := 70;
   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('create_cto_model_demand: ' || 'Calling reconstruct_shipset....',2);
   END IF;
   RECONSTRUCT_SHIPSET(
                       p_shipset,
                       p_shipset_status,
                       xreturn_status,
                       xmsgcount,
                       xmsgdata);

    IF PG_DEBUG <> 0 THEN
	oe_debug_pub.add('create_cto_model_demand: ' || 'coming out of Reconstruct ship set with status ..'||xreturn_status,2);
    END IF;

   IF xreturn_status = FND_API.G_RET_STS_ERROR THEN
      IF PG_DEBUG <> 0 THEN
      	oe_debug_pub.add('create_cto_model_demand: ' || ' exp Error in Resurrect_shipset procedure..',1);
      END IF;
      raise FND_API.G_EXC_ERROR;
   ELSIF xreturn_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      IF PG_DEBUG <> 0 THEN
      	oe_debug_pub.add('create_cto_model_demand: ' || ' Unexp Error in Resurrect_shipset procedure..',1);
      END IF;
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   xreturn_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
           WHEN FND_API.G_EXC_ERROR THEN
               ROLLBACK to create_cto_model_demand_begin;
               IF PG_DEBUG <> 0 THEN
               	oe_debug_pub.add('create_cto_model_demand: ' || ' CREATE_CTO_MODEL_DEMAND :: exp error::'|| to_char(lStmtNum)||'::'||sqlerrm,1);
               END IF;
               xreturn_status := FND_API.G_RET_STS_ERROR;
               FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,'CREATE_CTO_MODEL_DEMAND');
               FND_MSG_PUB.Count_and_get(
                                         p_count => XMsgcount,
                                         p_data  => XMsgData);
           WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
               ROLLBACK to create_cto_model_demand_begin;
               IF PG_DEBUG <> 0 THEN
               	oe_debug_pub.add('create_cto_model_demand: ' || ' CREATE_CTO_MODEL_DEMAND :: unexp error::'|| to_char(lStmtNum)||'::'||sqlerrm,1);
               END IF;
               xreturn_status := FND_API.G_RET_STS_UNEXP_ERROR;
               IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                  FND_MSG_PUB.Add_Exc_Msg(
                                           G_PKG_NAME
                                         , 'CREATE_CTO_MODEL_DEMAND'
                                           );
               END IF;

               FND_MSG_PUB.Count_and_get(
                                         p_count => XMsgCount,
                                         p_data  => xMsgData);
           WHEN OTHERS THEN
               ROLLBACK to create_cto_model_demand_begin;
               IF PG_DEBUG <> 0 THEN
               	oe_debug_pub.add('create_cto_model_demand: ' || ' CREATE_CTO_MODEL_DEMAND :: Other error ::'|| to_char(lStmtNum)||'::'||sqlerrm,1);
               END IF;
               xreturn_status := FND_API.G_RET_STS_UNEXP_ERROR;
               IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                  FND_MSG_PUB.Add_Exc_Msg(
                                           G_PKG_NAME
                                         , 'CREATE_CTO_MODEL_DEMAND'
                                           );
               END IF;

               FND_MSG_PUB.Count_and_get(
                                         p_count => XMsgCount,
                                         p_data  => XMsgData);
END CREATE_CTO_MODEL_DEMAND;



FUNCTION get_shipset_status(
                            p_shipset_tbl  IN MRP_ATP_PUB.SHIPSET_STATUS_REC_TYPE,
                            p_shipset_name IN varchar2) RETURN VARCHAR2 is
                            i  number := 0;
BEGIN
      IF PG_DEBUG <> 0 THEN
      	oe_debug_pub.add('get_shipset_status: ' || ' in get_shipset_status ... record count...'|| to_char(p_shipset_tbl.ship_set_name.count), 3);
      	oe_debug_pub.add('get_shipset_status: ' || 'Param shipset name = '||p_shipset_name,3);
      END IF;

      IF p_shipset_tbl.ship_set_name.count = 0 THEN
         IF PG_DEBUG <> 0 THEN
         	oe_debug_pub.add('get_shipset_status: ' || ' UNEXP ERROR :: GET_SHIPSET_STATUS  '|| ' No records found in the shipset status structure ',2);
         END IF;
         raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      FOR i IN p_shipset_tbl.ship_set_name.first..p_shipset_tbl.ship_set_name.last
      LOOP
          IF PG_DEBUG <> 0 THEN
          	oe_debug_pub.add('get_shipset_status: ' || 'Loop shipset name ='||p_shipset_tbl.ship_set_name(i),3);
          END IF;
          IF p_shipset_tbl.ship_set_name(i) = p_shipset_name THEN
              return p_shipset_tbl.status(i);
          END IF;
      END LOOP;
      IF PG_DEBUG <> 0 THEN
      	oe_debug_pub.add('get_shipset_status: ' || ' UNEXP ERROR :: GET_SHIPSET_STATUS  '|| ' The shipset name is not found in the pl/sql record '|| ' Shipset Name : '||p_shipset_name,2);
      END IF;
      return 'F';
END get_shipset_status;



FUNCTION get_shipset_source_flag(p_shipset_name IN varchar2) RETURN BOOLEAN is
      i    number := 0;
BEGIN
      IF PG_DEBUG <> 0 THEN
      	oe_debug_pub.add('get_shipset_source_flag: ' || 'get_shipset_source_flag :param value :'||p_shipset_name,3);
      END IF;

      IF g_shipset_status_tbl.count = 0 THEN
         IF PG_DEBUG <> 0 THEN
         	oe_debug_pub.add('get_shipset_source_flag: ' || ' UNEXP ERROR :: GET_SHIPSET_SOURCE_FLAG '|| ' No records found in the shipset structure ',2);
         END IF;
      END IF;

      FOR i IN g_shipset_status_tbl.first..g_shipset_status_tbl.last
      LOOP
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('get_shipset_source_flag: ' || ' source flag shipset name ...'|| g_shipset_status_tbl(i).ship_set_name,3);
        END IF;
        IF g_shipset_status_tbl(i).ship_set_name = p_shipset_name THEN
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('get_shipset_source_flag: ' || 'return success from source_flag proc ...',2);
		END IF;
          return g_shipset_status_tbl(i).model_sourced;
        END IF;
      END LOOP;
      IF PG_DEBUG <> 0 THEN
      	oe_debug_pub.add('get_shipset_source_flag: ' || ' UNEXP ERROR :: GET_SHIPSET_SOURCE_FLAG '||
                       ' The shipset name is not found in the pl/sql record '||
                       ' Shipsets Name :'||p_shipset_name,2);
      END IF;
      return false;
END get_shipset_source_flag;



FUNCTION is_config_line_exists(p_ato_line_id IN Number) RETURN VARCHAR2 is
         x_config_exists     varchar2(1);
BEGIN
         IF PG_DEBUG <> 0 THEN
         	oe_debug_pub.add('is_config_line_exists: ' || 'Entering is_config_item_exists for ato_line_id '|| to_char(p_ato_line_id), 4);
         END IF;

         SELECT  'Y'
         INTO    x_config_exists
         FROM    OE_ORDER_LINES_ALL
         WHERE   ato_line_id  = p_ato_line_id
         AND     ITEM_TYPE_CODE = 'CONFIG';

         return x_config_exists;
EXCEPTION
         WHEN NO_DATA_FOUND THEN
         IF PG_DEBUG <> 0 THEN
         	oe_debug_pub.add('is_config_line_exists: ' || 'Config line does not exists ..',1);
         END IF;
         x_config_exists := 'N';
         return x_config_exists;
         WHEN OTHERS THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END is_config_line_exists;



PROCEDURE create_demand_line(
                             p_session_id        IN Number,
                             p_line_id           IN Number,
                             p_ato_line_id       IN Number,
                             p_inventory_item_id IN oe_order_lines_all.inventory_item_id%type,
                             p_org_id            IN Number,
                             p_forecast_flag     IN Varchar2,
                             p_demand_flag       IN Varchar2,
                             p_config_line       IN varchar2) is


           l_required_date        date;
           l_required_qty         number;
           l_order_quantity_uom   varchar2(3);
           l_record_count         number;
           l_header_id            oe_order_lines_all.header_id%type;
           l_line_id              oe_order_lines_all.line_id%type;
           l_org_id               mtl_system_items.organization_id%type;
           l_inv_item_id          mtl_system_items.inventory_item_id%type;
           ATP_NO_RECORD_ERROR    EXCEPTION;
           l_stmt_no              number;
BEGIN

   -- If the Demand creation is for Config line
   -- get the demand record for the model with shipping org
   -- This will give you a exact schedule date and insert the
   -- the config line dtls in bcod table
   -- If it is not for config line THEN whatever we are getting in
   -- parameters that are safe.

   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('create_demand_line: ' || 'Entering create_demand_line procedure...',1);
   END IF;
   l_stmt_no := 10;
   IF p_config_line = 'Y' THEN
   --  Select the config line info from oe_order_lines_all
     l_stmt_no := 20;
     SELECT line_id,
            inventory_item_id,
            ship_from_org_id
     INTO
            l_line_id,
            l_inv_item_id,
            l_org_id
     FROM   OE_ORDER_LINES_ALL
     WHERE
                ato_line_id    = p_ato_line_id
            AND item_type_code = 'CONFIG';
   ELSE
      l_line_id     := p_line_id;
      l_inv_item_id := p_inventory_item_id;
      l_org_id      := p_org_id;
   END IF;

   --             bug fix #: 1531429
   --             Details
   --                      When we are getting the information from Pegging Tree we may get more than
   --                      one row for the combination of session_id,inventroy_item_id,supply_demand_type,
   --                      and the component_identifier. This is happening if the scheduling activity
   --                      succeeds due to both forward and backward scheduling. In this case we should
   --                      take the sum of the qty as the request qty and max of date as the request date.


         -- Get the requirement_date and requirement_qty from
         -- MRP_ATP_DETAILS_TEMP (Pegging Tree) table


   l_stmt_no := 30;

   SELECT /* added required date for BUG#2465370  */
          MAX(nvl( atp.required_date, atp.supply_demand_date)),          -- required_date
          SUM(atp.supply_demand_quantity),      -- required_qty
          MAX(oel.order_quantity_uom),          -- ordered_quantity_uom
          MAX(oel.header_id),                   -- Header_id
          COUNT(*)                              -- To get the no of rows selected
                                   -- The above count(*) is added by renga on 12/22/00 to error out
                                   -- in the case of zero rows.
   INTO
          l_required_date,
          l_required_qty,
          l_order_quantity_uom,
          l_header_id,
          l_record_count
   FROM
          MRP_ATP_DETAILS_TEMP ATP,
          OE_ORDER_LINES_ALL OEL
   WHERE
               ATP.session_id           = p_session_id
          AND  ATP.component_identifier = p_line_id
          AND  ATP.inventory_item_id    = p_inventory_item_id
          AND  ATP.organization_id      = l_org_id
          AND  ATP.supply_demand_type   = 1 -- Demand
          AND  ATP.component_identifier = OEL.line_id;


    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add('create_demand_line: ' || to_char(p_line_id)||':'||
                     to_char(p_inventory_item_id )||':'||
                     to_char(l_org_id)||':'||
                     to_char(l_required_qty)||':'||to_char(l_required_date),2);
    	oe_debug_pub.add('create_demand_line: ' || '# of Records in the Pegging tree :'||
                     to_char(l_record_count));
    END IF;

    --   This check is added to see whether ATP pegging tree returned any rows or not
    --   If there no rows returned from ATP THEN we need to raise an exception

    IF l_record_count = 0 THEN

       IF PG_DEBUG <> 0 THEN
       	oe_debug_pub.add('create_demand_line: ' || ' NO records in the pegging tree..',1);
       END IF;
       raise ATP_NO_RECORD_ERROR;

    ELSE

    l_stmt_no := 40;

    INSERT INTO BOM_CTO_ORDER_DEMAND (
                      bcod_line_id,
                      oe_line_id,
                      ato_line_id,
                      inventory_item_id,
                      organization_id,
                      required_date,
                      required_qty,
                      order_quantity_uom,
                      parent_demand_type,
                      header_id,
                      forecast_visible,
                      demand_visible,
                      created_by,
                      last_updated_by,
                      last_updated_date,
                      last_update_login,
                      program_application_id,
                      program_update_date)
    VALUES(
                      BOM_CTO_ORDER_DEMAND_S1.nextval,           -- bcod_line_id
                      l_line_id,                                 -- oe_line_id
                      p_ato_line_id,                             -- ato_line_id
                      l_inv_item_id,                             -- Inventory_item_id
                      l_org_id,                                  -- organization_id
                      l_required_date,                           -- required_date
                      l_required_qty,                            -- required_qty
                      l_order_quantity_uom,                      -- ordered_quantity_uom
                      1,                                         -- parent_demand_type
                      l_header_id,                               -- header_id
                      p_forecast_flag,                           -- forecast_visible
                      p_demand_flag,                             -- demand_visible
                      guserid,                                   -- Created_by
                      guserid,                                   -- Last_updated_by
                      sysdate,                                   -- last_updated_date
                      gloginid,                                  -- Last update_login
                      null,                                      -- program_application_id
                      sysdate);                                  -- program_update_date

    END IF;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('create_demand_line: ' || 'error at statement no #'||to_char(l_stmt_no),1);
         	oe_debug_pub.add('create_demand_line: ' || 'No Records found in the ATP Pegging Tree
                           for  line_id ..'||
                           to_char(l_line_id)||
                           'Item id ....'||
                            to_char(l_inv_item_id)
                            ||' And Sourcing org  ...'
                            ||to_char(l_org_id)||sqlerrm,1);
         END IF;
         raise FND_API.G_EXC_UNEXPECTED_ERROR;
      WHEN ATP_NO_RECORD_ERROR THEN
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('create_demand_line: ' || 'error at statement no #'||to_char(l_stmt_no),1);
        END IF;
        raise FND_API.G_EXC_UNEXPECTED_ERROR;
      WHEN OTHERS THEN
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('create_demand_line: ' || 'error at statement no #'||to_char(l_stmt_no),1);
        	oe_debug_pub.add('create_demand_line: ' || 'Error in select :: Other:: in the ATP Pegging Tree for  line_id ..'|| to_char(l_line_id)||
                           'Item id ....'||
                            to_char(l_inv_item_id)
                                 ||' And Sourcing org  ...'
                                 ||to_char(l_org_id)||sqlerrm,1);
        END IF;
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
   END Create_demand_line;


PROCEDURE ato_item_exp(p_item_id  mtl_system_items.inventory_item_id%type,
                       p_org_id   mtl_system_items.organization_id%type,
                       p_qty      number,
                       p_req_date date,
                       p_line_id  number,
                       p_header_id number,
                       x_return_status out varchar2,
                       x_msg_count  out number,
                       x_msg_data   out varchar2);


PROCEDURE create_demand(p_item_id in number,
                        p_org_id in number,
                        p_req_date in date,
                        p_qty in number,
                        p_line_id in number,
                        p_header_id in number,
                        x_return_status out varchar2,
                        x_msg_count     out number,
                        x_msg_data      out varchar2);


PROCEDURE  Is_item_sourced(p_item_id in number,
                         p_org_id in number,
                         x_source_flag   out varchar2,
                         x_return_status out varchar2,
                         x_msg_count     out number,
                         x_msg_data      out varchar2);


/*****************************************************************
   Procedured Name    :  CREATE_CTO_ITEM_DEMAND
   Created By         :  Renga Kannan
   Created Date       :  10-oct-2000
   Purpose            :  This procedure will be called by planning
                         collection process. Before planning starts
                         collecting the data this proecedure scan thru
                         all oe_order_lines and get all the Ato_item_lines.
                         For all these Ato_items this will explode the bill
                         and create the demand in the proper manufacturing
                         organizations.
  Input               :
  Output              : The proper demand record stored in the
                        BOM_CTO_ORDER_DEMAND
********************************************************************/


--- Modified for performance reason
--- Removed the join with Oe_order_headers_all table
--- and chagned the open_flag where from headers to line
--- this will improve the performance very well

PROCEDURE CREATE_CTO_ITEM_DEMAND(x_return_status out varchar2,
                                 x_msg_count     out number,
                                 x_msg_data      out varchar2) is
       cursor ato_item_lines is
       SELECT
              oeol.header_id,
              oeol.line_id,
              oeol.inventory_item_id,
              oeol.ship_from_org_id,
              oeol.ordered_quantity,
              oeol.schedule_ship_date,
              oeol.order_quantity_uom
      FROM    oe_order_lines_all oeol
      WHERE
              oeol.open_flag = 'Y'  /* SRS added for performance to retrieve only open orde
rs */
      AND     oeol.ship_from_org_id is not null
      AND     nvl(oeol.visible_demand_flag,'N') = 'Y'
      AND    ( oeol.item_type_code = 'STANDARD' OR oeol.item_type_code = 'OPTION' )
               /* added item_code = 'OPTION' to support ATO ITEMs under PTO Models per
BUG#1874380 */
      AND     oeol.line_id = oeol.ato_line_id
      AND     nvl(oeol.source_document_type_id,0) <> 10; -- This is confirmed with OM

      lStmtNum     Number := 0;
      l_source_flag Varchar2(1) := 'N';
BEGIN
     SAVEPOINT create_cto_item_demand_begin;

--   Since the ATO item explosion is execute during collection this above global varibale
--   needs to be initialized here also.

     IF PG_DEBUG <> 0 THEN
     	oe_debug_pub.add('create_cto_item_demand: ' || ' Begin CREATE_CTO_ITEM_DEMAND module...',1);
     END IF;
     guserid  := nvl(FND_GLOBAL.user_id,-1);
     gloginid := nvl(FND_GLOBAL.login_id,-1);

     -- Flush the data from BCOD table which is being populated
     -- by the previous collection run.
     -- The parent_demand_type = 2 tells that those rows are ato item rows
    lStmtNum := 10;
    -- Get the instace id from MRP_AP_APPS_INSTANCES
    -- This table will allways have one row

    lStmtNum := 13;
   /* initialize assignment set */
   initialize_assignment_set( x_return_status ) ;

   IF( x_return_status = FND_API.G_RET_STS_ERROR ) THEN
       IF PG_DEBUG <> 0 THEN
       	oe_debug_pub.add('create_cto_item_demand: ' || 'initialize_assignment_set returned with Expected error',1);
       END IF;
       RAISE FND_API.G_EXC_ERROR ;

   ELSIF( x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
       IF PG_DEBUG <> 0 THEN
       	oe_debug_pub.add('create_cto_item_demand: ' || 'initialize_assignment_set returned with Unexpected error',1);
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
   END IF ;

    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add('create_cto_item_demand: ' || 'Before getting the instance id ..',2);
    END IF;
    BEGIN
       SELECT instance_id
       INTO   ginstance_id
       FROM   MRP_AP_APPS_INSTANCES;
    EXCEPTION WHEN OTHERS THEN
       IF PG_DEBUG <> 0 THEN
       	oe_debug_pub.add('create_cto_item_demand: ' || 'UNEXP ::Error in getting instance id  '||sqlerrm||'::'||'line number'||to_char(lStmtNum), 1);
       END IF;
       raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END;

    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add('create_cto_item_demand: ' || 'Instance_id = '||to_char(ginstance_id),2);
    END IF;

    lStmtNum := 15;
    -- Delete all the lines in the bcod table where the
    -- parent_demand_type = '2'. This will delete all the rows
    -- corresponding to ato items.

    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add('create_cto_item_demand: ' || 'Before deleting records from Bcod table..',2);
    END IF;

    DELETE
    FROM
    BOM_CTO_ORDER_DEMAND
    WHERE  parent_demand_type = '2'; ---  The rows belongs to ato items

    lStmtNum := 20;

    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add('create_cto_item_demand: ' || 'Start looping thru oe_order_lines.....',2);
    END IF;

    FOR myrec IN ato_item_lines
    LOOP
        lStmtNum := 30;

        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('create_cto_item_demand: ' || 'Line_id           ='||to_char(myrec.line_id),2);
        	oe_debug_pub.add('create_cto_item_demand: ' || 'Header_id         ='||to_char(myrec.header_id),2);
        	oe_debug_pub.add('create_cto_item_demand: ' || 'inventory_item_id ='||to_char(myrec.inventory_item_id),2);
        	oe_debug_pub.add('create_cto_item_demand: ' || 'Ship_from_org_id  ='||to_char(myrec.ship_from_org_id),2);
        	oe_debug_pub.add('create_cto_item_demand: ' || 'Ordered_qty       ='||to_char(myrec.ordered_quantity),2);
        	oe_debug_pub.add('create_cto_item_demand: ' || 'Before getting sourcing flag..',2);
        END IF;

        is_item_sourced(myrec.inventory_item_id,
                      myrec.ship_from_org_id,
                      l_source_flag,
                      x_return_status,
                      x_msg_count,
                      x_msg_data);

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
           IF PG_DEBUG <> 0 THEN
           	oe_debug_pub.add('create_cto_item_demand: ' || 'Exp Error in is_item_sourced procedure for the item_id'
                            ||to_char(myrec.inventory_item_id)
                            ||' and org id...'||to_char(myrec.ship_from_org_id)
                            ,1);
           END IF;
           raise FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           IF PG_DEBUG <> 0 THEN
           	oe_debug_pub.add('create_cto_item_demand: ' || 'Unexp Error in is_item_sourced procedure for the item_id'
                            ||to_char(myrec.inventory_item_id)
                            ||' and org id...'||to_char(myrec.ship_from_org_id)
                            ,1);
           END IF;
           raise FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('create_cto_item_demand: ' || 'Source_flag   = '||l_source_flag,2);
        END IF;

        -- If the line is not fully cancelled and this Ato item is sourced
        -- THEN demand will be exploded in the Bcod table...

        IF myrec.ordered_quantity <> 0 AND l_source_flag = 'Y' THEN

           -- Insert the Configuration line into the demand table.....
           lStmtNum := 40;

           IF PG_DEBUG <> 0 THEN
           	oe_debug_pub.add('create_cto_item_demand: ' || 'Inserting Config line info into bcod...',2);
           END IF;

           INSERT INTO
              BOM_CTO_ORDER_DEMAND(
              bcod_line_id,
              oe_line_id,
              ato_line_id,
              inventory_item_id,
              organization_id,
              required_date,
              required_qty,
              order_quantity_uom,
              parent_demand_type,
              header_id,
              forecast_visible,
              demand_visible,
              created_by,
              last_updated_by,
              last_updated_date,
              last_update_login,
              program_application_id,
              program_update_date)
           VALUES (
              bom_cto_order_demand_s1.nextval,    --  bcod_line_id
              myrec.line_id,                      --  oe_line_id
              myrec.line_id,                      --  ato_line_id
              myrec.inventory_item_id,            --  inventory_item_id
              myrec.ship_from_org_id,             --  organization_id
              myrec.schedule_ship_date,           --  Required_date
              Round( myrec.ordered_quantity, 6 ) ,--  Ordered Quantity /* Decimal-Qty Support for Option Items */
              myrec.order_quantity_uom,           --  Order_quantity_uom
              2,                                  --  parent_demand_type
              myrec.header_id,                    --  Header_id
              'N',                                --  Forecast_visible
              'Y',                                --  Demand_visible
              guserid,                            --  Created_by
              guserid,                            --  Last_updated_by
              sysdate,                            --  Last_updated_date
              gloginid,                           --  Last_update_login
              null,                               --  program_application_id
              sysdate);                           --  Program_update_date

	   /*  Call the ato_item_Exp procedure to explode the Ato_item bill and
    	   Store the model,option class and option item demands             */
           lStmtNum := 50;

           IF PG_DEBUG <> 0 THEN
           	oe_debug_pub.add('create_cto_item_demand: ' || 'Calling ato_item_exp procedure...',2);
           END IF;

           ato_item_exp(myrec.inventory_item_id,
                     myrec.ship_from_org_id,
                     myrec.ordered_quantity,
                     myrec.schedule_ship_date,
                     myrec.line_id,
                     myrec.header_id,
                     x_return_status,
                     x_msg_count,
                     x_msg_data);

           IF x_return_status = FND_API.G_RET_STS_ERROR THEN
              IF PG_DEBUG <> 0 THEN
              	oe_debug_pub.add('create_cto_item_demand: ' || 'Exp Error in ato_item_exp procedure for the item_id'
                            ||to_char(myrec.inventory_item_id)
                            ||' and org id...'||to_char(myrec.ship_from_org_id)
                            ||'and line_id = '||to_char(myrec.line_id),1);
              END IF;
              raise FND_API.G_EXC_ERROR;
           ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              IF PG_DEBUG <> 0 THEN
              	oe_debug_pub.add('create_cto_item_demand: ' || 'Unexp Error in ato_item_exp procedure for the item_id'
                            ||to_char(myrec.inventory_item_id)
                            ||' and org id...'||to_char(myrec.ship_from_org_id)
                            ||' and line_id = '||to_char(myrec.line_id),1);
              END IF;
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
       END IF;
    END LOOP;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
           WHEN FND_API.G_EXC_ERROR THEN
               ROLLBACK to create_cto_item_demand_begin;
               IF PG_DEBUG <> 0 THEN
               	oe_debug_pub.add('create_cto_item_demand: ' || ' CREATE_CTO_ITEM_DEMAND :: exp error::'|| to_char(lStmtNum)||'::'||sqlerrm,1);
               END IF;
               x_return_status := FND_API.G_RET_STS_ERROR;
               FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,'CREATE_CTO_MODEL_DEMAND');
               FND_MSG_PUB.Count_and_get(
                                         p_count => X_Msg_count,
                                         p_data  => X_Msg_Data);

           WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
               ROLLBACK to create_cto_item_demand_begin;
               IF PG_DEBUG <> 0 THEN
               	oe_debug_pub.add('create_cto_item_demand: ' || ' CREATE_CTO_ITEM_DEMAND :: unexp error::'|| to_char(lStmtNum)||'::'||sqlerrm,1);
               END IF;
               x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
               IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                  FND_MSG_PUB.Add_Exc_Msg(
                                           G_PKG_NAME
                                         , 'CREATE_CTO_MODEL_DEMAND'
                                           );
               END IF;

               FND_MSG_PUB.Count_and_get(
                                         p_count => X_Msg_Count,
                                         p_data  => x_Msg_Data);

           WHEN OTHERS THEN
               ROLLBACK to create_cto_item_demand_begin;
               IF PG_DEBUG <> 0 THEN
               	oe_debug_pub.add('create_cto_item_demand: ' || ' CREATE_CTO_ITEM_DEMAND :: Other error ::'|| to_char(lStmtNum)||'::'||sqlerrm,1);
               END IF;
               x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
               IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                  FND_MSG_PUB.Add_Exc_Msg(
                                           G_PKG_NAME
                                         , 'CREATE_CTO_MODEL_DEMAND'
                                           );
               END IF;

               FND_MSG_PUB.Count_and_get(
                                         p_count => X_Msg_Count,
                                         p_data  => X_Msg_Data);
END CREATE_CTO_ITEM_DEMAND;



/************************************************************************/
PROCEDURE ato_item_exp(p_item_id  mtl_system_items.inventory_item_id%type,
                       p_org_id   mtl_system_items.organization_id%type,
                       p_qty      number,
                       p_req_date date,
                       p_line_id  number,
                       p_header_id number,
                       x_return_status out varchar2,
                       x_msg_count out number,
                       x_msg_data  out varchar2) is
lStmtNum                  Number;
l_request_date            date;
x_lead_time               number;
x_source_org              number;
x_ret_status              varchar2(1);
l_fixed_lead_time         number;
l_variable_lead_time      number;
x_rule_exists             varchar2(1);
v_source_type             number;

       cursor inven_comp is
       SELECT component_item_id,component_quantity
       FROM   bom_inventory_components bic,
              bom_bill_of_materials bom,
              mtl_system_items mtl
       WHERE  bom.assembly_item_id = p_item_id
       AND    bom.organization_id  = x_source_org
       AND    bom.bill_sequence_id = bic.bill_sequence_id
       AND    bic.bom_item_type    = 4
       AND    mtl.inventory_item_id = bic.component_item_id
       AND    mtl.organization_id   = x_source_org
       AND    mtl.base_item_id is not null;
BEGIN

    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add('ato_item_exp: ' || 'In ato_item_exp module...',1);
    	oe_debug_pub.add('ato_item_exp: ' || 'p_item_id    ='||to_char(p_item_id),2);
    	oe_debug_pub.add('ato_item_exp: ' || 'P_org_id     ='||to_char(p_org_id),2);
    	oe_debug_pub.add('ato_item_exp: ' || 'Getting the sourcing information....',2);
    END IF;

    cto_atp_interface_pk.get_model_sourcing_org(p_item_id,
                                                p_org_id,
                                                x_rule_exists,
                                                x_source_org,
                                                v_source_type,
                                                x_lead_time,
                                                x_ret_status);

    IF x_ret_status = FND_API.G_RET_STS_ERROR THEN
       IF PG_DEBUG <> 0 THEN
       	oe_debug_pub.add('ato_item_exp: ' || 'get_model_sourcing_org returned expected error',1);
       END IF;
       raise FND_API.G_EXC_ERROR;
    ELSIF x_ret_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       IF PG_DEBUG <> 0 THEN
       	oe_debug_pub.add('ato_item_exp: ' || 'Get_model_sourcing_org returned unexpected error',1);
       END IF;
       raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add('ato_item_exp: ' || 'Source_flag = '||x_rule_exists,2);
    END IF;

    IF  x_rule_exists = 'F'  THEN
          x_source_org := p_org_id;
          x_lead_time  := 0;
    END IF;

        select nvl(fixed_lead_time,0),nvl(variable_lead_time,0)
         into   l_fixed_lead_time,l_variable_lead_time
         from   mtl_system_items
         where  inventory_item_id = p_item_id
         and    organization_id   = x_source_org;
         x_lead_time := nvl(x_lead_time,0) + l_fixed_lead_time +
                        l_variable_lead_time * p_qty;

--       Calculate the offset date with CalENDer
         IF PG_DEBUG <> 0 THEN
         	oe_debug_pub.add('ato_item_exp: ' || 'Calculating calendar offset....',2);
         END IF;

	 -- Bugfix 3189261 : Changing date offset call

        /*l_request_date := MSC_CALENDAR.DATE_OFFSET(
                             x_source_org,
                             ginstance_id,
                             1,
                             p_req_date,
                             x_lead_time);*/

         l_request_date := MSC_SATP_FUNC.src_date_offset (
                           x_source_org,
                           p_req_date,
                           x_lead_time);

         IF PG_DEBUG <> 0 THEN
         	oe_debug_pub.add('ato_item_exp: ' || 'Calling Create_demand module...',2);
         END IF;

         create_demand(p_item_id,
                       x_source_org,
                       l_request_date,
                       p_qty,
                       p_line_id,
                       p_header_id,
                       x_return_status,
                       x_msg_count,
                       x_msg_data);

         IF PG_DEBUG <> 0 THEN
         	oe_debug_pub.add('ato_item_exp: ' || 'After create_demand Module...',2);
         END IF;

         FOR myrec IN inven_comp
         LOOP

              IF PG_DEBUG <> 0 THEN
              	oe_debug_pub.add('ato_item_exp: ' || 'Inside child record loop...',2);
              END IF;
              ato_item_exp(myrec.component_item_id,
                           x_source_org,
                           p_qty*myrec.component_quantity,
                           l_request_date,
                           p_line_id,
                           p_header_id,
                           x_return_status,
                           x_msg_count,
                           x_msg_data);
         END LOOP;
END ato_item_exp;



PROCEDURE create_demand(p_item_id in number,
                        p_org_id in number,
                        p_req_date in date,
                        p_qty in number,
                        p_line_id in number,
                        p_header_id in number,
                        x_return_status out varchar2,
                        x_msg_count out number,
                        x_msg_data out varchar2)  is
BEGIN
     guserid  := nvl(FND_GLOBAL.user_id,-1);
     gloginid := nvl(FND_GLOBAL.login_id,-1);
/* First level model and Option class rows are inserted in to the bcod table.*/
          insert into
              bom_cto_order_demand(
              bcod_line_id,
              oe_line_id,
              ato_line_id,
              inventory_item_id,
              organization_id,
              required_date,
              required_qty,
              order_quantity_uom,
              parent_demand_type,
              header_id,
              forecast_visible,
              demand_visible,
              created_by,
              last_updated_by,
              last_updated_date,
              last_update_login,
              program_application_id,
              program_update_date)
        select
              BOM_CTO_ORDER_DEMAND_S1.nextval,      -- bcod_line_id
              p_line_id,                            -- oe_line_id
              p_line_id,                            -- ato_line_id
              bic.component_item_id,                -- inventory_item_id
              p_org_id,                             -- organization_id
              p_req_date,                           -- Required_date
              Round( p_qty*bic.component_quantity, 6) ,-- required_qty /* Decimal-Qty Support for Option Items */
              mtl.primary_uom_code,                 -- Order_quantity_uom
              2,                                    -- Parent_demand_type
              p_header_id,                          -- Header_id
              'Y',                                  -- Forecast_visible
              'N',                                  -- Demand_visible
              guserid,                              -- Created_by
              guserid,                              -- Last_updated_by
              sysdate,                              -- Last_updated_date
              gloginid,                             -- Last_update_login
              null,                                 -- Program_application_id
              sysdate
        From
              bom_inventory_components bic,
              bom_bill_of_materials bom,
              mtl_system_items mtl
        where bom.assembly_item_id = p_item_id
        and   bom.organization_id  = p_org_id
        and   bom.bill_sequence_id = bic.bill_sequence_id
        and   bic.bom_item_type in (1,2)
        and   mtl.inventory_item_id= bic.component_item_id
        and   mtl.organization_id  = p_org_id;
/* Insert the option items for the first level models and option classes */
          insert into
              bom_cto_order_demand(
              bcod_line_id,
              oe_line_id,
              ato_line_id,
              inventory_item_id,
              organization_id,
              required_date,
              required_qty,
              order_quantity_uom,
              parent_demand_type,
              header_id,
              forecast_visible,
              demand_visible,
              created_by,
              last_updated_by,
              last_updated_date,
              last_update_login,
              program_application_id,
              program_update_date)
   select
              BOM_CTO_ORDER_DEMAND_S1.nextval,      -- bcod_line_id
              p_line_id,                            -- oe_line_id
              p_line_id,                            -- ato_line_id
              bic.component_item_id,                -- inventory_item_id
              p_org_id,                             -- organization_id
              p_req_date,                           -- Required_date
              Round( p_qty*bic.component_quantity, 6) ,-- required_qty /* Decimal-Qty Support for Option Items */
              mtl.primary_uom_code,                 -- Order_quantity_uom
              2,                                    -- Parent_demand_type
              p_header_id,                          -- Header_id
              'Y',                                  -- Forecast_visible
              'N',                                  -- Demand_visible
              guserid,                              -- Created_by
              guserid,                              -- Last_updated_by
              sysdate,                              -- Last_updated_date
              gloginid,                             -- Last_update_login
              null,                                 -- Program_application_id
              sysdate
   from   bom_inventory_components bic,
          bom_bill_of_materials bom,
          mtl_system_items      mtl
   where  bom.assembly_item_id = p_item_id
   and    bom.organization_id =  p_org_id
   and    bom.bill_sequence_id = bic.bill_sequence_id
   and    bic.bom_item_type = 4
   and    bic.component_item_id  in (
          select
          bic2.component_item_id
   from   bom_bill_of_materials bom1,
          bom_bill_of_materials bom2,
          bom_inventory_components bic1,
          bom_inventory_components bic2
   where  bom1.assembly_item_id = p_item_id
   and    bom1.organization_id  = p_org_id
   and    bom1.bill_sequence_id = bic1.bill_sequence_id
   and    bic1.bom_item_type     in(1, 2)
   and    bom2.assembly_item_id = bic1.component_item_id
   and    bom2.organization_id = p_org_id
   and    bic2.bill_sequence_id = bom2.bill_sequence_id
   and    bic2.bom_item_type  = 4
   and    bic2.optional = 1)
   and    mtl.inventory_item_id  = bic.component_item_id
   and    mtl.organization_id    = p_org_id;
END create_demand;



/****************************************************************************

           For the given item and organization id this procedure will find
           whether it is sourced or not.

*****************************************************************************/
PROCEDURE is_item_sourced(
                        p_item_id in number,
                        p_org_id in number,
                        x_source_flag   out varchar2,
                        x_return_status out varchar2,
                        x_msg_count     out number,
                        x_msg_data      out varchar2)    is

        cursor atoitem is
               select component_item_id
               from   bom_bill_of_materials bom,
                      bom_inventory_components bic,
                      mtl_system_items mtl
               where  bom.assembly_item_id = p_item_id
               and    bom.organization_id  = p_org_id
               and    bom.bill_sequence_id = bic.bill_sequence_id
               and    bic.bom_item_type = 4
               and    mtl.inventory_item_id = bic.component_item_id
               and    mtl.organization_id   = p_org_id
               and    mtl.base_item_id      is not null;
               x_rule_exists              varchar2(1);
               x_source_org               number;
               x_lead_time                number;
               x_ret_status               varchar2(1);
               v_source_type              number;
BEGIN

         IF PG_DEBUG <> 0 THEN
         	oe_debug_pub.add('is_item_sourced: ' || 'Entering is_item_sourced...',2);
         END IF;

         x_source_flag := 'N';

         IF PG_DEBUG <> 0 THEN
         	oe_debug_pub.add('is_item_sourced: ' || 'P_item_id    = '||to_char(p_item_id), 4);
         	oe_debug_pub.add('is_item_sourced: ' || 'p_org_id     = '||to_char(p_org_id), 4);
         END IF;

         cto_atp_interface_pk.get_model_sourcing_org(p_item_id,
                                                     p_org_id,
                                                     x_rule_exists,
                                                     x_source_org,
                                                     v_source_type,
                                                     x_lead_time,
                                                     x_ret_status);

         IF x_ret_status = FND_API.G_RET_STS_ERROR THEN
           IF PG_DEBUG <> 0 THEN
           	oe_debug_pub.add('is_item_sourced: ' || 'get_model_sourcing_org returned expected error',1);
           END IF;
           raise FND_API.G_EXC_ERROR;
         ELSIF x_ret_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           IF PG_DEBUG <> 0 THEN
           	oe_debug_pub.add('is_item_sourced: ' || 'Get_model_sourcing_org returned unexpected error',1);
           END IF;
           raise FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

         IF PG_DEBUG <> 0 THEN
         	oe_debug_pub.add('is_item_sourced: ' || 'source_flag  ='||x_rule_exists, 4);
         END IF;

         IF x_rule_exists = 'T' THEN
             x_source_flag := 'Y';
         ELSE
            FOR myrec IN atoitem
            LOOP
                is_item_sourced( myrec.component_item_id,
                               x_source_org,
                               x_source_flag,
                               x_return_status,
                               x_msg_count,
                               x_msg_data);
                IF x_source_flag = 'Y' THEN
                      x_source_flag := 'Y';
                      exit;
                END IF;
            END LOOP;
         END IF;
END is_item_sourced;


PROCEDURE initialize_session_globals
IS
BEGIN

      g_cto_shipset.delete ;
      gUserId := null ;
      gLoginId := null ;
      g_final_cto_shipset.delete ;
      g_cto_sparse_shipset.delete ;
      g_shipset_status_tbl.delete ;
      local_cto_shipset.delete ;
      g_auto_generated_shipset.delete;
      g_shipset := null  ;
      g_final_shipset := null ;

END initialize_session_globals ;


PROCEDURE initialize_assignment_set ( x_return_status out varchar2 )
IS
BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS ;

   /*
   ** get MRP's default assignment set
   */
   g_stmt_num := 1 ;
   BEGIN

   gMrpAssignmentSet := to_number(FND_PROFILE.VALUE('MRP_DEFAULT_ASSIGNMENT_SET'));
   EXCEPTION
   WHEN others THEN
    raise invalid_mrp_assignment_set ;
   END ;

    g_stmt_num := 5 ;

   IF( gMrpAssignmentSet is null )
   THEN
                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add('initialize_assignment_set: ' || '**$$ Default assignment set is null',  1);
                END IF;

   ELSE
                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add('initialize_assignment_set: ' || '**Default assignment set is '||to_char(gMrpAssignmentSet),1);
                END IF;

                g_stmt_num := 10 ;

                BEGIN

                select assignment_set_name into gMrpAssignmentSetName
                   from mrp_Assignment_sets
                where assignment_set_id = gMrpAssignmentSet ;

                EXCEPTION
                   WHEN no_data_found THEN
                       IF PG_DEBUG <> 0 THEN
                       	oe_debug_pub.add('initialize_assignment_set: ' ||  '**The assignment set pointed by the profile MRP_DEFAULT_ASSIGNMENT_SET does not exist in the database ' ,1);
                       END IF;

                       RAISE INVALID_MRP_ASSIGNMENT_SET ;

                   WHEN others THEN
                       RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                END ;

                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add('initialize_assignment_set: ' || 'Default assignment set name is '|| gMrpAssignmentSetName ,1);
                END IF;
   END IF;

EXCEPTION
   WHEN INVALID_MRP_ASSIGNMENT_SET THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('initialize_assignment_set: ' || 'INITIALIZE_ASSIGNMENT_SET::INVALID ASSIGNMENT SET ::'||to_char(g_stmt_num)||'::'||sqlerrm,1);
        END IF;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('initialize_assignment_set: ' || 'INITIALIZE_ASSIGNMENT_SET::unexp error::'||to_char(g_stmt_num)||'::'||sqlerrm,1);
        END IF;

   WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('initialize_assignment_set: ' || 'INITIALIZE_ASSIGNMENT_SET::others::'||to_char(g_stmt_num)||'::'||sqlerrm,1);
        END IF;

END initialize_assignment_set ;



END CTO_ATP_INTERFACE_PK;

/
