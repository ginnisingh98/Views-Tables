--------------------------------------------------------
--  DDL for Package PA_BILLING_VALUES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_BILLING_VALUES" AUTHID CURRENT_USER AS
/* $Header: PAXIVALS.pls 120.1 2005/08/19 17:15:16 mwasowic noship $ */

------------
--  OVERVIEW
--  Procedures/Functions created to return character fields from DB.
--
--

---------------------
--  SPECIAL CONSTANTS
--
--
--

----------------------------
--  PROCEDURES AND FUNCTIONS
--
--
--
--  1. Function Name:   funding_level
--
--     Usage:		If (funding_level(project_id) = 'TASK')
--
-- 			The function will return TASK if there is Task Level
-- 			funding and PROJECT if there is Project Level funding.
-- 			It will return NO FUNDING if there is no funding.
--
--     Parameters: 	X2_project_id (Mandatory)
--
--
--  2. Function Name:	get_dflt_org
--
--     Usage:		Org_id := get_dflt_org(project_id, task_id)
--
--			Returns task org of task_id is passed in else returns
--			the project org.
--
--
--  3. Procedure Name: 	get_dflt_desc
--
--     Usage:		event_desc := get_dflt_desc(extn_asgn_id, event_type,
--							description);
--
--       		Gets the default event description, and event_type
--			for the associated billing_extension.
--
--  4. Function Name:   message_text
--
--     Usage:           message := message_text('NULL_EVENT_TYPE')
--
--                      Returns the message associated with the code.
--
--
--

------------------------
-- FUNCTION DECLARATIONS
--

FUNCTION funding_level(X2_project_id NUMBER)
	RETURN VARCHAR2;

FUNCTION get_dflt_org(X2_project_id NUMBER, X2_top_task_id NUMBER)
	RETURN NUMBER;

PROCEDURE get_dflt_desc(X2_billing_assignment_id NUMBER,
			X2_event_type OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
			X2_event_description OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

FUNCTION get_message(X2_message_code VARCHAR2)
	RETURN VARCHAR2;

END pa_billing_values;

 

/
