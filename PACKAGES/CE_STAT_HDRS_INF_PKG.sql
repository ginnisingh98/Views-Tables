--------------------------------------------------------
--  DDL for Package CE_STAT_HDRS_INF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CE_STAT_HDRS_INF_PKG" AUTHID CURRENT_USER as
/* $Header: cestahis.pls 120.5 2005/06/10 14:23:41 jikumar ship $ */
--
-- Package
--   ce_stat_hdrs_inf_pkg
-- Purpose
--   To contain routines for ce_stat_hdrs_inf_pkg
-- History
--   04-08-95   Kai Pigg        Created

  G_spec_revision 	VARCHAR2(1000) := '$Revision: 120.5 $';

  FUNCTION spec_revision RETURN VARCHAR2;

  FUNCTION body_revision RETURN VARCHAR2;

  --
  -- Procedure
  --   insert_row
  -- Purpose
  --   To insert new row to ce_stat_hdrs_inf
  -- History
  --   04-08-95  Kai Pigg    Created
  --
  -- Example
  --   ce_stat_hdrs_inf_pkg.insert_row(...);
  -- Notes
  --

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Statement_Number               VARCHAR2,
                       X_Bank_Branch_Name               VARCHAR2,
                       X_Bank_Account_Num               VARCHAR2,
                       X_Statement_Date                 DATE,
		       X_Check_Digits			VARCHAR2,
                       X_Control_Begin_Balance          NUMBER,
                       X_Control_End_Balance            NUMBER,
                       X_Cashflow_Balance               NUMBER,
                       X_Int_Calc_Balance               NUMBER,
			   X_Average_Close_Ledger_MTD		NUMBER,
			   X_Average_Close_Ledger_YTD		NUMBER,
			   X_Average_Close_Available_MTD	NUMBER,
			   X_Average_Close_Available_YTD	NUMBER,
                       X_One_Day_Float                  NUMBER,
                       X_Two_Day_Float                  NUMBER,
                       X_Control_Total_Dr               NUMBER,
                       X_Control_Total_Cr               NUMBER,
                       X_Control_Dr_Line_Count          NUMBER,
                       X_Control_Cr_Line_Count          NUMBER,
                       X_Control_Line_Count             NUMBER,
                       X_Record_Status_Flag             VARCHAR2,
                       X_Currency_Code                  VARCHAR2,
                       X_Created_By                     NUMBER,
                       X_Creation_Date                  DATE,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       --X_Org_Id                         NUMBER,
                       X_Bank_Name                      VARCHAR2,
			   X_Subsidiary_flag				VARCHAR2
                      );

  --
  -- Procedure
  --   Lock_Row
  -- Purpose
  --   To lock a row from ce_stat_hdrs_inf
  -- History
  --   XX-XX-95  Kai Pigg    Created
  --
  -- Example
  --   ce_stat_hdrs_inf_pkg.Lock_Row(...);
  -- Notes
  --
  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Statement_Number                 VARCHAR2,
                     X_Bank_Branch_Name                 VARCHAR2,
                     X_Bank_Account_Num                 VARCHAR2,
                     X_Statement_Date                   DATE,
		     X_Check_Digits			VARCHAR2,
                     X_Control_Begin_Balance            NUMBER,
                     X_Control_End_Balance              NUMBER,
                     X_Cashflow_Balance                 NUMBER,
                     X_Int_Calc_Balance                 NUMBER,
			 X_Average_Close_Ledger_MTD			NUMBER,
			 X_Average_Close_Ledger_YTD			NUMBER,
			 X_Average_Close_Available_MTD		NUMBER,
			 X_Average_Close_Available_YTD		NUMBER,
                     X_One_Day_Float                    NUMBER,
                     X_Two_Day_Float                    NUMBER,
                     X_Control_Total_Dr                 NUMBER,
                     X_Control_Total_Cr                 NUMBER,
                     X_Control_Dr_Line_Count            NUMBER,
                     X_Control_Cr_Line_Count            NUMBER,
                     X_Control_Line_Count               NUMBER,
                     X_Record_Status_Flag               VARCHAR2,
                     X_Currency_Code                    VARCHAR2,
                     X_Attribute_Category               VARCHAR2,
                     X_Attribute1                       VARCHAR2,
                     X_Attribute10                      VARCHAR2,
                     X_Attribute11                      VARCHAR2,
                     X_Attribute12                      VARCHAR2,
                     X_Attribute13                      VARCHAR2,
                     X_Attribute14                      VARCHAR2,
                     X_Attribute15                      VARCHAR2,
                     X_Attribute2                       VARCHAR2,
                     X_Attribute3                       VARCHAR2,
                     X_Attribute4                       VARCHAR2,
                     X_Attribute5                       VARCHAR2,
                     X_Attribute6                       VARCHAR2,
                     X_Attribute7                       VARCHAR2,
                     X_Attribute8                       VARCHAR2,
                     X_Attribute9                       VARCHAR2,
                     --X_Org_Id                           NUMBER,
                     X_Bank_Name                        VARCHAR2
                    );


  --
  -- Procedure
  --   Update_Row
  -- Purpose
  --   To update a row in ce_stat_hdrs_inf_v
  -- History
  --   XX-XX-95  Kai Pigg    Created
  --
  -- Example
  --   ce_stat_hdrs_inf_pkg.Update_Row(...);
  -- Notes
  --
  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Statement_Number               VARCHAR2,
                       X_Bank_Branch_Name               VARCHAR2,
                       X_Bank_Account_Num               VARCHAR2,
                       X_Statement_Date                 DATE,
		       X_Check_Digits			VARCHAR2,
                       X_Control_Begin_Balance          NUMBER,
                       X_Control_End_Balance            NUMBER,
                       X_Cashflow_Balance               NUMBER,
                       X_Int_Calc_Balance               NUMBER,
			   X_Average_Close_Ledger_MTD		NUMBER,
			   X_Average_Close_Ledger_YTD		NUMBER,
			   X_Average_Close_Available_MTD	NUMBER,
			   X_Average_Close_Available_YTD	NUMBER,
                       X_One_Day_Float                  NUMBER,
                       X_Two_Day_Float                  NUMBER,
                       X_Control_Total_Dr               NUMBER,
                       X_Control_Total_Cr               NUMBER,
                       X_Control_Dr_Line_Count          NUMBER,
                       X_Control_Cr_Line_Count          NUMBER,
                       X_Control_Line_Count             NUMBER,
                       X_Record_Status_Flag             VARCHAR2,
                       X_Currency_Code                  VARCHAR2,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       --X_Org_Id                         NUMBER,
                       X_Bank_Name                      VARCHAR2,
			   X_Subsidiary_flag				VARCHAR2
                      );
  PROCEDURE Delete_Row(X_Rowid VARCHAR2);


  --
  -- Procedure
  --   check_unique
  -- Purpose
  --   Checks to make sure that the reconciliation inserted
  --   is unique.
  -- History
  --   04-08-95  Kai Pigg    Created
  -- Arguments
  -- X_statement_number 	VARCHAR2
  -- X_bank_account_num 	VARCHAR2
  -- X_row_id			NUMBER
  --
  -- Example
  --   ce_stat_hdrs_inf_pkg.check_unique(...);
  -- Notes
  --

  PROCEDURE check_unique(X_statement_number 	VARCHAR2,
			 X_bank_account_num 	VARCHAR2,
			 X_Row_id 		VARCHAR2);


END CE_STAT_HDRS_INF_PKG;

 

/
