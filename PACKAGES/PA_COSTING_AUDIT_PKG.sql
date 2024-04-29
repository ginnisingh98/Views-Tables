--------------------------------------------------------
--  DDL for Package PA_COSTING_AUDIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_COSTING_AUDIT_PKG" AUTHID CURRENT_USER as
/* $Header: PACSTAUS.pls 120.0 2005/05/29 17:35:46 appldev noship $ */

  Procedure Insert_Audit_Record (
   P_Module_Code              IN  VARCHAR2
  ,P_Activity_Code            IN  VARCHAR2
  ,P_Activity_Date            IN  DATE
  ,P_Description              IN  VARCHAR2 Default Null
  ,P_Pk01                     IN  VARCHAR2 Default Null
  ,P_Pk02                     IN  VARCHAR2 Default Null
  ,P_Pk03                     IN  VARCHAR2 Default Null
  ,P_Reference1               IN  VARCHAR2 Default Null
  ,P_Reference2               IN  VARCHAR2 Default Null
  ,P_Reference3               IN  VARCHAR2 Default Null
  ,P_Reference4               IN  VARCHAR2 Default Null
  ,P_Reference5               IN  VARCHAR2 Default Null
  ,P_Reference6               IN  VARCHAR2 Default Null
  ,P_Reference7               IN  VARCHAR2 Default Null
  ,P_Reference8               IN  VARCHAR2 Default Null
  ,P_Reference9               IN  VARCHAR2 Default Null
  ,P_Reference10              IN  VARCHAR2 Default Null
  ,P_Creation_Date            IN  DATE
  ,P_Created_By               IN  NUMBER
  ,P_Last_Update_Date         IN  DATE
  ,P_Last_Updated_By          IN  NUMBER
  ,P_Last_Update_Login        IN  number
  ,P_REQUEST_ID               IN  NUMBER Default Null
  ,P_PROGRAM_APPLICATION_ID   IN  NUMBER Default Null
  ,P_PROGRAM_ID               IN  NUMBER Default Null
  ,P_PROGRAM_UPDATE_DATE      IN  DATE   Default Null);

END Pa_Costing_Audit_Pkg;

 

/
