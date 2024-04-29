--------------------------------------------------------
--  DDL for Package PA_BILLING_SEQ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_BILLING_SEQ" AUTHID CURRENT_USER AS
/* $Header: PAXISEQS.pls 115.0 99/07/16 15:26:41 porting ship $ */

------------
--  OVERVIEW
--
--  This package has procedures which return serial numbers of any sort.
--

---------------------
--  SPECIAL CONSTANTS
--
--
--

----------------------------
--  PROCEDURES AND FUNCTIONS
--
--  1. Function Name: 	next_eventnum
--
--     Usage: 		new_eventnum = next_eventnum(project_id, task_id)
--            		new_eventnum gets the next eventnum for this project,
-- 			or task.
--
--     Parameters:   	X_project_id (Mandatory)
--

FUNCTION next_eventnum (X2_project_id NUMBER, X2_task_id NUMBER)
	RETURN NUMBER;

FUNCTION session_id RETURN NUMBER;

END pa_billing_seq;

 

/
