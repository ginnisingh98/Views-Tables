--------------------------------------------------------
--  DDL for Package CTO_MATCH_AND_RESERVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CTO_MATCH_AND_RESERVE" AUTHID CURRENT_USER as
/* $Header: CTOMCRSS.pls 120.1 2005/06/16 15:59:41 appldev  $ */
/*============================================================================+
|  Copyright (c) 1993 Oracle Corporation    Belmont, California, USA          |
|                        All rights reserved.                                 |
|                        Oracle Manufacturing                                 |
+=============================================================================+
|                                                                             |
| FILE NAME   : CTOMCRSS.pls                                                  |
| DESCRIPTION:                                                                |
|               This file creates a package that containst procedures called  |
|               from the Match and Reserve menu from Order Entry's Enter      |
|               Orders form.                                                  |
|                                                                             |
|               match_inquiry -                                               |
|               This function is called when the Match and Reserve            |
|               menu is  invoked.  It does the following:                     |
|               1.  Checks if the order line is eligible to be matched        |
|                   and reserved.                                             |
|               2.  If it is, it determines if the order line is already      |
|                   linked to a configuration item.  If it is, it uses that   |
|                   config item in the available quantity inquiry.  If it     |
|                   does not, it attempts to match the configuration from     |
|                   oe_order_lines against bom_ato_configurations.            |
|                3.  If a configuration item exists, it calls Inventory's     |
|                   API to query available quantity (on-hand and available    |
|                   to reserve).  If it has any quantity available to reserve |
|                   it returns true.                                          |
|                                                                             |
|                                                                             |
| To Do:        Handle Errors.  Need to discuss with Usha and Girish what     |
|               error information to include in Notification.                 |
|                                                                             |
| HISTORY     :                                                               |
|               May 10, 99  Angela Makalintal   Initial version		          |
=============================================================================*/

/*****************************************************************************
   Function:  match_inquiry
   Parameters:  p_model_line_id   - line id of the top model in oe_order_lines
                x_match_config_id - config id of the matching configuration
                                  from bom_ato_configurations
                x_error_message   - error message if match function fails
                x_message_name    - name of error message if match
                                    function fails

   Description:  This function looks for a configuration in
                 bom_ato_configurations that matches the ordered
                 configuration in oe_order_lines.

*****************************************************************************/
function match_inquiry(
	p_model_line_id         in  number,
        p_automatic_reservation in  boolean,
        p_quantity_to_reserve   in  number,
        p_reservation_uom_code  in  varchar2,
	x_config_id             out nocopy number,
        x_available_qty         out nocopy number,
        x_quantity_reserved     out nocopy number,
        x_error_message         out nocopy varchar2,
        x_message_name          out nocopy varchar2
)
RETURN boolean;

function create_config_reservation(
	p_model_line_id        IN NUMBER,
	p_config_item_id       IN NUMBER,
	p_quantity_to_reserve  IN NUMBER,
        p_reservation_uom_code IN VARCHAR2,
        x_quantity_reserved    OUT nocopy NUMBER,
	x_error_msg            OUT nocopy VARCHAR2,
	x_error_msg_name       OUT nocopy VARCHAR2
    )
return boolean;

function config_line_exists(p_model_line_id IN NUMBER,
                            x_config_line_id OUT nocopy NUMBER,
                            x_config_item_id OUT nocopy NUMBER)
return boolean;

end CTO_MATCH_AND_RESERVE;

 

/
