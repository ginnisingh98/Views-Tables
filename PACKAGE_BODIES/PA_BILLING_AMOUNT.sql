--------------------------------------------------------
--  DDL for Package Body PA_BILLING_AMOUNT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_BILLING_AMOUNT" AS
/* $Header: PAXIAMTB.pls 120.6.12010000.3 2008/08/11 04:18:10 arbandyo ship $ */

--------------------------------------
-- FUNCTION/PROCEDURE IMPLEMENTATIONS
--

g1_debug_mode varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

Procedure CostAmount( 	X2_project_id 	NUMBER,
		     	X2_task_id	NUMBER DEFAULT NULL,
			X2_accrue_through_date DATE DEFAULT NULL,
			X2_cost_amount  OUT NOCOPY REAL) IS --File.Sql.39 bug 4440895

new_cost 	REAL := 0;
l_calling_process  varchar2(15);

BEGIN
      IF g1_debug_mode  = 'Y' THEN
      	PA_MCB_INVOICE_PKG.log_message('Entering pa_billing_amount.CostAmount  :');
      END IF;

  l_calling_process := pa_billing.GetCallProcess; /*Added for bug 7299493*/

/* commented for bug 4251205 */
/*	SELECT	nvl(sum(nvl(a.burdened_cost,0)),0)
	INTO	new_cost
	FROM  	pa_proj_ccrev_cost_v a
	WHERE 	a.project_id = X2_project_id
	AND   	a.task_id= nvl(X2_task_id,a.task_id)
	AND   	TRUNC(nvl(X2_accrue_through_date,sysdate)) >= trunc(a.pa_start_date);/* BUG#3118592 */

/* Split select into two parts for bug 4251205 */

/* Commented for bug 4860032 Forward port of bug 4646775 */

/*IF X2_task_id is NULL THEN
	SELECT	nvl(sum(nvl(a.burdened_cost,0)),0)
	INTO	new_cost
	FROM  	pa_proj_ccrev_cost_v a
	WHERE 	a.project_id = X2_project_id
	AND   	TRUNC(nvl(X2_accrue_through_date,sysdate)) >= trunc(a.pa_start_date);

	ELSE

	SELECT	nvl(sum(nvl(a.burdened_cost,0)),0)
	INTO	new_cost
	FROM  	pa_proj_ccrev_cost_v a
	WHERE 	a.project_id = X2_project_id
	AND   	a.task_id= X2_task_id
	AND   	TRUNC(nvl(X2_accrue_through_date,sysdate)) >= trunc(a.pa_start_date);

	END IF;
End of Commenting for Bug 4860032 */

--Inserted for Bug 4860032 ( Forward port 4646775 )

IF X2_task_id is NULL THEN
        select sum(BURDENED_COST)
        INTO    new_cost
        from (
        SELECT  sum(nvl(ta.tot_burdened_cost, nvl(ta.tot_raw_cost,0)) +
                                              nvl(ta.i_tot_burdened_cost, nvl(i_tot_raw_cost,0))) BURDENED_COST
        FROM
                pa_txn_accum  ta
        WHERE   ta.project_id = X2_project_id
        AND EXISTS
        (
        select 1
        from pa_periods pp
        where nvl(X2_accrue_through_date,sysdate) >= trunc(pp.start_date)  --Removed to_date
        and pp.period_name = ta.pa_period
        )
        AND EXISTS (select 1 from pa_tasks t
              where t.task_id = ta.task_id
              and exists (select 1 from pa_tasks t1
                          where t1.task_id = t.top_task_id
                          and decode(l_calling_process,'Revenue',t1.ready_to_distribute_flag,
                                                       'Invoice',t1.ready_to_bill_flag,0) = 'Y')
                   ) /* Exists clause added for bug 7299493 */

        UNION ALL
        SELECT  sum(nvl((cdl.burdened_cost + nvl(project_burdened_change,0)), nvl(cdl.amount,0))) BURDENED_COST
        FROM    pa_cost_distribution_lines_all  cdl
        WHERE   cdl.resource_accumulated_flag = 'N'
        AND     cdl.line_type = 'R'
        AND     cdl.project_id = X2_project_id
        AND EXISTS
        (
        select 1
        from pa_periods pp
        where nvl(X2_accrue_through_date,sysdate) >= trunc(pp.start_date)  --Removed to_date
        and cdl.pa_date between pp.start_date and pp.end_date
        )
        AND EXISTS (select 1 from pa_tasks t
              where t.task_id = cdl.task_id
              and exists (select 1 from pa_tasks t1
                          where t1.task_id = t.top_task_id
                          and decode(l_calling_process,'Revenue',t1.ready_to_distribute_flag,
                                                       'Invoice',t1.ready_to_bill_flag,0) = 'Y')
              ) /* Exists clause added for bug 7299493 */
        );

ELSE

        select sum(BURDENED_COST)
        INTO    new_cost
        from (

        SELECT  sum(nvl(ta.tot_burdened_cost, nvl(ta.tot_raw_cost,0)) +
                                              nvl(ta.i_tot_burdened_cost, nvl(i_tot_raw_cost,0))) BURDENED_COST
        FROM
                pa_txn_accum  ta,
                pa_tasks  t
        WHERE   ta.task_id = t.task_id
        AND     t.top_task_id = X2_task_id
        AND     t.project_id = X2_project_id
        AND     ta.project_id = X2_project_id
        AND     ta.project_id = t.project_id
        and exists (select 1 from pa_tasks t1
              where t1.task_id = t.top_task_id
              and decode(l_calling_process,'Revenue',t1.ready_to_distribute_flag,
                                           'Invoice',t1.ready_to_bill_flag,0) = 'Y')   /* Exists clause added for bug 7299493 */

        AND EXISTS
        (
         select 1
         from pa_periods pp
         where nvl(X2_accrue_through_date,sysdate) >= trunc(pp.start_date)  --Removed to_date
         and pp.period_name = ta.pa_period
        )
	UNION ALL
        SELECT  sum(nvl((cdl.burdened_cost + nvl(project_burdened_change,0)), nvl(cdl.amount,0))) BURDENED_COST
        FROM    pa_cost_distribution_lines_all  cdl  /* Added _all for bug 5953670*/
                /*pa_tasks  commented for bug 6521198*/
        WHERE  EXISTS (	select 1 from pa_tasks t
                	     WHERE cdl.project_id = t.project_id
                       AND     cdl.task_id = t.task_id
                       AND     t.project_id = X2_project_id
                       AND     t.top_task_id = X2_task_id
                       and exists (select 1 from pa_tasks t1
                                   where t1.task_id = t.top_task_id
                                     and decode(l_calling_process,'Revenue',t1.ready_to_distribute_flag,
                                               'Invoice',t1.ready_to_bill_flag,0) = 'Y')   /* Exists clause added for bug 7294641 */
                       )
        AND     cdl.resource_accumulated_flag = 'N'
        AND     cdl.line_type = 'R'
        AND     cdl.project_id = X2_project_id
        AND EXISTS
        (
        select 1
        from pa_periods pp
        where nvl(X2_accrue_through_date,sysdate) >= trunc(pp.start_date)  --Removed to_date
        AND     cdl.pa_date between pp.start_date and pp.end_date
        )
        );

END IF;

--End of Inserting for bug 4860032


X2_cost_amount :=  nvl(new_cost,0);

      IF g1_debug_mode  = 'Y' THEN
      	PA_MCB_INVOICE_PKG.log_message('Exiting pa_billing_amount.CostAmount  :');
      END IF;
END CostAmount;




Procedure RevenueAmount(  	X2_project_id NUMBER,
	 			X2_task_Id   NUMBER DEFAULT NULL,
				X2_revenue_amount OUT NOCOPY REAL) IS --File.Sql.39 bug 4440895

pending_ccrev	REAL;
accrued_ccrev	REAL;
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

CURSOR func_revenue(X2_project_id Number,X2_task_id Number) IS
	SELECT 	NVL(e.bill_trans_rev_amount,0) trans_rev_amount,e.bill_trans_currency_code,
                e.projfunc_currency_code,e.projfunc_rate_type,e.projfunc_rate_date,e.projfunc_exchange_rate
	FROM 	pa_events e,
		pa_billing_assignments bea,
		pa_billing_extensions be
	where	be.billing_extension_id = bea.billing_extension_id
	and	e.project_id = X2_project_id
	and    	nvl(e.task_id,0) = decode(X2_task_id,NULL,nvl(e.task_id,0), X2_task_id )
	and	bea.billing_assignment_id = e.billing_assignment_id
	and	be.procedure_name = 'pa_billing.ccrev'
	and	e.revenue_distributed_flag||'' = 'N';

   l_projfunc_convers_fail       EXCEPTION;
BEGIN
IF g1_debug_mode  = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('Entering pa_billing_amount.RevenueAmount :');
END IF;

-- Cost-Cost Revenue that has been accrued.
SELECT sum(nvl(dri.projfunc_revenue_amount,0)) /* change this column from amount to projfunc_revenue_amount for MCB2 */
INTO   accrued_ccrev
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
			and	be.procedure_name = 'pa_billing.ccrev')
       OR dri.revenue_source like 'Expenditure%');

IF g1_debug_mode  = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('Number 01 RevenueAmount.accrued_ccrev :'||TO_CHAR(accrued_ccrev));
END IF;
-- Cost-Cost revenue that has not been created as events but not accrued yet.
-- This could be due to unauthorized task or an erroring request.
/* The following code is commented because this amount is in RPC i.e. Revenue programm is going to populate this amount
*/
/*	SELECT 	sum(nvl(e.revenue_amount,0))
	INTO	pending_ccrev
	FROM 	pa_events e,
		pa_billing_assignments bea,
		pa_billing_extensions be
	where	be.billing_extension_id = bea.billing_extension_id
	and	e.project_id = X2_project_id
	and    	nvl(e.task_id,0) =
			decode(X2_task_id,
				NULL, 	nvl(e.task_id,0), X2_task_id )
	and	bea.billing_assignment_id = e.billing_assignment_id
	and	be.procedure_name = 'pa_billing.ccrev'
	and	e.revenue_distributed_flag||'' = 'N';   */

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

       OPEN func_revenue( X2_project_id,X2_task_id);
        Loop
          FETCH func_revenue INTO l_trans_rev_amt,l_txn_currency_code,l_projfunc_currency_code,
                          l_projfunc_rate_type,l_projfunc_rate_date,l_projfunc_exchange_rate;
          EXIT WHEN func_revenue%NOTFOUND;
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
 IF g1_debug_mode  = 'Y' THEN
 	PA_MCB_INVOICE_PKG.log_message('Number 02 RevenueAmount.pending_ccrev :'||to_char(l_projfunc_rev_amount_sum));
 END IF;
        End Loop;
       Close func_revenue;
       pending_ccrev := l_projfunc_rev_amount_sum;
       X2_revenue_amount := nvl(accrued_ccrev,0) + nvl(pending_ccrev,0);
      IF g1_debug_mode  = 'Y' THEN
      	PA_MCB_INVOICE_PKG.log_message('Exiting pa_billing_amount.RevenueAmount  :');
      END IF;
END RevenueAmount;


Procedure PotEventAmount( 	X2_project_id 	NUMBER,
				X2_task_id 	NUMBER DEFAULT NULL,
				X2_accrue_through_date DATE DEFAULT NULL,
				X2_revenue_amount OUT NOCOPY REAL, --File.Sql.39 bug 4440895
				X2_invoice_amount OUT NOCOPY REAL )  --File.Sql.39 bug 4440895
IS
/* Varibles added for MCB2 */
l_trans_rev_amt                   pa_events.bill_trans_rev_amount%TYPE;
l_trans_bill_amt                  pa_events.bill_trans_bill_amount%TYPE;
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

l_projfunc_convers_fail       EXCEPTION;

--  added the RLZD_LOSSES event type classification

CURSOR func_rev_inv_amt(X2_project_id Number,X2_task_id Number,X2_accrue_through_date Date) IS
       SELECT (DECODE(et.event_type_classification,
		 'WRITE OFF',-1 * NVL(e.bill_trans_rev_amount,0),
		 'RLZED_LOSSES',-1 * NVL(e.bill_trans_rev_amount,0),
             NVL(e.bill_trans_rev_amount,0))) trans_rev_amount,
            (DECODE(et.event_type_classification,'INVOICE REDUCTION', -1 * NVL(e.bill_trans_bill_amount,0),
            NVL(e.bill_trans_bill_amount,0))) trans_bill_amount,
           e.bill_trans_currency_code,e.projfunc_currency_code,e.projfunc_rate_type,
           e.projfunc_rate_date,e.projfunc_exchange_rate
FROM	pa_events e,
	pa_event_types et
WHERE	e.event_type = et.event_type
AND	e.project_id = X2_project_id
AND	nvl(e.task_id,0) = nvl(X2_task_id, nvl(e.task_id,0))
AND	e.completion_date <= nvl(X2_accrue_through_date, sysdate)
AND	NOT EXISTS (	select 'cost-cost event'
		    	from	pa_billing_assignments bea,
				pa_billing_extensions be
			where	be.billing_extension_id = bea.billing_extension_id
			and	bea.billing_assignment_id = e.billing_assignment_id
			and	be.procedure_name = 'pa_billing.ccrev');

BEGIN
IF g1_debug_mode  = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('PotEventAmount: ' || 'Entering pa_billing_amount.PotEvent :');
END IF;
/* The following sql has been commented for MCB2 */
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
AND	NOT EXISTS (	select 'cost-cost event'
		    	from	pa_billing_assignments bea,
				pa_billing_extensions be
			where	be.billing_extension_id = bea.billing_extension_id
			and	bea.billing_assignment_id = e.billing_assignment_id
			and	be.procedure_name = 'pa_billing.ccrev'); */

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
       OPEN func_rev_inv_amt( X2_project_id,X2_task_id,X2_accrue_through_date);
        Loop
          FETCH func_rev_inv_amt
          INTO l_trans_rev_amt,l_trans_bill_amt,l_txn_currency_code,l_projfunc_currency_code,
                          l_projfunc_rate_type,l_projfunc_rate_date,l_projfunc_exchange_rate;
          EXIT WHEN func_rev_inv_amt%NOTFOUND;
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
      	PA_MCB_INVOICE_PKG.log_message('PotEventAmount: ' || 'Number 01 pa_billing_amount.PotEvent.l_projfunc_amount_sum :'||to_char(l_projfunc_amount_sum));
      END IF;
        End Loop;
       Close func_rev_inv_amt;

       IF ( l_calling_process = 'Revenue' ) THEN
         X2_revenue_amount := l_projfunc_amount_sum;
         X2_invoice_amount := 0;
       ELSIF ( l_calling_process = 'Invoice' ) THEN
            X2_revenue_amount := 0;
            X2_invoice_amount := l_projfunc_amount_sum;
       END IF;
      IF g1_debug_mode  = 'Y' THEN
      	PA_MCB_INVOICE_PKG.log_message('PotEventAmount: ' || 'Exiting pa_billing_amount.PotEvent :');
      END IF;
END PotEventAmount;



Procedure InvoiceAmount(	X2_project_id	NUMBER,
				X2_task_id	NUMBER default NULL,
				X2_invoice_amount OUT NOCOPY REAL) IS --File.Sql.39 bug 4440895

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

l_projfunc_convers_fail       EXCEPTION;

CURSOR func_invoice(X2_project_id Number,X2_task_id Number) IS
    SELECT NVL(e.bill_trans_bill_amount,0) trans_bill_amount,e.bill_trans_currency_code,
           e.projfunc_currency_code,
           e.projfunc_rate_type,e.projfunc_rate_date,e.projfunc_exchange_rate
    FROM    pa_events e,
	    pa_billing_assignments bea,
	    pa_billing_extensions be
    WHERE	be.billing_extension_id = bea.billing_extension_id
    AND	bea.billing_assignment_id = e.billing_assignment_id
    AND	e.project_id = X2_project_id
    AND	be.procedure_name = 'pa_billing.ccrev'
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
	PA_MCB_INVOICE_PKG.log_message('Entering pa_billing_amount.InvoiceAmount :');
END IF;

-- Cost/Cost Invoice Amount that has been created as an event, but not billed
-- yet.
/* The following code is commented because this amount is in IPC i.e.
   Invoice programm is going to populate this amount
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
and	be.procedure_name = 'pa_billing.ccrev'
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

       OPEN func_invoice( X2_project_id,X2_task_id);
        Loop
          FETCH func_invoice INTO l_trans_bill_amt,l_txn_currency_code,l_projfunc_currency_code,
                          l_projfunc_rate_type,l_projfunc_rate_date,l_projfunc_exchange_rate;
          EXIT WHEN func_invoice%NOTFOUND;
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
      IF g1_debug_mode  = 'Y' THEN
      	PA_MCB_INVOICE_PKG.log_message('inside pa_billing_amount.InvoiceAmount :'||l_projfunc_bill_amount_sum);
      END IF;
        End Loop;
       Close func_invoice;
       pending_ccinv := l_projfunc_bill_amount_sum;


IF (X2_task_id IS NULL) THEN

  -- Cost-Cost Invoice Amount that has been billed, or originates from
  -- expenditure items (historical cost-cost invoice amount)

/* change this column from amount to projfunc_bill_amount for MCB2 */
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
			and	be.procedure_name = 'pa_billing.ccrev')
          OR EXISTS (	select 	'1'
		   	from 	pa_cust_rev_dist_lines erdl
			where 	erdl.project_id = dii.project_id
			and	erdl.draft_invoice_num = dii.draft_invoice_num
			and	erdl.draft_invoice_item_line_num = dii.line_num));




	X2_invoice_amount := nvl(pending_ccinv,0) + nvl(billed_ccinv,0);

ELSE

/* Change this column from amount to projfunc_bill_amount for MCB2 */
  SELECT sum(nvl(rdl.projfunc_bill_amount,0))
  INTO	task_billed_ccinv
  FROM	pa_cust_rev_dist_lines rdl,
	pa_expenditure_items_all ei,
	pa_tasks t
  WHERE	ei.task_id = t.task_id
  AND	ei.expenditure_item_id = rdl.expenditure_item_id
  AND	rdl.project_id = X2_project_id
  AND	t.top_task_id = X2_task_id
  AND	rdl.draft_invoice_num IS NOT NULL;

/* Change this column from amount to projfunc_bill_amount for MCB2 */
  SELECT sum(nvl(pdii.projfunc_bill_amount,0))
  INTO   task_billed_ev_ccinv
  FROM   pa_draft_invoice_items pdii
  WHERE  pdii.event_task_id = X2_task_id
  AND    pdii.Project_ID = X2_Project_ID    --  Perf Bug 2695243
  AND    EXISTS (select '1'
			from 	pa_events e,
				pa_billing_assignments bea,
				pa_billing_extensions be
			where	be.billing_extension_id = bea.billing_extension_id
			and	bea.billing_assignment_id = e.billing_assignment_id
			and	pdii.project_id = e.project_id
			and	pdii.event_num = e.event_num
			and	pdii.event_task_id = e.task_id
			and	be.procedure_name = 'pa_billing.ccrev');

  X2_invoice_amount := nvl(task_billed_ccinv,0) + nvl(task_billed_ev_ccinv,0)				+ nvl(pending_ccinv,0);

IF g1_debug_mode  = 'Y' THEN
        PA_MCB_INVOICE_PKG.log_message('Overall invoice amount pa_billing_amount.InvoiceAmount :'||to_char(nvl(task_billed_ccinv,0) + nvl(task_billed_ev_ccinv,0) + nvl(pending_ccinv,0)));
	PA_MCB_INVOICE_PKG.log_message('Exiting pa_billing_amount.InvoiceAmount :');
END IF;
END IF;

END InvoiceAmount;



FUNCTION LowestAmountLeft (	X2_project_id NUMBER,
				X2_task_id NUMBER,
				X2_calling_process VARCHAR2)
	RETURN REAL IS

lowest_revenue_amount	REAL := 0;
lowest_invoice_amount 	REAL := 0;
current_event_revenue	REAL := 0;
current_event_invoice	REAL := 0;

l_trans_rev_amt                pa_events.bill_trans_rev_amount%TYPE;
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

l_projfunc_convers_fail       EXCEPTION;

l_Enable_Top_Task_Cust_Flag  VARCHAR2(1);

CURSOR func_lwst_rev_inv_amt(X2_project_id Number,X2_task_id Number) IS
 SELECT DECODE(e.revenue_distributed_flag,'N', NVL(e.bill_trans_rev_amount,0),0) trans_rev_amount,
        DECODE(pdii.event_num,NULL, NVL(e.bill_trans_bill_amount,0),0) trans_bill_amount,
        e.bill_trans_currency_code,
        e.projfunc_currency_code,e.projfunc_rate_type,e.projfunc_rate_date,e.projfunc_exchange_rate
 FROM	pa_events e, pa_event_types et, pa_draft_invoice_items pdii
 WHERE	e.project_id = X2_project_id
 AND	pdii.project_id (+)= e.project_id
 AND	pdii.event_num (+)= e.event_num
 AND	nvl(pdii.event_task_id,0) = nvl(e.task_id,0)
 AND	nvl(e.task_id,0) = nvl(X2_task_id,0)
 AND	e.event_type = et.event_type
 AND	et.event_type_classification||'' = 'AUTOMATIC';

BEGIN

IF g1_debug_mode  = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('Entering pa_billing_amount.LowestAmountLeft :');
END IF;
-- This select gets automatic events that were created in this run or some
-- previous run, but have not been accrued/billed yet.
-- This must be subtracted from amount available to get the real amount
-- available.
/* The following sql has been commented for MCB2 */
/*
SELECT 	sum(decode(e.revenue_distributed_flag,
		'N', nvl(e.revenue_amount,0),
			0)),
	sum(decode(pdii.event_num,
		NULL, nvl(e.bill_amount,0),
			0))
INTO	current_event_revenue, current_event_invoice
FROM	pa_events e, pa_event_types et, pa_draft_invoice_items pdii
WHERE	e.project_id = X2_project_id
AND	pdii.project_id (+)= e.project_id
and	pdii.event_num (+)= e.event_num
and	nvl(pdii.event_task_id,0) = nvl(e.task_id,0)
AND	nvl(e.task_id,0) = nvl(X2_task_id,0)
and	e.event_type = et.event_type
and	et.event_type_classification||'' = 'AUTOMATIC';
*/

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
       OPEN func_lwst_rev_inv_amt( X2_project_id,X2_task_id);
        Loop
          FETCH func_lwst_rev_inv_amt
          INTO l_trans_rev_amt,l_trans_bill_amt,l_txn_currency_code,l_projfunc_currency_code,
                          l_projfunc_rate_type,l_projfunc_rate_date,l_projfunc_exchange_rate;
          EXIT WHEN func_lwst_rev_inv_amt%NOTFOUND;
          IF ( X2_calling_process = 'Revenue' ) THEN
            l_projfunc_rate_date := NVL(l_projfunc_rate_date,pa_billing.GetPaDate);
            l_passd_amt := l_trans_rev_amt;
          ELSIF ( X2_calling_process = 'Invoice' ) THEN
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
      	PA_MCB_INVOICE_PKG.log_message('LowestAmountLeft: ' || 'Inside pa_billing_amount.LowestAmount :'||l_projfunc_amount_sum);
      END IF;
        End Loop;
       Close func_lwst_rev_inv_amt;

       IF ( X2_calling_process = 'Revenue' ) THEN
         current_event_revenue := l_projfunc_amount_sum;
         current_event_invoice := 0;
       ELSIF ( X2_calling_process = 'Invoice' ) THEN
            current_event_revenue := 0;
            current_event_invoice := l_projfunc_amount_sum;
       END IF;
/* DBMS_OUTPUT.PUT('current_event_revenue='); */
/* DBMS_OUTPUT.PUT(current_event_revenue); */
/* DBMS_OUTPUT.PUT('current_event_invoice='); */
/* DBMS_OUTPUT.PUT(current_event_invoice); */
/** Bug # 505759 , changed the select to use (100/pc.customer_bill_split)
    rather than (pc.customer_bill_split * .01)
    **/

/* MCB2: Change the name  from total_accrued_amount to projfunc_accrued_amount,
         total_billed_amount to projfunc_billed_amount, and total_baselined_amount to
         projfunc_baselined_amount  */

-- Following changes are made for FP_M : Top Task customer changes
l_Enable_Top_Task_Cust_Flag := PA_Billing_Pub.Get_Top_Task_Customer_Flag (
                                        P_Project_ID => l_Project_ID );

-- If the project is implemented with Top Task customer enabled then the
-- lowest revenue amount is calculated as the total baselined fundings
-- less the total accrued amounts.
-- Similarly the lowest invoice amount is calculated as the total baselined
-- fundings less the total billed amount.
--
If l_Enable_Top_Task_Cust_Flag = 'Y' then
   SELECT  sum(nvl(psf.projfunc_baselined_amount,0)
               - nvl(psf.projfunc_accrued_amount,0)),
	   sum(nvl(psf.projfunc_baselined_amount,0)
	       - nvl(psf.projfunc_billed_amount,0))
   INTO    lowest_revenue_amount,
	   lowest_invoice_amount
   FROM    pa_summary_project_fundings psf,
	   pa_agreements_all a
   WHERE   a.agreement_id = psf.agreement_id
   AND     psf.project_id = X2_project_id
   AND     psf.task_id = X2_task_id
   AND     DECODE (X2_calling_process,'Revenue',
                   a.revenue_limit_flag||'','Invoice',
		  a.invoice_limit_flag||'') = 'Y' ;
Else
   SELECT  min(sum(nvl(psf.projfunc_baselined_amount,0)
	       - nvl(psf.projfunc_accrued_amount,0))
		   * (100/nvl(pc.customer_bill_split,100)) ), /*Bug 5718115*/
	   min(sum(nvl(psf.projfunc_baselined_amount,0)
	       - nvl(psf.projfunc_billed_amount,0))
		   * (100/nvl(pc.customer_bill_split,100)) ) /* Bug 5718115*/
   INTO	lowest_revenue_amount,
	lowest_invoice_amount
   FROM	pa_summary_project_fundings psf,
	pa_agreements_all a, /* Changed table from pa_agreements to pa_agreements_all for MCB2 */
	pa_projects p,
	pa_project_customers pc
   WHERE
	a.agreement_id = psf.agreement_id
   AND	p.project_id = psf.project_id
   AND	a.customer_id = pc.customer_id
   AND	pc.project_id = p.project_id
   AND	nvl(psf.task_id,0) = nvl(X2_task_id,0)
   AND	psf.project_id = X2_project_id
   AND	DECODE (X2_calling_process,'Revenue',a.revenue_limit_flag||'','Invoice',a.invoice_limit_flag||'') = 'Y'
   GROUP BY pc.customer_id, pc.customer_bill_split;
/* Change the above condition (X2_calling_process one ) and added decode to get only revenue or only invoice amounts for MCB2 */
END IF ;
-- End of FP_M changes

      IF g1_debug_mode  = 'Y' THEN
      	PA_MCB_INVOICE_PKG.log_message('LowestAmountLeft: ' || 'Entering .LowestAmount 1 :'||lowest_revenue_amount);
      	PA_MCB_INVOICE_PKG.log_message('LowestAmountLeft: ' || 'Entering .LowestAmount 2 :'||lowest_invoice_amount);
      END IF;


IF (X2_calling_process = 'Revenue') THEN
	return greatest((nvl(lowest_revenue_amount,999999999999)
		- nvl(current_event_revenue,0)),0);
ELSE
	return greatest((nvl(lowest_invoice_amount,999999999999)
		- nvl(current_event_invoice,0)),0);
END IF;

      IF g1_debug_mode  = 'Y' THEN
      	PA_MCB_INVOICE_PKG.log_message('LowestAmountLeft: ' || 'Exiting pa_billing_amount.LowestAmount :');
      END IF;
EXCEPTION
  WHEN OTHERS THEN
  /* DBMS_OUTPUT.PUT_LINE(SQLERRM); */
  RAISE;
END LowestAmountLeft;


FUNCTION rdl_amount(X_which VARCHAR2, X_eiid NUMBER, X_adj VARCHAR2, X_ei_adj VARCHAR2)
	return REAL IS

	Ramount REAL;
BEGIN
      IF g1_debug_mode  = 'Y' THEN
      	PA_MCB_INVOICE_PKG.log_message('Entering pa_billing_amount.rdl_amount :');
      END IF;
/* Changed column from bill_amount to projfunc_bill_amount  and amount to projfunc_revenue_amount for MCB2  */
	SELECT sum(decode(X_which, 	'I', nvl(rdl.projfunc_bill_amount,0),
		      	'R', NVL(rdl.projfunc_revenue_amount,0),NVL(rdl.projfunc_revenue_amount,0)))
	INTO	Ramount
	FROM	pa_cust_rev_dist_lines rdl
	WHERE	rdl.expenditure_item_id = X_eiid
	AND	(X_adj = 'ADJ'
		        AND (rdl.line_num_reversed IS NOT NULL
			     OR X_ei_adj = 'Y')
		OR  (X_adj = 'REG'
		     	AND 	(rdl.line_num_reversed IS NULL
				and	rdl.reversed_flag IS NULL
				and X_ei_adj = 'N')));

                -- Explanation for last two statements above:
                -- 1. If we wants adjustment items only, only rdl's with
                -- NOT NULL line_num_reversed will be returned, or rdl's
		-- belonging to reversin ei's.
                -- If we want regular items only, only rdl's with a NULL
                -- line_num_reversed will be returned. These rdl's MUST NOT
		-- belong to a reversing ei.
                -- If want both, all rdl's will be returned.
		-- 2. Exclude items which have been reversed out, if
                -- only positive items requested.

      IF g1_debug_mode  = 'Y' THEN
      	PA_MCB_INVOICE_PKG.log_message('Exiting pa_billing_amount.rdl_amount :');
      END IF;

	RETURN Ramount;
END rdl_amount;


PROCEDURE get_baseline_budget
 ( X_project_id   in  NUMBER,
   X_rev_budget  out  NOCOPY REAL, --File.Sql.39 bug 4440895
   X_cost_budget out  NOCOPY REAL , --File.Sql.39 bug 4440895
   X_err_msg     out  NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
as
l_cost_budget_version_id        pa_budget_versions.budget_version_id%type;
l_rev_budget_version_id         pa_budget_versions.budget_version_id%type;
l_quantity_total                Real;
l_raw_cost_total                Real;
l_burdened_cost_total           Real;
l_err_code                      Number;
l_revenue_total                 Real;
l_err_stage                     VARCHAR2(30);
l_err_stack                     VARCHAR2(630);
l_dummy                         VARCHAR2(1);
c                               Number;
cost_budget_exception           exception;
rev_budget_exception            exception;


BEGIN
      IF g1_debug_mode  = 'Y' THEN
      	PA_MCB_INVOICE_PKG.log_message('Entering pa_billing_amount.get_baseline_budget :');
      END IF;
    c := 5;

    SELECT  Decode(SUBSTR(distribution_rule,INSTR(distribution_rule,'/')+1),'COST','x','y')     /* Added Decode for Bug 2389765 */
    INTO   l_dummy
    FROM   pa_projects_all
    WHERE  project_id        = X_project_id
    AND    substr(distribution_rule,1,instr(distribution_rule,'/')-1)
           IN  ('COST','EVENT')
    AND    exists ( select 'x'
                    from   pa_events e,
                           pa_event_types et
                    where  e.project_id  = X_project_id
                    and    e.event_type  = et.event_type
                    and    et.event_type_classification = 'SCHEDULED PAYMENTS');
   /* Bug 2389765  . Cost Budget is needed only when the Distribution Rule is
                     'COST/COST'. Hence the following if condition is added
                     to make sure cost budget details are required only for
                     Distribution rule 'COST/COST' */

    If (l_dummy='x') then

    /* Added for Fin plan impact */
    BEGIN
      SELECT v.budget_version_id
      INTO   l_cost_budget_version_id
      FROM   pa_budget_versions v
      WHERE  v.project_id = X_project_id
      AND    v.current_flag = 'Y'
      AND    v.budget_status_code           = 'B'
      AND    v.version_type IN ('COST','ALL');

    EXCEPTION
      WHEN NO_DATA_FOUND THEN

      c := 10;
      SELECT budget_version_id
      INTO   l_cost_budget_version_id
      FROM   pa_budget_versions pbv
      WHERE  project_id = X_project_id
      AND    budget_type_code = 'AC'
      AND    budget_status_code = 'B'
      AND    current_flag = 'Y';

    END;

   end if;


    /* Added for Fin plan impact */
    BEGIN
      SELECT v.budget_version_id
      INTO   l_rev_budget_version_id
      FROM   pa_budget_versions v
      WHERE  v.project_id = X_project_id
      AND    v.current_flag = 'Y'
      AND    v.budget_status_code           = 'B'
      AND    v.version_type IN ('REVENUE','ALL')
      AND    v.approved_rev_plan_type_flag = 'Y' ; /* Added for bug 4059918 */

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
       c := 20;

       SELECT budget_version_id
       INTO   l_rev_budget_version_id
       FROM   pa_budget_versions pbv
       WHERE  project_id = X_project_id
       AND    budget_type_code = 'AR'
       AND    budget_status_code = 'B'
       AND    current_flag = 'Y';

    END;

     If (l_dummy='x') then     /* if added for Bug 2389765  */
       pa_budget_utils.get_project_task_totals
         (l_cost_budget_version_id ,
          NULL ,
          l_quantity_total,
          l_raw_cost_total ,
          l_burdened_cost_total ,
          l_revenue_total ,
          l_err_code ,
          l_err_stage,
          l_err_stack );

       If (l_burdened_cost_total is  null) or ( l_burdened_cost_total = 0)
       then
         raise cost_budget_exception;
       end if;

       X_cost_budget :=
             pa_currency.round_currency_amt(l_burdened_cost_total);
    end if;
    pa_budget_utils.get_project_task_totals
          (l_rev_budget_version_id ,
           NULL ,
           l_quantity_total,
           l_raw_cost_total ,
           l_burdened_cost_total ,
           l_revenue_total ,
           l_err_code ,
           l_err_stage,
           l_err_stack );

    If (l_revenue_total is null) or ( L_revenue_total = 0)
    then
       raise rev_budget_exception;
    end if;

    X_rev_budget :=
              pa_currency.round_currency_amt(l_revenue_total);


      IF g1_debug_mode  = 'Y' THEN
      	PA_MCB_INVOICE_PKG.log_message('Exiting pa_billing_amount.get_baseline_budget :');
      END IF;
EXCEPTION
   When NO_DATA_FOUND
   then
        if  (c = 5)
        then
             X_rev_budget := NULL;
             X_cost_budget:= NULL;
             Return;
        elsif  ( c = 10)
        then
              X_err_msg := 'No Cost Budget Version Id';
        elsif ( c = 20 )
        then
              X_err_msg := 'No Revnue Budget Version Id';
        end if;

   When rev_budget_exception
   then
        X_rev_budget := 0;
        X_err_msg    := 'Exception Raised in Revenue Budget calculation';

   When cost_budget_exception
   then
        X_cost_budget := 0;
        X_err_msg     := 'Exception Raised in Cost Budget Calculation';

END get_baseline_budget;

END pa_billing_amount;

/
