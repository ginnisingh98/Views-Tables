--------------------------------------------------------
--  DDL for Package Body GL_PARENT_SEGMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_PARENT_SEGMENT_PKG" AS
/* $Header: glfcpsgb.pls 120.4.12010000.2 2008/08/13 12:08:27 kmotepal ship $ */

-- Global Variable
g_debug_mode VARCHAR2(1) := 'N';

-- PROCEDURE
--   merge_child_ranges
-- PURPOSE
--   It will merge the child ranges of all parent values stored in
--   GL_REVAL_CHD_RANGES_GT for the passed segment and store the merged
--   child ranges back to GL_REVAL_CHD_RANGES_GT.
-- HISTORY
--   07/29/03          L Poon            Created
-- ARGUMENTS
--   fv_set_id  Flex Value Set ID
--   debug_mode Debug Mode (Y or N)
-- NOTES
--   Before calling this procedure, insert all parent value(s) to be
--   processed to the temporary table GL_REVAL_CHD_RANGES_GT.


PROCEDURE merge_child_ranges(fv_set_id  IN NUMBER,
                             debug_mode IN VARCHAR2) IS

  p_fv_table      FND_FLEX_VALIDATION_TABLES.application_table_name%TYPE;
  p_fv_col        FND_FLEX_VALIDATION_TABLES.value_column_name%TYPE;
  p_fv_type       FND_FLEX_VALUE_SETS.validation_type%TYPE;

  v_CursorID      INTEGER;
  v_CursorSQL     VARCHAR2(300);
  v_detail_value  FND_FLEX_VALUES.flex_value%TYPE;
  v_dummy         INTEGER;

  p_parent_val    GL_REVAL_CHD_RANGES_GT.parent_flex_value%TYPE := NULL;
  p_child_fv_low  GL_REVAL_CHD_RANGES_GT.child_flex_value_low%TYPE := NULL;
  p_child_fv_high GL_REVAL_CHD_RANGES_GT.child_flex_value_high%TYPE := NULL;
  p_rowid         ROWID := NULL;

  p_old_parent_val    GL_REVAL_CHD_RANGES_GT.parent_flex_value%TYPE := NULL;
  p_old_child_fv_low  GL_REVAL_CHD_RANGES_GT.parent_flex_value%TYPE := NULL;
  p_old_child_fv_high GL_REVAL_CHD_RANGES_GT.parent_flex_value%TYPE := NULL;
  p_old_rowid         ROWID := NULL;

  p_rec_count     NUMBER;
  p_min_flex_val  GL_REVAL_CHD_RANGES_GT.parent_flex_value%TYPE;
  p_max_flex_val  GL_REVAL_CHD_RANGES_GT.parent_flex_value%TYPE;

  p_changed_flag  VARCHAR2(1) := 'N';
  p_used_flag     VARCHAR2(1) := 'N';
  p_delete_flag   VARCHAR2(1) := 'N';
  p_summary_flag  VARCHAR2(1) := 'N';


  CURSOR child_range_c (c_fv_set_id IN NUMBER) IS
    SELECT   parent_flex_value
           , child_flex_value_low
           , child_flex_value_high
           , rowid
    FROM GL_REVAL_CHD_RANGES_GT
    WHERE flex_value_set_id = c_fv_set_id
    ORDER BY   parent_flex_value
             , NLSSORT(child_flex_value_low, 'NLS_SORT=BINARY')
             , NLSSORT(child_flex_value_high, 'NLS_SORT=BINARY');

BEGIN

   -- Initialize the variabels
   IF (debug_mode = 'Y' or debug_mode = 'y') THEN
     g_debug_mode := 'Y';
   END IF;

   IF g_debug_mode = 'Y' THEN
     debug_msg('merge_child_ranges',
             'fv_set_id='||to_char(fv_set_id)||' debug_mode='||debug_mode);
   END IF;

   -- Call the get_fv_tagble to get the flex value table name and its
   -- flex value column name for the processed segment
   get_fv_table(fv_set_id, p_fv_table, p_fv_col, p_fv_type);

   -- Build the cursor SQL
   v_CursorSQL := 'SELECT VAL.'||p_fv_col||' detail_value'||' FROM '
                  ||p_fv_table||' VAL' ||' WHERE VAL.'||p_fv_col
                  ||' BETWEEN :low AND :high';

   IF p_fv_type <> 'F' THEN
        v_CursorSQL := v_CursorSQL||' AND VAL.flex_value_set_id='
                    ||to_char(fv_set_id)||' AND VAL.summary_flag= :l_summary_flag';
   END IF;

   v_CursorSQL := v_CursorSQL
                  ||' ORDER BY NLSSORT(detail_value,''NLS_SORT=BINARY'')';

   IF g_debug_mode = 'Y' THEN
     debug_msg('merge_child_ranges', 'Cur SQL='||v_CursorSQL);
     debug_msg('merge_child_ranges', 'Open cursor child_range_c loop');
   END IF;
   -- Open cursor
   OPEN child_range_c (fv_set_id);

   LOOP

     FETCH child_range_c INTO p_parent_val,
                              p_child_fv_low,
                              p_child_fv_high,
                              p_rowid;
     EXIT WHEN child_range_c%NOTFOUND;

     IF g_debug_mode = 'Y' THEN
       debug_msg('merge_child_ranges',
               'p_parent_val='||p_parent_val||' p_child_fv_low='
                ||p_child_fv_low||' p_child_fv_high='||p_child_fv_high);
       debug_msg('merge_child_ranges',
               'p_old_parent_val='||p_old_parent_val
                ||' p_old_child_fv_low='||p_old_child_fv_low
                ||' p_old_child_fv_high='||p_old_child_fv_high);
       debug_msg('merge_child_ranges',
               'p_changed_flag='||p_changed_flag||' p_used_flag='
               ||p_used_flag||' p_delete_flag='||p_delete_flag
               ||' v_detail_value='||v_detail_value);
     END IF;

     IF (p_old_parent_val IS NULL OR p_parent_val <> p_old_parent_val) THEN
       IF g_debug_mode = 'Y' THEN
         debug_msg('merge_child_ranges', 'Initial rec or different parent');
       END IF;
       IF (p_old_child_fv_high IS NOT NULL) THEN

         IF p_changed_flag = 'Y' THEN
           -- Update the old range if it is changed
           UPDATE GL_REVAL_CHD_RANGES_GT
              SET child_flex_value_high = p_old_child_fv_high
            WHERE rowid = p_old_rowid;
         END IF; -- IF p_changed_flag = 'Y' THEN

         -- Close the detail_value cursor
         DBMS_SQL.CLOSE_CURSOR(v_CursorID);

       END IF; -- IF (p_old_child_fv_high IS NOT NULL) THEN

       -- Initialize the variables for the new parent value
       p_used_flag := 'N';
       p_changed_flag := 'N';
       p_delete_flag := 'N';
       v_detail_value := NULL;
       p_summary_flag := 'N';

       -- Call the get_min_max to get the record count, min and max child
       -- flex value for the processed parent value
       get_min_max(fv_set_id,
                   p_parent_val,
                   p_rec_count,
                   p_min_flex_val,
                   p_max_flex_val);

       IF p_rec_count > 0 THEN
         -- Open the cursor for processing
         v_CursorID := DBMS_SQL.OPEN_CURSOR;

         -- Parse the query
         DBMS_SQL.PARSE(v_CursorID, v_CursorSQL, DBMS_SQL.v7);

         -- Bind varibales
         DBMS_SQL.BIND_VARIABLE(v_CursorID, ':low', p_min_flex_val);
         DBMS_SQL.BIND_VARIABLE(v_CursorID, ':high', p_max_flex_val);
         DBMS_SQL.BIND_VARIABLE(v_CursorID, ':l_summary_flag', p_summary_flag);

         -- Define output variable
         DBMS_SQL.DEFINE_COLUMN(v_CursorID, 1, v_detail_value, 150);

         -- Execute the query
         v_Dummy := DBMS_SQL.EXECUTE(v_CursorID);

       ELSE
         IF g_debug_mode = 'Y' THEN
           debug_msg('merge_child_ranges', 'No child ranges are found');
         END IF;

       END IF; -- IF p_rec_count > 0 THEN

       -- Store the new range to the old range
       p_old_parent_val := p_parent_val;
       p_old_child_fv_low := p_child_fv_low;
       p_old_child_fv_high := p_child_fv_high;
       p_old_rowid := p_rowid;

     ELSE

       IF p_delete_flag = 'Y' THEN
         IF g_debug_mode = 'Y' THEN
           debug_msg('merge_child_ranges', 'Delete new range as no more detail val');
         END IF;
         -- Delete all remaining ranges with the same parent value when
         -- the delete flag is set to Y because of no more detail values
         DELETE FROM GL_REVAL_CHD_RANGES_GT
         WHERE rowid = p_rowid;

       ELSE
         -- If the new range overlaps with the old range, merge them
         IF (p_old_child_fv_high >= p_child_fv_low) THEN
           IF g_debug_mode = 'Y' THEN
             debug_msg('merge_child_ranges', 'Merge the ranges as they overlap');
           END IF;

           IF (p_child_fv_high > p_old_child_fv_high) THEN
             -- Set the old range high to new range high and set the
             -- p_changed_flag to Y to indicate the old range has been changed
             p_old_child_fv_high := p_child_fv_high;
             p_changed_flag := 'Y';

           END IF; -- IF (p_child_fv_high > p_old_child_fv_high) THEN

           -- Delete the new range since it has merged with the old range
           DELETE FROM GL_REVAL_CHD_RANGES_GT
           WHERE rowid = p_rowid;

         ELSE
           IF g_debug_mode = 'Y' THEN
             debug_msg('merge_child_ranges', 'Two ranges do NOT overlap');
           END IF;

           LOOP -- This is the fetch loop for detail_value
             IF (v_detail_value IS NULL) THEN
               IF g_debug_mode = 'Y' THEN
                 debug_msg('merge_child_ranges', 'Fetch detail value');
               END IF;

               -- Fetch detail value from the cursor if it is NULL
               IF DBMS_SQL.FETCH_ROWS(v_CursorID) = 0 THEN
                 IF g_debug_mode = 'Y' THEN
                   debug_msg('merge_child_ranges', 'No more detail value');
                 END IF;
                 -- No more detail value for this parent value

                 IF (p_changed_flag = 'Y' AND p_used_flag = 'Y') THEN
                   -- Update the table for the changed and used old range
                   UPDATE GL_REVAL_CHD_RANGES_GT
                      SET child_flex_value_high = p_old_child_fv_high
                    WHERE rowid = p_old_rowid;

                 ELSIF (p_used_flag = 'N') THEN
                   -- Delete the old range if it is not used
                   DELETE FROM GL_REVAL_CHD_RANGES_GT
                   WHERE rowid = p_old_rowid;

                 END IF; -- IF (p_changed_flag = 'Y' AND ...

                 -- Delete the new range as there are no more detail value
                 DELETE FROM GL_REVAL_CHD_RANGES_GT
                 WHERE rowid = p_rowid;

                 IF g_debug_mode = 'Y' THEN
                   debug_msg('merge_child_ranges', 'Set p_delete_flag to Y');
                 END IF;
                 -- Set p_delet_flag to Y to indicate to delete all remaining
                 -- child ranges with same parent value
                 p_delete_flag := 'Y';

                 -- Exit the detail_value loop and proceed for the next range
                 EXIT;

               END IF; -- IF DBMS_SQL.FETCH_ROWS(v_CursorID) = 0 THEN

               -- Retrieve the detail value from the cursor
               DBMS_SQL.COLUMN_VALUE(v_CursorID, 1, v_detail_value);

             END IF; -- IF (v_detail_value IS NULL) THEN

             IF (v_detail_value < p_old_child_fv_low) THEN
               IF g_debug_mode = 'Y' THEN
                 debug_msg('merge_child_ranges', 'Detail val < old range');
               END IF;

               -- Set the detail value to NULL in order to fetch next detail
               -- value to process
               v_detail_value := NULL;

             ELSIF (v_detail_value >= p_old_child_fv_low
                    AND v_detail_value <= p_old_child_fv_high) THEN
               IF g_debug_mode = 'Y' THEN
                 debug_msg('merge_child_ranges', 'Detail val IN old range');
               END IF;

               -- The detail value is in the old range, so set it to NULL
               -- in order to fetch next detail value to process and
               -- set used flag to Y
               p_used_flag := 'Y';
               v_detail_value := NULL;

             ELSIF (v_detail_value > p_old_child_fv_high) THEN
               IF g_debug_mode = 'Y' THEN
                 debug_msg('merge_child_ranges', 'Detail value > old range');
               END IF;
               -- The detail value is beyond the old range

               IF (p_changed_flag = 'Y' AND p_used_flag = 'Y') THEN
                 -- Update the table for the changed and used old range
                 UPDATE GL_REVAL_CHD_RANGES_GT
                    SET child_flex_value_high = p_old_child_fv_high
                  WHERE rowid = p_old_rowid;

               ELSIF (p_used_flag = 'N') THEN
                 -- Delete the old range if it is not used
                 DELETE FROM GL_REVAL_CHD_RANGES_GT
                 WHERE rowid = p_old_rowid;

               END IF; -- IF (p_changed_flag = 'Y' AND ...

               -- Reset the variables for the new range
               p_changed_flag := 'N';
               p_used_flag := 'N';

               -- If detail_value is between the new and old range, set it
               -- to NULL in order to fetch next detail value to process.
               -- If it is in or beyond the new range, we still need to
               -- check it for the new range so we should not set
               -- v_detail_value to NULL
               IF (v_detail_value > p_old_child_fv_high
                   AND v_detail_value < p_child_fv_low) THEN
                 IF g_debug_mode = 'Y' THEN
                   debug_msg('merge_child_ranges',
                           'Detail val is between old and new ranges');
                 END IF;

                 v_detail_value := NULL;

               END IF; -- IF (v_detail_value > p_old_child_fv_high ...

               IF g_debug_mode = 'Y' THEN
                 debug_msg('merge_child_ranges', 'Set old range as new range');
               END IF;
               -- Store the new range to the old range
               p_old_parent_val := p_parent_val;
               p_old_child_fv_low := p_child_fv_low;
               p_old_child_fv_high := p_child_fv_high;
               p_old_rowid := p_rowid;

               -- Exit the detail value loop in order to get next range
               EXIT;

             END IF; -- IF (v_detail_value >= p_old_child_fv_low ...
           END LOOP; -- detail_value fetch loop
           IF g_debug_mode = 'Y' THEN
             debug_msg('merge_child_ranges', 'END LOOP for detail val');
           END IF;

         END IF; -- IF (p_old_child_fv_high >= p_child_fv_low) THEN
       END IF; -- IF p_delete_flag = 'Y' THEN
     END IF; -- IF (p_old_parent_val IS NULL ...
   END LOOP; -- child_range_c cursor loop
   IF g_debug_mode = 'Y' THEN
     debug_msg('merge_child_ranges', 'END LOOP for child_range_c');
   END IF;

   IF (p_old_child_fv_high IS NOT NULL) THEN
     IF g_debug_mode = 'Y' THEN
       debug_msg('merge_child_ranges', 'Check the last range');
     END IF;
     IF p_changed_flag = 'Y' THEN
       UPDATE GL_REVAL_CHD_RANGES_GT
          SET child_flex_value_high = p_old_child_fv_high
        WHERE rowid = p_old_rowid;
     END IF; -- IF p_changed_flag = 'Y' THEN

     -- Close the detail_value cursor
     DBMS_SQL.CLOSE_CURSOR(v_CursorID);

   END IF; -- IF (p_old_child_fv_high IS NOT NULL) THEN

   CLOSE child_range_c;

   IF g_debug_mode = 'Y' THEN
     debug_msg('merge_child_ranges', 'Complete successfully');
   END IF;

EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'GL_PARENT_SEGMENT_PKG.MERGE_CHILD_RANGES');
      RAISE_APPLICATION_ERROR(-20150, fnd_message.get||SQLERRM);
END merge_child_ranges;


-- PROCEDURE
--   get_min_max
-- PURPOSE
--   It will get the record count, the minimum and maximum child flex
--   values of the child ranges for the passed segment stored in
--   GL_REVAL_CHD_RANGES_GT.
-- HISTORY
--   07/29/03          L Poon            Created
-- ARGUMENTS
--   fv_set_id  Flex Value Set ID
--   parent_val Parent Flex Value to be processed
--   rec_count  Record Count
--   min_val    Minimum Child Flex Value
--   max_val    Maximum Child Flex Value
-- NOTES
--
PROCEDURE get_min_max(fv_set_id  IN NUMBER,
                      parent_val IN VARCHAR2,
                      rec_count  OUT NOCOPY NUMBER,
                      min_val    OUT NOCOPY VARCHAR2,
                      max_val    OUT NOCOPY VARCHAR2) IS
BEGIN

   IF g_debug_mode = 'Y' THEN
     debug_msg('get_min_max',
             'fv_set_id='||to_char(fv_set_id)||' parent_val='||parent_val);
   END IF;

   BEGIN
     SELECT   count(*)
            , min(child_flex_value_low)
            , max(child_flex_value_high)
       INTO rec_count
            , min_val
            , max_val
       FROM GL_REVAL_CHD_RANGES_GT
      WHERE flex_value_set_id = fv_set_id
        AND parent_flex_value = parent_val;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       rec_count := 0;
       min_val := NULL;
       max_val := NULL;
     WHEN OTHERS THEN
       fnd_message.set_name('SQLGL', 'MRC_TABLE_ERROR');
       fnd_message.set_token('MODULE', 'GL_PARENT_SEGMENT_PKG.GET_MIN_MAX');
       fnd_message.set_token('TABLE', 'GL_REVAL_CHD_RANGES_GT');
       RAISE_APPLICATION_ERROR(-20160, fnd_message.get||SQLERRM);
   END;

   IF g_debug_mode = 'Y' THEN
     debug_msg('get_min_max',
             'rec_count='||to_char(rec_count)||' min_val='||min_val
              ||' max_val='||max_val);
   END IF;

EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE', 'GL_PARENT_SEGMENT_PKG.GET_MIN_MAX');
      RAISE_APPLICATION_ERROR(-20200, fnd_message.get||SQLERRM);
END get_min_max;


-- PROCEDURE
--   get_fv_table
-- PURPOSE
--   It will get the name of the table which contains the flex values for
--   the passed segment.
-- HISTORY
--   07/29/03          L Poon            Created
-- ARGUMENTS
--   fv_set_id Flex Value Set ID
--   fv_table  Flex Value Table Name
--   fv_col    Flex Value Column Name
--   fv_type   Flex Value Validation Type
-- NOTES
--
PROCEDURE get_fv_table(fv_set_id IN NUMBER,
                       fv_table  OUT NOCOPY VARCHAR2,
                       fv_col    OUT NOCOPY VARCHAR2,
                       fv_type   OUT NOCOPY VARCHAR2) IS
BEGIN
   IF g_debug_mode = 'Y' THEN
     debug_msg('get_fv_table', 'fv_set_id='||to_char(fv_set_id));
   END IF;

   BEGIN
     SELECT   nvl(fvt.application_table_name, 'FND_FLEX_VALUES')
            , nvl(fvt.value_column_name, 'FLEX_VALUE')
            , fvs.validation_type
       INTO   fv_table
            , fv_col
            , fv_type
       FROM   fnd_flex_validation_tables fvt
            , fnd_flex_value_sets fvs
      WHERE fvs.flex_value_set_id = fv_set_id
        AND fvt.flex_value_set_id(+) = fvs.flex_value_set_id;
   EXCEPTION
     WHEN OTHERS THEN
       fnd_message.set_name('SQLGL', 'MRC_TABLE_ERROR');
       fnd_message.set_token('MODULE', 'GL_PARENT_SEGMENT_PKG.GET_FV_TABLE');
       fnd_message.set_token('TABLE', 'FND_FLEX_VALUE_SETS');
       RAISE_APPLICATION_ERROR(-20210, fnd_message.get||SQLERRM);
   END;

   IF g_debug_mode = 'Y' THEN
     debug_msg('get_fv_table',
             'fv_table='||fv_table||' fv_col='||fv_col||' fv_type='
              ||fv_type);
   END IF;

EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE', 'GL_PARENT_SEGMENT_PKG.GET_FV_TABLE');
      RAISE_APPLICATION_ERROR(-20250, fnd_message.get||SQLERRM);
END get_fv_table;

-- PROCEDURE
--   check_overlapping
-- PURPOSE
--   It will check whether any expanded and merged account ranges
--   in GL_REVAL_EXP_RANGES_GT overlap
-- HISTORY
--   08/29/03          L Poon            Created
-- ARGUMENTS
--   debug_mode     Debug Mode (Y or N)
--   is_overlapping Indicate if any ranges overlap (Y or N)
PROCEDURE check_overlapping(debug_mode     IN  VARCHAR2,
                            is_overlapping OUT NOCOPY VARCHAR2) IS

  CURSOR acct_range_c IS
    SELECT /*+ cardinality(er1 10) */ 1
    FROM GL_REVAL_EXP_RANGES_GT er1
           WHERE EXISTS(
        SELECT /*+ no_unnest index(er2) */ 'Overlapping'
        FROM gl_reval_exp_ranges_gt er2
        WHERE er2.ROWID <> er1.rowid
        AND   NVL(er2.segment30_low, 'X') <= NVL(er1.segment30_high, 'X')
        AND   NVL(er2.segment30_high, 'X') >= NVL(er1.segment30_low, 'X')
        AND   NVL(er2.segment29_low, 'X') <= NVL(er1.segment29_high, 'X')
        AND   NVL(er2.segment29_high, 'X') >= NVL(er1.segment29_low, 'X')
        AND   NVL(er2.segment28_low, 'X') <= NVL(er1.segment28_high, 'X')
        AND   NVL(er2.segment28_high, 'X') >= NVL(er1.segment28_low, 'X')
        AND   NVL(er2.segment27_low, 'X') <= NVL(er1.segment27_high, 'X')
        AND   NVL(er2.segment27_high, 'X') >= NVL(er1.segment27_low, 'X')
        AND   NVL(er2.segment26_low, 'X') <= NVL(er1.segment26_high, 'X')
        AND   NVL(er2.segment26_high, 'X') >= NVL(er1.segment26_low, 'X')
        AND   NVL(er2.segment25_low, 'X') <= NVL(er1.segment25_high, 'X')
        AND   NVL(er2.segment25_high, 'X') >= NVL(er1.segment25_low, 'X')
        AND   NVL(er2.segment24_low, 'X') <= NVL(er1.segment24_high, 'X')
        AND   NVL(er2.segment24_high, 'X') >= NVL(er1.segment24_low, 'X')
        AND   NVL(er2.segment23_low, 'X') <= NVL(er1.segment23_high, 'X')
        AND   NVL(er2.segment23_high, 'X') >= NVL(er1.segment23_low, 'X')
        AND   NVL(er2.segment22_low, 'X') <= NVL(er1.segment22_high, 'X')
        AND   NVL(er2.segment22_high, 'X') >= NVL(er1.segment22_low, 'X')
        AND   NVL(er2.segment21_low, 'X') <= NVL(er1.segment21_high, 'X')
        AND   NVL(er2.segment21_high, 'X') >= NVL(er1.segment21_low, 'X')
        AND   NVL(er2.segment20_low, 'X') <= NVL(er1.segment20_high, 'X')
        AND   NVL(er2.segment20_high, 'X') >= NVL(er1.segment20_low, 'X')
        AND   NVL(er2.segment19_low, 'X') <= NVL(er1.segment19_high, 'X')
        AND   NVL(er2.segment19_high, 'X') >= NVL(er1.segment19_low, 'X')
        AND   NVL(er2.segment18_low, 'X') <= NVL(er1.segment18_low, 'X')
        AND   NVL(er2.segment18_high, 'X') >= NVL(er1.segment18_low, 'X')
        AND   NVL(er2.segment17_low, 'X') <= NVL(er1.segment17_high, 'X')
        AND   NVL(er2.segment17_high, 'X') >= NVL(er1.segment17_low, 'X')
        AND   NVL(er2.segment16_low, 'X') <= NVL(er1.segment16_high, 'X')
        AND   NVL(er2.segment16_high, 'X') >= NVL(er1.segment16_low, 'X')
        AND   NVL(er2.segment15_low, 'X') <= NVL(er1.segment15_high, 'X')
        AND   NVL(er2.segment15_high, 'X') >= NVL(er1.segment15_low, 'X')
        AND   NVL(er2.segment14_low, 'X') <= NVL(er1.segment14_high, 'X')
        AND   NVL(er2.segment14_high, 'X') >= NVL(er1.segment14_low, 'X')
        AND   NVL(er2.segment13_low, 'X') <= NVL(er1.segment13_high, 'X')
        AND   NVL(er2.segment13_high, 'X') >= NVL(er1.segment13_low, 'X')
        AND   NVL(er2.segment12_low, 'X') <= NVL(er1.segment12_high, 'X')
        AND   NVL(er2.segment12_high, 'X') >= NVL(er1.segment12_low, 'X')
        AND   NVL(er2.segment11_low, 'X') <= NVL(er1.segment11_high, 'X')
        AND   NVL(er2.segment11_high, 'X') >= NVL(er1.segment11_low, 'X')
        AND   NVL(er2.segment10_low, 'X') <= NVL(er1.segment10_high, 'X')
        AND   NVL(er2.segment10_high, 'X') >= NVL(er1.segment10_low, 'X')
        AND   NVL(er2.segment9_low, 'X') <= NVL(er1.segment9_high, 'X')
        AND   NVL(er2.segment9_high, 'X') >= NVL(er1.segment9_low, 'X')
        AND   NVL(er2.segment8_low, 'X') <= NVL(er1.segment8_high, 'X')
        AND   NVL(er2.segment8_high, 'X') >= NVL(er1.segment8_low, 'X')
        AND   NVL(er2.segment7_low, 'X') <= NVL(er1.segment7_high, 'X')
        AND   NVL(er2.segment7_high, 'X') >= NVL(er1.segment7_low, 'X')
        AND   NVL(er2.segment6_low, 'X') <= NVL(er1.segment6_high, 'X')
        AND   NVL(er2.segment6_high, 'X') >= NVL(er1.segment6_low, 'X')
        AND   NVL(er2.segment5_low, 'X') <= NVL(er1.segment5_high, 'X')
        AND   NVL(er2.segment5_high, 'X') >= NVL(er1.segment5_low, 'X')
        AND   NVL(er2.segment4_low, 'X') <= NVL(er1.segment4_high, 'X')
        AND   NVL(er2.segment4_high, 'X') >= NVL(er1.segment4_low, 'X')
        AND   NVL(er2.segment3_low, 'X') <= NVL(er1.segment3_high, 'X')
        AND   NVL(er2.segment3_high, 'X') >= NVL(er1.segment3_low, 'X')
        AND   NVL(er2.segment2_low, 'X') <= NVL(er1.segment2_high, 'X')
        AND   NVL(er2.segment2_high, 'X') >= NVL(er1.segment2_low, 'X')
        AND   NVL(er2.segment1_low, 'X') <= NVL(er1.segment1_high, 'X')
        AND   NVL(er2.segment1_high, 'X') >= NVL(er1.segment1_low, 'X'))
        and rownum = 1;

  -- Low segments

  l_rowid      VARCHAR2(100); -- ROW ID
  l_overlap_flag VARCHAR2(100);
BEGIN

   -- Initialize the variabels
   IF (debug_mode = 'Y' or debug_mode = 'y') THEN
     g_debug_mode := 'Y';
   END IF;
   is_overlapping := 'N';

   IF g_debug_mode = 'Y' THEN
     debug_msg('check_overlapping', 'debug_mode='||debug_mode);
     debug_msg('check_overlapping', 'Open cursor - acct_range_c');
   END IF;

   -- Open cursor
   OPEN acct_range_c;

   FETCH acct_range_c INTO l_overlap_flag;

   IF acct_range_c%FOUND THEN
      is_overlapping := 'Y';
   END IF;
   CLOSE acct_range_c;

   IF (is_overlapping = 'Y')
     THEN
       IF g_debug_mode = 'Y' THEN
         debug_msg('check_overlapping',
                 ' => Return as this range overlaps with other ranges');
       END IF;

       RETURN;
   END IF;

   IF g_debug_mode = 'Y' THEN
     debug_msg('check_overlapping', 'Finish checking all the ranges');
   END IF;

EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE', 'GL_PARENT_SEGMENT_PKG.CHECK_OVERLAPPING');
      RAISE_APPLICATION_ERROR(-20300, fnd_message.get||SQLERRM);
END check_overlapping;

-- PROCEDURE
--   debug_msg
-- PURPOSE
--   It will print the debug message
-- HISTORY
--   07/29/03          L Poon            Created
-- ARGUMENTS
--   name Procedure/Function name
--   msg  Debug Message
PROCEDURE debug_msg(name IN VARCHAR2,
                    msg  IN VARCHAR2) IS
BEGIN

  IF g_debug_mode = 'Y' THEN
--    DBMS_OUTPUT.PUT_LINE(name||'():'||msg);
    NULL;
  END IF;

EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE', 'GL_PARENT_SEGMENT_PKG.DEBUG_MSG');
      RAISE_APPLICATION_ERROR(-20350, fnd_message.get||SQLERRM);
END debug_msg;

END GL_PARENT_SEGMENT_PKG;

/
