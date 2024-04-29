--------------------------------------------------------
--  DDL for Package IGI_AR_SYS_OPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_AR_SYS_OPT_PKG" AUTHID CURRENT_USER as
-- $Header: igirsops.pls 120.2.12000000.2 2007/10/25 06:22:49 mbremkum ship $

  /*Added for R12 Uptake Bug No 5905216*/

  PROCEDURE Insert_Row(X_Rowid		VARCHAR2,
	  X_Set_Of_Books_Id		NUMBER,
	  X_Rpi_Header_Context_Code	VARCHAR2,
	  X_Rpi_Header_Charge_Id	VARCHAR2,
	  X_Rpi_Header_Generate_Seq	VARCHAR2,
	  X_Rpi_Line_Context_Code	VARCHAR2,
	  X_Rpi_Line_Charge_Id		VARCHAR2,
	  X_Rpi_Line_Generate_Seq	VARCHAR2,
	  X_Rpi_Line_Charge_Line_Num	VARCHAR2,
	  X_Rpi_Line_Price_Break_Num	VARCHAR2,
--	  X_Dunning_Receivables_Trx_Id  NUMBER,
          X_Last_Updated_By             NUMBER,
          X_Last_Update_Date            DATE,
          X_Last_Update_Login           NUMBER,
	  X_Created_By			VARCHAR2,
	  X_Creation_Date		DATE,
	  X_Org_Id			NUMBER

 );


  PROCEDURE Update_Row(X_Rowid		VARCHAR2,
	  X_Set_Of_Books_Id		NUMBER,
--	  X_Arc_Auto_Gl_Import_Flag     VARCHAR2,	/*Commented for R12 Uptake Bug No 5905216 - Dunning and ARC are not used*/
--	  X_Arc_Cash_Sob_Id		NUMBER,
--	  X_Arc_Unalloc_Rev_Ccid	NUMBER,
--        X_Dunning_Receivables_Trx_Id  NUMBER,
	  X_Rpi_Header_Context_Code	VARCHAR2,
	  X_Rpi_Header_Charge_Id	VARCHAR2,
	  X_Rpi_Header_Generate_Seq	VARCHAR2,
	  X_Rpi_Line_Context_Code	VARCHAR2,
	  X_Rpi_Line_Charge_Id		VARCHAR2,
	  X_Rpi_Line_Generate_Seq	VARCHAR2,
	  X_Rpi_Line_Charge_Line_Num	VARCHAR2,
	  X_Rpi_Line_Price_Break_Num	VARCHAR2,
          X_Last_Updated_By             NUMBER,
          X_Last_Update_Date            DATE,
          X_Last_Update_Login           NUMBER
--        X_Arc_Je_Source_Name          VARCHAR2  -- Added by Zahi

 );

  PROCEDURE Lock_Row(X_Rowid		VARCHAR2,
	  X_Set_Of_Books_Id		NUMBER,
--	  X_Arc_Auto_Gl_Import_Flag     VARCHAR2,	/*Commented for R12 Uptake bug No 5905216 - Dunning and ARC are not used*/
--	  X_Arc_Cash_Sob_Id		NUMBER,
--	  X_Arc_Unalloc_Rev_Ccid	NUMBER,
--        X_Dunning_Receivables_Trx_Id  NUMBER,
	  X_Rpi_Header_Context_Code	VARCHAR2,
	  X_Rpi_Header_Charge_Id	VARCHAR2,
	  X_Rpi_Header_Generate_Seq	VARCHAR2,
	  X_Rpi_Line_Context_Code	VARCHAR2,
	  X_Rpi_Line_Charge_Id		VARCHAR2,
	  X_Rpi_Line_Generate_Seq	VARCHAR2,
	  X_Rpi_Line_Charge_Line_Num	VARCHAR2,
	  X_Rpi_Line_Price_Break_Num	VARCHAR2
--        X_Arc_Je_Source_Name          VARCHAR2
	 );

END IGI_AR_SYS_OPT_PKG ;

 

/
