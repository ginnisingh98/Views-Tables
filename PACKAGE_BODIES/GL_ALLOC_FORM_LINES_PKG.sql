--------------------------------------------------------
--  DDL for Package Body GL_ALLOC_FORM_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_ALLOC_FORM_LINES_PKG" AS
/* $Header: glimaflb.pls 120.6.12010000.2 2009/06/19 09:16:43 akhanapu ship $ */

--
-- PUBLIC FUNCTIONS
--

  FUNCTION complete_formula(formula_id  NUMBER,
                            actual_flag VARCHAR2) RETURN BOOLEAN IS
    CURSOR count_lines is
      SELECT count(*)
      FROM   GL_ALLOC_FORMULA_LINES gafl
      WHERE  gafl.allocation_formula_id = formula_id;

    line_count     NUMBER;
  BEGIN
    line_count := 0;

    OPEN count_lines;
    FETCH count_lines INTO line_count;

    IF (line_count = 5) THEN
      CLOSE count_lines;
      RETURN(TRUE);
    ELSIF (    (actual_flag = 'B')
           AND (line_count = 4)) THEN
      CLOSE count_lines;
      RETURN(TRUE);
    ELSE
      CLOSE count_lines;
      RETURN(FALSE);
    END IF;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token(
        'PROCEDURE', 'gl_alloc_formula_lines_pkg.complete_formula');
      RAISE;
  END complete_formula;

  PROCEDURE delete_rows(formula_id NUMBER) IS
  BEGIN
    DELETE gl_alloc_formula_lines
    WHERE  allocation_formula_id = formula_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      null;
  END delete_rows;

  PROCEDURE delete_batch(batch_id NUMBER) IS
  BEGIN
    DELETE gl_alloc_formula_lines
    WHERE  allocation_formula_id IN
      (SELECT allocation_formula_id
       FROM   gl_alloc_formulas
       WHERE  allocation_batch_id = batch_id);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      null;
  END delete_batch;

  PROCEDURE validate_ledger_action(x_object_type_code	           VARCHAR2,
                                   x_segment_types_key_full        VARCHAR2) IS
    original_ledger_action VARCHAR2(1) :=
                           SUBSTR(x_segment_types_key_full, 1, 1);
  BEGIN
    IF (x_object_type_code = 'L' and original_ledger_action <> 'C') THEN
      fnd_message.set_name('SQLGL', 'GL_ALLOC_ACTION_FOR_LEDGER');
      app_exception.raise_exception;
    ELSIF (x_object_type_code = 'S' and original_ledger_action = 'C') THEN
      fnd_message.set_name('SQLGL', 'GL_ALLOC_ACTION_FOR_LEDGER_SET');
      app_exception.raise_exception;
    END IF;
  EXCEPTION
    WHEN app_exception.application_exception THEN
      RAISE;
  END validate_ledger_action;

  PROCEDURE check_target_ledger(x_allocation_formula_id NUMBER) IS
    CURSOR target_line IS
      SELECT ledger_id, actual_flag, transaction_currency
      FROM   gl_alloc_formula_lines
      WHERE  allocation_formula_id = x_allocation_formula_id
      AND    line_number = 4;

    target_ledger_id    NUMBER;
    target_actual_flag  VARCHAR2(1);
    transaction_curr    VARCHAR2(15);
  BEGIN
    OPEN target_line;
    FETCH target_line INTO target_ledger_id,
                           target_actual_flag,
                           transaction_curr;
    CLOSE target_line;

    IF (target_ledger_id IS NULL OR target_actual_flag = 'A') THEN
      RETURN;
    END IF;

    check_target_ledger_currency(target_ledger_id,
                                 transaction_curr,
                                 target_actual_flag);

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
  END check_target_ledger;

  PROCEDURE check_target_ledger_currency(x_ledger_id NUMBER,
                                         x_ledger_currency VARCHAR2,
                                         x_actual_flag VARCHAR2) IS
    CURSOR ledger_object_type IS
      SELECT object_type_code, currency_code
      FROM   gl_ledgers
      WHERE  ledger_id = x_ledger_id;

    CURSOR mismatch_curr IS
      SELECT 'different currency'
      FROM   gl_ledgers ldg,
             gl_ledger_set_assignments lsa
      WHERE  lsa.ledger_set_id = x_ledger_id
      AND    ldg.ledger_id = lsa.ledger_id
      AND    ldg.object_type_code = 'L'
      AND    ldg.currency_code <> x_ledger_currency
      AND    rownum = 1;

    obj_type_code	VARCHAR2(1);
    curr_code		VARCHAR2(15);
    dummy		VARCHAR2(20);
    dummy_num           NUMBER;
  BEGIN
    OPEN ledger_object_type;
    FETCH ledger_object_type INTO obj_type_code, curr_code;
    CLOSE ledger_object_type;

    IF (obj_type_code = 'L') THEN
      IF (   curr_code = x_ledger_currency
          OR x_ledger_currency = 'STAT') THEN
        RETURN;
      END IF;

    ELSE  -- Ledger Set
      IF (x_ledger_currency = 'STAT') THEN
        SELECT count(DISTINCT ldg.currency_code)
        INTO   dummy_num
        FROM  gl_ledgers ldg, gl_ledger_set_assignments lsa
        WHERE lsa.ledger_set_id = x_ledger_id
        AND   ldg.ledger_id = lsa.ledger_id
        AND   ldg.object_type_code = 'L';

        IF (dummy_num <= 1) THEN
          RETURN;
        END IF;

      ELSE
        OPEN mismatch_curr;
        FETCH mismatch_curr INTO dummy;
        IF (mismatch_curr%NOTFOUND) THEN
          CLOSE mismatch_curr;
          RETURN;
        END IF;
        CLOSE mismatch_curr;

      END IF;
    END IF;

    -- if we reach here, we have a violation
    IF (x_actual_flag = 'E') THEN
      fnd_message.set_name('SQLGL', 'GL_ALLOC_CURR_BAL_TYPE_CONFLCT');
    ELSE
      fnd_message.set_name('SQLGL', 'GL_ALLOC_BUD_CURR_BAL_CONFLICT');
    END IF;
    app_exception.raise_exception;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
  END check_target_ledger_currency;


  PROCEDURE update_currency(formula_id 			NUMBER,
			    transaction_currency	VARCHAR2,
			    conversion_method		VARCHAR2) IS
    CURSOR check_curr IS
      SELECT 'x'
      FROM   gl_alloc_formula_lines
      WHERE  allocation_formula_id = formula_id
      AND    line_number = 1
      AND    (   (    currency_type = 'T'
                  AND ledger_currency <> update_currency.transaction_currency)
              OR (    currency_type = 'E'
                  AND entered_currency <> update_currency.transaction_currency));

    dummy VARCHAR2(1);
  BEGIN
    IF (    conversion_method = 'CV'
        AND update_currency.transaction_currency <> 'STAT') THEN
      OPEN check_curr;
      FETCH check_curr INTO dummy;
      IF (check_curr%FOUND) THEN
        CLOSE check_curr;
        fnd_message.set_name('SQLGL', 'GL_ALLOC_A_LEDGER_CURR_ERR');
        app_exception.raise_exception;
      ELSIF (check_curr%NOTFOUND) THEN
        null;
      END IF;
      CLOSE check_curr;

    END IF;

    UPDATE gl_alloc_formula_lines
    SET    transaction_currency = update_currency.transaction_currency
    WHERE  allocation_formula_id = formula_id;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      null;
    WHEN app_exceptions.application_exception THEN
      RAISE;
  END update_currency;


  FUNCTION currency_changed(formula_id 	   	   NUMBER,
			    transaction_currency   VARCHAR2) RETURN BOOLEAN IS
    CURSOR check_lines is
      SELECT 'Changed'
      FROM   GL_ALLOC_FORMULA_LINES gafl
      WHERE  gafl.allocation_formula_id = currency_changed.formula_id
      AND    gafl.amount IS NULL
      AND    gafl.transaction_currency <> currency_changed.transaction_currency
      AND    rownum < 2;

    dummy     VARCHAR2(100);
  BEGIN
    OPEN check_lines;
    FETCH check_lines INTO dummy;
    if (check_lines%NOTFOUND) then
      CLOSE check_lines;
      RETURN FALSE;
    else
      CLOSE check_lines;
      RETURN TRUE;
    end if;
  END currency_changed;


PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Allocation_Formula_Id        IN OUT NOCOPY NUMBER,
                     X_Line_Number                         NUMBER,
                     X_Line_Type                           VARCHAR2,
                     X_Operator                            VARCHAR2,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Creation_Date                       DATE,
                     X_Created_By                          NUMBER,
                     X_Last_Update_Login                   NUMBER,
                     X_Amount                              NUMBER,
                     X_Relative_Period                     VARCHAR2,
                     X_Period_Name                         VARCHAR2,
                     X_Transaction_Currency                VARCHAR2,
                     X_Ledger_Currency                     VARCHAR2,
                     X_Currency_Type                       VARCHAR2,
                     X_Entered_Currency                    VARCHAR2,
                     X_Actual_Flag                         VARCHAR2,
                     X_Budget_Version_Id                   NUMBER,
                     X_Encumbrance_Type_Id                 NUMBER,
                     X_Amount_Type                         VARCHAR2,
                     X_Ledger_Id                           NUMBER,
                     X_Segment_Types_Key_Full              VARCHAR2,
                     X_Segment_Break_Key                   VARCHAR2,
                     X_Segment1                            VARCHAR2,
                     X_Segment2                            VARCHAR2,
                     X_Segment3                            VARCHAR2,
                     X_Segment4                            VARCHAR2,
                     X_Segment5                            VARCHAR2,
                     X_Segment6                            VARCHAR2,
                     X_Segment7                            VARCHAR2,
                     X_Segment8                            VARCHAR2,
                     X_Segment9                            VARCHAR2,
                     X_Segment10                           VARCHAR2,
                     X_Segment11                           VARCHAR2,
                     X_Segment12                           VARCHAR2,
                     X_Segment13                           VARCHAR2,
                     X_Segment14                           VARCHAR2,
                     X_Segment15                           VARCHAR2,
                     X_Segment16                           VARCHAR2,
                     X_Segment17                           VARCHAR2,
                     X_Segment18                           VARCHAR2,
                     X_Segment19                           VARCHAR2,
                     X_Segment20                           VARCHAR2,
                     X_Segment21                           VARCHAR2,
                     X_Segment22                           VARCHAR2,
                     X_Segment23                           VARCHAR2,
                     X_Segment24                           VARCHAR2,
                     X_Segment25                           VARCHAR2,
                     X_Segment26                           VARCHAR2,
                     X_Segment27                           VARCHAR2,
                     X_Segment28                           VARCHAR2,
                     X_Segment29                           VARCHAR2,
                     X_Segment30                           VARCHAR2
 ) IS
   CURSOR C IS SELECT rowid FROM GL_ALLOC_FORMULA_LINES
             WHERE allocation_formula_id = X_Allocation_Formula_Id
             AND   line_number = X_Line_Number;

BEGIN

  -- Get formula id if it was not provided
  IF (x_allocation_formula_id IS NULL) THEN
    x_allocation_formula_id := gl_alloc_formulas_pkg.get_unique_id;
  END IF;

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
         ) VALUES (
          X_Allocation_Formula_Id,
          X_Line_Number,
          X_Line_Type,
          X_Operator,
          X_Last_Update_Date,
          X_Last_Updated_By,
          X_Creation_Date,
          X_Created_By,
          X_Last_Update_Login,
          X_Amount,
          X_Relative_Period,
          X_Period_Name,
          X_Transaction_Currency,
          X_Ledger_Currency,
          X_Currency_Type,
          X_Entered_Currency,
          X_Actual_Flag,
          X_Budget_Version_Id,
          X_Encumbrance_Type_Id,
          X_Amount_Type,
          X_Ledger_Id,
          SUBSTR(X_Segment_Types_Key_Full, 1, 1),
          SUBSTR(X_Segment_Types_Key_Full, 3),
          X_Segment_Break_Key,
          X_Segment1,
          X_Segment2,
          X_Segment3,
          X_Segment4,
          X_Segment5,
          X_Segment6,
          X_Segment7,
          X_Segment8,
          X_Segment9,
          X_Segment10,
          X_Segment11,
          X_Segment12,
          X_Segment13,
          X_Segment14,
          X_Segment15,
          X_Segment16,
          X_Segment17,
          X_Segment18,
          X_Segment19,
          X_Segment20,
          X_Segment21,
          X_Segment22,
          X_Segment23,
          X_Segment24,
          X_Segment25,
          X_Segment26,
          X_Segment27,
          X_Segment28,
          X_Segment29,
          X_Segment30
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
                   X_Line_Number                           NUMBER,
                   X_Line_Type                             VARCHAR2,
                   X_Operator                              VARCHAR2,
                   X_Amount                                NUMBER,
                   X_Relative_Period                       VARCHAR2,
                   X_Period_Name                           VARCHAR2,
                   X_Transaction_Currency                  VARCHAR2,
                   X_Ledger_Currency                       VARCHAR2,
                   X_Currency_Type                         VARCHAR2,
                   X_Entered_Currency                      VARCHAR2,
                   X_Actual_Flag                           VARCHAR2,
                   X_Budget_Version_Id                     NUMBER,
                   X_Encumbrance_Type_Id                   NUMBER,
                   X_Amount_Type                           VARCHAR2,
                   X_Ledger_Id                             NUMBER,
                   X_Segment_Types_Key_Full                VARCHAR2,
                   X_Segment_Break_Key                     VARCHAR2,
                   X_Segment1                              VARCHAR2,
                   X_Segment2                              VARCHAR2,
                   X_Segment3                              VARCHAR2,
                   X_Segment4                              VARCHAR2,
                   X_Segment5                              VARCHAR2,
                   X_Segment6                              VARCHAR2,
                   X_Segment7                              VARCHAR2,
                   X_Segment8                              VARCHAR2,
                   X_Segment9                              VARCHAR2,
                   X_Segment10                             VARCHAR2,
                   X_Segment11                             VARCHAR2,
                   X_Segment12                             VARCHAR2,
                   X_Segment13                             VARCHAR2,
                   X_Segment14                             VARCHAR2,
                   X_Segment15                             VARCHAR2,
                   X_Segment16                             VARCHAR2,
                   X_Segment17                             VARCHAR2,
                   X_Segment18                             VARCHAR2,
                   X_Segment19                             VARCHAR2,
                   X_Segment20                             VARCHAR2,
                   X_Segment21                             VARCHAR2,
                   X_Segment22                             VARCHAR2,
                   X_Segment23                             VARCHAR2,
                   X_Segment24                             VARCHAR2,
                   X_Segment25                             VARCHAR2,
                   X_Segment26                             VARCHAR2,
                   X_Segment27                             VARCHAR2,
                   X_Segment28                             VARCHAR2,
                   X_Segment29                             VARCHAR2,
                   X_Segment30                             VARCHAR2
) IS
  CURSOR C IS
      SELECT *
      FROM   GL_ALLOC_FORMULA_LINES
      WHERE  rowid = X_Rowid
      FOR UPDATE of Allocation_Formula_Id NOWAIT;
  Recinfo C%ROWTYPE;

  X_Ledger_Action_Code VARCHAR2(1) := SUBSTR(X_Segment_Types_Key_Full, 1, 1);
  X_Segment_Types_Key  VARCHAR2(60) := SUBSTR(X_Segment_Types_Key_Full, 3, 60);
BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;
  if (
          (   (Recinfo.allocation_formula_id = X_Allocation_Formula_Id)
           OR (    (Recinfo.allocation_formula_id IS NULL)
               AND (X_Allocation_Formula_Id IS NULL)))
      AND (   (Recinfo.line_number = X_Line_Number)
           OR (    (Recinfo.line_number IS NULL)
               AND (X_Line_Number IS NULL)))
      AND (   (Recinfo.line_type = X_Line_Type)
           OR (    (Recinfo.line_type IS NULL)
               AND (X_Line_Type IS NULL)))
      AND (   (Recinfo.operator = X_Operator)
           OR (    (Recinfo.operator IS NULL)
               AND (X_Operator IS NULL)))
      AND (   (Recinfo.amount = X_Amount)
           OR (    (Recinfo.amount IS NULL)
               AND (X_Amount IS NULL)))
      AND (   (Recinfo.relative_period = X_Relative_Period)
           OR (    (Recinfo.relative_period IS NULL)
               AND (X_Relative_Period IS NULL)))
      AND (   (Recinfo.period_name = X_Period_Name)
           OR (    (Recinfo.period_name IS NULL)
               AND (X_Period_Name IS NULL)))
      AND (   (Recinfo.transaction_currency = X_Transaction_Currency)
           OR (    (Recinfo.transaction_currency IS NULL)
               AND (X_Transaction_Currency IS NULL)))
      AND (   (Recinfo.ledger_currency = X_Ledger_Currency)
           OR (    (Recinfo.ledger_currency IS NULL)
               AND (X_Ledger_Currency IS NULL)))
      AND (   (Recinfo.currency_type = X_Currency_Type)
           OR (    (Recinfo.currency_type IS NULL)
               AND (X_Currency_Type IS NULL)))
      AND (   (Recinfo.entered_currency = X_Entered_Currency)
           OR (    (Recinfo.entered_currency IS NULL)
               AND (X_Entered_Currency IS NULL)))
      AND (   (Recinfo.actual_flag = X_Actual_Flag)
           OR (    (Recinfo.actual_flag IS NULL)
               AND (X_Actual_Flag IS NULL)))
      AND (   (Recinfo.budget_version_id = X_Budget_Version_Id)
           OR (    (Recinfo.budget_version_id IS NULL)
               AND (X_Budget_Version_Id IS NULL)))
      AND (   (Recinfo.encumbrance_type_id = X_Encumbrance_Type_Id)
           OR (    (Recinfo.encumbrance_type_id IS NULL)
               AND (X_Encumbrance_Type_Id IS NULL)))
      AND (   (Recinfo.amount_type = X_Amount_Type)
           OR (    (Recinfo.amount_type IS NULL)
               AND (X_Amount_Type IS NULL)))
      AND (   (Recinfo.ledger_id = X_Ledger_Id)
           OR (    (Recinfo.ledger_id IS NULL)
               AND (X_Ledger_Id IS NULL)))
      AND (   (Recinfo.ledger_action_code = X_Ledger_Action_Code)
           OR (    (Recinfo.ledger_action_code IS NULL)
               AND (X_Ledger_Action_Code IS NULL)))
      AND (   (Recinfo.segment_types_key = X_Segment_Types_Key)
           OR (    (Recinfo.segment_types_key IS NULL)
               AND (X_Segment_Types_Key IS NULL)))
      AND (   (Recinfo.segment_break_key = X_Segment_Break_Key)
           OR (    (Recinfo.segment_break_key IS NULL)
               AND (X_Segment_Break_Key IS NULL)))
      AND (   (Recinfo.segment1 = X_Segment1)
           OR (    (Recinfo.segment1 IS NULL)
               AND (X_Segment1 IS NULL)))
      AND (   (Recinfo.segment2 = X_Segment2)
           OR (    (Recinfo.segment2 IS NULL)
               AND (X_Segment2 IS NULL)))
      AND (   (Recinfo.segment3 = X_Segment3)
           OR (    (Recinfo.segment3 IS NULL)
               AND (X_Segment3 IS NULL)))
      AND (   (Recinfo.segment4 = X_Segment4)
           OR (    (Recinfo.segment4 IS NULL)
               AND (X_Segment4 IS NULL)))
      AND (   (Recinfo.segment5 = X_Segment5)
           OR (    (Recinfo.segment5 IS NULL)
               AND (X_Segment5 IS NULL)))
      AND (   (Recinfo.segment6 = X_Segment6)
           OR (    (Recinfo.segment6 IS NULL)
               AND (X_Segment6 IS NULL)))
      AND (   (Recinfo.segment7 = X_Segment7)
           OR (    (Recinfo.segment7 IS NULL)
               AND (X_Segment7 IS NULL)))
      AND (   (Recinfo.segment8 = X_Segment8)
           OR (    (Recinfo.segment8 IS NULL)
               AND (X_Segment8 IS NULL)))
      AND (   (Recinfo.segment9 = X_Segment9)
           OR (    (Recinfo.segment9 IS NULL)
               AND (X_Segment9 IS NULL)))
      AND (   (Recinfo.segment10 = X_Segment10)
           OR (    (Recinfo.segment10 IS NULL)
               AND (X_Segment10 IS NULL)))
      AND (   (Recinfo.segment11 = X_Segment11)
           OR (    (Recinfo.segment11 IS NULL)
               AND (X_Segment11 IS NULL)))
      AND (   (Recinfo.segment12 = X_Segment12)
           OR (    (Recinfo.segment12 IS NULL)
               AND (X_Segment12 IS NULL)))
      AND (   (Recinfo.segment13 = X_Segment13)
           OR (    (Recinfo.segment13 IS NULL)
               AND (X_Segment13 IS NULL)))
      AND (   (Recinfo.segment14 = X_Segment14)
           OR (    (Recinfo.segment14 IS NULL)
               AND (X_Segment14 IS NULL)))
      AND (   (Recinfo.segment15 = X_Segment15)
           OR (    (Recinfo.segment15 IS NULL)
               AND (X_Segment15 IS NULL)))
      AND (   (Recinfo.segment16 = X_Segment16)
           OR (    (Recinfo.segment16 IS NULL)
               AND (X_Segment16 IS NULL)))
      AND (   (Recinfo.segment17 = X_Segment17)
           OR (    (Recinfo.segment17 IS NULL)
               AND (X_Segment17 IS NULL)))
      AND (   (Recinfo.segment18 = X_Segment18)
           OR (    (Recinfo.segment18 IS NULL)
               AND (X_Segment18 IS NULL)))
      AND (   (Recinfo.segment19 = X_Segment19)
           OR (    (Recinfo.segment19 IS NULL)
               AND (X_Segment19 IS NULL)))
      AND (   (Recinfo.segment20 = X_Segment20)
           OR (    (Recinfo.segment20 IS NULL)
               AND (X_Segment20 IS NULL)))
      AND (   (Recinfo.segment21 = X_Segment21)
           OR (    (Recinfo.segment21 IS NULL)
               AND (X_Segment21 IS NULL)))
      AND (   (Recinfo.segment22 = X_Segment22)
           OR (    (Recinfo.segment22 IS NULL)
               AND (X_Segment22 IS NULL)))
      AND (   (Recinfo.segment23 = X_Segment23)
           OR (    (Recinfo.segment23 IS NULL)
               AND (X_Segment23 IS NULL)))
      AND (   (Recinfo.segment24 = X_Segment24)
           OR (    (Recinfo.segment24 IS NULL)
               AND (X_Segment24 IS NULL)))
      AND (   (Recinfo.segment25 = X_Segment25)
           OR (    (Recinfo.segment25 IS NULL)
               AND (X_Segment25 IS NULL)))
      AND (   (Recinfo.segment26 = X_Segment26)
           OR (    (Recinfo.segment26 IS NULL)
               AND (X_Segment26 IS NULL)))
      AND (   (Recinfo.segment27 = X_Segment27)
           OR (    (Recinfo.segment27 IS NULL)
               AND (X_Segment27 IS NULL)))
      AND (   (Recinfo.segment28 = X_Segment28)
           OR (    (Recinfo.segment28 IS NULL)
               AND (X_Segment28 IS NULL)))
      AND (   (Recinfo.segment29 = X_Segment29)
           OR (    (Recinfo.segment29 IS NULL)
               AND (X_Segment29 IS NULL)))
      AND (   (Recinfo.segment30 = X_Segment30)
           OR (    (Recinfo.segment30 IS NULL)
               AND (X_Segment30 IS NULL)))
          ) then
    return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
END Lock_Row;

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Allocation_Formula_Id               NUMBER,
                     X_Line_Number                         NUMBER,
                     X_Line_Type                           VARCHAR2,
                     X_Operator                            VARCHAR2,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Last_Update_Login                   NUMBER,
                     X_Amount                              NUMBER,
                     X_Relative_Period                     VARCHAR2,
                     X_Period_Name                         VARCHAR2,
                     X_Transaction_Currency                VARCHAR2,
                     X_Ledger_Currency                     VARCHAR2,
                     X_Currency_Type                       VARCHAR2,
                     X_Entered_Currency                    VARCHAR2,
                     X_Actual_Flag                         VARCHAR2,
                     X_Budget_Version_Id                   NUMBER,
                     X_Encumbrance_Type_Id                 NUMBER,
                     X_Amount_Type                         VARCHAR2,
                     X_Ledger_Id                           NUMBER,
                     X_Segment_Types_Key_Full              VARCHAR2,
                     X_Segment_Break_Key                   VARCHAR2,
                     X_Segment1                            VARCHAR2,
                     X_Segment2                            VARCHAR2,
                     X_Segment3                            VARCHAR2,
                     X_Segment4                            VARCHAR2,
                     X_Segment5                            VARCHAR2,
                     X_Segment6                            VARCHAR2,
                     X_Segment7                            VARCHAR2,
                     X_Segment8                            VARCHAR2,
                     X_Segment9                            VARCHAR2,
                     X_Segment10                           VARCHAR2,
                     X_Segment11                           VARCHAR2,
                     X_Segment12                           VARCHAR2,
                     X_Segment13                           VARCHAR2,
                     X_Segment14                           VARCHAR2,
                     X_Segment15                           VARCHAR2,
                     X_Segment16                           VARCHAR2,
                     X_Segment17                           VARCHAR2,
                     X_Segment18                           VARCHAR2,
                     X_Segment19                           VARCHAR2,
                     X_Segment20                           VARCHAR2,
                     X_Segment21                           VARCHAR2,
                     X_Segment22                           VARCHAR2,
                     X_Segment23                           VARCHAR2,
                     X_Segment24                           VARCHAR2,
                     X_Segment25                           VARCHAR2,
                     X_Segment26                           VARCHAR2,
                     X_Segment27                           VARCHAR2,
                     X_Segment28                           VARCHAR2,
                     X_Segment29                           VARCHAR2,
                     X_Segment30                           VARCHAR2
) IS
BEGIN
  UPDATE GL_ALLOC_FORMULA_LINES
  SET

    allocation_formula_id           =    X_Allocation_Formula_Id,
    line_number                     =    X_Line_Number,
    line_type                       =    X_Line_Type,
    operator                        =    X_Operator,
    last_update_date                =    X_Last_Update_Date,
    last_updated_by                 =    X_Last_Updated_By,
    last_update_login               =    X_Last_Update_Login,
    amount                          =    X_Amount,
    relative_period                 =    X_Relative_Period,
    period_name                     =    X_Period_Name,
    transaction_currency            =    X_Transaction_Currency,
    ledger_currency                 =    X_Ledger_Currency,
    currency_type                   =    X_Currency_Type,
    entered_currency                =    X_Entered_Currency,
    actual_flag                     =    X_Actual_Flag,
    budget_version_id               =    X_Budget_Version_Id,
    encumbrance_type_id             =    X_Encumbrance_Type_Id,
    amount_type                     =    X_Amount_Type,
    ledger_id                       =    X_Ledger_Id,
    ledger_action_code              =    SUBSTR(X_Segment_Types_Key_Full, 1, 1),
    segment_types_key               =    SUBSTR(X_Segment_Types_Key_Full, 3),
    segment_break_key               =    X_Segment_Break_Key,
    segment1                        =    X_Segment1,
    segment2                        =    X_Segment2,
    segment3                        =    X_Segment3,
    segment4                        =    X_Segment4,
    segment5                        =    X_Segment5,
    segment6                        =    X_Segment6,
    segment7                        =    X_Segment7,
    segment8                        =    X_Segment8,
    segment9                        =    X_Segment9,
    segment10                       =    X_Segment10,
    segment11                       =    X_Segment11,
    segment12                       =    X_Segment12,
    segment13                       =    X_Segment13,
    segment14                       =    X_Segment14,
    segment15                       =    X_Segment15,
    segment16                       =    X_Segment16,
    segment17                       =    X_Segment17,
    segment18                       =    X_Segment18,
    segment19                       =    X_Segment19,
    segment20                       =    X_Segment20,
    segment21                       =    X_Segment21,
    segment22                       =    X_Segment22,
    segment23                       =    X_Segment23,
    segment24                       =    X_Segment24,
    segment25                       =    X_Segment25,
    segment26                       =    X_Segment26,
    segment27                       =    X_Segment27,
    segment28                       =    X_Segment28,
    segment29                       =    X_Segment29,
    segment30                       =    X_Segment30
  WHERE rowid = X_rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;

END Update_Row;

PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
BEGIN
  DELETE FROM GL_ALLOC_FORMULA_LINES
  WHERE  rowid = X_Rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;
END Delete_Row;

END gl_alloc_form_lines_pkg;

/
