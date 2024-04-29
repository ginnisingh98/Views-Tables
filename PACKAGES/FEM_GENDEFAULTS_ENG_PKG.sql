--------------------------------------------------------
--  DDL for Package FEM_GENDEFAULTS_ENG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_GENDEFAULTS_ENG_PKG" AUTHID CURRENT_USER AS
--$Header: fem_gendflt_eng.pls 120.0 2006/07/11 18:01:02 rflippo ship $
/*==========================================================================+
 |    Copyright (c) 1997 Oracle Corporation, Redwood Shores, CA, USA        |
 |                         All rights reserved.                             |
 +==========================================================================+
 | FILENAME
 |
 |    fem_gendflt_eng.pls
 |
 | NAME fem_gendefaults_eng_pkg
 |
 | DESCRIPTION
 |
 |   Package Spec for the FEM Generate Defaults Engine
 |      The purpose of this package is to create rapid prototype data for EPF.
 |      The engine creates the following:
 |        1)  A starter Cal Period member and Cal Period hierarchy
 |        2)  A starter Ledger
 |        3)  A "Default" member for every empty dimension in the database
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
 |    07-JUL-06  RFlippo Created
+=========================================================================*/

---------------------------------------------
--  Package Constants
---------------------------------------------
   c_block  CONSTANT  VARCHAR2(80) := 'fem.plsql.fem_gendefaults_eng_pkg';
   c_fem    CONSTANT  VARCHAR2(3)  := 'FEM';
   c_user_id CONSTANT NUMBER := FND_GLOBAL.USER_ID;

   c_false        CONSTANT  VARCHAR2(1)      := FND_API.G_FALSE;
   c_true         CONSTANT  VARCHAR2(1)      := FND_API.G_TRUE;
   c_success      CONSTANT  VARCHAR2(1)      := FND_API.G_RET_STS_SUCCESS;
   c_error        CONSTANT  VARCHAR2(1)      := FND_API.G_RET_STS_ERROR;
   c_unexp        CONSTANT  VARCHAR2(1)      := FND_API.G_RET_STS_UNEXP_ERROR;
   c_api_version  CONSTANT  NUMBER           := 1.0;
   c_fetch_limit  CONSTANT  NUMBER           := 99999;


   c_proc_name CONSTANT VARCHAR2(30) := 'Main';

   gv_request_id  NUMBER;
   gv_apps_user_id  CONSTANT NUMBER := FND_GLOBAL.User_Id;
   gv_login_id   CONSTANT NUMBER   := FND_GLOBAL.Login_Id;
   gv_pgm_id      CONSTANT NUMBER  := FND_GLOBAL.Conc_Program_Id;
   gv_pgm_app_id  CONSTANT NUMBER  := FND_GLOBAL.Prog_Appl_ID;


   gv_concurrent_status BOOLEAN;


---------Message Constants--------------


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



END FEM_GENDEFAULTS_ENG_PKG;


 

/
