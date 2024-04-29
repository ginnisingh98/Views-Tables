--------------------------------------------------------
--  DDL for Package Body QLTCPDFB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QLTCPDFB" as
/* $Header: qltcpdfb.plb 115.4 2003/08/25 18:59:54 ksoh ship $ */

-- Copy Defaults
--
-- Called by QLTPLMDF form (Quality Plan Workbench) to copy default
-- values, action triggers, and actions from qa_char_value_lookups,
-- qa_char_action_triggers, and qa_char_actions into qa_plan_char_xxxx
-- tables.

-- dmaggard 110.17/94 created.


  PROCEDURE Insert_Rows (
                        X_Copy_Values                   NUMBER,
                        X_Copy_Actions                  NUMBER,
                        X_Plan_Id                       NUMBER,
                        X_Char_Id                       NUMBER,
                        X_Last_Update_Date              DATE,
                        X_Last_Updated_By               NUMBER,
                        X_Creation_Date                 DATE,
                        X_Created_By                    NUMBER,
                        X_Last_Update_Login             NUMBER DEFAULT NULL,
                        X_values_found          IN OUT  NOCOPY NUMBER,
                        X_actions_found         IN OUT  NOCOPY NUMBER
   ) IS
    X_qa_app_id   NUMBER	:= 250;
    X_qa_alert_id NUMBER	:= 10177;

    CURSOR C1 IS
      SELECT
	CHAR_ACTION_TRIGGER_ID,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	CREATION_DATE,
	CREATED_BY,
	TRIGGER_SEQUENCE,
	CHAR_ID,
	OPERATOR,
	LOW_VALUE_LOOKUP,
	HIGH_VALUE_LOOKUP,
	LOW_VALUE_OTHER,
	HIGH_VALUE_OTHER,
	LOW_VALUE_OTHER_ID,
	HIGH_VALUE_OTHER_ID
      FROM QA_CHAR_ACTION_TRIGGERS
      WHERE CHAR_ID = X_Char_Id
      ORDER BY TRIGGER_SEQUENCE,
	       CHAR_ACTION_TRIGGER_ID;

    QCAT	C1%ROWTYPE;

    CURSOR CS1 IS
      SELECT QA_PLAN_CHAR_ACTION_TRIGGERS_S.NEXTVAL FROM DUAL;

    ACTION_TRIGGER_ID NUMBER;

    CURSOR C2 IS
      SELECT
	CHAR_ACTION_ID,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	CREATION_DATE,
	CREATED_BY,
	CHAR_ACTION_TRIGGER_ID,
	ACTION_ID,
	CAR_NAME_PREFIX,
	CAR_TYPE_ID,
	CAR_OWNER,
	MESSAGE,
	STATUS_CODE,
	STATUS_ID,
	ALR_ACTION_ID,
	ALR_ACTION_SET_ID
      FROM QA_CHAR_ACTIONS
      WHERE CHAR_ACTION_TRIGGER_ID = QCAT.CHAR_ACTION_TRIGGER_ID;

    QCA		C2%ROWTYPE;

    CURSOR CS2 IS
      SELECT QA_PLAN_CHAR_ACTIONS_S.NEXTVAL FROM DUAL;

    QPC_ACTION_ID	NUMBER;

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
      WHERE APPLICATION_ID = X_qa_app_id
      AND ACTION_ID = QCA.ALR_ACTION_ID;

      ALRA	C3%ROWTYPE;

    CURSOR CS3 IS
      SELECT
 	ALR_ACTIONS_S.NEXTVAL,
	ALR_ACTION_SETS_S.NEXTVAL,
       	ALR_ACTION_SET_MEMBERS_S.NEXTVAL,
	QA_ALR_ACTION_NAME_S.NEXTVAL,
        QA_ALR_ACTION_SET_NAME_S.NEXTVAL
      FROM DUAL;

      NEW_ACTION_ID	NUMBER;
      NEW_ACTION_SET_ID	NUMBER;
      NEW_ACTION_SET_MEMBER_ID	NUMBER;

      ACTION_SET_SEQUENCE NUMBER;
      ACTION_SET_MEMBERS_SEQUENCE NUMBER;

      X_ACTION_NAME NUMBER;
      X_ACTION_SET_NAME NUMBER;
      NEW_ACTION_NAME VARCHAR2(80);
      NEW_ACTION_SET_NAME VARCHAR2(50);

    CURSOR C4 IS
      SELECT
	CHAR_ACTION_ID,
	CHAR_ID,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	CREATION_DATE,
	CREATED_BY,
	LAST_UPDATE_LOGIN,
	TOKEN_NAME
      FROM QA_CHAR_ACTION_OUTPUTS
      WHERE CHAR_ACTION_ID = QCA.CHAR_ACTION_ID;

      QCAO	C4%ROWTYPE;

    BEGIN

      -- Initialize "found" flags

	X_values_found := 2;	 /* no */
	X_actions_found := 2;	 /* no */


-- DEFAULT VALUES

	if (X_Copy_Values = 1) then

  --	Delete values

	  DELETE FROM qa_plan_char_value_lookups
	  WHERE   plan_id = X_Plan_Id and
		  char_id = X_Char_Id;

  --	Insert values

	  INSERT INTO qa_plan_char_value_lookups
	      (
 		PLAN_ID,
 		CHAR_ID,
 		SHORT_CODE,
 		LAST_UPDATE_DATE,
 		LAST_UPDATED_BY,
 		CREATION_DATE,
 		CREATED_BY,
 		LAST_UPDATE_LOGIN,
 		DESCRIPTION
	      )
	    SELECT	X_Plan_Id,
			char_id,
			short_code,
               		X_Last_Update_Date,
               		X_Last_Updated_By,
               		X_Creation_Date,
               		X_Created_By,
               		X_Last_Update_Login,
			description
	    FROM qa_char_value_lookups
	    WHERE char_id = X_Char_Id;

	    if (SQL%ROWCOUNT > 0) then
	      X_values_found := 1;	/* yes */
	    end if;

	end if;


-- DEFAULT ACTIONS

	if (X_Copy_Actions = 1) then

  --	Delete existing alr_actions
  -- Bug 3111310.  Rewrite WHERE...EXIST query
  -- to improve performance
  -- ksoh Fri Aug 22 11:05:00 PST 2003
  --
   	  DELETE FROM ALR_ACTIONS aa
          WHERE aa.application_id = X_qa_app_id
          AND aa.alert_id = X_qa_alert_id
          AND aa.action_id in
     		(SELECT  qpcav.alr_action_id
      		FROM qa_plan_char_actions_v qpcav
      		WHERE PLAN_ID = X_PLAN_ID
      		AND CHAR_ID   = X_CHAR_ID);

  --	Delete existing alr_action_sets

   	  DELETE FROM ALR_ACTION_SETS aas
          WHERE aas.application_id = X_qa_app_id
          AND aas.alert_id = X_qa_alert_id
          AND aas.action_set_id in
     		(SELECT qpcav.alr_action_set_id
      		FROM qa_plan_char_actions_v qpcav
      		WHERE PLAN_ID = X_PLAN_ID
      		AND CHAR_ID   = X_CHAR_ID);

  --	Delete existing alr_action_set_members

   	  DELETE FROM ALR_ACTION_SET_MEMBERS aasm
          WHERE aasm.application_id = X_qa_app_id
      	  AND aasm.alert_id = X_qa_alert_id
          AND aasm.action_set_id in
     		(SELECT qpcav.alr_action_set_id
      		FROM qa_plan_char_actions_v qpcav
      		WHERE PLAN_ID = X_PLAN_ID
      		AND CHAR_ID   = X_CHAR_ID);

  --	Delete existing action triggers

	  DELETE FROM qa_plan_char_action_triggers
	  WHERE   plan_id = X_Plan_Id and
		  char_id = X_Char_Id;

  --	Delete existing qa_plan_char_actions

	  DELETE FROM qa_plan_char_actions
	  WHERE  plan_char_action_trigger_id IN
	     (SELECT plan_char_action_trigger_id
              FROM qa_plan_char_action_triggers
              WHERE plan_id = X_Plan_Id
		and char_id = X_Char_Id);

  --	Insert new action triggers
  -- 	Insert qa_plan_char_actions
  --    Insert alr_actions
  --    Insert alr_action_sets
  --    Insert alr_action_set_members
  --    Insert qa_plan_char_action_outputs

      OPEN C1;
      LOOP
	FETCH C1 INTO QCAT;
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
	  X_Last_Update_Date,
	  X_Last_Updated_By,
	  X_Creation_Date,
	  X_Created_By,
	  QCAT.TRIGGER_SEQUENCE,
	  X_Plan_Id,
	  QCAT.CHAR_ID,
	  QCAT.OPERATOR,
	  QCAT.LOW_VALUE_LOOKUP,
	  QCAT.HIGH_VALUE_LOOKUP,
	  QCAT.LOW_VALUE_OTHER,
	  QCAT.HIGH_VALUE_OTHER,
	  QCAT.LOW_VALUE_OTHER_ID,
	  QCAT.HIGH_VALUE_OTHER_ID);

	  if (X_actions_found = 2) and (SQL%ROWCOUNT > 0) then
 	    X_actions_found := 1;	/* yes */
	  end if;

          OPEN C2;
	  LOOP

	    FETCH C2 INTO QCA;
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
	    STATUS_ID,
	    ALR_ACTION_ID,
	    ALR_ACTION_SET_ID)
          VALUES (
	    QPC_ACTION_ID,
	    X_Last_Update_Date,
	    X_Last_Updated_By,
	    X_Creation_Date,
	    X_Created_By,
	    ACTION_TRIGGER_ID,
	    QCA.ACTION_ID,
	    QCA.CAR_NAME_PREFIX,
	    QCA.CAR_TYPE_ID,
	    QCA.CAR_OWNER,
	    QCA.MESSAGE,
	    QCA.STATUS_CODE,
	    QCA.STATUS_ID,
	    DECODE (QCA.ACTION_ID,
			10, NEW_ACTION_ID,
			11, NEW_ACTION_ID,
			12, NEW_ACTION_ID,
			13, NEW_ACTION_ID,
			NULL),
	    DECODE (QCA.ACTION_ID,
			10, NEW_ACTION_SET_ID,
			11, NEW_ACTION_SET_ID,
			12, NEW_ACTION_SET_ID,
			13, NEW_ACTION_SET_ID,
			NULL)
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
	      X_Last_Update_Date,
	      X_Last_Updated_By,
	      X_Creation_Date,
	      X_Created_By,
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
	      X_Last_Update_Date,
	      X_Last_Updated_By,
	      X_Creation_Date,
	      X_Created_By,
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
	      X_Last_Update_Date,
	      X_Last_Updated_By,
	      X_Creation_Date,
	      X_Created_By,
	      NULL,
	      'Y',
	      NULL,
	      'A',
              NULL
	    );

	    OPEN C4;
	    LOOP
	      FETCH C4 INTO QCAO;
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
	        QCAO.CHAR_ID,
	        X_Last_Update_Date,
	        X_Last_Updated_By,
	        X_Creation_Date,
	        X_Created_By,
	        QCAO.TOKEN_NAME
	      );

            END LOOP;
	    CLOSE C4;

	  END IF;

	  CLOSE C3;

	END LOOP;
	CLOSE C2;

      END LOOP;
      CLOSE C1;

    end if;


  EXCEPTION

	WHEN NO_DATA_FOUND then
	  null;

  END Insert_Rows;


END QLTCPDFB;

/
