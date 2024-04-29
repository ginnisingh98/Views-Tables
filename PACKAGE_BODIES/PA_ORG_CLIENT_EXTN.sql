--------------------------------------------------------
--  DDL for Package Body PA_ORG_CLIENT_EXTN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ORG_CLIENT_EXTN" AS
-- $Header: PAXORCEB.pls 120.1 2005/08/19 17:15:30 mwasowic noship $

  PROCEDURE  verify_org_change(X_insert_update_mode     IN VARCHAR2
            ,  X_calling_module         IN VARCHAR2
            ,  X_project_id             IN NUMBER
            ,  X_task_id                IN NUMBER
            ,  X_old_organization_id    IN NUMBER
            ,  X_new_organization_id    IN NUMBER
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
            ,  X_outcome                OUT NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
  IS

 -- ====================================================================
 --  Default logic of client extension is as follows
 -- ====================================================================
 -- The default client extension does not do any validation for organization change.
 -- User needs to add code or uncomment the commented code to perform the validations.
 -- The validations inside the client extension will not be performed if your
 -- responsibility has the Function 'Projects:Org:Update:Override Standard Checks'
 -- assigned through Functional Security.

    -- Define local variables

    X_cdl_check             NUMBER;
    X_dil_check             NUMBER;
    X_rdl_check             NUMBER;

  BEGIN

    -- Initialize the X_outcome parameter to NULL.  If all the checks
    -- go through then the X_outcome parameter is returned as NULL .
    -- If a check  fails validation, the value of the
    -- X_outcome variable should be set to an error  code .

    X_outcome := NULL;

    -- If the user responsibility has the access to
    -- Function 'Projects:Org:Update:Override Standard Checks'
    -- org without performing any checks.

    if X_functional_security_flag = 'Y' then
      null;
    else
      null; /* Added for bug 2981386 */

	/* USER SHOULD ADD CODE HERE OR UNCOMMENT THE BELOW CODE
	   TO CUSTOMIZE THE CLIENT EXTENSION */

	/* Commented for bug 2981386
      --
      -- Check If CDLs exist for the project or the task.
      --
       X_cdl_check := 0;
      --
      if X_task_id is null then  -- Project Org change check
	select count(*)
	into X_cdl_check
	from sys.dual
	where exists (select  null
		from    pa_expenditure_items_ALL pai,
			pa_tasks t, pa_cost_distribution_lines_ALL pcd
		where   pai.task_id = t.task_id
		and pai.expenditure_item_id = pcd.expenditure_item_id
		and     t.project_id =X_project_id);
      --
      else -- Task Org Change check
	select count(*)
	into X_cdl_check
	from sys.dual
	where exists (select  null
		      from    pa_expenditure_items_all pai,
		      pa_cost_distribution_lines_aLL pcd
		      where   pai.expenditure_item_id
		       = pcd.expenditure_item_id
		      and pai.task_id = X_task_id);
      end if;

      if X_cdl_check <> 0 then
        x_outcome := 'PA_PR_CANT_CHG_PROJ_ORG';
        return;
      end if;

      --
      -- Check if any Revenue has been generated
      --
      X_rdl_check := 0;
       --
      if X_task_id is null then  -- Project Org change check
	select count(*)
	into X_rdl_check
	from sys.dual
	where exists (select  null
		      FROM     pa_draft_revenue_items
		      where    project_id = x_project_id);
      --
      else -- Task Org Change check
	select count(*)
	into X_rdl_check
	from    sys.dual
	where exists (select null
		      from   pa_draft_revenue_items
		      where  project_id = x_project_id
		      and  task_id in
			 (select task_id
			  from   pa_tasks
			  connect by prior task_id = parent_task_id
			  start with task_id = x_task_id));
      end if;

      if X_rdl_check <> 0 then
        x_outcome := 'PA_PR_CANT_CHG_PROJ_ORG';
        return;
      end if;

      --
      -- Check if any Draft Invoice Items exist
      --
     X_dil_check := 0;
     --
     if X_task_id is null then  -- Project Org change check
       select count(*)
       into X_dil_check
       from sys.dual
       where   exists (select null
		       from pa_draft_invoice_items
		       where  project_id = x_project_id);
     --
     else -- Task Org Change check
       select count(*)
       into X_dil_check
       from sys.dual
       where exists (select null
		     from   pa_draft_invoice_items
		     where  project_id = x_project_id
		     and  task_id in
			    (select task_iD
			     from   pa_tasks
			     connect by prior task_id = parent_task_id
			     start with task_id = X_task_id));
      end if;

      if X_dil_check <> 0 then
	x_outcome := 'PA_PR_CANT_CHG_PROJ_ORG';
	return;
      end if;
      --
    */
    end if;

  EXCEPTION
    WHEN  OTHERS  THEN
      -- Add your exception handling logic here
      NULL;
	/* x_outcome := sqlcode;   commented for bug 2981386 */
	x_outcome := 'PA_AL_CE_FAILED'; /* Added for bug 2981386 */

  END;

  END PA_ORG_CLIENT_EXTN ;

/
