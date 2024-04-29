--------------------------------------------------------
--  DDL for Package Body GL_FLATTEN_SEG_VAL_HIERARCHIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_FLATTEN_SEG_VAL_HIERARCHIES" AS
/* $Header: gluflshb.pls 120.11.12010000.2 2008/08/04 21:52:54 bsrikant ship $ */


 -- ********************************************************************
-- FUNCTION
--   Flatten_Seg_Val_Hier
-- Purpose
--   This prodcedure  is the entry point for maintaining segment hierarchy
--   in the tables GL_SEG_VAL_NORM_Hierarchy and GL_SEG_VAL_HIERARCHIES
-- History
--   25-04-2001       Srini Pala    Created
-- Arguments
--   Is_Seg_Hier_Changed            Indicates changes in the segment hierarchy
-- Example
--   ret_status := Flatten_Seg_Val_Hier(Is_Seg_Hier_Changed);


  FUNCTION  Flatten_Seg_Val_Hier(Is_Seg_Hier_Changed OUT NOCOPY BOOLEAN)
                                 RETURN    BOOLEAN IS

    l_Seg_Hier_Norm_Changed BOOLEAN := FALSE;
    l_Seg_Hier_Flat_Changed BOOLEAN := FALSE;
    l_no_rows          NUMBER := 0;
    t_record_check_id  NUMBER := 0;
    -- Variable used for 'T'records check

    result             VARCHAR2(8);
    -- Variable used to Call table validated function

    ret_message        VARCHAR2(2000);

    sqlbuf             VARCHAR2(2400);
    add_table          VARCHAR2(240):= NULL;
    column_name        VARCHAR2(240):= NULL;
    l_sql_stmt         NUMBER;
    l_status_flag      VARCHAR2(1);

    GLSTFL_fatal_err   EXCEPTION;

  BEGIN

    GL_MESSAGE.Func_Ent (func_name =>
                       'GL_FLATTEN_SEG_VAL_HIERARCHIES.Flatten_Seg_Val_Hier');

   -- The flow of the Flatten_Seg_Val_Hier routine is as follows
   -- First cleans all records with status 'I'and updates records with
   -- status_code 'D'to NULL in GL_SEG_VAL_HIERARCHIES.
   -- For operartion mode 'SH' call FND_FLEX_HIERARCHY_
   -- COMPILER.Compile_Hierarchy proccedure
   -- Maintain changes in the value set itself by maiantaining mappings for
   -- the parent value 'T' in the GL_SEG_VAL_HIERARCHIES table.
   -- Calls Fix_Norm_Table to maiantain the GL_SEG_VAL_NORM_HIERARCHY table
   -- Calls Fix_Flattened_Table to maiantain the GL_SEG_VAL_HIERARCHIES table.


   -- Clean Norm Table before processing

    IF (GL_FLATTEN_SETUP_DATA.GLSTFL_Debug) THEN
      GL_MESSAGE.Write_Log(msg_name  =>'SHRD0180',
                        token_num => 2,
                        t1        =>'ROUTINE',
                        v1        =>
                       'GL_FLATTEN_SEG_VAL_HIERARCHIES.Flatten_Seg_Val_Hier()',
                        t2        =>'ACTION',
                        v2        =>'Deleting records with status code I '
                                  || 'in the table GL_SEG_VAL_NORM_HIERARCHY');
    END IF;

    -- Delete records with status_code  'I' from GL_SEG_VAL_NORM_HIERARCHY

    -- To improve performance for bug fix # 5075776
    l_status_flag := 'I';

    DELETE
    FROM   GL_SEG_VAL_NORM_HIERARCHY
    WHERE  status_code = l_status_flag
    AND    flex_value_set_id = GL_FLATTEN_SETUP_DATA.GLSTFL_VS_ID;

    l_no_rows  := NVL(SQL%ROWCOUNT,0);
    GL_MESSAGE.Write_Log(msg_name  =>'SHRD0119',
                          token_num =>2,
                          t1        =>'NUM',
                          v1        => TO_CHAR(l_no_rows),
                          t2        =>'TABLE',
                          v2        =>'GL_SEG_VAL_NORM_HIERARCHY');

    IF (GL_FLATTEN_SETUP_DATA.GLSTFL_Debug) THEN
      GL_MESSAGE.Write_Log(msg_name  =>'SHRD0180',
                     token_num => 2,
                     t1        =>'ROUTINE',
                     v1        =>
                    'GL_FLATTEN_SEG_VAL_HIERARCHIES.Flatten_Seg_Val_Hier()',
                     t2        => 'ACTION',
                     v2        =>'Updating records with status code D '
                               ||'to status code NULL in the table'
                               ||' GL_SEG_VAL_NORM_HIERARCHY');
    END IF;

    UPDATE  GL_SEG_VAL_NORM_HIERARCHY
    SET     status_code = NULL
    WHERE   status_code ='D'
    AND     flex_value_set_id = GL_FLATTEN_SETUP_DATA.GLSTFL_VS_ID;

    l_no_rows  := NVL(SQL%ROWCOUNT,0);
    GL_MESSAGE.Write_Log(msg_name  =>'SHRD0118',
                          token_num =>2,
                          t1        =>'NUM',
                          v1        => TO_CHAR(l_no_rows),
                          t2        =>'TABLE',
                          v2        =>'GL_SEG_VAL_NORM_HIERARCHY');


   -- Clean Flattened table before processing

    IF (GL_FLATTEN_SETUP_DATA.GLSTFL_Debug) THEN
      GL_MESSAGE.Write_Log(msg_name  =>'SHRD0180',
                 token_num => 2,
                 t1        =>'ROUTINE',
                 v1        =>
                 'GL_FLATTEN_SEG_VAL_HIERARCHIES.Flatten_Seg_Val_Hier()',
                 t2        =>'ACTION',
                 v2        =>'Deleting records with status code I '
                          || 'in the table GL_SEG_VAL_HIERARCHIES');
    END IF;

    -- Delete records with status_code  'I'
    -- To improve performance for bug fix # 5075776
    l_status_flag := 'I';

    DELETE
    FROM   GL_SEG_VAL_HIERARCHIES
    WHERE  status_code = l_status_flag
    AND    flex_value_set_id = GL_FLATTEN_SETUP_DATA.GLSTFL_VS_ID;

    l_no_rows  := NVL(SQL%ROWCOUNT,0);
    GL_MESSAGE.Write_Log(msg_name  =>'SHRD0119',
                          token_num =>2,
                          t1        =>'NUM',
                          v1        => TO_CHAR(l_no_rows),
                          t2        =>'TABLE',
                          v2        =>'GL_SEG_VAL_HIERARCHIES');

    IF (GL_FLATTEN_SETUP_DATA.GLSTFL_Debug) THEN
      GL_MESSAGE.Write_Log(msg_name  =>'SHRD0180',
                 token_num => 2,
                 t1        =>'ROUTINE',
                 v1        =>
                'GL_FLATTEN_SEG_VAL_HIERARCHIES.Flatten_Seg_Val_Hier()',
                 t2        => 'ACTION',
                 v2        =>'Updating records with status code D '
                           ||'to status code NULL in the table'
                           ||' GL_SEG_VAL_HIERARCHIES');
    END IF;

    UPDATE  GL_SEG_VAL_HIERARCHIES
    SET     status_code = NULL
    WHERE   status_code ='D'
    AND     flex_value_set_id = GL_FLATTEN_SETUP_DATA.GLSTFL_VS_ID;

    l_no_rows  := NVL(SQL%ROWCOUNT,0);
    GL_MESSAGE.Write_Log(msg_name  =>'SHRD0118',
                          token_num =>2,
                          t1        =>'NUM',
                          v1        => TO_CHAR(l_no_rows),
                          t2        =>'TABLE',
                          v2        =>'GL_SEG_VAL_HIERARCHIES');

    FND_CONCURRENT.Af_Commit;    -- COMMIT point  after initial cleaning

    -- Th following block checks for the Value set ie being
    -- used by any chart of accounts or it has an hierarchy.

    BEGIN

      -- The following statement checks the value set is being
      -- used by any chart of accounts or it has an hierarchy.

      SELECT 1
      INTO t_record_check_id
      FROM   DUAL
      WHERE  EXISTS
 	    (SELECT 1
 	     FROM  FND_ID_FLEX_SEGMENTS fifs
 	     WHERE fifs.application_id = 101
             AND   fifs.id_flex_code = 'GL#'
 	     AND   fifs.flex_value_set_id = GL_FLATTEN_SETUP_DATA.GLSTFL_VS_ID)
      OR     EXISTS
 	    (SELECT 1
 	     FROM  FND_FLEX_VALUE_NORM_HIERARCHY ffvnh
 	     WHERE ffvnh.flex_value_set_id = GL_FLATTEN_SETUP_DATA.GLSTFL_VS_ID
             AND   ROWNUM = 1);

    EXCEPTION

      WHEN NO_DATA_FOUND THEN
        t_record_check_id := 0;
    END;

    IF (t_record_check_id = 1) THEN

      -- The follwoing statement updates 'T' records if any segement value
      -- changes from being a parent to a child value and vice versa.
      -- Bug7134519 Added DISTINCT in the sub query to spport Dependent value sets

      UPDATE   GL_SEG_VAL_HIERARCHIES glsvh
      SET      glsvh.status_code  = 'U',
 	       glsvh.summary_flag =
              (SELECT DISTINCT ffv.summary_flag
 	       FROM   FND_FLEX_VALUES ffv
 	       WHERE  ffv.flex_value_set_id =
                          GL_FLATTEN_SETUP_DATA.GLSTFL_VS_ID
 	       AND    ffv.flex_value = glsvh.child_flex_value)
      WHERE    glsvh.flex_value_set_id =
                     GL_FLATTEN_SETUP_DATA.GLSTFL_VS_ID
      AND      glsvh.parent_flex_value = 'T'
      AND      glsvh.child_flex_value IN
 	      (SELECT ffv2.flex_value
 	       FROM  FND_FLEX_VALUES ffv2
 	       WHERE ffv2.flex_value_set_id =
 			  glsvh.flex_value_set_id
 	       AND   ffv2.flex_value = glsvh.child_flex_value
 	       AND   ffv2.summary_flag <> glsvh.summary_flag);

      l_no_rows  := NVL(SQL%ROWCOUNT,0);
      GL_MESSAGE.Write_Log(msg_name  =>'SHRD0118',
                            token_num =>2,
                            t1        =>'NUM',
                            v1        =>TO_CHAR(l_no_rows),
                            t2        =>'TABLE',
                            v2        =>'GL_SEG_VAL_HIERARCHIES');

      -- The following SQL statement insert new 'T' records for the new
      -- segment values added to the value set. The following statement is
      -- for regular value sets.

      INSERT INTO GL_SEG_VAL_HIERARCHIES
            (flex_value_set_id, parent_flex_value, child_flex_value,
             summary_flag, status_code, created_by, creation_date,
             last_updated_by, last_update_login, last_update_date)
            (SELECT DISTINCT ffv.flex_value_set_id, 'T', ffv.flex_value,
                    ffv.summary_flag, 'I',
                    GL_FLATTEN_SETUP_DATA.GLSTFL_User_Id,
                    SYSDATE,  GL_FLATTEN_SETUP_DATA.GLSTFL_User_Id,
                    GL_FLATTEN_SETUP_DATA.GLSTFL_Login_Id,
                    SYSDATE
             FROM   FND_FLEX_VALUES  ffv
             WHERE  ffv.flex_value_set_id = GL_FLATTEN_SETUP_DATA.GLSTFL_VS_ID
             AND    NOT EXISTS
                   (SELECT 1
                    FROM GL_SEG_VAL_HIERARCHIES glsvh
                    WHERE glsvh.flex_value_set_id =
                                ffv.flex_value_set_id
                    AND   glsvh.parent_flex_value = 'T'
                    AND   glsvh.child_flex_value  = ffv.flex_value
                    AND   glsvh.summary_flag      = ffv.summary_flag));

      IF (SQL%FOUND) THEN
        Is_Seg_Hier_Changed := TRUE;
      END IF;

      l_no_rows   := NVL(SQL%ROWCOUNT,0);
      GL_MESSAGE.Write_Log(msg_name  =>'SHRD0117',
                            token_num =>2,
                            t1        =>'NUM',
                            v1        =>TO_CHAR(l_no_rows),
                            t2        =>'TABLE',
                            v2        =>'GL_SEG_VAL_HIERARCHIES');

       -- Insert 'T'records for table validated value sets.
       -- For any table validated value set the parent values will always be
       -- stored in FND_FLEX_VALUES table. Only the detail values will be
       -- stored in the user defined table. So the above statement takes
       -- care of all parent values and the following DYNAMIC SQL statement
       -- inserts all detail records into GL_SEG_VAL_HIERARCHIES table.

       IF (GL_FLATTEN_SETUP_DATA.GLSTFL_VS_TAB_NAME IS NOT NULL) THEN

         l_no_rows   := 0;
         add_table   := GL_FLATTEN_SETUP_DATA.GLSTFL_VS_TAB_NAME;
         column_name := GL_FLATTEN_SETUP_DATA.GLSTFL_VS_COL_NAME;

         sqlbuf :=   'INSERT INTO GL_SEG_VAL_HIERARCHIES
                         (flex_value_set_id, parent_flex_value,
                          child_flex_value, summary_flag,
                          status_code, created_by,
                          creation_date, last_updated_by,
                          last_update_login, last_update_date)
                          (SELECT DISTINCT :v_id,
                                  ''T'', tv.'||column_name||' ,
                                  ''N'', ''I'',
                                  :user_id,
                                  SYSDATE,  :u_id,
                                  :log_id,
                                  SYSDATE
                          FROM '   ||add_table || ' tv
                          WHERE   NOT EXISTS
                                 (SELECT 1
                                  FROM GL_SEG_VAL_HIERARCHIES glsvh
                                  WHERE glsvh.flex_value_set_id
                                          =  :vs_id
                                  AND   glsvh.parent_flex_value
                                          = ''T''
                                  AND   glsvh.child_flex_value
                                          = tv.'||column_name|| ' ))';

         IF (GL_FLATTEN_SETUP_DATA.GLSTFL_Debug) THEN

            l_sql_stmt := LENGTH(sqlbuf);



            GL_MESSAGE.Write_Log(msg_name  =>'SHRD0181',
                              token_num => 3 ,
                              t1        =>'ROUTINE',
                              v1        =>
                   'GL_FLATTEN_SEG_VAL_HIERARCHIES.Flatten_Seg_Val_Hier()',
                              t2        =>'VARIABLE',
                              v2        =>'Value_Set_Id',
                              t3        =>'VALUE',
                              v3        => GL_FLATTEN_SETUP_DATA.GLSTFL_VS_ID);

            GL_MESSAGE.Write_Log(msg_name  =>'SHRD0181',
                              token_num => 3 ,
                              t1        =>'ROUTINE',
                              v1        =>
                   'GL_FLATTEN_SEG_VAL_HIERARCHIES.Flatten_Seg_Val_Hier()',
                              t2        =>'VARIABLE',
                              v2        =>'Table Name',
                              t3        =>'VALUE',
                              v3        => add_table);

            GL_MESSAGE.Write_Log(msg_name  =>'SHRD0181',
                              token_num => 3 ,
                              t1        =>'ROUTINE',
                              v1        =>
                   'GL_FLATTEN_SEG_VAL_HIERARCHIES.Flatten_Seg_Val_Hier()',
                              t2        =>'VARIABLE',
                              v2        =>'Column Name',
                              t3        =>'VALUE',
                              v3  => GL_FLATTEN_SETUP_DATA.GLSTFL_VS_COL_NAME);

            GL_MESSAGE.Write_Log(msg_name  =>'SHRD0181',
                              token_num => 3 ,
                              t1        =>'ROUTINE',
                              v1        =>
                   'GL_FLATTEN_SEG_VAL_HIERARCHIES.Flatten_Seg_Val_Hier()',
                              t2        =>'VARIABLE',
                              v2        =>'sqlbuf',
                              t3        =>'VALUE',
                              v3        => sqlbuf);

            GL_MESSAGE.Write_Log(msg_name  =>'SHRD0181',
                              token_num => 3 ,
                              t1        =>'ROUTINE',
                              v1        =>
                  'GL_FLATTEN_SEG_VAL_HIERARCHIES.Flatten_Seg_Val_Hier()',
                              t2        =>'VARIABLE',
                              v2        =>'Length of sql_stmt',
                              t3        =>'VALUE',
                              v3        =>l_sql_stmt);

            GL_MESSAGE.Write_Log(msg_name  =>'SHRD0180',
                 token_num => 2,
                 t1        =>'ROUTINE',
                 v1        =>
                'GL_FLATTEN_SEG_VAL_HIERARCHIES.Flatten_Seg_Val_Hier()',
                 t2        => 'ACTION',
                 v2        =>'Inserting ''T'' records for table validated'
                           ||' value set into the table '
                           ||' GL_SEG_VAL_HIERARCHIES');

          END IF;

          EXECUTE IMMEDIATE sqlbuf
          USING   GL_FLATTEN_SETUP_DATA.GLSTFL_VS_ID,
                  GL_FLATTEN_SETUP_DATA.GLSTFL_User_Id,
                  GL_FLATTEN_SETUP_DATA.GLSTFL_User_Id,
                  GL_FLATTEN_SETUP_DATA.GLSTFL_Login_Id,
                  GL_FLATTEN_SETUP_DATA.GLSTFL_VS_ID;

          IF (SQL%FOUND) OR (Is_Seg_Hier_Changed) THEN
             Is_Seg_Hier_Changed := TRUE;
          END IF;


          l_no_rows   := NVL(SQL%ROWCOUNT,0);

          GL_MESSAGE.Write_Log(msg_name  =>'SHRD0117',
                            token_num =>2,
                            t1        =>'NUM',
                            v1        =>TO_CHAR(l_no_rows),
                            t2        =>'TABLE',
                            v2        =>'GL_SEG_VAL_HIERARCHIES');
        END IF;

      FND_CONCURRENT.Af_Commit;   -- COMMIT Point

    END IF; -- 'T' records If control block ends.

    IF (NOT Fix_Norm_Table(Is_Norm_Table_Changed =>
                           l_Seg_Hier_Norm_Changed)) THEN

      RAISE GLSTFL_fatal_err;

    ELSIF (NOT l_Seg_Hier_Norm_Changed) THEN

      GL_MESSAGE.Write_Log(msg_name  =>'FLAT0001',
                 token_num => 1,
                 t1        =>'ROUTINE_NAME',
                 v1        =>
                'GL_FLATTEN_SEG_VAL_HIERARCHIES.Flatten_Seg_Val_Hier()');
    ELSE

      IF (NOT Fix_Flattened_Table (Is_Flattened_Tab_Changed =>
                                   l_Seg_Hier_Flat_Changed )) THEN
        RAISE GLSTFL_fatal_err;

      ELSIF (NOT l_Seg_Hier_Flat_Changed) THEN

        GL_MESSAGE.Write_Log(msg_name  =>'FLAT0001',
                   token_num => 1,
                   t1        =>'ROUTINE_NAME',
                   v1        =>
                  'GL_FLATTEN_SEG_VAL_HIERARCHIES.Flatten_Seg_Val_Hier()');

      ELSE

        -- Return True Only if any changes processed in Flattened table.

        Is_Seg_Hier_Changed := TRUE;

      END IF;  -- Inner Fix_Flattened_table If  Control block ends.

    END IF;   -- Outer Fix_Norm_Table If control statement ends.

    GL_MESSAGE.Func_Succ(func_name =>
              'GL_FLATTEN_SEG_VAL_HIERARCHIES.Flatten_Seg_Val_Hier');

    RETURN TRUE;

  EXCEPTION

    WHEN GLSTFL_fatal_err THEN

      GL_MESSAGE.Write_Log(msg_name  =>'FLAT0002',
                            token_num => 1,
                            t1        =>'ROUTINE_NAME',
                            v1        =>
                 'GL_FLATTEN_SEG_VAL_HIERARCHIES.Flatten_Seg_Val_Hier()');

      GL_MESSAGE.Func_Fail(func_name =>
                'GL_FLATTEN_SEG_VAL_HIERARCHIE.Flatten_Seg_Val_Hier');

      FND_CONCURRENT.Af_Rollback;  -- Rollback Point

      Is_Seg_Hier_Changed := FALSE;

      RETURN FALSE;

    WHEN OTHERS THEN

      GL_MESSAGE.Write_Log(msg_name  =>'SHRD0203',
                 token_num =>2,
                 t1        =>'FUNCTION',
                 v1        =>
                'GL_FLATTEN_SEG_VAL_HIERARCHIE.Flatten_Seg_Val_Hier()',
                 t2        =>'SQLERRMC',
                 v2        => SQLERRM);

      GL_MESSAGE.Func_Fail(func_name =>
                'GL_FLATTEN_SEG_VAL_HIERARCHIES.Flatten_Seg_Val_Hier');

      FND_CONCURRENT.Af_Rollback;  -- Rollback Point

      Is_Seg_Hier_Changed := FALSE;

      RETURN FALSE;

  END Flatten_Seg_Val_Hier;

-- ******************************************************************
-- FUNCTION
--   Fix_Norm_Table
-- Purpose
--   This prodcedure  maintains the table GL_SEG_VAL_NORM_Hierarchy
-- History
--   25-04-2001       Srini Pala    Created
-- Arguments
--   Is_Norm_Table_Changed Indicates changes in Norm Table -values BOOLEAN
-- Example
--   ret_status := Fix_Flattened_Table(Is_Norm_Table_Changed);
--

  FUNCTION Fix_Norm_Table (Is_Norm_Table_Changed OUT NOCOPY BOOLEAN)
                           RETURN BOOLEAN IS

    condition            VARCHAR2(200) ;
    add_table            VARCHAR2(50);
    --sql_stmt             VARCHAR2(2400);
    --l_sql_stmt           VARCHAR2(4);
    l_no_rows            NUMBER :=0;



  BEGIN

    GL_MESSAGE.FUNC_ENT(func_name  =>
              'GL_FLATTEN_SEG_VAL_HIERARCHIES.Fix_Norm_Table');

   -- The following check allows the program to continue processing
   -- even there are no hierarchy changes occur in the case of
   -- inserting a new value into the value set. If the new value is
   -- a parent value then the program should run the FIX_FLATTENED_TABLE
   -- procedure.

    SELECT count(*) INTO l_no_rows
    FROM
    DUAL
    WHERE EXISTS
          (SELECT 1
           FROM   GL_SEG_VAL_HIERARCHIES
           WHERE  status_code = 'I'
           AND    flex_value_set_id =
                     GL_FLATTEN_SETUP_DATA.GLSTFL_VS_ID);

    IF (l_no_rows = 1) THEN
      Is_Norm_Table_Changed := TRUE;
    ELSE
      Is_Norm_Table_Changed := FALSE;
    END IF;

    --Reset the number of rows variable.
    l_no_rows := 0;

    IF (GL_FLATTEN_SETUP_DATA.GLSTFL_Debug) THEN
        GL_MESSAGE.Write_Log(msg_name  =>'SHRD0180',
                              token_num => 2,
                              t1        =>'ROUTINE',
                              v1        =>
                   'GL_FLATTEN_SEG_VAL_HIERARCHIES.Fix_Norm_Table()',
                              t2        =>'ACTION',
                              v2        =>'Mark all outdated parent-child '
                                           ||' segment value mappings'
                                           ||' in the table '
                                           ||' GL_SEG_VAL_NORM_HIERARCHY');
     END IF;

      -- The following SQL statement mark all outdated parent-child segment
      -- value mappings in the table GL_SEG_VAL_NORM_HIERARCHY

      UPDATE GL_SEG_VAL_NORM_HIERARCHY glsvnh
      SET    glsvnh.status_code = 'D'
      WHERE  glsvnh.flex_value_set_id = GL_FLATTEN_SETUP_DATA.GLSTFL_VS_ID
      AND
            (NOT EXISTS
            (SELECT 1
             FROM  FND_FLEX_VALUE_NORM_HIERARCHY ffvnh
             WHERE ffvnh.flex_value_set_id =
                         glsvnh.flex_value_set_id
             AND   ffvnh.range_attribute =
                         DECODE(glsvnh.summary_flag,'Y','P','N','C')
             AND   ffvnh.parent_flex_value =
                         glsvnh.parent_flex_value
             AND   glsvnh.child_flex_value
                          BETWEEN ffvnh.child_flex_value_low
                          AND     ffvnh.child_flex_value_high)
      OR
             EXISTS
            (SELECT 1
             FROM   GL_SEG_VAL_HIERARCHIES glsvh
             WHERE  glsvh.flex_value_set_id =
                        glsvnh.flex_value_set_id
             AND    glsvh.parent_flex_value = 'T'
             AND    glsvh.child_flex_value =
                        glsvnh.child_flex_value
             AND    glsvh.status_code = 'U'
             AND    glsvh.summary_flag <>
                       glsvnh.summary_flag));

      l_no_rows   := NVL(SQL%ROWCOUNT,0);

      IF (l_no_rows > 0) THEN
        Is_Norm_Table_Changed := TRUE;
      END IF;

      GL_MESSAGE.Write_Log(msg_name  =>'SHRD0118',
                            token_num =>2,
                            t1        =>'NUM',
                            v1        =>TO_CHAR(l_no_rows),
                            t2        =>'TABLE',
                            v2        =>'GL_SEG_VAL_NORM_HIERARCHY');


      IF (GL_FLATTEN_SETUP_DATA.GLSTFL_Debug) THEN


        GL_MESSAGE.Write_Log(msg_name  =>'SHRD0181',
                              token_num => 3 ,
                              t1        =>'ROUTINE',
                              v1        =>
                  'GL_FLATTEN_SEG_VAL_HIERARCHIES.Fix_Norm_Table()',
                              t2        =>'VARIABLE',
                              v2        =>'Value_Set_Id',
                              t3        =>'VALUE',
                              v3        =>GL_FLATTEN_SETUP_DATA.GLSTFL_VS_ID);

         GL_MESSAGE.Write_Log(msg_name  =>'SHRD0180',
                              token_num => 2,
                              t1        =>'ROUTINE',
                              v1        =>
                    'GL_FLATTEN_SEG_VAL_HIERARCHIES.Fix_Norm_Table()',
                              t2        => 'ACTION',
                              v2        =>'Insert any new parent-child'
                                        ||' segment value mappings into'
                                        ||' the table'
                                        ||' GL_SEG_VAL_NORM_HIERARCHY');
      END IF;

      -- The following statement inserts all new parent-child
      -- (direct mappings) segment value mappings into the
      -- table GL_SEG_VAL_NORM_HIERARCHY

      INSERT INTO GL_SEG_VAL_NORM_HIERARCHY
                (flex_value_set_id, parent_flex_value, child_flex_value,
                 summary_flag, status_code, created_by, creation_date,
                 last_updated_by, last_update_login, last_update_date)
                (SELECT DISTINCT ffvnh.flex_value_set_id,
                                 ffvnh.parent_flex_value,
                                 glsvh.child_flex_value,
                                 glsvh.summary_flag, 'I',
                                 GL_FLATTEN_SETUP_DATA.GLSTFL_User_Id,
 				 SYSDATE,
                                 GL_FLATTEN_SETUP_DATA.GLSTFL_User_Id,
                                 GL_FLATTEN_SETUP_DATA.GLSTFL_Login_Id,
                                 SYSDATE
                 FROM   FND_FLEX_VALUE_NORM_HIERARCHY ffvnh,
                        GL_SEG_VAL_HIERARCHIES glsvh
                 WHERE ffvnh.flex_value_set_id =
                            GL_FLATTEN_SETUP_DATA.GLSTFL_VS_ID
                 AND     glsvh.flex_value_set_id = ffvnh.flex_value_set_id
                 AND     glsvh.parent_flex_value = 'T'
                 AND     glsvh.summary_flag =
                         DECODE(ffvnh.range_attribute,
                                    'P','Y', 'C','N')
                 AND     glsvh.child_flex_value
                               BETWEEN ffvnh.child_flex_value_low
                               AND   ffvnh.child_flex_value_high
                 AND     glsvh.child_flex_value <> 'T'
                 AND   NOT EXISTS
                       (SELECT 1
                        FROM GL_SEG_VAL_NORM_HIERARCHY glsvnh2
                        WHERE glsvnh2.flex_value_set_id =
                                      ffvnh.flex_value_set_id
                        AND   glsvnh2.parent_flex_value =
                                      ffvnh.parent_flex_value
                        AND   glsvnh2.child_flex_value =
                                      glsvh.child_flex_value
                        AND   glsvnh2.summary_flag =
                                      DECODE(ffvnh.range_attribute ,
                                                'P','Y', 'C', 'N')));

      l_no_rows   := NVL(SQL%ROWCOUNT,0);

      IF (l_no_rows > 0) THEN
        Is_Norm_Table_Changed := TRUE;
      END IF;

      GL_MESSAGE.Write_Log(msg_name  =>'SHRD0117',
                            token_num => 2,
                            t1        =>'NUM',
                            v1        => TO_CHAR(l_no_rows),
                            t2        => 'TABLE',
                            v2        => 'GL_SEG_VAL_NORM_HIERARCHY');

    GL_MESSAGE.Func_Succ(func_name =>
               'GL_FLATTEN_SEG_VAL_HIERARCHIES.Fix_Norm_Table');

    FND_CONCURRENT.Af_Commit;  --COMMIT point

    RETURN TRUE;

  EXCEPTION

    WHEN OTHERS THEN

      GL_MESSAGE.Write_Log (msg_name  =>'SHRD0102',
                             token_num => 1,
                             t1        =>'EMESSAGE',
                             v1        => SQLERRM);

      GL_MESSAGE.Func_Fail(func_name =>
                 'GL_FLATTEN_SEG_VAL_HIERARCHIES.Fix_Norm_Table');

      FND_CONCURRENT.Af_Rollback;   -- Rollback Point

      RETURN FALSE;

  END Fix_Norm_Table;

-- *****************************************************************

-- FUNCTION
--   Fix_Flattened_Table
-- Purpose
--   The FUNCTION maintains table GL_SEG_VAL_HIERARCHIES
-- History
--   27-04-2001    Srini Pala    Created
-- Arguments
--  Is_Falttened_Tab_Changed     Indicates table change status -values BOOLEAN
-- Example
--   ret_status := Fix_Flattened_Table(Is_Falttened_Tab_Changed);
--

  FUNCTION Fix_Flattened_Table(Is_Flattened_Tab_Changed OUT NOCOPY BOOLEAN)
                               RETURN BOOLEAN IS

    c_rows_process             BOOLEAN;

    l_commit_ctr               NUMBER;

    l_no_rows                  NUMBER :=0;

  BEGIN

    GL_MESSAGE.Func_Ent(func_name =>
              'GL_FLATTEN_SEG_VAL_HIERARCHIES.Fix_Flattened_Table');

    Is_Flattened_Tab_Changed := FALSE;

    --  The following SQL statement determine all records in
    --  GL_SEG_VAL_HIERARCHIES that contain the deleted child via the
    --  deleted parent segment value mappings for all mappings marked
    --  for delete in GL_SEG_VAL_NORM_HIERARCHY

    UPDATE GL_SEG_VAL_HIERARCHIES GLSVH
    SET    status_code ='D'
    WHERE  NVL(glsvh.status_code,'X') <>'D'
    AND    (glsvh.flex_value_set_id , glsvh.parent_flex_value,
            glsvh.child_flex_value, glsvh.summary_flag) IN
           (SELECT DISTINCT glsvnh.flex_value_set_id,
                            glsvh1.parent_flex_value,
                            glsvnh.child_flex_value,
                            glsvnh.summary_flag
            FROM    GL_SEG_VAL_NORM_HIERARCHY glsvnh,
                    GL_SEG_VAL_HIERARCHIES glsvh1
            WHERE   glsvnh.flex_value_set_id =
                           GL_FLATTEN_SETUP_DATA.GLSTFL_VS_ID
            AND     glsvnh.status_code ='D'
            AND     glsvh1.flex_value_set_id =
                           glsvnh.flex_value_set_id
            AND     glsvh1.child_flex_value =
                           glsvnh.parent_flex_value
            AND     glsvh1.parent_flex_value <> 'T');

    l_no_rows  := NVL(SQL%ROWCOUNT,0);


    IF (l_no_rows > 0) THEN

     -- Tracks the changes in the table GL_Seg_Val_Hierarchies

     Is_Flattened_Tab_Changed := TRUE;

    END IF;

    IF (GL_FLATTEN_SETUP_DATA.GLSTFL_Debug) THEN
      GL_MESSAGE.Write_Log(msg_name  =>'SHRD0180',
                            token_num =>2,
                            t1        =>'ROUTINE',
                            v1        =>
                'GL_FLATTEN_SEG_VAL_HIERARCHIES.Fix_Flattened_Table()',
                            t2        =>'ACTION',
                            v2        =>'Updating all mapping(s) that'
                                      ||' contain deleted child via'
                                      ||' deleted parent in the'
                                      ||' table GL_SEG_VAL_HIERARCHIES');
    END IF;

    GL_MESSAGE.Write_Log(msg_name  =>'SHRD0118',
                          token_num => 2 ,
                          t1        =>'NUM',
                          v1        => TO_CHAR(l_no_rows),
                          t2        =>'TABLE',
                          v2        => 'GL_SEG_VAL_HIERARCHIES');

    --  The following SQL statement mark all records for delete  that
    --  contain any deleted parent child and its descendants
    --  in GL_SEG_VAL_HIERARCHIES

    IF (GL_FLATTEN_SETUP_DATA.GLSTFL_Debug) THEN
      GL_MESSAGE.Write_Log(msg_name  =>'SHRD0180',
                            token_num =>2,
                            t1        =>'ROUTINE',
                            v1        =>
                'GL_FLATTEN_SEG_VAL_HIERARCHIES.Fix_Flattened_Table()',
                            t2        =>'ACTION',
                            v2        =>'Updating all mapping(s) that'
                                      ||' contain deleted parent child'
                                      ||' and its descendants in the'
                                      ||' table GL_SEG_VAL_HIERARCHIES');
    END IF;

    UPDATE GL_SEG_VAL_HIERARCHIES GLSVH
    SET    status_code ='D'
    WHERE  NVL(glsvh.status_code,'X') <>'D'
    AND   (glsvh.flex_value_set_id , glsvh.parent_flex_value,
           glsvh.child_flex_value, glsvh.summary_flag) IN
          (SELECT DISTINCT glsvnh.flex_value_set_id,
                           glsvh1.parent_flex_value,
                           glsvh2.child_flex_value,
                           glsvh2.summary_flag
           FROM    GL_SEG_VAL_NORM_HIERARCHY glsvnh,
                   GL_SEG_VAL_HIERARCHIES glsvh1,
                   GL_SEG_VAL_HIERARCHIES glsvh2
           WHERE   glsvnh.status_code ='D'
           AND     glsvnh.summary_flag = 'Y'
           AND     glsvnh.flex_value_set_id =
                          GL_FLATTEN_SETUP_DATA.GLSTFL_VS_ID
           AND     glsvh1.flex_value_set_id =
                          glsvnh.flex_value_set_id
           AND     glsvh1.child_flex_value =
                          glsvnh.parent_flex_value
           AND     glsvh1.parent_flex_value <> 'T'
           AND     glsvh2.flex_value_set_id =
                          glsvnh.flex_value_set_id
           AND     glsvh2.parent_flex_value =
                          glsvnh.child_flex_value);

    l_no_rows   := NVL(SQL%ROWCOUNT,0);

    FND_CONCURRENT.Af_Commit;  -- COMMIT Point.

    IF (l_no_rows > 0) THEN

      Is_Flattened_Tab_Changed := TRUE;

    END IF;

    GL_MESSAGE.Write_Log(msg_name  =>'SHRD0118',
                          token_num => 2,
                          t1        =>'NUM',
                          v1        =>TO_CHAR(l_no_rows),
                          t2        =>'TABLE',
                          v2        =>'GL_SEG_VAL_HIERARCHIES');

    --  The following SQL checks and reconnects if the deleted child is
    --  mapped to the parent again through some other paths. It will run
    --  in a loop until no more changes occur.

    IF (GL_FLATTEN_SETUP_DATA.GLSTFL_Debug) THEN

      GL_MESSAGE.Write_Log(msg_name  =>'SHRD0180',
                            token_num =>2,
                            t1        =>'ROUTINE',
                            v1        =>
                'GL_FLATTEN_SEG_VAL_HIERARCHIES.Fix_Flattened_Table()',
                            t2        =>'ACTION',
                            v2        =>'Reconnecting mapping(s) that if '
                                      ||' any deleted child mapped to the'
                                      ||' parent through someother path');

    END IF;

    c_rows_process := FALSE;

    l_no_rows      :=0;

    WHILE NOT c_rows_process

    LOOP

      UPDATE GL_SEG_VAL_HIERARCHIES glsvh1
      SET    glsvh1.status_code = NULL
      WHERE  glsvh1.status_code ='D'
      AND    glsvh1.flex_value_set_id =
                    GL_FLATTEN_SETUP_DATA.GLSTFL_VS_ID
      AND   (EXISTS
            (SELECT 1
             FROM  GL_SEG_VAL_HIERARCHIES glsvh2,
                   GL_SEG_VAL_HIERARCHIES glsvh3
             WHERE glsvh2.flex_value_set_id =
                          glsvh1.flex_value_set_id
             AND   glsvh2.status_code IS NULL
             AND   glsvh2.child_flex_value =
                          glsvh1.child_flex_value
             AND   glsvh3.flex_value_set_id =
                          glsvh2.flex_value_set_id
             AND   glsvh3.status_code is NULL
             AND   glsvh3.parent_flex_value =
                          glsvh1.parent_flex_value
             AND   glsvh3.child_flex_value =
                          glsvh2.parent_flex_value)
      OR    EXISTS

           (SELECT 1
            FROM    GL_SEG_VAL_NORM_HIERARCHY glsvnh
            WHERE   glsvnh.flex_value_set_id = glsvh1.flex_value_set_id
            AND     glsvnh.parent_flex_value = glsvh1.parent_flex_value
            AND     glsvnh.child_flex_value  = glsvh1.child_flex_value
            AND     glsvnh.status_code IS NULL
            AND     glsvnh.summary_flag = glsvh1.summary_flag)) ;

      l_no_rows      := l_no_rows+NVL(SQL%ROWCOUNT,0);

      c_rows_process := SQL%NOTFOUND;

      FND_CONCURRENT.Af_Commit; -- COMMIT point

    END LOOP;

    IF (l_no_rows > 0) THEN
      Is_Flattened_Tab_Changed := TRUE;
    END IF;

    GL_MESSAGE.Write_Log(msg_name  =>'SHRD0118',
                          token_num =>2,
                          t1        =>'NUM',
                          v1        =>TO_CHAR(l_no_rows),
                          t2        =>'TABLE',
                          v2        =>'GL_SEG_VAL_HIERARCHIES');

    --  Insert new self reocrds into GL_SEG_VAL_HIERARCHIES for each
    --  new parent / changing being a child value to a parent value

    IF (GL_FLATTEN_SETUP_DATA.GLSTFL_Debug) THEN
      GL_MESSAGE.Write_Log(msg_name  =>'SHRD0180',
                 token_num =>2,
                 t1        =>'ROUTINE',
                 v1        =>
                 'GL_FLATTEN_SEG_VAL_HIERARCHIES.Fix_Flattened_Table()',
                 t2        =>'ACTION',
                 v2        =>'Inserting Parent segement value'
                           ||' with itself as child into the table'
                           ||' GL_SEG_VAL_HIERARCHIES');
    END IF;

    INSERT INTO GL_SEG_VAL_HIERARCHIES
          (flex_value_set_id, parent_flex_value, child_flex_value,
           summary_flag, status_code, created_by, creation_date,
           last_updated_by, last_update_login, last_update_date)
          (SELECT DISTINCT glsvh.flex_value_set_id, glsvh.child_flex_value,
                           glsvh.child_flex_value, 'Y', 'I',
                           GL_FLATTEN_SETUP_DATA.GLSTFL_User_Id,
                           SYSDATE,
                           GL_FLATTEN_SETUP_DATA.GLSTFL_User_Id,
                           GL_FLATTEN_SETUP_DATA.GLSTFL_Login_Id,
                           SYSDATE
                  FROM     GL_SEG_VAL_HIERARCHIES glsvh
                  WHERE    glsvh.flex_value_set_id =
                                 GL_FLATTEN_SETUP_DATA.GLSTFL_VS_ID
                  AND      glsvh.parent_flex_value = 'T'
                  AND      glsvh.status_code IN ('I','U')
                  AND      glsvh.summary_flag = 'Y'
                  AND 	   NOT EXISTS
                           (SELECT 1
                            FROM GL_SEG_VAL_HIERARCHIES glsvh1
                            WHERE   glsvh1.flex_value_set_id =
                                           glsvh.flex_value_set_id
                            AND     glsvh1.parent_flex_value =
                                           glsvh.child_flex_value
                            AND     glsvh1.child_flex_value =
                                           glsvh.child_flex_value
                            AND     NVL(glsvh1.status_code,'X') <> 'D'
                            AND     glsvh1.summary_flag = 'Y') );

    l_no_rows   := NVL(SQL%ROWCOUNT,0);

    IF (l_no_rows > 0) THEN
      Is_Flattened_Tab_Changed := TRUE;
    END IF;

    GL_MESSAGE.Write_Log(msg_name  =>'SHRD0117',
                          token_num => 2,
                          t1        => 'NUM',
                          v1        => TO_CHAR(l_no_rows),
                          t2        =>'TABLE',
                          v2        => 'GL_SEG_VAL_HIERARCHIES');


    --  The following SQL statement Insert all new detail child mappings

    IF (GL_FLATTEN_SETUP_DATA.GLSTFL_Debug) THEN
      GL_MESSAGE.Write_Log(msg_name  =>'SHRD0180',
                            token_num =>2,
                            t1        =>'ROUTINE',
                            v1        =>
                'GL_FLATTEN_SEG_VAL_HIERARCHIES.Fix_Flattened_Table()',
                            t2        =>'ACTION',
                            v2        =>'Inserting deatail child mapping(s)'
                                      ||' into table GL_SEG_VAL_HIERARCHIES');
    END IF;

    INSERT INTO GL_SEG_VAL_HIERARCHIES
                (flex_value_set_id, parent_flex_value,
                 child_flex_value, summary_flag, status_code,
                 created_by, creation_date, last_updated_by,
                 last_update_login, last_update_date)
                 (SELECT DISTINCT glsvnh.flex_value_set_id,
                                  glsvh.parent_flex_value,
                                  glsvnh.child_flex_value,
                                  glsvnh.summary_flag, 'I',
                                  GL_FLATTEN_SETUP_DATA.GLSTFL_User_Id,
                                  SYSDATE,
                                  GL_FLATTEN_SETUP_DATA.GLSTFL_User_Id,
                                  GL_FLATTEN_SETUP_DATA.GLSTFL_Login_Id,
                                  SYSDATE
                  FROM   GL_SEG_VAL_NORM_HIERARCHY glsvnh,
                         GL_SEG_VAL_HIERARCHIES   glsvh
                  WHERE  glsvnh.flex_value_set_id =
                                GL_FLATTEN_SETUP_DATA.GLSTFL_VS_ID
                  AND    glsvnh.status_code = 'I'
                  AND    glsvnh.summary_flag = 'N'
                  AND    glsvh.flex_value_set_id =
                               glsvnh.flex_value_set_id
                  AND    glsvh.child_flex_value =
                               glsvnh.parent_flex_value
                  AND    NVL(glsvh.status_code, 'X') <> 'D'
                  AND    NOT EXISTS
                           (SELECT 1
                           FROM   GL_SEG_VAL_HIERARCHIES glsvh2
                           WHERE  glsvh2.flex_value_set_id =
                                         glsvnh.flex_value_set_id
                           AND    glsvh2.parent_flex_value =
                                         glsvh.parent_flex_value
                           AND    glsvh2.child_flex_value =
                                         glsvnh.child_flex_value
                           AND    glsvh2.summary_flag =
                                         glsvnh.summary_flag
                           AND    NVL(glsvh2.status_code,'X') <>'D'));

    l_no_rows   := NVL(SQL%ROWCOUNT,0);

    FND_CONCURRENT.Af_Commit;    -- COMMIT point.

    IF (l_no_rows > 0) THEN
      Is_Flattened_Tab_Changed := TRUE;
    END IF;

    GL_MESSAGE.Write_Log(msg_name  =>'SHRD0117',
                          token_num => 2,
                          t1        => 'NUM',
                          v1        => TO_CHAR(l_no_rows),
                          t2        => 'TABLE',
                          v2        => 'GL_SEG_VAL_HIERARCHIES');

    --  The following SQL statement insert all new parent-child mappings
    --  for all levels in the hierarchy into the table GL_SEG_VAL_HIERARCHIES

    IF (GL_FLATTEN_SETUP_DATA.GLSTFL_Debug) THEN
      GL_MESSAGE.Write_Log(msg_name  =>'SHRD0180',
                  token_num =>2,
                  t1        =>'ROUTINE',
                  v1        =>
                 'GL_FLATTEN_SEG_VAL_HIERARCHIES.Fix_Flattened_Table()',
                  t2        =>'ACTION',
                  v2        =>'Inserting Parent child mapping(s)'
                            ||'into table GL_SEG_VAL_HIERARCHIES');
    END IF;

    c_rows_process := FALSE;
    l_no_rows      :=0;

    WHILE NOT c_rows_process
    LOOP
      INSERT INTO GL_SEG_VAL_HIERARCHIES
                 (flex_value_set_id, parent_flex_value,
                  child_flex_value, summary_flag, status_code,
                  created_by, creation_date, last_updated_by,
                  last_update_login, last_update_date)
                 (SELECT DISTINCT  glsvnh.flex_value_set_id,
                                   glsvh1.parent_flex_value,
                                   glsvh2.child_flex_value,
                                   glsvh2.summary_flag, 'I',
                                   GL_FLATTEN_SETUP_DATA.GLSTFL_User_Id,
                                   SYSDATE,
                                   GL_FLATTEN_SETUP_DATA.GLSTFL_User_Id,
                                   GL_FLATTEN_SETUP_DATA.GLSTFL_Login_Id,
                                   SYSDATE
                  FROM      GL_SEG_VAL_NORM_HIERARCHY glsvnh,
                            GL_SEG_VAL_HIERARCHIES   glsvh1,
                            GL_SEG_VAL_HIERARCHIES   glsvh2
                  WHERE     glsvnh.flex_value_set_id =
                                   GL_FLATTEN_SETUP_DATA.GLSTFL_VS_ID
                  AND       glsvnh.status_code = 'I'
                  AND       glsvnh.summary_flag = 'Y'
                  AND       glsvh1.flex_value_set_id =
                                   glsvnh.flex_value_set_id
                  AND       glsvh1.child_flex_value =
                                   glsvnh.parent_flex_value
                  AND       NVL(glsvh1.status_code, 'X') <>'D'
                  AND       glsvh2.flex_value_set_id =
                                   glsvnh.flex_value_set_id
                  AND       glsvh2.parent_flex_value =
                                   glsvnh.child_flex_value
                  AND       NVL(glsvh2.status_code, 'X') <>'D'
                  AND       NOT EXISTS
                               (SELECT 1
                                FROM   GL_SEG_VAL_HIERARCHIES glsvh3
                                WHERE  glsvh3.flex_value_set_id =
                                              glsvnh.flex_value_set_id
                                AND    glsvh3.parent_flex_value =
                                              glsvh1.parent_flex_value
                                AND    glsvh3.child_flex_value =
                                              glsvh2.child_flex_value
                                AND    glsvh3.summary_flag =
                                              glsvh2.summary_flag
                                AND    NVL(glsvh3.status_code,'X') <>'D'));

    l_no_rows     := l_no_rows+NVL(SQL%ROWCOUNT,0);

    -- l_commit_ctr  := l_commit_ctr+NVL(SQL%ROWCOUNT,0);

    c_rows_process := SQL%NOTFOUND;

    FND_CONCURRENT.Af_Commit;     -- COMMIT Point.

    END LOOP;

    IF (l_no_rows > 0) THEN
      Is_Flattened_Tab_Changed := TRUE;
    END IF;

    GL_MESSAGE.Write_Log(msg_name  =>'SHRD0117',
                          token_num => 2,
                          t1        =>'NUM',
                          v1        =>TO_CHAR(l_no_rows),
                          t2        =>'TABLE',
                          v2        => 'GL_SEG_VAL_HIERARCHIES');

    GL_MESSAGE.Func_Succ(func_name =>
              'GL_FLATTEN_SEG_VAL_HIERARCHIES.Fix_Flattend_Table');

    RETURN TRUE;

  EXCEPTION

    WHEN OTHERS THEN
      GL_MESSAGE.Write_Log (msg_name  =>'SHRD0102',
                             token_num => 1,
                             t1        =>'EMESSAGE',
                             v1        => SQLERRM);

      GL_MESSAGE.Func_Fail(func_name =>
                'GL_FLATTEN_SEG_VAL_HIERARCHIES.Fix_Flatten_Table');

      FND_CONCURRENT.Af_Rollback; -- ROLLBACK Ponit

      RETURN FALSE;

  END Fix_Flattened_Table;

-- ******************************************************************

-- Function
--   Clean_Up
-- Purpose
--   This function  is to bring all records to its final state in the tables
--   GL_SEG_VAL_NORM_HIERARCHY  and GL_SEG_VAL_HIERARCHIES
-- History
--   25-04-2001       Srini Pala    Created
-- Arguments

-- Example
--   ret_status := Clean_Up()
--

  FUNCTION  Clean_Up  RETURN BOOLEAN IS
    l_no_rows   NUMBER :=0;
    l_status    VARCHAR2(1);

  BEGIN
    GL_MESSAGE.Func_Ent(func_name =>
              'GL_FLATTEN_SEG_VAL_HIERARCHIES.Clean_Up');

    IF(GL_FLATTEN_SETUP_DATA.GLSTFL_Debug) THEN

    GL_MESSAGE.Write_Log(msg_name  =>'SHRD0181',
                          token_num => 3,
                          t1        => 'ROUTINE',
                          v1        =>
                          'GL_FLATTEN_SEG_VAL_HIERARCHIES.Clean_Up',
                          t2        =>'VARIABLE',
                          v2        => 'Value_Set_Id',
                          t3        => 'VALUE',
                          v3        =>
                          TO_CHAR(GL_FLATTEN_SETUP_DATA.GLSTFL_VS_ID));
    END IF;

    UPDATE  GL_SEG_VAL_NORM_HIERARCHY
    SET     status_code = NULL
    WHERE   status_code = 'I'
    AND     flex_value_set_id = GL_FLATTEN_SETUP_DATA.GLSTFL_VS_ID;

    l_no_rows        := NVL(SQL%ROWCOUNT,0);

    GL_MESSAGE.Write_Log(msg_name  =>'SHRD0118',
                          token_num =>2,
                          t1        =>'NUM',
                          v1        =>TO_CHAR(l_no_rows),
                          t2        =>'TABLE',
                          v2        =>'GL_SEG_VAL_NORM_HIERARCHY');

    UPDATE  GL_SEG_VAL_HIERARCHIES
    SET     status_code = NULL
    WHERE   status_code IN ('I','U')
    AND     flex_value_set_id = GL_FLATTEN_SETUP_DATA.GLSTFL_VS_ID;

    l_no_rows        := NVL(SQL%ROWCOUNT,0);

    GL_MESSAGE.Write_Log(msg_name  =>'SHRD0118',
                          token_num =>2,
                          t1        =>'NUM',
                          v1        =>TO_CHAR(l_no_rows),
                          t2        => 'TABLE',
                          v2        => 'GL_SEG_VAL_HIERARCHIES');

    -- To improve performance for bug fix # 5075776
    l_status := 'D';

    DELETE  FROM  GL_SEG_VAL_NORM_HIERARCHY
    WHERE   status_code = l_status
    AND     flex_value_set_id = GL_FLATTEN_SETUP_DATA.GLSTFL_VS_ID;

    l_no_rows        := NVL(SQL%ROWCOUNT,0);

    GL_MESSAGE.Write_Log(msg_name  =>'SHRD0119',
                          token_num =>2,
                          t1        =>'NUM',
                          v1        =>TO_CHAR(l_no_rows),
                          t2        =>'TABLE',
                          v2        =>'GL_SEG_VAL_NORM_HIERARCHY');

    DELETE FROM  GL_SEG_VAL_HIERARCHIES
    WHERE  status_code= l_status
    AND    flex_value_set_id = GL_FLATTEN_SETUP_DATA.GLSTFL_VS_ID;
    l_no_rows        := NVL(SQL%ROWCOUNT,0);

    GL_MESSAGE.Write_Log(msg_name  =>'SHRD0119',
                          token_num => 2,
                          t1        => 'NUM',
                          v1        => TO_CHAR(l_no_rows),
                          t2        =>'TABLE',
                          v2        => 'GL_SEG_VAL_HIERARCHIES');

    GL_MESSAGE.Func_Succ(func_name =>
              'GL_FLATTEN_SEG_VAL_HIERARCHIES.Clean_Up');

    RETURN TRUE;

  EXCEPTION

    WHEN OTHERS THEN

      GL_MESSAGE.Write_Log(msg_name  =>'SHRD0102',
                            token_num => 1,
                            t1        =>'EMESSAGE',
                            v1        => SQLERRM);

      FND_CONCURRENT.Af_Rollback; -- ROLLBACK point

      GL_MESSAGE.Func_Fail(func_name  =>
                'GL_FLATTEN_SEG_VAL_HIERARCHIES.Clean_Up');

      RETURN FALSE;

  END Clean_Up;


-- ******************************************************************

END GL_FLATTEN_SEG_VAL_HIERARCHIES;

/
