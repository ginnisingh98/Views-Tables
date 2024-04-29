--------------------------------------------------------
--  DDL for Package XLA_ENVIRONMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_ENVIRONMENT_PKG" AUTHID CURRENT_USER AS
/* $Header: xlacmenv.pkh 120.3 2003/02/22 18:59:48 svjoshi ship $ */
/*======================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                |
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
|    08-Feb-01 P. Labrevois    Created                                  |
|                                                                       |
+======================================================================*/

/*======================================================================+
|                                                                       |
| Public Release informations                                           |
|                                                                       |
+======================================================================*/
g_release_name                 VARCHAR2(50);
g_mapps_flag                   BOOLEAN    := FALSE;

/*======================================================================+
|                                                                       |
| Public Port-specific informations                                     |
|                                                                       |
+======================================================================*/
g_chr_newline                  VARCHAR(9) := '
';

/*======================================================================+
|                                                                       |
| Public WHO informations                                               |
|                                                                       |
+======================================================================*/
g_Login_Id                     INTEGER;
g_Prog_Appl_Id                 INTEGER;
g_Resp_Appl_Id                 INTEGER;
g_Prog_Id                      INTEGER;
g_Req_Id                       INTEGER;
g_Usr_Id                       INTEGER;

/*======================================================================+
|                                                                       |
| Public Session informations                                           |
|                                                                       |
+======================================================================*/
g_program                      VARCHAR2(255);
g_module                       VARCHAR2(255);
g_process_id                   VARCHAR2(255);
g_session_id                   VARCHAR2(255); -- Char on the NT Platform
g_session_name                 VARCHAR2(255);


/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| refresh                                                               |
|                                                                       |
| Refresh the environment. It must be called once at the beginning of   |
| EVERY concurrent program to refresh the cache variables.              |
|                                                                       |
+======================================================================*/
PROCEDURE Refresh;


END xla_environment_pkg;
 

/
