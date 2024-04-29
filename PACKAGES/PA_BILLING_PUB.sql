--------------------------------------------------------
--  DDL for Package PA_BILLING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_BILLING_PUB" AUTHID CURRENT_USER AS
/* $Header: PAXIPUBS.pls 120.3 2005/08/05 02:11:59 bchandra noship $ */

------------
--  OVERVIEW
--  Procedures/Functions for use by Clients are included in this file.
--
--

----------------------------
--  PROCEDURES AND FUNCTIONS
--
--  1. Procedure Name:	get_budget_amount returns the budgetted cost and
--			revenue	amount for the project/top task id specified.
--     Usage:		get_budget_amount(project_id, task_id, revenue, cost)
--
--     Parameters:
--
--			 X2_project_id : project_id of project to get budget
--				         IN Variable
--
--			 X2_task_id    : Top task id of the project
--				         IN Variable
--
--			 X2_revenue_amount : Revenue budget amount
--					 OUT Variable ,
--
--			 X2_cost_amount : Cost budget amount
--					 OUT Variable
--
--                       P_cost_budget_type_code : IN Variable
--                                                 Cost Budget type code
--				                   You may specify if
--						   a different cost budget is
--						   to be used other than the
--						   default 'AC'.
--
--                       P_rev_budget_type_code  : IN Variable
--                                                 Cost Budget type code
--				                   You may specify if
--						   a different cost budget is
--						   to be used other than the
--						   default 'AR'.
--
                          /* Added for Fin Plan impact */
--                       P_cost_plan_type_id     : IN Variable
--                                                 Unique identifier of the
--				                   plan type used for calculating
--						   Cost plan amount.
--
--                       P_rev_plan_type_id      : IN Variable
--                                                 Unique identifier of the
--				                   plan type used for calculating
--						   Revenue plan amount.
                          /* Till here */
--
--                       X_cost_budget_type_code : OUT Variable
--                                                 Contains the
--						   cost_budget_type_code
--						   used.
--
--                       X_rev_budget_type_code  : OUT Variable
--                                                 Contains the
--						   revenue_budget_type_code
--						   used.
--
-- 			 X_error_message	 : OUT Variable
--						   Error message if any, will
--						   be returned.
--
--			 X_status		 : OUT Variable
--						   Status
--
--  2. Procedure Name:	get_amount
--                      *** We recommended that you use the views
--			PA_BILLING_REV_TRANSACTIONS_V and
--			PA_BILLING_INV_TRANSACTIONS_V to select transaction
--			amounts.  Get_amount will not be supported in future
--			versions ***
--
--
--     Usage: 		get_amount(... , amount, status);
--			amount will get the revenue, cost or bill amount
--     			as specified by the parameters listed below.
--			status will get any error status returned by
--			the procedure.
--
--     Parameters: 	You must specify X_project_id.
--			Specify X_request_id if you want amounts for this
--			run only.
--			You must also specify X_calling_process. For the first
--			four values you may send in exactly the same value as
--			is passed into your stored procedure eg.
--			X_project_id => X_project_id, X_request_id =>X_req..etc
--
--     			X_project_id:  	If this value is specified, the
--					procedure will retrieve amounts for
--					this project only.
--   			X_request_id:   If specified only amounts being
--					processed in the current run
--                 			will be retrieved.
--			X_calling_process: Can have a value of 'Revenue'
--					or 'Invoice'. If this value is
--					left blank it defaults to 'Revenue'.
--    			X_calling_place: Can have a value of 'REG' or 'ADJ'.
--					You may send in the parameter that
--					was sent in to your procedure. The
--					behaviour of get_amounts will vary
--					as described below:
--					If you send in this value as:
--					X_calling_place => X_calling_place
--					then the behaviour will be as follows:
--					Regular Section: Only +ve amounts
--					Adjustment Section: Only -ve amounts
--					Pre/Post Section: All amount
--
--					If you send in NULL or ignore this
--					parameter (it defaults to NULL),
--					then All amounts will be returned in
--					all cases.
--   			X_which_amount: Can have value of R, I, C or B.
--					Default is R.
-- 		   			R: Revenue amount
--		   			I: Invoice amount
--		   			C: Raw Cost amount
--		   			B: Burden Cost amount
--			X_amount:	Output parameter to hold amount
--					returned
--			X_status:	Output parameter to hold error status
--					returned.
--    			X_top_task_id: 	If you wish to retreive totals only
--					for all tasks below a particular
--					top_task, specify this value.
--   			X_system_linkage: Only amounts for specified
--					system linkage will be retrieved.
--
--					The three parameters below must either
--					all or none be specified:
--   			X_cost_base:    Only amounts for expenditure_types
--					related to specified cost base will be
--					retrieved.
--			X_CP_structure: Since cost_base only makes sense in
--					the context of a cost plus structure
--					and cost base type, this must be
--					specified, whenever cost base is
--					specified.
--			X_CB_type:	Similarly, cost_base_type must be
--					specified if a cost base is specified.
--
--  Note: If you are using request_id and want to get detail figures, you will
--        get figures for cost/rev/invoice from ei's that have been revenue
--	  distributed/billed in this run. If your distribution rule is
--	  COST/COST or COST/EVENT or EVENT/EVENT, you will not get any figures,
--	  since the ei's do not get any rdl's in these cases.
--
--  10. Procedure Name:  insert_message
--
--			Inserts a row into pa_billing_messages. This
--			is of use in debugging what happened when the Users
--			procedure executed.
--
--			The only 2 required parameters are
--			x_inserting_procedure_name and x_message.
--
-- 11. Procedure Name:	insert_event
--
--     Purpose:         Inserts rows into table pa_events subject to
--			the following validation:
--     			- Event_type must have an event_type_classification of
--			  'AUTOMATIC'.
--     			- Completion date of event must be before
--			  accrue_through_date
--     			- If the Bill Extn Id belongs to an Invoice Type extn,
--			  then both revenue and invoice amount can be positive
--			  but if there is a +ve revenue amount, the invoice
-- 			  amount must be greater than 0.
--     			- Project Id be supplied, or an error message will be
--			  returned.
--     			- Also for each of the above validations, an error
--			  message will be returned.
--			- One of X_rev_amt or X_bill_amt must be non_zero
--			  all other values will default as described below:
--    Parameters:                                       Defaults
--                      X_rev_amt                       0
--			X_bill_amt                      0
--			X_project_id                    current project
--			X_event_type                    from Billing Ext Dflt
--			X_top_task_id                   NULL
--			X_organization_id               From Task/Proj Org
--			X_completion_date               sysdate or X_accrue_thr
--                     	X_event_description             default event descr
--			X_attribute_category            NULL
--                      X_attribute1-10                 NULL
--
--   Audit fields can be used for storing additional audit info for events
--
--                      X_audit_amount1-10              Audit Amounts
--			X_audit_cost_budget_type_code   cost budget type code
--                      X_audit_rev_budget_type_code    revenue budget type code
-- 			X_error_message	 	        error message returned
--			X_status		        status returned

procedure get_budget_amount(
			 X2_project_id               NUMBER,
			 X2_task_id                  NUMBER DEFAULT NULL,
			 X2_revenue_amount       OUT NOCOPY REAL,
			 X2_cost_amount          OUT NOCOPY REAL,
                         P_cost_budget_type_code IN  VARCHAR2 DEFAULT NULL,
                         P_rev_budget_type_code  IN  VARCHAR2 DEFAULT NULL,
                         P_cost_plan_type_id     IN  NUMBER   DEFAULT NULL, /* Added for Fin Plan impact */
                         P_rev_plan_type_id      IN  NUMBER   DEFAULT NULL, /* Added for Fin Plan impact */
                         X_cost_budget_type_code OUT NOCOPY VARCHAR2,
                         X_rev_budget_type_code  OUT NOCOPY VARCHAR2,
 			 X_error_message	 OUT NOCOPY VARCHAR2,
			 X_status		 OUT NOCOPY NUMBER
			);


procedure get_amount(	X_project_id 	NUMBER,
			X_request_id	NUMBER,
			X_calling_process VARCHAR2,
			X_calling_place VARCHAR2 DEFAULT NULL,
			X_which_amount	VARCHAR2 DEFAULT 'R',
			X_amount OUT NOCOPY 	NUMBER,
			X_top_task_id 	NUMBER DEFAULT NULL,
			X_system_linkage VARCHAR2 DEFAULT NULL,
			X_cost_base	VARCHAR2 DEFAULT NULL,
			X_CP_structure	VARCHAR2 DEFAULT NULL,
			X_CB_type	VARCHAR2 DEFAULT NULL);


PROCEDURE insert_message (X_inserting_procedure_name 	VARCHAR2,
			X_message			VARCHAR2,
			X_attribute1			VARCHAR2 DEFAULT NULL,
			X_attribute2			VARCHAR2 DEFAULT NULL,
			X_attribute3			VARCHAR2 DEFAULT NULL,
			X_attribute4			VARCHAR2 DEFAULT NULL,
			X_attribute5			VARCHAR2 DEFAULT NULL,
			X_attribute6			VARCHAR2 DEFAULT NULL,
			X_attribute7			VARCHAR2 DEFAULT NULL,
			X_attribute8			VARCHAR2 DEFAULT NULL,
			X_attribute9			VARCHAR2 DEFAULT NULL,
			X_attribute10			VARCHAR2 DEFAULT NULL,
			X_attribute11			VARCHAR2 DEFAULT NULL,
			X_attribute12			VARCHAR2 DEFAULT NULL,
			X_attribute13			VARCHAR2 DEFAULT NULL,
			X_attribute14			VARCHAR2 DEFAULT NULL,
			X_attribute15			VARCHAR2 DEFAULT NULL,
 			X_error_message	 		OUT NOCOPY VARCHAR2,
			X_status		 	OUT NOCOPY NUMBER
		        );

PROCEDURE insert_event (X_rev_amt			REAL DEFAULT NULL,
			X_bill_amt			REAL DEFAULT NULL,
			X_project_id			NUMBER DEFAULT NULL,
			X_event_type			VARCHAR2 DEFAULT NULL,
			X_top_task_id			NUMBER DEFAULT NULL,
			X_organization_id		NUMBER DEFAULT NULL,
			X_completion_date		DATE DEFAULT NULL,
                       	X_event_description		VARCHAR2 DEFAULT NULL,
			X_event_num_reversed		NUMBER DEFAULT NULL,
			X_attribute_category		VARCHAR2 DEFAULT NULL,
                        X_attribute1			VARCHAR2 DEFAULT NULL,
                        X_attribute2			VARCHAR2 DEFAULT NULL,
                        X_attribute3			VARCHAR2 DEFAULT NULL,
                        X_attribute4			VARCHAR2 DEFAULT NULL,
                        X_attribute5			VARCHAR2 DEFAULT NULL,
                        X_attribute6			VARCHAR2 DEFAULT NULL,
                        X_attribute7			VARCHAR2 DEFAULT NULL,
                        X_attribute8			VARCHAR2 DEFAULT NULL,
                        X_attribute9			VARCHAR2 DEFAULT NULL,
                        X_attribute10			VARCHAR2 DEFAULT NULL,
                        X_audit_amount1	        IN      NUMBER DEFAULT NULL,
                        X_audit_amount2	        IN      NUMBER DEFAULT NULL,
                        X_audit_amount3	        IN      NUMBER DEFAULT NULL,
                        X_audit_amount4	        IN      NUMBER DEFAULT NULL,
                        X_audit_amount5	        IN      NUMBER DEFAULT NULL,
                        X_audit_amount6	        IN      NUMBER DEFAULT NULL,
                        X_audit_amount7	        IN      NUMBER DEFAULT NULL,
                        X_audit_amount8	        IN      NUMBER DEFAULT NULL,
                        X_audit_amount9	        IN      NUMBER DEFAULT NULL,
                        X_audit_amount10	IN      NUMBER DEFAULT NULL,
			X_audit_cost_budget_type_code IN      VARCHAR2 DEFAULT NULL,
			X_audit_rev_budget_type_code  IN      VARCHAR2 DEFAULT NULL,
                        X_inventory_org_id	IN      NUMBER   DEFAULT NULL,
                        X_inventory_item_id	IN      NUMBER   DEFAULT NULL,
                        X_quantity_billed	IN      NUMBER   DEFAULT NULL,
                        X_uom_code      	IN      VARCHAR2 DEFAULT NULL,
                        X_unit_price     	IN      NUMBER   DEFAULT NULL,
                        X_reference1      	IN      VARCHAR2 DEFAULT NULL,
                        X_reference2      	IN      VARCHAR2 DEFAULT NULL,
                        X_reference3      	IN      VARCHAR2 DEFAULT NULL,
                        X_reference4      	IN      VARCHAR2 DEFAULT NULL,
                        X_reference5      	IN      VARCHAR2 DEFAULT NULL,
                        X_reference6      	IN      VARCHAR2 DEFAULT NULL,
                        X_reference7      	IN      VARCHAR2 DEFAULT NULL,
                        X_reference8      	IN      VARCHAR2 DEFAULT NULL,
                        X_reference9      	IN      VARCHAR2 DEFAULT NULL,
                        X_reference10      	IN      VARCHAR2 DEFAULT NULL,
                        X_txn_currency_code  	           IN      VARCHAR2 DEFAULT NULL,
                        X_project_rate_type                IN      VARCHAR2 DEFAULT NULL,
			X_project_rate_date		   IN      DATE     DEFAULT NULL,
                        X_project_exchange_rate        	   IN      NUMBER   DEFAULT NULL,
                        X_project_func_rate_type           IN      VARCHAR2 DEFAULT NULL,
			X_project_func_rate_date	   IN      DATE     DEFAULT NULL,
                        X_project_func_exchange_rate       IN      NUMBER   DEFAULT NULL,
                        X_funding_rate_type                IN      VARCHAR2 DEFAULT NULL,
			X_funding_rate_date	           IN      DATE     DEFAULT NULL,
                        X_funding_exchange_rate            IN      NUMBER   DEFAULT NULL,
                        X_zero_revenue_amount_flag         IN      VARCHAR2 DEFAULT NULL,  /* Funding MRC Changes */
                        X_audit_cost_plan_type_id          IN      NUMBER   DEFAULT NULL, /* Added for Fin plan impact */
                        X_audit_rev_plan_type_id           IN      NUMBER   DEFAULT NULL, /* Added for Fin plan impact */
 			X_error_message	 	OUT NOCOPY     VARCHAR2,
			X_status	 	OUT NOCOPY     NUMBER
			);

function GET_MRC_FOR_FUND_FLAG return boolean;

-- Following APIs added for FP_M changes for Customer at Top Task
-- If the project is implemented with Top Task Customer enabled then
-- return the value as 'Y'
Function Get_Top_Task_Customer_Flag (
   	P_Project_ID  IN NUMBER
) Return Varchar2 ;

-- If the project is implemented with Invoice Method Override Flag enabled then
-- return the value as 'Y'
Function Get_Inv_Method_Override_Flag (
   	P_Project_ID  IN NUMBER
) Return Varchar2 ;
-- End of APIs added for FP_M changes

END pa_billing_pub;

 

/
