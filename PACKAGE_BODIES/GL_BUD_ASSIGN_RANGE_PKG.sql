--------------------------------------------------------
--  DDL for Package Body GL_BUD_ASSIGN_RANGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_BUD_ASSIGN_RANGE_PKG" AS
/*  $Header: glibdarb.pls 120.12.12010000.1 2008/07/28 13:23:06 appldev ship $ */


  --
  -- PUBLIC FUNCTIONS
  --


  FUNCTION is_funds_check_not_none(
    x_ledger_id NUMBER )  RETURN BOOLEAN  IS

    CURSOR c_no_fc IS
      SELECT 'found'
      FROM   GL_BUDGET_ASSIGNMENT_RANGES bar
      WHERE  bar.ledger_id = x_ledger_id
      AND EXISTS (SELECT 'found'
                  FROM GL_BUDORG_BC_OPTIONS bco
                  WHERE bar.range_id = bco.range_id);

    dummy VARCHAR2(100);

  BEGIN

    OPEN  c_no_fc;
    FETCH c_no_fc INTO dummy;

    IF c_no_fc%FOUND THEN
      CLOSE c_no_fc;
      RETURN( TRUE );
    ELSE
      CLOSE c_no_fc;
      RETURN( FALSE );
    END IF;

    CLOSE c_no_fc;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'GL_BUD_ASSIGN_RANGE_PKG.is_funds_check_not_none');
      RAISE;

  END is_funds_check_not_none;


  PROCEDURE check_unique(org_id NUMBER, seq_num NUMBER,
			 row_id VARCHAR2) IS
    CURSOR chk_duplicates is
      SELECT 'Duplicate'
      FROM   GL_BUDGET_ASSIGNMENT_RANGES bar
      WHERE  bar.budget_entity_id = org_id
      AND    bar.sequence_number = seq_num
      AND    (   row_id is null
              OR bar.rowid <> row_id);
    dummy VARCHAR2(100);
  BEGIN
    OPEN chk_duplicates;
    FETCH chk_duplicates INTO dummy;

    IF chk_duplicates%FOUND THEN
      CLOSE chk_duplicates;
      fnd_message.set_name('SQLGL', 'GL_DUPLICATE_BUD_RANGE_SEQ');
      app_exception.raise_exception;
    END IF;

    CLOSE chk_duplicates;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'GL_BUD_ASSIGN_RANGE_PKG.check_unique');
      RAISE;
  END check_unique;


  PROCEDURE lock_range(x_range_id NUMBER) IS
    CURSOR lock_rng is
      SELECT 'Range locked'
      FROM   GL_BUDGET_ASSIGNMENT_RANGES bar
      WHERE  bar.range_id = x_range_id
      FOR UPDATE OF status;
    dummy VARCHAR2(100);
  BEGIN
    OPEN lock_rng;
    FETCH lock_rng INTO dummy;

    IF NOT lock_rng%FOUND THEN
      CLOSE lock_rng;
      fnd_message.set_name('SQLGL', 'GL_BUDORG_CANNOT_LOCK_RANGE');
      app_exception.raise_exception;
    END IF;

    CLOSE lock_rng;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'GL_BUD_ASSIGN_RANGE_PKG.lock_range');
      RAISE;
  END lock_range;


PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Budget_Entity_Id                    NUMBER,
                     X_Ledger_Id                           NUMBER,
                     X_Currency_Code                       VARCHAR2,
                     X_Entry_Code                          VARCHAR2,
                     X_Range_Id                     IN OUT NOCOPY NUMBER,
                     X_Status                              VARCHAR2,
                     X_Last_Update_Date                    DATE,
                     X_Created_By                          NUMBER,
                     X_Creation_Date                       DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Last_Update_Login                   NUMBER,
                     X_Sequence_Number                     NUMBER,
                     X_Segment1_Low                        VARCHAR2,
                     X_Segment1_High                       VARCHAR2,
                     X_Segment2_Low                        VARCHAR2,
                     X_Segment2_High                       VARCHAR2,
                     X_Segment3_Low                        VARCHAR2,
                     X_Segment3_High                       VARCHAR2,
                     X_Segment4_Low                        VARCHAR2,
                     X_Segment4_High                       VARCHAR2,
                     X_Segment5_Low                        VARCHAR2,
                     X_Segment5_High                       VARCHAR2,
                     X_Segment6_Low                        VARCHAR2,
                     X_Segment6_High                       VARCHAR2,
                     X_Segment7_Low                        VARCHAR2,
                     X_Segment7_High                       VARCHAR2,
                     X_Segment8_Low                        VARCHAR2,
                     X_Segment8_High                       VARCHAR2,
                     X_Segment9_Low                        VARCHAR2,
                     X_Segment9_High                       VARCHAR2,
                     X_Segment10_Low                       VARCHAR2,
                     X_Segment10_High                      VARCHAR2,
                     X_Segment11_Low                       VARCHAR2,
                     X_Segment11_High                      VARCHAR2,
                     X_Segment12_Low                       VARCHAR2,
                     X_Segment12_High                      VARCHAR2,
                     X_Segment13_Low                       VARCHAR2,
                     X_Segment13_High                      VARCHAR2,
                     X_Segment14_Low                       VARCHAR2,
                     X_Segment14_High                      VARCHAR2,
                     X_Segment15_Low                       VARCHAR2,
                     X_Segment15_High                      VARCHAR2,
                     X_Segment16_Low                       VARCHAR2,
                     X_Segment16_High                      VARCHAR2,
                     X_Segment17_Low                       VARCHAR2,
                     X_Segment17_High                      VARCHAR2,
                     X_Segment18_Low                       VARCHAR2,
                     X_Segment18_High                      VARCHAR2,
                     X_Segment19_Low                       VARCHAR2,
                     X_Segment19_High                      VARCHAR2,
                     X_Segment20_Low                       VARCHAR2,
                     X_Segment20_High                      VARCHAR2,
                     X_Segment21_Low                       VARCHAR2,
                     X_Segment21_High                      VARCHAR2,
                     X_Segment22_Low                       VARCHAR2,
                     X_Segment22_High                      VARCHAR2,
                     X_Segment23_Low                       VARCHAR2,
                     X_Segment23_High                      VARCHAR2,
                     X_Segment24_Low                       VARCHAR2,
                     X_Segment24_High                      VARCHAR2,
                     X_Segment25_Low                       VARCHAR2,
                     X_Segment25_High                      VARCHAR2,
                     X_Segment26_Low                       VARCHAR2,
                     X_Segment26_High                      VARCHAR2,
                     X_Segment27_Low                       VARCHAR2,
                     X_Segment27_High                      VARCHAR2,
                     X_Segment28_Low                       VARCHAR2,
                     X_Segment28_High                      VARCHAR2,
                     X_Segment29_Low                       VARCHAR2,
                     X_Segment29_High                      VARCHAR2,
                     X_Segment30_Low                       VARCHAR2,
                     X_Segment30_High                      VARCHAR2,
                     X_Context                             VARCHAR2,
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
                     X_Attribute11                         VARCHAR2,
                     X_Attribute12                         VARCHAR2,
                     X_Attribute13                         VARCHAR2,
                     X_Attribute14                         VARCHAR2,
                     X_Attribute15                         VARCHAR2,
		     X_Chart_Of_Accounts_Id		   NUMBER
 ) IS

    CURSOR get_new_id IS
      SELECT gl_budget_assignment_ranges_s.NEXTVAL
      FROM dual;


   CURSOR C IS SELECT rowid FROM GL_BUDGET_ASSIGNMENT_RANGES

             WHERE range_id = X_Range_Id;

   CURSOR check_overlaps IS
     SELECT 'Overlapping'
     FROM DUAL
     WHERE EXISTS
         (SELECT 'X'
          FROM GL_BUDGET_ASSIGNMENT_RANGES
          WHERE LEDGER_ID = X_LEDGER_ID
          AND   CURRENCY_CODE = X_CURRENCY_CODE
          AND  (NVL(SEGMENT30_LOW,'X') <= NVL(X_SEGMENT30_HIGH,'X')
          AND   NVL(SEGMENT30_HIGH,'X') >= NVL(X_SEGMENT30_LOW,'X')
          AND   NVL(SEGMENT29_LOW,'X') <= NVL(X_SEGMENT29_HIGH,'X')
          AND   NVL(SEGMENT29_HIGH,'X') >= NVL(X_SEGMENT29_LOW,'X')
          AND   NVL(SEGMENT28_LOW,'X') <= NVL(X_SEGMENT28_HIGH,'X')
          AND   NVL(SEGMENT28_HIGH,'X') >= NVL(X_SEGMENT28_LOW,'X')
          AND   NVL(SEGMENT27_LOW,'X') <= NVL(X_SEGMENT27_HIGH,'X')
          AND   NVL(SEGMENT27_HIGH,'X') >= NVL(X_SEGMENT27_LOW,'X')
          AND   NVL(SEGMENT26_LOW,'X') <= NVL(X_SEGMENT26_HIGH,'X')
          AND   NVL(SEGMENT26_HIGH,'X') >= NVL(X_SEGMENT26_LOW,'X')
          AND   NVL(SEGMENT25_LOW,'X') <= NVL(X_SEGMENT25_HIGH,'X')
          AND   NVL(SEGMENT25_HIGH,'X') >= NVL(X_SEGMENT25_LOW,'X')
          AND   NVL(SEGMENT24_LOW,'X') <= NVL(X_SEGMENT24_HIGH,'X')
          AND   NVL(SEGMENT24_HIGH,'X') >= NVL(X_SEGMENT24_LOW,'X')
          AND   NVL(SEGMENT23_LOW,'X') <= NVL(X_SEGMENT23_HIGH,'X')
          AND   NVL(SEGMENT23_HIGH,'X') >= NVL(X_SEGMENT23_LOW,'X')
          AND   NVL(SEGMENT22_LOW,'X') <= NVL(X_SEGMENT22_HIGH,'X')
          AND   NVL(SEGMENT22_HIGH,'X') >= NVL(X_SEGMENT22_LOW,'X')
          AND   NVL(SEGMENT21_LOW,'X') <= NVL(X_SEGMENT21_HIGH,'X')
          AND   NVL(SEGMENT21_HIGH,'X') >= NVL(X_SEGMENT21_LOW,'X')
          AND   NVL(SEGMENT20_LOW,'X') <= NVL(X_SEGMENT20_HIGH,'X')
          AND   NVL(SEGMENT20_HIGH,'X') >= NVL(X_SEGMENT20_LOW,'X')
          AND   NVL(SEGMENT19_LOW,'X') <= NVL(X_SEGMENT19_HIGH,'X')
          AND   NVL(SEGMENT19_HIGH,'X') >= NVL(X_SEGMENT19_LOW,'X')
          AND   NVL(SEGMENT18_LOW,'X') <= NVL(X_SEGMENT18_HIGH,'X')
          AND   NVL(SEGMENT18_HIGH,'X') >= NVL(X_SEGMENT18_LOW,'X')
          AND   NVL(SEGMENT17_LOW,'X') <= NVL(X_SEGMENT17_HIGH,'X')
          AND   NVL(SEGMENT17_HIGH,'X') >= NVL(X_SEGMENT17_LOW,'X')
          AND   NVL(SEGMENT16_LOW,'X') <= NVL(X_SEGMENT16_HIGH,'X')
          AND   NVL(SEGMENT16_HIGH,'X') >= NVL(X_SEGMENT16_LOW,'X')
          AND   NVL(SEGMENT15_LOW,'X') <= NVL(X_SEGMENT15_HIGH,'X')
          AND   NVL(SEGMENT15_HIGH,'X') >= NVL(X_SEGMENT15_LOW,'X'))
          AND   NVL(SEGMENT14_LOW,'X') <= NVL(X_SEGMENT14_HIGH,'X')
          AND   NVL(SEGMENT14_HIGH,'X') >= NVL(X_SEGMENT14_LOW,'X')
          AND   NVL(SEGMENT13_LOW,'X') <= NVL(X_SEGMENT13_HIGH,'X')
          AND   NVL(SEGMENT13_HIGH,'X') >= NVL(X_SEGMENT13_LOW,'X')
          AND   NVL(SEGMENT12_LOW,'X') <= NVL(X_SEGMENT12_HIGH,'X')
          AND   NVL(SEGMENT12_HIGH,'X') >= NVL(X_SEGMENT12_LOW,'X')
          AND   NVL(SEGMENT11_LOW,'X') <= NVL(X_SEGMENT11_HIGH,'X')
          AND   NVL(SEGMENT11_HIGH,'X') >= NVL(X_SEGMENT11_LOW,'X')
          AND   NVL(SEGMENT10_LOW,'X') <= NVL(X_SEGMENT10_HIGH,'X')
          AND   NVL(SEGMENT10_HIGH,'X') >= NVL(X_SEGMENT10_LOW,'X')
          AND   NVL(SEGMENT9_LOW,'X') <= NVL(X_SEGMENT9_HIGH,'X')
          AND   NVL(SEGMENT9_HIGH,'X') >= NVL(X_SEGMENT9_LOW,'X')
          AND   NVL(SEGMENT8_LOW,'X') <= NVL(X_SEGMENT8_HIGH,'X')
          AND   NVL(SEGMENT8_HIGH,'X') >= NVL(X_SEGMENT8_LOW,'X')
          AND   NVL(SEGMENT7_LOW,'X') <= NVL(X_SEGMENT7_HIGH,'X')
          AND   NVL(SEGMENT7_HIGH,'X') >= NVL(X_SEGMENT7_LOW,'X')
          AND   NVL(SEGMENT6_LOW,'X') <= NVL(X_SEGMENT6_HIGH,'X')
          AND   NVL(SEGMENT6_HIGH,'X') >= NVL(X_SEGMENT6_LOW,'X')
          AND   NVL(SEGMENT5_LOW,'X') <= NVL(X_SEGMENT5_HIGH,'X')
          AND   NVL(SEGMENT5_HIGH,'X') >= NVL(X_SEGMENT5_LOW,'X')
          AND   NVL(SEGMENT4_LOW,'X') <= NVL(X_SEGMENT4_HIGH,'X')
          AND   NVL(SEGMENT4_HIGH,'X') >= NVL(X_SEGMENT4_LOW,'X')
          AND   NVL(SEGMENT3_LOW,'X') <= NVL(X_SEGMENT3_HIGH,'X')
          AND   NVL(SEGMENT3_HIGH,'X') >= NVL(X_SEGMENT3_LOW,'X')
          AND   NVL(SEGMENT2_LOW,'X') <= NVL(X_SEGMENT2_HIGH,'X')
          AND   NVL(SEGMENT2_HIGH,'X') >= NVL(X_SEGMENT2_LOW,'X')
          AND   NVL(SEGMENT1_LOW,'X') <= NVL(X_SEGMENT1_HIGH,'X')
          AND   NVL(SEGMENT1_HIGH,'X') >= NVL(X_SEGMENT1_LOW,'X'));

  dummy VARCHAR2(100);
  L_Status VARCHAR2(1);

BEGIN
  -- get new range_id for the range
  -- Changed functionality to retrieve id from sequence only if
  -- routine is not called from the iSpeed API, since the API
  -- retrieves and passes in the id.

  IF (X_Status = 'ISPEED') THEN
     L_Status := 'A';
  ELSE
     OPEN get_new_id;
     FETCH get_new_id INTO X_Range_Id;

     IF get_new_id%FOUND THEN
       CLOSE get_new_id;
     ELSE
       CLOSE get_new_id;
       fnd_message.set_name('SQLGL', 'GL_ERROR_GETTING_UNIQUE_ID');
       fnd_message.set_token('SEQUENCE', 'GL_BUDGET_ASSIGNMENT_RANGES_S');
       app_exception.raise_exception;
     END IF;
     L_Status := X_Status;
  END IF;

  -- Make sure the budget organization isn't deleted as the range
  -- is being inserted
  gl_budget_entities_pkg.lock_organization(X_BUDGET_ENTITY_ID);

  -- Lock the timestamp to prevent coordination problems
  gl_bc_event_tstamps_pkg.lock_event_timestamp(X_Chart_Of_Accounts_Id, 'B');

  -- Check for overlapping ranges
  OPEN check_overlaps;
  FETCH check_overlaps INTO dummy;

  IF check_overlaps%FOUND THEN
    CLOSE check_overlaps;
    fnd_message.set_name('SQLGL', 'GL_BUDORG_RANGES_OVERLAP');
    app_exception.raise_exception;
  ELSE
    CLOSE check_overlaps;
  END IF;

  INSERT INTO GL_BUDGET_ASSIGNMENT_RANGES(
          budget_entity_id,
          ledger_id,
          currency_code,
          entry_code,
          range_id,
          status,
          last_update_date,
          created_by,
          creation_date,
          last_updated_by,
          last_update_login,
          sequence_number,
          segment1_low,
          segment1_high,
          segment2_low,
          segment2_high,
          segment3_low,
          segment3_high,
          segment4_low,
          segment4_high,
          segment5_low,
          segment5_high,
          segment6_low,
          segment6_high,
          segment7_low,
          segment7_high,
          segment8_low,
          segment8_high,
          segment9_low,
          segment9_high,
          segment10_low,
          segment10_high,
          segment11_low,
          segment11_high,
          segment12_low,
          segment12_high,
          segment13_low,
          segment13_high,
          segment14_low,
          segment14_high,
          segment15_low,
          segment15_high,
          segment16_low,
          segment16_high,
          segment17_low,
          segment17_high,
          segment18_low,
          segment18_high,
          segment19_low,
          segment19_high,
          segment20_low,
          segment20_high,
          segment21_low,
          segment21_high,
          segment22_low,
          segment22_high,
          segment23_low,
          segment23_high,
          segment24_low,
          segment24_high,
          segment25_low,
          segment25_high,
          segment26_low,
          segment26_high,
          segment27_low,
          segment27_high,
          segment28_low,
          segment28_high,
          segment29_low,
          segment29_high,
          segment30_low,
          segment30_high,
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
          X_Budget_Entity_Id,
          X_Ledger_Id,
          X_Currency_Code,
          X_Entry_Code,
          X_Range_Id,
          L_Status,
          X_Last_Update_Date,
          X_Created_By,
          X_Creation_Date,
          X_Last_Updated_By,
          X_Last_Update_Login,
          X_Sequence_Number,
          X_Segment1_Low,
          X_Segment1_High,
          X_Segment2_Low,
          X_Segment2_High,
          X_Segment3_Low,
          X_Segment3_High,
          X_Segment4_Low,
          X_Segment4_High,
          X_Segment5_Low,
          X_Segment5_High,
          X_Segment6_Low,
          X_Segment6_High,
          X_Segment7_Low,
          X_Segment7_High,
          X_Segment8_Low,
          X_Segment8_High,
          X_Segment9_Low,
          X_Segment9_High,
          X_Segment10_Low,
          X_Segment10_High,
          X_Segment11_Low,
          X_Segment11_High,
          X_Segment12_Low,
          X_Segment12_High,
          X_Segment13_Low,
          X_Segment13_High,
          X_Segment14_Low,
          X_Segment14_High,
          X_Segment15_Low,
          X_Segment15_High,
          X_Segment16_Low,
          X_Segment16_High,
          X_Segment17_Low,
          X_Segment17_High,
          X_Segment18_Low,
          X_Segment18_High,
          X_Segment19_Low,
          X_Segment19_High,
          X_Segment20_Low,
          X_Segment20_High,
          X_Segment21_Low,
          X_Segment21_High,
          X_Segment22_Low,
          X_Segment22_High,
          X_Segment23_Low,
          X_Segment23_High,
          X_Segment24_Low,
          X_Segment24_High,
          X_Segment25_Low,
          X_Segment25_High,
          X_Segment26_Low,
          X_Segment26_High,
          X_Segment27_Low,
          X_Segment27_High,
          X_Segment28_Low,
          X_Segment28_High,
          X_Segment29_Low,
          X_Segment29_High,
          X_Segment30_Low,
          X_Segment30_High,
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
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;
END Insert_Row;

PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,

                   X_Budget_Entity_Id                      NUMBER,
                   X_Ledger_Id                             NUMBER,
                   X_Currency_Code                         VARCHAR2,
                   X_Entry_Code                            VARCHAR2,
                   X_Range_Id                              NUMBER,
                   X_Status                                VARCHAR2,
                   X_Sequence_Number                       NUMBER,
                   X_Segment1_Low                          VARCHAR2,
                   X_Segment1_High                         VARCHAR2,
                   X_Segment2_Low                          VARCHAR2,
                   X_Segment2_High                         VARCHAR2,
                   X_Segment3_Low                          VARCHAR2,
                   X_Segment3_High                         VARCHAR2,
                   X_Segment4_Low                          VARCHAR2,
                   X_Segment4_High                         VARCHAR2,
                   X_Segment5_Low                          VARCHAR2,
                   X_Segment5_High                         VARCHAR2,
                   X_Segment6_Low                          VARCHAR2,
                   X_Segment6_High                         VARCHAR2,
                   X_Segment7_Low                          VARCHAR2,
                   X_Segment7_High                         VARCHAR2,
                   X_Segment8_Low                          VARCHAR2,
                   X_Segment8_High                         VARCHAR2,
                   X_Segment9_Low                          VARCHAR2,
                   X_Segment9_High                         VARCHAR2,
                   X_Segment10_Low                         VARCHAR2,
                   X_Segment10_High                        VARCHAR2,
                   X_Segment11_Low                         VARCHAR2,
                   X_Segment11_High                        VARCHAR2,
                   X_Segment12_Low                         VARCHAR2,
                   X_Segment12_High                        VARCHAR2,
                   X_Segment13_Low                         VARCHAR2,
                   X_Segment13_High                        VARCHAR2,
                   X_Segment14_Low                         VARCHAR2,
                   X_Segment14_High                        VARCHAR2,
                   X_Segment15_Low                         VARCHAR2,
                   X_Segment15_High                        VARCHAR2,
                   X_Segment16_Low                         VARCHAR2,
                   X_Segment16_High                        VARCHAR2,
                   X_Segment17_Low                         VARCHAR2,
                   X_Segment17_High                        VARCHAR2,
                   X_Segment18_Low                         VARCHAR2,
                   X_Segment18_High                        VARCHAR2,
                   X_Segment19_Low                         VARCHAR2,
                   X_Segment19_High                        VARCHAR2,
                   X_Segment20_Low                         VARCHAR2,
                   X_Segment20_High                        VARCHAR2,
                   X_Segment21_Low                         VARCHAR2,
                   X_Segment21_High                        VARCHAR2,
                   X_Segment22_Low                         VARCHAR2,
                   X_Segment22_High                        VARCHAR2,
                   X_Segment23_Low                         VARCHAR2,
                   X_Segment23_High                        VARCHAR2,
                   X_Segment24_Low                         VARCHAR2,
                   X_Segment24_High                        VARCHAR2,
                   X_Segment25_Low                         VARCHAR2,
                   X_Segment25_High                        VARCHAR2,
                   X_Segment26_Low                         VARCHAR2,
                   X_Segment26_High                        VARCHAR2,
                   X_Segment27_Low                         VARCHAR2,
                   X_Segment27_High                        VARCHAR2,
                   X_Segment28_Low                         VARCHAR2,
                   X_Segment28_High                        VARCHAR2,
                   X_Segment29_Low                         VARCHAR2,
                   X_Segment29_High                        VARCHAR2,
                   X_Segment30_Low                         VARCHAR2,
                   X_Segment30_High                        VARCHAR2,
                   X_Context                               VARCHAR2,
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
                   X_Attribute11                           VARCHAR2,
                   X_Attribute12                           VARCHAR2,
                   X_Attribute13                           VARCHAR2,
                   X_Attribute14                           VARCHAR2,
                   X_Attribute15                           VARCHAR2
) IS
  CURSOR C IS
      SELECT *
      FROM   GL_BUDGET_ASSIGNMENT_RANGES
      WHERE  rowid = X_Rowid
      FOR UPDATE of Range_Id   NOWAIT;
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
          (   (Recinfo.budget_entity_id = X_Budget_Entity_Id)
           OR (    (Recinfo.budget_entity_id IS NULL)
               AND (X_Budget_Entity_Id IS NULL)))
      AND (   (Recinfo.ledger_id = X_Ledger_Id)
           OR (    (Recinfo.ledger_id IS NULL)
               AND (X_Ledger_Id IS NULL)))
      AND (   (Recinfo.currency_code = X_Currency_Code)
           OR (    (Recinfo.currency_code IS NULL)
               AND (X_Currency_Code IS NULL)))
      AND (   (Recinfo.entry_code = X_Entry_Code)
           OR (    (Recinfo.entry_code IS NULL)
               AND (X_Entry_Code IS NULL)))
      AND (   (Recinfo.range_id = X_Range_Id)
           OR (    (Recinfo.range_id IS NULL)
               AND (X_Range_Id IS NULL)))
      AND (   (Recinfo.status = X_Status)
           OR (    (Recinfo.status IS NULL)
               AND (X_Status IS NULL)))
      AND (   (Recinfo.sequence_number = X_Sequence_Number)
           OR (    (Recinfo.sequence_number IS NULL)
               AND (X_Sequence_Number IS NULL)))
      AND (   (Recinfo.segment1_low = X_Segment1_Low)
           OR (    (Recinfo.segment1_low IS NULL)
               AND (X_Segment1_Low IS NULL)))
      AND (   (Recinfo.segment1_high = X_Segment1_High)
           OR (    (Recinfo.segment1_high IS NULL)
               AND (X_Segment1_High IS NULL)))
      AND (   (Recinfo.segment2_low = X_Segment2_Low)
           OR (    (Recinfo.segment2_low IS NULL)
               AND (X_Segment2_Low IS NULL)))
      AND (   (Recinfo.segment2_high = X_Segment2_High)
           OR (    (Recinfo.segment2_high IS NULL)
               AND (X_Segment2_High IS NULL)))
      AND (   (Recinfo.segment3_low = X_Segment3_Low)
           OR (    (Recinfo.segment3_low IS NULL)
               AND (X_Segment3_Low IS NULL)))
      AND (   (Recinfo.segment3_high = X_Segment3_High)
           OR (    (Recinfo.segment3_high IS NULL)
               AND (X_Segment3_High IS NULL)))
      AND (   (Recinfo.segment4_low = X_Segment4_Low)
           OR (    (Recinfo.segment4_low IS NULL)
               AND (X_Segment4_Low IS NULL)))
      AND (   (Recinfo.segment4_high = X_Segment4_High)
           OR (    (Recinfo.segment4_high IS NULL)
               AND (X_Segment4_High IS NULL)))
      AND (   (Recinfo.segment5_low = X_Segment5_Low)
           OR (    (Recinfo.segment5_low IS NULL)
               AND (X_Segment5_Low IS NULL)))
      AND (   (Recinfo.segment5_high = X_Segment5_High)
           OR (    (Recinfo.segment5_high IS NULL)
               AND (X_Segment5_High IS NULL)))
      AND (   (Recinfo.segment6_low = X_Segment6_Low)
           OR (    (Recinfo.segment6_low IS NULL)
               AND (X_Segment6_Low IS NULL)))
      AND (   (Recinfo.segment6_high = X_Segment6_High)
           OR (    (Recinfo.segment6_high IS NULL)
               AND (X_Segment6_High IS NULL)))
      AND (   (Recinfo.segment7_low = X_Segment7_Low)
           OR (    (Recinfo.segment7_low IS NULL)
               AND (X_Segment7_Low IS NULL)))
      AND (   (Recinfo.segment7_high = X_Segment7_High)
           OR (    (Recinfo.segment7_high IS NULL)
               AND (X_Segment7_High IS NULL)))
      AND (   (Recinfo.segment8_low = X_Segment8_Low)
           OR (    (Recinfo.segment8_low IS NULL)
               AND (X_Segment8_Low IS NULL)))
      AND (   (Recinfo.segment8_high = X_Segment8_High)
           OR (    (Recinfo.segment8_high IS NULL)
               AND (X_Segment8_High IS NULL)))
      AND (   (Recinfo.segment9_low = X_Segment9_Low)
           OR (    (Recinfo.segment9_low IS NULL)
               AND (X_Segment9_Low IS NULL)))
      AND (   (Recinfo.segment9_high = X_Segment9_High)
           OR (    (Recinfo.segment9_high IS NULL)
               AND (X_Segment9_High IS NULL)))
      AND (   (Recinfo.segment10_low = X_Segment10_Low)
           OR (    (Recinfo.segment10_low IS NULL)
               AND (X_Segment10_Low IS NULL)))
      AND (   (Recinfo.segment10_high = X_Segment10_High)
           OR (    (Recinfo.segment10_high IS NULL)
               AND (X_Segment10_High IS NULL)))
      AND (   (Recinfo.segment11_low = X_Segment11_Low)
           OR (    (Recinfo.segment11_low IS NULL)
               AND (X_Segment11_Low IS NULL)))
      AND (   (Recinfo.segment11_high = X_Segment11_High)
           OR (    (Recinfo.segment11_high IS NULL)
               AND (X_Segment11_High IS NULL)))
      AND (   (Recinfo.segment12_low = X_Segment12_Low)
           OR (    (Recinfo.segment12_low IS NULL)
               AND (X_Segment12_Low IS NULL)))
      AND (   (Recinfo.segment12_high = X_Segment12_High)
           OR (    (Recinfo.segment12_high IS NULL)
               AND (X_Segment12_High IS NULL)))
      AND (   (Recinfo.segment13_low = X_Segment13_Low)
           OR (    (Recinfo.segment13_low IS NULL)
               AND (X_Segment13_Low IS NULL)))
      AND (   (Recinfo.segment13_high = X_Segment13_High)
           OR (    (Recinfo.segment13_high IS NULL)
               AND (X_Segment13_High IS NULL)))
      AND (   (Recinfo.segment14_low = X_Segment14_Low)
           OR (    (Recinfo.segment14_low IS NULL)
               AND (X_Segment14_Low IS NULL)))
      AND (   (Recinfo.segment14_high = X_Segment14_High)
           OR (    (Recinfo.segment14_high IS NULL)
               AND (X_Segment14_High IS NULL)))
      AND (   (Recinfo.segment15_low = X_Segment15_Low)
           OR (    (Recinfo.segment15_low IS NULL)
               AND (X_Segment15_Low IS NULL)))
      AND (   (Recinfo.segment15_high = X_Segment15_High)
           OR (    (Recinfo.segment15_high IS NULL)
               AND (X_Segment15_High IS NULL)))
      AND (   (Recinfo.segment16_low = X_Segment16_Low)
           OR (    (Recinfo.segment16_low IS NULL)
               AND (X_Segment16_Low IS NULL)))
      AND (   (Recinfo.segment16_high = X_Segment16_High)
           OR (    (Recinfo.segment16_high IS NULL)
               AND (X_Segment16_High IS NULL)))
      AND (   (Recinfo.segment17_low = X_Segment17_Low)
           OR (    (Recinfo.segment17_low IS NULL)
               AND (X_Segment17_Low IS NULL)))
      AND (   (Recinfo.segment17_high = X_Segment17_High)
           OR (    (Recinfo.segment17_high IS NULL)
               AND (X_Segment17_High IS NULL)))
      AND (   (Recinfo.segment18_low = X_Segment18_Low)
           OR (    (Recinfo.segment18_low IS NULL)
               AND (X_Segment18_Low IS NULL)))
      AND (   (Recinfo.segment18_high = X_Segment18_High)
           OR (    (Recinfo.segment18_high IS NULL)
               AND (X_Segment18_High IS NULL)))
      AND (   (Recinfo.segment19_low = X_Segment19_Low)
           OR (    (Recinfo.segment19_low IS NULL)
               AND (X_Segment19_Low IS NULL)))
      AND (   (Recinfo.segment19_high = X_Segment19_High)
           OR (    (Recinfo.segment19_high IS NULL)
               AND (X_Segment19_High IS NULL)))
      AND (   (Recinfo.segment20_low = X_Segment20_Low)
           OR (    (Recinfo.segment20_low IS NULL)
               AND (X_Segment20_Low IS NULL)))
      AND (   (Recinfo.segment20_high = X_Segment20_High)
           OR (    (Recinfo.segment20_high IS NULL)
               AND (X_Segment20_High IS NULL)))
      AND (   (Recinfo.segment21_low = X_Segment21_Low)
           OR (    (Recinfo.segment21_low IS NULL)
               AND (X_Segment21_Low IS NULL)))
      AND (   (Recinfo.segment21_high = X_Segment21_High)
           OR (    (Recinfo.segment21_high IS NULL)
               AND (X_Segment21_High IS NULL)))
      AND (   (Recinfo.segment22_low = X_Segment22_Low)
           OR (    (Recinfo.segment22_low IS NULL)
               AND (X_Segment22_Low IS NULL)))
      AND (   (Recinfo.segment22_high = X_Segment22_High)
           OR (    (Recinfo.segment22_high IS NULL)
               AND (X_Segment22_High IS NULL)))
      AND (   (Recinfo.segment23_low = X_Segment23_Low)
           OR (    (Recinfo.segment23_low IS NULL)
               AND (X_Segment23_Low IS NULL)))
      AND (   (Recinfo.segment23_high = X_Segment23_High)
           OR (    (Recinfo.segment23_high IS NULL)
               AND (X_Segment23_High IS NULL)))
      AND (   (Recinfo.segment24_low = X_Segment24_Low)
           OR (    (Recinfo.segment24_low IS NULL)
               AND (X_Segment24_Low IS NULL)))
      AND (   (Recinfo.segment24_high = X_Segment24_High)
           OR (    (Recinfo.segment24_high IS NULL)
               AND (X_Segment24_High IS NULL)))
      AND (   (Recinfo.segment25_low = X_Segment25_Low)
           OR (    (Recinfo.segment25_low IS NULL)
               AND (X_Segment25_Low IS NULL)))
      AND (   (Recinfo.segment25_high = X_Segment25_High)
           OR (    (Recinfo.segment25_high IS NULL)
               AND (X_Segment25_High IS NULL)))) THEN
      IF  (
          (   (Recinfo.segment26_low = X_Segment26_Low)
           OR (    (Recinfo.segment26_low IS NULL)
               AND (X_Segment26_Low IS NULL)))
      AND (   (Recinfo.segment26_high = X_Segment26_High)
           OR (    (Recinfo.segment26_high IS NULL)
               AND (X_Segment26_High IS NULL)))
      AND (   (Recinfo.segment27_low = X_Segment27_Low)
           OR (    (Recinfo.segment27_low IS NULL)
               AND (X_Segment27_Low IS NULL)))
      AND (   (Recinfo.segment27_high = X_Segment27_High)
           OR (    (Recinfo.segment27_high IS NULL)
               AND (X_Segment27_High IS NULL)))
      AND (   (Recinfo.segment28_low = X_Segment28_Low)
           OR (    (Recinfo.segment28_low IS NULL)
               AND (X_Segment28_Low IS NULL)))
      AND (   (Recinfo.segment28_high = X_Segment28_High)
           OR (    (Recinfo.segment28_high IS NULL)
               AND (X_Segment28_High IS NULL)))
      AND (   (Recinfo.segment29_low = X_Segment29_Low)
           OR (    (Recinfo.segment29_low IS NULL)
               AND (X_Segment29_Low IS NULL)))
      AND (   (Recinfo.segment29_high = X_Segment29_High)
           OR (    (Recinfo.segment29_high IS NULL)
               AND (X_Segment29_High IS NULL)))
      AND (   (Recinfo.segment30_low = X_Segment30_Low)
           OR (    (Recinfo.segment30_low IS NULL)
               AND (X_Segment30_Low IS NULL)))
      AND (   (Recinfo.segment30_high = X_Segment30_High)
           OR (    (Recinfo.segment30_high IS NULL)
               AND (X_Segment30_High IS NULL)))
      AND (   (Recinfo.context = X_Context)
           OR (    (Recinfo.context IS NULL)
               AND (X_Context IS NULL)))
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
          ) then
    return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
END Lock_Row;

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Budget_Entity_Id                    NUMBER,
                     X_Ledger_Id                           NUMBER,
                     X_Currency_Code                       VARCHAR2,
                     X_Entry_Code                          VARCHAR2,
                     X_Range_Id                            NUMBER,
                     X_Status                              VARCHAR2,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Last_Update_Login                   NUMBER,
                     X_Sequence_Number                     NUMBER,
                     X_Segment1_Low                        VARCHAR2,
                     X_Segment1_High                       VARCHAR2,
                     X_Segment2_Low                        VARCHAR2,
                     X_Segment2_High                       VARCHAR2,
                     X_Segment3_Low                        VARCHAR2,
                     X_Segment3_High                       VARCHAR2,
                     X_Segment4_Low                        VARCHAR2,
                     X_Segment4_High                       VARCHAR2,
                     X_Segment5_Low                        VARCHAR2,
                     X_Segment5_High                       VARCHAR2,
                     X_Segment6_Low                        VARCHAR2,
                     X_Segment6_High                       VARCHAR2,
                     X_Segment7_Low                        VARCHAR2,
                     X_Segment7_High                       VARCHAR2,
                     X_Segment8_Low                        VARCHAR2,
                     X_Segment8_High                       VARCHAR2,
                     X_Segment9_Low                        VARCHAR2,
                     X_Segment9_High                       VARCHAR2,
                     X_Segment10_Low                       VARCHAR2,
                     X_Segment10_High                      VARCHAR2,
                     X_Segment11_Low                       VARCHAR2,
                     X_Segment11_High                      VARCHAR2,
                     X_Segment12_Low                       VARCHAR2,
                     X_Segment12_High                      VARCHAR2,
                     X_Segment13_Low                       VARCHAR2,
                     X_Segment13_High                      VARCHAR2,
                     X_Segment14_Low                       VARCHAR2,
                     X_Segment14_High                      VARCHAR2,
                     X_Segment15_Low                       VARCHAR2,
                     X_Segment15_High                      VARCHAR2,
                     X_Segment16_Low                       VARCHAR2,
                     X_Segment16_High                      VARCHAR2,
                     X_Segment17_Low                       VARCHAR2,
                     X_Segment17_High                      VARCHAR2,
                     X_Segment18_Low                       VARCHAR2,
                     X_Segment18_High                      VARCHAR2,
                     X_Segment19_Low                       VARCHAR2,
                     X_Segment19_High                      VARCHAR2,
                     X_Segment20_Low                       VARCHAR2,
                     X_Segment20_High                      VARCHAR2,
                     X_Segment21_Low                       VARCHAR2,
                     X_Segment21_High                      VARCHAR2,
                     X_Segment22_Low                       VARCHAR2,
                     X_Segment22_High                      VARCHAR2,
                     X_Segment23_Low                       VARCHAR2,
                     X_Segment23_High                      VARCHAR2,
                     X_Segment24_Low                       VARCHAR2,
                     X_Segment24_High                      VARCHAR2,
                     X_Segment25_Low                       VARCHAR2,
                     X_Segment25_High                      VARCHAR2,
                     X_Segment26_Low                       VARCHAR2,
                     X_Segment26_High                      VARCHAR2,
                     X_Segment27_Low                       VARCHAR2,
                     X_Segment27_High                      VARCHAR2,
                     X_Segment28_Low                       VARCHAR2,
                     X_Segment28_High                      VARCHAR2,
                     X_Segment29_Low                       VARCHAR2,
                     X_Segment29_High                      VARCHAR2,
                     X_Segment30_Low                       VARCHAR2,
                     X_Segment30_High                      VARCHAR2,
                     X_Context                             VARCHAR2,
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
                     X_Attribute11                         VARCHAR2,
                     X_Attribute12                         VARCHAR2,
                     X_Attribute13                         VARCHAR2,
                     X_Attribute14                         VARCHAR2,
                     X_Attribute15                         VARCHAR2
) IS
BEGIN
  UPDATE GL_BUDGET_ASSIGNMENT_RANGES
  SET

    budget_entity_id                          =    X_Budget_Entity_Id,
    ledger_id                                 =    X_Ledger_Id,
    currency_code                             =    X_Currency_Code,
    entry_code                                =    X_Entry_Code,
    range_id                                  =    X_Range_Id,
    status                                    =    X_Status,
    last_update_date                          =    X_Last_Update_Date,
    last_updated_by                           =    X_Last_Updated_By,
    last_update_login                         =    X_Last_Update_Login,
    sequence_number                           =    X_Sequence_Number,
    segment1_low                              =    X_Segment1_Low,
    segment1_high                             =    X_Segment1_High,
    segment2_low                              =    X_Segment2_Low,
    segment2_high                             =    X_Segment2_High,
    segment3_low                              =    X_Segment3_Low,
    segment3_high                             =    X_Segment3_High,
    segment4_low                              =    X_Segment4_Low,
    segment4_high                             =    X_Segment4_High,
    segment5_low                              =    X_Segment5_Low,
    segment5_high                             =    X_Segment5_High,
    segment6_low                              =    X_Segment6_Low,
    segment6_high                             =    X_Segment6_High,
    segment7_low                              =    X_Segment7_Low,
    segment7_high                             =    X_Segment7_High,
    segment8_low                              =    X_Segment8_Low,
    segment8_high                             =    X_Segment8_High,
    segment9_low                              =    X_Segment9_Low,
    segment9_high                             =    X_Segment9_High,
    segment10_low                             =    X_Segment10_Low,
    segment10_high                            =    X_Segment10_High,
    segment11_low                             =    X_Segment11_Low,
    segment11_high                            =    X_Segment11_High,
    segment12_low                             =    X_Segment12_Low,
    segment12_high                            =    X_Segment12_High,
    segment13_low                             =    X_Segment13_Low,
    segment13_high                            =    X_Segment13_High,
    segment14_low                             =    X_Segment14_Low,
    segment14_high                            =    X_Segment14_High,
    segment15_low                             =    X_Segment15_Low,
    segment15_high                            =    X_Segment15_High,
    segment16_low                             =    X_Segment16_Low,
    segment16_high                            =    X_Segment16_High,
    segment17_low                             =    X_Segment17_Low,
    segment17_high                            =    X_Segment17_High,
    segment18_low                             =    X_Segment18_Low,
    segment18_high                            =    X_Segment18_High,
    segment19_low                             =    X_Segment19_Low,
    segment19_high                            =    X_Segment19_High,
    segment20_low                             =    X_Segment20_Low,
    segment20_high                            =    X_Segment20_High,
    segment21_low                             =    X_Segment21_Low,
    segment21_high                            =    X_Segment21_High,
    segment22_low                             =    X_Segment22_Low,
    segment22_high                            =    X_Segment22_High,
    segment23_low                             =    X_Segment23_Low,
    segment23_high                            =    X_Segment23_High,
    segment24_low                             =    X_Segment24_Low,
    segment24_high                            =    X_Segment24_High,
    segment25_low                             =    X_Segment25_Low,
    segment25_high                            =    X_Segment25_High,
    segment26_low                             =    X_Segment26_Low,
    segment26_high                            =    X_Segment26_High,
    segment27_low                             =    X_Segment27_Low,
    segment27_high                            =    X_Segment27_High,
    segment28_low                             =    X_Segment28_Low,
    segment28_high                            =    X_Segment28_High,
    segment29_low                             =    X_Segment29_Low,
    segment29_high                            =    X_Segment29_High,
    segment30_low                             =    X_Segment30_Low,
    segment30_high                            =    X_Segment30_High,
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
  WHERE rowid = X_rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;

END Update_Row;

PROCEDURE Delete_Row(X_Range_Id NUMBER, X_Rowid VARCHAR2) IS
BEGIN

  -- Delete any budgetary control options defined for this range
  gl_budorg_bc_options_pkg.delete_budorg_bc_options(X_Range_id);

  -- Delete any assignments made by this range
  gl_budget_assignment_pkg.delete_range_assignments(X_Range_Id);

  DELETE FROM GL_BUDGET_ASSIGNMENT_RANGES
  WHERE  rowid = X_Rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;
END Delete_Row;

PROCEDURE Insert_Range(
                     X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Budget_Entity_Id                    NUMBER,
                     X_Ledger_Id                           NUMBER,
                     X_Currency_Code                       VARCHAR2,
                     X_Entry_Code                          VARCHAR2,
                     X_Range_Id                            NUMBER,
                     X_Status                              VARCHAR2,
                     X_Last_Update_Date                    DATE,
                     X_Created_By                          NUMBER,
                     X_Creation_Date                       DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Last_Update_Login                   NUMBER,
                     X_Sequence_Number                     NUMBER,
                     X_Segment1_Low                        VARCHAR2,
                     X_Segment1_High                       VARCHAR2,
                     X_Segment2_Low                        VARCHAR2,
                     X_Segment2_High                       VARCHAR2,
                     X_Segment3_Low                        VARCHAR2,
                     X_Segment3_High                       VARCHAR2,
                     X_Segment4_Low                        VARCHAR2,
                     X_Segment4_High                       VARCHAR2,
                     X_Segment5_Low                        VARCHAR2,
                     X_Segment5_High                       VARCHAR2,
                     X_Segment6_Low                        VARCHAR2,
                     X_Segment6_High                       VARCHAR2,
                     X_Segment7_Low                        VARCHAR2,
                     X_Segment7_High                       VARCHAR2,
                     X_Segment8_Low                        VARCHAR2,
                     X_Segment8_High                       VARCHAR2,
                     X_Segment9_Low                        VARCHAR2,
                     X_Segment9_High                       VARCHAR2,
                     X_Segment10_Low                       VARCHAR2,
                     X_Segment10_High                      VARCHAR2,
                     X_Segment11_Low                       VARCHAR2,
                     X_Segment11_High                      VARCHAR2,
                     X_Segment12_Low                       VARCHAR2,
                     X_Segment12_High                      VARCHAR2,
                     X_Segment13_Low                       VARCHAR2,
                     X_Segment13_High                      VARCHAR2,
                     X_Segment14_Low                       VARCHAR2,
                     X_Segment14_High                      VARCHAR2,
                     X_Segment15_Low                       VARCHAR2,
                     X_Segment15_High                      VARCHAR2,
                     X_Segment16_Low                       VARCHAR2,
                     X_Segment16_High                      VARCHAR2,
                     X_Segment17_Low                       VARCHAR2,
                     X_Segment17_High                      VARCHAR2,
                     X_Segment18_Low                       VARCHAR2,
                     X_Segment18_High                      VARCHAR2,
                     X_Segment19_Low                       VARCHAR2,
                     X_Segment19_High                      VARCHAR2,
                     X_Segment20_Low                       VARCHAR2,
                     X_Segment20_High                      VARCHAR2,
                     X_Segment21_Low                       VARCHAR2,
                     X_Segment21_High                      VARCHAR2,
                     X_Segment22_Low                       VARCHAR2,
                     X_Segment22_High                      VARCHAR2,
                     X_Segment23_Low                       VARCHAR2,
                     X_Segment23_High                      VARCHAR2,
                     X_Segment24_Low                       VARCHAR2,
                     X_Segment24_High                      VARCHAR2,
                     X_Segment25_Low                       VARCHAR2,
                     X_Segment25_High                      VARCHAR2,
                     X_Segment26_Low                       VARCHAR2,
                     X_Segment26_High                      VARCHAR2,
                     X_Segment27_Low                       VARCHAR2,
                     X_Segment27_High                      VARCHAR2,
                     X_Segment28_Low                       VARCHAR2,
                     X_Segment28_High                      VARCHAR2,
                     X_Segment29_Low                       VARCHAR2,
                     X_Segment29_High                      VARCHAR2,
                     X_Segment30_Low                       VARCHAR2,
                     X_Segment30_High                      VARCHAR2,
                     X_Context                             VARCHAR2,
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
                     X_Attribute11                         VARCHAR2,
                     X_Attribute12                         VARCHAR2,
                     X_Attribute13                         VARCHAR2,
                     X_Attribute14                         VARCHAR2,
                     X_Attribute15                         VARCHAR2
 ) IS

 CURSOR active_currencies IS
   SELECT 'X'
   FROM FND_CURRENCIES_ACTIVE_V fnd
   WHERE fnd.currency_code = X_Currency_Code;

 CURSOR check_entry_code IS
   SELECT 'X'
   FROM GL_LOOKUPS
   WHERE LOOKUP_TYPE = 'ENTRY_CODE'
   AND lookup_code = X_Entry_Code;

 CURSOR check_bud_org_name IS
   SELECT lk.meaning
   FROM   GL_BUDGET_ENTITIES bud,
          GL_LOOKUPS lk
   WHERE  bud.budget_entity_id = X_Budget_Entity_Id
   AND    lk.lookup_type = 'LITERAL'
   AND    lk.lookup_code = 'ALL'
   AND    lk.meaning = bud.name;

 L_Range_Id   NUMBER;
 L_Chart_Of_Accounts_Id NUMBER;
 L_Functional_Currency VARCHAR2(15);
 L_Budgetary_Control_Flag VARCHAR2(1);
 dummy VARCHAR2(80);

 BEGIN

   L_Range_Id := X_Range_Id;

   -- Validate Entry Code
   OPEN check_entry_code;
   FETCH check_entry_code INTO dummy;
   IF check_entry_code%NOTFOUND THEN
      CLOSE check_entry_code;
      fnd_message.set_name('SQLGL', 'GL_API_VALUE_NOT_EXIST');
      fnd_message.set_token('VALUE', X_Entry_Code);
      fnd_message.set_token('ATTRIBUTE', 'EntryCode');
      app_exception.raise_exception;
   END IF;
   CLOSE check_entry_code;

   -- Validate Budget Name
   OPEN check_bud_org_name;
   FETCH check_bud_org_name INTO dummy;
   IF check_bud_org_name%FOUND THEN
      CLOSE check_bud_org_name;
      fnd_message.set_name('SQLGL', 'GL_API_BUDORG_RANGES_FOR_ALL');
      fnd_message.set_token('ALL', dummy);
      app_exception.raise_exception;
   END IF;
   CLOSE check_bud_org_name;

   -- Validate currency_code exists and is enabled in FND_CURRENCIES
   -- Also, if entry_code is E, only functional currency and STAT is allowed.

   SELECT currency_code,
          enable_budgetary_control_flag,
          chart_of_accounts_id
   INTO   L_Functional_Currency,
          L_Budgetary_Control_Flag,
          L_Chart_Of_Accounts_Id
   FROM   gl_ledgers
   WHERE  ledger_id = X_Ledger_Id;

   -- If entry code is C for Calculated then only valid values for currency are
   -- the functional currency and STAT.
   IF (X_Entry_Code = 'C') THEN
      IF ((X_Currency_Code <> L_Functional_Currency) AND
          (X_Currency_Code <> 'STAT')) THEN
         fnd_message.set_name('SQLGL', 'GL_API_BUDORG_CALC_CURR_ERR');
         app_exception.raise_exception;
      END IF;
   END IF;

   -- Validate that the currency selected is an active currency.
   OPEN active_currencies;
   FETCH active_currencies INTO dummy;
   IF active_currencies%NOTFOUND THEN
      CLOSE active_currencies;
      fnd_message.set_name('SQLGL', 'GL_API_INVALID_CURR');
      app_exception.raise_exception;
   END IF;
   CLOSE active_currencies;


   GL_BUD_ASSIGN_RANGE_PKG.Insert_Row(
          X_Rowid,
          X_Budget_Entity_Id,
          X_Ledger_Id,
          X_Currency_Code,
          X_Entry_Code,
          L_Range_Id,
          X_Status,
          X_Last_Update_Date,
          X_Created_By,
          X_Creation_Date,
          X_Last_Updated_By,
          X_Last_Update_Login,
          X_Sequence_Number,
          X_Segment1_Low,
          X_Segment1_High,
          X_Segment2_Low,
          X_Segment2_High,
          X_Segment3_Low,
          X_Segment3_High,
          X_Segment4_Low,
          X_Segment4_High,
          X_Segment5_Low,
          X_Segment5_High,
          X_Segment6_Low,
          X_Segment6_High,
          X_Segment7_Low,
          X_Segment7_High,
          X_Segment8_Low,
          X_Segment8_High,
          X_Segment9_Low,
          X_Segment9_High,
          X_Segment10_Low,
          X_Segment10_High,
          X_Segment11_Low,
          X_Segment11_High,
          X_Segment12_Low,
          X_Segment12_High,
          X_Segment13_Low,
          X_Segment13_High,
          X_Segment14_Low,
          X_Segment14_High,
          X_Segment15_Low,
          X_Segment15_High,
          X_Segment16_Low,
          X_Segment16_High,
          X_Segment17_Low,
          X_Segment17_High,
          X_Segment18_Low,
          X_Segment18_High,
          X_Segment19_Low,
          X_Segment19_High,
          X_Segment20_Low,
          X_Segment20_High,
          X_Segment21_Low,
          X_Segment21_High,
          X_Segment22_Low,
          X_Segment22_High,
          X_Segment23_Low,
          X_Segment23_High,
          X_Segment24_Low,
          X_Segment24_High,
          X_Segment25_Low,
          X_Segment25_High,
          X_Segment26_Low,
          X_Segment26_High,
          X_Segment27_Low,
          X_Segment27_High,
          X_Segment28_Low,
          X_Segment28_High,
          X_Segment29_Low,
          X_Segment29_High,
          X_Segment30_Low,
          X_Segment30_High,
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
          L_Chart_Of_Accounts_Id);

EXCEPTION
  WHEN app_exceptions.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
    fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
    fnd_message.set_token('PROCEDURE',
                          'GL_BUDGET_ASSIGN_RANGE_PKG.Insert_Range');
    RAISE;
END Insert_Range;

END gl_bud_assign_range_pkg;

/
