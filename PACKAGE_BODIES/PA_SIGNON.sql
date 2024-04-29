--------------------------------------------------------
--  DDL for Package Body PA_SIGNON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_SIGNON" as
/* $Header: PASIGNOB.pls 120.5.12010000.3 2009/06/24 19:16:54 cklee ship $ */

PROCEDURE INIT
IS
  program_name             VARCHAR2(2000); /*bug 7277303*/
  l_module                     v$session.MODULE%TYPE;
  l_session_id             NUMBER;
  l_pji_installed          VARCHAR2(1);

  -- 5652711 Added below local variables
  l_application_short_name VARCHAR2(80);
  l_init_function_name     VARCHAR2(240);

BEGIN

  -- 5652711 Commented below code , refer bug for more detail

  /*
  SELECT USERENV('SESSIONID')
  INTO l_session_id
  FROM dual;

  --------------------------------------------------------------------------------
  --Session ID will be 0 if we schedule to run the workbooks
  --When the package is run from the DBMS_JOBS queue the userenv('SESSIONID') is
  --set to 0
  --------------------------------------------------------------------------------
  IF l_session_id = 0 THEN

     BEGIN
        SELECT audsid INTO l_session_id
        FROM   v$session
        WHERE  audsid = 0
        AND  MODULE = 'Discoverer4';
     EXCEPTION
       WHEN NO_DATA_FOUND THEN  -- not Discoverer 4i
         RETURN;
     END;

  ELSE

    --------------------------------------------------------
    -- Find program name for the current session
    -- Note, we only grab the text starting from the last '\'
    ---------------------------------------------------------
    SELECT  NVL(LOWER(SUBSTR(program,INSTRB(program,'\',-1,1)+1)), 'xxx')
               ,MODULE
    INTO    program_name
               ,l_module
    FROM   v$session
    WHERE  audsid = USERENV('SESSIONID');

    -----------------------------------------------------------------------
    -- Check if called from Discoverer session, if not, just exit
    -- Assumptions: 1 The icon name and/or executable
    --                name for Discoverer User Edition startes with
    --                the characters "dis" (not case sensitive)
    --              2 The total path of the icon does not exceed 48 char
    --
    -- Notes: 1 When running Disco from Win95, the PROGRAM field
    --          in V$SESSION is populated with executable name without path.
    --          In NT, path is included.  See bug 1472179
    --        2 Is not a complete solution as string matching is not
    --          100% reliable. Long term, requesting Disco 4i to
    --          populate the module field so we can definitively identify
    --          a Disco session.  Complete solution in 4i.

    -- IF program name is like '%dis%' OR
    -- module name is 'Discoverer4'    THEN
    -- we need to build the  temp table
    -- Otherwise, just exit.
    -------------------------------------------------------------------------
    IF  ( INSTRB(program_name,'dis',-1,1) =  0 )                AND
        ( NVL(l_module,'XXX')             <> 'Discoverer4' )    THEN

        RETURN;
    END IF;

    -- Check if the program name is like '%f60run%'. If so, it is forms
    -- runtime.  Just exit.
    IF (INSTRB(program_name,'f60run',1,1) > 0) THEN
        RETURN;
    END IF;

    -- Check if the program name is like '%rwrun60%'. If so, it is reports
    -- runtime.  Just exit.
    IF (INSTRB(program_name,'rwrun60',1,1) > 0) THEN
        RETURN;
    END IF;

    -- Check if the program name is like '%standard@%'. If so, it is standard
    -- manager within concurrent manager.  Just exit.
    IF (INSTRB(program_name,'standard@',1,1) > 0) THEN
        RETURN;
    END IF;

  END IF;--end IF l_session_id = 0
  */

  -- Added below code to do MO Initialization

  l_application_short_name := fnd_global.APPLICATION_SHORT_NAME;

  SELECT UPPER(init_function_name) INTO l_init_function_name
  FROM   fnd_product_initialization
  WHERE  application_short_name = UPPER(l_application_short_name);

  IF ('PA_SIGNON.INIT' = l_init_function_name) THEN
     mo_global.init(l_application_short_name);
  END IF;

  -- 5652711 end

  ----------------------------------------------
  --Populating secured list of projects and
  --project organizations
  --There are 2 temporary tables that are
  --populated based on the following logic
  --  - Projects for which logged in user is a
  --    project manager
  --  - Organizations on which one has project
  --    authority
  --  - Security 11.5.10 uptake for logged in user
  -----------------------------------------------
  BEGIN
      --Inserting secured Organizations
      INSERT INTO pa_rep_sec_porgz_tmp
      (
        ORGANIZATION_ID
      )
      SELECT INSTANCE_PK1_VALUE
      FROM   fnd_grants fg,
             fnd_objects fob,
             (SELECT nvl(pa_security_pvt.get_menu_id('PA_PRM_PROJ_AUTH'),-1)    menu_id
                    ,nvl(PA_SECURITY_PVT.GET_GRANTEE_KEY, -1)                   grantee_key
              FROM dual) prj_auth_menu
      WHERE fg.INSTANCE_TYPE = 'INSTANCE'
      AND   fg.GRANTEE_TYPE  = 'USER'
      AND   fg.OBJECT_ID     = fob.OBJECT_ID
      AND   fob.OBJ_NAME     = 'ORGANIZATION'
      AND   fg.MENU_ID       = prj_auth_menu.MENU_ID
      AND   fg.GRANTEE_KEY   = prj_auth_menu.GRANTEE_KEY -- in replacement of the following string of code
--       AND   fg.GRANTEE_KEY   = 'PER:' || fu.EMPLOYEE_ID
      AND   trunc(SYSDATE) BETWEEN trunc(fg.START_DATE)
                           AND     trunc(NVL(fg.END_DATE, SYSDATE+1));

      INSERT INTO pa_rep_sec_proj_tmp
      (
        PROJECT_ID
      )
      SELECT ppp.PROJECT_ID
      FROM   pa_project_parties ppp,
             fnd_user fu
           --  fnd_grants fg /*bug#4904076 Perf bug*/
      WHERE  fu.USER_ID          = fnd_global.user_id AND
             fu.EMPLOYEE_ID      = ppp.RESOURCE_SOURCE_ID AND
--start rem |  24-JUN-2009  cklee    fxied bug:6708625                                |
         object_type = 'PA_PROJECTS'  --(since this is reading project records)
         and resource_type_id = 101   --(since this join is grabbing project
--end rem |  24-JUN-2009  cklee    fxied bug:6708625                                |
         and ppp.PROJECT_ROLE_ID = 1;
  EXCEPTION
      WHEN OTHERS THEN
        null;
  END;

  -----------------------------------------------
  --If PJI is installed then populate security
  --tables for OU and Organizations
  --Also, we assume that the signon occured
  --from Discoverer login if code reaches this
  --point
  -----------------------------------------------
  IF PA_INSTALL.Is_PJI_Installed = 'Y' THEN

      --dynamic calls to pji api's
      execute immediate 'begin PJI_PMV_ENGINE.Convert_Organization; end;';
      execute immediate 'begin PJI_PMV_ENGINE.Convert_Operating_Unit(p_view_by => ''OU''); end;';

  END IF;

END INIT;

end PA_SIGNON;

/
