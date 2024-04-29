--------------------------------------------------------
--  DDL for Package Body PA_BILLING_WORKBENCH_BILL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_BILLING_WORKBENCH_BILL_PKG" as
/* $Header: PAXBLWBB.pls 120.5.12010000.9 2009/02/27 15:07:30 rmandali ship $ */
-- This procedure will get all the parameters for Billing Region for the given project.
-- burdened cost and raw revenue on the basis of passed parameters
-- Input parameters
-- Parameters                      Type           Required      Description
-- p_project_id                   NUMBER           YES          The identifier of the project
-- p_project_currency             VARCHAR2         YES          Currency of the project
-- p_projfunc_currency            VARCHAR2         YES          Project functional currency
-- p_ubr                          NUMBER           YES          Total Unbilled receivables for the given project
-- p_uer                          NUMBER           YES          Total Unearned revenue for the given project
--
-- Out parameters
--
--
g1_debug_mode varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

/* Declaring global variable for invoice region VO */
 G_system_reference        NUMBER;
 G_ar_amount               NUMBER;

PROCEDURE Get_Billing_Sum_Region_Amts (
                                            p_project_id                  IN     NUMBER ,
                                            p_project_currency            IN     VARCHAR2 ,
                                            p_projfunc_currency           IN     VARCHAR2 ,
                                            p_ubr                         IN     NUMBER ,
                                            p_uer                         IN     NUMBER ,
                                            x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                            x_msg_count                   OUT    NOCOPY NUMBER  , --File.Sql.39 bug 4440895
                                            x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                      )
IS

  -- Local standard variables used to pass calculated values
  -- in project currency to the calling program

  l_proj_funding_amt               NUMBER ;
  l_proj_rev_accured               NUMBER ;
  l_proj_rev_backlog               NUMBER ;
  l_proj_rev_writeoff              NUMBER ;
  l_proj_ubr                       NUMBER ;
  l_proj_uer                       NUMBER ;
  l_proj_inv_invoiced              NUMBER ;
  l_proj_inv_backlog               NUMBER ;
  l_proj_billable_cost             NUMBER ;
  l_proj_unbilled_cost             NUMBER ;
  l_proj_unbilled_events           NUMBER ;
  l_proj_unbilled_retn             NUMBER ;
  l_proj_unapprov_inv_amt          NUMBER ;
  l_pc_count                       NUMBER;
  l_pc_ubr_applicab_flag           VARCHAR2(1) := 'Y';
  l_pc_uer_applicab_flag           VARCHAR2(1) := 'Y';
  l_pc_unbil_eve_applicab_flag     VARCHAR2(1);


  -- Local standard variables used to pass calculated values
  -- in project functional currency to the calling program

  l_projfunc_funding_amt           NUMBER ;
  l_projfunc_rev_accured           NUMBER ;
  l_projfunc_rev_backlog           NUMBER ;
  l_projfunc_rev_writeoff          NUMBER ;
  l_projfunc_ubr                   NUMBER ;
  l_projfunc_uer                   NUMBER ;
  l_projfunc_inv_invoiced          NUMBER ;
  l_projfunc_inv_backlog           NUMBER ;
  l_projfunc_billable_cost         NUMBER ;
  l_projfunc_unbilled_cost         NUMBER ;
  l_projfunc_unbilled_events       NUMBER ;
  l_projfunc_unbilled_retn         NUMBER ;
  l_projfunc_unapprov_inv_amt      NUMBER ;
  l_pfc_count                      NUMBER;
  l_pfc_unbil_eve_applicab_flag    VARCHAR2(1);


  -- Local variables used for internal calculation

  l_writeoff                       NUMBER ;
  l_revproc_writeoff               NUMBER ;
  l_pc_unbill_eve_amt_with_part    NUMBER ;
  l_pc_total_part_bill_amt         NUMBER ;
  l_pfc_unbill_eve_amt_with_part   NUMBER ;
  l_pfc_total_part_bill_amt        NUMBER ;
  l_project_id                     NUMBER ;
  l_pfc_invoiced                   NUMBER ;
  l_pc_invoiced                    NUMBER ;
  l_multi_customer_flag            VARCHAR2(1):= 'N';
  l_count                          NUMBER ;

  l_projfunc_inv_due_unaccepted   NUMBER ;
  l_proj_inv_due_unaccepted       NUMBER ;

  l_projfunc_inv_orig             NUMBER ;
  l_projfunc_inv_due             NUMBER ;
  l_projfunc_tax_orig            NUMBER ;
  l_projfunc_tax_due             NUMBER ;

  l_projfunc_inv_tot_due             NUMBER ;
  l_projfunc_inv_tot_paid            NUMBER ;

  l_proj_inv_orig             NUMBER ;
  l_proj_inv_due             NUMBER ;
  l_proj_tax_orig            NUMBER ;
  l_proj_tax_due             NUMBER ;

  l_proj_inv_tot_due             NUMBER ;
  l_proj_inv_tot_paid            NUMBER ;

  l_accepted_exist varchar2(1);

  l_next_invoice_date DATE;

  -- Local standard variables used to pass status and error,
  -- if occur, to the calling program

  l_return_status                  VARCHAR2(1);
  l_msg_count                      NUMBER  ;
  l_msg_data                       VARCHAR2(30);
l_ubr_uer_msg_data		VARCHAR2(30);
BEGIN

    -- Initilizing status variable with success status
    l_return_status  := FND_API.G_RET_STS_SUCCESS;

    -- Initilizing FND MSG stack, so that it can start storing messages from 0th index
    FND_MSG_PUB.initialize;

    -- Initializing the Error Stack
    PA_DEBUG.init_err_stack('PA_BILLING_WORKBENCH_BILL_PKG.Get_Billing_Sum_Region_Amts');

    BEGIN
       /* Modified this select for bug 3677900. This select will check how many customers are funding this project
       */
	SELECT count(*)
	INTO l_count
	FROM pa_project_customers pc
	WHERE pc.project_id = p_project_id
	AND EXISTS (
      	SELECT
            	spf.project_id project_id
           	,spf.agreement_id
           	,agr.customer_id customer_id
    	FROM
           	pa_agreements_all agr
         	, pa_summary_project_fundings spf
    	WHERE  agr.customer_id        = pc.customer_id
    	AND    agr.agreement_id       = spf.agreement_id
    	AND    spf.project_id         = pc.project_id
    	AND    spf.project_id         = p_project_id
	);

       IF ( l_count > 1 ) THEN
          l_multi_customer_flag := 'Y';
       ELSIF ( l_count = 1 ) THEN
           l_multi_customer_flag := 'N';
       ELSE
          l_multi_customer_flag := 'N';
       END IF;
    END;

/* get next invoice_date */

   BEGIN

      l_next_invoice_date := pa_billing_cycles_pkg.get_next_billing_date (
                       x_project_id => p_project_id );

   EXCEPTION
       when others then
              l_next_invoice_date := NULL;
              null;
   END;

    BEGIN
        /* Funding, Revenue Accrued,Revenue Backlog,Invoiced, and Invoice Backlog
           in Project and Project Functional Currency for Revenue and Invoice Collections sections */
        SELECT
             ( SUM(NVL(spf.project_baselined_amount,0)) )                                                 Total_PC_Funding
            ,( SUM(NVL(spf.project_accrued_amount,0)))                                                    PC_Rev_Accrued
            ,( (SUM(NVL(spf.project_baselined_amount,0)) ) - (SUM(NVL(spf.project_accrued_amount,0))) )   PC_Rev_backlog
            ,( SUM(NVL(spf.project_billed_amount,0)))                                                     PC_Inv_Invoiced
            ,( (SUM(NVL(spf.project_baselined_amount,0)) ) - (SUM(NVL(spf.project_billed_amount,0))) )    PC_Inv_backlog
            ,( SUM(NVL(spf.projfunc_baselined_amount,0)) )                                                Total_PFC_Funding
            ,( SUM(NVL(spf.projfunc_accrued_amount,0)))                                                   PFC_Rev_Accrued
            ,( (SUM(NVL(spf.projfunc_baselined_amount,0)) ) - (SUM(NVL(spf.projfunc_accrued_amount,0))) ) PFC_Rev_backlog
            ,( SUM(NVL(spf.projfunc_billed_amount,0)))                                                    PFC_Inv_Invoiced
            ,( (SUM(NVL(spf.projfunc_baselined_amount,0)) ) - (SUM(NVL(spf.projfunc_billed_amount,0))) )  PFC_Inv_backlog
        INTO
           l_proj_funding_amt       ,
           l_proj_rev_accured       ,
           l_proj_rev_backlog       ,
           l_proj_inv_invoiced      ,
           l_proj_inv_backlog       ,
           l_projfunc_funding_amt   ,
           l_projfunc_rev_accured   ,
           l_projfunc_rev_backlog   ,
           l_projfunc_inv_invoiced  ,
           l_projfunc_inv_backlog
        FROM   pa_summary_project_fundings spf
        WHERE  spf.project_id = p_project_id;

         /* Unbilled Receivable, and Unearned Revenue in Project and
              Project Functional Currency for Revenue Section */
         IF (p_project_currency = p_projfunc_currency ) THEN
            l_proj_ubr             := p_ubr;
            l_proj_uer             := p_uer;
            l_projfunc_ubr         := p_ubr;
            l_projfunc_uer         := p_uer;
            l_pc_ubr_applicab_flag := 'Y';
            l_pc_uer_applicab_flag := 'Y';
         ELSE
            /* Populating Unbilled Receivable, and Unearned Revenue  only for PFC
               and 'N/A' for PC */
            l_projfunc_ubr            := p_ubr;
            l_projfunc_uer            := p_uer;

            /* When Project curr is diff from project func, call the below
               API to convert UBR and UER amounts in PFC to PC - Bug 4932118 */
            PROJECT_UBR_UER_CONVERT (
                                     P_PROJECT_ID       => p_project_id ,
                                     X_PROJECT_CURR_UBR => l_proj_ubr ,
                                     X_PROJECT_CURR_UER => l_proj_uer ,
                                     X_RETURN_STATUS    => x_return_status,
                                     X_MSG_COUNT        => x_msg_count,
                                     X_MSG_DATA         => l_ubr_uer_msg_data );
            l_pc_ubr_applicab_flag    := 'Y';
            l_pc_uer_applicab_flag    := 'Y';

         END IF;

        -- Calculating Revenue write off  in Project and Project Functional Currency
         PA_BILLING.Get_WriteOff_Revenue_Amount(
              p_project_id               => p_project_id,
              p_task_id                  => NULL,
              p_agreement_id             => NULL,
              p_funding_flag             => 'N',
              p_writeoff_amount          => l_writeoff,
              x_project_writeoff_amount  => l_proj_rev_writeoff,
              x_projfunc_writeoff_amount => l_projfunc_rev_writeoff,
              x_revproc_writeoff_amount  => l_revproc_writeoff
              );

    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

    BEGIN
         -- Calculating total paid and due amount in project functional currency
         -- and project currency
         -- calculate tax amount in pfc/pc

         BEGIN
             /**
              * Unaccepted invoices amount
             **/
             SELECT
                SUM(dii.projfunc_bill_amount) pfc_inv_amt,
                SUM(dii.project_bill_amount) pc_inv_amt
             INTO
                 l_projfunc_inv_due_unaccepted,
                 l_proj_inv_due_unaccepted
             FROM  pa_draft_invoices_all di,
                   pa_draft_invoice_items dii
             WHERE dii.project_id         =  di.project_id
             AND dii.draft_invoice_num    =  di.draft_invoice_num
             AND di.transfer_status_code <> 'A'
             AND di.project_id            = p_project_id
             AND di.system_reference IS NULL
             GROUP BY di.project_id;

         EXCEPTION
             WHEN OTHERS THEN
                  l_projfunc_inv_due_unaccepted := 0;
                  l_proj_inv_due_unaccepted := 0;
                  NULL;

         END;

         BEGIN

             /**
               * Accepted invoices amount
             **/

             /* check if any accepted invoice exist as the sql below is throwing no data found */

             SELECT 'T' into l_accepted_exist
             FROM dual
             WHERE EXISTS
                   (SELECT  null
                    FROM  pa_draft_invoices_all di
                    WHERE di.project_id         =  p_project_id
                    AND di.transfer_status_code = 'A'
                    AND di.system_reference IS NOT NULL) ;

             IF l_accepted_exist = 'T' THEN

/* Added NVL,additional condition pa_ar.line_amt_orig(+) <> 0)and outer joins for bug 7394622 */
/* added group function SUM to Ar amounts,modifed query to calculate billing amounts for bug 7628408 */
/* Modified the below query completely for the Bug 8249757 - Start */
                SELECT
                    pa_inv.project_id,
                    SUM(pa_inv.pfc_inv_amt / Nvl(pa_ar.line_amt_orig,1) * Nvl(pa_ar.line_amt_remn,1)) inv_due_pfc,
                    SUM(pa_inv.pfc_inv_amt / Nvl(pa_ar.line_amt_orig,1) * Nvl(pa_ar.line_amt_orig,1)) inv_orig_pfc,
                    SUM(pa_inv.pfc_inv_amt / Nvl(pa_ar.line_amt_orig,1) * Nvl(pa_ar.tax_orig,0))      tax_orig_pfc,
                    SUM(pa_inv.pfc_inv_amt / Nvl(pa_ar.line_amt_orig,1) * Nvl(pa_ar.tax_remn,0))      tax_due_pfc,
                    SUM(pa_inv.pc_inv_amt / Nvl(pa_ar.line_amt_orig,1) * Nvl(pa_ar.line_amt_remn,1))  inv_due_pc,
                    SUM(pa_inv.pc_inv_amt / Nvl(pa_ar.line_amt_orig,1) * Nvl(pa_ar.line_amt_orig,1))  inv_orig_pc,
                    SUM(pa_inv.pc_inv_amt / Nvl(pa_ar.line_amt_orig,1) * Nvl(pa_ar.tax_orig,0))       tax_orig_pc,
                    SUM(pa_inv.pc_inv_amt / Nvl(pa_ar.line_amt_orig,1) * Nvl(pa_ar.tax_remn,0))       tax_due_pc
                INTO
                   l_project_id,
                   l_projfunc_inv_due,
                   l_projfunc_inv_orig,
                   l_projfunc_tax_orig,
                   l_projfunc_tax_due,
                   l_proj_inv_due,
                   l_proj_inv_orig,
                   l_proj_tax_orig,
                   l_proj_tax_due
                FROM
                   (SELECT  arps.customer_trx_id, arps.trx_number,
                            Nvl(SUM(arps.amount_line_items_original),1) line_amt_orig,
                            Nvl(SUM(arps.amount_line_items_remaining),1)line_amt_remn,
                            Nvl(SUM(arps.tax_original),0)               tax_orig,
                            Nvl(SUM(arps.tax_remaining),0)              tax_remn
                    FROM    ar_payment_schedules_all arps
                    GROUP BY arps.customer_trx_id, arps.trx_number
                   ) pa_ar,
                   (SELECT di.project_id,
                           di.ra_invoice_number,
                           di.system_reference system_reference,
                           SUM(dii.projfunc_bill_amount) pfc_inv_amt,
                           SUM(dii.project_bill_amount) pc_inv_amt
                    FROM  pa_draft_invoices_all di,
                          pa_draft_invoice_items dii
                    WHERE di.project_id         =  dii.project_id
                    AND di.draft_invoice_num    =  dii.draft_invoice_num
                    AND di.transfer_status_code = 'A'
                    AND di.system_reference IS NOT NULL
                    GROUP BY di.project_id,di.ra_invoice_number,di.system_reference) pa_inv
                WHERE pa_inv.project_id     = p_project_id
                AND pa_inv.system_reference = pa_ar.customer_trx_id(+)
                AND pa_inv.ra_invoice_number = pa_ar.trx_number(+)
                AND pa_ar.line_amt_orig(+) <> 0
                GROUP BY pa_inv.project_id;
/* Modified the query completely for the Bug 8249757 - End */
             end if;

         EXCEPTION
             WHEN OTHERS THEN
                  NULL;

         END;

         /**
          * Total PFC due, PC due, PFC paid, and PC paid amounts
         **/

          l_projfunc_inv_tot_due  := NVL(l_projfunc_inv_due_unaccepted,0) + NVL(l_projfunc_inv_due,0) +
                                 NVL(l_projfunc_tax_due,0);
          l_proj_inv_tot_due      := NVL(l_proj_inv_due_unaccepted,0) + NVL(l_proj_inv_due,0) +
                                 NVL(l_proj_tax_due,0);
          l_projfunc_inv_tot_paid := NVL(l_projfunc_inv_orig,0) - NVL(l_projfunc_inv_due,0) +
                                     NVL(l_projfunc_tax_orig,0) - NVL(l_projfunc_tax_due,0) ;
          l_proj_inv_tot_paid     := NVL(l_proj_inv_orig,0) - NVL(l_proj_inv_due,0) +
                                     NVL(l_proj_tax_orig,0) - NVL(l_proj_tax_due,0) ;

    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

    -- Selecting column for invoicing status section
    BEGIN
        -- Calculating total billable cost and unbilled cost in project functional currency
        -- and project currency
/*
        SELECT
            SUM(DECODE(system_linkage_function,'BTC',NVL(project_burdened_cost,0),NVL(project_raw_cost,0))) Proj_billable_cost
           ,SUM(DECODE(NVL(event_num,0),0,DECODE(NVL(bill_amount,0),0,DECODE(system_linkage_function,'BTC',
             NVL(project_burdened_cost,0),NVL(project_raw_cost,0)),0),0) )                                  Proj_unbill_cost
           , SUM(DECODE(system_linkage_function,'BTC',NVL(burden_cost,0),NVL(raw_cost,0)))                  Projfunc_billable_cost
           ,SUM(DECODE(NVL(event_num,0),0,DECODE(NVL(bill_amount,0),0,DECODE(system_linkage_function,'BTC',
             NVL(burden_cost,0),NVL(raw_cost,0)),0),0) )                                                    Projfunc_unbill_cost
*/
        SELECT
            SUM(NVL(project_burdened_cost,0)) Proj_billable_cost
           ,SUM(DECODE(NVL(event_num,0),0,DECODE(NVL(bill_amount,0),0, NVL(project_burdened_cost,0) ,0),0) )Proj_unbill_cost
           , SUM(NVL(burden_cost,0))                  Projfunc_billable_cost
           ,SUM(DECODE(NVL(event_num,0),0,DECODE(NVL(bill_amount,0),0, NVL(burden_cost,0),0),0) )   Projfunc_unbill_cost
        INTO
           l_proj_billable_cost
          ,l_proj_unbilled_cost
          ,l_projfunc_billable_cost
          ,l_projfunc_unbilled_cost
        FROM pa_expenditure_items_all
        WHERE project_id = p_project_id
        AND  nvl(billable_flag,'N') = 'Y';


        -- Checking event currency is same as project currency
        SELECT COUNT(*)
        INTO   l_pc_count
        FROM pa_events eve
        WHERE eve.project_id = p_project_id
        AND eve.bill_trans_currency_code <> eve.project_currency_code;

        IF (l_pc_count < 1 ) THEN

          l_pc_unbil_eve_applicab_flag := 'Y';

          /* Calculating unbilled event amount, which is first selct - second selct */
          -- Calculating total event amount with partially billed event also if project currency is same
          -- as bill transaction currency
          SELECT
              SUM(NVL(eve.bill_trans_bill_amount,0)) total_pc_unbilled_with_partial
          INTO
              l_pc_unbill_eve_amt_with_part
          FROM pa_events eve
          WHERE eve.project_id = p_project_id
          AND  nvl(eve.billed_flag,'N') = 'N'
          AND 1   > ( SELECT COUNT(*)
                      FROM pa_events eve2
                      WHERE eve2.project_id = p_project_id
                      AND eve2.bill_trans_currency_code <> eve2.project_currency_code);

        ELSE
           l_pc_unbil_eve_applicab_flag := 'N';
        END IF;


        -- Checking event currency is same as project currency
        SELECT COUNT(*)
        INTO   l_pfc_count
        FROM pa_events eve
        WHERE eve.project_id = p_project_id
        AND eve.bill_trans_currency_code <> eve.projfunc_currency_code;

        IF (l_pfc_count < 1 ) THEN

            l_pfc_unbil_eve_applicab_flag := 'Y';
            -- Calculating total event amount with partially billed event also if project functional currency is same
            -- as bill transaction currency
            SELECT
                SUM(NVL(eve.bill_trans_bill_amount,0)) tot_pfc_unbilled_with_partial
            INTO
                l_pfc_unbill_eve_amt_with_part
             FROM pa_events eve
             WHERE eve.project_id = p_project_id
             AND  nvl(eve.billed_flag,'N') = 'N'
             AND 1   > ( SELECT COUNT(*)
                         FROM pa_events eve2
                         WHERE eve2.project_id = p_project_id
                         AND eve2.bill_trans_currency_code <> eve2.projfunc_currency_code);

        ELSE
          l_pfc_unbil_eve_applicab_flag := 'N';
        END IF;


        IF( l_pc_unbil_eve_applicab_flag = 'Y' OR l_pfc_unbil_eve_applicab_flag = 'Y' ) THEN

            -- Calculating total partially billed amount for events in project functional currency
            -- and project currency
/*
            SELECT
                 SUM(NVL(dii.project_bill_amount,0))  pc_total_partial_billed,
                 SUM(NVL(dii.projfunc_bill_amount,0)) pfc_total_partial_billed
            INTO
               l_pc_total_part_bill_amt,
               l_pfc_total_part_bill_amt
            FROM pa_draft_invoice_items dii
            WHERE dii.project_id = p_project_id
            AND EXISTS (   SELECT null
                           FROM pa_events eve
                           WHERE eve.event_num = dii.event_num
                           AND   eve.billed_flag = 'N');
*/
            SELECT
                 SUM(NVL(dii.project_bill_amount,0))  pc_total_partial_billed,
                 SUM(NVL(dii.projfunc_bill_amount,0)) pfc_total_partial_billed
            INTO
               l_pc_total_part_bill_amt,
               l_pfc_total_part_bill_amt
            FROM pa_draft_invoice_items dii, pa_events eve
            WHERE eve.project_id = p_project_id
            and eve.project_id = dii.project_id
            and nvl(eve.task_id, 0) = nvl(dii.task_id,0)
            and eve.event_num = nvl(dii.event_num,0)
            and nvl(eve.billed_flag,'N') = 'N';

            -- Calculating total unbilled event amount in project functional currency
            -- and project currency
            l_proj_unbilled_events     := nvl(l_pc_unbill_eve_amt_with_part,0)  - nvl(l_pc_total_part_bill_amt,0);
            l_projfunc_unbilled_events := nvl(l_pfc_unbill_eve_amt_with_part,0) - nvl(l_pfc_total_part_bill_amt,0);
        END IF;

        -- Calculating total unbilled retention amount in project functional currency
        -- and project currency
        SELECT
/*
            SUM(NVL(project_total_billed,0)) - SUM(NVL(project_total_retained,0)) Proj_Unbilled_Retn
           ,SUM(NVL(projfunc_total_billed,0)) - SUM(NVL(projfunc_total_retained,0)) Projfunc_Unbilled_Retn
*/
            SUM(NVL(project_total_retained,0)) - SUM(NVL(project_total_billed,0)) Proj_Unbilled_Retn
           ,SUM(NVL(projfunc_total_retained,0)) - SUM(NVL(projfunc_total_billed,0)) Projfunc_Unbilled_Retn
        INTO
           l_proj_unbilled_retn
          ,l_projfunc_unbilled_retn
        FROM pa_summary_project_retn
        WHERE project_id = p_project_id;

        -- Calculating total unapproved invoice amount in project functional currency
        -- and project currency
        SELECT
             SUM(NVL(dii.project_bill_amount,0)) unapproved_project_invoice,
             SUM(NVL(dii.projfunc_bill_amount,0)) unapproved_project_invoice
        INTO
           l_proj_unapprov_inv_amt,
           l_projfunc_unapprov_inv_amt
        FROM pa_draft_invoice_items dii,pa_draft_invoices_all di
        WHERE dii.draft_invoice_num = di.draft_invoice_num
        AND   dii.project_id        = di.project_id
        AND   di.project_id         = p_project_id
        AND   di.approved_by_person_id IS NULL;

    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

/* For Bug 3500408 : Introducing NVL clause for all amount columns to ensure that in case any amount column has
Null then on the Billing summary Page it shall be viewed as 0.00  . UBR and UER amount wont be touched as it is displayed
as N/A in case of PC<> PFC and otherwise when NULL they take value 0.00*/
  -- Calling procedure to populate temp table
  Populat_Bill_Workbench_Data (
                                            p_project_id                  =>    p_project_id,
                                            p_proj_funding_amt            =>    NVL(l_proj_funding_amt ,0),
                                            p_proj_rev_accured            =>    NVL(l_proj_rev_accured,0) ,
                                            p_proj_rev_backlog            =>    NVL(l_proj_rev_backlog,0) ,
                                            p_proj_rev_writeoff           =>    NVL(l_proj_rev_writeoff,0) ,
                                            p_proj_ubr                    =>    l_proj_ubr ,
                                            p_proj_uer                    =>    l_proj_uer ,
                                            p_proj_inv_invoiced           =>    NVL(l_proj_inv_invoiced ,0),
                                            p_proj_inv_backlog            =>    NVL(l_proj_inv_backlog ,0),
                                            p_proj_inv_paid               =>    NVL(l_proj_inv_tot_paid ,0),
                                            p_proj_inv_due                =>    NVL(l_proj_inv_tot_due ,0),
                                            p_proj_billable_cost          =>    NVL(l_proj_billable_cost ,0),
                                            p_proj_unbilled_cost          =>    NVL(l_proj_unbilled_cost ,0),
                                            p_proj_unbilled_events        =>    NVL(l_proj_unbilled_events ,0),
                                            p_proj_unbilled_retn          =>    NVL(l_proj_unbilled_retn ,0),
                                            p_proj_unapproved_inv_amt     =>    NVL(l_proj_unapprov_inv_amt ,0),
                                            p_proj_tax                    =>    NVL(l_proj_tax_orig ,0),
                                            p_pc_ubr_applicab_flag        =>    l_pc_ubr_applicab_flag,
                                            p_pc_uer_applicab_flag        =>    l_pc_uer_applicab_flag,
                                            p_pc_unbil_eve_applicab_flag  =>    l_pc_unbil_eve_applicab_flag,
                                            p_projfunc_funding_amt        =>    NVL(l_projfunc_funding_amt,0) ,
                                            p_projfunc_rev_accured        =>    NVL(l_projfunc_rev_accured ,0),
                                            p_projfunc_rev_backlog        =>    NVL(l_projfunc_rev_backlog,0) ,
                                            p_projfunc_rev_writeoff       =>    NVL(l_projfunc_rev_writeoff,0) ,
                                            p_projfunc_ubr                =>    l_projfunc_ubr ,
                                            p_projfunc_uer                =>    l_projfunc_uer ,
                                            p_projfunc_inv_invoiced       =>    NVL(l_projfunc_inv_invoiced,0) ,
                                            p_projfunc_inv_backlog        =>    NVL(l_projfunc_inv_backlog ,0),
                                            p_projfunc_inv_paid           =>    NVL(l_projfunc_inv_tot_paid ,0),
                                            p_projfunc_inv_due            =>    NVL(l_projfunc_inv_tot_due ,0),
                                            p_projfunc_billable_cost      =>    NVL(l_projfunc_billable_cost ,0),
                                            p_projfunc_unbilled_cost      =>    NVL(l_projfunc_unbilled_cost ,0),
                                            p_projfunc_unbilled_events    =>    NVL(l_projfunc_unbilled_events ,0),
                                            p_projfunc_unbilled_retn      =>    NVL(l_projfunc_unbilled_retn ,0),
                                            p_projfunc_unapprov_inv_amt   =>    NVL(l_projfunc_unapprov_inv_amt ,0),
                                            p_projfunc_tax                =>    NVL(l_projfunc_tax_orig ,0),
                                            p_pfc_unbil_eve_applicab_flag =>    l_pfc_unbil_eve_applicab_flag,
                                            p_next_invoice_date           =>    l_next_invoice_date,
                                            p_multi_customer_flag         =>    l_multi_customer_flag,
                                            x_return_status               =>    l_return_status,
                                            x_msg_count                   =>    l_msg_count  ,
                                            x_msg_data                    =>    l_msg_data
                                           );
/*End of Bug fix for Bug 3500408*/
IF l_ubr_uer_msg_data ='PA_NO_EXCH_RATE_EXISTS_PFC_PC' THEN
	x_msg_data :=  l_ubr_uer_msg_data;
END IF;
EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_BILLING_WORKBENCH_BILL_PKG'
                            ,p_procedure_name => 'Get_Billing_Sum_Region_Amts' );
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       x_msg_count := 1;
       x_msg_data  := SUBSTR(SQLERRM,1,30);
       RAISE;
END Get_Billing_Sum_Region_Amts;

-- This procedure will populate the temp table with all the input paramters for billing
-- work bench.
-- Input parameters
-- Parameters                      Type           Required      Description
-- p_project_id                   NUMBER           YES          The identifier of the project
-- p_funding_amt                  NUMBER          YES          Total Baselined amount for the given project
-- p_rev_accured                  NUMBER          YES          Total Revenue accrued for the given project
-- p_rev_backlog                  NUMBER          YES          Revenue funding backlog. The diff of above two
-- p_rev_writeoff                 NUMBER          YES          Total accrued revenue writeoff
-- p_ubr                          NUMBER          YES          Total Unbilled receivables for the given project
-- p_uer                          NUMBER          YES          Total Unearned revenue for the given project
-- p_inv_billed                   NUMBER          YES          Total Invoiced amount(including project invoices, credit
--                                                             memos,write-off,cancelling,concession project, and
--                                                             retention invoices
-- p_inv_backlog                  NUMBER          YES          Invoice Funding backlog. The diff of Funding amt and inv_billed
-- p_inv_paid                     NUMBER          YES          Total invoice amount paid by the customers for this project
-- p_inv_due                      NUMBER          YES          Total invoice amount due from customers
-- p_billable_cost                NUMBER          YES          Sum of the burdened cost of all the expenditure items
--                                                             with billable flag as yes and cost distribution as yes
-- p_unbilled_cost                NUMBER          YES          Total burdened cost that is not yet billed, but marked
--                                                             as billable as yes
-- p_unbilled_events              NUMBER          YES          Sum of all invoice events that are not billed to the customers (
--                                                             including partialy billed event amount also
-- p_unbilled_retn                NUMBER          YES          Total withheld amount that is not billed to the customer
-- p_unapproved_inv_amt           NUMBER          YES          Sum of all the unapproved project and retention invoices
--                                                             including credit memosof project invoices, cancelling,
-- x_funding_amt                  NUMBER          YES          Total Baselined amount for the given project
-- x_rev_accured                  NUMBER          YES          Total Revenue accrued for the given project
-- x_rev_backlog                  NUMBER          YES          Revenue funding backlog. The diff of above two
-- x_rev_writeoff                 NUMBER          YES          Total accrued revenue writeoff
-- x_ubr                          NUMBER          YES          Total Unbilled receivables for the given project
-- x_uer                          NUMBER          YES          Total Unearned revenue for the given project
-- x_inv_billed                   NUMBER          YES          Total Invoiced amount(including project invoices, credit
--                                                             memos,write-off,cancelling,concession project, and
--                                                             retention invoices
-- x_inv_backlog                  NUMBER          YES          Invoice Funding backlog. The diff of Funding amt and inv_billed
-- x_inv_paid                     NUMBER          YES          Total invoice amount paid by the customers for this project
-- x_inv_due                      NUMBER          YES          Total invoice amount due from customers
-- x_billable_cost                NUMBER          YES          Sum of the burdened cost of all the expenditure items
--                                                             with billable flag as yes and cost distribution as yes
-- x_unbilled_cost                NUMBER          YES          Total burdened cost that is not yet billed, but marked
--                                                             as billable as yes
-- x_unbilled_events              NUMBER          YES          Sum of all invoice events that are not billed to the customers (
--                                                             including partialy billed event amount also
-- x_unbilled_retn                NUMBER          YES          Total withheld amount that is not billed to the customer
-- x_unapproved_inv_amt           NUMBER          YES          Sum of all the unapproved project and retention invoices
--                                                             including credit memosof project invoices, cancelling,
--                                                             writeoff,concession project
--                                                             writeoff,concession project
--
-- Out parameters
--

PROCEDURE Populat_Bill_Workbench_Data (
                                            p_project_id                  IN    NUMBER,
                                            p_proj_funding_amt            IN    NUMBER ,
                                            p_proj_rev_accured            IN    NUMBER ,
                                            p_proj_rev_backlog            IN    NUMBER ,
                                            p_proj_rev_writeoff           IN    NUMBER ,
                                            p_proj_ubr                    IN    NUMBER ,
                                            p_proj_uer                    IN    NUMBER ,
                                            p_proj_inv_invoiced           IN    NUMBER ,
                                            p_proj_inv_backlog            IN    NUMBER ,
                                            p_proj_inv_paid               IN    NUMBER ,
                                            p_proj_inv_due                IN    NUMBER ,
                                            p_proj_billable_cost          IN    NUMBER ,
                                            p_proj_unbilled_cost          IN    NUMBER ,
                                            p_proj_unbilled_events        IN    NUMBER ,
                                            p_proj_unbilled_retn          IN    NUMBER ,
                                            p_proj_unapproved_inv_amt     IN    NUMBER ,
                                            p_proj_tax                    IN    NUMBER ,
                                            p_pc_ubr_applicab_flag        IN    VARCHAR2,
                                            p_pc_uer_applicab_flag        IN    VARCHAR2,
                                            p_pc_unbil_eve_applicab_flag  IN    VARCHAR2,
                                            p_projfunc_funding_amt        IN    NUMBER ,
                                            p_projfunc_rev_accured        IN    NUMBER ,
                                            p_projfunc_rev_backlog        IN    NUMBER ,
                                            p_projfunc_rev_writeoff       IN    NUMBER ,
                                            p_projfunc_ubr                IN    NUMBER ,
                                            p_projfunc_uer                IN    NUMBER ,
                                            p_projfunc_inv_invoiced       IN    NUMBER ,
                                            p_projfunc_inv_backlog        IN    NUMBER ,
                                            p_projfunc_inv_paid           IN    NUMBER ,
                                            p_projfunc_inv_due            IN    NUMBER ,
                                            p_projfunc_billable_cost      IN    NUMBER ,
                                            p_projfunc_unbilled_cost      IN    NUMBER ,
                                            p_projfunc_unbilled_events    IN    NUMBER ,
                                            p_projfunc_unbilled_retn      IN    NUMBER ,
                                            p_projfunc_unapprov_inv_amt   IN    NUMBER ,
                                            p_projfunc_tax                IN    NUMBER ,
                                            p_pfc_unbil_eve_applicab_flag IN    VARCHAR2,
                                            p_next_invoice_date           IN    DATE,
                                            p_multi_customer_flag         IN    VARCHAR2,
                                            x_return_status               OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                            x_msg_count                   OUT   NOCOPY NUMBER  , --File.Sql.39 bug 4440895
                                            x_msg_data                    OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                      )
IS
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

DELETE pa_bill_workbench_temp;
INSERT
INTO pa_bill_workbench_temp(
       PROJECT_ID                  ,
       PC_FUNDING                  ,
       PC_REV_ACCRUED              ,
       PC_REV_BACKLOG              ,
       PC_WRITEOFF                 ,
       PC_UBR                      ,
       PC_UER                      ,
       PC_INVOICED                 ,
       PC_INV_BACKLOG              ,
       PC_PAID                     ,
       PC_DUE                      ,
       PC_BILLABLE_COST            ,
       PC_UNBILLED_COST            ,
       PC_UNBILLED_EVENTS          ,
       PC_UNBILLED_RETENTION       ,
       PC_UNAPPRO_INVOICES         ,
       PC_TAX                      ,
       PC_UBR_APPLICAB_FLAG        ,
       PC_UER_APPLICAB_FLAG        ,
       PC_UNBIL_EVE_APPLICAB_FLAG  ,
       PFC_FUNDING                 ,
       PFC_REV_ACCRUED             ,
       PFC_REV_BACKLOG             ,
       PFC_WRITEOFF                ,
       PFC_UBR                     ,
       PFC_UER                     ,
       PFC_INVOICED                ,
       PFC_INV_BACKLOG             ,
       PFC_PAID                    ,
       PFC_DUE                     ,
       PFC_BILLABLE_COST           ,
       PFC_UNBILLED_COST           ,
       PFC_UNBILLED_EVENTS         ,
       PFC_UNBILLED_RETENTION      ,
       PFC_UNAPPRO_INVOICES        ,
       PFC_TAX                     ,
       PFC_UNBIL_EVE_APPLICAB_FLAG ,
       NEXT_INVOICE_DATE           ,
       Multi_Customer_Flag
)
VALUES(
       p_project_id                  ,
       p_proj_funding_amt            ,
       p_proj_rev_accured            ,
       p_proj_rev_backlog            ,
       p_proj_rev_writeoff           ,
       p_proj_ubr                    ,
       p_proj_uer                    ,
       p_proj_inv_invoiced           ,
       p_proj_inv_backlog            ,
       p_proj_inv_paid               ,
       p_proj_inv_due                ,
       p_proj_billable_cost          ,
       p_proj_unbilled_cost          ,
       p_proj_unbilled_events        ,
       p_proj_unbilled_retn          ,
       p_proj_unapproved_inv_amt     ,
       p_proj_tax                    ,
       p_pc_ubr_applicab_flag        ,
       p_pc_uer_applicab_flag        ,
       p_pc_unbil_eve_applicab_flag  ,
       p_projfunc_funding_amt        ,
       p_projfunc_rev_accured        ,
       p_projfunc_rev_backlog        ,
       p_projfunc_rev_writeoff       ,
       p_projfunc_ubr                ,
       p_projfunc_uer                ,
       p_projfunc_inv_invoiced       ,
       p_projfunc_inv_backlog        ,
       p_projfunc_inv_paid           ,
       p_projfunc_inv_due            ,
       p_projfunc_billable_cost      ,
       p_projfunc_unbilled_cost      ,
       p_projfunc_unbilled_events    ,
       p_projfunc_unbilled_retn      ,
       p_projfunc_unapprov_inv_amt   ,
       p_projfunc_tax                ,
       p_pfc_unbil_eve_applicab_flag ,
       p_next_invoice_date           ,
       p_multi_customer_flag
);

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_BILLING_WORKBENCH_BILL_PKG'
                            ,p_procedure_name => 'Populat_Bill_Workbench_Data' );
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       x_msg_count := 1;
       x_msg_data  := SUBSTR(SQLERRM,1,30);
       RAISE;
END Populat_Bill_Workbench_Data;


-- This procedure will populate the temp table with all the input paramters for Summary by customer region of invoicing
-- Input parameters
-- Parameters                      Type           Required      Description
-- p_project_id                   NUMBER           YES          The identifier of the project
-- p_inv_filter                   VARCHAR2         YES          Filter to filter invoices based on the user inputs
--
-- Out parameters
--

/* Added 10 parameter  after p_inv_filter for search region i.e. bug 3618704 */

PROCEDURE Populat_Inv_Summ_by_Cust_RN (
                                            p_project_id                  IN    NUMBER,
                                            p_inv_filter                  IN    VARCHAR2,
                                            p_search_flag                 IN    VARCHAR2,
                                            p_agreement_id                IN    NUMBER ,
                                            p_draft_num                   IN    NUMBER,
                                            p_ar_number                   IN    VARCHAR2 ,
                                            p_creation_frm_date           IN    DATE ,
                                            p_creation_to_date            IN    DATE ,
                                            p_invoice_frm_date            IN    DATE ,
                                            p_invoice_to_date             IN    DATE ,
                                            p_gl_frm_date                 IN    DATE ,
                                            p_gl_to_date                  IN    DATE ,
                                            x_return_status               OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                            x_msg_count                   OUT   NOCOPY NUMBER  , --File.Sql.39 bug 4440895
                                            x_msg_data                    OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                        )
IS
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;


 DELETE pa_bill_wrkbench_inv_temp;


/* Added search flag filter if for search region */

   IF (NVL(UPPER(p_search_flag),'N') = 'N') THEN

	INSERT
	INTO pa_bill_wrkbench_inv_temp(
     	PROJECT_ID
    	,AGREEMENT_ID
    	,CUSTOMER_ID
    	,CUSTOMER_NAME
    	,PC_FUNDING
    	,PC_INVOICED
    	,PC_DUE_ACCEPTED
    	,PC_DUE_PENDING
    	,PC_TAX
    	,PC_TAX_DUE
    	,PFC_FUNDING
    	,PFC_INVOICED
    	,PFC_DUE_ACCEPTED
    	,PFC_DUE_PENDING
    	,PFC_TAX
    	,PFC_TAX_DUE
	)
    	SELECT
            	spf.project_id project_id
           	,spf.agreement_id
--           	,ra.customer_id customer_id
--           	,ra.customer_name||' ('||ra.customer_number||')' Customer
                ,cust_acct.cust_account_id customer_id
                ,substrb(party.party_name,1,50)||' ('||cust_acct.account_number||')' Customer
           	,SUM(NVL(spf.project_baselined_amount,0)) pc_Baselined
           	,NULL pc_invoiced
           	,NULL pc_due_accepted
           	,NULL pc_due_pending
           	,NULL pc_tax
           	,NULL pc_tax_due
           	,SUM(NVL(spf.projfunc_baselined_amount,0)) pfc_Baselined
           	,NULL pfc_Invoiced
           	,NULL pfc_due_accepted
           	,NULL pfc_due_pending
           	,NULL pfc_tax
           	,NULL pfc_tax_due
    	FROM
--           	ra_customers ra
                hz_parties party
                , hz_cust_accounts cust_acct
         	, pa_agreements_all agr
         	, pa_project_customers pc
         	, pa_summary_project_fundings spf
--    	WHERE  ra.customer_id         = agr.customer_id
        WHERE  cust_acct.cust_account_id= agr.customer_id
        AND    cust_acct.party_id = party.party_id
    	AND    agr.customer_id        = pc.customer_id
    	AND    agr.agreement_id       = spf.agreement_id
    	AND    spf.project_id         = pc.project_id
    	AND    spf.project_id         = p_project_id
    	GROUP BY /*ra.customer_name,ra.customer_id,ra.customer_number*/
                substrb(party.party_name,1,50),cust_acct.account_number,cust_acct.cust_account_id,spf.project_id,spf.agreement_id;


	/**
  	* Updating  Project invoiced amount and project functional invoice amount
	**/

	UPDATE pa_bill_wrkbench_inv_temp pbw
	SET (pbw.pc_invoiced,pbw.pfc_invoiced ) =
                     (SELECT
                            SUM(NVL(dii.project_bill_amount,0)) projinv_amt
                           ,SUM(NVL(dii.projfunc_bill_amount,0)) projfuncinv_amt
                      FROM  pa_draft_invoices_all di , pa_draft_invoice_items dii , pa_agreements_all agr
                      WHERE dii.draft_invoice_num      = di.draft_invoice_num
                      AND   dii.project_id       = di.project_id
                      AND   agr.customer_id      = di.customer_id
                      AND   agr.agreement_id     = di.agreement_id
                      AND   di.customer_id       = pbw.customer_id
                      AND   di.agreement_id      = pbw.agreement_id
                      AND   di.project_id        = pbw.project_id
                      AND (
                            ( 'INV_ALL'           = p_inv_filter)
                            OR ( 'INV_APPRO'         = p_inv_filter AND di.approved_by_person_id IS NOT NULL
                                                                    AND di.released_date IS NULL)
                            OR ( 'INV_CREDITS'       = p_inv_filter AND di.draft_invoice_num_credited IS NOT NULL )
                            OR ( 'INV_RETN_BILL_INV' = p_inv_filter AND NVL(di.retention_invoice_flag,'N') = 'Y' )
                            OR ( 'INV_UNAPPRO'       = p_inv_filter AND di.approved_by_person_id IS NULL )
                            OR ( 'INV_RELEASE'       = p_inv_filter AND di.transfer_status_code = 'P'
                                                                   AND di.released_date IS NOT NULL )
                            OR ( 'INV_ACCEPT'        = p_inv_filter AND di.transfer_status_code = 'A'
                                                                   AND NVL(di.generation_error_flag,'N') <> 'Y' )
                            OR ( 'INV_REJECT'        = p_inv_filter AND (di.transfer_status_code = 'X'
                                                                   OR   di.transfer_status_code = 'R')
                                                                   AND NVL(di.generation_error_flag,'N') <> 'Y' )
                            OR ( 'INV_ERROR'         = p_inv_filter AND NVL(di.generation_error_flag,'N') = 'Y' )
                          )
                      GROUP BY di.project_id,di.customer_id,di.agreement_id);



	/**
 	*  Updating  Project due amount (accepted) and project functional due amount (accepted)
 	*            Project tax amount, tax due amount and project functional tax amount tax due amount
	**/
	/* Modified the below query completely for the Bug 8249757 includes the fix of bug 7394622 - Start */
	UPDATE pa_bill_wrkbench_inv_temp pbw
	/* added group function SUM to Ar amounts,modifed query to calculate billing amounts for bug 7628408 */
	SET (pbw.pc_due_accepted,pbw.pfc_due_accepted, pbw.pc_tax, pbw.pfc_tax, pbw.pc_tax_due, pbw.pfc_tax_due ) =
                     ( SELECT
                           SUM(( pa_inv.pc_inv_amt /Nvl(pa_ar.line_amt_orig,1)) * Nvl(pa_ar.line_amt_remn,1))  due_accepted_pc,
                           SUM(( pa_inv.pfc_inv_amt /Nvl(pa_ar.line_amt_orig,1)) * Nvl(pa_ar.line_amt_remn,1)) due_accepted_pfc,
                           SUM(( pa_inv.pc_inv_amt /Nvl(pa_ar.line_amt_orig,1)) * Nvl(pa_ar.tax_orig,0))       tax_pc,
                           SUM(( pa_inv.pfc_inv_amt /Nvl(pa_ar.line_amt_orig,1)) * Nvl(pa_ar.tax_orig,0))      tax_pfc,
                           SUM(( pa_inv.pc_inv_amt /Nvl(pa_ar.line_amt_orig,1)) * Nvl(pa_ar.tax_remn,0))       tax_due_pc,
                           SUM(( pa_inv.pfc_inv_amt /Nvl(pa_ar.line_amt_orig,1)) * Nvl(pa_ar.tax_remn,0))      tax_due_pfc
                        FROM
                                (SELECT  arps.customer_trx_id, arps.trx_number,
                                           Nvl(SUM(arps.amount_line_items_original),1) line_amt_orig,
                                           Nvl(SUM(arps.amount_line_items_remaining),1)line_amt_remn,
                                           Nvl(SUM(arps.tax_original),0)               tax_orig,
                                           Nvl(SUM(arps.tax_remaining),0)              tax_remn
                                   FROM    ar_payment_schedules_all arps
                                   GROUP BY arps.customer_trx_id, arps.trx_number
                                ) pa_ar,
                                (SELECT di.project_id,
                                        di.customer_id,
                                        di.agreement_id,
                                        di.ra_invoice_number,
                                        di.system_reference system_reference,
                                        SUM(dii.project_bill_amount) pc_inv_amt,
                                        SUM(dii.projfunc_bill_amount) pfc_inv_amt
                                 FROM  pa_draft_invoices_all di,
                                       pa_draft_invoice_items dii,
                                       PA_BILL_WRKBENCH_INV_TEMP pbwi
                                 WHERE di.project_id         =  dii.project_id
                                       AND di.draft_invoice_num    =  dii.draft_invoice_num
                                       AND di.transfer_status_code = 'A'
                                       AND di.customer_id          = pbwi.customer_id
                                       AND di.agreement_id         = pbwi.agreement_id
                                       AND di.project_id           = pbwi.project_id
                                       AND di.system_reference IS NOT NULL
                                       AND (
                                             ( 'INV_ALL'           = p_inv_filter)
                                             OR ( 'INV_APPRO'         = p_inv_filter
                                                 AND di.approved_by_person_id IS NOT NULL
                                                 AND di.released_date IS NULL)
                                             OR ( 'INV_CREDITS'       = p_inv_filter
                                                 AND di.draft_invoice_num_credited IS NOT NULL )
                                             OR ( 'INV_RETN_BILL_INV' = p_inv_filter
                                                 AND NVL(di.retention_invoice_flag,'N') = 'Y' )
                                             OR ( 'INV_UNAPPRO'       = p_inv_filter
                                                 AND di.approved_by_person_id IS NULL )
                                             OR ( 'INV_RELEASE'       = p_inv_filter
                                                 AND di.transfer_status_code = 'P'
                                                 AND di.released_date IS NOT NULL )
                                             OR ( 'INV_ACCEPT'        = p_inv_filter
                                                 AND di.transfer_status_code = 'A'
                                                 AND NVL(di.generation_error_flag,'N') <> 'Y' )
                                             OR ( 'INV_REJECT'        = p_inv_filter
                                                 AND (di.transfer_status_code = 'X'
                                                     OR   di.transfer_status_code = 'R')
                                                 AND NVL(di.generation_error_flag,'N') <> 'Y' )
                                             OR ( 'INV_ERROR'         = p_inv_filter
                                                 AND NVL(di.generation_error_flag,'N') = 'Y' )
                                           )
                                       GROUP BY di.project_id,di.customer_id,di.agreement_id, di.ra_invoice_number,
                                                 di.system_reference) pa_inv
                        WHERE pa_inv.project_id       = pbw.project_id
                        AND   pa_inv.customer_id      = pbw.customer_id
                        AND   pa_inv.agreement_id     = pbw.agreement_id
                        AND pa_inv.system_reference   = pa_ar.customer_trx_id(+)
                        AND pa_inv.ra_invoice_number = pa_ar.trx_number(+)
                        AND pa_ar.line_amt_orig(+) <> 0   /* Condition added for bug 5230465 */
                        GROUP BY pa_inv.project_id, pa_inv.customer_id,pa_inv.agreement_id);
	/* Modified the query completely for the Bug 8249757 includes the fix of bug 7394622 - End */

	UPDATE pa_bill_wrkbench_inv_temp pbw
	SET (pbw.pc_due_pending,pbw.pfc_due_pending ) =
                  ( SELECT
                         SUM(dii.project_bill_amount) ,
                         SUM(dii.projfunc_bill_amount)
                    FROM  pa_draft_invoices_all di,
                          pa_draft_invoice_items dii
                    WHERE di.project_id          =  dii.project_id
                    AND di.draft_invoice_num     =  dii.draft_invoice_num
                    AND di.transfer_status_code <> 'A'
                    AND di.customer_id           = pbw.customer_id
                    AND di.agreement_id          = pbw.agreement_id
                    AND di.project_id            = pbw.project_id
                    AND di.system_reference IS NULL
                    AND (
                          ( 'INV_ALL'             = p_inv_filter)
                          OR ( 'INV_APPRO'         = p_inv_filter
                              AND di.approved_by_person_id IS NOT NULL
                              AND di.released_date IS NULL)
                          OR ( 'INV_CREDITS'       = p_inv_filter
                              AND di.draft_invoice_num_credited IS NOT NULL )
                          OR ( 'INV_RETN_BILL_INV' = p_inv_filter
                              AND NVL(di.retention_invoice_flag,'N') = 'Y' )
                          OR ( 'INV_UNAPPRO'       = p_inv_filter
                              AND di.approved_by_person_id IS NULL )
                          OR ( 'INV_RELEASE'       = p_inv_filter
                              AND di.transfer_status_code = 'P'
                              AND di.released_date IS NOT NULL )
                          OR ( 'INV_ACCEPT'        = p_inv_filter
                              AND di.transfer_status_code = 'A'
                              AND NVL(di.generation_error_flag,'N') <> 'Y' )
                          OR ( 'INV_REJECT'        = p_inv_filter
                              AND (di.transfer_status_code = 'X'
                                  OR   di.transfer_status_code = 'R')
                              AND NVL(di.generation_error_flag,'N') <> 'Y' )
                          OR ( 'INV_ERROR'         = p_inv_filter
                              AND NVL(di.generation_error_flag,'N') = 'Y' )
                        )
                     GROUP BY di.project_id,di.customer_id,di.agreement_id);

   ELSIF (NVL(UPPER(p_search_flag),'N') = 'Y') THEN

	INSERT
	INTO pa_bill_wrkbench_inv_temp(
     	PROJECT_ID
    	,AGREEMENT_ID
    	,CUSTOMER_ID
    	,CUSTOMER_NAME
    	,PC_FUNDING
    	,PC_INVOICED
    	,PC_DUE_ACCEPTED
    	,PC_DUE_PENDING
    	,PC_TAX
    	,PC_TAX_DUE
    	,PFC_FUNDING
    	,PFC_INVOICED
    	,PFC_DUE_ACCEPTED
    	,PFC_DUE_PENDING
    	,PFC_TAX
    	,PFC_TAX_DUE
	)
    	SELECT
            	spf.project_id project_id
           	,spf.agreement_id
--              ,ra.customer_id customer_id
--              ,ra.customer_name||' ('||ra.customer_number||')' Customer
                ,cust_acct.cust_account_id customer_id
                ,substrb(party.party_name,1,50)||' ('||cust_acct.account_number||')' Customer
           	,SUM(NVL(spf.project_baselined_amount,0)) pc_Baselined
           	,NULL pc_invoiced
           	,NULL pc_due_accepted
           	,NULL pc_due_pending
           	,NULL pc_tax
           	,NULL pc_tax_due
           	,SUM(NVL(spf.projfunc_baselined_amount,0)) pfc_Baselined
           	,NULL pfc_Invoiced
           	,NULL pfc_due_accepted
           	,NULL pfc_due_pending
           	,NULL pfc_tax
           	,NULL pfc_tax_due
    	FROM
--           	ra_customers ra
                hz_parties party
                , hz_cust_accounts cust_acct
         	, pa_agreements_all agr
         	, pa_project_customers pc
         	, pa_summary_project_fundings spf
                , pa_draft_invoices_all di
--    	WHERE  ra.customer_id         = agr.customer_id
        WHERE  cust_acct.cust_account_id= agr.customer_id
        AND    cust_acct.party_id = party.party_id
        AND   di.draft_invoice_num                 = NVL(p_draft_num,di.draft_invoice_num)
        AND UPPER(NVL(di.ra_invoice_number,'-99')) = UPPER(NVL(p_ar_number,NVL(di.ra_invoice_number,'-99')))
        AND NVL(TRUNC(di.creation_date),TRUNC(SYSDATE)) BETWEEN
            NVL(LTRIM(RTRIM(p_creation_frm_date)),NVL(TRUNC(di.creation_date),TRUNC(SYSDATE)))
          AND NVL(LTRIM(RTRIM(p_creation_to_date)),NVL(TRUNC(di.creation_date),TRUNC(SYSDATE)))
        AND NVL(TRUNC(di.invoice_date),TRUNC(SYSDATE)) BETWEEN
           NVL(LTRIM(RTRIM(p_invoice_frm_date)),NVL(TRUNC(di.invoice_date),TRUNC(SYSDATE)))
          AND NVL(LTRIM(RTRIM(p_invoice_to_date)),NVL(TRUNC(di.invoice_date),TRUNC(SYSDATE)))
        AND NVL(TRUNC(di.gl_date),TRUNC(SYSDATE)) BETWEEN
           NVL(LTRIM(RTRIM(p_gl_frm_date)),NVL(TRUNC(di.gl_date),TRUNC(SYSDATE)))
          AND NVL(LTRIM(RTRIM(p_gl_to_date)),NVL(TRUNC(di.gl_date),TRUNC(SYSDATE)))
        AND    di.agreement_id        = agr.agreement_id
        AND    di.customer_id         = agr.customer_id
        AND    di.project_id          = spf.project_id
    	AND    agr.customer_id        = pc.customer_id
    	AND    agr.agreement_id       = spf.agreement_id
    	AND    spf.project_id         = pc.project_id
    	AND    spf.agreement_id       = NVL(p_agreement_id,spf.agreement_id)
    	AND    spf.project_id         = p_project_id
        GROUP BY /*ra.customer_name,ra.customer_id,ra.customer_number*/
                substrb(party.party_name,1,50),cust_acct.account_number,cust_acct.cust_account_id,spf.project_id,spf.agreement_id;
	/**
  	* Updating  Project invoiced amount and project functional invoice amount
	**/

	UPDATE pa_bill_wrkbench_inv_temp pbw
	SET (pbw.pc_invoiced,pbw.pfc_invoiced ) =
                     (SELECT
                            SUM(NVL(dii.project_bill_amount,0)) projinv_amt
                           ,SUM(NVL(dii.projfunc_bill_amount,0)) projfuncinv_amt
                      FROM  pa_draft_invoices_all di , pa_draft_invoice_items dii , pa_agreements_all agr
                      WHERE dii.draft_invoice_num                = di.draft_invoice_num
                      AND   dii.project_id                       = di.project_id
                      AND   agr.customer_id                      = di.customer_id
                      AND   agr.agreement_id                     = di.agreement_id
                      AND   di.agreement_id                      = NVL(p_agreement_id,di.agreement_id)
                      AND   di.draft_invoice_num                 = NVL(p_draft_num,di.draft_invoice_num)
                      AND UPPER(NVL(di.ra_invoice_number,'-99')) = UPPER(NVL(p_ar_number,NVL(di.ra_invoice_number,'-99')))
                      AND NVL(TRUNC(di.creation_date),TRUNC(SYSDATE)) BETWEEN
                            NVL(LTRIM(RTRIM(p_creation_frm_date)),NVL(TRUNC(di.creation_date),TRUNC(SYSDATE)))
                         AND NVL(LTRIM(RTRIM(p_creation_to_date)),NVL(TRUNC(di.creation_date),TRUNC(SYSDATE)))
                      AND NVL(TRUNC(di.invoice_date),TRUNC(SYSDATE)) BETWEEN
                            NVL(LTRIM(RTRIM(p_invoice_frm_date)),NVL(TRUNC(di.invoice_date),TRUNC(SYSDATE)))
                         AND NVL(LTRIM(RTRIM(p_invoice_to_date)),NVL(TRUNC(di.invoice_date),TRUNC(SYSDATE)))
                      AND NVL(TRUNC(di.gl_date),TRUNC(SYSDATE)) BETWEEN
                            NVL(LTRIM(RTRIM(p_gl_frm_date)),NVL(TRUNC(di.gl_date),TRUNC(SYSDATE)))
                         AND NVL(LTRIM(RTRIM(p_gl_to_date)),NVL(TRUNC(di.gl_date),TRUNC(SYSDATE)))
                      AND   di.customer_id       = pbw.customer_id
                      AND   di.agreement_id      = pbw.agreement_id
                      AND   di.project_id        = pbw.project_id
                      AND (
                            ( 'INV_ALL'           = p_inv_filter)
                            OR ( 'INV_APPRO'         = p_inv_filter AND di.approved_by_person_id IS NOT NULL
                                                                    AND di.released_date IS NULL)
                            OR ( 'INV_CREDITS'       = p_inv_filter AND di.draft_invoice_num_credited IS NOT NULL )
                            OR ( 'INV_RETN_BILL_INV' = p_inv_filter AND NVL(di.retention_invoice_flag,'N') = 'Y' )
                            OR ( 'INV_UNAPPRO'       = p_inv_filter AND di.approved_by_person_id IS NULL )
                            OR ( 'INV_RELEASE'       = p_inv_filter AND di.transfer_status_code = 'P'
                                                                   AND di.released_date IS NOT NULL )
                            OR ( 'INV_ACCEPT'        = p_inv_filter AND di.transfer_status_code = 'A'
                                                                   AND NVL(di.generation_error_flag,'N') <> 'Y' )
                            OR ( 'INV_REJECT'        = p_inv_filter AND (di.transfer_status_code = 'X'
                                                                   OR   di.transfer_status_code = 'R')
                                                                   AND NVL(di.generation_error_flag,'N') <> 'Y' )
                            OR ( 'INV_ERROR'         = p_inv_filter AND NVL(di.generation_error_flag,'N') = 'Y' )
                          )
                      GROUP BY di.project_id,di.customer_id,di.agreement_id);


	/**
 	*  Updating  Project due amount (accepted) and project functional due amount (accepted)
 	*            Project tax amount, tax due amount and project functional tax amount tax due amount
	**/
	/* Modified the below query completely for the Bug 8249757 includes the fix of bug 7394622 - Start */
	UPDATE pa_bill_wrkbench_inv_temp pbw
	/* added group function SUM to Ar amounts,modifed query to calculate billing amounts for bug 7628408 */
	SET (pbw.pc_due_accepted,pbw.pfc_due_accepted, pbw.pc_tax, pbw.pfc_tax, pbw.pc_tax_due, pbw.pfc_tax_due ) =
                     ( SELECT
                           SUM(( pa_inv.pc_inv_amt /Nvl(pa_ar.line_amt_orig,1)) * Nvl(pa_ar.line_amt_remn,1))  due_accepted_pc,
                           SUM(( pa_inv.pfc_inv_amt /Nvl(pa_ar.line_amt_orig,1)) * Nvl(pa_ar.line_amt_remn,1)) due_accepted_pfc,
                           SUM(( pa_inv.pc_inv_amt /Nvl(pa_ar.line_amt_orig,1)) * Nvl(pa_ar.tax_orig,0))       tax_pc,
                           SUM(( pa_inv.pfc_inv_amt /Nvl(pa_ar.line_amt_orig,1)) * Nvl(pa_ar.tax_orig,0))      tax_pfc,
                           SUM(( pa_inv.pc_inv_amt /Nvl(pa_ar.line_amt_orig,1)) * Nvl(pa_ar.tax_remn,0))       tax_due_pc,
                           SUM(( pa_inv.pfc_inv_amt /Nvl(pa_ar.line_amt_orig,1)) * Nvl(pa_ar.tax_remn,0))      tax_due_pfc
                        FROM
                                (SELECT  arps.customer_trx_id, arps.trx_number,
                                           Nvl(SUM(arps.amount_line_items_original),1) line_amt_orig,
                                           Nvl(SUM(arps.amount_line_items_remaining),1)line_amt_remn,
                                           Nvl(SUM(arps.tax_original),0)               tax_orig,
                                           Nvl(SUM(arps.tax_remaining),0)              tax_remn
                                   FROM    ar_payment_schedules_all arps
                                   GROUP BY arps.customer_trx_id, arps.trx_number
                                ) pa_ar,
                                (SELECT di.project_id,
                                        di.customer_id,
                                        di.agreement_id,
                                        di.ra_invoice_number,
                                        di.system_reference system_reference,
                                        SUM(dii.project_bill_amount) pc_inv_amt,
                                        SUM(dii.projfunc_bill_amount) pfc_inv_amt
                                 FROM  pa_draft_invoices_all di,
                                       pa_draft_invoice_items dii,
                                       PA_BILL_WRKBENCH_INV_TEMP pbwi
                                 WHERE di.project_id                              =  dii.project_id
                                       AND di.draft_invoice_num                   =  dii.draft_invoice_num
                                       AND di.agreement_id                        = NVL(p_agreement_id,di.agreement_id)
                                       AND di.draft_invoice_num                   = NVL(p_draft_num,di.draft_invoice_num)
                                       AND UPPER(NVL(di.ra_invoice_number,'-99')) = UPPER(NVL(p_ar_number,NVL(di.ra_invoice_number,'-99')))
                                       AND NVL(TRUNC(di.creation_date),TRUNC(SYSDATE)) BETWEEN
                                             NVL(LTRIM(RTRIM(p_creation_frm_date)),NVL(TRUNC(di.creation_date),TRUNC(SYSDATE)))
                                          AND NVL(LTRIM(RTRIM(p_creation_to_date)),NVL(TRUNC(di.creation_date),TRUNC(SYSDATE)))
                                       AND NVL(TRUNC(di.invoice_date),TRUNC(SYSDATE)) BETWEEN
                                             NVL(LTRIM(RTRIM(p_invoice_frm_date)),NVL(TRUNC(di.invoice_date),TRUNC(SYSDATE)))
                                          AND NVL(LTRIM(RTRIM(p_invoice_to_date)),NVL(TRUNC(di.invoice_date),TRUNC(SYSDATE)))
                                       AND NVL(TRUNC(di.gl_date),TRUNC(SYSDATE)) BETWEEN
                                             NVL(LTRIM(RTRIM(p_gl_frm_date)),NVL(TRUNC(di.gl_date),TRUNC(SYSDATE)))
                                          AND NVL(LTRIM(RTRIM(p_gl_to_date)),NVL(TRUNC(di.gl_date),TRUNC(SYSDATE)))
                                       AND di.transfer_status_code = 'A'
                                       AND di.customer_id          = pbwi.customer_id
                                       AND di.agreement_id         = pbwi.agreement_id
                                       AND di.project_id           = pbwi.project_id
                                       AND di.system_reference IS NOT NULL
                                       AND (
                                             ( 'INV_ALL'           = p_inv_filter)
                                             OR ( 'INV_APPRO'         = p_inv_filter
                                                 AND di.approved_by_person_id IS NOT NULL
                                                 AND di.released_date IS NULL)
                                             OR ( 'INV_CREDITS'       = p_inv_filter
                                                 AND di.draft_invoice_num_credited IS NOT NULL )
                                             OR ( 'INV_RETN_BILL_INV' = p_inv_filter
                                                 AND NVL(di.retention_invoice_flag,'N') = 'Y' )
                                             OR ( 'INV_UNAPPRO'       = p_inv_filter
                                                 AND di.approved_by_person_id IS NULL )
                                             OR ( 'INV_RELEASE'       = p_inv_filter
                                                 AND di.transfer_status_code = 'P'
                                                 AND di.released_date IS NOT NULL )
                                             OR ( 'INV_ACCEPT'        = p_inv_filter
                                                 AND di.transfer_status_code = 'A'
                                                 AND NVL(di.generation_error_flag,'N') <> 'Y' )
                                             OR ( 'INV_REJECT'        = p_inv_filter
                                                 AND (di.transfer_status_code = 'X'
                                                     OR   di.transfer_status_code = 'R')
                                                 AND NVL(di.generation_error_flag,'N') <> 'Y' )
                                             OR ( 'INV_ERROR'         = p_inv_filter
                                                 AND NVL(di.generation_error_flag,'N') = 'Y' )
                                           )
                                       GROUP BY di.project_id,di.customer_id,di.agreement_id, di.ra_invoice_number,
                                                 di.system_reference) pa_inv
                        WHERE pa_inv.project_id       = pbw.project_id
                        AND   pa_inv.customer_id      = pbw.customer_id
                        AND   pa_inv.agreement_id     = pbw.agreement_id
                        AND pa_inv.system_reference   = pa_ar.customer_trx_id(+)
                        AND pa_inv.ra_invoice_number = pa_ar.trx_number(+)
                        AND pa_ar.line_amt_orig(+) <> 0   /* Condition added for bug 5230465 */
                        GROUP BY pa_inv.project_id, pa_inv.customer_id,pa_inv.agreement_id);
	/* Modified the query completely for the Bug 8249757 includes the fix of bug 7394622 - End */

	UPDATE pa_bill_wrkbench_inv_temp pbw
	SET (pbw.pc_due_pending,pbw.pfc_due_pending ) =
                  ( SELECT
                         SUM(dii.project_bill_amount) ,
                         SUM(dii.projfunc_bill_amount)
                    FROM  pa_draft_invoices_all di,
                          pa_draft_invoice_items dii
                    WHERE di.project_id                        =  dii.project_id
                    AND di.draft_invoice_num                   =  dii.draft_invoice_num
                    AND di.agreement_id                        = NVL(p_agreement_id,di.agreement_id)
                    AND di.draft_invoice_num                   = NVL(p_draft_num,di.draft_invoice_num)
                    AND UPPER(NVL(di.ra_invoice_number,'-99')) = UPPER(NVL(p_ar_number,NVL(di.ra_invoice_number,'-99')))
                    AND NVL(TRUNC(di.creation_date),TRUNC(SYSDATE)) BETWEEN
                          NVL(LTRIM(RTRIM(p_creation_frm_date)),NVL(TRUNC(di.creation_date),TRUNC(SYSDATE)))
                       AND NVL(LTRIM(RTRIM(p_creation_to_date)),NVL(TRUNC(di.creation_date),TRUNC(SYSDATE)))
                    AND NVL(TRUNC(di.invoice_date),TRUNC(SYSDATE)) BETWEEN
                          NVL(LTRIM(RTRIM(p_invoice_frm_date)),NVL(TRUNC(di.invoice_date),TRUNC(SYSDATE)))
                       AND NVL(LTRIM(RTRIM(p_invoice_to_date)),NVL(TRUNC(di.invoice_date),TRUNC(SYSDATE)))
                    AND NVL(TRUNC(di.gl_date),TRUNC(SYSDATE)) BETWEEN
                          NVL(LTRIM(RTRIM(p_gl_frm_date)),NVL(TRUNC(di.gl_date),TRUNC(SYSDATE)))
                       AND NVL(LTRIM(RTRIM(p_gl_to_date)),NVL(TRUNC(di.gl_date),TRUNC(SYSDATE)))
                    AND di.transfer_status_code <> 'A'
                    AND di.customer_id           = pbw.customer_id
                    AND di.agreement_id          = pbw.agreement_id
                    AND di.project_id            = pbw.project_id
                    AND di.system_reference IS NULL
                    AND (
                          ( 'INV_ALL'             = p_inv_filter)
                          OR ( 'INV_APPRO'         = p_inv_filter
                              AND di.approved_by_person_id IS NOT NULL
                              AND di.released_date IS NULL)
                          OR ( 'INV_CREDITS'       = p_inv_filter
                              AND di.draft_invoice_num_credited IS NOT NULL )
                          OR ( 'INV_RETN_BILL_INV' = p_inv_filter
                              AND NVL(di.retention_invoice_flag,'N') = 'Y' )
                          OR ( 'INV_UNAPPRO'       = p_inv_filter
                              AND di.approved_by_person_id IS NULL )
                          OR ( 'INV_RELEASE'       = p_inv_filter
                              AND di.transfer_status_code = 'P'
                              AND di.released_date IS NOT NULL )
                          OR ( 'INV_ACCEPT'        = p_inv_filter
                              AND di.transfer_status_code = 'A'
                              AND NVL(di.generation_error_flag,'N') <> 'Y' )
                          OR ( 'INV_REJECT'        = p_inv_filter
                              AND (di.transfer_status_code = 'X'
                                  OR   di.transfer_status_code = 'R')
                              AND NVL(di.generation_error_flag,'N') <> 'Y' )
                          OR ( 'INV_ERROR'         = p_inv_filter
                              AND NVL(di.generation_error_flag,'N') = 'Y' )
                        )
                     GROUP BY di.project_id,di.customer_id,di.agreement_id);

   END IF;

/**
* If there is no rows in this table then inserting null row so that
* temp table should not return null pointer exception
**/

INSERT
INTO pa_bill_wrkbench_inv_temp(
     PROJECT_ID
    ,AGREEMENT_ID
    ,CUSTOMER_ID
    ,CUSTOMER_NAME
    ,PC_FUNDING
    ,PC_INVOICED
    ,PC_DUE_ACCEPTED
    ,PC_DUE_PENDING
    ,PC_TAX
    ,PC_TAX_DUE
    ,PFC_FUNDING
    ,PFC_INVOICED
    ,PFC_DUE_ACCEPTED
    ,PFC_DUE_PENDING
    ,PFC_TAX
    ,PFC_TAX_DUE)
    SELECT
            p_project_id
           ,-1
           ,-1
           ,NULL
           ,NULL
           ,NULL
           ,NULL
           ,NULL
           ,NULL
           ,NULL
           ,NULL
           ,NULL
           ,NULL
           ,NULL
           ,NULL
           ,NULL
    FROM
           dual
    WHERE  NOT EXISTS( SELECT 'x'
                       FROM pa_bill_wrkbench_inv_temp a
                       WHERE  a.project_id = p_project_id);



EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_BILLING_WORKBENCH_BILL_PKG'
                            ,p_procedure_name => 'Populat_Inv_Summ_by_Cust_RN' );
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       x_msg_count := 1;
       x_msg_data  := SUBSTR(SQLERRM,1,30);
       RAISE;
END Populat_Inv_Summ_by_Cust_RN;





--
-- Procedure            : Get_Due_Amount
-- Purpose              : This procedure will get all the parameters for Billing Region for the given project.
-- Parameters           :
--

FUNCTION Get_Due_Amount (
                                            p_project_id                  IN     NUMBER DEFAULT NULL,
                                            p_draft_inv_num               IN     NUMBER DEFAULT NULL,
                                            p_system_reference            IN     NUMBER ,
                                            p_transfer_status_code        IN     VARCHAR2 ,
                                            p_calling_mode                IN     VARCHAR2 ,
                                            p_inv_amount                  IN     NUMBER DEFAULT NULL,
                                            p_proj_bill_amount            IN     NUMBER DEFAULT NULL,
                                            p_projfunc_bill_amount        IN     NUMBER DEFAULT NULL
                                      )  RETURN NUMBER
IS

BEGIN

  IF (p_transfer_status_code = 'A') THEN

     IF  ( NVL(G_system_reference,-99) <> p_system_reference ) THEN
       BEGIN
          SELECT
                SUM(ar.amount_line_items_remaining + ar.tax_remaining)
          INTO  G_ar_amount
          FROM   ar_payment_schedules_all ar
          WHERE  p_system_reference IS NOT NULL
          AND    p_transfer_status_code = 'A'
          AND    ar.customer_trx_id =    p_system_reference;
       EXCEPTION
          WHEN OTHERS THEN
           RAISE;
       END;

       G_system_reference := p_system_reference;
     END IF;

     IF  ( p_calling_mode = 'TRANS' ) THEN
       RETURN (G_ar_amount);
     ELSIF (p_inv_amount = 0 ) THEN     /*   condition added     */
       RETURN (0);                      /*   to fix bug 5230465  */
     ELSIF ( p_calling_mode = 'PFC' ) THEN
       RETURN ( (p_projfunc_bill_amount/p_inv_amount) * G_ar_amount);
     ELSIF ( p_calling_mode = 'PC' ) THEN
       RETURN ( (p_proj_bill_amount/p_inv_amount) * G_ar_amount);
     END IF;

  END IF;


EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_BILLING_WORKBENCH_BILL_PKG'
                            ,p_procedure_name => 'Get_Due_Amount' );
       RAISE;

END Get_Due_Amount;


FUNCTION Get_tax_Amount (
                                            p_project_id                  IN     NUMBER DEFAULT NULL,
                                            p_draft_inv_num               IN     NUMBER DEFAULT NULL,
                                            p_system_reference            IN     NUMBER ,
                                            p_transfer_status_code        IN     VARCHAR2 ,
                                            p_calling_mode                IN     VARCHAR2 ,
                                            p_inv_amount                  IN     NUMBER DEFAULT NULL,
                                            p_proj_bill_amount            IN     NUMBER DEFAULT NULL,
                                            p_projfunc_bill_amount        IN     NUMBER DEFAULT NULL
                                      )  RETURN NUMBER
IS

  l_tax_amount  number;

BEGIN

  IF (p_transfer_status_code = 'A') THEN

       BEGIN
          SELECT
                SUM(ar.tax_original)
          INTO  l_tax_amount
          FROM   ar_payment_schedules_all ar
          WHERE  p_system_reference IS NOT NULL
          AND    p_transfer_status_code = 'A'
          AND    ar.customer_trx_id =    p_system_reference;
       EXCEPTION
          WHEN OTHERS THEN
           RAISE;
       END;


     IF  ( p_calling_mode = 'TRANS' ) THEN
       RETURN (l_tax_amount);
     ELSIF (p_inv_amount = 0 ) THEN     /*   condition added     */
       RETURN (0);                      /*   to fix bug 5230465  */
     ELSIF ( p_calling_mode = 'PFC' ) THEN
       RETURN ( (p_projfunc_bill_amount/p_inv_amount) * l_tax_amount);
     ELSIF ( p_calling_mode = 'PC' ) THEN
       RETURN ( (p_proj_bill_amount/p_inv_amount) * l_tax_amount);
     END IF;

  END IF;


EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_BILLING_WORKBENCH_BILL_PKG'
                            ,p_procedure_name => 'Get_Tax_Amount' );
       RAISE;

END Get_tax_Amount;

-- Added for bug 4932118
-- Procedure            : PROJECT_UBR_UER_CONVERT
-- Purpose              : This procedure will convert UBR/UER amounts
--                        in Projfunc curr to project curr for MCB
--                        projects while revtrans curr is different from
--                        Projfunc currency.
-- Parameters           : P_PROJECT_ID - Input Project Id
--                        X_PROJECT_CURR_UBR - UBR amount in Project currency
--                        X_PROJECT_CURR_UER - UER amount in Project currency
--                        X_RETURN_STATUS_ - Return status of the API
--                        X_MSG_COUNT  - Count of error messages
--                        X_MSG_DATA  - Actual message data
--

Procedure PROJECT_UBR_UER_CONVERT (
				      P_PROJECT_ID       IN         NUMBER,
				      X_PROJECT_CURR_UBR OUT NOCOPY NUMBER,
				      X_PROJECT_CURR_UER OUT NOCOPY NUMBER,
				      X_RETURN_STATUS	 OUT NOCOPY VARCHAR,
				      X_MSG_COUNT        OUT NOCOPY NUMBER,
				      X_MSG_DATA         OUT NOCOPY VARCHAR	)
Is
        l_mcb_flag_tab  PA_PLSQL_DATATYPES.Char1TabTyp ;
        l_prj_currency_code_tab PA_PLSQL_DATATYPES.Char30TabTyp;
        l_projfunc_currency_code_tab PA_PLSQL_DATATYPES.Char30TabTyp;
        l_prj_rate_type_tab PA_PLSQL_DATATYPES.Char30TabTyp;
        l_prj_rate_date_tab PA_PLSQL_DATATYPES.DateTabTyp;
        l_prj_exch_rate_tab PA_PLSQL_DATATYPES.NumTabTyp;
        l_ubr_dr_tab  PA_PLSQL_DATATYPES.NumTabTyp;
        l_uer_cr_tab PA_PLSQL_DATATYPES.NumTabTyp;
        l_project_ubr_dr_tab  PA_PLSQL_DATATYPES.NumTabTyp;
        l_project_uer_cr_tab PA_PLSQL_DATATYPES.NumTabTyp;
	l_conversion_between varchar(30);
	l_user_validate_flag_tab PA_PLSQL_DATATYPES.Char30TabTyp ;
	l_cache_flag  varchar(1);
	l_project_denominator_tab PA_PLSQL_DATATYPES.NumTabTyp;
	l_project_numerator_tab PA_PLSQL_DATATYPES.NumTabTyp;
	l_prj_status_tab PA_PLSQL_DATATYPES.Char30TabTyp ;
Begin
       X_Return_Status := FND_API.G_RET_STS_SUCCESS;

       --FND_MSG_PUB.initialize;

       SELECT
	MULTI_CURRENCY_BILLING_FLAG,
	PROJFUNC_CURRENCY_CODE,
	PROJECT_CURRENCY_CODE,
	PROJECT_BIL_RATE_TYPE,
	PROJECT_BIL_RATE_DATE,
	PROJECT_BIL_EXCHANGE_RATE,
	UNBILLED_RECEIVABLE_DR,
	UNEARNED_REVENUE_CR
       INTO
        l_mcb_flag_tab(1),
        l_projfunc_currency_code_tab(1),
        l_prj_currency_code_tab(1),
        l_prj_rate_type_tab(1),
        l_prj_rate_date_tab(1),
        l_prj_exch_rate_tab(1),
        l_ubr_dr_tab(1),
        l_uer_cr_tab(1)
       FROM PA_PROJECTS_ALL
       WHERE PROJECT_ID = P_PROJECT_ID;
     l_user_validate_flag_tab(1) := 'N';
     l_prj_status_tab(1) := 'N';

     IF l_mcb_flag_tab(1) = 'Y' AND l_projfunc_currency_code_tab(1) <> l_prj_currency_code_tab(1) Then
        /* Call PA_MULTI_CURRENCY_BILLING.convert_amount_bulk to convert from ubr/uer
           amount in project functional currency to project currency. */
        l_conversion_between := 'PFC_PC';
           PA_MULTI_CURRENCY_BILLING.convert_amount_bulk(
                    p_from_currency_tab        => l_projfunc_currency_code_tab,
                    p_to_currency_tab          => l_prj_currency_code_tab,
                    p_conversion_date_tab      => L_prj_rate_date_tab,
                    p_conversion_type_tab      => L_prj_rate_type_tab,
                    p_amount_tab               => l_ubr_dr_tab,
                    p_user_validate_flag_tab   => l_user_validate_flag_tab,
                    p_converted_amount_tab     => l_project_ubr_dr_tab,
                    p_denominator_tab          => l_project_denominator_tab,
                    p_numerator_tab            => l_project_numerator_tab,
                    p_rate_tab                 => l_prj_exch_rate_tab,
                    p_conversion_between       => l_conversion_between,
                    p_cache_flag               => l_cache_flag,
                    x_status_tab               => l_prj_status_tab
                    );
    /* Copy if the API call is successful */
       IF l_prj_status_tab(1) = 'N' Then
        X_PROJECT_CURR_UBR := l_project_ubr_dr_tab(1);
       ELSE
	x_msg_count  := 1;
        X_MSG_DATA   := l_prj_status_tab(1);
       End If;

        l_conversion_between := 'PFC_PC';
        l_prj_status_tab(1) := 'N';
           PA_MULTI_CURRENCY_BILLING.convert_amount_bulk(
                    p_from_currency_tab        => l_projfunc_currency_code_tab,
                    p_to_currency_tab          => l_prj_currency_code_tab,
                    p_conversion_date_tab      => L_prj_rate_date_tab,
                    p_conversion_type_tab      => L_prj_rate_type_tab,
                    p_amount_tab               => l_uer_cr_tab,
                    p_user_validate_flag_tab   => l_user_validate_flag_tab,
                    p_converted_amount_tab     => l_project_uer_cr_tab,
                    p_denominator_tab          => l_project_denominator_tab,
                    p_numerator_tab            => l_project_numerator_tab,
                    p_rate_tab                 => l_prj_exch_rate_tab,
                    p_conversion_between       => l_conversion_between,
                    p_cache_flag               => l_cache_flag,
                    x_status_tab               => l_prj_status_tab
                    );
    /* Copy if the API call is successful */
       IF l_prj_status_tab(1) = 'N' Then
        X_PROJECT_CURR_UER := l_project_uer_cr_tab(1);
       ELSE
        x_msg_count  := 1;
        X_MSG_DATA   := l_prj_status_tab(1);
       End If;

    Else
        X_Project_CURR_UBR := l_ubr_dr_tab(1);
        X_Project_CURR_UER := l_uer_cr_tab(1);
    End If;
    /* Handle Exceptions */
EXCEPTION
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_BILLING_WORKBENCH_BILL_PKG'
                     ,p_procedure_name  => 'PROJECT_UBR_UER_CONVERT');
     Raise;

End PROJECT_UBR_UER_CONVERT;
END PA_BILLING_WORKBENCH_BILL_PKG;


/
