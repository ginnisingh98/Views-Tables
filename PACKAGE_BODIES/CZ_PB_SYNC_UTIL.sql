--------------------------------------------------------
--  DDL for Package Body CZ_PB_SYNC_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_PB_SYNC_UTIL" AS
/*	$Header: czcloutb.pls 120.4.12010000.2 2009/07/27 17:24:37 lamrute ship $	*/


-----variable declarations
TYPE ref_cursor IS REF CURSOR;

-------------------------------------------------
---function that returns the run id
FUNCTION get_run_id
RETURN NUMBER
IS

v_run_id NUMBER := 0;

BEGIN
	SELECT cz_xfr_run_infos_s.NEXTVAL
	INTO   v_run_id
	FROM DUAL;
	RETURN v_run_id;
EXCEPTION
WHEN OTHERS THEN
	RETURN v_run_id;
END;

---------------------------------------------------
--------------------procedure to log errors during the sync process
PROCEDURE log_pb_sync_errors(p_msg_tbl IN message_list,p_run_id  IN  NUMBER)
AS

v_message	VARCHAR2(2000) := NULL;

BEGIN
	IF (p_msg_tbl.COUNT > 0) THEN
		FOR I IN p_msg_tbl.FIRST..p_msg_tbl.LAST
		LOOP
    cz_utils.log_report(p_msg_tbl(i).called_proc, null, p_msg_tbl(i).sql_code,
           p_msg_tbl(i).msg_text, fnd_log.LEVEL_ERROR);
		END LOOP;
               --fix 8607367 Implementor of cz_utils.log_report need to commit
               COMMIT;
	END IF;
EXCEPTION
WHEN OTHERS THEN
	RAISE;
END log_pb_sync_errors;

---------------------------------------------------
------function that retrieves the db link name from cz_servers
FUNCTION retrieve_link_name(p_tgt_server_id cz_servers.server_local_id%TYPE)
RETURN VARCHAR2
IS

v_db_link_name cz_servers.fndnam_link_name%TYPE := NULL;

BEGIN
	IF (p_tgt_server_id IS NOT NULL) THEN
		SELECT fndnam_link_name
		INTO   v_db_link_name
		FROM   cz_servers
		WHERE  cz_servers.server_local_id = p_tgt_server_id;
		v_db_link_name := '@'||v_db_link_name;
	END IF;
	RETURN v_db_link_name;
EXCEPTION
WHEN NO_DATA_FOUND THEN
	RETURN v_db_link_name;
END retrieve_link_name;

---------------------------------------------------------
----procedure that retrieves the target server id from cz_servers
FUNCTION get_target_instance_id(p_target_instance IN VARCHAR2)
RETURN NUMBER
IS

v_tgt_server_id cz_servers.server_local_id%TYPE;

BEGIN
	v_tgt_server_id := 0;
	SELECT server_local_id
	INTO   v_tgt_server_id
	FROM   cz_servers
	WHERE  UPPER(cz_servers.local_name) = UPPER(LTRIM(RTRIM(p_target_instance)));
	RETURN v_tgt_server_id ;
EXCEPTION
WHEN NO_DATA_FOUND THEN
	RETURN v_tgt_server_id ;
WHEN OTHERS THEN
	RETURN v_tgt_server_id ;
END get_target_instance_id;

------------------------------------------------------------
-----function that checks if the database lnk is active
FUNCTION check_db_link(p_db_link_name IN cz_servers.fndnam_link_name%TYPE)
RETURN BOOLEAN
IS

gl_ref_cursor	REF_CURSOR;
l_active_count	NUMBER := 0;
v_err_message 	VARCHAR2(2000);

BEGIN
	IF ( (p_db_link_name IS NULL) OR (p_db_link_name = '@') ) THEN
		v_err_message := CZ_UTILS.GET_TEXT('CZ_PB_SYNC_LINK_NAME_IS_NULL');
		RETURN FALSE;
	ELSE
		----check if the link is up and active
		OPEN gl_ref_cursor FOR 'SELECT COUNT(*) FROM cz_db_settings'||p_db_link_name ;
		LOOP
			FETCH gl_ref_cursor INTO l_active_count;
			EXIT WHEN gl_ref_cursor%NOTFOUND;
		END LOOP;
		CLOSE gl_ref_cursor;

		IF (l_active_count = 0) THEN
			v_err_message := CZ_UTILS.GET_TEXT('CZ_PB_SYNC_LINK_NOT_ACTIVE');
			RETURN FALSE;
		END IF;
	 END IF;
	 RETURN TRUE;
EXCEPTION
WHEN OTHERS THEN
	RETURN FALSE;
END check_db_link;

-------------------------------------------------------------
------function that validates the schema versions on the source
------and the cloned instances
------
FUNCTION validate_schema(target_server_id cz_servers.server_local_id%TYPE)
RETURN BOOLEAN
IS

v_source_major_version cz_db_settings.value%TYPE;
v_source_minor_version cz_db_settings.value%TYPE;
v_target_major_version cz_db_settings.value%TYPE;
v_target_minor_version cz_db_settings.value%TYPE;
db_schema_compare_cur  ref_cursor ;
v_db_link		     cz_servers.fndnam_link_name%TYPE;
v_validate_schema_flg  BOOLEAN := TRUE;
v_count		     PLS_INTEGER := 0;

BEGIN
	v_db_link	:= retrieve_link_name(target_server_id);

	IF ( NOT cz_pb_sync_util.check_db_link(v_db_link) ) THEN
		RETURN FALSE;
	END IF;

	IF LTRIM(RTRIM(v_db_link)) = '@' THEN
		v_validate_schema_flg := FALSE;
	ELSE
		OPEN	db_schema_compare_cur FOR '	select count(*)
							from	cz_db_settings,
								cz_db_settings'||v_db_link||' tgt
							where	cz_db_settings.setting_id = tgt.setting_id
							and	cz_db_settings.value = tgt.value
							and	cz_db_settings.setting_id = ''MAJOR_VERSION''
							INTERSECT
							select count(*)
							from	cz_db_settings,
								cz_db_settings'||v_db_link||' tgt
							where	cz_db_settings.setting_id = tgt.setting_id
							and	cz_db_settings.value = tgt.value
							and	cz_db_settings.setting_id = ''MINOR_VERSION'' ';
		LOOP
			FETCH db_schema_compare_cur INTO v_count;
			EXIT WHEN db_schema_compare_cur%NOTFOUND;
		END LOOP;
		CLOSE db_schema_compare_cur;

		IF (v_count <> 1) THEN
			v_validate_schema_flg := FALSE;
		END IF;
 	END IF;
 	RETURN v_validate_schema_flg ;

EXCEPTION
WHEN OTHERS THEN
    RETURN FALSE;
END validate_schema;
-------------------------------------------------------
----procedure to register application
PROCEDURE set_dbms_info(p_module_name IN VARCHAR2)
IS

BEGIN
	dbms_application_info.set_module(p_module_name,'');
END;

PROCEDURE reset_dbms_info
IS

BEGIN
	dbms_application_info.set_module('','');
END;

------------------------------------------------------
-- Verifies if there is another sync or a publishing session running
FUNCTION check_process RETURN VARCHAR2
IS
  l_module_name v$session.module%TYPE;
BEGIN
  SELECT module INTO l_module_name
  FROM   v$session
  WHERE  module IN ('CZ_PB_SYNC', 'CZ_PB_MGR');
  RETURN l_module_name;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;
END check_process;

-----------------------------------------------------
------------------------------------------------------
----procedure used by publishing to check if the target server is
----actually a target and not a source.
----if target then a value of 0 is returned
PROCEDURE verify_tgt_server(p_link_name IN cz_servers.fndnam_link_name%TYPE,
				    x_status OUT NOCOPY VARCHAR2,
				    x_msg    OUT NOCOPY VARCHAR2)
IS

l_instance_name 		cz_servers.instance_name%TYPE;
l_hostname			cz_servers.hostname%TYPE;
l_listener_port 		cz_servers.db_listener_port%TYPE;
l_source_server_flag	cz_servers.source_server_flag%TYPE;
l_tgt_instance_name 	cz_servers.instance_name%TYPE;
gl_ref_cursor	      REF_CURSOR;
seq_ref_cursor          REF_CURSOR;
l_server_local_id		cz_servers.server_local_id%TYPE;

l_msg				VARCHAR2(2000);

BEGIN
	x_status := '0';

	SELECT instance_name,hostname,db_listener_port
	INTO   l_instance_name,l_hostname,l_listener_port
	FROM   cz_servers
	WHERE  UPPER(cz_servers.local_name) = 'LOCAL';

	OPEN gl_ref_cursor FOR 'SELECT instance_name, source_server_flag
				   	FROM   cz_servers'||p_link_name||'  t
				   	WHERE  UPPER(t.local_name) = UPPER('''||l_instance_name||''')';
	LOOP
		FETCH gl_ref_cursor INTO l_tgt_instance_name, l_source_server_flag;
		EXIT WHEN gl_ref_cursor%NOTFOUND;
	END LOOP;
	CLOSE gl_ref_cursor ;

	IF (l_tgt_instance_name IS NOT NULL) THEN
		IF (l_source_server_flag IS NULL) THEN
			x_status := '1';
			x_msg    := CZ_UTILS.GET_TEXT('CZ_PB_MGR_NOT_PRD_INSTANCE');

		ELSIF (  (l_source_server_flag IS NOT NULL)
			 AND (l_source_server_flag <> '1') ) THEN
			x_status := '1';
			x_msg    := CZ_UTILS.GET_TEXT('CZ_PB_MGR_NOT_PRD_INSTANCE');
		END IF;
	ELSE
		l_msg := 'SELECT cz_servers_s.nextval from dual'||p_link_name;
		OPEN seq_ref_cursor FOR 'SELECT cz_servers_s.nextval from dual'||p_link_name;
		LOOP
			EXIT WHEN seq_ref_cursor%NOTFOUND;
			FETCH seq_ref_cursor INTO l_server_local_id;
		END LOOP;
		CLOSE seq_ref_cursor;

		l_msg := 	'INSERT INTO cz_servers'||p_link_name||'
			 (server_local_id,local_name,hostname,db_listener_port,instance_name,import_enabled,source_server_flag)
		 SELECT '||l_server_local_id||',local_name,hostname,db_listener_port,instance_name,import_enabled,''1''
		 FROM   cz_servers where UPPER(cz_servers.local_name) = ''LOCAL'' ';

		EXECUTE IMMEDIATE
		'INSERT INTO cz_servers'||p_link_name||
		'	 (server_local_id,local_name,hostname,db_listener_port,instance_name,import_enabled,source_server_flag) ' ||
		' SELECT '||l_server_local_id||',instance_name,hostname,db_listener_port,instance_name,import_enabled,''1'' ' ||
		' FROM   cz_servers where UPPER(cz_servers.local_name) = ''LOCAL'' ';
		 COMMIT;
		x_status := '0';
	END IF;
EXCEPTION
WHEN NO_DATA_FOUND THEN
	IF (gl_ref_cursor%ISOPEN) THEN
		CLOSE gl_ref_cursor;
	END IF;
	IF (seq_ref_cursor%ISOPEN) THEN
		CLOSE seq_ref_cursor;
	END IF;
	x_msg    := CZ_UTILS.GET_TEXT('CZ_PB_SYNC_INSTANCE_IS_NULL','TGTINSTANCE','LOCAL');
	x_status := '1';
WHEN OTHERS THEN
	IF (gl_ref_cursor%ISOPEN) THEN
		CLOSE gl_ref_cursor;
	END IF;
	IF (seq_ref_cursor%ISOPEN) THEN
		CLOSE seq_ref_cursor;
	END IF;
	x_msg    := SQLERRM;
	x_status := '1';
END verify_tgt_server;
----------------------------------------------------------------
----procedure used by migration to check if the target server is
----a Development instance and models can indeed migrate
-----------------------------------------------------------------
PROCEDURE verify_mig_tgt_server(p_link_name IN cz_servers.fndnam_link_name%TYPE,
				    x_status OUT NOCOPY VARCHAR2,
				    x_msg    OUT NOCOPY VARCHAR2)
IS

l_converted_target  VARCHAR2(1);
l_msg				VARCHAR2(2000);
p_link_name_trim cz_servers.fndnam_link_name%TYPE;

BEGIN

    --the local name is being passed as null because this is a migration
    --call and it really does not matter.  The local parameter is
    --only passed to check local publication.

    p_link_name_trim := REPLACE(p_link_name, '@', '');
    l_converted_target := CZ_MODEL_MIGRATION_PVT.target_open_for ('M', p_link_name_trim, '');
    IF (l_converted_target = '1') THEN
        x_status :='0';
    ELSE
        x_status :='1';
        x_msg    := CZ_UTILS.GET_TEXT('CZ_CANNOT_MIGRATE');
    END IF;
EXCEPTION
WHEN OTHERS THEN
	x_msg    := SQLERRM;
	x_status := '0';
END verify_mig_tgt_server;

-------------------------------------------------------

END cz_pb_sync_util;

/
