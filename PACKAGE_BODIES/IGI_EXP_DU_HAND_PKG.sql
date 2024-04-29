--------------------------------------------------------
--  DDL for Package Body IGI_EXP_DU_HAND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_EXP_DU_HAND_PKG" AS
-- $Header: igiexphb.pls 115.6 2003/08/09 11:41:00 rgopalan ship $
 PROCEDURE Update_Row( 	X_Rowid  VARCHAR2,
			X_Dial_Unit_Id NUMBER,
			X_Doc_Type_Id NUMBER,
			X_Third_Party_Id NUMBER,
			X_Dial_Unit_Num VARCHAR2,
			X_Status VARCHAR2,
			X_Amount NUMBER,
			X_Description VARCHAR2,
			X_Trans_Unit_Id NUMBER,
			X_Dial_Unit_Selected_Flag VARCHAR2,
			X_Creation_Date	DATE,
			X_Created_By NUMBER,
			X_Last_Update_Login NUMBER,
			X_Last_Update_Date DATE,
			X_Last_Updated_By NUMBER,
                        X_Req_Reject CHAR) IS
BEGIN
  NULL;
END Update_Row;
/***************************************************************************************/

PROCEDURE Lock_Row( 	X_Rowid  VARCHAR2,
			X_Dial_Unit_Id NUMBER,
			X_Doc_Type_Id NUMBER,
			X_Third_Party_Id NUMBER,
			X_Dial_Unit_Num VARCHAR2,
			X_Status VARCHAR2,
			X_Amount NUMBER,
			X_Description VARCHAR2,
			X_Trans_Unit_Id NUMBER,
			X_Dial_Unit_Selected_Flag VARCHAR2) IS
BEGIN
 NULL;
END Lock_Row;
END IGI_EXP_DU_HAND_PKG;

/
