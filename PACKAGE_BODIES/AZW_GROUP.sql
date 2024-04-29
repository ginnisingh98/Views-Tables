--------------------------------------------------------
--  DDL for Package Body AZW_GROUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AZW_GROUP" AS
/* $Header: AZWPGRPB.pls 115.13 1999/11/01 17:00:17 pkm ship     $: */


  TYPE message_tbl_t IS TABLE OF VARCHAR2(1024) INDEX BY BINARY_INTEGER;

    msg_delimiter VARCHAR2(1) := '^';

  TYPE dependency_rec_t IS RECORD (
    node_id           VARCHAR2(60),
    display_name      VARCHAR2(240),
    parent_node_id    VARCHAR2(60),
    node_type         VARCHAR2(1),
    status            VARCHAR2(20),
    installed_flag    VARCHAR2(1),
    group_color       VARCHAR2(15),
    display_order     NUMBER(5));

  TYPE dependency_tbl_t IS TABLE OF dependency_rec_t INDEX BY BINARY_INTEGER;

  g_current_mode az_processes.process_type%TYPE DEFAULT 'IMP';
--
-- get_installed_flag
--
-- Private function.  Called by get_group_dependency.
-- Given an application id, find the corresponding installed flag.
--

  FUNCTION contains_processes ( node_id IN VARCHAR2 ) RETURN BOOLEAN IS
     CURSOR sub_group_c IS
	SELECT group_id
	FROM	az_groups
	WHERE
		hierarchy_parent_id = node_id
	AND	process_type = g_current_mode ;

	ret_val		BOOLEAN DEFAULT TRUE;
	v_node_id	az_groups.group_id%TYPE;
	child_count	INTEGER DEFAULT 0;
  BEGIN

    BEGIN
	SELECT	count(*)
	INTO	child_count
	FROM	az_processes azp
	WHERE	azp.parent_id = node_id
	AND	azp.process_type = g_current_mode ;
    EXCEPTION
	WHEN app_exception.application_exception THEN
	    RAISE;
	WHEN OTHERS THEN
	    fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	    fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	    fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	    fnd_message.set_token('AZW_ERROR_PROC','azw_group.contains_processes');
	    fnd_message.set_token('AZW_ERROR_STMT','select count(*) into child_count from az_processes');
	    APP_EXCEPTION.RAISE_EXCEPTION;
    END;

	--dbms_output.put_line('Here: '||child_count|| ' MODE: ' ||g_current_mode || ' P:'|| node_id);
	IF child_count > 0 THEN
		ret_val := TRUE;
	ELSE
	    ret_val := FALSE;   -- this takes care of 'if cursor not found '
		BEGIN
			OPEN sub_group_c ;
			FETCH sub_group_c INTO v_node_id ;
			WHILE sub_group_c%FOUND LOOP
				ret_val := contains_processes( v_node_id );
				IF ret_val THEN
					GOTO endloop;
				END IF;
				FETCH sub_group_c INTO v_node_id ;
			END LOOP;
			<<endloop>>
			CLOSE sub_group_c;
	    	EXCEPTION
		    WHEN app_exception.application_exception THEN
		    	RAISE;
		    WHEN OTHERS THEN
		    	fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
			fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
			fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
			fnd_message.set_token('AZW_ERROR_PROC','azw_group.contains_processes');
			fnd_message.set_token('AZW_ERROR_STMT','CURSOR  sub_group_c');
			APP_EXCEPTION.RAISE_EXCEPTION;
	    	END;
	END IF;

	RETURN	ret_val;

      EXCEPTION
	  WHEN app_exception.application_exception THEN
		RAISE;
     	  WHEN OTHERS THEN
	 	fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
		fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
		fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
		fnd_message.set_token('AZW_ERROR_PROC','azw_group.contains_processes');
		fnd_message.set_token('AZW_ERROR_STMT','CURSOR  sub_group_c');
		APP_EXCEPTION.RAISE_EXCEPTION;
  END contains_processes;

  FUNCTION get_installed_flag(appl_id NUMBER) RETURN VARCHAR2 IS
    v_installed_flag VARCHAR2(1) DEFAULT 'A';
    v_count_installed NUMBER(5) DEFAULT 0;
    v_appl_id   NUMBER;
    BEGIN

--    dbms_output.put_line('*** get installed flag');
--    dbms_output.put_line('appl_id = ' || appl_id);

--    code put to handle CST as CST has no product installation
--    should be taken out for R12

      IF (appl_id = 707) THEN
         v_appl_id := 702;
      ELSE
         v_appl_id := appl_id;
      END IF;

---  end of hard coding for CST

      SELECT   count(*)
      INTO     v_count_installed
      FROM     fnd_product_installations fpi, fnd_application_vl fav
      WHERE    fpi.application_id = fav.application_id
      AND      fav.application_id = v_appl_id
      AND      fpi.status = 'I';
      IF (v_count_installed = 0) THEN
          v_installed_flag := 'N';
      ELSE
          v_installed_flag := 'I';
      END IF;

      RETURN v_installed_flag;

    EXCEPTION
      WHEN app_exception.application_exception THEN
	RAISE;
      WHEN NO_DATA_FOUND THEN
        v_installed_flag := 'A';
        RETURN v_installed_flag;
      WHEN OTHERS THEN
--        DBMS_OUTPUT.PUT_LINE('error: get_installed_flag: ' || SQLERRM);
	    fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	    fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	    fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	    fnd_message.set_token('AZW_ERROR_PROC','azw_group.get_installed_flag');
	    fnd_message.set_token('AZW_ERROR_STMT','select status from fnd_product_installations,fnd_application_vl');
	    APP_EXCEPTION.RAISE_EXCEPTION;
    END get_installed_flag;


--
--  get_installed_flag_group
--
--  Private function.  Called by get_group_dependency.
--  Given a group id, find the corresponding installed flag.
--

  FUNCTION get_installed_flag_group(p_group_id VARCHAR2) RETURN VARCHAR2 IS

    v_installed_flag  VARCHAR2(1) DEFAULT 'I';
    v_count_installed NUMBER(5) DEFAULT 0;
    BEGIN

      SELECT   count(*)
      INTO     v_count_installed
      FROM     az_groups azg, fnd_product_installations fpi
      WHERE    fpi.application_id       = azg.application_id
      AND      fpi.status               = 'I'
      AND      azg.dependency_parent_id = p_group_id
      AND      process_type = g_current_mode;

      IF (v_count_installed = 0) THEN
          v_installed_flag := 'N';
      ELSE
          v_installed_flag := 'I';
      END IF;

      RETURN v_installed_flag;

    EXCEPTION
      WHEN app_exception.application_exception THEN
	RAISE;
      WHEN NO_DATA_FOUND THEN
        v_installed_flag := 'A';
        RETURN v_installed_flag;
      WHEN OTHERS THEN
      --DBMS_OUTPUT.PUT_LINE('error: get_installed_flag: ' || SQLERRM);
	    fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	    fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	    fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	    fnd_message.set_token('AZW_ERROR_PROC','azw_group.get_process');
	    fnd_message.set_token('AZW_ERROR_STMT','CURSOR  process_hierarchy_pn');
	    APP_EXCEPTION.RAISE_EXCEPTION;
    END get_installed_flag_group;


--
-- get_group_dependency
--
-- Private procedure.  Called by get_dependency.
--

  PROCEDURE get_group_dependency (gd OUT dependency_tbl_t) IS

    v_node_id           az_groups.group_id%TYPE;
    v_parent_node_id    az_groups.dependency_parent_id%TYPE;
    v_display_order     az_groups.display_order%TYPE;
    v_application_id    az_groups.application_id%TYPE;
    v_lookup_code       az_groups.lookup_code%TYPE;
    v_color_code        az_groups.color_code%TYPE;
    v_complete_flag     az_groups.complete_flag%TYPE;
    i                   BINARY_INTEGER DEFAULT 0;


    CURSOR dependency_cursor IS
      SELECT  group_id, dependency_parent_id, display_order,
              application_id, lookup_code, color_code, complete_flag
      FROM    az_groups
      WHERE   hierarchy_parent_id is null
      AND      process_type = g_current_mode
      ORDER BY 1;

  BEGIN

    OPEN dependency_cursor;
    FETCH dependency_cursor INTO v_node_id, v_parent_node_id, v_display_order,
                                 v_application_id, v_lookup_code, v_color_code,
                                 v_complete_flag;

    WHILE dependency_cursor%FOUND LOOP

      i := i + 1;

      IF (v_application_id is not null) THEN
        gd(i).display_name := AZW_PROC.get_application_name(v_application_id);
        gd(i).installed_flag := get_installed_flag(v_application_id);
      ELSE
         gd(i).display_name := AZW_PROC.get_lookup_meaning(v_lookup_code);

         IF (v_parent_node_id is not null) THEN
            gd(i).installed_flag := get_installed_flag_group(v_node_id);
         ELSE
            gd(i).installed_flag := 'I';
         END IF;
      END IF;

-- Start : Swarup added
	IF contains_processes( v_node_id ) THEN
		NULL;
	ELSE
		gd(i).installed_flag := 'U';
	END IF ;
-- End : Swarup added

      gd(i).node_id := v_node_id;
      IF v_node_id = '1010' THEN
        gd(i).parent_node_id := 'root';
      ELSE
        gd(i).parent_node_id := v_parent_node_id;
      END IF;
      gd(i).node_type := 'G';

      IF v_complete_flag = 'Y' THEN
        gd(i).status := 'COMPLETED';
      ELSE
        gd(i).status := 'INCOMPLETE';
      END IF;

      gd(i).group_color := v_color_code;
      IF((gd(i).installed_flag <> 'I') AND (v_application_id is not null)) THEN
        gd(i).display_order := v_display_order + 10000;
      ELSE
        gd(i).display_order := v_display_order;
      END IF;

      FETCH dependency_cursor INTO v_node_id, v_parent_node_id, v_display_order,
                                   v_application_id, v_lookup_code,v_color_code,
                                   v_complete_flag;
    END LOOP;
    CLOSE dependency_cursor;

  EXCEPTION
    WHEN app_exception.application_exception THEN
	RAISE;
    WHEN OTHERS THEN
      -- DBMS_OUTPUT.PUT_LINE('error: get_group_dependency: ' || SQLERRM);
	    fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	    fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	    fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	    fnd_message.set_token('AZW_ERROR_PROC','azw_group.get_group_dependency');
	    fnd_message.set_token('AZW_ERROR_STMT','CURSOR  dependency_cursor');
	    APP_EXCEPTION.RAISE_EXCEPTION;
  END get_group_dependency;


--
-- GET_DEPENDENCY
--
-- Public procedure.  Called by Process Groups window.
-- The message format which has been agreed upon between front end
-- and back end is as follows:
--
-- display_name^node_id^parent_node_id^node_type^installed_flag^
-- status^display_order^^
--

  PROCEDURE get_dependency  IS

    gd    dependency_tbl_t;
    mesg  az_webform_messages.mesg%TYPE;

  BEGIN

--  dbms_output.put_line('get dependency');

    g_current_mode := fnd_profile.value('AZ_CURRENT_MODE');

    get_group_dependency(gd);

    FOR j IN 1..gd.COUNT LOOP

      IF gd(j).display_name <> 'NONE' THEN

	BEGIN
        	mesg := gd(j).display_name || msg_delimiter ||
                	gd(j).node_id || msg_delimiter ||
                	gd(j).parent_node_id || msg_delimiter ||
                	gd(j).node_type || msg_delimiter ||
                	gd(j).installed_flag || msg_delimiter ||
                	gd(j).status || msg_delimiter ||
                	gd(j).display_order || msg_delimiter ||
                	gd(j).group_color || msg_delimiter || msg_delimiter;

		INSERT INTO az_webform_messages (mesg)
		  VALUES (mesg);
        EXCEPTION
	    WHEN app_exception.application_exception THEN
		RAISE;
	    WHEN OTHERS THEN
	    	fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	    	fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	    	fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	    	fnd_message.set_token('AZW_ERROR_PROC','azw_group.get_dependency');
	    	fnd_message.set_token('AZW_ERROR_STMT','insert into az_webform_messages');
	    	APP_EXCEPTION.RAISE_EXCEPTION;
   	END;

      END IF;
    END LOOP;

  EXCEPTION
    WHEN app_exception.application_exception THEN
	APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN OTHERS THEN
	--DBMS_OUTPUT.PUT_LINE('error: get_dependency: ' || SQLERRM);
        fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	fnd_message.set_token('AZW_ERROR_PROC','azw_hier.get_dependency');
	fnd_message.set_token('AZW_ERROR_STMT','UNKNOWN');
	APP_EXCEPTION.RAISE_EXCEPTION;
  END get_dependency;

END AZW_GROUP;

/
