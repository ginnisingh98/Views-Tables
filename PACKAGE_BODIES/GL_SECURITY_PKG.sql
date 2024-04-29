--------------------------------------------------------
--  DDL for Package Body GL_SECURITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_SECURITY_PKG" AS
  /* $Header: gluoaseb.pls 120.21 2007/11/26 10:36:34 dthakker ship $ */

  --
  -- Global variables
  --
  RESPONSIBILITY_ID     FND_RESPONSIBILITY.RESPONSIBILITY_ID%TYPE;
  LDGR_ID               GL_LEDGERS.LEDGER_ID%TYPE;
  ACCESS_ID             GL_ACCESS_SETS.ACCESS_SET_ID%TYPE;
  COA_ID                GL_ACCESS_SETS.CHART_OF_ACCOUNTS_ID%TYPE;
  SECURITY_SEGMENT_CODE GL_ACCESS_SETS.SECURITY_SEGMENT_CODE%TYPE;
  BAL_MGMT_SEG_COL_NAME VARCHAR2(2000);

  -- Added under the bug 4730993
  RESP_APPLICATION_ID   FND_RESPONSIBILITY.APPLICATION_ID%TYPE;

  -- If init() has been executed, the inilialized value is TRUE
  initialized boolean := FALSE;

  -- Cache secured segment column name. If the segment is security enabled
  -- ,the value of the flag is TRUE
  seg1_flag  boolean;
  seg2_flag  boolean;
  seg3_flag  boolean;
  seg4_flag  boolean;
  seg5_flag  boolean;
  seg6_flag  boolean;
  seg7_flag  boolean;
  seg8_flag  boolean;
  seg9_flag  boolean;
  seg10_flag boolean;
  seg11_flag boolean;
  seg12_flag boolean;
  seg13_flag boolean;
  seg14_flag boolean;
  seg15_flag boolean;
  seg16_flag boolean;
  seg17_flag boolean;
  seg18_flag boolean;
  seg19_flag boolean;
  seg20_flag boolean;
  seg21_flag boolean;
  seg22_flag boolean;
  seg23_flag boolean;
  seg24_flag boolean;
  seg25_flag boolean;
  seg26_flag boolean;
  seg27_flag boolean;
  seg28_flag boolean;
  seg29_flag boolean;
  seg30_flag boolean;

  TYPE col_name IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
  seg_col_name col_name;

  --
  -- PRIVATE FUNCTIONS
  --
  PROCEDURE init_global_var IS
    appl_id NUMBER(15);
    resp_id NUMBER(15);
    l_ledger_id  NUMBER(15);
    l_segment_attr_type VARCHAR2(2000);
    l_segment_column    VARCHAR2(2000);
    flag                BOOLEAN := FALSE;
  BEGIN

    -- Cache Global variables
    ACCESS_ID         := fnd_profile.value('GL_ACCESS_SET_ID');
    RESPONSIBILITY_ID := fnd_global.resp_id;
    resp_id           := RESPONSIBILITY_ID;

    -- Added under the bug 4730993
    -- Get application id
    RESP_APPLICATION_ID := fnd_global.resp_appl_id;
    appl_id := RESP_APPLICATION_ID;


   /* Commented under the bug 4730993
    -- Get application id
    SELECT application_id
      into appl_id
      FROM FND_RESPONSIBILITY
     WHERE responsibility_id = resp_id;
   */

    -- The set of books id from the profile option GL_SET_OF_BKS_ID
    -- is stored in the local variable ldgr_id.
    LDGR_ID := to_number(fnd_profile.value_specific('GL_SET_OF_BKS_ID',
                                                    null,
                                                    resp_id,
                                                    appl_id));
    l_ledger_id := LDGR_ID;

    IF ACCESS_ID IS NULL THEN
      BEGIN
        -- Get chart of accounts id based upon Ledger
        SELECT chart_of_accounts_id
          INTO COA_ID
          FROM GL_LEDGERS
         WHERE ledger_id = l_ledger_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RETURN;
      END;
    ELSE
      BEGIN
        -- Get chart of accounts id based upon Access Set
        SELECT chart_of_accounts_id, security_segment_code
          INTO COA_ID, SECURITY_SEGMENT_CODE
          FROM GL_ACCESS_SETS
         WHERE access_set_id = ACCESS_ID;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RETURN;
      END;
    END IF;

    -- Run for GL_BALANCING and GL_MANAGEMENT conditionally
    IF SECURITY_SEGMENT_CODE = 'B' THEN
      l_segment_attr_type := 'GL_BALANCING';
      flag := FND_FLEX_APIS.GET_SEGMENT_COLUMN(X_APPLICATION_ID  => '101',
                                               X_ID_FLEX_CODE    => 'GL#',
                                               X_ID_FLEX_NUM     => COA_ID,
                                               X_SEG_ATTR_TYPE   => l_segment_attr_type,
                                               X_APP_COLUMN_NAME => l_segment_column);
      BAL_MGMT_SEG_COL_NAME  := l_segment_column;

    ELSIF SECURITY_SEGMENT_CODE = 'M' THEN
      l_segment_attr_type := 'GL_MANAGEMENT';
      flag := FND_FLEX_APIS.GET_SEGMENT_COLUMN(X_APPLICATION_ID  => '101',
                                               X_ID_FLEX_CODE    => 'GL#',
                                               X_ID_FLEX_NUM     => COA_ID,
                                               X_SEG_ATTR_TYPE   => l_segment_attr_type,
                                               X_APP_COLUMN_NAME => l_segment_column);
      BAL_MGMT_SEG_COL_NAME  := l_segment_column;

    END IF;

  END init_global_var;

  -- Procedure
  --   init
  -- Purpose
  --   To initialize, populate and update GL_BIS_SEGVAL_INT temporary
  --   table based on segment value security rules.
  --   This procedure is called from the Discoverer's POST_LOGON trigger.
  --
  PROCEDURE init IS
    Pragma AUTONOMOUS_TRANSACTION; -- 6341771 for discoverer issue
    program_name        VARCHAR2(48);
    l_module            v$session.module%TYPE;
    l_gl_bis_disco_flag varchar2(1);
    l_session_id        number;
  BEGIN
    -- Now there is no need to check for the module name for a session
    -- as this procedure is always going to be called from the
    -- Discoverer's POST_LOGON trigger
    -- Populate the Global Temporary Table GL_BIS_SEGVAL_INT
    -- with the security rules

    delete from GL_BIS_SEGVAL_INT; -- 6341771, clean up the existing rows
    init_segval;
    commit; -- 6341771, execute commit in autonomous transaction
  END init;

  -- Procedure
  --   init_segval
  -- Purpose
  --   Initialize, populate and update GL_BIS_SEGVAL_INT temporary
  --   table based on segment value security rules
  --
  PROCEDURE init_segval IS

    CURSOR seg_cur(coa_id number) is
      SELECT sg.application_column_name,
             sg.flex_value_set_id,
             sg.segment_num,
             vs.validation_type
        FROM FND_FLEX_VALUE_SETS vs, FND_ID_FLEX_SEGMENTS sg
       WHERE sg.application_id = 101
         AND sg.id_flex_code = 'GL#'
         AND sg.id_flex_num = coa_id
         AND sg.security_enabled_flag = 'Y'
         AND vs.flex_value_set_id = sg.flex_value_set_id;

    CURSOR rule_cur(resp_id number, v_id number, appl_id number) IS
      SELECT flex_value_rule_id, parent_flex_value_low
        FROM fnd_flex_value_rule_usages
       WHERE application_id = appl_id
         AND responsibility_id = resp_id
         AND flex_value_set_id = v_id;

    CURSOR in_range_cur(rule_id number) IS
      SELECT flex_value_low, flex_value_high
        FROM fnd_flex_value_rule_lines
       WHERE flex_value_rule_id = rule_id
         AND include_exclude_indicator = 'I'
       ORDER BY nlssort(decode(flex_value_low,
                               NULL,
                               '1',
                               '2' || flex_value_low),
                        'NLS_SORT=BINARY'),
                nlssort(decode(flex_value_high,
                               NULL,
                               '3',
                               '2' || flex_value_high),
                        'NLS_SORT=BINARY');

    CURSOR ex_range_cur(rule_id number) IS
      SELECT flex_value_low, flex_value_high
        FROM fnd_flex_value_rule_lines
       WHERE flex_value_rule_id = rule_id
         AND include_exclude_indicator <> 'I'
       ORDER BY nlssort(decode(flex_value_low,
                               NULL,
                               '1',
                               '2' || flex_value_low),
                        'NLS_SORT=BINARY'),
                nlssort(decode(flex_value_high,
                               NULL,
                               '3',
                               '2' || flex_value_high),
                        'NLS_SORT=BINARY');

    resp_id NUMBER(15);
    appl_id NUMBER(15);
    rule_id             NUMBER(15);
    segment_column_name VARCHAR2(20);
    value_set_id        NUMBER(15);
    segnum              NUMBER(3);
    validate_type       VARCHAR2(1);
    del_stmt            VARCHAR2(200);
    sql_stmt            VARCHAR2(5200);
    sql_stmt2           VARCHAR2(1000);
    v_column_name       VARCHAR2(240);
    v_appl_table_name   VARCHAR2(240);
    old_low             VARCHAR2(150);
    old_high            VARCHAR2(150);
    new_low             VARCHAR2(150);
    new_high            VARCHAR2(150);
    parent_segment      VARCHAR2(150);
    allrows             boolean;
    -- sql_stmt is 5200. Reserve 200 for del_stmt, and each extra clause
    -- is mostly 100 (101 for only the first line) max.
    max_line   CONSTANT NUMBER := 50;
    count_line          NUMBER;
    count_stmt          NUMBER;
    first_row           boolean;
    first_rule_range    boolean;
    pname_pos           NUMBER;
    i                   NUMBER;
  BEGIN
    sql_stmt  := NULL;
    sql_stmt2 := NULL;

    -- Initialize all segN_flag
    seg1_flag  := FALSE;
    seg2_flag  := FALSE;
    seg3_flag  := FALSE;
    seg4_flag  := FALSE;
    seg5_flag  := FALSE;
    seg6_flag  := FALSE;
    seg7_flag  := FALSE;
    seg8_flag  := FALSE;
    seg9_flag  := FALSE;
    seg10_flag := FALSE;
    seg11_flag := FALSE;
    seg12_flag := FALSE;
    seg13_flag := FALSE;
    seg14_flag := FALSE;
    seg15_flag := FALSE;
    seg16_flag := FALSE;
    seg17_flag := FALSE;
    seg18_flag := FALSE;
    seg19_flag := FALSE;
    seg20_flag := FALSE;
    seg21_flag := FALSE;
    seg22_flag := FALSE;
    seg23_flag := FALSE;
    seg24_flag := FALSE;
    seg25_flag := FALSE;
    seg26_flag := FALSE;
    seg27_flag := FALSE;
    seg28_flag := FALSE;
    seg29_flag := FALSE;
    seg30_flag := FALSE;

    -- Initialize table seg_col_name
    FOR i in 1 .. 30 LOOP
      seg_col_name(i) := NULL;
    END LOOP;

    -- Initialize package variables
      -- RESPONSIBILITY_ID,
      -- RESP_APPLICATION_ID,
      -- ACCESS_ID,
      -- LDGR_ID,
      -- COA_ID
      -- SECURITY_SEGMENT_CODE
    init_global_var;

    IF (COA_ID IS NULL) THEN
       RETURN;
    END IF;

    -- Cache Global variables
    resp_id := RESPONSIBILITY_ID;

    -- Get application_id
    -- Modified under bug 4730993
    appl_id := RESP_APPLICATION_ID;

    -- Loop for each security enabled segment
    OPEN seg_cur(coa_id);
    LOOP
       FETCH seg_cur INTO segment_column_name,
                          value_set_id,
                          segnum,
                          validate_type;

      EXIT WHEN seg_cur%NOTFOUND;

      IF validate_type <> 'F' THEN
        -- Not table validated segment
        sql_stmt := 'INSERT INTO GL_BIS_SEGVAL_INT( ' ||
                    'segment_column_name,' ||
                    'segment_value,      ' ||
                    'parent_segment) ' ||
                    'SELECT ''' || segment_column_name || ''',' ||
                    'flex_value, parent_flex_value_low ' ||
                    'FROM FND_FLEX_VALUES ' ||
                    'WHERE flex_value_set_id=' || value_set_id;

      ELSE
        -- Table validated segment
        SELECT value_column_name, application_table_name
        INTO   v_column_name, v_appl_table_name
        FROM   FND_FLEX_VALIDATION_TABLES
        WHERE  flex_value_set_id = value_set_id;

        sql_stmt := 'INSERT INTO GL_BIS_SEGVAL_INT( ' ||
                    'segment_column_name,' ||
                    'segment_value,' ||
                    'parent_segment) ' ||
                    ' SELECT ''' || segment_column_name || ''',' ||
                                    v_column_name || ',' || 'NULL' ||
                    ' FROM ' || v_appl_table_name;

        -- Insert parent segment value for table validated segment
        sql_stmt2 := 'INSERT INTO GL_BIS_SEGVAL_INT( ' ||
                     'segment_column_name,' ||
                     'segment_value,      ' ||
                     'parent_segment) ' ||
                     ' SELECT ''' || segment_column_name || ''',' ||
                                     ' flex_value, NULL' ||
                     ' FROM FND_FLEX_VALUES ' ||
                     ' WHERE flex_value_set_id= ' || value_set_id ||
                     ' AND summary_flag = ''Y'' ';
      END IF;

      IF (sql_stmt IS NOT NULL) THEN
        EXECUTE IMMEDIATE sql_stmt;
      END IF;

      IF ((sql_stmt2 IS NOT NULL) AND (validate_type = 'F')) THEN
        EXECUTE IMMEDIATE sql_stmt2;
      END IF;

      -- Loop for each security rule of the given responsibility and
      -- and value set id

      OPEN rule_cur(resp_id, value_set_id, appl_id);
      LOOP
        FETCH rule_cur INTO rule_id, parent_segment;

        EXIT WHEN rule_cur%NOTFOUND;

        -- Build Dynamic SQL statement to delete segment values that are
        -- not in the include range of the given segment security rule.
        -- The program first figures out the gap between all include
        -- ranges and then deletes segment values in the gap from temporary
        -- table. To find the gap, we store previous range in old_low and
        -- old_high and store current range in new_low and new_high. By
        -- comparing these values, we can obtain the gap between two ranges
        -- and build additionl where clause SQL statements.

        -- Variables initialization
        -- Old_low : Stores the From range value of the previous range in
        --           this security rule.
        -- Old_high: Stores the To  range value of the previous range in
        --           this security rule.
        -- New_low : The From  range value of the current range in this
        --           security rule.
        -- New_high: The To range value of the current range in this
        --           security rule.
        -- First_rule_range: The flag to check if the range is the first
        --                   range of the given security rule
        -- Allrows: If allrows is TRUE, then include every value of this
        --          segment
        -- First_row: The flag to check if the beginning of SQL statement
        --            has been built. If not, the flag is TRUE.
        -- Count_stmt: If count_stmt = 0, we build the Dynamic SQL starting
        --             with 'AND'.If cont_stmt > 0, we build the dynamic SQL
        --             statement starting with 'OR'.
        -- Count_line: Whenever count_line reaches max_line, we execute the
        --             current statement and restart the dynamic SQL.

        old_low          := NULL;
        old_high         := NULL;
        new_low          := NULL;
        new_high         := NULL;
        first_row        := TRUE;
        first_rule_range := TRUE;
        allrows          := FALSE;
        count_line       := 0;
        count_stmt       := 0;

        -- The first part of the delete statement is fixed within the rule
        del_stmt := 'DELETE /*+ index(gl_bis_segval_int gl_bis_segval_int_n1) */ FROM GL_BIS_SEGVAL_INT ' ||
                    'WHERE segment_column_name=''' || segment_column_name || '''';

         -- If the segment is a dependent segment, then add dynamic
         -- SQL statement where clause for the parent segment
        IF (parent_segment IS NOT NULL) THEN
          del_stmt := del_stmt || ' AND parent_segment=''' || parent_segment || '''';
        END IF;


        -- Build Dynamic SQL statement to delete all segment values
        -- not in the include range
        -- Dynamic SQL statement example:
        -- DELETE /*+ index(gl_bis_segval_int gl_bis_segval_int_n1) */
        -- FROM GL_BIS_SEGVAL_INT
        -- WHERE segment_column_name = 'SEGMENT1'
        -- AND   parent_segment = '01'
        -- AND ( segment_value < '100'
        --       OR (segment_value  > '300' AND segment_value < '500')...)
        --

        OPEN in_range_cur(rule_id);
        -- Loop for each include range
        LOOP
          FETCH in_range_cur INTO new_low, new_high;
          EXIT WHEN in_range_cur%NOTFOUND;

          -- IF first_row is TRUE, then build the beginning of Dynamic
          -- SQL statement.

          IF (first_row) THEN
            sql_stmt := del_stmt;
            first_row := FALSE;
          END IF;

          -- Build Where Clause for gaps between include ranges
          -- If both new_low and new_high are NULL, we keep all values
          -- of this segment. We set the allrows flag to TRUE, so no
          -- SQL statement will be executed.
          -- If old_low and old_high are NULL and this range is not the
          -- first rule range of this security rule, there must be NULL
          -- value in both FROM and TO fields somewhere within this security
          -- rule. So we will include every value of this segment,too.

          IF ((new_low IS NULL and new_high IS NULL) OR
             ((old_low IS NULL and old_high IS NULL) AND
             (NOT first_rule_range))) THEN
            -- Include all rows
            allrows := TRUE;
            EXIT;
          ELSE

            -- If this range is the first range in this security rule,
            -- we just store the range into old_low and old_high variables.

            IF (first_rule_range) THEN
              old_low  := new_low;
              old_high := new_high;

              IF (new_low IS NOT NULL) THEN
                -- According to the sort order of rule range, the From
                -- value of the first rule range is the smallest value
                -- if it is not NULL. So we build a where clause
                -- to delete any segment value less then this new_low

                IF (count_stmt <> 0) THEN
                  sql_stmt := sql_stmt || 'OR segment_value < ''' ||
                              new_low || '''';
                ELSE
                  sql_stmt   := sql_stmt || ' AND (segment_value < ''' ||
                                new_low || '''';
                  count_stmt := count_stmt + 1;
                END IF;
                count_line := count_line + 1;
              END IF;
              first_rule_range := FALSE;

            ELSIF (new_low <= old_high OR new_low IS NULL OR
                  old_high IS NULL) THEN
              -- If new_low is less than old_high, there is an overlap between
              -- two include ranges. We then reset the old_high to merge these
              -- two ranges.
              old_high := greatest(old_high, new_high);

            ELSE
              -- If new_low is greater then  old_high, there is a gap
              -- between these two include ranges. The gap is
              -- between new_low and old_high
              IF (count_stmt <> 0) THEN
                sql_stmt := sql_stmt ||
                            ' OR (segment_value > ''' || old_high ||
                            ''' AND segment_value < ''' || new_low || ''')';
              ELSE
                sql_stmt := sql_stmt ||
                            ' AND ((segment_value > ''' || old_high ||
                            ''' AND segment_value < ''' || new_low || ''')';
                count_stmt := count_stmt + 1;
              END IF;
              count_line := count_line + 1;
              old_low  := new_low;
              old_high := new_high;
            END IF;

             -- If we have hit the max number of lines, execute the statement
             -- and reset to start over building the statement
             IF (count_line = max_line) THEN
               IF (count_stmt <> 0) THEN
                 sql_stmt := sql_stmt || ')';
               END IF;

               -- Execute Dynamic SQL statement
               EXECUTE IMMEDIATE sql_stmt;

               -- reset the variables before looping back
               first_row := TRUE;
               count_line := 0;
               count_stmt := 0;
               sql_stmt := NULL;
             END IF;

          END IF;
        END LOOP;

        -- If old_low and old_high are NULL and this range is not the
        -- first rule range of this security rule, there must be NULL
        -- value in both FROM and TO fields within this security rule.
        -- So we will not delete any values for this segment.
        IF (old_low IS NULL AND old_high IS NULL AND (NOT first_rule_range)) THEN
          allrows := TRUE;
        END IF;

        -- If old_high IS NOT NULL, the value is the highest To range in
        -- all include ranges for this security rule. We delete all segment
        -- values which are greater then old_high.

        IF (old_high IS NOT NULL) THEN
          -- If we have just reset the statement with this as the only range
          -- left, then need to re-build the beginning of the dynamic SQL
          IF (sql_stmt IS NULL) THEN
            sql_stmt := del_stmt;
          END IF;

          IF (count_stmt <> 0) THEN
            sql_stmt := sql_stmt || ' OR segment_value > ''' || old_high ||
                        ''' ';
          ELSE
            sql_stmt   := sql_stmt || ' AND ( segment_value > ''' ||
                          old_high || ''' ';
            count_stmt := count_stmt + 1;
          END IF;
        END IF;

        IF (count_stmt <> 0) THEN
          sql_stmt := sql_stmt || ')';
        END IF;

        -- Execute Dynamic SQL statement
        IF ((NOT allrows) AND sql_stmt IS NOT NULL) THEN
          EXECUTE IMMEDIATE sql_stmt;
        END IF;

        CLOSE in_range_cur;

        count_line := 0;
        count_stmt := 0;
        first_row  := TRUE;
        sql_stmt   := NULL;

        -- Build Dynamic SQL statement to delete all segment values
        -- in the exclude range
        -- Dynamic SQL statement example:
        -- DELETE /*+ index(gl_bis_segval_int gl_bis_segval_int_n1) */
        -- FROM GL_BIS_SEGVAL_INT
        -- WHERE segment_column_name = 'SEGMENT1'
        -- AND   parent_segment = '01'
        -- AND ( segment_value < '100'
        --       OR (segment_value >= '300' AND segment_value <= '500')...)
        --

        OPEN ex_range_cur(rule_id);
        -- Loop for each exclude range
        LOOP
          FETCH ex_range_cur INTO new_low, new_high;
          EXIT WHEN ex_range_cur%NOTFOUND;

          -- If first_row is TRUE, we build the beginning Dynamic SQL
          -- statement for exclude ranges

          IF (first_row) THEN
            sql_stmt := del_stmt;
            first_row := FALSE;
          END IF;

          -- If new_low and new_high are both NULL, then we delete
          -- all segment values of this segment
          IF (new_low IS NULL AND new_high IS NULL) THEN
            /* exclude all segments */
            EXIT;

          ELSIF (new_low is NULL AND new_high IS NOT NULL) THEN
            -- If new_low is NULL and new_high IS NOT NULL, we delete segment
            -- values that are less then new_high.
            IF (count_stmt <> 0) THEN
              sql_stmt := sql_stmt || ' OR segment_value <= ''' || new_high ||
                          ''' ';
            ELSE
              sql_stmt   := sql_stmt || ' AND (segment_value <= ''' ||
                            new_high || ''' ';
              count_stmt := count_stmt + 1;
            END IF;
            count_line := count_line + 1;

          ELSIF (new_low IS NOT NULL AND new_high IS NULL) THEN
            -- If new_low IS NOT NULL and new_high is NULL, we delete segment
            -- values that are greater then new_low.
            IF (count_stmt <> 0) THEN
              sql_stmt := sql_stmt || ' OR segment_value >= ''' || new_low ||
                          '''';
            ELSE
              sql_stmt   := sql_stmt || ' AND (segment_value >= ''' ||
                            new_low || '''';
              count_stmt := count_stmt + 1;
            END IF;
            count_line := count_line + 1;

          ELSE
            -- If both new_low and new_high are not NULL, we delete all
            -- segment values between new_low and new_high.
            IF (count_stmt <> 0) THEN
              sql_stmt := sql_stmt ||
                          ' OR (segment_value >= ''' || new_low ||
                          ''' AND segment_value <= ''' || new_high || ''')';
            ELSE
              sql_stmt := sql_stmt ||
                          ' AND ((segment_value >= ''' || new_low ||
                          ''' AND segment_value <= ''' || new_high || ''')';
              count_stmt := count_stmt + 1;
            END IF;
            count_line := count_line + 1;
          END IF;

           -- If we have hit the max number of lines, execute the statement
           -- and reset to start over building the statement
           IF (count_line = max_line) THEN
             IF (count_stmt <> 0) THEN
               sql_stmt := sql_stmt || ')';
             END IF;

             -- Execute Dynamic SQL statement
             EXECUTE IMMEDIATE sql_stmt;

             -- reset the variables before looping back
             first_row := TRUE;
             count_line := 0;
             count_stmt := 0;
             sql_stmt := NULL;
           END IF;

        END LOOP;

        IF (count_stmt <> 0) THEN
          sql_stmt := sql_stmt || ')';
        END IF;

        -- Execute Dynamic SQL statement
        IF (sql_stmt IS NOT NULL) THEN
          EXECUTE IMMEDIATE sql_stmt;
        END IF;
        CLOSE ex_range_cur;

      END LOOP;
      CLOSE rule_cur;

      -- Set the seg_flag for each security enabled segments
      -- and assign value to seg_col_name table

      IF (segment_column_name = 'SEGMENT1') THEN
        seg1_flag := TRUE;
        seg_col_name(segnum) := 'SEGMENT1';
      ELSIF (segment_column_name = 'SEGMENT2') THEN
        seg2_flag := TRUE;
        seg_col_name(segnum) := 'SEGMENT2';
      ELSIF (segment_column_name = 'SEGMENT3') THEN
        seg3_flag := TRUE;
        seg_col_name(segnum) := 'SEGMENT3';
      ELSIF (segment_column_name = 'SEGMENT4') THEN
        seg4_flag := TRUE;
        seg_col_name(segnum) := 'SEGMENT4';
      ELSIF (segment_column_name = 'SEGMENT5') THEN
        seg5_flag := TRUE;
        seg_col_name(segnum) := 'SEGMENT5';
      ELSIF (segment_column_name = 'SEGMENT6') THEN
        seg6_flag := TRUE;
        seg_col_name(segnum) := 'SEGMENT6';
      ELSIF (segment_column_name = 'SEGMENT7') THEN
        seg7_flag := TRUE;
        seg_col_name(segnum) := 'SEGMENT7';
      ELSIF (segment_column_name = 'SEGMENT8') THEN
        seg8_flag := TRUE;
        seg_col_name(segnum) := 'SEGMENT8';
      ELSIF (segment_column_name = 'SEGMENT9') THEN
        seg9_flag := TRUE;
        seg_col_name(segnum) := 'SEGMENT9';
      ELSIF (segment_column_name = 'SEGMENT10') THEN
        seg10_flag := TRUE;
        seg_col_name(segnum) := 'SEGMENT10';
      ELSIF (segment_column_name = 'SEGMENT11') THEN
        seg11_flag := TRUE;
        seg_col_name(segnum) := 'SEGMENT11';
      ELSIF (segment_column_name = 'SEGMENT12') THEN
        seg12_flag := TRUE;
        seg_col_name(segnum) := 'SEGMENT12';
      ELSIF (segment_column_name = 'SEGMENT13') THEN
        seg13_flag := TRUE;
        seg_col_name(segnum) := 'SEGMENT13';
      ELSIF (segment_column_name = 'SEGMENT14') THEN
        seg14_flag := TRUE;
        seg_col_name(segnum) := 'SEGMENT14';
      ELSIF (segment_column_name = 'SEGMENT15') THEN
        seg15_flag := TRUE;
        seg_col_name(segnum) := 'SEGMENT15';
      ELSIF (segment_column_name = 'SEGMENT16') THEN
        seg16_flag := TRUE;
        seg_col_name(segnum) := 'SEGMENT16';
      ELSIF (segment_column_name = 'SEGMENT17') THEN
        seg17_flag := TRUE;
        seg_col_name(segnum) := 'SEGMENT17';
      ELSIF (segment_column_name = 'SEGMENT18') THEN
        seg18_flag := TRUE;
        seg_col_name(segnum) := 'SEGMENT18';
      ELSIF (segment_column_name = 'SEGMENT19') THEN
        seg19_flag := TRUE;
        seg_col_name(segnum) := 'SEGMENT19';
      ELSIF (segment_column_name = 'SEGMENT20') THEN
        seg20_flag := TRUE;
        seg_col_name(segnum) := 'SEGMENT20';
      ELSIF (segment_column_name = 'SEGMENT21') THEN
        seg21_flag := TRUE;
        seg_col_name(segnum) := 'SEGMENT21';
      ELSIF (segment_column_name = 'SEGMENT22') THEN
        seg22_flag := TRUE;
        seg_col_name(segnum) := 'SEGMENT22';
      ELSIF (segment_column_name = 'SEGMENT23') THEN
        seg23_flag := TRUE;
        seg_col_name(segnum) := 'SEGMENT23';
      ELSIF (segment_column_name = 'SEGMENT24') THEN
        seg24_flag := TRUE;
        seg_col_name(segnum) := 'SEGMENT24';
      ELSIF (segment_column_name = 'SEGMENT25') THEN
        seg25_flag := TRUE;
        seg_col_name(segnum) := 'SEGMENT25';
      ELSIF (segment_column_name = 'SEGMENT26') THEN
        seg26_flag := TRUE;
        seg_col_name(segnum) := 'SEGMENT26';
      ELSIF (segment_column_name = 'SEGMENT27') THEN
        seg27_flag := TRUE;
        seg_col_name(segnum) := 'SEGMENT27';
      ELSIF (segment_column_name = 'SEGMENT28') THEN
        seg28_flag := TRUE;
        seg_col_name(segnum) := 'SEGMENT28';
      ELSIF (segment_column_name = 'SEGMENT29') THEN
        seg29_flag := TRUE;
        seg_col_name(segnum) := 'SEGMENT29';
      ELSIF (segment_column_name = 'SEGMENT30') THEN
        seg30_flag := TRUE;
        seg_col_name(segnum) := 'SEGMENT30';
      END IF;
    END LOOP;

    initialized := TRUE;

    CLOSE seg_cur;

  END init_segval;

  -- Function
  --    Validate_access
  -- Purpose
  --    Validate the given code combination id and ledger id
  --    according to the rules stored in GL_BIS_SEGVAL_INT temporary
  --    table by gl_security_pkg.init
  --
  FUNCTION validate_access(p_ledger_id IN NUMBER DEFAULT NULL,
                           ccid   IN NUMBER DEFAULT NULL) RETURN VARCHAR2 IS
    segment1    VARCHAR2(150);
    segment2    VARCHAR2(150);
    segment3    VARCHAR2(150);
    segment4    VARCHAR2(150);
    segment5    VARCHAR2(150);
    segment6    VARCHAR2(150);
    segment7    VARCHAR2(150);
    segment8    VARCHAR2(150);
    segment9    VARCHAR2(150);
    segment10   VARCHAR2(150);
    segment11   VARCHAR2(150);
    segment12   VARCHAR2(150);
    segment13   VARCHAR2(150);
    segment14   VARCHAR2(150);
    segment15   VARCHAR2(150);
    segment16   VARCHAR2(150);
    segment17   VARCHAR2(150);
    segment18   VARCHAR2(150);
    segment19   VARCHAR2(150);
    segment20   VARCHAR2(150);
    segment21   VARCHAR2(150);
    segment22   VARCHAR2(150);
    segment23   VARCHAR2(150);
    segment24   VARCHAR2(150);
    segment25   VARCHAR2(150);
    segment26   VARCHAR2(150);
    segment27   VARCHAR2(150);
    segment28   VARCHAR2(150);
    segment29   VARCHAR2(150);
    segment30   VARCHAR2(150);
    total_count NUMBER;
    l_seg_value VARCHAR2(2000);

    --New private function for R12
    FUNCTION get_seg_value(p_seg_colname VARCHAR2) RETURN VARCHAR2 IS
      l_seg_value VARCHAR2(2000);
    BEGIN
      CASE
        WHEN p_seg_colname = 'SEGMENT1' THEN
          l_seg_value := segment1;
        WHEN p_seg_colname = 'SEGMENT2' THEN
          l_seg_value := segment2;
        WHEN p_seg_colname = 'SEGMENT3' THEN
          l_seg_value := segment3;
        WHEN p_seg_colname = 'SEGMENT4' THEN
          l_seg_value := segment4;
        WHEN p_seg_colname = 'SEGMENT5' THEN
          l_seg_value := segment5;
        WHEN p_seg_colname = 'SEGMENT6' THEN
          l_seg_value := segment6;
        WHEN p_seg_colname = 'SEGMENT7' THEN
          l_seg_value := segment7;
        WHEN p_seg_colname = 'SEGMENT8' THEN
          l_seg_value := segment8;
        WHEN p_seg_colname = 'SEGMENT9' THEN
          l_seg_value := segment9;
        WHEN p_seg_colname = 'SEGMENT10' THEN
          l_seg_value := segment10;
        WHEN p_seg_colname = 'SEGMENT11' THEN
          l_seg_value := segment11;
        WHEN p_seg_colname = 'SEGMENT12' THEN
          l_seg_value := segment12;
        WHEN p_seg_colname = 'SEGMENT13' THEN
          l_seg_value := segment13;
        WHEN p_seg_colname = 'SEGMENT14' THEN
          l_seg_value := segment14;
        WHEN p_seg_colname = 'SEGMENT15' THEN
          l_seg_value := segment15;
        WHEN p_seg_colname = 'SEGMENT16' THEN
          l_seg_value := segment16;
        WHEN p_seg_colname = 'SEGMENT17' THEN
          l_seg_value := segment17;
        WHEN p_seg_colname = 'SEGMENT18' THEN
          l_seg_value := segment18;
        WHEN p_seg_colname = 'SEGMENT19' THEN
          l_seg_value := segment19;
        WHEN p_seg_colname = 'SEGMENT20' THEN
          l_seg_value := segment20;
        WHEN p_seg_colname = 'SEGMENT21' THEN
          l_seg_value := segment21;
        WHEN p_seg_colname = 'SEGMENT22' THEN
          l_seg_value := segment22;
        WHEN p_seg_colname = 'SEGMENT23' THEN
          l_seg_value := segment23;
        WHEN p_seg_colname = 'SEGMENT24' THEN
          l_seg_value := segment24;
        WHEN p_seg_colname = 'SEGMENT25' THEN
          l_seg_value := segment25;
        WHEN p_seg_colname = 'SEGMENT26' THEN
          l_seg_value := segment26;
        WHEN p_seg_colname = 'SEGMENT27' THEN
          l_seg_value := segment27;
        WHEN p_seg_colname = 'SEGMENT28' THEN
          l_seg_value := segment28;
        WHEN p_seg_colname = 'SEGMENT29' THEN
          l_seg_value := segment29;
        WHEN p_seg_colname = 'SEGMENT30' THEN
          l_seg_value := segment30;
      END CASE;
      RETURN l_seg_value;
    END get_seg_value;

  BEGIN
    -- Check if init() is executed or not. If not, then return
    IF (NOT initialized) THEN
        RETURN('FALSE');
    END IF;

    total_count := 0;

    -- If only ledger id parameter is given, then validate
    -- only ledger id.
    IF ACCESS_ID IS NULL THEN
      IF ((p_ledger_id IS NOT NULL) AND (ccid IS NULL)) THEN
        IF (p_ledger_id = LDGR_ID) THEN
          RETURN('TRUE');
        ELSE
          RETURN('FALSE');
        END IF;
      END IF;
    ELSE
      -- Added check for the access set ID
      IF ((p_ledger_id IS NOT NULL) AND (ccid IS NULL)) THEN
         SELECT count(*)
         INTO total_count
         FROM gl_access_set_ledgers
         WHERE ledger_id = p_ledger_id
            AND access_set_id = ACCESS_ID;

         IF total_count > 0 THEN
           RETURN('TRUE');
         ELSE
           RETURN('FALSE');
         END IF;
      END IF;
    END IF;

    -- If the given code combination id is not NULL, then
    -- validate the ccid
    IF (ccid IS NOT NULL) THEN
      BEGIN
        SELECT segment1,
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
          INTO segment1,
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
          FROM GL_CODE_COMBINATIONS
         WHERE code_combination_id = ccid;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RETURN('FALSE');
      END;

        -- For each segment of the given code combination id, if the
        -- segment is secruity enabled, we check if the segment value
        -- exists in the GL_BIS_SEGVAL_INT temporary table. If not,
        -- then return FALSE.

        IF (seg1_flag) THEN
          SELECT /*+ index(gl_bis_segval_int gl_bis_segval_int_n1 ) */
           count(*)
            into total_count
            FROM GL_BIS_SEGVAL_INT
           WHERE segment_column_name = 'SEGMENT1'
             AND segment_value = segment1;

          IF (total_count = 0) THEN
            return('FALSE');
          END IF;
        END IF;

        IF (seg2_flag) THEN
          SELECT /*+ index(gl_bis_segval_int gl_bis_segval_int_n1 ) */
           count(*)
            into total_count
            FROM GL_BIS_SEGVAL_INT
           WHERE segment_column_name = 'SEGMENT2'
             AND segment_value = segment2;

          IF (total_count = 0) THEN
            return('FALSE');
          END IF;
        END IF;

        IF (seg3_flag) THEN
          SELECT /*+ index(gl_bis_segval_int gl_bis_segval_int_n1 ) */
           count(*)
            into total_count
            FROM GL_BIS_SEGVAL_INT
           WHERE segment_column_name = 'SEGMENT3'
             AND segment_value = segment3;

          IF (total_count = 0) THEN
            return('FALSE');
          END IF;
        END IF;

        IF (seg4_flag) THEN
          SELECT /*+ index(gl_bis_segval_int gl_bis_segval_int_n1 ) */
           count(*)
            into total_count
            FROM GL_BIS_SEGVAL_INT
           WHERE segment_column_name = 'SEGMENT4'
             AND segment_value = segment4;

          IF (total_count = 0) THEN
            return('FALSE');
          END IF;
        END IF;

        IF (seg5_flag) THEN
          SELECT /*+ index(gl_bis_segval_int gl_bis_segval_int_n1 ) */
           count(*)
            into total_count
            FROM GL_BIS_SEGVAL_INT
           WHERE segment_column_name = 'SEGMENT5'
             AND segment_value = segment5;

          IF (total_count = 0) THEN
            return('FALSE');
          END IF;
        END IF;

        IF (seg6_flag) THEN
          SELECT /*+ index(gl_bis_segval_int gl_bis_segval_int_n1 ) */
           count(*)
            into total_count
            FROM GL_BIS_SEGVAL_INT
           WHERE segment_column_name = 'SEGMENT6'
             AND segment_value = segment6;

          IF (total_count = 0) THEN
            return('FALSE');
          END IF;
        END IF;

        IF (seg7_flag) THEN
          SELECT /*+ index(gl_bis_segval_int gl_bis_segval_int_n1 ) */
           count(*)
            into total_count
            FROM GL_BIS_SEGVAL_INT
           WHERE segment_column_name = 'SEGMENT7'
             AND segment_value = segment7;

          IF (total_count = 0) THEN
            return('FALSE');
          END IF;
        END IF;

        IF (seg8_flag) THEN
          SELECT /*+ index(gl_bis_segval_int gl_bis_segval_int_n1 ) */
           count(*)
            into total_count
            FROM GL_BIS_SEGVAL_INT
           WHERE segment_column_name = 'SEGMENT8'
             AND segment_value = segment8;

          IF (total_count = 0) THEN
            return('FALSE');
          END IF;
        END IF;

        IF (seg9_flag) THEN
          SELECT /*+ index(gl_bis_segval_int gl_bis_segval_int_n1 ) */
           count(*)
            into total_count
            FROM GL_BIS_SEGVAL_INT
           WHERE segment_column_name = 'SEGMENT9'
             AND segment_value = segment9;

          IF (total_count = 0) THEN
            return('FALSE');
          END IF;
        END IF;

        IF (seg10_flag) THEN
          SELECT /*+ index(gl_bis_segval_int gl_bis_segval_int_n1 ) */
           count(*)
            into total_count
            FROM GL_BIS_SEGVAL_INT
           WHERE segment_column_name = 'SEGMENT10'
             AND segment_value = segment10;

          IF (total_count = 0) THEN
            return 'FALSE';
          END IF;
        END IF;

        IF (seg11_flag) THEN
          SELECT /*+ index(gl_bis_segval_int gl_bis_segval_int_n1 ) */
           count(*)
            into total_count
            FROM GL_BIS_SEGVAL_INT
           WHERE segment_column_name = 'SEGMENT11'
             AND segment_value = segment11;

          IF (total_count = 0) THEN
            return('FALSE');
          END IF;
        END IF;

        IF (seg12_flag) THEN
          SELECT /*+ index(gl_bis_segval_int gl_bis_segval_int_n1 ) */
           count(*)
            into total_count
            FROM GL_BIS_SEGVAL_INT
           WHERE segment_column_name = 'SEGMENT12'
             AND segment_value = segment12;

          IF (total_count = 0) THEN
            return('FALSE');
          END IF;
        END IF;

        IF (seg13_flag) THEN
          SELECT /*+ index(gl_bis_segval_int gl_bis_segval_int_n1 ) */
           count(*)
            into total_count
            FROM GL_BIS_SEGVAL_INT
           WHERE segment_column_name = 'SEGMENT13'
             AND segment_value = segment13;

          IF (total_count = 0) THEN
            return('FALSE');
          END IF;
        END IF;

        IF (seg14_flag) THEN
          SELECT /*+ index(gl_bis_segval_int gl_bis_segval_int_n1 ) */
           count(*)
            into total_count
            FROM GL_BIS_SEGVAL_INT
           WHERE segment_column_name = 'SEGMENT14'
             AND segment_value = segment14;

          IF (total_count = 0) THEN
            return('FALSE');
          END IF;
        END IF;

        IF (seg15_flag) THEN
          SELECT /*+ index(gl_bis_segval_int gl_bis_segval_int_n1 ) */
           count(*)
            into total_count
            FROM GL_BIS_SEGVAL_INT
           WHERE segment_column_name = 'SEGMENT15'
             AND segment_value = segment15;

          IF (total_count = 0) THEN
            return('FALSE');
          END IF;
        END IF;

        IF (seg16_flag) THEN
          SELECT /*+ index(gl_bis_segval_int gl_bis_segval_int_n1 ) */
           count(*)
            into total_count
            FROM GL_BIS_SEGVAL_INT
           WHERE segment_column_name = 'SEGMENT16'
             AND segment_value = segment16;

          IF (total_count = 0) THEN
            return 'FALSE';
          END IF;
        END IF;

        IF (seg17_flag) THEN
          SELECT /*+ index(gl_bis_segval_int gl_bis_segval_int_n1 ) */
           count(*)
            into total_count
            FROM GL_BIS_SEGVAL_INT
           WHERE segment_column_name = 'SEGMENT17'
             AND segment_value = segment17;

          IF (total_count = 0) THEN
            return 'FALSE';
          END IF;
        END IF;

        IF (seg18_flag) THEN
          SELECT /*+ index(gl_bis_segval_int gl_bis_segval_int_n1 ) */
           count(*)
            into total_count
            FROM GL_BIS_SEGVAL_INT
           WHERE segment_column_name = 'SEGMENT18'
             AND segment_value = segment18;

          IF (total_count = 0) THEN
            return('FALSE');
          END IF;
        END IF;

        IF (seg19_flag) THEN
          SELECT /*+ index(gl_bis_segval_int gl_bis_segval_int_n1 ) */
           count(*)
            into total_count
            FROM GL_BIS_SEGVAL_INT
           WHERE segment_column_name = 'SEGMENT19'
             AND segment_value = segment19;

          IF (total_count = 0) THEN
            return('FALSE');
          END IF;
        END IF;

        IF (seg20_flag) THEN
          SELECT /*+ index(gl_bis_segval_int gl_bis_segval_int_n1 ) */
           count(*)
            into total_count
            FROM GL_BIS_SEGVAL_INT
           WHERE segment_column_name = 'SEGMENT20'
             AND segment_value = segment20;

          IF (total_count = 0) THEN
            return('FALSE');
          END IF;
        END IF;

        IF (seg21_flag) THEN
          SELECT /*+ index(gl_bis_segval_int gl_bis_segval_int_n1 ) */
           count(*)
            into total_count
            FROM GL_BIS_SEGVAL_INT
           WHERE segment_column_name = 'SEGMENT21'
             AND segment_value = segment21;

          IF (total_count = 0) THEN
            return('FALSE');
          END IF;
        END IF;

        IF (seg22_flag) THEN
          SELECT /*+ index(gl_bis_segval_int gl_bis_segval_int_n1 ) */
           count(*)
            into total_count
            FROM GL_BIS_SEGVAL_INT
           WHERE segment_column_name = 'SEGMENT22'
             AND segment_value = segment22;

          IF (total_count = 0) THEN
            return('FALSE');
          END IF;
        END IF;

        IF (seg23_flag) THEN
          SELECT /*+ index(gl_bis_segval_int gl_bis_segval_int_n1 ) */
           count(*)
            into total_count
            FROM GL_BIS_SEGVAL_INT
           WHERE segment_column_name = 'SEGMENT23'
             AND segment_value = segment23;

          IF (total_count = 0) THEN
            return('FALSE');
          END IF;
        END IF;

        IF (seg24_flag) THEN
          SELECT /*+ index(gl_bis_segval_int gl_bis_segval_int_n1 ) */
           count(*)
            into total_count
            FROM GL_BIS_SEGVAL_INT
           WHERE segment_column_name = 'SEGMENT24'
             AND segment_value = segment24;

          IF (total_count = 0) THEN
            return('FALSE');
          END IF;
        END IF;

        IF (seg25_flag) THEN
          SELECT /*+ index(gl_bis_segval_int gl_bis_segval_int_n1 ) */
           count(*)
            into total_count
            FROM GL_BIS_SEGVAL_INT
           WHERE segment_column_name = 'SEGMENT25'
             AND segment_value = segment25;

          IF (total_count = 0) THEN
            return('FALSE');
          END IF;
        END IF;

        IF (seg26_flag) THEN
          SELECT /*+ index(gl_bis_segval_int gl_bis_segval_int_n1 ) */
           count(*)
            into total_count
            FROM GL_BIS_SEGVAL_INT
           WHERE segment_column_name = 'SEGMENT26'
             AND segment_value = segment26;

          IF (total_count = 0) THEN
            return('FALSE');
          END IF;
        END IF;

        IF (seg27_flag) THEN
          SELECT /*+ index(gl_bis_segval_int gl_bis_segval_int_n1 ) */
           count(*)
            into total_count
            FROM GL_BIS_SEGVAL_INT
           WHERE segment_column_name = 'SEGMENT27'
             AND segment_value = segment27;

          IF (total_count = 0) THEN
            return('FALSE');
          END IF;
        END IF;

        IF (seg28_flag) THEN
          SELECT /*+ index(gl_bis_segval_int gl_bis_segval_int_n1 ) */
           count(*)
            into total_count
            FROM GL_BIS_SEGVAL_INT
           WHERE segment_column_name = 'SEGMENT28'
             AND segment_value = segment28;

          IF (total_count = 0) THEN
            return('FALSE');
          END IF;
        END IF;

        IF (seg29_flag) THEN
          SELECT /*+ index(gl_bis_segval_int gl_bis_segval_int_n1 ) */
           count(*)
            into total_count
            FROM GL_BIS_SEGVAL_INT
           WHERE segment_column_name = 'SEGMENT29'
             AND segment_value = segment29;

          IF (total_count = 0) THEN
            return('FALSE');
          END IF;
        END IF;

        IF (seg30_flag) THEN
          SELECT /*+ index(gl_bis_segval_int gl_bis_segval_int_n1 ) */
           count(*)
            into total_count
            FROM GL_BIS_SEGVAL_INT
           WHERE segment_column_name = 'SEGMENT30'
             AND segment_value = segment30;

          IF (total_count = 0) THEN
            return('FALSE');
          END IF;
        END IF;


      -- Validate the given ledger id.
      -- If the given ledger id is NULL, then we return TRUE
      -- because the ccid is also valid from previous logic.
      -- If the given ledger id is not NULL, we return TRUE
      -- if the ledger id is valid.
      IF ACCESS_ID IS NULL THEN
        IF (p_ledger_id IS NOT NULL) THEN
          IF (p_ledger_id = LDGR_ID) THEN
            RETURN('TRUE');
          ELSE
            RETURN('FALSE');
          END IF;
        ELSE           -- Ledger context not available, validate only segment security rules
          RETURN('TRUE');
        END IF;
      ELSE
        -- added access set ID check
          IF (p_ledger_id IS NOT NULL) THEN
            IF SECURITY_SEGMENT_CODE = 'F' THEN
              SELECT count(*) into total_count
              FROM gl_access_set_ledgers
              WHERE ledger_id = p_ledger_id
              AND access_set_id = ACCESS_ID;

            ELSIF SECURITY_SEGMENT_CODE IN ('B','M') THEN
              IF BAL_MGMT_SEG_COL_NAME IS NULL THEN
                RETURN ('FALSE');
              END IF;

              l_seg_value := get_seg_value(BAL_MGMT_SEG_COL_NAME);

              SELECT count(*) into total_count
              FROM   gl_access_set_assignments gasa
              WHERE  gasa.segment_value = l_seg_value
              AND    gasa.ledger_id = p_ledger_id
              AND    gasa.access_set_id = ACCESS_ID;
            END IF;

            IF total_count > 0 THEN
              RETURN ('TRUE');
            ELSE
              RETURN ('FALSE');
            END IF;

          -- Ledger context not available, validate only segment security rules
          ELSE
            RETURN ('TRUE');
          END IF;
        END IF; --IF (ACCESS_ID IS NULL)
    END IF; -- IF (ccid IS NOT NULL ) THEN

  END validate_access;

  -- Function
  --    Validate_segval
  -- Purpose
  --    Validate the given segment number and segment value
  --    according to the rules stored in GL_BIS_SEGVAL_INT temporary
  --    table by gl_security_pkg.init
  --
  FUNCTION validate_segval(segnum1     IN NUMBER DEFAULT NULL,
                           segnum2     IN NUMBER DEFAULT NULL,
                           segval1     IN VARCHAR2 DEFAULT NULL,
                           segval2     IN VARCHAR2 DEFAULT NULL,
                           p_ledger_id IN NUMBER DEFAULT NULL)
    RETURN VARCHAR2 IS
    seg1_name VARCHAR2(30);
    seg2_name VARCHAR2(30);
    count1    NUMBER;
  BEGIN

    -- Check if init() is executed or not. If not, then return
    IF (NOT initialized) THEN
      RETURN('FALSE');
    END IF;

    -- Validate first segment number and segment value
    IF (segnum1 IS NOT NULL AND segnum1 <> -1) THEN
      IF (seg_col_name(segnum1) IS NOT NULL) THEN

        seg1_name := seg_col_name(segnum1);

        SELECT /*+ index(gl_bis_segval_int gl_bis_segval_int_n1 ) */
         count(*)
          into count1
          FROM GL_BIS_SEGVAL_INT
         WHERE segment_column_name = seg1_name
           AND segment_value = segval1;

        IF (count1 = 0) THEN
          return('FALSE');
        ELSE
           IF p_ledger_id IS NOT NULL AND
                ACCESS_ID IS NOT NULL AND
                 SECURITY_SEGMENT_CODE IN ('B','M') THEN
                  IF BAL_MGMT_SEG_COL_NAME IS NULL THEN
                     RETURN ('FALSE');
                  END IF;

                  IF seg1_name = BAL_MGMT_SEG_COL_NAME THEN
                    count1 := 0;
                    SELECT count(*) into count1
                    FROM   gl_access_set_assignments gasa
                    WHERE  gasa.segment_value = segval1
                    AND    gasa.ledger_id = p_ledger_id
                    AND    gasa.access_set_id = ACCESS_ID;

                   IF count1 = 0 THEN
                      RETURN ('FALSE');
                   END IF;
                  END IF;
           END IF;
        END IF;
      END IF;
    END IF;

    count1 := 0;

    -- Validate second segment nummber and segment value
    IF (segnum2 IS NOT NULL AND segnum2 <> -1) THEN
      IF (seg_col_name(segnum2) IS NOT NULL) THEN

        seg2_name := seg_col_name(segnum2);

        SELECT /*+ index(gl_bis_segval_int gl_bis_segval_int_n1 ) */
         count(*)
          into count1
          FROM GL_BIS_SEGVAL_INT
         WHERE segment_column_name = seg2_name
           AND segment_value = segval2;

        IF (count1 = 0) THEN
          return('FALSE');
        ELSE
           IF p_ledger_id IS NOT NULL AND
                ACCESS_ID IS NOT NULL AND
                  SECURITY_SEGMENT_CODE IN ('B','M') THEN

                  IF BAL_MGMT_SEG_COL_NAME IS NULL THEN
                     RETURN ('FALSE');
                  END IF;

                  IF seg2_name = BAL_MGMT_SEG_COL_NAME THEN
                    count1 := 0;
                    SELECT count(*)
                    INTO   count1
                    FROM   gl_access_set_assignments gasa
                    WHERE  gasa.segment_value = segval2
                    AND    gasa.ledger_id = p_ledger_id
                    AND    gasa.access_set_id = ACCESS_ID;

                   IF count1 = 0 THEN
                      RETURN ('FALSE');
                   END IF;
                  END IF;
           END IF;
        END IF;
      END IF;
    END IF;

    return('TRUE');

  END validate_segval;

  FUNCTION login_led_id RETURN NUMBER IS
  BEGIN
    IF (NOT initialized) THEN
        RETURN(-1);
    ELSE
        RETURN(LDGR_ID);
    END IF;
  END login_led_id;

  --Added new parameterized function
  FUNCTION login_led_id(p_ledger_id IN NUMBER) RETURN NUMBER IS
    l_total_count NUMBER;
  BEGIN
    IF p_ledger_id IS NULL THEN
      RETURN(-1);
    ELSIF (NOT initialized) THEN
      RETURN(-1);
    END IF;

    SELECT count(*)
    INTO l_total_count
    FROM gl_access_set_ledgers
    WHERE ledger_id = p_ledger_id
       AND access_set_id = ACCESS_ID;

    IF l_total_count > 0 THEN
      RETURN(p_ledger_id);
    ELSE
      RETURN(-1);
    END IF;

  END login_led_id;

  --Added new function
  FUNCTION login_access_id RETURN NUMBER IS
  BEGIN
    IF (NOT initialized) THEN
        RETURN(-1);
    ELSE
        RETURN(ACCESS_ID);
    END IF;
  END login_access_id;

END gl_security_pkg;

/
