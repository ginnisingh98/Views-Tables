--------------------------------------------------------
--  DDL for Package CTO_WORKBENCH_UTIL_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CTO_WORKBENCH_UTIL_PK" AUTHID CURRENT_USER as
/* $Header: CTOWBUTS.pls 120.6 2006/07/28 00:52:07 rekannan noship $ */
/********************************************************************************************************
|   Copyright (c) 1993 Oracle Corporation Belmont, California, USA                                      |
|                         All rights reserved,                                                          |
|                         Oracle Manufacturing                                                          |
|   File Name           : CTOWBUTS.pls                                                                |
|                                                                                                       |
|   Description         :  This is the Utility pkg for CTO workbench. CTO work bench is the             |
|                          Self service application and we need lot of funtions to call in the sql      |
|                          This file is not having any other product dependency.                        |
|   History             : Created on 11-NOV-2002 by Renga Kannan                                        |
********************************************************************************************************/


-- rkaza. ireq project. 06/30/2005. Used to cache config_line_ids given
-- ato_line_id.
TYPE config_line_id_tbl_type is TABLE OF number  INDEX BY Binary_integer;
config_line_id_tbl config_line_id_tbl_type;


/* This function will get the order line number as displayed in the OM form
*/

FUNCTION get_line_number
                                            (
                                            p_ato_line_id    IN Number,
                                            p_line_id        IN NUMBER,
                                            p_item_type_code IN VARCHAR2,
                                            p_Line_Number      IN NUMBER,
                                            p_Shipment_Number  IN NUMBER,
                                            p_Option_Number    IN NUMBER,
                                            p_Component_Number IN NUMBER DEFAULT NULL,
                                            p_Service_Number   IN NUMBER DEFAULT NULL
                                            ) Return varchar2;

 /* This function will get the line status for the given line, If the line passed is Model then it will
    get the config line's line status */

 FUNCTION get_line_status (
			   p_Line_Id	   IN   NUMBER,
			   p_Ato_Line_Id     IN   NUMBER,
			   p_Item_Type_code  IN   Varchar2,
		           p_flow_status     IN   Varchar2) Return Varchar2;

/* This function will get the supply type based on the reservation/Link to the config/ato/std line */

Function Get_supply_type (P_line_id       IN Number,
                          p_ato_line_id   IN Number,
                          p_item_type     IN Varchar2,
			  p_source_type   IN Varchar2) return Varchar2;

/* This function is used to get the config line id based on model line */

Function Get_config_line_id (P_ato_line_id IN Number,
                            p_line_id     IN Number,
                            p_item_type   IN Varchar2) return Number;


/* This function is used to get the Item name for config based on Model Line */

Function Get_Item_Name (P_ato_line_id  IN Number,
                        p_line_id      IN Number,
                        p_item_type    IN Varchar2,
                        p_item_name    IN Varchar2,
                        p_config_item  IN Number,
                        p_ship_org_id  IN Number) return Varchar2;


/* This function is used to get the item description for the config based on model line */

Function Get_Item_Desc (P_ato_line_id  IN Number,
                        p_line_id      IN Number,
                        p_item_type    IN Varchar2,
                        p_item_desc    IN Varchar2,
                        p_config_item  IN Number,
                        p_ship_org_id  IN Number) return Varchar2;


/* This function is used to get the document source id for sales order line */

FUNCTION get_source_document_id (pLineId in number)
RETURN NUMBER;


/* This function is used to convert UOM from and to primary UOM */

FUNCTION convert_uom(from_uom IN VARCHAR2,
                       to_uom  IN VARCHAR2,
                     quantity  IN NUMBER,
                      item_id  IN NUMBER )
 RETURN NUMBER;

/* This function gets the suggested buyer name for reqs */
FUNCTION Get_Buyer_Name (P_suggested_buyer_id  IN Varchar2)
RETURN Varchar2;


/* fp-J project: Added a new function Get_Workbench_Item_Type */
FUNCTION Get_WorkBench_Item_Type
	( p_header_id         IN  NUMBER
 	,p_top_model_line_id  IN  NUMBER
 	,p_ato_line_id        IN  NUMBER
 	,p_line_id            IN  NUMBER
 	,p_item_type_code     IN  VARCHAR2
	) RETURN varchar2;

-- Fixed bug 5199341
-- Added two more parameters to derive the config line id inisde API


FUNCTION Get_Rsvd_on_hand_qty(
                              p_line_id        IN Number,
			      p_ato_line_id    IN Number,
			      p_item_type_code IN varchar2) RETURN Number;


-- rkaza. 05/19/2005. ireq project.
-- Start of comments
-- API name : get_last_available_date
-- Type	    : Public
-- Pre-reqs : None.
-- Function : Given ato line id, order line id and item type code, it returns
--            the date when the last supply becomes available for the top
--            level config/ato/std item.
-- Parameters:
-- IN	    : p_ato_line_id           	IN NUMBER	Required
--	         order line id
--            p_line_id
--            p_item_type_code
-- Version  : Current version   115.9
--               Modified signature. Added ato_line_id and item_type_code
--            Previous version	115.7
--	         Added this description
--	      Initial version 	115.6
-- End of comments
FUNCTION get_last_available_date(p_ato_line_id IN number, p_line_id IN Number, p_item_type IN varchar2) RETURN date;



/*******************************************************************************************
-- API name : get_rsvd_inrcv_qty
-- Type     : Public
-- Pre-reqs : INVRSVGS.pls
-- Function : Given config/ato item line id  it returns
--            the qty reserved to in receiving supply
-- Parameters:
-- IN       : p_line_id           Expects the config/ato item order line id       Required
--
-- Version  :
--
--
******************************************************************************************/


-- Fixed bug 5199341
-- Added two more parameters to derive the config line id inisde API
FUNCTION Get_Rsvd_inrcv_qty(
                              p_line_id        IN    Number,
			      p_ato_line_id    IN    Number,
			      p_item_type_code IN    varchar2
			      ) RETURN Number;



-- rkaza. 06/30/2005. ireq project.
-- Start of comments
-- API name : find_config_line_and_level
-- Type	    : Public
-- Pre-reqs : None.
-- Function : Given ato line id, order line id and item type code, it finds
--            config/ato item/std line id for the top level. For lower level,
--            it will find line_id itself. Also, along with config line id,
--            it will give corresponding line level.
--            top level - 'Top'
--            lower level - 'Lower'
--            Ato item    - 'Ato'
--            Std item  - 'Std'
-- Parameters:
-- IN	    : p_ato_line_id           	IN NUMBER	Required
--	         order line id
--            p_line_id                 IN number     Required
--            p_item_type_code          IN varchar2   Required
--            x_config_line_id          OUT number
--            x_line_level              OUT varchar2
--            x_return_status           OUT varchar2
-- Version  :
-- End of comments
Procedure find_config_line_and_level(p_ato_line_id IN number,
                                     p_line_id IN Number,
                                     p_item_type IN varchar2,
                                     x_config_line_id OUT NOCOPY Number,
                                     x_line_level OUT NOCOPY varchar2,
                                     x_return_status OUT NOCOPY varchar2);
/* Added by renga Kannan for bug 5348842 */

 Function get_order_line_number(p_line_number       Number,
                                p_service_number    Number,
                                p_option_number     Number,
				p_component_number  Number,
				p_shipment_number   Number) return varchar2;



end cto_workbench_util_pk;


 

/
