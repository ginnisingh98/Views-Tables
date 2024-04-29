--------------------------------------------------------
--  DDL for Package Body GL_RECURRING_BATCHES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_RECURRING_BATCHES_PKG" as
/* $Header: glirecbb.pls 120.5 2005/05/05 01:19:40 kvora ship $ */


  --
  -- PUBLIC FUNCTIONS
  --

  PROCEDURE check_unique( x_rowid VARCHAR2,
                          x_name  VARCHAR2,
                          x_coaid NUMBER,
                          x_period_set_name      VARCHAR2,
                          x_accounted_period_type VARCHAR2) IS

    CURSOR c_dup IS
      SELECT 'Duplicate'
      FROM   gl_recurring_batches b
      WHERE  upper( b.name) = upper( x_name )
        AND  b.chart_of_accounts_id = x_coaid
        AND  b.period_set_name = x_period_set_name
        AND  b.accounted_period_type = x_accounted_period_type
        AND    ( x_rowid is NULL
               OR
               b.rowid <> x_rowid );

    dummy VARCHAR2(100);

  BEGIN
    OPEN  c_dup;
    FETCH c_dup INTO dummy;

    IF c_dup%FOUND THEN
      CLOSE c_dup;
      fnd_message.set_name( 'SQLGL', 'GL_DUPLICATE_REC_BATCH' );
      app_exception.raise_exception;
    END IF;

    CLOSE c_dup;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'GL_RECURRING_BATCHES_PKG.check_unique');
      RAISE;

  END check_unique;

-- **********************************************************************

  FUNCTION get_unique_id RETURN NUMBER IS

    CURSOR c_getid IS
      SELECT GL_RECURRING_BATCHES_S.NEXTVAL
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
      fnd_message.set_token('SEQUENCE', 'GL_RECURRING_BATCHES_S');
      app_exception.raise_exception;
    END IF;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'GL_RECURRING_BATCHES_PKG.get_unique_id');
      RAISE;

  END get_unique_id;

-- **********************************************************************

  PROCEDURE copy_recurring( X_Src_Batch_Id      NUMBER,
                            X_Trg_Batch_Id 	NUMBER,
                            X_Created_By        NUMBER,
                            X_Last_Updated_By   NUMBER,
                            X_Last_Update_Login NUMBER   ) IS

    CURSOR c_src_header IS
      SELECT	h.RECURRING_HEADER_ID
      FROM 	GL_RECURRING_HEADERS h
      WHERE 	h.RECURRING_BATCH_ID = X_Src_Batch_Id;

    src_header_id  	NUMBER;
    trg_header_id  	NUMBER;

  BEGIN

    OPEN c_src_header;


    LOOP
      FETCH 	c_src_header
      INTO  	src_header_id;

      EXIT WHEN c_src_header%NOTFOUND;

      trg_header_id := GL_RECURRING_HEADERS_PKG.get_unique_id;


      INSERT INTO GL_RECURRING_HEADERS
      (
        RECURRING_HEADER_ID,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        LEDGER_ID,
        NAME,
        JE_CATEGORY_NAME,
        ENABLED_FLAG,
        ALLOCATION_FLAG,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        RECURRING_BATCH_ID,
        PERIOD_TYPE,
        LAST_EXECUTED_PERIOD_NAME,
        LAST_EXECUTED_DATE,
        START_DATE_ACTIVE,
        END_DATE_ACTIVE,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        ATTRIBUTE6,
        ATTRIBUTE7,
        ATTRIBUTE8,
        ATTRIBUTE9,
        ATTRIBUTE10,
        CONTEXT,
        CURRENCY_CODE,
        CURRENCY_CONVERSION_TYPE
      )
      SELECT
        trg_header_id,
        sysdate,
        X_Last_Updated_By,
        LEDGER_ID,
        NAME,
        JE_CATEGORY_NAME,
        ENABLED_FLAG,
        ALLOCATION_FLAG,
        sysdate,
        X_Created_By,
        X_Last_Update_Login,
        X_Trg_Batch_Id,
        PERIOD_TYPE,
        NULL,
        NULL,
        START_DATE_ACTIVE,
        END_DATE_ACTIVE,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        ATTRIBUTE6,
        ATTRIBUTE7,
        ATTRIBUTE8,
        ATTRIBUTE9,
        ATTRIBUTE10,
        CONTEXT,
        CURRENCY_CODE,
        CURRENCY_CONVERSION_TYPE
      FROM GL_RECURRING_HEADERS
      WHERE RECURRING_HEADER_ID = src_header_id;


      INSERT INTO GL_RECURRING_LINES
      (
        RECURRING_HEADER_ID,
        RECURRING_LINE_NUM,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CODE_COMBINATION_ID,
        ENTERED_CURRENCY_CODE,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        DESCRIPTION,
        ENTERED_DR,
        ENTERED_CR,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        ATTRIBUTE6,
        ATTRIBUTE7,
        ATTRIBUTE8,
        ATTRIBUTE9,
        ATTRIBUTE10,
        CONTEXT
      )
      SELECT
        trg_header_id,
        RECURRING_LINE_NUM,
        sysdate,
        X_Last_Updated_By,
        CODE_COMBINATION_ID,
        ENTERED_CURRENCY_CODE,
        sysdate,
        X_Created_By,
        X_Last_Update_Login,
        DESCRIPTION,
        ENTERED_DR,
        ENTERED_CR,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        ATTRIBUTE6,
        ATTRIBUTE7,
        ATTRIBUTE8,
        ATTRIBUTE9,
        ATTRIBUTE10,
        CONTEXT
      FROM GL_RECURRING_LINES
      WHERE RECURRING_HEADER_ID = src_header_id;


      INSERT INTO GL_RECURRING_LINE_CALC_RULES
      (
        RECURRING_HEADER_ID,
        RECURRING_LINE_NUM,
        RULE_NUM,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        OPERATOR,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        AMOUNT,
        ASSIGNED_CODE_COMBINATION,
        TEMPLATE_ID,
	AMOUNT_TYPE,
        ACTUAL_FLAG,
        LEDGER_CURRENCY,
        CURRENCY_TYPE,
        ENTERED_CURRENCY,
        LEDGER_ID,
        RELATIVE_PERIOD_CODE,
        SEGMENT1,
        SEGMENT2,
        SEGMENT3,
        SEGMENT4,
        SEGMENT5,
        SEGMENT6,
        SEGMENT7,
        SEGMENT8,
        SEGMENT9,
        SEGMENT10,
        SEGMENT11,
        SEGMENT12,
        SEGMENT13,
        SEGMENT14,
        SEGMENT15,
        SEGMENT16,
        SEGMENT17,
        SEGMENT18,
        SEGMENT19,
        SEGMENT20,
        SEGMENT21,
        SEGMENT22,
        SEGMENT23,
        SEGMENT24,
        SEGMENT25,
        SEGMENT26,
        SEGMENT27,
        SEGMENT28,
        SEGMENT29,
        SEGMENT30,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        CONTEXT
      )
      SELECT
        trg_header_id,
        RECURRING_LINE_NUM,
        RULE_NUM,
        sysdate,
        X_Last_Updated_By,
        OPERATOR,
        sysdate,
        X_Created_By,
        X_Last_Update_Login,
        AMOUNT,
        ASSIGNED_CODE_COMBINATION,
        TEMPLATE_ID,
	AMOUNT_TYPE,
        ACTUAL_FLAG,
        LEDGER_CURRENCY,
        CURRENCY_TYPE,
        ENTERED_CURRENCY,
        LEDGER_ID,
        RELATIVE_PERIOD_CODE,
        SEGMENT1,
        SEGMENT2,
        SEGMENT3,
        SEGMENT4,
        SEGMENT5,
        SEGMENT6,
        SEGMENT7,
        SEGMENT8,
        SEGMENT9,
        SEGMENT10,
        SEGMENT11,
        SEGMENT12,
        SEGMENT13,
        SEGMENT14,
        SEGMENT15,
        SEGMENT16,
        SEGMENT17,
        SEGMENT18,
        SEGMENT19,
        SEGMENT20,
        SEGMENT21,
        SEGMENT22,
        SEGMENT23,
        SEGMENT24,
        SEGMENT25,
        SEGMENT26,
        SEGMENT27,
        SEGMENT28,
        SEGMENT29,
        SEGMENT30,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        CONTEXT
      FROM GL_RECURRING_LINE_CALC_RULES
      WHERE RECURRING_HEADER_ID = src_header_id;

    END LOOP;

    CLOSE c_src_header;
    COMMIT;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'GL_RECURRING_BATCHES_PKG.copy_recurring');
      RAISE;

  END copy_recurring;

-- **********************************************************************

  PROCEDURE Insert_Row( X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Recurring_Batch_Id             IN OUT NOCOPY NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Ledger_Id                      NUMBER,
                       X_Chart_Of_Accounts_Id           NUMBER,
                       X_Period_Set_Name                VARCHAR2,
                       X_Accounted_Period_Type          VARCHAR2,
                       X_Recurring_Batch_Type           VARCHAR2,
                       X_Security_Flag                  VARCHAR2,
                       X_Name                           VARCHAR2,
                       X_Budget_Flag                    VARCHAR2,
                       X_Allocation_Flag                VARCHAR2,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Budget_In_Formula_Flag         VARCHAR2,
                       X_Description                    VARCHAR2,
                       X_Period_Type                    VARCHAR2,
                       X_Last_Executed_Period_Name      VARCHAR2,
                       X_Last_Executed_Date             DATE,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Context                        VARCHAR2
  ) IS
    CURSOR C IS SELECT rowid FROM gl_recurring_batches
                 WHERE recurring_batch_id = X_Recurring_Batch_Id;
      CURSOR C2 IS SELECT gl_recurring_batches_s.nextval FROM sys.dual;



   BEGIN


-- Consolidating call to check unique to save on round trips
check_unique(X_rowid, X_name, X_Chart_Of_Accounts_Id, X_Period_Set_Name, X_Accounted_Period_Type);

      if (X_Recurring_Batch_Id is NULL) then
        OPEN C2;
        FETCH C2 INTO X_Recurring_Batch_Id;
        CLOSE C2;
      end if;

       INSERT INTO gl_recurring_batches(

              recurring_batch_id,
              last_update_date,
              last_updated_by,
              ledger_id,
              chart_of_accounts_id,
              period_set_name,
              accounted_period_type,
              recurring_batch_type,
              security_flag,
              name,
              budget_flag,
              allocation_flag,
              creation_date,
              created_by,
              last_update_login,
              budget_in_formula_flag,
              description,
              period_type,
              last_executed_period_name,
              last_executed_date,
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

              X_Recurring_Batch_Id,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Ledger_Id,
              X_Chart_Of_Accounts_Id,
              X_Period_Set_Name,
              X_Accounted_Period_Type,
              X_Recurring_Batch_Type,
              X_Security_Flag,
              X_Name,
              X_Budget_Flag,
              X_Allocation_Flag,
              X_Creation_Date,
              X_Created_By,
              X_Last_Update_Login,
              X_Budget_In_Formula_Flag,
              X_Description,
              X_Period_Type,
              X_Last_Executed_Period_Name,
              X_Last_Executed_Date,
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
      Raise NO_DATA_FOUND;
     end if;
    CLOSE C;

  END Insert_Row;

-- **********************************************************************




  PROCEDURE Lock_Row( X_Rowid                           VARCHAR2,
                     X_Recurring_Batch_Id               NUMBER,
                     X_Ledger_Id                        NUMBER,
                     X_Chart_Of_Accounts_Id             NUMBER,
                     X_Period_Set_Name                  VARCHAR2,
                     X_Accounted_Period_Type            VARCHAR2,
                     X_Recurring_Batch_Type             VARCHAR2,
                     X_Security_Flag                    VARCHAR2,
                     X_Name                             VARCHAR2,
                     X_Budget_Flag                      VARCHAR2,
                     X_Allocation_Flag                  VARCHAR2,
                     X_Budget_In_Formula_Flag           VARCHAR2,
                     X_Description                      VARCHAR2,
                     X_Period_Type                      VARCHAR2,
                     X_Last_Executed_Period_Name        VARCHAR2,
                     X_Last_Executed_Date               DATE,
                     X_Attribute1                       VARCHAR2,
                     X_Attribute2                       VARCHAR2,
                     X_Attribute3                       VARCHAR2,
                     X_Attribute4                       VARCHAR2,
                     X_Attribute5                       VARCHAR2,
                     X_Attribute6                       VARCHAR2,
                     X_Attribute7                       VARCHAR2,
                     X_Attribute8                       VARCHAR2,
                     X_Attribute9                       VARCHAR2,
                     X_Attribute10                      VARCHAR2,
                     X_Context                          VARCHAR2
  ) IS
      CURSOR C IS
          SELECT *
          FROM   gl_recurring_batches
          WHERE  rowid = X_Rowid
          FOR UPDATE of Recurring_Batch_Id NOWAIT;
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
               (Recinfo.recurring_batch_id =  X_Recurring_Batch_Id)
           AND (   (Recinfo.ledger_id =  X_Ledger_Id)
                OR (   (Recinfo.ledger_id IS NULL)
                    AND   (X_Ledger_Id IS NULL)))
           AND (Recinfo.chart_of_accounts_id =X_Chart_Of_Accounts_Id)
           AND (Recinfo.period_set_name = X_Period_Set_Name)
           AND (Recinfo.accounted_period_type = X_Accounted_Period_Type)
           AND (Recinfo.recurring_batch_type = X_Recurring_Batch_Type)
           AND (Recinfo.security_flag =  X_Security_Flag)
           AND (Recinfo.name =  X_Name)
           AND (Recinfo.budget_flag =  X_Budget_Flag)
           AND (Recinfo.allocation_flag =  X_Allocation_Flag)
           AND (   (Recinfo.budget_in_formula_flag =  X_Budget_In_Formula_Flag)
                OR (    (Recinfo.budget_in_formula_flag IS NULL)
                    AND (X_Budget_In_Formula_Flag IS NULL)))
          AND (   (Recinfo.description =  X_Description)
                OR (    (Recinfo.description IS NULL)
                    AND (X_Description IS NULL)))
          AND (   (Recinfo.period_type =  X_Period_Type)
                OR (    (Recinfo.period_type IS NULL)
                    AND (X_Period_Type IS NULL)))
           AND (   (Recinfo.last_executed_period_name =  X_Last_Executed_Period_Name)
                OR (    (Recinfo.last_executed_period_name IS NULL)
                    AND (X_Last_Executed_Period_Name IS NULL)))
           AND (   (Recinfo.last_executed_date =  X_Last_Executed_Date)
                OR (    (Recinfo.last_executed_date IS NULL)
                    AND (X_Last_Executed_Date IS NULL)))
           AND (   (Recinfo.attribute1 =  X_Attribute1)
                OR (    (Recinfo.attribute1 IS NULL)
                    AND (X_Attribute1 IS NULL)))
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
           AND (   (Recinfo.attribute10 =  X_Attribute10)
                OR (    (Recinfo.attribute10 IS NULL)
                    AND (X_Attribute10 IS NULL)))
           AND (   (Recinfo.context =  X_Context)
                OR (    (Recinfo.context IS NULL)
                    AND (X_Context IS NULL)))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,

                       X_Recurring_Batch_Id             NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Ledger_Id                      NUMBER,
                       X_Chart_Of_Accounts_Id           NUMBER,
                       X_Period_Set_Name                VARCHAR2,
                       X_Accounted_Period_Type          VARCHAR2,
                       X_Recurring_Batch_Type           VARCHAR2,
                       X_Security_Flag                  VARCHAR2,
                       X_Name                           VARCHAR2,
                       X_Budget_Flag                    VARCHAR2,
                       X_Allocation_Flag                VARCHAR2,
                       X_Last_Update_Login              NUMBER,
                       X_Budget_In_Formula_Flag         VARCHAR2,
                       X_Description                    VARCHAR2,
                       X_Period_Type                    VARCHAR2,
                       X_Last_Executed_Period_Name      VARCHAR2,
                       X_Last_Executed_Date             DATE,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Context                        VARCHAR2

  ) IS
  BEGIN

-- Consolidating call to check unique to save on round trips
-- check_unique(X_rowid, X_name, X_Set_Of_Books_Id);
check_unique(X_rowid, X_name, X_Chart_Of_Accounts_Id, X_Period_Set_Name, X_Accounted_Period_Type);


    UPDATE gl_recurring_batches
    SET
       recurring_batch_id              =     X_Recurring_Batch_Id,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       ledger_id                       =     X_Ledger_Id,
       chart_of_accounts_id            =     X_Chart_Of_Accounts_Id,
       period_set_name                 =     X_Period_Set_Name,
       accounted_period_type           =     X_Accounted_Period_Type,
       recurring_batch_type            =     X_Recurring_Batch_Type,
       security_flag                   =     X_Security_Flag,
       name                            =     X_Name,
       budget_flag                     =     X_Budget_Flag,
       allocation_flag                 =     X_Allocation_Flag,
       last_update_login               =     X_Last_Update_Login,
       budget_in_formula_flag          =     X_Budget_In_Formula_Flag,
       description                     =     X_Description,
       period_type                     =     X_Period_Type,
       last_executed_period_name       =     X_Last_Executed_Period_Name,
       last_executed_date              =     X_Last_Executed_Date,
       attribute1                      =     X_Attribute1,
       attribute2                      =     X_Attribute2,
       attribute3                      =     X_Attribute3,
       attribute4                      =     X_Attribute4,
       attribute5                      =     X_Attribute5,
       attribute6                      =     X_Attribute6,
       attribute7                      =     X_Attribute7,
       attribute8                      =     X_Attribute8,
       attribute9                      =     X_Attribute9,
       attribute10                     =     X_Attribute10,
       context                         =     X_Context
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;





  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
    CURSOR chk_autoalloc_set is
      SELECT 'Batch used in AutoAlloc set'
      FROM   GL_RECURRING_BATCHES rb, GL_AUTO_ALLOC_BATCHES aab
      WHERE  rb.rowid = X_Rowid
      AND    aab.batch_id = rb.recurring_batch_id;
    dummy VARCHAR2(100);
  BEGIN
    OPEN chk_autoalloc_set;
    FETCH chk_autoalloc_set INTO dummy;

    IF chk_autoalloc_set%FOUND THEN
      CLOSE chk_autoalloc_set;
      fnd_message.set_name('SQLGL', 'GL_RJE_USED_IN_ALLOC_SET');
      app_exception.raise_exception;
    END IF;

    CLOSE chk_autoalloc_set;

    DELETE FROM gl_recurring_batches
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;

PROCEDURE check_batch(X_Recurring_Batch_Id NUMBER) IS
  CURSOR chk_autoalloc_set IS
	SELECT 'Batch used in AutoAlloc set'
	FROM GL_AUTO_ALLOC_BATCHES aab
        WHERE aab.batch_id = X_Recurring_Batch_Id;
  dummy 	VARCHAR2(100);
BEGIN
  -- Make sure that this recurring batch is not being used by any
  -- of the AutoAllocation set
    OPEN chk_autoalloc_set;
    FETCH chk_autoalloc_set INTO dummy;

    IF (chk_autoalloc_set%NOTFOUND) THEN
      CLOSE chk_autoalloc_set;
    ELSE
      -- it is being used by some AutoAllocation sets, exit
      CLOSE chk_autoalloc_set;
      fnd_message.set_name('SQLGL', 'GL_RJE_USED_IN_ALLOC_SET');
      app_exception.raise_exception;
    END IF;

END check_batch;



-- **********************************************************************


END GL_RECURRING_BATCHES_PKG;

/
