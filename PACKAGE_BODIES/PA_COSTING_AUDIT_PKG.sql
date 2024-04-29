--------------------------------------------------------
--  DDL for Package Body PA_COSTING_AUDIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_COSTING_AUDIT_PKG" as
/* $Header: PACSTAUB.pls 120.0 2005/05/29 12:36:42 appldev noship $ */

/* Insert_Audit_Record inserts audit record into the PA_COSTING_AUDIT table
   For FPM, the audit table is used to record the changes to the CWK implementation option -
   'XFACE_CWK_TIMECARD_FLAG'.
   The column values are as follows:
          MODULE_CODE	'PAXSUDSI'
          ACTIVITY_CODE	'XFACE_CWK_TC_FLAG_CHANGE'
          ACTIVITY_DATE	Sysdate
          DESCRIPTION	Import CWK timecards with PO integration change
          PK01	        Org Id
          REFERENCE1	Return Value of the API - Exists_Prj_Cwk_RbTC
          REFERENCE2	Old Value of the flag
          REFERENCE3	New value of the flag
*/

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
  ,P_PROGRAM_UPDATE_DATE      IN  DATE   Default Null)

  IS

   L_Description Varchar2(240);

 Begin

        If P_Activity_Code = 'XFACE_CWK_TC_FLAG_CHANGE' Then
           L_Description := 'Import CWK timecards with PO integration change';
        End If;

	Insert INTO Pa_Costing_Audit (
               Module_Code
              ,Activity_Code
              ,Activity_Date
              ,Description
              ,Pk01
              ,Pk02
              ,Pk03
              ,Reference1
              ,Reference2
              ,Reference3
              ,Reference4
              ,Reference5
              ,Reference6
              ,Reference7
              ,Reference8
              ,Reference9
              ,Reference10
              ,Creation_Date
              ,Created_By
              ,Last_Update_Date
              ,Last_Updated_By
              ,Last_Update_Login
              ,REQUEST_ID
              ,PROGRAM_APPLICATION_ID
              ,PROGRAM_ID
              ,PROGRAM_UPDATE_DATE  )
	 values (
               P_Module_Code
              ,P_Activity_Code
              ,P_Activity_Date
              ,L_Description
              ,P_Pk01
              ,P_Pk02
              ,P_Pk03
              ,P_Reference1
              ,P_Reference2
              ,P_Reference3
              ,P_Reference4
              ,P_Reference5
              ,P_Reference6
              ,P_Reference7
              ,P_Reference8
              ,P_Reference9
              ,P_Reference10
              ,P_Creation_Date
              ,P_Created_By
              ,P_Last_Update_Date
              ,P_Last_Updated_By
              ,P_Last_Update_Login
              ,P_REQUEST_ID
              ,P_PROGRAM_APPLICATION_ID
              ,P_PROGRAM_ID
              ,P_PROGRAM_UPDATE_DATE
          );

 Exception
        When Others then
                Raise;

 End Insert_Audit_Record;

END Pa_Costing_Audit_Pkg ;

/
