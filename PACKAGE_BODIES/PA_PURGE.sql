--------------------------------------------------------
--  DDL for Package Body PA_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PURGE" as
/* $Header: PAXPRMNB.pls 120.4 2007/12/09 10:24:43 vvjoshi ship $ */

-- Start of comments
-- API name         : Purge_Project
-- Type             : Private
-- Pre-reqs         : None
-- Function         : Invokes the procedure for purge for a specific project for the
--                    various modules ( Costing , billing ,Project tracking , capital
--                    projects) based on the option selection during the purge batch
--                    creation.
--                    In addition also invokes a client extension
--                    for any customer specific purge procedures
--
-- Parameters         p_batch_id			IN     NUMBER
--                              The purge batch id for which rows have
--                              to be purged/archived.
--		      p_project_Id			IN     NUMBER,
--                              The project id for which records have
--                              to be purged/archived.
--		      p_Active_Closed_Flag		IN     VARCHAR2,
--                              Indicates if batch contains ACTIVE or CLOSED projects
--                              ( 'A' - Active , 'C' - Closed)
--		      p_Purge_Release                   IN     VARCHAR2,
--                              Oracle Projects release (10.7 , 11.0)
--		      p_Purge_Summary_Flag		IN     VARCHAR2,
--                              Purge Summary tables data
--		      p_Purge_Capital_Flag		IN     VARCHAR2,
--                              Purge Capital projects tables data
--		      p_Purge_Budgets_Flag		IN     VARCHAR2,
--                              Purge Budget tables data
--		      p_Purge_Actuals_Flag		IN     VARCHAR2,
--                              Purge Actuals tables data i.e. Costing and Billing tables
--		      p_Archive_Summary_Flag		IN     VARCHAR2,
--                              Archive Summary tables data
--		      p_Archive_Capital_Flag 		IN     VARCHAR2,
--                              Purge Capital projects tables data
--		      p_Archive_Budgets_Flag		IN     VARCHAR2,
--                              Archive Budget tables data
--		      p_Archive_Actuals_Flag 	 	IN     VARCHAR2,
--                              Archive Actuals tables data i.e. Costing and Billing tables
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
-- End of comments
 Procedure Purge_Project(
		p_batch_id			IN     NUMBER,
		p_project_Id			IN     NUMBER,
		p_Active_Closed_Flag		IN     VARCHAR2,
		p_Purge_Release                 IN     VARCHAR2,
		p_Purge_Summary_Flag		IN     VARCHAR2,
		p_Purge_Capital_Flag		IN     VARCHAR2,
		p_Purge_Budgets_Flag		IN     VARCHAR2,
		p_Purge_Actuals_Flag		IN     VARCHAR2,
		p_Archive_Summary_Flag		IN     VARCHAR2,
		p_Archive_Capital_Flag 		IN     VARCHAR2,
		p_Archive_Budgets_Flag		IN     VARCHAR2,
		p_Archive_Actuals_Flag 	 	IN     VARCHAR2,
		p_Txn_To_Date			IN     DATE,
		p_Commit_Size			IN     NUMBER,
		X_Err_Stack			IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
		X_Err_Stage		        IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
		X_Err_Code		        IN OUT NOCOPY NUMBER) is --File.Sql.39 bug 4440895

 l_old_err_stack VARCHAR2(2000); -- Bug 4227589. Changed size from 1024 to 2000
 l_project_status_code VARCHAR2(30);
 l_project_type_class   pa_project_types_all.project_type_class_code%TYPE; -- Added for bug 3583748
 begin
    l_old_err_stack := X_err_stack;
    X_err_stack := X_err_stack ||'->pa_purge.purge_project';
    X_err_stack := X_err_stack ||'Batch Id: '||p_batch_id || 'Project Id: '||p_project_id ;
    X_err_code  := 0;

    pa_debug.debug(X_err_stack);

   -- Call user defined extension to purge customer specific tables
    pa_debug.debug('--Calling client extension procedure');
    pa_purge_extn.pa_purge_client_extn(
		       	     p_purge_batch_id        => p_batch_id,
                             p_project_id            => p_project_id,
                             p_purge_release         => p_purge_release,
                             p_txn_through_date      => p_txn_to_date,
                             p_archive_flag          => p_archive_actuals_flag,
                             p_calling_place         => 'BEFORE_PURGE',
		             p_Commit_Size           => p_Commit_Size,
                             X_Err_Stack             => X_Err_Stack,
                             X_Err_Stage             => X_Err_Stage,
                             X_Err_Code              => X_Err_Code);


 -- Call the procedures conditionally based on the various flag values
 --
   -- If summarization need to be purged and project is closed then call
   -- main summarization purge procedure
   --

   IF P_purge_summary_flag = 'Y'  THEN
     if P_active_closed_flag =  'C' then
       pa_debug.debug('--Calling procedure pa_purge_summary.pa_summary_main_purge');
       pa_purge_summary.pa_summary_main_purge (
   			     p_purge_batch_id        => p_batch_id,
                             p_project_id            => p_project_id,
                             p_purge_release         => p_purge_release,
                             p_txn_to_date           => p_txn_to_date,
                             p_archive_flag          => p_archive_summary_flag,
		             p_Commit_Size           => p_Commit_Size,
                             X_Err_Stack             => X_Err_Stack,
                             X_Err_Stage             => X_Err_Stage,
                             X_Err_Code              => X_Err_Code);
     end if ;
   END IF;

   -- If budgets need to be purged and project is closed then call
   -- main budgets purge procedure
   --
  /***
   IF P_purge_budgets_flag = 'Y' THEN
     if P_active_closed_flag =  'C' then
       pa_debug.debug('--Calling procedure pa_purge_budget.pa_budget_main_purge');
       pa_purge_budget.pa_budget_main_purge (
			     p_batch_id,
                             p_project_id,
                             p_purge_release,
                             p_txn_to_date,
                             p_archive_budgets_flag,
		             p_Commit_Size,
                             X_Err_Stack,
                             X_Err_Stage,
                             X_Err_Code);

     end if ;
   END IF;
 **/
    -- If capital tables need to be purged and project is closed then call
    -- the main capital purge procedure
    --

    IF  P_purge_capital_flag = 'Y' THEN
     if  P_active_closed_flag  = 'C' then
      pa_debug.debug('--Calling procedure pa_purge_capital.pa_capital_main_purge');
      pa_purge_capital.pa_capital_main_purge   (
   			     p_purge_batch_id        => p_batch_id,
                             p_project_id            => p_project_id,
                             p_purge_release         => p_purge_release,
                             p_txn_to_date           => p_txn_to_date,
                             p_archive_flag          => p_archive_capital_flag,
		             p_Commit_Size           => p_Commit_Size,
                             p_Err_Stack             => X_Err_Stack,
                             p_Err_Stage             => X_Err_Stage,
                             p_Err_Code              => X_Err_Code);
      end if ;
    END IF;



    IF p_purge_actuals_flag = 'Y'	 THEN

   -- Billing purge procedure to be called only in case of 'CLOSED' projects
   --
   -- Added for bug 3583748
      select project_type_class_code
        into l_project_type_class
        from pa_project_types_all ppt
            ,pa_projects_all  ppa
       where ppt.project_type = ppa.project_type
         and ppt.org_id = ppa.org_id /* added for Bug 5099516*/ -- Removed NVL for bug#5908179 by vvjoshi
         and project_id = p_project_id;

       If p_active_closed_flag = 'C'
        and l_project_type_class = 'CONTRACT' Then  --  added for bug 3583748
          pa_debug.debug('--Calling procedure pa_purge_billing.pa_billing_main_purge ');
          pa_purge_billing.pa_billing_main_purge    (
			     p_purge_batch_id        => p_batch_id,
                             p_project_id            => p_project_id,
                             p_purge_release         => p_purge_release,
                             p_txn_to_date           => p_txn_to_date,
                             p_archive_flag          => p_archive_actuals_flag,
		             p_Commit_Size           => p_Commit_Size,
                             X_Err_Stack             => X_Err_Stack,
                             X_Err_Stage             => X_Err_Stage,
                             X_Err_Code              => X_Err_Code);
       end if ;

/* Bug#2416385 Code added for the Phase III of Archive and Purge, starts here */

    -- Call the Intercomapany and Interproject Billing purge procedure
    --
       pa_debug.debug('--Calling procedure pa_purge_icip.PA_DraftInvDetails');
       pa_purge_icip.PA_DraftInvDetails (
                             p_purge_batch_id        => p_batch_id,
                             p_project_id            => p_project_id,
                             p_purge_release         => p_purge_release,
                             p_txn_to_date           => p_txn_to_date,
                             p_archive_flag          => p_archive_actuals_flag,
                             p_Commit_Size           => p_Commit_Size,
                             X_Err_Stack             => X_Err_Stack,
                             X_Err_Stage             => X_Err_Stage,
                             X_Err_Code              => X_Err_Code);

/* Bug#2441479 Code added for the PJR  Archive and Purge, starts here */

       pa_debug.debug('--Calling procedure PA_PURGE_PJR_TXNS.PA_REQUIREMENTS_PURGE');
       pa_purge_pjr_txns.pa_requirements_purge (
                             p_purge_batch_id        => p_batch_id,
                             p_project_id            => p_project_id,
                             p_purge_release         => p_purge_release,
                             p_txn_to_date           => p_txn_to_date,
                             p_archive_flag          => p_archive_actuals_flag,
                             p_Commit_Size           => p_Commit_Size,
                             X_Err_Stack             => X_Err_Stack,
                             X_Err_Stage             => X_Err_Stage,
                             X_Err_Code              => X_Err_Code);

       pa_debug.debug('--Calling procedure PA_PURGE_PJR_TXNS.PA_ASSIGNMENTS_PURGE');
       pa_purge_pjr_txns.pa_assignments_purge (
                             p_purge_batch_id        => p_batch_id,
                             p_project_id            => p_project_id,
                             p_purge_release         => p_purge_release,
                             p_txn_to_date           => p_txn_to_date,
                             p_archive_flag          => p_archive_actuals_flag,
                             p_Commit_Size           => p_Commit_Size,
                             X_Err_Stack             => X_Err_Stack,
                             X_Err_Stage             => X_Err_Stage,
                             X_Err_Code              => X_Err_Code);


/* Bug#2416385 Code added for the Phase III of Archive and Purge, ends here */

    -- Call the main costing purge procedure
    --
       pa_debug.debug('--Calling procedure pa_purge_costing.pa_costing_main_purge');
       pa_purge_costing.pa_costing_main_purge (
			     p_purge_batch_id        => p_batch_id,
                             p_project_id            => p_project_id,
                             p_purge_release         => p_purge_release,
                             p_txn_to_date           => p_txn_to_date,
                             p_archive_flag          => p_archive_actuals_flag,
		             p_Commit_Size           => p_Commit_Size,
                             X_Err_Stack             => X_Err_Stack,
                             X_Err_Stage             => X_Err_Stage,
                             X_Err_Code              => X_Err_Code);

    END IF;

   -- Call user defined extension to purge customer specific tables after the
   -- main tables are purged
    pa_debug.debug('--Calling client extension procedure');
    pa_purge_extn.pa_purge_client_extn(
		       	     p_purge_batch_id        => p_batch_id,
                             p_project_id            => p_project_id,
                             p_purge_release         => p_purge_release,
                             p_txn_through_date      => p_txn_to_date,
                             p_archive_flag          => p_archive_actuals_flag,
                             p_calling_place         => 'AFTER_PURGE',
		             p_Commit_Size           => p_Commit_Size,
                             X_Err_Stack             => X_Err_Stack,
                             X_Err_Stage             => X_Err_Stage,
                             X_Err_Code              => X_Err_Code);


    -- Set completed status for the project
    pa_debug.debug('--Before update of pa_purge_projects batch id :
                   '|| p_batch_id || ' project id : '|| p_project_id);

    update pa_purge_projects
    set
        purged_date=sysdate
       ,last_update_date=sysdate
       ,last_updated_by=fnd_global.user_id
       ,last_update_login=fnd_global.login_id
       ,program_id = fnd_global.conc_program_id
       ,program_application_id = fnd_global.prog_appl_id
       ,request_id = fnd_global.conc_request_id
       ,program_update_date = sysdate
    where purge_batch_id = p_batch_id
    and project_id = p_project_id;

    commit;

    pa_debug.debug('--After update of pa_purge_projects batch id :
                   '|| p_batch_id || ' project id : '|| p_project_id);

   -- For closed projects set the project status to fully purged or partially purged
   -- For active projects set the project status code to old project status code

   pa_debug.debug('--Before update of pa_projects_all batch id :
                   '|| p_batch_id || ' project id : '|| p_project_id);


   l_project_status_code := pa_purge.get_post_purge_status(p_project_id,p_batch_id);

   update pa_projects_all
   set project_status_code = l_project_status_code
   where project_id = p_project_id;
   commit;
   pa_debug.debug('--After update of pa_projects_all batch id :
                   '|| p_batch_id || ' project id : '|| p_project_id);

   X_err_stack := l_old_err_stack;

 Exception
  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error then
       RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
    pa_debug.debug('Error Procedure Name  := PA_PURGE.PURGE_PROJECT' );
    pa_debug.debug('Error stage is '||x_err_stage );
    pa_debug.debug('Error stack is '||x_err_stack );
    pa_debug.debug(SQLERRM);
    PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM ;

    RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

 End purge_project;

-- Start of comments
-- API name         : Purge
-- Type             : Public
-- Pre-reqs         : None
-- Function         : This procedure is called from the form.
--                    Main purge procedure.
--                    Invokes the purge_project procedure for each project
--                    in the purge batch
-- Parameters         p_batch_id			IN     NUMBER
--                              The purge batch id for which rows have
--                              to be purged/archived.
--		      p_Commit_Size			IN     NUMBER,
--                              The commit size
--		      errbuf 			        IN OUT VARCHAR2,
--                              error buffer containing the SQLERRM
--		      retcode 		                IN OUT NUMBER
--                              Standard error code returned from the procedure
--                              = 0 SUCCESS
--                              < 0 Oracle error
-- End of comments
Procedure Purge (
		p_Batch_Id		IN     NUMBER ,
		p_Commit_Size		IN     NUMBER ,
                ret_code                IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                errbuf                  IN OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

    l_active_closed_flag VARCHAR2(1);
    l_purge_release VARCHAR2(30);
    l_err_stack     VARCHAR2(2000);
    l_err_stage     VARCHAR2(2000);
    l_err_code      NUMBER;
    l_project_id    NUMBER;
    COUNT_MRC_SET_OF_BOOKS NUMBER;

 Begin

    l_err_stack  := '->pa_purge.purge';
    l_err_code   := 0;
    l_err_stage  := 'Purge for batch_id: ' || to_char(p_batch_id);
    l_project_id := -9999;

    pa_debug.debug(l_err_stage);

    -- Count MRC reporting set of books
    -- and set ARPUR_MRC_COMMIT_SIZE.

    PA_UTILS2.ARPUR_Commit_Size     := p_commit_size;
    PA_UTILS2.ARPUR_MRC_Commit_Size := p_commit_size;

    SELECT count(*)
        INTO   COUNT_MRC_SET_OF_BOOKS
        FROM   pa_implementations pi, gl_alc_ledger_rships_v gal --gl_mc_reporting_options glm. Bug 4468366.
        WHERE  (gal.org_id = -99 OR pi.org_id = gal.org_id) --pi.org_id = glm.org_id. Bug 4468366.
        AND    gal.relationship_enabled_flag = 'Y' --glm.enabled_flag = 'Y'. Bug 4468366.
        AND    gal.application_id = 275; --glm.application_Id = 275; Bug 4468366.
   PA_UTILS2.ARPUR_MRC_Commit_Size := PA_UTILS2.ARPUR_Commit_size/(1+COUNT_MRC_SET_OF_BOOKS);
   pa_debug.debug('Calculate ARPUR_Commit_Size and ARPUR_MRC_Commit_Size');


    -- Set working status for the batch
    pa_debug.debug('Before update of pa_purge_batches to pending');
    Update pa_purge_batches
    Set batch_status_code='P' ,
        request_id = fnd_global.conc_request_id
    Where purge_batch_id = p_batch_id;

    Commit;
    pa_debug.debug('After update of pa_purge_batches to pending');

    -- Lock the batch row
    pa_debug.debug('Before locking table pa_purge_batches');
    Select  active_closed_flag , purge_release
    Into  l_active_closed_flag , l_purge_release
    From pa_purge_batches
    Where purge_batch_id = p_batch_id
    and   request_id = fnd_global.conc_request_id
    For update;

    pa_debug.debug('After locking table pa_purge_batches');

    -- Select the projects in the batch that have not been purged
    -- (Purged date is Null)

    pa_debug.debug('Before FOR loop');
  For pp_rec In
 (
  Select
             project_id,
	     purge_summary_flag,
	     purge_capital_flag,
	     purge_budgets_flag,
             purge_actuals_flag,
	     archive_summary_flag,
             archive_capital_flag,
	     archive_budgets_flag,
             archive_actuals_flag,
             txn_to_date,
             last_project_status_code,
             next_pp_project_status_code,
             next_p_project_status_code
     From pa_purge_projects
     Where purge_batch_id = p_Batch_Id
     And purged_date is NULL
     Order By project_id
 )
  Loop

     l_project_id  :=  pp_rec.project_id ;

  -- For each project call procedure to purge
     pa_debug.debug('Calling pa_purge.purge_project with project_id : '||pp_rec.project_id);
           pa_purge.purge_project(
		p_batch_id                     => p_batch_id,
                p_project_id                   => pp_rec.project_id,
                p_active_closed_flag           => l_active_closed_flag,
                p_purge_release                => l_purge_release,
		p_purge_summary_flag           => pp_rec.purge_summary_flag,
                p_purge_capital_flag           => pp_rec.purge_capital_flag,
		p_purge_budgets_flag           => pp_rec.purge_budgets_flag,
                p_purge_actuals_flag           => pp_rec.purge_actuals_flag,
		p_archive_summary_flag         => pp_rec.archive_summary_flag,
                p_archive_capital_flag         => pp_rec.archive_capital_flag,
		p_archive_budgets_flag         => pp_rec.archive_budgets_flag,
                p_archive_actuals_flag         => pp_rec.archive_actuals_flag,
		p_txn_to_date                  => pp_rec.txn_to_date,
                p_Commit_Size                  => p_commit_size,
		X_Err_Stack                    => l_Err_Stack,
                X_Err_Stage                    => l_Err_Stage,
                X_Err_Code                     => l_Err_Code);

  End Loop;

    -- The following three procedure calls purges pa_routings, pa_expenditures_all
    -- and pa-expenditure_history. It was originally in the call for costing
    -- tables purge. But there it will be called for every project. Here it is called
    -- after purging all the other tables for all the projects. So it will be called
    -- only once.

    -- Purging of PA_EXPENDITURES_ALL and PA_ROUTINGS are removed for the time being. It
    -- will be done at a later point of time
/*
    pa_debug.debug('*-> About to purge expenditures ');
    l_err_stage := 'About to purge expenditures without any expenditure items ';
    pa_purge_costing.PA_Expenditures1(p_purge_batch_id   => p_batch_id,
                                     p_project_id       => l_project_id,
                                     p_purge_release    => l_purge_release,
                                     p_archive_flag     => 'Y',
                                     p_commit_size      => p_commit_size,
                                     x_err_code         => l_err_code,
                                     x_err_stack        => l_err_stack,
                                     x_err_stage        => l_err_stage
                                    ) ;

    pa_debug.debug('*-> About to purge routings ');
    l_err_stage := 'About to purge routing records ';
    pa_purge_costing.PA_Routings1(p_purge_batch_id   => p_batch_id,
                                 p_project_id       => l_project_id,
                                 p_purge_release    => l_purge_release,
                                 p_archive_flag     => 'Y',
                                 p_commit_size      => p_commit_size,
                                 x_err_code         => l_err_code,
                                 x_err_stack        => l_err_stack,
                                 x_err_stage        => l_err_stage
                                ) ;

*/
    -- Set completed status for the batch
    pa_debug.debug('Before update of pa_purge_batches to complete ');
    Update pa_purge_batches
    Set batch_status_code='C'
       ,purged_date=sysdate
       ,last_update_date=sysdate
       ,last_updated_by=fnd_global.user_id
       ,last_update_login=fnd_global.login_id
    Where purge_batch_id = p_batch_id;

    Commit;
    pa_debug.debug('After update of pa_purge_batches to complete');


 Exception

  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error THEN
        errbuf := PA_PROJECT_UTILS2.g_sqlerrm ;
        ret_code := -1 ;
  WHEN OTHERS THEN
    errbuf := SQLERRM ;
    ret_code := -1 ;

 End purge;

-- Start of comments
-- API name         : CommitProcess
-- Type             : Public
-- Pre-reqs         : None
-- Function         : Common procedure for commit.
--                    Will be invoked from the various purge procedures
--
-- Parameters         p_batch_id			IN     NUMBER
--                              The purge batch id for which rows have
--                              been purged/archived.
--		      p_project_Id			IN     NUMBER,
--                              The project id for which records have
--                              been purged/archived.
--                    p_table_name		        IN VARCHAR2,
--                              The table for which rows have been purged
--                    p_NoOfRecordsIns                  IN NUMBER,
--                              No. of records inserted into the archive table
--                    p_NoOfRecordsDel                  IN NUMBER,
--                              No. of records deleted from table
-- 		      X_Err_Stack			IN OUT VARCHAR2,
--                              Error stack
--		      X_Err_Stage		        IN OUT VARCHAR2,
--                              Stage in the procedure where error occurred
--		      X_Err_Code		        IN OUT NUMBER,
--                              Error code returned from the procedure
--                              = 0 SUCCESS
--                              > 0 Application error
--                              < 0 Oracle error
--                    p_MRC_table_name                      IN VARCHAR2,
--                              The MRC table for which rows have been purged
--                    p_MRC_NoOfRecordsIns                  IN NUMBER,
--                              No. of records inserted into the MRC archive table
--                    p_MRC_NoOfRecordsDel                  IN NUMBER
--                              No. of records deleted from MRC table
-- End of comments
 Procedure  CommitProcess(p_purge_batch_id              IN NUMBER,
                          p_project_id                  IN NUMBER,
                          p_table_name		        IN VARCHAR2,
                          p_NoOfRecordsIns              IN NUMBER,
                          p_NoOfRecordsDel              IN NUMBER,
                          x_err_code                    IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_err_stack                   IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_err_stage                   IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          p_MRC_table_name              IN VARCHAR2  DEFAULT NULL,
                          p_MRC_NoOfRecordsIns          IN NUMBER    DEFAULT NULL,
                          p_MRC_NoOfRecordsDel          IN NUMBER    DEFAULT NULL
                          ) Is

 l_old_err_stack VARCHAR2(2000);  -- Increased the size from 1024 to 2000. Bug 4104182.
 l_dummy VARCHAR2(1);
 Begin

    l_old_err_stack := x_err_stack;

    X_err_stack := X_err_stack ||'->pa_purge.CommitProcess';
    X_err_stack := X_err_stack ||'Batch Id: '||p_purge_batch_id || 'Project Id: '||p_project_id ;

    pa_debug.debug(X_err_stack);

    -- update the pa_project_details with statistics
    pa_debug.debug('Before update of pa_project_details' );

      Update PA_PURGE_PRJ_DETAILS
      Set    num_recs_purged   = nvl(num_recs_purged,0) + nvl(p_NoOfRecordsDel,0)
            ,num_recs_archived = nvl(num_recs_archived,0) + nvl(p_NoOfRecordsIns,0)
            ,last_update_date=sysdate
            ,last_updated_by=fnd_global.user_id
            ,last_update_login=fnd_global.login_id
            ,program_id = fnd_global.conc_program_id
            ,program_application_id = fnd_global.prog_appl_id
            ,request_id = fnd_global.conc_request_id
            ,program_update_date = sysdate
      Where purge_batch_id = p_purge_batch_id
      And   project_id     = p_project_id
      And   Table_name     = p_table_name;

    pa_debug.debug('After update of pa_project_details' );
   -- If row doesnt exist then insert new row with statistics
   --
      IF SQL%Rowcount = 0 Then

      pa_debug.debug('Before insert into pa_project_details' );
         Insert into PA_PURGE_PRJ_DETAILS
         (
          purge_batch_id,
          project_id,
          table_name,
	  num_recs_purged,
          num_recs_archived,
          created_by,
          last_update_date,
          last_updated_by,
          last_update_login,
          creation_date,
          program_id,
          program_application_id,
          request_id,
          program_update_date
         )
         values
         (
	  p_purge_batch_id,
	  p_project_id,
          p_table_name,
          p_NoOfRecordsDel,
          p_NoOfRecordsIns,
          fnd_global.user_id,
	  sysdate,
          fnd_global.user_id,
          fnd_global.user_id,
          sysdate,
          fnd_global.conc_program_id,
          fnd_global.prog_appl_id,
          fnd_global.conc_request_id,
          sysdate
	 );

     pa_debug.debug('After insert into pa_project_details' );
     END IF;

     IF p_MRC_table_name is not null then
         X_err_stack := X_err_stack ||'->pa_purge.CommitProcess';
         X_err_stack := X_err_stack ||'Batch Id: '||p_purge_batch_id || 'Project Id: '||
                        p_project_id || 'MRC details' ;

         pa_debug.debug(X_err_stack);

         -- update the pa_project_details with MRC statistics
         pa_debug.debug('Before update of pa_project_details for MRC' );

         Update PA_PURGE_PRJ_DETAILS
         Set    num_recs_purged   = nvl(num_recs_purged,0) + nvl(p_MRC_NoOfRecordsDel,0)
                ,num_recs_archived = nvl(num_recs_archived,0) + nvl(p_MRC_NoOfRecordsIns,0)
                ,last_update_date=sysdate
                ,last_updated_by=fnd_global.user_id
                ,last_update_login=fnd_global.login_id
                ,program_id = fnd_global.conc_program_id
                ,program_application_id = fnd_global.prog_appl_id
                ,request_id = fnd_global.conc_request_id
                ,program_update_date = sysdate
          Where purge_batch_id = p_purge_batch_id
          And   project_id     = p_project_id
          And   Table_name     = p_MRC_table_name;

          pa_debug.debug('After MRC update of pa_project_details' );
          -- If row doesnt exist then insert new row with statistics
          --
          IF SQL%Rowcount = 0 Then

              pa_debug.debug('Before insert MRC into pa_project_details' );
              Insert into PA_PURGE_PRJ_DETAILS
              (
              purge_batch_id,
              project_id,
              table_name,
              num_recs_purged,
              num_recs_archived,
              created_by,
              last_update_date,
              last_updated_by,
              last_update_login,
              creation_date,
              program_id,
              program_application_id,
              request_id,
              program_update_date
              )
              values
              (
              p_purge_batch_id,
              p_project_id,
              p_MRC_table_name,
              p_MRC_NoOfRecordsDel,
              p_MRC_NoOfRecordsIns,
              fnd_global.user_id,
              sysdate,
              fnd_global.user_id,
              fnd_global.user_id,
              sysdate,
              fnd_global.conc_program_id,
              fnd_global.prog_appl_id,
              fnd_global.conc_request_id,
              sysdate
              );

          pa_debug.debug('After insert MRC into pa_project_details' );
          END IF;
      END IF;

     commit;

     -- Get the lock again after commit
     --
/* Added the condition for the bug#2510609 */
   if p_table_name not in ('PA_FORECAST_ITEMS', 'PA_FORECAST_ITEM_DETAILS', 'PA_FI_AMOUNT_DETAILS') then

     pa_debug.debug('Before locking pa_purge_batches again');

     Select  'x'
     Into l_dummy
     From pa_purge_batches
     Where purge_batch_id = p_purge_batch_id
     and request_id = fnd_global.conc_request_id
     For update;

     pa_debug.debug('After locking pa_purge_batches again');

   end if;

  x_err_stack := l_old_err_stack;

  Exception
  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error then
       RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
    pa_debug.debug('Error Procedure Name  := PA_PURGE.CommitProcess' );
    pa_debug.debug('Error stage is '||x_err_stage );
    pa_debug.debug('Error stack is '||x_err_stack );
    pa_debug.debug(SQLERRM);
    PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM ;

    RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;
 end CommitProcess;

-- Start of comments
-- API name         : get_post_purge_status
-- Type             : Private
-- Pre-reqs         : None
-- Function         : This function checks if the project is fully purged or
--                    partially purged for close projects and returns
--                    Returns the project status code ' Fully_Purged' or 'Partially_Purged'
--                    For active projects returns the old project status code
-- Parameters
--		      p_project_Id			IN     NUMBER,
--                              The project id for which purge status is to be determined
--                    p_batch_id                        IN     NUMBER,
--                              The purge batch id
-- End of comments
 Function get_post_purge_status ( p_project_id IN NUMBER, p_batch_id IN NUMBER)
                                Return VARCHAR2 IS

  l_purge_actuals_flag VARCHAR2(1);
  l_purge_capital_flag VARCHAR2(1);
  l_purge_budgets_flag VARCHAR2(1);
  l_purge_summary_flag VARCHAR2(1);
  l_active_closed_flag VARCHAR2(1);

/*  Changed the data length of l_next_p_project_status_code and l_next_pp_project_status_code to 90 for UTF8.
  l_last_project_status_code VARCHAR2(30);
*/
  l_last_project_status_code pa_purge_projects.Last_project_status_code%TYPE;
  l_project_type_class_code VARCHAR2(30);


 CURSOR next_p_pp_status IS
    SELECT next_p_project_status_code, next_pp_project_status_code
    FROM   pa_purge_projects
    WHERE  purge_batch_id = p_batch_id
    AND    project_id = p_project_id;

/*  Changed the data length of l_next_p_project_status_code and l_next_pp_project_status_code to 90 for UTF8.
 l_next_p_project_status_code  VARCHAR2(30);
 l_next_pp_project_status_code VARCHAR2(30);
 */

 l_next_p_project_status_code  pa_purge_projects.next_p_project_status_code%TYPE;
 l_next_pp_project_status_code pa_purge_projects.next_pp_project_status_code%TYPE;

BEGIN

  pa_debug.debug(' In function get_post_purge_status ');

  Select active_closed_flag
  into   l_active_closed_flag
  from   pa_purge_batches
  where  purge_batch_id = p_batch_id;

  IF  l_active_closed_flag = 'C'         THEN
  -- Select MAX of the flags for all rows of the project
  -- across all the purge batches that have been processed
  -- If the all the flags are 'Y' then the status is 'PURGED'
  -- else 'PARTIALLY_PURGED'
  --
	  Select MAX(purge_actuals_flag),
	         MAX(purge_capital_flag),
	         MAX(purge_budgets_flag),
	         MAX(purge_summary_flag)
	  Into   l_purge_actuals_flag,
	         l_purge_capital_flag,
		 l_purge_budgets_flag,
	         l_purge_summary_flag
	  From   pa_purge_projects
	  Where  project_id = p_project_id
	  And    purged_date is not null;

          OPEN next_p_pp_status;
          FETCH next_p_pp_status into l_next_p_project_status_code,
                                    l_next_pp_project_status_code;
          CLOSE next_p_pp_status;

-- Here if the Project is not a Capital Project then "purge_capital_flag" On pa_purge_projects
-- Will not be Y and will return the status as 'PARTIALLY PURGED' as there is no question
-- of purging any capital data for non capital project. So is project is NON CAPITAL then
-- traeting this as it has been purged for capital data completely.

          Select  pt.project_type_class_code
          into    l_project_type_class_code
          From    pa_projects_all p, pa_project_types_all pt
          where   p.project_type = pt.project_type
          and     p.org_id = pt.org_id -- Removed NVL for bug#5908179 by vvjoshi
          and     p.project_id = p_project_id;

          IF l_project_type_class_code <> 'CAPITAL' THEN
             l_purge_capital_flag := 'Y';
          END IF;

	  If    (l_purge_actuals_flag = 'N'
	     OR l_purge_capital_flag = 'N'
	     OR l_purge_summary_flag = 'N') THEN

             Return(l_next_pp_project_status_code);

	  Else

             Return(l_next_p_project_status_code);


	  End if;
 ELSE
	Select LAST_PROJECT_STATUS_CODE
	Into   l_last_project_status_code
        From   pa_purge_projects
        Where  project_id = p_project_id
        And    purge_batch_id   = p_batch_id;

        Return (l_last_project_status_code);

 END IF;

 exception
  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error then
       RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
    pa_debug.debug('Error functio Name  := PA_PURGE.get_post_purge_status ' );
    pa_debug.debug(SQLERRM);
    PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM ;

    RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

 end get_post_purge_status ;

end pa_purge ; /*Package Body*/

/
