--------------------------------------------------------
--  DDL for Package PA_MULTI_CURRENCY_TXN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_MULTI_CURRENCY_TXN" AUTHID CURRENT_USER AS
--$Header: PAXMCTXS.pls 120.1.12000000.2 2007/06/26 11:38:31 sugupta ship $


/* This global variable is introduced to handle specific method of returning exchange rate for 'WORKPLAN' model
If the rate for the passed date is not defined then the rquirement is to get the rate of max(date) defined before the passed_date */

G_calling_module varchar2(30) := NULL;

/*----------------------------------------------------------------------------*/
-- Start of Comments
-- API Name      : get_projfunc_cost_rate_type
-- Type          : Public
-- Pre-Reqs      : None
-- Type          : Procedure
-- Function      : returns the project functional rate type
-- Parameters    :
-- IN
--           P_task_id  	               NUMBER
-- IN/OUT
--	     P_projfunc_currency_code  	       VARCHAR2
--	     P_projfunc_cost_rate_type         VARCHAR2
--
--------------
-- EPP Changes
--------------
-- This procedure was previously called as get_project_rate_type.

/*----------------------------------------------------------------------------*/

/*
 * PROCEDURE get_project_rate_type   (
 *       P_task_id  IN NUMBER ,
 * 	     P_project_currency_code  	       IN OUT VARCHAR2 ,
 * 	     P_project_rate_type               IN OUT VARCHAR2 ) ;
 *
 * pragma RESTRICT_REFERENCES(get_project_rate_type,WNDS,WNPS);
 */
PROCEDURE get_projfunc_cost_rate_type   (
         P_task_id                 IN NUMBER ,
	     P_project_id  	           IN pa_projects_all.project_id%TYPE DEFAULT NULL,
	     P_calling_module  	       IN VARCHAR2 DEFAULT 'GET_CURR_AMOUNTS',
         p_structure_version_id    IN NUMBER DEFAULT NULL,
	     P_projfunc_currency_code  IN OUT NOCOPY VARCHAR2 ,
   	     P_projfunc_cost_rate_type IN OUT NOCOPY VARCHAR2 ) ;

--pragma RESTRICT_REFERENCES(get_projfunc_cost_rate_type,WNDS,WNPS);

/*----------------------------------------------------------------------------*/
-- Start of Comments
-- API Name      : get_def_projfunc_cst_rate_type
-- Type          : Public
-- Pre-Reqs      : None
-- Type          : Procedure
-- Function      : returns the project functional rate type
-- Parameters    :
-- IN
--           P_task_id  	               NUMBER
-- IN/OUT
--	     P_projfunc_currency_code  	       VARCHAR2
--	     P_projfunc_cost_rate_type         VARCHAR2
--------------
-- EPP Changes
--------------
-- This procedure was previously called as get_default_project_rate_type.

/*----------------------------------------------------------------------------*/

/*
 * PROCEDURE get_default_project_rate_type   ( P_task_id  IN NUMBER ,
 * 	     P_project_currency_code  	       IN OUT VARCHAR2 ,
 * 	     P_project_rate_type               IN OUT VARCHAR2 ) ;
 * pragma RESTRICT_REFERENCES(get_default_project_rate_type, WNDS, WNPS);
 */
PROCEDURE get_def_projfunc_cst_rate_type   (
         P_task_id                 IN NUMBER ,
  	     P_projfunc_currency_code  IN OUT NOCOPY VARCHAR2 ,
  	     P_projfunc_cost_rate_type IN OUT NOCOPY VARCHAR2 ) ;
--pragma RESTRICT_REFERENCES(get_def_projfunc_cst_rate_type, WNDS, WNPS);
/*----------------------------------------------------------------------------*/
-- Start of Comments
-- API Name      : get_proj_curr_code_sql
-- Type          : Public
-- Pre-Reqs      : None
-- Type          : Function
-- Function      : returns the project Currency Code
-- Purity        : WNDS, WNPS
-- Parameters    :
-- IN
--           P_project_id  	               NUMBER
-- RETURNS
--	     P_project_currency_code  	       VARCHAR2

/*----------------------------------------------------------------------------*/

FUNCTION get_proj_curr_code_sql( P_project_id   NUMBER )
         RETURN    VARCHAR2 ;
--pragma RESTRICT_REFERENCES(get_proj_curr_code_sql,WNDS,WNPS);

/*----------------------------------------------------------------------------*/
-- Start of Comments
-- API Name      : get_projfunc_cost_rate_date
-- Type          : Public
-- Pre-Reqs      : None
-- Type          : Procedure
-- Function      : returns the project functional rate date
-- Parameters    :
-- IN
--           P_task_id  	               NUMBER
--           P_EI_date                         DATE
-- IN/OUT
--	     P_projfunc_cost_rate_date               VARCHAR2
--------------
-- EPP Changes
--------------
-- This procedure was previously called as get_project_rate_date.

/*----------------------------------------------------------------------------*/

/*
 * PROCEDURE get_project_rate_date ( P_task_id    IN NUMBER ,
 *                                   P_EI_date    IN DATE   ,
 * 				  P_project_rate_date IN OUT DATE );
 *
 * pragma RESTRICT_REFERENCES(get_project_rate_date,WNDS);
 */
PROCEDURE get_projfunc_cost_rate_date (
               P_task_id                 IN NUMBER ,
               P_project_id              IN pa_projects_all.project_id%TYPE DEFAULT NULL   ,
               P_EI_date                 IN DATE   ,
               P_structure_version_id    IN NUMBER DEFAULT NULL,
               P_calling_module          IN VARCHAR2 DEFAULT 'GET_CURR_AMOUNTS'   ,
               P_projfunc_cost_rate_date IN OUT NOCOPY DATE );

--pragma RESTRICT_REFERENCES(get_projfunc_cost_rate_date,WNDS); /**CBGA - removed WNPS**/


/*----------------------------------------------------------------------------*/
-- Start of Comments
-- API Name      : get_def_projfunc_cst_rate_date
-- Type          : Public
-- Pre-Reqs      : None
-- Type          : Procedure
-- Function      : returns the project functional rate date
-- Parameters    :
-- IN
--           P_task_id  	               NUMBER
--           P_EI_date                         DATE
-- IN/OUT
--	     P_projfunc_cost_rate_date               VARCHAR2
--------------
-- EPP Changes
--------------
-- This procedure was previously called as get_default_project_rate_date.

/*----------------------------------------------------------------------------*/

/*
 * PROCEDURE get_default_project_rate_date ( P_task_id    IN NUMBER ,
 *                                   P_EI_date    IN DATE   ,
 * 				  P_project_rate_date IN OUT DATE );
 * pragma RESTRICT_REFERENCES(get_default_project_rate_date, WNDS, WNPS);
 */
PROCEDURE get_def_projfunc_cst_rate_date (
               P_task_id                 IN NUMBER ,
               P_project_id              IN pa_projects_all.project_id%TYPE DEFAULT NULL   ,
               P_EI_date                 IN DATE   ,
               p_structure_version_id    IN NUMBER DEFAULT NULL,
               P_calling_module          IN VARCHAR2 DEFAULT 'GET_CURR_AMOUNTS'   ,
               P_projfunc_cost_rate_date IN OUT NOCOPY DATE );
--pragma RESTRICT_REFERENCES(get_def_projfunc_cst_rate_date, WNDS, WNPS);
/*----------------------------------------------------------------------------*/
-- Start of Comments
-- API Name      : get_acct_rate_date
-- Type          : Public
-- Pre-Reqs      : None
-- Type          : Procedure
-- Function      : returns the acct rate date
-- Parameters    :
-- IN
--           P_EI_date                         DATE
-- IN/OUT
--	     P_acct_rate_date                  VARCHAR2

/*----------------------------------------------------------------------------*/

PROCEDURE get_acct_rate_date (
               P_EI_date        IN DATE   ,
		       P_acct_rate_date IN OUT NOCOPY DATE );

--pragma RESTRICT_REFERENCES(get_acct_rate_date,WNDS); /**CBGA - removed WNPS**/

/*----------------------------------------------------------------------------*/
-- Start of Comments
-- API Name      : get_default_acct_rate_date
-- Type          : Public
-- Pre-Reqs      : None
-- Type          : Procedure
-- Function      : returns the acct rate date
-- Parameters    :
-- IN
--           P_EI_date                         DATE
-- IN/OUT
--	     P_acct_rate_date                  VARCHAR2

/*----------------------------------------------------------------------------*/
PROCEDURE get_default_acct_rate_date ( P_EI_date        IN DATE   ,
                                       P_acct_rate_date IN OUT NOCOPY DATE );
--pragma RESTRICT_REFERENCES(get_default_acct_rate_date, WNDS, WNPS);

/*----------------------------------------------------------------------------*/
-- Start of Comments
-- API Name      : get_currency_amounts
-- Type          : Public
-- Pre-Reqs      : None
-- Type          : Procedure
-- Function      : returns the project and functional raw costs.
--		   If the conversion attributes are not passed in then
--		   this procedure will derive the conversion attributes
-- 		   from the project/task/implementation option setup tables.
--		   When functional and project currencies are same, this
--		   procedure will make sure the respective conversion attributes
--		   are identical.
-- Exceptions	 : Conversion Type 'User'Not allowed
--		   Conversion rate not available for conversion type 'User'
--		   Cannot find conversion rate in gl.
--		   Invalid currency code
-- Parameters    :
-- IN
--           P_task_id  	   NUMBER
--           P_EI_date             DATE
--           P_denom_raw_cost      NUMBER
--           P_denom_curr_code     VARCHAR2
--           P_acct_curr_code      VARCHAR2
--	          P_project_curr_code   VARCHAR2
--           P_accounted_flag      VARCHAR2
-- IN/OUT
--	     P_project_rate_type      VARCHAR2
--	     P_project_rate_date      DATE
--      P_project_exchange_rate  NUMBER
--      P_acct_rate_date         DATE
--      P_acct_rate_type         VARCHAR2
--      P_acct_exchange_rate     NUMBER
--	     P_raw_cost               NUMBER
--      P_status                 VARCHAR2
--      P_stage                  NUMBER
--------------
-- EPP Changes
--------------
-- Added 6 more parameters.
-- P_project_raw_cost
-- P_projfunc_curr_code
-- P_projfunc_cost_rate_type
-- P_projfunc_cost_rate_date
-- P_projfunc_exch_rate
-- P_raw_cost
-- P_system_linkage
/** The same API is called from Transactions Adjustments and Forecast Items
 *  so new parameters are added to handle the same API when it is called from
 *  Forecast module
 *  The P_calling_module = 'GET_CURR_AMOUNTS' for Transactions
 *      P_calling_module = 'FORECAST' for FIs
 *      P_calling_module = 'WORKPLAN' for Workplan
 *      Defaulting System_Linkage_Function to 'NER' meaning Not-ER. Special
 *      handling is required only for ER transactions. Hence the above.
 **/
PROCEDURE get_currency_amounts (
          	/** Added the following new params for the FI calls **/
           		P_project_id        IN  NUMBER DEFAULT NULL,
           		P_exp_org_id        IN  NUMBER DEFAULT NULL,
           		P_calling_module    IN  VARCHAR2 DEFAULT 'GET_CURR_AMOUNTS',
          	/** End of FI changes **/
			P_task_id  	              IN NUMBER,
         	P_EI_date                 IN DATE,
			P_denom_raw_cost          IN NUMBER,
			P_denom_curr_code	      IN VARCHAR2,
			P_acct_curr_code	      IN VARCHAR2,
			P_accounted_flag          IN VARCHAR2 DEFAULT 'N',
			P_acct_rate_date	      IN OUT NOCOPY DATE,
			P_acct_rate_type	      IN OUT NOCOPY VARCHAR2,
			P_acct_exch_rate	      IN OUT NOCOPY NUMBER,
			P_acct_raw_cost           IN OUT NOCOPY NUMBER,
			P_project_curr_code	      IN VARCHAR2,
			P_project_rate_type	      IN OUT NOCOPY VARCHAR2 ,
			P_project_rate_date	      IN OUT NOCOPY DATE,
			P_project_exch_rate	      IN OUT NOCOPY NUMBER,
			P_project_raw_cost        IN OUT NOCOPY NUMBER,
			P_projfunc_curr_code	  IN VARCHAR2,
			P_projfunc_cost_rate_type IN OUT NOCOPY VARCHAR2 ,
			P_projfunc_cost_rate_date IN OUT NOCOPY DATE,
			P_projfunc_cost_exch_rate IN OUT NOCOPY NUMBER,
			P_projfunc_raw_cost       IN OUT NOCOPY NUMBER,
			P_system_linkage          IN pa_expenditure_items_all.system_linkage_function%TYPE DEFAULT 'NER',
			P_structure_version_id    IN NUMBER DEFAULT NULL,
			P_status		          OUT NOCOPY VARCHAR2,
			P_stage			          OUT NOCOPY NUMBER,
            P_Po_Line_ID              IN  NUMBER DEFAULT NULL /* Bug : 3535935 */
                       ) ;

--pragma RESTRICT_REFERENCES(get_currency_amounts,WNDS); /**CBGA removed WNPS**/
/*----------------------------------------------------------------------------*/
/*
 * IC related changes:
 * New procedure added to perform MC and IC processings necessary
 * in the cost distribution programs. In addition to that, this new
 * procedure will take care of calling the client extension for
 * Labor program.
 */
PROCEDURE Perform_MC_and_IC_processing(
            P_Sys_Link            IN  VARCHAR2,
            P_Request_Id          IN  NUMBER,
            P_Source              OUT NOCOPY VARCHAR2,
            P_MC_IC_status        OUT NOCOPY NUMBER,
            P_Update_Count        OUT NOCOPY NUMBER);
/*----------------------------------------------------------------------------*/
-- Start of Comments
-- API Name      : get_proj_rate_type
-- Type          : Public
-- Pre-Reqs      : None
-- Type          : Procedure
-- Function      : returns the project rate type
-- Parameters    :
-- IN
--           P_task_id                         NUMBER
-- IN/OUT
--           P_project_currency_code       VARCHAR2
--           P_project_rate_type           VARCHAR2
--
/*----------------------------------------------------------------------------*/

PROCEDURE get_proj_rate_type   ( P_task_id               IN NUMBER ,
                                 P_project_id            IN pa_projects_all.project_id%TYPE DEFAULT NULL,
                                 P_structure_version_id  IN NUMBER DEFAULT NULL,
                                 P_calling_module        IN VARCHAR2 DEFAULT 'GET_CURR_AMOUNTS',
                                 P_project_currency_code IN OUT NOCOPY VARCHAR2 ,
                                 P_project_rate_type     IN OUT NOCOPY VARCHAR2 ) ;

--pragma RESTRICT_REFERENCES(get_proj_rate_type,WNDS,WNPS);
/*----------------------------------------------------------------------------*/
-- Start of Comments
-- API Name      : get_proj_rate_date
-- Type          : Public
-- Pre-Reqs      : None
-- Type          : Procedure
-- Function      : returns the project rate date
-- Parameters    :
-- IN
--           P_task_id                         NUMBER
--           P_EI_date                         DATE
-- IN/OUT
--           P_project_rate_date               VARCHAR2
/*----------------------------------------------------------------------------*/

PROCEDURE get_proj_rate_date ( P_task_id              IN NUMBER ,
                               P_project_id           IN pa_projects_all.project_id%TYPE DEFAULT NULL   ,
                               P_EI_date              IN DATE   ,
                               p_structure_version_id IN NUMBER DEFAULT NULL,
                               P_calling_module       IN VARCHAR2 DEFAULT 'GET_CURR_AMOUNTS' ,
                               P_project_rate_date    IN OUT NOCOPY DATE );

--pragma RESTRICT_REFERENCES(get_proj_rate_date,WNDS);
/*----------------------------------------------------------------------------*/
/** Added new params p_project_id, p_exp_org_id to call this api from FORECAST modules
 *  when p_calling_module = 'FORECAST' p_task_id will be null and p_ei_date = FI date
 **/
PROCEDURE get_currency_attributes (
			   P_project_id              IN pa_projects_all.project_id%type default NULL,
           	   P_exp_org_id              IN pa_projects_all.org_id%type default NULL,
			   P_task_id                 IN pa_expenditure_items_all.task_id%TYPE,
               P_ei_date                 IN pa_expenditure_items_all.expenditure_item_date%TYPE,
               P_calling_module          IN VARCHAR2,
               P_denom_curr_code         IN pa_expenditure_items_all.denom_currency_code%TYPE,
               P_accounted_flag          IN VARCHAR2 DEFAULT 'N',
               P_acct_curr_code          IN pa_expenditure_items_all.acct_currency_code%TYPE,
               X_acct_rate_date          IN OUT NOCOPY pa_expenditure_items_all.acct_rate_date%TYPE,
               X_acct_rate_type          IN OUT NOCOPY pa_expenditure_items_all.acct_rate_type%TYPE,
               X_acct_exch_rate          IN OUT NOCOPY pa_expenditure_items_all.acct_exchange_rate%TYPE,
               P_project_curr_code       IN pa_expenditure_items_all.project_currency_code%TYPE,
               X_project_rate_date       IN OUT NOCOPY pa_expenditure_items_all.project_rate_date%TYPE,
               X_project_rate_type       IN OUT NOCOPY pa_expenditure_items_all.project_rate_type%TYPE ,
               X_project_exch_rate       IN OUT NOCOPY pa_expenditure_items_all.project_exchange_rate%TYPE,
               P_projfunc_curr_code      IN pa_expenditure_items_all.projfunc_currency_code%TYPE,
               X_projfunc_cost_rate_date IN OUT NOCOPY pa_expenditure_items_all.projfunc_cost_rate_date%TYPE,
               X_projfunc_cost_rate_type IN OUT NOCOPY pa_expenditure_items_all.projfunc_cost_rate_type%TYPE ,
               X_projfunc_cost_exch_rate IN OUT NOCOPY pa_expenditure_items_all.projfunc_cost_exchange_rate%TYPE,
               P_system_linkage          IN pa_expenditure_items_all.system_linkage_function%TYPE,
               P_structure_version_id    IN NUMBER DEFAULT NULL,
               X_status                  OUT NOCOPY VARCHAR2,
               X_stage                   OUT NOCOPY NUMBER) ;

--pragma RESTRICT_REFERENCES(get_currency_attributes,WNDS); /**CBGA removed WNPS**/

/*----------------------------------------------------------------------------*/

END pa_multi_currency_txn ;

 

/
