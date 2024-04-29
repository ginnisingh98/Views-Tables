--------------------------------------------------------
--  DDL for Package Body PA_BILL_PCT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_BILL_PCT" AS
/* $Header: PAXPCTB.pls 120.3.12010000.2 2009/06/01 05:45:53 dlella ship $ */

/** Main procedure that calculates the revenue and invoice amounts **/

g1_debug_mode varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

PROCEDURE calc_pct_comp_amt
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
event_revenue REAL := 0;
event_invoice REAL := 0;
cost_amount REAL := 0;
revenue	REAL := 0;
invoice REAL := 0;
Amount_Left REAL := 0;
Percent_Complete REAL := 0;
calc_inv_amount REAL :=0;  -- added for bug 4719700
calc_rev_amount REAL :=0;  -- added for bug 4719700

event_description	VARCHAR2(240);
l_currency_code         VARCHAR2(15);

-- The cost and revenue budget type codes used by the get_rev_budget_amount procedure
--
l_cost_budget_type_code VARCHAR2(30);
l_rev_budget_type_code  VARCHAR2(30);

l_status		NUMBER;
l_error_message 	VARCHAR2(240);

pct_error		EXCEPTION;

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

/* Added for Fin Plan impact */
l_cost_plan_type_id      NUMBER;
l_rev_plan_type_id       NUMBER;
/* till here */

BEGIN
IF g1_debug_mode  = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('Entering pa_bill_pct.calc_pct_comp_amt  :');
END IF;


/** gets project currency code This is commented because now PFC and Project currency can be diffrent for MCB2 **/
 /* l_currency_code := pa_multi_currency_txn.get_proj_curr_code_sql(X_project_id); */

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

IF g1_debug_mode  = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('pa_bill_pct.calc_pct_comp_amt  currency :'||l_currency_code);
END IF;
/** gets the cost and revenue budget amounts **/

  IF g1_debug_mode  = 'Y' THEN
  	PA_MCB_INVOICE_PKG.log_message('Before pa_billing_extn_params_v select pa_bill_pct.calc_pct_comp_amt  :');
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
      	PA_MCB_INVOICE_PKG.log_message('Error from pa_billing_extn_params_v pa_bill_pct.calc_pct_comp_amt :'||SQLERRM);
      END IF;
      RAISE;
   END;
  /* till here */

  IF g1_debug_mode  = 'Y' THEN
  	PA_MCB_INVOICE_PKG.log_message('pa_bill_pct.calc_pct_comp_amt  cost_plan_type_id :'||l_cost_plan_type_id);
  	PA_MCB_INVOICE_PKG.log_message('pa_bill_pct.calc_pct_comp_amt  rev_plan_type_id :' ||l_rev_plan_type_id);
  END IF;

  l_status := 0;
  l_error_message := NULL;
                 get_rev_budget_amount(
		X2_project_id => X_project_id,
		X2_task_id => X_top_task_id,
		X2_revenue_amount => budget_revenue,
                X_rev_budget_type_code =>  l_rev_budget_type_code,
                X_rev_plan_type_id     =>  l_rev_plan_type_id,
		X_error_message	=> l_error_message,
		X_status	=> l_status);
IF g1_debug_mode  = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('After call of get_rev_budget_amount inside pa_bill_pct.calc_pct_comp_amt  :'||to_char(budget_revenue));
END IF;

-- If get budget amount return an error its fatal.

  IF l_status <> 0 THEN
	raise pct_error;
  END IF;

/** Get the event amounts generated by events other than Percent complete **/

IF g1_debug_mode  = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('Before calling PotEventAmount inside  pa_bill_pct.calc_pct_comp_amt  :');
END IF;
  PA_BILL_PCT.PotEventAmount(
		 X2_project_id => X_project_id,
 		 X2_task_id => X_top_task_id,
		 X2_accrue_through_date => X_rev_or_bill_date,
		 X2_revenue_amount => event_revenue,
		 X2_invoice_amount => event_invoice);

IF g1_debug_mode  = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('After calling PotEventAmount inside  pa_bill_pct.calc_pct_comp_amt  event revenue :'||to_char(event_revenue));
	PA_MCB_INVOICE_PKG.log_message('After calling PotEventAmount inside  pa_bill_pct.calc_pct_comp_amt  event invoice :'||to_char(event_invoice));
END IF;
/** Get the amount left based on the hard limit set for the projects
    customers **/

IF g1_debug_mode  = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('before calling pa_billing_amount.LowestAmountLeft inside  pa_bill_pct.calc_pct_comp_amt  :');
END IF;
  Amount_Left := pa_billing_amount.LowestAmountLeft(
					X_project_id,
					X_top_task_id,
					X_calling_process);

IF g1_debug_mode  = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('After calling PotEventAmount inside  pa_bill_pct.calc_pct_comp_amt  Amount_Left :'||to_char(Amount_Left));
END IF;
/** Get the Percent complete for the project / top task **/

IF g1_debug_mode  = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('before calling GetPercentComplete inside  pa_bill_pct.calc_pct_comp_amt  Percent_Complete :');
END IF;
  Percent_Complete := PA_BILL_PCT.GetPercentComplete(
					X_project_id ,
					X_top_task_id,
					X_rev_or_bill_date
					);


IF g1_debug_mode  = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('After calling GetPercentComplete inside  pa_bill_pct.calc_pct_comp_amt  Percent_Complete :'||to_char(Percent_Complete));
END IF;
 IF Percent_Complete > 100 THEN
    Percent_Complete := 100;
 END IF;

--			DBMS_OUTPUT.PUT('Revenue =');
--			DBMS_OUTPUT.PUT_LINE(Revenue);
--			DBMS_OUTPUT.PUT('Amount_Left=');
--			DBMS_OUTPUT.PUT_LINE(Amount_Left);
--			DBMS_OUTPUT.PUT('budget_cost=');
--			DBMS_OUTPUT.PUT_LINE(budget_cost);
--			DBMS_OUTPUT.PUT('budget_revenue=');
--			DBMS_OUTPUT.PUT_LINE(budget_revenue);
--			DBMS_OUTPUT.PUT('cost_amount=');
--			DBMS_OUTPUT.PUT_LINE(cost_amount);
--			DBMS_OUTPUT.PUT('revenue_amount=');
--			DBMS_OUTPUT.PUT_LINE(revenue_amount);
--			DBMS_OUTPUT.PUT('event_revenue=');
--			DBMS_OUTPUT.PUT_LINE(event_revenue);

  IF (X_calling_process = 'Revenue') THEN

IF g1_debug_mode  = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('before calling RevenueAmount inside  pa_bill_pct.calc_pct_comp_amt  RevenueAmount :');
END IF;
    PA_BILL_PCT.RevenueAmount(
		  X2_project_id => x_project_id,
 		  X2_task_id => X_top_task_id,
	   	  X2_revenue_amount => revenue_amount);

IF g1_debug_mode  = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('After calling RevenueAmount inside  pa_bill_pct.calc_pct_comp_amt  RevenueAmount :'||to_char(revenue_amount));
END IF;
--    IF (budget_cost <> 0) THEN
    --   Revenue is the Least of
    --   revenue = percent_complete * (budget_revenue - event_revenue)
    --                - existing revenue.
    --   or the amount left in the funding.

    /*	Revenue := Least(  ((nvl(Percent_Complete,0) * 0.01)
			      * greatest( nvl(budget_revenue,0)
 				           - nvl(event_revenue,0), 0
			                )
 			      - (nvl(revenue_amount,0))
			   ) ,
			   Amount_Left
            		);Commenting for bug 4719700*/
    /* Added for bug 4719700 BEGIN */
        calc_rev_amount :=  pa_multi_currency_billing.round_trans_currency_amt((nvl(Percent_Complete,0) * 0.01)
			      * greatest( nvl(budget_revenue,0)
 				           - nvl(event_revenue,0), 0
			                ),l_projfunc_currency_code);

        Revenue := Least( (calc_rev_amount - (nvl(revenue_amount,0))) , Amount_Left);
    /* Addded for bug 4719700 END */


IF g1_debug_mode  = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('Calculating  Revenue inside  pa_bill_pct.calc_pct_comp_amt (Least) Revenue :'||to_char(Revenue));
END IF;
        /* Changed the length of the format mask for amount_left column from 15 to 22
           to fix the bug 2124494 for MCB2 */
        /* Changed the length of the format mask for all column from 15 to 22
           to fix the bug 2162900 for MCB2 */
	/* Removed the format mask for Percent_Complete as this was rounding off
	   the value for bug 6660286 */
	Event_Description := 'Percent Complete Least ' || '(' ||
	       to_char(amount_left,fnd_currency.get_format_mask(l_currency_code,22))
               || ' ,((' ||
	       rtrim(to_char(Percent_Complete * 0.01,'0.000000'),'0')
               || ' * (' ||
	       to_char(budget_revenue,fnd_currency.get_format_mask(l_currency_code,22))
               || ' - ' ||
	       to_char(nvl(event_revenue,0),fnd_currency.get_format_mask(l_currency_code,22))
               || ')) - '||
	       to_char(nvl(revenue_amount,0),fnd_currency.get_format_mask(l_currency_code,22))
               || ' ))';

	/** public api to insert event **/

IF g1_debug_mode  = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('rev part inside pa_bill_pct.calc_pct_comp_amt event desc :'||Event_Description);
	PA_MCB_INVOICE_PKG.log_message('rev part Before calling insert_event inside  pa_bill_pct.calc_pct_comp_amt  Revenue :');
END IF;
    	pa_billing_pub.insert_event (
			X_rev_amt => Revenue,
			X_bill_amt => 0,
                       	X_event_description => event_description,
                        X_audit_amount1 => amount_left,
                        X_audit_amount2 => revenue_amount,
                        X_audit_amount3 => budget_revenue,
                        X_audit_amount4 => event_revenue,
			X_audit_amount5 => Percent_Complete,
                        X_audit_cost_budget_type_code => l_cost_budget_type_code,
                        X_audit_rev_budget_type_code => l_rev_budget_type_code,
                        X_audit_cost_plan_type_id     => l_cost_plan_type_id, /* Added for fin plan impact */
                        X_audit_rev_plan_type_id      => l_rev_plan_type_id,  /* Added for fin plan impact */
			X_error_message => l_error_message,
			X_status	=> l_status
			);

IF g1_debug_mode  = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('Rev part After calling insert_event inside  pa_bill_pct.calc_pct_comp_amt  Revenue -> status :'||l_status);
END IF;
	IF l_status <> 0 THEN
	   raise pct_error;
        END IF;

--   END IF;

  ELSE
IF g1_debug_mode  = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('before calling InvoiceAmount inside  pa_bill_pct.calc_pct_comp_amt  InvoiceAmount :');
END IF;
    PA_BILL_PCT.InvoiceAmount(
		  X2_project_id => X_project_id,
 		  X2_task_id => X_top_task_id,
		  X2_invoice_amount => invoice_amount);

IF g1_debug_mode  = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('After calling InvoiceAmount inside  pa_bill_pct.calc_pct_comp_amt  InvoiceAmount :'||to_char(invoice_amount));
END IF;
--    IF (budget_cost <> 0) THEN
	/*Invoice := Least( (( nvl(Percent_Complete,0) * 0.01)
			    * greatest( (nvl(budget_revenue,0)
					- nvl(event_invoice,0)), 0)
			  ) - nvl(invoice_amount,0),
			  nvl(Amount_Left,0)
			);Commenting for bug 4719700*/
/* Changes for 4719700 -Start */

 calc_inv_amount := pa_multi_currency_billing.round_trans_currency_amt((( nvl(Percent_Complete,0) * 0.01)
			    * greatest( (nvl(budget_revenue,0)
					- nvl(event_invoice,0)), 0)
			  ),l_projfunc_currency_code);

 Invoice :=Least( calc_inv_amount - nvl(invoice_amount,0), nvl(Amount_Left,0));
/* Changes for 4719700 -End */


IF g1_debug_mode  = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('calculating  Invoice Amount ( with least) inside  pa_bill_pct.calc_pct_comp_amt  Invoice :'||to_char(Invoice));
END IF;
        /* Changed the length of the format mask for amount_left column from 15 to 22
           to fix the bug 2124494 for MCB2 */
        /* Changed the length of the format mask for all column from 15 to 22
           to fix the bug 2162900 for MCB2 */
	/* Removed the format mask for Percent_Complete as this was rounding off
	   the value for bug 6660286 */
	Event_Description := 'Percent Complete Least '|| '(' ||
	       to_char(amount_left,fnd_currency.get_format_mask(l_currency_code,22))
               || ' ,((' ||
	       rtrim(to_char(Percent_Complete * 0.01,'0.000000'),'0')
               || ' * (' ||
	       to_char(budget_revenue,fnd_currency.get_format_mask(l_currency_code,22))
               || ' - ' ||
	       to_char(nvl(event_invoice,0),fnd_currency.get_format_mask(l_currency_code,22))
               || ')) - '||
	       to_char(nvl(invoice_amount,0),fnd_currency.get_format_mask(l_currency_code,22))
               || ' ))';

IF g1_debug_mode  = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('Inv part inside pa_bill_pct.calc_pct_comp_amt event desc :'||Event_Description);
	PA_MCB_INVOICE_PKG.log_message('Inv part Before insert event  inside  pa_bill_pct.calc_pct_comp_amt  Invoice :');
END IF;
    	pa_billing_pub.insert_event (
			X_rev_amt => 0,
			X_bill_amt => Invoice,
			X_event_description => Event_Description,
                        X_audit_amount1 => amount_left,
                        X_audit_amount2 => invoice_amount,
                        X_audit_amount3 => budget_revenue,
                        X_audit_amount4 => event_invoice,
			X_audit_amount5 => Percent_Complete,
                        X_audit_cost_budget_type_code => l_cost_budget_type_code,
                        X_audit_rev_budget_type_code => l_rev_budget_type_code,
                        X_audit_cost_plan_type_id     => l_cost_plan_type_id, /* Added for fin plan impact */
                        X_audit_rev_plan_type_id      => l_rev_plan_type_id,  /* Added for fin plan impact */
			X_error_message => l_error_message,
			X_status	=> l_status
			);

IF g1_debug_mode  = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('Inv partinsert event  inside  pa_bill_pct.calc_pct_comp_amt  Invoice -> status :'||l_status);
END IF;
	IF l_status <> 0 THEN
	   raise pct_error;
        END IF;
--    END IF;
  END IF;

IF g1_debug_mode  = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('Exiting pa_bill_pct.calc_pct_comp_amt :');
END IF;
EXCEPTION
  WHEN  pct_error THEN
      IF g1_debug_mode  = 'Y' THEN
      	PA_MCB_INVOICE_PKG.log_message('Inside pct_error inside  pa_bill_pct.calc_pct_comp_amt');
      END IF;
        NULL;
--  Modified so that this exception is reported but doesnot stop revenue
--  processing
--        RAISE_APPLICATION_ERROR(-20101,l_error_message);
  WHEN OTHERS THEN
--      DBMS_OUTPUT.PUT_LINE(SQLERRM);
        IF g1_debug_mode  = 'Y' THEN
        	PA_MCB_INVOICE_PKG.log_message('Inside when other of  pa_bill_pct.calc_pct_comp_amt');
        END IF;
	RAISE;

END calc_pct_comp_amt;


Procedure PotEventAmount( 	X2_project_id 	NUMBER,
				X2_task_id 	NUMBER DEFAULT NULL,
				X2_accrue_through_date DATE DEFAULT NULL,
				X2_revenue_amount OUT NOCOPY  REAL,
				X2_invoice_amount OUT NOCOPY  REAL)
IS
/* Declaring varible for MCB2 */
l_trans_rev_amt                   pa_events.bill_trans_rev_amount%TYPE;
l_trans_bill_amt               pa_events.bill_trans_bill_amount%TYPE;
l_passd_amt                       pa_events.bill_trans_bill_amount%TYPE := 0;
l_projfunc_amount_sum             pa_events.projfunc_revenue_amount%TYPE;
l_converted_amount                pa_events.projfunc_revenue_amount%TYPE;
l_txn_currency_code               pa_events.bill_trans_currency_code%TYPE;
l_projfunc_currency_code          pa_events.projfunc_currency_code%TYPE;
l_projfunc_rate_type              pa_events.projfunc_rate_type%TYPE;
l_projfunc_rate_date              pa_events.projfunc_rate_date%TYPE;
l_projfunc_exchange_rate          pa_events.projfunc_exchange_rate%TYPE;
l_event_date                      pa_events.completion_date%TYPE;
l_conv_date                       pa_events.completion_date%TYPE;
l_denominator                     Number;
l_numerator                       Number;
l_staus                           Varchar2(30);
l_calling_process                 Varchar2(50);
l_project_id                      pa_projects_all.project_id%TYPE;
l_multi_currency_billing_flag     pa_projects_all.multi_currency_billing_flag%TYPE;
l_baseline_funding_flag           pa_projects_all.baseline_funding_flag%TYPE;
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


--Modified the following cursor for bug 8429063

CURSOR pctfunc_rev_inv_amt(X2_project_id Number,X2_task_id Number,X2_accrue_through_date Date) IS
   SELECT  (DECODE(revenue_hold_flag, 'Y' , 0 ,DECODE(et.event_type_classification,
	   'WRITE OFF',-1 * nvl(bill_trans_rev_amount,0),
	   'RLZED_LOSSES',-1 * nvl(bill_trans_rev_amount,0),
           NVL(bill_trans_rev_amount,0)))) trans_rev_amount,
           (DECODE(bill_hold_flag, 'Y' , 0 , DECODE(et.event_type_classification,'INVOICE REDUCTION', -1 * nvl(bill_trans_bill_amount,0),
           NVL(bill_trans_bill_amount,0)))) trans_bill_amount,e.bill_trans_currency_code,e.projfunc_currency_code,
           e.projfunc_rate_type,e.projfunc_rate_date,e.projfunc_exchange_rate
FROM	pa_events e,
	pa_event_types et
WHERE	e.event_type = et.event_type
AND	e.project_id = X2_project_id
AND	nvl(e.task_id,0) = nvl(X2_task_id, nvl(e.task_id,0))
AND	e.completion_date <= nvl(X2_accrue_through_date, sysdate)
AND	NOT EXISTS (	select '1'
		    	from	pa_billing_assignments bea,
				pa_billing_extensions be
			where	be.billing_extension_id = bea.billing_extension_id
			and	bea.billing_assignment_id = e.billing_assignment_id
			and	be.procedure_name = 'pa_bill_pct.calc_pct_comp_amt');

BEGIN

IF g1_debug_mode  = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('Enetering  pa_bill_pct.PotEventAmount  ');
END IF;
/** Sum of all event amounts other than events created by percent complete **/
/*The following sql has been commented for MCB2 */
/* SELECT 	sum(decode(et.event_type_classification,
		'WRITE OFF',	-1 * nvl(revenue_amount,0),
				nvl(revenue_amount,0))),
	sum(decode(et.event_type_classification,
		'INVOICE REDUCTION', -1 * nvl(bill_amount,0),
				nvl(bill_amount,0)))
INTO	X2_revenue_amount,
	X2_invoice_amount
FROM	pa_events e,
	pa_event_types et
WHERE	e.event_type = et.event_type
AND	e.project_id = X2_project_id
AND	nvl(e.task_id,0) = nvl(X2_task_id, nvl(e.task_id,0))
AND	e.completion_date <= nvl(X2_accrue_through_date, sysdate)
AND	NOT EXISTS (	select '1'
		    	from	pa_billing_assignments bea,
				pa_billing_extensions be
			where	be.billing_extension_id = bea.billing_extension_id
			and	bea.billing_assignment_id = e.billing_assignment_id
			and	be.procedure_name = 'pa_bill_pct.calc_pct_comp_amt'); */

       /* Following code has been added for MCB2 */
         l_project_id := X2_project_id;
         l_calling_process := pa_billing.GetCallProcess;
      PA_MULTI_CURRENCY_BILLING.get_project_defaults (
            p_project_id                  =>  l_project_id,
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
       OPEN pctfunc_rev_inv_amt( X2_project_id,X2_task_id,X2_accrue_through_date);
        Loop
          FETCH pctfunc_rev_inv_amt INTO l_trans_rev_amt,l_trans_bill_amt,l_txn_currency_code,
                                         l_projfunc_currency_code,l_projfunc_rate_type,
                                         l_projfunc_rate_date,l_projfunc_exchange_rate;
          EXIT WHEN pctfunc_rev_inv_amt%NOTFOUND;
          IF ( l_calling_process = 'Revenue' ) THEN
            l_projfunc_rate_date := NVL(l_projfunc_rate_date,pa_billing.GetPaDate);
            l_passd_amt := l_trans_rev_amt;
          ELSIF ( l_calling_process = 'Invoice' ) THEN
            l_projfunc_rate_date := NVL(l_projfunc_rate_date,pa_billing.GetInvoiceDate);
            l_passd_amt := l_trans_bill_amt;
          END IF;
          /* Calling convert amount proc to convert this amount in PFC */
          PA_MULTI_CURRENCY.convert_amount(
                            P_FROM_CURRENCY          => l_txn_currency_code,
                            P_TO_CURRENCY            => l_projfunc_currency_code,
                            P_CONVERSION_DATE        => l_projfunc_rate_date,
                            P_CONVERSION_TYPE        => l_projfunc_rate_type,
                            P_AMOUNT                 => l_passd_amt,
                            P_USER_VALIDATE_FLAG     => 'Y',
                            P_HANDLE_EXCEPTION_FLAG  => 'Y',
                            P_CONVERTED_AMOUNT       => l_converted_amount,
                            P_DENOMINATOR            => l_denominator,
                            P_NUMERATOR              => l_numerator,
                            P_RATE                   => l_projfunc_exchange_rate,
                            X_STATUS                 => l_staus);
                            IF ( l_staus IS NOT NULL ) THEN
                               l_converted_amount := 0;
                            END IF;

          l_projfunc_amount_sum := NVL(l_projfunc_amount_sum,0) + NVL(l_converted_amount,0);
          IF g1_debug_mode  = 'Y' THEN
          	PA_MCB_INVOICE_PKG.log_message('The calculated amount after convert amount inside  pa_bill_pct.PotEventAmount : '||to_char(l_projfunc_amount_sum)||'calling process  '||l_calling_process);
          END IF;
        End Loop;
       Close pctfunc_rev_inv_amt;

       IF ( l_calling_process = 'Revenue' ) THEN
         X2_revenue_amount := l_projfunc_amount_sum;
         X2_invoice_amount := 0;
       ELSIF ( l_calling_process = 'Invoice' ) THEN
            X2_revenue_amount := 0;
            X2_invoice_amount := l_projfunc_amount_sum;
       END IF;

          IF g1_debug_mode  = 'Y' THEN
          	PA_MCB_INVOICE_PKG.log_message('Exiting from pa_bill_pct.PotEventAmount  ');
          END IF;
/* Added the below for NOCOPY mandate */
EXCEPTION WHEN OTHERS THEN
  X2_revenue_amount := 0;
  X2_invoice_amount := 0;
END PotEventAmount;


Procedure RevenueAmount(  	X2_project_id NUMBER,
	 			X2_task_Id   NUMBER DEFAULT NULL,
				X2_revenue_amount OUT NOCOPY REAL) IS

pending_pctrev	REAL;
accrued_pctrev	REAL;

/* Varible for MCB2 */
l_trans_rev_amt                   pa_events.bill_trans_rev_amount%TYPE;
l_projfunc_rev_amount_sum         pa_events.projfunc_revenue_amount%TYPE;
l_converted_rev_amount            pa_events.projfunc_revenue_amount%TYPE;
l_txn_currency_code               pa_events.bill_trans_currency_code%TYPE;
l_projfunc_currency_code          pa_events.projfunc_currency_code%TYPE;
l_projfunc_rate_type              pa_events.projfunc_rate_type%TYPE;
l_projfunc_rate_date              pa_events.projfunc_rate_date%TYPE;
l_projfunc_exchange_rate          pa_events.projfunc_exchange_rate%TYPE;
l_event_date                      pa_events.completion_date%TYPE;
l_conv_date                       pa_events.completion_date%TYPE;
l_denominator                     Number;
l_numerator                       Number;
l_staus                           Varchar2(30);
l_project_id                      pa_projects_all.project_id%TYPE;
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

CURSOR pctfunc_revenue(X2_project_id Number,X2_task_id Number) IS
        SELECT  NVL(e.bill_trans_rev_amount,0) trans_rev_amount,e.bill_trans_currency_code,
                e.projfunc_currency_code,e.projfunc_rate_type,e.projfunc_rate_date,e.projfunc_exchange_rate
	FROM 	pa_events e,
		pa_billing_assignments bea,
		pa_billing_extensions be
	where	be.billing_extension_id = bea.billing_extension_id
	and	e.project_id = X2_project_id
	and    	nvl(e.task_id,0) =
			decode(X2_task_id,
				NULL, 	nvl(e.task_id,0), X2_task_id )
	and	bea.billing_assignment_id = e.billing_assignment_id
	and	be.procedure_name = 'pa_bill_pct.calc_pct_comp_amt'
	and	e.revenue_distributed_flag||'' = 'N';

BEGIN

          IF g1_debug_mode  = 'Y' THEN
          	PA_MCB_INVOICE_PKG.log_message('RevenueAmount: ' || 'Entering pa_bill_pct.RevenuAmount  ');
          END IF;
-- Percent Complete Revenue that has been accrued.
/* change this column from amount to projfunc_revenue_amount for MCB2 */
SELECT sum(nvl(dri.projfunc_revenue_amount,0))
INTO   accrued_pctrev
FROM   pa_draft_revenue_items dri
WHERE  dri.project_id = X2_project_id
AND    nvl(dri.task_id,0) = decode(X2_task_id, NULL, nvl(dri.task_id,0), X2_task_id )
AND    (EXISTS (	select '1'
			from 	pa_cust_event_rev_dist_lines erdl,
				pa_events e,
				pa_billing_assignments bea,
				pa_billing_extensions be
			where	be.billing_extension_id = bea.billing_extension_id
			and	bea.billing_assignment_id = e.billing_assignment_id
			and	e.project_id = erdl.project_id
			and	e.event_num = erdl.event_num
			and	nvl(e.task_id,0) = nvl(erdl.task_id, 0)
			and	erdl.project_id = dri.project_id
			and	erdl.draft_revenue_num = dri.draft_revenue_num
			and	erdl.draft_revenue_item_line_num = dri.line_num
			and	be.procedure_name = 'pa_bill_pct.calc_pct_comp_amt')
       OR dri.revenue_source like 'Expenditure%');

          IF g1_debug_mode  = 'Y' THEN
          	PA_MCB_INVOICE_PKG.log_message('RevenueAmount: ' || 'The accrued_pctrev inside pa_bill_pct.RevenuAmount:  '||to_char(accrued_pctrev));
          END IF;
-- Percent Complete revenue that has not been created as events
-- but not accrued yet.
-- This could be due to unauthorized task or an erroring request.
/* The following code is commented because this amount is in RPC i.e. Revenue programm is going to populate this amount
*/
/*
	SELECT 	sum(nvl(e.revenue_amount,0))
	INTO	pending_pctrev
	FROM 	pa_events e,
		pa_billing_assignments bea,
		pa_billing_extensions be
	where	be.billing_extension_id = bea.billing_extension_id
	and	e.project_id = X2_project_id
	and    	nvl(e.task_id,0) =
			decode(X2_task_id,
				NULL, 	nvl(e.task_id,0), X2_task_id )
	and	bea.billing_assignment_id = e.billing_assignment_id
	and	be.procedure_name = 'pa_bill_pct.calc_pct_comp_amt'
	and	e.revenue_distributed_flag||'' = 'N'; */

       /* Following code has been added for MCB2 */
         l_project_id := X2_project_id;
      PA_MULTI_CURRENCY_BILLING.get_project_defaults (
            p_project_id                  =>  l_project_id,
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

       OPEN pctfunc_revenue( X2_project_id,X2_task_id);
        Loop
          FETCH pctfunc_revenue INTO l_trans_rev_amt,l_txn_currency_code,l_projfunc_currency_code,
                          l_projfunc_rate_type,l_projfunc_rate_date,l_projfunc_exchange_rate;
          EXIT WHEN pctfunc_revenue%NOTFOUND;
          IF ( l_project_bil_rate_date_code = 'PA_INVOICE_DATE' ) THEN
            l_projfunc_rate_date := NVL(l_projfunc_rate_date,pa_billing.GetPaDate);
          END IF;

          /* Calling convert amount proc to convert this amount in PFC */
          PA_MULTI_CURRENCY.convert_amount(
                            P_FROM_CURRENCY          => l_txn_currency_code,
                            P_TO_CURRENCY            => l_projfunc_currency_code,
                            P_CONVERSION_DATE        => l_projfunc_rate_date,
                            P_CONVERSION_TYPE        => l_projfunc_rate_type,
                            P_AMOUNT                 => l_trans_rev_amt,
                            P_USER_VALIDATE_FLAG     => 'Y',
                            P_HANDLE_EXCEPTION_FLAG  => 'Y',
                            P_CONVERTED_AMOUNT       => l_converted_rev_amount,
                            P_DENOMINATOR            => l_denominator,
                            P_NUMERATOR              => l_numerator,
                            P_RATE                   => l_projfunc_exchange_rate,
                            X_STATUS                 => l_staus);
                            IF ( l_staus IS NOT NULL ) THEN
                               l_converted_rev_amount := 0;
                            END IF;

          l_projfunc_rev_amount_sum := NVL(l_projfunc_rev_amount_sum,0) + NVL(l_converted_rev_amount,0);
        End Loop;
       Close pctfunc_revenue;
       pending_pctrev := l_projfunc_rev_amount_sum;

          IF g1_debug_mode  = 'Y' THEN
          	PA_MCB_INVOICE_PKG.log_message('RevenueAmount: ' || 'The pending_pctrev : inside pa_bill_pct.RevenuAmount  '||to_char(pending_pctrev ));
          END IF;
	X2_revenue_amount := nvl(accrued_pctrev,0) + nvl(pending_pctrev,0);

          IF g1_debug_mode  = 'Y' THEN
          	PA_MCB_INVOICE_PKG.log_message('RevenueAmount: ' || 'Exiting pa_bill_pct.RevenuAmount  ');
          END IF;

/* Added the below for NOCOPY mandate */
EXCEPTION WHEN OTHERS THEN
   X2_revenue_amount := NULL;
END RevenueAmount;

Procedure InvoiceAmount(	X2_project_id	NUMBER,
				X2_task_id	NUMBER default NULL,
				X2_invoice_amount OUT NOCOPY  REAL) IS

pending_ccinv		REAL;
task_billed_ccinv	REAL;
task_billed_ev_ccinv	REAL;
billed_ccinv 		REAL;

/* Varibles added for MCB2 */
l_trans_bill_amt               pa_events.bill_trans_bill_amount%TYPE;
l_projfunc_bill_amount_sum        pa_events.projfunc_bill_amount%TYPE;
l_converted_bill_amount           pa_events.projfunc_bill_amount%TYPE;
l_txn_currency_code               pa_events.bill_trans_currency_code%TYPE;
l_projfunc_currency_code          pa_events.projfunc_currency_code%TYPE;
l_projfunc_rate_type              pa_events.projfunc_rate_type%TYPE;
l_projfunc_rate_date              pa_events.projfunc_rate_date%TYPE;
l_projfunc_exchange_rate          pa_events.projfunc_exchange_rate%TYPE;
l_event_date                      pa_events.completion_date%TYPE;
l_conv_date                       pa_events.completion_date%TYPE;
l_denominator                     Number;
l_numerator                       Number;
l_staus                           Varchar2(30);
l_project_id                      pa_projects_all.project_id%TYPE;
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

CURSOR pctfunc_invoice(X2_project_id Number,X2_task_id Number) IS
    SELECT NVL(e.bill_trans_bill_amount,0) trans_bill_amount,e.bill_trans_currency_code,e.projfunc_currency_code,
           e.projfunc_rate_type,e.projfunc_rate_date,e.projfunc_exchange_rate
    FROM 	pa_events e,
	        pa_billing_assignments bea,
	        pa_billing_extensions be
    WHERE	be.billing_extension_id = bea.billing_extension_id
    AND	bea.billing_assignment_id = e.billing_assignment_id
    AND	e.project_id = X2_project_id
    AND	be.procedure_name = 'pa_bill_pct.calc_pct_comp_amt'
    AND	nvl(e.task_id,0) = decode(X2_task_id,
		    NULL, nvl(e.task_id,0), X2_task_id)
    AND	NOT EXISTS
	        (select 'billed'
	         from   pa_draft_invoice_items pdii
	         where 	pdii.project_id = e.project_id
	         and  	pdii.event_num = e.event_num
	         and 	nvl(pdii.task_id,0) = nvl(e.task_id,0));

BEGIN
          IF g1_debug_mode  = 'Y' THEN
          	PA_MCB_INVOICE_PKG.log_message('Entering pa_bill_pct.InvoiceAmount  ');
          END IF;

-- Percent Complete  Invoice Amount that has been created as an event,
-- but not billed yet.
/* The following code is commented because this amount is in IPC i.e. Invoice programm is going to populate this amount
*/
/*
SELECT	sum(nvl(e.bill_amount,0))
INTO	pending_ccinv
from 	pa_events e,
	pa_billing_assignments bea,
	pa_billing_extensions be
where	be.billing_extension_id = bea.billing_extension_id
and	bea.billing_assignment_id = e.billing_assignment_id
and	e.project_id = X2_project_id
and	be.procedure_name = 'pa_bill_pct.calc_pct_comp_amt'
and	nvl(e.task_id,0) = decode(X2_task_id,
					NULL, nvl(e.task_id,0), X2_task_id)
and	NOT EXISTS
	(select 'billed'
	 from   pa_draft_invoice_items pdii
	 where 	pdii.project_id = e.project_id
	 and  	pdii.event_num = e.event_num
	 and 	nvl(pdii.task_id,0) = nvl(e.task_id,0)); */

       /* Following code has been added for MCB2 */
         l_project_id := X2_project_id;
      PA_MULTI_CURRENCY_BILLING.get_project_defaults (
            p_project_id                  =>  l_project_id,
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

       OPEN pctfunc_invoice( X2_project_id,X2_task_id);
        Loop
          FETCH pctfunc_invoice INTO l_trans_bill_amt,l_txn_currency_code,l_projfunc_currency_code,
                          l_projfunc_rate_type,l_projfunc_rate_date,l_projfunc_exchange_rate;
          EXIT WHEN pctfunc_invoice%NOTFOUND;
          IF ( l_project_bil_rate_date_code = 'PA_INVOICE_DATE' ) THEN
            l_projfunc_rate_date := NVL(l_projfunc_rate_date,pa_billing.GetInvoiceDate);
          END IF;
          /* Calling convert amount proc to convert this amount in PFC */
          PA_MULTI_CURRENCY.convert_amount(
                            P_FROM_CURRENCY          => l_txn_currency_code,
                            P_TO_CURRENCY            => l_projfunc_currency_code,
                            P_CONVERSION_DATE        => l_projfunc_rate_date,
                            P_CONVERSION_TYPE        => l_projfunc_rate_type,
                            P_AMOUNT                 => l_trans_bill_amt,
                            P_USER_VALIDATE_FLAG     => 'Y',
                            P_HANDLE_EXCEPTION_FLAG  => 'Y',
                            P_CONVERTED_AMOUNT       => l_converted_bill_amount,
                            P_DENOMINATOR            => l_denominator,
                            P_NUMERATOR              => l_numerator,
                            P_RATE                   => l_projfunc_exchange_rate,
                            X_STATUS                 => l_staus);
                            IF ( l_staus IS NOT NULL ) THEN
                               l_converted_bill_amount := 0;
                            END IF;

          l_projfunc_bill_amount_sum := NVL(l_projfunc_bill_amount_sum,0) + NVL(l_converted_bill_amount,0);
        End Loop;
       Close pctfunc_invoice;
       pending_ccinv := l_projfunc_bill_amount_sum;


          IF g1_debug_mode  = 'Y' THEN
          	PA_MCB_INVOICE_PKG.log_message('The pending_ccinv inside pa_bill_pct.InvoiceAmount:  '||to_char(pending_ccinv));
          END IF;
IF (X2_task_id IS NULL) THEN

  -- Percent Complete Invoice Amount that has been billed, or originates from
  -- expenditure items (historical cost-cost invoice amount)

/* Change this column from amount to projfunc_bill_amount for MCB2 */
  SELECT sum(nvl(dii.projfunc_bill_amount,0))
  INTO   billed_ccinv
  FROM	 pa_draft_invoice_items dii
  WHERE  dii.project_id = X2_project_id
  AND    (EXISTS 	(select '1'
			from 	pa_events e,
				pa_billing_assignments bea,
				pa_billing_extensions be
			where	be.billing_extension_id = bea.billing_extension_id
			and	bea.billing_assignment_id = e.billing_assignment_id
			and	dii.project_id = e.project_id
			and	dii.event_num = e.event_num
			and	nvl(dii.event_task_id,0) = nvl(e.task_id,0)
			and	be.procedure_name = 'pa_bill_pct.calc_pct_comp_amt')
          OR EXISTS (	select 	'1'
		   	from 	pa_cust_rev_dist_lines erdl
			where 	erdl.project_id = dii.project_id
			and	erdl.draft_invoice_num = dii.draft_invoice_num
			and	erdl.draft_invoice_item_line_num = dii.line_num));

          IF g1_debug_mode  = 'Y' THEN
          	PA_MCB_INVOICE_PKG.log_message('The billed_ccinv for task id is null inside pa_bill_pct.InvoiceAmount:  '||to_char(billed_ccinv));
          END IF;
	X2_invoice_amount := nvl(pending_ccinv,0) + nvl(billed_ccinv,0);

ELSE

/* Change this column from amount to projfunc_bill_amount for MCB2 */
  SELECT sum(nvl(rdl.projfunc_bill_amount,0))
  INTO	task_billed_ccinv
  FROM	pa_cust_rev_dist_lines rdl,
	pa_expenditure_items_all ei,
	pa_tasks t
  WHERE	ei.task_id = t.task_id
  AND   ei.Project_ID = t.Project_ID -- Perf Bug 2695332
  AND	ei.expenditure_item_id = rdl.expenditure_item_id
  AND	rdl.project_id = X2_project_id
  AND	t.top_task_id = X2_task_id
  AND	rdl.draft_invoice_num IS NOT NULL;

          IF g1_debug_mode  = 'Y' THEN
          	PA_MCB_INVOICE_PKG.log_message('The task_billed_ccinv for task id is not null inside pa_bill_pct.InvoiceAmount:  '||to_char(task_billed_ccinv));
          END IF;
/* Change this column from amount to projfunc_bill_amount for MCB2 */
  SELECT sum(nvl(pdii.projfunc_bill_amount,0))
  INTO   task_billed_ev_ccinv
  FROM   pa_draft_invoice_items pdii
  WHERE  pdii.event_task_id = X2_task_id
  AND    pdii.Project_ID = X2_Project_ID -- Perf Bug 2695332
  AND    EXISTS (select '1'
			from 	pa_events e,
				pa_billing_assignments bea,
				pa_billing_extensions be
			where	be.billing_extension_id = bea.billing_extension_id
			and	bea.billing_assignment_id = e.billing_assignment_id
			and	pdii.project_id = e.project_id
			and	pdii.event_num = e.event_num
			and	pdii.event_task_id = e.task_id
			and	be.procedure_name = 'pa_bill_pct.calc_pct_comp_amt');

          IF g1_debug_mode  = 'Y' THEN
          	PA_MCB_INVOICE_PKG.log_message('The task_billed_ev_ccinv for task id is not null inside pa_bill_pct.InvoiceAmount:  '||to_char(task_billed_ev_ccinv));
          END IF;
  X2_invoice_amount := nvl(task_billed_ccinv,0) + nvl(task_billed_ev_ccinv,0)				+ nvl(pending_ccinv,0);

END IF;

          IF g1_debug_mode  = 'Y' THEN
          	PA_MCB_INVOICE_PKG.log_message('Exiting pa_bill_pct.InvoiceAmount:  ');
          END IF;
/* Added the below for NOCOPY mandate */
EXCEPTION WHEN OTHERS THEN
   X2_invoice_amount := NULL;
END InvoiceAmount;


Function GetPercentComplete( 	X2_project_id 	NUMBER,
				X2_task_id 	NUMBER DEFAULT NULL,
				X2_accrue_through_date DATE DEFAULT NULL)
         RETURN REAL IS

percent_comp  REAL :=0;

-- Cursor to select the most recently entered completion percentage
--
/* Patchset K : Percent complete changes :
   Using the view PA_PERCENT_COMPLETES_FIN_V instead of pa_percent_completes */


/* Changed cursor to pickup record based on sequence number (percent_complete_id)
for bug no 1283352.

CURSOR pct IS
SELECT  NVL(completed_percentage,0)
FROM	PA_PERCENT_COMPLETES_FIN_V ppc
WHERE
ppc.project_id = X2_project_id AND
nvl(ppc.task_id,0) = nvl(X2_task_id,0 )
AND	ppc.date_computed
        =
         (SELECT max(date_computed)
          from PA_PERCENT_COMPLETES_FIN_V
          where date_computed <=  nvl(X2_accrue_through_date, sysdate)
          and   project_id = X2_project_id
          and   nvl(task_id,0) = nvl(X2_task_id,0)
         )
ORDER BY creation_date desc
;
bug fix 1283352 "commentation" ends. */

CURSOR pct IS
SELECT  NVL(completed_percentage,0)
FROM    PA_PERCENT_COMPLETES_FIN_V ppc
WHERE
ppc.project_id = X2_project_id
And nvl(ppc.task_id,0) = nvl(X2_task_id,0 )
And ppc.date_computed <= nvl(X2_accrue_through_date, sysdate)
And ppc.percent_complete_id  = ( Select max(ppcx.percent_complete_id)
                                 from PA_PERCENT_COMPLETES_FIN_V ppcx
                                 where project_id = X2_project_id
                                 and   nvl(task_id,0) = nvl(X2_task_id,0)
                                 and   ppcx.date_computed = (
                                           Select max(ppcy.date_computed)
                                           from   PA_PERCENT_COMPLETES_FIN_V ppcy
                                           Where  ppcy.date_computed <=  nvl(X2_accrue_through_date, sysdate)
                                           and    ppcy.project_id = X2_project_id
                                           and    nvl(ppcy.task_id,0) = nvl(X2_task_id,0)));
BEGIN

/** get the most recent percent complete before the accru thru date **/

          -- PA_MCB_INVOICE_PKG.log_message('Entering pa_bill_pct.GetPercentComplete:  ');
OPEN pct;

FETCH pct INTO percent_comp;

          -- PA_MCB_INVOICE_PKG.log_message('Inside the loop of pa_bill_pct.GetPercentComplete:  ');
CLOSE pct;

           --PA_MCB_INVOICE_PKG.log_message(' Exiting pa_bill_pct.GetPercentComplete:  ');
RETURN percent_comp;

EXCEPTION
	WHEN OTHERS THEN
             CLOSE pct;
             RETURN 0;

END GetPercentComplete;

---------------------
--  GLOBALS
--

-- get_rev_budget_amount modified to use User defined budget types
-- and use api pa_budget_utils.get_project_task_totals
--
PROCEDURE get_rev_budget_amount( X2_project_id       NUMBER,
			 X2_task_id              NUMBER DEFAULT NULL,
			 X2_revenue_amount       OUT NOCOPY REAL,
                         P_rev_budget_type_code  IN VARCHAR2 DEFAULT NULL,
                         P_rev_plan_type_id      IN NUMBER DEFAULT NULL, /* Added for Fin plan impact */
                         X_rev_budget_type_code  OUT NOCOPY VARCHAR2,
                         X_rev_plan_type_id      OUT NOCOPY NUMBER, /* Added for Fin plan impact */
			 X_error_message	 OUT NOCOPY VARCHAR2,
			 X_status		 OUT NOCOPY NUMBER
			 ) IS

-- local variables for budget codes
status			VARCHAR2(240);     -- For error messages from subprogs
l_rev_budget_type_code  VARCHAR2(30) ;
l_rev_budget_status_code  VARCHAR2(1) ;
dummy                     CHAR(1);
err_msg			  VARCHAR2(240);
err_status                NUMBER;
l_status                 NUMBER;
l_rev_budget_version_id       NUMBER;
l_raw_cost_total              REAL := 0;
l_revenue_total               REAL := 0;
l_quantity_total              NUMBER;
l_burdened_cost_total         NUMBER;
l_err_code                    NUMBER;
l_err_stage                   VARCHAR2(30);
l_err_stack                   VARCHAR2(630);
invalid_rev_budget_code  EXCEPTION;
rev_budget_not_baselined EXCEPTION;

/* Added for Fin plan impact */
l_rev_plan_version_id       NUMBER;
l_rev_plan_type_id          NUMBER ;
/* till here */

BEGIN
          IF g1_debug_mode  = 'Y' THEN
          	PA_MCB_INVOICE_PKG.log_message(' Entering pa_bill_pct.get_rev_budget_amount:  ');
          END IF;
   X_status := 0;
   X_error_message := NULL;
   BEGIN
-- If user doesnt provide the budget get the default value from biling extensions
--

   IF ( P_rev_budget_type_code IS NULL) OR (P_rev_plan_type_id IS NULL) THEN

      SELECT  DECODE(P_rev_budget_type_code,NULL,default_rev_budget_type_code,P_rev_budget_type_code),
              DECODE(P_rev_plan_type_id,NULL,default_rev_plan_type_id,
                   P_rev_plan_type_id) /* Added for fin plan type id */
      INTO    l_rev_budget_type_code,
              l_rev_plan_type_id
      FROM     pa_billing_extensions
      WHERE    billing_extension_id=pa_billing.GetBillingExtensionId;

          IF g1_debug_mode  = 'Y' THEN
          	PA_MCB_INVOICE_PKG.log_message(' getting l_rev_budget_type_code inside pa_bill_pct.get_rev_budget_amount:  '||l_rev_budget_type_code);
          END IF;
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

  END; /* End of newly added code for Fin plan Impact */


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
    -- get the budget version id for cost and revenue budget
    -- Changed to use api pa_budget_utils.get_project_task_totals

   BEGIN

     SELECT budget_version_id
     INTO   l_rev_budget_version_id
     FROM   pa_budget_versions pbv
     WHERE  project_id = X2_project_id
     AND    budget_type_code = l_rev_budget_type_code
     AND    budget_status_code = 'B'
     AND    current_flag = 'Y';

          IF g1_debug_mode  = 'Y' THEN
          	PA_MCB_INVOICE_PKG.log_message(' getting l_rev_budget_version_id inside pa_bill_pct.get_rev_budget_amount:  '||l_rev_budget_version_id);
          END IF;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
         raise rev_budget_not_baselined;
   END;

  END; /* End of newly added code for Fin plan Impact */

   l_rev_budget_version_id  := NVL(l_rev_plan_version_id,l_rev_budget_version_id);


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

          IF g1_debug_mode  = 'Y' THEN
          	PA_MCB_INVOICE_PKG.log_message(' getting l_revenue_total inside pa_bill_pct.get_rev_budget_amount:  '||to_char(l_revenue_total));
          END IF;
X_rev_budget_type_code  := l_rev_budget_type_code;
X_rev_plan_type_id      := l_rev_plan_type_id; /* Added for Fin plan impact */

-- If any exception then raise it to the calling pl/sql block
--
          IF g1_debug_mode  = 'Y' THEN
          	PA_MCB_INVOICE_PKG.log_message(' Exiting pa_bill_pct.get_rev_budget_amount:  ');
          END IF;
   EXCEPTION
     WHEN invalid_rev_budget_code  THEN
  	 status := pa_billing_values.get_message('INVALID_REV_BUDGET_TYPE');
	 l_status := 2;
	 RAISE_APPLICATION_ERROR(-20101,status);
     WHEN rev_budget_not_baselined  THEN
         status := pa_billing_values.get_message('REV_BUDGET_NOT_BASELINED');
	 l_status := 3;
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
	X2_revenue_amount := NULL;
	X_rev_budget_type_code  := NULL;
----
        X_rev_plan_type_id := NULL;

        X_error_message := status;
	X_status	:= l_status;

	pa_billing_pub.insert_message
        (X_inserting_procedure_name =>'pa_billing_pct.get_rev_budget_amount',
	 X_attribute2 => l_rev_budget_type_code,
	 X_message => status,
         X_error_message=>err_msg,
         X_status=>err_status);

	 IF (l_status < 0 OR NVL(err_status,0) <0) THEN
	 RAISE;
	 END IF;

END get_rev_budget_amount;
END pa_bill_pct;

/
