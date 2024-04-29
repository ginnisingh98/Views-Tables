--------------------------------------------------------
--  DDL for Package Body ZX_ACCOUNT_TAX_RATES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_ACCOUNT_TAX_RATES_PKG" AS
/* $Header: zxglatrb.pls 120.6 2006/11/10 23:59:40 pla ship $ */

  ---
  --- PRIVATE FUNCTIONS
  ---

  --
  -- Procedure
  --   select_row
  -- Purpose
  --   Gets the row from gl_tax_options associated with
  --   the given ledger id and organization.
  -- History
  --
  -- Arguments
  --   recinfo 		A row from zx_account_rates
  -- Example
  --   gl_tax_options_pkg.select_row(recinfo);
  -- Notes
  --
  PROCEDURE select_row( recinfo IN OUT NOCOPY zx_account_rates%ROWTYPE )  IS
  BEGIN
    SELECT  *
    INTO    recinfo
    FROM    zx_account_rates
    WHERE   ledger_id = recinfo.ledger_id
    AND     content_owner_id = recinfo.content_owner_id;
  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'zx_account_rates.select_row');
      RAISE;
  END select_row;


  --
  -- PUBLIC FUNCTIONS
  --

  PROCEDURE select_columns(
	      x_ledger_id				NUMBER,
	      x_content_owner_id			NUMBER,
	      x_tax_precision			IN OUT NOCOPY	NUMBER,
	      x_tax_mau				IN OUT NOCOPY 	NUMBER) IS

    recinfo zx_account_rates%ROWTYPE;

  BEGIN
    recinfo.ledger_id := x_ledger_id;
    recinfo.content_owner_id := x_content_owner_id;
    select_row( recinfo );
    x_tax_precision := recinfo.tax_precision;
    x_tax_mau := recinfo.tax_mau;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'zx_account_rates.select_columns');
      RAISE;
  END select_columns;


  PROCEDURE duplicate_tax_options ( x_ledger_id	        NUMBER,
 				    x_content_owner_id	NUMBER,
				    x_rowid	        VARCHAR2 ) IS
    x_total 	NUMBER;
  BEGIN
    SELECT count(*)
    INTO x_total
    FROM zx_account_rates
    WHERE ledger_id = x_ledger_id
    AND   content_owner_id = x_content_owner_id
    AND ( x_rowid is null OR rowid <> x_rowid );

    IF (x_total <> 0) THEN
      -- A already record exists for this ledger id and org id
      fnd_message.set_name('SQLGL', 'GL_STAX_DUPLICATE_RECORD');
      app_exception.raise_exception;
    END IF;

  END duplicate_tax_options;


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
                X_CONTENT_OWNER_ID                NUMBER,
                X_ACCOUNT_SEGMENT_VALUE           VARCHAR2,
                X_TAX_PRECISION                   NUMBER,
                X_CALCULATION_LEVEL_CODE          VARCHAR2,
                X_ALLOW_RATE_OVERRIDE_FLAG        VARCHAR2,
                X_TAX_MAU                         NUMBER,
                X_TAX_CURRENCY_CODE               VARCHAR2,
                X_TAX_CLASS                       VARCHAR2,
                X_TAX_REGIME_CODE                 VARCHAR2,
                X_TAX                             VARCHAR2,
                X_TAX_STATUS_CODE                 VARCHAR2,
                X_TAX_RATE_CODE                   VARCHAR2,
                X_ROUNDING_RULE_CODE              VARCHAR2,
                X_AMT_INCL_TAX_FLAG               VARCHAR2,
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
                X_ALLOW_ROUNDING_OVERRIDE_FLAG	  VARCHAR2)  IS
    CURSOR C IS SELECT ROWID FROM ZX_ACCOUNT_RATES
                WHERE LEDGER_ID = X_LEDGER_ID
                AND CONTENT_OWNER_ID = X_CONTENT_OWNER_ID
                AND  (tax_class = X_TAX_CLASS OR
                      (tax_class IS NULL AND X_TAX_CLASS IS NULL) );
    dummy VARCHAR2(30);
  BEGIN
    INSERT INTO ZX_ACCOUNT_RATES
      (ledger_id,
       content_owner_id,
       account_segment_value,
       tax_precision,
       calculation_level_code,
       allow_rate_override_flag,
       tax_mau,
       tax_currency_code,
       tax_class,
       tax_regime_code,
       tax,
       tax_status_code,
       tax_rate_code,
       rounding_rule_code,
       amt_incl_tax_flag,
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
       attribute15,
       allow_rounding_override_flag)
   VALUES
     (X_LEDGER_ID,
      X_CONTENT_OWNER_ID,
      X_ACCOUNT_SEGMENT_VALUE,
      X_TAX_PRECISION,
      X_CALCULATION_LEVEL_CODE,
      X_ALLOW_RATE_OVERRIDE_FLAG,
      X_TAX_MAU,
      X_TAX_CURRENCY_CODE,
      X_TAX_CLASS,
      X_TAX_REGIME_CODE,
      X_TAX,
      X_TAX_STATUS_CODE,
      X_TAX_RATE_CODE,
      X_ROUNDING_RULE_CODE,
      X_AMT_INCL_TAX_FLAG,
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
      X_ATTRIBUTE15,
      X_ALLOW_ROUNDING_OVERRIDE_FLAG);

    OPEN C;
    FETCH C INTO dummy;
    IF (C%NOTFOUND) THEN
      CLOSE C;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE C;

  END insert_row;


  PROCEDURE update_row (
                X_RECORD_LEVEL 			  VARCHAR2,
		    X_LEDGER_ID                       NUMBER,
                X_CONTENT_OWNER_ID                NUMBER,
                X_ACCOUNT_SEGMENT_VALUE           VARCHAR2,
                X_TAX_PRECISION                   NUMBER,
                X_CALCULATION_LEVEL_CODE          VARCHAR2,
                X_ALLOW_RATE_OVERRIDE_FLAG        VARCHAR2,
                X_TAX_MAU                         NUMBER,
                X_TAX_CURRENCY_CODE               VARCHAR2,
                X_TAX_CLASS                       VARCHAR2,
                X_TAX_REGIME_CODE                 VARCHAR2,
                X_TAX                             VARCHAR2,
                X_TAX_STATUS_CODE                 VARCHAR2,
                X_TAX_RATE_CODE                   VARCHAR2,
                X_ROUNDING_RULE_CODE              VARCHAR2,
                X_AMT_INCL_TAX_FLAG               VARCHAR2,
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
                X_ALLOW_ROUNDING_OVERRIDE_FLAG	  VARCHAR2,
                X_CONTENT_OWNER_ID_ORIG           NUMBER,
                X_ACCOUNT_SEGMENT_VALUE_ORIG      VARCHAR2,
                X_TAX_CLASS_ORIG                  VARCHAR2)  IS

 BEGIN

     IF x_record_level = 'LEDGER'  THEN

        /******
	BEGIN

   	   UPDATE ZX_ACCOUNT_RATES
 	      SET tax_currency_code              = X_TAX_CURRENCY_CODE,
		  tax_precision                  = X_TAX_PRECISION,
		  tax_mau                        = X_TAX_MAU,
		  calculation_level_code         = X_CALCULATION_LEVEL_CODE,
                  allow_rounding_override_flag   = X_ALLOW_ROUNDING_OVERRIDE_FLAG
	    WHERE ledger_id             = X_LEDGER_ID
            --AND content_owner_id      = NVL(X_CONTENT_OWNER_ID_ORIG, content_owner_id)
              AND account_segment_value IS NULL
              AND (tax_class IN ('INPUT', 'OUTPUT')
                  OR tax_class is null);


  	EXCEPTION
  	   WHEN OTHERS THEN
	      NULL;
	END;
        ***/

        BEGIN

   	   UPDATE ZX_ACCOUNT_RATES
 	      SET content_owner_id               = X_CONTENT_OWNER_ID,
		  allow_rate_override_flag       = X_ALLOW_RATE_OVERRIDE_FLAG,
	          -- tax_class                      = X_TAX_CLASS,
		  tax_regime_code                = X_TAX_REGIME_CODE,
		  tax                            = X_TAX,
		  tax_status_code                = X_TAX_STATUS_CODE,
		  tax_rate_code                  = X_TAX_RATE_CODE,
		  rounding_rule_code             = X_ROUNDING_RULE_CODE,
		  amt_incl_tax_flag              = X_AMT_INCL_TAX_FLAG,
                  tax_currency_code              = X_TAX_CURRENCY_CODE,
                  tax_precision                  = X_TAX_PRECISION,
                  tax_mau                        = X_TAX_MAU,
                  calculation_level_code         = X_CALCULATION_LEVEL_CODE,
                  allow_rounding_override_flag   = X_ALLOW_ROUNDING_OVERRIDE_FLAG,
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
	    WHERE ledger_id             = X_LEDGER_ID
              AND content_owner_id      = X_CONTENT_OWNER_ID
              AND account_segment_value IS NULL
              AND  (tax_class = X_TAX_CLASS OR
                    (tax_class IS NULL AND X_TAX_CLASS IS NULL ));

	   IF (SQL%NOTFOUND) THEN
	     RAISE NO_DATA_FOUND;
   	   END IF;
  	EXCEPTION
  	   WHEN OTHERS THEN
	      NULL;
	END;

     ELSIF X_RECORD_LEVEL = 'ACCOUNT' then


	    UPDATE ZX_ACCOUNT_RATES
	     	   SET ledger_id                      = X_LEDGER_ID,
	    		content_owner_id               = X_CONTENT_OWNER_ID,
	    		account_segment_value          = X_ACCOUNT_SEGMENT_VALUE,
	    		tax_precision                  = X_TAX_PRECISION,
	    		calculation_level_code         = X_CALCULATION_LEVEL_CODE,
	    		allow_rate_override_flag       = X_ALLOW_RATE_OVERRIDE_FLAG,
	    		tax_mau                        = X_TAX_MAU,
	    		tax_currency_code              = X_TAX_CURRENCY_CODE,
	    		tax_class                      = X_TAX_CLASS,
	    		tax_regime_code                = X_TAX_REGIME_CODE,
	    		tax                            = X_TAX,
	    		tax_status_code                = X_TAX_STATUS_CODE,
	    		tax_rate_code                  = X_TAX_RATE_CODE,
	    		rounding_rule_code             = X_ROUNDING_RULE_CODE,
	    		amt_incl_tax_flag              = X_AMT_INCL_TAX_FLAG,
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
	    		attribute15                    = X_ATTRIBUTE15,
	    		allow_rounding_override_flag   = X_ALLOW_ROUNDING_OVERRIDE_FLAG
	    WHERE  ledger_id             = X_LEDGER_ID
	    AND    content_owner_id      = X_CONTENT_OWNER_ID
	    AND    account_segment_value = X_ACCOUNT_SEGMENT_VALUE
            AND    (tax_class = X_TAX_CLASS OR
                    (tax_class IS NULL AND X_TAX_CLASS IS NULL ));

		IF (SQL%NOTFOUND) THEN
		  RAISE NO_DATA_FOUND;
   		END IF;

	END IF;


  END update_row;


  PROCEDURE lock_row(
                X_RECORD_LEVEL 			  VARCHAR2,
                X_LEDGER_ID                       NUMBER,
                X_CONTENT_OWNER_ID                NUMBER,
                X_ACCOUNT_SEGMENT_VALUE           VARCHAR2,
                X_TAX_PRECISION                   NUMBER,
                X_CALCULATION_LEVEL_CODE          VARCHAR2,
                X_ALLOW_RATE_OVERRIDE_FLAG        VARCHAR2,
                X_TAX_MAU                         NUMBER,
                X_TAX_CURRENCY_CODE               VARCHAR2,
                X_TAX_CLASS                       VARCHAR2,
                X_TAX_REGIME_CODE                 VARCHAR2,
                X_TAX                             VARCHAR2,
                X_TAX_STATUS_CODE                 VARCHAR2,
                X_TAX_RATE_CODE                   VARCHAR2,
                X_ROUNDING_RULE_CODE              VARCHAR2,
                X_AMT_INCL_TAX_FLAG               VARCHAR2,
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
                X_ALLOW_ROUNDING_OVERRIDE_FLAG	  VARCHAR2)  IS
    CURSOR C1 IS
      SELECT *
      FROM ZX_ACCOUNT_RATES
      WHERE ledger_id = X_LEDGER_ID
      AND   content_owner_id = X_CONTENT_OWNER_ID
      AND   account_segment_value is null
      AND  (tax_class = X_TAX_CLASS OR
            (tax_class IS NULL AND X_TAX_CLASS IS NULL ))
      FOR UPDATE OF tax_currency_code NOWAIT;

    CURSOR C2 IS
      SELECT *
      FROM ZX_ACCOUNT_RATES
      WHERE ledger_id = X_LEDGER_ID
        AND content_owner_id = X_CONTENT_OWNER_ID
        AND account_segment_value = X_ACCOUNT_SEGMENT_VALUE
        AND  (tax_class = X_TAX_CLASS OR
            (tax_class IS NULL AND X_TAX_CLASS IS NULL ))


      FOR UPDATE OF tax_currency_code NOWAIT;

    Recinfo1 C1%ROWTYPE;
    Recinfo2 C2%ROWTYPE;
  BEGIN

    IF X_RECORD_LEVEL = 'LEDGER' THEN
      OPEN C1;
      FETCH C1 INTO Recinfo1;
       IF (C1%NOTFOUND) THEN
         CLOSE C1;
           FND_MESSAGE.set_name('FND', 'FORM_RECORD_DELETED');
           APP_EXCEPTION.raise_exception;
        END IF;
      CLOSE C1;

      IF (    (Recinfo1.ledger_id = X_LEDGER_ID)
  	  AND (Recinfo1.content_owner_id = X_CONTENT_OWNER_ID)
	  AND ((Recinfo1.account_segment_value = X_ACCOUNT_SEGMENT_VALUE)
                      OR (X_ACCOUNT_SEGMENT_VALUE IS NULL AND X_ACCOUNT_SEGMENT_VALUE IS NULL))
	  AND (Recinfo1.tax_precision = X_TAX_PRECISION)
	  AND (Recinfo1.calculation_level_code = X_CALCULATION_LEVEL_CODE)
	  AND (Recinfo1.allow_rate_override_flag = X_ALLOW_RATE_OVERRIDE_FLAG)
	        OR (Recinfo1.allow_rate_override_flag IS NULL AND X_ALLOW_RATE_OVERRIDE_FLAG IS NULL)
	  AND (   (Recinfo1.tax_mau = X_TAX_MAU)
	       OR (    (Recinfo1.tax_mau IS NULL)
		 AND (X_TAX_MAU IS NULL)))
	  AND (   (Recinfo1.tax_currency_code = X_TAX_CURRENCY_CODE)
	       OR (    (Recinfo1.tax_currency_code IS NULL)
	  	 AND (X_TAX_CURRENCY_CODE IS NULL)))
	  AND (   (Recinfo1.tax_class = X_TAX_CLASS)
	       OR (    (Recinfo1.tax_class IS NULL)
	  	 AND (X_TAX_CLASS IS NULL)))
	  AND ((Recinfo1.tax_regime_code = X_TAX_REGIME_CODE)
             OR (  X_TAX_REGIME_CODE IS NULL
             AND Recinfo1.tax_regime_code IS NULL) )
	  AND ((Recinfo1.tax = X_TAX)
             OR (  X_TAX IS NULL
             AND Recinfo1.tax IS NULL) )
	  AND ((Recinfo1.tax_status_code = X_TAX_STATUS_CODE)
             OR (X_TAX_STATUS_CODE IS NULL
             AND Recinfo1.tax_status_code IS NULL) )
	  AND ((Recinfo1.tax_rate_code = X_TAX_RATE_CODE)
             OR (X_TAX_RATE_CODE IS NULL
             AND Recinfo1.tax_rate_code IS NULL) )
	  AND (   (Recinfo1.rounding_rule_code = X_ROUNDING_RULE_CODE)
	       OR (    (Recinfo1.rounding_rule_code IS NULL)
	  	 AND (X_ROUNDING_RULE_CODE IS NULL)))
	  AND (   (Recinfo1.amt_incl_tax_flag = X_AMT_INCL_TAX_FLAG)
	       OR (    (Recinfo1.amt_incl_tax_flag IS NULL)
	  	 AND (X_AMT_INCL_TAX_FLAG IS NULL)))
	  AND (   (Recinfo1.record_type_code = X_RECORD_TYPE_CODE)
	       OR (    (Recinfo1.record_type_code IS NULL)
	  	 AND (X_RECORD_TYPE_CODE IS NULL)))
	  AND (   (Recinfo1.attribute_category = X_ATTRIBUTE_CATEGORY)
	       OR (    (Recinfo1.attribute_category IS NULL)
	  	 AND (X_ATTRIBUTE_CATEGORY IS NULL)))
	  AND (   (Recinfo1.attribute1 = X_ATTRIBUTE1)
	       OR (    (Recinfo1.attribute1 IS NULL)
	  	 AND (X_ATTRIBUTE1 IS NULL)))
	  AND (   (Recinfo1.attribute2 = X_ATTRIBUTE2)
	       OR (    (Recinfo1.attribute2 IS NULL)
	  	 AND (X_ATTRIBUTE2 IS NULL)))
	  AND (   (Recinfo1.attribute3 = X_ATTRIBUTE3)
	       OR (    (Recinfo1.attribute3 IS NULL)
	 	 AND (X_ATTRIBUTE3 IS NULL)))
	  AND (   (Recinfo1.attribute4 = X_ATTRIBUTE4)
	       OR (    (Recinfo1.attribute4 IS NULL)
	  	 AND (X_ATTRIBUTE4 IS NULL)))
	  AND (   (Recinfo1.attribute5 = X_ATTRIBUTE5)
	       OR (    (Recinfo1.attribute5 IS NULL)
	  	 AND (X_ATTRIBUTE5 IS NULL)))
	  AND (   (Recinfo1.attribute6 = X_ATTRIBUTE6)
	       OR (    (Recinfo1.attribute6 IS NULL)
		 AND (X_ATTRIBUTE6 IS NULL)))
	  AND (   (Recinfo1.attribute7 = X_ATTRIBUTE7)
	       OR (    (Recinfo1.attribute7 IS NULL)
		 AND (X_ATTRIBUTE7 IS NULL)))
	  AND (   (Recinfo1.attribute8 = X_ATTRIBUTE8)
	       OR (    (Recinfo1.attribute8 IS NULL)
		 AND (X_ATTRIBUTE8 IS NULL)))
	  AND (   (Recinfo1.attribute9 = X_ATTRIBUTE9)
	       OR (    (Recinfo1.attribute9 IS NULL)
	  	 AND (X_ATTRIBUTE9 IS NULL)))
	  AND (   (Recinfo1.attribute10 = X_ATTRIBUTE10)
	       OR (    (Recinfo1.attribute10 IS NULL)
		 AND (X_ATTRIBUTE10 IS NULL)))
	  AND (   (Recinfo1.attribute11 = X_ATTRIBUTE11)
	       OR (    (Recinfo1.attribute11 IS NULL)
		 AND (X_ATTRIBUTE11 IS NULL)))
	  AND (   (Recinfo1.attribute12 = X_ATTRIBUTE12)
	       OR (    (Recinfo1.attribute12 IS NULL)
		 AND (X_ATTRIBUTE12 IS NULL)))
	  AND (   (Recinfo1.attribute13 = X_ATTRIBUTE13)
	       OR (    (Recinfo1.attribute13 IS NULL)
	  	 AND (X_ATTRIBUTE13 IS NULL)))
	  AND (   (Recinfo1.attribute14 = X_ATTRIBUTE14)
	       OR (    (Recinfo1.attribute14 IS NULL)
		 AND (X_ATTRIBUTE14 IS NULL)))
	  AND (   (Recinfo1.attribute15 = X_ATTRIBUTE15)
	       OR (    (Recinfo1.attribute15 IS NULL)
		 AND (X_ATTRIBUTE15 IS NULL)))
	  AND (   (Recinfo1.allow_rounding_override_flag = X_ALLOW_ROUNDING_OVERRIDE_FLAG)
	       OR (    (Recinfo1.allow_rounding_override_flag IS NULL)
		 AND (X_ALLOW_ROUNDING_OVERRIDE_FLAG IS NULL)))
         ) THEN

        RETURN;
      ELSE
        FND_MESSAGE.set_name('FND', 'FORM_RECORD_CHANGED');
        APP_EXCEPTION.raise_exception;
      END IF;


    ELSIF X_RECORD_LEVEL = 'ACCOUNT' THEN
      OPEN C2;
      FETCH C2 INTO Recinfo2;
       IF (C2%NOTFOUND) THEN
         CLOSE C2;
           FND_MESSAGE.set_name('FND', 'FORM_RECORD_DELETED');
           APP_EXCEPTION.raise_exception;
        END IF;
      CLOSE C2;


      IF (    (Recinfo2.ledger_id = X_LEDGER_ID)
  	  AND (Recinfo2.content_owner_id = X_CONTENT_OWNER_ID)
	  AND (Recinfo2.account_segment_value = X_ACCOUNT_SEGMENT_VALUE)
	  AND (Recinfo2.tax_precision = X_TAX_PRECISION)
	  AND (Recinfo2.calculation_level_code = X_CALCULATION_LEVEL_CODE)
	  AND ((Recinfo2.allow_rate_override_flag = X_ALLOW_RATE_OVERRIDE_FLAG)
	        OR (Recinfo2.allow_rate_override_flag IS NULL AND X_ALLOW_RATE_OVERRIDE_FLAG IS NULL))
	  AND (   (Recinfo2.tax_mau = X_TAX_MAU)
	       OR (    (Recinfo2.tax_mau IS NULL)
		 AND (X_TAX_MAU IS NULL)))
	  AND (   (Recinfo2.tax_currency_code = X_TAX_CURRENCY_CODE)
	       OR (    (Recinfo2.tax_currency_code IS NULL)
	  	 AND (X_TAX_CURRENCY_CODE IS NULL)))
	  AND (   (Recinfo2.tax_class = X_TAX_CLASS)
	       OR (    (Recinfo2.tax_class IS NULL)
	  	 AND (X_TAX_CLASS IS NULL)))
	  AND ((Recinfo2.tax_regime_code = X_TAX_REGIME_CODE)
             OR (  X_TAX_REGIME_CODE IS NULL
             AND Recinfo2.tax_regime_code IS NULL) )
	  AND ((Recinfo2.tax = X_TAX)
             OR (  X_TAX IS NULL
             AND Recinfo2.tax IS NULL) )
	  AND ((Recinfo2.tax_status_code = X_TAX_STATUS_CODE)
             OR (X_TAX_STATUS_CODE IS NULL
             AND Recinfo2.tax_status_code IS NULL) )
	  AND ((Recinfo2.tax_rate_code = X_TAX_RATE_CODE)
             OR (X_TAX_RATE_CODE IS NULL
             AND Recinfo2.tax_rate_code IS NULL) )
	  AND ((Recinfo2.rounding_rule_code = X_ROUNDING_RULE_CODE)
	       OR (    (Recinfo2.rounding_rule_code IS NULL)
	  	 AND (X_ROUNDING_RULE_CODE IS NULL)))
	  AND (   (Recinfo2.amt_incl_tax_flag = X_AMT_INCL_TAX_FLAG)
	       OR (    (Recinfo2.amt_incl_tax_flag IS NULL)
	  	 AND (X_AMT_INCL_TAX_FLAG IS NULL)))
	  AND (   (Recinfo2.record_type_code = X_RECORD_TYPE_CODE)
	       OR (    (Recinfo2.record_type_code IS NULL)
	  	 AND (X_RECORD_TYPE_CODE IS NULL)))
	  AND (   (Recinfo2.attribute_category = X_ATTRIBUTE_CATEGORY)
	       OR (    (Recinfo2.attribute_category IS NULL)
	  	 AND (X_ATTRIBUTE_CATEGORY IS NULL)))
	  AND (   (Recinfo2.attribute1 = X_ATTRIBUTE1)
	       OR (    (Recinfo2.attribute1 IS NULL)
	  	 AND (X_ATTRIBUTE1 IS NULL)))
	  AND (   (Recinfo2.attribute2 = X_ATTRIBUTE2)
	       OR (    (Recinfo2.attribute2 IS NULL)
	  	 AND (X_ATTRIBUTE2 IS NULL)))
	  AND (   (Recinfo2.attribute3 = X_ATTRIBUTE3)
	       OR (    (Recinfo2.attribute3 IS NULL)
	 	 AND (X_ATTRIBUTE3 IS NULL)))
	  AND (   (Recinfo2.attribute4 = X_ATTRIBUTE4)
	       OR (    (Recinfo2.attribute4 IS NULL)
	  	 AND (X_ATTRIBUTE4 IS NULL)))
	  AND (   (Recinfo2.attribute5 = X_ATTRIBUTE5)
	       OR (    (Recinfo2.attribute5 IS NULL)
	  	 AND (X_ATTRIBUTE5 IS NULL)))
	  AND (   (Recinfo2.attribute6 = X_ATTRIBUTE6)
	       OR (    (Recinfo2.attribute6 IS NULL)
		 AND (X_ATTRIBUTE6 IS NULL)))
	  AND (   (Recinfo2.attribute7 = X_ATTRIBUTE7)
	       OR (    (Recinfo2.attribute7 IS NULL)
		 AND (X_ATTRIBUTE7 IS NULL)))
	  AND (   (Recinfo2.attribute8 = X_ATTRIBUTE8)
	       OR (    (Recinfo2.attribute8 IS NULL)
		 AND (X_ATTRIBUTE8 IS NULL)))
	  AND (   (Recinfo2.attribute9 = X_ATTRIBUTE9)
	       OR (    (Recinfo2.attribute9 IS NULL)
	  	 AND (X_ATTRIBUTE9 IS NULL)))
	  AND (   (Recinfo2.attribute10 = X_ATTRIBUTE10)
	       OR (    (Recinfo2.attribute10 IS NULL)
		 AND (X_ATTRIBUTE10 IS NULL)))
	  AND (   (Recinfo2.attribute11 = X_ATTRIBUTE11)
	       OR (    (Recinfo2.attribute11 IS NULL)
		 AND (X_ATTRIBUTE11 IS NULL)))
	  AND (   (Recinfo2.attribute12 = X_ATTRIBUTE12)
	       OR (    (Recinfo2.attribute12 IS NULL)
		 AND (X_ATTRIBUTE12 IS NULL)))
	  AND (   (Recinfo2.attribute13 = X_ATTRIBUTE13)
	       OR (    (Recinfo2.attribute13 IS NULL)
	  	 AND (X_ATTRIBUTE13 IS NULL)))
	  AND (   (Recinfo2.attribute14 = X_ATTRIBUTE14)
	       OR (    (Recinfo2.attribute14 IS NULL)
		 AND (X_ATTRIBUTE14 IS NULL)))
	  AND (   (Recinfo2.attribute15 = X_ATTRIBUTE15)
	       OR (    (Recinfo2.attribute15 IS NULL)
		 AND (X_ATTRIBUTE15 IS NULL)))
	  AND (   (Recinfo2.allow_rounding_override_flag = X_ALLOW_ROUNDING_OVERRIDE_FLAG)
	       OR (    (x_allow_rounding_override_flag IS NULL)
		 AND (X_ALLOW_ROUNDING_OVERRIDE_FLAG IS NULL)))
         ) THEN

        RETURN;
      ELSE
        FND_MESSAGE.set_name('FND', 'FORM_RECORD_CHANGED');
        APP_EXCEPTION.raise_exception;
      END IF;
    END IF;


  END lock_row;


END zx_account_tax_rates_pkg;

/
