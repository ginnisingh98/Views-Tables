--------------------------------------------------------
--  DDL for Package Body QLTTRAMB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QLTTRAMB" as
/* $Header: qlttramb.plb 115.13 2002/11/28 00:28:40 jezheng ship $ */
-- 1/22/96 - created
-- Paul Mishkin

    --
    -- Standard who columns.
    --
    who_user_id                 constant number := fnd_global.conc_login_id;
    who_request_id              constant number := fnd_global.conc_request_id;
    who_program_id              constant number := fnd_global.conc_program_id;
    who_program_application_id  constant number := fnd_global.prog_appl_id;
    who_creation_date           constant date := qltdate.get_sysdate;
    who_created_by			 number;
    who_last_update_login                number;

    --
    -- Launch a workflow for Self-service notification purpose.
    -- Return the item_key.
    --
    FUNCTION launch_workflow(item_type IN Varchar2, workers number)
    RETURN number IS
        item_key number;

	CURSOR c IS
	SELECT qa_ss_import_workflow_s.nextval
	FROM dual;
    BEGIN
        OPEN c;
	FETCH c INTO item_key;
	CLOSE c;

        wf_engine.CreateProcess(
            itemtype => item_type,
            itemkey  => item_key,
            process  => 'IMPORT_PROCESS');

        wf_engine.SetItemAttrNumber(
            itemtype => item_type,
            itemkey  => item_key,
            aname    => 'NUM_WORKERS',
            avalue   => to_char(workers));

        wf_engine.SetItemAttrNumber(
            itemtype => item_type,
            itemkey  => item_key,
            aname    => 'REQUEST_ID',
            avalue   => to_char(who_request_id));

        wf_engine.StartProcess(
            itemtype => item_type,
            itemkey  => item_key);

	RETURN item_key;
        EXCEPTION WHEN OTHERS THEN
        --
        --If there are any exceptions that are raised when
        --workflow needs to be started, then we should return a null
        --itemkey (in which case the workflow will not be started).
        --Look at bug: 1003883
        --
            RETURN null;

    END launch_workflow;


-- scans the collection import table for new rows and launches transaction
-- workers to validate the rows and transfer them to qa_results.  there are
-- two rules for how it assigns rows to workers:  (1) all rows assigned to a
-- given worker will have the same values for validation_flag and plan_name,
-- and (2) a maximum of worker_rows rows can be assigned to a given worker.

-- Added argument4 for Gather Statistics parameter.
-- bug2141009. kabalakr 4 feb 2002.

PROCEDURE TRANSACTION_MANAGER (WORKER_ROWS NUMBER, ARGUMENT2 VARCHAR2,
    ARGUMENT3 VARCHAR2, ARGUMENT4 VARCHAR2) IS

   X_USER_ID                NUMBER;
   X_REQUEST_ID             NUMBER;
   X_PROGRAM_APPLICATION_ID NUMBER;
   X_PROGRAM_ID             NUMBER;
   X_LAST_UPDATE_LOGIN      NUMBER;

   ERRCODE                  NUMBER;
   ERRSTAT                  BOOLEAN;
   I                        NUMBER;
   NUM_ROWS                 NUMBER;
   ROW_COUNT                NUMBER;
   X_GROUP_ID               NUMBER;
   X_PLAN_NAME              VARCHAR2(30);
   X_DEBUG                  VARCHAR2(80);
   TYPE_OF_TXN		    NUMBER;

   TYPE CHAR30_TABLE IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
   TYPE CHAR100_TABLE IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;

   ROWID_TABLE              CHAR100_TABLE;
   PLAN_NAME_TABLE          CHAR30_TABLE;

   TYPE worker_rec IS RECORD (group_id number, val_flag number);
   TYPE worker_table IS TABLE OF worker_rec INDEX BY binary_integer;
   workers worker_table;
   workers_n number := 0;
   self_service boolean := false;
   X_Profile_Val Number := 1;
   workflow_type Varchar2(8);
   workflow_key number := null;

BEGIN

   --
   -- For CBO, need to calculate the size of the QRI table.
   -- bso Tue Dec  7 12:53:14 PST 1999
   --

   --  Check if the parameter 'Gather Statistics' is Yes or not.
   -- for bug 2141009. kabalakr 4 feb 2002.

   IF (upper(ARGUMENT4) = 'YES') THEN
      fnd_stats.gather_table_stats('QA','QA_RESULTS_INTERFACE');
   END IF;

   TYPE_OF_TXN := TO_NUMBER(ARGUMENT2);

   -- get who column values

   X_USER_ID := who_user_id;
   X_REQUEST_ID := who_request_id;
   X_PROGRAM_APPLICATION_ID := who_program_application_id;
   X_PROGRAM_ID := who_program_id;
   X_LAST_UPDATE_LOGIN := who_last_update_login;

   -- first assign workers for rows where validate flag is true.  then
   -- assign workers for rows where validate flag is false.

   FOR X_VAL_FLAG IN 1..2 LOOP
      I := 0;
      IF (X_VAL_FLAG = 1) THEN

         -- count the number of rows where validate flag is true or, more
         -- specifically, where validate flag is not false

         FOR REC IN (SELECT ROWID, PLAN_NAME, SOURCE_CODE
                     FROM   QA_RESULTS_INTERFACE
                     WHERE  PROCESS_STATUS = 1
                       AND  GROUP_ID IS NULL
                       AND  ((VALIDATE_FLAG <> 2) OR (VALIDATE_FLAG IS NULL))
		       AND NVL(INSERT_TYPE,1) = TYPE_OF_TXN
                     ORDER BY PLAN_NAME
                     FOR UPDATE OF GROUP_ID) LOOP
            I := I + 1;
            ROWID_TABLE(I)     := REC.ROWID;
            PLAN_NAME_TABLE(I) := REC.PLAN_NAME;

	    --
	    -- Workflow notification enhancement.  Set a flag to indicate
	    -- if any of these rows are from self-service.  Workflow is
	    -- launched if and only if some records are self-service.
	    -- bso Thu Jul 22 13:35:29 PDT 1999
	    --
	    IF rec.source_code LIKE 'QA_SS%' THEN
	        self_service := true;
	    END IF;
         END LOOP;
      ELSE

         -- count the number of rows where validate flag is false

         FOR REC IN (SELECT ROWID, PLAN_NAME
                     FROM   QA_RESULTS_INTERFACE
                     WHERE  PROCESS_STATUS = 1
                       AND  GROUP_ID IS NULL
                       AND  VALIDATE_FLAG = 2
		       AND NVL(INSERT_TYPE,1) = TYPE_OF_TXN
                     ORDER BY PLAN_NAME
                     FOR UPDATE OF GROUP_ID) LOOP
            I := I + 1;
            ROWID_TABLE(I)     := REC.ROWID;
            PLAN_NAME_TABLE(I) := REC.PLAN_NAME;
         END LOOP;
      END IF;

      NUM_ROWS := I;

      -- get the mrp debug profile, if we'll be using it

      IF ((NUM_ROWS > 0) AND (X_DEBUG IS NULL)) THEN
         X_DEBUG := FND_PROFILE.VALUE('MRP_DEBUG');
      END IF;

      X_PLAN_NAME := NULL;
      X_GROUP_ID := NULL;
      ROW_COUNT := 0;

      -- loop through the rows, launching a worker whenever the plan name
      -- changes or the number of worker rows is exceeded

      FOR I IN 1..NUM_ROWS LOOP
         ROW_COUNT := ROW_COUNT + 1;

         IF (X_PLAN_NAME IS NULL) THEN
            X_PLAN_NAME := PLAN_NAME_TABLE(I);
         END IF;

         -- launch a worker when the plan name changes

         IF (X_PLAN_NAME <> PLAN_NAME_TABLE(I)) AND (ROW_COUNT > 1) THEN
            X_PLAN_NAME := PLAN_NAME_TABLE(I);
	    workers_n := workers_n + 1;
	    workers(workers_n).group_id := x_group_id;
	    workers(workers_n).val_flag := x_val_flag;
            ROW_COUNT := 1;
         END IF;

         -- if this is the first row in a group, fetch a new group id

         IF (ROW_COUNT = 1) THEN
            SELECT QA_GROUP_S.NEXTVAL INTO X_GROUP_ID FROM DUAL;
         END IF;

         -- assign the current group id to the current row

         UPDATE QA_RESULTS_INTERFACE
            SET GROUP_ID = X_GROUP_ID,
                REQUEST_ID = X_REQUEST_ID,
                CREATION_DATE = NVL(CREATION_DATE, who_creation_date),
                CREATED_BY = NVL(CREATED_BY, who_created_by),
                LAST_UPDATE_DATE = who_creation_date,
                LAST_UPDATED_BY = X_USER_ID,
                LAST_UPDATE_LOGIN = who_last_update_login,
                PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
                PROGRAM_ID = X_PROGRAM_ID,
                PROGRAM_UPDATE_DATE = who_creation_date
          WHERE ROWID = ROWID_TABLE(I);

         -- if transaction interface id for the current row is left blank,
         -- assign it a unique value

         UPDATE QA_RESULTS_INTERFACE
            SET TRANSACTION_INTERFACE_ID = QA_TXN_INTERFACE_S.NEXTVAL
          WHERE ROWID = ROWID_TABLE(I)
            AND TRANSACTION_INTERFACE_ID IS NULL;

         -- if we've reached the maximum number of worker rows, launch
         -- a new worker process to handle them, and reset the row count to 0

         IF (ROW_COUNT >= WORKER_ROWS) THEN
	    workers_n := workers_n + 1;
	    workers(workers_n).group_id := x_group_id;
	    workers(workers_n).val_flag := x_val_flag;
            ROW_COUNT := 0;
         END IF;

      END LOOP;

      -- launch a worker to handle any remaining rows

      IF (ROW_COUNT > 0) THEN
	    workers_n := workers_n + 1;
	    workers(workers_n).group_id := x_group_id;
	    workers(workers_n).val_flag := x_val_flag;
      END IF;

   END LOOP;



   --
   -- If self-service, we should start the appropriate workflow and give
   -- it the no. of workers as attribute. The item type of the workflow
   -- is determined by the profile value set.
   --

   IF self_service THEN
       X_Profile_Val := FND_PROFILE.VALUE('QA_SS_IMPORT_WORKFLOW');
       IF X_Profile_Val = 1 THEN
	    workflow_type := 'QASSIMP';
       ELSE
	    workflow_type := 'QASSUIMP';
       END IF;
       workflow_key := launch_workflow(workflow_type, workers_n);
   END IF;

   --
   -- The no. of workers to be spawned is workers_n.  All information
   -- needed will be stored in workers array (basically group_id and
   -- validation_flag).  Launch the workers here!
   --
   FOR n IN 1..workers_n LOOP
       errcode := fnd_request.submit_request(
           'QA', 'QLTTRAWB', null, null, false,
	   to_char(workers(n).group_id),
	   to_char(workers(n).val_flag),
	   x_debug,
	   argument2,
	   to_char(workflow_key),
	   to_char(who_request_id),
	   argument3,
	   workflow_type);
   END LOOP;

END TRANSACTION_MANAGER;


-- wrapper procedure so that the transaction manager can be run as a
-- concurrent program.  argument1 is the number of worker rows.

PROCEDURE WRAPPER(ERRBUF OUT NOCOPY VARCHAR2,
                  RETCODE OUT NOCOPY NUMBER,
                  ARGUMENT1 IN VARCHAR2,
		  ARGUMENT2 IN VARCHAR2,
		  ARGUMENT3 IN VARCHAR2,
		  ARGUMENT4 IN VARCHAR2) IS
		  -- argument 1 is worker row
		  -- argument 2 is transaction type
		  -- argument 3 is user id of the operator who runs import
-- For bug 2141009.
-- Added argument4 to decide whether we need to Gather Statistics on QRI.
-- kabalakr 4 feb 2002.

BEGIN

-- Just a test 'bso delete this later
-- qlttrafb.exec_sql('alter session set nls_numeric_characters='',.''');

   who_created_by := to_number(argument3);
   who_last_update_login := to_number(argument3);

-- For Bug 2141009. Added argument4 : Gather Statistics or not.
-- kabalakr 4 feb 2002.

   TRANSACTION_MANAGER(TO_NUMBER(ARGUMENT1), ARGUMENT2, ARGUMENT3, ARGUMENT4);
   COMMIT;
   ERRBUF := '';
   RETCODE := 0;
END WRAPPER;


END QLTTRAMB;


/
