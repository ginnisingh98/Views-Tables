--------------------------------------------------------
--  DDL for Package CTO_WIP_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CTO_WIP_WRAPPER" AUTHID CURRENT_USER as
/* $Header: CTOWIPWS.pls 120.0.12010000.1 2008/07/24 17:27:58 appldev ship $ */
/*============================================================================+
|  Copyright (c) 1993 Oracle Corporation    Belmont, California, USA          |
|                        All rights reserved.                                 |
|                        Oracle Manufacturing                                 |
+=============================================================================+
|                                                                             |
| FILE NAME   : CTOWIPWB.pls                                                  |
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
|               August 14, 99  Angela Makalintal   Initial version		      |
=============================================================================*/

/*****************************************************************************
   Procedure:  insert_wip_interface
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
FUNCTION get_order_lines(p_org_id               IN NUMBER,
                         p_offset_days          IN NUMBER,
                         p_load_type            IN NUMBER, -- config, non-config, both
                         p_class_code           IN varchar2, -- for job creation
                         p_status_type          IN NUMBER, -- for job creation
                         p_order_number         IN NUMBER,
                         p_line_id              IN NUMBER,
                         p_conc_request_id      IN NUMBER,
                         p_conc_program_id      IN NUMBER,
                         p_conc_login_id        IN NUMBER,
                         p_user_id              IN NUMBER,
                         p_appl_conc_program_id IN NUMBER,
                         x_orders_loaded        OUT NoCopy  NUMBER,
                         x_wip_seq              OUT NoCopy  NUMBER,
                         x_message_name         OUT NoCopy  VARCHAR2,
                         x_message_text         OUT NoCopy  VARCHAR2
)
RETURN integer;

FUNCTION reserve_wo_to_so(p_wip_seq IN NUMBER,
                          p_message_text VARCHAR2,
                          p_message_name VARCHAR2
)

RETURN integer;

FUNCTION Get_Reserved_Qty(pLineId IN NUMBER)
RETURN number;

--
-- begin bugfix 2095043 :
--       Added function Get_NotInv_Qty to find out how much has been NOT
--	 been inventory-interfaced.
--

FUNCTION Get_NotInv_Qty(pLineId IN NUMBER)
RETURN number;

-- end bugfix 2095043

end CTO_WIP_WRAPPER;

/
