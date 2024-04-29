--------------------------------------------------------
--  DDL for Package CTO_WORKFLOW_API_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CTO_WORKFLOW_API_PK" AUTHID CURRENT_USER as
/* $Header: CTOWFAPS.pls 120.3 2005/06/30 09:26:45 rekannan noship $ */
/*============================================================================+
|  Copyright (c) 1993 Oracle Corporation    Belmont, California, USA          |
|                        All rights reserved.                                 |
|                        Oracle Manufacturing                                 |
+=============================================================================+
|                                                                             |
| FILE NAME   : CTOWFAPS.pls
|                                                                             |
| DESCRIPTION:                                                                |
|               Contain all CTO and WF related APIs.
|               One API is used to check if a configured item (model)         |
|               is created. This API is applied by the Processing Constraints |
|               Framework provided by OE                                      |
|                                                                             |
|                                                                             |
| HISTORY     :                                                               |
|               Aug 16, 99   James Chiu   Initial version                     |
|               Sep 20, 01   Ravi         Added one new procedure for         |
|                                         Autocreate Req                      |
|
|
|		June 16,2005 Kiran Konada
|				modified cur_var_type record to include
|				secondary reservation  qty
|               June 27, 2005 Renga Kannan
|                             Modified by Renga Kannan for Cross Docking project
|
=============================================================================*/

G_ITEM_TYPE_NAME              CONSTANT VARCHAR2(30):='OEOL';


/**************************************************************************

   Procedure:   query_wf_activity_status
   Parameters:  p_itemtype                -
                p_itemkey                 -
                p_activity_label          -           "
                p_activity_name           -           "
                p_activity_status         -
   Description: this procedure is used to query a Workflow activity status

*****************************************************************************/

PROCEDURE query_wf_activity_status(
        p_itemtype        IN      VARCHAR2,
        p_itemkey         IN      VARCHAR2,
        p_activity_label  IN      VARCHAR2,
        p_activity_name   IN      VARCHAR2,
        p_activity_status OUT NOCOPY    VARCHAR2
        );

/**************************************************************************

   Procedure:   get_activity_status
   Parameters:  itemtype                -
                itemkey                 -
                linetype                -           "
                activity_name           -           "
   Description: this procedure is used by Match and Reserve to check if an
                instance of WF process resides at a desired block activity.

*****************************************************************************/

PROCEDURE get_activity_status(
        itemtype        IN      VARCHAR2,
        itemkey         IN      VARCHAR2,
        linetype        IN      VARCHAR2,
        activity_name   OUT NOCOPY    VARCHAR2
        );

/**************************************************************************

   Function:   complete_activity
   Parameters:  p_itemtype                -
                p_itemkey                 -
                p_activity_name           -           "
                p_result_code             -           "
   Description: this function is used to complete an WF activity

*****************************************************************************/

FUNCTION complete_activity(
        p_itemtype        IN      VARCHAR2,
        p_itemkey         IN      VARCHAR2,
        p_activity_name   IN      VARCHAR2,
        p_result_code     IN      VARCHAR2
        )
return BOOLEAN;

/**************************************************************************
	Function:    display_wf_status
	Parameters:  p_order_line_id
	Description: this function is used to display a proper wf status from
				 OM form. The status can be production open, production
     			 partial, and production complete.

***************************************************************************/

FUNCTION display_wf_status(
		 p_order_line_id  IN      NUMBER
    	 )
return INTEGER;


/**************************************************************************

   Procedure:   configuration_item_created
   Parameters:	p_application_id              (standard signature format)
		p_entity_short_name
		p_validation_entity_short_name
		p_validation_tmplt_short_name
		p_record_set_short_name
		p_scope
		x_result
   Description: This API with standard signature format is used to check is
                a configured item is created. This condition is applied to
                an option line.

*****************************************************************************/

PROCEDURE configuration_item_created(
	p_application_id	IN	NUMBER,
	p_entity_short_name	IN	VARCHAR2,
	p_validation_entity_short_name	IN	VARCHAR2,
	p_validation_tmplt_short_name	IN	VARCHAR2,
	p_record_set_short_name	IN VARCHAR2,
	p_scope			IN VARCHAR2,
	x_result		OUT NOCOPY NUMBER
	);

PROCEDURE configuration_created (
        p_application_id        IN      NUMBER,
        p_entity_short_name     IN      VARCHAR2,
        p_validation_entity_short_name  IN      VARCHAR2,
        p_validation_tmplt_short_name   IN      VARCHAR2,
        p_record_set_short_name IN VARCHAR2,
        p_scope                 IN VARCHAR2,
        x_result                OUT NOCOPY NUMBER
        );

/*************************************************************************
   Procedure:   inventory_reservation_check
   Parameters:  p_order_line_id
                x_return_status         - standard API output parameter
                x_msg_count             -           "
                x_msg_data              -           "

   Description: Check if an order line status is either
                "CREATE_CONFIG_BOM_ELIGIBLE" or
                "CREATE_SUPPLY_ORDER_ELIGIBLE"
*****************************************************************************/
PROCEDURE inventory_reservation_check(
        p_order_line_id   IN      NUMBER,
        x_return_status OUT  NOCOPY   VARCHAR2,
        x_msg_count     OUT  NOCOPY   NUMBER,
        x_msg_data      OUT  NOCOPY   VARCHAR2
        );

/*************************************************************************
   Procedure:   workflow_update_after_invent_reserv
   Parameters:  p_order_line_id
                x_return_status         - standard API output parameter
                x_msg_count             -           "
                x_msg_data              -           "

   Description: update an order line status after inventory reservation
*****************************************************************************/
PROCEDURE wf_update_after_inv_reserv(
        p_order_line_id   IN      NUMBER,
        x_return_status OUT NOCOPY    VARCHAR2,
        x_msg_count     OUT NOCOPY    NUMBER,
        x_msg_data      OUT NOCOPY    VARCHAR2
        );

/*************************************************************************
   - bugfix 2001824:  Added new parameter : p_rsv_quantity (unreserv qty)

   Procedure:   inventory_unreservation_check
   Parameters:  p_order_line_id
	        p_rsv_quantity          - Unreservation Quantity
	        x_return_status         - standard API output parameter
		x_msg_count             -           "
		x_msg_data              -           "

   Description: Check if an order line status is
    			 "SHIP_LINE"
*****************************************************************************/
PROCEDURE inventory_unreservation_check(
		p_order_line_id   IN      NUMBER,
		p_rsv_quantity    IN      NUMBER  default NULL,		--bugfix 2001824
		x_return_status   OUT NOCOPY    VARCHAR2,
		x_msg_count       OUT NOCOPY    NUMBER,
		x_msg_data        OUT NOCOPY    VARCHAR2
		);

/*************************************************************************
   Procedure:   wf_update_after_inv_unreserv
   Parameters:  p_order_line_id
				x_return_status         - standard API output parameter
				x_msg_count             -           "
				x_msg_data              -           "

   Description: update an order line status after inventory unreservation
*****************************************************************************/
PROCEDURE wf_update_after_inv_unreserv(
		p_order_line_id   IN      NUMBER,
		x_return_status OUT NOCOPY    VARCHAR2,
		x_msg_count     OUT NOCOPY    NUMBER,
		x_msg_data      OUT NOCOPY    VARCHAR2
		);

/*************************************************************************
   Procedure:   start_model_workflow
   Parameters:  p_model_line_id - top model line id from oe_order_lines_all
   Returns:     TRUE - if the ATO model workflow was started successfully;
                FALSE - if ATO model workflow was not started
   Description: update an order line status after inventory unreservation
*****************************************************************************/
function start_model_workflow(
                p_model_line_id IN NUMBER
                )
return boolean;

PROCEDURE Update_Config_Line(
	p_application_id	IN	NUMBER,
	p_entity_short_name	IN	VARCHAR2,
	p_validation_entity_short_name	IN	VARCHAR2,
	p_validation_tmplt_short_name	IN	VARCHAR2,
	p_record_set_short_name	IN VARCHAR2,
	p_scope			IN VARCHAR2,
	x_result		OUT NOCOPY NUMBER );

PROCEDURE Configuration_Created_For_Pto (
	p_application_id	IN	NUMBER,
	p_entity_short_name	IN	VARCHAR2,
	p_validation_entity_short_name	IN	VARCHAR2,
	p_validation_tmplt_short_name	IN	VARCHAR2,
	p_record_set_short_name	IN VARCHAR2,
	p_scope			IN VARCHAR2,
	x_result		OUT NOCOPY NUMBER );

PROCEDURE Top_Ato_Model(
	p_application_id	IN	NUMBER,
	p_entity_short_name	IN	VARCHAR2,
	p_validation_entity_short_name	IN	VARCHAR2,
	p_validation_tmplt_short_name	IN	VARCHAR2,
	p_record_set_short_name	IN VARCHAR2,
	p_scope			IN VARCHAR2,
	x_result		OUT NOCOPY NUMBER );

PROCEDURE Config_Line(
	p_application_id	IN	NUMBER,
	p_entity_short_name	IN	VARCHAR2,
	p_validation_entity_short_name	IN	VARCHAR2,
	p_validation_tmplt_short_name	IN	VARCHAR2,
	p_record_set_short_name	IN VARCHAR2,
	p_scope			IN VARCHAR2,
	x_result		OUT NOCOPY NUMBER );

PROCEDURE change_status_batch (
    p_header_id             NUMBER,
    p_line_id               NUMBER,
    p_change_status         VARCHAR2,
    p_oe_org_id             NUMBER,
	x_return_status OUT NOCOPY    VARCHAR2);

/**************************************************************************
   Procedure:   auto_create_pur_req
   Parameters:  p_itemtype                -
                p_itemkey                 -
                p_activity_label          -           "
                p_activity_name           -           "
                p_activity_status         -
   Description: This procedure is called from the AutoCreate Purchase Req program.
                This procedure will insert record into the req-imoprt table for the given sales order line.
*****************************************************************************/
PROCEDURE auto_create_pur_req(
            p_itemtype        IN      VARCHAR2, /* internal name for item type */
            p_itemkey         IN      VARCHAR2, /* sales order line id  */
            p_actid           IN      NUMBER,   /* ID number of WF activity  */
            p_funcmode        IN      VARCHAR2, /* execution mode of WF act  */
            x_result          OUT  NOCOPY   VARCHAR2   /* result of activity */
            );


/**************************************************************************

   Procedure:   chk_Buy_Ato_Item  -- change the desc later
   Parameters:  p_application_id              (standard signature format)
                p_entity_short_name
                p_validation_entity_short_name
                p_validation_tmplt_short_name
                p_record_set_short_name
                p_scope
                x_result
   Description: This API with standard signature format is called from
                the security constraints to validate whether a change is
                allowed on an order line.
                This API gets called for every item type.

*****************************************************************************/
PROCEDURE chk_Buy_Ato_Item(
        p_application_id        IN      NUMBER,
        p_entity_short_name     IN      VARCHAR2,
        p_validation_entity_short_name  IN      VARCHAR2,
        p_validation_tmplt_short_name   IN      VARCHAR2,
        p_record_set_short_name IN VARCHAR2,
        p_scope                 IN VARCHAR2,
        x_result                OUT NOCOPY NUMBER );



PROCEDURE Reservation_Exists(
        p_application_id        IN      NUMBER,
        p_entity_short_name     IN      VARCHAR2,
        p_validation_entity_short_name  IN      VARCHAR2,
        p_validation_tmplt_short_name   IN      VARCHAR2,
        p_record_set_short_name IN VARCHAR2,
        p_scope                 IN VARCHAR2,
        x_result                OUT NOCOPY NUMBER
        );

END CTO_WORKFLOW_API_PK;

 

/
