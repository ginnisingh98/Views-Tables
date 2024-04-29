--------------------------------------------------------
--  DDL for Package Body PA_PURGE_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PURGE_VALIDATE" as
/* $Header: PAXVALDB.pls 120.2 2005/08/19 17:22:18 mwasowic noship $ */

 -- forward declarations

-- Start of comments
-- API name         : BatchVal
-- Type             : Public
-- Pre-reqs         : None
-- Function         : This procedure is the main validate procedure that calls
--                    the validate_attribute_change procedure. This procedure
--                    gets all the projects from this batch and pass it one
--                    by one to validate_attribute_change procedure.
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

   procedure BatchVal ( errbuf                    IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                        ret_code                  IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                        p_purge_batch_id          IN NUMBER)

 is

  -- This cursor fetches the active_closed flag in the batch
  -- and locks the batch. Locking the batch is necessary because
  -- one batch should not be picked by two batches simultaneously
  -- for validation
  cursor GetBatchDet is
      select pb.active_closed_flag
        from pa_purge_batches pb
       where pb.purge_batch_id = p_purge_batch_id
       for update of pb.purge_batch_id nowait ;

  -- This cursor fetches all the projects in the batch.
  cursor GetProjectsInBatch is
      select pp.project_id,
   /*       pt.project_type_class_code,
              p.project_status_code,  Commented for bug 2715317*/     /* project current status */
             pp.last_project_status_code,
             pp.purge_project_status_code,   /* Bug#2416385 Added for Phase -III Archive and Purge */
             pp.purge_summary_flag,
             pp.purge_capital_flag,
             pp.purge_actuals_flag,
             pp.purge_budgets_flag,
             pp.txn_to_date
    /*  from pa_project_types pt,
             pa_projects p,         Commented for bug 2715317 */
        from pa_purge_projects pp
       where pp.purge_batch_id = p_purge_batch_id
    /*   and p.project_type = pt.project_type
         and nvl(pt.org_id, -99) = nvl(p.org_id, -99)
         and pp.project_id = p.project_id                     Commented for bug 2715317 */
       for update of pp.purge_project_status_code nowait ;

  /* bug 4255353 starts here*/
      cursor Getpurge_summaryflag(p_project_id IN NUMBER) is
      select    pp.purge_summary_flag
        from pa_purge_projects pp
       where pp.purge_batch_id = p_purge_batch_id
        and pp.project_id=p_project_id;

      l_GetProjectsInBatch_csr       GetProjectsInBatch%rowtype;
      l_GetBatchDet_csr              GetBatchDet%rowtype ;
      l_err_code                     NUMBER;
      l_err_stack                    VARCHAR2(2000);
      l_err_stage                    VARCHAR2(500);
      l_error_msg                    VARCHAR2(30);
      l_error_code                   NUMBER := 0;
      /* Added l_project_type_class_code ,l_project_status_code for bug 2715317 */
      l_project_type_class_code      pa_project_types_all.project_type_class_code%type;
      l_project_status_code          pa_projects_all.project_status_code%type;
      /* Bug#2416385 Added the variable l_purge_project_status_code for Phase -III Archive and Purge */
      l_purge_project_status_code  pa_purge_projects.purge_project_status_code%TYPE;
      l_warnings_only_flag VARCHAR2(1) := 'N'; --bug3134205
 BEGIN
     Open GetBatchDet ;
     Fetch GetBatchDet into l_GetBatchDet_csr ;


     g_delete_errors           := 'Y';  /* Bug#2416385 Added for Phase -III Archive and Purge */
     g_active_flag                              := l_GetBatchDet_csr.active_closed_flag ;
     pa_purge_validate.g_user                   := fnd_profile.value('USER_ID');
     pa_purge_validate.g_request_id             := fnd_global.conc_request_id ;
     pa_purge_validate.g_Program_Application_Id := fnd_global.prog_appl_id ;
     pa_purge_validate.g_program_id             := fnd_global.conc_program_id ;

     Open GetProjectsInBatch ;
     l_err_stage := 'After open cursor GetProjectsInBatch' ;
--     l_err_stack := err_stack || ' ->After open cursor GetProjectsInBatch' ;
--
     pa_debug.debug('Fetching the projects ');
     LOOP


        FND_MSG_PUB.Initialize ;

        -- Fetch the next project from the cursor

        Fetch GetProjectsInBatch into l_GetProjectsInBatch_csr ;


        If GetProjectsInBatch%NotFound then
            l_err_stage := 'No more records to process' ;
--            l_err_stack := err_stack || ' ->No more records to process' ;
            pa_debug.debug('No more projects to process');
            exit ;
        End If;
        -- Check project status has been changed during, project selected in batch to
        -- validation process.

     /* Bug 2715317 starts */
     Select pt.project_type_class_code,
            p.project_status_code
       into l_project_type_class_code,
            l_project_status_code
       from pa_project_types pt,
            pa_projects p
      where p.project_type = pt.project_type
        and p.project_id = l_GetProjectsInBatch_csr.project_id;
     /* Bug 2715317 ends */


	/* bug 4255353 starts here*/
        open Getpurge_summaryflag(l_GetProjectsInBatch_csr.project_id);
        Fetch Getpurge_summaryflag into pa_purge_validate_pjrm.g_purge_summary_flag ;
        close Getpurge_summaryflag;
         /* bug 4255353 ends here*/
/*      IF (l_GetProjectsInBatch_csr.project_status_code <> 'PENDING_PURGE') AND
           (l_GetProjectsInBatch_csr.project_status_code <>   Commented for Bug 2715317 */
        IF (l_project_status_code <> 'PENDING_PURGE') AND      /* Added for Bug 2715317 */
           (l_project_status_code <>
               l_GetProjectsInBatch_csr.last_project_status_code) THEN
           fnd_message.set_name('PA','PA_ARPR_PROJ_STATUS_CHANGED');
           fnd_msg_pub.add;
           l_err_code := 10;
           l_err_stage := 'This project status has been changed.';
           l_err_stack := l_err_stack||'->Project status changed';
           pa_debug.debug(' This project status changed after selecting a batch '||to_char(l_GetProjectsInBatch_csr.project_id));
        ELSE

           -- If current project status for project is same as in batch project last project status.
           -- Then run validation process.
           g_txn_to_date   := l_GetProjectsInBatch_csr.txn_to_date  ;

	   pa_purge_validate_capital.g_purge_capital_flag :=
			     l_GetProjectsInBatch_csr.purge_capital_flag;  /* Bug#2387342 */

/* g_project_type_class_code := l_GetProjectsInBatch_csr.project_type_class_code ; Commented for Bug 2715317 */
           g_project_type_class_code   := l_project_type_class_code  ; /* Added for Bug 2715317 */

           pa_debug.debug('Validating project '||to_char(l_GetProjectsInBatch_csr.project_id));
           -- Call the validation procedure

           if l_GetProjectsInBatch_csr.last_project_status_code <> 'PARTIALLY_PURGED' then

             pa_project_utils2.validate_attribute_change(
                                    x_Context                   => 'ARCHIVE_PURGE'
                                 ,  x_Insert_Update_Mode        => NULL
                                 ,  x_Calling_Module            => NULL
                                 ,  x_project_id                => l_GetProjectsInBatch_csr.project_id
                                 ,  x_Task_id                   => NULL
                                 ,  x_old_value                 => l_GetProjectsInBatch_csr.last_project_status_code
                                 ,  x_new_value                 => 'PENDING_PURGE'
                                 ,  x_Project_Type              => NULL
                                 ,  x_Project_Start_Date        => NULL
                                 ,  x_Project_End_Date          => NULL
                                 ,  x_Public_Sector_Flag        => NULL
                                 ,  x_Task_Manager_Person_Id    => NULL
                                 ,  x_Service_Type              => NULL
                                 ,  x_Task_Start_Date           => NULL
                                 ,  x_Task_End_Date             => NULL
                                 ,  x_Entered_By_User_Id        => NULL
                                 ,  x_Attribute_Category        => NULL
                                 ,  x_Attribute1                => NULL
                                 ,  x_Attribute2                => NULL
                                 ,  x_Attribute3                => NULL
                                 ,  x_Attribute4                => NULL
                                 ,  x_Attribute5                => NULL
                                 ,  x_Attribute6                => NULL
                                 ,  x_Attribute7                => NULL
                                 ,  x_Attribute8                => NULL
                                 ,  x_Attribute9                => NULL
                                 ,  x_Attribute10               => NULL
                                 ,  x_PM_Product_Code           => NULL
                                 ,  x_PM_Project_Reference      => NULL
                                 ,  x_PM_Task_Reference         => NULL
                                 ,  x_Functional_Security_Flag  => NULL
	                         ,  x_warnings_only_flag        => l_warnings_only_flag --bug3134205
                                 ,  x_err_code                  => l_err_code
                                 ,  x_err_stage                 => l_err_stage
                                 ,  x_err_stack                 => l_err_stack ) ;
	else

	    /* Code changes for Bug 4255353 starts here */
	        pa_purge_validate_pjrm.Validate_Perf_reporting(p_project_id       => l_GetProjectsInBatch_csr.project_id,
                                            x_err_code         => l_err_code,
                                            x_err_stack        => l_err_stack,
                                            x_err_stage        => l_err_stage
                                           );

	    /* Code changes for Bug 4255353 ends here */

          END IF; -- Validation.

        END IF; -- Project status is changed.

        pa_purge_validate.insert_errors(p_Purge_Batch_Id     => p_purge_batch_id,
                                        p_Project_Id         => l_GetProjectsInBatch_csr.project_id,
                                        p_Error_Type         => 'E',
                                        p_User               => pa_purge_validate.g_user,
                                        x_Err_Stack          => l_err_stack,
                                        x_Err_Stage          => l_err_stage,
                                        x_Err_Code           => l_err_code
                                       );

     end loop ;

     -- Update the batch status to working.
     update pa_purge_batches pb
        set pb.batch_status_code       = 'W',
            pb.request_id              = pa_purge_validate.g_request_id,
            pb.program_application_id  = pa_purge_validate.g_program_application_id,
            pb.program_id              = pa_purge_validate.g_program_id ,
            pb.program_update_date     = sysdate,
            pb.last_update_login       = -1,
            pb.last_updated_by         = -1,
            pb.last_update_date        = sysdate
      where pb.purge_batch_id = p_purge_batch_id ;


     close GetProjectsInBatch;
     close GetBatchDet ;

  /* Bug#2416385 Code added for Phase -III Archive and Purge starts here */

  /* If any of the Project which is a Receiver Project (InterProject Setup) is pulled in purge batch,
     we will NOT pull associated provider projects programmatically. But the code will Invalidate the
     receiver project prompting user to pull all associated un-purged provider projects in the same
     batch or to remove receiver project from the batch to make the batch valid for purge.
     To implement the above logic, the Interproject receiver project validation is called after all
     the regular checks are completed.
     Individually receiver and provider projects can be valid for regular checks but after the
     receiver project validation, the receiver project can be invalid incase,
      1. if any of its provider projects which is not in purge status and is not included in the
         purge batch  or
      2. included in the purge batch but is invalid for regular checks
  */

     FOR c_prj_in_batch in GetProjectsInBatch LOOP

       g_delete_errors := 'N';
       pa_purge_validate_icip.g_insert_errors_no_duplicate := 'N'; /* Bug# 2431705  */

       FND_MSG_PUB.Initialize;

       if c_prj_in_batch.last_project_status_code <> 'PARTIALLY_PURGED' then

          if pa_purge_validate_icip.Is_InterPrj_Receiver_Project(c_prj_in_batch.project_id) = 'Y' then

               pa_debug.debug('    * Calling validate process for IP receiver project for project '||
           			   to_char(c_prj_in_batch.project_id));

               pa_purge_validate_icip.Validate_IP_Rcvr ( c_prj_in_batch.project_id,
							l_err_code,
							l_err_stack,
							l_err_stage );

               pa_purge_validate.insert_errors ( p_Purge_Batch_Id     => p_purge_batch_id,
						 p_Project_Id         => c_prj_in_batch.project_id,
						 p_Error_Type         => 'E',
						 p_User               => pa_purge_validate.g_user,
						 x_Err_Stack          => l_err_stack,
						 x_Err_Stage          => l_err_stage,
						 x_Err_Code           => l_err_code );

		 select purge_project_status_code
		   into l_purge_project_status_code
		   from pa_purge_projects
		  where project_id     = c_prj_in_batch.project_id
		    and purge_batch_id = p_purge_batch_id ;

               if ( (l_purge_project_status_code <> c_prj_in_batch.purge_project_status_code) and
           	    (l_purge_project_status_code = 'I') ) then

		     update pa_projects_all p
			set p.project_status_code = c_prj_in_batch.last_project_status_code,
			    p.last_update_date    = sysdate,
			    p.last_updated_by     = -1,
			    p.last_update_login   = -1
		      where p.project_id = c_prj_in_batch.project_id;

               end if;

          end if;  /* pa_purge_validate_icip.Is_InterPrj_Receiver_Project check */

     end if;  /* c_prj_in_batch.last_project_status_code <> 'PARTIALLY_PURGED' check  */

     END LOOP;

    /* Bug#2416385 Code added for Phase -III Archive and Purge ends here */

     commit ;

EXCEPTION
  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error THEN
        errbuf := PA_PROJECT_UTILS2.g_sqlerrm ;
        ret_code := -1 ;
  WHEN OTHERS THEN
    errbuf := SQLERRM ;
    ret_code := -1 ;

 END BatchVal;

-- Start of comments
-- API name         : insert_errors
-- Type             : Public
-- Pre-reqs         : None
-- Function         : This procedure inserts all the errors for a project into
--                    the error table.
--
-- Parameters       : p_purge_batch_id                         NUMBER
--                              The purge batch id for which rows have
--                              to be purged/archived.
--		      p_project_Id			IN     NUMBER,
--                              The project id for which records have
--                              to be purged/archived.
--		      p_error_type			IN OUT VARCHAR2,
--                              This flag indicates if it is an error or
--                              warning.
--		      p_user				IN OUT VARCHAR2,
--                              This will get the user_id to the procedure
--		      X_Err_Stack			IN OUT VARCHAR2,
--                              Error stack
--		      X_Err_Stage		        IN OUT VARCHAR2,
--                              Stage in the procedure where error occurred
--		      X_Err_Code		        IN OUT NUMBER
--                              Error code returned from the procedure
-- End of comments

 procedure insert_errors ( p_purge_batch_id             in NUMBER,
                           p_project_id                 in NUMBER,
                           p_error_type                 in VARCHAR2,
                           p_user                       in NUMBER,
                           X_err_stack                  in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                           X_err_stage                  in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                           X_err_code                   in OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                         ) is

     l_Count                NUMBER ;
     l_MesgCount            NUMBER ;
     l_err_stage            VARCHAR2(2000);
     l_err_stack            VARCHAR2(2000);
     l_err_stack_old        VARCHAR2(2000);
     l_message_code         VARCHAR2(50);
     l_msg_data             VARCHAR2(30);
     l_chr                  VARCHAR2(3);
     l_msg_index_Out        NUMBER ;
     l_encoded              VARCHAR2(30) := FND_API.G_TRUE ;
     l_app_name             VARCHAR2(3);
 BEGIN

     l_chr  := convert(fnd_global.local_chr(12), substr(userenv('LANGUAGE'),
                                       instr(userenv('LANGUAGE'),'.') +1),
                       'WE8ISO8859P1') ;
     l_err_stack     := X_err_stack ;
     l_err_stack_old := X_err_stack ;
     l_err_stack     := X_err_stack || '-> Inserting errors to the error table ' ;
     l_MesgCount     := FND_MSG_PUB.Count_Msg ;

     if g_delete_errors = 'Y' then  /* Bug#2416385 Added for Phase -III Archive and Purge */

     pa_debug.debug('Deleting errors for the project '||to_char(p_project_id)||' in batch '||to_char(p_purge_batch_id));
     x_err_stage := 'Deleting errors for the project '||to_char(p_project_id)||' in batch '||to_char(p_purge_batch_id);
     X_err_stack := X_err_stack || '-> Deleting errors for the project '||to_char(p_project_id) ;

	     delete from pa_purge_project_errors pe
	      where pe.purge_batch_id = p_purge_batch_id
		and pe.project_id     = p_project_id ;

     end if;

     if l_MesgCount = 0 then


       if g_delete_errors = 'Y' then /* Bug#2416385 Added for Phase -III Archive and Purge */

         -- This means there are no errors for this validation run. So delete
         -- all the errors from the previous run if exists and update the
         -- project to Valid. Also update the status of the project in
         -- PA_PROJECTS to 'PENDING_PURGE'.

         pa_debug.debug('Updating purge_project_status_code to valid for project '||to_char(p_project_id)) ;
         X_err_stage := 'No errors . Updating purge_project_status_code to valid for project '||to_char(p_project_id) ;

         update pa_purge_projects pp
            set pp.purge_project_status_code = 'V',
                pp.request_id                = pa_purge_validate.g_request_id,
                pp.program_application_id    = pa_purge_validate.g_program_application_id,
                pp.program_id                = pa_purge_validate.g_program_id ,
                pp.program_update_date       = sysdate
          where pp.project_id     = p_project_id
            and pp.purge_batch_id = p_purge_batch_id ;

  /* Bug#2416385 Modified the pa_projects to pa_projects_all for Phase -III Archive and Purge */
         update pa_projects_all p
            set p.project_status_code = 'PENDING_PURGE',
                p.last_update_date    = sysdate,
                p.last_updated_by     = -1,
                p.last_update_login   = -1
          where p.project_id = p_project_id ;

      end if;   /* if g_delete_errors = 'Y check */

     else

         -- If l_MesgCount is greater than 0 then errors exist for the project
         -- and
         pa_debug.debug('Inserting validation errors for project '||to_char(p_project_id));
         X_err_stage := 'Inserting validation errors for project '||to_char(p_project_id) ;

         for i in 1..l_MesgCount
         LOOP
             FND_MSG_PUB.Get(p_encoded       => l_encoded,
                             p_data          => l_message_code,
                             p_msg_index     => 1,
                             p_msg_index_out => l_msg_index_out) ;
             pa_debug.debug('Message is '||replace(replace(l_message_code,'PA'||l_chr), l_chr));

	     l_app_name := 'PA';
	     if l_message_code is not null then

		FND_MESSAGE.PARSE_ENCODED(ENCODED_MESSAGE => l_message_code,
					  APP_SHORT_NAME  => l_app_name,
					  MESSAGE_NAME    => l_msg_data);

		FND_MSG_PUB.DELETE_MSG(p_msg_index => 1);

		pa_debug.debug('l_msg_data:'||l_msg_data);

	     end if;

             insert into pa_purge_project_errors
             ( purge_batch_id,
               project_id,
               error_code,
               error_type,
               created_by,
               creation_date,
               last_updated_by,
               last_update_date,
               last_update_login  )
             values (p_purge_batch_id,
                     p_project_id,
--                     replace(replace(l_message_code,'PA'||l_chr), l_chr),
                     l_msg_data,
                     p_error_type,
                     -1,
                     sysdate,
                     -1,
                     sysdate,
                     -1) ;

         END LOOP ;

         pa_debug.debug('Updating purge_project_status_code to invalid for project '||to_char(p_project_id));
         X_err_stage := 'Updating purge_project_status_code to invalid for project '||to_char(p_project_id) ;
         update pa_purge_projects pp
            set pp.purge_project_status_code = 'I',
                pp.request_id                = pa_purge_validate.g_request_id,
                pp.program_application_id    = pa_purge_validate.g_program_application_id,
                pp.program_id                = pa_purge_validate.g_program_id ,
                pp.program_update_date       = sysdate
          where pp.project_id     = p_project_id
            and pp.purge_batch_id = p_purge_batch_id ;
     end if;

     x_err_stack  := l_err_stack_old ;

EXCEPTION
  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error then
       RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
--    x_err_stage := l_err_stage ;
    pa_debug.debug('Error Procedure Name  := PA_PURGE_VALIDATE.INSERT_ERRORS' );
    pa_debug.debug('Error stage is '||x_err_stage );
    pa_debug.debug('Error stack is '||x_err_stack );
    pa_debug.debug(SQLERRM);
    PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM ;

    RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

 END insert_errors ;

END pa_purge_validate;

/
