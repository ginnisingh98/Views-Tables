--------------------------------------------------------
--  DDL for Package Body PA_REV_CA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_REV_CA" AS
/*$Header: PAXICOSB.pls 120.1.12010000.2 2008/09/25 08:56:47 dlella ship $*/

/*****************************************************************************
-- Global variables to store the attribute12 - 15 columns of
-- pa_billing_extensions table
 ****************************************************************************/

 g_ca_event_type         VARCHAR2(30);
 g_ca_contra_event_type  VARCHAR2(30);
 g_ca_wip_event_type     VARCHAR2(30);
 g_ca_budget_type        VARCHAR2(1) ;


/***************************************************************************

 Private Procedures and Functions

****************************************************************************/
--
-- Function to check if closing entries have been created for project and top task
--
g1_debug_mode varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

Function  Check_Closing_done
			(X_project_id NUMBER,
			 X_task_id    NUMBER DEFAULT NULL
			)
RETURN VARCHAR2
IS
l_count   INTEGER;
BEGIN

--
-- If closing entries have been created then attribute10 for pa_events
-- will be prefixed with CLOSE and they should not be reversed
--
-- If top task id is NULL then its project level check
--
SELECT count(*)
INTO   l_count
from   pa_events e
WHERE  e.project_id = X_project_id
and    nvl(e.task_id,0) =
			decode(X_task_id,
				NULL, 	nvl(e.task_id,0), X_task_id )
and     e.attribute10 LIKE 'CLOSE%'
and     NOT EXISTS
                 ( SELECT 'x'
                   from pa_events pe
                   WHERE pe.project_id = X_project_id
                   and   nvl(pe.task_id,0) =
                        decode(X_task_id,
                                NULL,   nvl(pe.task_id,0), X_task_id )
                   and   pe.attribute10 LIKE 'REV%'
                   and   pe.event_num_reversed = e.event_num
                 )
;

-- If more than one row is returned then Closing entries have been created
--
IF l_count > 0 THEN
   RETURN 'Y';
ELSE
   RETURN 'N';
END IF;

EXCEPTION
    WHEN OTHERS THEN
         RETURN ('N');
END Check_Closing_done ;

--
-- Procedure that returns the revenue accrued to date for project and top task
--
Procedure GetCurrentRevenue(  	X_project_id NUMBER,
	 			X_task_Id   NUMBER DEFAULT NULL,
				X_revenue_amount OUT NOCOPY REAL) IS

accrued_rev	REAL;

BEGIN

-- Revenue that has been accrued till date.
-- If top task id is NULL then sum revenue at project level
--
/* Change this column from amount to projfunc_revenue_amount for MCB2 */

SELECT sum(nvl(dri.projfunc_revenue_amount,0))
INTO   accrued_rev
FROM   pa_draft_revenue_items dri
WHERE  dri.project_id = X_project_id
AND    nvl(dri.task_id,0) =
        decode(X_task_id, NULL, nvl(dri.task_id,0), X_task_id);

X_revenue_amount := nvl(accrued_rev,0);
EXCEPTION
WHEN OTHERS THEN
	X_revenue_amount := NULL;
END GetCurrentRevenue;

--
-- Procedure that returns the cost accrual to date for a project and top task id
--
Procedure GetCostAccrued (X_project_id NUMBER,
	 		  X_task_Id   NUMBER DEFAULT NULL,
			  X_cost_accrued OUT NOCOPY REAL) IS
cost_accrued REAL := 0;
BEGIN
--
-- sum up the events with event type as g_ca_event_type , which is the event type
-- for COST ACCRUAL
-- If top task id is NULL them sum up at project level
--
/* Change this column from revenue_amount to projfunc_revenue_amount for MCB2 */
/* Bug 2956009 changed column projfunc_revenue_amount to bill_trans_rev_amount.
Since projfunc_revenue_amount will not be calculated till revenue process picks
up events created in the same run (reversing entries) ..
hence results in additional events getting created.
*/
	SELECT 	sum(nvl(e.bill_trans_rev_amount,0))
	INTO    cost_accrued
	FROM 	pa_events e
	where	e.project_id = X_project_id
	and    	nvl(e.task_id,0) =
			decode(X_task_id,
				NULL, 	nvl(e.task_id,0), X_task_id )
	and     e.event_type = g_ca_event_type
	;
-- COST ACCRUAL is stored as a negative amount since its a debit to the account
-- so reverse the sign to get the proper amount
--
X_cost_accrued := (-1) * nvl(cost_accrued,0) ;
EXCEPTION
WHEN OTHERS THEN
X_cost_accrued := NULL;
END GetCostAccrued;

-- Procedure that returns the cost accrual contra to date for a project and top task id
--
Procedure GetCostAccruedContra (X_project_id NUMBER,
	 		  X_task_Id   NUMBER DEFAULT NULL,
			  X_cost_accrued OUT NOCOPY REAL) IS
cost_accrued REAL := 0;
BEGIN
--
-- sum up the events with event type as g_ca_contra_event_type , which is the
-- event type for COST ACCRUAL CONTRA
-- If top task id is NULL them sum up at project level
--
/* Change this column from revenue_amount to projfunc_revenue_amount for MCB2 */
/* Bug 2956009 changed column projfunc_revenue_amount to bill_trans_rev_amount.
Since projfunc_revenue_amount will not be calculated till revenue process picks
up events created in the same run (reversing entries) ..
hence results in additional events getting created.
*/
	SELECT 	sum(nvl(e.bill_trans_rev_amount,0))
	INTO    cost_accrued
	FROM 	pa_events e
	where	e.project_id = X_project_id
	and    	nvl(e.task_id,0) =
			decode(X_task_id,
				NULL, 	nvl(e.task_id,0), X_task_id )
	and     e.event_type = g_ca_contra_event_type
	;
X_cost_accrued := nvl(cost_accrued,0) ;
EXCEPTION
WHEN OTHERS THEN
X_cost_accrued := NULL;
END GetCostAccruedContra;
--
-- Procedure that returns the cost WIP amount from events that has been created as
-- part of closing procedure for a project and top task id
--
Procedure GetCostWIP     (X_project_id NUMBER,
	 		  X_task_Id   NUMBER DEFAULT NULL,
			  X_cost_accrued OUT NOCOPY  REAL) IS
cost_accrued REAL := 0;
BEGIN
--
-- sum up the events with event type as g_ca_wip_event_type , which is the
-- event type for COST WIP
-- If top task id is NULL them sum up at project level
--
/* Change this column from revenue_amount to projfunc_revenue_amount for MCB2 */
/* Bug 2956009 changed column projfunc_revenue_amount to bill_trans_rev_amount.
Since projfunc_revenue_amount will not be calculated till revenue process picks
up events created in the same run (reversing entries) ..
hence results in additional events getting created.
*/
	SELECT 	sum(nvl(e.bill_trans_rev_amount,0))
	INTO    cost_accrued
	FROM 	pa_events e
	where	e.project_id = X_project_id
	and    	nvl(e.task_id,0) =
			decode(X_task_id,
				NULL, 	nvl(e.task_id,0), X_task_id )
	and     e.event_type = g_ca_wip_event_type
	;
X_cost_accrued := nvl(cost_accrued,0) ;
EXCEPTION
WHEN OTHERS THEN
X_cost_accrued := NULL;
END GetCostWIP;
--
-- Procedure that returns the cost budget and revenue budget amount
-- This procedure is same as the public api pa_billing_pub.get_budget_amount
-- the only difference in this case the raw cost is used for cost budget amount
--
PROCEDURE get_budget_amount( X2_project_id       NUMBER,
			 X2_task_id              NUMBER DEFAULT NULL,
			 X2_revenue_amount       OUT NOCOPY REAL,
			 X2_cost_amount    	 OUT NOCOPY  REAL,
                         P_cost_budget_type_code IN VARCHAR2 DEFAULT NULL,
                         P_rev_budget_type_code  IN VARCHAR2 DEFAULT NULL,
                         P_cost_plan_type_id     IN NUMBER DEFAULT NULL, /* Added for Fin plan impact */
                         P_rev_plan_type_id      IN NUMBER DEFAULT NULL, /* Added for Fin plan impact */
                         X_cost_budget_type_code OUT NOCOPY  VARCHAR2,
                         X_rev_budget_type_code  OUT NOCOPY VARCHAR2,
			 X_error_message	 OUT NOCOPY VARCHAR2,
			 X_status		 OUT NOCOPY NUMBER
			 ) IS

-- local variables for budget codes
l_cost_budget_type_code VARCHAR2(30) ;
l_rev_budget_type_code  VARCHAR2(30) ;
l_cost_budget_status_code VARCHAR2(1) ;
l_rev_budget_status_code  VARCHAR2(1) ;
dummy                     CHAR(1);
err_msg			  VARCHAR2(240);
err_status                NUMBER;
status			  VARCHAR2(240);
l_status                 NUMBER;
l_cost_budget_version_id      NUMBER;
l_rev_budget_version_id       NUMBER;
l_raw_cost_total              REAL := 0;
l_revenue_total               REAL := 0;
l_quantity_total              NUMBER;
l_burdened_cost_total         NUMBER;
l_err_code                    NUMBER;
l_err_stage                   VARCHAR2(30);
l_err_stack                   VARCHAR2(630);

/* Added for Fin Plan Impact */
l_cost_plan_type_id                NUMBER;
l_rev_plan_type_id                 NUMBER;
l_cost_plan_version_id             NUMBER;
l_rev_plan_version_id              NUMBER;
/* Till here */

invalid_cost_budget_code EXCEPTION;
invalid_rev_budget_code  EXCEPTION;
rev_budget_not_baselined EXCEPTION;
cost_budget_not_baselined EXCEPTION;

BEGIN
   X_status := 0;
   X_error_message := NULL;
   BEGIN
-- If user doesnt provide the budget get the default value from biling extensions
--

   IF (P_cost_budget_type_code IS NULL OR P_rev_budget_type_code IS NULL
      OR P_cost_plan_type_id IS NULL OR P_rev_plan_type_id IS NULL ) /* Added for Fin plan impact */
       THEN

      SELECT   DECODE(P_cost_budget_type_code,NULL,default_cost_budget_type_code, P_cost_budget_type_code),
               DECODE(P_rev_budget_type_code,NULL,default_rev_budget_type_code,P_rev_budget_type_code),
               DECODE(P_cost_plan_type_id,NULL,default_cost_plan_type_id,
                      P_cost_plan_type_id),                  /* Added for Fin plan impact */
               DECODE(P_rev_plan_type_id,NULL,default_rev_plan_type_id,
                      P_rev_plan_type_id)                  /* Added for Fin plan impact */
      INTO     l_cost_budget_type_code,
	       l_rev_budget_type_code,
               l_cost_plan_type_id,
               l_rev_plan_type_id
      FROM     pa_billing_extensions
      WHERE    billing_extension_id=pa_billing.GetBillingExtensionId;

   END IF;


  -- The plan code should be a valid code and of the right version type
  -- If invalid then process will check for budget code
  /* Added this select for Fin plan Impact */
  BEGIN
   SELECT  'x'
   INTO    dummy
   FROM    dual
   WHERE   EXISTS( SELECT *
                   FROM pa_fin_plan_types_b f
                   WHERE f.fin_plan_type_id=l_cost_plan_type_id );

  EXCEPTION
   WHEN NO_DATA_FOUND THEN

    -- The budget code should be a valid code and of the right amount code
    -- If invalid then raise appropriate exception

    BEGIN

      SELECT  'x'
      INTO    dummy
      FROM    pa_budget_types
      WHERE   budget_type_code = l_cost_budget_type_code
      AND     budget_amount_code = 'C';

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
	 raise invalid_cost_budget_code;
    END;

  END; /* End of newly added code for Fin plan Impact */



  /* Added this select for Fin plan Impact */
  BEGIN
   SELECT  'x'
   INTO    dummy
   FROM    dual
   WHERE   EXISTS( SELECT *
                   FROM  pa_fin_plan_types_b f
                   WHERE f.fin_plan_type_id=l_rev_plan_type_id );

  EXCEPTION
   WHEN NO_DATA_FOUND THEN

    -- The budget code should be a valid code and of the right amount code
    -- If invalid then raise appropriate exception

    BEGIN

      SELECT  'x'
      INTO    dummy
      FROM    pa_budget_types
      WHERE   budget_type_code = l_rev_budget_type_code
      AND     budget_amount_code = 'R';

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
	 raise invalid_rev_budget_code;
    END ;

  END; /* End of newly added code for Fin plan Impact *



  -- Get the budget version id for cost and revenue plan
  -- Changed to use api pa_budget_utils.get_project_task_totals

  /* Added this select for Fin plan Impact */
  BEGIN

   SELECT v.budget_version_id
   INTO   l_cost_plan_version_id
   FROM   pa_budget_versions v
   WHERE  v.project_id = X2_project_id
   AND    v.current_flag = 'Y'
   AND    v.budget_status_code           = 'B'
   AND    v.fin_plan_type_id             = l_cost_plan_type_id
   AND    v.version_type IN ('COST','ALL');

  EXCEPTION
   WHEN NO_DATA_FOUND THEN
    --
    -- get the budget version id for cost and revenue budget
    -- call api pa_budget_utils.get_project_task_totals for budget amounts
    --

    BEGIN
      SELECT budget_version_id
      INTO   l_cost_budget_version_id
      FROM   pa_budget_versions pbv
      WHERE  project_id = X2_project_id
      AND    budget_type_code = l_cost_budget_type_code
      AND    budget_status_code = 'B'
      AND    current_flag = 'Y';

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
         raise cost_budget_not_baselined;
   END;

  END; /* End of newly added code for Fin plan Impact */

   l_cost_budget_version_id  := NVL(l_cost_plan_version_id,l_cost_budget_version_id);



  /* Added this select for Fin plan Impact */
  BEGIN

   SELECT v.budget_version_id
   INTO   l_rev_plan_version_id
   FROM   pa_budget_versions v
   WHERE  v.project_id = X2_project_id
   AND    v.current_flag = 'Y'
   AND    v.budget_status_code           = 'B'
   AND    v.fin_plan_type_id             = l_rev_plan_type_id
   AND    v.version_type IN ('REVENUE','ALL');

  EXCEPTION
   WHEN NO_DATA_FOUND THEN
    --
    -- get the budget version id for cost and revenue budget
    -- Changed to use api pa_budget_utils.get_project_task_totals
    --

    BEGIN

      SELECT budget_version_id
      INTO   l_rev_budget_version_id
      FROM   pa_budget_versions pbv
      WHERE  project_id = X2_project_id
      AND    budget_type_code = l_rev_budget_type_code
      AND    budget_status_code = 'B'
      AND    current_flag = 'Y';

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
          raise rev_budget_not_baselined;
    END;

  END; /* End of newly added code for Fin plan Impact */

   l_rev_budget_version_id  := NVL(l_rev_plan_version_id,l_rev_budget_version_id);


   -- Call api to get cost budget amount
   --
   pa_budget_utils.get_project_task_totals
           (l_cost_budget_version_id ,
                            x2_task_id ,
                            l_quantity_total,
                            l_raw_cost_total ,
                            l_burdened_cost_total ,
                            l_revenue_total ,
                            l_err_code ,
                            l_err_stage,
                            l_err_stack );

X2_cost_amount := pa_currency.round_currency_amt(l_burdened_cost_total);

   -- Call api to get revenue budget amount
   --
   pa_budget_utils.get_project_task_totals
           (l_rev_budget_version_id ,
                            x2_task_id ,
                            l_quantity_total,
                            l_raw_cost_total ,
                            l_burdened_cost_total ,
                            l_revenue_total ,
                            l_err_code ,
                            l_err_stage,
                            l_err_stack );

X2_revenue_amount := pa_currency.round_currency_amt(l_revenue_total);

X_cost_budget_type_code := l_cost_budget_type_code;
X_rev_budget_type_code  := l_rev_budget_type_code;

-- If any exception then raise it to the calling pl/sql block
--
   EXCEPTION
     WHEN invalid_cost_budget_code THEN
  	 status := pa_billing_values.get_message('INVALID_COST_BUDGET_TYPE');
	 l_status := 1;
	 RAISE_APPLICATION_ERROR(-20101,status);
     WHEN invalid_rev_budget_code  THEN
  	 status := pa_billing_values.get_message('INVALID_REV_BUDGET_TYPE');
	 l_status := 2;
	 RAISE_APPLICATION_ERROR(-20101,status);
     WHEN rev_budget_not_baselined  THEN
         status := pa_billing_values.get_message('REV_BUDGET_NOT_BASELINED');
	 l_status := 3;
	 RAISE_APPLICATION_ERROR(-20101,status);
     WHEN cost_budget_not_baselined THEN
         status := pa_billing_values.get_message('COST_BUDGET_NOT_BASELINED');
	 l_status := 4;
	 RAISE_APPLICATION_ERROR(-20101,status);
     WHEN OTHERS THEN
         status := substr(SQLERRM,1,240);
	 l_status := sqlcode;
	 RAISE;
     END;

EXCEPTION
	WHEN OTHERS THEN
--	DBMS_OUTPUT.PUT_LINE(status);
--	DBMS_OUTPUT.PUT_LINE(SQLERRM);
	X2_cost_amount := NULL;
	X2_revenue_amount := NULL;
	X_cost_budget_type_code := NULL;
	X_rev_budget_type_code  := NULL;
----

        X_error_message := status;
	X_status	:= l_status;

	pa_billing_pub.insert_message
        (X_inserting_procedure_name =>'pa_rev_ca.get_budget_amount',
	 X_attribute1 => l_cost_budget_type_code,
	 X_attribute2 => l_rev_budget_type_code,
	 X_message => status,
         X_error_message=>err_msg,
         X_status=>err_status);

	 IF (l_status < 0 OR NVL(err_status,0) <0) THEN
	 RAISE;
	 END IF;

END get_budget_amount;

--
-- Procedure that creates reverses closing entries (if any) when project
-- status is changed back from PENDING CLOSE to ACTIVE
--
Procedure  ReverseClosingEntries
                                (X_project_id 	 NUMBER,
 		  		 X_task_id 	 NUMBER DEFAULT NULL,
				 X_request_id    NUMBER DEFAULT NULL,
				 X_error_message OUT NOCOPY VARCHAR2,
				 X_status	 OUT NOCOPY NUMBER
				)
IS
event_description	VARCHAR2(240);
l_event_set_id	VARCHAR2(150);
l_error_message VARCHAR2(240);
l_status        NUMBER;
BEGIN
-- Select the events from pa_events which have been created for closing
-- entries.The attribute10 column will be prefixed with CLOSE
-- Also check if there are no reversing events already created , the
-- reversing events can be identified from column attribute10  prefixed
-- with REV and column event_num_reversed will have the number of the
-- event reversed
-- For each row do the following
FOR r_rec IN
(
SELECT  *
from   pa_events e
WHERE  e.project_id = X_project_id
and    nvl(e.task_id,0) =
			decode(X_task_id,
				NULL, 	nvl(e.task_id,0), X_task_id )
and     e.attribute10 LIKE 'CLOSE%'
and     NOT EXISTS
		 ( SELECT 'x'
		   from pa_events pe
	           WHERE pe.project_id = X_project_id
		   and   nvl(pe.task_id,0) =
			decode(X_task_id,
				NULL, 	nvl(pe.task_id,0), X_task_id )
		   and   pe.attribute10 LIKE 'REV%'
                   and   pe.event_num_reversed = e.event_num
		 )
)
LOOP

-- Event description will show the event number reversed by this event
--
   Event_Description := 'reversing event num = ' || r_rec.event_num;

--
-- event_set_id is stored in attribute10 column of pa_events table
-- this helps in identifying why the event was created i.e. reversing 'REV'
-- closing 'CLOSE' .
-- event_set_id  also helps in identifying the events which were created
-- at the same time , i.e. events for Cost Accrual , Cost WIP and Cost Accrual
-- contra will have the same event_set_id
--
   l_event_set_id := 'REV-' ||x_project_id||'-'||nvl(x_task_id,0)||'-'
			       ||nvl(x_request_id,0);

--
-- Use the public api to create reversing events for each row
--
   pa_billing_pub.insert_event (
			X_rev_amt => (-1) * r_rec.revenue_amount,
			X_bill_amt => 0,
                       	X_event_type =>r_rec.event_type ,
                       	X_event_description => event_description,
                        X_event_num_reversed => r_rec.event_num,
                        X_attribute10 => l_event_set_id,
                        X_audit_amount1 => r_rec.audit_amount1,
                        X_audit_amount2 => r_rec.audit_amount2,
                        X_audit_amount3 => r_rec.audit_amount3,
                        X_audit_amount4 => r_rec.audit_amount4,
                        X_audit_cost_budget_type_code => r_rec.audit_cost_budget_type_code,
                        X_audit_rev_budget_type_code => r_rec.audit_rev_budget_type_code,
			X_error_message =>l_error_message,
			X_status => l_status);

   IF l_status <> 0 THEN
      X_status := l_status ;
      EXIT ;
   END IF;


END LOOP;
EXCEPTION
WHEN OTHERS THEN
X_status := NULL;
X_error_message := NULL;
END ReverseClosingEntries;

--
-- Procedure that creates the cost accrual , cost accrual contra entries
-- when the project status is 'ACTIVE'
--
Procedure CreateNormalEntries (
			X_project_id                    NUMBER,
	             	X_top_task_id                   NUMBER DEFAULT NULL,
                        X_revenue_amount 		NUMBER,
                        X_budget_revenue 		NUMBER,
                        X_budget_cost	 		NUMBER,
                        X_cost_accrued	 		NUMBER,
                        X_audit_cost_budget_type_code   VARCHAR2,
                        X_audit_rev_budget_type_code    VARCHAR2,
                     	X_request_id      	        NUMBER DEFAULT NULL,
                        X_cost_plan_type_id        IN   NUMBER , /* Added for Fin plan impact */
                        X_rev_plan_type_id         IN   NUMBER , /* Added for Fin plan impact */
			X_error_message   		OUT NOCOPY VARCHAR2,
			X_status 	  		OUT NOCOPY NUMBER
			)
IS
cost_accrual REAL := 0;
l_status     NUMBER := 0;
l_error_message VARCHAR2(240);
l_event_set_id	VARCHAR2(150);
event_description	VARCHAR2(240);
l_currency_code         VARCHAR2(15);

/* Declaring varible for MCB2 */
l_multi_currency_billing_flag     pa_projects_all.MULTI_CURRENCY_BILLING_FLAG%TYPE;
l_baseline_funding_flag           pa_projects_all.BASELINE_FUNDING_FLAG%TYPE;
l_revproc_currency_code           pa_projects_all.revproc_currency_code%TYPE;
l_revproc_rate_type               pa_events.revproc_rate_type%TYPE;
l_revproc_rate_date               pa_events.revproc_rate_date%TYPE;
l_revproc_exchange_rate           pa_events.revproc_exchange_rate%TYPE;
l_invproc_currency_code           pa_events.invproc_currency_code%TYPE;
l_invproc_currency_type           pa_projects_all.invproc_currency_type%TYPE;
l_invproc_rate_type               pa_events.invproc_rate_type%TYPE;
l_invproc_rate_date               pa_events.invproc_rate_date%TYPE;
l_invproc_exchange_rate           pa_events.invproc_exchange_rate%TYPE;
l_project_currency_code           pa_projects_all.project_currency_code%TYPE;
l_project_bil_rate_date_code      pa_projects_all.project_bil_rate_date_code%TYPE;
l_project_bil_rate_type           pa_projects_all.project_bil_rate_type%TYPE;
l_project_bil_rate_date           pa_projects_all.project_bil_rate_date%TYPE;
l_project_bil_exchange_rate       pa_projects_all.project_bil_exchange_rate%TYPE;
l_projfunc_currency_code          pa_projects_all.projfunc_currency_code%TYPE;
l_projfunc_bil_rate_date_code     pa_projects_all.projfunc_bil_rate_date_code%TYPE;
l_projfunc_bil_rate_type          pa_projects_all.projfunc_bil_rate_type%TYPE;
l_projfunc_bil_rate_date          pa_projects_all.projfunc_bil_rate_date%TYPE;
l_projfunc_bil_exchange_rate      pa_projects_all.projfunc_bil_exchange_rate%TYPE;
l_funding_rate_date_code          pa_projects_all.funding_rate_date_code%TYPE;
l_funding_rate_type               pa_projects_all.funding_rate_type%TYPE;
l_funding_rate_date               pa_projects_all.funding_rate_date%TYPE;
l_funding_exchange_rate           pa_projects_all.funding_exchange_rate%TYPE;
l_return_status                   VARCHAR2(30);
l_msg_count                       NUMBER;
l_msg_data                        VARCHAR2(30);


BEGIN


    /*  This is commented because now PFC and Project currency can be diffrent for MCB2 */
    /* l_currency_code := pa_multi_currency_txn.get_proj_curr_code_sql(X_project_id); */

 /* To get the Project functional currency for Project, calling get default procedure for MCB2  */

      PA_MULTI_CURRENCY_BILLING.get_project_defaults (
            p_project_id                  =>  X_project_id,
            x_multi_currency_billing_flag =>  l_multi_currency_billing_flag,
            x_baseline_funding_flag       =>  l_baseline_funding_flag,
            x_revproc_currency_code       =>  l_revproc_currency_code,
            x_invproc_currency_type       =>  l_invproc_currency_type,
            x_invproc_currency_code       =>  l_invproc_currency_code,
            x_project_currency_code       =>  l_project_currency_code,
            x_project_bil_rate_date_code  =>  l_project_bil_rate_date_code,
            x_project_bil_rate_type       =>  l_project_bil_rate_type,
            x_project_bil_rate_date       =>  l_project_bil_rate_date,
            x_project_bil_exchange_rate   =>  l_project_bil_exchange_rate,
            x_projfunc_currency_code      =>  l_projfunc_currency_code,
            x_projfunc_bil_rate_date_code =>  l_projfunc_bil_rate_date_code,
            x_projfunc_bil_rate_type      =>  l_projfunc_bil_rate_type,
            x_projfunc_bil_rate_date      =>  l_projfunc_bil_rate_date,
            x_projfunc_bil_exchange_rate  =>  l_projfunc_bil_exchange_rate,
            x_funding_rate_date_code      =>  l_funding_rate_date_code,
            x_funding_rate_type           =>  l_funding_rate_type,
            x_funding_rate_date           =>  l_funding_rate_date,
            x_funding_exchange_rate       =>  l_funding_exchange_rate,
            x_return_status               =>  l_return_status,
            x_msg_count                   =>  l_msg_count,
            x_msg_data                    =>  l_msg_data);

   l_currency_code := l_projfunc_currency_code;

--  Cost accrual calculation formula
--
--  Cost Accrual = (Accrued Revenue / Budgeted Revenue) * Budgeted Cost
--                                                        - cost_accrued
--
--
   cost_accrual :=  nvl(X_revenue_amount,0) /nvl(X_budget_revenue,0)
		* nvl(X_budget_cost,0) - nvl(X_cost_accrued,0);
--
-- Event description will show the calculation
--
/* 2958833 changed get_format_mask call to create mask for 30 char instead of 15 */
   Event_Description := 'Cost Accrual '|| ' = ' ||
         to_char(X_revenue_amount,fnd_currency.get_format_mask(l_currency_code,30))
         || '/ ' ||
         to_char(X_budget_revenue,fnd_currency.get_format_mask(l_currency_code,30))
         || ' * '||
         to_char(X_budget_cost,fnd_currency.get_format_mask(l_currency_code,30))
         || ' - ' ||
         to_char(nvl(X_cost_accrued,0),fnd_currency.get_format_mask(l_currency_code,30));

--
-- If the cost accrual is not zero then create the events
--

   IF (nvl(cost_accrual,0) <> 0) THEN

--
-- Create the Cost accrual contra entries
--
   l_event_set_id := 'CONTRA-' ||x_project_id||'-'||nvl(x_top_task_id,0)||'-'
			       ||nvl(x_request_id,0);
		/** public api to insert event **/
   pa_billing_pub.insert_event (
			X_rev_amt => cost_accrual,
			X_bill_amt => 0,
                       	X_event_type =>g_ca_contra_event_type ,
                       	X_event_description => event_description,
                        X_attribute10 => l_event_set_id,
                        X_audit_amount1 => X_revenue_amount,
                        X_audit_amount2 => X_budget_revenue,
                        X_audit_amount3 => X_budget_cost,
                        X_audit_amount4 => X_cost_accrued,
                        X_audit_cost_budget_type_code => X_audit_cost_budget_type_code,
                        X_audit_rev_budget_type_code => X_audit_rev_budget_type_code,
                        X_audit_cost_plan_type_id     => X_cost_plan_type_id, /* Added for fin plan impact */
                        X_audit_rev_plan_type_id      => X_rev_plan_type_id,  /* Added for fin plan impact */
			X_error_message =>l_error_message,
			X_status => l_status);

--
-- If the previous event is successfuly created then create the next event
--
   IF l_status = 0 THEN

-- Create the Cost accrual entries

   l_event_set_id := 'NORMAL-' ||x_project_id||'-'||nvl(x_top_task_id,0)||'-'
			       ||nvl(x_request_id,0);
--
-- In order to debit the cost accrual account the event is created with
-- a negative of the cost accrual amount
--
   pa_billing_pub.insert_event (
			X_rev_amt => (-1) * cost_accrual,
			X_bill_amt => 0,
                       	X_event_description => event_description,
                       	X_event_type =>  g_ca_event_type ,
                        X_attribute10 => l_event_set_id,
                        X_audit_amount1 => X_revenue_amount,
                        X_audit_amount2 => X_budget_revenue,
                        X_audit_amount3 => X_budget_cost,
                        X_audit_amount4 => X_cost_accrued,
                        X_audit_cost_budget_type_code =>x_audit_cost_budget_type_code,
                        X_audit_rev_budget_type_code => x_audit_rev_budget_type_code,
                        X_audit_cost_plan_type_id     => X_cost_plan_type_id, /* Added for fin plan impact */
                        X_audit_rev_plan_type_id      => X_rev_plan_type_id,  /* Added for fin plan impact */
			X_error_message =>l_error_message,
			X_status => l_status
			);
    END IF;
   END IF;
EXCEPTION
WHEN OTHERS THEN
X_error_message :=NULL;
X_status := NULL;
END CreateNormalEntries;
--
-- Procedure that creates closing entries when project status is changed
-- to 'PENDING CLOSE'
--
Procedure CreateClosingEntries (
			X_project_id                    NUMBER,
	             	X_top_task_id                   NUMBER DEFAULT NULL,
                        X_revenue_amount 		NUMBER,
                        X_budget_revenue 		NUMBER,
                        X_budget_cost	 		NUMBER,
                        X_cost_accrued	 		NUMBER,
                        X_audit_cost_budget_type_code   VARCHAR2,
                        X_audit_rev_budget_type_code    VARCHAR2,
                     	X_request_id      	        NUMBER DEFAULT NULL,
                        X_cost_plan_type_id        IN   NUMBER , /* Added for Fin plan impact */
                        X_rev_plan_type_id         IN   NUMBER , /* Added for Fin plan impact */
			X_error_message   		OUT NOCOPY VARCHAR2,
			X_status 	  		OUT NOCOPY NUMBER
			)
IS
cost_accrual            REAL := 0;
cost_accrual_contra     REAL := 0;
cost_WIP                REAL := 0;
l_status                NUMBER := 0;
l_error_message         VARCHAR2(240);
l_event_set_id	        VARCHAR2(150);
event_description	VARCHAR2(240);
l_currency_code         VARCHAR2(15);

/* Declaring varible for MCB2 */
l_multi_currency_billing_flag     pa_projects_all.MULTI_CURRENCY_BILLING_FLAG%TYPE;
l_baseline_funding_flag           pa_projects_all.BASELINE_FUNDING_FLAG%TYPE;
l_revproc_currency_code           pa_projects_all.revproc_currency_code%TYPE;
l_revproc_rate_type               pa_events.revproc_rate_type%TYPE;
l_revproc_rate_date               pa_events.revproc_rate_date%TYPE;
l_revproc_exchange_rate           pa_events.revproc_exchange_rate%TYPE;
l_invproc_currency_code           pa_events.invproc_currency_code%TYPE;
l_invproc_currency_type           pa_projects_all.invproc_currency_type%TYPE;
l_invproc_rate_type               pa_events.invproc_rate_type%TYPE;
l_invproc_rate_date               pa_events.invproc_rate_date%TYPE;
l_invproc_exchange_rate           pa_events.invproc_exchange_rate%TYPE;
l_project_currency_code           pa_projects_all.project_currency_code%TYPE;
l_project_bil_rate_date_code      pa_projects_all.project_bil_rate_date_code%TYPE;
l_project_bil_rate_type           pa_projects_all.project_bil_rate_type%TYPE;
l_project_bil_rate_date           pa_projects_all.project_bil_rate_date%TYPE;
l_project_bil_exchange_rate       pa_projects_all.project_bil_exchange_rate%TYPE;
l_projfunc_currency_code          pa_projects_all.projfunc_currency_code%TYPE;
l_projfunc_bil_rate_date_code     pa_projects_all.projfunc_bil_rate_date_code%TYPE;
l_projfunc_bil_rate_type          pa_projects_all.projfunc_bil_rate_type%TYPE;
l_projfunc_bil_rate_date          pa_projects_all.projfunc_bil_rate_date%TYPE;
l_projfunc_bil_exchange_rate      pa_projects_all.projfunc_bil_exchange_rate%TYPE;
l_funding_rate_date_code          pa_projects_all.funding_rate_date_code%TYPE;
l_funding_rate_type               pa_projects_all.funding_rate_type%TYPE;
l_funding_rate_date               pa_projects_all.funding_rate_date%TYPE;
l_funding_exchange_rate           pa_projects_all.funding_exchange_rate%TYPE;
l_return_status                   VARCHAR2(30);
l_msg_count                       NUMBER;
l_msg_data                        VARCHAR2(30);

BEGIN
--
--   Gets the total cost WIP amount from the cost distribution lines
--   line_type = R , indicates raw cost lines only
--   If budge type  = 'R' is set in the attribute15 column
--   of pa_events then use raw cost.
--   If budge type  = 'B' is set in the attribute15 column
--   of pa_events then use burdened cost.
--
/* This is commented because now PFC and Project currency can be diffrent for MCB2 */
/*    l_currency_code := pa_multi_currency_txn.get_proj_curr_code_sql(X_project_id); */

 /* To get the Project functional currency for Project, calling get default procedure for MCB2 */

      PA_MULTI_CURRENCY_BILLING.get_project_defaults (
            p_project_id                  =>  X_project_id,
            x_multi_currency_billing_flag =>  l_multi_currency_billing_flag,
            x_baseline_funding_flag       =>  l_baseline_funding_flag,
            x_revproc_currency_code       =>  l_revproc_currency_code,
            x_invproc_currency_type       =>  l_invproc_currency_type,
            x_invproc_currency_code       =>  l_invproc_currency_code,
            x_project_currency_code       =>  l_project_currency_code,
            x_project_bil_rate_date_code  =>  l_project_bil_rate_date_code,
            x_project_bil_rate_type       =>  l_project_bil_rate_type,
            x_project_bil_rate_date       =>  l_project_bil_rate_date,
            x_project_bil_exchange_rate   =>  l_project_bil_exchange_rate,
            x_projfunc_currency_code      =>  l_projfunc_currency_code,
            x_projfunc_bil_rate_date_code =>  l_projfunc_bil_rate_date_code,
            x_projfunc_bil_rate_type      =>  l_projfunc_bil_rate_type,
            x_projfunc_bil_rate_date      =>  l_projfunc_bil_rate_date,
            x_projfunc_bil_exchange_rate  =>  l_projfunc_bil_exchange_rate,
            x_funding_rate_date_code      =>  l_funding_rate_date_code,
            x_funding_rate_type           =>  l_funding_rate_type,
            x_funding_rate_date           =>  l_funding_rate_date,
            x_funding_exchange_rate       =>  l_funding_exchange_rate,
            x_return_status               =>  l_return_status,
            x_msg_count                   =>  l_msg_count,
            x_msg_data                    =>  l_msg_data);

   l_currency_code := l_projfunc_currency_code;

    /* According to MCB2 changes this columns will be in PFC */
    /*Change for burden shedule enhancement*/
     SELECT     sum(decode(g_ca_budget_type,'R',nvl(cdl.amount,0),
		   (nvl(cdl.burdened_cost,0)+nvl(cdl.project_burdened_change,0))))
     INTO       cost_WIP
     FROM       pa_cost_distribution_lines_all  cdl,
                pa_expenditure_items_all  ei,
                pa_tasks  t
     WHERE      t.project_id = X_project_id
     AND        (t.top_task_id = X_top_task_id
                 OR X_top_task_id IS NULL)
     AND        ei.task_id = t.task_id
     AND        ei.Project_ID = X_project_id  -- Perf Bug 2695266
     AND        cdl.expenditure_item_id = ei.expenditure_item_id
     AND        cdl.line_type = 'R'
     ;

--
-- Get the cost accrual contra to date
--
     pa_rev_ca.GetCostAccruedContra (X_project_id => x_project_id,
 		  		     X_task_id => X_top_task_id,
	   	  		     X_cost_accrued => cost_accrual_contra );

     cost_accrual_contra := (-1) * cost_accrual_contra ;

--
--   The adjustment entry for any difference in Cost WIP and cost accrual contra
--
--   Closing Cost Accrual Entry = -1* ( Closing Cost-WIP + Closing Cost Accrual Contra )
--
   cost_accrual := -1 * (cost_WIP + cost_accrual_contra);
/* 2958833 changed get_format_mask call to create mask for 30 char instead of 15 */
   Event_Description := 'Closing Balance in Cost WIP =  ' ||
         to_char(cost_WIP,fnd_currency.get_format_mask(l_currency_code,30));


   l_event_set_id := 'CLOSE-' ||x_project_id||'-'||nvl(x_top_task_id,0)||'-'
			       ||nvl(x_request_id,0);

--
-- Create event to close the cost WIP account
--
  /** public api to insert event **/

  IF cost_WIP <> 0 THEN  /* Added for bug 3788835: if project doesnot have EIs then this would be 0 */
   pa_billing_pub.insert_event (
			X_rev_amt => cost_WIP,
			X_bill_amt => 0,
                       	X_event_type => g_ca_wip_event_type ,
                       	X_event_description => event_description,
                        X_attribute10 => l_event_set_id,
                        X_audit_amount1 => X_revenue_amount,
                        X_audit_amount2 => X_budget_revenue,
                        X_audit_amount3 => X_budget_cost,
                        X_audit_amount4 => X_cost_accrued,
                        X_audit_cost_budget_type_code => X_audit_cost_budget_type_code,
                        X_audit_rev_budget_type_code => X_audit_rev_budget_type_code,
                        X_audit_cost_plan_type_id     => X_cost_plan_type_id, /* Added for fin plan impact */
                        X_audit_rev_plan_type_id      => X_rev_plan_type_id,  /* Added for fin plan impact */
			X_error_message =>l_error_message,
			X_status => l_status);
  END IF;  /* End if added for bug 3788835 */

   IF l_status = 0 THEN

   l_event_set_id := 'CLOSE-' ||x_project_id||'-'||nvl(x_top_task_id,0)||'-'
			       ||nvl(x_request_id,0);

/* 2958833 changed get_format_mask call to create mask for 30 char instead of 15 */
   Event_Description := 'Closing Balance in CA contra ' ||
         to_char(cost_accrual_contra,fnd_currency.get_format_mask(l_currency_code,30));

--
-- Create event to close the cost accrual contra account
--
   pa_billing_pub.insert_event (
			X_rev_amt => cost_accrual_contra,
			X_bill_amt => 0,
                       	X_event_description => event_description,
                       	X_event_type =>  g_ca_contra_event_type ,
                        X_attribute10 => l_event_set_id,
                        X_audit_amount1 => X_revenue_amount,
                        X_audit_amount2 => X_budget_revenue,
                        X_audit_amount3 => X_budget_cost,
                        X_audit_amount4 => X_cost_accrued,
                        X_audit_cost_budget_type_code =>x_audit_cost_budget_type_code,
                        X_audit_rev_budget_type_code => x_audit_rev_budget_type_code,
                        X_audit_cost_plan_type_id     => X_cost_plan_type_id, /* Added for fin plan impact */
                        X_audit_rev_plan_type_id      => X_rev_plan_type_id,  /* Added for fin plan impact */
			X_error_message =>l_error_message,
			X_status => l_status
			);
    END IF;

    IF (l_status = 0 AND cost_accrual <> 0) THEN

--
--  Create event for cost accrual for the adjustment amount
--
     l_event_set_id := 'CLOSE-' ||x_project_id||'-'||nvl(x_top_task_id,0)||'-'
			       ||nvl(x_request_id,0);

/* 2958833 changed get_format_mask call to create mask for 30 char instead of 15 */
      Event_Description := 'Closing Balance in CA =  (-1) * ' ||
         to_char(cost_WIP,fnd_currency.get_format_mask(l_currency_code,30))
         || ' + ' ||
         to_char(cost_accrual_contra,fnd_currency.get_format_mask(l_currency_code,30));

      pa_billing_pub.insert_event (
			X_rev_amt => cost_accrual,
			X_bill_amt => 0,
                       	X_event_description => event_description,
                       	X_event_type =>  g_ca_event_type,
                        X_attribute10 => l_event_set_id,
                        X_audit_amount1 => X_revenue_amount,
                        X_audit_amount2 => X_budget_revenue,
                        X_audit_amount3 => X_budget_cost,
                        X_audit_amount4 => X_cost_accrued,
                        X_audit_cost_budget_type_code =>x_audit_cost_budget_type_code,
                        X_audit_rev_budget_type_code => x_audit_rev_budget_type_code,
                        X_audit_cost_plan_type_id     => X_cost_plan_type_id, /* Added for fin plan impact */
                        X_audit_rev_plan_type_id      => X_rev_plan_type_id,  /* Added for fin plan impact */
			X_error_message =>l_error_message,
			X_status => l_status
			);

   END IF;
EXCEPTION
WHEN OTHERS THEN
X_error_message :=NULL;
X_status := NULL;
END CreateClosingEntries;

--
-- This procedure calculates the cost WIP for a project / top task
--
PROCEDURE GetCost ( p_project_id      	IN  NUMBER
		    ,p_task_id         	IN  NUMBER
		    ,x_cost_wip_amount      OUT NOCOPY VARCHAR2
		   )
IS
l_cost_wip_amount  VARCHAR2(200);
BEGIN

--
--   Gets the total cost WIP amount from the cost distribution lines
--   line_type = R , indicates raw cost lines only
--   If budge type  = 'R' is set in the attribute15 column
--   of pa_events then use raw cost.
--   If budge type  = 'B' is set in the attribute15 column
--   of pa_events then use burdened cost.
--
    /* According to MCB2 changes this columns will be in PFC */
     SELECT     sum(decode(g_ca_budget_type,'R',nvl(cdl.amount,0),
		    (nvl(cdl.burdened_cost,0)+nvl(cdl.project_burdened_change,0))))
     INTO      l_cost_wip_amount
     FROM       pa_cost_distribution_lines_all  cdl,
                pa_expenditure_items_all  ei,
                pa_tasks  t
     WHERE      t.project_id = p_project_id
     AND        (t.top_task_id = p_task_id
                 OR p_task_id IS NULL)
     AND        ei.task_id = t.task_id
     AND        ei.Project_ID = P_project_id  -- Perf Bug 2695266
     AND        cdl.expenditure_item_id = ei.expenditure_item_id
     AND        cdl.line_type = 'R'
     ;
x_cost_wip_amount := l_cost_wip_amount;
EXCEPTION
WHEN OTHERS THEN
x_cost_wip_amount := NULL;
END GetCost;

/****************************************************************************

 Public Procedures

 ****************************************************************************/

-- Main procedure that calculates the cost accrual
-- and creates the events for cost accrual

PROCEDURE calc_ca_amt
		(	X_project_id               IN     NUMBER,
	             	X_top_task_id              IN     NUMBER DEFAULT NULL,
                     	X_calling_process          IN     VARCHAR2 DEFAULT NULL,
                     	X_calling_place            IN     VARCHAR2 DEFAULT NULL,
                     	X_amount                   IN     NUMBER DEFAULT NULL,
                     	X_percentage               IN     NUMBER DEFAULT NULL,
                     	X_rev_or_bill_date         IN     DATE DEFAULT NULL,
                     	X_billing_assignment_id    IN     NUMBER DEFAULT NULL,
                     	X_billing_extension_id     IN     NUMBER DEFAULT NULL,
                     	X_request_id               IN     NUMBER DEFAULT NULL
                )
IS

budget_revenue REAL := 0;
budget_cost    REAL := 0;
invoice_amount REAL := 0;
revenue_amount REAL := 0;
cost_amount REAL := 0;
revenue	REAL := 0;
cost_accrued REAL := 0;

event_description	VARCHAR2(240);

l_cost_budget_type_code VARCHAR2(30);
l_rev_budget_type_code  VARCHAR2(30);

l_status		NUMBER;
l_error_message		VARCHAR2(240);

l_project_status        VARCHAR2(30);
l_ca_event_type         VARCHAR2(30);
l_ca_contra_event_type  VARCHAR2(30);
l_ca_wip        	VARCHAR2(30);
l_ca_budget_type        VARCHAR2(1);

/* Added for Fin Plan impact */
l_cost_plan_type_id      NUMBER;
l_rev_plan_type_id       NUMBER;
/* till here */

BEGIN

l_status 	:= 0;
l_error_message := NULL;

-- select the event types associated with the billing extension
-- these event types will be used while creating events for
-- cost accrual , cost accrual contra and cost WIP

  SELECT attribute12 , attribute13 , attribute14 , attribute15
  INTO   g_ca_event_type ,g_ca_contra_event_type,g_ca_wip_event_type,g_ca_budget_type
  FROM   pa_billing_extensions
  WHERE  billing_extension_id = X_billing_extension_id;

   IF g1_debug_mode  = 'Y' THEN
   	PA_MCB_INVOICE_PKG.log_message('Before pa_billing_extn_params_v select pa_rev_ca.calc_ca_amt  :');
   END IF;
  /* Added for bug 2649456.Not handling exception intentionaly because if it is coming,
   it will be data issue */
   BEGIN
     SELECT default_cost_plan_type_id,default_rev_plan_type_id
     INTO l_cost_plan_type_id,l_rev_plan_type_id
     FROM pa_billing_extn_params_v;
   EXCEPTION
     WHEN OTHERS THEN
      IF g1_debug_mode  = 'Y' THEN
      	PA_MCB_INVOICE_PKG.log_message('Error from pa_billing_extn_params_v pa_rev_ca.calc_ca_amt :'||SQLERRM);
      END IF;
      RAISE;
   END;
  /* till here */

 IF g1_debug_mode  = 'Y' THEN
 	PA_MCB_INVOICE_PKG.log_message('pa billing params v.cost_plan_type_id pa_rev_ca.calc_ca_amt :'||l_cost_plan_type_id);
 	PA_MCB_INVOICE_PKG.log_message('pa billing params v.rev_plan_type_id pa_rev_ca.calc_ca_amt  :'||l_rev_plan_type_id);
 END IF;


-- gets the cost and revenue budget amounts
-- if budget type = 'R' then call the procedure defined in this package
-- else use the public api in package pa_billing_pub
--
  IF g_ca_budget_type = 'R' THEN
     pa_rev_ca.get_budget_amount(
		X2_project_id                 => X_project_id,
		X2_task_id                    => X_top_task_id,
		X2_revenue_amount             => budget_revenue,
		X2_cost_amount                => budget_cost,
                X_cost_budget_type_code       => l_cost_budget_type_code,
                X_rev_budget_type_code        => l_rev_budget_type_code,
                P_cost_plan_type_id           => l_cost_plan_type_id, /* Added for fin plan impact */
                P_rev_plan_type_id            => l_rev_plan_type_id,  /* Added for fin plan impact */
		X_error_message               => l_error_message,
		X_status                      => l_status);
  ELSE
     pa_billing_pub.get_budget_amount(
		X2_project_id                 => X_project_id,
		X2_task_id                    => X_top_task_id,
		X2_revenue_amount             => budget_revenue,
		X2_cost_amount                => budget_cost,
                X_cost_budget_type_code       => l_cost_budget_type_code,
                X_rev_budget_type_code        => l_rev_budget_type_code,
                P_cost_plan_type_id           => l_cost_plan_type_id, /* Added for fin plan impact */
                P_rev_plan_type_id            => l_rev_plan_type_id,  /* Added for fin plan impact */
		X_error_message               =>l_error_message,
		X_status                      => l_status);
  END IF;


-- Gets the revenue accrued to date
  pa_rev_ca.GetCurrentRevenue(   X_project_id => x_project_id,
 		  		 X_task_id => X_top_task_id,
	   	  		 X_revenue_amount => revenue_amount);

-- Select the project system status code

  SELECT pps.project_system_status_code
  INTO   l_project_status
  FROM   pa_projects_all ppa , pa_project_statuses pps
  WHERE  ppa.project_id = x_project_id
  AND    ppa.project_status_code = pps.project_status_code
  AND    pps.status_type = 'PROJECT';

/****************************************************************************
 When the project system status is ACTIVE , Calculate the cost accrual and
 create events for cost accrual and cost accrual contra.

 Another condition is if the project is made ACTIVE after PENDING CLOSE
 then reverse the closing entries before creating actual entries.

 When the project system  status is PENDING CLOSE ,
 - Calculate the entries and create events as done for project status ACTIVE

 - For closing entries calculate the adjustment amount for any difference
   between cost WIP and cost accrual accounts .
   create reversing events for cost WIP , cost accrual contra and if the
   adjustment amount is not zero then create a cost accrual event for the
   amount

Please note that all events will be created at project level for project
level funding and at top task level for top task level funding.

*****************************************************************************/

    IF (budget_revenue <> 0) THEN

        IF l_project_status <> 'PENDING_CLOSE' THEN

	   -- Reverse the closing entries (if not allready reversed)
	        pa_rev_ca.ReverseClosingEntries
                                (X_project_id => x_project_id,
 		  		 X_task_id => x_top_task_id,
				 X_error_message => l_error_message,
				 X_status	 => l_status
				 );

           -- Get the cost accrual to date
	   --
                pa_rev_ca.GetCostAccrued
                                (X_project_id => x_project_id,
 		  		 X_task_id => X_top_task_id,
	   	  		 X_cost_accrued => cost_accrued );

	   -- Create Normal Entries
	   --
    		pa_rev_ca.CreateNormalEntries (
                        X_project_id     => x_project_id,
			X_top_task_id        => x_top_task_id,
			X_request_id	 => x_request_id,
                        X_revenue_amount => revenue_amount,
                        X_budget_revenue => budget_revenue,
                        X_budget_cost => budget_cost,
                        X_cost_accrued => cost_accrued,
                        X_audit_cost_budget_type_code => l_cost_budget_type_code,
                        X_audit_rev_budget_type_code  => l_rev_budget_type_code,
                        X_cost_plan_type_id     => l_cost_plan_type_id, /* Added for fin plan impact */
                        X_rev_plan_type_id      => l_rev_plan_type_id,  /* Added for fin plan impact */
			X_error_message =>l_error_message,
			X_status => l_status);

       ELSE
		-- Status is pending close
		-- Check if closing entries created allready
         IF (check_closing_done (X_project_id , X_top_task_id) = 'N') THEN

           -- Get the cost accrual to date
           pa_rev_ca.GetCostAccrued
                                (X_project_id => x_project_id,
 		  		 X_task_id => X_top_task_id,
	   	  		 X_cost_accrued => cost_accrued );

	   -- Create Normal entries
    	   pa_rev_ca.CreateNormalEntries (
                        X_project_id     => x_project_id,
			X_top_task_id    => x_top_task_id,
			X_request_id	 => x_request_id,
                        X_revenue_amount => revenue_amount,
                        X_budget_revenue => budget_revenue,
                        X_budget_cost    => budget_cost,
                        X_cost_accrued   => cost_accrued,
                        X_audit_cost_budget_type_code =>l_cost_budget_type_code,
                        X_audit_rev_budget_type_code => l_rev_budget_type_code,
                        X_cost_plan_type_id     => l_cost_plan_type_id, /* Added for fin plan impact */
                        X_rev_plan_type_id      => l_rev_plan_type_id,  /* Added for fin plan impact */
			X_error_message =>l_error_message,
			X_status => l_status);

           -- Get the cost accrual to date
           pa_rev_ca.GetCostAccrued
                                (X_project_id => x_project_id,
 		  		 X_task_id => X_top_task_id,
	   	  		 X_cost_accrued => cost_accrued );

	   -- Create closing entries
	   pa_rev_ca.CreateClosingEntries
			(
                        X_project_id     => x_project_id,
			X_top_task_id        => x_top_task_id,
			X_request_id	 => x_request_id,
                        X_revenue_amount => revenue_amount,
                        X_budget_revenue => budget_revenue,
                        X_budget_cost => budget_cost,
                        X_cost_accrued => cost_accrued,
                        X_audit_cost_budget_type_code => l_cost_budget_type_code,
                        X_audit_rev_budget_type_code  => l_rev_budget_type_code,
                        X_cost_plan_type_id           => l_cost_plan_type_id, /* Added for fin plan impact */
                        X_rev_plan_type_id            => l_rev_plan_type_id,  /* Added for fin plan impact */
			X_error_message =>l_error_message,
			X_status => l_status);
	END IF;
     END IF;
   END IF;

EXCEPTION
  WHEN OTHERS THEN
--      DBMS_OUTPUT.PUT_LINE(SQLERRM);
	RAISE;

END calc_ca_amt;


-- Procedure that sets the psi columns for cost accrual
-- This procedure will be called from the psi client extension
-- pa_client_extn_status.get_psi_cols
-- Uncomment the call to this procedure in pa_client_extn_status.get_psi_cols
-- in order to invoke this procedure
--
PROCEDURE get_psi_cols (
		  x_project_id			        IN NUMBER
		, x_task_id				IN NUMBER
		, x_resource_list_member_id		IN NUMBER
		, x_cost_budget_type_code		IN VARCHAR2
		, x_rev_budget_type_code		IN VARCHAR2
		, x_status_view				IN VARCHAR2
		, x_pa_install				IN VARCHAR2
		, x_derived_col_1			OUT NOCOPY VARCHAR2
		, x_derived_col_2			OUT NOCOPY VARCHAR2
		, x_derived_col_3			OUT NOCOPY VARCHAR2
		, x_derived_col_4			OUT NOCOPY NUMBER
		, x_derived_col_5			OUT NOCOPY NUMBER
		, x_derived_col_6			OUT NOCOPY NUMBER
		, x_derived_col_7			OUT NOCOPY NUMBER
		, x_derived_col_8			OUT NOCOPY NUMBER
		, x_derived_col_9			OUT NOCOPY NUMBER
		, x_derived_col_10			OUT NOCOPY NUMBER
		, x_derived_col_11			OUT NOCOPY NUMBER
		, x_derived_col_12			OUT NOCOPY NUMBER
		, x_derived_col_13			OUT NOCOPY NUMBER
		, x_derived_col_14			OUT NOCOPY NUMBER
		, x_derived_col_15			OUT NOCOPY NUMBER
		, x_derived_col_16			OUT NOCOPY NUMBER
		, x_derived_col_17			OUT NOCOPY NUMBER
		, x_derived_col_18			OUT NOCOPY NUMBER
		, x_derived_col_19			OUT NOCOPY NUMBER
		, x_derived_col_20			OUT NOCOPY NUMBER
		, x_derived_col_21			OUT NOCOPY NUMBER
		, x_derived_col_22			OUT NOCOPY NUMBER
		, x_derived_col_23			OUT NOCOPY NUMBER
		, x_derived_col_24			OUT NOCOPY NUMBER
		, x_derived_col_25			OUT NOCOPY NUMBER
		, x_derived_col_26			OUT NOCOPY NUMBER
		, x_derived_col_27			OUT NOCOPY NUMBER
		, x_derived_col_28			OUT NOCOPY NUMBER
		, x_derived_col_29			OUT NOCOPY NUMBER
		, x_derived_col_30			OUT NOCOPY NUMBER
		, x_derived_col_31			OUT NOCOPY NUMBER
		, x_derived_col_32			OUT NOCOPY NUMBER
		, x_derived_col_33			OUT NOCOPY NUMBER
		, p_revenue_ptd 			IN NUMBER
		, p_revenue_itd 			IN NUMBER)
IS
        l_raw_cost_itd                      NUMBER  := 0;
        l_raw_cost_ptd                      NUMBER  := 0;
        l_cost_accrual_itd                  NUMBER  := 0;
        l_cost_accrual_ptd                  NUMBER  := 0;
        l_accounted_cost_WIP_itd            NUMBER  := 0;
        l_accounted_cost_WIP_ptd            NUMBER  := 0;
        l_gross_profit                      NUMBER  := 0;
	l_project_type                      VARCHAR2(20);
	l_funding_flag                      VARCHAR2(1);
	l_ca_event_type			    VARCHAR2(30);
	l_ca_contra_event_type		    VARCHAR2(30);
	l_ca_wip_event_type		    VARCHAR2(30);
	l_ca_budget_type		    VARCHAR2(1);
	l_cost_accrual_flag		    VARCHAR2(1);
	l_revenue_ptd			    NUMBER := 0;

BEGIN
--------------------------- Cost Accrual Derived Columns --------------------
-- If the project has cost accrual enabled then proceed
-- else dont do anything
--
   pa_rev_ca.Check_if_Cost_Accrual ( x_project_id
			  ,l_cost_accrual_flag
   			  ,l_funding_flag
		          ,l_ca_event_type
		 	  ,l_ca_contra_event_type
		          ,l_ca_wip_event_type
		          ,l_ca_budget_type
			 );

   IF l_cost_accrual_flag = 'Y' THEN

--
--   Check if project level or Task level funding
--   If project level funding then dont show at top task level
--   else if top task level funding then show project and top task level
--   The dervied column will always be null for columns other than
--   top task level
--
--   Also the amounts will be shown only if accumulation process has included
--   the revenue and cost distribution lines for accumulation
--

      IF ( x_status_view = 'PROJECTS')
         			OR
         ( x_status_view = 'TASKS'    and l_funding_flag = 'N')
      THEN

--
--   Gets the inception to-date cost incurred from the cost distribution lines
--   line_type = R , indicates raw cost lines only
--   If budge type  = 'R' is set in the attribute15 column
--   of pa_events then use raw cost.
--   If budge type  = 'B' is set in the attribute15 column
--   of pa_events then use burdened cost.
--
    /* According to MCB2 changes this columns will be in PFC */
       SELECT     sum(decode(l_ca_budget_type,'R',nvl(cdl.amount,0),
						(nvl(burdened_cost,0)+nvl(cdl.project_burdened_change,0))))
       INTO       l_raw_cost_itd
       FROM       pa_cost_distribution_lines_all  cdl,
                  pa_expenditure_items_all  ei,
                  pa_tasks  t
       WHERE      t.project_id = x_project_id
       AND        (nvl(t.top_task_id,0) =
               decode(x_status_view , 'TASKS', x_task_id , nvl(t.top_task_id,0)))
       AND        ei.task_id = t.task_id
       AND        ei.Project_ID = X_project_id  -- Perf Bug 2695266
       AND        cdl.expenditure_item_id = ei.expenditure_item_id
       AND        cdl.line_type = 'R'
       AND        cdl.resource_accumulated_flag = 'Y'
       ;

--
--   Gets the current reporting period to-date cost incurred from the
--   cost distribution lines line_type = R , indicates raw cost lines only
--   If budge type  = 'R' is set in the attribute15 column
--   of pa_events then use raw cost.
--   If budge type  = 'B' is set in the attribute15 column
--   of pa_events then use burdened cost.
--
    /* According to MCB2 changes this columns will be in PFC */
       SELECT     sum(decode(l_ca_budget_type,'R',nvl(cdl.amount,0),
						(nvl(burdened_cost,0)+nvl(cdl.project_burdened_change,0))))
       INTO       l_raw_cost_ptd
       FROM       pa_cost_distribution_lines_all  cdl,
                  pa_expenditure_items_all  ei,
                  pa_tasks  t,
                  pa_periods pp
       WHERE      pp.current_pa_period_flag = 'Y'
       AND        TRUNC(cdl.pa_date) BETWEEN pp.start_date AND pp.end_date
       AND        t.project_id = x_project_id
       AND        (nvl(t.top_task_id,0) =
               decode(x_status_view , 'TASKS', x_task_id , nvl(t.top_task_id,0)))
       AND        ei.task_id = t.task_id
       AND        ei.Project_ID = X_project_id  -- Perf Bug 2695266
       AND        cdl.expenditure_item_id = ei.expenditure_item_id
       AND        cdl.line_type = 'R'
       AND        cdl.resource_accumulated_flag = 'Y'
       ;

--
--  Gets the inception to-date closing cost WIP and closing cost accrual amounts
--  cost WIP is identified by ca_wip_event_type
--  and cost accrual by ca_event_type
--

/* Changed this column from amount to projfunc_revenue_amount for MCB2 */
       SELECT sum(decode(pe.event_type,l_ca_wip_event_type,
					nvl(erdl.projfunc_revenue_amount,0),0)),
       	      sum(decode(pe.event_type,l_ca_event_type,
					nvl(erdl.projfunc_revenue_amount,0),0))
       INTO   l_accounted_cost_WIP_itd,
	      l_cost_accrual_itd
       FROM   pa_events pe, pa_cust_event_rdl_all erdl,
              pa_draft_revenues_all dr
       WHERE  pe.event_num  = erdl.event_num
         AND  pe.project_id = erdl.project_id
         AND  nvl(pe.task_id,0) = nvl(erdl.task_id,0)
         AND  nvl(pe.task_id,0) =
                   decode(x_status_view , 'TASKS', x_task_id , nvl(pe.task_id,0))
         AND  pe.project_id = x_project_id
         AND  erdl.draft_revenue_num = dr.draft_revenue_num
	 AND  erdl.project_id        = dr.project_id
	 AND  pe.event_type IN (l_ca_wip_event_type , l_ca_event_type)
         AND  dr.resource_accumulated_flag = 'Y'
         ;
--
--  Gets the current reporting period to-date closing cost WIP and closing cost accrual
--  amounts
--  cost WIP is identified by ca_wip_event_type
--  and cost accrual by ca_event_type
--
/* Changed this column from amount to projfunc_revenue_amount for MCB2 */
       SELECT sum(decode(pe.event_type,l_ca_wip_event_type,
					nvl(erdl.projfunc_revenue_amount,0),0)),
       	      sum(decode(pe.event_type,l_ca_event_type,
					nvl(erdl.projfunc_revenue_amount,0),0))
       INTO   l_accounted_cost_WIP_ptd,
	      l_cost_accrual_ptd
       FROM   pa_events pe, pa_cust_event_rdl_all erdl,
              pa_draft_revenues_all dr , pa_periods pp  /* Bug# 2197991 */
       WHERE  pp.current_pa_period_flag = 'Y'
         -- AND  TRUNC(dr.pa_date) = pp.end_date
         AND  TRUNC(dr.pa_date) BETWEEN pp.start_date AND pp.end_date -- Modified for PA/GL period enhancements
         AND  pe.event_num  = erdl.event_num
         AND  pe.project_id = erdl.project_id
         AND  nvl(pe.task_id,0) = nvl(erdl.task_id,0)
         AND  nvl(pe.task_id,0) =
                   decode(x_status_view , 'TASKS', x_task_id , nvl(pe.task_id,0))
         AND  pe.project_id = x_project_id
         AND  erdl.draft_revenue_num = dr.draft_revenue_num
	 AND  erdl.project_id        = dr.project_id
	 AND  pe.event_type IN (l_ca_wip_event_type , l_ca_event_type)
         AND  dr.resource_accumulated_flag = 'Y'
         ;

-- Cost accrual is a debit entry , so its created with a negative sign
-- to get the proper amount reverse the sign
--
        l_cost_accrual_itd := (-1)*l_cost_accrual_itd;
        l_cost_accrual_ptd := (-1)*l_cost_accrual_ptd;

-- gets the revenue accrued in the current reporting period to-date
--
/* Changed this column from amount to projfunc_revenue_amount for MCB2 */
	SELECT sum(nvl(dri.projfunc_revenue_amount,0))
	INTO   l_revenue_ptd
	FROM   pa_draft_revenue_items dri,
	       pa_draft_revenues_all  dr,
	       pa_periods pp  /* Bug# 2197991 */
	WHERE  dri.project_id = x_project_id
	AND    nvl(dri.task_id,0) =
                       decode(x_status_view,
                               'TASKS',  x_task_id , nvl(dri.task_id,0))
	AND    dri.draft_revenue_num = dr.draft_revenue_num
	AND    dri.project_id = dr.project_id
        -- AND  TRUNC(dr.pa_date) = pp.end_date
        AND  TRUNC(dr.pa_date) BETWEEN pp.start_date AND pp.end_date -- Modified for PA/GL period enhancements
        AND    dr.resource_accumulated_flag = 'Y'
        AND    pp.current_pa_period_flag = 'Y';

-- Assuming columns 28-33 have been setup in the following order is psi column setup
-- column 28 : Cost WIP inception to date
-- column 29 : Cost WIP period to date
-- column 30 : Cost Accrual inception to date
-- column 31 : Cost Accrual period to date
-- column 32 : Margin  inception to date
-- column 33 : Margin inception to date

--      Cost WIP amounts
	x_derived_col_28 := l_raw_cost_itd - nvl(l_accounted_cost_WIP_itd,0);      --Added NVL for Bug#6666921
	x_derived_col_29 := l_raw_cost_ptd - nvl(l_accounted_cost_WIP_ptd,0);      --Added NVL for Bug#6666921

--      Cost Accrual amounts
	x_derived_col_30 := l_cost_accrual_itd;
	x_derived_col_31 := l_cost_accrual_ptd;

--      Margin amoounts
	x_derived_col_32 := p_revenue_itd - l_cost_accrual_itd;
	x_derived_col_33 := l_revenue_ptd - l_cost_accrual_ptd;

      END IF;

    END IF;

EXCEPTION
WHEN OTHERS THEN
x_derived_col_1                      := NULL;
x_derived_col_2                      := NULL;
x_derived_col_3                     := NULL;
x_derived_col_4                      := NULL;
x_derived_col_5                      := NULL;
x_derived_col_6                      := NULL;
x_derived_col_7                      := NULL;
x_derived_col_8                      := NULL;
x_derived_col_9                      := NULL;
x_derived_col_10                     := NULL;
x_derived_col_11                     := NULL;
x_derived_col_12                     := NULL;
x_derived_col_13                     := NULL;
x_derived_col_14                     := NULL;
x_derived_col_15                     := NULL;
x_derived_col_16                     := NULL;
x_derived_col_17                     := NULL;
x_derived_col_18                     := NULL;
x_derived_col_19                     := NULL;
x_derived_col_20                     := NULL;
x_derived_col_21                     := NULL;
x_derived_col_22                     := NULL;
x_derived_col_23                     := NULL;
x_derived_col_24                     := NULL;
x_derived_col_25                     := NULL;
x_derived_col_26                     := NULL;
x_derived_col_27                     := NULL;
x_derived_col_28                     := NULL;
x_derived_col_29                     := NULL;
x_derived_col_30                     := NULL;
x_derived_col_31                     := NULL;
x_derived_col_32                     := NULL;
x_derived_col_33                     := NULL;
END get_psi_cols;

-- Procedure that checks pre-requisites before closing a project that has
-- cost accrual enabled
-- This procedure will be called from the client extension
-- pa_client_extn_proj_status.verify_project_status_change
-- Please uncomment the call to this procedure in the above procedure to invoke this
-- procedure

PROCEDURE Verify_Project_Status_CA
            (x_calling_module           IN VARCHAR2
            ,X_project_id               IN NUMBER
            ,X_old_proj_status_code     IN VARCHAR2
            ,X_new_proj_status_code     IN VARCHAR2
            ,X_project_type             IN VARCHAR2
            ,X_project_start_date       IN DATE
            ,X_project_end_date         IN DATE
            ,X_public_sector_flag       IN VARCHAR2
            ,X_attribute_category       IN VARCHAR2
            ,X_attribute1               IN VARCHAR2
            ,X_attribute2               IN VARCHAR2
            ,X_attribute3               IN VARCHAR2
            ,X_attribute4               IN VARCHAR2
            ,X_attribute5               IN VARCHAR2
            ,X_attribute6               IN VARCHAR2
            ,X_attribute7               IN VARCHAR2
            ,X_attribute8               IN VARCHAR2
            ,X_attribute9               IN VARCHAR2
            ,X_attribute10              IN VARCHAR2
            ,x_pm_product_code          IN VARCHAR2
            ,x_err_code               OUT NOCOPY NUMBER
            ,x_warnings_only_flag     OUT NOCOPY VARCHAR2
	   )
IS
	l_funding_flag                      VARCHAR2(1);
	l_ca_event_type			    VARCHAR2(30);
	l_ca_contra_event_type		    VARCHAR2(30);
	l_ca_wip_event_type		    VARCHAR2(30);
	l_ca_budget_type		    VARCHAR2(1);
	l_cost_accrual_flag		    VARCHAR2(1);
	l_cost_amount                       NUMBER;
	l_ca_contra_amount                  NUMBER;
	l_ca_wip_amount                     NUMBER;
	l_err_msgname			    VARCHAR2(30);
        l_new_system_status_code	    VARCHAR2(30);
        l_old_system_status_code	    VARCHAR2(30);
	l_err_code				NUMBER;

BEGIN

-- Check the system status for the new project status code
-- If system status is CLOSED then perform the checks
--
    select project_system_status_code
    into l_new_system_status_code
    from pa_project_statuses
    where project_status_code = x_new_proj_status_code
     and status_type = 'PROJECT';

    select project_system_status_code
    into l_old_system_status_code
    from pa_project_statuses
    where project_status_code = x_old_proj_status_code
     and status_type = 'PROJECT';

-- IF l_new_system_status_code = 'CLOSED' THEN

    IF pa_utils2.IsProjectClosed(l_new_system_status_code) = 'Y' THEN

-- If project has cost accrual enabled then perform the checks
-- else ignore the checks
--
   pa_rev_ca.Check_if_Cost_Accrual ( x_project_id
			  ,l_cost_accrual_flag
   			  ,l_funding_flag
		          ,l_ca_event_type
		 	  ,l_ca_contra_event_type
		          ,l_ca_wip_event_type
		          ,l_ca_budget_type
			 );

   IF l_cost_accrual_flag = 'Y' THEN

   ------------------------------------------------------------------------
   -- Check 1.
   ------------------------------------------------------------------------
   -- There should be no balance in the cost wip account
   -- i.e.the cost WIP should have the same amount
   -- as the cost incurred to date
   -- There could be a difference in the amounts if
   -- a. Closing entries are not present
   -- b. New costs are incurred after closing entries have been generated
   -------------------------------------------------------------------------
      -- Get the cost incurred to date
      pa_rev_ca.GetCost(x_project_id,NULL,l_cost_amount);

      -- Get the closing cost WIP
      pa_rev_ca.GetCostWIP(x_project_id,NULL,l_ca_wip_amount);

      IF  l_cost_amount <> l_ca_wip_amount THEN

      --  Add message to the message stack
      --  Set the error code

	  l_err_msgname := 'PA_REV_CA_COST_WIP_BALANCE';
          fnd_message.set_name('PA', l_err_msgname);
          fnd_msg_pub.add;

	  l_err_code := 11;

      END IF;

  ------------------------------------------------------------------------
  -- Check 2
  ------------------------------------------------------------------------
  -- The closing entries for cost accrual must be generated.
  -- When cost accrual closing entries are generated , the cost accrual
  -- contra account is set to zero
  ------------------------------------------------------------------------

      -- Get the cost accrued contra to date
      pa_rev_ca.GetCostAccruedContra(x_project_id,NULL,l_ca_contra_amount);

     IF l_ca_contra_amount <> 0 THEN

      --  Add message to the message stack
      --  Set the error code

	  l_err_msgname := 'PA_REV_CA_NO_CLOSING_ENTRIES';
          fnd_message.set_name('PA', l_err_msgname);
          fnd_msg_pub.add;

	  l_err_code := 11;

     END IF;

  --------------------------------------------------------------------
  -- Check 3
  --------------------------------------------------------------------
  -- Check if the project status was set to CLOSE only after it
  -- was set to PENDING CLOSE
  --------------------------------------------------------------------

--     IF ( l_new_system_status_code = 'CLOSED'

    IF ( pa_utils2.IsProjectClosed(l_new_system_status_code) = 'Y'
          AND l_old_system_status_code <> 'PENDING_CLOSE') THEN

      --  Add message to the message stack
      --  Set the error code

	  l_err_msgname := 'PA_REV_CA_INVALID_STATUS_CHNG';
          fnd_message.set_name('PA', l_err_msgname);
          fnd_msg_pub.add;

	  l_err_code := 11;

     END IF;

   END IF; -- Cost accrual flag

  END IF;  -- Status = CLOSED
x_err_code := l_err_code;
EXCEPTION
WHEN OTHERS THEN
x_err_code  := NULL;
x_warnings_only_flag := NULL;
END Verify_Project_Status_CA;

--
-- Procedure that checks if project has cost accrual and sets the
-- variables from attribute columns 11-15 of billing extension
--
PROCEDURE   Check_if_Cost_Accrual ( p_project_id   IN NUMBER
			  ,x_cost_accrual_flag     IN OUT NOCOPY VARCHAR2
   			  ,x_funding_flag          IN OUT NOCOPY VARCHAR2
		          ,x_ca_event_type         IN OUT NOCOPY VARCHAR2
		 	  ,x_ca_contra_event_type  IN OUT NOCOPY VARCHAR2
		          ,x_ca_wip_event_type     IN OUT NOCOPY VARCHAR2
		          ,x_ca_budget_type        IN OUT NOCOPY VARCHAR2
			 )
IS

  l_Project_Type  	  VARCHAR2(100);
  l_Check_For_Proj_Type   NUMBER;
  l_Org_ID		  NUMBER;
  l_funding_flag	  VARCHAR2(1);
  l_funding_flag1	  VARCHAR2(1);
  l_cost_accrual_flag     VARCHAR2(1);
  l_ca_event_type         VARCHAR2(150);
  l_ca_contra_event_type  VARCHAR2(150);
  l_ca_wip_event_type     VARCHAR2(150);
  l_ca_budget_type        VARCHAR2(150);
BEGIN
  l_cost_accrual_flag    := x_cost_accrual_flag;
  l_funding_flag         := x_funding_flag;
  l_ca_event_type        := x_ca_event_type;
  l_ca_contra_event_type := x_ca_contra_event_type;
  l_ca_wip_event_type    := x_ca_wip_event_type;
  l_ca_budget_type       := x_ca_budget_type;

  l_cost_accrual_flag := 'N';

  Begin
    select 'Y',
	   nvl(p.project_level_funding_flag ,'X') ,
	   be.attribute12,
	   be.attribute13,
	   be.attribute14,
	   be.attribute15
    INTO   l_cost_accrual_flag,
	   l_funding_flag,
	   l_ca_event_type,
	   l_ca_contra_event_type,
	   l_ca_wip_event_type,
	   l_ca_budget_type
    from   pa_billing_extensions be,
	   pa_billing_assignments_all bea,
           pa_projects_all p
    where  p.project_id = p_project_id
    and    bea.active_flag = 'Y'
    and    bea.billing_extension_id = be.billing_extension_id
    and    be.attribute11 = 'COST-ACCRUAL'
    and    bea.project_id  = p_project_id
    order by be.processing_order, bea.billing_assignment_id;
    Exception when no_data_found then
      l_Check_For_Proj_Type := 1;
  End;
  IF l_Check_For_Proj_Type = 1 THEN
    Begin
      Select Project_type, Org_ID , NVL(PROJECT_LEVEL_FUNDING_FLAG,'X')
      INTO   l_Project_Type, l_Org_ID, l_funding_flag1
      from   PA_PROJECTS_ALL
      where  Project_ID = P_Project_ID;
      Exception when no_data_found then
	l_cost_accrual_flag := 'N';
	l_Check_For_Proj_Type := 0;
    End;
    If l_Check_For_Proj_Type = 1 THEN
      Begin
        select 'Y',
	     l_funding_flag1,
	     be.attribute12,
	     be.attribute13,
	     be.attribute14,
	     be.attribute15
        INTO l_cost_accrual_flag,
	     l_funding_flag,
	     l_ca_event_type,
	     l_ca_contra_event_type,
	     l_ca_wip_event_type,
	     l_ca_budget_type
        from pa_billing_extensions be,
	     pa_billing_assignments_all bea
        where  bea.active_flag = 'Y'
        and    bea.billing_extension_id = be.billing_extension_id
        and    be.attribute11 = 'COST-ACCRUAL'
        and    bea.project_type = l_Project_Type
        and    bea.org_id = l_Org_ID
        order by be.processing_order, bea.billing_assignment_id;
        Exception When No_Data_Found then
	  l_cost_accrual_flag := 'N';
      End;
    End If;
  End IF;

  If l_cost_accrual_flag = 'Y' then
     g_ca_event_type        := l_ca_event_type;
     g_ca_contra_event_type := l_ca_contra_event_type;
     g_ca_wip_event_type    := l_ca_wip_event_type;
     g_ca_budget_type       := l_ca_budget_type;
  End If;

x_ca_event_type        := l_ca_event_type;
x_ca_contra_event_type := l_ca_contra_event_type;
x_ca_wip_event_type    := l_ca_wip_event_type;
x_ca_budget_type       := l_ca_budget_type;
x_cost_accrual_flag    := l_cost_accrual_flag;
x_funding_flag         := l_funding_flag;
EXCEPTION
WHEN OTHERS THEN
x_ca_event_type        := NULL;
x_ca_contra_event_type := NULL;
x_ca_wip_event_type    := NULL;
x_ca_budget_type       := NULL;
x_cost_accrual_flag    := NULL;
x_funding_flag         := NULL;

END Check_if_Cost_Accrual;

END pa_rev_ca;

/
