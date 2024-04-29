--------------------------------------------------------
--  DDL for Package Body CSL_LOBS_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSL_LOBS_ACC_PKG" AS
/* $Header: csllbacb.pls 120.0 2005/05/30 07:41:21 appldev noship $ */

g_publication_item_name CONSTANT JTM_HOOK_UTIL_PKG.t_publication_item_list :=
  JTM_HOOK_UTIL_PKG.t_publication_item_list('CSL_LOBS');

g_debug_level           NUMBER; -- debug level
g_table_name            CONSTANT VARCHAR2(30) := 'CSL_LOBS';
g_pk1_name              CONSTANT VARCHAR2(30) := 'FILE_ID';


  PROCEDURE INSERT_ACC_RECORD ( p_task_assignment_id IN NUMBER,
	    	                p_resource_id IN NUMBER)
  IS
    l_task_assignment_id jtf_task_assignments.task_assignment_id%type;
    l_resource_id	 jtf_task_assignments.resource_id%type;
    l_user_id          fnd_user.user_id%TYPE;
    l_item_key              varchar2(50);
    l_seq_val               number(15);
    l_pkvalueslist asg_download.pk_list;
    l_null_pkvalueslist asg_download.pk_list;
    l_accessid number;
    l_markdirty_rc BOOLEAN;
    l_dmllist varchar2(1);
    l_dml varchar2(1);
    l_timestamp DATE;
    l_resourcelist number;
    l_publicationitemname VARCHAR2(50);
    l_excep_markdirty_failed EXCEPTION;
    l_err_mesg    VARCHAR2(1000);

    CURSOR l_signature_csr(p_task_assignment_id IN number,
                           p_resource_id IN number) IS
    SELECT distinct lob.file_id, jtrs.user_id
      FROM jtf_task_assignments jtf, csf_debrief_headers dbfhdr,
           jtf_rs_resource_extns jtrs, asg_user, fnd_attached_documents fndatt,
           fnd_documents_tl fnddoc_tl, fnd_documents fnddoc, fnd_lobs lob,
           fnd_document_categories_tl fnddoccat_tl
      WHERE jtf.task_assignment_id = p_task_assignment_id
        AND jtf.task_assignment_id = dbfhdr.task_assignment_id
        AND jtf.resource_id = p_resource_id
        AND jtrs.resource_id = jtf.resource_id
        AND asg_user.resource_id = jtf.resource_id
        AND fndatt.entity_name = 'CSF_DEBRIEF_HEADERS'
        AND fndatt.pk1_value = dbfhdr.debrief_header_id
        AND fndatt.document_id = fnddoc_tl.document_id
        AND fnddoc_tl.document_id = fnddoc.document_id
        AND fnddoc_tl.language = asg_user.language
        AND fnddoc_tl.media_id = lob.file_id
        AND fnddoccat_tl.category_id = fnddoc.category_id
        AND fnddoccat_tl.language = asg_user.language
        AND fnddoccat_tl.user_name = 'Signature';

   CURSOR l_rs_resource_extns_csr (p_user_id fnd_user.user_id%type) IS
     SELECT resource_id FROM jtf_rs_resource_extns WHERE user_id = p_user_id;

  BEGIN

    g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

    l_task_assignment_id := p_task_assignment_id;
    l_resource_id := p_resource_id;
    l_publicationitemname := 'CSL_LOBS';
    l_timestamp := SYSDATE;

    l_dmllist := ASG_DOWNLOAD.INS;

    FOR l_signature_rec IN l_signature_csr(l_task_assignment_id, l_resource_id)
    LOOP
        -- initialize l_pkvalueslist
        l_pkvalueslist := l_null_pkvalueslist;

        l_accessid := l_signature_rec.file_id;
        l_pkvalueslist(1) := to_char(l_signature_rec.file_id);

        open l_rs_resource_extns_csr(l_signature_rec.user_id);
        fetch l_rs_resource_extns_csr into l_resourcelist;
        close l_rs_resource_extns_csr;

        -- make the markdirty call
        l_markdirty_rc := asg_download.MarkDirty (
                         l_publicationitemname
                         , l_accessid
                         , l_resourcelist
                         , l_dmllist
                         , l_timestamp
                         , l_pkvalueslist);

    	 IF NOT l_markdirty_rc THEN
              RAISE l_excep_markdirty_failed;
         END IF;
     END LOOP;

  EXCEPTION
    WHEN l_excep_markdirty_failed THEN

       l_err_mesg := 'EXCEPTION IN CSL_LOBS_PKG.INSERT_ACC_RECORD :'
                   || to_char(p_task_assignment_id);
       jtm_message_log_pkg.Log_Msg (
         p_task_assignment_id
         , 'LOBS_ACC_PKG.INSERT_ACC'
         , l_err_mesg
         , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);

	RAISE;

    WHEN OTHERS THEN
   	l_err_mesg := 'EXCEPTION IN CSL_LOBS_PKG.INSERT_ACC_RECORD : '
                    || to_char(p_task_assignment_id);
        jtm_message_log_pkg.Log_Msg (
         p_task_assignment_id
         , 'LOBS_ACC_PKG.INSERT_ACC'
         , l_err_mesg
         , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);

    	RAISE;

  END INSERT_ACC_RECORD;



  PROCEDURE DELETE_ACC_RECORD ( p_task_assignment_id IN NUMBER,
                                p_resource_id IN NUMBER)

  IS
    l_task_assignment_id 	jtf_task_assignments.task_assignment_id%type;
    l_resource_id		    jtf_task_assignments.resource_id%type;
    l_user_id          fnd_user.user_id%TYPE;
    l_item_key              varchar2(50);
    l_seq_val               number(15);
    l_pkvalueslist asg_download.pk_list;
    l_null_pkvalueslist asg_download.pk_list;
    l_accessid number;
    l_markdirty_rc  BOOLEAN;
    l_dmllist varchar2(1);
    l_dml varchar2(1);
    l_timestamp DATE;
    l_resourcelist number;
    l_publicationitemname VARCHAR2(50);
    l_excep_markdirty_failed EXCEPTION;
    l_err_mesg    VARCHAR2(1000);

    CURSOR l_signature_csr  (p_task_assignment_id IN number,
                             p_resource_id IN number) IS
    SELECT distinct lob.file_id, acc.user_id
       FROM csm_task_assignments_acc acc , csf_debrief_headers dbfhdr,
         asg_user, fnd_attached_documents fndatt, fnd_documents_tl fnddoc_tl,
         fnd_documents fnddoc, fnd_document_categories_tl fnddoccat_tl,
         fnd_lobs lob
       WHERE asg_user.resource_id = p_resource_id
         AND acc.task_assignment_id = p_task_assignment_id
         AND acc.task_assignment_id = dbfhdr.task_assignment_id
         AND asg_user.user_id = acc.user_id
         AND fndatt.entity_name = 'CSF_DEBRIEF_HEADERS'
         AND fndatt.pk1_value = dbfhdr.debrief_header_id
         AND fndatt.document_id = fnddoc_tl.document_id
         AND fnddoc_tl.document_id = fnddoc.document_id
         AND fnddoc_tl.language = asg_user.language
         AND fnddoc_tl.media_id = lob.file_id
         AND fnddoccat_tl.category_id = fnddoc.category_id
         AND fnddoccat_tl.language = asg_user.language
         AND fnddoccat_tl.user_name = 'Signature';

   CURSOR l_rs_resource_extns_csr (p_user_id fnd_user.user_id%type) IS
     SELECT resource_id FROM jtf_rs_resource_extns WHERE user_id = p_user_id;

  BEGIN

    g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

    l_task_assignment_id := p_task_assignment_id;
    l_resource_id := p_resource_id;
    l_publicationitemname := 'CSL_LOBS';
    l_timestamp := SYSDATE;
    l_dmllist := ASG_DOWNLOAD.DEL;

    FOR l_signature_rec IN l_signature_csr(l_task_assignment_id, l_resource_id)
    LOOP
        -- initialize l_pkvalueslist
        l_pkvalueslist := l_null_pkvalueslist;
        l_accessid := l_signature_rec.file_id;
        l_pkvalueslist(1) := to_char(l_signature_rec.file_id);

        open l_rs_resource_extns_csr(l_signature_rec.user_id);
        fetch l_rs_resource_extns_csr into l_resourcelist;
        close l_rs_resource_extns_csr;

        -- make the markdirty call

        l_markdirty_rc := asg_download.MarkDirty (
                         l_publicationitemname
                         , l_accessid
                         , l_resourcelist
                         , l_dmllist
                         , l_timestamp
                         , l_pkvalueslist);

    	 IF not l_markdirty_rc THEN
              RAISE l_excep_markdirty_failed;
         END IF;
     END LOOP;

  EXCEPTION
    WHEN l_excep_markdirty_failed then
      l_err_mesg := 'EXCEPTION IN CSL_LOBS_PKG.DELETE_ACC_RECORD :'
                  || to_char(p_task_assignment_id);
      jtm_message_log_pkg.Log_Msg (
         p_task_assignment_id
         , 'LOBS_ACC_PKG.INSERT_ACC'
         , l_err_mesg
         , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
      RAISE;

    WHEN OTHERS THEN
      l_err_mesg := 'EXCEPTION IN CSL_LOBS_PKG.DELETE_ACC_RECORD :'
                  || to_char(p_task_assignment_id);
      jtm_message_log_pkg.Log_Msg (
         p_task_assignment_id
         , 'LOBS_ACC_PKG.INSERT_ACC'
         , l_err_mesg
         , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
      RAISE;

  END DELETE_ACC_RECORD;


--Bug 3724142
PROCEDURE CONC_DOWNLOAD_ATTACHMENTS ( p_status OUT NOCOPY VARCHAR2,
					p_message OUT NOCOPY VARCHAR2)
IS
    PRAGMA AUTONOMOUS_TRANSACTION;

    /*** get the last run date of the concurent program ***/
    CURSOR  c_LastRundate
    IS
      select LAST_RUN_DATE
      from   JTM_CON_REQUEST_DATA
      where  package_name =  'CSL_LOBS_ACC_PKG'
      AND    procedure_name = 'CONC_DOWNLOAD_ATTACHMENTS';

    --Cursor to get the SR attachemnts
    CURSOR c_SRAtt (b_lastRundate date) IS
      SELECT  lobs.file_id, acc.resource_id
      FROM fnd_documents_tl fnddoc_tl, fnd_documents fnddoc,
           fnd_document_categories_tl fnddoccat_tl,
           fnd_attached_documents fndattdoc, fnd_lobs lobs,
           csl_cs_incidents_all_acc acc, asg_user asg
      WHERE fndattdoc.document_id = fnddoc_tl.document_id
      AND fnddoc_tl.language = asg.language
      AND fnddoc_tl.document_id = fnddoc.document_id
      AND fnddoc_tl.media_id = lobs.file_id
      AND fnddoccat_tl.category_id = fnddoc.category_id
      AND fnddoccat_tl.language = asg.language
      AND fndattdoc.pk1_value = to_char(acc.incident_id)
      AND asg.resource_id = acc.resource_id
      AND fnddoccat_tl.name = 'MISC'
      AND fndattdoc.entity_name = 'CS_INCIDENTS'
      AND fnddoc.datatype_id=6
      AND fndattdoc.last_update_date >= b_lastRundate;

 --Cursor to get the task attachemnts
    CURSOR c_TaskAtt (b_lastRundate date) IS
      SELECT  lobs.file_id, acc.resource_id
      FROM fnd_documents_tl fnddoc_tl, fnd_documents fnddoc,
           fnd_document_categories_tl fnddoccat_tl,
           fnd_attached_documents fndattdoc, fnd_lobs lobs,
           csl_jtf_tasks_acc acc, asg_user asg
      WHERE fndattdoc.document_id = fnddoc_tl.document_id
      AND fnddoc_tl.language = asg.language
      AND fnddoc_tl.document_id = fnddoc.document_id
      AND fnddoc_tl.media_id = lobs.file_id
      AND fnddoccat_tl.category_id = fnddoc.category_id
      AND fnddoccat_tl.language = asg.language
      AND fndattdoc.pk1_value = to_char(acc.task_id)
      AND asg.resource_id = acc.resource_id
      AND fnddoccat_tl.name = 'MISC'
      AND fndattdoc.entity_name = 'JTF_TASKS_B'
      AND fnddoc.datatype_id=6
      AND fndattdoc.last_update_date >= b_lastRundate;

/* For future support
--Cursor to get the Customer attachemnts
    CURSOR c_PartyAtt (b_lastRundate date) IS
      SELECT  lobs.file_id, acc.resource_id
      FROM fnd_documents_tl fnddoc_tl, fnd_documents fnddoc,
           fnd_document_categories_tl fnddoccat_tl,
           fnd_attached_documents fndattdoc, fnd_lobs lobs,
           csl_hz_parties_acc acc, asg_user asg
      WHERE fndattdoc.document_id = fnddoc_tl.document_id
      AND fnddoc_tl.language = asg.language
      AND fnddoc_tl.document_id = fnddoc.document_id
      AND fnddoc_tl.media_id = lobs.file_id
      AND fnddoccat_tl.category_id = fnddoc.category_id
      AND fnddoccat_tl.language = asg.language
      AND fndattdoc.pk1_value = to_char(acc.party_id)
      AND asg.resource_id = acc.resource_id
      AND fnddoccat_tl.name = 'MISC'
      AND fndattdoc.entity_name = 'HZ_PARTIES'
      AND fnddoc.datatype_id=6
      AND fndattdoc.last_update_date >= b_lastRundate;

    --Cursor to get the IB Item attachemnts
    CURSOR c_IBItemAtt (b_lastRundate date) IS
      SELECT  lobs.file_id, acc.resource_id
      FROM fnd_documents_tl fnddoc_tl, fnd_documents fnddoc,
           fnd_document_categories_tl fnddoccat_tl,
           fnd_attached_documents fndattdoc, fnd_lobs lobs,
           csl_csi_item_instances_acc acc, asg_user asg
      WHERE fndattdoc.document_id = fnddoc_tl.document_id
      AND fnddoc_tl.language = asg.language
      AND fnddoc_tl.document_id = fnddoc.document_id
      AND fnddoc_tl.media_id = lobs.file_id
      AND fnddoccat_tl.category_id = fnddoc.category_id
      AND fnddoccat_tl.language = asg.language
      AND fndattdoc.pk1_value = to_char(acc.instance_id)
      AND asg.resource_id = acc.resource_id
      AND fnddoccat_tl.name = 'MISC'
      AND fndattdoc.entity_name = 'CS_CUSTOMER_PRODUCTS_ALL'
      AND fnddoc.datatype_id=6
      AND fndattdoc.last_update_date >= b_lastRundate;

    --Cursor to get the debrief attachemnts
    CURSOR c_DebriefAtt (b_lastRundate date) IS
      SELECT  lobs.file_id, acc.resource_id
      FROM fnd_documents_tl fnddoc_tl, fnd_documents fnddoc,
           fnd_document_categories_tl fnddoccat_tl,
           fnd_attached_documents fndattdoc, fnd_lobs lobs,
           JTM_CSF_DEBRIEF_HEADERS_ACC acc, asg_user asg
      WHERE fndattdoc.document_id = fnddoc_tl.document_id
      AND fnddoc_tl.language = asg.language
      AND fnddoc_tl.document_id = fnddoc.document_id
      AND fnddoc_tl.media_id = lobs.file_id
      AND fnddoccat_tl.category_id = fnddoc.category_id
      AND fnddoccat_tl.language = asg.language
      AND fndattdoc.pk1_value = to_char(acc.debrief_header_id)
      AND asg.resource_id = acc.resource_id
      AND fnddoccat_tl.name = 'MISC'
      AND fndattdoc.entity_name = 'CSF_DEBRIEF_HEADERS'
      AND fnddoc.datatype_id=6
      AND fndattdoc.last_update_date >= b_lastRundate;
*/

   r_LastRundate  c_LastRundate%ROWTYPE;
   l_current_run_date DATE;
   l_dummy        BOOLEAN;

   l_tab_access_id   ASG_DOWNLOAD.ACCESS_LIST;

   l_tab_resource_id ASG_DOWNLOAD.USER_LIST;

BEGIN

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

    /*** First retrieve last run date of the conccurent program ***/
    OPEN  c_LastRundate;
    FETCH c_LastRundate  INTO r_LastRundate;
    CLOSE c_LastRundate;

    l_current_run_date := SYSDATE;

    --SR
    l_tab_access_id.delete;
    l_tab_resource_id.delete;


    --If the max size of attachment is less than 1, then exit.
    IF (TO_NUMBER(FND_PROFILE.Value('CSM_MAX_ATTACHMENT_SIZE')) < 1) THEN
      /*Update the last run date*/
      UPDATE jtm_con_request_data SET last_run_date = l_current_run_date
       WHERE package_name =  'CSL_LOBS_ACC_PKG'
       AND   procedure_name = 'CONC_DOWNLOAD_ATTACHMENTS';

      COMMIT;

      p_status := 'FINE';
      p_message :=  'CSL_LOBS_ACC_PKG.CONC_DOWNLOAD_ATTACHMENTS '
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

    OPEN c_SRAtt(r_LastRundate.last_run_date);
    FETCH c_SRAtt BULK COLLECT INTO l_tab_access_id, l_tab_resource_id;
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

      l_dummy := asg_download.markdirty(
           P_PUB_ITEM     => g_publication_item_name(1)
           , P_ACCESSLIST   => l_tab_access_id
           , P_RESOURCELIST => l_tab_resource_id
           , P_DML_TYPE     => 'I'
           , P_TIMESTAMP    => SYSDATE);

    END IF;


    --TASK
    l_tab_access_id.delete;
    l_tab_resource_id.delete;

    OPEN c_TaskAtt(r_LastRundate.last_run_date);
    FETCH c_TaskAtt BULK COLLECT INTO l_tab_access_id, l_tab_resource_id;
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

      l_dummy := asg_download.markdirty(
           P_PUB_ITEM     => g_publication_item_name(1)
           , P_ACCESSLIST   => l_tab_access_id
           , P_RESOURCELIST => l_tab_resource_id
           , P_DML_TYPE     => 'I'
           , P_TIMESTAMP    => SYSDATE);

    END IF;

/*For future support
    --Customer
    l_tab_access_id.delete;
    l_tab_resource_id.delete;

    OPEN c_PartyAtt(r_LastRundate.last_run_date);
    FETCH c_PartyAtt BULK COLLECT INTO l_tab_access_id, l_tab_resource_id;
    CLOSE c_PartyAtt;

    IF l_tab_access_id.COUNT > 0 THEN
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
       jtm_message_log_pkg.Log_Msg
        ( 0
        , g_table_name
        , 'Pushing ' || l_tab_access_id.COUNT || ' updated record(s)'
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
       );
      END IF;

      l_dummy := asg_download.markdirty(
           P_PUB_ITEM     => g_publication_item_name(1)
           , P_ACCESSLIST   => l_tab_access_id
           , P_RESOURCELIST => l_tab_resource_id
           , P_DML_TYPE     => 'I'
           , P_TIMESTAMP    => SYSDATE);

    END IF;

    --IB Item
    l_tab_access_id.delete;
    l_tab_resource_id.delete;

    OPEN c_IBItemAtt(r_LastRundate.last_run_date);
    FETCH c_IBItemAtt BULK COLLECT INTO l_tab_access_id, l_tab_resource_id;
    CLOSE c_IBItemAtt;

    IF l_tab_access_id.COUNT > 0 THEN
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
       jtm_message_log_pkg.Log_Msg
        ( 0
        , g_table_name
        , 'Pushing ' || l_tab_access_id.COUNT || ' updated record(s)'
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
       );
      END IF;

      l_dummy := asg_download.markdirty(
           P_PUB_ITEM     => g_publication_item_name(1)
           , P_ACCESSLIST   => l_tab_access_id
           , P_RESOURCELIST => l_tab_resource_id
           , P_DML_TYPE     => 'I'
           , P_TIMESTAMP    => SYSDATE);

    END IF;


    --DEBRIEF
    l_tab_access_id.delete;
    l_tab_resource_id.delete;

    OPEN c_DebriefAtt(r_LastRundate.last_run_date);
    FETCH c_DebriefAtt BULK COLLECT INTO l_tab_access_id, l_tab_resource_id;
    CLOSE c_DebriefAtt;

    IF l_tab_access_id.COUNT > 0 THEN
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
       jtm_message_log_pkg.Log_Msg
        ( 0
        , g_table_name
        , 'Pushing ' || l_tab_access_id.COUNT || ' updated record(s)'
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
       );
      END IF;

      l_dummy := asg_download.markdirty(
           P_PUB_ITEM     => g_publication_item_name(1)
           , P_ACCESSLIST   => l_tab_access_id
           , P_RESOURCELIST => l_tab_resource_id
           , P_DML_TYPE     => 'I'
           , P_TIMESTAMP    => SYSDATE);

    END IF;
*/

    /*Update the last run date*/
    UPDATE jtm_con_request_data SET last_run_date = l_current_run_date
     WHERE package_name =  'CSL_LOBS_ACC_PKG'
     AND   procedure_name = 'CONC_DOWNLOAD_ATTACHMENTS';

    COMMIT;

   p_status := 'FINE';
   p_message :=  'CSL_LOBS_ACC_PKG.CONC_DOWNLOAD_ATTACHMENTS '
                 || ' Executed successfully';

   IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
     jtm_message_log_pkg.Log_Msg
     ( 0
     , g_table_name
     , 'Leaving CONC_DOWNLOAD_ATTACHMENTS'
     , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
     );
   END IF;

EXCEPTION

   WHEN OTHERS THEN
     p_status := 'ERROR';
     p_message := 'Error in '||
                  'CSL_LOBS_ACC_PKG.CONC_DOWNLOAD_ATTACHMENTS: '
                  || substr(SQLERRM, 1, 2000);


     IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
       jtm_message_log_pkg.Log_Msg
         ( 0
         , g_table_name
         , 'CONC_DOWNLOAD_ATTACHMENTS'||fnd_global.local_chr(10)||
           'Error: '||sqlerrm
         , JTM_HOOK_UTIL_PKG.g_debug_level_error);
     END IF;
     ROLLBACK;

END CONC_DOWNLOAD_ATTACHMENTS;

--Bug 3724142
--To download attachment linked to a particular SR. Called by the
--incidents API.
PROCEDURE DOWNLOAD_SR_ATTACHMENTS ( p_incident_id IN NUMBER)
IS

    --Cursor to get the SR attachemnts
    CURSOR c_SRAtt (b_incident_id number) IS
      SELECT  lobs.file_id, acc.resource_id
      FROM fnd_documents_tl fnddoc_tl, fnd_documents fnddoc,
           fnd_document_categories_tl fnddoccat_tl,
           fnd_attached_documents fndattdoc, fnd_lobs lobs,
           csl_cs_incidents_all_acc acc, asg_user asg
      WHERE fndattdoc.document_id = fnddoc_tl.document_id
      AND fnddoc_tl.language = asg.language
      AND fnddoc_tl.document_id = fnddoc.document_id
      AND fnddoc_tl.media_id = lobs.file_id
      AND fnddoccat_tl.category_id = fnddoc.category_id
      AND fnddoccat_tl.language = asg.language
      AND fndattdoc.pk1_value = to_char(acc.incident_id)
      AND asg.resource_id = acc.resource_id
      AND fnddoccat_tl.name = 'MISC'
      AND fndattdoc.entity_name = 'CS_INCIDENTS'
      AND fnddoc.datatype_id=6
      AND acc.incident_id = b_incident_id;

   l_dummy        BOOLEAN;
   l_tab_access_id   ASG_DOWNLOAD.ACCESS_LIST;
   l_tab_resource_id ASG_DOWNLOAD.USER_LIST;

BEGIN

    /*** get debug level ***/
    g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;
    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( 0
      , g_table_name
      , 'Entering DOWNLOAD_SR_ATTACHMENTS'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
      );
    END IF;

    --SR
    l_tab_access_id.delete;
    l_tab_resource_id.delete;


    --If the max size of attachment is less than 1, then exit.
    IF (TO_NUMBER(FND_PROFILE.Value('CSM_MAX_ATTACHMENT_SIZE')) < 1) THEN
      /*Update the last run date*/

      IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
        jtm_message_log_pkg.Log_Msg
        ( 0
        , g_table_name
        , 'Leaving DOWNLOAD_SR_ATTACHMENTS - Max att download size is less than 1'
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
        );
      END IF;

      RETURN;
    END IF;

    OPEN c_SRAtt(p_incident_id);
    FETCH c_SRAtt BULK COLLECT INTO l_tab_access_id, l_tab_resource_id;
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

      l_dummy := asg_download.markdirty(
           P_PUB_ITEM     => g_publication_item_name(1)
           , P_ACCESSLIST   => l_tab_access_id
           , P_RESOURCELIST => l_tab_resource_id
           , P_DML_TYPE     => 'I'
           , P_TIMESTAMP    => SYSDATE);

    END IF;


   IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
     jtm_message_log_pkg.Log_Msg
     ( 0
     , g_table_name
     , 'Leaving DOWNLOAD_SR_ATTACHMENTS'
     , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
     );
   END IF;

EXCEPTION

   WHEN OTHERS THEN
     IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
       jtm_message_log_pkg.Log_Msg
         ( 0
         , g_table_name
         , 'DOWNLOAD_SR_ATTACHMENTS'||fnd_global.local_chr(10)||
           'Error: '||sqlerrm
         , JTM_HOOK_UTIL_PKG.g_debug_level_error);
     END IF;
     ROLLBACK;

END DOWNLOAD_SR_ATTACHMENTS;


--Bug 3724142
--To download attachment linked to a particular task. Called by the
--Tasks API.
PROCEDURE DOWNLOAD_TASK_ATTACHMENTS ( p_task_id IN NUMBER)
IS

    --Cursor to get the SR attachemnts
    CURSOR c_TaskAtt (b_task_id number) IS
      SELECT  lobs.file_id, acc.resource_id
      FROM fnd_documents_tl fnddoc_tl, fnd_documents fnddoc,
           fnd_document_categories_tl fnddoccat_tl,
           fnd_attached_documents fndattdoc, fnd_lobs lobs,
           csl_jtf_tasks_acc acc, asg_user asg
      WHERE fndattdoc.document_id = fnddoc_tl.document_id
      AND fnddoc_tl.language = asg.language
      AND fnddoc_tl.document_id = fnddoc.document_id
      AND fnddoc_tl.media_id = lobs.file_id
      AND fnddoccat_tl.category_id = fnddoc.category_id
      AND fnddoccat_tl.language = asg.language
      AND fndattdoc.pk1_value = to_char(acc.task_id)
      AND asg.resource_id = acc.resource_id
      AND fnddoccat_tl.name = 'MISC'
      AND fndattdoc.entity_name = 'JTF_TASKS_B'
      AND fnddoc.datatype_id=6
      AND acc.task_id = b_task_id;

   l_dummy           BOOLEAN;
   l_tab_access_id   ASG_DOWNLOAD.ACCESS_LIST;
   l_tab_resource_id ASG_DOWNLOAD.USER_LIST;

BEGIN

    /*** get debug level ***/
    g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;
    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( 0
      , g_table_name
      , 'Entering DOWNLOAD_TASK_ATTACHMENTS'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
      );
    END IF;

    --If the max size of attachment is less than 1, then exit.
    IF (TO_NUMBER(FND_PROFILE.Value('CSM_MAX_ATTACHMENT_SIZE')) < 1) THEN

      IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
        jtm_message_log_pkg.Log_Msg
        ( 0
        , g_table_name
        , 'Leaving DOWNLOAD_TASK_ATTACHMENTS - Max att download size is less than 1'
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
        );
      END IF;

      RETURN;
    END IF;

    --TASK
    l_tab_access_id.delete;
    l_tab_resource_id.delete;

    OPEN c_TaskAtt(p_task_id);
    FETCH c_TaskAtt BULK COLLECT INTO l_tab_access_id, l_tab_resource_id;
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

      l_dummy := asg_download.markdirty(
           P_PUB_ITEM     => g_publication_item_name(1)
           , P_ACCESSLIST   => l_tab_access_id
           , P_RESOURCELIST => l_tab_resource_id
           , P_DML_TYPE     => 'I'
           , P_TIMESTAMP    => SYSDATE);

    END IF;

   IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
     jtm_message_log_pkg.Log_Msg
     ( 0
     , g_table_name
     , 'Leaving DOWNLOAD_TASK_ATTACHMENTS'
     , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
     );
   END IF;

EXCEPTION

   WHEN OTHERS THEN
     IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
       jtm_message_log_pkg.Log_Msg
         ( 0
         , g_table_name
         , 'DOWNLOAD_TASK_ATTACHMENTS'||fnd_global.local_chr(10)||
           'Error: '||sqlerrm
         , JTM_HOOK_UTIL_PKG.g_debug_level_error);
     END IF;
     ROLLBACK;

END DOWNLOAD_TASK_ATTACHMENTS;

--Bug 3724142
--To delete the attachment when SR/Task is deleted
PROCEDURE DELETE_ATTACHMENTS ( p_entity_name IN VARCHAR2,
                                p_primary_key IN NUMBER,
                                p_resource_id IN NUMBER)

  IS

    CURSOR c_SRAtt ( b_incident_id IN NUMBER,
                     b_resource_id IN NUMBER) IS
      SELECT  lobs.file_id, b_resource_id
      FROM fnd_documents_tl fnddoc_tl, fnd_documents fnddoc,
           fnd_document_categories_tl fnddoccat_tl,
           fnd_attached_documents fndattdoc, fnd_lobs lobs,
           asg_user asg
      WHERE fndattdoc.document_id = fnddoc_tl.document_id
      AND fnddoc_tl.language = asg.language
      AND fnddoc_tl.document_id = fnddoc.document_id
      AND fnddoc_tl.media_id = lobs.file_id
      AND fnddoccat_tl.category_id = fnddoc.category_id
      AND fnddoccat_tl.language = asg.language
      AND fnddoccat_tl.name = 'MISC'
      AND fndattdoc.entity_name = 'CS_INCIDENTS'
      AND fnddoc.datatype_id=6
      AND fndattdoc.pk1_value = to_char(b_incident_id)
      AND asg.resource_id = b_resource_id;

    CURSOR c_TaskAtt ( b_task_id IN NUMBER,
                       b_resource_id IN NUMBER) IS
      SELECT  lobs.file_id, b_resource_id
      FROM fnd_documents_tl fnddoc_tl, fnd_documents fnddoc,
           fnd_document_categories_tl fnddoccat_tl,
           fnd_attached_documents fndattdoc, fnd_lobs lobs,
           asg_user asg
      WHERE fndattdoc.document_id = fnddoc_tl.document_id
      AND fnddoc_tl.language = asg.language
      AND fnddoc_tl.document_id = fnddoc.document_id
      AND fnddoc_tl.media_id = lobs.file_id
      AND fnddoccat_tl.category_id = fnddoc.category_id
      AND fnddoccat_tl.language = asg.language
      AND fnddoccat_tl.name = 'MISC'
      AND fndattdoc.entity_name = 'JTF_TASKS_B'
      AND fnddoc.datatype_id=6
      AND fndattdoc.pk1_value = to_char(b_task_id)
      AND asg.resource_id = b_resource_id;

   r_SRAtt  c_SRAtt%ROWTYPE;
   r_TaskAtt  c_TaskAtt%ROWTYPE;

   l_dummy        BOOLEAN;
   l_tab_access_id   ASG_DOWNLOAD.ACCESS_LIST;
   l_tab_resource_id ASG_DOWNLOAD.USER_LIST;

   l_err_mesg    VARCHAR2(1000);
  BEGIN

    g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( p_primary_key
      , g_table_name
      , 'Entering Delete_Attachments'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;

    IF (p_entity_name = 'CS_INCIDENTS') THEN

      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( p_primary_key
        , g_table_name
        , 'Deleting record for CS_INCIDENTS and resource_id: ' || p_resource_id
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;

      OPEN c_SRAtt(p_primary_key, p_resource_id);
      FETCH c_SRAtt BULK COLLECT INTO l_tab_access_id, l_tab_resource_id;
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

        l_dummy := asg_download.markdirty(
             P_PUB_ITEM     => g_publication_item_name(1)
             , P_ACCESSLIST   => l_tab_access_id
             , P_RESOURCELIST => l_tab_resource_id
             , P_DML_TYPE     => 'D'
             , P_TIMESTAMP    => SYSDATE);

      END IF;

    END IF; --IF (p_entity_name = 'CS_INCIDENTS') THEN


    IF (p_entity_name = 'JTF_TASKS_B') THEN

      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( p_primary_key
        , g_table_name
        , 'Deleting record for JTF_TASKS_B and resource_id: ' || p_resource_id
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;

      OPEN c_TaskAtt(p_primary_key, p_resource_id);
      FETCH c_TaskAtt BULK COLLECT INTO l_tab_access_id, l_tab_resource_id;
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

        l_dummy := asg_download.markdirty(
             P_PUB_ITEM     => g_publication_item_name(1)
             , P_ACCESSLIST   => l_tab_access_id
             , P_RESOURCELIST => l_tab_resource_id
             , P_DML_TYPE     => 'D'
             , P_TIMESTAMP    => SYSDATE);

      END IF;
    END IF; --IF (p_entity_name = 'JTF_TASKS_B') THEN

    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( p_primary_key
      , g_table_name
      , 'Exiting Delete_Attachments'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;

  EXCEPTION

    WHEN OTHERS THEN
      l_err_mesg := 'EXCEPTION IN ' || p_entity_name
                  || ' '|| substr(sqlerrm, 0 , 255);
      jtm_message_log_pkg.Log_Msg (
         p_primary_key
         , 'LOBS_ACC_PKG.DELETE_ATTACHMENTS'
         , l_err_mesg
         , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
      RAISE;

  END DELETE_ATTACHMENTS;

END CSL_LOBS_ACC_PKG;

/
