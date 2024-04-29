--------------------------------------------------------
--  DDL for Package Body CE_JE_MAPPINGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_JE_MAPPINGS_PKG" as
/* $Header: cejemcdb.pls 120.1 2006/04/07 06:27:20 svali noship $ */
--
-- Package
--  ce_je_mappings_pkg
-- Purpose
--   To contain validation and insertion routines for cb_transaction_codes
-- History
--   08-Sept-2004   Sahik Vali           Created

  FUNCTION body_revision RETURN VARCHAR2 IS
  BEGIN

    RETURN '$Revision: 120.1 $';

  END body_revision;

  FUNCTION spec_revision RETURN VARCHAR2 IS
  BEGIN

    RETURN G_spec_revision;

  END spec_revision;


  --
  -- Procedure
  --  Insert_Row
  -- Purpose
  --   Inserts a row into ce_je_mappings
  -- History
  --   08-Sept-2004  Shaik Vali           Created
  -- Arguments
  -- all the columns of the table CE_JE_MAPPINGS
  -- Example
  --   CE_JE_MAPPINGS_PKG.Insert_Row(....;
  -- Notes
  --
PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_JE_Mapping_Id     IN OUT NOCOPY NUMBER,
                       X_Bank_Account_Id            NUMBER,
                       X_Trx_Code_Id                NUMBER,
                       X_Search_String_txt          VARCHAR2,
                       X_GL_Account_CCID            NUMBER,
                       X_Reference_txt		        VARCHAR2,
                       X_Last_Updated_By            NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Update_Login              NUMBER,
                       X_Created_By                     NUMBER,
                       X_Creation_Date                  DATE,
		    X_trxn_subtype_code_id NUMBER
  ) IS
    CURSOR C IS SELECT rowid FROM CE_JE_MAPPINGS
                 WHERE je_mapping_id = X_JE_Mapping_Id;

  CURSOR C2 IS SELECT ce_je_mappings_s.nextval FROM sys.dual;
   --
   BEGIN
     --   cep_standard.debug('open c2 ');

       OPEN C2;
       FETCH C2 INTO X_JE_Mapping_id;
       CLOSE C2;
       --

       INSERT INTO CE_JE_MAPPINGS(
	      je_mapping_id,
              bank_account_id,
              trx_code_id,
	      search_string_txt,
	      GL_account_ccid,
	      reference_txt,
   	      Last_Updated_By,
              Last_Update_Date,
              Last_Update_Login,
              Created_By,
              Creation_Date,
	      trxn_subtype_code_id
             ) VALUES (
	      X_JE_Mapping_Id,
              X_Bank_Account_Id,
              X_Trx_Code_Id,
	      X_Search_String_txt,
	      X_GL_Account_CCID,
	      X_Reference_txt,
              X_Last_Updated_By,
              X_Last_Update_Date,
              X_Last_Update_Login,
              X_Created_By,
              X_Creation_Date,
	      X_trxn_subtype_code_id
             );
    --
    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;
  END Insert_Row;


  --
  -- Procedure
  --  Lock_Row
  -- Purpose
  --   Locks a row into ce_je_mappings
  -- History
  --   08-Sept-2004  Shaik Vali	 Created
  -- Arguments
  -- all the columns of the table CE_JE_MAPPINGS
  -- Example
  --   ce_je_mappings_pkg.Lock_Row(....;
  -- Notes
  --
  PROCEDURE Lock_Row(X_Rowid                      VARCHAR2,
                     X_JE_Mapping_Id              NUMBER,
                     X_Bank_Account_Id                  NUMBER,
                     X_Trx_Code_Id                      NUMBER,
			 X_GL_Account_CCID			NUMBER,
			 X_Search_String_txt		VARCHAR2,
			 X_Reference_txt			VARCHAR2,
		     X_trxn_subtype_code_id NUMBER
  ) IS
    CURSOR C IS
        SELECT *
        FROM   CE_JE_MAPPINGS
        WHERE  rowid = X_Rowid
        FOR UPDATE of JE_Mapping_Id NOWAIT;
    Recinfo C%ROWTYPE;
  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;
    if (
          (Recinfo.je_mapping_id =  X_JE_Mapping_Id)
           AND (Recinfo.bank_account_id =  X_Bank_Account_Id)
           AND (Recinfo.trx_code_id =  X_Trx_Code_Id)
	   AND (Recinfo.gl_account_ccid = X_GL_Account_CCID)
	   AND (Recinfo.search_string_txt is null
		 OR (Recinfo.search_string_txt = X_Search_String_txt))
	   AND (Recinfo.reference_txt is null
		 OR (Recinfo.reference_txt = X_Reference_txt))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;

  --
  -- Procedure
  --  Update_Row
  -- Purpose
  --   Updates a row into ce_je_mappings
  -- History
  --   08-Sept-2004  Shaik Vali Created
  -- Arguments
  -- all the columns of the table CE_JE_MAPPINGS
  -- Example
  --   ce_je_mappings_pkg.Update_Row(....;
  -- Notes
  --
  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_JE_Mapping_Id            NUMBER,
                       X_Bank_Account_Id                NUMBER,
                       X_Trx_Code_Id                    NUMBER,
			   X_GL_Account_CCID				NUMBER,
			   X_Search_String_txt				VARCHAR2,
			   X_Reference_txt					VARCHAR2,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Update_Login              NUMBER,
			X_trxn_subtype_code_id	NUMBER
  ) IS
  BEGIN
    UPDATE CE_JE_MAPPINGS
    SET
       je_mapping_id             =     X_JE_Mapping_Id,
       bank_account_id                 =     X_Bank_Account_Id,
       trx_code_id                        =     X_Trx_Code_Id,
       gl_account_ccid				   =	 X_GL_Account_CCID,
       search_string_txt			   =	 X_Search_String_txt,
       reference_txt				   =	 X_Reference_txt,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_date                =     X_Last_Update_Date,
       last_update_login               =     X_Last_Update_Login,
	trxn_subtype_code_id	= X_trxn_subtype_code_id
    WHERE rowid = X_Rowid;
    --
    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;
  --

  -- Procedure
  --  Delete_Row
  -- Purpose
  --   Deletes a row from ce_je_mappings
  -- History
  --   08-Sept-2004  Shaik Vali  Created
  -- Arguments
  --    x_rowid         Rowid of a row
  -- Example
  --   ce_je_mappings_pkg.delete_row(...;
  -- Notes
  --
  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM CE_JE_MAPPINGS
    WHERE rowid = X_Rowid;
    --
    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;
  --

  -- Procedure
  --  check_unique_combination
  -- Purpose
  --   Checks for uniquness of combination of the Bank account,
  --   Transaction code,Search string and GL Account before
  --   insertion and updates for a given mapping
  -- History
  --   08-Sept-2004  Shaik Vali  Created
  -- Arguments
  --    x_row_id           Rowid of a row
  --    X_trx_code_id         Transaction code of row to be inserted or updated
  --    X_bank_account_id  Bank Account Id
  --	X_GL_accountccid GL Account ccid
  --	X_Search_string_txt	Search string
  -- Example
  --   ce_je_mappings_pkg.check_unique_combination(..;
  -- Notes
  --


PROCEDURE check_unique_combination( X_bank_account_id IN NUMBER,
							 X_trx_code_id  IN NUMBER,
							 X_GL_account_ccid IN NUMBER,
							 X_Search_string_txt VARCHAR2,
 						     X_Row_id IN VARCHAR2 ) IS
  --
  CURSOR chk_duplicates is
  SELECT 'Duplicate'
  FROM   ce_je_mappings jem
  WHERE  bank_account_id = X_bank_account_id
  AND trx_code_id = X_trx_code_id
  AND ((search_string_txt is null and X_Search_string_txt is null) or
       (search_string_txt = X_Search_string_txt))
  AND    (    X_Row_id is null
           OR jem.rowid <> chartorowid( X_Row_id ) );
  dummy VARCHAR2(100);
  --
  BEGIN
    OPEN chk_duplicates;
    FETCH chk_duplicates INTO dummy;
    --
    IF chk_duplicates%FOUND THEN
        CLOSE chk_duplicates;
        fnd_message.set_name( 'CE', 'CE_DUP_BANK_JE_MAPPING' );
        app_exception.raise_exception;
    END IF;
    --
    CLOSE chk_duplicates;
    --
    EXCEPTION
          WHEN app_exceptions.application_exception THEN
          IF ( chk_duplicates%ISOPEN ) THEN
               CLOSE chk_duplicates;
          END IF;
          RAISE;
    WHEN OTHERS THEN
          fnd_message.set_name( 'SQLCE', 'CE_UNHANDLED_EXCEPTION');
          fnd_message.set_token( 'PROCEDURE',
                             'CE_TRANSACTION_CODES_pkg.check_unique_txn_code');
          IF ( chk_duplicates%ISOPEN ) THEN
               CLOSE chk_duplicates;
          END IF;
      RAISE;
  END check_unique_combination;

END CE_JE_MAPPINGS_PKG;

/
