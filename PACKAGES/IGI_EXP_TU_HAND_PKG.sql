--------------------------------------------------------
--  DDL for Package IGI_EXP_TU_HAND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_EXP_TU_HAND_PKG" AUTHID CURRENT_USER AS
-- $Header: igiexpis.pls 115.9 2003/07/23 13:56:57 sdixit ship $
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
                        --MOAC changes
                        X_Org_Id NUMBER);

 PROCEDURE Lock_Row( 	X_Rowid  VARCHAR2,
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
			X_Last_Updated_By NUMBER);

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
			X_Last_Updated_By NUMBER);

 PROCEDURE Delete_Row( 	X_Rowid VARCHAR2);

/* Added the following  procedure for bug 2661438*/

 PROCEDURE Check_App_Note_Status(p_trans_unit_id IN NUMBER,
                                 p_username      IN VARCHAR2,
                                 p_status        OUT NOCOPY VARCHAR2
                                );

/* Added the following  procedure for bug 2661438*/
 PROCEDURE Check_Acc_Note_Status(p_trans_unit_id IN NUMBER,
                                 p_username      IN VARCHAR2,
                                 p_status        OUT NOCOPY VARCHAR2
                                );

/* Added the following  procedure for bug 2661438*/
 PROCEDURE Check_Req_Note_Status(p_trans_unit_id IN NUMBER,
                                 p_username      IN VARCHAR2,
                                 p_status        OUT NOCOPY VARCHAR2
                                );
END IGI_EXP_TU_HAND_PKG;

 

/
