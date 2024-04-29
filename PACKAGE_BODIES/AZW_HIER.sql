--------------------------------------------------------
--  DDL for Package Body AZW_HIER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AZW_HIER" AS
/* $Header: AZWHIERB.pls 115.51 1999/11/09 12:52:57 pkm ship    $: */

  TYPE message_tbl_t IS TABLE OF VARCHAR2(1024) INDEX BY BINARY_INTEGER;

/* CAREFUL !!!!  Do not chage the sizes of hierarchy_rec_t fields */

  TYPE hierarchy_rec_t IS RECORD (
    node_id           VARCHAR2(300),
    display_name      VARCHAR2(415),
    parent_node_id    VARCHAR2(300),
    node_type         VARCHAR2(1),
    status            VARCHAR2(30),
    context_name      az_processes.context_name%TYPE,
    context_type      az_processes.context_type%TYPE,
    display_order     az_processes.display_order%TYPE );

  TYPE hierarchy_tbl_t IS TABLE OF hierarchy_rec_t INDEX BY BINARY_INTEGER;

  hierarchy_table hierarchy_tbl_t;
  t_index    BINARY_INTEGER DEFAULT 0;

-- Start: added by swarup for context sort

  ctx_table	AZW_PROC.context_tbl_t;

  PROCEDURE insert_context( ctx_type	IN VARCHAR2,
		            meaning	IN VARCHAR2,
  			    msg		IN OUT message_tbl_t,
			    i		IN OUT INTEGER,
			    p_disp_order	IN INTEGER);

  PROCEDURE insert_groups_for_context( ctx_type	IN VARCHAR2,
					   msg		IN OUT message_tbl_t,
				           i		IN OUT INTEGER);

  PROCEDURE insert_proc_task_for_context( msg		IN OUT message_tbl_t,
					  i 		IN OUT INTEGER );

  PROCEDURE	get_context(	ctx_type   IN	VARCHAR2,
				ctx_table  OUT	AZW_PROC.context_tbl_t);

-- End: added by swarup for context sort

  g_current_mode az_processes.process_type%TYPE	;

   msg_delimiter VARCHAR2(1) := '^';
   v_language_code   fnd_languages.language_code%TYPE DEFAULT NULL;
   v_language        fnd_languages.nls_language%TYPE DEFAULT NULL;
   v_days           	varchar2(8) DEFAULT NULL;
   v_skip            	varchar2(8) DEFAULT NULL;
   v_done            	varchar2(8) DEFAULT NULL;
   v_priority_display  	varchar2(16) DEFAULT NULL;

-- group_hierarchy_tree_not_found
--
-- Private function. Called by get_group_hierarchy.
-- Given a group, return TRUE if there is no hierarchy under it.
--

  FUNCTION group_hierarchy_tree_not_found(p_group_id VARCHAR2) RETURN BOOLEAN
    IS
    ret BOOLEAN DEFAULT FALSE;
    v_cnt INTEGER DEFAULT 0;

  BEGIN

    SELECT COUNT(*)
    INTO   v_cnt
    FROM   az_groups
    WHERE  hierarchy_parent_id = p_group_id
    AND    process_type = g_current_mode;

    IF (v_cnt > 0) THEN
      ret := FALSE;
    ELSE
      ret := TRUE;
    END IF;

    RETURN ret;

  EXCEPTION
    WHEN app_exception.application_exception THEN
	RAISE ;
    WHEN OTHERS THEN
   --DBMS_OUTPUT.PUT_LINE('error: group_hierarchy_tree_not_found: ' || SQLERRM);
     fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
     fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
     fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
     fnd_message.set_token('AZW_ERROR_PROC','azw_hier.group_hierarchy_tree_not_found');
     fnd_message.set_token('AZW_ERROR_STMT','select count(*) from az_groups');
     APP_EXCEPTION.RAISE_EXCEPTION;
  END group_hierarchy_tree_not_found;


--
-- get_leaf_nodes
--
-- Private procedure.  Called by get_group_hierarchy.
-- Retrieves all the leaf group nodes for a root process group
--

  PROCEDURE get_leaf_nodes(p_process_group IN VARCHAR2) IS

    v_group_id       az_groups.group_id%TYPE DEFAULT NULL;

    CURSOR leaf_node_cursor IS
      SELECT           group_id
      FROM             az_groups
      WHERE            hierarchy_parent_id is not null
      START WITH       group_id = p_process_group
      AND 	       process_type = g_current_mode
      CONNECT BY PRIOR group_id = hierarchy_parent_id
      AND 	       process_type = g_current_mode
      ORDER BY group_id;

    BEGIN

  --  DBMS_OUTPUT.PUT_LINE('leaf nodes: get_leaf_nodes: ' );
      OPEN leaf_node_cursor;
      FETCH leaf_node_cursor INTO v_group_id;

      WHILE leaf_node_cursor%FOUND LOOP

	BEGIN
	        IF group_hierarchy_tree_not_found(v_group_id) THEN
       		   INSERT INTO az_webform_messages (mesg)
        		VALUES (v_group_id);

        	END IF;

	EXCEPTION
	    WHEN app_exception.application_exception THEN
		RAISE ;
	    WHEN OTHERS THEN
   		--DBMS_OUTPUT.PUT_LINE('error: get_leaf_nodes: ' || SQLERRM);
	        fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	        fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	        fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
     		fnd_message.set_token('AZW_ERROR_PROC','azw_hier.get_leaf_nodes');
		fnd_message.set_token('AZW_ERROR_STMT','insert into az_webform_messages');
		APP_EXCEPTION.RAISE_EXCEPTION;
	END;

        FETCH leaf_node_cursor INTO v_group_id;

      END LOOP;
      CLOSE leaf_node_cursor;

    EXCEPTION
	WHEN app_exception.application_exception THEN
	    RAISE ;
	WHEN OTHERS THEN
		fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
		fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
		fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
		fnd_message.set_token('AZW_ERROR_PROC','azw_hier.get_leaf_nodes');
		fnd_message.set_token('AZW_ERROR_STMT','CURSOR leaf_node_cursor');
		APP_EXCEPTION.RAISE_EXCEPTION;
    END get_leaf_nodes;

--
-- get_process
--
-- Private procedure. Called by get_group_hierarchy.
-- Retrieve all the processes for a given group satisfying the search
-- criteria.
--

  PROCEDURE get_process(rollup_flag    OUT VARCHAR2,
					 p_process_parent_id IN VARCHAR2,
                                         process_status IN VARCHAR2,
					 process_phase IN NUMBER,
                                         assigned_user IN VARCHAR2,
                                         task_status   IN VARCHAR2,
					 task_total_days IN NUMBER,
					 task_total_days_op IN VARCHAR2,
					 sort_by IN VARCHAR2)
    IS
    display_id           NUMBER(5) DEFAULT 0;
    v_group_rollup       VARCHAR2(1);
    v_process_rollup     VARCHAR2(1);
    p_assigned_user      VARCHAR2(30);
    p_task_status        VARCHAR2(10);
    p_sort_by            VARCHAR2(30);
    label                VARCHAR2(400);
			 -- Should be >=  hierarchy_table.display_name
    p_process_status     VARCHAR2(30);
    p_process_phase      NUMBER(3);

    CURSOR    process_hierarchy_ph IS
    SELECT    DISTINCT azp.item_type,
              azp.process_name,
              azp.context_id,
              azp.display_order,
              azp.status_code,
              azp.context_type,
              azp.context_name,
              azp.comments,
              azp.parent_id,
              azfpv.phase,
              wav.display_name
    FROM      az_processes azp,
              az_flow_phases_v azfpv,
              wf_activities_vl wav
    WHERE     azfpv.item_type = azp.item_type
    AND       azfpv.process_name = azp.process_name
    AND       azp.parent_id = p_process_parent_id
    AND	      azp.process_type = g_current_mode
    AND       wav.item_type = azp.item_type
    AND       wav.name = azp.process_name
    AND       wav.end_date is NULL
    ORDER BY  4, 6, 7;

    CURSOR    process_hierarchy_pn_all IS
    SELECT   DISTINCT  azp.item_type,
              azp.process_name,
              azp.context_id,
              azp.display_order,
              azp.status_code,
              azp.context_type,
              azp.context_name,
              azp.comments,
              azp.parent_id,
              azfpv.phase,
              wav.display_name
    FROM      az_processes azp,
              az_flow_phases_v azfpv,
              wf_activities_vl wav
    WHERE     azfpv.item_type = azp.item_type
    AND       azfpv.process_name = azp.process_name
    AND	      azp.process_type = g_current_mode
    AND       wav.item_type = azp.item_type
    AND       wav.name = azp.process_name
    AND       wav.end_date is NULL
    ORDER BY wav.display_name, azp.context_type, azp.context_name;

    CURSOR    process_hierarchy_pn IS
    SELECT    DISTINCT azp.item_type,
              azp.process_name,
              azp.context_id,
              azp.display_order,
              azp.status_code,
              azp.context_type,
              azp.context_name,
              azp.comments,
              azp.parent_id,
              azfpv.phase,
              wav.display_name
    FROM      az_processes azp,
              az_flow_phases_v azfpv,
              wf_activities_vl wav,
              az_webform_messages azm
    WHERE     azfpv.item_type = azp.item_type
    AND       azfpv.process_name = azp.process_name
    AND	      azp.process_type = g_current_mode
    AND       wav.item_type = azp.item_type
    AND       wav.name = azp.process_name
    AND       wav.end_date is NULL
    AND      azp.parent_id = azm.mesg
    ORDER BY wav.display_name, azp.context_type, azp.context_name;

  BEGIN
  --  dbms_output.put_line('get process hierarchy' || process_status);

--  assign the local variables
    p_assigned_user      := assigned_user;
    p_task_status        := task_status;
    p_sort_by            := sort_by;
    p_process_status     := process_status;
    p_process_phase      := process_phase;
    rollup_flag := 'Y';


  IF (p_sort_by = 'PH' OR p_sort_by = 'C') THEN
    BEGIN
      FOR data IN process_hierarchy_ph LOOP

          IF (data.context_name is null) THEN
         	label := data.display_name || data.context_name || ' [' ||
               		   TO_CHAR(data.phase) || ']';
       	  ELSE
         	label := data.display_name || ':  ' || data.context_name ||
               		   ' [' || TO_CHAR(data.phase) || ']';
          END IF; /* data.context_name is null */

          IF (((process_status <> 'ALL') AND (data.status_code = process_status))
        	OR
         	(process_status = 'ALL')
        	OR
         	((process_status = 'I') AND
			((data.status_code = 'A') OR (data.status_code = 'N'))))
          THEN
             IF ((data.phase = process_phase) OR (process_phase = 0)) THEN
	          display_id := display_id + 1;

		     rollup_flag := 'N';
 	             t_index     := t_index + 1;
      		     hierarchy_table(t_index).node_id := data.item_type || '.'
                                 || data.process_name || '.' || data.context_id;
    		     hierarchy_table(t_index).display_name := label;
	             hierarchy_table(t_index).parent_node_id := data.parent_id;
      		     hierarchy_table(t_index).node_type := 'P';
		     hierarchy_table(t_index).context_name := data.context_name;
		     hierarchy_table(t_index).context_type := data.context_type;

 	             IF UPPER(data.status_code) = 'C' THEN
        		hierarchy_table(t_index).status := 'COMPLETED';
      		     ELSE
        		hierarchy_table(t_index).status := 'INCOMPLETE';
      		     END IF; /* UPPER(data.status_code = 'C' */

                     hierarchy_table(t_index).display_order := display_id;

             END IF; /* data.phase = process_phase OR process_phase = 0 */
          END IF; /* process_status <> 'A' AND data.complete_flag = process_status */
     END LOOP;

   EXCEPTION
	WHEN app_exception.application_exception THEN
	    RAISE;
	WHEN OTHERS THEN
	    fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	    fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	    fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	    fnd_message.set_token('AZW_ERROR_PROC','azw_hier.get_process');
	    fnd_message.set_token('AZW_ERROR_STMT','CURSOR  process_hierarchy_ph');
	    APP_EXCEPTION.RAISE_EXCEPTION;
   END;
  ELSE /* p_sort_by = 'PN' */
    BEGIN
      FOR data IN process_hierarchy_pn LOOP
       -- dbms_output.put_line('data found for PN sort ny and not all groups');
        IF (data.context_name is null) THEN
         	label := data.display_name || data.context_name ||
                               ' [' || TO_CHAR(data.phase) || ']';
        ELSE
         	label := data.display_name || ':  ' || data.context_name ||
                               ' [' || TO_CHAR(data.phase) || ']';
        END IF; /* data.context_name is null */

        IF (((process_status <> 'ALL') AND (data.status_code = process_status))
       		OR
         	(process_status = 'ALL')
        	OR
         	((process_status = 'I') AND
			((data.status_code = 'A') OR (data.status_code = 'N'))))
        THEN
             IF ((data.phase = process_phase) OR (process_phase = 0)) THEN
                  display_id := display_id + 1;
                    rollup_flag := 'N';
                    t_index     := t_index + 1;

                    hierarchy_table(t_index).node_id := data.item_type || '.' ||
                        data.process_name || '.' || data.context_id;
                    hierarchy_table(t_index).display_name   := label;
                    hierarchy_table(t_index).parent_node_id := 'root';
                    hierarchy_table(t_index).node_type      := 'P';

                    IF UPPER(data.status_code) = 'C' THEN
                        hierarchy_table(t_index).status := 'COMPLETED';
                    ELSE
                        hierarchy_table(t_index).status := 'INCOMPLETE';
                    END IF; /* UPPER(data.status_code) = 'Y' */

                    hierarchy_table(t_index).display_order := display_id;
   --    dbms_output.put_line('process' || label);

              END IF; /* data.phase = process_phase OR process_phase = 0 */
         END IF;

      END LOOP;
   EXCEPTION
	WHEN OTHERS THEN
	    fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	    fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	    fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	    fnd_message.set_token('AZW_ERROR_PROC','azw_hier.get_process');
	    fnd_message.set_token('AZW_ERROR_STMT','CURSOR  process_hierarchy_pn');
	    APP_EXCEPTION.RAISE_EXCEPTION;
   END;
  END IF; /* p_sort_by = 'PH' */

  EXCEPTION
    WHEN app_exception.application_exception THEN
	RAISE;
    WHEN OTHERS THEN
    --DBMS_OUTPUT.PUT_LINE('error: get_process: ' || SQLERRM);
    fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
    fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
    fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
    fnd_message.set_token('AZW_ERROR_PROC','azw_hier.get_process');
    fnd_message.set_token('AZW_ERROR_STMT','CURSOR  process_hierarchy_pn/ph');
    APP_EXCEPTION.RAISE_EXCEPTION;

  END get_process;


--
-- get_group_hierarchy_tree
--
-- Private procedure.  Called by get_group_hierarchy.
--

  PROCEDURE get_group_hierarchy_tree (group_rollup_flag  OUT VARCHAR2,
                                      process_group      IN VARCHAR2,
				      process_status     IN VARCHAR2,
				      process_phase      IN NUMBER,
			              assigned_user      IN VARCHAR2,
			              task_status        IN VARCHAR2,
				      task_total_days    IN NUMBER,
				      task_total_days_op IN VARCHAR2,
				      sort_by            IN VARCHAR2) IS

    p_process_group             VARCHAR2(20);
    p_process_status            VARCHAR2(20);
    p_process_phase             NUMBER(3);
    p_assigned_user             VARCHAR2(30);
    p_task_status               VARCHAR2(10);
    p_task_total_days           NUMBER(3);
    p_task_total_days_op 	VARCHAR2(5);
    p_sort_by                   VARCHAR2(40);

/*
    Reduced the size of the following ... in the data base they are 240
    v_node_id                   az_groups.group_id%TYPE;
    v_hierarchy_parent_id       az_groups.hierarchy_parent_id%TYPE;
*/
    v_node_id                   VARCHAR2(60);
    v_hierarchy_parent_id       VARCHAR2(60);

    v_display_order             az_groups.display_order%TYPE;
    v_lookup_code               az_groups.lookup_code%TYPE;
    v_rollup_flag               VARCHAR2(1);
    v_group_rollup_flag         VARCHAR2(1);
    v_application_id            az_groups.application_id%TYPE;

    CURSOR group_hierarchy_tree_cursor IS
      SELECT    SUBSTR(group_id, 1, 60),
		SUBSTR(hierarchy_parent_id, 1, 60),
		lookup_code, display_order, application_id
      FROM      az_groups
      WHERE     hierarchy_parent_id = process_group
      AND 	process_type = g_current_mode
      ORDER BY 1;

  BEGIN

  --dbms_output.put_line('get group hierarchy tree: '|| process_group);

    p_process_group      := process_group;
    p_process_status     := process_status;
    p_process_phase      := process_phase;
    p_assigned_user      := assigned_user;
    p_task_status        := task_status;
    p_task_total_days    := task_total_days;
    p_task_total_days_op := task_total_days_op;
    p_sort_by            := sort_by;

    group_rollup_flag    := 'Y';

      OPEN group_hierarchy_tree_cursor;
      FETCH group_hierarchy_tree_cursor
      INTO v_node_id, v_hierarchy_parent_id, v_lookup_code, v_display_order, v_application_id;

      WHILE group_hierarchy_tree_cursor%FOUND LOOP

        IF group_hierarchy_tree_not_found(v_node_id) THEN
          -- this group is a LEAF group
          --dbms_output.put_line('Getting processes for group : ' || v_node_id);

          	get_process(v_rollup_flag, v_node_id, p_process_status,
                                       p_process_phase,
                                       p_assigned_user, p_task_status,
                                       p_task_total_days, p_task_total_days_op,
                                       p_sort_by);

	  -- dbms_output.put_line('Completed get_process for group : ' || v_node_id);

          	IF v_rollup_flag = 'N' THEN

            		-- insert this group as a node
            		group_rollup_flag := 'N';

            	    IF p_sort_by = 'PH' OR p_sort_by = 'C' THEN

              		t_index := t_index + 1;
			 IF (v_application_id is not null) THEN
			      hierarchy_table(t_index).display_name   :=
				AZW_PROC.get_application_name(v_application_id);
			 ELSE
			      hierarchy_table(t_index).display_name   :=
				AZW_PROC.get_lookup_meaning(v_lookup_code);
			 END IF; /* v_application_id is not null */

              		 hierarchy_table(t_index).node_id        := v_node_id;
              		 hierarchy_table(t_index).parent_node_id := v_hierarchy_parent_id;
              		 hierarchy_table(t_index).node_type      := 'G';
              		 hierarchy_table(t_index).status         := 'INCOMPLETE';
              		 hierarchy_table(t_index).display_order  := v_display_order;

            		 --  dbms_output.put_line('Inserted group  : ' || v_node_id);
            	    END IF;
          	END IF;
        ELSE
          -- this group has children groups
	  --dbms_output.put_line('Getting group_hierarchy_tree for group : ' || v_node_id);

         	 get_group_hierarchy_tree(v_group_rollup_flag, v_node_id,
                                   p_process_status, p_process_phase,
                                   p_assigned_user,
                                   p_task_status, p_task_total_days,
                                   p_task_total_days_op, p_sort_by);

	  --dbms_output.put_line('Completed get_group_hierarchy_tree for group: ' || v_node_id);

          	IF v_group_rollup_flag = 'N' THEN
            	-- insert this group as a node
            		group_rollup_flag := 'N';

            	    IF p_sort_by = 'PH' OR p_sort_by = 'C'THEN
              			t_index := t_index + 1;
	 		IF (v_application_id is not null) THEN
              			hierarchy_table(t_index).display_name   :=
	 			AZW_PROC.get_application_name(v_application_id);
	 		ELSE
              			hierarchy_table(t_index).display_name   :=
                		AZW_PROC.get_lookup_meaning(v_lookup_code);
	 	    	END IF; /* v_application_id is not null */

		        hierarchy_table(t_index).node_id        := v_node_id;
		        hierarchy_table(t_index).parent_node_id := v_hierarchy_parent_id;
		        hierarchy_table(t_index).node_type      := 'G';
		        hierarchy_table(t_index).status         := 'INCOMPLETE';
		        hierarchy_table(t_index).display_order  := v_display_order;

           		--   dbms_output.put_line('Inserted group : ' || v_node_id);
            	    END IF;
          	END IF;
       	END IF;

        FETCH group_hierarchy_tree_cursor
        INTO v_node_id, v_hierarchy_parent_id,
		v_lookup_code, v_display_order, v_application_id;

    END LOOP;

      CLOSE group_hierarchy_tree_cursor;

  EXCEPTION
    WHEN app_exception.application_exception THEN
	RAISE;
    WHEN OTHERS THEN
 --dbms_output.put_line('*** Error: get_group_hierarchy_tree: ' || SQLERRM);
    fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
    fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
    fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
    fnd_message.set_token('AZW_ERROR_PROC','azw_hier.get_group_hierarchy_tree');
    fnd_message.set_token('AZW_ERROR_STMT','CURSOR  group_hierarchy_tree_cursor');
    APP_EXCEPTION.RAISE_EXCEPTION;

  END get_group_hierarchy_tree;


--
-- get_group_hierarchy
--
-- Private procedure.  Called by get_hierarchy.
-- Retrieve all the process groups satisfying the selection criteria
--

  PROCEDURE get_group_hierarchy(root_rollup_flag   OUT VARCHAR2,
                                       process_group      IN  VARCHAR2,
				       process_status     IN  VARCHAR2,
				       process_phase      IN  NUMBER,
			               assigned_user      IN  VARCHAR2,
			               task_status        IN  VARCHAR2,
				       task_total_days    IN  NUMBER,
				       task_total_days_op IN VARCHAR2,
				       sort_by            IN VARCHAR2) IS

    p_process_group             VARCHAR2(20);
    p_process_status            VARCHAR2(20);
    p_process_phase             NUMBER(3);
    p_assigned_user             VARCHAR2(30);
    p_task_status               VARCHAR2(10);
    p_task_total_days           NUMBER(3);
    p_task_total_days_op 	VARCHAR2(5);
    p_sort_by			VARCHAR2(40);
/*
    Reduced the size of the following to 60 ... in the data base they are 240 ... too large
    v_node_id                   az_groups.group_id%TYPE;
*/
    v_node_id                   VARCHAR2(60);

    v_display_order             az_groups.display_order%TYPE;
    v_application_id            az_groups.application_id%TYPE;
    v_lookup_code               az_groups.lookup_code%TYPE;
    v_rollup_flag               VARCHAR2(1);
    v_group_rollup_flag         VARCHAR2(1);

  BEGIN

--  dbms_output.enable(1000000);
--  dbms_output.put_line('get grouping hierarchy');

    p_process_group      := process_group;
    p_process_status     := process_status;
    p_process_phase      := process_phase;
    p_assigned_user      := assigned_user;
    p_task_status        := task_status;
    p_task_total_days    := task_total_days;
    p_task_total_days_op := task_total_days_op;
    p_sort_by            := sort_by;

    root_rollup_flag := 'Y';

      v_node_id := p_process_group;

    BEGIN
      SELECT    lookup_code, application_id, display_order
      INTO      v_lookup_code, v_application_id, v_display_order
      FROM      az_groups
      WHERE     group_id = v_node_id
      AND 	process_type = g_current_mode;

    EXCEPTION
	WHEN app_exception.application_exception THEN
	    RAISE;
        WHEN OTHERS THEN
	    fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	    fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	    fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	    fnd_message.set_token('AZW_ERROR_PROC','azw_hier.get_group_hierarchy');
	    fnd_message.set_token('AZW_ERROR_STMT','select lookup_code ... from az_groups');
	    APP_EXCEPTION.RAISE_EXCEPTION;
    END;

      IF group_hierarchy_tree_not_found(v_node_id) THEN

        -- this node is a LEAF node

        IF (p_sort_by = 'PH' OR p_sort_by = 'C') THEN

           get_process(v_rollup_flag, v_node_id, p_process_status,
                       p_process_phase,
                       p_assigned_user, p_task_status,
                       p_task_total_days, p_task_total_days_op,
                       p_sort_by);

--dbms_output.put_line('Completed get_process for group : ' || v_node_id);

           IF v_rollup_flag = 'N' THEN
          	root_rollup_flag := 'N';

          	IF (p_sort_by = 'PH' OR p_sort_by = 'C') THEN
            	    t_index := t_index + 1;

            	    IF (v_application_id is not null) THEN
              		hierarchy_table(t_index).display_name :=
                  		AZW_PROC.get_application_name(v_application_id);
            	    ELSE
              		hierarchy_table(t_index).display_name :=
                  	AZW_PROC.get_lookup_meaning(v_lookup_code);
            	    END IF; /* v_application_id is not null */

		    hierarchy_table(t_index).node_id        := v_node_id;
		    hierarchy_table(t_index).parent_node_id := 'root';
		    hierarchy_table(t_index).node_type      := 'G';
		    hierarchy_table(t_index).status         := 'INCOMPLETE';
		    hierarchy_table(t_index).display_order  := v_display_order;
          	END IF; /* p_sort_by = 'PH'or 'C' */
           END IF; /* v_rollup_flag = 'N' */
       ELSE
	  BEGIN
       		  INSERT INTO az_webform_messages (mesg)
	       		  VALUES (v_node_id);
	  EXCEPTION
	     WHEN app_exception.application_exception THEN
		RAISE;
	     WHEN OTHERS THEN
	    	fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	    	fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	    	fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	    	fnd_message.set_token('AZW_ERROR_PROC','azw_hier.get_group_hierarchy');
	    	fnd_message.set_token('AZW_ERROR_STMT','insert into az_webform_messages');
	    	APP_EXCEPTION.RAISE_EXCEPTION;
	  END;
         get_process(v_rollup_flag, v_node_id, p_process_status,p_process_phase,
                     p_assigned_user, p_task_status,
                     p_task_total_days, p_task_total_days_op, p_sort_by);

       END IF; /* p_sort_by = 'PN' */

      ELSE

        IF (p_sort_by = 'PH' OR p_sort_by = 'C') THEN
	--dbms_output.put_line('Getting group_hierarchy_tree for group : ' || v_node_id);
          	get_group_hierarchy_tree(v_group_rollup_flag, v_node_id,
                                   p_process_status, p_process_phase,
                                   p_assigned_user,
                                   p_task_status, p_task_total_days,
                                   p_task_total_days_op, p_sort_by);

	--dbms_output.put_line('Completed get_group_hierarchy_tree for group: '||v_node_id);

          IF v_group_rollup_flag = 'N' THEN
            	root_rollup_flag := 'N';
            	t_index          := t_index + 1;

            	IF (v_application_id is not null) THEN
              		hierarchy_table(t_index).display_name :=
                  		AZW_PROC.get_application_name(v_application_id);
            	ELSE
              		hierarchy_table(t_index).display_name :=
                  		AZW_PROC.get_lookup_meaning(v_lookup_code);
            	END IF; /* v_application_id is not null */

            	hierarchy_table(t_index).node_id        := v_node_id;
            	hierarchy_table(t_index).parent_node_id := 'root';
            	hierarchy_table(t_index).node_type      := 'G';
            	hierarchy_table(t_index).status         := 'INCOMPLETE';
            	hierarchy_table(t_index).display_order  := v_display_order;
           END IF;
          ELSE
          	get_leaf_nodes(v_node_id);

          	get_process(v_rollup_flag, v_node_id, p_process_status,
                                       p_process_phase,
                                       p_assigned_user, p_task_status,
                                       p_task_total_days, p_task_total_days_op,
                                       p_sort_by);

          END IF; /* p_sort_by = 'PN' */

      --  END IF; /* p_sort_by = 'PH' */

      END IF; /* group_hierarchy_tree_not_found(v_node_id) */

  EXCEPTION
    WHEN app_exception.application_exception THEN
	RAISE;
    WHEN OTHERS THEN
	--dbms_output.put_line('*** Error: get_group_hierarchy: ' || SQLERRM);
	    fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	    fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	    fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	    fnd_message.set_token('AZW_ERROR_PROC','azw_hier.get_group_hierarchy');
	    fnd_message.set_token('AZW_ERROR_STMT','UNKNOWN');
	    APP_EXCEPTION.RAISE_EXCEPTION;
  END get_group_hierarchy;


--
-- task_init
--
-- Private procedure.  Called by get_hierarchy each time the form for
-- hierarchy is shown.
-- Gets the display names of days, done, skip
-- which are part of task label for the current language
--

   PROCEDURE task_init IS
   BEGIN
   -- Set the session language, if necessary
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
                fnd_message.set_token('AZW_ERROR_PROC','azw_hier.get_hierarchy');
                fnd_message.set_token('AZW_ERROR_STMT','select language_code ... from fnd_languages');
                APP_EXCEPTION.RAISE_EXCEPTION;
        END;
        END IF;

	BEGIN
	    SELECT      SUBSTRB(text, 0, 8)
	    INTO        v_days
	    FROM        wf_resources
	    WHERE       language = v_language_code
	    AND         type     = 'WFTKN'
	    AND         name     = 'DAYS';
	EXCEPTION
	    WHEN app_exception.application_exception THEN
		RAISE;
	    WHEN OTHERS THEN
	       	fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
		fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	    	fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
		fnd_message.set_token('AZW_ERROR_PROC','azw_hier.tast_init');
		fnd_message.set_token('AZW_ERROR_STMT','select text into v_days from wf_resources');
		APP_EXCEPTION.RAISE_EXCEPTION;
	END;

	BEGIN
	    SELECT      SUBSTRB(text, 0, 8)
	    INTO        v_done
	    FROM        wf_resources
	    WHERE       language = v_language_code
	    AND         type     = 'WFTKN'
	    AND         name     = 'WFMON_DONE';
	EXCEPTION
	    WHEN app_exception.application_exception THEN
	    	RAISE;
	    WHEN OTHERS THEN
	       	fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
		fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	    	fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
		fnd_message.set_token('AZW_ERROR_PROC','azw_hier.tast_init');
		fnd_message.set_token('AZW_ERROR_STMT','select text into v_done from wf_resources');
		APP_EXCEPTION.RAISE_EXCEPTION;
	END;

	BEGIN
	    SELECT      SUBSTRB(text, 0, 8)
	    INTO        v_skip
	    FROM        wf_resources
	    WHERE       language = v_language_code
	    AND         type     = 'WFTKN'
	    AND         name     = 'WFMON_SKIP';
	EXCEPTION
	    WHEN app_exception.application_exception THEN
	   	RAISE;
	    WHEN OTHERS THEN
	       	fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
		fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	    	fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
		fnd_message.set_token('AZW_ERROR_PROC','azw_hier.tast_init');
		fnd_message.set_token('AZW_ERROR_STMT','select text into v_skip from wf_resources');
		APP_EXCEPTION.RAISE_EXCEPTION;
	END;

	BEGIN
	    SELECT      SUBSTRB(text, 0, 16)
	    INTO        v_priority_display
	    FROM        wf_resources
	    WHERE       language = v_language_code
	    AND         type     = 'WFTKN'
	    AND         name     = 'PRIORITY';
	EXCEPTION
	    WHEN app_exception.application_exception THEN
	    	RAISE;
	    WHEN OTHERS THEN
	       	fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
		fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	    	fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
		fnd_message.set_token('AZW_ERROR_PROC','azw_hier.tast_init');
		fnd_message.set_token('AZW_ERROR_STMT','select text into v_priority_display from wf_resources');
		APP_EXCEPTION.RAISE_EXCEPTION;
	END;
 END task_init;


--
-- get_all_group_hierarchy
--
-- Private procedure. Called by get_hierarchy.
-- Retrieve all the groups
--

  PROCEDURE get_all_group_hierarchy
   IS

/*
    v_node_id                   az_groups.group_id%TYPE;
    v_dependency_parent_id      az_groups.dependency_parent_id%TYPE;
    v_hierarchy_parent_id       az_groups.hierarchy_parent_id%TYPE;
*/
    v_node_id                   VARCHAR2(60);
    v_dependency_parent_id      VARCHAR2(60);
    v_hierarchy_parent_id       VARCHAR2(60);

    v_display_order             az_groups.display_order%TYPE;
    v_application_id            az_groups.application_id%TYPE;
    v_lookup_code               az_groups.lookup_code%TYPE;

    CURSOR root_group_hierarchy_cursor IS
      SELECT    SUBSTR(group_id, 1, 60),
		SUBSTR(dependency_parent_id, 1, 60),
		display_order, application_id, lookup_code
      FROM      az_groups
      WHERE     hierarchy_parent_id is null
      AND 	process_type = g_current_mode
      ORDER BY 1;

   CURSOR group_hierarchy_cursor IS
      SELECT    SUBSTR(group_id, 1, 60),
		SUBSTR(hierarchy_parent_id, 1, 60),
		display_order, application_id, lookup_code
      FROM      az_groups
      WHERE     hierarchy_parent_id is not null
      AND 	process_type = g_current_mode
      ORDER BY 1;

  BEGIN

--    dbms_output.enable(1000000);
--    dbms_output.put_line('get grouping hierarchy');
--  get all the root groups and create root for them

     BEGIN
        OPEN root_group_hierarchy_cursor;
        FETCH root_group_hierarchy_cursor
        	INTO v_node_id, v_dependency_parent_id, v_display_order,
        		v_application_id, v_lookup_code;

        WHILE root_group_hierarchy_cursor%FOUND LOOP
              t_index := t_index + 1;

              IF (v_application_id is not null) THEN
                hierarchy_table(t_index).display_name :=
                    AZW_PROC.get_application_name(v_application_id);
              ELSE
                hierarchy_table(t_index).display_name :=
                    AZW_PROC.get_lookup_meaning(v_lookup_code);
              END IF;

              hierarchy_table(t_index).node_id := v_node_id;
              hierarchy_table(t_index).parent_node_id := 'root';
              hierarchy_table(t_index).node_type := 'G';
              hierarchy_table(t_index).status := 'INCOMPLETE';
              hierarchy_table(t_index).display_order := v_display_order;

          FETCH root_group_hierarchy_cursor
          	INTO v_node_id, v_dependency_parent_id, v_display_order,
               		v_application_id, v_lookup_code;
        END LOOP;
     EXCEPTION
	    WHEN app_exception.application_exception THEN
	    	RAISE;
	    WHEN OTHERS THEN
	       	fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
		fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	    	fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
		fnd_message.set_token('AZW_ERROR_PROC','azw_hier.get_all_group_hierarchy');
		fnd_message.set_token('AZW_ERROR_STMT','CURSOR root_group_hierarchy_cursor');
		APP_EXCEPTION.RAISE_EXCEPTION;
     END;

--  get all the remaining hierarchy leaf groups and insert into hierarchy table
     BEGIN
        OPEN group_hierarchy_cursor;
        FETCH group_hierarchy_cursor
        	INTO v_node_id, v_hierarchy_parent_id, v_display_order,
        		v_application_id, v_lookup_code;

        WHILE group_hierarchy_cursor%FOUND LOOP
              t_index := t_index + 1;

              IF (v_application_id is not null) THEN
                hierarchy_table(t_index).display_name :=
                    AZW_PROC.get_application_name(v_application_id);
              ELSE
                hierarchy_table(t_index).display_name :=
                    AZW_PROC.get_lookup_meaning(v_lookup_code);
              END IF;

              hierarchy_table(t_index).node_id        := v_node_id;
              hierarchy_table(t_index).parent_node_id := v_hierarchy_parent_id;
              hierarchy_table(t_index).node_type      := 'G';
              hierarchy_table(t_index).status         := 'INCOMPLETE';
              hierarchy_table(t_index).display_order  := v_display_order;

           FETCH group_hierarchy_cursor
             	INTO v_node_id, v_hierarchy_parent_id, v_display_order,
               		v_application_id, v_lookup_code;
        END LOOP;

     EXCEPTION
	    WHEN app_exception.application_exception THEN
	    	RAISE;
	    WHEN OTHERS THEN
	       	fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
		fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	    	fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
		fnd_message.set_token('AZW_ERROR_PROC','azw_hier.get_all_group_hierarchy');
		fnd_message.set_token('AZW_ERROR_STMT','CURSOR group_hierarchy_cursor');
		APP_EXCEPTION.RAISE_EXCEPTION;
     END;

    EXCEPTION
	WHEN app_exception.application_exception THEN
	    RAISE;
	WHEN OTHERS THEN
	    fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	    fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	    fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	    fnd_message.set_token('AZW_ERROR_PROC','azw_hier.get_all_group_hierarchy');
	    fnd_message.set_token('AZW_ERROR_STMT','CURSOR group_hierarchy_cursor');
	    APP_EXCEPTION.RAISE_EXCEPTION;

  END get_all_group_hierarchy;


--
-- get_all_process
--
-- Private procedure.  Called by get_hierarchy.
-- Retrieve all the processes satisfying the selection criteria
-- without getting tasks belonging to the processes
--

  PROCEDURE get_all_process(process_status IN VARCHAR2,
                            process_phase IN NUMBER,
                            sort_by IN VARCHAR2)
  IS
    display_id       NUMBER(5) DEFAULT 0;
    p_sort_by        VARCHAR2(30);
    label            VARCHAR2(400); -- Should be the same as hierarchy_table.display_name

    CURSOR    process_hierarchy_ph IS
    SELECT    DISTINCT azp.item_type,
              azp.process_name,
              azp.context_id,
              azp.display_order,
              azp.status_code,
              azp.context_type,
              azp.context_name,
              azp.comments,
              azp.parent_id,
              azfpv.phase,
              wav.display_name
    FROM      wf_activities_vl wav,
              az_processes azp,
              az_flow_phases_v azfpv
    WHERE     azfpv.item_type = azp.item_type
    AND       azfpv.process_name = azp.process_name
    AND	      azp.process_type = g_current_mode
    AND       wav.item_type = azp.item_type
    AND       wav.name = azp.process_name
    AND       wav.end_date is NULL
    ORDER BY  4, 6, 7;

    CURSOR    process_hierarchy_pn_all IS
    SELECT    DISTINCT azp.item_type,
              azp.process_name,
              azp.context_id,
              azp.display_order,
              azp.status_code,
              azp.context_type,
              azp.context_name,
              azp.comments,
              azp.parent_id,
              azfpv.phase,
              wav.display_name
    FROM      wf_activities_vl wav,
              az_processes azp,
              az_flow_phases_v azfpv
    WHERE     azfpv.item_type = azp.item_type
    AND       azfpv.process_name = azp.process_name
    AND	      azp.process_type = g_current_mode
    AND       wav.item_type = azp.item_type
    AND       wav.name = azp.process_name
    AND       wav.end_date is NULL
    ORDER BY wav.display_name, azp.context_type, azp.context_name;

 BEGIN

--  when sort by is Process Hierarchy
    IF (sort_by = 'PH' OR sort_by = 'C') THEN
       BEGIN
           FOR data IN process_hierarchy_ph LOOP
       		IF (data.context_name is null) THEN
         		label := data.display_name ||  data.context_name
				|| ' [' || TO_CHAR(data.phase) || ']';
      		ELSE
       			label := data.display_name || ':  ' || data.context_name
				|| ' [' || TO_CHAR(data.phase) || ']';
      		END IF;
   	--dbms_output.put_line('getting data for process 2' || data.display_name);

       		IF (((process_status <> 'ALL') AND (data.status_code = process_status))
        	OR
         	(process_status = 'ALL')
        	OR
         	((process_status = 'I') AND
			((data.status_code = 'A') OR (data.status_code = 'N'))))
        	THEN
             	    IF ((data.phase = process_phase) OR (process_phase = 0)) THEN
			  display_id := display_id + 1;
			  t_index    := t_index + 1;

			  hierarchy_table(t_index).node_id := data.item_type || '.' ||
					   data.process_name || '.' || data.context_id;
			  hierarchy_table(t_index).display_name   := label;
			  hierarchy_table(t_index).parent_node_id := data.parent_id;
			  hierarchy_table(t_index).node_type      := 'P';
			  hierarchy_table(t_index).context_name := data.context_name;
			  hierarchy_table(t_index).context_type := data.context_type;

			 IF UPPER(data.status_code) = 'C' THEN
				hierarchy_table(t_index).status := 'COMPLETED';
			 ELSE
				hierarchy_table(t_index).status := 'INCOMPLETE';
			 END IF;
			 hierarchy_table(t_index).display_order := display_id;

            		--dbms_output.put_line('inserted process ' || label);
             	   END IF;
       		END IF;
           END LOOP;
       EXCEPTION
	    WHEN app_exception.application_exception THEN
	    	RAISE;
	    WHEN OTHERS THEN
	       	fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
		fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	    	fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
		fnd_message.set_token('AZW_ERROR_PROC','azw_hier.get_all_process');
		fnd_message.set_token('AZW_ERROR_STMT','CURSOR process_hierarchy_ph');
		APP_EXCEPTION.RAISE_EXCEPTION;
       END;

   ELSE
	--  When sort by is by Process Name
     BEGIN
       	FOR data IN process_hierarchy_pn_all LOOP
           IF (data.context_name is null) THEN
           	label := data.display_name ||  data.context_name || ' [' ||
                    TO_CHAR(data.phase) || ']';
      	   ELSE
       		label := data.display_name || ':  ' || data.context_name || ' [' ||
                    TO_CHAR(data.phase) || ']';
      	   END IF;

           IF (((process_status <> 'ALL') AND (data.status_code = process_status))
              OR
              (process_status = 'ALL')
              OR
              ((process_status = 'I') AND
	           ((data.status_code = 'A') OR (data.status_code = 'N'))))
           THEN
		IF ((data.phase = process_phase) OR (process_phase = 0)) THEN
                  	display_id := display_id + 1;
                  	t_index    := t_index + 1;
                  	hierarchy_table(t_index).node_id := data.item_type || '.' ||
                                 	data.process_name || '.'   || data.context_id;
                  	hierarchy_table(t_index).display_name   := label;
                  	hierarchy_table(t_index).parent_node_id := 'root';
                  	hierarchy_table(t_index).node_type      := 'P';

                 	IF UPPER(data.status_code) = 'C' THEN
                        	hierarchy_table(t_index).status := 'COMPLETED';
                 	ELSE
                        	hierarchy_table(t_index).status := 'INCOMPLETE';
                 	END IF;

                 	hierarchy_table(t_index).display_order := display_id;
                END IF;
            END IF;
         END LOOP;
      EXCEPTION
	    WHEN app_exception.application_exception THEN
	    	RAISE;
	    WHEN OTHERS THEN
	       	fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
		fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	    	fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
		fnd_message.set_token('AZW_ERROR_PROC','azw_hier.get_all_process');
		fnd_message.set_token('AZW_ERROR_STMT','CURSOR process_hierarchy_pn_all');
		APP_EXCEPTION.RAISE_EXCEPTION;
      END;
   END IF;

    EXCEPTION
	WHEN app_exception.application_exception THEN
	    RAISE;
	WHEN OTHERS THEN
	    fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	    fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	    fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	    fnd_message.set_token('AZW_ERROR_PROC','azw_hier.get_all_process');
	    fnd_message.set_token('AZW_ERROR_STMT','UNKNOWN');
	    APP_EXCEPTION.RAISE_EXCEPTION;

  END get_all_process;


--
-- get_all_task
--
-- Private procedure.  Called by get_hierarchy.
-- Gets all the tasks satisfying the search criteria.
--

  PROCEDURE get_all_task(p_process_status IN VARCHAR2,
                         p_process_phase  IN NUMBER,
                         p_assigned_user IN VARCHAR2,
                         p_task_status IN VARCHAR2,
                         p_task_tot_days IN NUMBER,
                         p_task_tot_days_op IN VARCHAR2,
                         p_sort_by IN VARCHAR2)
        IS
    v_item_type        az_processes.item_type%TYPE;
    v_item_type_p      az_processes.item_type%TYPE;
    v_process_name     az_processes.process_name%TYPE;
    v_parent_id        az_processes.parent_id%TYPE;
    v_comments         az_processes.comments%TYPE;
    v_context_id       az_processes.context_id%TYPE;
    v_status_code      az_processes.status_code%TYPE;
    v_context_type     az_processes.context_type%TYPE;
    v_context_name     az_processes.context_name%TYPE;
    v_display_order    az_processes.display_order%TYPE;

    v_status           wf_item_activity_statuses.activity_status%TYPE;
    v_task_status wf_item_activity_statuses.activity_status%TYPE;
    v_dummy_begin_date wf_item_activity_statuses.begin_date%TYPE;
    v_root_activity    wf_items.root_activity%TYPE;
    v_item_key         wf_items.item_key%TYPE;
    v_count            NUMBER(4);
    v_skip_count       NUMBER(4);
    v_display_string   wf_activities_vl.display_name%TYPE;
    v_days_no          NUMBER(4);
    v_role_assd        wf_item_attribute_values.text_value%TYPE;
    display_id         NUMBER(5) DEFAULT 0;
    v_task_begin_date  wf_items.begin_date%TYPE;
    v_task_tot_days    NUMBER(5) DEFAULT 0;
    v_days_since       NUMBER(5) DEFAULT 0;
    v_process_phase    az_product_phases.phase%TYPE;
    v_display_status   wf_resources.text%TYPE;

    CURSOR az_item_types IS
    SELECT  distinct item_type
    FROM    az_processes;

    CURSOR az_tasks_cursor IS
      SELECT   DISTINCT  wfi.item_key,
                wfi.root_activity,
                wfi.begin_date,
                round( months_between(sysdate, wfi.begin_date)* 31),
                wias.activity_status,
                wiav2.text_value,
                azpfv.phase,
                azp.status_code,
                azp.item_type,
                azp.context_id
      FROM      wf_item_attribute_values wiav1,
                wf_item_attribute_values wiav2,
                wf_item_activity_statuses wias,
                wf_process_activities  wpa,
                az_processes azp,
                az_flow_phases_v azpfv,
                wf_items wfi
      WHERE     wfi.item_type = azp.item_type
      AND       wfi.root_activity = azp.process_name
      AND       azpfv.item_type = azp.item_type
      AND       azpfv.process_name = azp.process_name
      AND       wiav1.item_type = azp.item_type
      AND       wiav1.item_key = wfi.item_key
      AND       wiav1.name = 'AZW_IA_CTXT_ID'
      AND       wiav1.text_value = to_char(azp.context_id)
      AND       wiav2.item_type = wfi.item_type
      AND       wiav2.item_key = wfi.item_key
      AND       wiav2.name = 'AZW_IA_ROLE'
      AND       wias.item_type = wfi.item_type
      AND       wias.item_key = wfi.item_key
      AND       wpa.instance_id = wias.process_activity
      AND       wpa.activity_name = wfi.root_activity
      AND       wpa.process_item_type = azp.item_type
      AND       wpa.process_name = 'ROOT'
      AND       azp.item_type = v_item_type_p
      ORDER BY  wfi.begin_date;

    CURSOR az_steps_count_cursor IS
      SELECT COUNT(*)
      FROM   wf_item_activity_statuses wias, wf_notification_attributes wna,
             wf_notifications wn
      WHERE  wias.item_type = v_item_type
      AND    wias.item_key = v_item_key
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
      WHERE  wias.item_type = v_item_type
      AND    wias.item_key = v_item_key
      AND    wias.notification_id is not NULL
      AND    wna.notification_id = wias.notification_id
      AND    wn.notification_id = wna.notification_id
      AND    wn.status = 'CLOSED'
      AND    wna.name = 'RESULT'
      AND    wna.text_value like '%SKIP%';

    CURSOR az_task_display_cursor IS
      SELECT    wav.display_name,
                round( months_between(sysdate, wias.begin_date)* 31),
                wias.begin_date
      FROM      wf_process_activities wpa, wf_item_activity_statuses wias,
                wf_activities_vl wav
      WHERE     wias.item_type = v_item_type
      AND       wias.item_key = v_item_key
      AND       wias.process_activity = wpa.instance_id
      AND       wpa.activity_name = wav.name
      AND       wpa.activity_item_type = wav.item_type
      AND       wpa.process_name <> 'ROOT'
      AND       wpa.activity_name <> 'START'
      AND       wav.begin_date is not NULL
      AND       wav.end_date is NULL
      AND       wav.type = 'NOTICE'
      ORDER BY  wias.begin_date desc;

  BEGIN
--   dbms_output.put_line('get tasks all  hierarchy');
--   dbms_output.put_line('Done with lookups');
--   Get iterations for processes
--   dbms_output.put_line('Task status is :' || p_task_status);
--   dbms_output.put_line('getting all statuses tasks');
--   Get all tasks one at a time

   OPEN az_item_types;
   FETCH az_item_types
       INTO  v_item_type_p;

   WHILE az_item_types%FOUND LOOP

   	OPEN az_tasks_cursor;
   	FETCH az_tasks_cursor
       	INTO  v_item_key, v_root_activity, v_task_begin_date, v_task_tot_days,
	      v_task_status, v_role_assd, v_process_phase, v_status_code,
	      v_item_type, v_context_id;

	-- IMPORTANT ... trim v_role_assd to 60 characters  and v_item_key to 100
	v_role_assd := SUBSTR(v_role_assd, 1, 100);
	v_item_key  := SUBSTR(v_item_key, 1, 15);

 	BEGIN

   	     WHILE az_tasks_cursor%FOUND LOOP
   			--dbms_output.put_line('Found all statuses tasks: ' || v_item_key);
         	display_id := display_id + 1;

	 	OPEN  az_task_display_cursor;
	 	FETCH az_task_display_cursor
	      	INTO  v_display_string, v_days_since,
		       v_dummy_begin_date;

 			--dbms_output.put_line('Opening count cursor');

	 	OPEN az_steps_count_cursor;
	 	FETCH az_steps_count_cursor INTO v_count;

	 	OPEN az_skip_count_cursor;
	 	FETCH az_skip_count_cursor INTO v_skip_count;

 			--dbms_output.put_line('count: ' || v_count);

       		IF(((p_task_tot_days_op = '=') AND (v_task_tot_days = p_task_tot_days))
            	OR
         	((p_task_tot_days_op = '>') AND (v_task_tot_days > p_task_tot_days))
            	OR
         	((p_task_tot_days_op = '<') AND (v_task_tot_days < p_task_tot_days))
            	OR
         	((p_task_tot_days_op = '<=') AND (v_task_tot_days <= p_task_tot_days))
            	OR
         	((p_task_tot_days_op = '>=') AND (v_task_tot_days >= p_task_tot_days))
            	OR
         	((p_task_tot_days_op = '!=') AND (v_task_tot_days <> p_task_tot_days)))
      		THEN
        	    IF((v_role_assd = p_assigned_user) OR (p_assigned_user = 'ALL'))
        	    AND (((p_task_status = 'A') AND (v_task_status = 'ACTIVE')) OR (p_task_status = 'ALL')
            	    OR ((p_task_status = 'C') AND (v_task_status <> 'ACTIVE')))
        	    AND ((v_process_phase = p_process_phase) OR (p_process_phase = 0))
        	    AND (((v_status_code = p_process_status) OR (p_process_status = 'ALL'))
              	    OR (( p_process_status = 'I') AND ((v_status_code = 'A') OR (v_status_code = 'N'))))
 		    THEN
 				-- dbms_output.put_line('inserting task');
	  		BEGIN
				t_index := t_index + 1;
				hierarchy_table(t_index).node_id := v_item_type || '.' ||
					v_root_activity || '.'|| v_context_id || '.' || v_item_key;
				hierarchy_table(t_index).parent_node_id := v_item_type || '.' ||
					v_root_activity || '.' || v_context_id;
				hierarchy_table(t_index).node_type := 'I';

				IF (v_task_status = 'ACTIVE') THEN
					hierarchy_table(t_index).status := 'INCOMPLETE';
					hierarchy_table(t_index).display_name := v_display_string ||
						': ' || v_role_assd || '  - ' ||to_char(v_task_tot_days)
						|| ' '|| v_days || ': ' || to_char(v_count) ||' '||
						v_done || ' , '|| to_char(v_skip_count) || ' ' || v_skip;
				ELSE
					hierarchy_table(t_index).status := 'COMPLETED';
					hierarchy_table(t_index).display_name :=   v_role_assd ||
						'  - ' ||to_char(v_task_tot_days) || ' '|| v_days ||
						': ' || to_char(v_count) ||' '|| v_done || ' , '||
						to_char(v_skip_count) || ' ' || v_skip;
				END IF;

            			hierarchy_table(t_index).display_order := display_id;

		  	EXCEPTION
				WHEN app_exception.application_exception THEN
				    RAISE;
				WHEN OTHERS THEN
				    fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
				    fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
				    fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
				    fnd_message.set_token('AZW_ERROR_PROC','azw_hier.get_all_task');
				    fnd_message.set_token('AZW_ERROR_STMT','while inserting task to hierarchy table');
				    APP_EXCEPTION.RAISE_EXCEPTION;
		  	END;
        	    END IF;
        	END IF;

		CLOSE az_task_display_cursor;
		CLOSE az_steps_count_cursor;
		CLOSE az_skip_count_cursor;

             FETCH az_tasks_cursor
             INTO  v_item_key, v_root_activity, v_task_begin_date, v_task_tot_days,
              	v_task_status, v_role_assd, v_process_phase, v_status_code,
              	v_item_type, v_context_id;
     	END LOOP;

  	CLOSE az_tasks_cursor;

  	EXCEPTION
		WHEN app_exception.application_exception THEN
	    	RAISE;
		WHEN OTHERS THEN
	    	fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	    	fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	    	fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	    	fnd_message.set_token('AZW_ERROR_PROC','azw_hier.get_all_task');
	    	fnd_message.set_token('AZW_ERROR_STMT','While looping in CURSOR az_tasks_cursor');
	    	APP_EXCEPTION.RAISE_EXCEPTION;
	END;

  	FETCH az_item_types
     	INTO  v_item_type_p;
     END LOOP;
     CLOSE az_item_types;

  EXCEPTION
	WHEN app_exception.application_exception THEN
	    RAISE;
	WHEN OTHERS THEN
	    fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	    fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	    fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	    fnd_message.set_token('AZW_ERROR_PROC','azw_hier.get_all_task');
	    fnd_message.set_token('AZW_ERROR_STMT','While looping in CURSOR az_item_types');
	    APP_EXCEPTION.RAISE_EXCEPTION;

  END get_all_task;


--
-- GET_HIERARCHY
--
-- Public procedure.  Called by Process Overview window.
-- The message format which has been agreed upon between front end
-- and back end is as follows:
--
-- display_name^node_id^parent_node_id^node_type^status^display_order^^
--

  PROCEDURE get_hierarchy (process_group      IN VARCHAR2,
                           process_status     IN VARCHAR2,
                           process_phase      IN NUMBER,
			   assigned_user      IN VARCHAR2,
                           task_status        IN VARCHAR2,
                           task_total_days    IN NUMBER,
			   task_total_days_op IN VARCHAR2,
                           sort_by            IN VARCHAR2)
    IS

    msg                  message_tbl_t;
    i                    BINARY_INTEGER DEFAULT 0;
    p_process_group      az_groups.group_id%TYPE;
    p_process_status     VARCHAR2(20);
    p_process_phase      NUMBER(3);
    p_assigned_user      VARCHAR2(30);
    p_task_status        VARCHAR2(10);
    p_task_total_days    NUMBER(3);
    p_task_total_days_op VARCHAR2(5);
    p_sort_by            VARCHAR2(40);
    v_root_rollup_flag   VARCHAR2(1);

-- Start: added by swarup for context sort
    disp_order INTEGER ;
    v_context_type 	fnd_lookups.lookup_code%TYPE;
    v_meaning 		fnd_lookups.meaning%TYPE;

    CURSOR	get_context_types_c IS

	SELECT	lookup_code,
		meaning,
               	DECODE(lookup_code, 'NONE', 1, 'BG', 2, 'SOB', 3, 'OU', 4, 5)
                	display_order
	FROM	fnd_lookups
	WHERE	lookup_type = 'AZ_CONTEXT_TYPE'
      	ORDER BY display_order;

-- End: added by swarup for context sort

  BEGIN
    dbms_output.enable(1000000);
--    DBMS_OUTPUT.PUT_LINE('get_hierarchy: ');
   --  assign the variables
    p_process_status     := process_status;
    p_process_group      := process_group;
    p_process_phase      := process_phase;
    p_assigned_user      := assigned_user;
    p_task_status        := task_status;
    p_task_total_days    := task_total_days;
    p_task_total_days_op := task_total_days_op;
    p_sort_by            := sort_by;

   -- get the current mode
  	g_current_mode := fnd_profile.value('AZ_CURRENT_MODE');

   --  get the current session language
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
		fnd_message.set_token('AZW_ERROR_PROC','azw_hier.get_hierarchy');
		fnd_message.set_token('AZW_ERROR_STMT','select language_code .. from fnd_languages');
		APP_EXCEPTION.RAISE_EXCEPTION;
	END;

--  initialize the language specific display labels for task's label
    task_init;
    hierarchy_table.delete;
    msg.delete;
    t_index := 0;

--  AZW_PROC.populate_az_processes is now called from AZWIZARD.fmb within the
--  WHEN_NEW_FORM_INSTANCE trigger instead.
--  AZW_PROC.populate_az_processes; --  DONT REMOVE THIS !!!

--  get groups, then get processes and then tasks
    IF (p_process_group = 'ALL') THEN
      IF (p_sort_by = 'PH' OR p_sort_by = 'C') THEN
        get_all_group_hierarchy;
      END IF;

      get_all_process(p_process_status, p_process_phase, p_sort_by);

      get_all_task(p_process_status, p_process_phase, p_assigned_user,
                   p_task_status, p_task_total_days, p_task_total_days_op, p_sort_by);
    ELSE
    -- get groups which then get processes and tasks recursively
    --dbms_output.put_line('Calling');
       get_group_hierarchy(v_root_rollup_flag, p_process_group,p_process_status,
                   p_process_phase, p_assigned_user,
                   p_task_status, p_task_total_days,
                   p_task_total_days_op, p_sort_by);
       get_all_task(p_process_status, p_process_phase, p_assigned_user,
                   p_task_status, p_task_total_days, p_task_total_days_op,
                   p_sort_by);
    END IF;

-- The following condition is added by swarup for context sort
IF (p_sort_by = 'C')	THEN

   BEGIN
    OPEN    get_context_types_c ;
        FETCH   get_context_types_c INTO v_context_type, v_meaning, disp_order;
        WHILE   get_context_types_c%FOUND LOOP
		-- Make nodes with Context Names with each context type
		-- This will add all groups and their sub groups under
		-- each node
		-- dbms_output.put_line('TYPE: ' || v_context_type ||' meaning: ' || v_meaning );
		ctx_table.delete ;

		IF UPPER(v_context_type) = 'NONE' THEN
			ctx_table(1).context_name := v_context_type;
			ctx_table(1).context_id := 0;	-- Shouldn't be used, careful.
		ELSE
			get_context(v_context_type, ctx_table);

		END IF;
                insert_context( v_context_type, v_meaning, msg, i, disp_order);

		-- Now insert groups for each context
		-- unnecessary groups will be rolled up by java
		-- from hierarchy table
 		insert_groups_for_context(v_context_type, msg, i);
                FETCH   get_context_types_c INTO v_context_type, v_meaning, disp_order;
          END   LOOP;
      CLOSE   get_context_types_c ;

     EXCEPTION
	 WHEN app_exception.application_exception THEN
	    RAISE;
	 WHEN OTHERS THEN
	    fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	    fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	    fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	    fnd_message.set_token('AZW_ERROR_PROC','azw_hier.get_hierarchy');
	    fnd_message.set_token('AZW_ERROR_STMT','CURSOR get_context_types_c');
	    APP_EXCEPTION.RAISE_EXCEPTION;
     END;

	-- Now insert processes/tasks for each their respective context
	insert_proc_task_for_context(msg, i);

ELSE -- Either 'PH' or 'PN'
    FOR j IN 1..hierarchy_table.COUNT LOOP
     i := i + 1;
     msg(i) := hierarchy_table(j).display_name || msg_delimiter ||
             hierarchy_table(j).node_id || msg_delimiter ||
             hierarchy_table(j).parent_node_id || msg_delimiter ||
             hierarchy_table(j).node_type || msg_delimiter ||
             hierarchy_table(j).status || msg_delimiter ||
             hierarchy_table(j).display_order || msg_delimiter || msg_delimiter;
    END LOOP;
END IF;

	  BEGIN
	    -- Somehow table.COUNT doesn't work.. so use i, which is the count of rows
	    IF i > 0 THEN
	    	FORALL k IN 1..i
	      	    INSERT INTO az_webform_messages (mesg)
	      		VALUES (msg(k));
	    END IF;

	  EXCEPTION
	     WHEN app_exception.application_exception THEN
	    	RAISE;
	     WHEN OTHERS THEN
		fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
		fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
		fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
		fnd_message.set_token('AZW_ERROR_PROC','azw_hier.get_hierarchy');
		fnd_message.set_token('AZW_ERROR_STMT','insert into az_webform_messages');
		APP_EXCEPTION.RAISE_EXCEPTION;
	  END;

  EXCEPTION
    WHEN app_exception.application_exception THEN
	RAISE;
    WHEN OTHERS THEN
    --DBMS_OUTPUT.PUT_LINE('error: get_hierarchy: ' || SQLERRM);
	fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	fnd_message.set_token('AZW_ERROR_PROC','azw_hier.get_hierarchy');
	fnd_message.set_token('AZW_ERROR_STMT','UNKNOWN');
      	APP_EXCEPTION.RAISE_EXCEPTION;

  END get_hierarchy;

/*---------------------------------------------------------------
  INSERT_PROC_TASK_FOR_CONTEXT
	private procedure inserts all processes and tasks
---------------------------------------------------------------*/

PROCEDURE	insert_proc_task_for_context(
				msg		IN OUT message_tbl_t,
				i		IN OUT INTEGER ) IS
  p_context_name	VARCHAR2(200);
  p_context_type	VARCHAR2(20);
  parent_id		VARCHAR2(220);
  node_id		VARCHAR2(220);
BEGIN
	FOR j IN 1..hierarchy_table.COUNT LOOP
		IF ( hierarchy_table(j).node_type = 'G') THEN
			NULL;
		ELSE
			parent_id := hierarchy_table(j).parent_node_id;
			--dbms_output.put_line('Here: '|| parent_id );
		   IF ( hierarchy_table(j).node_type = 'P') THEN

			p_context_type := hierarchy_table(j).context_type;
			p_context_name := hierarchy_table(j).context_name;

			   IF ( UPPER(p_context_type) = 'NONE' )  THEN
			        parent_id := parent_id ||
					'NONE' || 'NONE';
			   ELSE
				parent_id := parent_id ||
					p_context_type || p_context_name ;
			   END IF;
		   END IF;
			node_id := hierarchy_table(j).node_id ;
			i := i + 1;
		     	msg(i) := hierarchy_table(j).display_name || msg_delimiter ||
			     node_id || msg_delimiter ||
			     parent_id || msg_delimiter ||
			     hierarchy_table(j).node_type || msg_delimiter ||
			     hierarchy_table(j).status || msg_delimiter ||
			     hierarchy_table(j).display_order ||
			     msg_delimiter || msg_delimiter;
		END IF;
	END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
    --DBMS_OUTPUT.PUT_LINE('error: insert_proc_task_for_context: ' || SQLERRM);
       	fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
    	fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	fnd_message.set_token('AZW_ERROR_PROC','azw_hier.insert_proc_task_for_context');
	fnd_message.set_token('AZW_ERROR_STMT','UNKNOWN');
      	APP_EXCEPTION.RAISE_EXCEPTION;
  END insert_proc_task_for_context;

  /*---------------------------------------------------------------
   * INSERT_CONTEXT
     Private procedure : added by swarup for context sort
     This procedure adds five node at the root level
	1. NONE
	2. BG
	3. SOB
	4. OU
	5. IO
     Then all contexts are added below respective types
	EXCEPT 'NONE', which doesn't have context

   -------------------------------------------------------------- */
  PROCEDURE insert_context( ctx_type	IN VARCHAR2,
				meaning		IN VARCHAR2,
  				msg		IN OUT message_tbl_t,
  				i		IN OUT INTEGER,
  				p_disp_order	IN INTEGER
				) IS
  l_disp_order	INTEGER DEFAULT 0;
  l_meaning	fnd_lookups.meaning%TYPE;

  BEGIN

	l_meaning := meaning ;

	--IF meaning = 'NULL' OR meaning IS NULL OR meaning = '' THEN
	IF ctx_type = 'NONE' THEN
			-- note that context type is concatenated twice
			-- this will be used for attaching groups below it
	  	i := i + 1;
		msg(i) := NVL(meaning,'NONE') || msg_delimiter ||
		     ctx_type || ctx_type || msg_delimiter ||
		     'root'|| msg_delimiter ||
		     'G'|| msg_delimiter ||
		     'INCOMPLETE'|| msg_delimiter ||
		     p_disp_order || msg_delimiter || msg_delimiter;
	ELSE

		-- First add the context type

	  	i := i + 1;
		msg(i) := meaning || msg_delimiter ||
		     ctx_type || msg_delimiter ||
		     'root'|| msg_delimiter ||
		     'G'|| msg_delimiter ||
		     'INCOMPLETE'|| msg_delimiter ||
		     p_disp_order || msg_delimiter || msg_delimiter;

		-- Now add all context under type

	   	FOR l in 1..ctx_table.COUNT LOOP
			l_disp_order := l_disp_order + 1;
	  		i := i + 1;
			msg(i) := ctx_table(l).context_name || msg_delimiter ||
			     ctx_type||ctx_table(l).context_name|| msg_delimiter ||
			     ctx_type || msg_delimiter ||
			     'G'|| msg_delimiter ||
			     'INCOMPLETE'|| msg_delimiter ||
			     l_disp_order || msg_delimiter || msg_delimiter;
	   	END LOOP;
	END IF;
   EXCEPTION
      WHEN OTHERS THEN
     --DBMS_OUTPUT.PUT_LINE('error: insert_context: ' || SQLERRM);
       	fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
    	fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	fnd_message.set_token('AZW_ERROR_PROC','azw_hier.insert_context');
	fnd_message.set_token('AZW_ERROR_STMT','UNKNOWN');
      	APP_EXCEPTION.RAISE_EXCEPTION;
  END insert_context;


 FUNCTION  validContextType( ctx_type IN VARCHAR2,p_node_id VARCHAR2) RETURN BOOLEAN IS
        v_count         PLS_INTEGER := 0;
        v_application_id      az_groups.application_id%TYPE;

        CURSOR get_subgroup_c IS
                select group_id from az_groups
                where
                        hierarchy_parent_id = p_node_id
                        and process_type = g_current_mode;

  BEGIN
	SELECT count(distinct context_type)
	INTO   v_count
	FROM   az_processes
	WHERE  context_type = ctx_type
	  AND  process_type = g_current_mode
	  AND  parent_id = p_node_id ;

	IF v_count > 0 THEN
		return TRUE;
	ELSE
	    FOR data IN get_subgroup_c LOOP
		IF validContextType( ctx_type,data.group_id ) = TRUE THEN
				return TRUE;
		END IF;
	    END LOOP;
        END IF;

        RETURN FALSE;

  EXCEPTION
      WHEN OTHERS THEN
        return TRUE;
--     Do not put exception handler here
  END validContextType;


  /*---------------------------------------------------------------
   * INSERT_NODES_FOR_CONTEXT_TYPE
     Private procedure : added by swarup for context sort
     This procedure loops thru all the nodes of hierarchy table
     ( as retrieved as a hieararchy ), adds all groups for each
    context type : name pair , and processes/tasks for their
    own  context type : name pair only
   -------------------------------------------------------------- */

  PROCEDURE	insert_groups_for_context(
				ctx_type	IN VARCHAR2,
				msg		IN OUT message_tbl_t,
				i		IN OUT INTEGER
				) IS
  parent_id		VARCHAR2(220); -- id := context_name || context_type
  node_id		VARCHAR2(220);

  BEGIN

	FOR j IN 1..hierarchy_table.COUNT LOOP
	    IF ( hierarchy_table(j).node_type = 'G' AND
 		  validContextType( ctx_type, hierarchy_table(j).node_id ) = TRUE ) THEN

	        FOR k IN 1..ctx_table.COUNT LOOP
		   IF ( hierarchy_table(j).parent_node_id = 'root') THEN
			parent_id := ctx_type || ctx_table(k).context_name;
		   ELSE
			parent_id := hierarchy_table(j).parent_node_id ||
					ctx_type || ctx_table(k).context_name ;
		   END IF;

			node_id := hierarchy_table(j).node_id ||
					ctx_type || ctx_table(k).context_name ;
			i := i + 1;
		     	msg(i) := hierarchy_table(j).display_name || msg_delimiter ||
			     node_id || msg_delimiter ||
			     parent_id || msg_delimiter ||
			     hierarchy_table(j).node_type || msg_delimiter ||
			     hierarchy_table(j).status || msg_delimiter ||
			     hierarchy_table(j).display_order ||
			     msg_delimiter || msg_delimiter;
	        END LOOP; -- Loop for context table
	    END IF;
	END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
    --DBMS_OUTPUT.PUT_LINE('AZW_HIER.insert_groups_for_context: ' || SQLERRM);
       	fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
    	fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	fnd_message.set_token('AZW_ERROR_PROC','azw_hier.insert_groups_for_context');
	fnd_message.set_token('AZW_ERROR_STMT','UNKNOWN');
      	APP_EXCEPTION.RAISE_EXCEPTION;
  END insert_groups_for_context;

  /*---------------------------------------------------------------
   * get_context : private procedure
   * retrieves all distinct context_id, context_name
   * from az_processes table.
   * AZW_PROC.get_context fetches all the  context_id, context_name
   * but this one fetches only those for which some processes exists.
  *--------------------------------------------------------------*/

  PROCEDURE	get_context(	ctx_type   IN	VARCHAR2,
				ctx_table  OUT	AZW_PROC.context_tbl_t) IS

	CURSOR	ctx_cursor IS
	SELECT  DISTINCT context_id, context_name
	FROM	az_processes
	WHERE
		context_type = ctx_type
	ORDER BY context_name;
	i	BINARY_INTEGER  DEFAULT 0;
  BEGIN

	ctx_table.delete;
	FOR data IN ctx_cursor LOOP
		i := i + 1;
		ctx_table(i).context_id := data.context_id;
		ctx_table(i).context_name := data.context_name;
	END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
       	fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
    	fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	fnd_message.set_token('AZW_ERROR_PROC','azw_hier.get_context');
	fnd_message.set_token('AZW_ERROR_STMT','cursor select from az_processes ');
  END get_context;

END AZW_HIER;

/
