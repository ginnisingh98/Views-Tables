--------------------------------------------------------
--  DDL for Package CTO_AUTO_PROCURE_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CTO_AUTO_PROCURE_PK" AUTHID CURRENT_USER AS
/*$Header: CTOPROCS.pls 120.6.12010000.2 2010/01/11 14:42:38 pdube ship $ */
/*============================================================================+
|  Copyright (c) 1999 Oracle Corporation    Belmont, California, USA          |
|                        All rights reserved.                                 |
|                        Oracle Manufacturing                                 |
+=============================================================================+
|                                                                             |
| FILE NAME   : CTOPROCS.pls                                                  |
| DESCRIPTION:                                                                |
|               Contain all CTO and WF related APIs for AutoCreate Purchase   |
|               Requisitions. This Package creates the following              |
|               Procedures                                                    |
|               1. AUTO_CREATE_PUR_REQ_CR                                     |
|               2. POPULATE_REQ_INTERFACE                                     |
|               Functions                                                     |
|               1. GET_RESERVED_QTY                                           |
|               2. GET_NEW_ORDER_QTY                                          |
| HISTORY     :                                                               |
| 20-Sep-2001 : RaviKumar V Addepalli Initial version                         |
|
|
|13-AUG-2003   Kiran Konada
|               for bug# 3063156
|               Propagate bugfix bugfix 3042904 to main.
|		Chnaged the signature of populate_req_interface
|               to pass project_id and task_id for lower-level buy items
|               Dependent files: CTOWFAPB.pls
|                                CTOPROCB.pls
|                                CTOSUBSB.pls (only for I customers)
|
|
|
||03-NOV-2003    Kiran Konada
|               Main propagation bug#3140641
|
|               revrting bufix 3042904 (main bug 3063156)with  bug#3129117
|               ie have reverted changes made on |13-AUG-2003
|               Removed project_id and task_id as parameters
|               Hence dependency mentioned in 3042904 has been REMOVED
|               ie following files are not dependent as on 13-AUG-2003
|                CTOWFAPB.pls
|                CTOPROCB.pls
|                CTOSUBSB.pls (only for I customers)
|
|01-Jun-2005     Renga Kannan
|                Added NOCOPY hint to all out parameters.
|
=============================================================================*/

-- CTO_AUTO_PROCURE_PK
-- following parameters are created for
   g_pkg_name     CONSTANT  VARCHAR2(30) := 'Test package';
   gMrpAssignmentSet        NUMBER ;


-- rkaza. ireq project. 05/05/2005.
-- A new record for passing source type and org into populate_req_interface.
TYPE req_interface_input_data IS RECORD(
     source_type	 number,
     sourcing_org        number,
     secondary_qty       number, --OPM
     secondary_uom       VARCHAR2 (3) ,--OPM
     grade               VARCHAR2  (25) --OPM
     );


-- rkaza. 05/06/2005. Introduced this procedure for ireq project.
-- Start of comments
-- API name : get_need_by_date
-- Type	    : Public
-- Pre-reqs : None.
-- Function : Given item id, org id, SSD and source type (1 or 3), it returns
--	      need by date for the item. Used for external and internal reqs
-- Parameters:
-- IN	    : p_source_type           	IN NUMBER	Required
--	         1 or 3 (external or internal req).
--	      p_item_id			IN NUMBER 	Required
--	      p_org_id			IN NUMBER 	Required
--		 ship from org id
-- Version  : Current version	115.20
--	         Added this description
--	      Initial version 	115.17
-- End of comments

PROCEDURE get_need_by_date(p_source_type IN NUMBER,
                          p_item_id IN NUMBER,
                          p_org_id  IN NUMBER,
                          p_schedule_ship_date IN DATE,
                          x_need_by_date OUT NOCOPY DATE,
                          x_return_status OUT NOCOPY VARCHAR2);


-- rkaza. ireq project. 05/05/2005.
-- Added new conc program parameter p_create_req_type that specifies whether
-- to create internal or external reqs or both.
-- This parameter will have a default null for backward compatibility in case
-- of prescheduled program runs without this parameter.

/**************************************************************************
   Procedure:   AUTO_CREATE_PUR_REQ_CR
   Parameters:  p_sales_order             NUMBER    -- Sales Order number.
                p_dummy_field             VARCHAR2  -- Dummy field for the Concurrent Request.
                p_sales_order_line_id     NUMBER    -- Sales Order Line number.
                p_organization_id         VARCHAR2  -- Ship From Organization ID.
                current_organization_id   NUMBER    -- Current Org ID
                p_offset_days             NUMBER    -- Offset days.
		p_create_req_type         NUMBER  -- specifies whether to create ext and int reqs or both (1,2,3 respectively).

   Description: This procedure is called from the concurrent progran to run the
                AutoCreate Purchase Requisitions.
*****************************************************************************/
PROCEDURE auto_create_pur_req_cr (
           errbuf              OUT   NOCOPY VARCHAR2,
           retcode             OUT   NOCOPY VARCHAR2,
           p_sales_order             NUMBER,
           p_dummy_field             VARCHAR2,
           p_sales_order_line_id     NUMBER,
           p_organization_id         VARCHAR2,
           current_organization_id   NUMBER, -- VARCHAR2,
           p_offset_days             NUMBER,
	   p_create_req_type         NUMBER default null);



-- rkaza. 05/05/2005. Added new parameter of type req_interface_input_data
-- record. This is for passing source_type and source_org.
/**************************************************************************
   Procedure:   POPULATE_REQ_INTERFACE
   Parameters:  p_destination_org_id		NUMBER   -- PO Destination Org ID
                p_org_id                    NUMBER   --
                p_created_by            	NUMBER   -- Created By for preparor ID
                p_need_by_date              DATE     -- Need by date
                p_order_quantity	        NUMBER   -- Order Quantity
                p_order_uom                 VARCHAR2 -- Order Unit Of Measure
                p_item_id                   NUMBER   -- Inventory Item Id on the SO line.
                p_item_revision             VARCHAR2 -- Item Revisionon the SO Line.
                p_interface_source_line_id	NUMBER   -- Interface Source Line ID
                p_unit_price                NUMBER   -- Unit Price on the SO Line.
                p_batch_id                  NUMBER   -- Batch ID for the Req-Import
                p_order_number              VARCHAR2 -- Sales Order Number.
		p_req_interface_input_data  req_interface_input_data -- a record structure for any other IN parameters
                x_return_status      OUT    VARCHAR2 -- Return Status.

   Description: This procedure is called from the concurrent program
                and the Workflow to create the records in the
                req-interface table based on the line ID passed in to these procedures.
*****************************************************************************/
PROCEDURE populate_req_interface(
            p_interface_source_code      VARCHAR2,    --added this parameter for mlsupply enhancemnet , kkonada
            p_destination_org_id		NUMBER,
            p_org_id                    NUMBER,
            p_created_by            	NUMBER,
            p_need_by_date              DATE,
            p_order_quantity	        NUMBER,
            p_order_uom                 VARCHAR2,
            p_item_id                   NUMBER,
            p_item_revision             VARCHAR2,
            p_interface_source_line_id	NUMBER,
            p_unit_price                NUMBER,
            p_batch_id                  NUMBER,
            p_order_number              VARCHAR2,
            p_req_interface_input_data  req_interface_input_data,
            x_return_status      OUT NOCOPY   VARCHAR2  );

/**************************************************************************
   Function     : GET_RESERVED_QTY
   Parameters   : p_line_id  NUMBER
   Return Value : Number
   Description  : This procedure is called from the concurrent program to
                  get the the reserved quantity on the sales Order line.
*****************************************************************************/
FUNCTION get_reserved_qty (
            p_line_id                 NUMBER) RETURN NUMBER;


/**************************************************************************
   Function     : GET_NEW_ORDER_QTY
   Parameters   : p_interface_source_line_id   NUMBER -- Sales Order Linae ID.
                  p_order_qty                  NUMBER -- Sales Order Order_quantity.
                  p_cancelled_qty              NUMBER -- Sales Order Cancelled_quantity.
                  p_interface_qty              NUMBER DEFAULT NULL
                                                      -- qty from po_req_interface_all
   Return Value : Number
   Description  : This procedure is called from the concurrent program to
                  get the the quantity to be reserved for the demand.
*****************************************************************************/
-- Fix for performance bug 4897231
-- Added a new parameter p_item_id to use
-- in po_requisitions_interface table where clause

FUNCTION get_new_order_qty (
                    p_interface_source_line_id   NUMBER,
                    p_order_qty                  NUMBER,
                    p_cancelled_qty              NUMBER,
                    p_interface_qty              NUMBER  DEFAULT NULL, --7559710
		    p_item_id                    NUMBER)
        RETURN NUMBER;




PROCEDURE check_order_line_status (
               p_line_id            NUMBER,
               p_flow_status    OUT NOCOPY VARCHAR2,
               p_inv_qty        OUT NOCOPY NUMBER,
               p_po_qty         OUT NOCOPY NUMBER,
               p_req_qty        OUT NOCOPY NUMBER);



-- Added by Renga For purchase doc creation module



Type buy_components_rec is record (
                	inventory_item_id   bom_cto_order_lines.inventory_item_id%type,
                	line_id             bom_cto_order_lines.line_id%type,
                        ato_line_id         bom_cto_order_lines.ato_line_id%type,
                        ordered_quantity    bom_cto_order_lines.ordered_quantity%type,
                        order_quantity_uom  bom_cto_order_lines.order_quantity_uom%type,
                        ship_from_org_id    bom_cto_order_lines.ship_from_org_id%type,
                        wip_supply_type     bom_cto_order_lines.wip_supply_type%type,
                	bom_item_type       bom_cto_order_lines.bom_item_type%type,
                	primary_uom_code    mtl_system_items.primary_uom_code%type,
                	list_price_per_unit mtl_system_items.list_price_per_unit%type,
                	config_item_id      bom_cto_order_lines.config_item_id%type,
                	qty_per             Number,
			model_line	    Varchar2(1));

Type buy_components_tbl is table of buy_components_rec index by  binary_integer;


Type Oper_unit_rec is record
				(Oper_unit	Number);

Type oper_unit_tbl is table of oper_unit_rec index by binary_integer;


G_oper_unit_list       oper_unit_tbl;
G_oper_unit_list_null  oper_unit_tbl;

Procedure  Create_Purchasing_Doc(
                                P_config_item_id       IN            Number,
                                p_overwrite_list_price IN            Varchar2 default 'N',
                                p_called_in_batch      IN            Varchar2 default 'N',
                                p_batch_number         IN OUT NOCOPY Number,
				p_mode                 IN            Varchar2 Default 'ORDER',
				p_ato_line_id          IN            Number   Default null,
                                x_oper_unit_list       IN OUT NOCOPY cto_auto_procure_pk.oper_unit_tbl,
                                x_return_status        OUT    NOCOPY Varchar2,
                                x_msg_count            OUT    NOCOPY Number,
                                x_msg_data             OUT    NOCOPY Varchar);


Procedure  Rollup_list_price (
                p_config_item_id in          Number,
                p_group_id       in          Number,
                p_org_id         in          Number,
                x_rolled_price   out NOCOPY  Number,
                x_return_status  out NOCOPY  varchar2,
                x_msg_count      out NOCOPY  number,
                x_msg_data       out NOCOPY  varchar2);

Procedure  Rollup_purchase_price (
                p_config_item_id in            Number,
                p_batch_id       in out NOCOPY Number,
                p_group_id       in            Number,
		p_mode           in            Varchar2 Default 'ORDER',
		p_line_id        in            Number,
                x_oper_unit_list in out NOCOPY cto_auto_procure_pk.oper_unit_tbl,
                x_return_status  out    NOCOPY varchar2,
                x_msg_count      out    NOCOPY number,
                x_msg_data       out    NOCOPY varchar2);

Procedure rollup_blanket_price(
                      p_config_item_id in  number,
                      p_doc_header_id  in  number,
		      p_doc_line_id    in  number,
                      p_group_id       in  number,
                      p_po_valid_org   in  number,
   		      p_mode           IN  Varchar2 Default 'ORDER',
                      x_rolled_price   out NOCOPY number,
                      x_return_status  out NOCOPY varchar2,
                      x_msg_count      out NOCOPY number,
                      x_msg_data       out NOCOPY varchar2);

/** fp-J: Added several new parameters as part of optional processing */

PROCEDURE Create_purchase_doc_batch (
           errbuf        OUT  NOCOPY VARCHAR2,
           retcode       OUT  NOCOPY varchar2,
           p_sales_order             NUMBER,
	   p_dummy_field             VARCHAR2,
           p_sales_order_line_id     NUMBER,
           p_organization_id         VARCHAR2,
	   p_dummy_field1            VARCHAR2,
           p_offset_days             NUMBER,
	   p_overwrite_list_price    varchar2,
	   p_config_id		     NUMBER   DEFAULT NULL,
	   p_dummy_field2	     VARCHAR2 DEFAULT NULL,
	   p_base_model_id	     NUMBER   DEFAULT NULL,
	   p_created_days_ago	     NUMBER   DEFAULT NULL,
	   p_load_type		     NUMBER   DEFAULT NULL,
	   p_upgrade		     NUMBER   DEFAULT 2,
	   p_perform_rollup	     NUMBER   DEFAULT 1);


Procedure Submit_pdoi_conc_prog(
                                p_oper_unit_list     In         cto_auto_procure_pk.oper_unit_tbl,
                                p_batch_id           In         Number,
                                x_return_status      Out NOCOPY Varchar2,
                                x_msg_count          Out NOCOPY Number,
                                x_msg_data           Out NOCOPY Varchar2);


END cto_auto_procure_pk;

/
