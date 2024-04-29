--------------------------------------------------------
--  DDL for Package Body CSM_LOBS_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_LOBS_EVENT_PKG" AS
/* $Header: csmelobb.pls 120.10.12010000.2 2010/04/08 06:44:33 saradhak ship $*/
--
-- To modify this template, edit file PKGBODY.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package body
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
   -- Enter procedure, function bodies as shown below

g_debug_level           NUMBER; -- debug level
g_pk1_name              CONSTANT VARCHAR2(30) := 'FILE_ID';
g_table_name            CONSTANT VARCHAR2(30) := 'CSF_M_LOBS';

TYPE Number_TAB   IS TABLE OF NUMBER 		  INDEX BY BINARY_INTEGER;
TYPE Varchar2_TAB IS TABLE OF VARCHAR2(255)   INDEX BY BINARY_INTEGER;

--Bug 4938130
PROCEDURE CONC_DOWNLOAD_ATTACHMENTS (p_status OUT NOCOPY VARCHAR2,
                                     p_message OUT NOCOPY VARCHAR2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
 l_pub_item VARCHAR2(30) := 'CSF_M_LOBS';
 l_prog_update_date jtm_con_request_data.last_run_date%TYPE;
 l_run_date 		date;
 l_sqlerrno 		varchar2(20);
 l_sqlerrmsg 		varchar2(2000);
 l_tab_access_id   ASG_DOWNLOAD.ACCESS_LIST;
 l_tab_user_id 	   ASG_DOWNLOAD.USER_LIST;
 l_publicationitemname VARCHAR2(50):= 'CSF_M_LOBS';
 l_tab_file_id 	   Number_TAB;
 l_tab_seq_num 	   Number_TAB;
 l_tab_name 	   Varchar2_TAB;
 l_tab_description Varchar2_TAB;
 l_tab_language    Varchar2_TAB;
 l_tab_entity_name Varchar2_TAB;
 l_tab_pk1_value   Varchar2_TAB;
 l_tab_pk2_value   Varchar2_TAB;
 l_tab_upd_user    Varchar2_TAB;
 l_tab_category    Varchar2_TAB;
 l_tab_usage_type  Varchar2_TAB;
 l_tab_data_type   Varchar2_TAB;
 l_dummy           BOOLEAN;
 l_tab_datatype_id Number_TAB;
 l_tab_document_id Number_TAB;
 l_tab_title      Varchar2_TAB;
--NOTE
--DATATYPE ID 1 = SHORT TEXT
--DATATYPE ID 5 = WEB PAGE (URL)
--DATATYPE ID 6 = LOBS
--Cursor to get the SR attachemnts
CURSOR l_SRAtt_csr
IS
SELECT csm_fnd_lobs_acc_s.NEXTVAL, fnddoc.media_id, acc.user_id,
       fnddoccat_tl.name, fnddoc_tl.description, fnddoc_tl.language,
       fndattdoc.entity_name, fndattdoc.pk1_value, fndattdoc.pk2_value,
       fndattdoc.seq_num,asg.user_name,fnddoccat_tl.user_name,
	   fnddoc.usage_type,doctype.user_name,fnddoc.datatype_id,
	   fnddoc.document_id,fnddoc_tl.title
FROM   fnd_documents_tl fnddoc_tl, fnd_documents fnddoc,
       fnd_document_categories_tl fnddoccat_tl,
       fnd_attached_documents fndattdoc,
--	   fnd_lobs lobs,
       csm_incidents_all_acc acc, asg_user asg,
	   FND_DOCUMENT_DATATYPES doctype
WHERE  fndattdoc.document_id = fnddoc_tl.document_id
AND    fnddoc_tl.language = asg.language
AND    asg.user_id=asg.owner_id
AND    fnddoc_tl.document_id = fnddoc.document_id
--AND    fnddoc.media_id = lobs.file_id(+)
AND    fnddoccat_tl.category_id = fnddoc.category_id
AND    fnddoccat_tl.language = asg.language
AND    fndattdoc.pk1_value = to_char(acc.incident_id)
AND    asg.user_id = acc.user_id
AND    fnddoccat_tl.name = 'MISC'
AND    fndattdoc.entity_name = 'CS_INCIDENTS'
AND    fnddoc.datatype_id in(1,5,6)
AND    doctype.datatype_id = fnddoc.datatype_id
AND    doctype.language = asg.language
AND    NOT EXISTS (SELECT 1 FROM CSM_FND_LOBS_ACC cflacc
                      WHERE cflacc.document_id = fnddoc.document_id
                      AND   cflacc.user_id = acc.user_id);

--Cursor to get the task attachemnts
CURSOR	 l_TaskAtt_csr
IS
SELECT csm_fnd_lobs_acc_s.NEXTVAL, fnddoc.media_id, acc.user_id,
       fnddoccat_tl.name, fnddoc_tl.description, fnddoc_tl.language,
       fndattdoc.entity_name, fndattdoc.pk1_value, fndattdoc.pk2_value,
       fndattdoc.seq_num,asg.user_name,fnddoccat_tl.user_name,
	   fnddoc.usage_type,doctype.user_name,fnddoc.datatype_id,
	   fnddoc.document_id,fnddoc_tl.title
FROM   fnd_documents_tl fnddoc_tl, fnd_documents fnddoc,
       fnd_document_categories_tl fnddoccat_tl,
       fnd_attached_documents fndattdoc,
--	   fnd_lobs lobs,
       csm_tasks_acc acc, asg_user asg,
	   FND_DOCUMENT_DATATYPES doctype
WHERE  fndattdoc.document_id = fnddoc_tl.document_id
AND    fnddoc_tl.language = asg.language
AND    fnddoc_tl.document_id = fnddoc.document_id
--AND    fnddoc.media_id  = lobs.file_id(+)
AND    fnddoccat_tl.category_id = fnddoc.category_id
AND    fnddoccat_tl.language = asg.language
AND    fndattdoc.pk1_value = to_char(acc.task_id)
AND    asg.user_id = acc.user_id
AND    asg.user_id=asg.owner_id
AND    fnddoccat_tl.name = 'MISC'
AND    fndattdoc.entity_name = 'JTF_TASKS_B'
AND    fnddoc.datatype_id in(1,5,6)
AND    doctype.datatype_id = fnddoc.datatype_id
AND    doctype.language = asg.language
AND    NOT EXISTS (SELECT 1 FROM CSM_FND_LOBS_ACC cflacc
                      WHERE cflacc.document_id = fnddoc.document_id
                      AND   cflacc.user_id = acc.user_id);

--Bug 5726888
  --Cursor to get the Signature attachemnts
    CURSOR c_Signature  IS
      SELECT  csm_fnd_lobs_acc_s.NEXTVAL, fnddoc.media_id, acc.user_id,
        fnddoccat_tl.name, fnddoc_tl.description, fnddoc_tl.language,
        fndattdoc.entity_name, fndattdoc.pk1_value, fndattdoc.pk2_value,
        fndattdoc.seq_num,asg.user_name,fnddoccat_tl.user_name,
   	    fnddoc.usage_type,doctype.user_name,fnddoc.datatype_id,
	    fnddoc.document_id,fnddoc_tl.title
      FROM fnd_documents_tl fnddoc_tl, fnd_documents fnddoc,
           fnd_document_categories_tl fnddoccat_tl,
           fnd_attached_documents fndattdoc,
--		   fnd_lobs lobs,
           csm_debrief_headers_acc acc, asg_user asg,
           FND_DOCUMENT_DATATYPES doctype
      WHERE fndattdoc.document_id = fnddoc_tl.document_id
      AND fnddoc_tl.language = asg.language
      AND fnddoc_tl.document_id = fnddoc.document_id
--      AND fnddoc.media_id = lobs.file_id
      AND fnddoccat_tl.category_id = fnddoc.category_id
      AND fnddoccat_tl.language = asg.language
      AND fndattdoc.pk1_value = to_char(acc.debrief_header_id)
      AND fnddoccat_tl.name = 'SIGNATURE'
      AND fndattdoc.entity_name = 'CSF_DEBRIEF_HEADERS'
      AND fnddoc.datatype_id =6
      AND doctype.datatype_id = fnddoc.datatype_id
      AND doctype.language = asg.language
      AND acc.user_id = asg.user_id
      AND asg.user_id=asg.owner_id
      AND NOT EXISTS (SELECT 1 FROM CSM_FND_LOBS_ACC cflacc
                      WHERE cflacc.document_id = fnddoc.document_id
                      AND   cflacc.user_id = acc.user_id);

 CURSOR c_ha_parent_pld_id(b_pk_value NUMBER)
 IS
 SELECT MAX(HA_PAYLOAD_ID)
 FROM CSM_HA_PAYLOAD_DATA
 WHERE OBJECT_NAME='FND_DOCUMENTS'
 AND PK_VALUE=b_pk_value;

 l_ha_pld_id NUMBER;
 l_ha_mode VARCHAR2(20);

BEGIN
    l_ha_mode:= CSM_HA_SERVICE_PUB.GET_HA_STATUS;

    IF(l_ha_mode='HA_RECORD') THEN
     CSM_UTIL_PKG.LOG( 'HA Tracking of Attachments','CSM_LOBS_EVENT_PKG.CONC_DOWNLOAD_ATTACHMENTS', FND_LOG.LEVEL_PROCEDURE);
	 CSM_HA_EVENT_PKG.TRACK_HA_ATTACHMENTS;
	END IF;

	-- data program is run
 	l_run_date := SYSDATE;
   /*** get debug level ***/
   g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;
   IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
      ( 0
      , g_table_name
      , 'Entering CONC_DOWNLOAD_ATTACHMENTS'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
      );
    END IF;

    --Emptying all lists.
 	l_tab_access_id.delete;
 	l_tab_user_id.delete;
 	l_tab_file_id.delete;
 	l_tab_name.delete;
 	l_tab_description.delete;
 	l_tab_language.delete;
 	l_tab_entity_name.delete;
 	l_tab_pk1_value.delete;
 	l_tab_pk2_value.delete;
 	l_tab_seq_num.delete;
    l_tab_upd_user.delete;
    l_tab_category.delete;
    l_tab_usage_type.delete;
    l_tab_data_type.delete;
	l_tab_datatype_id.delete;
    l_tab_document_id.delete;
    l_tab_title.delete;

     --If the max size of attachment is less than 1, then exit.
    IF (TO_NUMBER(FND_PROFILE.Value('CSM_MAX_ATTACHMENT_SIZE')) < 1) THEN
      /*Update the last run date*/
      UPDATE jtm_con_request_data SET last_run_date = l_run_date
       WHERE package_name =  'CSM_LOBS_EVENT_PKG'
       AND   procedure_name = 'CONC_DOWNLOAD_ATTACHMENTS';

      COMMIT;

      p_status := 'FINE';
      p_message :=  'CSM_LOBS_EVENT_PKG.CONC_DOWNLOAD_ATTACHMENTS '
                 || ' Executed successfully';

      IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
        jtm_message_log_pkg.Log_Msg
        ( 0
        , g_table_name
        , 'Leaving CONC_DOWNLOAD_ATTACHMENTS - Max att download size is less than 1'
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
        );
      END IF;
      RETURN;
    END IF;


    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( 0
      , g_table_name
      , 'Downloading Attachments for SRs'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
      );
    END IF;

--- DOWNLOAD SR ATTACHMENTS
    OPEN l_SRAtt_csr;
    FETCH l_SRAtt_csr BULK COLLECT INTO l_tab_access_id, l_tab_file_id, l_tab_user_id, l_tab_name,
      l_tab_description, l_tab_language, l_tab_entity_name, l_tab_pk1_value,
      l_tab_pk2_value, l_tab_seq_num,l_tab_upd_user,l_tab_category,l_tab_usage_type,l_tab_data_type,
	  l_tab_datatype_id,l_tab_document_id,l_tab_title;
    CLOSE l_SRAtt_csr;

    IF l_tab_access_id.COUNT > 0 THEN
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
       jtm_message_log_pkg.Log_Msg
        ( 0
        , g_table_name
        , 'Pushing ' || l_tab_access_id.COUNT || ' updated record(s)'
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
       );
      END IF;

      FORALL i in l_tab_access_id.FIRST .. l_tab_access_id.LAST
        INSERT INTO CSM_FND_LOBS_ACC
			   		(access_id,  file_id,  	  user_id,     name,	    description,
					language, 	 entity_name, pk1_value,   pk2_value, 	seq_num,
					update_user, category, 	  usage_type,  data_type,	counter,
					last_update_date, last_updated_by,     creation_date,created_by, data_type_id,
					document_id,title)
          VALUES    (l_tab_access_id(i),  l_tab_file_id(i), 	l_tab_user_id(i),   l_tab_name(i),      l_tab_description(i),
		  			 l_tab_language(i),   l_tab_entity_name(i), l_tab_pk1_value(i), l_tab_pk2_value(i), l_tab_seq_num(i),
					 l_tab_upd_user(i),   l_tab_category(i),	l_tab_usage_type(i),l_tab_data_type(i), 1,
					 sysdate, 			  1, 					sysdate, 			1, 					l_tab_datatype_id(i),
					 l_tab_document_id(i),l_tab_title(i));

    IF(l_ha_mode='HA_RECORD') THEN
	    FOR I IN 1..l_tab_access_id.COUNT
		LOOP
		 OPEN c_ha_parent_pld_id(l_tab_document_id(i));
		 FETCH c_ha_parent_pld_id INTO l_ha_pld_id;
		 CLOSE c_ha_parent_pld_id;
		 CSM_HA_EVENT_PKG.G_CURRENT_PAYLOAD_ID:=l_ha_pld_id;

         l_dummy := asg_download.mark_dirty(
              P_PUB_ITEM     => l_publicationitemname
            , P_ACCESSID   => l_tab_access_id(I)
            , P_USERID => l_tab_user_id(I)
            , P_DML    => 'I'
            , P_TIMESTAMP    => SYSDATE);
		END LOOP;
	  ELSE
        --do markdiry for all the selected records
        l_dummy := asg_download.mark_dirty(
            P_PUB_ITEM     => l_publicationitemname
            , P_ACCESSLIST   => l_tab_access_id
            , P_USERID_LIST => l_tab_user_id
            , P_DML_TYPE     => 'I'
            , P_TIMESTAMP    => SYSDATE);
	  END IF;

    COMMIT;

    END IF;

--Emptying all lists.
 	l_tab_access_id.delete;
 	l_tab_user_id.delete;
 	l_tab_file_id.delete;
 	l_tab_name.delete;
 	l_tab_description.delete;
 	l_tab_language.delete;
 	l_tab_entity_name.delete;
 	l_tab_pk1_value.delete;
 	l_tab_pk2_value.delete;
 	l_tab_seq_num.delete;
    l_tab_upd_user.delete;
    l_tab_category.delete;
    l_tab_usage_type.delete;
    l_tab_data_type.delete;
	l_tab_datatype_id.delete;
    l_tab_document_id.delete;
	l_tab_title.delete;

--- DOWNLOAD TASK ATTACHMENTS
    OPEN l_TaskAtt_csr;
    FETCH l_TaskAtt_csr BULK COLLECT INTO l_tab_access_id, l_tab_file_id, l_tab_user_id, l_tab_name,
      l_tab_description, l_tab_language, l_tab_entity_name, l_tab_pk1_value,
      l_tab_pk2_value, l_tab_seq_num,l_tab_upd_user,l_tab_category,l_tab_usage_type,l_tab_data_type,
	  l_tab_datatype_id,l_tab_document_id,l_tab_title;
    CLOSE l_TaskAtt_csr;

    IF l_tab_access_id.COUNT > 0 THEN
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
       jtm_message_log_pkg.Log_Msg
        ( 0
        , g_table_name
        , 'Pushing ' || l_tab_access_id.COUNT || ' updated record(s)'
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
       );
      END IF;
--insert the rows into access table
      FORALL i in l_tab_access_id.FIRST .. l_tab_access_id.LAST
        INSERT INTO CSM_FND_LOBS_ACC
			   		(access_id,  file_id,  	  user_id,     name,	    description,
					language, 	 entity_name, pk1_value,   pk2_value, 	seq_num,
					update_user, category, 	  usage_type,  data_type,	counter,
					last_update_date, last_updated_by,     creation_date,created_by, data_type_id,
					document_id,title)
          VALUES    (l_tab_access_id(i),  l_tab_file_id(i), 	l_tab_user_id(i),   l_tab_name(i),      l_tab_description(i),
		  			 l_tab_language(i),   l_tab_entity_name(i), l_tab_pk1_value(i), l_tab_pk2_value(i), l_tab_seq_num(i),
					 l_tab_upd_user(i),   l_tab_category(i),	l_tab_usage_type(i),l_tab_data_type(i), 1,
					 sysdate, 			  1, 					sysdate, 			1, 					l_tab_datatype_id(i),
					 l_tab_document_id(i),l_tab_title(i));

    IF(l_ha_mode='HA_RECORD') THEN
	    FOR I IN 1..l_tab_access_id.COUNT
		LOOP
		 OPEN c_ha_parent_pld_id(l_tab_document_id(i));
		 FETCH c_ha_parent_pld_id INTO l_ha_pld_id;
		 CLOSE c_ha_parent_pld_id;

		 CSM_HA_EVENT_PKG.G_CURRENT_PAYLOAD_ID:=l_ha_pld_id;

         l_dummy := asg_download.mark_dirty(
              P_PUB_ITEM     => l_publicationitemname
            , P_ACCESSID   => l_tab_access_id(I)
            , P_USERID => l_tab_user_id(I)
            , P_DML     => 'I'
            , P_TIMESTAMP    => SYSDATE);
		END LOOP;
	  ELSE
         l_dummy := asg_download.mark_dirty(
              P_PUB_ITEM     => l_publicationitemname
            , P_ACCESSLIST   => l_tab_access_id
            , P_USERID_LIST => l_tab_user_id
            , P_DML_TYPE     => 'I'
            , P_TIMESTAMP    => SYSDATE);
	  END IF;

    COMMIT;

	END IF;

--Bug 5726888
--Emptying all lists.
 	l_tab_access_id.delete;
 	l_tab_user_id.delete;
 	l_tab_file_id.delete;
 	l_tab_name.delete;
 	l_tab_description.delete;
 	l_tab_language.delete;
 	l_tab_entity_name.delete;
 	l_tab_pk1_value.delete;
 	l_tab_pk2_value.delete;
 	l_tab_seq_num.delete;
    l_tab_upd_user.delete;
    l_tab_category.delete;
    l_tab_usage_type.delete;
    l_tab_data_type.delete;
	l_tab_datatype_id.delete;
    l_tab_document_id.delete;
	l_tab_title.delete;

--- DOWNLOAD SIGNATURE ATTACHMENTS
    OPEN c_Signature;
    FETCH c_Signature BULK COLLECT INTO l_tab_access_id, l_tab_file_id, l_tab_user_id, l_tab_name,
      l_tab_description, l_tab_language, l_tab_entity_name, l_tab_pk1_value,
      l_tab_pk2_value, l_tab_seq_num,l_tab_upd_user,l_tab_category,l_tab_usage_type,l_tab_data_type,
	  l_tab_datatype_id,l_tab_document_id,l_tab_title;
    CLOSE c_Signature;

    IF l_tab_access_id.COUNT > 0 THEN
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
       jtm_message_log_pkg.Log_Msg
        ( 0
        , g_table_name
        , 'Pushing ' || l_tab_access_id.COUNT || ' updated record(s)'
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
       );
      END IF;
--insert the rows into access table
      FORALL i in l_tab_access_id.FIRST .. l_tab_access_id.LAST
        INSERT INTO CSM_FND_LOBS_ACC
			   		(access_id,  file_id,  	  user_id,     name,	    description,
					language, 	 entity_name, pk1_value,   pk2_value, 	seq_num,
					update_user, category, 	  usage_type,  data_type,	counter,
					last_update_date, last_updated_by,     creation_date,created_by, data_type_id,
					document_id,title)
          VALUES    (l_tab_access_id(i),  l_tab_file_id(i), 	l_tab_user_id(i),   l_tab_name(i),      l_tab_description(i),
		  			 l_tab_language(i),   l_tab_entity_name(i), l_tab_pk1_value(i), l_tab_pk2_value(i), l_tab_seq_num(i),
					 l_tab_upd_user(i),   l_tab_category(i),	l_tab_usage_type(i),l_tab_data_type(i), 1,
					 sysdate, 			  1, 					sysdate, 			1, 					l_tab_datatype_id(i),
					 l_tab_document_id(i),l_tab_title(i));

    IF(l_ha_mode='HA_RECORD') THEN
	    FOR I IN 1..l_tab_access_id.COUNT
		LOOP
		 OPEN c_ha_parent_pld_id(l_tab_document_id(i));
		 FETCH c_ha_parent_pld_id INTO l_ha_pld_id;
		 CLOSE c_ha_parent_pld_id;
		 CSM_HA_EVENT_PKG.G_CURRENT_PAYLOAD_ID:=l_ha_pld_id;

         l_dummy := asg_download.mark_dirty(
              P_PUB_ITEM     => l_publicationitemname
            , P_ACCESSID     => l_tab_access_id(I)
            , P_USERID       => l_tab_user_id(I)
            , P_DML          => 'I'
            , P_TIMESTAMP    => SYSDATE);
		END LOOP;
	  ELSE
        l_dummy := asg_download.mark_dirty(
           	 P_PUB_ITEM     => l_publicationitemname
           , P_ACCESSLIST   => l_tab_access_id
           , P_USERID_LIST => l_tab_user_id
           , P_DML_TYPE     => 'I'
           , P_TIMESTAMP    => SYSDATE);
     END IF;
    COMMIT;

	END IF;


  -- set the program update date in jtm_con_request_data to sysdate
  UPDATE jtm_con_request_data
  SET last_run_date = l_run_date
  WHERE package_name = 'CSM_LOBS_EVENT_PKG'
    AND procedure_name = 'CONC_DOWNLOAD_ATTACHMENTS';

 COMMIT;

   p_status := 'FINE';
   p_message :=  'CSM_LOBS_EVENT_PKG.CONC_DOWNLOAD_ATTACHMENTS'||' Executed successfully';

 EXCEPTION
  WHEN others THEN
     l_sqlerrno := to_char(SQLCODE);
     l_sqlerrmsg := substr(SQLERRM, 1,2000);
     p_status := 'ERROR';
     p_message := 'Error in '||
                  'CSM_LOBS_EVENT_PKG.CONC_DOWNLOAD_ATTACHMENTS: ' || l_sqlerrno || ':' || l_sqlerrmsg;
     CSM_UTIL_PKG.LOG('CSM_CSI_ITEM_ATTR_EVENT_PKG ERROR : ' || l_sqlerrno || ':' || l_sqlerrmsg, 'CSM_CSI_ITEM_ATTR_EVENT_PKG.Refresh_acc',FND_LOG.LEVEL_EXCEPTION);
	 ROLLBACK;
END CONC_DOWNLOAD_ATTACHMENTS;

--Bug 4938130
PROCEDURE INSERT_ALL_ACC_RECORDS (p_user_id IN NUMBER )
IS
    --Cursor to get the SR attachemnts
    CURSOR c_SRAtt (b_user_id NUMBER) IS
      SELECT csm_fnd_lobs_acc_s.NEXTVAL, fnddoc.media_id, acc.user_id,
             fnddoccat_tl.name, fnddoc_tl.description, fnddoc_tl.language,
             fndattdoc.entity_name, fndattdoc.pk1_value, fndattdoc.pk2_value,
             fndattdoc.seq_num,asg.user_name,fnddoccat_tl.user_name,
             fnddoc.usage_type,doctype.user_name,fnddoc.datatype_id,
	   		 fnddoc.document_id,fnddoc_tl.title
      FROM   fnd_documents_tl fnddoc_tl, fnd_documents fnddoc,
             fnd_document_categories_tl fnddoccat_tl,
             fnd_attached_documents fndattdoc,
--			 fnd_lobs lobs,
             csm_incidents_all_acc acc, asg_user asg,
             FND_DOCUMENT_DATATYPES doctype
      WHERE  fndattdoc.document_id = fnddoc_tl.document_id
      AND    fnddoc_tl.language = asg.language
      AND    fnddoc_tl.document_id = fnddoc.document_id
--      AND    fnddoc.media_id  = lobs.file_id (+)
      AND    fnddoccat_tl.category_id = fnddoc.category_id
      AND    fnddoccat_tl.language = asg.language
      AND    fndattdoc.pk1_value = to_char(acc.incident_id)
      AND    asg.user_id = acc.user_id
      AND    fnddoccat_tl.name = 'MISC'
      AND    fndattdoc.entity_name = 'CS_INCIDENTS'
      AND    fnddoc.datatype_id in (1,5,6)
      AND    doctype.datatype_id = fnddoc.datatype_id
      AND    doctype.language = asg.language
      AND    acc.user_id = b_user_id;

    --Cursor to get the task attachemnts
    CURSOR c_TaskAtt (b_user_id NUMBER) IS
      SELECT  csm_fnd_lobs_acc_s.NEXTVAL, fnddoc.media_id, acc.user_id,
        fnddoccat_tl.name, fnddoc_tl.description, fnddoc_tl.language,
        fndattdoc.entity_name, fndattdoc.pk1_value, fndattdoc.pk2_value,
        fndattdoc.seq_num,asg.user_name,fnddoccat_tl.user_name,
   	    fnddoc.usage_type,doctype.user_name,fnddoc.datatype_id,
	    fnddoc.document_id,fnddoc_tl.title
      FROM fnd_documents_tl fnddoc_tl, fnd_documents fnddoc,
           fnd_document_categories_tl fnddoccat_tl,
           fnd_attached_documents fndattdoc,
--		   fnd_lobs lobs,
           csm_tasks_acc acc, asg_user asg,
           FND_DOCUMENT_DATATYPES doctype
      WHERE fndattdoc.document_id = fnddoc_tl.document_id
      AND fnddoc_tl.language = asg.language
      AND fnddoc_tl.document_id = fnddoc.document_id
--      AND fnddoc.media_id  = lobs.file_id (+)
      AND fnddoccat_tl.category_id = fnddoc.category_id
      AND fnddoccat_tl.language = asg.language
      AND fndattdoc.pk1_value = to_char(acc.task_id)
      AND asg.user_id = acc.user_id
      AND fnddoccat_tl.name = 'MISC'
      AND fndattdoc.entity_name = 'JTF_TASKS_B'
      AND fnddoc.datatype_id in (1,5,6)
      AND doctype.datatype_id = fnddoc.datatype_id
      AND doctype.language = asg.language
      AND acc.user_id = b_user_id;

    --Cursor to get the Signature attachemnts
    CURSOR c_Signature (b_user_id NUMBER) IS
      SELECT  csm_fnd_lobs_acc_s.NEXTVAL, fnddoc.media_id, acc.user_id,
        fnddoccat_tl.name, fnddoc_tl.description, fnddoc_tl.language,
        fndattdoc.entity_name, fndattdoc.pk1_value, fndattdoc.pk2_value,
        fndattdoc.seq_num,asg.user_name,fnddoccat_tl.user_name,
   	    fnddoc.usage_type,doctype.user_name,fnddoc.datatype_id,
	    fnddoc.document_id,fnddoc_tl.title
      FROM fnd_documents_tl fnddoc_tl, fnd_documents fnddoc,
           fnd_document_categories_tl fnddoccat_tl,
           fnd_attached_documents fndattdoc,
--		   fnd_lobs lobs,
           csm_debrief_headers_acc acc, asg_user asg,
           FND_DOCUMENT_DATATYPES doctype
      WHERE fndattdoc.document_id = fnddoc_tl.document_id
      AND fnddoc_tl.language = asg.language
      AND fnddoc_tl.document_id = fnddoc.document_id
--      AND fnddoc.media_id = lobs.file_id
      AND fnddoccat_tl.category_id = fnddoc.category_id
      AND fnddoccat_tl.language = asg.language
      AND fndattdoc.pk1_value = to_char(acc.debrief_header_id)
      AND asg.user_id = b_user_id
      AND fnddoccat_tl.name = 'SIGNATURE'
      AND fndattdoc.entity_name = 'CSF_DEBRIEF_HEADERS'
      AND fnddoc.datatype_id =6
      AND doctype.datatype_id = fnddoc.datatype_id
      AND doctype.language = asg.language
      AND acc.user_id = asg.user_id;

   l_dummy        	  BOOLEAN;
   l_publicationitemname VARCHAR2(50):= 'CSF_M_LOBS';
   l_tab_access_id   ASG_DOWNLOAD.ACCESS_LIST;
   l_tab_user_id 	 ASG_DOWNLOAD.USER_LIST;

   l_tab_file_id 	 Number_TAB;
   l_tab_seq_num 	 Number_TAB;
   l_tab_name 		 Varchar2_TAB;
   l_tab_description Varchar2_TAB;
   l_tab_language 	 Varchar2_TAB;
   l_tab_entity_name Varchar2_TAB;
   l_tab_pk1_value 	 Varchar2_TAB;
   l_tab_pk2_value 	 Varchar2_TAB;
   l_tab_upd_user    Varchar2_TAB;
   l_tab_category    Varchar2_TAB;
   l_tab_usage_type  Varchar2_TAB;
   l_tab_data_type   Varchar2_TAB;
   l_tab_datatype_id Number_TAB;
   l_tab_document_id Number_TAB;
   l_tab_title      Varchar2_TAB;

   x_return_status	 varchar2(2000);
BEGIN

    /*** get debug level ***/
    g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;
    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( 0
      , g_table_name
      , 'Entering INSERT_ALL_ACC_RECORDS'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
      );
    END IF;
	--Empty  the access table for the user before insert it freshly
	--bug 5213097
    DELETE FROM CSM_FND_LOBS_ACC   WHERE user_id = p_user_id;

    --SIGNATURE
    l_tab_access_id.delete;
    l_tab_user_id.delete;
    l_tab_file_id.delete;
    l_tab_name.delete;
    l_tab_description.delete;
    l_tab_language.delete;
    l_tab_entity_name.delete;
    l_tab_pk1_value.delete;
    l_tab_pk2_value.delete;
    l_tab_seq_num.delete;
    l_tab_upd_user.delete;
    l_tab_category.delete;
    l_tab_usage_type.delete;
    l_tab_data_type.delete;
	l_tab_datatype_id.delete;
    l_tab_document_id.delete;
	l_tab_title.delete;

    OPEN c_Signature(p_user_id);
    FETCH c_Signature BULK COLLECT INTO l_tab_access_id, l_tab_file_id, l_tab_user_id, l_tab_name,
      l_tab_description, l_tab_language, l_tab_entity_name, l_tab_pk1_value,
      l_tab_pk2_value, l_tab_seq_num,l_tab_upd_user,l_tab_category,l_tab_usage_type,l_tab_data_type,
	  l_tab_datatype_id,l_tab_document_id,l_tab_title;
    CLOSE c_Signature;

    IF l_tab_access_id.COUNT > 0 THEN
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
       jtm_message_log_pkg.Log_Msg
        ( 0
        , g_table_name
        , 'Pushing ' || l_tab_access_id.COUNT || ' updated record(s)'
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
       );
      END IF;

      FORALL i in l_tab_access_id.FIRST .. l_tab_access_id.LAST
        INSERT INTO CSM_FND_LOBS_ACC
   			   		(access_id,  file_id,  	  user_id,     name,	    description,
					language, 	 entity_name, pk1_value,   pk2_value, 	seq_num,
					update_user, category, 	  usage_type,  data_type,	counter,
					last_update_date, last_updated_by,     creation_date,created_by, data_type_id,
					document_id,title)
          VALUES    (l_tab_access_id(i),  l_tab_file_id(i), 	l_tab_user_id(i),   l_tab_name(i),      l_tab_description(i),
		  			 l_tab_language(i),   l_tab_entity_name(i), l_tab_pk1_value(i), l_tab_pk2_value(i), l_tab_seq_num(i),
					 l_tab_upd_user(i),   l_tab_category(i),	l_tab_usage_type(i),l_tab_data_type(i), 1,
					 sysdate, 			  1, 					sysdate, 			1, 					l_tab_datatype_id(i),
					 l_tab_document_id(i),l_tab_title(i));


      l_dummy := asg_download.mark_dirty(
             P_PUB_ITEM     =>  l_publicationitemname
           , P_ACCESSLIST   => l_tab_access_id
           , P_USERID_LIST  => l_tab_user_id
           , P_DML_TYPE     => 'I'
           , P_TIMESTAMP    => SYSDATE);

    END IF;

    --SR
    l_tab_access_id.delete;
    l_tab_user_id.delete;
    l_tab_file_id.delete;
    l_tab_name.delete;
    l_tab_description.delete;
    l_tab_language.delete;
    l_tab_entity_name.delete;
    l_tab_pk1_value.delete;
    l_tab_pk2_value.delete;
    l_tab_seq_num.delete;
    l_tab_upd_user.delete;
    l_tab_category.delete;
    l_tab_usage_type.delete;
    l_tab_data_type.delete;
	l_tab_datatype_id.delete;
    l_tab_document_id.delete;
    l_tab_title.delete;

    --If the max size of attachment is less than 1, then exit.
    IF (TO_NUMBER(FND_PROFILE.Value('CSM_MAX_ATTACHMENT_SIZE')) < 1) THEN
      IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
        jtm_message_log_pkg.Log_Msg
        ( 0
        , g_table_name
        , 'Leaving INSERT_ALL_ACC_RECORDS - Max att download size is less than 1'
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
        );
      END IF;

      x_return_status := FND_API.G_RET_STS_SUCCESS;
      RETURN;
    END IF;

    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( 0
      , g_table_name
      , 'Downloading Attachments for SRs'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
      );
    END IF;

    OPEN c_SRAtt(p_user_id);
    FETCH c_SRAtt BULK COLLECT INTO l_tab_access_id, l_tab_file_id, l_tab_user_id, l_tab_name,
      l_tab_description, l_tab_language, l_tab_entity_name, l_tab_pk1_value,
      l_tab_pk2_value, l_tab_seq_num,l_tab_upd_user,l_tab_category,l_tab_usage_type,l_tab_data_type,
	  l_tab_datatype_id,l_tab_document_id,l_tab_title;
    CLOSE c_SRAtt;

    IF l_tab_access_id.COUNT > 0 THEN
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
       jtm_message_log_pkg.Log_Msg
        ( 0
        , g_table_name
        , 'Pushing ' || l_tab_access_id.COUNT || ' updated record(s)'
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
       );
      END IF;

      FORALL i in l_tab_access_id.FIRST .. l_tab_access_id.LAST
        INSERT INTO CSM_FND_LOBS_ACC
   			   		(access_id,  file_id,  	  user_id,     name,	    description,
					language, 	 entity_name, pk1_value,   pk2_value, 	seq_num,
					update_user, category, 	  usage_type,  data_type,	counter,
					last_update_date, last_updated_by,     creation_date,created_by, data_type_id,
					document_id,title)
          VALUES    (l_tab_access_id(i),  l_tab_file_id(i), 	l_tab_user_id(i),   l_tab_name(i),      l_tab_description(i),
		  			 l_tab_language(i),   l_tab_entity_name(i), l_tab_pk1_value(i), l_tab_pk2_value(i), l_tab_seq_num(i),
					 l_tab_upd_user(i),   l_tab_category(i),	l_tab_usage_type(i),l_tab_data_type(i), 1,
					 sysdate, 			  1, 					sysdate, 			1, 					l_tab_datatype_id(i),
					 l_tab_document_id(i),l_tab_title(i));


      l_dummy := asg_download.mark_dirty(
             P_PUB_ITEM     => l_publicationitemname
           , P_ACCESSLIST   => l_tab_access_id
           , P_USERID_LIST  => l_tab_user_id
           , P_DML_TYPE     => 'I'
           , P_TIMESTAMP    => SYSDATE);

    END IF;

    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( 0
      , g_table_name
      , 'Downloading Attachments for Tasks'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
      );
    END IF;

    --TASK
    l_tab_access_id.delete;
    l_tab_user_id.delete;
    l_tab_file_id.delete;
    l_tab_name.delete;
    l_tab_description.delete;
    l_tab_language.delete;
    l_tab_entity_name.delete;
    l_tab_pk1_value.delete;
    l_tab_pk2_value.delete;
    l_tab_seq_num.delete;
    l_tab_upd_user.delete;
    l_tab_category.delete;
    l_tab_usage_type.delete;
    l_tab_data_type.delete;
	l_tab_datatype_id.delete;
    l_tab_document_id.delete;
	l_tab_title.delete;

    OPEN c_TaskAtt(p_user_id);
    FETCH c_TaskAtt BULK COLLECT INTO l_tab_access_id, l_tab_file_id, l_tab_user_id, l_tab_name,
      l_tab_description, l_tab_language, l_tab_entity_name, l_tab_pk1_value,
      l_tab_pk2_value, l_tab_seq_num,l_tab_upd_user,l_tab_category,l_tab_usage_type,l_tab_data_type,
	  l_tab_datatype_id,l_tab_document_id,l_tab_title;
    CLOSE c_TaskAtt;

    IF l_tab_access_id.COUNT > 0 THEN
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
       jtm_message_log_pkg.Log_Msg
        ( 0
        , g_table_name
        , 'Pushing ' || l_tab_access_id.COUNT || ' updated record(s)'
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
       );
      END IF;

      FORALL i in l_tab_access_id.FIRST .. l_tab_access_id.LAST
        INSERT INTO CSM_FND_LOBS_ACC
   			   		(access_id,  file_id,  	  user_id,     name,	    description,
					language, 	 entity_name, pk1_value,   pk2_value, 	seq_num,
					update_user, category, 	  usage_type,  data_type,	counter,
					last_update_date, last_updated_by,     creation_date,created_by, data_type_id,
					document_id,title)
          VALUES    (l_tab_access_id(i),  l_tab_file_id(i), 	l_tab_user_id(i),   l_tab_name(i),      l_tab_description(i),
		  			 l_tab_language(i),   l_tab_entity_name(i), l_tab_pk1_value(i), l_tab_pk2_value(i), l_tab_seq_num(i),
					 l_tab_upd_user(i),   l_tab_category(i),	l_tab_usage_type(i),l_tab_data_type(i), 1,
					 sysdate, 			  1, 					sysdate, 			1, 					l_tab_datatype_id(i),
					 l_tab_document_id(i),l_tab_title(i));


      l_dummy := asg_download.mark_dirty(
             P_PUB_ITEM     => l_publicationitemname
           , P_ACCESSLIST   => l_tab_access_id
           , P_USERID_LIST  => l_tab_user_id
           , P_DML_TYPE     => 'I'
           , P_TIMESTAMP    => SYSDATE);

    END IF;


    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( 0
      , g_table_name
      , 'Downloading Signatures'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
      );
    END IF;


   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
     jtm_message_log_pkg.Log_Msg
     ( 0
     , g_table_name
     , 'Leaving INSERT_ALL_ACC_RECORDS'
     , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
     );
   END IF;

EXCEPTION

   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
       jtm_message_log_pkg.Log_Msg
         ( 0
         , g_table_name
         , 'INSERT_ALL_ACC_RECORDS'||fnd_global.local_chr(10)||
           'Error: '||sqlerrm
         , JTM_HOOK_UTIL_PKG.g_debug_level_error);
     END IF;
     RAISE;
END INSERT_ALL_ACC_RECORDS;

--Bug 4938130
PROCEDURE INSERT_ACC_RECORD(p_task_assignment_id IN NUMBER, p_user_id IN NUMBER)
IS

CURSOR l_signature_csr(b_task_assignment_id IN NUMBER, b_user_id IN NUMBER,
	   					b_lang IN VARCHAR)
IS
SELECT csm_fnd_lobs_acc_s.NEXTVAL, fnddoc.media_id, acc.user_id,
       fnddoccat_tl.name, fnddoc_tl.description, fnddoc_tl.language,
       fndatt.entity_name, fndatt.pk1_value, fndatt.pk2_value,
       fndatt.seq_num,asg.user_name,fnddoccat_tl.user_name,
	   fnddoc.usage_type,doctype.user_name,fnddoc.datatype_id,
	   fnddoc.document_id,fnddoc_tl.title
FROM   csf_debrief_headers dbfhdr, fnd_attached_documents fndatt,
	   fnd_documents_tl fnddoc_tl, fnd_documents fnddoc,
--	   fnd_lobs lobs,
   	   fnd_document_categories_tl fnddoccat_tl,
	   csm_debrief_headers_acc acc,asg_user asg,
	   FND_DOCUMENT_DATATYPES doctype
WHERE dbfhdr.task_assignment_id = b_task_assignment_id
AND	acc.debrief_header_id 		= dbfhdr.debrief_header_id
AND acc.user_id 				= b_user_id
AND asg.user_id                 = b_user_id
AND fndatt.entity_name 			= 'CSF_DEBRIEF_HEADERS'
AND fndatt.pk1_value 			= dbfhdr.debrief_header_id
AND fndatt.document_id 			= fnddoc_tl.document_id
AND fnddoc_tl.document_id 		= fnddoc.document_id
AND fnddoc_tl.language 			= b_lang
--AND fnddoc.media_id 			= lobs.file_id
AND fnddoccat_tl.category_id 	= fnddoc.category_id
AND fnddoccat_tl.language 		= b_lang
AND fnddoccat_tl.name 			= 'SIGNATURE'
AND fnddoc.datatype_id			= 6
AND doctype.datatype_id         = fnddoc.datatype_id
AND doctype.language            = asg.language
AND NOT EXISTS (SELECT 1 FROM CSM_FND_LOBS_ACC cflacc
                      WHERE cflacc.document_id = fnddoc.document_id
                      AND   cflacc.user_id = acc.user_id);

-- get SR attachments
CURSOR l_SRAtt_csr (b_task_assignment_id IN NUMBER, b_user_id IN NUMBER,
	   			    b_lang VARCHAR)
IS
SELECT csm_fnd_lobs_acc_s.NEXTVAL, fnddoc.media_id, acc.user_id,
       fnddoccat_tl.name, fnddoc_tl.description, fnddoc_tl.language,
       fndattdoc.entity_name, fndattdoc.pk1_value, fndattdoc.pk2_value,
       fndattdoc.seq_num,asg.user_name,fnddoccat_tl.user_name,
	   fnddoc.usage_type,doctype.user_name,fnddoc.datatype_id,
	   fnddoc.document_id,fnddoc_tl.title
FROM jtf_task_assignments jta,    jtf_tasks_b jt,
     fnd_documents_tl fnddoc_tl,  fnd_documents fnddoc,
     fnd_document_categories_tl fnddoccat_tl,
     fnd_attached_documents fndattdoc,
--	 fnd_lobs lobs,
     csm_incidents_all_acc acc,asg_user asg,
	 FND_DOCUMENT_DATATYPES doctype
WHERE jta.task_assignment_id = b_task_assignment_id
AND jta.task_id 			 = jt.task_id
AND jt.source_object_id 	 = acc.incident_id
AND jt.source_object_type_code = 'SR'
AND fndattdoc.document_id 	   = fnddoc_tl.document_id
AND fnddoc_tl.language 		   = b_lang
AND fnddoc_tl.document_id 	   = fnddoc.document_id
--AND fnddoc.media_id 		   = lobs.file_id (+)
AND fnddoccat_tl.category_id   = fnddoc.category_id
AND fnddoccat_tl.language 	   = b_lang
AND fndattdoc.pk1_value 	   = to_char(acc.incident_id)
AND acc.user_id 			   = b_user_id
AND asg.user_id                = b_user_id
AND fnddoccat_tl.name 		   = 'MISC'
AND fndattdoc.entity_name 	   = 'CS_INCIDENTS'
AND fnddoc.datatype_id		   in (1,5,6)
AND doctype.datatype_id        = fnddoc.datatype_id
AND doctype.language           = asg.language
AND  NOT EXISTS (SELECT 1 FROM CSM_FND_LOBS_ACC cflacc
                      WHERE cflacc.document_id = fnddoc.document_id
                      AND   cflacc.user_id = acc.user_id);

--get the task attachemnts
CURSOR l_TaskAtt_csr (b_task_assignment_id IN NUMBER, b_user_id IN NUMBER,
	   				  b_lang IN VARCHAR)
IS
SELECT csm_fnd_lobs_acc_s.NEXTVAL, fnddoc.media_id, acc.user_id,
       fnddoccat_tl.name, fnddoc_tl.description, fnddoc_tl.language,
       fndattdoc.entity_name, fndattdoc.pk1_value, fndattdoc.pk2_value,
       fndattdoc.seq_num,asg.user_name,fnddoccat_tl.user_name,
	   fnddoc.usage_type,doctype.user_name,fnddoc.datatype_id,
	   fnddoc.document_id,fnddoc_tl.title
FROM jtf_task_assignments jta,
     fnd_documents_tl fnddoc_tl, fnd_documents fnddoc,
     fnd_document_categories_tl fnddoccat_tl,
     fnd_attached_documents fndattdoc,
--	 fnd_lobs lobs,
     csm_tasks_acc acc,asg_user asg,
	 FND_DOCUMENT_DATATYPES doctype
WHERE jta.task_assignment_id = b_task_assignment_id
AND acc.task_id 			 = jta.task_id
AND fndattdoc.document_id 	 = fnddoc_tl.document_id
AND fnddoc_tl.language 		 = b_lang
AND fnddoc_tl.document_id 	 = fnddoc.document_id
--AND fnddoc.media_id 		 = lobs.file_id (+)
AND fnddoccat_tl.category_id = fnddoc.category_id
AND fnddoccat_tl.language 	 = b_lang
AND fndattdoc.pk1_value 	 = to_char(acc.task_id)
AND acc.user_id 			 = b_user_id
AND asg.user_id              = b_user_id
AND fnddoccat_tl.name 		 = 'MISC'
AND fndattdoc.entity_name 	 = 'JTF_TASKS_B'
AND fnddoc.datatype_id		 in (1,5,6)
AND doctype.datatype_id      = fnddoc.datatype_id
AND doctype.language         = asg.language
AND NOT EXISTS (SELECT 1 FROM CSM_FND_LOBS_ACC cflacc
                      WHERE cflacc.document_id = fnddoc.document_id
                      AND   cflacc.user_id = acc.user_id);

CURSOR l_user_csr(b_user_id IN NUMBER)
IS
SELECT LANGUAGE
FROM   asg_user
WHERE  user_id=b_user_id;

l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

l_tab_access_id   ASG_DOWNLOAD.ACCESS_LIST;
l_tab_user_id ASG_DOWNLOAD.USER_LIST;
l_publicationitemname VARCHAR2(50):= 'CSF_M_LOBS';
l_tab_file_id Number_TAB;
l_tab_seq_num Number_TAB;
l_tab_name Varchar2_TAB;
l_tab_description Varchar2_TAB;
l_tab_language Varchar2_TAB;
l_tab_entity_name Varchar2_TAB;
l_tab_pk1_value Varchar2_TAB;
l_tab_pk2_value Varchar2_TAB;
l_tab_upd_user    Varchar2_TAB;
l_tab_category    Varchar2_TAB;
l_tab_usage_type  Varchar2_TAB;
l_tab_data_type   Varchar2_TAB;
l_tab_datatype_id Number_TAB;
l_tab_document_id Number_TAB;
l_tab_title       Varchar2_TAB;

l_dummy        BOOLEAN;
g_debug_level  NUMBER;
l_excep_markdirty_failed EXCEPTION;
l_language_user VARCHAR(10);

BEGIN
   CSM_UTIL_PKG.LOG('Entering INSERT_ACC_RECORD for task_assignment_id: ' || p_task_assignment_id,
                                   'CSM_LOBS_EVENT_PKG.INSERT_ACC_RECORD',FND_LOG.LEVEL_PROCEDURE);

    l_publicationitemname := 'CSF_M_LOBS';


	OPEN	  l_user_csr(p_user_id);
	FETCH 	  l_user_csr into l_language_user;
	CLOSE 	  l_user_csr;


---DOWNLOAD  SR AND TASK Attachments
   /*** get debug level ***/
   g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;
   IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
      ( 0
      , g_table_name
      , 'Entering CSM_LOBS_EVENT_PKG.INSERT_ACC_RECORD'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
      );
	END IF;

--Emptying all lists.
 	l_tab_access_id.delete;
 	l_tab_user_id.delete;
 	l_tab_file_id.delete;
 	l_tab_name.delete;
 	l_tab_description.delete;
 	l_tab_language.delete;
 	l_tab_entity_name.delete;
 	l_tab_pk1_value.delete;
 	l_tab_pk2_value.delete;
 	l_tab_seq_num.delete;
    l_tab_upd_user.delete;
    l_tab_category.delete;
    l_tab_usage_type.delete;
    l_tab_data_type.delete;
	l_tab_datatype_id.delete;
	l_tab_document_id.delete;
	l_tab_title.delete;

---    ATTACHMENT DOWNLOAD FOR SIGNATURE
    OPEN l_signature_csr(p_task_assignment_id, p_user_id,l_language_user);
    FETCH l_signature_csr  BULK COLLECT INTO l_tab_access_id, l_tab_file_id, l_tab_user_id, l_tab_name,
      l_tab_description, l_tab_language, l_tab_entity_name, l_tab_pk1_value,
      l_tab_pk2_value, l_tab_seq_num,l_tab_upd_user,l_tab_category,l_tab_usage_type,l_tab_data_type,
	  l_tab_datatype_id,l_tab_document_id,l_tab_title;
    CLOSE l_signature_csr;

    IF l_tab_access_id.COUNT > 0 THEN
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
       jtm_message_log_pkg.Log_Msg
        ( 0
        , g_table_name
        , 'Pushing ' || l_tab_access_id.COUNT || ' updated record(s)'
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
       );
      END IF;

      FORALL i in l_tab_access_id.FIRST .. l_tab_access_id.LAST
        INSERT INTO CSM_FND_LOBS_ACC
   			   		(access_id,  file_id,  	  user_id,     name,	    description,
					language, 	 entity_name, pk1_value,   pk2_value, 	seq_num,
					update_user, category, 	  usage_type,  data_type,	counter,
					last_update_date, last_updated_by,     creation_date,created_by, data_type_id,
					document_id,title)
          VALUES    (l_tab_access_id(i),  l_tab_file_id(i), 	l_tab_user_id(i),   l_tab_name(i),      l_tab_description(i),
		  			 l_tab_language(i),   l_tab_entity_name(i), l_tab_pk1_value(i), l_tab_pk2_value(i), l_tab_seq_num(i),
					 l_tab_upd_user(i),   l_tab_category(i),	l_tab_usage_type(i),l_tab_data_type(i), 1,
					 sysdate, 			  1, 					sysdate, 			1, 					l_tab_datatype_id(i),
					 l_tab_document_id(i),l_tab_title(i));

      l_dummy := asg_download.mark_dirty(
           	 P_PUB_ITEM     => l_publicationitemname
           , P_ACCESSLIST   => l_tab_access_id
           , P_USERID_LIST  => l_tab_user_id
           , P_DML_TYPE     => 'I'
           , P_TIMESTAMP    => SYSDATE);

    COMMIT;

	END IF;

     --If the max size of attachment is less than 1, then exit.(this should be done only
     --for SR and TASK attachments)
    IF (TO_NUMBER(FND_PROFILE.Value('CSM_MAX_ATTACHMENT_SIZE')) < 1) THEN
      IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
        jtm_message_log_pkg.Log_Msg
        ( 0
        , g_table_name
        , 'Leaving CSM_LOBS_EVENT_PKG.INSERT_ACC_RECORD - Max att download size is less than 1'
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
        );
      END IF;
      RETURN;
    END IF;


    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( 0
      , g_table_name
      , 'Downloading Attachments for SRs'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
      );
    END IF;

 --Emptying all lists.
 	l_tab_access_id.delete;
 	l_tab_user_id.delete;
 	l_tab_file_id.delete;
 	l_tab_name.delete;
 	l_tab_description.delete;
 	l_tab_language.delete;
 	l_tab_entity_name.delete;
 	l_tab_pk1_value.delete;
 	l_tab_pk2_value.delete;
 	l_tab_seq_num.delete;
    l_tab_upd_user.delete;
    l_tab_category.delete;
    l_tab_usage_type.delete;
    l_tab_data_type.delete;
	l_tab_datatype_id.delete;
	l_tab_document_id.delete;
	l_tab_title.delete;

--- ATTACHMENT DOWNLOAD FOR SR
    OPEN l_SRAtt_csr(p_task_assignment_id, p_user_id,l_language_user);
    FETCH l_SRAtt_csr BULK COLLECT INTO l_tab_access_id, l_tab_file_id, l_tab_user_id, l_tab_name,
      l_tab_description, l_tab_language, l_tab_entity_name, l_tab_pk1_value,
      l_tab_pk2_value, l_tab_seq_num,l_tab_upd_user,l_tab_category,l_tab_usage_type,l_tab_data_type,
	  l_tab_datatype_id,l_tab_document_id,l_tab_title;
    CLOSE l_SRAtt_csr;

    IF l_tab_access_id.COUNT > 0 THEN
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
       jtm_message_log_pkg.Log_Msg
        ( 0
        , g_table_name
        , 'Pushing ' || l_tab_access_id.COUNT || ' updated record(s)'
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
       );
      END IF;

      FORALL i in l_tab_access_id.FIRST .. l_tab_access_id.LAST
        INSERT INTO CSM_FND_LOBS_ACC
		   			(access_id,  file_id,  	  user_id,     name,	    description,
					language, 	 entity_name, pk1_value,   pk2_value, 	seq_num,
					update_user, category, 	  usage_type,  data_type,	counter,
					last_update_date, last_updated_by,     creation_date,created_by, data_type_id,
					document_id,title)
          VALUES    (l_tab_access_id(i),  l_tab_file_id(i), 	l_tab_user_id(i),   l_tab_name(i),      l_tab_description(i),
		  			 l_tab_language(i),   l_tab_entity_name(i), l_tab_pk1_value(i), l_tab_pk2_value(i), l_tab_seq_num(i),
					 l_tab_upd_user(i),   l_tab_category(i),	l_tab_usage_type(i),l_tab_data_type(i), 1,
					 sysdate, 			  1, 					sysdate, 			1, 					l_tab_datatype_id(i),
					 l_tab_document_id(i),l_tab_title(i));


      l_dummy := asg_download.mark_dirty(
           P_PUB_ITEM       => l_publicationitemname
           , P_ACCESSLIST   => l_tab_access_id
           , P_USERID_LIST  => l_tab_user_id
           , P_DML_TYPE     => 'I'
           , P_TIMESTAMP    => SYSDATE);

    COMMIT;

    END IF;

--Emptying all lists.
 	l_tab_access_id.delete;
 	l_tab_user_id.delete;
 	l_tab_file_id.delete;
 	l_tab_name.delete;
 	l_tab_description.delete;
 	l_tab_language.delete;
 	l_tab_entity_name.delete;
 	l_tab_pk1_value.delete;
 	l_tab_pk2_value.delete;
 	l_tab_seq_num.delete;
    l_tab_upd_user.delete;
    l_tab_category.delete;
    l_tab_usage_type.delete;
    l_tab_data_type.delete;
	l_tab_datatype_id.delete;
	l_tab_document_id.delete;
	l_tab_title.delete;

---    ATTACHMENT DOWNLOAD FOR TASK
    OPEN l_TaskAtt_csr(p_task_assignment_id, p_user_id,l_language_user);
    FETCH l_TaskAtt_csr BULK COLLECT INTO l_tab_access_id, l_tab_file_id, l_tab_user_id, l_tab_name,
      l_tab_description, l_tab_language, l_tab_entity_name, l_tab_pk1_value,
      l_tab_pk2_value, l_tab_seq_num,l_tab_upd_user,l_tab_category,l_tab_usage_type,l_tab_data_type,
	  l_tab_datatype_id,l_tab_document_id,l_tab_title;
    CLOSE l_TaskAtt_csr;

    IF l_tab_access_id.COUNT > 0 THEN
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
       jtm_message_log_pkg.Log_Msg
        ( 0
        , g_table_name
        , 'Pushing ' || l_tab_access_id.COUNT || ' updated record(s)'
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
       );
      END IF;

      FORALL i in l_tab_access_id.FIRST .. l_tab_access_id.LAST
        INSERT INTO CSM_FND_LOBS_ACC
   			   		(access_id,  file_id,  	  user_id,     name,	    description,
					language, 	 entity_name, pk1_value,   pk2_value, 	seq_num,
					update_user, category, 	  usage_type,  data_type,	counter,
					last_update_date, last_updated_by,     creation_date,created_by, data_type_id,
					document_id,title)
          VALUES    (l_tab_access_id(i),  l_tab_file_id(i), 	l_tab_user_id(i),   l_tab_name(i),      l_tab_description(i),
		  			 l_tab_language(i),   l_tab_entity_name(i), l_tab_pk1_value(i), l_tab_pk2_value(i), l_tab_seq_num(i),
					 l_tab_upd_user(i),   l_tab_category(i),	l_tab_usage_type(i),l_tab_data_type(i), 1,
					 sysdate, 			  1, 					sysdate, 			1, 					l_tab_datatype_id(i),
					 l_tab_document_id(i),l_tab_title(i));


      l_dummy := asg_download.mark_dirty(
           	 P_PUB_ITEM     => l_publicationitemname
           , P_ACCESSLIST   => l_tab_access_id
           , P_USERID_LIST  => l_tab_user_id
           , P_DML_TYPE     => 'I'
           , P_TIMESTAMP    => SYSDATE);

    COMMIT;

	END IF;

   CSM_UTIL_PKG.LOG('Leaving INSERT_ACC_RECORD for task_assignment_id: ' || p_task_assignment_id,
                                   'CSM_LOBS_EVENT_PKG.INSERT_ACC_RECORD',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
    WHEN l_excep_markdirty_failed THEN
  	 l_error_msg := ' FAILED MarkDirty in INSERT_ACC_RECORD for task_assignment_id:' || to_char(p_task_assignment_id);
     CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_LOBS_EVENT_PKG.INSERT_ACC_RECORD',FND_LOG.LEVEL_EXCEPTION);
     RAISE;

  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  INSERT_ACC_RECORD for task_assignment_id:'
                       || to_char(p_task_assignment_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_LOBS_EVENT_PKG.INSERT_ACC_RECORD',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END INSERT_ACC_RECORD;

--Bug 4938130
PROCEDURE DELETE_ACC_RECORD(p_task_assignment_id IN NUMBER, p_resource_id IN NUMBER)
IS
	--Cursor for signature
	  CURSOR l_signature_csr(b_task_assignment_id IN number, b_user_id IN number)
	  IS
      SELECT  acc.access_id, acc.user_id
      FROM    csm_fnd_lobs_acc acc,
              csf_debrief_headers dbh
      WHERE acc.user_id 		  = b_user_id
      AND acc.entity_name 		  = 'CSF_DEBRIEF_HEADERS'
      AND dbh.task_assignment_id  = b_task_assignment_id
      AND acc.pk1_value 		  = to_char(dbh.debrief_header_id);

	--Cursor for SR attachments
     CURSOR c_SRAtt ( b_task_assignment_id IN NUMBER,
                     b_user_id IN NUMBER) IS
      SELECT  acc.access_id, acc.user_id
      FROM    csm_fnd_lobs_acc acc,
              jtf_task_assignments jta,
              jtf_tasks_b jt
      WHERE acc.user_id   		   		= b_user_id
      AND acc.entity_name 				= 'CS_INCIDENTS'
      AND jt.task_id      				= jta.task_id
      AND jta.task_assignment_id	    = b_task_assignment_id
      AND acc.pk1_value 			    = to_char(jt.source_object_id);

	  --Cursor for Task attachments
      CURSOR l_TaskAtt_csr ( b_task_assignment_id IN NUMBER,
                     b_user_id IN NUMBER) IS
      SELECT  acc.access_id, acc.user_id
      FROM    csm_fnd_lobs_acc acc,
              jtf_task_assignments jta
      WHERE acc.user_id 		   = b_user_id
      AND acc.entity_name 		   = 'JTF_TASKS_B'
      AND jta.task_assignment_id   = b_task_assignment_id
      AND acc.pk1_value 		   = to_char(jta.task_id);

   --CURSOR to get userid
   CURSOR l_userid_csr (b_resource_id IN NUMBER)
   IS
   SELECT user_id
   FROM	  asg_user
   WHERE resource_id=b_resource_id;

l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

l_resourcelist number;
l_publicationitemname VARCHAR2(50) := 'CSF_M_LOBS';
l_excep_markdirty_failed EXCEPTION;
g_debug_level NUMBER;
l_tab_access_id   ASG_DOWNLOAD.ACCESS_LIST;
l_tab_user_id 	  ASG_DOWNLOAD.USER_LIST;
l_dummy        BOOLEAN;
l_userid NUMBER;

BEGIN

    g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( p_task_assignment_id
      , g_table_name
      , 'Entering CSM_LOBS_EVENT_PKG.DELETE_ACC_RECORD'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;

	--cursor to get language
	OPEN l_userid_csr (p_resource_id);
	FETCH l_userid_csr INTO l_userid;
	CLOSE l_userid_csr;

--Deleting Signature attachments

      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( p_task_assignment_id
        , g_table_name
        , 'Deleting record for CS_INCIDENTS and resource_id: ' || p_resource_id
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;

      OPEN l_signature_csr(p_task_assignment_id, l_userid);
      FETCH l_signature_csr BULK COLLECT INTO l_tab_access_id, l_tab_user_id;
      CLOSE l_signature_csr;

      IF l_tab_access_id.COUNT > 0 THEN
        IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
         jtm_message_log_pkg.Log_Msg
          ( 0
          , g_table_name
          , 'Pushing ' || l_tab_access_id.COUNT || ' updated record(s)'
          , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
         );
        END IF;

        FORALL i in l_tab_access_id.FIRST .. l_tab_access_id.LAST
          DELETE FROM CSM_FND_LOBS_ACC WHERE ACCESS_ID = l_tab_access_id(i);

        l_dummy := asg_download.mark_dirty(
               P_PUB_ITEM     => l_publicationitemname
             , P_ACCESSLIST   => l_tab_access_id
             , P_USERID_LIST  => l_tab_user_id
             , P_DML_TYPE     => 'D'
             , P_TIMESTAMP    => SYSDATE);

        COMMIT;

      END IF;

--SR attachment deletion
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( p_task_assignment_id
        , g_table_name
        , 'Deleting record for CS_INCIDENTS and resource_id: ' || p_resource_id
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;

      OPEN c_SRAtt(p_task_assignment_id, l_userid);
      FETCH c_SRAtt BULK COLLECT INTO l_tab_access_id, l_tab_user_id;
      CLOSE c_SRAtt;

      IF l_tab_access_id.COUNT > 0 THEN
        IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
         jtm_message_log_pkg.Log_Msg
          ( 0
          , g_table_name
          , 'Pushing ' || l_tab_access_id.COUNT || ' updated record(s)'
          , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
         );
        END IF;

        FORALL i in l_tab_access_id.FIRST .. l_tab_access_id.LAST
          DELETE FROM CSM_FND_LOBS_ACC WHERE ACCESS_ID = l_tab_access_id(i);

        l_dummy := asg_download.mark_dirty(
               P_PUB_ITEM     => l_publicationitemname
             , P_ACCESSLIST   => l_tab_access_id
             , P_USERID_LIST  => l_tab_user_id
             , P_DML_TYPE     => 'D'
             , P_TIMESTAMP    => SYSDATE);

        COMMIT;

      END IF;

----------------------------------
--Deletion for Tasks
-----------------------------------
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( p_task_assignment_id
        , g_table_name
        , 'Deleting record for JTF_TASKS_B and resource_id: ' || p_resource_id
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;

      OPEN l_TaskAtt_csr(p_task_assignment_id, l_userid);
      FETCH l_TaskAtt_csr BULK COLLECT INTO l_tab_access_id, l_tab_user_id;
      CLOSE l_TaskAtt_csr;

      IF l_tab_access_id.COUNT > 0 THEN
        IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
         jtm_message_log_pkg.Log_Msg
          ( 0
          , g_table_name
          , 'Pushing ' || l_tab_access_id.COUNT || ' updated record(s)'
          , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
         );
        END IF;

        FORALL i in l_tab_access_id.FIRST .. l_tab_access_id.LAST
          DELETE FROM CSM_FND_LOBS_ACC WHERE ACCESS_ID = l_tab_access_id(i);

	l_dummy := asg_download.mark_dirty(
               P_PUB_ITEM     => l_publicationitemname
             , P_ACCESSLIST   => l_tab_access_id
             , P_USERID_LIST  => l_tab_user_id
             , P_DML_TYPE     => 'D'
             , P_TIMESTAMP    => SYSDATE);

        COMMIT;

      END IF;

    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( p_task_assignment_id
      , g_table_name
      , 'Exiting CSM_LOBS_EVENT_PKG.DELETE_ACC_RECORD'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;

   CSM_UTIL_PKG.LOG('Leaving DELETE_ACC_RECORD for task_assignment_id: ' || p_task_assignment_id,
                                   'CSM_LOBS_EVENT_PKG.DELETE_ACC_RECORD',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
    WHEN l_excep_markdirty_failed THEN
  	 l_error_msg := ' FAILED MarkDirty in DELETE_ACC_RECORD for task_assignment_id:' || to_char(p_task_assignment_id);
     CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_LOBS_EVENT_PKG.DELETE_ACC_RECORD',FND_LOG.LEVEL_EXCEPTION);
     RAISE;

  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  DELETE_ACC_RECORD for task_assignment_id:'
                       || to_char(p_task_assignment_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_LOBS_EVENT_PKG.DELETE_ACC_RECORD',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END DELETE_ACC_RECORD;


PROCEDURE INSERT_ACC_ON_UPLOAD(p_PK1_value IN NUMBER, p_user_id IN NUMBER,
		  					   p_entity_name IN VARCHAR, p_data_typeid IN NUMBER, p_dodirty BOOLEAN)
IS
-- get SR attachments
--p_dodirty is used only for lobs attachments(6).if its sets to true then mark dirty has to be done.The reason
--for this is the file id sent from client may not be proper and so we allow the server to generate the file id
CURSOR l_SRAtt_csr (b_incident_id IN NUMBER, b_user_id IN NUMBER,
	   			    b_data_typeid IN NUMBER)
IS
SELECT csm_fnd_lobs_acc_s.NEXTVAL, fnddoc.media_id, 	  acc.user_id,
       fnddoccat_tl.name, 		   fnddoc_tl.description, fnddoc_tl.language,
       fndattdoc.entity_name, 	   fndattdoc.pk1_value,   fndattdoc.pk2_value,
       fndattdoc.seq_num,		   asg.user_name,		  fnddoccat_tl.user_name,
	   fnddoc.usage_type,		   doctype.user_name,	  fnddoc.datatype_id,
	   fnddoc.document_id,         fnddoc_tl.title
FROM   fnd_documents_tl  		fnddoc_tl,
	   fnd_documents 			fnddoc,
       fnd_document_categories_tl fnddoccat_tl,
       fnd_attached_documents 	  fndattdoc,
       csm_incidents_all_acc 	  acc,
	   asg_user 			 	  asg,
	   FND_DOCUMENT_DATATYPES 	  doctype
WHERE  fndattdoc.document_id    = fnddoc_tl.document_id
AND    fnddoc_tl.language 	 	= asg.language
AND    fnddoc_tl.document_id 	= fnddoc.document_id
AND    fnddoccat_tl.category_id = fnddoc.category_id
AND    fnddoccat_tl.language 	= asg.language
AND    fndattdoc.pk1_value 		= to_char(acc.incident_id)
AND	   fndattdoc.pk1_value		= to_char(b_incident_id)
AND    asg.user_id 				= acc.user_id
AND    fnddoccat_tl.name 		= 'MISC'
AND    fndattdoc.entity_name 	= 'CS_INCIDENTS'
AND    fnddoc.datatype_id 		= b_data_typeid
AND    doctype.datatype_id 		= fnddoc.datatype_id
AND    doctype.language 		= asg.language
AND	   acc.user_id				= b_user_id
AND    NOT EXISTS (SELECT 1
	   	   		   FROM   CSM_FND_LOBS_ACC cflacc
                   WHERE  cflacc.document_id = fnddoc.document_id
                   AND    cflacc.user_id 	   = acc.user_id);

--Cursor to get the task attachemnts
CURSOR	 l_TaskAtt_csr(b_task_id IN NUMBER, b_user_id IN NUMBER,
	   			       b_data_typeid IN NUMBER)
IS
SELECT csm_fnd_lobs_acc_s.NEXTVAL, fnddoc.media_id, 	  acc.user_id,
       fnddoccat_tl.name, 		   fnddoc_tl.description, fnddoc_tl.language,
       fndattdoc.entity_name, 	   fndattdoc.pk1_value,   fndattdoc.pk2_value,
       fndattdoc.seq_num,		   asg.user_name,		  fnddoccat_tl.user_name,
	   fnddoc.usage_type,		   doctype.user_name,	  fnddoc.datatype_id,
	   fnddoc.document_id,         fnddoc_tl.title
FROM   fnd_documents_tl fnddoc_tl,
	   fnd_documents fnddoc,
       fnd_document_categories_tl fnddoccat_tl,
       fnd_attached_documents fndattdoc,
       csm_tasks_acc acc,
	   asg_user asg,
	   FND_DOCUMENT_DATATYPES doctype
WHERE  fndattdoc.document_id = fnddoc_tl.document_id
AND    fnddoc_tl.language 	 = asg.language
AND    fnddoc_tl.document_id = fnddoc.document_id
AND    fnddoccat_tl.category_id = fnddoc.category_id
AND    fnddoccat_tl.language 	= asg.language
AND    fndattdoc.pk1_value 		= to_char(acc.task_id)
AND	   fndattdoc.pk1_value		= to_char(b_task_id)
AND    asg.user_id 				= acc.user_id
AND    fnddoccat_tl.name 		= 'MISC'
AND    fndattdoc.entity_name 	= 'JTF_TASKS_B'
AND    fnddoc.datatype_id 		= b_data_typeid
AND    doctype.datatype_id 		= fnddoc.datatype_id
AND    doctype.language 		= asg.language
AND	   acc.user_id				= b_user_id
AND    NOT EXISTS (SELECT 1
	   	   		   FROM   CSM_FND_LOBS_ACC cflacc
                   WHERE  cflacc.document_id = fnddoc.document_id
                   AND    cflacc.user_id 	   = acc.user_id);

--Bug 5726888
  --Cursor to get the Signature attachemnts
    CURSOR c_Signature (b_debrief_id IN NUMBER, b_user_id IN NUMBER,
	   			       b_data_typeid IN NUMBER) IS
      SELECT  csm_fnd_lobs_acc_s.NEXTVAL, fnddoc.media_id, acc.user_id,
        fnddoccat_tl.name, fnddoc_tl.description, fnddoc_tl.language,
        fndattdoc.entity_name, fndattdoc.pk1_value, fndattdoc.pk2_value,
        fndattdoc.seq_num,asg.user_name,fnddoccat_tl.user_name,
   	    fnddoc.usage_type,doctype.user_name,fnddoc.datatype_id,
	    fnddoc.document_id,fnddoc_tl.title
      FROM fnd_documents_tl fnddoc_tl, fnd_documents fnddoc,
           fnd_document_categories_tl fnddoccat_tl,
           fnd_attached_documents fndattdoc,
           csm_debrief_headers_acc acc, asg_user asg,
           FND_DOCUMENT_DATATYPES doctype
      WHERE fndattdoc.document_id = fnddoc_tl.document_id
      AND fnddoc_tl.language = asg.language
      AND fnddoc_tl.document_id = fnddoc.document_id
      AND fnddoccat_tl.category_id = fnddoc.category_id
      AND fnddoccat_tl.language = asg.language
      AND fndattdoc.pk1_value = to_char(acc.debrief_header_id)
      AND acc.debrief_header_id = b_debrief_id
      AND fnddoccat_tl.name = 'SIGNATURE'
      AND fndattdoc.entity_name = 'CSF_DEBRIEF_HEADERS'
      AND fnddoc.datatype_id =b_data_typeid
      AND doctype.datatype_id = fnddoc.datatype_id
      AND doctype.language = asg.language
      AND acc.user_id = asg.user_id
      AND acc.user_id=b_user_id
      AND NOT EXISTS (SELECT 1 FROM CSM_FND_LOBS_ACC cflacc
                      WHERE cflacc.document_id = fnddoc.document_id
                      AND   cflacc.user_id = acc.user_id);

TYPE Number_TAB IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE Varchar2_TAB IS TABLE OF VARCHAR2(255) INDEX BY BINARY_INTEGER;
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

l_tab_access_id   ASG_DOWNLOAD.ACCESS_LIST;
l_tab_user_id ASG_DOWNLOAD.USER_LIST;

l_publicationitemname VARCHAR2(50):= 'CSF_M_LOBS';
l_tab_file_id 		  Number_TAB;
l_tab_seq_num 		  Number_TAB;
l_tab_name 			  Varchar2_TAB;
l_tab_description 	  Varchar2_TAB;
l_tab_language 		  Varchar2_TAB;
l_tab_entity_name 	  Varchar2_TAB;
l_tab_pk1_value 	  Varchar2_TAB;
l_tab_pk2_value 	  Varchar2_TAB;
l_tab_upd_user    	  Varchar2_TAB;
l_tab_category    	  Varchar2_TAB;
l_tab_usage_type  	  Varchar2_TAB;
l_tab_data_type   	  Varchar2_TAB;
l_tab_datatype_id 	  Number_TAB;
l_tab_document_id 	  Number_TAB;
l_tab_title           Varchar2_TAB;

l_dummy        BOOLEAN;
g_debug_level  NUMBER;

BEGIN
   CSM_UTIL_PKG.LOG('Entering INSERT_ACC_ON_UPLOAD for task_assignment_id: ' || p_PK1_value,
                                   'CSM_LOBS_EVENT_PKG.INSERT_ACC_ON_UPLOAD',FND_LOG.LEVEL_PROCEDURE);

    l_publicationitemname := 'CSF_M_LOBS';

---DOWNLOAD  SR AND TASK Attachments
   /*** get debug level ***/
   g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;
   IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
      ( 0
      , g_table_name
      , 'Entering CSM_LOBS_EVENT_PKG.INSERT_ACC_ON_UPLOAD'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
      );
   END IF;
     --If the max size of attachment is less than 1, then exit.(this should be done only
     --for SR and TASK attachments)
   IF (TO_NUMBER(FND_PROFILE.Value('CSM_MAX_ATTACHMENT_SIZE')) < 1) THEN
      IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
        jtm_message_log_pkg.Log_Msg
        ( 0
        , g_table_name
        , 'Leaving CSM_LOBS_EVENT_PKG.INSERT_ACC_ON_UPLOAD - Max att download size is less than 1'
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
        );
      END IF;
      RETURN;
   END IF;

 --Emptying all lists.
 	l_tab_access_id.delete;
 	l_tab_user_id.delete;
 	l_tab_file_id.delete;
 	l_tab_name.delete;
 	l_tab_description.delete;
 	l_tab_language.delete;
 	l_tab_entity_name.delete;
 	l_tab_pk1_value.delete;
 	l_tab_pk2_value.delete;
 	l_tab_seq_num.delete;
    l_tab_upd_user.delete;
    l_tab_category.delete;
    l_tab_usage_type.delete;
    l_tab_data_type.delete;
	l_tab_datatype_id.delete;
	l_tab_document_id.delete;
	l_tab_title.delete;

    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( 0
      , g_table_name
      , 'Downloading Attachments for SRs'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
      );
    END IF;

	IF p_entity_name = 'CS_INCIDENTS'  THEN
	--- ATTACHMENT DOWNLOAD FOR SR
    	OPEN  l_SRAtt_csr(p_PK1_value, p_user_id,p_data_typeid);
    	FETCH l_SRAtt_csr BULK COLLECT INTO l_tab_access_id, l_tab_file_id, l_tab_user_id, l_tab_name,
      		  l_tab_description, l_tab_language, l_tab_entity_name, l_tab_pk1_value,
      		  l_tab_pk2_value, l_tab_seq_num,l_tab_upd_user,l_tab_category,l_tab_usage_type,l_tab_data_type,
	  		  l_tab_datatype_id,l_tab_document_id,l_tab_title;
        CLOSE l_SRAtt_csr;
	END IF;

	IF p_entity_name = 'JTF_TASKS_B'  THEN
	--- ATTACHMENT DOWNLOAD FOR task
    	OPEN  l_TaskAtt_csr(p_PK1_value, p_user_id,p_data_typeid);
    	FETCH l_TaskAtt_csr BULK COLLECT INTO l_tab_access_id, l_tab_file_id, l_tab_user_id, l_tab_name,
      		  l_tab_description, l_tab_language, l_tab_entity_name, l_tab_pk1_value,
      		  l_tab_pk2_value, l_tab_seq_num,l_tab_upd_user,l_tab_category,l_tab_usage_type,l_tab_data_type,
	  		  l_tab_datatype_id,l_tab_document_id,l_tab_title;
        CLOSE l_TaskAtt_csr;

	END IF;

--Bug 5726888
	IF p_entity_name = 'CSF_DEBRIEF_HEADERS'  THEN
	--- SIGNATURE DOWNLOAD
    	OPEN  c_Signature(p_PK1_value, p_user_id,p_data_typeid);
    	FETCH c_Signature BULK COLLECT INTO l_tab_access_id, l_tab_file_id, l_tab_user_id, l_tab_name,
      		  l_tab_description, l_tab_language, l_tab_entity_name, l_tab_pk1_value,
      		  l_tab_pk2_value, l_tab_seq_num,l_tab_upd_user,l_tab_category,l_tab_usage_type,l_tab_data_type,
	  		  l_tab_datatype_id,l_tab_document_id,l_tab_title;
        CLOSE c_Signature;

	END IF;

    IF l_tab_access_id.COUNT > 0 THEN

      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
       jtm_message_log_pkg.Log_Msg
        ( 0
        , g_table_name
        , 'Pushing ' || l_tab_access_id.COUNT || ' updated record(s)'
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
       );
      END IF;

      FORALL i in l_tab_access_id.FIRST .. l_tab_access_id.LAST
        INSERT INTO CSM_FND_LOBS_ACC
		   			(access_id,  file_id,  	  user_id,     name,	    description,
					language, 	 entity_name, pk1_value,   pk2_value, 	seq_num,
					update_user, category, 	  usage_type,  data_type,	counter,
					last_update_date, last_updated_by,     creation_date,created_by, data_type_id,
					document_id,title)
          VALUES    (l_tab_access_id(i),  l_tab_file_id(i), 	l_tab_user_id(i),   l_tab_name(i),      l_tab_description(i),
		  			 l_tab_language(i),   l_tab_entity_name(i), l_tab_pk1_value(i), l_tab_pk2_value(i), l_tab_seq_num(i),
					 l_tab_upd_user(i),   l_tab_category(i),	l_tab_usage_type(i),l_tab_data_type(i), 1,
					 sysdate, 			  1, 					sysdate, 			1, 					l_tab_datatype_id(i),
					 l_tab_document_id(i),l_tab_title(i));


	  IF p_data_typeid =5 OR  p_data_typeid =1 OR (p_data_typeid=6 AND p_dodirty = TRUE) THEN
	  	 --do mark dirly only for URL	and Short Text
      	   l_dummy := asg_download.mark_dirty(
             P_PUB_ITEM       => l_publicationitemname
           , P_ACCESSLIST   => l_tab_access_id
           , P_USERID_LIST  => l_tab_user_id
           , P_DML_TYPE     => 'I'
           , P_TIMESTAMP    => SYSDATE);

	  END IF;


   END IF;--Access id count if

EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  INSERT_ACC_ON_UPLOAD for PK1_value:'
                       || to_char(p_PK1_value) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_LOBS_EVENT_PKG.INSERT_ACC_ON_UPLOAD',FND_LOG.LEVEL_EXCEPTION);
        RAISE;

END INSERT_ACC_ON_UPLOAD;


END CSM_LOBS_EVENT_PKG;

/
