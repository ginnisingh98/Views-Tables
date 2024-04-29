--------------------------------------------------------
--  DDL for Package PA_BILLING_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_BILLING_VALIDATE" AUTHID CURRENT_USER AS
/* $Header: PAXIVLDS.pls 115.0 99/07/16 15:27:26 porting ship $ */

------------
--  OVERVIEW
--  This package contains functions that validate parameters entered and return
--  TRUE or FALSE.
--

---------------------
--  SPECIAL CONSTANTS
--
--
--

----------------------------
--  PROCEDURES AND FUNCTIONS
--
--  1. Function Name:  	valid_proj_task_extn
--
--     Usage:		is_valid = valid_proj_task_extn(project_id,
--				top_task_id, billing_assignment_id)
--  			is_valid gets true if the project_id exists in
--  			PA_TASKS for the specified top_task, and a
--			bill extn assignment exists for project or task.
--
--     Parameters:	X2_project_id (Mandatory)
--  			X2_top_task_id
--
--
--  2. Function Name:  	valid_organization
--
--     Usage:		is_valid = valid_organization(organization_id)
--  			is_valid gets true if the organization_id exists in
--  			PER_ORGANIZATION_UNITS.
--
--     Parameters: 	X2_organization_id (Mandatory)
--
--
--  3. Function Name: 	automatic_event
--
--     Usage:		If (automatic_event(event_type))
--
--     			The expression will evaluate to TRUE is the
-- 			event_type has a classification of automatic.
--
--     Parameters: 	X_event_type (Mandatory)

------------------------
-- FUNCTION DECLARATIONS
--
FUNCTION valid_proj_task_extn (X2_project_id NUMBER, X2_top_task_id NUMBER,
			X2_billing_assignment_id NUMBER)
	RETURN BOOLEAN;

FUNCTION valid_organization (X2_organization_id	NUMBER)
	RETURN BOOLEAN;

FUNCTION automatic_event (X2_event_type VARCHAR2)
	RETURN BOOLEAN;

END pa_billing_validate;

 

/
