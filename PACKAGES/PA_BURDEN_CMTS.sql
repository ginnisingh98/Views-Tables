--------------------------------------------------------
--  DDL for Package PA_BURDEN_CMTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_BURDEN_CMTS" AUTHID CURRENT_USER AS
/* $Header: PABCMTS.pls 120.0 2005/05/30 20:46:34 appldev noship $ */

-- This function returns the compiled_set_id
-- This function will return NULL in case of error or if the compiled_set_id
-- is not found

FUNCTION get_cmt_compiled_set_id
	  (
       x_transaction_id        IN NUMBER,
       x_transaction_type      IN VARCHAR2,
       x_task_id               IN NUMBER,
	    x_expenditure_item_date IN DATE,
	    x_organization_id       IN NUMBER,
	    p_expenditure_type       IN pa_expenditure_types.expenditure_type%TYPE,
	    x_schedule_type         IN VARCHAR2) RETURN NUMBER;
--pragma RESTRICT_REFERENCES (get_cmt_compiled_set_id, WNDS, WNPS );

-- This function returns the burdened_cost
-- in case if it is not able to calculate the burden cost component
-- then it will return the direct_cost itself.

FUNCTION get_cmt_burdened_cost
	  (
       x_transaction_id        IN NUMBER,
       x_transaction_type      IN VARCHAR2,
       x_task_id               IN NUMBER,
	    x_expenditure_item_date IN DATE,
            x_expenditure_type      IN VARCHAR2,
	    x_organization_id       IN NUMBER,
	    x_schedule_type         IN VARCHAR2,
            x_direct_cost           IN NUMBER) RETURN NUMBER;
--- pragma RESTRICT_REFERENCES (get_cmt_burdened_cost, WNDS, WNPS ); /* commented as per 3786374 */

END PA_BURDEN_CMTS;

 

/
