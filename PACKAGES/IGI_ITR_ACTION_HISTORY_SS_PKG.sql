--------------------------------------------------------
--  DDL for Package IGI_ITR_ACTION_HISTORY_SS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_ITR_ACTION_HISTORY_SS_PKG" AUTHID CURRENT_USER as
-- $Header: igiitrns.pls 120.2.12000000.1 2007/09/12 10:32:06 mbremkum ship $
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
                      );

END IGI_ITR_ACTION_HISTORY_SS_PKG;

 

/
