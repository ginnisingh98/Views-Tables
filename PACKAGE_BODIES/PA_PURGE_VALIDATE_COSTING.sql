--------------------------------------------------------
--  DDL for Package Body PA_PURGE_VALIDATE_COSTING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PURGE_VALIDATE_COSTING" as
/* $Header: PAXCSVTB.pls 120.8.12010000.2 2009/06/15 11:35:49 nisinha ship $ */

 -- forward declarations

-- Start of comments
-- API name         : validate_costing
-- Type             : Public
-- Pre-reqs         : None
-- Function         : This procedure is the main validate procedure for
--                    costing validations.
--
-- Parameters       : p_project_Id			IN     NUMBER,
--                              The project id for which records have
--                              to be purged/archived.
--		      p_txn_to_date			IN     DATE,
--                              If the purging is being done on projects
--                              that are active then this parameter is
--                              determine the date to which the transactions
--                              need to be purged.
--		      p_active_flag			IN    VARCHAR2,
--                              The flag to specify purging is done on
--                              open or closed projects.
--		      X_Err_Stack			IN OUT VARCHAR2,
--                              Error stack
--		      X_Err_Stage		        IN OUT VARCHAR2,
--                              Stage in the procedure where error occurred
--		      X_Err_Code		        IN OUT NUMBER
--                              Error code returned from the procedure
-- End of comments

 procedure Validate_Costing (
			p_project_id                     in NUMBER,
                        p_txn_to_date                    in DATE,
                        p_active_flag                    in VARCHAR2,
                        x_err_code                       in OUT NOCOPY NUMBER,
                        x_err_stack                      in OUT NOCOPY VARCHAR2,
                        x_err_stage                      in OUT NOCOPY VARCHAR2 )
 is


  cursor IsCostDistributed is
      select 'NOT COST DISTRIBUTED'
        from dual
       where exists (
		select ei.expenditure_item_id
                from pa_expenditure_items_all ei
                where ei.project_id = p_project_id
                and ( p_active_flag <> 'A'
                  or (trunc(ei.expenditure_item_date ) <=
				          trunc(p_txn_to_date ) ))
                and nvl(ei.cost_distributed_flag, 'N') <> 'Y') ;

  cursor IsTransImported is
      select 'NOT IMPORTED'
        from dual
       where exists (
		select 'X'
                from pa_transaction_interface_all it,
                     pa_projects t
                where it.project_number = t.segment1
                and t.project_id = p_project_id
                and ( p_active_flag <> 'A'
                   or (trunc(it.expenditure_item_date ) <=
					trunc(p_txn_to_date  ) ))
                and it.transaction_status_code <> 'A') ;

  cursor IsInterfaced (P_User_Source_Name IN VARCHAR2) is
      select 'NOT Transferred and Accepted in other system'
        from dual
       where exists (
		select ei.expenditure_item_id
                from  pa_expenditure_items_all ei,
                      pa_cost_distribution_lines_all cdl
                where ei.expenditure_item_id = cdl.expenditure_item_id
              and ei.system_linkage_function not in ('VI', 'ER')  /* Bug#2427766 */
/*                and ei.system_linkage_function <> 'VI'  Bug#2616111 */
                and ei.project_id = p_project_id
                and ( p_active_flag <> 'A'
                   or (trunc(ei.expenditure_item_date ) <=
					trunc(p_txn_to_date  ) ))
                and (cdl.transfer_status_code not in ( 'A','V','G') /** 4317826 **/
		or exists (select 1
		             from xla_events xe
                            where xe.event_id = cdl.acct_event_id
			      and xe.event_status_code <> 'P'
			      and xe.process_status_code <> 'P')));

                /* Commented below for R12
                or  exists (select reference26
                            from pa_gl_interface gl
                            where
                                gl.user_je_source_name || '' = P_User_Source_Name
                            and gl.reference26 = cdl.batch_name
			    and ((gl.Status NOT LIKE 'W%'
                                 and gl.Status <> 'NEW'
                                 and gl.Status <> 'PROCESSED')
                              or
			         gl.Status = 'NEW')))) ;
                */


  /* Commented below code for R12 changes.
  cursor IsMRCInterfaced (P_User_Source_Name IN VARCHAR2) is
     select 'MRC NOT Transferred and Accepted in other system'
     from dual
     where exists (
     	select ei.expenditure_item_id
        from   pa_expenditure_items_all ei,
               pa_mc_cost_dist_lines_all mrccdl
        where ei.expenditure_item_id = mrccdl.expenditure_item_id
        and ei.system_linkage_function not in ('VI', 'ER')
        and ei.project_id = p_project_id
        and ( p_active_flag <> 'A'
            or (trunc(ei.expenditure_item_date ) <= trunc(p_txn_to_date  ) ))
        and (mrccdl.transfer_status_code not in ('A','V','G')
        or  exists (select reference26
                    from pa_gl_interface gl
                    where
                        gl.user_je_source_name || '' = P_User_Source_Name
                    and gl.reference26 = mrccdl.batch_name
                    and ((gl.Status NOT LIKE 'W%'
                         and gl.Status <> 'NEW'
                         and gl.Status <> 'PROCESSED')
                       or
                         gl.Status = 'NEW')))) ;
   */

  cursor IsResAccumulated is
      select 'Cost not accumulated'
        from dual
       where exists (
		select ei.expenditure_item_id
                from pa_expenditure_items_all ei,
                     pa_cost_distribution_lines_all cdl
                where ei.expenditure_item_id = cdl.expenditure_item_id
                and ei.project_id = p_project_id
                and ( p_active_flag <> 'A'
                    or (trunc(ei.expenditure_item_date ) <=
					trunc(p_txn_to_date  ) ))
                and cdl.line_type = 'R'
                and nvl(cdl.resource_accumulated_flag, 'N') <> 'Y') ;

  cursor IsBurdenDistributed is
      select 'Not Burden Distributed'
        from dual
       where exists (
		select ei.expenditure_item_id
                from pa_expenditure_items_all ei,
                     pa_project_types_all pt,
                     pa_tasks t,
                     pa_projects_all p
                where ei.task_id = t.task_id
                and t.project_id = p.project_id
                and t.project_id = p_project_id
                and p.project_type = pt.project_type
                and pt.org_id = p.org_id -- Removed NVL for bug#590817 by vvjoshi
                and pt.burden_cost_flag = 'Y'
                and ( p_active_flag <> 'A'
                   or (trunc(ei.expenditure_item_date ) <=
					trunc(p_txn_to_date  ) ))) ;

/*** In part I of archive purge,projects with intercompany transactions are not to be
     purged. Hence check for the existence of any EIs with cross charge code I or
     existence of records in pa_draft_invoice_details for the project. ***/
/* Bug#2416385 Commented for Phase-3 Archive and Purge
  cursor  IsIntercompany is
      select 'INTERCOMPANY EIs INV EXISTS'
        from dual
      where exists (
               select ei.expenditure_item_id
               from pa_expenditure_items_all ei,
                    pa_tasks t
               where ei.task_id = t.task_id
               and   t.project_id = p_project_id
               and   ei.cc_cross_charge_code = 'I')
      or exists   (
               select null
               from   pa_draft_invoice_details_all di
               where  di.cc_project_id = p_project_id );
*/

  cursor IsBorrLentDistributed is
      select 'NOT BL DISTRIBUTED'
        from dual
       where exists (
		select ei.expenditure_item_id
                from pa_expenditure_items_all ei
                where ei.project_id = p_project_id
                and ( p_active_flag <> 'A'
                  or trunc(ei.expenditure_item_date) <= trunc(p_txn_to_date)  )
                and ei.cc_cross_charge_code = 'B'
                and ei.cc_bl_distributed_code <> 'Y') ;

  cursor IsCCDLInterfaced (P_User_Source_Name IN VARCHAR2) is
      select 'NOT Transferred and Accepted in other system'
        from dual
       where exists (
		select ei.expenditure_item_id
                from pa_expenditure_items_all ei,
                     pa_cc_dist_lines_all ccdl
                where ei.expenditure_item_id = ccdl.expenditure_item_id
                and ei.project_id = p_project_id
                and ( p_active_flag <> 'A'
                   or (trunc(ei.expenditure_item_date ) <=
					trunc(p_txn_to_date  ) ))
                and (ccdl.transfer_status_code not in ( 'A','V')
		or exists (select 1
		             from xla_events xe
                            where xe.event_id = ccdl.acct_event_id
			      and xe.event_status_code <> 'P'
			      and xe.process_status_code <> 'P')));

                /* Commented below code for R12 changes.
                or  exists (select reference26
                            from pa_gl_interface gl
                            where
                                gl.user_je_source_name || '' = P_User_Source_Name
                            and gl.reference26 = ccdl.gl_batch_name
			    and ((gl.Status NOT LIKE 'W%'
                                 and gl.Status <> 'NEW'
                                 and gl.Status <> 'PROCESSED')
                              or
			         gl.Status = 'NEW')))) ;

                */

  cursor IsDestProjectType is
      select 'This project is defined as a destination project in project type'
        from dual
       where exists (
		select project_type
		  from pa_project_types
	         where burden_sum_dest_project_id = p_project_id
		    );

/*******************************************************************************
 project related supplier invoices pending for transfer is handled as part of
 capital check. Now check is done for successfully interfaced VI, if eligible
 for discounts, fully paid or not.
 This check is necessary as discount is generated during payment of an invoice
 and if main invoice is purged before payment, discount transaction will not
 find the parent record during transfer to PA.
*******************************************************************************/
CURSOR IsVIPaymentPendg IS
SELECT 'VENDOR INVOICE NOT FULLY PAID'
FROM   dual
WHERE EXISTS ( SELECT aid.invoice_id
               FROM   ap_invoices_all ai,
   	      	      ap_invoice_distributions_all aid
-- bug 2404115	       WHERE  ai.project_id = p_project_id
	       WHERE  aid.project_id = p_project_id
               AND    nvl(ai.invoice_amount,0) <> 0 /* Bug 5063560 */
	       AND    ai.invoice_id = aid.invoice_id
               AND    ai.invoice_type_lookup_code <> 'EXPENSE REPORT'
               AND    (p_active_flag <> 'A' or
-- bug 2404115                       ai.expenditure_item_date < p_txn_to_date)
                       trunc(aid.expenditure_item_date) <= trunc(p_txn_to_date))
               AND    aid.pa_addition_flag = 'Y'
	       AND    nvl(ai.payment_status_flag,'N') <> 'Y'
               AND    nvl(aid.reversal_flag, 'N') <> 'Y'    /* 4065283 */
/* Bug#2407614. For all the supplier invoices check if payment has been done.
	       AND    exists (SELECT NULL
			      FROM   ap_payment_schedules_all aps
			      WHERE  aps.invoice_id = ai.invoice_id
			      AND    nvl(aps.discount_amount_available, 0) > 0
			      AND    nvl(aps.amount_remaining, 0 ) > 0
			     ) */
             );

/*  bug 2396427. Inter project receiver project check. */
/* Bug#2416385 Commented for Phase-3 Archive and Purg
      cursor ISInterPrjRecvPrj IS
      select 'This is an Inter-Project Receiver Project'
        from dual
       where exists ( select NULL
                        from pa_tasks pt
                       where pt.project_id = p_project_id
                         and pt.receive_project_invoice_flag = 'Y'
                         and exists ( select NULL
				      from   pa_project_customers ppc
				      where  ppc.receiver_task_id = pt.task_id )
                    );
*/
/*  Bug# 2405565. Check whether discount lines are interfaced to projects. */

    cursor ISDistLinesIntfed IS
    select 'Discount Not Interfaced'
    from dual
    where exists (
    select null from ap_invoices ai,
                     ap_invoice_distributions aid,
                     -- ap_invoice_payments pay --R12 change
                     ap_payment_hist_dists paydist
    where aid.project_id = p_project_id
    and   ai.invoice_id = aid.invoice_id
    -- and   paydist.invoice_id = ai.invoice_id -- R12 change
    -- and   pay.discount_taken <> 0 -- R12 change
    and   paydist.invoice_distribution_id = aid.invoice_distribution_id
    and   paydist.amount <> 0
    and   ai.invoice_type_lookup_code <> 'EXPENSE REPORT'
    and   paydist.pay_dist_lookup_code = 'DISCOUNT'
    and   paydist.pa_addition_flag  = 'N'
    and   aid.expenditure_item_date >= nvl(to_date(fnd_profile.value_specific('PA_DISC_PULL_START_DATE'),'YYYY/MM/DD'),to_date('01/01/2051','DD/MM/YYYY'))  /* Bug 3134267 */ /*Bug4124600*/ /*Bug 6855026*/
  /* --Commented for R12
    and   not exists
           ( select 'X' from pa_cost_distribution_lines cdl
             where cdl.system_reference2=to_char(aid.invoice_id)
             and cdl.system_reference3=to_char(aid.distribution_line_number)
             and cdl.system_reference4=to_char(pay.invoice_payment_id)
           )
  */
   );

   /* Bug 2503876. Organization forecast Dummy projects should not be purged */

   cursor ISOrgForecastProject IS
   select 'Organization Forecast Project'
   from dual
   where exists (
              select null from pa_projects pj,
                               pa_project_types pt
              where pj.project_id = p_project_id
              and   pj.project_type = pt.project_type
              and   pt.org_project_flag = 'Y'
                );

   /* Bug 2553535. Unassigned forecast items should be purged using the
      new concurrent process PRC:Archive/Purge Unassinged forecast items */

      cursor IsUnassignedTimeType IS
      select 'Unassigned Time Project Type'
      from dual
      where exists ( select    pt.project_type
                     from      pa_project_types pt,
                               pa_projects p
                      where    p.project_id = p_project_id
                      and      pt.project_type = p.project_type
                      and      nvl(pt.unassigned_time, 'N') = 'Y' );

      /* Check for project related iExpense transactions Pending for import */
      /* This portion has been done dynamically since pa_interfaced_flag is not
         added to ap_expense_report_lines table in release 11.5.3 bug 2695986
      cursor IsIexpenseTxnsPending IS
      select 'Iexpense Transactions Pending'
      from dual
      where exists (select h.report_header_id
                    from   ap_expense_report_headers h,
                           ap_expense_report_lines l
                    where  h.report_header_id = l.report_header_id
                    and    h.source <> 'Oracle Project Accounting'
                    and    l.project_id = p_project_id
                    and    ( p_active_flag <> 'A'
                             or (trunc(l.expenditure_item_date ) <=
                                          trunc(p_txn_to_date ) ))
                    and    nvl(l.pa_interfaced_flag,'N') <> 'Y'); */
     /* Bug2767419. Checking for the existence of iexpense txns pending
        for transfer to PA. Instead of using pa_interfaced_flag of ap_exp_lines
        the check is done thru ap_invoice tables. */
     cursor IsIexpenseTxnsPending IS
     select 'Iexpense Transactions Pending'
     from dual
     where exists (
                   select null
                   from   ap_expense_report_headers h,
                          ap_expense_report_lines l
                   where  l.project_id = p_project_id
                   and    (p_active_flag <> 'A'
                           or (trunc(l.expenditure_item_date ) <=
                                                        trunc(p_txn_to_date )))
                   and    l.report_header_id = h.report_header_id
                   and    h.source <> 'Oracle Project Accounting'
                   and    not exists (
                                      select null
                                      from  ap_invoice_distributions d
                                      where d.invoice_id = h.vouchno
                                      and d.pa_addition_flag IN ('Z','T','E','Y')));


      /* Bug 2610276. Added Expense report payment check */
      cursor IsERPaymentPendg IS
      SELECT 'EXPENSE REPORTS NOT FULLY PAID'
      FROM   dual
      WHERE EXISTS ( SELECT aid.invoice_id
                     FROM   ap_invoices_all ai,
   	      	            ap_invoice_distributions_all aid
	             WHERE  aid.project_id = p_project_id
	             AND    ai.invoice_id = aid.invoice_id
                     AND    ai.invoice_type_lookup_code = 'EXPENSE REPORT'
                     AND    (p_active_flag <> 'A' or
                             trunc(aid.expenditure_item_date) <=
                                                 trunc(p_txn_to_date))
	             AND    nvl(ai.payment_status_flag,'N') <> 'Y' );

      l_err_stack_old    VARCHAR2(2000);
      l_err_stack        VARCHAR2(2000);
      l_err_stage        VARCHAR2(500);
      l_err_code         NUMBER ;
      l_dummy            VARCHAR2(500);
      l_user_source_name GL_JE_SOURCES.USER_JE_SOURCE_NAME%TYPE;
      --l_used_in_OTL      BOOLEAN := FALSE; Commented for Bug 2726711
      l_purgeable        BOOLEAN := FALSE;   /* Added for Bug 2726711 */

      l_source_project   NUMBER;
      l_target_project   NUMBER;
      l_offset_project   NUMBER;

      V_CursorID        INTEGER;
      V_Stmt            VARCHAR2(500);
      V_Delete_Allowed  VARCHAR2(1);
      V_Dummy           INTEGER;
      l_igc_exists      NUMBER;
      l_dummy_num       NUMBER;

 BEGIN
     l_err_code  := 0 ;
     l_err_stack_old := x_err_stack;
     pa_debug.debug(' -- Performing costing validation for project '||
				to_char(p_project_id));
     -- Check if there are expenditure items that are not Cost
     -- Distributed

     Open IsCostDistributed ;
     Fetch IsCostDistributed into l_dummy ;
     If l_dummy is not null then
        fnd_message.set_name('PA', 'PA_ARPR_NOT_COSTED');
        fnd_msg_pub.add;
        l_err_code   :=  10 ;

        l_err_stage := 'After open cursor IsCostDistributed' ;
        l_err_stack := l_err_stack ||
		       ' ->After open cursor IsCostDistributed' ;
        pa_debug.debug('    * Uncosted items exists for project '||
		       to_char(p_project_id));
     End If;
     close IsCostDistributed;
     l_dummy := NULL;

     -- Check if there are expenditure items that are not Cost
     -- Distributed

     Open IsTransImported ;
     Fetch IsTransImported into l_dummy ;
     If l_dummy is not null then
        fnd_message.set_name('PA', 'PA_ARPR_NOT_TR_IMPORTED');
        fnd_msg_pub.add;
        l_err_code   :=  10 ;

        l_err_stage := 'After open cursor IsTransImported' ;
        l_err_stack := l_err_stack || ' ->After open cursor IsTransImported' ;
        pa_debug.debug('    * Items that are not revenue generated exists for project '||to_char(p_project_id));
     End If;
     close IsTransImported;
     l_dummy := NULL;

     -- Check if there are CDLs that are not accepted in the other
     -- application

     /*
      *   Need the user_je_source_name use in the the IsInterfaced
      *   and IsMRCInterfaced cursors. Added the parameter to Open
      *   IsInterfaced and IsMRCInterfaced cursors.
      */
     SELECT user_je_source_name
     INTO   l_user_source_name
     FROM   GL_Je_Sources
     WHERE je_source_name='Project Accounting';

     Open IsInterfaced(l_User_Source_Name) ;
     Fetch IsInterfaced into l_dummy ;
     If l_dummy is not null then
        fnd_message.set_name('PA', 'PA_ARPR_NOT_INFCED');
        fnd_msg_pub.add;
        l_err_code   :=  10 ;

        l_err_stage := 'After transfer check' ;
        l_err_stack := l_err_stack || ' ->After transfer check' ;
        pa_debug.debug('    * Not all costs are transferred for the project '||to_char(p_project_id));
     End If;
     close IsInterfaced;

/* Check if there are MRC CDLs that are not accepted in the other
 * application.  New for 11.0 due to MRC.
 */

     l_dummy := NULL;

    /* Commented below code for R12 changes.
     Open IsMRCInterfaced(l_User_Source_Name) ;
     Fetch IsMRCInterfaced into l_dummy ;
     If l_dummy is not null then
       	fnd_message.set_name('PA', 'PA_MRC_ARPR_NOT_INFCED');
       	fnd_msg_pub.add;
       	l_err_code   :=  10 ;
       	l_err_stage := 'After transfer check' ;
        l_err_stack := l_err_stack || ' ->After transfer check' ;
	pa_debug.debug('  * Not all MRC costs are transferred for the project ' || to_char(p_project_id));
     End If;
     close IsMRCInterfaced;
     */


/* End of new section for MRC CDLs */

     l_dummy := NULL;

     -- Check if there are CDLs whose costs are not accumulated

/*** -- This section of the code has been commented out due to the request from
     -- some customers who do not run summarization.  So if the user wants to
     -- check if summarization has been run the this section of the code needs
     -- to be put in the client-extension.

     Open IsResAccumulated ;
     Fetch IsResAccumulated into l_dummy ;
     If l_dummy is not null then
        fnd_message.set_name('PA', 'PA_ARPR_NOT_RES_ACCUM');
        fnd_msg_pub.add;
        l_err_code   :=  10 ;

        l_err_stage := 'After resource accumulation check ' ;
        l_err_stack := l_err_stack || ' ->After resource accumulation check ' ;
        pa_debug.debug('    * Not all costs are accumulated for the project '||to_char(p_project_id));
     End If;
     close IsResAccumulated;
     l_dummy := NULL;

***/
     -- Check if total burden cost distribution is run for the costs
/*
     Open IsBurdenDistributed ;
     Fetch IsBurdenDistributed into l_dummy ;
     If l_dummy is not null then
        fnd_message.set_name('PA', 'PA_ARPR_NOT_BRDN_DIST');
        fnd_msg_pub.add;
        l_err_code   :=  10 ;

        l_err_stage := 'After Burden Cost Dist. check ' ;
        l_err_stack := l_err_stack || ' ->After Burden Cost Dist. check ' ;
        pa_debug.debug('    * Not all costs are burden distributed for project '||to_char(p_project_id));
     End If;
     close IsBurdenDistributed;
     l_dummy := NULL;
*/

/* Bug#2416385 Commented for Phase-3 Archive and Purg
    -- Check there are no intercompany tranactions

    Open IsIntercompany;
    Fetch IsIntercompany into l_dummy;
    If l_dummy is not null then
       fnd_message.set_name('PA','PA_ARPR_IC_TRX_EXISTS');
       fnd_msg_pub.add;
       l_err_code  := 10;
       l_err_stage := 'After intercompany check ';
       l_err_stack := l_err_stack|| ' -> After intercompany check';
       pa_debug.debug('    * Intercompany transactions exists for the project '||to_char(p_project_id));
    End If;
    Close IsIntercompany;
    l_dummy := NULL;
*/

     -- Check if all the eligible borrowed lent EIs are BL distributed.

    Open IsBorrLentDistributed;
    Fetch IsBorrLentDistributed into l_dummy;
    If l_dummy is not null then
       fnd_message.set_name('PA','PA_ARPR_NOT_BL_DIST');
       fnd_msg_pub.add;
       l_err_code  := 10;
       l_err_stage := 'After Borrowed and Lent Dist check ';
       l_err_stack := l_err_stack|| ' -> After Borrwed and Lent Dist Check ';
       pa_debug.debug('    * Eligible Borrowed and Lent  EIs are not BL distributed for project '||to_char(p_project_id));
    End If;
    Close IsBorrLentDistributed;
    l_dummy := NULL;

     -- Check if BL cost is transferred to other applications.

     Open IsCCDLInterfaced(l_User_Source_Name) ;
     Fetch IsCCDLInterfaced into l_dummy ;
     If l_dummy is not null then
        fnd_message.set_name('PA', 'PA_ARPR_BL_NOT_IFCD');
        fnd_msg_pub.add;
        l_err_code  :=  10 ;
        l_err_stage := 'After BL transfer check' ;
        l_err_stack := l_err_stack || ' ->After BL transfer check' ;
        pa_debug.debug('    * Not all BL costs are transferred for the project '||to_char(p_project_id));
     End If;
     Close IsCCDLInterfaced;
     l_dummy := NULL;

     -- Check if the project is defined as a destination project in any project type

     Open IsDestProjectType;
     Fetch IsDestProjectType into l_dummy;
     If l_dummy is not null then
        fnd_message.set_name('PA', 'PA_ARPR_DEST_PRJ_TYPE');
        fnd_msg_pub.add;
        l_err_code  :=  10 ;
        l_err_stage := 'After destination project in project type check' ;
        l_err_stack := l_err_stack || ' ->After destination project in project type check' ;
        pa_debug.debug('    * The project '||to_char(p_project_id)||' is defined as a destination project in project type check ');
     End If;
     Close IsDestProjectType;
     l_dummy := NULL;

     --Check to see if the project has been used in OTL
/* Commented for Bug 2726711
   Modified call to ProjectTaskPurgeable to validate if the project is purgable
     PA_OTC_API.ProjectTaskUsed( p_search_attribute => 'PROJECT',
                                 p_search_value     => p_project_id,
                                 x_used             => l_used_in_OTL );*/

     PA_OTC_API.ProjectTaskPurgeable   /* Add for bug 2726711 */
		   (P_Search_Attribute => 'PROJECT',
                    P_Search_Value     => p_project_id,
                    X_Purgeable        => l_purgeable);

     --IF l_used_in_OTL   Commented for Bug 2726711
     IF  NOT l_purgeable
     THEN
        fnd_message.set_name('PA', 'PA_ARPR_OTL_NOT_IFCD');
        fnd_msg_pub.add;
        l_err_code := 10;
        l_err_stage := 'After OTL check' ;
        l_err_stack := l_err_stack || ' ->After OTL check' ;
        pa_debug.debug('    * OTL records exists for the project '||to_char(p_project_id));
     END IF;

     pa_debug.debug(' -- Performing Allocations validation for project '||
                                to_char(p_project_id));

     pa_purge_validate_costing.Validate_Allocations(p_proj_id    => p_project_id,
						    x_source     => l_source_project,
						    x_target     => l_target_project,
						    x_offset     => l_offset_project);
     IF l_source_project = 1 THEN
        fnd_message.set_name('PA', 'PA_ARPR_SOURCE_PROJECT');
        fnd_msg_pub.add;
        l_err_code   :=  10 ;

        l_err_stage := 'After checking for source project' ;
        l_err_stack := l_err_stack ||
                       ' ->After checking for source project' ;
        pa_debug.debug('    * There exists a rule with run status not as RS which contains
the project '||to_char(p_project_id)|| 'as source project');
     END IF;

     IF l_target_project = 1 THEN
        fnd_message.set_name('PA', 'PA_ARPR_TARGET_PROJECT');
        fnd_msg_pub.add;
        l_err_code   :=  10 ;

        l_err_stage := 'After checking for tartget project' ;
        l_err_stack := l_err_stack ||
                       ' ->After checking for target project' ;
        pa_debug.debug('    * There exists a rule with run status not as RS which contains
the project '||to_char(p_project_id)|| 'as target project');
     END IF;

     IF l_offset_project = 1 THEN
        fnd_message.set_name('PA', 'PA_ARPR_OFFSET_PROJECT');
        fnd_msg_pub.add;
        l_err_code   :=  10 ;

        l_err_stage := 'After checking for offset project' ;
        l_err_stack := l_err_stack ||
                       ' ->After checking for offset project' ;
        pa_debug.debug('    * There exists a rule with run status not as RS which contains
the project '||to_char(p_project_id)|| 'as offset project');
     END IF;

/* checking for the project in property manager */
     IF ( NOT PNP_OTH_PROD.delete_project (p_project_id) ) then
        fnd_message.set_name('PA', 'PA_ARPR_PROJ_INUSE_PROP_MGR');
        fnd_msg_pub.add;
        l_err_code   :=  10 ;

        l_err_stage := 'After checking for the project in property manager';
        l_err_stack := l_err_stack ||
                       ' ->After checking for the project in property manager';
        pa_debug.debug('    *  The project '||to_char(p_project_id)|| 'is in use by Property Manager module');
     END IF;


/*  checking for the project in contract commitments  */
/* commneted the code and added the modified code below since the arguments are changed in the
   call to the procedure IGC_CC_PROJECTS_PKG.delete_project for bug#2272487
       IF ( NOT IGC_CC_PROJECTS_PKG.delete_project (p_project_id) ) then
        fnd_message.set_name('PA', 'PA_ARPR_PROJ_INUSE_CNTR_CMTS');
        fnd_msg_pub.add;
        l_err_code   :=  10 ;

        l_err_stage := 'After checking for the project in contract commitments';
        l_err_stack := l_err_stack ||
                       ' ->After checking for the project in contract commitments';
        pa_debug.debug('    *  The project '||to_char(p_project_id)|| 'is in use by Contract Commitments');
     END IF;
*/

/*  checking for the project in contract commitments  */
       select count(*) into l_igc_exists
	 from fnd_product_installations
        where application_id = 8407
        and   status <> 'N';

     IF ( l_igc_exists > 0 ) then

       V_CursorID := DBMS_SQL.OPEN_CURSOR;

       V_Stmt := ' begin
                     IGC_CC_PROJECTS_PKG.delete_project (:project_id, :delete_allowed);
                   end; ';

       DBMS_SQL.PARSE(V_CursorID, V_Stmt, DBMS_SQL.v7);

       DBMS_SQL.BIND_VARIABLE(V_CursorID, ':project_id', p_project_id, 20);
       DBMS_SQL.BIND_VARIABLE(V_CursorID, ':delete_allowed', V_Delete_Allowed, 1);

       V_Dummy := DBMS_SQL.EXECUTE(V_CursorID);

       DBMS_SQL.VARIABLE_VALUE(V_CursorID, ':delete_allowed', V_Delete_Allowed);

       DBMS_SQL.CLOSE_CURSOR(V_CursorID);

       IF ( V_Delete_Allowed = 'N' ) then
           fnd_message.set_name('PA', 'PA_ARPR_PROJ_INUSE_CNTR_CMTS');
           fnd_msg_pub.add;
           l_err_code   :=  10 ;

           l_err_stage := 'After checking for the project in contract commitments';
           l_err_stack := l_err_stack ||
                       ' ->After checking for the project in contract commitments';
           pa_debug.debug('    *  The project '||to_char(p_project_id)|| 'is in use by Contract Commitments');
       END IF;

     END IF;
     -- Check supplier invoices eligible for discounts are fully paid.

     Open IsVIPaymentPendg;
     Fetch IsVIPaymentPendg into l_dummy ;
     If l_dummy is not null then
        fnd_message.set_name('PA', 'PA_ARPR_VI_DIS_NOT_PAID');
        fnd_msg_pub.add;
        l_err_code  :=  10 ;
        l_err_stage := 'After VI discount check' ;
        l_err_stack := l_err_stack || ' ->After VI discount check' ;
        pa_debug.debug('    * Supplier invoice eligible for discount not fully paid for project '||to_char(p_project_id));
     End If;
     Close IsVIPaymentPendg;
     l_dummy := NULL;

/* Bug#2416385 Commented for Phase-3 Archive and Purg
     Open ISInterPrjRecvPrj;
     Fetch ISInterPrjRecvPrj into l_dummy;
     If l_dummy is not null then
        fnd_message.set_name('PA','PA_ARPR_IP_RCVR_PROJ');
        fnd_msg_pub.add;
        l_err_code  :=  10 ;
        l_err_stage := 'After IP receiver project check' ;
        l_err_stack := l_err_stack || ' ->After IP receiver project check' ;
        pa_debug.debug('    * This is an inter-project receiver project');
     End If;
     Close ISInterPrjRecvPrj;
     l_dummy := NULL;
*/
     Open ISDistLinesIntfed;
     Fetch ISDistLinesIntfed into l_dummy;
     If l_dummy is not null then
        fnd_message.set_name('PA','PA_ARPR_VI_DISC_NOT_IFCD');
        fnd_msg_pub.add;
        l_err_code  :=  10 ;
        l_err_stage := 'After Vendor invoice discount interface check' ;
        l_err_stack := l_err_stack || ' ->After Vendor invoice discount interface check' ;
        pa_debug.debug('    * Supplier invoice discount lines not interfaced');
     End If;
     Close ISDistLinesIntfed;
     l_dummy := NULL;

     Open ISOrgForecastProject;
     Fetch ISOrgForecastProject into l_dummy;
     If l_dummy is not null then
        fnd_message.set_name('PA','PA_ARPR_ORG_FC_DUM_PRJ');
        fnd_msg_pub.add;
        l_err_code  :=  10 ;
        l_err_stage := 'After organization forecast project check' ;
        l_err_stack := l_err_stack || ' ->After organization forecast project check' ;
        pa_debug.debug('    * This is an organization forecast project');
     End If;
     Close ISOrgForecastProject;
     l_dummy := NULL;

     Open IsUnassignedTimeType;
     Fetch IsUnassignedTimeType into l_dummy;
     If l_dummy is not null then
        fnd_message.set_name('PA','PA_ARPR_UNASS_PROJ_TYPE');
        fnd_msg_pub.add;
        l_err_code  :=  10 ;
        l_err_stage := 'After Unassigned Time project type check' ;
        l_err_stack := l_err_stack || ' ->After Unassigned Time project type check' ;
        pa_debug.debug('    * This is an unassigned time project');
     End If;
     Close IsUnassignedTimeType;
     l_dummy := NULL;

     /* bug # 2695986 */
     /* bug 2767419
     select to_number(replace(release_name,'.'))
     into   l_dummy_num
     from fnd_product_groups;

     IF l_dummy_num > 1154 THEN
	     V_Stmt := 'select ' || '''Iexpense Transactions Pending''' ||
			' from dual '||
			' where exists (select h.report_header_id '||
			    ' from   ap_expense_report_headers h, '||
				   ' ap_expense_report_lines l '||
			    ' where  h.report_header_id = l.report_header_id '||
			    ' and    h.source <> '||'''Oracle Project Accounting''' ||
			    ' and    l.project_id = :p_proj_id '||
			    ' and    ( :p_act_flag <> '|| '''A''' ||
			    ' or (trunc(l.expenditure_item_date ) <= trunc(:p_txn_date ) )) '||
			    ' and    nvl(l.pa_interfaced_flag,'||'''N'''||') <> '||'''Y'''||')';


	      V_CursorID := DBMS_SQL.OPEN_CURSOR;
	      DBMS_SQL.PARSE(V_CursorID, V_Stmt, DBMS_SQL.v7);
	      DBMS_SQL.BIND_VARIABLE(V_CursorID, ':p_act_flag',p_active_flag);
	      DBMS_SQL.BIND_VARIABLE(V_CursorID, ':p_proj_id',p_project_id);
	      DBMS_SQL.BIND_VARIABLE(V_CursorID, ':p_txn_date',p_txn_to_date);
	      V_Dummy := DBMS_SQL.EXECUTE(V_CursorID);

	      IF (DBMS_SQL.FETCH_ROWS(V_CursorID) > 0 ) THEN
		fnd_message.set_name('PA','PA_ARPR_IEXP_TXNS_IMP_PEND');
		fnd_msg_pub.add;
		l_err_code  :=  10 ;
		l_err_stage := 'After Iexpense transactions transfer check' ;
		l_err_stack := l_err_stack || ' ->After Iexpense transactions transfer check' ;
		pa_debug.debug('    * Project related Iexpense transactions are yet to be imported to projects');
	      END IF;

	      DBMS_SQL.CLOSE_CURSOR(V_CursorID);
       END IF;
    */

     Open IsIexpenseTxnsPending;
     Fetch IsIexpenseTxnsPending into l_dummy;
     If l_dummy is not null then
	fnd_message.set_name('PA','PA_ARPR_IEXP_TXNS_IMP_PEND');
	fnd_msg_pub.add;
	l_err_code  :=  10 ;
	l_err_stage := 'After Iexpense transactions transfer check' ;
	l_err_stack := l_err_stack || ' ->After Iexpense transactions transfer check' ;
	pa_debug.debug('    * Project related Iexpense transactions are yet to be imported to projects');
     End If;
     Close IsIexpenseTxnsPending;
     l_dummy := NULL;

     Open IsERPaymentPendg;
     Fetch IsERPaymentPendg into l_dummy ;
     If l_dummy is not null then
        fnd_message.set_name('PA', 'PA_ARPR_ER_NOT_PAID');
        fnd_msg_pub.add;
        l_err_code  :=  10 ;
        l_err_stage := 'After ER Payment check' ;
        l_err_stack := l_err_stack || ' ->After ER Payment check' ;
        pa_debug.debug('    * Expense reports are yet to be paid for the project '||to_char(p_project_id));
     End If;
     Close IsERPaymentPendg;
     l_dummy := NULL;

     x_err_code  := l_err_code ;
     x_err_stage := l_err_stage ;
     x_err_stack := l_err_stack_old ;

EXCEPTION
  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error then
       RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
    x_err_stage := l_err_stage ;
    pa_debug.debug('Error Procedure Name  := PA_PURGE_VALIDATE_COSTING.VALIDATE_COSTING' );
    pa_debug.debug('Error stage is '||l_err_stage );
    pa_debug.debug('Error stack is '||l_err_stack );
    pa_debug.debug(SQLERRM);
    PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM ;

    RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

 END Validate_Costing ;


 PROCEDURE Validate_Allocations ( p_proj_id                    IN  NUMBER,
			          x_source                     OUT NOCOPY  NUMBER,
			 	  x_target                     OUT NOCOPY  NUMBER,
				  x_offset                     OUT NOCOPY  NUMBER)
 IS

/* Modified these 2 cursors and added the modified code below for the bug#2272487 */

      cursor c_source is
      select 1
        from dual
      where exists ( select null
                       from pa_alloc_run_sources pars,
                            pa_alloc_runs par
                      where par.rule_id = pars.rule_id
                        and pars.project_id = p_proj_id
                        and par.run_id = pars.run_id
                   /*     and par.run_status <> 'RS'   commented for bug#2446122   */
			and par.run_status not in ( 'RS', 'RV')   /* Added for bug#2446122  */
                   );

      cursor c_target is
      select 1
        from dual
       where exists ( select null
                        from pa_alloc_run_targets part,
                             pa_alloc_runs par
                       where par.rule_id = part.rule_id
                         and part.project_id = p_proj_id
                         and par.run_id = part.run_id
                   /*     and par.run_status <> 'RS'   commented for bug#2446122   */
			and par.run_status not in ( 'RS', 'RV')   /* Added for bug#2446122  */
                    );

 /* added the check for offsets for bug#2272487  */

      cursor c_offset is
      select 1
        from dual
       where exists ( select null
                        from pa_alloc_rules_all para,
                             pa_alloc_runs par
                       where par.rule_id = para.rule_id
                         and para.offset_project_id = p_proj_id
                   /*     and par.run_status <> 'RS'   commented for bug#2446122   */
			and par.run_status not in ( 'RS', 'RV')   /* Added for bug#2446122  */
                    );



      l_source           NUMBER DEFAULT 0;
      l_target           NUMBER DEFAULT 0;
      l_offset           NUMBER DEFAULT 0;

 BEGIN

     -- Check if there is any allocation rule existing with status not as
     -- Released Successfully (RS) having the input project_id

      open c_source;
      fetch c_source into l_source;
      close c_source;

      open c_target;
      fetch c_target into l_target;
      close c_target;

      open c_offset;
      fetch c_offset into l_offset;
      close c_offset;

      x_source := l_source;
      x_target := l_target;
      x_offset := l_offset;

 END Validate_Allocations;

END ;

/
