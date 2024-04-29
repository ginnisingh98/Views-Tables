--------------------------------------------------------
--  DDL for Package CTO_RESERVE_CONFIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CTO_RESERVE_CONFIG" AUTHID CURRENT_USER as
/* $Header: CTORCFGS.pls 120.1 2005/06/16 16:23:02 appldev  $ */
/*============================================================================+
|  Copyright (c) 1993 Oracle Corporation    Belmont, California, USA          |
|                        All rights reserved.                                 |
|                        Oracle Manufacturing                                 |
+=============================================================================+
|            					                              |
| FILE NAME   : CTORCFGS.pls                     		              |
| DESCRIPTION :                                                               |
|               This file creates packaged functions that are required        |
|               to make a reservation against Inventory from the              |
|               Create Reservation workflow activity and the                  |
|               Match and Reserve menu item.                                  |
|                                                                             |
|               reserve_config - Called from CTOWKFLB.pls from                |
|               reserve_config_wf to reserve configuration items              |
|                from inventory and from reserve_work_order_wf to             |
|                reserve a work order to a sales order.                       |
|                                                                             |
| HISTORY     :  					                      |
|               May 13, 99  Angela Makalintal   Initial version		      |
|									      |
|	Oct 25 '02	Kundan Sarkar	Bugfix 2644849 ( 2620282 in branch )  |
|			Add new column f_bom_revision in rec_reserve record   |
=============================================================================*/

/*****************************************************************************
   Function:  reserve_config
   Parameters:  model_line_id   - line id of the top model in oe_order_lines
                match_config_id - config id of the matching configuration
                                  from bom_ato_configurations
                error_message   - error message if match function fails
                message_name    - name of error message if match function fails

   Description:  This function looks for a configuration in
                 bom_ato_configurations that matches the ordered
                 configuration in oe_order_lines.

*****************************************************************************/
  TYPE rec_reserve IS RECORD (
             f_header_id          number,
             f_line_id            oe_order_lines.line_id%TYPE,
             f_mfg_org_id         oe_order_lines.ship_from_org_id%TYPE,
             f_item_id            oe_order_lines.inventory_item_id%TYPE,
             f_order_qty_uom      oe_order_lines.order_quantity_uom%TYPE,
             f_quantity           number,
             f_supply_source      number,
             f_supply_header_id   number,
             f_ship_date          oe_order_lines.schedule_ship_date%TYPE,
             f_source_document_type_id  oe_order_headers.source_document_type_id%TYPE default NULL,
		-- bugfix 1799874: added f_source_document_type_id
	     f_bom_revision	  mtl_item_revisions.revision%TYPE
	     	-- 2620282 : Add new column to store bom revision
        );




procedure reserve_config(
        p_rec_reserve      in   rec_reserve,
        x_rsrv_qty         out  nocopy number,
        x_rsrv_id          out  nocopy number,
        x_return_status    out  nocopy VARCHAR2,
        x_msg_txt          out  nocopy VARCHAR2,  /* 70 bytes to hold returned msg */
        x_msg_name         out  nocopy VARCHAR2 /* 30 bytes to hold returned name */
	);


end CTO_RESERVE_CONFIG;

 

/
