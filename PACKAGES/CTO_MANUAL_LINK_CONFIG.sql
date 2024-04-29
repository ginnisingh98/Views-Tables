--------------------------------------------------------
--  DDL for Package CTO_MANUAL_LINK_CONFIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CTO_MANUAL_LINK_CONFIG" AUTHID CURRENT_USER as
/* $Header: CTOLINKS.pls 120.1 2005/06/21 16:17:57 appldev ship $ */
/*============================================================================+
|  Copyright (c) 1993 Oracle Corporation    Belmont, California, USA          |
|                        All rights reserved.                                 |
|                        Oracle Manufacturing                                 |
+=============================================================================+
|                                                                             |
| FILE NAME   : CTOLINKS.pls                                                  |
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


function link_config(
	p_model_line_id         in  number,
        p_config_item_id        in  number,
        x_error_message         out NOCOPY varchar2,
        x_message_name          out NOCOPY varchar2
)
RETURN boolean;

FUNCTION Validate_Link(p_model_line_id         in  number,
        		p_config_item_id        in  number,
        		x_error_message         out NOCOPY varchar2,
        		x_message_name          out NOCOPY varchar2
)
RETURN integer;

end CTO_MANUAL_LINK_CONFIG;

 

/
