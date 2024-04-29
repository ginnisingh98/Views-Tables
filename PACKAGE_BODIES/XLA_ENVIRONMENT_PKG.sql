--------------------------------------------------------
--  DDL for Package Body XLA_ENVIRONMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_ENVIRONMENT_PKG" AS
/* $Header: xlacmenv.pkb 120.5 2005/05/27 07:02:57 ksvenkat ship $ */
/*======================================================================+
|             Copyright (c) 2000-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_environment_pkg                                                |
|                                                                       |
| DESCRIPTION                                                           |
|    XLA Environment Package                                            |
|                                                                       |
| HISTORY                                                               |
|    10-Feb-01 P. Labrevois    Created                                  |
+======================================================================*/

g_init_flag                    BOOLEAN := FALSE;


/*======================================================================+
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
| Misc privates procedure or functions                                  |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
+======================================================================*/

/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
| set_login_info                                                        |
|                                                                       |
| Set login global variables                                            |
|                                                                       |
+======================================================================*/
PROCEDURE set_login_info

IS

BEGIN
xla_utility_pkg.trace('> Package xla_environment_pkg .get_login_info'         , 20);

g_Login_Id     := fnd_global.login_id;
g_Prog_Appl_Id := fnd_global.prog_appl_id;
g_Prog_Id      := fnd_global.conc_program_id;
g_Req_Id       := fnd_global.conc_request_id;
g_Usr_Id       := fnd_global.user_id;

xla_utility_pkg.trace('Login id                   = '||TO_CHAR(g_Login_Id)    , 30);
xla_utility_pkg.trace('Prog Appl id               = '||TO_CHAR(g_Prog_Appl_Id), 30);
xla_utility_pkg.trace('Prog id                    = '||TO_CHAR(g_Prog_Id)     , 30);
xla_utility_pkg.trace('Request id                 = '||TO_CHAR(g_Req_Id)      , 30);
xla_utility_pkg.trace('User id                    = '||TO_CHAR(g_Usr_Id)      , 30);

xla_utility_pkg.trace('< Package xla_environment_pkg .login_info'            , 20);

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
     (p_location   => 'xla_environment_pkg .get_login_info');
END set_login_info;


/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
| set_release_info                                                      |
|                                                                       |
| Populate the global variable g_release_name with the current release. |
|                                                                       |
+======================================================================*/
PROCEDURE set_release_info

IS

BEGIN
xla_utility_pkg.trace('> Package xla_environment_pkg .set_release_info'       , 20);

SELECT SUBSTR(release_name,1,4)
INTO   g_release_name
FROM   fnd_product_groups
;

xla_utility_pkg.trace('Release                    = '||g_release_name    , 30);

xla_utility_pkg.trace('> Package xla_environment_pkg .set_release_info'       , 20);

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
     (p_location   => 'xla_environment_pkg .set_release_info');
END set_release_info;


/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
| set_mapps_info                                                        |
|                                                                       |
| Populate the global variable g_mapps_info.                            |
|                                                                       |
+======================================================================*/
PROCEDURE set_mapps_info

IS

l_count                        INTEGER;

BEGIN
xla_utility_pkg.trace('> Package xla_environment_pkg .get_mapps_info'        , 10);

SELECT COUNT(*)
INTO   l_count
FROM   fnd_data_groups
WHERE  data_group_name NOT LIKE 'Multiple Reporting Currencies%'
;

xla_utility_pkg.trace('Data groups                = '||TO_CHAR(l_count) , 20);

IF l_count >1 THEN
   g_mapps_flag := TRUE;
ELSE
   g_mapps_flag := FALSE;
END IF;

xla_utility_pkg.trace('< Package xla_environment_pkg .get_mapps_info'        , 10);

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
     (p_location   => 'xla_environment_pkg .get_login_info');
END set_mapps_info;


/*======================================================================+
|                                                                       |
| Private Function                                                      |
|                                                                       |
| set_unique_session_info                                               |
|                                                                       |
| Set the pipe name.                                                    |
|                                                                       |
+======================================================================*/
PROCEDURE set_session_info

IS

BEGIN
xla_utility_pkg.trace('> Package xla_environment_pkg .set_session_info'      , 10);

SELECT pr.spid
      ,se.sid
      ,se.program
      ,se.module
INTO   g_process_id
      ,g_session_id
      ,g_program
      ,g_module
FROM   v$session         se
      ,v$process         pr
WHERE  se.sid = (select sid from v$mystat where rownum = 1)
  AND  se.paddr          = pr.addr;

g_session_name        := dbms_pipe.unique_session_name;

xla_utility_pkg.trace('< Package xla_environment_pkg .set_session_info'      , 10);

EXCEPTION

WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
     (p_location   => 'xla_environment_pkg .set_session_info');
END set_session_info;



/*======================================================================+
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
| Refresh                                                               |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
+======================================================================*/


/*======================================================================+
|                                                                       |
| Public Procedure                                                     |
|                                                                       |
| refresh                                                               |
|                                                                       |
| Refresh the environment. It must be called once at the beginning of   |
| EVERY concurrent program to refresh the cache variables.              |
|                                                                       |
+======================================================================*/
PROCEDURE Refresh

IS

BEGIN
xla_utility_pkg.trace('> Package xla_environment_pkg .Refresh'                 , 20);

IF NOT g_Init_flag THEN
   set_login_info;
   set_release_info;
   set_mapps_info;
   set_session_info;
ELSE
   set_login_info;
END IF;

g_Init_flag := TRUE;

xla_utility_pkg.trace('< Package xla_environment_pkg .Refresh'                 , 20);

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
     (p_location   => 'xla_environment_pkg .get_login_info');
END Refresh;


/*======================================================================+
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
| Initialization                                                        |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
+======================================================================*/

BEGIN
refresh;

END xla_environment_pkg;

/
