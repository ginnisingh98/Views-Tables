--------------------------------------------------------
--  DDL for Package CE_STAT_LINES_INF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CE_STAT_LINES_INF_PKG" AUTHID CURRENT_USER as
/* $Header: cestalis.pls 120.1 2002/11/12 21:25:44 bhchung ship $ */

  G_spec_revision 	VARCHAR2(1000) := '$Revision: 120.1 $';

  FUNCTION spec_revision RETURN VARCHAR2;

  FUNCTION body_revision RETURN VARCHAR2;

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Bank_Account_Num               VARCHAR2,
                       X_Statement_Number               VARCHAR2,
                       X_Line_Number                    NUMBER,
                       X_Trx_Date                       DATE,
                       X_Trx_Code                       VARCHAR2,
                       X_Effective_Date                 DATE,
                       X_Trx_Text                       VARCHAR2,
                       X_Invoice_Text                   VARCHAR2,
		       X_Bank_Account_Text		VARCHAR2,
                       X_Amount                         NUMBER,
		       X_Charges_Amount			NUMBER,
                       X_Currency_Code                  VARCHAR2,
                       X_Exchange_Rate                  NUMBER,
		       X_user_exchange_rate_type	VARCHAR2,
		       X_exchange_rate_date		DATE,
		       X_original_amount		NUMBER,
                       X_Bank_Trx_Number                VARCHAR2,
                       X_Customer_Text                  VARCHAR2,
                       X_Created_By                     NUMBER,
                       X_Creation_Date                  DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Date               DATE,
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
                       X_Attribute9                     VARCHAR2
                      );

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Bank_Account_Num                 VARCHAR2,
                     X_Statement_Number                 VARCHAR2,
                     X_Line_Number                      NUMBER,
                     X_Trx_Date                         DATE,
                     X_Trx_Code                         VARCHAR2,
                     X_Effective_Date                   DATE,
                     X_Trx_Text                         VARCHAR2,
                     X_Invoice_Text                     VARCHAR2,
		     X_Bank_Account_Text		VARCHAR2,
                     X_Amount                           NUMBER,
		     X_Charges_Amount			NUMBER,
                     X_Currency_Code                    VARCHAR2,
                     X_Exchange_Rate                    NUMBER,
		     X_user_exchange_rate_type		VARCHAR2,
		     X_exchange_rate_date		DATE,
		     X_original_amount		        NUMBER,
                     X_Bank_Trx_Number                  VARCHAR2,
                     X_Customer_Text                    VARCHAR2,
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
                     X_Attribute9                       VARCHAR2
                    );



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Bank_Account_Num               VARCHAR2,
                       X_Statement_Number               VARCHAR2,
                       X_Line_Number                    NUMBER,
                       X_Trx_Date                       DATE,
                       X_Trx_Code                       VARCHAR2,
                       X_Effective_Date                 DATE,
                       X_Trx_Text                       VARCHAR2,
                       X_Invoice_Text                   VARCHAR2,
		       X_Bank_Account_Text		VARCHAR2,
                       X_Amount                         NUMBER,
                       X_Charges_Amount                 NUMBER,
		       X_Currency_Code                  VARCHAR2,
                       X_Exchange_Rate                  NUMBER,
		       X_user_exchange_rate_type	VARCHAR2,
		       X_exchange_rate_date		DATE,
		       X_original_amount		NUMBER,
                       X_Bank_Trx_Number                VARCHAR2,
                       X_Customer_Text                  VARCHAR2,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Date               DATE,
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
                       X_Attribute9                     VARCHAR2
                      );
  PROCEDURE Delete_Row(X_Rowid VARCHAR2);
  --
  -- Procedure
  --   check_unique
  -- Purpose
  --   Checks to make sure that the reconciliation inserted
  --   is unique.
  -- History
  --   04-08-95  Dean McCarthy  Created
  -- Arguments
  -- X_statement_number         VARCHAR2
  -- X_bank_account_num         VARCHAR2
  -- X_Line_number              NUMBER
  -- X_row_id                   VARCHAR2
  --
  -- Example
  --   ce_stat_lines_inf_pkg.check_unique(...);
  -- Notes
  --

  PROCEDURE check_unique(X_statement_number     VARCHAR2,
                         X_bank_account_num     VARCHAR2,
                         X_line_number          NUMBER,
                         X_row_id               VARCHAR2);
END CE_STAT_LINES_INF_PKG;

 

/
