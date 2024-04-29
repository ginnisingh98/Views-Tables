--------------------------------------------------------
--  DDL for Package Body GL_INTERCOMPANY_ACCTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_INTERCOMPANY_ACCTS_PKG" as
/* $Header: gliacicb.pls 120.6 2005/05/05 00:58:26 kvora ship $ */


  --
  -- PUBLIC FUNCTIONS
  --

  PROCEDURE check_acc_set_unique( x_rowid               VARCHAR2,
                          	  x_ledger_id           NUMBER,
                          	  x_je_source_name      VARCHAR2,
                          	  x_je_category_name    VARCHAR2 ) IS
    CURSOR c_dup IS
      SELECT 'Duplicate row found'
      FROM   gl_intercompany_acc_sets ia
      WHERE  ia.LEDGER_ID 	        = x_ledger_id
      AND    ia.JE_SOURCE_NAME 		= x_je_source_name
      AND    ia.JE_CATEGORY_NAME	= x_je_category_name
      AND    ( x_rowid IS NULL
               OR
               ia.rowid <> x_rowid );
    dummy VARCHAR2( 100 );

  BEGIN
    OPEN  c_dup;
    FETCH c_dup INTO dummy;

    IF c_dup%FOUND THEN
      CLOSE c_dup;
      fnd_message.set_name('SQLGL',
        gl_public_sector.get_message_name('GL_DUPLICATE_INTERCO_ACC_SET',
                                          'SQLGL', null));
      app_exception.raise_exception;
    END IF;

    CLOSE c_dup;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'GL_INTERCOMPANY_ACCTS_PKG.check_acc_set_unique');
      RAISE;

  END check_acc_set_unique;


-- **********************************************************************
  PROCEDURE check_acct_unique( x_rowid		     VARCHAR2,
			       x_ledger_id           NUMBER,
                               x_je_source_name      VARCHAR2,
                               x_je_category_name    VARCHAR2,
			       x_bal_seg_value       VARCHAR2 ) IS
    CURSOR c_dup IS
      SELECT 'Duplicate row found'
      FROM   gl_intercompany_accounts ia
      WHERE  ia.LEDGER_ID 	        = x_ledger_id
      AND    ia.JE_SOURCE_NAME 		= x_je_source_name
      AND    ia.JE_CATEGORY_NAME	= x_je_category_name
      AND    ia.bal_seg_value		= x_bal_seg_value
      AND    ( x_rowid IS NULL
               OR
               ia.rowid <> x_rowid );

    dummy VARCHAR2( 100 );

  BEGIN
    OPEN  c_dup;
    FETCH c_dup INTO dummy;

    IF c_dup%FOUND THEN
      CLOSE c_dup;
      fnd_message.set_name('SQLGL',
        gl_public_sector.get_message_name('GL_DUPLICATE_INTERCO_ACCT',
                                          'SQLGL', null));
      app_exception.raise_exception;
    END IF;

    CLOSE c_dup;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'GL_INTERCOMPANY_ACCTS_PKG.check_acct_unique');
      RAISE;

  END check_acct_unique;


-- **********************************************************************

  FUNCTION is_other_exist( x_ledger_id NUMBER ) RETURN BOOLEAN IS

    CURSOR c_other IS
      SELECT 'found'
      FROM   gl_intercompany_accounts ia
      WHERE  ia.LEDGER_ID	 = x_ledger_id
      AND    ia.JE_SOURCE_NAME	 = 'Other'
      AND    ia.JE_CATEGORY_NAME = 'Other'
      AND    ia.BAL_SEG_VALUE	 = 'OTHER1234567890123456789012345';

    dummy VARCHAR2( 100 );

  BEGIN

    OPEN  c_other;
    FETCH c_other INTO dummy;

    IF c_other%FOUND THEN
       CLOSE c_other;
       RETURN( TRUE );
    ELSE
       CLOSE c_other;
       RETURN( FALSE );
    END IF;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'GL_INTERCOMPANY_ACCTS_PKG.is_other_exist');
      RAISE;

  END is_other_exist;

-- **********************************************************************

PROCEDURE Insert_Row(X_Rowid                         IN OUT NOCOPY VARCHAR2,
                     X_Je_Source_Name                       VARCHAR2,
                     X_Je_Category_Name                     VARCHAR2,
                     X_Ledger_Id                            NUMBER,
		     X_Balance_By_Code			    VARCHAR2,
		     X_Bal_Seg_Rule_Code		    VARCHAR2,
		     X_Always_Balance_Flag		    VARCHAR2,
                     X_Last_Update_Date                     DATE,
                     X_Last_Updated_By                      NUMBER,
                     X_Creation_Date                        DATE,
                     X_Created_By                           NUMBER,
                     X_Last_Update_Login                    NUMBER,
		     X_Default_Bal_Seg_Value		    VARCHAR2,
                     X_Attribute1                           VARCHAR2,
                     X_Attribute2                           VARCHAR2,
                     X_Attribute3                           VARCHAR2,
                     X_Attribute4                           VARCHAR2,
                     X_Attribute5                           VARCHAR2,
                     X_Attribute6                           VARCHAR2,
                     X_Attribute7                           VARCHAR2,
                     X_Attribute8                           VARCHAR2,
                     X_Attribute9                           VARCHAR2,
                     X_Attribute10                          VARCHAR2,
                     X_Attribute11                          VARCHAR2,
                     X_Attribute12                          VARCHAR2,
                     X_Attribute13                          VARCHAR2,
                     X_Attribute14                          VARCHAR2,
                     X_Attribute15                          VARCHAR2,
                     X_Context                              VARCHAR2
		     ) IS
   CURSOR C IS SELECT rowid FROM gl_intercompany_acc_sets
             WHERE je_source_name = X_Je_Source_Name
             AND   je_category_name = X_Je_Category_Name
             AND   ledger_id = X_Ledger_Id;

BEGIN

  INSERT INTO gl_intercompany_acc_sets(
          je_source_name,
          je_category_name,
          ledger_id,
	  balance_by_code,
	  bal_seg_rule_code,
	  always_balance_flag,
          last_update_date,
          last_updated_by,
          creation_date,
          created_by,
          last_update_login,
	  default_bal_seg_value,
          attribute1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          attribute6,
          attribute7,
          attribute8,
          attribute9,
          attribute10,
          attribute11,
          attribute12,
          attribute13,
          attribute14,
          attribute15,
          context
         ) VALUES (
          X_Je_Source_Name,
          X_Je_Category_Name,
          X_Ledger_Id,
	  X_Balance_By_Code,
	  X_Bal_Seg_Rule_Code,
	  X_Always_Balance_Flag,
          X_Last_Update_Date,
          X_Last_Updated_By,
          X_Creation_Date,
          X_Created_By,
          X_Last_Update_Login,
	  X_Default_Bal_Seg_Value,
          X_Attribute1,
          X_Attribute2,
          X_Attribute3,
          X_Attribute4,
          X_Attribute5,
          X_Attribute6,
          X_Attribute7,
          X_Attribute8,
          X_Attribute9,
          X_Attribute10,
          X_Attribute11,
          X_Attribute12,
          X_Attribute13,
          X_Attribute14,
          X_Attribute15,
          X_Context
  );

  OPEN C;
  FETCH C INTO X_Rowid;

  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;

EXCEPTION
  WHEN app_exceptions.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
    fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
    fnd_message.set_token('PROCEDURE',
      'GL_INTERCOMPANY_ACCTS_PKG.Insert_Row');
    RAISE;

END Insert_Row;

-- **********************************************************************

PROCEDURE Lock_Row(X_Rowid                                  VARCHAR2,
                   X_Je_Source_Name                         VARCHAR2,
                   X_Je_Category_Name                       VARCHAR2,
                   X_Ledger_Id                              NUMBER,
   		   X_Balance_By_Code			    VARCHAR2,
		   X_Bal_Seg_Rule_Code			    VARCHAR2,
		   X_Always_Balance_Flag		    VARCHAR2,
		   X_Default_Bal_Seg_Value		    VARCHAR2,
                   X_Attribute1	                            VARCHAR2,
                   X_Attribute2	                            VARCHAR2,
                   X_Attribute3                             VARCHAR2,
                   X_Attribute4                             VARCHAR2,
                   X_Attribute5                             VARCHAR2,
                   X_Attribute6                             VARCHAR2,
                   X_Attribute7                             VARCHAR2,
                   X_Attribute8                             VARCHAR2,
                   X_Attribute9                             VARCHAR2,
                   X_Attribute10                            VARCHAR2,
                   X_Attribute11                            VARCHAR2,
                   X_Attribute12                            VARCHAR2,
                   X_Attribute13                            VARCHAR2,
                   X_Attribute14                            VARCHAR2,
                   X_Attribute15                            VARCHAR2,
                   X_Context                                VARCHAR2
		  ) IS
  CURSOR C IS
      SELECT *
      FROM   gl_intercompany_acc_sets
      WHERE  rowid = X_Rowid
      FOR UPDATE of Je_Source_Name NOWAIT;
  Recinfo C%ROWTYPE;
BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;
  if (
          (   (Recinfo.je_source_name = X_Je_Source_Name)
           OR (    (Recinfo.je_source_name IS NULL)
               AND (X_Je_Source_Name IS NULL)))
      AND (   (Recinfo.je_category_name = X_Je_Category_Name)
           OR (    (Recinfo.je_category_name IS NULL)
               AND (X_Je_Category_Name IS NULL)))
      AND (   (Recinfo.ledger_id = X_Ledger_Id)
           OR (    (Recinfo.ledger_id IS NULL)
               AND (X_Ledger_Id IS NULL)))
      AND (   (Recinfo.balance_by_code = X_Balance_By_Code)
           OR (    (Recinfo.Balance_By_Code IS NULL)
               AND (X_Balance_By_Code IS NULL)))
      AND (   (Recinfo.bal_seg_rule_code = X_Bal_Seg_Rule_Code)
           OR (    (Recinfo.bal_seg_rule_code IS NULL)
               AND (X_Bal_Seg_Rule_Code IS NULL)))
      AND (   (Recinfo.always_balance_flag = X_Always_Balance_Flag)
           OR (    (Recinfo.always_balance_flag IS NULL)
               AND (X_Always_Balance_Flag IS NULL)))
      AND (   (Recinfo.default_bal_seg_value = X_Default_Bal_Seg_Value)
           OR (    (Recinfo.default_bal_seg_value IS NULL)
               AND (X_Default_Bal_Seg_Value IS NULL)))
      AND (   (Recinfo.attribute1 = X_Attribute1)
           OR (    (Recinfo.attribute1 IS NULL)
               AND (X_Attribute1 IS NULL)))
      AND (   (Recinfo.attribute2 = X_Attribute2)
           OR (    (Recinfo.attribute2 IS NULL)
               AND (X_Attribute2 IS NULL)))
      AND (   (Recinfo.attribute3 = X_Attribute3)
           OR (    (Recinfo.attribute3 IS NULL)
               AND (X_Attribute3 IS NULL)))
      AND (   (Recinfo.attribute4 = X_Attribute4)
           OR (    (Recinfo.attribute4 IS NULL)
               AND (X_Attribute4 IS NULL)))
      AND (   (Recinfo.attribute5 = X_Attribute5)
           OR (    (Recinfo.attribute5 IS NULL)
               AND (X_Attribute5 IS NULL)))
      AND (   (Recinfo.attribute6 = X_Attribute6)
           OR (    (Recinfo.attribute6 IS NULL)
               AND (X_Attribute6 IS NULL)))
      AND (   (Recinfo.attribute7 = X_Attribute7)
           OR (    (Recinfo.attribute7 IS NULL)
               AND (X_Attribute7 IS NULL)))
      AND (   (Recinfo.attribute8 = X_Attribute8)
           OR (    (Recinfo.attribute8 IS NULL)
               AND (X_Attribute8 IS NULL)))
      AND (   (Recinfo.attribute9 = X_Attribute9)
           OR (    (Recinfo.attribute9 IS NULL)
               AND (X_Attribute9 IS NULL)))
      AND (   (Recinfo.attribute10 = X_Attribute10)
           OR (    (Recinfo.attribute10 IS NULL)
               AND (X_Attribute10 IS NULL)))
      AND (   (Recinfo.attribute11 = X_Attribute11)
           OR (    (Recinfo.attribute11 IS NULL)
               AND (X_Attribute11 IS NULL)))
      AND (   (Recinfo.attribute12 = X_Attribute12)
           OR (    (Recinfo.attribute12 IS NULL)
               AND (X_Attribute12 IS NULL)))
      AND (   (Recinfo.attribute13 = X_Attribute13)
           OR (    (Recinfo.attribute13 IS NULL)
               AND (X_Attribute13 IS NULL)))
      AND (   (Recinfo.attribute14 = X_Attribute14)
           OR (    (Recinfo.attribute14 IS NULL)
               AND (X_Attribute14 IS NULL)))
      AND (   (Recinfo.attribute15 = X_Attribute15)
           OR (    (Recinfo.attribute15 IS NULL)
               AND (X_Attribute15 IS NULL)))
      AND (   (Recinfo.context = X_Context)
           OR (    (Recinfo.context IS NULL)
               AND (X_Context IS NULL)))
          ) then
    return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;

EXCEPTION
  WHEN app_exceptions.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
    fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
    fnd_message.set_token('PROCEDURE',
      'GL_INTERCOPANY_ACCTS_PKG.Lock_Row');
    RAISE;

END Lock_Row;

-- **********************************************************************

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Je_Source_Name                      VARCHAR2,
                     X_Je_Category_Name                    VARCHAR2,
                     X_Ledger_Id                           NUMBER,
		     X_Balance_By_Code			   VARCHAR2,
		     X_Bal_Seg_Rule_Code		   VARCHAR2,
		     X_Always_Balance_Flag		   VARCHAR2,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Last_Update_Login                   NUMBER,
		     X_Default_Bal_Seg_Value		   VARCHAR2,
                     X_Attribute1	                   VARCHAR2,
                     X_Attribute2	                   VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Attribute6                          VARCHAR2,
                     X_Attribute7                          VARCHAR2,
                     X_Attribute8                          VARCHAR2,
                     X_Attribute9                          VARCHAR2,
                     X_Attribute10                         VARCHAR2,
                     X_Attribute11                         VARCHAR2,
                     X_Attribute12                         VARCHAR2,
                     X_Attribute13                         VARCHAR2,
                     X_Attribute14                         VARCHAR2,
                     X_Attribute15                         VARCHAR2,
                     X_Context                             VARCHAR2
		     ) IS
BEGIN
  UPDATE gl_intercompany_acc_sets
  SET
    je_source_name			=    X_Je_Source_Name,
    je_category_name                    =    X_Je_Category_Name,
    ledger_id                           =    X_Ledger_Id,
    balance_by_code			=    X_Balance_By_Code,
    bal_seg_rule_code			=    X_Bal_Seg_Rule_Code,
    always_balance_flag			=    X_Always_Balance_Flag,
    default_bal_seg_value		=    X_Default_Bal_Seg_Value,
    last_update_date                    =    X_Last_Update_Date,
    last_updated_by                     =    X_Last_Updated_By,
    last_update_login                   =    X_Last_Update_Login,
    attribute1                          =    X_Attribute1,
    attribute2                          =    X_Attribute2,
    attribute3                          =    X_Attribute3,
    attribute4                          =    X_Attribute4,
    attribute5                          =    X_Attribute5,
    attribute6                          =    X_Attribute6,
    attribute7                          =    X_Attribute7,
    attribute8                          =    X_Attribute8,
    attribute9                          =    X_Attribute9,
    attribute10                         =    X_Attribute10,
    attribute11                         =    X_Attribute11,
    attribute12                         =    X_Attribute12,
    attribute13                         =    X_Attribute13,
    attribute14                         =    X_Attribute14,
    attribute15                         =    X_Attribute15,
    context                             =    X_Context
  WHERE rowid = X_Rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;

EXCEPTION
  WHEN app_exceptions.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
    fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
    fnd_message.set_token('PROCEDURE',
      'GL_INTERCOMPANY_ACCTS_PKG.Update_Row');
    RAISE;

END Update_Row;

-- **********************************************************************

PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
BEGIN
  DELETE FROM gl_intercompany_acc_sets
  WHERE  rowid = X_Rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;

EXCEPTION
  WHEN app_exceptions.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
    fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
    fnd_message.set_token('PROCEDURE',
      'GL_INTERCOMPANY_ACCTS_PKG.Delete_Row');
    RAISE;

END Delete_Row;

-- **********************************************************************

END GL_INTERCOMPANY_ACCTS_PKG;

/
