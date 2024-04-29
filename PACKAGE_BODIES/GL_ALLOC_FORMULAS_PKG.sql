--------------------------------------------------------
--  DDL for Package Body GL_ALLOC_FORMULAS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_ALLOC_FORMULAS_PKG" AS
/* $Header: glimafmb.pls 120.6.12010000.2 2009/07/13 06:23:24 sommukhe ship $ */

--
-- PRIVATE FUNCTIONS
--
  --
  -- Procedure
  --   check_ledger_selection
  -- Purpose
  --   Check if the target and offset lines' ledgers are the same.
  -- History
  --   04-18-02  T Cheng      Created
  -- Arguments
  --   X_Allocation_Formula_id         the allocation formula id
  -- Notes
  --
  PROCEDURE check_ledger_selection(X_Allocation_Formula_Id NUMBER) IS
    CURSOR to_ledger_selection IS
      SELECT count(DISTINCT nvl(ledger_id, -1))
      FROM   gl_alloc_formula_lines
      WHERE  allocation_formula_id = X_Allocation_Formula_Id
      AND    line_number in (4, 5);
    counts   NUMBER;
  BEGIN
    OPEN to_ledger_selection;
    FETCH to_ledger_selection INTO counts;
    IF (counts = 2) THEN
      -- target and offset ledgers are both not null and are different
      CLOSE to_ledger_selection;
      fnd_message.set_name('SQLGL', 'GL_ALLOC_INTER_LEDGER');
      app_exception.raise_exception;
    END IF;
    CLOSE to_ledger_selection;
  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
  END check_ledger_selection;

--
-- PUBLIC FUNCTIONS
--

  PROCEDURE check_unique(batch_id NUMBER, formula_name VARCHAR2,
			 row_id VARCHAR2) IS
    CURSOR chk_duplicates is
      SELECT 'Duplicate'
      FROM   GL_ALLOC_FORMULAS gaf
      WHERE  gaf.allocation_batch_id = batch_id
      AND    gaf.name = formula_name
      AND    (   row_id is null
              OR gaf.rowid <> row_id);
    dummy VARCHAR2(100);
  BEGIN
    OPEN chk_duplicates;
    FETCH chk_duplicates INTO dummy;

    IF chk_duplicates%FOUND THEN
      CLOSE chk_duplicates;
      fnd_message.set_name('SQLGL', 'GL_DUPLICATE_ALLOC_FORMULA_NAM');
      app_exception.raise_exception;
    END IF;

    CLOSE chk_duplicates;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE', 'gl_alloc_formulas_pkg.check_unique');
      RAISE;
  END check_unique;


  FUNCTION get_unique_id RETURN NUMBER IS
    CURSOR get_new_id IS
      SELECT gl_alloc_formulas_s.NEXTVAL
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
      fnd_message.set_token('SEQUENCE', 'GL_ALLOC_FORMULAS_S');
      app_exception.raise_exception;
    END IF;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'gl_alloc_formulas_pkg.get_unique_id');
      RAISE;
  END get_unique_id;

  PROCEDURE delete_rows(batch_id NUMBER) IS
  BEGIN
    gl_alloc_form_lines_pkg.delete_batch(batch_id);

    DELETE gl_alloc_formulas
    WHERE  allocation_batch_id = batch_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      null;
  END delete_rows;

PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Allocation_Formula_Id        IN OUT NOCOPY NUMBER,
                     X_Allocation_Batch_Id          IN OUT NOCOPY NUMBER,
                     X_Name                                VARCHAR2,
                     X_Run_Sequence                        NUMBER,
                     X_Je_Category_Name                    VARCHAR2,
                     X_Full_Allocation_Flag                VARCHAR2,
                     X_Conversion_Method_Code              VARCHAR2,
                     X_Currency_Conversion_Type            VARCHAR2,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Creation_Date                       DATE,
                     X_Created_By                          NUMBER,
                     X_Last_Update_Login                   NUMBER,
                     X_Description                         VARCHAR2,
                     X_Actual_Flag                         VARCHAR2,
		     X_Validation_Status                    VARCHAR2
 ) IS
   CURSOR C IS SELECT rowid FROM GL_ALLOC_FORMULAS
               WHERE allocation_formula_id = X_Allocation_Formula_Id;

BEGIN

  -- Get batch id if it was not provided
  IF (x_allocation_batch_id IS NULL) THEN
    x_allocation_batch_id := gl_alloc_batches_pkg.get_unique_id;
  END IF;

  -- Get formula id if it was not provided
  IF (x_allocation_formula_id IS NULL) THEN
    x_allocation_formula_id := gl_alloc_formulas_pkg.get_unique_id;
  END IF;

  -- Make sure the user has completed all of the formula
  -- lines.
  IF (NOT gl_alloc_form_lines_pkg.complete_formula(
        X_allocation_formula_id,
        X_actual_flag)) THEN
    IF (X_actual_flag = 'B') THEN
      fnd_message.set_name('SQLGL', 'GL_COMPLETE_FOUR_FORMULA_LINES');
      app_exception.raise_exception;
    ELSE
      fnd_message.set_name('SQLGL', 'GL_COMPLETE_ALL_FORMULA_LINES');
      app_exception.raise_exception;
    END IF;
  END IF;

  -- Make sure the ledger segment of target and offset lines are the same
  check_ledger_selection(X_Allocation_Formula_Id);

  -- Make sure there isn't a currency conflict
  gl_alloc_form_lines_pkg.check_target_ledger(X_Allocation_Formula_Id);

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
         ) VALUES (
          X_Allocation_Formula_Id,
          X_Allocation_Batch_Id,
          X_Name,
          X_Run_Sequence,
          X_Je_Category_Name,
          X_Full_Allocation_Flag,
          X_Validation_Status,
          X_Conversion_Method_Code,
          X_Currency_Conversion_Type,
          X_Last_Update_Date,
          X_Last_Updated_By,
          X_Creation_Date,
          X_Created_By,
          X_Last_Update_Login,
          X_Description
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
                   X_Allocation_Formula_Id                 NUMBER,
                   X_Allocation_Batch_Id                   NUMBER,
                   X_Name                                  VARCHAR2,
                   X_Run_Sequence                          NUMBER,
                   X_Je_Category_Name                      VARCHAR2,
                   X_Full_Allocation_Flag                  VARCHAR2,
                   X_Conversion_Method_Code                VARCHAR2,
                   X_Currency_Conversion_Type              VARCHAR2,
                   X_Description                           VARCHAR2,
                   X_Validation_Status                    VARCHAR2
) IS
  CURSOR C IS
      SELECT *
      FROM   GL_ALLOC_FORMULAS
      WHERE  rowid = X_Rowid
      FOR UPDATE of Allocation_Formula_Id NOWAIT;
  Recinfo C%ROWTYPE;
BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
  if (C%NOTFOUND) then
    CLOSE C;
    FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
  CLOSE C;
  if (
          (   (Recinfo.allocation_formula_id = X_Allocation_Formula_Id)
           OR (    (Recinfo.allocation_formula_id IS NULL)
               AND (X_Allocation_Formula_Id IS NULL)))
      AND (   (Recinfo.allocation_batch_id = X_Allocation_Batch_Id)
           OR (    (Recinfo.allocation_batch_id IS NULL)
               AND (X_Allocation_Batch_Id IS NULL)))
      AND (   (Recinfo.name = X_Name)
           OR (    (Recinfo.name IS NULL)
               AND (X_Name IS NULL)))
      AND (   (Recinfo.run_sequence = X_Run_Sequence)
           OR (    (Recinfo.run_sequence IS NULL)
               AND (X_Run_Sequence IS NULL)))
      AND (   (Recinfo.je_category_name = X_Je_Category_Name)
           OR (    (Recinfo.je_category_name IS NULL)
               AND (X_Je_Category_Name IS NULL)))
      AND (   (Recinfo.full_allocation_flag = X_Full_Allocation_Flag)
           OR (    (Recinfo.full_allocation_flag IS NULL)
               AND (X_Full_Allocation_Flag IS NULL)))
      AND (   (Recinfo.validation_status = X_Validation_Status)
           OR (    (Recinfo.validation_status IS NULL)
               AND (X_Validation_Status IS NULL)))
      AND (   (Recinfo.conversion_method_code = X_Conversion_Method_Code)
           OR (    (Recinfo.conversion_method_code IS NULL)
               AND (X_Conversion_Method_Code IS NULL)))
      AND (   (Recinfo.currency_conversion_type = X_Currency_Conversion_Type)
           OR (    (Recinfo.currency_conversion_type IS NULL)
               AND (X_Currency_Conversion_Type IS NULL)))
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

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Allocation_Formula_Id               NUMBER,
                     X_Allocation_Batch_Id                 NUMBER,
                     X_Name                                VARCHAR2,
                     X_Run_Sequence                        NUMBER,
                     X_Je_Category_Name                    VARCHAR2,
                     X_Full_Allocation_Flag                VARCHAR2,
                     X_Conversion_Method_Code              VARCHAR2,
                     X_Currency_Conversion_Type            VARCHAR2,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Last_Update_Login                   NUMBER,
                     X_Description                         VARCHAR2,
                     X_Actual_Flag                         VARCHAR2,
		     X_Transaction_Currency		   VARCHAR2,
		     Currency_Changed	   IN OUT NOCOPY   VARCHAR2,
		     X_Validation_Status                    VARCHAR2
) IS
BEGIN
  -- Make sure the user has completed all of the formula
  -- lines.
  IF (NOT gl_alloc_form_lines_pkg.complete_formula(
        X_allocation_formula_id,
        X_actual_flag)) THEN
    IF (X_actual_flag = 'B') THEN
      fnd_message.set_name('SQLGL', 'GL_COMPLETE_FOUR_FORMULA_LINES');
      app_exception.raise_exception;
    ELSE
      fnd_message.set_name('SQLGL', 'GL_COMPLETE_ALL_FORMULA_LINES');
      app_exception.raise_exception;
    END IF;
  END IF;

  -- If the user has changed the currency, then update the lines
  IF (gl_alloc_form_lines_pkg.currency_changed(
	X_Allocation_Formula_Id,
	X_Transaction_Currency)
      OR X_Conversion_Method_Code = 'CV') THEN
    gl_alloc_form_lines_pkg.update_currency(
        X_Allocation_Formula_id,
        X_Transaction_Currency,
        X_Conversion_Method_Code);
    Currency_Changed := 'Y';
  ELSE
    Currency_Changed := 'N';
  END IF;

  -- Make sure the ledger segment of target and offset lines are the same
  check_ledger_selection(X_Allocation_Formula_Id);

  IF (Currency_Changed = 'Y') THEN
    -- Make sure there isn't a currency conflict
    gl_alloc_form_lines_pkg.check_target_ledger(X_Allocation_Formula_Id);
  END IF;

  UPDATE GL_ALLOC_FORMULAS
  SET
    allocation_formula_id                     =    X_Allocation_Formula_Id,
    allocation_batch_id                       =    X_Allocation_Batch_Id,
    name                                      =    X_Name,
    run_sequence                              =    X_Run_Sequence,
    je_category_name                          =    X_Je_Category_Name,
    full_allocation_flag                      =    X_Full_Allocation_Flag,
    validation_status                         =    X_Validation_Status,
    conversion_method_code                    =    X_Conversion_Method_Code,
    currency_conversion_type                  =    X_Currency_Conversion_Type,
    last_update_date                          =    X_Last_Update_Date,
    last_updated_by                           =    X_Last_Updated_By,
    last_update_login                         =    X_Last_Update_Login,
    description                               =    X_Description
  WHERE rowid = X_rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;

END Update_Row;

PROCEDURE Delete_Row(Allocation_formula_id NUMBER, X_Rowid VARCHAR2) IS
BEGIN

  -- Delete all of the associated formula lines
  gl_alloc_form_lines_pkg.delete_rows(
    allocation_formula_id);

  -- Delete the formula
  DELETE FROM GL_ALLOC_FORMULAS
  WHERE  rowid = X_Rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;
END Delete_Row;

END gl_alloc_formulas_pkg;

/
