--------------------------------------------------------
--  DDL for Package Body QLTAUFLB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QLTAUFLB" AS
/* $Header: qltauflb.plb 120.4.12000000.2 2007/02/20 23:27:48 shkalyan ship $ */

-- Fill in missing elements/actions for an Inspection Plan.
-- 07/31/97
-- Munazza Bukhari

    -- SQL Repository Bug 4958757
    --
    -- The cursors c3 and c7 are identical, they are consolidated
    -- into one c_result_columns to promote code reuse and to avoid
    -- SQL re-parsing.
    --
    -- bso Thu Feb  2 15:27:03 PST 2006
    --

    CURSOR c_result_columns(p_plan_id NUMBER) IS
      SELECT to_number(substr(result_column_name,10)) res_column_name
      FROM   qa_plan_chars
      WHERE  plan_id = p_plan_id AND
             result_column_name like 'CHARACTER%'
      ORDER BY to_number(substr(result_column_name,10));


    -- SQL Repository Bug 4958757
    --
    -- The original cursors c5, c1 and Mobile_Inspection_Elements
    -- are condensed into one single SQL c_plan_chars to promote
    -- code re-use and to avoid re-parsing.
    --
    -- Since a list of char_ids are expected, to avoid literals,
    -- we will be using the qa_performance_temp_pkg package to
    -- keep a list of char_ids temporarily.
    --
    -- The params to the cursor are:
    --
    -- p_from_plan_id NUMBER    The copy-from plan ID
    -- p_to_plan_id NUMBER      The copy-to plan ID
    -- p_char_id_key VARCHAR2   The key to the performance temp table
    --
    -- bso Thu Feb  2 15:02:46 PST 2006
    --
    -- Bug # 3329507. Modifying the cursor to include read_only,
    -- Self Service and Information flags.
    -- saugupta Fri, 26 Dec 2003 04:16:08 -0800 PDT

    CURSOR c_plan_chars(
        p_from_plan_id NUMBER,
        p_to_plan_id NUMBER,
        p_char_id_key VARCHAR2) IS
    SELECT
        qpc.plan_id,
        qpc.char_id,
        qc.name char_name, -- bug 3926150 needs char_name
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
        qpc.default_value_id
    FROM
        qa_plan_chars qpc,
        qa_chars qc
    WHERE
        qpc.plan_id = p_from_plan_id AND
        qpc.char_id IN (
            SELECT id
            FROM   qa_performance_temp
            WHERE  key = p_char_id_key) AND
        qpc.char_id NOT IN (
            SELECT char_id
            FROM   qa_plan_chars
            WHERE  plan_id = p_to_plan_id) AND
        qpc.char_id = qc.char_id
    ORDER BY
        qpc.prompt_sequence;

      --
      -- Bug 3926150 need to add a new out param (X_DISABLED_INDEXED_ELEMENTS).
      -- This proc is called from two places:
      -- QLTPLMDF.QP_TRANSACTIONS_CONTROL various procedures
      -- QASLSET.pld
      --
FUNCTION auto_fill_missing_char (X_PLAN_ID NUMBER,
		X_COPY_PLAN_ID NUMBER,
		X_USER_ID NUMBER,
                X_DISABLED_INDEXED_ELEMENTS OUT NOCOPY VARCHAR2) RETURN NUMBER IS

    --
    -- Bug 3926150 add new local variable.
    -- When defaulting a required element, we should check to
    -- see if the result_column_name assigned clashes with a
    -- function based index.  If so, we will disable the index
    -- and collect the element name here in a comma-separated
    -- list.  Since this whole package is not modular, we need
    -- to do a shortcut by only modifying this auto_fill_missing_char
    -- function because only it contains softcoded elements, namely
    -- 8 (Inspection Results) and 112 (UOM Name).
    --
    -- Because of the small no. of softcoded elements involved,
    -- we will also shortcut by not attempting the default result
    -- column name, and directly move on to just testing for
    -- clashes.  (As oppose to Copy Element (qltcpplb) where we
    -- try to not disturb the index as much as possible.
    --
    -- bso Wed Dec  1 22:07:59 PST 2004
    --
    l_disabled_indexed_elements VARCHAR2(3000);
    l_default_column VARCHAR2(30);
    dummy NUMBER;

    l_key VARCHAR2(30); -- Bug 4958757 Performance Temp Key

    --
    -- Bug# 5739330. This cursor fetches all the trigger rules.
    -- Need only the ones that are missing.
    -- SHKALYAN. 20-Feb-2007.
    --
    /*CURSOR C1 IS
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
      WHERE PLAN_ID = X_COPY_PLAN_ID;*/
--     AND   PLAN_CHAR_ACTION_TRIGGER_ID NOT IN
--                        (SELECT PLAN_CHAR_ACTION_TRIGGER_ID
--                           FROM QA_PLAN_CHAR_ACTION_TRIGGERS
--			    WHERE PLAN_ID = X_PLAN_ID)
--      ORDER BY TRIGGER_SEQUENCE,
--	       PLAN_CHAR_ACTION_TRIGGER_ID;


    --
    -- Bug# 5739330. This cursor fetches only the missing trigger rules
    -- that are neccessary for enabling Inspection Transaction.
    -- SHKALYAN. 20-Feb-2007.
    --
   CURSOR C1 IS
        SELECT a.plan_char_action_trigger_id,
          a.last_update_date,
          a.last_updated_by,
          a.creation_date,
          a.created_by,
          a.trigger_sequence,
          a.plan_id,
          a.char_id,
          a.operator,
          a.low_value_lookup,
          a.high_value_lookup,
          a.low_value_other,
          a.high_value_other,
          a.low_value_other_id,
          a.high_value_other_id
        FROM qa_plan_char_action_triggers a
        WHERE NOT EXISTS
          (SELECT 1
           FROM qa_plan_char_action_triggers b
           WHERE b.plan_id = X_PLAN_ID
           AND a.char_id = b.char_id
           --AND nvl(a.trigger_sequence, 0) = nvl(b.trigger_sequence, 0)
           AND nvl(a.operator, 0) = nvl(b.operator, 0)
           AND nvl(a.low_value_lookup, 0) = nvl(b.low_value_lookup, 0)
           AND nvl(b.low_value_other, 0) = decode(nvl(a.low_value_other, 0),
                                                     'ACCEPT',
                                                     (SELECT DISPLAYED_FIELD
                                                        FROM PO_LOOKUP_CODES
                                                       WHERE LOOKUP_TYPE = 'ERT RESULTS ACTION'
                                                         AND LOOKUP_CODE = a.low_value_other),
                                                     'REJECT',
                                                     (SELECT DISPLAYED_FIELD
                                                      FROM   PO_LOOKUP_CODES
                                                      WHERE  LOOKUP_TYPE = 'ERT RESULTS ACTION'
                                                      AND    LOOKUP_CODE = a.low_value_other),
                                                      nvl(a.low_value_other, 0))
           AND nvl(a.high_value_other, 0) = nvl(b.high_value_other, 0)
           AND nvl(a.high_value_lookup, 0) = nvl(b.high_value_lookup, 0)
           AND nvl(a.low_value_other_id, 0) = nvl(b.low_value_other_id, 0)
           AND nvl(a.high_value_other_id, 0) = nvl(b.high_value_other_id, 0))
        AND a.plan_id = X_COPY_PLAN_ID;

    CURSOR CS1 IS
      SELECT QA_PLAN_CHAR_ACTION_TRIGGERS_S.NEXTVAL FROM DUAL;

    ACTION_TRIGGER_ID NUMBER;

    QPCAT	C1%ROWTYPE;

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
	STATUS_ID,
	ALR_ACTION_ID,
	ALR_ACTION_SET_ID,
	ASSIGNED_CHAR_ID,
	ASSIGN_TYPE
      FROM QA_PLAN_CHAR_ACTIONS
      WHERE PLAN_CHAR_ACTION_TRIGGER_ID = QPCAT.PLAN_CHAR_ACTION_TRIGGER_ID
      ORDER BY PLAN_CHAR_ACTION_ID;

    QPCA	C2%ROWTYPE;

    CURSOR CS2 IS
      SELECT QA_PLAN_CHAR_ACTIONS_S.NEXTVAL FROM DUAL;

    QPC_ACTION_ID	NUMBER;

    --
    -- Bug# 5739330. Added the cursor C8 and C9. C8 fetches
    -- plan_char_action_trigger_ids from the template plan and the
    -- corresponding plan which needs the required actions. This is
    -- the driving cursor which faciliates cursor C9 to get the missing actions
    -- for the particular plan_char_action_trigger_id
    -- SHKALYAN. 20-Feb-2007.
    --
   CURSOR C8 IS
        SELECT a.plan_char_action_trigger_id temp_action_trigger_id,
               b.plan_char_action_trigger_id action_trigger_id
          FROM qa_plan_char_action_triggers a, qa_plan_char_action_triggers b
         WHERE a.char_id = b.char_id
           AND nvl(a.operator, 0) = nvl(b.operator, 0)
           AND nvl(a.low_value_lookup, 0) = nvl(b.low_value_lookup, 0)
           AND nvl(b.low_value_other, 0) = decode(nvl(a.low_value_other, 0),
                                                     'ACCEPT',
                                                     (SELECT DISPLAYED_FIELD
                                                        FROM PO_LOOKUP_CODES
                                                       WHERE LOOKUP_TYPE = 'ERT RESULTS ACTION'
                                                         AND LOOKUP_CODE = a.low_value_other),
                                                     'REJECT',
                                                     (SELECT DISPLAYED_FIELD
                                                      FROM   PO_LOOKUP_CODES
                                                      WHERE  LOOKUP_TYPE = 'ERT RESULTS ACTION'
                                                      AND    LOOKUP_CODE = a.low_value_other),
                                                      nvl(a.low_value_other, 0))
           AND nvl(a.high_value_other, 0) = nvl(b.high_value_other, 0)
           AND nvl(a.high_value_lookup, 0) = nvl(b.high_value_lookup, 0)
           AND nvl(a.low_value_other_id, 0) = nvl(b.low_value_other_id, 0)
           AND nvl(a.high_value_other_id, 0) = nvl(b.high_value_other_id, 0)
           AND b.plan_id = X_PLAN_ID
           AND a.plan_id = X_COPY_PLAN_ID;

    QPCAT_TEMP   C8%ROWTYPE;

    CURSOR C9 IS
         SELECT ACTION_ID,
                CAR_NAME_PREFIX,
                CAR_TYPE_ID,
                CAR_OWNER,
                MESSAGE,
                STATUS_CODE,
                STATUS_ID,
                ALR_ACTION_ID,
                ALR_ACTION_SET_ID,
                ASSIGNED_CHAR_ID,
                ASSIGN_TYPE
         FROM qa_plan_char_actions a,
              qa_plan_char_action_triggers c
         WHERE NOT EXISTS
           (SELECT 1
              FROM qa_plan_char_actions b,
                   qa_plan_char_action_triggers d
             WHERE nvl(a.action_id, 0) = nvl(b.action_id, 0)
               AND nvl(a.car_name_prefix, 0) = nvl(b.car_name_prefix, 0)
               AND nvl(a.car_type_id, 0) = nvl(b.car_type_id, 0)
               AND nvl(a.car_owner, 0) = nvl(b.car_owner, 0)
               AND nvl(a.message, 0) = nvl(b.message, 0)
               AND nvl(a.status_code, 0) = nvl(b.status_code, 0)
               AND nvl(a.alr_action_id, 0) = nvl(b.alr_action_id, 0)
               AND nvl(a.alr_action_set_id, 0) = nvl(b.alr_action_set_id, 0)
               AND nvl(a.assigned_char_id, 0) = nvl(b.assigned_char_id, 0)
               AND nvl(a.assign_type, 0) = nvl(b.assign_type, 0)
               AND d.plan_id = x_plan_id
               AND b.plan_char_action_trigger_id = d.plan_char_action_trigger_id
               AND b.plan_char_action_trigger_id = qpcat_temp.action_trigger_id)
           AND a.plan_char_action_trigger_id = c.plan_char_action_trigger_id
           AND c.plan_char_action_trigger_id = qpcat_temp.temp_action_trigger_id
           AND c.plan_id = x_copy_plan_id;

      QPCA_TEMP   C9%ROWTYPE;


      -- Bug 4958757.  SQL Repository Fix SQL ID: 15008068
      -- The cursor c5 is completed removed and replaced by
      -- a generic package level c_plan_chars cursor.
      -- bso Thu Feb  2 15:04:35 PST 2006

      QPCV	c_plan_chars%ROWTYPE;

 -- Bug 4958757.  SQL Repository Fix SQL ID: 15008087
 -- Cursor Mobile_Inspection_Elements completely removed
 -- and replaced by a generic c_plan_chars cursor.
 -- bso Thu Feb  2 15:02:19 PST 2006

      MIE	c_plan_chars%ROWTYPE;

      -- Bug 4958757.  SQL Repository Fix SQL ID: 15008119
      -- The cursor c7 has been extracted to package level as
      -- c_result_columns.

      TYPE column_num IS TABLE of BOOLEAN
	INDEX BY BINARY_INTEGER;

      res_columns column_num;
      i binary_integer;

      COLUMN_NAME	VARCHAR2(30);
      COLUMN_NUMBER	NUMBER;
      NEW_RESULT_COLUMN_NAME VARCHAR2(30);

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
	X_USER_ID,
	DESCRIPTION,
	SHORT_CODE_ID
      FROM QA_PLAN_CHAR_VALUE_LOOKUPS
      WHERE PLAN_ID = X_COPY_PLAN_ID
      AND CHAR_ID NOT IN (SELECT CHAR_ID FROM QA_PLAN_CHARS
			  WHERE PLAN_ID = X_PLAN_ID);

    --
    -- Bug# 5739330. These statements delete only the actions 25 and 26 and
    -- then the parent trigger. The parent trigger should not be deleted
    -- since there can be other actions associated to it which will get orphaned
    -- SHKALYAN. 20-Feb-2007.
    --

    /*DELETE FROM qa_plan_char_actions
      WHERE  action_id in (25, 26)
      AND    plan_char_action_trigger_id IN
                 (SELECT plan_char_action_trigger_id
                  FROM   qa_plan_char_action_triggers
                  WHERE  plan_id = X_Plan_id
                  AND    char_id = 8
                  AND    low_value_other IN
                              (SELECT displayed_field
                                 FROM po_lookup_codes
                                WHERE lookup_type='ERT RESULTS ACTION'));

      DELETE FROM qa_plan_char_action_triggers
      WHERE plan_id = X_Plan_id
      AND   char_id = 8
      AND   low_value_other IN
                 (SELECT displayed_field
                    FROM po_lookup_codes
                   WHERE lookup_type='ERT RESULTS ACTION');*/

      --
      -- Bug# 5739330.
      -- Added this part of code to insert the missing actions fetched
      -- from cursor C9 and inserting it into QA_PLAN_CHAR_ACTIONS
      -- The C8 cursor gets the action_triggers which are already present
      -- in the plan and it is used for getting the actions in C9
      -- SHKALYAN. 20-Feb-2007.
      --
      OPEN C8;
      LOOP
         FETCH C8 INTO QPCAT_TEMP;
         EXIT WHEN C8%NOTFOUND;

         OPEN C9;
         LOOP
            FETCH C9 INTO QPCA_TEMP;
            EXIT WHEN C9%NOTFOUND;

            OPEN CS2;
            FETCH CS2 INTO QPC_ACTION_ID;
            CLOSE CS2;

            INSERT INTO QA_PLAN_CHAR_ACTIONS
                 (PLAN_CHAR_ACTION_ID,
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
                  STATUS_ID,
                  ASSIGNED_CHAR_ID,
                  ASSIGN_TYPE)
             VALUES
                  (QPC_ACTION_ID,
                   SYSDATE,
                   X_USER_ID,
                   SYSDATE,
                   X_USER_ID,
                   QPCAT_TEMP.ACTION_TRIGGER_ID,
                   QPCA_TEMP.ACTION_ID,
                   QPCA_TEMP.CAR_NAME_PREFIX,
                   QPCA_TEMP.CAR_TYPE_ID,
                   QPCA_TEMP.CAR_OWNER,
                   QPCA_TEMP.MESSAGE,
                   QPCA_TEMP.STATUS_CODE,
                   QPCA_TEMP.STATUS_ID,
                   QPCA_TEMP.ASSIGNED_CHAR_ID,
                   QPCA_TEMP.ASSIGN_TYPE);

         END LOOP;
         CLOSE C9;

      END LOOP;
      CLOSE C8;

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
	    STATUS_ID,
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
	    QPCA.STATUS_ID,
	    QPCA.ASSIGNED_CHAR_ID,
	    QPCA.ASSIGN_TYPE
	  );

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

      OPEN c_result_columns(x_plan_id);
      LOOP
	FETCH c_result_columns INTO i;
	EXIT WHEN c_result_columns%NOTFOUND;

  	res_columns(i) := TRUE;
      END LOOP;
      CLOSE c_result_columns;

      i := 1;

      -- This branching was put in to enforce the transaction
      -- requirement for mobile inspection transactions.

      IF (x_copy_plan_id = 58) THEN

          -- Bug 4958757 SQL Repository tuning.
          l_key := 'QLTAUFLB.C_MOBILE_INSPECT';
          qa_performance_temp_pkg.purge_and_add_ids(
              p_key => l_key,
              p_id_list => qa_ss_const.QUANTITY || ',' ||
                           qa_ss_const.INSPECTION_RESULT || ',' ||
                           qa_ss_const.ITEM || ',' ||
                           qa_ss_const.UOM);

          OPEN c_plan_chars(x_copy_plan_id, x_plan_id, l_key);
          LOOP

          FETCH c_plan_chars INTO MIE;
	  EXIT WHEN c_plan_chars%NOTFOUND;

	  IF MIE.HARDCODED_COLUMN IS NOT NULL THEN
	      NEW_RESULT_COLUMN_NAME := MIE.HARDCODED_COLUMN;
	  ELSE
	      -- Find the first available column number
  	      WHILE ((res_columns(i) = TRUE) AND (i <=
                  QLTNINRB.RES_CHAR_COLUMNS)) LOOP
		  i := i + 1;
	      END LOOP;

	      IF i > QLTNINRB.RES_CHAR_COLUMNS THEN
	          -- Exceeded upper limit of maximum number of chars.
                  -- Error out.
                  FND_MESSAGE.SET_NAME('QA', 'QA_EXCEEDED_COLUMN_COUNT');
	          APP_EXCEPTION.RAISE_EXCEPTION;
              END IF;

	      NEW_RESULT_COLUMN_NAME := 'CHARACTER' || TO_CHAR(i);

              --
              -- Bug 3926150.  Check if index is enabled and this
              -- assignment disrupts the index or not.
              --
              l_default_column :=
                  qa_char_indexes_pkg.get_default_result_column(mie.char_id);
              IF l_default_column IS NOT NULL AND
                 l_default_column <> new_result_column_name THEN
                 --
                 -- Need to warn user because we can't reuse the index.
                 --
                 l_disabled_indexed_elements :=
                     l_disabled_indexed_elements || ', ' || mie.char_name;
                 dummy := qa_char_indexes_pkg.disable_index(mie.char_id);
              END IF;

	      res_columns(i) := TRUE;
	      i := i + 1;
          END IF;

	  NEW_PROMPT_SEQUENCE := NEW_PROMPT_SEQUENCE + 10;

          -- Bug # 3329507. Modifying the query to include read_only,
          -- Self Service and Information flags.
          -- saugupta Fri, 26 Dec 2003 04:16:08 -0800 PDT

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
	      default_value_id)
          VALUES (
	      X_PLAN_ID,
	      MIE.CHAR_ID,
	      SYSDATE,
	      X_USER_ID,
	      SYSDATE,
	      X_USER_ID,
	      NEW_PROMPT_SEQUENCE,
	      MIE.PROMPT,
	      MIE.ENABLED_FLAG,
	      MIE.MANDATORY_FLAG,
          MIE.READ_ONLY_FLAG,
          MIE.SS_POPLIST_FLAG,
          MIE.INFORMATION_FLAG,
	      MIE.DEFAULT_VALUE,
	      NEW_RESULT_COLUMN_NAME,
	      MIE.VALUES_EXIST_FLAG,
	      MIE.DISPLAYED_FLAG,
	      MIE.ATTRIBUTE_CATEGORY,
	      MIE.ATTRIBUTE1,
	      MIE.ATTRIBUTE2,
	      MIE.ATTRIBUTE3,
	      MIE.ATTRIBUTE4,
	      MIE.ATTRIBUTE5,
	      MIE.ATTRIBUTE6,
	      MIE.ATTRIBUTE7,
	      MIE.ATTRIBUTE8,
	      MIE.ATTRIBUTE9,
	      MIE.ATTRIBUTE10,
	      MIE.ATTRIBUTE11,
	      MIE.ATTRIBUTE12,
	      MIE.ATTRIBUTE13,
	      MIE.ATTRIBUTE14,
	      MIE.ATTRIBUTE15,
	      MIE.DEFAULT_VALUE_ID);

          END LOOP;
          CLOSE c_plan_chars;

          --
          -- Bug 3926150
          -- Pass back the disabled index names.  (use substr to get rid of
          -- the lead comma and space.
          --
          IF l_disabled_indexed_elements IS NOT NULL THEN
              x_disabled_indexed_elements := substr(l_disabled_indexed_elements, 3);
          END IF;

          IF NEW_PROMPT_SEQUENCE > 0 THEN
              RETURN(NEW_PROMPT_SEQUENCE + 10);
          ELSE
              RETURN(NEW_PROMPT_SEQUENCE );
          END IF;

      ELSE

          -- Bug 4958757 SQL Repository tuning.
          l_key := 'QLTAUFLB.C5';
          qa_performance_temp_pkg.purge_and_add_ids(
              p_key => l_key,
              p_id_list => qa_ss_const.TRANSACTION_DATE || ',' ||
                           qa_ss_const.QUANTITY || ',' ||
                           qa_ss_const.INSPECTION_RESULT || ',' ||
                           qa_ss_const.UOM_NAME);

          OPEN c_plan_chars(x_copy_plan_id, x_plan_id, l_key);
          LOOP

          FETCH c_plan_chars INTO QPCV;
	  EXIT WHEN c_plan_chars%NOTFOUND;

	  IF QPCV.HARDCODED_COLUMN IS NOT NULL THEN
	      NEW_RESULT_COLUMN_NAME := QPCV.HARDCODED_COLUMN;
	  ELSE
	      -- Find the first available column number
  	      WHILE ((res_columns(i) = TRUE) AND (i <=
                  QLTNINRB.RES_CHAR_COLUMNS)) LOOP
		  i := i + 1;
	      END LOOP;

	      IF i > QLTNINRB.RES_CHAR_COLUMNS THEN
	          -- Exceeded upper limit of maximum number of chars.
                  -- Error out.
                  FND_MESSAGE.SET_NAME('QA', 'QA_EXCEEDED_COLUMN_COUNT');
	          APP_EXCEPTION.RAISE_EXCEPTION;
              END IF;

	      NEW_RESULT_COLUMN_NAME := 'CHARACTER' || TO_CHAR(i);

              --
              -- Bug 3926150.  Check if index is enabled and this
              -- assignment disrupts the index or not.
              --
              l_default_column :=
                  qa_char_indexes_pkg.get_default_result_column(qpcv.char_id);
              IF l_default_column IS NOT NULL AND
                 l_default_column <> new_result_column_name THEN
                 --
                 -- Need to warn user because we can't reuse the index.
                 --
                 l_disabled_indexed_elements :=
                     l_disabled_indexed_elements || ', ' || qpcv.char_name;
                 dummy := qa_char_indexes_pkg.disable_index(qpcv.char_id);
              END IF;

	      res_columns(i) := TRUE;
	      i := i + 1;
          END IF;

	  NEW_PROMPT_SEQUENCE := NEW_PROMPT_SEQUENCE + 10;

          -- Bug # 3329507. Modifying the query to include read_only,
          -- Self Service and Information flags.
          -- saugupta Fri, 26 Dec 2003 04:16:08 -0800 PDT

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
	      default_value_id)
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
	      QPCV.DEFAULT_VALUE_ID);

          END LOOP;
          CLOSE c_plan_chars;

          --
          -- Bug 3926150
          -- Pass back the disabled index names.  (use substr to get rid of
          -- the lead comma and space.
          --
          IF l_disabled_indexed_elements IS NOT NULL THEN
              x_disabled_indexed_elements := substr(l_disabled_indexed_elements, 3);
          END IF;

          IF NEW_PROMPT_SEQUENCE > 0 THEN
              RETURN(NEW_PROMPT_SEQUENCE + 10);
          ELSE
              RETURN(NEW_PROMPT_SEQUENCE );
          END IF;

      END IF;

END auto_fill_missing_char;


FUNCTION add_ss_elements (p_plan_id NUMBER, p_user_id IN NUMBER)
    RETURN NUMBER IS

    -- Bug # 3329507. Modifying the cursor to include read_only,
    -- Self Service and Information flags.
    -- saugupta Fri, 26 Dec 2003 04:16:08 -0800 PDT

    -- Bug 4958757.  SQL Repository Fix SQL ID: 15008297
    -- Cursor c1 completely removed and replaced by a
    -- generic c_plan_chars cursor.
    -- bso Thu Feb  2 15:03:41 PST 2006

    CURSOR c2 IS
        SELECT MAX(prompt_sequence) FROM qa_plan_chars
	WHERE plan_id = p_plan_id;

    -- Bug 4958757.  SQL Repository Fix SQL ID: 15008349
    -- The cursor c3 has been extracted to package level as
    -- c_result_columns.

    TYPE column_num IS TABLE of BOOLEAN INDEX BY BINARY_INTEGER;

    res_columns 		column_num;
    i 				BINARY_INTEGER;
    qpcv			c_plan_chars%ROWTYPE;
    column_name 		VARCHAR2(30);
    column_number		NUMBER;
    new_result_column_name 	VARCHAR2(30);
    new_prompt_sequence 	NUMBER;

    l_key VARCHAR2(30); -- Bug 4958757 Performance Temp Key

BEGIN

    OPEN c2;
    FETCH c2 INTO new_prompt_sequence;
    CLOSE c2;

    IF new_prompt_sequence IS NULL THEN
	new_prompt_sequence := 0;
    END IF;

    FOR i IN 1..qltninrb.res_char_columns LOOP
	res_columns(i) := FALSE;
    END LOOP;

    OPEN c_result_columns(p_plan_id);
    LOOP
	FETCH c_result_columns INTO i;
	EXIT WHEN c_result_columns%NOTFOUND;
  	res_columns(i) := TRUE;
    END LOOP;
    CLOSE c_result_columns;

    i := 1;

    -- Bug 4958757 SQL Repository tuning.
    l_key := 'QLTAUFLB.C1';
    qa_performance_temp_pkg.purge_and_add_ids(
        p_key => l_key,
        p_id_list => qa_ss_const.VENDOR_NAME || ',' ||
                     qa_ss_const.PO_NUMBER);

    OPEN c_plan_chars(7, p_plan_id, l_key); -- 7 is OSP Template Plan ID.
    LOOP
        FETCH c_plan_chars INTO qpcv;
	EXIT WHEN c_plan_chars%NOTFOUND;

	IF qpcv.hardcoded_column IS NOT NULL THEN
	  new_result_column_name := qpcv.hardcoded_column;
	ELSE
	    -- Find the first available column number
  	    WHILE ((res_columns(i) = TRUE) AND(i <= qltninrb.res_char_columns))
 	    LOOP
		i := i + 1;
	    END LOOP;

	    IF i > qltninrb.res_char_columns THEN
	        -- Exceeded upper limit of maximum number of chars.  Error out.
                FND_MESSAGE.SET_NAME('QA', 'QA_EXCEEDED_COLUMN_COUNT');
	        APP_EXCEPTION.RAISE_EXCEPTION;
            END IF;

	    new_result_column_name := 'CHARACTER' || TO_CHAR(i);
	    res_columns(i) := TRUE;
	    i := i + 1;
        END IF;

	new_prompt_sequence := new_prompt_sequence + 10;

        -- Bug # 3329507. Modifying the query to include read_only,
        -- Self Service and Information flags.
        -- saugupta Fri, 26 Dec 2003 04:16:08 -0800 PDT

        INSERT INTO qa_plan_chars(
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
	    default_value_id)
	VALUES (
	    p_plan_id,
	    qpcv.char_id,
	    SYSDATE,
	    p_user_id,
	    SYSDATE,
	    p_user_id,
	    new_prompt_sequence,
	    qpcv.prompt,
	    qpcv.enabled_flag,
	    qpcv.mandatory_flag,
        qpcv.read_only_flag,
        qpcv.ss_poplist_flag,
        qpcv.information_flag,
	    qpcv.default_value,
	    new_result_column_name,
	    qpcv.values_exist_flag,
	    qpcv.displayed_flag,
	    qpcv.attribute_category,
	    qpcv.attribute1,
	    qpcv.attribute2,
	    qpcv.attribute3,
	    qpcv.attribute4,
	    qpcv.attribute5,
	    qpcv.attribute6,
	    qpcv.attribute7,
	    qpcv.attribute8,
	    qpcv.attribute9,
	    qpcv.attribute10,
	    qpcv.attribute11,
	    qpcv.attribute12,
	    qpcv.attribute13,
	    qpcv.attribute14,
	    qpcv.attribute15,
	    qpcv.default_value_id);

    END LOOP;
    CLOSE c_plan_chars;

    IF new_prompt_sequence > 0 THEN
        RETURN(new_prompt_sequence + 10);
    ELSE
        RETURN(new_prompt_sequence );
    END IF;

END add_ss_elements;

PROCEDURE add_work_req_elements (p_plan_id IN NUMBER, p_user_id IN NUMBER) IS

-- Bug 2368425: The procedure adds mandatory collection elements
-- Asset Group and Asset Number to the Collection Plan
-- when Action 'Create a work request' is assigned to the plan.
-- If both the collection Elements are already present in the plan
-- then this procedure will not be called.
-- This is called from post-forms-commit trigger in QLTPLMDF.fmb
-- suramasw Fri Jun 21 00:42:03 PDT 2002

  l_new_prompt_sequence  NUMBER;
  l_asset_group_char_id  CONSTANT NUMBER := 162;
  l_asset_number_char_id CONSTANT NUMBER := 163;

  -- The following cursor is to find the Max value of Prompt Sequence.

  CURSOR prompt_cur IS
    SELECT MAX(prompt_sequence) FROM qa_plan_chars
    WHERE plan_id = p_plan_id;

  -- The following cursor is to find the hardcoded values of the two collection
  -- elements Asset Group and Asset Number.

  CURSOR element_cur IS
    SELECT char_id,prompt,hardcoded_column
    FROM qa_chars
    WHERE char_id IN (l_asset_group_char_id,l_asset_number_char_id);

  BEGIN
    -- finding out the max value of the prompt
    OPEN prompt_cur;
    FETCH prompt_cur INTO l_new_prompt_sequence;
    CLOSE prompt_cur;

    IF l_new_prompt_sequence IS NULL THEN
        l_new_prompt_sequence := 0;
    END IF;

    -- If any one of the collection Elements Asset Group or Asset Number
    -- is present in the Collection plan it is deleted. The deleted Element
    -- will be added with the missing element in the following Insert statement.

    DELETE FROM qa_plan_chars
    WHERE plan_id = p_plan_id
    AND char_id IN (l_asset_group_char_id,l_asset_number_char_id);

    FOR i IN element_cur LOOP
      l_new_prompt_sequence := l_new_prompt_sequence + 10;

      -- The following Insert statement is to add both the mandatory
      -- Collection Elements for the action.

      -- Bug # 3329507. Modifying the query to include read_only,
      -- Self Service and Information flags.
      -- saugupta Fri, 26 Dec 2003 04:16:08 -0800 PDT

      INSERT INTO qa_plan_chars(
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
            result_column_name,
            values_exist_flag,
            displayed_flag,
            read_only_flag,
            ss_poplist_flag,
            information_flag)
        VALUES (
            p_plan_id,
            i.char_id,
            SYSDATE,
            p_user_id,
            SYSDATE,
            p_user_id,
            l_new_prompt_sequence,
            i.prompt,
            1,
            1,
            i.hardcoded_column,
            2,
            1,
            2,
            2,
            2);
    END LOOP;
 END add_work_req_elements;

  -- Bug 3517598. If lot/serial number is present in plan
  -- add LPN automatically. Function to add LPN automatically.
  -- Returns the next sequence number.

FUNCTION auto_fill_lpn (X_PLAN_ID NUMBER,
				  X_USER_ID NUMBER
				  ) RETURN NUMBER IS
CURSOR prompt_cur IS
    SELECT MAX(prompt_sequence) FROM qa_plan_chars
    WHERE plan_id = x_plan_id;

  -- Cursor to find the hardcoded values of the LPN

  CURSOR lpn_cur IS
    SELECT char_id cid,prompt pro,hardcoded_column hc
    FROM qa_chars
    WHERE char_id = 150;

PROMPT_SEQ NUMBER;
LPN_REC lpn_cur%ROWTYPE;

BEGIN

  OPEN prompt_cur;
  FETCH prompt_cur into PROMPT_SEQ;
  CLOSE prompt_cur;

  OPEN lpn_cur;
  FETCH lpn_cur INTO LPN_REC;
  CLOSE lpn_cur;


INSERT INTO qa_plan_chars(
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
            result_column_name,
            values_exist_flag,
            displayed_flag,
            read_only_flag,
            ss_poplist_flag,
            information_flag)
        VALUES (
            x_plan_id,
            LPN_REC.cid,
            SYSDATE,
            x_user_id,
            SYSDATE,
            x_user_id,
            PROMPT_SEQ +10,
            LPN_REC.pro,
            1,
            2,
            LPN_REC.hc,
            2,
            1,
            2,
            2,
            2);

RETURN (PROMPT_SEQ + 20);

END auto_fill_lpn;

   -- Bug 5147965 ksiddhar EAM Transaction Dependency Check
FUNCTION auto_fill_missing_char_eam (X_PLAN_ID NUMBER,
		X_COPY_PLAN_ID NUMBER,
		X_USER_ID NUMBER
                 ) RETURN NUMBER IS
CURSOR prompt_cur IS
    SELECT MAX(prompt_sequence) FROM qa_plan_chars
    WHERE plan_id = X_PLAN_ID;

  -- Cursor to find the hardcoded values of the eam

  CURSOR eam_cur IS
    SELECT char_id cid,prompt pro,hardcoded_column hc,enabled_flag,
    mandatory_flag
    FROM qa_chars
    WHERE char_id in (SELECT char_id
    FROM
    qa_plan_chars qpc1
    WHERE plan_id=X_COPY_PLAN_ID
    AND enabled_flag =1
    and not exists
    ( select 1
    from
    qa_plan_chars qpc2
    where qpc2.plan_id=X_PLAN_ID
    and qpc2.char_id = qpc1.char_id)
    )
    AND enabled_flag =1;


PROMPT_SEQ NUMBER;

BEGIN

  OPEN prompt_cur;
  FETCH prompt_cur into PROMPT_SEQ;
  CLOSE prompt_cur;

    IF PROMPT_SEQ IS NULL THEN
        PROMPT_SEQ := 0;
    END IF;

FOR i IN eam_cur LOOP
      PROMPT_SEQ := PROMPT_SEQ + 10;

INSERT INTO qa_plan_chars(
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
            result_column_name,
            values_exist_flag,
            displayed_flag,
            read_only_flag,
            ss_poplist_flag,
            information_flag)
        VALUES (
            x_plan_id,
            i.cid,
            SYSDATE,
            x_user_id,
            SYSDATE,
            x_user_id,
            PROMPT_SEQ,
            i.pro,
            i.enabled_flag,
            i.mandatory_flag,
            i.hc,
            2,
            1,
            2,
            2,
            2);

 END LOOP;
RETURN (PROMPT_SEQ + 10);

END auto_fill_missing_char_eam;
   -- Bug 5147965 ksiddhar EAM Transaction Dependency Check
END QLTAUFLB;

/
