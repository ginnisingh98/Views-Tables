--------------------------------------------------------
--  DDL for Package Body CSM_TASK_ASSIGNMENT_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_TASK_ASSIGNMENT_EVENT_PKG" AS
/* $Header: csmetab.pls 120.8 2006/09/15 13:00:29 trajasek noship $ */

/*** Globals ***/
g_acc_table_name        CONSTANT VARCHAR2(30) := 'CSM_TASK_ASSIGNMENTS_ACC';
g_table_name            CONSTANT VARCHAR2(30) := 'JTF_TASK_ASSIGNMENTS';
g_acc_seq_name          CONSTANT VARCHAR2(30) := 'CSM_TASK_ASSIGNMENTS_ACC_S' ;
g_pk1_name              CONSTANT VARCHAR2(30) := 'TASK_ASSIGNMENT_ID';
g_pubi_name             CONSTANT CSM_ACC_PKG.t_publication_item_list :=
  CSM_ACC_PKG.t_publication_item_list('CSM_TASK_ASSIGNMENTS');

/**
** Conc program called every midnight to purge task assignments depending on the
** history profile of the user
**/
PROCEDURE PURGE_TASK_ASSIGNMENTS_CONC(p_status OUT NOCOPY VARCHAR2, p_message OUT NOCOPY VARCHAR2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
l_task_assignment_id jtf_task_assignments.task_assignment_id%TYPE;
l_task_id 			 jtf_task_assignments.task_id%TYPE;
l_resource_id jtf_task_assignments.resource_id%TYPE;
l_user_id number;
l_dummy number;
l_last_run_date date;

l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

CURSOR l_purge_task_assignments_csr
IS
SELECT /*+ INDEX (acc CSM_TASK_ASSIGNMENTS_ACC_U1)*/
	 acc.task_assignment_id,
	 jt.task_id,
	 jt.source_object_type_code
FROM csm_task_assignments_acc acc,
     jtf_task_assignments jta,
     jtf_tasks_b jt,
     jtf_task_statuses_b jts,
     jtf_task_statuses_b jts_jta
WHERE acc.task_assignment_id = jta.task_assignment_id
  AND jt.task_id = jta.task_id
  AND (jt.scheduled_start_date
      < (SYSDATE - csm_profile_pkg.get_task_history_days(acc.user_id)))
  AND jts.task_status_id = jt.task_status_id
  AND jts_jta.task_status_id = jta.assignment_status_id
  AND (jts.cancelled_flag = 'Y' OR jts.closed_flag = 'Y'
     OR jts.completed_flag = 'Y'   OR jts.rejected_flag = 'Y'
     OR jts_jta.cancelled_flag = 'Y' OR jts_jta.closed_flag = 'Y'
     OR jts_jta.completed_flag = 'Y' OR jts_jta.rejected_flag = 'Y')
  AND NOT EXISTS (SELECT 'x'
                    FROM csm_service_history_acc hist,
                         cs_incidents_all_b  cia,
                         cs_incident_statuses_b ists
                   WHERE hist.user_id = acc.user_id
                     AND hist.history_incident_id = jt.source_object_id
                     AND jt.source_object_type_code = 'SR'
                     AND hist.incident_id = cia.incident_id
                     AND cia.INCIDENT_STATUS_ID = ists.INCIDENT_STATUS_ID
                     AND NVL(ists.CLOSE_FLAG, 'N') <> 'Y');

TYPE l_purge_task_tbl_type 		IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE l_task_src_type_tbl_type   IS TABLE OF jtf_tasks_b.source_object_type_code%TYPE INDEX BY BINARY_INTEGER;

l_purge_task_assignment_tbl    l_purge_task_tbl_type;
l_task_src_type_tbl 		   l_task_src_type_tbl_type;
l_purge_task_tbl    		   l_purge_task_tbl_type;

CURSOR l_upd_last_run_date_csr
IS
SELECT 1
FROM jtm_con_request_data
WHERE product_code = 'CSM'
AND package_name = 'CSM_TASK_ASSIGNMENT_EVENT_PKG'
AND procedure_name = 'PURGE_TASK_ASSIGNMENTS_CONC'
FOR UPDATE OF last_run_date NOWAIT
;

BEGIN
  l_last_run_date := SYSDATE;

  OPEN l_purge_task_assignments_csr;
  LOOP
    IF l_purge_task_tbl.COUNT > 0 THEN
       l_purge_task_tbl.DELETE;
    END IF;

    IF l_task_src_type_tbl.COUNT > 0 THEN
       l_task_src_type_tbl.DELETE;
    END IF;

  FETCH l_purge_task_assignments_csr BULK COLLECT INTO l_purge_task_assignment_tbl,l_purge_task_tbl,l_task_src_type_tbl LIMIT 10;
  EXIT WHEN l_purge_task_assignment_tbl.COUNT = 0;

  IF l_purge_task_assignment_tbl.COUNT > 0 THEN
    CSM_UTIL_PKG.LOG(TO_CHAR(l_purge_task_assignment_tbl.COUNT) || ' records sent for purge', 'CSM_TASK_ASSIGNMENT_EVENT_PKG.PURGE_TASK_ASSIGNMENTS_CONC',FND_LOG.LEVEL_EVENT);
    FOR i IN l_purge_task_assignment_tbl.FIRST..l_purge_task_assignment_tbl.LAST LOOP

		l_task_assignment_id := l_purge_task_assignment_tbl(i);
		l_task_id			 := l_purge_task_tbl(i);
		--Delete SR tasks only if the corresponding SR is closed
		IF l_task_src_type_tbl(i) ='SR' AND CSM_SR_EVENT_PKG.IS_SR_OPEN(l_task_id) = FALSE THEN

      	   		csm_task_assignment_event_pkg.TASK_ASSIGNMENT_PURGE_INIT(p_task_assignment_id=>l_task_assignment_id,
                                                           p_error_msg=>l_error_msg,
                                                           x_return_status=>l_return_status);
		ELSIF l_task_src_type_tbl(i) ='TASK' THEN
      	   		csm_task_assignment_event_pkg.TASK_ASSIGNMENT_PURGE_INIT(p_task_assignment_id=>l_task_assignment_id,
                                                           p_error_msg=>l_error_msg,
                                                           x_return_status=>l_return_status);

		END IF;
    END LOOP;
  END IF;
  -- commit after every 10 records
  COMMIT;
  END LOOP;
  CLOSE l_purge_task_assignments_csr;
   -- update last_run_date
   OPEN l_upd_last_run_date_csr;
   FETCH l_upd_last_run_date_csr INTO l_dummy;
   IF l_upd_last_run_date_csr%FOUND THEN
     UPDATE jtm_con_request_data
     SET last_run_date = l_last_run_date
     WHERE CURRENT OF l_upd_last_run_date_csr;
   END IF;
   CLOSE l_upd_last_run_date_csr;
   COMMIT;

  p_status := 'SUCCESS';
  p_message :=  'CSM_TASK_ASSIGNMENT_EVENT_PKG.PURGE_TASK_ASSIGNMENTS_CONC Executed successfully';

EXCEPTION
  WHEN OTHERS THEN
      l_sqlerrno := to_char(SQLCODE);
      l_sqlerrmsg := substr(SQLERRM, 1,2000);
      ROLLBACK;
      l_error_msg := ' Exception in  PURGE_TASK_ASSIGNMENTS_CONC for task_assignment_id:' || to_char(l_task_assignment_id)
                           || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
      CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_TASK_ASSIGNMENT_EVENT_PKG.PURGE_TASK_ASSIGNMENTS_CONC',FND_LOG.LEVEL_EVENT);
      p_status := 'ERROR';
      p_message := 'Error in CSM_TASK_ASSIGNMENT_EVENT_PKG.PURGE_TASK_ASSIGNMENTS_CONC: ' || l_error_msg;
--    x_return_status := FND_API.G_RET_STS_ERROR ;
   -- RAISE;
END PURGE_TASK_ASSIGNMENTS_CONC;

PROCEDURE SPAWN_DEBRIEF_HEADER_INS (p_task_assignment_id IN NUMBER,
                                    p_user_id IN NUMBER,
                                    p_flow_type IN VARCHAR2)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

-- cursor to get all debrief header id
CURSOR l_debrief_header_csr(p_task_assg_id jtf_task_assignments.task_assignment_id%TYPE)
IS
SELECT dh.debrief_header_id
FROM  csf_debrief_headers dh
WHERE dh.task_assignment_id =p_task_assg_id
AND NOT EXISTS
(SELECT 1
 FROM csm_debrief_headers_acc acc
 WHERE acc.debrief_header_id = dh.debrief_header_id
 AND acc.user_id = p_user_id);

BEGIN
   CSM_UTIL_PKG.LOG('Entering SPAWN_DEBRIEF_HEADER_INS for task_assignment_id: ' || p_task_assignment_id,
                                   'CSM_TASK_ASSIGNMENT_EVENT_PKG.SPAWN_DEBRIEF_HEADER_INS',FND_LOG.LEVEL_PROCEDURE);

    FOR r_debrief_header_rec IN l_debrief_header_csr(p_task_assignment_id) LOOP
       -- insert debrief headers
       csm_debrief_header_event_pkg.debrief_header_ins_init(p_debrief_header_id=>r_debrief_header_rec.debrief_header_id,
                                                            p_h_user_id=>p_user_id,
                                                            p_flow_type=>p_flow_type);
    END LOOP;

   CSM_UTIL_PKG.LOG('Leaving SPAWN_DEBRIEF_HEADER_INS for task_assignment_id: ' || p_task_assignment_id,
                                   'CSM_TASK_ASSIGNMENT_EVENT_PKG.SPAWN_DEBRIEF_HEADER_INS',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  SPAWN_DEBRIEF_HEADER_INS for task_assignment_id:'
                       || to_char(p_task_assignment_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_TASK_ASSIGNMENT_EVENT_PKG.SPAWN_DEBRIEF_HEADER_INS',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END SPAWN_DEBRIEF_HEADER_INS;

PROCEDURE SPAWN_DEBRIEF_LINE_INS (p_task_assignment_id IN NUMBER,
                                  p_user_id IN NUMBER,
                                  p_flow_type IN VARCHAR2)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

-- cursor to get all debrief line id
CURSOR l_debrief_lines_csr(p_task_assg_id jtf_task_assignments.task_assignment_id%TYPE)
IS
SELECT dl.debrief_line_id,
      dh.debrief_header_id
FROM csf_debrief_lines dl,
     csf_debrief_headers dh
WHERE dh.task_assignment_id =p_task_assg_id
AND dl.debrief_header_id = dh.debrief_header_id
AND NOT EXISTS
(SELECT 1
 FROM csm_debrief_lines_acc acc
 WHERE acc.debrief_line_id = dl.debrief_line_id
 AND acc.user_id = p_user_id);

BEGIN
   CSM_UTIL_PKG.LOG('Entering SPAWN_DEBRIEF_LINE_INS for task_assignment_id: ' || p_task_assignment_id,
                                   'CSM_TASK_ASSIGNMENT_EVENT_PKG.SPAWN_DEBRIEF_LINE_INS',FND_LOG.LEVEL_PROCEDURE);

    FOR r_debrief_line_rec IN l_debrief_lines_csr(p_task_assignment_id) LOOP
       -- insert debrief lines
       csm_debrief_event_pkg.debrief_line_ins_init(p_debrief_line_id=>r_debrief_line_rec.debrief_line_id,
                                                   p_h_user_id=>p_user_id,
                                                   p_flow_type=>p_flow_type);
    END LOOP;

   CSM_UTIL_PKG.LOG('Leaving SPAWN_DEBRIEF_LINE_INS for task_assignment_id: ' || p_task_assignment_id,
                                   'CSM_TASK_ASSIGNMENT_EVENT_PKG.SPAWN_DEBRIEF_LINE_INS',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  SPAWN_DEBRIEF_LINE_INS for task_assignment_id:'
                       || to_char(p_task_assignment_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_TASK_ASSIGNMENT_EVENT_PKG.SPAWN_DEBRIEF_LINE_INS',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END SPAWN_DEBRIEF_LINE_INS;

PROCEDURE SPAWN_REQUIREMENT_HEADER_INS(p_task_assignment_id IN NUMBER,
                                       p_user_id IN NUMBER,
                                       p_flow_type IN VARCHAR2)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

-- cursor to get all requirement headers for the task_id
CURSOR l_req_headers_csr(p_task_assg_id IN jtf_task_assignments.task_assignment_id%TYPE,
                         p_user_id IN NUMBER)
IS
SELECT hdr.requirement_header_id,
      jta.resource_id
FROM jtf_task_assignments jta,
     csp_requirement_headers hdr
WHERE jta.task_assignment_id = p_task_assg_id
AND hdr.task_id = jta.task_id
AND NOT EXISTS
(SELECT 1
 FROM csm_req_headers_acc acc
 WHERE acc.requirement_header_id = hdr.requirement_header_id
 AND acc.user_id = p_user_id
 );

BEGIN
   CSM_UTIL_PKG.LOG('Entering SPAWN_REQUIREMENT_HEADER_INS for task_assignment_id: ' || p_task_assignment_id,
                                   'CSM_TASK_ASSIGNMENT_EVENT_PKG.SPAWN_REQUIREMENT_HEADER_INS',FND_LOG.LEVEL_PROCEDURE);

   IF p_flow_type IS NULL OR p_flow_type <> 'HISTORY' THEN
     FOR r_req_headers_rec IN l_req_headers_csr(p_task_assignment_id, p_user_id) LOOP
        -- insert requirement headers
        csm_csp_req_headers_event_pkg.csp_req_headers_mdirty_i(p_requirement_header_id=>r_req_headers_rec.requirement_header_id,
                                                               p_user_id=>p_user_id);
     END LOOP;
   END IF;

   CSM_UTIL_PKG.LOG('Leaving SPAWN_REQUIREMENT_HEADER_INS for task_assignment_id: ' || p_task_assignment_id,
                                   'CSM_TASK_ASSIGNMENT_EVENT_PKG.SPAWN_REQUIREMENT_HEADER_INS',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  SPAWN_REQUIREMENT_HEADER_INS for task_assignment_id:'
                       || to_char(p_task_assignment_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_TASK_ASSIGNMENT_EVENT_PKG.SPAWN_REQUIREMENT_HEADER_INS',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END SPAWN_REQUIREMENT_HEADER_INS;

PROCEDURE SPAWN_REQUIREMENT_LINES_INS(p_task_assignment_id IN NUMBER,
                                       p_user_id IN NUMBER,
                                       p_flow_type IN VARCHAR2)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

-- cursor to get all requirement lines for the task_id
CURSOR l_req_lines_csr(p_task_assg_id IN jtf_task_assignments.task_assignment_id%TYPE,
                        p_user_id IN NUMBER)
IS
SELECT line.requirement_line_id,
      line.requirement_header_id,
      jta.resource_id
FROM jtf_task_assignments jta,
     csp_requirement_headers hdr,
     csp_requirement_lines line
WHERE jta.task_assignment_id = p_task_assg_id
AND hdr.task_id = jta.task_id
AND line.requirement_header_id = hdr.requirement_header_id
AND NOT EXISTS
(SELECT 1
 FROM csm_req_lines_acc acc
 WHERE acc.requirement_line_id = line.requirement_line_id
 AND acc.user_id = p_user_id
 );

BEGIN
   CSM_UTIL_PKG.LOG('Entering SPAWN_REQUIREMENTS_INS for task_assignment_id: ' || p_task_assignment_id,
                                   'CSM_TASK_ASSIGNMENT_EVENT_PKG.SPAWN_REQUIREMENTS_INS',FND_LOG.LEVEL_PROCEDURE);

   IF p_flow_type IS NULL OR p_flow_type <> 'HISTORY' THEN
     FOR r_req_lines_rec IN l_req_lines_csr(p_task_assignment_id, p_user_id) LOOP
        -- insert requirement lines
        csm_csp_req_lines_event_pkg.csp_req_lines_mdirty_i(p_requirement_line_id=>r_req_lines_rec.requirement_line_id,
                                                           p_user_id=>p_user_id);
     END LOOP;
   END IF;

   CSM_UTIL_PKG.LOG('Leaving SPAWN_REQUIREMENTS_INS for task_assignment_id: ' || p_task_assignment_id,
                                   'CSM_TASK_ASSIGNMENT_EVENT_PKG.SPAWN_REQUIREMENTS_INS',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  SPAWN_REQUIREMENTS_INS for task_assignment_id:'
                       || to_char(p_task_assignment_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_TASK_ASSIGNMENT_EVENT_PKG.SPAWN_REQUIREMENTS_INS',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END SPAWN_REQUIREMENT_LINES_INS;

PROCEDURE TASK_ASSIGNMENTS_ACC_PROCESSOR(p_task_assignment_id IN NUMBER,
                                         p_incident_id IN NUMBER,
                                         p_task_id IN NUMBER,
                                         p_source_object_type_code IN VARCHAR2,
                                         p_flow_type IN VARCHAR2,
                                         p_user_id IN NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);
l_dummy NUMBER;

CURSOR l_task_access_csr(p_task_id IN NUMBER, p_user_id IN NUMBER)
IS
SELECT 1
FROM csm_tasks_acc
WHERE user_id = p_user_id
AND task_id = p_task_id;

BEGIN
   CSM_UTIL_PKG.LOG('Entering TASK_ASSIGNMENTS_ACC_PROCESSOR for task_assignment_id: ' || p_task_assignment_id,
                                   'CSM_TASK_ASSIGNMENT_EVENT_PKG.TASK_ASSIGNMENTS_ACC_PROCESSOR',FND_LOG.LEVEL_PROCEDURE);

    IF p_source_object_type_code = 'SR' THEN
      csm_sr_event_pkg.incidents_acc_i(p_incident_id=>p_incident_id,
                                       p_user_id=>p_user_id);

      IF p_flow_type IS NULL OR p_flow_type <> 'HISTORY' THEN
          csm_contract_event_pkg.sr_contract_acc_i(p_incident_id=>p_incident_id,
                                                   p_user_id=>p_user_id);
      END IF ;
    END IF;

   -- check if user already has access to the task. if already present then do not re-insert
   -- since a task can be assigned to a user only once..multiple assignments are not supported

    OPEN l_task_access_csr(p_task_id=>p_task_id, p_user_id=>p_user_id);
    FETCH l_task_access_csr INTO l_dummy;
    IF l_task_access_csr%NOTFOUND THEN
       -- get notes only if it not history
      IF p_flow_type IS NULL OR p_flow_type <> 'HISTORY' THEN
        csm_notes_event_pkg.notes_make_dirty_i_grp(p_sourceobjectcode=>'TASK',
                                              p_sourceobjectid=>p_task_id,
                                              p_userid=>p_user_id,
                                              p_error_msg=>l_error_msg,
                                              x_return_status=>l_return_status);
      END IF;

      csm_task_event_pkg.acc_insert(p_task_id=>p_task_id, p_user_id=>p_user_id);
    END IF;
    CLOSE l_task_access_csr;

    csm_task_assignment_event_pkg.acc_insert(p_task_assignment_id=>p_task_assignment_id,
                                             p_user_id=>p_user_id);

   CSM_UTIL_PKG.LOG('Leaving TASK_ASSIGNMENTS_ACC_PROCESSOR for task_assignment_id: ' || p_task_assignment_id,
                                   'CSM_TASK_ASSIGNMENT_EVENT_PKG.TASK_ASSIGNMENTS_ACC_PROCESSOR',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  TASK_ASSIGNMENTS_ACC_PROCESSOR for task_assignment_id:'
                       || to_char(p_task_assignment_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_TASK_ASSIGNMENT_EVENT_PKG.TASK_ASSIGNMENTS_ACC_PROCESSOR',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END TASK_ASSIGNMENTS_ACC_PROCESSOR;

PROCEDURE ACC_INSERT(p_task_assignment_id IN NUMBER, p_user_id IN NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

BEGIN
   CSM_UTIL_PKG.LOG('Entering ACC_INSERT for task_assignment_id: ' || p_task_assignment_id,
                                   'CSM_TASK_ASSIGNMENT_EVENT_PKG.ACC_INSERT',FND_LOG.LEVEL_PROCEDURE);

    CSM_ACC_PKG.Insert_Acc
    ( P_PUBLICATION_ITEM_NAMES => g_pubi_name
     ,P_ACC_TABLE_NAME         => g_acc_table_name
     ,P_SEQ_NAME               => g_acc_seq_name
     ,P_PK1_NAME               => g_pk1_name
     ,P_PK1_NUM_VALUE          => p_task_assignment_id
     ,P_USER_ID                => p_user_id
    );

   CSM_UTIL_PKG.LOG('Leaving ACC_INSERT for task_assignment_id: ' || p_task_assignment_id,
                                   'CSM_TASK_ASSIGNMENT_EVENT_PKG.ACC_INSERT',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  ACC_INSERT for task_assignment_id:'
                       || to_char(p_task_assignment_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_TASK_ASSIGNMENT_EVENT_PKG.ACC_INSERT',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END ACC_INSERT;

--Bug 4938130
PROCEDURE LOBS_MDIRTY_I(p_task_assignment_id IN NUMBER, p_resource_id IN NUMBER)
IS
BEGIN
 CSM_LOBS_EVENT_PKG.INSERT_ACC_RECORD(p_task_assignment_id, p_resource_id);
END LOBS_MDIRTY_I;

PROCEDURE TASK_ASSIGNMENT_INITIALIZER (p_task_assignment_id IN NUMBER,
                                       p_error_msg     OUT NOCOPY    VARCHAR2,
                                       x_return_status IN OUT NOCOPY VARCHAR2)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);
l_organization_id NUMBER;
l_is_synchronous_history VARCHAR2(1);

--Bug 5220635
CURSOR l_TaskAssgDetails_csr (p_taskassgid number) IS
SELECT	au.user_id,
 		jta.resource_id,
		jta.task_id,
		csi.incident_id,
		csi.customer_id,
		hz_ps.party_site_id,
		hz_ps.party_id,
		csi.inventory_item_id,
		csi.inv_organization_id,
        csi.contract_service_id,
        csi.customer_product_id,
        hz_ps.location_id,
        jt.source_object_type_code,
        csi.incident_location_type
FROM	JTF_TASK_ASSIGNMENTS jta,
        asg_user au,
        asg_user_pub_resps aupr,
 		jtf_tasks_b jt,
		cs_incidents_all_b csi,
		hz_party_sites hz_ps
WHERE	jta.task_assignment_id = p_taskassgid
AND     jta.assignee_role = 'ASSIGNEE'
AND     au.resource_id = jta.resource_id
AND     au.user_name = aupr.user_name
AND     aupr.pub_name = 'SERVICEP'
AND     jt.task_id = jta.task_id
AND     jt.source_object_type_code = 'SR'
AND     jt.source_object_id = csi.incident_id
AND  	hz_ps.party_site_id = NVL(csi.incident_location_id, jt.ADDRESS_ID)
AND     NVL(csi.incident_location_type,'HZ_PARTY_SITE')='HZ_PARTY_SITE'
UNION
SELECT	au.user_id,
 		jta.resource_id,
		jta.task_id,
		csi.incident_id,
		csi.customer_id,
		NULL,
		csi.customer_id,
		csi.inventory_item_id,
		csi.inv_organization_id,
        csi.contract_service_id,
        csi.customer_product_id,
        lc.location_id,
        jt.source_object_type_code,
        csi.incident_location_type
FROM	JTF_TASK_ASSIGNMENTS jta,
        asg_user au,
        asg_user_pub_resps aupr,
 		jtf_tasks_b jt,
		cs_incidents_all_b csi,
		hz_locations lc
WHERE	jta.task_assignment_id = p_taskassgid
AND     jta.assignee_role = 'ASSIGNEE'
AND     au.resource_id = jta.resource_id
AND     au.user_name = aupr.user_name
AND     aupr.pub_name = 'SERVICEP'
AND     jt.task_id = jta.task_id
AND     jt.source_object_type_code = 'SR'
AND     jt.source_object_id = csi.incident_id
AND  	lc.location_id = NVL(jt.LOCATION_ID,csi.incident_location_id)
AND     csi.incident_location_type='HZ_LOCATION'
UNION
SELECT	au.user_id,
 		jta.resource_id,
		jta.task_id,
		to_number(NULL),
		to_number(NULL),
		to_number(NULL),
		to_number(NULL),
		to_number(NULL),
		to_number(NULL),
        to_number(NULL),
        to_number(NULL),
        to_number(NULL),
        jt.source_object_type_code,
        to_char(NULL)
FROM	JTF_TASK_ASSIGNMENTS jta,
        asg_user au,
        asg_user_pub_resps aupr,
 		jtf_tasks_b jt
WHERE	jta.task_assignment_id = p_taskassgid
AND     jta.assignee_role = 'ASSIGNEE'
AND     au.resource_id = jta.resource_id
AND     au.user_name = aupr.user_name
AND     aupr.pub_name = 'SERVICEP'
AND     jt.task_id = jta.task_id
AND     (jt.source_object_type_code = 'TASK' OR jt.source_object_type_code IS NULL);

l_TaskAssgDetails_rec l_TaskAssgDetails_csr%ROWTYPE;
l_TaskAssgDetails_null_rec l_TaskAssgDetails_csr%ROWTYPE;

BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   CSM_UTIL_PKG.LOG('Entering CSM_TASK_ASSIGNMENT_EVENT_PKG.TASK_ASSIGNMENT_INITIALIZER for task_assignment_id: ' || p_task_assignment_id,
                         'CSM_TASK_ASSIGNMENT_EVENT_PKG.TASK_ASSIGNMENT_INITIALIZER',FND_LOG.LEVEL_PROCEDURE);

   l_TaskAssgDetails_rec := l_TaskAssgDetails_null_rec;

   OPEN l_TaskAssgDetails_csr(p_task_assignment_id);
   FETCH l_TaskAssgDetails_csr INTO l_taskassgdetails_rec;
   IF l_taskassgdetails_csr%NOTFOUND THEN
        CLOSE l_taskassgdetails_csr;
        CSM_UTIL_PKG.LOG('Not a mobile task_assignment_id: ' || p_task_assignment_id,
                         'CSM_TASK_ASSIGNMENT_EVENT_PKG.TASK_ASSIGNMENT_INITIALIZER',FND_LOG.LEVEL_PROCEDURE);
        RETURN;
   END IF;
   CLOSE l_taskassgdetails_csr;

   -- check if its a SR Task
   IF NOT csm_sr_event_pkg.is_sr_task(l_taskassgdetails_rec.task_id) THEN
     RETURN;
   END IF;

   -- check if task status is downloadable
   IF NOT csm_sr_event_pkg.is_task_status_downloadable(l_taskassgdetails_rec.task_id) THEN
     RETURN;
   END IF;

   -- check if task assignment status is downloadable
   IF NOT csm_sr_event_pkg.is_assgn_status_downloadable(p_task_assignment_id) THEN
     RETURN;
   END IF;

   -- get Service Inv Validation org
   l_organization_id := csm_profile_pkg.get_organization_id(l_taskassgdetails_rec.user_id);

   --get task notes moved to task_assignments_acc processor


   --get SR notes
   IF l_taskassgdetails_rec.incident_id IS NOT NULL THEN
     csm_notes_event_pkg.notes_make_dirty_i_grp(p_sourceobjectcode=>'SR',
                                              p_sourceobjectid=>l_taskassgdetails_rec.incident_id,
                                              p_userid=>l_taskassgdetails_rec.user_id,
                                              p_error_msg=>l_error_msg,
                                              x_return_status=>l_return_status);
   END IF;

   --get contract notes
   IF l_taskassgdetails_rec.contract_service_id IS NOT NULL THEN
     csm_notes_event_pkg.notes_make_dirty_i_grp(p_sourceobjectcode=>'OKS_COV_NOTE',
                                              p_sourceobjectid=>l_taskassgdetails_rec.contract_service_id,
                                              p_userid=>l_taskassgdetails_rec.user_id,
                                              p_error_msg=>l_error_msg,
                                              x_return_status=>l_return_status);
   END IF;

   -- get SR contacts
   IF l_taskassgdetails_rec.incident_id IS NOT NULL THEN
     csm_sr_event_pkg.spawn_sr_contacts_ins(p_incident_id=>l_taskassgdetails_rec.incident_id,
                                            p_user_id=>l_taskassgdetails_rec.user_id,
                                            p_flowtype=>NULL);
   END IF;

   IF l_taskassgdetails_rec.incident_location_type = 'HZ_LOCATION' THEN --R12 Assest
   		--insert location for the task
    	CSM_HZ_LOCATIONS_EVENT_PKG.insert_location(p_location_id => l_taskassgdetails_rec.location_id,
                                                   p_user_id => l_taskassgdetails_rec.user_id);
   ELSE
   -- spawn party site ins
    IF l_taskassgdetails_rec.party_site_id IS NOT NULL THEN
      csm_party_site_event_pkg.party_sites_acc_i(p_party_site_id => l_taskassgdetails_rec.party_site_id,
                                                p_user_id => l_taskassgdetails_rec.user_id,
                                                p_flowtype => NULL,
                                                p_error_msg => l_error_msg,
                                                x_return_status => l_return_status);
    END IF;
   END IF;

   -- spawn SR customer ins
   IF l_taskassgdetails_rec.customer_id IS NOT NULL THEN
     csm_party_event_pkg.party_acc_i(p_party_id => l_taskassgdetails_rec.customer_id,
                                     p_user_id => l_taskassgdetails_rec.user_id,
                                     p_flowtype => NULL,
                                     p_error_msg => l_error_msg,
                                     x_return_status => l_return_status);

    	 --insert Accounts for the above party-R12
     CSM_CUSTOMER_ACCOUNT_EVENT_PKG.CUST_ACCOUNTS_INS
                                    (p_party_id=> l_taskassgdetails_rec.customer_id
                                    ,p_user_id => l_taskassgdetails_rec.user_id);

   END IF;

   IF l_taskassgdetails_rec.customer_product_id IS NOT NULL THEN
      -- spawn SR item instance insert
      csm_sr_event_pkg.sr_item_ins_init(p_incident_id=>l_taskassgdetails_rec.incident_id,
                                        p_instance_id=>l_taskassgdetails_rec.customer_product_id,
                                        p_party_site_id=>l_taskassgdetails_rec.party_site_id,
                                        p_party_id=>l_taskassgdetails_rec.party_id,
                                        p_location_id=>l_taskassgdetails_rec.location_id,
                                        p_organization_id=>NVL(l_taskassgdetails_rec.inv_organization_id, l_organization_id),
                                        p_user_id=>l_taskassgdetails_rec.user_id,
                                        p_flow_type=>NULL);

   ELSIF l_taskassgdetails_rec.customer_product_id IS NULL OR l_taskassgdetails_rec.customer_product_id = 0 THEN
      IF l_taskassgdetails_rec.inventory_item_id IS NOT NULL THEN
           csm_mtl_system_items_event_pkg.mtl_system_items_acc_i
                       (p_inventory_item_id=>l_taskassgdetails_rec.inventory_item_id,
                        p_organization_id=>NVL(l_taskassgdetails_rec.inv_organization_id, l_organization_id),
                        p_user_id=>l_taskassgdetails_rec.user_id,
                        p_error_msg=>l_error_msg,
                        x_return_status=>l_return_status);
      END IF;
   END IF;

   -- spawn debrief line ins
   csm_task_assignment_event_pkg.spawn_debrief_line_ins(p_task_assignment_id=>p_task_assignment_id,
                                                        p_user_id=>l_taskassgdetails_rec.user_id,
                                                        p_flow_type=>NULL);

   -- spawn debrief header ins
   csm_task_assignment_event_pkg.spawn_debrief_header_ins(p_task_assignment_id=>p_task_assignment_id,
                                                        p_user_id=>l_taskassgdetails_rec.user_id,
                                                        p_flow_type=>NULL);

   -- spawn requirement lines ins
   csm_task_assignment_event_pkg.spawn_requirement_lines_ins(p_task_assignment_id=>p_task_assignment_id,
                                                             p_user_id=>l_taskassgdetails_rec.user_id,
                                                             p_flow_type=>NULL);

   -- spawn requirement headers ins
   csm_task_assignment_event_pkg.spawn_requirement_header_ins(p_task_assignment_id=>p_task_assignment_id,
                                                              p_user_id=>l_taskassgdetails_rec.user_id,
                                                              p_flow_type=>NULL);

   -- task_assignments_acc processor
   csm_task_assignment_event_pkg.task_assignments_acc_processor
                    (p_task_assignment_id=>p_task_assignment_id,
                     p_incident_id=>l_taskassgdetails_rec.incident_id,
                     p_task_id=>l_taskassgdetails_rec.task_id,
                     p_source_object_type_code=>l_taskassgdetails_rec.source_object_type_code,
                     p_flow_type=>NULL,
                     p_user_id=>l_taskassgdetails_rec.user_id);

   -- get synchronous history
   IF l_taskassgdetails_rec.incident_id IS NOT NULL THEN
     l_is_synchronous_history := fnd_profile.value('CSM_SYNCHRONOUS_HISTORY');

     IF l_is_synchronous_history = 'Y' THEN
        csm_service_history_event_pkg.calculate_history(l_incident_id=>l_taskassgdetails_rec.incident_id,
                                                        l_user_id=>l_taskassgdetails_rec.user_id);
     END IF;
   END IF;

   -- lobs mdirty I
   csm_task_assignment_event_pkg.lobs_mdirty_i(p_task_assignment_id=>p_task_assignment_id,
                                               p_resource_id=>l_taskassgdetails_rec.resource_id);

   CSM_UTIL_PKG.LOG('Leaving CSM_TASK_ASSIGNMENT_EVENT_PKG.TASK_ASSIGNMENT_INITIALIZER for task_assignment_id: ' || p_task_assignment_id,
                         'CSM_TASK_ASSIGNMENT_EVENT_PKG.TASK_ASSIGNMENT_INITIALIZER',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        x_return_status := FND_API.G_RET_STS_ERROR;
        p_error_msg := ' Exception in  TASK_ASSIGNMENT_INITIALIZER for task_assignment_id:' || to_char(p_task_assignment_id)
                           || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(p_error_msg, 'CSM_TASK_ASSIGNMENT_EVENT_PKG.TASK_ASSIGNMENT_INITIALIZER',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END TASK_ASSIGNMENT_INITIALIZER;

PROCEDURE TASK_ASSIGNMENT_HIST_INIT(p_task_assignment_id IN NUMBER,
                                    p_parent_incident_id IN NUMBER,
                                    p_user_id IN NUMBER,
                                    p_error_msg     OUT NOCOPY    VARCHAR2,
                                    x_return_status IN OUT NOCOPY VARCHAR2)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);
l_organization_id NUMBER;
l_flowtype VARCHAR2(20);

--Bug 5220635
CURSOR l_TaskAssgDetails_csr (p_taskassgid number) IS
SELECT jta.resource_id,
		jta.task_id,
		csi.incident_id,
		csi.customer_id,
		NVL(csi.incident_location_id, jt.ADDRESS_ID) AS incident_location_id,
		hz_ps.party_site_id,
		hz_ps.party_id,
		csi.inventory_item_id,
		csi.inv_organization_id,
        csi.contract_service_id,
        csi.customer_product_id,
        hz_ps.location_id,
        jt.source_object_type_code,
        csi.incident_location_type
FROM	JTF_TASK_ASSIGNMENTS jta,
 		jtf_tasks_b jt,
		cs_incidents_all_b csi,
		hz_party_sites hz_ps
WHERE	jta.task_assignment_id = p_taskassgid
AND     jt.task_id = jta.task_id
AND     jt.source_object_type_code = 'SR'
AND     jt.source_object_id = csi.incident_id
AND 	hz_ps.party_site_id = NVL(csi.incident_location_id, jt.ADDRESS_ID) -- csi.install_site_use_id
AND     NVL(csi.incident_location_type,'HZ_PARTY_SITE')='HZ_PARTY_SITE'
UNION
SELECT jta.resource_id,
		jta.task_id,
		csi.incident_id,
		csi.customer_id,
		NVL(csi.incident_location_id, jt.ADDRESS_ID) AS incident_location_id,
		NULL,
		csi.customer_id,
		csi.inventory_item_id,
		csi.inv_organization_id,
        csi.contract_service_id,
        csi.customer_product_id,
        lc.location_id,
        jt.source_object_type_code,
        csi.incident_location_type
FROM	JTF_TASK_ASSIGNMENTS jta,
 		jtf_tasks_b jt,
		cs_incidents_all_b csi,
		hz_locations lc
WHERE	jta.task_assignment_id = p_taskassgid
AND     jt.task_id = jta.task_id
AND     jt.source_object_type_code = 'SR'
AND     jt.source_object_id = csi.incident_id
AND 	lc.location_id = NVL(jt.LOCATION_ID,csi.incident_location_id) -- csi.install_site_use_id;
AND     csi.incident_location_type='HZ_LOCATION';

l_TaskAssgDetails_rec l_TaskAssgDetails_csr%ROWTYPE;
l_TaskAssgDetails_null_rec l_TaskAssgDetails_csr%ROWTYPE;

BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   CSM_UTIL_PKG.LOG('Entering TASK_ASSIGNMENT_HIST_INIT for task_assignment_id: ' || p_task_assignment_id
                    || ' and parent_incident_id: ' || p_parent_incident_id,
                         'CSM_TASK_ASSIGNMENT_EVENT_PKG.TASK_ASSIGNMENT_HIST_INIT',FND_LOG.LEVEL_PROCEDURE);

   l_TaskAssgDetails_rec := l_TaskAssgDetails_null_rec;
   l_flowtype := 'HISTORY';

   OPEN l_TaskAssgDetails_csr(p_task_assignment_id);
   FETCH l_TaskAssgDetails_csr INTO l_taskassgdetails_rec;
   IF l_taskassgdetails_csr%NOTFOUND THEN
        CLOSE l_taskassgdetails_csr;
        CSM_UTIL_PKG.LOG('No date found for history task_assignment_id: ' || p_task_assignment_id,
                         'CSM_TASK_ASSIGNMENT_EVENT_PKG.TASK_ASSIGNMENT_HIST_INIT',FND_LOG.LEVEL_EXCEPTION);
        RETURN;
   END IF;
   CLOSE l_taskassgdetails_csr;

   -- insert into service history acc
   csm_service_history_event_pkg.service_history_acc_i(p_parent_incident_id=>p_parent_incident_id,
                                                       p_incident_id=>l_taskassgdetails_rec.incident_id,
                                                       p_user_id=>p_user_id);

   -- get SR contacts
   csm_sr_event_pkg.spawn_sr_contacts_ins(p_incident_id=>l_taskassgdetails_rec.incident_id,
                                          p_user_id=>p_user_id,
                                          p_flowtype=>l_flowtype);
   IF l_taskassgdetails_rec.incident_location_type = 'HZ_LOCATION' THEN --R12 Assest
   		--insert location for the sr
    	CSM_HZ_LOCATIONS_EVENT_PKG.insert_location(p_location_id => l_taskassgdetails_rec.location_id,
                                                   p_user_id => p_user_id);
   ELSE
   -- spawn party site ins
    IF l_taskassgdetails_rec.party_site_id IS NOT NULL THEN
     csm_party_site_event_pkg.party_sites_acc_i(p_party_site_id => l_taskassgdetails_rec.party_site_id,
                                                p_user_id => p_user_id,
                                                p_flowtype => l_flowtype,
                                                p_error_msg => l_error_msg,
                                                x_return_status => l_return_status);
	END IF;
   END IF;

   -- spawn SR customer ins
   IF l_taskassgdetails_rec.customer_id IS NOT NULL THEN
     csm_party_event_pkg.party_acc_i(p_party_id => l_taskassgdetails_rec.customer_id,
                                     p_user_id => p_user_id,
                                     p_flowtype => l_flowtype,
                                     p_error_msg => l_error_msg,
                                     x_return_status => l_return_status);

    	 --insert Accounts for the above party-R12
     CSM_CUSTOMER_ACCOUNT_EVENT_PKG.CUST_ACCOUNTS_INS
                                    (p_party_id=> l_taskassgdetails_rec.customer_id
                                    ,p_user_id => p_user_id);

   END IF;

   -- get customer product
   IF l_taskassgdetails_rec.customer_product_id IS NOT NULL THEN
      csm_item_instance_event_pkg.item_instances_acc_processor(p_instance_id=>l_taskassgdetails_rec.customer_product_id,
                                                               p_user_id=>p_user_id,
                                                               p_flowtype=>l_flowtype,
                                                               p_error_msg=>l_error_msg,
                                                               x_return_status=>l_return_status);
   END IF;

   -- spawn debrief line ins
   csm_task_assignment_event_pkg.spawn_debrief_line_ins(p_task_assignment_id=>p_task_assignment_id,
                                                        p_user_id=>p_user_id,
                                                        p_flow_type=>l_flowtype);

   -- spawn debrief header ins
   csm_task_assignment_event_pkg.spawn_debrief_header_ins(p_task_assignment_id=>p_task_assignment_id,
                                                        p_user_id=>p_user_id,
                                                        p_flow_type=>l_flowtype);

   -- task_assignments_acc processor
   csm_task_assignment_event_pkg.task_assignments_acc_processor
                    (p_task_assignment_id=>p_task_assignment_id,
                     p_incident_id=>l_taskassgdetails_rec.incident_id,
                     p_task_id=>l_taskassgdetails_rec.task_id,
                     p_source_object_type_code=>l_taskassgdetails_rec.source_object_type_code,
                     p_flow_type=>l_flowtype,
                     p_user_id=>p_user_id);

   -- resource extns acc
   csm_resource_extns_event_pkg.resource_extns_acc_i(p_resource_id=>l_taskassgdetails_rec.resource_id,
                                                     p_user_id=>p_user_id);

   CSM_UTIL_PKG.LOG('Leaving TASK_ASSIGNMENT_HIST_INIT for task_assignment_id: ' || p_task_assignment_id
                    || ' and parent_incident_id: ' || p_parent_incident_id,
                         'CSM_TASK_ASSIGNMENT_EVENT_PKG.TASK_ASSIGNMENT_HIST_INIT',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        x_return_status := FND_API.G_RET_STS_ERROR;
        p_error_msg := ' Exception in  TASK_ASSIGNMENT_HIST_INIT for task_assignment_id:' || p_task_assignment_id
                    || ' and parent_incident_id: ' || p_parent_incident_id  || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(p_error_msg, 'CSM_TASK_ASSIGNMENT_EVENT_PKG.TASK_ASSIGNMENT_HIST_INIT',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END TASK_ASSIGNMENT_HIST_INIT;

PROCEDURE TASK_ASSIGNMENT_PURGE_INIT (p_task_assignment_id IN NUMBER,
                                      p_error_msg     OUT NOCOPY    VARCHAR2,
                                      x_return_status IN OUT NOCOPY VARCHAR2)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);
l_organization_id NUMBER;

CURSOR l_task_assg_purge_csr(p_task_assignment_id jtf_task_assignments.task_assignment_id%TYPE)
IS
--Bug 5220635
SELECT /*+ INDEX (acc CSM_TASK_ASSIGNMENTS_ACC_U1)*/ au.user_id,
       au.resource_id,
       jt.task_id,
       csi.incident_id,
       csi.customer_id,
       NVL(csi.incident_location_id, jt.ADDRESS_ID) AS incident_location_id,
       hz_ps.party_id,
       csi.inventory_item_id,
       csi.inv_organization_id,
       csi.contract_service_id,
       csi.customer_product_id,
       hz_ps.location_id,
       jt.source_object_type_code,
       csi.incident_location_type
FROM   csm_task_assignments_acc acc,
       jtf_task_assignments jta,
       asg_user au,
       asg_user_pub_resps aupr,
       jtf_tasks_b  jt,
       cs_incidents_all_b csi,
       hz_party_sites hz_ps
WHERE  acc.task_assignment_id = p_task_assignment_id
AND    acc.task_assignment_id = jta.task_assignment_id
AND    acc.user_id = au.user_id
AND    au.user_name = aupr.user_name
AND    aupr.pub_name = 'SERVICEP'
AND    jta.task_id = jt.task_id
AND    jt.source_object_type_code = 'SR'
AND    jt.source_object_id = csi.INCIDENT_ID
AND    hz_ps.party_site_id = NVL(csi.incident_location_id, jt.ADDRESS_ID)
AND    NVL(csi.incident_location_type,'HZ_PARTY_SITE')='HZ_PARTY_SITE'
UNION
SELECT /*+ INDEX (acc CSM_TASK_ASSIGNMENTS_ACC_U1)*/ au.user_id,
       au.resource_id,
       jt.task_id,
       csi.incident_id,
       csi.customer_id,
       NVL(csi.incident_location_id, jt.ADDRESS_ID) AS incident_location_id,
       csi.customer_id,
       csi.inventory_item_id,
       csi.inv_organization_id,
       csi.contract_service_id,
       csi.customer_product_id,
       lc.location_id,
       jt.source_object_type_code,
       csi.incident_location_type
FROM   csm_task_assignments_acc acc,
       jtf_task_assignments jta,
       asg_user au,
       asg_user_pub_resps aupr,
       jtf_tasks_b  jt,
       cs_incidents_all_b csi,
       hz_locations lc
WHERE  acc.task_assignment_id = p_task_assignment_id
AND    acc.task_assignment_id = jta.task_assignment_id
AND    acc.user_id = au.user_id
AND    au.user_name = aupr.user_name
AND    aupr.pub_name = 'SERVICEP'
AND    jta.task_id = jt.task_id
AND    jt.source_object_type_code = 'SR'
AND    jt.source_object_id = csi.INCIDENT_ID
AND    lc.location_id = NVL(jt.LOCATION_ID,csi.incident_location_id)
AND     csi.incident_location_type='HZ_LOCATION'
UNION
SELECT /*+ INDEX (acc CSM_TASK_ASSIGNMENTS_ACC_U1)*/ au.user_id,
       au.resource_id,
       jt.task_id,
	   TO_NUMBER(NULL),
	   TO_NUMBER(NULL),
	   TO_NUMBER(NULL),
	   TO_NUMBER(NULL),
	   TO_NUMBER(NULL),
	   TO_NUMBER(NULL),
       TO_NUMBER(NULL),
       TO_NUMBER(NULL),
       TO_NUMBER(NULL),
       jt.source_object_type_code,
       TO_CHAR(NULL)
FROM   csm_task_assignments_acc acc,
       JTF_TASK_ASSIGNMENTS jta,
       asg_user au,
       asg_user_pub_resps aupr,
 	   jtf_tasks_b jt
WHERE  acc.task_assignment_id = p_task_assignment_id
AND    acc.task_assignment_id = jta.task_assignment_id
AND    acc.user_id = au.user_id
AND    au.user_name = aupr.user_name
AND    aupr.pub_name = 'SERVICEP'
AND    jt.task_id = jta.task_id
AND    (jt.source_object_type_code = 'TASK' OR jt.source_object_type_code IS NULL);

l_task_assg_purge_rec l_task_assg_purge_csr%ROWTYPE;
l_task_assg_purge_null_rec l_task_assg_purge_csr%ROWTYPE;

BEGIN
   CSM_UTIL_PKG.LOG('Entering TASK_ASSIGNMENT_PURGE_INIT for task_assignment_id: ' || p_task_assignment_id,
                         'CSM_TASK_ASSIGNMENT_EVENT_PKG.TASK_ASSIGNMENT_PURGE_INIT',FND_LOG.LEVEL_PROCEDURE);
   l_task_assg_purge_rec := l_task_assg_purge_null_rec;

   OPEN l_task_assg_purge_csr(p_task_assignment_id);
   FETCH l_task_assg_purge_csr INTO l_task_assg_purge_rec;
   IF l_task_assg_purge_csr%NOTFOUND THEN
        CLOSE l_task_assg_purge_csr;
        CSM_UTIL_PKG.LOG('Not a mobile task_assignment_id: ' || p_task_assignment_id,
                         'CSM_TASK_ASSIGNMENT_EVENT_PKG.TASK_ASSIGNMENT_PURGE_INIT',FND_LOG.LEVEL_PROCEDURE);
        RETURN;
   END IF;
   CLOSE l_task_assg_purge_csr;
   -- get Service Inv Validation org
   l_organization_id := csm_profile_pkg.get_organization_id(l_task_assg_purge_rec.user_id);

   -- lobs mdirty D
   csm_task_assignment_event_pkg.lobs_mdirty_D(p_task_assignment_id=>p_task_assignment_id,
                                               p_resource_id=>l_task_assg_purge_rec.resource_id);

   -- delete task notes
   csm_notes_event_pkg.notes_make_dirty_d_grp(p_sourceobjectcode=>'TASK',
                                              p_sourceobjectid=>l_task_assg_purge_rec.task_id,
                                              p_userid=>l_task_assg_purge_rec.user_id,
                                              p_error_msg=>l_error_msg,
                                              x_return_status=>l_return_status);

   -- delete SR notes
   IF l_task_assg_purge_rec.incident_id IS NOT NULL THEN
     csm_notes_event_pkg.notes_make_dirty_d_grp(p_sourceobjectcode=>'SR',
                                              p_sourceobjectid=>l_task_assg_purge_rec.incident_id,
                                              p_userid=>l_task_assg_purge_rec.user_id,
                                              p_error_msg=>l_error_msg,
                                              x_return_status=>l_return_status);
   END IF;

   -- delete contract notes
   IF l_task_assg_purge_rec.contract_service_id IS NOT NULL THEN
     csm_notes_event_pkg.notes_make_dirty_d_grp(p_sourceobjectcode=>'OKS_COV_NOTE',
                                              p_sourceobjectid=>l_task_assg_purge_rec.contract_service_id,
                                              p_userid=>l_task_assg_purge_rec.user_id,
                                              p_error_msg=>l_error_msg,
                                              x_return_status=>l_return_status);
   END IF;

   -- delete SR contacts
   IF l_task_assg_purge_rec.incident_id IS NOT NULL THEN
     csm_sr_event_pkg.spawn_sr_contact_del(p_incident_id=>l_task_assg_purge_rec.incident_id,
                                            p_user_id=>l_task_assg_purge_rec.user_id,
                                            p_flowtype=>NULL);
   END IF;

  IF l_task_assg_purge_rec.incident_location_type = 'HZ_LOCATION' THEN --R12 Assest
   		--delete location for the sr
    	CSM_HZ_LOCATIONS_EVENT_PKG.delete_location(p_location_id => l_task_assg_purge_rec.location_id,
                                                   p_user_id => l_task_assg_purge_rec.user_id);
   ELSE
   -- spawn party site del
    --Bug 5220635
    IF l_task_assg_purge_rec.incident_location_id IS NOT NULL THEN
     csm_party_site_event_pkg.party_sites_acc_d(p_party_site_id => l_task_assg_purge_rec.incident_location_id,
                                                p_user_id => l_task_assg_purge_rec.user_id,
                                                p_flowtype => NULL,
                                                p_error_msg => l_error_msg,
                                                x_return_status => l_return_status);
    END IF;
   END IF;


   -- spawn SR customer del
   IF l_task_assg_purge_rec.customer_id IS NOT NULL THEN
     csm_party_event_pkg.party_acc_d(p_party_id => l_task_assg_purge_rec.customer_id,
                                     p_user_id => l_task_assg_purge_rec.user_id,
                                     p_flowtype => NULL,
                                     p_error_msg => l_error_msg,
                                     x_return_status => l_return_status);

	 --Delete Accounts for the above party-R12
     CSM_CUSTOMER_ACCOUNT_EVENT_PKG.CUST_ACCOUNTS_DEL
                                    (p_party_id=>l_task_assg_purge_rec.customer_id
                                    ,p_user_id =>l_task_assg_purge_rec.user_id);

   END IF;

   IF l_task_assg_purge_rec.customer_product_id IS NOT NULL THEN
      -- spawn SR item instance delete
      --Bug 5220635
      csm_sr_event_pkg.sr_item_del_init(p_incident_id=>l_task_assg_purge_rec.incident_id,
                                        p_instance_id=>l_task_assg_purge_rec.customer_product_id,
                                        p_party_site_id=>l_task_assg_purge_rec.incident_location_id,
                                        p_party_id=>l_task_assg_purge_rec.party_id,
                                        p_location_id=>l_task_assg_purge_rec.location_id,
                                        p_organization_id=>NVL(l_task_assg_purge_rec.inv_organization_id, l_organization_id),
                                        p_user_id=>l_task_assg_purge_rec.user_id,
                                        p_flow_type=>NULL);

   ELSIF l_task_assg_purge_rec.customer_product_id IS NULL OR l_task_assg_purge_rec.customer_product_id = 0 THEN
      IF l_task_assg_purge_rec.inventory_item_id IS NOT NULL THEN
           csm_mtl_system_items_event_pkg.mtl_system_items_acc_d
                       (p_inventory_item_id=>l_task_assg_purge_rec.inventory_item_id,
                        p_organization_id=>NVL(l_task_assg_purge_rec.inv_organization_id, l_organization_id),
                        p_user_id=>l_task_assg_purge_rec.user_id,
                        p_error_msg=>l_error_msg,
                        x_return_status=>l_return_status);
      END IF;
   END IF;

   -- spawn debrief line del
   csm_task_assignment_event_pkg.spawn_debrief_line_del(p_task_assignment_id=>p_task_assignment_id,
                                                        p_user_id=>l_task_assg_purge_rec.user_id,
                                                        p_flow_type=>NULL);

   -- spawn debrief header del
   csm_task_assignment_event_pkg.spawn_debrief_header_del(p_task_assignment_id=>p_task_assignment_id,
                                                          p_user_id=>l_task_assg_purge_rec.user_id,
                                                          p_flow_type=>NULL);

   -- spawn requirement line del
   csm_task_assignment_event_pkg.spawn_requirement_lines_del(p_task_assignment_id=>p_task_assignment_id,
                                                             p_user_id=>l_task_assg_purge_rec.user_id,
                                                             p_flow_type=>NULL);

   -- spawn requirement header del
   csm_task_assignment_event_pkg.spawn_requirement_header_del(p_task_assignment_id=>p_task_assignment_id,
                                                              p_user_id=>l_task_assg_purge_rec.user_id,
                                                              p_flow_type=>NULL);

   -- delete SR history
   IF l_task_assg_purge_rec.incident_id IS NOT NULL THEN
        csm_service_history_event_pkg.delete_history(p_task_assignment_id=>p_task_assignment_id,
                                                     p_incident_id=>l_task_assg_purge_rec.incident_id,
                                                     p_user_id=>l_task_assg_purge_rec.user_id);
   END IF;

   -- task_assignments_acc delete
   csm_task_assignment_event_pkg.task_assignments_acc_d
                    (p_task_assignment_id=>p_task_assignment_id,
                     p_incident_id=>l_task_assg_purge_rec.incident_id,
                     p_task_id=>l_task_assg_purge_rec.task_id,
                     p_source_object_type_code=>l_task_assg_purge_rec.source_object_type_code,
                     p_flow_type=>NULL,
                     p_user_id=>l_task_assg_purge_rec.user_id);

   CSM_UTIL_PKG.LOG('Leaving TASK_ASSIGNMENT_PURGE_INIT for task_assignment_id: ' || p_task_assignment_id,
                         'CSM_TASK_ASSIGNMENT_EVENT_PKG.TASK_ASSIGNMENT_PURGE_INIT',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  TASK_ASSIGNMENT_PURGE_INIT for task_assignment_id:' || to_char(p_task_assignment_id)
                           || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_TASK_ASSIGNMENT_EVENT_PKG.TASK_ASSIGNMENT_PURGE_INIT',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END TASK_ASSIGNMENT_PURGE_INIT;

--Bug 4938130
PROCEDURE LOBS_MDIRTY_D(p_task_assignment_id IN NUMBER, p_resource_id IN NUMBER)
IS
BEGIN
 CSM_LOBS_EVENT_PKG.DELETE_ACC_RECORD(p_task_assignment_id, p_resource_id);
END LOBS_MDIRTY_D;

PROCEDURE SPAWN_DEBRIEF_HEADER_DEL (p_task_assignment_id IN NUMBER,
                                    p_user_id IN NUMBER,
                                    p_flow_type IN VARCHAR2)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

-- cursor to get all debrief header id
CURSOR l_debrief_header_csr(p_task_assg_id jtf_task_assignments.task_assignment_id%TYPE,
                            p_user_id fnd_user.user_id%TYPE)
IS
SELECT hdr.debrief_header_id
FROM csm_debrief_headers_acc acc,
     csf_debrief_headers hdr
WHERE hdr.task_assignment_id = p_task_assg_id
AND acc.debrief_header_id = hdr.debrief_header_id
AND acc.user_id = p_user_id
;

BEGIN
   CSM_UTIL_PKG.LOG('Entering SPAWN_DEBRIEF_HEADER_DEL for task_assignment_id: ' || p_task_assignment_id,
                                   'CSM_TASK_ASSIGNMENT_EVENT_PKG.SPAWN_DEBRIEF_HEADER_DEL',FND_LOG.LEVEL_PROCEDURE);

    FOR r_debrief_header_rec IN l_debrief_header_csr(p_task_assignment_id, p_user_id) LOOP
       -- delete debrief headers
       csm_debrief_header_event_pkg.debrief_header_del_init(p_debrief_header_id=>r_debrief_header_rec.debrief_header_id,
                                                            p_user_id=>p_user_id,
                                                            p_flow_type=>p_flow_type);
    END LOOP;

   CSM_UTIL_PKG.LOG('Leaving SPAWN_DEBRIEF_HEADER_DEL for task_assignment_id: ' || p_task_assignment_id,
                                   'CSM_TASK_ASSIGNMENT_EVENT_PKG.SPAWN_DEBRIEF_HEADER_DEL',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  SPAWN_DEBRIEF_HEADER_DEL for task_assignment_id:'
                       || to_char(p_task_assignment_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_TASK_ASSIGNMENT_EVENT_PKG.SPAWN_DEBRIEF_HEADER_DEL',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END SPAWN_DEBRIEF_HEADER_DEL;

PROCEDURE SPAWN_DEBRIEF_LINE_DEL (p_task_assignment_id IN NUMBER,
                                  p_user_id IN NUMBER,
                                  p_flow_type IN VARCHAR2)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

-- cursor to get all debrief line id
CURSOR l_debrief_lines_csr(p_task_assg_id jtf_task_assignments.task_assignment_id%TYPE,
                           p_user_id fnd_user.user_id%TYPE)
IS
SELECT dl.debrief_line_id,
       dl.debrief_header_id
FROM csm_debrief_lines_acc acc,
     csF_debrief_headers hdr,
     csf_debrief_lines dl
WHERE hdr.task_assignment_id = p_task_assg_id
AND hdr.DEBRIEF_HEADER_ID = dl.DEBRIEF_HEADER_ID
AND acc.debrief_line_id = dl.debrief_line_id
AND acc.user_id = p_user_id
;

BEGIN
   CSM_UTIL_PKG.LOG('Entering SPAWN_DEBRIEF_LINE_DEL for task_assignment_id: ' || p_task_assignment_id,
                                   'CSM_TASK_ASSIGNMENT_EVENT_PKG.SPAWN_DEBRIEF_DEL',FND_LOG.LEVEL_PROCEDURE);

    FOR r_debrief_line_rec IN l_debrief_lines_csr(p_task_assignment_id, p_user_id) LOOP
       -- delete debrief lines
       csm_debrief_event_pkg.debrief_line_del_init(p_debrief_line_id=>r_debrief_line_rec.debrief_line_id,
                                                   p_user_id=>p_user_id,
                                                   p_flow_type=>p_flow_type);

    END LOOP;

   CSM_UTIL_PKG.LOG('Leaving SPAWN_DEBRIEF_LINE_DEL for task_assignment_id: ' || p_task_assignment_id,
                                   'CSM_TASK_ASSIGNMENT_EVENT_PKG.SPAWN_DEBRIEF_DEL',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  SPAWN_DEBRIEF_LINE_DEL for task_assignment_id:'
                       || to_char(p_task_assignment_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_TASK_ASSIGNMENT_EVENT_PKG.SPAWN_DEBRIEF_LINE_DEL',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END SPAWN_DEBRIEF_LINE_DEL;

PROCEDURE SPAWN_REQUIREMENT_HEADER_DEL(p_task_assignment_id IN NUMBER,
                                       p_user_id IN NUMBER,
                                       p_flow_type IN VARCHAR2)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

-- cursor to get all requirement headers for the task_id
CURSOR l_req_headers_csr(p_task_assg_id IN jtf_task_assignments.task_assignment_id%TYPE,
                         p_user_id IN NUMBER)
IS
SELECT hdr.requirement_header_id,
      jta.resource_id
FROM jtf_task_assignments jta,
     csp_requirement_headers hdr
WHERE jta.task_assignment_id = p_task_assg_id
AND hdr.task_id = jta.task_id
AND EXISTS
(SELECT 1
 FROM csm_req_headers_acc acc
 WHERE acc.requirement_header_id = hdr.requirement_header_id
 AND acc.user_id = p_user_id
 );

BEGIN
   CSM_UTIL_PKG.LOG('Entering SPAWN_REQUIREMENT_HEADER_DEL for task_assignment_id: ' || p_task_assignment_id,
                                   'CSM_TASK_ASSIGNMENT_EVENT_PKG.SPAWN_REQUIREMENT_HEADER_DEL',FND_LOG.LEVEL_PROCEDURE);

   IF p_flow_type IS NULL OR p_flow_type <> 'HISTORY' THEN
     FOR r_req_headers_rec IN l_req_headers_csr(p_task_assignment_id, p_user_id) LOOP
        -- delete requirement headers
        csm_csp_req_headers_event_pkg.csp_req_headers_mdirty_d(p_requirement_header_id=>r_req_headers_rec.requirement_header_id,
                                                               p_user_id=>p_user_id);
     END LOOP;
   END IF;

   CSM_UTIL_PKG.LOG('Leaving SPAWN_REQUIREMENT_HEADER_DEL for task_assignment_id: ' || p_task_assignment_id,
                                   'CSM_TASK_ASSIGNMENT_EVENT_PKG.SPAWN_REQUIREMENT_HEADER_DEL',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  SPAWN_REQUIREMENT_HEADER_DEL for task_assignment_id:'
                       || to_char(p_task_assignment_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_TASK_ASSIGNMENT_EVENT_PKG.SPAWN_REQUIREMENT_HEADER_DEL',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END SPAWN_REQUIREMENT_HEADER_DEL;

PROCEDURE SPAWN_REQUIREMENT_LINES_DEL(p_task_assignment_id IN NUMBER,
                                      p_user_id IN NUMBER,
                                      p_flow_type IN VARCHAR2)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

-- cursor to get all requirement lines for the task_id

CURSOR l_req_lines_csr(p_task_assg_id IN jtf_task_assignments.task_assignment_id%TYPE,
                       p_user_id IN NUMBER)
IS
SELECT line.requirement_line_id,
       line.requirement_header_id,
       acc.user_id
FROM jtf_task_assignments jta,
     csp_requirement_headers hdr,
     csp_requirement_lines line,
     csm_req_lines_acc acc
WHERE jta.task_assignment_id = p_task_assg_id
AND hdr.task_id = jta.task_id
AND line.requirement_header_id = hdr.requirement_header_id
AND acc.requirement_line_id = line.requirement_line_id;

BEGIN
   CSM_UTIL_PKG.LOG('Entering SPAWN_REQUIREMENT_LINES_DEL for task_assignment_id: ' || p_task_assignment_id,
                                   'CSM_TASK_ASSIGNMENT_EVENT_PKG.SPAWN_REQUIREMENT_LINES_DEL',FND_LOG.LEVEL_PROCEDURE);

   IF p_flow_type IS NULL OR p_flow_type <> 'HISTORY' THEN
     FOR r_req_lines_rec IN l_req_lines_csr(p_task_assignment_id, p_user_id) LOOP
        -- delete requirement lines
        csm_csp_req_lines_event_pkg.csp_req_lines_mdirty_d(p_requirement_line_id=>r_req_lines_rec.requirement_line_id,
                                                           p_user_id=>p_user_id);
     END LOOP;
   END IF;

   CSM_UTIL_PKG.LOG('Leaving SPAWN_REQUIREMENT_LINES_DEL for task_assignment_id: ' || p_task_assignment_id,
                                   'CSM_TASK_ASSIGNMENT_EVENT_PKG.SPAWN_REQUIREMENT_LINES_DEL',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  SPAWN_REQUIREMENT_LINES_DEL for task_assignment_id:'
                       || to_char(p_task_assignment_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_TASK_ASSIGNMENT_EVENT_PKG.SPAWN_REQUIREMENT_LINES_DEL',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END SPAWN_REQUIREMENT_LINES_DEL;

PROCEDURE TASK_ASSIGNMENTS_ACC_D(p_task_assignment_id IN NUMBER,
                                 p_incident_id IN NUMBER,
                                 p_task_id IN NUMBER,
                                 p_source_object_type_code IN VARCHAR2,
                                 p_flow_type IN VARCHAR2,
                                 p_user_id IN NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

BEGIN
   CSM_UTIL_PKG.LOG('Entering TASK_ASSIGNMENTS_ACC_D for task_assignment_id: ' || p_task_assignment_id,
                                   'CSM_TASK_ASSIGNMENT_EVENT_PKG.TASK_ASSIGNMENTS_ACC_D',FND_LOG.LEVEL_PROCEDURE);

    IF p_source_object_type_code = 'SR' THEN
      csm_sr_event_pkg.incidents_acc_d(p_incident_id=>p_incident_id,
                                       p_user_id=>p_user_id);

      IF p_flow_type IS NULL OR p_flow_type <> 'HISTORY' THEN
          csm_contract_event_pkg.sr_contract_acc_d(p_incident_id=>p_incident_id,
                                                   p_user_id=>p_user_id);
      END IF ;
    END IF;

   -- delete tasks
   csm_task_event_pkg.acc_delete(p_user_id=>p_user_id, p_task_id=>p_task_id);

   -- delete task assignments
   csm_task_assignment_event_pkg.acc_delete(p_task_assignment_id=>p_task_assignment_id,
                                            p_user_id=>p_user_id);

   CSM_UTIL_PKG.LOG('Leaving TASK_ASSIGNMENTS_ACC_D for task_assignment_id: ' || p_task_assignment_id,
                                   'CSM_TASK_ASSIGNMENT_EVENT_PKG.TASK_ASSIGNMENTS_ACC_D',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  TASK_ASSIGNMENTS_ACC_D for task_assignment_id:'
                       || to_char(p_task_assignment_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_TASK_ASSIGNMENT_EVENT_PKG.TASK_ASSIGNMENTS_ACC_D',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END TASK_ASSIGNMENTS_ACC_D;

PROCEDURE ACC_DELETE(p_task_assignment_id IN NUMBER, p_user_id IN NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

BEGIN
   CSM_UTIL_PKG.LOG('Entering ACC_DELETE for task_assignment_id: ' || p_task_assignment_id,
                                   'CSM_TASK_ASSIGNMENT_EVENT_PKG.ACC_DELETE',FND_LOG.LEVEL_PROCEDURE);

    CSM_ACC_PKG.Delete_Acc
    ( P_PUBLICATION_ITEM_NAMES => g_pubi_name
     ,P_ACC_TABLE_NAME         => g_acc_table_name
     ,P_PK1_NAME               => g_pk1_name
     ,P_PK1_NUM_VALUE          => p_task_assignment_id
     ,P_USER_ID                => p_user_id
    );

   CSM_UTIL_PKG.LOG('Leaving ACC_DELETE for task_assignment_id: ' || p_task_assignment_id,
                                   'CSM_TASK_ASSIGNMENT_EVENT_PKG.ACC_DELETE',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  ACC_DELETE for task_assignment_id:'
                       || to_char(p_task_assignment_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_TASK_ASSIGNMENT_EVENT_PKG.ACC_DELETE',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END ACC_DELETE;

PROCEDURE TASK_ASSIGNMENT_HIST_DEL_INIT(p_task_assignment_id IN NUMBER,
                                    p_parent_incident_id IN NUMBER,
                                    p_user_id IN NUMBER,
                                    p_error_msg  OUT NOCOPY VARCHAR2,
                                    x_return_status IN OUT NOCOPY VARCHAR2)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);
l_organization_id NUMBER;
l_flowtype VARCHAR2(20);

CURSOR l_TaskAssgHistPurge_csr (p_task_assignment_id jtf_task_assignments.task_assignment_id%TYPE)
IS
--Bug 5220635
SELECT jta.resource_id,
		jta.task_id,
		csi.incident_id,
		csi.customer_id,
		NVL(csi.incident_location_id, jt.ADDRESS_ID) AS incident_location_id,
		hz_ps.party_site_id,
		hz_ps.party_id,
		csi.inventory_item_id,
		csi.inv_organization_id,
        csi.contract_service_id,
        csi.customer_product_id,
        hz_ps.location_id,
        jt.source_object_type_code,
        csi.incident_location_type
FROM	JTF_TASK_ASSIGNMENTS jta,
 		jtf_tasks_b jt,
		cs_incidents_all_b csi,
		hz_party_sites hz_ps
WHERE	jta.task_assignment_id = p_task_assignment_id
AND     jt.task_id = jta.task_id
AND     jt.source_object_type_code = 'SR'
AND     jt.source_object_id = csi.incident_id
AND 	hz_ps.party_site_id = NVL(csi.incident_location_id, jt.ADDRESS_ID) -- csi.install_site_use_id
AND     NVL(csi.incident_location_type,'HZ_PARTY_SITE')='HZ_PARTY_SITE'
UNION
SELECT jta.resource_id,
		jta.task_id,
		csi.incident_id,
		csi.customer_id,
		NVL(csi.incident_location_id, jt.ADDRESS_ID) AS incident_location_id,
		NULL,
		csi.customer_id,
		csi.inventory_item_id,
		csi.inv_organization_id,
        csi.contract_service_id,
        csi.customer_product_id,
        lc.location_id,
        jt.source_object_type_code,
        csi.incident_location_type
FROM	JTF_TASK_ASSIGNMENTS jta,
 		jtf_tasks_b jt,
		cs_incidents_all_b csi,
		hz_locations lc
WHERE	jta.task_assignment_id = p_task_assignment_id
AND     jt.task_id = jta.task_id
AND     jt.source_object_type_code = 'SR'
AND     jt.source_object_id = csi.incident_id
AND 	lc.location_id = NVL(jt.LOCATION_ID,csi.incident_location_id ) -- csi.install_site_use_id;
AND     csi.incident_location_type='HZ_LOCATION'
;

l_TaskAssgHistPurge_rec l_TaskAssgHistPurge_csr%ROWTYPE;
l_TaskAssgHistPurge_null_rec l_TaskAssgHistPurge_csr%ROWTYPE;

BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   CSM_UTIL_PKG.LOG('Entering TASK_ASSIGNMENT_HIST_DEL_INIT for task_assignment_id: ' || p_task_assignment_id
                    || ' and parent_incident_id: ' || p_parent_incident_id,
                         'CSM_TASK_ASSIGNMENT_EVENT_PKG.TASK_ASSIGNMENT_HIST_DEL_INIT',FND_LOG.LEVEL_PROCEDURE);

   l_TaskAssgHistPurge_rec := l_TaskAssgHistPurge_null_rec;
   l_flowtype := 'HISTORY';

   OPEN l_TaskAssgHistPurge_csr(p_task_assignment_id);
   FETCH l_TaskAssgHistPurge_csr INTO l_TaskAssgHistPurge_rec;
   IF l_TaskAssgHistPurge_csr%NOTFOUND THEN
        CLOSE l_TaskAssgHistPurge_csr;
        CSM_UTIL_PKG.LOG('No date found for history task_assignment_id: ' || p_task_assignment_id,
                         'CSM_TASK_ASSIGNMENT_EVENT_PKG.TASK_ASSIGNMENT_HIST_INIT',FND_LOG.LEVEL_EXCEPTION);
        RETURN;
   END IF;
   CLOSE l_TaskAssgHistPurge_csr;

   -- delete from service history acc
   csm_service_history_event_pkg.service_history_acc_d(p_parent_incident_id=>p_parent_incident_id,
                                                       p_incident_id=>l_TaskAssgHistPurge_rec.incident_id,
                                                       p_user_id=>p_user_id);

   -- delete SR contacts
   csm_sr_event_pkg.spawn_sr_contact_del(p_incident_id=>l_TaskAssgHistPurge_rec.incident_id,
                                          p_user_id=>p_user_id,
                                          p_flowtype=>l_flowtype);
   IF l_TaskAssgHistPurge_rec.incident_location_type = 'HZ_LOCATION' THEN --R12 Assest
   		--insert location for the sr
    	csm_hz_locations_event_pkg.delete_location(p_location_id => l_TaskAssgHistPurge_rec.location_id,
                                                   p_user_id => p_user_id);
   ELSE

    -- spawn party site del
        --Bug 5220635
    	csm_party_site_event_pkg.party_sites_acc_d(p_party_site_id => l_TaskAssgHistPurge_rec.incident_location_id,
                                              p_user_id => p_user_id,
                                              p_flowtype => l_flowtype,
                                              p_error_msg => l_error_msg,
                                              x_return_status => l_return_status);
   END IF;
   -- spawn SR customer del
   csm_party_event_pkg.party_acc_d(p_party_id => l_TaskAssgHistPurge_rec.customer_id,
                                   p_user_id => p_user_id,
                                   p_flowtype => l_flowtype,
                                   p_error_msg => l_error_msg,
                                   x_return_status => l_return_status);

	 --Delete Accounts for the above party-R12
     CSM_CUSTOMER_ACCOUNT_EVENT_PKG.CUST_ACCOUNTS_DEL
                                    (p_party_id=> l_TaskAssgHistPurge_rec.customer_id
                                    ,p_user_id => p_user_id);

   -- delete customer product
   IF l_TaskAssgHistPurge_rec.customer_product_id IS NOT NULL THEN
      csm_item_instance_event_pkg.item_instances_acc_d(p_instance_id=>l_TaskAssgHistPurge_rec.customer_product_id,
                                                       p_user_id=>p_user_id,
                                                       p_error_msg=>l_error_msg,
                                                       x_return_status=>l_return_status);
   END IF;

   -- spawn debrief line del
   csm_task_assignment_event_pkg.spawn_debrief_line_del(p_task_assignment_id=>p_task_assignment_id,
                                                        p_user_id=>p_user_id,
                                                        p_flow_type=>l_flowtype);

   -- spawn debrief header del
   csm_task_assignment_event_pkg.spawn_debrief_header_del(p_task_assignment_id=>p_task_assignment_id,
                                                          p_user_id=>p_user_id,
                                                          p_flow_type=>l_flowtype);

   -- resource extns acc del
   csm_resource_extns_event_pkg.resource_extns_acc_d(p_resource_id=>l_TaskAssgHistPurge_rec.resource_id,
                                                     p_user_id=>p_user_id);

   -- task_assignments_acc delete
   csm_task_assignment_event_pkg.task_assignments_acc_d
                    (p_task_assignment_id=>p_task_assignment_id,
                     p_incident_id=>l_TaskAssgHistPurge_rec.incident_id,
                     p_task_id=>l_TaskAssgHistPurge_rec.task_id,
                     p_source_object_type_code=>l_TaskAssgHistPurge_rec.source_object_type_code,
                     p_flow_type=>l_flowtype,
                     p_user_id=>p_user_id);

   CSM_UTIL_PKG.LOG('Leaving TASK_ASSIGNMENT_HIST_DEL_INIT for task_assignment_id: ' || p_task_assignment_id
                    || ' and parent_incident_id: ' || p_parent_incident_id,
                         'CSM_TASK_ASSIGNMENT_EVENT_PKG.TASK_ASSIGNMENT_HIST_DEL_INIT',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        x_return_status := FND_API.G_RET_STS_ERROR;
        p_error_msg := ' Exception in  TASK_ASSIGNMENT_HIST_DEL_INIT for task_assignment_id:' || p_task_assignment_id
                    || ' and parent_incident_id: ' || p_parent_incident_id  || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(p_error_msg, 'CSM_TASK_ASSIGNMENT_EVENT_PKG.TASK_ASSIGNMENT_HIST_DEL_INIT',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END TASK_ASSIGNMENT_HIST_DEL_INIT;

END CSM_TASK_ASSIGNMENT_EVENT_PKG;

/
