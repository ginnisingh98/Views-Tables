--------------------------------------------------------
--  DDL for Package Body PA_SECURITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_SECURITY" AS
/* $Header: PAPLSECB.pls 120.1.12010000.3 2009/06/08 12:00:28 paljain ship $ */


   /* ----------------------------------------------------------------------
   ||
   ||  Function Name:  Initialize
   ||
   ||  Input Parameters:
   ||     X_user_id     <-- identifier of the application user
   ||	  X_calling_module  <-- hard-coded string that refers to the
   ||                           module that is calling pa_security
   ||				functions
   ||
   ||  Description:
   ||     This function is called to initialize package globals that are
   ||     referenced by the security functions.  Each form that uses
   ||     views that are secured MUST execute this procedure during form
   ||     startup, otherwise the logic in the security functions built into
   ||     secured views is not executed, and the views return all rows.
   ||
   ||     This built-in default (return unsecured data if package globals
   ||     are not enabled) enables system administrators using SQL*Plus to
   ||     query data to have access all data.
   ||
   ||     In order to secure data in external applications or custom
   ||     modules that are not part of core PA code, this procedure must
   ||     be called before querying secured views.
   ||
   || ---------------------------------------------------------------------
   */

  PROCEDURE Initialize ( X_user_id         IN NUMBER
                       , X_calling_module  IN VARCHAR2 )
  IS
  v_resp_id      NUMBER;
  v_resp_appl_id NUMBER;
  BEGIN

    IF ( X_user_id  IS NOT NULL ) THEN
      G_user_id := X_user_id;
      G_person_id := pa_utils.GetEmpIdFromUser( G_user_id );
    ELSE
      G_person_id := NULL;
    END IF;

    v_resp_id := fnd_global.resp_id;
    v_resp_appl_id := fnd_global.resp_appl_id;

    IF fnd_profile.value_specific('PA_SUPER_PROJECT',x_user_id, v_resp_id, v_resp_appl_id) = 'Y' THEN
      G_cross_project_user := 'Y';
    ELSE
      G_cross_project_user := 'N';
    END IF;

    IF fnd_profile.value_specific('PA_SUPER_PROJECT_VIEW',x_user_id, v_resp_id, v_resp_appl_id) = 'Y' THEN
      G_cross_project_view := 'Y';
    ELSE
      G_cross_project_view := 'N';
    END IF;

    G_module_name := X_calling_module;

    IF ( G_module_name = 'PAXTRAPE.CROSS-PROJECT' ) THEN
      G_query_allowed := 'Y';
      G_update_allowed := 'Y';
      G_view_labor_costs := 'Y';
    ELSE
      G_view_labor_costs := NULL;
      G_query_allowed := NULL;
      G_update_allowed := NULL;
    END IF;

  END Initialize;



   /* ----------------------------------------------------------------------
   ||
   ||  Function Name:  allow_query
   ||
   ||  Input Parameters:
   ||     X_project_id     <-- project identifier
   ||
   ||  Description:
   ||     This function determines whether a user has query access to a
   ||     particular project.
   ||
   ||     The function first checks if the package variable G_query_allowed
   ||     has been initiated with a value.  This global variable is set
   ||     during the Initialize procedure and is used to override normal
   ||     validation in the allow_query function (this enables users who
   ||     connect to the database in custom modules or in SQL*Plus to
   ||     access all data in secured views without enforcing project-based
   ||     security).
   ||
   ||     If the global variable is not set, then this function calls the
   ||     client extension API to determine whether or not the user has
   ||     query privileges for the given project.
   ||
   ||     The default validation that PA seeds in the client extension for
   ||     'ALLOW_QUERY' is to verify that the user has cross project view/update
   ||     access, or has the project authority role in the organizational domain
   ||     of this project, or is a key member of the project.
   ||
   ||     There are only two valid values returned from the extension
   ||     procedure:  'Y' or 'N'.  If the value returned is not one of
   ||     these values, then this function returns 'Y'.
   ||     -- changed the return value to 'N' for bug 2635016
   ||
   || ---------------------------------------------------------------------
   */

  FUNCTION allow_query ( X_project_id     IN NUMBER) RETURN VARCHAR2
  IS
    V_allow_query               VARCHAR2(1);
    V_allow_update              VARCHAR2(1); /* added for bug 2686117 */

  BEGIN

    /*
     * Bug# 918652
     */
    IF  ( G_module_name IS NULL ) THEN
      RETURN('Y');
    END IF;

/* Bug 2686117 Start */
    IF ( G_update_allowed = 'Y') THEN
      RETURN( G_update_allowed );
    END IF;

    pa_security_extn.check_project_access(
                          X_project_id
                        , G_person_id
                        , G_cross_project_user
                        , G_module_name
                        , 'ALLOW_UPDATE'
                        , V_allow_update );

    IF ( V_allow_update = 'Y') THEN
      RETURN( V_allow_update );
/* Bug 2686117 End */

    ELSE

        IF ( G_query_allowed IS NOT NULL ) THEN
          RETURN( G_query_allowed );
        END IF;

        pa_security_extn.check_project_access(
                              X_project_id
                            , G_person_id
                            , G_cross_project_user
                        , G_module_name
                        , 'ALLOW_QUERY'
                        , V_allow_query
                        , G_cross_project_view );

        IF ( V_allow_query IN ('Y', 'N') ) THEN
          RETURN( V_allow_query );
        ELSE
/* changed the return value from 'Y' to N for bug 2635016 */
          RETURN( 'N' );
        END IF;
    END IF;
  END allow_query;




   /* ----------------------------------------------------------------------
   ||
   ||  Function Name:  allow_update
   ||
   ||  Input Parameters:
   ||     X_project_id     <-- project identifier
   ||
   ||  Description:
   ||     This function determines whether a user has update privileges for
   ||     a particular project.
   ||
   ||     The structure is identical to the allow_query function. The default
   ||     validation that PA seeds in the client extension for 'ALLOW_QUERY' is
   ||     to verify that the user has cross project update access, or has the
   ||     project authority role in the organizational domain of this project,
   ||     or is a key member of the project.
   ||
   || ---------------------------------------------------------------------
   */

  FUNCTION allow_update ( X_project_id     IN NUMBER) RETURN VARCHAR2
  IS
    V_allow_update  		VARCHAR2(1);

  BEGIN

    /*
     * Bug# 918652
     */
    IF  ( G_module_name IS NULL ) THEN
      RETURN('Y');
    END IF;

    IF ( G_update_allowed IS NOT NULL ) THEN
      RETURN( G_update_allowed );
    END IF;

    pa_security_extn.check_project_access(
                          X_project_id
                        , G_person_id
                        , G_cross_project_user
                        , G_module_name
                        , 'ALLOW_UPDATE'
                        , V_allow_update );

    IF ( V_allow_update IN ('Y', 'N') ) THEN
      RETURN( V_allow_update );
    ELSE
/* changed the return value from 'Y' to 'N' for bug 2635016 */
      RETURN( 'N' );
    END IF;

  END allow_update;



   /* ----------------------------------------------------------------------
   ||
   ||  Function Name:  view_labor_costs
   ||
   ||  Input Parameters:
   ||     X_project_id     <-- project identifier
   ||
   ||  Description:
   ||     This function determines whether or not labor cost amounts are
   ||     displayed when the user queries detail project expenditure items.
   ||
   ||     The structure of the function is identical to the allow_query
   ||     function.  The default validation that PA seeds in the client
   ||     extension for 'VIEW_LABOR_COSTS' is to verify that the user
   ||     is a valid key member for the project and that his/her project
   ||     role type of this assignment is defined with Query Labor Cost
   ||     privilege.
   ||
   || ---------------------------------------------------------------------
   */

  FUNCTION view_labor_costs ( X_project_id      IN NUMBER) RETURN VARCHAR2
  IS
    V_view_labor_costs          VARCHAR2(1);

  BEGIN

    /*
     * Bug# 918652
     */
    IF  ( G_module_name IS NULL ) THEN
      RETURN('Y');
    END IF;

    IF ( G_view_labor_costs IS NOT NULL ) THEN
      RETURN( G_view_labor_costs );
    END IF;

    pa_security_extn.check_project_access(
                          X_project_id
                        , G_person_id
                        , G_cross_project_user
                        , G_module_name
                        , 'VIEW_LABOR_COSTS'
                        , V_view_labor_costs );

    IF ( V_view_labor_costs IN ('N', 'Y') ) THEN
      RETURN( V_view_labor_costs );
    ELSE
      RETURN( 'Y' );
    END IF;

  END view_labor_costs;

      /* ----------------------------------------------------------------------
 	    ||
 	    ||  Function Name:  view_labor_costs_new
 	    ||
 	    ||  Input Parameters:
 	    ||     X_project_id     <-- project identifier
 	    ||
 	    ||  Description:
 	    ||     This function determines whether or not labor cost amounts are
 	    ||     displayed when the user queries detail project expenditure items.
 	    ||     Caching logic is implemented for performance
 	    ||
 	    ||     The structure of the function is identical to the allow_query
 	    ||     function.  The default validation that PA seeds in the client
 	    ||     extension for 'VIEW_LABOR_COSTS' is to verify that the user
 	    ||     is a valid key member for the project and that his/her project
 	    ||     role type of this assignment is defined with Query Labor Cost
 	    ||     privilege.
 	    ||
 	    ||     15-01-2009 anuragar  Added this for caching purpose so that
 	    ||                          performance doesnt take a hit for bug7192736
 	    ||
 	    || ---------------------------------------------------------------------
 	    */

 	   FUNCTION view_labor_costs_new ( X_project_id      IN NUMBER) RETURN NUMBER
 	   IS
 	     V_view_labor_costs          VARCHAR2(1);

 	   BEGIN

 	   --For bug 7192736
 	   Initialize (fnd_global.user_id, 'RESOURCE_SUMMARY') ;

 	           G_proj_id := X_project_id;
 	           V_view_labor_costs := view_labor_costs(X_project_id);
 	           if(V_view_labor_costs = 'Y')
 	             then G_allow_result := 1;
 	           else
 	                  G_allow_result := NULL;
 	           end if;
 	                 return G_allow_result;

 	   END view_labor_costs_new;

            /* ----------------------------------------------------------------------
   	    ||
 	    ||  Function Name:  view_labor_costs_new2
 	    ||
 	    ||  Input Parameters:
 	    ||     X_project_id     <-- project identifier
 	    ||
 	    ||  Description:
 	    ||     This function determines whether or not labor cost amounts are
 	    ||     displayed when the user queries detail project expenditure items.
 	    ||     This is used from Task Summary Drilldown pages.
 	    ||
 	    ||     The structure of the function is identical to the allow_query
 	    ||     function.  The default validation that PA seeds in the client
 	    ||     extension for 'VIEW_LABOR_COSTS' is to verify that the user
 	    ||     is a valid key member for the project and that his/her project
 	    ||     role type of this assignment is defined with Query Labor Cost
 	    ||     privilege.
 	    ||
 	    ||     23-04-2009  paljain   Adding this function for Bug fix 8460451.
 	    ||                           Please check the bug for more details.
 	    || ---------------------------------------------------------------------
 	    */
 	 FUNCTION view_labor_costs_new2 ( X_project_id      IN NUMBER) RETURN VARCHAR2
 	   IS
 	     V_view_labor_costs          VARCHAR2(1);
 	     x_return_status         VARCHAR2(1);
 	   BEGIN
 	   Initialize (fnd_global.user_id, 'TASK_SUMMARY') ;

 	           G_proj_id := X_project_id;
 	           V_view_labor_costs := view_labor_costs(X_project_id);
 	           if(V_view_labor_costs = 'Y')
 	             then x_return_status := 'T';
 	           else
 	                  x_return_status := 'F';
 	           end if;
 	                 return x_return_status;

 	   END view_labor_costs_new2;

   /* ----------------------------------------------------------------------
   ||
   ||  Procedure Name:  set_value
   ||
   ||  Input Parameters:
   ||     X_security_level     <-- Hard-Coded value to specify which
   ||                              level of security to set global values
   ||     X_value              <-- The value to assign to the package
   ||                              global.  Once set, this package global
   ||                              is returned when the security function
   ||                              for that level is called instead of
   ||                              executing the function validation code.
   ||
   ||  Description:
   ||     This procedure is called to assign to a given value to the
   ||     security package global variable specified.  It is used in
   ||     forms that drilldown to details for a specific project so that
   ||     security validation is only executed once.
   ||
   ||     For example, labor cost security is implemented by embedding the
   ||     view_labor_costs function in the view definition that displays
   ||     expenditure item details for a project.  Since the function is
   ||     row dependent (ie, based on project and expenditure type), it is
   ||     executed for each record queried.  Since the Expenditure Inquiry
   ||     form (PROJECT mode) queries expenditure items for a
   ||     specific project, the logic in the view_labor_costs function
   ||     needs to be executed only once.  Therefore, the package global
   ||     variable for view labor cost security is initialized when
   ||     the project number/name specified in the form is validated.  When
   ||     expenditure items are queried, the security function returns
   ||     the global value instead of executing its validation logic.
   ||
   || ---------------------------------------------------------------------
   */

  PROCEDURE set_value ( X_security_level  IN VARCHAR2
                      , X_value           IN VARCHAR2 )
  IS
  BEGIN

    IF ( X_security_level = 'VIEW_LABOR_COSTS' ) THEN
      IF ( X_value IS NULL ) THEN
        G_view_labor_costs := NULL;
      ELSE
        G_view_labor_costs := X_value;
      END IF;
    ELSIF ( X_security_level = 'ALLOW_UPDATE' ) THEN
      IF ( X_value IS NULL ) THEN
        G_update_allowed := NULL;
      ELSE
        G_update_allowed := X_value;
      END IF;
    ELSIF ( X_security_level = 'ALLOW_QUERY' ) THEN
      IF ( X_value IS NULL ) THEN
        G_query_allowed := NULL;
      ELSE
        G_query_allowed := X_value;
      END IF;
    END IF;

  END set_value;



  /* ----------------------------------------------------------------------
   ||
   ||  Function Name:  check_key_member
   ||
   ||  Input Parameters:
   ||     X_person_id     <-- Identifier of the person
   ||     X_project_id    <-- Identifier of the project
   ||
   ||  Return value:
   ||     Y  <-- Indicates that the person specified is an active key
   ||            member for the project specified as of the current date
   ||     N  <-- The person is not an active key member for the project
   ||     NULL <-- Return value if either input parameter is not given
   ||
   || ---------------------------------------------------------------------
   */

  FUNCTION check_key_member ( X_person_id   IN NUMBER
                            , X_project_id  IN NUMBER ) RETURN VARCHAR2
  IS
    dummy    NUMBER;

  BEGIN
    IF ( X_person_id IS NULL OR X_project_id IS NULL ) THEN
      RETURN( NULL );
    END IF;

    BEGIN
           SELECT 1
             INTO dummy
             FROM pa_project_players
            WHERE project_id = X_project_id
              AND person_id = X_person_id
	AND TRUNC(sysdate) >= trunc(start_date_active)
	AND TRUNC(sysdate) <= trunc(NVL(end_date_active, sysdate+1));
       RETURN( 'Y' );

    EXCEPTION
      WHEN  NO_DATA_FOUND  THEN
        RETURN( 'N' );
     WHEN  TOO_MANY_ROWS   THEN
        RETURN ('Y');
     WHEN OTHERS THEN
        RETURN ('N');

    END;

  END check_key_member;



  /* ----------------------------------------------------------------------
   ||
   ||  Function Name:  check_labor_cost_access
   ||
   ||  Input Parameters:
   ||     X_person_id     <-- Identifier of the person
   ||     X_project_id    <-- Identifier of the project
   ||
   ||  Return value:
   ||     Y  <-- Indicates that the person specified is a key member
   ||            with a project role type that allows query of labor costs
   ||            for the specified project
   ||     N  <-- The person is not an active key member for the project or
   ||            is an active key member but with a project role type that
   ||            does not permit query of labor cost amounts
   ||     NULL <-- Return value if either input parameter is not given
   ||
   || ---------------------------------------------------------------------
   */

  FUNCTION check_labor_cost_access ( X_person_id  IN NUMBER
                                   , X_project_id  IN NUMBER )
       RETURN VARCHAR2
  IS
    dummy     NUMBER;
  BEGIN
    IF ( X_person_id IS NULL  OR  X_project_id IS NULL ) THEN
      RETURN( NULL );
    END IF;

    BEGIN
           SELECT 1
             INTO dummy
             --FROM pa_project_role_types rt --bug 4004821
             FROM pa_project_role_types_b rt
           ,      pa_project_players pp
	   ,      pa_role_controls rc    -- Added for bug 3058844
            WHERE rt.project_role_type = pp.project_role_type
	     /*  Below code added for  bug 3058844 */
	      AND rt.project_role_id = rc.project_role_id
	      AND rc.role_control_code = 'ALLOW_QUERY_LABOR_COST'
	     /* Code addition ends for bug 3058844 */
  	      AND TRUNC(sysdate) >= trunc(pp.start_date_active)
	      AND TRUNC(sysdate) <= trunc(NVL(pp.end_date_active, sysdate+1))
              AND pp.person_id = X_person_id
              AND pp.project_id = X_project_id;

      RETURN( 'Y' );

    EXCEPTION
      WHEN  NO_DATA_FOUND  THEN
        RETURN( 'N' );
     WHEN  TOO_MANY_ROWS   THEN
        RETURN ('Y');
     WHEN OTHERS THEN
        RETURN ('N');

    END;

  END check_labor_cost_access;


 /* ----------------------------------------------------------------------
   ||
   ||  Function Name:  check_project_authority
   ||
   ||  Input Parameters:
   ||     X_person_id     <-- Identifier of the person
   ||     X_project_id    <-- Identifier of the project
   ||
   ||  Return value:
   ||     Y  <-- Indicates that the person specified has the project authority
   ||            role that permits access to the specified project
   ||     N  <-- The person is not a project authority, or is a project authority
   ||            for an organization that does not encompass the specified project
   ||     NULL <-- Return value if either input parameter is not given
   ||
   || ---------------------------------------------------------------------
   */

FUNCTION check_project_authority ( X_person_id  IN NUMBER,
                                   X_project_id IN NUMBER ) RETURN VARCHAR2
  IS
    CURSOR c1 IS
       SELECT '1'
       FROM pa_projects_all ppa,
            pa_project_role_types_b ppr, -- Added for bug 3224170
            fnd_grants fg,
            fnd_objects fo
       WHERE
            --fg.grantee_key = 'PER:'||X_person_id and  /* commenting this line for 11.5.10 security changes */
            fg.grantee_key = PA_SECURITY_PVT.get_grantee_key( 'PERSON', X_person_id, 'N') and
/* replaced the above line with this call. The last paramater will assert that the function will not write to database. */
            fg.grantee_type = 'USER' and
												fg.menu_id = ppr.menu_id  and  -- Added for bug 3224170
												ppr.project_role_id = 3  and   -- Added for bug 3224170
            ppa.project_id = X_project_id and
            to_char(ppa.carrying_out_organization_id) = fg.instance_pk1_value and  -- bug 2777621
            fg.object_id = fo.object_id and
            fo.obj_name = 'ORGANIZATION' and
            fg.instance_type = 'INSTANCE' and
            TRUNC(sysdate) >= trunc(fg.start_date) and
  	    trunc(sysdate) <= trunc(NVL(fg.end_date, sysdate+1));

    v_dummy VARCHAR2(1);
  BEGIN
    IF( X_person_id IS NULL or X_project_id IS NULL ) THEN
       RETURN( NULL );
    END IF;

    open c1;
    fetch c1 into v_dummy;
    IF c1%notfound THEN
      close c1;
      RETURN( 'N' );
    ELSE
      close c1;
      RETURN( 'Y' );
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN( 'N' );
  END check_project_authority;

  /* ----------------------------------------------------------------------
   ||
   ||  Function Name:  check_key_member_no_dates
   ||
   ||  Input Parameters:
   ||     X_person_id     <-- Identifier of the person
   ||     X_project_id    <-- Identifier of the project
   ||
   ||  Return value:
   ||     Y  <-- Indicates that the person specified is a
   ||            member for the project.
   ||     N  <-- The person is not a member for the project.
   ||     NULL <-- Return value if either input parameter is not given
   ||
   || ---------------------------------------------------------------------
   */

  FUNCTION check_key_member_no_dates ( X_person_id   IN NUMBER
                            , X_project_id  IN NUMBER ) RETURN VARCHAR2
  IS
    dummy    NUMBER;

  BEGIN
    IF ( X_person_id IS NULL OR X_project_id IS NULL ) THEN
      RETURN( NULL );
    END IF;

    BEGIN
           SELECT 1
             INTO dummy
             FROM pa_project_players
            WHERE project_id = X_project_id
              AND person_id = X_person_id;

   RETURN( 'Y' );

    EXCEPTION
      WHEN  NO_DATA_FOUND  THEN
        RETURN( 'N' );
     WHEN  TOO_MANY_ROWS   THEN
        RETURN ('Y');
     WHEN OTHERS THEN
        RETURN ('N');
    END;

  END check_key_member_no_dates;

 /* ----------------------------------------------------------------------
   ||
   ||  Function Name:  check_forecast_authority
   ||
   ||  Input Parameters:
   ||     p_person_id     <-- Identifier of the person
   ||     p_project_id    <-- Identifier of the project
   ||
   ||  Return value:
   ||     Y  <-- Indicates that the person specified has the forecast authority
   ||            role that permits access to the specified project
   ||     N  <-- The person is not a forecast authority
   ||     NULL <-- Return value if either input parameter is not given
   ||
   || ---------------------------------------------------------------------
   */

/*Enhancement 6519194 - commenting out this function*/
/*FUNCTION check_forecast_authority ( X_person_id  IN NUMBER,
                                    X_project_id IN NUMBER ) RETURN VARCHAR2
  IS
    CURSOR c1 IS
       SELECT '1'
       FROM pa_projects_all ppa,
            fnd_grants fg,
            fnd_objects fo,
            fnd_menus fm
       WHERE */
            --fg.grantee_key = 'PER:'||X_person_id and  /* commenting this line for 11.5.10 security changes */
 /*           fg.grantee_key = PA_SECURITY_PVT.get_grantee_key( 'PERSON', X_person_id, 'N') and*/
/* replaced the above line with this call. The last paramater will assert that the function will not write to database. */
/*            fg.grantee_type = 'USER' and
            ppa.project_id = X_project_id and
            to_char(ppa.carrying_out_organization_id) = fg.instance_pk1_value and  -- bug2777621
            fg.object_id = fo.object_id and
            fm.menu_name  = 'PA_PRM_FCST_AUTH'  and
            fg.menu_id = fm.menu_id and
            fo.obj_name = 'ORGANIZATION' and
            fg.instance_type = 'INSTANCE' and
            TRUNC(sysdate) >= trunc(fg.start_date) and
            trunc(sysdate) <= trunc(NVL(fg.end_date, sysdate+1));

    v_dummy VARCHAR2(1);
  BEGIN

    IF( X_person_id IS NULL or X_project_id IS NULL ) THEN
       RETURN( NULL );
    END IF;

    open c1;
    fetch c1 into v_dummy;
    IF c1%notfound THEN
      close c1;
      RETURN( 'N' );
    ELSE
      close c1;
      RETURN( 'Y' );
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN( 'N' );

END check_forecast_authority;
*/
END pa_security;

/
