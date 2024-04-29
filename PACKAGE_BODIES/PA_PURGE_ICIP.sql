--------------------------------------------------------
--  DDL for Package Body PA_PURGE_ICIP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PURGE_ICIP" as
/*$Header: PAICIPPB.pls 120.6.12010000.2 2009/06/23 14:25:58 atshukla ship $*/


    l_commit_size     NUMBER ;
    l_mrc_flag        VARCHAR2(1) := 'N';
    l_pmy_commit_size     NUMBER ;

/*

-- Start of comments
-- API name         : PA_DraftInvDetails
-- Type             : Private
-- Pre-reqs         : None
-- Function         : Archive and Purge data for table PA_DRAFT_INVOICE_DETAILS_ALL
-- Parameters       : See common list above
-- End of comments
*/

     procedure PA_DraftInvDetails ( p_purge_batch_id                 in NUMBER,
				    p_project_id                     in NUMBER,
				    p_purge_release                  in VARCHAR2,
				    p_txn_to_date                    in DATE,
				    p_archive_flag                   in VARCHAR2,
				    p_commit_size                    in NUMBER,
				    x_err_stack                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
				    x_err_stage                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
				    x_err_code                       in OUT NOCOPY NUMBER ) is --File.Sql.39 bug 4440895


     l_old_err_stage         VARCHAR2(2000);
     l_old_err_stack         VARCHAR2(2000);
     l_NoOfRecordsIns        NUMBER;
     l_NoOfRecordsDel        NUMBER;
     l_MRC_NoOfRecordsIns     NUMBER := NULL;
     l_MRC_NoOfRecordsDel     NUMBER := NULL;

 begin

     l_old_err_stack := x_err_stack;

     x_err_stack := x_err_stack || ' ->Entering PA_DRAFT_INVOICE_DETAILS_ALL' ;

     pa_debug.debug(x_err_stack);

     LOOP
      l_NoOfRecordsDel := 0;  -- Value of l_NoOfRecordsDel is reset for BUg 4104133
      l_NoOfRecordsIns := 0;  -- Value of l_NoOfRecordsDel is reset for BUg 4104133
               if p_archive_flag = 'Y' then

                     -- If archive option is selected then the records are
                     -- inserted into the archived into the archive tables
                     -- before being purged. The where condition is such that
                     -- only the it inserts half the no. of records specified
                     -- in the commit size.

                     l_commit_size := pa_utils2.arpur_mrc_commit_size / 2 ;

     pa_debug.debug( ' ->Before insert into PA_DRAFT_INV_DETS_AR') ;

	          if p_txn_to_date IS NOT NULL then
                     insert into PA_DRAFT_INV_DETS_AR (
		                 PURGE_BATCH_ID,
				 PURGE_RELEASE,
				 PURGE_PROJECT_ID,
				 DRAFT_INVOICE_DETAIL_ID,
				 EXPENDITURE_ITEM_ID,
				 LINE_NUM,
				 PROJECT_ID,
				 DENOM_CURRENCY_CODE,
				 DENOM_BILL_AMOUNT,
				 ACCT_CURRENCY_CODE,
                                 BILL_AMOUNT,
                                 REQUEST_ID,
                                 LAST_UPDATE_DATE,
                                 LAST_UPDATED_BY,
                                 CREATION_DATE,
                                 CREATED_BY,
				 LAST_UPDATE_LOGIN,
				 ACCT_RATE_TYPE,
				 ACCT_RATE_DATE,
				 ACCT_EXCHANGE_RATE,
				 CC_PROJECT_ID,
				 CC_TAX_TASK_ID,
				 ORG_ID,
				 REV_CODE_COMBINATION_ID,
				 DRAFT_INVOICE_NUM,
				 DRAFT_INVOICE_LINE_NUM,
				 OUTPUT_VAT_TAX_ID,
                                 OUTPUT_TAX_CLASSIFICATION_CODE,
				 OUTPUT_TAX_EXEMPT_FLAG,
				 OUTPUT_TAX_EXEMPT_REASON_CODE,
				 OUTPUT_TAX_EXEMPT_NUMBER,
				 LINE_NUM_REVERSED,
				 DETAIL_ID_REVERSED,
				 REVERSED_FLAG,
				 PROJACCT_CURRENCY_CODE,
				 PROJACCT_COST_AMOUNT,
				 PROJACCT_BILL_AMOUNT,
				 MARKUP_CALC_BASE_CODE,
				 IND_COMPILED_SET_ID,
				 RULE_PERCENTAGE,
				 BILL_RATE,
				 BILL_MARKUP_PERCENTAGE,
				 BASE_AMOUNT,
				 SCHEDULE_LINE_PERCENTAGE,
				 INVOICED_FLAG,
				 ORIG_DRAFT_INVOICE_NUM,
				 ORIG_DRAFT_INVOICE_LINE_NUM,
				 PROGRAM_APPLICATION_ID,
				 PROGRAM_ID,
				 PROGRAM_UPDATE_DATE,
				 TP_JOB_ID,
				 PROV_PROJ_BILL_JOB_ID,
				 PROJECT_TP_CURRENCY_CODE,
				 PROJECT_TP_RATE_DATE,
				 PROJECT_TP_RATE_TYPE,
				 PROJECT_TP_EXCHANGE_RATE,
				 PROJFUNC_TP_CURRENCY_CODE,
				 PROJFUNC_TP_RATE_DATE,
				 PROJFUNC_TP_RATE_TYPE,
				 PROJFUNC_TP_EXCHANGE_RATE,
				 PROJECT_TRANSFER_PRICE,
				 PROJFUNC_TRANSFER_PRICE,
				 TP_AMT_TYPE_CODE
                           )
                       select
       		    	         p_purge_batch_id,
                                 p_purge_release,
                                 p_project_id,
                                 DRAFT_INVOICE_DETAIL_ID,
                                 EXPENDITURE_ITEM_ID,
                                 LINE_NUM,
                                 PROJECT_ID,
                                 DENOM_CURRENCY_CODE,
                                 DENOM_BILL_AMOUNT,
                                 ACCT_CURRENCY_CODE,
                                 BILL_AMOUNT,
                                 REQUEST_ID,
                                 LAST_UPDATE_DATE,
                                 LAST_UPDATED_BY,
                                 CREATION_DATE,
                                 CREATED_BY,
                                 LAST_UPDATE_LOGIN,
                                 ACCT_RATE_TYPE,
                                 ACCT_RATE_DATE,
                                 ACCT_EXCHANGE_RATE,
                                 CC_PROJECT_ID,
                                 CC_TAX_TASK_ID,
                                 ORG_ID,
                                 REV_CODE_COMBINATION_ID,
                                 DRAFT_INVOICE_NUM,
                                 DRAFT_INVOICE_LINE_NUM,
                                 OUTPUT_VAT_TAX_ID,
                                 OUTPUT_TAX_CLASSIFICATION_CODE,
                                 OUTPUT_TAX_EXEMPT_FLAG,
                                 OUTPUT_TAX_EXEMPT_REASON_CODE,
                                 OUTPUT_TAX_EXEMPT_NUMBER,
                                 LINE_NUM_REVERSED,
                                 DETAIL_ID_REVERSED,
                                 REVERSED_FLAG,
                                 PROJACCT_CURRENCY_CODE,
                                 PROJACCT_COST_AMOUNT,
                                 PROJACCT_BILL_AMOUNT,
                                 MARKUP_CALC_BASE_CODE,
                                 IND_COMPILED_SET_ID,
                                 RULE_PERCENTAGE,
                                 BILL_RATE,
                                 BILL_MARKUP_PERCENTAGE,
                                 BASE_AMOUNT,
                                 SCHEDULE_LINE_PERCENTAGE,
                                 INVOICED_FLAG,
                                 ORIG_DRAFT_INVOICE_NUM,
                                 ORIG_DRAFT_INVOICE_LINE_NUM,
                                 PROGRAM_APPLICATION_ID,
                                 PROGRAM_ID,
                                 PROGRAM_UPDATE_DATE,
                                 TP_JOB_ID,
                                 PROV_PROJ_BILL_JOB_ID,
                                 PROJECT_TP_CURRENCY_CODE,
                                 PROJECT_TP_RATE_DATE,
                                 PROJECT_TP_RATE_TYPE,
                                 PROJECT_TP_EXCHANGE_RATE,
                                 PROJFUNC_TP_CURRENCY_CODE,
                                 PROJFUNC_TP_RATE_DATE,
                                 PROJFUNC_TP_RATE_TYPE,
                                 PROJFUNC_TP_EXCHANGE_RATE,
                                 PROJECT_TRANSFER_PRICE,
                                 PROJFUNC_TRANSFER_PRICE,
                                 TP_AMT_TYPE_CODE
                       from pa_draft_invoice_details_all
                       where expenditure_item_id in
			       ( select ei.expenditure_item_id
			  	   from pa_tasks t,
				        pa_expenditure_items_all ei
			          where ei.expenditure_item_date <= p_txn_to_date
				    and ei.task_id = t.task_id
				    and t.project_id = p_project_id )
                         and rownum <= l_commit_size;
                  else
                     insert into PA_DRAFT_INV_DETS_AR (
		                 PURGE_BATCH_ID,
				 PURGE_RELEASE,
				 PURGE_PROJECT_ID,
				 DRAFT_INVOICE_DETAIL_ID,
				 EXPENDITURE_ITEM_ID,
				 LINE_NUM,
				 PROJECT_ID,
				 DENOM_CURRENCY_CODE,
				 DENOM_BILL_AMOUNT,
				 ACCT_CURRENCY_CODE,
                                 BILL_AMOUNT,
                                 REQUEST_ID,
                                 LAST_UPDATE_DATE,
                                 LAST_UPDATED_BY,
                                 CREATION_DATE,
                                 CREATED_BY,
				 LAST_UPDATE_LOGIN,
				 ACCT_RATE_TYPE,
				 ACCT_RATE_DATE,
				 ACCT_EXCHANGE_RATE,
				 CC_PROJECT_ID,
				 CC_TAX_TASK_ID,
				 ORG_ID,
				 REV_CODE_COMBINATION_ID,
				 DRAFT_INVOICE_NUM,
				 DRAFT_INVOICE_LINE_NUM,
--				 OUTPUT_VAT_TAX_ID,
                                 OUTPUT_TAX_CLASSIFICATION_CODE,
				 OUTPUT_TAX_EXEMPT_FLAG,
				 OUTPUT_TAX_EXEMPT_REASON_CODE,
				 OUTPUT_TAX_EXEMPT_NUMBER,
				 LINE_NUM_REVERSED,
				 DETAIL_ID_REVERSED,
				 REVERSED_FLAG,
				 PROJACCT_CURRENCY_CODE,
				 PROJACCT_COST_AMOUNT,
				 PROJACCT_BILL_AMOUNT,
				 MARKUP_CALC_BASE_CODE,
				 IND_COMPILED_SET_ID,
				 RULE_PERCENTAGE,
				 BILL_RATE,
				 BILL_MARKUP_PERCENTAGE,
				 BASE_AMOUNT,
				 SCHEDULE_LINE_PERCENTAGE,
				 INVOICED_FLAG,
				 ORIG_DRAFT_INVOICE_NUM,
				 ORIG_DRAFT_INVOICE_LINE_NUM,
				 PROGRAM_APPLICATION_ID,
				 PROGRAM_ID,
				 PROGRAM_UPDATE_DATE,
				 TP_JOB_ID,
				 PROV_PROJ_BILL_JOB_ID,
				 PROJECT_TP_CURRENCY_CODE,
				 PROJECT_TP_RATE_DATE,
				 PROJECT_TP_RATE_TYPE,
				 PROJECT_TP_EXCHANGE_RATE,
				 PROJFUNC_TP_CURRENCY_CODE,
				 PROJFUNC_TP_RATE_DATE,
				 PROJFUNC_TP_RATE_TYPE,
				 PROJFUNC_TP_EXCHANGE_RATE,
				 PROJECT_TRANSFER_PRICE,
				 PROJFUNC_TRANSFER_PRICE,
				 TP_AMT_TYPE_CODE
                           )
                       select
       		    	         p_purge_batch_id,
                                 p_purge_release,
                                 p_project_id,
                                 DRAFT_INVOICE_DETAIL_ID,
                                 EXPENDITURE_ITEM_ID,
                                 LINE_NUM,
                                 PROJECT_ID,
                                 DENOM_CURRENCY_CODE,
                                 DENOM_BILL_AMOUNT,
                                 ACCT_CURRENCY_CODE,
                                 BILL_AMOUNT,
                                 REQUEST_ID,
                                 LAST_UPDATE_DATE,
                                 LAST_UPDATED_BY,
                                 CREATION_DATE,
                                 CREATED_BY,
                                 LAST_UPDATE_LOGIN,
                                 ACCT_RATE_TYPE,
                                 ACCT_RATE_DATE,
                                 ACCT_EXCHANGE_RATE,
                                 CC_PROJECT_ID,
                                 CC_TAX_TASK_ID,
                                 ORG_ID,
                                 REV_CODE_COMBINATION_ID,
                                 DRAFT_INVOICE_NUM,
                                 DRAFT_INVOICE_LINE_NUM,
--                                 OUTPUT_VAT_TAX_ID,
                                 OUTPUT_TAX_CLASSIFICATION_CODE,
                                 OUTPUT_TAX_EXEMPT_FLAG,
                                 OUTPUT_TAX_EXEMPT_REASON_CODE,
                                 OUTPUT_TAX_EXEMPT_NUMBER,
                                 LINE_NUM_REVERSED,
                                 DETAIL_ID_REVERSED,
                                 REVERSED_FLAG,
                                 PROJACCT_CURRENCY_CODE,
                                 PROJACCT_COST_AMOUNT,
                                 PROJACCT_BILL_AMOUNT,
                                 MARKUP_CALC_BASE_CODE,
                                 IND_COMPILED_SET_ID,
                                 RULE_PERCENTAGE,
                                 BILL_RATE,
                                 BILL_MARKUP_PERCENTAGE,
                                 BASE_AMOUNT,
                                 SCHEDULE_LINE_PERCENTAGE,
                                 INVOICED_FLAG,
                                 ORIG_DRAFT_INVOICE_NUM,
                                 ORIG_DRAFT_INVOICE_LINE_NUM,
                                 PROGRAM_APPLICATION_ID,
                                 PROGRAM_ID,
                                 PROGRAM_UPDATE_DATE,
                                 TP_JOB_ID,
                                 PROV_PROJ_BILL_JOB_ID,
                                 PROJECT_TP_CURRENCY_CODE,
                                 PROJECT_TP_RATE_DATE,
                                 PROJECT_TP_RATE_TYPE,
                                 PROJECT_TP_EXCHANGE_RATE,
                                 PROJFUNC_TP_CURRENCY_CODE,
                                 PROJFUNC_TP_RATE_DATE,
                                 PROJFUNC_TP_RATE_TYPE,
                                 PROJFUNC_TP_EXCHANGE_RATE,
                                 PROJECT_TRANSFER_PRICE,
                                 PROJFUNC_TRANSFER_PRICE,
                                 TP_AMT_TYPE_CODE
                       from pa_draft_invoice_details_all
                       where expenditure_item_id in
			       ( select ei.expenditure_item_id    /* Bug#4943324 : Perf Issue : Removed the Task table */
			  	   from
				        pa_expenditure_items_all ei
			          where ei.project_id = p_project_id )
                         and rownum <= l_commit_size;
                   end if;

		   l_NoOfRecordsIns := SQL%ROWCOUNT ;
     pa_debug.debug( ' ->After insert into PA_DRAFT_INV_DETS_AR') ;
	/*Code Changes for Bug No.2984871 start */
		     if l_NoOfRecordsIns > 0 then
	/*Code Changes for Bug No.2984871 end */
                         -- First call the MRC procedure to archive the MC table
                         -- We have a seperate delete statement if the archive option is
                         -- selected because if archive option is selected the the records
                         -- being purged will be those records which are already archived.
                         -- table and
  /* Commented out for MRC migration to SLA
			IF (l_mrc_flag = 'Y') THEN
                          PA_MC_DraftInvoiceDetails(
                                p_purge_batch_id,
                                p_project_id,
                                p_txn_to_date,
                                p_purge_release,
                                p_archive_flag,
                                l_commit_size,
                                x_err_code,
                                x_err_stack,
                                x_err_stage,
                                l_MRC_NoOfRecordsIns);
                        END IF; */

                         /* Each time thru the loop need to make sure that reset the
                          * counter tracking the number of records that deleted from
                          * the mrc table.
                          */
                         IF (l_mrc_flag = 'Y') THEN
                              pa_utils2.MRC_row_count := 0;
                         END IF;

                         x_err_stage := 'Before deleting records from PA_MC_DRAFT_INV_DETAILS_ALL';
                         /*delete from pa_mc_draft_inv_details_all mdi
                          where (mdi.draft_invoice_detail_id) in
                                          ( select mdir.draft_invoice_detail_id
                                              from pa_mc_draft_inv_dets_ar mdir
                                             where mdir.purge_project_id = p_project_id ) ; */

                         /*  Commented the above and added the following for bug 3611190  */

	/* Commented out for MRC migration to SLA		delete from pa_mc_draft_inv_details_all mdi
		         where mdi.set_of_books_id > 0
                           and exists ( select 1 from pa_mc_draft_inv_dets_ar mdir
				         where mdir.purge_project_id = p_project_id
                                           and mdir.set_of_books_id > 0
					   and mdir.draft_invoice_detail_id = mdi.draft_invoice_detail_id);

				 l_MRC_NoOfRecordsDel := SQL%ROWCOUNT; */

			 /*  The new column pa_draft_invoices_all.purge_flag will be updated with 'Y'
			     whenever any of the source project is purged. Since we have to show
			     appropriate message, in the case of Drilldown from Intercompany Invoice
			     to source Expenditure items, will not have a performance hit as we would
			     know upfront that the at least one of the source project has been purged.
                          */

                         update pa_draft_invoices_all di
                            set di.purge_flag = 'Y'
                          where ( di.project_id, di.draft_invoice_num ) in
                                    ( select did.project_id, did.draft_invoice_num
                                        from pa_draft_inv_dets_ar did
                                       where did.cc_project_id = p_project_id
                                    )
                            and rownum < l_commit_size;


                         pa_debug.debug( ' ->Before delete from pa_draft_invoice_details_all ') ;

                         delete from pa_draft_invoice_details_all did
                          where (did.project_id, did.draft_invoice_detail_id) in
                                          ( select did2.project_id, did2.draft_invoice_detail_id
                                              from PA_DRAFT_INV_DETS_AR did2
                                             where did2.purge_project_id = p_project_id
                                          ) ;
                         /* Bug 2984871: Moved the below statement above the pa_debug.debug api call */
			 l_NoOfRecordsDel :=  SQL%ROWCOUNT ;

			 pa_debug.debug( ' ->After delete from pa_draft_invoice_details_all ') ;


                     end if ;
               else

                     l_commit_size := pa_utils2.arpur_mrc_commit_size;
                     l_pmy_commit_size := pa_utils2.arpur_commit_size;

                     /* Each time thru the loop need to make sure that reset the
                      * counter tracking the number of records that deleted from
                      * the mrc table.
                      */
                     IF (l_mrc_flag = 'Y') THEN
                          pa_utils2.MRC_row_count := 0;
                     END IF;

                     -- If the archive option is not selected then the delete will
                     -- be based on the commit size.

                         pa_debug.debug( ' ->Before delete from pa_draft_invoice_details_all ') ;

                     if p_txn_to_date is NOT NULL then

                         /*delete from pa_mc_draft_inv_details_all mdi
                            where (mdi.draft_invoice_detail_id ) in
                                      ( select did.draft_invoice_detail_id
                                          from pa_tasks t,
                                               pa_expenditure_items_all ei,
                                               pa_draft_invoice_details_all did
                                         where ei.expenditure_item_date <= p_txn_to_date
                                           and ei.task_id = t.task_id
                                           and t.project_id = p_project_id
                                           and t.project_id = did.project_id
                                       )
                            and rownum < l_commit_size; */

                         /*  commented the above and added the following for bug 3611190  */

/* Commented out for MRC migration to SLA
                         delete from pa_mc_draft_inv_details_all mdi where
			  mdi.set_of_books_id > 0
			  and exists
			  (select  1 from pa_draft_invoice_details_all did,
					  pa_expenditure_items_all ei
			    where  ei.expenditure_item_id = did.expenditure_item_id
			      and  ei.project_id = p_project_id
			      and  ei.expenditure_item_date <= p_txn_to_date
			      and  did.draft_invoice_detail_id = mdi.draft_invoice_detail_id)
			  and  rownum < l_pmy_commit_size;

                         l_MRC_NoOfRecordsDel := SQL%ROWCOUNT ; */

                         /*  The new column pa_draft_invoices_all.purge_flag will be updated with 'Y'
                             whenever any of the source project is purged. Since we have to show
                             appropriate message, in the case of Drilldown from Intercompany Invoice
                             to source Expenditure items, will not have a performance hit as we would
                             know upfront that the at least one of the source project has been purged.
                          */

                         update pa_draft_invoices_all di
                            set di.purge_flag = 'Y'
                          where ( di.project_id, di.draft_invoice_num ) in
                                    ( select did.project_id, did.draft_invoice_num
                                        from pa_draft_invoice_details_all did
                                       where did.cc_project_id = p_project_id
                                         and did.expenditure_item_id in
                                                  ( select ei.expenditure_item_id
                                                      from pa_tasks t,
                                                           pa_expenditure_items_all ei
                                                     where ei.expenditure_item_date <= p_txn_to_date
                                                       and ei.task_id = t.task_id
                                                       and t.project_id = p_project_id
                                                   )
                                    )
                            and rownum < l_commit_size;


                         --Commenting out for bug#7701114 and taking out of loop
                         /* delete from pa_draft_invoice_details_all did
                          where (did.expenditure_item_id ) in
                                      ( select ei.expenditure_item_id
                                          from pa_tasks t,
                                               pa_expenditure_items_all ei
                                         where ei.expenditure_item_date <= p_txn_to_date
                                           and ei.task_id = t.task_id
                                           and t.project_id = p_project_id
                                       )
                            and did.cc_project_id = p_project_id
                            and rownum < l_commit_size;

                          l_NoOfRecordsDel := SQL%ROWCOUNT ; */

                     else

                         /*delete from pa_mc_draft_inv_details_all mdi
                          where (mdi.draft_invoice_detail_id ) in
                                      ( select did.draft_invoice_detail_id
                                          from pa_tasks t,
                                               pa_expenditure_items_all ei,
                                               pa_draft_invoice_details_all did
                                         where ei.task_id = t.task_id
                                           and t.project_id = p_project_id
                                           and t.project_id = did.project_id
                                       )
                            and rownum < l_commit_size; */

                        /*  commented the above and added the following for bug 3611190  */

    /* Commented out for MRC migration to SLA
                        delete from pa_mc_draft_inv_details_all mdi where
			  mdi.set_of_books_id > 0
			  and exists
			  (select  1 from pa_draft_invoice_details_all did,
					  pa_expenditure_items_all ei
			    where  ei.expenditure_item_id = did.expenditure_item_id
			      and  ei.project_id = p_project_id
			      and  did.draft_invoice_detail_id = mdi.draft_invoice_detail_id)
			  and  rownum < l_pmy_commit_size;

                         l_MRC_NoOfRecordsDel := SQL%ROWCOUNT ; */


                         /*  The new column pa_draft_invoices_all.purge_flag will be updated with 'Y'
                             whenever any of the source project is purged. Since we have to show
                             appropriate message, in the case of Drilldown from Intercompany Invoice
                             to source Expenditure items, will not have a performance hit as we would
                             know upfront that the at least one of the source project has been purged.
                          */

			 update pa_draft_invoices_all di
 			    set di.purge_flag = 'Y'
                          where ( di.project_id, di.draft_invoice_num ) in
				    ( select did.project_id, did.draft_invoice_num
					from pa_draft_invoice_details_all did
                                       where did.cc_project_id = p_project_id
                                    )
                            and rownum < l_commit_size;


                         --Commenting out for bug#7701114 and taking out of loop
                         /*delete from pa_draft_invoice_details_all did
                          where (did.expenditure_item_id ) in
                                      ( select ei.expenditure_item_id   /* Bug#4943324 : Perf Issue : Removed the Task table
                                          from pa_expenditure_items_all ei
                                         where ei.project_id = p_project_id
                                      )
                            and did.cc_project_id = p_project_id
                            and rownum < l_commit_size;

                          l_NoOfRecordsDel := SQL%ROWCOUNT ; */

                     end if;


                         pa_debug.debug( ' ->After delete from pa_draft_invoice_details_all ') ;

               end if ;

	       /* Bug 2984871: Changed sql%rowcount to l_NoOfRecordsDel in the if condition below */
               if NVL(l_NoOfRecordsDel,0) = 0 then
                     -- Once the SqlCount becomes 0, which means that there are
                     -- no more records to be purged then we exit the loop.

                     exit ;

               else
                     -- After "deleting" or "deleting and inserting" a set of records
                     -- the transaction is commited. This also creates a record in the
                     -- Pa_Purge_Project_details which will show the no. of records
                     -- that are purged from each table.

                         pa_debug.debug( ' ->Calling pa_purge.CommitProcess ') ;
                         pa_purge.CommitProcess
                               (p_purge_batch_id             => p_purge_batch_id,
                                p_project_id                 => p_project_id,
                                p_table_name                 => 'PA_DRAFT_INVOICE_DETAILS_ALL',
                                p_NoOfRecordsIns             => l_NoOfRecordsIns,
                                p_NoOfRecordsDel             => l_NoOfRecordsDel,
                                x_err_code                   => x_err_code,
                                x_err_stack                  => x_err_stack,
                                x_err_stage                  => x_err_stage,
                                p_MRC_table_name             => 'PA_MC_DRAFT_INV_DETAILS_ALL',
                                p_MRC_NoOfRecordsIns         => l_MRC_NoOfRecordsIns,
                                p_MRC_NoOfRecordsDel         => l_MRC_NoOfRecordsDel
                                ) ;

                      PA_UTILS2.mrc_row_count := 0;

               end if ;
     END LOOP ;

     x_err_stack    := l_old_err_stack ;

     --Fix for bug#7701114 , creating a separate loop to delete records from pa_draft_invoice_details_all
     LOOP
          IF p_archive_flag <> 'Y' THEN

          l_commit_size := pa_utils2.arpur_mrc_commit_size;

            IF p_txn_to_date is NOT NULL THEN
               delete from pa_draft_invoice_details_all did
               where (did.expenditure_item_id ) in
                          ( select ei.expenditure_item_id
                            from pa_tasks t,
                                 pa_expenditure_items_all ei
                           where ei.expenditure_item_date <= p_txn_to_date
                           and ei.task_id = t.task_id
                           and t.project_id = p_project_id)
               and did.cc_project_id = p_project_id
               and rownum < l_commit_size;

               l_NoOfRecordsDel := SQL%ROWCOUNT ;

            ELSE

               delete from pa_draft_invoice_details_all did
               where (did.expenditure_item_id ) in
                          ( select ei.expenditure_item_id
                            from --pa_tasks t,                     /* Bug#4943324 : Perf Issue : Removed the Task table */
                                 pa_expenditure_items_all ei
                            where -- ei.task_id = t.task_id and
                                  ei.project_id = p_project_id)
               and did.cc_project_id = p_project_id
               and rownum < l_commit_size;

               l_NoOfRecordsDel := SQL%ROWCOUNT ;

          END IF;

        END IF ;

        IF NVL(l_NoOfRecordsDel,0) = 0 THEN
             exit ;
        ELSE
           pa_purge.CommitProcess
              (p_purge_batch_id             => p_purge_batch_id,
               p_project_id                 => p_project_id,
               p_table_name                 => 'PA_DRAFT_INVOICE_DETAILS_ALL',
               p_NoOfRecordsIns             => l_NoOfRecordsIns,
               p_NoOfRecordsDel             => l_NoOfRecordsDel,
               x_err_code                   => x_err_code,
               x_err_stack                  => x_err_stack,
               x_err_stage                  => x_err_stage) ;

        END IF ;
     END LOOP ;

 EXCEPTION
  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error then
       RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
    pa_debug.debug('Error Procedure Name  := PA_PURGE_ICIP.PA_DraftInvDetails' );
    pa_debug.debug('Error stage is '||x_err_stage );
    pa_debug.debug('Error stack is '||x_err_stack );
    pa_debug.debug(SQLERRM);

   /* ATG Changes */
     x_err_stack    := l_old_err_stack ;

    PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM ;

    RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

 end PA_DraftInvDetails ;


-- Start of comments
-- API name         : PA_MC_DraftInvoiceDetails
-- Type             : Private
-- Pre-reqs         : None
-- Function         : Archive and Purge data for table pa_mc_draft_inv_details_all
-- Parameters       : See common list above
-- End of comments

 procedure PA_MC_DraftInvoiceDetails(
                             p_purge_batch_id   IN NUMBER,
                             p_project_id       IN NUMBER,
                             p_txn_to_date      IN DATE,
                             p_purge_release    IN VARCHAR2,
                             p_archive_flag     IN VARCHAR2,
                             p_commit_size      IN NUMBER,
                             x_err_code         IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                             x_err_stack        IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             x_err_stage        IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             x_MRC_NoOfRecordsIns  OUT NOCOPY NUMBER ) --File.Sql.39 bug 4440895
 IS

     l_old_err_stage         VARCHAR2(2000);
     l_old_err_stack         VARCHAR2(2000);

 begin

     l_old_err_stack := x_err_stack;

     x_err_stack := x_err_stack || ' ->Entering PA_MC_DraftInvoiceDetails ';

     pa_debug.debug(x_err_stack);

     pa_debug.debug( ' ->Before insert into PA_MC_DRAFT_INV_DETS_AR') ;

      /* Commented out for MRC migration to SLA   insert into PA_MC_DRAFT_INV_DETS_AR
                        (
			 PURGE_BATCH_ID,
			 PURGE_RELEASE,
			 PURGE_PROJECT_ID,
			 SET_OF_BOOKS_ID,
			 DRAFT_INVOICE_DETAIL_ID,
			 PROJECT_ID,
			 INVOICED_FLAG,
			 ACCT_CURRENCY_CODE,
			 BILL_AMOUNT,
			 REQUEST_ID,
			 ACCT_RATE_TYPE,
			 ACCT_RATE_DATE,
			 ACCT_EXCHANGE_RATE,
			 PROGRAM_APPLICATION_ID,
			 PROGRAM_ID,
			 PROGRAM_UPDATE_DATE
                        )
		 select
			 p_purge_batch_id,
			 p_purge_release,
			 p_project_id,
			 mc.SET_OF_BOOKS_ID,
			 mc.DRAFT_INVOICE_DETAIL_ID,
			 mc.PROJECT_ID,
			 mc.INVOICED_FLAG,
			 mc.ACCT_CURRENCY_CODE,
			 mc.BILL_AMOUNT,
			 mc.REQUEST_ID,
			 mc.ACCT_RATE_TYPE,
			 mc.ACCT_RATE_DATE,
			 mc.ACCT_EXCHANGE_RATE,
			 mc.PROGRAM_APPLICATION_ID,
			 mc.PROGRAM_ID,
			 mc.PROGRAM_UPDATE_DATE
                   from pa_mc_draft_inv_details_all mc,
                        pa_draft_inv_dets_ar ar
                  where ar.purge_project_id = p_project_id
                    and mc.draft_invoice_detail_id = ar.draft_invoice_detail_id; */

     x_MRC_NoOfRecordsIns := nvl(SQL%ROWCOUNT,0) ;

     pa_debug.debug( ' ->After insert into PA_MC_DRAFT_INV_DETS_AR') ;
     x_err_stack    := l_old_err_stack ;

 EXCEPTION
  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error then
       RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
    pa_debug.debug('Error Procedure Name  := PA_PURGE_ICIP.PA_MC_DraftInvoiceDetails' );
    pa_debug.debug('Error stage is '||x_err_stage );
    pa_debug.debug('Error stack is '||x_err_stack );
    pa_debug.debug(SQLERRM);
    PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM ;

   /* ATG Changes */
     x_err_stack    := l_old_err_stack ;
     x_MRC_NoOfRecordsIns := null;

    RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

 end PA_MC_DraftInvoiceDetails;

END pa_purge_icip;

/
