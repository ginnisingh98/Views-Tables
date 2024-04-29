--------------------------------------------------------
--  DDL for Package Body AP_WEB_DB_EXPDIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_DB_EXPDIST_PKG" AS
/* $Header: apwdbedb.pls 120.13.12010000.7 2009/11/19 09:32:20 rveliche ship $ */

---------------------------------------------
-- Some global types, constants and cursors
---------------------------------------------

cursor cflex(p_chart_accounts_id IN NUMBER) is
  SELECT flex.application_column_name
  FROM   fnd_id_flex_segments flex
  WHERE flex.application_id = 101
  AND flex.id_flex_code = 'GL#'
  AND flex.id_flex_num = p_chart_accounts_id
  AND flex.enabled_flag='Y'
  AND flex.display_flag='Y'
  order by segment_num;

PROCEDURE updateAccountValuesForForms(
                   p_report_header_id IN  expDist_report_header_ID,
                   p_report_line_id   IN  expDist_REPORT_LINE_ID,
                   p_report_distribution_id IN expDist_REPORT_DISTRIBUTION_ID,
                   p_ccid             IN  expDist_CODE_COMBINATION_ID,
                   p_line_amount IN NUMBER);

--------------------------------------------------------------------------------
FUNCTION foundCCID(p_report_distribution_id IN expDist_REPORT_DISTRIBUTION_ID,
                   x_line_ccid        OUT NOCOPY expDist_CODE_COMBINATION_ID)
RETURN BOOLEAN IS

--------------------------------------------------------------------------------
  l_line_ccid VARCHAR2(15);
BEGIN

  SELECT code_combination_id
  INTO   l_line_ccid
  FROM   ap_exp_report_dists aerd
  WHERE  aerd.report_distribution_id = p_report_distribution_id
  AND    aerd.code_combination_id is not null;

  x_line_ccid := l_line_ccid;

  IF (l_line_ccid = -1) THEN
    return false;
  ELSE
    return true;
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('foundCCID');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END foundCCID;


--------------------------------------------------------------------------------
FUNCTION foundDistributions(p_report_distribution_id IN expDist_REPORT_DISTRIBUTION_ID)
RETURN BOOLEAN IS
--------------------------------------------------------------------------------
  l_temp VARCHAR2(1);
BEGIN

  SELECT 'Y'
  INTO   l_temp
  FROM   ap_exp_report_dists rd
  WHERE  rd.report_distribution_id = p_report_distribution_id;

  return TRUE;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('foundDistributions');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END foundDistributions;


-----------------------------------------------------------------------------
FUNCTION SetDistCCID(
p_report_header_id      IN expDist_REPORT_HEADER_ID,
p_report_line_id        IN expDist_REPORT_LINE_ID,
p_exp_line_ccid         IN expDist_CODE_COMBINATION_ID)
RETURN BOOLEAN IS
-----------------------------------------------------------------------------
BEGIN
    UPDATE ap_exp_report_dists RD
    SET    RD.code_combination_id = p_exp_line_ccid
    WHERE  RD.report_header_id = p_report_header_id
    AND    RD.report_line_id   = p_report_line_id;

    return TRUE;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('SetDistCCID');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END SetDistCCID;


--------------------------------------------------------------------------------
FUNCTION UpdateDistCCID(
                        p_report_header_id      IN expDist_REPORT_HEADER_ID,
                        p_report_distribution_id IN expDist_REPORT_DISTRIBUTION_ID,
                        p_exp_dist_ccid         IN expDist_CODE_COMBINATION_ID
) RETURN BOOLEAN IS
--------------------------------------------------------------------------------
BEGIN

    UPDATE ap_exp_report_dists RD
    SET    RD.code_combination_id = p_exp_dist_ccid
    WHERE  RD.report_header_id = p_report_header_id
    AND    RD.report_distribution_id   = p_report_distribution_id;

    return TRUE;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('UpdateDistCCID');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END UpdateDistCCID;

-----------------------------------------------------------------------------
PROCEDURE DeleteReportDistributions(P_ReportID             IN expDist_report_header_ID) IS
--------------------------------------------------------------------------------
  l_TempReportHeaderID   expDist_report_header_ID;
  l_curr_calling_sequence VARCHAR2(100) := 'DeleteReportDistributions';

  -- Selects report lines to delete.  The actual value being selected does not
  -- matter.  For some reason the compiler complains when the OF column-name
  -- in the FOR UPDATE is missing and NOWAIT is used, so the OF
  -- REPORT_HEADER_ID is used as a place holder.
  CURSOR ReportDistributions IS
    SELECT REPORT_HEADER_ID
      FROM AP_EXP_REPORT_DISTS
      WHERE (REPORT_HEADER_ID = P_ReportID)
      FOR UPDATE OF REPORT_HEADER_ID NOWAIT;

BEGIN
  -- Delete the report distributions from table.  An exception will occur if the row
  -- locks cannot be attained because of the NOWAIT argument for select.
  -- We are guaranteed a lock on the records because of the FOR UPDATE
  OPEN ReportDistributions;

  LOOP
    FETCH ReportDistributions into l_TempReportHeaderID;
    EXIT WHEN ReportDistributions%NOTFOUND;

    -- Delete matching line
    DELETE AP_EXP_REPORT_DISTS WHERE CURRENT OF ReportDistributions;
  END LOOP;

  CLOSE ReportDistributions;


EXCEPTION
  WHEN NO_DATA_FOUND THEN
    NULL;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('ReportDistributions');
    APP_EXCEPTION.RAISE_EXCEPTION;
END DeleteReportDistributions;


-------------------------------------------------------------------
-- Name: MoveDistributions
-- Desc: moves Expense Report Distributions from souce to destination
-- Input: p_target_report_header_id - target expense report header id
-- Input: p_source_report_line_id - source expense report line id
-- Input: p_target_report_line_id - target expense report line id
-------------------------------------------------------------------
PROCEDURE MoveDistributions(
  p_target_report_header_id   IN expDist_report_header_ID,
  p_source_report_line_id     IN expDist_report_line_ID,
  p_target_report_line_id     IN expDist_report_line_ID) IS

  l_has_dist     NUMBER;

BEGIN
  AP_WEB_UTILITIES_PKG.LogProcedure('AP_WEB_DB_EXPDIST_PKG',
                                   'start MoveDistributions');

  /* If there is no distribution line, add one. */
  BEGIN
    /* Bug# 6131435 :
		Added rownum condition to avoid TOO_MANY_ROWS_RETURNED exception. */

    SELECT report_line_id
    INTO   l_has_dist
    FROM   ap_exp_report_dists
    WHERE  report_line_id   = p_source_report_line_id
    AND ROWNUM = 1;


  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    AddDistributionLine( p_report_line_id => p_target_report_line_id);
    RETURN;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('MoveDistributions');
    APP_EXCEPTION.RAISE_EXCEPTION;
  END;


  -- For the given line, move its distributions from original ER
  -- to the new ER
  UPDATE AP_EXP_REPORT_DISTS
  SET report_header_id = p_target_report_header_id,
      report_line_id   = p_target_report_line_id
  WHERE report_line_id = p_source_report_line_id;

  AP_WEB_UTILITIES_PKG.LogProcedure('AP_WEB_DB_EXPDIST_PKG',
                                   'end MoveDistributions');

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    NULL;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('MoveDistributions');
    APP_EXCEPTION.RAISE_EXCEPTION;
END MoveDistributions;

-------------------------------------------------------------------
-- Name: DuplicateDistributions
-- Desc: duplicates Expense Report Distributions
-- Input: p_target_report_header_id - target expense report header id
-- Input: p_source_report_line_id - source expense report line id
-- Input: p_target_report_line_id - target expense report line id
-------------------------------------------------------------------
PROCEDURE DuplicateDistributions(
  p_user_id     IN NUMBER,
  p_target_report_header_id   IN expDist_report_header_ID,
  p_source_report_line_id     IN expDist_report_line_ID,
  p_target_report_line_id     IN expDist_report_line_ID) IS

BEGIN
  AP_WEB_UTILITIES_PKG.LogProcedure('AP_WEB_DB_EXPDIST_PKG',
                                   'start DuplicateDistributions');

  -- For the given line, duplicate its distributions
  INSERT INTO AP_EXP_REPORT_DISTS
    (
      report_header_id,
      report_line_id,
      report_distribution_id,
      org_id,
      sequence_num,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      code_combination_id,
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
      segment30,
      amount,
      project_id,
      task_id,
      award_id,
      expenditure_organization_id,
      cost_center,
      preparer_modified_flag
    )
  SELECT
      p_target_report_header_id AS report_header_id,
      p_target_report_line_id AS report_line_id,
      AP_EXP_REPORT_DISTS_S.NEXTVAL AS report_distribution_id,
      org_id,
      sequence_num,
      SYSDATE AS last_update_date,
      nvl(p_user_id,last_updated_by) AS last_updated_by,
      SYSDATE AS creation_date,
      nvl(p_user_id, created_by) AS created_by,
      code_combination_id,
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
      segment30,
      amount,
      project_id,
      task_id,
      award_id,
      expenditure_organization_id,
      cost_center,
      preparer_modified_flag
  FROM AP_EXP_REPORT_DISTS
  WHERE
    report_line_id = p_source_report_line_id;


  AP_WEB_UTILITIES_PKG.LogProcedure('AP_WEB_DB_EXPDIST_PKG',
                                   'end DuplicateDistributions');

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    NULL;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('DuplicateDistributions');
    APP_EXCEPTION.RAISE_EXCEPTION;
END DuplicateDistributions;

--------------------------------------------------------------------------------
PROCEDURE updateAccountValues(
                   p_report_header_id IN  expDist_report_header_ID,
                   p_report_line_id   IN  expDist_REPORT_LINE_ID,
                   p_report_distribution_id IN expDist_REPORT_DISTRIBUTION_ID,
                   p_ccid             IN  expDist_CODE_COMBINATION_ID)
IS
--------------------------------------------------------------------------------
l_sequence_num NUMBER := 0;
l_has_dist     NUMBER;
l_report_distribution_id NUMBER;

BEGIN

      l_report_distribution_id := p_report_distribution_id;

      /* If there is no distribution line, add one.
         p_report_distribution_id is null indicates that there is no
         distribution for the line. */

      if (p_report_distribution_id is null) then

         AddDistributionLine( p_report_line_id => p_report_line_id);


         BEGIN
           SELECT report_distribution_id
           INTO   l_report_distribution_id
           FROM   ap_exp_report_dists
           WHERE  report_header_id = p_report_header_id
           AND    report_line_id  = p_report_line_id
           AND    rownum = 1;

         EXCEPTION
           WHEN NO_DATA_FOUND THEN
             RETURN;
           WHEN OTHERS THEN
             AP_WEB_DB_UTIL_PKG.RaiseException('updateAccountValues');
             APP_EXCEPTION.RAISE_EXCEPTION;
         END;

      end if;

      UPDATE ap_exp_report_dists
      SET    (code_combination_id,
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
             segment30,
	     cost_center) = (SELECT  nvl(code_combination_id,p_ccid),
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
                                   segment30,
				   AP_WEB_DB_EXPDIST_PKG.GetCCSegmentValue(p_ccid) -- Bug 7395568
                            FROM   GL_CODE_COMBINATIONS
                            WHERE  code_combination_id = p_ccid)
     WHERE   report_distribution_id = l_report_distribution_id
     AND     report_header_id = p_report_header_id;

EXCEPTION
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('updateAccountValues');
    APP_EXCEPTION.RAISE_EXCEPTION;
END updateAccountValues;

--------------------------------------------------------------------------------
PROCEDURE updateAccountValuesForForms(
                   p_report_header_id IN  expDist_report_header_ID,
                   p_report_line_id   IN  expDist_REPORT_LINE_ID,
                   p_report_distribution_id IN expDist_REPORT_DISTRIBUTION_ID,
                   p_ccid             IN  expDist_CODE_COMBINATION_ID,
                   p_line_amount      IN NUMBER)
IS
--------------------------------------------------------------------------------
l_sequence_num NUMBER := 0;
l_has_dist     NUMBER;
l_report_distribution_id NUMBER;

BEGIN

      l_report_distribution_id := p_report_distribution_id;

      /* If there is no distribution line, add one.
         p_report_distribution_id is null indicates that there is no
         distribution for the line. */

      if (p_report_distribution_id is null) then

         AddDistributionLine( p_report_line_id => p_report_line_id);


         BEGIN
           SELECT report_distribution_id
           INTO   l_report_distribution_id
           FROM   ap_exp_report_dists
           WHERE  report_header_id = p_report_header_id
           AND    report_line_id  = p_report_line_id
           AND    rownum = 1;

         EXCEPTION
           WHEN NO_DATA_FOUND THEN
             RETURN;
           WHEN OTHERS THEN
             AP_WEB_DB_UTIL_PKG.RaiseException('updateAccountValues');
             APP_EXCEPTION.RAISE_EXCEPTION;
         END;

      end if;

      UPDATE ap_exp_report_dists
      SET    (code_combination_id,
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
             segment30,
	     cost_center) = (SELECT  nvl(code_combination_id,p_ccid),
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
                                   segment30,
				   AP_WEB_DB_EXPDIST_PKG.GetCCSegmentValue(p_ccid) -- Bug 7395568
                            FROM   GL_CODE_COMBINATIONS
                            WHERE  code_combination_id = p_ccid),
             amount = p_line_amount
     WHERE   report_distribution_id = l_report_distribution_id
     AND     report_header_id = p_report_header_id;

EXCEPTION
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('updateAccountValuesForForms');
    APP_EXCEPTION.RAISE_EXCEPTION;
END updateAccountValuesForForms;

--------------------------------------------------------------------------------
PROCEDURE updateDistAccountValues(
                   p_report_header_id IN  expDist_report_header_ID)
IS
--------------------------------------------------------------------------------
  CURSOR dist_lines_c IS
    SELECT *
    FROM AP_EXP_REPORT_DISTS_ALL
    WHERE REPORT_HEADER_ID = p_report_header_id
    FOR UPDATE OF REPORT_HEADER_ID NOWAIT;

  dist_lines_rec                dist_lines_c%ROWTYPE;

BEGIN

  OPEN dist_lines_c;

  LOOP
    FETCH dist_lines_c into dist_lines_rec;
    EXIT WHEN dist_lines_c%NOTFOUND;

    IF dist_lines_rec.CODE_COMBINATION_ID IS NOT NULL THEN
      UPDATE ap_exp_report_dists_all
      SET   (segment1,
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
             segment30,
	     cost_center) = (SELECT  segment1,
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
                                   segment30,
				   AP_WEB_DB_EXPDIST_PKG.GetCCSegmentValue(dist_lines_rec.CODE_COMBINATION_ID) -- Bug 7395568
                            FROM   GL_CODE_COMBINATIONS
                            WHERE  code_combination_id = dist_lines_rec.CODE_COMBINATION_ID)
     WHERE CURRENT OF dist_lines_c;

    END IF;
  END LOOP;

  CLOSE dist_lines_c;

EXCEPTION
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('updateDistAccountValues');
    APP_EXCEPTION.RAISE_EXCEPTION;
END updateDistAccountValues;

--------------------------------------------------------------------------------
PROCEDURE updateDistAcctValuesForForms(
                   p_report_header_id IN  expDist_report_header_ID)
IS
--------------------------------------------------------------------------------
  l_report_distribution_id  expDist_REPORT_DISTRIBUTION_ID;
  c_line_ccid_cursor        AP_WEB_DB_EXPLINE_PKG.ExpLineCCIDCursor;
  l_report_line_id          AP_WEB_DB_EXPLINE_PKG.expLines_report_line_id;
  l_line_ccid               AP_WEB_DB_EXPLINE_PKG.expLines_codeCombID;
  l_dist_id     	    AP_EXP_REPORT_DISTS.REPORT_DISTRIBUTION_ID%TYPE;
  l_line_amount             NUMBER;
BEGIN

  IF (AP_WEB_DB_EXPLINE_PKG.GetLineCCIDCursor(p_report_header_id, c_line_ccid_cursor)) THEN

    LOOP
      FETCH c_line_ccid_cursor INTO l_report_line_id, l_line_ccid, l_line_amount;
      EXIT WHEN c_line_ccid_cursor%NOTFOUND;

      BEGIN
      /* If there is no distribution line, add one. */
      SELECT report_distribution_id
      INTO   l_dist_id
      FROM   ap_exp_report_dists
      WHERE  report_header_id = p_report_header_id
      AND    report_line_id   = l_report_line_id;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
	  l_dist_id := null;
        WHEN OTHERS THEN
          AP_WEB_DB_UTIL_PKG.RaiseException('updateAccountValues');
          APP_EXCEPTION.RAISE_EXCEPTION;
      END;

      updateAccountValuesForForms(p_report_header_id, l_report_line_id, l_dist_id, l_line_ccid, l_line_amount);

    END LOOP;
  END IF;

END updateDistAcctValuesForForms;

--------------------------------------------------------------------------------
PROCEDURE AddDistributionLine(
                   p_report_line_id           IN  AP_EXPENSE_REPORT_LINES.REPORT_LINE_ID%TYPE)
IS
--------------------------------------------------------------------------------
  l_debug_info              varchar2(1000);
  l_sequence_num            NUMBER;

BEGIN

  AP_WEB_UTILITIES_PKG.LogProcedure('AP_WEB_DB_EXPDIST_PKG',
                                   'start AddDistributionLine');
  l_sequence_num := 0;

  -- For the given line, duplicate its distributions
  INSERT INTO AP_EXP_REPORT_DISTS
    (
      report_header_id,
      report_line_id,
      report_distribution_id,
      sequence_num,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      code_combination_id,
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
      segment30,
      org_id,
      amount,
      project_id,
      task_id,
      award_id,
      expenditure_organization_id,
      cost_center
    )
  SELECT
      XL.report_header_id,
      XL.report_line_id,
      AP_EXP_REPORT_DISTS_S.NEXTVAL,
      l_sequence_num,
      SYSDATE,
      XL.last_updated_by,
      SYSDATE,
      XL.created_by,
      XL.code_combination_id,
      GL.segment1,
      GL.segment2,
      GL.segment3,
      GL.segment4,
      GL.segment5,
      GL.segment6,
      GL.segment7,
      GL.segment8,
      GL.segment9,
      GL.segment10,
      GL.segment11,
      GL.segment12,
      GL.segment13,
      GL.segment14,
      GL.segment15,
      GL.segment16,
      GL.segment17,
      GL.segment18,
      GL.segment19,
      GL.segment20,
      GL.segment21,
      GL.segment22,
      GL.segment23,
      GL.segment24,
      GL.segment25,
      GL.segment26,
      GL.segment27,
      GL.segment28,
      GL.segment29,
      GL.segment30,
      XL.org_id,
      XL.amount,
      XL.project_id,
      XL.task_id,
      XL.award_id,
      XL.expenditure_organization_id,
      XH.flex_concatenated -- Bug: 6735020, flex_concatenated should be fetched from headers
  FROM  AP_EXPENSE_REPORT_LINES XL,
        AP_EXPENSE_REPORT_HEADERS XH,
        GL_CODE_COMBINATIONS GL
  WHERE XL.report_line_id = p_report_line_id
  AND   XL.report_header_id = XH.report_header_id
  AND   GL.code_combination_id(+) = XL.code_combination_id;




  AP_WEB_UTILITIES_PKG.LogProcedure('AP_WEB_DB_EXPDIST_PKG',
                                   'end AddDistributionLine');


EXCEPTION
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('AddDistributionLine');
    APP_EXCEPTION.RAISE_EXCEPTION;
END AddDistributionLine;

--------------------------------------------------------------------------------
PROCEDURE AddDistributionLine(
            p_segments           IN  AP_OIE_KFF_SEGMENTS_T,
            p_report_line_id     IN  AP_EXPENSE_REPORT_LINES.REPORT_LINE_ID%TYPE,
            p_chart_of_accounts_id  IN NUMBER)
IS
--------------------------------------------------------------------------------
  l_debug_info              varchar2(1000);
  l_sequence_num            NUMBER;
  l_colname		    fnd_id_flex_segments.application_column_name%type;
  l_sqlstmt	            varchar2(20000);
  l_col_stmt	            varchar2(5000);
  l_temp	            long;
  l_cursor                  integer;
  l_rows                    integer;
  l_report_header_id        AP_WEB_DB_EXPLINE_PKG.expLines_headerID;
  l_last_updated_by         NUMBER;
  l_created_by	            NUMBER;
  l_report_distribution_id  expDist_REPORT_DISTRIBUTION_ID;
  l_code_combination_id     expDist_CODE_COMBINATION_ID;
  l_org_id                  NUMBER;
  l_amount                  ap_exp_report_dists_all.amount%TYPE;
  l_project_id              ap_exp_report_dists_all.project_id%TYPE;
  l_task_id                 ap_exp_report_dists_all.task_id%TYPE;
  l_award_id                ap_exp_report_dists_all.award_id%TYPE;
  l_expenditure_organization_id ap_exp_report_dists_all.expenditure_organization_id%TYPE;
  l_cost_center             ap_exp_report_dists_all.cost_center%TYPE;
  l_cost_center_seg_num	    NUMBER;
  l_chart_of_accounts_id    gl_sets_of_books.chart_of_accounts_id%type;

  -- BUG 7025517
  p_seg1                    varchar2(25) := null;
  p_seg2                    varchar2(25) := null;
  p_seg3                    varchar2(25) := null;
  p_seg4                    varchar2(25) := null;
  p_seg5                    varchar2(25) := null;
  p_seg6                    varchar2(25) := null;
  p_seg7                    varchar2(25) := null;
  p_seg8                    varchar2(25) := null;
  p_seg9                    varchar2(25) := null;
  p_seg10                    varchar2(25) := null;
  p_seg11                    varchar2(25) := null;
  p_seg12                    varchar2(25) := null;
  p_seg13                    varchar2(25) := null;
  p_seg14                    varchar2(25) := null;
  p_seg15                    varchar2(25) := null;
  p_seg16                    varchar2(25) := null;
  p_seg17                    varchar2(25) := null;
  p_seg18                    varchar2(25) := null;
  p_seg19                    varchar2(25) := null;
  p_seg20                    varchar2(25) := null;
  p_seg21                    varchar2(25) := null;
  p_seg22                    varchar2(25) := null;
  p_seg23                    varchar2(25) := null;
  p_seg24                    varchar2(25) := null;
  p_seg25                    varchar2(25) := null;
  p_seg26                    varchar2(25) := null;
  p_seg27                    varchar2(25) := null;
  p_seg28                    varchar2(25) := null;
  p_seg29                    varchar2(25) := null;
  p_seg30                    varchar2(25) := null;





BEGIN

  AP_WEB_UTILITIES_PKG.LogProcedure('AP_WEB_DB_EXPDIST_PKG',
                                   'start AddDistributionLine');

  -----------------------------------------------------
  l_debug_info := 'AP_WEB_DB_AP_INT_PKG.GetCOAofSOB';
  -----------------------------------------------------
  IF (NOT AP_WEB_DB_AP_INT_PKG.GetCOAofSOB(l_chart_of_accounts_id)) THEN
       l_chart_of_accounts_id := NULL;
  END IF;

  -----------------------------------------------------
  l_debug_info := 'Get the segment number corresponding to the costcenter qualifier.';
  -----------------------------------------------------
  IF (NOT FND_FLEX_APIS.GET_QUALIFIER_SEGNUM(
                               101,
                               'GL#',
                               l_chart_of_accounts_id,
                               'FA_COST_CTR',
                               l_cost_center_seg_num)) then
    return;
  END IF;
  -- Bug 7395568, get the cost center
  l_cost_center := p_segments(l_cost_center_seg_num);

  -----------------------------------------------------
  l_debug_info := 'select from ap_expense_report_lines';
  -----------------------------------------------------
  l_sequence_num := 0;
  SELECT XL.report_header_id,
         XL.code_combination_id,
         XL.last_updated_by,
         XL.created_by,
         XL.org_id,
         XL.amount,
         XL.project_id,
         XL.task_id,
         XL.award_id,
         XL.expenditure_organization_id,
         XH.flex_concatenated -- Bug 6735020, flex_concatenated should be fetched from headers
  INTO   l_report_header_id,
         l_code_combination_id,
         l_last_updated_by,
         l_created_by,
         l_org_id,
         l_amount,
         l_project_id,
         l_task_id,
         l_award_id,
         l_expenditure_organization_id,
         l_cost_center
  FROM   ap_expense_report_lines XL,
         ap_expense_report_headers XH
  WHERE  XL.report_line_id = p_report_line_id
  AND    XL.report_header_id = XH.report_header_id;

  -----------------------------------------------------
  l_debug_info := 'get next AP_EXP_REPORT_DISTS_S';
  -----------------------------------------------------
  SELECT AP_EXP_REPORT_DISTS_S.NEXTVAL
  INTO   l_report_distribution_id
  FROM   DUAL;

  l_sqlstmt := 'INSERT INTO AP_EXP_REPORT_DISTS ( ';
  l_sqlstmt := l_sqlstmt || 'report_header_id, ';
  l_sqlstmt := l_sqlstmt || 'report_line_id, ';
  l_sqlstmt := l_sqlstmt || 'report_distribution_id, ';
  l_sqlstmt := l_sqlstmt || 'sequence_num, ';
  l_sqlstmt := l_sqlstmt || 'last_update_date, ';
  l_sqlstmt := l_sqlstmt || 'last_updated_by, ';
  l_sqlstmt := l_sqlstmt || 'creation_date, ';
  l_sqlstmt := l_sqlstmt || 'created_by, ';
  if (l_code_combination_id is not null) then
  l_sqlstmt := l_sqlstmt || 'code_combination_id, ';
  end if;
  if (l_org_id is not null) then
  l_sqlstmt := l_sqlstmt || 'org_id, ';
  end if;
  if (l_amount is not null) then
  l_sqlstmt := l_sqlstmt || 'amount, ';
  end if;
  if (l_project_id is not null) then
  l_sqlstmt := l_sqlstmt || 'project_id, ';
  end if;
  if (l_task_id is not null) then
  l_sqlstmt := l_sqlstmt || 'task_id, ';
  end if;
  if (l_award_id is not null) then
  l_sqlstmt := l_sqlstmt || 'award_id, ';
  end if;
  if (l_expenditure_organization_id is not null) then
  l_sqlstmt := l_sqlstmt || 'expenditure_organization_id, ';
  end if;
  if (l_cost_center is not null) then
  l_sqlstmt := l_sqlstmt || 'cost_center, ';
  end if;

  -- Construct the segment columns in the insert clause
  if cflex%isopen then close cflex;
  end if;

  open cflex(p_chart_of_accounts_id);
    LOOP
      FETCH cflex INTO l_colname;
      EXIT WHEN cflex%NOTFOUND;

        IF l_col_stmt IS NOT NULL THEN
          l_col_stmt := l_col_stmt || ',' || l_colname;
        ELSE
          l_col_stmt := l_colname;
        END IF;
  END LOOP;

  l_sqlstmt := l_sqlstmt || l_col_stmt;


  l_sqlstmt := l_sqlstmt || ') values (';


  /*    BUG 7025517  --  refer to bind vars in values clause of insert statement */
  /*  l_sqlstmt := l_sqlstmt || l_report_header_id;
  **  l_sqlstmt := l_sqlstmt || ', ' || p_report_line_id;
  **  l_sqlstmt := l_sqlstmt || ', ' || l_report_distribution_id;
  **  l_sqlstmt := l_sqlstmt || ', ' || l_sequence_num;
  **  l_sqlstmt := l_sqlstmt || ', ' || '''' || sysdate || '''';
  **  l_sqlstmt := l_sqlstmt || ', ' || l_last_updated_by;
  **  l_sqlstmt := l_sqlstmt || ', ' || '''' || sysdate || '''';
  **  l_sqlstmt := l_sqlstmt || ', ' || l_created_by;
  **  if (l_code_combination_id is not null) then
  **  l_sqlstmt := l_sqlstmt || ', ' || '''' || l_code_combination_id || '''';
  **  end if;
  **    if (l_org_id is not null) then
  **    l_sqlstmt := l_sqlstmt || ', ' || l_org_id;
  **    end if;
  **    if (l_amount is not null) then
  **    l_sqlstmt := l_sqlstmt || ', ' || l_amount;
  **    end if;
  **    if (l_project_id is not null) then
  **    l_sqlstmt := l_sqlstmt || ', ' || l_project_id;
  **    end if;
  **    if (l_task_id is not null) then
  **    l_sqlstmt := l_sqlstmt || ', ' || l_task_id;
  **    end if;
  **    if (l_award_id is not null) then
  **    l_sqlstmt := l_sqlstmt || ', ' || l_award_id;
  **    end if;
  **    if (l_expenditure_organization_id is not null) then
  **    l_sqlstmt := l_sqlstmt || ', ' || l_expenditure_organization_id;
  **    end if;
  **    if (l_cost_center is not null) then
  **    l_sqlstmt := l_sqlstmt || ', ' || '''' || l_cost_center || '''';
  **    end if;
  */
  /*    BUG 7025517  --  refer to bind vars in values clause of insert statement */
  l_sqlstmt := l_sqlstmt || ' :l_report_header_id' ;
  l_sqlstmt := l_sqlstmt || ', :p_report_line_id' ;
  l_sqlstmt := l_sqlstmt || ', :l_report_distribution_id' ;
  l_sqlstmt := l_sqlstmt || ', :l_sequence_num' ;
  l_sqlstmt := l_sqlstmt || ', sysdate' ;
  l_sqlstmt := l_sqlstmt || ', :l_last_updated_by' ;
  l_sqlstmt := l_sqlstmt || ', sysdate' ;
  l_sqlstmt := l_sqlstmt || ', :l_created_by' ;
  if (l_code_combination_id is not null) then
      l_sqlstmt := l_sqlstmt || ', :l_code_combination_id' ;
  end if;
  if (l_org_id is not null) then
  l_sqlstmt := l_sqlstmt || ', :l_org_id' ;
  end if;
  if (l_amount is not null) then
  l_sqlstmt := l_sqlstmt || ', :l_amount' ;
  end if;
  if (l_project_id is not null) then
  l_sqlstmt := l_sqlstmt || ', :l_project_id' ;
  end if;
  if (l_task_id is not null) then
  l_sqlstmt := l_sqlstmt || ', :l_task_id' ;
  end if;
  if (l_award_id is not null) then
  l_sqlstmt := l_sqlstmt || ', :l_award_id' ;
  end if;
  if (l_expenditure_organization_id is not null) then
  l_sqlstmt := l_sqlstmt || ', :l_expenditure_organization_id' ;
  end if;
  if (l_cost_center is not null) then
  l_sqlstmt := l_sqlstmt || ', :l_cost_center' ;
  end if;

  -- BUG 7025517
  -- BUG 7698138
  FOR i IN 1..p_segments.count LOOP
	case i
		when 1 then p_seg1        := p_segments(1);
		when 2 then p_seg2        := p_segments(2);
		when 3 then p_seg3        := p_segments(3);
		when 4 then p_seg4        := p_segments(4);
		when 5 then p_seg5        := p_segments(5);
		when 6 then p_seg6        := p_segments(6);
		when 7 then p_seg7        := p_segments(7);
		when 8 then p_seg8        := p_segments(8);
		when 9 then p_seg9        := p_segments(9);
		when 10 then p_seg10       := p_segments(10);
		when 11 then p_seg11       := p_segments(11);
		when 12 then p_seg12       := p_segments(12);
		when 13 then p_seg13       := p_segments(13);
		when 14 then p_seg14       := p_segments(14);
		when 15 then p_seg15       := p_segments(15);
		when 16 then p_seg16       := p_segments(16);
		when 17 then p_seg17       := p_segments(17);
		when 18 then p_seg18       := p_segments(18);
		when 19 then p_seg19       := p_segments(19);
		when 20 then p_seg20       := p_segments(20);
		when 21 then p_seg21       := p_segments(21);
		when 22 then p_seg22       := p_segments(22);
		when 23 then p_seg23       := p_segments(23);
		when 24 then p_seg24       := p_segments(24);
		when 25 then p_seg25       := p_segments(25);
		when 26 then p_seg26       := p_segments(26);
		when 27 then p_seg27       := p_segments(27);
		when 28 then p_seg28       := p_segments(28);
		when 29 then p_seg29       := p_segments(29);
		when 30 then p_seg30       := p_segments(30);

	end case;
  END LOOP;

  --FOR i IN 1..p_segments.count LOOP
  --  if (p_segments(i) is not null) then
  --    l_sqlstmt := l_sqlstmt || ',' || '''' || p_segments(i) || '''';
  --  end if;
  --END LOOP;
  -- ...........  l_sqlstmt := l_sqlstmt || ', :l_cost_center' ;

  -- BUG 7698138
  if (p_seg1 is not null) then l_sqlstmt := l_sqlstmt || ', :p_seg1' ; end if ;
  if (p_seg2 is not null) then l_sqlstmt := l_sqlstmt || ', :p_seg2' ; end if ;
  if (p_seg3 is not null) then l_sqlstmt := l_sqlstmt || ', :p_seg3' ; end if ;
  if (p_seg4 is not null) then l_sqlstmt := l_sqlstmt || ', :p_seg4' ; end if ;
  if (p_seg5 is not null) then l_sqlstmt := l_sqlstmt || ', :p_seg5' ; end if ;
  if (p_seg6 is not null) then l_sqlstmt := l_sqlstmt || ', :p_seg6' ; end if ;
  if (p_seg7 is not null) then l_sqlstmt := l_sqlstmt || ', :p_seg7' ; end if ;
  if (p_seg8 is not null) then l_sqlstmt := l_sqlstmt || ', :p_seg8' ; end if ;
  if (p_seg9 is not null) then l_sqlstmt := l_sqlstmt || ', :p_seg9' ; end if ;
  if (p_seg10 is not null) then l_sqlstmt := l_sqlstmt || ', :p_seg10' ; end if ;
  if (p_seg11 is not null) then l_sqlstmt := l_sqlstmt || ', :p_seg11' ; end if ;
  if (p_seg12 is not null) then l_sqlstmt := l_sqlstmt || ', :p_seg12' ; end if ;
  if (p_seg13 is not null) then l_sqlstmt := l_sqlstmt || ', :p_seg13' ; end if ;
  if (p_seg14 is not null) then l_sqlstmt := l_sqlstmt || ', :p_seg14' ; end if ;
  if (p_seg15 is not null) then l_sqlstmt := l_sqlstmt || ', :p_seg15' ; end if ;
  if (p_seg16 is not null) then l_sqlstmt := l_sqlstmt || ', :p_seg16' ; end if ;
  if (p_seg17 is not null) then l_sqlstmt := l_sqlstmt || ', :p_seg17' ; end if ;
  if (p_seg18 is not null) then l_sqlstmt := l_sqlstmt || ', :p_seg18' ; end if ;
  if (p_seg19 is not null) then l_sqlstmt := l_sqlstmt || ', :p_seg19' ; end if ;
  if (p_seg20 is not null) then l_sqlstmt := l_sqlstmt || ', :p_seg20' ; end if ;
  if (p_seg21 is not null) then l_sqlstmt := l_sqlstmt || ', :p_seg21' ; end if ;
  if (p_seg22 is not null) then l_sqlstmt := l_sqlstmt || ', :p_seg22' ; end if ;
  if (p_seg23 is not null) then l_sqlstmt := l_sqlstmt || ', :p_seg23' ; end if ;
  if (p_seg24 is not null) then l_sqlstmt := l_sqlstmt || ', :p_seg24' ; end if ;
  if (p_seg25 is not null) then l_sqlstmt := l_sqlstmt || ', :p_seg25' ; end if ;
  if (p_seg26 is not null) then l_sqlstmt := l_sqlstmt || ', :p_seg26' ; end if ;
  if (p_seg27 is not null) then l_sqlstmt := l_sqlstmt || ', :p_seg27' ; end if ;
  if (p_seg28 is not null) then l_sqlstmt := l_sqlstmt || ', :p_seg28' ; end if ;
  if (p_seg29 is not null) then l_sqlstmt := l_sqlstmt || ', :p_seg29' ; end if ;
  if (p_seg30 is not null) then l_sqlstmt := l_sqlstmt || ', :p_seg30' ; end if ;


  l_sqlstmt := l_sqlstmt || ')';

  -----------------------------------------------------
  l_debug_info := 'l_sqlstmt = '||l_sqlstmt;
  -----------------------------------------------------
  -----------------
  -- Now execute it
  -----------------
  l_cursor := dbms_sql.open_cursor;

  -----------------------------------------------------
  l_debug_info := 'parse cursor';
  -----------------------------------------------------
  dbms_sql.parse(l_cursor, l_sqlstmt, dbms_sql.native);


  /*    BUG 7025517  --  bind the input vars */
  dbms_sql.bind_variable(l_cursor,':l_report_header_id', l_report_header_id) ;
  dbms_sql.bind_variable(l_cursor,':p_report_line_id', p_report_line_id) ;
  dbms_sql.bind_variable(l_cursor,':l_report_distribution_id', l_report_distribution_id) ;
  dbms_sql.bind_variable(l_cursor,':l_sequence_num', l_sequence_num) ;
  dbms_sql.bind_variable(l_cursor,':l_last_updated_by', l_last_updated_by) ;
  dbms_sql.bind_variable(l_cursor,':l_created_by', l_created_by) ;
  if (l_code_combination_id is not null) then
      dbms_sql.bind_variable(l_cursor,':l_code_combination_id', l_code_combination_id) ;
  end if;
  if (l_org_id is not null) then
      dbms_sql.bind_variable(l_cursor,':l_org_id', l_org_id) ;
  end if;
  if (l_amount is not null) then
      dbms_sql.bind_variable(l_cursor,':l_amount', l_amount) ;
  end if;
  if (l_project_id is not null) then
      dbms_sql.bind_variable(l_cursor,':l_project_id', l_project_id) ;
  end if;
  if (l_task_id is not null) then
      dbms_sql.bind_variable(l_cursor,':l_task_id', l_task_id) ;
  end if;
  if (l_award_id is not null) then
      dbms_sql.bind_variable(l_cursor,':l_award_id', l_award_id) ;
  end if;
  if (l_expenditure_organization_id is not null) then
      dbms_sql.bind_variable(l_cursor,':l_expenditure_organization_id', l_expenditure_organization_id) ;
  end if;
  if (l_cost_center is not null) then
      dbms_sql.bind_variable(l_cursor,':l_cost_center', l_cost_center) ;
  end if;

if (p_seg1 is not null) then   dbms_sql.bind_variable(l_cursor,':p_seg1', p_seg1) ; end if ;
if (p_seg2 is not null) then   dbms_sql.bind_variable(l_cursor,':p_seg2', p_seg2) ; end if ;
if (p_seg3 is not null) then   dbms_sql.bind_variable(l_cursor,':p_seg3', p_seg3) ; end if ;
if (p_seg4 is not null) then   dbms_sql.bind_variable(l_cursor,':p_seg4', p_seg4) ; end if ;
if (p_seg5 is not null) then   dbms_sql.bind_variable(l_cursor,':p_seg5', p_seg5) ; end if ;
if (p_seg6 is not null) then   dbms_sql.bind_variable(l_cursor,':p_seg6', p_seg6) ; end if ;
if (p_seg7 is not null) then   dbms_sql.bind_variable(l_cursor,':p_seg7', p_seg7) ; end if ;
if (p_seg8 is not null) then   dbms_sql.bind_variable(l_cursor,':p_seg8', p_seg8) ; end if ;
if (p_seg9 is not null) then   dbms_sql.bind_variable(l_cursor,':p_seg9', p_seg9) ; end if ;
if (p_seg10 is not null) then   dbms_sql.bind_variable(l_cursor,':p_seg10', p_seg10) ; end if ;
if (p_seg11 is not null) then   dbms_sql.bind_variable(l_cursor,':p_seg11', p_seg11) ; end if ;
if (p_seg12 is not null) then   dbms_sql.bind_variable(l_cursor,':p_seg12', p_seg12) ; end if ;
if (p_seg13 is not null) then   dbms_sql.bind_variable(l_cursor,':p_seg13', p_seg13) ; end if ;
if (p_seg14 is not null) then   dbms_sql.bind_variable(l_cursor,':p_seg14', p_seg14) ; end if ;
if (p_seg15 is not null) then   dbms_sql.bind_variable(l_cursor,':p_seg15', p_seg15) ; end if ;
if (p_seg16 is not null) then   dbms_sql.bind_variable(l_cursor,':p_seg16', p_seg16) ; end if ;
if (p_seg17 is not null) then   dbms_sql.bind_variable(l_cursor,':p_seg17', p_seg17) ; end if ;
if (p_seg18 is not null) then   dbms_sql.bind_variable(l_cursor,':p_seg18', p_seg18) ; end if ;
if (p_seg19 is not null) then   dbms_sql.bind_variable(l_cursor,':p_seg19', p_seg19) ; end if ;
if (p_seg20 is not null) then   dbms_sql.bind_variable(l_cursor,':p_seg20', p_seg20) ; end if ;
if (p_seg21 is not null) then   dbms_sql.bind_variable(l_cursor,':p_seg21', p_seg21) ; end if ;
if (p_seg22 is not null) then   dbms_sql.bind_variable(l_cursor,':p_seg22', p_seg22) ; end if ;
if (p_seg23 is not null) then   dbms_sql.bind_variable(l_cursor,':p_seg23', p_seg23) ; end if ;
if (p_seg24 is not null) then   dbms_sql.bind_variable(l_cursor,':p_seg24', p_seg24) ; end if ;
if (p_seg25 is not null) then   dbms_sql.bind_variable(l_cursor,':p_seg25', p_seg25) ; end if ;
if (p_seg26 is not null) then   dbms_sql.bind_variable(l_cursor,':p_seg26', p_seg26) ; end if ;
if (p_seg27 is not null) then   dbms_sql.bind_variable(l_cursor,':p_seg27', p_seg27) ; end if ;
if (p_seg28 is not null) then   dbms_sql.bind_variable(l_cursor,':p_seg28', p_seg28) ; end if ;
if (p_seg29 is not null) then   dbms_sql.bind_variable(l_cursor,':p_seg29', p_seg29) ; end if ;
if (p_seg30 is not null) then   dbms_sql.bind_variable(l_cursor,':p_seg30', p_seg30) ; end if ;


  /*    BUG 7025517 ... End		*/


  -----------------------------------------------------
  l_debug_info := 'execute cursor';
  -----------------------------------------------------
  l_rows := dbms_sql.execute(l_cursor);


  AP_WEB_UTILITIES_PKG.LogProcedure('AP_WEB_DB_EXPDIST_PKG',
                                   'end AddDistributionLine');


EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'AddDistributionLine');
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END AddDistributionLine;
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
FUNCTION ContainsProjectRelatedDist(
        p_report_header_id        IN  expDist_report_header_ID
) RETURN BOOLEAN IS
--------------------------------------------------------------------------------
  V_Temp VARCHAR2(20);
BEGIN

  -- Check if project-related dist exists
    SELECT 'dist exists'
    INTO   V_Temp
    FROM   AP_EXP_REPORT_DISTS
    WHERE  REPORT_HEADER_ID = p_report_header_id
    AND    PROJECT_ID IS NOT NULL
    AND    TASK_ID IS NOT NULL;

    return TRUE;

EXCEPTION
        WHEN TOO_MANY_ROWS THEN
                return TRUE;
        WHEN NO_DATA_FOUND THEN
                return FALSE;

        WHEN OTHERS THEN
                AP_WEB_DB_UTIL_PKG.RaiseException( 'ContainsProjectRelatedDist' );
                APP_EXCEPTION.RAISE_EXCEPTION;
                return FALSE;
END ContainsProjectRelatedDist;


--------------------------------------------------------------------------------
FUNCTION ContainsNonProjectRelatedDist(
        p_report_header_id        IN  expDist_report_header_ID
) RETURN BOOLEAN IS
--------------------------------------------------------------------------------
  V_Temp                VARCHAR2(20);
BEGIN

  -- Check if non-project-related dist exists
    SELECT 'dist exists'
    INTO   V_Temp
    FROM   AP_EXP_REPORT_DISTS
    WHERE  REPORT_HEADER_ID = p_report_header_id
    AND    PROJECT_ID IS NULL
    AND    TASK_ID IS NULL;

    return TRUE;

EXCEPTION
        WHEN TOO_MANY_ROWS THEN
                return TRUE;
        WHEN NO_DATA_FOUND THEN
                return FALSE;
        WHEN OTHERS THEN
                AP_WEB_DB_UTIL_PKG.RaiseException( 'ContainsNonProjectRelatedDist' );

                APP_EXCEPTION.RAISE_EXCEPTION;
                return FALSE;
END ContainsNonProjectRelatedDist;

PROCEDURE ResplitDistAmounts(p_report_line_id IN NUMBER,
                             p_line_amt       IN NUMBER,
                             p_currency_code  IN VARCHAR2) IS

l_dist_sum	NUMBER;
l_dist_id	NUMBER;
l_dist_amt	NUMBER;
l_remainder	NUMBER;
l_last_dist_id	NUMBER;

cursor c_dists is
	select report_distribution_id, amount
	from ap_exp_report_dists_all
	where report_line_id = p_report_line_id;

BEGIN
  select sum(amount) into l_dist_sum
  from ap_exp_report_dists_all
  where report_line_id = p_report_line_id;

  l_remainder := p_line_amt;
  open c_dists;
  loop
	fetch c_dists into l_dist_id, l_dist_amt;
	exit when c_dists%NOTFOUND;

        -- Ex: If the New line has an amount of 200 and the previous dists have amounts say
        -- 300 and 300, the new dists will be 200 * (300/600) = 100 and 100
        -- This logic will work in all cases and is used in ExpenseAllocationAMImpl.java as well.
	l_dist_amt := AP_WEB_UTILITIES_PKG.OIE_ROUND_CURRENCY(p_line_amt * (l_dist_amt/l_dist_sum), p_currency_code);

	update ap_exp_report_dists_all set amount = l_dist_amt
	where report_distribution_id = l_dist_id;
	l_remainder := l_remainder - l_dist_amt;
	l_last_dist_id := l_dist_id;
  end loop;
  close c_dists;
  -- If there is any line amount still remaining add it to the last line.
  if(l_remainder <> 0) then
	update ap_exp_report_dists_all set amount = (amount + l_remainder)
	where report_distribution_id = l_last_dist_id;
  end if;
exception
when others then
AP_WEB_DB_UTIL_PKG.RaiseException('ResplitDistAmounts');
      APP_EXCEPTION.RAISE_EXCEPTION;
END ResplitDistAmounts;

-- Bug: 7395568
---------------------------------------------------------------------------------------
FUNCTION GetCCSegmentValue(p_ccid    IN  expDist_CODE_COMBINATION_ID) RETURN VARCHAR2 IS
---------------------------------------------------------------------------------------
l_cc_segment_name	 varchar2(10);
l_segment_value		 varchar2(25);


BEGIN
  -- Fetch the cost center segment name
  AP_WEB_ACCTG_PKG.GetCostCenterSegmentName(l_cc_segment_name);

  -- Fetch the costcenter segment value.
  EXECUTE IMMEDIATE 'select '|| l_cc_segment_name || ' from gl_code_combinations where code_combination_id = :1'
		  into l_segment_value
		  using p_ccid;

  RETURN l_segment_value;

  EXCEPTION WHEN OTHERS THEN
    AP_WEB_UTILITIES_PKG.LogProcedure('AP_WEB_DB_EXPDIST_PKG',
                                   'Exception getting segment value ' || SQLERRM);
    -- Return Null for exception.
    RETURN NULL;
END GetCCSegmentValue;

END AP_WEB_DB_EXPDIST_PKG;

/
