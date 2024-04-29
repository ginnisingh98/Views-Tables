--------------------------------------------------------
--  DDL for Package PA_BILLING_AMOUNT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_BILLING_AMOUNT" AUTHID CURRENT_USER AS
/* $Header: PAXIAMTS.pls 120.1 2005/08/19 17:13:45 mwasowic noship $ */

------------
--  OVERVIEW
--  Contains procedures that do calculations and return numeric values.
--

----------------------------
--  PROCEDURES AND FUNCTIONS
--
--
--  1. Procedure Name:	CostAmount returns the actual burden cost for the
-- 			project/task_id specified. This includes accumulated
--  			and unaccumulated burden cost with pa_dates before
--			the specified accrue thru date.
--  	Usage:		CostAmount(project_id, task_id, accru_thr_date, cost)
--  			where cost is an OUT variable.
--
--  2. Procedure Name:	RevenueAmount returns all revenue that came from the
--  			cost-cost algorithm events or Expenditure Items.
--  	Usage:		RevenueAmount(project_id, task_id, revenue)
--  			where revenue is an OUT parameter.
--
--  3. Procedure Name:	PotEventAmount returns revenue and invoice amount total
--  			for all events other than those coming from cost-cost,
--			for the Project/Task specified with completion dates
--			before the accrue_thru_date.
--  	Usage:		PotEventAmount(project_id, task_id, accrue_thru_date,
--  			revenue, invoice)
--  			where revenue and invoice are OUT parameters.
--
--  4. Procedure Name:  InvoiceAmount returns the Invoice Amount that is coming
--  			from expenditure items or cost-cost events for the
--  			project/task specified.
--  	Usage:		InvoiceAmount(project_id, task_id, invoice)
--  			where invoice is an OUT parameter.
--
--  5. Function Name:	LowestAmountLeft calculates how much can go under the
--  			lowest hard limit of the customers attached to the
--			project taking the bill split and accrued_amounts
--  			into account. From this it subtracts automatic events
--  			have not been accrued/billed yet.
--  			If called by Revenue it returns the Revenue
--  			amount otherwise the Invoice Amount. If the amount
--  			being returned in negative it returns zero.
--  	Usage:		amount REAL;
--			amount := LowestAmountLeft(project, task,
--  					 	calling_process);
--
--  6. 	Function Name:		rdl_amount
--
--   	Usage:			amount := rdl_amount(eiid, which_amount)
--
--     	Parameters: 		X_which: Can have values R or I (Default R)
--	       				R: return revenue_amount
--             				I: return invoice_amount
--     				X_eiid:  Return amount for this eiid.
--				X_adj:   If 'Y' Return only adjusting amounts.
--  					 If 'N' return only +ve amounts
--					 IF NULL return both.
--				X_ei_adj: 'Y' if the Exp Item is an adjusting
--					one, 'N' otherwise.
--
-- 7.  Procedure Name :        get_baseline_budget
--
--     Usage:                  get_baseline_budget ( X_project_id,
--                                                   X_rev_budget,
--                                                   X_cost_budget,
--                                                   X_err_msg )
--
--     Parameter:              X_project_id : Project id
--                             X_rev_budget : Baseline Revenue Budget
--                             X_cost_budget: Baseline Cost Budget
--                             X_err_msg    : Error Message
--
------------------------
-- FUNCTION DECLARATIONS
--



Procedure CostAmount( 	X2_project_id 	NUMBER,
		     	X2_task_id	NUMBER DEFAULT NULL,
			X2_accrue_through_date DATE DEFAULT NULL,
			X2_cost_amount  OUT NOCOPY REAL); --File.Sql.39 bug 4440895

Procedure RevenueAmount(  	X2_project_id NUMBER,
	 			X2_task_Id   NUMBER DEFAULT NULL,
				X2_revenue_amount OUT NOCOPY REAL); --File.Sql.39 bug 4440895

Procedure PotEventAmount( 	X2_project_id 	NUMBER,
				X2_task_id 	NUMBER DEFAULT NULL,
				X2_accrue_through_date DATE DEFAULT NULL,
				X2_revenue_amount OUT NOCOPY REAL, --File.Sql.39 bug 4440895
				X2_invoice_amount OUT NOCOPY REAL); --File.Sql.39 bug 4440895

Procedure InvoiceAmount(	X2_project_id	NUMBER,
				X2_task_id	NUMBER default NULL,
				X2_invoice_amount OUT NOCOPY REAL); --File.Sql.39 bug 4440895

FUNCTION LowestAmountLeft (	X2_project_id NUMBER,
				X2_task_id NUMBER,
				X2_calling_process VARCHAR2)
	RETURN REAL;

FUNCTION rdl_amount(X_which VARCHAR2, X_eiid NUMBER, X_adj VARCHAR2, X_ei_adj VARCHAR2)
	return REAL;

PROCEDURE get_baseline_budget ( X_project_id   IN NUMBER,
                                X_rev_budget  OUT NOCOPY REAL, --File.Sql.39 bug 4440895
                                X_cost_budget OUT NOCOPY REAL, --File.Sql.39 bug 4440895
                                X_err_msg     OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


END pa_billing_amount;

 

/
