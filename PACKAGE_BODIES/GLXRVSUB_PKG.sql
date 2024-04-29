--------------------------------------------------------
--  DDL for Package Body GLXRVSUB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GLXRVSUB_PKG" AS
/* $Header: glfcrrvb.pls 120.7 2006/03/02 19:40:44 ticheng ship $ */

/* ------------------------------------------------------------------------- */

  FUNCTION get_unique_id
     RETURN NUMBER IS
    CURSOR get_new_id IS
      SELECT gl_revaluations_s.NEXTVAL
        FROM DUAL;

    new_id                        NUMBER;
  BEGIN
    OPEN get_new_id;
    FETCH get_new_id INTO new_id;

    IF get_new_id%FOUND THEN
      CLOSE get_new_id;
      RETURN (new_id);
    ELSE
      CLOSE get_new_id;
      fnd_message.set_name('SQLGL', 'GL_ERROR_GETTING_UNIQUE_ID');
      fnd_message.set_token('SEQUENCE', 'GL_REVALUATIONS_S');
      app_exception.raise_exception;
    END IF;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE', 'GLXRVSUB_PKG.get_unique_id');
      RAISE;
  END get_unique_id;

/* ------------------------------------------------------------------------- */

  FUNCTION get_segment_num(
      coa_id    IN   VARCHAR2,
      segment   IN   VARCHAR2)
      RETURN NUMBER IS
    l_application_column_name     VARCHAR2(30);
    l_seg_num                     NUMBER;

    /* Defined the cursor seg_cursor to fix bug 2981493 */
    CURSOR seg_cursor (l_coa_id fnd_segment_attribute_values.id_flex_num%type,
                       l_segment fnd_segment_attribute_values.segment_attribute_type%type) IS
      SELECT segment_num
      FROM fnd_segment_attribute_values fsav, fnd_id_flex_segments fifs
      WHERE fsav.application_id = 101
        AND fsav.id_flex_code = 'GL#'
        AND fsav.id_flex_num = l_coa_id
        AND fsav.segment_attribute_type = l_segment
        AND fsav.attribute_value = 'Y'
        AND fsav.application_id = fifs.application_id
        AND fsav.id_flex_code = fifs.id_flex_code
        AND fsav.id_flex_num = fifs.id_flex_num
        AND fsav.application_column_name = fifs.application_column_name;

  BEGIN
    OPEN seg_cursor (coa_id , SEGMENT) ;
    FETCH seg_cursor into l_seg_num;
    CLOSE seg_cursor;

    RETURN l_seg_num;
  END get_segment_num;

/* ------------------------------------------------------------------------- */

  FUNCTION is_summary_account(
      coa_id         IN   VARCHAR2,
      segment_name   IN   VARCHAR2,
      account_num    IN   VARCHAR2)
      RETURN BOOLEAN IS
    l_coa_id                      NUMBER(15);
    l_segment_name                VARCHAR2(30);
    l_flex_value_set_id           NUMBER(10);
    l_application_column_name     VARCHAR2(30);
    p_table                       VARCHAR2(240);
    p_col                         VARCHAR2(240);
    l_summary_flag                VARCHAR2(1);
  BEGIN
    l_coa_id := TO_NUMBER(coa_id);
    l_segment_name := segment_name;

    BEGIN
      SELECT flex_value_set_id
        INTO l_flex_value_set_id
        FROM fnd_id_flex_segments
       WHERE application_id = 101
         AND id_flex_code = 'GL#'
         AND id_flex_num = l_coa_id
         AND application_column_name = l_segment_name;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN FALSE;
    END;

    BEGIN
      SELECT NVL(fvt.application_table_name, 'FND_FLEX_VALUES'),
             NVL(fvt.summary_column_name, 'SUMMARY_FLAG')
        INTO p_table,
             p_col
        FROM fnd_flex_validation_tables fvt, fnd_flex_value_sets fvs
       WHERE fvs.flex_value_set_id = l_flex_value_set_id
         AND fvt.flex_value_set_id(+) = fvs.flex_value_set_id;
    EXCEPTION
      WHEN OTHERS THEN
        p_table := 'FND_FLEX_VALUES';
        p_col := 'SUMMARY_FLAG';
    END;

    IF ((p_table = 'FND_FLEX_VALUES') AND (p_col = 'SUMMARY_FLAG')) THEN
       BEGIN
         SELECT summary_flag
           INTO l_summary_flag
           FROM fnd_flex_values
          WHERE flex_value_set_id = l_flex_value_set_id
            AND flex_value = account_num;
       EXCEPTION
         WHEN OTHERS THEN
           l_summary_flag := 'N';
       END;
    ELSE
      DECLARE
        stmt VARCHAR2(200);
      BEGIN
        stmt := 'SELECT ' || p_col ||
                ' FROM ' || p_table ||
                ' WHERE flex_value_set_id = :flex_vs_id ' ||
                ' AND flex_value = :flex_val';

        EXECUTE IMMEDIATE stmt INTO l_summary_flag
                               USING l_flex_value_set_id, account_num;
      EXCEPTION
        WHEN OTHERS THEN
          l_summary_flag := 'N';
      END;
    END IF;

    IF (l_summary_flag = 'Y') THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  END is_summary_account;

/* ------------------------------------------------------------------------- */

  FUNCTION has_overlapping(
      x_revaluation_id   NUMBER,
      x_row_id           VARCHAR2,
      x_segment1_low     VARCHAR2,
      x_segment1_high    VARCHAR2,
      x_segment2_low     VARCHAR2,
      x_segment2_high    VARCHAR2,
      x_segment3_low     VARCHAR2,
      x_segment3_high    VARCHAR2,
      x_segment4_low     VARCHAR2,
      x_segment4_high    VARCHAR2,
      x_segment5_low     VARCHAR2,
      x_segment5_high    VARCHAR2,
      x_segment6_low     VARCHAR2,
      x_segment6_high    VARCHAR2,
      x_segment7_low     VARCHAR2,
      x_segment7_high    VARCHAR2,
      x_segment8_low     VARCHAR2,
      x_segment8_high    VARCHAR2,
      x_segment9_low     VARCHAR2,
      x_segment9_high    VARCHAR2,
      x_segment10_low    VARCHAR2,
      x_segment10_high   VARCHAR2,
      x_segment11_low    VARCHAR2,
      x_segment11_high   VARCHAR2,
      x_segment12_low    VARCHAR2,
      x_segment12_high   VARCHAR2,
      x_segment13_low    VARCHAR2,
      x_segment13_high   VARCHAR2,
      x_segment14_low    VARCHAR2,
      x_segment14_high   VARCHAR2,
      x_segment15_low    VARCHAR2,
      x_segment15_high   VARCHAR2,
      x_segment16_low    VARCHAR2,
      x_segment16_high   VARCHAR2,
      x_segment17_low    VARCHAR2,
      x_segment17_high   VARCHAR2,
      x_segment18_low    VARCHAR2,
      x_segment18_high   VARCHAR2,
      x_segment19_low    VARCHAR2,
      x_segment19_high   VARCHAR2,
      x_segment20_low    VARCHAR2,
      x_segment20_high   VARCHAR2,
      x_segment21_low    VARCHAR2,
      x_segment21_high   VARCHAR2,
      x_segment22_low    VARCHAR2,
      x_segment22_high   VARCHAR2,
      x_segment23_low    VARCHAR2,
      x_segment23_high   VARCHAR2,
      x_segment24_low    VARCHAR2,
      x_segment24_high   VARCHAR2,
      x_segment25_low    VARCHAR2,
      x_segment25_high   VARCHAR2,
      x_segment26_low    VARCHAR2,
      x_segment26_high   VARCHAR2,
      x_segment27_low    VARCHAR2,
      x_segment27_high   VARCHAR2,
      x_segment28_low    VARCHAR2,
      x_segment28_high   VARCHAR2,
      x_segment29_low    VARCHAR2,
      x_segment29_high   VARCHAR2,
      x_segment30_low    VARCHAR2,
      x_segment30_high   VARCHAR2)
      RETURN BOOLEAN IS
    CURSOR check_overlaps IS
      SELECT 'Overlapping'
        FROM DUAL
       WHERE EXISTS( SELECT 'X'
                       FROM gl_reval_account_ranges
                      WHERE revaluation_id = x_revaluation_id
                        AND (   x_row_id IS NULL
                             OR x_row_id <> ROWID)
                        AND NVL(segment30_low, 'X') <=
                                                  NVL(x_segment30_high, 'X')
                        AND NVL(segment30_high, 'X') >=
                                                   NVL(x_segment30_low, 'X')
                        AND NVL(segment29_low, 'X') <=
                                                  NVL(x_segment29_high, 'X')
                        AND NVL(segment29_high, 'X') >=
                                                   NVL(x_segment29_low, 'X')
                        AND NVL(segment28_low, 'X') <=
                                                  NVL(x_segment28_high, 'X')
                        AND NVL(segment28_high, 'X') >=
                                                   NVL(x_segment28_low, 'X')
                        AND NVL(segment27_low, 'X') <=
                                                  NVL(x_segment27_high, 'X')
                        AND NVL(segment27_high, 'X') >=
                                                   NVL(x_segment27_low, 'X')
                        AND NVL(segment26_low, 'X') <=
                                                  NVL(x_segment26_high, 'X')
                        AND NVL(segment26_high, 'X') >=
                                                   NVL(x_segment26_low, 'X')
                        AND NVL(segment25_low, 'X') <=
                                                  NVL(x_segment25_high, 'X')
                        AND NVL(segment25_high, 'X') >=
                                                   NVL(x_segment25_low, 'X')
                        AND NVL(segment24_low, 'X') <=
                                                  NVL(x_segment24_high, 'X')
                        AND NVL(segment24_high, 'X') >=
                                                   NVL(x_segment24_low, 'X')
                        AND NVL(segment23_low, 'X') <=
                                                  NVL(x_segment23_high, 'X')
                        AND NVL(segment23_high, 'X') >=
                                                   NVL(x_segment23_low, 'X')
                        AND NVL(segment22_low, 'X') <=
                                                  NVL(x_segment22_high, 'X')
                        AND NVL(segment22_high, 'X') >=
                                                   NVL(x_segment22_low, 'X')
                        AND NVL(segment21_low, 'X') <=
                                                  NVL(x_segment21_high, 'X')
                        AND NVL(segment21_high, 'X') >=
                                                   NVL(x_segment21_low, 'X')
                        AND NVL(segment20_low, 'X') <=
                                                  NVL(x_segment20_high, 'X')
                        AND NVL(segment20_high, 'X') >=
                                                   NVL(x_segment20_low, 'X')
                        AND NVL(segment19_low, 'X') <=
                                                  NVL(x_segment19_high, 'X')
                        AND NVL(segment19_high, 'X') >=
                                                   NVL(x_segment19_low, 'X')
                        AND NVL(segment18_low, 'X') <=
                                                  NVL(x_segment18_high, 'X')
                        AND NVL(segment18_high, 'X') >=
                                                   NVL(x_segment18_low, 'X')
                        AND NVL(segment17_low, 'X') <=
                                                  NVL(x_segment17_high, 'X')
                        AND NVL(segment17_high, 'X') >=
                                                   NVL(x_segment17_low, 'X')
                        AND NVL(segment16_low, 'X') <=
                                                  NVL(x_segment16_high, 'X')
                        AND NVL(segment16_high, 'X') >=
                                                   NVL(x_segment16_low, 'X')
                        AND NVL(segment15_low, 'X') <=
                                                  NVL(x_segment15_high, 'X')
                        AND NVL(segment15_high, 'X') >=
                                                   NVL(x_segment15_low, 'X')
                        AND NVL(segment14_low, 'X') <=
                                                  NVL(x_segment14_high, 'X')
                        AND NVL(segment14_high, 'X') >=
                                                   NVL(x_segment14_low, 'X')
                        AND NVL(segment13_low, 'X') <=
                                                  NVL(x_segment13_high, 'X')
                        AND NVL(segment13_high, 'X') >=
                                                   NVL(x_segment13_low, 'X')
                        AND NVL(segment12_low, 'X') <=
                                                  NVL(x_segment12_high, 'X')
                        AND NVL(segment12_high, 'X') >=
                                                   NVL(x_segment12_low, 'X')
                        AND NVL(segment11_low, 'X') <=
                                                  NVL(x_segment11_high, 'X')
                        AND NVL(segment11_high, 'X') >=
                                                   NVL(x_segment11_low, 'X')
                        AND NVL(segment10_low, 'X') <=
                                                  NVL(x_segment10_high, 'X')
                        AND NVL(segment10_high, 'X') >=
                                                   NVL(x_segment10_low, 'X')
                        AND NVL(segment9_low, 'X') <=
                                                   NVL(x_segment9_high, 'X')
                        AND NVL(segment9_high, 'X') >=
                                                    NVL(x_segment9_low, 'X')
                        AND NVL(segment8_low, 'X') <=
                                                   NVL(x_segment8_high, 'X')
                        AND NVL(segment8_high, 'X') >=
                                                    NVL(x_segment8_low, 'X')
                        AND NVL(segment7_low, 'X') <=
                                                   NVL(x_segment7_high, 'X')
                        AND NVL(segment7_high, 'X') >=
                                                    NVL(x_segment7_low, 'X')
                        AND NVL(segment6_low, 'X') <=
                                                   NVL(x_segment6_high, 'X')
                        AND NVL(segment6_high, 'X') >=
                                                    NVL(x_segment6_low, 'X')
                        AND NVL(segment5_low, 'X') <=
                                                   NVL(x_segment5_high, 'X')
                        AND NVL(segment5_high, 'X') >=
                                                    NVL(x_segment5_low, 'X')
                        AND NVL(segment4_low, 'X') <=
                                                   NVL(x_segment4_high, 'X')
                        AND NVL(segment4_high, 'X') >=
                                                    NVL(x_segment4_low, 'X')
                        AND NVL(segment3_low, 'X') <=
                                                   NVL(x_segment3_high, 'X')
                        AND NVL(segment3_high, 'X') >=
                                                    NVL(x_segment3_low, 'X')
                        AND NVL(segment2_low, 'X') <=
                                                   NVL(x_segment2_high, 'X')
                        AND NVL(segment2_high, 'X') >=
                                                    NVL(x_segment2_low, 'X')
                        AND NVL(segment1_low, 'X') <=
                                                   NVL(x_segment1_high, 'X')
                        AND NVL(segment1_high, 'X') >=
                                                    NVL(x_segment1_low, 'X'));

    dummy                         VARCHAR2(100);
  BEGIN
    OPEN check_overlaps;
    FETCH check_overlaps INTO dummy;

    IF check_overlaps%FOUND THEN
      CLOSE check_overlaps;
      RETURN TRUE;
    END IF;

    CLOSE check_overlaps;
    RETURN FALSE;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE', 'GLXRVSUB_PKG.check_overlapping');
      RAISE;
  END has_overlapping;

/* ------------------------------------------------------------------------- */

   PROCEDURE raise_exception(
      err_type       NUMBER,
      segment_name   VARCHAR2) IS
      l_err_type                    NUMBER(1);
      l_token                       VARCHAR2(50);
   BEGIN
     l_err_type := err_type;
     l_token := segment_name;

     IF (l_err_type = 1) THEN
       fnd_message.set_name('SQLGL', 'GL_REVAL_SEGMENT_NULL_VALUE');
       fnd_message.set_token('SEG', l_token);
       app_exception.raise_exception;
     ELSIF (l_err_type = 2) THEN
       fnd_message.set_name('SQLGL', 'GL_REVAL_WRONG_RATE');
       app_exception.raise_exception;
     ELSIF (l_err_type = 3) THEN
       fnd_message.set_name('SQLGL', 'GL_REVAL_NO_REVAL_OPTIONS');
       app_exception.raise_exception;
     ELSIF (l_err_type = 4) THEN
       fnd_message.set_name('SQLGL', 'GL_REVAL_DUPLICATE_NAME');
       app_exception.raise_exception;
     ELSIF (l_err_type = 5) THEN
       fnd_message.set_name('SQLGL', 'GL_REVALUE_OVERLAP_RANGE');
       app_exception.raise_exception;
     ELSE
       app_exception.raise_exception;
     END IF;
   END raise_exception;

/* ------------------------------------------------------------------------- */

  FUNCTION name_existed(
     reval_name   VARCHAR2,
     reval_id     NUMBER,
     coa_id       NUMBER)
     RETURN BOOLEAN IS
    dummy                         VARCHAR2(100);

    CURSOR checkname(revaluation_name VARCHAR2, r_id NUMBER, c_id NUMBER) IS
      SELECT NAME
      FROM   gl_revaluations
      WHERE  name = revaluation_name
      AND    chart_of_accounts_id = c_id
      AND    revaluation_id <> r_id;
  BEGIN
    OPEN checkname(reval_name, reval_id, coa_id);
    FETCH checkname INTO dummy;

    IF checkname%FOUND THEN
      CLOSE checkname;
      RETURN TRUE;
    END IF;

    CLOSE checkname;
    RETURN FALSE;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE', 'GLXRVSUB_PKG.name_existed');
      RAISE;
  END name_existed;

/* ------------------------------------------------------------------------- */

  FUNCTION range_found(
      reval_id   NUMBER)
      RETURN BOOLEAN IS
    dummy                         NUMBER(30);
    r_id                          NUMBER(30);

    CURSOR check_range_exist IS
      SELECT revaluation_id
        FROM gl_reval_account_ranges
       WHERE revaluation_id = r_id AND ROWNUM = 1;
  BEGIN
    r_id := reval_id;
    OPEN check_range_exist;
    FETCH check_range_exist INTO dummy;

    IF check_range_exist%FOUND THEN
      CLOSE check_range_exist;
      RETURN TRUE;
    ELSE
      CLOSE check_range_exist;
      RETURN FALSE;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE', 'GLXRVSUB_PKG.no_range_found');
      RAISE;
  END range_found;

END glxrvsub_pkg;

/
