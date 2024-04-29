--------------------------------------------------------
--  DDL for Package Body GL_CONS_ACCOUNTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_CONS_ACCOUNTS_PKG" AS
/* $Header: glicoacb.pls 120.3 2005/05/05 01:03:53 kvora ship $ */

--
-- PUBLIC FUNCTIONS
--

  FUNCTION Insert_Consolidation_Accounts(
        X_Consolidation_Run_Id    NUMBER,
        X_Consolidation_Id        NUMBER,
        X_From_Ledger_Id          NUMBER) RETURN BOOLEAN IS
  cons_run_id   NUMBER;
  CURSOR accts is
    SELECT  consolidation_id
      FROM  GL_CONSOLIDATION_ACCOUNTS glca
     WHERE  glca.consolidation_id = X_Consolidation_Id
       AND  glca.consolidation_run_id = cons_run_id ;

  dummy  NUMBER;

  BEGIN
    SELECT max(consolidation_run_id)
      INTO cons_run_id
      FROM gl_consolidation_history
     WHERE consolidation_id = X_Consolidation_Id;

    OPEN accts;
    FETCH accts INTO dummy;

    IF (accts%FOUND) THEN
      CLOSE  accts;
      LOCK TABLE gl_consolidation_accounts IN SHARE UPDATE MODE;
      INSERT INTO GL_CONSOLIDATION_ACCOUNTS
        (consolidation_run_id, consolidation_id, last_update_date,
         last_updated_by, from_ledger_id, element_sequence,
         segment1_low, segment1_high, segment2_low, segment2_high,
         segment3_low, segment3_high, segment4_low, segment4_high,
         segment5_low, segment5_high, segment6_low, segment6_high,
         segment7_low, segment7_high, segment8_low, segment8_high,
         segment9_low, segment9_high, segment10_low, segment10_high,
         segment11_low, segment11_high, segment12_low, segment12_high,
         segment13_low, segment13_high, segment14_low, segment14_high,
         segment15_low, segment15_high, segment16_low, segment16_high,
         segment17_low, segment17_high, segment18_low, segment18_high,
         segment19_low, segment19_high, segment20_low, segment20_high,
         segment21_low, segment21_high, segment22_low, segment22_high,
         segment23_low, segment23_high, segment24_low, segment24_high,
         segment25_low, segment25_high, segment26_low, segment26_high,
         segment27_low, segment27_high, segment28_low, segment28_high,
         segment29_low, segment29_high, segment30_low, segment30_high)
      SELECT X_Consolidation_Run_Id, X_Consolidation_Id, last_update_date,
         last_updated_by, X_From_Ledger_Id, element_sequence,
         segment1_low, segment1_high, segment2_low, segment2_high,
         segment3_low, segment3_high, segment4_low, segment4_high,
         segment5_low, segment5_high, segment6_low, segment6_high,
         segment7_low, segment7_high, segment8_low, segment8_high,
         segment9_low, segment9_high, segment10_low, segment10_high,
         segment11_low, segment11_high, segment12_low, segment12_high,
         segment13_low, segment13_high, segment14_low, segment14_high,
         segment15_low, segment15_high, segment16_low, segment16_high,
         segment17_low, segment17_high, segment18_low, segment18_high,
         segment19_low, segment19_high, segment20_low, segment20_high,
         segment21_low, segment21_high, segment22_low, segment22_high,
         segment23_low, segment23_high, segment24_low, segment24_high,
        segment25_low, segment25_high, segment26_low, segment26_high,
         segment27_low, segment27_high, segment28_low, segment28_high,
         segment29_low, segment29_high, segment30_low, segment30_high
      FROM   GL_CONSOLIDATION_ACCOUNTS
      WHERE  X_Consolidation_Id = consolidation_id
      AND    consolidation_run_id =
                (select max(consolidation_run_id)
                 from   gl_consolidation_accounts
                 where  consolidation_id = X_Consolidation_Id);
      RETURN TRUE;
    ELSE
      CLOSE accts;
      RETURN FALSE;
    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN FALSE;

  END Insert_Consolidation_Accounts;


  PROCEDURE Check_Unique_Element_Sequence(
	X_Rowid			  VARCHAR2,
        X_Consolidation_Id        NUMBER,
        X_Consolidation_Run_Id    NUMBER,
        X_Element_Sequence        NUMBER) IS

  CURSOR elem_seq IS
    SELECT  'x'
      FROM  GL_CONSOLIDATION_ACCOUNTS gca
     WHERE  gca.consolidation_id = X_Consolidation_Id
       AND  gca.consolidation_run_id = X_Consolidation_Run_Id
       AND  gca.element_sequence = X_Element_Sequence
       AND  (X_Rowid is null OR X_Rowid <> gca.rowid);

  dummy  VARCHAR2(2);

  BEGIN
    OPEN elem_seq;
    FETCH elem_seq INTO dummy;

    IF (elem_seq%FOUND) THEN
      CLOSE  elem_seq;
      fnd_message.set_name('SQLGL','GL_DUP_LINE_NUMBER');
      app_exception.raise_exception;
    END IF;

    CLOSE elem_seq;

  END Check_Unique_Element_Sequence;

  PROCEDURE Check_Account_Ranges_Overlap(
	X_Rowid			  VARCHAR2,
        X_Consolidation_Id        NUMBER,
        X_Consolidation_Run_Id    NUMBER,
        X_Segment1_Low            VARCHAR2,
        X_Segment1_High           VARCHAR2,
        X_Segment2_Low            VARCHAR2,
        X_Segment2_High           VARCHAR2,
        X_Segment3_Low            VARCHAR2,
        X_Segment3_High           VARCHAR2,
        X_Segment4_Low            VARCHAR2,
        X_Segment4_High           VARCHAR2,
        X_Segment5_Low            VARCHAR2,
        X_Segment5_High           VARCHAR2,
        X_Segment6_Low            VARCHAR2,
        X_Segment6_High           VARCHAR2,
        X_Segment7_Low            VARCHAR2,
        X_Segment7_High           VARCHAR2,
        X_Segment8_Low            VARCHAR2,
        X_Segment8_High           VARCHAR2,
        X_Segment9_Low            VARCHAR2,
        X_Segment9_High           VARCHAR2,
        X_Segment10_Low           VARCHAR2,
        X_Segment10_High          VARCHAR2,
        X_Segment11_Low           VARCHAR2,
        X_Segment11_High          VARCHAR2,
        X_Segment12_Low           VARCHAR2,
        X_Segment12_High          VARCHAR2,
        X_Segment13_Low           VARCHAR2,
        X_Segment13_High          VARCHAR2,
        X_Segment14_Low           VARCHAR2,
        X_Segment14_High          VARCHAR2,
        X_Segment15_Low           VARCHAR2,
        X_Segment15_High          VARCHAR2,
        X_Segment16_Low           VARCHAR2,
        X_Segment16_High          VARCHAR2,
        X_Segment17_Low           VARCHAR2,
        X_Segment17_High          VARCHAR2,
        X_Segment18_Low           VARCHAR2,
        X_Segment18_High          VARCHAR2,
        X_Segment19_Low           VARCHAR2,
        X_Segment19_High          VARCHAR2,
        X_Segment20_Low           VARCHAR2,
        X_Segment20_High          VARCHAR2,
        X_Segment21_Low           VARCHAR2,
        X_Segment21_High          VARCHAR2,
        X_Segment22_Low           VARCHAR2,
        X_Segment22_High          VARCHAR2,
        X_Segment23_Low           VARCHAR2,
        X_Segment23_High          VARCHAR2,
        X_Segment24_Low           VARCHAR2,
        X_Segment24_High          VARCHAR2,
        X_Segment25_Low           VARCHAR2,
        X_Segment25_High          VARCHAR2,
        X_Segment26_Low           VARCHAR2,
        X_Segment26_High          VARCHAR2,
        X_Segment27_Low           VARCHAR2,
        X_Segment27_High          VARCHAR2,
        X_Segment28_Low           VARCHAR2,
        X_Segment28_High          VARCHAR2,
        X_Segment29_Low           VARCHAR2,
        X_Segment29_High          VARCHAR2,
        X_Segment30_Low           VARCHAR2,
        X_Segment30_High          VARCHAR2
	) IS
  CURSOR Account_Ranges_Overlap IS
        SELECT  'x'
        FROM    GL_CONSOLIDATION_ACCOUNTS
        WHERE   consolidation_id = X_Consolidation_Id
        AND     consolidation_run_id = X_Consolidation_Run_Id
        AND     (X_Rowid is null OR X_Rowid <> rowid)
	AND     (      nvl(segment1_low,   'x') <= nvl(X_Segment1_High,  'x')
	          AND  nvl(segment1_high,  'x') >= nvl(X_Segment1_Low,   'x')
	          AND  nvl(segment2_low,   'x') <= nvl(X_Segment2_High,  'x')
	          AND  nvl(segment2_high,  'x') >= nvl(X_Segment2_Low,   'x')
	          AND  nvl(segment3_low,   'x') <= nvl(X_Segment3_High,  'x')
	          AND  nvl(segment3_high,  'x') >= nvl(X_Segment3_Low,   'x')
	          AND  nvl(segment4_low,   'x') <= nvl(X_Segment4_High,  'x')
	          AND  nvl(segment4_high,  'x') >= nvl(X_Segment4_Low,   'x')
	          AND  nvl(segment5_low,   'x') <= nvl(X_Segment5_High,  'x')
	          AND  nvl(segment5_high,  'x') >= nvl(X_Segment5_Low,   'x')
	          AND  nvl(segment6_low,   'x') <= nvl(X_Segment6_High,  'x')
	          AND  nvl(segment6_high,  'x') >= nvl(X_Segment6_Low,   'x')
	          AND  nvl(segment7_low,   'x') <= nvl(X_Segment7_High,  'x')
	          AND  nvl(segment7_high,  'x') >= nvl(X_Segment7_Low,   'x')
	          AND  nvl(segment8_low,   'x') <= nvl(X_Segment8_High,  'x')
	          AND  nvl(segment8_high,  'x') >= nvl(X_Segment8_Low,   'x')
	          AND  nvl(segment9_low,   'x') <= nvl(X_Segment9_High,  'x')
	          AND  nvl(segment9_high,  'x') >= nvl(X_Segment9_Low,   'x')
	          AND  nvl(segment10_low,  'x') <= nvl(X_Segment10_High, 'x')
	          AND  nvl(segment10_high, 'x') >= nvl(X_Segment10_Low,  'x')
	          AND  nvl(segment11_low,  'x') <= nvl(X_Segment11_High, 'x')
	          AND  nvl(segment11_high, 'x') >= nvl(X_Segment11_Low,  'x')
	          AND  nvl(segment12_low,  'x') <= nvl(X_Segment12_High, 'x')
	          AND  nvl(segment12_high, 'x') >= nvl(X_Segment12_Low,  'x')
	          AND  nvl(segment13_low,  'x') <= nvl(X_Segment13_High, 'x')
	          AND  nvl(segment13_high, 'x') >= nvl(X_Segment13_Low,  'x')
	          AND  nvl(segment14_low,  'x') <= nvl(X_Segment14_High, 'x')
	          AND  nvl(segment14_high, 'x') >= nvl(X_Segment14_Low,  'x')
	          AND  nvl(segment15_low,  'x') <= nvl(X_Segment15_High, 'x')
	          AND  nvl(segment15_high, 'x') >= nvl(X_Segment15_Low,  'x')
	          AND  nvl(segment16_low,  'x') <= nvl(X_Segment16_High, 'x')
	          AND  nvl(segment16_high, 'x') >= nvl(X_Segment16_Low,  'x')
	          AND  nvl(segment17_low,  'x') <= nvl(X_Segment17_High, 'x')
	          AND  nvl(segment17_high, 'x') >= nvl(X_Segment17_Low,  'x')
	          AND  nvl(segment18_low,  'x') <= nvl(X_Segment18_High, 'x')
	          AND  nvl(segment18_high, 'x') >= nvl(X_Segment18_Low,  'x')
	          AND  nvl(segment19_low,  'x') <= nvl(X_Segment19_High, 'x')
	          AND  nvl(segment19_high, 'x') >= nvl(X_Segment19_Low,  'x')
	          AND  nvl(segment20_low,  'x') <= nvl(X_Segment20_High, 'x')
	          AND  nvl(segment20_high, 'x') >= nvl(X_Segment20_Low,  'x')
	          AND  nvl(segment21_low,  'x') <= nvl(X_Segment21_High, 'x')
	          AND  nvl(segment21_high, 'x') >= nvl(X_Segment21_Low,  'x')
	          AND  nvl(segment22_low,  'x') <= nvl(X_Segment22_High, 'x')
	          AND  nvl(segment22_high, 'x') >= nvl(X_Segment22_Low,  'x')
	          AND  nvl(segment23_low,  'x') <= nvl(X_Segment23_High, 'x')
	          AND  nvl(segment23_high, 'x') >= nvl(X_Segment23_Low,  'x')
	          AND  nvl(segment24_low,  'x') <= nvl(X_Segment24_High, 'x')
	          AND  nvl(segment24_high, 'x') >= nvl(X_Segment24_Low,  'x')
	          AND  nvl(segment25_low,  'x') <= nvl(X_Segment25_High, 'x')
	          AND  nvl(segment25_high, 'x') >= nvl(X_Segment25_Low,  'x')
	          AND  nvl(segment26_low,  'x') <= nvl(X_Segment26_High, 'x')
	          AND  nvl(segment26_high, 'x') >= nvl(X_Segment26_Low,  'x')
	          AND  nvl(segment27_low,  'x') <= nvl(X_Segment27_High, 'x')
	          AND  nvl(segment27_high, 'x') >= nvl(X_Segment27_Low,  'x')
	          AND  nvl(segment28_low,  'x') <= nvl(X_Segment28_High, 'x')
	          AND  nvl(segment28_high, 'x') >= nvl(X_Segment28_Low,  'x')
	          AND  nvl(segment29_low,  'x') <= nvl(X_Segment29_High, 'x')
	          AND  nvl(segment29_high, 'x') >= nvl(X_Segment29_Low,  'x')
	          AND  nvl(segment30_low,  'x') <= nvl(X_Segment30_High, 'x')
	          AND  nvl(segment30_high, 'x') >= nvl(X_Segment30_Low,  'x')
	 );
  dummy  VARCHAR2(2);

  BEGIN
    OPEN Account_Ranges_Overlap;
    FETCH Account_Ranges_Overlap INTO dummy;

    IF (Account_Ranges_Overlap%FOUND) THEN
      CLOSE  Account_Ranges_Overlap;
      fnd_message.set_name('SQLGL','GL_CONS_ACCOUNT_RANGES_OVERLAP');
      app_exception.raise_exception;
    END IF;

    CLOSE Account_Ranges_Overlap;

  END Check_Account_Ranges_Overlap;

  FUNCTION Count_Ranges(
	X_Consolidation_Id	NUMBER,
	X_Consolidation_Run_Id	NUMBER) RETURN BOOLEAN IS

  CURSOR range_count IS
    SELECT  'y'
      FROM  GL_CONSOLIDATION_ACCOUNTS gca
     WHERE  gca.consolidation_id = X_Consolidation_Id
       AND  gca.consolidation_run_id = X_Consolidation_Run_Id;

  var1  VARCHAR2(2);

  BEGIN
    OPEN range_count;
    FETCH range_count INTO var1;

    IF (range_count%NOTFOUND) THEN
      CLOSE range_count;
      return FALSE;
    END IF;

    CLOSE range_count;
    return TRUE;

  END Count_Ranges;


/* Name: copy_ranges
 * Desc: Copies the ranges for the source run id to the target run id.
 */
PROCEDURE copy_ranges(
            ConsolidationId NUMBER,
            SourceRunId     NUMBER,
            TargetRunId     NUMBER) IS
BEGIN
  INSERT INTO GL_CONSOLIDATION_ACCOUNTS(
                     consolidation_run_id,
                     consolidation_id,
                     last_update_date,
                     last_updated_by,
                     from_ledger_id,
                     element_sequence,
                     creation_date,
                     created_by,
                     last_update_login,
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
                     segment30_high
  ) SELECT
                     TargetRunId,
                     consolidation_id,
                     last_update_date,
                     last_updated_by,
                     from_ledger_id,
                     element_sequence,
                     creation_date,
                     created_by,
                     last_update_login,
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
                     segment30_high
  FROM  gl_consolidation_accounts
  WHERE NOT EXISTS (SELECT 1
                    FROM   gl_consolidation_accounts
                    WHERE  consolidation_id = ConsolidationId
                    AND    consolidation_run_id = TargetRunId)
  AND   consolidation_id = ConsolidationId
  AND   consolidation_run_id = SourceRunId;

END copy_ranges;


PROCEDURE Delete_Account_Range(
                 ConsolidationId  NUMBER,
                 StdRunId         NUMBER,
                 AvgRunId         NUMBER) IS
BEGIN

  DELETE FROM  GL_CONSOLIDATION_ACCOUNTS
         WHERE consolidation_id = ConsolidationId
         AND   (consolidation_run_id = StdRunId OR
                consolidation_run_id = AvgRunId);

END Delete_Account_Range;

END GL_CONS_ACCOUNTS_PKG;

/
