--------------------------------------------------------
--  DDL for Package Body PA_MC_BILLING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_MC_BILLING_PVT" AS
/* $Header: PAMCPVTB.pls 120.5 2005/10/04 17:39:19 skannoji noship $ */


   PROCEDURE get_budget_amount(
             p_project_id               IN    NUMBER,
             p_task_id                  IN    NUMBER,
             p_psob_id                  IN    NUMBER,
             p_rsob_id                  IN    NUMBER,
             p_billing_extension_id     IN    NUMBER,
             p_cost_budget_type_code    IN    VARCHAR2 DEFAULT NULL,
             p_rev_budget_type_code     IN    VARCHAR2 DEFAULT NULL,
             x_revenue_amount           OUT   NOCOPY NUMBER,
             x_cost_amount              OUT   NOCOPY NUMBER,
             x_cost_budget_type_code    OUT   NOCOPY VARCHAR2,
             x_rev_budget_type_code     OUT   NOCOPY VARCHAR2,
             x_return_status            OUT   NOCOPY VARCHAR2,
             x_msg_count                OUT   NOCOPY NUMBER,
             x_msg_data                 OUT   NOCOPY VARCHAR2)
IS


l_cost_budget_type_code      VARCHAR2(30) ;
l_rev_budget_type_code       VARCHAR2(30) ;

l_check_code                 VARCHAR2(1) ;

l_cost_budget_version_id     NUMBER ;
l_rev_budget_version_id      NUMBER ;
l_task_id                    NUMBER ;
l_raw_cost_total             NUMBER ;
l_burdened_cost_total        NUMBER ;
l_revenue_total              NUMBER ;

invalid_cost_budget_code     EXCEPTION ;
invalid_rev_budget_code      EXCEPTION ;
rev_budget_not_baselined     EXCEPTION ;
cost_budget_not_baselined    EXCEPTION ;


l_return_status              VARCHAR2(30);
l_msg_count                  NUMBER ;
l_msg_data                   VARCHAR2(240);


BEGIN


   /* -----------------------------------------------------------
      Initialize the Output Variables
      ----------------------------------------------------------- */

     l_return_status    := FND_API.G_RET_STS_SUCCESS;
     l_msg_count        := 0;

     l_raw_cost_total       := NULL;
     l_burdened_cost_total  := NULL;
     l_revenue_total        := NULL;




   /* ---------------------------------------------------------
      Assigning the Input to the local variables
      ---------------------------------------------------------

     l_task_id    := p_task_id;



    /* ----------------------------------------------------------------------
       Get the Cost and Revenue Budget Type code from pa_billing_extensions
       ---------------------------------------------------------------------- */

     l_cost_budget_type_code  := P_cost_budget_type_code ;
     l_rev_budget_type_code   := P_rev_budget_type_code  ;


    IF (P_cost_budget_type_code IS NULL OR P_rev_budget_type_code IS NULL) THEN

         SELECT decode(P_cost_budget_type_code,NULL,default_cost_budget_type_code, P_cost_budget_type_code),
                decode(P_rev_budget_type_code,NULL,default_rev_budget_type_code,
                P_rev_budget_type_code)
           INTO l_cost_budget_type_code,
                l_rev_budget_type_code
           FROM pa_billing_extensions
          WHERE billing_extension_id= p_billing_Extension_Id;

   END IF;



   /* -----------------------------------------------------------------------
      Checking for the Cost budget type code is a valid and the correct amount
      code, If it is not a valid code then Raise the exception
      ----------------------------------------------------------------------- */


    BEGIN

      SELECT  'x'
      INTO    l_check_code
      FROM    pa_budget_types
      WHERE   budget_type_code = l_cost_budget_type_code
      AND     budget_amount_code = 'C';

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
           RAISE invalid_cost_budget_code;
    END;




   /* --------------------------------------------------------------------------
      Checking for the Revenue budget type code is a valid and the correct amount
      code, If it is not a valid code then Raise the exception
      -------------------------------------------------------------------------- */


    BEGIN

      SELECT  'x'
      INTO    l_check_code
      FROM    pa_budget_types
      WHERE   budget_type_code = l_rev_budget_type_code
      AND     budget_amount_code = 'R';

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RAISE invalid_rev_budget_code;
    END ;





  /* ----------------------------------------------------------------
     Get the budget version id for cost budget
     ---------------------------------------------------------------- */

   BEGIN

     SELECT budget_version_id
     INTO   l_cost_budget_version_id
     FROM   pa_budget_versions pbv
     WHERE  project_id = p_project_id
     AND    budget_type_code = l_cost_budget_type_code
     AND    budget_status_code = 'B'
     AND    current_flag = 'Y';

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
          RAISE cost_budget_not_baselined;

   END;


  /* ----------------------------------------------------------------
     Get the budget version id for revenue budget
     ---------------------------------------------------------------- */


   BEGIN

     SELECT budget_version_id
     INTO   l_rev_budget_version_id
     FROM   pa_budget_versions pbv
     WHERE  project_id = p_project_id
     AND    budget_type_code = l_rev_budget_type_code
     AND    budget_status_code = 'B'
     AND    current_flag = 'Y';

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
          RAISE rev_budget_not_baselined;
   END;



   /* -------------------------------------------------------------------------
      Calling the API to get the cost budget amount in reporting currency
      ------------------------------------------------------------------------- */


   pa_mc_billing_pvt.get_project_task_budget_amount
                           (p_budget_version_id       =>  l_cost_budget_version_id ,
                            p_project_id              =>  p_project_id ,
                            p_task_id                 =>  p_task_id ,
                            p_psob_id                 =>  p_psob_id ,
                            p_rsob_id                 =>  p_rsob_id ,
                            x_raw_cost_total          =>  l_raw_cost_total ,
                            x_burdened_cost_total     =>  l_burdened_cost_total ,
                            x_revenue_total           =>  l_revenue_total ,
                            x_return_status           =>  l_return_status ,
                            x_msg_count               =>  l_msg_count ,
                            x_msg_data                =>  l_msg_data );


    /* ------------------------------------------------------------
       Copy the value of cost budget amount to the OUTPUT valiable
       ------------------------------------------------------------ */


    x_cost_amount := pa_currency.round_currency_amt(l_burdened_cost_total);




   /* -------------------------------------------------------------------------
      Calling the API to get the Revenue budget amount in reporting currency
      ------------------------------------------------------------------------- */


   pa_mc_billing_pvt.get_project_task_budget_amount
                           (p_budget_version_id       =>  l_rev_budget_version_id ,
                            p_project_id              =>  p_project_id ,
                            p_task_id                 =>  p_task_id ,
                            p_psob_id                 =>  p_psob_id ,
                            p_rsob_id                 =>  p_rsob_id ,
                            x_raw_cost_total          =>  l_raw_cost_total ,
                            x_burdened_cost_total     =>  l_burdened_cost_total ,
                            x_revenue_total           =>  l_revenue_total ,
                            x_return_status           =>  l_return_status ,
                            x_msg_count               =>  l_msg_count ,
                            x_msg_data                =>  l_msg_data );




    /* ----------------------------------------------------------------
       Copy the value of revenue budget amount and budget type code into
       the OUTPUT variables.
       --------------------------------------------------------------- */

    x_revenue_amount := pa_currency.round_currency_amt(l_revenue_total);
    x_cost_budget_type_code := l_cost_budget_type_code;
    x_rev_budget_type_code  := l_rev_budget_type_code;
    x_return_status	   := l_return_status;
    x_msg_count            := l_msg_count;



   EXCEPTION

     WHEN invalid_cost_budget_code THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_msg_count     := 1;
          x_msg_data      := 'INVALID_COST_BUDGET_TYPE';
          FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_MC_BILLING_PVT',
                               p_procedure_name   => 'get_budget_amount');

     WHEN invalid_rev_budget_code  THEN

          x_return_status := FND_API.G_RET_STS_ERROR;
          x_msg_count     := 1;
          x_msg_data      := 'INVALID_REV_BUDGET_TYPE';
          FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_MC_BILLING_PVT',
                               p_procedure_name   => 'get_budget_amount');

     WHEN rev_budget_not_baselined  THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_msg_count     := 1;
          x_msg_data      := 'REV_BUDGET_NOT_BASELINED';
          FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_MC_BILLING_PVT',
                               p_procedure_name   => 'get_budget_amount');

     WHEN cost_budget_not_baselined THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_msg_count     := 1;
          x_msg_data      := 'COST_BUDGET_NOT_BASELINED';
          FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_MC_BILLING_PVT',
                               p_procedure_name   => 'get_budget_amount');

     WHEN OTHERS THEN
          x_msg_count     := 1;
          x_msg_data      := SUBSTR(SQLERRM, 1, 240);
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

          FND_MSG_PUB.add_Exc_msg(
                  p_pkg_name         => 'PA_MC_BILLING_PVT',
                  p_procedure_name   => 'get_budget_amount');

          RAISE ;

END get_budget_amount;




PROCEDURE get_project_task_budget_amount(
             p_budget_version_id        IN       NUMBER,
             p_project_id               IN       NUMBER,
             p_task_id                  IN       NUMBER,
             p_psob_id                  IN       NUMBER,
             p_rsob_id                  IN       NUMBER,
             x_raw_cost_total           IN OUT   NOCOPY NUMBER,
             x_burdened_cost_total      IN OUT  NOCOPY  NUMBER,
             x_revenue_total            IN OUT   NOCOPY NUMBER,
             x_return_status            OUT      NOCOPY VARCHAR2,
             x_msg_count                OUT      NOCOPY NUMBER,
             x_msg_data                 OUT      NOCOPY VARCHAR2)

IS


  /* -----------------------------------------------------------------------------
   How to use this API:
   This API can be used to get the total cost and revenue budget amount in reporting
   currency for Project Level or at the task level. If Input task_id is passed
   as a null value then project level totals are fetched. Otherwise task level totals
   are fetched. For task level totals, first the task level is determined.
   If the task level is top or intermediate level , then the amounts
   are rolled from the child tasks.
   ------------------------------------------------------------------------------ */

  CURSOR csr_rollup IS
    SELECT 'P'
      FROM dual
     WHERE  p_task_id is null
   UNION
    SELECT 'T'
      FROM pa_tasks
     WHERE p_task_id is not null
       AND   task_id = p_task_id
       AND   parent_task_id is null
   UNION
    SELECT 'M'
      FROM pa_tasks
     WHERE p_task_id is not null
       AND task_id = p_task_id
       AND parent_task_id is not null
       AND exists (select 'X'
                     from pa_tasks
                    where parent_task_id = p_task_id)
   UNION
    SELECt 'L'
      FROM dual
     WHERE p_task_id is not null
       AND not exists (select 'X'
                         from pa_tasks
                        where parent_task_id = p_task_id);



l_rollup_level            VARCHAR2(1);

l_raw_cost_total          NUMBER;
l_burdened_cost_total     NUMBER;
l_revenue_total           NUMBER;

l_msg_count		NUMBER;
l_return_status		VARCHAR2(30);
BEGIN


   /* -----------------------------------------------------------
      Initialize the Output Variables
      ----------------------------------------------------------- */

     l_return_status    := FND_API.G_RET_STS_SUCCESS;
     l_msg_count        := 0;



    /* -------------------------------------------------------------------------
       Cursor : To get the Rollup level, The Values are
       Project(P)  or  Top Task(T)  or  Middle Task(M)  or  Low level Task(L)
       ------------------------------------------------------------------------- */


      OPEN csr_rollup;

      FETCH csr_rollup
       INTO l_rollup_level;

      CLOSE csr_rollup;



    /* ------------------------------------------------------------------------
       Get the Cost and Revenue budget amount - Depends upon the Rollup level,
       different SELECT for get the amount.
       ------------------------------------------------------------------------ */


      /* Project Level Task */
      IF  (l_rollup_level = 'P') THEN
        NULL;
        /* Commented out for MRC migration to SLA
               SELECT SUM(NVL(mcbl.raw_cost,0)),
                 SUM(NVL(mcbl.burdened_cost,0)),
                 SUM(NVL(mcbl.revenue,0))
            INTO l_raw_cost_total,
                 l_burdened_cost_total,
                 l_revenue_total
            FROM pa_mc_budget_lines mcbl, pa_budget_lines bl,
                 pa_resource_assignments a
           WHERE bl.budget_line_id = mcbl.budget_line_id
             AND a.budget_version_id = p_budget_version_id
             AND a.project_id = p_project_id
             AND a.resource_assignment_id = bl.resource_assignment_id
             AND mcbl.set_of_books_id = p_rsob_id
             ;

       */
      /* Top Task Level */
      ELSIF (l_rollup_level = 'T') THEN
          NULL;
          /* Commented out for MRC migration to SLA
          SELECT SUM(NVL(mcbl.raw_cost,0)),
                 SUM(NVL(mcbl.burdened_cosT,0)),
                 SUM(NVL(mcbl.revenue,0))
            INTO l_raw_cost_total,
                 l_burdened_cost_total,
                 l_revenue_total
            FROM pa_tasks t, pa_mc_budget_lines mcbl , pa_budget_lines bl,
                 pa_resource_assignments a
           WHERE bl.budget_line_id = mcbl.budget_line_id
             AND a.budget_version_id = p_budget_version_id
             AND a.task_id = t.task_id
             AND t.top_task_id  = p_task_id
             AND a.resource_assignment_id = bl.resource_assignment_id
             AND mcbl.set_of_books_id = p_rsob_id
             ;

*/
       ELSIF (l_rollup_level = 'M') THEN          /* Middle Level Task */
        NULL;
        /* Commented out for MRC migration to SLA
          SELECT SUM(NVL(mcbl.raw_cost,0)),
                 SUM(NVL(mcbl.burdened_cost,0)),
                 SUM(NVL(mcbl.revenue,0))
            INTO l_raw_cost_total,
                 l_burdened_cost_total,
                 l_revenue_total
            FROM pa_mc_budget_lines mcbl, pa_budget_lines bl,
                 pa_resource_assignments a
           WHERE bl.budget_line_id = mcbl.budget_line_id
             AND a.budget_version_id = p_budget_version_id
             AND a.task_id in (SELECT task_id
                                 FROM pa_tasks
                                START with task_id = p_task_id
                              CONNECT by prior task_id = parent_task_id)
             AND a.resource_assignment_id = bl.resource_assignment_id
             AND mcbl.set_of_books_id = p_rsob_id
             ;
         */
       ELSIF (l_rollup_level = 'L') THEN          /* Low Level Task */

        NULL;
        /* Commented out for MRC migration to SLA
          SELECT SUM(NVL(mcbl.raw_cost,0)),
                 SUM(NVL(mcbl.burdened_cost,0)),
                 SUM(NVL(mcbl.revenue,0))
            INTO l_raw_cost_total,
                 l_burdened_cost_total,
                 l_revenue_total
            FROM pa_mc_budget_lines mcbl, pa_budget_lines bl,
                 pa_resource_assignments a
           WHERE bl.budget_line_id = mcbl.budget_line_id
             AND a.budget_version_id = p_budget_version_id
             AND a.task_id = p_task_id
             AND a.resource_assignment_id = bl.resource_assignment_id
             AND mcbl.set_of_books_id = p_rsob_id
              ;
           */
       END IF;


     /* ---------------------------------------------------------
        Assign the Revenue and cost budget amount to the Output
        --------------------------------------------------------- */


         x_raw_cost_total        :=  l_raw_cost_total ;
         x_burdened_cost_total   :=  l_burdened_cost_total ;
         x_revenue_total         :=  l_revenue_total ;
	 x_return_status	 :=  l_return_status;
	 x_msg_count		 :=  l_msg_count;


  EXCEPTION
     WHEN OTHERS THEN
          x_msg_count     := 1;
          x_msg_data      := SUBSTR(SQLERRM, 1, 240);
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

          FND_MSG_PUB.add_Exc_msg(
                  p_pkg_name         => 'PA_MC_BILLING_PVT',
                  p_procedure_name   => 'get_budget_amount');

          RAISE ;

END get_project_task_budget_amount ;



PROCEDURE get_cost_amount(
             p_project_id               IN    NUMBER ,
             p_task_id                  IN    NUMBER ,
             p_psob_id                  IN    NUMBER ,
             p_rsob_id                  IN    NUMBER ,
             p_accrue_through_date      IN    DATE ,
             x_cost_amount              OUT   NOCOPY NUMBER ,
             x_return_status            OUT   NOCOPY VARCHAR2 ,
             x_msg_count                OUT   NOCOPY NUMBER ,
             x_msg_data                 OUT   NOCOPY VARCHAR2)
IS

l_cost_amount        NUMBER;
l_return_status		VARCHAR2(30);
l_msg_count		NUMBER;


BEGIN


   /* -----------------------------------------------------------
      Initialize the Output Variables
      ----------------------------------------------------------- */

     l_return_status    := FND_API.G_RET_STS_SUCCESS;
     l_msg_count        := 0;



    /* -----------------------------------------------------------------
       Get the Cost amount for the sepcific Reporting currency and based
       on the PA date and accrue throug date.
       ----------------------------------------------------------------- */


        NULL;
    /* Commented out for MRC migration to SLA
      SELECT SUM(NVL(mccdl.burdened_cost, NVL(mccdl.amount,0)))
      INTO l_cost_amount
      FROM pa_cost_distribution_lines_all cdl,
           pa_mc_cost_dist_lines_all mccdl,
           pa_tasks t, pa_periods pp
     WHERE cdl.project_id   = t.project_id
       AND t.project_id     = p_project_id
       AND nvl(cdl.task_id, -1) = nvl(t.task_id, -1)
       AND nvl(t.task_id, -1) = nvl(p_task_id, nvl(t.task_id, -1))
       AND mccdl.expenditure_item_id = cdl.expenditure_item_id
       AND mccdl.line_num  = cdl.line_num
       AND ( cdl.pa_date BETWEEN pp.start_date AND pp.end_date)
       AND (trunc(NVL(p_accrue_through_date, SYSDATE)) >= TRUNC(pp.start_date)) -- BUG#3118592
       AND cdl.line_type = 'R'
       AND mccdl.set_of_books_id = p_rsob_id ;
    */

    /* ---------------------------------------------------
       Assign the value to the OUTPUT variables
       --------------------------------------------------- */

      x_cost_amount := l_cost_amount ;
      x_return_status := l_return_status;
      x_msg_count     := l_msg_count;


   EXCEPTION
     WHEN OTHERS THEN
          x_msg_count     := 1;
          x_msg_data      := SUBSTR(SQLERRM, 1, 240);
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

          FND_MSG_PUB.add_Exc_msg(
                  p_pkg_name         => 'PA_MC_BILLING_PVT',
                  p_procedure_name   => 'get_cost_amount');
          RAISE ;


END get_cost_amount;




PROCEDURE get_pot_event_amount(
             p_project_id               IN    NUMBER,
             p_task_id                  IN    NUMBER,
             p_psob_id                  IN    NUMBER,
             p_rsob_id                  IN    NUMBER,
             p_event_id                 IN    NUMBER,
             p_accrue_through_date      IN    DATE,
             x_event_amount             OUT   NOCOPY NUMBER,
             x_return_status            OUT   NOCOPY VARCHAR2,
             x_msg_count                OUT   NOCOPY NUMBER,
             x_msg_data                 OUT   NOCOPY VARCHAR2)
IS


l_mc_revenue_amount          NUMBER;
l_return_status		     VARCHAR2(30);
l_msg_count		     NUMBER;

BEGIN


   /* -----------------------------------------------------------
      Initialize the Output Variables
      ----------------------------------------------------------- */

     l_return_status     := FND_API.G_RET_STS_SUCCESS;
     l_msg_count         := 0;
     l_mc_revenue_amount := 0;


  /* ----------------------------------------------------------------
     Get the Revenue event in reporting currency. Ignore the current
     processing event.
     ---------------------------------------------------------------- */


        NULL;
    /* Commented out for MRC migration to SLA
     SELECT SUM((DECODE(et.event_type_classification, 'WRITE OFF',-1 * NVL(mcevt.revenue_amount,0),
             NVL(mcevt.revenue_amount,0))))
       INTO  l_mc_revenue_amount
       FROM  pa_events e,
             pa_mc_events mcevt,
             pa_event_types et
      WHERE  e.event_type = et.event_type
        AND  e.project_id = p_project_id
        AND  nvl(e.task_id,-1) = nvl(p_task_id, nvl(e.task_id,-1))
        AND  e.event_id  = mcevt.event_id
        AND  e.event_id <> NVL(p_event_id, -1)
        AND  mcevt.set_of_books_id = p_rsob_id
        AND  TRUNC(e.completion_date) <= TRUNC(nvl(p_accrue_through_date, sysdate))
        */

     /* -------------------------------------------------------
        Copy the value into the OUTPUT parameter
        ------------------------------------------------------- */

       x_event_amount  :=  l_mc_revenue_amount ;
       x_return_status := l_return_status;
       x_msg_count     := l_msg_count;

   EXCEPTION
     WHEN OTHERS THEN
          x_msg_count     := 1;
          x_msg_data      := SUBSTR(SQLERRM, 1, 240);
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

          FND_MSG_PUB.add_Exc_msg(
                  p_pkg_name         => 'PA_MC_BILLING_PVT',
                  p_procedure_name   => 'get_pot_event_amount');
          RAISE ;


END get_pot_event_amount;




PROCEDURE get_Lowest_amount_left(
             p_project_id               IN    NUMBER,
             p_task_id                  IN    NUMBER,
             p_psob_id                  IN    NUMBER,
             p_rsob_id                  IN    NUMBER,
             p_event_id                 IN    NUMBER,
             x_funding_amount           OUT   NOCOPY  NUMBER,
             x_return_status            OUT   NOCOPY VARCHAR2,
             x_msg_count                OUT   NOCOPY NUMBER,
             x_msg_data                 OUT   NOCOPY VARCHAR2)
IS


l_mc_current_revenue        NUMBER;
l_lowest_revenue_amount     NUMBER;

l_Enable_Top_Task_Cust_Flag VARCHAR2(1);

l_return_status	VARCHAR2(30);
l_msg_count 	NUMBER;
l_msg_data	VARCHAR2(2000);

BEGIN


-- Following changes are made for FP_M : Top Task customer changes
-- If the Project is implemented with Top Task Customer flag enabled, then
-- assign 'Y' value to the variable l_Enable_Top_Task_Cust_Flag
l_Enable_Top_Task_Cust_Flag := PA_Billing_Pub.Get_Top_Task_Customer_Flag(P_Project_ID );

   /* -----------------------------------------------------------
      Initialize the Output Variables
      ----------------------------------------------------------- */

     l_return_status     := FND_API.G_RET_STS_SUCCESS;
     l_msg_count         := 0;


   /* -----------------------------------------------------------------
      Get the event revenue amount in reporting currency for calculate
      the avaialbe funding amount
      ----------------------------------------------------------------- */
        NULL;
    /* Commented out for MRC migration to SLA
     SELECT SUM(DECODE(e.revenue_distributed_flag,'N', NVL(mcevt.revenue_amount,0),0)) revenue_amount
       INTO l_mc_current_revenue
       FROM pa_events e, pa_mc_events mcevt, pa_event_types et
      WHERE e.project_id = p_project_id
        AND nvl(e.task_id,-1) = nvl(p_task_id, nvl(e.task_id,-1))
        AND e.event_id  = mcevt.event_id
        AND e.event_id  <> NVL(p_event_id, -1)
        AND mcevt.set_of_books_id = p_rsob_id
        AND e.event_type = et.event_type
        AND et.event_type_classification||'' = 'AUTOMATIC';
        */

   -- Following IF clause is added for FP_M changes
   -- If the project is implemented with Top Task Customer enabled then the lowest
   -- amount left is calculated as the total baselined fundings less the
   -- total accrued amount
   If l_Enable_Top_Task_Cust_Flag = 'Y' then
        NULL;
    /* Commented out for MRC migration to SLA
      SELECT SUM(NVL(mcspf.total_baselined_amount,0) -
             NVL(mcspf.total_accrued_amount,0))
--	INTO x_Funding_Amount
	INTO l_lowest_revenue_amount
	FROM pa_summary_project_fundings spf,
	pa_mc_sum_proj_fundings mcspf,
	pa_agreements_all a
	WHERE a.agreement_id = spf.agreement_id
	AND spf.task_id = p_task_id
	AND spf.project_id = p_project_id
	AND a.revenue_limit_flag  =  'Y'
	AND mcspf.set_of_books_id = p_rsob_id;
        */
   Else
        NULL;
    /* Commented out for MRC migration to SLA
      SELECT MIN(SUM(NVL(mcspf.total_baselined_amount,0)
               - NVL(mcspf.total_accrued_amount,0))
                   * (100/pc.customer_bill_split) )
       INTO l_lowest_revenue_amount
       FROM pa_summary_project_fundings spf,
            pa_mc_sum_proj_fundings mcspf,
            pa_agreements_all a,
            pa_projects p,
            pa_project_customers pc
      WHERE a.agreement_id = spf.agreement_id
        AND p.project_id = spf.project_id
        AND a.customer_id = pc.customer_id
        AND pc.project_id = p.project_id
        AND nvl(spf.task_id,-1) = nvl(p_task_id,-1)
        AND spf.project_id = p_project_id
        AND a.revenue_limit_flag  =  'Y'
        AND mcspf.project_id = spf.project_id
        AND nvl(mcspf.task_id,-1) = nvl(spf.task_id,-1)
        AND mcspf.agreement_id = spf.agreement_id
        AND mcspf.set_of_books_id = p_rsob_id
      GROUP BY pc.customer_id, pc.customer_bill_split;
      */
   End IF;

   x_funding_amount := GREATEST((nvl(l_lowest_revenue_amount,999999999999)
                         - nvl(l_mc_current_revenue,0)),0);

   x_return_status  := l_return_status;
   x_msg_count      := l_msg_count;

   EXCEPTION
     WHEN OTHERS THEN
          x_msg_count     := 1;
          x_msg_data      := SUBSTR(SQLERRM, 1, 240);
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

          FND_MSG_PUB.add_Exc_msg(
                  p_pkg_name         => 'PA_MC_BILLING_PVT',
                  p_procedure_name   => 'get_Lowest_amount_left');
          RAISE ;

END get_Lowest_amount_left;


PROCEDURE get_revenue_amount(
             p_project_id               IN    NUMBER,
             p_task_id                  IN    NUMBER,
             p_psob_id                  IN    NUMBER,
             p_rsob_id                  IN    NUMBER,
             p_event_id                 IN    NUMBER,
             x_revenue_amount           OUT NOCOPY   NUMBER,
             x_return_status            OUT NOCOPY  VARCHAR2,
             x_msg_count                OUT NOCOPY  NUMBER,
             x_msg_data                 OUT NOCOPY  VARCHAR2)
IS



l_mc_revenue_amount          NUMBER;
l_erdl_accrued_amount        NUMBER;
l_rdl_accrued_amount         NUMBER;

l_return_status             VARCHAR2(30);
l_msg_count		    NUMBER;

BEGIN


   /* -----------------------------------------------------------
      Initialize the Output Variables
      ----------------------------------------------------------- */

     l_return_status     := FND_API.G_RET_STS_SUCCESS;
     l_msg_count         := 0;

    /* ---------------------------------------------------------------------
       Get the Event Revenue amount for the pending revenue for the
       specific Reporting set of book id., Ignore to process the current
       processing event.
       --------------------------------------------------------------------- */


        NULL;
    /* Commented out for MRC migration to SLA
        SELECT  SUM(NVL(mcevt.revenue_amount,0)) revenue_amount
          INTO  l_mc_revenue_amount
          FROM  pa_events e, pa_mc_events mcevt,
                pa_billing_assignments bea,
                pa_billing_extensions be
         WHERE  be.billing_extension_id = bea.billing_extension_id
           AND  e.project_id = p_project_id
           AND  nvl(e.task_id,-1) = nvl(p_task_id, nvl(e.task_id, -1))
           AND  e.event_id  = mcevt.event_id
           AND  e.event_id <> nvl(p_event_id, -1)
           AND  mcevt.set_of_books_id = p_rsob_id
           AND  bea.billing_assignment_id = e.billing_assignment_id
           AND  be.procedure_name = 'pa_billing.ccrev'
           AND  e.revenue_distributed_flag||'' = 'N';
           */



    /* ---------------------------------------------------------------------
       Get the Revenue amount for the specific Reporting currency from the
       pa_mc_cust_event_rdl_all table
       --------------------------------------------------------------------- */


        NULL;
    /* Commented out for MRC migration to SLA
        SELECT sum(nvl(mcerdl.amount,0))
          INTO l_erdl_accrued_amount
          FROM pa_draft_revenue_items dri, pa_mc_cust_event_rdl_all  mcerdl,
               pa_events e, pa_billing_assignments bea,
               pa_billing_extensions be
         WHERE dri.project_id = p_project_id
           AND NVL(dri.task_id,-1) = NVL(p_task_id, nvl(dri.task_id, -1))
           AND mcerdl.project_id = dri.project_id
           AND NVL(mcerdl.task_id, -1) = NVL(dri.task_id, -1)
           AND mcerdl.draft_revenue_num = dri.draft_revenue_num
           AND mcerdl.line_num = dri.line_num
           AND mcerdl.set_of_books_id  = p_rsob_id
           AND e.project_id = mcerdl.project_id
           AND nvl(e.task_id,-1) = nvl(mcerdl.task_id, -1)
           AND e.event_num = mcerdl.event_num
           AND be.billing_extension_id = bea.billing_extension_id
           AND bea.billing_assignment_id = e.billing_assignment_id
           AND be.procedure_name = 'pa_billing.ccrev';   */    /* Check with SS for this ccrev join */


    /* ---------------------------------------------------------------------
       Get the Revenue amount for the specific Reporting currency from the
       pa_mc_cust_rdl_all table
       --------------------------------------------------------------------- */

        NULL;
    /* Commented out for MRC migration to SLA
        SELECT sum(nvl(mcrdl.amount,0))
          INTO l_rdl_accrued_amount
          FROM pa_draft_revenue_items dri, pa_mc_cust_rdl_all  mcrdl
         WHERE dri.project_id = p_project_id
           AND NVL(dri.task_id,-1) = nvl(p_task_id, nvl(dri.task_id, -1))
           AND mcrdl.project_id = dri.project_id
           AND mcrdl.draft_revenue_num = dri.draft_revenue_num
           AND mcrdl.line_num = dri.line_num
           AND mcrdl.set_of_books_id  = p_rsob_id
           AND dri.revenue_source like 'Expenditure%' ;  */
           /* Check with SS for revenue source condition */



    /* -------------------------------------------------------------------------
       Get the sum of the Pending revenue amount (MC events) and accured revenue
       in reporting currency from RDL and ERDL table.
       ------------------------------------------------------------------------- */


      /* dbms_output.put_line('Event Revenue   ............ : ' || l_mc_revenue_amount);
         dbms_output.put_line('ERDL  Revenue   ............ : ' || l_erdl_accrued_amount);
         dbms_output.put_line('RDL   Revenue   ............ : ' || l_rdl_accrued_amount );
       */


       x_revenue_amount  :=  NVL(l_mc_revenue_amount,0)  + NVL(l_erdl_accrued_amount,0) +
                             NVL(l_rdl_accrued_amount,0) ;

	x_return_status  := l_return_status;
	x_msg_count      := l_msg_count;

   EXCEPTION
     WHEN OTHERS THEN
          x_msg_count     := 1;
          x_msg_data      := SUBSTR(SQLERRM, 1, 240);
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

          FND_MSG_PUB.add_Exc_msg(
                  p_pkg_name         => 'PA_MC_BILLING_PVT',
                  p_procedure_name   => 'get_revenue_amount');
          RAISE ;

END get_revenue_amount;


END pa_mc_billing_pvt;

/
