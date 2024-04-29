--------------------------------------------------------
--  DDL for Package Body GL_DAILY_RATES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_DAILY_RATES_PKG" as
/* $Header: glirtdyb.pls 120.10 2005/05/05 01:21:06 kvora ship $ */
--
-- Package
--   gl_daily_rates_pkg
-- Purpose
--   To contain validation and insertion routines for gl_daily_rates
-- History
--   07-29-97	W Wong		Created

  --
  -- Procedure
  --  Insert_Row
  --
  -- Purpose
  --   Inserts two rows into gl_daily_rates:
  --   one for the original conversion rate ( From Currency -> To Currency )
  --   one for the inverse conversion rate  ( To Currency   -> From Currency )
  --
  -- History
  --   07-29-97	W Wong		Created
  --
  -- Arguments
  --   All the columns of the table GL_DAILY_RATES and
  --   X_Average_Balances_Used	 		Average Balances Used
  --   X_Euro_Currency				Currency Code of EURO
  --
  -- Example
  --   gl_daily_rates.Insert_Row(....);
  --
  -- Notes
  --
PROCEDURE Insert_Row(X_Rowid                         IN OUT NOCOPY VARCHAR2,
		     X_Inverse_Rowid                 IN OUT NOCOPY VARCHAR2,
                     X_From_Currency                        VARCHAR2,
                     X_To_Currency                          VARCHAR2,
                     X_Conversion_Date                      DATE,
                     X_Conversion_Type                      VARCHAR2,
                     X_Conversion_Rate                      NUMBER,
                     X_Inverse_Conversion_Rate              NUMBER,
		     X_Status_Code        	     IN OUT NOCOPY VARCHAR2,
                     X_Creation_Date                        DATE,
                     X_Created_By                           NUMBER,
                     X_Last_Update_Date                     DATE,
                     X_Last_Updated_By                      NUMBER,
                     X_Last_Update_Login                    NUMBER,
                     X_Context                              VARCHAR2,
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
		     X_Average_Balances_Used		    VARCHAR2,
		     X_Euro_Currency			    VARCHAR2
 ) IS
   CURSOR C IS SELECT rowid FROM GL_DAILY_RATES
             WHERE from_currency   = X_From_Currency
             AND   to_currency     = X_To_Currency
             AND   conversion_date = X_Conversion_Date
             AND   conversion_type = X_Conversion_Type;

   CURSOR Inverse_C IS SELECT rowid FROM GL_DAILY_RATES
             WHERE from_currency   = X_To_Currency
             AND   to_currency     = X_From_Currency
             AND   conversion_date = X_Conversion_Date
             AND   conversion_type = X_Conversion_Type;

    ekey    VARCHAR2(100);
BEGIN
  --
  -- Set the status code to 'O' if the X_To_Currency and X_Conversion_Type is
  -- used in ledgers.
  -- Set status code to 'C' otherwise.
  --
  IF ( GL_DAILY_RATES_PKG.Used_In_Ledger( X_From_Currency,
					  X_To_Currency,
	 			          X_Conversion_Type,
					  X_Euro_Currency,
					  X_Conversion_Date )) THEN
    X_Status_Code := 'O';

  ELSE
    X_Status_Code := 'C';
  END IF;

  -- Insert the row with conversion rate
  INSERT INTO GL_DAILY_RATES(
	  from_currency,
	  to_currency,
	  conversion_date,
	  conversion_type,
	  conversion_rate,
	  status_code,
	  creation_date,
	  created_by,
	  last_update_date,
	  last_updated_by,
	  last_update_login,
	  context,
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
	  attribute15
        ) VALUES (
	  X_From_Currency,
	  X_To_Currency,
	  X_Conversion_Date,
	  X_Conversion_Type,
	  X_Conversion_Rate,
	  X_Status_Code,
	  X_Creation_Date,
	  X_Created_By,
	  X_Last_Update_Date,
	  X_Last_Updated_By,
	  X_Last_Update_Login,
	  X_Context,
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
	  X_Attribute15
	);

  OPEN C;
  FETCH C INTO X_Rowid;
  if ( C%NOTFOUND ) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;

  -- Insert the row with new inverse conversion rate
  INSERT INTO GL_DAILY_RATES(
	  from_currency,
	  to_currency,
	  conversion_date,
	  conversion_type,
	  conversion_rate,
	  status_code,
	  creation_date,
	  created_by,
	  last_update_date,
	  last_updated_by,
	  last_update_login,
	  context,
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
	  attribute15
        ) VALUES (
	  X_To_Currency,
	  X_From_Currency,
	  X_Conversion_Date,
	  X_Conversion_Type,
	  X_Inverse_Conversion_Rate,
	  X_Status_Code,
	  X_Creation_Date,
	  X_Created_By,
	  X_Last_Update_Date,
	  X_Last_Updated_By,
	  X_Last_Update_Login,
	  X_Context,
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
	  X_Attribute15
	);

  OPEN Inverse_C;
  FETCH Inverse_C INTO X_Inverse_Rowid;
  if ( Inverse_C%NOTFOUND ) then
    CLOSE Inverse_C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE Inverse_C;

  ekey := X_From_Currency||':'||X_To_Currency||':'||X_Conversion_Type||':'
         ||to_char(X_Conversion_Date,'RRDDDSSSSS')||':'
         ||to_char(X_Conversion_date,'RRDDDSSSSS')||':'
         ||to_char(sysdate, 'RRDDDSSSSS');

  -- Raise the specify conversion event
  gl_business_events.raise(
    p_event_name => 'oracle.apps.gl.CurrencyConversionRates.dailyRate.specify',
    p_event_key => ekey,
    p_parameter_name1 => 'FROM_CURRENCY',
    p_parameter_value1 => X_From_Currency,
    p_parameter_name2 => 'TO_CURRENCY',
    p_parameter_value2 => X_To_Currency,
    p_parameter_name3 => 'FROM_CONVERSION_DATE',
    p_parameter_value3 => to_char(X_Conversion_Date,'YYYY/MM/DD'),
    p_parameter_name4 => 'FROM_CONVERSION_DATE',
    p_parameter_value4 => to_char(X_Conversion_Date,'YYYY/MM/DD'),
    p_parameter_name5 => 'CONVERSION_TYPE',
    p_parameter_value5 => X_Conversion_Type,
    p_parameter_name6 => 'CONVERSION_RATE',
    p_parameter_value6 => to_char(X_Conversion_Rate,
                           '99999999999999999999.99999999999999999999'),
    p_parameter_name7 => 'INVERSE_CONVERSION_RATE',
    p_parameter_value7 => to_char(X_Inverse_Conversion_Rate,
                           '99999999999999999999.99999999999999999999')
    );

END Insert_Row;


  --
  -- Procedure
  --  Lock_Row
  --
  -- Purpose
  --   Locks a pair of rows in gl_daily_rates
  --
  -- History
  --   07-29-97	W Wong		Created
  --
  -- Arguments
  --   All the columns of the table GL_DAILY_RATES
  --
  -- Example
  --   gl_daily_rates.Lock_Row(....);
  --
  -- Notes
  --
PROCEDURE Lock_Row(X_Rowid                                VARCHAR2,
		   X_Inverse_Rowid			  VARCHAR2,
                   X_From_Currency                        VARCHAR2,
                   X_To_Currency                          VARCHAR2,
                   X_Conversion_Date                      DATE,
                   X_Conversion_Type                      VARCHAR2,
                   X_Conversion_Rate                      NUMBER,
                   X_Inverse_Conversion_Rate              NUMBER,
		   X_Status_Code        		  VARCHAR2,
                   X_Creation_Date                        DATE,
                   X_Created_By                           NUMBER,
                   X_Last_Update_Date                     DATE,
                   X_Last_Updated_By                      NUMBER,
                   X_Last_Update_Login                    NUMBER,
                   X_Context                              VARCHAR2,
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
                   X_Attribute15                          VARCHAR2
) IS

  CURSOR C IS
      SELECT *
      FROM   GL_DAILY_RATES
      WHERE  rowid = X_Rowid
      FOR UPDATE of from_currency NOWAIT;
  Recinfo C%ROWTYPE;

  CURSOR Inverse_C IS
      SELECT *
      FROM   GL_DAILY_RATES
      WHERE  rowid = X_Inverse_Rowid
      FOR UPDATE of from_currency NOWAIT;
  Inverse_Recinfo Inverse_C%ROWTYPE;

BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
  if ( C%NOTFOUND ) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;

  if (
          ((Recinfo.from_currency = X_From_Currency) OR
           (     (Recinfo.from_currency IS NULL)
             AND (X_From_Currency IS NULL)))
      AND ((Recinfo.to_currency = X_To_Currency) OR
           (     (Recinfo.to_currency IS NULL)
             AND (X_To_Currency IS NULL)))
      AND ((Recinfo.conversion_date = X_Conversion_Date) OR
           (     (Recinfo.conversion_date IS NULL)
             AND (X_Conversion_Date IS NULL)))
      AND ((Recinfo.conversion_type = X_Conversion_Type) OR
           (     (Recinfo.conversion_type IS NULL)
             AND (X_Conversion_Type IS NULL)))
      AND ((Recinfo.conversion_rate = X_Conversion_Rate) OR
           (     (Recinfo.conversion_rate IS NULL)
             AND (X_Conversion_Rate IS NULL)))
      AND ((Recinfo.status_code = X_Status_Code) OR
           (     (Recinfo.status_code IS NULL)
             AND (X_Status_Code IS NULL)))
      AND ((Recinfo.context = X_Context) OR
           (     (Recinfo.context IS NULL)
             AND (X_Context IS NULL)))
      AND ((Recinfo.attribute1 = X_Attribute1) OR
           (     (Recinfo.attribute1 IS NULL)
             AND (X_Attribute1 IS NULL)))
      AND ((Recinfo.attribute2 = X_Attribute2) OR
           (     (Recinfo.attribute2 IS NULL)
             AND (X_Attribute2 IS NULL)))
      AND ((Recinfo.attribute3 = X_Attribute3) OR
           (     (Recinfo.attribute3 IS NULL)
             AND (X_Attribute3 IS NULL)))
      AND ((Recinfo.attribute4 = X_Attribute4) OR
           (     (Recinfo.attribute4 IS NULL)
             AND (X_Attribute4 IS NULL)))
      AND ((Recinfo.attribute5 = X_Attribute5) OR
           (     (Recinfo.attribute5 IS NULL)
             AND (X_Attribute5 IS NULL)))
      AND ((Recinfo.attribute6 = X_Attribute6) OR
           (     (Recinfo.attribute6 IS NULL)
             AND (X_Attribute6 IS NULL)))
      AND ((Recinfo.attribute7 = X_Attribute7) OR
           (     (Recinfo.attribute7 IS NULL)
             AND (X_Attribute7 IS NULL)))
      AND ((Recinfo.attribute8 = X_Attribute8) OR
           (     (Recinfo.attribute8 IS NULL)
             AND (X_Attribute8 IS NULL)))
      AND ((Recinfo.attribute9 = X_Attribute9) OR
           (     (Recinfo.attribute9 IS NULL)
             AND (X_Attribute9 IS NULL)))
      AND ((Recinfo.attribute10 = X_Attribute10) OR
           (     (Recinfo.attribute10 IS NULL)
             AND (X_Attribute10 IS NULL)))
      AND ((Recinfo.attribute11 = X_Attribute11) OR
           (     (Recinfo.attribute11 IS NULL)
             AND (X_Attribute11 IS NULL)))
      AND ((Recinfo.attribute12 = X_Attribute12) OR
           (     (Recinfo.attribute12 IS NULL)
             AND (X_Attribute12 IS NULL)))
      AND ((Recinfo.attribute13 = X_Attribute13) OR
           (     (Recinfo.attribute13 IS NULL)
             AND (X_Attribute13 IS NULL)))
      AND ((Recinfo.attribute14 = X_Attribute14) OR
           (     (Recinfo.attribute14 IS NULL)
             AND (X_Attribute14 IS NULL)))
      AND ((Recinfo.attribute15 = X_Attribute15) OR
           (     (Recinfo.attribute15 IS NULL)
             AND (X_Attribute15 IS NULL)))
     ) then
    return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;


  OPEN Inverse_C;
  FETCH Inverse_C INTO Inverse_Recinfo;
  if ( Inverse_C%NOTFOUND ) then
    CLOSE Inverse_C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE Inverse_C;

  if (
          ((Inverse_Recinfo.from_currency = X_From_Currency) OR
           (     (Inverse_Recinfo.from_currency IS NULL)
             AND (X_From_Currency IS NULL)))
      AND ((Inverse_Recinfo.to_currency = X_To_Currency) OR
           (     (Inverse_Recinfo.to_currency IS NULL)
             AND (X_To_Currency IS NULL)))
      AND ((Inverse_Recinfo.conversion_date = X_Conversion_Date) OR
           (     (Inverse_Recinfo.conversion_date IS NULL)
             AND (X_Conversion_Date IS NULL)))
      AND ((Inverse_Recinfo.conversion_type = X_Conversion_Type) OR
           (     (Inverse_Recinfo.conversion_type IS NULL)
             AND (X_Conversion_Type IS NULL)))
      AND ((Inverse_Recinfo.conversion_rate = X_Inverse_Conversion_Rate) OR
           (     (Inverse_Recinfo.conversion_rate IS NULL)
             AND (X_Inverse_Conversion_Rate IS NULL)))
      AND ((Inverse_Recinfo.status_code = X_Status_Code) OR
           (     (Inverse_Recinfo.status_code IS NULL)
             AND (X_Status_Code IS NULL)))
      AND ((Inverse_Recinfo.context = X_Context) OR
           (     (Inverse_Recinfo.context IS NULL)
             AND (X_Context IS NULL)))
      AND ((Inverse_Recinfo.attribute1 = X_Attribute1) OR
           (     (Inverse_Recinfo.attribute1 IS NULL)
             AND (X_Attribute1 IS NULL)))
      AND ((Inverse_Recinfo.attribute2 = X_Attribute2) OR
           (     (Inverse_Recinfo.attribute2 IS NULL)
             AND (X_Attribute2 IS NULL)))
      AND ((Inverse_Recinfo.attribute3 = X_Attribute3) OR
           (     (Inverse_Recinfo.attribute3 IS NULL)
             AND (X_Attribute3 IS NULL)))
      AND ((Inverse_Recinfo.attribute4 = X_Attribute4) OR
           (     (Inverse_Recinfo.attribute4 IS NULL)
             AND (X_Attribute4 IS NULL)))
      AND ((Inverse_Recinfo.attribute5 = X_Attribute5) OR
           (     (Inverse_Recinfo.attribute5 IS NULL)
             AND (X_Attribute5 IS NULL)))
      AND ((Inverse_Recinfo.attribute6 = X_Attribute6) OR
           (     (Inverse_Recinfo.attribute6 IS NULL)
             AND (X_Attribute6 IS NULL)))
      AND ((Inverse_Recinfo.attribute7 = X_Attribute7) OR
           (     (Inverse_Recinfo.attribute7 IS NULL)
             AND (X_Attribute7 IS NULL)))
      AND ((Inverse_Recinfo.attribute8 = X_Attribute8) OR
           (     (Inverse_Recinfo.attribute8 IS NULL)
             AND (X_Attribute8 IS NULL)))
      AND ((Inverse_Recinfo.attribute9 = X_Attribute9) OR
           (     (Inverse_Recinfo.attribute9 IS NULL)
             AND (X_Attribute9 IS NULL)))
      AND ((Inverse_Recinfo.attribute10 = X_Attribute10) OR
           (     (Inverse_Recinfo.attribute10 IS NULL)
             AND (X_Attribute10 IS NULL)))
      AND ((Inverse_Recinfo.attribute11 = X_Attribute11) OR
           (     (Inverse_Recinfo.attribute11 IS NULL)
             AND (X_Attribute11 IS NULL)))
      AND ((Inverse_Recinfo.attribute12 = X_Attribute12) OR
           (     (Inverse_Recinfo.attribute12 IS NULL)
             AND (X_Attribute12 IS NULL)))
      AND ((Inverse_Recinfo.attribute13 = X_Attribute13) OR
           (     (Inverse_Recinfo.attribute13 IS NULL)
             AND (X_Attribute13 IS NULL)))
      AND ((Inverse_Recinfo.attribute14 = X_Attribute14) OR
           (     (Inverse_Recinfo.attribute14 IS NULL)
             AND (X_Attribute14 IS NULL)))
      AND ((Inverse_Recinfo.attribute15 = X_Attribute15) OR
           (     (Inverse_Recinfo.attribute15 IS NULL)
             AND (X_Attribute15 IS NULL)))
     ) then
    return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;

END Lock_Row;


  --
  -- Procedure
  --
  --  Update_Row
  --
  -- Purpose
  --   Updates a pair of rows in gl_daily_rates.
  --
  -- History
  --   07-29-97	W Wong		Created
  --
  -- Arguments
  --   All the columns of the table GL_DAILY_RATES and
  --   X_Average_Balances_Used	 		Average Balances Used
  --   X_Euro_Currency				Currency Code of EURO
  --
  -- Example
  --   gl_daily_rates.Update_Row(....);
  --
  -- Notes
  --
PROCEDURE Update_Row(X_Rowid                                VARCHAR2,
                     X_Inverse_Rowid                        VARCHAR2,
                     X_From_Currency                        VARCHAR2,
                     X_To_Currency                          VARCHAR2,
                     X_Conversion_Date                      DATE,
                     X_Conversion_Type                      VARCHAR2,
                     X_Conversion_Rate                      NUMBER,
                     X_Inverse_Conversion_Rate              NUMBER,
		     X_Status_Code        	     IN OUT NOCOPY VARCHAR2,
                     X_Creation_Date                        DATE,
                     X_Created_By                           NUMBER,
                     X_Last_Update_Date                     DATE,
                     X_Last_Updated_By                      NUMBER,
                     X_Last_Update_Login                    NUMBER,
                     X_Context                              VARCHAR2,
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
		     X_Average_Balances_Used		    VARCHAR2,
		     X_Euro_Currency			    VARCHAR2
) IS
    ekey    VARCHAR2(100);
BEGIN
  -- Set the status code to 'O' if the X_To_Currency and X_Conversion_Type is
  -- used in ledgers.
  IF ( X_Status_Code <> 'O' ) THEN
    IF ( GL_DAILY_RATES_PKG.Used_In_Ledger( X_From_Currency,
	  			            X_To_Currency,
	 			            X_Conversion_Type,
				            X_Euro_Currency,
					    X_Conversion_Date )) THEN
       X_Status_Code := 'O';

    ELSE
       X_Status_Code := 'C';
    END IF;

  ELSE
    X_Status_Code := 'O';
  END IF;

  -- Update conversion information for the row with conversion rate
  UPDATE GL_DAILY_RATES
  SET
    from_currency			      =    X_From_Currency,
    to_currency				      =    X_To_Currency,
    conversion_date                           =    X_Conversion_Date,
    conversion_type                           =    X_Conversion_Type,
    conversion_rate                           =    X_Conversion_Rate,
    status_code                               =    X_Status_Code,
    last_update_date                          =    X_Last_Update_Date,
    last_updated_by                           =    X_Last_Updated_By,
    last_update_login                         =    X_Last_Update_Login,
    context                                   =    X_Context,
    attribute1                                =    X_Attribute1,
    attribute2                                =    X_Attribute2,
    attribute3                                =    X_Attribute3,
    attribute4                                =    X_Attribute4,
    attribute5                                =    X_Attribute5,
    attribute6                                =    X_Attribute6,
    attribute7                                =    X_Attribute7,
    attribute8                                =    X_Attribute8,
    attribute9                                =    X_Attribute9,
    attribute10                               =    X_Attribute10,
    attribute11                               =    X_Attribute11,
    attribute12                               =    X_Attribute12,
    attribute13                               =    X_Attribute13,
    attribute14                               =    X_Attribute14,
    attribute15                               =    X_Attribute15
  WHERE rowid = X_Rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;

  -- Update conversion information for the row with inverse conversion rate
  UPDATE GL_DAILY_RATES
  SET
    from_currency			      =    X_To_Currency,
    to_currency				      =    X_From_Currency,
    conversion_date                           =    X_Conversion_Date,
    conversion_type                           =    X_Conversion_Type,
    conversion_rate                           =    X_Inverse_Conversion_Rate,
    status_code                               =    X_Status_Code,
    last_update_date                          =    X_Last_Update_Date,
    last_updated_by                           =    X_Last_Updated_By,
    last_update_login                         =    X_Last_Update_Login,
    context                                   =    X_Context,
    attribute1                                =    X_Attribute1,
    attribute2                                =    X_Attribute2,
    attribute3                                =    X_Attribute3,
    attribute4                                =    X_Attribute4,
    attribute5                                =    X_Attribute5,
    attribute6                                =    X_Attribute6,
    attribute7                                =    X_Attribute7,
    attribute8                                =    X_Attribute8,
    attribute9                                =    X_Attribute9,
    attribute10                               =    X_Attribute10,
    attribute11                               =    X_Attribute11,
    attribute12                               =    X_Attribute12,
    attribute13                               =    X_Attribute13,
    attribute14                               =    X_Attribute14,
    attribute15                               =    X_Attribute15
  WHERE rowid = X_Inverse_Rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;


  ekey := X_From_Currency||':'||X_To_Currency||':'||X_Conversion_Type||':'
         ||to_char(X_Conversion_Date,'RRDDDSSSSS')||':'
         ||to_char(X_Conversion_date,'RRDDDSSSSS')||':'
         ||to_char(sysdate, 'RRDDDSSSSS');

  -- Raise the specify conversion event
  gl_business_events.raise(
    p_event_name => 'oracle.apps.gl.CurrencyConversionRates.dailyRate.specify',
    p_event_key => ekey,
    p_parameter_name1 => 'FROM_CURRENCY',
    p_parameter_value1 => X_From_Currency,
    p_parameter_name2 => 'TO_CURRENCY',
    p_parameter_value2 => X_To_Currency,
    p_parameter_name3 => 'FROM_CONVERSION_DATE',
    p_parameter_value3 => to_char(X_Conversion_Date,'YYYY/MM/DD'),
    p_parameter_name4 => 'FROM_CONVERSION_DATE',
    p_parameter_value4 => to_char(X_Conversion_Date,'YYYY/MM/DD'),
    p_parameter_name5 => 'CONVERSION_TYPE',
    p_parameter_value5 => X_Conversion_Type,
    p_parameter_name6 => 'CONVERSION_RATE',
    p_parameter_value6 => to_char(X_Conversion_Rate,
                           '99999999999999999999.99999999999999999999'),
    p_parameter_name7 => 'INVERSE_CONVERSION_RATE',
    p_parameter_value7 => to_char(X_Inverse_Conversion_Rate,
                           '99999999999999999999.99999999999999999999')
    );

END Update_Row;


  --
  -- Procedure
  --
  --  Delete_Row
  --
  -- Purpose
  --   Deletes a row from gl_daily_rates
  --
  -- History
  --   07-29-97	W Wong		Created
  --
  -- Arguments
  --    X_Rowid         	Rowid of the row with conversion rate
  --    X_Inverse_Rowid		Rowid of the row with inverse conversion rate
  --    X_To_Currency		To Currency
  --    X_Conversion_Type	Conversion Type
  --    X_Status_Code		Status Code
  --    X_Average_Balances_Used Average Balance Used Flag
  --    X_Euro_Currency		Currency code of the Euro currency
  --
  -- Example
  --   gl_daily_rates.delete_row('...');
  --
  -- Notes
  --
PROCEDURE Delete_Row(X_Rowid    	                    VARCHAR2,
                     X_Inverse_Rowid	                    VARCHAR2,
	             X_From_Currency			    VARCHAR2,
		     X_To_Currency			    VARCHAR2,
		     X_Conversion_Type			    VARCHAR2,
		     X_Conversion_Date			    DATE,
		     X_Status_Code        	     IN OUT NOCOPY VARCHAR2,
		     X_Average_Balances_Used		    VARCHAR2,
		     X_Euro_Currency			    VARCHAR2
	            ) IS
    ekey    VARCHAR2(100);
BEGIN
  -- Set the status code to 'D' if the X_To_Currency and X_Conversion_Type is
  -- used in ledgers.
  IF ( X_Status_Code <> 'O' ) THEN
    IF ( GL_DAILY_RATES_PKG.Used_In_Ledger( X_From_Currency,
	  			            X_To_Currency,
	 			            X_Conversion_Type,
				            X_Euro_Currency,
				            X_Conversion_Date )) THEN
      X_Status_Code := 'D';

    ELSE
      X_Status_Code := 'C';
    END IF;
  ELSE
    X_Status_Code := 'D';
  END IF;

  -- Delete or update GL_DAILY_RATES table according to the status code
  IF (X_Status_Code <> 'D') THEN
     -- Delete the original row and its corresponding row with the
     -- inverse conversion rate
     DELETE FROM GL_DAILY_RATES
     WHERE  rowid IN (X_Rowid, X_Inverse_Rowid);

  ELSE
     -- Update the original row and its corresponding row with the
     -- inverse conversion rate
     UPDATE GL_DAILY_RATES
     SET
         status_code = 'D'
     WHERE rowid IN  (X_Rowid, X_Inverse_Rowid);
  END IF;

  ekey := X_From_Currency||':'||X_To_Currency||':'||X_Conversion_Type||':'
         ||to_char(X_Conversion_Date,'RRDDDSSSSS')||':'
         ||to_char(X_Conversion_date,'RRDDDSSSSS')||':'
         ||to_char(sysdate, 'RRDDDSSSSS');

  -- Raise the specify conversion event
  gl_business_events.raise(
    p_event_name => 'oracle.apps.gl.CurrencyConversionRates.dailyRate.remove',
    p_event_key => ekey,
    p_parameter_name1 => 'FROM_CURRENCY',
    p_parameter_value1 => X_From_Currency,
    p_parameter_name2 => 'TO_CURRENCY',
    p_parameter_value2 => X_To_Currency,
    p_parameter_name3 => 'FROM_CONVERSION_DATE',
    p_parameter_value3 => to_char(X_Conversion_Date,'YYYY/MM/DD'),
    p_parameter_name4 => 'FROM_CONVERSION_DATE',
    p_parameter_value4 => to_char(X_Conversion_Date,'YYYY/MM/DD'),
    p_parameter_name5 => 'CONVERSION_TYPE',
    p_parameter_value5 => X_Conversion_Type
    );

EXCEPTION
  WHEN NO_DATA_FOUND THEN
      null;
  -- The following exception will catch the condition when a row
  -- which was deleted earlier is reinserted and deleted again. Since
  -- two rows with the same primary keys exist in GL_DAILY_RATES
  -- we need to delete this row. The Rate Change program will
  -- outdate the corresponding rows in GL_DAILY_BALANCES since it will
  -- process the existing duplicate row with the same accounting date and
  -- the currency code.
  WHEN DUP_VAL_ON_INDEX THEN
      DELETE FROM GL_DAILY_RATES
            WHERE  rowid = X_Rowid;
      DELETE FROM GL_DAILY_RATES
            WHERE  rowid = X_Inverse_Rowid;
  WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE', 'gl_daily_rates.delete_row');
      RAISE;

END Delete_Row;


  --
  -- Procedure
  --   Check_Unique
  --
  -- Purpose
  --   Checks to make sure that gl_daily_rates is unique.
  --
  -- History
  --   07-29-97	W Wong		Created
  --
  -- Arguments
  --   X_Rowid                   	The row ID
  --   X_From_Currency			From Currency
  --   X_To_Currency			To Currency
  --   X_Conversion_Date		Conversion Date
  --   X_Conversion_Type		Conversion Type
  --
  -- Example
  --   gl_daily_rates.check_unique(...);
  --
  -- Notes
  --
PROCEDURE Check_Unique(X_Rowid                  VARCHAR2,
                       X_From_Currency          VARCHAR2,
                       X_To_Currency            VARCHAR2,
                       X_Conversion_Date        DATE,
                       X_Conversion_Type        VARCHAR2) IS
dummy NUMBER;
BEGIN
  IF (     X_From_Currency IS NOT NULL
       AND X_To_Currency IS NOT NULL
       AND X_Conversion_Date IS NOT NULL
       AND X_Conversion_Type IS NOT NULL ) THEN

 	SELECT 1
	INTO   dummy
	FROM   dual D
	WHERE NOT EXISTS ( SELECT 1
			   FROM   GL_DAILY_RATES R
			   WHERE  R.from_currency = X_From_Currency
			   AND    R.to_currency = X_To_Currency
			   AND    R.conversion_date = X_Conversion_Date
			   AND	  R.conversion_type = X_Conversion_Type
			   AND    ( R.rowid <> X_Rowid OR X_Rowid IS NULL ));
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
         FND_MESSAGE.SET_NAME('SQLGL', 'GL_EXCHG_RATE_ALREADY_EXISTS');
         APP_EXCEPTION.RAISE_EXCEPTION;

end Check_Unique;


  --
  -- Function
  --   Used_In_Ledger
  --
  -- Purpose
  --   Checks if the functional currency and the specified conversion type is
  --   being used for translation by any ledgers.  If it is, check the
  --   following:
  --
  --   a. If functional currency is an EMU currency,
  --      and the X_Conversion_Date is ON OR AFTER the EMU date,
  --      and if daily rates which involves the EURO currency has been changed,
  --      return 'Y'.
  --
  --   b. If functional currency is an EMU currency,
  --      but the X_Conversion_Date is BEFORE the EMU date,
  --      and if daily rates which involves the functional currency has been
  --      changed, return 'Y'.
  --
  --   c. If functional currency is not an EMU currency,
  --      and if daily rates which involves the functional currency has been
  --      which is not an EMU currency, return 'Y'.
  --
  --   d. Return 'N' otherwise.
  --
  -- History
  --   08-06-97	W Wong	Created
  --
  -- Arguments
  --   X_To_Currency                    To Currency
  --   X_Conversion_Type                Conversion Type
  --
  -- Example
  --   gl_daily_rates.used_in_ledger(...)
  --
  -- Notes
  --
FUNCTION Used_In_Ledger( X_From_Currency          VARCHAR2,
			 X_To_Currency            VARCHAR2,
                         X_Conversion_Type        VARCHAR2,
			 X_Euro_Currency          VARCHAR2,
			 X_Conversion_Date        DATE)
RETURN BOOLEAN IS
  is_used  VARCHAR2(1) := 'N';

BEGIN
  SELECT nvl(max('Y'),'N')
  INTO   is_used
  FROM   dual
  WHERE EXISTS (
	SELECT 'found'
	FROM   GL_LEDGERS LGR, GL_LEDGER_RELATIONSHIPS REL
        WHERE  LGR.currency_code IN (X_From_Currency, X_To_Currency)
        AND    REL.source_ledger_id = LGR.ledger_id+0
        AND    REL.target_ledger_id = LGR.ledger_id+0
        AND    REL.application_id = 101
        AND    REL.target_ledger_category_code = 'ALC'
        AND    REL.relationship_type_code = 'BALANCE'
        AND    REL.target_currency_code IN (X_From_Currency, X_To_Currency)
        AND    (   LGR.daily_translation_rate_type = X_Conversion_Type
                OR nvl(REL.alc_period_average_rate_type,
                       LGR.period_average_rate_type) = X_Conversion_Type
                OR nvl(REL.alc_period_end_rate_type,
                       LGR.period_end_rate_type) = X_Conversion_Type));

  IF ( is_used = 'Y' ) THEN
    return( TRUE );

  ELSE
    return( FALSE );
  END IF;

END Used_In_Ledger;

  --
  -- Procedure
  --  Insert_DateRange
  --
  -- Purpose
  --   This procedure is created for Ispeed Daily Rates API.
  --   It inserts rows into gl_daily_rates_interface.
  --
  -- History
  --   09-06-00	K Chang		Created
  --
  -- Arguments
  --   All the columns of the table GL_DAILY_RATES_INTERFACE
  --
  -- Example
  --   gl_daily_rates_pkg.Insert_DateRage(....);
  --
  -- Notes
  --
PROCEDURE Insert_DateRange(X_From_Currency                  VARCHAR2,
                     X_To_Currency                          VARCHAR2,
                     X_From_Conversion_Date                 DATE,
                     X_To_Conversion_Date                   DATE,
                     X_User_Conversion_Type                 VARCHAR2,
                     X_Conversion_Rate                      NUMBER,
                     X_Mode_Flag                            VARCHAR2,
                     X_Inverse_Conversion_Rate              NUMBER,
                     X_User_Id                              NUMBER,
                     X_Launch_Rate_Change                   VARCHAR2,
                     X_Error_Code                           VARCHAR2,
                     X_Context                              VARCHAR2,
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
		     X_Used_For_AB_Translation		    VARCHAR2
 ) IS
BEGIN
  -- Insert the row with conversion rate
  INSERT INTO GL_DAILY_RATES_INTERFACE(
	  from_currency,
	  to_currency,
	  from_conversion_date,
          to_conversion_date,
	  user_conversion_type,
	  conversion_rate,
	  mode_flag,
	  inverse_conversion_rate,
	  user_id,
	  launch_rate_change,
	  error_code,
	  context,
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
          used_for_ab_translation
        ) VALUES (
	  X_From_Currency,
	  X_To_Currency,
	  X_From_Conversion_Date,
          X_To_Conversion_Date,
	  X_User_Conversion_Type,
	  X_Conversion_Rate,
	  X_Mode_Flag,
          X_Inverse_Conversion_Rate,
	  X_User_Id,
	  X_Launch_Rate_Change,
	  X_Error_Code,
	  X_Context,
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
          X_Used_For_AB_Translation
	);

END Insert_DateRange;


  --
  -- Procedure
  --  Validate_DailyRates
  --
  -- Purpose
  --   This procedure is created for Ispeed Daily Rates API.
  --   It validate the following:
  --   o From_Currency and To_Currency are not the same
  --   o From_Currency and To_Currency:
  --     a. Currency exists in the FND_CURRENCIES table
  --     b. Currency is enabled
  --     c. Currency is not out of date
  --     d. Currency is not an EMU currency
  --   o Range of dates specified does not exceed 366 days
  --
  -- History
  --   09-06-00	K Chang		Created
  --
  -- Arguments
  --  X_From_Currency		From Currency
  --  X_To_Currency		To Currency
  --  X_Conversion_Date         Conversion Date
  --  X_Converson_Type          Conversion Type
  --  X_From_Conversion_Date    From Conversion Date
  --  X_To_Conversion_Date	To Conversion Date
  --
  -- Example
  --   gl_daily_rates_pkg.Validate_DailyRates(....);
  --
  -- Notes
  --
PROCEDURE Validate_DailyRates(X_From_Currency               VARCHAR2,
                     X_To_Currency                          VARCHAR2,
     		     X_Conversion_Date                      DATE,
                     X_Conversion_Type                      VARCHAR2,
		     X_From_Conversion_Date 		    DATE,
		     X_To_Conversion_Date		    DATE

 ) IS
CURSOR check_from_currency IS
   SELECT 'X'
   FROM FND_CURRENCIES
   WHERE   currency_code = X_FROM_CURRENCY
   AND     currency_flag = 'Y'
   AND     enabled_flag ='Y'
   AND     sign(trunc(sysdate) -
           nvl(trunc(start_date_active),trunc(sysdate))) <> -1
   AND     sign(trunc(sysdate)
           - nvl(trunc(end_date_active),trunc(sysdate))) <> 1
   AND      decode(derive_type, 'EMU', sign(  trunc(derive_effective) - trunc(X_CONVERSION_DATE)),1) > 0;

CURSOR check_to_currency IS
   SELECT 'X'
   FROM FND_CURRENCIES
   WHERE   currency_code = X_TO_CURRENCY
   AND     currency_flag = 'Y'
   AND     enabled_flag ='Y'
   AND     sign(trunc(sysdate) -
           nvl(trunc(start_date_active),trunc(sysdate))) <> -1
   AND     sign(trunc(sysdate)
           - nvl(trunc(end_date_active),trunc(sysdate))) <> 1
   AND      decode(derive_type,'EMU', sign(  trunc(derive_effective) - trunc(X_CONVERSION_DATE) ),   1) > 0 ;

dummy VARCHAR2(10);
numDays number := 0;
BEGIN

   -- Check if from and to currencies are the same
   IF (X_FROM_CURRENCY = X_TO_CURRENCY) THEN
      fnd_message.set_name('SQLGL', 'GL_GLXRTDLY_SAMECURR');
      app_exception.raise_exception;
   END IF;

   -- Check from currency
   OPEN check_from_currency;
   FETCH check_from_currency INTO dummy;
   IF check_from_currency%NOTFOUND THEN
         CLOSE check_from_currency;
         fnd_message.set_name('SQLGL', 'GL_API_DRATE_INVALID_FCURR');
         app_exception.raise_exception;
   END IF;
   CLOSE check_from_currency;

   -- Check to currency
   OPEN check_to_currency;
   FETCH check_to_currency INTO dummy;
   IF check_to_currency%NOTFOUND THEN
         CLOSE check_to_currency;
         fnd_message.set_name('SQLGL', 'GL_API_DRATE_INVALID_TCURR');
         app_exception.raise_exception;
   END IF;
   CLOSE check_to_currency;

   -- Check conversion date ranges
   IF (X_From_Conversion_Date IS NOT NULL AND
       X_To_Conversion_Date IS NOT NULL) THEN

     SELECT least(trunc(X_To_Conversion_DATE) -
		  trunc(X_From_Conversion_Date), 367)
     into numDays
     FROM dual;

     IF (numDays = 367) THEN
	fnd_message.set_name('SQLGL', 'GL_GLXRTDLY_LARGERANGE');
        app_exception.raise_exception;
     END IF;

  END IF;

EXCEPTION
  WHEN app_exception.application_exception THEN
       RAISE;
  WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE', 'gl_daily_rates.validate_dailyrates');
      RAISE;

END Validate_DailyRates;


  --
  -- Function
  --  Submit_Conc_Request
  --
  -- Purpose
  --   Launch Conversion Rate Change concurrent program for
  --   Ispeed Daily Rates API
  --
  -- History
  --   09-08-00	K Chang		Created
  --
  -- Arguments
  --
  --
  -- Example
  --   gl_daily_rates_pkg.Submit_Conc_Request(....);
  --
  -- Notes
  --
FUNCTION submit_conc_request RETURN NUMBER
IS
result         NUMBER :=-1;
BEGIN

    --FND_PROFILE.put('USER_ID', '2090' );
    --FND_PROFILE.put('RESP_ID', '50553');
    --FND_PROFILE.put('RESP_APPL_ID','101');

    -- Submit the request to run Rate Change concurrent program
    result     := FND_REQUEST.submit_request (
                            'SQLGL','GLTTRC','','',FALSE,
                  	    'D','',chr(0),
                            '','','','','','','',
                            '','','','','','','','','','',
                            '','','','','','','','','','',
                            '','','','','','','','','','',
                            '','','','','','','','','','',
                            '','','','','','','','','','',
                            '','','','','','','','','','',
                            '','','','','','','','','','',
                            '','','','','','','','','','',
                            '','','','','','','','','','');

    return(result);

END submit_conc_request;

  --
  -- Procedure
  --  Upload_Row
  --
  -- Purpose
  --   Inserts or Updates two rows into gl_daily_rates for Ispeed Daily
  --   Rates API:
  --   one for the original conversion rate ( From Currency -> To Currency )
  --   one for the inverse conversion rate  ( To Currency   -> From Currency )
  --
  -- History
  --   09-21-00	K Chang		Created
  --
  -- Arguments
  --   All the columns of the table GL_DAILY_RATES and
  --   X_Average_Balances_Used	 		Average Balances Used
  --   X_Euro_Currency				Currency Code of EURO
  --
  -- Example
  --   gl_daily_rates.Upload_Row(....);
  --
  -- Notes
  --
PROCEDURE Upload_Row(X_Rowid                         IN OUT NOCOPY VARCHAR2,
		     X_Inverse_Rowid                 IN OUT NOCOPY VARCHAR2,
                     X_From_Currency                        VARCHAR2,
                     X_To_Currency                          VARCHAR2,
                     X_Conversion_Date                      DATE,
                     X_Conversion_Type                      VARCHAR2,
                     X_Conversion_Rate                      NUMBER,
                     X_Inverse_Conversion_Rate              NUMBER,
		     X_Status_Code        	     IN OUT NOCOPY VARCHAR2,
                     X_Creation_Date                        DATE,
                     X_Created_By                           NUMBER,
                     X_Last_Update_Date                     DATE,
                     X_Last_Updated_By                      NUMBER,
                     X_Last_Update_Login                    NUMBER,
                     X_Context                              VARCHAR2,
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
		     X_Average_Balances_Used		    VARCHAR2,
		     X_Euro_Currency			    VARCHAR2
 ) IS
   lrowid rowid := null;
   invrowid rowid := null;
BEGIN

   -- Get the row id
   select rowid
   into  lrowid
   from  gl_daily_rates
   where from_currency = X_From_Currency
   and   to_currency = X_To_Currency
   and   conversion_date = X_Conversion_Date
   and   conversion_type = X_Conversion_Type;

   -- Get the row id for the inverse conversion rate
   select rowid
   into   invrowid
   from   gl_daily_rates
   where  from_currency = X_To_Currency
   and    to_currency = X_From_Currency
   and    conversion_date = X_Conversion_Date
   and    conversion_type = X_Conversion_Type;

   -- Update only if the record exists in the database
   --IF ( lrowid IS NOT NULL and invrowid IS NOT NULL) THEN
   GL_DAILY_RATES_PKG.update_row(
          X_Rowid			=>lrowid,
          X_Inverse_Rowid		=>invrowid,
	  X_From_Currency		=>X_From_Currency,
	  X_To_Currency			=>X_To_Currency,
	  X_Conversion_Date		=>X_Conversion_Date,
	  X_Conversion_Type		=>X_Conversion_Type,
	  X_Conversion_Rate		=>X_Conversion_Rate,
          X_Inverse_Conversion_Rate	=>X_Inverse_Conversion_Rate,
	  X_Status_Code 		=>X_Status_Code,
	  X_Creation_Date 		=>X_Creation_Date,
	  X_Created_By 			=>X_Created_By,
	  X_Last_Update_Date		=>X_Last_Update_Date,
	  X_Last_Updated_By 		=>X_Last_Updated_By,
	  X_Last_Update_Login 		=>X_Last_Update_Login,
	  X_Context 			=>X_Context,
	  X_Attribute1			=>X_Attribute1,
	  X_Attribute2			=>X_Attribute2,
	  X_Attribute3			=>X_Attribute3,
	  X_Attribute4			=>X_Attribute4,
	  X_Attribute5			=>X_Attribute5,
	  X_Attribute6			=>X_Attribute6,
	  X_Attribute7			=>X_Attribute7,
	  X_Attribute8	 		=>X_Attribute8,
	  X_Attribute9			=>X_Attribute9,
	  X_Attribute10			=>X_Attribute10,
	  X_Attribute11 		=>X_Attribute11,
	  X_Attribute12			=>X_Attribute12,
	  X_Attribute13			=>X_Attribute13,
	  X_Attribute14			=>X_Attribute14,
	  X_Attribute15			=>X_Attribute15,
          X_Average_Balances_Used	=>X_Average_Balances_Used,
          X_Euro_Currency		=>X_Euro_Currency
 	);
    --END IF;

    EXCEPTION WHEN NO_DATA_FOUND THEN
      GL_DAILY_RATES_PKG.insert_row(
          X_Rowid			=>lrowid,
          X_Inverse_Rowid		=>invrowid,
	  X_From_Currency		=>X_From_Currency,
	  X_To_Currency			=>X_To_Currency,
	  X_Conversion_Date		=>X_Conversion_Date,
	  X_Conversion_Type		=>X_Conversion_Type,
	  X_Conversion_Rate		=>X_Conversion_Rate,
          X_Inverse_Conversion_Rate	=>X_Inverse_Conversion_Rate,
	  X_Status_Code 		=>X_Status_Code,
	  X_Creation_Date 		=>X_Creation_Date,
	  X_Created_By 			=>X_Created_By,
	  X_Last_Update_Date		=>X_Last_Update_Date,
	  X_Last_Updated_By 		=>X_Last_Updated_By,
	  X_Last_Update_Login 		=>X_Last_Update_Login,
	  X_Context 			=>X_Context,
	  X_Attribute1			=>X_Attribute1,
	  X_Attribute2			=>X_Attribute2,
	  X_Attribute3			=>X_Attribute3,
	  X_Attribute4			=>X_Attribute4,
	  X_Attribute5			=>X_Attribute5,
	  X_Attribute6			=>X_Attribute6,
	  X_Attribute7			=>X_Attribute7,
	  X_Attribute8	 		=>X_Attribute8,
	  X_Attribute9			=>X_Attribute9,
	  X_Attribute10			=>X_Attribute10,
	  X_Attribute11 		=>X_Attribute11,
	  X_Attribute12			=>X_Attribute12,
	  X_Attribute13			=>X_Attribute13,
	  X_Attribute14			=>X_Attribute14,
	  X_Attribute15			=>X_Attribute15,
          X_Average_Balances_Used	=>X_Average_Balances_Used,
          X_Euro_Currency		=>X_Euro_Currency
	);


END Upload_Row;

END GL_DAILY_RATES_PKG;

/
