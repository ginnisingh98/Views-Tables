--------------------------------------------------------
--  DDL for Package IGI_EXP_DU_HAND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_EXP_DU_HAND_PKG" AUTHID CURRENT_USER AS
-- $Header: igiexphs.pls 115.5 2002/09/11 14:40:44 mbarrett ship $
 PROCEDURE Lock_Row( 	X_Rowid  VARCHAR2,
			X_Dial_Unit_Id NUMBER,
			X_Doc_Type_Id NUMBER,
			X_Third_Party_Id NUMBER,
			X_Dial_Unit_Num VARCHAR2,
			X_Status VARCHAR2,
			X_Amount NUMBER,
			X_Description VARCHAR2,
			X_Trans_Unit_Id NUMBER,
			X_Dial_Unit_Selected_Flag VARCHAR2 );

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
                        X_Req_Reject CHAR);

END IGI_EXP_DU_HAND_PKG;

 

/
