--------------------------------------------------------
--  DDL for Package CE_JE_MAPPINGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CE_JE_MAPPINGS_PKG" AUTHID CURRENT_USER as
/* $Header: cejemcds.pls 120.1 2006/04/07 06:27:14 svali noship $ */
   --
   -- Package
   --   ce_je_mappings_pkg
   -- Purpose
   --   To contain validation and insertion routines for ce_je_mappings
   -- History
   --   08-Sept-2004   Sahik Vali   Created
  G_spec_revision 	VARCHAR2(1000) := '$Revision: 120.1 $';

  FUNCTION spec_revision RETURN VARCHAR2;

  FUNCTION body_revision RETURN VARCHAR2;

   --
   -- Procedure
   --  Insert_Row
   -- Purpose
   --   Inserts a row into ce_je_mappings
   -- History
   --   08-Sept-2004  Shaik Vali Created
   -- Arguments
   -- all the columns of the table ce_je_mappings
   -- Example
   --   ce_je_mappings_pkg.Insert_Row(....;
   -- Notes
   --
   PROCEDURE Insert_Row( X_Rowid                   IN OUT NOCOPY VARCHAR2,
                         X_JE_Mapping_Id     IN OUT NOCOPY NUMBER,
                         X_Bank_Account_Id                NUMBER,
                         X_Trx_Code_Id     	NUMBER,
				 X_Search_String_txt VARCHAR2,
		         X_GL_Account_CCID	NUMBER,
				 X_Reference_txt	VARCHAR2,
                         X_Last_Updated_By                NUMBER,
                         X_Last_Update_Date               DATE,
                         X_Last_Update_Login              NUMBER,
                         X_Created_By                     NUMBER,
                         X_Creation_Date                  DATE,
			 X_trxn_subtype_code_id 	NUMBER
                      );
   --
   -- Procedure
   --  Lock_Row
   -- Purpose
   --   Locks a row into ce_je_mappings
   -- History
   --   08-Sept-2004  Shaik Vali Created
   -- Arguments
   -- all the columns of the table ce_je_mappings
   -- Example
   --   ce_je_mappings_pkg.Lock_Row(....;
   -- Notes
   --
  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_JE_Mapping_Id	                NUMBER,
                     X_Bank_Account_Id                  NUMBER,
                     X_Trx_Code_Id                      NUMBER,
		 X_GL_Account_CCID			NUMBER,
		 X_Search_String_txt			VARCHAR2,
		 X_Reference_txt		VARCHAR2,
		 X_trxn_subtype_code_id 	NUMBER             );
   --
   -- Procedure
   --  Update_Row
   -- Purpose
   --   Updates a row into ce_je_mappings
   -- History
   --   08-Sept-2004  Shaik Vali Created
   -- Arguments
   -- all the columns of the table ce_je_mappings
   -- Example
   --   ce_je_mappings.Update_Row(....;
   -- Notes
   --
  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_JE_Mapping_Id            NUMBER,
                       X_Bank_Account_Id                NUMBER,
                       X_Trx_Code_Id                    NUMBER,
			   X_GL_Account_CCID				NUMBER,
			   X_Search_String_txt			    VARCHAR2,
			   X_Reference_txt					VARCHAR2,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Update_Login              NUMBER,
		X_trxn_subtype_code_id NUMBER
                      );
   --
   -- Procedure
   --  Delete_Row
   -- Purpose
   --   Deletes a row from ce_je_mappings
   -- History
   --   08-Sept-2004  Shaik Vali Created
   -- Arguments
   --    x_rowid         Rowid of a row
   -- Example
   --   ce_je_mappings_pkg.delete_row();
   -- Notes
   --
  PROCEDURE Delete_Row(X_Rowid VARCHAR2);
  --
  -- Procedure
  --  check_unique_combination
  -- Purpose
  --   Checks for uniquness of combination of the Bank account,
  --   Transaction code,Search string and GL Account before
  --   insertion and updates for a given mapping
  -- History
  --   08-Sept-2004  Shaik Vali Created
  -- Arguments
  --    x_row_id           Rowid of a row
  --    X_trx_code         Transaction code of row to be inserted or updated
  --    X_bank_account_id  Bank Account Id
  -- Example
  --   ce_je_mappings_pkg.check_unique_combination(
  -- Notes
  --


PROCEDURE check_unique_combination( X_bank_account_id IN NUMBER,
							X_trx_code_id  IN NUMBER,
						  	X_GL_account_ccid IN NUMBER,
						 	X_Search_string_txt VARCHAR2,
                                   X_Row_id IN VARCHAR2 );


END CE_JE_MAPPINGS_PKG;

 

/
