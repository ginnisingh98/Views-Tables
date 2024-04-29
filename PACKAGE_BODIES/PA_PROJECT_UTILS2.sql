--------------------------------------------------------
--  DDL for Package Body PA_PROJECT_UTILS2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJECT_UTILS2" as
-- $Header: PAXPUT2B.pls 120.6.12010000.4 2009/10/19 12:54:42 acprakas ship $

-- ----------------------------------------------------------
-- Validate_Attribute_Change
--   X_err_code:
--       > 0   for application business errors
--       < 0   for SQL errors
--       = 0   for success
--  If X_err_code > 0, X_err_stage contains the message code
--     X_err_code < 0, X_err_stage contains SQLCODE
-- ----------------------------------------------------------

PROCEDURE validate_attribute_change(
       X_Context                IN VARCHAR2
    ,  X_insert_update_mode     IN VARCHAR2
    ,  X_calling_module         IN VARCHAR2
    ,  X_project_id             IN NUMBER
    ,  X_task_id                IN NUMBER
    ,  X_old_value              IN VARCHAR2
    ,  X_new_value              IN VARCHAR2
    ,  X_project_type           IN VARCHAR2
    ,  X_project_start_date     IN DATE
    ,  X_project_end_date       IN DATE
    ,  X_public_sector_flag     IN VARCHAR2
    ,  X_task_manager_person_id IN NUMBER
    ,  X_Service_type           IN VARCHAR2
    ,  X_task_start_date        IN DATE
    ,  X_task_end_date          IN DATE
    ,  X_entered_by_user_id     IN NUMBER
    ,  X_attribute_category     IN VARCHAR2
    ,  X_attribute1             IN VARCHAR2
    ,  X_attribute2             IN VARCHAR2
    ,  X_attribute3             IN VARCHAR2
    ,  X_attribute4             IN VARCHAR2
    ,  X_attribute5             IN VARCHAR2
    ,  X_attribute6             IN VARCHAR2
    ,  X_attribute7             IN VARCHAR2
    ,  X_attribute8             IN VARCHAR2
    ,  X_attribute9             IN VARCHAR2
    ,  X_attribute10            IN VARCHAR2
    ,  X_pm_product_code        IN VARCHAR2
    ,  X_pm_project_reference   IN VARCHAR2
    ,  X_pm_task_reference      IN VARCHAR2
    ,  X_functional_security_flag IN VARCHAR2
    ,  x_warnings_only_flag       OUT    NOCOPY varchar2 --bug3134205 --File.Sql.39 bug 4440895
    ,  X_err_code                 IN OUT    NOCOPY number --File.Sql.39 bug 4440895
    ,  X_err_stage                IN OUT    NOCOPY varchar2 --File.Sql.39 bug 4440895
    ,  X_err_stack                IN OUT    NOCOPY varchar2) --File.Sql.39 bug 4440895
IS
  x_yes_no   varchar2(1);
  x_pt_class_meaning varchar2(80);
  x_outcome   varchar2(80);
  old_stack      varchar2(2000); /* Increased the array size from 630 */
  l_error_number  NUMBER;
  l_warnings_only_flag  VARCHAR2(1) := 'N';
  l_system_status_code varchar2(30);
  l_proj_type_class_code varchar2(30);
  l_err_msgname VARCHAR2(30);

  -- Added by sunkalya for bug:4687520
  l_return_status         VARCHAR2(100);
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(2000);
  l_start_no_mgr_date     DATE;
  l_end_no_mgr_date       DATE;
  l_error_occured         VARCHAR2(100) := 'N';
  -- End of code added by Sunkalya for Bug:4687520

  -- These two variables will keep track of the very first error that we
  -- encounter.  We need to do this because we'll continue processing
  -- even though an error has occurred
  l_error_msg  VARCHAR2(30);
  l_error_code NUMBER := 0;

--MOAC Changes: Bug 4363092: removed nvl usage with org_id
  cursor c is
  select nvl(decode(pt.project_type_class_code,'INDIRECT',org_information1
					  , 'CAPITAL',org_information12
					  , 'CONTRACT',org_information13),'Y')
         ,meaning
  from hr_organization_information org
       , pa_project_types_all pt   -- Bug#3807805 : Modified pa_project_types to pa_project_types_all
       , pa_lookups lps
  where org.organization_id(+) = nvl(x_new_value,x_old_value)
  and  upper(org.org_information_context(+)) = upper('Project Type Class Information')
  and  pt.project_type = x_project_type
  and  lps.lookup_type(+) = 'PROJECT TYPE CLASS'
  and  lps.lookup_code(+) = pt.project_type_class_code
  and  pt.org_id = PA_PROJECT_REQUEST_PVT.G_ORG_ID; -- Added the and condition for Bug#3807805

Begin
  x_err_code := 0;
  old_stack := x_err_stack;
  x_err_stack := x_err_stack || '->PA_PROJECT_UTILS.VALIDATE_ATTRIBUTE_CHANGE';

  If X_Context = 'ORGANIZATION_VALIDATION' then
     --
     -- Validating whether the Org selected allows creating Projects or Tasks
     -- with the PT class . This info for the Org is specified when
     -- definining the org in HR.
     -- PT class for a Project is determined from the project type specified
     -- for the Project.
     --
   if PA_PROJECT_REQUEST_PVT.G_ORG_ID is null and X_project_type is not null then       -- Added the if block for Bug#3807805
      select org_id into PA_PROJECT_REQUEST_PVT.G_ORG_ID from pa_project_types where project_type = X_project_type;
   end if;

   open c;
   fetch c into x_yes_no
	      , x_pt_class_meaning;
   close c;

   if x_yes_no = 'N' then
     x_err_code := 10;
     x_err_stage := 'PA_INVALID_PT_CLASS_ORG';
     return;
   end if;

   --
   -- Calling the Client Extension for Org Validation
   pa_org_client_extn.verify_org_change(
                X_insert_update_mode    =>X_insert_update_mode
	     ,  X_calling_module        =>X_calling_module
	     ,  X_project_id            =>X_project_id
	     ,  X_task_id               =>X_task_id
	     ,  X_old_organization_id   =>to_number(X_old_value)
	     ,  X_new_organization_id   =>to_number(x_new_value)
	     ,  X_project_type          =>X_project_type
	     ,  X_project_start_date    =>X_project_start_date
	     ,  X_project_end_date      =>X_project_end_date
	     ,  X_public_sector_flag    =>X_public_sector_flag
	     ,  X_task_manager_person_id =>X_task_manager_person_id
	     ,  X_Service_type           =>X_Service_type
	     ,  X_task_start_date        =>X_task_start_date
	     ,  X_task_end_date          =>X_task_end_date
	     ,  X_entered_by_user_id    =>X_entered_by_user_id
	     ,  X_attribute_category    =>X_attribute_category
	     ,  X_attribute1            =>X_attribute1
	     ,  X_attribute2            =>X_attribute2
	     ,  X_attribute3            =>X_attribute3
	     ,  X_attribute4            =>X_attribute4
	     ,  X_attribute5            =>X_attribute5
	     ,  X_attribute6            =>X_attribute6
	     ,  X_attribute7            =>X_attribute7
	     ,  X_attribute8            =>X_attribute8
	     ,  X_attribute9            =>X_attribute9
	     ,  X_attribute10           =>X_attribute10
	     ,  X_pm_product_code       =>X_pm_product_code
	     ,  X_pm_project_reference  =>X_pm_project_reference
             ,  X_pm_task_reference     =>X_pm_task_reference
	     ,  X_functional_security_flag => X_functional_security_flag
	     ,  X_outcome               =>X_outcome );
     if x_outcome  is not null then

/*   Commented for bug 2981386
	 if (SUBSTRB(x_outcome, 1, 3) = 'PA_') then
           x_err_code := 15;    --Changed to 15
         else
           BEGIN
	     l_error_number := to_number(x_outcome);
	     x_err_code := -1;
           EXCEPTION
	     WHEN OTHERS THEN
	     x_err_code := 10;
           END;
         end if;
*/
	 x_err_code := 15; /* Added for bug 2981386 */
         x_err_stage  := X_outcome ;
         return;
     end if;

ELSIF  X_Context = 'PROJECT_STATUS_CHANGE' then
  IF x_new_value IS NULL OR x_project_id IS NULL THEN
     x_err_code := 0;
     RETURN;
  END IF;

  IF x_new_value IS NOT NULL THEN
    select project_system_status_code
      into l_system_status_code
      from pa_project_statuses
     where project_status_code = X_new_value;
  END IF;

    IF (l_system_status_code IN ('APPROVED', 'SUBMITTED')) THEN

      PA_PROJECT_VERIFY_PKG.Category_Required(
		  x_project_id	=>  X_Project_Id,
                  x_err_stage   =>  X_err_stage,
                  x_err_code    =>  X_err_code,
		  x_err_stack   =>  X_err_stack,
		  x_err_msgname	=>  l_err_msgname );

	IF (x_err_code > 0) THEN
		IF (l_err_msgname IS NOT NULL) THEN
		  fnd_message.set_name('PA', l_err_msgname);
		  fnd_msg_pub.add;
		END IF;
		l_error_code := X_err_code;
		l_error_msg := x_err_stage;
	ELSIF (X_err_code < 0) THEN
		FND_MSG_PUB.Add_Exc_Msg(
			p_pkg_name	  => 'PA_PROJECT_VERIFY_PKG',
			p_procedure_name  => 'CATEGORY_REQUIRED',
			p_error_text	  => 'ORA-'||LPAD(substr(to_char(x_err_code),2),5,'0'));
		l_error_code := -1;
		l_error_msg := to_char(x_err_code);
	END IF;

	      -- Get the project type class code
      --MOAC Changes: Bug 4363092: removed nvl usage with org_id
	  IF x_project_id IS NOT NULL THEN
	      select pt.project_type_class_code
		into l_proj_type_class_code
		from pa_projects_all p,  -- Bug#3807805 : Modified pa_projects to pa_projects_all
		     pa_project_types_all pt  -- Bug#3807805 : Modified pa_project_types to pa_project_types_all
	       where p.project_id = X_Project_ID
		 and p.project_type = pt.project_type
		 and p.org_id = pt.org_id;  -- Added the and condition for Bug#3807805
	  END IF;

      -- Additional validation is required for Contract projects
     IF (l_proj_type_class_code = 'CONTRACT') THEN

        PA_PROJECT_VERIFY_PKG.Customer_Exists(
	 	  x_project_id	=>  X_Project_Id,
                  x_err_stage   =>  X_err_stage,
                  x_err_code    =>  X_err_code,
		  x_err_stack   =>  X_err_stack,
		  x_err_msgname	=>  l_err_msgname );

        IF (x_err_code > 0) THEN
		  IF (l_err_msgname IS NOT NULL) THEN
		    fnd_message.set_name('PA', l_err_msgname);
		    fnd_msg_pub.add;
		  END IF;
		  IF (l_error_code = 0) THEN
		    l_error_code := X_err_code;
		    l_error_msg := x_err_stage;
		  END IF;
        ELSIF (X_err_code < 0) THEN
		  FND_MSG_PUB.Add_Exc_Msg(
			p_pkg_name	  => 'PA_PROJECT_VERIFY_PKG',
			p_procedure_name  => 'CUSTOMER_EXISTS',
			p_error_text	  => 'ORA-'||LPAD(substr(to_char(x_err_code),2),5,'0'));
		  IF (l_error_code = 0) THEN
		    l_error_code := -1;
		    l_error_msg := to_char(x_err_code);
		  END IF;
        END IF;
        /* Start of code change Done for Bug:4687520. Done by Sunkalya. */
        /*PA_PROJECT_VERIFY_PKG.Manager_Exists(
		  x_project_id	=>  X_Project_Id,
                  x_err_stage   =>  X_err_stage,
                  x_err_code    =>  X_err_code,
		  x_err_stack   =>  X_err_stack,
		  x_err_msgname	=>  l_err_msgname );

        IF (x_err_code > 0) THEN
		  IF (l_err_msgname IS NOT NULL) THEN
		    fnd_message.set_name('PA', l_err_msgname);
		    fnd_msg_pub.add;
		  END IF;
		  IF (l_error_code = 0) THEN
		    l_error_code := X_err_code;
		    l_error_msg := x_err_stage;
		  END IF;
        ELSIF (X_err_code < 0) THEN
		  FND_MSG_PUB.Add_Exc_Msg(
			p_pkg_name	  => 'PA_PROJECT_VERIFY_PKG',
			p_procedure_name  => 'MANAGER_EXISTS',
			p_error_text	  => 'ORA-'||LPAD(substr(to_char(x_err_code),2),5,'0'));
		  IF (l_error_code = 0) THEN
		    l_error_code := -1;
		    l_error_msg := to_char(x_err_code);
		  END IF;
        END IF; */ --This entire API call is Commented for Bug:4687520
        IF l_system_status_code = 'APPROVED' THEN

        -- Putting a savepoint and changing project status to 'APPROVED' temporarily
        -- since PA_PROJECT_PARTIES_UTILS.VALIDATE_ONE_MANAGER_EXISTS and
        -- PA_PROJECT_PARTIES_UTILS.validate_manager_date_range will do the checks
        -- only if the project is an approved contract project.

          savepoint checking_manager_validity;

          update pa_projects_all
          set project_status_code = 'APPROVED'
          where project_id = x_project_id;

          -- Calling the procedures that do the checks

          PA_PROJECT_PARTIES_UTILS.VALIDATE_ONE_MANAGER_EXISTS( p_project_id    => x_project_id
                                                               ,x_return_status => l_return_status
                                                               ,x_msg_count     => l_msg_count
                                                               ,x_msg_data      => l_msg_data);

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

            IF (l_error_code = 0) THEN
              IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 l_error_code := 10;
                 l_error_msg := l_msg_data;
              ELSE
                 l_error_code := -1;
                 l_error_msg := l_msg_data;
              END IF;
            END IF;

          ELSE
            l_error_occured := 'N';

            PA_PROJECT_PARTIES_UTILS.validate_manager_date_range( p_mode               => 'SS'
                                                                 ,p_project_id         => x_project_id
                                                                 ,x_start_no_mgr_date  => l_start_no_mgr_date
                                                                 ,x_end_no_mgr_date    => l_end_no_mgr_date
                                                                 ,x_error_occured      => l_error_occured);

            IF l_error_occured <> 'N' THEN

              IF l_error_occured = 'PA_PR_NO_MGR_DATE_RANGE' THEN
 IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                         pa_utils.add_message
                            ( p_app_short_name   => 'PA'
                             ,p_msg_name         => 'PA_PR_NO_MGR_DATE_RANGE'
                             ,p_token1           => 'START_DATE'
                             ,p_value1           => l_start_no_mgr_date
                             ,p_token2           => 'END_DATE'
                             ,p_value2           => l_end_no_mgr_date
                             );
                END IF;

                IF (l_error_code = 0) THEN
                  l_error_code := 10;
                  l_error_msg := l_error_occured;
                END IF;
              ELSE
               IF (l_error_code = 0) THEN
                 l_error_code := -1;
                 l_error_msg := l_error_occured;
               END IF;
              END IF;
            END IF;
          END IF;

         rollback to checking_manager_validity;

        END IF; -- Checks for project manager done

        /* End of changes for bug 4687520 Done by Sunkalya */

    -- Commented below code for the bug 4867044
   /*     PA_PROJECT_VERIFY_PKG.Contact_Exists(
		  x_project_id	=>  X_Project_Id,
                  x_err_stage   =>  X_err_stage,
                  x_err_code    =>  X_err_code,
		  x_err_stack   =>  X_err_stack,
		  x_err_msgname	=>  l_err_msgname );

        IF (x_err_code > 0) THEN
		  IF (l_err_msgname IS NOT NULL) THEN
		    fnd_message.set_name('PA', l_err_msgname);
		    fnd_msg_pub.add;
		  END IF;
		  IF (l_error_code = 0) THEN
		    l_error_code := X_err_code;
		    l_error_msg := x_err_stage;
		  END IF;
        ELSIF (X_err_code < 0) THEN
		  FND_MSG_PUB.Add_Exc_Msg(
			p_pkg_name	  => 'PA_PROJECT_VERIFY_PKG',
			p_procedure_name  => 'CONTACT_EXISTS',
			p_error_text	  => 'ORA-'||LPAD(substr(to_char(x_err_code),2),5,'0'));
		  IF (l_error_code = 0) THEN
		    l_error_code := -1;
		    l_error_msg := to_char(x_err_code);
		  END IF;
        END IF;
*/  -- End of commented code for the bug 4867044
      END IF;   -- (l_proj_type_class_code = 'CONTRACT')
    END IF;  -- (l_system_status_code IN ('APPROVED', 'SUBMITTED'))

    -- Call the client extn to verify project status changes
    pa_client_extn_proj_status.verify_project_status_change
            (x_calling_module           => x_calling_module
            ,X_project_id               => X_project_id
            ,X_old_proj_status_code     => X_old_value
            ,X_new_proj_status_code     => x_new_value
            ,X_project_type             => x_project_type
            ,X_project_start_date       => X_project_start_date
            ,X_project_end_date         => X_project_end_date
            ,X_public_sector_flag       => X_public_sector_flag
            ,X_attribute_category       => X_attribute_category
            ,X_attribute1               => X_attribute1
            ,X_attribute2               => X_attribute2
            ,X_attribute3               => X_attribute3
            ,X_attribute4               => X_attribute4
            ,X_attribute5               => X_attribute5
            ,X_attribute6               => X_attribute6
            ,X_attribute7               => X_attribute7
            ,X_attribute8               => X_attribute8
            ,X_attribute9               => X_attribute9
            ,X_attribute10              => X_attribute10
            ,x_pm_product_code          => x_pm_product_code
            ,x_err_code                 => l_error_number
            ,x_warnings_only_flag       => l_warnings_only_flag );

	--bug 3134205
	x_warnings_only_flag := l_warnings_only_flag;

    IF (l_error_number < 0) THEN
      FND_MSG_PUB.Add_Exc_Msg(
		p_pkg_name	  => 'PA_CLIENT_EXTN_PROJ_STATUS',
		p_procedure_name  => 'VERIFY_PROJECT_STATUS_CHANGE',
		p_error_text	  => 'ORA-'||LPAD(substr(X_err_stage,2),5,'0'));
      X_err_code := l_error_number;
      IF (l_error_code = 0) THEN
        x_err_code := -1;
        x_err_stage := to_char(l_error_number);
      END IF;
    END IF;

    -- Begin of Fix for error code > 0       ssanckar on 8th Jul 99

    IF (l_error_number > 0) THEN
      l_error_code := l_error_number;
    END IF;

    -- End of Fix for error code > 0       ssanckar on 8th Jul 99

    -- Set the return values if errors have occurred
    IF (l_error_code <> 0) THEN
      X_err_code := l_error_code;
      X_err_stage := l_error_msg;
    END IF;

ELSIF  X_Context = 'ARCHIVE_PURGE' then
  IF X_new_value IS NULL OR X_project_id IS NULL THEN
     x_err_code := 0;
     RETURN;
  END IF;

        pa_debug.debug('Calling validate process for costing for project '||to_char(X_project_id));
        x_err_stage := 'Calling validate process for billing for project '||to_char(X_project_id);
        pa_purge_validate_costing.validate_costing(p_project_id   => X_project_id,
                                                   p_txn_to_date  => pa_purge_validate.g_txn_to_date ,
                                                   p_active_flag  => pa_purge_validate.g_active_flag,
                                                   x_err_code     => x_err_code,
                                                   x_err_stack    => x_err_stack,
                                                   x_err_stage    => x_err_stage
                                                  );

        if pa_purge_validate.g_project_type_class_code = 'CONTRACT' then

           pa_debug.debug('Calling validate process for billing for project '||to_char(X_project_id));
           x_err_stage := 'Calling validate process for billing for project '||to_char(X_project_id);
           pa_purge_validate_billing.validate_billing(p_project_id  => X_project_id,
                                                      p_txn_to_date => pa_purge_validate.g_txn_to_date ,
                                                      p_active_flag => pa_purge_validate.g_active_flag,
                                                      x_err_code    => x_err_code,
                                                      x_err_stack   => x_err_stack,
                                                      x_err_stage   => x_err_stage
                                                  );
        end if;

        pa_debug.debug('Calling validate process for capital for project '||to_char(X_project_id));

        x_err_stage := 'Calling validate process for capital for project '||to_char(X_project_id);
        pa_purge_validate_capital.validate_capital( p_project_id  => X_project_id,
                                                    p_purge_to_date => pa_purge_validate.g_txn_to_date ,
                                                    p_active_flag => pa_purge_validate.g_active_flag,
                                                    p_err_code    => x_err_code,
                                                    p_err_stack   => x_err_stack,
                                                    p_err_stage   => x_err_stage
                                                  );

        pa_debug.debug('Calling validate process for PJRM for project '||to_char(X_project_id));

        x_err_stage := 'Calling validate process for PJRM for project '||to_char(X_project_id);

        pa_purge_validate_pjrm.validate_requirement (p_project_id  => X_project_id,
                                                     p_txn_to_date => pa_purge_validate.g_txn_to_date ,
                                                     p_active_flag => pa_purge_validate.g_active_flag,
                                                     x_err_code    => x_err_code,
                                                     x_err_stack   => x_err_stack,
                                                     x_err_stage   => x_err_stage
                                                  );

        pa_purge_validate_pjrm.validate_assignment (p_project_id  => X_project_id,
                                                    p_txn_to_date => pa_purge_validate.g_txn_to_date ,
                                                    p_active_flag => pa_purge_validate.g_active_flag,
                                                    x_err_code    => x_err_code,
                                                    x_err_stack   => x_err_stack,
                                                    x_err_stage   => x_err_stage
                                                  );

/* Bug#2416385 Code added for phase III of archive and Purge, starts here */

        pa_debug.debug('Calling validate process for IC and IP Billing for project '||to_char(X_project_id));
        x_err_stage := 'Calling validate process for IC and IP Billing for project '||to_char(X_project_id);
        pa_purge_validate_icip.validate_IC_IP(p_project_id  => X_project_id,
                                              p_txn_to_date => pa_purge_validate.g_txn_to_date ,
                                              p_active_flag => pa_purge_validate.g_active_flag,
                                              x_err_code    => x_err_code,
                                              x_err_stack   => x_err_stack,
                                              x_err_stage   => x_err_stage
                                             );

/* Bug#2416385 Code added for phase III of archive and Purge, ends here */

/* Code changes for Bug 2962582 starts here */
        pa_purge_validate_pjrm.Validate_PJI(p_project_id       => x_project_id,
                                            p_project_end_date => x_project_end_date,
                                            x_err_code         => x_err_code,
                                            x_err_stack        => x_err_stack,
                                            x_err_stage        => x_err_stage
                                           );

/* Code changes for Bug 2962582 ends here */


/* Code changes for Bug 4255353 starts here */
        pa_purge_validate_pjrm.Validate_Perf_reporting(p_project_id       => x_project_id,
                                            x_err_code         => x_err_code,
                                            x_err_stack        => x_err_stack,
                                            x_err_stage        => x_err_stage
                                           );

/* Code changes for Bug 4255353 ends here */

        -- Client extension for the user if he wants to put any extra validation.

        pa_debug.debug('Calling validate process for client extn for project '||to_char(X_project_id));

        x_err_stage := 'Calling validate process for client extn for project '||to_char(X_project_id);
        pa_purge_extn_validate.validate_extn( p_project_id  => X_project_id,
                                              p_txn_through_date => pa_purge_validate.g_txn_to_date ,
                                              p_active_flag => pa_purge_validate.g_active_flag,
                                              x_err_code    => x_err_code,
                                              x_err_stack   => x_err_stack,
                                              x_err_stage   => x_err_stage
                                            );

  END IF;  -- X_context =

  x_err_stack := old_stack;

EXCEPTION
  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error then
       RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
    /* If X_Context is ARCHIVE_PURGE then pa_debug is used for logging errors in
     * cocurrent request log */

    IF X_Context='ARCHIVE_PURGE' THEN
       pa_debug.debug('Procedure Name  := PA_PROJECT_UTILS2.VALIDATE_ATTRIBUTE_CHANGE');
       pa_debug.debug('Error stage is '||x_err_stage );
       pa_debug.debug('Error stack is '||x_err_stack );
       pa_debug.debug(SQLERRM);
       PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM ;

       RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;
    ELSE

     /* Other X_Context values ORGANIZATION_VALIDATION and PROJECT_STATUS_CHANGE
      * return to forms so nedd to use fnd calls to handle it. */

       x_err_code := -1;
       x_err_stage := to_char(SQLCODE);
       FND_MSG_PUB.Add_Exc_Msg(
		p_pkg_name	  => 'PA_PROJECT_UTILS2',
		p_procedure_name  => 'VALIDATE_ATTRIBUTE_CHANGE',
		p_error_text	  => 'ORA-'||LPAD(substr(X_err_stage,2),5,'0'));
   END IF;

END;

FUNCTION Get_project_business_group
     (p_project_id IN pa_projects_all.project_id%TYPE) RETURN NUMBER IS
-- This function returns the business group for a project
l_bg_id NUMBER := 0;
BEGIN
	SELECT impl.business_group_id
	INTO   l_bg_id
	FROM pa_implementations_all impl,
	     pa_projects_all	    pap
	WHERE pap.project_id = p_project_id
	AND   pap.org_id = impl.org_id; --MOAC Changes: Bug 4363092: removed nvl usage with org_id
        RETURN l_bg_id ;
EXCEPTION

  WHEN OTHERS THEN

       RAISE;
END get_project_business_group ;


PROCEDURE  Check_Project_Number_Or_Id
                  ( p_project_id          IN pa_projects_all.project_id%TYPE
                   ,p_project_number      IN pa_projects_all.segment1%TYPE
                   ,p_check_id_flag       IN VARCHAR2 := 'A'
                   ,x_project_id          OUT NOCOPY pa_projects_all.project_id%TYPE --File.Sql.39 bug 4440895
                   ,x_return_status       OUT NOCOPY VARCHAR2                                     --File.Sql.39 bug 4440895
                   ,x_error_message_code  OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895


               l_current_id NUMBER := NULL;
               l_num_ids NUMBER := 0;
               l_id_found_flag VARCHAR(1) := 'N';

               CURSOR c_ids IS
                  SELECT project_id
                  FROM pa_projects_all
                  WHERE segment1 = p_project_number;

            BEGIN

               IF (p_project_id IS NOT NULL) THEN
                  IF (p_check_id_flag = 'Y') THEN
                     -- Validate ID
                     SELECT project_id
                     INTO x_project_id
                     FROM pa_projects_all
                     WHERE project_id = p_project_id;
                  ELSIF (p_check_id_flag = 'N') THEN
                     -- No ID validation necessary
                     x_project_id := p_project_id;
                  ELSIF (p_check_id_flag = 'A') THEN
                     IF (p_project_number IS NULL) THEN
                        -- Return a null ID since the name is null.
                        x_project_id := NULL;
                     ELSE
                        -- Find the ID which matches the Name passed
                        OPEN c_ids;
                        LOOP
                           FETCH c_ids INTO l_current_id;
                           EXIT WHEN c_ids%NOTFOUND;
                           IF (l_current_id = p_project_id) THEN
                              l_id_found_flag := 'Y';
                              x_project_id := p_project_id;
                           END IF;
                        END LOOP;
                        l_num_ids := c_ids%ROWCOUNT;
                        CLOSE c_ids;

                        IF (l_num_ids = 0) THEN
                           -- No IDs for name
                           RAISE NO_DATA_FOUND;
                        ELSIF (l_num_ids = 1) THEN
                           -- Since there is only one ID for the name use it.
                           x_project_id := l_current_id;
                        ELSIF (l_id_found_flag = 'N') THEN
                           -- More than one ID for the name and none of the IDs matched
                           -- the ID passed in.
                           RAISE TOO_MANY_ROWS;
                        END IF;
                     END IF;
                  END IF;
               ELSE   -- Find ID since it was not passed.
                  IF (p_project_number IS NOT NULL) THEN
                     SELECT project_id
                     INTO x_project_id
                     FROM pa_projects_all
                     WHERE segment1 = p_project_number;
                  ELSE
                     x_project_id := NULL;
                  END IF;
               END IF;

               x_return_status:= FND_API.G_RET_STS_SUCCESS;

            EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                  x_project_id := NULL;
                      x_return_status := FND_API.G_RET_STS_ERROR;
                        x_error_message_code := 'PA_PROJECT_NUMBER_INVALID';
                    WHEN TOO_MANY_ROWS THEN
                  x_project_id := NULL;
                      x_return_status := FND_API.G_RET_STS_ERROR;
                        x_error_message_code := 'PA_PROJECT_NUMBER_INVALID';
              WHEN OTHERS THEN
                  x_project_id := NULL;
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                  FND_MSG_PUB.add_exc_msg(p_pkg_name        =>'PA_PROJECT_UTILS2',
                                          p_procedure_name  => 'Check_Project_Number_Or_Id');
                  RAISE;
            END Check_Project_Number_Or_Id;

-- Procedure            : AbortWorkflow
-- Type                 :
-- Purpose              : This API will is called when the Abort WorkFlow button is pressed on the project status
--                        change page
-- Note                 :
-- Parameters                    Type      Required  Description and Purpose
-- ---------------------------  ------     --------  --------------------------------------------------------
-- p_project_id                 NUMBER        Y      The project id
-- p_record_version_number      NUMBER        Y      The record version number
PROCEDURE AbortWorkflow( p_project_id            IN NUMBER,
              			p_record_version_number IN NUMBER,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count     OUT NOCOPY NUMBER,
                         x_msg_data      OUT NOCOPY VARCHAR2 ) IS
     CURSOR c_wf_type IS
     SELECT ps.workflow_item_type
       FROM pa_project_statuses ps,
            pa_projects_all ppa
      WHERE ppa.project_id  = p_project_id
        AND ppa.project_status_code = ps.project_status_code
        AND ps.enable_wf_flag = 'Y'
        AND ps.wf_success_status_code is NOT NULL
        AND ps.wf_failure_status_code is NOT NULL;

      CURSOR get_last_workflow_info(p_wf_item_type IN VARCHAR2) IS
      SELECT MAX(item_key)
        FROM pa_wf_processes
       WHERE item_type   = p_wf_item_type
         AND entity_key1 = p_project_id
         AND wf_type_code  = 'PROJECT';

      CURSOR get_prev_status(c_project_id IN VARCHAR2) IS
      SELECT a.old_project_status_code, a.new_project_status_code
      FROM  ( SELECT obj_status_change_id,
                     old_project_status_code,
                     new_project_status_code
              FROM   pa_obj_status_changes
              WHERE  object_type = 'PA_PROJECTS'
              AND    object_id = p_project_id
              ORDER BY obj_status_change_id DESC ) a
      WHERE ROWNUM = 1;

     Invalid_Arg_Exc          EXCEPTION;

     l_diagramUrl    VARCHAR2(2000);
     l_wf_item_type  pa_project_statuses.workflow_item_type%TYPE;
     l_wf_process    pa_project_statuses.workflow_process%TYPE;
     l_item_key      pa_wf_processes.item_key%TYPE;
     l_prev_status   pa_obj_status_changes.old_project_status_code%TYPE;
     l_curr_status   pa_obj_status_changes.new_project_status_code%TYPE;
     l_comment       pa_ci_comments.comment_text%TYPE;

     l_debug_mode         VARCHAR2(1);
	 l_calling_module     VARCHAR2(50) := 'SSO_ABORT';   -- for the BUG # 6661144

     l_debug_level2                   CONSTANT NUMBER := 2;
     l_debug_level3                   CONSTANT NUMBER := 3;
     l_debug_level4                   CONSTANT NUMBER := 4;
     l_debug_level5                   CONSTANT NUMBER := 5;
BEGIN
     x_msg_count     := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode    := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF l_debug_mode = 'Y' THEN
        PA_DEBUG.set_curr_function( p_function   => 'AbortWorkflow',
                                    p_debug_mode => l_debug_mode );
     END IF;

     IF l_debug_mode = 'Y' THEN
        Pa_Debug.g_err_stage:= 'Printing Input parameters';
        Pa_Debug.WRITE('PA_PROJECT_UTILS2',Pa_Debug.g_err_stage,
                                           l_debug_level3);

        Pa_Debug.WRITE('PA_PROJECT_UTILS2','p_project_id'||':'||p_project_id,
                                            l_debug_level3);
     END IF;

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'Validating Input parameters';
          Pa_Debug.WRITE('PA_PROJECT_UTILS2',Pa_Debug.g_err_stage,
                                             l_debug_level3);
     END IF;

     IF ( p_project_id       IS NULL OR p_project_id         = FND_API.G_MISS_NUM  )
     THEN
           IF l_debug_mode = 'Y' THEN
               Pa_Debug.g_err_stage:= 'PA_PROJECT_UTILS2 : AbortWorkflow : p_project_id IS NULL';
               Pa_Debug.WRITE('PA_PROJECT_UTILS2',Pa_Debug.g_err_stage,
                                                  l_debug_level3);
           END IF;
          RAISE Invalid_Arg_Exc;
     END IF;

     OPEN  c_wf_type;
     FETCH c_wf_type INTO l_wf_item_type;
     CLOSE c_wf_type;

     OPEN  get_last_workflow_info( l_wf_item_type );
     FETCH get_last_workflow_info INTO l_item_key;
     CLOSE get_last_workflow_info;

     OPEN  get_prev_status(p_project_id);
     FETCH get_prev_status INTO l_prev_status, l_curr_status;
     CLOSE get_prev_status;


     --Abort the workflow
     pa_control_items_workflow.cancel_workflow
        (l_wf_item_type,
         l_item_key,
         x_msg_count,
         x_msg_data,
         x_return_status);

     --Retrieve the comment to be put into the status change history
     fnd_message.set_name('PA', 'PA_CI_ABORT_WF_COMMENT');
     l_comment := fnd_message.get;

     --Change the project status back to the previous status
	  -- for the BUG # 6661144
     PA_PROJECTS_MAINT_PUB.project_status_change(
         p_project_id              =>    p_project_id
        ,p_new_status_code         =>    l_prev_status
        ,p_comment                 =>    l_comment
		,p_calling_module          =>    l_calling_module
        ,x_return_status           =>    x_return_status
        ,x_msg_count               =>    x_msg_count
        ,x_msg_data                =>    x_msg_data     );

EXCEPTION
  WHEN OTHERS THEN

     x_return_status := 'U';
     fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_UTILS2',
                             p_procedure_name => 'AbortWorkflow',
                             p_error_text     => SUBSTRB(SQLERRM,1,240));

     fnd_msg_pub.count_and_get(p_count => x_msg_count,
                               p_data  => x_msg_data);
END AbortWorkflow;


END PA_PROJECT_UTILS2 ;

/
