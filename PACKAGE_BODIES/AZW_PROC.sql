--------------------------------------------------------
--  DDL for Package Body AZW_PROC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AZW_PROC" AS
/* $Header: AZWPROCB.pls 115.46 2003/04/08 08:50:04 sbandi ship $: */


  TYPE status_rec_t IS RECORD (
	item_type	az_processes.item_type%TYPE,
	process_name	az_processes.process_name%TYPE,
	context_id	az_processes.context_id%TYPE);

  TYPE status_tbl_t IS TABLE OF status_rec_t INDEX BY BINARY_INTEGER;

  group_status_tbl	status_tbl_t;

  group_status_index	BINARY_INTEGER DEFAULT 0;

  TYPE process_rec_t IS RECORD (
    item_type         az_processes.item_type%TYPE,
    process_name      az_processes.process_name%TYPE,
    parent_id         az_processes.parent_id%TYPE,
    context_type      az_processes.context_type%TYPE,
    display_order     az_processes.display_order%TYPE,
    process_type      az_processes.process_type%TYPE);

  TYPE process_tbl_t IS TABLE OF process_rec_t INDEX BY BINARY_INTEGER;

  msg_delimiter VARCHAR2(1) := '^';

    v_language_code   fnd_languages.language_code%TYPE;
    v_language        fnd_languages.nls_language%TYPE;
    v_days            VARCHAR2(8);
    v_done            VARCHAR2(8);
    v_skip            VARCHAR2(8);
    v_new_task_key    wf_items.item_key%TYPE;
    g_current_mode    az_groups.process_type%TYPE;

  PROCEDURE update_hierarchy_status(p_item_type    IN VARCHAR2,
                                    p_process_name IN VARCHAR2,
                                    p_context_id   IN VARCHAR2);

--
-- get_parent_group
--
-- Private function. Called by get_group_color
-- Given a  process' parent id, find the process parent group's parent
-- Returns 'NONE' if there is no more parent
--

  FUNCTION get_parent_group(p_parent_id IN VARCHAR2) RETURN VARCHAR2
   IS
     v_parent_gr_id az_groups.group_id%TYPE;
  BEGIN
--    dbms_output.put_line(' getting parent for ' || p_parent_id);

  	  SELECT azg1.group_id
          INTO   v_parent_gr_id
          FROM   az_groups azg1, az_groups azg2
          WHERE  azg2.group_id = p_parent_id
	  AND	 azg1.process_type = azg2.process_type
	  AND	 azg1.process_type = g_current_mode
          AND    azg1.group_id = azg2.hierarchy_parent_id;

    RETURN v_parent_gr_id;

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
          v_parent_gr_id := 'NONE';
    	RETURN v_parent_gr_id;
     WHEN app_exception.application_exception THEN
	RAISE;
     WHEN OTHERS THEN
     --DBMS_OUTPUT.PUT_LINE('error: group_hierarchy_tree_not_found: ' || SQLERRM);
     fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
     fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
     fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
     fnd_message.set_token('AZW_ERROR_PROC','azw_proc.get_parent_group');
     fnd_message.set_token('AZW_ERROR_STMT','select group_id from az_groups');
     APP_EXCEPTION.RAISE_EXCEPTION;
  END get_parent_group;


--
-- PARSE_CTXT_ID_TASK
--
-- Public function. Called by get_group_color.
-- Given a concatenated node_id for a task, retrieve context_id for that node.
-- Separator is '.'
--
  FUNCTION parse_ctxt_id_task(node_id IN VARCHAR2) RETURN NUMBER IS

    v_first_step  PLS_INTEGER;
    v_second_step PLS_INTEGER;
    v_ctx_id   az_processes.context_id%TYPE;

  BEGIN
--    dbms_output.put_line('parse context id');

		v_first_step := INSTR(node_id, '.', 1, 2);
		v_second_step := INSTR(node_id, '.',-1, 1);
		v_ctx_id := SUBSTR(node_id, v_first_step + 1, v_second_step - v_first_step - 1);

	    RETURN v_ctx_id;
 EXCEPTION
     WHEN app_exception.application_exception THEN
	RAISE;
     WHEN OTHERS THEN
     fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
     fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
     fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
     fnd_message.set_token('AZW_ERROR_PROC','azw_proc.parse_ctxt_id_task');
     fnd_message.set_token('AZW_ERROR_STMT','NODE_ID :'|| node_id);
     APP_EXCEPTION.RAISE_EXCEPTION;
 END parse_ctxt_id_task;


--
-- process_not_found
--
-- Private function. Called by set_process.
-- Given a process and a context id, check if it already exits in the
-- az_processes table. If the process is already in the table,
-- return FALSE; otherwise return TRUE.
--
  FUNCTION process_not_found(proc process_rec_t, p_ctx_id NUMBER) RETURN BOOLEAN
    IS
  v_cnt PLS_INTEGER DEFAULT 0;
  BEGIN
--    dbms_output.put_line('process not found');

    SELECT count(*)
    INTO v_cnt
    FROM  az_processes ap
    WHERE    ap.item_type = proc.item_type
    AND    ap.process_name = proc.process_name
    AND    ap.context_id = p_ctx_id;

    IF v_cnt = 0 THEN
    	RETURN TRUE;
    ELSE
    	RETURN FALSE;
    END IF;

  EXCEPTION
     WHEN app_exception.application_exception THEN
	RAISE;
    WHEN OTHERS THEN
        fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
        fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
        fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
        fnd_message.set_token('AZW_ERROR_PROC','azw_proc.process_not_found');
        fnd_message.set_token('AZW_ERROR_STMT','select count(*) from az_processes');
        APP_EXCEPTION.RAISE_EXCEPTION;
  END process_not_found;


--
-- PARSE_APPLICATION_IDS
--
-- Public function. Called by populate_product_flows.
-- Parses a string of app ids, returning one appl_id  at a time.
--
  FUNCTION parse_application_ids(p_application_ids IN VARCHAR2,
                                 id_cnt IN NUMBER)

  RETURN NUMBER IS

    prev_cnt PLS_INTEGER DEFAULT 0;
    pres_cnt PLS_INTEGER DEFAULT 0;
    id_length NUMBER DEFAULT 0;
    v_id NUMBER DEFAULT 0;
  BEGIN

	pres_cnt := INSTR(p_application_ids, ',', 1, id_cnt);

        IF id_cnt > 1 THEN
	    prev_cnt := INSTR(p_application_ids, ',', 1, id_cnt - 1);
	    IF ((pres_cnt = 0) AND (prev_cnt <> 0)) THEN
	       pres_cnt := LENGTH(p_application_ids) + 1;
	    END IF;
   	ELSE
	    IF (pres_cnt = 0) THEN
	       v_id := to_number(p_application_ids);
	       RETURN v_id;
	    END IF;
   	END IF;

   	id_length := pres_cnt - prev_cnt - 1;

	v_id := to_number(SUBSTR(p_application_ids, prev_cnt + 1, id_length));

   IF v_id IS NULL THEN
    RETURN -1;
   ELSE
    RETURN v_id;
   END IF;

  EXCEPTION
     WHEN app_exception.application_exception THEN
        APP_EXCEPTION.RAISE_EXCEPTION;
     WHEN OTHERS THEN
     fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
     fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
     fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
     fnd_message.set_token('AZW_ERROR_PROC','azw_proc.parse_application_ids');
     fnd_message.set_token('AZW_ERROR_STMT','UNKNOWN');
     APP_EXCEPTION.RAISE_EXCEPTION;
  END parse_application_ids;


--
-- PARSE_ITEM_TYPE
--
-- Public function.  Called by update_process_xxxx.
-- Given a concatenated node_id, retrieve item_type for that node.
-- Separator is '.'
--
  FUNCTION parse_item_type(node_id IN VARCHAR2) RETURN VARCHAR2 IS

    v_first_sep PLS_INTEGER;
    v_type      az_processes.item_type%TYPE;

  BEGIN

	v_first_sep := INSTR(node_id, '.', 1, 1);
	v_type := SUBSTR(node_id, 1, v_first_sep - 1);
    	RETURN v_type;

  EXCEPTION
  	WHEN app_exception.application_exception THEN
        	RAISE;
  	WHEN OTHERS THEN
     	   fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
     	   fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
     	   fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
     	   fnd_message.set_token('AZW_ERROR_PROC','azw_proc.parse_item_type');
     	   fnd_message.set_token('AZW_ERROR_STMT','NODE_ID:'|| node_id);
     	   APP_EXCEPTION.RAISE_EXCEPTION;
  END parse_item_type;


--
-- PARSE_PROCESS_NAME
--
-- Public function.
-- Given a cocatenated node_id, retrieve process_name for that node.
-- Separator is '.'
--
  FUNCTION parse_process_name(node_id IN VARCHAR2) RETURN VARCHAR2 IS

    v_first_sep  PLS_INTEGER;
    v_second_sep PLS_INTEGER;
    p_name       az_processes.process_name%TYPE;

  BEGIN

	v_first_sep := INSTR(node_id, '.', 1, 1);
	v_second_sep := INSTR(node_id, '.', -1, 1);
	p_name := SUBSTR(node_id, v_first_sep + 1, v_second_sep - v_first_sep - 1);

	    RETURN p_name;

  EXCEPTION
     WHEN app_exception.application_exception THEN
        APP_EXCEPTION.RAISE_EXCEPTION;
     WHEN OTHERS THEN
     fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
     fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
     fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
     fnd_message.set_token('AZW_ERROR_PROC','azw_proc.parse_process_name');
     fnd_message.set_token('AZW_ERROR_STMT','NODE_ID:'|| node_id);
     APP_EXCEPTION.RAISE_EXCEPTION;
  END parse_process_name;

--
-- PARSE_PROCESS_NAME_TASK
--
-- Public function.
-- Given a concatenated node_id for a task, get process_name for that node.
-- Separator is '.'
--
  FUNCTION parse_process_name_task(node_id IN VARCHAR2) RETURN VARCHAR2 IS

    v_first_sep  PLS_INTEGER;
    v_second_sep PLS_INTEGER;
    p_name     az_processes.process_name%TYPE;

  BEGIN

	v_first_sep := INSTR(node_id, '.', 1, 1);
	v_second_sep := INSTR(node_id, '.', 1, 2);
	p_name := SUBSTR(node_id, v_first_sep + 1, v_second_sep - v_first_sep - 1);
    	RETURN p_name;

  EXCEPTION
     WHEN app_exception.application_exception THEN
        APP_EXCEPTION.RAISE_EXCEPTION;
     WHEN OTHERS THEN
     fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
     fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
     fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
     fnd_message.set_token('AZW_ERROR_PROC','azw_proc.parse_process_name_task');
     fnd_message.set_token('AZW_ERROR_STMT','NODEID:'|| node_id);
     APP_EXCEPTION.RAISE_EXCEPTION;
  END parse_process_name_task;

--
-- PARSE_CONTEXT_ID
--
-- Public function.
-- Given a concatenated node_id, retrieve context_id for that node.
-- Separator is '.'
--
  FUNCTION parse_context_id(node_id IN VARCHAR2) RETURN VARCHAR2 IS

    v_last_sep PLS_INTEGER;
    v_len      PLS_INTEGER;
    v_ctx_id   az_processes.context_id%TYPE;

  BEGIN

	v_last_sep := INSTR(node_id, '.', -1, 1);
	v_len := LENGTH(node_id);
	v_ctx_id := SUBSTR(node_id, v_last_sep + 1, v_len - v_last_sep);
	RETURN v_ctx_id;

  EXCEPTION
     WHEN app_exception.application_exception THEN
        APP_EXCEPTION.RAISE_EXCEPTION;
     WHEN OTHERS THEN
     fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
     fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
     fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
     fnd_message.set_token('AZW_ERROR_PROC','azw_proc.parse_context_id');
     fnd_message.set_token('AZW_ERROR_STMT','NODE_ID:'||node_id);
     APP_EXCEPTION.RAISE_EXCEPTION;
  END parse_context_id;


--
-- PARSE_ITEM_KEY
--
-- Public function.
-- Given a concatenated node_id for a task , get item key for that task.
-- Separator is '.'
--
  FUNCTION parse_item_key(node_id IN VARCHAR2) RETURN VARCHAR2 IS

    v_last_sep PLS_INTEGER;
    v_len      PLS_INTEGER;
    itm_k      wf_items.item_key%TYPE;

  BEGIN

	v_last_sep := INSTR(node_id, '.', -1, 1);
	v_len := LENGTH(node_id);
	itm_k := SUBSTR(node_id, v_last_sep + 1, v_len - v_last_sep);

	RETURN itm_k;

  EXCEPTION
     WHEN app_exception.application_exception THEN
	RAISE;
     WHEN OTHERS THEN
     fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
     fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
     fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
     fnd_message.set_token('AZW_ERROR_PROC','azw_proc.parse_item_key');
     fnd_message.set_token('AZW_ERROR_STMT','NODE_ID:'|| node_id);
     APP_EXCEPTION.RAISE_EXCEPTION;
  END parse_item_key;


--
-- GET_GROUP_COLOR
--
-- Public function.  Called by step detail form
-- Given a node id for a task, return the color of its root group
-- to which it belongs
--
  FUNCTION get_group_color(node_id IN VARCHAR2) RETURN VARCHAR2
   IS

     v_process_parent_id az_processes.parent_id%TYPE;
     v_process_item_type az_processes.item_type%TYPE;
     v_process_name      az_processes.process_name%TYPE;
     v_process_ctxt_id   az_processes.context_id%TYPE;
     p_group_id          az_groups.group_id%TYPE;
     v_group_color       az_groups.color_code%TYPE;
     p_node_id           VARCHAR2(300);

  BEGIN
     p_node_id           := node_id;
     v_process_item_type := parse_item_type(p_node_id);
     v_process_name      := parse_process_name_task(p_node_id);
     v_process_ctxt_id   := parse_ctxt_id_task(p_node_id);

	BEGIN
	     SELECT parent_id
	     INTO v_process_parent_id
	     FROM az_processes
		 WHERE item_type    = v_process_item_type
		 AND   process_name = v_process_name
		 AND   context_id   = v_process_ctxt_id;
  	EXCEPTION
	     WHEN OTHERS THEN
	     fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	     fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	     fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	     fnd_message.set_token('AZW_ERROR_PROC','azw_proc.get_group_color');
	     fnd_message.set_token('AZW_ERROR_STMT','select parent_id from az_processes');
	     APP_EXCEPTION.RAISE_EXCEPTION;
	END;

     p_group_id := v_process_parent_id;

     WHILE (p_group_id <> 'NONE') LOOP
        v_process_parent_id := p_group_id;
        p_group_id          := get_parent_group(v_process_parent_id);
     END LOOP;

	BEGIN
	     SELECT color_code
	     INTO   v_group_color
	     FROM   az_groups
	     WHERE  group_id = v_process_parent_id
		 AND    process_type = g_current_mode;

	     RETURN v_group_color;

  	EXCEPTION
	     WHEN OTHERS THEN
	     fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	     fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	     fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	     fnd_message.set_token('AZW_ERROR_PROC','azw_proc.get_group_color');
	     fnd_message.set_token('AZW_ERROR_STMT','select color_code from az_groups');
	     APP_EXCEPTION.RAISE_EXCEPTION;
	END;
  EXCEPTION
     WHEN app_exception.application_exception THEN
     	APP_EXCEPTION.RAISE_EXCEPTION;
     WHEN OTHERS THEN
     fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
     fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
     fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
     fnd_message.set_token('AZW_ERROR_PROC','azw_proc.get_group_color');
     fnd_message.set_token('AZW_ERROR_STMT','UNKNOWN');
     APP_EXCEPTION.RAISE_EXCEPTION;
  END get_group_color;

--
-- get_context_name
--
-- Private function.  Called by set_hierarchy_display_name.
--
  FUNCTION get_context_name(id IN VARCHAR2, ctx_table IN context_tbl_t)
    RETURN VARCHAR2 IS

  BEGIN

    FOR i IN 1..ctx_table.COUNT LOOP
      IF ctx_table(i).context_id = TO_NUMBER(id) THEN
        RETURN ctx_table(i).context_name;
      END IF;
    END LOOP;

    RETURN '???';

  EXCEPTION
     WHEN OTHERS THEN
     fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
     fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
     fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
     fnd_message.set_token('AZW_ERROR_PROC','azw_proc.get_context_name');
     fnd_message.set_token('AZW_ERROR_STMT','UNKNOWN');
     APP_EXCEPTION.RAISE_EXCEPTION;
  END get_context_name;

--
-- get_context_type
--
-- Private function.  Called by wrapper_azw_start.
-- Given a process item type, process name and context id return
-- it's context type.
--
  FUNCTION get_context_type(p_item_type IN VARCHAR2,
			    p_process_name IN VARCHAR2,
			    p_context_id IN NUMBER)
    RETURN VARCHAR2 IS

    v_ctxt_type    az_processes.context_type%TYPE;

  BEGIN

    IF (p_context_id > -1) THEN
      SELECT waav.text_default
      INTO   v_ctxt_type
      FROM   wf_activity_attributes_vl waav
      WHERE  waav.activity_item_type = p_item_type
      AND    waav.activity_name      = p_process_name
      AND    waav.name               = 'AZW_IA_CTXTYP'
      AND    waav.activity_version =
             (SELECT MAX(activity_version)
              FROM   wf_activity_attributes_vl
              WHERE  activity_item_type = p_item_type
              AND    activity_name      = p_process_name
              AND    name               = 'AZW_IA_CTXTYP');
   END IF;

   RETURN v_ctxt_type;

  EXCEPTION
     WHEN OTHERS THEN
     fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
     fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
     fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
     fnd_message.set_token('AZW_ERROR_PROC','azw_proc.get_context_type');
     fnd_message.set_token('AZW_ERROR_STMT','select text_default from wf_activity_attributes_vl');
     APP_EXCEPTION.RAISE_EXCEPTION;

  END get_context_type;

-- get_opm_context_name
-- Private function. Called by get_context_name.
-- Executes dynamic sql and returns the name of opmcontexts

  FUNCTION get_opm_context_name(ctx_type IN VARCHAR2, ctx_id IN NUMBER)
    RETURN VARCHAR2 IS

    curs         integer;
    rows         integer;
    sqlstatement az_contexts_sql.SQL_STATEMENT%TYPE;
    v_ctxt_name  az_processes.context_name%TYPE;

  BEGIN

     v_ctxt_name := NULL;

     SELECT sql_statement
     INTO   sqlstatement
     FROM   az_contexts_sql
     WHERE  context = ctx_type
     AND    purpose = 'GET_NAME';

     curs := DBMS_SQL.OPEN_CURSOR;
     DBMS_SQL.PARSE(curs, sqlstatement, DBMS_SQL.NATIVE);

     DBMS_SQL.DEFINE_COLUMN(curs, 1, v_ctxt_name, 80);
     DBMS_SQL.BIND_VARIABLE(curs, ':ctx_id', ctx_id);

     rows := DBMS_SQL.EXECUTE(curs);
     rows := DBMS_SQL.FETCH_ROWS(curs);

     DBMS_SQL.COLUMN_VALUE(curs, 1, v_ctxt_name);
     DBMS_SQL.CLOSE_CURSOR(curs);

     RETURN v_ctxt_name;

    EXCEPTION
    	WHEN OTHERS THEN
	    IF DBMS_SQL.IS_OPEN(curs) then
		  DBMS_SQL.CLOSE_CURSOR(curs);
	     END IF;

	     fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	     fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	     fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	     fnd_message.set_token('AZW_ERROR_PROC','azw_proc.get_opm_context_name');
	     fnd_message.set_token('AZW_ERROR_STMT','UNKNOWN');
	     APP_EXCEPTION.RAISE_EXCEPTION;

  END get_opm_context_name;

--
-- get_context_name
--
-- Private function.  Called by AIWStart.
-- Given a context type and a context id find the context name.
--
  FUNCTION get_context_name(ctx_type IN VARCHAR2, ctx_id IN NUMBER)
    RETURN VARCHAR2 IS

    v_ctxt_name az_processes.context_name%TYPE;

    BEGIN

    IF (ctx_type = 'BG') THEN
	BEGIN
	      SELECT   name INTO v_ctxt_name
	      FROM     per_business_groups
	      WHERE    date_from < SYSDATE
	      AND      (date_to IS NULL
	      OR        date_to > SYSDATE)
	      AND      organization_id = ctx_id;
	EXCEPTION
	     WHEN OTHERS THEN
	     fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	     fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	     fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	     fnd_message.set_token('AZW_ERROR_PROC','azw_proc.get_context_name');
	     fnd_message.set_token('AZW_ERROR_STMT','select name from per_business_groups');
	     APP_EXCEPTION.RAISE_EXCEPTION;
	END;

   ELSIF (ctx_type = 'IO') THEN
	BEGIN
	      SELECT   organization_name INTO v_ctxt_name
	      FROM     org_organization_definitions
	      WHERE    user_definition_enable_date < SYSDATE
	      AND      (disable_date IS NULL
	      OR        disable_date > SYSDATE)
	      AND      organization_id = ctx_id;
	EXCEPTION
	     WHEN OTHERS THEN
	     fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	     fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	     fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	     fnd_message.set_token('AZW_ERROR_PROC','azw_proc.get_context_name');
	     fnd_message.set_token('AZW_ERROR_STMT','select name from org_organization_definitions');
	     APP_EXCEPTION.RAISE_EXCEPTION;
	END;

   ELSIF (ctx_type = 'OU') THEN
	BEGIN
	      SELECT   name INTO v_ctxt_name
	      FROM     hr_operating_units
	      WHERE    organization_id = ctx_id
	      AND       date_from < SYSDATE
	      AND      (date_to IS NULL
	      OR        date_to > SYSDATE);
	EXCEPTION
	     WHEN OTHERS THEN
	     fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	     fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	     fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	     fnd_message.set_token('AZW_ERROR_PROC','azw_proc.get_context_name');
	     fnd_message.set_token('AZW_ERROR_STMT','select name from hr_operating_units');
	     APP_EXCEPTION.RAISE_EXCEPTION;
	END;

   ELSIF (ctx_type = 'SOB') THEN
	BEGIN
	      SELECT   name INTO v_ctxt_name
	      FROM     gl_sets_of_books
	      WHERE    set_of_books_id = ctx_id;
	EXCEPTION
	     WHEN OTHERS THEN
	     fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	     fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	     fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	     fnd_message.set_token('AZW_ERROR_PROC','azw_proc.get_context_name');
	     fnd_message.set_token('AZW_ERROR_STMT','select name from gl_sets_of_books');
	     APP_EXCEPTION.RAISE_EXCEPTION;
	END;

       ELSIF (ctx_type = 'OPMCOM' OR ctx_type = 'OPMORG') THEN
	BEGIN
	      v_ctxt_name := get_opm_context_name(ctx_type, ctx_id);
	EXCEPTION
	     WHEN OTHERS THEN
	     fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	     fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	     fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	     fnd_message.set_token('AZW_ERROR_PROC','azw_proc.get_context_name');
	     fnd_message.set_token('AZW_ERROR_STMT','select name from sy_orgn_mst');
	     APP_EXCEPTION.RAISE_EXCEPTION;
	END;

   END IF;

   IF v_ctxt_name is NULL THEN
      v_ctxt_name := 'NONE';
   END IF;

   RETURN v_ctxt_name;

  EXCEPTION
     WHEN app_exception.application_exception THEN
     	RAISE;
     WHEN OTHERS THEN
     	fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
     	fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
     	fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
     	fnd_message.set_token('AZW_ERROR_PROC','azw_proc.get_context_name');
     	fnd_message.set_token('AZW_ERROR_STMT','UNKNOWN');
     	APP_EXCEPTION.RAISE_EXCEPTION;
  END get_context_name;


--
-- get_application_name
--
-- Public function.  Called by various procedures.
-- Given an application id, find the corresponding application name.
--
  FUNCTION get_application_name(appl_id NUMBER)
    RETURN VARCHAR2 IS

    v_application_name fnd_application_vl.application_name%TYPE;
    BEGIN

      SELECT   application_name
      INTO     v_application_name
      FROM     fnd_application_vl
      WHERE    application_id = appl_id;

      RETURN v_application_name;


    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_application_name := 'NONE';
        RETURN v_application_name;
      WHEN app_exception.application_exception THEN
	APP_EXCEPTION.RAISE_EXCEPTION;
      WHEN OTHERS THEN
        -- DBMS_OUTPUT.PUT_LINE('error: get_application_name: ' || SQLERRM);
     	fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
     	fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
     	fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
     	fnd_message.set_token('AZW_ERROR_PROC','azw_proc.get_application_name');
     	fnd_message.set_token('AZW_ERROR_STMT','select application_name from fnd_application_vl');
	APP_EXCEPTION.RAISE_EXCEPTION;
  END get_application_name;


--
-- get_lookup_meaning
--
-- Public function.  Called by various procedures.
-- Given a lookup code, find the corresponding meaning.
--
  FUNCTION get_lookup_meaning(code VARCHAR2)
    RETURN VARCHAR2 IS

    v_meaning fnd_lookups.meaning%TYPE;

    BEGIN

      SELECT   meaning
      INTO     v_meaning
      FROM     fnd_lookups
      WHERE    lookup_type = 'AZ_PROCESS_GROUPS'
      AND      lookup_code = code;

      RETURN v_meaning;

    EXCEPTION
      WHEN app_exception.application_exception THEN
	APP_EXCEPTION.RAISE_EXCEPTION;
      WHEN NO_DATA_FOUND THEN
        v_meaning := 'NONE';
        RETURN v_meaning;
      WHEN OTHERS THEN
        -- DBMS_OUTPUT.PUT_LINE('error: get_lookup_meaning: ' || SQLERRM);
     	fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
     	fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
     	fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
     	fnd_message.set_token('AZW_ERROR_PROC','azw_proc.get_lookup_meaning');
     	fnd_message.set_token('AZW_ERROR_STMT','select meaning from fnd_lookups');
     	APP_EXCEPTION.RAISE_EXCEPTION;
    END get_lookup_meaning;


--
-- task_init
--
-- Private procedure.  Called by get_hierarchy each time the form for
-- hierarchy is shown.
-- Gets the display names of days,done,skip
-- which are part of task label for the current language
--
   PROCEDURE task_init IS
   BEGIN
	IF (v_language_code is null) THEN
        BEGIN
            select distinct language_code, nls_language
            into v_language_code, v_language
            from fnd_languages
            where NLS_LANGUAGE =
              SUBSTR(USERENV('LANGUAGE'), 1, INSTR(USERENV('LANGUAGE'), '_')-1);
        EXCEPTION
            WHEN app_exception.application_exception THEN
                RAISE;
            WHEN OTHERS THEN
                fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
                fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
                fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
                fnd_message.set_token('AZW_ERROR_PROC','azw_hier.get_hierarchy')
;
                fnd_message.set_token('AZW_ERROR_STMT','select language_code ..
from fnd_languages');
                APP_EXCEPTION.RAISE_EXCEPTION;
        END;
        END IF;
	BEGIN
	    SELECT      substr(text, 1, 8)
	    INTO        v_days
	    FROM        wf_resources
	    WHERE       language = v_language_code
	    AND         type     = 'WFTKN'
	    AND         name     = 'DAYS';
	EXCEPTION
	     WHEN OTHERS THEN
	     fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	     fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	     fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	     fnd_message.set_token('AZW_ERROR_PROC','azw_proc.task_init');
	     fnd_message.set_token('AZW_ERROR_STMT','select into v_days');
	     APP_EXCEPTION.RAISE_EXCEPTION;
	END;

	BEGIN
	    SELECT      substr(text, 1, 8)
	    INTO        v_done
	    FROM        wf_resources
	    WHERE       language = v_language_code
	    AND         type     = 'WFTKN'
	    AND         name     = 'WFMON_DONE';
	EXCEPTION
	     WHEN OTHERS THEN
	     fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	     fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	     fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	     fnd_message.set_token('AZW_ERROR_PROC','azw_proc.task_init');
	     fnd_message.set_token('AZW_ERROR_STMT','select into v_done');
	     APP_EXCEPTION.RAISE_EXCEPTION;
	END;

	BEGIN
	    SELECT      substr(text, 1, 8)
	    INTO        v_skip
	    FROM        wf_resources
	    WHERE       language = v_language_code
	    AND         type     = 'WFTKN'
	    AND         name     = 'WFMON_SKIP';
	EXCEPTION
	     WHEN OTHERS THEN
	     fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	     fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	     fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	     fnd_message.set_token('AZW_ERROR_PROC','azw_proc.task_init');
	     fnd_message.set_token('AZW_ERROR_STMT','select into v_skip');
	     APP_EXCEPTION.RAISE_EXCEPTION;
	END;

 END task_init;


-- GET_CONTEXT
--
-- Public procedure.  Called by populate_processes and AZW_HIER.
-- Given a context type, retrieve all enabled/valid context ids and
-- store in the given PL/SQL context table.
--
  PROCEDURE get_context(ctx_type IN VARCHAR2, ctx_table OUT NOCOPY context_tbl_t) IS

    i BINARY_INTEGER DEFAULT 0;
    CURSOR bg_cursor IS
      SELECT   organization_id, name
      FROM     per_business_groups
      WHERE    date_from < SYSDATE
      AND      (date_to IS NULL
      OR        date_to > SYSDATE)
      ORDER BY organization_id;

    CURSOR io_cursor IS
      SELECT   organization_id, organization_name
      FROM     org_organization_definitions
      WHERE    user_definition_enable_date < SYSDATE
      AND      (disable_date IS NULL
      OR        disable_date > SYSDATE)
      ORDER BY organization_id;

    CURSOR ou_cursor IS
      SELECT   organization_id, name
      FROM     hr_operating_units
      WHERE    date_from < SYSDATE
      AND      (date_to IS NULL
      OR        date_to > SYSDATE)
      ORDER BY organization_id;

    CURSOR sob_cursor IS
      SELECT   set_of_books_id, name
      FROM     gl_sets_of_books
      ORDER BY set_of_books_id;

    curs         integer;
    rows         integer;
    sqlstatement az_contexts_sql.SQL_STATEMENT%TYPE;
    t1           NUMBER(15);
    t2           varchar2(40);


  BEGIN
--    dbms_output.put_line('get context type=' || ctx_type);

    IF (ctx_type = 'BG') THEN

	BEGIN
	      OPEN bg_cursor;
	      LOOP
		i := i + 1;
		FETCH bg_cursor  INTO ctx_table(i);
		EXIT WHEN bg_cursor%NOTFOUND;
	      END LOOP;
	      CLOSE bg_cursor;
	EXCEPTION
	     WHEN OTHERS THEN
	     fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	     fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	     fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	     fnd_message.set_token('AZW_ERROR_PROC','azw_proc.get_context');
	     fnd_message.set_token('AZW_ERROR_STMT','CURSOR bg_cursor');
	     APP_EXCEPTION.RAISE_EXCEPTION;
	END;

    ELSIF (ctx_type = 'IO') THEN

	BEGIN
	      OPEN io_cursor;
	      LOOP
		i := i + 1;
		FETCH io_cursor INTO ctx_table(i);
		EXIT WHEN io_cursor%NOTFOUND;
	      END LOOP;
	      CLOSE io_cursor;
	EXCEPTION
	     WHEN OTHERS THEN
	     fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	     fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	     fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	     fnd_message.set_token('AZW_ERROR_PROC','azw_proc.get_context');
	     fnd_message.set_token('AZW_ERROR_STMT','CURSOR io_cursor');
	     APP_EXCEPTION.RAISE_EXCEPTION;
	END;

    ELSIF (ctx_type = 'OU') THEN

	BEGIN
	      OPEN ou_cursor;
	      LOOP
		i := i + 1;
		FETCH ou_cursor INTO ctx_table(i);
		EXIT WHEN ou_cursor%NOTFOUND;
	      END LOOP;
	      CLOSE ou_cursor;
	EXCEPTION
	     WHEN OTHERS THEN
	     fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	     fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	     fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	     fnd_message.set_token('AZW_ERROR_PROC','azw_proc.get_context');
	     fnd_message.set_token('AZW_ERROR_STMT','CURSOR ou_cursor');
	     APP_EXCEPTION.RAISE_EXCEPTION;
	END;

    ELSIF (ctx_type = 'SOB') THEN

	BEGIN
	      OPEN sob_cursor;
	      LOOP
		i := i + 1;
		FETCH sob_cursor INTO ctx_table(i);
		EXIT WHEN sob_cursor%NOTFOUND;
	      END LOOP;
	      CLOSE sob_cursor;
	EXCEPTION
	     WHEN OTHERS THEN
	     fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	     fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	     fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	     fnd_message.set_token('AZW_ERROR_PROC','azw_proc.get_context');
	     fnd_message.set_token('AZW_ERROR_STMT','CURSOR sob_cursor');
	     APP_EXCEPTION.RAISE_EXCEPTION;
	END;

       ELSIF (ctx_type = 'OPMCOM' OR ctx_type = 'OPMORG') THEN

	BEGIN
		SELECT sql_statement
      		INTO   sqlstatement
      		FROM   az_contexts_sql
		WHERE  context = ctx_type
     		AND    purpose = 'POPULATE';

		curs := DBMS_SQL.OPEN_CURSOR;
      		DBMS_SQL.PARSE(curs, sqlstatement, DBMS_SQL.NATIVE);

      		DBMS_SQL.DEFINE_COLUMN(curs, 1, t1);
      		DBMS_SQL.DEFINE_COLUMN(curs, 2, t2, 40);

      		rows := DBMS_SQL.EXECUTE(curs);

	      	LOOP
			IF DBMS_SQL.FETCH_ROWS(curs) > 0 THEN

		  		DBMS_SQL.COLUMN_VALUE(curs, 1, t1);
          	  		DBMS_SQL.COLUMN_VALUE(curs, 2, t2);

				IF (t1 IS NOT NULL) THEN
					i := i + 1;
		  			ctx_table(i).context_id := t1;
        	  			ctx_table(i).context_name := t2;
				END IF;

			ELSE
          	  		EXIT;

        		END IF;
		END LOOP;

            	DBMS_SQL.CLOSE_CURSOR(curs);


	EXCEPTION
	     WHEN OTHERS THEN

	     if DBMS_SQL.IS_OPEN(curs) then
		DBMS_SQL.CLOSE_CURSOR(curs);
	     end if;

	     fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	     fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	     fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	     fnd_message.set_token('AZW_ERROR_PROC','azw_proc.get_context');
	     fnd_message.set_token('AZW_ERROR_STMT','CURSOR opm_cursor');
	     APP_EXCEPTION.RAISE_EXCEPTION;
	END;

    END IF;

  EXCEPTION
	WHEN app_exception.application_exception THEN
	    RAISE;
        WHEN OTHERS THEN
        -- DBMS_OUTPUT.PUT_LINE('error: get_context: ' || SQLERRM);
	fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	fnd_message.set_token('AZW_ERROR_PROC','azw_proc.get_context');
	fnd_message.set_token('AZW_ERROR_STMT','UNKNOWN');
	APP_EXCEPTION.RAISE_EXCEPTION;

  END get_context;


--
-- get_processes
--
-- Private procedure.  Called by populate_az_processes.
-- Retrieve all workflow runnable processes for installed products
-- and store them in the given PL/SQL table.
--
  PROCEDURE get_processes(proc_table OUT NOCOPY process_tbl_t) IS

    i BINARY_INTEGER DEFAULT 0;

    CURSOR valid_processes_c IS
      SELECT  distinct azpf.item_type, azpf.process_name, azpf.parent_id,
              azpf.context_type, azpf.display_order, azpf.process_type
      FROM     az_product_flows azpf, fnd_product_installations fpi
      WHERE   azpf.application_id = fpi.application_id
      AND     fpi.status = 'I';

  BEGIN
--dbms_output.put_line('get processes');

    OPEN valid_processes_c;
    LOOP
      i := i + 1;
      FETCH valid_processes_c INTO proc_table(i);
      EXIT WHEN valid_processes_c%NOTFOUND;
    END loop;
    CLOSE valid_processes_c;

  EXCEPTION
    WHEN OTHERS THEN
      CLOSE valid_processes_c;
	fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	fnd_message.set_token('AZW_ERROR_PROC','azw_proc.get_processes');
	fnd_message.set_token('AZW_ERROR_STMT','CURSOR valid_processes_c');
	APP_EXCEPTION.RAISE_EXCEPTION;
  END get_processes;


--
-- insert_az_processes
--
-- Private procedure. Called by populate_processes.
-- Insert the process into az_processes for each context.
-- (Cartesian product)
-- Check if the process with the context is already in the table; insert
-- the one not already in the table.
--
  PROCEDURE insert_az_processes(proc IN process_rec_t,ctxts IN context_tbl_t) IS

  BEGIN

    FOR j IN 1..ctxts.COUNT LOOP

      IF process_not_found(proc, ctxts(j).context_id) THEN
	   BEGIN
	        INSERT INTO az_processes(item_type, process_name, context_id,
                                 display_order, complete_flag,
                                 context_type, context_name, comments,parent_id,
				 status_code, process_type)
       		VALUES (proc.item_type, proc.process_name,
               		 ctxts(j).context_id, proc.display_order, 'N', proc.context_type,
                	 ctxts(j).context_name, NULL, proc.parent_id,
			 'N', proc.process_type);

		group_status_index :=  group_status_index + 1;
		group_status_tbl( group_status_index ).item_type := proc.item_type;
		group_status_tbl( group_status_index ).process_name := proc.process_name;
		group_status_tbl( group_status_index ).context_id := ctxts(j).context_id;
  	   EXCEPTION
     		WHEN OTHERS THEN
		fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
		fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
		fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
		fnd_message.set_token('AZW_ERROR_PROC','azw_proc.insert_az_processes(param1, param2)');
		fnd_message.set_token('AZW_ERROR_STMT','insert into az_processes');
		APP_EXCEPTION.RAISE_EXCEPTION;
	   END;

      ELSE
	   BEGIN
		UPDATE az_processes
		SET    context_name = ctxts(j).context_name
		WHERE  item_type = proc.item_type
		AND    process_name = proc.process_name
		AND    context_id = ctxts(j).context_id
		AND    context_name <>  ctxts(j).context_name;
  	   EXCEPTION
    		WHEN OTHERS THEN
		fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
		fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
		fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
		fnd_message.set_token('AZW_ERROR_PROC','azw_proc.insert_az_processes(param1, param2)');
		fnd_message.set_token('AZW_ERROR_STMT','update az_processes');
		APP_EXCEPTION.RAISE_EXCEPTION;
	   END;
      END IF;
   END LOOP;

  EXCEPTION
   WHEN app_exception.application_exception THEN
	RAISE;
   WHEN OTHERS THEN
     -- DBMS_OUTPUT.PUT_LINE('error: insert_az_processes(context): ' || SQLERRM);
	fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	fnd_message.set_token('AZW_ERROR_PROC','azw_proc.insert_az_processes(param1, param2)');
	fnd_message.set_token('AZW_ERROR_STMT','UNKNOWN');
	APP_EXCEPTION.RAISE_EXCEPTION;

  END insert_az_processes;


--
-- insert_az_processes
--
-- Private procedure. Called by populate_processes.
-- Insert the process without context into az_processes.
-- Check if the process with the context is already in the table; insert
-- the one not already in the table.
-- The context_id in az_processes is defaulted to -1.
--
  PROCEDURE insert_az_processes(proc IN process_rec_t) IS

  BEGIN

    IF process_not_found(proc, -1) THEN
	BEGIN
	      INSERT INTO az_processes (item_type, process_name, context_id,
			display_order, complete_flag,
			context_type, context_name, comments, parent_id,
			status_code, process_type)
	      VALUES (proc.item_type, proc.process_name, -1, proc.display_order, 'N',
		      'NONE', NULL, NULL, proc.parent_id,
			'N', proc.process_type);
  	EXCEPTION
    	    WHEN OTHERS THEN
		fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
		fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
		fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
		fnd_message.set_token('AZW_ERROR_PROC','azw_proc.insert_az_processes(param1)');
		fnd_message.set_token('AZW_ERROR_STMT','insert into az_processes');
		APP_EXCEPTION.RAISE_EXCEPTION;
	END;

	group_status_index :=  group_status_index + 1;
	group_status_tbl( group_status_index ).item_type := proc.item_type;
	group_status_tbl( group_status_index ).process_name := proc.process_name;
	group_status_tbl( group_status_index ).context_id := '-1';

    END IF;

  EXCEPTION
     WHEN app_exception.application_exception THEN
	RAISE;
     WHEN OTHERS THEN
     -- DBMS_OUTPUT.PUT_LINE('error: insert_az_processes: ' || SQLERRM);
	fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	fnd_message.set_token('AZW_ERROR_PROC','azw_proc.insert_az_processes(param1)');
	fnd_message.set_token('AZW_ERROR_STMT','UNKNOWN');
	APP_EXCEPTION.RAISE_EXCEPTION;

  END insert_az_processes;


--
-- populate_processes
--
-- Private procedure.  Called by populate_az_processes.
--
  PROCEDURE populate_processes(bg_ctx    IN context_tbl_t,
                               io_ctx    IN context_tbl_t,
                               ou_ctx    IN context_tbl_t,
                               sob_ctx   IN context_tbl_t,
			       opmcom_ctx   IN context_tbl_t,
			       opmorg_ctx   IN context_tbl_t,
                               processes IN process_tbl_t) IS

  BEGIN
--    dbms_output.put_line('populate processes');

    FOR i IN 1..processes.COUNT LOOP
      IF (UPPER(processes(i).context_type) LIKE '%BG%') THEN
         insert_az_processes(processes(i), bg_ctx);
      ELSIF (UPPER(processes(i).context_type) LIKE '%IO%') THEN
         insert_az_processes(processes(i), io_ctx);
      ELSIF (UPPER(processes(i).context_type) LIKE '%OU%') THEN
         insert_az_processes(processes(i), ou_ctx);
      ELSIF (UPPER(processes(i).context_type) LIKE '%SOB%') THEN
         insert_az_processes(processes(i), sob_ctx);
      ELSIF (UPPER(processes(i).context_type) LIKE '%OPMCOM%') THEN
         insert_az_processes(processes(i), opmcom_ctx);
      ELSIF (UPPER(processes(i).context_type) LIKE '%OPMORG%') THEN
         insert_az_processes(processes(i), opmorg_ctx);
      ELSE
         insert_az_processes(processes(i));
      END IF;
    END LOOP;
    COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
        --DBMS_OUTPUT.PUT_LINE('error: populate_processes: ' || SQLERRM);
	fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	fnd_message.set_token('AZW_ERROR_PROC','azw_proc.populate_processes');
	fnd_message.set_token('AZW_ERROR_STMT','UNKNOWN');
	APP_EXCEPTION.RAISE_EXCEPTION;
  END populate_processes;

--
-- disable_invalid_opm_processes
--
-- Private procedure.  Called by disable_invalid_processes.
-- Delete processes that are not valid  in OPMCOM, OPMORG
-- by executing dynamic sql.

   PROCEDURE disable_invalid_opm_processes(ctx_type IN VARCHAR2) IS

    curs         integer;
    rows         integer;
    sqlstatement az_contexts_sql.SQL_STATEMENT%TYPE;

   BEGIN

     SELECT sql_statement
     INTO   sqlstatement
     FROM   az_contexts_sql
     WHERE  context = ctx_type
     AND    purpose = 'DELETE';

     curs := DBMS_SQL.OPEN_CURSOR;
     DBMS_SQL.PARSE(curs, sqlstatement, DBMS_SQL.NATIVE);
     DBMS_SQL.BIND_VARIABLE(curs, ':ctx_type', ctx_type);

     rows := DBMS_SQL.EXECUTE(curs);

     DBMS_SQL.CLOSE_CURSOR(curs);

    EXCEPTION
    	WHEN OTHERS THEN
	    IF DBMS_SQL.IS_OPEN(curs) then
		  DBMS_SQL.CLOSE_CURSOR(curs);
	     END IF;

	     fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	     fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	     fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	     fnd_message.set_token('AZW_ERROR_PROC','azw_proc.disable_invalid_opm_processes');
	     fnd_message.set_token('AZW_ERROR_STMT','UNKNOWN');
	     APP_EXCEPTION.RAISE_EXCEPTION;

   END disable_invalid_opm_processes;

--
-- disable_invalid_processes
--
-- Private procedure.  Called by populate_az_processes.
-- Delete processes that are not valid as of the date this procedure is
-- executed.  These processes include those in BG, IO, OU types.  SOB type
-- doesn't define from/to dates.
--
  PROCEDURE disable_invalid_processes IS

    cnt               PLS_INTEGER DEFAULT 0;
    v_installed_prods PLS_INTEGER DEFAULT 0;
    v_item_type       az_processes.item_type%TYPE;
    v_process_name    az_processes.process_name%TYPE;

    CURSOR invalid_bg_processes_cursor IS
      SELECT  ap.item_type, ap.process_name, ap.context_id
      FROM    az_processes ap,
              per_business_groups pbg
      WHERE   ap.context_type = 'BG'
      AND     ap.process_type = g_current_mode
      AND     ap.context_id > -1
      AND     ap.context_id = pbg.organization_id
      AND     (pbg.date_to IS NOT NULL
      AND      pbg.date_from IS NOT NULL
      AND      (pbg.date_from > SYSDATE
      OR        pbg.date_to < SYSDATE));

    CURSOR invalid_io_processes_cursor IS
      SELECT  ap.item_type, ap.process_name, ap.context_id
      FROM    az_processes ap,
              org_organization_definitions ood
      WHERE   ap.context_type = 'IO'
      AND     ap.process_type = g_current_mode
      AND     ap.context_id > -1
      AND     ap.context_id = ood.organization_id
      AND     (ood.user_definition_enable_date IS NOT NULL
      AND      ood.disable_date IS NOT NULL
      AND      (ood.user_definition_enable_date > SYSDATE
      OR        ood.disable_date < SYSDATE));

    CURSOR invalid_ou_processes_cursor IS
      SELECT  ap.item_type, ap.process_name, ap.context_id
      FROM    az_processes ap,
              hr_operating_units hou
      WHERE   ap.context_type = 'OU'
      AND     ap.process_type = g_current_mode
      AND     ap.context_id > -1
      AND     ap.context_id = hou.organization_id
      AND     (hou.date_from IS NOT NULL
      AND      hou.date_to IS NOT NULL
      AND      (hou.date_from > SYSDATE
      OR        hou.date_to < SYSDATE));

  BEGIN
--    dbms_output.put_line('disable invalid process');
-- get rid of non-existent BG processes from az_processes
      DELETE from az_processes
      WHERE  context_type = 'BG'
      AND    context_id not in
             ( select distinct organization_id
               from per_business_groups);
-- get rid of non-existent IO processes from az_processes
      DELETE from az_processes
      WHERE  context_type = 'IO'
      AND    context_id not in
             ( select distinct organization_id
               from org_organization_definitions);
-- get rid of non-existent OU processes from az_processes
      DELETE from az_processes
      WHERE  context_type = 'OU'
      AND    context_id not in
             ( select distinct organization_id
               from hr_operating_units);

      disable_invalid_opm_processes('OPMCOM');
--      disable_invalid_opm_processes('OPMORG');


    	BEGIN
	    SELECT COUNT(*)
	    INTO  cnt
	    FROM  az_processes;
	EXCEPTION
	    WHEN OTHERS THEN
	    fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	    fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	    fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	    fnd_message.set_token('AZW_ERROR_PROC','azw_proc.disable_invalid_processes');
	    fnd_message.set_token('AZW_ERROR_STMT','select count(*) from az_processes');
	    APP_EXCEPTION.RAISE_EXCEPTION;
	END ;

    IF (cnt <> 0) THEN
	BEGIN
	      FOR invalid_process IN invalid_bg_processes_cursor LOOP
		DELETE from az_processes ap
		WHERE  ap.item_type = invalid_process.item_type
		AND    ap.process_name = invalid_process.process_name
		AND    ap.context_id = invalid_process.context_id;

		group_status_index :=  group_status_index + 1;
		group_status_tbl( group_status_index ).item_type := invalid_process.item_type;
		group_status_tbl( group_status_index ).process_name:=invalid_process.process_name;
		group_status_tbl( group_status_index ).context_id := invalid_process.context_id;

	      END LOOP;
	      COMMIT;
	EXCEPTION
	    WHEN OTHERS THEN
	    ROLLBACK;
	    fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	    fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	    fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	    fnd_message.set_token('AZW_ERROR_PROC','azw_proc.disable_invalid_processes');
	    fnd_message.set_token('AZW_ERROR_STMT','CURSOR invalid_bg_processes_cursor');
	    APP_EXCEPTION.RAISE_EXCEPTION;
	END ;

	BEGIN
	      FOR invalid_process IN invalid_io_processes_cursor LOOP
		DELETE from az_processes ap
		WHERE  ap.item_type = invalid_process.item_type
		AND    ap.process_name = invalid_process.process_name
		AND    ap.context_id = invalid_process.context_id;

		group_status_index :=  group_status_index + 1;
		group_status_tbl( group_status_index ).item_type := invalid_process.item_type;
		group_status_tbl( group_status_index ).process_name := invalid_process.process_name;
		group_status_tbl( group_status_index ).context_id := invalid_process.context_id;

	      END LOOP;
      	      COMMIT;
	EXCEPTION
	    WHEN OTHERS THEN
	    ROLLBACK;
	    fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	    fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	    fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	    fnd_message.set_token('AZW_ERROR_PROC','azw_proc.disable_invalid_processes');
	    fnd_message.set_token('AZW_ERROR_STMT','CURSOR invalid_io_processes_cursor');
	    APP_EXCEPTION.RAISE_EXCEPTION;
	END ;

	BEGIN
	      FOR invalid_process IN invalid_ou_processes_cursor LOOP
		DELETE from az_processes ap
		WHERE  ap.item_type = invalid_process.item_type
		AND    ap.process_name = invalid_process.process_name
		AND    ap.context_id = invalid_process.context_id;

		group_status_index :=  group_status_index + 1;
		group_status_tbl( group_status_index ).item_type := invalid_process.item_type;
		group_status_tbl( group_status_index ).process_name := invalid_process.process_name;
		group_status_tbl( group_status_index ).context_id := invalid_process.context_id;

	      END LOOP;
	      COMMIT;
	EXCEPTION
	    WHEN OTHERS THEN
	    ROLLBACK;
	    fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	    fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	    fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	    fnd_message.set_token('AZW_ERROR_PROC','azw_proc.disable_invalid_processes');
	    fnd_message.set_token('AZW_ERROR_STMT','CURSOR invalid_ou_processes_cursor');
	    APP_EXCEPTION.RAISE_EXCEPTION;
	END ;

    END IF;

  EXCEPTION
    WHEN app_exception.application_exception THEN
	RAISE;
    WHEN OTHERS THEN
      -- DBMS_OUTPUT.PUT_LINE('error: disable_invalid_processes: ' || SQLERRM);
        fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
        fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
        fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
        fnd_message.set_token('AZW_ERROR_PROC','azw_proc.disable_invalid_processes');
        fnd_message.set_token('AZW_ERROR_STMT','UNKNOWN');
        APP_EXCEPTION.RAISE_EXCEPTION;



  END disable_invalid_processes;


--
-- POPULATE_AZ_PROCESSES
--
-- Public procedure.  Called by AZW_HIER.get_hierarchy each time
-- hierarchy is shown.
--
  PROCEDURE populate_az_processes IS

    bg_ctx    context_tbl_t;
    io_ctx    context_tbl_t;
    ou_ctx    context_tbl_t;
    sob_ctx   context_tbl_t;
    processes process_tbl_t;

   opmcom_ctx   context_tbl_t;
   opmorg_ctx   context_tbl_t;


  BEGIN
--  dbms_output.put_line('populate az_processes table');

    g_current_mode := fnd_profile.value('AZ_CURRENT_MODE');

--  get the current session language for task_init
	BEGIN
	    select distinct language_code, nls_language
	    into v_language_code, v_language
	    from fnd_languages
	    where NLS_LANGUAGE =
	      SUBSTR(USERENV('LANGUAGE'), 1, INSTR(USERENV('LANGUAGE'), '_')-1);
	EXCEPTION
	    WHEN OTHERS THEN
	    fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	    fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	    fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	    fnd_message.set_token('AZW_ERROR_PROC','azw_proc.populate_az_processes');
	    fnd_message.set_token('AZW_ERROR_STMT','select language_code .. from fnd_languages');
	    APP_EXCEPTION.RAISE_EXCEPTION;
	END;
    get_context('BG', bg_ctx);
    get_context('IO', io_ctx);
    get_context('OU', ou_ctx);
    get_context('SOB', sob_ctx);

    get_context('OPMCOM', opmcom_ctx);
    get_context('OPMORG', opmorg_ctx);

--    dbms_output.put_line('populate contexts');

    get_processes(processes);
--    dbms_output.put_line('done get_processes');

  	group_status_index := 0;
	group_status_tbl.delete;

    populate_processes(bg_ctx, io_ctx, ou_ctx, sob_ctx, opmcom_ctx, opmorg_ctx, processes);
--    dbms_output.put_line('done populate_processes ');

	-- check for group status
	FOR i IN 1..group_status_index LOOP
    		update_hierarchy_status(group_status_tbl(i).item_type,
					group_status_tbl(i).process_name,
					group_status_tbl(i).context_id);
	END LOOP;
  	group_status_index := 0;
	group_status_tbl.delete;

    disable_invalid_processes;
--    dbms_output.put_line('Done disable_invalid_processes');

	-- check for group status
	FOR i IN 1..group_status_index LOOP
    		update_hierarchy_status(group_status_tbl(i).item_type,
					group_status_tbl(i).process_name,
					group_status_tbl(i).context_id);
	END LOOP;

  EXCEPTION
    WHEN app_exception.application_exception THEN
	RAISE;
    WHEN OTHERS THEN
    fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
    fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
    fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
    fnd_message.set_token('AZW_ERROR_PROC','azw_proc.populate_az_processes');
    fnd_message.set_token('AZW_ERROR_STMT','UNKNOWN');
    APP_EXCEPTION.RAISE_EXCEPTION;

  END populate_az_processes;


--
-- UPDATE_PROCESS_PHASE
--
-- Public procedure. Called from the trigger in response to an event in
-- a form.
-- Updates phase information for a given process
--
  PROCEDURE update_process_phase(node_id IN VARCHAR2, value IN NUMBER) IS

    p_type  az_processes.item_type%TYPE;
    p_name  az_processes.process_name%TYPE;
    ctx_id  az_processes.context_id%TYPE;

  BEGIN
    p_type := parse_item_type(node_id);
    p_name := parse_process_name(node_id);
    ctx_id := parse_context_id(node_id);

/*
    UPDATE az_processes ap
    SET    ap.phase = value
    WHERE  ap.item_type = p_type
    AND    ap.process_name = p_name
    AND    ap.context_id = TO_NUMBER(ctx_id);
    COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
      -- DBMS_OUTPUT.PUT_LINE('error: update_process_phase: ' || SQLERRM);
      RAISE;
*/
  END update_process_phase;


--
-- UPDATE_PROCESS_COMMENTS
--
-- Public procedure.  Called from the trigger in response to an event in
-- a form.
-- Updates phase information for a given process
--
  PROCEDURE update_process_comments(node_id IN VARCHAR2, value IN VARCHAR2) IS

    p_type  az_processes.item_type%TYPE;
    p_name  az_processes.process_name%TYPE;
    ctx_id  az_processes.context_id%TYPE;

  BEGIN
    p_type := parse_item_type(node_id);
    p_name := parse_process_name(node_id);
    ctx_id := parse_context_id(node_id);

	BEGIN
	    UPDATE az_processes ap
	    SET    ap.comments     = value
	    WHERE  ap.item_type    = p_type
	    AND    ap.process_name = p_name
	    AND    ap.context_id   = TO_NUMBER(ctx_id);
	    COMMIT;
	EXCEPTION
    	    WHEN OTHERS THEN
	    ROLLBACK;
    	    fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
    	    fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
    	    fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
    	    fnd_message.set_token('AZW_ERROR_PROC','azw_proc.update_process_comments');
    	    fnd_message.set_token('AZW_ERROR_STMT','UNKNOWN');
    	    APP_EXCEPTION.RAISE_EXCEPTION;
	END;

  EXCEPTION
    WHEN app_exception.application_exception THEN
    	APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN OTHERS THEN
      -- DBMS_OUTPUT.PUT_LINE('error: update_process_comments: ' || SQLERRM);
        fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
        fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
        fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
        fnd_message.set_token('AZW_ERROR_PROC','azw_proc.update_process_comments');
        fnd_message.set_token('AZW_ERROR_STMT','UNKNOWN');
        APP_EXCEPTION.RAISE_EXCEPTION;
  END update_process_comments;


--
-- update_groups_status
--
-- Private procedure.  Called by update_hierarchy_status.
-- Given a group id, finds if all siblings are completed. If completed,
-- sets the parent complete status to 'Y' and continues rolling up the
-- hierarchy.  When first 'N' is found, stop checking status and sets
-- all ancestors' complete status to 'N'.
--
  PROCEDURE update_groups_status(p_group_id IN VARCHAR2) IS

    v_parent_id  az_groups.group_id%TYPE;
    v_cnt        NUMBER DEFAULT 0;
    v_total_kids NUMBER DEFAULT 0;

  BEGIN
	BEGIN
	    SELECT ag.hierarchy_parent_id
	    INTO   v_parent_id
	    FROM   az_groups ag
	    WHERE  ag.group_id = p_group_id
	    AND    ag.process_type = g_current_mode;
  	EXCEPTION
	     WHEN NO_DATA_FOUND  THEN
		v_parent_id := NULL;
	     WHEN OTHERS THEN
	     fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	     fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	     fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	     fnd_message.set_token('AZW_ERROR_PROC','azw_proc.update_groups_status');
	     fnd_message.set_token('AZW_ERROR_STMT','select hierarchy_parent_id from az_groups');
	     APP_EXCEPTION.RAISE_EXCEPTION;
	END;

    WHILE (v_parent_id IS NOT NULL) LOOP

	BEGIN
	      SELECT COUNT(*)
	      INTO   v_total_kids
	      FROM   az_groups ag
	      WHERE  ag.hierarchy_parent_id = v_parent_id
	      AND    ag.process_type = g_current_mode;
  	EXCEPTION
	     WHEN OTHERS THEN
	     fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	     fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	     fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	     fnd_message.set_token('AZW_ERROR_PROC','azw_proc.update_groups_status');
	     fnd_message.set_token('AZW_ERROR_STMT','select count(*) into v_total_kids from az_groups');
	     APP_EXCEPTION.RAISE_EXCEPTION;
	END;

	BEGIN
	      SELECT COUNT(*)
	      INTO   v_cnt
	      FROM   az_groups ag
	      WHERE  ag.hierarchy_parent_id = v_parent_id
	      AND    ag.process_type = g_current_mode
	      AND    ag.complete_flag <> 'Y';
  	EXCEPTION
	     WHEN OTHERS THEN
	     fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	     fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	     fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	     fnd_message.set_token('AZW_ERROR_PROC','azw_proc.update_groups_status');
	     fnd_message.set_token('AZW_ERROR_STMT','select count(*) into v_cnt from az_groups');
	     APP_EXCEPTION.RAISE_EXCEPTION;
	END;

      IF (v_total_kids <> 0 AND v_cnt = 0) THEN
	BEGIN
		UPDATE az_groups
		SET    complete_flag = 'Y'
		WHERE  group_id = v_parent_id
		AND    process_type = g_current_mode;
		COMMIT;
  	EXCEPTION
	     WHEN OTHERS THEN
	     fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	     fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	     fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	     fnd_message.set_token('AZW_ERROR_PROC','azw_proc.update_groups_status');
	     fnd_message.set_token('AZW_ERROR_STMT','update az_groups set complete_flag = Y');
	     APP_EXCEPTION.RAISE_EXCEPTION;
	END;

	BEGIN
		SELECT ag.hierarchy_parent_id
		INTO   v_parent_id
		FROM   az_groups ag
		WHERE  ag.group_id = v_parent_id
		AND    ag.process_type = g_current_mode;
  	EXCEPTION
	     WHEN OTHERS THEN
	     fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	     fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	     fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	     fnd_message.set_token('AZW_ERROR_PROC','azw_proc.update_groups_status');
	     fnd_message.set_token('AZW_ERROR_STMT','select hierarchy_parent_id from az_groups');
	     APP_EXCEPTION.RAISE_EXCEPTION;
	END;

      ELSIF (v_total_kids <> 0 AND v_cnt <> 0) THEN
        WHILE (v_parent_id IS NOT NULL) LOOP

	    BEGIN
		  UPDATE az_groups
		  SET    complete_flag = 'N'
		  WHERE  group_id = v_parent_id
		  AND    process_type = g_current_mode;
		  COMMIT;
  	    EXCEPTION
	        WHEN OTHERS THEN
	        fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	        fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	        fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	        fnd_message.set_token('AZW_ERROR_PROC','azw_proc.update_groups_status');
	        fnd_message.set_token('AZW_ERROR_STMT','update az_groups set complete_flag = N');
	        APP_EXCEPTION.RAISE_EXCEPTION;
	    END;

	    BEGIN
		  SELECT ag.hierarchy_parent_id
		  INTO   v_parent_id
		  FROM   az_groups ag
		  WHERE  ag.group_id = v_parent_id
		  AND    ag.process_type = g_current_mode;
  	    EXCEPTION
	         WHEN OTHERS THEN
	         fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	         fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	         fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	         fnd_message.set_token('AZW_ERROR_PROC','azw_proc.update_groups_status');
	     	 fnd_message.set_token('AZW_ERROR_STMT','select hierarchy_parent_id from az_groups');
	         APP_EXCEPTION.RAISE_EXCEPTION;
	    END;
        END LOOP;

      END IF;

    END LOOP;

  EXCEPTION
    WHEN app_exception.application_exception THEN
	RAISE ;
    WHEN OTHERS THEN
      -- DBMS_OUTPUT.PUT_LINE('error: update_groups_status ' || SQLERRM);
	 fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	 fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	 fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	 fnd_message.set_token('AZW_ERROR_PROC','azw_proc.update_groups_status');
	 fnd_message.set_token('AZW_ERROR_STMT','UNKNOWN');
	 APP_EXCEPTION.RAISE_EXCEPTION;

  END update_groups_status;


--
-- update_hierarchy_status
--
-- Private procedure.  Called by update_process_status.
-- Given an process id (item_type, process_name, context_id),
-- updates all the ancestors' complete status.
--
  PROCEDURE update_hierarchy_status(p_item_type    IN VARCHAR2,
                                    p_process_name IN VARCHAR2,
                                    p_context_id   IN VARCHAR2) IS

    v_group_id az_groups.group_id%TYPE;
    v_cnt      NUMBER DEFAULT 0;
    v_status   VARCHAR2(1);

  BEGIN
	BEGIN
	    SELECT ap.parent_id
	    INTO   v_group_id
	    FROM   az_processes ap
	    WHERE  ap.item_type    = p_item_type
	    AND    ap.process_name = p_process_name
	    AND    ap.process_type = g_current_mode
	    AND    ap.context_id   = p_context_id;
  	EXCEPTION
	     WHEN NO_DATA_FOUND THEN
		v_group_id := NULL;
	     WHEN OTHERS THEN
	     fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	     fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	     fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	     fnd_message.set_token('AZW_ERROR_PROC','azw_proc.update_hierarchy_status');
	     fnd_message.set_token('AZW_ERROR_STMT','select parent_id from az_processes');
	     APP_EXCEPTION.RAISE_EXCEPTION;
	END;

    IF v_group_id is null THEN
	NULL;
    ELSE
		BEGIN
		    SELECT COUNT(*)
		    INTO   v_cnt
		    FROM   az_processes ap
		    WHERE  ap.status_code <> 'C'
		    AND    ap.process_type = g_current_mode
		    AND    ap.parent_id      = v_group_id;
		EXCEPTION
		     WHEN OTHERS THEN
		     fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
		     fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
		     fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
		     fnd_message.set_token('AZW_ERROR_PROC','azw_proc.update_hierarchy_status');
		     fnd_message.set_token('AZW_ERROR_STMT','select count(*) from az_processes');
		     APP_EXCEPTION.RAISE_EXCEPTION;
		END;

		    IF (v_cnt = 0) THEN
		      v_status := 'Y';
		    ELSE
		      v_status := 'N';
		    END IF;

		BEGIN
		    UPDATE az_groups ag
		    SET    ag.complete_flag = v_status
		    WHERE  ag.group_id = v_group_id
		    AND    ag.process_type = g_current_mode;
		    COMMIT;
		EXCEPTION
		     WHEN OTHERS THEN
		     fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
		     fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
		     fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
		     fnd_message.set_token('AZW_ERROR_PROC','azw_proc.update_hierarchy_status');
		     fnd_message.set_token('AZW_ERROR_STMT','update az_groups set complete_flag');
		     APP_EXCEPTION.RAISE_EXCEPTION;
		END;

		    -- update groups complete status, starting with the leaf group id
		    update_groups_status(v_group_id);

     END IF;

  EXCEPTION
    WHEN app_exception.application_exception THEN
	RAISE;
    WHEN OTHERS THEN
      -- DBMS_OUTPUT.PUT_LINE('error: update_hierarchy_status ' || SQLERRM);
     fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
     fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
     fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
     fnd_message.set_token('AZW_ERROR_PROC','azw_proc.update_hierarchy_status');
     fnd_message.set_token('AZW_ERROR_STMT','UNKNOWN');
     APP_EXCEPTION.RAISE_EXCEPTION;
  END update_hierarchy_status;


--
-- UPDATE_PROCESS_STATUS
--
-- Public procedure.
-- Updates phase information for a given process
--
  PROCEDURE update_process_status(node_id IN VARCHAR2, value IN VARCHAR2) IS

    p_type  az_processes.item_type%TYPE;
    p_name  az_processes.process_name%TYPE;
    ctx_id  az_processes.context_id%TYPE;
    v_count NUMBER(30);
  BEGIN
    p_type := parse_item_type(node_id);
    p_name := parse_process_name(node_id);
    ctx_id := parse_context_id(node_id);
--  get count of tasks for this process
	BEGIN
	    SELECT count(*)
	    INTO   v_count
	    FROM   wf_items wfi, wf_item_attribute_values wiav
	    WHERE  wfi.item_type = p_type
	    AND    wfi.root_activity = p_name
	    AND    wiav.item_type = p_type
	    AND    wiav.item_key = wfi.item_key
	    AND    wiav.name = 'AZW_IA_CTXT_ID'
	    AND    wiav.text_value = ctx_id;
  	EXCEPTION
	     WHEN OTHERS THEN
	     fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	     fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	     fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	     fnd_message.set_token('AZW_ERROR_PROC','azw_proc.update_process_status');
	     fnd_message.set_token('AZW_ERROR_STMT','select count(*) into v_count from wf_items,wf_item_attribute_values');
	     APP_EXCEPTION.RAISE_EXCEPTION;
	END;

    IF (value <> 'N') THEN
	BEGIN
	     UPDATE az_processes ap
	     SET    ap.status_code   = value
	     WHERE  ap.item_type     = p_type
	     AND    ap.process_name  = p_name
	     AND    ap.context_id    = TO_NUMBER(ctx_id);
	     COMMIT;
  	EXCEPTION
	     WHEN OTHERS THEN
	     fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	     fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	     fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	     fnd_message.set_token('AZW_ERROR_PROC','azw_proc.update_process_status');
	     fnd_message.set_token('AZW_ERROR_STMT','update az_processes set status_code = value');
	     APP_EXCEPTION.RAISE_EXCEPTION;
	END;
    ELSE
	IF (v_count <> 0) THEN
	     BEGIN
	      	UPDATE az_processes ap
	      	SET    ap.status_code   = 'A'
	      	WHERE  ap.item_type     = p_type
	      	AND    ap.process_name  = p_name
	      	AND    ap.context_id    = TO_NUMBER(ctx_id);
	      	COMMIT;
  	     EXCEPTION
	        WHEN OTHERS THEN
	        fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	        fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	        fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	        fnd_message.set_token('AZW_ERROR_PROC','azw_proc.update_process_status');
	        fnd_message.set_token('AZW_ERROR_STMT','update az_processes set status_code = A');
	        APP_EXCEPTION.RAISE_EXCEPTION;
	     END;
	ELSE
  	     BEGIN
	        UPDATE az_processes ap
	        SET    ap.status_code   = 'N'
	        WHERE  ap.item_type     = p_type
	        AND    ap.process_name  = p_name
	        AND    ap.context_id    = TO_NUMBER(ctx_id);
  	     EXCEPTION
	        WHEN OTHERS THEN
	        fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	        fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	        fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	        fnd_message.set_token('AZW_ERROR_PROC','azw_proc.update_process_status');
	        fnd_message.set_token('AZW_ERROR_STMT','update az_processes set status_code = N');
	        APP_EXCEPTION.RAISE_EXCEPTION;
	     END;
	END IF; /* for process complete unchecked */
    END IF;
    -- update status for all ancestors
    update_hierarchy_status(p_type, p_name, ctx_id);

  EXCEPTION
    WHEN app_exception.application_exception THEN
     APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN OTHERS THEN
      -- DBMS_OUTPUT.PUT_LINE('error: complete_process_status: ' || SQLERRM);
     fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
     fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
     fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
     fnd_message.set_token('AZW_ERROR_PROC','azw_proc.update_process_status');
     fnd_message.set_token('AZW_ERROR_STMT','select into v_ctx_id');
     APP_EXCEPTION.RAISE_EXCEPTION;
  END update_process_status;


--
-- AIWStart
--
-- Private procedure.  Called by az_start_task.
-- Starts a task.
--
  PROCEDURE AIWStart(
    p_itemtype in varchar2,
    p_workflow in varchar2,
    p_context  in varchar2,
    p_role     in varchar2,
    p_context_level in varchar2,
    p_org_id   in number,
    p_org_code in varchar2,
    p_coa_id   in number,
    p_context_id in number) IS

    itemkey       varchar2(240);
    murl          varchar2(2000);
    prev_step     varchar2(2000);

  BEGIN

    select AZ_WF_ITEMKEY_S.nextval into itemkey from dual;

    if (wf_item.Item_Exist(p_itemtype, itemkey)) then
      --wf_engine.handleerror(p_itemtype, itemkey, 'START', 'RETRY', null);
      null;
    else

	BEGIN
   		wf_engine.CreateProcess(p_itemtype, itemkey, p_workflow);
      		--Set the context, role, comments and priority here
      		wf_engine.SetItemAttrText(p_itemtype, itemkey,
					'AZW_IA_CTXTNAME', p_context);

      		if(p_context_level = 'IO') then
        		wf_engine.SetItemAttrText(p_itemtype, itemkey,
					'AZW_IA_ORG_CODE', p_org_code);
        		wf_engine.SetItemAttrNumber(p_itemtype, itemkey,
					'AZW_IA_ORG_ID', p_org_id);
        		wf_engine.SetItemAttrNumber(p_itemtype, itemkey,
					'AZW_IA_COA_ID', p_coa_id);
      		end if;
	EXCEPTION
    		WHEN app_exception.application_exception THEN
     		     APP_EXCEPTION.RAISE_EXCEPTION;
		WHEN OTHERS THEN
		     fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
		     fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
		     fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
		     fnd_message.set_token('AZW_ERROR_PROC','azw_proc.AIWStart');
		     fnd_message.set_token('AZW_ERROR_STMT','BLOCK 1');
		     APP_EXCEPTION.RAISE_EXCEPTION;
	END;

	BEGIN
      		if(p_context is null) then
        		wf_engine.SetItemAttrText(p_itemtype, itemkey,
				'AZW_IA_CTXTNAME', 'NONE');
      		end if;
      		wf_engine.SetItemAttrText(p_itemtype, itemkey, 'AZW_IA_ROLE', p_role);

      		wf_engine.AddItemAttr(p_itemtype, itemkey, 'AZW_IA_CTXT_ID');
      		wf_engine.SetItemAttrText(p_itemtype, itemkey, 'AZW_IA_CTXT_ID',
               		                 p_context_id);
      		wf_engine.AddItemAttr(p_itemtype, itemkey, 'AZW_IA_NEW_CTXT_TYPE');
      		wf_engine.SetItemAttrText(p_itemtype, itemkey,
					 'AZW_IA_NEW_CTXT_TYPE', p_context_level);

      		AZW_UTIL.UpdateDocUrl(p_itemtype, p_workflow);

      		wf_engine.StartProcess(p_itemtype, itemkey);
	EXCEPTION
    		WHEN app_exception.application_exception THEN
     		     APP_EXCEPTION.RAISE_EXCEPTION;
		WHEN OTHERS THEN
		     fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
		     fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
		     fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
		     fnd_message.set_token('AZW_ERROR_PROC','azw_proc.AIWStart');
		     fnd_message.set_token('AZW_ERROR_STMT','BLOCK 2');
		     APP_EXCEPTION.RAISE_EXCEPTION;
	END;
    end if;

    commit;
    v_new_task_key := itemkey;
  EXCEPTION
    WHEN app_exception.application_exception THEN
	APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN OTHERS THEN
     	fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
     	fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
     	fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
     	fnd_message.set_token('AZW_ERROR_PROC','azw_proc.AIWStart');
     	fnd_message.set_token('AZW_ERROR_STMT','UNKNOWN');
     	APP_EXCEPTION.RAISE_EXCEPTION;

  END AIWStart;


--
-- get_old_task_label
--
-- Private procedure.  Returns old task's label.
-- Called by get_task_label.
--
  FUNCTION get_old_task_label(p_type VARCHAR2, p_key VARCHAR2, p_name VARCHAR2,
                              p_role VARCHAR2) RETURN VARCHAR2
   IS
      v_begin_date       wf_item_activity_statuses.begin_date%TYPE;
      v_display_status   wf_resources.text%TYPE;
      v_label            az_webform_messages.mesg%TYPE;
      v_task_tot_days    NUMBER(5) := 0;
      v_count            NUMBER(5) := 0;
      v_skip_count       NUMBER(4) := 0;
      v_task_status      wf_item_activity_statuses.activity_status%TYPE;

    CURSOR az_tasks_days_cursor IS
      SELECT    round( months_between(sysdate, wfi.begin_date)* 31),
                wias.activity_status
      FROM      wf_items wfi, wf_process_activities  wpa,
                wf_item_activity_statuses wias
      WHERE     wfi.item_type = p_type
      AND       wfi.root_activity = p_name
      AND       wfi.item_key = p_key
      AND       wias.item_type = wfi.item_type
      AND       wias.item_key = wfi.item_key
      AND       wpa.instance_id = wias.process_activity
      AND       wpa.activity_name = wfi.root_activity
      AND       wpa.process_item_type =p_type
      AND       wpa.process_name = 'ROOT';

    CURSOR az_task_display_cursor IS
      SELECT    wav.display_name,
                wias.begin_date
      FROM      wf_process_activities wpa, wf_item_activity_statuses wias,
                wf_activities_vl wav
      WHERE     wias.item_type = p_type
      AND       wias.item_key = p_key
      AND       wias.process_activity = wpa.instance_id
      AND       wpa.activity_name = wav.name
      AND       wpa.activity_item_type = wav.item_type
      AND       wpa.process_name <> 'ROOT'
      AND       wpa.activity_name <> 'START'
      AND       wav.begin_date is not NULL
      AND       wav.end_date is NULL
      AND       wav.type = 'NOTICE'
      ORDER BY  wias.begin_date desc;

    CURSOR az_steps_count_cursor IS
      SELECT COUNT(*)
      FROM   wf_item_activity_statuses wias, wf_notification_attributes wna,
             wf_notifications wn
      WHERE  wias.item_type = p_type
      AND    wias.item_key = p_key
      AND    wias.notification_id IS NOT NULL
      AND    wna.notification_id = wias.notification_id
      AND    wn.notification_id = wna.notification_id
      AND    wn.status = 'CLOSED'
      AND    wna.name = 'RESULT'
      AND    wna.text_value LIKE '%DONE%';

    CURSOR az_skip_count_cursor IS
      SELECT COUNT(*)
      FROM   wf_item_activity_statuses wias, wf_notification_attributes wna,
             wf_notifications wn
      WHERE  wias.item_type = p_type
      AND    wias.item_key = p_key
      AND    wias.notification_id is not NULL
      AND    wna.notification_id = wias.notification_id
      AND    wn.notification_id = wna.notification_id
      AND    wn.status = 'CLOSED'
      AND    wna.name = 'RESULT'
      AND    wna.text_value like '%SKIP%';

  BEGIN
           task_init;

           OPEN   az_task_display_cursor;
           FETCH  az_task_display_cursor
           INTO   v_label, v_begin_date;

           OPEN   az_tasks_days_cursor;
           FETCH  az_tasks_days_cursor
           INTO   v_task_tot_days, v_task_status;

           OPEN az_steps_count_cursor;
           FETCH az_steps_count_cursor
	   INTO v_count;

           OPEN az_skip_count_cursor;
           FETCH az_skip_count_cursor
	   INTO v_skip_count;

           IF (v_task_status = 'COMPLETE') THEN
             v_label := p_role || ' - '|| to_char(v_task_tot_days) ||  ' ' ||
                        v_days || ': ' || to_char(v_count) || ' ' ||  v_done ||
                        ' , '|| to_char(v_skip_count) || ' ' || v_skip;
           ELSE
           v_label := v_label || ': ' || p_role || ' - '||
                      to_char(v_task_tot_days) ||  '  ' || v_days || ': ' ||
                      to_char(v_count) || ' ' ||  v_done || ' , '||
                      to_char(v_skip_count) || ' ' || v_skip;
           END IF;

           CLOSE az_task_display_cursor;
           CLOSE az_tasks_days_cursor;
           CLOSE az_steps_count_cursor;
           CLOSE az_skip_count_cursor;

           RETURN v_label;

  EXCEPTION
     WHEN app_exception.application_exception THEN
	RAISE;
     WHEN OTHERS THEN
     fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
     fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
     fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
     fnd_message.set_token('AZW_ERROR_PROC','azw_proc.get_old_task_label');
     fnd_message.set_token('AZW_ERROR_STMT','UNKNOWN');
     APP_EXCEPTION.RAISE_EXCEPTION;
  END get_old_task_label;


--
-- get_new_task_mesg
--
-- Private procedure.  Returns new task's message.
-- Called by az_start_task.
--
  FUNCTION get_new_task_mesg(p_type VARCHAR2, p_name VARCHAR2,
                             p_role VARCHAR2, p_ctxt_id VARCHAR2)
  RETURN VARCHAR2
   IS
      label            az_webform_messages.mesg%TYPE;
      v_begin_date     wf_item_activity_statuses.begin_date%TYPE;
      v_display_status wf_resources.text%TYPE;
      v_mesg           az_webform_messages.mesg%TYPE;
      v_node_id        VARCHAR2(300);
      v_parent_node_id VARCHAR2(300);

      CURSOR az_task_display_cursor IS
      SELECT    wav.display_name,
                wias.begin_date
      FROM      wf_process_activities wpa, wf_item_activity_statuses wias,
                wf_activities_vl wav
      WHERE     wias.item_type = p_type
      AND       wias.item_key = v_new_task_key
      AND       wias.process_activity = wpa.instance_id
      AND       wpa.activity_name = wav.name
      AND       wpa.activity_item_type = wav.item_type
      AND       wpa.process_name <> 'ROOT'
      AND       wpa.activity_name <> 'START'
      AND       wav.type = 'NOTICE'
      AND       wav.end_date is NULL
      AND       wav.begin_date is not NULL
      ORDER BY  wias.begin_date desc;

  BEGIN
           task_init;

           OPEN   az_task_display_cursor;
           FETCH  az_task_display_cursor
           INTO   label, v_begin_date;

           v_node_id        := p_type || '.' || p_name || '.'|| p_ctxt_id ||
                               '.' || v_new_task_key;

           v_parent_node_id := p_type || '.' || p_name || '.'|| p_ctxt_id;

           label            := label || ': ' || p_role || ' - '|| '0' ||  '  '
                               || v_days || ': ' || '0 ' || v_done || ' , '||
                               '0' || ' ' || v_skip;

           v_mesg := label || msg_delimiter || v_node_id || msg_delimiter ||
                     v_parent_node_id || msg_delimiter || 'I' || msg_delimiter
                     || 'INCOMPLETE' || msg_delimiter || '100000'
                     || msg_delimiter || msg_delimiter;

           CLOSE az_task_display_cursor;
           RETURN v_mesg;

  EXCEPTION
     WHEN app_exception.application_exception THEN
	RAISE;
     WHEN OTHERS THEN
     fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
     fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
     fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
     fnd_message.set_token('AZW_ERROR_PROC','azw_proc.get_new_task_mesg');
     fnd_message.set_token('AZW_ERROR_STMT','CURSOR az_task_display_cursor');
     APP_EXCEPTION.RAISE_EXCEPTION;
  END get_new_task_mesg;


--
-- AZ_START_TASK
--
-- Public procedure.  Starts a new task and passes its display string.
--
  FUNCTION az_start_task(node_id IN VARCHAR2, role IN VARCHAR2) RETURN VARCHAR2
   IS

    p_type   az_processes.item_type%TYPE;
    p_name   az_processes.process_name%TYPE;
    ctx_id   az_processes.context_id%TYPE;
    ctx_type az_processes.context_type%TYPE;
    ctx_name az_processes.context_name%TYPE;
    org_code org_access_view.organization_code%TYPE DEFAULT NULL;
    coa_id   org_access_view.chart_of_accounts_id%TYPE DEFAULT NULL;
    p_role   wf_roles.name%TYPE;
    msg      az_webform_messages.mesg%TYPE;

  BEGIN

    p_type   := parse_item_type(node_id);
    p_name   := parse_process_name(node_id);
    ctx_id   := parse_context_id(node_id);
    ctx_type := get_context_type(p_type, p_name, to_number(ctx_id));
    ctx_name := get_context_name(ctx_type, to_number(ctx_id));

    p_role := role;

	BEGIN
	    IF(ctx_type = 'IO') THEN
	      SELECT 	distinct organization_code, chart_of_accounts_id
	      INTO 	org_code, coa_id
	      FROM   	org_access_view
	      WHERE  	organization_id = ctx_id;
	    END IF;
  	EXCEPTION
	     WHEN OTHERS THEN
	     fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	     fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	     fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	     fnd_message.set_token('AZW_ERROR_PROC','azw_proc.az_start_task');
	     fnd_message.set_token('AZW_ERROR_STMT','select organization_code from org_access_view');
	     APP_EXCEPTION.RAISE_EXCEPTION;
	END;

    AIWStart(p_type, p_name, ctx_name, p_role ,ctx_type, ctx_id, org_code,
             coa_id, ctx_id);
    msg := get_new_task_mesg(p_type, p_name, p_role, ctx_id);
   /* Now update the status */
    update_process_status(node_id, 'A');
    COMMIT;
    RETURN msg;
  EXCEPTION
     WHEN app_exception.application_exception THEN
        APP_EXCEPTION.RAISE_EXCEPTION;
     WHEN OTHERS THEN
        ROLLBACK;
     fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
     fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
     fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
     fnd_message.set_token('AZW_ERROR_PROC','azw_proc.az_start_task');
     fnd_message.set_token('AZW_ERROR_STMT','UNKNOWN');
     APP_EXCEPTION.RAISE_EXCEPTION;
  END az_start_task;


--
-- AZ_REASSIGN_TASK
--
-- Public function.  Reassigns a task and returns the new label.
--
  FUNCTION az_reassign_task(node_id IN VARCHAR2, p_role IN VARCHAR2)
           RETURN VARCHAR2
  IS
  v_type az_processes.item_type%TYPE;
  v_key  wf_items.item_key%TYPE;
  p_name az_processes.process_name%TYPE;
  label  az_webform_messages.mesg%TYPE;

  BEGIN

    v_type := parse_item_type(node_id);
    v_key  := parse_item_key(node_id);
    p_name := parse_process_name_task(node_id);

    wf_engine.SetItemAttrText(v_type, v_key, 'AZW_IA_ROLE', p_role);
    label :=  get_old_task_label(v_type, v_key, p_name, p_role);
    return label;

  EXCEPTION
     WHEN app_exception.application_exception THEN
        APP_EXCEPTION.RAISE_EXCEPTION;
     WHEN OTHERS THEN
     fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
     fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
     fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
     fnd_message.set_token('AZW_ERROR_PROC','azw_proc.az_reassign_task');
     fnd_message.set_token('AZW_ERROR_STMT','UNKNOWN');
     APP_EXCEPTION.RAISE_EXCEPTION;
  END az_reassign_task;


--
-- AZ_ABORT_TASK
--
-- Public function.  Aborts a task and returns its label
--
  FUNCTION az_abort_task(node_id IN VARCHAR2) RETURN VARCHAR2
  IS
  v_type az_processes.item_type%TYPE;
  v_key  wf_items.item_key%TYPE;
  p_name az_processes.process_name%TYPE;
  label  az_webform_messages.mesg%TYPE;
  p_role wf_roles.name%TYPE;

  BEGIN

    v_type := parse_item_type(node_id);
    v_key  := parse_item_key(node_id);
    p_name := parse_process_name_task(node_id);
    p_role := wf_engine.GetItemAttrText(v_type, v_key, 'AZW_IA_ROLE');
    label := NULL;

    wf_engine.AbortProcess(v_type, v_key, NULL, 'eng_force');

    label := get_old_task_label(v_type, v_key, p_name, p_role);
    commit;
    return label;

  EXCEPTION
     WHEN app_exception.application_exception THEN
        APP_EXCEPTION.RAISE_EXCEPTION;
     WHEN OTHERS THEN
     fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
     fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
     fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
     fnd_message.set_token('AZW_ERROR_PROC','azw_proc.az_abort_task');
     fnd_message.set_token('AZW_ERROR_STMT','UNKNOWN');
     APP_EXCEPTION.RAISE_EXCEPTION;
  END az_abort_task;


--
-- GET_TASK_LABEL
--
-- Public function.
-- Given a task node id for a task return it's display label
--
  FUNCTION get_task_label(node_id IN VARCHAR2) RETURN VARCHAR2
  IS
  v_type az_processes.item_type%TYPE;
  v_key  wf_items.item_key%TYPE;
  p_name az_processes.process_name%TYPE;
  label  az_webform_messages.mesg%TYPE;
  p_role wf_roles.name%TYPE;

  BEGIN

    v_type := parse_item_type(node_id);
    v_key  := parse_item_key(node_id);
    p_name := parse_process_name_task(node_id);
    p_role := wf_engine.GetItemAttrText(v_type, v_key, 'AZW_IA_ROLE');
    label  := get_old_task_label(v_type, v_key, p_name, p_role);

    RETURN label;
  EXCEPTION
     WHEN app_exception.application_exception THEN
        APP_EXCEPTION.RAISE_EXCEPTION;
     WHEN OTHERS THEN
     fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
     fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
     fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
     fnd_message.set_token('AZW_ERROR_PROC','azw_proc.get_task_label');
     fnd_message.set_token('AZW_ERROR_STMT','UNKNOWN');
     APP_EXCEPTION.RAISE_EXCEPTION;
  END get_task_label;


--
-- GET_TASK_STATUS
--
-- Public function.
-- Given a task node id for a task return it's current status
--
  FUNCTION get_task_status(node_id IN VARCHAR2) RETURN VARCHAR2
  IS
  v_type        az_processes.item_type%TYPE;
  v_key         wf_items.item_key%TYPE;
  p_name        az_processes.process_name%TYPE;
  label         az_webform_messages.mesg%TYPE;
  v_task_status wf_item_activity_statuses.activity_status%TYPE;

  CURSOR   az_task_status_cursor IS
  SELECT   wias.activity_status
  FROM     wf_items wfi, wf_process_activities  wpa,
           wf_item_activity_statuses wias
  WHERE     wfi.item_type = v_type
  AND       wfi.root_activity = p_name
  AND       wfi.item_key = v_key
  AND       wias.item_type = wfi.item_type
  AND       wias.item_key = wfi.item_key
  AND       wpa.instance_id = wias.process_activity
  AND       wpa.activity_name = wfi.root_activity
  AND       wpa.process_item_type =v_type
  AND       wpa.process_name = 'ROOT';

  BEGIN

    v_type := parse_item_type(node_id);
    v_key  := parse_item_key(node_id);
    p_name := parse_process_name_task(node_id);

	    OPEN az_task_status_cursor;
	    FETCH az_task_status_cursor
	    INTO  v_task_status;

	    IF (v_task_status = 'ACTIVE') THEN
	      RETURN 'N';
	    ELSE
	      RETURN 'Y';
	    END IF;
	    CLOSE az_task_status_cursor;
   EXCEPTION
     WHEN app_exception.application_exception THEN
        APP_EXCEPTION.RAISE_EXCEPTION;
     WHEN OTHERS THEN
     fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
     fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
     fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
     fnd_message.set_token('AZW_ERROR_PROC','azw_proc.get_task_status');
     fnd_message.set_token('AZW_ERROR_STMT','CURSOR az_task_status_cursor');
     APP_EXCEPTION.RAISE_EXCEPTION;
   END get_task_status;


--
-- POPULATE_PROCESS_STATUS
--
-- Public procedure.  Called during upgrade from 11.0 to 11.5 only.
-- Populates the STATUS_CODE column in AZ_PROCESSES to be either
-- 'A', 'C', or 'N'.
--

  PROCEDURE populate_process_status IS

            CURSOR az_process_active_cursor IS
            SELECT ap.item_type, ap.process_name, ap.context_id
            FROM   az_processes ap,wf_items wfi, wf_item_attribute_values wiav
            WHERE  wfi.item_type = ap.item_type
            AND    wfi.root_activity = ap.process_name
            AND    wiav.item_type = wfi.item_type
            AND    wiav.item_key = wfi.item_key
            AND    wiav.name = 'AZW_IA_CTXT_ID'
            AND    wiav.text_value = ap.context_id
            AND    ap.complete_flag = 'N';
            p_item_type    az_processes.item_type%TYPE;
            p_process_name az_processes.process_name%TYPE;
            p_context_id   az_processes.context_id%TYPE;

  BEGIN
--    dbms_output.put_line('populate process status');

-- Update all 'Active' processes

	BEGIN
	   OPEN    az_process_active_cursor;
	   FETCH   az_process_active_cursor
	   INTO    p_item_type, p_process_name, p_context_id;

	   WHILE   az_process_active_cursor%FOUND LOOP
	     UPDATE az_processes
	     SET    status_code = 'A'
	     WHERE  item_type = p_item_type
	     AND    process_name = p_process_name
	     AND    context_id  = p_context_id;
	     FETCH   az_process_active_cursor
	     INTO    p_item_type, p_process_name, p_context_id;
	   END LOOP;

	   CLOSE   az_process_active_cursor;
  	EXCEPTION
	     WHEN OTHERS THEN
	     fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	     fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	     fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	     fnd_message.set_token('AZW_ERROR_PROC','azw_proc.populate_process_status');
	     fnd_message.set_token('AZW_ERROR_STMT','CURSOR az_process_active_cursor');
	     APP_EXCEPTION.RAISE_EXCEPTION;
	END;

	BEGIN
	-- Update all 'Complete' processes

	   UPDATE az_processes
	   SET    status_code = 'C'
	   WHERE  complete_flag = 'Y';
  	EXCEPTION
	     WHEN OTHERS THEN
	     fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	     fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	     fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	     fnd_message.set_token('AZW_ERROR_PROC','azw_proc.parse_ctxt_id_task');
	     fnd_message.set_token('AZW_ERROR_STMT','update az_processes status code C');
	     APP_EXCEPTION.RAISE_EXCEPTION;
	END;

	BEGIN
	-- Update all 'Not Started' Processes

	   UPDATE az_processes
	   SET    status_code = 'N'
	   WHERE  status_code NOT IN ('A', 'C');
  	EXCEPTION
	     WHEN OTHERS THEN
	     fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	     fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	     fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	     fnd_message.set_token('AZW_ERROR_PROC','azw_proc.parse_ctxt_id_task');
	     fnd_message.set_token('AZW_ERROR_STMT','update az_processes status code N');
	     APP_EXCEPTION.RAISE_EXCEPTION;
	END;

  COMMIT;

  EXCEPTION
    WHEN app_exception.application_exception THEN
	RAISE;
    WHEN OTHERS THEN
      -- DBMS_OUTPUT.PUT_LINE('error: populate_process_status: ' || SQLERRM);
     ROLLBACK;
     fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
     fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
     fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
     fnd_message.set_token('AZW_ERROR_PROC','azw_proc.populate_process_status');
     fnd_message.set_token('AZW_ERROR_STMT','UNKNOWN');
     	APP_EXCEPTION.RAISE_EXCEPTION;
  END populate_process_status;


--
-- ABORT_RUNNING_TASKS
--
-- Public procedure.  Called during upgrade from 11.0 to 11.5 only.
-- Aborts all tasks without an end date.
--

  PROCEDURE abort_running_tasks IS

      CURSOR running_tasks IS
      SELECT distinct wi.item_type, wi.item_key
      FROM   wf_items wi
      WHERE  wi.item_type like 'AZW%'
      AND    wi.end_date is NULL;

      v_item_type wf_items.item_type%TYPE;
      v_item_key  wf_items.item_key%TYPE;

  BEGIN

    OPEN  running_tasks;
    FETCH running_tasks INTO v_item_type, v_item_key;
    WHILE running_tasks%FOUND LOOP
    BEGIN
      wf_engine.AbortProcess(v_item_type, v_item_key);
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
      FETCH running_tasks INTO v_item_type, v_item_key;
    END LOOP;
    CLOSE running_tasks;
  EXCEPTION
     WHEN OTHERS THEN
     fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
     fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
     fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
     fnd_message.set_token('AZW_ERROR_PROC','azw_proc.abort_running_tasks');
     fnd_message.set_token('AZW_ERROR_STMT','CURSOR running_tasks');
     APP_EXCEPTION.RAISE_EXCEPTION;

  END abort_running_tasks;

--
-- PROCESS_HAS_ACTIVE_TASKS
--
-- Public function. Called by AZWIZARD form from
-- 	process_overview.process_complete program unit.
-- Checks if the specified process has any active tasks.
-- Returns TRUE if there is any active tasks for the specified process
-- otherwise returns FALSE.
--
FUNCTION process_has_active_tasks(node_id IN VARCHAR2) RETURN BOOLEAN
IS

  v_count 	NUMBER;
  v_return 	BOOLEAN;
  v_type 	wf_items.item_type%TYPE;
  v_name 	wf_items.root_activity%TYPE;

BEGIN

  --
  --  parse the node id to get the item type and the process name
  --
  v_type := parse_item_type(node_id);
  v_name := parse_process_name_task(node_id);

  --
  -- Check if there is any active tasks for the specified process.
  --
  SELECT COUNT(*) INTO v_count
  FROM   az_tasks_v
  WHERE  item_type = v_type
    AND  root_activity = v_name
    AND  status = 'A';

  IF v_count > 0 THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;

EXCEPTION
     WHEN OTHERS THEN
     fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
     fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
     fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
     fnd_message.set_token('AZW_ERROR_PROC','azw_proc.process_has_active_tasks');
     fnd_message.set_token('AZW_ERROR_STMT','SELECT COUNT(*) FROM AZ_TASKS_V');
     APP_EXCEPTION.RAISE_EXCEPTION;
END process_has_active_tasks;


END AZW_PROC;

/
