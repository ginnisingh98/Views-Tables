--------------------------------------------------------
--  DDL for Package Body ZX_ACCT_TAX_CLS_DEFS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_ACCT_TAX_CLS_DEFS_PKG" AS
/* $Header: zxgltcdb.pls 120.1 2005/07/06 12:04:11 mparihar noship $ */

  ---
  --- PRIVATE FUNCTIONS
  ---

  --
  -- Procedure
  --   select_row
  -- Purpose
  --   Gets the row from zx_acct_tax_cls_defs_all associated with
  --   the given ledger id and organization.
  -- History
  --
  -- Arguments
  --   recinfo 		A row from zx_acct_tx_cls_defs_all
  -- Example
  --   zx_acct_tax_cls_defs_pkg.select_row(recinfo);
  -- Notes
  --
  PROCEDURE select_row( recinfo IN OUT NOCOPY zx_acct_tx_cls_defs_all%ROWTYPE )  IS
  BEGIN
    SELECT  *
    INTO    recinfo
    FROM    zx_acct_tx_cls_defs_all
    WHERE   ledger_id = recinfo.ledger_id
    AND     org_id = recinfo.org_id;
  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'zx_acct_tax_cls_defs_all.select_row');
      RAISE;
  END select_row;


  --
  -- PUBLIC FUNCTIONS
  --

  PROCEDURE select_columns(
	      x_ledger_id	             NUMBER,
	      x_org_id			     NUMBER,
	      x_tax_class		     IN OUT NOCOPY	VARCHAr2,
	      x_tax_classification_code	     IN OUT NOCOPY      VARCHAr2) IS

    recinfo zx_acct_tx_cls_defs_all%ROWTYPE;

  BEGIN
    recinfo.ledger_id := x_ledger_id;
    recinfo.org_id := x_org_id;
    select_row( recinfo );
    x_tax_class := recinfo.tax_class;
    x_tax_classification_code := recinfo.tax_classification_code;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'zx_acct_tax_cls_defs_all.select_columns');
      RAISE;
  END select_columns;


  PROCEDURE duplicate_tax_class_code ( x_ledger_id	        NUMBER,
 				       x_org_id	                NUMBER,
				       x_rowid	                VARCHAR2 ) IS
    x_total 	NUMBER;
  BEGIN
    SELECT count(*)
    INTO x_total
    FROM zx_acct_tx_cls_defs_all
    WHERE ledger_id = x_ledger_id
    AND   org_id = x_org_id
    AND ( x_rowid is null OR rowid <> x_rowid );

    IF (x_total <> 0) THEN
      -- A already record exists for this ledger id and org id
      fnd_message.set_name('SQLGL', 'GL_STAX_DUPLICATE_RECORD');
      app_exception.raise_exception;
    END IF;

  END duplicate_tax_class_code;


  PROCEDURE org_name ( x_org_id		NUMBER,
		       x_org_name	IN OUT NOCOPY	VARCHAR2 ) IS
    org_cursor	NUMBER;
    row_count   NUMBER;
  BEGIN

    org_cursor := dbms_sql.open_cursor;
    dbms_sql.parse(org_cursor,
		   'SELECT name ' ||
		   'FROM hr_operating_units ' ||
		   'WHERE organization_id = :org_id ',
		   dbms_sql.v7);
    dbms_sql.define_column(org_cursor, 1, x_org_name, 240);
    dbms_sql.bind_variable(org_cursor, ':org_id', x_org_id);

    row_count := dbms_sql.execute_and_fetch(org_cursor);
    IF (row_count = 0) THEN
      RAISE NO_DATA_FOUND;
    END IF;

    dbms_sql.column_value(org_cursor, 1, x_org_name);
    dbms_sql.close_cursor(org_cursor);
  END org_name;


  PROCEDURE insert_row(
                X_LEDGER_ID                       NUMBER,
                X_ORG_ID                          NUMBER,
                X_ACCOUNT_SEGMENT_VALUE           VARCHAR2,
                X_TAX_CLASS                       VARCHAR2,
                X_TAX_CLASSIFICATION_CODE         VARCHAR2,
                X_ALLOW_TAX_CODE_OVERRIDE_FLAG    VARCHAR2,
                X_RECORD_TYPE_CODE                VARCHAR2,
                X_CREATION_DATE                   DATE,
                X_CREATED_BY                      NUMBER,
                X_LAST_UPDATED_BY                 NUMBER,
                X_LAST_UPDATE_DATE                DATE,
                X_LAST_UPDATE_LOGIN               NUMBER,
                X_ATTRIBUTE_CATEGORY              VARCHAR2,
                X_ATTRIBUTE1                      VARCHAR2,
                X_ATTRIBUTE2                      VARCHAR2,
                X_ATTRIBUTE3                      VARCHAR2,
                X_ATTRIBUTE4                      VARCHAR2,
                X_ATTRIBUTE5                      VARCHAR2,
                X_ATTRIBUTE6                      VARCHAR2,
                X_ATTRIBUTE7                      VARCHAR2,
                X_ATTRIBUTE8                      VARCHAR2,
                X_ATTRIBUTE9                      VARCHAR2,
                X_ATTRIBUTE10                     VARCHAR2,
                X_ATTRIBUTE11                     VARCHAR2,
                X_ATTRIBUTE12                     VARCHAR2,
                X_ATTRIBUTE13                     VARCHAR2,
                X_ATTRIBUTE14                     VARCHAR2,
                X_ATTRIBUTE15                     VARCHAR2)  IS
    CURSOR C IS SELECT ROWID FROM ZX_ACCT_TX_CLS_DEFS_ALL
                WHERE LEDGER_ID = X_LEDGER_ID
                AND ORG_ID = X_ORG_ID;
    dummy VARCHAR2(30);
  BEGIN
    INSERT INTO ZX_ACCT_TX_CLS_DEFS_ALL
      (ledger_id,
       org_id,
       account_segment_value,
       tax_class,
       tax_classification_code,
       allow_tax_code_override_flag,
       record_type_code,
       creation_date,
       created_by,
       last_updated_by,
       last_update_date,
       last_update_login,
       attribute_category,
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
       attribute15)
   VALUES
     (X_LEDGER_ID,
      X_ORG_ID,
      X_ACCOUNT_SEGMENT_VALUE,
      X_TAX_CLASS,
      X_TAX_CLASSIFICATION_CODE,
      X_ALLOW_TAX_CODE_OVERRIDE_FLAG,
      X_RECORD_TYPE_CODE,
      X_CREATION_DATE,
      X_CREATED_BY,
      X_LAST_UPDATED_BY,
      X_LAST_UPDATE_DATE,
      X_LAST_UPDATE_LOGIN,
      X_ATTRIBUTE_CATEGORY,
      X_ATTRIBUTE1,
      X_ATTRIBUTE2,
      X_ATTRIBUTE3,
      X_ATTRIBUTE4,
      X_ATTRIBUTE5,
      X_ATTRIBUTE6,
      X_ATTRIBUTE7,
      X_ATTRIBUTE8,
      X_ATTRIBUTE9,
      X_ATTRIBUTE10,
      X_ATTRIBUTE11,
      X_ATTRIBUTE12,
      X_ATTRIBUTE13,
      X_ATTRIBUTE14,
      X_ATTRIBUTE15);

    OPEN C;
    FETCH C INTO dummy;
    IF (C%NOTFOUND) THEN
      CLOSE C;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE C;

  END insert_row;


  PROCEDURE update_row(
                X_LEDGER_ID                       NUMBER,
                X_ORG_ID                          NUMBER,
                X_ACCOUNT_SEGMENT_VALUE           VARCHAR2,
                X_TAX_CLASS                       VARCHAR2,
                X_TAX_CLASSIFICATION_CODE         VARCHAR2,
                X_ALLOW_TAX_CODE_OVERRIDE_FLAG    VARCHAR2,
                X_RECORD_TYPE_CODE                VARCHAR2,
                X_CREATION_DATE                   DATE,
                X_CREATED_BY                      NUMBER,
                X_LAST_UPDATED_BY                 NUMBER,
                X_LAST_UPDATE_DATE                DATE,
                X_LAST_UPDATE_LOGIN               NUMBER,
                X_ATTRIBUTE_CATEGORY              VARCHAR2,
                X_ATTRIBUTE1                      VARCHAR2,
                X_ATTRIBUTE2                      VARCHAR2,
                X_ATTRIBUTE3                      VARCHAR2,
                X_ATTRIBUTE4                      VARCHAR2,
                X_ATTRIBUTE5                      VARCHAR2,
                X_ATTRIBUTE6                      VARCHAR2,
                X_ATTRIBUTE7                      VARCHAR2,
                X_ATTRIBUTE8                      VARCHAR2,
                X_ATTRIBUTE9                      VARCHAR2,
                X_ATTRIBUTE10                     VARCHAR2,
                X_ATTRIBUTE11                     VARCHAR2,
                X_ATTRIBUTE12                     VARCHAR2,
                X_ATTRIBUTE13                     VARCHAR2,
                X_ATTRIBUTE14                     VARCHAR2,
                X_ATTRIBUTE15                     VARCHAR2,
                X_ACCOUNT_SEGMENT_VALUE_ORIG      VARCHAR2,
                X_TAX_CLASS_ORIG		  VARCHAR2)  IS
  BEGIN
    UPDATE ZX_ACCT_TX_CLS_DEFS_ALL
    SET ledger_id                      = X_LEDGER_ID,
        org_id                         = X_ORG_ID,
        account_segment_value          = X_ACCOUNT_SEGMENT_VALUE,
        tax_class                      = X_TAX_CLASS,
        tax_classification_code        = X_TAX_CLASSIFICATION_CODE,
        allow_tax_code_override_flag   = X_ALLOW_TAX_CODE_OVERRIDE_FLAG,
        record_type_code               = X_RECORD_TYPE_CODE,
        creation_date                  = X_CREATION_DATE,
        created_by                     = X_CREATED_BY,
        last_updated_by                = X_LAST_UPDATED_BY,
        last_update_date               = X_LAST_UPDATE_DATE,
        last_update_login              = X_LAST_UPDATE_LOGIN,
        attribute_category             = X_ATTRIBUTE_CATEGORY,
        attribute1                     = X_ATTRIBUTE1,
        attribute2                     = X_ATTRIBUTE2,
        attribute3                     = X_ATTRIBUTE3,
        attribute4                     = X_ATTRIBUTE4,
        attribute5                     = X_ATTRIBUTE5,
        attribute6                     = X_ATTRIBUTE6,
        attribute7                     = X_ATTRIBUTE7,
        attribute8                     = X_ATTRIBUTE8,
        attribute9                     = X_ATTRIBUTE9,
        attribute10                    = X_ATTRIBUTE10,
        attribute11                    = X_ATTRIBUTE11,
        attribute12                    = X_ATTRIBUTE12,
        attribute13                    = X_ATTRIBUTE13,
        attribute14                    = X_ATTRIBUTE14,
        attribute15                    = X_ATTRIBUTE15
  WHERE  ledger_id		= X_LEDGER_ID
  AND    org_id			= X_ORG_ID
  AND   account_segment_value	= X_ACCOUNT_SEGMENT_VALUE_ORIG
  AND   tax_class		= X_TAX_CLASS_ORIG;

   IF (SQL%NOTFOUND) THEN
     RAISE NO_DATA_FOUND;
   END IF;

  END update_row;


  PROCEDURE lock_row(
                X_LEDGER_ID                       NUMBER,
                X_ORG_ID                          NUMBER,
                X_ACCOUNT_SEGMENT_VALUE           VARCHAR2,
                X_TAX_CLASS                       VARCHAR2,
                X_TAX_CLASSIFICATION_CODE         VARCHAR2,
                X_ALLOW_TAX_CODE_OVERRIDE_FLAG    VARCHAR2,
                X_RECORD_TYPE_CODE                VARCHAR2,
                X_CREATION_DATE                   DATE,
                X_CREATED_BY                      NUMBER,
                X_LAST_UPDATED_BY                 NUMBER,
                X_LAST_UPDATE_DATE                DATE,
                X_LAST_UPDATE_LOGIN               NUMBER,
                X_ATTRIBUTE_CATEGORY              VARCHAR2,
                X_ATTRIBUTE1                      VARCHAR2,
                X_ATTRIBUTE2                      VARCHAR2,
                X_ATTRIBUTE3                      VARCHAR2,
                X_ATTRIBUTE4                      VARCHAR2,
                X_ATTRIBUTE5                      VARCHAR2,
                X_ATTRIBUTE6                      VARCHAR2,
                X_ATTRIBUTE7                      VARCHAR2,
                X_ATTRIBUTE8                      VARCHAR2,
                X_ATTRIBUTE9                      VARCHAR2,
                X_ATTRIBUTE10                     VARCHAR2,
                X_ATTRIBUTE11                     VARCHAR2,
                X_ATTRIBUTE12                     VARCHAR2,
                X_ATTRIBUTE13                     VARCHAR2,
                X_ATTRIBUTE14                     VARCHAR2,
                X_ATTRIBUTE15                     VARCHAR2)  IS
    CURSOR C IS
      SELECT *
      FROM ZX_ACCT_TX_CLS_DEFS_ALL
      WHERE ledger_id = X_LEDGER_ID
      AND   org_id = X_ORG_ID
      AND   account_segment_value = X_ACCOUNT_SEGMENT_VALUE
      AND   tax_class = X_TAX_CLASS
      FOR UPDATE OF tax_classification_code NOWAIT;
    Recinfo C%ROWTYPE;
  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    IF (C%NOTFOUND) THEN
      CLOSE C;
      FND_MESSAGE.set_name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.raise_exception;
    END IF;
    CLOSE C;

    IF (    (Recinfo.ledger_id = X_LEDGER_ID)
	AND (   (Recinfo.org_id = X_ORG_ID)
	     OR (    (Recinfo.org_id IS NULL)
		 AND (X_ORG_ID IS NULL)))
	AND (Recinfo.account_segment_value = X_ACCOUNT_SEGMENT_VALUE)
	AND (   (Recinfo.tax_class = X_TAX_CLASS)
	     OR (    (Recinfo.tax_class IS NULL)
		 AND (X_TAX_CLASS IS NULL)))
	AND (   (Recinfo.tax_classification_code = X_TAX_CLASSIFICATION_CODE)
	     OR (    (Recinfo.tax_classification_code IS NULL)
		 AND (X_TAX_CLASSIFICATION_CODE IS NULL)))
	AND (   (Recinfo.allow_tax_code_override_flag = X_ALLOW_TAX_CODE_OVERRIDE_FLAG)
	     OR (    (Recinfo.allow_tax_code_override_flag IS NULL)
		 AND (X_ALLOW_TAX_CODE_OVERRIDE_FLAG IS NULL)))
	AND (   (Recinfo.record_type_code = X_RECORD_TYPE_CODE)
	     OR (    (Recinfo.record_type_code IS NULL)
		 AND (X_RECORD_TYPE_CODE IS NULL)))
	AND (   (Recinfo.attribute_category = X_ATTRIBUTE_CATEGORY)
	     OR (    (Recinfo.attribute_category IS NULL)
		 AND (X_ATTRIBUTE_CATEGORY IS NULL)))
	AND (   (Recinfo.attribute1 = X_ATTRIBUTE1)
	     OR (    (Recinfo.attribute1 IS NULL)
		 AND (X_ATTRIBUTE1 IS NULL)))
	AND (   (Recinfo.attribute2 = X_ATTRIBUTE2)
	     OR (    (Recinfo.attribute2 IS NULL)
		 AND (X_ATTRIBUTE2 IS NULL)))
	AND (   (Recinfo.attribute3 = X_ATTRIBUTE3)
	     OR (    (Recinfo.attribute3 IS NULL)
		 AND (X_ATTRIBUTE3 IS NULL)))
	AND (   (Recinfo.attribute4 = X_ATTRIBUTE4)
	     OR (    (Recinfo.attribute4 IS NULL)
		 AND (X_ATTRIBUTE4 IS NULL)))
	AND (   (Recinfo.attribute5 = X_ATTRIBUTE5)
	     OR (    (Recinfo.attribute5 IS NULL)
		 AND (X_ATTRIBUTE5 IS NULL)))
	AND (   (Recinfo.attribute6 = X_ATTRIBUTE6)
	     OR (    (Recinfo.attribute6 IS NULL)
		 AND (X_ATTRIBUTE6 IS NULL)))
	AND (   (Recinfo.attribute7 = X_ATTRIBUTE7)
	     OR (    (Recinfo.attribute7 IS NULL)
		 AND (X_ATTRIBUTE7 IS NULL)))
	AND (   (Recinfo.attribute8 = X_ATTRIBUTE8)
	     OR (    (Recinfo.attribute8 IS NULL)
		 AND (X_ATTRIBUTE8 IS NULL)))
	AND (   (Recinfo.attribute9 = X_ATTRIBUTE9)
	     OR (    (Recinfo.attribute9 IS NULL)
		 AND (X_ATTRIBUTE9 IS NULL)))
	AND (   (Recinfo.attribute10 = X_ATTRIBUTE10)
	     OR (    (Recinfo.attribute10 IS NULL)
		 AND (X_ATTRIBUTE10 IS NULL)))
	AND (   (Recinfo.attribute11 = X_ATTRIBUTE11)
	     OR (    (Recinfo.attribute11 IS NULL)
		 AND (X_ATTRIBUTE11 IS NULL)))
	AND (   (Recinfo.attribute12 = X_ATTRIBUTE12)
	     OR (    (Recinfo.attribute12 IS NULL)
		 AND (X_ATTRIBUTE12 IS NULL)))
	AND (   (Recinfo.attribute13 = X_ATTRIBUTE13)
	     OR (    (Recinfo.attribute13 IS NULL)
		 AND (X_ATTRIBUTE13 IS NULL)))
	AND (   (Recinfo.attribute14 = X_ATTRIBUTE14)
	     OR (    (Recinfo.attribute14 IS NULL)
		 AND (X_ATTRIBUTE14 IS NULL)))
	AND (   (Recinfo.attribute15 = X_ATTRIBUTE15)
	     OR (    (Recinfo.attribute15 IS NULL)
		 AND (X_ATTRIBUTE15 IS NULL)))
       ) THEN
      RETURN;
    ELSE
      FND_MESSAGE.set_name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.raise_exception;
    END IF;

  END lock_row;


END zx_acct_tax_cls_defs_pkg;

/
