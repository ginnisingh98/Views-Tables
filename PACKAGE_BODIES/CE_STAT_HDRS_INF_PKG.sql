--------------------------------------------------------
--  DDL for Package Body CE_STAT_HDRS_INF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_STAT_HDRS_INF_PKG" as
/* $Header: cestahib.pls 120.6 2005/06/10 14:34:41 jikumar ship $ */
--
-- Package
--   ce_stat_hdrs_inf_pkg
-- Purpose
--   To contain routines for ce_hdrs_inf
-- History
--  XX-XX-95	Kai Pigg	Created
  FUNCTION body_revision RETURN VARCHAR2 IS
  BEGIN

    RETURN '$Revision: 120.6 $';

  END body_revision;

  FUNCTION spec_revision RETURN VARCHAR2 IS
  BEGIN

    RETURN G_spec_revision;

  END spec_revision;

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
  ) IS
    CURSOR C IS SELECT rowid FROM CE_STATEMENT_HEADERS_INT
                 WHERE statement_number = X_Statement_Number
                 AND   bank_account_num = X_Bank_Account_Num;

   BEGIN


       INSERT INTO CE_STATEMENT_HEADERS_INT(
              statement_number,
              bank_branch_name,
              bank_account_num,
              statement_date,
	      check_digits,
              control_begin_balance,
              control_end_balance,
              cashflow_balance,
              int_calc_balance,
	      average_close_ledger_mtd,
	      average_close_ledger_ytd,
 	      average_close_available_mtd,
	      average_close_available_ytd,
              one_day_float,
              two_day_float,
              control_total_dr,
              control_total_cr,
              control_dr_line_count,
              control_cr_line_count,
              control_line_count,
              record_status_flag,
              currency_code,
              created_by,
              creation_date,
              attribute_category,
              attribute1,
              attribute10,
              attribute11,
              attribute12,
              attribute13,
              attribute14,
              attribute15,
              attribute2,
              attribute3,
              attribute4,
              attribute5,
              attribute6,
              attribute7,
              attribute8,
              attribute9,
              bank_name,
	      subsidiary_flag

             ) VALUES (

              X_Statement_Number,
              X_Bank_Branch_Name,
              X_Bank_Account_Num,
              X_Statement_Date,
	      X_Check_Digits,
              X_Control_Begin_Balance,
              X_Control_End_Balance,
              X_Cashflow_Balance,
              X_Int_Calc_Balance,
	      X_Average_Close_Ledger_MTD,
	      X_Average_Close_Ledger_YTD,
	      X_Average_Close_Available_MTD,
	      X_Average_Close_Available_YTD,
              X_One_Day_Float,
              X_Two_Day_Float,
              X_Control_Total_Dr,
              X_Control_Total_Cr,
              X_Control_Dr_Line_Count,
              X_Control_Cr_Line_Count,
              X_Control_Line_Count,
              X_Record_Status_Flag,
              X_Currency_Code,
              X_Created_By,
              X_Creation_Date,
              X_Attribute_Category,
              X_Attribute1,
              X_Attribute10,
              X_Attribute11,
              X_Attribute12,
              X_Attribute13,
              X_Attribute14,
              X_Attribute15,
              X_Attribute2,
              X_Attribute3,
              X_Attribute4,
              X_Attribute5,
              X_Attribute6,
              X_Attribute7,
              X_Attribute8,
              X_Attribute9,
              X_Bank_Name,
	      X_Subsidiary_flag
             );

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;
  END Insert_Row;


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
  ) IS
    CURSOR C IS
        SELECT *
        FROM   CE_STATEMENT_HEADERS_INT
        WHERE  rowid = X_Rowid
        FOR UPDATE of Statement_Number NOWAIT;
    Recinfo C%ROWTYPE;


  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      fnd_message.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;
    if (

               (Recinfo.statement_number =  X_Statement_Number)
           AND (   (Recinfo.bank_branch_name =  X_Bank_Branch_Name)
                OR (    (Recinfo.bank_branch_name IS NULL)
                    AND (X_Bank_Branch_Name IS NULL)))
           AND (Recinfo.bank_account_num =  X_Bank_Account_Num)
           AND (Recinfo.statement_date =  X_Statement_Date)
	   AND (   (Recinfo.check_digits = X_Check_Digits)
		OR (    (Recinfo.check_digits IS NULL)
		    AND (X_Check_Digits IS NULL)))
           AND (   (Recinfo.control_begin_balance =  X_Control_Begin_Balance)
                OR (    (Recinfo.control_begin_balance IS NULL)
                    AND (X_Control_Begin_Balance IS NULL)))
           AND (   (Recinfo.control_end_balance =  X_Control_End_Balance)
                OR (    (Recinfo.control_end_balance IS NULL)
                    AND (X_Control_End_Balance IS NULL)))
           AND (   (Recinfo.cashflow_balance =  X_Cashflow_Balance)
                OR (    (Recinfo.cashflow_balance IS NULL)
                    AND (X_Cashflow_Balance IS NULL)))
           AND (   (Recinfo.int_calc_balance =  X_Int_Calc_Balance)
                OR (    (Recinfo.int_calc_balance IS NULL)
                    AND (X_Int_calc_Balance IS NULL)))
           AND (   (Recinfo.average_close_ledger_mtd =  X_Average_Close_Ledger_MTD)
                OR (    (Recinfo.average_close_ledger_mtd IS NULL)
                    AND (X_Average_Close_Ledger_MTD IS NULL)))
           AND (   (Recinfo.average_close_ledger_ytd =  X_Average_Close_Ledger_YTD)
                OR (    (Recinfo.average_close_ledger_ytd IS NULL)
                    AND (X_Average_Close_Ledger_YTD IS NULL)))
           AND (   (Recinfo.average_close_available_mtd =  X_Average_Close_Available_MTD)
                OR (    (Recinfo.average_close_available_mtd IS NULL)
                    AND (X_Average_Close_Available_MTD IS NULL)))
           AND (   (Recinfo.average_close_available_ytd =  X_Average_Close_Available_YTD)
                OR (    (Recinfo.average_close_available_ytd IS NULL)
                    AND (X_Average_Close_Available_YTD IS NULL)))
           AND (   (Recinfo.one_day_float =  X_One_Day_Float)
                OR (    (Recinfo.one_day_float IS NULL)
                    AND (X_One_Day_Float IS NULL)))
           AND (   (Recinfo.two_day_float =  X_Two_Day_Float)
                OR (    (Recinfo.two_day_float IS NULL)
                    AND (X_Two_Day_Float IS NULL)))
           AND (   (Recinfo.control_total_dr =  X_Control_Total_Dr)
                OR (    (Recinfo.control_total_dr IS NULL)
                    AND (X_Control_Total_Dr IS NULL)))
           AND (   (Recinfo.control_total_cr =  X_Control_Total_Cr)
                OR (    (Recinfo.control_total_cr IS NULL)
                    AND (X_Control_Total_Cr IS NULL)))
           AND (   (Recinfo.control_dr_line_count =  X_Control_Dr_Line_Count)
                OR (    (Recinfo.control_dr_line_count IS NULL)
                    AND (X_Control_Dr_Line_Count IS NULL)))
           AND (   (Recinfo.control_cr_line_count =  X_Control_Cr_Line_Count)
                OR (    (Recinfo.control_cr_line_count IS NULL)
                    AND (X_Control_Cr_Line_Count IS NULL)))
           AND (   (Recinfo.control_line_count =  X_Control_Line_Count)
                OR (    (Recinfo.control_line_count IS NULL)
                    AND (X_Control_Line_Count IS NULL)))
           AND (   (Recinfo.record_status_flag =  X_Record_Status_Flag)
                OR (    (Recinfo.record_status_flag IS NULL)
                    AND (X_Record_Status_Flag IS NULL)))
           AND (   (Recinfo.currency_code =  X_Currency_Code)
                OR (    (Recinfo.currency_code IS NULL)
                    AND (X_Currency_Code IS NULL)))
           AND (   (Recinfo.attribute_category =  X_Attribute_Category)
                OR (    (Recinfo.attribute_category IS NULL)
                    AND (X_Attribute_Category IS NULL)))
           AND (   (Recinfo.attribute1 =  X_Attribute1)
                OR (    (Recinfo.attribute1 IS NULL)
                    AND (X_Attribute1 IS NULL)))
           AND (   (Recinfo.attribute10 =  X_Attribute10)
                OR (    (Recinfo.attribute10 IS NULL)
                    AND (X_Attribute10 IS NULL)))
           AND (   (Recinfo.attribute11 =  X_Attribute11)
                OR (    (Recinfo.attribute11 IS NULL)
                    AND (X_Attribute11 IS NULL)))
           AND (   (Recinfo.attribute12 =  X_Attribute12)
                OR (    (Recinfo.attribute12 IS NULL)
                    AND (X_Attribute12 IS NULL)))
           AND (   (Recinfo.attribute13 =  X_Attribute13)
                OR (    (Recinfo.attribute13 IS NULL)
                    AND (X_Attribute13 IS NULL)))
           AND (   (Recinfo.attribute14 =  X_Attribute14)
                OR (    (Recinfo.attribute14 IS NULL)
                    AND (X_Attribute14 IS NULL)))
           AND (   (Recinfo.attribute15 =  X_Attribute15)
                OR (    (Recinfo.attribute15 IS NULL)
                    AND (X_Attribute15 IS NULL)))
           AND (   (Recinfo.attribute2 =  X_Attribute2)
                OR (    (Recinfo.attribute2 IS NULL)
                    AND (X_Attribute2 IS NULL)))
           AND (   (Recinfo.attribute3 =  X_Attribute3)
                OR (    (Recinfo.attribute3 IS NULL)
                    AND (X_Attribute3 IS NULL)))
           AND (   (Recinfo.attribute4 =  X_Attribute4)
                OR (    (Recinfo.attribute4 IS NULL)
                    AND (X_Attribute4 IS NULL)))
           AND (   (Recinfo.attribute5 =  X_Attribute5)
                OR (    (Recinfo.attribute5 IS NULL)
                    AND (X_Attribute5 IS NULL)))
           AND (   (Recinfo.attribute6 =  X_Attribute6)
                OR (    (Recinfo.attribute6 IS NULL)
                    AND (X_Attribute6 IS NULL)))
           AND (   (Recinfo.attribute7 =  X_Attribute7)
                OR (    (Recinfo.attribute7 IS NULL)
                    AND (X_Attribute7 IS NULL)))
           AND (   (Recinfo.attribute8 =  X_Attribute8)
                OR (    (Recinfo.attribute8 IS NULL)
                    AND (X_Attribute8 IS NULL)))
           AND (   (Recinfo.attribute9 =  X_Attribute9)
                OR (    (Recinfo.attribute9 IS NULL)
                    AND (X_Attribute9 IS NULL)))
           AND (   (Recinfo.bank_name =  X_Bank_Name)
                OR (    (Recinfo.bank_name IS NULL)
                    AND (X_Bank_Name IS NULL)))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;



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
  ) IS
  BEGIN
    UPDATE CE_STATEMENT_HEADERS_INT
    SET
       statement_number                =     X_Statement_Number,
       bank_branch_name                =     X_Bank_Branch_Name,
       bank_account_num                =     X_Bank_Account_Num,
       statement_date                  =     X_Statement_Date,
       check_digits		       =     X_Check_Digits,
       control_begin_balance           =     X_Control_Begin_Balance,
       control_end_balance             =     X_Control_End_Balance,
       cashflow_balance                =     X_Cashflow_Balance,
       int_calc_balance                =     X_Int_Calc_Balance,
       average_close_ledger_mtd		   =  	 X_Average_Close_Ledger_MTD,
       average_close_ledger_ytd		   =  	 X_Average_Close_Ledger_YTD,
       average_close_available_mtd	   =  	 X_Average_Close_Available_MTD,
       average_close_available_ytd	   =  	 X_Average_Close_Available_YTD,
       one_day_float                   =     X_One_Day_Float,
       two_day_float                   =     X_Two_Day_Float,
       control_total_dr                =     X_Control_Total_Dr,
       control_total_cr                =     X_Control_Total_Cr,
       control_dr_line_count           =     X_Control_Dr_Line_Count,
       control_cr_line_count           =     X_Control_Cr_Line_Count,
       control_line_count              =     X_Control_Line_Count,
       record_status_flag              =     X_Record_Status_Flag,
       currency_code                   =     X_Currency_Code,
       attribute_category              =     X_Attribute_Category,
       attribute1                      =     X_Attribute1,
       attribute10                     =     X_Attribute10,
       attribute11                     =     X_Attribute11,
       attribute12                     =     X_Attribute12,
       attribute13                     =     X_Attribute13,
       attribute14                     =     X_Attribute14,
       attribute15                     =     X_Attribute15,
       attribute2                      =     X_Attribute2,
       attribute3                      =     X_Attribute3,
       attribute4                      =     X_Attribute4,
       attribute5                      =     X_Attribute5,
       attribute6                      =     X_Attribute6,
       attribute7                      =     X_Attribute7,
       attribute8                      =     X_Attribute8,
       attribute9                      =     X_Attribute9,
       bank_name                       =     X_Bank_Name,
       subsidiary_flag				   =     X_Subsidiary_flag
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;
  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM CE_STATEMENT_HEADERS_INT
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;

  PROCEDURE check_unique(X_statement_number     VARCHAR2,
                         X_bank_account_num     VARCHAR2,
                         X_row_id               VARCHAR2) IS
    CURSOR chk_duplicates is
      SELECT 'Duplicate'
      FROM   CE_STATEMENT_HEADERS_INT csr
      WHERE  csr.statement_number       = X_statement_number
      AND    csr.bank_account_num       = X_bank_account_num
      AND    (   X_row_id is null
              OR csr.rowid <> chartorowid(X_row_id));
    dummy VARCHAR2(100);
  BEGIN
    OPEN chk_duplicates;
    FETCH chk_duplicates INTO dummy;

    IF chk_duplicates%FOUND THEN
      CLOSE chk_duplicates;
      fnd_message.set_name('CE', 'CE_DUPLICATE_STAT_HDRS_INF');
      app_exception.raise_exception;
    END IF;
    CLOSE chk_duplicates;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('CE', 'CE_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE', 'ce_stat_hdrs_inf_pkg.check_unique');
      RAISE;
  END check_unique;
  --

END CE_STAT_HDRS_INF_PKG;

/
