--------------------------------------------------------
--  DDL for Package Body PA_SECURITY_EXTN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_SECURITY_EXTN" AS
/* $Header: PAPSECXB.pls 120.5.12010000.2 2009/03/05 10:27:34 rthumma ship $ */

  PROCEDURE check_project_access ( X_project_id            IN NUMBER
                                 , X_person_id             IN NUMBER
                                 , X_cross_project_user    IN VARCHAR2
                                 , X_calling_module        IN VARCHAR2
                                 , X_event                 IN VARCHAR2
                                 , X_value                 OUT NOCOPY VARCHAR2
                                 , X_cross_project_view    IN VARCHAR2 := 'Y' )
  IS
    -- Declare local variables

    X_project_num 	VARCHAR2(25);
    X_tmp               CHAR;

  BEGIN

/*** Calling Modules *********************************************************

    The pa_security_extn will be invoked from the following modules.
    You can use the module name in this extension to control project access in
    a specific module. The calling module parameter X_calling_module has the
    following values.

    FORMS:

    Module Name      User Name      		Description
    ---------        -----------      		-----------
    PAXBUEBU         Budgets          		Enter Budgets
    PAXCARVW         Capital Projects   	Manage Capital project asset
 						capitalization
    PAXINEAG         Agreements         	Enter Agreements and Funding
    PAXINEVT         Events Maintenance 	Events Inquiry
    PAXINRVW         Invoices           	Review Invoices
    PAXINVPF         Project Funding    	Inquire on Project funding
		     Inquiry
    PAXPREPR         Projects 			Enter projects
    PAXRVRVW         Review Revenue     	Review Revenue
    PAXTRAPE         Expenditure Inquiry        Inquire, Adjust Expenditure
    PAXURDDC         Project Status Display     Define Project status display
		     Columns			columns
    PAXURVPS         Project Status Inquiry     Inquire on project status

    Open Integration Toolkit :

    OIT Budget creation and maintenance

    Module Name
    ------------
    PA_PM_CREATE_DRAFT_BUDGET
    PA_PM_ADD_BUDGET_LINE
    PA_PM_BASELINE_BUDGET
    PA_PM_DELETE_DRAFT_BUDGET
    PA_PM_DELETE_BUDGET_LINE
    PA_PM_UPDATE_BUDGET
    PA_PM_UPDATE_BUDGET_LINE

    OIT Project Maintenance

    Module Name
    ------------
    PA_PM_ADD_TASK
    PA_PM_UPDATE_PROJECT
    PA_PM_UPDATE_TASK
    PA_PM_DELETE_PROJECT

    OIT Maintain Progess Data

    Module Name
    ------------
    PA_PM_UPDATE_PROJ_PROGRESS
    PA_PM_UPDATE_EARNED_VALUE

*******************************************************************************/

/****************** Example Security Code Begins *******************************

--  To use the following example code, please uncomment the code.
--
--  The example allows only users assigned to the same organization as the
--  project organization to have access to the project.
--
--  If required, the security check can be only for specific modules.
--  You change the IF condition to include or remove the module names.



 IF X_calling_module = 'Module Name' THEN

    BEGIN
       IF (x_project_id IS NOT NULL) THEN       -- Added the condition for bug 2853458
	SELECT 'x'
	INTO   x_tmp
	FROM   pa_projects_all ppa , per_assignments_f paf
	WHERE  ppa.project_id = X_project_id
	AND    ppa.carrying_out_organization_id = paf.organization_id
	AND    paf.person_id = X_person_id
	AND    paf.assignment_type = 'E'
        AND    paf.primary_flag='Y' --Added for bug 291451
	AND    trunc(SYSDATE)
	       BETWEEN paf.effective_start_date AND paf.effective_end_date;
       END IF;
    EXCEPTION
	WHEN NO_DATA_FOUND THEN
	     X_value := 'N';
             RETURN;

    END;

    X_value := 'Y';
    RETURN;

END IF;
********* Example Code Ends Here ************************************************/


    IF x_calling_module IN ('PAXTRAPE_GL_DRILLDOWN','PAXRVRVW_GL_DRILLDOWN',
                        'GL_DRILLDOWN_PA_COST', 'GL_DRILLDOWN_PA_REVENUE')
    AND x_event IN  ('ALLOW_QUERY' , 'VIEW_LABOR_COSTS')
    THEN
          X_value := 'Y';
          RETURN;
    END IF;

    IF ( X_event = 'ALLOW_QUERY' ) THEN

      -- Default processing is to only grant ALLOW_QUERY access to cross
      -- project update users (done at beginning of procedure), cross project
      -- view users, project authorities for the encompassing organization, and
      -- active key members defined for the project.

      -- PA provides an API to determine whether or not a given person is a
      -- project authority on a specified project.  This function,
      -- CHECK_PROJECT_AUTHORITY is defined in the PA_SECURITY package.  It takes
      -- two input parameters, person_id and project_id, and returns as
      -- output:
      --   'Y' if the person is a project authority for the project,
      --   'N' if the person is not.

      -- Note, if NULL values are passed for either parameter, person or
      -- project, then the function returns NULL.

      -- PA provides an API to determine whether or not a given person is an
      -- active key member on a specified project.  This function,
      -- CHECK_KEY_MEMBER is defined in the PA_SECURITY package.  It takes
      -- two input parameters, person_id and project_id, and returns as
      -- output:
      --   'Y' if the person is an active key member for the project,
      --   'N' if the person is not.

      -- Note, if NULL values are passed for either parameter, person or
      -- project, then the function returns NULL.

      -- You can change the default processing by adding your own rules
      -- based on the project and user attributes passed into this procedure.

      IF X_cross_project_view = 'Y' THEN
        X_value := 'Y';
        RETURN;
      END IF;

/*Enhancement 6519194 changes begin here*/
/*      IF X_calling_module = 'PA_FORECASTING' THEN
        IF pa_security.check_key_member( X_person_id, X_project_id ) = 'Y' THEN
          X_value := 'Y';
          RETURN;
        END IF;

         X_value := pa_security.check_forecast_authority( X_person_id, X_project_id );
      ELSE
*/
        IF pa_security.check_key_member_no_dates( X_person_id, X_project_id ) = 'Y' THEN
          X_value := 'Y';
          RETURN;
        END IF;

        X_value := pa_security.check_project_authority( X_person_id, X_project_id );
/*      END IF;*/ --Enhancement 6519194 changes end here.

      RETURN;

    ELSIF ( X_event = 'ALLOW_UPDATE' ) THEN


      -- Default processing is to only grant ALLOW_QUERY access to cross
      -- project update users (done at beginning of procedure), project authorities
      -- for the encompassing organization, and active key members defined for the
      -- project.

      IF X_cross_project_user = 'Y' THEN
        X_value := 'Y';
        RETURN;
      END IF;

      IF pa_security.check_key_member( X_person_id, X_project_id ) = 'Y' THEN
        X_value := 'Y';
        RETURN;
      END IF;

      X_value := pa_security.check_project_authority( X_person_id, X_project_id );
      RETURN;

RETURN;

    ELSIF ( X_event = 'VIEW_LABOR_COSTS' ) THEN

      -- Default validation in PA to determine if a user has privileges to
      -- view labor cost amounts for expenditure item details is to ensure
      -- that the person is an active key member for the project, and that
      -- the user's project role type for that assignment is one that allows
      -- query access to labor cost amounts.

      -- PA provides an API to determine whether or not a given person
      -- has VIEW_LABOR_COSTS access for a given project based on the above
      -- criteria.  This function, CHECK_LABOR_COST_ACCESS is defined in
      -- the PA_SECURITY package.  It takes two input parameters, person_id
      -- and project_id, and returns as output:
      --    'Y' if the person has access to view labor costs
      --    'N' if the person does not.

      -- Note, if NULL values are passed for either parameter, person or
      -- project, then the function returns NULL.

      IF X_cross_project_user = 'Y' THEN
        X_value := 'Y';
        RETURN;
      END IF;

      X_value := pa_security.check_labor_cost_access( X_person_id
                                                    , X_project_id );
      RETURN;

    END IF;

  EXCEPTION
    WHEN OTHERS THEN
       X_Value := 'N';
       Raise;

  END check_project_access;



  /* Added for Bug 8306009 */

  FUNCTION custom_project_access ( X_mode           IN VARCHAR2
                                 , X_project_id     IN NUMBER
                                 , X_person_id      IN NUMBER) RETURN VARCHAR2
  IS
    -- Declare local variables

    x_tmp               VARCHAR2(1);

  BEGIN

   -- This function is called with X_mode = 'CHECK_IF_CUSTOMIZED' to check
   -- if the client extension is being used to customize accessibility to
   -- projects on the project search pages.
   -- If custom code written in this api is to be considered, the return value
   -- should be set to 'Y' in the block below. If the return value is set to 'N',
   -- the custom code is not considered.

    IF (X_mode = 'CHECK_IF_CUSTOMIZED') THEN
    RETURN 'N';
    END IF;


   -- This function is called with X_mode = 'CHECK_IF_ACCESSIBLE' to check
   -- if the particular project can be accessed on the project search pages.
   -- If the project should be accessible, the return value should be 'Y'
   -- in the block below. If the return value is 'N', the project cannot
   -- be accessed. If the default value 'D' is returned, the default security
   -- checks will be done to determine the project's accessibility.

    IF (X_mode = 'CHECK_IF_ACCESSIBLE') THEN

/****************** Example Security Code Begins *******************************

--  To use the following example code, please uncomment the code.
--
--  The example does not allow users assigned to an organization different from
--  the project organization to access the project on the project search
--  pages.

    BEGIN
       IF (X_project_id IS NOT NULL) THEN
        SELECT 'x'
        INTO   x_tmp
        FROM   pa_projects_all ppa , per_assignments_f paf
        WHERE  ppa.project_id = X_project_id
        AND    ppa.carrying_out_organization_id = paf.organization_id
        AND    paf.person_id = X_person_id
        AND    paf.assignment_type = 'E'
        AND    paf.primary_flag='Y'
        AND    trunc(SYSDATE)
               BETWEEN paf.effective_start_date AND paf.effective_end_date;
       END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
             RETURN 'N';
    END;

    RETURN 'D';

********* Example Code Ends Here ************************************************/

    RETURN 'D';

    END IF;

  END custom_project_access;

END pa_security_extn;

/
