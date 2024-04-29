--------------------------------------------------------
--  DDL for Package FEM_REFRESH_ENG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_REFRESH_ENG_PKG" AUTHID CURRENT_USER AS
--$Header: fem_refresh_eng.pls 120.0 2005/06/06 19:23:42 appldev noship $
/*==========================================================================+
 |    Copyright (c) 1997 Oracle Corporation, Redwood Shores, CA, USA        |
 |                         All rights reserved.                             |
 +==========================================================================+
 | FILENAME
 |
 |    fem_refresh_eng.pls
 |
 | NAME fem_refresh_eng_pkg
 |
 | DESCRIPTION
 |
 |   Package Spec for the FEM Refresh Engine
 |      The purpose of this package is to return an FEM database
 |      (which includes tables owned by other teams such as RCM, PFT, etc)
 |      to the original install state.
 |
 | FUNCTIONS/PROCEDURES
 |
 |  Main
 | errbuf                       OUT NOCOPY     VARCHAR2
 | retcode                      OUT NOCOPY     VARCHAR2
 | NOTES
 |
 |
 | HISTORY
 |
 |    02-MAY-05  RFlippo Created
+=========================================================================*/

---------------------------------------------
--  Package Constants
---------------------------------------------
   c_block  CONSTANT  VARCHAR2(80) := 'fem.plsql.fem_refresh_eng_pkg';
   c_fem    CONSTANT  VARCHAR2(3)  := 'FEM';
   c_user_id CONSTANT NUMBER := FND_GLOBAL.USER_ID;

   c_false        CONSTANT  VARCHAR2(1)      := FND_API.G_FALSE;
   c_true         CONSTANT  VARCHAR2(1)      := FND_API.G_TRUE;
   c_success      CONSTANT  VARCHAR2(1)      := FND_API.G_RET_STS_SUCCESS;
   c_error        CONSTANT  VARCHAR2(1)      := FND_API.G_RET_STS_ERROR;
   c_unexp        CONSTANT  VARCHAR2(1)      := FND_API.G_RET_STS_UNEXP_ERROR;
   c_api_version  CONSTANT  NUMBER           := 1.0;
   c_fetch_limit  CONSTANT  NUMBER           := 99999;

   c_FNDLOAD      CONSTANT  VARCHAR2(30)     := 'FEM_RFSH_FNDLOAD';
   c_test_lct     CONSTANT  VARCHAR2(100)    := '/patch/115/import/fem_dim.lct';
   c_test_ldt     CONSTANT  VARCHAR2(100)    := '/patch/115/import/US/fem_dim.ldt';

   c_proc_name CONSTANT VARCHAR2(30) := 'Main';
   c_object_id CONSTANT NUMBER := 1350;
   c_object_definition_id CONSTANT NUMBER := 1350;

   gv_request_id  NUMBER;
   gv_apps_user_id  CONSTANT NUMBER := FND_GLOBAL.User_Id;
   gv_login_id   CONSTANT NUMBER   := FND_GLOBAL.Login_Id;
   gv_pgm_id      CONSTANT NUMBER  := FND_GLOBAL.Conc_Program_Id;
   gv_pgm_app_id  CONSTANT NUMBER  := FND_GLOBAL.Prog_Appl_ID;


   gv_concurrent_status BOOLEAN;


---------Message Constants--------------
G_EXEC_LOCK_EXISTS CONSTANT VARCHAR2(30)       := 'FEM_PL_OBJ_EXECLOCK_EXISTS_ERR';
G_INVALID_OBJ_DEF CONSTANT VARCHAR2(30)        := 'FEM_DATAX_LDR_BAD_OBJ_ERR';
G_EXT_LDR_POST_PROC_ERR CONSTANT VARCHAR2(30)  := 'FEM_EXT_LDR_POST_PROC_ERR';
G_EXT_LDR_EXEC_STATUS   CONSTANT VARCHAR2(30)  := 'FEM_EXT_LDR_EXEC_STATUS';
G_PL_REG_REQUEST_ERR CONSTANT VARCHAR2(30)     := 'FEM_PL_REG_REQUEST_ERR';
G_PL_OBJ_EXEC_LOCK_ERR CONSTANT VARCHAR2(30)  := 'FEM_PL_OBJ_EXEC_LOCK_ERR';


---------------------------------------
------------------------
-- Declare Exceptions --
------------------------

---------------------------------------

---------------------------------------------
--  Package Types
---------------------------------------------



PROCEDURE Main (
   errbuf                       OUT NOCOPY     VARCHAR2
  ,retcode                      OUT NOCOPY     VARCHAR2
);



END FEM_REFRESH_ENG_PKG;


 

/
