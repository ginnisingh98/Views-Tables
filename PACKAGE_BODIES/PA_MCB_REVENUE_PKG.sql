--------------------------------------------------------
--  DDL for Package Body PA_MCB_REVENUE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_MCB_REVENUE_PKG" AS
--$Header: PAXMCRUB.pls 120.8 2007/12/28 12:00:24 hkansal ship $

/*----------------------------------------------------------------------------------------+
|   Procedure  :   event_amount_conversion                                                |
|   Purpose    :   To update the pa_events table (bill transaction currency to            |
|                  revenue processing currency                                            |
|   Parameters :                                                                          |
|     ==================================================================================  |
|     Name               Mode    Description                                              |
|     ==================================================================================  |
|     p_project_id        IN      project Id                                              |
|     p_request_id        IN      Id for the current Run                                  |
|     p_event_type        IN      Type of events - to identify the AUTOMATIC events and   |
|                                 other events                                            |
|     p_calling_place     IN                                                              |
|     acc_thru_date       IN      Input parameter given in When we Generate revenue       |
|     p_project_rate_date IN      Project Rate date                                       |
      p_projfunc_rate_dateIN      Project Functional Rate date                            |
|     x_return_status     IN OUT  Return status of this procedure                         |
|     x_msg_count         IN OUT  Error message count                                     |
|     x_msg_data          IN OUT  Error message                                           |
|     ==================================================================================  |
+----------------------------------------------------------------------------------------*/

/* Funding Revaluation Changes : Added the realized gain and loss event type */

  g1_debug_mode varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
/* Fix for bug 5907315 starts here */
    gl_pa_dt_st	PA_PLSQL_DATATYPES.DateTabTyp;
  gl_pa_dt_end  PA_PLSQL_DATATYPES.DateTabTyp;

FUNCTION pa_date(p_date	IN DATE) RETURN DATE IS
l_start_date	DATE;
l_end_date	DATE;
l_cnt		NUMBER;
BEGIN
	l_cnt	:= gl_pa_dt_st.COUNT;
	FOR I IN 1..l_cnt
	LOOP
		IF (p_date between gl_pa_dt_st(I) and gl_pa_dt_end(I)) THEN
			RETURN(gl_pa_dt_end(I));
		END IF;
	END LOOP;

	SELECT	start_date,end_date
	INTO	l_start_date,l_end_date
	FROM	pa_periods
	WHERE	p_date between start_date and end_date;

	l_cnt := l_cnt+1;

	gl_pa_dt_st(l_cnt):= l_start_date;
	gl_pa_dt_end(l_cnt):= l_end_date;
	RETURN(l_end_date);

END;
/* Fix for bug 5907315 ends here */


PROCEDURE event_amount_conversion(
            p_project_id         IN       NUMBER,
            p_request_id         IN       NUMBER,
            p_event_type         IN       VARCHAR2,
            p_calling_place      IN       VARCHAR2,
            p_acc_thru_dt        IN       DATE,
            p_project_rate_date  IN       DATE,
            p_projfunc_rate_date IN       DATE,
            x_return_status      IN OUT NOCOPY   VARCHAR2,
            x_msg_count          IN OUT NOCOPY   NUMBER,
            x_msg_data           IN OUT NOCOPY   VARCHAR2) IS


    CURSOR csr_events(p_project_id     NUMBER,
                      p_request_id     NUMBER,
                      p_event_type     VARCHAR2,
                      p_calling_place  VARCHAR2,
                      p_acc_thru_dt    DATE ) IS
    SELECT event_id,
           bill_trans_currency_code,
           bill_trans_rev_amount,
           project_currency_code,
           project_rate_type,
           project_rate_date,
           project_exchange_rate,
           projfunc_currency_code,
           projfunc_rate_type,
           projfunc_rate_date,
           projfunc_exchange_rate,
           revproc_currency_code,
           revproc_rate_type,
           revproc_rate_date,
           revproc_exchange_rate,
           'N'                                                /* Bug 2563738 */
     FROM  pa_events  v
    WHERE  v.project_id   =  p_project_id
      AND  v.request_id   =  p_request_id
      AND  v. revenue_distributed_flag = 'D'
      AND  nvl(v.task_id, -1) IN
           (SELECT decode(v.task_id, null, -1, t.task_id )
              FROM pa_tasks t
             WHERE t.project_id = p_project_id
               AND t.ready_to_distribute_flag ||'' = 'Y'
            )
      AND  TRUNC(v.completion_date) <= TRUNC(NVL(p_acc_thru_dt,sysdate))   /* Bug#3118592 */
      AND (DECODE(NVL(v.bill_trans_rev_amount, 0), 0 ,
               DECODE(NVL(v.zero_revenue_amount_flag, 'N'), 'Y', 1, 0),1) = 1)
      AND  v.calling_place =  p_calling_place
      AND  EXISTS
           (SELECT vt.event_type
              FROM pa_event_types vt
             WHERE vt.event_type = v.event_type
               AND vt.event_type_classification||''= 'AUTOMATIC'
            )
      AND  ( v.calling_process||'' = 'Revenue'
            OR ( v.calling_process||'' = 'Invoice'
            AND EXISTS
               (SELECT 'Invoice is released'
                  FROM pa_draft_invoice_items drii,
                       pa_draft_invoices dri
                 WHERE drii.project_id = p_project_id
                   AND  nvl(drii.event_task_id, -1) = nvl( v.task_id, -1)
                   AND  drii.event_num = v.event_num
                   AND  dri.project_id = drii.project_id
                   AND  dri.draft_invoice_num = drii.draft_invoice_num
                   AND  dri.released_date is not null
                  )))
         AND p_event_type = 'AUTOMATIC'
  UNION
    SELECT event_id,
           bill_trans_currency_code,
           bill_trans_rev_amount,
           project_currency_code,
           project_rate_type,
           project_rate_date,
           project_exchange_rate,
           projfunc_currency_code,
           projfunc_rate_type,
           projfunc_rate_date,
           projfunc_exchange_rate,
           revproc_currency_code,
           revproc_rate_type,
           revproc_rate_date,
           revproc_exchange_rate,
           DECODE(vt.event_type_classification , 'REALIZED_GAINS', 'Y',
                                                 'REALIZED_LOSSES', 'Y','N')
        FROM  pa_events  evt,
              pa_event_types vt
       WHERE  evt.project_id   =  p_project_id
         AND  evt.request_id   =  p_request_id
         AND  evt.revenue_distributed_flag = 'D'
         AND  TRUNC(evt.completion_date) <= TRUNC(NVL(p_acc_thru_dt,sysdate)) /* Bug#3118592 */
         AND (DECODE(NVL(evt.bill_trans_rev_amount, 0), 0 ,
                           DECODE(NVL(evt.zero_revenue_amount_flag, 'N'), 'Y', 1, 0),1) = 1)
         AND  vt.event_type = evt.event_type ||''
         AND  vt.event_type_classification ||'' IN
                       ('WRITE ON','WRITE OFF','MANUAL','REALIZED_GAINS','REALIZED_LOSSES')
         AND EXISTS ( SELECT 'ready to distribute top task exists'
                        FROM  pa_tasks tsk
                       WHERE  tsk.project_id = p_project_id
                         AND  tsk.task_id = NVL( evt.task_id, tsk.task_id )
                         AND  tsk.ready_to_distribute_flag ||'' = 'Y'
                    )
        /* AND EXISTS ( SELECT 'Write on or Write off or Manual events exists'
                        FROM  pa_event_types vt
                       WHERE  vt.event_type = evt.event_type ||''
                         AND  vt.event_type_classification ||'' IN
                              ('WRITE ON','WRITE OFF','MANUAL','REALIZED_GAINS','REALIZED_LOSSES')
                      ) */
           AND  p_event_type = 'MANUAL';


      l_event_id_tab                   PA_PLSQL_DATATYPES.IdTabTyp;
      l_bill_trans_curr_code_tab       PA_PLSQL_DATATYPES.Char30TabTyp;
      l_bill_trans_rev_amount_tab      PA_PLSQL_DATATYPES.NumTabTyp;
      l_project_curr_code_tab          PA_PLSQL_DATATYPES.Char30TabTyp;
      l_project_rate_type_tab          PA_PLSQL_DATATYPES.Char30TabTyp;
      l_project_rate_date_tab          PA_PLSQL_DATATYPES.DateTabTyp;
      l_project_exchange_rate_tab      PA_PLSQL_DATATYPES.NumTabTyp;
      l_project_amount_tab             PA_PLSQL_DATATYPES.NumTabTyp;
      l_project_denominator_tab        PA_PLSQL_DATATYPES.NumTabTyp;
      l_project_numerator_tab          PA_PLSQL_DATATYPES.NumTabTyp;
      l_projfunc_curr_code_tab         PA_PLSQL_DATATYPES.Char30TabTyp;
      l_projfunc_rate_type_tab         PA_PLSQL_DATATYPES.Char30TabTyp;
      l_projfunc_rate_date_tab         PA_PLSQL_DATATYPES.DateTabTyp;
      l_projfunc_exchange_rate_tab     PA_PLSQL_DATATYPES.NumTabTyp;
      l_projfunc_amount_tab            PA_PLSQL_DATATYPES.NumTabTyp;
      l_projfunc_denominator_tab       PA_PLSQL_DATATYPES.NumTabTyp;
      l_projfunc_numerator_tab         PA_PLSQL_DATATYPES.NumTabTyp;
      l_revproc_curr_code_tab          PA_PLSQL_DATATYPES.Char30TabTyp;
      l_revproc_rate_type_tab          PA_PLSQL_DATATYPES.Char30TabTyp;
      l_revproc_rate_date_tab          PA_PLSQL_DATATYPES.DateTabTyp;
      l_revproc_exchange_rate_tab      PA_PLSQL_DATATYPES.NumTabTyp;
      l_revproc_amount_tab             PA_PLSQL_DATATYPES.NumTabTyp;
      l_revproc_denominator_tab        PA_PLSQL_DATATYPES.NumTabTyp;
      l_revproc_numerator_tab          PA_PLSQL_DATATYPES.NumTabTyp;
      l_project_status_tab             PA_PLSQL_DATATYPES.Char30TabTyp;
      l_projfunc_status_tab            PA_PLSQL_DATATYPES.Char30TabTyp;
      l_revproc_status_tab             PA_PLSQL_DATATYPES.Char30TabTyp;
      l_user_validate_flag_tab         PA_PLSQL_DATATYPES.Char30TabTyp;

      l_conversion_between             VARCHAR2(6);
      l_cache_flag                     VARCHAR2(1);


      l_currency_flag                  VARCHAR2(1):= 'N';

      l_Rgain_Rloss_flag               PA_PLSQL_DATATYPES.Char30TabTyp;

  BEGIN


        /* This flag is N then the convert_amount_bulk API not cache any currency code,
           If the flag is Y then it cache the currency and other attributes for avoid the
           repeat processing. */

        l_cache_flag   := 'N';


        IF g1_debug_mode  = 'Y' THEN
        	PA_MCB_INVOICE_PKG.log_message('... Enter the procedure Event_amount_Conversion');
        	PA_MCB_INVOICE_PKG.log_message('event_amount_conversion: ' || '-----------------------------------------------');
        END IF;


          OPEN csr_events(p_project_id,
                          p_request_id,
                          p_event_type,
                          p_calling_place,
                          p_acc_thru_dt
                         );


     LOOP

/*
 *    Clear all PL/SQL table.
 */

      l_event_id_tab.delete;
      l_bill_trans_curr_code_tab.delete;
      l_bill_trans_rev_amount_tab.delete;
      l_project_curr_code_tab.delete;
      l_project_rate_type_tab.delete;
      l_project_rate_date_tab.delete;
      l_project_exchange_rate_tab.delete;
      l_project_amount_tab.delete;
      l_project_denominator_tab.delete;
      l_project_numerator_tab.delete;
      l_projfunc_curr_code_tab.delete;
      l_projfunc_rate_type_tab.delete;
      l_projfunc_rate_date_tab.delete;
      l_projfunc_exchange_rate_tab.delete;
      l_projfunc_amount_tab.delete;
      l_projfunc_denominator_tab.delete;
      l_projfunc_numerator_tab.delete;
      l_revproc_curr_code_tab.delete;
      l_revproc_rate_type_tab.delete;
      l_revproc_rate_date_tab.delete;
      l_revproc_exchange_rate_tab.delete;
      l_revproc_amount_tab.delete;
      l_revproc_denominator_tab.delete;
      l_revproc_numerator_tab.delete;
      l_project_status_tab.delete;
      l_projfunc_status_tab.delete;
      l_revproc_status_tab.delete;
      l_user_validate_flag_tab.delete;
      l_Rgain_Rloss_flag.delete;


    /* Fetch the Convert Attributes and amount for Event */

     FETCH csr_events BULK  COLLECT
      INTO l_event_id_tab,
           l_bill_trans_curr_code_tab,
           l_bill_trans_rev_amount_tab,
           l_project_curr_code_tab,
           l_project_rate_type_tab,
           l_project_rate_date_tab,
           l_project_exchange_rate_tab,
           l_projfunc_curr_code_tab,
           l_projfunc_rate_type_tab,
           l_projfunc_rate_date_tab,
           l_projfunc_exchange_rate_tab,
           l_revproc_curr_code_tab,
           l_revproc_rate_type_tab,
           l_revproc_rate_date_tab,
           l_revproc_exchange_rate_tab,
           l_Rgain_Rloss_flag   LIMIT 100;


    /* If any events fetched from table then proceding for conversion */




    IF (l_event_id_tab.COUNT = 0) THEN

        Exit;

    ELSE

        /* Checking for Project Fuunctional and Project Currencies are same
           If both currencies are same then convert only Project Functional currency
           copy the Project functional amount and attributes to Project */


         l_currency_flag := 'N';

         IF  (l_projfunc_curr_code_tab(1) = l_project_curr_code_tab(1)) THEN

              l_currency_flag := 'Y';

         END IF;


         IF g1_debug_mode  = 'Y' THEN
         	PA_MCB_INVOICE_PKG.log_message('event_amount_conversion: ' || 'Project and Proj Func currencies are same : ' || l_currency_flag);
         END IF;


        /* Initialize the array variables */


         FOR I in 1 .. l_event_id_tab.COUNT
         LOOP

              l_project_amount_tab(I)       := NULL;
              l_projfunc_amount_tab(I)      := NULL;
              l_revproc_amount_tab(I)       := NULL;
              l_project_denominator_tab(I)  := NULL;
              l_project_numerator_tab(I)    := NULL;
              l_projfunc_denominator_tab(I) := NULL;
              l_projfunc_numerator_tab(I)   := NULL;
              l_revproc_denominator_tab(I)  := NULL;
              l_revproc_numerator_tab(I)    := NULL;
              l_project_status_tab(I)       := NULL;
              l_projfunc_status_tab(I)      := NULL;
              l_revproc_status_tab(I)       := NULL;
              l_user_validate_flag_tab(I)   := 'Y';


          /* If project rate date is null in events table then take the project rate date from
             pa_projects_all table(p_project_rate_date from pa_projects_all table) */


              IF  l_project_rate_date_tab(I) IS NULL THEN

                  l_project_rate_date_tab(I) := p_project_rate_date;

              END IF;


          /* If projfunc rate date is null in events table then take the functional rate date from
             pa_projects_all table(p_projfunc_rate_date  from pa_projects_all table) */


              IF  l_projfunc_rate_date_tab(I) IS NULL THEN

                  l_projfunc_rate_date_tab(I) := p_projfunc_rate_date;

              END IF;



          END LOOP;




    /* Converting Bill Transaction amount to Project Functional amount */

      IF g1_debug_mode  = 'Y' THEN
      	PA_MCB_INVOICE_PKG.log_message('event_amount_conversion: ' || 'Converting the Bill trans amount to project functional amount');
      END IF;

           /* Passing the param (two currency code) to the convert_amount_bulk API, If any conversion fails
              then the API concate the code with error message */

              l_conversion_between  := 'BTC_PF';


           PA_MULTI_CURRENCY_BILLING.convert_amount_bulk(
                    p_from_currency_tab        => l_bill_trans_curr_code_tab,
                    p_to_currency_tab          => l_projfunc_curr_code_tab,
                    p_conversion_date_tab      => l_projfunc_rate_date_tab,
                    p_conversion_type_tab      => l_projfunc_rate_type_tab,
                    p_amount_tab               => l_bill_trans_rev_amount_tab,
                    p_user_validate_flag_tab   => l_user_validate_flag_tab,
                    p_converted_amount_tab     => l_projfunc_amount_tab,
                    p_denominator_tab          => l_projfunc_denominator_tab,
                    p_numerator_tab            => l_projfunc_numerator_tab,
                    p_rate_tab                 => l_projfunc_exchange_rate_tab,
                    p_conversion_between       => l_conversion_between,
                    p_cache_flag               => l_cache_flag,
                    x_status_tab               => l_projfunc_status_tab
                    );




    /* Converting Bill Transaction amount to Project Currency amount */

      IF g1_debug_mode  = 'Y' THEN
      	PA_MCB_INVOICE_PKG.log_message('event_amount_conversion: ' || 'Convert the Bill trans amount to project amount');
      END IF;


    /* Passing the param (two currency code) to the convert_amount_bulk API, If any conversion fails
       then the API concate the code with error message */

    /* If project and Project Functional both are same then copy the PF attributes to Project other
       Wise convert the project amount */


        IF (l_currency_flag <> 'Y')  THEN

           l_conversion_between  := 'BTC_PC';

           PA_MULTI_CURRENCY_BILLING.convert_amount_bulk(
                    p_from_currency_tab        => l_bill_trans_curr_code_tab,
                    p_to_currency_tab          => l_project_curr_code_tab,
                    p_conversion_date_tab      => l_project_rate_date_tab,
                    p_conversion_type_tab      => l_project_rate_type_tab,
                    p_amount_tab               => l_bill_trans_rev_amount_tab,
                    p_user_validate_flag_tab   => l_user_validate_flag_tab,
                    p_converted_amount_tab     => l_project_amount_tab,
                    p_denominator_tab          => l_project_denominator_tab,
                    p_numerator_tab            => l_project_numerator_tab,
                    p_rate_tab                 => l_project_exchange_rate_tab,
                    p_conversion_between       => l_conversion_between,
                    p_cache_flag               => l_cache_flag,
                    x_status_tab               => l_project_status_tab
                    );


        END IF;

        -- Log Messages for Events Converted Amounts

        IF g1_debug_mode  = 'Y' THEN
        	PA_MCB_INVOICE_PKG.log_message('event_amount_conversion: ' || 'Project Id  : ' || p_project_id);
        END IF;

        FOR i IN 1..l_event_id_tab.COUNT LOOP


             /* If both Project and Proj Func are same then copy the Proj func attributes to project */

               IF l_currency_flag  = 'Y' THEN

                    l_project_curr_code_tab(i)     := l_projfunc_curr_code_tab(i);
                    l_project_rate_type_tab(i)     := l_projfunc_rate_type_tab(i);
                    l_project_rate_date_tab(i)     := l_projfunc_rate_date_tab(i);
                    l_project_exchange_rate_tab(i) := l_projfunc_exchange_rate_tab(i);
                    l_project_amount_tab(i)        := l_projfunc_amount_tab(i);
                    l_project_status_tab(i)        := l_projfunc_status_tab(i);

               END IF;



              /* If revenue processing currency and project functional currency both are same then
                 copy the project functional attributes to revenue processing attributes */

              /* Bug : 2563738 - Change the logic for Revenue processing and project function check
                 in the IF loop and project and reveproc check in the else loop */


               IF (l_revproc_curr_code_tab(i) = l_projfunc_curr_code_tab(i)) THEN

                    l_revproc_curr_code_tab(I)     := l_projfunc_curr_code_tab(i);
                    l_revproc_rate_type_tab(I)     := l_projfunc_rate_type_tab(i);
                    l_revproc_rate_date_tab(I)     := l_projfunc_rate_date_tab(i);
                    l_revproc_exchange_rate_tab(I) := l_projfunc_exchange_rate_tab(i);
                    l_revproc_amount_tab(I)        := l_projfunc_amount_tab(i);


                 /* If revenue processing currency and project currency both are same then
                 copy the project currency attributes to revenue processing attributes */


             ELSIF (l_revproc_curr_code_tab(i) = l_project_curr_code_tab(i)) THEN


                    l_revproc_curr_code_tab(I)     := l_project_curr_code_tab(i);
                    l_revproc_rate_type_tab(I)     := l_project_rate_type_tab(i);
                    l_revproc_rate_date_tab(I)     := l_project_rate_date_tab(i);
                    l_revproc_exchange_rate_tab(I) := l_project_exchange_rate_tab(i);
                    l_revproc_amount_tab(I)        := l_project_amount_tab(i);


             END IF;

	     /* Added for Bug 5372663 */
	     IF l_projfunc_status_tab(i) <> 'N'  THEN
                      x_msg_data := l_projfunc_status_tab(i);

              ELSIF l_project_status_tab(i) <> 'N' THEN
                       x_msg_data := l_project_status_tab(i);

              END IF;
	      /* End of changes for Bug 5372663 */




          /* Bug#2563738 : If event type realized gain and realized loss then
             we are not conversting, so making the value as zero for the project amount,
             and project attributes are null  */


            IF  (l_Rgain_Rloss_flag(i) = 'Y') THEN

                  l_project_rate_type_tab(i)     := null;
                  l_project_rate_date_tab(i)     := null;
                  l_project_exchange_rate_tab(i) := null;
                  l_project_amount_tab(i)        := 0;
                  l_project_status_tab(i)        := 'N';

            END IF;


           IF g1_debug_mode  = 'Y' THEN
           	PA_MCB_INVOICE_PKG.log_message('event_amount_conversion: ' || 'Event Id :' || l_event_id_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('event_amount_conversion: ' || 'Bill Trans Currency Code :' || l_bill_trans_curr_code_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('event_amount_conversion: ' || 'Input Bill Trans Amount :' || l_bill_trans_rev_amount_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('event_amount_conversion: ' || 'Project Currency Code :' || l_project_curr_code_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('event_amount_conversion: ' || 'Project rate type :' || l_project_rate_type_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('event_amount_conversion: ' || 'Project Exchange rate :' || l_project_exchange_rate_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('event_amount_conversion: ' || 'Project Rate date :' || l_project_rate_date_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('event_amount_conversion: ' || 'Convert Project Amount :' || l_project_amount_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('event_amount_conversion: ' || 'Project Rejection Reason :' || l_project_status_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('event_amount_conversion: ' || 'Convert Project Func Amount :' || l_projfunc_amount_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('event_amount_conversion: ' || 'ProjFunc Curr Code :' || l_projfunc_curr_code_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('event_amount_conversion: ' || 'ProjFunc rate type :' || l_projfunc_rate_type_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('event_amount_conversion: ' || 'ProjFunc Exchange rate :' || l_projfunc_exchange_rate_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('event_amount_conversion: ' || 'ProjFunc Rate date :' || l_projfunc_rate_date_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('event_amount_conversion: ' || 'ProjFunc Amt Rejection Reason :' || l_projfunc_status_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('event_amount_conversion: ' || 'Convert RevProc Amount :' || l_revproc_amount_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('event_amount_conversion: ' || 'Revproc Currency  Code :' || l_revproc_curr_code_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('event_amount_conversion: ' || 'Revproc rate type :' || l_revproc_rate_type_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('event_amount_conversion: ' || 'Revproc Exchange rate :' || l_revproc_exchange_rate_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('event_amount_conversion: ' || 'Revproc Rate date :' || l_revproc_rate_date_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('event_amount_conversion: ' || 'Realized gain and Loss Flag :' || l_Rgain_Rloss_flag(i));
           END IF;

        END LOOP;





 /* Updating pa_events table with all converted amounts. Set the
    revenue_distributed flag = 'N' if conversion fails,
    so that this event will pick up next time revenue distribution */


  /* Bug : 2563738 - Ignore the project amount and attributes if event type is realized gain and loss event
     l_rgain_rloss_flag = 'Y' (realized_gain and realized_loss event ) */

          FORALL I IN 1 .. l_event_id_tab.COUNT
              UPDATE pa_events
                 SET project_revenue_amount      =
                         DECODE(l_project_status_tab(i), 'N',
                            (DECODE(l_projfunc_status_tab(i), 'N',l_project_amount_tab(i), NULL)), NULL),
                     project_rate_type    =
                         DECODE(l_project_status_tab(i), 'N',
                             (DECODE(l_projfunc_status_tab(i), 'N', l_project_rate_type_tab(i),
                              project_rate_type)), project_rate_type),
                     project_rev_rate_date       =
                         DECODE(l_project_status_tab(i), 'N',
          --Modified for Bug3087885
          --                   (DECODE(l_projfunc_status_tab(i), 'N',l_project_rate_date_tab(i), NULL)), NULL),
                             (DECODE(l_projfunc_status_tab(i), 'N',
                                  DECODE(l_project_rate_type_tab(i), 'User', null, l_project_rate_date_tab(i)),
                                  NULL)), NULL),
                     project_rev_exchange_rate   =
                         DECODE(l_project_status_tab(i), 'N',
                            (DECODE(l_projfunc_status_tab(i), 'N',l_project_exchange_rate_tab(i), NULL)), NULL),
                     projfunc_revenue_amount     =
                         DECODE(l_project_status_tab(i), 'N',
                             (DECODE(l_projfunc_status_tab(i), 'N',l_projfunc_amount_tab(i), NULL)), NULL),
                     projfunc_rate_type    =
                         DECODE(l_project_status_tab(i), 'N',
                             (DECODE(l_projfunc_status_tab(i), 'N', l_projfunc_rate_type_tab(i),
                               projfunc_rate_type)), projfunc_rate_type),
                     projfunc_rev_rate_date      =
                          DECODE(l_project_status_tab(i), 'N',
          --Modified for Bug3087885
          --                   (DECODE(l_projfunc_status_tab(i), 'N',l_projfunc_rate_date_tab(i), NULL)), NULL),
                             (DECODE(l_projfunc_status_tab(i), 'N',
                                 DECODE(l_projfunc_rate_type_tab(i), 'User', null, l_projfunc_rate_date_tab(i)),
                                 NULL)), NULL),
                     projfunc_rev_exchange_rate  =
                           DECODE(l_project_status_tab(i), 'N',
                             (DECODE(l_projfunc_status_tab(i), 'N',l_projfunc_exchange_rate_tab(i), NULL)), NULL),
                     revenue_amount              =
                           DECODE(l_revproc_amount_tab(i), NULL, 0, l_revproc_amount_tab(i)),
                     revproc_rate_type    =
                         DECODE(l_project_status_tab(i), 'N',
                             (DECODE(l_projfunc_status_tab(i), 'N', l_revproc_rate_type_tab(i),
                                 revproc_rate_type)), revproc_rate_type),
                     revproc_rate_date           =
                           DECODE(l_project_status_tab(i), 'N',
          --Modified for Bug3087885
          --                 (DECODE(l_projfunc_status_tab(i), 'N',l_revproc_rate_date_tab(i), revproc_rate_date)),
          --                               revproc_rate_date),
                             (DECODE(l_projfunc_status_tab(i), 'N',
                                  DECODE(l_revproc_rate_type_tab(i), 'User', null, l_revproc_rate_date_tab(i)),
                                  DECODE(l_revproc_rate_type_tab(i), 'User', null, revproc_rate_date))),
                                             DECODE(l_revproc_rate_type_tab(i), 'User', null, revproc_rate_date)),
                     revproc_exchange_rate       =
                       DECODE(l_project_status_tab(i), 'N',
                        (DECODE(l_projfunc_status_tab(i), 'N',l_revproc_exchange_rate_tab(i), revproc_exchange_rate)),
                                        revproc_exchange_rate),
                     revenue_distributed_flag    =
                           DECODE(l_project_status_tab(i), 'N',
                             (DECODE(l_projfunc_status_tab(i), 'N',revenue_distributed_flag, 'N')),
                               'N'),
                     rev_dist_rejection_code      =
                           DECODE(l_project_status_tab(i), 'N',
                             (DECODE(l_projfunc_status_tab(i), 'N', NULL, l_projfunc_status_tab(i))),
                               l_project_status_tab(i))
               WHERE event_id = l_event_id_tab(i);

          IF g1_debug_mode  = 'Y' THEN
            PA_MCB_INVOICE_PKG.log_message('No of Rows Updated in Events table : ' || SQL%ROWCOUNT);
          END IF;


      END IF;       /* if l_event_id_tab <> 0 */


      EXIT WHEN csr_events%NOTFOUND;


       END LOOP;

       CLOSE csr_events;


   EXCEPTION
      WHEN OTHERS THEN
          IF g1_debug_mode  = 'Y' THEN
          	PA_MCB_INVOICE_PKG.log_message('Error in Event_amount_conversion ' || sqlerrm);
          END IF;
          x_return_status := sqlerrm( sqlcode );
END event_amount_conversion;



/*----------------------------------------------------------------------------------------+
|   Procedure  :   ei_amount_conversion                                                   |
|   Purpose    :   To update the pa_expenditure_items_all table
|                  (bill transaction currency to  revenue processing currency
|
|   Parameters :                                                                          |
|     ==================================================================================  |
|     Name               Mode    Description                                              |
|     ==================================================================================  |
|     p_project_id        IN      project Id                                              |
|     ei_id               IN      Expenditure item id
|     p_request_id        IN      Id for the current  Run                                 |
|     p_pa_date           IN      Project Accounting date                                 |
|     x_return_status     IN OUT  Return status of this procedure                         |
|     x_msg_count         IN OUT  Error message count                                     |
|     x_msg_data          IN OUT  Error message                                           |
|     ==================================================================================  |
+----------------------------------------------------------------------------------------*/

PROCEDURE ei_amount_conversion(
                               p_project_id       IN       NUMBER,
                               p_ei_id            IN       PA_PLSQL_DATATYPES.IdTabTyp,
                               p_request_id       IN       NUMBER,
                               p_pa_date          IN       VARCHAR2,
                               x_return_status    IN OUT NOCOPY   VARCHAR2,
                               x_msg_count        IN OUT NOCOPY   NUMBER,
                               x_msg_data         IN OUT NOCOPY   VARCHAR2,
                               x_rej_reason       IN OUT NOCOPY   VARCHAR2) IS


      CURSOR ei_amt_csr (p_request_id NUMBER) IS
      SELECT expenditure_item_id,
             expenditure_item_date, /* Added for bug 5907315*/
             bill_trans_raw_revenue,
             bill_trans_adjusted_revenue,
             bill_trans_currency_code
        FROM pa_expenditure_items_all
       WHERE request_id = p_request_id
         AND revenue_distributed_flag = 'D'
         AND bill_trans_raw_revenue IS NOT NULL
         AND raw_revenue IS NULL;


      l_ei_date_tab		       PA_PLSQL_DATATYPES.DateTabTyp;	/* Added for bug 5907315*/
      l_ei_id_tab                      PA_PLSQL_DATATYPES.IdTabTyp;
      l_bill_trans_rev_amount_tab      PA_PLSQL_DATATYPES.NumTabTyp;
      l_bill_trans_adj_rev_tab         PA_PLSQL_DATATYPES.NumTabTyp;
      l_bill_trans_bill_rate_tab       PA_PLSQL_DATATYPES.NumTabTyp;
      l_bill_trans_adj_rate_tab        PA_PLSQL_DATATYPES.NumTabTyp;
      l_bill_trans_curr_code_tab       PA_PLSQL_DATATYPES.Char30TabTyp;

      l_revproc_rate_type_tab          PA_PLSQL_DATATYPES.Char30TabTyp;
      l_revproc_rate_date_tab          PA_PLSQL_DATATYPES.DateTabTyp;
      l_revproc_exchange_rate_tab      PA_PLSQL_DATATYPES.NumTabTyp;
      l_revproc_curr_code_tab          PA_PLSQL_DATATYPES.Char30TabTyp;
      l_revproc_amount_tab             PA_PLSQL_DATATYPES.NumTabTyp;


      l_bill_trans_proj_amt_tab      PA_PLSQL_DATATYPES.NumTabTyp;
      l_project_curr_code_tab          PA_PLSQL_DATATYPES.Char30TabTyp;
      l_project_rate_date_tab          PA_PLSQL_DATATYPES.DateTabTyp;
      l_project_rate_type_tab          PA_PLSQL_DATATYPES.Char30TabTyp;
      l_project_exchange_rate_tab      PA_PLSQL_DATATYPES.NumTabTyp;
      l_project_amount_tab             PA_PLSQL_DATATYPES.NumTabTyp;
      l_project_rev_status_tab         PA_PLSQL_DATATYPES.Char30TabTyp;

      l_bill_trans_projfunc_amt_tab     PA_PLSQL_DATATYPES.NumTabTyp;
      l_projfunc_curr_code_tab         PA_PLSQL_DATATYPES.Char30TabTyp;
      l_projfunc_rate_date_tab         PA_PLSQL_DATATYPES.DateTabTyp;
      l_projfunc_rate_type_tab         PA_PLSQL_DATATYPES.Char30TabTyp;
      l_projfunc_exchange_rate_tab     PA_PLSQL_DATATYPES.NumTabTyp;
      l_projfunc_amount_tab            PA_PLSQL_DATATYPES.NumTabTyp;
      l_projfunc_rev_status_tab        PA_PLSQL_DATATYPES.Char30TabTyp;

      l_revproc_adj_rev_tab            PA_PLSQL_DATATYPES.NumTabTyp;
      l_revproc_bill_rate_tab          PA_PLSQL_DATATYPES.NumTabTyp;
      l_revproc_adj_rate_tab           PA_PLSQL_DATATYPES.NumTabTyp;

      l_denominator_tab                PA_PLSQL_DATATYPES.NumTabTyp;
      l_numerator_tab                  PA_PLSQL_DATATYPES.NumTabTyp;
      l_user_validate_flag_tab         PA_PLSQL_DATATYPES.Char30TabTyp;
      l_raw_rev_status_tab             PA_PLSQL_DATATYPES.Char30TabTyp;

      l_final_error_status_tab         PA_PLSQL_DATATYPES.Char30TabTyp;



      l_project_curr_code              VARCHAR2(30);
      l_project_rate_date_code         VARCHAR2(30);
      l_project_rate_date              DATE;
      l_project_rate_type              VARCHAR2(30);
      l_project_exchange_rate          NUMBER;

      l_projfunc_curr_code             VARCHAR2(30);
      l_projfunc_rate_date_code        VARCHAR2(30);
      l_projfunc_rate_date             DATE;
      l_projfunc_rate_type             VARCHAR2(30);
      l_projfunc_exchange_rate         NUMBER;

      l_multi_currency_billing_flag    VARCHAR2(1);
      l_baseline_funding_flag          VARCHAR2(1);
      l_revproc_currency_code          VARCHAR2(30);
      l_invproc_currency_type          VARCHAR2(30);
      l_invproc_currency_code          VARCHAR2(30);
      l_funding_rate_date_code         VARCHAR2(30);
      l_funding_rate_type              VARCHAR2(30);
      l_funding_rate_date              DATE;
      l_funding_exchange_rate          NUMBER;
      l_return_status                  VARCHAR2(1);
      l_msg_count                      NUMBER;
      l_msg_data                       VARCHAR2(240);

      l_pa_date                        DATE;

      l_conversion_between             VARCHAR2(6);
      l_cache_flag                     VARCHAR2(1);

      l_currency_flag                  VARCHAR2(1):= 'N';
/* Variable declaration for bug 5907315 */

      l_previous_project_rate_date     DATE;
      l_previous_projfunc_rate_date    DATE;

/* End of variable declaration: Bug 5907315 */


  BEGIN


        /* This flag is N then the convert_amount_bulk API not cache the currency code and attributes,
           If the flag is Y then cache the currency and other attributes to avoid the
           repeat conversion processing. */

        l_cache_flag   := 'Y';


        x_rej_reason := NULL;


       /* Convert the PA date from character to date */

        /*File.Date.5. Added format to the p_pa_date which was missing*/
        l_pa_date  :=  TO_DATE(p_pa_date,'YYYY/MM/DD');


        IF g1_debug_mode  = 'Y' THEN
        	PA_MCB_INVOICE_PKG.log_message('Entering the procedure ei_amount_conversion');
        	PA_MCB_INVOICE_PKG.log_message('ei_amount_conversion: ' || '-------------------------------------------');
        	PA_MCB_INVOICE_PKG.log_message('ei_amount_conversion: ' || 'Calling Procedure get_project_defaults');
        END IF;


     -- Get the Project Level Defaults

     PA_MULTI_CURRENCY_BILLING.get_project_defaults (
            p_project_id                  => p_project_id,
            x_multi_currency_billing_flag => l_multi_currency_billing_flag,
            x_baseline_funding_flag       => l_baseline_funding_flag,
            x_revproc_currency_code       => l_revproc_currency_code,
            x_invproc_currency_type       => l_invproc_currency_type,
            x_invproc_currency_code       => l_invproc_currency_code,
            x_project_currency_code       => l_project_curr_code,
            x_project_bil_rate_date_code  => l_project_rate_date_code,
            x_project_bil_rate_type       => l_project_rate_type,
            x_project_bil_rate_date       => l_project_rate_date,
            x_project_bil_exchange_rate   => l_project_exchange_rate,
            x_projfunc_currency_code      => l_projfunc_curr_code,
            x_projfunc_bil_rate_date_code => l_projfunc_rate_date_code,
            x_projfunc_bil_rate_type      => l_projfunc_rate_type,
            x_projfunc_bil_rate_date      => l_projfunc_rate_date,
            x_projfunc_bil_exchange_rate  => l_projfunc_exchange_rate,
            x_funding_rate_date_code      => l_funding_rate_date_code,
            x_funding_rate_type           => l_funding_rate_type,
            x_funding_rate_date           => l_funding_rate_date,
            x_funding_exchange_rate       => l_funding_exchange_rate,
            x_return_status               => l_return_status,
            x_msg_count                   => l_msg_count,
            x_msg_data                    => l_msg_data);



     /* Checking for Project Functional and Project currencies are same, If both are same then
        Convert only Project Functional and copy the Project Functional attributes to
        project
        Here we are setting flag for Whether we need to convert Project amount or not
     */


         l_currency_flag := 'N';

         IF  (l_projfunc_curr_code = l_project_curr_code) THEN

              l_currency_flag := 'Y';

         END IF;

/* Code added for bug 5907315 */
    fnd_profile_revenue_orig_rate := NVL(fnd_profile.value_specific('PA_REVENUE_ORIGINAL_RATE_FORRECALC'),'N');
/* End of bug 5907315 */


   /* cursor for select the expenditure details based on current request id */


    OPEN ei_amt_csr( p_request_id);



    LOOP


/*
 *    Clear all PL/SQL table.
 */

              l_ei_id_tab.delete;
      	      l_ei_date_tab.delete; /* Added for bug 5907315*/
              l_bill_trans_rev_amount_tab.delete;
              l_bill_trans_bill_rate_tab.delete;
              l_bill_trans_curr_code_tab.delete;
              l_bill_trans_adj_rev_tab.delete;
              l_bill_trans_adj_rate_tab.delete;

              l_revproc_rate_type_tab.delete;
              l_revproc_rate_date_tab.delete;
              l_revproc_exchange_rate_tab.delete;
              l_revproc_curr_code_tab.delete;
              l_revproc_amount_tab.delete;

              l_project_curr_code_tab.delete;
              l_project_rate_date_tab.delete;
              l_project_rate_type_tab.delete;
              l_project_exchange_rate_tab.delete;
              l_project_amount_tab.delete;
              l_project_rev_status_tab.delete;

              l_projfunc_curr_code_tab.delete;
              l_projfunc_rate_date_tab.delete;
              l_projfunc_rate_type_tab.delete;
              l_projfunc_exchange_rate_tab.delete;
              l_projfunc_amount_tab.delete;
              l_projfunc_rev_status_tab.delete;

              l_revproc_adj_rev_tab.delete;
              l_revproc_bill_rate_tab.delete;
              l_revproc_adj_rate_tab.delete;

              l_user_validate_flag_tab.delete;
              l_denominator_tab.delete;
              l_numerator_tab.delete;
              l_raw_rev_status_tab.delete;

              l_final_error_status_tab.delete;


      /* Fetching the expenditure bill transaction value */


       FETCH ei_amt_csr BULK  COLLECT
        INTO l_ei_id_tab,
	     l_ei_date_tab,
             l_bill_trans_rev_amount_tab,
             l_bill_trans_adj_rev_tab,
             l_bill_trans_curr_code_tab LIMIT 100;
/* Added l_ei_date_tab for bug 5907315*/

        /* If any records select in the fetch then go for conversion */

        IF (l_ei_id_tab.COUNT = 0) THEN

           Exit;


        ELSE                 /*  l_ei_id_tab.COUNT <> 0) */


          /* Initialize the Array variables to use convert_amount_bulk API */

              FOR I in 1 .. l_ei_id_tab.COUNT
              LOOP

                    l_revproc_amount_tab(I)       := NULL;
                    l_user_validate_flag_tab(I)   := 'Y';
                    l_project_amount_tab(i)       := NULL;
                    l_projfunc_amount_tab(i)      := NULL;
                    l_revproc_amount_tab(I)       := NULL;
                    l_revproc_adj_rev_tab(I)      := NULL;
                    l_revproc_bill_rate_tab(I)    := NULL;
                    l_revproc_adj_rate_tab(I)     := NULL;
                    l_denominator_tab(I)          := NULL;
                    l_numerator_tab(I)            := NULL;
                    l_raw_rev_status_tab(i)       := 'N';
                    l_project_rev_status_tab(i)   := 'N';
                    l_projfunc_rev_status_tab(i)   := 'N';


                   /* Copy the project and project attributed into array variables */


                   l_project_curr_code_tab(I)      := l_project_curr_code;
                   l_project_rate_type_tab(I)      := l_project_rate_type;
                   l_project_rate_date_tab(I)      := l_project_rate_date;
                   l_project_exchange_rate_tab(I)  := l_project_exchange_rate;

                   l_projfunc_curr_code_tab(I)     := l_projfunc_curr_code;
                   l_projfunc_rate_type_tab(I)     := l_projfunc_rate_type;
                   l_projfunc_rate_date_tab(I)     := l_projfunc_rate_date;
                   l_projfunc_exchange_rate_tab(I) := l_projfunc_exchange_rate;


                /* If Bill transaction adjusted revenue is NOT NULL then take the bill trans
                   adjsuted revenue otherwise take the bill transaction raw revenue revenue */

                    l_bill_trans_proj_amt_tab(I)
                           := NVL(l_bill_trans_adj_rev_tab(I), l_bill_trans_rev_amount_tab(I));

                /* Copy the project amount to project functional amount */


                    l_bill_trans_projfunc_amt_tab(I)
                           := l_bill_trans_proj_amt_tab(I);

/* Code added for bug 5907315 */

               l_previous_project_rate_date := NULL;
               l_previous_projfunc_rate_date:= NULL;

	       IF fnd_profile_revenue_orig_rate = 'Y' THEN

                  begin
                    l_previous_project_rate_date := NULL;
                    l_previous_projfunc_rate_date:= NULL;
		    l_previous_project_rate_date := pa_date(l_ei_date_tab(i));
		    l_previous_projfunc_rate_date:= pa_date(l_ei_date_tab(i));

		  EXCEPTION
		    when  OTHERS then
		      l_previous_project_rate_date := NULL;
		      l_previous_projfunc_rate_date:= NULL;
		  end;

	       END IF;

/* End of code. Bug 5907315 */


               /* Copy the PA date to project rate date */

               IF (l_project_rate_date_code = 'PA_INVOICE_DATE') THEN
/* Code commented for bug 5907315
                   l_project_rate_date_tab(I) := l_pa_date;
The statement is modified as below */
		  IF fnd_profile_revenue_orig_rate = 'Y' THEN
                     l_project_rate_date_tab(I) := NVL(l_previous_project_rate_date,l_pa_date);
		  ELSE
                     l_project_rate_date_tab(I) := l_pa_date;
		  END IF;
/* End of bug 5907315 */

               END IF;


              /* Copy the PA date to project functional rate date */

               IF (l_projfunc_rate_date_code = 'PA_INVOICE_DATE') THEN
/* Code commented for bug 5907315
                   l_projfunc_rate_date_tab(I) := l_pa_date;
 The statement is modified as below */
		  IF fnd_profile_revenue_orig_rate = 'Y' THEN
                     l_projfunc_rate_date_tab(I) := NVL(l_previous_projfunc_rate_date,l_pa_date);
		  ELSE
                     l_projfunc_rate_date_tab(I) := l_pa_date;
		  END IF;
/* End of bug 5907315 */
               END IF;


           /* Print the currency attribute value */

           IF g1_debug_mode  = 'Y' THEN
           	PA_MCB_INVOICE_PKG.log_message('ei_amount_conversion: ' || 'Bill Trans Currency Code :' || l_bill_trans_curr_code_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('ei_amount_conversion: ' || 'Bill Trans Rev amount :' || l_bill_trans_rev_amount_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('ei_amount_conversion: ' || 'Bill Trans projfun amount :' || l_bill_trans_projfunc_amt_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('ei_amount_conversion: ' || 'Projfunc Currency Code :' || l_projfunc_curr_code_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('ei_amount_conversion: ' || 'Projfunc Rate Type     :' || l_projfunc_rate_type_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('ei_amount_conversion: ' || 'Projfunc Rate Date     :' || l_projfunc_rate_date_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('ei_amount_conversion: ' || 'Projfunc Xchg Rate     :' || l_projfunc_exchange_rate_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('ei_amount_conversion: ' || 'Project Currency Code :' || l_project_curr_code_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('ei_amount_conversion: ' || 'Project Rate Type     :' || l_project_rate_type_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('ei_amount_conversion: ' || 'Project Rate Date     :' || l_project_rate_date_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('ei_amount_conversion: ' || 'Project Xchg Rate     :' || l_project_exchange_rate_tab(i));
           END IF;


        END LOOP;



  /* Converting Bill Trans Raw revenue to Project Functional Amount(Project Func Amount) */


        IF g1_debug_mode  = 'Y' THEN
        	PA_MCB_INVOICE_PKG.log_message('ei_amount_conversion: ' || 'Calling the procedure convert_amount_bulk for project func amount');
        END IF;

           /* Passing the param (two currency code) to the convert_amount_bulk API, If any conversion fails
              then the API concatenate the code with error message */

              l_conversion_between  := 'BTC_PF';


           PA_MULTI_CURRENCY_BILLING.convert_amount_bulk(
                    p_from_currency_tab        => l_bill_trans_curr_code_tab,
                    p_to_currency_tab          => l_projfunc_curr_code_tab,
                    p_conversion_date_tab      => l_projfunc_rate_date_tab,
                    p_conversion_type_tab      => l_projfunc_rate_type_tab,
                    p_amount_tab               => l_bill_trans_projfunc_amt_tab,
                    p_user_validate_flag_tab   => l_user_validate_flag_tab,
                    p_converted_amount_tab     => l_projfunc_amount_tab,
                    p_denominator_tab          => l_denominator_tab,
                    p_numerator_tab            => l_numerator_tab,
                    p_rate_tab                 => l_projfunc_exchange_rate_tab,
                    p_conversion_between       => l_conversion_between,
                    p_cache_flag               => l_cache_flag,
                    x_status_tab               => l_projfunc_rev_status_tab
                    );


                  l_denominator_tab.delete;
                  l_numerator_tab.delete;


  /* Converting Bill Trans Raw revenue to Project Amount(Project Currency) */


        IF g1_debug_mode  = 'Y' THEN
        	PA_MCB_INVOICE_PKG.log_message('ei_amount_conversion: ' || 'Calling the procedure convert_amount_bulk for convert project amount');
        END IF;


           /* Passing the param (two currency code) to the convert_amount_bulk API, If any conversion fails
              then the API concatenate the code with error message */


         IF (l_currency_flag <> 'Y') THEN

           l_conversion_between  := 'BTC_PC';

           PA_MULTI_CURRENCY_BILLING.convert_amount_bulk(
                    p_from_currency_tab        => l_bill_trans_curr_code_tab,
                    p_to_currency_tab          => l_project_curr_code_tab,
                    p_conversion_date_tab      => l_project_rate_date_tab,
                    p_conversion_type_tab      => l_project_rate_type_tab,
                    p_amount_tab               => l_bill_trans_proj_amt_tab,
                    p_user_validate_flag_tab   => l_user_validate_flag_tab,
                    p_converted_amount_tab     => l_project_amount_tab,
                    p_denominator_tab          => l_denominator_tab,
                    p_numerator_tab            => l_numerator_tab,
                    p_rate_tab                 => l_project_exchange_rate_tab,
                    p_conversion_between       => l_conversion_between,
                    p_cache_flag               => l_cache_flag,
                    x_status_tab               => l_project_rev_status_tab
                    );

         END IF;


   /* Converting Bill trans adjusted revenue to Adjusted revenue
      Here not necessary call the conver_amount_bulk API
      we have to calculate the adjusted revenue based on rate, which
      we got it from previos API */



        IF g1_debug_mode  = 'Y' THEN
        	PA_MCB_INVOICE_PKG.log_message('ei_amount_conversion: ' || 'Project Id  : ' || p_project_id);
        END IF;


             FOR I in 1 .. l_ei_id_tab.COUNT
              LOOP

              IF g1_debug_mode  = 'Y' THEN
              	PA_MCB_INVOICE_PKG.log_message('ei_amount_conversion: ' || 'Inside EI tab .........');
              END IF;


             /* Checking for Project Functional and Project currencies are same, If both are same then
                Convert only Project Functional and copy the Project Functional attributes to
                project.
             */


              IF (l_currency_flag  = 'Y') THEN

                    l_project_curr_code_tab(i)     := l_projfunc_curr_code_tab(i);
                    l_project_rate_type_tab(i)     := l_projfunc_rate_type_tab(i);
                    l_project_rate_date_tab(i)     := l_projfunc_rate_date_tab(i);
                    l_project_exchange_rate_tab(i) := l_projfunc_exchange_rate_tab(i);
                    l_project_amount_tab(i)        := l_projfunc_amount_tab(i);
                    l_project_rev_status_tab(i)    := l_projfunc_rev_status_tab(i);

               END IF;



              /* If revenue processing currency and project currency both are same then
                 copy the project attributes to revenue processing attributes */

               IF (l_revproc_currency_code = l_project_curr_code) THEN


                    l_revproc_curr_code_tab(I)     := l_project_curr_code_tab(i);
                    l_revproc_rate_type_tab(I)     := l_project_rate_type_tab(i);
                    l_revproc_rate_date_tab(I)     := l_project_rate_date_tab(i);
                    l_revproc_exchange_rate_tab(I) := l_project_exchange_rate_tab(i);
                    l_revproc_amount_tab(I)        := l_project_amount_tab(i);

                 /* If revenue processing currency and project functional  currency both are same then
                 copy the project functional attributes to revenue processing attributes */


             ELSIF (l_revproc_currency_code = l_projfunc_curr_code) THEN

                    l_revproc_curr_code_tab(I)     := l_projfunc_curr_code_tab(i);
                    l_revproc_rate_type_tab(I)     := l_projfunc_rate_type_tab(i);
                    l_revproc_rate_date_tab(I)     := l_projfunc_rate_date_tab(i);
                    l_revproc_exchange_rate_tab(I) := l_projfunc_exchange_rate_tab(i);
                    l_revproc_amount_tab(I)        := l_projfunc_amount_tab(i);

               END IF;



                  IF  (l_bill_trans_curr_code_tab(I) = l_revproc_curr_code_tab(I)) THEN

                     l_revproc_adj_rev_tab(I) := l_bill_trans_adj_rev_tab(I) ;

                  ELSE

                     l_revproc_adj_rev_tab(I) :=
                             l_bill_trans_adj_rev_tab(I) * l_revproc_exchange_rate_tab(I);
                  END IF;



                  /* If error occur any one of the currency conversion fails then copy
                     the error code into the  variable l_final_error_status_tab
                     for easy to use in following UPDATE */


                   l_final_error_status_tab(I) := 'N';

                   IF l_projfunc_rev_status_tab(I) <> 'N' THEN

                      l_final_error_status_tab(I) := l_projfunc_rev_status_tab(I);

                      /* Bug :2135943 - Added for get the any onr rejection reasaon, it will
                         use for print the rejction reason in the report */

                         x_rej_reason := l_projfunc_rev_status_tab(I);


                   ELSIF l_project_rev_status_tab(I) <> 'N' THEN

                      l_final_error_status_tab(I) := l_project_rev_status_tab(I);

                      /* Bug :2135943 - Added for get the any onr rejection reasaon, it will
                         use for print the rejction reason in the report */

                         x_rej_reason :=  l_project_rev_status_tab(I);

                   END IF;



        -- Log Messages for EI Converted Amounts

           IF g1_debug_mode  = 'Y' THEN
           	PA_MCB_INVOICE_PKG.log_message('ei_amount_conversion: ' || 'Expenditure Item Id :' || l_ei_id_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('ei_amount_conversion: ' || 'Bill Trans Currency Code :' || l_bill_trans_curr_code_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('ei_amount_conversion: ' || 'Bill Trans Raw revenue :' || l_bill_trans_rev_amount_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('ei_amount_conversion: ' || 'Bill Trans Adj revenue :' || l_bill_trans_adj_rev_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('ei_amount_conversion: ' || 'Project Currency Code :' || l_project_curr_code_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('ei_amount_conversion: ' || 'Project Rate Type     :' || l_project_rate_type_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('ei_amount_conversion: ' || 'Project Rate Date     :' || l_project_rate_date_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('ei_amount_conversion: ' || 'Project Xchg Rate     :' || l_project_exchange_rate_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('ei_amount_conversion: ' || 'Convert Project Amount :' || l_project_amount_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('ei_amount_conversion: ' || 'Project Rejection Reason :' || l_project_rev_status_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('ei_amount_conversion: ' || 'Convert Project Func Amount :' || l_projfunc_amount_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('ei_amount_conversion: ' || 'Project Func Curr Code :' || l_projfunc_curr_code_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('ei_amount_conversion: ' || 'Projfunc Rate Type     :' || l_projfunc_rate_type_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('ei_amount_conversion: ' || 'Projfunc Rate Date     :' || l_projfunc_rate_date_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('ei_amount_conversion: ' || 'Projfunc Xchg Rate     :' || l_projfunc_exchange_rate_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('ei_amount_conversion: ' || 'ProjFunc Amt Rejection Reason :' || l_projfunc_rev_status_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('ei_amount_conversion: ' || 'Convert RevProc Amount :' || l_revproc_amount_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('ei_amount_conversion: ' || 'Revproc Currency  Code :' || l_revproc_curr_code_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('ei_amount_conversion: ' || 'Revproc Rate Type     :' || l_revproc_rate_type_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('ei_amount_conversion: ' || 'RevProc Rate Date     :' || l_revproc_rate_date_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('ei_amount_conversion: ' || 'Revproc Xchg Rate     :' || l_revproc_exchange_rate_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('ei_amount_conversion: ' || 'Revproc Amt Rejection Reason :' || l_raw_rev_status_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('ei_amount_conversion: ' || 'Adjusted Reveneue :' || l_revproc_adj_rev_tab(i));
           END IF;



     END LOOP;



  /* Updating the converted amount to the Expenditure Item table.
     Converted amount column : raw_revenue, adjusted_revenue, bill_rate, adjusted_rate
     Other columns           : Initialize when conversion fails and marking revenue
                               distributed flag to 'N                       */

         IF g1_debug_mode  = 'Y' THEN
         	PA_MCB_INVOICE_PKG.log_message('ei_amount_conversion: ' || 'Before Updating EI table .....');
        	PA_MCB_INVOICE_PKG.log_message('ei_amount_conversion: ' || 'Inside If statement .....');
        END IF;

          FORALL I IN 1 ..l_ei_id_tab.COUNT
                  UPDATE pa_expenditure_items_all
                     SET raw_revenue      =
                              DECODE(l_final_error_status_tab(i), 'N', l_revproc_amount_tab(i), NULL),
                         adjusted_revenue =
                              DECODE(l_final_error_status_tab(i), 'N',
                              PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(l_revproc_adj_rev_tab(i),
                                                   l_revproc_curr_code_tab(i)), NULL),
                         project_raw_revenue =
                              DECODE(l_final_error_status_tab(i), 'N', l_project_amount_tab(i), NULL),
                         projfunc_raw_revenue =
                              DECODE(l_final_error_status_tab(i), 'N', l_projfunc_amount_tab(i), NULL),
                         bill_trans_raw_revenue =
                              DECODE(l_final_error_status_tab(i), 'N', bill_trans_raw_revenue, NULL),
                         bill_trans_adjusted_revenue =
                            DECODE(l_final_error_status_tab(i), 'N', bill_trans_adjusted_revenue, NULL),
                         accrued_revenue  =
                              DECODE(l_final_error_status_tab(i), 'N', accrued_revenue, NULL),
                         accrual_rate     =
                              DECODE(l_final_error_status_tab(i), 'N', accrual_rate, NULL),
                         revenue_distributed_flag =
                              DECODE(l_final_error_status_tab(i), 'N', revenue_distributed_flag, 'N'),
                         rev_dist_rejection_code =
                                DECODE(l_final_error_status_tab(i), 'N',NULL, l_final_error_status_tab(i)),
                         revproc_currency_code   = l_revproc_curr_code_tab(i),
                         revproc_rate_type       = l_revproc_rate_type_tab(i),
                       --  revproc_rate_date       = l_revproc_rate_date_tab(i), --Modified for Bug3137196
                         revproc_rate_date       = decode(l_revproc_rate_type_tab(i), 'User', null, l_revproc_rate_date_tab(i)),
                         revproc_exchange_rate   = l_revproc_exchange_rate_tab(i),
                         projfunc_currency_code  = l_projfunc_curr_code_tab(i),
                         project_rev_rate_type       = l_project_rate_type_tab(i),
                       --  project_rev_rate_date       = l_project_rate_date_tab(i), --Modified for Bug3137196
                         project_rev_rate_date       = decode(l_project_rate_type_tab(i), 'User', null, l_project_rate_date_tab(i)),
                         project_rev_exchange_rate   = l_project_exchange_rate_tab(i),
                         projfunc_rev_rate_type      = l_projfunc_rate_type_tab(i),
                       --  projfunc_rev_rate_date      = l_projfunc_rate_date_tab(i), --Modified for Bug3137196
                         projfunc_rev_rate_date      = decode(l_projfunc_rate_type_tab(i), 'User', null, l_projfunc_rate_date_tab(i)),
                         projfunc_rev_exchange_rate  = l_projfunc_exchange_rate_tab(i)
                   WHERE expenditure_item_id = l_ei_id_tab(i);

           IF g1_debug_mode  = 'Y' THEN
            PA_MCB_INVOICE_PKG.log_message('No of Rows Updated in EI table : ' || SQL%ROWCOUNT);
           END IF;

      END IF;    /* l_ei_id_tab.COUNT <> 0 */

          EXIT WHEN ei_amt_csr%NOTFOUND;


       END LOOP;

       CLOSE ei_amt_csr;


   EXCEPTION
     WHEN OTHERS THEN

          IF g1_debug_mode  = 'Y' THEN
          	PA_MCB_INVOICE_PKG.log_message('Error in Ei_amount_conversion ' || sqlerrm);
          END IF;

          x_return_status := sqlerrm( sqlcode );

END ei_amount_conversion;


/*----------------------------------------------------------------------------------------+
|   Procedure  :   rdl_amount_conversion                                                  |
|   Purpose    :   To update the RDLltable                                                |
|                  (bill transaction currency to  revenue processing currency)            |
|                                                                                         |
|   Parameters :                                                                          |
|     ==================================================================================  |
|     Name               Mode    Description                                              |
|     ==================================================================================  |
|     p_project_id             IN      project Id                                         |
|     ei_id                    IN      Expenditure item id                                |
|     p_request_id             IN      Id for the current  Run                            |
|     p_raw_revenue            IN      raw revenue from EI table                          |
|     p_bill_trans_raw_revenue IN      bill trans raw revenue from EI table.              |
|     p_project_raw_revenue    IN      Project Raw Revenue                                |
|     p_projfunc_raw_revenue   IN      Project Functional raw Revenue                     |
|     p_funding_rate_date      IN      Funding Rate Date                                  |
|     x_return_status          IN OUT  Return status of this procedure                    |
|     x_msg_count              IN OUT  Error message count                                |
|     x_msg_data               IN OUT  Error message                                      |
|     ==================================================================================  |
+----------------------------------------------------------------------------------------*/

PROCEDURE rdl_amount_conversion(
                               p_project_id                IN       NUMBER,
                               p_request_id                IN       NUMBER,
                               p_ei_id                     IN       PA_PLSQL_DATATYPES.IdTabTyp,
                               p_raw_revenue               IN       PA_PLSQL_DATATYPES.Char30TabTyp,
                               p_bill_trans_raw_revenue    IN       PA_PLSQL_DATATYPES.Char30TabTyp,
                               p_project_raw_revenue       IN       PA_PLSQL_DATATYPES.Char30TabTyp,
                               p_projfunc_raw_revenue      IN       PA_PLSQL_DATATYPES.Char30TabTyp,
                               p_funding_rate_date         IN       VARCHAR2,
                               x_return_status             IN OUT NOCOPY   VARCHAR2,
                               x_msg_count                 IN OUT NOCOPY   NUMBER,
                               x_msg_data                  IN OUT NOCOPY   VARCHAR2) IS


      CURSOR rdl_amt_csr (p_project_id NUMBER,
                          p_request_id NUMBER) IS
      SELECT rdl.expenditure_item_id,
             ei.expenditure_item_date, /* Added for bug 5907315*/
             rdl.line_num,
             rdl.draft_revenue_num,
             rdl.bill_trans_currency_code,
             rdl.amount,
             rdl.project_currency_code,
             rdl.project_rev_rate_type,
             rdl.project_rev_rate_date,
             rdl.project_rev_exchange_rate,
             rdl.projfunc_currency_code,
             rdl.projfunc_rev_rate_type,
             rdl.projfunc_rev_rate_date,
             rdl.projfunc_rev_exchange_rate,
             rdl.funding_currency_code,
             rdl.funding_rev_rate_type,
             rdl.funding_rev_rate_date,
             rdl.funding_rev_exchange_rate,
             nvl(ei.adjusted_revenue, ei.raw_revenue),
             nvl(ei.bill_trans_adjusted_revenue, ei.bill_trans_raw_revenue),
             ei.project_raw_revenue,
             ei.projfunc_raw_revenue,
             RDL.REVTRANS_CURRENCY_CODE,
             RDL.REVPROC_REVTRANS_RATE_TYPE,
             RDL.REVPROC_REVTRANS_RATE_DATE,
             RDL.REVPROC_REVTRANS_EX_RATE
        FROM pa_cust_rev_dist_lines rdl,
             pa_expenditure_items_all ei
      WHERE  rdl.project_id = p_project_id
        AND  ei.expenditure_item_id = rdl.expenditure_item_id
        AND  rdl.request_id = p_request_id
        AND  rdl.bill_trans_amount is NULL ;



      l_ei_id_tab                          PA_PLSQL_DATATYPES.IdTabTyp;
      l_ei_date_tab			   PA_PLSQL_DATATYPES.DateTabTyp; /* Added for bug 5907315*/
      l_bill_trans_currency_code_tab       PA_PLSQL_DATATYPES.Char30TabTyp;
      l_project_currency_code_tab          PA_PLSQL_DATATYPES.Char30TabTyp;
      l_project_rev_rate_type_tab          PA_PLSQL_DATATYPES.Char30TabTyp;
      l_project_rev_rate_date_tab          PA_PLSQL_DATATYPES.DateTabTyp;
      l_project_rev_xchg_rate_tab          PA_PLSQL_DATATYPES.NumTabTyp;
      l_projfunc_currency_code_tab         PA_PLSQL_DATATYPES.Char30TabTyp;
      l_projfunc_rev_rate_type_tab         PA_PLSQL_DATATYPES.Char30TabTyp;
      l_projfunc_rev_rate_date_tab         PA_PLSQL_DATATYPES.DateTabTyp;
      l_projfunc_rev_xchg_rate_tab         PA_PLSQL_DATATYPES.NumTabTyp;
      l_funding_currency_code_tab          PA_PLSQL_DATATYPES.Char30TabTyp;
      l_funding_rev_rate_type_tab          PA_PLSQL_DATATYPES.Char30TabTyp;
      l_funding_rev_rate_date_tab          PA_PLSQL_DATATYPES.DateTabTyp;
      l_funding_rev_xchg_rate_tab          PA_PLSQL_DATATYPES.NumTabTyp;

      l_BTC_amount_tab                     PA_PLSQL_DATATYPES.NumTabTyp;

      l_project_amount_tab                 PA_PLSQL_DATATYPES.NumTabTyp;
      l_projfunc_amount_tab                PA_PLSQL_DATATYPES.NumTabTyp;
      l_funding_amount_tab                 PA_PLSQL_DATATYPES.NumTabTyp;

      l_project_bill_rate_tab              PA_PLSQL_DATATYPES.NumTabTyp;
      l_projfunc_bill_rate_tab             PA_PLSQL_DATATYPES.NumTabTyp;
      l_funding_bill_rate_tab              PA_PLSQL_DATATYPES.NumTabTyp;
      l_project_denominator_tab            PA_PLSQL_DATATYPES.NumTabTyp;
      l_projfunc_denominator_tab           PA_PLSQL_DATATYPES.NumTabTyp;
      l_funding_denominator_tab            PA_PLSQL_DATATYPES.NumTabTyp;
      l_project_numerator_tab              PA_PLSQL_DATATYPES.NumTabTyp;
      l_projfunc_numerator_tab             PA_PLSQL_DATATYPES.NumTabTyp;
      l_funding_numerator_tab              PA_PLSQL_DATATYPES.NumTabTyp;
      l_project_status_tab                 PA_PLSQL_DATATYPES.Char30TabTyp;
      l_projfunc_status_tab                PA_PLSQL_DATATYPES.Char30TabTyp;
      l_funding_status_tab                 PA_PLSQL_DATATYPES.Char30TabTyp;

      l_user_validate_flag_tab             PA_PLSQL_DATATYPES.Char30TabTyp;

      l_revenue_amount_tab                 PA_PLSQL_DATATYPES.NumTabTyp;

      l_line_num_tab                       PA_PLSQL_DATATYPES.NumTabTyp;

      l_draft_revenue_num_tab              PA_PLSQL_DATATYPES.NumTabTyp;

      l_error_draft_rev_num_tab            PA_PLSQL_DATATYPES.NumTabTyp;
      l_error_ei_id_tab                    PA_PLSQL_DATATYPES.NumTabTyp;
      l_error_funding_status_tab           PA_PLSQL_DATATYPES.Char30TabTyp;

      l_raw_revenue                        PA_PLSQL_DATATYPES.NumTabTyp;
      l_bill_trans_raw_revenue             PA_PLSQL_DATATYPES.NumTabTyp;
      l_project_raw_revenue                PA_PLSQL_DATATYPES.NumTabTyp;
      l_projfunc_raw_revenue               PA_PLSQL_DATATYPES.NumTabTyp;


      l_funding_rate_date                  DATE;

      l_counter                            NUMBER;

      l_conversion_between             VARCHAR2(6);
      l_cache_flag                     VARCHAR2(1);

      l_pf_currency_flag               VARCHAR2(1) := 'N';
      l_prj_currency_flag              VARCHAR2(1) := 'N';

      /* Revenue in foreign currency */
      l_revtrans_currency_code_tab          PA_PLSQL_DATATYPES.Char30TabTyp;
      l_revtrans_rate_type_tab          PA_PLSQL_DATATYPES.Char30TabTyp;
      l_revtrans_rate_date_tab          PA_PLSQL_DATATYPES.DateTabTyp;
      l_revtrans_xchg_rate_tab          PA_PLSQL_DATATYPES.NumTabTyp;
      l_mcb_flag                       VARCHAR2(1);
      l_inv_by_btc_flag                VARCHAR2(1);
      l_rev_in_txn_curr_flag                VARCHAR2(1);
      l_pf_currency_flag_rtc_tab        PA_PLSQL_DATATYPES.Char1TabTyp;
      l_bt_currency_flag_rtc_tab        PA_PLSQL_DATATYPES.Char1TabTyp;
      l_revtrans_status_tab                 PA_PLSQL_DATATYPES.Char30TabTyp;
      l_error_revtrans_status_tab           PA_PLSQL_DATATYPES.Char30TabTyp;
      l_PFC_amount_tab                     PA_PLSQL_DATATYPES.NumTabTyp;
      l_revtrans_amount_tab                     PA_PLSQL_DATATYPES.NumTabTyp;
      l_revtrans_denominator_tab            PA_PLSQL_DATATYPES.NumTabTyp;
      l_revtrans_numerator_tab              PA_PLSQL_DATATYPES.NumTabTyp;

	l_pf_currency_code_t1_tab  PA_PLSQL_DATATYPES.Char30TabTyp;
	l_rt_currency_code_t1_tab  PA_PLSQL_DATATYPES.Char30TabTyp;
	l_rt_rate_date_t1_tab  PA_PLSQL_DATATYPES.DateTabTyp;
	l_rt_rate_type_t1_tab PA_PLSQL_DATATYPES.Char30TabTyp;
	l_pf_amount_t1_tab PA_PLSQL_DATATYPES.NumTabTyp;
	l_user_validate_flag_t1_tab   PA_PLSQL_DATATYPES.Char30TabTyp;
	l_rt_amount_t1_tab PA_PLSQL_DATATYPES.NumTabTyp;
	l_rt_denominator_t1_tab PA_PLSQL_DATATYPES.NumTabTyp;
	l_rt_numerator_t1_tab PA_PLSQL_DATATYPES.NumTabTyp;
	l_rt_xchg_rate_t1_tab PA_PLSQL_DATATYPES.NumTabTyp;
	l_rt_status_t1_tab  PA_PLSQL_DATATYPES.Char30TabTyp;
        l_error_rt_dr_rev_num_tab            PA_PLSQL_DATATYPES.NumTabTyp;

/* Variable declaration for bug 5907315 */

      l_previous_funding_rate_date     DATE;

/* End of variable declaration: Bug 5907315 */

  BEGIN


       /* Initiallizing the Currency variable for check PF and Project curency are same
          for Funding Currency or not *

          l_pf_currency_flag      := 'N';
          l_prj_currency_flag     := 'N';


        /* This flag is N then the convert_amount_bulk API not cache any currency code,
           If the flag is Y then it cache the currency and other attributes for avoid the
           repeat processing. */


        l_cache_flag   := 'N';


    IF g1_debug_mode  = 'Y' THEN
    	PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || 'Inside the Procedure RDL AMOUT conversion');
    	PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || '-----------------------------------------');
    	PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || 'project Id ' || p_project_id);
    END IF;



    /* Convert the funding rate date charater to DATE format */

        /*File.Date.5. Added format to the p_funding_rate_date which was missing*/
       l_funding_rate_date    := TO_DATE(p_funding_rate_date,'YYYY/MM/DD');

    /* Revenue in foreign currency */

	l_mcb_flag := pa_billing.globvars.mcb_flag;
	l_inv_by_btc_flag :=  pa_billing.globvars.inv_by_btc_flag;
	l_rev_in_txn_curr_flag :=  pa_billing.globvars.rev_in_txn_curr_flag;


    OPEN rdl_amt_csr( p_project_id,
                      p_request_id);


    LOOP

/* Added l_ei_date_tab for bug 5907315*/
       FETCH rdl_amt_csr BULK COLLECT
        INTO l_ei_id_tab,
  	     l_ei_date_tab,
             l_line_num_tab,
             l_draft_revenue_num_tab,
             l_bill_trans_currency_code_tab,
             l_revenue_amount_tab,
             l_project_currency_code_tab,
             l_project_rev_rate_type_tab,
             l_project_rev_rate_date_tab,
             l_project_rev_xchg_rate_tab,
             l_projfunc_currency_code_tab,
             l_projfunc_rev_rate_type_tab,
             l_projfunc_rev_rate_date_tab,
             l_projfunc_rev_xchg_rate_tab,
             l_funding_currency_code_tab,
             l_funding_rev_rate_type_tab,
             l_funding_rev_rate_date_tab,
             l_funding_rev_xchg_rate_tab,
             l_raw_revenue,
             l_bill_trans_raw_revenue,
             l_project_raw_revenue,
             l_projfunc_raw_revenue,
             l_revtrans_currency_code_tab,
             l_revtrans_rate_type_tab,
             l_revtrans_rate_date_tab,
             l_revtrans_xchg_rate_tab LIMIT 100;



   /* If fetch return more than one row then proceeding for the conversion */


   IF (l_ei_id_tab.COUNT = 0) THEN

       Exit;

   ELSE                        /*  (l_ei_id_tab.COUNT <> 0) */


      FOR I in 1..l_ei_id_tab.COUNT
      LOOP



       /* Checking for Project Functional and Funding Currencies are same or
           Project and Funding currencies are same the copy the Project Functional and
           Project currency to Funding currency
           If not same then we need to convert the funding amount
        */


           IF g1_debug_mode  = 'Y' THEN
           	PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || 'PF Currency  ' || l_projfunc_currency_code_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || 'PC Currency  ' || l_project_currency_code_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || 'FC Currency  ' || l_funding_currency_code_tab(i));
           END IF;




           IF  (l_projfunc_currency_code_tab(i) = l_funding_currency_code_tab(i)) THEN

                l_pf_currency_flag := 'Y';

           END IF;


           IF  (l_project_currency_code_tab(i) = l_funding_currency_code_tab(i)) THEN

                l_prj_currency_flag := 'Y';

           END IF;

           /* Revenue in foreign currency */
	   l_pf_currency_flag_rtc_tab(i) := 'N';
	   l_bt_currency_flag_rtc_tab(i) := 'N';
           If l_mcb_flag = 'Y'  AND  l_inv_by_btc_flag = 'N' AND l_rev_in_txn_curr_flag = 'Y' Then

		   IF  (l_projfunc_currency_code_tab(i) = l_revtrans_currency_code_tab(i)) THEN

			l_pf_currency_flag_rtc_tab(i) := 'Y';

		   ELSIF  (l_bill_trans_currency_code_tab(i) = l_revtrans_currency_code_tab(i)) THEN

			l_bt_currency_flag_rtc_tab(i) := 'Y';

                   ELSIF (l_bill_trans_currency_code_tab(i) <> l_revtrans_currency_code_tab(i)) THEN

                        l_bt_currency_flag_rtc_tab(i) := 'N';
			l_pf_currency_flag_rtc_tab(i) := 'N';

		   END IF;

           End If;

          /*  Initializing the array variables */


            l_user_validate_flag_tab(I)      := 'Y';

            l_project_bill_rate_tab(I)       := NULL;
            l_projfunc_bill_rate_tab(I)      := NULL;
            l_funding_bill_rate_tab(I)       := NULL;
            l_project_denominator_tab(I)     := NULL;
            l_projfunc_denominator_tab(I)    := NULL;
            l_funding_denominator_tab(I)     := NULL;
            l_project_numerator_tab(I)       := NULL;
            l_projfunc_numerator_tab(I)      := NULL;
            l_funding_numerator_tab(I)       := NULL;
            l_project_status_tab(I)          := 'N';
            l_projfunc_status_tab(I)         := 'N';
            l_funding_status_tab(I)          := 'N';
            l_funding_amount_tab(i)          := NULL;

		l_projfunc_amount_tab(I) := null;
		l_revtrans_amount_tab(I) := null;
		l_revtrans_denominator_tab(I) := null;
		l_revtrans_numerator_tab(I) := null;
		l_revtrans_status_tab(I) := 'N';
            /* Copy the funding rate date to array variable */
/* Code added for bug 5907315 */
            l_previous_funding_rate_date := NULL;

	    IF fnd_profile_revenue_orig_rate = 'Y' THEN
	     l_previous_funding_rate_date := pa_date(l_ei_date_tab(I));
	    END IF;
/* End of code. Bug 5907315 */

/* Code commented for bug 5907315
            l_funding_rev_rate_date_tab(I) := l_funding_rate_date;
The statement is modified as below */
	   IF fnd_profile_revenue_orig_rate = 'Y' THEN
            l_funding_rev_rate_date_tab(I) := nvl(l_previous_funding_rate_date,l_funding_rate_date);
           ELSE
            l_funding_rev_rate_date_tab(I) := l_funding_rate_date;
           END IF;
/* End of bug 5907315 */

        /* Calculating BTC amount from bill trans raw revenue and raw revenue */

        l_BTC_amount_tab(I) :=
             PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(
                 ( l_revenue_amount_tab(I) / l_raw_revenue(I) ) * l_bill_trans_raw_revenue(I),l_bill_trans_currency_code_tab(i));


        /* Calculating the project amount from bill trans raw revenue and raw revenue */

        l_project_amount_tab(I) := PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(
             ( l_revenue_amount_tab(I) / l_raw_revenue(I) ) * l_project_raw_revenue(I),l_project_currency_code_tab(i));


          /* Calculating project functional amount from bill trans raw revenue and raw revenue */


        l_projfunc_amount_tab(I) := PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(
             ( l_revenue_amount_tab(I) / l_raw_revenue(I) ) * l_projfunc_raw_revenue(I), l_projfunc_currency_code_tab(i));


       /* Debug message for MCB testing */


           IF g1_debug_mode  = 'Y' THEN
           	PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || 'Bill Trans curr Code    :' || l_bill_trans_currency_code_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || 'Input revenue amount    :' || l_revenue_amount_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || 'Input Raw revenue       :' || l_raw_revenue(i));
           	PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || 'Input Bill trans raw rev:' || l_bill_trans_raw_revenue(i));
           	PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || 'Input Project raw rev   :' || l_project_raw_revenue(i));
           	PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || 'Input projfunc raw rev  :' || l_projfunc_raw_revenue(i));
           	PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || 'Calculated Project  amount:' || l_project_amount_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || 'Calculated projfunc amount:' || l_projfunc_amount_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || 'Funding Curr Code :' || l_funding_currency_code_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || 'Funding Rate Type :' || l_funding_rev_rate_type_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || 'Funding Rate date :' || l_funding_rev_rate_date_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || 'Funding xchg rate :' || l_funding_rev_xchg_rate_tab(i));
           END IF;

      END LOOP;



     --  BTC amounts to Funding currency  amount


           /* Passing the param (two currency code) to the convert_amount_bulk API, If any conversion fails
              then the API concatenate the code with error message */


           IF g1_debug_mode  = 'Y' THEN
           	PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || 'Calling convert_amount_bulk API for funding conversion');
           END IF;


    /* If Funding Currency are not equal to project and Project Functional currency then
       Convert the funding amount otherwise copy the Project or project Function attributes
       to funding currency */


           IF g1_debug_mode  = 'Y' THEN
           	PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || 'PF Currency flag ' || l_pf_currency_flag);
           	PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || 'PC Currency flag ' || l_prj_currency_flag);
           END IF;




      IF (l_pf_currency_flag <> 'Y') AND (l_prj_currency_flag <> 'Y') THEN

          l_conversion_between  := 'BTC_FC';


           IF g1_debug_mode  = 'Y' THEN
           	PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || 'Funding is not equal to PF and project .....');
           END IF;

           PA_MULTI_CURRENCY_BILLING.convert_amount_bulk(
                    p_from_currency_tab        => l_bill_trans_currency_code_tab,
                    p_to_currency_tab          => l_funding_currency_code_tab,
                    p_conversion_date_tab      => l_funding_rev_rate_date_tab,
                    p_conversion_type_tab      => l_funding_rev_rate_type_tab,
                    p_amount_tab               => l_BTC_amount_tab,
                    p_user_validate_flag_tab   => l_user_validate_flag_tab,
                    p_converted_amount_tab     => l_funding_amount_tab,
                    p_denominator_tab          => l_funding_denominator_tab,
                    p_numerator_tab            => l_funding_numerator_tab,
                    p_rate_tab                 => l_funding_rev_xchg_rate_tab,
                    p_conversion_between       => l_conversion_between,
                    p_cache_flag               => l_cache_flag,
                    x_status_tab               => l_funding_status_tab
                    );


         END IF;


         IF g1_debug_mode  = 'Y' THEN
         	PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || 'after Calling convert_amount_bulk API for funding conversion');
         END IF;

         l_counter := 1;


         FOR I in 1 ..l_ei_id_tab.COUNT
         LOOP


           /* If Funding Currency are not equal to project and Project Functional currency then
              Convert the funding amount otherwise copy the Project or project Function attributes
              to funding currency */


               IF (l_pf_currency_flag = 'Y') THEN

                    IF g1_debug_mode  = 'Y' THEN
                    	PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || '....PF Currency = Funding currency.....');
                    END IF;

                    l_funding_currency_code_tab(i)     := l_projfunc_currency_code_tab(i);
                    l_funding_rev_rate_type_tab(i)     := l_projfunc_rev_rate_type_tab(i);
                    l_funding_rev_rate_date_tab(i)     := l_projfunc_rev_rate_date_tab(i);
                    l_funding_rev_xchg_rate_tab(i)     := l_projfunc_rev_xchg_rate_tab(i);
                    l_funding_amount_tab(i)            := l_projfunc_amount_tab(i);
                    l_funding_status_tab(i)            := 'N';

               ELSIF (l_prj_currency_flag  = 'Y') THEN

                    IF g1_debug_mode  = 'Y' THEN
                    	PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || '....Project currency = Funding currency.....');
                    END IF;

                    l_funding_currency_code_tab(i)     := l_project_currency_code_tab(i);
                    l_funding_rev_rate_type_tab(i)     := l_project_rev_rate_type_tab(i);
                    l_funding_rev_rate_date_tab(i)     := l_project_rev_rate_date_tab(i);
                    l_funding_rev_xchg_rate_tab(i)     := l_project_rev_xchg_rate_tab(i);
                    l_funding_amount_tab(i)            := l_project_amount_tab(i);
                    l_funding_status_tab(i)            := 'N';

                END IF;


           /* Get the draft revenue number for conversion fail cases
              to mark in pa_draft_revenues table  */


           IF g1_debug_mode  = 'Y' THEN
           	PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || 'Inside the loop ........');
           END IF;

            IF  l_funding_status_tab(i) <> 'N' THEN


                l_error_draft_rev_num_tab(l_counter)  := l_draft_revenue_num_tab(I);

                l_error_ei_id_tab(l_counter)          := l_ei_id_tab(I);

                l_error_funding_status_tab(l_counter) := l_funding_status_tab(I);

                l_counter := l_counter + 1;


            END IF;



        -- Log Messages for Events Converted Amounts

           IF g1_debug_mode  = 'Y' THEN
           	PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || 'Expenditure Item Id :' || l_ei_id_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || 'Line Num :' || l_line_num_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || 'Draft revenue Num :' || l_draft_revenue_num_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || 'Bill Trans Currency Code :' || l_bill_trans_currency_code_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || 'Output Bill Trans Amount:' || l_BTC_amount_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || 'Output Project Amount :' || l_project_amount_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || 'Output Project Func Amount :' || l_projfunc_amount_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || 'Funding Curr Code :' || l_funding_currency_code_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || 'Funding Rate Type :' || l_funding_rev_rate_type_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || 'Funding Rate date :' || l_funding_rev_rate_date_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || 'Funding Echg rate :' || l_funding_rev_xchg_rate_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || 'Funding Amt Rejection Reason :' || l_funding_status_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || 'Convert Funding Amount :' || l_funding_amount_tab(i));
           END IF;



          IF l_error_draft_rev_num_tab.EXISTS(i) THEN

              IF g1_debug_mode  = 'Y' THEN
              	PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || 'Error Draft revenue num :' || l_error_draft_rev_num_tab(i));
              END IF;

          END IF;


        END LOOP;

         IF g1_debug_mode  = 'Y' THEN
         	PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || 'after Calling convert_amount_bulk API for funding conversion');
         END IF;

         l_counter := 1;


         FOR I in 1 .. l_ei_id_tab.COUNT
         LOOP

           IF l_rev_in_txn_curr_flag = 'Y' AND l_mcb_flag = 'Y'  AND  l_inv_by_btc_flag = 'N' THEN

           /* If revenue txn Currency is not equal to transaction and Project Functional currency then
              Convert the revenue txn amount otherwise copy the transaction or project Functional attributes
              to revenue txn currency */

	 -- Log Messages

           IF g1_debug_mode  = 'Y' THEN
                PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || 'Expenditure Item Id :' || l_ei_id_tab(i));
                PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || 'Line Num :' || l_line_num_tab(i));
                PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || 'Draft revenue Num :' || l_draft_revenue_num_tab(i));
                PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: '||'Bill Trans Currency Code :'||l_bill_trans_currency_code_tab(i));
                PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || 'Bill Trans Amount:' || l_BTC_amount_tab(i));
                PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || 'Output Project Func Amount :' || l_projfunc_amount_tab(i));
                PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || 'Revtrans Curr Code :' || l_revtrans_currency_code_tab(i));
                PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || 'Revtrans Rate Type :' || l_revtrans_rate_type_tab(i));
                PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || 'Revtrans Rate date :' || l_revtrans_rate_date_tab(i));
                PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || 'Revtrans Echg rate :' || l_revtrans_xchg_rate_tab(i));
                PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || 'Revtrans Rejection Reason :' || l_revtrans_status_tab(i));
                PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || 'Convert Revtrans Amount :' || l_revtrans_amount_tab(i));
           END IF;


               IF (l_pf_currency_flag_rtc_tab(i) = 'Y') THEN

                    IF g1_debug_mode  = 'Y' THEN
                    	PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || '....PF Currency = RT Currency.....');
                    END IF;

                    l_revtrans_rate_type_tab(i)     := NULL;
                    l_revtrans_rate_date_tab(i)     := NULL;
                    l_revtrans_xchg_rate_tab(i)     := NULL;
                    l_revtrans_amount_tab(i)        := l_projfunc_amount_tab(i);
                    l_revtrans_status_tab(i)        := 'N';

               ELSIF (l_bt_currency_flag_rtc_tab(i)  = 'Y') THEN

                    IF g1_debug_mode  = 'Y' THEN
                    	PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || '....BT Currency = RT currency.....');
                    END IF;

                    l_revtrans_rate_type_tab(i)     := l_projfunc_rev_rate_type_tab(i);
                    l_revtrans_rate_date_tab(i)     := l_projfunc_rev_rate_date_tab(i);
                    l_revtrans_xchg_rate_tab(i)     := 1/l_projfunc_rev_xchg_rate_tab(i);
                    l_revtrans_amount_tab(i)            := l_BTC_amount_tab(i);
                    l_revtrans_status_tab(i)            := 'N';

               ELSIF ((l_pf_currency_flag_rtc_tab(i) <> 'Y') AND (l_bt_currency_flag_rtc_tab(i) <> 'Y'))
                THEN

		   l_conversion_between  := 'RC_RTC';


		   IF g1_debug_mode  = 'Y' THEN
			PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || 'Revenue Txn is not equal to PFC and BTC .....');
		   END IF;

			l_pf_currency_code_t1_tab(1) := null;
			l_rt_currency_code_t1_tab(1) := null;
			l_rt_rate_date_t1_tab(1) := null;
			l_rt_rate_type_t1_tab(1) := null;
			l_pf_amount_t1_tab(1) := null;
			l_user_validate_flag_t1_tab(1) := 'N';
			l_rt_amount_t1_tab(1) := null;
			l_rt_denominator_t1_tab(1) := null;
			l_rt_numerator_t1_tab(1) := null;
			l_rt_xchg_rate_t1_tab(1) :=  null;
			l_rt_status_t1_tab(1) := 'N';

			l_pf_currency_code_t1_tab(1) := l_projfunc_currency_code_tab(i);
			l_rt_currency_code_t1_tab(1) := l_revtrans_currency_code_tab(i);
			l_rt_rate_date_t1_tab(1) := l_revtrans_rate_date_tab(i);
			l_rt_rate_type_t1_tab(1) := l_revtrans_rate_type_tab(i);
			l_pf_amount_t1_tab(1) := l_projfunc_amount_tab(i);
			l_user_validate_flag_t1_tab(1) := l_user_validate_flag_tab(i);
			l_rt_xchg_rate_t1_tab(1) := l_revtrans_xchg_rate_tab(i);  -- Bug 4760091

                   IF g1_debug_mode  = 'Y' THEN
		      PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: '||'Before convert_amount_bulk to derive rtc amt.....');
                   END IF;

		   PA_MULTI_CURRENCY_BILLING.convert_amount_bulk(
			    p_from_currency_tab        => l_pf_currency_code_t1_tab,
			    p_to_currency_tab          => l_rt_currency_code_t1_tab,
			    p_conversion_date_tab      => l_rt_rate_date_t1_tab,
			    p_conversion_type_tab      => l_rt_rate_type_t1_tab,
			    p_amount_tab               => l_pf_amount_t1_tab,
			    p_user_validate_flag_tab   => l_user_validate_flag_t1_tab,
			    p_converted_amount_tab     => l_rt_amount_t1_tab,
			    p_denominator_tab          => l_rt_denominator_t1_tab,
			    p_numerator_tab            => l_rt_numerator_t1_tab,
			    p_rate_tab                 => l_rt_xchg_rate_t1_tab,
			    p_conversion_between       => l_conversion_between,
			    p_cache_flag               => l_cache_flag,
			    x_status_tab               => l_rt_status_t1_tab
			    );

                   IF g1_debug_mode  = 'Y' THEN
		      PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: '||'After convert_amount_bulk to derive RTC Amt.....');
                   END IF;

			l_revtrans_rate_date_tab(i) := trunc(l_rt_rate_date_t1_tab(1));
			l_revtrans_rate_type_tab(i) := l_rt_rate_type_t1_tab(1);
			l_revtrans_amount_tab(i):= l_rt_amount_t1_tab(1);
			l_revtrans_denominator_tab(i):= l_rt_denominator_t1_tab(1);
			l_revtrans_numerator_tab(i) := l_rt_numerator_t1_tab(1);
			l_revtrans_xchg_rate_tab(i) := l_rt_xchg_rate_t1_tab(1);
			l_revtrans_status_tab(i)        := l_rt_status_t1_tab(1);

                   IF g1_debug_mode  = 'Y' THEN
			PA_MCB_INVOICE_PKG.log_message('Rev trans rate date after conv is.....'||l_revtrans_rate_date_tab(i));
			PA_MCB_INVOICE_PKG.log_message('l_revtrans_status_tab('||i||') is.....'||l_revtrans_status_tab(i));
                   END IF;
               END IF;
             ELSE
                   IF g1_debug_mode  = 'Y' THEN
			PA_MCB_INVOICE_PKG.log_message('Revenue not in foreign curr/mcb disabled/inv by btc enabled...');
                   END IF;
                    l_revtrans_currency_code_tab(i)     := l_projfunc_currency_code_tab(i);
                    l_revtrans_rate_type_tab(i)     := NULL;
                    l_revtrans_rate_date_tab(i)     := NULL;
                    l_revtrans_xchg_rate_tab(i)     := NULL;
                    l_revtrans_amount_tab(i)        := l_projfunc_amount_tab(i);
                    l_revtrans_status_tab(i)        := 'N';

	 -- Log Messages

           IF g1_debug_mode  = 'Y' THEN
                PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || 'Expenditure Item Id :' || l_ei_id_tab(i));
                PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || 'Line Num :' || l_line_num_tab(i));
                PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || 'Draft revenue Num :' || l_draft_revenue_num_tab(i));
                PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: '||'Bill Trans Currency Code :'||l_bill_trans_currency_code_tab(i));
                PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || 'Bill Trans Amount:' || l_BTC_amount_tab(i));
                PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || 'Output Project Func Amount :' || l_projfunc_amount_tab(i));
                PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || 'Revtrans Curr Code :' || l_revtrans_currency_code_tab(i));
                PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || 'Revtrans Rate Type :' || l_revtrans_rate_type_tab(i));
                PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || 'Revtrans Rate date :' || l_revtrans_rate_date_tab(i));
                PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || 'Revtrans Echg rate :' || l_revtrans_xchg_rate_tab(i));
                PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || 'Revtrans Rejection Reason :' || l_revtrans_status_tab(i));
                PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || 'Convert Revtrans Amount :' || l_revtrans_amount_tab(i));
           END IF;

             END IF;


           /* Get the draft revenue number for conversion fail cases
              to mark in pa_draft_revenues table  */


           IF g1_debug_mode  = 'Y' THEN
           	PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || 'Before setting the error status........');
           END IF;

            IF  l_revtrans_status_tab(i) <> 'N' THEN


                l_error_rt_dr_rev_num_tab(l_counter)  := l_draft_revenue_num_tab(I);

                l_error_ei_id_tab(l_counter)          := l_ei_id_tab(I);

                l_error_revtrans_status_tab(l_counter) := l_revtrans_status_tab(I);

                l_counter := l_counter + 1;


            END IF;


          IF l_error_draft_rev_num_tab.EXISTS(i) THEN

              IF g1_debug_mode  = 'Y' THEN
              	PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || 'Error Draft revenue num :' || l_error_draft_rev_num_tab(i));
              END IF;

          END IF;


        END LOOP;

  /* i) Updating the converted project amount, project functional amount,
        funding amount and update the rev_dist_rejection_code
    ii) Call the round currency function for bill_trans_amount, project_revenue_amount,
        projfunc_revenue_amount for calculated values
   iii) Funding amount converted through the convert_amount_bulk API, its rounded automatically
        as per the funding currency code, so not necessary to call             */


         FORALL I IN 1 .. l_ei_id_tab.COUNT
              UPDATE pa_cust_rev_dist_lines
                 SET bill_trans_amount        =
                     PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(
                                       l_BTC_amount_tab(i),l_bill_trans_currency_code_tab(i)),
                     project_revenue_amount   =
                        PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(
                                         l_project_amount_tab(i),l_project_currency_code_tab(i)),
                      projfunc_revenue_amount  =
                          PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(
                                        l_projfunc_amount_tab(i),l_projfunc_currency_code_tab(i)),
                      funding_revenue_amount   =
                           DECODE(l_funding_status_tab(I), 'N',
                          PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(
                                        l_funding_amount_tab(I),l_funding_currency_code_tab(i)),
                                          NULL),
                      funding_rev_rate_type =
                           DECODE(l_funding_status_tab(I), 'N', l_funding_rev_rate_type_tab(I),NULL),
                      funding_rev_rate_date     =
                        DECODE(l_funding_status_tab(I), 'N', l_funding_rev_rate_date_tab(i),funding_rev_rate_date),
                      funding_rev_exchange_rate =
                      DECODE(l_funding_status_tab(I), 'N', l_funding_rev_xchg_rate_tab(i), funding_rev_exchange_rate),
                      revtrans_currency_code =
                           DECODE(l_revtrans_status_tab(I), 'N', l_revtrans_currency_code_tab(I),NULL),
                      revtrans_amount   =
                           DECODE(l_revtrans_status_tab(I), 'N',
                          PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(
                                        l_revtrans_amount_tab(I),l_revtrans_currency_code_tab(i)), NULL),
                      revproc_revtrans_rate_type =
                           DECODE(l_revtrans_status_tab(I), 'N', l_revtrans_rate_type_tab(I),NULL),
                      revproc_revtrans_rate_date     =
                        DECODE(l_revtrans_status_tab(I), 'N', l_revtrans_rate_date_tab(i),NULL),
                      revproc_revtrans_ex_rate =
                      DECODE(l_revtrans_status_tab(I), 'N', l_revtrans_xchg_rate_tab(i), NULL)
                WHERE expenditure_item_id = l_ei_id_tab(I)
                  AND line_num = l_line_num_tab(I);

         IF g1_debug_mode  = 'Y' THEN
           PA_MCB_INVOICE_PKG.log_message('No of Rows Updated in RDL :' || SQL%ROWCOUNT);
         END IF;


   /* Marking Draft Revenues as error, If error exist in RDL amount conversion */

           PA_MCB_INVOICE_PKG.log_message('Before updating RTC error code..BPC...:' );

     IF l_rev_in_txn_curr_flag = 'Y' THEN
      IF l_error_rt_dr_rev_num_tab.COUNT <> 0  THEN

        FORALL J IN 1 .. l_error_rt_dr_rev_num_tab.COUNT
                  UPDATE pa_draft_revenues
                     SET generation_error_flag = 'Y',
                         transfer_rejection_reason = l_error_revtrans_status_tab(j)
                   WHERE project_id = p_project_id
                     AND draft_revenue_num = l_error_rt_dr_rev_num_tab(J);

         IF g1_debug_mode  = 'Y' THEN
           PA_MCB_INVOICE_PKG.log_message('No of Rows Marked Error in Draft Revenue :' || SQL%ROWCOUNT);
         END IF;

      END IF;
    END IF;

      IF l_error_draft_rev_num_tab.COUNT <> 0  THEN

        FORALL J IN 1 .. l_error_draft_rev_num_tab.COUNT
                  UPDATE pa_draft_revenues
                     SET generation_error_flag = 'Y',
                         transfer_rejection_reason = l_error_funding_status_tab(J)
                   WHERE project_id = p_project_id
                     AND draft_revenue_num = l_error_draft_rev_num_tab(J);

         IF g1_debug_mode  = 'Y' THEN
           PA_MCB_INVOICE_PKG.log_message('No of Rows Marked Error in Draft Revenue :' || SQL%ROWCOUNT);
         END IF;

      END IF;

           PA_MCB_INVOICE_PKG.log_message('After updating error code..BPC...:' );


   END IF;      /* l_ei_id_tab.COUNT <> 0 */




       EXIT WHEN rdl_amt_csr%NOTFOUND;


   END LOOP;

          CLOSE rdl_amt_csr;


   EXCEPTION
     WHEN OTHERS THEN
           IF g1_debug_mode  = 'Y' THEN
           	PA_MCB_INVOICE_PKG.log_message('rdl_amount_conversion: ' || 'Error in rdl conversion :' || sqlerrm);
           END IF;
          x_return_status := sqlerrm( sqlcode );

END rdl_amount_conversion;


/*----------------------------------------------------------------------------------------+
|   Procedure  :   erdl_amount_conversion                                                 |
|   Purpose    :   To update the ERDL table                                               |
|                  (bill transaction currency to Funding Currency)                        |
|                                                                                         |
|   Parameters :                                                                          |
|     ==================================================================================  |
|     Name               Mode    Description                                              |
|     ==================================================================================  |
|     p_btc_code               IN      Bill transaction currency code                     |
|     p_btc_amount             IN      Bill transaction amount                            |
|     p_funding_curr_code      IN      Funding currency code to convert funding amount    |
|     x_funding_rate_type      IN OUT  Funding Rate type to convert funding amount        |
|     x_funding_rate_rate      IN OUT  Funding Rate date to convert funding amount        |
|     x_funding_exchange_rate  IN OUT  Funding Exchange Rate to convert funding amount    |
|     x_funding_amount         IN OUT  Converted funding amount                           |
|     x_funding_convert_status IN OUT  If converted the pass NULL else pass error code    |
|     x_return_status          IN OUT  Return status of this procedure                    |
|     x_msg_count              IN OUT  Error message count                                |
|     x_msg_data               IN OUT  Error message                                      |
|     ==================================================================================  |
+----------------------------------------------------------------------------------------*/

PROCEDURE erdl_amount_conversion( p_project_id               IN     NUMBER,
                                  p_draft_revenue_num        IN     NUMBER,
                                  p_btc_code                 IN     VARCHAR2,
                                  p_btc_amount               IN     VARCHAR2,
                                  p_funding_rate_date        IN     VARCHAR2,
                                  p_funding_curr_code        IN     VARCHAR2,
                                  x_funding_rate_type        IN OUT NOCOPY VARCHAR2,
                                  x_funding_rate_date        IN OUT NOCOPY VARCHAR2,
                                  x_funding_exchange_rate    IN OUT NOCOPY VARCHAR2,
                                  x_funding_amount           IN OUT NOCOPY VARCHAR2,
                                  x_funding_convert_status   IN OUT NOCOPY VARCHAR2,
			            p_projfunc_curr_code     IN     VARCHAR2,
                                    p_projfunc_amount        IN     VARCHAR2,
                                    p_projfunc_rate_type     IN     VARCHAR2,
                                    p_projfunc_rate_date     IN     VARCHAR2,
                                    p_projfunc_exch_rate     IN     VARCHAR2,
                                    p_revtrans_curr_code     IN     VARCHAR2,
                                    p_calling_place          IN     VARCHAR2,
                                    x_revtrans_rate_type     IN OUT NOCOPY VARCHAR2,
                                    x_revtrans_rate_date     IN OUT NOCOPY VARCHAR2,
                                    x_revtrans_exch_rate     IN OUT NOCOPY VARCHAR2,
                                    x_revtrans_amount        IN OUT NOCOPY VARCHAR2,
                                  x_return_status            IN OUT NOCOPY VARCHAR2,
                                  x_msg_count                IN OUT NOCOPY NUMBER,
                                  x_msg_data                 IN OUT NOCOPY VARCHAR2
                                ) IS


      l_btc_amount_tab                     PA_PLSQL_DATATYPES.NumTabTyp;
      l_bill_trans_currency_code_tab       PA_PLSQL_DATATYPES.Char30TabTyp;
      l_funding_currency_code_tab          PA_PLSQL_DATATYPES.Char30TabTyp;
      l_funding_rev_rate_type_tab          PA_PLSQL_DATATYPES.Char30TabTyp;
      l_funding_rev_rate_date_tab          PA_PLSQL_DATATYPES.DateTabTyp;
      l_funding_rev_xchg_rate_tab          PA_PLSQL_DATATYPES.NumTabTyp;
      l_funding_amount_tab                 PA_PLSQL_DATATYPES.NumTabTyp;
      l_funding_status_tab                 PA_PLSQL_DATATYPES.Char30TabTyp;
      l_user_validate_flag_tab             PA_PLSQL_DATATYPES.Char30TabTyp;
      l_funding_denominator_tab            PA_PLSQL_DATATYPES.NumTabTyp;
      l_funding_numerator_tab              PA_PLSQL_DATATYPES.NumTabTyp;
      l_funding_bill_rate_tab              PA_PLSQL_DATATYPES.NumTabTyp;

      l_funding_rate_date                  DATE;

      l_conversion_between             VARCHAR2(6);
      l_cache_flag                     VARCHAR2(1);

      /* Revenue in foreign currency */
      l_mcb_flag                     VARCHAR2(1);
      l_inv_by_btc_flag                     VARCHAR2(1);

      l_pfc_amount_tab                     PA_PLSQL_DATATYPES.NumTabTyp;
      l_projfunc_currency_code_tab       PA_PLSQL_DATATYPES.Char30TabTyp;
      l_revtrans_currency_code_tab          PA_PLSQL_DATATYPES.Char30TabTyp;
      l_revtrans_rate_type_tab          PA_PLSQL_DATATYPES.Char30TabTyp;
      l_revtrans_rate_date_tab          PA_PLSQL_DATATYPES.DateTabTyp;
      l_revtrans_xchg_rate_tab          PA_PLSQL_DATATYPES.NumTabTyp;
      l_revtrans_amount_tab                 PA_PLSQL_DATATYPES.NumTabTyp;
      l_revtrans_denominator_tab            PA_PLSQL_DATATYPES.NumTabTyp;
      l_revtrans_numerator_tab              PA_PLSQL_DATATYPES.NumTabTyp;

      /* Added for NOCOPY change */
      l_x_funding_rate_type         VARCHAR2(30) := x_funding_rate_type;
      l_x_funding_rate_date         VARCHAR2(10) := x_funding_rate_date;
      l_x_funding_exchange_rate     VARCHAR2(30) := x_funding_exchange_rate;
      l_x_funding_amount            VARCHAR2(30) := x_funding_amount;
      l_x_funding_convert_status    VARCHAR2(30) := x_funding_convert_status;
      l_x_revtrans_rate_type        VARCHAR2(30) := x_revtrans_rate_type;
      l_x_revtrans_rate_date        VARCHAR2(10) := x_revtrans_rate_date;
      l_x_revtrans_exch_rate        VARCHAR2(30) := x_revtrans_exch_rate;

  BEGIN


        /* This flag is N then the convert_amount_bulk API not cache any currency code,
           If the flag is Y then it cache the currency and other attributes for avoid the
           repeat processing. */

        l_cache_flag   := 'N';

    IF p_calling_place = 'FC' THEN

      IF g1_debug_mode  = 'Y' THEN
      	PA_MCB_INVOICE_PKG.log_message('erdl_amount_conversion: ' || '....Inside the Procedure ERDL conversion');
      	PA_MCB_INVOICE_PKG.log_message('erdl_amount_conversion: ' || '---------------------------------------');
      END IF;



      /* Converting the funding rate date Character to DATE format */


     /*File.Date.5. Added format to the p_funding_rate_date which was missing*/
     l_funding_rate_date     := TO_DATE(p_funding_rate_date,'YYYY/MM/DD');


      x_return_status := NULL;


      /* Copy the Input funding attributed to array variables */

      l_btc_amount_tab(1)                  :=  p_btc_amount;
      l_bill_trans_currency_code_tab(1)    :=  p_btc_code;
      l_funding_currency_code_tab(1)       :=  p_funding_curr_code;
      l_funding_rev_rate_type_tab(1)       :=  x_funding_rate_type;
      l_funding_rev_rate_date_tab(1)       :=  x_funding_rate_date;
      l_funding_rev_xchg_rate_tab(1)       :=  x_funding_exchange_rate;
      l_funding_amount_tab(1)              :=  NULL;
      l_funding_status_tab(1)              :=  'N';
      l_user_validate_flag_tab(1)          :=  'Y';
      l_funding_denominator_tab(1)         :=  NULL;
      l_funding_numerator_tab(1)           :=  NULL;
      l_funding_bill_rate_tab(1)           :=  NULL;



      /* If funding rate date is null then take the funding rate from projects table */

      IF l_funding_rev_rate_date_tab(1) IS NULL THEN

         l_funding_rev_rate_date_tab(1) := l_funding_rate_date;

      END IF;



     --  BTC amounts to Funding currency amount conversion

      IF g1_debug_mode  = 'Y' THEN
      	PA_MCB_INVOICE_PKG.log_message('erdl_amount_conversion: ' || 'Calling the Funding Amount conversion procedure');
      END IF;


           /* Passing the param (two currency code) to the convert_amount_bulk API, If any conversion fails
              then the API concatenate the code with error message */

              l_conversion_between  := 'BTC_FC';


           PA_MULTI_CURRENCY_BILLING.convert_amount_bulk(
                    p_from_currency_tab        => l_bill_trans_currency_code_tab,
                    p_to_currency_tab          => l_funding_currency_code_tab,
                    p_conversion_date_tab      => l_funding_rev_rate_date_tab,
                    p_conversion_type_tab      => l_funding_rev_rate_type_tab,
                    p_amount_tab               => l_btc_amount_tab,
                    p_user_validate_flag_tab   => l_user_validate_flag_tab,
                    p_converted_amount_tab     => l_funding_amount_tab,
                    p_denominator_tab          => l_funding_denominator_tab,
                    p_numerator_tab            => l_funding_numerator_tab,
                    p_rate_tab                 => l_funding_rev_xchg_rate_tab,
                    p_conversion_between       => l_conversion_between,
                    p_cache_flag               => l_cache_flag,
                    x_status_tab               => l_funding_status_tab
                    );


      /* Copy the converted amount and attributes to OUT variables */


      x_funding_rate_type          := l_funding_rev_rate_type_tab(1);
      x_funding_rate_date          := l_funding_rev_rate_date_tab(1);
      x_funding_exchange_rate      := l_funding_rev_xchg_rate_tab(1);
      x_funding_amount             := l_funding_amount_tab(1);
      x_funding_convert_status     := l_funding_status_tab(1);


       -- Log Messages for Funding amount conversion in ERDL


           IF g1_debug_mode  = 'Y' THEN
           	PA_MCB_INVOICE_PKG.log_message('erdl_amount_conversion: ' || 'Project Id :' || p_project_id);
           	PA_MCB_INVOICE_PKG.log_message('erdl_amount_conversion: ' || 'Draft revenue Num :' || p_draft_revenue_num);
           	PA_MCB_INVOICE_PKG.log_message('erdl_amount_conversion: ' || 'Bill Trans Currency Code :' || p_btc_code);
           	PA_MCB_INVOICE_PKG.log_message('erdl_amount_conversion: ' || 'Bill Trans Amount :' || p_btc_amount);
           	PA_MCB_INVOICE_PKG.log_message('erdl_amount_conversion: ' || 'Funding Currency Code :' || p_funding_curr_code);
           	PA_MCB_INVOICE_PKG.log_message('erdl_amount_conversion: ' || 'Funding rate type :' || l_funding_rev_rate_type_tab(1));
           	PA_MCB_INVOICE_PKG.log_message('erdl_amount_conversion: ' || 'Funding rate date :' || l_funding_rev_rate_date_tab(1));
           	PA_MCB_INVOICE_PKG.log_message('erdl_amount_conversion: ' || 'Funding exchange rate :' || l_funding_rev_xchg_rate_tab(1));
           	PA_MCB_INVOICE_PKG.log_message('erdl_amount_conversion: ' || 'Funding Amt Rejection Reason :' || l_funding_status_tab(1));
           	PA_MCB_INVOICE_PKG.log_message('erdl_amount_conversion: ' || 'Convert Funding Amount :' || l_funding_amount_tab(1));
           END IF;



    /* Marking the draft revenues as error if funding conversion fails */


    IF (l_funding_status_tab(1) <> 'N') THEN

        UPDATE pa_draft_revenues
           SET generation_error_flag = 'Y',
               transfer_rejection_reason = l_funding_status_tab(1)
         WHERE project_id = p_project_id
           AND draft_revenue_num = p_draft_revenue_num;

    IF g1_debug_mode  = 'Y' THEN
      PA_MCB_INVOICE_PKG.log_message('No of Rows Updated as error in Draft Revenue : ' || SQL%ROWCOUNT);
    END IF;

    END IF;

  ELSIF p_calling_place = 'RTC' THEN

    /* Revenue in foreign currency - Start*/

      x_return_status := NULL;

	 -- Log Messages

           IF g1_debug_mode  = 'Y' THEN
           	PA_MCB_INVOICE_PKG.log_message('erdl_amount_conversion: ' || 'Project Id :' || p_project_id);
           	PA_MCB_INVOICE_PKG.log_message('erdl_amount_conversion: ' || 'Draft revenue Num :' || p_draft_revenue_num);
           	PA_MCB_INVOICE_PKG.log_message('erdl_amount_conversion: ' || 'Projfunc Currency Code :' || p_projfunc_curr_code);
           	PA_MCB_INVOICE_PKG.log_message('erdl_amount_conversion: ' || 'Projfunc Amount :' || p_projfunc_amount);
           	PA_MCB_INVOICE_PKG.log_message('erdl_amount_conversion: ' || 'Revtrans Currency Code :' || p_revtrans_curr_code);
           	PA_MCB_INVOICE_PKG.log_message('erdl_amount_conversion: ' || 'Revtrans Amount :' || x_revtrans_amount);
           	PA_MCB_INVOICE_PKG.log_message('erdl_amount_conversion: ' || 'Revtrans rate type :' || x_revtrans_rate_type);
           	PA_MCB_INVOICE_PKG.log_message('erdl_amount_conversion: ' || 'Revtrans rate date :' || x_revtrans_rate_date);
           	PA_MCB_INVOICE_PKG.log_message('erdl_amount_conversion: ' || 'Revtrans exchange rate :' || x_revtrans_exch_rate);
           END IF;
      /* Copy the Input revenue transactions  attributes to array variables */

      l_pfc_amount_tab(1)               :=  p_projfunc_amount;
      l_projfunc_currency_code_tab(1)   :=  p_projfunc_curr_code;
      l_revtrans_currency_code_tab(1)   :=  p_revtrans_curr_code;
      l_revtrans_rate_type_tab(1)       :=  x_revtrans_rate_type;
      l_revtrans_rate_date_tab(1)       :=  to_date(x_revtrans_rate_date, 'YYYY/MM/DD');    -- For bug 4751461
      l_revtrans_xchg_rate_tab(1)       :=  x_revtrans_exch_rate;
      l_revtrans_amount_tab(1)          :=  NULL;
      l_funding_status_tab(1)           :=  'N';
      l_user_validate_flag_tab(1)       :=  'Y';
      l_revtrans_denominator_tab(1)     :=  NULL;
      l_revtrans_numerator_tab(1)       :=  NULL;
      l_funding_bill_rate_tab(1)        :=  NULL;


      PA_MULTI_CURRENCY_BILLING.convert_amount_bulk(
	    p_from_currency_tab        => l_projfunc_currency_code_tab,
	    p_to_currency_tab          => l_revtrans_currency_code_tab,
	    p_conversion_date_tab      => l_revtrans_rate_date_tab,
	    p_conversion_type_tab      => l_revtrans_rate_type_tab,
	    p_amount_tab               => l_pfc_amount_tab,
	    p_user_validate_flag_tab   => l_user_validate_flag_tab,
	    p_converted_amount_tab     => l_revtrans_amount_tab,
	    p_denominator_tab          => l_revtrans_denominator_tab,
	    p_numerator_tab            => l_revtrans_numerator_tab,
	    p_rate_tab                 => l_revtrans_xchg_rate_tab,
	    p_conversion_between       => 'RC_RTC',
	    p_cache_flag               => l_cache_flag,
	    x_status_tab               => l_funding_status_tab
	    );


      /* Copy the converted amount and attributes to OUT variables */

      x_revtrans_rate_type          := l_revtrans_rate_type_tab(1);
      x_revtrans_rate_date          := l_revtrans_rate_date_tab(1);
      x_revtrans_exch_rate          := l_revtrans_xchg_rate_tab(1);
      x_revtrans_amount             := l_revtrans_amount_tab(1);
      x_funding_convert_status     := l_funding_status_tab(1);

	 -- Log Messages

           IF g1_debug_mode  = 'Y' THEN
           	PA_MCB_INVOICE_PKG.log_message('erdl_amount_conversion: ' || 'Project Id :' || p_project_id);
           	PA_MCB_INVOICE_PKG.log_message('erdl_amount_conversion: ' || 'Draft revenue Num :' || p_draft_revenue_num);
           	PA_MCB_INVOICE_PKG.log_message('erdl_amount_conversion: ' || 'Projfunc Currency Code :' || p_projfunc_curr_code);
           	PA_MCB_INVOICE_PKG.log_message('erdl_amount_conversion: ' || 'Projfunc Amount :' || p_projfunc_amount);
           	PA_MCB_INVOICE_PKG.log_message('erdl_amount_conversion: ' || 'Revtrans Currency Code :' || p_revtrans_curr_code);
           	PA_MCB_INVOICE_PKG.log_message('erdl_amount_conversion: ' || 'Revtrans Amount :' || x_revtrans_amount);
           	PA_MCB_INVOICE_PKG.log_message('erdl_amount_conversion: ' || 'Revtrans rate type :' || x_revtrans_rate_type);
           	PA_MCB_INVOICE_PKG.log_message('erdl_amount_conversion: ' || 'Revtrans rate date :' || x_revtrans_rate_date);
           	PA_MCB_INVOICE_PKG.log_message('erdl_amount_conversion: ' || 'Revtrans exchange rate :' || x_revtrans_exch_rate);
           	PA_MCB_INVOICE_PKG.log_message('erdl_amount_conversion: ' || 'Revtrans Amt Rejection Reason :' || l_funding_status_tab(1));
           END IF;
       IF (l_funding_status_tab(1) <> 'N') THEN

            UPDATE pa_draft_revenues
               SET generation_error_flag = 'Y',
               transfer_rejection_reason = l_funding_status_tab(1)
             WHERE project_id = p_project_id
               AND draft_revenue_num = p_draft_revenue_num;

	    IF g1_debug_mode  = 'Y' THEN
	      PA_MCB_INVOICE_PKG.log_message('No of Rows Updated as error in Draft Revenue : ' || SQL%ROWCOUNT);
	    END IF;

       END IF;

    END IF;
    /* Revenue in foreign currency - End*/

   EXCEPTION
     WHEN OTHERS THEN
          IF g1_debug_mode  = 'Y' THEN
          	PA_MCB_INVOICE_PKG.log_message('Error in Erdl_amount_conversion ' || sqlerrm);
          END IF;
          x_return_status := sqlerrm( sqlcode );
      /* Added for NOCOPY change */
      x_funding_rate_type         := l_x_funding_rate_type;
      x_funding_rate_date         := l_x_funding_rate_date;
      x_funding_exchange_rate     := l_x_funding_exchange_rate;
      x_funding_amount            := l_x_funding_amount;
      x_funding_convert_status    := l_x_funding_convert_status;
      x_revtrans_rate_type        := l_x_revtrans_rate_type;
      x_revtrans_rate_date        := l_x_revtrans_rate_date;
      x_revtrans_exch_rate        := l_x_revtrans_exch_rate;
END erdl_amount_conversion;


/*----------------------------------------------------------------------------------------+
|   Procedure  :   ei_fcst_amount_conversion                                                   |
|   Purpose    :   To update the pa_expenditure_items_all table
|                  (bill transaction currency to  revenue processing currency for         |
|                    forecast revenue
|   Parameters :                                                                          |
|     ==================================================================================  |
|     Name               Mode    Description                                              |
|     ==================================================================================  |
|     p_project_id        IN      project Id                                              |
|     ei_id               IN      Expenditure item id
|     p_request_id        IN      Id for the current  Run                                 |
|     p_pa_date           IN      Project Accounting date                                 |
|     x_return_status     IN OUT  Return status of this procedure                         |
|     x_msg_count         IN OUT  Error message count                                     |
|     x_msg_data          IN OUT  Error message                                           |
|     ==================================================================================  |
+----------------------------------------------------------------------------------------*/

PROCEDURE ei_fcst_amount_conversion(
                               p_project_id       IN       NUMBER,
                               p_ei_id            IN       PA_PLSQL_DATATYPES.IdTabTyp,
                               p_request_id       IN       NUMBER,
                               p_pa_date          IN       VARCHAR2,
                               x_return_status    IN OUT NOCOPY   VARCHAR2,
                               x_msg_count        IN OUT NOCOPY   NUMBER,
                               x_msg_data         IN OUT NOCOPY   VARCHAR2) IS


      CURSOR ei_fcst_amt_csr (p_request_id NUMBER) IS
      SELECT project_id,            /* 2456371 */
             expenditure_item_id,
             bill_trans_forecast_revenue,
             bill_trans_forecast_curr_code
        FROM pa_expenditure_items_all
       WHERE request_id = p_request_id
         AND revenue_distributed_flag = 'F'
         AND bill_trans_forecast_revenue IS NOT NULL
         AND forecast_revenue IS NULL
       ORDER BY project_id;        /* 2456371 */


      l_ei_id_tab                      PA_PLSQL_DATATYPES.IdTabTyp;
      l_bill_trans_rev_amount_tab      PA_PLSQL_DATATYPES.NumTabTyp;
      l_bill_trans_adj_rev_tab         PA_PLSQL_DATATYPES.NumTabTyp;
      l_bill_trans_curr_code_tab       PA_PLSQL_DATATYPES.Char30TabTyp;

      l_project_id_tab                 PA_PLSQL_DATATYPES.IdTabTyp;    /* 2456371 */

      l_revproc_rate_type_tab          PA_PLSQL_DATATYPES.Char30TabTyp;
      l_revproc_rate_date_tab          PA_PLSQL_DATATYPES.DateTabTyp;
      l_revproc_exchange_rate_tab      PA_PLSQL_DATATYPES.NumTabTyp;
      l_revproc_curr_code_tab          PA_PLSQL_DATATYPES.Char30TabTyp;
      l_revproc_amount_tab             PA_PLSQL_DATATYPES.NumTabTyp;


      l_bill_trans_proj_amt_tab      PA_PLSQL_DATATYPES.NumTabTyp;
      l_project_curr_code_tab          PA_PLSQL_DATATYPES.Char30TabTyp;
      l_project_rate_date_tab          PA_PLSQL_DATATYPES.DateTabTyp;
      l_project_rate_type_tab          PA_PLSQL_DATATYPES.Char30TabTyp;
      l_project_exchange_rate_tab      PA_PLSQL_DATATYPES.NumTabTyp;
      l_project_amount_tab             PA_PLSQL_DATATYPES.NumTabTyp;
      l_project_rev_status_tab         PA_PLSQL_DATATYPES.Char30TabTyp;

      l_bill_trans_projfunc_amt_tab     PA_PLSQL_DATATYPES.NumTabTyp;
      l_projfunc_curr_code_tab         PA_PLSQL_DATATYPES.Char30TabTyp;
      l_projfunc_rate_date_tab         PA_PLSQL_DATATYPES.DateTabTyp;
      l_projfunc_rate_type_tab         PA_PLSQL_DATATYPES.Char30TabTyp;
      l_projfunc_exchange_rate_tab     PA_PLSQL_DATATYPES.NumTabTyp;
      l_projfunc_amount_tab            PA_PLSQL_DATATYPES.NumTabTyp;
      l_projfunc_rev_status_tab        PA_PLSQL_DATATYPES.Char30TabTyp;

      l_denominator_tab                PA_PLSQL_DATATYPES.NumTabTyp;
      l_numerator_tab                  PA_PLSQL_DATATYPES.NumTabTyp;
      l_user_validate_flag_tab         PA_PLSQL_DATATYPES.Char30TabTyp;
      l_raw_rev_status_tab             PA_PLSQL_DATATYPES.Char30TabTyp;

      l_final_error_status_tab         PA_PLSQL_DATATYPES.Char30TabTyp;



      l_project_curr_code              VARCHAR2(30);
      l_project_rate_date_code         VARCHAR2(30);
      l_project_rate_date              DATE;
      l_project_rate_type              VARCHAR2(30);
      l_project_exchange_rate          NUMBER;

      l_projfunc_curr_code             VARCHAR2(30);
      l_projfunc_rate_date_code        VARCHAR2(30);
      l_projfunc_rate_date             DATE;
      l_projfunc_rate_type             VARCHAR2(30);
      l_projfunc_exchange_rate         NUMBER;

      l_multi_currency_billing_flag    VARCHAR2(1);
      l_baseline_funding_flag          VARCHAR2(1);
      l_revproc_currency_code          VARCHAR2(30);
      l_invproc_currency_type          VARCHAR2(30);
      l_invproc_currency_code          VARCHAR2(30);
      l_funding_rate_date_code         VARCHAR2(30);
      l_funding_rate_type              VARCHAR2(30);
      l_funding_rate_date              DATE;
      l_funding_exchange_rate          NUMBER;
      l_return_status                  VARCHAR2(1);
      l_msg_count                      NUMBER;
      l_msg_data                       VARCHAR2(240);

      l_pa_date                        DATE;

      l_conversion_between             VARCHAR2(6);
      l_cache_flag                     VARCHAR2(1);

      l_project_id                     NUMBER ;              /* 2456371 */
      l_prv_project_id                 NUMBER ;


  BEGIN


       /* Assign the dummy value into the previous project id - This for checking
          whenever project id changes then call the get_project_defaults API - 2456371 */


         l_prv_project_id  := -9999;



        /* This flag is N then the convert_amount_bulk API not cache any currency code,
           If the flag is Y then it cache the currency and other attributes for avoid the
           repeat processing. */

        l_cache_flag   := 'N';


       /* Convert the PA date from character to date */


        /*File.Date.5. Added format to the p_pa_date which was missing*/
         l_pa_date  :=  TO_DATE(p_pa_date,'YYYY/MM/DD');


        IF g1_debug_mode  = 'Y' THEN
        	PA_MCB_INVOICE_PKG.log_message('Entering the procedure ei_fcst_amount_conversion');
        	PA_MCB_INVOICE_PKG.log_message('ei_fcst_amount_conversion: ' || '------------------------------------------------');
        END IF;



   /* 2456371 - cursor for select the expenditure details based on current request id */


    OPEN ei_fcst_amt_csr( p_request_id);

    LOOP




/*
 *    Clear all PL/SQL table.
 */

              l_ei_id_tab.delete;
              l_bill_trans_rev_amount_tab.delete;
              l_bill_trans_curr_code_tab.delete;

              l_project_id_tab.delete;                   /* 2456371 */

              l_revproc_rate_type_tab.delete;
              l_revproc_rate_date_tab.delete;
              l_revproc_exchange_rate_tab.delete;
              l_revproc_curr_code_tab.delete;
              l_revproc_amount_tab.delete;

              l_project_curr_code_tab.delete;
              l_project_rate_date_tab.delete;
              l_project_rate_type_tab.delete;
              l_project_exchange_rate_tab.delete;
              l_project_amount_tab.delete;
              l_project_rev_status_tab.delete;


              l_projfunc_curr_code_tab.delete;
              l_projfunc_rate_date_tab.delete;
              l_projfunc_rate_type_tab.delete;
              l_projfunc_exchange_rate_tab.delete;
              l_projfunc_amount_tab.delete;
              l_projfunc_rev_status_tab.delete;


              l_user_validate_flag_tab.delete;
              l_denominator_tab.delete;
              l_numerator_tab.delete;
              l_raw_rev_status_tab.delete;


      /* Fetching the expenditure bill transaction value */


     FETCH ei_fcst_amt_csr BULK  COLLECT
      INTO l_project_id_tab,                     /* 2456371 */
           l_ei_id_tab,
           l_bill_trans_rev_amount_tab,
           l_bill_trans_curr_code_tab LIMIT 100;


IF g1_debug_mode  = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('ei_fcst_amount_conversion: ' || 'Record Count  :' || l_ei_id_tab.COUNT);
END IF;

   IF (l_ei_id_tab.COUNT =  0 ) THEN

      EXIT;

   ELSE


    /* Initialize the Array variables to use convert_amount_bulk API */


     FOR I in 1 .. l_ei_id_tab.COUNT
     LOOP

      l_user_validate_flag_tab(I)   := 'Y';
      l_revproc_amount_tab(I)       := NULL;
      l_denominator_tab(I)          := NULL;
      l_numerator_tab(I)            := NULL;
      l_raw_rev_status_tab(I)       := NULL;



     /* Assign the project Id from PL/SQL table into non array variable for
        pass into the API get_project_defaults - 2456371 */

        l_project_id       :=  l_project_id_tab(i);


     /* 2456371 - Checking for the Previous and current project Id - If bott are different then
        call the api to get the default conversion attributes - If same then not necessary to call
        the  API to get the conversion attributes */


   IF (l_project_id  <>  l_prv_project_id)   THEN



     IF g1_debug_mode  = 'Y' THEN
     	PA_MCB_INVOICE_PKG.log_message('ei_fcst_amount_conversion: ' || 'Project Id  :' || l_project_id);
     	PA_MCB_INVOICE_PKG.log_message('ei_fcst_amount_conversion: ' || 'Calling Procedure get_project_defaults');
     END IF;

     -- Get the Project Level Defaults

     PA_MULTI_CURRENCY_BILLING.get_project_defaults (
            p_project_id                  => l_project_id,
            x_multi_currency_billing_flag => l_multi_currency_billing_flag,
            x_baseline_funding_flag       => l_baseline_funding_flag,
            x_revproc_currency_code       => l_revproc_currency_code,
            x_invproc_currency_type       => l_invproc_currency_type,
            x_invproc_currency_code       => l_invproc_currency_code,
            x_project_currency_code       => l_project_curr_code,
            x_project_bil_rate_date_code  => l_project_rate_date_code,
            x_project_bil_rate_type       => l_project_rate_type,
            x_project_bil_rate_date       => l_project_rate_date,
            x_project_bil_exchange_rate   => l_project_exchange_rate,
            x_projfunc_currency_code      => l_projfunc_curr_code,
            x_projfunc_bil_rate_date_code => l_projfunc_rate_date_code,
            x_projfunc_bil_rate_type      => l_projfunc_rate_type,
            x_projfunc_bil_rate_date      => l_projfunc_rate_date,
            x_projfunc_bil_exchange_rate  => l_projfunc_exchange_rate,
            x_funding_rate_date_code      => l_funding_rate_date_code,
            x_funding_rate_type           => l_funding_rate_type,
            x_funding_rate_date           => l_funding_rate_date,
            x_funding_exchange_rate       => l_funding_exchange_rate,
            x_return_status               => l_return_status,
            x_msg_count                   => l_msg_count,
            x_msg_data                    => l_msg_data);


   END IF;


        IF g1_debug_mode  = 'Y' THEN
        	PA_MCB_INVOICE_PKG.log_message('ei_fcst_amount_conversion: ' || 'after calling Procedure get_project_defaults');
        END IF;


                   /* Copy the project and project attributed into array variables */


                   l_project_curr_code_tab(I)      := l_project_curr_code;
                   l_project_rate_type_tab(I)      := l_project_rate_type;
                   l_project_rate_date_tab(I)      := l_project_rate_date;
                   l_project_exchange_rate_tab(I)  := l_project_exchange_rate;

                   l_projfunc_curr_code_tab(I)     := l_projfunc_curr_code;
                   l_projfunc_rate_type_tab(I)     := l_projfunc_rate_type;
                   l_projfunc_rate_date_tab(I)     := l_projfunc_rate_date;
                   l_projfunc_exchange_rate_tab(I) := l_projfunc_exchange_rate;


              /* If revenue processing currency and project currency both are same then
                 copy the project attributes to revenue processing attributes */


               IF (l_revproc_currency_code = l_project_curr_code) THEN


                    l_revproc_curr_code_tab(I)     := l_project_curr_code;
                    l_revproc_rate_type_tab(I)     := l_project_rate_type;
                    l_revproc_rate_date_tab(I)     := l_project_rate_date;
                    l_revproc_exchange_rate_tab(I) := l_project_exchange_rate;


                    /* If  rate date code = 'PA_INVOICE_DATE' then get the PA DATE and
                       assign to the revenue processing rate date */

                     IF (l_project_rate_date_code = 'PA_INVOICE_DATE') THEN

                        l_revproc_rate_date_tab(I) := l_pa_date;

                     END IF;

                 /* If revenue processing currency and project functional  currency both are same then
                 copy the project functional attributes to revenue processing attributes */


             ELSIF (l_revproc_currency_code = l_projfunc_curr_code) THEN

                    l_revproc_curr_code_tab(I)     := l_projfunc_curr_code;
                    l_revproc_rate_type_tab(I)     := l_projfunc_rate_type;
                    l_revproc_rate_date_tab(I)     := l_projfunc_rate_date;
                    l_revproc_exchange_rate_tab(I) := l_projfunc_exchange_rate;

                    /* If  rate date code = 'PA_INVOICE_DATE' then get the PA DATE and
                       assign to the revenue processing rate date */


                    IF (l_projfunc_rate_date_code = 'PA_INVOICE_DATE') THEN

                        l_revproc_rate_date_tab(I) := l_pa_date;

                     END IF;


               END IF;



           /* 2456371 : Assign the project id to the previous project Id variable */

           l_prv_project_id   := l_project_id;


           /* Print the currency attribute value */

           IF g1_debug_mode  = 'Y' THEN
           	PA_MCB_INVOICE_PKG.log_message('ei_fcst_amount_conversion: ' || 'Revproc Currency Code :' || l_revproc_curr_code_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('ei_fcst_amount_conversion: ' || 'Revproc Rate Type     :' || l_revproc_rate_type_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('ei_fcst_amount_conversion: ' || 'RevProc Rate Date     :' || l_revproc_rate_date_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('ei_fcst_amount_conversion: ' || 'Revproc Xchg Rate     :' || l_revproc_exchange_rate_tab(i));
           END IF;


        END LOOP;



  /* Converting Bill Trans Raw revenue to Raw revenue (Revenue processing currency) */

        IF g1_debug_mode  = 'Y' THEN
        	PA_MCB_INVOICE_PKG.log_message('ei_fcst_amount_conversion: ' || 'Calling the procedure convert_amount_bulk for Revenue amount');
        END IF;


           /* Passing the param (two currency code) to the convert_amount_bulk API, If any conversion fails
              then the API concatenate the code with error message */

              l_conversion_between  := 'BTC_PF';


           PA_MULTI_CURRENCY_BILLING.convert_amount_bulk(
                    p_from_currency_tab        => l_bill_trans_curr_code_tab,
                    p_to_currency_tab          => l_revproc_curr_code_tab,
                    p_conversion_date_tab      => l_revproc_rate_date_tab,
                    p_conversion_type_tab      => l_revproc_rate_type_tab,
                    p_amount_tab               => l_bill_trans_rev_amount_tab,
                    p_user_validate_flag_tab   => l_user_validate_flag_tab,
                    p_converted_amount_tab     => l_revproc_amount_tab,
                    p_denominator_tab          => l_denominator_tab,
                    p_numerator_tab            => l_numerator_tab,
                    p_rate_tab                 => l_revproc_exchange_rate_tab,
                    p_conversion_between       => l_conversion_between,
                    p_cache_flag               => l_cache_flag,
                    x_status_tab               => l_raw_rev_status_tab
                    );



        IF g1_debug_mode  = 'Y' THEN
        	PA_MCB_INVOICE_PKG.log_message('ei_fcst_amount_conversion: ' || 'Project Id  : ' || p_project_id);
        END IF;


       /*  FOR I in 1 .. l_ei_id_tab.COUNT
          LOOP



        -- Log Messages for EI Converted Amounts

           IF g1_debug_mode  = 'Y' THEN
           	PA_MCB_INVOICE_PKG.log_message('ei_fcst_amount_conversion: ' || 'Expenditure Item Id :' || l_ei_id_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('ei_fcst_amount_conversion: ' || 'Bill Trans Currency Code :' || l_bill_trans_curr_code_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('ei_fcst_amount_conversion: ' || 'Bill Trans Raw revenue :' || l_bill_trans_rev_amount_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('ei_fcst_amount_conversion: ' || 'Convert RevProc Amount :' || l_revproc_amount_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('ei_fcst_amount_conversion: ' || 'Revproc Currency  Code :' || l_revproc_curr_code_tab(i));
           	PA_MCB_INVOICE_PKG.log_message('ei_fcst_amount_conversion: ' || 'Revproc Amt Rejection Reason :' || l_raw_rev_status_tab(i));
           END IF;



         END LOOP; */



  /* Updating the converted amount to the Expenditure Item table.
     Converted amount column : raw_revenue, adjusted_revenue, bill_rate, adjusted_rate
     Other columns           : Initialize when conversion fails and marking revenue
                               distributed flag to 'N                       */


          FORALL I IN 1 ..l_ei_id_tab.COUNT
                  UPDATE pa_expenditure_items_all
                     SET forecast_revenue      =
                              DECODE(l_raw_rev_status_tab(i), 'N', l_revproc_amount_tab(i), NULL),
                         projfunc_fcst_rate_type       = l_revproc_rate_type_tab(i),
                         projfunc_fcst_rate_date       = l_revproc_rate_date_tab(i),
                         projfunc_fcst_exchange_rate   = l_revproc_exchange_rate_tab(i),
                         rev_dist_rejection_code =
                                DECODE(l_raw_rev_status_tab(i), 'N',NULL, l_raw_rev_status_tab(i))
                   WHERE expenditure_item_id = l_ei_id_tab(i);

       PA_MCB_INVOICE_PKG.log_message('No of Rows Updated in EI table for forecast revenue: ' || SQL%ROWCOUNT);


      END IF;    /* l_ei_id_tab.COUNT <> 0 */

          EXIT WHEN ei_fcst_amt_csr%NOTFOUND;


       END LOOP;

       CLOSE ei_fcst_amt_csr;


   EXCEPTION
     WHEN OTHERS THEN

          IF g1_debug_mode  = 'Y' THEN
          	PA_MCB_INVOICE_PKG.log_message('Error in Ei_fcst_amount_conversion ' || sqlerrm);
          END IF;

          x_return_status := sqlerrm( sqlcode );

END ei_fcst_amount_conversion;



PROCEDURE log_message (p_log_msg IN VARCHAR2) IS
BEGIN
--pa_debug.write_file ('LOG',to_char(sysdate, 'DD-MON-YYYY HH:MI:SS ')||p_log_msg);
pa_debug.write_file ('LOG','MCB.....' || p_log_msg);
NULL;
END log_message;


PROCEDURE Init (P_DEBUG_MODE VARCHAR2) IS
BEGIN
G_LAST_UPDATE_LOGIN := fnd_global.login_id;
G_REQUEST_ID := fnd_global.conc_request_id;
G_PROGRAM_APPLICATION_ID := fnd_global.prog_appl_id;
G_PROGRAM_ID := fnd_global.conc_program_id;
G_LAST_UPDATED_BY := fnd_global.user_id;
G_CREATED_BY :=  fnd_global.user_id;
G_DEBUG_MODE := P_DEBUG_MODE;
pa_debug.init_err_stack ('Revenue Generation');
pa_debug.set_process(
            x_process => 'PLSQL',
            x_debug_mode => G_DEBUG_MODE);


pa_debug.G_Err_Stage :=' Start PLSQL Message ';

   IF g1_debug_mode  = 'Y' THEN
      PA_MCB_REVENUE_PKG.log_message(pa_debug.G_Err_Stage);
   END IF;

END Init;


/*----------------------------------------------------------------------------------------+
|   Procedure  :   RTC_UBR_UER_CALC                                                       |
|   Purpose    :   To compute transaction level ie, draft revenue level UBR/UER values in |
|                  Revenue transaction currency.                                          |
|   Parameters :                                                                          |
|     ==================================================================================  |
|     Name                    Mode            Description                                 |
|     ==================================================================================  |
|      P_PFC_REV_AMOUNT        IN           Total revenue amount for a revenue in PFC     |
|      P_REVTRANS_AMOUNT       IN           Total revenue amount for a revenue in RTC     |
|      P_PROJFUNC_UBR          IN           UBR amount in project functional currency     |
|      P_PROJFUNC_UER          IN           UBR amount in project functional currency     |
|      P_UBR_CORR              IN           UBR correction amt in proj functional currency|
|      P_UER_CORR              IN           UER correction amt in proj functional currency|
|      P_REVTRANS_UBR          OUT NOCOPY   UBR amount in revenue transaction currency    |
|      P_REVTRANS_UER          OUT NOCOPY   UER amount in revenue transaction currency    |
|      X_RETURN_STATUS         OUT NOCOPY   Return status                                 |
|      X_MSG_COUNT             OUT NOCOPY   Error messages count                          |
|      X_MSG_DATA              OUT NOCOPY   Error message                                 |
|     ==================================================================================  |
+----------------------------------------------------------------------------------------*/
PROCEDURE RTC_UBR_UER_CALC(
                        P_PFC_REV_AMOUNT	IN		NUMBER,
			P_REVTRANS_AMOUNT	IN		NUMBER,
			P_PROJFUNC_UBR		IN		NUMBER,
			P_PROJFUNC_UER		IN		NUMBER,
			P_UBR_CORR		IN		NUMBER,
			P_UER_CORR		IN		NUMBER,
			P_REVTRANS_UBR		OUT NOCOPY	VARCHAR,
			P_REVTRANS_UER		OUT NOCOPY	VARCHAR,
			X_RETURN_STATUS		OUT NOCOPY	VARCHAR,
			X_MSG_COUNT		OUT NOCOPY 	NUMBER,
			X_MSG_DATA		OUT NOCOPY	VARCHAR)
IS

l_rtc_ubr_corr VARCHAR2(30);
l_rtc_uer_corr VARCHAR2(30);

BEGIN
	X_RETURN_STATUS := NULL;
	X_MSG_COUNT := 0;
	X_MSG_DATA := NULL;

-- Compute ubr,uer correction amount in revenue transaction currency from project functional amounts.

	l_rtc_ubr_corr := substr(to_char((P_REVTRANS_AMOUNT / P_PFC_REV_AMOUNT ) * P_UBR_CORR), 1, 30);
	l_rtc_uer_corr := substr(to_char((P_REVTRANS_AMOUNT / P_PFC_REV_AMOUNT ) * P_UER_CORR), 1, 30);


-- Calculate UBR in revenue transaction currency as projfunc UBR multiplied by the ratio of revenue in
-- project functional currency and revenue in revenue transaction currency.

	P_Revtrans_Ubr  :=  substr(to_char(((P_RevTrans_Amount / P_Pfc_Rev_Amount ) * P_Projfunc_Ubr) + to_number(l_rtc_ubr_corr)), 1, 30);

-- Calculate UER in revenue transaction currency as projfunc UER multiplied by the ratio of revenue in
-- project functional currency and revenue in revenue transaction currency.

	P_Revtrans_Uer  :=  substr(to_char(((P_RevTrans_Amount / P_Pfc_Rev_Amount ) * P_Projfunc_Uer) + to_number(l_rtc_uer_corr)), 1, 30);


EXCEPTION
    WHEN ZERO_DIVIDE THEN
        P_REVTRANS_UBR := 0;
        P_REVTRANS_UER := 0;

    WHEN OTHERS THEN
        P_REVTRANS_UBR := NULL;
        P_REVTRANS_UER := NULL;
        raise;
END RTC_UBR_UER_CALC;


END PA_MCB_REVENUE_PKG;

/
