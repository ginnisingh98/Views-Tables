--------------------------------------------------------
--  DDL for Package Body PA_PURGE_VALIDATE_BILLING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PURGE_VALIDATE_BILLING" as
/* $Header: PAXBIVTB.pls 120.7 2007/10/31 05:31:59 dlella ship $ */

-- Start of comments
-- API name         : Validate_Billing
-- Type             : Public
-- Pre-reqs         : None
-- Function         : Validates the data in billing tables before purge for a project
--                    and reports the invalid data conditions
--                    The following validations are performed
--
--                    1.All the expenditure items should be revenue distributed.
--                    2.All the draft revenues are transferred and accepted in GL.
--                    3.All the draft invoices are transferred and accepted in AR.
--                    4.All revenue are summarized (*** Removed).
--                    5.Unbilled Recievables and Unearned Revenue should be zero.
--                    6.Events having completion date should be processed
--
--
-- Parameters         p_batch_id			IN     NUMBER
--                              The purge batch id for which rows have
--                              to be purged/archived.
--		      p_project_Id			IN     NUMBER,
--                              The project id for which records have
--                              to be purged/archived.
--		      p_Active_Flag		        IN     VARCHAR2,
--                              Indicates if batch contains ACTIVE or CLOSED projects
--                              ( 'A' - Active , 'C' - Closed)
--		      p_Txn_To_Date			IN     DATE,
--                              Date on or before which all transactions are to be purged
--                              (Will be used by Costing only)
--		      X_Err_Stack			IN OUT VARCHAR2,
--                              Error stack
--		      X_Err_Stage		        IN OUT VARCHAR2,
--                              Stage in the procedure where error occurred
--		      X_Err_Code		        IN OUT NUMBER
--                              Error code returned from the procedure
--                              = 0 SUCCESS
--                              > 0 Application error
--                              < 0 Oracle error
-- End of comments

 procedure validate_billing ( p_project_id                     in NUMBER,
                              p_txn_to_date                    in DATE,
                              p_active_flag                    in VARCHAR2,
                              x_err_code                       in OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                              x_err_stack                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              x_err_stage                      in OUT NOCOPY VARCHAR2 ) is --File.Sql.39 bug 4440895

  -- Cursor for billing validaton before purge
  --
  cursor IsBillingValid(p_user_source_name IN VARCHAR2) is
---Comments for the bug - 6522044..starts here
  /*    select 'Not Revenue Distributed' , 'PA_ARPR_NOT_REV_DIST'
      from dual
      where exists ( select spf.project_id
                     from   pa_summary_project_fundings spf,
                             pa_projects_all pp,
                          -- pa_project_types_all pt  -- performance changes bug 2706550
                             pa_project_types_v  pt   -- Added to remove FTS bug 2706550
                       where
			 pp.project_id = p_project_id
                         and pp.project_type = pt.project_type
 			 and pt.project_type_class_code = 'CONTRACT'
                         and spf.project_id = pp.project_id
			 and nvl(spf.total_baselined_amount,0) <> 0
                       group by  spf.project_id
                       having
              -- Total baselined amount need not be equal to billed or accrued
              -- amount in case of soft limit. Total invoiced and accrued amt
              -- should atleast be equal to total baselined amount in any case.
              --       sum (spf.total_baselined_amount) <> sum(spf.total_accrued_amount)
              --       OR
              --       sum (spf.total_baselined_amount) <> sum (spf.total_billed_amount)

              --  Commented as the desired functionality is to check against PFC for accrued and
              --     IPC for billed
              --       sum (spf.total_baselined_amount) > sum(spf.total_accrued_amount)
              --       OR
              --       sum (spf.total_baselined_amount) > sum (spf.total_billed_amount)

                       sum (spf.projfunc_baselined_amount) > sum(spf.projfunc_accrued_amount)
                       OR
                       sum (spf.invproc_baselined_amount) > sum (spf.invproc_billed_amount)
                    )
      UNION */
      -- ---Comments for the bug - 6522044..ends here
           /*  Deleted the old code and added below for bug # 2861315  */
           select 'Revenue Not Transferred and Accepted ' , 'PA_ARPR_NOT_REV_IFCD'
           from dual
           where exists ( select draft_revenue_num
                            from pa_draft_revenues  dr,
                                 pa_implementations imp
                          where  dr.project_id = p_project_id
                           and  (( dr.transfer_status_code <> 'A'
                                   and nvl(imp.INTERFACE_REVENUE_TO_GL_FLAG,'N')<>'Y')
                                 or (imp.INTERFACE_REVENUE_TO_GL_FLAG = 'Y'
                                     and ((nvl(dr.unearned_revenue_cr,0) <> 0
				           and exists (select 'In XLA AE Lines'
                                                             from xla_ae_headers xh, xla_ae_lines xl, xla_distribution_links xdl
                                                            where xh.event_id = dr.event_id
                                			      and xl.ae_header_id = xh.ae_header_id
							      and xl.ae_header_id = xdl.ae_header_id
                                                              and xl.ae_line_num = xdl.ae_line_num
                                                              and xdl.SOURCE_DISTRIBUTION_TYPE  = 'Revenue - UER'
                                                              and xdl.SOURCE_DISTRIBUTION_ID_NUM_1 = dr.project_id
                                                              and xdl.SOURCE_DISTRIBUTION_ID_NUM_2 = dr.draft_revenue_num
							      and xh.accounting_entry_status_code <> 'F' ))
                                           or (nvl(dr.unbilled_receivable_dr,0) <> 0
                                           and exists (select 'In XLA AE Lines'
                                                             from xla_ae_headers xh, xla_ae_lines xl, xla_distribution_links xdl
                                                            where xh.event_id = dr.event_id
                                			      and xl.ae_header_id = xh.ae_header_id
							      and xl.ae_header_id = xdl.ae_header_id
                                                              and xl.ae_line_num = xdl.ae_line_num
                                                              and xdl.SOURCE_DISTRIBUTION_TYPE  = 'Revenue - UBR'
                                                              and xdl.SOURCE_DISTRIBUTION_ID_NUM_1 = dr.project_id
                                                              and xdl.SOURCE_DISTRIBUTION_ID_NUM_2 = dr.draft_revenue_num
							      and xh.accounting_entry_status_code <> 'F'
                           ))))))
      UNION
      select 'Invoice has outstanding balance ' , 'PA_ARPR_INV_AMT_DUE'
        from dual
       where exists ( select draft_invoice_num
                         from  pa_draft_invoices_all di,
                               ar_payment_schedules  ar
                         where di.project_id = p_project_id
                         and di.transfer_status_code = 'A'
                         and ar.customer_trx_id = di.system_reference
                         and ( ar.amount_due_remaining is null
                               OR ar.amount_due_remaining <> 0 ))
      UNION
      select 'Invoice Not Transferred and Accepted ' , 'PA_ARPR_NOT_INV_IFCD'
        from dual
       where exists ( select draft_invoice_num
                         from  pa_draft_invoices_all di
                         where di.project_id = p_project_id
                         and di.transfer_status_code <> 'A')
      UNION
      select 'UBR and UER not cleared' , 'PA_ARPR_NOT_UBR_UER'
        from dual
       where exists ( select project_id
                         from pa_projects_all pp
                         where pp.project_id = p_project_id
                         and
                            (nvl(pp.unbilled_receivable_dr,0) <> 0
                             or
                             nvl(pp.unearned_revenue_cr,0)    <> 0)
                    )
     UNION
     /* Bug 2423429. Use transaction value of bill and revenue amount */
     select 'Events not processed' , 'PA_ARPR_NOT_ENVT_PCSD'
     from dual
     where exists
             ( select 'x'
            /* from pa_events_v ev  Commented for performance bug 2706550 */
               from pa_events  ev     /* Added for performance bug 2706550 */
               where ev.project_id = p_project_id
               and   NVL(ev.revenue_distributed_flag,'N') <> 'Y'
               and   NVL(ev.bill_trans_REV_AMOUNT,0) > 0
               UNION
               select 'x'
            /* from pa_events_v ey,  Commented for performance bug 2706550 */
               from pa_events  ey,     /* Added for performance bug 2706550 */
                    pa_event_types et
               where ey.project_id = p_project_id
               and   et.event_type = ey.event_type
               and   NVL(ey.bill_hold_flag,'N') = 'N'
               and   NVL(ey.bill_trans_bill_amount,0) <> 0
               and not exists
                   ( select 'x' from
                      pa_draft_invoice_items di
                     where   di.project_id = ey.project_id
                     and   NVL(di.event_task_id,-1) = NVL(ey.task_id,-1)
                     and   di.event_num = ey.event_num
		     and   not exists (
				select NULL from pa_draft_invoices inv
			        where inv.project_id = di.project_id
				  and inv.draft_invoice_num = di.draft_invoice_num
				  and inv.write_off_flag ='Y')
                     having sum(di.bill_trans_bill_amount) =
                       decode(et.event_type_classification,'INVOICE REDUCTION',
                                -ey.bill_trans_bill_amount,ey.bill_trans_bill_amount )
                   )
             )
     UNION
      select 'This is an Inter Company Billing Project', 'PA_ARPR_IC_BILLING_PROJ'
        from dual
       where exists ( select null
                        from pa_projects pp, pa_project_types pt
                       where pp.project_id = p_project_id
                         and pp.project_type = pt.project_type
                         and pt.project_type_class_code = 'CONTRACT'
                         and pt.cc_prvdr_flag = 'Y'
                    )
/*   UNION
      select 'This is an Inter Company Cross Charge Project', 'PA_ARPR_IC_CC_PROJ'
        from dual
       where exists ( select null
                        from pa_draft_invoice_details_all
                       where cc_project_id = p_project_id
		    )
Already this check is there in costing validation		    */
/* Bug#2416385 Commented for Phase 3 of Archive and Purge
     UNION
      select 'This is an Inter-Project Provider Project', 'PA_ARPR_IP_PRVDR_PROJ'
        from dual
       where exists ( select NULL
                        from pa_project_customers ppc
                       where ppc.project_id = p_project_id
                         and ppc.bill_another_project_flag = 'Y'
                         and ppc.receiver_task_id is not null
		    )    */
/*** bug 2396427. Moving this validation to costing module, since
     receiver project can be an indirect project and billing validation
     is done only for contract projects.
     UNION
      select 'This is an Inter-Project Receiver Project', 'PA_ARPR_IP_RCVR_PROJ'
        from dual
       where exists ( select NULL
                        from pa_tasks pt
                       where pt.project_id = p_project_id
                         and pt.receive_project_invoice_flag = 'Y' */
/*                         and pt.task_id in ( select receiver_task_id
                                               from pa_project_customers ppc
          		                     ) modified for the bug# 2272487  */
/*                           and exists ( select NULL
					  from pa_project_customers ppc
				         where ppc.receiver_task_id = pt.task_id)
                    )*/
     UNION
      select 'All retentions are not billed for this project', 'PA_ARPR_RETN_NOT_BILLED'
        from dual
       where 0 <> ( select (sum(nvl(project_total_retained,0)) - sum(nvl(project_total_billed,0)))
                      from pa_summary_project_retn
                     where project_id = p_project_id
                     group by project_id
		   );

      l_err_stack    VARCHAR2(2000);
      l_err_stage    VARCHAR2(500);
      l_err_code     NUMBER ;
      l_dummy        VARCHAR2(500);
      l_msg_name     VARCHAR2(50);
      l_user_source_name    VARCHAR2(25);
      l_used_by_oke  BOOLEAN;

 BEGIN
     l_err_code  := 0 ;
     l_err_stage := x_err_stage;
     l_err_stack := x_err_stack;
     pa_debug.debug('-- Performing Billing validation for project '||to_char(p_project_id));

     -- Open cursor
     -- If cursor returns one or more rows , indicates that
     -- project is not valid for purge as far as billing is concerned
     --
     SELECT user_je_source_name
     INTO   l_user_source_name
     FROM   GL_Je_Sources
     WHERE je_source_name='Project Accounting';

     Open IsBillingValid(l_user_source_name) ;

     pa_debug.debug('-- After Open cursor IsBillingValid');

     LOOP

     -- Fetch a row for each validation that failed
     -- and set the appropriate message
     --
     Fetch IsBillingValid into l_dummy , l_msg_name ;
     Exit When IsBillingValid%Notfound;
        fnd_message.set_name('PA',l_msg_name );
        fnd_msg_pub.add;
        l_err_stack  := l_err_stack || ' ->After open cursor ' ||l_dummy ;
        pa_debug.debug('   * '  || l_dummy|| ' for ' || to_char(p_project_id));


     END LOOP;

     close IsBillingValid;

     --Check to see if any projects are in use by contract integration system.

     pa_debug.debug('-- Before call to check usage by OKE');

     l_used_by_oke := OKE_DTS_PA_PKG.Project_Exist(p_project_id);

     IF l_used_by_oke
     THEN
         fnd_message.set_name('PA','PA_ARPR_PROJ_INUSE_CNTRCT_INT');
         fnd_msg_pub.add;
         l_err_stage := 'After OKE check';
         l_err_stack :=  l_err_stack || ' ->After OKE check' ;
         pa_debug.debug('   * This project '||to_char(p_project_id)||' is in use by OKE ');
     END IF;

     pa_debug.debug('-- After call to check usage by OKE');

     x_err_stage := l_err_stage ;
     x_err_stack := l_err_stack ;

EXCEPTION
  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error then
       RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
     x_err_stage := l_err_stage ;

     /* ATG Changes */

     x_err_stack := l_err_stack;


    pa_debug.debug('Error Procedure Name  := PA_PURGE_VALIDATE_BILLING.VALIDATE_BILLING' );
    pa_debug.debug('Error stage is '||l_err_stage );
    pa_debug.debug('Error stack is '||l_err_stack );
    pa_debug.debug(SQLERRM);
    PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM ;

    RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

END validate_billing ;

END ;

/
