--------------------------------------------------------
--  DDL for Package Body GL_BUDGET_ASSIGNMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_BUDGET_ASSIGNMENT_PKG" AS
/* $Header: glibdasb.pls 120.6 2005/08/25 22:55:46 djogg ship $ */

--
-- PRIVATE FUNCTIONS
--

  --
  -- Procedure
  --   select_row
  -- Purpose
  --   Used to select a particular budget assignment row
  -- History
  --   21-MAR-93  D. J. Ogg    Created
  -- Arguments
  --   recinfo			Various information about the row
  -- Example
  --   gl_budget_assignments_pkg.select_row(recinfo)
  -- Notes
  --
  PROCEDURE select_row( recinfo	IN OUT NOCOPY gl_budget_assignments%ROWTYPE) IS
  BEGIN
    SELECT *
    INTO recinfo
    FROM gl_budget_assignments
    WHERE ledger_id = recinfo.ledger_id
    AND   code_combination_id = recinfo.code_combination_id
    AND   currency_code = recinfo.currency_code
    AND   rownum = 1;
  END SELECT_ROW;


--
-- PUBLIC FUNCTIONS
--

  PROCEDURE check_unique(lgr_id NUMBER, ccid NUMBER, curr_code VARCHAR2,
			 rng_id NUMBER, row_id VARCHAR2) IS
    CURSOR chk_duplicates is
      SELECT 'Duplicate'
      FROM   GL_BUDGET_ASSIGNMENTS ba
      WHERE  ba.ledger_id = lgr_id
      AND    ba.code_combination_id = ccid
      AND    ba.currency_code = curr_code
      AND    ba.range_id = rng_id
      AND    (   row_id is null
              OR ba.rowid <> row_id);
    dummy VARCHAR2(100);
  BEGIN
    OPEN chk_duplicates;
    FETCH chk_duplicates INTO dummy;

    IF chk_duplicates%FOUND THEN
      CLOSE chk_duplicates;
      fnd_message.set_name('SQLGL', 'GL_DUPLICATE_BUD_ASSIGNMENT');
      app_exception.raise_exception;
    END IF;

    CLOSE chk_duplicates;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'gl_budget_assignment_pkg.check_unique');
      RAISE;
  END check_unique;

  PROCEDURE delete_range_assignments(xrange_id NUMBER) IS
  BEGIN
    DELETE GL_BUDGET_ASSIGNMENTS ba
    WHERE ba.range_id = xrange_id;

  EXCEPTION
    WHEN no_data_found THEN
      RETURN;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token(
        'PROCEDURE',
        'gl_budget_assignment_pkg.delete_range_assignments');
      RAISE;
  END delete_range_assignments;


  PROCEDURE delete_assignment(lgr_id NUMBER, ccid NUMBER,
                              curr_code VARCHAR2, rng_id NUMBER) IS
  BEGIN
    DELETE GL_BUDGET_ASSIGNMENTS ba
    WHERE ba.ledger_id = lgr_id
    AND   ba.code_combination_id = ccid
    AND   ba.currency_code = curr_code
    AND   ba.range_id = rng_id
    AND   rownum = 1;

  EXCEPTION
    WHEN no_data_found THEN
      RETURN;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token(
        'PROCEDURE',
        'gl_budget_assignment_pkg.delete_assignment');
      RAISE;
  END delete_assignment;



  FUNCTION is_budget_calculated( xlgr_id         NUMBER,
                                 xccid           NUMBER,
                                 xcurr_code      VARCHAR2 ) RETURN BOOLEAN IS

    CURSOR c IS
      SELECT	'Calculated'
      FROM	gl_budget_assignments ba
      WHERE  	ba.ledger_id = xlgr_id
      AND    	ba.code_combination_id = xccid
      AND       ba.currency_code = xcurr_code
      AND	ba.entry_code = 'C';

    dummy VARCHAR2(100);

  BEGIN
    OPEN  c;
    FETCH c INTO dummy;

    IF c%FOUND THEN
      CLOSE c;
      RETURN( TRUE );
    ELSE
      CLOSE c;
      RETURN( FALSE );
    END IF;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'GL_BUDGET_ASSIGNMENT_PKG.is_budget_calculated');
      RAISE;

  END is_budget_calculated;


  FUNCTION is_acct_stat_enterable( xlgr_id  NUMBER,
                                   xccid    NUMBER ) RETURN BOOLEAN IS

    CURSOR c IS
      SELECT	'Stat Enterable'
      FROM	gl_budget_assignments ba
      WHERE  	ba.ledger_id = xlgr_id
      AND    	ba.code_combination_id = xccid
      AND       ba.currency_code = 'STAT'
      AND	ba.entry_code = 'E';

    dummy VARCHAR2(100);

  BEGIN
    OPEN  c;
    FETCH c INTO dummy;

    IF c%FOUND THEN
      CLOSE c;
      RETURN( TRUE );
    ELSE
      CLOSE c;
      RETURN( FALSE );
    END IF;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'GL_BUDGET_ASSIGNMENT_PKG.is_acct_stat_enterable');
      RAISE;

  END is_acct_stat_enterable;


  PROCEDURE select_columns( xlgr_id		NUMBER,
                            xccid 		NUMBER,
                            xcurr_code		VARCHAR2,
			    xentity_id		IN OUT NOCOPY NUMBER,
			    xentry_code		IN OUT NOCOPY VARCHAR2) IS

    recinfo gl_budget_assignments%ROWTYPE;

  BEGIN
    recinfo.ledger_id := xlgr_id;
    recinfo.code_combination_id := xccid;
    recinfo.currency_code := xcurr_code;

    select_row(recinfo);

    xentity_id := recinfo.budget_entity_id;
    xentry_code := recinfo.entry_code;
  END select_columns;




PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Ledger_Id                           NUMBER,
                     X_Budget_Entity_Id                    NUMBER,
                     X_Code_Combination_Id                 NUMBER,
                     X_Currency_Code                       VARCHAR2,
                     X_Entry_Code                          VARCHAR2,
                     X_Ordering_Value                      VARCHAR2,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Creation_Date                       DATE,
                     X_Created_By                          NUMBER,
                     X_Last_Update_Login                   NUMBER,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Attribute6                          VARCHAR2,
                     X_Attribute7                          VARCHAR2,
                     X_Attribute8                          VARCHAR2,
                     X_Context                             VARCHAR2,
                     X_Range_Id                            NUMBER
 ) IS
   CURSOR C IS SELECT rowid FROM GL_BUDGET_ASSIGNMENTS

             WHERE ledger_id = X_Ledger_Id

             AND   code_combination_id = X_Code_Combination_Id

             AND   currency_code = X_Currency_Code
             AND   range_id = X_Range_Id;

BEGIN

  -- Make sure the budget organization isn't deleted as the range
  -- is being inserted
  gl_budget_entities_pkg.lock_organization(X_BUDGET_ENTITY_ID);

  INSERT INTO GL_BUDGET_ASSIGNMENTS(
          ledger_id,
          budget_entity_id,
          code_combination_id,
          currency_code,
          entry_code,
          ordering_value,
          last_update_date,
          last_updated_by,
          creation_date,
          created_by,
          last_update_login,
          attribute1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          attribute6,
          attribute7,
          attribute8,
          context,
          range_id
         ) VALUES (
          X_Ledger_Id,
          X_Budget_Entity_Id,
          X_Code_Combination_Id,
          X_Currency_Code,
          X_Entry_Code,
          X_Ordering_Value,
          X_Last_Update_Date,
          X_Last_Updated_By,
          X_Creation_Date,
          X_Created_By,
          X_Last_Update_Login,
          X_Attribute1,
          X_Attribute2,
          X_Attribute3,
          X_Attribute4,
          X_Attribute5,
          X_Attribute6,
          X_Attribute7,
          X_Attribute8,
          X_Context,
          X_Range_Id
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

                   X_Ledger_Id                             NUMBER,
                   X_Budget_Entity_Id                      NUMBER,
                   X_Code_Combination_Id                   NUMBER,
                   X_Currency_Code                         VARCHAR2,
                   X_Entry_Code                            VARCHAR2,
                   X_Ordering_Value                        VARCHAR2,
                   X_Attribute1                            VARCHAR2,
                   X_Attribute2                            VARCHAR2,
                   X_Attribute3                            VARCHAR2,
                   X_Attribute4                            VARCHAR2,
                   X_Attribute5                            VARCHAR2,
                   X_Attribute6                            VARCHAR2,
                   X_Attribute7                            VARCHAR2,
                   X_Attribute8                            VARCHAR2,
                   X_Context                               VARCHAR2,
                   X_Range_Id                              NUMBER
) IS
  CURSOR C IS
      SELECT *
      FROM   GL_BUDGET_ASSIGNMENTS
      WHERE  rowid = X_Rowid
      FOR UPDATE of Ledger_Id NOWAIT;
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
          (   (Recinfo.ledger_id = X_Ledger_Id)
           OR (    (Recinfo.ledger_id IS NULL)
               AND (X_Ledger_Id IS NULL)))
      AND (   (Recinfo.budget_entity_id = X_Budget_Entity_Id)
           OR (    (Recinfo.budget_entity_id IS NULL)
               AND (X_Budget_Entity_Id IS NULL)))
      AND (   (Recinfo.code_combination_id = X_Code_Combination_Id)
           OR (    (Recinfo.code_combination_id IS NULL)
               AND (X_Code_Combination_Id IS NULL)))
      AND (   (Recinfo.currency_code = X_Currency_Code)
           OR (    (Recinfo.currency_code IS NULL)
               AND (X_Currency_Code IS NULL)))
      AND (   (Recinfo.entry_code = X_Entry_Code)
           OR (    (Recinfo.entry_code IS NULL)
               AND (X_Entry_Code IS NULL)))
      AND (   (Recinfo.ordering_value = X_Ordering_Value)
           OR (    (Recinfo.ordering_value IS NULL)
               AND (X_Ordering_Value IS NULL)))
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
      AND (   (Recinfo.context = X_Context)
           OR (    (Recinfo.context IS NULL)
               AND (X_Context IS NULL)))
      AND (   (Recinfo.range_id = X_Range_Id)
           OR (    (Recinfo.range_id IS NULL)
               AND (X_Range_Id IS NULL)))
          ) then
    return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
END Lock_Row;

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Ledger_Id                           NUMBER,
                     X_Budget_Entity_Id                    NUMBER,
                     X_Code_Combination_Id                 NUMBER,
                     X_Currency_Code                       VARCHAR2,
                     X_Entry_Code                          VARCHAR2,
                     X_Ordering_Value                      VARCHAR2,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Last_Update_Login                   NUMBER,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Attribute6                          VARCHAR2,
                     X_Attribute7                          VARCHAR2,
                     X_Attribute8                          VARCHAR2,
                     X_Context                             VARCHAR2,
                     X_Range_Id                            NUMBER
) IS
BEGIN
  UPDATE GL_BUDGET_ASSIGNMENTS
  SET

    ledger_id                                 =    X_Ledger_Id,
    budget_entity_id                          =    X_Budget_Entity_Id,
    code_combination_id                       =    X_Code_Combination_Id,
    currency_code                             =    X_Currency_Code,
    entry_code                                =    X_Entry_Code,
    ordering_value                            =    X_Ordering_Value,
    last_update_date                          =    X_Last_Update_Date,
    last_updated_by                           =    X_Last_Updated_By,
    last_update_login                         =    X_Last_Update_Login,
    attribute1                                =    X_Attribute1,
    attribute2                                =    X_Attribute2,
    attribute3                                =    X_Attribute3,
    attribute4                                =    X_Attribute4,
    attribute5                                =    X_Attribute5,
    attribute6                                =    X_Attribute6,
    attribute7                                =    X_Attribute7,
    attribute8                                =    X_Attribute8,
    context                                   =    X_Context,
    range_id                                  =    X_Range_Id
  WHERE rowid = X_rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;

END Update_Row;

PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
BEGIN
  DELETE FROM GL_BUDGET_ASSIGNMENTS
  WHERE  rowid = X_Rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;
END Delete_Row;

END gl_budget_assignment_pkg;

/
