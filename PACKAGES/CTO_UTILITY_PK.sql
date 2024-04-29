--------------------------------------------------------
--  DDL for Package CTO_UTILITY_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CTO_UTILITY_PK" AUTHID CURRENT_USER as
/* $Header: CTOUTILS.pls 120.6.12010000.2 2008/08/14 11:30:05 ntungare ship $*/
/*----------------------------------------------------------------------------+
| Copyright (c) 1993 Oracle Corporation    Belmont, California, USA
|                       All rights reserved.
|                       Oracle Manufacturing
|
|FILE NAME   : CTOUTILS.pls
|
|DESCRIPTION : Contains modules to :
|		1. Populate temporary tables bom_cto_order_lines and
|		bom_cto_src_orgs, used for intermediate CTO processing
|		2. Update these tables with the config_item_id
|		3. Copy sourcing rule assignments from model to config item
|
|HISTORY     : Created on 04-MAY-2000  by Sajani Sheth
|              06/18/01                by Renga Kannan
|                                         Get_model_sourcing_org API is moved
|                                         from CTOATPIB.pls to keep the dependency
|                                         minimal.
|              Modified on 22-JUN-2001 by Shashi Bhaskaran : bugfix 1811007
|                                         Added a new function convert_uom for wt/vol
|                                         calculation.
|              Modified on 18-JUL-2001 by Shashi Bhaskaran : bugfix 1799874
|                                         Added a new function get_source_document_id
|
|              Modified on 04-NOV-2001 by Shashi Bhaskaran : bugfix 2001894
|                                         Added a new function check_rsv_quantity
|
|             Modified on 27-MAR-2002  by Kiran Konada
|                                         changed the signature of GENERATE_BOM_ATTACH_TEXT
|                                         removed the signature for GENERATE_ROUTING_ATTACH_TEXT
|                                         above changes have been made as part of patchset-H
|                                         to be in sync with decisions made for cto-isp page
|
|             Modified on 04-JUN-2002  by Kiran Konada--bugfix 2327972
|                                         added a new procedure chk_all_rsv_details.
|                                         This procedure gets all the types of reservation
|                                         (supply). The reservation details are store in
|                                         a table of records
|                                         record structure = r_resv_details
|                                         table structure  = t_resv_details
|
|             Modified on 16-SEP-2002  by Sushant Sawant- copied bugfix for 2474865 from G branch
|                                         Added procedure isModelMLMO
|
|
|
|		16-Jun-2005		Kiran Konada
|			     Changed signaturre of check_cto_can_create_supply
|			     comment string : OPM
|
|               29-Jun-2005   Renga Kannan
|                             Added a procedure spec for Cross-dock project
|
+-----------------------------------------------------------------------------*/

  PC_BOM_PROGRAM_ID     number := 1100 ;
  PC_BOM_VALIDATION_ORG number ; /* This global will be set by preconfigure bom process */
  PC_BOM_CURRENT_ORG number ; /* This global will be set by preconfigure bom process */
  PC_BOM_BILL_SEQUENCE_ID number ; /* This global will be set by preconfigure bom process */
  PC_BOM_TOP_BILL_SEQUENCE_ID number ; /* This global will be set by preconfigure bom process */


  /* ERROR CODES FOR CTO EXCEPTION NOTIFICATION */

  OPT_DROP_AND_ITEM_CREATED          number := 1 ;
  OPT_DROP_AND_ITEM_NOT_CREATED      number := 2 ;
  EXP_ERROR_AND_ITEM_CREATED         number := 3 ;
  EXP_ERROR_AND_ITEM_NOT_CREATED     number := 4 ;





TYPE EXPECTED_ERROR_INFO_TYPE is record (
                            PROCESS              varchar2(100)
                           ,LINE_ID              number
                           ,SALES_ORDER_NUM      number
                           ,ERROR_MESSAGE        varchar2(2000)
                           ,TOP_MODEL_NAME       varchar2(1000)
                           ,TOP_MODEL_LINE_NUM   varchar2(100)
                           ,TOP_CONFIG_NAME      varchar2(1000)
                           ,TOP_CONFIG_LINE_NUM  varchar2(100)
                           ,PROBLEM_MODEL        varchar2(100)
                           ,PROBLEM_MODEL_LINE_NUM varchar2(100)
                           ,PROBLEM_CONFIG        varchar2(1000)
                           ,ERROR_ORG             varchar2(100)
                           ,ERROR_ORG_ID          number
                           ,REQUEST_ID            varchar2(100)
                           , NOTIFY_USER          varchar2(1000) ) ;


TYPE t_expected_error_info_type  IS TABLE OF EXPECTED_ERROR_INFO_TYPE INDEX BY BINARY_INTEGER;


g_t_expected_error_info   t_expected_error_info_type ;


/*--------------------------------------------------------------------------+
This function identifies the model items for which configuration items need
to be created and populates the temporary table bom_cto_src_orgs with all the
organizations that each configuration item needs to be created in.
+-------------------------------------------------------------------------*/
FUNCTION Populate_Src_Orgs( pTopAtoLineId in number,
				x_return_status	out NOCOPY varchar2,
				x_msg_count	out NOCOPY number,
				x_msg_data	out NOCOPY varchar2)
RETURN integer;


/*--------------------------------------------------------------------------+
This function populates the table bom_cto_src_orgs with all the organizations
in which a configuration item needs to be created.
The organizations include all potential sourcing orgs, receiving orgs,
OE validation org and PO validation org.
The line_id, rcv_org_id, organization_id combination is unique.
It is called by Populate_Src_Orgs.
+-------------------------------------------------------------------------*/
FUNCTION Get_All_Item_Orgs( pLineId in number,
				pModelItemId in number,
				pRcvOrgId  in number,
				x_return_status	out NOCOPY varchar2,
				x_msg_count	out NOCOPY number,
				x_msg_data	out NOCOPY varchar2)
RETURN integer;


/*--------------------------------------------------------------------------+
This function updates table bom_cto_order_lines with the config_item_id for
a given model item.
It is called by "Match" and "Create_Item" programs.
+-------------------------------------------------------------------------*/
FUNCTION Update_Order_Lines(pLineId	in 	number,
			pModelId	in	number,
			pConfigId	in	number)
RETURN integer;


/*--------------------------------------------------------------------------+
This function updates table bom_cto_src_orgs with the config_item_id for
a given model item.
It is called by "Match" and "Create_Item" programs.
+-------------------------------------------------------------------------*/
FUNCTION Update_Src_Orgs(pLineId	in 	number,
			pModelId	in	number,
			pConfigId	in	number)
RETURN integer;


/*--------------------------------------------------------------------------+
This procedure creates sourcing information for a configuration item.
It copies the sourcing rule assignment of the model into the configuration
item and adds this assignment to the MRP default assignment set.
+-------------------------------------------------------------------------*/
PROCEDURE Create_Sourcing_Rules(pModelItemId	in	number,
				pConfigId	in	number,
				pRcvOrgId	in	number,
				x_return_status	out NOCOPY varchar2,
				x_msg_count	out NOCOPY number,
				x_msg_data	out NOCOPY varchar2);


/*--------------------------------------------------------------------------+
This procedure populates information in bom_cto_order_lines table.
It assigns plan level, parent ato line id to each record after copying all
components related to a specific top level item.
+-------------------------------------------------------------------------*/
PROCEDURE POPULATE_BCOL
( p_bcol_line_id        bom_cto_order_lines.line_id%type,
  x_return_status   out NOCOPY   varchar2,
  x_msg_count       out NOCOPY  number,
  x_msg_data        out NOCOPY  varchar2,
  p_reschedule      in    varchar2 default 'N') ;


-- The followin API get_model_sourcing_org is added by Renga Kannan as part of moving this
-- API from CTOATPIB.pls to CTOUTILB.pls
-- This is added on 06/18/2001


PROCEDURE get_model_sourcing_org(
  p_inventory_item_id    NUMBER
, p_organization_id      NUMBER
, p_sourcing_rule_exists out NOCOPY varchar2
, p_sourcing_org         out NOCOPY NUMBER
, p_source_type          out NOCOPY NUMBER   --- Added by Renga for BUY MODEL
, p_transit_lead_time    out NOCOPY NUMBER
, x_return_status        out NOCOPY varchar2
, x_exp_error_code       out NOCOPY number
, p_line_id              in number default null
, p_ship_set_name        in varchar2 default null
) ;


PROCEDURE query_sourcing_org(
  p_inventory_item_id    NUMBER
, p_organization_id      NUMBER
, p_sourcing_rule_exists out NOCOPY varchar2
, p_source_type          out NOCOPY NUMBER    -- Added by Renga Kannan on 08/21/01
, p_sourcing_org         out NOCOPY NUMBER
, p_transit_lead_time    out NOCOPY NUMBER
, x_exp_error_code       out NOCOPY NUMBER
, x_return_status        out NOCOPY varchar2
);



-- bugfix 1811007 begin
-- Added a new function convert_uom
--
-- Procedure:   Convert_Uom
-- Parameters:  from_uom - Uom code to convert from
--              to_uom   - Uom code to convert to
--              quantity - quantity to convert
--              item_id  - inventory item id
-- Description: This procedure will convert quantity from one Uom to another by
--              calling an inventory convert uom procedure
--

FUNCTION convert_uom(from_uom IN VARCHAR2,
                     to_uom IN VARCHAR2,
                     quantity IN NUMBER,
                     item_id IN NUMBER DEFAULT NULL) RETURN NUMBER;

-- The following pragma is used to allow convert_uom to be used in a select statement
-- WNDS : Write No Database State (does not allow tables to be altered)

pragma restrict_references (convert_uom, WNDS);

-- bugfix 1811007 end


--bugfix 1799874 : Added function get_source_document_id to fetch the source_document_id
FUNCTION get_source_document_id (pLineId in number) RETURN NUMBER;


--begin bugfix 2001824
/*-------------------------------------------------------------------------+
  bugfix 2001824 : Added function check_rsv_quantity to check if the quantity
		   being unreserved is okay or not.
		   If the qty passed by INV is more than "unshipped" quantity,
		   error out.
  Parameters :     p_order_line_id    : order line id
                   p_rsv_quantity     : Unreserve Qty
+--------------------------------------------------------------------------*/
 FUNCTION check_rsv_quantity (p_order_line_id  IN NUMBER,
			      p_rsv_quantity   IN NUMBER ) RETURN BOOLEAN ;

 --end bugfix 2001824


PROCEDURE CREATE_ATTACHMENT(
                             p_item_id        IN mtl_system_items.inventory_item_id%type,
                             p_org_id         IN mtl_system_items.organization_id%type,
                             p_text           IN Long,
                             p_desc           IN varchar2,
                             p_doc_type       In Varchar2,
                             x_return_status  OUT NOCOPY varchar2);


PO_VALIDATION_ORG            mtl_system_items.organization_id%type;



PROCEDURE  GENERATE_BOM_ATTACH_TEXT
                                   (p_line_id          bom_cto_src_orgs.line_id%type ,
                                    x_text          in out NOCOPY long,
                                    x_return_status    out NOCOPY Varchar2
                                    );


FUNCTION CHECK_CONFIG_ITEM(
                           p_parent_item_id     IN Mtl_system_items.inventory_item_id%type,
                           p_inventory_item_id  IN Mtl_system_items.inventory_item_id%type,
                           p_organization_id    IN Mtl_system_items.organization_id%type) RETURN Varchar2;

/*---------------------------------------------------------------------------------------------
Procedure : chk_all_rsv_details --bugfix 2327972
Description: This procedure gets the different types of reservation done on a line_id (item)
             When a reservation exists,It returns success and reservation qunatity, reservation id and type of              supply are stored in table of records.
Input:  p_line_Id        in         --line_id
        p_rsv_details    out        --table of records
        x_msg_count      out
        x_msg_data       out
        x_return_status  out        -returns 'S' if reservation exists
                                    --returns 'F' if there is no reservation

-----------------------------------------------------------------------------*/

TYPE r_resv_details IS RECORD(
                                  l_reservation_id    NUMBER,
                                  l_reservation_quantity      NUMBER,
                                 l_supply_source_type_id   NUMBER);

TYPE t_resv_details  IS TABLE OF r_resv_details INDEX BY BINARY_INTEGER;


Procedure chk_all_rsv_details
(
         p_line_id          in     number    ,
         p_rsv_details    out NOCOPY t_resv_details,
         x_msg_count     out  NOCOPY number  ,
         x_msg_data       out NOCOPY varchar2,
         x_return_status out NOCOPY varchar2
);





FUNCTION isModelMLMO( p_bill_sequence_id in number )
return number ;


FUNCTION create_isp_bom
(p_item_id IN number,
p_org_id IN number)
RETURN NUMBER;

FUNCTION concat_values(
p_value1 IN varchar2,
p_value2 IN number)
RETURN Varchar2;

procedure copy_cost(
                             p_src_cost_type_id   number
                           , p_dest_cost_type_id   number
                           , p_config_item_id number
                           , p_organization_id   number
) ;


--This procedure checks if pllanning needs to create supply
--or CTO can create supply
--x_can_create_supply = Y : CTO
--  = N : Planning
--Calls
--1. custom API Check_supply
--2. query sourcing org
--added by KKONADA
PROCEDURE check_cto_can_create_supply (
	P_config_item_id	IN   number,
	P_org_id		IN   number,
	x_can_create_supply     OUT  NOCOPY Varchar2,
	--p_source_type           OUT  NOCOPY Varchar2,
        p_source_type           OUT  NOCOPY number,  --Bugfix 6470516
	x_return_status         OUT  NOCOPY varchar2,
	X_msg_count		OUT  NOCOPY   number,
	X_msg_data		OUT  NOCOPY   Varchar2,
	x_sourcing_org          OUT  NOCOPY NUMBER, --R12 OPM
	x_message		OUT  NOCOPY varchar2 --R12 OPM


 );




procedure split_line (
p_ato_line_id  in number,
x_return_status         OUT  nocopy varchar2,
x_msg_count             OUT  nocopy number,
x_msg_data              OUT  nocopy Varchar2
);



procedure adjust_bcol_for_split(
p_ato_line_id   in number ,
x_return_status out nocopy varchar2,
x_msg_count     out nocopy number,
x_msg_data      out nocopy varchar2
);

procedure adjust_bcol_for_warehouse(
p_ato_line_id   in number ,
x_return_status out nocopy varchar2,
x_msg_count     out nocopy number,
x_msg_data      out nocopy varchar2
);



  PROCEDURE  Reservation_Exists(
                               Pconfiglineid    in      number,
                               x_return_status  out nocopy    varchar2,
                               x_result         out nocopy    boolean,
                               X_Msg_Count      out nocopy    number,
                               X_Msg_Data       out nocopy    varchar2);





procedure copy_bcolgt_bcol(     p_ato_line_id   in      number,
                                x_return_status out     NOCOPY varchar2,
                                x_msg_count     out     NOCOPY number,
                                x_msg_data      out     NOCOPY varchar2) ;

procedure copy_bcol_bcolgt(      p_ato_line_id   in      number,
                                x_return_status out     NOCOPY varchar2,
                                x_msg_count     out     NOCOPY number,
                                x_msg_data      out     NOCOPY varchar2) ;



procedure send_notification(
                            P_PROCESS                       in    varchar2
                           ,P_LINE_ID                       in    number
                           ,P_SALES_ORDER_NUM               in    number
                           ,P_ERROR_MESSAGE                 in    varchar2
                           ,P_TOP_MODEL_NAME                in    varchar2
                           ,P_TOP_MODEL_LINE_NUM            in    varchar2
                           ,P_TOP_CONFIG_NAME               in    varchar2
                           ,P_TOP_CONFIG_LINE_NUM           in    varchar2
                           ,P_PROBLEM_MODEL                 in    varchar2
                           ,P_PROBLEM_MODEL_LINE_NUM        in    varchar2
                           ,P_PROBLEM_CONFIG                in    varchar2
                           ,P_ERROR_ORG                     in    varchar2
                           ,P_NOTIFY_USER                   in    varchar2
                           ,P_REQUEST_ID                    in    varchar2
                           ,P_MFG_REL_DATE                  in    date default null
);

procedure notify_expected_errors ( P_PROCESS                       in    varchar2
                           ,P_LINE_ID                       in    number
                           ,P_SALES_ORDER_NUM               in    number
                           ,P_TOP_MODEL_NAME                in    varchar2
                           ,P_TOP_MODEL_LINE_NUM            in    varchar2
                           ,P_MSG_COUNT                     in    number
                           ,P_NOTIFY_USER                   in    varchar2
                           ,P_REQUEST_ID                    in    varchar2
                           ,P_ERROR_MESSAGE                 in    varchar2 default null
                           ,P_TOP_CONFIG_NAME               in    varchar2 default null
                           ,P_TOP_CONFIG_LINE_NUM           in    varchar2 default null
                           ,P_PROBLEM_MODEL                 in    varchar2 default null
                           ,P_PROBLEM_MODEL_LINE_NUM        in    varchar2 default null
                           ,P_PROBLEM_CONFIG                in    varchar2 default null
                           ,P_ERROR_ORG                     in    varchar2 default null
) ;

/* activity hold for create config */
PROCEDURE APPLY_CREATE_CONFIG_HOLD( p_line_id        in  number
                                  , p_header_id      in  number
                                  , x_return_status  out NOCOPY varchar2
                                  , x_msg_count      out NOCOPY number
                                  , x_msg_data       out NOCOPY varchar2)  ;



procedure handle_expected_error( p_error_type           in number
                     , p_inventory_item_id    in number
                     , p_organization_id      in number
                     , p_line_id              in number
                     , p_sales_order_num      in number
                     , p_top_model_name       in varchar2
                     , p_top_model_line_num   in varchar2
                     , p_top_config_name       in varchar2 default null
                     , p_top_config_line_num   in varchar2 default null
                     , p_msg_count            in number
                     , p_planner_code         in varchar2
                     , p_request_id           in varchar2
                     , p_process              in varchar2 ) ;


 procedure get_planner_code( p_inventory_item_id   in number
                         , p_organization_id     in number
                         , x_planner_code        out NOCOPY fnd_user.user_name%type ) ;


procedure send_oid_notification ;


Procedure Create_item_attachments(
                                   p_ato_line_id     in    Number,
                                   x_return_status   out nocopy  Varchar2,
                                   x_msg_count       out nocopy  Number,
                                   x_msg_data        out nocopy  Varchar2);

--
-- bugfix 4227993: Added lock_for_match procedure for acquiring user-locks for match
--
--
-- bug 7203643
-- changed the hash value variable type to varchar2
-- ntungare
--
PROCEDURE lock_for_match(
			x_return_status	OUT nocopy varchar2,
        		xMsgCount       OUT nocopy number,
        		xMsgData        OUT nocopy varchar2,
			x_lock_status	OUT nocopy number,
    		        x_hash_value	OUT nocopy varchar2,
			p_line_id	IN  number);
--
-- bug 7203643
-- changed the hash value variable type to varchar2
-- ntungare
--
PROCEDURE release_lock(
     x_return_status        OUT NOCOPY VARCHAR2
   , x_msg_count            OUT NOCOPY NUMBER
   , x_msg_data             OUT NOCOPY VARCHAR2
   , p_hash_value	    IN  varchar2);



  -- bugfix 4044709: Created new validation procedure
  PROCEDURE validate_oe_data (  p_bcol_line_id  in      bom_cto_order_lines.line_id%type,
                                x_return_status out NOCOPY varchar2);



FUNCTION get_cto_item_attachment(p_item_id in number,
		                 p_po_val_org_id in number,
				 x_return_status out NOCOPY varchar2)
RETURN clob;


-- Added for Cross Docking Project

TYPE cur_var_type is RECORD  (
                 primary_reservation_quantity   Number,
		 secondary_reservation_quantity Number,--opm and ireq
		 supply_source_type_id          Number
		  );

TYPE resv_tbl_rec_type is TABLE OF cur_var_type INDEX BY Binary_integer;

-- The following constants are mimicking demand source type ids
-- in inv_reservation_global package for flow qty, ext req interface rec qty,
-- int req interface qty. It will be used in get_resv_qty_and_code procedure.

g_source_type_flow             CONSTANT NUMBER := 1000 ;
g_source_type_ext_req_if       CONSTANT NUMBER := 1001 ;
g_source_type_int_req_if       CONSTANT NUMBER := 1003 ;


/*******************************************************************************************
-- API name : get_resv_qty
-- Type     : Public
-- Pre-reqs : None.
-- Function : Given config/ato item Order line id  it returns
--            the supply details tied to this line in a record structure. Also, it return the
              total supply qty in primary uom and pass the primary uom code to the calling module.
-- Parameters:
-- IN       : p_order_line_id     Expects the config/ato item order line       Required
--
-- OUT      : x_rsv_rec           Record strcutre with each supply type
                                  and supply qty in primary uom
	      x_primary_uom_code  Primary uom code of the order line's
	                          inventory item id .
	      x_sum_rsv_qty       Sum of supply quantities tied to the
	                          order line in primary uom.
	      x_return_status     Standard error message status
	      x_msg_count         Std. error message count in the message stack
	      x_msg_data          Std. error message data in the message stack
-- Version  :
--
--
******************************************************************************************/
PROCEDURE Get_Resv_Qty
               (
		 p_order_line_id                      NUMBER,
		 x_rsv_rec               OUT NOCOPY   CTO_UTILITY_PK.resv_tbl_rec_type,
		 x_primary_uom_code      OUT NOCOPY   VARCHAR2,
		 x_sum_rsv_qty	         OUT NOCOPY   NUMBER,
                 x_return_status         OUT NOCOPY   VARCHAR2,
		 x_msg_count	         OUT NOCOPY   NUMBER,
                 x_msg_data	         OUT NOCOPY   VARCHAR2
	        );


END CTO_UTILITY_PK;

/
