--------------------------------------------------------
--  DDL for Package Body PA_PURGE_SUMMARY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PURGE_SUMMARY" as
/* $Header: PAXSUPRB.pls 120.1.12010000.2 2009/06/23 14:24:29 atshukla ship $ */

    l_commit_size     NUMBER ;
    g_def_proj_accum_id NUMBER;

-- private procedures
--
-- The list of parameters is common for all private procedures in the package
------------------------------------------------------------------------------------------
-- Parameters         p_batch_id      IN     NUMBER   -- The purge batch id
--                                                       for which rows have
--                                                       to be purged/archived.
--		      p_project_Id    IN     NUMBER   -- The project id for
--                                                       which records have
--                                                       to be purged/archived.
--		      p_Purge_Release IN     VARCHAR2 -- Oracle Projects release(10.7,11.0)
--		      p_Archive_Flag  IN     VARCHAR2 -- Archive table data
--		      p_Txn_To_Date   IN     DATE     -- Date on or before which all
--                                                       transactions are to be purged
--                                                       (Will be used by Costing only)
--		      p_Commit_Size   IN     NUMBER   -- The commit size
--		      X_Err_Stack     IN OUT VARCHAR2 -- Error stack
--		      X_Err_Stage     IN OUT VARCHAR2 -- Stage in the procedure where
--                                                       error occurred
--		      X_Err_Code      IN OUT NUMBER   -- Error code returned from the procedure
--                                                       = 0 SUCCESS
--                                                       > 0 Application error
--                                                       < 0 Oracle error
-------------------------------------------------------------------------------------------
-- Start of comments
-- API name         : PA_PROJACCUMHEADERS
-- Type             : Private
-- Pre-reqs         : None
-- Function         : Archive and Purge data for table PA_PROJECT_ACCUM_HEADERS
-- Parameters       : See common list above
-- End of comments

 PROCEDURE pa_projaccumheaders
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

 BEGIN

     l_old_err_stack := x_err_stack;

     x_err_stack := x_err_stack || ' ->Entering PA_PROJACCUMHEADERS ';

     pa_debug.debug(x_err_stack);

     LOOP
     l_NoOfRecordsDel := 0;  -- Value of l_NoOfRecordsDel is reset for BUg 4104133
     l_NoOfRecordsIns := 0;  -- Value of l_NoOfRecordsIns is reset for BUg 4104133

               IF p_archive_flag = 'Y' THEN
                     -- If archive option is selected then the records are
                     -- archived into the archive table before being purged.
                     -- The WHERE condition is such that half the no. of records
                     -- specified in commit size are inserted into the archive
                     -- table and same number deleted from the original table

                     l_commit_size := p_commit_size / 2 ;


     pa_debug.debug( ' ->Before insert into PA_PRJ_ACCUM_HEADERS_AR') ;

                     INSERT INTO PA_PRJ_ACCUM_HEADERS_AR
                          (
                               PURGE_BATCH_ID,
                               PURGE_RELEASE,
                               PURGE_PROJECT_ID,
                               PROJECT_ACCUM_ID,
                               PROJECT_ID,
                               TASK_ID,
                               ACCUM_PERIOD,
                               RESOURCE_ID,
                               RESOURCE_LIST_ASSIGNMENT_ID,
                               RESOURCE_LIST_ID,
                               RESOURCE_LIST_MEMBER_ID,
                               LAST_UPDATED_BY,
                               LAST_UPDATE_DATE,
                               CREATION_DATE,
                               CREATED_BY,
                               LAST_UPDATE_LOGIN,
                               REQUEST_ID,
                               PROGRAM_APPLICATION_ID,
                               PROGRAM_ID,
                               PROGRAM_UPDATE_DATE,
                               TASKS_RESTRUCTURED_FLAG,
                               SUM_EXCEPTION_CODE
                           )
                       SELECT
			       p_purge_batch_id,
                               p_purge_release,
                               p_project_id,
                               pah.PROJECT_ACCUM_ID,
                               pah.PROJECT_ID,
                               pah.TASK_ID,
                               pah.ACCUM_PERIOD,
                               pah.RESOURCE_ID,
                               pah.RESOURCE_LIST_ASSIGNMENT_ID,
                               pah.RESOURCE_LIST_ID,
                               pah.RESOURCE_LIST_MEMBER_ID,
                               pah.LAST_UPDATED_BY,
                               pah.LAST_UPDATE_DATE,
                               pah.CREATION_DATE,
                               pah.CREATED_BY,
                               pah.LAST_UPDATE_LOGIN,
                               pah.REQUEST_ID,
                               pah.PROGRAM_APPLICATION_ID,
                               pah.PROGRAM_ID,
                               pah.PROGRAM_UPDATE_DATE,
                               pah.TASKS_RESTRUCTURED_FLAG,
                               pah.SUM_EXCEPTION_CODE
                       FROM pa_project_accum_headers  pah
                       WHERE ( pah.project_id = p_project_id
/* 2485577 */          AND     pah.project_accum_id <> g_def_proj_accum_id
                       AND     rownum <= l_commit_size
                              ) ;

   /*Code Changes for Bug No.2984871 start */
		     l_NoOfRecordsIns :=  SQL%ROWCOUNT ;
   /*Code Changes for Bug No.2984871 end */

     pa_debug.debug( ' ->After insert into PA_PRJ_ACCUM_HEADERS_AR') ;

	/* Commented for Bug 2984871

		     l_NoOfRecordsIns :=  SQL%ROWCOUNT ; */

	/* Commented for Bug 2984871
                     IF SQL%ROWCOUNT > 0 THEN */

	   /*Code Changes for Bug No.2984871 start */
		     IF  l_NoOfRecordsIns> 0 THEN
	   /*Code Changes for Bug No.2984871 end */
			 -- The algorithm for deleting records from original table
                         -- depends on whether records are being archived or not.

                       pa_debug.debug( ' ->Before delete from pa_project_accum_headers ') ;

/* commented and modified as below for performance reasons. Archive Purge 11.5
                         DELETE FROM pa_project_accum_headers pah
                          WHERE (pah.rowid) IN
                                          ( SELECT pah1.rowid
                                            FROM pa_project_accum_headers pah1,
                                                 PA_PRJ_ACCUM_HEADERS_AR pah2
                                      WHERE pah1.project_accum_id = pah2.project_accum_id
                                            AND   pah2.purge_project_id = p_project_id
                                          ) ;
*/

                         DELETE FROM pa_project_accum_headers pah
                          WHERE (pah.project_accum_id) IN
                                          ( SELECT pah2.project_accum_id
                                            FROM PA_PRJ_ACCUM_HEADERS_AR pah2
                                      WHERE pah2.purge_project_id = p_project_id
                                          ) ;

	   /*Code Changes for Bug No.2984871 start */
		     l_NoOfRecordsDel :=  SQL%ROWCOUNT ;
	   /*Code Changes for Bug No.2984871 end */

			pa_debug.debug( ' ->After delete from pa_project_accum_headers ') ;

                     END IF ;
               ELSE

                     l_commit_size := p_commit_size ;

                     -- If the archive option is not selected then the delete will
                     -- be based on the commit size.


                       pa_debug.debug( ' ->Before delete from pa_project_accum_headers ') ;
/* commented and modified as below for performance reasons. Archive Purge 11.5
                         DELETE FROM pa_project_accum_headers pah
                          WHERE (pah.rowid) IN
                                          (  SELECT pah.rowid
                                             FROM   pa_project_accum_headers pah
                                             WHERE  pah.project_id = p_project_id
					     AND    rownum <= l_commit_size
                                          ) ;
*/

                         DELETE FROM pa_project_accum_headers pah
                          WHERE pah.project_id = p_project_id
/* 2485577 */             AND   pah.project_accum_id <> g_def_proj_accum_id
	                    AND rownum <= l_commit_size;


   /*Code Changes for Bug No.2984871 start */
		    l_NoOfRecordsDel := SQL%ROWCOUNT ;
   /*Code Changes for Bug No.2984871 end */
			pa_debug.debug( ' ->After delete from pa_project_accum_headers ') ;
               END IF ;

/* Commented for Bug 2984871
	      IF SQL%ROWCOUNT = 0 THEN*/

   /*Code Changes for Bug No.2984871 start */
	      IF  l_NoOfRecordsDel= 0 THEN
   /*Code Changes for Bug No.2984871 end */
		     -- SqlCount = 0 means there are no more records to be purged
                     exit ;

              ELSE
                     -- After "deleting" or "deleting and inserting" a set of records
                     -- the transaction is commited. This also creates a record in the
                     -- Pa_Purge_Project_details which will show the no. of records
                     -- that are purged from each table.

                         pa_debug.debug( ' ->Calling pa_purge.CommitProcess ') ;

                      pa_purge.CommitProcess
                               (p_purge_batch_id             => p_purge_batch_id,
                                p_project_id                 => p_project_id,
                                p_table_name                 => 'PA_PROJECT_ACCUM_HEADERS',
                                p_NoOfRecordsIns             => l_NoOfRecordsIns,
                                p_NoOfRecordsDel             => l_NoOfRecordsDel,
                                x_err_code                   => x_err_code,
                                x_err_stack                  => x_err_stack,
                                x_err_stage                  => x_err_stage
                                ) ;


            END IF ;
     END LOOP ;

     x_err_stack    := l_old_err_stack ;

 EXCEPTION
  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error THEN
       RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
    pa_debug.debug('Error Procedure Name  := PA_PURGE_SUMMARY.PA_PROJACCUMHEADERS' );
    pa_debug.debug('Error stage is '||x_err_stage );
    pa_debug.debug('Error stack is '||x_err_stack );
    pa_debug.debug(SQLERRM);
    PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM ;

    RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

 END pa_projaccumheaders ;

-- Start of comments
-- API name         : PA_ProjAccumCommitments
-- Type             : Private
-- Pre-reqs         : None
-- Function         : Archive and Purge data for table PA_PROJECT_ACCUM_COMMITMENTS
-- Parameters       : See common list above
-- End of comments

 PROCEDURE PA_ProjAccumCommitments
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
 BEGIN

     l_old_err_stack := x_err_stack;

     x_err_stack := x_err_stack || ' Entering PA_ProjAccumCommitments ' ;

     pa_debug.debug(x_err_stack);

     LOOP
      l_NoOfRecordsDel := 0;  -- Value of l_NoOfRecordsDel is reset for BUg 4104133
      l_NoOfRecordsIns := 0;  -- Value of l_NoOfRecordsIns is reset for BUg 4104133
               IF p_archive_flag = 'Y' THEN
                     -- If archive option is selected then the records are
                     -- archived into the archive table before being purged.
                     -- The WHERE condition is such that half the no. of records
                     -- specified in commit size are inserted into the archive
                     -- table and same number deleted from the original table

                     l_commit_size := p_commit_size / 2 ;

     pa_debug.debug( ' ->Before insert into PA_Project_Accum_Commitments') ;

-- The archive table name is different from the original table to limit
-- table name to 30 characters.

                     INSERT INTO PA_PRJ_ACCUM_COMMIT_AR
                          (
		               PURGE_BATCH_ID,
                               PURGE_RELEASE,
                               PURGE_PROJECT_ID,
                               PROJECT_ACCUM_ID,
                               CMT_RAW_COST_ITD,
                               CMT_RAW_COST_YTD,
                               CMT_RAW_COST_PP,
                               CMT_RAW_COST_PTD,
                               CMT_BURDENED_COST_ITD,
                               CMT_BURDENED_COST_YTD,
                               CMT_BURDENED_COST_PP,
                               CMT_BURDENED_COST_PTD,
                               CMT_QUANTITY_ITD,
                               CMT_QUANTITY_YTD,
                               CMT_QUANTITY_PP,
                               CMT_QUANTITY_PTD,
                               CMT_UNIT_OF_MEASURE,
                               LAST_UPDATED_BY,
                               LAST_UPDATE_DATE,
                               CREATION_DATE,
                               CREATED_BY,
                               LAST_UPDATE_LOGIN,
                               REQUEST_ID,
                               PROGRAM_APPLICATION_ID,
                               PROGRAM_ID,
                               PROGRAM_UPDATE_DATE
                           )
                       SELECT
		               p_purge_batch_id,
                               p_purge_release,
                               p_project_id,
                               pac.PROJECT_ACCUM_ID,
                               pac.CMT_RAW_COST_ITD,
                               pac.CMT_RAW_COST_YTD,
                               pac.CMT_RAW_COST_PP,
                               pac.CMT_RAW_COST_PTD,
                               pac.CMT_BURDENED_COST_ITD,
                               pac.CMT_BURDENED_COST_YTD,
                               pac.CMT_BURDENED_COST_PP,
                               pac.CMT_BURDENED_COST_PTD,
                               pac.CMT_QUANTITY_ITD,
                               pac.CMT_QUANTITY_YTD,
                               pac.CMT_QUANTITY_PP,
                               pac.CMT_QUANTITY_PTD,
                               pac.CMT_UNIT_OF_MEASURE,
                               pac.LAST_UPDATED_BY,
                               pac.LAST_UPDATE_DATE,
                               pac.CREATION_DATE,
                               pac.CREATED_BY,
                               pac.LAST_UPDATE_LOGIN,
                               pac.REQUEST_ID,
                               pac.PROGRAM_APPLICATION_ID,
                               pac.PROGRAM_ID,
                               pac.PROGRAM_UPDATE_DATE
		       FROM pa_project_accum_commitments pac
      /* commented and modified as below for performance reasons. Archive Purge 11.5
                       WHERE (pac.rowid) IN
                             (   SELECT pac1.rowid
                                 FROM   pa_project_accum_commitments pac1,
                                        pa_project_accum_headers pah
                                 WHERE  pac1.project_accum_id=pah.project_accum_id
                                 AND    pah.project_id = p_project_id
                                 AND    rownum < l_commit_size
                                ) ;
      */
                       WHERE  (pac.project_accum_id) in
                             (   SELECT pah.project_accum_id
                                 FROM   pa_project_accum_headers pah
                                 WHERE  pah.project_id = p_project_id
/* 2485577 */                    AND    pah.project_accum_id <> g_def_proj_accum_id
                                 AND    rownum < l_commit_size
                                ) ;

   /*Code Changes for Bug No.2984871 start */
		     l_NoOfRecordsIns := SQL%ROWCOUNT ;
   /*Code Changes for Bug No.2984871 end */

     pa_debug.debug( ' ->After insert into PA_Project_Accum_Commitments') ;

   /*Code Changes for Bug No.2984871 start */
		     IF l_NoOfRecordsIns > 0 THEN
   /*Code Changes for Bug No.2984871 end*/
			 -- The algorithm for deleting records from original table
                         -- depends on whether records are being archived or not.
                  pa_debug.debug( ' ->Before delete from pa_project_accum_commitments ') ;
/* commented and modified as below for performance reasons. Archive Purge 11.5
                         DELETE FROM pa_project_accum_commitments PAC
                          WHERE (pac.rowid) IN
                                ( SELECT pac1.rowid
                                  FROM pa_project_accum_commitments pac1,
                                       PA_PRJ_ACCUM_COMMIT_AR pac2
                                  WHERE pac1.project_accum_id = pac2.project_accum_id
                                  AND pac2.purge_project_id=p_project_id
                                ) ;
*/
                         DELETE FROM pa_project_accum_commitments PAC
                          WHERE (pac.project_accum_id) IN
                                ( SELECT pac2.project_accum_id
                                  FROM PA_PRJ_ACCUM_COMMIT_AR pac2
                                  WHERE pac2.purge_project_id=p_project_id
                                ) ;
   /*Code Changes for Bug No.2984871 start */
		     l_NoOfRecordsDel :=  SQL%ROWCOUNT ;
   /*Code Changes for Bug No.2984871 end */
		    pa_debug.debug( ' ->After delete from pa_project_accum_commitments ') ;
                     END IF ;
               ELSE

                     l_commit_size := p_commit_size ;

                     -- If the archive option is not selected then the delete will
                     -- be based on the commit size.

                   pa_debug.debug( ' ->Before delete from pa_project_accum_commitments ') ;
/* commented and modified as below for performance reasons. Archive Purge 11.5
                         DELETE FROM pa_project_accum_commitments pac
                          WHERE (pac.rowid) IN
                                ( SELECT pac1.rowid
                                  FROM pa_project_accum_commitments pac1,
                                       pa_project_accum_headers pah
                                  WHERE pac1.project_accum_id=pah.project_accum_id
                                  AND   pah.project_id = p_project_id
			          AND rownum <= l_commit_size
                                ) ;
*/

                         DELETE FROM pa_project_accum_commitments pac
                          WHERE (pac.project_accum_id) IN
                                ( SELECT pah.project_accum_id
                                  FROM pa_project_accum_headers pah
                                  WHERE pah.project_id = p_project_id
/* 2485577 */                     AND pah.project_accum_id <> g_def_proj_accum_id
			          AND rownum <= l_commit_size
                                ) ;
   /*Code Changes for Bug No.2984871 start */
		    l_NoOfRecordsDel := SQL%ROWCOUNT ;
   /*Code Changes for Bug No.2984871 end */

		    pa_debug.debug( ' ->After delete from pa_project_accum_commitments ') ;
               END IF ;

   /*Code Changes for Bug No.2984871 start */
               IF l_NoOfRecordsDel = 0 THEN
   /*Code Changes for Bug No.2984871 end */
		     -- SqlCount = 0 means there are no more records to be purged

                     exit ;

               ELSE
                     -- After "deleting" or "deleting and inserting" a set of records
                     -- the transaction is commited. This also creates a record in the
                     -- Pa_Purge_Project_details which will show the no. of records
                     -- that are purged from each table.

                         pa_debug.debug( ' ->Calling pa_purge.CommitProcess ') ;
                         pa_purge.CommitProcess
                           (p_purge_batch_id             => p_purge_batch_id,
                            p_project_id                 => p_project_id,
                            p_table_name                 => 'PA_PROJECT_ACCUM_COMMITMENTS',
                            p_NoOfRecordsIns             => l_NoOfRecordsIns,
                            p_NoOfRecordsDel             => l_NoOfRecordsDel,
                            x_err_code                   => x_err_code,
                            x_err_stack                  => x_err_stack,
                            x_err_stage                  => x_err_stage
                           ) ;
               END IF ;
     END LOOP ;


     x_err_stack    := l_old_err_stack ;
 EXCEPTION
  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error THEN
       RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
    pa_debug.debug('Error Procedure Name  := PA_PURGE_SUMMARY.PA_ProjAccumCommitments' );
    pa_debug.debug('Error stage is '||x_err_stage );
    pa_debug.debug('Error stack is '||x_err_stack );
    pa_debug.debug(SQLERRM);
    PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM ;

    RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

 END pa_projaccumcommitments ;

-- Start of comments
-- API name         : PA_ProjAccumBudgets
-- Type             : Private
-- Pre-reqs         : None
-- Function         : Archive and Purge data for table PA_Project_Accum_Budgets
-- Parameters       : See common list above
-- End of comments
 PROCEDURE pa_projaccumbudgets
                            ( p_purge_batch_id         IN NUMBER,
                              p_project_id             IN NUMBER,
                              p_txn_to_date            IN DATE,
                              p_purge_release          IN VARCHAR2,
                              p_archive_flag           IN VARCHAR2,
                              p_commit_size            IN NUMBER,
                              x_err_code           IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                              x_err_stack          IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              x_err_stage          IN OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                            )    IS

     l_old_err_stage         VARCHAR2(2000);
     l_old_err_stack         VARCHAR2(2000);
     l_NoOfRecordsIns        NUMBER;
     l_NoOfRecordsDel        NUMBER;
 BEGIN

     l_old_err_stack := x_err_stack;

     x_err_stack := x_err_stack || ' ->Entering PA_ProjAccumBudgets' ;

     pa_debug.debug(x_err_stack);

     LOOP
      l_NoOfRecordsDel := 0;  -- Value of l_NoOfRecordsDel is reset for BUg 4104133
      l_NoOfRecordsIns := 0;  -- Value of l_NoOfRecordsIns is reset for BUg 4104133
               IF p_archive_flag = 'Y' THEN
                     -- If archive option is selected then the records are
                     -- archived into the archive table before being purged.
                     -- The WHERE condition is such that half the no. of records
                     -- specified in commit size are inserted into the archive
                     -- table and same number deleted from the original table

                     l_commit_size := p_commit_size / 2 ;


     pa_debug.debug( ' ->Before insert into PA_PRJ_ACCUM_BUDGETS_AR') ;

                     INSERT INTO PA_PRJ_ACCUM_BUDGETS_AR
                          (
			       PURGE_BATCH_ID,
                               PURGE_RELEASE,
                               PURGE_PROJECT_ID,
                               PROJECT_ACCUM_ID,
                               BUDGET_TYPE_CODE,
                               BASE_RAW_COST_ITD,
                               BASE_RAW_COST_YTD,
                               BASE_RAW_COST_PP,
                               BASE_RAW_COST_PTD,
                               BASE_BURDENED_COST_ITD,
                               BASE_BURDENED_COST_YTD,
                               BASE_BURDENED_COST_PP,
                               BASE_BURDENED_COST_PTD,
                               ORIG_RAW_COST_ITD,
                               ORIG_RAW_COST_YTD,
                               ORIG_RAW_COST_PP,
                               ORIG_RAW_COST_PTD,
                               ORIG_BURDENED_COST_ITD,
                               ORIG_BURDENED_COST_YTD,
                               ORIG_BURDENED_COST_PP,
                               ORIG_BURDENED_COST_PTD,
                               BASE_REVENUE_ITD,
                               BASE_REVENUE_YTD,
                               BASE_REVENUE_PP,
                               BASE_REVENUE_PTD,
                               ORIG_REVENUE_ITD,
                               ORIG_REVENUE_YTD,
                               ORIG_REVENUE_PP,
                               ORIG_REVENUE_PTD,
                               ORIG_LABOR_HOURS_ITD,
                               ORIG_LABOR_HOURS_YTD,
                               ORIG_LABOR_HOURS_PP,
                               ORIG_LABOR_HOURS_PTD,
                               BASE_LABOR_HOURS_ITD,
                               BASE_LABOR_HOURS_YTD,
                               BASE_LABOR_HOURS_PP,
                               BASE_LABOR_HOURS_PTD,
                               ORIG_QUANTITY_YTD,
                               ORIG_QUANTITY_ITD,
                               ORIG_QUANTITY_PP,
                               ORIG_QUANTITY_PTD,
                               BASE_QUANTITY_YTD,
                               BASE_QUANTITY_ITD,
                               BASE_QUANTITY_PP,
                               BASE_QUANTITY_PTD,
                               ORIG_LABOR_HOURS_TOT,
                               BASE_LABOR_HOURS_TOT,
                               ORIG_QUANTITY_TOT,
                               BASE_QUANTITY_TOT,
                               BASE_RAW_COST_TOT,
                               BASE_BURDENED_COST_TOT,
                               ORIG_RAW_COST_TOT,
                               ORIG_BURDENED_COST_TOT,
                               BASE_REVENUE_TOT,
                               ORIG_REVENUE_TOT,
                               BASE_UNIT_OF_MEASURE,
                               ORIG_UNIT_OF_MEASURE,
                               LAST_UPDATED_BY,
                               LAST_UPDATE_DATE,
                               CREATION_DATE,
                               CREATED_BY,
                               LAST_UPDATE_LOGIN,
                               REQUEST_ID,
                               PROGRAM_APPLICATION_ID,
                               PROGRAM_ID,
                               PROGRAM_UPDATE_DATE
                           )
                       SELECT
			       p_purge_batch_id,
                               p_purge_release,
                               p_project_id,
                               PROJECT_ACCUM_ID,
                               BUDGET_TYPE_CODE,
                               BASE_RAW_COST_ITD,
                               BASE_RAW_COST_YTD,
                               BASE_RAW_COST_PP,
                               BASE_RAW_COST_PTD,
                               BASE_BURDENED_COST_ITD,
                               BASE_BURDENED_COST_YTD,
                               BASE_BURDENED_COST_PP,
                               BASE_BURDENED_COST_PTD,
                               ORIG_RAW_COST_ITD,
                               ORIG_RAW_COST_YTD,
                               ORIG_RAW_COST_PP,
                               ORIG_RAW_COST_PTD,
                               ORIG_BURDENED_COST_ITD,
                               ORIG_BURDENED_COST_YTD,
                               ORIG_BURDENED_COST_PP,
                               ORIG_BURDENED_COST_PTD,
                               BASE_REVENUE_ITD,
                               BASE_REVENUE_YTD,
                               BASE_REVENUE_PP,
                               BASE_REVENUE_PTD,
                               ORIG_REVENUE_ITD,
                               ORIG_REVENUE_YTD,
                               ORIG_REVENUE_PP,
                               ORIG_REVENUE_PTD,
                               ORIG_LABOR_HOURS_ITD,
                               ORIG_LABOR_HOURS_YTD,
                               ORIG_LABOR_HOURS_PP,
                               ORIG_LABOR_HOURS_PTD,
                               BASE_LABOR_HOURS_ITD,
                               BASE_LABOR_HOURS_YTD,
                               BASE_LABOR_HOURS_PP,
                               BASE_LABOR_HOURS_PTD,
                               ORIG_QUANTITY_YTD,
                               ORIG_QUANTITY_ITD,
                               ORIG_QUANTITY_PP,
                               ORIG_QUANTITY_PTD,
                               BASE_QUANTITY_YTD,
                               BASE_QUANTITY_ITD,
                               BASE_QUANTITY_PP,
                               BASE_QUANTITY_PTD,
                               ORIG_LABOR_HOURS_TOT,
                               BASE_LABOR_HOURS_TOT,
                               ORIG_QUANTITY_TOT,
                               BASE_QUANTITY_TOT,
                               BASE_RAW_COST_TOT,
                               BASE_BURDENED_COST_TOT,
                               ORIG_RAW_COST_TOT,
                               ORIG_BURDENED_COST_TOT,
                               BASE_REVENUE_TOT,
                               ORIG_REVENUE_TOT,
                               BASE_UNIT_OF_MEASURE,
                               ORIG_UNIT_OF_MEASURE,
                               LAST_UPDATED_BY,
                               LAST_UPDATE_DATE,
                               CREATION_DATE,
                               CREATED_BY,
                               LAST_UPDATE_LOGIN,
                               REQUEST_ID,
                               PROGRAM_APPLICATION_ID,
                               PROGRAM_ID,
                               PROGRAM_UPDATE_DATE
                       FROM pa_Project_Accum_Budgets pab
/*  commented and modified as below for performance reasons. Archive Purge 11.5
                       WHERE (pab.rowid) IN
                             (SELECT pab1.rowid FROM pa_project_accum_budgets pab1,
                                                     Pa_project_accum_headers pah
                                 WHERE  pab1.project_accum_id=pah.project_accum_id
                                 AND    pah.project_id = p_project_id
                                 AND    rownum < l_commit_size
                                ) ;
*/
                       WHERE (pab.project_accum_id) IN
                             (SELECT pah.project_accum_id
				FROM Pa_project_accum_headers pah
                               WHERE pah.project_id = p_project_id
/* 2485577 */                    AND pah.project_accum_id <> g_def_proj_accum_id
                                 AND rownum < l_commit_size
                                ) ;
   /*Code Changes for Bug No.2984871 start */
                     l_NoOfRecordsIns := SQL%ROWCOUNT ;
   /*Code Changes for Bug No.2984871 end */

     pa_debug.debug( ' ->After insert into PA_Project_Accum_Budgets') ;

   /*Code Changes for Bug No.2984871 start */
		     IF l_NoOfRecordsIns > 0 THEN
   /*Code Changes for Bug No.2984871 end */
			 -- The algorithm for deleting records from original table
                         -- depends on whether records are being archived or not.
                         -- If records are archived before purging, then the WHERE clause
                         -- joins the original and the archived table on the basis of a
                         -- unique key and uses rowid of records in original table to hit
                         -- the records to be deleted

                       pa_debug.debug( ' ->Before delete from pa_project_accum_budgets ') ;
/* commented and modified as below for performance reasons. Archive Purge 11.5
                         DELETE FROM pa_project_accum_budgets pab
                          WHERE (pab.rowid) IN
                                ( SELECT pab1.rowid
                                  FROM   pa_project_accum_budgets pab1,
                                         PA_PRJ_ACCUM_BUDGETS_AR pab2
                                  WHERE pab1.project_accum_id = pab2.project_accum_id
                                  AND   pab1.budget_type_code=pab2.budget_type_code
                                  AND   pab2.purge_project_id=p_project_id
                                ) ;
*/

                         DELETE FROM pa_project_accum_budgets pab
                          WHERE (pab.project_accum_id) IN
                                ( SELECT pab2.project_accum_id
                                    FROM PA_PRJ_ACCUM_BUDGETS_AR pab2
                                   WHERE pab.budget_type_code=pab2.budget_type_code
                                     AND pab2.purge_project_id=p_project_id
                                ) ;
	   /*Code Changes for Bug No.2984871 start */
		     l_NoOfRecordsDel :=  SQL%ROWCOUNT ;
	   /*Code Changes for Bug No.2984871 end */
		     pa_debug.debug( ' ->After delete from pa_project_accum_budgets ') ;
                     END IF ;
               ELSE

                     l_commit_size := p_commit_size ;

                     -- If the archive option is not selected then the delete will
                     -- be based on the commit size.

                       pa_debug.debug( ' ->Before delete from pa_project_accum_budgets ') ;

                         --Fix for bug#7701114
                         DELETE FROM pa_project_accum_budgets ppab
                         WHERE (ppab.project_accum_id) IN (SELECT pab.project_accum_id
                                                           FROM pa_project_accum_commitments pab,
                                                                pa_project_accum_headers pah
                                                          WHERE pab.project_accum_id=pah.project_accum_id
                                                            AND pah.project_id = p_project_id
                             /* 2485577 */                     AND pah.project_accum_id <> g_def_proj_accum_id)
                           AND rownum <= l_commit_size;
   /*Code Changes for Bug No.2984871 start */
		    l_NoOfRecordsDel := SQL%ROWCOUNT ;
   /*Code Changes for Bug No.2984871 end */
			pa_debug.debug( ' ->After delete from pa_project_accum_budgets ') ;
               END IF ;

               IF l_NoOfRecordsDel = 0 THEN
                     -- no more records to be purged then we exit the loop.

                     exit ;

               ELSE
                     -- After "deleting" or "deleting and inserting" a set of records
                     -- the transaction is commited. This also creates a record in the
                     -- Pa_Purge_Project_details which will show the no. of records
                     -- that are purged from each table.

                         pa_debug.debug( ' ->Calling pa_purge.CommitProcess ') ;
                         pa_purge.CommitProcess
                               (p_purge_batch_id             => p_purge_batch_id,
                                p_project_id                 => p_project_id,
                                p_table_name                 => 'PA_PROJECT_ACCUM_BUDGETS',
                                p_NoOfRecordsIns             => l_NoOfRecordsIns,
                                p_NoOfRecordsDel             => l_NoOfRecordsDel,
                                x_err_code                   => x_err_code,
                                x_err_stack                  => x_err_stack,
                                x_err_stage                  => x_err_stage
                                ) ;
               END IF ;
     END LOOP ;


     x_err_stack    := l_old_err_stack ;
 EXCEPTION
  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error then
       RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
    pa_debug.debug('Error Procedure Name  := PA_PURGE_SUMMARY.PA_ProjAccumBudgets');
    pa_debug.debug('Error stage is '||x_err_stage );
    pa_debug.debug('Error stack is '||x_err_stack );
    pa_debug.debug(SQLERRM);
    PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM ;

    RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;


END pa_projaccumbudgets ;

-- Start of comments
-- API name         : PA_ProjAccumActuals
-- Type             : Private
-- Pre-reqs         : None
-- Function         : Archive and Purge data for table PA_Project_Accum_Actuals
-- Parameters       : See common list above
-- End of comments
 PROCEDURE pa_projaccumactuals
                            ( p_purge_batch_id         IN NUMBER,
                              p_project_id             IN NUMBER,
                              p_txn_to_date            IN DATE,
                              p_purge_release          IN VARCHAR2,
                              p_archive_flag           IN VARCHAR2,
                              p_commit_size            IN NUMBER,
                              x_err_code           IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                              x_err_stack          IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              x_err_stage          IN OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                            )    IS

     l_old_err_stage         VARCHAR2(2000);
     l_old_err_stack         VARCHAR2(2000);
     l_NoOfRecordsIns        NUMBER;
     l_NoOfRecordsDel        NUMBER;
 BEGIN

     l_old_err_stack := x_err_stack;

     x_err_stack := x_err_stack || ' ->Entering PA_ProjAccumActuals' ;

     pa_debug.debug(x_err_stack);

     LOOP
      l_NoOfRecordsDel := 0;  -- Value of l_NoOfRecordsDel is reset for BUg 4104133
      l_NoOfRecordsIns := 0;  -- Value of l_NoOfRecordsIns is reset for BUg 4104133

               IF p_archive_flag = 'Y' THEN
                     -- If archive option is selected then the records are
                     -- archived into the archive table before being purged.
                     -- The WHERE condition is such that half the no. of records
                     -- specified in commit size are inserted into the archive
                     -- table and same number deleted from the original table

                     l_commit_size := p_commit_size / 2 ;


     pa_debug.debug( ' ->Before insert into PA_PRJ_ACCUM_ACTUALS_AR') ;

                     INSERT INTO PA_PRJ_ACCUM_ACTUALS_AR
                          (
			       PURGE_BATCH_ID,
                               PURGE_RELEASE,
                               PURGE_PROJECT_ID,
                               PROJECT_ACCUM_ID,
                               RAW_COST_ITD,
                               RAW_COST_YTD,
                               RAW_COST_PP,
                               RAW_COST_PTD,
                               BILLABLE_RAW_COST_ITD,
                               BILLABLE_RAW_COST_YTD,
                               BILLABLE_RAW_COST_PP,
                               BILLABLE_RAW_COST_PTD,
                               BURDENED_COST_ITD,
                               BURDENED_COST_YTD,
                               BURDENED_COST_PP,
                               BURDENED_COST_PTD,
                               BILLABLE_BURDENED_COST_ITD,
                               BILLABLE_BURDENED_COST_YTD,
                               BILLABLE_BURDENED_COST_PP,
                               BILLABLE_BURDENED_COST_PTD,
                               QUANTITY_ITD,
                               QUANTITY_YTD,
                               QUANTITY_PP,
                               QUANTITY_PTD,
                               LABOR_HOURS_ITD,
                               LABOR_HOURS_YTD,
                               LABOR_HOURS_PP,
                               LABOR_HOURS_PTD,
                               BILLABLE_QUANTITY_ITD,
                               BILLABLE_QUANTITY_YTD,
                               BILLABLE_QUANTITY_PP,
                               BILLABLE_QUANTITY_PTD,
                               BILLABLE_LABOR_HOURS_ITD,
                               BILLABLE_LABOR_HOURS_YTD,
                               BILLABLE_LABOR_HOURS_PP,
                               BILLABLE_LABOR_HOURS_PTD,
                               REVENUE_ITD,
                               REVENUE_YTD,
                               REVENUE_PP,
                               REVENUE_PTD,
                               TXN_UNIT_OF_MEASURE,
                               LAST_UPDATED_BY,
                               LAST_UPDATE_DATE,
                               CREATION_DATE,
                               CREATED_BY,
                               LAST_UPDATE_LOGIN,
                               REQUEST_ID,
                               PROGRAM_APPLICATION_ID,
                               PROGRAM_ID,
                               PROGRAM_UPDATE_DATE
                           )
                       SELECT
			       p_purge_batch_id,
                               p_purge_release,
                               p_project_id,
                               PROJECT_ACCUM_ID,
                               RAW_COST_ITD,
                               RAW_COST_YTD,
                               RAW_COST_PP,
                               RAW_COST_PTD,
                               BILLABLE_RAW_COST_ITD,
                               BILLABLE_RAW_COST_YTD,
                               BILLABLE_RAW_COST_PP,
                               BILLABLE_RAW_COST_PTD,
                               BURDENED_COST_ITD,
                               BURDENED_COST_YTD,
                               BURDENED_COST_PP,
                               BURDENED_COST_PTD,
                               BILLABLE_BURDENED_COST_ITD,
                               BILLABLE_BURDENED_COST_YTD,
                               BILLABLE_BURDENED_COST_PP,
                               BILLABLE_BURDENED_COST_PTD,
                               QUANTITY_ITD,
                               QUANTITY_YTD,
                               QUANTITY_PP,
                               QUANTITY_PTD,
                               LABOR_HOURS_ITD,
                               LABOR_HOURS_YTD,
                               LABOR_HOURS_PP,
                               LABOR_HOURS_PTD,
                               BILLABLE_QUANTITY_ITD,
                               BILLABLE_QUANTITY_YTD,
                               BILLABLE_QUANTITY_PP,
                               BILLABLE_QUANTITY_PTD,
                               BILLABLE_LABOR_HOURS_ITD,
                               BILLABLE_LABOR_HOURS_YTD,
                               BILLABLE_LABOR_HOURS_PP,
                               BILLABLE_LABOR_HOURS_PTD,
                               REVENUE_ITD,
                               REVENUE_YTD,
                               REVENUE_PP,
                               REVENUE_PTD,
                               TXN_UNIT_OF_MEASURE,
                               LAST_UPDATED_BY,
                               LAST_UPDATE_DATE,
                               CREATION_DATE,
                               CREATED_BY,
                               LAST_UPDATE_LOGIN,
                               REQUEST_ID,
                               PROGRAM_APPLICATION_ID,
                               PROGRAM_ID,
                               PROGRAM_UPDATE_DATE
                       FROM pa_Project_Accum_Actuals paa
/*  commented and modified as below for performance reasons. Archive Purge 11.5
                       WHERE (paa.rowid) IN
                             (SELECT paa1.rowid FROM pa_project_accum_actuals paa1,
                                                     pa_project_accum_headers pah
                                 WHERE  paa1.project_accum_id=pah.project_accum_id
                                 AND    pah.project_id = p_project_id
                                 AND    rownum < l_commit_size
                                ) ;
*/
                       WHERE (paa.project_accum_id) IN
                             (SELECT pah.project_accum_id
				FROM pa_project_accum_headers pah
                               WHERE pah.project_id = p_project_id
/* 2485577 */                    AND pah.project_accum_id <> g_def_proj_accum_id
                                 AND rownum < l_commit_size
                                ) ;

   /*Code Changes for Bug No.2984871 start */
		     l_NoOfRecordsIns := SQL%ROWCOUNT ;
   /*Code Changes for Bug No.2984871 end */

     pa_debug.debug( ' ->After insert into PA_Project_Accum_Actuals') ;

                     IF l_NoOfRecordsIns > 0 THEN
                         -- The algorithm for deleting records from original table
                         -- depends on whether records are being archived or not.
                         -- If records are archived before purging, then the WHERE clause
                         -- joins the original and the archived table on the basis of a
                         -- unique key and uses rowid of records in original table to hit
                         -- the records to be deleted

                      pa_debug.debug( ' ->Before delete from pa_project_accum_actuals ') ;
/* commented and modified as below for performance reasons. Archive Purge 11.5
                         DELETE FROM pa_project_accum_actuals paa
                          WHERE (paa.rowid) IN
                                ( SELECT paa1.rowid
                                  FROM pa_project_accum_Actuals paa1,
                                       PA_PRJ_ACCUM_ACTUALS_AR paa2
                                  WHERE paa1.project_accum_id = paa2.project_accum_id
                                  AND   paa2.purge_project_id = p_project_id
                                ) ;
*/
                         DELETE FROM pa_project_accum_actuals paa
                          WHERE (paa.project_accum_id) IN
                                ( SELECT paa2.project_accum_id
                                    FROM PA_PRJ_ACCUM_ACTUALS_AR paa2
                                   WHERE paa2.purge_project_id = p_project_id
                                ) ;
   /*Code Changes for Bug No.2984871 start */
		     l_NoOfRecordsDel :=  SQL%ROWCOUNT ;
   /*Code Changes for Bug No.2984871 end*/

                        pa_debug.debug( ' ->After delete from pa_project_accum_actuals ') ;
                     END IF ;
               ELSE

                     l_commit_size := p_commit_size ;

                     -- If the archive option is not selected then the delete will
                     -- be based on the commit size.

                       pa_debug.debug( ' ->Before delete from pa_project_accum_actuals ') ;
/* commented and modified as below for performance reasons. Archive Purge 11.5
                         DELETE from pa_project_accum_actuals paa
                          WHERE (paa.rowid) IN
                                ( SELECT paa1.rowid
                                  FROM pa_project_accum_actuals paa1,
                                       pa_project_accum_headers pah
                                  WHERE paa1.project_accum_id=pah.project_accum_id
                                  AND   pah.project_id = p_project_id
			          AND rownum <= l_commit_size
                                ) ;
*/
                         DELETE from pa_project_accum_actuals paa
                          WHERE (paa.project_accum_id) IN
                                ( SELECT pah.project_accum_id
                                    FROM pa_project_accum_headers pah
                                   WHERE pah.project_id = p_project_id
/* 2485577 */                        AND pah.project_accum_id <> g_def_proj_accum_id
			             AND rownum <= l_commit_size
                                ) ;

   /*Code Changes for Bug No.2984871 start */
		    l_NoOfRecordsDel := SQL%ROWCOUNT ;
   /*Code Changes for Bug No.2984871 end */

		       pa_debug.debug( ' ->After delete from pa_project_accum_actuals ') ;
               END IF ;

               IF l_NoOfRecordsDel = 0 THEN

                     exit ;

               ELSE
                     -- After "deleting" or "deleting and inserting" a set of records
                     -- the transaction is commited. This also creates a record in the
                     -- Pa_Purge_Project_details which will show the no. of records
                     -- that are purged from each table.

                         pa_debug.debug( ' ->Calling pa_purge.CommitProcess ') ;
                         pa_purge.CommitProcess
                               (p_purge_batch_id             => p_purge_batch_id,
                                p_project_id                 => p_project_id,
                                p_table_name                 => 'PA_PROJECT_ACCUM_ACTUALS',
                                p_NoOfRecordsIns             => l_NoOfRecordsIns,
                                p_NoOfRecordsDel             => l_NoOfRecordsDel,
                                x_err_code                   => x_err_code,
                                x_err_stack                  => x_err_stack,
                                x_err_stage                  => x_err_stage
                                ) ;
               END IF ;
     END LOOP ;


     x_err_stack    := l_old_err_stack ;
 EXCEPTION
  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error THEN
       RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
    pa_debug.debug('Error Procedure Name  := PA_PURGE_SUMMARY.PA_ProjAccumActuals');
    pa_debug.debug('Error stage is '||x_err_stage );
    pa_debug.debug('Error stack is '||x_err_stack );
    pa_debug.debug(SQLERRM);
    PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM ;

    RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;


END pa_projaccumactuals ;

-- Start of comments
-- API name         : PA_ResAccumDetails
-- Type             : Private
-- Pre-reqs         : None
-- Function         : Archive and Purge data for table PA_Resource_Accum_Details
-- Parameters       : See common list above
-- End of comments
 PROCEDURE pa_resaccumdetails
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
 BEGIN

     l_old_err_stack := x_err_stack;

     x_err_stack := x_err_stack || ' ->Entering PA_ResAccumDetails' ;

     pa_debug.debug(x_err_stack);

     LOOP
      l_NoOfRecordsDel := 0;  -- Value of l_NoOfRecordsDel is reset for BUg 4104133
      l_NoOfRecordsIns := 0;  -- Value of l_NoOfRecordsIns is reset for BUg 4104133
               IF p_archive_flag = 'Y' THEN
                     -- If archive option is selected then the records are
                     -- archived into the archive table before being purged.
                     -- The WHERE condition is such that half the no. of records
                     -- specified in commit size are inserted into the archive
                     -- table and same number deleted from the original table

                     l_commit_size := p_commit_size / 2 ;


     pa_debug.debug( ' ->Before insert into PA_RES_ACCUM_DETAILS_AR') ;

                     INSERT INTO PA_RES_ACCUM_DETAILS_AR
                          (
			       PURGE_BATCH_ID,
                               PURGE_RELEASE,
                               PURGE_PROJECT_ID,
                               TXN_ACCUM_ID,
                               RESOURCE_LIST_ASSIGNMENT_ID,
                               RESOURCE_LIST_ID,
                               RESOURCE_LIST_MEMBER_ID,
                               RESOURCE_ID,
                               PROJECT_ID,
                               TASK_ID,
                               LAST_UPDATED_BY,
                               LAST_UPDATE_DATE,
                               CREATION_DATE,
                               CREATED_BY,
                               LAST_UPDATE_LOGIN,
                               REQUEST_ID,
                               PROGRAM_APPLICATION_ID,
                               PROGRAM_ID,
                               PROGRAM_UPDATE_DATE,
                               ADW_NOTIFY_FLAG
                           )
                       SELECT
			       p_purge_batch_id,
                               p_purge_release,
                               p_project_id,
                               TXN_ACCUM_ID,
                               RESOURCE_LIST_ASSIGNMENT_ID,
                               RESOURCE_LIST_ID,
                               RESOURCE_LIST_MEMBER_ID,
                               RESOURCE_ID,
                               PROJECT_ID,
                               TASK_ID,
                               LAST_UPDATED_BY,
                               LAST_UPDATE_DATE,
                               CREATION_DATE,
                               CREATED_BY,
                               LAST_UPDATE_LOGIN,
                               REQUEST_ID,
                               PROGRAM_APPLICATION_ID,
                               PROGRAM_ID,
                               PROGRAM_UPDATE_DATE,
                               ADW_NOTIFY_FLAG
                       FROM pa_Resource_Accum_Details pad
                       WHERE pad.project_id = p_project_id
                       AND    rownum < l_commit_size;
   /*Code Changes for Bug No.2984871 start */
                     l_NoOfRecordsIns := SQL%ROWCOUNT ;
   /*Code Changes for Bug No.2984871 end */

     pa_debug.debug( ' ->After insert into PA_RES_ACCUM_DETAILS_AR') ;

   /*Code Changes for Bug No.2984871 start */
		     IF l_NoOfRecordsIns > 0 THEN
   /*Code Changes for Bug No.2984871 end */
			 -- The algorithm for deleting records from original table
                         -- depends on whether records are being archived or not.
                         -- If records are archived before purging, then the WHERE clause
                         -- joins the original and the archived table on the basis of a
                         -- unique key and uses rowid of records in original table to hit
                         -- the records to be deleted

                      pa_debug.debug( ' ->Before delete from pa_resource_accum_details ') ;
/* commented and modified as below for performance reasons. Archive Purge 11.5
                         DELETE FROM pa_resource_accum_details pad
                          WHERE (pad.rowid) IN
                                ( SELECT pad1.rowid
                                  FROM pa_resource_accum_details pad1,
                                       PA_RES_ACCUM_DETAILS_AR pad2
                                  WHERE pad1.txn_accum_id = pad2.txn_accum_id
                                  AND   pad1.resource_list_assignment_id =
                                        pad2.resource_list_assignment_id
                                  AND pad2.purge_project_id=p_project_id
                                ) ;
*/
                         DELETE FROM pa_resource_accum_details pad
                          WHERE (pad.txn_accum_id, pad.resource_list_assignment_id) IN
                                ( SELECT pad2.txn_accum_id, pad2.resource_list_assignment_id
                                  FROM PA_RES_ACCUM_DETAILS_AR pad2
                                  WHERE pad2.purge_project_id=p_project_id
                                ) ;
   /*Code Changes for Bug No.2984871 start */
		     l_NoOfRecordsDel :=  SQL%ROWCOUNT ;
   /*Code Changes for Bug No.2984871 end */

                       pa_debug.debug( ' ->After delete from pa_resource_accum_details ') ;
                     END IF ;
               ELSE

                     l_commit_size := p_commit_size ;

                     -- If the archive option is not selected then the delete will
                     -- be based on the commit size.

                      pa_debug.debug( ' ->Before delete from pa_resource_accum_details ') ;
/* commented and modified as below for performance reasons. Archive Purge 11.5
                         DELETE FROM pa_resource_accum_details pad
                          WHERE (pad.rowid) IN
                                ( SELECT pad.rowid
                                  FROM pa_resource_accum_details pad
                                  WHERE pad.project_id = p_project_id
			          AND rownum <= l_commit_size
                                ) ;
*/
                         DELETE FROM pa_resource_accum_details pad
                          WHERE pad.project_id = p_project_id
			    AND rownum <= l_commit_size;
   /*Code Changes for Bug No.2984871 start */
                    l_NoOfRecordsDel := SQL%ROWCOUNT ;
   /*Code Changes for Bug No.2984871 end */
		       pa_debug.debug( ' ->After delete from pa_resource_accum_details ') ;
               END IF ;

   /*Code Changes for Bug No.2984871 start */
	       IF l_NoOfRecordsDel = 0 THEN
   /*Code Changes for Bug No.2984871 end*/
		     -- Once the SqlCount becomes 0, which means that there are
                     -- no more records to be purged then we exit the loop.

                     exit ;

               ELSE
                     -- After "deleting" or "deleting and inserting" a set of records
                     -- the transaction is commited. This also creates a record in the
                     -- Pa_Purge_Project_details which will show the no. of records
                     -- that are purged from each table.

                         pa_debug.debug( ' ->Calling pa_purge.CommitProcess ') ;
                         pa_purge.CommitProcess
                              (p_purge_batch_id             => p_purge_batch_id,
                               p_project_id                 => p_project_id,
                               p_table_name                 => 'PA_RESOURCE_ACCUM_DETAILS',
                               p_NoOfRecordsIns             => l_NoOfRecordsIns,
                               p_NoOfRecordsDel             => l_NoOfRecordsDel,
                               x_err_code                   => x_err_code,
                               x_err_stack                  => x_err_stack,
                               x_err_stage                  => x_err_stage
                               ) ;
               END IF ;
     END LOOP ;


     x_err_stack    := l_old_err_stack ;
 EXCEPTION
  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error THEN
       RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
    pa_debug.debug('Error Procedure Name  := PA_PURGE_SUMMARY.PA_ResAccumDetails');
    pa_debug.debug('Error stage is '||x_err_stage );
    pa_debug.debug('Error stack is '||x_err_stack );
    pa_debug.debug(SQLERRM);
    PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM ;

    RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;


END pa_resaccumdetails ;


-- Start of comments
-- API name         : PA_TxnAccum
-- Type             : Private
-- Pre-reqs         : None
-- Function         : Archive and Purge data for table PA_TxnAccum
-- Parameters       : See common list above
-- End of comments
 PROCEDURE pa_txnaccum
                            ( p_purge_batch_id         IN NUMBER,
                              p_project_id             IN NUMBER,
                              p_txn_to_date            IN DATE,
                              p_purge_release          IN VARCHAR2,
                              p_archive_flag           IN VARCHAR2,
                              p_commit_size            IN NUMBER,
                              x_err_code           IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                              x_err_stack          IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              x_err_stage          IN OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                            )    IS

     l_old_err_stage         VARCHAR2(2000);
     l_old_err_stack         VARCHAR2(2000);
     l_NoOfRecordsIns        NUMBER;
     l_NoOfRecordsDel        NUMBER;
 BEGIN

     l_old_err_stack := x_err_stack;

     x_err_stack := x_err_stack || ' ->Entering PA_TxnAccum' ;

     pa_debug.debug(x_err_stack);

     LOOP
      l_NoOfRecordsDel := 0;  -- Value of l_NoOfRecordsDel is reset for BUg 4104133
      l_NoOfRecordsIns := 0;  -- Value of l_NoOfRecordsIns is reset for BUg 4104133
               IF p_archive_flag = 'Y' THEN
                     -- If archive option is selected then the records are
                     -- archived into the archive table before being purged.
                     -- The WHERE condition is such that half the no. of records
                     -- specified in commit size are inserted into the archive
                     -- table and same number deleted from the original table

                     l_commit_size := p_commit_size / 2 ;


     pa_debug.debug( ' ->Before insert into PA_Txn_Accum_AR') ;

                     INSERT INTO PA_Txn_Accum_AR
                          (
			       PURGE_BATCH_ID,
                               PURGE_RELEASE,
                               PURGE_PROJECT_ID,
                               TXN_ACCUM_ID,
                               PERSON_ID,
                               JOB_ID,
                               ORGANIZATION_ID,
                               VENDOR_ID,
                               EXPENDITURE_TYPE,
                               EVENT_TYPE,
                               NON_LABOR_RESOURCE,
                               EXPENDITURE_CATEGORY,
                               REVENUE_CATEGORY,
                               NON_LABOR_RESOURCE_ORG_ID,
                               EVENT_TYPE_CLASSIFICATION,
                               SYSTEM_LINKAGE_FUNCTION,
                               PROJECT_ID,
                               TASK_ID,
                               PA_PERIOD,
                               GL_PERIOD,
                               MONTH_ENDING_DATE,
                               WEEK_ENDING_DATE,
                               TOT_REVENUE,
                               TOT_RAW_COST,
                               TOT_BURDENED_COST,
                               TOT_QUANTITY,
                               TOT_LABOR_HOURS,
                               TOT_BILLABLE_RAW_COST,
                               TOT_BILLABLE_BURDENED_COST,
                               TOT_BILLABLE_QUANTITY,
                               TOT_BILLABLE_LABOR_HOURS,
                               TOT_CMT_RAW_COST,
                               TOT_CMT_BURDENED_COST,
                               TOT_CMT_QUANTITY,
                               I_TOT_REVENUE,
                               I_TOT_RAW_COST,
                               I_TOT_BURDENED_COST,
                               I_TOT_QUANTITY,
                               I_TOT_LABOR_HOURS,
                               I_TOT_BILLABLE_RAW_COST,
                               I_TOT_BILLABLE_BURDENED_COST,
                               I_TOT_BILLABLE_QUANTITY,
                               I_TOT_BILLABLE_LABOR_HOURS,
                               COST_IND_COMPILED_SET_ID,
                               REV_IND_COMPILED_SET_ID,
                               INV_IND_COMPILED_SET_ID,
                               CMT_IND_COMPILED_SET_ID,
                               UNIT_OF_MEASURE,
                               ACTUAL_COST_ROLLUP_FLAG,
                               REVENUE_ROLLUP_FLAG,
                               CMT_ROLLUP_FLAG,
                               LAST_UPDATED_BY,
                               LAST_UPDATE_DATE,
                               CREATION_DATE,
                               CREATED_BY,
                               LAST_UPDATE_LOGIN,
                               REQUEST_ID,
                               PROGRAM_APPLICATION_ID,
                               PROGRAM_ID,
                               PROGRAM_UPDATE_DATE,
                               ADW_NOTIFY_FLAG
                           )
                       SELECT
			       p_purge_batch_id,
                               p_purge_release,
                               p_project_id,
                               TXN_ACCUM_ID,
                               PERSON_ID,
                               JOB_ID,
                               ORGANIZATION_ID,
                               VENDOR_ID,
                               EXPENDITURE_TYPE,
                               EVENT_TYPE,
                               NON_LABOR_RESOURCE,
                               EXPENDITURE_CATEGORY,
                               REVENUE_CATEGORY,
                               NON_LABOR_RESOURCE_ORG_ID,
                               EVENT_TYPE_CLASSIFICATION,
                               SYSTEM_LINKAGE_FUNCTION,
                               PROJECT_ID,
                               TASK_ID,
                               PA_PERIOD,
                               GL_PERIOD,
                               MONTH_ENDING_DATE,
                               WEEK_ENDING_DATE,
                               TOT_REVENUE,
                               TOT_RAW_COST,
                               TOT_BURDENED_COST,
                               TOT_QUANTITY,
                               TOT_LABOR_HOURS,
                               TOT_BILLABLE_RAW_COST,
                               TOT_BILLABLE_BURDENED_COST,
                               TOT_BILLABLE_QUANTITY,
                               TOT_BILLABLE_LABOR_HOURS,
                               TOT_CMT_RAW_COST,
                               TOT_CMT_BURDENED_COST,
                               TOT_CMT_QUANTITY,
                               I_TOT_REVENUE,
                               I_TOT_RAW_COST,
                               I_TOT_BURDENED_COST,
                               I_TOT_QUANTITY,
                               I_TOT_LABOR_HOURS,
                               I_TOT_BILLABLE_RAW_COST,
                               I_TOT_BILLABLE_BURDENED_COST,
                               I_TOT_BILLABLE_QUANTITY,
                               I_TOT_BILLABLE_LABOR_HOURS,
                               COST_IND_COMPILED_SET_ID,
                               REV_IND_COMPILED_SET_ID,
                               INV_IND_COMPILED_SET_ID,
                               CMT_IND_COMPILED_SET_ID,
                               UNIT_OF_MEASURE,
                               ACTUAL_COST_ROLLUP_FLAG,
                               REVENUE_ROLLUP_FLAG,
                               CMT_ROLLUP_FLAG,
                               LAST_UPDATED_BY,
                               LAST_UPDATE_DATE,
                               CREATION_DATE,
                               CREATED_BY,
                               LAST_UPDATE_LOGIN,
                               REQUEST_ID,
                               PROGRAM_APPLICATION_ID,
                               PROGRAM_ID,
                               PROGRAM_UPDATE_DATE,
                               ADW_NOTIFY_FLAG
                       FROM pa_txn_accum ta
                       WHERE ta.project_id = p_project_id
                       AND    rownum < l_commit_size;
   /*Code Changes for Bug No.2984871 start */
                   l_NoOfRecordsIns := SQL%ROWCOUNT ;
   /*Code Changes for Bug No.2984871 end */

     pa_debug.debug( ' ->After insert into PA_Txn_Accum_AR') ;

   /*Code Changes for Bug No.2984871 start */
		     IF l_NoOfRecordsIns > 0 THEN
   /*Code Changes for Bug No.2984871 end */
			 -- The algorithm for deleting records from original table
                         -- depends on whether records are being archived or not.
                         -- If records are archived before purging, then the WHERE clause
                         -- joins the original and the archived table on the basis of a
                         -- unique key and uses rowid of records in original table to hit
                         -- the records to be deleted

                         pa_debug.debug( ' ->Before delete from pa_txn_accum ') ;
/*  commented and modified as below for performance reasons. Archive Purge 11.5
                         DELETE FROM pa_txn_accum ta
                          WHERE (ta.rowid) IN
                                ( SELECT ta1.rowid
                                  FROM pa_txn_accum ta1,
                                       pa_txn_accum_ar ta2
                                  WHERE ta1.txn_accum_id = ta2.txn_accum_id
                                  AND   ta2.purge_project_id = p_project_id
                                ) ;
*/
                         DELETE FROM pa_txn_accum ta
                          WHERE (ta.txn_accum_id) IN
                                ( SELECT ta2.txn_accum_id
                                    FROM pa_txn_accum_ar ta2
                                   WHERE ta2.purge_project_id = p_project_id
                                ) ;
   /*Code Changes for Bug No.2984871 start */
		     l_NoOfRecordsDel :=  SQL%ROWCOUNT ;
   /*Code Changes for Bug No.2984871 end */

                         pa_debug.debug( ' ->After delete from pa_txn_accum ') ;
                     END IF ;
               ELSE

                     l_commit_size := p_commit_size ;

                     -- If the archive option is not selected then the delete will
                     -- be based on the commit size.

                         pa_debug.debug( ' ->Before delete from pa_txn_accum ') ;
/* commented and modified as below for performance reasons. Archive Purge 11.5
                         DELETE FROM pa_txn_accum ta
                          WHERE (ta.rowid) IN
                                ( SELECT ta.rowid
                                  FROM pa_txn_accum ta
                                  WHERE ta.project_id = p_project_id
			          AND rownum <= l_commit_size
                                ) ;
*/
                         DELETE FROM pa_txn_accum ta
                          WHERE ta.project_id = p_project_id
			    AND rownum <= l_commit_size;

   /*Code Changes for Bug No.2984871 start */
		    l_NoOfRecordsDel := SQL%ROWCOUNT ;
   /*Code Changes for Bug No.2984871 end */
			 pa_debug.debug( ' ->After delete from pa_txn_accum ') ;
               END IF ;

               IF l_NoOfRecordsDel = 0 THEN
                     -- Once the SqlCount becomes 0, which means that there are
                     -- no more records to be purged then we exit the loop.

                     exit ;

               ELSE
                     -- After "deleting" or "deleting and inserting" a set of records
                     -- the transaction is commited. This also creates a record in the
                     -- Pa_Purge_Project_details which will show the no. of records
                     -- that are purged from each table.

                         pa_debug.debug( ' ->Calling pa_purge.CommitProcess ') ;
                         pa_purge.CommitProcess
                               (p_purge_batch_id             => p_purge_batch_id,
                                p_project_id                 => p_project_id,
                                p_table_name                 => 'PA_TXN_ACCUM',
                                p_NoOfRecordsIns             => l_NoOfRecordsIns,
                                p_NoOfRecordsDel             => l_NoOfRecordsDel,
                                x_err_code                   => x_err_code,
                                x_err_stack                  => x_err_stack,
                                x_err_stage                  => x_err_stage
                                ) ;
               END IF ;
     END LOOP ;


     x_err_stack    := l_old_err_stack ;
 EXCEPTION
  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error THEN
       RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
    pa_debug.debug('Error Procedure Name  := PA_PURGE_SUMMARY.PA_TxnAccum');
    pa_debug.debug('Error stage is '||x_err_stage );
    pa_debug.debug('Error stack is '||x_err_stack );
    pa_debug.debug(SQLERRM);
    PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM ;

    RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

END pa_txnaccum ;

-- Start of comments
-- API name         : PA_TxnAccumDetails
-- Type             : Private
-- Pre-reqs         : None
-- Function         : Archive and Purge data for table PA_TxnAccumDetails
-- Parameters       : See common list above
-- End of comments


 PROCEDURE pa_txnaccumdetails
                            ( p_purge_batch_id         IN NUMBER,
                              p_project_id             IN NUMBER,
                              p_txn_to_date            IN DATE,
                              p_purge_release          IN VARCHAR2,
                              p_archive_flag           IN VARCHAR2,
                              p_commit_size            IN NUMBER,
                              x_err_code           IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                              x_err_stack          IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              x_err_stage          IN OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                            )    IS

     l_old_err_stage         VARCHAR2(2000);
     l_old_err_stack         VARCHAR2(2000);
     l_NoOfRecordsIns        NUMBER;
     l_NoOfRecordsDel        NUMBER;
 BEGIN

     l_old_err_stack := x_err_stack;

     x_err_stack := x_err_stack || ' ->Entering PA_TxnAccumDetails' ;

     pa_debug.debug(x_err_stack);

     LOOP
      l_NoOfRecordsDel := 0;  -- Value of l_NoOfRecordsDel is reset for BUg 4104133
      l_NoOfRecordsIns := 0;  -- Value of l_NoOfRecordsIns is reset for BUg 4104133
               IF p_archive_flag = 'Y' THEN
                     -- If archive option is selected then the records are
                     -- archived into the archive table before being purged.
                     -- The WHERE condition is such that half the no. of records
                     -- specified in commit size are inserted into the archive
                     -- table and same number deleted from the original table

                     l_commit_size := p_commit_size / 2 ;


     pa_debug.debug( ' ->Before insert into PA_Txn_Accum_Details_AR') ;

-- Modified insert statement to use project_id from pa_txn_accum to select rows from
-- pa_txn_accum_details as project_id may be null for some detail lines
-- project_id is a not null column in pa_txn_accum.

                     INSERT INTO PA_Txn_Accum_Details_AR
                          (
			       PURGE_BATCH_ID,
                               PURGE_RELEASE,
                               PURGE_PROJECT_ID,
                               ORIGINAL_ROWID,
                               TXN_ACCUM_ID,
                               LINE_TYPE,
                               EXPENDITURE_ITEM_ID,
                               EVENT_NUM,
                               LINE_NUM,
                               PROJECT_ID,
                               TASK_ID,
                               CMT_LINE_ID,
                               LAST_UPDATED_BY,
                               LAST_UPDATE_DATE,
                               CREATION_DATE,
                               CREATED_BY,
                               LAST_UPDATE_LOGIN,
                               REQUEST_ID,
                               PROGRAM_APPLICATION_ID,
                               PROGRAM_ID,
                               PROGRAM_UPDATE_DATE
                           )
                       SELECT
			       p_purge_batch_id,
                               p_purge_release,
                               p_project_id,
                               tad.ROWID,
                               tad.TXN_ACCUM_ID,
                               tad.LINE_TYPE,
                               tad.EXPENDITURE_ITEM_ID,
                               tad.EVENT_NUM,
                               tad.LINE_NUM,
                               tad.PROJECT_ID,
                               tad.TASK_ID,
                               tad.CMT_LINE_ID,
                               tad.LAST_UPDATED_BY,
                               tad.LAST_UPDATE_DATE,
                               tad.CREATION_DATE,
                               tad.CREATED_BY,
                               tad.LAST_UPDATE_LOGIN,
                               tad.REQUEST_ID,
                               tad.PROGRAM_APPLICATION_ID,
                               tad.PROGRAM_ID,
                               tad.PROGRAM_UPDATE_DATE
                       FROM pa_txn_accum_details tad,
                            pa_txn_accum pta
                       WHERE tad.txn_accum_id = pta.txn_accum_id
                       AND   pta.project_id = p_project_id
                       AND   rownum < l_commit_size;


   /*Code Changes for Bug No.2984871 start */
		     l_NoOfRecordsIns := SQL%ROWCOUNT ;
   /*Code Changes for Bug No.2984871 end */

     pa_debug.debug( ' ->After insert into PA_Txn_Accum_Details_AR') ;

                     IF l_NoOfRecordsIns > 0 THEN
                         -- The algorithm for deleting records from original table
                         -- depends on whether records are being archived or not.
                         -- If records are archived before purging, then the WHERE clause
                         -- joins the original and the archived table on the basis of a
                         -- unique key and uses rowid of records in original table to hit
                         -- the records to be deleted

                         pa_debug.debug( ' ->Before delete from pa_txn_accum_details ') ;

                         DELETE FROM pa_txn_accum_details tad
                          WHERE (tad.rowid) IN
                                ( SELECT tad2.original_rowid
                                  FROM pa_txn_accum_details tad1,
                                       pa_txn_accum_details_ar tad2
                                  WHERE tad1.rowid = tad2.original_rowid
--                                AND tad1.project_id=tad2.project_id
                                  AND tad2.purge_project_id = p_project_id
                                ) ;
   /*Code Changes for Bug No.2984871 start */
		     l_NoOfRecordsDel :=  SQL%ROWCOUNT ;
   /*Code Changes for Bug No.2984871 end */
			 pa_debug.debug( ' ->After delete from pa_txn_accum_details ') ;
                     END IF ;
               ELSE

                     l_commit_size := p_commit_size ;

                     -- If the archive option is not selected then the delete will
                     -- be based on the commit size.

                         pa_debug.debug( ' ->Before delete from pa_txn_accum_details ') ;
/*  commented and modified as below for performance reasons. Archive Purge 11.5
                         DELETE FROM pa_txn_accum_details tad
                          WHERE (tad.rowid) IN
                                ( SELECT tad1.rowid
                                  FROM pa_txn_accum_details tad1, pa_txn_accum pta
                                  WHERE tad1.txn_accum_id = pta.txn_accum_id
                                  AND   pta.project_id = p_project_id
			          AND   rownum <= l_commit_size
                                ) ;
*/
                         --Fix for bug#7701114
                         DELETE FROM pa_txn_accum_details tad
                          WHERE (tad.txn_accum_id) IN
                                ( SELECT pta.txn_accum_id
                                    FROM pa_txn_accum pta
                                   WHERE pta.project_id = p_project_id)
			             AND rownum <= l_commit_size;


   /*Code Changes for Bug No.2984871 start */
		    l_NoOfRecordsDel := SQL%ROWCOUNT ;
   /*Code Changes for Bug No.2984871 end */
			 pa_debug.debug( ' ->After delete from pa_txn_accum_details ') ;
               END IF ;

   /*Code Changes for Bug No.2984871 start */
	       IF l_NoOfRecordsDel = 0 THEN
   /*Code Changes for Bug No.2984871 end*/
		     -- Once the SqlCount becomes 0, which means that there are
                     -- no more records to be purged then we exit the loop.

                     exit ;

               ELSE
                     -- After "deleting" or "deleting and inserting" a set of records
                     -- the transaction is commited. This also creates a record in the
                     -- Pa_Purge_Project_details which will show the no. of records
                     -- that are purged from each table.

                         pa_debug.debug( ' ->Calling pa_purge.CommitProcess ') ;
                         pa_purge.CommitProcess
                               (p_purge_batch_id             => p_purge_batch_id,
                                p_project_id                 => p_project_id,
                                p_table_name                 => 'PA_TXN_ACCUM_DETAILS',
                                p_NoOfRecordsIns             => l_NoOfRecordsIns,
                                p_NoOfRecordsDel             => l_NoOfRecordsDel,
                                x_err_code                   => x_err_code,
                                x_err_stack                  => x_err_stack,
                                x_err_stage                  => x_err_stage
                                ) ;
               END IF ;
     END LOOP ;


     x_err_stack    := l_old_err_stack ;
 EXCEPTION
  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error THEN
       RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
    pa_debug.debug('Error Procedure Name  := PA_PURGE_SUMMARY.PA_TxnAccumDetails');
    pa_debug.debug('Error stage is '||x_err_stage );
    pa_debug.debug('Error stack is '||x_err_stack );
    pa_debug.debug(SQLERRM);
    PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM ;

    RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

END pa_txnaccumdetails;


-- Start of comments
-- API name         : PA_Summary_Main_Purge
-- Type             : Public
-- Pre-reqs         : None
-- Function         : Main purge procedure for summarization tables.
--                    Calls a separate procedure to purge each summary table
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
--                     p_archive_flag    -> set to 'Y' if summarization data
--                                          is to be archived
--                     p_commit_size     -> The maximum number of records that
--                                          can be allowed to remain uncommited.
--                                          If the number of records processed
--                                          goes beyond this number then the
--                                          process is commited.
-- End of comments

 PROCEDURE pa_summary_main_purge ( p_purge_batch_id                 in NUMBER,
                                   p_project_id                     in NUMBER,
                                   p_purge_release                  in VARCHAR2,
                                   p_txn_to_date                    in DATE,
                                   p_archive_flag                   in VARCHAR2,
                                   p_commit_size                    in NUMBER,
                                   x_err_stack                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                   x_err_stage                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                   x_err_code                       in OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                                 ) IS

      l_old_err_stack      VARCHAR2(2000);

 BEGIN
     l_old_err_stack := x_err_stack;
     g_def_proj_accum_id := 0; /* 2485577 */

     /* 2485577. When a new project is created default records gets
        inserted into summarization tables. These records should not be
        purged. */

     Select Project_Accum_Id
     INTO   g_def_proj_accum_id
     FROM   PA_Project_Accum_Headers
     WHERE  Project_Id = p_project_id
     AND    Task_Id = 0
     AND    Resource_Id = 0
     AND    Resource_List_Assignment_Id = 0
     AND    Resource_List_Id = 0
     AND    Resource_List_Member_Id = 0
     AND    rownum = 1;

     x_err_stack := x_err_stack || ' ->Before call to purge summary data ';

        pa_debug.debug('*-> About to purge Summary data ') ;

     -- Call the procedures to archive/purge data for each summary table
     --
        pa_debug.debug('*-> About to purge PA_Project_Accum_Commitments ') ;
        pa_purge_summary.PA_ProjAccumCommitments
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

        pa_debug.debug('*-> About to purge PA_Project_Accum_Actuals') ;
        pa_purge_summary.PA_ProjAccumActuals
				         (p_purge_batch_id => p_purge_batch_id,
                                          p_project_id     => p_project_id,
                                          p_txn_to_date    => p_txn_to_date,
                                          p_purge_release  => p_purge_release,
                                          p_archive_flag   => p_archive_flag,
                                          p_commit_size    => p_commit_size,
                                          x_err_code       => x_err_code,
                                          x_err_stack      => x_err_stack,
                                          x_err_stage      => x_err_stage
                                        )  ;

        pa_debug.debug('*-> About to purge PA_Project_Accum_Budgets ') ;
        pa_purge_summary.PA_ProjAccumBudgets
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

        pa_debug.debug('*-> About to purge PA_Resource_Accum_Details ') ;
        pa_purge_summary.PA_ResAccumDetails
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

        pa_debug.debug('*-> About to purge PA_Project_Accum_Headers ') ;
        pa_purge_summary.PA_ProjAccumHeaders
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

        pa_debug.debug('*-> About to purge PA_Txn_Accum_Details') ;
        pa_purge_summary.PA_TxnAccumDetails
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

        pa_debug.debug('*-> About to purge PA_Txn_Accum') ;
        pa_purge_summary.PA_TxnAccum
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


      x_err_stack := l_old_err_stack;

 EXCEPTION
  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error THEN
       RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
    pa_debug.debug('Error Procedure Name  := PA_PURGE_SUMMARY.pa_summary_main_purge' );
    pa_debug.debug('Error stage is '||x_err_stage );
    pa_debug.debug('Error stack is '||x_err_stack );
    pa_debug.debug(SQLERRM);
    PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM ;

    RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

END pa_summary_main_purge ;

END  pa_purge_summary;

/
