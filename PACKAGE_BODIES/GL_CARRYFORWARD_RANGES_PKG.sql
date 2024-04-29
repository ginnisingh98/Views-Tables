--------------------------------------------------------
--  DDL for Package Body GL_CARRYFORWARD_RANGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_CARRYFORWARD_RANGES_PKG" as
/* $Header: glicfrab.pls 120.2 2005/05/05 01:03:39 kvora ship $ */

  FUNCTION get_unique_id RETURN NUMBER IS
    CURSOR get_new_id IS
      SELECT gl_carryforward_ranges_s.NEXTVAL
      FROM sys.dual;
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
      fnd_message.set_token('SEQUENCE', 'GL_CARRYFORWARD_RANGES_S');
      app_exception.raise_exception;
    END IF;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE', 'gl_carryforward_ranges.get_unique_id');
      RAISE;
  END get_unique_id;



  PROCEDURE check_overlapping(x_carryforward_range_id IN NUMBER,
			 x_segment1_low	   IN VARCHAR2,
			 x_segment1_high   IN VARCHAR2,
			 x_segment2_low	   IN VARCHAR2,
			 x_segment2_high   IN VARCHAR2,
			 x_segment3_low	   IN VARCHAR2,
			 x_segment3_high   IN VARCHAR2,
			 x_segment4_low	   IN VARCHAR2,
			 x_segment4_high   IN VARCHAR2,
			 x_segment5_low	   IN VARCHAR2,
			 x_segment5_high   IN VARCHAR2,
			 x_segment6_low	   IN VARCHAR2,
			 x_segment6_high   IN VARCHAR2,
			 x_segment7_low	   IN VARCHAR2,
			 x_segment7_high   IN VARCHAR2,
			 x_segment8_low	   IN VARCHAR2,
			 x_segment8_high   IN VARCHAR2,
			 x_segment9_low	   IN VARCHAR2,
			 x_segment9_high   IN VARCHAR2,
			 x_segment10_low   IN VARCHAR2,
			 x_segment10_high  IN VARCHAR2,
			 x_segment11_low   IN VARCHAR2,
			 x_segment11_high  IN VARCHAR2,
			 x_segment12_low   IN VARCHAR2,
			 x_segment12_high  IN VARCHAR2,
			 x_segment13_low   IN VARCHAR2,
			 x_segment13_high  IN VARCHAR2,
			 x_segment14_low   IN VARCHAR2,
			 x_segment14_high  IN VARCHAR2,
			 x_segment15_low   IN VARCHAR2,
			 x_segment15_high  IN VARCHAR2,
			 x_segment16_low   IN VARCHAR2,
			 x_segment16_high  IN VARCHAR2,
			 x_segment17_low   IN VARCHAR2,
			 x_segment17_high  IN VARCHAR2,
			 x_segment18_low   IN VARCHAR2,
			 x_segment18_high  IN VARCHAR2,
			 x_segment19_low   IN VARCHAR2,
			 x_segment19_high  IN VARCHAR2,
			 x_segment20_low   IN VARCHAR2,
			 x_segment20_high  IN VARCHAR2,
			 x_segment21_low   IN VARCHAR2,
			 x_segment21_high  IN VARCHAR2,
			 x_segment22_low   IN VARCHAR2,
			 x_segment22_high  IN VARCHAR2,
			 x_segment23_low   IN VARCHAR2,
			 x_segment23_high  IN VARCHAR2,
			 x_segment24_low   IN VARCHAR2,
			 x_segment24_high  IN VARCHAR2,
			 x_segment25_low   IN VARCHAR2,
			 x_segment25_high  IN VARCHAR2,
			 x_segment26_low   IN VARCHAR2,
			 x_segment26_high  IN VARCHAR2,
			 x_segment27_low   IN VARCHAR2,
			 x_segment27_high  IN VARCHAR2,
			 x_segment28_low   IN VARCHAR2,
			 x_segment28_high  IN VARCHAR2,
			 x_segment29_low   IN VARCHAR2,
			 x_segment29_high  IN VARCHAR2,
			 x_segment30_low   IN VARCHAR2,
			 x_segment30_high  IN VARCHAR2,
                         row_id            VARCHAR2 ) IS
    CURSOR chk_overlapping IS
      SELECT 'Overlapping'
      FROM   GL_CARRYFORWARD_RANGES
      WHERE  carryforward_range_id = x_carryforward_range_id   	  AND
            (NVL(SEGMENT30_LOW,'X') <= NVL(X_SEGMENT30_HIGH,'X')  AND
            NVL(SEGMENT30_HIGH,'X') >= NVL(X_SEGMENT30_LOW,'X'))  AND
            NVL(SEGMENT29_LOW,'X') <= NVL(X_SEGMENT29_HIGH,'X')  AND
            NVL(SEGMENT29_HIGH,'X') >= NVL(X_SEGMENT29_LOW,'X')	 AND
            NVL(SEGMENT28_LOW,'X') <= NVL(X_SEGMENT28_HIGH,'X')  AND
            NVL(SEGMENT28_HIGH,'X') >= NVL(X_SEGMENT28_LOW,'X')  AND
            NVL(SEGMENT27_LOW,'X') <= NVL(X_SEGMENT27_HIGH,'X')  AND
            NVL(SEGMENT27_HIGH,'X') >= NVL(X_SEGMENT27_LOW,'X')  AND
            NVL(SEGMENT26_LOW,'X') <= NVL(X_SEGMENT26_HIGH,'X')  AND
            NVL(SEGMENT26_HIGH,'X') >= NVL(X_SEGMENT26_LOW,'X')  AND
            NVL(SEGMENT25_LOW,'X') <= NVL(X_SEGMENT25_HIGH,'X')  AND
            NVL(SEGMENT25_HIGH,'X') >= NVL(X_SEGMENT25_LOW,'X')  AND
            NVL(SEGMENT24_LOW,'X') <= NVL(X_SEGMENT24_HIGH,'X')  AND
            NVL(SEGMENT24_HIGH,'X') >= NVL(X_SEGMENT24_LOW,'X')  AND
            NVL(SEGMENT23_LOW,'X') <= NVL(X_SEGMENT23_HIGH,'X')  AND
            NVL(SEGMENT23_HIGH,'X') >= NVL(X_SEGMENT23_LOW,'X')  AND
            NVL(SEGMENT22_LOW,'X') <= NVL(X_SEGMENT22_HIGH,'X')  AND
            NVL(SEGMENT22_HIGH,'X') >= NVL(X_SEGMENT22_LOW,'X')  AND
            NVL(SEGMENT21_LOW,'X') <= NVL(X_SEGMENT21_HIGH,'X')  AND
            NVL(SEGMENT21_HIGH,'X') >= NVL(X_SEGMENT21_LOW,'X')  AND
            NVL(SEGMENT20_LOW,'X') <= NVL(X_SEGMENT20_HIGH,'X')  AND
            NVL(SEGMENT20_HIGH,'X') >= NVL(X_SEGMENT20_LOW,'X')  AND
            NVL(SEGMENT19_LOW,'X') <= NVL(X_SEGMENT19_HIGH,'X')  AND
            NVL(SEGMENT19_HIGH,'X') >= NVL(X_SEGMENT19_LOW,'X')  AND
            NVL(SEGMENT18_LOW,'X') <= NVL(X_SEGMENT18_HIGH,'X')  AND
            NVL(SEGMENT18_HIGH,'X') >= NVL(X_SEGMENT18_LOW,'X')  AND
            NVL(SEGMENT17_LOW,'X') <= NVL(X_SEGMENT17_HIGH,'X')  AND
            NVL(SEGMENT17_HIGH,'X') >= NVL(X_SEGMENT17_LOW,'X')  AND
            NVL(SEGMENT16_LOW,'X') <= NVL(X_SEGMENT16_HIGH,'X')  AND
            NVL(SEGMENT16_HIGH,'X') >= NVL(X_SEGMENT16_LOW,'X')  AND
            NVL(SEGMENT15_LOW,'X') <= NVL(X_SEGMENT15_HIGH,'X')  AND
            NVL(SEGMENT15_HIGH,'X') >= NVL(X_SEGMENT15_LOW,'X')  AND
            NVL(SEGMENT14_LOW,'X') <= NVL(X_SEGMENT14_HIGH,'X')  AND
            NVL(SEGMENT14_HIGH,'X') >= NVL(X_SEGMENT14_LOW,'X')  AND
            NVL(SEGMENT13_LOW,'X') <= NVL(X_SEGMENT13_HIGH,'X')  AND
            NVL(SEGMENT13_HIGH,'X') >= NVL(X_SEGMENT13_LOW,'X')  AND
            NVL(SEGMENT12_LOW,'X') <= NVL(X_SEGMENT12_HIGH,'X')  AND
            NVL(SEGMENT12_HIGH,'X') >= NVL(X_SEGMENT12_LOW,'X')  AND
            NVL(SEGMENT11_LOW,'X') <= NVL(X_SEGMENT11_HIGH,'X')  AND
            NVL(SEGMENT11_HIGH,'X') >= NVL(X_SEGMENT11_LOW,'X')  AND
            NVL(SEGMENT10_LOW,'X') <= NVL(X_SEGMENT10_HIGH,'X')  AND
            NVL(SEGMENT10_HIGH,'X') >= NVL(X_SEGMENT10_LOW,'X')  AND
            NVL(SEGMENT9_LOW,'X') <= NVL(X_SEGMENT9_HIGH,'X')    AND
            NVL(SEGMENT9_HIGH,'X') >= NVL(X_SEGMENT9_LOW,'X')    AND
            NVL(SEGMENT8_LOW,'X') <= NVL(X_SEGMENT8_HIGH,'X')    AND
            NVL(SEGMENT8_HIGH,'X') >= NVL(X_SEGMENT8_LOW,'X')    AND
            NVL(SEGMENT7_LOW,'X') <= NVL(X_SEGMENT7_HIGH,'X')    AND
            NVL(SEGMENT7_HIGH,'X') >= NVL(X_SEGMENT7_LOW,'X')    AND
            NVL(SEGMENT6_LOW,'X') <= NVL(X_SEGMENT6_HIGH,'X')    AND
            NVL(SEGMENT6_HIGH,'X') >= NVL(X_SEGMENT6_LOW,'X')    AND
            NVL(SEGMENT5_LOW,'X') <= NVL(X_SEGMENT5_HIGH,'X')    AND
            NVL(SEGMENT5_HIGH,'X') >= NVL(X_SEGMENT5_LOW,'X')    AND
            NVL(SEGMENT4_LOW,'X') <= NVL(X_SEGMENT4_HIGH,'X')    AND
            NVL(SEGMENT4_HIGH,'X') >= NVL(X_SEGMENT4_LOW,'X')    AND
            NVL(SEGMENT3_LOW,'X') <= NVL(X_SEGMENT3_HIGH,'X')    AND
            NVL(SEGMENT3_HIGH,'X') >= NVL(X_SEGMENT3_LOW,'X')    AND
            NVL(SEGMENT2_LOW,'X') <= NVL(X_SEGMENT2_HIGH,'X')    AND
            NVL(SEGMENT2_HIGH,'X') >= NVL(X_SEGMENT2_LOW,'X')    AND
            NVL(SEGMENT1_LOW,'X') <= NVL(X_SEGMENT1_HIGH,'X')    AND
            NVL(SEGMENT1_HIGH,'X') >= NVL(X_SEGMENT1_LOW,'X')    AND
             (row_id is NULL OR rowid <> row_id );
    dummy VARCHAR2(100);
  BEGIN
    OPEN chk_overlapping;
    FETCH chk_overlapping INTO dummy;

    IF chk_overlapping%FOUND THEN
      CLOSE chk_overlapping;
      fnd_message.set_name('SQLGL', 'GL_DUPLICATE_CARRYFWD_RANGE');
      app_exception.raise_exception;
    END IF;

    CLOSE chk_overlapping;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE', 'GL_CARRYFORWARD_RANGES_PKG.check_overlapping');
      RAISE;
  END check_overlapping;

END GL_CARRYFORWARD_RANGES_PKG;

/
