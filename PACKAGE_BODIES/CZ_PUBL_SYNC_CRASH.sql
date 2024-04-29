--------------------------------------------------------
--  DDL for Package Body CZ_PUBL_SYNC_CRASH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_PUBL_SYNC_CRASH" AS
/*      $Header: czpsynb.pls 120.1 2006/04/27 03:20:40 kdande ship $       */

pkg_name  VARCHAR2(30) := 'CZ_PUBL_SYNC_CRASH';

PROCEDURE SET_DBMS_INFO(p_module_name        IN VARCHAR2)
IS
BEGIN
  CZ_ADMIN.SPX_SYNC_PUBLISHSESSIONS;
  DBMS_APPLICATION_INFO.SET_MODULE(p_module_name,'');
END;
------------------------------------------------------------------------------------------
/* clear session */
PROCEDURE RESET_DBMS_INFO
IS
BEGIN
  DBMS_APPLICATION_INFO.SET_MODULE('', '');
END;
------------------------------------------------------------------------------------------
/* Validate if the input server id matches the sid for that server and the db link is alive */

FUNCTION validateServer(p_server_id	IN       NUMBER)
RETURN BOOLEAN
IS
	lServerName CZ_SERVERS.local_name%type;
	lLinkName CZ_SERVERS.fndnam_link_name%type;
	lHostName CZ_SERVERS.HOSTNAME%type;
	lSid CZ_SERVERS.INSTANCE_NAME%type;
	lHost CZ_SERVERS.HOSTNAME%type;
	x_server_f BOOLEAN := FALSE;
	CURSOR c_get_server IS
		SELECT local_name, fndnam_link_name FROM CZ_SERVERS
		WHERE server_local_id = p_server_id;
BEGIN

   BEGIN
	EXECUTE IMMEDIATE
	' SELECT fndnam_link_name,local_name, hostname FROM CZ_SERVERS WHERE server_local_id = :1'
      INTO lLinkName, lServerName, lHostName
	USING p_server_id ;
   EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RAISE SERVER_NOT_FOUND;
   END;

	IF (lLinkName <> NULL) THEN
		lLinkName := '@' || LTRIM(RTRIM(lLinkName));
	END IF;

	IF (lServerName <> NULL) THEN
	   IF (lServerName = 'LOCAL') THEN
		NULL;
	   ELSE
	      IF ((lLinkName <> NULL) AND (CZ_ORAAPPS_INTEGRATE.LINK_IS_DOWN = (cz_oraapps_integrate.isLinkAlive(lLinkName)))) THEN
		   RAISE DB_LINK_DOWN;
	      END IF;
	   END IF;

	   execute immediate 'select INSTANCE_NAME, HOST_NAME from v$instance@'|| lLinkName
		INTO lSid, lHost;
	   IF ((upper(lSid) = upper(lServerName)) and (upper(lHost) = upper(lHostName))) THEN
		return true;
	   ELSE
		RAISE DB_TNS_INCORRECT;
	   END IF;
	ELSE
	   /*
	   ERRNO := czError;
	   ERRBUF := CZ_UTILS.GET_TEXT('CZ_SOURCE_NOT_FOUND','SERVERNAME',lServerName);
	   xERROR := CZ_UTILS.REPORT(ERRBUF,1,'CZ_PUBL_SYNC_CRASH.VALIDATE_SERVER',11276);
	   return false;
	   */
	   RAISE SERVER_NOT_FOUND;
	END IF;
EXCEPTION
WHEN OTHERS THEN
	/*
	ERRNO := czError;
	ERRBUF := CZ_UTILS.GET_TEXT(SQLERRM);
	xERROR := CZ_UTILS.REPORT(ERRBUF,1,'CZ_PUBL_SYNC_CRASH.VALIDATE_SERVER',11276);
	return false;
	*/
	RAISE VALIDATE_SERVER_ERROR;
END validateServer;

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
/* Validate if the input server id matches the sid for that server and the db link is alive */

FUNCTION verifyServer(p_link_name	IN      VARCHAR2)
RETURN BOOLEAN
IS
	lServerName CZ_SERVERS.local_name%type;
	lLinkName CZ_SERVERS.fndnam_link_name%type;
	lHostName CZ_SERVERS.HOSTNAME%type;
	lInstanceName CZ_SERVERS.INSTANCE_NAME%type;
	lSid CZ_SERVERS.INSTANCE_NAME%type;
	lHost CZ_SERVERS.HOSTNAME%type;
	x_server_f BOOLEAN := FALSE;

BEGIN

   BEGIN
	EXECUTE IMMEDIATE
	' SELECT local_name, hostname, instance_name  FROM CZ_SERVERS' || p_link_name ||
	' WHERE source_server_flag = ''1'''
	INTO lServerName,lHostName, lInstanceName;
   EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RAISE SERVER_NOT_FOUND;
   END;

	IF (lServerName is NOT NULL) THEN
	   IF (lServerName = 'LOCAL') THEN
		NULL;
	   ELSE
	      execute immediate 'select INSTANCE_NAME, HOST_NAME from v$instance'
			INTO lSid, lHost ;
	      IF ((upper(lSid) = upper(lServerName)) and (upper(lHost) = upper(lHostName))) THEN
		    return true;
	      ELSE
		   /* ERRNO := czError;
	    	   ERRBUF := CZ_UTILS.GET_TEXT('CZ_SOURCE_MISMATCH','SERVERNAME',lServerName,'DATABASE',lSid);
	  	   return false; */
		   RAISE DB_TNS_INCORRECT;
	      END IF;
         END IF;
	ELSE
	   /*
	   ERRNO := czError;
	   ERRBUF := CZ_UTILS.GET_TEXT('CZ_SOURCE_NOT_FOUND','SERVERNAME',lServerName);
	   xERROR := CZ_UTILS.REPORT(ERRBUF,1,'CZ_PUBL_SYNC_CRASH.VALIDATE_SERVER',11276);
	   return false;
	   */
	   RAISE SERVER_NOT_FOUND;
	END IF;
EXCEPTION
WHEN OTHERS THEN
	RAISE VALIDATE_SERVER_ERROR;
END verifyServer;

------------------------------------------------------------------------------------------

-- Validate if this is the source server based on if the source_server_flag is set.
FUNCTION checkIfSource(p_server_id	IN       NUMBER)
RETURN BOOLEAN
IS

	lServerId CZ_SERVERS.server_local_id%type;
	rServerId CZ_SERVERS.server_local_id%type;
	lServerName CZ_SERVERS.local_name%type;
	lName CZ_SERVERS.local_name%type;
	x_source_server_f BOOLEAN := FALSE;

	CURSOR c_source_servers IS
		SELECT local_name FROM CZ_SERVERS
		WHERE source_server_flag = '1'
		AND server_local_id = p_server_id;

	str varchar2(255);
BEGIN
/*	open c_source_servers;
	FETCH c_source_servers INTO lServerName;
		x_source_server_f:= c_source_servers%FOUND;
	close c_source_servers;
*/
	select fndnam_link_name into lName from CZ_SERVERS
	WHERE server_local_id = p_server_id;

	IF (lName is not NULL) THEN
	 lName := '@' || lName;
	   EXECUTE IMMEDIATE 'SELECT local_name, server_local_id FROM CZ_SERVERS' || lName ||
		' WHERE source_server_flag = ''1'' '
	   INTO lServerName, rServerId;

--	if (NOT(x_source_server_f)) then
	   IF (NOT(verifyServer(lName) ) ) THEN
		RAISE INCORRECT_SOURCE;
	   else
		return true;
	   end if;
	END IF;
EXCEPTION
   WHEN OTHERS THEN
	RAISE CZ_SYNC_ERROR;
END checkIfSource;

------------------------------------------------------------------------------------------

/* Deletes publication data from the source */


PROCEDURE DELETE_PUBLICATION_DATA (p_target_server_id	IN       NUMBER)
IS
-- xERROR BOOLEAN := FALSE;
--TYPE tPublicationIds             IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
--lPublicationIds                  tPublicationIds;
BEGIN
	UPDATE cz_model_publications
	SET deleted_flag = '1'
	WHERE server_id = p_target_server_id;

	DELETE FROM cz_pb_client_apps
	WHERE publication_id in (SELECT publication_id from cz_model_publications
					 where server_id = p_target_server_id);

	DELETE FROM cz_publication_usages
	WHERE  publication_id in (SELECT publication_id from cz_model_publications
					 where server_id = p_target_server_id);

	DELETE FROM cz_pb_languages
	WHERE  publication_id in (SELECT publication_id from cz_model_publications
					 where server_id = p_target_server_id);

	DELETE FROM cz_pb_model_exports
	WHERE  server_id = p_target_server_id;
	COMMIT;
EXCEPTION
  WHEN OTHERS THEN
	ERRNO := czError;
	ERRBUF := CZ_UTILS.GET_TEXT('SQLERRM');
    cz_utils.log_report(pkg_name, 'DELETE_PUBLICATION_DATA', null, ERRBUF, fnd_log.LEVEL_ERROR);
	RAISE DELETE_PUBLICATION_ERROR;
END DELETE_PUBLICATION_DATA ;

-----------------------------------------------------------------------------------------
/* Deletes publication data from the source */

/* not in use currently
PROCEDURE DELETE_PUBLICATION_DATA (p_target_server_id	IN NUMBER,
					     p_date			IN DATE default to_date('01/01/1970', 'mm/dd/yyyy') )
IS
-- xERROR BOOLEAN := FALSE;
--TYPE tPublicationIds             IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
--lPublicationIds                  tPublicationIds;

BEGIN
	UPDATE cz_model_publications
	SET deleted_flag = '1'
	WHERE server_id = p_target_server_id
	and model_last_updated > p_date;

	DELETE FROM cz_pb_client_apps
	WHERE publication_id in (SELECT publication_id from cz_model_publications
					 where server_id = p_target_server_id
					  and model_last_updated > p_date);

	DELETE FROM cz_publication_usages
	WHERE  publication_id in (SELECT publication_id from cz_model_publications
					 where server_id = p_target_server_id
					  and model_last_updated  > p_date);

	DELETE FROM cz_pb_languages
	WHERE  publication_id in (SELECT publication_id from cz_model_publications
					 where server_id = p_target_server_id
					  and model_last_updated  > p_date);

	DELETE FROM cz_pb_model_exports
	WHERE  server_id = p_target_server_id;
	COMMIT;
EXCEPTION
WHEN OTHERS THEN
	RAISE DELETE_PUBLICATION_ERROR;
END DELETE_PUBLICATION_DATA ;
*/
------------------------------------------------------------------------------------------
/* Deletes publication data from the source */

PROCEDURE DELETE_PUBLICATION ( p_publication_id 	IN NUMBER,
					 p_target_server_id	IN NUMBER DEFAULT 0,
					 p_link_name		IN VARCHAR2 DEFAULT NULL,
				       p_date			IN DATE)
IS
-- xERROR BOOLEAN := FALSE;
--TYPE tPublicationIds             IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
--lPublicationIds                  tPublicationIds;
lLinkName		VARCHAR2(255);
BEGIN
	/*
	IF (p_link_name <> NULL) THEN
		lLinkName = '@'||RTIM(LTRIM(p_link_name));
	END IF;
	*/

	EXECUTE IMMEDIATE
	'UPDATE cz_model_publications' || p_link_name ||
	' SET deleted_flag = ''1'' WHERE publication_id = :1 AND last_update_date > :2'
	USING p_publication_id, p_date;

	EXECUTE IMMEDIATE
	' DELETE FROM cz_pb_client_apps' || p_link_name ||
	' WHERE publication_id = :1'
	USING p_publication_id;

	EXECUTE IMMEDIATE
	' DELETE FROM cz_publication_usages' || p_link_name ||
	' WHERE  publication_id = :1'
	USING p_publication_id;

	EXECUTE IMMEDIATE
	' DELETE FROM cz_pb_languages' || p_link_name ||
	' WHERE  publication_id publication_id = :1'
	USING p_publication_id;

	EXECUTE IMMEDIATE
	' DELETE FROM cz_pb_model_exports' || p_link_name ||
	' WHERE  server_id = :1'
	USING p_target_server_id;

	COMMIT;

EXCEPTION
WHEN OTHERS THEN
	/*
	ERRNO := czError;
	ERRBUF := CZ_UTILS.GET_TEXT('SQLERRM');
	xERROR := CZ_UTILS.REPORT(ERRBUF,1,'CZ_PUBL_SYNC_CRASH.SYNC_ALL_SOURCE_CP',11276);
	*/
	RAISE DELETE_PUBLICATION_ERROR;
END DELETE_PUBLICATION;

------------------------------------------------------------------------------------------

/* Deletes publication data from the source and target */

PROCEDURE DELETE_DELETED_PUBLICATIONS ( p_server_id	IN NUMBER,
					          p_date	      IN DATE default to_date('01/01/1970', 'mm/dd/yyyy'))
IS
-- xERROR BOOLEAN := FALSE;
--TYPE tPublicationIds             IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
--lPublicationIds                  tPublicationIds;
lServerName 	CZ_SERVERS.local_name%type;
lLinkName 		CZ_SERVERS.fndnam_link_name%type;
lTargetServerId	CZ_SERVERS.server_local_id%type;
lSid			CZ_SERVERS.instance_name%type;
lHostName		CZ_SERVERS.hostname%type;
x_server_f BOOLEAN := FALSE;

TYPE t_publ_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
v_deleted_pub_tbl 		t_publ_tbl;
v_deleted_remote_pub_tbl 	t_publ_tbl;
v_pub_tbl 				t_publ_tbl;
v_remote_pub_tbl 			t_publ_tbl;
v_publication_id			CZ_MODEL_PUBLICATIONS.publication_id%type;

BEGIN

	SELECT fndnam_link_name, server_local_id INTO lLinkName, lServerName FROM CZ_SERVERS
		WHERE server_local_id = p_server_id;

	IF (lLinkName <> NULL) THEN
		lLinkName := '@' || LTRIM(RTRIM(lLinkName));
	END IF;

	/*
	EXECUTE IMMEDIATE
	' SELECT publication_id BULK COLLECT INTO ' || v_deleted_pub_tbl ||
        ' from cz_model_publications' || lLinkName ||
	' where deleted_flag = ''1''';

	IF (v_deleted_pub_tbl.COUNT > 0) THEN
	 FOR i IN v_deleted_pub_tbl.FIRST..v_deleted_pub_tbl.LAST
	 LOOP
 		DELETE_PUBLICATION(v_deleted_pub_tbl(i),p_server_id,lLinkName);
	 END LOOP;
	END IF;
	*/

	-- delete publications in source for which the target publication has been deleted
	SELECT publication_id, remote_publication_id
	BULK COLLECT INTO v_deleted_pub_tbl, v_deleted_remote_pub_tbl
      from cz_model_publications
	where deleted_flag = '1';

	IF (v_deleted_pub_tbl.COUNT > 0) THEN
	 FOR i IN v_deleted_pub_tbl.FIRST..v_deleted_pub_tbl.LAST
	 LOOP
		DELETE_PUBLICATION(v_deleted_remote_pub_tbl(i),p_server_id,lLinkName,p_date);
	 END LOOP;
	END IF;

	-- delete publications in target for which the source publication has been deleted
	SELECT publication_id
	BULK COLLECT INTO v_pub_tbl
      from cz_model_publications
	where deleted_flag = '0';

	IF (v_pub_tbl.COUNT > 0) THEN
	 FOR i IN v_pub_tbl.FIRST..v_pub_tbl.LAST
	 LOOP
		EXECUTE IMMEDIATE
		' SELECT publication_id INTO ' || v_publication_id ||
      	        ' from cz_model_publications' || lLinkName ||
		' where remote_publication_id = :1 and deleted_flag = ''1'''
		USING v_pub_tbl(i);

		IF (v_publication_id <> NULL) THEN
			DELETE_PUBLICATION(v_pub_tbl(i),0,NULL,p_date);
		END IF;
	 END LOOP;
	END IF;

	-- Delete all history for this target on the source.

	SELECT hostname, instance_name
	INTO lHostName, lSid
	FROM CZ_SERVERS
	WHERE server_local_id = '0';

	EXECUTE IMMEDIATE
	'SELECT SERVER_LOCAL_ID FROM CZ_SERVERS' || lLinkName ||
	' INTO ' || lTargetServerId ||
	' WHERE hostname = ' || lHostName ||
	' AND instance_name = ' || lSid;

	EXECUTE IMMEDIATE
	' DELETE FROM CZ_PB_MODEL_EXPORTS' || lLinkName ||
	' WHERE server_id = :1 AND last_update_date = :2'
	USING lTargetServerId, p_date;

	COMMIT;
EXCEPTION
WHEN OTHERS THEN
	/*
	ERRNO := czError;
	ERRBUF := CZ_UTILS.GET_TEXT('SQLERRM');
	xERROR := CZ_UTILS.REPORT(ERRBUF,1,'CZ_PUBL_SYNC_CRASH.SYNC_ALL_SOURCE_CP',11276);
	*/
	RAISE DELETE_DEL_PUBLICATION_ERROR;
END DELETE_DELETED_PUBLICATIONS ;
------------------------------------------------------------------------------------------
/* Check if the applicability parameters match for the publication and its remote publication */

FUNCTION checkApplicabilityParameters(publicationId IN NUMBER,
						  linkName      IN VARCHAR2)
RETURN boolean
IS
TYPE tPublLangs             IS TABLE OF cz_pb_languages.language%type INDEX BY BINARY_INTEGER;
lPublishedLanguages         tPublLangs ;
rPublishedLanguages         tPublLangs ;
TYPE tPublIds               IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
lPublUsages         	    tPublIds;
lPublApps         	    tPublIds;
rPublUsages         	    tPublIds;
rPublApps         	    tPublIds;
i				    NUMBER;
j				    NUMBER;
found				    BOOLEAN := FALSE;

BEGIN

   SELECT language BULK COLLECT INTO lPublishedLanguages
   FROM CZ_PB_LANGUAGES
   WHERE publication_id = publicationId;

   SELECT usage_id BULK COLLECT INTO lPublUsages
   FROM CZ_PUBLICATION_USAGES
   WHERE publication_id = publicationId;

   SELECT fnd_application_id BULK COLLECT INTO lPublApps
   FROM CZ_PB_CLIENT_APPS
   WHERE publication_id = publicationId;

   EXECUTE IMMEDIATE 'Begin SELECT language bulk collect INTO rPublishedLanguages FROM CZ_PB_LANGUAGES' || linkName || ' WHERE publication_id = publicationId; End;';

   EXECUTE IMMEDIATE 'Begin SELECT usage_id bulk collect INTO rPublUsages FROM CZ_PUBLICATION_USAGES' || linkName || ' WHERE publication_id = publicationId; End;';

   EXECUTE IMMEDIATE 'Begin SELECT fnd_application_id bulk collect INTO rPublApps FROM CZ_PB_CLIENT_APPS' || linkName || ' WHERE publication_id = publicationId; End;';

   IF (lPublishedLanguages.COUNT > 0) THEN
	FOR I IN lPublishedLanguages.FIRST..lPublishedLanguages.LAST
	LOOP
	   found	:= FALSE;
	   IF (rPublishedLanguages.COUNT > 0) THEN
		FOR J IN rPublishedLanguages.FIRST..rPublishedLanguages.LAST
		LOOP
		   IF (upper(lPublishedLanguages(i)) =  upper(rPublishedLanguages(j))) THEN
			found	:=	TRUE;
		   ELSE
			return false;
--			EXIT;
		   END IF;
		END LOOP;
         END IF;
	END LOOP;
   END IF;
   found := FALSE;

   IF (lPublUsages.COUNT > 0) THEN
	FOR I IN lPublUsages.FIRST..lPublUsages.LAST
	LOOP
	   found	:= FALSE;
	   IF (rPublUsages.COUNT > 0) THEN
		FOR J IN rPublUsages.FIRST..rPublUsages.LAST
		LOOP
		   IF (upper(lPublUsages(i)) =  upper(rPublUsages(j))) THEN
			found	:=	TRUE;
		   ELSE
			return false;
		   END IF;
		END LOOP;
         END IF;
	END LOOP;
   END IF;
   found := FALSE;

   IF (lPublApps.COUNT > 0) THEN
	FOR I IN lPublApps.FIRST..lPublApps.LAST
	LOOP
	   found	:= FALSE;
	   IF (rPublApps.COUNT > 0) THEN
		FOR J IN rPublApps.FIRST..rPublApps.LAST
		LOOP
		   IF (upper(lPublApps(i)) =  upper(rPublApps(j))) THEN
			found	:=	TRUE;
		   ELSE
			return false;
		   END IF;
		END LOOP;
         END IF;
	END LOOP;
   END IF;

return true;
END checkApplicabilityParameters;
------------------------------------------------------------------------------------------
/* Create publication data on source */

PROCEDURE CREATE_PUBLICATION_DATA ( errBuf 			IN OUT NOCOPY VARCHAR,
						p_target_server_id	IN NUMBER,
						x_count			IN OUT NOCOPY NUMBER)
IS
-- xERROR BOOLEAN := FALSE;
--TYPE tPublicationIds             IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
--lPublicationIds                  tPublicationIds;
	lServerName CZ_SERVERS.local_name%type;
	lLinkName CZ_SERVERS.fndnam_link_name%type;
	x_server_f BOOLEAN := FALSE;

	n_source_model_id 	cz_ps_nodes.ps_node_id%type;
	n_source_ui_def_id	cz_ui_nodes.ui_def_id%type;
	lCount			NUMBER;
	lPublicationId		cz_model_publications.publication_id%type;

	publications_cur	      REF_CURSOR;
	TYPE t_publ_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
	v_pub_tbl 				t_publ_tbl;

BEGIN

	SELECT fndnam_link_name INTO lLinkName FROM CZ_SERVERS
		WHERE server_local_id = p_target_server_id;

	IF (lLinkName is NOT  NULL) THEN
		lLinkName := '@' || LTRIM(RTRIM(lLinkName));
	END IF;

	-- insert into publication tables
	EXECUTE IMMEDIATE
	 'SELECT count(*) from cz_model_publications' || lLinkName || ' where source_model_id is null'
	  INTO lCount;
	x_count := lCount;

	if (lCount > 0) then
	begin
		OPEN publications_cur FOR ' SELECT publication_id FROM cz_model_publications'||lLinkName ||
					        ' WHERE deleted_flag = ''0'' ';
		LOOP
			lPublicationId := NULL;
		 	FETCH publications_cur INTO lPublicationId;
			EXIT WHEN publications_cur%NOTFOUND;

			BEGIN
			   -- Match applicability parameters. Call raparti's procedure here
			   IF (not(checkApplicabilityParameters(lPublicationId,lLinkName))) THEN
				RAISE APPLICABILITY_PARAM_ERR;
			   END IF;

			   -- resolve source_model_id
			   EXECUTE IMMEDIATE 'select pb.model_id into ' || n_source_model_id ||
				' from cz_model_publications' || lLinkName || ' pb, cz_ps_nodes' || lLinkName || ' ps, ' ||
				'cz_ps_nodes p ' ||
	  			'where pb.model_id = ps.ps_node_id ' ||
	  			'and pb.persistent_node_id = ps.persistent_node_id ' ||
	  			'and pb_source_model_id is null ' ||
	  			'and pb.persistent_node_id = p.persistent_node_id ' ||
	  			'and ps.name = p.name' ;
	  		exception
	     		when no_data_found then
				-- ERRNO := czError;
				ERRBUF := CZ_UTILS.GET_TEXT('CZ_SOURCE_MODEL_NOT_FOUND', 'PUBID', lPublicationId);
       cz_utils.log_report(pkg_name, 'CREATE_PUBLICATION_DATA', null, ERRBUF, fnd_log.LEVEL_ERROR);
				-- RAISE SOURCE_MODEL_NOT_FOUND;
	  		END;
			-- resolve source_ui_def_id
			BEGIN
	 			EXECUTE IMMEDIATE  'select pb.ui_def_id into ' || n_source_ui_def_id || ' ' ||
	  			'from cz_model_publications' || lLinkName || ' pb, cz_ui_nodes' || lLinkName || ' ui, ' ||
				'cz_ui_nodes u ' ||
	  			'where pb.ui_def_id = ui.ui_def_id ' ||
	  			'and pb.source_ui_def_id is null ' ||
	  			'and ui.persistent_node_id = u.persistent_ui_node_id ' ||
	  			'and u.parent_id is null ' ||
	  			'and ui.name = u.name' ;
			exception
	   		when no_data_found then
				-- ERRNO := czError;
				ERRBUF := CZ_UTILS.GET_TEXT('CZ_SOURCE_MODEL_NOT_FOUND', 'PUBID', lPublicationId);
       cz_utils.log_report(pkg_name, 'CREATE_PUBLICATION_DATA', null, ERRBUF, fnd_log.LEVEL_ERROR);
				-- RAISE SOURCE_UI_NOT_FOUND;
	   		when others then
				CLOSE publications_cur;
				ERRNO := czError;
				ERRBUF := CZ_UTILS.GET_TEXT('SQLERRM');
       cz_utils.log_report(pkg_name, 'CREATE_PUBLICATION_DATA', null, ERRBUF, fnd_log.LEVEL_ERROR);
			END;

			-- insert
			SELECT CZ_MODEL_PUBLICATIONS_S.NEXTVAL into lPublicationId from dual;
			EXECUTE IMMEDIATE
                        ' INSERT INTO cz_model_publications (PUBLICATION_ID ' ||
                             ' ,MODEL_ID ' ||
                             ' ,SERVER_ID ' ||
                             ' ,ORGANIZATION_ID ' ||
                             ' ,TOP_ITEM_ID ' ||
                             ' ,PRODUCT_KEY ' ||
                             ' ,PUBLICATION_MODE ' ||
                             ' ,UI_DEF_ID ' ||
                             ' ,UI_STYLE ' ||
                             ' ,APPLICABLE_FROM ' ||
                             ' ,APPLICABLE_UNTIL ' ||
                             ' ,EXPORT_STATUS ' ||
                             ' ,MODEL_PERSISTENT_ID ' ||
                             ' ,DELETED_FLAG ' ||
                             ' ,MODEL_LAST_STRUCT_UPDATE ' ||
                             ' ,MODEL_LAST_LOGIC_UPDATE ' ||
                             ' ,MODEL_LAST_UPDATED ' ||
                             ' ,CREATION_DATE ' ||
                             ' ,LAST_UPDATE_DATE ' ||
                             ' ,CREATED_BY ' ||
                             ' ,LAST_UPDATED_BY ' ||
                             ' ,SOURCE_TARGET_FLAG ' ||
                             ' ,REMOTE_PUBLICATION_ID ' ||
                             ' ) ' ||
                          ' VALUES   (SELECT lPublicationId ' ||
                             ' ,nvl(SOURCE_MODEL_ID,n_source_model_id) ' ||
                             ' ,p_target_server_id ' ||
                             ' ,ORGANIZATION_ID ' ||
                             ' ,TOP_ITEM_ID ' ||
                             ' ,PRODUCT_KEY ' ||
                             ' ,PUBLICATION_MODE ' ||
                             ' ,nvl(SOURCE_UI_DEF_ID,n_source_ui_def_id) ' ||
                             ' ,UI_STYLE ' ||
                             ' ,APPLICABLE_FROM ' ||
                             ' ,APPLICABLE_UNTIL ' ||
                             ' ,EXPORT_STATUS ' ||
                             ' ,MODEL_PERSISTENT_ID ' ||
                             ' ,DELETED_FLAG ' ||
                             ' ,MODEL_LAST_STRUCT_UPDATE ' ||
                             ' ,MODEL_LAST_LOGIC_UPDATE ' ||
                             ' ,MODEL_LAST_UPDATED ' ||
                             ' ,CREATION_DATE ' ||
                             ' ,LAST_UPDATE_DATE ' ||
                             ' ,CREATED_BY ' ||
                             ' ,LAST_UPDATED_BY ' ||
                             ' ,''S'' ' ||
                             ' ,PUBLICATION_ID ' ||
                             ' FROM CZ_MODEL_PUBLICATIONS' || lLinkName || ' remote ' ||
                             ' WHERE  cz_model_publications.remote_publication_id = remote.publication_id  ' ||
                           ' AND cz_model_publications.deleted_flag = ''1'' )';

			-- insert into other publication request tables
			EXECUTE IMMEDIATE
			' INSERT INTO CZ_PB_LANGUAGES( PUBLICATION_ID, LANGUAGE) VALUES (SELECT v_pub_tbl(i),language FROM CZ_PB_LANGUAGES'|| lLinkName || 'r ' ||
			' WHERE r.publication_id = lPublicationId';

			EXECUTE IMMEDIATE
			' INSERT INTO CZ_PB_CLIENT_APPS( PUBLICATION_ID, FND_APPLICATION_ID, APPLICATION_SHORT_NAME, NOTES) VALUES ' ||
                        ' (SELECT v_pub_tbl(i),FND_APPLICATION_ID, APPLICATION_SHORT_NAME, NOTES FROM CZ_PB_CLIENT_APPS'|| lLinkName || 'r ' ||
			' WHERE r.publication_id = lPublicationId';

			EXECUTE IMMEDIATE
			' INSERT INTO CZ_PUBLICATION_USAGES( PUBLICATION_ID, USAGE_ID) ' ||
			' VALUES (SELECT v_pub_tbl(i),usage_id FROM Z_PUBLICATION_USAGES'|| lLinkName || 'r ' ||
			' WHERE r.publication_id = lPublicationId';

		END LOOP;
		CLOSE publications_cur;
	END;
	END IF;

	-- Update remote_publication_id on target
	EXECUTE IMMEDIATE
	' update cz_model_publications'||lLinkName || ' t ' ||
	' set remote_publication_id = (select publication_id from cz_model_publications' ||
	' where remote_publication_id = t.publication_id' ||
	' and deleted_flag = ''0'')' ||
	' and deleted_flag = ''0'' ';

EXCEPTION
WHEN OTHERS THEN
	RAISE CREATE_PUBLICATION_ERROR;
	/*
	ERRNO := czError;
	ERRBUF := CZ_UTILS.GET_TEXT('SQLERRM');
	xERROR := CZ_UTILS.REPORT(ERRBUF,1,'CZ_PUBL_SYNC_CRASH.CREATE_PUBLICATION_DATA',11276);
	*/
END CREATE_PUBLICATION_DATA ;
------------------------------------------------------------------------------------------
/* Redo item/ property sequences */
PROCEDURE redo_sequences (p_target_server IN NUMBER)
IS

cursor c1 is
select value from CZ_DB_SETTINGS
where  setting_id='OracleSequenceIncr' and section_name='SCHEMA';
r_incr	    number;
r_item_val        number;
r_property_val    number;
r_item_type_val   number;
r_node_val        number;
r_ui_node_val     number;
incr_val	    number;
item_val        number;
property_val    number;
item_type_val   number;
ps_node_val     number;
ui_node_val     number;

lLinkName 	  CZ_SERVERS.fndnam_link_name%type;
WRONG_INCR    exception;

BEGIN

	EXECUTE IMMEDIATE
	' SELECT fndnam_link_name FROM CZ_SERVERS WHERE server_local_id = :1'
	INTO lLinkName
	USING p_target_server ;

	IF (lLinkName <> NULL) THEN
		lLinkName := '@' || LTRIM(RTRIM(lLinkName));
	END IF;

	OPEN c1;
	FETCH c1 INTO incr_val;
	IF (c1%notfound) THEN
		incr_val := 20;
		raise WRONG_INCR;
	END IF;
	CLOSE c1;

	EXECUTE IMMEDIATE
	'SELECT greatest (max(l.item_id),max(r.item_id)) INTO ' || item_val ||
	' FROM cz_item_masters' || lLinkName || ' r, cz_item_masters l';

	EXECUTE IMMEDIATE
	'SELECT greatest (max(l.item_type_id),max(r.item_type_id)) INTO ' || item_type_val ||
	' FROM cz_item_types' || lLinkName || ' r, cz_item_masters l' ;

	EXECUTE IMMEDIATE
	'SELECT greatest (max(l.property_id),max(r.property_id)) INTO ' || property_val ||
	' FROM cz_properties' || lLinkName || ' r, cz_item_masters l' ;

	EXECUTE IMMEDIATE
	'SELECT greatest (max(l.ps_node_id),max(r.ps_node_id)) INTO ' || ps_node_val ||
	' FROM cz_ps_nodes' || lLinkName || ' r, cz_item_masters l' ;

	EXECUTE IMMEDIATE
	'SELECT greatest (max(l.ui_node_id),max(r.ui_node_id)) INTO ' || ui_node_val ||
	' FROM cz_ui_nodes' || lLinkName || ' r, cz_item_masters l' ;

	/* drop sequences */
	EXECUTE IMMEDIATE 'DROP SEQUENCE cz_ps_nodes_s';
	EXECUTE IMMEDIATE 'DROP SEQUENCE cz_ui_nodes_s';
	EXECUTE IMMEDIATE 'DROP SEQUENCE cz_item_masters_s';
	EXECUTE IMMEDIATE 'DROP SEQUENCE cz_item_types_s';
	EXECUTE IMMEDIATE 'DROP SEQUENCE cz_properties_s';

	-- create sequences
	EXECUTE IMMEDIATE 'CREATE SEQUENCE cz_item_masters_s START WITH '|| item_val+incr_val ||
		' INCREMENT BY '|| incr_val || ' NOCACHE';
	EXECUTE IMMEDIATE 'CREATE SEQUENCE cz_item_types_s START WITH '|| item_type_val+incr_val ||
		' INCREMENT BY '|| incr_val || ' NOCACHE';
	EXECUTE IMMEDIATE 'CREATE SEQUENCE cz_ps_nodes_s START WITH '|| ps_node_val+incr_val ||
		' INCREMENT BY '|| incr_val || ' NOCACHE';
	EXECUTE IMMEDIATE 'CREATE SEQUENCE cz_ui_nodes_s START WITH '|| ui_node_val+incr_val ||
		' INCREMENT BY '|| incr_val || ' NOCACHE';
	EXECUTE IMMEDIATE 'CREATE SEQUENCE cz_properties_s START WITH '|| property_val+incr_val ||
		' INCREMENT BY '|| incr_val || ' NOCACHE';
EXCEPTION
WHEN OTHERS THEN
	RAISE REDO_SEQUENCE_ERROR;
	/*
	ERRNO := czError;
	ERRBUF := CZ_UTILS.GET_TEXT('SQLERRM');
	xERROR := CZ_UTILS.REPORT(ERRBUF,1,'CZ_PUBL_SYNC.REDO_SEQUENCES',11276);
	*/
END;
------------------------------------------------------------------------------------------
PROCEDURE republish_models (ERRNO			IN OUT NOCOPY  NUMBER,
				    ERRBUF			IN OUT NOCOPY  VARCHAR2,
				    p_source_server 	IN NUMBER,
				    okCount 		IN OUT NOCOPY  NUMBER,
				    errCount 		IN OUT NOCOPY  NUMBER,
				    commitYesNo         IN NUMBER DEFAULT 0)
IS
TYPE t_publ_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
v_pub_tbl 				t_publ_tbl;
v_remote_pub_tbl 			t_publ_tbl;
v_publication_id			CZ_MODEL_PUBLICATIONS.publication_id%type;

lLinkName 				CZ_SERVERS.fndnam_link_name%type;
x_run_id            		CZ_XFR_RUN_INFOS.run_id%type;
x_status            		CZ_MODEL_PUBLICATIONS.export_status%type;

ok_count 				NUMBER := 0;
err_count				NUMBER := 0;
lStartDate     			DATE := sysdate;
lEndDate       			DATE := sysdate;
BEGIN

	SELECT fndnam_link_name INTO lLinkName FROM CZ_SERVERS
		WHERE server_local_id = p_source_server;

	IF (lLinkName <> NULL) THEN
		lLinkName := '@' || LTRIM(RTRIM(lLinkName));
	END IF;

	SELECT publication_id, remote_publication_id
	BULK COLLECT INTO v_pub_tbl, v_remote_pub_tbl
      from cz_model_publications
	where deleted_flag = '0';

	IF (v_pub_tbl.COUNT > 0) THEN
	 FOR i IN v_pub_tbl.FIRST..v_pub_tbl.LAST
	 LOOP
		UPDATE CZ_MODEL_PUBLICATIONS SET export_status = PUBLICATION_PENDING
		WHERE export_status = PUBLICATION_OK
		AND deleted_flag = '0';

		x_status := NULL;
		IF (commitYesNo = 0 ) THEN
			CZ_PB_MGR.REPUBLISH_MODEL(v_pub_tbl(i),lStartDate,lEndDate,x_run_id,x_status);
			IF (x_status <> PUBLICATION_OK) THEN
				err_count := err_count + 1;
				ERRBUF := CZ_UTILS.GET_TEXT('CZ_REPUBLISH_ERROR','PUBL_ID',v_pub_tbl(i),'ERROR',SQLERRM);
        cz_utils.log_report(pkg_name, 'REPUBLISH_MODELS', null, ERRBUF, fnd_log.LEVEL_ERROR);
			ELSE
				ok_count := ok_count + 1;
			END IF;
		ELSE
			-- Republishing :Publication Id
			ERRBUF := CZ_UTILS.GET_TEXT('CZ_REPUBLISH','PUBL_ID',v_pub_tbl(i));
        cz_utils.log_report(pkg_name, 'REPUBLISH_MODELS', null, ERRBUF, fnd_log.LEVEL_ERROR);
		END IF;
	 END LOOP;
	END IF;
	okCount := ok_count;
	errCount := err_count;
EXCEPTION
WHEN OTHERS THEN
	okCount := ok_count;
	errCount := err_count;
	RAISE REPUBLISH_ERROR;
END;
------------------------------------------------------------------------------------------
PROCEDURE report_results (p_runId IN NUMBER,
				  p_programName IN VARCHAR2,
				  p_disposition IN VARCHAR2,
				  p_rec_status  IN VARCHAR2,
				  p_rec_count IN NUMBER)
IS
BEGIN
     INSERT INTO CZ_XFR_RUN_RESULTS (RUN_ID,IMP_TABLE,DISPOSITION,REC_STATUS,RECORDS)
     VALUES(p_runId,p_programName,p_disposition,p_rec_status,p_rec_count);
     COMMIT;
EXCEPTION
WHEN OTHERS THEN
	RAISE REPORT_RESULTS_ERROR;
END;
------------------------------------------------------------------------------------------

/* Validate if the serverId is the right source server */

FUNCTION ValidateSource(p_target_server_id	IN       NUMBER)
	RETURN BOOLEAN
IS

lLinkName CZ_SERVERS.FNDNAM_LINK_NAME%TYPE;
BEGIN

	if (checkIfSource(p_target_server_id)) then
--	  if(validateServer(p_target_server_id)) then
	  	return true;
--	  else
--		return false;
--	  end if;
	else
	  return false;
	end if;
EXCEPTION
   WHEN OTHERS THEN
   RAISE INCORRECT_SOURCE;
/*
	ERRNO := czError;
	ERRBUF := CZ_UTILS.GET_TEXT('CZ_INCORRECT_SOURCE');
	xERROR := CZ_UTILS.REPORT(ERRBUF,1,'CZ_PUBL_SYNC_CRASH.ValidateSource',11276);
*/
END ValidateSource;

------------------------------------------------------------------------------------------

/* Sync source instance with a single target instance */

PROCEDURE SYNC_SINGLE_SOURCE_CP(ERRNO			IN OUT NOCOPY  NUMBER,
					  ERRBUF			IN OUT NOCOPY  VARCHAR2,
					  p_run_id			IN OUT NOCOPY  NUMBER, -- DEFAULT NULL
					  p_target_server_id	IN       NUMBER)
IS
-- xERROR 		BOOLEAN := FALSE;
runId 		CZ_XFR_RUN_INFOS.RUN_ID%type;
okCount 		NUMBER := 0;
errCount		NUMBER := 0;
lServerName		CZ_SERVERS.local_name%type;
lLinkName		CZ_SERVERS.fndnam_link_name%type;

BEGIN
   SET_DBMS_INFO(pbSourceCrash);

   SELECT local_name,fndnam_link_name INTO lServerName, lLinkName
   FROM CZ_SERVERS
   WHERE server_local_id = p_target_server_id;

   IF (ValidateSource(p_target_server_id)) THEN
	BEGIN
	   -- get new run id if not there and insert record in cz_xfr_run_infos
	   IF (p_run_id = NULL) THEN
		SELECT CZ_XFR_RUN_INFOS_S.NEXTVAL INTO runId FROM DUAL;
	   	INSERT INTO CZ_XFR_RUN_INFOS (RUN_ID,STARTED,LAST_ACTIVITY,COMPLETED)
         	    SELECT runId,SYSDATE,SYSDATE,'0' FROM DUAL WHERE NOT EXISTS
         	    (SELECT 1 FROM CZ_XFR_RUN_INFOS WHERE RUN_ID = runId);
         	COMMIT;
	   ELSE
		-- should have been inserted by SYNC_ALL_SOURCE_CP
	      runId := p_run_id;
	   END IF;
	   -- delete and recreate publication data
	   DELETE_PUBLICATION_DATA (p_target_server_id);
	   CREATE_PUBLICATION_DATA (errBuf,p_target_server_id,okCount);
	   REDO_SEQUENCES(p_target_server_id);
	   REPORT_RESULTS(runId,pbSourceCrash,'I',czOk,okCount);
	END;
   ELSE
	RAISE INCORRECT_SOURCE;
   END IF;
   RESET_DBMS_INFO;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		ROLLBACK;
		ERRNO := czError;
		ERRBUF := CZ_UTILS.GET_TEXT(sqlerrm);
    cz_utils.log_report(pkg_name, 'SYNC_TARGET_CP', null, ERRBUF, fnd_log.LEVEL_ERROR);
		RESET_DBMS_INFO;
	WHEN INCORRECT_SOURCE THEN
		ROLLBACK;
		ERRNO := czError;
		ERRBUF := CZ_UTILS.GET_TEXT('CZ_SERVER_NOT_SOURCE','SERVERNAME',lServerName);
    cz_utils.log_report(pkg_name, 'SYNC_TARGET_CP', null, ERRBUF, fnd_log.LEVEL_ERROR);
		RESET_DBMS_INFO;
	WHEN CZ_SYNC_ERROR THEN
		ROLLBACK;
		ERRNO := czError;
		ERRBUF := CZ_UTILS.GET_TEXT('CZ_GENERAL_ERROR', 'ERRORTEXT', SQLERRM);
    cz_utils.log_report(pkg_name, 'SYNC_TARGET_CP', null, ERRBUF, fnd_log.LEVEL_ERROR);
		RESET_DBMS_INFO;
	WHEN SERVER_NOT_FOUND THEN
		ROLLBACK;
 	   	ERRNO := czError;
		ERRBUF := CZ_UTILS.GET_TEXT('CZ_SOURCE_NOT_FOUND','SERVERNAME',lServerName);
    cz_utils.log_report(pkg_name, 'SYNC_TARGET_CP', null, ERRBUF, fnd_log.LEVEL_ERROR);
		RESET_DBMS_INFO;
	WHEN DB_LINK_DOWN THEN
		ROLLBACK;
		ERRNO := czError;
		ERRBUF := CZ_UTILS.GET_TEXT('CZ_DB_LINK_IS_DOWN','LINK_NAME', lLinkName);
    cz_utils.log_report(pkg_name, 'SYNC_TARGET_CP', null, ERRBUF, fnd_log.LEVEL_ERROR);
		RESET_DBMS_INFO;
	WHEN DB_TNS_INCORRECT THEN
		ROLLBACK;
		ERRNO := czError;
		ERRBUF := CZ_UTILS.GET_TEXT('CZ_SOURCE_MISMATCH','SERVERNAME',lServerName);
    cz_utils.log_report(pkg_name, 'SYNC_TARGET_CP', null, ERRBUF, fnd_log.LEVEL_ERROR);
		RESET_DBMS_INFO;
	WHEN VALIDATE_SERVER_ERROR THEN
		ROLLBACK;
		ERRNO := czError;
		ERRBUF := CZ_UTILS.GET_TEXT(SQLERRM);
    cz_utils.log_report(pkg_name, 'SYNC_TARGET_CP', null, ERRBUF, fnd_log.LEVEL_ERROR);
		RESET_DBMS_INFO;
	WHEN DELETE_PUBLICATION_ERROR THEN
		ROLLBACK;
		ERRNO := czError;
		ERRBUF := CZ_UTILS.GET_TEXT('SQLERRM');
    cz_utils.log_report(pkg_name, 'SYNC_TARGET_CP', null, ERRBUF, fnd_log.LEVEL_ERROR);
		RESET_DBMS_INFO;
/*	WHEN SOURCE_MODEL_NOT_FOUND THEN
		ROLLBACK;
		ERRNO := czError;
		ERRBUF := CZ_UTILS.GET_TEXT('CZ_SOURCE_MODEL_NOT_FOUND', 'MODELID', n_Source_Model_Id);
    cz_utils.log_report(pkg_name, 'SYNC_TARGET_CP', null, ERRBUF, fnd_log.LEVEL_ERROR);
		RESET_DBMS_INFO;
	WHEN SOURCE_UI_NOT_FOUND THEN
		ROLLBACK;
		ERRNO := czError;
		ERRBUF := CZ_UTILS.GET_TEXT('CZ_UI_MODEL_NOT_FOUND', 'MODELID', n_Source_Model_Id);
    cz_utils.log_report(pkg_name, 'SYNC_TARGET_CP', null, ERRBUF, fnd_log.LEVEL_ERROR);
		RESET_DBMS_INFO;
*/
	WHEN CREATE_PUBLICATION_ERROR THEN
		ROLLBACK;
		ERRNO := czError;
		ERRBUF := CZ_UTILS.GET_TEXT('SQLERRM');
    cz_utils.log_report(pkg_name, 'SYNC_TARGET_CP', null, ERRBUF, fnd_log.LEVEL_ERROR);
		RESET_DBMS_INFO;
	WHEN REDO_SEQUENCE_ERROR THEN
		ROLLBACK;
 		ERRNO := czError;
		ERRBUF := CZ_UTILS.GET_TEXT('CZ_GENERAL_ERROR','ERRORTEXT', SQLERRM);
    cz_utils.log_report(pkg_name, 'SYNC_TARGET_CP', null, ERRBUF, fnd_log.LEVEL_ERROR);
		RESET_DBMS_INFO;
/*	WHEN WRONG_INCR THEN
		ERRNO := czWarning;
		ERRBUF := CZ_UTILS.GET_TEXT('CZ_NO_SEQ_INCREMENT_VAL');
    cz_utils.log_report(pkg_name, 'SYNC_TARGET_CP', null, ERRBUF, fnd_log.LEVEL_ERROR);
		RESET_DBMS_INFO;
*/
	WHEN REPORT_RESULTS_ERROR THEN
 		ERRNO := czWarning;
		ERRBUF := CZ_UTILS.GET_TEXT('CZ_GENERAL_ERROR','ERRORTEXT', SQLERRM);
    cz_utils.log_report(pkg_name, 'SYNC_TARGET_CP', null, ERRBUF, fnd_log.LEVEL_ERROR);
		RESET_DBMS_INFO;
  	WHEN OTHERS THEN
       	--'Unable to continue because of %ERRORTEXT'
		ROLLBACK;
		ERRNO := czError;
		ERRBUF := CZ_UTILS.GET_TEXT('CZ_GENERAL_ERROR', 'ERRORTEXT', SQLERRM);
    cz_utils.log_report(pkg_name, 'SYNC_TARGET_CP', null, ERRBUF, fnd_log.LEVEL_UNEXPECTED);
		RESET_DBMS_INFO;
END SYNC_SINGLE_SOURCE_CP;
------------------------------------------------------------------------------------------

/* Sync source with all target instances */
PROCEDURE SYNC_ALL_SOURCE_CP	 (ERRNO		IN OUT NOCOPY  NUMBER,
					  ERRBUF		IN OUT NOCOPY  VARCHAR2,
					  p_run_id		IN OUT NOCOPY  NUMBER)
IS
	l_server_id CZ_SERVERS.server_local_id%type;
	l_server_name CZ_SERVERS.local_name%type;
--	xError boolean := false;
	CURSOR c_get_all_remote_servers IS
		SELECT server_local_id, local_name FROM CZ_SERVERS;
BEGIN
	-- get new run id if not there and insert record in cz_xfr_run_infos
	IF (p_run_id = NULL) THEN
		SELECT CZ_XFR_RUN_INFOS_S.NEXTVAL INTO p_run_id FROM DUAL;
	END IF;
	INSERT INTO CZ_XFR_RUN_INFOS (RUN_ID,STARTED,LAST_ACTIVITY,COMPLETED)
         SELECT p_run_id,SYSDATE,SYSDATE,'0' FROM DUAL WHERE NOT EXISTS
         	(SELECT 1 FROM CZ_XFR_RUN_INFOS WHERE RUN_ID=p_run_id);
      COMMIT;
	OPEN c_get_all_remote_servers;
	LOOP
         BEGIN
		FETCH c_get_all_remote_servers INTO l_server_id, l_server_name;
		EXIT WHEN c_get_all_remote_servers%NOTFOUND;
			ERRBUF := CZ_UTILS.GET_TEXT('CZ_SOURCE_SYNC','SERVERNAME',l_server_name);
			CZ_PUBL_SYNC_CRASH.SYNC_SINGLE_SOURCE_CP(ERRNO,ERRBUF,p_run_id,l_server_id);
         EXCEPTION
           WHEN OTHERS THEN
		 ERRNO := 2;
		 ERRBUF := SQLERRM;
      cz_utils.log_report(pkg_name, 'SYNC_ALL_SOURCE_CP', null, ERRBUF, fnd_log.LEVEL_UNEXPECTED);
        END;
	END LOOP;
	CLOSE c_get_all_remote_servers;

END SYNC_ALL_SOURCE_CP;
------------------------------------------------------------------------------------------
PROCEDURE SYNC_TARGET_CP(ERRNO			IN OUT NOCOPY  NUMBER,
				 ERRBUF			IN OUT NOCOPY  VARCHAR2,
				 p_run_id			IN OUT NOCOPY  NUMBER,
				 p_source_server_id	IN       NUMBER,
				 p_date			IN	   DATE,
				 p_commitYesNo		IN 	   NUMBER DEFAULT 0)
IS
okCount 		NUMBER := 0;
errCount		NUMBER := 0;
lServerName		CZ_SERVERS.local_name%type;
lLinkName		CZ_SERVERS.fndnam_link_name%type;
inSourceServerId	CZ_SERVERS.server_local_id%type;
inDate 		DATE;
inCommitYesNo 	NUMBER;
runId			NUMBER;
BEGIN


   SET_DBMS_INFO(pbTargetCrash);

--   inSourceServerId := p_source_server_id;
   inDate 		:= p_date;
   inCommitYesNo 	:= p_commitYesNo;

   SELECT local_name,fndnam_link_name INTO lServerName, lLinkName
   FROM CZ_SERVERS
   WHERE server_local_id = p_source_server_id;

   -- Check if source server flag is set correctly
   IF (ValidateSource(p_source_server_id)) THEN
--	IF (ValidateTarget(p_source_server_id)) THEN
	  BEGIN
	   -- get new run id if not there and insert record in cz_xfr_run_infos
	   IF (p_run_id = NULL) THEN
		SELECT CZ_XFR_RUN_INFOS_S.NEXTVAL INTO runId FROM DUAL;
	   ELSE
	      runId := p_run_id;
	   END IF;
	   INSERT INTO CZ_XFR_RUN_INFOS (RUN_ID,STARTED,LAST_ACTIVITY,COMPLETED)
             SELECT runId,SYSDATE,SYSDATE,'0' FROM DUAL WHERE NOT EXISTS
             (SELECT 1 FROM CZ_XFR_RUN_INFOS WHERE RUN_ID=runId);
	   IF (inCommitYesNo = 0) THEN
         	COMMIT;
	   END IF;
	   -- Delete all deleted publications from source and target
	   DELETE_DELETED_PUBLICATIONS(p_source_server_id,inDate);
	   -- republish
	   REPUBLISH_MODELS(Errno,ErrBuf,p_source_server_id, okCount, errCount,inCommitYesNo);
	   -- log results  -- not sure what to use for Disposition ??
	   REPORT_RESULTS(runId,pbTargetCrash,'I',czOk,okCount);
	   REPORT_RESULTS(runId,pbTargetCrash,'I',czError,errCount);
	  END;
/*   	ELSE
	   ERRNO := czError;
		-- This instance is not the source for the selected Target server
	   ERRBUF := CZ_UTILS.GET_TEXT('CZ_SERVER_NOT_SOURCE');
      cz_utils.log_report(pkg_name, 'SYNC_TARGET_CP', null, ERRBUF, fnd_log.LEVEL_ERROR);
   	END IF;
**/
   ELSE
	ERRNO := czError;
	-- The selected Target's tns details do not match with that in CZ_SERVERS
	ERRBUF := CZ_UTILS.GET_TEXT('CZ_INCORRECT_TARGET');
      cz_utils.log_report(pkg_name, 'SYNC_TARGET_CP', null, ERRBUF, fnd_log.LEVEL_ERROR);
   END IF;
	IF (inCommitYesNo = 0) THEN
		COMMIT;
	END IF;
	RESET_DBMS_INFO;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		ROLLBACK;
		ERRNO := czError;
		ERRBUF := CZ_UTILS.GET_TEXT(sqlerrm);
      cz_utils.log_report(pkg_name, 'SYNC_TARGET_CP', null, ERRBUF, fnd_log.LEVEL_ERROR);
		RESET_DBMS_INFO;
	WHEN INCORRECT_SOURCE THEN
		ROLLBACK;
		ERRNO := czError;
		ERRBUF := CZ_UTILS.GET_TEXT('CZ_SERVER_NOT_SOURCE','SERVERNAME',lServerName);
      cz_utils.log_report(pkg_name, 'CHECK_IF_SOURCE', null, ERRBUF, fnd_log.LEVEL_ERROR);
		RESET_DBMS_INFO;
	WHEN CZ_SYNC_ERROR THEN
		ROLLBACK;
		ERRNO := czError;
		ERRBUF := CZ_UTILS.GET_TEXT('CZ_GENERAL_ERROR', 'ERRORTEXT', SQLERRM);
      cz_utils.log_report(pkg_name, 'CHECK_IF_SOURCE', null, ERRBUF, fnd_log.LEVEL_ERROR);
		RESET_DBMS_INFO;
	WHEN SERVER_NOT_FOUND THEN
		ROLLBACK;
 	   	ERRNO := czError;
		ERRBUF := CZ_UTILS.GET_TEXT('CZ_SOURCE_NOT_FOUND','SERVERNAME',lServerName);
      cz_utils.log_report(pkg_name, 'VALIDATE_SERVER', null, ERRBUF, fnd_log.LEVEL_ERROR);
		RESET_DBMS_INFO;
	WHEN DB_LINK_DOWN THEN
		ROLLBACK;
		ERRNO := czError;
		ERRBUF := CZ_UTILS.GET_TEXT('CZ_DB_LINK_IS_DOWN','LINK_NAME', lLinkName);
      cz_utils.log_report(pkg_name, 'VALIDATE_SERVER', null, ERRBUF, fnd_log.LEVEL_ERROR);
		RESET_DBMS_INFO;
	WHEN DB_TNS_INCORRECT THEN
		ROLLBACK;
		ERRNO := czError;
		ERRBUF := CZ_UTILS.GET_TEXT('CZ_SOURCE_MISMATCH','SERVERNAME',lServerName);
      cz_utils.log_report(pkg_name, 'VALIDATE_SERVER', null, ERRBUF, fnd_log.LEVEL_ERROR);
		RESET_DBMS_INFO;
	WHEN VALIDATE_SERVER_ERROR THEN
		ROLLBACK;
		ERRNO := czError;
		ERRBUF := CZ_UTILS.GET_TEXT(SQLERRM);
      cz_utils.log_report(pkg_name, 'VALIDATE_SERVER', null, ERRBUF, fnd_log.LEVEL_ERROR);
		RESET_DBMS_INFO;
 	WHEN TNS_INCORRECT THEN -- target validation
		ROLLBACK;
		ERRNO := czError;
		ERRBUF := CZ_UTILS.GET_TEXT('CZ_INCORRECT_TARGET','SERVERNAME',lServerName);
      cz_utils.log_report(pkg_name, 'VALIDATETARGET', null, ERRBUF, fnd_log.LEVEL_ERROR);
		RESET_DBMS_INFO;
	WHEN DELETE_DEL_PUBLICATION_ERROR THEN
		ROLLBACK;
		ERRNO := czError;
		ERRBUF := CZ_UTILS.GET_TEXT('SQLERRM');
      cz_utils.log_report(pkg_name, 'DELETE_DELETED_PUBLICATIONS', null, ERRBUF, fnd_log.LEVEL_ERROR);
		RESET_DBMS_INFO;
	WHEN DELETE_PUBLICATION_ERROR THEN
		ROLLBACK;
		ERRNO := czError;
		ERRBUF := CZ_UTILS.GET_TEXT('SQLERRM');
      cz_utils.log_report(pkg_name, 'DELETE_DELETED_PUBLICATIONS', null, ERRBUF, fnd_log.LEVEL_ERROR);
		RESET_DBMS_INFO;
	WHEN REPUBLISH_ERROR THEN
		ROLLBACK;
		ERRNO := czError;
		ERRBUF := CZ_UTILS.GET_TEXT('REPUBLISH_ERROR');
      cz_utils.log_report(pkg_name, 'REPUBLISH_MODELS', null, ERRBUF, fnd_log.LEVEL_ERROR);
		RESET_DBMS_INFO;
	WHEN REPORT_RESULTS_ERROR THEN
 		ERRNO := czWarning;
		ERRBUF := CZ_UTILS.GET_TEXT('CZ_GENERAL_ERROR','ERRORTEXT', SQLERRM);
      cz_utils.log_report(pkg_name, 'REDO_SEQUENCES', null, ERRBUF, fnd_log.LEVEL_ERROR);
		RESET_DBMS_INFO;
  	WHEN OTHERS THEN
       	--'Unable to continue because of %ERRORTEXT'
		ROLLBACK;
		ERRNO := czError;
		ERRBUF := CZ_UTILS.GET_TEXT('CZ_GENERAL_ERROR', 'ERRORTEXT', SQLERRM);
      cz_utils.log_report(pkg_name, 'SYNC_TARGET_CP', null, ERRBUF, fnd_log.LEVEL_UNEXPECTED);
		RESET_DBMS_INFO;
END;
------------------------------------------------------------------------------------------

/* Validate if the serverId is a valid target */

FUNCTION ValidateTarget(p_server_id	IN       NUMBER)
RETURN BOOLEAN
IS
lHost			CZ_SERVERS.hostname%type;
lSid			CZ_SERVERS.instance_name%type;
lLinkName		CZ_SERVERS.fndnam_link_name%type;
lHostName		CZ_SERVERS.hostname%type;
lServerName		CZ_SERVERS.instance_name%type;
BEGIN

	SELECT fndnam_link_name INTO lLinkName
	FROM CZ_SERVERS
	WHERE server_local_id = p_server_id;

	IF (lLinkName <> NULL) THEN
		lLinkName := '@' || lLinkName;
	END IF;

	EXECUTE IMMEDIATE
	' SELECT hostname, instance_name INTO ' || lHost || ',' || lSid ||
	' FROM CZ_SERVERS'|| lLinkName ||
	' WHERE source_server_flag = ''1''';

	SELECT INSTANCE_NAME, HOST_NAME INTO lServerName,lHostName from v$instance;
	IF ((upper(lSid) = upper(lServerName)) and (upper(lHost) = upper(lHostName))) THEN
		return true;
	ELSE
		/* ERRNO := czError;
		ERRBUF := CZ_UTILS.GET_TEXT('CZ_SOURCE_MISMATCH','SERVERNAME',lServerName,'DATABASE',lSid);
		return false; */
		RAISE TNS_INCORRECT;
	END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    cz_utils.log_report(pkg_name, 'SYNC_ALL_SOURCE_CP', null, ERRBUF, fnd_log.LEVEL_UNEXPECTED);
END;
------------------------------------------------------------------------------------------
PROCEDURE SYNC_TARGET_LIST_CP(ERRNO				IN OUT NOCOPY  NUMBER,
				      ERRBUF			IN OUT NOCOPY  VARCHAR2,
				 	p_run_id			IN OUT NOCOPY  NUMBER,
				 	p_source_server_id	IN       NUMBER,
				 	p_date			IN	   DATE)
IS
okCount 				NUMBER := 0;
errCount				NUMBER := 0;
lServerName		CZ_SERVERS.local_name%type;
BEGIN
	SYNC_TARGET_CP(ERRNO,ERRBUF,p_run_id,p_source_server_id,p_date,1);
END;
------------------------------------------------------------------------------------------
END CZ_PUBL_SYNC_CRASH;

/
