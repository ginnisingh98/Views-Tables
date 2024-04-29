--------------------------------------------------------
--  DDL for Package Body IGI_ITR_ACTION_HISTORY_SS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_ITR_ACTION_HISTORY_SS_PKG" as
-- $Header: igiitrnb.pls 120.2.12000000.1 2007/09/12 10:32:02 mbremkum ship $
--

  PROCEDURE Insert_Row(
                       X_Service_Line_Id       NUMBER,
                       X_Sequence_Num          NUMBER,
                       X_Action_Code           VARCHAR2,
                       X_Action_Date           DATE,
                       X_Employee_Id           NUMBER,
                       X_Use_Workflow_Flag     VARCHAR2,
                       X_Note                  VARCHAR2,
                       X_Created_By            NUMBER,
                       X_Creation_Date         DATE,
                       X_Last_Update_Login     NUMBER,
                       X_Last_Update_Date      DATE,
                       X_Last_Updated_By       NUMBER
                      ) IS
  BEGIN
     INSERT INTO igi_itr_action_history(
            it_service_line_id,
            sequence_num,
            action_code,
            action_date,
            employee_id,
            use_workflow_flag,
            note,
            created_by,
            creation_date,
            last_update_login,
            last_update_date,
            last_updated_by
            )
      VALUES (
              X_Service_Line_Id,
              X_Sequence_Num,
              X_Action_Code,
              X_Action_Date,
              X_Employee_Id,
              X_Use_Workflow_Flag,
              X_Note,
              X_Created_By,
              X_Creation_Date,
              X_Last_Update_Login,
              X_Last_Update_Date,
              X_Last_Updated_By
             );

  END Insert_Row;


END IGI_ITR_ACTION_HISTORY_SS_PKG;

/
