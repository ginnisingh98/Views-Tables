--------------------------------------------------------
--  DDL for Package Body IGI_EXP_TU_HAND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_EXP_TU_HAND_PKG" AS
-- $Header: igiexpib.pls 115.9 2003/08/09 11:41:08 rgopalan ship $
 PROCEDURE Insert_Row( 	X_Rowid IN OUT NOCOPY VARCHAR2,
			X_Trans_Unit_Id NUMBER,
			X_Doc_Type_Id NUMBER,
			X_Trans_Unit_Num VARCHAR2,
			X_Trans_Unit_Num_Type VARCHAR2,
			X_Trans_Unit_Status VARCHAR2,
			X_Amount NUMBER,
			X_Creation_Date	DATE,
			X_Created_By NUMBER,
			X_Last_Update_Login NUMBER,
			X_Last_Update_Date DATE,
			X_Last_Updated_By NUMBER,
			/*MOAc changes*/X_Org_Id NUMBER) IS

BEGIN
NULL;
END INSERT_ROW;
/***************************************************************************************/
 PROCEDURE Update_Row( 	X_Rowid VARCHAR2,
			X_Trans_Unit_Id NUMBER,
			X_Doc_Type_Id NUMBER,
			X_Trans_Unit_Num VARCHAR2,
			X_Trans_Unit_Num_Type VARCHAR2,
			X_Trans_Unit_Status VARCHAR2,
			X_Amount NUMBER,
			X_Creation_Date	DATE,
			X_Created_By NUMBER,
			X_Last_Update_Login NUMBER,
			X_Last_Update_Date DATE,
			X_Last_Updated_By NUMBER) IS
BEGIN
NULL;
END Update_Row;
/***************************************************************************************/
 PROCEDURE Delete_Row (X_Rowid VARCHAR2) IS
BEGIN
NULL;
END Delete_Row;
/***************************************************************************************/
PROCEDURE Lock_Row( 	X_Rowid VARCHAR2,
			X_Trans_Unit_Id NUMBER,
			X_Doc_Type_Id NUMBER,
			X_Trans_Unit_Num VARCHAR2,
			X_Trans_Unit_Num_Type VARCHAR2,
			X_Trans_Unit_Status VARCHAR2,
			X_Amount NUMBER,
			X_Creation_Date	DATE,
			X_Created_By NUMBER,
			X_Last_Update_Login NUMBER,
			X_Last_Update_Date DATE,
			X_Last_Updated_By NUMBER) IS
BEGIN
NULL;
END Lock_Row;

 /* Added the following procedure for bug 2661438*/
 PROCEDURE Check_App_Note_Status(p_trans_unit_id IN NUMBER,
                                 p_username      IN VARCHAR2,
                                 p_status        OUT NOCOPY VARCHAR2
                                )
  IS
BEGIN
NULL;
END;

 /* Added the following procedure for bug 2661438*/
  PROCEDURE Check_Acc_Note_Status(p_trans_unit_id IN NUMBER,
                                  p_username      IN VARCHAR2,
                                  p_status        OUT NOCOPY VARCHAR2
                                  )
  IS

BEGIN
NULL;
END ;


 /* Added the following procedure for bug 2661438*/
  PROCEDURE Check_Req_Note_Status(p_trans_unit_id IN NUMBER,
                                  p_username      IN VARCHAR2,
                                  p_status        OUT NOCOPY VARCHAR2
                                  )
  IS
BEGIN
NULL;
END;

END IGI_EXP_TU_HAND_PKG;

/
