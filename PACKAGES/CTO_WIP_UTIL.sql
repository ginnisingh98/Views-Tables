--------------------------------------------------------
--  DDL for Package CTO_WIP_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CTO_WIP_UTIL" AUTHID CURRENT_USER as
/* $Header: CTOWIPUS.pls 120.1 2005/06/06 10:09:32 appldev  $ */
/*============================================================================+
|  Copyright (c) 1993 Oracle Corporation    Belmont, California, USA          |
|                        All rights reserved.                                 |
|                        Oracle Manufacturing                                 |
+=============================================================================+
|                                                                             |
| FILE NAME   : CTOWIPUS.pls                                                  |
|                                                                             |
| DESCRIPTION:                                                                |
|               This file creates the utilities that are required to create   |
|                work orders for ATO configurations.                          |
|                                                                             |
|               insert_wip_interface - inserts a record into                  |
|                                    WIP_JOB_SCHEDULE_INTERFACE for           |
|                                    WIP_MASS_LOAD to create work orders      |
|                                                                             |
| To Do:        Handle Errors.  Need to discuss with Usha and Girish what     |
|               error information to include in Notification.                 |
|                                                                             |
| HISTORY     :                                                               |
|               June 7, 99  Angela Makalintal   Initial version		      |
|               June 1, 05  Renga  Kannann      Added nocopy hint
=============================================================================*/

/*****************************************************************************
   Function:  insert_wip_interface
   Parameters:  p_model_line_id   - line id of the configuration item in
                                   oe_order_lines
                p_wip_seq - group id to be used in interface table
                x_error_message   - error message if insert fails
                x_message_name    - name of error message if insert
                                    fails

   Description:  This function inserts a record into the
                 WIP_JOB_SCHEDULE_INTERFACE table for the creation of
                 work orders.

*****************************************************************************/


procedure insert_wip_interface(
	p_line_id              in number,
	p_wip_seq              in number,
        p_status_type          in number,
        p_class_code           in varchar2,
        p_conc_request_id      in number,
        p_conc_program_id      in number,
        p_conc_login_id        in number,
        p_user_id              in number,
        p_appl_conc_program_id in number,
        x_return_status        out NOCOPY VARCHAR2,
        x_error_message        out NOCOPY VARCHAR2,  /* 70 bytes to hold  msg */
        x_message_name         out NOCOPY VARCHAR2 /* 30 bytes to hold  name */
	);

function validate_delivery_id(
        p_line_id              in number
) return integer;

function departure_plan_required(
        p_line_id              in number
) return integer;

PROCEDURE Delivery_Planned(p_line_id 	IN 	        NUMBER,
			x_result_out	OUT NOCOPY 	VARCHAR2,
			x_return_status OUT NOCOPY	VARCHAR2,
			x_msg_count	OUT NOCOPY	NUMBER,
			x_msg_data	OUT NOCOPY	VARCHAR2);

PRAGMA RESTRICT_REFERENCES (validate_delivery_id, WNDS);

end CTO_WIP_UTIL;

 

/
