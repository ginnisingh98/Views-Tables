--------------------------------------------------------
--  DDL for Package Body QLTCPPLB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QLTCPPLB" AS
/* $Header: qltcpplb.plb 120.3.12010000.1 2008/07/25 09:21:39 appldev ship $ */

-- Insert rows for copying plans
-- 2/5/96
-- Jacqueline Chang

  PROCEDURE insert_plan_chars (X_PLAN_ID NUMBER,
                X_COPY_PLAN_ID NUMBER,
                X_USER_ID NUMBER,
                X_DISABLED_INDEXED_ELEMENTS OUT NOCOPY VARCHAR2) IS

  --
  -- Bug 3926150
  --
  l_disabled_indexed_elements VARCHAR2(3000);
  l_default_column VARCHAR2(30);
  dummy NUMBER;

    CURSOR C1 IS
      SELECT
        PLAN_CHAR_ACTION_TRIGGER_ID,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        TRIGGER_SEQUENCE,
        PLAN_ID,
        CHAR_ID,
        OPERATOR,
        LOW_VALUE_LOOKUP,
        HIGH_VALUE_LOOKUP,
        LOW_VALUE_OTHER,
        HIGH_VALUE_OTHER,
        LOW_VALUE_OTHER_ID,
        HIGH_VALUE_OTHER_ID
      FROM QA_PLAN_CHAR_ACTION_TRIGGERS
      WHERE PLAN_ID = X_COPY_PLAN_ID AND
            CHAR_ID NOT IN (SELECT CHAR_ID FROM QA_PLAN_CHARS
                            WHERE PLAN_ID = X_PLAN_ID)
      ORDER BY TRIGGER_SEQUENCE,
               PLAN_CHAR_ACTION_TRIGGER_ID;


    CURSOR CS1 IS
      SELECT QA_PLAN_CHAR_ACTION_TRIGGERS_S.NEXTVAL FROM DUAL;

    ACTION_TRIGGER_ID NUMBER;

    QPCAT       C1%ROWTYPE;

    CURSOR C2 IS
      SELECT
        PLAN_CHAR_ACTION_ID,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        PLAN_CHAR_ACTION_TRIGGER_ID,
        ACTION_ID,
        CAR_NAME_PREFIX,
        CAR_TYPE_ID,
        CAR_OWNER,
        MESSAGE,
        STATUS_CODE,
        ALR_ACTION_ID,
        ALR_ACTION_SET_ID,
        ASSIGNED_CHAR_ID,
        ASSIGN_TYPE
      FROM QA_PLAN_CHAR_ACTIONS
      WHERE PLAN_CHAR_ACTION_TRIGGER_ID = QPCAT.PLAN_CHAR_ACTION_TRIGGER_ID
      ORDER BY PLAN_CHAR_ACTION_ID;

    QPCA        C2%ROWTYPE;

    CURSOR CS2 IS
      SELECT QA_PLAN_CHAR_ACTIONS_S.NEXTVAL FROM DUAL;

    QPC_ACTION_ID       NUMBER;

    -- Bug 3111310.  Add app_id to WHERE clause of SQL
    -- to improve performance
    -- ksoh Fri Aug 22 11:05:00 PST 2003
    --
    CURSOR C3 IS
      SELECT
        APPLICATION_ID,
        ACTION_ID,
        NAME,
        ALERT_ID,
        ACTION_TYPE,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        END_DATE_ACTIVE,
        ENABLED_FLAG,
        DESCRIPTION,
        ACTION_LEVEL_TYPE,
        DATE_LAST_EXECUTED,
        FILE_NAME,
        ARGUMENT_STRING,
        PROGRAM_APPLICATION_ID,
        CONCURRENT_PROGRAM_ID,
        LIST_APPLICATION_ID,
        LIST_ID,
        TO_RECIPIENTS,
        CC_RECIPIENTS,
        BCC_RECIPIENTS,
        PRINT_RECIPIENTS,
        PRINTER,
        SUBJECT,
        REPLY_TO,
        RESPONSE_SET_ID,
        FOLLOW_UP_AFTER_DAYS,
        COLUMN_WRAP_FLAG,
        MAXIMUM_SUMMARY_MESSAGE_WIDTH,
        BODY,
        VERSION_NUMBER
      FROM ALR_ACTIONS
      WHERE APPLICATION_ID = 250
      AND ACTION_ID = QPCA.ALR_ACTION_ID;

      ALRA      C3%ROWTYPE;

      CURSOR CS3 IS
      SELECT
        ALR_ACTIONS_S.NEXTVAL,
        ALR_ACTION_SETS_S.NEXTVAL,
        ALR_ACTION_SET_MEMBERS_S.NEXTVAL,
        QA_ALR_ACTION_NAME_S.NEXTVAL,
        QA_ALR_ACTION_SET_NAME_S.NEXTVAL
      FROM DUAL;

      NEW_ACTION_ID     NUMBER;
      NEW_ACTION_SET_ID NUMBER;
      NEW_ACTION_SET_MEMBER_ID  NUMBER;

      ACTION_SET_SEQUENCE NUMBER;
      ACTION_SET_MEMBERS_SEQUENCE NUMBER;

      X_ACTION_NAME NUMBER;
      X_ACTION_SET_NAME NUMBER;
      NEW_ACTION_NAME VARCHAR2(80);
      NEW_ACTION_SET_NAME VARCHAR2(50);

      CURSOR C4 IS
      SELECT
        PLAN_CHAR_ACTION_ID,
        CHAR_ID,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        TOKEN_NAME
      FROM QA_PLAN_CHAR_ACTION_OUTPUTS
      WHERE PLAN_CHAR_ACTION_ID = QPCA.PLAN_CHAR_ACTION_ID
      ORDER BY PLAN_CHAR_ACTION_ID;

      QPCAO     C4%ROWTYPE;

--
-- See Bug 2624112
-- The decimal precision for a number type collection
-- element is to be configured at plan level.
-- rkunchal Wed Oct 16 05:32:33 PDT 2002
--
-- Modified the cursor to read decimal precision of the element
-- in master plan also.
--
-- Changed for UOM Code also
--
-- Tracking Bug : 3104827. Review Tracking Bug : 3148873
-- Modified the cursor to include three new flags for collection plan elements
-- saugupta Mon Sep 22 23:38:15 PDT 2003

      -- Bug 4958761.  SQL Repository Fix SQL ID: 15008182
      CURSOR C5 IS
        SELECT
            qpc.plan_id,
            qpc.char_id,
            qc.name char_name,
            qc.datatype,
            qpc.last_update_date,
            qpc.last_updated_by,
            qpc.creation_date,
            qpc.created_by,
            qpc.prompt_sequence,
            qpc.prompt,
            qpc.enabled_flag,
            qpc.mandatory_flag,
            qpc.read_only_flag,
            qpc.ss_poplist_flag,
            qpc.information_flag,
            qpc.default_value,
            qc.hardcoded_column,
            qpc.result_column_name,
            qpc.values_exist_flag,
            qpc.displayed_flag,
            -- 12.1 Device Integration Project.
            -- Added device fields.
            -- bhsankar Fri Oct 19 01:51:57 PDT 2007
            qpc.device_flag,
            qpc.device_id,
            qpc.override_flag,
            -- Device Integration Project End.
            qpc.attribute_category,
            qpc.attribute1,
            qpc.attribute2,
            qpc.attribute3,
            qpc.attribute4,
            qpc.attribute5,
            qpc.attribute6,
            qpc.attribute7,
            qpc.attribute8,
            qpc.attribute9,
            qpc.attribute10,
            qpc.attribute11,
            qpc.attribute12,
            qpc.attribute13,
            qpc.attribute14,
            qpc.attribute15,
            qpc.default_value_id,
            nvl(qpc.decimal_precision, qc.decimal_precision) decimal_precision ,
            nvl(qpc.uom_code, qc.uom_code) uom_code
        FROM qa_plan_chars qpc,
            qa_chars qc
        WHERE qpc.plan_id = X_COPY_PLAN_ID
            AND qc.char_id = qpc.char_id
            AND qc.char_id not in
            (SELECT char_id
             FROM qa_plan_chars
             WHERE plan_id = X_PLAN_ID )
        ORDER BY prompt_sequence;
/*
      SELECT
        PLAN_ID,
        CHAR_ID,
        CHAR_NAME,  -- Bug 3926150 needed name.
        DATATYPE,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        PROMPT_SEQUENCE,
        PROMPT,
        ENABLED_FLAG,
        MANDATORY_FLAG,
        READ_ONLY_FLAG,
        SS_POPLIST_FLAG,
        INFORMATION_FLAG,
        DEFAULT_VALUE,
        HARDCODED_COLUMN,
        RESULT_COLUMN_NAME,
        VALUES_EXIST_FLAG,
        DISPLAYED_FLAG,
        ATTRIBUTE_CATEGORY,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        ATTRIBUTE6,
        ATTRIBUTE7,
        ATTRIBUTE8,
        ATTRIBUTE9,
        ATTRIBUTE10,
        ATTRIBUTE11,
        ATTRIBUTE12,
        ATTRIBUTE13,
        ATTRIBUTE14,
        ATTRIBUTE15,
        DEFAULT_VALUE_ID,
        DECIMAL_PRECISION,
        UOM_CODE
      FROM QA_PLAN_CHARS_V
      WHERE PLAN_ID = X_COPY_PLAN_ID
      AND   CHAR_ID NOT IN (SELECT CHAR_ID FROM QA_PLAN_CHARS
                            WHERE PLAN_ID = X_PLAN_ID)
      ORDER BY PROMPT_SEQUENCE;
*/

      QPCV      C5%ROWTYPE;

-- rkaza; 05/01/2002. added datatype restriction

      -- Bug 3229810. Modifying the code as Collection element copying
      -- failing for DATETIME datatype elements.
      -- saugupta Wed Nov 12 23:08:34 PST 2003

      -- -- Bug 4958761.  SQL Repository Fix SQL ID: 15008205
      CURSOR C7 IS
        SELECT TO_NUMBER(SUBSTR(QPC.RESULT_COLUMN_NAME,10,3)) RES_COLUMN_NAME
        FROM QA_PLAN_CHARS QPC, QA_CHARS QC
        WHERE PLAN_ID = X_PLAN_ID
            AND qc.char_id = qpc.char_id
            AND   QC.HARDCODED_COLUMN IS NULL
            AND QC.DATATYPE in (1,2,3,6)
        ORDER BY TO_NUMBER(SUBSTR(QPC.RESULT_COLUMN_NAME,10,3));

/*
      SELECT TO_NUMBER(SUBSTR(RESULT_COLUMN_NAME,10,3)) RES_COLUMN_NAME
        FROM QA_PLAN_CHARS_V
        WHERE PLAN_ID = X_PLAN_ID
        AND   HARDCODED_COLUMN IS NULL
        AND DATATYPE in (1,2,3,6)
        ORDER BY TO_NUMBER(SUBSTR(RESULT_COLUMN_NAME,10,3));
*/

      TYPE column_num IS TABLE of BOOLEAN
        INDEX BY BINARY_INTEGER;

      res_columns column_num;
      i binary_integer;

      COLUMN_NAME       VARCHAR2(30);
      COLUMN_NUMBER     NUMBER;
      NEW_RESULT_COLUMN_NAME VARCHAR2(30);

-- rkaza; 05/01/2002. added the following cursor for comments

      -- Bug 4958761.  SQL Repository Fix SQL ID: 15008222
      CURSOR C8 IS
        SELECT TO_NUMBER(SUBSTR(RESULT_COLUMN_NAME,8,3)) RES_COLUMN_NAME
        FROM QA_PLAN_CHARS QPC, QA_CHARS QC
        WHERE QPC.PLAN_ID = X_PLAN_ID
        and qc.char_id = qpc.char_id
        AND QC.HARDCODED_COLUMN IS NULL
        AND QC.DATATYPE = 4
        ORDER BY TO_NUMBER(SUBSTR(QPC.RESULT_COLUMN_NAME,8,3));
/*
      SELECT TO_NUMBER(SUBSTR(RESULT_COLUMN_NAME,8,3)) RES_COLUMN_NAME
        FROM QA_PLAN_CHARS_V
        WHERE PLAN_ID = X_PLAN_ID
        AND   HARDCODED_COLUMN IS NULL
        AND DATATYPE = 4
        ORDER BY TO_NUMBER(SUBSTR(RESULT_COLUMN_NAME,8,3));
*/

      comment_cols column_num;
      j binary_integer;

      CURSOR C6 IS
      SELECT MAX(PROMPT_SEQUENCE) FROM QA_PLAN_CHARS
        WHERE PLAN_ID = X_PLAN_ID;

      NEW_PROMPT_SEQUENCE NUMBER;

    BEGIN

      -- Insert child values


      INSERT INTO QA_PLAN_CHAR_VALUE_LOOKUPS (
        PLAN_ID,
        CHAR_ID,
        SHORT_CODE,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        DESCRIPTION,
        SHORT_CODE_ID)
      SELECT
        X_PLAN_ID,
        CHAR_ID,
        SHORT_CODE,
        SYSDATE,
        X_USER_ID,
        SYSDATE,
        CREATED_BY,
        DESCRIPTION,
        SHORT_CODE_ID
      FROM QA_PLAN_CHAR_VALUE_LOOKUPS
      WHERE PLAN_ID = X_COPY_PLAN_ID
      AND CHAR_ID NOT IN (SELECT CHAR_ID FROM QA_PLAN_CHARS
                          WHERE PLAN_ID = X_PLAN_ID);

      OPEN C1;
      LOOP

        FETCH C1 INTO QPCAT;
        EXIT WHEN C1%NOTFOUND;

        OPEN CS1;
        FETCH CS1 INTO ACTION_TRIGGER_ID;
        CLOSE CS1;

        INSERT INTO QA_PLAN_CHAR_ACTION_TRIGGERS (
          PLAN_CHAR_ACTION_TRIGGER_ID,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          TRIGGER_SEQUENCE,
          PLAN_ID,
          CHAR_ID,
          OPERATOR,
          LOW_VALUE_LOOKUP,
          HIGH_VALUE_LOOKUP,
          LOW_VALUE_OTHER,
          HIGH_VALUE_OTHER,
          LOW_VALUE_OTHER_ID,
          HIGH_VALUE_OTHER_ID)
        VALUES (
          ACTION_TRIGGER_ID,
          SYSDATE,
          X_USER_ID,
          SYSDATE,
          X_USER_ID,
          QPCAT.TRIGGER_SEQUENCE,
          X_PLAN_ID,
          QPCAT.CHAR_ID,
          QPCAT.OPERATOR,
          QPCAT.LOW_VALUE_LOOKUP,
          QPCAT.HIGH_VALUE_LOOKUP,
          QPCAT.LOW_VALUE_OTHER,
          QPCAT.HIGH_VALUE_OTHER,
          QPCAT.LOW_VALUE_OTHER_ID,
          QPCAT.HIGH_VALUE_OTHER_ID);

        --
        -- Bug 2698812
        -- Avoided the earlier used Cursor to read
        -- from PO lookup table. Using variables instead
        --
        -- rkunchal Sat Jan  4 02:06:10 PST 2003
        --
        -- Bug 5300577
        -- Included Template OPM Recieving inspection plan because
        -- conversion is required for these plans as well.

        IF X_COPY_PLAN_ID IN (1,2147483637) AND QPCAT.LOW_VALUE_OTHER IN ('ACCEPT', 'REJECT') THEN
           UPDATE  QA_PLAN_CHAR_ACTION_TRIGGERS
           SET     LOW_VALUE_OTHER = (SELECT DISPLAYED_FIELD
                                      FROM   PO_LOOKUP_CODES
                                      WHERE  LOOKUP_TYPE = 'ERT RESULTS ACTION'
                                      AND    LOOKUP_CODE = QPCAT.LOW_VALUE_OTHER)
           WHERE   PLAN_CHAR_ACTION_TRIGGER_ID = ACTION_TRIGGER_ID;
        END IF;

          OPEN C2;
          LOOP

            FETCH C2 INTO QPCA;
            EXIT WHEN C2%NOTFOUND;

            OPEN CS2;
            FETCH CS2 INTO QPC_ACTION_ID;
            CLOSE CS2;

            OPEN CS3;
            FETCH CS3 INTO NEW_ACTION_ID, NEW_ACTION_SET_ID,
                        NEW_ACTION_SET_MEMBER_ID,
                        X_ACTION_NAME, X_ACTION_SET_NAME;
            CLOSE CS3;

            NEW_ACTION_NAME := 'QA_' || TO_CHAR(X_ACTION_NAME);
            NEW_ACTION_SET_NAME := 'QA_' || TO_CHAR(X_ACTION_SET_NAME);

          INSERT INTO QA_PLAN_CHAR_ACTIONS (
            PLAN_CHAR_ACTION_ID,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            CREATION_DATE,
            CREATED_BY,
            PLAN_CHAR_ACTION_TRIGGER_ID,
            ACTION_ID,
            CAR_NAME_PREFIX,
            CAR_TYPE_ID,
            CAR_OWNER,
            MESSAGE,
            STATUS_CODE,
            ALR_ACTION_ID,
            ALR_ACTION_SET_ID,
            ASSIGNED_CHAR_ID,
            ASSIGN_TYPE)
          VALUES (
            QPC_ACTION_ID,
            SYSDATE,
            X_USER_ID,
            SYSDATE,
            X_USER_ID,
            ACTION_TRIGGER_ID,
            QPCA.ACTION_ID,
            QPCA.CAR_NAME_PREFIX,
            QPCA.CAR_TYPE_ID,
            QPCA.CAR_OWNER,
            QPCA.MESSAGE,
            QPCA.STATUS_CODE,
            DECODE (QPCA.ACTION_ID,
                        10, NEW_ACTION_ID,
                        11, NEW_ACTION_ID,
                        12, NEW_ACTION_ID,
                        13, NEW_ACTION_ID,
                        NULL),
            DECODE (QPCA.ACTION_ID,
                        10, NEW_ACTION_SET_ID,
                        11, NEW_ACTION_SET_ID,
                        12, NEW_ACTION_SET_ID,
                        13, NEW_ACTION_SET_ID,
                        NULL),
            QPCA.ASSIGNED_CHAR_ID,
            QPCA.ASSIGN_TYPE
          );

          OPEN C3;
          FETCH C3 INTO ALRA;

          IF NOT C3%NOTFOUND THEN
            INSERT INTO ALR_ACTIONS (
              APPLICATION_ID,
              ACTION_ID,
              NAME,
              ALERT_ID,
              ACTION_TYPE,
              LAST_UPDATE_DATE,
              LAST_UPDATED_BY,
              CREATION_DATE,
              CREATED_BY,
              END_DATE_ACTIVE,
              ENABLED_FLAG,
              DESCRIPTION,
              ACTION_LEVEL_TYPE,
              DATE_LAST_EXECUTED,
              FILE_NAME,
              ARGUMENT_STRING,
              PROGRAM_APPLICATION_ID,
              CONCURRENT_PROGRAM_ID,
              LIST_APPLICATION_ID,
              LIST_ID,
              TO_RECIPIENTS,
              CC_RECIPIENTS,
              BCC_RECIPIENTS,
              PRINT_RECIPIENTS,
              PRINTER,
              SUBJECT,
              REPLY_TO,
              RESPONSE_SET_ID,
              FOLLOW_UP_AFTER_DAYS,
              COLUMN_WRAP_FLAG,
              MAXIMUM_SUMMARY_MESSAGE_WIDTH,
              BODY,
              VERSION_NUMBER)
            VALUES (
              ALRA.APPLICATION_ID,
              NEW_ACTION_ID,
              NEW_ACTION_NAME,
              ALRA.ALERT_ID,
              ALRA.ACTION_TYPE,
              SYSDATE,
              X_USER_ID,
              SYSDATE,
              X_USER_ID,
              ALRA.END_DATE_ACTIVE,
              ALRA.ENABLED_FLAG,
              ALRA.DESCRIPTION,
              ALRA.ACTION_LEVEL_TYPE,
              ALRA.DATE_LAST_EXECUTED,
              ALRA.FILE_NAME,
              ALRA.ARGUMENT_STRING,
              ALRA.PROGRAM_APPLICATION_ID,
              ALRA.CONCURRENT_PROGRAM_ID,
              ALRA.LIST_APPLICATION_ID,
              ALRA.LIST_ID,
              ALRA.TO_RECIPIENTS,
              ALRA.CC_RECIPIENTS,
              ALRA.BCC_RECIPIENTS,
              ALRA.PRINT_RECIPIENTS,
              ALRA.PRINTER,
              ALRA.SUBJECT,
              ALRA.REPLY_TO,
              ALRA.RESPONSE_SET_ID,
              ALRA.FOLLOW_UP_AFTER_DAYS,
              ALRA.COLUMN_WRAP_FLAG,
              ALRA.MAXIMUM_SUMMARY_MESSAGE_WIDTH,
              ALRA.BODY,
              ALRA.VERSION_NUMBER
            );

            BEGIN
              SELECT NVL(MAX(SEQUENCE),0)+1
              INTO ACTION_SET_SEQUENCE
              FROM ALR_ACTION_SETS
              WHERE APPLICATION_ID = 250
              AND   ALERT_ID = 10177;

            EXCEPTION
              WHEN NO_DATA_FOUND THEN
              ACTION_SET_SEQUENCE := 1;
            END;

            INSERT INTO ALR_ACTION_SETS (
              APPLICATION_ID,
              ACTION_SET_ID,
              NAME,
              ALERT_ID,
              LAST_UPDATE_DATE,
              LAST_UPDATED_BY,
              CREATION_DATE,
              CREATED_BY,
              END_DATE_ACTIVE,
              ENABLED_FLAG,
              RECIPIENTS_VIEW_ONLY_FLAG,
              DESCRIPTION,
              SUPPRESS_FLAG,
              SUPPRESS_DAYS,
              SEQUENCE)
            VALUES (
              250,
              NEW_ACTION_SET_ID,
              NEW_ACTION_SET_NAME,
              10177,
              SYSDATE,
              X_USER_ID,
              SYSDATE,
              X_USER_ID,
              NULL,
              'Y',
              'N',
              NEW_ACTION_SET_NAME,
              'N',
              NULL,
              ACTION_SET_SEQUENCE
            );

            BEGIN
              SELECT NVL(MAX(SEQUENCE),0)+1
              INTO ACTION_SET_MEMBERS_SEQUENCE
              FROM ALR_ACTION_SET_MEMBERS
              WHERE APPLICATION_ID = 250
              AND   ALERT_ID = 10177
              AND   ACTION_SET_ID = NEW_ACTION_SET_ID;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
              ACTION_SET_MEMBERS_SEQUENCE := 1;
            END;

            INSERT INTO ALR_ACTION_SET_MEMBERS (
              APPLICATION_ID,
              ACTION_SET_MEMBER_ID,
              ACTION_SET_ID,
              ACTION_ID,
              ACTION_GROUP_ID,
              ALERT_ID,
              SEQUENCE,
              LAST_UPDATE_DATE,
              LAST_UPDATED_BY,
              CREATION_DATE,
              CREATED_BY,
              END_DATE_ACTIVE,
              ENABLED_FLAG,
              SUMMARY_THRESHOLD,
              ABORT_FLAG,
              ERROR_ACTION_SEQUENCE)
            VALUES (
              250,
              NEW_ACTION_SET_MEMBER_ID,
              NEW_ACTION_SET_ID,
              NEW_ACTION_ID,
              NULL,
              10177,
              ACTION_SET_MEMBERS_SEQUENCE,
              SYSDATE,
              X_USER_ID,
              SYSDATE,
              X_USER_ID,
              NULL,
              'Y',
              NULL,
              'A',
              NULL
            );

          END IF;

          CLOSE C3;

          OPEN C4;
          LOOP
            FETCH C4 INTO QPCAO;
            EXIT WHEN C4%NOTFOUND;

            INSERT INTO QA_PLAN_CHAR_ACTION_OUTPUTS (
                PLAN_CHAR_ACTION_ID,
                CHAR_ID,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                CREATION_DATE,
                CREATED_BY,
                TOKEN_NAME)
            VALUES (
                QPC_ACTION_ID,
                QPCAO.CHAR_ID,
                SYSDATE,
                X_USER_ID,
                SYSDATE,
                X_USER_ID,
                QPCAO.TOKEN_NAME
              );

          END LOOP;
          CLOSE C4;

        END LOOP;
        CLOSE C2;

      END LOOP;
      CLOSE C1;

      -- Put this insert statement AFTER all the children have been inserted
      -- so that the last line of the where clauses will work in the above
      -- statements; i.e. if you insert the plan-chars first, none of the
      -- children will ever get copied over.

      OPEN C6;
      FETCH C6 INTO NEW_PROMPT_SEQUENCE;
      CLOSE C6;

      IF NEW_PROMPT_SEQUENCE IS NULL THEN
        NEW_PROMPT_SEQUENCE := 0;
      END IF;

      FOR i IN 1..QLTNINRB.RES_CHAR_COLUMNS LOOP
        res_columns(i) := FALSE;
      END LOOP;

-- rkaza; 05/01/2002. following for loop for comments
      FOR j IN 1..5 LOOP
        comment_cols(j) := FALSE;
      END LOOP;

      OPEN C7;
      LOOP
        FETCH C7 INTO i;
        EXIT WHEN C7%NOTFOUND;

        res_columns(i) := TRUE;
      END LOOP;
      CLOSE C7;

-- rkaza; 05/01/2002. following cursor for comments
      OPEN C8;
      LOOP
        FETCH C8 INTO j;
        EXIT WHEN C8%NOTFOUND;

        comment_cols(j) := TRUE;
      END LOOP;
      CLOSE C8;

-- rkaza; 05/01/2002. initialize j for comments
      --
      -- Need to move i to inside loop for Bug 3926150
      --
      -- i := 1;
      --
      j := 1;

      OPEN C5;
      LOOP

        FETCH C5 INTO QPCV;
        EXIT WHEN C5%NOTFOUND;

        IF QPCV.HARDCODED_COLUMN IS NOT NULL THEN
          NEW_RESULT_COLUMN_NAME := QPCV.HARDCODED_COLUMN;
        ELSE

/* rkaza; 05/01/2002. copy the same result_column_name as in the original plan
   for sequence element
*/
          IF QPCV.DATATYPE = 5 THEN
                  NEW_RESULT_COLUMN_NAME := QPCV.RESULT_COLUMN_NAME;
          END IF;

-- rkaza; 05/01/2002. character columns

          -- Bug 3229810. Modifying the code as Collection element copying
          -- failing for DATETIME datatype elements.
          -- saugupta Wed Nov 12 23:08:34 PST 2003
          IF QPCV.DATATYPE IN (1,2,3,6) THEN

              --
              -- Bug 3926150.  Test if there is a function based index
              -- associated.  If so, we will try to use it.
              --
              new_result_column_name := NULL;
              l_default_column :=
                  qa_char_indexes_pkg.get_default_result_column(qpcv.char_id);
              IF l_default_column IS NOT NULL THEN
                  IF NOT res_columns(to_number(substr(l_default_column, 10))) THEN
                      --
                      -- Now we know the default column is available.
                      --
                      new_result_column_name := l_default_column;
                  ELSE
                      --
                      -- Need to warn user because we can't reuse the index.
                      --
                      l_disabled_indexed_elements :=
                          l_disabled_indexed_elements || ', ' || qpcv.char_name;
                      dummy := qa_char_indexes_pkg.disable_index(qpcv.char_id);
                  END IF;
               END IF;

               IF new_result_column_name IS NULL THEN
                  -- Find the first available column number for character columns
                  --
                  -- Bug 3926150.  Moved i to here to re-scan entire rg
                  -- for more foolproof operation.
                  --
                  i := 1;
                  WHILE ((res_columns(i) = TRUE) AND (i <= QLTNINRB.RES_CHAR_COLUMNS)) LOOP
                        i := i + 1;
                  END LOOP;

                  IF i > QLTNINRB.RES_CHAR_COLUMNS THEN
                    -- Exceeded upper limit of maximum number of chars.  Error out.
                    FND_MESSAGE.SET_NAME('QA', 'QA_EXCEEDED_COLUMN_COUNT');
                    APP_EXCEPTION.RAISE_EXCEPTION;
                  END IF;

                  NEW_RESULT_COLUMN_NAME := 'CHARACTER' || TO_CHAR(i);
                END IF;

                res_columns(to_number(substr(new_result_column_name, 10))) := TRUE;
                --
                -- Bug 3926150
                -- i := i + 1;
                --
          END IF;

-- rkaza; 05/01/2002. for comments
          IF QPCV.DATATYPE = 4 THEN
                  -- Find the first available column number for comment columns
                  WHILE ((comment_cols(j) = TRUE) AND (j <= 5)) LOOP
                        j := j + 1;
                  END LOOP;

                  IF j > 5 THEN
                    -- Exceeded upper limit of maximum number of chars.  Error out.
                    FND_MESSAGE.SET_NAME('QA', 'QA_EXCEEDED_COLUMN_COUNT');
                    APP_EXCEPTION.RAISE_EXCEPTION;
                  END IF;

                  NEW_RESULT_COLUMN_NAME := 'COMMENT' || TO_CHAR(j);
                  comment_cols(j) := TRUE;
                  j := j + 1;
          END IF;

        END IF;

        NEW_PROMPT_SEQUENCE := NEW_PROMPT_SEQUENCE + 10;

--
-- See Bug 2624112
-- The decimal precision for a number type collection
-- element is to be configured at plan level.
-- rkunchal Wed Oct 16 05:32:33 PDT 2002
--
-- Modified the INSERT statement to write decimal_precision also
-- from the master plan.
--
-- Tracking Bug : 3104827. Review Tracking Bug : 3148873
-- Modified the INSERT statement to include three new flags for collection plan elements
-- saugupta Mon Sep 22 23:38:15 PDT 2003

        INSERT INTO QA_PLAN_CHARS (
          plan_id,
          char_id,
          last_update_date,
          last_updated_by,
          creation_date,
          created_by,
          prompt_sequence,
          prompt,
          enabled_flag,
          mandatory_flag,
          read_only_flag,
          ss_poplist_flag,
          information_flag,
          default_value,
          result_column_name,
          values_exist_flag,
          displayed_flag,
          attribute_category,
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
          attribute15,
          default_value_id,
          decimal_precision,
          uom_code,
          -- 12.1 Device Integration Project.
          -- Added device fields.
          -- bhsankar Fri Oct 19 01:51:57 PDT 2007
          device_flag,
          device_id,
          override_flag)
        VALUES (
          X_PLAN_ID,
          QPCV.CHAR_ID,
          SYSDATE,
          X_USER_ID,
          SYSDATE,
          X_USER_ID,
          NEW_PROMPT_SEQUENCE,
          QPCV.PROMPT,
          QPCV.ENABLED_FLAG,
          QPCV.MANDATORY_FLAG,
          QPCV.READ_ONLY_FLAG,
          QPCV.SS_POPLIST_FLAG,
          QPCV.INFORMATION_FLAG,
          QPCV.DEFAULT_VALUE,
          NEW_RESULT_COLUMN_NAME,
          QPCV.VALUES_EXIST_FLAG,
          QPCV.DISPLAYED_FLAG,
          QPCV.ATTRIBUTE_CATEGORY,
          QPCV.ATTRIBUTE1,
          QPCV.ATTRIBUTE2,
          QPCV.ATTRIBUTE3,
          QPCV.ATTRIBUTE4,
          QPCV.ATTRIBUTE5,
          QPCV.ATTRIBUTE6,
          QPCV.ATTRIBUTE7,
          QPCV.ATTRIBUTE8,
          QPCV.ATTRIBUTE9,
          QPCV.ATTRIBUTE10,
          QPCV.ATTRIBUTE11,
          QPCV.ATTRIBUTE12,
          QPCV.ATTRIBUTE13,
          QPCV.ATTRIBUTE14,
          QPCV.ATTRIBUTE15,
          QPCV.DEFAULT_VALUE_ID,
          QPCV.DECIMAL_PRECISION,
          QPCV.UOM_CODE,
          -- Bug 6350580
          -- 12.1 Device Integration Project.
          -- Added device fields.
          -- bhsankar Fri Oct 19 01:51:57 PDT 2007
          QPCV.DEVICE_FLAG,
          QPCV.DEVICE_ID,
          QPCV.OVERRIDE_FLAG
        );

      END LOOP;
      CLOSE C5;

      --
      -- Bug 3926150
      -- Pass back the disabled index names.  (use substr to get rid of
      -- the lead comma and space.
      --
      IF l_disabled_indexed_elements IS NOT NULL THEN
          x_disabled_indexed_elements := substr(l_disabled_indexed_elements, 3);
      END IF;

-- the following insert statement has to be replicated for the
-- collection triggers in-lists.  Comment it out for now; in-lists
-- haven't been implemented in QLTPLMDF yet.  (Need to pass in an
-- additional argument indicating whether it's an action trigger or a
-- collection trigger in-list.)

/*      INSERT INTO QA_IN_LISTS (
        LIST_ELEM_ID,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LIST_ID,
        PARENT_BLOCK_NAME,
        VALUE,
        VALUE_ID,
        CHAR_ID)
      SELECT
        *** nextval
        SYSDATE,
        X_USER_ID,
        SYSDATE,
        X_USER_ID,
        QPCAT.PLAN_CHAR_ACTION_TRIGGER_ID,
        'QPC_ACTION_TRIGGERS',
        QIL.VALUE,
        QIL.VALUE_ID,
        QIL.CHAR_ID
      FROM
        QA_PLAN_CHAR_ACTION_TRIGGERS QPCAT,
        QA_IN_LISTS QIL
      WHERE QPCAT.PLAN_ID = X_COPY_PLAN_ID
      AND   QPCAT.CHAR_ID = QIL.CHAR_ID
      AND   ????  */

    END insert_plan_chars;



END QLTCPPLB;


/
