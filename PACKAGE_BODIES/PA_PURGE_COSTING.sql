--------------------------------------------------------
--  DDL for Package Body PA_PURGE_COSTING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PURGE_COSTING" as
/* $Header: PAXCSPRB.pls 120.4 2005/08/03 14:38:31 aaggarwa noship $ */

 -- forward declarations

    l_commit_size     NUMBER ;
    p_active_flag     VARCHAR2(1);
    g_user            NUMBER ;
    l_mrc_flag        VARCHAR2(1) := paapimp_pkg.get_mrc_flag;

-- Start of comments
-- API name         : Pa_Costing_Main_Purge
-- Type             : Public
-- Pre-reqs         : None
-- Function         : This procedure is the main purge procedure for costing
--                    tables. This procedure calls a procedure that purges
--                    each of the individual tables.
--
-- Parameters       : p_batch_id			IN     NUMBER
--                              The purge batch id for which rows have
--                              to be purged/archived.
--		      p_project_Id			IN     NUMBER,
--                              The project id for which records have
--                              to be purged/archived.
--		      p_txn_to_date			IN     DATE,
--                              If the purging is being done on projects
--                              that are active then this parameter is
--                              determine the date to which the transactions
--                              need to be purged.
--		      p_Commit_Size			IN     NUMBER,
--                              The number of records that can be allowed to
--                              remain uncommited. If the number of records
--                              goes byond this number then the process is
--                              commited.
--		      p_Archive_Flag			IN OUT VARCHAR2,
--                              This flag determines if the records need to
--                              be archived before they are purged
--		      p_Purge_Release			IN OUT VARCHAR2,
--                              The version of the application on which the
--                              purge process is run.
--		      X_Err_Stack			IN OUT VARCHAR2,
--                              Error stack
--		      X_Err_Stage		        IN OUT VARCHAR2,
--                              Stage in the procedure where error occurred
--		      X_Err_Code		        IN OUT NUMBER
--                              Error code returned from the procedure
-- End of comments

 procedure pa_costing_main_purge ( p_purge_batch_id  in NUMBER,
                                   p_project_id      in NUMBER,
                                   p_purge_release   in VARCHAR2,
                                   p_txn_to_date     in DATE,
                                   p_archive_flag    in VARCHAR2,
                                   p_commit_size     in NUMBER,
                                   x_err_stack       in OUT NOCOPY VARCHAR2,
                                   x_err_stage       in OUT NOCOPY VARCHAR2,
                                   x_err_code        in OUT NOCOPY NUMBER ) is

      l_old_err_stack        VARCHAR2(2000);
      l_err_stage            VARCHAR2(500);
      l_no_records_del       NUMBER ;
      l_no_records_ins       NUMBER ;

 BEGIN
        l_old_err_stack := x_err_stack;

    X_err_stack := 'Batch Id: '||p_purge_batch_id || 'Project Id: '||p_project_id ;
        x_err_stack := x_err_stack || ' ->Before call to purge the data ';
        g_user   := FND_PROFILE.VALUE('USER_ID') ;

        g_user  := -1 ;
        -- Call the procedure to delete CDLs

        pa_debug.debug('*-> About to purge CDLs ') ;
        x_err_stage := 'About to purge CDLs for project '||to_char(p_project_id) ;
        pa_purge_costing.PA_CostDistLines(p_purge_batch_id   => p_purge_batch_id,
                                          p_project_id       => p_project_id,
                                          p_txn_to_date      => p_txn_to_date ,
                                          p_purge_release    => p_purge_release,
                                          p_archive_flag     => p_archive_flag,
                                          p_commit_size      => p_commit_size,
                                          x_err_code         => x_err_code,
                                          x_err_stack        => x_err_stack,
                                          x_err_stage        => x_err_stage
                                         ) ;

        pa_debug.debug('*-> About to purge CCDIST lines ') ;
        x_err_stage := 'About to purge CCDIST lines for project '||to_char(p_project_id) ;
        pa_purge_costing.PA_CcDistLines(p_purge_batch_id   => p_purge_batch_id,
                                          p_project_id       => p_project_id,
                                          p_txn_to_date      => p_txn_to_date ,
                                          p_purge_release    => p_purge_release,
                                          p_archive_flag     => p_archive_flag,
                                          p_commit_size      => p_commit_size,
                                          x_err_code         => x_err_code,
                                          x_err_stack        => x_err_stack,
                                          x_err_stage        => x_err_stage
                                         ) ;

        pa_debug.debug('*-> About to purge expenditure comments ') ;
        x_err_stage := 'About to purge expenditure comments for project '||to_char(p_project_id) ;
        pa_purge_costing.PA_ExpenditureComments(p_purge_batch_id  => p_purge_batch_id,
                                                p_project_id      => p_project_id,
                                                p_txn_to_date     => p_txn_to_date ,
                                                p_purge_release   => p_purge_release,
                                                p_archive_flag    => p_archive_flag,
                                                p_commit_size     => p_commit_size,
                                                x_err_code        => x_err_code,
                                                x_err_stack       => x_err_stack,
                                                x_err_stage       => x_err_stage
                                               ) ;

        pa_debug.debug('*-> About ot purge expenditure adj acts ') ;
        x_err_stage := 'About to purge audit record for project '||to_char(p_project_id) ;
        pa_purge_costing.PA_ExpendItemAdjActivities(p_purge_batch_id  => p_purge_batch_id,
                                                    p_project_id      => p_project_id,
                                                    p_txn_to_date     => p_txn_to_date ,
                                                    p_purge_release   => p_purge_release,
                                                    p_archive_flag    => p_archive_flag,
                                                    p_commit_size     => p_commit_size,
                                                    x_err_code        => x_err_code,
                                                    x_err_stack       => x_err_stack,
                                                    x_err_stage       => x_err_stage
                                                   ) ;

        pa_debug.debug('*-> About to purge records from the denorm table');
        x_err_stage := 'About to purge records from denorm table for project '||to_char(p_project_id) ;
        pa_purge_costing.PA_EiDenorm(p_purge_batch_id  => p_purge_batch_id,
                                     p_project_id      => p_project_id,
                                     p_txn_to_date     => p_txn_to_date ,
                                     p_purge_release   => p_purge_release,
                                     p_archive_flag    => p_archive_flag,
                                     p_commit_size     => p_commit_size,
                                     x_err_code        => x_err_code,
                                     x_err_stack       => x_err_stack,
                                     x_err_stage       => x_err_stage
                                    ) ;

        pa_debug.debug('*-> About to purge expenditure items that were transferred to another item');
        x_err_stage := 'About to purge exp items transferred to another item for project '||to_char(p_project_id) ;
/*
        pa_purge_costing.PA_ExpItemsSrcPurge() ;

*/
        pa_debug.debug('*-> About to purge expenditure items that were transferred from another item ');
        x_err_stage := 'About to purge exp items transferred from another item for project '||to_char(p_project_id) ;
        pa_purge_costing.PA_ExpItemsDestPurge(p_purge_batch_id  => p_purge_batch_id,
                                              p_project_id      => p_project_id,
                                              p_txn_to_date     => p_txn_to_date ,
                                              p_purge_release   => p_purge_release,
                                              p_archive_flag    => p_archive_flag,
                                              p_commit_size     => p_commit_size,
                                              x_err_code        => x_err_code,
                                              x_err_stack       => x_err_stack,
                                              x_err_stage       => x_err_stage
                                             ) ;


        pa_debug.debug('*-> About to purge expenditure items ');
        x_err_stage := 'About to purge expenditure items of project '||to_char(p_project_id);
        pa_purge_costing.PA_ExpenditureItems(p_purge_batch_id   => p_purge_batch_id,
                                             p_project_id       => p_project_id,
                                             p_txn_to_date      => p_txn_to_date ,
                                             p_purge_release    => p_purge_release,
                                             p_archive_flag     => p_archive_flag,
                                             p_commit_size      => p_commit_size,
                                             x_err_code         => x_err_code,
                                             x_err_stack        => x_err_stack,
                                             x_err_stage        => x_err_stage
                                            ) ;

        pa_debug.debug('*-> About to purge expenditure history records of expenditures ');
        x_err_stage := 'About to purge expenditure history records of expenditures without any exp items ';
        pa_purge_costing.PA_ExpenditureHistory(p_purge_batch_id  => p_purge_batch_id,
                                               p_project_id      => p_project_id,
                                               p_txn_to_date     => p_txn_to_date ,
                                               p_purge_release   => p_purge_release,
                                               p_archive_flag    => p_archive_flag,
                                               p_commit_size     => p_commit_size,
                                               x_err_code        => x_err_code,
                                               x_err_stack       => x_err_stack,
                                               x_err_stage       => x_err_stage
                                              ) ;

    /* */
    x_err_stack := l_old_err_stack; -- Added for bug 4227589
EXCEPTION
  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error then
       RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
    x_err_stage := l_err_stage ;
    pa_debug.debug('Error Procedure Name  := PA_PURGE_COSTING.PA_COSTING_MAIN_PURGE' );
    pa_debug.debug('Error stage is '||x_err_stage );
    pa_debug.debug('Error stack is '||x_err_stack );
    pa_debug.debug(SQLERRM);
    PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM ;

    RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

 END pa_costing_main_purge ;

-- Start of comments
-- API name         : PA_CostDistLines
-- Type             : Public
-- Pre-reqs         : None
-- Function         : This procedure purges all the cost distribution lines
--
-- Parameters       : Refer to the comments of the previous procedure
--
-- End of comments

 procedure PA_CostDistLines ( p_purge_batch_id         IN NUMBER,
                              p_project_id             IN NUMBER,
                              p_txn_to_date            IN DATE,
                              p_purge_release          IN VARCHAR2,
                              p_archive_flag           IN VARCHAR2,
                              p_commit_size            IN NUMBER,
                              x_err_code           IN OUT NOCOPY  NUMBER,
                              x_err_stack          IN OUT NOCOPY  VARCHAR2,
                              x_err_stage          IN OUT NOCOPY  VARCHAR2
                            )    is

     l_old_err_stage         VARCHAR2(2000);
     l_old_err_stack         VARCHAR2(2000);
     l_NoOfRecordsIns        NUMBER;
     l_NoOfRecordsDel        NUMBER;
     l_MRC_NoOfRecordsDel    NUMBER;
     x_MRC_NoOfRecordsIns    NUMBER;
     l_commit_size           NUMBER;
     l_cdl_rowid_tab         PA_PLSQL_DATATYPES.RowIdTabTyp;
     l_cdl_rowid_tab_empty   PA_PLSQL_DATATYPES.RowIdTabTyp;
     exp_ind                 NUMBER;
     l_fetch_complete          BOOLEAN := FALSE;
     cursor cdl_open_projects is
     select cdl.rowid
     from   pa_cost_distribution_lines_all cdl,
            pa_expenditure_items_all ei
     where  cdl.expenditure_item_id = ei.expenditure_item_id
       and  ei.expenditure_item_date <= p_txn_to_date
       and  ei.project_id = p_project_id;

     cursor cdl_close_projects is
     select cdl.rowid
     from   pa_cost_distribution_lines_all cdl
     where  cdl.project_id = p_project_id;

 begin

     l_old_err_stack := x_err_stack;
     x_err_stack := x_err_stack || ' ->Before insert into Cost_Distribution_Lines_AR' ;

     /*   If mrc is enabled and being used then set the commit size based on the number
      *   of reporting currencies using PA_UTILS2.ARPUR_MRC_Commit_Size.
      *   Otherwise just set the commit using PA_UTILS2.ARPUR_Commit_Size.
      */
     IF (l_mrc_flag = 'Y') THEN
        l_commit_size := PA_UTILS2.ARPUR_MRC_Commit_Size;
     ELSE
        l_commit_size := PA_UTILS2.ARPUR_Commit_Size;
     END IF;
     IF p_txn_to_date is not null THEN
         OPEN cdl_open_projects;
     ELSE
         OPEN cdl_close_projects;
     END IF;
   LOOP
        l_NoOfRecordsIns := 0;
        l_NoOfRecordsDel := 0;
        l_cdl_rowid_tab := l_cdl_rowid_tab_empty;

        IF p_txn_to_date is not null THEN

            FETCH cdl_open_projects BULK COLLECT INTO l_cdl_rowid_tab LIMIT l_commit_size;
            IF cdl_open_projects%NOTFOUND THEN
               CLOSE cdl_open_projects;
               l_fetch_complete := TRUE;
            END IF;
        ELSE
            FETCH cdl_close_projects BULK COLLECT INTO l_cdl_rowid_tab LIMIT l_commit_size;
            IF cdl_close_projects%NOTFOUND THEN
               CLOSE cdl_close_projects;
               l_fetch_complete := TRUE;
            END IF;
        END IF;
      if l_cdl_rowid_tab.last is not null then
         if p_archive_flag = 'Y' then
                     x_err_stage := 'Before insert into Cost_Distribution_Lines_AR' ;
            FORALL exp_ind IN l_cdl_rowid_tab.FIRST .. l_cdl_rowid_tab.LAST
                     insert into PA_COST_DIST_LINES_AR
                           (
				  project_id,
				  task_id,
				  denom_currency_code,
				  denom_raw_cost,
				  denom_burdened_cost,
				  acct_currency_code,
				  acct_rate_date,
				  acct_rate_type,
				  acct_exchange_rate,
				  acct_raw_cost,
				  acct_burdened_cost,
				  project_currency_code,
				  project_rate_date,
				  project_rate_type,
				  project_exchange_rate,
				  prc_generated_flag,
				  recvr_pa_date,
				  recvr_gl_date,
				  util_summarized_flag,
				  liquidate_encum_flag,
				  encumbrance_batch_name,
				  encumbrance_type_id,
				  encum_transfer_rej_reason,
				  budget_ccid,
				  encumbrance_amount,
				  projfunc_cost_exchange_rate,
				  project_raw_cost,
				  project_burdened_cost,
				  work_type_id,
				  gl_period_name,
				  recvr_gl_period_name,
				  pa_period_name,
				  projfunc_cost_rate_type,
				  projfunc_cost_rate_date,
				  recvr_pa_period_name,
				  projfunc_currency_code,
				  system_reference4,
                             pji_summarized_flag,
                             ind_compiled_set_id,
                             line_type,
                             burdened_cost,
                             resource_accumulated_flag,
                             org_id,
                             function_transaction_code,
                             code_combination_id,
                             expenditure_item_id,
                             line_num,
                             creation_date,
                             created_by,
                             transfer_status_code,
                             amount,
                             quantity,
                             billable_flag,
                             request_id,
                             program_application_id,
                             program_id,
                             program_update_date,
                             pa_date,
                             dr_code_combination_id,
                             gl_date,
                             transferred_date,
                             transfer_rejection_reason,
                             batch_name,
                             accumulated_flag,
                             reversed_flag,
                             line_num_reversed,
                             system_reference1,
                             system_reference2,
                             system_reference3,
                             cr_code_combination_id,
			     burden_sum_rejection_code,
			     burden_sum_source_run_id,
                             purge_batch_id,
                             purge_release,
                             purge_project_id
                            ,cost_rate_sch_id
                            ,org_labor_sch_rule_id
                            ,denom_burdened_change
                            ,project_burdened_change
                            ,projfunc_burdened_change
                            ,acct_burdened_change
                            ,parent_line_num
                            ,prev_ind_compiled_set_id
			    ,si_assets_addition_flag   -- R12 change
			    ,system_reference5         -- R12 change
			    ,acct_event_id -- R12 change
			    ,acct_source_code -- R12 change
                           )
		      select	  cdl.project_id,
				  cdl.task_id,
				  cdl.denom_currency_code,
				  cdl.denom_raw_cost,
				  cdl.denom_burdened_cost,
				  cdl.acct_currency_code,
				  cdl.acct_rate_date,
				  cdl.acct_rate_type,
				  cdl.acct_exchange_rate,
				  cdl.acct_raw_cost,
				  cdl.acct_burdened_cost,
				  cdl.project_currency_code,
				  cdl.project_rate_date,
				  cdl.project_rate_type,
				  cdl.project_exchange_rate,
				  cdl.prc_generated_flag,
				  cdl.recvr_pa_date,
				  cdl.recvr_gl_date,
				  cdl.util_summarized_flag,
				  cdl.liquidate_encum_flag,
				  cdl.encumbrance_batch_name,
				  cdl.encumbrance_type_id,
				  cdl.encum_transfer_rej_reason,
				  cdl.budget_ccid,
				  cdl.encumbrance_amount,
				  cdl.projfunc_cost_exchange_rate,
				  cdl.project_raw_cost,
				  cdl.project_burdened_cost,
				  cdl.work_type_id,
				  cdl.gl_period_name,
				  cdl.recvr_gl_period_name,
				  cdl.pa_period_name,
				  cdl.projfunc_cost_rate_type,
				  cdl.projfunc_cost_rate_date,
				  cdl.recvr_pa_period_name,
				  cdl.projfunc_currency_code,
				  cdl.system_reference4,
                              cdl.pji_summarized_flag,
                              cdl.ind_compiled_set_id,
                              cdl.line_type,
                              cdl.burdened_cost,
                              cdl.resource_accumulated_flag,
                              cdl.org_id,
                              cdl.function_transaction_code,
                              cdl.code_combination_id,
                              cdl.expenditure_item_id,
                              cdl.line_num,
                              cdl.creation_date,
                              cdl.created_by,
                              cdl.transfer_status_code,
                              cdl.amount,
                              cdl.quantity,
                              cdl.billable_flag,
                              cdl.request_id,
                              cdl.program_application_id,
                              cdl.program_id,
                              cdl.program_update_date,
                              cdl.pa_date,
                              cdl.dr_code_combination_id,
                              cdl.gl_date,
                              cdl.transferred_date,
                              cdl.transfer_rejection_reason,
                              cdl.batch_name,
                              cdl.accumulated_flag,
                              cdl.reversed_flag,
                              cdl.line_num_reversed,
                              cdl.system_reference1,
                              cdl.system_reference2,
                              cdl.system_reference3,
                              cdl.cr_code_combination_id,
                              cdl.burden_sum_rejection_code,
                              cdl.burden_sum_source_run_id,
                              p_purge_batch_id,
                              p_purge_release,
                              p_project_id
                            ,cdl.cost_rate_sch_id
                            ,cdl.org_labor_sch_rule_id
                            ,cdl.denom_burdened_change
                            ,cdl.project_burdened_change
                            ,cdl.projfunc_burdened_change
                            ,cdl.acct_burdened_change
                            ,cdl.parent_line_num
                            ,cdl.prev_ind_compiled_set_id
			    ,cdl.si_assets_addition_flag   -- R12 change
			    ,cdl.system_reference5         -- R12 change
			    ,cdl.acct_event_id             -- R12 change
			    ,cdl.acct_source_code          -- R12 change
                         from pa_cost_distribution_lines_all cdl
                        where cdl.rowid = l_cdl_rowid_tab(exp_ind);

                     l_NoOfRecordsIns := SQL%ROWCOUNT ;

                      end if;


/* Commented for the bug#2405916 and moved this to inside the if SQL%ROWCOUNT > 0 condition */
/* */

                     if l_NoOfRecordsIns > 0 then
                         -- We have a seperate delete statement if the archive option is
                         -- selected because if archive option is selected the the records
                         -- being purged will be those records which are already archived.
                         -- table and

                        IF (l_mrc_flag = 'Y') THEN
                           pa_purge_costing.PA_MRCCostDistLines(
                                p_purge_batch_id,
                                p_project_id,
                                p_txn_to_date,
                                p_purge_release,
                                p_archive_flag,
                                l_commit_size,
                                x_err_code,
                                x_err_stack,
                                x_err_stage,
                                x_MRC_NoOfRecordsIns);
                        END IF;
                     END IF;
                         /* Each time thru the loop need to make sure that reset the
                          * counter tracking the number of records that deleted from
                          * the mrc table.
                          */
                         IF (l_mrc_flag = 'Y') THEN
                              pa_utils2.MRC_row_count := 0;
                         END IF;
                         x_err_stage := 'Before deleting records from pa_cost_distribution_lines_all' ;
               FORALL exp_ind in l_cdl_rowid_tab.FIRST .. l_cdl_rowid_tab.LAST
                   DELETE FROM PA_COST_DISTRIBUTION_LINES_ALL cdl
                   WHERE  CDL.rowid = l_cdl_rowid_tab(exp_ind);

			 l_NoOfRecordsDel := SQL%ROWCOUNT;
                         l_MRC_NoOfRecordsDel := pa_utils2.MRC_row_count ;

                   IF l_NoOfRecordsDel > 0 THEN
                     -- After "deleting" or "deleting and inserting" a set of records
                     -- the transaction is commited. This also creates a record in the
                     -- Pa_Purge_Project_details which will show the no. of records
                     -- that are purged from each table.

                     x_err_stage := 'PA_CostDistLines: Commiting the transaction' ;
                     pa_purge.CommitProcess(p_purge_batch_id,
                                            p_project_id,
                                            'PA_COST_DISTRIBUTION_LINES',
                                            l_NoOfRecordsIns,
                                            l_NoOfRecordsDel,
                                            x_err_code,
                                            x_err_stack,
                                            x_err_stage,
                                      /*      'PA_MC_CDL_AR',   */
					    'PA_MC_COST_DIST_LINES',
                                            x_MRC_NoOfRecordsIns,
                                            l_MRC_NoOfRecordsDel
                                            ) ;
                  end if ;
              end if;
               IF (l_fetch_complete ) THEN
                  EXIT;
               END IF;
     END LOOP ;


     x_err_stack    := l_old_err_stack ;

 EXCEPTION
  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error then
       RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
--  x_err_stage := l_err_stage ;
    pa_debug.debug('Error Procedure Name  := PA_PURGE_COSTING.PA_COSTDISTLINES' );
    pa_debug.debug('Error stage is '||x_err_stage );
    pa_debug.debug('Error stack is '||x_err_stack );
    pa_debug.debug(SQLERRM);
    PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM ;

    RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

 end PA_CostDistLines ;


-- Start of comments
-- API name         : PA_CcDistLines
-- Type             : Public
-- Pre-reqs         : None
-- Function         : This procedure purges all the cc distribution lines
--
-- Parameters       : Refer to the comments of the previous procedure
--
-- End of comments

 procedure PA_CcDistLines ( p_purge_batch_id         IN NUMBER,
                            p_project_id             IN NUMBER,
                            p_txn_to_date            IN DATE,
                            p_purge_release          IN VARCHAR2,
                            p_archive_flag           IN VARCHAR2,
                            p_commit_size            IN NUMBER,
                            x_err_code           IN OUT NOCOPY  NUMBER,
                            x_err_stack          IN OUT NOCOPY  VARCHAR2,
                            x_err_stage          IN OUT NOCOPY  VARCHAR2
                            )    is

     l_old_err_stage         VARCHAR2(2000);
     l_old_err_stack         VARCHAR2(2000);
     l_NoOfRecordsIns        NUMBER;
     l_NoOfRecordsDel        NUMBER;
     l_MRC_NoOfRecordsDel    NUMBER;
     x_MRC_NoOfRecordsIns    NUMBER;
     l_commit_size           NUMBER;
/*performance changes starts*/
     l_cc_dist_rowid_tab         PA_PLSQL_DATATYPES.RowIdTabTyp;
     l_cc_dist_rowid_tab_empty   PA_PLSQL_DATATYPES.RowIdTabTyp;
     exp_ind                      NUMBER;
     l_fetch_complete             BOOLEAN := FALSE;

	cursor c_open_cc_lines is
	select cdl1.rowid
	from   pa_expenditure_items_all ei,
	       pa_cc_dist_lines_all cdl1
	where  cdl1.expenditure_item_id = ei.expenditure_item_id
	and    ei.expenditure_item_date <= p_txn_to_date
	and    ei.project_id = p_project_id;

	cursor c_close_cc_lines is
	select cdl1.rowid
	from   pa_cc_dist_lines_all cdl1
	where  cdl1.project_id = p_project_id;

 begin

     l_old_err_stack := x_err_stack;

     x_err_stack := x_err_stack || ' ->Before insert into Cost_Distribution_Lines_AR' ;

     /*   If mrc is enabled and being used then set the commit size based on the number
      *   of reporting currencies using PA_UTILS2.ARPUR_MRC_Commit_Size.
      *   Otherwise just set the commit using PA_UTILS2.ARPUR_Commit_Size.
      */
     IF (l_mrc_flag = 'Y') THEN
        l_commit_size := PA_UTILS2.ARPUR_MRC_Commit_Size;
     ELSE
        l_commit_size := PA_UTILS2.ARPUR_Commit_Size;
     END IF;

     If p_txn_to_date is NOT NULL then
	Open  c_open_cc_lines;
     Else
	Open c_close_cc_lines;
     End If;

     LOOP
        l_NoOfRecordsIns := 0;
        l_NoOfRecordsDel := 0;
        l_cc_dist_rowid_tab:= l_cc_dist_rowid_tab_empty;

        IF p_txn_to_date is not null THEN

            FETCH c_open_cc_lines  BULK COLLECT INTO l_cc_dist_rowid_tab LIMIT l_commit_size;
            IF c_open_cc_lines%NOTFOUND THEN
               CLOSE c_open_cc_lines;
               l_fetch_complete := TRUE;
            END IF;
        ELSE
            FETCH c_close_cc_lines BULK COLLECT INTO l_cc_dist_rowid_tab LIMIT l_commit_size;
            IF c_close_cc_lines%NOTFOUND THEN
               CLOSE c_close_cc_lines;
               l_fetch_complete := TRUE;
            END IF;
        END IF;
             If l_cc_dist_rowid_tab.last is not null Then
               if p_archive_flag = 'Y' then
                     x_err_stage := 'Before insert into Cc_Dist_Lines_AR' ;
		FORALL  exp_ind In l_cc_dist_rowid_tab.FIRST .. l_cc_dist_rowid_tab.LAST
                     insert into PA_Cc_Dist_Lines_AR
                           ( PURGE_BATCH_ID,
                             PURGE_RELEASE,
                             PURGE_PROJECT_ID,
                             CC_DIST_LINE_ID,
                             EXPENDITURE_ITEM_ID,
                             LINE_NUM,
                             LINE_TYPE,
                             CROSS_CHARGE_CODE,
                             ACCT_CURRENCY_CODE,
                             AMOUNT,
                             PROJECT_ID,
                             TASK_ID,
                             REQUEST_ID,
                             LAST_UPDATE_DATE,
                             LAST_UPDATED_BY,
                             CREATION_DATE,
                             CREATED_BY,
                             LAST_UPDATE_LOGIN,
                             ORG_ID,
                             LINE_NUM_REVERSED,
                             DIST_LINE_ID_REVERSED,
                             REVERSED_FLAG,
                             DENOM_TP_CURRENCY_CODE,
                             DENOM_TRANSFER_PRICE,
                             ACCT_TP_RATE_TYPE,
                             ACCT_TP_RATE_DATE,
                             ACCT_TP_EXCHANGE_RATE,
                             DR_CODE_COMBINATION_ID,
                             CR_CODE_COMBINATION_ID,
                             PA_DATE,
                             GL_DATE,
                             GL_BATCH_NAME,
                             TRANSFER_STATUS_CODE,
                             TRANSFERRED_DATE,
                             TRANSFER_REJECTION_CODE,
                             MARKUP_CALC_BASE_CODE,
                             IND_COMPILED_SET_ID,
                             BILL_RATE,
                             TP_BASE_AMOUNT,
                             BILL_MARKUP_PERCENTAGE,
                             SCHEDULE_LINE_PERCENTAGE,
                             RULE_PERCENTAGE,
                             REFERENCE_1,
                             REFERENCE_2,
                             PROGRAM_APPLICATION_ID,
                             PROGRAM_ID,
                             PROGRAM_UPDATE_DATE,
                             REFERENCE_3,
                             TP_JOB_ID,
                             PROJFUNC_TP_EXCHANGE_RATE,
                             PROJFUNC_TRANSFER_PRICE,
                             TP_AMT_TYPE_CODE,
                             PROJFUNC_TP_RATE_TYPE,
                             PROJFUNC_TP_RATE_DATE,
                             GL_PERIOD_NAME,
                             PA_PERIOD_NAME,
                             PROJECT_TP_CURRENCY_CODE,
                             PROJECT_TP_RATE_DATE,
                             PROJECT_TP_RATE_TYPE,
                             PROJECT_TP_EXCHANGE_RATE,
                             PROJECT_TRANSFER_PRICE,
                             PROJFUNC_TP_CURRENCY_CODE,
			     ACCT_EVENT_ID -- R12 change
                           )
                      select p_purge_batch_id,
                             p_purge_release,
                             p_project_id,
                             cdl.CC_DIST_LINE_ID,
                             cdl.EXPENDITURE_ITEM_ID,
                             cdl.LINE_NUM,
                             cdl.LINE_TYPE,
                             cdl.CROSS_CHARGE_CODE,
                             cdl.ACCT_CURRENCY_CODE,
                             cdl.AMOUNT,
                             cdl.PROJECT_ID,
                             cdl.TASK_ID,
                             cdl.REQUEST_ID,
                             cdl.LAST_UPDATE_DATE,
                             cdl.LAST_UPDATED_BY,
                             cdl.CREATION_DATE,
                             cdl.CREATED_BY,
                             cdl.LAST_UPDATE_LOGIN,
                             cdl.ORG_ID,
                             cdl.LINE_NUM_REVERSED,
                             cdl.DIST_LINE_ID_REVERSED,
                             cdl.REVERSED_FLAG,
                             cdl.DENOM_TP_CURRENCY_CODE,
                             cdl.DENOM_TRANSFER_PRICE,
                             cdl.ACCT_TP_RATE_TYPE,
                             cdl.ACCT_TP_RATE_DATE,
                             cdl.ACCT_TP_EXCHANGE_RATE,
                             cdl.DR_CODE_COMBINATION_ID,
                             cdl.CR_CODE_COMBINATION_ID,
                             cdl.PA_DATE,
                             cdl.GL_DATE,
                             cdl.GL_BATCH_NAME,
                             cdl.TRANSFER_STATUS_CODE,
                             cdl.TRANSFERRED_DATE,
                             cdl.TRANSFER_REJECTION_CODE,
                             cdl.MARKUP_CALC_BASE_CODE,
                             cdl.IND_COMPILED_SET_ID,
                             cdl.BILL_RATE,
                             cdl.TP_BASE_AMOUNT,
                             cdl.BILL_MARKUP_PERCENTAGE,
                             cdl.SCHEDULE_LINE_PERCENTAGE,
                             cdl.RULE_PERCENTAGE,
                             cdl.REFERENCE_1,
                             cdl.REFERENCE_2,
                             cdl.PROGRAM_APPLICATION_ID,
                             cdl.PROGRAM_ID,
                             cdl.PROGRAM_UPDATE_DATE,
                             cdl.REFERENCE_3,
                             cdl.TP_JOB_ID,
                             cdl.PROJFUNC_TP_EXCHANGE_RATE,
                             cdl.PROJFUNC_TRANSFER_PRICE,
                             cdl.TP_AMT_TYPE_CODE,
                             cdl.PROJFUNC_TP_RATE_TYPE,
                             cdl.PROJFUNC_TP_RATE_DATE,
                             cdl.GL_PERIOD_NAME,
                             cdl.PA_PERIOD_NAME,
                             cdl.PROJECT_TP_CURRENCY_CODE,
                             cdl.PROJECT_TP_RATE_DATE,
                             cdl.PROJECT_TP_RATE_TYPE,
                             cdl.PROJECT_TP_EXCHANGE_RATE,
                             cdl.PROJECT_TRANSFER_PRICE,
                             cdl.PROJFUNC_TP_CURRENCY_CODE,
			     cdl.ACCT_EVENT_ID -- R12 change
                          from pa_cc_dist_lines_all cdl
                         where cdl.rowid = l_cc_dist_rowid_tab(exp_ind);

               l_NoOfRecordsIns := SQL%ROWCOUNT ;
             end if;


                     if l_NoOfRecordsIns > 0 then
                         -- We have a seperate delete statement if the archive option is
                         -- selected because if archive option is selected the the records
                         -- being purged will be those records which are already archived.
                         -- table and

                        IF (l_mrc_flag = 'Y') THEN
                           pa_purge_costing.PA_MRCCcDistLines(
                                p_purge_batch_id,
                                p_project_id,
                                p_txn_to_date,
                                p_purge_release,
                                p_archive_flag,
                                l_commit_size,
                                x_err_code,
                                x_err_stack,
                                x_err_stage,
                                x_MRC_NoOfRecordsIns);
                        END IF;
	            END IF;

                         /* Each time thru the loop need to make sure that reset the
                          * counter tracking the number of records that deleted from
                          * the mrc table.
                          */
                         IF (l_mrc_flag = 'Y') THEN
                              pa_utils2.MRC_row_count := 0;
                         END IF;

                    If ( p_archive_flag = 'Y' and x_MRC_NoOfRecordsIns > 0 )Then
                         x_err_stage := 'Before deleting records from PA_MC_CC_DIST_LINES_ALL' ;
                         delete from pa_mc_cc_dist_lines_all cdl
                          where (cdl.cc_dist_line_id) in
                                          ( select cdar.cc_dist_line_id
                                              from pa_mc_cc_dist_lines_ar cdar
                                             where cdar.purge_project_id = p_project_id ) ;
                         l_MRC_NoOfRecordsDel := SQL%ROWCOUNT;
                   End if;

               If ( l_mrc_flag = 'Y' and p_archive_flag <> 'Y' )Then
                     delete from pa_mc_cc_dist_lines_all cdl
                      where cdl.rowid in
                                     ( select cdl1.rowid
                                         from pa_expenditure_items_all ei,
                                              pa_mc_cc_dist_lines_all cdl1
                                        where cdl1.expenditure_item_id = ei.expenditure_item_id
                                          and ei.project_id = p_project_id
                                          and rownum < l_commit_size
                                     ) ;

		    l_MRC_NoOfRecordsDel := SQL%ROWCOUNT ;
              End If;

		FORALL  exp_ind In l_cc_dist_rowid_tab.FIRST .. l_cc_dist_rowid_tab.LAST
                     delete from pa_cc_dist_lines_all cdl
                      where cdl.rowid = l_cc_dist_rowid_tab(exp_ind);

                    l_NoOfRecordsDel := SQL%ROWCOUNT ;




   /*            if SQL%ROWCOUNT = 0 then
                     -- Once the SqlCount becomes 0, which means that there are
                     -- no more records to be purged then we exit the loop.

                     x_err_stage := 'PA_CostDistLines: No more records to archive / purge ' ;
 --                    exit ;

               else */
                     -- After "deleting" or "deleting and inserting" a set of records
                     -- the transaction is commited. This also creates a record in the
                     -- Pa_Purge_Project_details which will show the no. of records
                     -- that are purged from each table.

                     x_err_stage := 'PA_CostDistLines: Commiting the transaction' ;
                  If l_NoOfRecordsDel > 0 Then
                     pa_purge.CommitProcess(p_purge_batch_id,
                                            p_project_id,
                                            'PA_CC_DIST_LINES',
                                            l_NoOfRecordsIns,
                                            l_NoOfRecordsDel,
                                            x_err_code,
                                            x_err_stack,
                                            x_err_stage,
                                      /*    'PA_MC_CC_DIST_LINES_AR',  */
					    'PA_MC_CC_DIST_LINES',
                                            x_MRC_NoOfRecordsIns,
                                            l_MRC_NoOfRecordsDel
                                            ) ;

               end if ;
             End if;
             IF ( l_fetch_complete ) Then
                exit;
             END IF;
     END LOOP ;


     x_err_stack    := l_old_err_stack ;

 EXCEPTION
  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error then
       RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
--  x_err_stage := l_err_stage ;
    pa_debug.debug('Error Procedure Name  := PA_PURGE_COSTING.PA_CCDISTLINES' );
    pa_debug.debug('Error stage is '||x_err_stage );
    pa_debug.debug('Error stack is '||x_err_stack );
    pa_debug.debug(SQLERRM);
    PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM ;

    RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

 end PA_CcDistLines ;


-- Start of comments
-- API name         : PA_ExpenditureComments
-- Type             : Public
-- Pre-reqs         : None
-- Function         : This procedure purges all the expenditure comments
--
-- Parameters       : Refer to the comments of the previous procedure
--
-- End of comments

 procedure PA_ExpenditureComments ( p_purge_batch_id         IN NUMBER,
                                    p_project_id             IN NUMBER,
                                    p_txn_to_date            IN DATE,
                                    p_purge_release          IN VARCHAR2,
                                    p_archive_flag           IN VARCHAR2,
                                    p_commit_size            IN NUMBER,
                                    x_err_code           IN OUT NOCOPY  NUMBER,
                                    x_err_stack          IN OUT NOCOPY  VARCHAR2,
                                    x_err_stage          IN OUT NOCOPY  VARCHAR2
                                  )    is

     l_old_err_stage         VARCHAR2(2000);
     l_old_err_stack         VARCHAR2(2000);
     l_NoOfRecordsIns        NUMBER;
     l_NoOfRecordsDel        NUMBER;
/*performance changes starts*/
     l_commit_size		  NUMBER;
     l_exp_comm_rowid_tab     	  PA_PLSQL_DATATYPES.RowIdTabTyp;
     l_exp_comm_rowid_tab_empty   PA_PLSQL_DATATYPES.RowIdTabTyp;
     exp_ind                 	  NUMBER;
     l_fetch_complete          	  BOOLEAN := FALSE;

     Cursor c_open_exp_comm is
     Select ec1.rowid
     From   pa_expenditure_items_all ei,
	    pa_expenditure_comments ec1
     Where  ei.expenditure_item_id = ec1.expenditure_item_id
     And    ei.expenditure_item_date <= p_txn_to_date
     And    ei.project_id = p_project_id;

     Cursor c_close_exp_comm is
     Select ec1.rowid
     From   pa_expenditure_items_all ei,
	    pa_expenditure_comments ec1
     Where  ei.expenditure_item_id = ec1.expenditure_item_id
     And    ei.project_id = p_project_id;

 begin

     l_old_err_stack := x_err_stack;
     x_err_stack := x_err_stack || ' ->Before insert into PA_EXP_COMMENTS_AR' ;

     if p_archive_flag = 'Y' then
	     l_commit_size := p_commit_size/2  ;
     else
	     l_commit_size := p_commit_size  ;
     end if;

     If p_txn_to_date is NOT NULL then
	Open  c_open_exp_comm;
     Else
	Open c_close_exp_comm;
     End If;

     LOOP
        l_NoOfRecordsIns := 0;
        l_NoOfRecordsDel := 0;
        l_exp_comm_rowid_tab:= l_exp_comm_rowid_tab_empty;

        IF p_txn_to_date is not null THEN

            FETCH c_open_exp_comm BULK COLLECT INTO l_exp_comm_rowid_tab LIMIT l_commit_size;
            IF c_open_exp_comm%NOTFOUND THEN
               CLOSE c_open_exp_comm;
               l_fetch_complete := TRUE;
            END IF;
        ELSE
            FETCH c_close_exp_comm BULK COLLECT INTO l_exp_comm_rowid_tab LIMIT l_commit_size;
            IF c_close_exp_comm%NOTFOUND THEN
               CLOSE c_close_exp_comm;
               l_fetch_complete := TRUE;
            END IF;
        END IF;
      If l_exp_comm_rowid_tab.last is not null then
        if p_archive_flag = 'Y' then
                     -- If archive option is selected then the records are
                     -- inserted into the archived into the archive tables
                     -- before being purged. The where condition is such that
                     -- only the it inserts half the no. of records specified
                     -- in the commit size.

                     x_err_stage := 'PA_ExpenditureComments: Before inserting records into PA_EXP_COMMENTS_AR';

            FORALL exp_ind IN l_exp_comm_rowid_tab.FIRST .. l_exp_comm_rowid_tab.LAST
                     insert into PA_EXP_COMMENTS_AR
                        (
                          expenditure_item_id,
                          line_number,
                          last_update_date,
                          last_updated_by,
                          creation_date,
                          created_by,
                          expenditure_comment,
                          last_update_login,
                          request_id,
                          program_id,
                          program_application_id,
                          program_update_date ,
                          purge_batch_id,
                          purge_release,
                          purge_project_id
                        )
                       select ec.expenditure_item_id,
                              ec.line_number,
                              ec.last_update_date,
                              ec.last_updated_by,
                              ec.creation_date,
                              ec.created_by,
                              ec.expenditure_comment,
                              ec.last_update_login,
                              ec.request_id,
                              ec.program_id,
                              ec.program_application_id,
                              ec.program_update_date,
                              p_purge_batch_id,
                              p_purge_release,
                              p_project_id
                         from pa_expenditure_comments ec
                        where ec.rowid = l_exp_comm_rowid_tab(exp_ind);

                     l_NoOfRecordsIns :=  SQL%ROWCOUNT ;
         end if;  /*if p_archive_flag = 'Y' */

               FORALL exp_ind in l_exp_comm_rowid_tab.FIRST .. l_exp_comm_rowid_tab.LAST
                   DELETE FROM pa_expenditure_comments ec
                   WHERE  ec.rowid = l_exp_comm_rowid_tab(exp_ind);

                         l_NoOfRecordsDel := SQL%ROWCOUNT;
  /*  commented for performance changes
                     if SQL%ROWCOUNT > 0 then
                          -- We have a seperate delete statement if the archive option is
                          -- selected because if archive option is selected the the records
                          -- being purged will be those records which are already archived.
                          -- table and

                          x_err_stage := 'PA_ExpenditureComments: Before deleting records from pa_expenditure_comments';
                          delete from pa_expenditure_comments ec
                           where ( ec.expenditure_item_id, ec.line_number )
                                       in ( select ecar.expenditure_item_id, ecar.line_number
                                              from PA_EXP_COMMENTS_AR ecar
                                             where ecar.purge_project_id = p_project_id
                                          ) ;

                          l_NoOfRecordsDel :=  SQL%ROWCOUNT ;

                     end if;

                     l_commit_size := p_commit_size ;

                     -- If the archive option is not selected then the delete will
                     -- be based on the commit size.

                     x_err_stage := 'PA_ExpenditureComments: Before deleting records from pa_expenditure_comments' ;
                 if p_txn_to_date is NOT NULL then
                     delete from pa_expenditure_comments ec
                      where ( ec.rowid )
                                  in ( select ec1.rowid
                                         from pa_expenditure_items_all ei,
                                              pa_expenditure_comments ec1
                                        where ei.expenditure_item_id = ec1.expenditure_item_id
                                          and ei.expenditure_item_date <= p_txn_to_date
                                          and ei.project_id = p_project_id
                                          and rownum <= p_commit_size
                                      ) ;
                 else
                     delete from pa_expenditure_comments ec
                      where ( ec.rowid )
                                  in ( select ec1.rowid
                                         from pa_expenditure_items_all ei,
                                              pa_expenditure_comments ec1
                                        where ei.expenditure_item_id = ec1.expenditure_item_id
                                          and ei.project_id = p_project_id
                                          and rownum <= p_commit_size
                                      ) ;
                 end if;

                     l_NoOfRecordsDel :=  SQL%ROWCOUNT ;

  end of comment for performance changes*/

/*             if SQL%ROWCOUNT = 0 then

                  -- Once the SqlCount becomes 0, which means that there are
                  -- no more records to be purged then we exit the loop.

                  x_err_stage := 'PA_ExpenditureComments: No more records to archive / purge ' ;
                  exit ;

             else */
                  -- After "deleting" or "deleting and inserting" a set of records
                  -- the transaction is commited. This also creates a record in the
                  -- Pa_Purge_Project_details which will show the no. of records
                  -- that are purged from each table.

                  x_err_stage := 'PA_ExpenditureComments: Commiting the transaction' ;
                if l_NoOfRecordsDel > 0 Then
                  pa_purge.CommitProcess(p_purge_batch_id,
                                         p_project_id,
                                         'PA_EXPENDITURE_COMMENTS',
                                         l_NoOfRecordsIns,
                                         l_NoOfRecordsDel,
                                         x_err_code,
                                         x_err_stack,
                                         x_err_stage
                                        ) ;
                end if;

             end if ;
             If (l_fetch_complete ) Then
                exit;
             End If;
     END LOOP ;

     x_err_stack    := l_old_err_stack ;

 EXCEPTION
  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error then
       RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
--  x_err_stage := l_err_stage ;
    pa_debug.debug('Error Procedure Name  := PA_PURGE_COSTING.PA_EXPENDITURECOMMENTS' );
    pa_debug.debug('Error stage is '||x_err_stage );
    pa_debug.debug('Error stack is '||x_err_stack );
    pa_debug.debug(SQLERRM);
    PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM;

    RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

 end PA_ExpenditureComments ;

-- Start of comments
-- API name         : PA_ExpendItemAdjActivities
-- Type             : Public
-- Pre-reqs         : None
-- Function         : This procedure purges all the audit records in the
--                    audit table for expenditure items.
--
-- Parameters       : Refer to the comments of the previous procedure
--
-- End of comments

 procedure PA_ExpendItemAdjActivities ( p_purge_batch_id         IN NUMBER,
                                        p_project_id             IN NUMBER,
                                        p_txn_to_date            IN DATE,
                                        p_purge_release          IN VARCHAR2,
                                        p_archive_flag           IN VARCHAR2,
                                        p_commit_size            IN NUMBER,
                                        x_err_code           IN OUT NOCOPY  NUMBER,
                                        x_err_stack          IN OUT NOCOPY  VARCHAR2,
                                        x_err_stage          IN OUT NOCOPY  VARCHAR2
                                      )    is

     l_old_err_stage         VARCHAR2(2000);
     l_old_err_stack         VARCHAR2(2000);
     l_NoOfRecordsIns        NUMBER;
     l_NoOfRecordsDel        NUMBER;
     l_commit_size	     NUMBER;
/*performance changes starts*/
     l_exp_adj_rowid_tab         PA_PLSQL_DATATYPES.RowIdTabTyp;
     l_exp_adj_rowid_tab_empty   PA_PLSQL_DATATYPES.RowIdTabTyp;
     exp_ind                      NUMBER;
     l_fetch_complete             BOOLEAN := FALSE;

     cursor c_open_exp_adj is
     Select eia1.rowid
     from   pa_expenditure_items_all ei,
	    pa_expend_item_adj_activities eia1
     where  ei.expenditure_item_date <= p_txn_to_date
     and    ei.expenditure_item_id = eia1.expenditure_item_id
     and    ei.project_id = p_project_id;

     cursor c_close_exp_adj is
     Select eia1.rowid
     from   pa_expenditure_items_all ei,
	    pa_expend_item_adj_activities eia1
     where  ei.expenditure_item_id = eia1.expenditure_item_id
     and    ei.project_id = p_project_id;

 begin
  --s1

     --  Added for bug 4227589
     l_old_err_stack := x_err_stack;
     x_err_stack := x_err_stack || ' ->Before insert into PA_ExpendItemAdjActivities' ;

     if p_archive_flag = 'Y' then
	     l_commit_size := p_commit_size/2  ;
     else
	     l_commit_size := p_commit_size  ;
     end if;

     If p_txn_to_date is NOT NULL then
        Open  c_open_exp_adj;
     Else
        Open c_close_exp_adj;
     End If;

     LOOP
        l_NoOfRecordsIns := 0;
        l_NoOfRecordsDel := 0;
        l_exp_adj_rowid_tab:= l_exp_adj_rowid_tab_empty;

        IF p_txn_to_date is not null THEN

            FETCH c_open_exp_adj BULK COLLECT INTO l_exp_adj_rowid_tab LIMIT l_commit_size;
            IF c_open_exp_adj%NOTFOUND THEN
               CLOSE c_open_exp_adj;
               l_fetch_complete := TRUE;
            END IF;
        ELSE
            FETCH c_close_exp_adj BULK COLLECT INTO l_exp_adj_rowid_tab LIMIT l_commit_size;
            IF c_close_exp_adj%NOTFOUND THEN
               CLOSE c_close_exp_adj;
               l_fetch_complete := TRUE;
            END IF;
        END IF;


     --  Commented for bug 4227589 and moved outside LOOP
     -- l_old_err_stack := x_err_stack;
     -- x_err_stack := x_err_stack || ' ->Before insert into PA_EXP_COMMENTS_AR' ;
           If l_exp_adj_rowid_tab.last is not null Then
             if p_archive_flag = 'Y' then
                   x_err_stage := 'PA_ExpendItemAdjActivities: Before inserting records into PA_EXP_ITEM_ADJ_ACT_AR';
		FORALL exp_ind IN l_exp_adj_rowid_tab.FIRST .. l_exp_adj_rowid_tab.LAST
                   insert into PA_EXP_ITEM_ADJ_ACT_AR
                      (
                        expenditure_item_id,
                        activity_date,
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        exception_activity_code,
                        module_code,
                        description,
                        last_update_login,
                        request_id,
                        program_application_id,
                        program_id,
                        program_update_date,
                        purge_batch_id,
                        purge_release,
                        purge_project_id
                      )
                     select eia.expenditure_item_id,
                            eia.activity_date,
                            eia.last_update_date,
                            eia.last_updated_by,
                            eia.creation_date,
                            eia.created_by,
                            eia.exception_activity_code,
                            eia.module_code,
                            eia.description,
                            eia.last_update_login,
                            eia.request_id,
                            eia.program_application_id,
                            eia.program_id,
                            eia.program_update_date,
                            p_purge_batch_id,
                            p_purge_release,
                            p_project_id
                       from pa_expend_item_adj_activities eia
	              where eia.rowid = l_exp_adj_rowid_tab(exp_ind);
	     End If;  /* if p_archive_flag = 'Y' */
                    l_NoOfRecordsIns :=  SQL%ROWCOUNT ;


             x_err_stage := 'PA_ExpendItemAdjActivities: Before deleting records from pa_expend_item_adj_activities' ;

		FORALL exp_ind IN l_exp_adj_rowid_tab.FIRST .. l_exp_adj_rowid_tab.LAST
                           DELETE from pa_expend_item_adj_activities eia
                            where eia.rowid = l_exp_adj_rowid_tab(exp_ind);

         		  l_NoOfRecordsDel := SQL%ROWCOUNT;
    /*s22            start of comment for performance changes
		              ( select eia1.rowid
                                  from pa_expenditure_items_all ei,
                                       pa_expend_item_adj_activities eia1
                                 where ei.expenditure_item_date <= p_txn_to_date
                                   and ei.expenditure_item_id = eia1.expenditure_item_id
                                   and ei.project_id = p_project_id
                                   and rownum < p_commit_size
                              ) ;

       else
                      insert into PA_EXP_ITEM_ADJ_ACT_AR
                      (
                        expenditure_item_id,
                        activity_date,
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        exception_activity_code,
                        module_code,
                        description,
                        last_update_login,
                        request_id,
                        program_application_id,
                        program_id,
                        program_update_date,
                        purge_batch_id,
                        purge_release,
                        purge_project_id
                      )
                     select eia.expenditure_item_id,
                            eia.activity_date,
                            eia.last_update_date,
                            eia.last_updated_by,
                            eia.creation_date,
                            eia.created_by,
                            eia.exception_activity_code,
                            eia.module_code,
                            eia.description,
                            eia.last_update_login,
                            eia.request_id,
                            eia.program_application_id,
                            eia.program_id,
                            eia.program_update_date,
                            p_purge_batch_id,
                            p_purge_release,
                            p_project_id
                       from pa_expend_item_adj_activities eia
                      where (eia.rowid ) in
                              ( select eia1.rowid
                                  from pa_expenditure_items_all ei,
                                       pa_expend_item_adj_activities eia1
                                 where ei.expenditure_item_id = eia1.expenditure_item_id
                                   and ei.project_id = p_project_id
                                   and rownum < p_commit_size
                              ) ;
                 end if;

                    l_NoOfRecordsIns :=  SQL%ROWCOUNT ;

                    if SQL%ROWCOUNT > 0 then
                         -- We have a seperate delete statement if the archive option is
                         -- selected because if archive option is selected the the records
                         -- being purged will be those records which are already archived.
                         -- table and

                          x_err_stage := 'PA_ExpendItemAdjActivities: Before deleting records from pa_expend_item_adj_activities';
                          delete from pa_expend_item_adj_activities eia
                           where (eia.expenditure_item_id, eia.activity_date )  in
                                        ( select eiar.expenditure_item_id, eiar.activity_date
                                            from PA_EXP_ITEM_ADJ_ACT_AR eiar
                                           where eiar.purge_project_id = p_project_id
                                        ) ;

                          l_NoOfRecordsDel :=  SQL%ROWCOUNT ;

                     end if;
                else
                     l_commit_size := p_commit_size ;

                     -- If the archive option is not selected then the delete will
                     -- be based on the commit size.

                     x_err_stage := 'PA_ExpendItemAdjActivities: Before deleting records from pa_expend_item_adj_activities' ;
                  if p_txn_to_date is NOT NULL then
                     delete from pa_expend_item_adj_activities eia
                      where (eia.rowid )  in
                              ( select eia1.rowid
                                  from pa_expenditure_items_all ei,
                                       pa_expend_item_adj_activities eia1
                                 where ei.expenditure_item_date <= p_txn_to_date
                                   and ei.expenditure_item_id = eia1.expenditure_item_id
                                   and ei.project_id = p_project_id
                                   and rownum < p_commit_size
                              ) ;

                   else
                     delete from pa_expend_item_adj_activities eia
                      where (eia.rowid )  in
                              ( select eia1.rowid
                                  from pa_expenditure_items_all ei,
                                       pa_expend_item_adj_activities eia1
                                 where ei.expenditure_item_id = eia1.expenditure_item_id
                                   and ei.project_id = p_project_id
                                   and rownum < p_commit_size
                              ) ;
                   end if;

                     l_NoOfRecordsDel :=  SQL%ROWCOUNT ;

                  end if ;

    end of comment for performance changes. s3 */
                  /*if SQL%ROWCOUNT = 0 then

                          -- Once the SqlCount becomes 0, which means that there are
                          -- no more records to be purged then we exit the loop.

                          x_err_stage := 'PA_ExpendItemAdjActivities: No more records to archive / purge ' ;
                          exit ;

                  else */
                          -- After "deleting" or "deleting and inserting" a set of records
                          -- the transaction is commited. This also creates a record in the
                          -- Pa_Purge_Project_details which will show the no. of records
                          -- that are purged from each table.

                          x_err_stage := 'PA_ExpendItemAdjActivities: Commiting the transaction' ;
                       If l_NoOfRecordsDel > 0 Then
                          Pa_Purge.CommitProcess(p_purge_batch_id,
                                                 p_project_id,
                                                 'PA_EXPEND_ITEM_ADJ_ACTIVITIES',
                                                 l_NoOfRecordsIns,
                                                 l_NoOfRecordsDel,
                                                 x_err_code,
                                                 x_err_stack,
                                                 x_err_stage
                                                ) ;
                       End if;

                  end if ;
             If (l_fetch_complete) Then
                exit;
             End If;
     END LOOP ;

     x_err_stack    := l_old_err_stack ;

 EXCEPTION
  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error then
       RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
--  x_err_stage := l_err_stage ;
    pa_debug.debug('Error Procedure Name  := pa_purge_costing.PA_ExpendItemAdjActivities' );
    pa_debug.debug('Error stage is '||x_err_stage );
    pa_debug.debug('Error stack is '||x_err_stack );
    pa_debug.debug(SQLERRM);
    PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM ;

    RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

 end PA_ExpendItemAdjActivities ;

-- Start of comments
-- API name         : PA_EiDenorm
-- Type             : Public
-- Pre-reqs         : None
-- Function         : This procedure purges all the records from pa_ei_denorm
--
-- Parameters       : Refer to the comments of the previous procedure
--
-- End of comments

 --
 -- The following procedure PA_EiDenorm was coded in the extension as all the
 -- customers may not have installed the patch for Online Time and Expense entry.
 -- If the patch is not installed then the procedure is put in the regular
 -- package there will be compilation errors.

 procedure PA_EiDenorm  ( p_purge_batch_id         IN NUMBER,
                          p_project_id             IN NUMBER,
                          p_txn_to_date            IN DATE,
                          p_purge_release          IN VARCHAR2,
                          p_archive_flag           IN VARCHAR2,
                          p_commit_size            IN NUMBER,
                          x_err_code           IN OUT NOCOPY  NUMBER,
                          x_err_stack          IN OUT NOCOPY  VARCHAR2,
                          x_err_stage          IN OUT NOCOPY  VARCHAR2
                        )    is

     l_old_err_stage         VARCHAR2(2000);
     l_old_err_stack         VARCHAR2(2000);
     l_NoOfRecordsIns        NUMBER;
     l_NoOfRecordsDel        NUMBER;
 begin

 --
 -- This procedure is called by the main costing purge procedure
 -- pa_purge_costing.pa_costing_main_purge. It purges the data from
 -- Pa_Ei_Denorm. This is a new table created for Online Time and
 -- Expense(OTE) entry. Once OTE patch is installed user should
 -- uncomment these code to allow the purging of data from Pa_Ei_Denorm
 -- which is also a transaction table.

        l_old_err_stack := x_err_stack;

        x_err_stack := x_err_stack || ' ->Before insert into Pa_Ei_Denorm_AR' ;

        LOOP
                  if p_archive_flag = 'Y' then
                        -- If archive option is selected then the records are
                        -- inserted into the archived into the archive tables
                        -- before being purged. The where condition is such that
                        -- only the it inserts half the no. of records specified
                        -- in the commit size.

                        l_commit_size := p_commit_size / 2 ;

                        insert into Pa_Ei_Denorm_AR
                            (
                             Expenditure_Id,
                             Denorm_Id,
                             Person_Id,
                             Project_Id,
                             Task_Id,
                             Billable_Flag,
                             Expenditure_Type,
                             Unit_Of_Measure_Code,
                             Unit_Of_Measure,
                             Expenditure_Item_Id_1,
                             Expenditure_Item_Date_1,
                             Quantity_1,
                             System_Linkage_Function_1,
                             Non_Labor_Resource_1,
                             Organization_Id_1,
                             Override_To_Organization_Id_1,
                             Raw_Cost_1,
                             Raw_Cost_Rate_1,
                             Attribute_Category_1,
                             Attribute1_1,
                             Attribute1_2,
                             Attribute1_3,
                             Attribute1_4,
                             Attribute1_5,
                             Attribute1_6,
                             Attribute1_7,
                             Attribute1_8,
                             Attribute1_9,
                             Attribute1_10,
                             Orig_Transaction_Reference_1,
                             Adjusted_Expenditure_Item_Id_1,
                             Net_Zero_Adjustment_Flag_1,
                             Expenditure_Comment_1,
                             Expenditure_Item_Id_2,
                             Expenditure_Item_Date_2,
                             Quantity_2,
                             System_Linkage_Function_2,
                             Non_Labor_Resource_2,
                             Organization_Id_2,
                             Override_To_Organization_Id_2,
                             Raw_Cost_2,
                             Raw_Cost_Rate_2,
                             Attribute_Category_2,
                             Attribute2_1,
                             Attribute2_2,
                             Attribute2_3,
                             Attribute2_4,
                             Attribute2_5,
                             Attribute2_6,
                             Attribute2_7,
                             Attribute2_8,
                             Attribute2_9,
                             Attribute2_10,
                             Orig_Transaction_Reference_2,
                             Adjusted_Expenditure_Item_Id_2,
                             Net_Zero_Adjustment_Flag_2,
                             Expenditure_Comment_2,
                             Expenditure_Item_Id_3,
                             Expenditure_Item_Date_3,
                             Quantity_3,
                             System_Linkage_Function_3,
                             Non_Labor_Resource_3,
                             Organization_Id_3,
                             Override_To_Organization_Id_3,
                             Raw_Cost_3,
                             Raw_Cost_Rate_3,
                             Attribute_Category_3,
                             Attribute3_1,
                             Attribute3_2,
                             Attribute3_3,
                             Attribute3_4,
                             Attribute3_5,
                             Attribute3_6,
                             Attribute3_7,
                             Attribute3_8,
                             Attribute3_9,
                             Attribute3_10,
                             Orig_Transaction_Reference_3,
                             Adjusted_Expenditure_Item_Id_3,
                             Net_Zero_Adjustment_Flag_3,
                             Expenditure_Comment_3,
                             Expenditure_Item_Id_4,
                             Expenditure_Item_Date_4,
                             Quantity_4,
                             System_Linkage_Function_4,
                             Non_Labor_Resource_4,
                             Organization_Id_4,
                             Override_To_Organization_Id_4,
                             Raw_Cost_4,
                             Raw_Cost_Rate_4,
                             Attribute_Category_4,
                             Attribute4_1,
                             Attribute4_2,
                             Attribute4_3,
                             Attribute4_4,
                             Attribute4_5,
                             Attribute4_6,
                             Attribute4_7,
                             Attribute4_8,
                             Attribute4_9,
                             Attribute4_10,
                             Orig_Transaction_Reference_4,
                             Adjusted_Expenditure_Item_Id_4,
                             Net_Zero_Adjustment_Flag_4,
                             Expenditure_Comment_4,
                             Expenditure_Item_Id_5,
                             Expenditure_Item_Date_5,
                             Quantity_5,
                             System_Linkage_Function_5,
                             Non_Labor_Resource_5,
                             Organization_Id_5,
                             Override_To_Organization_Id_5,
                             Raw_Cost_5,
                             Raw_Cost_Rate_5,
                             Attribute_Category_5,
                             Attribute5_1,
                             Attribute5_2,
                             Attribute5_3,
                             Attribute5_4,
                             Attribute5_5,
                             Attribute5_6,
                             Attribute5_7,
                             Attribute5_8,
                             Attribute5_9,
                             Attribute5_10,
                             Orig_Transaction_Reference_5,
                             Adjusted_Expenditure_Item_Id_5,
                             Net_Zero_Adjustment_Flag_5,
                             Expenditure_Comment_5,
                             Expenditure_Item_Id_6,
                             Expenditure_Item_Date_6,
                             Quantity_6,
                             System_Linkage_Function_6,
                             Non_Labor_Resource_6,
                             Organization_Id_6,
                             Override_To_Organization_Id_6,
                             Raw_Cost_6,
                             Raw_Cost_Rate_6,
                             Attribute_Category_6,
                             Attribute6_1,
                             Attribute6_2,
                             Attribute6_3,
                             Attribute6_4,
                             Attribute6_5,
                             Attribute6_6,
                             Attribute6_7,
                             Attribute6_8,
                             Attribute6_9,
                             Attribute6_10,
                             Orig_Transaction_Reference_6,
                             Adjusted_Expenditure_Item_Id_6,
                             Net_Zero_Adjustment_Flag_6,
                             Expenditure_Comment_6,
                             Expenditure_Item_Id_7,
                             Expenditure_Item_Date_7,
                             Quantity_7,
                             System_Linkage_Function_7,
                             Non_Labor_Resource_7,
                             Organization_Id_7,
                             Override_To_Organization_Id_7,
                             Raw_Cost_7,
                             Raw_Cost_Rate_7,
                             Attribute_Category_7,
                             Attribute7_1,
                             Attribute7_2,
                             Attribute7_3,
                             Attribute7_4,
                             Attribute7_5,
                             Attribute7_6,
                             Attribute7_7,
                             Attribute7_8,
                             Attribute7_9,
                             Attribute7_10,
                             Orig_Transaction_Reference_7,
                             Adjusted_Expenditure_Item_Id_7,
                             Net_Zero_Adjustment_Flag_7,
                             Expenditure_Comment_7,
                             Denorm_Total_Qty,
                             Denorm_Total_Amount,
                             Created_By,
                             Creation_Date,
                             Last_Update_Date,
                             Last_Updated_By,
                             Last_Update_Login,
			     JOB_ID_1,
			     JOB_ID_2,
			     JOB_ID_3,
			     JOB_ID_4,
			     JOB_ID_5,
			     JOB_ID_6,
			     JOB_ID_7,
			     ADJUSTED_DENORM_ID,
			     BILLABLE_FLAG_1,
			     BILLABLE_FLAG_2,
			     BILLABLE_FLAG_3,
		             BILLABLE_FLAG_4,
		             BILLABLE_FLAG_5,
		             BILLABLE_FLAG_6,
			     BILLABLE_FLAG_7,
                             purge_batch_id,
                             purge_release,
                             purge_project_id
                            )
                          select eid.Expenditure_Id,
                                 eid.Denorm_Id,
                                 eid.Person_Id,
                                 eid.Project_Id,
                                 eid.Task_Id,
                                 eid.Billable_Flag,
                                 eid.Expenditure_Type,
                                 eid.Unit_Of_Measure_Code,
                                 eid.Unit_Of_Measure,
                                 eid.Expenditure_Item_Id_1,
                                 eid.Expenditure_Item_Date_1,
                                 eid.Quantity_1,
                                 eid.System_Linkage_Function_1,
                                 eid.Non_Labor_Resource_1,
                                 eid.Organization_Id_1,
                                 eid.Override_To_Organization_Id_1,
                                 eid.Raw_Cost_1,
                                 eid.Raw_Cost_Rate_1,
                                 eid.Attribute_Category_1,
                                 eid.Attribute1_1,
                                 eid.Attribute1_2,
                                 eid.Attribute1_3,
                                 eid.Attribute1_4,
                                 eid.Attribute1_5,
                                 eid.Attribute1_6,
                                 eid.Attribute1_7,
                                 eid.Attribute1_8,
                                 eid.Attribute1_9,
                                 eid.Attribute1_10,
                                 eid.Orig_Transaction_Reference_1,
                                 eid.Adjusted_Expenditure_Item_Id_1,
                                 eid.Net_Zero_Adjustment_Flag_1,
                                 eid.Expenditure_Comment_1,
                                 eid.Expenditure_Item_Id_2,
                                 eid.Expenditure_Item_Date_2,
                                 eid.Quantity_2,
                                 eid.System_Linkage_Function_2,
                                 eid.Non_Labor_Resource_2,
                                 eid.Organization_Id_2,
                                 eid.Override_To_Organization_Id_2,
                                 eid.Raw_Cost_2,
                                 eid.Raw_Cost_Rate_2,
                                 eid.Attribute_Category_2,
                                 eid.Attribute2_1,
                                 eid.Attribute2_2,
                                 eid.Attribute2_3,
                                 eid.Attribute2_4,
                                 eid.Attribute2_5,
                                 eid.Attribute2_6,
                                 eid.Attribute2_7,
                                 eid.Attribute2_8,
                                 eid.Attribute2_9,
                                 eid.Attribute2_10,
                                 eid.Orig_Transaction_Reference_2,
                                 eid.Adjusted_Expenditure_Item_Id_2,
                                 eid.Net_Zero_Adjustment_Flag_2,
                                 eid.Expenditure_Comment_2,
                                 eid.Expenditure_Item_Id_3,
                                 eid.Expenditure_Item_Date_3,
                                 eid.Quantity_3,
                                 eid.System_Linkage_Function_3,
                                 eid.Non_Labor_Resource_3,
                                 eid.Organization_Id_3,
                                 eid.Override_To_Organization_Id_3,
                                 eid.Raw_Cost_3,
                                 eid.Raw_Cost_Rate_3,
                                 eid.Attribute_Category_3,
                                 eid.Attribute3_1,
                                 eid.Attribute3_2,
                                 eid.Attribute3_3,
                                 eid.Attribute3_4,
                                 eid.Attribute3_5,
                                 eid.Attribute3_6,
                                 eid.Attribute3_7,
                                 eid.Attribute3_8,
                                 eid.Attribute3_9,
                                 eid.Attribute3_10,
                                 eid.Orig_Transaction_Reference_3,
                                 eid.Adjusted_Expenditure_Item_Id_3,
                                 eid.Net_Zero_Adjustment_Flag_3,
                                 eid.Expenditure_Comment_3,
                                 eid.Expenditure_Item_Id_4,
                                 eid.Expenditure_Item_Date_4,
                                 eid.Quantity_4,
                                 eid.System_Linkage_Function_4,
                                 eid.Non_Labor_Resource_4,
                                 eid.Organization_Id_4,
                                 eid.Override_To_Organization_Id_4,
                                 eid.Raw_Cost_4,
                                 eid.Raw_Cost_Rate_4,
                                 eid.Attribute_Category_4,
                                 eid.Attribute4_1,
                                 eid.Attribute4_2,
                                 eid.Attribute4_3,
                                 eid.Attribute4_4,
                                 eid.Attribute4_5,
                                 eid.Attribute4_6,
                                 eid.Attribute4_7,
                                 eid.Attribute4_8,
                                 eid.Attribute4_9,
                                 eid.Attribute4_10,
                                 eid.Orig_Transaction_Reference_4,
                                 eid.Adjusted_Expenditure_Item_Id_4,
                                 eid.Net_Zero_Adjustment_Flag_4,
                                 eid.Expenditure_Comment_4,
                                 eid.Expenditure_Item_Id_5,
                                 eid.Expenditure_Item_Date_5,
                                 eid.Quantity_5,
                                 eid.System_Linkage_Function_5,
                                 eid.Non_Labor_Resource_5,
                                 eid.Organization_Id_5,
                                 eid.Override_To_Organization_Id_5,
                                 eid.Raw_Cost_5,
                                 eid.Raw_Cost_Rate_5,
                                 eid.Attribute_Category_5,
                                 eid.Attribute5_1,
                                 eid.Attribute5_2,
                                 eid.Attribute5_3,
                                 eid.Attribute5_4,
                                 eid.Attribute5_5,
                                 eid.Attribute5_6,
                                 eid.Attribute5_7,
                                 eid.Attribute5_8,
                                 eid.Attribute5_9,
                                 eid.Attribute5_10,
                                 eid.Orig_Transaction_Reference_5,
                                 eid.Adjusted_Expenditure_Item_Id_5,
                                 eid.Net_Zero_Adjustment_Flag_5,
                                 eid.Expenditure_Comment_5,
                                 eid.Expenditure_Item_Id_6,
                                 eid.Expenditure_Item_Date_6,
                                 eid.Quantity_6,
                                 eid.System_Linkage_Function_6,
                                 eid.Non_Labor_Resource_6,
                                 eid.Organization_Id_6,
                                 eid.Override_To_Organization_Id_6,
                                 eid.Raw_Cost_6,
                                 eid.Raw_Cost_Rate_6,
                                 eid.Attribute_Category_6,
                                 eid.Attribute6_1,
                                 eid.Attribute6_2,
                                 eid.Attribute6_3,
                                 eid.Attribute6_4,
                                 eid.Attribute6_5,
                                 eid.Attribute6_6,
                                 eid.Attribute6_7,
                                 eid.Attribute6_8,
                                 eid.Attribute6_9,
                                 eid.Attribute6_10,
                                 eid.Orig_Transaction_Reference_6,
                                 eid.Adjusted_Expenditure_Item_Id_6,
                                 eid.Net_Zero_Adjustment_Flag_6,
                                 eid.Expenditure_Comment_6,
                                 eid.Expenditure_Item_Id_7,
                                 eid.Expenditure_Item_Date_7,
                                 eid.Quantity_7,
                                 eid.System_Linkage_Function_7,
                                 eid.Non_Labor_Resource_7,
                                 eid.Organization_Id_7,
                                 eid.Override_To_Organization_Id_7,
                                 eid.Raw_Cost_7,
                                 eid.Raw_Cost_Rate_7,
                                 eid.Attribute_Category_7,
                                 eid.Attribute7_1,
                                 eid.Attribute7_2,
                                 eid.Attribute7_3,
                                 eid.Attribute7_4,
                                 eid.Attribute7_5,
                                 eid.Attribute7_6,
                                 eid.Attribute7_7,
                                 eid.Attribute7_8,
                                 eid.Attribute7_9,
                                 eid.Attribute7_10,
                                 eid.Orig_Transaction_Reference_7,
                                 eid.Adjusted_Expenditure_Item_Id_7,
                                 eid.Net_Zero_Adjustment_Flag_7,
                                 eid.Expenditure_Comment_7,
                                 eid.Denorm_Total_Qty,
                                 eid.Denorm_Total_Amount,
                                 eid.Created_By,
                                 eid.Creation_Date,
                                 eid.Last_Update_Date,
                                 eid.Last_Updated_By,
                                 eid.Last_Update_Login,
                                 eid.JOB_ID_1,
                                 eid.JOB_ID_2,
                                 eid.JOB_ID_3,
                                 eid.JOB_ID_4,
                                 eid.JOB_ID_5,
                                 eid.JOB_ID_6,
                                 eid.JOB_ID_7,
                                 eid.ADJUSTED_DENORM_ID,
                                 eid.BILLABLE_FLAG_1,
                                 eid.BILLABLE_FLAG_2,
                                 eid.BILLABLE_FLAG_3,
                                 eid.BILLABLE_FLAG_4,
                                 eid.BILLABLE_FLAG_5,
                                 eid.BILLABLE_FLAG_6,
                                 eid.BILLABLE_FLAG_7,
                                 p_purge_batch_id,
                                 p_purge_release,
                                 p_project_id
                            from pa_ei_denorm eid
                           where eid.project_id = p_project_id
                             and (p_txn_to_date  is null
                             or  ( trunc(eid.expenditure_item_date_1) <= trunc(p_txn_to_date )
                             and   trunc(eid.expenditure_item_date_2) <= trunc(p_txn_to_date )
                             and   trunc(eid.expenditure_item_date_3) <= trunc(p_txn_to_date )
                             and   trunc(eid.expenditure_item_date_4) <= trunc(p_txn_to_date )
                             and   trunc(eid.expenditure_item_date_5) <= trunc(p_txn_to_date )
                             and   trunc(eid.expenditure_item_date_6) <= trunc(p_txn_to_date )
                             and   trunc(eid.expenditure_item_date_7) <= trunc(p_txn_to_date )))
                             and rownum < p_commit_size ;

                        l_NoOfRecordsIns :=  SQL%ROWCOUNT ;

                        if SQL%ROWCOUNT  > 0 then

                             -- We have a seperate delete statement if the archive option is
                             -- selected because if archive option is selected the the records
                             -- being purged will be those records which are already archived.
                             -- table and

                             delete from pa_ei_denorm eid
                              where (eid.denorm_id, eid.expenditure_id) in
                                        ( select eid2.denorm_id, eid.expenditure_id
                                            from pa_ei_denorm_ar eid2
                                           where eid2.purge_project_id = p_project_id  ) ;

                             l_NoOfRecordsDel :=  SQL%ROWCOUNT ;
                        end if;
                  else

                        l_commit_size := p_commit_size ;

                        -- If the archive option is not selected then the delete will
                        -- be based on the commit size.

                        delete from pa_ei_denorm eid
                         where eid.project_id = p_project_id
                           and (p_txn_to_date  is null
                             or  ( trunc(eid.expenditure_item_date_1) <= trunc(p_txn_to_date )
                             and   trunc(eid.expenditure_item_date_2) <= trunc(p_txn_to_date )
                             and   trunc(eid.expenditure_item_date_3) <= trunc(p_txn_to_date )
                             and   trunc(eid.expenditure_item_date_4) <= trunc(p_txn_to_date )
                             and   trunc(eid.expenditure_item_date_5) <= trunc(p_txn_to_date )
                             and   trunc(eid.expenditure_item_date_6) <= trunc(p_txn_to_date )
                             and   trunc(eid.expenditure_item_date_7) <= trunc(p_txn_to_date )))
                           and rownum < p_commit_size ;

                        l_NoOfRecordsDel :=  SQL%ROWCOUNT ;

                  end if ;

                  if SQL%ROWCOUNT = 0 then

                        -- Once the SqlCount becomes 0, which means that there are
                        -- no more records to be purged then we exit the loop.

                        exit ;

                  else
                        -- After "deleting" or "deleting and inserting" a set of records
                        -- the transaction is commited. This also creates a record in the
                        -- Pa_Purge_Project_details which will show the no. of records
                        -- that are purged from each table.

                        pa_purge.CommitProcess(p_purge_batch_id,
                                               p_project_id,
                                               'PA_EI_DENORM',
                                               l_NoOfRecordsIns,
                                               l_NoOfRecordsDel,
                                               x_err_code,
                                               x_err_stack,
                                               x_err_stage
                                              ) ;

                  end if ;

             END LOOP ;

             x_err_stack    := l_old_err_stack ;

 EXCEPTION
  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error then
       RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
--  x_err_stage := l_err_stage ;
    pa_debug.debug('Error Procedure Name  := PA_PURGE_EXTN.PA_EIDENORM' );
    pa_debug.debug('Error stage is '||x_err_stage );
    pa_debug.debug('Error stack is '||x_err_stack );
    pa_debug.debug(SQLERRM);
    PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM ;

    RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

 end PA_EiDenorm ;


-- Start of comments
-- API name         : PA_ExpenditureHistory
-- Type             : Public
-- Pre-reqs         : None
-- Function         : This procedure purges all the records from pa_expenditure_history
--
-- Parameters       : Refer to the comments of the previous procedure
--
-- End of comments

 procedure PA_ExpenditureHistory  ( p_purge_batch_id         IN NUMBER,
                                    p_project_id             IN NUMBER,
                                    p_txn_to_date            IN DATE,
                                    p_purge_release          IN VARCHAR2,
                                    p_archive_flag           IN VARCHAR2,
                                    p_commit_size            IN NUMBER,
                                    x_err_code           IN OUT NOCOPY  NUMBER,
                                    x_err_stack          IN OUT NOCOPY  VARCHAR2,
                                    x_err_stage          IN OUT NOCOPY  VARCHAR2
                                  )    is

     l_old_err_stage         VARCHAR2(2000);
     l_old_err_stack         VARCHAR2(2000);
     l_NoOfRecordsIns        NUMBER;
     l_NoOfRecordsDel        NUMBER;
 begin

     l_old_err_stack := x_err_stack;

     x_err_stack := x_err_stack || ' ->Before insert into Expenditure_History_AR' ;

     LOOP
               if p_archive_flag = 'Y' then
                     -- If archive option is selected then the records are
                     -- inserted into the archived into the archive tables
                     -- before being purged. The where condition is such that
                     -- only the it inserts half the no. of records specified
                     -- in the commit size.

                     l_commit_size := p_commit_size / 2 ;
                if p_txn_to_date is NOT NULL then
                     insert into PA_EXP_HISTORY_AR
                           (
			     Audit_Type_Code,
			     Late_Entry_Code,
			     Reason_Comment,
			     Audit_Order,
                             Incurred_By_Person_Id,
                             Expenditure_Id,
                             Denorm_Id,
                             Project_Id,
                             Task_Id,
                             Expenditure_Class_Code,
                             Expenditure_Source_Code,
                             Expenditure_Type,
                             System_Linkage_Function,
                             Expenditure_Item_Date,
                             Quantity,
                             Attribute_Category,
                             Attribute1,
                             Attribute2,
                             Attribute3,
                             Attribute4,
                             Attribute5,
                             Attribute6,
                             Attribute7,
                             Attribute8,
                             Attribute9,
                             Attribute10,
                             Expenditure_Item_Comment,
                             Adjusted_Expenditure_Item_Id,
                             Change_Code,
                             Creation_Date,
                             Created_By,
                             Last_Update_Date,
                             Last_Updated_By,
                             Last_Update_Login,
                             purge_batch_id,
                             purge_release,
                             purge_project_id
                           )
	         select	      xh.Audit_Type_Code,
			      xh.Late_Entry_Code,
			      xh.Reason_Comment,
			      xh.Audit_Order,
                              xh.Incurred_By_Person_Id,
                              xh.Expenditure_Id,
                              xh.Denorm_Id,
                              xh.Project_Id,
                              xh.Task_Id,
                              xh.Expenditure_Class_Code,
                              xh.Expenditure_Source_Code,
                              xh.Expenditure_Type,
                              xh.System_Linkage_Function,
                              xh.Expenditure_Item_Date,
                              xh.Quantity,
                              xh.Attribute_Category,
                              xh.Attribute1,
                              xh.Attribute2,
                              xh.Attribute3,
                              xh.Attribute4,
                              xh.Attribute5,
                              xh.Attribute6,
                              xh.Attribute7,
                              xh.Attribute8,
                              xh.Attribute9,
                              xh.Attribute10,
                              xh.Expenditure_Item_Comment,
                              xh.Adjusted_Expenditure_Item_Id,
                              xh.Change_Code,
                              xh.Creation_Date,
                              xh.Created_By,
                              xh.Last_Update_Date,
                              xh.Last_Updated_By,
                              xh.Last_Update_Login,
                              p_purge_batch_id,
                              p_purge_release,
                              p_project_id
                          from pa_expenditure_history xh
                         where xh.project_id = p_project_id
                           and xh.expenditure_item_date <= p_txn_to_date
                           and rownum < l_commit_size  ;
                 else
                     insert into PA_EXP_HISTORY_AR
                           (
			     Audit_Type_Code,
			     Late_Entry_Code,
			     Reason_Comment,
			     Audit_Order,
                             Incurred_By_Person_Id,
                             Expenditure_Id,
                             Denorm_Id,
                             Project_Id,
                             Task_Id,
                             Expenditure_Class_Code,
                             Expenditure_Source_Code,
                             Expenditure_Type,
                             System_Linkage_Function,
                             Expenditure_Item_Date,
                             Quantity,
                             Attribute_Category,
                             Attribute1,
                             Attribute2,
                             Attribute3,
                             Attribute4,
                             Attribute5,
                             Attribute6,
                             Attribute7,
                             Attribute8,
                             Attribute9,
                             Attribute10,
                             Expenditure_Item_Comment,
                             Adjusted_Expenditure_Item_Id,
                             Change_Code,
                             Creation_Date,
                             Created_By,
                             Last_Update_Date,
                             Last_Updated_By,
                             Last_Update_Login,
                             purge_batch_id,
                             purge_release,
                             purge_project_id
                           )
	         select	      xh.Audit_Type_Code,
			      xh.Late_Entry_Code,
			      xh.Reason_Comment,
			      xh.Audit_Order,
                              xh.Incurred_By_Person_Id,
                              xh.Expenditure_Id,
                              xh.Denorm_Id,
                              xh.Project_Id,
                              xh.Task_Id,
                              xh.Expenditure_Class_Code,
                              xh.Expenditure_Source_Code,
                              xh.Expenditure_Type,
                              xh.System_Linkage_Function,
                              xh.Expenditure_Item_Date,
                              xh.Quantity,
                              xh.Attribute_Category,
                              xh.Attribute1,
                              xh.Attribute2,
                              xh.Attribute3,
                              xh.Attribute4,
                              xh.Attribute5,
                              xh.Attribute6,
                              xh.Attribute7,
                              xh.Attribute8,
                              xh.Attribute9,
                              xh.Attribute10,
                              xh.Expenditure_Item_Comment,
                              xh.Adjusted_Expenditure_Item_Id,
                              xh.Change_Code,
                              xh.Creation_Date,
                              xh.Created_By,
                              xh.Last_Update_Date,
                              xh.Last_Updated_By,
                              xh.Last_Update_Login,
                              p_purge_batch_id,
                              p_purge_release,
                              p_project_id
                          from pa_expenditure_history xh
                         where xh.project_id = p_project_id
                           and rownum < l_commit_size  ;
                  end if;

                     l_NoOfRecordsIns := SQL%ROWCOUNT ;

                     if SQL%ROWCOUNT > 0 then
                         -- We have a seperate delete statement if the archive option is
                         -- selected because if archive option is selected the the records
                         -- being purged will be those records which are already archived.
                         -- table and
                         delete from pa_expenditure_history xh
                          where (xh.expenditure_id, xh.denorm_id ) in
                                          ( select xhar.expenditure_id, xhar.denorm_id
                                              from PA_EXP_HISTORY_AR xhar
                                             where xhar.purge_project_id = p_project_id
                                          ) ;

                         l_NoOfRecordsDel :=  SQL%ROWCOUNT ;
                     end if ;
               else

                     l_commit_size := p_commit_size ;

                     -- If the archive option is not selected then the delete will
                     -- be based on the commit size.
                  if p_txn_to_date is NOT NULL then
                     delete from pa_expenditure_history xh
                      where xh.project_id = p_project_id
                        and xh.expenditure_item_date <= p_txn_to_date
                        and rownum < l_commit_size  ;
                  else
                     delete from pa_expenditure_history xh
                      where xh.project_id = p_project_id
                        and rownum < l_commit_size  ;
                  end if;

                    l_NoOfRecordsDel :=  SQL%ROWCOUNT ;
               end if ;

               if SQL%ROWCOUNT = 0 then
                     -- Once the SqlCount becomes 0, which means that there are
                     -- no more records to be purged then we exit the loop.

                     exit ;

               else
                     -- After "deleting" or "deleting and inserting" a set of records
                     -- the transaction is commited. This also creates a record in the
                     -- Pa_Purge_Project_details which will show the no. of records
                     -- that are purged from each table.

                      pa_purge.CommitProcess(p_purge_batch_id,
                                             p_project_id,
                                             'PA_EXPENDITURE_HISTORY',
                                             l_NoOfRecordsIns,
                                             l_NoOfRecordsDel,
                                             x_err_code,
                                             x_err_stack,
                                             x_err_stage
                                            ) ;

               end if ;
     END LOOP ;

     x_err_stack    := l_old_err_stack ;

 EXCEPTION
  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error then
       RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
--  x_err_stage := l_err_stage ;
    pa_debug.debug('Error Procedure Name  := PA_PURGE_EXTN.PA_EXPENDITUREHISTORY' );
    pa_debug.debug('Error stage is '||x_err_stage );
    pa_debug.debug('Error stack is '||x_err_stack );
    pa_debug.debug(SQLERRM);
    PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM ;

    RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

 end PA_ExpenditureHistory ;


-- Start of comments
-- API name         : PA_ExpenditureItems
-- Type             : Public
-- Pre-reqs         : None
-- Function         : This procedure purges all the expenditure items that are
--                    not related to other expenditure items through
--                    transferred_from_exp_item_id.
--
-- Parameters       : Refer to the comments of the previous procedure
--
-- End of comments

 procedure PA_ExpenditureItems ( p_purge_batch_id         IN NUMBER,
                                 p_project_id             IN NUMBER,
                                 p_txn_to_date            IN DATE,
                                 p_purge_release          IN VARCHAR2,
                                 p_archive_flag           IN VARCHAR2,
                                 p_commit_size            IN NUMBER,
                                 x_err_code           IN OUT NOCOPY  NUMBER,
                                 x_err_stack          IN OUT NOCOPY  VARCHAR2,
                                 x_err_stage          IN OUT NOCOPY  VARCHAR2)
 is

     l_old_err_stage         VARCHAR2(2000);
     l_old_err_stack         VARCHAR2(2000);
     l_NoOfRecordsIns        NUMBER;
     l_NoOfRecordsDel        NUMBER;
     l_MRC_NoOfRecordsDel    NUMBER;
     x_MRC_NoOfRecordsIns    NUMBER;
     l_commit_size           NUMBER;
     l_ei_rowid_tab          PA_PLSQL_DATATYPES.RowIDTabTyp;
     l_ei_rowid_tab_empty    PA_PLSQL_DATATYPES.RowIDTabTyp;
     l_fetch_complete          BOOLEAN := FALSE;
     exp_ind                   NUMBER;
     l_exp_item_id_tab       PA_PLSQL_DATATYPES.IdTabTyp;
     l_exp_item_id_tab_empty PA_PLSQL_DATATYPES.IdTabTyp;
     l_request_id            NUMBER;

     cursor c_exp_open_projects is
     select rowid,expenditure_item_id from pa_expenditure_items_all ei
     where ei.expenditure_item_date <= p_txn_to_date
     and ei.project_id = p_project_id;

     cursor c_exp_close_projects is
     select rowid,expenditure_item_id from pa_expenditure_items_all ei
     where ei.project_id = p_project_id;

 begin


     l_old_err_stack := x_err_stack;

     x_err_stack := x_err_stack || ' ->Before insert into PA_Expenditure_Items_AR' ;

     /*   If mrc is enabled and being used then set the commit size based on the number
      *   of reporting currencies using PA_UTILS2.ARPUR_MRC_Commit_Size.
      *   Otherwise just set the commit using PA_UTILS2.ARPUR_Commit_Size.
      */
     IF (l_mrc_flag = 'Y') THEN
      	l_commit_size := trunc(PA_UTILS2.ARPUR_MRC_Commit_Size/3);
     ELSE
        l_commit_size := trunc(PA_UTILS2.ARPUR_Commit_Size/3);
     END IF;

     IF p_txn_to_date is not null THEN
        OPEN c_exp_open_projects;
     ELSE
        OPEN c_exp_close_projects;
     END IF;

     LOOP
          l_NoOfRecordsIns := 0;
          l_NoOfRecordsIns := 0;
          l_ei_rowid_tab := l_ei_rowid_tab_empty;

        IF p_txn_to_date is not null THEN

            FETCH c_exp_open_projects BULK COLLECT INTO
                  l_ei_rowid_tab,
                  l_exp_item_id_tab
                  LIMIT l_commit_size;
            IF c_exp_open_projects%NOTFOUND THEN
               CLOSE c_exp_open_projects;
               l_fetch_complete := TRUE;
            END IF;
        ELSE
           FETCH c_exp_close_projects BULK COLLECT INTO
                 l_ei_rowid_tab,
                 l_exp_item_id_tab
                 LIMIT l_commit_size;
            IF c_exp_close_projects%NOTFOUND THEN
               CLOSE c_exp_close_projects;
               l_fetch_complete := TRUE;
            END IF;
        END IF;

     If l_ei_rowid_tab.last is not null Then
       if p_archive_flag = 'Y' then

       x_err_stage := 'PA_ExpenditureItems: Before inserting records into PA_Expenditure_Items_AR';
            FORALL exp_ind IN l_ei_rowid_tab.FIRST .. l_ei_rowid_tab.LAST
                     insert into PA_Expenditure_Items_AR
                        (
			  receipt_currency_amount,
			  receipt_currency_code,
			  receipt_exchange_rate,
			  denom_currency_code,
			  denom_raw_cost,
			  denom_burdened_cost,
			  acct_currency_code,
			  acct_rate_date,
			  acct_rate_type,
			  acct_exchange_rate,
			  acct_raw_cost,
			  acct_burdened_cost,
			  acct_exchange_rounding_limit,
			  project_currency_code,
			  project_rate_date,
			  project_rate_type,
			  project_exchange_rate,
			  cc_cross_charge_code,
			  cc_prvdr_organization_id,
			  cc_recvr_organization_id,
			  cc_rejection_code,
			  denom_tp_currency_code,
			  denom_transfer_price,
			  acct_tp_rate_type,
			  acct_tp_rate_date,
			  acct_tp_exchange_rate,
			  acct_transfer_price,
			  projacct_transfer_price,
			  cc_markup_base_code,
			  tp_base_amount,
			  cc_cross_charge_type,
			  recvr_org_id,
			  cc_bl_distributed_code,
			  cc_ic_processed_code,
			  tp_ind_compiled_set_id,
			  tp_bill_rate,
			  tp_bill_markup_percentage,
			  tp_schedule_line_percentage,
			  tp_rule_percentage,
			  cc_prvdr_cost_reclass_code,
			  crl_asset_creation_status_code,
			  crl_asset_creation_rej_code,
			  cost_job_id,
			  tp_job_id,
			  prov_proj_bill_job_id,
			  cost_dist_warning_code,
			  project_tp_rate_date,
			  project_tp_rate_type,
			  project_tp_exchange_rate,
			  projfunc_tp_rate_date,
			  projfunc_tp_rate_type,
			  projfunc_tp_exchange_rate,
			  projfunc_transfer_price,
			  bill_trans_forecast_curr_code,
			  bill_trans_forecast_revenue,
			  projfunc_rev_rate_date,
			  projfunc_rev_exchange_rate,
			  projfunc_cost_rate_type,
			  projfunc_cost_rate_date,
			  projfunc_cost_exchange_rate,
			  project_raw_cost,
			  project_burdened_cost,
			  assignment_id,
			  work_type_id,
			  projfunc_raw_revenue,
			  project_bill_amount,
			  projfunc_currency_code,
			  project_raw_revenue,
			  project_transfer_price,
			  tp_amt_type_code,
			  bill_trans_currency_code,
			  bill_trans_raw_revenue,
			  bill_trans_bill_amount,
			  bill_trans_adjusted_revenue,
			  revproc_currency_code,
			  revproc_rate_type,
			  revproc_rate_date,
			  revproc_exchange_rate,
			  invproc_currency_code,
			  invproc_rate_type,
			  invproc_rate_date,
			  discount_percentage,
			  labor_multiplier,
			  amount_calculation_code,
			  bill_markup_percentage,
			  rate_source_id,
			  invproc_exchange_rate,
			  inv_gen_rejection_code,
			  projfunc_bill_amount,
			  project_rev_rate_type,
			  project_rev_rate_date,
			  project_rev_exchange_rate,
			  projfunc_rev_rate_type,
			  projfunc_inv_rate_type,
			  projfunc_inv_rate_date,
			  projfunc_inv_exchange_rate,
			  project_inv_rate_type,
			  project_inv_rate_date,
			  project_inv_exchange_rate,
			  projfunc_fcst_rate_type,
			  projfunc_fcst_rate_date,
			  projfunc_fcst_exchange_rate,
			  prvdr_accrual_date,
			  recvr_accrual_date,
                          quantity,
                          non_labor_resource,
                          organization_id,
                          override_to_organization_id,
                          denorm_id,
                          raw_cost,
                          raw_cost_rate,
                          burden_cost,
                          burden_cost_rate,
                          cost_dist_rejection_code,
                          labor_cost_multiplier_name,
                          raw_revenue,
                          bill_rate,
                          accrued_revenue,
                          accrual_rate,
                          adjusted_revenue,
                          adjusted_rate,
                          bill_amount,
                          forecast_revenue,
                          bill_rate_multiplier,
                          rev_dist_rejection_code,
                          event_num,
                          event_task_id,
                          bill_job_id,
                          bill_job_billing_title,
                          bill_employee_billing_title,
                          adjusted_expenditure_item_id,
                          net_zero_adjustment_flag,
                          transferred_from_exp_item_id,
                          converted_flag,
                          last_update_login,
                          request_id,
                          program_application_id,
                          program_id,
                          program_update_date,
                          attribute_category,
                          attribute1,
                          expenditure_item_id,
                          last_update_date,
                          last_updated_by,
                          creation_date,
                          created_by,
                          expenditure_id,
                          task_id,
                          expenditure_item_date,
                          expenditure_type,
                          cost_distributed_flag,
                          revenue_distributed_flag,
                          billable_flag,
                          bill_hold_flag,
                          attribute2,
                          attribute3,
                          attribute4,
                          attribute5,
                          attribute6,
                          attribute7,
                          attribute8,
                          attribute9,
                          attribute10,
                          cost_ind_compiled_set_id,
                          rev_ind_compiled_set_id,
                          inv_ind_compiled_set_id,
                          cost_burden_distributed_flag,
                          ind_cost_dist_rejection_code,
                          orig_transaction_reference,
                          transaction_source,
                          project_id,
                          source_expenditure_item_id,
                          job_id,
                          org_id,
			  system_linkage_function,
			  burden_sum_dest_run_id,
                          purge_batch_id,
                          purge_release,
                          purge_project_id,
                          RATE_DISC_REASON_CODE,
			  capital_event_id,
                          posted_denom_burdened_cost,
                          posted_project_burdened_cost,
                          posted_projfunc_burdened_cost,
                          posted_acct_burdened_cost,
                          adjustment_type,
			  Po_Line_Id,                  -- CWK and FPM Changes
                          Po_Price_Type,               -- CWK and FPM Changes
                          Inventory_Item_Id,           -- CWK and FPM Changes
                          Wip_Resource_Id,             -- CWK and FPM Changes
                          Unit_Of_Measure,             -- CWK and FPM Changes
                          document_header_id,          -- R12 Change
                          document_distribution_id,    -- R12 Change
                          document_line_number,        -- R12 Change
                          document_payment_id,         -- R12 Change
                          vendor_id,                   -- R12 Change
                          document_type,               -- R12 Change
                          document_distribution_type   -- R12 Change
                        )
		       select	ei.receipt_currency_amount,
				ei.receipt_currency_code,
				ei.receipt_exchange_rate,
				ei.denom_currency_code,
				ei.denom_raw_cost,
				ei.denom_burdened_cost,
				ei.acct_currency_code,
				ei.acct_rate_date,
				ei.acct_rate_type,
				ei.acct_exchange_rate,
				ei.acct_raw_cost,
				ei.acct_burdened_cost,
				ei.acct_exchange_rounding_limit,
				ei.project_currency_code,
				ei.project_rate_date,
				ei.project_rate_type,
				ei.project_exchange_rate,
				ei.cc_cross_charge_code,
				ei.cc_prvdr_organization_id,
				ei.cc_recvr_organization_id,
				ei.cc_rejection_code,
				ei.denom_tp_currency_code,
				ei.denom_transfer_price,
				ei.acct_tp_rate_type,
				ei.acct_tp_rate_date,
				ei.acct_tp_exchange_rate,
				ei.acct_transfer_price,
				ei.projacct_transfer_price,
				ei.cc_markup_base_code,
				ei.tp_base_amount,
				ei.cc_cross_charge_type,
				ei.recvr_org_id,
				ei.cc_bl_distributed_code,
				ei.cc_ic_processed_code,
				ei.tp_ind_compiled_set_id,
				ei.tp_bill_rate,
				ei.tp_bill_markup_percentage,
				ei.tp_schedule_line_percentage,
				ei.tp_rule_percentage,
				ei.cc_prvdr_cost_reclass_code,
				ei.crl_asset_creation_status_code,
				ei.crl_asset_creation_rej_code,
				ei.cost_job_id,
				ei.tp_job_id,
				ei.prov_proj_bill_job_id,
				ei.cost_dist_warning_code,
				ei.project_tp_rate_date,
				ei.project_tp_rate_type,
				ei.project_tp_exchange_rate,
				ei.projfunc_tp_rate_date,
				ei.projfunc_tp_rate_type,
				ei.projfunc_tp_exchange_rate,
				ei.projfunc_transfer_price,
				ei.bill_trans_forecast_curr_code,
				ei.bill_trans_forecast_revenue,
				ei.projfunc_rev_rate_date,
				ei.projfunc_rev_exchange_rate,
				ei.projfunc_cost_rate_type,
				ei.projfunc_cost_rate_date,
				ei.projfunc_cost_exchange_rate,
				ei.project_raw_cost,
				ei.project_burdened_cost,
				ei.assignment_id,
				ei.work_type_id,
				ei.projfunc_raw_revenue,
				ei.project_bill_amount,
				ei.projfunc_currency_code,
				ei.project_raw_revenue,
				ei.project_transfer_price,
				ei.tp_amt_type_code,
				ei.bill_trans_currency_code,
				ei.bill_trans_raw_revenue,
				ei.bill_trans_bill_amount,
				ei.bill_trans_adjusted_revenue,
				ei.revproc_currency_code,
				ei.revproc_rate_type,
				ei.revproc_rate_date,
				ei.revproc_exchange_rate,
				ei.invproc_currency_code,
				ei.invproc_rate_type,
				ei.invproc_rate_date,
				ei.discount_percentage,
				ei.labor_multiplier,
				ei.amount_calculation_code,
				ei.bill_markup_percentage,
				ei.rate_source_id,
				ei.invproc_exchange_rate,
				ei.inv_gen_rejection_code,
				ei.projfunc_bill_amount,
				ei.project_rev_rate_type,
				ei.project_rev_rate_date,
				ei.project_rev_exchange_rate,
				ei.projfunc_rev_rate_type,
				ei.projfunc_inv_rate_type,
				ei.projfunc_inv_rate_date,
				ei.projfunc_inv_exchange_rate,
				ei.project_inv_rate_type,
				ei.project_inv_rate_date,
				ei.project_inv_exchange_rate,
				ei.projfunc_fcst_rate_type,
				ei.projfunc_fcst_rate_date,
				ei.projfunc_fcst_exchange_rate,
				ei.prvdr_accrual_date,
				ei.recvr_accrual_date,
                              ei.quantity,
                              ei.non_labor_resource,
                              ei.organization_id,
                              ei.override_to_organization_id,
                              ei.denorm_id,
                              ei.raw_cost,
                              ei.raw_cost_rate,
                              ei.burden_cost,
                              ei.burden_cost_rate,
                              ei.cost_dist_rejection_code,
                              ei.labor_cost_multiplier_name,
                              ei.raw_revenue,
                              ei.bill_rate,
                              ei.accrued_revenue,
                              ei.accrual_rate,
                              ei.adjusted_revenue,
                              ei.adjusted_rate,
                              ei.bill_amount,
                              ei.forecast_revenue,
                              ei.bill_rate_multiplier,
                              ei.rev_dist_rejection_code,
                              ei.event_num,
                              ei.event_task_id,
                              ei.bill_job_id,
                              ei.bill_job_billing_title,
                              ei.bill_employee_billing_title,
                              ei.adjusted_expenditure_item_id,
                              ei.net_zero_adjustment_flag,
                              ei.transferred_from_exp_item_id,
                              ei.converted_flag,
                              ei.last_update_login,
                              ei.request_id,
                              ei.program_application_id,
                              ei.program_id,
                              ei.program_update_date,
                              ei.attribute_category,
                              ei.attribute1,
                              ei.expenditure_item_id,
                              ei.last_update_date,
                              ei.last_updated_by,
                              ei.creation_date,
                              ei.created_by,
                              ei.expenditure_id,
                              ei.task_id,
                              ei.expenditure_item_date,
                              ei.expenditure_type,
                              ei.cost_distributed_flag,
                              ei.revenue_distributed_flag,
                              ei.billable_flag,
                              ei.bill_hold_flag,
                              ei.attribute2,
                              ei.attribute3,
                              ei.attribute4,
                              ei.attribute5,
                              ei.attribute6,
                              ei.attribute7,
                              ei.attribute8,
                              ei.attribute9,
                              ei.attribute10,
                              ei.cost_ind_compiled_set_id,
                              ei.rev_ind_compiled_set_id,
                              ei.inv_ind_compiled_set_id,
                              ei.cost_burden_distributed_flag,
                              ei.ind_cost_dist_rejection_code,
                              ei.orig_transaction_reference,
                              ei.transaction_source,
                              ei.project_id,
                              ei.source_expenditure_item_id,
                              ei.job_id,
                              ei.org_id,
                              ei.system_linkage_function,
                              ei.burden_sum_dest_run_id,
                              p_purge_batch_id,
                              p_purge_release,
                              p_project_id,
                              ei.RATE_DISC_REASON_CODE,
             	              ei.capital_event_id,
                              ei.posted_denom_burdened_cost,
                              ei.posted_project_burdened_cost,
                              ei.posted_projfunc_burdened_cost,
                              ei.posted_acct_burdened_cost,
                              ei.adjustment_type,
                              ei.Po_Line_Id,                  -- CWK and FPM Changes
                              ei.Po_Price_Type,               -- CWK and FPM Changes
                              ei.Inventory_Item_Id,           -- CWK and FPM Changes
                              ei.Wip_Resource_Id,             -- CWK and FPM Changes
                              ei.Unit_Of_Measure,             -- CWK and FPM Changes
                              ei.document_header_id,          -- R12 Change
                              ei.document_distribution_id,    -- R12 Change
                              ei.document_line_number,        -- R12 Change
                              ei.document_payment_id,         -- R12 Change
                              ei.vendor_id,                   -- R12 Change
                              ei.document_type,               -- R12 Change
                              ei.document_distribution_type   -- R12 Change
                         from pa_expenditure_items_all ei
                        where ei.rowid = l_ei_rowid_tab(exp_ind);
                     l_NoOfRecordsIns :=  SQL%ROWCOUNT ;
                    end if;


/* Commented for the bug#2405916 and moved this to inside the if SQL%ROWCOUNT > 0 condition */
/* */

                     if l_NoOfRecordsIns > 0 then

         	         IF (l_mrc_flag = 'Y') THEN
		            pa_purge_costing.PA_MRCExpenditureItems(
				p_purge_batch_id,
                                p_project_id,
                                p_txn_to_date,
                                p_purge_release,
                                p_archive_flag,
                                l_commit_size,
                                x_err_code,
                                x_err_stack,
                                x_err_stage,
				x_MRC_NoOfRecordsIns);
      		         END IF;
      		     END IF;

               Select Pa_Expend_Item_Adj_Act_s.nextval
                 into l_request_id
                 from dual ;

            FORALL exp_ind IN l_exp_item_id_tab.FIRST .. l_exp_item_id_tab.LAST
              insert into Pa_Expend_item_Adj_Activities
               ( expenditure_item_id,
                 activity_date,
                 last_update_date,
                 last_updated_by,
                 creation_date,
                 created_by,
                 exception_activity_code,
                 module_code,
                 last_update_login,
                 request_id
                 )
               select ei.expenditure_item_id,
                      sysdate,
                      sysdate,
                      g_user,
                      sysdate,
                      g_user,
                      'SOURCE PURGED',
                      'PURGE PROCESS',
                      g_user,
                      l_request_id
               from pa_expenditure_items_all ei
               where ei.transferred_from_exp_item_id = l_exp_item_id_tab(exp_ind)
               and ei.transferred_from_exp_item_id is not null
               and not exists ( select pp.project_id
                                  from pa_purge_projects pp
                                 where pp.project_id = ei.project_id
                                   and pp.purge_batch_id = p_purge_batch_id ) ;

            FORALL exp_ind IN l_exp_item_id_tab.FIRST .. l_exp_item_id_tab.LAST
              update pa_expenditure_items_all ei
              set    ei.transferred_from_exp_item_id = NULL
              where  ei.transferred_from_exp_item_id = l_exp_item_id_tab(exp_ind)
              and    ei.transferred_from_exp_item_id is not null
              and    not exists ( select pp.project_id
                                  from pa_purge_projects pp
                                 where pp.project_id = ei.project_id
                                   and pp.purge_batch_id = p_purge_batch_id ) ;

			  /* Each time thru the loop need to make sure that reset the
			   * counter tracking the number of records that deleted from
			   * the mrc table.
			   */
			  IF (l_mrc_flag = 'Y') THEN
			     pa_utils2.MRC_row_count := 0;
			  END IF;

                          -- We have a seperate delete statement if the archive option is
                          -- selected because if archive option is selected the the records
                          -- being purged will be those records which are already archived.
                          -- table and

                          x_err_stage := 'PA_ExpenditureItems: Before deleting records from pa_expenditure_items_all';
                    FORALL exp_ind IN l_ei_rowid_tab.FIRST .. l_ei_rowid_tab.LAST
                           DELETE FROM PA_EXPENDITURE_ITEMS_ALL EI
                           WHERE EI.ROWID = l_ei_rowid_tab(exp_ind);

         		  l_NoOfRecordsDel := SQL%ROWCOUNT;
                          l_MRC_NoOfRecordsDel := pa_utils2.MRC_row_count;


                    IF l_NoOfRecordsDel > 0 THEN
                     x_err_stage := 'PA_ExpenditureItems: Commiting the transaction' ;
                     pa_purge.CommitProcess(p_purge_batch_id,
                                            p_project_id,
                                            'PA_EXPENDITURE_ITEMS',
                                            l_NoOfRecordsIns,
                                            l_NoOfRecordsDel,
                                            x_err_code,
                                            x_err_stack,
                                            x_err_stage,
				       /*   'PA_MC_EXP_ITEMS_AR',    */
					    'PA_MC_EXP_ITEMS',
					    x_MRC_NoOfRecordsIns,
					    l_MRC_NoOfRecordsDel
                                            ) ;

                   end if ;
                 end if ;

                   IF (l_fetch_complete) THEN
                      Exit;
                   END IF;

          END LOOP ;

          x_err_stack    := l_old_err_stack ;

 EXCEPTION
  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error then
       RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
--  x_err_stage := l_err_stage ;
    pa_debug.debug('Error Procedure Name  := PA_PURGE_COSTING.PA_EXPENDITUREITEMS' );
    pa_debug.debug('Error stage is '||x_err_stage );
    pa_debug.debug('Error stack is '||x_err_stack );
    pa_debug.debug(SQLERRM);
    PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM ;

    RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

 end PA_ExpenditureItems ;

-- Start of comments
-- API name         : PA_ExpItemsSrcPurge
-- Type             : Public
-- Pre-reqs         : None
-- Function         : This procedure all the expenditure items that are
--                    transferred to another expenditure item.
--
-- Parameters       : Refer to the comments of the previous procedure
--
-- End of comments

 procedure PA_ExpItemsSrcPurge ( p_purge_batch_id         IN NUMBER,
                                 p_project_id             IN NUMBER,
                                 p_txn_to_date            IN DATE,
                                 p_purge_release          IN VARCHAR2,
                                 p_archive_flag           IN VARCHAR2,
                                 p_commit_size            IN NUMBER,
                                 x_err_code           IN OUT NOCOPY  NUMBER,
                                 x_err_stack          IN OUT NOCOPY  VARCHAR2,
                                 x_err_stage          IN OUT NOCOPY  VARCHAR2
                               )    is

     l_old_err_stage         VARCHAR2(2000);
     l_old_err_stack         VARCHAR2(2000);
     l_NoOfRecordsIns        NUMBER;
     l_NoOfRecordsDel        NUMBER;
     l_Request_Id            NUMBER;

begin


     l_old_err_stack := x_err_stack;

     x_err_stack := x_err_stack || ' ->Before insert into PA_Expenditure_Items_AR' ;

     if p_archive_flag = 'Y' then
        l_commit_size := trunc(p_commit_size / 4) ;
     else

        l_commit_size := trunc(p_commit_size / 3) ;
     end if ;


     LOOP
               Select Pa_Expend_Item_Adj_Act_s.nextval
                 into l_request_id
                 from dual ;
--               l_request_id := Pa_Expend_Item_Adj_Act_s.nextval ;
               x_err_stage := 'PA_ExpItemsSrcPurge: Before inserting audit records into Pa_Expend_item_Adj_Activities';
            if p_txn_to_date is NOT NULL then
               insert into Pa_Expend_item_Adj_Activities
               ( expenditure_item_id,
                 activity_date,
                 last_update_date,
                 last_updated_by,
                 creation_date,
                 created_by,
                 exception_activity_code,
                 module_code,
                 last_update_login,
                 request_id
                 )
               select ei.expenditure_item_id,
                      sysdate,
                      sysdate,
                      g_user,
                      sysdate,
                      g_user,
                      'SOURCE PURGED',
                      'PURGE PROCESS',
                      g_user,
                      l_request_id
               from pa_expenditure_items_all ei
               where ei.transferred_from_exp_item_id in ( select ei1.expenditure_item_id
                                                       from pa_expenditure_items_all ei1
                                                        where ei1.expenditure_item_date <= p_txn_to_date
                                                        and ei1.project_id = p_project_id )
               and ei.transferred_from_exp_item_id is not null
               and rownum < l_commit_size
               and not exists ( select pp.project_id
                                  from pa_purge_projects pp
                                 where pp.project_id = ei.project_id
                                   and pp.purge_batch_id = p_purge_batch_id ) ;
          else
               insert into Pa_Expend_item_Adj_Activities
               ( expenditure_item_id,
                 activity_date,
                 last_update_date,
                 last_updated_by,
                 creation_date,
                 created_by,
                 exception_activity_code,
                 module_code,
                 last_update_login,
                 request_id
                 )
               select ei.expenditure_item_id,
                      sysdate,
                      sysdate,
                      g_user,
                      sysdate,
                      g_user,
                      'SOURCE PURGED',
                      'PURGE PROCESS',
                      g_user,
                      l_request_id
               from pa_tasks t,pa_expenditure_items_all ei
               where ei.transferred_from_exp_item_id in ( select ei1.expenditure_item_id
                                                       from pa_expenditure_items_all ei1,
                                                            pa_tasks t1
                                                      where ei1.task_id = t1.task_id
                                                        and t1.project_id = p_project_id )
               and ei.task_id = t.task_id
               and ei.transferred_from_exp_item_id is not null
               and rownum < l_commit_size
               and not exists ( select pp.project_id
                                  from pa_purge_projects pp
                                 where pp.project_id = t.project_id
                                   and pp.purge_batch_id = p_purge_batch_id ) ;
          end if;



               if SQL%ROWCOUNT = 0 then
                  exit ;
               else

/* Commented for archive purge performance....
                     if p_archive_flag = 'Y' then
                           -- If archive option is selected then the records are
                           -- inserted into the archived into the archive tables
                           -- before being purged. The where condition is such that
                           -- only the it inserts half the no. of records specified
                           -- in the commit size.

                           x_err_stage := 'PA_ExpItemsSrcPurge: Before inserting records into PA_Expenditure_Items_AR';
                           insert into PA_Expenditure_Items_AR
                              (
				  receipt_currency_amount,
				  receipt_currency_code,
				  receipt_exchange_rate,
				  denom_currency_code,
				  denom_raw_cost,
				  denom_burdened_cost,
				  acct_currency_code,
				  acct_rate_date,
				  acct_rate_type,
				  acct_exchange_rate,
				  acct_raw_cost,
				  acct_burdened_cost,
				  acct_exchange_rounding_limit,
				  project_currency_code,
				  project_rate_date,
				  project_rate_type,
				  project_exchange_rate,
				  cc_cross_charge_code,
				  cc_prvdr_organization_id,
				  cc_recvr_organization_id,
				  cc_rejection_code,
				  denom_tp_currency_code,
				  denom_transfer_price,
				  acct_tp_rate_type,
				  acct_tp_rate_date,
				  acct_tp_exchange_rate,
				  acct_transfer_price,
				  projacct_transfer_price,
				  cc_markup_base_code,
				  tp_base_amount,
				  cc_cross_charge_type,
				  recvr_org_id,
				  cc_bl_distributed_code,
				  cc_ic_processed_code,
				  tp_ind_compiled_set_id,
				  tp_bill_rate,
				  tp_bill_markup_percentage,
				  tp_schedule_line_percentage,
				  tp_rule_percentage,
				  cc_prvdr_cost_reclass_code,
				  crl_asset_creation_status_code,
				  crl_asset_creation_rej_code,
				  cost_job_id,
				  tp_job_id,
				  prov_proj_bill_job_id,
				  cost_dist_warning_code,
				  project_tp_rate_date,
				  project_tp_rate_type,
				  project_tp_exchange_rate,
				  projfunc_tp_rate_date,
				  projfunc_tp_rate_type,
				  projfunc_tp_exchange_rate,
				  projfunc_transfer_price,
				  bill_trans_forecast_curr_code,
				  bill_trans_forecast_revenue,
				  projfunc_rev_rate_date,
				  projfunc_rev_exchange_rate,
				  projfunc_cost_rate_type,
				  projfunc_cost_rate_date,
				  projfunc_cost_exchange_rate,
				  project_raw_cost,
				  project_burdened_cost,
				  assignment_id,
				  work_type_id,
				  projfunc_raw_revenue,
				  project_bill_amount,
				  projfunc_currency_code,
				  project_raw_revenue,
				  project_transfer_price,
				  tp_amt_type_code,
				  bill_trans_currency_code,
				  bill_trans_raw_revenue,
				  bill_trans_bill_amount,
				  bill_trans_adjusted_revenue,
				  revproc_currency_code,
				  revproc_rate_type,
				  revproc_rate_date,
				  revproc_exchange_rate,
				  invproc_currency_code,
				  invproc_rate_type,
				  invproc_rate_date,
				  discount_percentage,
				  labor_multiplier,
				  amount_calculation_code,
				  bill_markup_percentage,
				  rate_source_id,
				  invproc_exchange_rate,
				  inv_gen_rejection_code,
				  projfunc_bill_amount,
				  project_rev_rate_type,
				  project_rev_rate_date,
				  project_rev_exchange_rate,
				  projfunc_rev_rate_type,
				  projfunc_inv_rate_type,
				  projfunc_inv_rate_date,
				  projfunc_inv_exchange_rate,
				  project_inv_rate_type,
				  project_inv_rate_date,
				  project_inv_exchange_rate,
				  projfunc_fcst_rate_type,
				  projfunc_fcst_rate_date,
				  projfunc_fcst_exchange_rate,
				  prvdr_accrual_date,
				  recvr_accrual_date,
                                quantity,
                                non_labor_resource,
                                organization_id,
                                override_to_organization_id,
                                denorm_id,
                                raw_cost,
                                raw_cost_rate,
                                burden_cost,
                                burden_cost_rate,
                                cost_dist_rejection_code,
                                labor_cost_multiplier_name,
                                raw_revenue,
                                bill_rate,
                                accrued_revenue,
                                accrual_rate,
                                adjusted_revenue,
                                adjusted_rate,
                                bill_amount,
                                forecast_revenue,
                                bill_rate_multiplier,
                                rev_dist_rejection_code,
                                event_num,
                                event_task_id,
                                bill_job_id,
                                bill_job_billing_title,
                                bill_employee_billing_title,
                                adjusted_expenditure_item_id,
                                net_zero_adjustment_flag,
                                transferred_from_exp_item_id,
                                converted_flag,
                                last_update_login,
                                request_id,
                                program_application_id,
                                program_id,
                                program_update_date,
                                attribute_category,
                                attribute1,
                                expenditure_item_id,
                                last_update_date,
                                last_updated_by,
                                creation_date,
                                created_by,
                                expenditure_id,
                                task_id,
                                expenditure_item_date,
                                expenditure_type,
                                cost_distributed_flag,
                                revenue_distributed_flag,
                                billable_flag,
                                bill_hold_flag,
                                attribute2,
                                attribute3,
                                attribute4,
                                attribute5,
                                attribute6,
                                attribute7,
                                attribute8,
                                attribute9,
                                attribute10,
                                cost_ind_compiled_set_id,
                                rev_ind_compiled_set_id,
                                inv_ind_compiled_set_id,
                                cost_burden_distributed_flag,
                                ind_cost_dist_rejection_code,
                                orig_transaction_reference,
                                transaction_source,
                                project_id,
                                source_expenditure_item_id,
                                job_id,
                                org_id,
				System_Linkage_Function,
				Burden_Sum_Dest_Run_Id,
                                purge_batch_id,
                                purge_release,
                                purge_project_id,
                                RATE_DISC_REASON_CODE,
                              posted_denom_burdened_cost,
                              posted_project_burdened_cost,
                              posted_projfunc_burdened_cost,
                              posted_acct_burdened_cost,
                              adjustment_type
                              )
		       select	ei.receipt_currency_amount,
				ei.receipt_currency_code,
				ei.receipt_exchange_rate,
				ei.denom_currency_code,
				ei.denom_raw_cost,
				ei.denom_burdened_cost,
				ei.acct_currency_code,
				ei.acct_rate_date,
				ei.acct_rate_type,
				ei.acct_exchange_rate,
				ei.acct_raw_cost,
				ei.acct_burdened_cost,
				ei.acct_exchange_rounding_limit,
				ei.project_currency_code,
				ei.project_rate_date,
				ei.project_rate_type,
				ei.project_exchange_rate,
				ei.cc_cross_charge_code,
				ei.cc_prvdr_organization_id,
				ei.cc_recvr_organization_id,
				ei.cc_rejection_code,
				ei.denom_tp_currency_code,
				ei.denom_transfer_price,
				ei.acct_tp_rate_type,
				ei.acct_tp_rate_date,
				ei.acct_tp_exchange_rate,
				ei.acct_transfer_price,
				ei.projacct_transfer_price,
				ei.cc_markup_base_code,
				ei.tp_base_amount,
				ei.cc_cross_charge_type,
				ei.recvr_org_id,
				ei.cc_bl_distributed_code,
				ei.cc_ic_processed_code,
				ei.tp_ind_compiled_set_id,
				ei.tp_bill_rate,
				ei.tp_bill_markup_percentage,
				ei.tp_schedule_line_percentage,
				ei.tp_rule_percentage,
				ei.cc_prvdr_cost_reclass_code,
				ei.crl_asset_creation_status_code,
				ei.crl_asset_creation_rej_code,
				ei.cost_job_id,
				ei.tp_job_id,
				ei.prov_proj_bill_job_id,
				ei.cost_dist_warning_code,
				ei.project_tp_rate_date,
				ei.project_tp_rate_type,
				ei.project_tp_exchange_rate,
				ei.projfunc_tp_rate_date,
				ei.projfunc_tp_rate_type,
				ei.projfunc_tp_exchange_rate,
				ei.projfunc_transfer_price,
				ei.bill_trans_forecast_curr_code,
				ei.bill_trans_forecast_revenue,
				ei.projfunc_rev_rate_date,
				ei.projfunc_rev_exchange_rate,
				ei.projfunc_cost_rate_type,
				ei.projfunc_cost_rate_date,
				ei.projfunc_cost_exchange_rate,
				ei.project_raw_cost,
				ei.project_burdened_cost,
				ei.assignment_id,
				ei.work_type_id,
				ei.projfunc_raw_revenue,
				ei.project_bill_amount,
				ei.projfunc_currency_code,
				ei.project_raw_revenue,
				ei.project_transfer_price,
				ei.tp_amt_type_code,
				ei.bill_trans_currency_code,
				ei.bill_trans_raw_revenue,
				ei.bill_trans_bill_amount,
				ei.bill_trans_adjusted_revenue,
				ei.revproc_currency_code,
				ei.revproc_rate_type,
				ei.revproc_rate_date,
				ei.revproc_exchange_rate,
				ei.invproc_currency_code,
				ei.invproc_rate_type,
				ei.invproc_rate_date,
				ei.discount_percentage,
				ei.labor_multiplier,
				ei.amount_calculation_code,
				ei.bill_markup_percentage,
				ei.rate_source_id,
				ei.invproc_exchange_rate,
				ei.inv_gen_rejection_code,
				ei.projfunc_bill_amount,
				ei.project_rev_rate_type,
				ei.project_rev_rate_date,
				ei.project_rev_exchange_rate,
				ei.projfunc_rev_rate_type,
				ei.projfunc_inv_rate_type,
				ei.projfunc_inv_rate_date,
				ei.projfunc_inv_exchange_rate,
				ei.project_inv_rate_type,
				ei.project_inv_rate_date,
				ei.project_inv_exchange_rate,
				ei.projfunc_fcst_rate_type,
				ei.projfunc_fcst_rate_date,
				ei.projfunc_fcst_exchange_rate,
				ei.prvdr_accrual_date,
				ei.recvr_accrual_date,
                                    ei.quantity,
                                    ei.non_labor_resource,
                                    ei.organization_id,
                                    ei.override_to_organization_id,
                                    ei.denorm_id,
                                    ei.raw_cost,
                                    ei.raw_cost_rate,
                                    ei.burden_cost,
                                    ei.burden_cost_rate,
                                    ei.cost_dist_rejection_code,
                                    ei.labor_cost_multiplier_name,
                                    ei.raw_revenue,
                                    ei.bill_rate,
                                    ei.accrued_revenue,
                                    ei.accrual_rate,
                                    ei.adjusted_revenue,
                                    ei.adjusted_rate,
                                    ei.bill_amount,
                                    ei.forecast_revenue,
                                    ei.bill_rate_multiplier,
                                    ei.rev_dist_rejection_code,
                                    ei.event_num,
                                    ei.event_task_id,
                                    ei.bill_job_id,
                                    ei.bill_job_billing_title,
                                    ei.bill_employee_billing_title,
                                    ei.adjusted_expenditure_item_id,
                                    ei.net_zero_adjustment_flag,
                                    ei.transferred_from_exp_item_id,
                                    ei.converted_flag,
                                    ei.last_update_login,
                                    ei.request_id,
                                    ei.program_application_id,
                                    ei.program_id,
                                    ei.program_update_date,
                                    ei.attribute_category,
                                    ei.attribute1,
                                    ei.expenditure_item_id,
                                    ei.last_update_date,
                                    ei.last_updated_by,
                                    ei.creation_date,
                                    ei.created_by,
                                    ei.expenditure_id,
                                    ei.task_id,
                                    ei.expenditure_item_date,
                                    ei.expenditure_type,
                                    ei.cost_distributed_flag,
                                    ei.revenue_distributed_flag,
                                    ei.billable_flag,
                                    ei.bill_hold_flag,
                                    ei.attribute2,
                                    ei.attribute3,
                                    ei.attribute4,
                                    ei.attribute5,
                                    ei.attribute6,
                                    ei.attribute7,
                                    ei.attribute8,
                                    ei.attribute9,
                                    ei.attribute10,
                                    ei.cost_ind_compiled_set_id,
                                    ei.rev_ind_compiled_set_id,
                                    ei.inv_ind_compiled_set_id,
                                    ei.cost_burden_distributed_flag,
                                    ei.ind_cost_dist_rejection_code,
                                    ei.orig_transaction_reference,
                                    ei.transaction_source,
                                    ei.project_id,
                                    ei.source_expenditure_item_id,
                                    ei.job_id,
                                    ei.org_id,
                                    ei.System_Linkage_Function,
                                    ei.Burden_Sum_Dest_Run_Id,
                                    p_purge_batch_id,
                                    p_purge_release,
                                    p_project_id,
                                    ei.RATE_DISC_REASON_CODE
                              ei.posted_denom_burdened_cost,
                              ei.posted_project_burdened_cost,
                              ei.posted_projfunc_burdened_cost,
                              ei.posted_acct_burdened_cost,
                              ei.adjustment_type
                               from pa_expenditure_items_all ei
                              where ei.expenditure_item_id in ( select ei1.transferred_from_exp_item_id
                                                                  from Pa_Expend_item_Adj_Activities eia,
                                                                       pa_expenditure_items_all ei1
                                                                 where ei1.expenditure_item_id = eia.expenditure_item_id
                                                                   and eia.request_id = l_request_id
                                                                   and eia.exception_activity_code= 'SOURCE PURGED'
                                                                   and ei1.transferred_from_exp_item_id is not null ) ;


                           l_NoOfRecordsIns :=  SQL%ROWCOUNT ;

                      end if ;

                      x_err_stage := 'PA_ExpItemsSrcPurge: Deleting records into pa_expenditure_items_all';
                      delete from pa_expenditure_items_all ei
                       where ei.expenditure_item_id in ( select ei1.transferred_from_exp_item_id
                                                           from Pa_Expend_item_Adj_Activities eia,
                                                                pa_expenditure_items_all ei1
                                                          where ei1.expenditure_item_id = eia.expenditure_item_id
                                                            and eia.request_id = l_request_id
                                                            and eia.exception_activity_code= 'SOURCE PURGED'
                                                            and ei1.transferred_from_exp_item_id is not null ) ;


                      l_NoOfRecordsDel :=  SQL%ROWCOUNT ;
*/

                     x_err_stage := 'PA_ExpItemsSrcPurge: Deleting the links between expenditure items' ;
                     update pa_expenditure_items_all ei
                        set ei.transferred_from_exp_item_id = NULL
                      where ei.expenditure_item_id in ( select eia.expenditure_item_id
                                                          from Pa_Expend_item_Adj_Activities eia
                                                         where eia.request_id = l_request_id
                                                           and eia.exception_activity_code= 'SOURCE PURGED')
                        and ei.transferred_from_exp_item_id is not null  ;


                     -- After "deleting" or "deleting and inserting" a set of records
                     -- the transaction is commited. This also creates a record in the
                     -- Pa_Purge_Project_details which will show the no. of records
                     -- that are purged from each table.

                     x_err_stage := 'PA_ExpenditureComments: Commiting the transaction' ;

                     /* */
               end if;
          END LOOP ;

          x_err_stack    := l_old_err_stack ;

 EXCEPTION
  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error then
       RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
--  x_err_stage := l_err_stage ;
    pa_debug.debug('Error Procedure Name  := PA_PURGE_COSTING.PA_EXPITEMSSRCPURGE' );
    pa_debug.debug('Error stage is '||x_err_stage );
    pa_debug.debug('Error stack is '||x_err_stack );
    pa_debug.debug(SQLERRM);
    PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM ;

    RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

 end PA_ExpItemsSrcPurge ;

-- Start of comments
-- API name         : PA_ExpItemsDestPurge
-- Type             : Public
-- Pre-reqs         : None
-- Function         : This procedure purges all expenditure items that were
--                    transferred from some other expenditure item.
--
-- Parameters       : Refer to the comments of the previous procedure
--
-- End of comments

 procedure PA_ExpItemsDestPurge( p_purge_batch_id         IN NUMBER,
                                 p_project_id             IN NUMBER,
                                 p_txn_to_date            IN DATE,
                                 p_purge_release          IN VARCHAR2,
                                 p_archive_flag           IN VARCHAR2,
                                 p_commit_size            IN NUMBER,
                                 x_err_code           IN OUT NOCOPY  NUMBER,
                                 x_err_stack          IN OUT NOCOPY  VARCHAR2,
                                 x_err_stage          IN OUT NOCOPY  VARCHAR2
                               )    is

     l_old_err_stage         VARCHAR2(2000);
     l_old_err_stack         VARCHAR2(2000);
     l_NoOfRecordsIns        NUMBER;
     l_NoOfRecordsDel        NUMBER;
     l_Request_Id            NUMBER;
     l_exp_ind               NUMBER;
     l_fetch_complete        BOOLEAN:= FALSE;

     cursor c_exp_open_lines is
     select ei.transferred_from_exp_item_id
     from pa_expenditure_items_all ei
     where ei.expenditure_item_date <= p_txn_to_date
     and ei.transferred_from_exp_item_id is not null
     and ei.project_id = p_project_id;

     cursor c_exp_close_lines is
     select ei.transferred_from_exp_item_id
     from pa_expenditure_items_all ei
     where ei.transferred_from_exp_item_id is not null
     and ei.project_id = p_project_id;

     l_exp_item_id_tab     PA_PLSQL_DATATYPES.IdTabTyp;
     l_exp_item_id_tab_emp PA_PLSQL_DATATYPES.IdTabTyp;

 begin


     l_old_err_stack := x_err_stack;

     x_err_stack := x_err_stack || ' ->Before insert into PA_Expenditure_Items_AR' ;

     if p_archive_flag = 'Y' then
        l_commit_size := trunc(p_commit_size / 5) ;
     else

        l_commit_size := trunc(p_commit_size / 3) ;
     end if ;

     IF p_txn_to_date is not null THEN
        OPEN c_exp_open_lines;
     ELSE
        OPEN c_exp_close_lines;
     END IF;

     LOOP
          l_exp_item_id_tab := l_exp_item_id_tab_emp;
          IF p_txn_to_date is not null THEN
             FETCH c_exp_open_lines BULK COLLECT INTO l_exp_item_id_tab LIMIT l_commit_size;
                   IF c_exp_open_lines%NOTFOUND THEN
                      CLOSE c_exp_open_lines;
                      l_fetch_complete := TRUE;
                   END IF;
          ELSE
             FETCH c_exp_close_lines BULK COLLECT INTO l_exp_item_id_tab LIMIT l_commit_size;
                   IF c_exp_close_lines%NOTFOUND THEN
                      CLOSE c_exp_close_lines;
                      l_fetch_complete := TRUE;
                   END IF;
         END IF;

           IF (nvl(l_exp_item_id_tab.LAST,0) > 0 ) THEN
               Select Pa_Expend_Item_Adj_Act_s.nextval
                 into l_request_id
                 from dual ;
--             l_request_id := Pa_Expend_Item_Adj_Act_s.nextval ;
               x_err_stage := 'PA_ExpItemsDestPurge: Before inserting audit records  ' ;
           /*  if p_txn_to_date is NOT NULL then  */
               FORALL l_exp_ind IN l_exp_item_id_tab.FIRST .. l_exp_item_id_tab.LAST
               insert into Pa_Expend_item_Adj_Activities
               ( expenditure_item_id,
                 activity_date,
                 last_update_date,
                 last_updated_by,
                 creation_date,
                 created_by,
                 exception_activity_code,
                 module_code,
                 last_update_login,
                 request_id
                 )
               select ei.expenditure_item_id,
                      sysdate,
                      sysdate,
                      g_user,
                      sysdate,
                      g_user,
                      'DESTINATION PURGED',
                      'PURGE PROCESS',
                      g_user,
                      l_Request_Id
               from pa_expenditure_items_all ei
               where ei.expenditure_item_id = l_exp_item_id_tab(l_exp_ind)
                                              /* in ( select ei1.transferred_from_exp_item_id
                                                    from pa_expenditure_items_all ei1
                                                    where ei1.expenditure_item_date <= p_txn_to_date
                                                     and ei1.transferred_from_exp_item_id is not null
                                                     and ei1.project_id = p_project_id )
               and rownum < l_commit_size */
               and not exists ( select pp.project_id
                                  from pa_purge_projects pp
                                 where pp.project_id = ei.project_id
                                   and pp.purge_batch_id = p_purge_batch_id );
           /* else */
          /*  end if;  */

/*               if SQL%ROWCOUNT = 0 then
                   exit ; */

/* Commented for performance issue.....  */
               end if;
               IF ( l_fetch_complete ) THEN
                   exit;
               END IF;
          END LOOP ;

          x_err_stack    := l_old_err_stack ;

 EXCEPTION
  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error then
       RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
--  x_err_stage := l_err_stage ;
    pa_debug.debug('Error Procedure Name  := PA_PURGE_COSTING.PA_EXPITEMSDESTPURGE' );
    pa_debug.debug('Error stage is '||x_err_stage );
    pa_debug.debug('Error stack is '||x_err_stack );
    pa_debug.debug(SQLERRM);
    PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM ;

    RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

 end PA_ExpItemsDestPurge ;

-- Start of comments
-- API name         : PA_Routings1
-- Type             : Public
-- Pre-reqs         : None
-- Function         : This procedure purges all the routing records whose expenditures
--                    does not have any expenditure items.
--
-- Parameters       : Refer to the comments of the previous procedure
--
-- End of comments

 procedure PA_Routings1  ( p_purge_batch_id         IN NUMBER,
                          p_project_id             IN NUMBER,
                          p_purge_release          IN VARCHAR2,
                          p_archive_flag           IN VARCHAR2,
                          p_commit_size            IN NUMBER,
                          x_err_code           IN OUT NOCOPY  NUMBER,
                          x_err_stack          IN OUT NOCOPY  VARCHAR2,
                          x_err_stage          IN OUT NOCOPY  VARCHAR2
                        )    is

     l_old_err_stage         VARCHAR2(2000);
     l_old_err_stack         VARCHAR2(2000);
     l_NoOfRecordsIns        NUMBER;
     l_NoOfRecordsDel        NUMBER;
 begin

     l_old_err_stack := x_err_stack;

     x_err_stack := x_err_stack || ' ->Before insert into Routings_AR' ;

     LOOP
               if p_archive_flag = 'Y' then
                     -- If archive option is selected then the records are
                     -- inserted into the archived into the archive tables
                     -- before being purged. The where condition is such that
                     -- only the it inserts half the no. of records specified
                     -- in the commit size.

                     l_commit_size := p_commit_size / 2 ;

                     x_err_stage := 'PA_Routings1: Before inserting records into PA_Routings_AR' ;
                     insert into PA_Routings_AR
                           (
                             Expenditure_Id,
                             Routed_From_Person_Id,
                             Start_Date,
                             Routing_Status_Code,
                             Creation_Date,
                             Created_By,
                             Last_Update_Date,
                             Last_Updated_By,
                             Last_Update_Login,
                             Routed_To_Person_Id,
                             End_Date,
                             Routing_Comment,
                             purge_batch_id,
                             purge_release,
                             purge_project_id
                           )
                       Select ro.Expenditure_Id,
                              ro.Routed_From_Person_Id,
                              ro.Start_Date,
                              ro.Routing_Status_Code,
                              ro.Creation_Date,
                              ro.Created_By,
                              ro.Last_Update_Date,
                              ro.Last_Updated_By,
                              ro.Last_Update_Login,
                              ro.Routed_To_Person_Id,
                              ro.End_Date,
                              ro.Routing_Comment,
                              p_purge_batch_id,
                              p_purge_release,
                              p_project_id
                          from pa_routings ro
                         where not exists
                                      ( select x.expenditure_id
                                          from pa_expenditures_all x
                                         where ro.expenditure_id = x.expenditure_id)
                           and rownum < l_commit_size ;

                     l_NoOfRecordsIns := SQL%ROWCOUNT ;

                     if SQL%ROWCOUNT > 0 then
                         -- We have a seperate delete statement if the archive option is
                         -- selected because if archive option is selected the the records
                         -- being purged will be those records which are already archived.
                         -- table and

                         x_err_stage := 'PA_Routings1: Before deleting records from pa_routings' ;

                         delete from pa_routings ro
                          where (ro.expenditure_id, ro.start_date ) in
                                          ( select roar.expenditure_id, roar.start_date
                                              from pa_routings_ar roar
                                             where roar.purge_project_id = p_project_id
                                          ) ;

                         l_NoOfRecordsDel :=  SQL%ROWCOUNT ;
                     end if ;
               else

                     l_commit_size := p_commit_size ;

                     -- If the archive option is not selected then the delete will
                     -- be based on the commit size.

                     x_err_stage := 'PA_Routings1: Before deleting records from pa_routings' ;
                     delete from pa_routings ro
                      where not exists
                                      ( select x.expenditure_id
                                          from pa_expenditures_all x
                                         where ro.expenditure_id = x.expenditure_id)
                        and rownum < l_commit_size ;

                    l_NoOfRecordsDel :=  SQL%ROWCOUNT ;
               end if ;

               if SQL%ROWCOUNT = 0 then
                     -- Once the SqlCount becomes 0, which means that there are
                     -- no more records to be purged then we exit the loop.

                     x_err_stage := 'PA_Routings1: No more records to archive / purge ' ;
                     exit ;

               else
                     -- After "deleting" or "deleting and inserting" a set of records
                     -- the transaction is commited. This also creates a record in the
                     -- Pa_Purge_Project_details which will show the no. of records
                     -- that are purged from each table.

                     x_err_stage := 'PA_Routings1: Commiting the transaction' ;
                     pa_purge.CommitProcess(p_purge_batch_id,
                                            p_project_id,
                                            'PA_ROUTINGS',
                                            l_NoOfRecordsIns,
                                            l_NoOfRecordsDel,
                                            x_err_code,
                                            x_err_stack,
                                            x_err_stage
                                           ) ;

               end if ;
     END LOOP ;

     x_err_stack    := l_old_err_stack ;

 EXCEPTION
  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error then
       RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
--  x_err_stage := l_err_stage ;
    pa_debug.debug('Error Procedure Name  := PA_PURGE_COSTING.PA_ROUTINGS1' );
    pa_debug.debug('Error stage is '||x_err_stage );
    pa_debug.debug('Error stack is '||x_err_stack );
    pa_debug.debug(SQLERRM);
    PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM ;

    RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

 end PA_Routings1 ;

-- Start of comments
-- API name         : PA_Expenditures1
-- Type             : Public
-- Pre-reqs         : None
-- Function         : This procedure purges all the expenditures that does not
--                    have any expenditure items.
--
-- Parameters       : Refer to the comments of the previous procedure
--
-- End of comments

 procedure PA_Expenditures1  ( p_purge_batch_id         IN NUMBER,
                              p_project_id             IN NUMBER,
                              p_purge_release          IN VARCHAR2,
                              p_archive_flag           IN VARCHAR2,
                              p_commit_size            IN NUMBER,
                              x_err_code           IN OUT NOCOPY  NUMBER,
                              x_err_stack          IN OUT NOCOPY  VARCHAR2,
                              x_err_stage          IN OUT NOCOPY  VARCHAR2
                            )    is

     l_old_err_stage         VARCHAR2(2000);
     l_old_err_stack         VARCHAR2(2000);
     l_NoOfRecordsIns        NUMBER;
     l_NoOfRecordsDel        NUMBER;
 begin

     l_old_err_stack := x_err_stack;

     x_err_stack := x_err_stack || ' ->Before insert into Expenditures_AR' ;

     LOOP
               if p_archive_flag = 'Y' then
                     -- If archive option is selected then the records are
                     -- inserted into the archived into the archive tables
                     -- before being purged. The where condition is such that
                     -- only the it inserts half the no. of records specified
                     -- in the commit size.

                     l_commit_size := p_commit_size / 2 ;

                     x_err_stage := 'PA_Expenditures1: Before insert into PA_Expenditures_AR' ;
                     insert into PA_Expenditures_AR
                           (
                             Expenditure_Id,
                             Last_Update_Date,
                             Last_Updated_By,
                             Creation_Date,
                             Created_By,
                             Expenditure_Status_Code,
                             Expenditure_Ending_Date,
                             Expenditure_Class_Code,
                             Incurred_By_Person_Id,
                             Incurred_By_Organization_Id,
                             Expenditure_Group,
                             Control_Total_Amount,
                             Entered_By_Person_Id,
                             Description,
                             Initial_Submission_Date,
                             Last_Update_Login,
                             Request_Id,
                             Program_Id,
                             Program_Application_Id,
                             Program_Update_Date,
                             Attribute_Category,
                             Attribute1,
                             Attribute2,
                             Attribute3,
                             Attribute4,
                             Attribute5,
                             Attribute6,
                             Attribute7,
                             Attribute8,
                             Attribute9,
                             Attribute10,
                             Pte_Reference,
                             Org_Id,
			     OVERRIDING_APPROVER_PERSON_ID,
			     WF_STATUS_CODE,
			     TRANSFER_STATUS_CODE,
			     ORIG_EXP_TXN_REFERENCE1,
			     ORIG_USER_EXP_TXN_REFERENCE,
			     ORIG_EXP_TXN_REFERENCE2,
			     ORIG_EXP_TXN_REFERENCE3,
			     USER_BATCH_NAME,
			     DENOM_CURRENCY_CODE,
			     ACCT_CURRENCY_CODE,
			     ACCT_RATE_DATE,
			     ACCT_RATE_TYPE,
			     ACCT_EXCHANGE_RATE,
			     VENDOR_ID,
			     purge_batch_id,
                             purge_release,
                             purge_project_id,
			     Person_Type         -- CWK and FPM Changes
                           )
                       Select x.Expenditure_Id,
                              x.Last_Update_Date,
                              x.Last_Updated_By,
                              x.Creation_Date,
                              x.Created_By,
                              x.Expenditure_Status_Code,
                              x.Expenditure_Ending_Date,
                              x.Expenditure_Class_Code,
                              x.Incurred_By_Person_Id,
                              x.Incurred_By_Organization_Id,
                              x.Expenditure_Group,
                              x.Control_Total_Amount,
                              x.Entered_By_Person_Id,
                              x.Description,
                              x.Initial_Submission_Date,
                              x.Last_Update_Login,
                              x.Request_Id,
                              x.Program_Id,
                              x.Program_Application_Id,
                              x.Program_Update_Date,
                              x.Attribute_Category,
                              x.Attribute1,
                              x.Attribute2,
                              x.Attribute3,
                              x.Attribute4,
                              x.Attribute5,
                              x.Attribute6,
                              x.Attribute7,
                              x.Attribute8,
                              x.Attribute9,
                              x.Attribute10,
                              x.Pte_Reference,
                              x.Org_Id,
                              x.OVERRIDING_APPROVER_PERSON_ID,
                              x.WF_STATUS_CODE,
                              x.TRANSFER_STATUS_CODE,
                              x.ORIG_EXP_TXN_REFERENCE1,
                              x.ORIG_USER_EXP_TXN_REFERENCE,
                              x.ORIG_EXP_TXN_REFERENCE2,
                              x.ORIG_EXP_TXN_REFERENCE3,
			      x.USER_BATCH_NAME,
			      x.DENOM_CURRENCY_CODE,
			      x.ACCT_CURRENCY_CODE,
			      x.ACCT_RATE_DATE,
			      x.ACCT_RATE_TYPE,
			      x.ACCT_EXCHANGE_RATE,
			      x.VENDOR_ID,
                              p_purge_batch_id,
                              p_purge_release,
                              p_project_id,
       	                      x.Person_Type         -- CWK and FPM Changes

                          from pa_expenditures_all x
                         where (x.rowid ) in
                                      ( select x1.rowid
                                          from pa_expenditures_all x1
                                         where not exists ( select ei.expenditure_id
                                                              from pa_expenditure_items_all ei
                                                             where ei.expenditure_id = x1.expenditure_id)
                                           and x1.expenditure_status_code = 'APPROVED'
                                           and rownum < l_commit_size
                                      ) ;

                     l_NoOfRecordsIns := SQL%ROWCOUNT ;

                     if SQL%ROWCOUNT > 0 then
                         -- We have a seperate delete statement if the archive option is
                         -- selected because if archive option is selected the the records
                         -- being purged will be those records which are already archived.
                         -- table and

                         x_err_stage := 'PA_Expenditures1: Before deleting records from pa_expenditures_all' ;
                         delete from pa_expenditures_all x
                          where (x.rowid ) in
                                          ( select x1.rowid
                                              from pa_expenditures_all x1,
                                                   pa_expenditures_ar x2
                                             where x2.expenditure_id = x1.expenditure_id
                                               and x2.purge_project_id = p_project_id
                                          ) ;

                         l_NoOfRecordsDel :=  SQL%ROWCOUNT ;
                     end if ;
               else

                     l_commit_size := p_commit_size ;

                     -- If the archive option is not selected then the delete will
                     -- be based on the commit size.

                     x_err_stage := 'PA_Expenditures1: Before deleting records from pa_expenditures_all' ;
                     delete from pa_expenditures_all x
                      where (x.rowid ) in
                                      ( select x1.rowid
                                          from pa_expenditures_all x1
                                         where not exists ( select ei.expenditure_id
                                                              from pa_expenditure_items_all ei
                                                             where ei.expenditure_id = x1.expenditure_id)
                                           and x1.expenditure_status_code = 'APPROVED'
                                           and rownum < l_commit_size
                                      ) ;

                    l_NoOfRecordsDel :=  SQL%ROWCOUNT ;
               end if ;

               if SQL%ROWCOUNT = 0 then
                     -- Once the SqlCount becomes 0, which means that there are
                     -- no more records to be purged then we exit the loop.

                     x_err_stage := 'PA_Expenditures1: No more records to archive / purge ' ;
                     exit ;

               else
                     -- After "deleting" or "deleting and inserting" a set of records
                     -- the transaction is commited. This also creates a record in the
                     -- Pa_Purge_Project_details which will show the no. of records
                     -- that are purged from each table.

                     x_err_stage := 'PA_Expenditures1: Commiting the transaction' ;
                     pa_purge.CommitProcess(p_purge_batch_id,
                                            p_project_id,
                                            'PA_EXPENDITURES_ALL',
                                            l_NoOfRecordsIns,
                                            l_NoOfRecordsDel,
                                            x_err_code,
                                            x_err_stack,
                                            x_err_stage
                                           ) ;

               end if ;
     END LOOP ;


     x_err_stack    := l_old_err_stack ;

 EXCEPTION
  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error then
       RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
--  x_err_stage := l_err_stage ;
    pa_debug.debug('Error Procedure Name  := PA_PURGE_COSTING.PA_EXPENDITURES1' );
    pa_debug.debug('Error stage is '||x_err_stage );
    pa_debug.debug('Error stack is '||x_err_stack );
    pa_debug.debug(SQLERRM);
    PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM ;

    RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

 end PA_Expenditures1 ;

-- Start of comments
-- API name         : PA_MRCExpenditureItems
-- Type             : Public
-- Pre-reqs         : None
-- Function         : This procedure purges all the MRCexpenditure items that
--                    are not related to other expenditure items through
--                    transferred_from_exp_item_id.
--
-- Parameters       : Refer to the comments of the previous procedure
--
-- End of comments

 procedure PA_MRCExpenditureItems(
			     p_purge_batch_id         	IN NUMBER,
                             p_project_id             	IN NUMBER,
                             p_txn_to_date            	IN DATE,
                             p_purge_release          	IN VARCHAR2,
                             p_archive_flag           	IN VARCHAR2,
                             p_commit_size            	IN NUMBER,
                             x_err_code           	IN OUT NOCOPY  NUMBER,
                             x_err_stack          	IN OUT NOCOPY  VARCHAR2,
                             x_err_stage          	IN OUT NOCOPY  VARCHAR2,
			     x_MRC_NoOfRecordsIns          OUT NOCOPY  NUMBER )
 IS

     l_old_err_stage         VARCHAR2(2000);
     l_old_err_stack         VARCHAR2(2000);

 BEGIN

     l_old_err_stack := x_err_stack;

     x_err_stack := x_err_stack || ' ->Before insert into PA_MC_EXP_ITEMS_AR' ;

     x_err_stage := 'PA_MRCExpenditureItems: Before inserting records into PA_MC_EXP_ITEMS_AR';

      /* Note that purged_project_id in table PA_EXPENDITURE_ITEMS_AR is index
       * Will also need index on PA_MC_EXP_ITEMS_AR columns set_of_books_id and
       * expenditure_item_id.
       * The NOT EXISTS section is to make sure that no attempt is made to insert a
       * duplicate record in table PA_MC_EXP_ITEMS_AR.
       */
     INSERT INTO PA_MC_EXP_ITEMS_AR
              ( SET_OF_BOOKS_ID,
  		EXPENDITURE_ITEM_ID,
  		RAW_COST,
  		RAW_COST_RATE,
  		BURDEN_COST,
  		BURDEN_COST_RATE,
  		RAW_REVENUE,
  		BILL_RATE,
  		ACCRUED_REVENUE,
  		ACCRUAL_RATE,
  		ADJUSTED_REVENUE,
  		ADJUSTED_RATE,
  		BILL_AMOUNT,
  		FORECAST_REVENUE,
  		NET_ZERO_ADJUSTMENT_FLAG,
  		TRANSFERRED_FROM_EXP_ITEM_ID,
		PRC_ASSIGNMENT_ID,
		CURRENCY_CODE,
		COST_EXCHANGE_RATE,
		COST_CONVERSION_DATE,
		COST_RATE_TYPE,
		REVENUE_EXCHANGE_RATE,
		REVENUE_CONVERSION_DATE,
		REVENUE_RATE_TYPE,
		TRANSFER_PRICE,
		TP_EXCHANGE_RATE,
		TP_CONVERSION_DATE,
		TP_RATE_TYPE,
		PROJFUNC_INV_RATE_TYPE,
		PROJFUNC_INV_RATE_DATE,
		PROJFUNC_INV_EXCHANGE_RATE,
		PROJFUNC_FCST_RATE_TYPE,
		PROJFUNC_FCST_RATE_DATE,
                PROJFUNC_FCST_EXCHANGE_RATE,
		PURGE_PROJECT_ID,
  		PURGE_RELEASE,
  		PURGE_BATCH_ID )
     SELECT
		MCEI.SET_OF_BOOKS_ID,
  		MCEI.EXPENDITURE_ITEM_ID,
  		MCEI.RAW_COST,
  		MCEI.RAW_COST_RATE,
  		MCEI.BURDEN_COST,
  		MCEI.BURDEN_COST_RATE,
  		MCEI.RAW_REVENUE,
  		MCEI.BILL_RATE,
  		MCEI.ACCRUED_REVENUE,
  		MCEI.ACCRUAL_RATE,
  		MCEI.ADJUSTED_REVENUE,
  		MCEI.ADJUSTED_RATE,
  		MCEI.BILL_AMOUNT,
  		MCEI.FORECAST_REVENUE,
  		MCEI.NET_ZERO_ADJUSTMENT_FLAG,
  		MCEI.TRANSFERRED_FROM_EXP_ITEM_ID,
		MCEI.PRC_ASSIGNMENT_ID,
		MCEI.CURRENCY_CODE,
		MCEI.COST_EXCHANGE_RATE,
		MCEI.COST_CONVERSION_DATE,
		MCEI.COST_RATE_TYPE,
		MCEI.REVENUE_EXCHANGE_RATE,
		MCEI.REVENUE_CONVERSION_DATE,
		MCEI.REVENUE_RATE_TYPE,
		MCEI.TRANSFER_PRICE,
		MCEI.TP_EXCHANGE_RATE,
		MCEI.TP_CONVERSION_DATE,
		MCEI.TP_RATE_TYPE,
		MCEI.PROJFUNC_INV_RATE_TYPE,
		MCEI.PROJFUNC_INV_RATE_DATE,
		MCEI.PROJFUNC_INV_EXCHANGE_RATE,
		MCEI.PROJFUNC_FCST_RATE_TYPE,
		MCEI.PROJFUNC_FCST_RATE_DATE,
		MCEI.PROJFUNC_FCST_EXCHANGE_RATE,
		P_PROJECT_ID,
  		P_PURGE_RELEASE,
  		P_PURGE_BATCH_ID
       FROM
		PA_EXPENDITURE_ITEMS_AR EI,
		PA_MC_EXP_ITEMS_ALL MCEI
       WHERE
		EI.PURGE_PROJECT_ID       = P_PROJECT_ID
       AND   	MCEI.EXPENDITURE_ITEM_ID  = EI.EXPENDITURE_ITEM_ID
       AND   	NOT EXISTS ( SELECT expenditure_item_id
			     FROM
				    PA_MC_EXP_ITEMS_AR
			     WHERE
				    purge_project_id    = P_PROJECT_ID
			     AND    expenditure_item_id = mcei.expenditure_item_id
			     AND    set_of_books_id     = mcei.set_of_books_id ) ;

       x_MRC_NoOfRecordsIns :=  NVL(SQL%ROWCOUNT,0) ;

       x_err_stack    := l_old_err_stack ;

 EXCEPTION
 	WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error then
       		RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

  	WHEN OTHERS THEN
                pa_debug.debug('Error Procedure Name  := PA_PURGE_COSTING.PA_MRCExpenditureItems' );
    		pa_debug.debug('Error stage is '||x_err_stage );
    		pa_debug.debug('Error stack is '||x_err_stack );
    		pa_debug.debug(SQLERRM);
    		PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM ;

    		RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

 END PA_MRCExpenditureItems ;

-- Start of comments
-- API name         : PA_MRCCostDistLines
-- Type             : Public
-- Pre-reqs         : None
-- Function         : This procedure purges all the Cost Distribution Lines that are
--                    not related to other expenditure items through
--                    transferred_from_exp_item_id.
--
-- Parameters       : Refer to the comments of the previous procedure
--
-- End of comments


 PROCEDURE PA_MRCCostDistLines (
			     p_purge_batch_id	IN NUMBER,
                             p_project_id       IN NUMBER,
                             p_txn_to_date      IN DATE,
                             p_purge_release    IN VARCHAR2,
                             p_archive_flag     IN VARCHAR2,
                             p_commit_size      IN NUMBER,
                             x_err_code         IN OUT NOCOPY  NUMBER,
                             x_err_stack        IN OUT NOCOPY  VARCHAR2,
                             x_err_stage        IN OUT NOCOPY  VARCHAR2,
                             x_MRC_NoOfRecordsIns  OUT NOCOPY  NUMBER )
 IS

     l_old_err_stage       VARCHAR2(2000);
     l_old_err_stack       VARCHAR2(2000);

 BEGIN

     l_old_err_stack := x_err_stack;

     x_err_stack := x_err_stack || ' ->Before insert into MRC PA_MC_CDL_AR ' ;

     x_err_stage := 'Before insert into PA_MC_CDL_AR' ;
     INSERT INTO PA_MC_CDL_AR
               (SET_OF_BOOKS_ID,
       		EXPENDITURE_ITEM_ID,
       		LINE_NUM,
       		LINE_TYPE,
       		TRANSFER_STATUS_CODE,
       		AMOUNT,
       		QUANTITY,
       		REQUEST_ID,
       		PROGRAM_APPLICATION_ID,
       		PROGRAM_ID,
       		PROGRAM_UPDATE_DATE,
       		TRANSFERRED_DATE,
       		TRANSFER_REJECTION_REASON,
       		BATCH_NAME,
       		BURDENED_COST,
       		CURRENCY_CODE,
       		EXCHANGE_RATE,
       		CONVERSION_DATE,
		PRC_ASSIGNMENT_ID,
		RATE_TYPE,
       		PURGE_PROJECT_ID,
       		PURGE_RELEASE ,
       		PURGE_BATCH_ID )
     SELECT
		MC_CDL.SET_OF_BOOKS_ID,
		MC_CDL.EXPENDITURE_ITEM_ID,
		MC_CDL.LINE_NUM,
                MC_CDL.LINE_TYPE,
                MC_CDL.TRANSFER_STATUS_CODE,
                MC_CDL.AMOUNT,
		MC_CDL.QUANTITY,
                MC_CDL.REQUEST_ID,
                MC_CDL.PROGRAM_APPLICATION_ID,
                MC_CDL.PROGRAM_ID,
                MC_CDL.PROGRAM_UPDATE_DATE,
		MC_CDL.TRANSFERRED_DATE,
                MC_CDL.TRANSFER_REJECTION_REASON,
                MC_CDL.BATCH_NAME,
                MC_CDL.BURDENED_COST,
		MC_CDL.CURRENCY_CODE,
		MC_CDL.EXCHANGE_RATE,
		MC_CDL.CONVERSION_DATE,
		MC_CDL.PRC_ASSIGNMENT_ID,
		MC_CDL.RATE_TYPE,
                P_PURGE_BATCH_ID,
                P_PURGE_RELEASE,
                P_PROJECT_ID
     FROM
		PA_MC_COST_DIST_LINES_ALL MC_CDL,
                PA_COST_DIST_LINES_AR AR_CDL
     WHERE
                MC_CDL.EXPENDITURE_ITEM_ID = AR_CDL.EXPENDITURE_ITEM_ID
     AND        MC_CDL.LINE_NUM            = AR_CDL.LINE_NUM
     AND        AR_CDL.PURGE_PROJECT_ID    = P_PROJECT_ID
     AND        NOT EXISTS (
		       SELECT MC_CDL.expenditure_item_id
		       FROM
			      PA_MC_CDL_AR MC_AR_CDL
		       WHERE
			      MC_AR_CDL.purge_project_id    = P_PROJECT_ID
		       AND    MC_AR_CDL.expenditure_item_id = MC_CDL.expenditure_item_id
		       AND    MC_AR_CDL.line_num            = MC_CDL.line_num
                       AND    MC_AR_CDL.set_of_books_id     = MC_CDL.set_of_books_id ) ;

     x_MRC_NoOfRecordsIns := nvl(SQL%ROWCOUNT,0) ;

     x_err_stack    := l_old_err_stack ;

 EXCEPTION
     WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error then
     	RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

     WHEN OTHERS THEN
        pa_debug.debug('Error Procedure Name  := PA_PURGE_COSTING.PA_MRCCOSTDISTLINES');
    	pa_debug.debug('Error stage is '|| x_err_stage );
    	pa_debug.debug('Error stack is '|| x_err_stack );
    	pa_debug.debug(SQLERRM);
    	PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM ;

    	RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

 END PA_MRCCostDistLines ;


-- Start of comments
-- API name         : PA_MRCCcDistLines
-- Type             : Public
-- Pre-reqs         : None
-- Function         : This procedure purges all the CC Distribution Lines in MRC.
--
-- Parameters       : Refer to the comments of the previous procedure
--
-- End of comments


 PROCEDURE PA_MRCCcDistLines( p_purge_batch_id	IN NUMBER,
                             p_project_id       IN NUMBER,
                             p_txn_to_date      IN DATE,
                             p_purge_release    IN VARCHAR2,
                             p_archive_flag     IN VARCHAR2,
                             p_commit_size      IN NUMBER,
                             x_err_code         IN OUT NOCOPY  NUMBER,
                             x_err_stack        IN OUT NOCOPY  VARCHAR2,
                             x_err_stage        IN OUT NOCOPY  VARCHAR2,
                             x_MRC_NoOfRecordsIns  OUT NOCOPY  NUMBER )
 IS

     l_old_err_stage       VARCHAR2(2000);
     l_old_err_stack       VARCHAR2(2000);

 BEGIN

     l_old_err_stack := x_err_stack;

     x_err_stack := x_err_stack || ' ->Before insert into MRC PA_MC_CC_DIST_LINES_AR ' ;

     x_err_stage := 'Before insert into PA_MC_CC_DIST_LINES_AR' ;
     INSERT INTO PA_MC_CC_DIST_LINES_AR
                (PURGE_BATCH_ID,
                 PURGE_RELEASE,
                 PURGE_PROJECT_ID,
                 SET_OF_BOOKS_ID,
                 PRC_ASSIGNMENT_ID,
                 CC_DIST_LINE_ID,
                 EXPENDITURE_ITEM_ID,
                 LINE_NUM,
                 LINE_TYPE,
                 ACCT_CURRENCY_CODE,
                 AMOUNT,
                 PROGRAM_ID,
                 PROGRAM_APPLICATION_ID,
                 PROGRAM_UPDATE_DATE,
                 REQUEST_ID,
                 TRANSFER_STATUS_CODE,
                 ACCT_TP_RATE_TYPE,
                 ACCT_TP_RATE_DATE,
                 ACCT_TP_EXCHANGE_RATE,
                 GL_BATCH_NAME,
                 TRANSFERRED_DATE,
                 TRANSFER_REJECTION_CODE)
         SELECT
                P_PURGE_BATCH_ID,
                P_PURGE_RELEASE,
                P_PROJECT_ID,
                MC_CDL.SET_OF_BOOKS_ID,
                MC_CDL.PRC_ASSIGNMENT_ID,
                MC_CDL.CC_DIST_LINE_ID,
                MC_CDL.EXPENDITURE_ITEM_ID,
                MC_CDL.LINE_NUM,
                MC_CDL.LINE_TYPE,
                MC_CDL.ACCT_CURRENCY_CODE,
                MC_CDL.AMOUNT,
                MC_CDL.PROGRAM_ID,
                MC_CDL.PROGRAM_APPLICATION_ID,
                MC_CDL.PROGRAM_UPDATE_DATE,
                MC_CDL.REQUEST_ID,
                MC_CDL.TRANSFER_STATUS_CODE,
                MC_CDL.ACCT_TP_RATE_TYPE,
                MC_CDL.ACCT_TP_RATE_DATE,
                MC_CDL.ACCT_TP_EXCHANGE_RATE,
                MC_CDL.GL_BATCH_NAME,
                MC_CDL.TRANSFERRED_DATE,
                MC_CDL.TRANSFER_REJECTION_CODE
     FROM
		PA_MC_CC_DIST_LINES_ALL MC_CDL,
                PA_CC_DIST_LINES_AR AR_CDL
     WHERE
                MC_CDL.EXPENDITURE_ITEM_ID = AR_CDL.EXPENDITURE_ITEM_ID
     AND        MC_CDL.LINE_NUM            = AR_CDL.LINE_NUM
     AND        AR_CDL.PURGE_PROJECT_ID    = P_PROJECT_ID
     AND        NOT EXISTS (
		       SELECT MC_CDL.expenditure_item_id
		       FROM
			      PA_MC_CC_DIST_LINES_AR MC_AR_CDL
		       WHERE
			      MC_AR_CDL.purge_project_id    = P_PROJECT_ID
		       AND    MC_AR_CDL.expenditure_item_id = MC_CDL.expenditure_item_id
		       AND    MC_AR_CDL.line_num            = MC_CDL.line_num
                       AND    MC_AR_CDL.set_of_books_id     = MC_CDL.set_of_books_id ) ;

     x_MRC_NoOfRecordsIns := nvl(SQL%ROWCOUNT,0) ;

     x_err_stack    := l_old_err_stack ;

 EXCEPTION
     WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error then
     	RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

     WHEN OTHERS THEN
        pa_debug.debug('Error Procedure Name  := PA_PURGE_COSTING.PA_MRCCCDISTLINES');
    	pa_debug.debug('Error stage is '|| x_err_stage );
    	pa_debug.debug('Error stack is '|| x_err_stack );
    	pa_debug.debug(SQLERRM);
    	PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM ;

    	RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

 END PA_MRCCcDistLines ;

END pa_purge_costing;

/
