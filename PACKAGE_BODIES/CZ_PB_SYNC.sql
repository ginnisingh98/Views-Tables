--------------------------------------------------------
--  DDL for Package Body CZ_PB_SYNC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_PB_SYNC" AS
/*  $Header: czpbsynb.pls 120.4.12010000.3 2008/10/29 19:50:29 lamrute ship $  */

--------package variable declaration
TYPE  t_ref IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE  t_name IS TABLE OF VARCHAR2(255) INDEX BY BINARY_INTEGER;

m_msg_tbl      cz_pb_sync_util.message_list;
m_err_message  VARCHAR2(2000);

SRC_SERVER_FLAG   cz_servers.source_server_flag%TYPE := '1';

OBJECT_TYPE_PROJECT  CONSTANT  cz_model_publications.object_type%TYPE := 'PRJ';
OBJECT_TYPE_UITEMPL  CONSTANT  cz_model_publications.object_type%TYPE := 'UIT';
GLOBAL_UI_DEF_PUB    CONSTANT  NUMBER := 1;
GLOBAL_UI_DEF_SRC    CONSTANT  NUMBER := 0;

---------------------------------------
----procedure that logs err messages to m_msg_tbl

PROCEDURE error_msg_populate(p_msg 		VARCHAR2,
				     p_caller	VARCHAR2,
				     p_code 	NUMBER
				    )
AS
record_count	PLS_INTEGER := 0;
BEGIN
	record_count := m_msg_tbl.COUNT + 1;
	m_msg_tbl(record_count).msg_text := LTRIM(RTRIM(substr(p_msg,1,2000)));
	m_msg_tbl(record_count).called_proc := p_caller;
	m_msg_tbl(record_count).SQL_CODE := p_code;
EXCEPTION
WHEN OTHERS THEN
	RAISE;
END error_msg_populate;

------------------------------------------------------
-----verifies source server entry on the target instance
FUNCTION verify_src_server_entry( p_link_name     cz_servers.fndnam_link_name%TYPE
					   ,p_source_server cz_servers.local_name%TYPE)
RETURN BOOLEAN
IS

gl_ref_cursor	    REF_CURSOR;
l_source_server_flag  cz_servers.source_server_flag%TYPE;

BEGIN
	OPEN gl_ref_cursor FOR 'SELECT source_server_flag
				   	FROM   cz_servers'||p_link_name||'  t
				   	WHERE  UPPER(t.local_name) = UPPER(:1)' USING p_source_server;
	LOOP
		FETCH gl_ref_cursor INTO l_source_server_flag;
		EXIT WHEN gl_ref_cursor%NOTFOUND;
	END LOOP;
	CLOSE gl_ref_cursor ;

	IF ( (l_source_server_flag IS NULL)
		OR (l_source_server_flag <> SRC_SERVER_FLAG) ) THEN
		RETURN FALSE;
	ELSE
		RETURN TRUE;
	END IF;
EXCEPTION
WHEN OTHERS THEN
	CLOSE gl_ref_cursor;
	RETURN FALSE;
END verify_src_server_entry;

---------------------------------------------------------
-----procedure that verifies that the clone proc is executed on the source db
FUNCTION verify_source_instance(p_target_instance IN VARCHAR2)
RETURN BOOLEAN
IS

v_flag  		 BOOLEAN := TRUE;
x_src_verification NUMBER  := 0;
gl_ref_cursor	 REF_CURSOR;

l_hostname		 cz_servers.hostname%TYPE;
l_instance_name    cz_servers.instance_name%TYPE;
l_src_server_flg   cz_servers.source_server_flag%TYPE;
l_src_count		 NUMBER;

v_target_server_id	NUMBER := 0;
v_link_name 		cz_servers.fndnam_link_name%TYPE;

CURSOR src_server_info IS SELECT hostname, instance_name, source_server_flag
				  FROM   cz_servers
				  WHERE  UPPER(local_name) = 'LOCAL';

BEGIN
      --------compare instance information
	OPEN src_server_info;
	LOOP
		FETCH src_server_info INTO l_hostname,l_instance_name,l_src_server_flg;
		EXIT WHEN src_server_info%NOTFOUND;
	END LOOP;
	CLOSE src_server_info;

	SELECT COUNT(*)
      INTO   l_src_count
      FROM   cz_servers
	WHERE  cz_servers.source_server_flag = SRC_SERVER_FLAG;

	IF (l_src_count <> 0) THEN
		m_err_message := CZ_UTILS.GET_TEXT('CZ_PB_SYNC_NOT_SRC_INSTANCE', 'INSTANCE', l_instance_name);
		error_msg_populate(m_err_message ,'CZ_PB_SYNC.VERIFYSRCINST',21061);
		RETURN FALSE;
	END IF;

	SELECT COUNT(*)
	INTO   x_src_verification
	FROM   v$instance
	WHERE  UPPER(host_name) = UPPER(l_hostname)
	AND    UPPER(instance_name) = UPPER(l_instance_name);

	IF (x_src_verification = 0) THEN
		m_err_message := CZ_UTILS.GET_TEXT('CZ_PB_SYNC_NOT_SRC_INSTANCE','SRCINSTANCE',l_instance_name);
		error_msg_populate(m_err_message ,'CZ_PB_SYNC.VERIFYSRCINST',21061);
		RETURN FALSE;
	END IF;

	v_target_server_id := cz_pb_sync_util.get_target_instance_id(p_target_instance);
	v_link_name := cz_pb_sync_util.retrieve_link_name(v_target_server_id);
	IF (NOT verify_src_server_entry(v_link_name,l_instance_name) ) THEN
		m_err_message := CZ_UTILS.GET_TEXT('CZ_PB_SYNC_NOT_TGT_INSTANCE',
								 'TGTINSTANCE', p_target_instance,
								 'SRCINSTANCE', l_instance_name);
		error_msg_populate(m_err_message ,'CZ_PB_SYNC.VERIFYSRCENTRY',21061);
		RETURN FALSE;
	END IF;

	RETURN v_flag;
EXCEPTION
WHEN OTHERS THEN
	RETURN FALSE;
END verify_source_instance;

-------------------------------------------------------------
-----function that checks if the target instance is a clone
FUNCTION check_target_instance(p_link_name IN cz_servers.fndnam_link_name%TYPE)
RETURN BOOLEAN
IS

gl_ref_cursor	REF_CURSOR;
l_instance_name	cz_servers.instance_name%TYPE;
l_host_name		cz_servers.hostname%TYPE;
v_instance_name	cz_servers.instance_name%TYPE;
v_host_name		cz_servers.hostname%TYPE;
v_notes		VARCHAR2(2000);
v_return_flg	BOOLEAN := FALSE;

BEGIN
	OPEN gl_ref_cursor FOR 'SELECT instance_name,host_name
					FROM   v$instance'||p_link_name;
	LOOP
		FETCH gl_ref_cursor INTO l_instance_name,l_host_name;
		EXIT WHEN gl_ref_cursor%NOTFOUND;
	END LOOP;
	CLOSE gl_ref_cursor;

	OPEN gl_ref_cursor FOR 'SELECT instance_name,hostname,notes
					FROM   cz_servers'||p_link_name||'  t
					WHERE  UPPER(local_name) = ''LOCAL'' ';
	LOOP
		FETCH gl_ref_cursor INTO v_instance_name,v_host_name,v_notes;
		EXIT WHEN gl_ref_cursor%NOTFOUND;
	END LOOP;
	CLOSE gl_ref_cursor;

	IF ( (UPPER(l_instance_name) <> UPPER(v_instance_name))
		OR (UPPER(l_host_name) <> UPPER(v_host_name)) ) THEN
		v_return_flg := FALSE;
	ELSE
		IF (v_notes IS NULL) THEN
			m_err_message := CZ_UTILS.GET_TEXT('CZ_PB_SYNC_NOT_A_CLONE', 'INSTANCENAME',v_instance_name);
			error_msg_populate(m_err_message ,'CZ_PB_SYNC.GETLINKNAME',21011);
			v_return_flg := TRUE;
		ELSE
			m_err_message := CZ_UTILS.GET_TEXT('CZ_PB_SYNC_ALREADY_SYNCED','INSTANCENAME',v_instance_name, 'SYNCDATE',v_notes);
			error_msg_populate(m_err_message ,'CZ_PB_SYNC.GETLINKNAME',21011);
			v_return_flg := TRUE;
		END IF;
	END IF;
	RETURN v_return_flg;
EXCEPTION
WHEN OTHERS THEN
	CLOSE gl_ref_cursor;
	RETURN TRUE;
END check_target_instance;

-------------------------------------------------
-----function that returns the server id of the cloned instance
FUNCTION get_tgt_server_id(p_link_name cz_servers.fndnam_link_name%TYPE)
RETURN NUMBER
IS

gl_ref_cursor	REF_CURSOR;
v_tgt_server_id	cz_servers.server_local_id%TYPE := 0;

BEGIN
	OPEN gl_ref_cursor FOR 'SELECT distinct server_id
				   FROM   cz_model_publications'||p_link_name||'  t
				   WHERE  t.source_target_flag = ''T''
				   AND    t.deleted_flag = ''0'' ';
	LOOP
		FETCH gl_ref_cursor INTO v_tgt_server_id;
		EXIT WHEN gl_ref_cursor%NOTFOUND;
	END LOOP;
	CLOSE gl_ref_cursor ;
	RETURN v_tgt_server_id;
EXCEPTION
WHEN OTHERS THEN
	CLOSE gl_ref_cursor;
	RETURN v_tgt_server_id;
END get_tgt_server_id;

---------------------------------------------------
------function that verifies that the source and target server ids match
FUNCTION verify_src_tgt_instances(p_link_name IN cz_servers.fndnam_link_name%TYPE)
RETURN BOOLEAN
IS

v_tgt_pb_server_id  	cz_servers.server_local_id%TYPE;
v_validate_flag		BOOLEAN := TRUE;
v_src_server_count  	NUMBER := 0;

NO_TGT_ID			EXCEPTION;

BEGIN
	v_src_server_count  := 0;
	v_tgt_pb_server_id  := get_tgt_server_id(p_link_name);
	IF (v_tgt_pb_server_id  = 0) THEN
		RAISE NO_TGT_ID;
	END IF;

	----compare source and target publications
	----check not required
	IF (v_tgt_pb_server_id <> 0) THEN
		SELECT 1
		INTO   v_src_server_count
		FROM   cz_model_publications
		WHERE  cz_model_publications.server_id = v_tgt_pb_server_id
		AND    cz_model_publications.deleted_flag = '0'
		AND	 ROWNUM < 2;
	END IF;

	IF (v_src_server_count <> 1) THEN
		v_validate_flag := FALSE;
	END IF;

 	RETURN v_validate_flag ;
EXCEPTION
WHEN NO_TGT_ID THEN
	v_validate_flag := FALSE;
	RETURN v_validate_flag ;
WHEN OTHERS THEN
	v_validate_flag := FALSE;
	RETURN v_validate_flag ;
END verify_src_tgt_instances;

-------------------------------------------------------
------function that verifies if model ids on source and target instances are the same
FUNCTION verify_src_tgt_models(p_link_name IN cz_servers.fndnam_link_name%TYPE)
RETURN BOOLEAN
IS

gl_ref_cursor	     REF_CURSOR;
v_validate_model_count NUMBER := 0;
v_validate_flag        BOOLEAN := TRUE;

BEGIN
	----compare model persistent ids on of source and target models
	OPEN gl_ref_cursor FOR 'SELECT COUNT(*) FROM cz_model_publications'||p_link_name||'  t
					WHERE t.deleted_flag = ''0''
					AND   t.model_persistent_id IN (SELECT model_persistent_id
										  FROM   cz_model_publications x
										  WHERE  x.deleted_flag = ''0''
										  AND    x.source_target_flag = ''S'')';
	LOOP
		FETCH gl_ref_cursor INTO v_validate_model_count;
		EXIT WHEN gl_ref_cursor%NOTFOUND;
	END LOOP;
	CLOSE gl_ref_cursor;

	IF (v_validate_model_count = 0) THEN
		v_validate_flag := FALSE;
	END IF;
	RETURN v_validate_flag;
EXCEPTION
WHEN OTHERS THEN
	CLOSE gl_ref_cursor;
	v_validate_flag := FALSE;
	RETURN v_validate_flag;
END verify_src_tgt_models;

---------------------------------------------------
---------function that validates publication ids on the tgt instance
FUNCTION verify_src_tgt_pb_ids(p_link_name IN cz_servers.fndnam_link_name%TYPE)
RETURN BOOLEAN
IS

gl_ref_cursor	REF_CURSOR;
v_validate_flg    BOOLEAN := TRUE;
v_rem_pb_count    NUMBER  := 0;

BEGIN

	 ----verify that the remote publication ids on the source exist on the target
	OPEN gl_ref_cursor FOR 'SELECT COUNT(*) FROM cz_model_publications'||p_link_name||'  t
					WHERE t.deleted_flag  = ''0''
					AND   t.export_status = ''OK''
					AND   t.source_target_flag = ''T''
					AND   t.publication_id IN (SELECT remote_publication_id
									   FROM   cz_model_publications x
									   WHERE  x.export_status = ''OK''
									    AND   x.deleted_flag = ''0'')';
	LOOP
		FETCH gl_ref_cursor INTO v_rem_pb_count;
		EXIT WHEN gl_ref_cursor%NOTFOUND;
	END LOOP;
	CLOSE gl_ref_cursor;

	IF (v_rem_pb_count = 0) THEN
		v_validate_flg := FALSE;
	END IF;
	RETURN v_validate_flg;
EXCEPTION
WHEN OTHERS THEN
	CLOSE gl_ref_cursor;
	v_validate_flg := FALSE;
	RETURN v_validate_flg;
END verify_src_tgt_pb_ids;

----------------------------------------------------
-----procedure that checks if the target instance has to be synchronized
-----x_sync_flag : TRUE if it has to be synced
FUNCTION has_to_be_synced(p_tgt_server_id IN cz_servers.server_local_id%TYPE)
RETURN BOOLEAN
IS

v_link_name 	cz_servers.fndnam_link_name%TYPE;
v_sync_flag 	BOOLEAN := TRUE;

BEGIN
	FOR I IN 1..1
	LOOP
		------get db link name for tgt instance
		v_link_name := cz_pb_sync_util.retrieve_link_name(p_tgt_server_id);
		IF ( NOT cz_pb_sync_util.check_db_link(v_link_name) ) THEN
			v_sync_flag := FALSE;
			EXIT;
		END IF;

		------verify that server ids on the source and target are the same
		v_sync_flag  := verify_src_tgt_instances(v_link_name);
		IF (NOT v_sync_flag) THEN
			m_err_message := CZ_UTILS.GET_TEXT('CZ_PB_SYNC_NO_TGT_ID_FOUND', 'INSTANCENAME',v_link_name);
			error_msg_populate(m_err_message ,'CZ_PB_SYNC.NOTGTIDFOUND',21011);
			EXIT;
		END IF;

		----verify persistent model ids on source and target instances
		v_sync_flag  := verify_src_tgt_models(v_link_name);
		IF (NOT v_sync_flag) THEN
			m_err_message := CZ_UTILS.GET_TEXT('CZ_PB_SYNC_MODELS_ERR');
			error_msg_populate(m_err_message ,'CZ_PB_SYNC.SRCTGTMODELS',21009);
			v_sync_flag := FALSE;
			EXIT;
		END IF;

		----verify remote publication ids
		v_sync_flag  := verify_src_tgt_pb_ids(v_link_name);
		IF (NOT v_sync_flag) THEN
			m_err_message := CZ_UTILS.GET_TEXT('CZ_PB_SYNC_REM_PB_ID_ERR', 'TGTINSTANCE',v_link_name );
			error_msg_populate(m_err_message ,'CZ_PB_SYNC.VERIFYSRCTGTPBIDS',21010);
			v_sync_flag := FALSE;
			EXIT;
		END IF;
	END LOOP;
	RETURN v_sync_flag;
EXCEPTION
WHEN OTHERS THEN
	v_sync_flag := FALSE;
	RETURN v_sync_flag;
END has_to_be_synced;

----------------------------------------------------
---procedure that deletes the publication (on the source instance) record pointing to the cloned database
PROCEDURE clear_source_pb_record(p_publication_id IN cz_model_publications.publication_id%TYPE)
IS

BEGIN
	UPDATE cz_model_publications
	SET deleted_flag = '1'
      WHERE publication_id = p_publication_id;

	/* DELETE FROM cz_model_publications
	WHERE publication_id = p_publication_id; */
EXCEPTION
WHEN OTHERS THEN
	m_err_message := CZ_UTILS.GET_TEXT('CZ_PB_SYNC_DEL_PB_REC_ERR', 'PUBID', p_publication_id, 'SQLERRM', SQLERRM);
	error_msg_populate(m_err_message ,'CZ_PB_SYNC.CLRSRCPBRECORD',SQLCODE);
	RAISE;
END clear_source_pb_record;

----------------------------------------------------
---procedure that deletes data from cz_pb_client_apps for a given publication
PROCEDURE clear_pb_clients(p_publication_id IN cz_model_publications.publication_id%TYPE)
IS

BEGIN
	DELETE FROM cz_pb_client_apps
	WHERE publication_id = p_publication_id;
EXCEPTION
WHEN OTHERS THEN
	m_err_message := CZ_UTILS.GET_TEXT('CZ_PB_SYNC_DEL_PB_CLIENT_ERR', 'PUBID',p_publication_id, 'SQLERRM', SQLERRM);
	error_msg_populate(m_err_message ,'CZ_PB_SYNC.CLRPBCLIENTS',SQLCODE);
	RAISE;
END clear_pb_clients;

-----------------------------------------------------
---procedure that deletes data from cz_pb_languages for a given publication
PROCEDURE clear_pb_lang(p_publication_id IN cz_model_publications.publication_id%TYPE)
IS

BEGIN
	DELETE FROM cz_pb_languages
	WHERE publication_id = p_publication_id;
EXCEPTION
WHEN OTHERS THEN
	m_err_message := CZ_UTILS.GET_TEXT('CZ_PB_SYNC_DEL_LANG_ERR','PUBID',p_publication_id, 'SQLERRM', SQLERRM);
	error_msg_populate(m_err_message ,'CZ_PB_SYNC.CLRPBCLIENTS',SQLCODE);
	RAISE;
END clear_pb_lang;

-----------------------------------------------------
---procedure that deletes data from cz_pb_client_apps for a given publication
PROCEDURE clear_pb_usages(p_publication_id IN cz_model_publications.publication_id%TYPE)
IS

BEGIN
	DELETE FROM cz_publication_usages
	WHERE publication_id = p_publication_id;
EXCEPTION
WHEN OTHERS THEN
	m_err_message := CZ_UTILS.GET_TEXT('CZ_PB_SYNC_DEL_PB_USAGE_ERR','PUBID',p_publication_id, 'SQLERRM', SQLERRM);
	error_msg_populate(m_err_message ,'CZ_PB_SYNC.CLRPBUSAGES',SQLCODE);
	RAISE;
END clear_pb_usages;

--------------------------------------------------------
----procedure that truncates publication history
PROCEDURE clear_pb_exports
IS

BEGIN
	delete from cz_pb_model_exports;
EXCEPTION
WHEN OTHERS THEN
	m_err_message := CZ_UTILS.GET_TEXT('CZ_PB_SYNC_DEL_PB_EXPORTS_ERR', 'SQLERRM', SQLERRM);
	error_msg_populate(m_err_message ,'CZ_PB_SYNC.CLRPBEXPORTS',SQLCODE);
	RAISE;
END clear_pb_exports;

---------------------------------------------------------
-----procedure that updates the server_id of the target publication record
PROCEDURE update_tgt_server_id(p_target_server_id IN cz_servers.server_local_id%TYPE,
				       p_link_name In cz_servers.fndnam_link_name%TYPE)
IS

BEGIN
	EXECUTE IMMEDIATE
	'UPDATE cz_model_publications'||p_link_name||'  t SET t.server_id = '||p_target_server_id||' WHERE t.deleted_flag = ''0'' ';
EXCEPTION
WHEN OTHERS THEN
	RAISE;
END update_tgt_server_id;

------------------------------------------------------
--jhanda
-- procedure that returns the product_id and organisation_id in the target corresponding
-- to the product_id and organisation_id in the source for a given source publication
PROCEDURE get_local_ids(p_publication_id IN cz_model_publications.publication_id%TYPE,
			p_sync_tgt_link_name IN cz_servers.fndnam_link_name%TYPE,
			p_import_link_name IN cz_servers.fndnam_link_name%TYPE,
			p_item_id IN OUT NOCOPY cz_item_masters.item_id%TYPE,
			p_org_id IN OUT NOCOPY cz_model_publications.organization_id%TYPE,
			p_product_key IN OUT NOCOPY cz_model_publications.product_key%TYPE
			)
IS
l_concatenated_segments MTL_SYSTEM_ITEMS_VL.concatenated_segments%TYPE;
l_remote_item_cursor ref_cursor;
c_local_item_id ref_cursor;
l_org_id cz_model_publications.organization_id%TYPE;

BEGIN


  IF  p_product_key IS NULL THEN
     p_item_id:=NULL;
     p_org_id:=NULL;
     RETURN;
  ELSIF instr(p_product_key,   ':')=0 THEN -- product key not in BOM Format then exit
     p_item_id:=NULL;
     p_org_id:=NULL;
     RETURN;
  END IF;

  l_org_id:=p_org_id;

  BEGIN
	-- Product key is propogated for Non BOM parent
	  IF p_org_id IS NULL
	   AND p_product_key IS NOT NULL THEN
	    p_org_id := SUBSTR(p_product_key,   1,   instr(p_product_key,   ':') -1);
	  END IF;

	-- Extract item id

	  IF p_item_id IS NULL
	   AND p_product_key IS NOT NULL THEN
		  p_item_id:=SUBSTR(p_product_key,  instr(p_product_key,   ':') +1);
	  END IF;

	  EXCEPTION WHEN OTHERS THEN
	--   This will happen if product key has non numeric components
	     p_item_id:=NULL;
	     p_org_id:=NULL;
	     RETURN;
  END;


-- Transform Organization ID
  BEGIN
  EXECUTE IMMEDIATE 'SELECT organization_id FROM org_organization_definitions'||p_import_link_name||
                      ' WHERE UPPER(organization_name) = ' ||
                      '  (SELECT UPPER(organization_name) FROM org_organization_definitions' || p_sync_tgt_link_name ||
                      '    WHERE organization_id = :1)'
  INTO p_org_id USING l_org_id;

  EXCEPTION WHEN NO_DATA_FOUND THEN
	m_err_message := 'Unable to find organization definition in import source';
	error_msg_populate(m_err_message ,'CZ_PB_SYNC.GETLOCALIDS',SQLCODE);
	RAISE;
  END;

-- Transform Item ID


  OPEN l_remote_item_cursor FOR ' SELECT  concatenated_segments  FROM  MTL_SYSTEM_ITEMS_VL'
                         || p_sync_tgt_link_name || '  t ' || ' WHERE t.inventory_item_id = ' || p_item_id
			 || ' AND organization_id = '||l_org_id;
  LOOP
    FETCH l_remote_item_cursor
    INTO l_concatenated_segments;
    EXIT
  WHEN l_remote_item_cursor%NOTFOUND;
  END LOOP;

  CLOSE l_remote_item_cursor;


  -- here if p_import_link_name is NULL then we are effectively querying the local BOM data

  BEGIN
  OPEN c_local_item_id FOR ' SELECT inventory_item_id FROM MTL_SYSTEM_ITEMS_VL'
			   || p_import_link_name||' WHERE concatenated_segments = '''||l_concatenated_segments||''' AND organization_id = '||p_org_id;
  FETCH c_local_item_id
  INTO p_item_id;
  CLOSE c_local_item_id;

  EXCEPTION WHEN NO_DATA_FOUND THEN
	m_err_message := 'Unable to find item definition in import source .';
	error_msg_populate(m_err_message ,'CZ_PB_SYNC.GETLOCALIDS',SQLCODE);
	IF c_local_item_id%ISOPEN THEN
	  CLOSE c_local_item_id;
        END IF;
	RAISE;
  END;

  IF p_org_id IS NOT NULL AND p_item_id IS NOT NULL THEN
    p_product_key:=p_org_id||':'||p_item_id;
  END IF;


EXCEPTION WHEN OTHERS THEN
  IF (c_local_item_id%ISOPEN)
  THEN
     CLOSE c_local_item_id;
  END IF;

  IF (l_remote_item_cursor%ISOPEN)
  THEN
     CLOSE l_remote_item_cursor;
  END IF;
  RAISE;
END get_local_ids;


------------------------------------------------------
------procedure that creates a single publication record on the source for a
------target publication.  This proc is called from create_src_pb_records.
PROCEDURE create_src_publication(p_publication_id  IN cz_model_publications.publication_id%TYPE,
                                 p_link_name       IN cz_servers.fndnam_link_name%TYPE,
                                 p_tgt_server_id   IN cz_servers.server_local_id%TYPE,
                                 p_src_object_id   IN cz_model_publications.object_id%TYPE,
                                 -- p_src_object_type IN cz_model_publications.object_type%TYPE,
                                 p_src_ui_def_id   IN cz_model_publications.ui_def_id%TYPE)
IS
l_new_pb_id cz_model_publications.publication_id%TYPE;
l_ui_def_id     VARCHAR2(100);
pub_cursor ref_cursor;
l_pub_cursor cz_model_publications%rowtype;
v_item_id cz_item_masters.item_id%TYPE;
v_org_id cz_model_publications.organization_id%TYPE;
v_product_key cz_model_publications.product_key%TYPE;

linkName      cz_servers.fndnam_link_name%TYPE;

BEGIN
  ----get new publication id
  SELECT cz_model_publications_s.nextval
  INTO   l_new_pb_id
  FROM   dual;

  IF (p_src_ui_def_id IS NULL) THEN
    l_ui_def_id := 'NULL';
  ELSE
    l_ui_def_id := to_char(p_src_ui_def_id);
  END IF;

  -- Get Import Server link name
  SELECT fndnam_link_name INTO linkName
           FROM cz_servers
  WHERE import_enabled='1';


  IF(linkName IS NOT NULL)THEN
       linkName := '@' || linkName;
  END IF;

  -- model_id, source_model_id, source_ui_def_id are null
   OPEN pub_cursor for
      '  SELECT *'||
      ' FROM  cz_model_publications'||p_link_name||'  t ' ||
      ' WHERE t.publication_id = '||p_publication_id ;

     LOOP
      FETCH pub_cursor
      INTO  l_pub_cursor;
       EXIT WHEN pub_cursor % NOTFOUND;
       v_item_id:=l_pub_cursor.top_item_id;
       v_org_id:=l_pub_cursor.organization_id;
       v_product_key:=l_pub_cursor.product_key;
      IF p_link_name <> linkName THEN
	      get_local_ids(l_pub_cursor.PUBLICATION_ID,p_link_name,linkName ,v_item_id,v_org_id,v_product_key);
      END IF;

      INSERT INTO cz_model_publications(
       PUBLICATION_ID
      ,OBJECT_ID
      ,OBJECT_TYPE
      ,SERVER_ID
      ,ORGANIZATION_ID
      ,TOP_ITEM_ID
      ,PRODUCT_KEY
      ,PUBLICATION_MODE
      ,UI_DEF_ID
      ,UI_STYLE
      ,APPLICABLE_FROM
      ,APPLICABLE_UNTIL
      ,EXPORT_STATUS
      ,DELETED_FLAG
      ,MODEL_LAST_STRUCT_UPDATE
      ,MODEL_LAST_LOGIC_UPDATE
      ,MODEL_LAST_UPDATED
      ,CREATED_BY
      ,CREATION_DATE
      ,LAST_UPDATED_BY
      ,LAST_UPDATE_DATE
      ,USER_STR01
      ,USER_STR02
      ,USER_STR03
      ,USER_STR04
      ,USER_NUM01
      ,USER_NUM02
      ,USER_NUM03
      ,USER_NUM04
      ,MODEL_PERSISTENT_ID
      ,SOURCE_TARGET_FLAG
      ,REMOTE_PUBLICATION_ID
      ,PAGE_LAYOUT
      ,CONTAINER
      ,DISABLED_FLAG
      ,PUBLISHED
      ) VALUES
      (
        l_new_pb_id
	 ,p_src_object_id
	 ,l_pub_cursor.OBJECT_TYPE
	 ,p_tgt_server_id
	 ,DECODE(l_pub_cursor.ORGANIZATION_ID,NULL,NULL, v_org_id)
	 ,DECODE(l_pub_cursor.TOP_ITEM_ID ,NULL, NULL, v_item_id)
	 ,DECODE(l_pub_cursor.PRODUCT_KEY , NULL,NULL, v_product_key )
	 ,l_pub_cursor.PUBLICATION_MODE
	 ,l_ui_def_id
	 ,l_pub_cursor.UI_STYLE
	 ,l_pub_cursor.APPLICABLE_FROM
	 ,l_pub_cursor.APPLICABLE_UNTIL
	 ,l_pub_cursor.EXPORT_STATUS
	 ,l_pub_cursor.DELETED_FLAG
	 ,l_pub_cursor.MODEL_LAST_STRUCT_UPDATE
	 ,l_pub_cursor.MODEL_LAST_LOGIC_UPDATE
	 ,l_pub_cursor.MODEL_LAST_UPDATED
	 ,l_pub_cursor.CREATED_BY
	 ,l_pub_cursor.CREATION_DATE
	 ,l_pub_cursor.LAST_UPDATED_BY
	 ,l_pub_cursor.LAST_UPDATE_DATE
	 ,l_pub_cursor.USER_STR01
	 ,l_pub_cursor.USER_STR02
	 ,l_pub_cursor.USER_STR03
	 ,l_pub_cursor.USER_STR04
	 ,l_pub_cursor.USER_NUM01
	 ,l_pub_cursor.USER_NUM02
	 ,l_pub_cursor.USER_NUM03
	 ,l_pub_cursor.USER_NUM04
	 ,l_pub_cursor.MODEL_PERSISTENT_ID
	 ,'S'
	 ,p_publication_id
	 ,l_pub_cursor.PAGE_LAYOUT
	 ,l_pub_cursor.CONTAINER
	 ,l_pub_cursor.DISABLED_FLAG
	 ,l_pub_cursor.PUBLISHED
    );
  END LOOP;
  CLOSE pub_cursor;

  ----update remote publication id on the clone instance
  EXECUTE IMMEDIATE
    'UPDATE cz_model_publications'||p_link_name||'  t ' ||
    ' SET t.remote_publication_id = '||l_new_pb_id||
    ' WHERE t.publication_id = '||p_publication_id ;

  ----insert into cz_pb_client_apps
  EXECUTE IMMEDIATE
    'INSERT INTO cz_pb_client_apps(publication_id,fnd_application_id,application_short_name,notes)' ||
    ' SELECT '||l_new_pb_id||',' ||
    '        s.application_id,' ||
    '        x.application_short_name,' ||
    '        x.notes' ||
    ' FROM  cz_pb_client_apps'||p_link_name||'  x,  fnd_applications  s' ||
    ' WHERE x.publication_id = '||p_publication_id ||
    ' AND x.application_short_name = s.application_short_name' ;

  ----insert into cz_publication_usages
  EXECUTE IMMEDIATE
    'INSERT INTO cz_publication_usages(publication_id,usage_id)' ||
    ' SELECT '||l_new_pb_id||',usage_id' ||
    ' FROM  cz_publication_usages'||p_link_name||'  z' ||
    ' WHERE z.publication_id = '||p_publication_id ;

  ----insert into cz_pb_languages
  EXECUTE IMMEDIATE
    'INSERT INTO cz_pb_languages(publication_id,language)' ||
    ' SELECT '||l_new_pb_id||', language' ||
    ' FROM cz_pb_languages'||p_link_name||'  y' ||
    ' WHERE y.publication_id = '||p_publication_id;

  m_err_message  := 'source pb: '||l_new_pb_id||' created for target pb: '||p_publication_id;
  error_msg_populate(m_err_message ,'CZ_PB_MGR.CREATESRCPBRECORDS',SQLCODE);
EXCEPTION
  WHEN OTHERS THEN
    IF pub_cursor%ISOPEN THEN
      CLOSE pub_cursor;
    END IF;
    ROLLBACK;
    RAISE;
END create_src_publication;

--------------------------------------------------------
----procedure that deletes a publication record on the target
----instance
PROCEDURE delete_tgt_publication(p_publication_id IN cz_model_publications.publication_id%TYPE,
					   p_link_name IN cz_servers.fndnam_link_name%TYPE)
IS

BEGIN
	EXECUTE IMMEDIATE
	'delete from cz_model_publications'||p_link_name||' t' ||
	' where  t.publication_id = '||p_publication_id ;
EXCEPTION
WHEN OTHERS THEN
	RAISE;
END;

---------------------------------------------------------
------procedure that retrieves the src and tgt information
PROCEDURE get_src_tgt_info(p_tgt_server_id IN cz_servers.server_local_id%TYPE,
				   x_src_instance OUT NOCOPY cz_servers.local_name%TYPE,
				   x_tgt_instance OUT NOCOPY cz_servers.local_name%TYPE)
IS

BEGIN
	SELECT instance_name
	INTO   x_src_instance
	FROM   cz_servers
	WHERE  cz_servers.server_local_id = 0;

	SELECT instance_name
	INTO   x_tgt_instance
	FROM   cz_servers
	WHERE  cz_servers.server_local_id = p_tgt_server_id ;
EXCEPTION
WHEN OTHERS THEN
	RAISE;
END;
-------------------------------------------------------
PROCEDURE clear_publication_data(p_target_server_id IN cz_model_publications.server_id%TYPE)
IS

l_src_pub_tbl  t_ref;

BEGIN
	SELECT publication_id
	BULK
	COLLECT
	INTO   l_src_pub_tbl
	FROM   cz_model_publications
	WHERE  server_id = p_target_server_id ;

	IF (l_src_pub_tbl.COUNT > 0) THEN
		FOR I IN l_src_pub_tbl.FIRST..l_src_pub_tbl.LAST
		LOOP
			----clear source pb record of the tgt clone
			clear_source_pb_record(l_src_pub_tbl(i));

			---clear pb clients
			clear_pb_clients(l_src_pub_tbl(i));

			----clear pb usages
			clear_pb_usages(l_src_pub_tbl(i));

			----clear pb lang
			clear_pb_lang(l_src_pub_tbl(i));
		END LOOP;
	END IF;
EXCEPTION
WHEN NO_DATA_FOUND THEN
	----do nothing
	NULL;
WHEN OTHERS THEN
   RAISE;
END;

----------------------------------------------------------
----procedure that creates the source publication records for each valid publication
----on the clone
PROCEDURE create_src_pb_records(p_tgt_server_id IN cz_servers.server_local_id%TYPE)
IS

  TYPE object_type_tbl_type IS TABLE OF cz_model_publications.object_type%TYPE
    INDEX BY BINARY_INTEGER;

  l_ref_cursor    REF_CURSOR;
  l_model_cursor  REF_CURSOR;
  l_templ_cursor  REF_CURSOR;
  l_ui_cursor     REF_CURSOR;

  l_publication_id   cz_model_publications.publication_id%TYPE;
  l_src_pb_id        cz_model_publications.publication_id%TYPE;
  l_rem_pb_id        cz_model_publications.publication_id%TYPE;
  l_src_object_id    cz_model_publications.object_id%TYPE;
  l_tgt_object_id    cz_model_publications.object_id%TYPE;
  l_src_object_type  cz_model_publications.object_type%TYPE;
  l_tgt_object_type  cz_model_publications.object_type%TYPE;
  l_src_model_id     cz_model_publications.model_id%TYPE;
  l_src_ui_def_id    cz_model_publications.ui_def_id%TYPE;
  l_src_object_name  cz_devl_projects.name%TYPE;
  l_tgt_object_name  cz_devl_projects.name%TYPE;

  l_link_name        cz_servers.fndnam_link_name%TYPE;

  l_tgt_src_pub_tbl      t_ref;
  l_tgt_rem_pub_tbl      t_ref;
  l_tgt_object_id_tbl    t_ref;
  l_tgt_object_type_tbl  object_type_tbl_type;
  l_tgt_src_model_tbl    t_ref;
  l_tgt_src_ui_def_tbl   t_ref;
  l_tgt_object_name_tbl  t_name;
  l_tgt_pb_count         NUMBER;

  l_src_instance    cz_servers.local_name%TYPE;
  l_tgt_instance    cz_servers.local_name%TYPE;
  l_tgt_ui_def_id   cz_ui_defs.ui_def_id%TYPE;

  OBJ_TYPE_MISMATCH_ERR  EXCEPTION;
  MODEL_MISMATCH_ERR     EXCEPTION;
  UI_MISMATCH_ERR        EXCEPTION;
  MODELNAME_MISMATCH_ERR EXCEPTION;
  TEMPLNAME_MISMATCH_ERR EXCEPTION;
  OBJ_TYPE_ERR           EXCEPTION;

BEGIN
  clear_publication_data(p_tgt_server_id);
  l_link_name := cz_pb_sync_util.retrieve_link_name(p_tgt_server_id);

  l_tgt_src_pub_tbl.DELETE;
  l_tgt_rem_pub_tbl.DELETE;
  l_tgt_object_id_tbl.DELETE;
  l_tgt_object_type_tbl.DELETE;
  l_tgt_src_model_tbl.DELETE;
  l_tgt_src_ui_def_tbl.DELETE;
  l_tgt_object_name_tbl.DELETE;

  l_tgt_pb_count := 1;
  OPEN l_ref_cursor FOR
         'SELECT publication_id,
                 remote_publication_id,
                 object_id,
                 object_type,
                 source_model_id,
                 source_ui_def_id
          FROM cz_model_publications'||l_link_name||'  t
          WHERE t.deleted_flag = ''0''
          AND   t.source_target_flag = ''T''
          AND   t.export_status = ''OK'' ';
  LOOP
    FETCH l_ref_cursor INTO l_publication_id,
                            l_rem_pb_id,
                            l_tgt_object_id,
                            l_tgt_object_type,
                            l_src_model_id,
                            l_src_ui_def_id;
    EXIT WHEN l_ref_cursor%NOTFOUND;
    l_tgt_src_pub_tbl(l_tgt_pb_count)     := l_publication_id;
    l_tgt_rem_pub_tbl(l_tgt_pb_count)     := l_rem_pb_id;
    l_tgt_object_id_tbl(l_tgt_pb_count)   := l_tgt_object_id;
    l_tgt_object_type_tbl(l_tgt_pb_count) := l_tgt_object_type;
    l_tgt_src_model_tbl(l_tgt_pb_count)   := nvl(l_src_model_id,0);
    l_tgt_src_ui_def_tbl(l_tgt_pb_count)  := nvl(l_src_ui_def_id,0);
    l_tgt_pb_count := l_tgt_pb_count + 1;
  END LOOP;
  CLOSE l_ref_cursor;

  IF (l_tgt_object_id_tbl.COUNT > 0) THEN
    FOR i IN l_tgt_object_id_tbl.FIRST..l_tgt_object_id_tbl.LAST
    LOOP
      l_tgt_object_id := l_tgt_object_id_tbl(i);
      IF l_tgt_object_type_tbl(i) = OBJECT_TYPE_PROJECT THEN
        OPEN l_model_cursor FOR
          'SELECT name
           FROM cz_devl_projects'||l_link_name||'  t
           WHERE t.devl_project_id = '||l_tgt_object_id||'
           AND   t.deleted_flag = ''0'' ';
        LOOP
          FETCH l_model_cursor INTO l_tgt_object_name;
          EXIT WHEN l_model_cursor%NOTFOUND;
          l_tgt_object_name_tbl(i) := l_tgt_object_name;
        END LOOP;
        CLOSE l_model_cursor;
      ELSE
        OPEN l_templ_cursor FOR
          'SELECT template_name
           FROM cz_ui_templates'||l_link_name||'  t
           WHERE t.template_id = '||l_tgt_object_id||'
           AND   t.ui_def_id = '||GLOBAL_UI_DEF_PUB||'
           AND   t.deleted_flag = ''0'' ';
        LOOP
          FETCH l_templ_cursor INTO l_tgt_object_name;
          EXIT WHEN l_templ_cursor%NOTFOUND;
          l_tgt_object_name_tbl(i) := l_tgt_object_name;
        END LOOP;
        CLOSE l_templ_cursor;
      END IF;
    END LOOP;
  END IF;

  IF (l_tgt_rem_pub_tbl.COUNT > 0) THEN
    FOR I IN 1..l_tgt_rem_pub_tbl.COUNT
    LOOP
      l_src_pb_id := 0;
      l_src_object_id  := 0;
      l_src_ui_def_id := 0;
      BEGIN
        SELECT publication_id,object_id,object_type,ui_def_id
        INTO   l_src_pb_id,l_src_object_id,l_src_object_type,l_src_ui_def_id
        FROM   cz_model_publications
        WHERE  cz_model_publications.publication_id = l_tgt_rem_pub_tbl(i);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          ----delete tgt_publication
          m_err_message  := CZ_UTILS.GET_TEXT('CZ_PB_SYNC_DEL_TGT_PB',
              'TGTPBID',l_tgt_rem_pub_tbl(i));
          error_msg_populate(m_err_message ,'CZ_PB_MGR.DELTGTPBID',SQLCODE);
          delete_tgt_publication(l_tgt_src_pub_tbl(i),l_link_name);
        WHEN OTHERS THEN
          RAISE;
      END;

      IF (l_src_object_id > 0) THEN
        IF UPPER(l_src_object_type) <> UPPER(l_tgt_object_type_tbl(i)) THEN
          l_publication_id := l_tgt_src_pub_tbl(i);
          l_tgt_object_type := l_tgt_object_type_tbl(i);
          RAISE OBJ_TYPE_MISMATCH_ERR;
        END IF;

        IF l_src_object_type = OBJECT_TYPE_PROJECT THEN
          -----match models on the source and the target
          IF (l_tgt_src_model_tbl(i) <> 0) THEN
            IF (l_src_object_id <> l_tgt_src_model_tbl(i)) THEN
              l_tgt_object_id := l_tgt_src_model_tbl(i);
              RAISE MODEL_MISMATCH_ERR;
            END IF;
          END IF;

          IF (l_tgt_src_ui_def_tbl(i) <> 0) THEN
            IF ( (l_src_ui_def_id IS NOT NULL) AND
                 (l_src_ui_def_id <> l_tgt_src_ui_def_tbl(i)) ) THEN
              l_tgt_ui_def_id := l_tgt_src_ui_def_tbl(i);
              RAISE UI_MISMATCH_ERR;
            END IF;
          END IF;

          SELECT name INTO l_src_object_name
          FROM   cz_devl_projects
          WHERE  cz_devl_projects.devl_project_id = l_src_object_id;

          IF (l_src_object_name <> l_tgt_object_name_tbl(i)) THEN
            l_tgt_object_name  := l_tgt_object_name_tbl(i);
            RAISE MODELNAME_MISMATCH_ERR;
          END IF;
        ELSIF l_src_object_type = OBJECT_TYPE_UITEMPL THEN
          SELECT template_name INTO l_src_object_name
          FROM cz_ui_templates
          WHERE template_id = l_src_object_id AND ui_def_id = GLOBAL_UI_DEF_SRC;

          IF l_src_object_name <> l_tgt_object_name_tbl(i) THEN
            l_tgt_object_name  := l_tgt_object_name_tbl(i);
            RAISE TEMPLNAME_MISMATCH_ERR;
          END IF;
        ELSE
          RAISE OBJ_TYPE_ERR;
        END IF;

        ----publication data on the source is created for each publication id
        ----if error occurs during an insert, the whole sync is terminated
        create_src_publication(l_tgt_src_pub_tbl(i),
                               l_link_name,
                               p_tgt_server_id,
                               l_src_object_id,
                               -- l_src_object_type,
                               l_src_ui_def_id);
      END IF;
    END LOOP;
  END IF;
EXCEPTION
  WHEN MODEL_MISMATCH_ERR THEN
    ----get source and target info
    get_src_tgt_info(p_tgt_server_id, l_src_instance,l_tgt_instance);
    m_err_message  := CZ_UTILS.GET_TEXT('CZ_PB_SYNC_MODELS_ERR',
                                        'SRCMODEL',l_src_object_id,
                                        'SRCINSTANCE',l_src_instance,
                                        'TGTMODEL',l_tgt_object_id,
                                        'TGTINSTANCE',l_tgt_instance);
    error_msg_populate(m_err_message ,'CZ_PB_MGR.CREATESRCPBRECORDS',SQLCODE);
    IF (l_ref_cursor%ISOPEN) THEN
      CLOSE l_ref_cursor;
    END IF;

    IF (l_model_cursor%ISOPEN) THEN
      CLOSE l_model_cursor;
    END IF;
    IF (l_templ_cursor%ISOPEN) THEN
      CLOSE l_templ_cursor;
    END IF;
    RAISE;
  WHEN UI_MISMATCH_ERR THEN
    ----get source and target info
    get_src_tgt_info(p_tgt_server_id, l_src_instance,l_tgt_instance);
    m_err_message  := CZ_UTILS.GET_TEXT('CZ_PB_SYNC_UIS_ERR',
                                        'SRCUIDEF',l_src_ui_def_id,
                                        'SRCINSTANCE',l_src_instance,
                                        'TGTUIDEF',l_tgt_ui_def_id,
                                        'TGTINSTANCE',l_tgt_instance);
    error_msg_populate(m_err_message ,'CZ_PB_MGR.CREATESRCPBRECORDS',SQLCODE);
    IF (l_ref_cursor%ISOPEN) THEN
      CLOSE l_ref_cursor;
    END IF;
    IF (l_model_cursor%ISOPEN) THEN
      CLOSE l_model_cursor;
    END IF;
    IF (l_templ_cursor%ISOPEN) THEN
      CLOSE l_templ_cursor;
    END IF;
    RAISE;
  WHEN MODELNAME_MISMATCH_ERR  THEN
    ----get source and target info
    get_src_tgt_info(p_tgt_server_id, l_src_instance,l_tgt_instance);
    m_err_message  := CZ_UTILS.GET_TEXT('CZ_PB_SYNC_MODELNAME_ERR',
                                        'SRCMODEL',l_src_object_name,
                                        'SRCINSTANCE',l_src_instance,
                                        'TGTMODEL',l_tgt_object_name,
                                        'TGTINSTANCE',l_tgt_instance);
    error_msg_populate(m_err_message ,'CZ_PB_MGR.CREATESRCPBRECORDS',SQLCODE);
    IF (l_ref_cursor%ISOPEN) THEN
      CLOSE l_ref_cursor;
    END IF;
    IF (l_model_cursor%ISOPEN) THEN
      CLOSE l_model_cursor;
    END IF;
    IF (l_templ_cursor%ISOPEN) THEN
      CLOSE l_templ_cursor;
    END IF;
    RAISE;
  WHEN TEMPLNAME_MISMATCH_ERR  THEN
    ----get source and target info
    get_src_tgt_info(p_tgt_server_id, l_src_instance,l_tgt_instance);
    m_err_message  := CZ_UTILS.GET_TEXT('CZ_PB_SYNC_TEMPLNAME_ERR',
                                        'SRCTEMPL',l_src_object_name,
                                        'SRCINSTANCE',l_src_instance,
                                        'TGTTEMPL',l_tgt_object_name,
                                        'TGTINSTANCE',l_tgt_instance);
    error_msg_populate(m_err_message ,'CZ_PB_MGR.CREATESRCPBRECORDS',SQLCODE);
    IF (l_ref_cursor%ISOPEN) THEN
      CLOSE l_ref_cursor;
    END IF;

    IF (l_templ_cursor%ISOPEN) THEN
      CLOSE l_templ_cursor;
    END IF;

    IF (l_model_cursor%ISOPEN) THEN
      CLOSE l_model_cursor;
    END IF;
    RAISE;
  WHEN OBJ_TYPE_MISMATCH_ERR THEN
    ----get source and target info
    get_src_tgt_info(p_tgt_server_id, l_src_instance,l_tgt_instance);
    m_err_message  := CZ_UTILS.GET_TEXT('CZ_PB_SYNC_TYPE_ERR',
                                        'TGTTYPE', l_tgt_object_type,
                                        'TGTPUBID',l_publication_id,
                                        'TGTINSTANCE',l_tgt_instance,
                                        'SRCTYPE', l_src_object_type,
                                        'SRCPUBID',l_src_pb_id,
                                        'SRCINSTANCE',l_src_instance);
    error_msg_populate(m_err_message ,'CZ_PB_MGR.CREATESRCPBRECORDS',SQLCODE);
    IF (l_ref_cursor%ISOPEN) THEN
      CLOSE l_ref_cursor;
    END IF;

    IF (l_model_cursor%ISOPEN) THEN
      CLOSE l_model_cursor;
    END IF;
    RAISE;

    IF (l_templ_cursor%ISOPEN) THEN
      CLOSE l_templ_cursor;
    END IF;
    RAISE;

  WHEN OBJ_TYPE_ERR THEN
    ----get source and target info
    get_src_tgt_info(p_tgt_server_id, l_src_instance,l_tgt_instance);
    m_err_message := 'The object_type ' || l_src_object_type || ' of publication ' ||
           l_src_pb_id || ' on instance ' || l_src_instance || ' is invalid';
    error_msg_populate(m_err_message ,'CZ_PB_MGR.CREATESRCPBRECORDS',SQLCODE);
    IF (l_ref_cursor%ISOPEN) THEN
      CLOSE l_ref_cursor;
    END IF;

    IF (l_model_cursor%ISOPEN) THEN
      CLOSE l_model_cursor;
    END IF;
    RAISE;

    IF (l_templ_cursor%ISOPEN) THEN
      CLOSE l_templ_cursor;
    END IF;
    RAISE;

  WHEN OTHERS THEN
    IF (l_ref_cursor%ISOPEN) THEN
      CLOSE l_ref_cursor;
    END IF;

    IF (l_model_cursor%ISOPEN) THEN
      CLOSE l_model_cursor;
    END IF;
    IF (l_templ_cursor%ISOPEN) THEN
      CLOSE l_templ_cursor;
    END IF;
    RAISE;
END create_src_pb_records;

------------------------------------------------------
-----function that validates input parameters
FUNCTION verify_input_parameters(p_target_instance IN VARCHAR2)
RETURN BOOLEAN
IS

l_instance_name	cz_servers.instance_name%TYPE;
l_host_name		cz_servers.hostname%TYPE;
l_listener_port	cz_servers.db_listener_port%TYPE;
l_fndnam_link_name cz_servers.fndnam_link_name%TYPE;
v_ret_flag		 BOOLEAN := TRUE;

BEGIN
	IF (p_target_instance IS NULL) THEN
		m_err_message := CZ_UTILS.GET_TEXT('CZ_PB_SYNC_INPUT_INST_NULL');
		error_msg_populate(m_err_message ,'CZ_PB_SYNC.INPUTPARAMS',21004);
		v_ret_flag := FALSE;
	ELSE
		SELECT instance_name,hostname,db_listener_port,fndnam_link_name
		INTO   l_instance_name,l_host_name,l_listener_port,l_fndnam_link_name
		FROM   cz_servers
		WHERE  UPPER(cz_servers.local_name) = UPPER(p_target_instance);

		IF (l_instance_name IS NULL) THEN
			m_err_message := CZ_UTILS.GET_TEXT('CZ_PB_SYNC_INSTANCE_IS_NULL', 'TGTINSTANCE',p_target_instance);
			error_msg_populate(m_err_message ,'CZ_PB_SYNC.INPUTPARAMS',21004);
			v_ret_flag := FALSE;
		END IF;

		IF (l_host_name IS NULL) THEN
			m_err_message := CZ_UTILS.GET_TEXT('CZ_PB_SYNC_HOST_IS_NULL','TGTINSTANCE',p_target_instance);
			error_msg_populate(m_err_message ,'CZ_PB_SYNC.INPUTPARAMS',21004);
			v_ret_flag := FALSE;
		END IF;

		IF (l_listener_port IS NULL) THEN
			m_err_message := CZ_UTILS.GET_TEXT('CZ_PB_SYNC_PORT_IS_NULL','TGTINSTANCE',p_target_instance);
			error_msg_populate(m_err_message ,'CZ_PB_SYNC.INPUTPARAMS',21004);
			v_ret_flag := FALSE;
		END IF;

		IF (l_fndnam_link_name IS NULL) THEN
			m_err_message := CZ_UTILS.GET_TEXT('CZ_PB_SYNC_LINK_IS_NULL','TGTINSTANCE',p_target_instance);
			error_msg_populate(m_err_message ,'CZ_PB_SYNC.INPUTPARAMS',21004);
			v_ret_flag := FALSE;
		END IF;
	END IF;

	RETURN v_ret_flag;
EXCEPTION
WHEN NO_DATA_FOUND THEN
	m_err_message := CZ_UTILS.GET_TEXT('CZ_PB_SYNC_NO_SVR_ENTRY','TGTINSTANCE',p_target_instance);
	error_msg_populate(m_err_message ,'CZ_PB_SYNC.INPUTPARAMS',21004);
	v_ret_flag := FALSE;
	RETURN v_ret_flag;
WHEN OTHERS THEN
	v_ret_flag := FALSE;
	RETURN v_ret_flag;
END verify_input_parameters;

-------------------------------------------------------
-----procedure that updates server information on the target
PROCEDURE update_server_info(p_target_server_id IN cz_servers.server_local_id%TYPE,
				     p_link_name 		IN cz_servers.fndnam_link_name%TYPE)
IS

l_instance_name	cz_servers.instance_name%TYPE;
l_host_name		cz_servers.hostname%TYPE;
l_listener_port	cz_servers.db_listener_port%TYPE;
l_sync_date		VARCHAR2(50);

BEGIN
	l_sync_date	:= TO_CHAR(sysdate, 'mm-dd-yyyy hh24:mi:ss');

	SELECT instance_name,hostname,db_listener_port
	INTO   l_instance_name,l_host_name,l_listener_port
	FROM   cz_servers
	WHERE  cz_servers.server_local_id = p_target_server_id;

	EXECUTE IMMEDIATE
		'UPDATE cz_servers'||p_link_name||'  t ' ||
	 	' SET t.instance_name = '''||l_instance_name||''',  ' ||
		'     t.hostname = '''||l_host_name||''', ' ||
		'     t.db_listener_port = '||l_listener_port||', ' ||
		'     t.notes		= '''||l_sync_date||'''   ' ||
		' WHERE UPPER(t.local_name) = ''LOCAL'' ';
EXCEPTION
WHEN NO_DATA_FOUND THEN
	m_err_message := CZ_UTILS.GET_TEXT('CZ_PB_SYNC_UPD_SVR_ERR','SERVERID',p_target_server_id, 'SQLERRM',SQLERRM);
	error_msg_populate(m_err_message ,'CZ_PB_SYNC.GETTGTINSTANCE',21004);
	RAISE;
WHEN OTHERS THEN
	m_err_message := CZ_UTILS.GET_TEXT('CZ_PB_SYNC_UPD_SVR_ERR','SERVERID',p_target_server_id, 'SQLERRM',SQLERRM);
	error_msg_populate(m_err_message ,'CZ_PB_SYNC.GETTGTINSTANCE',21004);
	RAISE;
END;

--------------------------------------------------------
-----procedure that syncs publication data on the source
-----and target servers
------@p_target_server_id --- server id of the target server
------@x_pb_clone_flg     --- TRUE if sync was successful

PROCEDURE sync_publication_clone(p_target_server_id IN cz_servers.server_local_id%TYPE,
					   x_pb_clone_flg OUT NOCOPY BOOLEAN)
IS

v_link_name      cz_servers.fndnam_link_name%TYPE;

BEGIN
	x_pb_clone_flg := TRUE;

 	----for each tgt publication record create source publication record
	create_src_pb_records(p_target_server_id);

	----clear pb exports
	clear_pb_exports;

	----update server id in tgt publication record
	v_link_name := cz_pb_sync_util.retrieve_link_name(p_target_server_id);
	update_tgt_server_id(p_target_server_id,v_link_name);

	----update target server information
	update_server_info(p_target_server_id,v_link_name);

EXCEPTION
WHEN OTHERS THEN
	m_err_message := CZ_UTILS.GET_TEXT('CZ_PB_SYNC_INSERT_ERR', 'SQLERRM', SQLERRM);
	error_msg_populate(m_err_message ,'CZ_PB_SYNC.SYNCPBCLONE',21015);
	x_pb_clone_flg := FALSE;
END sync_publication_clone;

-----------------------------------------------------
--- procedure that synchronizes the publication data on the source and
--- target servers
PROCEDURE sync_cloned_tgt_pub_data(p_target_instance IN VARCHAR2,
                                   x_run_id OUT NOCOPY NUMBER,
                                   x_status OUT NOCOPY VARCHAR2)
IS

  l_src_verification   BOOLEAN;
  l_target_server_id  NUMBER := 0;
  l_validate_flg     BOOLEAN := TRUE;
  l_has_to_be_synced_flg  BOOLEAN := TRUE;
  l_pb_clone_flg    BOOLEAN ;
  l_run_id          NUMBER := 0;
  l_link_name     cz_servers.fndnam_link_name%TYPE;
  l_proc_name     v$session.module%TYPE;

BEGIN

  ----initialize OUT NOCOPY variables
  x_status := FND_API.G_RET_STS_SUCCESS;
  m_msg_tbl.DELETE;

  FOR I IN 1..1
  LOOP
    ----get run id
    l_run_id := cz_pb_sync_util.get_run_id;
    x_run_id := l_run_id;

    IF (l_run_id = 0) THEN
      m_err_message  := CZ_UTILS.GET_TEXT('CZ_PB_SEQ_XFR');
      error_msg_populate(m_err_message ,'CZ_PB_SYNC.XFRINFO',21001);
      x_status := FND_API.G_RET_STS_ERROR;
      EXIT;
    END IF;

    ----check if another sync is in progress
    l_proc_name := cz_pb_sync_util.check_process;
    IF l_proc_name IS NOT NULL THEN
      m_err_message  := CZ_UTILS.GET_TEXT('CZ_PB_SYNC_PROCESS_EXISTS');
      error_msg_populate(m_err_message ,'CZ_PB_SYNC.CHKPROCESS',21001);
      x_status := FND_API.G_RET_STS_ERROR;
      EXIT;
    ELSE
      ----register application
      cz_pb_sync_util.set_dbms_info('CZ_PB_SYNC');
    END IF;

    ----validate input parameters
    IF (NOT verify_input_parameters(p_target_instance) ) THEN
      x_status := FND_API.G_RET_STS_ERROR;
      EXIT;
    END IF;

    ---verify schema versions on the source and target instances
    l_target_server_id := cz_pb_sync_util.get_target_instance_id(p_target_instance);

    ------check for active links
    l_link_name := cz_pb_sync_util.retrieve_link_name(l_target_server_id);
    IF ( NOT cz_pb_sync_util.check_db_link(l_link_name) ) THEN
      m_err_message := CZ_UTILS.GET_TEXT('CZ_PB_SYNC_NO_LINK_EXISTS','LINKNAME',l_link_name);
      error_msg_populate(m_err_message ,'CHECKDBLINK',21025);
      x_status := FND_API.G_RET_STS_ERROR;
      EXIT;
    END IF;

    ---verify that the above proc is called from the source
    l_src_verification := verify_source_instance(p_target_instance);
    IF (NOT l_src_verification) THEN
      x_status := FND_API.G_RET_STS_ERROR;
      EXIT;
    END IF;

    l_validate_flg := cz_pb_sync_util.validate_schema(l_target_server_id);
    IF (NOT l_validate_flg ) THEN
      m_err_message :=  CZ_UTILS.GET_TEXT('CZ_PB_SCHEMA_COMPAT_ERR');
      error_msg_populate(m_err_message ,'VALIDATESCHEMA',21005);
      x_status := FND_API.G_RET_STS_ERROR;
      EXIT;
    END IF;

    -----verify that the target instance is a clone
    IF (check_target_instance(l_link_name) ) THEN
      x_status := FND_API.G_RET_STS_ERROR;
      EXIT;
    END IF;


    ----check if the pb data has to be synchronized
    l_has_to_be_synced_flg  := has_to_be_synced(l_target_server_id);
    IF (NOT l_has_to_be_synced_flg) THEN
      x_status := FND_API.G_RET_STS_ERROR;
      EXIT;
    ELSE
      ---sync publication data for a single publication
      sync_publication_clone(l_target_server_id,l_pb_clone_flg);

      IF (NOT l_pb_clone_flg) THEN
        x_status := FND_API.G_RET_STS_ERROR;
        ROLLBACK;
        EXIT;
      ELSE
        COMMIT;
      END IF;
    END IF;
  END LOOP;

  ---log errors to cz_db_logs
  IF (x_status = FND_API.G_RET_STS_ERROR) THEN
    m_err_message :=  CZ_UTILS.GET_TEXT('CZ_PB_SYNC_FAILURE', 'INSTANCENAME',p_target_instance);
    error_msg_populate(m_err_message ,'SYNCCLOTGTPBDATA',21014);
  END IF;
  cz_pb_sync_util.log_pb_sync_errors(m_msg_tbl,l_run_id);

  -----unregister application
  cz_pb_sync_util.reset_dbms_info;
EXCEPTION
  WHEN OTHERS THEN
    x_status := FND_API.G_RET_STS_UNEXP_ERROR;
END sync_cloned_tgt_pub_data;

------------------------------------------------------------
-----concurrent manager program for cloned tgt instance
PROCEDURE sync_cloned_tgt_pub_data_cp(Errbuf  IN OUT NOCOPY  VARCHAR2,
				  		  Retcode IN OUT NOCOPY  PLS_INTEGER,
						  p_target_instance IN VARCHAR2)

IS

v_run_id      NUMBER := 0.0;
v_sync_status VARCHAR2(1);

BEGIN
   Retcode:=0;
   sync_cloned_tgt_pub_data(p_target_instance,v_run_id,v_sync_status);

   Errbuf := NULL;
   IF (v_sync_status = FND_API.G_RET_STS_ERROR) THEN
      Errbuf := CZ_UTILS.GET_TEXT('CZ_PB_SYNC_FAILURE', 'INSTANCENAME',p_target_instance);
	Retcode:= 2;
   END IF;

EXCEPTION
WHEN OTHERS THEN
    Retcode := 2;
    Errbuf := CZ_UTILS.GET_TEXT('CZ_PB_SYNC_FAILURE', 'TGTINSTANCE',p_target_instance);
END sync_cloned_tgt_pub_data_cp;

---------------------------------------------------------
----get local server information
PROCEDURE get_local_server_info (x_hostname OUT NOCOPY cz_servers.hostname%TYPE,
					   x_instance_name  OUT NOCOPY cz_servers.instance_name%TYPE)
IS

BEGIN
	SELECT host_name,instance_name
	INTO   x_hostname,x_instance_name
	FROM   v$instance;
EXCEPTION
WHEN OTHERS THEN
	RAISE;
END get_local_server_info;

--------------------------------------------------------
PROCEDURE modify_target_server(p_link_name IN VARCHAR2,
					 p_hostname IN  cz_servers.hostname%TYPE,
					 p_instance_name IN cz_servers.instance_name%TYPE,
					 p_local_name IN cz_servers.local_name%TYPE)
IS

v_str VARCHAR2(2000);

BEGIN
	v_str := ' UPDATE cz_servers'||p_link_name||'  SET hostname = '''||p_hostname||''', ' ||
		 ' instance_name = '''||p_instance_name||''',   ' ||
		 ' local_name = :1 ' ||
	 	 ' WHERE source_server_flag = ''1'' ';

	EXECUTE IMMEDIATE v_str USING p_local_name ;
COMMIT;
EXCEPTION
WHEN OTHERS THEN
	RAISE;
END;

-----procedure that retrieves the link name
FUNCTION get_link_name(p_local_name IN cz_servers.local_name%TYPE)
RETURN VARCHAR2
IS

l_link_name	cz_servers.fndnam_link_name%TYPE := NULL;

BEGIN
	SELECT fndnam_link_name
	INTO   l_link_name
	FROM   cz_servers
	WHERE  UPPER(local_name) = UPPER(p_local_name);

	RETURN l_link_name;
EXCEPTION
WHEN OTHERS THEN
	RETURN l_link_name;
END get_link_name;
----------------------------------------------------------
--- procedure that synchronizes the publication data on the source and
--- target servers after the source server has been cloned
 PROCEDURE sync_cloned_src_pub_data(p_decomm_flag IN VARCHAR2,
					     x_run_id OUT NOCOPY NUMBER,
					     x_status OUT NOCOPY VARCHAR2)
IS

v_src_verification 	BOOLEAN;
v_target_server_id	NUMBER := 0;
v_validate_flg 		BOOLEAN := TRUE;
v_has_to_be_synced_flg  BOOLEAN := TRUE;
v_pb_clone_flg		BOOLEAN ;
v_run_id		      NUMBER := 0;
v_link_name 		cz_servers.fndnam_link_name%TYPE;

l_hostname			cz_servers.hostname%TYPE;
l_instance_name		cz_servers.instance_name%TYPE;
l_local_name_tbl		t_name ;
l_message			VARCHAr2(2000);
l_proc_name   v$session.module%TYPE;

BEGIN

	----initialize OUT NOCOPY variables
	x_status := FND_API.G_RET_STS_SUCCESS;
	m_msg_tbl.DELETE;

	FOR I IN 1..1
	LOOP
		----get run id for message
		v_run_id := cz_pb_sync_util.get_run_id;
		x_run_id := v_run_id;

		IF (v_run_id = 0) THEN
			m_err_message  := CZ_UTILS.GET_TEXT('CZ_PB_SEQ_XFR');
			error_msg_populate(m_err_message ,'CZ_PB_SYNC.XFRINFO',21001);
			x_status := FND_API.G_RET_STS_ERROR;
			EXIT;
		END IF;

		----check if another sync is in progress
                l_proc_name := cz_pb_sync_util.check_process;
                IF l_proc_name IS NOT NULL THEN
			m_err_message  := CZ_UTILS.GET_TEXT('CZ_PB_SYNC_PROCESS_EXISTS');
			error_msg_populate(m_err_message ,'CZ_PB_SYNC.CHKPROCESS',21001);
			x_status := FND_API.G_RET_STS_ERROR;
			EXIT;
		ELSE
			----register application
			cz_pb_sync_util.set_dbms_info('CZ_PB_SYNC');
		END IF;

		----validate input parameter
		IF (UPPER(p_decomm_flag) NOT IN ('YES','NO') ) THEN
			m_err_message := CZ_UTILS.GET_TEXT('CZ_PB_SYNC_INPUT_FLG_INVALID', 'FLAG', p_decomm_flag);
			error_msg_populate(m_err_message ,'CZ_PB_SYNC.DECOMMFLG',21004);
			x_status := FND_API.G_RET_STS_ERROR;
			EXIT;
		END IF;

		-----update local server entry
		get_local_server_info (l_hostname,l_instance_name);

		UPDATE cz_servers
		set    hostname = l_hostname,
			 instance_name = l_instance_name
		WHERE  UPPER(cz_servers.local_name) = 'LOCAL';

		-----recreate database links
		BEGIN
			SELECT local_name
			BULK
			COLLECT
			INTO   l_local_name_tbl
			FROM   cz_servers
			WHERE  UPPER(cz_servers.local_name) <> 'LOCAL';
		EXCEPTION
		WHEN NO_DATA_FOUND THEN
			-----do not care
			NULL;
		END;


		IF (l_local_name_tbl.COUNT > 0) THEN
			FOR localName IN l_local_name_tbl.FIRST..l_local_name_tbl.LAST
			LOOP
				v_link_name := get_link_name(l_local_name_tbl(localName));
				IF (v_link_name IS NOT NULL)  THEN
					v_link_name := '@'||v_link_name;
					IF ( NOT cz_pb_sync_util.check_db_link(v_link_name) ) THEN
						m_err_message := CZ_UTILS.GET_TEXT('CZ_PB_SYNC_NO_LINK_EXISTS','LINKNAME',v_link_name);
						error_msg_populate(m_err_message ,'CHECKDBLINK',21025);
						x_status := FND_API.G_RET_STS_ERROR;
						EXIT;
					END IF;
				END IF;

				IF (UPPER(p_decomm_flag) = 'YES') THEN
					modify_target_server(v_link_name,l_hostname,l_instance_name,l_instance_name);
				ELSE
					UPDATE cz_model_publications set deleted_flag = '1';
					COMMIT;
				END IF;
			END LOOP;
		END IF;
	END LOOP;

	---log errors to cz_db_logs
      IF (x_status = FND_API.G_RET_STS_ERROR) THEN
		m_err_message :=  CZ_UTILS.GET_TEXT('CZ_PB_SYNC_FAILURE', 'SRCINSTANCE',l_instance_name);
		error_msg_populate(m_err_message ,'SYNCCLOTGTPBDATA',21014);
		x_status := FND_API.G_RET_STS_ERROR;
	END IF;
	cz_pb_sync_util.log_pb_sync_errors(m_msg_tbl,v_run_id);

	-----unregister application
	cz_pb_sync_util.reset_dbms_info;
COMMIT;
EXCEPTION
WHEN OTHERS THEN
	x_status := FND_API.G_RET_STS_UNEXP_ERROR;
END sync_cloned_src_pub_data;

-------------------------------------------------------------------
-----concurrent manager program for cloned src instance
PROCEDURE sync_cloned_src_pub_data_cp(Errbuf  IN OUT NOCOPY  VARCHAR2,
				  		  Retcode IN OUT NOCOPY  PLS_INTEGER,
						  p_decomm_flag IN VARCHAR2)

IS

v_run_id       NUMBER := 0.0;
v_sync_status  VARCHAR2(1);
l_src_instance cz_servers.instance_name%TYPE;

BEGIN
   Retcode:=0;
   Errbuf := NULL;

   SELECT name INTO l_src_instance from v$database;
   sync_cloned_src_pub_data(p_decomm_flag,v_run_id,v_sync_status);
   IF (v_sync_status = FND_API.G_RET_STS_ERROR) THEN
      Errbuf := CZ_UTILS.GET_TEXT('CZ_PB_SYNC_FAILURE', 'INSTANCENAME',l_src_instance );
	Retcode:= 2;
   END IF;
EXCEPTION
WHEN OTHERS THEN
    Retcode := 2;
    Errbuf := CZ_UTILS.GET_TEXT('CZ_PB_SYNC_FAILURE', 'TGTINSTANCE',l_src_instance );
END sync_cloned_src_pub_data_cp;


---------------------------------------------------------------------

END cz_pb_sync; /* end of package */

/
