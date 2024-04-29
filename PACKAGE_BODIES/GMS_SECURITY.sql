--------------------------------------------------------
--  DDL for Package Body GMS_SECURITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_SECURITY" AS
/* $Header: gmsseseb.pls 115.2 2002/07/04 11:22:32 gnema ship $ */


   /* ----------------------------------------------------------------------
   ||
   ||  Function Name:  Initialize
   ||
   ||  Input Parameters:
   ||     X_user_id     <-- identifier of the application user
   ||	  X_calling_module  <-- hard-coded string that refers to the
   ||                           module that is calling gms_security
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
  BEGIN

    IF ( X_user_id  IS NOT NULL ) THEN
      G_user_id := X_user_id;
      G_person_id := pa_utils.GetEmpIdFromUser( G_user_id );
    ELSE
      G_person_id := NULL;
    END IF;
      G_module_name := X_calling_module;
      G_query_allowed := NULL;
      G_update_allowed := NULL;

  END Initialize;



   /* ----------------------------------------------------------------------
   ||
   ||  Function Name:  allow_query
   ||
   ||  Input Parameters:
   ||     X_award_id     <-- award   identifier
   ||
   ||  Description:
   ||     This function determines whether a user has query access to a
   ||     particular award.
   ||
   ||     The function first checks if the package variable G_query_allowed
   ||     has been initiated with a value.  This global variable is set
   ||     during the Initialize procedure and is used to override normal
   ||     validation in the allow_query function (this enables users who
   ||     connect to the database in custom modules or in SQL*Plus to
   ||     access all data in secured views without enforcing award-based
   ||     security).
   ||
   ||     If the global variable is not set, then this function calls the
   ||     client extension API to determine whether or not the user has
   ||     query privileges for the given project.
   ||
   ||     The default validation that GMS seeds in the client extension for
   ||     'ALLOW_QUERY' is to verify that the user is an active key member
   ||     for the award or is using a Cross-award responsibility.
   ||
   ||     There are only two valid values returned from the extension
   ||     procedure:  'Y' or 'N'.  If the value returned is not one of
   ||     these values, then this function returns 'Y'.
   ||
   || ---------------------------------------------------------------------
   */

  FUNCTION allow_query ( X_award_id     IN NUMBER) RETURN VARCHAR2
  IS
    V_allow_query               VARCHAR2(1);

  BEGIN

    IF ( G_query_allowed IS NOT NULL ) THEN
      RETURN( G_query_allowed );
    END IF;

    gms_security_extn.check_award_access(
                          X_award_id
                        , G_person_id
                        , G_module_name
                        , 'ALLOW_QUERY'
                        , V_allow_query );

    IF ( V_allow_query IN ('Y', 'N') ) THEN
      RETURN( V_allow_query );
    ELSE
      RETURN( 'Y' );
    END IF;

  END allow_query;




   /* ----------------------------------------------------------------------
   ||
   ||  Function Name:  allow_update
   ||
   ||  Input Parameters:
   ||     X_award_id     <-- award  identifier
   ||
   ||  Description:
   ||     This function determines whether a user has update privileges for
   ||     a particular award.
   ||
   ||     The structure is identical to the allow_query function.  In
   ||     the client extension, however, there is NO seeded validation
   ||     for 'ALLOW_UPDATE'.  GMS assumes that if a person has query access
   ||     for the award (ie, is an active key member), he/she may also
   ||     update information on the award.
   ||
   || ---------------------------------------------------------------------
   */

  FUNCTION allow_update ( X_award_id     IN NUMBER) RETURN VARCHAR2
  IS
    V_allow_update  		VARCHAR2(1);

  BEGIN

    IF ( G_update_allowed IS NOT NULL ) THEN
      RETURN( G_update_allowed );
    END IF;

    gms_security_extn.check_award_access(
                          X_award_id
                        , G_person_id
                        , G_module_name
                        , 'ALLOW_UPDATE'
                        , V_allow_update );

-- insert into ttt values(X_award_id,G_person_id,G_module_name,V_allow_update);
-- commit;
    IF ( V_allow_update IN ('Y', 'N') ) THEN
      RETURN( V_allow_update );
    ELSE
      RETURN( 'Y' );
    END IF;

  END allow_update;

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
   ||     forms that drilldown to details for a specific award so that
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

    IF ( X_security_level = 'ALLOW_UPDATE' ) THEN
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
   ||     X_award_id    <-- Identifier of the award
   ||
   ||  Return value:
   ||     Y  <-- Indicates that the person specified is an active key
   ||            member for the award specified as of the current date
   ||     N  <-- The person is not an active key member for the award
   ||     NULL <-- Return value if either input parameter is not given
   ||
   || ---------------------------------------------------------------------
   */

  FUNCTION check_key_member ( X_person_id   IN NUMBER
                            , X_award_id  IN NUMBER ) RETURN VARCHAR2
  IS
    dummy    NUMBER;

  BEGIN
    IF ( X_person_id IS NULL OR X_award_id IS NULL ) THEN
      RETURN( NULL );
    END IF;

    BEGIN
      SELECT 1
        INTO dummy
        FROM dual
       WHERE EXISTS (
           SELECT NULL
             FROM gms_personnel
            WHERE award_id = X_award_id
              AND person_id = X_person_id
              AND TRUNC(sysdate) BETWEEN start_date_active
                                     AND NVL(end_date_active, sysdate) );
      RETURN( 'Y' );

    EXCEPTION
      WHEN  NO_DATA_FOUND  THEN
        RETURN( 'N' );

    END;

  END check_key_member;



END gms_security;

/
