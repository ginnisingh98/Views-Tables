--------------------------------------------------------
--  DDL for Package CSP_PROD_TASK_HIST_RULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_PROD_TASK_HIST_RULE" AUTHID CURRENT_USER AS
/* $Header: cspgphrs.pls 115.2 2002/11/26 07:47:25 hhaugeru ship $ */
-- Start of Comments
-- Package name     : CSP_PROD_TASK_HIST_RULE
-- Purpose          : This package includes the functions that decide whether to use the history
--                    of Product-Task-Parts details based on value defined in CSP_PROD_TASK_HIST_RULE profile.
-- History          : 03-Aug-2001, Arul Joseph.
-- NOTE             :
-- End of Comments
Function get_quantity
	(p_prod_task_times_used number,
         p_manual_quantity  number,
	 p_rollup_quantity_used  number,
	 p_rollup_times_used number,
         p_quantity_used    number,
         p_part_actual_times_used number
	) return number;
Function get_percentage
	(p_prod_task_times_used number,
         p_manual_percentage number,
	 p_rollup_times_used number,
         p_part_actual_times_used number)
         return number;

END CSP_PROD_TASK_HIST_RULE;

 

/
