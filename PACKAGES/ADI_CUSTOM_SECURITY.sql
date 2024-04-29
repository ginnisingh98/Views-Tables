--------------------------------------------------------
--  DDL for Package ADI_CUSTOM_SECURITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ADI_CUSTOM_SECURITY" AUTHID CURRENT_USER AS
/* $Header: frmcuses.pls 120.0 2006/12/14 02:02:56 dvayro noship $ */
----------------------------------------------------------------------------------------
--  PACKAGE:      ADI_Custom_Security                                                 --
--                                                                                    --
--  DESCRIPTION:  Before this example package can be run, it is assumed that the      --
--                following table exists within the database:                         --
--                   ADI_USER_COST_CENTER                                             --
--                        ID           NOT NULL  NUMBER(15)                           --
--                        USERID                 NUMBER(15)                           --
--                        COST_CENTER            VARCHAR2(30)                         --
--                                                                                    --
--                   CREATE TABLE ADI_USER_CC                                         --
--                      (ID           NUMBER(15) NOT NULL,                            --
--                       USERID       NUMBER(15),                                     --
--                       COST_CENTER  VARCHAR2(30));                                  --
--                                                                                    --
--                 The package contains three procedures which allows the calling     --
--                 procedure to extract records from the secured values table         --
--                 (ADI_USER_COST_CENTER).  There are three procedures because PL/SQL --
--                 cannot handle arrays of information and therefore, DBMS cannot     --
--                 pass arrays of tables between two functions.                       --
--                                                                                    --
--                 The package contains three procedures which allows the calling     --
--                 procedure to extract records from the secured values table         --
--                 (ADI_USER_COST_CENTER).  There are three procedures because        --
--                 DBMS cannot pass arrays of tables between two functions.           --
--                                                                                    --
--                 You may use this package as a basis for creating your own security --
--                 model, however, the package specification MUST remain identical to --
--                 this package.  You can change the way in which these values are    --
--                 generated.                                                         --
--                                                                                    --
--  MODIFICATIONS                                                                     --
--  DATE       DEVELOPER  COMMENTS                                                    --
--  17-JUN-99  CCLYDE     Initial creation                                            --
--  16-FEB-00   CCLYDE     Added Package_Revision procedure to see if we can  --
--                         capture the revision number of the package during  --
--                         runtime.                                           --
--  16-MAY-00   GSANAP     Moved the $Header comment from the top to          --
--                         under the CREATE OR RAPLACE stmt.                  --
--  14-NOV-02   GHOOKER    Stub out procedures not used by RM8                        --
----------------------------------------------------------------------------------------
END ADI_CUSTOM_SECURITY;

 

/
