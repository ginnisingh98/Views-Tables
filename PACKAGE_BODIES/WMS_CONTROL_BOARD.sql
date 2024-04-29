--------------------------------------------------------
--  DDL for Package Body WMS_CONTROL_BOARD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_CONTROL_BOARD" AS
/* $Header: WMSCBCPB.pls 120.2 2005/07/12 02:31:36 varajago noship $ */

-- Global constant holding package name
g_pkg_name CONSTANT VARCHAR2(20) := ' WMS_CONTROL_BOARD' ;


/**************************************
 *
 **************************************/
-- Bug # 1800521, added new parameter so that where clause of the cursor matches
-- exactly same as control board find query condition and chart reflects the
-- queried data.
-- After making changes in the control board form to split the task and
-- exception views into separate ones, it makes sense to have the
-- performance chart use the same where clause that is set either through
-- the query find window or selecting the nodes in the trees
-- The where clause is now set as a form level parameter

/* --Bug#2483984 Performace Tuning of WMS Control Board
  --  now there are separate FROM and WHERE clauses for active, pending and completed tasks */
PROCEDURE get_status_dist (
	x_status_chart_data OUT NOCOPY /* file.sql.39 change */ cb_chart_status_tbl_type
,	x_status_data_count OUT NOCOPY /* file.sql.39 change */ 	NUMBER
,	x_return_status	        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
, 	x_msg_count	        OUT NOCOPY /* file.sql.39 change */ NUMBER
, 	x_msg_data     	        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,  p_cq_type   IN NUMBER
,  p_at_from   IN VARCHAR2
,  p_pt_from   IN VARCHAR2
,  p_ct_from   IN VARCHAR2
,  p_at_where  IN VARCHAR2
,  p_pt_where  IN VARCHAR2
,  p_ct_where  IN VARCHAR2
,  p_acy_from   IN VARCHAR2
,  p_pcy_from   IN VARCHAR2
,  p_ccy_from   IN VARCHAR2
,  p_acy_where  IN VARCHAR2
,  p_pcy_where  IN VARCHAR2
,  p_ccy_where  IN VARCHAR2 ) IS

   c_api_name            CONSTANT VARCHAR2(20) := 'get_status_dist';
   l_CursorStmt          VARCHAR2(32000);
   l_CursorID            INTEGER;
   l_Dummy               INTEGER;
   l_temp_status         NUMBER;
   l_temp_count          NUMBER;
   i                     NUMBER;
   TYPE status_table IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;
   l_status_code_table   status_table;
   l_temp_status_code    VARCHAR2(80);
   TYPE status_count_table IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   l_status_count_table    status_count_table;
   l_loop_index	         NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   -- Get all of the lookup values for the status code
   -- There are 7, 1-Pending, 2-Queued, 3-Dispatched, 4-Loaded , 5 -errored, 6-Completed, 7-Hold
   i := 1;
   LOOP
      SELECT meaning
	INTO l_temp_status_code
	FROM mfg_lookups
	WHERE lookup_type = 'WMS_TASK_STATUS'
	AND   lookup_code = i;
      l_status_code_table(i) := l_temp_status_code;
      EXIT WHEN i = 7;
      i := i + 1;
   END LOOP;


   -- Define the cursor statement
   -- noraml tasks alone
   l_CursorStmt := ' SELECT wdt.status, count(*) task_count FROM ' || p_at_from || ' WHERE ' || p_at_where ||
   				   	 ' AND wdt.status IN (2,3,4,5) GROUP BY wdt.status  UNION ALL  ' ||
				   ' SELECT 1, count(*) task_count FROM ' || p_pt_from || ' WHERE ' || p_pt_where || ' HAVING count(rownum) > 0  ' ||
				   ' UNION ALL SELECT 6, count(*) task_count FROM ' || p_ct_from || ' WHERE ' || p_ct_where || ' HAVING count(rownum) > 0 ';

  IF p_cq_type = 1 THEN
    -- query noraml + cc tasks
    l_CursorStmt := l_CursorStmt || ' UNION ALL ' ||
                    ' SELECT wdt.status, count(*) task_count FROM ' || p_acy_from ||
	  			   	  ' WHERE ' || p_acy_where || ' AND wdt.status IN (2,3,4,5) GROUP BY wdt.status UNION ALL  ' ||
				   	  ' SELECT 1, count(min(mcce.cycle_count_entry_id)) task_count FROM ' || p_pcy_from ||
				   	  ' WHERE ' || p_pcy_where || --' and count(rownum) > 0 ' ||
				   	  ' UNION ALL SELECT 6, count(*) task_count FROM ' || p_ccy_from ||
					  ' WHERE ' || p_ccy_where ||
				   	  ' HAVING count(rownum) > 0 ';
  ELSIF p_cq_type = 2 THEN
     --query cc tasks alone
     l_CursorStmt := ' SELECT wdt.status, count(*) task_count FROM ' || p_acy_from ||
                     ' WHERE ' || p_acy_where || ' AND wdt.status IN (2,3,4,5) GROUP BY wdt.status UNION ALL  ' ||
                     ' SELECT 1, count(min(mcce.cycle_count_entry_id)) task_count FROM ' || p_pcy_from ||
                     ' WHERE ' || p_pcy_where || --' and count(rownum) > 0 '	||
                     ' UNION ALL SELECT 6, count(*) task_count FROM ' || p_ccy_from ||
                  ' WHERE ' || p_ccy_where ||
                     ' HAVING count(rownum) > 0 ';
  END IF;

   -- Open a cursor for processing.
   l_CursorID := DBMS_SQL.OPEN_CURSOR;

   -- Parse the query
   DBMS_SQL.PARSE(l_CursorID, l_CursorStmt, DBMS_SQL.V7);

   -- Define the output variables
   DBMS_SQL.DEFINE_COLUMN(l_CursorID, 1, l_temp_status);
   DBMS_SQL.DEFINE_COLUMN(l_CursorID, 2, l_temp_count);

   -- Execute the statement. We don't care about the return value,
   -- but we do need to declare a variable for it.
   l_Dummy := DBMS_SQL.EXECUTE(l_CursorID);

   -- This is the fetch loop
   x_status_data_count := 0;
   i := 0;
   x_return_status := fnd_api.g_ret_sts_success;
   LOOP
      -- Fetch the rows into the buffer, and also check for the exit
      -- condition from the loop.
      IF DBMS_SQL.FETCH_ROWS(l_CursorID) = 0 THEN
	     EXIT;
      END IF;

      -- Retrieve the rows from the buffer into temp variables.
      DBMS_SQL.COLUMN_VALUE(l_CursorID, 1, l_temp_status);
      DBMS_SQL.COLUMN_VALUE(l_CursorID, 2, l_temp_count);

      --mydebug('CBPT: Storing into temp table for status -->' || l_temp_status || ' = ' || l_temp_count );
      -- Store these values in the task count table
      IF (l_status_count_table.EXISTS(l_temp_status)) THEN
         l_status_count_table(l_temp_status) := l_status_count_table(l_temp_status) + l_temp_count;
      ELSE
         l_status_count_table(l_temp_status) := l_temp_count;
      END IF;

   END LOOP;
   -- Close the cursor.
   DBMS_SQL.CLOSE_CURSOR(l_CursorID);


   -- Input in the status type and count information into the chart table
   x_status_data_count := 0;
   l_loop_index := l_status_count_table.FIRST;

   -- Populate the chart only if there are records returned by the cursor c_type
   IF (l_loop_index IS NOT NULL) THEN
      LOOP

         x_status_data_count := x_status_data_count + 1;
         x_status_chart_data(x_status_data_count).status     := l_status_code_table(l_loop_index);
         x_status_chart_data(x_status_data_count).task_count := l_status_count_table(l_loop_index);
      EXIT WHEN l_loop_index = l_status_count_table.LAST;
         l_loop_index := l_status_count_table.NEXT(l_loop_index);

      END LOOP;
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Close the cursor.
      DBMS_SQL.CLOSE_CURSOR(l_CursorID);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Close the cursor.
      DBMS_SQL.CLOSE_CURSOR(l_CursorID);

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
	 FND_MSG_PUB.ADD_EXC_MSG(g_pkg_name, c_api_name);
      END IF;
      -- Close the cursor.
      DBMS_SQL.CLOSE_CURSOR(l_CursorID);

END get_status_dist;


/**************************************
 *
 **************************************/

/* --Bug#2483984 Performace Tuning of WMS Control Board
  --  now there are separate FROM and WHERE clauses for active, pending and completed tasks */
PROCEDURE get_type_dist(
	x_type_chart_data OUT NOCOPY /* file.sql.39 change */ cb_chart_type_tbl_type
,	x_type_data_count OUT NOCOPY /* file.sql.39 change */ 	NUMBER
,	x_return_status	        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
, 	x_msg_count	        OUT NOCOPY /* file.sql.39 change */ NUMBER
, 	x_msg_data     	        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,  p_cq_type   IN NUMBER
,  p_at_from   IN VARCHAR2
,  p_pt_from   IN VARCHAR2
,  p_ct_from   IN VARCHAR2
,  p_at_where  IN VARCHAR2
,  p_pt_where  IN VARCHAR2
,  p_ct_where  IN VARCHAR2
,  p_acy_from   IN VARCHAR2
,  p_pcy_from   IN VARCHAR2
,  p_ccy_from   IN VARCHAR2
,  p_acy_where  IN VARCHAR2
,  p_pcy_where  IN VARCHAR2
,  p_ccy_where  IN VARCHAR2 ) IS

   c_api_name            CONSTANT VARCHAR2(20) := 'get_type_dist';
   l_CursorStmt          VARCHAR2(32000);
   l_CursorID            INTEGER;
   l_Dummy               INTEGER;
   l_temp_task           NUMBER;
   l_temp_count          NUMBER;
   l_loop_index	         NUMBER;
   TYPE task_type_table IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;
   l_task_type_table     task_type_table;
   l_temp_task_type      VARCHAR2(80);
   TYPE task_count_table IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   l_task_count_table    task_count_table;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   -- Get all of the lookup values for the task type description
   -- There should be only 6, 1-Pick, 2-Putaway, 3-Cycle Count, 4-Replenish 5-MOXfer 6-MOIssue
   l_loop_index := 1;
   LOOP
      SELECT meaning
	INTO l_temp_task_type
	FROM mfg_lookups
	WHERE lookup_type = 'WMS_TASK_TYPES'
	AND   lookup_code = l_loop_index;
      l_task_type_table(l_loop_index) := l_temp_task_type;
      EXIT WHEN l_loop_index = 6;
      l_loop_index := l_loop_index + 1;
   END LOOP;

   -- Define the cursor statement
   l_CursorStmt := 'SELECT NVL(wdt.task_type,mmtt.wms_task_type) task_type, count(*) task_count FROM ' ||
      				   p_at_from || ' WHERE ' || p_at_where ||
					   ' AND status IN (2,3,4,5) GROUP BY NVL(wdt.task_type,mmtt.wms_task_type) UNION ALL ' ||
     			   'SELECT mmtt.wms_task_type task_type, count(*) task_count FROM ' ||
				   		   p_pt_from || ' WHERE ' || p_pt_where || ' GROUP BY mmtt.wms_task_type UNION ALL ' ||
				   'SELECT wdth.task_type task_type, count(*) task_count FROM ' ||
				   	   p_ct_From || ' WHERE ' || p_ct_where || ' GROUP BY wdth.task_type ';

   IF p_cq_type = 1 THEN
      -- query noraml + cc tasks
      l_CursorStmt := l_CursorStmt || ' UNION ALL ' ||
                       ' SELECT 3 task_type, count(*) task_count FROM ' || p_acy_from ||
           			    ' WHERE ' || p_acy_where || ' AND wdt.status IN (2,3,4,5) HAVING count(rownum) > 0 UNION ALL ' ||
     			          ' SELECT 3 task_type, count(min(mcce.cycle_count_entry_id)) task_count FROM ' || p_pcy_from ||
				          ' WHERE ' || p_pcy_where || --' and count(rownum) > 0  UNION ALL ' ||
				          ' UNION ALL SELECT 3 task_type, count(*) task_count FROM ' || p_ccy_From ||
				          ' WHERE ' || p_ccy_where || ' HAVING count(rownum) > 0 ';
   ELSIF p_cq_type = 2 THEN
      --query cc tasks alone
      l_CursorStmt :=  ' SELECT 3 task_type, count(*) task_count FROM ' || p_acy_from ||
           			    ' WHERE ' || p_acy_where || ' AND wdt.status IN (2,3,4,5) HAVING count(rownum) > 0 UNION ALL ' ||
     			          ' SELECT 3 task_type, count(min(mcce.cycle_count_entry_id)) task_count FROM ' || p_pcy_from ||
				          ' WHERE ' || p_pcy_where || --' and count(rownum) > 0 UNION ALL ' ||
				          ' UNION ALL SELECT 3 task_type, count(*) task_count FROM ' || p_ccy_From ||
				          ' WHERE ' || p_ccy_where || ' HAVING count(rownum) > 0 ';
   END IF;

   -- Open a cursor for processing.
   l_CursorID := DBMS_SQL.OPEN_CURSOR;

   -- Parse the query
   DBMS_SQL.PARSE(l_CursorID, l_CursorStmt, DBMS_SQL.V7);

   -- Define the output variables
   DBMS_SQL.DEFINE_COLUMN(l_CursorID, 1, l_temp_task);
   DBMS_SQL.DEFINE_COLUMN(l_CursorID, 2, l_temp_count);

   -- Execute the statement. We don't care about the return value,
   -- but we do need to declare a variable for it.
   l_Dummy := DBMS_SQL.EXECUTE(l_CursorID);

   -- The dynamic sql cursor statement  will return task types and count but is
   -- not grouped together based on the task_type.  This part will deal with
   -- doing that while putting the aggregate count information in a table with
   -- the index being the task_type code.  7 refers to a NULL value for task_type
   LOOP
      -- Fetch the rows into the buffer, and also check for the exit
      -- condition from the loop.
      IF DBMS_SQL.FETCH_ROWS(l_CursorID) = 0 THEN
	 EXIT;
      END IF;

      -- Retrieve the rows from the buffer into temp variables.
      DBMS_SQL.COLUMN_VALUE(l_CursorID, 1, l_temp_task);
      DBMS_SQL.COLUMN_VALUE(l_CursorID, 2, l_temp_count);

      -- Store these values in the task count table
      -- Changed for supporting new task types 5,  6
      IF (l_task_count_table.EXISTS(NVL(l_temp_task, 7))) THEN
        l_task_count_table(NVL(l_temp_task, 7)) := l_task_count_table(NVL(l_temp_task, 7)) + l_temp_count;
      ELSE
        l_task_count_table(NVL(l_temp_task, 7)) := l_temp_count;
     END IF;


   END LOOP;

   -- Close the cursor.
   DBMS_SQL.CLOSE_CURSOR(l_CursorID);

   -- Input in the task type and count information into the chart table
   x_type_data_count := 0;
   l_loop_index := l_task_count_table.FIRST;
   -- Populate the chart only if there are records returned by the cursor c_type
   IF (l_loop_index IS NOT NULL) THEN
      LOOP
	 x_type_data_count := x_type_data_count + 1;
     -- Changed for supporting new task types

	 IF (l_loop_index = 7) THEN
	    x_type_chart_data(x_type_data_count).TYPE := 'Other';
	 ELSE
	    -- Get the lookup value for the task_type from the table
	    x_type_chart_data(x_type_data_count).TYPE := l_task_type_table(l_loop_index);
	 END IF;
	 -- Store the count value associated with the task type
	 x_type_chart_data(x_type_data_count).task_count := l_task_count_table(l_loop_index);
	 EXIT WHEN l_loop_index = l_task_count_table.LAST;
	 l_loop_index := l_task_count_table.NEXT(l_loop_index);
      END LOOP;
   END IF;

   x_return_status := fnd_api.g_ret_sts_success;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Close the cursor.
      DBMS_SQL.CLOSE_CURSOR(l_CursorID);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Close the cursor.
      DBMS_SQL.CLOSE_CURSOR(l_CursorID);

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
	 FND_MSG_PUB.ADD_EXC_MSG(g_pkg_name, c_api_name);
      END IF;
      -- Close the cursor.
      DBMS_SQL.CLOSE_CURSOR(l_CursorID);

END get_type_dist;


----------------------------------------------------
--  Valid status changes are:
--  Pending(1) Queued(2) Dispatched(3) Loaded(4)
--    Error(5) Completed(6) Hold(7)
--  Vertical axis is from_status
--  Horizontal axis is to_status
--          P(1)  Q(2)  D(3)  L(4)  E(5)  C(6)  H(7)
--     P(1)  x     x     x
--     Q(2)  x     x     x
--     D(3)  x     x     x     x
--     L(4)                    x
--     E(5)  x     x     x           x
--     C(6)                                x
--     H(7)                                      x
----------------------------------------------------
FUNCTION is_status_valid(
   p_from_status  IN NUMBER
,  p_to_status    IN NUMBER ) RETURN VARCHAR2 IS

	l_is_valid VARCHAR2(2);

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
	l_is_valid := 'N';

	IF p_from_status = 1 THEN
		IF p_to_status in (1,2,3) THEN
			l_is_valid := 'Y';
		END IF;
	ELSIF p_from_status = 2 THEN
		IF p_to_status in (1,2,3) THEN
			l_is_valid := 'Y';
		END IF;
	ELSIF p_from_status = 3 THEN
		IF p_to_status in (1,2,3,4) THEN
			l_is_valid := 'Y';
		END IF;
	ELSIF p_from_status = 4 THEN
		IF p_to_status in (4) THEN
			l_is_valid := 'Y';
	 	END IF;
	ELSIF p_from_status = 5 THEN
		IF p_to_status in (1,2,3,5) THEN
			l_is_valid := 'Y';
		END IF;
	ELSIF p_from_status = 6 THEN
		IF p_to_status in (6) THEN
			l_is_valid := 'Y';
		END IF;
	ELSIF p_from_status = 7 THEN
		IF p_to_status in (7) THEN
			l_is_valid := 'Y';
		END IF;
	END IF;

	return l_is_valid;

END is_status_valid;



/**************************************
 *
 **************************************/
/*
   PROCEDURE lock_row(
	p_rowid				 IN OUT NOCOPY  VARCHAR2
,	p_transaction_temp_id	IN	NUMBER
,	p_task_id				IN	NUMBER
,	p_status				IN 	NUMBER
,	p_priority				IN 	NUMBER
,	p_person_id				IN	NUMBER
,	p_person_resource_id	IN	NUMBER
,       p_transaction_source_type_id IN NUMBER NULL --kkoothan
) IS
	CURSOR C_mcce IS SELECT  --kkoothan
		cycle_count_entry_id
	,	1 -- status
	,	task_priority
	FROM MTL_CYCLE_COUNT_ENTRIES
	WHERE cycle_count_entry_id = p_transaction_temp_id
	FOR UPDATE OF entry_status_code, task_priority NOWAIT;

	CURSOR C_mmtt IS SELECT
		transaction_temp_id
	,	wms_task_status
	,	task_priority
	FROM MTL_MATERIAL_TRANSACTIONS_TEMP
	WHERE transaction_temp_id = p_transaction_temp_id
	FOR UPDATE OF wms_task_status, task_priority NOWAIT;

	CURSOR C_wdt IS SELECT
		transaction_temp_id
	,	task_id
	,	status
	,	priority
	,	person_id
	,	person_resource_id
	FROM WMS_DISPATCHED_TASKS
	WHERE 	transaction_temp_id = p_transaction_temp_id
	AND		task_id	= p_task_id
	FOR UPDATE OF status, priority, person_id, person_resource_id NOWAIT;

        recinfo_mcce C_mcce%ROWTYPE; --kkoothan
	recinfo_mmtt C_mmtt%ROWTYPE;
	recinfo_wdt C_wdt%ROWTYPE;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
    IF p_transaction_source_type_id = 9 THEN -- kkoothan
      -- cycle count Task

   BEGIN
      OPEN C_mcce;
      FETCH C_mcce INTO recinfo_mcce;
      IF (c_mcce%notfound) THEN
	 CLOSE C_mcce;
	 fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
	 app_exception.raise_exception;
      END IF;
      CLOSE C_mcce;
   EXCEPTION
      WHEN OTHERS THEN
	 IF SQLCODE = -54 THEN --record locked by other session
	    fnd_message.set_name('WMS', 'WMS_RECORD_BEING_UPDATED');
	    app_exception.raise_exception;
	 END IF;
   END;
     ELSE
	 BEGIN
	    OPEN C_mmtt;
	    FETCH C_mmtt INTO recinfo_mmtt;
	    IF (c_mmtt%notfound) THEN
	       CLOSE C_mmtt;
	       fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
	       app_exception.raise_exception;
	    END IF;
	    CLOSE C_mmtt;
	 EXCEPTION
	    WHEN OTHERS THEN
	       IF SQLCODE = -54 THEN --record locked by other session
		  fnd_message.set_name('WMS', 'WMS_RECORD_BEING_UPDATED');
		  app_exception.raise_exception;
	       END IF;
	 END;
    END IF;

    IF (p_transaction_temp_id IN
	(recinfo_mmtt.transaction_temp_id,recinfo_mcce.cycle_count_entry_id)
	) THEN -- kkoothan
       NULL;
     ELSE
       fnd_message.set_name('FND','FORM_RECORD_CHANGED');
       app_exception.raise_exception;
    END IF;

    IF p_status =1 THEN
       -- Pending task, no need to lock wdt
       RETURN;
    END IF;
    BEGIN
       OPEN C_wdt;
       FETCH C_wdt INTO recinfo_wdt;
       IF (c_wdt%notfound) THEN
	  CLOSE C_wdt;
	  fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
	  app_exception.raise_exception;
       END IF;
       CLOSE C_wdt;
    EXCEPTION
       WHEN OTHERS THEN
	  IF SQLCODE = -54 THEN --record locked by other session
	     fnd_message.set_name('WMS', 'WMS_RECORD_BEING_UPDATED');
	     app_exception.raise_exception;
	  END IF;
    END;

    IF(   	(recinfo_wdt.transaction_temp_id = p_transaction_temp_id)
		AND	(recinfo_wdt.task_id = p_task_id)
		) THEN
       NULL;
     ELSE
       fnd_message.set_name('FND','FORM_RECORD_CHANGED');
       app_exception.raise_exception;
    END IF;

END;
*/

--Modified one
PROCEDURE lock_row(
		        p_rowid				 IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2
		   ,	p_transaction_temp_id	IN	NUMBER
		   ,	p_task_id				IN	NUMBER
		   ,	p_status				IN 	NUMBER
		   ,	p_priority				IN 	NUMBER
		   ,	p_person_id				IN	NUMBER
		   ,	p_person_resource_id	IN	NUMBER
		   ,    p_transaction_source_type_id IN NUMBER  --kkoothan
  ) IS

     MMTT_lock_name VARCHAR2(50):= To_char(p_transaction_temp_id);
     lock_result NUMBER;
     l_lock_id VARCHAR2(50);
     l_return_value NUMBER;

     CURSOR C_mcce IS SELECT  --kkoothan
       cycle_count_entry_id
       ,	1 -- status
       ,	task_priority
	FROM MTL_CYCLE_COUNT_ENTRIES
	WHERE cycle_count_entry_id = p_transaction_temp_id
	FOR UPDATE OF entry_status_code, task_priority NOWAIT;

        recinfo_mcce C_mcce%ROWTYPE; --kkoothan

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
    IF (l_debug = 1) THEN
       mydebug('Inside lock_row p_transaction_temp_id:'||p_transaction_temp_id);
    END IF;

    IF p_transaction_source_type_id = 9 THEN -- kkoothan
      -- cycle count Task

   BEGIN
      OPEN C_mcce;
      FETCH C_mcce INTO recinfo_mcce;
      IF (c_mcce%notfound) THEN
	 CLOSE C_mcce;
	 fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
	 app_exception.raise_exception;
      END IF;
      CLOSE C_mcce;
   EXCEPTION
      WHEN OTHERS THEN
	 IF SQLCODE = -54 THEN --record locked by other session
	    fnd_message.set_name('WMS', 'WMS_RECORD_BEING_UPDATED');
	    app_exception.raise_exception;
	 END IF;
   END;
     ELSE
	 IF (l_debug = 1) THEN
   	 mydebug('for MMTT');
	 END IF;
        BEGIN
	   dbms_lock.allocate_unique
	     (lockname         => MMTT_lock_name,
	      lockhandle       => l_lock_id);

	   l_return_value := dbms_lock.request --EXCLUSIVE LOCK
	     (lockhandle         => l_lock_id,
	      lockmode           => 6,
	      timeout            => 1,
	      release_on_commit  => TRUE);

	   IF (l_debug = 1) THEN
   	   mydebug('dbms_lock:l_return_value:'||l_return_value);
	   END IF;

	   IF l_return_value IN (1,2) THEN
	      fnd_message.set_name('WMS', 'WMS_RECORD_BEING_UPDATED');
	      app_exception.raise_exception;
	   END IF;

	EXCEPTION
	   WHEN OTHERS THEN
	      IF ((SQLCODE = -54) OR l_return_value IN (1,2)) THEN --record locked by other session
		 IF (l_debug = 1) THEN
   		 mydebug('INSIDE EXCEPTION');
		 END IF;
		 fnd_message.set_name('WMS', 'WMS_RECORD_BEING_UPDATED');
		 app_exception.raise_exception;

	      END IF;
	END;

    END IF;

END;


/***********************************
 * created by kkoothan to handle cycle count Tasks
 ***********************************/
PROCEDURE update_mcce(
	 p_cycle_count_entry_id	        IN NUMBER
	,p_priority		        IN NUMBER
	,p_updated_by			IN NUMBER
	,p_user_task_type		IN NUMBER
       ,p_last_update_date              IN      DATE    /* Bug 2372652 */
         ) IS

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

	UPDATE MTL_CYCLE_COUNT_ENTRIES
        SET
		task_priority = p_priority
	,	last_updated_by	= p_updated_by
	,	last_update_date= p_last_update_date                     /* Bug 2372652 */
	,	standard_operation_id = p_user_task_type
	WHERE cycle_count_entry_id = p_cycle_count_entry_id;
	commit;
EXCEPTION
	WHEN no_data_found THEN
		null;

END update_mcce;

/***********************************
 *
 ***********************************/

PROCEDURE update_mmtt(
	 p_transaction_temp_id		IN NUMBER
	,p_priority			IN NUMBER
	,p_from_status			IN NUMBER
	,p_to_status			IN NUMBER
	,p_updated_by			IN NUMBER
	,p_user_task_type		IN NUMBER
	,p_task_type			IN NUMBER
         ) IS

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
	--dbms_output.put_line('in update_mmtt '|| p_transaction_temp_id || ':' || p_priority || ':' ||p_from_status || ':' ||p_to_status);

	UPDATE mtl_material_transactions_temp
	SET
		task_priority = p_priority
	,	wms_task_status = decode(p_to_status, NULL, p_from_status, p_to_status)
	,	last_updated_by	= p_updated_by
	,	last_update_date= SYSDATE
	,	standard_operation_id = p_user_task_type
	,	wms_task_type = p_task_type
	WHERE transaction_temp_id = p_transaction_temp_id;
	commit;
	--dbms_output.put_line('did update_mmtt ');
EXCEPTION
	WHEN no_data_found THEN
		null;
		--dbms_output.put_line('not found in mmtt');

END update_mmtt;

/***********************************
 ***********************************/
PROCEDURE update_wdt(
	p_transaction_temp_id 	IN NUMBER
	,p_task_id		IN NUMBER
	,p_priority		IN NUMBER
	,p_from_status		IN NUMBER
	,p_to_status		IN NUMBER
	,p_person_id		IN NUMBER
	,p_person_resource_id	IN NUMBER
	,p_updated_by		IN NUMBER
	,p_user_task_type	IN NUMBER
	,p_task_type		IN NUMBER
   ) IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
	--dbms_output.put_line('in update wdt');
	UPDATE wms_dispatched_tasks
	SET
		person_resource_id = p_person_resource_id
	,	person_id	   = p_person_id
	,	priority	   = p_priority
	,	status		   = p_to_status
	,	last_updated_by	   = p_updated_by
	,	last_update_date   = SYSDATE
	,	user_task_type	   = p_user_task_type
	,	task_type	   = p_task_type
	WHERE transaction_temp_id = p_transaction_temp_id
	AND	  task_id	  = nvl(p_task_id, task_id);

END update_wdt;


/**************************************
 *
 **************************************/
PROCEDURE insert_to_wdt(
	p_transaction_temp_id 	IN NUMBER
	,p_status		IN NUMBER
	,p_person_id		IN NUMBER
	,p_person_resource_id	IN NUMBER
	,p_updated_by		IN NUMBER
        ,p_transaction_source_type_id IN NUMBER --kkoothan
	,x_task_id	 OUT NOCOPY /* file.sql.39 change */ NUMBER
        ,x_priority             IN NUMBER

) IS

	l_org_id		NUMBER;
	l_user_task_type	NUMBER;
	l_wms_task_type		NUMBER;
	l_next_task_id		NUMBER;
	l_operation_plan_id     NUMBER;
	l_move_order_line_id    NUMBER;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

	--Get value from sequence for next task id
	SELECT wms_dispatched_tasks_s.NEXTVAL
	INTO l_next_task_id
	FROM dual ;

	-- Obtain org_id, user_task_type and task_type
    IF p_transaction_source_type_id =9 THEN --kkoothan
      -- cycle count
      SELECT 	organization_id, standard_operation_id, 3 --task type
	  INTO	l_org_id, l_user_task_type, l_wms_task_type
	  FROM	mtl_cycle_count_entries
	  WHERE	cycle_count_entry_id = p_transaction_temp_id;
    ELSE
	  SELECT organization_id, standard_operation_id, wms_task_type, operation_plan_id, move_order_line_id
 	  INTO	l_org_id, l_user_task_type, l_wms_task_type, l_operation_plan_id, l_move_order_line_id
          FROM	mtl_material_transactions_temp
	  WHERE	transaction_temp_id = p_transaction_temp_id;
    END IF;

	--dbms_output.put_line('Before Insert into WMSDT');


	INSERT INTO WMS_DISPATCHED_TASKS
	(	TASK_ID
	,	TRANSACTION_TEMP_ID
	,	ORGANIZATION_ID
	,	USER_TASK_TYPE
	,	PERSON_ID
	,	EFFECTIVE_START_DATE
	,	EFFECTIVE_END_DATE
	,	PERSON_RESOURCE_ID
	,	STATUS
	,	DISPATCHED_TIME
	,	LAST_UPDATE_DATE
	,	LAST_UPDATED_BY
	,	CREATION_DATE
	,	CREATED_BY
	,	task_type
	,       priority
	,       operation_plan_id
	,       move_order_line_id	)

	VALUES( l_next_task_id
	,	p_transaction_temp_id
	,	l_org_id
	,	Nvl(l_user_task_type,2)
	,	p_person_id
	,	sysdate
	,	sysdate
	,	p_person_resource_id
	,	p_status
	,	sysdate
	,	sysdate
	,	p_updated_by
	,	sysdate
	,	p_updated_by
	,	l_wms_task_type
        ,       x_priority
        ,       l_operation_plan_id
        ,       l_move_order_line_id);
	  x_task_id := l_next_task_id;
END insert_to_wdt;

/************************************
 ************************************/
PROCEDURE delete_from_wdt(
	p_transaction_temp_id 	IN NUMBER , p_task_id IN NUMBER) IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
	DELETE FROM wms_dispatched_tasks
	WHERE transaction_temp_id = p_transaction_temp_id
	AND task_id = nvl(p_task_id, task_id);

END delete_from_wdt;



-- Procedure definition of task manipulation
-- Task status lookup
--  1 : Pending
--  2:  Queued
--  3:  Dispatched
--  4:  Loaded
--  5:  Error
--  6:  Completed

PROCEDURE task_manipulator(
	 x_return_status		 OUT NOCOPY /* file.sql.39 change */ 	VARCHAR2
	,x_msg_count			 OUT NOCOPY /* file.sql.39 change */ 	NUMBER
	,x_msg_data			 OUT NOCOPY /* file.sql.39 change */ 	VARCHAR2
	,x_task_id			 OUT NOCOPY /* file.sql.39 change */ 	NUMBER
	,p_updated_by				IN	NUMBER
	,p_task_id				IN	NUMBER
	,p_transaction_temp_id			IN	NUMBER
	,p_organization_id			IN	NUMBER
	,p_person_resource_id			IN	NUMBER
	,p_person_id				IN	NUMBER
	,p_priority				IN	NUMBER
	,p_from_status				IN	NUMBER
	,p_to_status				IN	NUMBER
	,p_user_task_type			IN 	NUMBER
	,p_task_type				IN	NUMBER
	,p_transaction_source_type_id           IN	NUMBER  -- kkoothan
        ,p_last_update_date                     IN      DATE    /* Bug 2372652 */

	) IS
        -- Bug# 1728558, added p_user_task_type parameter in task_manipulator,
	-- update_mmtt, update_wdt

	c_api_name CONSTANT VARCHAR2(20) := 'task_manipulator';

	from_status		NUMBER := p_from_status;
	to_status 		NUMBER := p_to_status;
	from_status_code VARCHAR2(10) ;
	to_status_code	 VARCHAR2(10) ;


    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
	x_return_status := fnd_api.g_ret_sts_success;
	x_task_id := p_task_id;

	--dbms_output.put_line('in task_mani');

	/*select mlk1.meaning, mlk2.meaning
	into	from_status_code, to_status_code
	from	mfg_lookups mlk1, mfg_lookups mlk2
	where   mlk1.lookup_type = 'WMS_TASK_TYPES'
	and		mlk2.lookup_type = 'WMS_TASK_TYPES'
	and 	mlk1.lookup_code = from_status
	and 	mlk2.lookup_code = to_status;*/

	-- Check whether the change of status is valid
	--dbms_output.put_line('in validate' || from_status || ':' || to_status || ':' || is_status_valid(from_status, to_status));

	IF is_status_valid(from_status, to_status) <> 'Y' THEN
		fnd_message.set_name('WMS', 'WMS_TASK_STATUS_CHG_NOTALLOWED');
		fnd_message.set_token('FROM_STATUS', from_status_code);
		fnd_message.set_token('TO_STATUS', to_status_code);
		fnd_msg_pub.add;
		RAISE fnd_api.g_exc_error;
	END IF;

	--dbms_output.put_line('pass validate');

	IF from_status = to_status THEN
		-- Status doesn't change
		IF from_status = 1  THEN
			--'PENDING'
			-- Update mmtt/mcce
                  IF p_transaction_source_type_id = 9  THEN -- kkoothan
                   -- cycle count
               	        update_mcce(p_transaction_temp_id
				    ,p_priority
				    ,p_updated_by
				    ,p_user_task_type
				     ,p_last_update_date                     /* Bug 2372652 */
				      );
                  ELSE
                	update_mmtt(p_transaction_temp_id
				    ,p_priority
				    ,from_status
				    ,from_status
				    ,p_updated_by
				    ,p_user_task_type
				    ,p_task_type);
                  END IF;

		ELSIF from_status in (2, 3,4) THEN
			-- queued, dispatched
			-- update mmtt/mcce and wdt
			--dbms_output.put_line('calling update_mmtt ');
		 	IF p_transaction_source_type_id = 9  THEN -- kkoothan
                                   -- cycle count
                  	            update_mcce(p_transaction_temp_id
		  		    ,p_priority
				    ,p_updated_by
				    ,p_user_task_type
				    ,p_last_update_date                     /* Bug 2372652 */
				    );
                        ELSE
                            	   update_mmtt(p_transaction_temp_id
				    ,p_priority
				    ,from_status
				    ,from_status
				    ,p_updated_by
				    ,p_user_task_type
				    ,p_task_type);
                        END IF;

			update_wdt(p_transaction_temp_id
				   , p_task_id
				   , p_priority
				   , from_status
				   , to_status
				   , p_person_id
				   , p_person_resource_id
				   , p_updated_by
				   , p_user_task_type
				   , p_task_type);
		END IF;
	ELSE
		-- Status are changed... manipulate more than one tables
		IF from_status = 1 THEN -- Pending
			IF to_status in (2,3) THEN --'QUEUED', Dispatched
		                IF p_transaction_source_type_id = 9  THEN -- kkoothan
                                 -- cycle count
               	                   update_mcce(p_transaction_temp_id
				    ,p_priority
				    ,p_updated_by
				    ,p_user_task_type
				    ,p_last_update_date                     /* Bug 2372652 */
				    );
                                ELSE
                	            update_mmtt(p_transaction_temp_id
				    ,p_priority
				    ,from_status
				    ,from_status
				    ,p_updated_by
				    ,p_user_task_type
				    ,p_task_type);
                                END IF;
				insert_to_wdt(p_transaction_temp_id
					      , to_status
					      , p_person_id
					      , p_person_resource_id
					      , p_updated_by
                                              , p_transaction_source_type_id -- kkoothan
					      , x_task_id
                                              , p_priority);
			END IF;
		ELSIF from_status = 2 THEN --'QUEUED'
			IF to_status = 1 THEN --'PENDING'
				IF p_transaction_source_type_id = 9  THEN -- kkoothan
                                  -- cycle count
                 	            update_mcce(p_transaction_temp_id
				    ,p_priority
				    ,p_updated_by
				    ,p_user_task_type
				    ,p_last_update_date                     /* Bug 2372652 */
				    );
                                ELSE
                	            update_mmtt(p_transaction_temp_id
				    ,p_priority
				    ,from_status
				    ,from_status
				    ,p_updated_by
				    ,p_user_task_type
				    ,p_task_type);
                                END IF;
				delete_from_wdt(p_transaction_temp_id
						, p_task_id);

				x_task_id := null;
			ELSIF to_status IN (3) THEN
				--'DISPATCHED'
				update_wdt(p_transaction_temp_id
					   , p_task_id
					   , p_priority
					   , from_status
					   , to_status
					   , p_person_id
					   , p_person_resource_id
					   , p_updated_by
					   , p_user_task_type
					   , p_task_type);

			END IF;
		ELSIF from_status = 3 THEN --'DISPATCHED'
			IF to_status = 1 THEN --'Pending'
			        IF p_transaction_source_type_id = 9  THEN -- kkoothan
                                  -- cycle count
                 	            update_mcce(p_transaction_temp_id
				    ,p_priority
				    ,p_updated_by
				    ,p_user_task_type
				    ,p_last_update_date                     /* Bug 2372652 */
				    );
                                ELSE
                	            update_mmtt(p_transaction_temp_id
				    ,p_priority
				    ,from_status
				    ,from_status
				    ,p_updated_by
				    ,p_user_task_type
				    ,p_task_type);
                                END IF;
				delete_from_wdt(p_transaction_temp_id
					, p_task_id);

				x_task_id := null;

			ELSIF to_status in (2,4) THEN --'Queued', 'LOADED'
				IF p_transaction_source_type_id = 9  THEN -- kkoothan
                                  -- cycle count
               	                    update_mcce(p_transaction_temp_id
				    ,p_priority
				    ,p_updated_by
				    ,p_user_task_type
				    ,p_last_update_date                     /* Bug 2372652 */
				    );
                                ELSE
                	            update_mmtt(p_transaction_temp_id
				    ,p_priority
				    ,from_status
				    ,from_status
				    ,p_updated_by
				    ,p_user_task_type
				    ,p_task_type);
                                END IF;
				update_wdt(p_transaction_temp_id
					   , p_task_id
					   , p_priority
					   , from_status
					   , to_status
					   , p_person_id
					   , p_person_resource_id
					   , p_updated_by
					   , p_user_task_type
					   , p_task_type);
			END IF;
		ELSIF from_status = 5  THEN --'ERROR'
			IF to_status=1 THEN --'PENDING'
			        IF p_transaction_source_type_id = 9  THEN -- kkoothan
                                   -- cycle count
                 	            update_mcce(p_transaction_temp_id
				    ,p_priority
				    ,p_updated_by
				    ,p_user_task_type
				    ,p_last_update_date                     /* Bug 2372652 */
				    );
                                ELSE
                	            update_mmtt(p_transaction_temp_id
				    ,p_priority
				    ,from_status
				    ,from_status
				    ,p_updated_by
				    ,p_user_task_type
				    ,p_task_type);
                                END IF;
				delete_from_wdt(p_transaction_temp_id, p_task_id);
				x_task_id := null;
			ELSIF to_status IN (2, 3) THEN --'QUEUED', 'DISPATCHED'
				IF p_transaction_source_type_id = 9  THEN -- kkoothan
                                  -- cycle count
               	                    update_mcce(p_transaction_temp_id
				    ,p_priority
				    ,p_updated_by
				    ,p_user_task_type
				    ,p_last_update_date                     /* Bug 2372652 */
				    );
                                ELSE
                	            update_mmtt(p_transaction_temp_id
				    ,p_priority
				    ,from_status
				    ,from_status
				    ,p_updated_by
				    ,p_user_task_type
				    ,p_task_type);
                                END IF;
				update_wdt(p_transaction_temp_id
					   , p_task_id
					   , p_priority
					   , from_status
					   , to_status
					   , p_person_id
					   , p_person_resource_id
					   , p_updated_by
					   , p_user_task_type
					   , p_task_type);
			END IF;
		END IF;
	END IF;

EXCEPTION
	WHEN fnd_api.g_exc_error THEN
		x_return_status := fnd_api.g_ret_sts_error ;
		inv_rsv_trigger_global.g_from_trigger := FALSE;

	WHEN fnd_api.g_exc_unexpected_error THEN
		x_return_status := fnd_api.g_ret_sts_unexp_error ;
		inv_rsv_trigger_global.g_from_trigger := FALSE;

	WHEN OTHERS THEN
		x_return_status := fnd_api.g_ret_sts_unexp_error ;
		inv_rsv_trigger_global.g_from_trigger := FALSE;

	IF (fnd_msg_pub.check_msg_level
		(fnd_msg_pub.g_msg_lvl_unexp_error)) THEN
		fnd_msg_pub.add_exc_msg(g_pkg_name, c_api_name);
	END IF;


END task_manipulator;

PROCEDURE mydebug(msg in varchar2)
  IS
     l_msg VARCHAR2(5100);
     l_ts VARCHAR2(30);
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
--   select to_char(sysdate,'MM/DD/YYYY HH:MM:SS') INTO l_ts from dual;
--   l_msg:=l_ts||'  '||msg;

   l_msg := msg;

   inv_mobile_helper_functions.tracelog
     (p_err_msg => l_msg,
      p_module => 'WMS_CONTROL_BOARD',
      p_level => 4);

END;


END WMS_CONTROL_BOARD;

/
