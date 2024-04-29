--------------------------------------------------------
--  DDL for Package Body GL_ALLOC_BATCHES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_ALLOC_BATCHES_PKG" AS
/* $Header: glimabab.pls 120.5.12010000.2 2009/07/13 06:25:18 sommukhe ship $ */

--
-- PUBLIC FUNCTIONS
--

  PROCEDURE check_unique(batch_name VARCHAR2, row_id VARCHAR2, coa_id NUMBER) IS
    CURSOR chk_duplicates is
      SELECT 'Duplicate'
      FROM   GL_ALLOC_BATCHES gab
      WHERE  gab.name = batch_name
      AND    (   row_id is null
              OR gab.rowid <> row_id)
      AND    gab.chart_of_accounts_id = coa_id;
    dummy VARCHAR2(100);
  BEGIN
    OPEN chk_duplicates;
    FETCH chk_duplicates INTO dummy;

    IF chk_duplicates%FOUND THEN
      CLOSE chk_duplicates;
      fnd_message.set_name('SQLGL', 'GL_DUPLICATE_ALLOC_BATCH_NAME');
      app_exception.raise_exception;
    END IF;

    CLOSE chk_duplicates;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE', 'gl_alloc_batches_pkg.check_unique');
      RAISE;
  END check_unique;

  FUNCTION get_unique_id RETURN NUMBER IS
    CURSOR get_new_id IS
      SELECT gl_alloc_batches_s.NEXTVAL
      FROM dual;
    new_id number;
  BEGIN
    OPEN get_new_id;
    FETCH get_new_id INTO new_id;

    IF get_new_id%FOUND THEN
      CLOSE get_new_id;
      return(new_id);
    ELSE
      CLOSE get_new_id;
      fnd_message.set_name('SQLGL', 'GL_ERROR_GETTING_UNIQUE_ID');
      fnd_message.set_token('SEQUENCE', 'GL_ALLOC_BATCHES_S');
      app_exception.raise_exception;
    END IF;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE', 'gl_alloc_batches_pkg.get_unique_id');
      RAISE;
  END get_unique_id;

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Allocation_Batch_Id     IN OUT NOCOPY NUMBER,
                       X_Name                           VARCHAR2,
                       X_Chart_Of_Accounts_Id           NUMBER,
                       X_Actual_Flag                    VARCHAR2,
                       X_Security_Flag                  VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Description                    VARCHAR2,
		       X_Validation_Status              VARCHAR2,
		       X_Validation_Request_Id          NUMBER
   ) IS
     CURSOR C IS SELECT rowid FROM GL_ALLOC_BATCHES
                 WHERE allocation_batch_id = X_Allocation_Batch_Id;

    BEGIN

      -- Get batch id if it was not provided
      IF (X_allocation_batch_id IS NULL) THEN
        x_allocation_batch_id := gl_alloc_batches_pkg.get_unique_id;
      END IF;

      INSERT INTO GL_ALLOC_BATCHES(
               allocation_batch_id,
               name,
               chart_of_accounts_id,
               validation_status,
               actual_flag,
               security_flag,
               last_update_date,
               last_updated_by,
               creation_date,
               created_by,
               last_update_login,
	       validation_request_id,--included -- new project
               description
             ) VALUES (
               X_Allocation_Batch_Id,
               X_Name,
               X_Chart_Of_Accounts_Id,
               X_Validation_Status,--removed 'N' -- new project
               X_Actual_Flag,
               X_Security_Flag,
               X_Last_Update_Date,
               X_Last_Updated_By,
               X_Creation_Date,
               X_Created_By,
               X_Last_Update_Login,
	       X_Validation_Request_Id,
               X_Description --included -- new project
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
                     X_Allocation_Batch_Id              NUMBER,
                     X_Name                             VARCHAR2,
                     X_Chart_Of_Accounts_Id             NUMBER,
                     X_Actual_Flag                      VARCHAR2,
                     X_Security_Flag                    VARCHAR2,
                     X_Description                      VARCHAR2,
		     X_Validation_Status                VARCHAR2,
		     X_Validation_Request_Id            NUMBER

  ) IS
    CURSOR C IS
        SELECT *
        FROM   GL_ALLOC_BATCHES
        WHERE  rowid = X_Rowid
        FOR UPDATE of Allocation_Batch_Id NOWAIT;
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
               (Recinfo.allocation_batch_id = X_Allocation_Batch_Id)
           AND (Recinfo.name = X_Name)
           AND (Recinfo.chart_of_accounts_id = X_Chart_Of_Accounts_Id)
           AND (Recinfo.validation_status = X_Validation_Status)
           AND (Recinfo.actual_flag = X_Actual_Flag)
	   AND (   (Recinfo.validation_request_id = X_Validation_Request_Id)
                OR (    (Recinfo.validation_request_id IS NULL)
                    AND (X_Validation_Request_Id IS NULL)))
           AND (Recinfo.security_flag = X_Security_Flag)
           AND (   (Recinfo.description = X_Description)
                OR (    (Recinfo.description IS NULL)
                    AND (X_Description IS NULL)))

            ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.RAISE_EXCEPTION;
    end if;
  END Lock_Row;



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Allocation_Batch_Id            NUMBER,
                       X_Name                           VARCHAR2,
                       X_Chart_Of_Accounts_Id           NUMBER,
                       X_Actual_Flag                    VARCHAR2,
                       X_Security_Flag                  VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Description                    VARCHAR2,
		       X_Validation_Status              VARCHAR2,
		       X_Validation_Request_Id          NUMBER

 ) IS
 BEGIN
   UPDATE GL_ALLOC_BATCHES
   SET
     allocation_batch_id               =     X_Allocation_Batch_Id,
     name                              =     X_Name,
     chart_of_accounts_id              =     X_Chart_Of_Accounts_Id,
     actual_flag                       =     X_Actual_Flag,
     security_flag                     =     X_Security_Flag,
     Validation_Status                 =     X_Validation_Status,
     last_update_date                  =     X_Last_Update_Date,
     last_updated_by                   =     X_Last_Updated_By,
     last_update_login                 =     X_Last_Update_Login,
     description                       =     X_Description
   WHERE rowid = X_rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

  END Update_Row;

  PROCEDURE Delete_Row(Allocation_Batch_Id NUMBER, X_Rowid VARCHAR2) IS
    CURSOR chk_autoalloc_set is
      SELECT 'Batch used in AutoAlloc set'
      FROM   GL_AUTO_ALLOC_BATCHES aab
      WHERE  aab.batch_id = Allocation_Batch_Id;
    dummy VARCHAR2(100);
  BEGIN
    -- Make sure that this allocation batch is not being used by any
    -- of the AutoAllocation set
    OPEN chk_autoalloc_set;
    FETCH chk_autoalloc_set INTO dummy;

    IF chk_autoalloc_set%FOUND THEN
      CLOSE chk_autoalloc_set;
      fnd_message.set_name('SQLGL', 'GL_BATCH_USED_IN_ALLOC_SET');
      app_exception.raise_exception;
    END IF;

    CLOSE chk_autoalloc_set;

    -- Delete all of the associated formulas
    gl_alloc_formulas_pkg.delete_rows(
      allocation_batch_id);

    DELETE FROM GL_ALLOC_BATCHES
    WHERE  rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;

  PROCEDURE Autocopy(     X_Src_Batch_Id      NUMBER,
                          X_Trg_Batch_Id      NUMBER,
                          X_Last_Updated_By   NUMBER,
                          X_Last_Update_Login NUMBER) IS


  BEGIN

    INSERT INTO GL_ALLOC_FORMULAS(
          allocation_formula_id,
          allocation_batch_id,
          name,
          run_sequence,
          je_category_name,
          full_allocation_flag,
          validation_status,
          conversion_method_code,
          currency_conversion_type,
          last_update_date,
          last_updated_by,
          creation_date,
          created_by,
          last_update_login,
          description
         ) (
          Select
          	gl_alloc_formulas_s.nextval,
          	X_Trg_Batch_Id,
          	f.Name,
          	f.Run_Sequence,
          	f.Je_Category_Name,
          	f.Full_Allocation_Flag,
          	'N',
                f.Conversion_Method_Code,
                f.Currency_Conversion_Type,
          	sysdate,
          	X_Last_Updated_By,
          	sysdate,
          	X_Last_Updated_By,
          	X_Last_Update_Login,
          	f.Description
	  from GL_ALLOC_FORMULAS F
	  where f.Allocation_batch_id = X_Src_Batch_ID
  );


    INSERT INTO GL_ALLOC_FORMULA_LINES(
          allocation_formula_id,
          line_number,
          line_type,
          operator,
          last_update_date,
          last_updated_by,
          creation_date,
          created_by,
          last_update_login,
          amount,
          relative_period,
          period_name,
          transaction_currency,
          ledger_currency,
          currency_type,
          entered_currency,
          actual_flag,
          budget_version_id,
          encumbrance_type_id,
          amount_type,
          ledger_id,
          ledger_action_code,
          segment_types_key,
          segment_break_key,
          segment1,
          segment2,
          segment3,
          segment4,
          segment5,
          segment6,
          segment7,
          segment8,
          segment9,
          segment10,
          segment11,
          segment12,
          segment13,
          segment14,
          segment15,
          segment16,
          segment17,
          segment18,
          segment19,
          segment20,
          segment21,
          segment22,
          segment23,
          segment24,
          segment25,
          segment26,
          segment27,
          segment28,
          segment29,
          segment30
         )  (
          Select
                  New.Allocation_Formula_Id,
                  L.Line_Number,
                  L.Line_Type,
                  L.Operator,
                  sysdate,
                  X_Last_Updated_By,
                  sysdate,
                  X_Last_Updated_By,
                  X_Last_Update_Login,
                  L.Amount,
                  L.Relative_Period,
                  L.Period_Name,
                  L.Transaction_Currency,
                  L.Ledger_Currency,
                  L.Currency_Type,
                  L.Entered_Currency,
                  L.Actual_Flag,
                  L.Budget_Version_Id,
                  L.Encumbrance_Type_Id,
                  L.Amount_Type,
                  L.Ledger_Id,
                  L.Ledger_Action_Code,
                  L.Segment_Types_Key,
                  L.Segment_Break_Key,
                  L.Segment1,
                  L.Segment2,
                  L.Segment3,
                  L.Segment4,
                  L.Segment5,
                  L.Segment6,
                  L.Segment7,
                  L.Segment8,
                  L.Segment9,
                  L.Segment10,
                  L.Segment11,
                  L.Segment12,
                  L.Segment13,
                  L.Segment14,
                  L.Segment15,
                  L.Segment16,
                  L.Segment17,
                  L.Segment18,
                  L.Segment19,
                  L.Segment20,
                  L.Segment21,
                  L.Segment22,
                  L.Segment23,
                  L.Segment24,
                  L.Segment25,
                  L.Segment26,
                  L.Segment27,
                  L.Segment28,
                  L.Segment29,
                  L.Segment30
	   from GL_ALLOC_FORMULA_LINES L, GL_ALLOC_FORMULAS New, GL_ALLOC_FORMULAS Old
	   where L.allocation_formula_id = Old.Allocation_formula_id
	   AND New.allocation_batch_id = X_Trg_Batch_Id
	   AND New.name = Old.name
	   AND Old.allocation_batch_id = X_Src_Batch_Id
  );


  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'GL_ALLOC_BATCHES_PKG.Autocopy');
      RAISE;

  END Autocopy;

PROCEDURE check_batch(X_Alloc_Batch_Id NUMBER) IS
  CURSOR chk_autoalloc_set IS
	SELECT 'Batch used in AutoAlloc set'
	FROM GL_AUTO_ALLOC_BATCHES aab
        WHERE aab.batch_id = X_Alloc_Batch_Id;
  dummy 	VARCHAR2(100);
BEGIN
  -- Make sure that this allocation batch is not being used by any
  -- of the AutoAllocation set
    OPEN chk_autoalloc_set;
    FETCH chk_autoalloc_set INTO dummy;
    IF (chk_autoalloc_set%NOTFOUND) THEN
      CLOSE chk_autoalloc_set;
    ELSE
      -- it is being used by some AutoAllocation sets, exit
      CLOSE chk_autoalloc_set;
      fnd_message.set_name('SQLGL', 'GL_BATCH_USED_IN_ALLOC_SET');
      app_exception.raise_exception;
    END IF;

END check_batch;

END gl_alloc_batches_pkg;

/
