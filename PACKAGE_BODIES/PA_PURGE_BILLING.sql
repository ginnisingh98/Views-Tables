--------------------------------------------------------
--  DDL for Package Body PA_PURGE_BILLING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PURGE_BILLING" as
/*$Header: PAXBIPRB.pls 120.5 2007/02/07 10:46:49 rgandhi ship $*/

    l_commit_size     NUMBER ;

-- private procedures
--
-- The list of parameters is common for all private procedures in the package
------------------------------------------------------------------------------------------
-- Parameters         p_batch_id			IN     NUMBER
--                              The purge batch id for which rows have
--                              to be purged/archived.
--		      p_project_Id			IN     NUMBER,
--                              The project id for which records have
--                              to be purged/archived.
--		      p_Purge_Release                   IN     VARCHAR2,
--                              Oracle Projects release (10.7 , 11.0)
--		      p_Archive_Flag 	 	        IN     VARCHAR2,
--                              Archive table data
--		      p_Txn_To_Date			IN     DATE,
--                              Date on or before which all transactions are to be purged
--                              (Will be used by Costing only)
--		      p_Commit_Size			IN     NUMBER,
--                              The commit size
--		      X_Err_Stack			IN OUT VARCHAR2,
--                              Error stack
--		      X_Err_Stage		        IN OUT VARCHAR2,
--                              Stage in the procedure where error occurred
--		      X_Err_Code		        IN OUT NUMBER
--                              Error code returned from the procedure
--                              = 0 SUCCESS
--                              > 0 Application error
--                              < 0 Oracle error
-------------------------------------------------------------------------------------------
-- Start of comments
-- API name         : PA_MC_CUSTREVDISTLINES
-- Type             : Private
-- Pre-reqs         : None
-- Function         : Archive and Purge data for table pa_mc_cust_rdl_AR
-- Parameters       : See common list above
-- End of comments
 procedure PA_MC_CUSTREVDISTLINES
                            ( p_purge_batch_id         IN NUMBER,
                              p_project_id             IN NUMBER,
                              p_txn_to_date            IN DATE,
                              p_purge_release          IN VARCHAR2,
                              p_mcnoofrecordsins      OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                              x_err_code           IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                              x_err_stack          IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              x_err_stage          IN OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                            )    is

     l_old_err_stage         VARCHAR2(2000);
     l_old_err_stack         VARCHAR2(2000);


 begin


     l_old_err_stack := x_err_stack;

     x_err_stack := x_err_stack || ' ->Entering PA_MC_CUSTREVDISTLINES ';

     pa_debug.debug(x_err_stack);

     pa_debug.debug( ' ->Before insert into PA_MC_Rev_Distribution_Lines_AR') ;
/* Commented out for MRC migration to SLA
         insert into Pa_MC_Cust_Rdl_ar
         (
	        PURGE_BATCH_ID,
                PURGE_RELEASE,
                PURGE_PROJECT_ID,
                REQUEST_ID,
                PROGRAM_APPLICATION_ID,
                PROGRAM_ID,
                PROGRAM_UPDATE_DATE,
                BATCH_NAME,
                RAW_COST,
                PROJECT_ID,
                DRAFT_REVENUE_NUM,
                DRAFT_REVENUE_ITEM_LINE_NUM,
                DRAFT_INVOICE_NUM,
                DRAFT_INVOICE_ITEM_LINE_NUM,
                CURRENCY_CODE,
                EXCHANGE_RATE,
                CONVERSION_DATE,
                SET_OF_BOOKS_ID,
                EXPENDITURE_ITEM_ID,
                LINE_NUM,
                AMOUNT,
                BILL_AMOUNT,
                PRC_ASSIGNMENT_ID,
		RATE_TYPE,
		PROJFUNC_INV_RATE_TYPE,
		PROJFUNC_INV_RATE_DATE,
		PROJFUNC_INV_EXCHANGE_RATE
         )
         select
		p_purge_batch_id,
                p_purge_release,
                p_project_id,
                mc.REQUEST_ID,
                mc.PROGRAM_APPLICATION_ID,
                mc.PROGRAM_ID,
                mc.PROGRAM_UPDATE_DATE,
                mc.BATCH_NAME,
                mc.RAW_COST,
                mc.PROJECT_ID,
                mc.DRAFT_REVENUE_NUM,
                mc.DRAFT_REVENUE_ITEM_LINE_NUM,
                mc.DRAFT_INVOICE_NUM,
                mc.DRAFT_INVOICE_ITEM_LINE_NUM,
                mc.CURRENCY_CODE,
                mc.EXCHANGE_RATE,
                mc.CONVERSION_DATE,
                mc.SET_OF_BOOKS_ID,
                mc.EXPENDITURE_ITEM_ID,
                mc.LINE_NUM,
                mc.AMOUNT,
                mc.BILL_AMOUNT,
                mc.PRC_ASSIGNMENT_ID,
		mc.RATE_TYPE,
		mc.PROJFUNC_INV_RATE_TYPE,
		mc.PROJFUNC_INV_RATE_DATE,
		mc.PROJFUNC_INV_EXCHANGE_RATE
         from Pa_Mc_Cust_Rdl_All mc,
              PA_CUST_RDL_AR ar
         where ar.purge_project_id = p_project_id
         and   mc.expenditure_item_id = ar.expenditure_item_id
         and   mc.line_num = ar.line_num;

*/
     p_mcnoofrecordsins :=  SQL%ROWCOUNT ;

     pa_debug.debug( ' ->After insert into PA_Revenue_Distribution_Lines_AR') ;
     x_err_stack    := l_old_err_stack ;

 EXCEPTION
  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error then
       RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
    pa_debug.debug('Error Procedure Name  := PA_PURGE_BILLING.PA_MC_CUSTREVDISTLINES' );
    pa_debug.debug('Error stage is '||x_err_stage );
    pa_debug.debug('Error stack is '||x_err_stack );
    pa_debug.debug(SQLERRM);
    PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM ;

    /* ATG NOCOPY changes */
    p_mcnoofrecordsins := null;
    x_err_stack    := l_old_err_stack ;

    RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

 end PA_MC_CUSTREVDISTLINES ;

-- Start of comments
-- API name         : PA_CUSTREVDISTLINES
-- Type             : Private
-- Pre-reqs         : None
-- Function         : Archive and Purge data for table PA_CUST_REV_DIST_LINES_ALL
-- Parameters       : See common list above
-- End of comments
 procedure PA_CUSTREVDISTLINES
                            ( p_purge_batch_id         IN NUMBER,
                              p_project_id             IN NUMBER,
                              p_txn_to_date            IN DATE,
                              p_purge_release          IN VARCHAR2,
                              p_archive_flag           IN VARCHAR2,
                              p_commit_size            IN NUMBER,
                              x_err_code           IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                              x_err_stack          IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              x_err_stage          IN OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                            )    is

     l_old_err_stage         VARCHAR2(2000);
     l_old_err_stack         VARCHAR2(2000);
     l_NoOfRecordsIns        NUMBER;
     l_NoOfRecordsDel        NUMBER;
     l_MC_NoOfRecordsIns     NUMBER := NULL;
     l_MC_NoOfRecordsDel     NUMBER := NULL;

     l_crdl_rowid_tab        PA_PLSQL_DATATYPES.RowIDTabTyp;
     l_crdl_rowid_tab_empty  PA_PLSQL_DATATYPES.RowIDTabTyp;
     l_fetch_complete        BOOLEAN := FALSE;
     l_crdl_ind              NUMBER;

     cursor c_crdl_records is
     select crdl.rowid from pa_cust_rev_dist_lines_all crdl
     where  crdl.project_id = p_project_id;

 begin


     l_old_err_stack := x_err_stack;

     x_err_stack := x_err_stack || ' ->Entering PA_CUSTREVDISTLINES ';

     pa_debug.debug(x_err_stack);

     OPEN c_crdl_records;

     if p_archive_flag = 'Y' then
        l_commit_size := pa_utils2.arpur_mrc_commit_size / 2 ;
     else
        l_commit_size := pa_utils2.arpur_mrc_commit_size  ;
     end if;

     LOOP

         l_NoOfRecordsIns := 0;
         l_NoOfRecordsDel := 0;
         l_crdl_rowid_tab := l_crdl_rowid_tab_empty;

         FETCH c_crdl_records BULK COLLECT INTO l_crdl_rowid_tab LIMIT l_commit_size;
         IF c_crdl_records%NOTFOUND Then
            CLOSE c_crdl_records;
            l_fetch_complete := TRUE;
         END IF;
               /*  if p_archive_flag = 'Y' then  */
                     -- If archive option is selected then the records are
                     -- inserted into the archive tables
                     -- before being purged. The where condition is such that
                     -- only the it inserts half the no. of records specified
                     -- in the commit size.

                     /*  l_commit_size := pa_utils2.arpur_mrc_commit_size / 2 ;  */

     pa_debug.debug( ' ->Before insert into PA_Revenue_Distribution_Lines_AR') ;
         IF l_crdl_rowid_tab.LAST is not null THEN
           IF p_archive_flag = 'Y' THEN
            FORALL l_crdl_ind in l_crdl_rowid_tab.FIRST .. l_crdl_rowid_tab.LAST
                     insert into PA_CUST_RDL_AR
                          (
			       PURGE_BATCH_ID,
                               PURGE_RELEASE,
                               PURGE_PROJECT_ID,
                               ORG_ID,
                               EXPENDITURE_ITEM_ID,
                               LINE_NUM,
                               CREATION_DATE,
                               CREATED_BY,
                               PROJECT_ID,
                               DRAFT_REVENUE_NUM,
                               DRAFT_REVENUE_ITEM_LINE_NUM,
                               AMOUNT,
                               CODE_COMBINATION_ID,
                               BILL_AMOUNT,
                               FUNCTION_CODE,
                               FUNCTION_TRANSACTION_CODE,
                               REQUEST_ID,
                               PROGRAM_APPLICATION_ID,
                               PROGRAM_ID,
                               PROGRAM_UPDATE_DATE,
                               BATCH_NAME,
                               ADDITIONAL_REVENUE_FLAG,
                               INVOICE_ELIGIBLE_FLAG,
                               DRAFT_INVOICE_NUM,
                               DRAFT_INVOICE_ITEM_LINE_NUM,
                               REVERSED_FLAG,
                               LINE_NUM_REVERSED,
                               REV_IND_COMPILED_SET_ID,
                               INV_IND_COMPILED_SET_ID,
                               RAW_COST,
				OUTPUT_VAT_TAX_ID,
                                OUTPUT_TAX_CLASSIFICATION_CODE,
				OUTPUT_TAX_EXEMPT_FLAG,
				OUTPUT_TAX_EXEMPT_REASON_CODE,
				OUTPUT_TAX_EXEMPT_NUMBER,
				PRC_GENERATED_FLAG,
				BILL_TRANS_CURRENCY_CODE,
				BILL_TRANS_AMOUNT,
				BILL_TRANS_BILL_AMOUNT,
				BILL_RATE,
				REVPROC_CURRENCY_CODE,
				REVPROC_RATE_TYPE,
				REVPROC_RATE_DATE,
				REVPROC_EXCHANGE_RATE,
				INVPROC_CURRENCY_CODE,
				INVPROC_RATE_TYPE,
				INVPROC_RATE_DATE,
				INVPROC_EXCHANGE_RATE,
				PROJECT_CURRENCY_CODE,
				PROJECT_REVENUE_AMOUNT,
				PROJECT_REV_RATE_TYPE,
				PROJECT_REV_RATE_DATE,
				PROJECT_REV_EXCHANGE_RATE,
				PROJECT_BILL_AMOUNT,
				PROJECT_INV_RATE_TYPE,
				PROJECT_INV_RATE_DATE,
				PROJECT_INV_EXCHANGE_RATE,
				PROJFUNC_CURRENCY_CODE,
				PROJFUNC_REVENUE_AMOUNT,
				PROJFUNC_REV_RATE_TYPE,
				PROJFUNC_REV_RATE_DATE,
				PROJFUNC_REV_EXCHANGE_RATE,
				PROJFUNC_BILL_AMOUNT,
				PROJFUNC_INV_RATE_TYPE,
				PROJFUNC_INV_RATE_DATE,
				PROJFUNC_INV_EXCHANGE_RATE,
				FUNDING_CURRENCY_CODE,
				FUNDING_REVENUE_AMOUNT,
				FUNDING_REV_RATE_TYPE,
				FUNDING_REV_RATE_DATE,
				FUNDING_REV_EXCHANGE_RATE,
				FUNDING_BILL_AMOUNT,
				FUNDING_INV_RATE_TYPE,
				FUNDING_INV_RATE_DATE,
				FUNDING_INV_EXCHANGE_RATE,
				LABOR_MULTIPLIER,
				DISCOUNT_PERCENTAGE,
				AMOUNT_CALCULATION_CODE,
				BILL_MARKUP_PERCENTAGE,
				RATE_SOURCE_ID,
				INV_GEN_REJECTION_CODE,
				RETN_DRAFT_INVOICE_NUM,
				RETN_DRAFT_INVOICE_LINE_NUM,
				RETAINED_AMOUNT,
				RETENTION_RULE_ID,
                                RATE_DISC_REASON_CODE
                           )
                       select
			       p_purge_batch_id,
                               p_purge_release,
                               p_project_id,
                               ORG_ID,
                               EXPENDITURE_ITEM_ID,
                               LINE_NUM,
                               CREATION_DATE,
                               CREATED_BY,
                               PROJECT_ID,
                               DRAFT_REVENUE_NUM,
                               DRAFT_REVENUE_ITEM_LINE_NUM,
                               AMOUNT,
                               CODE_COMBINATION_ID,
                               BILL_AMOUNT,
                               FUNCTION_CODE,
                               FUNCTION_TRANSACTION_CODE,
                               REQUEST_ID,
                               PROGRAM_APPLICATION_ID,
                               PROGRAM_ID,
                               PROGRAM_UPDATE_DATE,
                               BATCH_NAME,
                               ADDITIONAL_REVENUE_FLAG,
                               INVOICE_ELIGIBLE_FLAG,
                               DRAFT_INVOICE_NUM,
                               DRAFT_INVOICE_ITEM_LINE_NUM,
                               REVERSED_FLAG,
                               LINE_NUM_REVERSED,
                               REV_IND_COMPILED_SET_ID,
                               INV_IND_COMPILED_SET_ID,
                               RAW_COST,
				OUTPUT_VAT_TAX_ID,
                                OUTPUT_TAX_CLASSIFICATION_CODE,
				OUTPUT_TAX_EXEMPT_FLAG,
				OUTPUT_TAX_EXEMPT_REASON_CODE,
				OUTPUT_TAX_EXEMPT_NUMBER,
				PRC_GENERATED_FLAG,
				BILL_TRANS_CURRENCY_CODE,
				BILL_TRANS_AMOUNT,
				BILL_TRANS_BILL_AMOUNT,
				BILL_RATE,
				REVPROC_CURRENCY_CODE,
				REVPROC_RATE_TYPE,
				REVPROC_RATE_DATE,
				REVPROC_EXCHANGE_RATE,
				INVPROC_CURRENCY_CODE,
				INVPROC_RATE_TYPE,
				INVPROC_RATE_DATE,
				INVPROC_EXCHANGE_RATE,
				PROJECT_CURRENCY_CODE,
				PROJECT_REVENUE_AMOUNT,
				PROJECT_REV_RATE_TYPE,
				PROJECT_REV_RATE_DATE,
				PROJECT_REV_EXCHANGE_RATE,
				PROJECT_BILL_AMOUNT,
				PROJECT_INV_RATE_TYPE,
				PROJECT_INV_RATE_DATE,
				PROJECT_INV_EXCHANGE_RATE,
				PROJFUNC_CURRENCY_CODE,
				PROJFUNC_REVENUE_AMOUNT,
				PROJFUNC_REV_RATE_TYPE,
				PROJFUNC_REV_RATE_DATE,
				PROJFUNC_REV_EXCHANGE_RATE,
				PROJFUNC_BILL_AMOUNT,
				PROJFUNC_INV_RATE_TYPE,
				PROJFUNC_INV_RATE_DATE,
				PROJFUNC_INV_EXCHANGE_RATE,
				FUNDING_CURRENCY_CODE,
				FUNDING_REVENUE_AMOUNT,
				FUNDING_REV_RATE_TYPE,
				FUNDING_REV_RATE_DATE,
				FUNDING_REV_EXCHANGE_RATE,
				FUNDING_BILL_AMOUNT,
				FUNDING_INV_RATE_TYPE,
				FUNDING_INV_RATE_DATE,
				FUNDING_INV_EXCHANGE_RATE,
				LABOR_MULTIPLIER,
				DISCOUNT_PERCENTAGE,
				AMOUNT_CALCULATION_CODE,
				BILL_MARKUP_PERCENTAGE,
				RATE_SOURCE_ID,
				INV_GEN_REJECTION_CODE,
				RETN_DRAFT_INVOICE_NUM,
				RETN_DRAFT_INVOICE_LINE_NUM,
				RETAINED_AMOUNT,
				RETENTION_RULE_ID,
                                RATE_DISC_REASON_CODE
                       from pa_cust_rev_dist_lines_all crdl
                       where crdl.rowid = l_crdl_rowid_tab(l_crdl_ind);
                       /*where (
			      project_id = p_project_id
                              and rownum <= l_commit_size
                             ) ;*/

                     l_NoOfRecordsIns :=  SQL%ROWCOUNT ;
                 end if;


     pa_debug.debug( ' ->After insert into PA_Revenue_Distribution_Lines_AR') ;

                     if l_NoOfRecordsIns > 0 then
                         -- First call the MRC procedure to archive the MC table
                         -- We have a seperate delete statement if the archive option is
                         -- selected because if archive option is selected the the records
                         -- being purged will be those records which are already archived.
                         -- table and

                        PA_MC_CUSTREVDISTLINES
                           (    p_purge_batch_id             => p_purge_batch_id,
                                p_project_id                 => p_project_id,
                                p_txn_to_date                => p_txn_to_date,
                                p_purge_release              => p_purge_release,
                                p_mcnoofrecordsins           => l_MC_NoOfRecordsIns,
                                x_err_code                   => x_err_code,
                                x_err_stack                  => x_err_stack,
                                x_err_stage                  => x_err_stage
                            ) ;

                    end if;
                         pa_debug.debug( ' ->Before delete from pa_cust_rev_dist_lines_all ') ;
/* commented and modified as below for performance reasons. Archive Purge 11.5
                         delete from pa_cust_rev_dist_lines_all crdl
                          where (crdl.rowid) in
                                          ( select crdl1.rowid
                                              from pa_cust_rev_dist_lines_all crdl1,
                                                   PA_CUST_RDL_AR crdl2
                                     where crdl2.expenditure_item_id = crdl1.expenditure_item_id
                                               and crdl2.line_num = crdl1.line_num
                                               and crdl2.purge_project_id = p_project_id
                                          ) ;
*/

/*                         delete from pa_cust_rev_dist_lines_all crdl
                          where (crdl.expenditure_item_id, crdl.line_num) in
                                          ( select crdl2.expenditure_item_id, crdl2.line_num
                                              from PA_CUST_RDL_AR crdl2
                                             where crdl2.purge_project_id = p_project_id
                                          ) ;


			 l_NoOfRecordsDel :=  SQL%ROWCOUNT ;
                         l_MC_NoOfRecordsDel  := PA_UTILS2.mrc_row_count;

			 pa_debug.debug( ' ->After delete from pa_cust_rev_dist_lines_all ') ;


                     end if ;
               else

                     l_commit_size := pa_utils2.arpur_mrc_commit_size; */

                     -- If the archive option is not selected then the delete will
                     -- be based on the commit size.


                         pa_debug.debug( ' ->Before delete from pa_cust_rev_dist_lines_all ') ;
/* commented and modified as below for performance reasons. Archive Purge 11.5
                         delete from pa_cust_rev_dist_lines_all crdl
                          where (crdl.rowid) in
                                          ( select crdl1.rowid
                                              from pa_cust_rev_dist_lines_all crdl1
                                             where crdl1.project_id = p_project_id
					       and rownum <= l_commit_size
                                          ) ;
*/
/*                        delete from pa_cust_rev_dist_lines_all crdl
                          where crdl.project_id = p_project_id
		            and rownum <= l_commit_size; */
                FORALL l_crdl_ind IN l_crdl_rowid_tab.FIRST ..l_crdl_rowid_tab.LAST
                       DELETE FROM pa_cust_rev_dist_lines_all crdl
                       WHERE  crdl.rowid = l_crdl_rowid_tab(l_crdl_ind);

		  /*Code Changes for Bug No.2984871 start */
                    l_NoOfRecordsDel := SQL%ROWCOUNT ;
                    l_MC_NoOfRecordsDel  := PA_UTILS2.mrc_row_count;
		  /*Code Changes for Bug No.2984871 end */

			 pa_debug.debug( ' ->After delete from pa_cust_rev_dist_lines_all ') ;
               /*  end if ;  */

/*              if SQL%ROWCOUNT = 0 then
                     -- Once the SqlCount becomes 0, which means that there are
                     -- no more records to be purged then we exit the loop.

                     exit ;

              else */
                     -- After "deleting" or "deleting and inserting" a set of records
                     -- the transaction is commited. This also creates a record in the
                     -- Pa_Purge_Project_details which will show the no. of records
                     -- that are purged from each table.

                         pa_debug.debug( ' ->Calling pa_purge.CommitProcess ') ;

                    IF l_NoOfRecordsDel > 0 Then
                      pa_purge.CommitProcess
                          (p_purge_batch_id             => p_purge_batch_id,
                           p_project_id                 => p_project_id,
                           p_table_name                 => 'PA_CUST_REV_DIST_LINES_ALL',
                           p_NoOfRecordsIns             => l_NoOfRecordsIns,
                           p_NoOfRecordsDel             => l_NoOfRecordsDel,
                           x_err_code                   => x_err_code,
                           x_err_stack                  => x_err_stack,
                           x_err_stage                  => x_err_stage,
                           p_MRC_table_name             => 'PA_MC_CUST_RDL_ALL',
                           p_MRC_NoOfRecordsIns         => l_MC_NoOfRecordsIns,
                           p_MRC_NoOfRecordsDel         => l_MC_NoOfRecordsDel
                          ) ;

                      PA_UTILS2.mrc_row_count := 0;
                   END IF;
            end if ;
            IF ( l_fetch_complete) THEN
               exit;
            END IF;
     END LOOP ;

     x_err_stack    := l_old_err_stack ;

 EXCEPTION
  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error then
       RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
    pa_debug.debug('Error Procedure Name  := PA_PURGE_BILLING.PA_CUSTREVDISTLINES' );
    pa_debug.debug('Error stage is '||x_err_stage );
    pa_debug.debug('Error stack is '||x_err_stack );
    pa_debug.debug(SQLERRM);
    PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM ;

    /* ATG NOCOPY changes */
    x_err_stack    := l_old_err_stack ;


    RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

 end PA_CUSTREVDISTLINES ;

-- Start of comments
-- API name         : PA_MC_EventRevDistLines
-- Type             : Private
-- Pre-reqs         : None
-- Function         : Archive and Purge data for table Pa_MC_Cust_Event_Rdl_ar
-- Parameters       : See common list above
-- End of comments
 procedure PA_MC_EventRevDistLines
                            ( p_purge_batch_id         IN NUMBER,
                              p_project_id             IN NUMBER,
                              p_txn_to_date            IN DATE,
                              p_purge_release          IN VARCHAR2,
                              p_mcnoofrecordsins      OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                              x_err_code           IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                              x_err_stack          IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              x_err_stage          IN OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                            )    is

     l_old_err_stage         VARCHAR2(2000);
     l_old_err_stack         VARCHAR2(2000);

 begin

     l_old_err_stack := x_err_stack;

     x_err_stack := x_err_stack || ' ->Entering PA_MC_EventRevDistLines ';

     pa_debug.debug(x_err_stack);

     pa_debug.debug( ' ->Before insert into Pa_MC_Cust_Event_Rdl_AR') ;

/* Commented out for MRC migration to SLA
         insert into Pa_MC_Cust_Event_Rdl_AR
         (
              Purge_Batch_Id,
              Purge_Release,
              Purge_Project_Id,
              Draft_Invoice_Item_Line_Num,
              Currency_Code,
              Exchange_Rate,
              Conversion_Date,
              Set_Of_Books_Id,
              Project_Id,
              Task_Id,
              Event_Num,
              Line_Num,
              Amount,
              Request_Id,
              Program_Application_Id,
              Program_Id,
              Program_Update_Date,
              Batch_Name,
              Draft_Revenue_Num,
              Draft_Revenue_Item_Line_Num,
              Draft_Invoice_Num,
	      Prc_Assignment_Id,
	      Rate_Type
          )
          select
	      p_purge_batch_id,
              p_purge_release,
              p_project_id,
              mc.Draft_Invoice_Item_Line_Num,
              mc.Currency_Code,
              mc.Exchange_Rate,
              mc.Conversion_Date,
              mc.Set_Of_Books_Id,
              mc.Project_Id,
              mc.Task_Id,
              mc.Event_Num,
              mc.Line_Num,
              mc.Amount,
              mc.Request_Id,
              mc.Program_Application_Id,
              mc.Program_Id,
              mc.Program_Update_Date,
              mc.Batch_Name,
              mc.Draft_Revenue_Num,
              mc.Draft_Revenue_Item_Line_Num,
              mc.Draft_Invoice_Num,
	      mc.Prc_Assignment_Id,
	      mc.Rate_Type
         from   pa_mc_cust_event_rdl_all mc,
                PA_Cust_Event_RDL_AR ar
         where ar.Purge_Project_Id = p_project_id
         and   mc.project_id = ar.Purge_Project_Id
         and   mc.event_num = ar.event_num
         and   nvl(mc.task_id,-99) = nvl(ar.task_id,-99)
         and   mc.line_num = ar.line_num;

*/
     p_mcnoofrecordsins :=  SQL%ROWCOUNT ;

     pa_debug.debug( ' ->After insert into Pa_MC_Cust_Event_Rdl_AR') ;
     x_err_stack    := l_old_err_stack ;

 EXCEPTION
  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error then
       RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
    pa_debug.debug('Error Procedure Name  := PA_PURGE_BILLING.PA_MC_EventRevDistLines');
    pa_debug.debug('Error stage is '||x_err_stage );
    pa_debug.debug('Error stack is '||x_err_stack );
    pa_debug.debug(SQLERRM);
    PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM;

    /* ATG Changes */
    p_mcnoofrecordsins  :=  null;
    x_err_stack    := l_old_err_stack ;

    RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

 end PA_MC_EventRevDistLines ;

-- Start of comments
-- API name         : PA_EventRevDistLines
-- Type             : Private
-- Pre-reqs         : None
-- Function         : Archive and Purge data for table PA_CUST_EVENT_RDL_ALL
-- Parameters       : See common list above
-- End of comments
 procedure PA_EventRevDistLines
                            ( p_purge_batch_id         IN NUMBER,
                              p_project_id             IN NUMBER,
                              p_txn_to_date            IN DATE,
                              p_purge_release          IN VARCHAR2,
                              p_archive_flag           IN VARCHAR2,
                              p_commit_size            IN NUMBER,
                              x_err_code           IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                              x_err_stack          IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              x_err_stage          IN OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                            )    is

     l_old_err_stage         VARCHAR2(2000);
     l_old_err_stack         VARCHAR2(2000);
     l_NoOfRecordsIns        NUMBER;
     l_NoOfRecordsDel        NUMBER;
     l_MC_NoOfRecordsIns     NUMBER := NULL;
     l_MC_NoOfRecordsDel     NUMBER := NULL;
     l_erdl_rowid_tab        PA_PLSQL_DATATYPES.RowIDTabTyp;
     l_erdl_rowid_tab_empty  PA_PLSQL_DATATYPES.RowIDTabTyp;
     l_fetch_complete        BOOLEAN := FALSE;
     l_erdl_ind              NUMBER;

     cursor c_erdl_records is
     select erdl.rowid from pa_cust_event_rdl_all erdl
     where erdl.project_id = p_project_id;

 begin

     l_old_err_stack := x_err_stack;

     x_err_stack := x_err_stack || ' Entering PA_EventRevDistLines ' ;

     pa_debug.debug(x_err_stack);
     IF  p_archive_flag = 'Y' THEN
         l_commit_size := pa_utils2.arpur_mrc_commit_size / 2 ;
     ELSE
         l_commit_size := pa_utils2.arpur_mrc_commit_size  ;
     END IF;

     OPEN c_erdl_records;


     LOOP
          l_NoOfRecordsIns := 0;
          l_NoOfRecordsDel := 0;
          l_erdl_rowid_tab := l_erdl_rowid_tab_empty;
          FETCH c_erdl_records BULK COLLECT INTO l_erdl_rowid_tab LIMIT l_commit_size;

	     IF  c_erdl_records%NOTFOUND THEN
		 CLOSE c_erdl_records;
		 l_fetch_complete := TRUE;
	     END IF;
             IF l_erdl_rowid_tab.LAST is not null Then
               if p_archive_flag = 'Y' then
                     -- If archive option is selected then the records are
                     -- inserted into the archived into the archive tables
                     -- before being purged. The where condition is such that
                     -- only the it inserts half the no. of records specified
                     -- in the commit size.

                     /*  l_commit_size := pa_utils2.arpur_mrc_commit_size / 2 ;  */

     pa_debug.debug( ' ->Before insert into PA_Cust_Event_RDL_AR') ;
                     FORALL l_erdl_ind IN l_erdl_rowid_tab.FIRST .. l_erdl_rowid_tab.LAST
                     insert into PA_Cust_Event_RDL_AR
                          (
		               PURGE_BATCH_ID,
                               PURGE_RELEASE,
                               PURGE_PROJECT_ID,
                               TASK_ID,
                               EVENT_NUM,
                               LINE_NUM,
                               AMOUNT,
                               CREATION_DATE,
                               CREATED_BY,
                               PROJECT_ID,
                               DRAFT_REVENUE_NUM,
                               DRAFT_REVENUE_ITEM_LINE_NUM,
                               CODE_COMBINATION_ID,
                               REQUEST_ID,
                               PROGRAM_APPLICATION_ID,
                               PROGRAM_ID,
                               PROGRAM_UPDATE_DATE,
                               DRAFT_INVOICE_NUM,
                               DRAFT_INVOICE_ITEM_LINE_NUM,
                               BATCH_NAME,
                               LINE_NUM_REVERSED,
                               REVERSED_FLAG,
                               ORG_ID,
				OUTPUT_VAT_TAX_ID,
                                OUTPUT_TAX_CLASSIFICATION_CODE,
				OUTPUT_TAX_EXEMPT_FLAG,
				OUTPUT_TAX_EXEMPT_REASON_CODE,
				OUTPUT_TAX_EXEMPT_NUMBER,
				PRC_GENERATED_FLAG,
				BILL_TRANS_CURRENCY_CODE,
				BILL_TRANS_AMOUNT,
				REVPROC_CURRENCY_CODE,
				REVPROC_RATE_TYPE,
				REVPROC_RATE_DATE,
				REVPROC_EXCHANGE_RATE,
				INVPROC_CURRENCY_CODE,
				INVPROC_RATE_TYPE,
				INVPROC_RATE_DATE,
				INVPROC_EXCHANGE_RATE,
				PROJECT_CURRENCY_CODE,
				PROJECT_REVENUE_AMOUNT,
				PROJECT_REV_RATE_TYPE,
				PROJECT_REV_RATE_DATE,
				PROJECT_REV_EXCHANGE_RATE,
				PROJECT_BILL_AMOUNT,
				PROJECT_INV_RATE_TYPE,
				PROJECT_INV_RATE_DATE,
				PROJECT_INV_EXCHANGE_RATE,
				PROJFUNC_CURRENCY_CODE,
				PROJFUNC_REVENUE_AMOUNT,
				PROJFUNC_REV_RATE_TYPE,
				PROJFUNC_REV_RATE_DATE,
				PROJFUNC_REV_EXCHANGE_RATE,
				PROJFUNC_BILL_AMOUNT,
				PROJFUNC_INV_RATE_TYPE,
				PROJFUNC_INV_RATE_DATE,
				PROJFUNC_INV_EXCHANGE_RATE,
				FUNDING_CURRENCY_CODE,
				FUNDING_REVENUE_AMOUNT,
				FUNDING_REV_RATE_TYPE,
				FUNDING_REV_RATE_DATE,
				FUNDING_REV_EXCHANGE_RATE,
				FUNDING_BILL_AMOUNT,
				FUNDING_INV_RATE_TYPE,
				FUNDING_INV_RATE_DATE,
				FUNDING_INV_EXCHANGE_RATE,
				INV_GEN_REJECTION_CODE,
				RETN_DRAFT_INVOICE_NUM,
				RETN_DRAFT_INVOICE_LINE_NUM,
				RETAINED_AMOUNT,
				RETENTION_RULE_ID
                           )
                       select
		               p_purge_batch_id,
                               p_purge_release,
                               p_project_id,
                               TASK_ID,
                               EVENT_NUM,
                               LINE_NUM,
                               AMOUNT,
                               CREATION_DATE,
                               CREATED_BY,
                               PROJECT_ID,
                               DRAFT_REVENUE_NUM,
                               DRAFT_REVENUE_ITEM_LINE_NUM,
                               CODE_COMBINATION_ID,
                               REQUEST_ID,
                               PROGRAM_APPLICATION_ID,
                               PROGRAM_ID,
                               PROGRAM_UPDATE_DATE,
                               DRAFT_INVOICE_NUM,
                               DRAFT_INVOICE_ITEM_LINE_NUM,
                               BATCH_NAME,
                               LINE_NUM_REVERSED,
                               REVERSED_FLAG,
      			       ORG_ID,
				OUTPUT_VAT_TAX_ID,
                                OUTPUT_TAX_CLASSIFICATION_CODE,
				OUTPUT_TAX_EXEMPT_FLAG,
				OUTPUT_TAX_EXEMPT_REASON_CODE,
				OUTPUT_TAX_EXEMPT_NUMBER,
				PRC_GENERATED_FLAG,
				BILL_TRANS_CURRENCY_CODE,
				BILL_TRANS_AMOUNT,
				REVPROC_CURRENCY_CODE,
				REVPROC_RATE_TYPE,
				REVPROC_RATE_DATE,
				REVPROC_EXCHANGE_RATE,
				INVPROC_CURRENCY_CODE,
				INVPROC_RATE_TYPE,
				INVPROC_RATE_DATE,
				INVPROC_EXCHANGE_RATE,
				PROJECT_CURRENCY_CODE,
				PROJECT_REVENUE_AMOUNT,
				PROJECT_REV_RATE_TYPE,
				PROJECT_REV_RATE_DATE,
				PROJECT_REV_EXCHANGE_RATE,
				PROJECT_BILL_AMOUNT,
				PROJECT_INV_RATE_TYPE,
				PROJECT_INV_RATE_DATE,
				PROJECT_INV_EXCHANGE_RATE,
				PROJFUNC_CURRENCY_CODE,
				PROJFUNC_REVENUE_AMOUNT,
				PROJFUNC_REV_RATE_TYPE,
				PROJFUNC_REV_RATE_DATE,
				PROJFUNC_REV_EXCHANGE_RATE,
				PROJFUNC_BILL_AMOUNT,
				PROJFUNC_INV_RATE_TYPE,
				PROJFUNC_INV_RATE_DATE,
				PROJFUNC_INV_EXCHANGE_RATE,
				FUNDING_CURRENCY_CODE,
				FUNDING_REVENUE_AMOUNT,
				FUNDING_REV_RATE_TYPE,
				FUNDING_REV_RATE_DATE,
				FUNDING_REV_EXCHANGE_RATE,
				FUNDING_BILL_AMOUNT,
				FUNDING_INV_RATE_TYPE,
				FUNDING_INV_RATE_DATE,
				FUNDING_INV_EXCHANGE_RATE,
				INV_GEN_REJECTION_CODE,
				RETN_DRAFT_INVOICE_NUM,
				RETN_DRAFT_INVOICE_LINE_NUM,
				RETAINED_AMOUNT,
				RETENTION_RULE_ID
                       from pa_cust_event_rdl_all erdl
                       where erdl.rowid = l_erdl_rowid_tab(l_erdl_ind);

                       l_NoOfRecordsIns := SQL%ROWCOUNT ;
                    END IF;
/*
                       where (
			      project_id = p_project_id
                              and rownum < l_commit_size
                             ) ;
*/

     pa_debug.debug( ' ->After insert into PA_Cust_Event_RDL_AR') ;
                     /*  l_NoOfRecordsIns := SQL%ROWCOUNT ;  */

                     if l_NoOfRecordsIns > 0 then
                     -- First call the MRC procedure to archive the MC table
                      -- We have a seperate delete statement if the archive option is
                      -- selected because if archive option is selected the the records
                      -- being purged will be those records which are already archived.
                      -- table and

                        PA_MC_EventRevDistLines
                           (    p_purge_batch_id             => p_purge_batch_id,
                                p_project_id                 => p_project_id,
                                p_txn_to_date                => p_txn_to_date,
                                p_purge_release              => p_purge_release,
                                p_mcnoofrecordsins           => l_MC_NoOfRecordsIns,
                                x_err_code                   => x_err_code,
                                x_err_stack                  => x_err_stack,
                                x_err_stage                  => x_err_stage
                            ) ;
                     end if;
                         pa_debug.debug( ' ->Before delete from pa_cust_event_rdl_all ') ;
/* commented and modified as below for performance reasons. Archive Purge 11.5
                         delete from pa_cust_event_rdl_all erdl
                          where (erdl.rowid)
 				          in
                                          ( select erdl1.rowid
                                              from pa_cust_event_rdl_all erdl1,
                                                   pa_cust_event_rdl_ar erdl2
                                             where nvl(erdl2.task_id,-99) = nvl(erdl1.task_id,-99)
                                               and erdl2.event_num = erdl1.event_num
                                               and erdl2.line_num = erdl1.line_num
                                               and erdl1.project_id = erdl2.project_id
                                               and erdl2.purge_project_id = p_project_id
                                          ) ;
*/
/*                         delete from pa_cust_event_rdl_all erdl
                          where (erdl.project_id, erdl.event_num) in
                                          ( select erdl2.project_id, erdl2.event_num
                                              from pa_cust_event_rdl_ar erdl2
                                             where nvl(erdl2.task_id,-99) = nvl(erdl.task_id,-99)
                                               and erdl2.line_num = erdl.line_num
                                               and erdl2.purge_project_id = p_project_id
                                          )
			and erdl.project_id = p_project_id; -- Perf Bug 2695202

                         pa_debug.debug( ' ->After delete from pa_cust_event_rdl_all ') ;
*/
                FORALL l_erdl_ind IN l_erdl_rowid_tab.FIRST .. l_erdl_rowid_tab.LAST
                       DELETE FROM PA_CUST_EVENT_RDL_ALL ERDL
                       WHERE  ERDL.rowid = l_erdl_rowid_tab(l_erdl_ind);

                         l_NoOfRecordsDel :=  SQL%ROWCOUNT ;
                         l_MC_NoOfRecordsDel  := PA_UTILS2.mrc_row_count;
/*                     end if ;
               else

                     l_commit_size := pa_utils2.arpur_mrc_commit_size;

                     -- If the archive option is not selected then the delete will
                     -- be based on the commit size.

                         pa_debug.debug( ' ->Before delete from pa_cust_event_rdl_all ') ;
*/
/*  commented and modified as below for performance reasons. Archive Purge 11.5
                         delete from pa_cust_event_rdl_all erdl
                          where (erdl.rowid)
 				          in
                                          ( select erdl1.rowid
                                            from pa_cust_event_rdl_all erdl1
                                            where erdl1.project_id = p_project_id
					      and rownum <= l_commit_size
                                          ) ;
*/
/*
                         delete from pa_cust_event_rdl_all erdl
                          where erdl.project_id = p_project_id
     		            and rownum <= l_commit_size;
                    l_NoOfRecordsDel := SQL%ROWCOUNT ;
                    l_MC_NoOfRecordsDel  := PA_UTILS2.mrc_row_count;
			 pa_debug.debug( ' ->After delete from pa_cust_event_rdl_all ') ;
               end if ;


               if SQL%ROWCOUNT = 0 then
                     -- Once the SqlCount becomes 0, which means that there are
                     -- no more records to be purged then we exit the loop.

                     exit ;

               else */
                     -- After "deleting" or "deleting and inserting" a set of records
                     -- the transaction is commited. This also creates a record in the
                     -- Pa_Purge_Project_details which will show the no. of records
                     -- that are purged from each table.

                 If l_NoOfRecordsDel > 0 Then
                         pa_debug.debug( ' ->Calling pa_purge.CommitProcess ') ;
                      pa_purge.CommitProcess
                               (p_purge_batch_id             => p_purge_batch_id,
                                p_project_id                 => p_project_id,
                                p_table_name                 => 'PA_CUST_EVENT_RDL_ALL',
                                p_NoOfRecordsIns             => l_NoOfRecordsIns,
                                p_NoOfRecordsDel             => l_NoOfRecordsDel,
                                x_err_code                   => x_err_code,
                                x_err_stack                  => x_err_stack,
                                x_err_stage                  => x_err_stage,
                                p_MRC_table_name             => 'PA_MC_CUST_EVENT_RDL_ALL',
                                p_MRC_NoOfRecordsIns         => l_MC_NoOfRecordsIns,
                                p_MRC_NoOfRecordsDel         => l_MC_NoOfRecordsDel
                                ) ;

                End If;
                      PA_UTILS2.mrc_row_count := 0;
               end if ;
               IF (l_fetch_complete) THEN
                   exit;
               END IF;
     END LOOP ;


     x_err_stack    := l_old_err_stack ;
 EXCEPTION
  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error then
       RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
    pa_debug.debug('Error Procedure Name  := PA_PURGE_BILLING.PA_EventRevDistLines' );
    pa_debug.debug('Error stage is '||x_err_stage );
    pa_debug.debug('Error stack is '||x_err_stack );
    pa_debug.debug(SQLERRM);
    PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM ;

   /* ATG NOCOPY changes */
    x_err_stack    := l_old_err_stack ;

    RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

 end PA_EventRevDistLines ;

-- Start of comments
-- API name         : PA_MC_Events_Trx
-- Type             : Private
-- Pre-reqs         : None
-- Function         : Archive and Purge data for table PA_MC_Events_AR
-- Parameters       : See common list above
-- End of comments
 procedure PA_MC_Events_Trx
                    ( p_purge_batch_id         IN NUMBER,
                      p_project_id             IN NUMBER,
                      p_txn_to_date            IN DATE,
                      p_purge_release          IN VARCHAR2,
                      p_mcnoofrecordsins      OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                      x_err_code           IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                      x_err_stack          IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                      x_err_stage          IN OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                    )    is

     l_old_err_stage         VARCHAR2(2000);
     l_old_err_stack         VARCHAR2(2000);

 begin

     l_old_err_stack := x_err_stack;

     x_err_stack := x_err_stack || ' ->Entering PA_MC_Events_Trx ';

     pa_debug.debug(x_err_stack);

     pa_debug.debug( ' ->Before insert into PA_MC_Events_AR') ;

     /* Funding MRC : Added the column description */
       /* Commented out for MRC migration to SLA
         insert into Pa_Mc_Events_AR
         (
             Purge_Batch_Id,
             Purge_Release,
             Purge_Project_Id,
             Set_Of_Books_Id,
             Event_Id,
             Project_Id,
             Task_Id,
             Event_Num,
             Revenue_Amount,
             Bill_Amount,
             Currency_Code,
             Exchange_Rate,
             Conversion_Date,
	     Prc_Assignment_Id,
	     Rate_Type,
	     Projfunc_Inv_Rate_Date,
	     Projfunc_Inv_Exchange_Rate,
             description
          )
          select
	      p_purge_batch_id,
              p_purge_release,
              p_project_id,
              mc.Set_Of_Books_Id,
              mc.Event_Id,
              mc.Project_Id,
              mc.Task_Id,
              mc.Event_Num,
              mc.Revenue_Amount,
              mc.Bill_Amount,
              mc.Currency_Code,
              mc.Exchange_Rate,
              mc.Conversion_Date,
	      mc.Prc_Assignment_Id,
	      mc.Rate_Type,
	      mc.Projfunc_Inv_Rate_Date,
	      mc.Projfunc_Inv_Exchange_Rate,
              mc.description
         from   Pa_Mc_Events mc,
                PA_Events_AR ar
         where  ar.Purge_Project_Id = p_project_id
         and    mc.event_id = ar.event_id;
*/

     p_mcnoofrecordsins :=  SQL%ROWCOUNT ;

     pa_debug.debug( ' ->After insert into PA_MC_Events_AR') ;
     x_err_stack    := l_old_err_stack ;

 EXCEPTION
  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error then
       RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
    pa_debug.debug('Error Procedure Name  := PA_PURGE_BILLING.PA_MC_Events_Trx');
    pa_debug.debug('Error stage is '||x_err_stage );
    pa_debug.debug('Error stack is '||x_err_stack );
    pa_debug.debug(SQLERRM);
    PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM;

    /* ATG NOCOPY changes */
    p_mcnoofrecordsins := null;
    x_err_stack    := l_old_err_stack ;

    RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

 end PA_MC_Events_Trx ;

-- Start of comments
-- API name         : PA_Event
-- Type             : Private
-- Pre-reqs         : None
-- Function         : Archive and Purge data for table PA_EVENTS
-- Parameters       : See common list above
-- End of comments
 procedure PA_Event
                            ( p_purge_batch_id         IN NUMBER,
                              p_project_id             IN NUMBER,
                              p_txn_to_date            IN DATE,
                              p_purge_release          IN VARCHAR2,
                              p_archive_flag           IN VARCHAR2,
                              p_commit_size            IN NUMBER,
                              x_err_code           IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                              x_err_stack          IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              x_err_stage          IN OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                            )    is

     l_old_err_stage         VARCHAR2(2000);
     l_old_err_stack         VARCHAR2(2000);
     l_NoOfRecordsIns        NUMBER := 0;  --Initialized to zero for bug 3583748
     l_NoOfRecordsDel        NUMBER := 0;  --Initialized to zero for bug 3583748
     l_MC_NoOfRecordsIns     NUMBER := NULL;
     l_MC_NoOfRecordsDel     NUMBER := NULL;
 begin

     l_old_err_stack := x_err_stack;

     x_err_stack := x_err_stack || ' ->Entering PA_EVENT' ;

     pa_debug.debug(x_err_stack);

     LOOP
      l_NoOfRecordsDel := 0;  -- Value of l_NoOfRecordsDel is reset for BUg 4104133
      l_NoOfRecordsIns := 0;  -- Value of l_NoOfRecordsIns is reset for BUg 4104133
               if p_archive_flag = 'Y' then
                     -- First call the MRC procedure to archive the MC table
                     -- If archive option is selected then the records are
                     -- inserted into the archived into the archive tables
                     -- before being purged. The where condition is such that
                     -- only the it inserts half the no. of records specified
                     -- in the commit size.

                     l_commit_size := pa_utils2.arpur_mrc_commit_size / 2 ;

     pa_debug.debug( ' ->Before insert into PA_Events_AR') ;

     /* Funding MRC Changes : Added the column zero_revenue_amount_flag */

                     insert into PA_Events_AR
                          (
			       PURGE_BATCH_ID,
                               PURGE_RELEASE,
                               PURGE_PROJECT_ID,
                               ATTRIBUTE10,
                               PROJECT_ID,
                               ORGANIZATION_ID,
                               BILLING_ASSIGNMENT_ID,
                               EVENT_NUM_REVERSED,
                               CALLING_PLACE,
                               CALLING_PROCESS,
                               TASK_ID,
                               EVENT_NUM,
                               LAST_UPDATE_DATE,
                               LAST_UPDATED_BY,
                               CREATION_DATE,
                               CREATED_BY,
                               LAST_UPDATE_LOGIN,
                               EVENT_TYPE,
                               DESCRIPTION,
                               BILL_AMOUNT,
                               REVENUE_AMOUNT,
                               REVENUE_DISTRIBUTED_FLAG,
                               BILL_HOLD_FLAG,
                               COMPLETION_DATE,
                               REV_DIST_REJECTION_CODE,
                               REQUEST_ID,
                               PROGRAM_APPLICATION_ID,
                               PROGRAM_ID,
                               PROGRAM_UPDATE_DATE,
                               ATTRIBUTE_CATEGORY,
                               ATTRIBUTE1,
                               ATTRIBUTE2,
                               ATTRIBUTE3,
                               ATTRIBUTE4,
                               ATTRIBUTE5,
                               ATTRIBUTE6,
                               ATTRIBUTE7,
                               ATTRIBUTE8,
                               ATTRIBUTE9,
                               Event_Id,
                               Audit_Amount1,
                               Audit_Amount2,
                               Audit_Amount3,
                               Audit_Amount4,
                               Audit_Amount5,
                               Audit_Amount6,
                               Audit_Amount7,
                               Audit_Amount8,
                               Audit_Amount9,
                               Audit_Amount10,
				AUDIT_COST_BUDGET_TYPE_CODE,
				AUDIT_REV_BUDGET_TYPE_CODE,
				INVENTORY_ORG_ID,
				INVENTORY_ITEM_ID,
				QUANTITY_BILLED,
				UOM_CODE,
				UNIT_PRICE,
				REFERENCE1,
				REFERENCE2,
				REFERENCE3,
				REFERENCE4,
				REFERENCE5,
				REFERENCE6,
				REFERENCE7,
				REFERENCE8,
				REFERENCE9,
				REFERENCE10,
				BILLED_FLAG,
				BILL_TRANS_CURRENCY_CODE,
				BILL_TRANS_BILL_AMOUNT,
				BILL_TRANS_REV_AMOUNT,
				PROJECT_CURRENCY_CODE,
				PROJECT_RATE_TYPE,
				PROJECT_RATE_DATE,
				PROJECT_EXCHANGE_RATE,
				PROJECT_REV_RATE_DATE,
				PROJECT_REV_EXCHANGE_RATE,
				PROJECT_REVENUE_AMOUNT,
				PROJECT_INV_RATE_DATE,
				PROJECT_INV_EXCHANGE_RATE,
				PROJECT_BILL_AMOUNT,
				PROJFUNC_CURRENCY_CODE,
				PROJFUNC_RATE_TYPE,
				PROJFUNC_RATE_DATE,
				PROJFUNC_EXCHANGE_RATE,
				PROJFUNC_REV_RATE_DATE,
				PROJFUNC_REV_EXCHANGE_RATE,
				PROJFUNC_REVENUE_AMOUNT,
				PROJFUNC_INV_RATE_DATE,
				PROJFUNC_INV_EXCHANGE_RATE,
				PROJFUNC_BILL_AMOUNT,
				FUNDING_RATE_TYPE,
				FUNDING_RATE_DATE,
				FUNDING_EXCHANGE_RATE,
				REVPROC_CURRENCY_CODE,
				REVPROC_RATE_TYPE,
				REVPROC_RATE_DATE,
				REVPROC_EXCHANGE_RATE,
				INVPROC_CURRENCY_CODE,
				INVPROC_RATE_TYPE,
				INVPROC_RATE_DATE,
				INVPROC_EXCHANGE_RATE,
				INV_GEN_REJECTION_CODE,
				ADJUSTING_REVENUE_FLAG,
                                zero_revenue_amount_flag,
				project_funding_id,
				revenue_hold_flag,
				non_updateable_flag,
                                audit_rev_plan_type_id,
                                audit_cost_plan_type_id,
                                pm_product_code,
                                pm_event_reference,
                                deliverable_id,
                                action_id,
                                record_version_number,
				agreement_id /*Federal*/
                           )
                       select
			       p_purge_batch_id,
                               p_purge_release,
                               p_project_id,
                               ATTRIBUTE10,
                               PROJECT_ID,
                               ORGANIZATION_ID,
                               BILLING_ASSIGNMENT_ID,
                               EVENT_NUM_REVERSED,
                               CALLING_PLACE,
                               CALLING_PROCESS,
                               TASK_ID,
                               EVENT_NUM,
                               LAST_UPDATE_DATE,
                               LAST_UPDATED_BY,
                               CREATION_DATE,
                               CREATED_BY,
                               LAST_UPDATE_LOGIN,
                               EVENT_TYPE,
                               DESCRIPTION,
                               BILL_AMOUNT,
                               REVENUE_AMOUNT,
                               REVENUE_DISTRIBUTED_FLAG,
                               BILL_HOLD_FLAG,
                               COMPLETION_DATE,
                               REV_DIST_REJECTION_CODE,
                               REQUEST_ID,
                               PROGRAM_APPLICATION_ID,
                               PROGRAM_ID,
                               PROGRAM_UPDATE_DATE,
                               ATTRIBUTE_CATEGORY,
                               ATTRIBUTE1,
                               ATTRIBUTE2,
                               ATTRIBUTE3,
                               ATTRIBUTE4,
                               ATTRIBUTE5,
                               ATTRIBUTE6,
                               ATTRIBUTE7,
                               ATTRIBUTE8,
                               ATTRIBUTE9,
                               Event_Id,
                               Audit_Amount1,
                               Audit_Amount2,
                               Audit_Amount3,
                               Audit_Amount4,
                               Audit_Amount5,
                               Audit_Amount6,
                               Audit_Amount7,
                               Audit_Amount8,
                               Audit_Amount9,
                               Audit_Amount10,
				AUDIT_COST_BUDGET_TYPE_CODE,
				AUDIT_REV_BUDGET_TYPE_CODE,
				INVENTORY_ORG_ID,
				INVENTORY_ITEM_ID,
				QUANTITY_BILLED,
				UOM_CODE,
				UNIT_PRICE,
				REFERENCE1,
				REFERENCE2,
				REFERENCE3,
				REFERENCE4,
				REFERENCE5,
				REFERENCE6,
				REFERENCE7,
				REFERENCE8,
				REFERENCE9,
				REFERENCE10,
				BILLED_FLAG,
				BILL_TRANS_CURRENCY_CODE,
				BILL_TRANS_BILL_AMOUNT,
				BILL_TRANS_REV_AMOUNT,
				PROJECT_CURRENCY_CODE,
				PROJECT_RATE_TYPE,
				PROJECT_RATE_DATE,
				PROJECT_EXCHANGE_RATE,
				PROJECT_REV_RATE_DATE,
				PROJECT_REV_EXCHANGE_RATE,
				PROJECT_REVENUE_AMOUNT,
				PROJECT_INV_RATE_DATE,
				PROJECT_INV_EXCHANGE_RATE,
				PROJECT_BILL_AMOUNT,
				PROJFUNC_CURRENCY_CODE,
				PROJFUNC_RATE_TYPE,
				PROJFUNC_RATE_DATE,
				PROJFUNC_EXCHANGE_RATE,
				PROJFUNC_REV_RATE_DATE,
				PROJFUNC_REV_EXCHANGE_RATE,
				PROJFUNC_REVENUE_AMOUNT,
				PROJFUNC_INV_RATE_DATE,
				PROJFUNC_INV_EXCHANGE_RATE,
				PROJFUNC_BILL_AMOUNT,
				FUNDING_RATE_TYPE,
				FUNDING_RATE_DATE,
				FUNDING_EXCHANGE_RATE,
				REVPROC_CURRENCY_CODE,
				REVPROC_RATE_TYPE,
				REVPROC_RATE_DATE,
				REVPROC_EXCHANGE_RATE,
				INVPROC_CURRENCY_CODE,
				INVPROC_RATE_TYPE,
				INVPROC_RATE_DATE,
				INVPROC_EXCHANGE_RATE,
				INV_GEN_REJECTION_CODE,
				ADJUSTING_REVENUE_FLAG,
                                zero_revenue_amount_flag,
				project_funding_id,
				revenue_hold_flag,
				non_updateable_flag,
                                audit_rev_plan_type_id,
                                audit_cost_plan_type_id ,
                                pm_product_code,
                                pm_event_reference,
                                deliverable_id,
                                action_id,
                                record_version_number,
				agreement_id
                       from pa_events
                       where (
			      project_id = p_project_id
                              and rownum <= l_commit_size
                             ) ;

                     l_NoOfRecordsIns :=  SQL%ROWCOUNT;

     pa_debug.debug( ' ->After insert into PA_Events_AR') ;


   /*Code Changes for Bug No.2984871 start */
		     if l_NoOfRecordsIns > 0 then
   /*Code Changes for Bug No.2984871 end */

			 -- First call the MRC procedure to archive the MC table
                         -- We have a seperate delete statement if the archive option is
                         -- selected because if archive option is selected the the records
                         -- being purged will be those records which are already archived.
                         -- table and

                         PA_MC_Events_Trx
                           (    p_purge_batch_id             => p_purge_batch_id,
                                p_project_id                 => p_project_id,
                                p_txn_to_date                => p_txn_to_date,
                                p_purge_release              => p_purge_release,
                                p_mcnoofrecordsins           => l_MC_NoOfRecordsIns,
                                x_err_code                   => x_err_code,
                                x_err_stack                  => x_err_stack,
                                x_err_stage                  => x_err_stage
                            ) ;

                         pa_debug.debug( ' ->Before delete from pa_events ') ;
/*  commented and modified as below for performance reasons. Archive Purge 11.5
                         delete from pa_events ev
                          where (ev.rowid)
 				          in
                                          ( select ev1.rowid
                                              from pa_events ev1,
                                                   pa_events_ar ev2
                                             where nvl(ev2.task_id,-99) = nvl(ev1.task_id,-99)
                                               and ev2.event_num = ev1.event_num
				               and ev2.project_id = ev1.project_id
                                               and ev2.purge_project_id = p_project_id
                                          ) ;
*/
                         delete from pa_events ev
                          where (ev.project_id, ev.event_num) in
			         	  ( select ev2.project_id, ev2.event_num
                                              from pa_events_ar ev2
                                             where nvl(ev2.task_id,-99) = nvl(ev.task_id,-99)
                                               and ev2.purge_project_id = p_project_id
                                          )
			and ev.project_id = p_project_id; -- Perf Bug 2695202

		   /*Code Changes for Bug No.2984871 start */
			 l_NoOfRecordsDel :=  SQL%ROWCOUNT ;
                         l_MC_NoOfRecordsDel  := PA_UTILS2.mrc_row_count;
		   /*Code Changes for Bug No.2984871 end */

			 pa_debug.debug( ' ->After delete from pa_events ') ;


                     end if ;
               else

                     l_commit_size := pa_utils2.arpur_mrc_commit_size;

                     -- If the archive option is not selected then the delete will
                     -- be based on the commit size.

                         pa_debug.debug( ' ->Before delete from pa_events ') ;
/*  commented and modified as below for performance reasons. Archive Purge 11.5
                         delete from pa_events ev
                          where (ev.rowid)
 				          in
                                          ( select ev1.rowid
                                              from pa_events ev1
                                             where ev1.project_id = p_project_id
					       and rownum <= l_commit_size
                                          ) ;
*/
                         delete from pa_events ev
                          where ev.project_id = p_project_id
		            and rownum <= l_commit_size;
	   /*Code Changes for Bug No.2984871 start */
		    l_NoOfRecordsDel := SQL%ROWCOUNT ;
                    l_MC_NoOfRecordsDel  := PA_UTILS2.mrc_row_count;
	   /*Code Changes for Bug No.2984871 end */

                         pa_debug.debug( ' ->After delete from pa_events ') ;

               end if ;

   /*Code Changes for Bug No.2984871 start */
	       if l_NoOfRecordsDel = 0 then
   /*Code Changes for Bug No.2984871 end*/

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
                                p_table_name                 => 'PA_EVENTS',
                                p_NoOfRecordsIns             => l_NoOfRecordsIns,
                                p_NoOfRecordsDel             => l_NoOfRecordsDel,
                                x_err_code                   => x_err_code,
                                x_err_stack                  => x_err_stack,
                                x_err_stage                  => x_err_stage,
                                p_MRC_table_name             => 'PA_MC_EVENTS',
                                p_MRC_NoOfRecordsIns         => l_MC_NoOfRecordsIns,
                                p_MRC_NoOfRecordsDel         => l_MC_NoOfRecordsDel
                                ) ;

                      PA_UTILS2.mrc_row_count := 0;

               end if ;
     END LOOP ;


     x_err_stack    := l_old_err_stack ;
 EXCEPTION
  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error then
       RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
    pa_debug.debug('Error Procedure Name  := PA_PURGE_BILLING.PA_Event' );
    pa_debug.debug('Error stage is '||x_err_stage );
    pa_debug.debug('Error stack is '||x_err_stack );
    pa_debug.debug(SQLERRM);
    PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM ;

    /* ATG NOCOPY changes */
     x_err_stack    := l_old_err_stack ;

    RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

 end PA_Event ;

-- Start of comments
-- API name         : PA_DraftRevItems
-- Type             : Private
-- Pre-reqs         : None
-- Function         : Archive and Purge data for table PA_Draft_Revenue_Items
-- Parameters       : See common list above
-- End of comments
 procedure PA_DraftRevItems
                            ( p_purge_batch_id         IN NUMBER,
                              p_project_id             IN NUMBER,
                              p_txn_to_date            IN DATE,
                              p_purge_release          IN VARCHAR2,
                              p_archive_flag           IN VARCHAR2,
                              p_commit_size            IN NUMBER,
                              x_err_code           IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                              x_err_stack          IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              x_err_stage          IN OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                            )    is

     l_old_err_stage         VARCHAR2(2000);
     l_old_err_stack         VARCHAR2(2000);
     l_NoOfRecordsIns        NUMBER := 0;  --Initialized to zero for bug 3583748
     l_NoOfRecordsDel        NUMBER := 0;  --Initialized to zero for bug 3583748
 begin

     l_old_err_stack := x_err_stack;

     x_err_stack := x_err_stack || ' ->Entering PA_DRAFTREVITEMS ' ;

     pa_debug.debug(x_err_stack);

     LOOP
      l_NoOfRecordsDel := 0;  -- Value of l_NoOfRecordsDel is reset for BUg 4104133
      l_NoOfRecordsIns := 0;  -- Value of l_NoOfRecordsIns is reset for BUg 4104133
               if p_archive_flag = 'Y' then
                     -- If archive option is selected then the records are
                     -- inserted into the archived into the archive tables
                     -- before being purged. The where condition is such that
                     -- only the it inserts half the no. of records specified
                     -- in the commit size.

                     l_commit_size := pa_utils2.arpur_mrc_commit_size / 2 ;

     pa_debug.debug( ' ->Before insert into PA_DRAFT_REV_ITEMS_AR') ;
                     insert into PA_DRAFT_REV_ITEMS_AR (
			       PURGE_BATCH_ID,
                               PURGE_RELEASE,
                               PURGE_PROJECT_ID,
                               PROJECT_ID,
                               DRAFT_REVENUE_NUM,
                               LINE_NUM,
                               LAST_UPDATE_DATE,
                               LAST_UPDATED_BY,
                               CREATION_DATE,
                               CREATED_BY,
                               TASK_ID,
                               AMOUNT,
                               REVENUE_SOURCE,
                               REVENUE_CATEGORY_CODE,
                               LAST_UPDATE_LOGIN,
                               REQUEST_ID,
                               PROGRAM_APPLICATION_ID,
                               PROGRAM_ID,
                               PROGRAM_UPDATE_DATE,
				REVPROC_CURRENCY_CODE,
				PROJFUNC_CURRENCY_CODE,
				PROJFUNC_REVENUE_AMOUNT,
				PROJECT_CURRENCY_CODE,
				PROJECT_REVENUE_AMOUNT,
				FUNDING_CURRENCY_CODE,
				FUNDING_REVENUE_AMOUNT
                           )
                       select
			       p_purge_batch_id,
                               p_purge_release,
                               p_project_id,
                               PROJECT_ID,
                               DRAFT_REVENUE_NUM,
                               LINE_NUM,
                               LAST_UPDATE_DATE,
                               LAST_UPDATED_BY,
                               CREATION_DATE,
                               CREATED_BY,
                               TASK_ID,
                               AMOUNT,
                               REVENUE_SOURCE,
                               REVENUE_CATEGORY_CODE,
                               LAST_UPDATE_LOGIN,
                               REQUEST_ID,
                               PROGRAM_APPLICATION_ID,
                               PROGRAM_ID,
                               PROGRAM_UPDATE_DATE,
				REVPROC_CURRENCY_CODE,
				PROJFUNC_CURRENCY_CODE,
				PROJFUNC_REVENUE_AMOUNT,
				PROJECT_CURRENCY_CODE,
				PROJECT_REVENUE_AMOUNT,
				FUNDING_CURRENCY_CODE,
				FUNDING_REVENUE_AMOUNT
                       from pa_draft_revenue_items dri
                       where (
			      dri.project_id = p_project_id
                              and rownum <= l_commit_size
                             ) ;

                     l_NoOfRecordsIns := SQL%ROWCOUNT ;

     pa_debug.debug( ' ->After insert into PA_DRAFT_REV_ITEMS_AR') ;

   /*Code Changes for Bug No.2984871 start */
		     if l_NoOfRecordsIns > 0 then
   /*Code Changes for Bug No.2984871 end */

			 -- We have a seperate delete statement if the archive option is
                         -- selected because if archive option is selected the the records
                         -- being purged will be those records which are already archived.
                         -- table and

                         pa_debug.debug( ' ->Before delete from pa_draft_revenue_items ') ;
/*  commented and modified as below for performance reasons. Archive Purge 11.5
                         delete from pa_draft_revenue_items dri
                          where (dri.rowid)
 				          in
                                          ( select dri1.rowid
                                              from pa_draft_revenue_items dri1,
                                                   PA_DRAFT_REV_ITEMS_AR dri2
                                             where dri2.draft_revenue_num = dri1.draft_revenue_num
                                               and dri2.line_num = dri1.line_num
					       and dri2.project_id = dri1.project_id
                                               and dri2.purge_project_id = p_project_id
                                          ) ;
*/
/* Commented the delete statement and added the modified code below not to correlate queries */
/*                         delete from pa_draft_revenue_items dri
                          where (dri.project_id, dri.draft_revenue_num) in
                                          ( select dri2.project_id, dri2.draft_revenue_num
                                              from PA_DRAFT_REV_ITEMS_AR dri2
                                             where dri2.line_num = dri.line_num
                                               and dri2.purge_project_id = p_project_id
                                          ) ;
*/
                         delete from pa_draft_revenue_items dri
                          where (dri.project_id, dri.draft_revenue_num, dri.line_num) in
                                          ( select dri2.project_id, dri2.draft_revenue_num, dri2.line_num
                                              from PA_DRAFT_REV_ITEMS_AR dri2
                                             where dri2.purge_project_id = p_project_id
                                          ) ;
	   /*Code Changes for Bug No.2984871 start */
		     l_NoOfRecordsDel := SQL%ROWCOUNT ;
	   /*Code Changes for Bug No.2984871 end */

			 pa_debug.debug( ' ->After delete from pa_draft_revenue_items ') ;

                     end if ;
               else

                     l_commit_size := pa_utils2.arpur_mrc_commit_size;

                     -- If the archive option is not selected then the delete will
                     -- be based on the commit size.

                         pa_debug.debug( ' ->Before delete from pa_draft_revenue_items ') ;
/* commented and modified as below for performance reasons. Archive Purge 11.5
                         delete from pa_draft_revenue_items dri
                          where (dri.rowid)
 				          in
                                          ( select dri1.rowid
					     from pa_draft_revenue_items dri1
                                             where dri1.project_id = p_project_id
                                             and rownum <= l_commit_size
                                          ) ;
*/
                         delete from pa_draft_revenue_items dri
                          where dri.project_id = p_project_id
                            and rownum <= l_commit_size;
	   /*Code Changes for Bug No.2984871 start */
		    l_NoOfRecordsDel :=  SQL%ROWCOUNT ;
	   /*Code Changes for Bug No.2984871 end */

                         pa_debug.debug( ' ->After delete from pa_draft_revenue_items ') ;
               end if ;

   /*Code Changes for Bug No.2984871 start */
	       if  l_NoOfRecordsDel= 0 then
   /*Code Changes for Bug No.2984871 end */
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
                                p_table_name                 => 'PA_DRAFT_REVENUE_ITEMS',
                                p_NoOfRecordsIns             => l_NoOfRecordsIns,
                                p_NoOfRecordsDel             => l_NoOfRecordsDel,
                                x_err_code                   => x_err_code,
                                x_err_stack                  => x_err_stack,
                                x_err_stage                  => x_err_stage
                                ) ;

               end if ;
     END LOOP ;


     x_err_stack    := l_old_err_stack ;
 EXCEPTION
  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error then
       RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
    pa_debug.debug('Error Procedure Name  := PA_PURGE_BILLING.PA_DraftRevItems' );
    pa_debug.debug('Error stage is '||x_err_stage );
    pa_debug.debug('Error stack is '||x_err_stack );
    pa_debug.debug(SQLERRM);
    PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM ;

    /* ATG NOCOPY changes */
     x_err_stack    := l_old_err_stack ;

    RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

 end PA_DraftRevItems ;

-- Start of comments
-- API name         : PA_MC_DRAFTINVOICEITEMS
-- Type             : Private
-- Pre-reqs         : None
-- Function         : Archive and Purge data for table PA_MC_DRAFT_INV_ITMS_AR
-- Parameters       : See common list above
-- End of comments
 procedure PA_MC_DraftInvoiceItems
                            ( p_purge_batch_id         IN NUMBER,
                              p_project_id             IN NUMBER,
                              p_txn_to_date            IN DATE,
                              p_purge_release          IN VARCHAR2,
                              p_mcnoofrecordsins      OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                              x_err_code           IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                              x_err_stack          IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              x_err_stage          IN OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                            )    is

     l_old_err_stage         VARCHAR2(2000);
     l_old_err_stack         VARCHAR2(2000);

 begin


     l_old_err_stack := x_err_stack;

     x_err_stack := x_err_stack || ' ->Entering PA_MC_DRAFTINVOICEITEMS ';

     pa_debug.debug(x_err_stack);

     pa_debug.debug( ' ->Before insert into PA_MC_DRAFT_INV_ITMS_AR') ;

       /* Commented out for MRC migration to SLA  insert into PA_MC_DRAFT_INV_ITMS_AR
         (
               Purge_Batch_Id,
               Purge_Release,
               Purge_Project_Id,
               Set_Of_Books_Id,
               Project_Id,
               Draft_Invoice_Num,
               Line_Num,
               Amount,
               Unbilled_Receivable_Dr,
               Unearned_Revenue_Cr,
		Prc_Assignment_Id,
		Currency_Code,
		Exchange_Rate,
		Conversion_Date,
		Rate_Type
         )
         select
	       p_purge_batch_id,
               p_purge_release,
               p_project_id,
               mc.Set_Of_Books_Id,
               mc.Project_Id,
               mc.Draft_Invoice_Num,
               mc.Line_Num,
               mc.Amount,
               mc.Unbilled_Receivable_Dr,
               mc.Unearned_Revenue_Cr,
	       mc.Prc_Assignment_Id,
	       mc.Currency_Code,
	       mc.Exchange_Rate,
	       mc.Conversion_Date,
	       mc.Rate_Type
         from Pa_Mc_Draft_Inv_Items mc,
              -- PA_MC_DRAFT_INV_ITMS_AR ar   Bug 2590517
              PA_DRAFT_INV_ITEMS_AR ar
         where ar.Purge_Project_Id  = p_project_id
         and   mc.Project_Id        = ar.Purge_Project_Id
         and   mc.Draft_Invoice_Num = ar.Draft_Invoice_Num
         and   mc.Line_Num          = ar.Line_Num;
 */
     p_mcnoofrecordsins :=  SQL%ROWCOUNT ;

     pa_debug.debug( ' ->After insert into PA_MC_DRAFT_INV_ITMS_AR') ;
     x_err_stack    := l_old_err_stack ;

 EXCEPTION
  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error then
       RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
    pa_debug.debug('Error Procedure Name  := PA_PURGE_BILLING.PA_MC_DRAFTINVOICEITEMS' );
    pa_debug.debug('Error stage is '||x_err_stage );
    pa_debug.debug('Error stack is '||x_err_stack );
    pa_debug.debug(SQLERRM);
    PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM ;

    /* ATG NOCOPY changes */
    p_mcnoofrecordsins := null;
    x_err_stack    := l_old_err_stack ;


    RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

 end PA_MC_DRAFTINVOICEITEMS ;

-- Start of comments
-- API name         : PA_DraftInvItems
-- Type             : Private
-- Pre-reqs         : None
-- Function         : Archive and Purge data for table PA_DRAFT_INVOICE_ITEMS
-- Parameters       : See common list above
-- End of comments
 procedure PA_DraftInvItems
                            ( p_purge_batch_id         IN NUMBER,
                              p_project_id             IN NUMBER,
                              p_txn_to_date            IN DATE,
                              p_purge_release          IN VARCHAR2,
                              p_archive_flag           IN VARCHAR2,
                              p_commit_size            IN NUMBER,
                              x_err_code           IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                              x_err_stack          IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              x_err_stage          IN OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                            )    is

     l_old_err_stage         VARCHAR2(2000);
     l_old_err_stack         VARCHAR2(2000);
     l_NoOfRecordsIns        NUMBER:= 0;  --Initialized to zero for bug 3583748
     l_NoOfRecordsDel        NUMBER:= 0;  --Initialized to zero for bug 3583748
     l_MC_NoOfRecordsIns     NUMBER := NULL;
     l_MC_NoOfRecordsDel     NUMBER := NULL;
 begin

     l_old_err_stack := x_err_stack;

     x_err_stack := x_err_stack || ' ->Entering PA_DRAFT_INVOICE_ITEMS' ;

     pa_debug.debug(x_err_stack);

     LOOP
      l_NoOfRecordsDel := 0;  -- Value of l_NoOfRecordsDel is reset for BUg 4104133
      l_NoOfRecordsIns := 0;  -- Value of l_NoOfRecordsIns is reset for BUg 4104133
               if p_archive_flag = 'Y' then
                     -- If archive option is selected then the records are
                     -- inserted into the archived into the archive tables
                     -- before being purged. The where condition is such that
                     -- only the it inserts half the no. of records specified
                     -- in the commit size.

                     l_commit_size := pa_utils2.arpur_mrc_commit_size / 2 ;

     pa_debug.debug( ' ->Before insert into PA_DRAFT_INV_ITEMS_AR') ;
                     insert into PA_DRAFT_INV_ITEMS_AR (
			       PURGE_BATCH_ID,
                               PURGE_RELEASE,
                               PURGE_PROJECT_ID,
                               PROJECT_ID,
                               DRAFT_INVOICE_NUM,
                               LINE_NUM,
                               LAST_UPDATE_DATE,
                               LAST_UPDATED_BY,
                               CREATION_DATE,
                               CREATED_BY,
                               AMOUNT,
                               TEXT,
                               INVOICE_LINE_TYPE,
                               REQUEST_ID,
                               PROGRAM_APPLICATION_ID,
                               PROGRAM_ID,
                               PROGRAM_UPDATE_DATE,
                               UNEARNED_REVENUE_CR,
                               UNBILLED_RECEIVABLE_DR,
                               TASK_ID,
                               EVENT_TASK_ID,
                               EVENT_NUM,
                               SHIP_TO_ADDRESS_ID,
                               TAXABLE_FLAG,
                               DRAFT_INV_LINE_NUM_CREDITED,
                               LAST_UPDATE_LOGIN,
				INV_AMOUNT,
				OUTPUT_VAT_TAX_ID,
                                OUTPUT_TAX_CLASSIFICATION_CODE,
				OUTPUT_TAX_EXEMPT_FLAG,
				OUTPUT_TAX_EXEMPT_REASON_CODE,
				OUTPUT_TAX_EXEMPT_NUMBER,
				ACCT_AMOUNT,
				ROUNDING_AMOUNT,
				UNBILLED_ROUNDING_AMOUNT_DR,
				UNEARNED_ROUNDING_AMOUNT_CR,
				TRANSLATED_TEXT,
				CC_REV_CODE_COMBINATION_ID,
				CC_PROJECT_ID,
				CC_TAX_TASK_ID,
				PROJFUNC_CURRENCY_CODE,
				PROJFUNC_BILL_AMOUNT,
				PROJECT_CURRENCY_CODE,
				PROJECT_BILL_AMOUNT,
				FUNDING_CURRENCY_CODE,
				FUNDING_BILL_AMOUNT,
				FUNDING_RATE_DATE,
				FUNDING_EXCHANGE_RATE,
				FUNDING_RATE_TYPE,
				INVPROC_CURRENCY_CODE,
				BILL_TRANS_CURRENCY_CODE,
				BILL_TRANS_BILL_AMOUNT,
				RETN_BILLING_METHOD,
				RETN_PERCENT_COMPLETE,
				RETN_TOTAL_RETENTION,
				RETN_BILLING_CYCLE_ID,
				RETN_CLIENT_EXTENSION_FLAG,
				RETN_BILLING_PERCENTAGE,
				RETN_BILLING_AMOUNT,
				RETENTION_RULE_ID,
				RETAINED_AMOUNT,
				RETN_DRAFT_INVOICE_NUM,
				RETN_DRAFT_INVOICE_LINE_NUM
                           )
                       select
       			       p_purge_batch_id,
                               p_purge_release,
                               p_project_id,
                               PROJECT_ID,
                               DRAFT_INVOICE_NUM,
                               LINE_NUM,
                               LAST_UPDATE_DATE,
                               LAST_UPDATED_BY,
                               CREATION_DATE,
                               CREATED_BY,
                               AMOUNT,
                               TEXT,
                               INVOICE_LINE_TYPE,
                               REQUEST_ID,
                               PROGRAM_APPLICATION_ID,
                               PROGRAM_ID,
                               PROGRAM_UPDATE_DATE,
                               UNEARNED_REVENUE_CR,
                               UNBILLED_RECEIVABLE_DR,
                               TASK_ID,
                               EVENT_TASK_ID,
                               EVENT_NUM,
                               SHIP_TO_ADDRESS_ID,
                               TAXABLE_FLAG,
                               DRAFT_INV_LINE_NUM_CREDITED,
                               LAST_UPDATE_LOGIN,
				INV_AMOUNT,
				OUTPUT_VAT_TAX_ID,
                                OUTPUT_TAX_CLASSIFICATION_CODE,
				OUTPUT_TAX_EXEMPT_FLAG,
				OUTPUT_TAX_EXEMPT_REASON_CODE,
				OUTPUT_TAX_EXEMPT_NUMBER,
				ACCT_AMOUNT,
				ROUNDING_AMOUNT,
				UNBILLED_ROUNDING_AMOUNT_DR,
				UNEARNED_ROUNDING_AMOUNT_CR,
				TRANSLATED_TEXT,
				CC_REV_CODE_COMBINATION_ID,
				CC_PROJECT_ID,
				CC_TAX_TASK_ID,
				PROJFUNC_CURRENCY_CODE,
				PROJFUNC_BILL_AMOUNT,
				PROJECT_CURRENCY_CODE,
				PROJECT_BILL_AMOUNT,
				FUNDING_CURRENCY_CODE,
				FUNDING_BILL_AMOUNT,
				FUNDING_RATE_DATE,
				FUNDING_EXCHANGE_RATE,
				FUNDING_RATE_TYPE,
				INVPROC_CURRENCY_CODE,
				BILL_TRANS_CURRENCY_CODE,
				BILL_TRANS_BILL_AMOUNT,
				RETN_BILLING_METHOD,
				RETN_PERCENT_COMPLETE,
				RETN_TOTAL_RETENTION,
				RETN_BILLING_CYCLE_ID,
				RETN_CLIENT_EXTENSION_FLAG,
				RETN_BILLING_PERCENTAGE,
				RETN_BILLING_AMOUNT,
				RETENTION_RULE_ID,
				RETAINED_AMOUNT,
				RETN_DRAFT_INVOICE_NUM,
				RETN_DRAFT_INVOICE_LINE_NUM
                       from pa_draft_invoice_items
                       where (
			      project_id = p_project_id
                              and rownum <= l_commit_size
                             ) ;
	   /*Code Changes for Bug No.2984871 start */
                     l_NoOfRecordsIns := SQL%ROWCOUNT ;
	   /*Code Changes for Bug No.2984871 end */


     pa_debug.debug( ' ->After insert into PA_DRAFT_INV_ITEMS_AR') ;

	   /*Code Changes for Bug No.2984871 start */
		     if l_NoOfRecordsIns > 0 then
	   /*Code Changes for Bug No.2984871 end */
			 -- First call the MRC procedure to archive the MC table
                         -- We have a seperate delete statement if the archive option is
                         -- selected because if archive option is selected the the records
                         -- being purged will be those records which are already archived.
                         -- table and

                        PA_MC_DraftInvoiceItems
                           (    p_purge_batch_id             => p_purge_batch_id,
                                p_project_id                 => p_project_id,
                                p_txn_to_date                => p_txn_to_date,
                                p_purge_release              => p_purge_release,
                                p_mcnoofrecordsins           => l_MC_NoOfRecordsIns,
                                x_err_code                   => x_err_code,
                                x_err_stack                  => x_err_stack,
                                x_err_stage                  => x_err_stage
                            ) ;

                         pa_debug.debug( ' ->Before delete from pa_draft_invoice_items ') ;
/* commented and modified as below for performance reasons. Archive Purge 11.5
                         delete from pa_draft_invoice_items dii
                          where (dii.rowid)
 				          in
                                          ( select dii1.rowid
                                              from pa_draft_invoice_items dii1,
                                                   PA_DRAFT_INV_ITEMS_AR dii2
                                             where dii2.draft_invoice_num = dii1.draft_invoice_num
                                               and dii2.line_num = dii1.line_num
					       and dii2.project_id = dii1.project_id
                                               and dii2.purge_project_id = p_project_id
                                          ) ;
*/
/* Commented the delete statement and added the modified code below not to correlate queries */
/*                         delete from pa_draft_invoice_items dii
                          where (dii.project_id, dii.draft_invoice_num) in
                                          ( select dii2.project_id, dii2.draft_invoice_num
                                              from PA_DRAFT_INV_ITEMS_AR dii2
                                             where dii2.line_num = dii.line_num
                                               and dii2.purge_project_id = p_project_id
                                          ) ;
*/
                         delete from pa_draft_invoice_items dii
                          where (dii.project_id, dii.draft_invoice_num, dii.line_num) in
                                          ( select dii2.project_id, dii2.draft_invoice_num, dii2.line_num
                                              from PA_DRAFT_INV_ITEMS_AR dii2
                                             where dii2.purge_project_id = p_project_id
                                          ) ;

		   /*Code Changes for Bug No.2984871 start */
			 l_NoOfRecordsDel :=  SQL%ROWCOUNT ;
                         l_MC_NoOfRecordsDel  := PA_UTILS2.mrc_row_count;
		   /*Code Changes for Bug No.2984871 end */

                         pa_debug.debug( ' ->After delete from pa_draft_invoice_items ') ;

                     end if ;
               else

                     l_commit_size := pa_utils2.arpur_mrc_commit_size;

                     -- If the archive option is not selected then the delete will
                     -- be based on the commit size.

                         pa_debug.debug( ' ->Before delete from pa_draft_invoice_items ') ;
/* commented and modified as below for performance reasons. Archive Purge 11.5
                         delete from pa_draft_invoice_items dii
                          where (dii.rowid)
 				          in
                                          ( select dii1.rowid
					     from pa_draft_invoice_items dii1
                                             where dii1.project_id = p_project_id
                                             and rownum <= l_commit_size
                                          ) ;
*/

                         delete from pa_draft_invoice_items dii
                          where dii.project_id = p_project_id
                            and rownum <= l_commit_size;
	   /*Code Changes for Bug No.2984871 start */
		    l_NoOfRecordsDel := SQL%ROWCOUNT ;
                    l_MC_NoOfRecordsDel  := PA_UTILS2.mrc_row_count;
	   /*Code Changes for Bug No.2984871 end */

                         pa_debug.debug( ' ->After delete from pa_draft_invoice_items ') ;

               end if ;

	   /*Code Changes for Bug No.2984871 start */
	       if  l_NoOfRecordsDel= 0 then
           /*Code Changes for Bug No.2984871 end */
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
                                p_table_name                 => 'PA_DRAFT_INVOICE_ITEMS',
                                p_NoOfRecordsIns             => l_NoOfRecordsIns,
                                p_NoOfRecordsDel             => l_NoOfRecordsDel,
                                x_err_code                   => x_err_code,
                                x_err_stack                  => x_err_stack,
                                x_err_stage                  => x_err_stage,
                                p_MRC_table_name             => 'PA_MC_DRAFT_INV_ITEMS',
                                p_MRC_NoOfRecordsIns         => l_MC_NoOfRecordsIns,
                                p_MRC_NoOfRecordsDel         => l_MC_NoOfRecordsDel
                                ) ;

                      PA_UTILS2.mrc_row_count := 0;

               end if ;
     END LOOP ;


     x_err_stack    := l_old_err_stack ;
 EXCEPTION
  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error then
       RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
    pa_debug.debug('Error Procedure Name  := PA_PURGE_BILLING.PA_DraftInvItems' );
    pa_debug.debug('Error stage is '||x_err_stage );
    pa_debug.debug('Error stack is '||x_err_stack );
    pa_debug.debug(SQLERRM);
    PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM ;

    /* ATG NOCOPY changes */
     x_err_stack    := l_old_err_stack ;


    RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

 end PA_DraftInvItems ;

-- Start of comments
-- API name         : PA_MC_RETNINVDETAILS
-- Type             : Private
-- Pre-reqs         : None
-- Function         : Archive and Purge data for table PA_MC_RETN_INV_DETLS_AR
-- Parameters       : See common list above
-- End of comments
 procedure PA_MC_RetnInvDetails
                            ( p_purge_batch_id         IN NUMBER,
                              p_project_id             IN NUMBER,
                              p_txn_to_date            IN DATE,
                              p_purge_release          IN VARCHAR2,
                              p_mcnoofrecordsins      OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                              x_err_code           IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                              x_err_stack          IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              x_err_stage          IN OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                            )    is

     l_old_err_stage         VARCHAR2(2000);
     l_old_err_stack         VARCHAR2(2000);

 begin

     l_old_err_stack := x_err_stack;

     x_err_stack := x_err_stack || ' ->Entering PA_MC_RETNINVDETAILS ';

     pa_debug.debug(x_err_stack);

     pa_debug.debug( ' ->Before insert into PA_MC_RETN_INV_DETLS_AR') ;

/* Commented out for MRC migration to SLA
         insert into PA_MC_RETN_INV_DETLS_AR
         (
           Purge_Batch_Id,
           Purge_Release,
           Purge_Project_Id,
           RETN_INVOICE_DETAIL_ID,
           SET_OF_BOOKS_ID,
           PROJECT_ID,
           DRAFT_INVOICE_NUM,
           LINE_NUM,
           TOTAL_RETAINED,
           ACCT_CURRENCY_CODE,
           ACCT_RATE_TYPE,
           ACCT_RATE_DATE,
           ACCT_EXCHANGE_RATE,
           PROGRAM_APPLICATION_ID,
           PROGRAM_ID,
           PROGRAM_UPDATE_DATE,
           REQUEST_ID,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
         )
         select
           p_purge_batch_id,
           p_purge_release,
           p_project_id,
           mc.RETN_INVOICE_DETAIL_ID,
           mc.SET_OF_BOOKS_ID,
           mc.PROJECT_ID,
           mc.DRAFT_INVOICE_NUM,
           mc.LINE_NUM,
           mc.TOTAL_RETAINED,
           mc.ACCT_CURRENCY_CODE,
           mc.ACCT_RATE_TYPE,
           mc.ACCT_RATE_DATE,
           mc.ACCT_EXCHANGE_RATE,
           mc.PROGRAM_APPLICATION_ID,
           mc.PROGRAM_ID,
           mc.PROGRAM_UPDATE_DATE,
           mc.REQUEST_ID,
           mc.CREATION_DATE,
           mc.CREATED_BY,
           mc.LAST_UPDATE_DATE,
           mc.LAST_UPDATED_BY
         from Pa_MC_Retn_Inv_Details mc,
              PA_RETN_INV_DETAILS_AR ar
         where ar.Purge_Project_Id  = p_project_id
         and   mc.Project_Id        = ar.purge_Project_Id
         and   mc.Draft_Invoice_Num = ar.Draft_Invoice_Num
         and   mc.Line_Num          = ar.Line_Num;

*/
     p_mcnoofrecordsins :=  SQL%ROWCOUNT ;

     pa_debug.debug( ' ->After insert into PA_MC_RETN_INV_DETLS_AR') ;
     x_err_stack    := l_old_err_stack ;

 EXCEPTION
  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error then
       RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
    pa_debug.debug('Error Procedure Name  := PA_PURGE_BILLING.PA_MC_RETNINVDETAILS' );
    pa_debug.debug('Error stage is '||x_err_stage );
    pa_debug.debug('Error stack is '||x_err_stack );
    pa_debug.debug(SQLERRM);
    PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM ;

   /* ATG NOCOPY changes */
    p_mcnoofrecordsins := null;
    x_err_stack    := l_old_err_stack ;

    RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

 end PA_MC_RETNINVDETAILS;

-- Start of comments
-- API name         : PA_RetnInvDetails
-- Type             : Private
-- Pre-reqs         : None
-- Function         : Archive and Purge data for table PA_RETN_INVOICE_DETAILS
-- Parameters       : See common list above
-- End of comments
 procedure PA_RetnInvDetails
                            ( p_purge_batch_id         IN NUMBER,
                              p_project_id             IN NUMBER,
                              p_txn_to_date            IN DATE,
                              p_purge_release          IN VARCHAR2,
                              p_archive_flag           IN VARCHAR2,
                              p_commit_size            IN NUMBER,
                              x_err_code           IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                              x_err_stack          IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              x_err_stage          IN OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                            )    is

     l_old_err_stage         VARCHAR2(2000);
     l_old_err_stack         VARCHAR2(2000);
     l_NoOfRecordsIns        NUMBER:= 0;  --Initialized to zero for bug 3583748
     l_NoOfRecordsDel        NUMBER:= 0;  --Initialized to zero for bug 3583748
     l_MC_NoOfRecordsIns     NUMBER := NULL;
     l_MC_NoOfRecordsDel     NUMBER := NULL;
 begin

     l_old_err_stack := x_err_stack;

     x_err_stack := x_err_stack || ' ->Entering PA_RETN_INVOICE_DETAILS' ;

     pa_debug.debug(x_err_stack);

     LOOP
     l_NoOfRecordsDel := 0;  -- Value of l_NoOfRecordsDel is reset for BUg 4104133
     l_NoOfRecordsIns := 0;  -- Value of l_NoOfRecordsIns is reset for BUg 4104133
               if p_archive_flag = 'Y' then
                     -- If archive option is selected then the records are
                     -- inserted into the archived into the archive tables
                     -- before being purged. The where condition is such that
                     -- only the it inserts half the no. of records specified
                     -- in the commit size.

                     l_commit_size := pa_utils2.arpur_mrc_commit_size / 2 ;

     pa_debug.debug( ' ->Before insert into PA_RETN_INV_DETAILS_AR') ;
                     insert into PA_RETN_INV_DETAILS_AR (
			         PURGE_BATCH_ID,
                                 PURGE_RELEASE,
                                 PURGE_PROJECT_ID,
				 RETN_INVOICE_DETAIL_ID,
				 PROJECT_ID,
				 DRAFT_INVOICE_NUM,
				 LINE_NUM,
				 PROJECT_RETENTION_ID,
				 INVPROC_CURRENCY_CODE,
				 TOTAL_RETAINED,
				 PROJFUNC_CURRENCY_CODE,
				 PROJFUNC_TOTAL_RETAINED,
				 PROJECT_CURRENCY_CODE,
				 PROJECT_TOTAL_RETAINED,
				 FUNDING_CURRENCY_CODE,
				 FUNDING_TOTAL_RETAINED,
				 PROGRAM_APPLICATION_ID,
				 PROGRAM_ID,
				 PROGRAM_UPDATE_DATE,
				 REQUEST_ID,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY
                           )
                       select
       			         P_PURGE_BATCH_ID,
                                 P_PURGE_RELEASE,
                                 P_PROJECT_ID,
				 RETN_INVOICE_DETAIL_ID,
				 PROJECT_ID,
				 DRAFT_INVOICE_NUM,
				 LINE_NUM,
				 PROJECT_RETENTION_ID,
				 INVPROC_CURRENCY_CODE,
				 TOTAL_RETAINED,
				 PROJFUNC_CURRENCY_CODE,
				 PROJFUNC_TOTAL_RETAINED,
				 PROJECT_CURRENCY_CODE,
				 PROJECT_TOTAL_RETAINED,
				 FUNDING_CURRENCY_CODE,
				 FUNDING_TOTAL_RETAINED,
				 PROGRAM_APPLICATION_ID,
				 PROGRAM_ID,
				 PROGRAM_UPDATE_DATE,
				 REQUEST_ID,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY
                       from PA_Retn_Invoice_Details
                       where (
			      project_id = p_project_id
                              and rownum <= l_commit_size
                             ) ;

                     l_NoOfRecordsIns := SQL%ROWCOUNT ;

     pa_debug.debug( ' ->After insert into PA_RETN_INV_DETAILS_AR') ;

   /*Code Changes for Bug No.2984871 start */
		     if l_NoOfRecordsIns > 0 then
   /*Code Changes for Bug No.2984871 end */

			 -- First call the MRC procedure to archive the MC table
                         -- We have a seperate delete statement if the archive option is
                         -- selected because if archive option is selected the the records
                         -- being purged will be those records which are already archived.
                         -- table and

                        PA_MC_RETNINVDETAILS
                           (    p_purge_batch_id             => p_purge_batch_id,
                                p_project_id                 => p_project_id,
                                p_txn_to_date                => p_txn_to_date,
                                p_purge_release              => p_purge_release,
                                p_mcnoofrecordsins           => l_MC_NoOfRecordsIns,
                                x_err_code                   => x_err_code,
                                x_err_stack                  => x_err_stack,
                                x_err_stage                  => x_err_stage
                            ) ;

/* Added the code to delete the records from the MC table of Pa_Retn_Invoice_Details for bug#2272487, starts here*/
                         pa_debug.debug( ' ->Before delete from Pa_MC_Retn_Inv_Details ') ;

                       /* Commented out for MRC migration to SLA  delete from Pa_MC_Retn_Inv_Details rid
                          where (rid.project_id, rid.draft_invoice_num) in
                                          ( select rid2.project_id, rid2.draft_invoice_num
                                              from PA_MC_RETN_INV_DETLS_AR rid2
                                             where rid2.line_num = rid.line_num
                                               and rid2.purge_project_id = p_project_id
                                          ) ; */
	   /*Code Changes for Bug No.2984871 start */
			 l_MC_NoOfRecordsDel  := SQL%ROWCOUNT;
	   /*Code Changes for Bug No.2984871 end */

			 pa_debug.debug( ' ->After delete from Pa_MC_Retn_Inv_Details ') ;

/* Added the code to delete the records from the MC table of Pa_Retn_Invoice_Details for bug#2272487, ends here*/

                         pa_debug.debug( ' ->Before delete from PA_Retn_Invoice_Details ') ;
/* commented and modified as below for performance reasons. Archive Purge 11.5
                         delete from PA_Retn_Invoice_Details rid
                          where (rid.rowid)
 				          in
                                          ( select rid1.rowid
                                              from PA_Retn_Invoice_Details rid1,
                                                   PA_RETN_INV_DETAILS_AR rid2
                                             where rid2.draft_invoice_num = rid1.draft_invoice_num
                                               and rid2.line_num = rid1.line_num
					       and rid2.project_id = rid1.project_id
                                               and rid2.purge_project_id = p_project_id
                                          ) ;
*/
                         delete from PA_Retn_Invoice_Details rid
                          where (rid.project_id, rid.draft_invoice_num) in
                                          ( select rid2.project_id, rid2.draft_invoice_num
                                              from PA_RETN_INV_DETAILS_AR rid2
                                             where rid2.line_num = rid.line_num
                                               and rid2.purge_project_id = p_project_id
                                          ) ;
	   /*Code Changes for Bug No.2984871 start */
			 l_NoOfRecordsDel :=  SQL%ROWCOUNT ;
	   /*Code Changes for Bug No.2984871 end */

			 pa_debug.debug( ' ->After delete from PA_Retn_Invoice_Details ') ;

                     end if ;
               else

                     l_commit_size := pa_utils2.arpur_mrc_commit_size;

                     -- If the archive option is not selected then the delete will
                     -- be based on the commit size.


/* Added the code to delete the records from the MC table of Pa_Retn_Invoice_Details for bug#2272487, starts here */
                         pa_debug.debug( ' ->Before delete from Pa_MC_Retn_Inv_Details ') ;

                     /* Commented out for MRC migration to SLA    delete from Pa_MC_Retn_Inv_Details rid
                          where rid.project_id = p_project_id
                            and rownum <= l_commit_size; */
	   -- Code Changes for Bug No.2984871 start
                         l_MC_NoOfRecordsDel  := SQL%ROWCOUNT;
	   -- Code Changes for Bug No.2984871 end

			 pa_debug.debug( ' ->After delete from Pa_MC_Retn_Inv_Details ') ;

/* Added the code to delete the records from the MC table of Pa_Retn_Invoice_Details for bug#2272487, ends here */

                         pa_debug.debug( ' ->Before delete from PA_Retn_Invoice_Details ') ;
/* commented and modified as below for performance reasons. Archive Purge 11.5
                         delete from PA_Retn_Invoice_Details rid
                          where (rid.rowid)
 				          in
                                          ( select rid1.rowid
					     from PA_Retn_Invoice_Details rid1
                                             where rid1.project_id = p_project_id
                                             and rownum <= l_commit_size
                                          ) ;
*/
                         delete from PA_Retn_Invoice_Details rid
                          where rid.project_id = p_project_id
                            and rownum <= l_commit_size;
   /*Code Changes for Bug No.2984871 start */
		    l_NoOfRecordsDel := SQL%ROWCOUNT ;
   /*Code Changes for Bug No.2984871 end */

                         pa_debug.debug( ' ->After delete from PA_Retn_Invoice_Details ') ;

               end if ;

               if l_NoOfRecordsDel = 0 then
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
                                p_table_name                 => 'PA_RETN_INVOICE_DETAILS',
                                p_NoOfRecordsIns             => l_NoOfRecordsIns,
                                p_NoOfRecordsDel             => l_NoOfRecordsDel,
                                x_err_code                   => x_err_code,
                                x_err_stack                  => x_err_stack,
                                x_err_stage                  => x_err_stage,
                                p_MRC_table_name             => 'Pa_MC_Retn_Inv_Details',
                                p_MRC_NoOfRecordsIns         => l_MC_NoOfRecordsIns,
                                p_MRC_NoOfRecordsDel         => l_MC_NoOfRecordsDel
                                ) ;

                      PA_UTILS2.mrc_row_count := 0;

               end if ;
     END LOOP ;


     x_err_stack    := l_old_err_stack ;
 EXCEPTION
  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error then
       RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
    pa_debug.debug('Error Procedure Name  := PA_PURGE_BILLING.PA_RetnInvDetails' );
    pa_debug.debug('Error stage is '||x_err_stage );
    pa_debug.debug('Error stack is '||x_err_stack );
    pa_debug.debug(SQLERRM);
    PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM ;

    /* ATG NOCOPY changes */
      x_err_stack    := l_old_err_stack ;


    RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

 end PA_RetnInvDetails;

-- Start of comments
-- API name         : PA_MC_DRAFTREVENUES
-- Type             : Private
-- Pre-reqs         : None
-- Function         : Archive and Purge data for table Pa_MC_Draft_Revs_AR
-- Parameters       : See common list above
-- End of comments
 procedure PA_MC_DraftRevenues
                            ( p_purge_batch_id         IN NUMBER,
                              p_project_id             IN NUMBER,
                              p_txn_to_date            IN DATE,
                              p_purge_release          IN VARCHAR2,
                              p_mcnoofrecordsins      OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                              x_err_code           IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                              x_err_stack          IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              x_err_stage          IN OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                            )    is

     l_old_err_stage         VARCHAR2(2000);
     l_old_err_stack         VARCHAR2(2000);

 begin


     l_old_err_stack := x_err_stack;

     x_err_stack := x_err_stack || ' ->Entering PA_MC_DRAFTREVENUES ';

     pa_debug.debug(x_err_stack);

     pa_debug.debug( ' ->Before insert into Pa_MC_Draft_Revs_AR') ;

      /* Commented out for MRC migration to SLA   insert into Pa_MC_Draft_Revs_AR
         (
               Purge_Batch_Id,
               Purge_Release,
               Purge_Project_Id,
               Set_Of_Books_Id,
               Project_Id,
               Draft_Revenue_Num,
               Transfer_Status_Code,
               Request_Id,
               Program_Application_Id,
               Program_Id,
               Program_Update_Date,
               Transferred_Date,
               Transfer_Rejection_Reason,
               Unbilled_Receivable_Dr,
               Unearned_Revenue_Cr,
               Unbilled_Batch_Name,
               Unearned_Batch_Name,
               Last_Update_Date,
               Last_Updated_By,
               Last_Update_Login,
	       REALIZED_GAINS_AMOUNT,
 	       REALIZED_LOSSES_AMOUNT,
 	       REALIZED_GAINS_BATCH_NAME,
 	       REALIZED_LOSSES_BATCH_NAME
         )
         select
	       p_purge_batch_id,
               p_purge_release,
               p_project_id,
               mc.Set_Of_Books_Id,
               mc.Project_Id,
               mc.Draft_Revenue_Num,
               mc.Transfer_Status_Code,
               mc.Request_Id,
               mc.Program_Application_Id,
               mc.Program_Id,
               mc.Program_Update_Date,
               mc.Transferred_Date,
               mc.Transfer_Rejection_Reason,
               mc.Unbilled_Receivable_Dr,
               mc.Unearned_Revenue_Cr,
               mc.Unbilled_Batch_Name,
               mc.Unearned_Batch_Name,
               mc.Last_Update_Date,
               mc.Last_Updated_By,
               mc.Last_Update_Login,
	       mc.REALIZED_GAINS_AMOUNT,
 	       mc.REALIZED_LOSSES_AMOUNT,
 	       mc.REALIZED_GAINS_BATCH_NAME,
 	       mc.REALIZED_LOSSES_BATCH_NAME
         from Pa_MC_Draft_Revs_All mc,
              PA_Draft_Revenues_AR ar
         where ar.Purge_Project_Id  = p_project_id
         and   mc.Project_Id        = ar.Purge_Project_Id
         and   mc.Draft_Revenue_Num = ar.Draft_Revenue_Num;

*/
     p_mcnoofrecordsins :=  SQL%ROWCOUNT ;

     pa_debug.debug( ' ->After insert into Pa_MC_Draft_Revs_AR') ;
     x_err_stack    := l_old_err_stack ;

 EXCEPTION
  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error then
       RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
    pa_debug.debug('Error Procedure Name  := PA_PURGE_BILLING.PA_MC_DRAFTREVENUES' );
    pa_debug.debug('Error stage is '||x_err_stage );
    pa_debug.debug('Error stack is '||x_err_stack );
    pa_debug.debug(SQLERRM);
    PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM ;

    /* ATG NOCOPY CHANGES */
    p_mcnoofrecordsins := NULL;
    x_err_stack    := l_old_err_stack ;

    RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

 end PA_MC_DRAFTREVENUES;

-- Start of comments
-- API name         : PA_DraftRevenues
-- Type             : Private
-- Pre-reqs         : None
-- Function         : Archive and Purge data for table PA_DRAFT_REVENUES_ALL
-- Parameters       : See common list above
-- End of comments
 procedure PA_DraftRevenues
                            ( p_purge_batch_id         IN NUMBER,
                              p_project_id             IN NUMBER,
                              p_txn_to_date            IN DATE,
                              p_purge_release          IN VARCHAR2,
                              p_archive_flag           IN VARCHAR2,
                              p_commit_size            IN NUMBER,
                              x_err_code           IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                              x_err_stack          IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              x_err_stage          IN OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                            )    is

     l_old_err_stage         VARCHAR2(2000);
     l_old_err_stack         VARCHAR2(2000);
     l_NoOfRecordsIns        NUMBER:= 0;  --Initialized to zero for bug 3583748
     l_NoOfRecordsDel        NUMBER:= 0;  --Initialized to zero for bug 3583748
     l_MC_NoOfRecordsIns     NUMBER := NULL;
     l_MC_NoOfRecordsDel     NUMBER := NULL;
 begin

     l_old_err_stack := x_err_stack;

     x_err_stack := x_err_stack || ' ->Entering PA_DRAFTREVENUES' ;

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

     pa_debug.debug( ' ->Before insert into PA_Draft_Revenues_AR') ;
                     insert into PA_Draft_Revenues_AR (
			       PURGE_BATCH_ID,
                               PURGE_RELEASE,
                               PURGE_PROJECT_ID,
                               LAST_UPDATE_LOGIN,
                               RESOURCE_ACCUMULATED_FLAG,
                               ORG_ID,
                               PROJECT_ID,
                               DRAFT_REVENUE_NUM,
                               LAST_UPDATE_DATE,
                               LAST_UPDATED_BY,
                               CREATION_DATE,
                               CREATED_BY,
                               AGREEMENT_ID,
                               TRANSFER_STATUS_CODE,
                               GENERATION_ERROR_FLAG,
                               PA_DATE,
                               REQUEST_ID,
                               PROGRAM_APPLICATION_ID,
                               PROGRAM_ID,
                               PROGRAM_UPDATE_DATE,
                               CUSTOMER_BILL_SPLIT,
                               ACCRUE_THROUGH_DATE,
                               RELEASED_DATE,
                               TRANSFERRED_DATE,
                               TRANSFER_REJECTION_REASON,
                               UNBILLED_RECEIVABLE_DR,
                               UNEARNED_REVENUE_CR,
                               UNBILLED_CODE_COMBINATION_ID,
                               UNEARNED_CODE_COMBINATION_ID,
                               UNBILLED_BATCH_NAME,
                               UNEARNED_BATCH_NAME,
                               GL_DATE,
                               ACCUMULATED_FLAG,
                               DRAFT_REVENUE_NUM_CREDITED,
				GL_PERIOD_NAME,
				PA_PERIOD_NAME,
				ADJUSTING_REVENUE_FLAG,
				UBR_SUMMARY_ID,
				UER_SUMMARY_ID,
				UBR_UER_PROCESS_FLAG,
				PJI_SUMMARIZED_FLAG,
			        REALIZED_GAINS_AMOUNT,
 				REALIZED_LOSSES_AMOUNT,
 				REALIZED_GAINS_CCID,
 			        REALIZED_LOSSES_CCID,
 				REALIZED_GAINS_BATCH_NAME,
 				REALIZED_LOSSES_BATCH_NAME
                           )
                       select
                               p_purge_batch_id,
                               p_purge_release,
                               p_project_id,
                               LAST_UPDATE_LOGIN,
                               RESOURCE_ACCUMULATED_FLAG,
                               ORG_ID,
                               PROJECT_ID,
                               DRAFT_REVENUE_NUM,
                               LAST_UPDATE_DATE,
                               LAST_UPDATED_BY,
                               CREATION_DATE,
                               CREATED_BY,
                               AGREEMENT_ID,
                               TRANSFER_STATUS_CODE,
                               GENERATION_ERROR_FLAG,
                               PA_DATE,
                               REQUEST_ID,
                               PROGRAM_APPLICATION_ID,
                               PROGRAM_ID,
                               PROGRAM_UPDATE_DATE,
                               CUSTOMER_BILL_SPLIT,
                               ACCRUE_THROUGH_DATE,
                               RELEASED_DATE,
                               TRANSFERRED_DATE,
                               TRANSFER_REJECTION_REASON,
                               UNBILLED_RECEIVABLE_DR,
                               UNEARNED_REVENUE_CR,
                               UNBILLED_CODE_COMBINATION_ID,
                               UNEARNED_CODE_COMBINATION_ID,
                               UNBILLED_BATCH_NAME,
                               UNEARNED_BATCH_NAME,
                               GL_DATE,
                               ACCUMULATED_FLAG,
                               DRAFT_REVENUE_NUM_CREDITED,
				GL_PERIOD_NAME,
				PA_PERIOD_NAME,
				ADJUSTING_REVENUE_FLAG,
				UBR_SUMMARY_ID,
				UER_SUMMARY_ID,
				UBR_UER_PROCESS_FLAG,
				PJI_SUMMARIZED_FLAG,
			        REALIZED_GAINS_AMOUNT,
 				REALIZED_LOSSES_AMOUNT,
 				REALIZED_GAINS_CCID,
 			        REALIZED_LOSSES_CCID,
 				REALIZED_GAINS_BATCH_NAME,
 				REALIZED_LOSSES_BATCH_NAME
                       from pa_draft_revenues_all
                       where (
			      project_id = p_project_id
                              and rownum <= l_commit_size
                             ) ;

                     l_NoOfRecordsIns :=  SQL%ROWCOUNT ;
     pa_debug.debug( ' ->After insert into PA_Draft_Revenues_AR') ;

                     if l_NoOfRecordsIns > 0 then
                         -- First call the MRC procedure to archive the MC table
                         -- We have a seperate delete statement if the archive option is
                         -- selected because if archive option is selected the the records
                         -- being purged will be those records which are already archived.
                         -- table and

                        PA_MC_DraftRevenues
                           (    p_purge_batch_id             => p_purge_batch_id,
                                p_project_id                 => p_project_id,
                                p_txn_to_date                => p_txn_to_date,
                                p_purge_release              => p_purge_release,
                                p_mcnoofrecordsins           => l_MC_NoOfRecordsIns,
                                x_err_code                   => x_err_code,
                                x_err_stack                  => x_err_stack,
                                x_err_stage                  => x_err_stage
                            ) ;

                         pa_debug.debug( ' ->Before delete from pa_draft_revenues_all ') ;
/* commented and modified as below for performance reasons. Archive Purge 11.5
                         delete from pa_draft_revenues_all dr
                          where (dr.rowid)
 				          in
                                          ( select dr1.rowid
                                              from pa_draft_revenues_all dr1,
                                                   pa_draft_revenues_ar dr2
                                             where dr2.draft_revenue_num = dr1.draft_revenue_num
					       and dr1.project_id = dr2.project_id
                                               and dr2.purge_project_id = p_project_id
                                          ) ;
*/
                         delete from pa_draft_revenues_all dr
                          where (dr.project_id, dr.draft_revenue_num) in
                                          ( select dr2.project_id, dr2.draft_revenue_num
                                              from pa_draft_revenues_ar dr2
                                             where dr2.purge_project_id = p_project_id
                                          ) ;

	   /*Code Changes for Bug No.2984871 start */
			 l_NoOfRecordsDel := SQL%ROWCOUNT ;
                         l_MC_NoOfRecordsDel  := PA_UTILS2.mrc_row_count;
	   /*Code Changes for Bug No.2984871 end */
                         pa_debug.debug( ' ->After delete from pa_draft_revenues_all ') ;

                     end if ;
               else

                     l_commit_size := pa_utils2.arpur_mrc_commit_size;

                     -- If the archive option is not selected then the delete will
                     -- be based on the commit size.

                         pa_debug.debug( ' ->Before delete from pa_draft_revenues_all ') ;
/* commented and modified as below for performance reasons. Archive Purge 11.5
                         delete from pa_draft_revenues_all dr
                          where (dr.rowid)
 				          in
                                          ( select dr1.rowid
					     from pa_draft_revenues_all dr1
                                             where dr1.project_id = p_project_id
                                             and rownum <= l_commit_size
                                          ) ;
*/

                         delete from pa_draft_revenues_all dr
                          where dr.project_id = p_project_id
                            and rownum <= l_commit_size;

	   /*Code Changes for Bug No.2984871 start */
		    l_NoOfRecordsDel :=  SQL%ROWCOUNT ;
                    l_MC_NoOfRecordsDel  := PA_UTILS2.mrc_row_count;
	   /*Code Changes for Bug No.2984871 end */
                         pa_debug.debug( ' ->After delete from pa_draft_revenues_all ') ;
               end if ;

               if l_NoOfRecordsDel = 0 then
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
                                p_table_name                 => 'PA_DRAFT_REVENUES_ALL',
                                p_NoOfRecordsIns             => l_NoOfRecordsIns,
                                p_NoOfRecordsDel             => l_NoOfRecordsDel,
                                x_err_code                   => x_err_code,
                                x_err_stack                  => x_err_stack,
                                x_err_stage                  => x_err_stage,
                                p_MRC_table_name             => 'PA_MC_DRAFT_REVS_ALL',
                                p_MRC_NoOfRecordsIns         => l_MC_NoOfRecordsIns,
                                p_MRC_NoOfRecordsDel         => l_MC_NoOfRecordsDel
                                ) ;

                      PA_UTILS2.mrc_row_count := 0;

               end if ;
     END LOOP ;


     x_err_stack    := l_old_err_stack ;
 EXCEPTION
  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error then
       RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
    pa_debug.debug('Error Procedure Name  := PA_PURGE_BILLING.PA_DraftRevenues' );
    pa_debug.debug('Error stage is '||x_err_stage );
    pa_debug.debug('Error stack is '||x_err_stack );
    pa_debug.debug(SQLERRM);
    PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM ;

    /* ATG NOPCOPY changes */

     x_err_stack    := l_old_err_stack ;

    RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

 end PA_DraftRevenues ;

-- Start of comments
-- API name         : PA_DraftInvoices
-- Type             : Private
-- Pre-reqs         : None
-- Function         : Archive and Purge data for table PA_DRAFT_INVOICES_ALL
-- Parameters       : See common list above
-- End of comments
 procedure PA_DraftInvoices
                            ( p_purge_batch_id         IN NUMBER,
                              p_project_id             IN NUMBER,
                              p_txn_to_date            IN DATE,
                              p_purge_release          IN VARCHAR2,
                              p_archive_flag           IN VARCHAR2,
                              p_commit_size            IN NUMBER,
                              x_err_code           IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                              x_err_stack          IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              x_err_stage          IN OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                            )    is

     l_old_err_stage         VARCHAR2(2000);
     l_old_err_stack         VARCHAR2(2000);
     l_NoOfRecordsIns        NUMBER:= 0;  --Initialized to zero for bug 3583748
     l_NoOfRecordsDel        NUMBER:= 0;  --Initialized to zero for bug 3583748
 begin

     l_old_err_stack := x_err_stack;

     x_err_stack := x_err_stack || ' ->Entering PA_DRAFTINVOICES' ;

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

     pa_debug.debug( ' ->Before insert into PA_Draft_Invoices_AR') ;
                     insert into PA_Draft_Invoices_AR (
			       PURGE_BATCH_ID,
                               PURGE_RELEASE,
                               PURGE_PROJECT_ID,
                               SYSTEM_REFERENCE,
                               DRAFT_INVOICE_NUM_CREDITED,
                               CANCELED_FLAG,
                               CANCEL_CREDIT_MEMO_FLAG,
                               WRITE_OFF_FLAG,
                               CONVERTED_FLAG,
                               EXTRACTED_DATE,
                               LAST_UPDATE_LOGIN,
                               ATTRIBUTE_CATEGORY,
                               ATTRIBUTE1,
                               ATTRIBUTE2,
                               ATTRIBUTE3,
                               ATTRIBUTE4,
                               ATTRIBUTE5,
                               ATTRIBUTE6,
                               ATTRIBUTE7,
                               ATTRIBUTE8,
                               ATTRIBUTE9,
                               ATTRIBUTE10,
                               RETENTION_PERCENTAGE,
                               INVOICE_SET_ID,
                               ORG_ID,
                               PROJECT_ID,
                               DRAFT_INVOICE_NUM,
                               LAST_UPDATE_DATE,
                               LAST_UPDATED_BY,
                               CREATION_DATE,
                               CREATED_BY,
                               TRANSFER_STATUS_CODE,
                               GENERATION_ERROR_FLAG,
                               AGREEMENT_ID,
                               PA_DATE,
                               REQUEST_ID,
                               PROGRAM_APPLICATION_ID,
                               PROGRAM_ID,
                               PROGRAM_UPDATE_DATE,
                               CUSTOMER_BILL_SPLIT,
                               BILL_THROUGH_DATE,
                               INVOICE_COMMENT,
                               APPROVED_DATE,
                               APPROVED_BY_PERSON_ID,
                               RELEASED_DATE,
                               RELEASED_BY_PERSON_ID,
                               INVOICE_DATE,
                               RA_INVOICE_NUMBER,
                               TRANSFERRED_DATE,
                               TRANSFER_REJECTION_REASON,
                               UNEARNED_REVENUE_CR,
                               UNBILLED_RECEIVABLE_DR,
                               GL_DATE,
				INV_CURRENCY_CODE,
				INV_RATE_TYPE,
				INV_RATE_DATE,
				INV_EXCHANGE_RATE,
				BILL_TO_ADDRESS_ID,
				SHIP_TO_ADDRESS_ID,
				PRC_GENERATED_FLAG,
				RECEIVABLE_CODE_COMBINATION_ID,
				ROUNDING_CODE_COMBINATION_ID,
				UNBILLED_CODE_COMBINATION_ID,
				UNEARNED_CODE_COMBINATION_ID,
				WOFF_CODE_COMBINATION_ID,
				ACCTD_CURR_CODE,
				ACCTD_RATE_TYPE,
				ACCTD_RATE_DATE,
				ACCTD_EXCHG_RATE,
				LANGUAGE,
				CC_INVOICE_GROUP_CODE,
				CC_PROJECT_ID,
				IB_AP_TRANSFER_STATUS_CODE,
				IB_AP_TRANSFER_ERROR_CODE,
				INVPROC_CURRENCY_CODE,
				PROJFUNC_INVTRANS_RATE_TYPE,
				PROJFUNC_INVTRANS_RATE_DATE,
				PROJFUNC_INVTRANS_EX_RATE,
				PA_PERIOD_NAME,
				GL_PERIOD_NAME,
				UBR_SUMMARY_ID,
				UER_SUMMARY_ID,
				UBR_UER_PROCESS_FLAG,
				PJI_SUMMARIZED_FLAG,
				RETENTION_INVOICE_FLAG,
				RETN_CODE_COMBINATION_ID
                           )
                       select
                       	       p_purge_batch_id,
                               p_purge_release,
                               p_project_id,
                               SYSTEM_REFERENCE,
                               DRAFT_INVOICE_NUM_CREDITED,
                               CANCELED_FLAG,
                               CANCEL_CREDIT_MEMO_FLAG,
                               WRITE_OFF_FLAG,
                               CONVERTED_FLAG,
                               EXTRACTED_DATE,
                               LAST_UPDATE_LOGIN,
                               ATTRIBUTE_CATEGORY,
                               ATTRIBUTE1,
                               ATTRIBUTE2,
                               ATTRIBUTE3,
                               ATTRIBUTE4,
                               ATTRIBUTE5,
                               ATTRIBUTE6,
                               ATTRIBUTE7,
                               ATTRIBUTE8,
                               ATTRIBUTE9,
                               ATTRIBUTE10,
                               RETENTION_PERCENTAGE,
                               INVOICE_SET_ID,
                               ORG_ID,
                               PROJECT_ID,
                               DRAFT_INVOICE_NUM,
                               LAST_UPDATE_DATE,
                               LAST_UPDATED_BY,
                               CREATION_DATE,
                               CREATED_BY,
                               TRANSFER_STATUS_CODE,
                               GENERATION_ERROR_FLAG,
                               AGREEMENT_ID,
                               PA_DATE,
                               REQUEST_ID,
                               PROGRAM_APPLICATION_ID,
                               PROGRAM_ID,
                               PROGRAM_UPDATE_DATE,
                               CUSTOMER_BILL_SPLIT,
                               BILL_THROUGH_DATE,
                               INVOICE_COMMENT,
                               APPROVED_DATE,
                               APPROVED_BY_PERSON_ID,
                               RELEASED_DATE,
                               RELEASED_BY_PERSON_ID,
                               INVOICE_DATE,
                               RA_INVOICE_NUMBER,
                               TRANSFERRED_DATE,
                               TRANSFER_REJECTION_REASON,
                               UNEARNED_REVENUE_CR,
                               UNBILLED_RECEIVABLE_DR,
                               GL_DATE,
				INV_CURRENCY_CODE,
				INV_RATE_TYPE,
				INV_RATE_DATE,
				INV_EXCHANGE_RATE,
				BILL_TO_ADDRESS_ID,
				SHIP_TO_ADDRESS_ID,
				PRC_GENERATED_FLAG,
				RECEIVABLE_CODE_COMBINATION_ID,
				ROUNDING_CODE_COMBINATION_ID,
				UNBILLED_CODE_COMBINATION_ID,
				UNEARNED_CODE_COMBINATION_ID,
				WOFF_CODE_COMBINATION_ID,
				ACCTD_CURR_CODE,
				ACCTD_RATE_TYPE,
				ACCTD_RATE_DATE,
				ACCTD_EXCHG_RATE,
				LANGUAGE,
				CC_INVOICE_GROUP_CODE,
				CC_PROJECT_ID,
				IB_AP_TRANSFER_STATUS_CODE,
				IB_AP_TRANSFER_ERROR_CODE,
				INVPROC_CURRENCY_CODE,
				PROJFUNC_INVTRANS_RATE_TYPE,
				PROJFUNC_INVTRANS_RATE_DATE,
				PROJFUNC_INVTRANS_EX_RATE,
				PA_PERIOD_NAME,
				GL_PERIOD_NAME,
				UBR_SUMMARY_ID,
				UER_SUMMARY_ID,
				UBR_UER_PROCESS_FLAG,
				PJI_SUMMARIZED_FLAG,
				RETENTION_INVOICE_FLAG,
				RETN_CODE_COMBINATION_ID
       		       from pa_draft_invoices_all
                       where (
			      project_id = p_project_id
                              and rownum <= l_commit_size
                             ) ;

                     l_NoOfRecordsIns :=  SQL%ROWCOUNT ;

     pa_debug.debug( ' ->After insert into PA_Draft_Invoices_AR') ;
	               if l_NoOfRecordsIns > 0 then
                         -- We have a seperate delete statement if the archive option is
                         -- selected because if archive option is selected the the records
                         -- being purged will be those records which are already archived.
                         -- table and

                         pa_debug.debug( ' ->Before delete from pa_draft_invoices_all ') ;
/*  commented and modified as below for performance reasons. Archive Purge 11.5
                         delete from pa_draft_invoices_all di
                          where (di.rowid)
 				          in
                                          ( select di1.rowid
                                              from pa_draft_invoices_all di1,
                                                   pa_draft_invoices_ar di2
                                             where di2.draft_invoice_num = di1.draft_invoice_num
					       and di1.project_id = di2.project_id
                                               and di2.purge_project_id = p_project_id
                                          ) ;
*/

                         delete from pa_draft_invoices_all di
                          where (di.project_id, di.draft_invoice_num) in
					  ( select di2.project_id, di2.draft_invoice_num
                                              from pa_draft_invoices_ar di2
                                             where di2.purge_project_id = p_project_id
                                          ) ;

                         pa_debug.debug( ' ->After delete from pa_draft_invoices_all ') ;

                     l_NoOfRecordsDel :=  SQL%ROWCOUNT ;
                     end if ;
               else

                     l_commit_size := pa_utils2.arpur_mrc_commit_size;

                     -- If the archive option is not selected then the delete will
                     -- be based on the commit size.

                         pa_debug.debug( ' ->Before delete from pa_draft_invoices_all ') ;
/*  commented and modified as below for performance reasons. Archive Purge 11.5
                         delete from pa_draft_invoices_all di
                          where (di.rowid)
 				          in
                                          ( select di1.rowid
					     from pa_draft_invoices_all di1
                                             where di1.project_id = p_project_id
                                             and rownum <= l_commit_size
                                          ) ;
*/

                         delete from pa_draft_invoices_all di
                          where di.project_id = p_project_id
                            and rownum <= l_commit_size;

	   /*Code Changes for Bug No.2984871 start */
		    l_NoOfRecordsDel := SQL%ROWCOUNT ;
	   /*Code Changes for Bug No.2984871 end */
                         pa_debug.debug( ' ->After delete from pa_draft_invoices_all ') ;
               end if ;

               if l_NoOfRecordsDel = 0 then
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
                                p_table_name                 => 'PA_DRAFT_INVOICES_ALL',
                                p_NoOfRecordsIns             => l_NoOfRecordsIns,
                                p_NoOfRecordsDel             => l_NoOfRecordsDel,
                                x_err_code                   => x_err_code,
                                x_err_stack                  => x_err_stack,
                                x_err_stage                  => x_err_stage
                                ) ;
               end if ;
     END LOOP ;


     x_err_stack    := l_old_err_stack ;
 EXCEPTION
  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error then
       RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
    pa_debug.debug('Error Procedure Name  := PA_PURGE_BILLING.PA_DraftInvoices' );
    pa_debug.debug('Error stage is '||x_err_stage );
    pa_debug.debug('Error stack is '||x_err_stack );
    pa_debug.debug(SQLERRM);
    PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM ;

    /* ATG NOCOPY CHANGES */
     x_err_stack    := l_old_err_stack;

    RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

 end PA_DraftInvoices ;

-- Start of comments
-- API name         : PA_DistWarnings
-- Type             : Private
-- Pre-reqs         : None
-- Function         : Archive and Purge data for table PA_Distribution_Warnings
-- Parameters       : See common list above
-- End of comments
 procedure PA_DistWarnings
                            ( p_purge_batch_id         IN NUMBER,
                              p_project_id             IN NUMBER,
                              p_txn_to_date            IN DATE,
                              p_purge_release          IN VARCHAR2,
                              p_archive_flag           IN VARCHAR2,
                              p_commit_size            IN NUMBER,
                              x_err_code           IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                              x_err_stack          IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              x_err_stage          IN OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                            )    is

     l_old_err_stage        VARCHAR2(2000);
     l_old_err_stack         VARCHAR2(2000);
     l_NoOfRecordsIns        NUMBER:= 0;  --Initialized to zero for bug 3583748
     l_NoOfRecordsDel        NUMBER:= 0;  --Initialized to zero for bug 3583748
 begin

     l_old_err_stack := x_err_stack;

     x_err_stack := x_err_stack || ' ->Entering PA_DISTWARNINGS' ;

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

     pa_debug.debug( ' ->Before insert into PA_DIST_WARNINGS_AR') ;
                     insert into PA_DIST_WARNINGS_AR (
			       PURGE_BATCH_ID,
                               PURGE_RELEASE,
                               PURGE_PROJECT_ID,
                               PROJECT_ID,
                               DRAFT_REVENUE_NUM,
                               DRAFT_INVOICE_NUM,
                               LAST_UPDATE_DATE,
                               LAST_UPDATED_BY,
                               CREATION_DATE,
                               CREATED_BY,
                               LAST_UPDATE_LOGIN,
                               REQUEST_ID,
                               PROGRAM_APPLICATION_ID,
                               PROGRAM_ID,
                               PROGRAM_UPDATE_DATE,
                               WARNING_MESSAGE,
                               WARNING_MESSAGE_CODE,
			       agreement_id,
			       task_id
                           )
                       select
       			       p_purge_batch_id,
                               p_purge_release,
                               p_project_id,
                               PROJECT_ID,
                               DRAFT_REVENUE_NUM,
                               DRAFT_INVOICE_NUM,
                               LAST_UPDATE_DATE,
                               LAST_UPDATED_BY,
                               CREATION_DATE,
                               CREATED_BY,
                               LAST_UPDATE_LOGIN,
                               REQUEST_ID,
                               PROGRAM_APPLICATION_ID,
                               PROGRAM_ID,
                               PROGRAM_UPDATE_DATE,
                               WARNING_MESSAGE,
                               WARNING_MESSAGE_CODE,
			       AGREEMENT_ID,
			       TASK_ID
                       from pa_distribution_warnings dw
                       where (
			      dw.project_id = p_project_id
                              and rownum <= l_commit_size
                             ) ;

                     l_NoOfRecordsIns := SQL%ROWCOUNT ;
     pa_debug.debug( ' ->After insert into PA_DIST_WARNINGS_AR') ;

   /*Code Changes for Bug No.2984871 start */
		     if l_NoOfRecordsIns > 0 then
   /*Code Changes for Bug No.2984871 end */
			 -- We have a seperate delete statement if the archive option is
                         -- selected because if archive option is selected the the records
                         -- being purged will be those records which are already archived.
                         -- table and

                         pa_debug.debug( ' ->Before delete from pa_distribution_warnings ') ;
/*  commented and modified as below for performance reasons. Archive Purge 11.5
                         delete from pa_distribution_warnings dw
                          where (dw.rowid)
 				          in
                                          ( select dw1.rowid
                                              from pa_distribution_warnings dw1,
                                                   PA_DIST_WARNINGS_AR dw2
                                             where dw1.project_id = dw2.project_id
                                               and dw2.purge_project_id = p_project_id
					       and nvl(dw1.draft_revenue_num,-99)
						          = nvl(dw2.draft_revenue_num,-99)
					       and nvl(dw1.draft_invoice_num,-99)
							  = nvl(dw2.draft_invoice_num, -99)
                                          ) ;
*/

                         delete from pa_distribution_warnings dw
                          where (dw.project_id) in
                                          ( select dw2.project_id
                                              from PA_DIST_WARNINGS_AR dw2
                                             where dw2.purge_project_id = p_project_id
					       and nvl(dw.draft_revenue_num,-99)
						          = nvl(dw2.draft_revenue_num,-99)
					       and nvl(dw.draft_invoice_num,-99)
							  = nvl(dw2.draft_invoice_num, -99)
                                          )
			and dw.project_id = p_project_id; -- Perf Bug 2695202

		   /*Code Changes for Bug No.2984871 start */
		     l_NoOfRecordsDel :=  SQL%ROWCOUNT ;
		   /*Code Changes for Bug No.2984871 end */
			 pa_debug.debug( ' ->After delete from pa_distribution_warnings ') ;

                     end if ;
               else

                     l_commit_size := pa_utils2.arpur_mrc_commit_size;

                     -- If the archive option is not selected then the delete will
                     -- be based on the commit size.

                         pa_debug.debug( ' ->Before delete from pa_distribution_warnings ') ;
/*  commented and modified as below for performance reasons. Archive Purge 11.5
                         delete from pa_distribution_warnings dw
                          where (dw.rowid)
 				          in
                                          ( select dw1.rowid
					     from pa_distribution_warnings dw1
                                             where dw1.project_id = p_project_id
                                             and rownum <= l_commit_size
                                          ) ;
*/
                         delete from pa_distribution_warnings dw
                          where dw.project_id = p_project_id
                            and rownum <= l_commit_size;
	   /*Code Changes for Bug No.2984871 start */
		    l_NoOfRecordsDel :=  SQL%ROWCOUNT ;
	   /*Code Changes for Bug No.2984871 end */
			 pa_debug.debug( ' ->After delete from pa_distribution_warnings ') ;

               end if ;

               if l_NoOfRecordsDel = 0 then
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
                                p_table_name                 => 'PA_DISTRIBUTION_WARNINGS',
                                p_NoOfRecordsIns             => l_NoOfRecordsIns,
                                p_NoOfRecordsDel             => l_NoOfRecordsDel,
                                x_err_code                   => x_err_code,
                                x_err_stack                  => x_err_stack,
                                x_err_stage                  => x_err_stage
                                ) ;

               end if ;
     END LOOP ;


     x_err_stack    := l_old_err_stack ;
 EXCEPTION
  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error then
       RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
    pa_debug.debug('Error Procedure Name  := PA_PURGE_BILLING.PA_DistWarnings' );
    pa_debug.debug('Error stage is '||x_err_stage );
    pa_debug.debug('Error stack is '||x_err_stack );
    pa_debug.debug(SQLERRM);
    PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM ;

    /* ATG NOCOPY changes */
     x_err_stack    := l_old_err_stack ;


    RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

 end PA_DistWarnings ;

-- Start of comments
-- API name         : PA_BillingMessages
-- Type             : Private
-- Pre-reqs         : None
-- Function         : Archive and Purge data for table PA_Billing_Messages
-- Parameters       : See common list above
-- End of comments
 procedure PA_BillingMessages
                            ( p_purge_batch_id         IN NUMBER,
                              p_project_id             IN NUMBER,
                              p_txn_to_date            IN DATE,
                              p_purge_release          IN VARCHAR2,
                              p_archive_flag           IN VARCHAR2,
                              p_commit_size            IN NUMBER,
                              x_err_code           IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                              x_err_stack          IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              x_err_stage          IN OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                            )    is

     l_old_err_stage        VARCHAR2(2000);
     l_old_err_stack         VARCHAR2(2000);
     l_NoOfRecordsIns        NUMBER:= 0;  --Initialized to zero for bug 3583748
     l_NoOfRecordsDel        NUMBER:= 0;  --Initialized to zero for bug 3583748
 begin

     l_old_err_stack := x_err_stack;

     x_err_stack := x_err_stack || ' ->Entering PA_BillingMessages' ;

     pa_debug.debug(x_err_stack);

     LOOP
     l_NoOfRecordsDel := 0;  -- Value of l_NoOfRecordsDel is reset for BUg 4104133
      l_NoOfRecordsIns := 0;  -- Value of l_NoOfRecordsIns is reset for BUg 4104133
               if p_archive_flag = 'Y' then
                     -- If archive option is selected then the records are
                     -- inserted into the archived into the archive tables
                     -- before being purged. The where condition is such that
                     -- only the it inserts half the no. of records specified
                     -- in the commit size.

                     l_commit_size := pa_utils2.arpur_mrc_commit_size / 2 ;

     pa_debug.debug( ' ->Before insert into PA_Billing_Messages_AR') ;
                     insert into PA_Billing_Messages_AR (
			         PURGE_BATCH_ID,
                                 PURGE_RELEASE,
                                 PURGE_PROJECT_ID,
				 INSERTING_PROCEDURE_NAME,
				 BILLING_ASSIGNMENT_ID,
				 PROJECT_ID,
				 TASK_ID,
				 CALLING_PROCESS,
				 CALLING_PLACE,
				 REQUEST_ID,
				 MESSAGE,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_LOGIN,
				 ATTRIBUTE1,
				 ATTRIBUTE2,
				 ATTRIBUTE3,
				 ATTRIBUTE4,
				 ATTRIBUTE5,
				 ATTRIBUTE6,
				 ATTRIBUTE7,
				 ATTRIBUTE8,
				 ATTRIBUTE9,
				 ATTRIBUTE10,
				 ATTRIBUTE11,
				 ATTRIBUTE12,
				 ATTRIBUTE13,
				 ATTRIBUTE14,
				 ATTRIBUTE15,
				 LINE_NUM,
				 PROGRAM_APPLICATION_ID,
				 PROGRAM_ID,
				 PROGRAM_UPDATE_DATE
                           )
                       select
       			         p_purge_batch_id,
                                 p_purge_release,
                                 p_project_id,
                                 INSERTING_PROCEDURE_NAME,
                                 BILLING_ASSIGNMENT_ID,
                                 PROJECT_ID,
                                 TASK_ID,
                                 CALLING_PROCESS,
                                 CALLING_PLACE,
                                 REQUEST_ID,
                                 MESSAGE,
                                 LAST_UPDATE_DATE,
                                 LAST_UPDATED_BY,
                                 CREATION_DATE,
                                 CREATED_BY,
                                 LAST_UPDATE_LOGIN,
                                 ATTRIBUTE1,
                                 ATTRIBUTE2,
                                 ATTRIBUTE3,
                                 ATTRIBUTE4,
                                 ATTRIBUTE5,
                                 ATTRIBUTE6,
                                 ATTRIBUTE7,
                                 ATTRIBUTE8,
                                 ATTRIBUTE9,
                                 ATTRIBUTE10,
                                 ATTRIBUTE11,
                                 ATTRIBUTE12,
                                 ATTRIBUTE13,
                                 ATTRIBUTE14,
                                 ATTRIBUTE15,
                                 LINE_NUM,
                                 PROGRAM_APPLICATION_ID,
                                 PROGRAM_ID,
                                 PROGRAM_UPDATE_DATE
                       from pa_billing_messages bm
                       where (
			      bm.project_id = p_project_id
                              and rownum <= l_commit_size
                             ) ;
	   /*Code Changes for Bug No.2984871 start */
                     l_NoOfRecordsIns := SQL%ROWCOUNT ;
	   /*Code Changes for Bug No.2984871 end */

     pa_debug.debug( ' ->After insert into pa_billing_messages_AR') ;

	/* Commented for Bug 2984871
                     if SQL%ROWCOUNT > 0 then	*/

	   /*Code Changes for Bug No.2984871 start */
		     if l_NoOfRecordsIns > 0 then
	   /*Code Changes for Bug No.2984871 end */
			 -- We have a seperate delete statement if the archive option is
                         -- selected because if archive option is selected the the records
                         -- being purged will be those records which are already archived.
                         -- table and

                         pa_debug.debug( ' ->Before delete from pa_billing_messages ') ;
/*  commented and modified as below for performance reasons. Archive Purge 11.5
                         delete from pa_billing_messages bm
                          where (bm.rowid)
 				          in
                                          ( select bm1.rowid
                                              from pa_billing_messages bm1,
						   pa_billing_messages_ar bm2
                                             where bm2.purge_project_id = p_project_id
					       and bm1.project_id = bm2.project_id
                                          ) ;
*/
                         delete from pa_billing_messages bm
                          where (bm.project_id) in
                                          ( select bm2.project_id
                                              from pa_billing_messages_ar bm2
                                             where bm2.purge_project_id = p_project_id
                                          ) ;
	   /*Code Changes for Bug No.2984871 start */
		     l_NoOfRecordsDel :=  SQL%ROWCOUNT ;
	   /*Code Changes for Bug No.2984871 end */
			 pa_debug.debug( ' ->After delete from pa_billing_messages ') ;

                     end if ;
               else

                     l_commit_size := pa_utils2.arpur_mrc_commit_size;

                     -- If the archive option is not selected then the delete will
                     -- be based on the commit size.

                         pa_debug.debug( ' ->Before delete from pa_billing_messages ') ;

/* commented and modified as below for performance reasons. Archive Purge 11.5
                         delete from pa_billing_messages bm
                          where (bm.rowid)
 				          in
                                          ( select bm1.rowid
					     from pa_billing_messages bm1
                                             where bm1.project_id = p_project_id
                                             and rownum <= l_commit_size
                                          ) ;
*/
                         delete from pa_billing_messages bm
                          where bm.project_id = p_project_id
                            and rownum <= l_commit_size;

	   /*Code Changes for Bug No.2984871 start */
                    l_NoOfRecordsDel :=  SQL%ROWCOUNT ;
	   /*Code Changes for Bug No.2984871 end */
			 pa_debug.debug( ' ->After delete from pa_billing_messages ') ;

               end if ;

               if l_NoOfRecordsDel = 0 then
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
                                p_table_name                 => 'PA_BILLING_MESSAGES',
                                p_NoOfRecordsIns             => l_NoOfRecordsIns,
                                p_NoOfRecordsDel             => l_NoOfRecordsDel,
                                x_err_code                   => x_err_code,
                                x_err_stack                  => x_err_stack,
                                x_err_stage                  => x_err_stage
                                ) ;

               end if ;
     END LOOP ;


     x_err_stack    := l_old_err_stack ;
 EXCEPTION
  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error then
       RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
    pa_debug.debug('Error Procedure Name  := PA_PURGE_BILLING.PA_BillingMessages' );
    pa_debug.debug('Error stage is '||x_err_stage );
    pa_debug.debug('Error stack is '||x_err_stack );
    pa_debug.debug(SQLERRM);
    PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM ;

    /* ATG NOCOPY changes */
    x_err_stack    := l_old_err_stack ;

    RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

 end PA_BillingMessages;

-- Start of comments
-- API name         : PA_Billing_Main_Purge
-- Type             : Public
-- Pre-reqs         : None
-- Function         : Main purge procedure for billing tables.
--                    Calls a seperate procedure to purge each billing table
-- Parameters       :
--        l            p_purge_batch_id  -> Purge batch Id
--                     p_project_id      -> Project Id
--                     p_purge_release   -> The release during which it is
--                                          purged
--                     p_archive_flag    -> This flag will indicate if the
--                                          records need to be archived
--                                          before they are purged.
--                     p_txn_to_date     -> Date through which the transactions
--                                          need to be purged. This value will
--                                          be NULL if the purge batch is for
--                                          active projects.
--                     p_commit_size     -> The maximum number of records that
--                                          can be allowed to remain uncommited.
--                                          If the number of records processed
--                                          goes byond this number then the
--                                          process is commited.
-- End of comments

 procedure pa_billing_main_purge ( p_purge_batch_id                 in NUMBER,
                                   p_project_id                     in NUMBER,
                                   p_purge_release                  in VARCHAR2,
                                   p_txn_to_date                    in DATE,
                                   p_archive_flag                   in VARCHAR2,
                                   p_commit_size                    in NUMBER,
                                   x_err_stack                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                   x_err_stage                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                   x_err_code                       in OUT NOCOPY NUMBER ) is --File.Sql.39 bug 4440895

      l_old_err_stack      VARCHAR2(2000);

 BEGIN
     l_old_err_stack := x_err_stack;
     PA_UTILS2.mrc_row_count := 0;

     x_err_stack := x_err_stack || ' ->Before call to purge the data ';

     -- Call the procedures to archive/purge data for each billing table
     --
        pa_debug.debug('*-> About to purge CRDLs ') ;
        pa_purge_billing.PA_CustRevDistLines
				         (p_purge_batch_id => p_purge_batch_id,
                                          p_project_id     => p_project_id,
                                          p_txn_to_date    => p_txn_to_date,
                                          p_purge_release  => p_purge_release,
                                          p_archive_flag   => p_archive_flag,
                                          p_commit_size    => p_commit_size,
                                          x_err_code       => x_err_code,
                                          x_err_stack      => x_err_stack,
                                          x_err_stage      => x_err_stage
                                         ) ;

        pa_debug.debug('*-> About to purge ERDLs ') ;
        pa_purge_billing.PA_EventRevDistLines
				         (p_purge_batch_id => p_purge_batch_id,
                                          p_project_id     => p_project_id,
                                          p_txn_to_date    => p_txn_to_date,
                                          p_purge_release  => p_purge_release,
                                          p_archive_flag   => p_archive_flag,
                                          p_commit_size    => p_commit_size,
                                          x_err_code       => x_err_code,
                                          x_err_stack      => x_err_stack,
                                          x_err_stage      => x_err_stage
                                         ) ;

        pa_debug.debug('*-> About to purge Events ') ;
        pa_purge_billing.PA_Event
				         (p_purge_batch_id => p_purge_batch_id,
                                          p_project_id     => p_project_id,
                                          p_txn_to_date    => p_txn_to_date,
                                          p_purge_release  => p_purge_release,
                                          p_archive_flag   => p_archive_flag,
                                          p_commit_size    => p_commit_size,
                                          x_err_code       => x_err_code,
                                          x_err_stack      => x_err_stack,
                                          x_err_stage      => x_err_stage
                                         ) ;

        pa_debug.debug('*-> About to purge Draft Revenue Items ') ;
        pa_purge_billing.PA_DraftRevItems
				         (p_purge_batch_id => p_purge_batch_id,
                                          p_project_id     => p_project_id,
                                          p_txn_to_date    => p_txn_to_date,
                                          p_purge_release  => p_purge_release,
                                          p_archive_flag   => p_archive_flag,
                                          p_commit_size    => p_commit_size,
                                          x_err_code       => x_err_code,
                                          x_err_stack      => x_err_stack,
                                          x_err_stage      => x_err_stage
                                         ) ;

        pa_debug.debug('*-> About to purge Draft Invoice Items ') ;
        pa_purge_billing.PA_DraftInvItems
				         (p_purge_batch_id => p_purge_batch_id,
                                          p_project_id     => p_project_id,
                                          p_txn_to_date    => p_txn_to_date,
                                          p_purge_release  => p_purge_release,
                                          p_archive_flag   => p_archive_flag,
                                          p_commit_size    => p_commit_size,
                                          x_err_code       => x_err_code,
                                          x_err_stack      => x_err_stack,
                                          x_err_stage      => x_err_stage
                                         ) ;

        pa_debug.debug('*-> About to purge Draft Revenues ') ;
        pa_purge_billing.PA_DraftRevenues
				         (p_purge_batch_id => p_purge_batch_id,
                                          p_project_id     => p_project_id,
                                          p_txn_to_date    => p_txn_to_date,
                                          p_purge_release  => p_purge_release,
                                          p_archive_flag   => p_archive_flag,
                                          p_commit_size    => p_commit_size,
                                          x_err_code       => x_err_code,
                                          x_err_stack      => x_err_stack,
                                          x_err_stage      => x_err_stage
                                         ) ;

        pa_debug.debug('*-> About to purge Draft Invoices ') ;
        pa_purge_billing.PA_DraftInvoices
				         (p_purge_batch_id => p_purge_batch_id,
                                          p_project_id     => p_project_id,
                                          p_txn_to_date    => p_txn_to_date,
                                          p_purge_release  => p_purge_release,
                                          p_archive_flag   => p_archive_flag,
                                          p_commit_size    => p_commit_size,
                                          x_err_code       => x_err_code,
                                          x_err_stack      => x_err_stack,
                                          x_err_stage      => x_err_stage
                                         ) ;

        pa_debug.debug('*-> About to purge distribution warnings ');
        pa_purge_billing.PA_DistWarnings
				         (p_purge_batch_id => p_purge_batch_id,
                                          p_project_id     => p_project_id,
                                          p_txn_to_date    => p_txn_to_date,
                                          p_purge_release  => p_purge_release,
                                          p_archive_flag   => p_archive_flag,
                                          p_commit_size    => p_commit_size,
                                          x_err_code       => x_err_code,
                                          x_err_stack      => x_err_stack,
                                          x_err_stage      => x_err_stage
                                         ) ;

        pa_debug.debug('*-> About to purge billing messages ');
        pa_purge_billing.PA_BillingMessages
                                         (p_purge_batch_id => p_purge_batch_id,
                                          p_project_id     => p_project_id,
                                          p_txn_to_date    => p_txn_to_date,
                                          p_purge_release  => p_purge_release,
                                          p_archive_flag   => p_archive_flag,
                                          p_commit_size    => p_commit_size,
                                          x_err_code       => x_err_code,
                                          x_err_stack      => x_err_stack,
                                          x_err_stage      => x_err_stage
                                         ) ;

        pa_debug.debug('*-> About to purge retention details ');
        pa_purge_billing.PA_RetnInvDetails
				    ( p_purge_batch_id     => p_purge_batch_id,
				      p_project_id         => p_project_id,
				      p_txn_to_date        => p_txn_to_date,
				      p_purge_release      => p_purge_release,
				      p_archive_flag       => p_archive_flag,
				      p_commit_size        => p_commit_size,
				      x_err_code           => x_err_code,
				      x_err_stack          => x_err_stack,
				      x_err_stage          => x_err_stage
				    );

      x_err_stack := l_old_err_stack;

 exception
  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error then
       RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
    pa_debug.debug('Error Procedure Name  := PA_PURGE_BILLING.pa_billing_main_purge' );
    pa_debug.debug('Error stage is '||x_err_stage );
    pa_debug.debug('Error stack is '||x_err_stack );
    pa_debug.debug(SQLERRM);
    PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM ;

    /* ATG NOCOPY changes */
     x_err_stack := l_old_err_stack;


    RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

 END pa_billing_main_purge ;


END pa_purge_billing;

/
