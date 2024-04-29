--------------------------------------------------------
--  DDL for Package Body GL_RECURRING_HEADERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_RECURRING_HEADERS_PKG" as
/* $Header: glirechb.pls 120.5 2005/05/05 01:19:57 kvora ship $ */


  --
  -- PUBLIC FUNCTIONS
  --

  FUNCTION is_valid_header_exist(
    x_ledger_id NUMBER,
    x_recurring_batch_id NUMBER ) RETURN BOOLEAN  IS

    CURSOR c_active IS
      SELECT 'found'
      FROM   gl_recurring_headers head
      WHERE  head.LEDGER_ID	= x_ledger_id
      AND    head.RECURRING_BATCH_ID	= x_recurring_batch_id
      AND    TRUNC( sysdate )
               BETWEEN  NVL( head.START_DATE_ACTIVE, TRUNC( sysdate ) )
               AND      NVL( head.END_DATE_ACTIVE, TRUNC( sysdate ) );

    dummy VARCHAR2( 100 );

  BEGIN

    OPEN  c_active;

    FETCH c_active INTO dummy;

    IF c_active%FOUND THEN
       CLOSE c_active;
       RETURN( TRUE );
    ELSE
       CLOSE c_active;
       RETURN( FALSE );
    END IF;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'GL_RECURRING_HEADERS_PKG.is_valid_header_exist');
      RAISE;

  END is_valid_header_exist;

-- **********************************************************************

  PROCEDURE check_unique( x_rowid    VARCHAR2,
                          x_name     VARCHAR2,
                          x_batchid  NUMBER ) IS
    CURSOR c_dup IS
      SELECT 'Duplicate'
      FROM   gl_recurring_headers h
      WHERE  upper( h.name) = upper( x_name )
      AND    h.recurring_batch_id = x_batchid
      AND    ( x_rowid is NULL
               OR
               h.rowid <> x_rowid );

    dummy VARCHAR2(100);

  BEGIN
    OPEN  c_dup;
    FETCH c_dup INTO dummy;

    IF c_dup%FOUND THEN
      CLOSE c_dup;
      fnd_message.set_name( 'SQLGL', 'GL_DUPLICATE_REC_HEADER' );
      app_exception.raise_exception;
    END IF;

    CLOSE c_dup;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'GL_RECURRING_HEADERS_PKG.check_unique');
      RAISE;

  END check_unique;

-- **********************************************************************

  FUNCTION get_unique_id RETURN NUMBER IS

    CURSOR c_getid IS
      SELECT GL_RECURRING_HEADERS_S.NEXTVAL
      FROM   dual;

    id number;

  BEGIN
    OPEN  c_getid;
    FETCH c_getid INTO id;

    IF c_getid%FOUND THEN
      CLOSE c_getid;
      RETURN( id );
    ELSE
      CLOSE c_getid;
      fnd_message.set_name('SQLGL', 'GL_ERROR_GETTING_UNIQUE_ID');
      fnd_message.set_token('SEQUENCE', 'GL_RECURRING_HEADERS_S');
      app_exception.raise_exception;
    END IF;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'GL_RECURRING_HEADERS_PKG.get_unique_id');
      RAISE;

  END get_unique_id;

-- **********************************************************************

  PROCEDURE delete_rows( x_batch_id    NUMBER ) IS

    CURSOR c_header IS
      SELECT    h.RECURRING_HEADER_ID
      FROM      GL_RECURRING_HEADERS h
      WHERE     h.RECURRING_BATCH_ID = x_batch_id;

    header_id NUMBER;

  BEGIN

    OPEN c_header;
    LOOP
      FETCH     c_header
      INTO      header_id;
      EXIT WHEN c_header%NOTFOUND;

      DELETE
      FROM   GL_RECURRING_LINE_CALC_RULES
      WHERE  RECURRING_HEADER_ID = header_id;

      DELETE
      FROM   GL_RECURRING_LINES
      WHERE  RECURRING_HEADER_ID = header_id;

    END LOOP;

    CLOSE c_header;

    DELETE
    FROM    GL_RECURRING_HEADERS
    WHERE   RECURRING_BATCH_ID = x_batch_id;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'GL_RECURRING_HEADERS_PKG.delete_rows');
      RAISE;

  END delete_rows;

-- **********************************************************************

PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Recurring_Header_Id          IN OUT NOCOPY NUMBER,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Ledger_Id                           NUMBER,
                     X_Name                                VARCHAR2,
                     X_Je_Category_Name                    VARCHAR2,
                     X_Enabled_Flag                        VARCHAR2,
                     X_Allocation_Flag                     VARCHAR2,
                     X_Currency_Code                       VARCHAR2,
                     X_Currency_Conversion_Type            VARCHAR2,
                     X_Creation_Date                       DATE,
                     X_Created_By                          NUMBER,
                     X_Last_Update_Login                   NUMBER,
                     X_Recurring_Batch_Id                  NUMBER,
                     X_Period_Type                         VARCHAR2,
                     X_Last_Executed_Period_Name           VARCHAR2,
                     X_Last_Executed_Date                  DATE,
                     X_Start_Date_Active                   DATE,
                     X_End_Date_Active                     DATE,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Attribute6                          VARCHAR2,
                     X_Attribute7                          VARCHAR2,
                     X_Attribute8                          VARCHAR2,
                     X_Attribute9                          VARCHAR2,
                     X_Attribute10                         VARCHAR2,
                     X_Context                             VARCHAR2
 ) IS

   CURSOR C IS
     SELECT rowid
       FROM GL_RECURRING_HEADERS
      WHERE recurring_header_id = X_Recurring_Header_Id;

    CURSOR C2 IS
      SELECT gl_recurring_headers_s.nextval
        FROM dual;

BEGIN

   if (X_Recurring_Header_Id is NULL) then
     OPEN C2;
     FETCH C2 INTO X_Recurring_Header_Id;

     if (C2%NOTFOUND) then
       CLOSE C2;
       RAISE NO_DATA_FOUND;
     end if;

     CLOSE C2;
   end if;

-- Consolidating call to check unique to save on round trips
check_unique(X_rowid, X_name, X_Recurring_Batch_id);

  INSERT INTO GL_RECURRING_HEADERS(
          recurring_header_id,
          last_update_date,
          last_updated_by,
          ledger_id,
          name,
          je_category_name,
          enabled_flag,
          allocation_flag,
          currency_code,
          currency_conversion_type,
          creation_date,
          created_by,
          last_update_login,
          recurring_batch_id,
          period_type,
          last_executed_period_name,
          last_executed_date,
          start_date_active,
          end_date_active,
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
          context
         ) VALUES (
          X_Recurring_Header_Id,
          X_Last_Update_Date,
          X_Last_Updated_By,
          X_Ledger_Id,
          X_Name,
          X_Je_Category_Name,
          X_Enabled_Flag,
          X_Allocation_Flag,
          X_Currency_Code,
          X_Currency_Conversion_Type,
          X_Creation_Date,
          X_Created_By,
          X_Last_Update_Login,
          X_Recurring_Batch_Id,
          X_Period_Type,
          X_Last_Executed_Period_Name,
          X_Last_Executed_Date,
          X_Start_Date_Active,
          X_End_Date_Active,
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
          X_Context

  );

  OPEN C;
  FETCH C INTO X_Rowid;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;
END Insert_Row;



PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                   X_Recurring_Header_Id                   NUMBER,
                   X_Ledger_Id                             NUMBER,
                   X_Name                                  VARCHAR2,
                   X_Je_Category_Name                      VARCHAR2,
                   X_Enabled_Flag                          VARCHAR2,
                   X_Allocation_Flag                       VARCHAR2,
                   X_Currency_Code                         VARCHAR2,
                   X_Currency_Conversion_Type              VARCHAR2,
                   X_Recurring_Batch_Id                    NUMBER,
                   X_Period_Type                           VARCHAR2,
                   X_Last_Executed_Period_Name             VARCHAR2,
                   X_Last_Executed_Date                    DATE,
                   X_Start_Date_Active                     DATE,
                   X_End_Date_Active                       DATE,
                   X_Attribute1                            VARCHAR2,
                   X_Attribute2                            VARCHAR2,
                   X_Attribute3                            VARCHAR2,
                   X_Attribute4                            VARCHAR2,
                   X_Attribute5                            VARCHAR2,
                   X_Attribute6                            VARCHAR2,
                   X_Attribute7                            VARCHAR2,
                   X_Attribute8                            VARCHAR2,
                   X_Attribute9                            VARCHAR2,
                   X_Attribute10                           VARCHAR2,
                   X_Context                               VARCHAR2
) IS
  CURSOR C IS
      SELECT *
      FROM   GL_RECURRING_HEADERS
      WHERE  rowid = X_Rowid
      FOR UPDATE OF Recurring_Header_Id NOWAIT;
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
          (   (Recinfo.recurring_header_id = X_Recurring_Header_Id)
           OR (    (Recinfo.recurring_header_id IS NULL)
               AND (X_Recurring_Header_Id IS NULL)))
      AND (   (Recinfo.ledger_id = X_Ledger_Id)
           OR (    (Recinfo.ledger_id IS NULL)
               AND (X_Ledger_Id IS NULL)))
      AND (   (Recinfo.name = X_Name)
           OR (    (Recinfo.name IS NULL)
               AND (X_Name IS NULL)))
      AND (   (Recinfo.je_category_name = X_Je_Category_Name)
           OR (    (Recinfo.je_category_name IS NULL)
               AND (X_Je_Category_Name IS NULL)))
      AND (   (Recinfo.enabled_flag = X_Enabled_Flag)
           OR (    (Recinfo.enabled_flag IS NULL)
               AND (X_Enabled_Flag IS NULL)))
      AND (   (Recinfo.allocation_flag = X_Allocation_Flag)
           OR (    (Recinfo.allocation_flag IS NULL)
               AND (X_Allocation_Flag IS NULL)))
      AND (   (Recinfo.currency_code = X_Currency_Code)
           OR (    (Recinfo.currency_code IS NULL)
               AND (X_Currency_Code IS NULL)))
      AND (   (Recinfo.currency_conversion_type = X_Currency_Conversion_Type)
           OR (    (Recinfo.currency_conversion_type IS NULL)
               AND (X_Currency_Conversion_Type IS NULL)))
      AND (   (Recinfo.recurring_batch_id = X_Recurring_Batch_Id)
           OR (    (Recinfo.recurring_batch_id IS NULL)
               AND (X_Recurring_Batch_Id IS NULL)))
      AND (   (Recinfo.period_type = X_Period_Type)
           OR (    (Recinfo.period_type IS NULL)
               AND (X_Period_Type IS NULL)))
      AND (   (Recinfo.last_executed_period_name = X_Last_Executed_Period_Name)
           OR (    (Recinfo.last_executed_period_name IS NULL)
               AND (X_Last_Executed_Period_Name IS NULL)))
      AND (   (Recinfo.last_executed_date = X_Last_Executed_Date)
           OR (    (Recinfo.last_executed_date IS NULL)
               AND (X_Last_Executed_Date IS NULL)))
      AND (   (Recinfo.start_date_active = X_Start_Date_Active)
           OR (    (Recinfo.start_date_active IS NULL)
               AND (X_Start_Date_Active IS NULL)))
      AND (   (Recinfo.end_date_active = X_End_Date_Active)
           OR (    (Recinfo.end_date_active IS NULL)
               AND (X_End_Date_Active IS NULL)))
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
      AND (   (Recinfo.context = X_Context)
           OR (    (Recinfo.context IS NULL)
               AND (X_Context IS NULL)))
          ) then
    return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
END Lock_Row;




PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Recurring_Header_Id                 NUMBER,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Ledger_Id                           NUMBER,
                     X_Name                                VARCHAR2,
                     X_Je_Category_Name                    VARCHAR2,
                     X_Enabled_Flag                        VARCHAR2,
                     X_Allocation_Flag                     VARCHAR2,
                     X_Currency_Code                       VARCHAR2,
                     X_Currency_Conversion_Type            VARCHAR2,
                     X_Last_Update_Login                   NUMBER,
                     X_Recurring_Batch_Id                  NUMBER,
                     X_Period_Type                         VARCHAR2,
                     X_Last_Executed_Period_Name           VARCHAR2,
                     X_Last_Executed_Date                  DATE,
                     X_Start_Date_Active                   DATE,
                     X_End_Date_Active                     DATE,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Attribute6                          VARCHAR2,
                     X_Attribute7                          VARCHAR2,
                     X_Attribute8                          VARCHAR2,
                     X_Attribute9                          VARCHAR2,
                     X_Attribute10                         VARCHAR2,
                     X_Context                             VARCHAR2
--                   Currency_Changed           IN OUT NOCOPY VARCHAR2
) IS

func_curr   VARCHAR2(15);

BEGIN

  -- Consolidating call to check unique to save on round trips
  check_unique(X_rowid, X_name, X_Recurring_Batch_id);

  UPDATE GL_RECURRING_HEADERS
  SET
    recurring_header_id                       =    X_Recurring_Header_Id,
    last_update_date                          =    X_Last_Update_Date,
    last_updated_by                           =    X_Last_Updated_By,
    ledger_id                                 =    X_Ledger_Id,
    name                                      =    X_Name,
    je_category_name                          =    X_Je_Category_Name,
    enabled_flag                              =    X_Enabled_Flag,
    allocation_flag                           =    X_Allocation_Flag,
    currency_code                             =    X_Currency_Code,
    currency_conversion_type                  =    X_Currency_Conversion_Type,
    last_update_login                         =    X_Last_Update_Login,
    recurring_batch_id                        =    X_Recurring_Batch_Id,
    period_type                               =    X_Period_Type,
    last_executed_period_name                 =    X_Last_Executed_Period_Name,
    last_executed_date                        =    X_Last_Executed_Date,
    start_date_active                         =    X_Start_Date_Active,
    end_date_active                           =    X_End_Date_Active,
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
    context                                   =    X_Context
  WHERE rowid = X_rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;

END Update_Row;



PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
BEGIN
  DELETE
    FROM GL_RECURRING_HEADERS
   WHERE  rowid = X_Rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;
END Delete_Row;



END GL_RECURRING_HEADERS_PKG;

/
