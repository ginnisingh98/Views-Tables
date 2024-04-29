--------------------------------------------------------
--  DDL for Package Body CSM_SR_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_SR_EVENT_PKG" AS
/* $Header: csmesrb.pls 120.12.12010000.3 2009/09/25 04:06:39 trajasek ship $ */

-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
-- Melvin P   05/02/02 Base creation
   -- Enter procedure, function bodies as shown below
/*** Globals ***/
g_incidents_acc_table_name        CONSTANT VARCHAR2(30) := 'CSM_INCIDENTS_ALL_ACC';
g_incidents_table_name            CONSTANT VARCHAR2(30) := 'CS_INCIDENTS_ALL';
g_incidents_seq_name              CONSTANT VARCHAR2(30) := 'CSM_INCIDENTS_ALL_ACC_S' ;
g_incidents_pk1_name              CONSTANT VARCHAR2(30) := 'INCIDENT_ID';
g_incidents_pubi_name CONSTANT CSM_ACC_PKG.t_publication_item_list :=
  CSM_ACC_PKG.t_publication_item_list('CSM_INCIDENTS_ALL');

g_table_name1            CONSTANT VARCHAR2(30) := 'CSM_CSI_ITEM_ATTR';
g_acc_table_name1        CONSTANT VARCHAR2(30) := 'CSM_CSI_ITEM_ATTR_ACC';
g_acc_sequence_name1     CONSTANT VARCHAR2(30) := 'CSM_CSI_ITEM_ATTR_ACC_S';
g_publication_item_name1 CONSTANT CSM_ACC_PKG.t_publication_item_list :=
                             CSM_ACC_PKG.t_publication_item_list('CSM_CSI_ITEM_ATTR');
g_pk1_name1              CONSTANT VARCHAR2(30) := 'ATTRIBUTE_VALUE_ID';
g_pub_item               CONSTANT VARCHAR2(30) := 'CSM_CSI_ITEM_ATTR';

incident_not_found exception;

/**
** Conc program called every midnight to purge task assignments depending on the
** history profile of the user
**/
--12.1XB6
PROCEDURE PURGE_INCIDENTS_CONC (p_status OUT NOCOPY VARCHAR2, p_message OUT NOCOPY VARCHAR2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);
l_incident_id cs_incidents_all_b.incident_id%TYPE;
l_dummy number;
l_last_run_date date;


CURSOR l_purge_incidents_csr
IS
SELECT acc.incident_id,
       acc.user_id,
       acc.counter
FROM csm_incidents_all_acc acc,
     cs_incidents_all_b inc,
     cs_incident_statuses_b   ists
WHERE inc.incident_id = acc.incident_id
  AND  decode(CSM_UTIL_PKG.get_group_owner(inc.owner_group_id),
       -1,
       CSM_UTIL_PKG.get_owner(inc.created_by),
       CSM_UTIL_PKG.get_group_owner(inc.owner_group_id)) = acc.user_id
  AND (inc.creation_date  < (SYSDATE - csm_profile_pkg.get_task_history_days(acc.user_id)))
  AND inc.INCIDENT_STATUS_ID = ists.INCIDENT_STATUS_ID
  AND ists.CLOSE_FLAG = 'Y';


CURSOR l_upd_last_run_date_csr
IS
SELECT 1
FROM jtm_con_request_data
WHERE product_code = 'CSM'
AND package_name = 'CSM_SR_EVENT_PKG'
AND procedure_name = 'PURGE_INCIDENTS_CONC'
FOR UPDATE OF last_run_date NOWAIT;

TYPE l_incident_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
l_incident_tbl l_incident_tbl_type;
TYPE l_userid_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
l_userid_tbl l_userid_tbl_type;
TYPE l_cnt_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
l_cnt_tbl l_cnt_tbl_type;


BEGIN
  l_last_run_date := SYSDATE;

  OPEN l_purge_incidents_csr;
  LOOP
    IF l_incident_tbl.COUNT > 0 THEN
       l_incident_tbl.DELETE;
    END IF;
    IF l_userid_tbl.COUNT > 0 THEN
       l_userid_tbl.DELETE;
    END IF;

    FETCH l_purge_incidents_csr BULK COLLECT INTO l_incident_tbl,l_userid_tbl,l_cnt_tbl LIMIT 50;
    EXIT WHEN l_incident_tbl.COUNT = 0;

    CSM_UTIL_PKG.LOG(TO_CHAR(l_incident_tbl.COUNT) || ' records sent for purge', 'CSM_SR_EVENT_PKG.PURGE_INCIDENTS_CONC',FND_LOG.LEVEL_EVENT);

    FOR I IN 1..l_incident_tbl.count
    LOOP
         l_incident_id:=l_incident_tbl(I);
         FOR j IN 1..l_cnt_tbl.COUNT
		 LOOP
          csm_sr_event_pkg.sr_del_init(p_incident_id=>l_incident_id);
         END LOOP;
    END LOOP;
    -- commit after every 50 records
    COMMIT;
  END LOOP;

  CLOSE l_purge_incidents_csr;

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
   p_message :=  'CSM_SR_EVENT_PKG.PURGE_INCIDENTS_CONC Executed successfully';

EXCEPTION
  --log the error
  WHEN OTHERS THEN
    l_sqlerrno := to_char(SQLCODE);
    l_sqlerrmsg := substr(SQLERRM, 1,2000);
    ROLLBACK;
    l_error_msg := ' Exception in  Purge_incidents_conc for incident_id:'
                      || to_char(l_incident_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
    p_status := 'ERROR';
    p_message := 'Error in CSM_SR_EVENT_PKG.PURGE_INCIDENTS_CONC: ' || l_error_msg;
    CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_SR_EVENT_PKG.PURGE_INCIDENTS_CONC',FND_LOG.LEVEL_EVENT);
--    x_return_status := FND_API.G_RET_STS_ERROR ;
--    RAISE;
END PURGE_INCIDENTS_CONC;

FUNCTION IS_SR_TASK ( p_task_id IN NUMBER)
RETURN BOOLEAN
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_source_object_type_code jtf_tasks_b.source_object_type_code%TYPE;

CURSOR l_jtf_tasks_csr(p_task_id jtf_tasks_b.task_id%TYPE)
IS
SELECT tsk.source_object_type_code
FROM  jtf_tasks_b tsk, jtf_task_types_b ttype
WHERE tsk.task_id = p_task_id
AND tsk.task_type_id = ttype.task_type_id
AND (ttype.RULE = 'DISPATCH' OR ttype.private_flag = 'Y')
AND tsk.SCHEDULED_START_DATE IS NOT NULL
AND tsk.SCHEDULED_END_DATE IS NOT NULL
;

BEGIN
   CSM_UTIL_PKG.LOG('Entering CSM_SR_EVENT_PKG.IS_SR_TASK for task_id: ' || p_task_id,
                         'CSM_SR_EVENT_PKG.IS_SR_TASK',FND_LOG.LEVEL_PROCEDURE);

   l_source_object_type_code := NULL;

   OPEN l_jtf_tasks_csr(p_task_id);
   FETCH l_jtf_tasks_csr INTO l_source_object_type_code;
   IF l_jtf_tasks_csr%NOTFOUND THEN
       CLOSE l_jtf_tasks_csr;
       CSM_UTIL_PKG.LOG('Not a mobile Task Type for task_id: ' || p_task_id,
                         'CSM_SR_EVENT_PKG.IS_SR_TASK',FND_LOG.LEVEL_EXCEPTION);
       RETURN FALSE;
   END IF;
   CLOSE l_jtf_tasks_csr;

   IF (l_source_object_type_code IN ('SR', 'TASK') OR l_source_object_type_code IS NULL) THEN
       CSM_UTIL_PKG.LOG('Leaving CSM_SR_EVENT_PKG.IS_SR_TASK for task_id: ' || p_task_id,
                         'CSM_SR_EVENT_PKG.IS_SR_TASK', FND_LOG.LEVEL_PROCEDURE);
		RETURN TRUE;
   ELSE
       CSM_UTIL_PKG.LOG('Not a mobile Task Type for task_id: ' || p_task_id,
                         'CSM_SR_EVENT_PKG.IS_SR_TASK',FND_LOG.LEVEL_EXCEPTION);
    	RETURN FALSE;
   END IF;

EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  IS_SR_TASK for task_id:' || to_char(p_task_id)
                           || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_SR_EVENT_PKG.IS_SR_TASK',FND_LOG.LEVEL_EXCEPTION);
        RETURN FALSE;
END IS_SR_TASK;

FUNCTION IS_TASK_STATUS_DOWNLOADABLE(p_task_id IN NUMBER)
RETURN BOOLEAN
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_dummy NUMBER;

CURSOR l_jtf_task_status_csr(p_task_id jtf_tasks_b.task_id%TYPE)
IS
SELECT 1
FROM jtf_tasks_b jt,
	 jtf_task_statuses_b jts
WHERE jt.task_id = p_task_id
AND	  jt.task_status_id = jts.task_status_id
AND (jt.source_object_type_code = 'TASK' OR jt.source_object_type_code IS NULL
OR	  (jts.assigned_flag = 'Y'
		OR jts.closed_flag = 'Y'
		OR jts.completed_flag = 'Y'
      ));

BEGIN
   CSM_UTIL_PKG.LOG('Entering CSM_SR_EVENT_PKG.IS_TASK_STATUS_DOWNLOADABLE for task_id: ' || p_task_id,
                         'CSM_SR_EVENT_PKG.IS_TASK_STATUS_DOWNLOADABLE',FND_LOG.LEVEL_PROCEDURE);

   OPEN l_jtf_task_status_csr(p_task_id);
   FETCH l_jtf_task_status_csr INTO l_dummy;
   IF l_jtf_task_status_csr%NOTFOUND THEN
       CLOSE l_jtf_task_status_csr;
       CSM_UTIL_PKG.LOG('Task Status not downloadable for task_id: ' || p_task_id,
                         'CSM_SR_EVENT_PKG.IS_TASK_STATUS_DOWNLOADABLE',FND_LOG.LEVEL_EXCEPTION);
       RETURN FALSE;
   END IF;
   CLOSE l_jtf_task_status_csr;

   CSM_UTIL_PKG.LOG('Leaving CSM_SR_EVENT_PKG.IS_TASK_STATUS_DOWNLOADABLE for task_id: ' || p_task_id,
                         'CSM_SR_EVENT_PKG.IS_TASK_STATUS_DOWNLOADABLE',FND_LOG.LEVEL_PROCEDURE);

   RETURN TRUE;
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  IS_TASK_STATUS_DOWNLOADABLE for task_id:' || to_char(p_task_id)
                           || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_SR_EVENT_PKG.IS_TASK_STATUS_DOWNLOADABLE',FND_LOG.LEVEL_EXCEPTION);
        RETURN FALSE;
END IS_TASK_STATUS_DOWNLOADABLE;

FUNCTION IS_ASSGN_STATUS_DOWNLOADABLE(p_task_assignment_id IN NUMBER)
RETURN BOOLEAN
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_dummy NUMBER;

CURSOR l_jtf_task_assg_status_csr(p_task_assg_id NUMBER)
IS
SELECT 1
FROM jtf_task_assignments jta,
     jtf_tasks_b jt,
	 jtf_task_statuses_b jts
WHERE jta.task_assignment_id = p_task_assg_id
AND jt.task_id = jta.task_id
AND	  jta.assignment_status_id = jts.task_status_id
AND (jt.source_object_type_code = 'TASK' OR jt.source_object_type_code IS NULL
OR	  (jts.assigned_flag = 'Y'
		OR jts.closed_flag = 'Y'
		OR jts.completed_flag = 'Y'
      ));

BEGIN
   CSM_UTIL_PKG.LOG('Entering CSM_SR_EVENT_PKG.IS_ASSGN_STATUS_DOWNLOADABLE for task_assignment_id: ' || p_task_assignment_id,
                         'CSM_SR_EVENT_PKG.IS_ASSGN_STATUS_DOWNLOADABLE',FND_LOG.LEVEL_PROCEDURE);

   OPEN l_jtf_task_assg_status_csr(p_task_assignment_id);
   FETCH l_jtf_task_assg_status_csr INTO l_dummy;
   IF l_jtf_task_assg_status_csr%NOTFOUND THEN
       CLOSE l_jtf_task_assg_status_csr;
       CSM_UTIL_PKG.LOG('Task Assignment Status not downloadable for task_assignment_id: ' || p_task_assignment_id,
                         'CSM_SR_EVENT_PKG.IS_ASSGN_STATUS_DOWNLOADABLE',FND_LOG.LEVEL_EXCEPTION);
       RETURN FALSE;
   END IF;
   CLOSE l_jtf_task_assg_status_csr;

   CSM_UTIL_PKG.LOG('Leaving CSM_SR_EVENT_PKG.IS_ASSGN_STATUS_DOWNLOADABLE for task_assignment_id: ' || p_task_assignment_id,
                         'CSM_SR_EVENT_PKG.IS_ASSGN_STATUS_DOWNLOADABLE',FND_LOG.LEVEL_PROCEDURE);

   RETURN TRUE;
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  IS_ASSGN_STATUS_DOWNLOADABLE for task_assignment_id:' || to_char(p_task_assignment_id)
                           || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_SR_EVENT_PKG.IS_ASSGN_STATUS_DOWNLOADABLE',FND_LOG.LEVEL_EXCEPTION);
        RETURN FALSE;
END IS_ASSGN_STATUS_DOWNLOADABLE;

PROCEDURE SPAWN_SR_CONTACTS_INS(p_incident_id IN NUMBER, p_sr_contact_point_id IN NUMBER,
                                p_user_id IN NUMBER, p_flowtype IN VARCHAR2)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);
l_resource_id jtf_rs_resource_extns.resource_id%TYPE;
l_party_id hz_parties.party_id%TYPE;

CURSOR l_srcontpts_csr (p_incident_id cs_incidents_all_b.incident_id%TYPE,
                        p_sr_contact_point_id NUMBER)
IS
SELECT sr_contact_point_id,
	   contact_point_id,
	   contact_type,
	   party_id
FROM   cs_hz_sr_contact_points
WHERE incident_id = p_incident_id
AND sr_contact_point_id = NVL(p_sr_contact_point_id, sr_contact_point_id);

CURSOR l_emp_resource_csr (p_party_id hz_parties.party_id%TYPE)
IS
SELECT jtrs.resource_id
FROM jtf_rs_resource_extns jtrs
WHERE jtrs.source_id = p_party_id
AND jtrs.CATEGORY = 'EMPLOYEE'
AND SYSDATE BETWEEN jtrs.start_date_active AND nvl(jtrs.end_date_active, SYSDATE)
;

BEGIN
   CSM_UTIL_PKG.LOG('Entering CSM_SR_EVENT_PKG.SPAWN_SR_CONTACTS_INS for incident_id: ' || p_incident_id,
                         'CSM_SR_EVENT_PKG.SPAWN_SR_CONTACTS_INS',FND_LOG.LEVEL_PROCEDURE);

   FOR r_srcontpts_rec IN l_srcontpts_csr(p_incident_id, p_sr_contact_point_id) LOOP
     IF r_srcontpts_rec.contact_type = 'EMPLOYEE' THEN
            OPEN l_emp_resource_csr(r_srcontpts_rec.party_id);
			FETCH l_emp_resource_csr INTO l_resource_id;
			CLOSE l_emp_resource_csr;

			-- insert resource into acc table
			IF l_resource_id IS NOT NULL THEN
			  csm_resource_extns_event_pkg.resource_extns_acc_i(p_resource_id=>l_resource_id,
			                                                    p_user_id=>p_user_id);
			END IF;
     END IF;  --Bug 6880063
	  -- insert party record
            csm_party_event_pkg.party_acc_i(p_party_id=> r_srcontpts_rec.party_id,
                                            p_user_id=> p_user_id,
                                            p_flowtype=> p_flowtype,
                                            p_error_msg=> l_error_msg,
                                            x_return_status=> l_return_status);

     -- insert sr_contact_point into acc table
     csm_sr_contact_event_pkg.sr_cntact_mdirty_i(p_sr_contact_point_id=>r_srcontpts_rec.sr_contact_point_id,
                                                 p_user_id=>p_user_id);
   END LOOP;

   CSM_UTIL_PKG.LOG('Leaving CSM_SR_EVENT_PKG.SPAWN_SR_CONTACTS_INS for task_assignment_id: ' || p_incident_id,
                         'CSM_SR_EVENT_PKG.SPAWN_SR_CONTACTS_INS',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  SPAWN_SR_CONTACTS_INS for incident_id:' || to_char(p_incident_id)
                           || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_SR_EVENT_PKG.SPAWN_SR_CONTACTS_INS',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END SPAWN_SR_CONTACTS_INS;

PROCEDURE SR_ITEM_INS_INIT(p_incident_id IN NUMBER, p_instance_id IN NUMBER, p_party_site_id IN NUMBER,
                           p_party_id IN NUMBER, p_location_id IN NUMBER, p_organization_id IN NUMBER,
                           p_user_id IN NUMBER, p_flow_type IN VARCHAR2)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

BEGIN
   CSM_UTIL_PKG.LOG('Entering SR_ITEM_INS_INIT for incident_id: ' || p_incident_id ||
                    ' and instance_id: ' || p_instance_id,'CSM_SR_EVENT_PKG.SR_ITEM_INS_INIT',FND_LOG.LEVEL_PROCEDURE);

   -- initialize count of IB items at location to 0;
   csm_sr_event_pkg.g_ib_count := 0;

   -- item instances fork
   csm_sr_event_pkg.spawn_item_instances_ins(p_instance_id=>p_instance_id,p_organization_id=>p_organization_id,
                                              p_user_id=>p_user_id);

   -- get IB at location
   csm_item_instance_event_pkg.get_ib_at_location(p_instance_id=>p_instance_id,p_party_site_id=>p_party_site_id,
                                                  p_party_id=>p_party_id,p_location_id=>p_location_id,
                                                  p_user_id=>p_user_id, p_flow_type=>p_flow_type);

   -- spawn counters INS
   csm_item_instance_event_pkg.spawn_counters_ins(p_instance_id=>p_instance_id, p_user_id=>p_user_id);

   -- get IB notes
   csm_notes_event_pkg.notes_make_dirty_i_grp(p_sourceobjectcode=>'CP',
                                              p_sourceobjectid=>p_instance_id,
                                              p_userid=>p_user_id,
                                              p_error_msg=>l_error_msg,
                                              x_return_status=>l_return_status);

   CSM_UTIL_PKG.LOG('Leaving SR_ITEM_INS_INIT for incident_id: ' || p_incident_id ||
                    ' and instance_id: ' || p_instance_id,'CSM_SR_EVENT_PKG.SR_ITEM_INS_INIT',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  SR_ITEM_INS_INIT for incident_id: ' || p_incident_id || ' and instance_id:'
                       || to_char(p_instance_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_SR_EVENT_PKG.SR_ITEM_INS_INIT',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END SR_ITEM_INS_INIT;

PROCEDURE SPAWN_ITEM_INSTANCES_INS (p_instance_id IN NUMBER, p_organization_id IN NUMBER, p_user_id IN NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);
l_transaction_date DATE;
l_null_relationship_id csi_ii_relationships.relationship_id%TYPE;
l_organization_id NUMBER;

-- get all the child intances of the parent and the parent instance
-- also check these instances do not exist for the user
CURSOR l_instance_children_csr (p_instance_id csi_item_instances.instance_id%TYPE,
	   						   	p_transaction_date DATE, p_user_id fnd_user.user_id%TYPE)
IS
SELECT cir.relationship_id AS relationship_id ,
       cir.subject_id AS instance_id ,
       cii.inventory_item_id
FROM (SELECT * FROM CSI_II_RELATIONSHIPS CIRo
          START WITH CIRo.OBJECT_ID = p_instance_id
          AND CIRo.RELATIONSHIP_TYPE_CODE = 'COMPONENT-OF'
          AND p_transaction_date BETWEEN NVL(CIRo.active_start_date, p_transaction_date)
                                      AND NVL(CIRo.active_end_date, p_transaction_date)
          CONNECT BY CIRo.OBJECT_ID = PRIOR CIRo.SUBJECT_ID
     ) CIR,
     CSI_ITEM_INSTANCES CII
WHERE  CII.INSTANCE_ID = CIR.SUBJECT_ID
AND p_transaction_date BETWEEN NVL ( CII.ACTIVE_START_DATE , p_transaction_date )
                           AND NVL ( CII.ACTIVE_END_DATE , p_transaction_date)
UNION
-- select the current instance
SELECT l_null_relationship_id AS relationship_id,
   	   cii.instance_id AS instance_id,
   	   cii.inventory_item_id
FROM csi_item_instances cii
WHERE cii.instance_id = p_instance_id
AND    p_transaction_date BETWEEN NVL(cii.active_start_date, p_transaction_date)
					           	 AND NVL(cii.active_end_date, p_transaction_date)
UNION
SELECT cir.relationship_id AS relationship_id,
       cir.object_id AS instance_id,
       cii.inventory_item_id
FROM   CSI_II_RELATIONSHIPS cir,
       csi_item_instances cii
WHERE  cir.RELATIONSHIP_TYPE_CODE = 'COMPONENT-OF'
AND    cir.SUBJECT_ID = p_instance_id
AND    cii.instance_id = cir.object_id
AND    p_transaction_date BETWEEN NVL(cir.active_start_date, p_transaction_date)
					           	 AND NVL(cir.active_end_date, p_transaction_date)
AND    p_transaction_date BETWEEN NVL(cii.active_start_date, p_transaction_date)
					           	 AND NVL(cii.active_end_date, p_transaction_date)
;

-- get additional IB attributes if existing
CURSOR l_csi_iea_values_ins_csr(p_instance_id IN NUMBER)
IS
SELECT attrval.attribute_value_id
FROM csi_iea_values attrval,
     csi_i_extended_attribs attr
WHERE attrval.instance_id = p_instance_id
AND attrval.attribute_id = attr.attribute_id
AND SYSDATE BETWEEN NVL(attrval.active_start_date, SYSDATE) AND NVL(attrval.active_end_date, SYSDATE)
AND SYSDATE BETWEEN NVL(attr.active_start_date, SYSDATE) AND NVL(attr.active_end_date, SYSDATE)
;

BEGIN
   CSM_UTIL_PKG.LOG('Entering SPAWN_ITEM_INSTANCES_INS for instance_id: ' || p_instance_id,
                                   'CSM_SR_EVENT_PKG.SPAWN_ITEM_INSTANCES_INS',FND_LOG.LEVEL_PROCEDURE);

   l_transaction_date := SYSDATE;
   l_null_relationship_id := TO_NUMBER(NULL);

  	FOR l_instance_children_rec IN l_instance_children_csr(p_instance_id, l_transaction_date, p_user_id) LOOP

       IF l_instance_children_rec.relationship_id IS NOT NULL THEN
         csm_item_instance_event_pkg.ii_relationships_acc_i(l_instance_children_rec.relationship_id, p_user_id, l_error_msg, l_return_status);
       END IF;

       --insert item instance
       csm_item_instance_event_pkg.item_instances_acc_processor(l_instance_children_rec.instance_id,
                                                                 p_user_id,
                                                                 NULL, -- p_flowtype
                                                                 l_error_msg,
                                                                 l_return_status);

       -- insert mtl_system_items bug 3949282
       csm_mtl_system_items_event_pkg.MTL_SYSTEM_ITEMS_ACC_I(l_instance_children_rec.inventory_item_id,
                                                             p_organization_id,
                                                             p_user_id,
                                                             l_error_msg,
                                                             l_return_status);

     END LOOP;

       -- process inserts of additional attributes
     FOR r_csi_iea_values_ins_rec IN l_csi_iea_values_ins_csr(p_instance_id) LOOP
         CSM_ACC_PKG.Insert_Acc
          ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name1
           ,P_ACC_TABLE_NAME         => g_acc_table_name1
           ,P_SEQ_NAME               => g_acc_sequence_name1
           ,P_PK1_NAME               => g_pk1_name1
           ,P_PK1_NUM_VALUE          => r_csi_iea_values_ins_rec.attribute_value_id
           ,P_USER_ID                => p_user_id
          );
     END LOOP;

   CSM_UTIL_PKG.LOG('Leaving SPAWN_ITEM_INSTANCES_INS for instance_id: ' || p_instance_id,
                                   'CSM_SR_EVENT_PKG.SPAWN_ITEM_INSTANCES_INS',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := l_error_msg || '- Exception in  SPAWN_ITEM_INSTANCES_INS for instance_id:'
                       || to_char(p_instance_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_SR_EVENT_PKG.SPAWN_ITEM_INSTANCES_INS',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END SPAWN_ITEM_INSTANCES_INS;

PROCEDURE INCIDENTS_ACC_I(p_incident_id IN NUMBER, p_user_id IN NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

BEGIN
   CSM_UTIL_PKG.LOG('Entering INCIDENTS_ACC_I for incident_id: ' || p_incident_id,
                                   'CSM_SR_EVENT_PKG.INCIDENTS_ACC_I',FND_LOG.LEVEL_PROCEDURE);

   CSM_ACC_PKG.Insert_Acc
    ( P_PUBLICATION_ITEM_NAMES => g_incidents_pubi_name
     ,P_ACC_TABLE_NAME         => g_incidents_acc_table_name
     ,P_SEQ_NAME               => g_incidents_seq_name
     ,P_PK1_NAME               => g_incidents_pk1_name
     ,P_PK1_NUM_VALUE          => p_incident_id
     ,P_USER_ID                => p_user_id
    );

   CSM_UTIL_PKG.LOG('Leaving INCIDENTS_ACC_I for incident_id: ' || p_incident_id,
                                   'CSM_SR_EVENT_PKG.INCIDENTS_ACC_I',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  INCIDENTS_ACC_I for incident_id:'
                       || to_char(p_incident_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_SR_EVENT_PKG.INCIDENTS_ACC_I',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END INCIDENTS_ACC_I;

PROCEDURE SPAWN_SR_CONTACT_DEL(p_incident_id IN NUMBER, p_sr_contact_point_id IN NUMBER,
                               p_user_id IN NUMBER, p_flowtype IN VARCHAR2)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);
l_resource_id jtf_rs_resource_extns.resource_id%TYPE;
l_party_id hz_parties.party_id%TYPE;

CURSOR l_srcontpts_csr (p_incident_id cs_incidents_all_b.incident_id%TYPE,
                        p_sr_contact_point_id NUMBER)
IS
SELECT sr_contact_point_id,
	   contact_point_id,
	   contact_type,
	   party_id
FROM   cs_hz_sr_contact_points
WHERE incident_id = p_incident_id
AND sr_contact_point_id = NVL(p_sr_contact_point_id, sr_contact_point_id);

CURSOR l_emp_resource_csr (p_party_id hz_parties.party_id%TYPE)
IS
SELECT jtrs.resource_id
FROM jtf_rs_resource_extns jtrs
WHERE jtrs.source_id = p_party_id
AND jtrs.CATEGORY = 'EMPLOYEE'
AND SYSDATE BETWEEN jtrs.start_date_active AND nvl(jtrs.end_date_active, SYSDATE)
;

BEGIN
   CSM_UTIL_PKG.LOG('Entering CSM_SR_EVENT_PKG.SPAWN_SR_CONTACT_DEL for incident_id: ' || p_incident_id,
                         'CSM_SR_EVENT_PKG.SPAWN_SR_CONTACT_DEL',FND_LOG.LEVEL_PROCEDURE);

   FOR r_srcontpts_rec IN l_srcontpts_csr(p_incident_id, p_sr_contact_point_id) LOOP
     IF r_srcontpts_rec.contact_type = 'EMPLOYEE' THEN
            OPEN l_emp_resource_csr(r_srcontpts_rec.party_id);
			FETCH l_emp_resource_csr INTO l_resource_id;
			CLOSE l_emp_resource_csr;

			-- delete resource from acc table
			IF l_resource_id IS NOT NULL THEN
			  csm_resource_extns_event_pkg.resource_extns_acc_d(p_resource_id=>l_resource_id,
			                                                    p_user_id=>p_user_id);
			END IF;
     END IF; --Bug 6880063
	 -- delete party record
            csm_party_event_pkg.party_acc_d(p_party_id=> r_srcontpts_rec.party_id,
                                            p_user_id=> p_user_id,
                                            p_flowtype=> p_flowtype,
                                            p_error_msg=> l_error_msg,
                                            x_return_status=> l_return_status);


     -- delete sr_contact_point from acc table
     csm_sr_contact_event_pkg.sr_cntact_mdirty_d(p_sr_contact_point_id=>r_srcontpts_rec.sr_contact_point_id,
                                                 p_user_id=>p_user_id);
   END LOOP;

   CSM_UTIL_PKG.LOG('Leaving CSM_SR_EVENT_PKG.SPAWN_SR_CONTACT_DEL for incident_id: ' || p_incident_id,
                         'CSM_SR_EVENT_PKG.SPAWN_SR_CONTACT_DEL',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  SPAWN_SR_CONTACT_DEL for incident_id:' || to_char(p_incident_id)
                           || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_SR_EVENT_PKG.SPAWN_SR_CONTACT_DEL',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END SPAWN_SR_CONTACT_DEL;

PROCEDURE SR_ITEM_DEL_INIT(p_incident_id IN NUMBER, p_instance_id IN NUMBER, p_party_site_id IN NUMBER,
                           p_party_id IN NUMBER, p_location_id IN NUMBER, p_organization_id IN NUMBER,
                           p_user_id IN NUMBER, p_flow_type IN VARCHAR2)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

BEGIN
   CSM_UTIL_PKG.LOG('Entering SR_ITEM_DEL_INIT for incident_id: ' || p_incident_id ||
                    ' and instance_id: ' || p_instance_id,'CSM_SR_EVENT_PKG.SR_ITEM_DEL_INIT',FND_LOG.LEVEL_PROCEDURE);

   -- spawn item instances del
   csm_sr_event_pkg.spawn_item_instances_del(p_instance_id=>p_instance_id,p_organization_id=>p_organization_id,
                                              p_user_id=>p_user_id);

   -- delete IB at location (logic not correct)
--   csm_item_instance_event_pkg.delete_ib_at_location(p_incident_id => p_incident_id, p_instance_id=>p_instance_id,p_party_site_id=>p_party_site_id,
--                                                  p_party_id=>p_party_id,p_location_id=>p_location_id,
--                                                  p_user_id=>p_user_id, p_flow_type=>p_flow_type);

   -- spawn counters DEL
   csm_item_instance_event_pkg.spawn_counters_del(p_instance_id=>p_instance_id, p_user_id=>p_user_id);

   -- delete IB notes
   csm_notes_event_pkg.notes_make_dirty_d_grp(p_sourceobjectcode=>'CP',
                                              p_sourceobjectid=>p_instance_id,
                                              p_userid=>p_user_id,
                                              p_error_msg=>l_error_msg,
                                              x_return_status=>l_return_status);

   CSM_UTIL_PKG.LOG('Leaving SR_ITEM_DEL_INIT for incident_id: ' || p_incident_id ||
                    ' and instance_id: ' || p_instance_id,'CSM_SR_EVENT_PKG.SR_ITEM_DEL_INIT',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  SR_ITEM_DEL_INIT for incident_id: ' || p_incident_id || ' and instance_id:'
                       || to_char(p_instance_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_SR_EVENT_PKG.SR_ITEM_DEL_INIT',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END SR_ITEM_DEL_INIT;

PROCEDURE SPAWN_ITEM_INSTANCES_DEL (p_instance_id IN NUMBER, p_organization_id IN NUMBER,
                                    p_user_id IN NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);
l_transaction_date DATE;
l_null_relationship_id csi_ii_relationships.relationship_id%TYPE;
l_organization_id NUMBER;

-- get all the child instances of the parent instance as well as the parent
CURSOR l_parent_child_instance_csr (p_instance_id csi_item_instances.instance_id%type,
   			                     					    p_transaction_date date)
IS
SELECT cir.relationship_id AS relationship_id ,
       cir.subject_id AS instance_id ,
       cii.inventory_item_id
FROM (SELECT * FROM CSI_II_RELATIONSHIPS CIRo
          START WITH CIRo.OBJECT_ID = p_instance_id
          AND CIRo.RELATIONSHIP_TYPE_CODE = 'COMPONENT-OF'
          AND p_transaction_date BETWEEN NVL(CIRo.active_start_date, p_transaction_date)
                                      AND NVL(CIRo.active_end_date, p_transaction_date)
          CONNECT BY CIRo.OBJECT_ID = PRIOR CIRo.SUBJECT_ID
     ) CIR,
     CSI_ITEM_INSTANCES CII
WHERE  CII.INSTANCE_ID = CIR.SUBJECT_ID
AND p_transaction_date BETWEEN NVL ( CII.ACTIVE_START_DATE , p_transaction_date )
                           AND NVL ( CII.ACTIVE_END_DATE , p_transaction_date)
UNION
SELECT l_null_relationship_id AS relationship_id,
       p_instance_id AS instance_id,
       cii.inventory_item_id
FROM  csi_item_instances cii
WHERE cii.instance_id = p_instance_id
AND    p_transaction_date BETWEEN NVL(cii.active_start_date, p_transaction_date)
					           	 AND NVL(cii.active_end_date, p_transaction_date)
-- get the parent instance
UNION
SELECT cir.relationship_id as relationship_id,
       cir.object_id AS instance_id,
       cii.inventory_item_id
FROM   CSI_II_RELATIONSHIPS cir,
       csi_item_instances cii
WHERE  cir.RELATIONSHIP_TYPE_CODE = 'COMPONENT-OF'
AND    cir.SUBJECT_ID = p_instance_id
AND    cii.instance_id = cir.object_id
AND    p_transaction_date BETWEEN NVL(cir.active_start_date, p_transaction_date)
					           	 AND NVL(cir.active_end_date, p_transaction_date)
AND    p_transaction_date BETWEEN NVL(cii.active_start_date, p_transaction_date)
					           	 AND NVL(cii.active_end_date, p_transaction_date)
;

-- get additional IB attributes if existing to delete
CURSOR l_csi_iea_values_del_csr(p_instance_id IN NUMBER)
IS
SELECT attrval.attribute_value_id
FROM csi_iea_values attrval,
     csi_i_extended_attribs attr
WHERE attrval.instance_id = p_instance_id
AND attrval.attribute_id = attr.attribute_id
AND SYSDATE BETWEEN NVL(attrval.active_start_date, SYSDATE) AND NVL(attrval.active_end_date, SYSDATE)
AND SYSDATE BETWEEN NVL(attr.active_start_date, SYSDATE) AND NVL(attr.active_end_date, SYSDATE)
;

BEGIN
   CSM_UTIL_PKG.LOG('Entering SPAWN_ITEM_INSTANCES_DEL for instance_id: ' || p_instance_id,
                                   'CSM_SR_EVENT_PKG.SPAWN_ITEM_INSTANCES_DEL',FND_LOG.LEVEL_PROCEDURE);

   l_transaction_date := SYSDATE;
   l_null_relationship_id := TO_NUMBER(NULL);

    	-- get parent and all child instances
   	FOR l_parent_child_instance_rec IN l_parent_child_instance_csr(p_instance_id, l_transaction_date) LOOP

       IF l_parent_child_instance_rec.relationship_id IS NOT NULL THEN
           csm_item_instance_event_pkg.ii_relationships_acc_d(l_parent_child_instance_rec.relationship_id, p_user_id, l_error_msg, l_return_status);
       END IF;

       --delete item instance
       csm_item_instance_event_pkg.ITEM_INSTANCES_ACC_D(p_instance_id=>l_parent_child_instance_rec.instance_id,
                                                        p_user_id=>p_user_id,
                                                        p_error_msg=>l_error_msg,
                                                        x_return_status=>l_return_status);

       -- delete mtl_system_items bug 3949282
       csm_mtl_system_items_event_pkg.MTL_SYSTEM_ITEMS_ACC_D(l_parent_child_instance_rec.inventory_item_id,
                                                             p_organization_id,
                                                             p_user_id,
                                                             l_error_msg,
                                                             l_return_status);
   	END LOOP;

    -- process deletes of additional attributes
    FOR r_csi_iea_values_del_rec IN l_csi_iea_values_del_csr(p_instance_id) LOOP
      CSM_ACC_PKG.Delete_acc
        ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name1
         ,P_ACC_TABLE_NAME         => g_acc_table_name1
         ,P_PK1_NAME               => g_pk1_name1
         ,P_PK1_NUM_VALUE          => r_csi_iea_values_del_rec.attribute_value_id
         ,P_USER_ID                => p_user_id
        );
    END LOOP;

   CSM_UTIL_PKG.LOG('Leaving SPAWN_ITEM_INSTANCES_DEL for instance_id: ' || p_instance_id,
                                   'CSM_SR_EVENT_PKG.SPAWN_ITEM_INSTANCES_DEL',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := l_error_msg || '- Exception in  SPAWN_ITEM_INSTANCES_DEL for instance_id:'
                       || to_char(p_instance_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_SR_EVENT_PKG.SPAWN_ITEM_INSTANCES_DEL',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END SPAWN_ITEM_INSTANCES_DEL;

PROCEDURE INCIDENTS_ACC_D(p_incident_id IN NUMBER, p_user_id IN NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

BEGIN
   CSM_UTIL_PKG.LOG('Entering INCIDENTS_ACC_D for incident_id: ' || p_incident_id,
                                   'CSM_SR_EVENT_PKG.INCIDENTS_ACC_D',FND_LOG.LEVEL_PROCEDURE);

   CSM_ACC_PKG.Delete_Acc
    ( P_PUBLICATION_ITEM_NAMES => g_incidents_pubi_name
     ,P_ACC_TABLE_NAME         => g_incidents_acc_table_name
     ,P_PK1_NAME               => g_incidents_pk1_name
     ,P_PK1_NUM_VALUE          => p_incident_id
     ,P_USER_ID                => p_user_id
    );

   CSM_UTIL_PKG.LOG('Leaving INCIDENTS_ACC_D for incident_id: ' || p_incident_id,
                                   'CSM_SR_EVENT_PKG.INCIDENTS_ACC_D',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  INCIDENTS_ACC_D for incident_id:'
                       || to_char(p_incident_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_SR_EVENT_PKG.INCIDENTS_ACC_D',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END INCIDENTS_ACC_D;

--12.1XB6
FUNCTION IS_SR_DOWNLOADED_TO_OWNER(p_task_id NUMBER) RETURN BOOLEAN
IS
CURSOR c_sr_owner_group (b_task_id NUMBER) IS
 SELECT inc.owner_group_id,
        inc.created_by
 FROM CS_INCIDENTS_ALL_B inc,
      JTF_TASKS_B tsk,
      JTF_TASK_TYPES_B ttype
 WHERE tsk.TASK_ID=b_task_id
 AND   tsk.SOURCE_OBJECT_TYPE_CODE='SR'
 AND   tsk.SOURCE_OBJECT_ID=inc.INCIDENT_ID
 AND   ttype.TASK_TYPE_ID = tsk.TASK_TYPE_ID
 AND   ttype.RULE='DISPATCH';

l_owner_group_id number;
l_created_by number ;
BEGIN
OPEN c_sr_owner_group(p_task_id);
FETCH c_sr_owner_group INTO l_owner_group_id,l_created_by;
CLOSE c_sr_owner_group;

RETURN CSM_UTIL_PKG.is_mfs_group(l_owner_group_id) OR CSM_UTIL_PKG.is_palm_user(l_created_by);

END;

--12.1
PROCEDURE SR_INS_INIT(p_incident_id IN NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);
l_organization_id NUMBER;
l_owner_id NUMBER;
l_owner_resource_id NUMBER;

--Change for Asset
CURSOR l_sr_csr (p_incident_id cs_incidents_all_b.incident_id%TYPE)
IS
SELECT csi.incident_id,
       csi.customer_id,
       csi.install_site_id,
       csi.customer_product_id,
       csi.inventory_item_id,
       csi.inv_organization_id,
       csi.contract_service_id,
       csi.created_by,
       csi.incident_location_id,
       csi.customer_id party_id,
       decode(nvl(csi.incident_location_type,'HZ_PARTY_SITE'),
	   'HZ_PARTY_SITE',
       (select location_id from hz_party_sites where party_site_id = NVL(csi.incident_location_id, csi.install_site_id)),
       'HZ_LOCATION',
       (select location_id from hz_locations where location_id = NVL(csi.incident_location_id, csi.install_site_id))
	   ) location_id ,
       nvl(csi.incident_location_type,'HZ_PARTY_SITE') incident_location_type,
       csi.owner_group_id
FROM   cs_incidents_all_b csi
WHERE  csi.incident_id = p_incident_id
AND  nvl(csi.incident_location_type,'HZ_PARTY_SITE') IN ('HZ_PARTY_SITE','HZ_LOCATION');
--not required as counter is important
/*AND NOT EXISTS
(SELECT 1
 FROM csm_incidents_all_acc acc
 WHERE acc.incident_id = csi.incident_id
 AND acc.user_id = CSM_UTIL_PKG.get_group_owner(csi.owner_group_id));*/


CURSOR l_addr_id_csr (p_incident_id IN NUMBER)
IS
SELECT NVL(LOCATION_ID,ADDRESS_ID)--R12Assest
FROM JTF_TASKS_B
WHERE SOURCE_OBJECT_TYPE_CODE = 'SR'
AND SOURCE_OBJECT_ID = p_incident_id;

l_sr_rec l_sr_csr%ROWTYPE;

CURSOR c_tasks(b_incident_id NUMBER)
IS
SELECT TASK_ID
FROM JTF_TASKS_B tsk,
     JTF_TASK_TYPES_B ttype
WHERE tsk.SOURCE_OBJECT_TYPE_CODE='SR'
AND   tsk.SOURCE_OBJECT_ID=b_incident_id
AND   ttype.TASK_TYPE_ID = tsk.TASK_TYPE_ID
AND   ttype.RULE='DISPATCH';

CURSOR c_task_assignments(b_task_id NUMBER)
IS
SELECT TASK_ASSIGNMENT_ID,resource_id
FROM JTF_TASK_ASSIGNMENTS
WHERE TASK_ID=b_task_id;

CURSOR c_resource_id(b_user_id NUMBER) IS
SELECT RESOURCE_ID
FROM JTF_RS_RESOURCE_EXTNS
WHERE USER_ID=b_user_id;

--assignee bug
CURSOR c_user_id(b_resource_id NUMBER) IS
SELECT USER_ID
FROM JTF_RS_RESOURCE_EXTNS
WHERE RESOURCE_ID=b_resource_id;

l_assignee_user_id NUMBER;

BEGIN
   CSM_UTIL_PKG.LOG('Entering SR_INS_INIT for incident_id: ' || p_incident_id ,'CSM_SR_EVENT_PKG.SR_INS_INIT',FND_LOG.LEVEL_PROCEDURE);

   OPEN l_sr_csr(p_incident_id);
   FETCH l_sr_csr INTO l_sr_rec;
   IF l_sr_csr%NOTFOUND THEN
     CLOSE l_sr_csr;
     RETURN;
   END IF;
   CLOSE l_sr_csr;
--12.1XB6
   IF ( NOT CSM_UTIL_PKG.is_mfs_group(l_sr_rec.owner_group_id)) THEN
          IF ( NOT CSM_UTIL_PKG.is_palm_user(l_sr_rec.created_by)) THEN
              CSM_UTIL_PKG.LOG('Leaving SR_INS_INIT because the Owner group of SR is not a mobile resource group
			                    and also this SR , incident_id: ' || p_incident_id ||' is not created by a mobile user'
			   ,'CSM_SR_EVENT_PKG.SR_INS_INIT',FND_LOG.LEVEL_PROCEDURE);
              RETURN;
          ELSE
              l_owner_id := CSM_UTIL_PKG.get_owner(l_sr_rec.created_by);
          END IF;
   ELSE
     l_owner_id := CSM_UTIL_PKG.get_group_owner(l_sr_rec.owner_group_id);
   END IF;



  -- not necessary as all DISPATCH Sr's need an install site id
   IF l_sr_rec.INCIDENT_LOCATION_ID IS NULL THEN
       OPEN l_addr_id_csr(p_incident_id);
       FETCH l_addr_id_csr INTO l_sr_rec.INCIDENT_LOCATION_ID;
       CLOSE l_addr_id_csr;
   END IF;


   -- get Service Inv Validation org
   l_organization_id := csm_profile_pkg.get_organization_id(l_owner_id);

   --get SR notes
   csm_notes_event_pkg.notes_make_dirty_i_grp(p_sourceobjectcode=>'SR',
                                              p_sourceobjectid=>p_incident_id,
                                              p_userid=>l_owner_id,
                                              p_error_msg=>l_error_msg,
                                              x_return_status=>l_return_status);

   -- get SR contacts
   csm_sr_event_pkg.spawn_sr_contacts_ins(p_incident_id=>p_incident_id,
                                          p_user_id=>l_owner_id,
                                          p_flowtype=>NULL);
   IF l_sr_rec.incident_location_type = 'HZ_LOCATION' THEN --R12 Assest
   		--insert location for the sr
    	CSM_HZ_LOCATIONS_EVENT_PKG.insert_location(p_location_id => l_sr_rec.incident_location_id,
                                              p_user_id => l_owner_id);
   ELSE
	   -- get party site
	   IF l_sr_rec.incident_location_id IS NOT NULL THEN
    	csm_party_site_event_pkg.party_sites_acc_i(p_party_site_id => l_sr_rec.incident_location_id,
                                              p_user_id => l_owner_id,
                                              p_flowtype => NULL,
                                              p_error_msg => l_error_msg,
                                              x_return_status => l_return_status);
	   END IF;
	END IF;
   -- spawn SR customer ins
   IF l_sr_rec.customer_id IS NOT NULL THEN
     csm_party_event_pkg.party_acc_i(p_party_id => l_sr_rec.customer_id,
                                     p_user_id => l_owner_id,
                                     p_flowtype => NULL,
                                     p_error_msg => l_error_msg,
                                     x_return_status => l_return_status);
	 --insert Accounts for the above party-R12
     CSM_CUSTOMER_ACCOUNT_EVENT_PKG.CUST_ACCOUNTS_INS
                                    (p_party_id=>l_sr_rec.customer_id
                                    ,p_user_id =>l_owner_id);

   END IF;

   IF l_sr_rec.customer_product_id IS NOT NULL THEN
      -- spawn SR item instance insert
      csm_sr_event_pkg.sr_item_ins_init(p_incident_id=>l_sr_rec.incident_id,
                                        p_instance_id=>l_sr_rec.customer_product_id,
                                        p_party_site_id=>l_sr_rec.incident_location_id,
                                        p_party_id=>l_sr_rec.party_id,
                                        p_location_id=>l_sr_rec.location_id,
                                        p_organization_id=>NVL(l_sr_rec.inv_organization_id, l_organization_id),
                                        p_user_id=>l_owner_id,
                                        p_flow_type=>NULL);

   ELSIF l_sr_rec.customer_product_id IS NULL OR l_sr_rec.customer_product_id = 0 THEN
      IF l_sr_rec.inventory_item_id IS NOT NULL THEN
           csm_mtl_system_items_event_pkg.mtl_system_items_acc_i
                       (p_inventory_item_id=>l_sr_rec.inventory_item_id,
                        p_organization_id=>NVL(l_sr_rec.inv_organization_id, l_organization_id),
                        p_user_id=>l_owner_id,
                        p_error_msg=>l_error_msg,
                        x_return_status=>l_return_status);
      END IF;
   END IF;

   -- insert into incidents acc
   csm_sr_event_pkg.incidents_acc_i(p_incident_id=>l_sr_rec.incident_id,
                                    p_user_id=>l_owner_id);

   -- get SR contracts
   csm_contract_event_pkg.sr_contract_acc_i(p_incident_id=>l_sr_rec.incident_id,
                                            p_user_id=>l_owner_id);

   --get contract notes
   IF l_sr_rec.contract_service_id IS NOT NULL THEN
     csm_notes_event_pkg.notes_make_dirty_i_grp(p_sourceobjectcode=>'OKS_COV_NOTE',
                                              p_sourceobjectid=>l_sr_rec.contract_service_id,
                                              p_userid=>l_owner_id,
                                              p_error_msg=>l_error_msg,
                                              x_return_status=>l_return_status);
   END IF;

   --DOWNLOAD TASK/TASK_ASSIGNMENTS TO SR OWNER
   FOR task_rec IN c_tasks(p_incident_id)
   LOOP
   --dwnld notes to owner  if required
/*     csm_notes_event_pkg.notes_make_dirty_i_grp(p_sourceobjectcode=>'TASK',
                                              p_sourceobjectid=>task_rec.task_id,
                                              p_userid=>l_owner_id,
                                              p_error_msg=>l_error_msg,
                                              x_return_status=>l_return_status);*/

    csm_task_event_pkg.acc_insert(p_task_id=>task_rec.task_id,p_user_id=>l_owner_id);

    for assign_rec in c_task_assignments(task_rec.task_id)
    loop
     csm_task_assignment_event_pkg.acc_insert(p_task_assignment_id=>assign_rec.task_assignment_id,p_user_id=>l_owner_id);

         -- to download other grp's resource if required
     OPEN c_resource_id(l_owner_id);
     FETCH c_resource_id INTO l_owner_resource_id;
     CLOSE c_resource_id;
     IF NOT CSM_UTIL_PKG.from_same_group(l_owner_resource_id,assign_rec.resource_id) THEN
--assignee bug
       OPEN c_user_id(assign_rec.resource_id);
       FETCH c_user_id INTO l_assignee_user_id;
       CLOSE c_user_id;
       IF l_assignee_user_id IS NOT NULL THEN
        CSM_USER_EVENT_PKG.INSERT_ACC(l_assignee_user_id,l_owner_id);
       END IF;
     END IF;
     --to decide if LOBS shd be downloaded for task assignment and also service history
    end loop;

   END LOOP;

   CSM_UTIL_PKG.LOG('Leaving SR_INS_INIT for incident_id: ' || p_incident_id ,'CSM_SR_EVENT_PKG.SR_INS_INIT',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  SR_INS_INIT for incident_id:'
                       || to_char(p_incident_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_SR_EVENT_PKG.SR_INS_INIT',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END SR_INS_INIT;

--12.1
PROCEDURE SR_DEL_INIT(p_incident_id IN NUMBER,p_user_id IN NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);
l_organization_id NUMBER;
l_owner_id NUMBER;
l_owner_resource_id NUMBER;

--12.1XB6
CURSOR l_sr_csr (p_incident_id cs_incidents_all_b.incident_id%TYPE,b_user_id NUMBER)
IS
SELECT csi.incident_id,
       csi.customer_id,
       csi.install_site_id,
       csi.customer_product_id,
       csi.inventory_item_id,
       csi.inv_organization_id,
       csi.contract_service_id,
       csi.created_by,
       csi.incident_location_id,
       csi.customer_id party_id,
       decode(nvl(csi.incident_location_type,'HZ_PARTY_SITE'),
	   'HZ_PARTY_SITE',
       (select location_id from hz_party_sites where party_site_id = NVL(csi.incident_location_id, csi.install_site_id)),
       'HZ_LOCATION',
       (select location_id from hz_locations where location_id = NVL(csi.incident_location_id, csi.install_site_id))
	   ) location_id ,
       nvl(csi.incident_location_type,'HZ_PARTY_SITE') incident_location_type,
       csi.owner_group_id
FROM   cs_incidents_all_b csi
WHERE  csi.incident_id = p_incident_id
AND  nvl(csi.incident_location_type,'HZ_PARTY_SITE') IN ('HZ_PARTY_SITE','HZ_LOCATION')
AND EXISTS
(SELECT 1
 FROM csm_incidents_all_acc acc
 WHERE acc.incident_id = csi.incident_id
 AND acc.user_id = NVL(b_user_id,decode(CSM_UTIL_PKG.get_group_owner(csi.owner_group_id),-1,csi.created_by,CSM_UTIL_PKG.get_group_owner(csi.owner_group_id)) ));

l_sr_rec l_sr_csr%ROWTYPE;

CURSOR c_tasks(b_incident_id NUMBER)
IS
SELECT tsk.TASK_ID
FROM JTF_TASKS_B tsk,
     JTF_TASK_TYPES_B ttype
WHERE tsk.SOURCE_OBJECT_TYPE_CODE='SR'
AND   tsk.SOURCE_OBJECT_ID=b_incident_id
AND   ttype.TASK_TYPE_ID = tsk.TASK_TYPE_ID
AND   ttype.RULE='DISPATCH';

CURSOR c_task_assignments(b_task_id NUMBER)
IS
SELECT TASK_ASSIGNMENT_ID,resource_id
FROM JTF_TASK_ASSIGNMENTS
WHERE TASK_ID=b_task_id;

CURSOR c_resource_id(b_user_id NUMBER) IS
SELECT RESOURCE_ID
FROM JTF_RS_RESOURCE_EXTNS
WHERE USER_ID=b_user_id;

--assignee bug
CURSOR c_user_id(b_resource_id NUMBER) IS
SELECT USER_ID
FROM JTF_RS_RESOURCE_EXTNS
WHERE RESOURCE_ID=b_resource_id;

l_assignee_user_id NUMBER;


BEGIN
   CSM_UTIL_PKG.LOG('Entering SR_DEL_INIT for incident_id: ' || p_incident_id ,'CSM_SR_EVENT_PKG.SR_DEL_INIT',FND_LOG.LEVEL_PROCEDURE);

   OPEN l_sr_csr(p_incident_id,p_user_id);
   FETCH l_sr_csr INTO l_sr_rec;
   IF l_sr_csr%NOTFOUND THEN
     CLOSE l_sr_csr;
     RETURN;
   END IF;
   CLOSE l_sr_csr;

--12.1XB6
   IF p_user_id IS NULL THEN
      IF ( NOT CSM_UTIL_PKG.is_mfs_group(l_sr_rec.owner_group_id)) THEN
          IF ( NOT CSM_UTIL_PKG.is_palm_user(l_sr_rec.created_by)) THEN
              CSM_UTIL_PKG.LOG('Leaving SR_DEL_INIT since the Owner group of SR is not a mobile resource group
			                    and also this SR , incident_id: ' || p_incident_id ||' is not created by a mobile user'
			   ,'CSM_SR_EVENT_PKG.SR_DEL_INIT',FND_LOG.LEVEL_PROCEDURE);
              RETURN;
          ELSE
              l_owner_id := CSM_UTIL_PKG.get_owner(l_sr_rec.created_by);
          END IF;
      ELSE
        l_owner_id := CSM_UTIL_PKG.get_group_owner(l_sr_rec.owner_group_id);
      END IF;
   ELSE
    l_owner_id:=p_user_id;
   END IF;
   -- get Service Inv Validation org
   l_organization_id := csm_profile_pkg.get_organization_id(l_owner_id);

   -- delete from incidents acc
   csm_sr_event_pkg.incidents_acc_d(p_incident_id=>l_sr_rec.incident_id,
                                    p_user_id=>l_owner_id);

   -- delete SR notes
   csm_notes_event_pkg.notes_make_dirty_d_grp(p_sourceobjectcode=>'SR',
                                              p_sourceobjectid=>l_sr_rec.incident_id,
                                              p_userid=>l_owner_id,
                                              p_error_msg=>l_error_msg,
                                              x_return_status=>l_return_status);

   -- delete SR contacts
   csm_sr_event_pkg.spawn_sr_contact_del(p_incident_id=>l_sr_rec.incident_id,
                                         p_user_id=>l_owner_id,
                                         p_flowtype=>NULL);
   IF l_sr_rec.incident_location_type = 'HZ_LOCATION' THEN --R12 Assest
   		--insert location for the sr
    	csm_hz_locations_event_pkg.delete_location(p_location_id => l_sr_rec.incident_location_id,
                                              p_user_id => l_owner_id);
   ELSE
   		-- spawn party site del
	   IF l_sr_rec.incident_location_id IS NOT NULL THEN
     	csm_party_site_event_pkg.party_sites_acc_d(p_party_site_id => l_sr_rec.incident_location_id,
                                                p_user_id => l_owner_id,
                                                p_flowtype => NULL,
                                                p_error_msg => l_error_msg,
                                                x_return_status => l_return_status);
   		END IF;
	END IF;
   -- spawn SR customer del
   IF l_sr_rec.customer_id IS NOT NULL THEN
     csm_party_event_pkg.party_acc_d(p_party_id => l_sr_rec.customer_id,
                                     p_user_id => l_owner_id,
                                     p_flowtype => NULL,
                                     p_error_msg => l_error_msg,
                                     x_return_status => l_return_status);
	 --Delete Accounts for the above party-R12
     CSM_CUSTOMER_ACCOUNT_EVENT_PKG.CUST_ACCOUNTS_DEL
                                    (p_party_id=>l_sr_rec.customer_id
                                    ,p_user_id =>l_owner_id);

   END IF;

   -- delete SR contract
   IF l_sr_rec.contract_service_id IS NOT NULL THEN
     csm_contract_event_pkg.sr_contract_acc_d(p_incident_id=>l_sr_rec.inventory_item_id,
                                              p_user_id=>l_owner_id);
   END IF;

   -- delete contract notes
   IF l_sr_rec.contract_service_id IS NOT NULL THEN
     csm_notes_event_pkg.notes_make_dirty_d_grp(p_sourceobjectcode=>'OKS_COV_NOTE',
                                              p_sourceobjectid=>l_sr_rec.contract_service_id,
                                              p_userid=>l_owner_id,
                                              p_error_msg=>l_error_msg,
                                              x_return_status=>l_return_status);
   END IF;

   IF l_sr_rec.customer_product_id IS NOT NULL THEN
      -- spawn SR item instance delete
      csm_sr_event_pkg.sr_item_del_init(p_incident_id=>l_sr_rec.incident_id,
                                        p_instance_id=>l_sr_rec.customer_product_id,
                                        p_party_site_id=>l_sr_rec.incident_location_id,
                                        p_party_id=>l_sr_rec.party_id,
                                        p_location_id=>l_sr_rec.location_id,
                                        p_organization_id=>NVL(l_sr_rec.inv_organization_id, l_organization_id),
                                        p_user_id=>l_owner_id,
                                        p_flow_type=>NULL);

   ELSIF l_sr_rec.customer_product_id IS NULL OR l_sr_rec.customer_product_id = 0 THEN
      IF l_sr_rec.inventory_item_id IS NOT NULL THEN
           csm_mtl_system_items_event_pkg.mtl_system_items_acc_d
                       (p_inventory_item_id=>l_sr_rec.inventory_item_id,
                        p_organization_id=>NVL(l_sr_rec.inv_organization_id, l_organization_id),
                        p_user_id=>l_owner_id,
                        p_error_msg=>l_error_msg,
                        x_return_status=>l_return_status);
      END IF;
   END IF;

   --DELETE TASK/TASK_ASSIGNMENTS DOWNLOADED TO SR OWNER
   FOR task_rec IN c_tasks(p_incident_id)
   LOOP
      -- delete task notes if inserted
   /* csm_notes_event_pkg.notes_make_dirty_d_grp(p_sourceobjectcode=>'TASK',
                                              p_sourceobjectid=>task_rec.task_id,
                                              p_userid=>l_owner_id,
                                              p_error_msg=>l_error_msg,
                                              x_return_status=>l_return_status);*/

    csm_task_event_pkg.acc_delete(p_task_id=>task_rec.task_id,p_user_id=>l_owner_id);

    for assign_rec in c_task_assignments(task_rec.task_id)
    loop

     csm_task_assignment_event_pkg.acc_delete(p_task_assignment_id=>assign_rec.task_assignment_id,p_user_id=>l_owner_id);

     /*Other grp's member Resource to be deleted from acc if assigned to him*/
     OPEN c_resource_id(l_owner_id);
     FETCH c_resource_id INTO l_owner_resource_id;
     CLOSE c_resource_id;
     IF NOT CSM_UTIL_PKG.from_same_group(l_owner_resource_id,assign_rec.resource_id) THEN
--assignee bug
       OPEN c_user_id(assign_rec.resource_id);
       FETCH c_user_id INTO l_assignee_user_id;
       CLOSE c_user_id;
       IF l_assignee_user_id IS NOT NULL THEN
        CSM_USER_EVENT_PKG.DELETE_ACC(l_assignee_user_id,l_owner_id);
       END IF;
     END IF;
    end loop;

   END LOOP;

   CSM_UTIL_PKG.LOG('Leaving SR_DEL_INIT for incident_id: ' || p_incident_id ,'CSM_SR_EVENT_PKG.SR_DEL_INIT',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  SR_DEL_INIT for incident_id:'
                       || to_char(p_incident_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_SR_EVENT_PKG.SR_DEL_INIT',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END SR_DEL_INIT;

--12.1
PROCEDURE SR_UPD_INIT(p_incident_id IN NUMBER, p_is_install_site_updated IN VARCHAR2,
                      p_old_install_site_id IN NUMBER,
                      p_is_incident_location_updated IN VARCHAR2,
                      p_old_incident_location_id IN NUMBER, p_is_sr_customer_updated IN VARCHAR2,
                      p_old_sr_customer_id IN NUMBER, p_is_sr_instance_updated IN VARCHAR2,
                      p_old_instance_id IN NUMBER, p_is_inventory_item_updated IN VARCHAR2,
                      p_old_inventory_item_id IN NUMBER, p_old_organization_id IN NUMBER,
                      p_old_party_id IN NUMBER, p_old_location_id IN NUMBER,
                      p_is_contr_service_id_updated IN VARCHAR2, p_old_contr_service_id IN NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);
l_organization_id NUMBER;

CURSOR l_sr_csr (p_incident_id cs_incidents_all_b.incident_id%TYPE)
IS
SELECT csi.incident_id,
       csi.customer_id,
       csi.install_site_id,
       csi.customer_product_id,
       csi.inventory_item_id,
       csi.inv_organization_id,
       csi.contract_service_id,
       csi.created_by,
       csi.incident_location_id,
       csi.customer_id party_id,
       decode(nvl(csi.incident_location_type,'HZ_PARTY_SITE'),
	   'HZ_PARTY_SITE',
       (select location_id from hz_party_sites where party_site_id = NVL(csi.incident_location_id, csi.install_site_id)),
       'HZ_LOCATION',
       (select location_id from hz_locations where location_id = NVL(csi.incident_location_id, csi.install_site_id))
	   ) location_id ,
       nvl(csi.incident_location_type,'HZ_PARTY_SITE') incident_location_type,
       csi.owner_group_id
FROM   cs_incidents_all_b csi
WHERE  csi.incident_id = p_incident_id
AND  nvl(csi.incident_location_type,'HZ_PARTY_SITE') IN ('HZ_PARTY_SITE','HZ_LOCATION');


CURSOR l_addr_id_csr (p_incident_id IN NUMBER)
IS
SELECT NVL(LOCATION_ID,ADDRESS_ID)--R12Assest
FROM JTF_TASKS_B
WHERE SOURCE_OBJECT_TYPE_CODE = 'SR'
AND SOURCE_OBJECT_ID = p_incident_id;

l_sr_rec l_sr_csr%ROWTYPE;

CURSOR l_csm_task_assg_csr (p_incident_id cs_incidents_all_b.incident_id%TYPE)
IS
SELECT acc.access_id, acc.user_id
FROM csm_incidents_all_acc acc
WHERE acc.incident_id = p_incident_id;


BEGIN
   CSM_UTIL_PKG.LOG('Entering SR_UPD_INIT for incident_id: ' || p_incident_id ,'CSM_SR_EVENT_PKG.SR_UPD_INIT',FND_LOG.LEVEL_PROCEDURE);

   OPEN l_sr_csr(p_incident_id);
   FETCH l_sr_csr INTO l_sr_rec;
   IF l_sr_csr%NOTFOUND THEN
     CLOSE l_sr_csr;
     RETURN;
   END IF;
   CLOSE l_sr_csr;

  -- not necessary as all DISPATCH Sr's need an install site id
   IF l_sr_rec.incident_location_id IS NULL THEN
       OPEN l_addr_id_csr(p_incident_id);
       FETCH l_addr_id_csr INTO l_sr_rec.incident_location_id;
       CLOSE l_addr_id_csr;
   END IF;

   -- get all users having access for this SR
  FOR r_csm_task_assg_rec IN l_csm_task_assg_csr(p_incident_id) LOOP
   l_organization_id := csm_profile_pkg.get_organization_id(r_csm_task_assg_rec.user_id);

   IF p_is_incident_location_updated = 'Y' THEN
       IF l_sr_rec.incident_location_type = 'HZ_LOCATION' THEN --R12 Assest
 		--Delete old location
      	IF p_old_incident_location_id IS NOT NULL THEN

    	csm_hz_locations_event_pkg.delete_location(p_location_id => l_sr_rec.incident_location_id,
	                                              p_user_id => r_csm_task_assg_rec.user_id);
      	END IF;

      	IF l_sr_rec.incident_location_id IS NOT NULL THEN
        -- insert new location
        csm_hz_locations_event_pkg.insert_location(p_location_id => l_sr_rec.incident_location_id,
	                                              p_user_id => r_csm_task_assg_rec.user_id);
      	END IF;

	ELSE

      IF p_old_incident_location_id IS NOT NULL THEN
         -- spawn party site del process
         csm_party_site_event_pkg.party_sites_acc_d(p_party_site_id => p_old_incident_location_id,
                                                  p_user_id => r_csm_task_assg_rec.user_id,
                                                  p_flowtype => NULL,
                                                  p_error_msg => l_error_msg,
                                                  x_return_status => l_return_status);
      END IF;

      IF l_sr_rec.incident_location_id IS NOT NULL THEN
        -- spawn party site ins process
        csm_party_site_event_pkg.party_sites_acc_i(p_party_site_id => l_sr_rec.incident_location_id,
                                                    p_user_id => r_csm_task_assg_rec.user_id,
                                                    p_flowtype => NULL,
                                                    p_error_msg => l_error_msg,
                                                    x_return_status => l_return_status);
      END IF;
    END IF;
   END IF;

   IF p_is_sr_customer_updated = 'Y' THEN
      IF p_old_sr_customer_id IS NOT NULL THEN
        -- spawn party del process
        csm_party_event_pkg.party_acc_d(p_party_id=>p_old_sr_customer_id,
                                      p_user_id=>r_csm_task_assg_rec.user_id,
                                      p_flowtype=>NULL,
                                      p_error_msg=>l_error_msg,
                                      x_return_status=>l_return_status);
      END IF;

      IF l_sr_rec.customer_id IS NOT NULL THEN
        -- spawn party site ins process
        csm_party_event_pkg.party_acc_i(p_party_id=>l_sr_rec.customer_id,
                                      p_user_id=>r_csm_task_assg_rec.user_id,
                                      p_flowtype=>NULL,
                                      p_error_msg=>l_error_msg,
                                      x_return_status=>l_return_status);
      END IF;
   END IF;

   IF p_is_sr_instance_updated = 'Y' THEN
     IF p_old_instance_id IS NOT NULL THEN
       -- spawn SR item instance delete
       csm_sr_event_pkg.sr_item_del_init(p_incident_id=>l_sr_rec.incident_id,
                                        p_instance_id=>p_old_instance_id,
                                        p_party_site_id=>p_old_incident_location_id,
                                        p_party_id=>p_old_party_id,
                                        p_location_id=>p_old_location_id,
                                        p_organization_id=>NVL(p_old_organization_id, l_organization_id),
                                        p_user_id=>r_csm_task_assg_rec.user_id,
                                        p_flow_type=>NULL);
     END IF;

     IF l_sr_rec.customer_product_id IS NOT NULL THEN
       -- spawn SR item instance insert
       csm_sr_event_pkg.sr_item_ins_init(p_incident_id=>l_sr_rec.incident_id,
                                        p_instance_id=>l_sr_rec.customer_product_id,
                                        p_party_site_id=>l_sr_rec.incident_location_id,
                                        p_party_id=>l_sr_rec.party_id,
                                        p_location_id=>l_sr_rec.location_id,
                                        p_organization_id=>NVL(l_sr_rec.inv_organization_id, l_organization_id),
                                        p_user_id=>r_csm_task_assg_rec.user_id,
                                        p_flow_type=>NULL);
     END IF;
   END IF;

   IF p_is_inventory_item_updated = 'Y' THEN
     IF p_old_inventory_item_id IS NOT NULL THEN
           csm_mtl_system_items_event_pkg.mtl_system_items_acc_d
                       (p_inventory_item_id=>p_old_inventory_item_id,
                        p_organization_id=>NVL(p_old_organization_id, l_organization_id),
                        p_user_id=>r_csm_task_assg_rec.user_id,
                        p_error_msg=>l_error_msg,
                        x_return_status=>l_return_status);
     END IF;

     IF l_sr_rec.inventory_item_id IS NOT NULL THEN
           csm_mtl_system_items_event_pkg.mtl_system_items_acc_i
                       (p_inventory_item_id=>l_sr_rec.inventory_item_id,
                        p_organization_id=>NVL(l_sr_rec.inv_organization_id, l_organization_id),
                        p_user_id=>r_csm_task_assg_rec.user_id,
                        p_error_msg=>l_error_msg,
                        x_return_status=>l_return_status);
     END IF;
   END IF;

   IF p_is_contr_service_id_updated = 'Y' THEN
     csm_contract_event_pkg.sr_contract_acc_u(p_incident_id=>l_sr_rec.incident_id,
                                              p_old_contract_service_id=>p_old_contr_service_id,
                                              p_contract_service_id=>l_sr_rec.contract_service_id,
                                              p_user_id=>r_csm_task_assg_rec.user_id);
   END IF;

   -- incidents make dirty for update
   CSM_ACC_PKG.Update_Acc
         ( P_PUBLICATION_ITEM_NAMES => g_incidents_pubi_name
          ,P_ACC_TABLE_NAME         => g_incidents_acc_table_name
          ,P_USER_ID                => r_csm_task_assg_rec.user_id
          ,P_ACCESS_ID              => r_csm_task_assg_rec.access_id
         );

 END LOOP;

   CSM_UTIL_PKG.LOG('Leaving SR_UPD_INIT for incident_id: ' || p_incident_id ,'CSM_SR_EVENT_PKG.SR_UPD_INIT',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  SR_UPD_INIT for incident_id:'
                       || to_char(p_incident_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_SR_EVENT_PKG.SR_UPD_INIT',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END SR_UPD_INIT;

--Function to find whether the SR associated with Task assignment id is open before purging.
FUNCTION IS_SR_OPEN ( p_task_id IN NUMBER)
RETURN BOOLEAN
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_incident_id cs_incidents_all_b.incident_id%TYPE;

CURSOR l_is_sr_open_csr(c_task_id jtf_tasks_b.task_id%TYPE)
IS
SELECT inc.incident_id
FROM   cs_incidents_all_b 	  inc,
       cs_incident_statuses_b ists,
       jtf_tasks_b 			  tsk
WHERE  inc.INCIDENT_STATUS_ID = ists.INCIDENT_STATUS_ID
AND    ists.CLOSE_FLAG 		  = 'Y'
AND    tsk.task_id  		  = c_task_id
AND    tsk.source_object_id   = inc.incident_id;

BEGIN
   CSM_UTIL_PKG.LOG('Entering CSM_SR_EVENT_PKG.IS_SR_OPEN for task_id: ' || p_task_id,
                         'CSM_SR_EVENT_PKG.IS_SR_OPEN',FND_LOG.LEVEL_PROCEDURE);

   l_incident_id := NULL;

   OPEN   l_is_sr_open_csr(p_task_id);
   FETCH  l_is_sr_open_csr INTO l_incident_id;
   IF     l_is_sr_open_csr%NOTFOUND THEN

	   CLOSE l_is_sr_open_csr;
       CSM_UTIL_PKG.LOG('The SR is open for task_id : ' || p_task_id,
                         'CSM_SR_EVENT_PKG.IS_SR_OPEN',FND_LOG.LEVEL_EXCEPTION);
       RETURN TRUE;
   END IF;
   CLOSE l_is_sr_open_csr;

   CSM_UTIL_PKG.LOG('The SR is Closed for task_id : ' || p_task_id,
                         'CSM_SR_EVENT_PKG.IS_SR_OPEN',FND_LOG.LEVEL_EXCEPTION);

   RETURN FALSE;

EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  IS_SR_OPEN for task_id:' || to_char(p_task_id)
                           || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_SR_EVENT_PKG.IS_SR_OPEN',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END IS_SR_OPEN;


--Function to find whether the SR associated with Task assignment id is open before purging.
PROCEDURE GET_PROFORMA_INVOICE (
    itemtype IN VARCHAR2
   ,itemkey  IN VARCHAR2
   ,actid    IN NUMBER
   ,funcmode IN VARCHAR2
   ,RESULT   IN OUT NOCOPY VARCHAR2)
IS
--PRAGMA AUTONOMOUS_TRANSACTION;

CURSOR c_check_results(c_USER_ID NUMBER,c_QUERY_ID NUMBER,c_INSTANCE_ID NUMBER)
IS
SELECT ACCESS_ID
FROM  CSM_QUERY_RESULTS_ACC
WHERE QUERY_ID    = c_QUERY_ID
AND   USER_ID     = c_USER_ID
AND   INSTANCE_ID = c_INSTANCE_ID;

CURSOR c_get_sr_id (c_incident_number VARCHAR2)
IS
SELECT INCIDENT_ID FROM CS_INCIDENTS_ALL_B
WHERE INCIDENT_NUMBER =c_incident_number;

CURSOR c_get_invoice(c_incident_id NUMBER)
IS
SELECT inv.INCIDENT_ID,
       inv.LINE_NUMBER,
       inv.BUSINESS_PROCESS_ID,
       inv.TXN_BILLING_TYPE_ID,
       inv.INVENTORY_ITEM_ID,
       inv.SERIAL_NUMBER,
       inv.QUANTITY_REQUIRED,
       inv.UNIT_OF_MEASURE_CODE,
       inv.SELLING_PRICE,
       inv.AFTER_WARRANTY_COST,
       inv.CHARGE_LINE_TYPE,
       inv.BILL_TO_PARTY_ID
FROM   CS_ESTIMATE_DETAILS  inv
WHERE  INV.ORIGINAL_SOURCE_CODE = 'SR'
AND    inv.INCIDENT_ID = c_incident_id ;

 l_xml         CLOB;
 l_xml_blob    BLOB;
 qrycontext   DBMS_XMLGEN.ctxHandle;
 l_dest_offset NUMBER := 1;
 l_Src_offset  NUMBER := 1;
 l_language    NUMBER := 0;
 l_warning     NUMBER := 0;
 l_access_id   NUMBER;
 l_mark_dirty  BOOLEAN;
 l_rs_access_id   NUMBER;
 l_SQL_TEXT       VARCHAR2(4000);
 g_pub_item_qres      VARCHAR2(30) := 'CSM_QUERY_RESULTS';
 l_sqlerrno VARCHAR2(200);
 l_sqlerrmsg VARCHAR2(4000);
 l_error_msg VARCHAR2(4000);
 l_error_status VARCHAR2(200);
 l_INCIDENT_ID  NUMBER;
 l_USER_ID NUMBER;
 l_QUERY_ID NUMBER;
 l_INSTANCE_ID NUMBER;
 l_INCIDENT_NUM VARCHAR2(64);

BEGIN
   CSM_UTIL_PKG.LOG('Entering CSM_SR_EVENT_PKG.GET_PROFORMA_INVOICE ',
                         'CSM_SR_EVENT_PKG.GET_PROFORMA_INVOICE',FND_LOG.LEVEL_PROCEDURE);

    IF (funcmode <> 'RUN')
    THEN
      RETURN;
    END IF;

    l_USER_ID      := wf_engine.getitemattrnumber(itemtype => itemtype, itemkey  => itemkey, aname    => 'USER_ID');
    l_QUERY_ID     := wf_engine.getitemattrnumber(itemtype => itemtype, itemkey  => itemkey, aname    => 'QUERY_ID');
    l_INSTANCE_ID  := wf_engine.getitemattrnumber(itemtype => itemtype, itemkey  => itemkey, aname    => 'INSTANCE_ID');
    l_INCIDENT_NUM := wf_engine.getitemattrtext(itemtype => itemtype, itemkey  => itemkey, aname    => 'SR_NUMBER');

    OPEN  c_get_sr_id (l_INCIDENT_NUM);
    FETCH c_get_sr_id INTO l_INCIDENT_ID;
    CLOSE c_get_sr_id;

    IF l_INCIDENT_ID IS NULL THEN
         CSM_UTIL_PKG.LOG('The Given SR number is Invalid : ' || l_INCIDENT_NUM,
                         'CSM_SR_EVENT_PKG.GET_PROFORMA_INVOICE',FND_LOG.LEVEL_PROCEDURE);
         RETURN;
    END IF;


      l_SQL_TEXT := 'SELECT inv.INCIDENT_ID,   inv.LINE_NUMBER,     inv.BUSINESS_PROCESS_ID,
     inv.TXN_BILLING_TYPE_ID,       inv.INVENTORY_ITEM_ID,       inv.SERIAL_NUMBER,
     inv.QUANTITY_REQUIRED,       inv.UNIT_OF_MEASURE_CODE,       inv.SELLING_PRICE,
     inv.AFTER_WARRANTY_COST,       inv.CHARGE_LINE_TYPE,       inv.BILL_TO_PARTY_ID
      FROM   CS_ESTIMATE_DETAILS  inv WHERE  INV.ORIGINAL_SOURCE_CODE = ''SR''
      AND    inv.INCIDENT_ID = ' || l_INCIDENT_ID ;
      --Execute the SQL query
    qrycontext := DBMS_XMLGEN.newcontext(l_SQL_TEXT) ;

    l_xml := DBMS_XMLGEN.getxml (qrycontext);

    IF DBMS_LOB.GETLENGTH(l_xml) > 0 THEN
      --Convert the XML output into BLOB and store it in the DB
      dbms_lob.createtemporary(l_xml_blob,TRUE);
      DBMS_LOB.convertToBlob(l_xml_blob,l_xml,DBMS_LOB.LOBMAXSIZE,
                        l_dest_offset,l_src_offset,DBMS_LOB.default_csid,l_language,l_warning);

      CSM_QUERY_PKG.INSERT_RESULT
          ( p_USER_ID       => l_USER_ID,
            p_QUERY_ID      => l_QUERY_ID,
            p_INSTANCE_ID   => l_INSTANCE_ID,
            p_QUERY_RESULT  => l_xml_blob,
            p_commit        => fnd_api.G_FALSE,
            x_return_status => l_error_status,
            x_error_message =>  l_error_msg
          );
    END IF;

    IF l_error_status = FND_API.G_RET_STS_SUCCESS THEN
      COMMIT;
      RESULT := 'COMPLETE:Y';
     CSM_UTIL_PKG.LOG('Proforma Invoice Generated sucessfully for  Incident Number : ' || l_INCIDENT_NUM,
                         'CSM_SR_EVENT_PKG.GET_PROFORMA_INVOICE',FND_LOG.LEVEL_EXCEPTION);

    ELSE
      CSM_UTIL_PKG.LOG('ERROR IN CSM_SR_EVENT_PKG.GET_PROFORMA_INVOICE' || l_error_msg, 'CSM_SR_EVENT_PKG.GET_PROFORMA_INVOICE',FND_LOG.LEVEL_EXCEPTION);
      ROLLBACK;
      RESULT := 'COMPLETE:N';
    END IF;

EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  GET_PROFORMA_INVOICE for Incident Number:' || to_char(l_INCIDENT_NUM)
                           || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_SR_EVENT_PKG.GET_PROFORMA_INVOICE',FND_LOG.LEVEL_EXCEPTION);
        ROLLBACK;
        RESULT := 'COMPLETE:N';
END GET_PROFORMA_INVOICE;

END CSM_SR_EVENT_PKG;

/
